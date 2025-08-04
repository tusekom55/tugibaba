import { User, Role, Coin, CoinTransaction, DepositRequest, WithdrawalRequest, 
         LeveragePosition, LeverageTrade, ForexPair, TransactionHistory } from '@prisma/client'

// User Types
export interface UserProfile extends User {
  _count?: {
    coinTransactions: number
    depositRequests: number
    leveragePositions: number
  }
}

export interface SessionUser {
  id: number
  username: string
  email: string
  role: Role
  balance: number
  fullName?: string
}

// Trading Types
export interface CoinWithCategory extends Coin {
  category?: {
    id: number
    name: string
  }
}

export interface CoinTransactionWithDetails extends CoinTransaction {
  coin: CoinWithCategory
  user: Pick<User, 'id' | 'username'>
}

export interface TradingPair {
  id: string
  symbol: string
  name: string
  price: number
  change24h: number
  volume24h: number
  marketCap: number
  logo?: string
}

export interface MarketData {
  symbol: string
  price: number
  change24h: number
  volume: number
  high24h: number
  low24h: number
  timestamp: number
}

// Leverage Trading Types
export interface LeveragePositionWithDetails extends LeveragePosition {
  coin?: CoinWithCategory
  currentPnl: number
  pnlPercentage: number
  marginLevel: number
}

export interface LeverageTradeWithDetails extends LeverageTrade {
  pair: ForexPair
  currentPnl: number
  marginLevel: number
}

export interface OpenPositionRequest {
  coinSymbol: string
  positionType: 'LONG' | 'SHORT'
  leverageRatio: number
  investedAmount: number
  entryPrice: number
}

export interface ClosePositionRequest {
  positionId: number
  closePrice: number
}

// Chart Types
export interface CandlestickData {
  time: number
  open: number
  high: number
  low: number
  close: number
  volume?: number
}

export interface ChartConfig {
  symbol: string
  timeframe: '1m' | '5m' | '15m' | '30m' | '1h' | '4h' | '1d'
  limit?: number
}

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean
  data?: T
  error?: string
  message?: string
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number
    limit: number
    total: number
    totalPages: number
  }
}

// Form Types
export interface LoginForm {
  username: string
  password: string
}

export interface RegisterForm {
  username: string
  email: string
  password: string
  confirmPassword: string
  fullName: string
  phone?: string
}

export interface DepositForm {
  method: 'CREDIT_CARD' | 'PAPARA' | 'BANK_TRANSFER'
  amount: number
  details?: string
  description?: string
}

export interface WithdrawalForm {
  method: 'CREDIT_CARD' | 'PAPARA' | 'BANK_TRANSFER'
  amount: number
  description?: string
}

export interface TradeForm {
  coinId: number
  type: 'BUY' | 'SELL'
  amount: number
  price?: number
}

// Dashboard Types
export interface DashboardStats {
  totalBalance: number
  totalPnl: number
  openPositions: number
  todayPnl: number
  portfolioValue: number
}

export interface PortfolioItem {
  coin: CoinWithCategory
  amount: number
  value: number
  pnl: number
  pnlPercentage: number
}

// Admin Types
export interface AdminDashboardStats {
  totalUsers: number
  totalDeposits: number
  totalWithdrawals: number
  pendingDeposits: number
  pendingWithdrawals: number
  totalVolume: number
}

export interface UserManagement extends User {
  _count: {
    coinTransactions: number
    depositRequests: number
    leveragePositions: number
  }
  lastActivity?: Date
}

// WebSocket Types
export interface WebSocketMessage {
  type: 'PRICE_UPDATE' | 'TRADE_UPDATE' | 'POSITION_UPDATE' | 'NOTIFICATION'
  data: any
  timestamp: number
}

export interface PriceUpdate {
  symbol: string
  price: number
  change24h: number
  volume: number
  timestamp: number
}

// Notification Types
export interface Notification {
  id: string
  type: 'SUCCESS' | 'ERROR' | 'WARNING' | 'INFO'
  title: string
  message: string
  timestamp: number
  read: boolean
}

// Settings Types
export interface UserSettings {
  notifications: {
    email: boolean
    push: boolean
    trading: boolean
    deposits: boolean
  }
  trading: {
    defaultLeverage: number
    riskPerTrade: number
    autoClose: {
      profit: number | null
      loss: number | null
    }
  }
  security: {
    twoFactorEnabled: boolean
    loginNotifications: boolean
  }
}

// Validation Types
export interface ValidationError {
  field: string
  message: string
}

export interface FormState<T> {
  data: T
  errors: ValidationError[]
  isLoading: boolean
  isValid: boolean
}

// Utility Types
export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P]
}

export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>

export type RequiredFields<T, K extends keyof T> = T & Required<Pick<T, K>>

// Component Props Types
export interface BaseComponentProps {
  className?: string
  children?: React.ReactNode
}

export interface LoadingState {
  isLoading: boolean
  error?: string | null
}

// Hook Return Types
export interface UseAsyncReturn<T> extends LoadingState {
  data: T | null
  execute: (...args: any[]) => Promise<void>
  reset: () => void
}

export interface UsePaginationReturn {
  currentPage: number
  totalPages: number
  hasNextPage: boolean
  hasPrevPage: boolean
  nextPage: () => void
  prevPage: () => void
  goToPage: (page: number) => void
}

// Constants
export const TIMEFRAMES = ['1m', '5m', '15m', '30m', '1h', '4h', '1d'] as const
export const LEVERAGE_OPTIONS = [1, 2, 5, 10, 20, 50, 100] as const
export const PAYMENT_METHODS = ['CREDIT_CARD', 'PAPARA', 'BANK_TRANSFER'] as const

export type Timeframe = typeof TIMEFRAMES[number]
export type LeverageOption = typeof LEVERAGE_OPTIONS[number]
export type PaymentMethod = typeof PAYMENT_METHODS[number]