#!/usr/bin/env bash
# ai-seo-check-hook.sh — PostToolUse hook for Write|Edit
#
# Reads tool_input JSON from stdin, checks AI-relevant files for common issues.
# Outputs warnings/info to stderr. Always exits 0 (non-blocking).
#
# If .ai-seo/config.json exists, uses it for framework-aware hints
# and smarter file relevance detection via searchPaths.

set -uo pipefail

# Read JSON from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# ---------- Config discovery ----------

# Walk up from FILE_PATH to find .ai-seo/config.json
CONFIG_FILE=""
FRAMEWORK=""
CONFIG_SEARCH_PATHS=()

find_config() {
  local dir
  dir=$(dirname "$FILE_PATH")

  # Resolve to absolute if possible
  if [ -d "$dir" ]; then
    dir=$(cd "$dir" && pwd)
  fi

  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.ai-seo/config.json" ]; then
      CONFIG_FILE="$dir/.ai-seo/config.json"
      return
    fi
    # Also check for project root markers
    if [ -f "$dir/.git/HEAD" ] || [ -f "$dir/package.json" ]; then
      # This is likely the project root — check for config here
      if [ -f "$dir/.ai-seo/config.json" ]; then
        CONFIG_FILE="$dir/.ai-seo/config.json"
      fi
      return
    fi
    dir=$(dirname "$dir")
  done
}

find_config

# Load config values if found
if [ -n "$CONFIG_FILE" ]; then
  PROJECT_ROOT=$(dirname "$(dirname "$CONFIG_FILE")")

  # Read framework (simple grep fallback)
  if command -v jq >/dev/null 2>&1; then
    FRAMEWORK=$(jq -r '.framework // empty' "$CONFIG_FILE" 2>/dev/null)
    while IFS= read -r sp; do
      [ -z "$sp" ] && continue
      CONFIG_SEARCH_PATHS+=("$sp")
    done <<< "$(jq -r '.searchPaths[]? // empty' "$CONFIG_FILE" 2>/dev/null)"
  else
    FRAMEWORK=$(sed -n 's/.*"framework"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_FILE" 2>/dev/null | head -1)
    # Read searchPaths via simple extraction
    while IFS= read -r sp; do
      [ -z "$sp" ] && continue
      CONFIG_SEARCH_PATHS+=("$sp")
    done <<< "$(sed -n '/"searchPaths"/,/\]/p' "$CONFIG_FILE" 2>/dev/null | grep -o '"[^"]*"' | grep -v '"searchPaths"' | sed 's/"//g')"
  fi
fi

# ---------- Framework-aware hint prefix ----------

framework_hint() {
  case "$FRAMEWORK" in
    vite)   echo "Your Vite project" ;;
    next)   echo "Your Next.js project" ;;
    nuxt)   echo "Your Nuxt project" ;;
    gatsby) echo "Your Gatsby project" ;;
    static) echo "Your static site" ;;
    *)      echo "Your project" ;;
  esac
}

# ---------- File relevance check ----------

# Check if the edited file is within a known search path
is_in_search_path() {
  if [ ${#CONFIG_SEARCH_PATHS[@]} -eq 0 ]; then
    return 1
  fi
  if [ -z "$PROJECT_ROOT" ]; then
    return 1
  fi
  for sp in "${CONFIG_SEARCH_PATHS[@]}"; do
    local full_sp="$PROJECT_ROOT/$sp"
    case "$FILE_PATH" in
      "$full_sp"*) return 0 ;;
    esac
  done
  return 1
}

# Determine if this file is AI-relevant
is_ai_relevant() {
  # Always relevant by filename
  case "$BASENAME" in
    robots.txt|llms.txt|sitemap.xml|index.html|netlify.toml)
      return 0 ;;
    *.html)
      return 0 ;;
  esac

  # If config exists, also check files in search paths that contain SEO-relevant content
  if [ ${#CONFIG_SEARCH_PATHS[@]} -gt 0 ] && is_in_search_path; then
    # Check for SEO-related content patterns in the edited file
    case "$BASENAME" in
      *.tsx|*.jsx|*.ts|*.js|*.vue|*.svelte)
        if [ -f "$FILE_PATH" ] && grep -qE 'application/ld\+json|og:title|og:description|hreflang|canonical|<meta|<Helmet|<Head' "$FILE_PATH" 2>/dev/null; then
          return 0
        fi
        ;;
    esac
  fi

  return 1
}

