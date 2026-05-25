public with sharing class AcknowledgeButtonController {
    
    @AuraEnabled
    public static Boolean acknowledgePolicy(Id recordId) {
        PolicyGuideline__c policy = [
            SELECT Id, Acknowledged_Users__c 
            FROM PolicyGuideline__c 
            WHERE Id = :recordId 
            LIMIT 1
        ];
        
        String currentUserId = UserInfo.getUserId();
        List<String> users = new List<String>();
        
        if(String.isNotBlank(policy.Acknowledged_Users__c)) {
            users = policy.Acknowledged_Users__c.split(',');
        }
        
        if(!users.contains(currentUserId)) {
            users.add(currentUserId);
            policy.Acknowledged_Users__c = String.join(users, ',');
            update policy;
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static Boolean checkAcknowledged(Id recordId) {
        PolicyGuideline__c policy = [
            SELECT Id, Acknowledged_Users__c 
            FROM PolicyGuideline__c 
            WHERE Id = :recordId 
            LIMIT 1
        ];
        
        String currentUserId = UserInfo.getUserId();
        if(String.isNotBlank(policy.Acknowledged_Users__c)) {
            List<String> users = policy.Acknowledged_Users__c.split(',');
            return users.contains(currentUserId);
        }
        return false;
    }
}