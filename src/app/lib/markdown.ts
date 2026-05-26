import fs from 'node:fs'
import path from 'node:path'
import matter from 'gray-matter'
import { marked } from 'marked'

const contentDirectory = path.join(process.cwd(), 'content')

export interface MarkdownPage {
  slug: string
  title: string
  contentHtml: string
  frontmatter: Record<string, unknown>
}

export async function getPageData(slug: string): Promise<MarkdownPage | null> {
  try {
    // Sanitize slug to prevent directory traversal
    const safeSlug = path.basename(slug, '.md')
    const fullPath = path.join(contentDirectory, `${safeSlug}.md`)
    
    if (!fs.existsSync(fullPath)) {
      return null
    }

    const fileContents = fs.readFileSync(fullPath, 'utf8')
    const { data, content } = matter(fileContents)

    // Convert Markdown content to HTML string
    const contentHtml = await marked(content)

    return {
      slug: safeSlug,
      title: data.title || safeSlug,
      contentHtml,
      frontmatter: data as Record<string, unknown>,
    }
  } catch (error) {
    console.error(`Error loading markdown data for slug ${slug}:`, error)
    return null
  }
}