# Only activate for AI-relevant files
if ! is_ai_relevant; then
  exit 0
fi

# ---------- robots.txt checks ----------
if [ "$BASENAME" = "robots.txt" ] && [ -f "$FILE_PATH" ]; then
  BLOCKED=""
  for BOT in GPTBot ClaudeBot PerplexityBot; do
    # Check if bot has a Disallow rule (not just comments)
    if grep -A1 -i "User-agent:.*${BOT}" "$FILE_PATH" 2>/dev/null | grep -qi "Disallow: /" 2>/dev/null; then
      BLOCKED="${BLOCKED} ${BOT}"
    fi
  done
  if [ -n "$BLOCKED" ]; then
    echo "[ai-seo] WARNING: robots.txt blocks AI crawlers:${BLOCKED}" >&2
    echo "[ai-seo] $(framework_hint) should allow these bots to be discoverable by AI search engines." >&2
  fi

  # Framework-specific robots.txt hints
  case "$FRAMEWORK" in
    vite)
      if ! grep -q "Sitemap:" "$FILE_PATH" 2>/dev/null; then
        echo "[ai-seo] HINT: $(framework_hint) should include a Sitemap: directive in robots.txt." >&2
      fi
      ;;
    next)
      echo "[ai-seo] INFO: $(framework_hint) can generate robots.txt via app/robots.ts — consider using the dynamic approach." >&2
      ;;
    nuxt)
      echo "[ai-seo] INFO: $(framework_hint) can use @nuxtjs/robots module for dynamic robots.txt generation." >&2
      ;;
  esac
fi

# ---------- llms.txt checks ----------
if [ "$BASENAME" = "llms.txt" ] && [ -f "$FILE_PATH" ]; then
  # Check if file is empty
  if [ ! -s "$FILE_PATH" ]; then
    echo "[ai-seo] WARNING: llms.txt is empty. AI engines need structured content to understand your site." >&2
  else
    MISSING=""
    if ! grep -q "^# " "$FILE_PATH" 2>/dev/null; then
      MISSING="${MISSING} '# heading'"
    fi
    if ! grep -q "^> " "$FILE_PATH" 2>/dev/null; then
      MISSING="${MISSING} '> description'"
    fi
    if [ -n "$MISSING" ]; then
      echo "[ai-seo] WARNING: llms.txt is missing required sections:${MISSING}" >&2
      echo "[ai-seo] See https://llmstxt.org/ for the expected format." >&2
    fi
  fi

  # Framework-specific placement hint
  case "$FRAMEWORK" in
    vite)
      if ! echo "$FILE_PATH" | grep -q "/public/"; then
        echo "[ai-seo] HINT: $(framework_hint) should place llms.txt in the public/ directory so it's served at the site root." >&2
      fi
      ;;
    next)
      if ! echo "$FILE_PATH" | grep -q "/public/\|/app/"; then
        echo "[ai-seo] HINT: $(framework_hint) should place llms.txt in public/ or serve it via app/llms.txt/route.ts." >&2
      fi
      ;;
  esac
fi

# ---------- HTML files: JSON-LD info ----------
case "$BASENAME" in
  *.html|index.html)
    if [ -f "$FILE_PATH" ]; then
      if grep -q "application/ld+json" "$FILE_PATH" 2>/dev/null; then
        echo "[ai-seo] INFO: JSON-LD structured data detected in ${BASENAME}. Validate at https://search.google.com/test/rich-results" >&2
      fi
    fi
    ;;
esac

# ---------- Component files with SEO content ----------
case "$BASENAME" in
  *.tsx|*.jsx|*.ts|*.js|*.vue|*.svelte)
    if [ -f "$FILE_PATH" ]; then
      if grep -q "application/ld+json" "$FILE_PATH" 2>/dev/null; then
        echo "[ai-seo] INFO: JSON-LD structured data detected in ${BASENAME}. Validate at https://search.google.com/test/rich-results" >&2
      fi
      # Check for missing canonical in components that set meta tags
      if grep -qE '<Helmet|<Head|<NextHead|useHead' "$FILE_PATH" 2>/dev/null; then
        if ! grep -q 'canonical' "$FILE_PATH" 2>/dev/null; then
          echo "[ai-seo] HINT: ${BASENAME} sets meta tags but is missing a canonical URL. AI engines use canonical URLs to avoid duplicate content." >&2
        fi
      fi
    fi
    ;;
esac

exit 0
