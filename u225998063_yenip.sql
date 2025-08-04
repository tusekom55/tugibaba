-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1:3306
-- Üretim Zamanı: 04 Ağu 2025, 17:56:08
-- Sunucu sürümü: 10.11.10-MariaDB-log
-- PHP Sürümü: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `u225998063_yenip`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `admin_islem_loglari`
--

CREATE TABLE `admin_islem_loglari` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `islem_tipi` enum('kullanici_duzenleme','kullanici_silme','para_onaylama','coin_ekleme','coin_duzenleme','coin_silme','ayar_guncelleme') DEFAULT NULL,
  `hedef_id` int(11) DEFAULT NULL,
  `islem_detayi` text DEFAULT NULL,
  `tarih` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `admin_islem_loglari`
--

INSERT INTO `admin_islem_loglari` (`id`, `admin_id`, `islem_tipi`, `hedef_id`, `islem_detayi`, `tarih`) VALUES
(1, 1, 'para_onaylama', 1, 'Para yatırma onaylandı: tttttt - ₺22.00', '2025-07-31 22:21:04'),
(2, 1, 'para_onaylama', 2, 'Para yatırma onaylandı: tttttt - ₺333.00', '2025-07-31 22:23:06'),
(3, 1, 'para_onaylama', 3, 'Para yatırma onaylandı: tttttt - ₺200.00', '2025-07-31 22:32:02'),
(4, 3, 'para_onaylama', 4, 'Para yatırma onaylandı: t - ₺10000.00', '2025-07-31 23:04:48'),
(5, 6, 'para_onaylama', 5, 'Para yatırma onaylandı: t - ₺222.00', '2025-08-01 04:19:17'),
(6, 6, 'para_onaylama', 6, 'Para yatırma onaylandı: tttttt - ₺10000.00', '2025-08-01 20:51:35'),
(7, 6, 'coin_ekleme', 101, 'Yeni coin eklendi: TugayCışn (TGC) - ₺315269', '2025-08-04 17:06:09'),
(8, 6, 'coin_silme', 101, 'Coin silindi: TugayCışn (TGC)', '2025-08-04 17:19:48'),
(9, 6, 'coin_ekleme', 102, 'Yeni coin eklendi: Tugaycoin (T) - ₺5000', '2025-08-04 17:20:02');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `ayarlar`
--

