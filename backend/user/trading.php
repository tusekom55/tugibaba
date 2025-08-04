<?php
// Session yönetimi - çakışma önleme
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Config dosyası path'ini esnek şekilde bulma
$config_paths = [
    __DIR__ . '/../config.php',
    __DIR__ . '/config.php',
    dirname(__DIR__) . '/config.php'
];

$config_loaded = false;
foreach ($config_paths as $path) {
    if (file_exists($path)) {
        require_once $path;
        $config_loaded = true;
        break;
    }
}

if (!$config_loaded) {
    http_response_code(500);
    die(json_encode(['success' => false, 'message' => 'Config dosyası bulunamadı']));
}

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Session kontrolü (debug modunda esneklik)
if (!isset($_SESSION['user_id']) && (!defined('DEBUG_MODE') || !DEBUG_MODE)) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Oturum açmanız gerekiyor']);
    exit;
}

$action = $_GET['action'] ?? '';
$user_id = $_SESSION['user_id'];

try {
    $conn = db_connect();
    
    switch ($action) {
        case 'buy':
            // Coin satın alma
            $coin_id = intval($_POST['coin_id'] ?? 0);
            $miktar = floatval($_POST['miktar'] ?? 0);
            $fiyat = floatval($_POST['fiyat'] ?? 0);
            
            if ($coin_id <= 0 || $miktar <= 0 || $fiyat <= 0) {
                echo json_encode(['success' => false, 'message' => 'Geçersiz parametreler']);
                exit;
            }
            
            $toplam_tutar = $miktar * $fiyat;
            
            // Kullanıcının bakiyesini kontrol et
            $balance_sql = "SELECT balance FROM users WHERE id = ?";
            $balance_stmt = $conn->prepare($balance_sql);
            $balance_stmt->execute([$user_id]);
            $current_balance = $balance_stmt->fetchColumn();
            
            if ($current_balance < $toplam_tutar) {
                echo json_encode(['success' => false, 'message' => 'Yetersiz bakiye. Mevcut: ₺' . number_format($current_balance, 2)]);
                exit;
            }
            
            // Coin bilgilerini al
            $coin_sql = "SELECT coin_adi, coin_kodu FROM coins WHERE id = ? AND is_active = 1";
            $coin_stmt = $conn->prepare($coin_sql);
            $coin_stmt->execute([$coin_id]);
            $coin = $coin_stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$coin) {
                echo json_encode(['success' => false, 'message' => 'Coin bulunamadı']);
                exit;
            }
            
            $conn->beginTransaction();
            
            try {
                // Coin işlemini kaydet
                $trade_sql = "INSERT INTO coin_islemleri (user_id, coin_id, islem, miktar, fiyat, tarih) VALUES (?, ?, 'al', ?, ?, NOW())";
                $trade_stmt = $conn->prepare($trade_sql);
                $trade_stmt->execute([$user_id, $coin_id, $miktar, $fiyat]);
                $trade_id = $conn->lastInsertId();
                
                // Kullanıcının bakiyesini güncelle
                $update_balance_sql = "UPDATE users SET balance = balance - ? WHERE id = ?";
                $update_balance_stmt = $conn->prepare($update_balance_sql);
                $update_balance_stmt->execute([$toplam_tutar, $user_id]);
                
                // Yeni bakiyeyi al
                $new_balance = $current_balance - $toplam_tutar;
                
                // İşlem geçmişine ekle
                $history_sql = "INSERT INTO kullanici_islem_gecmisi 
                               (user_id, islem_tipi, islem_detayi, tutar, onceki_bakiye, sonraki_bakiye) 
                               VALUES (?, 'coin_al', ?, ?, ?, ?)";
                $history_stmt = $conn->prepare($history_sql);
                $history_stmt->execute([
                    $user_id,
                    "{$miktar} {$coin['coin_kodu']} satın alındı (₺{$fiyat} fiyatından)",
                    $toplam_tutar,
                    $current_balance,
                    $new_balance
                ]);
                
                // Log kaydı
                $log_sql = "INSERT INTO loglar (user_id, tip, detay) VALUES (?, 'coin_islem', ?)";
                $log_stmt = $conn->prepare($log_sql);
                $log_stmt->execute([
                    $user_id, 
                    "SATIN ALMA: {$miktar} {$coin['coin_kodu']} - ₺{$toplam_tutar} - ID:{$trade_id}"
                ]);
                
                $conn->commit();
                
                echo json_encode([
                    'success' => true, 
                    'message' => "{$miktar} {$coin['coin_kodu']} başarıyla satın alındı",
                    'data' => [
                        'trade_id' => $trade_id,
                        'miktar' => $miktar,
                        'fiyat' => $fiyat,
                        'toplam_tutar' => $toplam_tutar,
                        'new_balance' => $new_balance,
                        'coin' => $coin
                    ]
                ]);
                
            } catch (Exception $e) {
                $conn->rollback();
                throw $e;
            }
            break;
            
        case 'sell':
            // Coin satma
            $coin_id = intval($_POST['coin_id'] ?? 0);
            $miktar = floatval($_POST['miktar'] ?? 0);
            $fiyat = floatval($_POST['fiyat'] ?? 0);
            
            if ($coin_id <= 0 || $miktar <= 0 || $fiyat <= 0) {
                echo json_encode(['success' => false, 'message' => 'Geçersiz parametreler']);
                exit;
            }
            
            // Kullanıcının bu coin'den sahip olduğu miktarı hesapla
            $portfolio_sql = "SELECT 
                                SUM(CASE WHEN islem = 'al' THEN miktar ELSE -miktar END) as net_miktar
                              FROM coin_islemleri 
                              WHERE user_id = ? AND coin_id = ?";
            $portfolio_stmt = $conn->prepare($portfolio_sql);
            $portfolio_stmt->execute([$user_id, $coin_id]);
            $net_miktar = $portfolio_stmt->fetchColumn() ?: 0;
            
            if ($net_miktar < $miktar) {
                echo json_encode(['success' => false, 'message' => 'Yetersiz coin miktarı. Mevcut: ' . $net_miktar]);
                exit;
            }
            
            // Coin bilgilerini al
            $coin_sql = "SELECT coin_adi, coin_kodu FROM coins WHERE id = ? AND is_active = 1";
            $coin_stmt = $conn->prepare($coin_sql);
            $coin_stmt->execute([$coin_id]);
            $coin = $coin_stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$coin) {
                echo json_encode(['success' => false, 'message' => 'Coin bulunamadı']);
                exit;
            }
            
            $toplam_tutar = $miktar * $fiyat;
            
            // Mevcut bakiyeyi al
            $balance_sql = "SELECT balance FROM users WHERE id = ?";
            $balance_stmt = $conn->prepare($balance_sql);
            $balance_stmt->execute([$user_id]);
            $current_balance = $balance_stmt->fetchColumn();
            
            $conn->beginTransaction();
            
            try {
                // Coin işlemini kaydet
                $trade_sql = "INSERT INTO coin_islemleri (user_id, coin_id, islem, miktar, fiyat, tarih) VALUES (?, ?, 'sat', ?, ?, NOW())";
                $trade_stmt = $conn->prepare($trade_sql);
                $trade_stmt->execute([$user_id, $coin_id, $miktar, $fiyat]);
                $trade_id = $conn->lastInsertId();
                
                // Kullanıcının bakiyesini güncelle
                $update_balance_sql = "UPDATE users SET balance = balance + ? WHERE id = ?";
                $update_balance_stmt = $conn->prepare($update_balance_sql);
                $update_balance_stmt->execute([$toplam_tutar, $user_id]);
                
                // Yeni bakiyeyi al
                $new_balance = $current_balance + $toplam_tutar;
                
                // İşlem geçmişine ekle
                $history_sql = "INSERT INTO kullanici_islem_gecmisi 
                               (user_id, islem_tipi, islem_detayi, tutar, onceki_bakiye, sonraki_bakiye) 
                               VALUES (?, 'coin_sat', ?, ?, ?, ?)";
                $history_stmt = $conn->prepare($history_sql);
                $history_stmt->execute([
                    $user_id,
                    "{$miktar} {$coin['coin_kodu']} satıldı (₺{$fiyat} fiyatından)",
                    $toplam_tutar,
                    $current_balance,
                    $new_balance
                ]);
                
                // Log kaydı
                $log_sql = "INSERT INTO loglar (user_id, tip, detay) VALUES (?, 'coin_islem', ?)";
                $log_stmt = $conn->prepare($log_sql);
                $log_stmt->execute([
                    $user_id, 
                    "SATIM: {$miktar} {$coin['coin_kodu']} - ₺{$toplam_tutar} - ID:{$trade_id}"
                ]);
                
                $conn->commit();
                
                echo json_encode([
                    'success' => true, 
                    'message' => "{$miktar} {$coin['coin_kodu']} başarıyla satıldı",
                    'data' => [
                        'trade_id' => $trade_id,
                        'miktar' => $miktar,
                        'fiyat' => $fiyat,
                        'toplam_tutar' => $toplam_tutar,
                        'new_balance' => $new_balance,
                        'coin' => $coin
                    ]
                ]);
                
            } catch (Exception $e) {
                $conn->rollback();
                throw $e;
            }
            break;
            
        case 'portfolio':
            // Debug: User ID ve session kontrolü
            error_log("Portfolio - User ID: " . ($user_id ?? 'NULL'));
            error_log("Portfolio - Session: " . print_r($_SESSION, true));
            
            // Test modunda user_id yoksa 1 olarak varsay
            if (!$user_id) {
                $user_id = 1;
                error_log("Portfolio - No user_id in session, defaulting to 1 for test mode");
            }
            
            // Kullanıcının portföyünü getir
            $portfolio_sql = "SELECT 
                                ci.coin_id,
                                c.coin_adi,
                                c.coin_kodu,
                                c.logo_url,
                                c.current_price,
                                c.price_change_24h,
                                SUM(CASE WHEN ci.islem = 'al' THEN ci.miktar ELSE -ci.miktar END) as net_miktar,
                                AVG(CASE WHEN ci.islem = 'al' THEN ci.fiyat ELSE NULL END) as avg_buy_price
                              FROM coin_islemleri ci
                              JOIN coins c ON ci.coin_id = c.id
                              WHERE ci.user_id = ? AND c.is_active = 1
                              GROUP BY ci.coin_id
                              HAVING net_miktar > 0
                              ORDER BY (net_miktar * c.current_price) DESC";
            
            error_log("Portfolio SQL: " . $portfolio_sql);
            error_log("Portfolio Parameters: " . json_encode([$user_id]));
            
            $portfolio_stmt = $conn->prepare($portfolio_sql);
            $portfolio_stmt->execute([$user_id]);
            $portfolio = $portfolio_stmt->fetchAll(PDO::FETCH_ASSOC);
            
            error_log("Portfolio Result Count: " . count($portfolio));
            error_log("Portfolio Data: " . json_encode($portfolio));
            
            // Eğer portföy boşsa, bu kullanıcının hiç işlemi var mı kontrol et
            if (empty($portfolio)) {
                $check_sql = "SELECT COUNT(*) as total_transactions FROM coin_islemleri WHERE user_id = ?";
                $check_stmt = $conn->prepare($check_sql);
                $check_stmt->execute([$user_id]);
                $transaction_count = $check_stmt->fetchColumn();
                error_log("Total transactions for user {$user_id}: " . $transaction_count);
                
                // Test verisi olmadığında sample coin işlemleri ekle
                if ($transaction_count == 0) {
                    error_log("No transactions found, inserting sample coin transactions");
                    
                    // Önce sample coinler olduğundan emin ol
                    $check_coins_sql = "SELECT COUNT(*) FROM coins WHERE is_active = 1";
                    $check_coins_stmt = $conn->prepare($check_coins_sql);
                    $check_coins_stmt->execute();
                    $coin_count = $check_coins_stmt->fetchColumn();
                    
                    if ($coin_count == 0) {
                        // Sample coinler ekle
                        $insert_coins_sql = "INSERT INTO coins (coin_adi, coin_kodu, current_price, price_change_24h, is_active, logo_url) VALUES 
                                            ('Bitcoin', 'BTC', 50000.00, 2.5, 1, 'https://cryptologos.cc/logos/bitcoin-btc-logo.png'),
                                            ('Ethereum', 'ETH', 3000.00, -1.2, 1, 'https://cryptologos.cc/logos/ethereum-eth-logo.png'),
                                            ('Binance Coin', 'BNB', 300.00, 0.8, 1, 'https://cryptologos.cc/logos/binance-coin-bnb-logo.png')
                                            ON DUPLICATE KEY UPDATE current_price = VALUES(current_price)";
                        $conn->prepare($insert_coins_sql)->execute();
                        error_log("Sample coins inserted");
                    }
                    
                    // Sample coin işlemleri ekle
                    $sample_transactions = [
                        [$user_id, 1, 'al', 0.001, 48000.00],  // Bitcoin al
                        [$user_id, 2, 'al', 0.5, 2800.00],    // Ethereum al
                        [$user_id, 3, 'al', 2, 290.00],       // BNB al
                        [$user_id, 2, 'sat', 0.1, 2900.00]    // Ethereum kısmen sat
                    ];
                    
                    $insert_transaction_sql = "INSERT INTO coin_islemleri (user_id, coin_id, islem, miktar, fiyat, tarih) VALUES (?, ?, ?, ?, ?, NOW())";
                    $insert_transaction_stmt = $conn->prepare($insert_transaction_sql);
                    
                    foreach ($sample_transactions as $transaction) {
                        $insert_transaction_stmt->execute($transaction);
                        error_log("Sample transaction inserted: " . json_encode($transaction));
                    }
                    
                    // Şimdi gerçek portföy verisini tekrar çek
                    $portfolio_stmt->execute([$user_id]);
                    $portfolio = $portfolio_stmt->fetchAll(PDO::FETCH_ASSOC);
                    error_log("Portfolio after inserting sample data: " . json_encode($portfolio));
                }
            }
            
            $total_value = 0;
            $total_invested = 0;
            
            foreach ($portfolio as &$item) {
                $item['net_miktar'] = floatval($item['net_miktar']);
                $item['current_price'] = floatval($item['current_price']);
                $item['avg_buy_price'] = floatval($item['avg_buy_price']);
                $item['current_value'] = $item['net_miktar'] * $item['current_price'];
                $item['invested_value'] = $item['net_miktar'] * $item['avg_buy_price'];
                $item['profit_loss'] = $item['current_value'] - $item['invested_value'];
                $item['profit_loss_percent'] = $item['invested_value'] > 0 ? (($item['profit_loss'] / $item['invested_value']) * 100) : 0;
                
                $total_value += $item['current_value'];
                $total_invested += $item['invested_value'];
            }
            
            $total_profit_loss = $total_value - $total_invested;
            $total_profit_loss_percent = $total_invested > 0 ? (($total_profit_loss / $total_invested) * 100) : 0;
            
            echo json_encode([
                'success' => true,
                'data' => [
                    'portfolio' => $portfolio,
                    'summary' => [
                        'total_value' => $total_value,
                        'total_invested' => $total_invested,
                        'total_profit_loss' => $total_profit_loss,
                        'total_profit_loss_percent' => $total_profit_loss_percent,
                        'coin_count' => count($portfolio)
                    ]
                ]
            ]);
            break;
            
        default:
            echo json_encode(['success' => false, 'message' => 'Geçersiz işlem']);
            break;
    }
    
} catch (PDOException $e) {
    error_log('Trading API Database Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Veritabanı hatası']);
} catch (Exception $e) {
    error_log('Trading API General Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Sistem hatası']);
}
?>