# 🏛️ GlobalTradePro - Modern Trading Platform

Modern, güvenli ve güvenilir bir yatırım/trading platformu. Next.js 14, TypeScript, Prisma ORM ve Tailwind CSS ile geliştirilmiştir.

## ✨ Özellikler

### 🎯 Ana Özellikler
- **Modern Next.js 14 App Router** - Server-side rendering ve optimizasyonlar
- **TypeScript** - Tip güvenliği ve geliştirici deneyimi
- **Prisma ORM** - Modern veritabanı yönetimi
- **NextAuth.js** - Güvenli authentication sistemi
- **Tailwind CSS** - Modern ve responsive tasarım
- **Real-time Trading** - WebSocket ile canlı fiyat takibi
- **Kaldıraçlı İşlemler** - Forex ve kripto leverage trading
- **Admin Panel** - Kapsamlı yönetim paneli

### 🎨 Trading Özellikleri
- **Kripto Trading** - Bitcoin, Ethereum ve 100+ altcoin
- **Forex Trading** - Major, minor ve exotic döviz çiftleri
- **Leverage Trading** - 100x'e kadar kaldıraç desteği
- **Real-time Charts** - Profesyonel grafik araçları
- **Portföy Yönetimi** - Detaylı kar/zarar takibi
- **Para Yatırma/Çekme** - Papara, kredi kartı, havale
- **Fatura Sistemi** - Otomatik fatura oluşturma

### 🏗️ Teknik Özellikler
- **Server-Side Rendering** - SEO optimizasyonu
- **API Routes** - RESTful backend API'ler
- **Database Migrations** - Prisma ile veritabanı yönetimi
- **Type Safety** - Tam TypeScript desteği
- **Responsive Design** - Mobil ve desktop uyumlu
- **Performance Optimized** - Next.js optimizasyonları
- **Security** - Modern güvenlik standartları

## 🚀 Kurulum

### Gereksinimler
- Node.js 18.0 veya üzeri
- MySQL 8.0 veya üzeri
- npm veya yarn paket yöneticisi

### 1. Projeyi Klonlayın
```bash
git clone https://github.com/your-username/nextjs-trading-platform.git
cd nextjs-trading-platform
```

### 2. Bağımlılıkları Yükleyin
```bash
npm install
# veya
yarn install
```

### 3. Ortam Değişkenlerini Ayarlayın
`.env.example` dosyasını `.env` olarak kopyalayın ve gerekli değerleri doldurun:

```bash
cp .env.example .env
```

`.env` dosyasını düzenleyin:
```env
# Database
DATABASE_URL="mysql://username:password@localhost:3306/trading_platform"

# NextAuth
NEXTAUTH_SECRET="your-secret-key-here"
NEXTAUTH_URL="http://localhost:3000"

# External APIs
COINGECKO_API_KEY="your-coingecko-api-key"
FOREX_API_KEY="your-forex-api-key"

# Payment Gateways
PAPARA_API_KEY="your-papara-api-key"
PAPARA_SECRET="your-papara-secret"
```

### 4. Veritabanını Hazırlayın
```bash
# Prisma client'ı oluşturun
npx prisma generate

# Veritabanı migration'larını çalıştırın
npx prisma db push

# (Opsiyonel) Seed data ekleyin
npx prisma db seed
```

### 5. Geliştirme Sunucusunu Başlatın
```bash
npm run dev
# veya
yarn dev
```

