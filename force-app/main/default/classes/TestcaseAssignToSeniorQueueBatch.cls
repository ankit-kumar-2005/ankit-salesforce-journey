@isTest
public with sharing class TestcaseAssignToSeniorQueueBatch {
    @TestSetup
   static void makeData(){

    

    Account acc=TestDataFactory.createAccount('test', 10000, 'Other');
    insert acc;
    case positiveCase=TestDataFactory.createCase(acc.Id, 'New');
    positiveCase.Priority='High';
    case Negativecase=TestDataFactory.createCase(acc.Id, 'New');
    Negativecase.Priority='Low';
    List<Case> listOfCase= new List<Case>{positiveCase,Negativecase};
    insert listOfCase;
   }
   @isTest
   public static void caseAssignToSeniorQueueBatch_Positive(){
    test.startTest();
    Database.executeBatch(new caseAssignToSeniorQueueBatch());
    test.stopTest();
    case c=[SELECT id, OwnerId  from Case where Priority='High'];
    Group groupp=[SELECT Id from Group WHERE Type='Queue' and DeveloperName='Senior_Support_Queue'];
    
    System.assertEquals(groupp.id,c.OwnerId);
   }
   @isTest 
   public static void caseAssignToSeniorQueueBatch_Negative(){
    test.startTest();
    Database.executeBatch(new caseAssignToSeniorQueueBatch());
    test.stopTest();
    case c=[SELECT id,Owner.Name  from Case where Priority='Low'];
    Group groupp=[SELECT Id from Group WHERE Type='Queue' and DeveloperName='Senior_Support_Queue'];
   System.assertNotEquals(groupp.id,c.OwnerId);
   }
   
}