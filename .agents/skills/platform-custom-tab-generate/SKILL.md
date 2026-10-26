---
name: platform-custom-tab-generate
description: "Use this skill when users need to create or configure Salesforce Custom Tabs. Trigger when users mention tabs, navigation tabs, object tabs, web tabs, Visualforce tabs, Lightning component tabs, app page tabs, or tab configuration. Also use when users want to add navigation to custom objects, create tabs for external content, or set up Lightning page tabs. Always use this skill for any custom tab work."
metadata:
  version: "1.0"
  domains: ["Platform"]
  minApiVersion: "60.0"
---

# platform-custom-tab-generate

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
- Create tabs for objects, web pages, or Visualforce pages
- Add navigation tabs to applications
- Configure tab visibility and access
- Troubleshoot deployment errors related to custom tabs

## Overview
Custom tabs for navigating to objects, web content, or Visualforce pages within Salesforce applications.

## Purpose
- Provide navigation to custom objects
- Link to external web content
- Access Visualforce pages
- Organize application navigation

## Supported Applications
- **Standard Apps**: Available in standard Salesforce applications
- **Custom Apps**: Can be included in custom applications
- **Community Apps**: Available in community applications

## Integration Points
- **Object Relationships**: Links to related object records
- **Web Content**: External website integration
- **Visualforce Pages**: Custom page functionality
- **Lightning Components**: Modern component integration

## Best Practices
- Use clear, descriptive tab labels
- Choose appropriate tab types for functionality
- **Select a unique, contextually relevant motif for each tab** — do not default every tab to the same icon
- Consider user experience and navigation flow
- Test tab functionality across different applications
- Ensure proper permissions and visibility settings
- Follow consistent naming conventions
- Object tab files MUST only contain `<customObject>true</customObject>` and `<motif>` — nothing else
- Web tab files MUST only contain: `<customObject>false</customObject>`, `<label>`, `<motif>`, `<url>`, `<urlEncodingKey>`, and optionally `<description>`, `<frameHeight>` — nothing else
- Never include `<isHidden>`, `<tabVisibility>`, `<type>`, `<mobileReady>`, or empty elements
