/*
@Name:PolicyGuideline Record Sharing
@Author:Ankit Kumar
@Description::PolicyGuideline Record Share with software Engineer
@Date:28/08/2025

*/

public class PolicyGuidelineSharingService {
       /**
* @Share Record of policyGuideline to the Software Engineer.
* @return void
*/
    public static void shareWithSoftwareEngineers() {
        
        try{
        // Step 1: Get all users with Software Engineer profile
        Group groupOfSoftEngUsers = [SELECT Id 
                             From Group
                             Where Type='Regular' AND DeveloperName='Software_Engineer_Group'
                             LIMIT 1
                             ];
        
        // Step 2: Create share records
        List<PolicyGuideline__Share> shareRecords = new List<PolicyGuideline__Share>();
        List<PolicyGuideline__c> PolicyGuidelineList =[SELECT Id FROM PolicyGuideline__c];
        
        for(PolicyGuideline__c Policyguideline: PolicyGuidelineList){
            PolicyGuideline__Share PolicyGuidelineToShare = NEW  PolicyGuideline__Share();
            PolicyGuidelineToShare.ParentId=Policyguideline.Id;
            PolicyGuidelineToShare.UserOrGroupId=groupOfSoftEngUsers.Id;
            PolicyGuidelineToShare.AccessLevel= 'Read'; 
            shareRecords.add(PolicyGuidelineToShare);
        }
        
        
        
        // Step 3: Insert all at once (bulk insert)
        if (!shareRecords.isEmpty()) {
            insert shareRecords;
        }
            
        }
        
        
    catch (Exception ex) {
        // Catches any other unhandled exceptions
        System.debug('General Exception: ' + ex.getMessage());
         System.debug('Line Number'+ex.getLineNumber());
    }
    finally {
        // Always runs, useful for logging or cleanup
        System.debug('Process Completed');
    }
    }
}