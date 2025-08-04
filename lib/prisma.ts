// Temporarily disabled for deployment without database
// import { PrismaClient } from '@prisma/client'

// declare global {
//   var prisma: PrismaClient | undefined
// }

// const prisma = globalThis.prisma || new PrismaClient({
//   log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
// })

// if (process.env.NODE_ENV !== 'production') {
//   globalThis.prisma = prisma
// }

// Mock prisma for deployment without database
const prisma = {
  user: {
    findUnique: () => Promise.resolve(null),
    findMany: () => Promise.resolve([]),
    create: () => Promise.resolve({}),
    update: () => Promise.resolve({}),
    delete: () => Promise.resolve({}),
  },
  coin: {
    findMany: () => Promise.resolve([]),
    findUnique: () => Promise.resolve(null),
  },
  // Add other models as needed
} as any;

export default prisma

// Database connection utility
export async function connectToDatabase() {
  try {
    await prisma.$connect()
    console.log('✅ Database connected successfully')
  } catch (error) {
    console.error('❌ Database connection failed:', error)
    throw error
  }
}

// Graceful shutdown
export async function disconnectFromDatabase() {
  try {
    await prisma.$disconnect()
    console.log('✅ Database disconnected successfully')
  } catch (error) {
    console.error('❌ Database disconnection failed:', error)
  }
}

// Transaction wrapper
export async function withTransaction<T>(
  callback: (prisma: PrismaClient) => Promise<T>
): Promise<T> {
  return await prisma.$transaction(callback)
}

// Health check
export async function checkDatabaseHealth(): Promise<boolean> {
  try {
    await prisma.$queryRaw`SELECT 1`
    return true
  } catch (error) {
    console.error('Database health check failed:', error)
    return false
  }
}

// Common queries
export const queries = {
  // User queries
  findUserByEmail: (email: string) =>
    prisma.user.findUnique({
      where: { email },
      include: {
        leveragePositions: {
          where: { status: 'OPEN' },
          take: 5,
        },
        _count: {
          select: {
            coinTransactions: true,
            depositRequests: true,
            leveragePositions: true,
          },
        },
      },
    }),

  findUserById: (id: number) =>
    prisma.user.findUnique({
      where: { id },
      include: {
        _count: {
          select: {
            coinTransactions: true,
            depositRequests: true,
            leveragePositions: true,
          },
        },
      },
    }),

  // Trading queries
  getActiveCoins: () =>
    prisma.coin.findMany({
      where: { isActive: true },
      include: { category: true },
      orderBy: [{ sortOrder: 'asc' }, { id: 'asc' }],
    }),

  getUserPortfolio: (userId: number) =>
    prisma.coinTransaction.groupBy({
      by: ['coinId'],
      where: { userId },
      _sum: {
        amount: true,
      },
      having: {
        amount: {
          _sum: {
            gt: 0,
          },
        },
      },
    }),

  getOpenLeveragePositions: (userId: number) =>
    prisma.leveragePosition.findMany({
      where: {
        userId,
        status: 'OPEN',
      },
      orderBy: { createdAt: 'desc' },
    }),

  // Transaction queries
  getUserTransactionHistory: (userId: number, limit = 50) =>
    prisma.transactionHistory.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    }),

  // Deposit/Withdrawal queries
  getPendingDeposits: () =>
    prisma.depositRequest.findMany({
      where: { status: 'PENDING' },
      include: { user: { select: { username: true, email: true } } },
      orderBy: { createdAt: 'desc' },
    }),

  getPendingWithdrawals: () =>
    prisma.withdrawalRequest.findMany({
      where: { status: 'PENDING' },
      include: { user: { select: { username: true, email: true } } },
      orderBy: { createdAt: 'desc' },
    }),
}