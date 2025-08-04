-- ✅ MySQL Uyumlu Portfolio Sorgusu (Hata Düzeltildi)

-- Kullanıcı ID 1 için portföy hesaplama
SELECT 
    ci.coin_id,
    c.coin_adi,
    c.coin_kodu,
    c.logo_url,
    c.current_price,
    c.price_change_24h,
    SUM(CASE WHEN ci.islem = 'al' THEN ci.miktar ELSE -ci.miktar END) as net_miktar,
    AVG(CASE WHEN ci.islem = 'al' THEN ci.fiyat ELSE NULL END) as avg_buy_price,
    (SUM(CASE WHEN ci.islem = 'al' THEN ci.miktar ELSE -ci.miktar END) * c.current_price) as current_value,
    (SUM(CASE WHEN ci.islem = 'al' THEN ci.miktar ELSE -ci.miktar END) * AVG(CASE WHEN ci.islem = 'al' THEN ci.fiyat ELSE NULL END)) as invested_value,
    ((SUM(CASE WHEN ci.islem = 'al' THEN ci.miktar ELSE -ci.miktar END) * c.current_price) - 
     (SUM(CASE WHEN ci.islem = 'al' THEN ci.miktar ELSE -ci.miktar END) * AVG(CASE WHEN ci.islem = 'al' THEN ci.fiyat ELSE NULL END))) as profit_loss
FROM coin_islemleri ci
JOIN coins c ON ci.coin_id = c.id
WHERE ci.user_id = 1 AND c.is_active = 1
GROUP BY ci.coin_id, c.coin_adi, c.coin_kodu, c.logo_url, c.current_price, c.price_change_24h
HAVING SUM(CASE WHEN ci.islem = 'al' THEN ci.miktar ELSE -ci.miktar END) > 0
ORDER BY (SUM(CASE WHEN ci.islem = 'al' THEN ci.miktar ELSE -ci.miktar END) * c.current_price) DESC;

-- ℹ️ Hata Çözümü:
-- ❌ HAVING net_miktar > 0  (MySQL bazı sürümlerinde desteklenmiyor)
-- ✅ HAVING SUM(CASE...) > 0  (Tam hesaplama ile çalışır)

-- 📊 Bu sorgu şunları döndürür:
-- - net_miktar: Kullanıcının sahip olduğu coin miktarı
-- - avg_buy_price: Ortalama alış fiyatı  
-- - current_value: Güncel değer
-- - invested_value: Yatırılan toplam para
-- - profit_loss: Kar/zarar miktarı