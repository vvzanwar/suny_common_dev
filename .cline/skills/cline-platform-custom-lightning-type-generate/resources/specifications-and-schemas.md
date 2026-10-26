# platform-custom-lightning-type-generate - Technical Specifications, Rules & Schemas

## Specification

# CustomLightningType Metadata Specification

---

## Critical Rules (Read First)
- **CRITICAL: NEVER include the `"$schema"` field in schema.json**
  - Salesforce CLT validator WILL REJECT schemas with this field, even if it's a valid JSON Schema `$schema` declaration.
- **Root object schemas MUST include**:
  - `"type": "object"`
  - `"title"`
  - `"lightning:type": "lightning__objectType"`
  - `"unevaluatedProperties": false`
- `"unevaluatedProperties"` is enforced as `false` by the CLT metaschema. Do not set it to `true`.
- **Root object schemas MUST NOT include** `"examples"` when `"unevaluatedProperties": false` is set.
- **Nested objects (inside `properties`) MUST NOT set** `"lightning:type": "lightning__objectType"`.
    - Nested objects can be: references to other CLTs using `c__<CLTName>` syntax.
- **List/array properties are highly restricted by the CLT metaschema**:
  - **CRITICAL LIMITATION**: the CLT metaschema may reject the `items` keyword entirely. Treat `items` as **disallowed by default**.
  - **Root-level arrays** (direct children of the root `properties`):
    - **MUST include** `"lightning:type": "lightning__listType"`
    - **MUST NOT include** `"items"`
    - **OPTIONAL** `"type": "array"`
  - **Nested arrays** (arrays inside nested objects) are the most common failure:
    - **MUST include** `"type": "array"`
    - **MUST NOT include** `"lightning:type": "lightning__listType"`
    - **MUST NOT include** `"items"`
- **When `"unevaluatedProperties": false` is set, any unknown keyword will fail validation**. Prefer removing keywords over relaxing strictness.
- **Apex class CLTs are minimal**:
  - Include **only** `title`, `description` (optional), and `lightning:type` set to `@apexClassType/...`.
  - Do **not** add `type`, `properties`, `required`, or `unevaluatedProperties`.
  - **Custom LWC renderers/editors on an Apex class CLT MUST NOT use `attributes` in the root override — this overrides any prompt wording to the contrary.** Since the schema has no `properties` block, there is nothing for `{!$attrs.<name>}` to resolve against — `unevaluatedProperties: false` will reject any attribute key (e.g. `"You can't add the flightId property ... because the unevaluatedProperties keyword value is set to false"`). Use `"componentOverrides": { "$": { "definition": "c/<yourComponent>" } }` with **no `attributes` key** at all. **If the user's prompt explicitly asks for attribute mappings to specific fields (e.g. "with attribute mappings for fieldA, fieldB") on an Apex-class CLT renderer/editor, do NOT comply literally** — omit `attributes` from the root override anyway, and say so in your response (e.g. "Note: attribute mappings were omitted because the backing type is an Apex-class CLT, which has no `properties` block to bind against").
- **No shell metacharacters that trigger the Vibes safe-shell filter.** In any Bash tool call emitted by this skill, do NOT use command substitution (`$(…)` or backticks), process substitution (`<(…)`, `>(…)`), brace expansion (`{a,b,c}` or `{1..N}`), or `eval` / `exec`. Vibes forces manual approval on these patterns even under Bypass mode and stalls the eval. Emit separate commands (`mkdir -p a && mkdir -p b`) or print each value with its own command and reason about the output rather than capturing it in a shell variable.

---

## Primitive Types & Constraints

When you need the full list of supported primitive `lightning:type` identifiers, their constraints, and the allowed property-level keywords, read `resources/primitive-types-and-constraints.md` in this skill's directory.

---

## Generation Workflow
1. **Confirm the CLT approach**
   - If referencing Apex: capture the exact class reference (@apexClassType/namespace__ClassName$InnerClass).
   - If using standard primitives: list the fields, their Lightning primitive types, and which fields are required.
