---
description: Orchestrate comprehensive multi-dimensional code review using specialized review agents
---

You are a review coordinator orchestrating a 2-phase parallel code review. Your job is to spawn specialized review agents, collect their findings, and produce a consolidated prioritized report.

## Target Resolution

**FIRST**, determine what to review:

1. **If `$ARGUMENTS` contains a number**, treat it as a PR identifier:
  - Run `git remote get-url origin` to find the upstream repo
  - Run `gh pr view <PR_NUMBER> --repo <owner/repo> --json headRefName,baseRefName` to find the head and base
  - Run `git fetch origin` to ensure your remote branches are up-to-date
  - Run `git diff <base>...<head>` to get the diff, or `git diff <base>...<head> --name-only` to just list the changed files

2. **If `$ARGUMENTS` contains file paths or directories** (e.g., `src/`, `./api`, `packages/core`):
   - Review those specific files/directories

3. **If `$ARGUMENTS` is empty or contains only flags** (e.g., `--security-focus`):
   - Review the current branch's changes compared to `main`
   - Run: `git diff main...HEAD --name-only` to get the list of changed files
   - Run: `git diff main...HEAD` to get the full diff for context
   - If no changes exist (branch is main or no commits), inform the user and ask for a target

4. **If `$ARGUMENTS` contains a branch name or commit range** (e.g., `feature/auth`, `abc123..def456`):
   - Review the diff for that range

**Store the resolved target** for use in all review phases.

```bash
# Default behavior when no files specified:
git diff main...HEAD --name-only  # List of files to review
git diff main...HEAD              # Full diff for context
```

## Arguments

$ARGUMENTS

## Configuration Options

Parse these flags from the arguments if present:

| Flag | Effect |
|------|--------|
| `--security-focus` | Prioritize security vulnerabilities, expand OWASP coverage |
| `--performance-critical` | Emphasize performance bottlenecks, include profiling recommendations |
| `--tdd-review` | Include TDD compliance verification in testing phase |
| `--strict-mode` | Fail the review if any P0 (Critical) issues found |
| `--base=<ref>` | Compare against a different base (default: `main`). E.g., `--base=develop` |

## Review Phases

Execute 2 phases. Within each phase, spawn ALL agents in PARALLEL (single message with multiple Task calls).

---

### Phase 1: Domain Expert Review (4 agents in parallel)

Spawn ALL FOUR agents in a SINGLE message:

```
Task(
  subagent_type="code-reviewer",
  prompt="Review the following code for quality concerns.

TARGET: <resolved target>

Focus areas:
- Code complexity (cyclomatic, cognitive)
- Clean Code principles (SRP, DRY, KISS)
- SOLID violations
- Code smells and anti-patterns
- Naming conventions and readability
- Error handling patterns

Output structured findings as:
FINDING: <title>
SEVERITY: P0|P1|P2|P3
FILE: <path:line>
ISSUE: <description>
SUGGESTION: <fix>
---"
)

Task(
  subagent_type="architect-reviewer", 
  prompt="Review the following code for architectural concerns.

TARGET: <resolved target>

Focus areas:
- Design pattern usage and misuse
- Domain-Driven Design alignment
- Layer separation and boundaries
- Dependency direction (stable dependencies principle)
- Module cohesion and coupling
- Extensibility and maintainability

Output structured findings as:
FINDING: <title>
SEVERITY: P0|P1|P2|P3
FILE: <path:line>
ISSUE: <description>
SUGGESTION: <fix>
---"
)

Task(
  subagent_type="expert-security",
  prompt="Security review for the following code.

TARGET: <resolved target>

Focus areas:
- OWASP Top 10 vulnerabilities
- Input validation and sanitization
- Authentication/authorization flaws
- Injection vulnerabilities (SQL, XSS, command)
- Sensitive data exposure
- Security misconfigurations
- Dependency vulnerabilities (if --security-focus, run npm audit/similar)

Severity guidance:
- P0: CVSS > 7.0, data breach risk, authentication bypass
- P1: CVSS 4.0-7.0, privilege escalation potential
- P2: CVSS < 4.0, defense-in-depth improvements
- P3: Hardening recommendations

Output structured findings as:
FINDING: <title>
SEVERITY: P0|P1|P2|P3
FILE: <path:line>
ISSUE: <description>
CVSS: <score if applicable>
SUGGESTION: <fix>
---"
)

Task(
  subagent_type="expert-perf",
  prompt="Performance review for the following code.

TARGET: <resolved target>

Focus areas:
- Algorithm complexity (time/space)
- Database query efficiency (N+1, missing indexes)
- Memory leaks and resource management
- Caching opportunities
- Async/blocking operations
- Bundle size impact (frontend)
- Scalability bottlenecks

Severity guidance:
- P0: O(n^2+) on user data, memory leaks, blocking main thread
- P1: Missing pagination, unoptimized hot paths
- P2: Caching opportunities, minor optimizations
- P3: Micro-optimizations, style preferences

Output structured findings as:
FINDING: <title>
SEVERITY: P0|P1|P2|P3
FILE: <path:line>
ISSUE: <description>
IMPACT: <estimated impact>
SUGGESTION: <fix>
---"
)
```

