# Generate Mermaid Flowchart for Lucidchart

Convert an ASCII diagram, description, or code architecture into Mermaid flowchart code optimized for Lucidchart import.

## Input

Diagram source: $ARGUMENTS

## Instructions

### Phase 1: Interpret the Source

1. **Determine the input type:**
   - ASCII art diagram (box-and-arrow)
   - Natural language description of a flow
   - File path(s) to read and extract architecture from
   - Code reference (class hierarchy, request flow, pipeline)

2. **If a file path is provided**, read the file and extract the relevant structure. If the input is a description, clarify any ambiguous relationships before generating.

3. **Identify the diagram elements:**
   - Nodes (processes, services, decisions, data stores)
   - Edges (data flow, control flow, optional/conditional paths)
   - Groupings (subgraphs for logical sections)
   - Hierarchy depth (nested subgraphs if needed)

### Phase 2: Generate Mermaid Code

Generate a single Mermaid `flowchart TD` code block following these Lucidchart-compatible rules:

#### Node Syntax
- Standard process: `id["Label text"]`
- Decision/conditional: `id{"Question?"}`
- Database/storage: `id[("Database label")]`
- Use `<b>` for bold titles inside labels
- Use `<br/>` for line breaks inside labels (NOT `\n`)

#### Layout & Flow
- Default to `flowchart TD` (top-down) for vertical flows
- Use `flowchart LR` only when the user explicitly requests horizontal layout
- Inside subgraphs, set `direction TB` to enforce vertical stacking
- Use `-->` for directional flow arrows
- Use `-->|"label"|` for labeled edges
- Use `~~~` (invisible link) to enforce ordering without visible lines
- Use `--- ` (line, no arrow) only when items are peers, not sequential

#### Subgraphs
- Use `subgraph id ["Display Title"]` with quoted titles
- Nest subgraphs for logical grouping (e.g., phases inside a pipeline)
- Keep nesting to a maximum of 3 levels deep (Lucidchart limitation)

#### Styling
- Include a `classDef` section at the bottom for color-coded node categories
- Use distinct fill colors for different node types (e.g., entry points, processing, decisions, storage)
- Use hex colors with good contrast: dark stroke + readable text
- Apply classes with `class nodeId className`

#### Lucidchart Compatibility — CRITICAL
- Do NOT use `%%{init: ...}%%` directives (Lucidchart ignores them)
- Do NOT use `click` or `callback` events
- Do NOT use `style` on individual nodes — use `classDef` + `class` instead
- Do NOT use HTML tags other than `<b>`, `<br/>`, `<i>`, `<code>` inside labels
- Do NOT use `:::` class shorthand on node declarations — apply classes separately at the bottom
- Keep node IDs short alphanumeric (no hyphens or special characters)
- Avoid `linkStyle` rules — Lucidchart drops them on import
- Maximum ~40 nodes per diagram for clean Lucidchart rendering; suggest splitting if larger

### Phase 3: Output

1. Output the Mermaid code inside a single fenced code block with ` ```mermaid ` language tag
2. After the code block, include a short **Lucidchart Import** section:
   ```
   **Lucidchart Import:**
   File → Import Data → Mermaid → paste the code above.
   ```
3. Note any elements that may need manual adjustment after import (e.g., subgraph label positions, color themes)

## Important Rules

- Always output `flowchart`, never `graph` (deprecated syntax)
- Preserve every node and edge from the source — do not summarize or omit elements
- If the source has more than 40 nodes, split into multiple diagrams and explain how they connect
- Do not invent nodes or flows that aren't in the source material
- When converting ASCII art, match the topology exactly — same branches, same nesting
- Use `direction TB` inside every subgraph to prevent horizontal drift
- Test mental model: every edge in the source should have a corresponding `-->` in the output
