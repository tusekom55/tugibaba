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

// Hibrit coin sistemi - DB'den coin listesi + API'den fiyat
function getHybridCoins($limit = 50, $search = '') {
    try {
        $conn = db_connect();
        
        // Coins tablosunun var olup olmadığını kontrol et
        $table_check = $conn->prepare("SHOW TABLES LIKE 'coins'");
        $table_check->execute();
        
        if ($table_check->rowCount() == 0) {
            // Coins tablosu yoksa mock data döndür
            return getMockCoinsData($limit, $search);
        }
        
        // Veritabanından aktif coinleri çek
        $sql = '
            SELECT 
                c.id,
                c.coingecko_id,
                c.coin_adi,
                c.coin_kodu,
                c.logo_url,
                c.current_price,
                c.price_change_24h,
                c.market_cap,
                c.api_aktif,
                c.sira,
                COALESCE(ck.kategori_adi, "Diğer") as kategori_adi
            FROM coins c
            LEFT JOIN coin_kategorileri ck ON c.kategori_id = ck.id
            WHERE c.is_active = 1
        ';
        
        $params = [];
        
        // Arama filtresi
        if (!empty($search)) {
            $sql .= ' AND (c.coin_adi LIKE ? OR c.coin_kodu LIKE ?)';
            $search_param = '%' . $search . '%';
            $params[] = $search_param;
            $params[] = $search_param;
        }
        
        $sql .= ' ORDER BY c.sira ASC, c.id ASC LIMIT ?';
        $params[] = $limit;
        
        $stmt = $conn->prepare($sql);
        $stmt->execute($params);
        $coins = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $api_aktif_coins = []; // API'den fiyat çekilecek coinler
        
        foreach ($coins as $coin) {
            // API aktifse coin ID'sini sakla
            if ($coin['api_aktif'] && $coin['coingecko_id']) {
                $api_aktif_coins[] = $coin['coingecko_id'];
            }
        }
        
        // API aktif coinler varsa fiyatları güncelle
        if (!empty($api_aktif_coins)) {
            $api_prices = fetchPricesFromAPI($api_aktif_coins);
            
            // Fiyatları coinlerle eşleştir
            foreach ($coins as $index => $coin) {
                if ($coin['api_aktif'] && isset($api_prices[$coin['coingecko_id']])) {
                    $api_data = $api_prices[$coin['coingecko_id']];
                    $coins[$index]['current_price'] = $api_data['current_price'];
                    $coins[$index]['price_change_24h'] = $api_data['price_change_percentage_24h'];
                    $coins[$index]['market_cap'] = $api_data['market_cap'];
                    $coins[$index]['last_updated'] = date('Y-m-d H:i:s');
                    $coins[$index]['price_source'] = 'api';
                } else {
                    $coins[$index]['price_source'] = 'database';
                }
            }
        } else {
            // Tüm fiyatlar veritabanından
            foreach ($coins as $index => $coin) {
                $coins[$index]['price_source'] = 'database';
            }
        }
        
        return [
            'success' => true,
            'coins' => $coins,
            'total_count' => count($coins),
            'api_active_count' => count($api_aktif_coins),
            'message' => 'Coin listesi başarıyla yüklendi'
        ];
        
    } catch (PDOException $e) {
        error_log('Database error in getHybridCoins: ' . $e->getMessage());
        return [
            'success' => false,
            'message' => 'Veritabanı hatası: ' . $e->getMessage()
        ];
    } catch (Exception $e) {
        error_log('General error in getHybridCoins: ' . $e->getMessage());
        return [
            'success' => false,
            'message' => 'Sistem hatası: ' . $e->getMessage()
        ];
    }
}

