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
    die(json_encode(['error' => 'Config dosyası bulunamadı']));
}

// Test modu - session kontrolü olmadan
// if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
//     http_response_code(403);
//     echo json_encode(['error' => 'Yetkisiz erişim']);
//     exit;
// }

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$action = $_GET['action'] ?? '';

try {
    $conn = db_connect();
    
    switch ($action) {
        case 'list':
            // Aktif pozisyonları listele
            $positions_sql = "SELECT 
                                lp.id,
                                lp.user_id,
                                u.username,
                                lp.coin_id,
                                c.coin_kodu as coin_symbol,
                                lp.position_type,
                                lp.leverage_ratio,
                                lp.entry_price,
                                lp.invested_amount,
                                lp.unrealized_pnl,
                                lp.pnl_percentage,
                                lp.status,
                                lp.open_time,
                                c.current_price
                              FROM leverage_positions lp
                              JOIN users u ON lp.user_id = u.id
                              JOIN coins c ON lp.coin_id = c.id
                              WHERE lp.status = 'open'
                              ORDER BY lp.open_time DESC";
            
            $positions_stmt = $conn->prepare($positions_sql);
            $positions_stmt->execute();
            $positions = $positions_stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Her pozisyon için güncel fiyat ve PnL hesapla
            foreach ($positions as &$position) {
                $current_price = floatval($position['current_price']);
                $entry_price = floatval($position['entry_price']);
                $invested_amount = floatval($position['invested_amount']);
                $leverage = floatval($position['leverage_ratio']);
                
                // PnL hesaplama
                $price_change_percent = (($current_price - $entry_price) / $entry_price) * 100;
                
                if ($position['position_type'] === 'short') {
                    $price_change_percent = -$price_change_percent;
                }
                
                $pnl_percent = $price_change_percent * $leverage;
                $unrealized_pnl = $invested_amount * ($pnl_percent / 100);
                
                $position['current_price'] = $current_price;
                $position['unrealized_pnl'] = $unrealized_pnl;
                $position['pnl_percentage'] = $pnl_percent;
            }
            
            echo json_encode(['success' => true, 'data' => $positions]);
            break;
            
        case 'intervene':
            // Pozisyona müdahale et
            $position_id = intval($_POST['position_id'] ?? 0);
            $intervention_type = $_POST['intervention_type'] ?? '';
            $profit_multiplier = floatval($_POST['profit_multiplier'] ?? 0);
            $target_price = floatval($_POST['target_price'] ?? 0);
            
            if ($position_id <= 0) {
                echo json_encode(['error' => 'Geçersiz pozisyon ID']);
                exit;
            }
            
            // Pozisyon bilgilerini al
            $position_sql = "SELECT * FROM leverage_positions WHERE id = ? AND status = 'open'";
            $position_stmt = $conn->prepare($position_sql);
            $position_stmt->execute([$position_id]);
            $position = $position_stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$position) {
                echo json_encode(['error' => 'Pozisyon bulunamadı']);
                exit;
            }
            
            $conn->beginTransaction();
            
            try {
                switch ($intervention_type) {
                    case 'profit_boost':
                        // Kar artırma - pozisyonun PnL'ini manipüle et
                        $invested_amount = floatval($position['invested_amount']);
                        $target_pnl = $invested_amount * ($profit_multiplier / 100);
                        
                        // Pozisyonu güncelle
                        $update_sql = "UPDATE leverage_positions 
                                      SET unrealized_pnl = ?, 
                                          pnl_percentage = ?,
                                          admin_intervention = 1,
                                          intervention_type = 'profit_boost',
                                          intervention_details = ?
                                      WHERE id = ?";
                        
                        $intervention_details = json_encode([
                            'original_pnl' => $position['unrealized_pnl'],
                            'boosted_pnl' => $target_pnl,
                            'profit_multiplier' => $profit_multiplier,
                            'admin_id' => $_SESSION['user_id'] ?? 1,
                            'timestamp' => date('Y-m-d H:i:s')
                        ]);
                        
                        $update_stmt = $conn->prepare($update_sql);
                        $update_stmt->execute([$target_pnl, $profit_multiplier, $intervention_details, $position_id]);
                        break;
                        
                    case 'loss_reduce':
                        // Zarar azaltma
                        $current_pnl = floatval($position['unrealized_pnl']);
                        $reduced_pnl = $current_pnl * 0.5; // %50 zarar azalt
                        
                        $update_sql = "UPDATE leverage_positions 
                                      SET unrealized_pnl = ?, 
                                          admin_intervention = 1,
                                          intervention_type = 'loss_reduce',
                                          intervention_details = ?
                                      WHERE id = ?";
                        
                        $intervention_details = json_encode([
                            'original_pnl' => $current_pnl,
                            'reduced_pnl' => $reduced_pnl,
                            'admin_id' => $_SESSION['user_id'] ?? 1,
                            'timestamp' => date('Y-m-d H:i:s')
                        ]);
                        
                        $update_stmt = $conn->prepare($update_sql);
                        $update_stmt->execute([$reduced_pnl, $intervention_details, $position_id]);
                        break;
                        
                    case 'force_close':
                        // Zorla kapama
                        $invested_amount = floatval($position['invested_amount']);
                        $target_pnl = $invested_amount * ($profit_multiplier / 100);
                        $final_balance = $invested_amount + $target_pnl;
                        
                        // Pozisyonu kapat
                        $close_sql = "UPDATE leverage_positions 
                                     SET status = 'closed',
                                         close_price = ?,
                                         close_time = NOW(),
                                         realized_pnl = ?,
                                         admin_intervention = 1,
                                         intervention_type = 'force_close',
                                         intervention_details = ?
                                     WHERE id = ?";
                        
                        $intervention_details = json_encode([
                            'forced_close_price' => $target_price,
                            'forced_pnl' => $target_pnl,
                            'profit_multiplier' => $profit_multiplier,
                            'admin_id' => $_SESSION['user_id'] ?? 1,
                            'timestamp' => date('Y-m-d H:i:s')
                        ]);
                        
                        $close_stmt = $conn->prepare($close_sql);
                        $close_stmt->execute([$target_price, $target_pnl, $intervention_details, $position_id]);
                        
                        // Kullanıcı bakiyesini güncelle
                        $balance_sql = "UPDATE users SET balance = balance + ? WHERE id = ?";
                        $balance_stmt = $conn->prepare($balance_sql);
                        $balance_stmt->execute([$final_balance, $position['user_id']]);
                        break;
                }
                
                // Admin log kaydı
                $log_sql = "INSERT INTO admin_islem_loglari 
                           (admin_id, islem_tipi, hedef_id, islem_detayi) 
                           VALUES (?, 'leverage_intervention', ?, ?)";
                $log_stmt = $conn->prepare($log_sql);
                $log_stmt->execute([
                    $_SESSION['user_id'] ?? 1,
                    $position_id,
                    "Pozisyon müdahalesi: {$intervention_type} - Pozisyon ID: {$position_id}"
                ]);
                
                $conn->commit();
                echo json_encode(['success' => true, 'message' => 'Müdahale başarıyla uygulandı']);
                
            } catch (Exception $e) {
                $conn->rollback();
                echo json_encode(['error' => 'Müdahale uygulanamadı: ' . $e->getMessage()]);
            }
            break;
            
        case 'force_close':
            // Tek pozisyonu zorla kapat
            $position_id = intval($_POST['position_id'] ?? 0);
            
            if ($position_id <= 0) {
                echo json_encode(['error' => 'Geçersiz pozisyon ID']);
                exit;
            }
            
            // Pozisyon bilgilerini al
            $position_sql = "SELECT * FROM leverage_positions WHERE id = ? AND status = 'open'";
            $position_stmt = $conn->prepare($position_sql);
            $position_stmt->execute([$position_id]);
            $position = $position_stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$position) {
                echo json_encode(['error' => 'Pozisyon bulunamadı']);
                exit;
            }
            
            $conn->beginTransaction();
            
            try {
                // Pozisyonu kapat (mevcut PnL ile)
                $close_sql = "UPDATE leverage_positions 
                             SET status = 'closed',
                                 close_time = NOW(),
                                 realized_pnl = unrealized_pnl,
                                 admin_intervention = 1,
                                 intervention_type = 'admin_close'
                             WHERE id = ?";
                $close_stmt = $conn->prepare($close_sql);
                $close_stmt->execute([$position_id]);
                
                // Kullanıcı bakiyesini güncelle
                $final_amount = floatval($position['invested_amount']) + floatval($position['unrealized_pnl']);
                $balance_sql = "UPDATE users SET balance = balance + ? WHERE id = ?";
                $balance_stmt = $conn->prepare($balance_sql);
                $balance_stmt->execute([$final_amount, $position['user_id']]);
                
                $conn->commit();
                echo json_encode(['success' => true, 'message' => 'Pozisyon başarıyla kapatıldı']);
                
            } catch (Exception $e) {
                $conn->rollback();
                echo json_encode(['error' => 'Pozisyon kapatılamadı: ' . $e->getMessage()]);
            }
            break;
            
        case 'close_all':
            // Tüm pozisyonları kapat
            $positions_sql = "SELECT * FROM leverage_positions WHERE status = 'open'";
            $positions_stmt = $conn->prepare($positions_sql);
            $positions_stmt->execute();
            $positions = $positions_stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $closed_count = 0;
            $conn->beginTransaction();
            
            try {
                foreach ($positions as $position) {
                    // Pozisyonu kapat
                    $close_sql = "UPDATE leverage_positions 
                                 SET status = 'closed',
                                     close_time = NOW(),
                                     realized_pnl = unrealized_pnl,
                                     admin_intervention = 1,
                                     intervention_type = 'admin_close_all'
                                 WHERE id = ?";
                    $close_stmt = $conn->prepare($close_sql);
                    $close_stmt->execute([$position['id']]);
                    
                    // Kullanıcı bakiyesini güncelle
                    $final_amount = floatval($position['invested_amount']) + floatval($position['unrealized_pnl']);
                    $balance_sql = "UPDATE users SET balance = balance + ? WHERE id = ?";
                    $balance_stmt = $conn->prepare($balance_sql);
                    $balance_stmt->execute([$final_amount, $position['user_id']]);
                    
                    $closed_count++;
                }
                
                $conn->commit();
                echo json_encode(['success' => true, 'message' => 'Tüm pozisyonlar kapatıldı', 'closed_count' => $closed_count]);
                
            } catch (Exception $e) {
                $conn->rollback();
                echo json_encode(['error' => 'Pozisyonlar kapatılamadı: ' . $e->getMessage()]);
            }
            break;
            
        default:
            echo json_encode(['error' => 'Geçersiz işlem']);
            break;
    }
    
} catch (PDOException $e) {
    error_log('Leverage Control Database Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Veritabanı hatası']);
} catch (Exception $e) {
    error_log('Leverage Control General Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Sistem hatası']);
}
?>