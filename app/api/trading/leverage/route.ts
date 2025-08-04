import { NextRequest, NextResponse } from 'next/server'
import { getServerSession } from 'next-auth'
import { authOptions } from '@/lib/auth'
import prisma, { withTransaction } from '@/lib/prisma'
import { z } from 'zod'
import { calculateLiquidationPrice, calculatePnL } from '@/lib/utils'

const openPositionSchema = z.object({
  coinSymbol: z.string().min(1, 'Coin sembolü gereklidir'),
  positionType: z.enum(['LONG', 'SHORT'], { errorMap: () => ({ message: 'Pozisyon tipi LONG veya SHORT olmalıdır' }) }),
  leverageRatio: z.number().min(1).max(100, 'Kaldıraç 1-100 arasında olmalıdır'),
  investedAmount: z.number().positive('Yatırım miktarı pozitif olmalıdır'),
  entryPrice: z.number().positive('Giriş fiyatı pozitif olmalıdır'),
})

const closePositionSchema = z.object({
  positionId: z.number().positive('Geçersiz pozisyon ID'),
  closePrice: z.number().positive('Kapanış fiyatı pozitif olmalıdır'),
})

// GET - Get user's leverage positions
export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session) {
      return NextResponse.json(
        { error: 'Oturum açmanız gerekiyor' },
        { status: 401 }
      )
    }
    
    const { searchParams } = new URL(request.url)
    const status = searchParams.get('status') || 'OPEN'
    const limit = parseInt(searchParams.get('limit') || '50')
    
    const positions = await prisma.leveragePosition.findMany({
      where: {
        userId: session.user.id,
        status: status as any,
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
    })
    
    // Calculate current PnL for open positions
    const positionsWithPnL = positions.map(position => {
      const currentPnl = calculatePnL(
        Number(position.entryPrice),
        Number(position.currentPrice || position.entryPrice),
        Number(position.positionSize),
        position.positionType as 'LONG' | 'SHORT'
      )
      
      const pnlPercentage = (currentPnl / Number(position.investedAmount)) * 100
      
      return {
        id: position.id,
        coinSymbol: position.coinSymbol,
        positionType: position.positionType,
        leverageRatio: Number(position.leverageRatio),
        entryPrice: Number(position.entryPrice),
        currentPrice: Number(position.currentPrice || position.entryPrice),
        positionSize: Number(position.positionSize),
        investedAmount: Number(position.investedAmount),
        liquidationPrice: Number(position.liquidationPrice),
        unrealizedPnl: currentPnl,
        realizedPnl: Number(position.realizedPnl),
        pnlPercentage,
        status: position.status,
        createdAt: position.createdAt,
        closedAt: position.closedAt,
      }
    })
    
    return NextResponse.json({
      success: true,
      data: positionsWithPnL,
      count: positionsWithPnL.length,
    })
    
  } catch (error) {
    console.error('Get leverage positions error:', error)
    return NextResponse.json(
      { error: 'Pozisyonlar yüklenemedi' },
      { status: 500 }
    )
  }
}

// POST - Open new leverage position
export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session) {
      return NextResponse.json(
        { error: 'Oturum açmanız gerekiyor' },
        { status: 401 }
      )
    }
    
    const body = await request.json()
    const { action } = body
    
    if (action === 'open') {
      return await openPosition(session.user.id, body)
    } else if (action === 'close') {
      return await closePosition(session.user.id, body)
    } else if (action === 'update_prices') {
      return await updatePositionPrices(session.user.id, body)
    } else {
      return NextResponse.json(
        { error: 'Geçersiz işlem' },
        { status: 400 }
      )
    }
    
  } catch (error) {
    console.error('Leverage trading error:', error)
    
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: error.errors[0].message },
        { status: 400 }
      )
    }
    
    if (error instanceof Error) {
      return NextResponse.json(
        { error: error.message },
        { status: 400 }
      )
    }
    
    return NextResponse.json(
      { error: 'İşlem başarısız oldu' },
      { status: 500 }
    )
  }
}

async function openPosition(userId: number, data: any) {
  const validatedData = openPositionSchema.parse(data)
  const { coinSymbol, positionType, leverageRatio, investedAmount, entryPrice } = validatedData
  
  // Calculate position size
  const positionSize = (investedAmount * leverageRatio) / entryPrice
  
  // Calculate liquidation price
  const liquidationPrice = calculateLiquidationPrice(
    entryPrice,
    leverageRatio,
    positionType as 'LONG' | 'SHORT',
    0.8 // 80% loss triggers liquidation
  )
  
  const result = await withTransaction(async (tx) => {
    // Check user balance
    const user = await tx.user.findUnique({
      where: { id: userId },
      select: { balance: true },
    })
    
    if (!user) {
      throw new Error('Kullanıcı bulunamadı')
    }
    
    const currentBalance = Number(user.balance)
    
    if (currentBalance < investedAmount) {
      throw new Error('Yetersiz bakiye')
    }
    
    // Deduct invested amount from balance
    await tx.user.update({
      where: { id: userId },
      data: { balance: currentBalance - investedAmount },
    })
    
    // Create leverage position
    const position = await tx.leveragePosition.create({
      data: {
        userId,
        coinSymbol,
        positionType: positionType as any,
        leverageRatio,
        entryPrice,
        positionSize,
        investedAmount,
        currentPrice: entryPrice,
        liquidationPrice,
        status: 'OPEN',
      },
    })
    
    // Add to transaction history
    await tx.transactionHistory.create({
      data: {
        userId,
        type: 'COIN_BUY', // Using existing enum
        details: `Kaldıraçlı pozisyon açıldı: ${coinSymbol} ${positionType} ${leverageRatio}x`,
        amount: investedAmount,
        previousBalance: currentBalance,
        newBalance: currentBalance - investedAmount,
      },
    })
    
    return {
      position,
      newBalance: currentBalance - investedAmount,
    }
  })
  
  // Log the action
  await prisma.log.create({
    data: {
      userId,
      type: 'COIN_TRADE',
      details: `Opened leverage position: ${coinSymbol} ${positionType} ${leverageRatio}x`,
    },
  })
  
  return NextResponse.json({
    success: true,
    message: 'Pozisyon başarıyla açıldı',
    data: {
      positionId: result.position.id,
      coinSymbol,
      positionType,
      leverageRatio,
      entryPrice,
      positionSize,
      investedAmount,
      liquidationPrice,
      newBalance: result.newBalance,
    },
  })
}

