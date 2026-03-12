---
name: ai-seo
description: Optimize websites for AI search engines (ChatGPT, Claude, Perplexity, Google AI Overview). This skill should be used when implementing AEO (Answer Engine Optimization) or GEO (Generative Engine Optimization) — making content discoverable, citable, and recommendable by AI systems. Covers llms.txt, AI crawler policies, structured data for AI, content optimization, agentic integration (MCP), and measurement. Complements traditional SEO skills with AI-specific optimization layers.
license: MIT
metadata:
  author: JHyeok5
  version: "1.0.0"
  tags: [seo, aeo, geo, ai-search, llms-txt, structured-data, mcp]
  platforms: Claude, ChatGPT, Gemini
---

# AI SEO — AEO/GEO Optimization

Make websites discoverable and citable by AI search engines. Unlike traditional SEO (ranking in search results), AI SEO ensures AI systems **recommend, cite, and accurately represent** content when answering user questions.

## When to Use

- **New website launch**: Set up AI discoverability from day one
- **AI visibility audit**: Check if ChatGPT/Claude/Perplexity knows about the site
- **Content strategy**: Optimize content structure for AI citation
- **Competitive analysis**: Compare AI visibility against competitors
- **After traditional SEO**: Add the AI-specific optimization layer
- **Multilingual site**: Ensure AI engines understand all language versions

## Why AI SEO Differs from Traditional SEO

| Aspect | Traditional SEO | AI SEO (AEO/GEO) |
|--------|----------------|-------------------|
| Goal | Rank in search results | Be cited/recommended by AI |
| Audience | Search engine crawlers | LLM training + real-time inference |
| Signal | Backlinks, keywords, PageRank | Structured data, authority, freshness |
| Format | HTML meta tags, anchor text | llms.txt, JSON-LD, public APIs |
| Measurement | SERP position, click-through | AI engine test prompts, citation accuracy |
| Update cycle | Index in hours/days | Training data months + real-time RAG |

## Quick Start (5-Minute Wins)

Complete these 3 steps to immediately improve AI discoverability. No coding experience required.

### 1. Create `llms.txt` (2 minutes)

Place a plain text file at the site root (e.g., `https://example.com/llms.txt`).
This file tells AI systems what the site is, what it offers, and where to find key content.

```txt
# [Site Name]

> [One-sentence description of what the site does]

## About
[2-3 sentences: purpose, target audience, unique value proposition]

## Key Features
- [Feature 1]: [brief description]
- [Feature 2]: [brief description]
- [Feature 3]: [brief description]

## Main Content
- [Content type 1]: [URL]
- [Content type 2]: [URL]

## Links
- Website: [URL]
- Documentation: [URL] (if applicable)
- API: [URL] (if applicable)

## Contact
- Email: [email]
```

**Why this matters**: AI engines like Perplexity and ChatGPT read `llms.txt` to understand a site's purpose and structure before deciding whether to recommend it.

### 2. Update `robots.txt` (1 minute)

Add explicit permission for AI crawlers. Without this, AI systems may skip the site entirely.

```txt
# AI Crawlers — Explicitly Allow
User-agent: GPTBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: Bytespider
Allow: /

# Standard crawlers
User-agent: *
Allow: /
Disallow: /private/
Disallow: /api/internal/

Sitemap: https://example.com/sitemap.xml
```

**Why this matters**: Many hosting platforms block AI crawlers by default. Explicit `Allow` ensures the content reaches AI systems.

### 3. Add Basic Structured Data (2 minutes)

Add JSON-LD to the homepage `<head>`. This helps AI engines understand what the site is at a glance.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "[Site Name]",
  "url": "https://example.com",
  "description": "[Site description with specific numbers and facts]",
  "potentialAction": {
    "@type": "SearchAction",
    "target": "https://example.com/search?q={search_term_string}",
    "query-input": "required name=search_term_string"
  }
}
</script>
```

**Why this matters**: JSON-LD is the format AI systems most reliably parse. It converts unstructured HTML into machine-readable facts.

## 4-Layer Framework

A systematic approach from foundational to advanced. Complete each layer before moving to the next.

```
Layer 4: Agentic       AI uses the site as a tool (MCP, API)
Layer 3: Authority      AI trusts the site (citations, reviews, data exclusivity)
Layer 2: Content        AI understands the content (Q&A, statistics, modularity)
Layer 1: Technical      AI can access the site (crawlers, structured data, sitemap)
```

### Layer 1: Technical Foundation

Ensure AI systems can crawl, parse, and understand the site structure.

**Checklist:**

- [ ] `robots.txt` explicitly allows AI crawlers (GPTBot, ClaudeBot, PerplexityBot)
- [ ] `llms.txt` at site root with structured metadata
- [ ] Dynamic `sitemap.xml` with `lastmod` timestamps
- [ ] JSON-LD structured data on all key pages
- [ ] `<meta>` tags: title, description, Open Graph, Twitter Card
- [ ] `hreflang` tags for multilingual content
- [ ] Canonical URLs on all pages
- [ ] Fast page load (< 3s) with proper caching headers
- [ ] HTTPS with security headers (HSTS, CSP)

**JSON-LD by Page Type:**

| Page Type | Schema.org @type | Key Properties |
|-----------|-----------------|----------------|
| Homepage | WebSite + Organization | name, url, SearchAction, logo |
| Product | Product | name, price, availability, review, aggregateRating |
| Article | Article | headline, author, datePublished, dateModified |
| FAQ | FAQPage | Question + Answer pairs |
| Local Business | LocalBusiness | address, geo, openingHours, telephone |
| Event | Event | startDate, endDate, location, performer |
| Recipe | Recipe | ingredients, instructions, nutrition |
| How-to | HowTo | step, totalTime, tool, supply |
| Course/Tour | TouristTrip | itinerary, provider, touristType |
| Person/Profile | Person | name, jobTitle, affiliation, knowsAbout |

### Layer 2: Content Optimization

Structure content for AI citation with answer-first writing, modular sections, specific data, and freshness signals. See `references/layers-deep-dive.md` for detailed principles, BAD/GOOD content patterns, and multilingual optimization strategies.

### Layer 3: Authority Building

Build trust signals so AI systems prioritize your content over competitors. See `references/layers-deep-dive.md` for the effort-vs-effect strategies table covering author bios, reviews, exclusive data, and community building.

### Layer 4: Agentic Integration

Enable AI systems to use your site as a tool via public APIs, MCP servers, or AI plugins. See `references/layers-deep-dive.md` for the Level 1-3 progressive approach with code examples.

## Audit Workflow

To audit any site's AI discoverability:

```
[Step 1] Auto-Detect
  - Scan project for existing assets: robots.txt, llms.txt, sitemap.xml, JSON-LD, meta tags
  - Identify framework (React, Vue, Next.js, WordPress, static HTML, etc.)
  - Check if .ai-seo/config.json exists (returning audit)

