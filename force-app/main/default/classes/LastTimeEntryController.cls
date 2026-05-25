public with sharing class LastTimeEntryController {
     @AuraEnabled(cacheable=true)
    public static List<Time_Entry__c> getLastFiveDaysEntries() {
        Date today = Date.today();
        Date fiveDaysAgo = Date.today().addDays(-4);
        Id currentUserId = UserInfo.getUserId();
        Employee__c empObj = [SELECT Id FROM Employee__c WHERE Related_User__c = :currentUserId LIMIT 1]; 
        List<Time_Entry__c> entries = [
            SELECT Id, Date__c, Total_Hours__c
            FROM Time_Entry__c
            WHERE Date__c >= :fiveDaysAgo
              AND Date__c <= :today
              AND Employee_Name_E__c = :empObj.Id 
            ORDER BY Date__c DESC
            LIMIT 5
        ];
        if(!entries.isEmpty()){
            return entries;
        }else {
            return null;
        }
        
    }
}