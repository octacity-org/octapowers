---
name: brainstorming
description: Explore software ideas, requirements, alternatives, architecture, or design decisions when the user explicitly asks to brainstorm, think something through, explore options, or create a written design/spec. Conversational exploration creates no artifact or approval gate; written design does so only when explicitly requested.
---

# Brainstorming

Help the user clarify an idea and make decisions at the level of formality they requested.

## Select the Mode

Use this skill only when the user explicitly asks to brainstorm, explore alternatives, think through an idea, discuss architecture or design, create a design/spec, or invokes this skill by name. Do not trigger merely because implementation is ambitious, creative, architectural, or multi-step.

- **Exploratory brainstorming:** Use when the user wants discussion, ideation, alternatives, or help deciding. Keep it conversational. Do not create a document or approval gate.
- **Written design:** Use only when the user explicitly requests a spec, design document, design-first workflow, or another persistent design artifact.

If the request says only “brainstorm,” use exploratory brainstorming. Do not silently upgrade it to a written design workflow.

## Shared Approach

1. Inspect relevant project context when the discussion concerns an existing project.
2. Identify the decisions that materially affect the outcome.
3. Ask focused questions only when answers cannot be inferred safely. Batch related questions when useful.
4. Present alternatives only when they have meaningful tradeoffs.
5. Make a recommendation when the evidence supports one.
6. Keep the depth proportional to the user's question.

## Exploratory Brainstorming

Discuss the idea directly in the conversation. Use short options, tradeoffs, sketches, examples, or a recommendation as appropriate.

Do not save a design document, request formal approval, or force a transition into planning. At the end:

- stop if the user requested exploration only;
- continue implementing if the user already authorized implementation after brainstorming;
- offer the relevant conclusion and wait for direction when the next action is genuinely unspecified.

## Written Design

Create a decision-focused design scaled to the task. Cover architecture, boundaries, data flow, failure behavior, and verification only where relevant.

1. Check the design for ambiguity, contradictions, placeholders, and unnecessary scope.
2. Save it to `docs/octapowers/specs/YYYY-MM-DD-<topic>-design.md`, unless the user specifies another location.
3. Ask the user to approve or revise the written design.

Do not begin implementation before approval. This approval gate applies only because the user explicitly requested a persistent written design workflow.

After approval:

- invoke `writing-plans` if the user also requested a written implementation plan;
- implement directly with an internal plan if the user already authorized implementation and did not request a written plan;
- stop if the user requested only the design.

Do not commit the design unless the user requests a commit or the surrounding workflow explicitly includes commits.

## Visual Explanation

In either mode, when the user explicitly asks to see or visualize a UI layout, architecture, flow, spatial relationship, or comparison, invoke `show-me`. Keep textual requirements, tradeoffs, and ordinary clarification in the conversation.

Visual explanation supports brainstorming; it does not create a written-design or approval requirement.
