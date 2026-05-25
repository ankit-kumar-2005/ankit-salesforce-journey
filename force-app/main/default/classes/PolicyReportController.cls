/* Apex Controller for Policy Report Component
 * Generates policy acknowledgment reports with counts
 */
public with sharing class PolicyReportController {
   
    /**
     * Wrapper class for policy report data
     */
    public class PolicyReportWrapper {
        @AuraEnabled public String policyId { get; set; }
        @AuraEnabled public String policyName { get; set; }
        @AuraEnabled public Integer acknowledgedCount { get; set; }
        @AuraEnabled public Integer pendingCount { get; set; }
       
        public PolicyReportWrapper(String policyId, String policyName, Integer acknowledgedCount, Integer pendingCount) {
            this.policyId = policyId;
            this.policyName = policyName;
            this.acknowledgedCount = acknowledgedCount;
            this.pendingCount = pendingCount;
        }
    }
   
    /**
     * Response wrapper for the report data
     */
    public class ReportResponseWrapper {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public List<PolicyReportWrapper> reportData { get; set; }
       
        public ReportResponseWrapper() {
            this.success = false;
            this.reportData = new List<PolicyReportWrapper>();
        }
    }
   
    /**
     * Get policy report data with acknowledgment counts
     * @return ReportResponseWrapper containing policy data with counts
     */
    @AuraEnabled
    public static ReportResponseWrapper getPolicyReportData() {
        ReportResponseWrapper response = new ReportResponseWrapper();
       
        try {
            System.debug('getPolicyReportData called');
           
            // Get all policies
            List<PolicyGuideline__c> policies = [
                SELECT Id, Name, CreatedDate
                FROM PolicyGuideline__c
                ORDER BY Name ASC
            ];
           
            System.debug('Found ' + policies.size() + ' policies');
           
            // Get total employee count
            Integer totalEmployeeCount = [
                SELECT COUNT()
                FROM Employee__c
                WHERE Related_User__c != null
            ];
           
            System.debug('Total employees with users: ' + totalEmployeeCount);
           
            // If no employees, all policies have 0 acknowledged and 0 pending
            if (totalEmployeeCount == 0) {
                for (PolicyGuideline__c policy : policies) {
                    response.reportData.add(new PolicyReportWrapper(
                        policy.Id,
                        policy.Name,
                        0,
                        0
                    ));
                }
                response.success = true;
                response.message = 'No employees found in the system.';
                return response;
            }
           
            // Get acknowledgment counts for each policy
            Map<Id, Integer> policyAcknowledgmentCounts = new Map<Id, Integer>();
           
            // Query all acknowledgments grouped by policy
            List<AggregateResult> acknowledgmentResults = [
                SELECT Policy__c, COUNT(Id) acknowledgedCount
                FROM 	PolicyGuidelineAndUser__c
                GROUP BY Policy__c
            ];
           
            System.debug('Found acknowledgment data for ' + acknowledgmentResults.size() + ' policies');
           
            // Build map of policy ID to acknowledged count
            for (AggregateResult result : acknowledgmentResults) {
                Id policyId = (Id) result.get('Policy__c');
                Integer acknowledgedCount = (Integer) result.get('acknowledgedCount');
                policyAcknowledgmentCounts.put(policyId, acknowledgedCount);
                System.debug('Policy ' + policyId + ' has ' + acknowledgedCount + ' acknowledgments');
            }
           
            // Build report data
            for (PolicyGuideline__c policy : policies) {
                Integer acknowledgedCount = policyAcknowledgmentCounts.containsKey(policy.Id)
                    ? policyAcknowledgmentCounts.get(policy.Id)
                    : 0;
                   
                Integer pendingCount = totalEmployeeCount - acknowledgedCount;
               
                // Ensure pending count is not negative (edge case handling)
                if (pendingCount < 0) {
                    pendingCount = 0;
                }
               
                response.reportData.add(new PolicyReportWrapper(
                    policy.Id,
                    policy.Name,
                    acknowledgedCount,
                    pendingCount
                ));
               
                System.debug('Policy: ' + policy.Name +
                           ' | Acknowledged: ' + acknowledgedCount +
                           ' | Pending: ' + pendingCount);
            }
           
            response.success = true;
            System.debug('Report data generated successfully with ' + response.reportData.size() + ' records');
           
        } catch (Exception e) {
            System.debug('Error in getPolicyReportData: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            response.message = 'An error occurred while generating the report: ' + e.getMessage();
        }
       
        return response;
    }
}