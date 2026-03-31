# 🗂️ Repository Categorization Template

Use this template to classify every repository in your GitHub account into one of four action categories before beginning a cleanup cycle.

---

## How to Use This Template

1. Copy the **Repository Entry** table below for each repository (or export it to a spreadsheet).
2. Fill in every column honestly; use the scoring guide to stay consistent.
3. Assign a final **Category** (KEEP / ARCHIVE / DELETE / REVIEW).
4. Transfer the results to your [CLEANUP-REPORT-TEMPLATE.md](CLEANUP-REPORT-TEMPLATE.md).

---

## Category Definitions

| Category | Symbol | Meaning |
|----------|--------|---------|
| **KEEP** | 🟢 | Actively used or high future value; no action needed |
| **ARCHIVE** | 📦 | Valuable for reference but no longer actively developed; make read-only |
| **DELETE** | 🗑️ | No value, obsolete, or a fork with no local changes; remove after backup |
| **REVIEW** | 🔵 | Uncertain; requires manual investigation before deciding |

---

## Scoring Rubric

Score each dimension 1–5, then sum for a **Total Score (5–25)**.

| Dimension | 1 (Lowest) | 3 (Mid) | 5 (Highest) |
|-----------|-----------|---------|------------|
| **Last Activity** | > 2 years ago | 6–12 months ago | < 3 months ago |
| **Business Value** | No relevance | Nice-to-have | Core / revenue-generating |
| **Code Quality** | Abandoned / broken | Partial / draft | Production-ready |
| **Uniqueness** | Public fork, unchanged | Lightly customized | Original work |
| **External Dependency** | Nobody depends on it | Shared internally | Public users depend on it |

### Suggested Category by Score

| Total Score | Recommended Category |
|-------------|---------------------|
| 20 – 25 | 🟢 KEEP |
| 13 – 19 | 🔵 REVIEW |
| 7 – 12 | 📦 ARCHIVE |
| 5 – 6 | 🗑️ DELETE |

---

## Repository Entry

Copy this block once per repository and fill it in.

```
## Repository: <name>

| Field | Value |
|-------|-------|
| Full Name | <owner>/<repo> |
| URL | https://github.com/<owner>/<repo> |
| Description | <paste GitHub description or "none"> |
| Language(s) | |
| Stars / Forks | |
| Is Fork? | Yes / No |
| Private? | Yes / No |
| Last Commit Date | YYYY-MM-DD |
| Open Issues | |
| Open PRs | |

### Scoring

| Dimension | Score (1–5) | Notes |
|-----------|------------|-------|
| Last Activity | | |
| Business Value | | |
| Code Quality | | |
| Uniqueness | | |
| External Dependency | | |
| **Total** | **/25** | |

### Decision

- **Category**: [ ] 🟢 KEEP  [ ] 📦 ARCHIVE  [ ] 🗑️ DELETE  [ ] 🔵 REVIEW
- **Rationale**: 
- **Backup Required Before Action?**: Yes / No
- **Decided By**: 
- **Decision Date**: YYYY-MM-DD
```

---

## Example: Completed Entries

### Repository: TTSHUB

| Field | Value |
|-------|-------|
| Full Name | mruhegwu/TTSHUB |
| URL | https://github.com/mruhegwu/TTSHUB |
| Description | Centralized Digital Service Marketplace |
| Language(s) | JavaScript, Python |
| Stars / Forks | 2 / 0 |
| Is Fork? | No |
| Private? | No |
| Last Commit Date | 2026-03-31 |
| Open Issues | 3 |
| Open PRs | 1 |

**Scoring**

| Dimension | Score | Notes |
|-----------|-------|-------|
| Last Activity | 5 | Committed this month |
| Business Value | 5 | Core product |
| Code Quality | 4 | Active development |
| Uniqueness | 5 | Original work |
| External Dependency | 3 | Internal team uses it |
| **Total** | **22/25** | |

**Decision**

- **Category**: 🟢 KEEP
- **Rationale**: Active core product, high business value.
- **Backup Required Before Action?**: N/A (no action)
- **Decided By**: mruhegwu
- **Decision Date**: 2026-03-31

---

### Repository: netlify-feature-tour-4d2d9

| Field | Value |
|-------|-------|
| Full Name | mruhegwu/netlify-feature-tour-4d2d9 |
| Description | Auto-generated Netlify demo |
| Is Fork? | Yes |
| Last Commit Date | 2022-11-05 |

**Scoring**

| Dimension | Score | Notes |
|-----------|-------|-------|
| Last Activity | 1 | Over 2 years before this cleanup cycle |
| Business Value | 1 | Auto-generated demo, no value |
| Code Quality | 1 | Scaffold code only |
| Uniqueness | 1 | Auto-generated fork |
| External Dependency | 1 | Nobody uses it |
| **Total** | **5/25** | |

**Decision**

- **Category**: 🗑️ DELETE
- **Rationale**: Auto-generated Netlify tour with no personal content.
- **Backup Required Before Action?**: No
- **Decided By**: mruhegwu
- **Decision Date**: 2026-03-31

---

## Bulk Categorization Table

Use this condensed table when reviewing a large number of repositories at once.

| Repository | Last Commit | Score | Category | Action | Backup? | Decided By | Date |
|-----------|------------|-------|----------|--------|---------|-----------|------|
| TTSHUB | 2026-03-31 | 22 | 🟢 KEEP | None | No | | |
| agent-academy | | | | | | | |
| awesome-go | | | | | | | |
| netlify-feature-tour-4d2d9 | 2024-01-10 | 5 | 🗑️ DELETE | Delete | No | | |
| shadPS4 | | | | | | | |
| NemoClaw | | | | | | | |
| *(add more rows)* | | | | | | | |

---

## Notes

- Resolve all **REVIEW** items within **7 days** of starting a cleanup cycle to avoid decision fatigue.
- When in doubt between ARCHIVE and DELETE, choose **ARCHIVE** — it costs nothing and is reversible.
- Re-run this categorization process at least **once per quarter** to keep your account tidy.
