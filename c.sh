#!/usr/bin/env bash
# c.sh - Concatenates the repository's files for prompt packaging and review, respecting concat.config

# ==========================================
# SETUP LOGGING (Console output to STDERR)
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() {
    echo -e "${CYAN}[$(date +'%H:%M:%S')]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING:${NC} $1" >&2
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1" >&2
}

# ==========================================
# LOAD CONFIGURATION & FALLBACKS
# ==========================================
CONFIG_FILE="concat.config"

# Default fallbacks
OUTPUT_FILE="a.txt"
PRUNES=(".git" "node_modules" ".vercel" "content/assets")
EXCLUDES=("./package-lock.json" "./pnpm-lock.yaml" "./current_response.json" "./flake.lock")
ALLOWED_EXTENSIONS=(".md" ".sh" ".config" ".py" ".nix")

if [ -f "$CONFIG_FILE" ]; then
    log "Loading config: $CONFIG_FILE"
    # shellcheck source=concat.config
    source "$CONFIG_FILE"

    # Backward compatibility mapping for old config arrays
    if [ ${#EXCLUDE_DIRS[@]} -gt 0 ]; then
        PRUNES=("${EXCLUDE_DIRS[@]}")
    fi
    if [ ${#EXCLUDE_FILES[@]} -gt 0 ]; then
        EXCLUDES=()
        for f in "${EXCLUDE_FILES[@]}"; do
            EXCLUDES+=("./$f")
        done
    fi
    if [ ${#ALLOWED_EXTENSIONS[@]} -gt 0 ]; then
        ALLOWED_EXTENSIONS=("${ALLOWED_EXTENSIONS[@]}")
    fi
else
    warn "$CONFIG_FILE not found. Utilizing default fallback arrays."
fi

# Remove existing output file if it exists
if [ -f "$OUTPUT_FILE" ]; then
    log "Removing old output file: $OUTPUT_FILE"
    rm -f "$OUTPUT_FILE"
fi

# ==========================================
# GENERATE PROJECT STRUCTURE
# ==========================================
log "Generating project file structure map..."

echo "# Project Structure" >"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"

structure_find_args=(.)
for path in "${PRUNES[@]}"; do
    clean_path=${path%/}
    if [[ "$clean_path" != "./"* ]]; then
        clean_path="./$clean_path"
    fi
    structure_find_args+=(-path "$clean_path" -prune -o)
done

# Exclude the concatenator, configuration, and output file from the directory tree mapping
structure_find_args+=(-not -path "./$OUTPUT_FILE")
structure_find_args+=(-not -path "./$CONFIG_FILE")
structure_find_args+=(-not -path "./$0")
structure_find_args+=(-print)

find "${structure_find_args[@]}" | sort | sed 's|^./||' | grep -v '^$' >>"$OUTPUT_FILE"

echo "" >>"$OUTPUT_FILE"
echo "# End of Project Structure" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"
log "Project structure written to $OUTPUT_FILE"

# ==========================================
# RECURSIVE FILE SEARCH & CONCATENATION
# ==========================================
echo "Concatenating directory files..." >>"$OUTPUT_FILE"

log "Building dynamic search parameters..."

find_args=(.)

# Add Prunes first to ensure subdirectories are not evaluated
for path in "${PRUNES[@]}"; do
    clean_path=${path%/}
    if [[ "$clean_path" != "./"* ]]; then
        clean_path="./$clean_path"
    fi
    find_args+=(-path "$clean_path" -prune -o)
done

# Check file type
find_args+=(-type f)

# Add exact excludes
for path in "${EXCLUDES[@]}"; do
    if [[ "$path" != "./"* ]]; then
        path="./$path"
    fi
    find_args+=(-not -path "$path")
done

# Prevent self-concatenation of control files
find_args+=(-not -path "./$OUTPUT_FILE")
find_args+=(-not -path "./$CONFIG_FILE")
find_args+=(-not -path "./$0")

# Append ALLOWED_EXTENSIONS filter logic
if [ ${#ALLOWED_EXTENSIONS[@]} -gt 0 ]; then
    find_args+=(\()
    first=true
    for ext in "${ALLOWED_EXTENSIONS[@]}"; do
        if [ "$first" = true ]; then
            find_args+=(-name "*$ext")
            first=false
        else
            find_args+=(-o -name "*$ext")
        fi
    done
    find_args+=(\))
fi

find_args+=(-print0)

log "Starting recursive search and content aggregation..."

find "${find_args[@]}" | sort -z | while IFS= read -r -d '' file; do
    if [ -d "$file" ]; then
        continue
    fi

    # Clear line on stderr and measure file size
    echo -ne "\r\033[K" >&2
    if [[ "$OSTYPE" == "darwin"* ]]; then
        fsize=$(stat -f%z "$file")
    else
        fsize=$(stat -c%s "$file")
    fi
    fsize_kb=$((fsize / 1024))

    if [ "$fsize_kb" -gt 100 ]; then
        warn "Processing LARGE file (${fsize_kb}KB): $file"
    else
        echo -e "${GREEN}Processing:${NC} $file (${fsize} bytes)" >&2
    fi

    # Append content with standard wrappers
    {
        echo "File: $file"
        echo "------------------------"
        cat "$file"
        echo -e "\n\n"
    } >>"$OUTPUT_FILE"
done

# Clear stderr formatting artifacts
echo -ne "\r\033[K" >&2

log "DONE! All files successfully concatenated into $OUTPUT_FILE"
