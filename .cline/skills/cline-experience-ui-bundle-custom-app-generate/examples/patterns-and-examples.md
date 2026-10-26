# experience-ui-bundle-custom-app-generate - Reference Examples, Patterns & Troubleshooting

## Reference Code & Command Examples

### Example 1
```xml
<?xml version="1.0" encoding="UTF-8"?>
<UIBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <masterLabel>{appName}</masterLabel>
    <description>A Salesforce UI Bundle.</description>
    <isActive>true</isActive>
    <version>1</version>
    <target>CustomApplication</target>
</UIBundle>
```

### Example 2
```bash
sf project deploy validate --metadata CustomApplication UIBundle --target-org ${usernameOrAlias}
```
