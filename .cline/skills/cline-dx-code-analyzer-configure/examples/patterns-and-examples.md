# dx-code-analyzer-configure - Reference Examples, Patterns & Troubleshooting

## Gotchas

| Issue | Solution |
|-------|----------|
| Config not picked up | Must be `code-analyzer.yml` in CWD or use `--config-file` |
| YAML validation fails | Spaces only (no tabs), check colon spacing |
| SFGE out of memory | Increase `java_max_heap_size` in engines section |
| ESLint rules missing | Set `auto_discover_eslint_config: true` |

For full troubleshooting, read `<skill_dir>/examples/troubleshooting.md`.

---
