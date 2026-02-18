When you are uncertain about knowledge, or the user doubts your answer, use Jina and Tavily MCP tools together for best results:

**Jina** — primary tool for discovery and academic search:
- `parallel_search_web` for broad multi-query discovery (5 concurrent queries)
- `search_arxiv` for academic papers (arXiv only; VLDB/SIGMOD papers need web search)
- `read_url` / `parallel_read_url` to read sources (good on docs/PDFs, blocked on Medium/Cloudflare sites)
- `sort_by_relevance` to filter large result sets
- Every search MUST be followed by read_url to read actual content. Never cite unread sources.

**Tavily** — use for extraction, protected content, and autonomous research:
- `tavily_search` (use `search_depth: "advanced"`) when Jina search misses or for second opinions
- `tavily_extract` for reading URLs that Jina's read_url can't access (paywalled/Cloudflare-protected)
- `tavily_research` (model: "pro") for autonomous multi-source synthesis on broad questions
- `tavily_crawl` for site-wide content (use with `instructions` + `chunks_per_source`); `tavily_map` is unreliable

**Workflow**: Jina parallel_search_web for discovery -> Jina read_url for most sources -> Tavily extract for protected sources -> Tavily research for synthesis when needed.

Never use emojis in output to files. Keep code comments terse / concise and reserved only for complicated logic. Avoid opinionated or "changelog" / breadcrumb comments like "changed from X to XX".

IMPORTANT: Use 'bd' for task tracking. If ever running init, ALWAYS run with --stealth
