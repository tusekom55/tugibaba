'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { 
  TrendingUp, 
  Shield, 
  Zap, 
  BarChart3, 
  Users, 
  Globe,
  ArrowRight,
  CheckCircle,
  Star,
  Play
} from 'lucide-react'

export function LandingPage() {
  const [currentSlide, setCurrentSlide] = useState(0)
  
  const heroSlides = [
    {
      title: "Profesyonel Trading Platformu",
      subtitle: "Kripto para ve forex piyasalarında güvenli yatırım",
      description: "Modern arayüz ve gelişmiş analiz araçları ile trading deneyiminizi üst seviyeye taşıyın.",
      image: "/hero-1.jpg"
    },
    {
      title: "Kaldıraçlı İşlemler",
      subtitle: "Yüksek kaldıraç oranları ile kar potansiyelinizi artırın",
      description: "100x'e kadar kaldıraç ile pozisyon alın ve piyasa hareketlerinden maksimum fayda sağlayın.",
      image: "/hero-2.jpg"
    },
    {
      title: "Gerçek Zamanlı Analiz",
      subtitle: "Profesyonel grafik araçları ve teknik analiz",
      description: "Canlı fiyat takibi, gelişmiş göstergeler ve otomatik trading seçenekleri.",
      image: "/hero-3.jpg"
    }
  ]
  
  const services = [
    {
      icon: TrendingUp,
      title: "Kripto Trading",
      description: "Bitcoin, Ethereum ve 100+ altcoin ile spot ve vadeli işlemler"
    },
    {
      icon: BarChart3,
      title: "Forex Trading",
      description: "Major, minor ve exotic döviz çiftleri ile 24/5 trading"
    },
    {
      icon: Zap,
      title: "Kaldıraçlı İşlemler",
      description: "100x'e kadar kaldıraç ile pozisyon büyütme imkanı"
    }
  ]
  
  const features = [
    "Anlık para yatırma/çekme",
    "7/24 müşteri desteği",
    "Mobil uygulama",
    "Güvenli cüzdan",
    "Profesyonel analiz araçları",
    "Düşük komisyon oranları"
  ]
  
  const stats = [
    { label: "Aktif Kullanıcı", value: "50K+" },
    { label: "Günlük İşlem Hacmi", value: "$2.5M" },
    { label: "Desteklenen Coin", value: "150+" },
    { label: "Ülke", value: "25+" }
  ]
  
  // Auto slide functionality
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % heroSlides.length)
    }, 5000)
    
    return () => clearInterval(interval)
  }, [heroSlides.length])
  
  return (
    <div className="min-h-screen">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-background/80 backdrop-blur-xl border-b border-white/10">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-gradient-primary rounded-lg flex items-center justify-center">
                <TrendingUp className="w-5 h-5 text-white" />
              </div>
              <span className="text-xl font-bold gradient-primary bg-clip-text text-transparent">
                GlobalTradePro
              </span>
            </div>
            
            <div className="hidden md:flex items-center gap-8">
              <Link href="#features" className="text-muted-foreground hover:text-foreground transition-colors">
                Özellikler
              </Link>
              <Link href="#services" className="text-muted-foreground hover:text-foreground transition-colors">
                Hizmetler
              </Link>
              <Link href="#about" className="text-muted-foreground hover:text-foreground transition-colors">
                Hakkımızda
              </Link>
              <Link href="#contact" className="text-muted-foreground hover:text-foreground transition-colors">
                İletişim
              </Link>
            </div>
            
            <div className="flex items-center gap-4">
              <Link href="/auth/login">
                <Button variant="ghost">Giriş Yap</Button>
              </Link>
              <Link href="/auth/register">
                <Button className="gradient-primary">
                  Hesap Aç
                  <ArrowRight className="w-4 h-4 ml-2" />
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </nav>
      
      {/* Hero Section */}
      <section className="relative h-screen flex items-center justify-center overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-r from-background via-background/80 to-transparent z-10" />
        
        {/* Background Slides */}
        <div className="absolute inset-0">
          {heroSlides.map((slide, index) => (
            <div
              key={index}
              className={`absolute inset-0 transition-opacity duration-1000 ${
                index === currentSlide ? 'opacity-100' : 'opacity-0'
              }`}
            >
              <div className="absolute inset-0 bg-gradient-to-r from-background to-background/20" />
              <div className="w-full h-full bg-gradient-to-br from-blue-900/20 to-purple-900/20" />
            </div>
          ))}
        </div>
        
        {/* Content */}
        <div className="container mx-auto px-4 z-20">
          <div className="max-w-4xl">
            <div className="animate-fade-in">
              <span className="text-primary font-semibold text-lg mb-4 block">
                {heroSlides[currentSlide].subtitle}
              </span>
              <h1 className="text-5xl md:text-7xl font-bold mb-6 leading-tight">
                {heroSlides[currentSlide].title}
              </h1>
              <p className="text-xl text-muted-foreground mb-8 max-w-2xl">
                {heroSlides[currentSlide].description}
              </p>
              
              <div className="flex flex-col sm:flex-row gap-4">
                <Link href="/auth/register">
                  <Button size="lg" className="gradient-primary text-lg px-8">
                    Hemen Başla
                    <ArrowRight className="w-5 h-5 ml-2" />
                  </Button>
                </Link>
                <Button size="lg" variant="outline" className="text-lg px-8">
                  <Play className="w-5 h-5 mr-2" />
                  Demo İzle
                </Button>
              </div>
            </div>
          </div>
        </div>
        
        {/* Slide Indicators */}
        <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 flex gap-2 z-20">
          {heroSlides.map((_, index) => (
            <button
              key={index}
              onClick={() => setCurrentSlide(index)}
              className={`w-3 h-3 rounded-full transition-all ${
                index === currentSlide ? 'bg-primary w-8' : 'bg-white/30'
              }`}
            />
          ))}
        </div>
      </section>
      
      {/* Stats Section */}
      <section className="py-16 border-b border-white/10">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {stats.map((stat, index) => (
              <div key={index} className="text-center">
                <div className="text-3xl md:text-4xl font-bold text-primary mb-2">
                  {stat.value}
                </div>
                <div className="text-muted-foreground">
                  {stat.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
      
      {/* Services Section */}
      <section id="services" className="py-20">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4">Trading Hizmetlerimiz</h2>
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              Profesyonel trading araçları ve güvenilir platform ile yatırım hedeflerinize ulaşın
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {services.map((service, index) => (
              <Card key={index} className="glass-card hover:bg-white/10 transition-all duration-300 group">
                <CardContent className="p-8 text-center">
                  <div className="w-16 h-16 bg-gradient-primary rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform">
                    <service.icon className="w-8 h-8 text-white" />
                  </div>
                  <h3 className="text-xl font-semibold mb-4">{service.title}</h3>
                  <p className="text-muted-foreground">{service.description}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>
      
      {/* Features Section */}
      <section id="features" className="py-20 bg-white/5">
        <div className="container mx-auto px-4">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            <div>
              <h2 className="text-4xl font-bold mb-6">
                Neden GlobalTradePro?
              </h2>
              <p className="text-xl text-muted-foreground mb-8">
                Modern teknoloji ve güvenilir altyapı ile trading deneyiminizi mükemmelleştirin
              </p>
              
              <div className="grid gap-4">
                {features.map((feature, index) => (
                  <div key={index} className="flex items-center gap-3">
                    <CheckCircle className="w-5 h-5 text-primary flex-shrink-0" />
                    <span>{feature}</span>
                  </div>
                ))}
              </div>
              
              <div className="mt-8">
                <Link href="/auth/register">
                  <Button size="lg" className="gradient-primary">
                    Ücretsiz Hesap Aç
                    <ArrowRight className="w-5 h-5 ml-2" />
                  </Button>
                </Link>
              </div>
            </div>
            
            <div className="relative">
              <div className="glass-card p-8">
                <div className="space-y-6">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-muted-foreground">BTC/USDT</span>
                    <span className="text-trading-up font-semibold">+2.45%</span>
                  </div>
                  <div className="text-3xl font-bold">$67,234.56</div>
                  <div className="h-32 bg-gradient-to-r from-trading-up/20 to-trading-up/5 rounded-lg flex items-end justify-center">
                    <div className="text-xs text-muted-foreground">Trading Chart Preview</div>
                  </div>
                  <div className="flex gap-2">
                    <Button className="btn-buy flex-1">Satın Al</Button>
                    <Button className="btn-sell flex-1">Sat</Button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      
      {/* CTA Section */}
      <section className="py-20">
        <div className="container mx-auto px-4 text-center">
          <div className="max-w-3xl mx-auto">
            <h2 className="text-4xl font-bold mb-6">
              Trading Yolculuğunuza Başlayın
            </h2>
            <p className="text-xl text-muted-foreground mb-8">
              Ücretsiz hesap açın ve profesyonel trading platformumuzdan hemen yararlanmaya başlayın
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/auth/register">
                <Button size="lg" className="gradient-primary text-lg px-8">
                  Ücretsiz Hesap Aç
                  <ArrowRight className="w-5 h-5 ml-2" />
                </Button>
              </Link>
              <Link href="/auth/login">
                <Button size="lg" variant="outline" className="text-lg px-8">
                  Giriş Yap
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>
      
      {/* Footer */}
      <footer className="border-t border-white/10 py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center gap-2 mb-4">
                <div className="w-8 h-8 bg-gradient-primary rounded-lg flex items-center justify-center">
                  <TrendingUp className="w-5 h-5 text-white" />
                </div>
                <span className="text-xl font-bold">GlobalTradePro</span>
              </div>
              <p className="text-muted-foreground">
                Modern ve güvenilir trading platformu
              </p>
            </div>
            
            <div>
              <h4 className="font-semibold mb-4">Platform</h4>
              <div className="space-y-2 text-muted-foreground">
                <div>Kripto Trading</div>
                <div>Forex Trading</div>
                <div>Kaldıraçlı İşlemler</div>
                <div>Mobil Uygulama</div>
              </div>
            </div>
            
            <div>
              <h4 className="font-semibold mb-4">Destek</h4>
              <div className="space-y-2 text-muted-foreground">
                <div>Yardım Merkezi</div>
                <div>API Dokümantasyonu</div>
                <div>Canlı Destek</div>
                <div>İletişim</div>
              </div>
            </div>
            
            <div>
              <h4 className="font-semibold mb-4">Şirket</h4>
              <div className="space-y-2 text-muted-foreground">
                <div>Hakkımızda</div>
                <div>Güvenlik</div>
                <div>Gizlilik Politikası</div>
                <div>Kullanım Şartları</div>
              </div>
            </div>
          </div>
          
          <div className="border-t border-white/10 mt-8 pt-8 text-center text-muted-foreground">
            <p>&copy; 2024 GlobalTradePro. Tüm hakları saklıdır.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}