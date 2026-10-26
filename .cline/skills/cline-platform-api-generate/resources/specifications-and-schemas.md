# platform-api-generate - Technical Specifications, Rules & Schemas

## 1. Operating Rules & Core Principles

1. **Inbound Custom REST Services (`@RestResource`)**:
   - URL mappings must follow semantic REST versioning: `@RestResource(urlMapping='/api/v1/admissions/*')`.
   - Adhere to standard HTTP verb semantics:
     - `@HttpGet`: Query/retrieve resource.
     - `@HttpPost`: Create new resource (return `201 Created` with Location header or ID).
     - `@HttpPut`: Complete replacement/upsert.
     - `@HttpPatch`: Partial update of specific fields.
     - `@HttpDelete`: Soft or hard delete resource.
   - Always wrap inbound execution in a standardized JSON envelope with consistent status codes (`statusCode`), error codes, and request correlation IDs.

2. **Outbound HTTP Callouts**:
   - **Never hardcode endpoint URLs or authentication tokens**.
   - Always route outbound traffic through Salesforce **Named Credentials** and **External Credentials**:
     `req.setEndpoint('callout:SUNY_Central_Auth_API/v1/oauth2/token');`
   - Handle timeouts gracefully (default to 60,000ms - 120,000ms max, implement retry logic with exponential backoff where idempotent).
   - Use strongly typed Data Transfer Objects (DTOs) for request/response bodies rather than untyped raw string manipulations.

3. **Error Handling & Fault Tolerance**:
   - Map standard HTTP error codes: `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict`, `422 Unprocessable Entity`, `500 Internal Server Error`.
   - Log failed callouts or unhandled exceptions into custom error logging objects or Platform Events.

4. **Testing & Mocking**:
   - Outbound callout code must be 100% testable without making live network requests.
   - Implement `HttpCalloutMock` or `MultiStaticResourceCalloutMock` for both successful 200/201 payloads and edge-case error scenarios (400, 500, timeout).

---

---

## 2. Inbound REST API Standard Template

### `force-app/main/default/classes/LearnerAdmissionRestResource.cls`
```apex
@RestResource(urlMapping='/api/v1/admissions/applicants/*')
global with sharing class LearnerAdmissionRestResource {

    global class ResponseEnvelope {
        public Boolean success;
        public String message;
        public Object data;
        public List<String> errors;

        public ResponseEnvelope(Boolean success, String message, Object data) {
            this.success = success;
            this.message = message;
            this.data = data;
            this.errors = new List<String>();
        }
    }

    @HttpGet
    global static void getApplicantDetails() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            String applicantId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            if (String.isBlank(applicantId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(
                    new ResponseEnvelope(false, 'Applicant ID is required in URL path.', null)
                ));
                return;
            }

            Applicant applicantRecord = [
                SELECT Id, Name, Status, CreatedDate 
                FROM Applicant 
                WHERE Id = :applicantId
                WITH USER_MODE
                LIMIT 1
            ];

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new ResponseEnvelope(true, 'Applicant retrieved successfully.', applicantRecord)
            ));
        } catch (QueryException qe) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new ResponseEnvelope(false, 'Applicant not found.', null)
            ));
        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new ResponseEnvelope(false, 'Internal Server Error: ' + ex.getMessage(), null)
            ));
        }
    }
}
```

---
