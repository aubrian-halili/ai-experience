# Examples and Error Handling Reference

## Full Example Invocations

| Invocation | What It Does |
|---|---|
| `/qred-repo` | List repositories in the Qred org |
| `/qred-repo qred-mcp-proxy` | Orient: view repo details, README, and summary |
| `/qred-repo tree qred-mcp-proxy` | Navigate: show directory tree (max 3 levels) |
| `/qred-repo qred-mcp-proxy/src/` | Navigate: list files in `src/` directory |
| `/qred-repo qred-mcp-proxy/README.md` | Read: file contents with 300-line guardrail |
| `/qred-repo OAuth` | Search: find "OAuth" across all Qred repos (max 30 results) |
| `/qred-repo fetchUser in qred-api` | Search: find "fetchUser" in qred-api repo |
| `/qred-repo prs qred-mcp-proxy` | Direct: list open PRs in qred-mcp-proxy |
| `/qred-repo pr qred-mcp-proxy #42` | Direct: view PR #42 details |
| `/qred-repo issues qred-api` | Direct: list open issues in qred-api |
| `/qred-repo gh repo list Qred --language typescript` | Direct: pass-through gh command |

## Error Handling

| Scenario | Response |
|---|---|
| `gh` not installed | "GitHub CLI is not installed. Install with `brew install gh` and run `gh auth login`." |
| Not authenticated | "Run `gh auth login` to authenticate with GitHub." |
| No Qred org access | "Ensure your GitHub account has access to the Qred organization." |
| Repo not found | Suggest listing repos with `/qred-repo` to find the correct name |
| File/path not found | List parent directory contents to help navigate |
| File too large (>300 lines) | Show first 100 lines and ask: "This file has N lines. Show more?" |
| Directory >30 entries | Show first 30 entries and note: "Showing 30 of N entries. Narrow with a path or search." |
| No search results | Suggest alternative terms, broader scope, or different repo |
| PR/issue not found | Show error and suggest listing PRs/issues |
| API rate limit | "GitHub API rate limit exceeded. Wait a few minutes and retry." |
