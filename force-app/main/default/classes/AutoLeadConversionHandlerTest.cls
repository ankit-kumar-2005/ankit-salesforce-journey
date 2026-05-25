@isTest
public class AutoLeadConversionHandlerTest {
    
    @TestSetup
    static void setupData() {
        Lead webLeadRecord = TestDataFactory.createLead('positivetestdata','lastname','positivetest company','web');
        Lead phoneLeadRecord = TestDataFactory.createLead('Negativetestdata','singh','negativetest company','phone');
        
        insert new List<Lead>{ webLeadRecord, phoneLeadRecord };
            
        
    }

    @isTest
    public static void testAutoLeadConversionHandler() {
    LeadStatus convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];

        
        Lead webLeadRecord   = [SELECT Id, Status FROM Lead WHERE LeadSource = 'web' LIMIT 1];


        Integer convertedWebLeadCount = [
            SELECT Id FROM Lead 
            WHERE Status = :convertedStatus.MasterLabel 
            AND Id = :webLeadRecord.Id
        ].size();

       

        System.assertEquals(1, convertedWebLeadCount, 'Web lead  automatically converted.');
       
      
  
        // Account 
        Integer webAccountCount = [
            SELECT Id FROM Account 
           // WHERE Name = :webLeadRecord.Company
        ].size();

       

        System.assertEquals(1, webAccountCount, 'Account should be created for Web lead.');
       

        //  Contact 
        Integer webContactCount = [
            SELECT Id FROM Contact 
           // WHERE Account.Name = :webLeadRecord.Company
        ].size();

        

        System.assertEquals(3, webContactCount, 'Contact should be created for Web lead.');
       
      
        Integer webOpportunityCount = [
            SELECT Id FROM Opportunity 
            //WHERE Account.Name = :webLeadRecord.Company
        ].size();

       

        System.assertEquals(2, webOpportunityCount, 'Opportunity should be created for Web lead.');
      
        // Task
        List<Task> taskListRecord = [SELECT Id, WhoId FROM Task 
            WHERE WhoId =: webLeadRecord.Id];
		System.debug('Web lead record ID -->'+webLeadRecord.Id);
        System.debug('Task list record-->'+taskListRecord);
        Integer webTaskCount = [
            SELECT Id FROM Task 
            //WHERE WhoId = :webLeadRecord.Id
        ].size();
        System.debug('Web Tak--> '+ webTaskCount);

       

        System.assertEquals(2, webTaskCount, 'Follow-up Task should be created for Web lead.');
      
    }
    
    @isTest
    public static void testAutoLeadConversionHandlernegative(){
        LeadStatus convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
          Lead phoneLeadRecord = [SELECT Id, Status FROM Lead WHERE LeadSource = 'phone' LIMIT 1];
        
          Integer convertedPhoneLeadCount = [
            SELECT Id FROM Lead 
            WHERE Status = :convertedStatus.MasterLabel 
            AND Id = :phoneLeadRecord.Id
        ].size(); 
        
         System.assertEquals(0, convertedPhoneLeadCount, 'Phone lead should NOT be converted.');
        
          
    }
}