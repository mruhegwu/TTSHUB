# 🗄️ Backup Guide

Comprehensive procedures for creating full, restorable backups of GitHub repositories before any cleanup operation.

---

## Table of Contents

1. [Why Mirror Clones?](#why-mirror-clones)
2. [Prerequisites](#prerequisites)
3. [Method 1: Mirror Clone (Recommended)](#method-1-mirror-clone-recommended)
4. [Method 2: Selective Backup](#method-2-selective-backup)
5. [Method 3: Full Account Backup via GitHub CLI](#method-3-full-account-backup-via-github-cli)
6. [Method 4: Cloud Storage (AWS S3)](#method-4-cloud-storage-aws-s3)
7. [Method 5: Cloud Storage (Google Drive / rclone)](#method-5-cloud-storage-google-drive--rclone)
8. [Verifying Backups](#verifying-backups)
9. [Backup Storage Best Practices](#backup-storage-best-practices)
10. [Scheduled / Automated Backups](#scheduled--automated-backups)
11. [Troubleshooting](#troubleshooting)

---

## Why Mirror Clones?

A standard `git clone` copies only the default branch. A **mirror clone** (`git clone --mirror`) captures:

- All branches (including remote-tracking branches)
- All tags
- Complete commit history
- Git notes and other refs

This guarantees a bit-for-bit copy that can be pushed to a new host and resume as if nothing changed.

---

## Prerequisites

| Tool | Minimum Version | Install |
|------|----------------|---------|
| Git | 2.28 | [git-scm.com](https://git-scm.com) |
| GitHub CLI (`gh`) | 2.0 | [cli.github.com](https://cli.github.com) |
| AWS CLI (optional) | 2.x | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| rclone (optional) | 1.60 | [rclone.org](https://rclone.org) |
| Bash | 4+ | `brew install bash` on macOS |

Authenticate the GitHub CLI before running any commands:

```bash
gh auth login
```

---

## Method 1: Mirror Clone (Recommended)

Mirror clones are the gold standard for complete repository backups.

### Single Repository

```bash
# Variables
OWNER="mruhegwu"
REPO="TTSHUB"
BACKUP_DIR="$HOME/github-backups-$(date +%Y-%m-%d)"

mkdir -p "$BACKUP_DIR"
git clone --mirror "https://github.com/$OWNER/$REPO.git" \
    "$BACKUP_DIR/${OWNER}_${REPO}.git"
```

### Multiple Named Repositories

```bash
OWNER="mruhegwu"
BACKUP_DIR="$HOME/github-backups-$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

REPOS=(
  "TTSHUB"
  "agent-academy"
  "Deploy-Your-AI-Application-In-Production"
  "Multi-Agent-Custom-Automation-Engine-Solution-Accelerator"
)

for REPO in "${REPOS[@]}"; do
  echo "Backing up $REPO ..."
  git clone --mirror "https://github.com/$OWNER/$REPO.git" \
      "$BACKUP_DIR/${OWNER}_${REPO}.git"
done
echo "Done. Backups saved to $BACKUP_DIR"
```

---

## Method 2: Selective Backup

Use when you only need to preserve specific high-value repositories.

```bash
OWNER="mruhegwu"
BACKUP_DIR="$HOME/github-backups-$(date +%Y-%m-%d)/selective"
mkdir -p "$BACKUP_DIR"

# Clone with full history but as a bare (lightweight) repo
for REPO in agent-academy TTSHUB; do
  git clone --bare "https://github.com/$OWNER/$REPO.git" \
      "$BACKUP_DIR/$REPO.git"
done
```

> **Note:** `--bare` is slightly smaller than `--mirror` but omits some remote refs. Use `--mirror` when in doubt.

---

## Method 3: Full Account Backup via GitHub CLI

Backs up every repository in an account automatically.

```bash
OWNER="mruhegwu"
BACKUP_DIR="$HOME/github-backups-$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

gh repo list "$OWNER" --limit 1000 \
  --json nameWithOwner \
  -q '.[].nameWithOwner' | while IFS='/' read -r owner repo; do
    echo "Cloning $owner/$repo ..."
    git clone --mirror "https://github.com/$owner/$repo.git" \
        "$BACKUP_DIR/${owner}_${repo}.git"
done

echo "All repositories backed up to $BACKUP_DIR"
```

---

## Method 4: Cloud Storage (AWS S3)

After creating mirror clones locally, upload them to S3 for off-site durability.

```bash
# Prerequisites: AWS CLI configured with sufficient S3 permissions
BACKUP_DIR="$HOME/github-backups-$(date +%Y-%m-%d)"
S3_BUCKET="s3://my-github-backups/$(date +%Y-%m-%d)/"

# Compress and upload each mirror
for DIR in "$BACKUP_DIR"/*.git; do
  NAME=$(basename "$DIR")
  TAR_FILE="/tmp/$NAME.tar.gz"
  echo "Compressing $NAME ..."
  tar -czf "$TAR_FILE" -C "$(dirname "$DIR")" "$NAME"
  echo "Uploading $NAME to S3 ..."
  aws s3 cp "$TAR_FILE" "$S3_BUCKET"
  rm -f "$TAR_FILE"
done

echo "Upload complete: $S3_BUCKET"
```

---

## Method 5: Cloud Storage (Google Drive / rclone)

```bash
# Prerequisites: rclone configured with a remote named "gdrive"
BACKUP_DIR="$HOME/github-backups-$(date +%Y-%m-%d)"
GDRIVE_REMOTE="gdrive:github-backups/$(date +%Y-%m-%d)"

rclone copy "$BACKUP_DIR" "$GDRIVE_REMOTE" \
  --progress \
  --transfers 4

echo "Sync complete: $GDRIVE_REMOTE"
```

Configure rclone once with `rclone config` — follow the interactive prompts to add a Google Drive remote.

---

## Verifying Backups

Always verify a backup before relying on it.

### Check Git Object Integrity

```bash
BACKUP_DIR="$HOME/github-backups-$(date +%Y-%m-%d)"

for DIR in "$BACKUP_DIR"/*.git; do
  echo -n "Verifying $(basename "$DIR") ... "
  if git -C "$DIR" fsck --quiet 2>/dev/null; then
    echo "OK"
  else
    echo "FAILED — investigate $DIR"
  fi
done
```

### List All Backed-Up Branches

```bash
git -C "$BACKUP_DIR/mruhegwu_TTSHUB.git" branch -a
```

### Test-Restore to a Temporary Location

```bash
BACKUP_DIR="$HOME/github-backups-$(date +%Y-%m-%d)"
TEST_DIR="/tmp/restore-test"
mkdir -p "$TEST_DIR"

git clone "$BACKUP_DIR/mruhegwu_TTSHUB.git" "$TEST_DIR/TTSHUB"
echo "Files restored: $(find "$TEST_DIR/TTSHUB" -type f | wc -l)"
rm -rf "$TEST_DIR"
```

---

## Backup Storage Best Practices

| Practice | Rationale |
|----------|-----------|
| **3-2-1 Rule** | 3 copies, on 2 different media, 1 off-site (e.g., local NAS + S3 + external drive) |
| **Date-stamped directories** | Makes it easy to identify which backup corresponds to which cleanup event |
| **Retain for ≥ 30 days** | Ensures you can recover from post-deletion regret |
| **Integrity check after backup** | Catches network corruption during clone |
| **Store credentials separately** | Never commit tokens or SSH keys into the backup archive |

---

## Scheduled / Automated Backups

Add a cron job to run monthly full-account backups:

```bash
# Edit crontab:  crontab -e
# Run at 02:00 on the 1st of every month
0 2 1 * * /home/user/repo-cleanup/AUTOMATED-CLEANUP-SCRIPT.sh --backup-only >> /var/log/github-backup.log 2>&1
```

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| `Authentication failed` | Token expired or missing `repo` scope | Re-run `gh auth login` |
| `Repository not found` | Private repo or wrong name | Verify with `gh repo list` |
| `No space left on device` | Disk full | Free space or change `BACKUP_DIR` to a larger volume |
| `fsck` reports missing objects | Incomplete clone (network error) | Delete the partial `.git` folder and re-run |
| Backup is very slow | Large LFS objects | Add `--no-local` and increase timeout |
