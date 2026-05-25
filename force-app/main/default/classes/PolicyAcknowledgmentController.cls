public with sharing class PolicyAcknowledgmentController {
   
    public class ResponseWrapper {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public PolicyGuideline__c policyRecord;
        @AuraEnabled public Boolean isAcknowledged;
        @AuraEnabled public String acknowledgmentDate;
       
        public ResponseWrapper() {
            this.success = false;
            this.isAcknowledged = false;
        }
    }
   
    @AuraEnabled
    public static ResponseWrapper getPolicyDataAndStatus(String policyId) {
        ResponseWrapper response = new ResponseWrapper();
       
        try {
            if (String.isBlank(policyId)) {
                response.message = 'Policy ID is required.';
                return response;
            }
           
            // Get policy record
            List<PolicyGuideline__c> policies = [
                SELECT Id, Name FROM PolicyGuideline__c WHERE Id = :policyId LIMIT 1
            ];
           
            if (policies.isEmpty()) {
                response.message = 'Policy record not found.';
                return response;
            }
           
            response.policyRecord = policies[0];
           
            // Find employee record for current user
            List<Employee__c> employees = [
                SELECT Id FROM Employee__c WHERE Related_User__c = :UserInfo.getUserId() LIMIT 1
            ];
           
            if (employees.isEmpty()) {
                response.message = 'No employee record found. Please contact your administrator.';
                return response;
            }
           
            // Check if acknowledgment exists
            List<PolicyGuidelineAndUser__c> acknowledgments = [
                SELECT CreatedDate FROM PolicyGuidelineAndUser__c
                WHERE Employee__c = :employees[0].Id AND Policy__c = :policyId LIMIT 1
            ];
           
            if (!acknowledgments.isEmpty()) {
                response.isAcknowledged = true;
                response.acknowledgmentDate = acknowledgments[0].CreatedDate.format('MMM dd, yyyy HH:mm');
            }
           
            response.success = true;
           
        } catch (Exception e) {
            response.message = 'Error loading policy data: ' + e.getMessage();
        }
       
        return response;
    }
   
    @AuraEnabled
    public static ResponseWrapper createPolicyAcknowledgment(String policyId) {
        ResponseWrapper response = new ResponseWrapper();
       
        try {
            if (String.isBlank(policyId)) {
                response.message = 'Policy ID is required.';
                return response;
            }
           
            // Find employee record
            List<Employee__c> employees = [
                SELECT Id FROM Employee__c WHERE Related_User__c = :UserInfo.getUserId() LIMIT 1
            ];
           
            if (employees.isEmpty()) {
                response.message = 'No employee record found.';
                return response;
            }
           
            // Check if already acknowledged
            if ([SELECT COUNT() FROM PolicyGuidelineAndUser__c
                 WHERE Employee__c = :employees[0].Id AND Policy__c = :policyId] > 0) {
                response.message = 'Policy already acknowledged.';
                return response;
            }
           
            // Create acknowledgment
            PolicyGuidelineAndUser__c newAcknowledgment = new PolicyGuidelineAndUser__c(
                Employee__c = employees[0].Id,
                Policy__c = policyId
            );
           
            insert newAcknowledgment;
           
            response.success = true;
            response.isAcknowledged = true;
            response.acknowledgmentDate = Datetime.now().format('MMM dd, yyyy HH:mm');
            response.message = 'Policy acknowledged successfully.';
           
        } catch (Exception e) {
            response.message = 'Error creating acknowledgment: ' + e.getMessage();
        }
       
        return response;
    }
}