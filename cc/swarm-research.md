Research this topic thoroughly using a team of web search agents: $ARGUMENTS

Follow these rules strictly:

1. ALL agents MUST be Opus model agents (`model: "opus"`).
2. Every agent MUST load `/beads` at the start and use beads (`bd`) for all task tracking.
3. ALL agents are strictly READ-ONLY. They must NOT edit, write, or create any files.
4. Use Jina `expand_query` first to generate diverse search angles from the user's topic.
5. Spawn 3-5 research agents, each assigned a distinct angle or sub-question.

## Tool usage per agent

Agents have access to both Jina and Tavily MCP tools. Use them according to their strengths:

**Jina** (primary discovery + reading):
- `parallel_search_web` / `search_web` for broad discovery
- `search_arxiv` for academic papers (arXiv only; use search_web for VLDB/SIGMOD/other venues)
- `read_url` / `parallel_read_url` to read every source before citing it
- `sort_by_relevance` to filter large result sets

**Tavily** (extraction + autonomous research):
- `tavily_search` (search_depth: "advanced") as secondary search or when Jina misses
- `tavily_extract` for URLs that Jina read_url fails on (Cloudflare/paywall-protected)
- `tavily_research` (model: "pro") for autonomous synthesis of broad sub-topics
- `tavily_crawl` with `instructions` + `chunks_per_source` for site-wide content

**Rules**:
- Every search MUST be complemented with read_url or tavily_extract to read the actual content
- NEVER cite a source that hasn't been read
- If Jina read_url fails on a URL, fall back to tavily_extract
- Use parallel_search_web (up to 5 concurrent queries) for efficient broad discovery

6. Each agent reports findings as a message back to the team lead with: key facts, source URLs, and any conflicting information found.
7. As team lead, synthesize all agent findings into a single comprehensive report for the user. The report must include:
   - Executive summary (2-3 sentences)
   - Detailed findings organized by sub-topic
   - Sources section with all URLs as markdown links
   - Open questions or areas where sources conflict

Plan the research angles and team composition first, then create the team and spawn the agents.