// Mock data fonksiyonu (coins tablosu yoksa)
function getMockCoinsData($limit = 50, $search = '') {
    $mock_coins = [
        [
            'id' => 1,
            'coingecko_id' => 'bitcoin',
            'coin_adi' => 'Bitcoin',
            'coin_kodu' => 'BTC',
            'logo_url' => 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
            'current_price' => 96480.50,
            'price_change_24h' => 2.35,
            'market_cap' => 1900000000000,
            'api_aktif' => true,
            'sira' => 1,
            'kategori_adi' => 'Kripto Para',
            'price_source' => 'mock'
        ],
        [
            'id' => 2,
            'coingecko_id' => 'ethereum',
            'coin_adi' => 'Ethereum',
            'coin_kodu' => 'ETH',
            'logo_url' => 'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
            'current_price' => 3420.75,
            'price_change_24h' => -1.22,
            'market_cap' => 410000000000,
            'api_aktif' => true,
            'sira' => 2,
            'kategori_adi' => 'Kripto Para',
            'price_source' => 'mock'
        ],
        [
            'id' => 3,
            'coingecko_id' => 'binancecoin',
            'coin_adi' => 'BNB',
            'coin_kodu' => 'BNB',
            'logo_url' => 'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png',
            'current_price' => 685.20,
            'price_change_24h' => 0.88,
            'market_cap' => 99000000000,
            'api_aktif' => true,
            'sira' => 3,
            'kategori_adi' => 'Kripto Para',
            'price_source' => 'mock'
        ],
        [
            'id' => 4,
            'coingecko_id' => 'solana',
            'coin_adi' => 'Solana',
            'coin_kodu' => 'SOL',
            'logo_url' => 'https://assets.coingecko.com/coins/images/4128/large/solana.png',
            'current_price' => 238.45,
            'price_change_24h' => 4.65,
            'market_cap' => 113000000000,
            'api_aktif' => true,
            'sira' => 4,
            'kategori_adi' => 'Kripto Para',
            'price_source' => 'mock'
        ],
        [
            'id' => 5,
            'coingecko_id' => 'ripple',
            'coin_adi' => 'XRP',
            'coin_kodu' => 'XRP',
            'logo_url' => 'https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png',
            'current_price' => 2.35,
            'price_change_24h' => 12.88,
            'market_cap' => 133000000000,
            'api_aktif' => true,
            'sira' => 5,
            'kategori_adi' => 'Kripto Para',
            'price_source' => 'mock'
        ]
    ];
    
    // Arama filtresi uygula
    if (!empty($search)) {
        $mock_coins = array_filter($mock_coins, function($coin) use ($search) {
            return stripos($coin['coin_adi'], $search) !== false || 
                   stripos($coin['coin_kodu'], $search) !== false;
        });
    }
    
    // Limit uygula
    $mock_coins = array_slice($mock_coins, 0, $limit);
    
    return [
        'success' => true,
        'coins' => $mock_coins,
        'total_count' => count($mock_coins),
        'api_active_count' => count(array_filter($mock_coins, function($coin) { return $coin['api_aktif']; })),
        'message' => 'Mock coin listesi yüklendi (database bağlantısı yok)'
    ];
}

// CoinGecko API'den fiyat çek
function fetchPricesFromAPI($coingecko_ids) {
    if (empty($coingecko_ids)) {
        return [];
    }
    
    try {
        $ids_string = implode(',', $coingecko_ids);
        $url = "https://api.coingecko.com/api/v3/simple/price?ids={$ids_string}&vs_currencies=usd&include_market_cap=true&include_24hr_change=true";
        
        // cURL kullanarak daha güvenilir API çağrısı
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 15);
        curl_setopt($ch, CURLOPT_USERAGENT, 'TradePro/1.0 (PHP)');
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Accept: application/json'
        ]);
        
        $response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curl_error = curl_error($ch);
        curl_close($ch);
        
        if ($response === FALSE || !empty($curl_error)) {
            error_log('CoinGecko API cURL hatası: ' . $curl_error);
            return [];
        }
        
        if ($http_code !== 200) {
            error_log('CoinGecko API HTTP hatası: ' . $http_code);
            return [];
        }
        
        $data = json_decode($response, true);
        
        if (!$data) {
            error_log('CoinGecko API geçersiz yanıt');
            return [];
        }
        
        // Veriyi düzenle
        $formatted_data = [];
        foreach ($data as $coin_id => $price_data) {
            $formatted_data[$coin_id] = [
                'current_price' => $price_data['usd'] ?? 0,
                'price_change_percentage_24h' => $price_data['usd_24h_change'] ?? 0,
                'market_cap' => $price_data['usd_market_cap'] ?? 0
            ];
        }
        
        return $formatted_data;
        
    } catch (Exception $e) {
        error_log('API fiyat çekme hatası: ' . $e->getMessage());
        return [];
    }
}

// API endpoint
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 50;
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    
    $limit = max(1, min(100, $limit)); // 1-100 arası sınırla
    
    $result = getHybridCoins($limit, $search);
    echo json_encode($result);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Sadece GET istekleri desteklenir'
    ]);
}
?> 