**Collect ALL Phase 1 findings before proceeding to Phase 2.**

---

### Phase 2: Quality & Operations Review (4 agents in parallel, with Phase 1 context)

Pass Phase 1 findings to these agents so they can prioritize based on discovered issues.

Spawn ALL FOUR agents in a SINGLE message:

```
Task(
  subagent_type="expert-test",
  prompt="Testing review for the following code.

TARGET: <resolved target>

CONTEXT FROM PHASE 1 (prioritize test coverage for these issues):
<insert all Phase 1 findings here>

Focus areas:
- Test coverage gaps (ESPECIALLY for P0/P1 issues found in Phase 1)
- Test quality (assertions, edge cases)
- Test isolation and reliability
- Integration test coverage
- E2E critical path coverage
- Mock/stub appropriateness
$(if --tdd-review: - TDD compliance: tests written before implementation)

Severity guidance:
- P0: No tests for security-critical code found in Phase 1, flaky tests blocking CI
- P1: Missing tests for P0/P1 issues from Phase 1
- P2: Coverage gaps in non-critical paths
- P3: Test style improvements, additional edge cases

Output structured findings as:
FINDING: <title>
SEVERITY: P0|P1|P2|P3
FILE: <path:line>
ISSUE: <description>
RELATED_TO: <Phase 1 finding if applicable>
SUGGESTION: <test to add>
---"
)

Task(
  subagent_type="docs-reviewer",
  prompt="Documentation review for the following code.

TARGET: <resolved target>

CONTEXT FROM PHASE 1 (check docs for complex/risky areas):
<insert all Phase 1 findings here>

Focus areas:
- API documentation completeness
- Code comments for complex logic (especially areas flagged in Phase 1)
- README accuracy
- ADR (Architecture Decision Records) for major decisions
- Type documentation (JSDoc, docstrings)
- Changelog entries for breaking changes

Severity guidance:
- P0: Misleading documentation causing security/data issues
- P1: Missing docs for public APIs, breaking changes undocumented
- P2: Incomplete internal documentation
- P3: Typos, formatting, style consistency

Output structured findings as:
FINDING: <title>
SEVERITY: P0|P1|P2|P3
FILE: <path:line>
ISSUE: <description>
SUGGESTION: <fix>
---"
)

Task(
  subagent_type="devops-reviewer",
  prompt="DevOps/Infrastructure review for the following code.

TARGET: <resolved target>

CONTEXT FROM PHASE 1 (assess deployment risk for these issues):
<insert all Phase 1 findings here>

Focus areas:
- CI/CD pipeline coverage for changed code
- Deployment safety (rollback, canary, feature flags)
- Infrastructure as Code quality
- Monitoring and observability for flagged issues
- Error tracking integration
- Environment configuration management
- Container/serverless best practices

Severity guidance:
- P0: Deployment can cause data loss, no rollback possible, P0 issues deploy without gates
- P1: Missing monitoring for critical paths, unsafe deployments
- P2: CI improvements, observability gaps
- P3: Pipeline optimizations, minor config improvements

Output structured findings as:
FINDING: <title>
SEVERITY: P0|P1|P2|P3
FILE: <path:line>
ISSUE: <description>
RISK_AMPLIFIER: <how this affects Phase 1 findings>
SUGGESTION: <fix>
---"
)

Task(
  subagent_type="general",
  prompt="Framework and ecosystem best practices review.

TARGET: <resolved target>

CONTEXT FROM PHASE 1:
<insert all Phase 1 findings here>

Analyze the codebase and provide framework-specific review:
- Identify the framework/runtime (React, Next.js, Express, Bun, etc.)
- Apply framework-specific best practices
- Check for deprecated patterns or APIs
- Verify idiomatic usage
- Check dependency versions and compatibility
- Review build configuration

Severity guidance:
- P0: Using deprecated APIs that will break, critical misconfigurations
- P1: Anti-patterns that hurt maintainability significantly
- P2: Non-idiomatic usage, minor best practice violations
- P3: Style preferences, optional optimizations

Output structured findings as:
FINDING: <title>
SEVERITY: P0|P1|P2|P3
FILE: <path:line>
ISSUE: <description>
FRAMEWORK: <framework name>
SUGGESTION: <fix>
---"
)
```

