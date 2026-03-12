# AI SEO Layers Deep Dive

Detailed patterns, strategies, and scoring for the 4-layer AI SEO framework. Referenced from `skills/ai-seo/SKILL.md`.

## Layer 2: Content Optimization

Structure content so AI can extract and cite it accurately.

**Principles:**

1. **Answer-first writing**: Lead with the answer, then explain (AI extracts the first clear statement)
2. **Modular content**: Each section stands alone as a citable unit
3. **Specific data**: Include concrete numbers, dates, prices AI can cite
4. **Q&A format**: Structure as questions and answers where natural
5. **Freshness signals**: Include "last updated" dates, version numbers

**Content patterns:**

```markdown
## BAD — Hard for AI to cite
Our service is really great and has many features that users love.
We have been serving customers for years with excellent results.

## GOOD — Easy for AI to cite
[Service Name] serves 50,000+ users across 12 countries since 2020.

Key metrics (as of [Month Year]):
- **Response time**: 200ms average
- **Uptime**: 99.97% over the past 12 months
- **Pricing**: Free tier available, paid plans from $9/month

Last updated: [YYYY-MM-DD]
```

**Multilingual content optimization:**

- Provide hreflang alternate links for every page in every language
- JSON-LD `alternateName` for multilingual entity names
- Separate llms.txt per language if content differs significantly (e.g., `llms-zh.txt`)
- OG tags with locale variants (`og:locale`, `og:locale:alternate`)

## Layer 3: Authority Building

Build signals that make AI systems trust and prioritize the content.

**Strategies by effort level:**

| Effort | Strategy | Effect |
|--------|----------|--------|
| Low | Add author bios with credentials | AI attributes expertise |
| Low | Include specific statistics with sources | AI cites concrete data |
| Medium | Collect user reviews/testimonials | AI references social proof |
| Medium | Get cited by authoritative sources | AI cross-references mentions |
| High | Provide exclusive data not available elsewhere | AI must cite the source |
| High | Build community (forums, UGC) | AI finds diverse signals |

## Layer 4: Agentic Integration

Enable AI systems to directly use the site as a tool.

**Progressive approach:**

**Level 1 — Public API** (any framework):
```
GET /api/public/search?q=...     → Search content
GET /api/public/catalog          → List all items
GET /api/public/item/:id         → Get item details
```

Serve with:
- CORS: `*` (public)
- Cache-Control: `public, max-age=3600`
- No authentication required
- JSON response with schema.org types embedded

**Level 2 — MCP Server** (Model Context Protocol):
```json
{
  "name": "your-service-mcp",
  "tools": [
    {
      "name": "search",
      "description": "Search [your content type] by keyword, category, or location",
      "inputSchema": { "type": "object", "properties": { "query": { "type": "string" } } }
    },
    {
      "name": "get_details",
      "description": "Get detailed information about a specific [item]",
      "inputSchema": { "type": "object", "properties": { "id": { "type": "string" } } }
    }
  ]
}
```

**Level 3 — AI Plugins**: Platform-specific integrations (OpenAI GPTs, etc.)

## Scoring Rubric

| Layer | 0-3 (Poor) | 4-6 (Fair) | 7-9 (Good) | 10 (Excellent) |
|-------|-----------|-----------|-----------|----------------|
| Technical | No robots.txt or structured data | Basic meta tags only | llms.txt + JSON-LD + sitemap | All items + AI-specific headers + hreflang |
| Content | Unstructured prose | Some headings and lists | Q&A format with statistics | Modular, citable, dated, multilingual |
| Authority | No external mentions | Some reviews exist | Expert content + UGC | Cited by authoritative sources |
| Agentic | No API | Static data export | Public REST API | MCP server or AI plugin |

## Measurement

### AI Engine Test Prompts

After optimization, test discoverability monthly with these prompts:

| Engine | Test Prompt Template |
|--------|---------------------|
| ChatGPT | "[What/Where] is [brand/service]?" |
| Claude | "Recommend [category] in [location/niche]" |
| Perplexity | "[brand] review" or "[category] comparison" |
| Google AI Overview | "[primary keyword]" |
| Gemini | "[category] options for [target audience]" |

**What to track per test:**

- [ ] AI mentions the brand by name
- [ ] Information is factually accurate
- [ ] AI links to the correct URL (if applicable)
- [ ] AI cites specific data or statistics from the site
- [ ] Recommendation tone is positive/neutral (not dismissive)

### Tracking Template

```markdown
## AI Visibility Log — [Month Year]

| Engine | Prompt | Mentioned? | Accurate? | URL cited? | Notes |
|--------|--------|-----------|-----------|-----------|-------|
| ChatGPT | "..." | Yes/No | Yes/Partial/No | Yes/No | ... |
| Claude | "..." | Yes/No | Yes/Partial/No | Yes/No | ... |
| Perplexity | "..." | Yes/No | Yes/Partial/No | Yes/No | ... |
```
