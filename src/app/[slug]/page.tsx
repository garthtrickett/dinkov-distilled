import { getMarkdownByIdentifier, getAllMarkdowns } from '../lib/markdown';
import { notFound } from 'next/navigation';
import Link from 'next/link';

interface PageProps {
  params: Promise<{ slug: string }> | { slug: string };
}

export async function generateStaticParams() {
  const files = getAllMarkdowns();
  const paramsList: { slug: string }[] = [];
  
  for (const file of files) {
    if (file.uuid) {
      paramsList.push({ slug: file.uuid });
    }
    paramsList.push({ slug: file.slug });
  }
  
  return paramsList;
}

export default async function Page({ params }: PageProps) {
  // Gracefully handle both Next.js 14 and Next.js 15+ promise resolution structures
  const resolvedParams = 'then' in params ? await params : params;
  const rawSlug = resolvedParams.slug;
  const slug = decodeURIComponent(rawSlug).replace(/\.md$/, '');

  const data = getMarkdownByIdentifier(slug);

  if (!data) {
    notFound();
  }

  return (
    <main className="min-h-screen bg-white text-stone-900">
      <div className="max-w-4xl mx-auto px-6 py-12">
        <div className="mb-8">
          <Link href="/" className="text-sm font-medium text-cyan-600 hover:text-cyan-800 transition-colors inline-flex items-center gap-1">
            ← Back to Outline
          </Link>
        </div>

        <article className="prose prose-stone lg:prose-xl max-w-none">
          {data.title && <h1 className="mb-4 text-3xl font-bold">{data.title}</h1>}
          {data.created && (
            <p className="text-sm text-gray-500 mb-6">
              Published: {new Date(data.created).toLocaleDateString()}
            </p>
          )}
          <div 
            dangerouslySetInnerHTML={{ __html: data.htmlContent }} 
            className="markdown-content"
          />
        </article>

        <div className="mt-12 pt-6 border-t border-stone-200">
          <Link href="/" className="text-sm font-medium text-cyan-600 hover:text-cyan-800 transition-colors inline-flex items-center gap-1">
            ← Back to Outline
          </Link>
        </div>
      </div>
    </main>
  );
}
