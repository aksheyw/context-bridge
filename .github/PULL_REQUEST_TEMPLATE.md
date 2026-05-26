## What this changes

<one paragraph: the change + motivation>

## Type of change

- [ ] Bug fix (no breaking change)
- [ ] New feature (no breaking change)
- [ ] Breaking change (explain migration path below)
- [ ] Documentation only
- [ ] CI / tooling
- [ ] Attribution / credits

## Checklist

### Gates (mandatory)

- [ ] No real secrets in any committed file (entropy-required scan run locally).
- [ ] No private proper nouns in any committed file (project codenames, internal URLs, real IDs).
- [ ] `skill/SKILL.md` is ≤200 lines (run `wc -l skill/SKILL.md`).
- [ ] If a `skill/references/<topic>.md` mentions Karpathy, it links the [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (not just "Karpathy").
- [ ] All cross-links in `skill/SKILL.md` resolve.
- [ ] Frontmatter on `skill/SKILL.md` + every `skill/commands/*.md` is present and valid.
- [ ] CI `pii-scrub-check` workflow passes.

### Content

- [ ] Templates remain scrubbed (only `<project-name>` / `ExampleApp` / `ExampleService` placeholders).
- [ ] If a new template is added, it has YAML frontmatter and a `<!--` convention comment block.
- [ ] If a new slash command is added, `skill/SKILL.md` is updated (command table + cross-link).
- [ ] If a new finding is opened, it's recorded in `.claude/wiki/_findings.md` with severity + status + phase.

### Attribution

- [ ] If this PR draws on someone else's work, they're credited in `CREDITS.md`.
- [ ] No removal of existing attribution lines without explicit reason.

## Migration / breaking-change notes

<if breaking, explain what users need to do>

## Related issues

Closes #
Refs #
