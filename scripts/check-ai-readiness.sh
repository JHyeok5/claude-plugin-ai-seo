#!/usr/bin/env bash
# check-ai-readiness.sh — Quick AI SEO readiness check
#
# Usage:
#   bash check-ai-readiness.sh [project-root]
#
# Checks for AI discoverability essentials in a web project.
# Outputs a markdown checklist to stdout.
# Exit code: 0 = all pass, 1 = issues found
#
# On first run, creates .ai-seo/config.json and .ai-seo/history.json.
# On subsequent runs, reads config for optimized search paths and shows delta.

set -uo pipefail

ROOT="${1:-.}"
# Resolve to absolute path
ROOT=$(cd "$ROOT" && pwd)
SCORE=0
TOTAL=0
ISSUES=()

CONFIG_DIR="$ROOT/.ai-seo"
CONFIG_FILE="$CONFIG_DIR/config.json"
HISTORY_FILE="$CONFIG_DIR/history.json"

# ---------- JSON helpers (jq with printf fallback) ----------

has_jq() { command -v jq >/dev/null 2>&1; }

# Read a string value from a JSON file by key (top-level only)
json_read() {
  local file="$1" key="$2"
  if has_jq; then
    jq -r ".$key // empty" "$file" 2>/dev/null
  else
    # Fallback: simple grep/sed for "key": "value" or "key": true/false/number
    sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$file" 2>/dev/null | head -1
  fi
}

# Read a boolean value from a JSON file by key
json_read_bool() {
  local file="$1" key="$2"
  if has_jq; then
    jq -r ".$key // empty" "$file" 2>/dev/null
  else
    sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p" "$file" 2>/dev/null | head -1
  fi
}

# Read a JSON array as newline-separated values
json_read_array() {
  local file="$1" key="$2"
  if has_jq; then
    jq -r ".$key[]? // empty" "$file" 2>/dev/null
  else
    # Fallback: extract array contents, split by comma, strip quotes/whitespace
    sed -n "/\"$key\"/,/\]/p" "$file" 2>/dev/null \
      | grep -o '"[^"]*"' \
      | sed 's/"//g'
  fi
}

# Read the last run's score from history.json
history_last_score() {
  if [ ! -f "$HISTORY_FILE" ]; then
    echo ""
    return
  fi
  if has_jq; then
    jq -r '.runs[-1].score // empty' "$HISTORY_FILE" 2>/dev/null
  else
    # Fallback: find the last "score" line
    grep -o '"score"[[:space:]]*:[[:space:]]*[0-9]*' "$HISTORY_FILE" 2>/dev/null \
      | tail -1 \
      | sed 's/.*:[[:space:]]*//'
  fi
}

history_last_total() {
  if [ ! -f "$HISTORY_FILE" ]; then
    echo ""
    return
  fi
  if has_jq; then
    jq -r '.runs[-1].total // empty' "$HISTORY_FILE" 2>/dev/null
  else
    grep -o '"total"[[:space:]]*:[[:space:]]*[0-9]*' "$HISTORY_FILE" 2>/dev/null \
      | tail -1 \
      | sed 's/.*:[[:space:]]*//'
  fi
}

history_last_timestamp() {
  if [ ! -f "$HISTORY_FILE" ]; then
    echo ""
    return
  fi
  if has_jq; then
    jq -r '.runs[-1].timestamp // empty' "$HISTORY_FILE" 2>/dev/null
  else
    grep -o '"timestamp"[[:space:]]*:[[:space:]]*"[^"]*"' "$HISTORY_FILE" 2>/dev/null \
      | tail -1 \
      | sed 's/.*"timestamp"[[:space:]]*:[[:space:]]*"//;s/"$//'
  fi
}

