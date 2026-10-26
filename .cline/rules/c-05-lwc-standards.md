---
trigger: always_on
description: NCSIM Lightning Web Component (LWC) Structure, Data Access, UI States, SLDS Styling, and Accessibility Standards
---

# NCSIM Standard 05: Lightning Web Component (LWC) Standards

## 1. Component Structure & Size
- **Folder & Naming**: One `camelCase` folder per component (`enrollmentCard` -> `enrollmentCard.html`, `enrollmentCard.js`, `enrollmentCard.js-meta.xml`).
- **300-Line Split Rule**: Keep each component focused on one job. If a `.js` file exceeds ~300 lines, split it into:
  - One **Container Component** (fetches data from Apex / LDS), and
  - One or more **Presentation Components** (accept `@api` properties and emit `CustomEvent` events).

## 2. Data Access & Apex Calls
- **Standard LDS First**: Prefer `lightning/uiRecordApi` wire adapters (`getRecord`, `getRelatedListRecords`, `createRecord`, `updateRecord`) before writing custom Apex.
- **Reads (`@wire`)**: Use `@wire` on `@AuraEnabled(cacheable=true)` Controller methods for reactive reads.
- **Writes (Imperative `async/await`)**: Use imperative Apex calls with `async/await`, `try / catch / finally` toggling `this.isLoading`, `ShowToastEvent`, and `refreshApex(this.wiredResult)`.
- **Strict Prohibitions**:
  - Never pass SOQL strings or field lists from JS to Apex.
  - Never access `window` or `document.querySelector` outside `this.template`.
  - Never mutate an `@api` property inside a child component; dispatch a `CustomEvent` with a lowercase event name (`new CustomEvent('confirm', { detail: { enrollmentId: this.recordId } })`).

## 3. Mandatory UI States, SLDS Styling & Accessibility
- **3 Mandatory UI States**: Every component that loads data must explicitly render:
  1. **Loading state**: `<lightning-spinner alternative-text="Loading"></lightning-spinner>`
  2. **Error state**: `<p class="slds-text-color_error" role="alert">{errorMessage}</p>`
  3. **Empty state**: Clear user message when no records match
- **SLDS Only**: Use SLDS utility classes and styling hooks (`var(--lwc-spacingMedium)`). Zero hardcoded hex colours (`#336699`) or pixel widths (`width: 347px`).
- **Accessibility**: Every input has a visible label (`label` attribute or `<label>`), every icon-only button has `alternative-text`, focus stays visible, and every interactive flow works with keyboard-only navigation (`Tab`, `Enter`, `Escape`).
- **Jest Tests (`__tests__/<component>.test.js`)**: Cover data rendering, empty state, and error state.
