When you are uncertain about knowledge, or the user doubts your answer, always use Jina MCP tools to search and read best practices and latest information. Use search_arxiv and read_url together when questions relate to theoretical deep learning or algorithm details. search_web and search_arxiv cannot be used alone - always combine with read_url or parallel_read_url to read from multiple sources. Remember: every search must be complemented with read_url to read the source URL content. For maximum efficiency, use parallel_* versions of search and read when necessary.

Never use emojis in output to files. Keep code comments terse / concise and reserved only for complicated logic. Avoid opinionated or "changelog" / breadcrumb comments like "changed from X to XX".

IMPORTANT: Use 'bd' for task tracking. If ever running init, ALWAYS run with --stealth
