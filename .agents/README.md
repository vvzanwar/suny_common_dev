# Workspace Agent Customizations

This directory (`.agents/`) contains workspace-level customizations for AI coding agents.

## Structure

```
.agents/
├── rules/         # Coding standards, architectural rules, and project-specific constraints (Markdown files)
├── skills/        # Reusable skills and playbooks (each skill has its own folder with a SKILL.md)
├── plugins/       # Packaged bundles containing skills, agents, and tool configurations
└── workflows/     # Step-by-step guides for common multi-step tasks and slash commands
```

### 1. `rules/`
Place project conventions and guidelines here as `.md` files (e.g., `rules/salesforce-standards.md`, `rules/lwc-best-practices.md`). These are automatically loaded to keep agent-generated code aligned with your repo's patterns.

### 2. `skills/`
Place task-specific skills here. Each skill should be in a subfolder containing a `SKILL.md` with YAML frontmatter (name, description) and instructions.

### 3. `plugins/`
Place modular plugin bundles here (containing `plugin.json` and associated skills/subagents).

### 4. `workflows/`
Place workflow guides here to document structured, repeatable procedures (e.g., PR checks, release testing, deployment steps).
