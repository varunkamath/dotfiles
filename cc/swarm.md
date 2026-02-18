Create an agent team to accomplish this task: $ARGUMENTS

Break the work into logical subtasks however you see fit. Follow these rules strictly:

1. ALL agents MUST be Opus model agents (`model: "opus"`).
2. Every agent (including yourself as team lead) MUST load `/beads` at the start and use beads (`bd`) for all task tracking throughout their work.
3. At least one agent MUST be a dedicated code reviewer. This agent should:
   - Wait for all implementation agents to finish their work
   - Review every file changed by the other agents
   - Run `@"code-simplifier:code-simplifier (agent)"` on the other agents' code
   - Flag issues, suggest improvements, and verify correctness
4. All agents are free to use web research (Jina MCP tools, WebSearch, WebFetch) at any time to look up documentation, best practices, or any information they need.
5. Agents should coordinate through the shared task list and direct messages.

Plan the team composition first, then create the team and spawn the agents.