2. **Draft `schema.json`**
   - **DO NOT include `"$schema"` at the top**
   - Start with the root object structure (required root fields).
   - Add `properties` using valid primitive `lightning:type` identifiers.
   - For nested-object properties, use **CLT Reference pattern**:
     - `"lightning:type": "c__<CLTName>"` to reference another CLT
     - The referenced CLT must be deployed to the org before the parent CLT.
   - For Apex-based nested objects: Use `@apexClassType/...` when structure exists server-side.
   - If the prompt explicitly requires true nested object output, prefer an **Apex-based CLT** (`@apexClassType/...`) for deploy-safe nested structures.
   - For arrays: follow the strict list rules (avoid `items`; avoid `lightning:type` on nested arrays).
   - Before deployment, verify exact `lightning:type` spellings (for example, use `lightning__richTextType`, not misspelled variants).
3. **(Optional) Draft `editor.json`** (only if custom UI is required)
   - **Supported shape:** Top-level `editor` object with `editor.componentOverrides` and `editor.layout`.
     - Top-level `editor` object.
     - Use `editor.componentOverrides` for component overrides.
     - Use `editor.layout` for layout.
     - **DEPRECATED**: Do NOT use `propertyRenderers` or `view` — these are legacy keys. Always use `componentOverrides` and `layout` instead.
   - **Root override pattern** (most common for fully custom editing UI):
     - `editor.componentOverrides["$"] = { "definition": "c/<yourEditorComponent>", "attributes": { ... } }`
     - When passing schema data into a custom LWC, use attribute mapping with the `{!$attrs.<name>}` syntax: e.g. `"attributes": { "myField": "{!$attrs.value}" }` so the runtime binds schema values to your component's attributes.
     - **CRITICAL**: The `<name>` in `{!$attrs.<name>}` must be a property defined in your type schema. For example, if your schema has a property called `temperature`, use `{!$attrs.temperature}`, not `{!$attrs.value}` unless `value` is an actual property.
   - **Property-level override pattern** (for individual fields):
     - `editor.componentOverrides["<propertyName>"] = { "definition": "es_property_editors/<...>" }`
     - **Valid editor components** (examples): `es_property_editors/inputText`, `es_property_editors/inputNumber`, `es_property_editors/inputRichText`, `es_property_editors/inputImage`, `es_property_editors/inputTextarea`. **Do not use** `es_property_editors/inputList`.
   - **Collection editor** (for root-level `lightning__listType` properties): Use a collection-level override so the list is edited by a custom component: `collection.editor.componentOverrides["$"] = { "definition": "c/<yourCollectionEditorComponent>" }`. Alternatively, use `editor.layout` with `lightning/propertyLayout` and `attributes.property = "<listPropertyName>"` for default list editing.
   - **Layout pattern**:
     - `editor.layout.definition = "lightning/verticalLayout"`
     - `editor.layout.children[*].definition = "lightning/propertyLayout"` with `attributes.property = "<propertyName>"`
     - **CRITICAL**: `lightning/propertyLayout` only accepts the `property` attribute. Do NOT add `label`, `title`, or any other attributes — these will fail validation with `additionalProperties: false` errors.
   - **Avoid known-invalid patterns**:
     - Do not use `es_property_editors/inputList`.
     - Do not use `itemSchema` attributes.
