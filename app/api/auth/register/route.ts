import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'
import prisma from '@/lib/prisma'
import { hashPassword } from '@/lib/auth'
import { isValidEmail, isValidPhone, isValidTCNo } from '@/lib/utils'

const registerSchema = z.object({
  username: z.string().min(3, 'Kullanıcı adı en az 3 karakter olmalıdır').max(50),
  email: z.string().email('Geçersiz email adresi'),
  password: z.string().min(6, 'Şifre en az 6 karakter olmalıdır'),
  confirmPassword: z.string(),
  fullName: z.string().min(2, 'Ad soyad en az 2 karakter olmalıdır').max(100),
  phone: z.string().optional(),
  tcNo: z.string().optional(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Şifreler eşleşmiyor',
  path: ['confirmPassword'],
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validate input
    const validatedData = registerSchema.parse(body)
    
    // Additional validations
    if (!isValidEmail(validatedData.email)) {
      return NextResponse.json(
        { error: 'Geçersiz email formatı' },
        { status: 400 }
      )
    }
    
    if (validatedData.phone && !isValidPhone(validatedData.phone)) {
      return NextResponse.json(
        { error: 'Geçersiz telefon numarası formatı' },
        { status: 400 }
      )
    }
    
    if (validatedData.tcNo && !isValidTCNo(validatedData.tcNo)) {
      return NextResponse.json(
        { error: 'Geçersiz TC kimlik numarası' },
        { status: 400 }
      )
    }
    
    // Check if user already exists
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          { username: validatedData.username },
          { email: validatedData.email },
        ],
      },
    })
    
    if (existingUser) {
      if (existingUser.username === validatedData.username) {
        return NextResponse.json(
          { error: 'Bu kullanıcı adı zaten kullanılıyor' },
          { status: 400 }
        )
      }
      if (existingUser.email === validatedData.email) {
        return NextResponse.json(
          { error: 'Bu email adresi zaten kullanılıyor' },
          { status: 400 }
        )
      }
    }
    
    // Hash password
    const hashedPassword = await hashPassword(validatedData.password)
    
    // Create user
    const user = await prisma.user.create({
      data: {
        username: validatedData.username,
        email: validatedData.email,
        password: hashedPassword,
        fullName: validatedData.fullName,
        phone: validatedData.phone,
        tcNo: validatedData.tcNo,
        balance: 0,
        role: 'USER',
      },
      select: {
        id: true,
        username: true,
        email: true,
        fullName: true,
        createdAt: true,
      },
    })
    
    // Log the registration
    await prisma.log.create({
      data: {
        userId: user.id,
        type: 'API_UPDATE',
        details: `New user registered: ${user.username}`,
      },
    })
    
    // Create default trading settings
    await prisma.userTradingSettings.create({
      data: {
        userId: user.id,
        defaultLeverage: 10,
        defaultLotSize: 0.01,
        maxOpenPositions: 10,
        riskPerTrade: 2.0,
        notificationsEnabled: true,
      },
    })
    
    return NextResponse.json({
      success: true,
      message: 'Hesabınız başarıyla oluşturuldu',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        fullName: user.fullName,
      },
    })
    
  } catch (error) {
    console.error('Registration error:', error)
    
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: error.errors[0].message },
        { status: 400 }
      )
    }
    
    return NextResponse.json(
      { error: 'Kayıt işlemi başarısız oldu' },
      { status: 500 }
    )
  }
}