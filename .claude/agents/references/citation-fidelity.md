# Citation fidelity (every `file:line` must be verifiable)

- Before citing `file:line`, **Read that file** and take the number from the Read line-number gutter — never from a diff hunk header (`@@ -N,M @@`), from grep output for a *different* file, or from memory.
- Confirm the cited line actually contains the code you describe. For a range, confirm both ends.
- When scanning multiple files, never carry a line number from one file onto another file's path — re-anchor per file. Conflating a sibling/storage file's lines with the file under review is the most common error.
- If you cannot pin the exact line, cite `file` + the symbol/function name instead of guessing. A missing line number is acceptable; a wrong one is not.