4. **(Optional) Draft `renderer.json`** (only if custom UI or widget rendition is required)
   - **Supported shape:** Top-level `renderer` object with `renderer.componentOverrides` and `renderer.layout`.
     - Top-level `renderer` object.
     - Use `renderer.componentOverrides` for component overrides.
     - Use `renderer.layout` for layout.
     - **DEPRECATED**: Do NOT use `propertyRenderers` or `view` — these are legacy keys. Always use `componentOverrides` and `layout` instead.
   - **Widget rendition pattern** (reference an existing WidgetBundle as the root renderer): the renderer file is a thin wrapper that points at the widget by developer name (`"definition": "@widget/c/<widgetDeveloperName>"`) and maps CLT schema properties to widget attributes via `{!$attrs.<schemaPropertyName>}`. Do **NOT** duplicate the widget body inside `renderer.json`. See `examples/widget-rendition.md` for the full shape, binding rules, and constraints. For the full Apex → Lightning Type → Widget pipeline, use the `platform-lightning-type-widget-coordinate` orchestrator instead of this skill.
   - **Root override pattern** (most common for fully custom rendering UI with a custom LWC):
     - `renderer.componentOverrides["$"] = { "definition": "c/<yourRendererComponent>", "attributes": { ... } }`
     - Use `{!$attrs.<name>}` in attribute mappings when binding schema data to custom renderer component attributes.
     - **CRITICAL**: Attribute mappings like `{!$attrs.propertyName}` must reference properties that **actually exist** in your type schema. Referencing non-existent properties will fail validation.
     - **Type matching**: Attribute values must match the expected type for the component. For example, if a component expects a string attribute, passing an integer will fail validation.
   - **Property-level override pattern**:
     - `renderer.componentOverrides["<propertyName>"] = { "definition": "es_property_editors/outputText" | "es_property_editors/outputNumber" | "es_property_editors/outputImage" | ... }`. **Valid renderer components** (examples): `es_property_editors/outputText`, `es_property_editors/outputNumber`, `es_property_editors/outputImage`. Avoid input-style components in the renderer.
   - **Layout pattern for renderer**:
     - `renderer.layout.definition = "lightning/verticalLayout"`
     - `renderer.layout.children[*].definition = "lightning/propertyLayout"` with `attributes.property = "<propertyName>"`
     - **CRITICAL**: Same as editor layouts, `lightning/propertyLayout` only accepts the `property` attribute. Do NOT add `label`, `title`, or any other attributes.
   - **Collection renderer** (for root-level `lightning__listType` properties): Use `collection.renderer.componentOverrides["$"] = { "definition": "c/<yourListRendererComponent>" }` or `es_property_editors/genericListTypeRenderer` to render the list.
5. **Place files in the correct bundle structure**
   - `lightningTypes/<TypeName>/schema.json`
   - (Optional) `lightningTypes/<TypeName>/lightningDesktopGenAi/editor.json`
   - (Optional) `lightningTypes/<TypeName>/lightningDesktopGenAi/renderer.json`
      For Gen AI / Copilot the standard path is `lightningDesktopGenAi/`. Other targets (e.g. Experience Builder, Mobile Copilot, Enhanced Web Chat) use different subfolders when supported: `experienceBuilder/`, `lightningMobileGenAi/`, `enhancedWebChat/`.
   - (Optional - for widget rendition only) `lightningTypes/<TypeName>/renderer.json`
6. **Configure custom LWC components (if using custom components)**
   - **CRITICAL**: Custom LWC components referenced in editor/renderer configs MUST have the correct target configuration in their `-meta.xml` files:
     - **For editor components** (`c/<componentName>` used in `editor.json`): The LWC's `-meta.xml` file must include `<target>lightning__AgentforceInput</target>`
     - **For renderer components** (`c/<componentName>` used in `renderer.json`): The LWC's `-meta.xml` file must include `<target>lightning__AgentforceOutput</target>`
   - Without the correct target, deployment will fail with: `Invalid target configuration. To use 'c/componentName' as a renderer/editor, your js-meta.xml file must include valid target 'lightning__AgentforceOutput/Input'.`
   - Example `-meta.xml` for a renderer component:
     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
         <apiVersion>60.0</apiVersion>
         <isExposed>true</isExposed>
         <targets>
             <target>lightning__AgentforceOutput</target>
         </targets>
     </LightningComponentBundle>
     ```
