@isTest
public with sharing class TestoverdueTaskCloseBatch {
   @TestSetup
   static void makeData(){
    User user=TestDataFactory.createUser('usertest', 'Standard User');
    insert user;
    Task positiveCaseTask=TestDataFactory.createTask(user.Id, 'Not Started', 'Task is Overdue', 'Normal', Date.newInstance(2024,12,21));
    Task negativeCaseTask=TestDataFactory.createTask(user.Id, 'Not Started', 'Task is not Overdue', 'High', Date.newInstance(2025, 12, 21));
       List<Task> listOfTask = new List<Task>{positiveCaseTask,negativeCaseTask};
           insert listOfTask;

   }
   @isTest
   public static void TestoverdueTaskCloseBatch_Positive(){
    test.startTest();
    Database.executeBatch(new OverdueTaskCloseBatch());
    test.stopTest();

    Task taskOutput=[SELECT Id,Status From Task WHERE Subject='Task is Overdue'];
    System.assertEquals('Closed', taskOutput.Status,'There is error in code Status is not completed');
   }

   @isTest  
   public static void TestoverdueTaskCloseBatch_Negative(){
       test.startTest();
       Database.executeBatch(new OverdueTaskCloseBatch());
       test.stopTest();

        Task taskOutput=[SELECT Id,Status From Task WHERE Subject='Task is not Overdue'];
        System.assertNotEquals('Closed', taskOutput.Status,'There is Error in code Status must be complete');
   }
}