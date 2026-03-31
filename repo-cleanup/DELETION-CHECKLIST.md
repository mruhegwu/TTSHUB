# ✅ Deletion Checklist

Work through every item in this checklist **in order** before deleting a repository. Do not skip steps. Each step is a safety gate.

---

## Pre-Requisites (Complete Once Per Cleanup Cycle)

- [ ] GitHub CLI is installed and authenticated (`gh auth status`)
- [ ] Git version ≥ 2.28 is installed (`git --version`)
- [ ] Backup directory has been created with sufficient free space
- [ ] Cleanup report file has been created (copy from `CLEANUP-REPORT-TEMPLATE.md`)
- [ ] All team members have been notified of the upcoming cleanup

---

## Phase 1: Pre-Deletion Research

Complete this phase for **each repository** before marking it for deletion.

### 1.1 Confirm Repository Identity

- [ ] Repository URL verified: `https://github.com/<owner>/<repo>`
- [ ] Repository description reviewed
- [ ] Last commit date confirmed (older than threshold?)
- [ ] Open issues reviewed and noted
- [ ] Open pull requests reviewed and noted

### 1.2 Dependency Check

- [ ] Searched codebase for references to this repository
- [ ] Checked whether any CI/CD pipelines reference this repository
- [ ] Verified no other repositories list this as a dependency
- [ ] Confirmed no team members are actively working in this repository
- [ ] Checked whether repository is published as a package (npm, PyPI, etc.)

### 1.3 Value Assessment

- [ ] Categorization score calculated (see `CATEGORIZATION-TEMPLATE.md`)
- [ ] Score is in the DELETE range (5–6 out of 25) **or** explicit business decision documented
- [ ] Repository has been reviewed by at least one other person (if team environment)

---

## Phase 2: Backup

All items in this phase must be marked **complete and verified** before proceeding.

### 2.1 Create Mirror Clone

```bash
OWNER="<owner>"
REPO="<repo>"
BACKUP_DIR="$HOME/github-backups-$(date +%Y-%m-%d)"

mkdir -p "$BACKUP_DIR"
git clone --mirror "https://github.com/$OWNER/$REPO.git" \
    "$BACKUP_DIR/${OWNER}_${REPO}.git"
```

- [ ] Mirror clone command executed without errors
- [ ] Backup directory exists and is non-empty
- [ ] Backup size appears reasonable (not suspiciously small)

### 2.2 Verify Backup Integrity

```bash
git -C "$BACKUP_DIR/${OWNER}_${REPO}.git" fsck --quiet
echo "Exit code: $?"   # Must be 0
```

- [ ] `git fsck` exits with code 0 (no errors)
- [ ] Branch list is complete: `git -C "$BACKUP_DIR/${OWNER}_${REPO}.git" branch -a`
- [ ] Tag list is complete: `git -C "$BACKUP_DIR/${OWNER}_${REPO}.git" tag -l`

### 2.3 Test Restore

```bash
TEST_DIR="/tmp/restore-test-$(date +%s)"
git clone "$BACKUP_DIR/${OWNER}_${REPO}.git" "$TEST_DIR"
ls "$TEST_DIR"   # Should show repository files
rm -rf "$TEST_DIR"
```

- [ ] Test restore completed without errors
- [ ] Expected files are present in the restored copy

### 2.4 Off-Site Copy (Recommended)

- [ ] Backup uploaded to cloud storage (S3, Google Drive, or equivalent)
- [ ] Off-site copy location recorded in cleanup report

---

## Phase 3: Final Confirmation

- [ ] Backup location recorded in `CLEANUP-REPORT-YYYY-MM-DD.md`
- [ ] Deletion reason documented in cleanup report
- [ ] A second person has confirmed the decision (if team environment)
- [ ] Mandatory waiting period observed (recommended: 24 hours after backup)
- [ ] No last-minute objections from team

---

## Phase 4: Deletion

Execute deletion **only after all items above are checked**.

### Using GitHub CLI

```bash
# Soft check — print the repo info first
gh repo view <owner>/<repo>

# Hard delete — this is irreversible on GitHub
gh repo delete <owner>/<repo> --yes
```

- [ ] `gh repo view` output confirmed correct repository
- [ ] `gh repo delete` command executed
- [ ] Repository URL returns 404 on GitHub (verify in browser)

### Recording the Deletion

- [ ] Deletion date and time recorded in cleanup report Section 3
- [ ] Repository removed from categorization table

---

## Phase 5: Post-Deletion Verification

- [ ] GitHub account total repository count decreased by expected amount
- [ ] No broken links in other repositories or documentation
- [ ] CI/CD pipelines tested and passing (if any referenced the deleted repo)
- [ ] Team notified that deletion is complete

---

## Emergency Abort Procedure

If anything goes wrong **before** the deletion command is run, stop immediately:

1. Do not execute or re-execute the `gh repo delete` command.
2. Note the issue in the cleanup report (Section 5: Issues Encountered).
3. Escalate to the team if the repository may be actively used.
4. Revisit the categorization decision before proceeding.

If deletion has already been executed, proceed to **RESTORATION-GUIDE.md**.

---

## Quick Reference: Common Mistakes to Avoid

| Mistake | Prevention |
|---------|-----------|
| Deleting the wrong repository | Always run `gh repo view` and confirm the URL before deleting |
| Skipping backup verification | Run `git fsck` — never rely on an unverified backup |
| Deleting a dependency | Complete Phase 1.2 dependency check thoroughly |
| Not documenting the deletion | Fill in the cleanup report before and after each deletion |
| Rushing the process | Observe the 24-hour waiting period after backup |

---

*Part of the [Repository Cleanup Toolkit](README.md).*