CREATE TABLE `ayarlar` (
  `key` varchar(100) NOT NULL,
  `value` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `ayarlar`
--

INSERT INTO `ayarlar` (`key`, `value`) VALUES
('api_guncelleme_aktif', 'false'),
('api_guncelleme_siklik', '300'),
('leverage_enabled', 'true'),
('leverage_fee', '0.05'),
('liquidation_threshold', '80.0'),
('max_leverage', '10.0'),
('min_leverage', '1.0'),
('varsayilan_fiyat_kaynak', 'manuel');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `coins`
--

CREATE TABLE `coins` (
  `id` int(11) NOT NULL,
  `kategori_id` int(11) DEFAULT NULL,
  `coingecko_id` varchar(100) DEFAULT NULL,
  `coin_adi` varchar(100) DEFAULT NULL,
  `coin_kodu` varchar(20) DEFAULT NULL,
  `logo_url` varchar(500) DEFAULT NULL,
  `aciklama` text DEFAULT NULL,
  `current_price` decimal(16,8) DEFAULT 0.00000000,
  `price_change_24h` decimal(5,2) DEFAULT 0.00,
  `market_cap` bigint(20) DEFAULT 0,
  `api_aktif` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `sira` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `coins`
--

INSERT INTO `coins` (`id`, `kategori_id`, `coingecko_id`, `coin_adi`, `coin_kodu`, `logo_url`, `aciklama`, `current_price`, `price_change_24h`, `market_cap`, `api_aktif`, `is_active`, `sira`, `created_at`, `updated_at`) VALUES
(3, 1, 'ripple', 'XRP', 'XRP', 'https://coin-images.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png?1696501442', NULL, 3.12000000, -1.00, 184590044041, 0, 1, 3, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(4, 6, 'tether', 'Tether', 'USDT', 'https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661', NULL, 0.99980900, 0.00, 163627913394, 0, 1, 4, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(6, 1, 'solana', 'Solana', 'SOL', 'https://coin-images.coingecko.com/coins/images/4128/large/solana.png?1718769756', NULL, 180.45000000, -3.00, 97016689551, 0, 1, 6, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(7, 6, 'usd-coin', 'USDC', 'USDC', 'https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694', NULL, 0.99978800, 0.00, 63943675444, 0, 1, 7, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(8, 2, 'staked-ether', 'Lido Staked Ether', 'STETH', 'https://coin-images.coingecko.com/coins/images/13442/large/steth_logo.png?1696513206', NULL, 3758.01000000, -1.00, 33696787326, 0, 1, 8, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(9, 5, 'dogecoin', 'Dogecoin', 'DOGE', 'https://coin-images.coingecko.com/coins/images/5/large/dogecoin.png?1696501409', NULL, 0.22204200, -4.00, 33339644080, 0, 1, 9, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(10, 2, 'tron', 'TRON', 'TRX', 'https://coin-images.coingecko.com/coins/images/1094/large/tron-logo.png?1696502193', NULL, 0.33711700, 4.00, 31954909426, 0, 1, 10, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(12, 2, 'wrapped-bitcoin', 'Wrapped Bitcoin', 'WBTC', 'https://coin-images.coingecko.com/coins/images/7598/large/wrapped_bitcoin_wbtc.png?1696507857', NULL, 117500.00000000, 0.00, 14893649374, 0, 1, 12, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(13, 2, 'wrapped-steth', 'Wrapped stETH', 'WSTETH', 'https://coin-images.coingecko.com/coins/images/18834/large/wstETH.png?1696518295', NULL, 4518.62000000, -1.00, 14766548944, 0, 1, 13, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(14, 2, 'hyperliquid', 'Hyperliquid', 'HYPE', 'https://coin-images.coingecko.com/coins/images/50882/large/hyperliquid.jpg?1729431300', NULL, 43.66000000, -5.00, 14561748606, 0, 1, 14, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(15, 2, 'sui', 'Sui', 'SUI', 'https://coin-images.coingecko.com/coins/images/26375/large/sui-ocean-square.png?1727791290', NULL, 3.82000000, -5.00, 13197170356, 0, 1, 15, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(16, 2, 'stellar', 'Stellar', 'XLM', 'https://coin-images.coingecko.com/coins/images/100/large/fmpFRHHQ_400x400.jpg?1735231350', NULL, 0.41869100, -1.00, 13050824174, 0, 1, 16, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(17, 2, 'chainlink', 'Chainlink', 'LINK', 'https://coin-images.coingecko.com/coins/images/877/large/chainlink-new-logo.png?1696502009', NULL, 17.77000000, -3.00, 12045465984, 0, 1, 17, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(18, 2, 'wrapped-beacon-eth', 'Wrapped Beacon ETH', 'WBETH', 'https://coin-images.coingecko.com/coins/images/30061/large/wbeth-icon.png?1696528983', NULL, 4041.42000000, -1.00, 11941595115, 0, 1, 18, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(19, 2, 'bitcoin-cash', 'Bitcoin Cash', 'BCH', 'https://coin-images.coingecko.com/coins/images/780/large/bitcoin-cash-circle.png?1696501932', NULL, 566.90000000, -2.00, 11280474897, 0, 1, 19, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(20, 2, 'hedera-hashgraph', 'Hedera', 'HBAR', 'https://coin-images.coingecko.com/coins/images/3688/large/hbar.png?1696504364', NULL, 0.26350200, -3.00, 11164353936, 0, 1, 20, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(21, 2, 'wrapped-eeth', 'Wrapped eETH', 'WEETH', 'https://coin-images.coingecko.com/coins/images/33033/large/weETH.png?1701438396', NULL, 4028.08000000, -1.00, 10682746719, 0, 1, 21, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(22, 1, 'avalanche-2', 'Avalanche', 'AVAX', 'https://coin-images.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png?1696512369', NULL, 24.33000000, -6.00, 10268597694, 0, 1, 22, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(23, 2, 'weth', 'WETH', 'WETH', 'https://coin-images.coingecko.com/coins/images/2518/large/weth.png?1696503332', NULL, 3762.82000000, -1.00, 8490758279, 0, 1, 23, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(24, 2, 'litecoin', 'Litecoin', 'LTC', 'https://coin-images.coingecko.com/coins/images/2/large/litecoin.png?1696501400', NULL, 109.12000000, -1.00, 8302205408, 0, 1, 24, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(25, 2, 'leo-token', 'LEO Token', 'LEO', 'https://coin-images.coingecko.com/coins/images/8418/large/leo-token.png?1696508607', NULL, 8.96000000, 0.00, 8272307344, 0, 1, 25, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(26, 2, 'the-open-network', 'Toncoin', 'TON', 'https://coin-images.coingecko.com/coins/images/17980/large/photo_2024-09-10_17.09.00.jpeg?1725963446', NULL, 3.29000000, 0.00, 7955597841, 0, 1, 26, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(27, 5, 'shiba-inu', 'Shiba Inu', 'SHIB', 'https://coin-images.coingecko.com/coins/images/11939/large/shiba.png?1696511800', NULL, 0.00001310, -4.00, 7716309331, 0, 1, 27, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(28, 2, 'ethena-usde', 'Ethena USDe', 'USDE', 'https://coin-images.coingecko.com/coins/images/33613/large/usde.png?1733810059', NULL, 1.00100000, 0.00, 7660748539, 0, 1, 28, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(29, 2, 'usds', 'USDS', 'USDS', 'https://coin-images.coingecko.com/coins/images/39926/large/usds.webp?1726666683', NULL, 0.99960600, 0.00, 7531634913, 0, 1, 29, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(30, 2, 'binance-bridged-usdt-bnb-smart-chain', 'Binance Bridged USDT (BNB Smart Chain)', 'BSC-USD', 'https://coin-images.coingecko.com/coins/images/35021/large/USDT.png?1707233575', NULL, 0.99968400, 0.00, 6787298650, 0, 1, 30, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(31, 2, 'coinbase-wrapped-btc', 'Coinbase Wrapped BTC', 'CBBTC', 'https://coin-images.coingecko.com/coins/images/40143/large/cbbtc.webp?1726136727', NULL, 117836.00000000, 0.00, 6338652188, 0, 1, 31, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(32, 2, 'whitebit', 'WhiteBIT Coin', 'WBT', 'https://coin-images.coingecko.com/coins/images/27045/large/wbt_token.png?1696526096', NULL, 43.89000000, 0.00, 6325875869, 0, 1, 32, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(33, 3, 'uniswap', 'Uniswap', 'UNI', 'https://coin-images.coingecko.com/coins/images/12504/large/uniswap-logo.png?1720676669', NULL, 10.24000000, -3.00, 6141743131, 0, 1, 33, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(34, 1, 'polkadot', 'Polkadot', 'DOT', 'https://coin-images.coingecko.com/coins/images/12171/large/polkadot.png?1696512008', NULL, 3.90000000, -4.00, 5929941839, 0, 1, 34, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(35, 2, 'monero', 'Monero', 'XMR', 'https://coin-images.coingecko.com/coins/images/69/large/monero_logo.png?1696501460', NULL, 319.02000000, 0.00, 5884020269, 0, 1, 35, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(36, 2, 'bitget-token', 'Bitget Token', 'BGB', 'https://coin-images.coingecko.com/coins/images/11610/large/Bitget_logo.png?1736925727', NULL, 4.49000000, -2.00, 5119855589, 0, 1, 36, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(37, 5, 'pepe', 'Pepe', 'PEPE', 'https://coin-images.coingecko.com/coins/images/29850/large/pepe-token.jpeg?1696528776', NULL, 0.00001151, -6.00, 4839820910, 0, 1, 37, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(38, 2, 'crypto-com-chain', 'Cronos', 'CRO', 'https://coin-images.coingecko.com/coins/images/7310/large/cro_token_logo.png?1696507599', NULL, 0.14346000, 1.00, 4652449932, 0, 1, 38, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(39, 2, 'ethena-staked-usde', 'Ethena Staked USDe', 'SUSDE', 'https://coin-images.coingecko.com/coins/images/33669/large/sUSDe-Symbol-Color.png?1716307680', NULL, 1.19000000, 0.00, 4378253523, 0, 1, 39, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(40, 3, 'aave', 'Aave', 'AAVE', 'https://coin-images.coingecko.com/coins/images/12645/large/aave-token-round.png?1720472354', NULL, 283.29000000, -3.00, 4305485800, 0, 1, 40, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(41, 6, 'dai', 'Dai', 'DAI', 'https://coin-images.coingecko.com/coins/images/9956/large/Badge_Dai.png?1696509996', NULL, 0.99987400, 0.00, 3742301975, 0, 1, 41, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(42, 2, 'bittensor', 'Bittensor', 'TAO', 'https://coin-images.coingecko.com/coins/images/28452/large/ARUsPeNQ_400x400.jpeg?1696527447', NULL, 389.60000000, -4.00, 3705346059, 0, 1, 42, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(43, 2, 'ethena', 'Ethena', 'ENA', 'https://coin-images.coingecko.com/coins/images/36530/large/ethena.png?1711701436', NULL, 0.57069800, -15.00, 3630778381, 0, 1, 43, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(44, 2, 'near', 'NEAR Protocol', 'NEAR', 'https://coin-images.coingecko.com/coins/images/10365/large/near.jpg?1696510367', NULL, 2.73000000, -3.00, 3377300935, 0, 1, 44, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(45, 2, 'ethereum-classic', 'Ethereum Classic', 'ETC', 'https://coin-images.coingecko.com/coins/images/453/large/ethereum-classic-logo.png?1696501717', NULL, 21.84000000, -1.00, 3337691247, 0, 1, 45, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(46, 2, 'pi-network', 'Pi Network', 'PI', 'https://coin-images.coingecko.com/coins/images/54342/large/pi_network.jpg?1739347576', NULL, 0.42929200, -3.00, 3321285704, 0, 1, 46, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(47, 2, 'ondo-finance', 'Ondo', 'ONDO', 'https://coin-images.coingecko.com/coins/images/26580/large/ONDO.png?1696525656', NULL, 0.96118800, -4.00, 3035645037, 0, 1, 47, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(48, 2, 'internet-computer', 'Internet Computer', 'ICP', 'https://coin-images.coingecko.com/coins/images/14495/large/Internet_Computer_logo.png?1696514180', NULL, 5.45000000, -3.00, 2920328663, 0, 1, 48, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(49, 2, 'okb', 'OKB', 'OKB', 'https://coin-images.coingecko.com/coins/images/4463/large/WeChat_Image_20220118095654.png?1696505053', NULL, 48.58000000, 0.00, 2902494707, 0, 1, 49, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(50, 2, 'jito-staked-sol', 'Jito Staked SOL', 'JITOSOL', 'https://coin-images.coingecko.com/coins/images/28046/large/JitoSOL-200.png?1696527060', NULL, 219.84000000, -3.00, 2873941780, 0, 1, 50, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(51, 2, 'mantle', 'Mantle', 'MNT', 'https://coin-images.coingecko.com/coins/images/30980/large/Mantle-Logo-mark.png?1739213200', NULL, 0.75975700, -4.00, 2557186733, 0, 1, 51, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(52, 2, 'kaspa', 'Kaspa', 'KAS', 'https://coin-images.coingecko.com/coins/images/25751/large/kaspa-icon-exchanges.png?1696524837', NULL, 0.09697000, -2.00, 2555719630, 0, 1, 52, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(53, 2, 'aptos', 'Aptos', 'APT', 'https://coin-images.coingecko.com/coins/images/26455/large/aptos_round.png?1696525528', NULL, 4.55000000, -4.00, 2539241272, 0, 1, 53, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(54, 2, 'blackrock-usd-institutional-digital-liquidity-fund', 'BlackRock USD Institutional Digital Liquidity Fund', 'BUIDL', 'https://coin-images.coingecko.com/coins/images/36291/large/blackrock.png?1711013223', NULL, 1.00000000, 0.00, 2414587528, 0, 1, 54, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(55, 2, 'pudgy-penguins', 'Pudgy Penguins', 'PENGU', 'https://coin-images.coingecko.com/coins/images/52622/large/PUDGY_PENGUINS_PENGU_PFP.png?1733809110', NULL, 0.03754371, -8.00, 2359089709, 0, 1, 55, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(56, 2, 'bonk', 'Bonk', 'BONK', 'https://coin-images.coingecko.com/coins/images/28600/large/bonk.jpg?1696527587', NULL, 0.00002993, -12.00, 2314590032, 0, 1, 56, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(57, 2, 'binance-peg-weth', 'Binance-Peg WETH', 'WETH', 'https://coin-images.coingecko.com/coins/images/39580/large/weth.png?1723006716', NULL, 3761.40000000, 0.00, 2275674777, 0, 1, 57, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(58, 2, 'algorand', 'Algorand', 'ALGO', 'https://coin-images.coingecko.com/coins/images/4380/large/download.png?1696504978', NULL, 0.25957600, -3.00, 2254295413, 0, 1, 58, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(59, 2, 'usd1-wlfi', 'USD1', 'USD1', 'https://coin-images.coingecko.com/coins/images/54977/large/USD1_1000x1000_transparent.png?1749297002', NULL, 0.99945600, 0.00, 2211327365, 0, 1, 59, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(60, 2, 'arbitrum', 'Arbitrum', 'ARB', 'https://coin-images.coingecko.com/coins/images/16547/large/arb.jpg?1721358242', NULL, 0.42373900, -5.00, 2181564440, 0, 1, 60, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(61, 2, 'vechain', 'VeChain', 'VET', 'https://coin-images.coingecko.com/coins/images/1167/large/VET.png?1742383283', NULL, 0.02483835, -1.00, 2134985204, 0, 1, 61, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(62, 2, 'cosmos', 'Cosmos Hub', 'ATOM', 'https://coin-images.coingecko.com/coins/images/1481/large/cosmos_hub.png?1696502525', NULL, 4.62000000, -3.00, 2128570137, 0, 1, 62, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(63, 2, 'gatechain-token', 'Gate', 'GT', 'https://coin-images.coingecko.com/coins/images/8183/large/200X200.png?1735246724', NULL, 17.62000000, -2.00, 2104279652, 0, 1, 63, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(64, 2, 'render-token', 'Render', 'RENDER', 'https://coin-images.coingecko.com/coins/images/11636/large/rndr.png?1696511529', NULL, 3.94000000, -5.00, 2041084449, 0, 1, 64, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(65, 2, 'polygon-ecosystem-token', 'POL (ex-MATIC)', 'POL', 'https://coin-images.coingecko.com/coins/images/32440/large/polygon.png?1698233684', NULL, 0.22149000, -3.00, 1999512079, 0, 1, 65, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(66, 2, 'fasttoken', 'Fasttoken', 'FTN', 'https://coin-images.coingecko.com/coins/images/28478/large/lightenicon_200x200.png?1696527472', NULL, 4.59000000, 0.00, 1979185947, 0, 1, 66, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(67, 2, 'worldcoin-wld', 'Worldcoin', 'WLD', 'https://coin-images.coingecko.com/coins/images/31069/large/worldcoin.jpeg?1696529903', NULL, 1.07200000, -6.00, 1944862461, 0, 1, 67, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(68, 2, 'spx6900', 'SPX6900', 'SPX', 'https://coin-images.coingecko.com/coins/images/31401/large/centeredcoin_%281%29.png?1737048493', NULL, 2.06000000, -5.00, 1921419478, 0, 1, 68, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(69, 2, 'official-trump', 'Official Trump', 'TRUMP', 'https://coin-images.coingecko.com/coins/images/53746/large/trump.png?1737171561', NULL, 9.43000000, -5.00, 1885996808, 0, 1, 69, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(70, 2, 'sei-network', 'Sei', 'SEI', 'https://coin-images.coingecko.com/coins/images/28205/large/Sei_Logo_-_Transparent.png?1696527207', NULL, 0.32270800, -1.00, 1865699953, 0, 1, 70, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(71, 2, 'fetch-ai', 'Artificial Superintelligence Alliance', 'FET', 'https://coin-images.coingecko.com/coins/images/5681/large/ASI.png?1719827289', NULL, 0.71387300, -1.00, 1857146799, 0, 1, 71, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(72, 2, 'binance-staked-sol', 'Binance Staked SOL', 'BNSOL', 'https://coin-images.coingecko.com/coins/images/40132/large/bnsol.png?1725968367', NULL, 192.14000000, -3.00, 1799279676, 0, 1, 72, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(73, 2, 'sky', 'Sky', 'SKY', 'https://coin-images.coingecko.com/coins/images/39925/large/sky.jpg?1724827980', NULL, 0.08411300, -9.00, 1787601390, 0, 1, 73, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(74, 2, 'rocket-pool-eth', 'Rocket Pool ETH', 'RETH', 'https://coin-images.coingecko.com/coins/images/20764/large/reth.png?1696520159', NULL, 4278.34000000, -1.00, 1765002227, 0, 1, 74, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(75, 2, 'quant-network', 'Quant', 'QNT', 'https://coin-images.coingecko.com/coins/images/3370/large/5ZOu7brX_400x400.jpg?1696504070', NULL, 120.87000000, -2.00, 1757589574, 0, 1, 75, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(76, 2, 'filecoin', 'Filecoin', 'FIL', 'https://coin-images.coingecko.com/coins/images/12817/large/filecoin.png?1696512609', NULL, 2.57000000, -4.00, 1752472565, 0, 1, 76, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(77, 2, 'story-2', 'Story', 'IP', 'https://coin-images.coingecko.com/coins/images/54035/large/Transparent_bg.png?1738075331', NULL, 5.85000000, 1.00, 1712539848, 0, 1, 77, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(78, 2, 'flare-networks', 'Flare', 'FLR', 'https://coin-images.coingecko.com/coins/images/28624/large/FLR-icon200x200.png?1696527609', NULL, 0.02435660, 0.00, 1699159186, 0, 1, 78, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(79, 2, 'lombard-staked-btc', 'Lombard Staked BTC', 'LBTC', 'https://coin-images.coingecko.com/coins/images/39969/large/LBTC_Logo.png?1724959872', NULL, 117781.00000000, 0.00, 1683939551, 0, 1, 79, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(80, 2, 'kelp-dao-restaked-eth', 'Kelp DAO Restaked ETH', 'RSETH', 'https://coin-images.coingecko.com/coins/images/33800/large/Icon___Dark.png?1702991855', NULL, 3943.98000000, -1.00, 1671096227, 0, 1, 80, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(81, 2, 'susds', 'sUSDS', 'SUSDS', 'https://coin-images.coingecko.com/coins/images/52721/large/sUSDS_Coin.png?1734086971', NULL, 1.06100000, 0.00, 1670872000, 0, 1, 81, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(82, 2, 'jupiter-perpetuals-liquidity-provider-token', 'Jupiter Perpetuals Liquidity Provider Token', 'JLP', 'https://coin-images.coingecko.com/coins/images/33094/large/jlp.png?1700631386', NULL, 5.04000000, -1.00, 1630150933, 0, 1, 82, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(83, 2, 'jupiter-exchange-solana', 'Jupiter', 'JUP', 'https://coin-images.coingecko.com/coins/images/34188/large/jup.png?1704266489', NULL, 0.53928000, -6.00, 1617189693, 0, 1, 83, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(84, 2, 'xdce-crowd-sale', 'XDC Network', 'XDC', 'https://coin-images.coingecko.com/coins/images/2912/large/xdc-icon.png?1696503661', NULL, 0.09587700, 5.00, 1555460537, 0, 1, 84, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(85, 2, 'kucoin-shares', 'KuCoin', 'KCS', 'https://coin-images.coingecko.com/coins/images/1047/large/sa9z79.png?1696502152', NULL, 11.37000000, 0.00, 1449127316, 0, 1, 85, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(86, 2, 'usdtb', 'USDtb', 'USDTB', 'https://coin-images.coingecko.com/coins/images/52804/large/USDtbSmall.png?1734344946', NULL, 0.99983300, 0.00, 1445211291, 0, 1, 86, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(87, 2, 'stakewise-v3-oseth', 'StakeWise Staked ETH', 'OSETH', 'https://coin-images.coingecko.com/coins/images/33117/large/Frame_27513839.png?1700732599', NULL, 3956.38000000, 0.00, 1419866787, 0, 1, 87, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(88, 2, 'mantle-staked-ether', 'Mantle Staked Ether', 'METH', 'https://coin-images.coingecko.com/coins/images/33345/large/symbol_transparent_bg.png?1701697066', NULL, 4024.25000000, -1.00, 1388107009, 0, 1, 88, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(89, 2, 'injective-protocol', 'Injective', 'INJ', 'https://coin-images.coingecko.com/coins/images/12882/large/Other_200x200.png?1738782212', NULL, 14.18000000, -5.00, 1385150670, 0, 1, 89, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(90, 2, 'liquid-staked-ethereum', 'Liquid Staked ETH', 'LSETH', 'https://coin-images.coingecko.com/coins/images/28848/large/LsETH-receipt-token-circle.png?1696527824', NULL, 4065.75000000, -1.00, 1370274283, 0, 1, 90, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(91, 2, 'celestia', 'Celestia', 'TIA', 'https://coin-images.coingecko.com/coins/images/31967/large/tia.jpg?1696530772', NULL, 1.88000000, -4.00, 1365498063, 0, 1, 91, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(92, 2, 'usdt0', 'USDT0', 'USDT0', 'https://coin-images.coingecko.com/coins/images/53705/large/usdt0.jpg?1737086183', NULL, 0.99979200, 0.00, 1363264328, 0, 1, 92, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(93, 3, 'curve-dao-token', 'Curve DAO', 'CRV', 'https://coin-images.coingecko.com/coins/images/12124/large/Curve.png?1696511967', NULL, 0.98700100, 0.00, 1361378840, 0, 1, 93, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(94, 2, 'first-digital-usd', 'First Digital USD', 'FDUSD', 'https://coin-images.coingecko.com/coins/images/31079/large/FDUSD_icon_black.png?1731097953', NULL, 1.00100000, 0.00, 1343212458, 0, 1, 94, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(95, 2, 'nexo', 'NEXO', 'NEXO', 'https://coin-images.coingecko.com/coins/images/3695/large/CG-nexo-token-200x200_2x.png?1730414360', NULL, 1.31000000, 0.00, 1312413872, 0, 1, 95, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(96, 2, 'optimism', 'Optimism', 'OP', 'https://coin-images.coingecko.com/coins/images/25244/large/Optimism.png?1696524385', NULL, 0.72417800, -8.00, 1269393140, 0, 1, 96, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(97, 2, 'renzo-restaked-eth', 'Renzo Restaked ETH', 'EZETH', 'https://coin-images.coingecko.com/coins/images/34753/large/Ezeth_logo_circle.png?1713496404', NULL, 3958.08000000, -1.00, 1245135487, 0, 1, 97, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(98, 6, 'polygon-bridged-usdt-polygon', 'Polygon Bridged USDT (Polygon)', 'USDT', 'https://coin-images.coingecko.com/coins/images/35023/large/USDT.png?1707233644', NULL, 0.99955500, 0.00, 1226310437, 0, 1, 98, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(99, 2, 'blockstack', 'Stacks', 'STX', 'https://coin-images.coingecko.com/coins/images/2069/large/Stacks_Logo_png.png?1709979332', NULL, 0.76981700, -4.00, 1221725850, 0, 1, 99, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(100, 2, 'falcon-finance', 'Falcon USD', 'USDF', 'https://coin-images.coingecko.com/coins/images/54558/large/ff_200_X_200.png?1740741076', NULL, 0.99933500, 0.00, 1174197940, 0, 1, 100, '2025-07-29 17:13:32', '2025-07-29 17:13:32'),
(102, NULL, NULL, 'Tugaycoin', 'T', NULL, 'sex', 7000.00000000, 0.00, 0, 0, 1, 0, '2025-08-04 17:20:02', '2025-08-04 17:31:46');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `coin_islemleri`
--

CREATE TABLE `coin_islemleri` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `coin_id` int(11) DEFAULT NULL,
  `islem` enum('al','sat') DEFAULT NULL,
  `miktar` decimal(16,8) DEFAULT NULL,
  `fiyat` decimal(16,2) DEFAULT NULL,
  `tarih` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `coin_islemleri`
--

INSERT INTO `coin_islemleri` (`id`, `user_id`, `coin_id`, `islem`, `miktar`, `fiyat`, `tarih`) VALUES
(1, 3, 17, 'al', 4.68486213, 533.10, '2025-07-31 23:16:13'),
(9, 3, 4, 'al', 34.59898141, 29.99, '2025-08-01 04:17:33'),
(10, 3, 50, 'al', 0.37975914, 6595.20, '2025-08-01 05:08:49'),
(18, 1, 3, 'al', 26.50391827, 93.60, '2025-08-04 13:36:10'),
(19, 1, 3, 'al', 19.90446047, 93.60, '2025-08-04 14:01:23'),
(20, 3, 3, 'al', 0.11740385, 93.60, '2025-08-04 17:15:40'),
(21, 3, 102, 'al', 0.00000666, 150000.00, '2025-08-04 17:21:57'),
(22, 3, 102, 'al', 0.00007326, 150000.00, '2025-08-04 17:30:37'),
(23, 3, 102, 'al', 0.00087841, 210000.00, '2025-08-04 17:46:14');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `coin_kategorileri`
--

CREATE TABLE `coin_kategorileri` (
  `id` int(11) NOT NULL,
  `kategori_adi` varchar(100) DEFAULT NULL,
  `aciklama` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `sira` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `coin_kategorileri`
--

INSERT INTO `coin_kategorileri` (`id`, `kategori_adi`, `aciklama`, `is_active`, `sira`) VALUES
(1, 'Major Coins', NULL, 1, 0),
(2, 'Altcoins', NULL, 1, 0),
(3, 'DeFi', NULL, 1, 0),
(4, 'NFT', NULL, 1, 0),
(5, 'Meme Coins', NULL, 1, 0),
(6, 'Stablecoins', NULL, 1, 0),
(7, 'Major Coins', 'Bitcoin, Ethereum gibi büyük coinler', 1, 1),
(8, 'Altcoins', 'Alternatif coinler', 1, 2),
(9, 'DeFi', 'Merkeziyetsiz finans coinleri', 1, 3),
(10, 'Meme Coins', 'Eğlence amaçlı coinler', 1, 4),
(11, 'Stablecoins', 'Sabit değerli coinler', 1, 5);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `coin_price_history`
--

CREATE TABLE `coin_price_history` (
  `id` int(11) NOT NULL,
  `coin_id` int(11) DEFAULT NULL,
  `price` decimal(16,8) DEFAULT NULL,
  `price_change_24h` decimal(5,2) DEFAULT NULL,
  `market_cap` bigint(20) DEFAULT NULL,
  `recorded_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `faturalar`
--

CREATE TABLE `faturalar` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `islem_tipi` enum('para_yatirma','para_cekme','coin_islem') DEFAULT NULL,
  `islem_id` int(11) DEFAULT NULL,
  `fatura_no` varchar(50) DEFAULT NULL,
  `tutar` decimal(16,2) DEFAULT NULL,
  `kdv_orani` decimal(5,2) DEFAULT 0.00,
  `kdv_tutari` decimal(16,2) DEFAULT 0.00,
  `toplam_tutar` decimal(16,2) DEFAULT NULL,
  `tarih` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `faturalar`
--

INSERT INTO `faturalar` (`id`, `user_id`, `islem_tipi`, `islem_id`, `fatura_no`, `tutar`, `kdv_orani`, `kdv_tutari`, `toplam_tutar`, `tarih`) VALUES
(1, 4, 'para_cekme', 3, 'FTR-20250111-0004-1234', 800.00, 18.00, 144.00, 944.00, '2025-07-27 19:01:11'),
(2, 2, 'para_cekme', 1, 'FTR-20250111-0002-5678', 1500.00, 18.00, 270.00, 1770.00, '2025-07-28 19:01:11'),
(3, 4, 'para_cekme', 3, 'INV-2025-0642', 800.00, 0.00, 0.00, 800.00, '2025-07-30 21:01:28'),
(4, 4, 'para_cekme', 3, 'INV-2025-4161', 800.00, 0.00, 0.00, 800.00, '2025-07-31 07:27:36');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kullanici_islem_gecmisi`
--

CREATE TABLE `kullanici_islem_gecmisi` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `islem_tipi` enum('para_yatirma','para_cekme','coin_al','coin_sat','bakiye_guncelleme') DEFAULT NULL,
  `islem_detayi` text DEFAULT NULL,
  `tutar` decimal(16,2) DEFAULT NULL,
  `onceki_bakiye` decimal(16,2) DEFAULT NULL,
  `sonraki_bakiye` decimal(16,2) DEFAULT NULL,
  `tarih` datetime DEFAULT current_timestamp(),
  `ip_adresi` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `kullanici_islem_gecmisi`
--

INSERT INTO `kullanici_islem_gecmisi` (`id`, `user_id`, `islem_tipi`, `islem_detayi`, `tutar`, `onceki_bakiye`, `sonraki_bakiye`, `tarih`, `ip_adresi`, `user_agent`) VALUES
(1, 2, 'para_yatirma', 'Kredi kartı ile yatırma', 2000.00, 3000.00, 5000.00, '2025-07-25 19:01:11', NULL, NULL),
(2, 2, 'para_cekme', 'Para çekme onaylandı - havale', 1500.00, 5000.00, 3500.00, '2025-07-28 19:01:11', NULL, NULL),
(3, 3, 'para_yatirma', 'Papara ile yatırma', 3000.00, 4500.00, 7500.00, '2025-07-27 19:01:11', NULL, NULL),
(4, 4, 'para_yatirma', 'Havale ile yatırma', 1000.00, 2200.00, 3200.00, '2025-07-26 19:01:11', NULL, NULL),
(5, 4, 'para_cekme', 'Para çekme onaylandı - havale', 800.00, 3200.00, 2400.00, '2025-07-27 19:01:11', NULL, NULL),
(6, 1, 'para_yatirma', 'Para yatırma talebi oluşturuldu - papara - ₺22', 22.00, 0.00, 0.00, '2025-07-31 22:20:53', NULL, NULL),
(7, 1, 'para_yatirma', 'Para yatırma onaylandı - papara - ₺22.00', 22.00, 0.00, 22.00, '2025-07-31 22:21:04', NULL, NULL),
(8, 1, 'para_yatirma', 'Para yatırma talebi oluşturuldu - havale - ₺333', 333.00, 22.00, 22.00, '2025-07-31 22:23:01', NULL, NULL),
(9, 1, 'para_yatirma', 'Para yatırma onaylandı - havale - ₺333.00', 333.00, 22.00, 355.00, '2025-07-31 22:23:06', NULL, NULL),
(10, 1, 'para_yatirma', 'Para yatırma talebi oluşturuldu - papara - ₺200', 200.00, 355.00, 355.00, '2025-07-31 22:31:53', NULL, NULL),
(11, 1, 'para_yatirma', 'Para yatırma onaylandı - papara - ₺200.00', 200.00, 355.00, 555.00, '2025-07-31 22:32:02', NULL, NULL),
(12, 3, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-07-31 22:32:56', NULL, NULL),
(13, 3, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-07-31 22:51:03', NULL, NULL),
(14, 3, 'para_yatirma', 'Para yatırma talebi oluşturuldu - papara - ₺10000', 10000.00, 0.00, 0.00, '2025-07-31 23:04:42', NULL, NULL),
(15, 3, 'para_yatirma', 'Para yatırma onaylandı - papara - ₺10000.00', 10000.00, 0.00, 10000.00, '2025-07-31 23:04:48', NULL, NULL),
(16, 3, 'coin_al', '4.68486213 LINK satın alındı (₺533.1 fiyatından)', 2497.50, 10000.00, 7502.50, '2025-07-31 23:16:13', NULL, NULL),
(17, 3, 'coin_al', '0.00053064 BTC satın alındı (₺3534660 fiyatından)', 1875.63, 7502.50, 5626.87, '2025-07-31 23:17:32', NULL, NULL),
(18, 3, 'coin_al', '0.00079596 BTC satın alındı (₺3534660 fiyatından)', 2813.45, 5626.87, 2813.42, '2025-07-31 23:31:09', NULL, NULL),
(19, 3, 'coin_al', '0.00019899 BTC satın alındı (₺3534660 fiyatından)', 703.36, 2813.42, 2110.06, '2025-07-31 23:32:30', NULL, NULL),
(20, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2110.06, 2110.06, '2025-07-31 23:33:36', NULL, NULL),
(21, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2110.06, 2110.06, '2025-07-31 23:40:50', NULL, NULL),
(22, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2110.06, 2110.06, '2025-07-31 23:48:40', NULL, NULL),
(23, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2110.06, 2110.06, '2025-07-31 23:49:52', NULL, NULL),
(24, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2110.06, 2110.06, '2025-07-31 23:49:53', NULL, NULL),
(25, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2110.06, 2110.06, '2025-07-31 23:50:50', NULL, NULL),
(26, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2110.06, 2110.06, '2025-07-31 23:53:44', NULL, NULL),
(27, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2110.06, 2110.06, '2025-07-31 23:56:32', NULL, NULL),
(28, 3, 'coin_al', '0.00014909 BTC satın alındı (₺3534660 fiyatından)', 526.98, 2110.06, 1583.08, '2025-08-01 00:07:45', NULL, NULL),
(29, 3, 'coin_sat', '0.00033557 BTC satıldı (₺3534660 fiyatından)', 1186.13, 1583.08, 2769.21, '2025-08-01 00:08:04', NULL, NULL),
(30, 3, 'para_yatirma', 'Para yatırma talebi oluşturuldu - papara - ₺222', 222.00, 2769.21, 2769.21, '2025-08-01 00:10:12', NULL, NULL),
(31, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2769.21, 2769.21, '2025-08-01 00:11:09', NULL, NULL),
(32, 3, 'coin_al', '0.00019566 BTC satın alındı (₺3534660 fiyatından)', 691.59, 2769.21, 2077.62, '2025-08-01 00:11:32', NULL, NULL),
(33, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2077.62, 2077.62, '2025-08-01 04:15:35', NULL, NULL),
(34, 3, 'coin_sat', '0.00058778 BTC satıldı (₺3534660 fiyatından)', 2077.60, 2077.62, 4155.22, '2025-08-01 04:16:32', NULL, NULL),
(35, 3, '', 'Kullanıcı giriş yaptı', 0.00, 4155.22, 4155.22, '2025-08-01 04:17:09', NULL, NULL),
(36, 3, 'coin_al', '34.59898141 USDT satın alındı (₺29.99427 fiyatından)', 1037.77, 4155.22, 3117.45, '2025-08-01 04:17:33', NULL, NULL),
(37, 6, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-08-01 04:18:25', NULL, NULL),
(38, 3, 'para_yatirma', 'Para yatırma onaylandı - papara - ₺222.00', 222.00, 3117.45, 3339.45, '2025-08-01 04:19:17', NULL, NULL),
(39, 3, '', 'Kullanıcı giriş yaptı', 0.00, 3339.45, 3339.45, '2025-08-01 05:04:21', NULL, NULL),
(40, 3, '', 'Kullanıcı giriş yaptı', 0.00, 3339.45, 3339.45, '2025-08-01 05:08:17', NULL, NULL),
(41, 3, '', 'Kullanıcı giriş yaptı', 0.00, 3339.45, 3339.45, '2025-08-01 05:08:18', NULL, NULL),
(42, 3, 'coin_al', '0.37975914 JITOSOL satın alındı (₺6595.2 fiyatından)', 2504.59, 3339.45, 834.86, '2025-08-01 05:08:49', NULL, NULL),
(43, 3, '', 'Kullanıcı giriş yaptı', 0.00, 834.86, 834.86, '2025-08-01 05:41:20', NULL, NULL),
(44, 3, '', 'Kullanıcı giriş yaptı', 0.00, 834.86, 834.86, '2025-08-01 05:42:32', NULL, NULL),
(45, 3, '', 'Kullanıcı giriş yaptı', 0.00, 834.86, 834.86, '2025-08-01 05:42:33', NULL, NULL),
(46, 3, '', 'Kullanıcı giriş yaptı', 0.00, 834.86, 834.86, '2025-08-01 05:44:10', NULL, NULL),
(47, 3, '', 'Kullanıcı giriş yaptı', 0.00, 834.86, 834.86, '2025-08-01 05:44:11', NULL, NULL),
(48, 6, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-08-01 05:47:17', NULL, NULL),
(49, 3, '', 'Kullanıcı giriş yaptı', 0.00, 834.86, 834.86, '2025-08-01 05:48:05', NULL, NULL),
(50, 3, '', 'Kullanıcı giriş yaptı', 0.00, 834.86, 834.86, '2025-08-01 05:48:06', NULL, NULL),
(51, 6, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-08-01 05:48:14', NULL, NULL),
(52, 6, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-08-01 05:48:42', NULL, NULL),
(53, 3, '', 'Kullanıcı giriş yaptı', 0.00, 834.86, 834.86, '2025-08-01 08:29:04', NULL, NULL),
(54, 3, 'coin_al', '0.0001181 BTC satın alındı (₺3534660 fiyatından)', 417.44, 834.86, 417.42, '2025-08-01 09:03:16', NULL, NULL),
(55, 3, 'coin_sat', '0.00011809 BTC satıldı (₺3534660 fiyatından)', 417.41, 417.42, 834.83, '2025-08-01 09:03:35', NULL, NULL),
(56, 3, '', 'Kullanıcı giriş yaptı', 0.00, 10834.83, 10834.83, '2025-08-01 09:11:29', NULL, NULL),
(57, 3, '', 'Kullanıcı giriş yaptı', 0.00, 10834.83, 10834.83, '2025-08-01 09:12:31', NULL, NULL),
(58, 3, '', 'Kullanıcı giriş yaptı', 0.00, 10834.83, 10834.83, '2025-08-01 09:13:09', NULL, NULL),
(59, 3, '', 'Kullanıcı giriş yaptı', 0.00, 10834.83, 10834.83, '2025-08-01 09:58:43', NULL, NULL),
(60, 3, 'coin_al', '1.413E-5 BTC satın alındı (₺3534660 fiyatından)', 49.94, 10834.83, 10784.89, '2025-08-01 10:00:05', NULL, NULL),
(61, 3, '', 'Kullanıcı giriş yaptı', 0.00, 10784.89, 10784.89, '2025-08-01 10:03:55', NULL, NULL),
(62, 3, '', 'Kullanıcı giriş yaptı', 0.00, 10784.89, 10784.89, '2025-08-01 10:06:54', NULL, NULL),
(63, 3, 'coin_al', '0.0007628 BTC satın alındı (₺3534660 fiyatından)', 2696.24, 10784.89, 8088.65, '2025-08-01 10:07:01', NULL, NULL),
(64, 3, '', 'Kullanıcı giriş yaptı', 0.00, 8088.65, 8088.65, '2025-08-01 10:09:15', NULL, NULL),
(65, 3, '', 'Kullanıcı giriş yaptı', 0.00, 8088.65, 8088.65, '2025-08-01 10:09:16', NULL, NULL),
(66, 3, 'coin_al', '0.00057152 BTC satın alındı (₺3534660 fiyatından)', 2020.13, 8088.65, 6068.52, '2025-08-01 10:09:33', NULL, NULL),
(67, 3, '', 'Kullanıcı giriş yaptı', 0.00, 6068.52, 6068.52, '2025-08-01 11:21:02', NULL, NULL),
(68, 3, '', 'Kullanıcı giriş yaptı', 0.00, 6068.52, 6068.52, '2025-08-01 11:28:18', NULL, NULL),
(69, 3, 'coin_al', '0.00042879 BTC satın alındı (₺3534660 fiyatından)', 1515.63, 6068.52, 4552.89, '2025-08-01 11:28:26', NULL, NULL),
(70, 3, '', 'Kullanıcı giriş yaptı', 0.00, 4552.89, 4552.89, '2025-08-01 11:38:49', NULL, NULL),
(71, 3, '', 'Kullanıcı giriş yaptı', 0.00, 3214.67, 3214.67, '2025-08-01 12:05:38', NULL, NULL),
(72, 3, 'coin_al', '0.00022008 BTC satın alındı (₺3534660 fiyatından)', 777.91, 3114.67, 2336.76, '2025-08-01 12:06:06', NULL, NULL),
(73, 3, '', 'Kullanıcı giriş yaptı', 0.00, 1272.16, 1272.16, '2025-08-01 13:05:04', NULL, NULL),
(74, 1, 'para_yatirma', 'Para yatırma talebi oluşturuldu - papara - ₺10000', 10000.00, -67.00, -67.00, '2025-08-01 20:50:22', NULL, NULL),
(75, 6, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-08-01 20:51:23', NULL, NULL),
(76, 1, 'para_yatirma', 'Para yatırma onaylandı - papara - ₺10000.00', 10000.00, -67.00, 9933.00, '2025-08-01 20:51:35', NULL, NULL),
(77, 3, '', 'Kullanıcı giriş yaptı', 0.00, 1272.16, 1272.16, '2025-08-01 20:51:46', NULL, NULL),
(78, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2067.99, 2067.99, '2025-08-01 22:53:25', NULL, NULL),
(79, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2067.99, 2067.99, '2025-08-02 11:31:57', NULL, NULL),
(80, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2067.99, 2067.99, '2025-08-03 15:30:46', NULL, NULL),
(81, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2067.99, 2067.99, '2025-08-04 12:07:38', NULL, NULL),
(82, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2067.99, 2067.99, '2025-08-04 12:22:12', NULL, NULL),
(83, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2105.92, 2105.92, '2025-08-04 13:17:14', NULL, NULL),
(84, 1, 'coin_al', '26.50391827 XRP satın alındı (₺93.6 fiyatından)', 2480.77, 9933.00, 7452.23, '2025-08-04 13:36:10', NULL, NULL),
(85, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2105.92, 2105.92, '2025-08-04 13:36:20', NULL, NULL),
(86, 1, 'coin_al', '19.90446047 XRP satın alındı (₺93.6 fiyatından)', 1863.06, 7452.23, 5589.17, '2025-08-04 14:01:23', NULL, NULL),
(87, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2105.92, 2105.92, '2025-08-04 16:45:12', NULL, NULL),
(88, 6, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-08-04 17:05:42', NULL, NULL),
(89, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2105.92, 2105.92, '2025-08-04 17:06:27', NULL, NULL),
(90, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2105.92, 2105.92, '2025-08-04 17:09:08', NULL, NULL),
(91, 3, 'coin_al', '0.11740385 XRP satın alındı (₺93.6 fiyatından)', 10.99, 2312.36, 2301.37, '2025-08-04 17:15:40', NULL, NULL),
(92, 6, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-08-04 17:19:40', NULL, NULL),
(93, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2301.37, 2301.37, '2025-08-04 17:21:36', NULL, NULL),
(94, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2301.37, 2301.37, '2025-08-04 17:21:37', NULL, NULL),
(95, 3, 'coin_al', '6.66E-6 T satın alındı (₺150000 fiyatından)', 1.00, 2301.37, 2300.37, '2025-08-04 17:21:57', NULL, NULL),
(96, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2300.37, 2300.37, '2025-08-04 17:30:15', NULL, NULL),
(97, 3, 'coin_al', '7.326E-5 T satın alındı (₺150000 fiyatından)', 10.99, 2300.37, 2289.38, '2025-08-04 17:30:37', NULL, NULL),
(98, 6, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-08-04 17:34:58', NULL, NULL),
(99, 6, '', 'Kullanıcı giriş yaptı', 0.00, 0.00, 0.00, '2025-08-04 17:42:43', NULL, NULL),
(100, 3, '', 'Kullanıcı giriş yaptı', 0.00, 2178.38, 2178.38, '2025-08-04 17:43:58', NULL, NULL),
(101, 3, 'coin_al', '0.00087841 T satın alındı (₺210000 fiyatından)', 184.47, 738.59, 554.12, '2025-08-04 17:46:14', NULL, NULL);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `leverage_positions`
--

CREATE TABLE `leverage_positions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `coin_symbol` varchar(10) NOT NULL,
  `position_type` enum('long','short') NOT NULL,
  `leverage_ratio` decimal(3,1) NOT NULL,
  `entry_price` decimal(20,8) NOT NULL,
  `position_size` decimal(20,8) NOT NULL,
  `invested_amount` decimal(20,8) NOT NULL,
  `current_price` decimal(20,8) DEFAULT NULL,
  `unrealized_pnl` decimal(20,8) DEFAULT 0.00000000,
  `status` enum('open','closed','liquidated') DEFAULT 'open',
  `stop_loss_price` decimal(20,8) DEFAULT NULL,
  `take_profit_price` decimal(20,8) DEFAULT NULL,
  `liquidation_price` decimal(20,8) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `closed_at` timestamp NULL DEFAULT NULL,
  `close_price` decimal(20,8) DEFAULT NULL,
  `realized_pnl` decimal(20,8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `leverage_positions`
--

INSERT INTO `leverage_positions` (`id`, `user_id`, `coin_symbol`, `position_type`, `leverage_ratio`, `entry_price`, `position_size`, `invested_amount`, `current_price`, `unrealized_pnl`, `status`, `stop_loss_price`, `take_profit_price`, `liquidation_price`, `created_at`, `updated_at`, `closed_at`, `close_price`, `realized_pnl`) VALUES
(1, 3, 'BTC', 'long', 1.0, 3534660.00000000, 0.00032202, 1138.22000000, 117822.00000000, -1100.29017276, 'closed', NULL, NULL, 706932.00000000, '2025-08-01 11:42:43', '2025-08-04 12:50:55', '2025-08-04 12:50:55', 117822.00000000, -1100.29017276),
(2, 1, 'BTC', 'long', 1.0, 3534660.00000000, 0.00003925, 138.75000000, 117822.00000000, -134.11089150, 'closed', NULL, NULL, 706932.00000000, '2025-08-01 11:47:18', '2025-08-01 14:07:00', '2025-08-01 14:07:00', 117822.00000000, -134.11089150),
(3, 3, 'BTC', 'long', 2.0, 50000.00000000, 0.00400000, 100.00000000, 50000.00000000, 0.00000000, 'closed', NULL, NULL, 30000.00000000, '2025-08-01 12:03:27', '2025-08-04 17:09:43', '2025-08-04 17:09:43', 50000.00000000, 0.00000000),
(4, 3, 'BTC', 'long', 2.0, 50000.00000000, 0.00400000, 100.00000000, 117822.00000000, 271.28800000, 'closed', NULL, NULL, 30000.00000000, '2025-08-01 12:03:30', '2025-08-01 20:52:48', '2025-08-01 20:52:48', 117822.00000000, 271.28800000),
(5, 3, 'BTC', 'long', 2.0, 50000.00000000, 0.00400000, 100.00000000, 117822.00000000, 271.28800000, 'closed', NULL, NULL, 30000.00000000, '2025-08-01 12:05:50', '2025-08-01 20:52:46', '2025-08-01 20:52:46', 117822.00000000, 271.28800000),
(6, 3, 'BTC', 'long', 2.0, 50000.00000000, 0.00400000, 100.00000000, 117822.00000000, 271.28800000, 'closed', NULL, NULL, 30000.00000000, '2025-08-01 12:08:50', '2025-08-01 20:52:43', '2025-08-01 20:52:43', 117822.00000000, 271.28800000),
(7, 3, 'BTC', 'long', 1.0, 3534660.00000000, 0.00015820, 559.19000000, 3534660.00000000, 0.00000000, 'closed', NULL, NULL, 706932.00000000, '2025-08-01 12:09:02', '2025-08-04 17:09:41', '2025-08-04 17:09:41', 3534660.00000000, 0.00000000),
(8, 3, 'XRP', 'long', 1.0, 93.60000000, 4.48068910, 419.39249976, 3.12000000, -405.41274977, 'closed', NULL, NULL, 18.72000000, '2025-08-01 12:14:59', '2025-08-01 12:23:26', '2025-08-01 12:23:26', 3.12000000, -405.41274977),
(9, 1, 'BTC', 'long', 10.0, 3534660.00000000, 0.00005888, 20.81207808, 117822.00000000, -201.18342144, 'closed', NULL, NULL, 3251887.20000000, '2025-08-01 14:02:51', '2025-08-01 14:06:56', '2025-08-01 14:06:56', 117822.00000000, -201.18342144),
(10, 1, 'BTC', 'long', 10.0, 3534660.00000000, 0.00008391, 29.65933206, 117822.00000000, -286.70687658, 'closed', NULL, NULL, 3251887.20000000, '2025-08-01 14:05:18', '2025-08-01 14:06:53', '2025-08-01 14:06:53', 117822.00000000, -286.70687658),
(11, 3, 'BTC', 'long', 1.0, 3534660.00000000, 0.00008998, 318.04000000, 3534660.00000000, 0.00000000, 'closed', NULL, NULL, 706932.00000000, '2025-08-01 20:52:10', '2025-08-04 17:09:38', '2025-08-04 17:09:38', 3534660.00000000, 0.00000000),
(12, 1, 'USDE', 'long', 1.0, 30.03000000, 46.52980353, 1397.29000000, 1.00100000, -1350.71366667, 'open', NULL, NULL, 6.00600000, '2025-08-04 14:20:22', '2025-08-04 14:20:22', NULL, NULL, NULL),
(13, 3, 'TGC', 'long', 1.0, 9458070.00000000, 0.00008150, 770.79000000, 9458070.00000000, 0.00000000, 'closed', NULL, NULL, 1891614.00000000, '2025-08-04 17:10:22', '2025-08-04 17:44:18', '2025-08-04 17:44:18', 9458070.00000000, 0.00000000),
(14, 3, 'T', 'long', 1.0, 150000.00000000, 0.00074000, 111.00000000, 7000.00000000, -105.82000000, 'closed', NULL, NULL, 30000.00000000, '2025-08-04 17:31:08', '2025-08-04 17:44:16', '2025-08-04 17:44:16', 7000.00000000, -105.82000000),
(15, 3, 'T', 'long', 1.0, 210000.00000000, 0.01055124, 2215.76000000, 7000.00000000, -2141.90172000, 'open', NULL, NULL, 42000.00000000, '2025-08-04 17:44:28', '2025-08-04 17:44:28', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `leverage_settings`
--

CREATE TABLE `leverage_settings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `max_leverage` decimal(3,1) DEFAULT 10.0,
  `default_leverage` decimal(3,1) DEFAULT 1.0,
  `auto_close_enabled` tinyint(1) DEFAULT 1,
  `max_loss_percentage` decimal(5,2) DEFAULT 80.00,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `loglar`
--

CREATE TABLE `loglar` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `tip` enum('para_yatirma','coin_islem','api_guncelleme') DEFAULT NULL,
  `detay` text DEFAULT NULL,
  `tarih` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `loglar`
--

INSERT INTO `loglar` (`id`, `user_id`, `tip`, `detay`, `tarih`) VALUES
(1, 1, 'para_yatirma', 'Para yatırma talebi: ID:1, Yöntem:papara, Tutar:₺22', '2025-07-31 22:20:53'),
(2, 1, 'para_yatirma', 'Para yatırma onaylandı: ID:1, Tutar:₺22.00, Yeni Bakiye:₺22.00', '2025-07-31 22:21:04'),
(3, 1, 'para_yatirma', 'Para yatırma talebi: ID:2, Yöntem:havale, Tutar:₺333', '2025-07-31 22:23:01'),
(4, 1, 'para_yatirma', 'Para yatırma onaylandı: ID:2, Tutar:₺333.00, Yeni Bakiye:₺355.00', '2025-07-31 22:23:06'),
(5, 1, 'para_yatirma', 'Para yatırma talebi: ID:3, Yöntem:papara, Tutar:₺200', '2025-07-31 22:31:53'),
(6, 1, 'para_yatirma', 'Para yatırma onaylandı: ID:3, Tutar:₺200.00, Yeni Bakiye:₺555.00', '2025-07-31 22:32:02'),
(7, 3, 'para_yatirma', 'Para yatırma talebi: ID:4, Yöntem:papara, Tutar:₺10000', '2025-07-31 23:04:42'),
(8, 3, 'para_yatirma', 'Para yatırma onaylandı: ID:4, Tutar:₺10000.00, Yeni Bakiye:₺10000.00', '2025-07-31 23:04:48'),
(9, 3, 'coin_islem', 'SATIN ALMA: 4.68486213 LINK - ₺2497.500001503 - ID:1', '2025-07-31 23:16:13'),
(10, 3, 'coin_islem', 'SATIN ALMA: 0.00053064 BTC - ₺1875.6319824 - ID:2', '2025-07-31 23:17:32'),
(11, 3, 'coin_islem', 'SATIN ALMA: 0.00079596 BTC - ₺2813.4479736 - ID:3', '2025-07-31 23:31:09'),
(12, 3, 'coin_islem', 'SATIN ALMA: 0.00019899 BTC - ₺703.3619934 - ID:4', '2025-07-31 23:32:30'),
(13, 3, 'coin_islem', 'SATIN ALMA: 0.00014909 BTC - ₺526.9824594 - ID:5', '2025-08-01 00:07:45'),
(14, 3, 'coin_islem', 'SATIM: 0.00033557 BTC - ₺1186.1258562 - ID:6', '2025-08-01 00:08:04'),
(15, 3, 'para_yatirma', 'Para yatırma talebi: ID:5, Yöntem:papara, Tutar:₺222', '2025-08-01 00:10:12'),
(16, 3, 'coin_islem', 'SATIN ALMA: 0.00019566 BTC - ₺691.5915756 - ID:7', '2025-08-01 00:11:32'),
(17, 3, 'coin_islem', 'SATIM: 0.00058778 BTC - ₺2077.6024548 - ID:8', '2025-08-01 04:16:32'),
(18, 3, 'coin_islem', 'SATIN ALMA: 34.59898141 USDT - ₺1037.7711901365 - ID:9', '2025-08-01 04:17:33'),
(19, 3, 'para_yatirma', 'Para yatırma onaylandı: ID:5, Tutar:₺222.00, Yeni Bakiye:₺3339.45', '2025-08-01 04:19:17'),
(20, 3, 'coin_islem', 'SATIN ALMA: 0.37975914 JITOSOL - ₺2504.587480128 - ID:10', '2025-08-01 05:08:49'),
(21, 3, 'coin_islem', 'SATIN ALMA: 0.0001181 BTC - ₺417.443346 - ID:11', '2025-08-01 09:03:16'),
(22, 3, 'coin_islem', 'SATIM: 0.00011809 BTC - ₺417.4079994 - ID:12', '2025-08-01 09:03:35'),
(23, 3, 'coin_islem', 'SATIN ALMA: 1.413E-5 BTC - ₺49.9447458 - ID:13', '2025-08-01 10:00:05'),
(24, 3, 'coin_islem', 'SATIN ALMA: 0.0007628 BTC - ₺2696.238648 - ID:14', '2025-08-01 10:07:01'),
(25, 3, 'coin_islem', 'SATIN ALMA: 0.00057152 BTC - ₺2020.1288832 - ID:15', '2025-08-01 10:09:33'),
(26, 3, 'coin_islem', 'SATIN ALMA: 0.00042879 BTC - ₺1515.6268614 - ID:16', '2025-08-01 11:28:26'),
(28, 3, 'coin_islem', 'SATIN ALMA: 0.00022008 BTC - ₺777.9079728 - ID:17', '2025-08-01 12:06:06'),
(29, 3, '', 'Opened leverage position: BTC long 2x', '2025-08-01 12:08:50'),
(30, 3, '', 'Opened leverage position: BTC long 1x', '2025-08-01 12:09:02'),
(39, 3, '', 'Opened leverage position: XRP long 1x', '2025-08-01 12:14:59'),
(63, 3, '', 'Closed leverage position: XRP PnL: -405.412749768', '2025-08-01 12:23:26'),
(64, 1, '', 'Opened leverage position: BTC long 10x', '2025-08-01 14:02:51'),
(65, 1, '', 'Opened leverage position: BTC long 10x', '2025-08-01 14:05:18'),
(66, 1, '', 'Closed leverage position: BTC PnL: -286.70687658', '2025-08-01 14:06:53'),
(67, 1, '', 'Closed leverage position: BTC PnL: -201.18342144', '2025-08-01 14:06:56'),
(68, 1, '', 'Closed leverage position: BTC PnL: -134.1108915', '2025-08-01 14:07:00'),
(69, 1, 'para_yatirma', 'Para yatırma talebi: ID:6, Yöntem:papara, Tutar:₺10000', '2025-08-01 20:50:22'),
(70, 1, 'para_yatirma', 'Para yatırma onaylandı: ID:6, Tutar:₺10000.00, Yeni Bakiye:₺9933.00', '2025-08-01 20:51:35'),
(71, 3, '', 'Opened leverage position: BTC long 1x', '2025-08-01 20:52:10'),
(72, 3, '', 'Closed leverage position: BTC PnL: 271.288', '2025-08-01 20:52:43'),
(73, 3, '', 'Closed leverage position: BTC PnL: 271.288', '2025-08-01 20:52:46'),
(74, 3, '', 'Closed leverage position: BTC PnL: 271.288', '2025-08-01 20:52:48'),
(75, 3, '', 'Closed leverage position: BTC PnL: -1100.29017276', '2025-08-04 12:50:55'),
(76, 1, 'coin_islem', 'SATIN ALMA: 26.50391827 XRP - ₺2480.766750072 - ID:18', '2025-08-04 13:36:10'),
(77, 1, 'coin_islem', 'SATIN ALMA: 19.90446047 XRP - ₺1863.057499992 - ID:19', '2025-08-04 14:01:23'),
(78, 1, '', 'Opened leverage position: USDE long 1x', '2025-08-04 14:20:22'),
(79, 3, '', 'Closed leverage position: BTC PnL: 0', '2025-08-04 17:09:38'),
(80, 3, '', 'Closed leverage position: BTC PnL: 0', '2025-08-04 17:09:41'),
(81, 3, '', 'Closed leverage position: BTC PnL: 0', '2025-08-04 17:09:43'),
(82, 3, '', 'Opened leverage position: TGC long 1x', '2025-08-04 17:10:22'),
(83, 3, 'coin_islem', 'SATIN ALMA: 0.11740385 XRP - ₺10.98900036 - ID:20', '2025-08-04 17:15:40'),
(84, 3, 'coin_islem', 'SATIN ALMA: 6.66E-6 T - ₺0.999 - ID:21', '2025-08-04 17:21:57'),
(85, 3, 'coin_islem', 'SATIN ALMA: 7.326E-5 T - ₺10.989 - ID:22', '2025-08-04 17:30:37'),
(86, 3, '', 'Opened leverage position: T long 1x', '2025-08-04 17:31:08'),
(87, 3, '', 'Closed leverage position: T PnL: -105.82', '2025-08-04 17:44:16'),
(88, 3, '', 'Closed leverage position: TGC PnL: 0', '2025-08-04 17:44:18'),
(89, 3, '', 'Opened leverage position: T long 1x', '2025-08-04 17:44:28'),
(90, 3, 'coin_islem', 'SATIN ALMA: 0.00087841 T - ₺184.4661 - ID:23', '2025-08-04 17:46:14');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `para_cekme_talepleri`
--

CREATE TABLE `para_cekme_talepleri` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `yontem` enum('papara','havale','kredi_karti') DEFAULT NULL,
  `tutar` decimal(16,2) DEFAULT NULL,
  `iban` varchar(50) DEFAULT NULL,
  `hesap_sahibi` varchar(100) DEFAULT NULL,
  `durum` enum('beklemede','onaylandi','reddedildi') DEFAULT 'beklemede',
  `tarih` datetime DEFAULT current_timestamp(),
  `onay_tarihi` datetime DEFAULT NULL,
  `onaylayan_admin_id` int(11) DEFAULT NULL,
  `aciklama` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `para_cekme_talepleri`
--

INSERT INTO `para_cekme_talepleri` (`id`, `user_id`, `yontem`, `tutar`, `iban`, `hesap_sahibi`, `durum`, `tarih`, `onay_tarihi`, `onaylayan_admin_id`, `aciklama`) VALUES
(1, 2, 'havale', 1500.00, 'TR63 0006 4000 0019 3001 9751 44', 'Ahmet Yılmaz', 'beklemede', '2025-07-28 19:01:11', NULL, NULL, 'Acil para ihtiyacı'),
(2, 3, 'papara', 2500.00, '', 'Fatma Demir', 'beklemede', '2025-07-29 19:01:11', NULL, NULL, 'Alışveriş için'),
(3, 4, 'havale', 800.00, 'TR63 0006 4000 0019 3001 9751 45', 'Mehmet Kaya', 'onaylandi', '2025-07-27 19:01:11', NULL, NULL, 'Fatura ödemesi'),
(4, 2, 'papara', 1200.00, '', 'Ahmet Yılmaz', 'reddedildi', '2025-07-26 19:01:11', NULL, NULL, 'Yetersiz bakiye');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `para_yatirma_talepleri`
--

CREATE TABLE `para_yatirma_talepleri` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `yontem` enum('kredi_karti','papara','havale') DEFAULT NULL,
  `tutar` decimal(16,2) DEFAULT NULL,
  `durum` enum('beklemede','onaylandi','reddedildi') DEFAULT 'beklemede',
  `onay_tarihi` datetime DEFAULT NULL,
  `onaylayan_admin_id` int(11) DEFAULT NULL,
  `tarih` datetime DEFAULT current_timestamp(),
  `detay_bilgiler` text DEFAULT NULL,
  `aciklama` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `para_yatirma_talepleri`
--

INSERT INTO `para_yatirma_talepleri` (`id`, `user_id`, `yontem`, `tutar`, `durum`, `onay_tarihi`, `onaylayan_admin_id`, `tarih`, `detay_bilgiler`, `aciklama`) VALUES
(1, 1, 'papara', 22.00, 'onaylandi', '2025-07-31 22:21:04', 1, '2025-07-31 22:20:53', '{\"papara_number\":\"123123123\"}', 'Admin tarafından onaylandı'),
(2, 1, 'havale', 333.00, 'onaylandi', '2025-07-31 22:23:06', 1, '2025-07-31 22:23:01', '{\"sender_name\":\"tugay sec\",\"sender_iban\":\"tr1321231231231321\"}', 'Admin tarafından onaylandı'),
(3, 1, 'papara', 200.00, 'onaylandi', '2025-07-31 22:32:02', 1, '2025-07-31 22:31:53', '{\"papara_number\":\"1231231231231\"}', 'Admin tarafından onaylandı'),
(4, 3, 'papara', 10000.00, 'onaylandi', '2025-07-31 23:04:48', 3, '2025-07-31 23:04:42', '{\"papara_number\":\"12313211231212\"}', 'Admin tarafından onaylandı'),
(5, 3, 'papara', 222.00, 'onaylandi', '2025-08-01 04:19:17', 6, '2025-08-01 00:10:12', '{\"papara_number\":\"asdasdsad\"}', 'Admin tarafından onaylandı'),
(6, 1, 'papara', 10000.00, 'onaylandi', '2025-08-01 20:51:34', 6, '2025-08-01 20:50:22', '{\"papara_number\":\"2828282\"}', 'Admin tarafından onaylandı');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `position_history`
--

CREATE TABLE `position_history` (
  `id` int(11) NOT NULL,
  `position_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action_type` enum('open','close','liquidate','update') NOT NULL,
  `price` decimal(20,8) NOT NULL,
  `pnl` decimal(20,8) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `position_history`
--

INSERT INTO `position_history` (`id`, `position_id`, `user_id`, `action_type`, `price`, `pnl`, `timestamp`) VALUES
(1, 1, 3, 'open', 3534660.00000000, NULL, '2025-08-01 11:42:43'),
(2, 2, 1, 'open', 3534660.00000000, NULL, '2025-08-01 11:47:18'),
(3, 3, 3, 'open', 50000.00000000, NULL, '2025-08-01 12:03:27'),
(4, 4, 3, 'open', 50000.00000000, NULL, '2025-08-01 12:03:30'),
(5, 5, 3, 'open', 50000.00000000, NULL, '2025-08-01 12:05:50'),
(6, 6, 3, 'open', 50000.00000000, NULL, '2025-08-01 12:08:50'),
(7, 7, 3, 'open', 3534660.00000000, NULL, '2025-08-01 12:09:02'),
(8, 8, 3, 'open', 93.60000000, NULL, '2025-08-01 12:14:59'),
(9, 8, 3, 'close', 3.12000000, -405.41274977, '2025-08-01 12:23:26'),
(10, 9, 1, 'open', 3534660.00000000, NULL, '2025-08-01 14:02:51'),
(11, 10, 1, 'open', 3534660.00000000, NULL, '2025-08-01 14:05:18'),
(12, 10, 1, 'close', 117822.00000000, -286.70687658, '2025-08-01 14:06:53'),
(13, 9, 1, 'close', 117822.00000000, -201.18342144, '2025-08-01 14:06:56'),
(14, 2, 1, 'close', 117822.00000000, -134.11089150, '2025-08-01 14:07:00'),
(15, 11, 3, 'open', 3534660.00000000, NULL, '2025-08-01 20:52:10'),
(16, 6, 3, 'close', 117822.00000000, 271.28800000, '2025-08-01 20:52:43'),
(17, 5, 3, 'close', 117822.00000000, 271.28800000, '2025-08-01 20:52:46'),
(18, 4, 3, 'close', 117822.00000000, 271.28800000, '2025-08-01 20:52:48'),
(19, 1, 3, 'close', 117822.00000000, -1100.29017276, '2025-08-04 12:50:55'),
(20, 12, 1, 'open', 30.03000000, NULL, '2025-08-04 14:20:22'),
(21, 11, 3, 'close', 3534660.00000000, 0.00000000, '2025-08-04 17:09:38'),
(22, 7, 3, 'close', 3534660.00000000, 0.00000000, '2025-08-04 17:09:41'),
(23, 3, 3, 'close', 50000.00000000, 0.00000000, '2025-08-04 17:09:43'),
(24, 13, 3, 'open', 9458070.00000000, NULL, '2025-08-04 17:10:22'),
(25, 14, 3, 'open', 150000.00000000, NULL, '2025-08-04 17:31:08'),
(26, 14, 3, 'close', 7000.00000000, -105.82000000, '2025-08-04 17:44:16'),
(27, 13, 3, 'close', 9458070.00000000, 0.00000000, '2025-08-04 17:44:18'),
(28, 15, 3, 'open', 210000.00000000, NULL, '2025-08-04 17:44:28');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `sistem_ayarlari`
--

CREATE TABLE `sistem_ayarlari` (
  `id` int(11) NOT NULL,
  `ayar_adi` varchar(100) DEFAULT NULL,
  `ayar_degeri` text DEFAULT NULL,
  `aciklama` text DEFAULT NULL,
  `guncelleme_tarihi` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `sistem_ayarlari`
--

INSERT INTO `sistem_ayarlari` (`id`, `ayar_adi`, `ayar_degeri`, `aciklama`, `guncelleme_tarihi`) VALUES
(1, 'papara_numara', '', 'Papara numarası', '2025-07-30 18:50:37'),
(2, 'banka_adi', '', 'Banka adı', '2025-07-30 18:50:37'),
(3, 'banka_iban', '', 'Banka IBAN numarası', '2025-07-30 18:50:37'),
(4, 'banka_hesap_sahibi', '', 'Banka hesap sahibi', '2025-07-30 18:50:37'),
(5, 'kart_komisyon_orani', '2.5', 'Kredi kartı komisyon oranı (%)', '2025-07-30 18:50:37'),
(6, 'papara_komisyon_orani', '1.0', 'Papara komisyon oranı (%)', '2025-07-30 18:50:37'),
(7, 'havale_komisyon_orani', '0.0', 'Havale komisyon oranı (%)', '2025-07-30 18:50:37'),
(8, 'minimum_cekme_tutari', '50', 'Minimum para çekme tutarı', '2025-07-30 18:50:37'),
(9, 'maksimum_cekme_tutari', '10000', 'Maksimum para çekme tutarı', '2025-07-30 18:50:37'),
(10, 'fatura_sirket_adi', 'Crypto Trading Platform', 'Fatura şirket adı', '2025-07-30 18:50:37'),
(11, 'fatura_adres', '', 'Fatura adresi', '2025-07-30 18:50:37'),
(12, 'fatura_vergi_no', '', 'Fatura vergi numarası', '2025-07-30 18:50:37'),
(13, 'fatura_telefon', '', 'Fatura telefon numarası', '2025-07-30 18:50:37'),
(14, 'fatura_email', '', 'Fatura email adresi', '2025-07-30 18:50:37');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `telefon` varchar(20) DEFAULT NULL,
  `ad_soyad` varchar(100) DEFAULT NULL,
  `tc_no` varchar(11) DEFAULT NULL,
  `iban` varchar(50) DEFAULT NULL,
  `dogum_tarihi` date DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` enum('user','admin') DEFAULT 'user',
  `is_active` tinyint(1) DEFAULT 1,
  `son_giris` datetime DEFAULT NULL,
  `ip_adresi` varchar(45) DEFAULT NULL,
  `balance` decimal(16,2) DEFAULT 0.00,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tablo döküm verisi `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `telefon`, `ad_soyad`, `tc_no`, `iban`, `dogum_tarihi`, `password`, `role`, `is_active`, `son_giris`, `ip_adresi`, `balance`, `created_at`) VALUES
(1, 'tttttt', 'asdasdasdsa@msn.com', NULL, NULL, NULL, 'TR63 0006 4000 0019 3001 9751 48', NULL, '$2y$10$o2jol2k0C0sIURlr31P6ZuffXwYuFu5HPqB2RVfzRYcU8HGIKSYE2', 'user', 1, NULL, NULL, 4191.88, '2025-07-29 16:08:40'),
(2, 'tugay60', 'asdasdasdsa@test.com', NULL, NULL, NULL, 'TR63 0006 4000 0019 3001 9751 49', NULL, '$2y$10$2o214a/ZB6L5UgoET6ysSu/b5wauyLtjx.OGMI6lZEV8pE6glDac2', 'user', 1, NULL, NULL, 0.00, '2025-07-29 16:37:25'),
(3, 't', 'tusec@test.com', NULL, NULL, NULL, 'TR63 0006 4000 0019 3001 9751 50', NULL, '123', 'user', 1, '2025-08-04 17:43:58', '2a02:4780:40:9::2', 554.12, '2025-07-29 16:42:51'),
(4, 'aliUsanmaz', 'aliusanmaz640@gmail.com', NULL, NULL, NULL, 'TR63 0006 4000 0019 3001 9751 51', NULL, '123qw123', 'user', 1, NULL, NULL, 0.00, '2025-07-29 21:04:42'),
(5, 'adad', 'adad@test.com', NULL, NULL, NULL, 'TR63 0006 4000 0019 3001 9751 52', NULL, '11111111', 'user', 1, NULL, NULL, 0.00, '2025-07-30 07:21:00'),
(6, 'admin', 'admin@cryptotrading.com', NULL, 'Sistem Yöneticisi', NULL, 'TR63 0006 4000 0019 3001 9751 47', NULL, '1', 'admin', 1, '2025-08-04 17:42:43', '2a02:4780:40:9::2', 0.00, '2025-07-30 18:50:37'),
(11, 'user1', 'user1@example.com', '+905551234568', 'Ahmet Yılmaz', '12345678902', 'TR63 0006 4000 0019 3001 9751 44', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, NULL, NULL, 5000.00, '2025-07-30 19:01:11'),
(12, 'user2', 'user2@example.com', '+905551234569', 'Fatma Demir', '12345678903', 'TR63 0006 4000 0019 3001 9751 45', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, NULL, NULL, 7500.00, '2025-07-30 19:01:11'),
(13, 'user3', 'user3@example.com', '+905551234570', 'Mehmet Kaya', '12345678904', 'TR63 0006 4000 0019 3001 9751 46', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, NULL, NULL, 3200.00, '2025-07-30 19:01:11'),
(14, 'kemta', 'kemta@test.com', NULL, NULL, NULL, NULL, NULL, '11111111', 'user', 1, NULL, NULL, 0.00, '2025-07-31 07:28:28');

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `admin_islem_loglari`
--
ALTER TABLE `admin_islem_loglari`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Tablo için indeksler `ayarlar`
--
ALTER TABLE `ayarlar`
  ADD PRIMARY KEY (`key`);

--
-- Tablo için indeksler `coins`
--
ALTER TABLE `coins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `coingecko_id` (`coingecko_id`),
  ADD KEY `kategori_id` (`kategori_id`);

--
-- Tablo için indeksler `coin_islemleri`
--
ALTER TABLE `coin_islemleri`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `coin_id` (`coin_id`);

--
-- Tablo için indeksler `coin_kategorileri`
--
ALTER TABLE `coin_kategorileri`
  ADD PRIMARY KEY (`id`);

--
-- Tablo için indeksler `coin_price_history`
--
ALTER TABLE `coin_price_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `coin_id` (`coin_id`);

--
-- Tablo için indeksler `faturalar`
--
ALTER TABLE `faturalar`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fatura_no` (`fatura_no`),
  ADD KEY `user_id` (`user_id`);

--
-- Tablo için indeksler `kullanici_islem_gecmisi`
--
ALTER TABLE `kullanici_islem_gecmisi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Tablo için indeksler `leverage_positions`
--
ALTER TABLE `leverage_positions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_status` (`user_id`,`status`),
  ADD KEY `idx_coin_status` (`coin_symbol`,`status`);

--
-- Tablo için indeksler `leverage_settings`
--
ALTER TABLE `leverage_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Tablo için indeksler `loglar`
--
ALTER TABLE `loglar`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Tablo için indeksler `para_cekme_talepleri`
--
ALTER TABLE `para_cekme_talepleri`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `onaylayan_admin_id` (`onaylayan_admin_id`);

--
-- Tablo için indeksler `para_yatirma_talepleri`
--
ALTER TABLE `para_yatirma_talepleri`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `onaylayan_admin_id` (`onaylayan_admin_id`);

--
-- Tablo için indeksler `position_history`
--
ALTER TABLE `position_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `position_id` (`position_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Tablo için indeksler `sistem_ayarlari`
--
ALTER TABLE `sistem_ayarlari`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ayar_adi` (`ayar_adi`);

--
-- Tablo için indeksler `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `admin_islem_loglari`
--
ALTER TABLE `admin_islem_loglari`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Tablo için AUTO_INCREMENT değeri `coins`
--
ALTER TABLE `coins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- Tablo için AUTO_INCREMENT değeri `coin_islemleri`
--
ALTER TABLE `coin_islemleri`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- Tablo için AUTO_INCREMENT değeri `coin_kategorileri`
--
ALTER TABLE `coin_kategorileri`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Tablo için AUTO_INCREMENT değeri `coin_price_history`
--
ALTER TABLE `coin_price_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `faturalar`
--
ALTER TABLE `faturalar`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Tablo için AUTO_INCREMENT değeri `kullanici_islem_gecmisi`
--
ALTER TABLE `kullanici_islem_gecmisi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- Tablo için AUTO_INCREMENT değeri `leverage_positions`
--
ALTER TABLE `leverage_positions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Tablo için AUTO_INCREMENT değeri `leverage_settings`
--
ALTER TABLE `leverage_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `loglar`
--
ALTER TABLE `loglar`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91;

--
-- Tablo için AUTO_INCREMENT değeri `para_cekme_talepleri`
--
ALTER TABLE `para_cekme_talepleri`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Tablo için AUTO_INCREMENT değeri `para_yatirma_talepleri`
--
ALTER TABLE `para_yatirma_talepleri`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Tablo için AUTO_INCREMENT değeri `position_history`
--
ALTER TABLE `position_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- Tablo için AUTO_INCREMENT değeri `sistem_ayarlari`
--
ALTER TABLE `sistem_ayarlari`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- Tablo için AUTO_INCREMENT değeri `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `admin_islem_loglari`
--
ALTER TABLE `admin_islem_loglari`
  ADD CONSTRAINT `admin_islem_loglari_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Tablo kısıtlamaları `coins`
--
ALTER TABLE `coins`
  ADD CONSTRAINT `coins_ibfk_1` FOREIGN KEY (`kategori_id`) REFERENCES `coin_kategorileri` (`id`) ON DELETE SET NULL;

--
-- Tablo kısıtlamaları `coin_islemleri`
--
ALTER TABLE `coin_islemleri`
  ADD CONSTRAINT `coin_islemleri_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `coin_islemleri_ibfk_2` FOREIGN KEY (`coin_id`) REFERENCES `coins` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `coin_price_history`
--
ALTER TABLE `coin_price_history`
  ADD CONSTRAINT `coin_price_history_ibfk_1` FOREIGN KEY (`coin_id`) REFERENCES `coins` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `faturalar`
--
ALTER TABLE `faturalar`
  ADD CONSTRAINT `faturalar_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `kullanici_islem_gecmisi`
--
ALTER TABLE `kullanici_islem_gecmisi`
  ADD CONSTRAINT `kullanici_islem_gecmisi_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `leverage_positions`
--
ALTER TABLE `leverage_positions`
  ADD CONSTRAINT `leverage_positions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `leverage_settings`
--
ALTER TABLE `leverage_settings`
  ADD CONSTRAINT `leverage_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `loglar`
--
ALTER TABLE `loglar`
  ADD CONSTRAINT `loglar_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Tablo kısıtlamaları `para_cekme_talepleri`
--
ALTER TABLE `para_cekme_talepleri`
  ADD CONSTRAINT `para_cekme_talepleri_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `para_cekme_talepleri_ibfk_2` FOREIGN KEY (`onaylayan_admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Tablo kısıtlamaları `para_yatirma_talepleri`
--
ALTER TABLE `para_yatirma_talepleri`
  ADD CONSTRAINT `para_yatirma_talepleri_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `para_yatirma_talepleri_ibfk_2` FOREIGN KEY (`onaylayan_admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `para_yatirma_talepleri_ibfk_3` FOREIGN KEY (`onaylayan_admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Tablo kısıtlamaları `position_history`
--
ALTER TABLE `position_history`
  ADD CONSTRAINT `position_history_ibfk_1` FOREIGN KEY (`position_id`) REFERENCES `leverage_positions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `position_history_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
