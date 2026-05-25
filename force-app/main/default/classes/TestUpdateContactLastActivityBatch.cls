@IsTest
public with sharing class TestUpdateContactLastActivityBatch {

    @TestSetup
    static void makeData() {
        Account acc = TestDataFactory.createAccount( 'Test Account',10000,'Other');
        insert acc;

        Contact con1 = TestDataFactory.createContact('John', 'Doe', acc.Id, 'Manager', 'john@gmail.com');
        Contact con2 = TestDataFactory.createContact('Jane', 'Smith', acc.Id, 'Developer', 'jane@gmail.com');
         List<Contact> listOfContact= new List<Contact>{con1,con2};
         insert listOfContact;

         User user=TestDataFactory.createUser('user test contact', 'Standard User');
         insert user;

        Task task1 = TestDataFactory.createTask(user.Id, 'Completed', 'Old Task', 'Normal', Date.today().addDays(-5));
        Task task2 = TestDataFactory.createTask(user.Id, 'Completed', 'Recent Task', 'Normal', Date.today().addDays(-1));
        Task task3 = TestDataFactory.createTask(user.Id, 'Completed', 'Task 1', 'Normal', Date.today().addDays(-3));
        Task task4 = TestDataFactory.createTask(user.Id, 'Completed', 'Task 2', 'Normal', Date.today());
        task1.WhoId=con1.Id;task2.WhoId=con1.Id;
        task3.WhoId=con2.Id;task4.WhoId=con2.Id;
         
        List<Task> listOfTask= new List<Task>{task1,task2,task3,task4};
        insert listOfTask;
    }

    @IsTest
    public static void testUpdateContactLastActivityBatch_Positive() {
        Test.startTest();
        Database.executeBatch(new UpdateContactLastActivityBatch());
        Test.stopTest();

        Contact con1 = [SELECT Last_Activity_Date__c FROM Contact WHERE FirstName='John' LIMIT 1];
        Contact con2 = [SELECT Last_Activity_Date__c FROM Contact WHERE FirstName='Jane' LIMIT 1];

        System.assertEquals(Date.today().addDays(-1), con1.Last_Activity_Date__c, 'Last Activity Date for John is incorrect');
        System.assertEquals(Date.today(), con2.Last_Activity_Date__c, 'Last Activity Date for Jane is incorrect');
    }

    @IsTest
    public static void testUpdateContactLastActivityBatch_Negative() {
        Test.startTest();
        Database.executeBatch(new UpdateContactLastActivityBatch());
        Test.stopTest();

        Contact con1 = [SELECT Last_Activity_Date__c FROM Contact WHERE FirstName='John' LIMIT 1];

        System.assertNotEquals(Date.today().addDays(-5), con1.Last_Activity_Date__c, 'Batch incorrectly set old task date');
    }
}