---
name: screenshot-renamer
description: >
  Batch rename screenshot files by viewing each image, identifying its content, and renaming to a
  standardized "yyyy-mm-dd content description" format. Use this skill whenever the user asks to
  rename, organize, or clean up screenshot files, or when they have a folder of images with
  cryptic names (like SCR-*, Screenshot*, IMG_*, or any auto-generated filenames) and want them
  made human-readable. Also trigger when the user mentions "rename my screenshots",
  "organize my images", "clean up filenames", or similar.
user_invocable: true
---

# Screenshot Renamer

Rename screenshot files in the **current working directory** by viewing each image, identifying
its content, and applying a clean `yyyy-mm-dd content` naming convention. The date comes from
the file's modification timestamp.

> This skill operates on whichever folder Claude Code is currently running in. No directory is
> hardcoded — just `cd` into the target folder (or launch Claude Code there) and invoke the skill.

## Workflow

### 1. Inventory the folder

List all image files (`.png`, `.jpeg`, `.jpg`, `.webp`, etc.) in the current directory. Use
`ls -la` to get file counts and a sense of what's there. Ignore non-image files like `.DS_Store`.

### 2. Get exact timestamps

Run `stat` on all image files to extract modification timestamps. These become the `yyyy-mm-dd`
prefix. Use this macOS-compatible pattern:

```bash
for f in *.png *.jpeg *.jpg *.webp; do
  [ -f "$f" ] || continue
  ts=$(stat -f '%m' "$f")
  echo "$(date -r $ts '+%Y-%m-%d') | $f"
done | sort
```

### 3. Categorize files before viewing

Split files into two groups:

- **Already descriptive names** — Files whose names already contain meaningful context (e.g.,
  YouTube video titles, project names). Extract the content phrase from the existing name. You
  may still want to view these to confirm or refine the description.
- **Cryptic names** — Files like `SCR-*`, `Screenshot*`, `IMG_*`, or any auto-generated names.
  These must be viewed to identify content.

### 4. View images in parallel batches

Use the `Read` tool to view images. Read 6-8 files per batch to maximize throughput. If a file
fails to read (resource locks, corruption), note it and move on — you can retry once later, then
fall back to a generic name if it still fails.

For each image, write a short content phrase (2-6 words) that captures what the screenshot shows.
Good phrases are specific and scannable:

- "AWS ECS chatbot service deployment" (specific)
- "LangGraph Udemy web search node" (specific)
- "Malwarebytes scan complete zero threats" (specific)

Avoid vague phrases like "code screenshot" or "web page" — add enough context to distinguish
the file from others.

### 5. Handle duplicates from the same source

When multiple screenshots come from the same source (e.g., a YouTube video, a multi-page
document, a series of related captures), append `pt1`, `pt2`, `pt3` etc. to keep them
distinguishable. Order by timestamp.

### 6. Execute renames

Build and run rename commands using `mv`. Key considerations:

- **Special characters in filenames**: Use glob patterns (`for f in Pattern*; do mv "$f" ...`)
  instead of quoting exact names, since filenames may contain smart quotes, unicode spaces, or
  other tricky characters that break shell quoting.
- **Batch by group**: Rename in logical batches (by date or source) so partial failures are easy
  to diagnose.
- **Always quote variables**: `mv "$f" "$new_name"` to handle spaces in both old and new names.

Naming format: `yyyy-mm-dd content phrase.ext`

Example renames:
```
SCR-20251105-mpfk.png        → 2025-11-05 Malwarebytes scan complete zero threats.png
Screenshot 2025-11-12 at...  → 2025-11-12 LangGraph Udemy web search node.png
Kenneth Tanaka - OPPO...     → 2025-11-25 OPPO Find X9 Pro review pt1.png
```

### 7. Verify

After all renames, list the folder contents sorted alphabetically to confirm:
- No old-format filenames remain (check for `SCR-*`, `Screenshot*`, `IMG_*`, etc.)
- Total file count matches the original inventory
- Names are clean and chronologically sortable

### 8. Report unreadable files

If any files couldn't be read and got generic names, tell the user which ones so they can
manually rename them.

## Edge Cases

- **Video timestamps in filenames**: YouTube screenshot tools embed video timestamps like
  `[ID - 1545x869 - 13m29s]`. Strip these entirely — the content phrase should describe what's
  shown, not the video position.
- **Duplicate timestamps**: If two files land on the same `yyyy-mm-dd` with identical content
  phrases, append `pt1`/`pt2` to differentiate.
- **Mixed extensions**: Preserve the original file extension (`.png`, `.jpeg`, `.jpg`, etc.).
  Don't convert between formats.
- **Non-screenshot files**: If the folder contains non-image files, leave them alone unless the
  user explicitly asks to rename everything.
