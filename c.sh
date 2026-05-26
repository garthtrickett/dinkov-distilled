#!/usr/bin/env bash
# c.sh - Concatenates the repository's files for prompt packaging and review, respecting concat.config

CONFIG_FILE="concat.config"

# Default fallback arrays if config is missing
EXCLUDE_DIRS=(".git" "node_modules" ".vercel")
EXCLUDE_FILES=("package-lock.json" "pnpm-lock.yaml" "current_response.json")
ALLOWED_EXTENSIONS=(".md" ".sh" ".config" ".py")

# Source the configuration file if it exists
if [ -f "$CONFIG_FILE" ]; then
    # Source arrays safely from the config file
    source "$CONFIG_FILE"
fi

OUTPUT_FILE="project_concat.txt"
rm -f "$OUTPUT_FILE"

echo "📄 Concatenating project files into $OUTPUT_FILE..."

# Build find expression for excluded directories
EXCLUDE_DIR_ARGS=()
for dir in "${EXCLUDE_DIRS[@]}"; do
    if [ ${#EXCLUDE_DIR_ARGS[@]} -eq 0 ]; then
        EXCLUDE_DIR_ARGS+=("-path" "*/$dir")
    else
        EXCLUDE_DIR_ARGS+=("-o" "-path" "*/$dir")
    fi
done

# Build find expression for allowed extensions
EXTENSION_ARGS=()
for ext in "${ALLOWED_EXTENSIONS[@]}"; do
    if [ ${#EXTENSION_ARGS[@]} -eq 0 ]; then
        EXTENSION_ARGS+=("-name" "*$ext")
    else
        EXTENSION_ARGS+=("-o" "-name" "*$ext")
    fi
done

# Temporary list of files to process
find . -type f \
    \( "${EXCLUDE_DIR_ARGS[@]}" \) -prune \
    -o \( "${EXTENSION_ARGS[@]}" \) -print | sort | while read -r FILE_PATH; do
    
    # Check against excluded files
    BASE_NAME=$(basename "$FILE_PATH")
    is_excluded=false
    for exc in "${EXCLUDE_FILES[@]}"; do
        if [[ "$BASE_NAME" == "$exc" || "$FILE_PATH" == *"$exc"* ]]; then
            is_excluded=true
            break
        fi
    done
    
    if [ "$is_excluded" = true ] || [ "$FILE_PATH" == "./$OUTPUT_FILE" ]; then
        continue
    fi

    echo "Adding: $FILE_PATH"
    echo "--- START OF FILE $FILE_PATH ---" >> "$OUTPUT_FILE"
    cat "$FILE_PATH" >> "$OUTPUT_FILE"
    echo -e "\n--- END OF FILE $FILE_PATH ---\n" >> "$OUTPUT_FILE"
done

echo "✅ Concatenation complete! Output saved to $OUTPUT_FILE"
#!/usr/bin/env bash

# ==========================================
# SETUP LOGGING
# ==========================================
# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[1;30m'
NC='\033[0m' # No Color

# Helper to print to STDERR (console) so it doesn't mess up the output file
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
# LOAD CONFIGURATION
# ==========================================
CONFIG_FILE="concat.config"

# Check if config exists
if [ -f "$CONFIG_FILE" ]; then
    log "Loading config: $CONFIG_FILE"
    # shellcheck source=concat.config
    source "$CONFIG_FILE"
else
    error "$CONFIG_FILE not found."
    exit 1
fi

# Remove existing output file if it exists
if [ -f "$OUTPUT_FILE" ]; then
    log "Removing old output file: $OUTPUT_FILE"
    rm -f "$OUTPUT_FILE"
fi

# ==========================================
# GENERATE PROJECT STRUCTURE
# ==========================================
log "Generating project file structure..."

echo "# Project Structure" >"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"

# Build find arguments for the structure
structure_find_args=(.)
for path in "${PRUNES[@]}"; do
    clean_path=${path%/}
    structure_find_args+=(-path "$clean_path" -prune -o)
done

# Also prune the script itself, the config, and the output file
structure_find_args+=(-path "./$OUTPUT_FILE" -prune -o)
structure_find_args+=(-path "./$CONFIG_FILE" -prune -o)
structure_find_args+=(-path "$0" -prune -o)
structure_find_args+=(-print)

# Execute find, remove the leading './', and append to the output file
find "${structure_find_args[@]}" | sed 's|^./||' >>"$OUTPUT_FILE"

echo "" >>"$OUTPUT_FILE"
echo "# End of Project Structure" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"
log "Project structure written to $OUTPUT_FILE"

# ==========================================
# CONCATENATE FILES (Original Logic)
# ==========================================

echo "Concatenating directory files..." >>"$OUTPUT_FILE"

# ==========================================
# LOGIC BUILDER
# ==========================================

log "Building file search arguments..."

# 1. Start building find arguments
find_args=(.)

# 2. Add Prunes FIRST (Efficiency Check)
# This prevents entering the directory at all
for path in "${PRUNES[@]}"; do
    # Remove trailing slash if present to ensure directory matching works cleanly
    clean_path=${path%/}
    find_args+=(-path "$clean_path" -prune -o)
done

# ---------------------------------------------------------
# NEW: DEBUG DIRECTORY SCANNER
# This prints the current directory being scanned to stderr
# overwriting the previous line (\r).
# If the script hangs, the problematic folder will be visible.
# ---------------------------------------------------------
find_args+=(-type d -exec sh -c 'printf "\r\033[K\033[1;30mScanning: %s\033[0m" "$1" >&2' _ {} \;)
find_args+=(-false -o) # Return false so we continue to the next check logic
# ---------------------------------------------------------

# 3. Check file type (After prune logic)
find_args+=(-type f)

# 4. Add Excludes (-not -path)
for path in "${EXCLUDES[@]}"; do
    find_args+=(-not -path "$path")
done

# 5. Build the dynamic 'OR' logic for includes
if [ ${#INCLUDE_PATHS[@]} -gt 0 ]; then
    find_args+=(\()

    first=true
    for path in "${INCLUDE_PATHS[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            find_args+=(-o)
        fi

        if [[ "$path" == "FLAT:"* ]]; then
            clean_path="${path#FLAT:}"
            # Logic: Match files in this dir, but reject files in subdirs
            find_args+=(\( -path "${clean_path}/*" -not -path "${clean_path}/*/*" \))
        else
            find_args+=(-path "$path")
        fi
    done

    find_args+=(\))
fi

# 6. Final Print for the pipe
find_args+=(-print0)

# ==========================================
# EXECUTION
# ==========================================

log "Starting recursive search and concatenation..."

# Run find using the constructed array
find "${find_args[@]}" | while IFS= read -r -d '' file; do
    # ---------------------------------------------------------
    # CRITICAL FIX: Skip directories (Double check)
    # ---------------------------------------------------------
    if [ -d "$file" ]; then
        continue
    fi

    # Skip the output file, config file, and script itself
    case "$file" in
        "./$OUTPUT_FILE" | "./$CONFIG_FILE" | "./$0") continue ;;
    esac

    # ---------------------------------------------------------
    # LOGGING: CHECK FILE SIZE & PRINT PROGRESS
    # ---------------------------------------------------------

    # Clear the "Scanning: ..." line
    echo -ne "\r\033[K" >&2

    # Get file size in bytes (Cross-platform compatible)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        fsize=$(stat -f%z "$file") # MacOS
    else
        fsize=$(stat -c%s "$file") # Linux
    fi

    # Convert to readable format for log
    fsize_kb=$((fsize / 1024))

    # Log the file we are about to process
    # If a file is > 100KB, highlight it. Large files are usually the bottleneck.
    if [ "$fsize_kb" -gt 100 ]; then
        warn "Processing LARGE file (${fsize_kb}KB): $file"
    else
        echo -e "${GREEN}Processing:${NC} $file (${fsize} bytes)" >&2
    fi

    # ---------------------------------------------------------
    # WRITE CONTENT
    # ---------------------------------------------------------
    {
        echo "File: $file"
        echo "------------------------"
        cat "$file"
        echo -e "\n\n"
    } >>"$OUTPUT_FILE"

done

# Clear any leftover scanning text
echo -ne "\r\033[K" >&2

echo "Concatenating root-level files..." >>"$OUTPUT_FILE"
log "Finished recursive files. Starting root-level files..."

# ==========================================
# ROOT FILES EXECUTION
# ==========================================

root_args=(. -maxdepth 1 -type f \()
first=true
for ext in "${ROOT_EXTENSIONS[@]}"; do
    if [ "$first" = true ]; then
        root_args+=(-iname "$ext")
        first=false
    else
        root_args+=(-o -iname "$ext")
    fi
done
root_args+=(\))

find "${root_args[@]}" -print0 | while IFS= read -r -d '' file; do
    if [ -d "$file" ]; then continue; fi

    skip=false
    for exclude in "${ROOT_EXCLUDES[@]}"; do
        # shellcheck disable=SC2254
        case "$file" in
            $exclude | ./$exclude)
                skip=true
                break
                ;;
        esac
    done

    case "$file" in
        "./$OUTPUT_FILE" | "./$CONFIG_FILE" | "./$0") skip=true ;;
    esac

    if [ "$skip" = true ]; then
        continue
    fi

    echo -e "${GREEN}Processing Root File:${NC} $file" >&2

    {
        echo "File: ${file#./}"
        echo "------------------------"
        cat "$file"
        echo -e "\n\n"
    } >>"$OUTPUT_FILE"
done

log "DONE! All files concatenated into $OUTPUT_FILE"