history_last_issues() {
  if [ ! -f "$HISTORY_FILE" ]; then
    echo ""
    return
  fi
  if has_jq; then
    jq -r '.runs[-1].issues[]? // empty' "$HISTORY_FILE" 2>/dev/null
  else
    # Fallback: extract the last issues array block
    # Find the last "issues" key and grab its array contents
    local in_last_issues=false
    local bracket_depth=0
    local result=""
    while IFS= read -r line; do
      if echo "$line" | grep -q '"issues"'; then
        in_last_issues=true
        bracket_depth=0
        result=""
      fi
      if [ "$in_last_issues" = true ]; then
        if echo "$line" | grep -q '\['; then
          bracket_depth=$((bracket_depth + 1))
        fi
        if echo "$line" | grep -q '\]'; then
          bracket_depth=$((bracket_depth - 1))
          if [ "$bracket_depth" -le 0 ]; then
            in_last_issues=false
          fi
        fi
        # Extract quoted strings that aren't "issues"
        local extracted
        extracted=$(echo "$line" | grep -o '"[^"]*"' | grep -v '"issues"' | sed 's/"//g')
        if [ -n "$extracted" ]; then
          result="${result}${extracted}"$'\n'
        fi
      fi
    done < "$HISTORY_FILE"
    echo "$result"
  fi
}

# ---------- Framework detection ----------

detect_framework() {
  local root="$1"
  if [ -f "$root/vite.config.ts" ] || [ -f "$root/vite.config.js" ] || [ -f "$root/vite.config.mts" ]; then
    echo "vite"
  elif [ -f "$root/next.config.js" ] || [ -f "$root/next.config.ts" ] || [ -f "$root/next.config.mjs" ]; then
    echo "next"
  elif [ -f "$root/nuxt.config.ts" ] || [ -f "$root/nuxt.config.js" ]; then
    echo "nuxt"
  elif [ -f "$root/gatsby-config.js" ] || [ -f "$root/gatsby-config.ts" ]; then
    echo "gatsby"
  elif [ -f "$root/index.html" ] && [ ! -f "$root/package.json" ]; then
    echo "static"
  else
    echo "unknown"
  fi
}

# ---------- Config management ----------

IS_FIRST_RUN=false

