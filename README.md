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

## Requirements

- Claude Code CLI
- Any web project (framework-agnostic)

## License

MIT
