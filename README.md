# AI SEO — AEO/GEO Optimization Plugin

[![Version](https://img.shields.io/badge/version-1.0.0-blue?style=flat-square)](https://github.com/JHyeok5/claude-plugin-ai-seo)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey?style=flat-square)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?style=flat-square)]()

Make websites discoverable and citable by AI search engines (ChatGPT, Claude, Perplexity, Google AI Overview).

Unlike traditional SEO (ranking in search results), AI SEO ensures AI systems **recommend, cite, and accurately represent** your content when answering user questions.

## The Problem

```
Traditional SEO:  "best coffee shop tokyo" → Google shows 10 links → user clicks one
AI Search:        "best coffee shop tokyo" → ChatGPT gives ONE answer → cites 0-3 sources
```

Your site ranks #1 on Google but ChatGPT doesn't mention it. Why? AI engines need **different signals**: structured data, llms.txt, direct answers, not just keywords and backlinks.

## The Solution

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Run audit   │ --> │  Score 5/8   │ --> │  Fix issues  │ --> │  Score 8/8   │
│  First time  │     │  + .ai-seo/  │     │  with hints  │     │  + delta +2  │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
         │                   │                                        │
         └── config.json ────┘── history.json ────────────────────────┘
             (framework,          (score tracking,
              search paths)        issue diff)
```

## Key Features

| Feature | Description |
|---------|-------------|
| 4-Layer Audit | Technical, Content, Authority, Agentic scoring |
| Framework Detection | Auto-detects Vite, Next.js, Nuxt, Gatsby, static sites |
| Auto-Check Hook | Monitors robots.txt, llms.txt, HTML edits in real-time |
| Progress Tracking | `.ai-seo/history.json` — score delta across runs |
| Framework-Aware Hints | "Your Vite project should include a Sitemap directive..." |
| Zero Dependencies | Pure bash, runs anywhere with a shell |

## Installation

```bash
# From marketplace
/plugin install ai-seo@JHyeok5

# Or clone directly
git clone https://github.com/JHyeok5/claude-plugin-ai-seo.git
claude --plugin-dir ./claude-plugin-ai-seo
```

> **Note**: Restart Claude Code after installation to activate hooks.

## Usage

```
/ai-seo:ai-seo
```

Or just describe what you need — auto-triggers on AEO/GEO related tasks:

- "Check if my site shows up in ChatGPT"
- "Optimize my site for AI search engines"
- "Add llms.txt to my project"
- "Audit my site's AI discoverability"

### Standalone Script

```bash
bash scripts/check-ai-readiness.sh /path/to/project
```

## How It Works

```
[First Run]
  1. Detect framework (Vite/Next/Nuxt/Gatsby/static)
  2. Scan for robots.txt, llms.txt, sitemap, JSON-LD, meta tags
  3. Score 8 checks → create .ai-seo/config.json + history.json
  4. Output actionable report with framework-specific hints

[Subsequent Runs]
  1. Read .ai-seo/config.json → use saved searchPaths
  2. Run same 8 checks
  3. Compare with history → show delta (fixed/new issues)
  4. Update config + append history

[Hooks (automatic)]
  Edit robots.txt → warn if AI crawlers blocked
  Edit llms.txt   → warn if structure incomplete
  Edit .tsx/.html  → detect JSON-LD/SEO component patterns
```

## 4-Layer Framework

| Layer | Focus | Example |
|-------|-------|---------|
| 1. Technical | AI can access the site | robots.txt, llms.txt, sitemap, JSON-LD |
| 2. Content | AI understands the content | Q&A format, statistics, modularity |
| 3. Authority | AI trusts the site | Reviews, citations, expert content |
| 4. Agentic | AI uses the site as a tool | Public API, MCP server |

## Auto-Check Hook

When installed, the plugin automatically monitors edits to AI-relevant files:

| File | What It Checks |
|------|---------------|
| `robots.txt` | Warns if AI crawlers (GPTBot, ClaudeBot) are blocked |
| `llms.txt` | Warns if missing required structure (`# heading`, `> description`) |
| `*.tsx/.jsx/.vue` | Detects JSON-LD, `<Helmet>`, `<Head>` patterns |

Warnings are **framework-aware** — "Your Vite project should..." vs "Your Next.js project should...".

## Self-Improvement

The plugin creates `.ai-seo/` in your project on first run:

```
.ai-seo/
├── config.json    ← framework, search paths, asset flags
└── history.json   ← score + issues per run, delta tracking
```

Each subsequent run compares with previous scores and shows what changed.

## Script Output Example

**First run:**
```
# AI SEO Readiness Check

**Project**: /home/user/my-site
**Date**: 2026-03-12T10:30:00Z
**Framework**: vite
**Status**: First run -- creating .ai-seo/ config

## Layer 1: Technical Foundation
- [x] robots.txt exists
- [x] robots.txt allows AI crawlers (GPTBot/ClaudeBot/PerplexityBot)
- [ ] llms.txt exists
- [x] sitemap.xml exists (static or dynamic)

## Structured Data
- [x] JSON-LD structured data found
  - Found ~3 @type declarations

## Meta Tags
- [x] Open Graph tags found
- [x] hreflang tags found (multilingual)
- [ ] Canonical URL tags found

## Summary
**Score**: 6/8
**Readiness**: 75%

### Action Items
1. Fix: llms.txt exists
2. Fix: Canonical URL tags found
```

**Second run (after fixes):**
```
**Status**: Subsequent run -- using saved config

## Delta (vs 2026-03-12T10:30:00Z)
- Score: 6/8 -> 8/8 (+2)
- Fixed:
  - llms.txt exists
  - Canonical URL tags found

## Summary
**Score**: 8/8
**Readiness**: 100%
```

## Plugin Structure

```
claude-plugin-ai-seo/
├── .claude-plugin/
│   └── plugin.json          ← plugin manifest
├── skills/
│   └── ai-seo/
│       └── SKILL.md         ← skill definition (4-layer audit guide)
├── hooks/
│   └── hooks.json           ← PostToolUse hook config
├── scripts/
│   ├── check-ai-readiness.sh  ← standalone audit script
│   └── ai-seo-check-hook.sh  ← hook script (framework-aware)
├── references/
│   ├── layers-deep-dive.md  ← Layers 2-4 detailed guide
│   └── structured-data-patterns.md  ← JSON-LD templates
├── README.md
└── LICENSE
```

## Requirements

- Claude Code CLI
- Any web project (framework-agnostic)
- bash (for scripts)
- jq (optional — enhances config/history management, graceful fallback without it)

## License

MIT
