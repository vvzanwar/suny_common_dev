#!/usr/bin/env node
/**
 * High-Level Salesforce Development Standards Pre-Write & CLI Guard (sf-pre-write-guard.js)
 * Location: D:\SUNY_COMMON_DEV\SUNY_COMMON_DEV\scripts\cline\sf-pre-write-guard.js
 *
 * Deterministically enforces high-level architectural and coding standards in 0 LLM tokens:
 *  1. Trigger & Handler Separation:
 *     - .trigger files hold no logic, SOQL, or DML (only delegate to handler)
 *     - *TriggerHandler.cls contains no SOQL and no DML
 *  2. Layered Architecture (Service / Domain / Selector / Controller / Utils):
 *     - All SOQL lives in *Selector.cls (or *Test.cls) and runs WITH USER_MODE
 *     - No inline SOQL in *Service.cls, *Domain.cls, *Controller.cls, or *Utils.cls
 *     - No DML in *Domain.cls, *Selector.cls, *Controller.cls, or *Utils.cls
 *  3. Bulkification & Limits:
 *     - No SOQL, DML, callouts, or Messaging.sendEmail inside loops
 *  4. Clean Error Handling & Logging:
 *     - No System.debug in committed code
 *     - No empty catch blocks
 *  5. Async & Callouts:
 *     - No new @future methods (use Queueable)
 *     - Named Credentials only (`callout:...` in setEndpoint) and explicit req.setTimeout(...)
 *  6. Testing (*Test.cls):
 *     - No SeeAllData=true
 *     - Use Assert.areEqual / Assert.* instead of legacy System.assertEquals / System.assert
 *  7. LWC (/lwc/):
 *     - No document.querySelector or window.* in LWC JS
 *     - No @api property mutation in LWC JS
 *     - No hardcoded hex colors (#...) or pixel sizes (px) in LWC CSS (use SLDS tokens)
 */

const fs = require('fs');
const path = require('path');

const SF_ID_REGEX = /\b(?:001|003|005|006|00D|00G|00Q|012|01t|500|701|800|a0[0-9A-Za-z])[0-9A-Za-z]{12}(?:[0-9A-Za-z]{3})?\b/g;

