import { getMarkdownByIdentifier } from './lib/markdown';

export default async function Home() {
  const data = getMarkdownByIdentifier('table-of-contents') || getMarkdownByIdentifier('health_vitalist_Outline');
  
  if (!data) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen py-12 px-4 text-center">
        <h1 className="text-4xl font-bold mb-4">Dinkov Distilled</h1>
        <p className="text-xl text-gray-600">Table of Contents not found.</p>
      </div>
    );
  }
  
  return (
    <article className="prose lg:prose-xl mx-auto py-8 px-4 dark:prose-invert">
      {data.title && <h1 className="mb-4 text-3xl font-bold">{data.title}</h1>}
      <div 
        dangerouslySetInnerHTML={{ __html: data.htmlContent }} 
        className="markdown-content"
      />
    </article>
  );
}
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