async function closePosition(userId: number, data: any) {
  const validatedData = closePositionSchema.parse(data)
  const { positionId, closePrice } = validatedData
  
  const result = await withTransaction(async (tx) => {
    // Get position
    const position = await tx.leveragePosition.findFirst({
      where: {
        id: positionId,
        userId,
        status: 'OPEN',
      },
    })
    
    if (!position) {
      throw new Error('Pozisyon bulunamadı veya zaten kapatılmış')
    }
    
    // Calculate PnL
    const pnl = calculatePnL(
      Number(position.entryPrice),
      closePrice,
      Number(position.positionSize),
      position.positionType as 'LONG' | 'SHORT'
    )
    
    const finalAmount = Number(position.investedAmount) + pnl
    
    // Get current user balance
    const user = await tx.user.findUnique({
      where: { id: userId },
      select: { balance: true },
    })
    
    if (!user) {
      throw new Error('Kullanıcı bulunamadı')
    }
    
    const currentBalance = Number(user.balance)
    
    // Update user balance
    await tx.user.update({
      where: { id: userId },
      data: { balance: currentBalance + finalAmount },
    })
    
    // Close position
    await tx.leveragePosition.update({
      where: { id: positionId },
      data: {
        status: 'CLOSED',
        closePrice,
        realizedPnl: pnl,
        closedAt: new Date(),
      },
    })
    
    // Add to transaction history
    await tx.transactionHistory.create({
      data: {
        userId,
        type: 'COIN_SELL', // Using existing enum
        details: `Kaldıraçlı pozisyon kapatıldı: ${position.coinSymbol} PnL: ₺${pnl.toFixed(2)}`,
        amount: finalAmount,
        previousBalance: currentBalance,
        newBalance: currentBalance + finalAmount,
      },
    })
    
    return {
      pnl,
      finalAmount,
      newBalance: currentBalance + finalAmount,
    }
  })
  
  // Log the action
  await prisma.log.create({
    data: {
      userId,
      type: 'COIN_TRADE',
      details: `Closed leverage position: ID ${positionId}, PnL: ₺${result.pnl.toFixed(2)}`,
    },
  })
  
  return NextResponse.json({
    success: true,
    message: 'Pozisyon başarıyla kapatıldı',
    data: {
      positionId,
      closePrice,
      pnl: result.pnl,
      finalAmount: result.finalAmount,
      newBalance: result.newBalance,
    },
  })
}

async function updatePositionPrices(userId: number, data: any) {
  const { prices } = data
  
  if (!prices || typeof prices !== 'object') {
    throw new Error('Fiyat bilgileri gereklidir')
  }
  
  // Update positions with new prices
  for (const [coinSymbol, currentPrice] of Object.entries(prices)) {
    if (typeof currentPrice !== 'number') continue
    
    await prisma.leveragePosition.updateMany({
      where: {
        userId,
        coinSymbol,
        status: 'OPEN',
      },
      data: {
        currentPrice,
        // Calculate unrealized PnL
        unrealizedPnl: {
          // This would need a more complex calculation in real implementation
          // For now, we'll calculate it in the GET request
        },
      },
    })
    
    // Check for liquidations
    const positions = await prisma.leveragePosition.findMany({
      where: {
        userId,
        coinSymbol,
        status: 'OPEN',
      },
    })
    
    for (const position of positions) {
      const shouldLiquidate = 
        (position.positionType === 'LONG' && currentPrice <= Number(position.liquidationPrice)) ||
        (position.positionType === 'SHORT' && currentPrice >= Number(position.liquidationPrice))
      
      if (shouldLiquidate) {
        // Liquidate position
        const pnl = calculatePnL(
          Number(position.entryPrice),
          currentPrice,
          Number(position.positionSize),
          position.positionType as 'LONG' | 'SHORT'
        )
        
        await prisma.leveragePosition.update({
          where: { id: position.id },
          data: {
            status: 'LIQUIDATED',
            closePrice: currentPrice,
            realizedPnl: pnl,
            closedAt: new Date(),
          },
        })
        
        // Log liquidation
        await prisma.log.create({
          data: {
            userId,
            type: 'COIN_TRADE',
            details: `Position liquidated: ${coinSymbol} PnL: ₺${pnl.toFixed(2)}`,
          },
        })
      }
    }
  }
  
  return NextResponse.json({
    success: true,
    message: 'Fiyatlar güncellendi',
  })
}