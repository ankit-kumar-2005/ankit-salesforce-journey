@isTest
public with sharing class AccountRatingOperationBatchableTest {
    
    /**
    * Create 3 Accounts and Opportunities for basic test.
    */
    @TestSetup
    static void makeData() {
        List<Account> accList = new List<Account>();
        for (Integer i = 1; i <= 3; i++) {
            accList.add(new Account(Name = 'testacc' + i, Industry = 'Other'));
        }
        insert accList;

        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(Name='opp1', AccountId=accList[0].Id, StageName='Closewon', CloseDate=Date.today().addDays(2), Amount=1000000));
        oppList.add(new Opportunity(Name='opp2', AccountId=accList[0].Id, StageName='Closewon', CloseDate=Date.today().addDays(2), Amount=100));

        oppList.add(new Opportunity(Name='opp3', AccountId=accList[1].Id, StageName='Closewon', CloseDate=Date.today().addDays(2), Amount=50000));
        oppList.add(new Opportunity(Name='opp4', AccountId=accList[1].Id, StageName='Closewon', CloseDate=Date.today().addDays(2), Amount=1000));

        oppList.add(new Opportunity(Name='opp5', AccountId=accList[2].Id, StageName='Closewon', CloseDate=Date.today().addDays(2), Amount=1000));
        oppList.add(new Opportunity(Name='opp6', AccountId=accList[2].Id, StageName='Closewon', CloseDate=Date.today().addDays(2), Amount=100));

        insert oppList;
    }

    /**
    * Test Ratings for 3 Accounts (Hot, Warm, Cold).
    */
    @isTest
    public static void AccountRatingOperationBatchable_singleBatchTest() {
        Test.startTest();
            Database.executeBatch(new AccountRatingOperationBatchable(), 100);
        Test.stopTest();

        Account acc1 = [SELECT Rating FROM Account WHERE Name = 'testacc1' LIMIT 1];
        System.assertEquals('Hot', acc1.Rating);

        Account acc2 = [SELECT Rating FROM Account WHERE Name = 'testacc2' LIMIT 1];
        System.assertEquals('Warm', acc2.Rating);

        Account acc3 = [SELECT Rating FROM Account WHERE Name = 'testacc3' LIMIT 1];
        System.assertEquals('Cold', acc3.Rating);
    }

    /**
    * Bulk test: create 100 Accounts with Opportunities.
    */
    @isTest
    public static void AccountRatingOperationBatchable_bulkTest() {
        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < 100; i++) {
            bulkAccounts.add(new Account(Name = 'bulkAcc' + i, Industry = 'Other'));
        }
        insert bulkAccounts;

        List<Opportunity> bulkOpps = new List<Opportunity>();
        for (Account acc : bulkAccounts) {
            bulkOpps.add(new Opportunity(Name = 'bulkOpp1-' + acc.Name, AccountId = acc.Id,
                                         StageName = 'Closewon', CloseDate = Date.today().addDays(10), Amount = 20000));
            bulkOpps.add(new Opportunity(Name = 'bulkOpp2-' + acc.Name, AccountId = acc.Id,
                                         StageName = 'Closewon', CloseDate = Date.today().addDays(10), Amount = 30000));
        }
        insert bulkOpps;

        Test.startTest();
            Database.executeBatch(new AccountRatingOperationBatchable(), 50);
        Test.stopTest();

        Integer warmCount = [SELECT COUNT() FROM Account WHERE Name LIKE 'bulkAcc%' AND Rating = 'Warm'];
        System.assertEquals(100, warmCount, 'All bulk accounts should be Warm');
    }
}