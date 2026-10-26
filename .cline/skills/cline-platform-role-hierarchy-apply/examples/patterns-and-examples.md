# platform-role-hierarchy-apply - Reference Examples, Patterns & Troubleshooting

## Reference Code & Command Examples

### Example 1
```text
SELECT Id, DeveloperName, Name, ParentRoleId
FROM   UserRole
LIMIT  10000
```

### Example 2
```text
Restructure preview
-------------------
  ReparentRole : 42
  CreateRole   :  3
  RenameRole   :  1
  DeleteRole   :  2
  MoveUser     :  2

  Territory / forecast references : 1
  Portal roles                    : 0
  Roles with more than 500 users  : 2

Approve this restructure? [yes / no]
```

### Example 3
```text
POST /services/data/v{version}/sharing/role-hierarchy-restructure
{
  "operation": "Save",
  "mutations": [
    {
      "operationId": "reparent-sales-vp",
      "operationType": "ReparentRole",
      "dependsOnOperationIds": [],
      "reparentRole": {
        "targetRoleId": "00E000000000001",
        "expectedParentRoleId": "00E000000000002",
        "desiredParentRoleReference": "cro"
      }
    },
    {
      "operationId": "delete-legacy-region",
      "operationType": "DeleteRole",
      "dependsOnOperationIds": ["reparent-legacy-children"],
      "deleteRole": {
        "targetRoleId": "00E000000000003",
        "expectedParentRoleId": "00E000000000002",
        "expectedAssignedUserIds": [],
        "expectedDirectChildRoleIds": []
      }
    }
  ]
}
```
