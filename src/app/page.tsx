import { getPageData } from './lib/markdown';
import { notFound } from 'next/navigation';

export default async function HomePage() {
  // Try to load the table of contents first, falling back to the main outline file
  let page = await getPageData('table-of-contents');
  if (!page) {
    page = await getPageData('health_vitalist_Outline');
  }
  
  if (!page) {
    notFound();
  }

  return (
    <main className="min-h-screen bg-white text-stone-900">
      <div className="max-w-4xl mx-auto px-6 py-12">
        <article className="prose prose-stone lg:prose-xl max-w-none">
          {page.title && <h1 className="mb-6 text-3xl font-bold">{page.title}</h1>}
          <div dangerouslySetInnerHTML={{ __html: page.contentHtml }} />
        </article>
      </div>
    </main>
  );
}