[Step 2] Layer-by-Layer Scoring
  - Score each of the 4 layers (0-10)
  - Identify gaps and quick wins
  - Compare with previous audit if history exists

[Step 3] Generate Report
  - Overall score (0-40, sum of 4 layers)
  - Prioritized action items by effort vs. impact
  - Copy-paste ready fixes for each issue

[Step 4] Save Progress
  - Write results to .ai-seo/history.json
  - Update config with detected project structure
```

For detailed scoring rubric and measurement methodology, see `references/layers-deep-dive.md`.

## Self-Improvement

This skill builds project context over time.

### First Run

1. Auto-detect project structure and existing SEO/GEO assets
2. Run full 4-layer audit
3. Create `.ai-seo/` directory with:
   - `config.json`: project URL, framework, detected assets, language list
   - `history.json`: baseline audit scores with timestamps
   - `test-prompts.md`: AI engine test prompts customized for the site's domain

### Subsequent Runs

1. Read `.ai-seo/config.json` for project context (skip detection)
2. Run audit and compare with `history.json`
3. Show delta: improved / regressed / unchanged per layer
4. Update history with new scores and timestamp
5. Refine test prompts based on what's working

### Progressive Enhancement

- **First audit**: Focus on Layer 1 quick wins (robots.txt, llms.txt, basic JSON-LD)
- **Score 10+**: Move to Layer 2 content restructuring
- **Score 20+**: Advance to Layer 3 authority building
- **Score 30+**: Implement Layer 4 agentic integration

## Constraints

### Required (MUST)

1. **llms.txt must be plain text**: No HTML, no JavaScript — simple structured text only
2. **robots.txt must explicitly name AI bots**: Default "allow all" is insufficient — AI crawlers check for their specific User-agent name
3. **JSON-LD must be valid**: Test with Google Rich Results Test before deploying
4. **Sitemap must have lastmod**: AI systems use freshness as a ranking signal
5. **Structured data must match visible content**: JSON-LD that contradicts page content is penalized

### Prohibited (MUST NOT)

1. **Block AI crawlers without reason**: Removing GPTBot/ClaudeBot removes the site from AI responses entirely
2. **Keyword-stuff llms.txt**: AI systems detect and deprioritize unnatural content
3. **Use stale structured data**: Outdated prices, hours, or facts cause AI to cite wrong information
4. **Ignore multilingual optimization**: If content exists in multiple languages, all need AI optimization

## Best Practices

1. **Layer 1 first**: Technical foundation must be solid before content optimization matters
2. **Test monthly**: AI systems update constantly — re-test every 30 days
3. **Monitor citations**: Track when and how AI engines mention the brand
4. **Keep llms.txt current**: Update whenever the core offering changes
5. **Combine with traditional SEO**: AI SEO complements, not replaces, traditional SEO
6. **Localize for AI**: AI engines serving different markets may have different training data
7. **Measure before and after**: Always establish a baseline before making changes

## Bundled Resources

### Scripts

- **`scripts/check-ai-readiness.sh`**: Quick readiness check — scans project for robots.txt, llms.txt, sitemap, JSON-LD, meta tags. Run with `bash scripts/check-ai-readiness.sh [project-root]`. Returns a scored checklist. Exit code 0 = all pass, 1 = issues found.

### References

- **`references/structured-data-patterns.md`**: Copy-paste JSON-LD templates for 8 page types (Homepage, Product, Article, FAQ, LocalBusiness, TouristAttraction, HowTo, Event). Use when implementing Layer 1 structured data.
- **`references/layers-deep-dive.md`**: Detailed Layer 2-4 patterns, BAD/GOOD content examples, authority strategies table, agentic integration code, scoring rubric, and measurement methodology with AI engine test prompts.

## References

- [llms.txt specification](https://llmstxt.org/)
- [schema.org vocabulary](https://schema.org/)
- [Google Rich Results Test](https://search.google.com/test/rich-results)
- [OpenAI GPTBot documentation](https://platform.openai.com/docs/bots)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
- [GEO: Generative Engine Optimization — Princeton/IIT Delhi (2023)](https://arxiv.org/abs/2311.09735)
- [Optimizing LLM Queries in Interactive Data Analysis — KDD 2024](https://arxiv.org/abs/2407.06450)

## Related Skills

- `seo-audit`: Traditional SEO auditing with seomator CLI (complements ai-seo)
- `schema-markup`: Detailed schema.org implementation patterns
- `mcp-builder`: Building MCP servers (for Layer 4 agentic integration)
