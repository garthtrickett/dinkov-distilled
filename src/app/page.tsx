import { getPageData } from './lib/markdown'
import { notFound } from 'next/navigation'

export default async function HomePage() {
  // Load and parse the main outline file
  const page = await getPageData('health_vitalist_Outline')
  
  if (!page) {
    notFound()
  }

  return (
    <main className="max-w-4xl mx-auto px-6 py-12">
      <article className="prose prose-stone lg:prose-xl max-w-none">
        <div dangerouslySetInnerHTML={{ __html: page.contentHtml }} />
      </article>
    </main>
  )
}