load_or_create_config() {
  if [ -f "$CONFIG_FILE" ]; then
    IS_FIRST_RUN=false
    return
  fi

  IS_FIRST_RUN=true
  mkdir -p "$CONFIG_DIR"

  local framework
  framework=$(detect_framework "$ROOT")

  local has_robots=false has_llms=false has_sitemap=false has_jsonld=false

  # Check for robots.txt
  if [ -f "$ROOT/public/robots.txt" ] || [ -f "$ROOT/robots.txt" ] || [ -f "$ROOT/static/robots.txt" ]; then
    has_robots=true
  fi

  # Check for llms.txt
  if find "$ROOT" -maxdepth 2 -name "llms.txt" -not -path "*node_modules*" -not -path "*/.git/*" 2>/dev/null | grep -q .; then
    has_llms=true
  fi

  # Check for sitemap.xml
  if find "$ROOT" -maxdepth 2 -name "sitemap.xml" -not -path "*node_modules*" -not -path "*/.git/*" 2>/dev/null | grep -q .; then
    has_sitemap=true
  fi

  # Build search paths for config
  local search_paths_json="["
  local first=true
  for candidate in "src" "app" "pages" "public/index.html" "index.html"; do
    if [ -e "$ROOT/$candidate" ]; then
      if [ "$first" = true ]; then
        first=false
      else
        search_paths_json="$search_paths_json, "
      fi
      search_paths_json="$search_paths_json\"$candidate\""
    fi
  done
  search_paths_json="$search_paths_json]"

  # Check for JSON-LD in search paths
  local search_args=()
  for candidate in "src" "app" "pages" "public/index.html" "index.html"; do
    if [ -e "$ROOT/$candidate" ]; then
      search_args+=("$ROOT/$candidate")
    fi
  done
  if [ ${#search_args[@]} -gt 0 ] && grep -rq "application/ld+json" "${search_args[@]}" 2>/dev/null; then
    has_jsonld=true
  fi

  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  if has_jq; then
    jq -n \
      --arg ts "$timestamp" \
      --arg pr "$ROOT" \
      --arg fw "$framework" \
      --argjson hr "$has_robots" \
      --argjson hl "$has_llms" \
      --argjson hs "$has_sitemap" \
      --argjson hj "$has_jsonld" \
      --argjson sp "$search_paths_json" \
      '{
        detectedAt: $ts,
        projectRoot: $pr,
        framework: $fw,
        hasRobotsTxt: $hr,
        hasLlmsTxt: $hl,
        hasSitemap: $hs,
        hasJsonLd: $hj,
        searchPaths: $sp
      }' > "$CONFIG_FILE"
  else
    printf '{\n' > "$CONFIG_FILE"
    printf '  "detectedAt": "%s",\n' "$timestamp" >> "$CONFIG_FILE"
    printf '  "projectRoot": "%s",\n' "$ROOT" >> "$CONFIG_FILE"
    printf '  "framework": "%s",\n' "$framework" >> "$CONFIG_FILE"
    printf '  "hasRobotsTxt": %s,\n' "$has_robots" >> "$CONFIG_FILE"
    printf '  "hasLlmsTxt": %s,\n' "$has_llms" >> "$CONFIG_FILE"
    printf '  "hasSitemap": %s,\n' "$has_sitemap" >> "$CONFIG_FILE"
    printf '  "hasJsonLd": %s,\n' "$has_jsonld" >> "$CONFIG_FILE"
    printf '  "searchPaths": %s\n' "$search_paths_json" >> "$CONFIG_FILE"
    printf '}\n' >> "$CONFIG_FILE"
  fi
}

update_config_field() {
  local key="$1" value="$2"
  if [ ! -f "$CONFIG_FILE" ]; then return; fi
  if has_jq; then
    local tmp
    tmp=$(mktemp)
    # Detect if value is a boolean
    if [ "$value" = "true" ] || [ "$value" = "false" ]; then
      jq --argjson v "$value" ".$key = \$v" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    else
      jq --arg v "$value" ".$key = \$v" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    fi
  else
    # Fallback: sed in-place replacement for boolean/string values
    if [ "$value" = "true" ] || [ "$value" = "false" ]; then
      sed -i "s/\"$key\"[[:space:]]*:[[:space:]]*[a-z]*/\"$key\": $value/" "$CONFIG_FILE" 2>/dev/null
    else
      sed -i "s|\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"|\"$key\": \"$value\"|" "$CONFIG_FILE" 2>/dev/null
    fi
  fi
}

# ---------- History management ----------

save_history() {
  local timestamp score total
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  score="$SCORE"
  total="$TOTAL"

  mkdir -p "$CONFIG_DIR"

  # Build issues JSON array
  local issues_json="["
  local first=true
  for issue in "${ISSUES[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      issues_json="$issues_json, "
    fi
    issues_json="$issues_json\"$issue\""
  done
  issues_json="$issues_json]"

  if [ ! -f "$HISTORY_FILE" ]; then
    # Create new history file
    if has_jq; then
      jq -n \
        --arg ts "$timestamp" \
        --argjson sc "$score" \
        --argjson tl "$total" \
        --argjson is "$issues_json" \
        '{runs: [{timestamp: $ts, score: $sc, total: $tl, issues: $is}]}' > "$HISTORY_FILE"
    else
      printf '{\n  "runs": [\n    {\n' > "$HISTORY_FILE"
      printf '      "timestamp": "%s",\n' "$timestamp" >> "$HISTORY_FILE"
      printf '      "score": %s,\n' "$score" >> "$HISTORY_FILE"
      printf '      "total": %s,\n' "$total" >> "$HISTORY_FILE"
      printf '      "issues": %s\n' "$issues_json" >> "$HISTORY_FILE"
      printf '    }\n  ]\n}\n' >> "$HISTORY_FILE"
    fi
  else
    # Append to existing history
    if has_jq; then
      local tmp
      tmp=$(mktemp)
      jq \
        --arg ts "$timestamp" \
        --argjson sc "$score" \
        --argjson tl "$total" \
        --argjson is "$issues_json" \
        '.runs += [{timestamp: $ts, score: $sc, total: $tl, issues: $is}]' \
        "$HISTORY_FILE" > "$tmp" && mv "$tmp" "$HISTORY_FILE"
    else
      # Fallback: insert new entry before the closing "]}"
      local new_entry
      new_entry=$(printf ',\n    {\n      "timestamp": "%s",\n      "score": %s,\n      "total": %s,\n      "issues": %s\n    }' \
        "$timestamp" "$score" "$total" "$issues_json")
      # Insert before the last ] in the file
      sed -i "s|\(.*\)\]|\\1${new_entry}\n  ]|" "$HISTORY_FILE" 2>/dev/null
    fi
  fi
}

# ---------- Delta display ----------

show_delta() {
  local prev_score prev_total prev_timestamp
  prev_score=$(history_last_score)
  prev_total=$(history_last_total)
  prev_timestamp=$(history_last_timestamp)

  if [ -z "$prev_score" ] || [ -z "$prev_total" ]; then
    return
  fi

  echo ""
  echo "## Delta (vs ${prev_timestamp})"
  echo ""

  local diff=$((SCORE - prev_score))
  if [ "$diff" -gt 0 ]; then
    echo "- Score: ${prev_score}/${prev_total} -> ${SCORE}/${TOTAL} (+${diff})"
  elif [ "$diff" -lt 0 ]; then
    echo "- Score: ${prev_score}/${prev_total} -> ${SCORE}/${TOTAL} (${diff})"
  else
    echo "- Score: ${SCORE}/${TOTAL} (unchanged)"
  fi

  # Find fixed issues (were in previous, not in current)
  local prev_issues_list
  prev_issues_list=$(history_last_issues)
  local fixed=()
  while IFS= read -r prev_issue; do
    [ -z "$prev_issue" ] && continue
    local still_broken=false
    for current_issue in "${ISSUES[@]}"; do
      if [ "$current_issue" = "$prev_issue" ]; then
        still_broken=true
        break
      fi
    done
    if [ "$still_broken" = false ]; then
      fixed+=("$prev_issue")
    fi
  done <<< "$prev_issues_list"

  # Find new issues (in current, not in previous)
  local new_issues=()
  for current_issue in "${ISSUES[@]}"; do
    local was_broken=false
    while IFS= read -r prev_issue; do
      [ -z "$prev_issue" ] && continue
      if [ "$current_issue" = "$prev_issue" ]; then
        was_broken=true
        break
      fi
    done <<< "$prev_issues_list"
    if [ "$was_broken" = false ]; then
      new_issues+=("$current_issue")
    fi
  done

  if [ ${#fixed[@]} -gt 0 ]; then
    echo "- Fixed:"
    for f in "${fixed[@]}"; do
      echo "  - $f"
    done
  fi

  if [ ${#new_issues[@]} -gt 0 ]; then
    echo "- New issues:"
    for n in "${new_issues[@]}"; do
      echo "  - $n"
    done
  fi

  if [ ${#fixed[@]} -eq 0 ] && [ ${#new_issues[@]} -eq 0 ] && [ "$diff" -eq 0 ]; then
    echo "- No changes since last run"
  fi
}

# ---------- Main check logic ----------

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

# Load or create config (must come before search path setup)
load_or_create_config

# Read framework from config for context-aware hints
FRAMEWORK=""
if [ -f "$CONFIG_FILE" ]; then
  FRAMEWORK=$(json_read "$CONFIG_FILE" "framework")
fi

# Build search paths: use config if available, otherwise scan
SEARCH_PATHS=()
if [ -f "$CONFIG_FILE" ] && [ "$IS_FIRST_RUN" = false ]; then
  # Use saved search paths from config
  while IFS= read -r sp; do
    [ -z "$sp" ] && continue
    if [ -e "$ROOT/$sp" ]; then
      SEARCH_PATHS+=("$ROOT/$sp")
    fi
  done <<< "$(json_read_array "$CONFIG_FILE" "searchPaths")"
fi

# Fallback: scan if no config paths or config is empty
if [ ${#SEARCH_PATHS[@]} -eq 0 ]; then
  [ -f "$ROOT/index.html" ] && SEARCH_PATHS+=("$ROOT/index.html")
  [ -f "$ROOT/public/index.html" ] && SEARCH_PATHS+=("$ROOT/public/index.html")
  [ -d "$ROOT/src" ] && SEARCH_PATHS+=("$ROOT/src")
  [ -d "$ROOT/app" ] && SEARCH_PATHS+=("$ROOT/app")
  [ -d "$ROOT/pages" ] && SEARCH_PATHS+=("$ROOT/pages")
fi

# Capture previous run data for delta BEFORE printing anything
PREV_SCORE=$(history_last_score)

echo "# AI SEO Readiness Check"
echo ""
echo "**Project**: $ROOT"
echo "**Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
if [ -n "$FRAMEWORK" ] && [ "$FRAMEWORK" != "unknown" ]; then
  echo "**Framework**: $FRAMEWORK"
fi
if [ "$IS_FIRST_RUN" = true ]; then
  echo "**Status**: First run -- creating .ai-seo/ config"
else
  echo "**Status**: Subsequent run -- using saved config"
fi
echo ""

# --- File Existence ---
echo "## Layer 1: Technical Foundation"
echo ""

# robots.txt
HAS_ROBOTS=false
if [ -f "$ROOT/public/robots.txt" ] || [ -f "$ROOT/robots.txt" ] || [ -f "$ROOT/static/robots.txt" ]; then
  ROBOTS_FILE=$(find "$ROOT" -maxdepth 2 -name "robots.txt" -not -path "*node_modules*" -not -path "*/.git/*" 2>/dev/null | head -1)
  check "robots.txt exists" "pass"
  HAS_ROBOTS=true

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
HAS_LLMS=false
if find "$ROOT" -maxdepth 2 -name "llms.txt" -not -path "*node_modules*" -not -path "*/.git/*" 2>/dev/null | grep -q .; then
  check "llms.txt exists" "pass"
  HAS_LLMS=true
else
  check "llms.txt exists" "fail"
fi

# sitemap.xml
HAS_SITEMAP=false
if find "$ROOT" -maxdepth 2 -name "sitemap.xml" -not -path "*node_modules*" -not -path "*/.git/*" 2>/dev/null | grep -q . || \
   grep -rq "sitemap" "$ROOT/netlify.toml" 2>/dev/null || \
   grep -rq "sitemap" "$ROOT/next.config" 2>/dev/null; then
  check "sitemap.xml exists (static or dynamic)" "pass"
  HAS_SITEMAP=true
else
  check "sitemap.xml exists" "fail"
fi

# JSON-LD
echo ""
echo "## Structured Data"
echo ""

HAS_JSONLD=false
if [ ${#SEARCH_PATHS[@]} -gt 0 ] && grep -rq "application/ld+json" "${SEARCH_PATHS[@]}" 2>/dev/null; then
  check "JSON-LD structured data found" "pass"
  HAS_JSONLD=true
  LD_COUNT=$(grep -roh '"@type"' "${SEARCH_PATHS[@]}" 2>/dev/null | wc -l)
  echo "  - Found ~${LD_COUNT} @type declarations"
else
  check "JSON-LD structured data found" "fail"
fi

# Meta tags
echo ""
echo "## Meta Tags"
echo ""

if [ ${#SEARCH_PATHS[@]} -gt 0 ] && grep -rq 'og:title\|og:description' "${SEARCH_PATHS[@]}" 2>/dev/null; then
  check "Open Graph tags found" "pass"
else
  check "Open Graph tags found" "fail"
fi

if [ ${#SEARCH_PATHS[@]} -gt 0 ] && grep -rq 'hreflang' "${SEARCH_PATHS[@]}" 2>/dev/null; then
  check "hreflang tags found (multilingual)" "pass"
else
  check "hreflang tags found (multilingual)" "skip -- single language site?"
fi

if [ ${#SEARCH_PATHS[@]} -gt 0 ] && grep -rq 'canonical' "${SEARCH_PATHS[@]}" 2>/dev/null; then
  check "Canonical URL tags found" "pass"
else
  check "Canonical URL tags found" "fail"
fi

# --- Delta (before summary, after scoring) ---
if [ -n "$PREV_SCORE" ]; then
  show_delta
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

# --- Save history and update config ---
save_history

# Update config booleans to reflect current state
if [ -f "$CONFIG_FILE" ]; then
  update_config_field "hasRobotsTxt" "$HAS_ROBOTS"
  update_config_field "hasLlmsTxt" "$HAS_LLMS"
  update_config_field "hasSitemap" "$HAS_SITEMAP"
  update_config_field "hasJsonLd" "$HAS_JSONLD"
fi

# Exit code
if [ "$SCORE" -eq "$TOTAL" ]; then
  exit 0
else
  exit 1
fi
