# platform-permission-set-generate - Reference Examples, Patterns & Troubleshooting

## What Causes Deployment Failure

- **Field permissions on required fields:** Any required field in `<fieldPermissions>` fails deployment. Required fields cannot have FLS; omit them entirely. Always confirm from object/field metadata that a field exists and is not required—never assume.
- **Incorrect API names:** Using the wrong name or missing suffixes (e.g. missing `__c` for custom objects, fields, tabs) cause failure.
- **Invented fields:** A field permission for a field that doesn't exist on the object (including a plausible-looking one pattern-matched from another field in the request) fails deployment. Only grant field permissions for fields the request actually names.
- **Missing permission dependencies:** Some user permissions (e.g. `ModifyAllData`) fail to deploy unless their dependent permissions are also enabled. Do not add unrequested user permissions to work around a dependency error — escalate org-wide or administrative requests for security review instead.