Uygulama [http://localhost:3000](http://localhost:3000) adresinde çalışacaktır.

## 📁 Proje Yapısı

```
nextjs-trading-platform/
├── app/                          # Next.js 14 App Router
│   ├── (auth)/                   # Auth group routes
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── (dashboard)/              # Dashboard group routes
│   │   ├── trading/page.tsx
│   │   ├── portfolio/page.tsx
│   │   ├── deposits/page.tsx
│   │   └── profile/page.tsx
│   ├── (admin)/                  # Admin group routes
│   │   ├── users/page.tsx
│   │   ├── deposits/page.tsx
│   │   └── settings/page.tsx
│   ├── api/                      # API Routes
│   │   ├── auth/
│   │   ├── trading/
│   │   ├── deposits/
│   │   └── admin/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/                   # React Components
│   ├── ui/                      # Shadcn/ui components
│   ├── trading/                 # Trading specific components
│   ├── charts/                  # Chart components
│   └── layout/                  # Layout components
├── lib/                         # Utilities
│   ├── prisma.ts
│   ├── auth.ts
│   ├── utils.ts
│   └── validations.ts
├── prisma/                      # Database
│   ├── schema.prisma
│   └── migrations/
├── types/                       # TypeScript types
├── hooks/                       # Custom React hooks
└── public/                      # Static assets
```

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/register` - Kullanıcı kaydı
- `POST /api/auth/login` - Kullanıcı girişi (NextAuth)
- `POST /api/auth/logout` - Kullanıcı çıkışı

### Trading
- `GET /api/trading/coins` - Coin listesi
- `POST /api/trading/trade` - Al/sat işlemi
- `GET /api/trading/trade` - İşlem geçmişi
- `GET /api/trading/leverage` - Kaldıraçlı pozisyonlar
- `POST /api/trading/leverage` - Pozisyon aç/kapat

### Deposits & Withdrawals
- `GET /api/deposits` - Para yatırma talepleri
- `POST /api/deposits` - Yeni para yatırma talebi
- `GET /api/withdrawals` - Para çekme talepleri
- `POST /api/withdrawals` - Yeni para çekme talebi

### Admin
- `GET /api/admin/users` - Kullanıcı listesi
- `GET /api/admin/deposits` - Bekleyen yatırımlar
- `POST /api/admin/deposits/approve` - Yatırım onaylama
- `GET /api/admin/stats` - Dashboard istatistikleri

## 🛠️ Geliştirme

### Kod Kalitesi
```bash
# TypeScript kontrol
npm run type-check

# Linting
npm run lint

# Formatting (Prettier)
npm run format
```

### Veritabanı Yönetimi
```bash
# Prisma Studio (GUI)
npx prisma studio

# Migration oluştur
npx prisma migrate dev --name migration-name

# Database reset
npx prisma migrate reset
```

### Build ve Deploy
```bash
# Production build
npm run build

# Production sunucu
npm run start
```

## 🔐 Güvenlik

- **NextAuth.js** - Güvenli authentication
- **JWT Tokens** - Session yönetimi
- **Password Hashing** - bcryptjs ile şifre hashleme
- **Input Validation** - Zod ile veri doğrulama
- **SQL Injection** - Prisma ORM koruması
- **XSS Protection** - React built-in koruması
- **CSRF Protection** - NextAuth built-in koruması

## 📱 Responsive Design

- **Desktop** - 1200px+
- **Tablet** - 768px - 1199px
- **Mobile** - 320px - 767px
- **Tailwind Breakpoints** - Responsive tasarım sistemi

## 🌐 Deployment

### Vercel (Önerilen)
1. GitHub'a push yapın
2. Vercel'e bağlayın
3. Environment variables ekleyin
4. Deploy edin

### Docker
```bash
# Docker image oluştur
docker build -t trading-platform .

# Container çalıştır
docker run -p 3000:3000 trading-platform
```

### Manual Deployment
```bash
# Build
npm run build

# Start
npm run start
```

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 Destek

- **Email**: support@globaltradepro.com
- **Discord**: [GlobalTradePro Community](https://discord.gg/globaltradepro)
- **GitHub Issues**: [Issues](https://github.com/your-username/nextjs-trading-platform/issues)

## 🙏 Teşekkürler

- [Next.js](https://nextjs.org/) - React framework
- [Prisma](https://prisma.io/) - Database ORM
- [NextAuth.js](https://next-auth.js.org/) - Authentication
- [Tailwind CSS](https://tailwindcss.com/) - CSS framework
- [Radix UI](https://radix-ui.com/) - UI components
- [Lucide](https://lucide.dev/) - Icons

---

**© 2024 GlobalTradePro - Modern Trading Platform**

*Bu proje modern web standartları kullanılarak, Next.js 14 ve TypeScript ile geliştirilmiştir.*