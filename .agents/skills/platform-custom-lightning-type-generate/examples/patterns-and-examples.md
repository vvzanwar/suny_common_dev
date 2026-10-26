# platform-custom-lightning-type-generate - Reference Examples, Patterns & Troubleshooting

## Common Deployment Errors
| Error / Symptom | Likely Cause | Fix |
|---|---|---|
| Schema validation fails due to unknown keyword | `unevaluatedProperties: false` + disallowed keyword (commonly `examples`, `items`) | Remove the offending keyword; keep schema minimal |
| Nested object validation failure | Org/channel validation rejects nested object typing in `LightningTypeBundle` | Use CLT reference (`c__<CLTName>`) or Apex class types |
| Invalid CLT reference | Referenced CLT doesn't exist in org or incorrect syntax | Deploy the referenced CLT first; `c__<CLTName>` must match the referenced type’s **`lightning:type` value / FQN / registered identifier**, not `title` |
| Invalid or misspelled `lightning:type` (for example, `lightning__richtextType` instead of `lightning__richTextType`) | Incorrect generated type name | Cross-check all `lightning:type` values against supported type names and correct them before deployment |
| Array property rejected | Use of `items` (or `lightning:type` in nested arrays) rejected by validator | For nested arrays: keep only `type: "array"`. For root arrays: use minimal structure; remove `items` if rejected |
| Apex-based CLT rejected | Extra fields added (e.g., `type`, `properties`) | Use only `title`, optional `description`, and `lightning:type` |
| Editor config rejected | Use of invalid patterns (`es_property_editors/inputList`, `itemSchema`) or unrecognized top-level keys | Use `editor.componentOverrides` and `editor.layout`; keep config minimal |
| `additionalProperties` error on layout attributes | Adding `label` or other attributes to `lightning/propertyLayout` | Only use `property` attribute in `lightning/propertyLayout`. Remove `label`, `title`, or any other attributes |
| Invalid target configuration for custom LWC | Custom LWC component's `-meta.xml` missing required target (`lightning__AgentforceInput` or `lightning__AgentforceOutput`) | Add correct target to LWC's `-meta.xml`: use `lightning__AgentforceInput` for editors, `lightning__AgentforceOutput` for renderers |
| Attribute mapping doesn't exist in type schema | Using `{!$attrs.propertyName}` where `propertyName` is not defined in schema | Ensure all attribute mappings reference actual properties in your type schema's `properties` section |
| `unevaluatedProperties` error on custom LWC renderer for an Apex class CLT | Root override `attributes` mapping used on an Apex class CLT, which has no `properties` block to validate against | Remove `attributes` entirely from the root override; use `"componentOverrides": { "$": { "definition": "c/<component>" } }` only |
| `additionalProperties` error with deprecated keys | Using `propertyRenderers` or `view` in editor/renderer config | Replace deprecated `propertyRenderers` with `componentOverrides` and `view` with `layout` |
| Type mismatch in component attributes | Passing wrong type for component attribute (e.g., integer instead of string) | Ensure attribute values match the expected type defined by the component |
