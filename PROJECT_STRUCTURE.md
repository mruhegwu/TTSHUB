# Project Structure

## Overview

This document outlines the directory and file structure of the TTSHUB project.

## Directory Structure

```
TTSHUB/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md          # Bug report issue template
│   │   └── feature_request.md     # Feature request issue template
│   ├── workflows/
│   │   └── ci.yml                 # GitHub Actions CI/CD pipeline
│   └── pull_request_template.md   # PR description template
│
├── src/
│   ├── api/                       # Route handlers / controllers
│   │   ├── users.py (or .ts)
│   │   ├── services.py
│   │   ├── projects.py
│   │   ├── proposals.py
│   │   ├── payments.py
│   │   └── ai.py
│   ├── models/                    # Database models / schemas
│   │   ├── user.py
│   │   ├── service.py
│   │   ├── project.py
│   │   ├── proposal.py
│   │   └── payment.py
│   ├── services/                  # Business logic layer
│   │   ├── auth_service.py
│   │   ├── matching_service.py
│   │   └── payment_service.py
│   ├── utils/                     # Shared utility functions
│   │   ├── logger.py
│   │   ├── validators.py
│   │   └── pagination.py
│   ├── config.py                  # App configuration (reads from .env)
│   └── main.py                    # Application entry point
│
├── tests/
│   ├── unit/                      # Unit tests
│   │   ├── test_users.py
│   │   ├── test_services.py
│   │   └── test_auth.py
│   ├── integration/               # Integration tests
│   │   └── test_api.py
│   └── conftest.py                # Shared pytest fixtures
│
├── docs/                          # Additional documentation
│   └── diagrams/                  # Architecture diagrams
│
├── scripts/                       # Utility scripts
│   ├── seed.py                    # Database seeding script
│   └── migrate.py                 # Migration helper
│
├── .env.example                   # Example environment variables (committed)
├── .env                           # Local environment variables (NOT committed)
├── .gitignore
├── API.md                         # API reference documentation
├── ARCHITECTURE.md                # System architecture overview
├── CHANGELOG.md                   # Version history and changes
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md                # Contribution guidelines
├── IMPROVEMENTS_SUMMARY.md        # Ongoing improvement log
├── LICENSE
├── PROJECT_STRUCTURE.md           # This file
├── README.md                      # Project overview and quick start
└── SETUP.md                       # Detailed setup instructions
```

## Key Files and Directories

### `.github/`
Contains GitHub-specific configuration including CI/CD workflows and issue/PR templates.

### `src/`
All application source code. Organized into four main layers:
- **`api/`** — HTTP route handlers and request validation
- **`models/`** — Database models and data schemas
- **`services/`** — Business logic, decoupled from HTTP layer
- **`utils/`** — Shared helpers (logging, validation, pagination)

### `tests/`
All test files. Structure mirrors `src/`:
- **`unit/`** — Tests for individual functions with mocked dependencies
- **`integration/`** — End-to-end API tests against a test database

### `docs/`
Supplementary documentation such as architecture diagrams or ADRs (Architecture Decision Records).

### `scripts/`
One-off utility scripts for development tasks like seeding or data migration.

## Naming Conventions

| Artifact | Convention | Example |
|----------|-----------|---------|
| Python files | `snake_case.py` | `auth_service.py` |
| TypeScript files | `camelCase.ts` | `authService.ts` |
| Test files (Python) | `test_<module>.py` | `test_users.py` |
| Test files (TS) | `<module>.test.ts` | `users.test.ts` |
| Environment vars | `SCREAMING_SNAKE_CASE` | `DATABASE_URL` |
| API routes | `kebab-case` | `/api/user-profiles` |