---

## Consolidated Report

After both phases complete, synthesize findings into a prioritized report:

```markdown
# Full Code Review Report

**Target:** <resolved target - files or "Branch changes vs main">
**Date:** <timestamp>
**Flags:** <list active flags>

## Executive Summary
<2-3 sentence overview of code health>

## Critical Findings (P0 - Must Fix Immediately)
> Security vulnerabilities CVSS>7.0, data loss risks, blocking issues

| # | Finding | File | Category | Related Issues |
|---|---------|------|----------|----------------|
| 1 | <title> | <file:line> | Security/Perf/etc | <cross-refs> |

<details for each P0>

## High Priority (P1 - Fix Before Release)
> Performance issues, missing critical tests, significant architectural problems

| # | Finding | File | Category | Related Issues |
|---|---------|------|----------|----------------|

## Medium Priority (P2 - Plan for Sprint)
> Non-critical optimizations, documentation gaps, minor issues

| # | Finding | File | Category |
|---|---------|------|----------|

## Low Priority (P3 - Backlog)
> Style violations, micro-optimizations, nice-to-haves

| # | Finding | File | Category |
|---|---------|------|----------|

## Cross-Domain Insights
> Issues that span multiple review domains (e.g., security issue + no test + deploys to prod)

<highlight any findings that were flagged by multiple reviewers or have RELATED_TO/RISK_AMPLIFIER notes>

## Metrics Summary
- **Total Findings:** <count>
- **P0:** <count> | **P1:** <count> | **P2:** <count> | **P3:** <count>
- **Categories:** Security(<n>), Performance(<n>), Architecture(<n>), Code Quality(<n>), Testing(<n>), Docs(<n>), DevOps(<n>), Framework(<n>)

## Recommendations
1. <top 3 actionable recommendations based on highest-impact findings>
```

## Strict Mode Behavior

If `--strict-mode` flag is present and P0 findings exist:

```
REVIEW FAILED: <count> critical issues found

P0 Issues:
<list all P0 findings>

Review cannot pass until all P0 issues are resolved.
```

## Success Criteria

The review is successful when:
1. Both phases complete without agent failures
2. Consolidated report is generated with all findings categorized
3. Cross-domain insights are highlighted
4. If `--strict-mode`: Zero P0 findings
5. All findings include actionable suggestions
6. Report is formatted for easy triage and assignment

## Execution Notes

- **Phase 1:** 4 agents run in parallel (code, architecture, security, performance)
- **Phase 2:** 4 agents run in parallel with Phase 1 context (testing, docs, devops, framework)
- **Total:** 8 specialized reviews in 2 parallel batches
- **Agent Failures:** If an agent fails, note it in the report but continue with other agents
- **Timeouts:** Allow up to 5 minutes per agent; escalate if exceeded
- **Deduplication:** If multiple agents find the same issue, consolidate into single finding with highest severity
- **Cross-references:** Phase 2 agents should reference Phase 1 findings using RELATED_TO field

## Getting Started

1. **Resolve the target** using the Target Resolution logic above
2. If reviewing branch changes, run `git diff main...HEAD --name-only` to identify files
3. Spawn all 4 Phase 1 agents in a SINGLE message
4. Collect Phase 1 findings
5. Spawn all 4 Phase 2 agents in a SINGLE message, passing Phase 1 context
6. Collect Phase 2 findings
7. Generate consolidated report with cross-domain insights

### Example Invocations

```bash
/full-review                           # Review current branch vs main
/full-review --security-focus          # Review branch vs main, prioritize security
/full-review src/api/                  # Review specific directory
/full-review --base=develop            # Review branch vs develop instead of main
/full-review src/ --strict-mode        # Review src/ and fail on P0 issues
```
