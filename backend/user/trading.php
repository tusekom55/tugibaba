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
            
            $portfolio_stmt = $conn->prepare($portfolio_sql);
            $portfolio_stmt->execute([$user_id]);
            $portfolio = $portfolio_stmt->fetchAll(PDO::FETCH_ASSOC);
            
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