# SecOps Plugin — Repository

This repo contains the **secops** Claude Code plugin for cybersecurity teams.

## Repository Structure

```text
secops/                              (repo root)
├── .claude-plugin/
│   └── marketplace.json             (marketplace metadata)
├── secops-plugin/                   (plugin root — all plugin content here)
│   ├── .claude-plugin/plugin.json
│   ├── CLAUDE.md                    (plugin runtime context)
│   ├── agents/                      (12 agents)
│   ├── skills/                      (8 skills)
│   ├── commands/                    (14 commands)
│   ├── hooks/                       (hooks.json + scripts/)
│   ├── rules/                       (5 rule files)
│   ├── workflows/                   (YAML workflow templates)
│   └── context/                     (company profile templates)
├── tests/                           (test suite — 5 layers)
├── README.md
├── GETTING-STARTED.md
└── DEVELOPMENT.md
```

## Development

```bash
# Load plugin in dev mode
claude --plugin-dir ./secops-plugin

# Run tests
bash tests/run-all.sh
```

When editing plugin content, work inside `secops-plugin/`:

- Agents: follow frontmatter format (name, description, tools, model)
- Skills: ensure SKILL.md has proper YAML frontmatter
- Hooks: test with `claude --plugin-dir ./secops-plugin` after changes
- All content should support Vietnamese + English

See [secops-plugin/CLAUDE.md](secops-plugin/CLAUDE.md) for plugin architecture and runtime context.
See [DEVELOPMENT.md](DEVELOPMENT.md) for full development workflow.
