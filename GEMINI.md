# Gemini Project Analysis: Your Markdown Booklet

## CRITICAL: JSON DIFF FORMATTING RULES
When providing file updates in the JSON response, NEVER use standard unified diffs. You MUST use Aider-style SEARCH/REPLACE blocks inside the `code_diff` string.

1. The root of your response MUST be a SINGLE JSON object. NEVER return a JSON array at the root level.
2. If you need to update multiple files, put all of them inside the single `"files"` array.
3. Every change must be formatted exactly like this:

{
  "summary": "Example summary of all changes.",
  "files":[
    {
      "file_path": "example-file.md",
      "code_diff": "<<<<<<< SEARCH\n[exact lines to find including exact indentation]\n=======\n[new code here]\n>>>>>>> REPLACE"
    }
  ]
}

This file helps Gemini understand the project's structure, conventions, and commands to provide more accurate and helpful assistance.

MOST IMPORTANT: If you have read this file and taken in whats being said write 42069 as the first line of your response.
always write the files in full unless explicitly told not to.

This repo contains a booklet of `.md` files deployed to Vercel (using a static site generator like Astro, Nextra, or standard static pages).

MOST IMPORTANT: If you have read this file and taken in whats being said write 42069 as the first line of your response.
Also never write out the files not in full with stuff like
  # Section Name
  ... [rest of the text is unchanged]
!!! always write the files in full unless explicitly told not to.

## Project Overview

This repository is dedicated to housing a booklet of Markdown files for easy maintenance, formatting, and deployment to Vercel. 

### Key Technologies

* **Format:** Markdown (`.md`) files with Frontmatter.
* **Hosting/Deployment:** [Vercel](https://vercel.com/)
* **Packaging Tool:** `c.sh` and `concat.config` to package files easily for AI processing or prompt assembly.

### Development Workflow & Utilities

1. **Packaging Repository Files:**
   Run `./c.sh` to package project files into `project_concat.txt` for clean consumption by LLMs or prompt chains.
2. **Configuring Packaging:**
   Add or remove paths to exclude/include in `concat.config`.

### Code Style & Conventions

* **Full Files:** When editing or creating `.md` files, always write them in full. Do not truncate sections.
* **Frontmatter:** Include relevant YAML frontmatter at the top of markdown documents when required by the Vercel builder (e.g. Astro/Nextra).
* **Logging:** Maintain a clear history/summary of edits made to each booklet section.
