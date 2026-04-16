# Examples and Error Handling Reference

## Full Example Invocations

| Invocation | What It Does |
|---|---|
| `/qred-repo qred-mcp-proxy` | Orient: view repo details, README, and summary |
| `/qred-repo tree qred-mcp-proxy` | Navigate: show directory tree |
| `/qred-repo qred-mcp-proxy/src/` | Navigate: list files in `src/` directory (path ending in `/`) |
| `/qred-repo qred-mcp-proxy/README.md` | Read: file contents with 300-line guardrail (path to file) |
| `/qred-repo OAuth` | Search: find "OAuth" across all Qred repos |
| `/qred-repo fetchUser in qred-api` | Search: find "fetchUser" scoped to qred-api |
| `/qred-repo pr qred-mcp-proxy #42` | Direct: view PR #42 details |

## Error Handling

| Scenario | Response |
|---|---|
| `gh` not installed | "GitHub CLI is not installed. Install with `brew install gh` and run `gh auth login`." |
| Not authenticated | "Run `gh auth login` to authenticate with GitHub." |
| No Qred org access | "Ensure your GitHub account has access to the Qred organization." |
| File/path not found | List parent directory contents to help navigate |
| File too large (>300 lines) | Show first 100 lines and ask: "This file has N lines. Show more?" |
| Directory >30 entries | Show first 30 entries and note: "Showing 30 of N entries. Narrow with a path or search." |
| API rate limit | "GitHub API rate limit exceeded. Wait a few minutes and retry." |
