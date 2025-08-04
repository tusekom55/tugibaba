import { getServerSession } from 'next-auth'
import { redirect } from 'next/navigation'
import { authOptions } from '@/lib/auth'
import { LandingPage } from '@/components/landing/landing-page'

export default async function HomePage() {
  const session = await getServerSession(authOptions)
  
  // If user is authenticated, redirect to dashboard
  if (session) {
    redirect('/dashboard')
  }
  
  return <LandingPage />
}