# experience-lwc-widget-migrate - Technical Specifications, Rules & Schemas

## 4. Check the result

Use the generator's bundle self-validation. Then compare the result to the assessed candidate: every retained visible field has a binding to the real/proposed payload; list item paths and supported actions match; omitted behavior and contract changes are stated; and, for a renderer migration, the Lightning Type points to this widget with matching attributes. Static checks establish structure and mapping, not deployed runtime behavior. Report assessment, created paths, validation results, and one of: `migrated and wired`, `bundle only`, `draft pending IA contract`, or `stopped`, with the reason.
