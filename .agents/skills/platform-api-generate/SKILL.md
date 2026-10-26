---
name: platform-api-generate
description: >-
  Author and integrate Salesforce custom REST services (@RestResource), HTTP callouts,
  Named Credentials, Platform Events, DTO contracts, and HttpCalloutMock test classes.
  Use when designing, implementing, debugging, or mocking APIs and integrations.
metadata:
  version: "1.0"
  domains: ["Platform", "Integration"]
  minApiVersion: "66.0"
---

# Salesforce API & Integration Authoring (`platform-api-generate`)

You are the dedicated **Integration & API Architect** for the `SUNY_COMMON_DEV` project. Your mission is to build secure, robust, and performant inbound and outbound integrations connecting SUNY campuses, external student information systems (SIS), state databases, and third-party credential services.

---

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md`

---

## 2. Inbound REST API Standard Template

### `force-app/main/default/classes/LearnerAdmissionRestResource.cls`
```apex
@RestResource(urlMapping='/api/v1/admissions/applicants/*')
global with sharing class LearnerAdmissionRestResource {

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## 3. Outbound Callout Template with Named Credentials

```apex
public inherited sharing class SisSyncOutboundService {

    public class SisSyncResult {
        public Boolean isSuccess;
        public Integer statusCode;
        public String responseBody;
    }

    public static SisSyncResult syncStudentProfile(String studentCampusId, String payloadJson) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SUNY_Campus_SIS/api/v2/students/' + EncodingUtil.urlEncode(studentCampusId, 'UTF-8'));
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000); // 120s max
        req.setBody(payloadJson);

        Http http = new Http();
        HttpResponse res = http.send(req);

        SisSyncResult result = new SisSyncResult();
        result.statusCode = res.getStatusCode();
        result.responseBody = res.getBody();
        result.isSuccess = (res.getStatusCode() >= 200 && res.getStatusCode() < 300);

        return result;
    }
}
```

---

## 4. Callout Mock Template for Unit Tests

```apex
@isTest
public class SisSyncOutboundServiceMock implements HttpCalloutMock {
    protected Integer statusCode;
    protected String responsePayload;

    public SisSyncOutboundServiceMock(Integer statusCode, String responsePayload) {
        this.statusCode = statusCode;
        this.responsePayload = responsePayload;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.responsePayload);
        res.setStatusCode(this.statusCode);
        return res;
    }
}

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
