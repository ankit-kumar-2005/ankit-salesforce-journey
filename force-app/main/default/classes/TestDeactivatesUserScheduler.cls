@isTest
public class TestDeactivatesUserScheduler {
/*
    @TestSetup
    static void makeData(){
        User u1= TestDataFactory.createUser('test1', 'Standard User');
        u1.LastLoginDate=Date.today().addDays(-100);
        User u2= TestDataFactory.createUser('test2', 'Standard User');
        u2.LastLoginDate=Date.today().addDays(-10);

        insert new List<User>{u1,u2};
        
    }
        */

    @isTest 
    public static void TestDeactivatesUserScheduler_positive(){
        Test.startTest();
        System.schedule('Deactivate user', '0 0 9 * * ?', new DeactivatesUserScheduler());
        Test.stopTest();
        User user=[SELECT Id,IsActive FROM USER 
                   WHERE LastLoginDate  <= :System.today().addDays(-90) LIMIT 1 ];
        system.assertEquals(false, user.IsActive, 'Deactive user is not running prperly');
    }

    @isTest 
    public static void TestDeactivatesUserScheduler_negative(){
      Test.startTest();
        System.schedule('Deactivate user', '0 0 9 * * ?', new DeactivatesUserScheduler());
        Test.stopTest();
         User user=[SELECT Id,IsActive FROM USER 
                   WHERE LastLoginDate  = :System.today().addDays(-90) LIMIT 1 ];
        system.assertEquals(true, user.IsActive, 'Deactive user is not running prperly');
    }
}