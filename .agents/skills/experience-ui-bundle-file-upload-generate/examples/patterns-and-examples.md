# experience-ui-bundle-file-upload-generate - Reference Examples, Patterns & Troubleshooting

## Troubleshooting

**Upload fails with CORS error:**

- Ensure the UI bundle is properly deployed to Salesforce or running on `localhost`
- Check that the org allows the origin in CORS settings

**No progress updates:**

- Verify `onProgress` callback is provided
- Check that the callback function updates React state correctly

**ContentVersion not created:**

- Verify `recordId` is provided to `upload()` function
- Check that the record ID is valid and exists in the org
- Ensure user has permissions to create ContentVersion records

**Files upload but don't appear in record:**

- Verify `recordId` is correct
- Check that ContentVersion was created (look for `contentVersionId` in results)
- Confirm user has access to view files on the record
