# experience-ui-bundle-file-upload-generate - Technical Specifications, Rules & Schemas

## 2. Understand the three upload patterns

### Pattern A: Basic upload (no record linking)

Upload files to Salesforce and get back `contentBodyId` for each file. No ContentVersion record is created.

**When to use:**

- User wants to upload files first, then create/link them to a record later
- Building a multi-step form where the record doesn't exist yet
- Deferred record linking scenarios

```tsx
import { upload } from "@salesforce/ui-bundle-template-feature-react-file-upload";

const results = await upload({
  files: [file1, file2],
  onProgress: (progress) => {
    console.log(`${progress.fileName}: ${progress.status} - ${progress.progress}%`);
  },
});

// results[0].contentBodyId: "069..." (always available)
// results[0].contentVersionId: undefined (no record linked)
```

### Pattern B: Upload with immediate record linking

Upload files and immediately link them to an existing Salesforce record by creating ContentVersion records.

**When to use:**

- Record already exists (Account, Opportunity, Case, etc.)
- User wants files immediately attached to the record
- Direct upload-and-attach scenarios

```tsx
import { upload } from "@salesforce/ui-bundle-template-feature-react-file-upload";

const results = await upload({
  files: [file1, file2],
  recordId: "001xx000000yyyy", // Existing record ID
  onProgress: (progress) => {
    console.log(`${progress.fileName}: ${progress.status} - ${progress.progress}%`);
  },
});

// results[0].contentBodyId: "069..." (always available)
// results[0].contentVersionId: "068..." (linked to record)
```

### Pattern C: Deferred record linking (record creation flow)

Upload files without a record, then link them after the record is created.

**When to use:**

- Building a "create record with attachments" form
- Record doesn't exist until form submission
- Need to upload files before knowing the final record ID

```tsx
import {
  upload,
  createContentVersion,
} from "@salesforce/ui-bundle-template-feature-react-file-upload";

// Step 1: Upload files (no recordId)
const uploadResults = await upload({
  files: [file1, file2],
  onProgress: (progress) => console.log(progress),
});

// Step 2: Create the record
const newRecordId = await createRecord(formData);

// Step 3: Link uploaded files to the new record
for (const file of uploadResults) {
  const contentVersionId = await createContentVersion(
    new File([""], file.fileName),
    file.contentBodyId,
    newRecordId,
  );
}
```

---

## API Reference

### upload(options)

Main upload API that handles complete flow with progress tracking.

```typescript
interface UploadOptions {
  files: File[];
  recordId?: string | null; // If provided, creates ContentVersion
  onProgress?: (progress: FileUploadProgress) => void;
  signal?: AbortSignal; // Optional cancellation
}

interface FileUploadProgress {
  fileName: string;
  status: "pending" | "uploading" | "processing" | "success" | "error";
  progress: number; // 0-100 for uploading, 0 for other states
  error?: string;
}

interface FileUploadResult {
  fileName: string;
  size: number;
  contentBodyId: string; // Always available
  contentVersionId?: string; // Only if recordId was provided
}
```

**Returns:** `Promise<FileUploadResult[]>`

### createContentVersion(file, contentBodyId, recordId)

Manually create a ContentVersion record from a previously uploaded file.

```typescript
async function createContentVersion(
  file: File,
  contentBodyId: string,
  recordId: string,
): Promise<string | undefined>;
```

**Parameters:**

- `file` — File object (used for metadata like name)
- `contentBodyId` — ContentBody ID from previous upload
- `recordId` — Record ID for FirstPublishLocationId

**Returns:** ContentVersion ID if successful

### getCurrentUserId()

Get the current user's Salesforce ID.

```typescript
async function getCurrentUserId(): Promise<string>;
```

**Returns:** Current user ID

---

## Common UI patterns

### File input with button

```tsx
<input type="file" multiple accept=".pdf,.doc,.docx,.jpg,.png" onChange={handleFileSelect} />
```

### Drag-and-drop zone

Build your own dropzone using native events:

```tsx
function DropZone({ onDrop }: { onDrop: (files: File[]) => void }) {
  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    const files = Array.from(e.dataTransfer.files);
    onDrop(files);
  };

  return (
    <div
      onDrop={handleDrop}
      onDragOver={(e) => e.preventDefault()}
      style={{ border: "2px dashed #ccc", padding: "2rem" }}
    >
      Drop files here
    </div>
  );
}
```

### Progress bar

```tsx
{
  progress.status === "uploading" && (
    <div style={{ width: "100%", background: "#eee" }}>
      <div
        style={{
          width: `${progress.progress}%`,
          background: "#0176d3",
          height: "8px",
        }}
      />
    </div>
  );
}
```

---

## Reference implementation

The package includes a reference implementation in `src/features/fileupload/` with:

- `FileUpload.tsx` — Complete component with dropzone and dialog
- `FileUploadDialog.tsx` — Progress tracking dialog
- `FileUploadDropZone.tsx` — Drag-and-drop zone
- `useFileUpload.ts` — React hook for state management

**These are NOT exported** but can be viewed as examples. Read the source files to understand patterns for building your own UI.
