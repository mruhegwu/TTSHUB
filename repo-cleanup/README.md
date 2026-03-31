# 📦 Repository Cleanup Toolkit

A production-ready set of tools and documentation for safely organizing, backing up, and managing GitHub repositories.

## 📋 Overview

This toolkit provides a systematic, repeatable process for keeping your GitHub account tidy. It is designed for individual developers and teams who need to:

- Back up all repositories before making destructive changes
- Classify repositories by value and status
- Safely archive or delete stale projects
- Restore repositories from backups if something goes wrong
- Automate the entire workflow for future maintenance cycles

## 📂 Files in This Toolkit

| File | Purpose |
|------|---------|
| [BACKUP-GUIDE.md](BACKUP-GUIDE.md) | Step-by-step procedures for mirroring and storing repositories |
| [CATEGORIZATION-TEMPLATE.md](CATEGORIZATION-TEMPLATE.md) | Framework for classifying repos into KEEP / ARCHIVE / DELETE / REVIEW |
| [CLEANUP-REPORT-TEMPLATE.md](CLEANUP-REPORT-TEMPLATE.md) | Template for logging every change made during a cleanup run |
| [DELETION-CHECKLIST.md](DELETION-CHECKLIST.md) | Pre-deletion verification checklist with safety gates |
| [AUTOMATED-CLEANUP-SCRIPT.sh](AUTOMATED-CLEANUP-SCRIPT.sh) | Bash automation script for backup and cleanup operations |
| [RESTORATION-GUIDE.md](RESTORATION-GUIDE.md) | Instructions for recovering repositories from backups |

## 🚀 Quick Start

### Prerequisites

- [Git](https://git-scm.com/) ≥ 2.28
- [GitHub CLI (`gh`)](https://cli.github.com/) ≥ 2.0 (authenticated)
- Bash 4+ (macOS users: `brew install bash`)
- Sufficient disk space for mirror clones (~2× total repo size)

### Recommended Workflow

```
Phase 1 ─ Backup      →  BACKUP-GUIDE.md
Phase 2 ─ Categorize  →  CATEGORIZATION-TEMPLATE.md
Phase 3 ─ Review      →  CLEANUP-REPORT-TEMPLATE.md
Phase 4 ─ Execute     →  DELETION-CHECKLIST.md
Phase 5 ─ Automate    →  AUTOMATED-CLEANUP-SCRIPT.sh
Recovery              →  RESTORATION-GUIDE.md
```

### Automated Path (Fastest)

```bash
# 1. Make the script executable
chmod +x repo-cleanup/AUTOMATED-CLEANUP-SCRIPT.sh

# 2. Run and choose an option from the interactive menu
./repo-cleanup/AUTOMATED-CLEANUP-SCRIPT.sh
```

### Manual Path (Most Control)

1. Read and follow **BACKUP-GUIDE.md** to create local mirror clones.
2. Fill in **CATEGORIZATION-TEMPLATE.md** for every repository.
3. Use **CLEANUP-REPORT-TEMPLATE.md** to log planned and completed changes.
4. Work through **DELETION-CHECKLIST.md** before deleting anything.
5. Refer to **RESTORATION-GUIDE.md** if you need to undo a deletion.

## ⚠️ Safety Principles

1. **Always back up before deleting.** Mirror clones capture everything: all branches, tags, and full history.
2. **Dry-run first.** The automation script includes a `--dry-run` flag that prints actions without executing them.
3. **Keep backups for at least 30 days** after completing a cleanup cycle.
4. **Document every decision** in the cleanup report so future team members understand what was removed and why.

## 📝 Conventions

- Backup directory naming: `github-backups-YYYY-MM-DD/`
- Mirror clone naming: `<owner>_<repo>.git`
- Cleanup report naming: `CLEANUP-REPORT-YYYY-MM-DD.md`

## 📄 License

MIT — see the root [LICENSE](../LICENSE) for details.
