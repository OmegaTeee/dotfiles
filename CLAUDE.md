<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (60-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk go test             # Go test failures only (90%)
rtk jest                # Jest failures only (99.5%)
rtk vitest              # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk pytest              # Python test failures only (90%)
rtk rake test           # Ruby test failures only (90%)
rtk rspec               # RSpec test failures only (60%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
rtk uv run <cmd>        # Compact uv project command output
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%). Format flags (-c, -l, -L, -o, -Z) run raw.
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->

---

<!-- headroom-mcp-instructions v1 -->
# Headroom MCP - Context Compression for Large Tool Results

Headroom provides intelligent compression of large, repetitive, or verbose tool output. Use these tools when investigating code, processing logs, or retrieving documents.

## When to Use Headroom

**Use compression when:**
- Tool result exceeds 500 lines
- File excerpts are repetitive or have common patterns
- Log files contain duplicated entries
- Generated reports have verbose structure
- Retrieved documents have boilerplate sections

**Do not compress when:**
- Result is <500 lines
- You need every detail for the answer
- Output is already concise (git log, ls output, etc.)
- Compression would lose critical context

## Core Workflow

### 1. Compress Large Results
```bash
# After running a large command that fills context
mcp__headroom__headroom_compress "<large-output>" "describe-what-this-is"
```

**Preserves:** A retrieval reference (use it to get details later)

**Examples:**
```bash
# Compress verbose test output
mcp__headroom__headroom_compress "$test_output" "pytest failures from test_suite.py"

# Compress API response
mcp__headroom__headroom_compress "$curl_response" "GitHub API paginated list of PRs"

# Compress build logs
mcp__headroom__headroom_compress "$build_log" "TypeScript compilation errors from monorepo build"
```

### 2. Retrieve Compressed Details
```bash
# Use the retrieval reference when compressed form lacks needed details
mcp__headroom__headroom_retrieve "<retrieval-reference>"
```

**When to use:**
- Need full file paths from abbreviated results
- Need exact error messages or stack traces
- Need to see specific failure context
- Implementation requires precise details

**Example:**
```bash
# Compressed said "3 failures in utils" but you need details
mcp__headroom__headroom_retrieve "test-output-ref-2024-08-30-1045"
```

### 3. Summarize After Investigation
```bash
# At end of large debugging session
mcp__headroom__headroom_stats
```

**Shows:**
- Total compression savings this session
- Retrieval requests made
- Space reclaimed for new analysis

## Integration with RTK

Headroom and RTK work together:
- **RTK first:** Use `rtk` for initial filtering (tests, build, git)
- **Then Headroom:** If RTK output is still large, compress it
- **Result:** Minimal context footprint with full retrievability

Example workflow:
```bash
rtk cargo test 2>&1 | tee /tmp/test.log    # RTK filters to failures
mcp__headroom__headroom_compress "$(cat /tmp/test.log)" "cargo test failures"
# Now you have compressed output + retrieval reference
```

## Policy

**Always preserve the retrieval reference** returned by compression. Format: typically `<tool>-ref-<date>-<hash>` or UUID.

Store it in your response context if you'll need to retrieve details later.

### Example Response Pattern

1. **Compressed analysis** (50 lines of essential info)
2. **Retrieval reference**: `test-output-ref-2024-08-30-1234ab`
3. **Implementation** (based on compressed summary)
4. **Full retrieval only if** answer requires exact details

<!-- /headroom-mcp-instructions -->
