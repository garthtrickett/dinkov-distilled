import { getPageData } from '../lib/markdown'
import { notFound } from 'next/navigation'
import Link from 'next/link'

interface PageProps {
  params: Promise<{ slug: string }> | { slug: string }
}

export default async function ChapterPage({ params }: PageProps) {
  // Gracefully handle both Next.js 14 and Next.js 15+ promise resolution structures
  const resolvedParams = 'then' in params ? await params : params
  const rawSlug = resolvedParams.slug
  const slug = decodeURIComponent(rawSlug).replace(/\.md$/, '')

  const page = await getPageData(slug)

  if (!page) {
    notFound()
  }

  return (
    <main className="max-w-4xl mx-auto px-6 py-12">
      <div className="mb-8">
        <Link href="/" className="text-sm font-medium text-cyan-600 hover:text-cyan-800 transition-colors inline-flex items-center gap-1">
          ← Back to Outline
        </Link>
      </div>

      <article className="prose prose-stone lg:prose-xl max-w-none">
        <div dangerouslySetInnerHTML={{ __html: page.contentHtml }} />
      </article>

      <div className="mt-12 pt-6 border-t border-stone-200">
        <Link href="/" className="text-sm font-medium text-cyan-600 hover:text-cyan-800 transition-colors inline-flex items-center gap-1">
          ← Back to Outline
        </Link>
      </div>
    </main>
  )
}
