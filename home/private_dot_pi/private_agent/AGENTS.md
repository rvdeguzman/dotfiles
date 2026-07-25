# Global Agent Notes

## Exploratory repositories

When cloning repositories for reference or investigation, place them in a `.repos/` directory rather than alongside project source files.

- Reuse an existing `.repos/` directory when available.
- Ensure `.repos/` is ignored by Git; prefer `.git/info/exclude` to avoid modifying the project's `.gitignore` solely for agent scratch work.
- Do not modify or commit files from exploratory repositories unless explicitly requested.
- Follow project-specific instructions when they define another location.
