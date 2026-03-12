#!/usr/bin/env bash
# check-ai-readiness.sh — Quick AI SEO readiness check
#
# Usage:
#   bash check-ai-readiness.sh [project-root]
#
# Checks for AI discoverability essentials in a web project.
# Outputs a markdown checklist to stdout.
# Exit code: 0 = all pass, 1 = issues found

set -euo pipefail

ROOT="${1:-.}"
SCORE=0
TOTAL=0
ISSUES=()

check() {
  local label="$1"
  local result="$2"
  TOTAL=$((TOTAL + 1))
  if [ "$result" = "pass" ]; then
    SCORE=$((SCORE + 1))
    echo "- [x] $label"
  else
    echo "- [ ] $label"
    ISSUES+=("$label")
  fi
}

echo "# AI SEO Readiness Check"
echo ""
echo "**Project**: $(cd "$ROOT" && pwd)"
echo "**Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# --- File Existence ---
echo "## Layer 1: Technical Foundation"
echo ""

# robots.txt
if [ -f "$ROOT/public/robots.txt" ] || [ -f "$ROOT/robots.txt" ] || [ -f "$ROOT/static/robots.txt" ]; then
  ROBOTS_FILE=$(find "$ROOT" -maxdepth 2 -name "robots.txt" -not -path "*node_modules*" -not -path "*/.git/*" | head -1)
  check "robots.txt exists" "pass"

  # Check for AI bot entries
  if grep -qi "GPTBot\|ClaudeBot\|PerplexityBot" "$ROBOTS_FILE" 2>/dev/null; then
    check "robots.txt allows AI crawlers (GPTBot/ClaudeBot/PerplexityBot)" "pass"
  else
    check "robots.txt allows AI crawlers (GPTBot/ClaudeBot/PerplexityBot)" "fail"
  fi
else
  check "robots.txt exists" "fail"
  check "robots.txt allows AI crawlers" "fail"
fi

# llms.txt
if find "$ROOT" -maxdepth 2 -name "llms.txt" -not -path "*node_modules*" -not -path "*/.git/*" | grep -q .; then
  check "llms.txt exists" "pass"
else
  check "llms.txt exists" "fail"
fi

# sitemap.xml
if find "$ROOT" -maxdepth 2 -name "sitemap.xml" -not -path "*node_modules*" -not -path "*/.git/*" | grep -q . || \
   grep -rq "sitemap" "$ROOT/netlify.toml" 2>/dev/null || \
   grep -rq "sitemap" "$ROOT/next.config" 2>/dev/null; then
  check "sitemap.xml exists (static or dynamic)" "pass"
else
  check "sitemap.xml exists" "fail"
fi

# JSON-LD
echo ""
echo "## Structured Data"
echo ""

if grep -rq "application/ld+json" "$ROOT/index.html" "$ROOT/public/index.html" "$ROOT/src" 2>/dev/null; then
  check "JSON-LD structured data found" "pass"

  # Count schema types
  LD_COUNT=$(grep -roh '"@type"' "$ROOT/index.html" "$ROOT/public/index.html" "$ROOT/src" 2>/dev/null | wc -l)
  echo "  - Found ~${LD_COUNT} @type declarations"
else
  check "JSON-LD structured data found" "fail"
fi

# Meta tags
echo ""
echo "## Meta Tags"
echo ""

if grep -rq 'og:title\|og:description' "$ROOT/index.html" "$ROOT/public/index.html" "$ROOT/src" 2>/dev/null; then
  check "Open Graph tags found" "pass"
else
  check "Open Graph tags found" "fail"
fi

if grep -rq 'hreflang' "$ROOT/index.html" "$ROOT/public/index.html" "$ROOT/src" 2>/dev/null; then
  check "hreflang tags found (multilingual)" "pass"
else
  check "hreflang tags found (multilingual)" "skip — single language site?"
fi

if grep -rq 'canonical' "$ROOT/index.html" "$ROOT/public/index.html" "$ROOT/src" 2>/dev/null; then
  check "Canonical URL tags found" "pass"
else
  check "Canonical URL tags found" "fail"
fi

# --- Summary ---
echo ""
echo "## Summary"
echo ""
echo "**Score**: ${SCORE}/${TOTAL}"
PERCENT=$((SCORE * 100 / TOTAL))
echo "**Readiness**: ${PERCENT}%"

if [ ${#ISSUES[@]} -gt 0 ]; then
  echo ""
  echo "### Action Items"
  for issue in "${ISSUES[@]}"; do
    echo "1. Fix: $issue"
  done
fi

# Exit code
if [ "$SCORE" -eq "$TOTAL" ]; then
  exit 0
else
  exit 1
fi
