# 🔄 Restoration Guide

Step-by-step instructions for recovering repositories from mirror-clone backups created by this toolkit.

---

## Table of Contents

1. [Recovery Scenarios](#recovery-scenarios)
2. [Prerequisites](#prerequisites)
3. [Scenario A: Restore a Deleted Repository](#scenario-a-restore-a-deleted-repository)
4. [Scenario B: Restore a Single Branch](#scenario-b-restore-a-single-branch)
5. [Scenario C: Restore to a Different Account or Organization](#scenario-c-restore-to-a-different-account-or-organization)
6. [Scenario D: Restore from a Compressed Archive](#scenario-d-restore-from-a-compressed-archive)
7. [Scenario E: Restore from Cloud Storage (AWS S3)](#scenario-e-restore-from-cloud-storage-aws-s3)
8. [Scenario F: Restore from Google Drive (rclone)](#scenario-f-restore-from-google-drive-rclone)
9. [Verifying a Restored Repository](#verifying-a-restored-repository)
10. [Partial Recovery (Individual Files or Commits)](#partial-recovery-individual-files-or-commits)
11. [Post-Restoration Checklist](#post-restoration-checklist)
12. [Troubleshooting](#troubleshooting)

---

## Recovery Scenarios

| Scenario | When to Use |
|----------|------------|
| A — Restore Deleted Repository | You accidentally deleted a repository and need to recover everything |
| B — Restore a Single Branch | You need one branch from a backup without re-creating the whole repo |
| C — Restore to Different Account | You are migrating a repository to a new account or organization |
| D — Restore from Compressed Archive | Your backup is a `.tar.gz` file rather than a bare `.git` directory |
| E — Restore from S3 | Your backup lives in an AWS S3 bucket |
| F — Restore from Google Drive | Your backup was uploaded via rclone to Google Drive |

---

## Prerequisites

| Tool | Install |
|------|---------|
| Git ≥ 2.28 | [git-scm.com](https://git-scm.com) |
| GitHub CLI (`gh`) ≥ 2.0 | [cli.github.com](https://cli.github.com) |
| AWS CLI (Scenario E only) | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| rclone (Scenario F only) | [rclone.org](https://rclone.org) |

Authenticate the GitHub CLI:

```bash
gh auth login
```

---

## Scenario A: Restore a Deleted Repository

### Step 1 — Locate the backup

```bash
BACKUP_DIR="$HOME/github-backups-YYYY-MM-DD"
OWNER="mruhegwu"
REPO="repo-name"

ls "$BACKUP_DIR/${OWNER}_${REPO}.git"
```

### Step 2 — Verify backup integrity

```bash
git -C "$BACKUP_DIR/${OWNER}_${REPO}.git" fsck --quiet
echo "Exit code: $?"   # Must be 0
```

### Step 3 — Create a new GitHub repository

```bash
# Create the repository (adjust visibility as needed)
gh repo create "$OWNER/$REPO" --public --description "Restored from backup"
```

### Step 4 — Push the mirror backup to GitHub

```bash
cd "$BACKUP_DIR/${OWNER}_${REPO}.git"

# Update the push URL to the new repository
git remote set-url origin "https://github.com/$OWNER/$REPO.git"

# Push all refs (branches, tags, notes)
git push --mirror origin
```

### Step 5 — Verify on GitHub

```bash
gh repo view "$OWNER/$REPO"
```

Open the repository URL in your browser and confirm:
- All branches are present
- Commit history is intact
- Tags are restored

---

## Scenario B: Restore a Single Branch

Use this when you only need a specific branch from a backup without recreating the entire repository.

```bash
BACKUP_DIR="$HOME/github-backups-YYYY-MM-DD"
OWNER="mruhegwu"
REPO="repo-name"
BRANCH="main"
RESTORE_DIR="/tmp/${REPO}-restored"

# Clone just the one branch from the backup
git clone --single-branch --branch "$BRANCH" \
    "$BACKUP_DIR/${OWNER}_${REPO}.git" \
    "$RESTORE_DIR"

echo "Branch '$BRANCH' restored to: $RESTORE_DIR"
ls "$RESTORE_DIR"
```

---

## Scenario C: Restore to a Different Account or Organization

```bash
NEW_OWNER="new-account-or-org"
REPO="repo-name"
BACKUP_DIR="$HOME/github-backups-YYYY-MM-DD"
OLD_OWNER="mruhegwu"

# Create the repo under the new owner
gh repo create "$NEW_OWNER/$REPO" --public

cd "$BACKUP_DIR/${OLD_OWNER}_${REPO}.git"

# Point the remote at the new location
git remote set-url origin "https://github.com/$NEW_OWNER/$REPO.git"
git push --mirror origin

echo "Repository restored to https://github.com/$NEW_OWNER/$REPO"
```

---

## Scenario D: Restore from a Compressed Archive

If your backup was compressed with `tar`, extract it first.

```bash
ARCHIVE="/path/to/mruhegwu_repo-name.git.tar.gz"
EXTRACT_DIR="/tmp/backup-extract"
OWNER="mruhegwu"
REPO="repo-name"

# Extract archive
mkdir -p "$EXTRACT_DIR"
tar -xzf "$ARCHIVE" -C "$EXTRACT_DIR"

# Verify integrity of extracted backup
git -C "$EXTRACT_DIR/${OWNER}_${REPO}.git" fsck --quiet

# Create GitHub repo and push
gh repo create "$OWNER/$REPO" --public
cd "$EXTRACT_DIR/${OWNER}_${REPO}.git"
git remote set-url origin "https://github.com/$OWNER/$REPO.git"
git push --mirror origin
```

---

## Scenario E: Restore from Cloud Storage (AWS S3)

### Download from S3

```bash
S3_BUCKET="s3://my-github-backups/YYYY-MM-DD"
OWNER="mruhegwu"
REPO="repo-name"
LOCAL_DIR="/tmp/s3-restore"

mkdir -p "$LOCAL_DIR"
aws s3 cp "$S3_BUCKET/${OWNER}_${REPO}.git.tar.gz" "$LOCAL_DIR/"
```

### Extract and restore

```bash
tar -xzf "$LOCAL_DIR/${OWNER}_${REPO}.git.tar.gz" -C "$LOCAL_DIR"
git -C "$LOCAL_DIR/${OWNER}_${REPO}.git" fsck --quiet

gh repo create "$OWNER/$REPO" --public
cd "$LOCAL_DIR/${OWNER}_${REPO}.git"
git remote set-url origin "https://github.com/$OWNER/$REPO.git"
git push --mirror origin
```

---

## Scenario F: Restore from Google Drive (rclone)

```bash
GDRIVE_REMOTE="gdrive:github-backups/YYYY-MM-DD"
OWNER="mruhegwu"
REPO="repo-name"
LOCAL_DIR="/tmp/gdrive-restore"

# Download from Google Drive
mkdir -p "$LOCAL_DIR"
rclone copy "$GDRIVE_REMOTE/${OWNER}_${REPO}.git.tar.gz" "$LOCAL_DIR/" --progress

# Extract and restore (same as Scenario D from here)
tar -xzf "$LOCAL_DIR/${OWNER}_${REPO}.git.tar.gz" -C "$LOCAL_DIR"
git -C "$LOCAL_DIR/${OWNER}_${REPO}.git" fsck --quiet

gh repo create "$OWNER/$REPO" --public
cd "$LOCAL_DIR/${OWNER}_${REPO}.git"
git remote set-url origin "https://github.com/$OWNER/$REPO.git"
git push --mirror origin
```

---

## Verifying a Restored Repository

Run these checks after every restoration to confirm completeness.

```bash
OWNER="mruhegwu"
REPO="repo-name"

# 1. Check remote repo info
gh repo view "$OWNER/$REPO"

# 2. Count branches
echo "Branches:"
gh api "repos/$OWNER/$REPO/branches" --jq '.[].name'

# 3. Count tags
echo "Tags:"
gh api "repos/$OWNER/$REPO/tags" --jq '.[].name'

# 4. Show latest commit
gh api "repos/$OWNER/$REPO/commits" --jq '.[0] | {sha: .sha, message: .commit.message, date: .commit.author.date}'
```

---

## Partial Recovery (Individual Files or Commits)

When you only need a specific file or commit, avoid a full restoration.

### Extract a Single File from a Backup

```bash
BACKUP_DIR="$HOME/github-backups-YYYY-MM-DD"
OWNER="mruhegwu"
REPO="repo-name"
COMMIT_OR_BRANCH="main"
FILE_PATH="src/app.py"

git -C "$BACKUP_DIR/${OWNER}_${REPO}.git" \
    show "${COMMIT_OR_BRANCH}:${FILE_PATH}" > /tmp/recovered_app.py

echo "File recovered to /tmp/recovered_app.py"
```

### View Commit History Without Restoring

```bash
git -C "$BACKUP_DIR/${OWNER}_${REPO}.git" \
    log --oneline --graph --all | head -30
```

### Cherry-Pick a Specific Commit into an Existing Repo

```bash
# Add the backup as a remote in an existing working clone
cd /path/to/existing-repo
git remote add backup "$BACKUP_DIR/${OWNER}_${REPO}.git"
git fetch backup

# Cherry-pick the commit
git cherry-pick <commit-sha>

# Remove the temporary remote
git remote remove backup
```

---

## Post-Restoration Checklist

- [ ] Repository exists on GitHub with correct visibility (public/private)
- [ ] All expected branches are present
- [ ] All tags are present
- [ ] Latest commit SHA matches the backup manifest
- [ ] README and key files display correctly on GitHub
- [ ] CI/CD pipelines (if any) are re-configured and passing
- [ ] Webhooks and integrations re-added (GitHub does not restore these)
- [ ] Collaborators re-invited (GitHub does not restore permissions)
- [ ] Issue tracker and project boards re-created manually if needed
- [ ] Cleanup report updated to document the restoration

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| `fatal: repository not found` | Backup directory path is wrong | Verify `$BACKUP_DIR` and `ls` to confirm the `.git` folder exists |
| `remote: Repository not found` on push | GitHub repo was not created first | Run `gh repo create` before `git push --mirror` |
| `! [remote rejected]` on push | Missing permissions | Ensure your token has `repo` scope: `gh auth refresh -s repo` |
| `fsck` reports errors | Incomplete or corrupted backup | Re-run the backup from source while the repo still exists |
| Only default branch restored | Used `git clone` instead of `--mirror` | Re-push with `git push --mirror origin` from the backup directory |
| Missing issues / PRs | GitHub does not export issues in git | Export issues separately using `gh issue list --json` before deletion |

---

*Part of the [Repository Cleanup Toolkit](README.md).*
