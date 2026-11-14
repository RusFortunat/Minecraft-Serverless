# Project conventions

## Commits

Format:

```
<type>/<branch-name>: short summary

Longer description, 2-3 lines, explaining what changed
and why.
```

`<type>` is one of:

| Type    | Use for                                   |
|---------|-------------------------------------------|
| `fix`   | Patch: bug fixes, small corrections       |
| `feat`  | Minor: new features                       |
| `feat!` | Major: breaking changes / major version   |
| `chore` | Tooling, config, dependencies, cleanup    |
| `doc`   | Documentation only                        |

Example:

```
feat/architecture-planning: add project skeleton

Set up terraform, lambda and container folders for the
on-demand Minecraft server.
```

## Branches

Feature work goes on `feat/<branch-name>` branches, never directly on `main`.
