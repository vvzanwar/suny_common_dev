---
name: cline-education-cloud-course-catalog-migrate
description: "Use this skill to migrate course catalog data from external sources (CSV, PDF, website) and bulk-create Learning and LearningCourse records in Education Cloud. Triggers when a user wants to import courses, parse course catalog documents, or set up a course catalog for an academic term. Handles multi-source data ingestion, intelligent interpretation of course structures (lecture+lab linked courses via IsLinkedOnly flag, credit hours, course types), batch creation via sObject REST API, data quality validation, conflict resolution for existing courses, and gap identification. Explains what's missing (descriptions, types) and requests additional sources. Pauses for clarification on multi-component courses and conflicting data. DO NOT TRIGGER for creating individual Learning Course records manually, for creating Learning Programs (different workflow), or for enrollment/registration workflows."
metadata:
  version: "1.0"
  domains:
    - "Education"
  accessCheck: "IndustriesEducation.userHasEducationCloudAccess"
  cliTools:
    - tool: ["python3"]
      semver: ">=3.9.0"
---

# Migrating Course Catalog to Education Cloud

Import course catalog data from multiple sources (CSV, PDF, website) and bulk-create Learning Course records with structure detection and data quality validation.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `gotchas-detail.md, gotchas.md, large-catalog-handling.md, patterns-and-examples.md`

---

## Scope

- **In scope**: Multi-source ingestion (CSV, PDF, web), Learning + LearningCourse bulk creation via sObject REST API (Composite batches up to 200), linked course detection (lecture+lab via IsLinkedOnly), credit hour parsing (Duration/DurationUnit), course type mapping, data quality validation, conflict resolution, gap identification/remediation
- **Out of scope**: Creating individual Learning Course records manually (delegate to metadata generation skills), creating Learning Programs (Learning.Type = 'LearningProgram' + separate child object), creating External Learning (Learning.Type = 'ExternalLearning'), course sections/offerings (CourseOffering object), enrollment/registration workflows (no dedicated skill yet — ask the user), SIS sync (separate integration workflow)

---

## Required Inputs

Gather or infer before proceeding:

- **Target org**: Active Salesforce org with Education Cloud enabled
- **Primary data source**: CSV file, PDF document, or website URL with course catalog data
- **Business Account**: the Academic Operations Business Account to link courses to (e.g., College of Engineering)
- **Academic term** (optional): context only, not stored on Learning Course

Additional sources (gathered during workflow):
- Supplementary data sources for missing fields (descriptions, types, mappings)
- Lecture-lab mapping files (if multi-component courses detected)
- Conflict resolution decisions (if existing courses found)

Defaults unless specified:
- Course status: Active (IsActive = true on Learning)
- Batch size: 25 records per Composite API call as an agent (API supports 200; tool-call payload limits are the binding constraint — see Step 7)
- Data quality validation: Enabled
- Learning.Type: 'LearningCourse' (required for course catalog entries)

---

## Workflow

All steps are sequential. Do not skip or reorder. If blocked, stop and ask for missing context.

### Phase 1 — Ingest Primary Source

1. **Identify data source type** — determine if primary source is CSV, PDF, or website URL. Ask user to provide the source if not already specified.
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Output Expectations

Deliverables:
- X Learning records created (Type = 'LearningCourse')
- X LearningCourse child records created (LearningId lookups)
- Data quality report showing completeness per field
- Import summary listing all data sources used
- Optional: course verification via direct record reads or SOQL `/query` (both routable via headless-360)

No files are produced — all output is org records created via sObject REST API.

---

## Cross-Skill Integration

| Need | Delegate to |
|------|-------------|
| Create individual Learning Course manually | Platform metadata generation skills |
| Create Learning Programs | No dedicated skill yet — ask the user |
| Set up course sections/offerings | No dedicated skill yet — ask the user |
| Configure enrollment eligibility rules | No dedicated skill yet — ask the user |

---
