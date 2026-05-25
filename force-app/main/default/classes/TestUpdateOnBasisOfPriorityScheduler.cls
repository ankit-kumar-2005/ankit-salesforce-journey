@isTest
public class TestUpdateOnBasisOfPriorityScheduler {
 @TestSetup
    static void makeData() {
        Case oldHigh = new Case(
            Subject  = 'Case older than 48 hours',
            Status   = 'New',
            Priority = 'High'
        );
        insert oldHigh;
        Test.setCreatedDate(oldHigh.Id, System.now().addDays(-3));

        Case recentHigh = new Case(
            Subject  = 'Recent high priority case',
            Status   = 'New',
            Priority = 'High'
        );
        insert recentHigh;
    }

    @IsTest
    static void testSchedulerUpdatesOnlyOldHighCases() {
        String cron = '0 0 2 * * ?';
        Test.startTest();
        System.schedule(
            'HighToCritical',
            cron,
            new UpdateCaseOnBasisOfPriorityScheduler()
        );
        Test.stopTest();

        Case updated = [SELECT Priority FROM Case WHERE Subject = 'Case older than 48 hours' LIMIT 1];
        System.assertEquals('Critical', updated.Priority);

        Case notUpdated = [SELECT Priority FROM Case WHERE Subject = 'Recent high priority case' LIMIT 1];
        System.assertEquals('High', notUpdated.Priority);
    }

    @IsTest
    static void testSchedulerNoCases() {
        delete [SELECT Id FROM Case];
        Test.startTest();
        System.schedule(
            'HighToCritical',
            '0 0 2 * * ?',
            new UpdateCaseOnBasisOfPriorityScheduler()
        );
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Case]);
    }
}