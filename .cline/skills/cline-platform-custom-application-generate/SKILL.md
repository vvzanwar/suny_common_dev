---
name: cline-platform-custom-application-generate
description: "Use this skill when users need to create or configure tab-based Salesforce Custom Applications with navigation, branding, and action overrides. Trigger when users mention custom apps, application metadata, app navigation, or organizing tabs into applications. Use when users want to create app containers for tabs and pages. Do NOT use when the goal is hosting a React UI bundle in the App Launcher — use experience-ui-bundle-custom-app-generate for that case."
metadata:
  version: "1.0"
  domains: ["Platform"]
  minApiVersion: "60.0"
  relatedSkills:
    - "experience-ui-bundle-custom-app-generate"
---

# platform-custom-application-generate

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md`

---

## When to Use This Skill

Use this skill when you need to:
- Create Lightning applications
- Organize tabs and features into focused apps
- Configure application navigation and branding
- Set up custom page layouts for objects
- Troubleshoot deployment errors related to custom applications
# CustomApplication (Lightning App) Metadata Specification

## Overview

Custom applications (Lightning Apps) that group tabs and functionality to provide a focused user experience for specific business processes. Always configured for Lightning Experience.

## Purpose
- Organize related functionality into focused applications
- Group tabs and components for specific user roles
- Provide tailored user experiences
- Control access to specific features and data
- Use Standard navigation for general business applications or Console navigation for specialized service/support workflows requiring multi-tab workspaces
- Create professional, branded application identity with custom colors and branding
- Override standard actions with custom Lightning pages for enhanced user experience
- Enable profile-specific experiences through profile action overrides

## Application Configuration

### Navigation Type Selection (CRITICAL)
**Decision Criteria for navType:**

**Choose "Standard" (DEFAULT) for:**
- General business applications and most workflows
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Device Support

### Desktop Configuration
- **formFactor**: "Large"
- **tabs**: Full list of application tabs

### Phone Configuration
- **formFactor**: "Small"
- **tabs**: Mobile-optimized tab selection

### Tablet Configuration
- **formFactor**: "Medium"
- **tabs**: Tablet-appropriate tab selection

## User Experience Features

### Navigation Behavior
- **Auto Temporary Tabs**: Can be enabled/disabled
- **Personalization**: User customization options
- **Tab Persistence**: Remember user's tab selections

### Accessibility
- **Keyboard Navigation**: Full keyboard support
- **Screen Reader**: Compatible with assistive technologies
- **High Contrast**: Support for high contrast modes

## Integration Points
- **Custom Tabs**: Include custom object and web tabs
- **Standard Tabs**: Include standard Salesforce tabs
- **Lightning Pages**: Integrate with Lightning page layouts
- **Components**: Include custom Lightning components


*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
