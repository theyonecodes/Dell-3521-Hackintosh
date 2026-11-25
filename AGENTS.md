# Agent Instructions

This file provides context for autonomous coding agents working on this repository.

## Repository Overview

**Name**: Dell-3521-Hackintosh
**Type**: Documentation/Config (e.g., Rust crate, Node.js app, Python package, docs, config)
**Primary Language**: Markdown/YAML/JSON
**Package Manager**: None

## Architecture Overview

```
See repository structure
```

## Key Components

| Component | Path | Description |
|-----------|------|-------------|
| Main Entry | src/index.ts / server.ts / main.py / Cargo.toml | Primary application entry point |
| Core Logic | src/ / lib/ / core/ | Business logic and domain models |

## Development Commands

```bash
# Install dependencies
N/A

# Run tests
N/A

# Run linting
markdownlint *.md

# Build
N/A

# Run locally
N/A
```

## Code Style & Conventions

- **Formatting**: Prettier (run `{{FORMAT_CMD}}`)
- **Linting**: markdownlint (run `markdownlint *.md`)
- **Type Checking**: N/A
- **Commit Messages**: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, etc.)

## Testing Strategy

- **Unit Tests**: N/A in `N/A`
- **Integration Tests**: N/A in `N/A`
- **Coverage Target**: 80%
- **Run All Tests**: `N/A`

## CI/CD Pipeline

- **Provider**: GitHub Actions
- **Workflow**: `.github/workflows/ci.yml`
- **Triggers**: Push to main/master, PRs to main/master
- **Jobs**: lint, test, build, security-scan
- **Artifacts**: Build outputs, coverage reports, security scan results

## Security Considerations

- **Secrets**: Managed via GitHub Secrets, never in code
- **Dependencies**: Scanned via `N/A` in CI
- **Supply Chain**: Dependencies pinned, signed releases
- **Secrets Scanning**: `gitleaks` / `trufflehog` in CI

## Architecture Invariants (Non-Negotiable)

1. **Never commit secrets or credentials**
2. **All CI checks must pass before merge**
3. **Maintain backward compatibility in public APIs**

## Common Tasks

### Adding a New Feature
1. Create feature branch: `git checkout -b feat/feature-name`
2. Implement with tests
3. Run `markdownlint *.md && N/A`
4. Open PR with description linking to issue

### Fixing a Bug
1. Create fix branch: `git checkout -b fix/bug-id`
2. Write failing test first
3. Implement fix
4. Run `N/A`
5. Open PR

### Releasing
1. Ensure all CI checks pass on `main`
2. Tag release: `git tag vx.y.z`
3. Push tag: `git push origin vx.y.z`
4. GitHub Actions builds and publishes release

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails | Run install command and check dependencies |
| Tests fail | Check test output and fix failing assertions |

## Useful Links

- **Repo**: `https://github.com/theyonecodes/Dell-3521-Hackintosh`
- **Issues**: `https://github.com/theyonecodes/Dell-3521-Hackintosh/issues`
- **CI**: `https://github.com/theyonecodes/Dell-3521-Hackintosh/actions`
- **Security**: `https://github.com/theyonecodes/Dell-3521-Hackintosh/security/advisories`
