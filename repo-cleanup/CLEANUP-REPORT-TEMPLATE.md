# 📋 Cleanup Report Template

Copy this file and rename it `CLEANUP-REPORT-YYYY-MM-DD.md` before filling it in. One report per cleanup cycle.

---

## Cleanup Report

| Field | Value |
|-------|-------|
| **Report Date** | YYYY-MM-DD |
| **GitHub Account** | `<owner>` |
| **Performed By** | `<name>` |
| **Reviewed By** | `<name>` |
| **Backup Location** | `~/github-backups-YYYY-MM-DD/` or `s3://…` |
| **Total Repos Reviewed** | |
| **Total Repos Kept** | |
| **Total Repos Archived** | |
| **Total Repos Deleted** | |
| **Total Repos Deferred** | |

---

## Executive Summary

> *(2–4 sentence overview of what was done, why, and the outcome.)*

---

## Section 1: Preserved Repositories (KEEP 🟢)

Repositories that remain active and untouched.

| Repository | Description | Reason for Keeping |
|-----------|-------------|-------------------|
| `<owner>/<repo>` | | |

---

## Section 2: Archived Repositories (ARCHIVE 📦)

Repositories converted to read-only archives. All history is preserved on GitHub.

| Repository | Archived Date | Archive Reason | Backup Taken? |
|-----------|--------------|----------------|--------------|
| `<owner>/<repo>` | YYYY-MM-DD | | Yes / No |

### How Each Repository Was Archived

```bash
# Archive a repository using the GitHub CLI
gh repo archive <owner>/<repo>
```

---

## Section 3: Deleted Repositories (DELETE 🗑️)

Repositories permanently removed. Each entry must include backup confirmation.

| Repository | Deleted Date | Deletion Reason | Backup Location | Backup Verified? |
|-----------|-------------|-----------------|----------------|-----------------|
| `<owner>/<repo>` | YYYY-MM-DD | | | Yes / No |

> ⚠️ **Warning:** Deletion is irreversible on GitHub. Confirm backup integrity before filling in this section.

---

## Section 4: Deferred Repositories (REVIEW 🔵)

Repositories that could not be categorized during this cycle. Schedule a follow-up.

| Repository | Reason for Deferral | Follow-Up Date | Owner |
|-----------|--------------------|--------------:|-------|
| `<owner>/<repo>` | | YYYY-MM-DD | |

---

## Section 5: Issues Encountered

Document any problems encountered during the cleanup, and how they were resolved.

| # | Issue | Repository | Resolution | Date Resolved |
|---|-------|-----------|-----------|--------------|
| 1 | | | | |

---

## Section 6: Backup Manifest

List every backup file created during this cycle.

| Backup File | Source Repository | Size | SHA-256 Checksum | Storage Location |
|------------|------------------|------|-----------------|-----------------|
| `mruhegwu_TTSHUB.git.tar.gz` | mruhegwu/TTSHUB | | | |

### Generate Checksums

```bash
# Generate SHA-256 for all backup archives
for FILE in ~/github-backups-YYYY-MM-DD/*.tar.gz; do
  sha256sum "$FILE"
done
```

---

## Section 7: Post-Cleanup Verification

- [ ] GitHub account repository count matches expected count after deletions
- [ ] Archived repositories show the "Archived" badge on GitHub
- [ ] All deleted repositories return 404 on GitHub
- [ ] At least one backup was test-restored successfully
- [ ] Cleanup report has been committed to the repository
- [ ] Team members notified of changes (if applicable)

---

## Section 8: Decision Log

Record every non-obvious decision made during the cleanup for future reference.

| Decision # | Repository | Decision Made | Alternatives Considered | Decided By | Date |
|-----------|-----------|--------------|------------------------|-----------|------|
| 1 | | | | | |

---

## Appendix A: Commands Used

```bash
# Example commands executed during this cleanup cycle

# Backup all repos
gh repo list mruhegwu --limit 1000 --json nameWithOwner \
  -q '.[].nameWithOwner' | while IFS='/' read -r owner repo; do
    git clone --mirror "https://github.com/$owner/$repo.git" \
        "$BACKUP_DIR/${owner}_${repo}.git"
done

# Archive a repo
gh repo archive mruhegwu/repo-name --yes

# Verify a backup
git -C "$BACKUP_DIR/mruhegwu_repo-name.git" fsck --quiet
```

---

## Appendix B: Repository Count Summary

| Status | Count Before | Count After | Delta |
|--------|-------------|------------|-------|
| Total Repositories | | | |
| Public | | | |
| Private | | | |
| Forked | | | |
| Archived | | | |

---

*Report generated using the [Repository Cleanup Toolkit](README.md).*
