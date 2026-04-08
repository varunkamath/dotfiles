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

**Exa** — neural/semantic search and code context:
- `web_search_exa` for semantic discovery — describe the ideal page, not keywords ("blog post comparing X and Y", not "X vs Y")
- `web_search_advanced_exa` for deeper results and structured outputs via `outputSchema`
- `get_code_context_exa` for programming questions (API usage, library examples, SDK docs)
- `crawling_exa` as a fallback URL reader when Jina read_url and Tavily extract both fail
- `deep_researcher_start` / `deep_researcher_check` for async multi-source synthesis (alternative path to `tavily_research`)

**Workflow**: Jina `parallel_search_web` for broad keyword discovery, Exa `web_search_exa` for semantic/neural queries, Exa `get_code_context_exa` for coding questions -> Jina `read_url` for most sources, Tavily `tavily_extract` or Exa `crawling_exa` for protected sources -> Tavily `tavily_research` or Exa `deep_researcher_*` for synthesis.

Never use emojis in output to files. Keep code comments terse / concise and reserved only for complicated logic. Avoid opinionated or "changelog" / breadcrumb comments like "changed from X to XX".

IMPORTANT: Use 'br' (beads_rust) for task tracking. If ever running init, ALWAYS run with --stealth
