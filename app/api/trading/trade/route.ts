import { NextRequest, NextResponse } from 'next/server'
import { getServerSession } from 'next-auth'
import { authOptions } from '@/lib/auth'
import prisma, { withTransaction } from '@/lib/prisma'
import { z } from 'zod'

const tradeSchema = z.object({
  coinId: z.number().positive('Geçersiz coin ID'),
  type: z.enum(['BUY', 'SELL'], { errorMap: () => ({ message: 'İşlem tipi BUY veya SELL olmalıdır' }) }),
  amount: z.number().positive('Miktar pozitif olmalıdır'),
  price: z.number().positive('Fiyat pozitif olmalıdır').optional(),
})

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
    const validatedData = tradeSchema.parse(body)
    
    const { coinId, type, amount, price } = validatedData
    const userId = session.user.id
    
    // Get coin information
    const coin = await prisma.coin.findUnique({
      where: { id: coinId },
      select: {
        id: true,
        name: true,
        symbol: true,
        currentPrice: true,
        isActive: true,
      },
    })
    
    if (!coin || !coin.isActive) {
      return NextResponse.json(
        { error: 'Coin bulunamadı veya aktif değil' },
        { status: 400 }
      )
    }
    
    const tradePrice = price || Number(coin.currentPrice)
    const totalAmount = amount * tradePrice
    
    // Execute trade in transaction
    const result = await withTransaction(async (tx) => {
      // Get current user balance
      const user = await tx.user.findUnique({
        where: { id: userId },
        select: { balance: true },
      })
      
      if (!user) {
        throw new Error('Kullanıcı bulunamadı')
      }
      
      const currentBalance = Number(user.balance)
      
      if (type === 'BUY') {
        // Check if user has enough balance
        if (currentBalance < totalAmount) {
          throw new Error('Yetersiz bakiye')
        }
        
        // Deduct balance
        await tx.user.update({
          where: { id: userId },
          data: { balance: currentBalance - totalAmount },
        })
        
        // Create buy transaction
        const transaction = await tx.coinTransaction.create({
          data: {
            userId,
            coinId,
            type: 'BUY',
            amount,
            price: tradePrice,
          },
        })
        
        // Add to transaction history
        await tx.transactionHistory.create({
          data: {
            userId,
            type: 'COIN_BUY',
            details: `${coin.symbol} satın alındı - ${amount} adet @ ₺${tradePrice}`,
            amount: totalAmount,
            previousBalance: currentBalance,
            newBalance: currentBalance - totalAmount,
          },
        })
        
        return {
          transaction,
          newBalance: currentBalance - totalAmount,
          message: `${amount} ${coin.symbol} başarıyla satın alındı`,
        }
        
      } else { // SELL
        // Get user's coin holdings
        const holdings = await tx.coinTransaction.groupBy({
          by: ['coinId'],
          where: {
            userId,
            coinId,
          },
          _sum: {
            amount: true,
          },
        })
        
        const totalHoldings = holdings[0]?._sum.amount || 0
        
        if (Number(totalHoldings) < amount) {
          throw new Error('Yetersiz coin miktarı')
        }
        
        // Add balance
        await tx.user.update({
          where: { id: userId },
          data: { balance: currentBalance + totalAmount },
        })
        
        // Create sell transaction (negative amount)
        const transaction = await tx.coinTransaction.create({
          data: {
            userId,
            coinId,
            type: 'SELL',
            amount: -amount, // Negative for sell
            price: tradePrice,
          },
        })
        
        // Add to transaction history
        await tx.transactionHistory.create({
          data: {
            userId,
            type: 'COIN_SELL',
            details: `${coin.symbol} satıldı - ${amount} adet @ ₺${tradePrice}`,
            amount: totalAmount,
            previousBalance: currentBalance,
            newBalance: currentBalance + totalAmount,
          },
        })
        
        return {
          transaction,
          newBalance: currentBalance + totalAmount,
          message: `${amount} ${coin.symbol} başarıyla satıldı`,
        }
      }
    })
    
    // Log the trade
    await prisma.log.create({
      data: {
        userId,
        type: 'COIN_TRADE',
        details: `${type} ${amount} ${coin.symbol} @ ₺${tradePrice}`,
      },
    })
    
    return NextResponse.json({
      success: true,
      message: result.message,
      data: {
        transactionId: result.transaction.id,
        type,
        coin: {
          id: coin.id,
          name: coin.name,
          symbol: coin.symbol,
        },
        amount,
        price: tradePrice,
        total: totalAmount,
        newBalance: result.newBalance,
      },
    })
    
  } catch (error) {
    console.error('Trade error:', error)
    
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
    const limit = parseInt(searchParams.get('limit') || '50')
    const offset = parseInt(searchParams.get('offset') || '0')
    
    // Get user's transaction history
    const transactions = await prisma.coinTransaction.findMany({
      where: { userId: session.user.id },
      include: {
        coin: {
          select: {
            id: true,
            name: true,
            symbol: true,
            logoUrl: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
      skip: offset,
    })
    
    const transformedTransactions = transactions.map(tx => ({
      id: tx.id,
      type: tx.type,
      coin: {
        id: tx.coin.id,
        name: tx.coin.name,
        symbol: tx.coin.symbol,
        logo: tx.coin.logoUrl,
      },
      amount: Math.abs(Number(tx.amount)),
      price: Number(tx.price),
      total: Math.abs(Number(tx.amount)) * Number(tx.price),
      createdAt: tx.createdAt,
    }))
    
    return NextResponse.json({
      success: true,
      data: transformedTransactions,
      count: transformedTransactions.length,
    })
    
  } catch (error) {
    console.error('Get trades error:', error)
    return NextResponse.json(
      { error: 'İşlem geçmişi yüklenemedi' },
      { status: 500 }
    )
  }
}