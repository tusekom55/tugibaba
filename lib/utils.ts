import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// Number formatting utilities
export function formatCurrency(
  amount: number,
  currency: string = 'TRY',
  locale: string = 'tr-TR'
): string {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount)
}

export function formatNumber(
  value: number,
  decimals: number = 2,
  locale: string = 'tr-TR'
): string {
  return new Intl.NumberFormat(locale, {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  }).format(value)
}

export function formatPercentage(
  value: number,
  decimals: number = 2,
  locale: string = 'tr-TR'
): string {
  return new Intl.NumberFormat(locale, {
    style: 'percent',
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  }).format(value / 100)
}

export function formatCompactNumber(value: number): string {
  const formatter = new Intl.NumberFormat('en-US', {
    notation: 'compact',
    compactDisplay: 'short',
  })
  return formatter.format(value)
}

// Date formatting utilities
export function formatDate(
  date: Date | string,
  options: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  },
  locale: string = 'tr-TR'
): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date
  return new Intl.DateTimeFormat(locale, options).format(dateObj)
}

export function formatDateTime(
  date: Date | string,
  locale: string = 'tr-TR'
): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date
  return new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(dateObj)
}

export function formatRelativeTime(
  date: Date | string,
  locale: string = 'tr-TR'
): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date
  const now = new Date()
  const diffInSeconds = Math.floor((now.getTime() - dateObj.getTime()) / 1000)

  const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' })

  if (diffInSeconds < 60) {
    return rtf.format(-diffInSeconds, 'second')
  } else if (diffInSeconds < 3600) {
    return rtf.format(-Math.floor(diffInSeconds / 60), 'minute')
  } else if (diffInSeconds < 86400) {
    return rtf.format(-Math.floor(diffInSeconds / 3600), 'hour')
  } else if (diffInSeconds < 2592000) {
    return rtf.format(-Math.floor(diffInSeconds / 86400), 'day')
  } else if (diffInSeconds < 31536000) {
    return rtf.format(-Math.floor(diffInSeconds / 2592000), 'month')
  } else {
    return rtf.format(-Math.floor(diffInSeconds / 31536000), 'year')
  }
}

// String utilities
export function truncateString(str: string, length: number): string {
  if (str.length <= length) return str
  return str.slice(0, length) + '...'
}

export function capitalizeFirst(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase()
}

export function slugify(str: string): string {
  return str
    .toLowerCase()
    .replace(/[^a-z0-9 -]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim('-')
}

// Validation utilities
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

export function isValidPhone(phone: string): boolean {
  const phoneRegex = /^(\+90|0)?[5][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$/
  return phoneRegex.test(phone.replace(/\s/g, ''))
}

export function isValidTCNo(tcNo: string): boolean {
  if (!/^[1-9][0-9]{10}$/.test(tcNo)) return false
  
  const digits = tcNo.split('').map(Number)
  const oddSum = digits[0] + digits[2] + digits[4] + digits[6] + digits[8]
  const evenSum = digits[1] + digits[3] + digits[5] + digits[7]
  
  const check1 = (oddSum * 7 - evenSum) % 10
  const check2 = (oddSum + evenSum + digits[9]) % 10
  
  return check1 === digits[9] && check2 === digits[10]
}

export function isValidIBAN(iban: string): boolean {
  const ibanRegex = /^TR[0-9]{2}[0-9]{4}[0-9]{1}[0-9]{16}$/
  return ibanRegex.test(iban.replace(/\s/g, ''))
}

// Trading utilities
export function calculatePnL(
  entryPrice: number,
  currentPrice: number,
  amount: number,
  type: 'LONG' | 'SHORT'
): number {
  if (type === 'LONG') {
    return (currentPrice - entryPrice) * amount
  } else {
    return (entryPrice - currentPrice) * amount
  }
}

export function calculatePnLPercentage(
  entryPrice: number,
  currentPrice: number,
  leverage: number,
  type: 'LONG' | 'SHORT'
): number {
  const priceChangePercentage = ((currentPrice - entryPrice) / entryPrice) * 100
  return type === 'LONG' 
    ? priceChangePercentage * leverage
    : -priceChangePercentage * leverage
}

export function calculateLiquidationPrice(
  entryPrice: number,
  leverage: number,
  type: 'LONG' | 'SHORT',
  liquidationPercentage: number = 0.8
): number {
  const liquidationRatio = liquidationPercentage / leverage
  
  if (type === 'LONG') {
    return entryPrice * (1 - liquidationRatio)
  } else {
    return entryPrice * (1 + liquidationRatio)
  }
}

export function calculateRequiredMargin(
  positionSize: number,
  entryPrice: number,
  leverage: number
): number {
  return (positionSize * entryPrice) / leverage
}

// Array utilities
export function groupBy<T, K extends keyof any>(
  array: T[],
  key: (item: T) => K
): Record<K, T[]> {
  return array.reduce((groups, item) => {
    const groupKey = key(item)
    groups[groupKey] = groups[groupKey] || []
    groups[groupKey].push(item)
    return groups
  }, {} as Record<K, T[]>)
}

export function sortBy<T>(
  array: T[],
  key: keyof T,
  direction: 'asc' | 'desc' = 'asc'
): T[] {
  return [...array].sort((a, b) => {
    const aVal = a[key]
    const aVal = b[key]
    
    if (aVal < bVal) return direction === 'asc' ? -1 : 1
    if (aVal > bVal) return direction === 'asc' ? 1 : -1
    return 0
  })
}

// Async utilities
export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout
  return (...args: Parameters<T>) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => func(...args), wait)
  }
}

export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean
  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      func(...args)
      inThrottle = true
      setTimeout(() => (inThrottle = false), limit)
    }
  }
}

// Local storage utilities
export function setLocalStorage(key: string, value: any): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem(key, JSON.stringify(value))
  }
}

export function getLocalStorage<T>(key: string, defaultValue: T): T {
  if (typeof window !== 'undefined') {
    const item = localStorage.getItem(key)
    return item ? JSON.parse(item) : defaultValue
  }
  return defaultValue
}

export function removeLocalStorage(key: string): void {
  if (typeof window !== 'undefined') {
    localStorage.removeItem(key)
  }
}

// Error handling utilities
export function getErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message
  return String(error)
}

export function isNetworkError(error: unknown): boolean {
  return error instanceof Error && (
    error.message.includes('fetch') ||
    error.message.includes('network') ||
    error.message.includes('NETWORK_ERROR')
  )
}

// Color utilities for trading
export function getPnLColor(value: number): string {
  if (value > 0) return 'text-trading-up'
  if (value < 0) return 'text-trading-down'
  return 'text-trading-neutral'
}

export function getPnLBgColor(value: number): string {
  if (value > 0) return 'bg-trading-up/10'
  if (value < 0) return 'bg-trading-down/10'
  return 'bg-trading-neutral/10'
}

// Generate random ID
export function generateId(): string {
  return Math.random().toString(36).substr(2, 9)
}