function stripApexCommentsAndStrings(code) {
    return code
        .replace(/\/\*[\s\S]*?\*\//g, (m) => m.replace(/[^\n]/g, ' '))
        .replace(/\/\/.*$/gm, '')
        .replace(/'(?:\\'|[^'])*'/g, "''");
}

function validateContent(filePath, content) {
    const violations = [];
    if (!filePath || !content) return violations;
    const norm = filePath.replace(/\\/g, '/');
    const baseName = path.basename(norm);

    // =========================================================================
    // 1. APEX (.cls, .trigger) â€” High-Level Coding Standards
    // =========================================================================
    if (norm.endsWith('.cls') || norm.endsWith('.trigger')) {
        const clean = stripApexCommentsAndStrings(content);
        const lines = clean.split(/\r?\n/);
        const isTrigger = norm.endsWith('.trigger');
        const isTest = /@isTest/i.test(content) || /Test\.cls$/i.test(baseName);
        const isTriggerHandler = /TriggerHandler\.cls$/i.test(baseName) && baseName !== 'TriggerHandler.cls';
        const isDomain = /Domain\.cls$/i.test(baseName);
        const isSelector = /Selector\.cls$/i.test(baseName);
        const isService = /Service\.cls$/i.test(baseName);
        const isController = /Controller\.cls$/i.test(baseName);
        const isUtils = /Utils\.cls$/i.test(baseName);

        const hasSoql = /\[\s*SELECT\s+[\s\S]*?\bFROM\s+\w+/i.test(clean) || /\bDatabase\.query(?:WithBinds)?\s*\(/i.test(clean);
        const hasDml =
            /\b(insert|update|upsert|delete|undelete)\s+[a-zA-Z0-9_]+/i.test(clean) ||
            /\bDatabase\.(insert|update|upsert|delete|undelete)\s*\(/i.test(clean);

        // Rule: No System.debug in committed code
        if (/\bSystem\.debug\s*\(/i.test(clean)) {
            violations.push(
                `[Logging Standard] System.debug is not permitted in committed code. Use structured error logging in catch blocks.`
            );
        }

        // Rule: Trigger (.trigger) holds zero logic, SOQL, or DML
        if (isTrigger) {
            if (hasSoql || hasDml || /\b(for|while|if)\s*\(/i.test(clean)) {
                violations.push(
                    `[Trigger Standard] Triggers must hold no logic, SOQL, or DMLâ€”delegate immediately to the trigger handler.`
                );
            }
        }

        // Rule: TriggerHandler has no SOQL and no DML
        if (isTriggerHandler) {
            if (hasSoql) {
                violations.push(
                    `[Layering Standard] No SOQL allowed in ${baseName}. Query through a *Selector class inside the *Service layer.`
                );
            }
            if (hasDml) {
                violations.push(
                    `[Layering Standard] No DML allowed in ${baseName}. Shape Trigger.new/oldMap and delegate DML to a *Service class.`
                );
            }
        }

        // Rule: Domain class has no SOQL, no DML, no callouts
        if (isDomain) {
            if (hasSoql || hasDml || /\bnew\s+Http\s*\(\s*\)/i.test(clean)) {
                violations.push(
                    `[Layering Standard] ${baseName} (Domain layer) must work purely in-memory on List<SObject>â€”no SOQL, DML, or callouts.`
                );
            }
        }

        // Rule: Selector class holds all SOQL with WITH USER_MODE, and never performs DML
        if (isSelector) {
            if (hasDml) {
                violations.push(`[Layering Standard] ${baseName} (Selector layer) must never perform DML.`);
            }
            if (hasSoql && !/\bWITH\s+(USER_MODE|SYSTEM_MODE)\b/i.test(content)) {
                violations.push(
                    `[Security Standard] Queries in ${baseName} must include WITH USER_MODE (or WITH SYSTEM_MODE with an explanatory comment).`
                );
            }
        }

        // Rule: Service, Controller, and Utils never contain inline SOQL (must call a Selector)
        if ((isService || isController || isUtils) && !isTest) {
            if (/\[\s*SELECT\s+[\s\S]*?\bFROM\s+\w+/i.test(clean)) {
                violations.push(
                    `[Layering Standard] Inline SOQL detected in ${baseName}. Centralize SOQL queries inside the corresponding *Selector class.`
                );
            }
        }

        // Rule: Controller and Utils never perform direct DML (must call a Service)
        if ((isController || isUtils) && !isTest && hasDml) {
            violations.push(
                `[Layering Standard] Direct DML detected in ${baseName}. Controllers and Utils must delegate DML to a *Service class.`
            );
        }

        // Rule: No empty catch blocks
        if (/\bcatch\s*\([^)]+\)\s*\{\s*\}/i.test(clean)) {
            violations.push(
                `[Error Handling Standard] Empty catch block detected in ${baseName}. Log context and surface a user-actionable exception.`
            );
        }

        // Rule: No new @future methods
        if (/@future\b/i.test(content)) {
            violations.push(
                `[Async Standard] @future is legacy only. Implement Queueable (<Work>Queueable) taking a Set<Id> instead.`
            );
        }

        // Rule: Sharing keyword mandatory on classes
        if (!isTrigger && !isTest && !/Exception\.cls$/i.test(baseName)) {
            const isInterface = /\binterface\s+\w+/i.test(clean);
            const hasSharing = /\b(with\s+sharing|without\s+sharing|inherited\s+sharing)\s+(virtual\s+|abstract\s+)?class\b/i.test(clean);
            if (!isInterface && (isTriggerHandler || isService || isDomain || isSelector || isController) && !hasSharing) {
                violations.push(
                    `[Sharing Standard] ${baseName} must explicitly declare 'with sharing' (default), 'inherited sharing', or 'without sharing' (with comment).`
                );
            }
        }

        // Rule: No SOQL, DML, Callout, or Messaging.sendEmail inside loops
        let braceDepth = 0;
        const loopDepths = [];
        let pendingLoop = false;

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            let wasInLoopOnLine = loopDepths.length > 0;
            if (/\b(for|while)\s*\(/.test(line)) pendingLoop = true;
            for (let c = 0; c < line.length; c++) {
                if (line[c] === '{') {
                    braceDepth++;
                    if (pendingLoop) {
                        loopDepths.push(braceDepth);
                        wasInLoopOnLine = true;
                        pendingLoop = false;
                    }
                } else if (line[c] === '}') {
                    if (loopDepths.length > 0 && loopDepths[loopDepths.length - 1] === braceDepth) {
                        loopDepths.pop();
                    }
                    braceDepth = Math.max(0, braceDepth - 1);
                }
            }

            const inLoop = wasInLoopOnLine && !/\bfor\s*\([^)]*\[\s*SELECT\b/i.test(line);
            if (inLoop) {
                if (/\[\s*SELECT\s+/i.test(line) || /\bDatabase\.query/i.test(line)) {
                    violations.push(`[Bulkification Standard] Line ${i + 1}: SOQL inside loop. Query once into a Map<Id, SObject> before the loop.`);
                }
                if (/\b(insert|update|upsert|delete|undelete)\s+\w+/i.test(line) || /\bDatabase\.(insert|update|upsert|delete)\s*\(/i.test(line)) {
                    violations.push(`[Bulkification Standard] Line ${i + 1}: DML inside loop. Collect records into a List and perform one DML after the loop.`);
                }
                if (/\bMessaging\.sendEmail\s*\(/i.test(line) || /\bnew\s+Http\s*\(\s*\)\.send\s*\(/i.test(line)) {
                    violations.push(`[Bulkification Standard] Line ${i + 1}: Callout or Messaging.sendEmail inside loop.`);
                }
            }
        }

        // Rule: Callouts must use Named Credentials and setTimeout
        if (/\.setEndpoint\s*\(\s*'https?:\/\//i.test(content) && !isTest) {
            violations.push(
                `[Callout Standard] Hardcoded URL in setEndpoint(). Use a Named Credential ('callout:<Named_Credential>/...').`
            );
        }
        if (/\bnew\s+HttpRequest\s*\(\s*\)/i.test(clean) && !/\.setTimeout\s*\(/i.test(clean) && !isTest) {
            violations.push(
                `[Callout Standard] HttpRequest created without req.setTimeout(...). Always set an explicit timeout.`
            );
        }

        // Rule: Leading wildcard in SOQL
        if (/\bLIKE\s+'%[^']+'/i.test(content)) {
            violations.push(
                `[SOQL Standard] Non-selective leading wildcard (LIKE '%...') causes full table scans.`
            );
        }

        // Rule: Testing Standards (*Test.cls)
        if (isTest && !/Factory\.cls$/i.test(baseName)) {
            if (/SeeAllData\s*=\s*true/i.test(content)) {
                violations.push(`[Testing Standard] @IsTest(SeeAllData=true) is prohibited.`);
            }
            if (/\bSystem\.assert(Equals|NotEquals)?\s*\(/i.test(clean)) {
                violations.push(
                    `[Testing Standard] Use Assert.areEqual(expected, actual, 'message') / Assert.* instead of legacy System.assertEquals.`
                );
            }
        }

        // Rule: Hardcoded Salesforce IDs in non-test classes
        if (!isTest) {
            const idMatches = content.match(SF_ID_REGEX);
            if (idMatches && idMatches.some((id) => !/0000000000/.test(id))) {
                violations.push(`[Coding Standard] Hardcoded Salesforce ID detected (${idMatches[0]}).`);
            }
        }
    }

    // =========================================================================
    // 2. LWC (/lwc/) â€” High-Level Coding Standards
    // =========================================================================
    if (norm.includes('/lwc/')) {
        if (norm.endsWith('.js') && !norm.includes('__tests__')) {
            if (/\b(window|document)\.querySelector/i.test(content)) {
                violations.push(
                    `[LWC Standard] Do not use document.querySelector or window.* in LWC; scope DOM queries to this.template.`
                );
            }
            const apiProps = [...content.matchAll(/@api\s+([a-zA-Z0-9_]+)/g)].map((m) => m[1]);
            for (const prop of apiProps) {
                if (new RegExp(`\\bthis\\.${prop}\\s*=[^=]`).test(content)) {
                    violations.push(
                        `[LWC Standard] Direct mutation of @api property 'this.${prop}'. Use @api for input only and raise a CustomEvent.`
                    );
                }
            }
        }
        if (norm.endsWith('.css')) {
            const noVarContent = content.replace(/var\([^)]+\)/g, '');
            if (/#[0-9a-fA-F]{3,8}\b/.test(noVarContent) || /\b\d+px\b/.test(noVarContent)) {
                violations.push(
                    `[LWC Styling Standard] Hardcoded hex color or pixel size in ${baseName}. Use SLDS classes and design tokens (--slds-c-*) so campus theming works.`
                );
            }
        }
    }

    return violations;
}

if (process.argv.length > 2) {
    const files = process.argv.slice(2).filter((f) => !f.startsWith('--') && fs.existsSync(f));
    let total = 0;
    for (const file of files) {
        const issues = validateContent(file, fs.readFileSync(file, 'utf8'));
        if (issues.length > 0) {
            console.log(`\n[Code Guard Violations in ${file}]:`);
            issues.forEach((iss) => console.log(`  - ${iss}`));
            total += issues.length;
        }
    }
    process.exit(total > 0 ? 1 : 0);
} else {
    let input = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => (input += chunk));
    process.stdin.on('end', () => {
        try {
            if (!input.trim()) {
                process.stdout.write(JSON.stringify({ decision: 'allow' }) + '\n');
                return;
            }
            const payload = JSON.parse(input);
            const args = (payload.toolCall && payload.toolCall.args) || {};
            const cmdLine = args.CommandLine || args.commandLine || '';
            if (cmdLine && /\bsf\s+data\s+(delete|import|update|upsert)\b|\bsfdx\s+force:data:(record:delete|bulk:delete|bulk:upsert)\b/i.test(cmdLine)) {
                process.stdout.write(
                    JSON.stringify({
                        decision: 'deny',
                        reason: 'Blocked by SUNY_COMMON_DEV Sandbox DB Guard: Destructive or mutating CLI data commands (sf data delete/update/upsert/import) require explicit user approval. Use scripts/cline/cline-query-org.ps1 for read-only SELECT queries and schema describes.'
                    }) + '\n'
                );
                return;
            }

            const targetFile = args.TargetFile || args.targetFile || '';
            const content = args.CodeContent || args.ReplacementContent || '';

            const issues = validateContent(targetFile, content);
            if (issues.length > 0) {
                process.stdout.write(
                    JSON.stringify({
                        decision: 'deny',
                        reason: `Blocked by SUNY_COMMON_DEV Coding Standards Guard:\n- ${issues.join('\n- ')}`
                    }) + '\n'
                );
            } else {
                process.stdout.write(JSON.stringify({ decision: 'allow' }) + '\n');
            }
        } catch {
            process.stdout.write(JSON.stringify({ decision: 'allow' }) + '\n');
        }
    });
}

