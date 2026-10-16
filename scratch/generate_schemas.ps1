# Clean PowerShell script to generate 35 object schema documentation files in docs/objects/
$objectsDir = "d:\SUNY_COMMON_DEV\SUNY_COMMON_DEV\docs\objects"
if (-not (Test-Path -Path $objectsDir)) {
    New-Item -ItemType Directory -Path $objectsDir -Force | Out-Null
}

$schemaData = @(
    @{
        Name = "Account"
        Label = "Account"
        Prefix = "001"
        Type = "Standard Object"
        Module = "Core CRM & Education Cloud Institutional Model"
        Overview = "The Account object is the core pillar of the SUNY Common Dev ecosystem. In this multi-campus architecture, Account represents institutional entities (SUNY Campuses), external corporate partners (Employers), and individual learners (Person Accounts)."
        RecordTypes = "- **Campus** (`Account.Campus`): Represents individual SUNY colleges and university centers (e.g., Stony Brook, Buffalo, Albany, Binghamton).`n- **Employer** (`Account.Employer`): Corporate and non-profit partner employers providing internships, cooperative education, and career placement.`n- **Person Account** (`Account.PersonAccount`): Represents enrolled students and prospective learners by unifying Account and Contact into a single record."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Official name of the Campus, Employer company, or Learner."),
            @("RecordTypeId", "RecordTypeId", "Lookup", "RecordType", "Distinguishes between Campus, Employer, and Person Account records."),
            @("ParentId", "ParentId", "Lookup", "Account", "Institutional hierarchy link (e.g. SUNY System Administration -> Specific Campus)."),
            @("PersonEmail", "PersonEmail", "Email", "-", "Personal primary email address for Person Accounts (Learners)."),
            @("PersonBirthdate", "PersonBirthdate", "Date", "-", "Student date of birth for identity verification and eligibility."),
            @("PersonMailingAddress", "PersonMailingAddress", "Address", "-", "Official student residential and mailing address."),
            @("Industry", "Industry", "Picklist", "-", "Sector categorization for employer and institutional accounts."),
            @("Ownership", "Ownership", "Picklist", "-", "Ownership structure (e.g., Public for SUNY institutions, Private for employers)."),
            @("Type", "Type", "Picklist", "-", "Account classification (Campus, Vendor, Academic Partner, Employer).")
        )
        Parents = @(
            "- ``ParentId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Higher-level system or institutional parent)"
        )
        Children = @(
            "- ``Contact.AccountId`` -> Campus faculty, advisors, and student contacts",
            "- ``IndividualApplication.AccountId`` -> Applications submitted by learners",
            "- ``LearningProgram.ProviderId`` -> Academic degree programs offered by the campus",
            "- ``LearningCourse.ProviderId`` -> Course offerings taught by the campus",
            "- ``PersonEducation.InstitutionAccountId`` -> Prior colleges or high schools attended",
            "- ``PersonEmployment.AccountId`` -> Employer companies employing students",
            "- ``Case.AccountId`` -> Advising tickets and student support inquiries"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ CONTACT : has`n    ACCOUNT ||--o{ INDIVIDUAL_APPLICATION : submits`n    ACCOUNT ||--o{ LEARNING_PROGRAM : provides`n    ACCOUNT ||--o{ LEARNING_COURSE : teaches`n    ACCOUNT ||--o{ CASE : logs"
        Soql = "SELECT Id, Name, RecordType.DeveloperName, ParentId, PersonEmail FROM Account ORDER BY Name LIMIT 10"
    },
    @{
        Name = "Contact"
        Label = "Contact"
        Prefix = "003"
        Type = "Standard Object"
        Module = "Core CRM & Campus Personnel"
        Overview = "Represents individuals associated with accounts, including SUNY campus faculty, academic advisors, departmental deans, administrative staff, and external references for admissions applications."
        RecordTypes = "Operates with standard contact architecture across institutional campus accounts and corporate partner employers."
        Fields = @(
            @("Name", "Name", "Text(121)", "-", "Full name of the contact person."),
            @("AccountId", "AccountId", "Lookup", "Account", "The associated SUNY campus or employer account."),
            @("Email", "Email", "Email", "-", "Primary institutional or professional email address."),
            @("Phone", "Phone", "Phone", "-", "Work telephone number or departmental extension."),
            @("Title", "Title", "Text(128)", "-", "Official faculty/staff designation (e.g., Associate Dean, Academic Advisor)."),
            @("Department", "Department", "Text(80)", "-", "Academic department (e.g., Computer Science, School of Nursing)."),
            @("ReportsToId", "ReportsToId", "Lookup", "Contact", "Managerial or supervisory hierarchy between staff members.")
        )
        Parents = @(
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Institutional campus or employer)",
            "- ``ReportsToId`` -> [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md) (Direct supervisor or department chair)"
        )
        Children = @(
            "- ``User.ContactId`` -> Community/portal authenticated user accounts",
            "- ``IndividualApplication.ContactId`` -> Student applicant contact link",
            "- ``PersonEducation.ContactId`` -> Prior educational records for the contact",
            "- ``Case.ContactId`` -> Support cases filed by or assigned to the contact"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ CONTACT : employs`n    CONTACT ||--o{ CONTACT : reports_to`n    CONTACT ||--o{ USER : authenticates`n    CONTACT ||--o{ CASE : requests"
        Soql = "SELECT Id, FirstName, LastName, Account.Name, Title, Department, Email FROM Contact LIMIT 10"
    },
    @{
        Name = "User"
        Label = "User"
        Prefix = "005"
        Type = "Standard Object"
        Module = "Identity, Access & Security"
        Overview = "Represents internal administrative users, campus admissions officers, evaluators, and portal users (Campus Staff, SUNY Admin, Learners, Employers) accessing the system."
        RecordTypes = "Utilizes profiles and permission set groups (force__AgentforceServiceAgentUserPsg, force__Talent_Recruitment_Management_Applicant, SUNY Admin, Campus Staff)."
        Fields = @(
            @("Username", "Username", "Text(80)", "-", "Unique system login credential."),
            @("Name", "Name", "Text(121)", "-", "Full display name of the staff or system user."),
            @("Email", "Email", "Email", "-", "Verified email address for notifications and MFA."),
            @("ProfileId", "ProfileId", "Lookup", "Profile", "Role profile controlling object-level permissions (e.g. SUNY Admin, Learner)."),
            @("UserRoleId", "UserRoleId", "Lookup", "UserRole", "Role hierarchy node for record sharing."),
            @("AccountId", "AccountId", "Lookup", "Account", "Associated portal account for external community users."),
            @("ContactId", "ContactId", "Lookup", "Contact", "Associated contact record for portal users."),
            @("IsActive", "IsActive", "Checkbox", "-", "Indicates whether the user license is enabled.")
        )
        Parents = @(
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (For community portal users)",
            "- ``ContactId`` -> [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md) (Personnel record)"
        )
        Children = @(
            "- ``ApplicationDecision.DecisionAuthorityId`` -> Authorized admissions decisions signed off by user",
            "- ``ApplicationReview.ReviewedById`` -> Evaluation rubrics completed by faculty user"
        )
        Mermaid = "erDiagram`n    USER ||--o{ APPLICATION_DECISION : authorizes`n    USER ||--o{ APPLICATION_REVIEW : completes`n    ACCOUNT ||--o{ USER : portal_access"
        Soql = "SELECT Id, Username, Name, Profile.Name, IsActive, LastLoginDate FROM User WHERE IsActive = true LIMIT 10"
    },
    @{
        Name = "PersonAccount"
        Label = "Person Account"
        Prefix = "001"
        Type = "Standard Object (Person Architecture)"
        Module = "Student & Learner 360"
        Overview = "A specialized architecture of Account that combines business account and individual contact attributes. In SUNY Education Cloud, Person Accounts represent students and lifelong learners."
        RecordTypes = "Configured under Account record type PersonAccount with default compact layout EmployeePortalDefault."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Full student name (FirstName LastName)."),
            @("PersonEmail", "PersonEmail", "Email", "-", "Primary email address for learner communications."),
            @("PersonBirthdate", "PersonBirthdate", "Date", "-", "Student birth date."),
            @("PersonMobilePhone", "PersonMobilePhone", "Phone", "-", "Mobile phone number for alerts and verification."),
            @("BillingAddress", "BillingAddress", "Address", "-", "Permanent billing/residence address."),
            @("PersonGenderIdentity", "PersonGenderIdentity", "Picklist", "-", "Optional self-reported gender identity."),
            @("PersonPronouns", "PersonPronouns", "Picklist", "-", "Preferred personal pronouns.")
        )
        Parents = @(
            "- [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Underlying standard entity)"
        )
        Children = @(
            "- ``IndividualApplication.AccountId`` -> Applications submitted by learner",
            "- ``AcademicTermEnrollment.LearnerAccountId`` -> Term enrollments",
            "- ``PersonEducation.AccountId`` -> Prior transcripts and degrees",
            "- ``PersonEmployment.AccountId`` -> Work history and internships",
            "- ``PersonExamination.AccountId`` -> Standardized test scores"
        )
        Mermaid = "erDiagram`n    PERSON_ACCOUNT ||--o{ INDIVIDUAL_APPLICATION : files`n    PERSON_ACCOUNT ||--o{ ACADEMIC_TERM_ENROLLMENT : enrolls`n    PERSON_ACCOUNT ||--o{ PERSON_EDUCATION : possesses`n    PERSON_ACCOUNT ||--o{ PERSON_EXAMINATION : reports"
        Soql = "SELECT Id, Name, PersonEmail, PersonBirthdate, BillingCity, BillingState FROM Account WHERE IsPersonAccount = true LIMIT 10"
    },
    @{
        Name = "Applicant"
        Label = "Applicant"
        Prefix = "13Y"
        Type = "Standard Education Cloud Object"
        Module = "Admissions & Recruitment"
        Overview = "Represents a prospective learner who has created an admissions profile and intends to submit applications to one or more SUNY campus programs."
        RecordTypes = "Standard Education Cloud Applicant record types."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Applicant profile identifier or name."),
            @("AccountId", "AccountId", "Lookup", "Account", "Associated student Person Account."),
            @("ContactId", "ContactId", "Lookup", "Contact", "Associated Contact record for the applicant."),
            @("ApplicationFormId", "ApplicationFormId", "Master-Detail", "ApplicationForm", "The master application form definition."),
            @("PartyProfileId", "PartyProfileId", "Lookup", "PartyProfile", "Common identity party profile record.")
        )
        Parents = @(
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Learner Person Account)",
            "- ``ContactId`` -> [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md) (Individual Contact)",
            "- ``ApplicationFormId`` -> ApplicationForm (Parent form template)"
        )
        Children = @(
            "- ``IndividualApplication.ApplicantId`` -> Specific program applications submitted",
            "- ``PersonEmployment.RelatedPersonId`` -> Applicant work experience records"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ APPLICANT : represents`n    APPLICATION_FORM ||--o{ APPLICANT : defines`n    APPLICANT ||--o{ INDIVIDUAL_APPLICATION : submits"
        Soql = "SELECT Id, Name, Account.Name, Contact.Email, CreatedDate FROM Applicant LIMIT 10"
    },
    @{
        Name = "IndividualApplication"
        Label = "Individual Application"
        Prefix = "11A"
        Type = "Standard Education Cloud Object"
        Module = "Admissions & Recruitment"
        Overview = "The central record for an application submitted by a student for admission into a specific SUNY academic program, degree plan, or course in a designated term."
        RecordTypes = "Categorized by Undergraduate, Graduate, Transfer, Certificate, and Non-Degree application types."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Application tracking number or label."),
            @("AccountId", "AccountId", "Lookup", "Account", "Student Person Account submitting the application."),
            @("ContactId", "ContactId", "Lookup", "Contact", "Student Contact record."),
            @("ProgramTermApplnTimelineId", "ProgramTermApplnTimelineId", "Lookup", "ProgramTermApplnTimeline", "Specific program intake window and term deadline."),
            @("ApplicationCaseId", "ApplicationCaseId", "Lookup", "Case", "Admissions processing case associated with the application."),
            @("OpportunityId", "OpportunityId", "Lookup", "Opportunity", "Associated financial or enrollment pipeline opportunity."),
            @("Status", "Status", "Picklist", "-", "Current status (Draft, Submitted, Under Review, Decision Rendered).")
        )
        Parents = @(
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Learner Person Account)",
            "- ``ContactId`` -> [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md) (Applicant Contact)",
            "- ``ProgramTermApplnTimelineId`` -> [ProgramTermApplnTimeline](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/ProgramTermApplnTimeline.md) (Target intake term)"
        )
        Children = @(
            "- ``ApplicationDecision.ApplicationId`` -> Official admissions decisions",
            "- ``ApplicationReview.ApplicationId`` -> Faculty and staff scoring reviews",
            "- ``PersonEducation.IndividualApplicationId`` -> Educational records attached to application",
            "- ``PersonExamination.IndividualApplicationId`` -> Test scores attached to application"
        )
        Mermaid = "erDiagram`n    INDIVIDUAL_APPLICATION ||--o{ APPLICATION_DECISION : concludes_with`n    INDIVIDUAL_APPLICATION ||--o{ APPLICATION_REVIEW : evaluated_by`n    INDIVIDUAL_APPLICATION ||--o{ PERSON_EDUCATION : provides_records`n    PROGRAM_TERM_APPLN_TIMELINE ||--o{ INDIVIDUAL_APPLICATION : schedules"
        Soql = "SELECT Id, Name, Account.Name, Status, ProgramTermApplnTimeline.LearningProgram.Name FROM IndividualApplication LIMIT 10"
    },
    @{
        Name = "ApplicationDecision"
        Label = "Application Decision"
        Prefix = "12F"
        Type = "Standard Education Cloud Object"
        Module = "Admissions & Recruitment"
        Overview = "Records formal admission decisions rendered for an application, such as Admitted, Waitlisted, Conditional Offer, or Denied, along with issuance and response dates."
        RecordTypes = "Standard admissions decision records."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Decision reference name."),
            @("ApplicationId", "ApplicationId", "Lookup", "IndividualApplication", "The application for which the decision is rendered."),
            @("AccountId", "AccountId", "Lookup", "Account", "The learner account receiving the decision."),
            @("DecisionAuthorityId", "DecisionAuthorityId", "Lookup", "User", "Dean, Vice Provost, or Admissions Officer authorizing the decision."),
            @("DecisionDate", "DecisionDate", "Date", "-", "Date when the decision was finalized."),
            @("Status", "Status", "Picklist", "-", "Decision status (Accepted, Deferred, Waitlist, Denied).")
        )
        Parents = @(
            "- ``ApplicationId`` -> [IndividualApplication](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/IndividualApplication.md) (Evaluated application)",
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Learner)",
            "- ``DecisionAuthorityId`` -> [User](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/User.md) (Authorizing official)"
        )
        Children = @(
            "- ``IndividualApplicationTask.ApplicationDecisionId`` -> Post-decision enrollment checklist tasks"
        )
        Mermaid = "erDiagram`n    INDIVIDUAL_APPLICATION ||--o{ APPLICATION_DECISION : generates`n    USER ||--o{ APPLICATION_DECISION : authorizes`n    ACCOUNT ||--o{ APPLICATION_DECISION : notifies"
        Soql = "SELECT Id, Name, Application.Name, Status, DecisionDate, DecisionAuthority.Name FROM ApplicationDecision LIMIT 10"
    },
    @{
        Name = "ApplicationReview"
        Label = "Application Review"
        Prefix = "12E"
        Type = "Standard Education Cloud Object"
        Module = "Admissions & Recruitment"
        Overview = "Stores holistic evaluation rubrics, reviewer ratings, and qualitative comments provided by campus admissions counselors or academic department faculty."
        RecordTypes = "Standard admissions review evaluations."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Review evaluation identifier."),
            @("ApplicationId", "ApplicationId", "Lookup", "IndividualApplication", "Target application being evaluated."),
            @("InstitutionId", "InstitutionId", "Lookup", "Account", "The evaluating SUNY campus account."),
            @("ReviewedById", "ReviewedById", "Lookup", "User", "The faculty member or admissions officer conducting the review."),
            @("ReviewDate", "ReviewDate", "Date", "-", "Date review was conducted."),
            @("OverallScore", "OverallScore", "Number", "-", "Weighted numeric score based on rubric metrics.")
        )
        Parents = @(
            "- ``ApplicationId`` -> [IndividualApplication](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/IndividualApplication.md)",
            "- ``InstitutionId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (SUNY Campus)",
            "- ``ReviewedById`` -> [User](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/User.md) (Reviewer)"
        )
        Children = @(
            "- ``IndividualApplicationTask.ApplicationReviewId`` -> Follow-up review tasks"
        )
        Mermaid = "erDiagram`n    INDIVIDUAL_APPLICATION ||--o{ APPLICATION_REVIEW : assessed_in`n    ACCOUNT ||--o{ APPLICATION_REVIEW : conducts`n    USER ||--o{ APPLICATION_REVIEW : evaluates"
        Soql = "SELECT Id, Name, Application.Name, Institution.Name, ReviewedBy.Name, OverallScore FROM ApplicationReview LIMIT 10"
    },
    @{
        Name = "ApplicationRecommendation"
        Label = "Application Recommendation"
        Prefix = "12G"
        Type = "Standard Education Cloud Object"
        Module = "Admissions & Recruitment"
        Overview = "Captures external letters of recommendation, ratings, and referee endorsements submitted on behalf of a student applicant."
        RecordTypes = "Standard Education Cloud recommendation records."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Recommendation record name."),
            @("ApplicationRecommenderId", "ApplicationRecommenderId", "Lookup", "ApplicationRecommender", "The referee providing the recommendation."),
            @("RecommendationStatus", "RecommendationStatus", "Picklist", "-", "Status (Requested, Received, Waived)."),
            @("SubmittedDate", "SubmittedDate", "Date/Time", "-", "Timestamp when referee submitted letter.")
        )
        Parents = @(
            "- ``ApplicationRecommenderId`` -> ApplicationRecommender (Referee profile)"
        )
        Children = @(
            "- Associated to applicant application packet"
        )
        Mermaid = "erDiagram`n    APPLICATION_RECOMMENDER ||--o{ APPLICATION_RECOMMENDATION : provides`n    APPLICATION_RECOMMENDATION ||--o{ INDIVIDUAL_APPLICATION : supports"
        Soql = "SELECT Id, Name, ApplicationRecommender.Name, RecommendationStatus, SubmittedDate FROM ApplicationRecommendation LIMIT 10"
    },
    @{
        Name = "ProgramTermApplnTimeline"
        Label = "Program Term Application Timeline"
        Prefix = "13W"
        Type = "Standard Education Cloud Object"
        Module = "Academic Operations & Admissions"
        Overview = "Critical bridge linking Academic Terms with Degree Programs to govern the intake calendar, opening dates, early action deadlines, and final application cutoffs."
        RecordTypes = "Standard calendar timeline rules."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Timeline rule designation (e.g. Fall 2025 CS B.S. Regular)."),
            @("LearningProgramId", "LearningProgramId", "Lookup", "LearningProgram", "Target academic program offering admission."),
            @("LearningProgramPlanId", "LearningProgramPlanId", "Lookup", "LearningProgramPlan", "Specific curriculum plan/catalog year."),
            @("AcademicTermId", "AcademicTermId", "Lookup", "AcademicTerm", "Target academic semester (e.g., Fall 2025)."),
            @("ApplicationTimelineId", "ApplicationTimelineId", "Lookup", "ApplicationTimeline", "Master timeline window definition.")
        )
        Parents = @(
            "- ``LearningProgramId`` -> [LearningProgram](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/LearningProgram.md)",
            "- ``LearningProgramPlanId`` -> [LearningProgramPlan](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/LearningProgramPlan.md)",
            "- ``AcademicTermId`` -> [AcademicTerm](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/AcademicTerm.md)"
        )
        Children = @(
            "- ``IndividualApplication.ProgramTermApplnTimelineId`` -> Submitted applications governed by this schedule"
        )
        Mermaid = "erDiagram`n    LEARNING_PROGRAM ||--o{ PROGRAM_TERM_APPLN_TIMELINE : schedules`n    ACADEMIC_TERM ||--o{ PROGRAM_TERM_APPLN_TIMELINE : during`n    PROGRAM_TERM_APPLN_TIMELINE ||--o{ INDIVIDUAL_APPLICATION : receives"
        Soql = "SELECT Id, Name, LearningProgram.Name, AcademicTerm.Name FROM ProgramTermApplnTimeline LIMIT 10"
    },
    @{
        Name = "AcademicYear"
        Label = "Academic Year"
        Prefix = "13S"
        Type = "Standard Education Cloud Object"
        Module = "Academic Calendar & Operations"
        Overview = "Defines the macro institutional academic calendar year (e.g. 2025-2026 Academic Year) across SUNY campuses."
        RecordTypes = "Standard institutional calendar years."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Calendar label (e.g., 2025-2026 Academic Year)."),
            @("StartDate", "StartDate", "Date", "-", "Commencement date of academic year."),
            @("EndDate", "EndDate", "Date", "-", "Conclusion date of academic year.")
        )
        Parents = @(
            "- Master institutional calendar root"
        )
        Children = @(
            "- ``AcademicTerm.AcademicYearId`` -> Semesters and quarters within the year"
        )
        Mermaid = "erDiagram`n    ACADEMIC_YEAR ||--o{ ACADEMIC_TERM : subdivides_into"
        Soql = "SELECT Id, Name, StartDate, EndDate FROM AcademicYear ORDER BY StartDate DESC LIMIT 10"
    },
    @{
        Name = "AcademicTerm"
        Label = "Academic Term"
        Prefix = "13T"
        Type = "Standard Education Cloud Object"
        Module = "Academic Calendar & Operations"
        Overview = "Represents distinct instructional periods within an academic year, such as Fall, Spring, or Summer terms, driving registration and billing cycles."
        RecordTypes = "Standard academic terms."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Term name (e.g., Fall 2025 Semester)."),
            @("AcademicYearId", "AcademicYearId", "Lookup", "AcademicYear", "Parent academic year."),
            @("StartDate", "StartDate", "Date", "-", "First day of instruction for the term."),
            @("EndDate", "EndDate", "Date", "-", "Final examination and grading cutoff date."),
            @("TermType", "TermType", "Picklist", "-", "Semester, Trimester, Quarter, or Intersession.")
        )
        Parents = @(
            "- ``AcademicYearId`` -> [AcademicYear](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/AcademicYear.md)"
        )
        Children = @(
            "- ``AcademicSession.AcademicTermId`` -> Granular sessions within the term",
            "- ``AcademicTermEnrollment.AcademicTermId`` -> Student enrollments for the term",
            "- ``ProgramTermApplnTimeline.AcademicTermId`` -> Program intake timelines"
        )
        Mermaid = "erDiagram`n    ACADEMIC_YEAR ||--o{ ACADEMIC_TERM : contains`n    ACADEMIC_TERM ||--o{ ACADEMIC_SESSION : divides`n    ACADEMIC_TERM ||--o{ ACADEMIC_TERM_ENROLLMENT : registers"
        Soql = "SELECT Id, Name, AcademicYear.Name, StartDate, EndDate, TermType FROM AcademicTerm ORDER BY StartDate DESC LIMIT 10"
    },
    @{
        Name = "AcademicSession"
        Label = "Academic Session"
        Prefix = "13V"
        Type = "Standard Education Cloud Object"
        Module = "Academic Calendar & Operations"
        Overview = "Sub-divides an Academic Term into granular instructional sessions (e.g., 7-week accelerated block A, 10-week summer session)."
        RecordTypes = "Standard session blocks."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Session block name (e.g., Summer Session I)."),
            @("AcademicTermId", "AcademicTermId", "Lookup", "AcademicTerm", "Parent academic semester."),
            @("StartDate", "StartDate", "Date", "-", "Session start date."),
            @("EndDate", "EndDate", "Date", "-", "Session end date.")
        )
        Parents = @(
            "- ``AcademicTermId`` -> [AcademicTerm](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/AcademicTerm.md)"
        )
        Children = @(
            "- Course section offerings scheduled within this session"
        )
        Mermaid = "erDiagram`n    ACADEMIC_TERM ||--o{ ACADEMIC_SESSION : contains"
        Soql = "SELECT Id, Name, AcademicTerm.Name, StartDate, EndDate FROM AcademicSession LIMIT 10"
    },
    @{
        Name = "AcademicTermEnrollment"
        Label = "Academic Term Enrollment"
        Prefix = "13U"
        Type = "Standard Education Cloud Object"
        Module = "Student Registration & Records"
        Overview = "Records a learner's official matriculation and active registration status for a designated academic term."
        RecordTypes = "Standard term enrollment records."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Term enrollment identifier."),
            @("AcademicTermId", "AcademicTermId", "Lookup", "AcademicTerm", "The enrolled semester."),
            @("LearnerAccountId", "LearnerAccountId", "Lookup", "Account", "The student Person Account."),
            @("LearnerContactId", "LearnerContactId", "Lookup", "Contact", "The student Contact record."),
            @("OpportunityId", "OpportunityId", "Lookup", "Opportunity", "Associated financial or tuition billing opportunity."),
            @("EnrollmentStatus", "EnrollmentStatus", "Picklist", "-", "Enrolled, On Leave, Withdrawn, Graduated.")
        )
        Parents = @(
            "- ``AcademicTermId`` -> [AcademicTerm](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/AcademicTerm.md)",
            "- ``LearnerAccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md)",
            "- ``LearnerContactId`` -> [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md)"
        )
        Children = @(
            "- Course registration and attendance records"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ ACADEMIC_TERM_ENROLLMENT : student`n    ACADEMIC_TERM ||--o{ ACADEMIC_TERM_ENROLLMENT : semester"
        Soql = "SELECT Id, Name, LearnerAccount.Name, AcademicTerm.Name, EnrollmentStatus FROM AcademicTermEnrollment LIMIT 10"
    },
    @{
        Name = "AcademicCredential"
        Label = "Academic Credential"
        Prefix = "4ru"
        Type = "Standard Education Cloud Object"
        Module = "Curriculum & Conferred Degrees"
        Overview = "Defines degrees, diplomas, and official certifications issued by SUNY campuses (e.g., Bachelor of Science, Associate in Applied Science)."
        RecordTypes = "Standard credential types."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Official credential title."),
            @("IssuerId", "IssuerId", "Lookup", "Account", "The SUNY campus authorized to issue the credential."),
            @("CredentialType", "CredentialType", "Picklist", "-", "Associate, Bachelor, Master, Doctorate, Certificate.")
        )
        Parents = @(
            "- ``IssuerId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Issuing SUNY Campus)"
        )
        Children = @(
            "- ``PersonAcademicCredential.AcademicCredentialId`` -> Conferred student degree records",
            "- ``LearningAchievement.AcademicCredentialId`` -> Linked curriculum achievements"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ ACADEMIC_CREDENTIAL : confers`n    ACADEMIC_CREDENTIAL ||--o{ PERSON_ACADEMIC_CREDENTIAL : awarded_to"
        Soql = "SELECT Id, Name, Issuer.Name, CredentialType FROM AcademicCredential LIMIT 10"
    },
    @{
        Name = "Learning"
        Label = "Learning"
        Prefix = "13A"
        Type = "Standard Education Cloud Object"
        Module = "Curriculum Architecture"
        Overview = "The canonical foundation of Education Cloud curriculum. Serves as the abstract parent for all educational experiences, courses, and programs."
        RecordTypes = "Specialized via child records into LearningCourse and LearningProgram."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Name of the learning unit."),
            @("ProviderId", "ProviderId", "Lookup", "Account", "The SUNY campus providing instruction."),
            @("PreviousLearningVerId", "PreviousLearningVerId", "Lookup", "Learning", "Previous curriculum version for catalog tracking."),
            @("RevisedLearningVerId", "RevisedLearningVerId", "Lookup", "Learning", "Succeeding curriculum version.")
        )
        Parents = @(
            "- ``ProviderId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Campus)"
        )
        Children = @(
            "- ``LearningCourse.LearningId`` -> Course specialization",
            "- ``LearningProgram.LearningId`` -> Degree program specialization",
            "- ``LearningEquivalencyLearning.LearningId`` -> Credit transfer equivalency mappings"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ LEARNING : provides`n    LEARNING ||--|| LEARNING_COURSE : specializes`n    LEARNING ||--|| LEARNING_PROGRAM : specializes"
        Soql = "SELECT Id, Name, Provider.Name FROM Learning LIMIT 10"
    },
    @{
        Name = "LearningCourse"
        Label = "Learning Course"
        Prefix = "13B"
        Type = "Standard Education Cloud Object"
        Module = "Curriculum & Course Catalog"
        Overview = "Catalog definition of an individual course of study (e.g., Intro to Computer Science, Organic Chemistry I) offered by a SUNY institution."
        RecordTypes = "Standard course catalog units."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Course title and number (e.g., BIO 101)."),
            @("LearningId", "LearningId", "Master-Detail", "Learning", "Parent abstract learning record."),
            @("ProviderId", "ProviderId", "Lookup", "Account", "The SUNY college teaching the course."),
            @("Product2Id", "Product2Id", "Lookup", "Product2", "Product catalog link for billing."),
            @("CreditHours", "CreditHours", "Number", "-", "Instructional credit hours awarded.")
        )
        Parents = @(
            "- ``LearningId`` -> [Learning](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Learning.md) (Master-Detail parent)",
            "- ``ProviderId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Campus)"
        )
        Children = @(
            "- Course section offerings and schedule templates"
        )
        Mermaid = "erDiagram`n    LEARNING ||--|| LEARNING_COURSE : master_detail`n    ACCOUNT ||--o{ LEARNING_COURSE : provides"
        Soql = "SELECT Id, Name, Learning.Name, Provider.Name FROM LearningCourse LIMIT 10"
    },
    @{
        Name = "LearningProgram"
        Label = "Learning Program"
        Prefix = "13C"
        Type = "Standard Education Cloud Object"
        Module = "Curriculum & Academic Majors"
        Overview = "Represents formal academic majors, degree programs, and certificates (e.g., B.S. in Electrical Engineering, M.B.A.) offered by SUNY."
        RecordTypes = "Undergraduate Degree, Graduate Degree, Advanced Certificate."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Program title (e.g., B.S. in Cybersecurity)."),
            @("LearningId", "LearningId", "Master-Detail", "Learning", "Parent abstract learning record."),
            @("ProviderId", "ProviderId", "Lookup", "Account", "The SUNY campus offering the degree."),
            @("Product2Id", "Product2Id", "Lookup", "Product2", "Product catalog link.")
        )
        Parents = @(
            "- ``LearningId`` -> [Learning](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Learning.md) (Master-Detail parent)",
            "- ``ProviderId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Campus)"
        )
        Children = @(
            "- ``LearningProgramPlan.LearningProgramId`` -> Curriculum plans / catalog years",
            "- ``ProgramTermApplnTimeline.LearningProgramId`` -> Admissions application intake periods"
        )
        Mermaid = "erDiagram`n    LEARNING ||--|| LEARNING_PROGRAM : master_detail`n    LEARNING_PROGRAM ||--o{ LEARNING_PROGRAM_PLAN : defines`n    LEARNING_PROGRAM ||--o{ PROGRAM_TERM_APPLN_TIMELINE : schedules"
        Soql = "SELECT Id, Name, Learning.Name, Provider.Name FROM LearningProgram LIMIT 10"
    },
    @{
        Name = "LearningProgramPlan"
        Label = "Learning Program Plan"
        Prefix = "13D"
        Type = "Standard Education Cloud Object"
        Module = "Curriculum Plans & Catalog Years"
        Overview = "Defines the degree plan structure and graduation requirement rules for a specific catalog year (e.g. 2025-2026 CS Curriculum Plan)."
        RecordTypes = "Standard program plans."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Plan name (e.g., 2025-2026 BSCS Degree Plan)."),
            @("LearningProgramId", "LearningProgramId", "Master-Detail", "LearningProgram", "Parent degree program."),
            @("ProviderId", "ProviderId", "Lookup", "Account", "The providing SUNY institution."),
            @("TotalCreditsRequired", "TotalCreditsRequired", "Number", "-", "Minimum credits required to confer degree.")
        )
        Parents = @(
            "- ``LearningProgramId`` -> [LearningProgram](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/LearningProgram.md)",
            "- ``ProviderId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md)"
        )
        Children = @(
            "- ``LearningProgramPlanRqmt.LearningProgramPlanId`` -> Specific course and credit rules",
            "- ``ProgramTermApplnTimeline.LearningProgramPlanId`` -> Intake cycles"
        )
        Mermaid = "erDiagram`n    LEARNING_PROGRAM ||--o{ LEARNING_PROGRAM_PLAN : contains`n    LEARNING_PROGRAM_PLAN ||--o{ LEARNING_PROGRAM_PLAN_RQMT : details"
        Soql = "SELECT Id, Name, LearningProgram.Name, Provider.Name FROM LearningProgramPlan LIMIT 10"
    },
    @{
        Name = "LearningProgramPlanRqmt"
        Label = "Learning Program Plan Requirement"
        Prefix = "13E"
        Type = "Standard Education Cloud Object"
        Module = "Degree Audit & Requirements"
        Overview = "Atomic graduation requirement rule within a program plan (e.g., General Education Mathematics requirement, Major Core Courses, Senior Capstone)."
        RecordTypes = "Standard requirement nodes."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Requirement name (e.g., Math Core Requirements)."),
            @("LearningProgramPlanId", "LearningProgramPlanId", "Master-Detail", "LearningProgramPlan", "Parent degree plan."),
            @("LearningAchievementId", "LearningAchievementId", "Lookup", "LearningAchievement", "Associated achievement/competency granted."),
            @("ReusableLearningProgramPlanId", "ReusableLearningProgramPlanId", "Lookup", "LearningProgramPlan", "Shared plan block."),
            @("CreditsRequired", "CreditsRequired", "Number", "-", "Credit threshold required.")
        )
        Parents = @(
            "- ``LearningProgramPlanId`` -> [LearningProgramPlan](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/LearningProgramPlan.md)",
            "- ``LearningAchievementId`` -> [LearningAchievement](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/LearningAchievement.md)"
        )
        Children = @(
            "- ``LearningPathwayTemplateItem.LearningProgramPlanRequirementId`` -> Pathway roadmap links"
        )
        Mermaid = "erDiagram`n    LEARNING_PROGRAM_PLAN ||--o{ LEARNING_PROGRAM_PLAN_RQMT : specifies`n    LEARNING_ACHIEVEMENT ||--o{ LEARNING_PROGRAM_PLAN_RQMT : satisfies"
        Soql = "SELECT Id, Name, LearningProgramPlan.Name, LearningAchievement.Name FROM LearningProgramPlanRqmt LIMIT 10"
    },
    @{
        Name = "LearningAchievement"
        Label = "Learning Achievement"
        Prefix = "13H"
        Type = "Standard Education Cloud Object"
        Module = "Student Competencies & Milestones"
        Overview = "Milestones, certificates, digital badges, and competencies earned by learners upon completing learning requirements."
        RecordTypes = "Standard achievement types."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Achievement label (e.g., Dean's Honors, Micro-credential)."),
            @("IssuerId", "IssuerId", "Lookup", "Account", "The conferring SUNY campus."),
            @("AcademicCredentialId", "AcademicCredentialId", "Lookup", "AcademicCredential", "Formal degree credential link.")
        )
        Parents = @(
            "- ``IssuerId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md)",
            "- ``AcademicCredentialId`` -> [AcademicCredential](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/AcademicCredential.md)"
        )
        Children = @(
            "- ``LearningProgramPlanRqmt.LearningAchievementId`` -> Plan requirement satisfactions"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ LEARNING_ACHIEVEMENT : issues`n    ACADEMIC_CREDENTIAL ||--o{ LEARNING_ACHIEVEMENT : confers"
        Soql = "SELECT Id, Name, Issuer.Name, AcademicCredential.Name FROM LearningAchievement LIMIT 10"
    },
    @{
        Name = "LearningPathwayTemplate"
        Label = "Learning Pathway Template"
        Prefix = "13J"
        Type = "Standard Education Cloud Object"
        Module = "Degree Roadmaps & Academic Pathways"
        Overview = "Master template defining semester-by-semester roadmaps for degree completion to guide students and academic advisors."
        RecordTypes = "Standard pathway templates."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Pathway roadmap name (e.g., 4-Year B.S. in Biology Roadmap)."),
            @("Description", "Description", "Text(255)", "-", "Guidance details for advisors and learners.")
        )
        Parents = @(
            "- Independent master template"
        )
        Children = @(
            "- ``LearningPathwayTemplateItem.LearningPathwayTemplateId`` -> Ordered steps in roadmap"
        )
        Mermaid = "erDiagram`n    LEARNING_PATHWAY_TEMPLATE ||--o{ LEARNING_PATHWAY_TEMPLATE_ITEM : sequence"
        Soql = "SELECT Id, Name, Description FROM LearningPathwayTemplate LIMIT 10"
    },
    @{
        Name = "LearningPathwayTemplateItem"
        Label = "Learning Pathway Template Item"
        Prefix = "13K"
        Type = "Standard Education Cloud Object"
        Module = "Degree Roadmaps & Academic Pathways"
        Overview = "Specific sequential milestone or course recommendation within a Learning Pathway Template (e.g., Term 1: Take MAT 101 and ENG 101)."
        RecordTypes = "Standard pathway items."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Item designation."),
            @("LearningPathwayTemplateId", "LearningPathwayTemplateId", "Master-Detail", "LearningPathwayTemplate", "Parent roadmap template."),
            @("LearningProgramPlanRequirementId", "LearningProgramPlanRequirementId", "Lookup", "LearningProgramPlanRqmt", "Satisfied graduation requirement."),
            @("LearningId", "LearningId", "Lookup", "Learning", "Recommended course or learning unit.")
        )
        Parents = @(
            "- ``LearningPathwayTemplateId`` -> [LearningPathwayTemplate](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/LearningPathwayTemplate.md)",
            "- ``LearningProgramPlanRequirementId`` -> [LearningProgramPlanRqmt](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/LearningProgramPlanRqmt.md)",
            "- ``LearningId`` -> [Learning](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Learning.md)"
        )
        Children = @(
            "- Sequence elements within template"
        )
        Mermaid = "erDiagram`n    LEARNING_PATHWAY_TEMPLATE ||--o{ LEARNING_PATHWAY_TEMPLATE_ITEM : contains`n    LEARNING ||--o{ LEARNING_PATHWAY_TEMPLATE_ITEM : prescribes"
        Soql = "SELECT Id, Name, LearningPathwayTemplate.Name, Learning.Name FROM LearningPathwayTemplateItem LIMIT 10"
    },
    @{
        Name = "LearningEquivalency"
        Label = "Learning Equivalency"
        Prefix = "13M"
        Type = "Standard Education Cloud Object"
        Module = "Transfer Credit & Articulation Agreements"
        Overview = "Crucial for SUNY seamless transfer mobility. Represents formal articulation agreements establishing that courses taken at one institution count toward courses at another SUNY campus."
        RecordTypes = "Course-to-course, Program-to-program, General Education block articulation."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Articulation agreement name (e.g., SUNY Transfer Articulation: MAT 101 -> MAT 120)."),
            @("Description", "Description", "Text(255)", "-", "Terms of credit transfer.")
        )
        Parents = @(
            "- Articulation header"
        )
        Children = @(
            "- ``LearningEquivalencyLearning.LearningEquivalencyId`` -> Courses mapped in articulation"
        )
        Mermaid = "erDiagram`n    LEARNING_EQUIVALENCY ||--o{ LEARNING_EQUIVALENCY_LEARNING : details"
        Soql = "SELECT Id, Name, Description FROM LearningEquivalency LIMIT 10"
    },
    @{
        Name = "LearningEquivalencyLearning"
        Label = "Learning Equivalency Learning"
        Prefix = "13O"
        Type = "Standard Education Cloud Object"
        Module = "Transfer Credit & Articulation Agreements"
        Overview = "Junction object connecting a Learning Equivalency agreement with the specific source and target Learning courses."
        RecordTypes = "Standard junction records."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Mapping record identifier."),
            @("LearningEquivalencyId", "LearningEquivalencyId", "Master-Detail", "LearningEquivalency", "Parent transfer articulation agreement."),
            @("LearningId", "LearningId", "Lookup", "Learning", "The course involved in the transfer articulation.")
        )
        Parents = @(
            "- ``LearningEquivalencyId`` -> [LearningEquivalency](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/LearningEquivalency.md)",
            "- ``LearningId`` -> [Learning](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Learning.md)"
        )
        Children = @(
            "- Junction entries"
        )
        Mermaid = "erDiagram`n    LEARNING_EQUIVALENCY ||--o{ LEARNING_EQUIVALENCY_LEARNING : joins`n    LEARNING ||--o{ LEARNING_EQUIVALENCY_LEARNING : maps"
        Soql = "SELECT Id, Name, LearningEquivalency.Name, Learning.Name FROM LearningEquivalencyLearning LIMIT 10"
    },
    @{
        Name = "PersonEducation"
        Label = "Person Education"
        Prefix = "0d5"
        Type = "Standard Education Cloud Object"
        Module = "Student Academic History & Transcripts"
        Overview = "Stores a learner's prior educational background, including previous high schools, community colleges, degrees awarded, cumulative GPAs, and official transcripts."
        RecordTypes = "Secondary Education, Higher Education, Vocational."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Educational history identifier."),
            @("AccountId", "AccountId", "Lookup", "Account", "The student Person Account."),
            @("ContactId", "ContactId", "Lookup", "Contact", "The student Contact."),
            @("InstitutionAccountId", "InstitutionAccountId", "Lookup", "Account", "The prior school or college institution."),
            @("IndividualApplicationId", "IndividualApplicationId", "Lookup", "IndividualApplication", "Associated application submission."),
            @("GraduationDate", "GraduationDate", "Date", "-", "Graduation or expected completion date."),
            @("Gpa", "Gpa", "Number(3,2)", "-", "Cumulative Grade Point Average.")
        )
        Parents = @(
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Student Person Account)",
            "- ``InstitutionAccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Prior School)",
            "- ``IndividualApplicationId`` -> [IndividualApplication](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/IndividualApplication.md)"
        )
        Children = @(
            "- Academic credential verification items"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ PERSON_EDUCATION : learner`n    ACCOUNT ||--o{ PERSON_EDUCATION : attended_school`n    INDIVIDUAL_APPLICATION ||--o{ PERSON_EDUCATION : attached_to"
        Soql = "SELECT Id, Account.Name, InstitutionAccount.Name, Gpa, GraduationDate FROM PersonEducation LIMIT 10"
    },
    @{
        Name = "PersonEmployment"
        Label = "Person Employment"
        Prefix = "0ck"
        Type = "Standard Education Cloud Object"
        Module = "Learner Work History & Career"
        Overview = "Tracks a learner's employment records, internships, corporate apprenticeships, and military service."
        RecordTypes = "Standard work experience."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Position or role title."),
            @("RelatedPersonId", "RelatedPersonId", "Lookup", "Account, Contact, Applicant", "The learner holding the position."),
            @("AccountId", "AccountId", "Lookup", "Account", "Employer Account."),
            @("StartDate", "StartDate", "Date", "-", "Employment start date."),
            @("EndDate", "EndDate", "Date", "-", "Employment end date.")
        )
        Parents = @(
            "- ``RelatedPersonId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) / [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md)",
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Employer)"
        )
        Children = @(
            "- Internship evaluations and career outcomes"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ PERSON_EMPLOYMENT : learner`n    ACCOUNT ||--o{ PERSON_EMPLOYMENT : employer"
        Soql = "SELECT Id, Name, RelatedPersonId, Account.Name, StartDate, EndDate FROM PersonEmployment LIMIT 10"
    },
    @{
        Name = "PersonExamination"
        Label = "Person Examination"
        Prefix = "0d4"
        Type = "Standard Education Cloud Object"
        Module = "Testing & Standardized Scores"
        Overview = "Records standardized test scores (SAT, ACT, GRE, GMAT, TOEFL, IELTS, AP tests) submitted by an applicant for admissions evaluation."
        RecordTypes = "Admissions Testing, Language Proficiency, Professional Licensure."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Examination record name."),
            @("AccountId", "AccountId", "Lookup", "Account", "The student Person Account."),
            @("ContactId", "ContactId", "Lookup", "Contact", "The student Contact."),
            @("ExaminationId", "ExaminationId", "Lookup", "Examination", "The test type definition."),
            @("IndividualApplicationId", "IndividualApplicationId", "Lookup", "IndividualApplication", "The application requiring the test score."),
            @("ScoreDate", "ScoreDate", "Date", "-", "Date examination was administered.")
        )
        Parents = @(
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) (Student Person Account)",
            "- ``IndividualApplicationId`` -> [IndividualApplication](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/IndividualApplication.md)"
        )
        Children = @(
            "- Sub-score components (e.g. SAT Math, SAT Reading)"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ PERSON_EXAMINATION : student`n    INDIVIDUAL_APPLICATION ||--o{ PERSON_EXAMINATION : submits_score"
        Soql = "SELECT Id, Name, Account.Name, ScoreDate, IndividualApplication.Name FROM PersonExamination LIMIT 10"
    },
    @{
        Name = "PersonAcademicCredential"
        Label = "Person Academic Credential"
        Prefix = "4rv"
        Type = "Standard Education Cloud Object"
        Module = "Conferred Student Degrees"
        Overview = "Junction linking an individual learner with an Academic Credential conferred upon graduation by a SUNY campus."
        RecordTypes = "Conferred degrees and certificates."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Credential record name."),
            @("LearnerContactId", "LearnerContactId", "Lookup", "Contact", "Student Contact receiving the degree."),
            @("AcademicCredentialId", "AcademicCredentialId", "Lookup", "AcademicCredential", "The credential awarded."),
            @("ConferredDate", "ConferredDate", "Date", "-", "Graduation/conferral date.")
        )
        Parents = @(
            "- ``LearnerContactId`` -> [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md)",
            "- ``AcademicCredentialId`` -> [AcademicCredential](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/AcademicCredential.md)"
        )
        Children = @(
            "- Degree audit validation records"
        )
        Mermaid = "erDiagram`n    CONTACT ||--o{ PERSON_ACADEMIC_CREDENTIAL : recipient`n    ACADEMIC_CREDENTIAL ||--o{ PERSON_ACADEMIC_CREDENTIAL : awarded"
        Soql = "SELECT Id, Name, LearnerContact.Name, AcademicCredential.Name FROM PersonAcademicCredential LIMIT 10"
    },
    @{
        Name = "PersonLanguage"
        Label = "Person Language"
        Prefix = "0d6"
        Type = "Standard Education Cloud Object"
        Module = "Learner Profile & Multilingual Skills"
        Overview = "Records languages spoken, written, and read by learners, along with proficiency ratings (Native, Fluent, Professional)."
        RecordTypes = "Standard language proficiencies."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Language name (e.g., Spanish, Mandarin)."),
            @("IndividualId", "IndividualId", "Master-Detail", "Account, Contact", "The learner possessing the language proficiency."),
            @("SpeakingProficiency", "SpeakingProficiency", "Picklist", "-", "Spoken fluency level."),
            @("WritingProficiency", "WritingProficiency", "Picklist", "-", "Written fluency level.")
        )
        Parents = @(
            "- ``IndividualId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) / [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md)"
        )
        Children = @(
            "- Language validation certificates"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ PERSON_LANGUAGE : speaks"
        Soql = "SELECT Id, Name, IndividualId, SpeakingProficiency, WritingProficiency FROM PersonLanguage LIMIT 10"
    },
    @{
        Name = "PersonDisability"
        Label = "Person Disability"
        Prefix = "0d7"
        Type = "Standard Education Cloud Object"
        Module = "Campus Accessibility & Accommodations"
        Overview = "Securely manages student disability disclosures and requested academic accommodations (e.g., extra exam time, assistive hearing devices, note-takers)."
        RecordTypes = "Academic Accommodation, Mobility Accommodation, Visual/Audio."
        Fields = @(
            @("Name", "Name", "Text(255)", "-", "Disability or accommodation designation."),
            @("IndividualId", "IndividualId", "Lookup", "Account, Contact", "The student requesting accommodations."),
            @("AccommodationStatus", "AccommodationStatus", "Picklist", "-", "Requested, Approved, Active, Expired."),
            @("ApprovedDate", "ApprovedDate", "Date", "-", "Date campus accessibility office approved accommodation.")
        )
        Parents = @(
            "- ``IndividualId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md) / [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md)"
        )
        Children = @(
            "- Accommodation service delivery plans"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ PERSON_DISABILITY : requests_accommodation"
        Soql = "SELECT Id, Name, IndividualId, AccommodationStatus FROM PersonDisability LIMIT 10"
    },
    @{
        Name = "Case"
        Label = "Case"
        Prefix = "500"
        Type = "Standard Object"
        Module = "Student Support & Academic Advising"
        Overview = "Used across SUNY campuses for student support tickets, academic advising cases, registrar inquiries, financial aid appeals, and IT helpdesk requests."
        RecordTypes = "Inquiry, Academic Advising, Financial Aid, Accessibility Services."
        Fields = @(
            @("CaseNumber", "CaseNumber", "AutoNumber", "-", "Unique case tracking number."),
            @("Subject", "Subject", "Text(255)", "-", "Summary description of student request."),
            @("AccountId", "AccountId", "Lookup", "Account", "The student or institutional account."),
            @("ContactId", "ContactId", "Lookup", "Contact", "Contact submitting the ticket."),
            @("Status", "Status", "Picklist", "-", "New, Working, Escalated, Closed."),
            @("Priority", "Priority", "Picklist", "-", "Low, Medium, High, Urgent."),
            @("Origin", "Origin", "Picklist", "-", "Web, Email, Campus Portal, In Person.")
        )
        Parents = @(
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md)",
            "- ``ContactId`` -> [Contact](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Contact.md)"
        )
        Children = @(
            "- ``IndividualApplication.ApplicationCaseId`` -> Linked admissions inquiries"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ CASE : files`n    CONTACT ||--o{ CASE : requests"
        Soql = "SELECT CaseNumber, Subject, Status, Priority, Account.Name FROM Case ORDER BY CreatedDate DESC LIMIT 10"
    },
    @{
        Name = "Lead"
        Label = "Lead"
        Prefix = "00Q"
        Type = "Standard Object"
        Module = "Recruitment & Prospective Learners"
        Overview = "Captures prospective learners before an application is submitted, gathered from college recruitment fairs, online RFI forms, and outreach campaigns."
        RecordTypes = "Undergraduate Prospect, Transfer Prospect, Graduate Prospect."
        Fields = @(
            @("Name", "Name", "Text(121)", "-", "Prospective student full name."),
            @("Email", "Email", "Email", "-", "Contact email address."),
            @("Phone", "Phone", "Phone", "-", "Contact phone number."),
            @("Company", "Company", "Text(255)", "-", "Current high school or institution attended."),
            @("Status", "Status", "Picklist", "-", "Open, Contacted, Qualified, Unqualified."),
            @("LeadSource", "LeadSource", "Picklist", "-", "College Fair, Website RFI, High School Visit.")
        )
        Parents = @(
            "- Top of admissions funnel"
        )
        Children = @(
            "- Converts into Account, Contact, and Opportunity"
        )
        Mermaid = "erDiagram`n    LEAD ||--o| ACCOUNT : converts_to`n    LEAD ||--o| CONTACT : converts_to"
        Soql = "SELECT Id, Name, Email, Status, LeadSource FROM Lead ORDER BY CreatedDate DESC LIMIT 10"
    },
    @{
        Name = "Opportunity"
        Label = "Opportunity"
        Prefix = "006"
        Type = "Standard Object"
        Module = "Financial Aid, Grants & Enrollment Pipeline"
        Overview = "Tracks institutional fundraising, research grants, corporate sponsorships, and tuition/financial aid pipeline conversions."
        RecordTypes = "Grant Funding, Corporate Partnership, Enrollment Pipeline."
        Fields = @(
            @("Name", "Name", "Text(120)", "-", "Opportunity title (e.g., NSF Research Grant 2026)."),
            @("AccountId", "AccountId", "Lookup", "Account", "The corporate sponsor, donor, or campus account."),
            @("StageName", "StageName", "Picklist", "-", "Prospecting, Proposal Sent, Negotiation, Closed Won."),
            @("Amount", "Amount", "Currency", "-", "Dollar value of grant, tuition, or gift."),
            @("CloseDate", "CloseDate", "Date", "-", "Projected award or closing date.")
        )
        Parents = @(
            "- ``AccountId`` -> [Account](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/objects/Account.md)"
        )
        Children = @(
            "- ``IndividualApplication.OpportunityId`` -> Linked admissions pipeline",
            "- ``AcademicTermEnrollment.OpportunityId`` -> Term billing opportunity"
        )
        Mermaid = "erDiagram`n    ACCOUNT ||--o{ OPPORTUNITY : sponsors`n    OPPORTUNITY ||--o{ INDIVIDUAL_APPLICATION : tracks"
        Soql = "SELECT Id, Name, Account.Name, StageName, Amount, CloseDate FROM Opportunity LIMIT 10"
    },
    @{
        Name = "In_App_Checklist_Settings__c"
        Label = "In App Checklist Settings"
        Prefix = "a00"
        Type = "Hierarchy Custom Setting"
        Module = "System Configuration & User Guidance"
        Overview = "Protected hierarchy custom setting storing user onboarding guidance, checklists, and in-app walkthrough target URLs mapped to profile keys."
        RecordTypes = "Hierarchy Custom Setting (Organization -> Profile -> User)."
        Fields = @(
            @("Name", "Name", "Text(80)", "-", "Custom setting entry label."),
            @("SetupOwnerId", "SetupOwnerId", "Lookup", "Org, Profile, User", "Hierarchy level assignment."),
            @("ProfileKey__c", "ProfileKey__c", "Text(255)", "-", "Profile key identifier used to resolve targeted checklist rules."),
            @("Sales_Cloud_In_App_Page__c", "Sales_Cloud_In_App_Page__c", "URL(255)", "-", "Direct URL to the In-App guidance page.")
        )
        Parents = @(
            "- ``SetupOwnerId`` -> System Organization, Profile, or User"
        )
        Children = @(
            "- Global user guidance resolution"
        )
        Mermaid = "erDiagram`n    USER ||--o| IN_APP_CHECKLIST_SETTINGS : resolves_at_user_level`n    PROFILE ||--o| IN_APP_CHECKLIST_SETTINGS : resolves_at_profile_level"
        Soql = "SELECT Id, Name, SetupOwnerId, ProfileKey__c, Sales_Cloud_In_App_Page__c FROM In_App_Checklist_Settings__c LIMIT 10"
    }
)

$ticks = "```"

foreach ($obj in $schemaData) {
    $name = $obj.Name
    $label = $obj.Label
    $prefix = $obj.Prefix
    $type = $obj.Type
    $module = $obj.Module
    $overview = $obj.Overview
    $recordTypes = $obj.RecordTypes
    $soql = $obj.Soql
    $mermaid = $obj.Mermaid
    
    $filePath = Join-Path $objectsDir "$name.md"
    
    $fieldsRows = ""
    foreach ($f in $obj.Fields) {
        $fLabel = $f[0]
        $fApi = $f[1]
        $fType = $f[2]
        $fRef = $f[3]
        $fDesc = $f[4]
        $fieldsRows += "| **$fLabel** | ``$fApi`` | $fType | $fRef | $fDesc |`n"
    }
    
    $parentsText = ($obj.Parents -join "`n")
    $childrenText = ($obj.Children -join "`n")
    
    $content = @"
# $label (`$name`)

**Object Type**: $type  
**Key Prefix**: `$prefix`  
**Module / Cloud**: $module  
**Metadata Definition**: [`force-app/main/default/objects/$name/`](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/force-app/main/default/objects/$name/)

---

## 1. Overview & Role in SUNY

$overview

---

## 2. Record Types & Architectural Setup

$recordTypes

---

## 3. Key Fields Specification

| Field Label | API Name | Data Type | Reference / Target | Description |
| :--- | :--- | :--- | :--- | :--- |
$fieldsRows
---

## 4. Entity Relationships & Data Flow

${ticks}mermaid
$mermaid
$ticks

### Outbound Relationships (Parent References)
$parentsText

### Inbound Relationships (Child Records)
$childrenText

---

## 5. Sample SOQL Query

${ticks}sql
$soql
$ticks

---
[Return to Master Object Schema Directory](file:///d:/SUNY_COMMON_DEV/SUNY_COMMON_DEV/docs/object_schema.md)
"@
    Set-Content -Path $filePath -Value $content -Encoding UTF8
}

Write-Output "Regenerated all schema documentation files cleanly."
