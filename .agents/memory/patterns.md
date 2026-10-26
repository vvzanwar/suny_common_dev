# Project Implementation Patterns

Document reusable code patterns, testing recipes, and mocking conventions specific to this workspace.

### Template:
<!--
### Pattern: [Pattern Name]
- **Use Case:** [When to apply this pattern]
- **Reference Example:** [Code snippet or class reference]
-->

### Pattern: TestDataFactory Unsaved SObject Defaults
- **Use Case:** Creating test records without premature DML.
- **Recipe:** All factory methods (`TestDataFactory.make<Object>()`) return unsaved SObjects so test methods can override fields before a single consolidated insert in `@TestSetup`.

### Pattern: Selector Query Structure
- **Use Case:** All SOQL queries across the codebase.
- **Recipe:**
  ```apex
  public with sharing class <Object>Selector {
      private static final String FIELDS = 'Id, Name, ...';
      public static List<SObject> selectByIds(Set<Id> ids) {
          if (ids == null || ids.isEmpty()) return new List<SObject>();
          return Database.query('SELECT ' + FIELDS + ' FROM <Object> WHERE Id IN :ids WITH USER_MODE');
      }
  }
  ```
