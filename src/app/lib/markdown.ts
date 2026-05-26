import fs from 'fs';
import path from 'path';
import { marked } from 'marked';

const contentDirectory = path.join(process.cwd(), 'content');

export interface MarkdownData {
  slug: string;
  uuid?: string;
  title?: string;
  created?: string;
  updated?: string;
  tags?: string[];
  content: string;
  htmlContent: string;
}

function parseFrontmatter(fileContent: string): { data: any; content: string } {
  const match = fileContent.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/);
  if (!match) {
    return { data: {}, content: fileContent };
  }
  const yamlBlock = match[1];
  const content = match[2];
  const data: any = {};
  
  const lines = yamlBlock.split('\n');
  let currentKey = '';
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    
    if (trimmed.startsWith('-') && currentKey) {
      if (!Array.isArray(data[currentKey])) {
        data[currentKey] = [];
      }
      data[currentKey].push(trimmed.slice(1).trim().replace(/^['"]|['"]$/g, ''));
      continue;
    }
    
    const colonIdx = trimmed.indexOf(':');
    if (colonIdx !== -1) {
      const key = trimmed.slice(0, colonIdx).trim();
      const val = trimmed.slice(colonIdx + 1).trim().replace(/^['"]|['"]$/g, '');
      data[key] = val;
      currentKey = key;
    }
  }
  return { data, content };
}

// Memory cache for path lookup
let filesCache: { slug: string; uuid?: string; filePath: string }[] | null = null;

function getFilesCache() {
  if (filesCache) return filesCache;
  
  if (!fs.existsSync(contentDirectory)) {
    return [];
  }
  
  const files = fs.readdirSync(contentDirectory);
  const cache: { slug: string; uuid?: string; filePath: string }[] = [];
  
  for (const file of files) {
    if (!file.endsWith('.md')) continue;
    const filePath = path.join(contentDirectory, file);
    try {
      const fileContent = fs.readFileSync(filePath, 'utf-8');
      const { data } = parseFrontmatter(fileContent);
      const slug = file.replace(/\.md$/, '');
      cache.push({
        slug,
        uuid: data.uuid,
        filePath,
      });
    } catch (e) {
      console.error(`Error reading ${file}:`, e);
    }
  }
  
  filesCache = cache;
  return cache;
}

function rewriteLinks(html: string): string {
  // 1. Rewrite Amplenote links like https://www.amplenote.com/notes/7b088428-4f43-11f0-aef7-69ac32418669 to /7b088428-4f43-11f0-aef7-69ac32418669
  let updatedHtml = html.replace(/href="https:\/\/www\.amplenote\.com\/notes\/([a-zA-Z0-9-]+)"/g, 'href="/$1"');

  // 2. Rewrite other local .md links like href="introduction.md" to the correct uuid or slug
  updatedHtml = updatedHtml.replace(/href="([^"]+?\.md)"/g, (match, link) => {
    if (link.startsWith('http') || link.startsWith('#') || link.startsWith('mailto:')) {
      return match;
    }
    const filename = link.split('/').pop()?.replace(/\.md$/, '') || '';
    const cache = getFilesCache();
    const found = cache.find(item => item.slug === filename || item.uuid === filename);
    if (found) {
      return `href="/${found.uuid || found.slug}"`;
    }
    return `href="/${filename}"`;
  });
  
  return updatedHtml;
}

export function getMarkdownByIdentifier(identifier: string): MarkdownData | null {
  const cache = getFilesCache();
  
  // Clean up identifier: remove optional .md suffix if present
  const cleanId = identifier.replace(/\.md$/, '');
  
  // Try to find by UUID first, then by slug
  const found = cache.find(item => item.uuid === cleanId || item.slug === cleanId);
  if (!found) return null;
  
  try {
    const fileContent = fs.readFileSync(found.filePath, 'utf-8');
    const { data, content } = parseFrontmatter(fileContent);
    const rawHtml = marked(content) as string;
    const htmlContent = rewriteLinks(rawHtml);
    
    return {
      slug: found.slug,
      uuid: data.uuid,
      title: data.title || found.slug,
      created: data.created,
      updated: data.updated,
      tags: data.tags,
      content,
      htmlContent,
    };
  } catch (e) {
    console.error(`Error loading markdown file ${found.filePath}:`, e);
    return null;
  }
}

export function getAllMarkdowns() {
  const cache = getFilesCache();
  return cache.map(item => {
    try {
      const fileContent = fs.readFileSync(item.filePath, 'utf-8');
      const { data } = parseFrontmatter(fileContent);
      return {
        slug: item.slug,
        uuid: item.uuid,
        title: data.title || item.slug,
      };
    } catch (e) {
      return {
        slug: item.slug,
        uuid: item.uuid,
        title: item.slug,
      };
    }
  });
}
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
    console.error(`Error loading markdown data for slug ${slug.replace(/\.md$/, "")}:`, error)
    return null
  }
}
