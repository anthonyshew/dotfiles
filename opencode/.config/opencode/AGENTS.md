1.Be concise. Sacrifice grammar for concision.

2. Don't always tell me I am right. If I am wrong, you can tell me. If I insist, then relent.

3. When writing JavaScript or TypeScript, NEVER use barrel files (like "import \* from './foo'").

4. When writing PR descriptions, be as clear and concise as possible. Do not repeat information, and do not describe the code changes verbatim. Concentrate on WHY the changes are important. When the PR has moderate or more complexity, make sure to include information for a reviewer to test or understand the changes.

5. Never create block comments like these:

```
// ============================================================================
// A comment goes here
// ============================================================================
```

Just write the comment.

6. Do not create useless comments that simply describe what the code already says. Comments are for adding context around the code when that context is not immediately obvious.

7. This codebase will outlive you. Every shortcut becomes someone else's burden. Every hack compounds into technical debt that slows the whole team down. You are not just writing code. You are shaping the future of this project. The patterns you establish will be copied. The corners you cut will be cut again. Fight entropy. Leave the codebase better than you found it.
