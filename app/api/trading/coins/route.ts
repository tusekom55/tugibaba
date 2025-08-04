import { NextRequest, NextResponse } from 'next/server'
import { getServerSession } from 'next-auth'
import { authOptions } from '@/lib/auth'
import prisma from '@/lib/prisma'

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
    const search = searchParams.get('search') || ''
    const limit = parseInt(searchParams.get('limit') || '50')
    const category = searchParams.get('category')
    
    // Build where clause
    const where: any = {
      isActive: true,
    }
    
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { symbol: { contains: search, mode: 'insensitive' } },
      ]
    }
    
    if (category) {
      where.category = {
        name: category,
      }
    }
    
    // Get coins with category information
    const coins = await prisma.coin.findMany({
      where,
      include: {
        category: {
          select: {
            id: true,
            name: true,
          },
        },
      },
      orderBy: [
        { sortOrder: 'asc' },
        { id: 'asc' },
      ],
      take: limit,
    })
    
    // Transform data for frontend
    const transformedCoins = coins.map(coin => ({
      id: coin.id,
      name: coin.name,
      symbol: coin.symbol,
      price: Number(coin.currentPrice),
      change24h: Number(coin.priceChange24h),
      marketCap: Number(coin.marketCap),
      logo: coin.logoUrl,
      category: coin.category?.name || 'Diğer',
      isApiActive: coin.apiActive,
      coingeckoId: coin.coingeckoId,
    }))
    
    return NextResponse.json({
      success: true,
      data: transformedCoins,
      count: transformedCoins.length,
    })
    
  } catch (error) {
    console.error('Coins API error:', error)
    return NextResponse.json(
      { error: 'Coinler yüklenemedi' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session || session.user.role !== 'ADMIN') {
      return NextResponse.json(
        { error: 'Yetkiniz bulunmuyor' },
        { status: 403 }
      )
    }
    
    const body = await request.json()
    const {
      name,
      symbol,
      categoryId,
      coingeckoId,
      logoUrl,
      description,
      currentPrice,
      apiActive,
      sortOrder,
    } = body
    
    // Validate required fields
    if (!name || !symbol) {
      return NextResponse.json(
        { error: 'Coin adı ve sembolü gereklidir' },
        { status: 400 }
      )
    }
    
    // Check if coin already exists
    const existingCoin = await prisma.coin.findFirst({
      where: {
        OR: [
          { symbol: symbol.toUpperCase() },
          { coingeckoId: coingeckoId || undefined },
        ],
      },
    })
    
    if (existingCoin) {
      return NextResponse.json(
        { error: 'Bu coin zaten mevcut' },
        { status: 400 }
      )
    }
    
    // Create new coin
    const coin = await prisma.coin.create({
      data: {
        name,
        symbol: symbol.toUpperCase(),
        categoryId: categoryId || null,
        coingeckoId: coingeckoId || null,
        logoUrl: logoUrl || null,
        description: description || null,
        currentPrice: currentPrice || 0,
        apiActive: apiActive || false,
        sortOrder: sortOrder || 0,
        isActive: true,
      },
      include: {
        category: true,
      },
    })
    
    // Log the action
    await prisma.adminLog.create({
      data: {
        adminId: session.user.id,
        type: 'COIN_ADD',
        targetId: coin.id,
        details: `Added new coin: ${coin.name} (${coin.symbol})`,
      },
    })
    
    return NextResponse.json({
      success: true,
      message: 'Coin başarıyla eklendi',
      data: {
        id: coin.id,
        name: coin.name,
        symbol: coin.symbol,
        price: Number(coin.currentPrice),
        category: coin.category?.name,
      },
    })
    
  } catch (error) {
    console.error('Add coin error:', error)
    return NextResponse.json(
      { error: 'Coin eklenemedi' },
      { status: 500 }
    )
  }
}