---
name: experience-ui-bundle-file-upload-generate
description: "MUST activate when the project contains a uiBundles/*/src/ directory and the task involves uploading, attaching, or dropping files. Use this skill when adding file upload functionality to a UI bundle app. Provides progress tracking and Salesforce ContentVersion integration. This feature provides programmatic APIs ONLY — build custom UI using the upload() API. ALWAYS use this instead of building file upload from scratch with FormData or XHR."
metadata:
  version: "1.0"
  domains: ["Experience"]
  relatedSkills:
    - "experience-ui-bundle-salesforce-data-access"
  cliTools:
    - tool: ["npm"]
      semver: ">=7.0.0"
---

# File Upload API (workflow)

When the user wants file upload functionality in a React UI bundle, follow this workflow. This feature provides **APIs only** — you must build the UI components yourself using the provided APIs.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md`

---

## CRITICAL: This is an API-only package

The package exports **programmatic APIs**, not React components or hooks. You will:

- Use the `upload()` function to handle file uploads with progress tracking
- Build your own custom UI (file input, dropzone, progress bars, etc.)
- Track upload progress through the `onProgress` callback

**Do NOT:**

- Expect pre-built components like `<FileUpload />` — they are not exported
- Try to import React hooks like `useFileUpload` — they are not exported
- Look for dropzone components — they are not exported

The source code contains reference components for demonstration, but they are **not available** as imports. Use them as examples to build your own UI.

## 1. Install the package

```bash
npm install @salesforce/ui-bundle-template-feature-react-file-upload
```

Dependencies are automatically installed:

- `@salesforce/ui-bundle` (API client)
- `@salesforce/platform-sdk` (data SDK; the old `@salesforce/sdk-data` name is dead — see the `experience-ui-bundle-salesforce-data-access` skill)

## 2. Understand the three upload patterns

### Pattern A: Basic upload (no record linking)

Upload files to Salesforce and get back `contentBodyId` for each file. No ContentVersion record is created.

**When to use:**
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## 3. Build your custom UI

The package provides the backend — you build the frontend. Here's a minimal example:

```tsx
import {
  upload,
  type FileUploadProgress,
} from "@salesforce/ui-bundle-template-feature-react-file-upload";
import { useState } from "react";

function CustomFileUpload({ recordId }: { recordId?: string }) {
  const [progress, setProgress] = useState<Map<string, FileUploadProgress>>(new Map());

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(event.target.files || []);

    await upload({
      files,
      recordId,
      onProgress: (fileProgress) => {
        setProgress((prev) => new Map(prev).set(fileProgress.fileName, fileProgress));
      },
    });
  };

  return (
    <div>
      <input type="file" multiple onChange={handleFileSelect} />

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
