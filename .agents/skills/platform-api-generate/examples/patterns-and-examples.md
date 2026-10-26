# platform-api-generate - Reference Examples, Patterns & Troubleshooting

## Reference Code & Command Examples

### Example 1
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

### Example 2
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

### Example 3
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
```
