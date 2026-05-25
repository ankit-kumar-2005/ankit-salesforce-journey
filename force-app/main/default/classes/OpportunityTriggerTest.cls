@isTest
public class OpportunityTriggerTest {
    
    @TestSetup
    static void setupData() {
        Account acc1 = TestDataFactory.createAccount('Test Account 1', 100000, 'Technology');
        Account acc2 = TestDataFactory.createAccount('Test Account 2', 200000, 'Finance');
        insert new List<Account>{ acc1, acc2 };

        Opportunity opp1 = TestDataFactory.createOpportunity('Opp 1', acc1.Id, System.today().addDays(10), 'Prospecting');
        opp1.Amount = 5000;

        Opportunity opp2 = TestDataFactory.createOpportunity('Opp 2', acc1.Id, System.today().addDays(15), 'Qualification');
        opp2.Amount = 3000;

        Opportunity opp3 = TestDataFactory.createOpportunity('Closed Opp', acc2.Id, System.today(), 'Closed Won');
        opp3.Amount = 10000;

        insert new List<Opportunity>{ opp1, opp2, opp3 };
    }

    @isTest
    static void testOpportunityTriggerPositive() {
        Account acc1 = [SELECT Id, Total_Opportunity_Amount__c 
                        FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        Decimal acc1Total = acc1.Total_Opportunity_Amount__c != null ? acc1.Total_Opportunity_Amount__c : 0;

        System.assertEquals(8000, acc1Total, 
            'Total Opportunity Amount should include only open Opportunities for Account 1');

        Opportunity opp4 = TestDataFactory.createOpportunity('Opp 4', acc1.Id, System.today().addDays(5), 'Needs Analysis');
        opp4.Amount = 2000;
        insert opp4;

        acc1 = [SELECT Id, Total_Opportunity_Amount__c FROM Account WHERE Id = :acc1.Id LIMIT 1];
        acc1Total = acc1.Total_Opportunity_Amount__c != null ? acc1.Total_Opportunity_Amount__c : 0;

        System.assertEquals(10000, acc1Total, 
            'Total Opportunity Amount should update correctly when a new Opportunity is inserted');
    }

    @isTest
    static void testOpportunityTriggerNegative() {
        Account acc2 = [SELECT Id, Total_Opportunity_Amount__c 
                        FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        Decimal acc2Total = acc2.Total_Opportunity_Amount__c != null ? acc2.Total_Opportunity_Amount__c : 0;

        System.assertEquals(0, acc2Total, 
            'Closed Won/Lost Opportunities should not be included in Total Opportunity Amount');

        Opportunity opp5 = TestDataFactory.createOpportunity('Opp 5', acc2.Id, System.today().addDays(7), 'Closed Lost');
        opp5.Amount = 6000;
        insert opp5;

        acc2 = [SELECT Id, Total_Opportunity_Amount__c FROM Account WHERE Id = :acc2.Id LIMIT 1];
        acc2Total = acc2.Total_Opportunity_Amount__c != null ? acc2.Total_Opportunity_Amount__c : 0;

        System.assertEquals(0, acc2Total, 
            'Closed Opportunities should never affect the total amount for Account 2');
    }
}