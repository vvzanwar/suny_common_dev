# platform-sharing-rules-generate - Technical Specifications, Rules & Schemas

## Workflow

Steps are sequential within each phase. Phase 3 branches by operation type — execute only the matching branch. Phase 4 applies to create, edit, and delete only (get operations end at Phase 3).

### Phase 1 — Discover

1. **Resolve the SFDX project path** — find the project's `sfdx-project.json` and identify the package directory for `sharingRules/`.

2. **Always retrieve the latest sharing rules from the org** using the Metadata API Retrieve pattern:
   ```bash
   sf project retrieve start --metadata "SharingRules:<ObjectName>" --target-org <org>
   ```
   This ensures the local file reflects the current org state. Never trust a local file that may be stale — edits or deletes against a stale file can recreate rules that were already removed in the org or overwrite changes made by other users.

3. **Read the retrieved file** — parse `<packageDir>/sharingRules/<ObjectName>.sharingRules-meta.xml` to understand existing rules and avoid duplicates.

### Phase 2 — Determine Operation and Rule Type

4. **Identify the operation** — determine whether the user wants to **get**, **create**, **edit**, or **delete** a sharing rule.

5. **Select the rule type** based on user intent. Read `examples/rule-types.md` for the complete schema of each type and its required elements.

6. **For Account sharing rules**: the `accountSettings` element is required. Default sub-access levels to `None` unless the user specifies otherwise.

7. **For Guest rules**: the `sharedTo` must use `<guestUser>` with the site guest user's community nickname. Never use `<role>` or `<group>` for guest rules.

### Phase 3 — Execute Operation

#### For Get:

8a. **Use the file already retrieved in Phase 1** — the retrieve in step 2 already pulled the latest `<ObjectName>.sharingRules-meta.xml` from the org. No additional retrieve is needed.

8b. **Read and present the retrieved rules** — parse the `.sharingRules-meta.xml` file and present the rules to the user in a readable format showing:
    - Rule name (`fullName`) and label
    - Rule type (criteria-based, owner-based, or guest)
    - Access level
    - Shared-to target
    - Criteria (if applicable)

    For get operations, skip Phase 4 (no write needed). The retrieve itself writes the metadata file to the local project.

#### For Create:

8a. **Construct the XML** following the schema in `examples/rule-types.md`. Key structure:
    - One `.sharingRules-meta.xml` file per object
    - All rules for the same object go in the same file
    - If appending to an existing file, add the new rule element inside the existing `<SharingRules>` root

8b. **Name the rule** — derive `<fullName>` from the intent (PascalCase, no spaces, descriptive). Generate a matching `<label>` in Title Case with spaces.

#### For Edit:

8a. **Locate the target rule** — find the rule by `<fullName>` or `<label>` in the existing `.sharingRules-meta.xml` file.

8b. **Gate unsupported edits** — the platform does NOT support in-place modification of `<sharedTo>` or `<sharedFrom>` elements. If the user requests a change to the sharing target or source, refuse the edit and instruct them to delete the existing rule and create a new one with the desired target. This is the same pattern used for rule-type changes (see TC-16).

8c. **Determine modifications based on rule type**:
    - **Owner-based rules (`sharingOwnerRules`)**: only `<accessLevel>` can be edited. The platform does not support modifying any other element (`sharedTo`, `sharedFrom`, `label`) on owner rules. If the user requests changes beyond access level, refuse and instruct them to delete + create.
    - **Criteria-based rules (`sharingCriteriaRules`)**: supported editable elements are `<accessLevel>`, `<criteriaItems>`, `<label>`, and `<booleanFilter>`.
    - **Guest rules (`sharingGuestRules`)**: supported editable elements are `<accessLevel>`, `<criteriaItems>`, `<label>`, and `<includeHVUOwnedRecords>`.

#### For Delete:

8a. **Locate the target rule** — find the rule by `<fullName>` or `<label>` in the existing `.sharingRules-meta.xml` file.

8b. **Count remaining rules** — run `scripts/count-remaining-rules.sh <file>` to get the total rule count. If the count is 1 (only the rule being deleted), the file must be removed entirely in Phase 4.

8c. **Delegate destructive deployment to `platform-destructive-deploy`** — a normal `sf project deploy start` is additive and will NOT remove a rule from the org. Delegate to the `platform-destructive-deploy` skill with the following context:
    - Metadata type: `SharingCriteriaRule`, `SharingOwnerRule`, or `SharingGuestRule` (depending on the rule type)
    - Member: `<ObjectName>.<RuleFullName>`
    - Target org: the user's specified org

### Phase 4 — Write and Verify

9. **Apply the change**:
    - **Create**: Write the file to `<packageDir>/sharingRules/<ObjectName>.sharingRules-meta.xml`.
    - **Edit**: Update only the elements identified in step 8b; preserve all other elements exactly as they were.
    - **Delete (rules remain)**: Write the updated file with the target rule removed.
    - **Delete (last rule)**: Remove the file `<packageDir>/sharingRules/<ObjectName>.sharingRules-meta.xml` entirely.

10. **Run the verification checklist** below and consult the examples files (`examples/create-cases.md`, `examples/edit-cases.md`, `examples/delete-cases.md`) for scenario-specific expected behaviors before presenting output.

