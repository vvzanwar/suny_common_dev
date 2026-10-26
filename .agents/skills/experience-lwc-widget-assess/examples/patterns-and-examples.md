# experience-lwc-widget-assess - Reference Examples, Patterns & Troubleshooting

## Reference Code & Command Examples

### Example 1
```json
{
  "component": "caseDetailsPanel",
  "role": "renderer",
  "asIsVerdict": "port-declarative",
  "contractChange": {"suggested": false, "shapeToAdd": []},
  "asDisplayWidget": {"verdict": "viable", "rendersAsWidget": true, "stillServesPurpose": true, "isRebuild": false},
  "needsHumanReview": false
}
```

### Example 2
```markdown
# <component>: <one-line conclusion>

**Verdict:** <asIsVerdict> → <asDisplayWidget.verdict> (rebuild or not) · **Confidence:** high | low · **Needs human review:** yes | no

## Why
The user's goal, what maps cleanly, and what decides the verdict.

## Blockers
Each material blocker: gate, signal, evidence. "None" for `port-declarative`.

## Suggested contract change
Each field to add and why it must move into the action output. Omit when none is suggested.

## What the widget keeps / drops
Kept actions and dropped or replaced interactions.

## Open questions
What would resolve any low-confidence conclusion.
```
