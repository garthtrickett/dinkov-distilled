#!/usr/bin/env python3
import os
import re
import html

def clean_name(filename):
    # Keep the table of contents and main outline file names standardized
    if filename in ["table-of-contents.md", "health_vitalist_Outline.md"]:
        return filename
    
    # Split filename and extension
    name, ext = os.path.splitext(filename)
    
    # 1. Unescape HTML entities (e.g. &amp; -> &)
    name = html.unescape(name)
    
    # 2. Replace non-alphanumeric characters (excluding spaces and hyphens) with spaces
    name = re.sub(r"[^a-zA-Z0-9\s-]", " ", name)
    
    # 3. Replace any repeating sequence of spaces or hyphens with a single space
    name = re.sub(r"[\s-]+", " ", name)
    
    # 4. Strip edges, lowercase, and join words with hyphens
    cleaned = "-".join(name.strip().split()).lower()
    
    return cleaned + ext

def run_cleanup():
    content_dir = "content"
    if not os.path.exists(content_dir):
        print(f"❌ Content directory not found at: {content_dir}")
        return

    # 1. Gather all markdown files on disk
    files = [f for f in os.listdir(content_dir) if f.endswith(".md")]
    
    # 2. Build the exact mapping from old -> new name
    mapping = {}
    for filename in files:
        new_filename = clean_name(filename)
        mapping[filename] = new_filename

    # 3. Update links inside all markdown files before renaming files
    print("📝 Step 1: Updating links inside markdown files...")
    # Matches markdown link format: [anchor text](path)
    link_pattern = re.compile(r"(\[[^\]]+\]\()([^)]+)(\))")

    for filename in files:
        file_path = os.path.join(content_dir, filename)
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        def replace_link(match):
            prefix, link_path, suffix = match.groups()
            
            # Ignore web links and internal section anchor links
            if link_path.startswith("http") or link_path.startswith("#"):
                return match.group(0)

            # Standardize and clean the link path to check against our keys
            decoded_path = html.unescape(link_path).replace("%20", " ")
            base_link = os.path.basename(decoded_path)

            if base_link in mapping:
                new_base = mapping[base_link]
                
                # Keep folder prefix (e.g. content/) if it was present
                if "/" in link_path:
                    new_link = link_path.rsplit("/", 1)[0] + "/" + new_base
                else:
                    new_link = new_base
                
                return f"{prefix}{new_link}{suffix}"
            return match.group(0)

        updated_content = link_pattern.sub(replace_link, content)
        
        if updated_content != content:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(updated_content)
            print(f"  ✨ Updated links inside: {filename}")

    # 4. Perform actual file renames
    print("\n🚀 Step 2: Renaming files on disk...")
    renamed_count = 0
    for old_name, new_name in mapping.items():
        if old_name == new_name:
            continue
        
        old_path = os.path.join(content_dir, old_name)
        new_path = os.path.join(content_dir, new_name)

        if os.path.exists(new_path):
            print(f"  ⚠️  Skipping rename: '{new_name}' already exists.")
            continue

        os.rename(old_path, new_path)
        print(f"  ✅ Renamed: '{old_name}' ➔ '{new_name}'")
        renamed_count += 1

    print(f"\n🎉 Clean-up complete! {renamed_count} files renamed.")

if __name__ == "__main__":
    run_cleanup()
