@IsTest
public with sharing class TestTaskReminderScheduler {

    @TestSetup
    static void makeData() {
     
        User u = TestDataFactory.createUser('userpendingtask', 'Standard User');
        insert u;

      
      
            Task todayTask = TestDataFactory.createTask(
                u.Id, 'Not Started', 'Pending Task today', 'Normal', Date.today()
            );
            Task futureTask = TestDataFactory.createTask(
                u.Id, 'Not Started', 'Task not due today', 'High', Date.today().addDays(5)
            );
            
            System.debug('todayTask -->'+todayTask);
            insert new List<Task>{ todayTask, futureTask };
        }

    
    @IsTest
   static void testTaskReminderScheduler_Positive() {
     List<Task> listOfTask=[SELECT Id,Status,ActivityDate FROM Task];
     List<User> listOfUser=[SELECT Id FROM User];
       system.debug('list of task'+listofTask);
       system.debug('list of User'+listOfUser);
        Test.startTest();
      
        System.schedule('Daily Reminder',
                        '0 0 9 * * ?', new TaskReminderScheduler());
      /*  System.assert(
           Limits.getEmailInvocations() > 0,
            'Expected at least one email for today’s pending task');
         */
        
        Test.stopTest();
       List<CronTrigger> listOfJob = [
        SELECT Id, CronJobDetail.Name
        FROM CronTrigger
        WHERE CronJobDetail.Name = 'Daily Reminder'];
       
         System.assertEquals(1, listOfJob.size(), 'Expected one scheduled job');

    }

    @IsTest
    static void testTaskReminderScheduler_Negative() {
        delete [SELECT Id FROM Task];

        Test.startTest();
        System.schedule('Daily  Reminder' ,
                        '0 0 9 * * ?', new TaskReminderScheduler());
        Test.stopTest();

       System.assertEquals(
            0,Limits.getEmailInvocations(),
            'No emails should be sent when no pending tasks exist'
        );
    }
}