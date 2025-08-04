import { NextAuthOptions, Session, User } from 'next-auth'
import { JWT } from 'next-auth/jwt'
import CredentialsProvider from 'next-auth/providers/credentials'
import bcrypt from 'bcryptjs'
// import prisma from './prisma' // Temporarily disabled
import { SessionUser } from '@/types'

declare module 'next-auth' {
  interface Session {
    user: SessionUser
  }
  
  interface User {
    id: number
    username: string
    email: string
    role: 'USER' | 'ADMIN'
    balance: number
    fullName?: string
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    id: number
    username: string
    role: 'USER' | 'ADMIN'
    balance: number
    fullName?: string
  }
}

export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: 'credentials',
      credentials: {
        username: { label: 'Username', type: 'text' },
        password: { label: 'Password', type: 'password' }
      },
      async authorize(credentials) {
        if (!credentials?.username || !credentials?.password) {
          throw new Error('Kullanıcı adı ve şifre gereklidir')
        }

        // Temporarily return mock user for deployment without database
        if (credentials.username === 'admin' && credentials.password === 'admin') {
          return {
            id: 1,
            username: 'admin',
            email: 'admin@test.com',
            role: 'ADMIN' as const,
            balance: 10000,
            fullName: 'Test Admin',
          }
        }
        
        if (credentials.username === 'test' && credentials.password === 'test') {
          return {
            id: 2,
            username: 'test',
            email: 'test@test.com',
            role: 'USER' as const,
            balance: 1000,
            fullName: 'Test User',
          }
        }
        
        throw new Error('Geçersiz kullanıcı adı veya şifre')
      }
    })
  ],
  
  session: {
    strategy: 'jwt',
    maxAge: 24 * 60 * 60, // 24 hours
  },
  
  jwt: {
    maxAge: 24 * 60 * 60, // 24 hours
  },
  
  callbacks: {
    async jwt({ token, user, trigger, session }) {
      // Initial sign in
      if (user) {
        token.id = user.id
        token.username = user.username
        token.role = user.role
        token.balance = user.balance
        token.fullName = user.fullName
      }
      
      // Update session (when session.update() is called)
      if (trigger === 'update' && session) {
        if (session.balance !== undefined) {
          token.balance = session.balance
        }
        if (session.fullName !== undefined) {
          token.fullName = session.fullName
        }
      }
      
      return token
    },
    
    async session({ session, token }) {
      if (token) {
        session.user = {
          id: token.id,
          username: token.username,
          email: token.email!,
          role: token.role,
          balance: token.balance,
          fullName: token.fullName,
        }
      }
      return session
    }
  },
  
  pages: {
    signIn: '/auth/login',
    signUp: '/auth/register',
    error: '/auth/error',
  },
  
  events: {
    async signIn({ user, account, profile, isNewUser }) {
      console.log('User signed in:', user.username)
      
      // Log the sign in
      try {
        await prisma.log.create({
          data: {
            userId: user.id,
            type: 'API_UPDATE',
            details: `User ${user.username} signed in`,
          }
        })
      } catch (error) {
        console.error('Failed to log sign in:', error)
      }
    },
    
    async signOut({ token }) {
      if (token?.id) {
        console.log('User signed out:', token.username)
        
        // Log the sign out
        try {
          await prisma.log.create({
            data: {
              userId: token.id,
              type: 'API_UPDATE',
              details: `User ${token.username} signed out`,
            }
          })
        } catch (error) {
          console.error('Failed to log sign out:', error)
        }
      }
    }
  },
  
  debug: process.env.NODE_ENV === 'development',
}

// Utility functions
export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 12)
}

export async function verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
  return bcrypt.compare(password, hashedPassword)
}

export async function createUser(userData: {
  username: string
  email: string
  password: string
  fullName?: string
  phone?: string
}) {
  const hashedPassword = await hashPassword(userData.password)
  
  return prisma.user.create({
    data: {
      ...userData,
      password: hashedPassword,
    }
  })
}

export async function updateUserBalance(userId: number, newBalance: number) {
  return prisma.user.update({
    where: { id: userId },
    data: { balance: newBalance }
  })
}

export async function getUserBalance(userId: number): Promise<number> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { balance: true }
  })
  
  return user ? Number(user.balance) : 0
}

export function isAdmin(user: SessionUser): boolean {
  return user.role === 'ADMIN'
}

export function isUser(user: SessionUser): boolean {
  return user.role === 'USER'
}