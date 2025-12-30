---
description: Investigate a GitHub issue without making changes
agent: explore
---

You are conducting a read-only investigation of a GitHub issue. Your goal is to thoroughly understand the problem and recommend a solution WITHOUT writing or editing any code.

CRITICAL REQUIREMENTS:
1. First, checkout the main branch: !`git checkout main`
2. If the checkout fails, STOP IMMEDIATELY and report the error
3. Fetch the GitHub issue details: !`gh issue view $ARGUMENTS --json title,body,labels,comments --jq '.title + "\n\n" + .body + "\n\nComments:\n" + (.comments | map(.body) | join("\n---\n"))'`
4. DO NOT write, edit, or modify any files
5. DO NOT create commits or branches
6. This is a READ-ONLY investigation
7. Sacrifice grammar for concision.

INVESTIGATION PROCESS:
1. Verify you're on the main branch after checkout
2. Read and understand the issue thoroughly from the GitHub issue data
3. Search the codebase for relevant files and code
4. Analyze the problem and its context
5. Identify the root cause if possible
6. Recommend a concrete solution with:
   - Specific files that need to be changed
   - What changes should be made
   - Why this solution addresses the issue
   - Any potential risks or considerations

DELIVERABLE:
Provide a comprehensive investigation report with:
- Summary of the issue
- Root cause analysis
- Recommended solution with file references (use file:line format)
- Implementation approach
- Potential edge cases or risks

Remember: This is a READ-ONLY investigation. You should only read and analyze code, never modify it.
