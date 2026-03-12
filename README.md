# AI SEO — AEO/GEO Optimization Plugin

Make websites discoverable and citable by AI search engines (ChatGPT, Claude, Perplexity, Google AI Overview).

Unlike traditional SEO (ranking in search results), AI SEO ensures AI systems **recommend, cite, and accurately represent** your content when answering user questions.

## What This Plugin Does

- Audits your site's AI discoverability with a 4-layer scoring framework
- Guides `llms.txt`, `robots.txt` AI crawler policy, and structured data setup
- Provides content optimization patterns for AI citation
- Tracks improvement over time with `.ai-seo/` project config
- Covers agentic integration (MCP servers, public APIs)

## Installation

```bash
/plugin install ai-seo@JHyeok5
```

Or load directly:

```bash
claude --plugin-dir ./claude-plugin-ai-seo
```

## Usage

```
/ai-seo:ai-seo
```

Or just describe what you need — the skill auto-triggers on AEO/GEO related tasks:

- "Check if my site shows up in ChatGPT"
- "Optimize my site for AI search engines"
- "Add llms.txt to my project"
- "Audit my site's AI discoverability"

## 4-Layer Framework

| Layer | Focus | Example |
|-------|-------|---------|
| 1. Technical | AI can access the site | robots.txt, llms.txt, sitemap, JSON-LD |
| 2. Content | AI understands the content | Q&A format, statistics, modularity |
| 3. Authority | AI trusts the site | Reviews, citations, expert content |
| 4. Agentic | AI uses the site as a tool | Public API, MCP server |

## Self-Improvement

The skill creates `.ai-seo/` in your project on first run:
- `config.json` — detected project structure
- `history.json` — audit scores over time
- `test-prompts.md` — AI engine test prompts for your domain

Each subsequent run compares with previous scores and shows improvement delta.

## Auto-Check Hook

When installed, the plugin automatically monitors edits to AI-relevant files:

| File | What it checks |
|------|---------------|
| `robots.txt` | Warns if AI crawlers (GPTBot, ClaudeBot) are blocked |
| `llms.txt` | Warns if missing required structure |
| `*.html` | Notifies when JSON-LD structured data is modified |

No manual invocation needed — works in the background.

## Script Output Example

Running `bash scripts/check-ai-readiness.sh /path/to/project` produces:

```
# AI SEO Readiness Check

**Project**: /path/to/project
**Date**: 2026-03-12T10:30:00Z

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

## Requirements

- Claude Code CLI
- Any web project (framework-agnostic)

## License

MIT
