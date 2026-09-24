---
name: show-me
description: Explain software visually with concise diagrams, code-shape sketches, diffs, or focused HTML artifacts. Use only when the user explicitly asks for a visual explanation—such as to visualize, diagram, map, or sketch code structure, control flow, data flow, architecture, state, an algorithm, or UI composition—or invokes this skill by name.
---

# Show Me

Help the user understand the current software topic visually. Skip the preamble and keep prose brief. Pick the smallest visual form that makes the key point clear.

## Ground the Visual

Base repository diagrams on inspected code. Do not invent files, calls, components, states, or runtime behavior.

Distinguish structure that is verified, inferred, conceptual, simplified, or proposed. Treat a runtime sequence as observed only when traces, logs, or equivalent evidence establish it; otherwise label it as inferred. Mark future-state visuals as proposed.

## Choose the Form

- **Algorithm or compact logic:** pseudocode.
- **Nested calls:** an indented call tree.
- **UI ownership:** a component tree with only relevant state and module boundaries.
- **Repository responsibility:** a shallow file tree.
- **Interactions over time:** a Mermaid sequence diagram.
- **Branching, state, or data flow:** a Mermaid flowchart or state diagram.
- **Change to an existing shape:** a `diff` matching that shape.
- **Mostly new, copyable structure:** the complete code or text block.
- **Dense spatial, interactive, or visual comparison:** focused HTML, only when text diagrams or Mermaid cannot communicate the important relationship.

Use several forms only when each answers a different part of the user's question. Prefer one primary visual.

## Keep It Focused

- Include only the calls, files, props, states, and boundaries needed for the current explanation.
- Keep trees shallow unless depth is the point.
- Use real repository names when explaining existing code.
- Omit irrelevant helpers, framework internals, and unchanged branches.
- Put each visual next to the short text it supports.
- Keep a brief textual conclusion beside every visual.
- Do not decorate technical diagrams merely to make them look impressive.
- Do not present multiple visual directions unless the user requests them.

## Mermaid

Choose the diagram type that matches the relationship rather than forcing everything into a flowchart. Validate Mermaid syntax before relying on the rendered result. Quote labels containing punctuation when needed.

For a meaningful diagram, provide an accessible title and description when the renderer supports them. Keep the accompanying text sufficient to understand the conclusion if rendering fails.

## Focused HTML

Prefer the host's native visualization mechanism when it can express the idea. Do not create HTML merely because the topic concerns a UI.

If an HTML file is necessary:

- create one focused diagram, infographic, comparison, or short slide sequence;
- match an existing product's visual language when relevant;
- use real labels and representative data;
- support desktop and mobile when layout matters;
- use a valid workspace or user-specified location, report its path, and avoid leaving unnecessary artifacts behind;
- open or present it using the host's supported mechanism rather than assuming a shell command or platform.

When the user explicitly wants an interactive browser artifact and the native host view is insufficient, read the [interactive visual companion](../brainstorming/visual-companion.md). This companion is optional and does not create a written-design or implementation approval gate.
