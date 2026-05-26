import type { Metadata } from 'next'
import Link from 'next/link'
import './globals.css'

export const metadata: Metadata = {
  title: 'Dinkov Distilled',
  description: 'The Metabolic Theory of Health',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col bg-stone-50 text-stone-900 selection:bg-cyan-100 antialiased">
        <header className="border-b border-stone-200 bg-white/80 backdrop-blur-md sticky top-0 z-50">
          <div className="max-w-4xl mx-auto px-6 h-16 flex items-center justify-between">
            <Link href="/" className="font-bold text-lg tracking-tight hover:text-cyan-600 transition-colors">
              🧬 Dinkov Distilled
            </Link>
            <Link href="/" className="text-sm font-medium text-stone-500 hover:text-stone-900 transition-colors">
              Outline
            </Link>
          </div>
        </header>
        <div className="flex-grow">
          {children}
        </div>
        <footer className="border-t border-stone-200 py-8 bg-stone-100 text-stone-500 text-xs mt-12">
          <div className="max-w-4xl mx-auto px-6 flex items-center justify-between">
            <p>© {new Date().getFullYear()} Dinkov Distilled</p>
            <p>Built with Next.js & Vercel</p>
          </div>
        </footer>
      </body>
    </html>
  )
}
