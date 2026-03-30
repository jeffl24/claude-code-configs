---
name: meeting-summary
description: >
  Summarize one or more meeting transcript files (.vtt, .srt, .txt) into structured markdown
  documents. Each transcript gets its own output file with headers, topic sections, and a
  Key Decisions & Action Items table. Trigger when the user references transcript files and
  asks to summarize, export, or document meeting notes. Also trigger on phrases like
  "summarize this meeting", "export meeting notes", "generate meeting summary", or
  "summarize these transcripts".
user_invocable: true
---

# Meeting Summary

Summarize one or more meeting transcript files into detailed, structured markdown documents.
Each transcript gets its own output file saved alongside the source file.

> This skill works with any transcript format: `.vtt` (WebVTT), `.srt`, or plain `.txt`.
> Files are processed in parallel when multiple transcripts are provided.

## Workflow

### 1. Identify transcript files

Collect all transcript files the user referenced. If none are specified, glob for `.vtt`,
`.srt`, and `.txt` files in the current working directory and confirm with the user before
proceeding.

### 2. Handle large files

Transcript files are often large (100KB–400KB+). **Never try to read them in one call.**
Use `offset` and `limit` parameters on the Read tool to read in chunks of ~500 lines at a
time, iterating until the end of the file is reached. Track which chunk you're on and
accumulate the full content before writing the summary.

VTT/SRT format has interleaved timestamp lines — ignore them:
- Skip lines matching `\d{2}:\d{2}:\d{2}[.,]\d{3}\s*-->\s*\d{2}:\d{2}:\d{2}[.,]\d{3}`
- Skip blank lines and sequence number lines (standalone integers in SRT)
- Extract only the spoken text lines

### 3. Process transcripts in parallel

When summarizing multiple files, launch parallel agents — one per transcript — to avoid
sequential bottlenecks. Each agent should:
1. Read the full transcript in chunks
2. Identify all major topics discussed
3. Write the summary markdown file (see format below)

### 4. Summary document format

Output file naming: replace the source file extension with ` - Summary.md`
Example: `Workshop 1.vtt` → `Workshop 1 - Summary.md` (saved in the same directory)

Use this structure:

```markdown
# <Meeting Title> — Meeting Summary

## Overview
- **Date:** (extract from transcript if mentioned, otherwise note "not stated")
- **Participants:** (list names/roles mentioned)
- **Duration:** (if determinable from timestamps)
- **Purpose:** (one-sentence description of the meeting's goal)

## <Major Topic 1>

### <Sub-topic 1.1>
- Key point
- Key point

### <Sub-topic 1.2>
...

## <Major Topic 2>
...

## Key Decisions & Action Items

| # | Decision / Action Item | Owner | Timeline |
|---|------------------------|-------|----------|
| 1 | ...                    | ...   | ...      |

## Open Questions & Unresolved Debates
- ...
```

### 5. What to capture — be thorough

Do NOT paraphrase away specifics. Capture:

- **Named frameworks, models, and architectures** — exact names (e.g., DDPG, MPC, LangGraph,
  MEDDPICC, Airflow, RAG, etc.)
- **Product/feature names** — as spoken (e.g., "Orca chatbot", "Match Engine", "DMM")
- **Specific numbers and metrics** — percentages, latencies, counts, thresholds
- **Tool and vendor names** — software, cloud services, APIs, platforms
- **Decisions made** — what was agreed, confirmed, or rejected, and by whom
- **Action items** — who owns what and by when
- **Concerns and debates** — disagreements, trade-offs, risks raised
- **Strategic priorities** — goals, OKRs, roadmap items mentioned
- **Analogies and examples** — specific examples used to illustrate points

### 6. Confirm completion

After all files are written, report to the user:
- Which summary files were created and their paths
- A one-line description of each meeting's main topic(s)
- Any files that could not be fully processed (e.g., read errors, truncation)

## Quality Standards

- Every major topic discussed should have its own `##` section
- Use `###` for sub-topics when a section has 3+ distinct angles
- Bullet points should be specific enough to stand alone without re-reading the transcript
- The Key Decisions table must cover ALL decisions, not just the last few
- Open questions must capture genuine ambiguity — not rhetorical questions

## Edge Cases

- **Speaker diarization**: If speakers are labeled (e.g., `SPEAKER_01:`, `Jeff:`), include
  speaker attribution for key decisions and action items where it adds clarity.
- **Crosstalk / filler words**: Strip filler words (`um`, `uh`, `you know`) but preserve
  meaning. Do not sanitize substantive hesitation (e.g., "we're not sure if X will work").
- **Repeated topics**: If a topic resurfaces across the meeting, consolidate into one section
  rather than duplicating it.
- **Very long meetings (2h+)**: Add a `## Session Timeline` section at the top mapping rough
  timestamps to topic sections, so readers can jump to relevant parts.
- **No clear structure**: If the meeting is free-form, derive topics from the natural flow of
  conversation — do not force an artificial structure.
