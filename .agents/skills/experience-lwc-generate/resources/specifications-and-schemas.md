# experience-lwc-generate - Technical Specifications, Rules & Schemas

## Recommended Workflow

### 1. Choose the right architecture
Use the **PICKLES** mindset:
- prototype
- integrate the right data source
- compose component boundaries
- define interaction model
- use platform libraries
- optimize execution
- enforce security

### 2. Choose the right data access pattern
| Need | Default pattern |
|---|---|
| single-record UI | LDS / `getRecord` |
| simple CRUD form | base record form components |
| complex server query | Apex `@AuraEnabled(cacheable=true)` |
| related graph data | GraphQL wire adapter |
| cross-DOM communication | Lightning Message Service |

### 3. Start from an asset when useful
Use provided assets for:
- basic component bundles
- datatables
- modal patterns
- Flow screen components
- GraphQL components
- LMS message channels
- Jest tests
- TypeScript-enabled components

### 4. Validate for frontend quality
Check:
- accessibility
- SLDS 2 / dark mode compliance
- event contracts
- performance / rerender safety
- Jest coverage when required

### 5. Hand off supporting backend or deploy work
Use:
- [platform-apex-generate](../platform-apex-generate/SKILL.md) for controllers / services
- [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md) for deployment
- [platform-apex-test-run](../platform-apex-test-run/SKILL.md) only for Apex-side test loops, not Jest

---

---

## High-Signal Rules

- prefer platform base components over reinventing controls
- use `@wire` for reactive read-only use cases; imperative calls for explicit actions and DML paths
- do not introduce inaccessible custom UI
- avoid hardcoded colors; use SLDS 2-compatible styling hooks / variables
- avoid rerender loops in `renderedCallback()`
- keep component communication patterns explicit and minimal

---

---

## Reference File Index

### Start here
- [examples/component-patterns.md](examples/component-patterns.md) — component architecture patterns and bundle design
- [examples/slds-design-guide.md](examples/slds-design-guide.md) — SLDS 2 styling, dark mode, CSS hooks
- [examples/lwc-best-practices.md](examples/lwc-best-practices.md) — high-signal rules and anti-patterns
- [examples/scoring-and-testing.md](examples/scoring-and-testing.md) — 165-point scoring rubric across 8 categories
- [examples/jest-testing.md](examples/jest-testing.md) — Jest unit test patterns and async rendering helpers
- [examples/slds-blueprints.json](examples/slds-blueprints.json) — machine-readable SLDS component blueprints
- [examples/cli-commands.md](examples/cli-commands.md) — SF CLI commands for LWC development

### Accessibility / performance / state
- [examples/accessibility-guide.md](examples/accessibility-guide.md) — WCAG, ARIA, keyboard navigation patterns
- [examples/performance-guide.md](examples/performance-guide.md) — lazy loading, debouncing, rerender safety
- [examples/state-management.md](examples/state-management.md) — reactive state patterns and LMS
- [examples/template-anti-patterns.md](examples/template-anti-patterns.md) — common HTML template mistakes to avoid

### Integration / advanced features
- [examples/lms-guide.md](examples/lms-guide.md) — Lightning Message Service patterns
- [examples/flow-integration-guide.md](examples/flow-integration-guide.md) — Flow screen component design
- [examples/advanced-features.md](examples/advanced-features.md) — Spring '26 features: TypeScript, lwc:on, GraphQL mutations
- [examples/async-notification-patterns.md](examples/async-notification-patterns.md) — toast, notifications, async flows
- [examples/triangle-pattern.md](examples/triangle-pattern.md) — parent-child-sibling communication triangle

### Asset templates
- [resources/basic-component/basicComponent.js](resources/basic-component/basicComponent.js) — wire service, error/loading states, event dispatching
- [resources/datatable-component/datatableComponent.js](resources/datatable-component/datatableComponent.js) — datatable with inline editing
- [resources/flow-screen-component/flowScreenComponent.js](resources/flow-screen-component/flowScreenComponent.js) — Flow screen with input/output properties
- [resources/form-component/formComponent.js](resources/form-component/formComponent.js) — form validation and DML patterns
- [resources/graphql-component/graphqlComponent.js](resources/graphql-component/graphqlComponent.js) — GraphQL wire adapter with cursor-based pagination
- [resources/jest-test/componentName.test.js.example](resources/jest-test/componentName.test.js.example) — Jest test template (copy and rename, remove `.example` suffix)
- [resources/message-channel/lmsPublisher.js](resources/message-channel/lmsPublisher.js) — LMS publisher pattern
- [resources/message-channel/lmsSubscriber.js](resources/message-channel/lmsSubscriber.js) — LMS subscriber pattern
- [resources/modal-component/modalComponent.js](resources/modal-component/modalComponent.js) — modal with focus trap and ESC handling
- [resources/record-picker/recordPicker.js](resources/record-picker/recordPicker.js) — record picker with search
- [resources/state-store/store.js](resources/state-store/store.js) — reactive state store for cross-component state
- [resources/typescript-component/typescriptComponent.ts](resources/typescript-component/typescriptComponent.ts) — TypeScript-enabled component (Spring '26)
- [resources/workspace-api/workspaceComponent.js](resources/workspace-api/workspaceComponent.js) — workspace API for tab and focus management
- [resources/apex-controller/LwcController.cls](resources/apex-controller/LwcController.cls) — Apex controller with `@AuraEnabled(cacheable=true)` patterns

### Scripts
- [scripts/local-dev-preview.sh](scripts/local-dev-preview.sh) — local dev server commands for component, app, and site preview

---