---

---

## Verification Checklist

### Universal Checks
- [ ] Does the file have the XML declaration and `<SharingRules xmlns="http://soap.sforce.com/2006/04/metadata">` root?
- [ ] Is there exactly one file per object with all rules inside it?
- [ ] Does `<fullName>` use PascalCase with no spaces?
- [ ] Is `<label>` present and human-readable?
- [ ] Is `<accessLevel>` one of `Read` or `Edit`?

### Criteria Rule Checks
- [ ] Is `<includeRecordsOwnedByAll>` present (required boolean)?
- [ ] Does each `<criteriaItems>` have `<field>`, `<operation>`, and `<value>`?
- [ ] Are picklist values valid for the target org?

### Guest Rule Checks   CRITICAL
- [ ] Does `<sharedTo>` use `<guestUser>` (NOT `<role>` or `<group>`)?
- [ ] Is `<includeHVUOwnedRecords>` present (required boolean)?
- [ ] Is `<includeRecordsOwnedByAll>` ABSENT (only for criteria rules, not guest rules)?

### Owner Rule Checks
- [ ] Does the rule have both `<sharedFrom>` and `<sharedTo>` elements?
- [ ] Do both use valid `<role>`, `<roleAndSubordinates>`, or `<group>` targets?

### Edit Operation Checks
- [ ] Was the edit against a freshly retrieved file (not a stale local copy)?
- [ ] Is the edit limited to supported fields for the rule type?
  - Owner rules: only `accessLevel`
  - Criteria rules: `accessLevel`, `criteriaItems`, `label`, `booleanFilter`
  - Guest rules: `accessLevel`, `criteriaItems`, `label`, `includeHVUOwnedRecords`
- [ ] Was `sharedTo`/`sharedFrom` left unchanged? (if user requested that change, refuse and advise delete + create)
- [ ] Was only the intended element modified?
- [ ] Are all required elements still present after the edit?
- [ ] Does the modified rule still pass the universal checks above?

### Delete Operation Checks
- [ ] Was the correct rule removed (matched by `<fullName>`)?
- [ ] Is the remaining XML well-formed with proper `<SharingRules>` root?
- [ ] If no rules remain, was the file removed entirely?
- [ ] Was `platform-destructive-deploy` delegated to with the correct metadata type (`SharingCriteriaRule`, `SharingOwnerRule`, or `SharingGuestRule`)?

### Account-Specific Checks   CRITICAL
- [ ] If object is Account, is `<accountSettings>` present with all three sub-elements?
- [ ] Are `<caseAccessLevel>`, `<contactAccessLevel>`, `<opportunityAccessLevel>` all set?

---

---

## Rules / Constraints

| Constraint | Rationale |
|-----------|-----------|
| One `.sharingRules-meta.xml` file per object | Platform requirement — multiple files cause deployment errors |
| Guest rules must use `<guestUser>` in `sharedTo` | Using `<role>` or `<group>` causes: "Specify a guest user's nickname for the guestUser field" |
| Account rules require `<accountSettings>` | Without it: "AccountSettings is required for account sharing rules" |
| `includeRecordsOwnedByAll` is required on criteria rules | Missing it causes: "Required field is missing: sharingCriteriaRules" |
| `includeHVUOwnedRecords` is required on guest rules | Missing it causes deployment failure |
| Criteria field values must exist as picklist values on the org | Invalid values cause: "Picklist value does not exist" |
| Never hardcode file paths — resolve from `sfdx-project.json` | Customer projects use custom package directories |
| For managed package custom objects, use the full API name including namespace prefix (e.g., `ns__Object__c`) | Namespace-prefixed objects store sharing rules under the prefixed name |
| `sharedTo` and `sharedFrom` cannot be edited in place | Platform does not support modifying sharing targets — deploy will fail. Delete the rule and create a new one instead |
| Owner-based rules only support editing `accessLevel` | No other field (`label`, `sharedTo`, `sharedFrom`) can be modified on owner rules — delete and recreate instead |
| Always retrieve from the org before edit or delete | Local files may be stale; editing a stale file can recreate deleted rules or overwrite concurrent changes |
| Deleting a rule requires a destructive deployment | A normal deploy is additive — it will not remove rules from the org. Delegate to `platform-destructive-deploy` |
| Edit must preserve unmodified elements | Changing only `accessLevel` must not alter `criteriaItems` or other fields |
| Delete must remove the entire rule block | Partial deletion leaves invalid XML and causes deployment failures |
| Delete last rule removes the file | An empty `<SharingRules>` root with no children is invalid metadata |

---

---

## Reference File Index

| File | When to read |
|------|-------------|
| `examples/rule-types.md` | Phase 2 — before generating any rule, to get the complete XML schema for each rule type |
| `scripts/count-remaining-rules.sh` | Phase 3, step 8b (Delete) — count sharing rule elements to determine if file should be removed |
| `examples/create-cases.md` | Phase 4, step 10 — expected behavior for create and append scenarios |
| `examples/edit-cases.md` | Phase 4, step 10 — expected behavior for edit scenarios |
| `examples/delete-cases.md` | Phase 4, step 10 — expected behavior for delete scenarios |
