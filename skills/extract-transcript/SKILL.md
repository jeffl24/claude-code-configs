---
name: extract-transcript
description: >
  Extract the full transcript from a SharePoint Stream video recording page.
  Works even when the Download button is permission-locked and the transcript
  panel uses lazy-loading/virtualization. Trigger when the user asks to extract,
  download, or grab a transcript from a SharePoint Stream or Teams recording URL.
user_invocable: true
---

# Extract SharePoint Stream Transcript

Extract the full transcript from a SharePoint Stream video recording page by reading
the React component state directly, bypassing lazy-loading virtualization and
permission-locked download buttons.

## Required argument

`$ARGUMENTS` should be the full SharePoint Stream URL to the video recording.

If no URL is provided, ask the user for one before proceeding.

## Steps

### 1. Navigate to the page

Use the Chrome browser automation tools:

1. Call `mcp__claude-in-chrome__tabs_context_mcp` with `createIfEmpty: true`
2. Create a new tab with `mcp__claude-in-chrome__tabs_create_mcp`
3. Navigate to the provided URL using `mcp__claude-in-chrome__navigate`
4. Wait 5 seconds for the page to load using `mcp__claude-in-chrome__computer` with action `wait`

### 2. Open the transcript panel (if not already open)

1. Take a screenshot to check the current page state
2. Look for a "Transcript" tab/button on the right side of the video player
3. If the transcript panel is not visible, click the Transcript tab to open it
4. Wait 3 seconds for the transcript to begin loading

### 3. Extract the transcript from React state

The transcript data is stored in the React component tree and can be extracted
directly without scrolling. Run this JavaScript via `mcp__claude-in-chrome__javascript_tool`:

```javascript
// Find the scrollable transcript container
const container = document.querySelector('.ms-FocusZone[class*="focusZoneWithSearchBox"]');
if (!container) throw new Error('Transcript container not found. Make sure the Transcript panel is open.');

// Walk the React fiber tree to find the entries array
const fiberKey = Object.keys(container).find(k => k.startsWith('__reactFiber'));
if (!fiberKey) throw new Error('React fiber not found on container element.');

let fiber = container[fiberKey];
let depth = 0;
let entries = null;

while (fiber && depth < 50) {
  if (fiber.memoizedProps?.entries?.length > 10) {
    entries = fiber.memoizedProps.entries;
    break;
  }
  fiber = fiber.return;
  depth++;
}

if (!entries) throw new Error('Transcript entries not found in React state. The page structure may have changed.');

// Parse ISO 8601 duration timestamps (e.g., "PT1H30M45S")
function parseDuration(iso) {
  if (!iso) return '';
  const match = iso.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/);
  if (!match) return iso;
  const h = parseInt(match[1] || '0');
  const m = parseInt(match[2] || '0');
  const s = parseInt(match[3] || '0');
  if (h > 0) return `${h}:${String(m).padStart(2,'0')}:${String(s).padStart(2,'0')}`;
  return `${m}:${String(s).padStart(2,'0')}`;
}

// Filter to text entries only and format
const textEntries = entries.filter(e => e.type === 'Text' && e.text?.trim());

let transcript = '';
let currentSpeaker = '';
for (const entry of textEntries) {
  const speaker = entry.speakerDisplayName || 'Unknown';
  const timeStr = parseDuration(entry.timestamp);
  if (speaker !== currentSpeaker) {
    transcript += `\n${speaker} [${timeStr}]\n`;
    currentSpeaker = speaker;
  }
  transcript += entry.text + ' ';
}

window._fullTranscript = transcript.trim();
window._entryCount = textEntries.length;
```

### 4. Add a title header

Extract the video title from `document.title` and prepend it as a header to the transcript.

### 5. Save the transcript file

Use JavaScript to trigger a browser download of the transcript as a `.txt` file:

```javascript
const title = document.title.replace(/\.[^.]+$/, '').replace(/[^a-zA-Z0-9_\- ]/g, '');
const filename = title.trim().replace(/\s+/g, '_') + '_transcript.txt';

const blob = new Blob([window._fullTranscript], { type: 'text/plain' });
const url = URL.createObjectURL(blob);
const a = document.createElement('a');
a.href = url;
a.download = filename;
document.body.appendChild(a);
a.click();
document.body.removeChild(a);
URL.revokeObjectURL(url);
```

The file will be saved to the user's Downloads folder.

### 6. Verify and report

1. Verify the file exists in `~/Downloads/` using the Glob tool
2. Report to the user:
   - File path and size
   - Number of transcript entries extracted
   - Duration range (first to last timestamp)
   - List of speakers found in the transcript

## Troubleshooting

- If the transcript panel is not visible, try scrolling down or looking for a
  "Transcript" tab on the right sidebar
- If the React fiber tree doesn't contain `entries`, the SharePoint Stream UI may
  have been updated. Fall back to scrolling the transcript panel and collecting
  text incrementally
- If the container selector `.ms-FocusZone[class*="focusZoneWithSearchBox"]`
  doesn't match, take a screenshot and look for the transcript container manually,
  then adapt the selector
