---
trigger: always_on
description: NCSIM Trigger Framework (7 contexts, TriggerHandler base class, recursion & bypass) and FeatureSwitch Custom Metadata rules
---

# NCSIM Standard 02: Trigger Framework & Feature Switches

## 1. Trigger Rules
- **One Trigger Per Object**: Named `<Object>Trigger.trigger`, declaring all 7 contexts (`before insert, before update, before delete, after insert, after update, after delete, after undelete`).
- **Zero Logic in `.trigger`**: The trigger body is a single line: `new <Object>TriggerHandler().run();`.
- **No SOQL or DML in Handlers**: `<Object>TriggerHandler` extends `TriggerHandler`, overrides only the needed virtual methods (`beforeInsert`, `beforeUpdate`, `afterUpdate`, etc.), calls `<Object>Domain` in `before` triggers, and filters changed records into a `Set<Id>` to pass to `<Object>Service` in `after` triggers.
- **Recursion & Bypass**: Handled centrally in `TriggerHandler` via `TriggerHandler.bypass('<HandlerName>')`, `TriggerHandler.clearBypass('<HandlerName>')`, and `setMaxLoopCount(Integer n)` (default `1`). Never add static `Boolean hasRun` flags to individual handlers.

```apex
trigger EnrollmentTrigger on Enrollment__c (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    new EnrollmentTriggerHandler().run();
}
```

```apex
public with sharing class EnrollmentTriggerHandler extends TriggerHandler {
    protected override void beforeInsert() {
        EnrollmentDomain.applyDefaults((List<Enrollment__c>) Trigger.new);
        EnrollmentDomain.validate((List<Enrollment__c>) Trigger.new, null);
    }

    protected override void beforeUpdate() {
        EnrollmentDomain.validate(
            (List<Enrollment__c>) Trigger.new,
            (Map<Id, Enrollment__c>) Trigger.oldMap
        );
    }

    protected override void afterUpdate() {
        Map<Id, Enrollment__c> oldMap = (Map<Id, Enrollment__c>) Trigger.oldMap;
        Set<Id> newlyConfirmedIds = new Set<Id>();
        for (Enrollment__c rec : (List<Enrollment__c>) Trigger.new) {
            if (rec.Status__c == EnrollmentDomain.STATUS_CONFIRMED
                && oldMap.get(rec.Id).Status__c != EnrollmentDomain.STATUS_CONFIRMED) {
                newlyConfirmedIds.add(rec.Id);
            }
        }
        if (!newlyConfirmedIds.isEmpty()) {
            EnrollmentService.handleConfirmations(newlyConfirmedIds);
        }
    }
}
```

## 2. Feature Switches (`FeatureSwitch` & `Feature_Switch__mdt`)
- Every trigger handler (`TriggerHandler.run()`) and every switchable Apex feature/callout checks `FeatureSwitch.isEnabled(name)`.
- `Feature_Switch__mdt` fields:
  - `DeveloperName`: Feature or TriggerHandler name (e.g., `EnrollmentTriggerHandler`, `Enrollment_Confirmation`, `Billing_Callout`)
  - `Is_Active__c` (Checkbox): Master on/off toggle
  - `Bypass_Permission__c` (Text, optional): API name of a Custom Permission (e.g., `Data_Migration_Bypass`) that skips this feature for specific users via `FeatureManagement.checkPermission`
  - `Description__c` (Long Text): Explains what turning the switch off disables
- **Mandatory Conventions**:
  1. Missing metadata record returns `true` (enabled) so a missing record never silently breaks logic.
  2. Every new trigger or switchable feature ships with its `Feature_Switch__mdt` record in the same deployment.
  3. Tests set switch states explicitly using `FeatureSwitch.set('Switch_Name', true/false)`.

```apex
public with sharing class FeatureSwitch {
    @TestVisible private static Map<String, Boolean> overrides = new Map<String, Boolean>();

    public static Boolean isEnabled(String name) {
        if (overrides.containsKey(name)) return overrides.get(name);
        Feature_Switch__mdt cfg = Feature_Switch__mdt.getInstance(name);
        if (cfg == null) return true;
        if (!cfg.Is_Active__c) return false;
        return String.isBlank(cfg.Bypass_Permission__c)
            || !FeatureManagement.checkPermission(cfg.Bypass_Permission__c);
    }

    @TestVisible
    private static void set(String name, Boolean value) {
        overrides.put(name, value);
    }
}
```
