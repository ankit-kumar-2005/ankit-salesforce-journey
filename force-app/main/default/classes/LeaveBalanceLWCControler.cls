public with sharing class LeaveBalanceLWCControler {
    @AuraEnabled(cacheable=true)
    public static Leave_Balance__c getLeaveBalanceForCurrentUser() {
        List<Employee__c> emps = [
            SELECT Id
            FROM Employee__c
            WHERE Related_User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        if (emps.isEmpty()) return null;
        List<Leave_Balance__c> balances = [
            SELECT Id, Leave_Balance__c
            FROM Leave_Balance__c
            WHERE Employee__c = :emps[0].Id
            LIMIT 1
        ];
        if (balances.isEmpty()) return null;
        return balances[0];
    }
}