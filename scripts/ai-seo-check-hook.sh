#!/usr/bin/env bash
# ai-seo-check-hook.sh — PostToolUse hook for Write|Edit
#
# Reads tool_input JSON from stdin, checks AI-relevant files for common issues.
# Outputs warnings/info to stderr. Always exits 0 (non-blocking).

set -uo pipefail

# Read JSON from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# Only activate for AI-relevant files
case "$BASENAME" in
  robots.txt|llms.txt|sitemap.xml|index.html|netlify.toml) ;;
  *.html) ;;
  *) exit 0 ;;
esac

# --- robots.txt checks ---
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
    echo "[ai-seo] Blocking these bots removes your site from their AI responses." >&2
  fi
fi

# --- llms.txt checks ---
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
fi

# --- HTML files: JSON-LD info ---
case "$BASENAME" in
  *.html|index.html)
    if [ -f "$FILE_PATH" ]; then
      if grep -q "application/ld+json" "$FILE_PATH" 2>/dev/null; then
        echo "[ai-seo] INFO: JSON-LD structured data detected in ${BASENAME}. Validate at https://search.google.com/test/rich-results" >&2
      fi
    fi
    ;;
esac

exit 0
