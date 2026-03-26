# Contributing to TTSHUB

Thank you for considering contributing to the TTSHUB project! This guide covers everything you need to know to contribute effectively.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Testing](#testing)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Requesting Features](#requesting-features)

---

## Code of Conduct

This project is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to support@ttshub.com.

---

## Getting Started

1. **Fork** the repository by clicking the Fork button on GitHub.
2. **Clone** your fork:
   ```bash
   git clone https://github.com/<your-username>/TTSHUB.git
   cd TTSHUB
   ```
3. **Add the upstream remote** so you can pull in future changes:
   ```bash
   git remote add upstream https://github.com/mruhegwu/TTSHUB.git
   ```
4. **Set up your environment** by following [SETUP.md](SETUP.md).
5. **Create a branch** for your work:
   ```bash
   git checkout -b feat/your-feature-name
   ```

---

## Development Workflow

1. **Sync with upstream** before starting new work:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```
2. Make your changes in small, logical commits.
3. Run the linter and tests locally before pushing (see [Testing](#testing)).
4. Push your branch and open a Pull Request against `main`.

---

## Code Style

### JavaScript / TypeScript

- We use **ESLint** and **Prettier**. Run before committing:
  ```bash
  npm run lint
  npm run format
  ```
- Use `const` and `let`; avoid `var`.
- Prefer `async/await` over `.then()` chains.
- All public functions must have JSDoc comments.

### Python

- We follow **PEP 8**. Run before committing:
  ```bash
  flake8 src/
  black src/
  isort src/
  ```
- Use type hints on all function signatures.
- All public functions must have docstrings.

### General

- Keep functions small and single-purpose.
- Avoid magic numbers — use named constants.
- Delete dead code rather than commenting it out.

---

## Testing

All contributions **must** include tests. We aim for ≥80% code coverage.

### Running Tests

```bash
# Node.js
npm test

# Python
pytest

# With coverage
pytest --cov=src --cov-report=term-missing
```

### Writing Tests

- Place tests in the `tests/` directory, mirroring the `src/` structure.
- Name test files `test_<module>.py` (Python) or `<module>.test.ts` (JS/TS).
- Write both **unit tests** (mock external calls) and **integration tests** where applicable.
- Every bug fix should include a regression test.

---

## Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

**Types:**

| Type | When to use |
|------|------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Formatting, missing semicolons, etc. |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or updating tests |
| `chore` | Build process, dependency updates, etc. |
| `ci` | Changes to CI configuration |

**Examples:**
```
feat(auth): add JWT refresh token rotation
fix(payments): handle Stripe webhook signature mismatch
docs(api): add request/response examples for /api/users
test(services): add unit tests for service filtering logic
```

---

## Pull Request Process

1. Ensure your branch is up to date with `main` before opening a PR.
2. Fill in the Pull Request template completely.
3. Link any related issues using `Closes #<issue-number>`.
4. All CI checks (lint, test, build) must pass.
5. At least **one approving review** is required before merging.
6. Squash commits when merging to keep the history clean.
7. Delete your branch after merging.

---

## Reporting Bugs

Use the [Bug Report issue template](.github/ISSUE_TEMPLATE/bug_report.md). Please include:

- A clear description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Node/Python version, browser)
- Relevant logs or screenshots

---

## Requesting Features

Use the [Feature Request issue template](.github/ISSUE_TEMPLATE/feature_request.md). Please include:

- A description of the problem you're trying to solve
- Your proposed solution
- Any alternatives you considered
- Why this feature benefits the broader community

---

Thank you for contributing to TTSHUB! 🎉
