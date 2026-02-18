Create a team of read-only agents to review the entire codebase. Their goal: $ARGUMENTS

Follow these rules strictly:

1. ALL agents MUST be Opus model agents (`model: "opus"`).
2. Every agent MUST load `/beads` at the start and use beads (`bd`) for all task tracking.
3. ALL agents are strictly READ-ONLY. They must NOT edit, write, or create any files. They may only use Read, Glob, Grep, WebSearch, WebFetch, and other read-only tools.
4. All agents are free to use web research (Jina MCP tools, WebSearch, WebFetch) at any time.
5. Divide the codebase into logical sections and assign each agent a section to review.
6. Each agent should report their findings as a message back to the team lead.
7. As team lead, synthesize all findings into a comprehensive report for the user.

If no specific review goal was provided, default to a general audit covering: code quality, potential bugs, security concerns, performance issues, and architectural observations.

Plan the team composition and codebase division first, then create the team and spawn the agents.
