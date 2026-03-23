# Copy as Markdown

Export Claude's response(s) to markdown, properly formatted as markdown. Copies to clipboard AND exports to a markdown file in the current project directory.

## Input

$ARGUMENTS

## Instructions

### Determine scope

Check the argument:
- If empty or no argument: Export only the **last assistant response**
- If `-all`: Export the **entire conversation history**

### Generate a title

Analyze the conversation content and generate a descriptive, concise title:
1. Look at the main topic or task discussed
2. Create a kebab-case filename from the title (e.g., `refactoring-auth-module`, `debugging-api-errors`)
3. Add a timestamp prefix in format `YYYYMMDD-HHMMSS` for uniqueness (e.g., `20250304-143022-refactoring-auth-module.md`)

### Format as Markdown

#### For single response (default):
1. Take the last assistant response from this conversation
2. Add a title header at the top: `# <Generated Title>`
3. Ensure all code blocks have proper language tags (```python, ```bash, etc.)
4. Preserve all formatting: headers, lists, tables, bold, italic
5. Output the formatted markdown

#### For full history (`-all`):
1. Format the entire conversation as markdown:
   ```markdown
   # <Generated Title>

   ## User
   <user message>

   ## Assistant
   <assistant response>

   ---

   ## User
   <user message>

   ## Assistant
   <assistant response>

   ...
   ```
2. Preserve all code blocks, tables, and formatting
3. Add horizontal rules `---` between exchanges for readability

### Export to file

1. Write the formatted markdown content to a file in the **current working directory**
2. Use the generated filename: `<timestamp>-<title>.md`
3. Use the Write tool to create the file

### Copy to Clipboard

After formatting and saving, run this command to copy to clipboard:

```bash
pbcopy
```

Pipe the formatted markdown content to `pbcopy`.

### Confirm

Tell the user:
- What was copied (last response or full history)
- The filename and path of the exported markdown file
- Approximate length (number of lines or characters)
- That the content is ready to paste from clipboard

## Example Usage

- `/copy-markdown` — copies last response, exports to file like `20250304-143022-api-setup-guide.md`
- `/copy-markdown -all` — copies entire conversation, exports to file like `20250304-143022-debugging-session.md`
