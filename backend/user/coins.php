<?php
// Session yönetimi - çakışma önleme
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
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

try {
    $conn = db_connect();
    
    // Coins tablosunun var olup olmadığını kontrol et
    $table_check = $conn->prepare("SHOW TABLES LIKE 'coins'");
    $table_check->execute();
    
    if ($table_check->rowCount() == 0) {
        // Mock data döndür
        echo json_encode([
            'success' => true, 
            'coins' => [
                ['id' => 1, 'coin_adi' => 'Bitcoin', 'coin_kodu' => 'BTC', 'current_price' => 1350000, 'kategori_adi' => 'Kripto Para'],
                ['id' => 2, 'coin_adi' => 'Ethereum', 'coin_kodu' => 'ETH', 'current_price' => 85000, 'kategori_adi' => 'Kripto Para'],
                ['id' => 3, 'coin_adi' => 'BNB', 'coin_kodu' => 'BNB', 'current_price' => 12500, 'kategori_adi' => 'Kripto Para']
            ]
        ]);
        exit;
    }
    
    $sql = 'SELECT coins.id, coins.coin_adi, coins.coin_kodu, coins.current_price, COALESCE(coin_kategorileri.kategori_adi, "Diğer") as kategori_adi FROM coins LEFT JOIN coin_kategorileri ON coins.kategori_id = coin_kategorileri.id WHERE coins.is_active = 1 ORDER BY coins.sira ASC, coins.id ASC';
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $coins = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode(['success' => true, 'coins' => $coins]);
    
} catch (PDOException $e) {
    error_log('Database error in coins.php: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Veritabanı hatası']);
} catch (Exception $e) {
    error_log('General error in coins.php: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Sistem hatası']);
} 