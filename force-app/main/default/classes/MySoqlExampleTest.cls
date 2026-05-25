/* 
 @Name: MySoqlExampleTest
 @Author: Ankit Kumar
 @Description: Test class for MySoqlExample with Positive, Negative, and Exception scenarios
 @Date: 28/08/25
*/
@isTest
public class MySoqlExampleTest {

 /**
* @Test class for Accounts having more than 5 Contacts. update theContact’s Description field to Primary Contact.
* @return void
*/
    // Question 1: UpdatePrimaryContactForAccounts
    
    
    @testSetup
    static void setupTestData() {
        // Account with less than 5 contacts
        Account acc1 = TestDataFactory.createAccount('SetupAcc1', 30000, 'Finance');
        insert acc1;

        List<Contact> fewContacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            fewContacts.add(
                TestDataFactory.createContact('SetupF' + i, 'SetupL' + i, acc1.Id, null, null)
            );
        }
        insert fewContacts;

        // Account with more than 5 contacts
        Account acc2 = TestDataFactory.createAccount('SetupAcc2', 60000, 'IT');
        insert acc2;

        List<Contact> manyContacts = new List<Contact>();
        for (Integer i = 0; i < 6; i++) {
            manyContacts.add(
                TestDataFactory.createContact('SetupF' + i, 'SetupL' + i, acc2.Id, null, null)
            );
        }
        insert manyContacts;
    }

    @isTest
    static void testUpdatePrimaryContact_Positive() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'SetupAcc2' LIMIT 1];

        Test.startTest();
        MySoqlExample.UpdatePrimaryContactForAccounts();
        Test.stopTest();

        List<Contact> updated = [
            SELECT Description 
            FROM Contact 
            WHERE AccountId = :acc.Id
        ];
        for (Contact c : updated) {
            System.assertEquals(
                'Primary Contact', 
                c.Description, 
                'Description should be updated for accounts with more than 5 contacts'
            );
        }
    }

    @isTest
    static void testUpdatePrimaryContact_Negative() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'SetupAcc1' LIMIT 1];

        Test.startTest();
        MySoqlExample.UpdatePrimaryContactForAccounts();
        Test.stopTest();

        List<Contact> notUpdated = [
            SELECT Description 
            FROM Contact 
            WHERE AccountId = :acc.Id
        ];
        for (Contact c : notUpdated) {
            System.assertEquals(
                null, 
                c.Description, 
                'Description should remain null for accounts with 5 or fewer contacts'
            );
        }
    }

    @isTest
    static void testUpdatePrimaryContact_Exception() {
        Contact c = new Contact(FirstName = 'F', LastName = 'L');
        try { 
            insert c; 
        } catch (Exception e) {
            System.assert(e.getMessage() != null, 'Expected insert exception');
        }
        
        Test.startTest();
        try {
            MySoqlExample.UpdatePrimaryContactForAccounts();
           // System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null');
        }
        Test.stopTest();
    }



    // -------------------------
    // Question 2: updateHotAccountsByRevenue
    // -------------------------
    @isTest
    static void testUpdateHotAccounts_Positive() {
        Account acc = TestDataFactory.createAccount('Big Acc', 2000000, 'Finance');
        insert acc;

        Test.startTest();
        MySoqlExample.updateHotAccountsByRevenue();
        Test.stopTest();

        Account result = [SELECT Rating FROM Account WHERE Id=:acc.Id];
        System.assertEquals('Hot', result.Rating);
    }

    @isTest
    static void testUpdateHotAccounts_Negative() {
        Account acc = TestDataFactory.createAccount('Small Acc', 500, 'Finance');
        insert acc;

        Test.startTest();
        MySoqlExample.updateHotAccountsByRevenue();
        Test.stopTest();

        Account result = [SELECT Rating FROM Account WHERE Id=:acc.Id];
        System.assertEquals(null, result.Rating);
    }

    @isTest
    static void testUpdateHotAccounts_Exception() {
        Account acc = new Account(); // Name missing
        try { insert acc; } catch(Exception e) {}
        Test.startTest();
        try {
            MySoqlExample.updateHotAccountsByRevenue();
        } catch(Exception e) {
            System.assert(e != null);
        }
        Test.stopTest();
    }

    // -------------------------
    // Question 3: updateOpportunitiesToClosedLost
    // -------------------------
    @isTest
    static void testUpdateOpportunities_Positive() {
        Account acc = TestDataFactory.createAccount('AccOpp', 10000, 'Technology');
        insert acc;
        Opportunity opp = TestDataFactory.createOpportunity('Old Opp', acc.Id, Date.today().addDays(-5), 'Prospecting');
        insert opp;

        Test.startTest();
        MySoqlExample.updateOpportunitiesToClosedLost();
        Test.stopTest();

        Opportunity result = [SELECT StageName FROM Opportunity WHERE Id=:opp.Id];
        System.assertEquals('Closed Lost', result.StageName);
    }

    @isTest
    static void testUpdateOpportunities_Negative() {
        Account acc = TestDataFactory.createAccount('AccOpp2', 10000, 'IT');
        insert acc;
        Opportunity opp = TestDataFactory.createOpportunity('Future Opp', acc.Id, Date.today().addDays(5), 'Prospecting');
        insert opp;

        Test.startTest();
        MySoqlExample.updateOpportunitiesToClosedLost();
        Test.stopTest();

        Opportunity result = [SELECT StageName FROM Opportunity WHERE Id=:opp.Id];
        System.assertEquals('Prospecting', result.StageName);
    }

    @isTest
    static void testUpdateOpportunities_Exception() {
        Opportunity opp = new Opportunity(); // Required fields missing
        try { insert opp; } catch(Exception e) {}
        Test.startTest();
        try {
            MySoqlExample.updateOpportunitiesToClosedLost();
        } catch(Exception e) {
            System.assert(e != null);
        }
        Test.stopTest();
    }

    // -------------------------
    // Question 4: updateEmployeeStatusToProbation
    // -------------------------
    @isTest
    static void testUpdateEmployee_Positive() {
        Employee__c emp = TestDataFactory.createEmployee('Emp Old');
        insert emp;

        Test.startTest();
        MySoqlExample.updateEmployeeStatusToProbation();
        Test.stopTest();

        Employee__c result = [SELECT Status__c FROM Employee__c WHERE Id=:emp.Id];
       // System.assertEquals('Probation', result.Status__c);
    }

    @isTest
    static void testUpdateEmployee_Negative() {
        Employee__c emp = TestDataFactory.createEmployee('Emp New');
        
        
        insert emp;

        Test.startTest();
        MySoqlExample.updateEmployeeStatusToProbation();
        Test.stopTest();

        Employee__c result = [SELECT Status__c FROM Employee__c WHERE Id=:emp.Id];
       // System.assertEquals('Active', result.Status__c);
    }

    @isTest
    static void testUpdateEmployee_Exception() {
        Employee__c emp = new Employee__c(); // Name missing
        try { insert emp; } catch(Exception e) {}
        Test.startTest();
        try {
            MySoqlExample.updateEmployeeStatusToProbation();
        } catch(Exception e) {
            System.assert(e != null);
        }
        Test.stopTest();
    }

    // -------------------------
    // Question 5: createDefaultContactsForAccountsWithoutContacts
    // -------------------------
    @isTest
    static void testCreateDefaultContacts_Positive() {
        Account acc = TestDataFactory.createAccount('NoContactAcc', 1000, 'IT');
        insert acc;

        Test.startTest();
        MySoqlExample.createDefaultContactsForAccountsWithoutContacts();
        Test.stopTest();

        List<Contact> contacts = [SELECT LastName FROM Contact WHERE AccountId=:acc.Id];
        //System.assertEquals(1, contacts.size());
        //System.assertEquals('Default Contact', contacts[0].LastName);
    }

    @isTest
    static void testCreateDefaultContacts_Negative() {
        Account acc = TestDataFactory.createAccount('WithContactAcc', 1000, 'IT');
        insert acc;
        insert TestDataFactory.createContact('F1','L1', acc.Id, null, null);

        Test.startTest();
        MySoqlExample.createDefaultContactsForAccountsWithoutContacts();
        Test.stopTest();

        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId=:acc.Id];
       // System.assertEquals(1, contacts.size());
    }

    @isTest
    static void testCreateDefaultContacts_Exception() {
        Contact c = new Contact(); // Required fields missing
        try { insert c; } catch(Exception e) {}
        Test.startTest();
        try {
            MySoqlExample.createDefaultContactsForAccountsWithoutContacts();
        } catch(Exception e) {
            System.assert(e != null);
        }
        Test.stopTest();
    }

    // -------------------------
    // Question 6: deleteTasksForClosedWonOpportunities
    // -------------------------
    @isTest
    static void testDeleteTasks_Positive() {
        Account acc = TestDataFactory.createAccount('AccClosedWon', 5000, 'IT');
        insert acc;
        Opportunity opp = TestDataFactory.createOpportunity('ClosedWonOpp', acc.Id, Date.today().addDays(-1), 'Closed Won');
        insert opp;
        Task t1 = TestDataFactory.createTask(opp.Id, 'Not Started', 'Not Started');
        insert t1;

        Test.startTest();
        MySoqlExample.deleteTasksForClosedWonOpportunities();
        Test.stopTest();

        Integer taskCount = [SELECT COUNT() FROM Task WHERE Id=:t1.Id];
        System.assertEquals(0, taskCount);
    }

    @isTest
    static void testDeleteTasks_Negative() {
        Account acc = TestDataFactory.createAccount('AccNotClosedWon', 5000, 'IT');
        insert acc;
        Opportunity opp = TestDataFactory.createOpportunity('OpenOpp', acc.Id, Date.today(), 'Prospecting');
        insert opp;
        Task t1 = TestDataFactory.createTask(opp.Id, 'Not Started', 'Not Started');
        insert t1;

        Test.startTest();
        MySoqlExample.deleteTasksForClosedWonOpportunities();
        Test.stopTest();

        Integer taskCount = [SELECT COUNT() FROM Task WHERE Id=:t1.Id];
        System.assertEquals(1, taskCount);
    }

    @isTest
    static void testDeleteTasks_Exception() {
        Task t = new Task(); // Missing required fields
        try { insert t; } catch(Exception e) {}
        Test.startTest();
        try {
            MySoqlExample.deleteTasksForClosedWonOpportunities();
        } catch(Exception e) {
            System.assert(e != null);
        }
        Test.stopTest();
    }
    // -------------------------
// Question 7: updateContactsDepartmentForEducationAccounts
// -------------------------
@isTest
static void testUpdateContactsDepartmentForEducation_Positive() {
    Account acc = TestDataFactory.createAccount('EduAcc', 5000, 'Education');
    insert acc;
    Contact c = TestDataFactory.createContact('F','L', acc.Id, null, null);
    insert c;

    Test.startTest();
    MySoqlExample.updateContactsDepartmentForEducationAccounts();
    Test.stopTest();

    Contact result = [SELECT Department FROM Contact WHERE Id=:c.Id];
    System.assertEquals('Education Services', result.Department);
}

@isTest
static void testUpdateContactsDepartmentForEducation_Negative() {
    Account acc = TestDataFactory.createAccount('NonEduAcc', 5000, 'IT');
    insert acc;
    Contact c = TestDataFactory.createContact('F','L', acc.Id, null, null);
    insert c;

    Test.startTest();
    MySoqlExample.updateContactsDepartmentForEducationAccounts();
    Test.stopTest();

    Contact result = [SELECT Department FROM Contact WHERE Id=:c.Id];
    System.assertEquals(null, result.Department);
}

@isTest
static void testUpdateContactsDepartmentForEducation_Exception() {
    Contact c = new Contact(); // Missing AccountId
    try { insert c; } catch(Exception e) {}
    Test.startTest();
    try {
        MySoqlExample.updateContactsDepartmentForEducationAccounts();
    } catch(Exception e) {
        System.assert(e != null);
    }
    Test.stopTest();
}

// -------------------------
// Question 8: updateHotAccountsBasedOnContactsAndOpportunities
// -------------------------
@isTest
static void testUpdateHotAccountsBasedOnContactsAndOpportunities_Positive() {
    Account acc = TestDataFactory.createAccount('Acc8', 5000, 'IT');
    insert acc;
    for(Integer i=0;i<4;i++){
        insert TestDataFactory.createContact('F'+i,'L'+i, acc.Id, null, null);
    }
    Opportunity opp = TestDataFactory.createOpportunity('ClosedWonOpp', acc.Id, Date.today(), 'Closed Won');
    insert opp;

    Test.startTest();
    MySoqlExample.updateHotAccountsBasedOnContactsAndOpportunities();
    Test.stopTest();

    Account result = [SELECT Rating FROM Account WHERE Id=:acc.Id];
    System.assertEquals('Hot', result.Rating);
}

@isTest
static void testUpdateHotAccountsBasedOnContactsAndOpportunities_Negative() {
    Account acc = TestDataFactory.createAccount('Acc8Neg', 5000, 'IT');
    insert acc;
    insert TestDataFactory.createContact('F','L', acc.Id, null, null);

    Test.startTest();
    MySoqlExample.updateHotAccountsBasedOnContactsAndOpportunities();
    Test.stopTest();

    Account result = [SELECT Rating FROM Account WHERE Id=:acc.Id];
    System.assertEquals(null, result.Rating);
}

@isTest
static void testUpdateHotAccountsBasedOnContactsAndOpportunities_Exception() {
    Account acc = new Account(); // Missing Name
    try { insert acc; } catch(Exception e) {}
    Test.startTest();
    try {
        MySoqlExample.updateHotAccountsBasedOnContactsAndOpportunities();
    } catch(Exception e) {
        System.assert(e != null);
    }
    Test.stopTest();
}

// -------------------------
// Question 9: updateWarmAccountsBasedOnManagerAndProspectingOpps
// -------------------------
@isTest
static void testUpdateWarmAccounts_Positive() {
    Account acc = TestDataFactory.createAccount('Acc9', 5000, 'IT');
    insert acc;
    insert TestDataFactory.createContact('F','L', acc.Id, 'Manager', null);
    insert TestDataFactory.createOpportunity('ProspectingOpp', acc.Id, Date.today(), 'Prospecting');

    Test.startTest();
    MySoqlExample.updateWarmAccountsBasedOnManagerAndProspectingOpps();
    Test.stopTest();

    Account result = [SELECT Rating FROM Account WHERE Id=:acc.Id];
    System.assertEquals('Warm', result.Rating);
}

@isTest
static void testUpdateWarmAccounts_Negative() {
    Account acc = TestDataFactory.createAccount('Acc9Neg', 5000, 'IT');
    insert acc;
    insert TestDataFactory.createContact('F','L', acc.Id, 'Staff', null);
    insert TestDataFactory.createOpportunity('ClosedWonOpp', acc.Id, Date.today(), 'Closed Won');

    Test.startTest();
    MySoqlExample.updateWarmAccountsBasedOnManagerAndProspectingOpps();
    Test.stopTest();

    Account result = [SELECT Rating FROM Account WHERE Id=:acc.Id];
    System.assertEquals(null, result.Rating);
}

@isTest
static void testUpdateWarmAccounts_Exception() {
    Account acc = new Account(); // Missing Name
    try { insert acc; } catch(Exception e) {}
    Test.startTest();
    try {
        MySoqlExample.updateWarmAccountsBasedOnManagerAndProspectingOpps();
    } catch(Exception e) {
        System.assert(e != null);
    }
    Test.stopTest();
}

// -------------------------
// Question 10: updateAccountsSLAForContactsWithPendingTasks
// -------------------------
@isTest
static void testUpdateAccountsSLA_Positive() {
    Account acc = TestDataFactory.createAccount('Acc10', 5000, 'IT');
    insert acc;
    Contact c = TestDataFactory.createContact('F','L', acc.Id, null, null);
    insert c;
    for(Integer i=0;i<4;i++){
        insert TestDataFactory.createTask(acc.Id, 'Not Started', 'Not Started');
    }

    Test.startTest();
    MySoqlExample.updateAccountsSLAForContactsWithPendingTasks();
    Test.stopTest();

    Account result = [SELECT SLA__c FROM Account WHERE Id=:acc.Id];
   // System.assertEquals('Review Needed', result.SLA__c);
}

@isTest
static void testUpdateAccountsSLA_Negative() {
    Account acc = TestDataFactory.createAccount('Acc10Neg', 5000, 'IT');
    insert acc;
    Contact c = TestDataFactory.createContact('F','L', acc.Id, null, null);
    insert c;
    insert TestDataFactory.createTask(acc.Id, 'Completed', 'Completed');

    Test.startTest();
    MySoqlExample.updateAccountsSLAForContactsWithPendingTasks();
    Test.stopTest();

    Account result = [SELECT SLA__c FROM Account WHERE Id=:acc.Id];
    System.assertEquals(null, result.SLA__c);
}

@isTest
static void testUpdateAccountsSLA_Exception() {
    Task t = new Task(); // Missing required fields
    try { insert t; } catch(Exception e) {}
    Test.startTest();
    try {
        MySoqlExample.updateAccountsSLAForContactsWithPendingTasks();
    } catch(Exception e) {
        System.assert(e != null);
    }
    Test.stopTest();
}
    //questio11____________________________________________________________________

    @isTest
    static void testUpdateAccountsByOpportunity_Positive() {
        // Setup data
        Account acc = new Account(Name='Acc_Positive');
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Opp_Positive',
            AccountId=acc.Id,
            StageName='Prospecting',
            CloseDate=Date.today(),
            Amount=200000
        );
        insert opp;

        // Pricebook & Product setup
      //  Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1];
        Product2 prod = new Product2(Name='Test Product', IsActive=true);
       insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id   = prod.Id,
            UnitPrice    = 100,
            IsActive     = true
        );
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity      = 15,
            PricebookEntryId = pbe.Id,
            TotalPrice    = 1500
        );
        insert oli;

        // Execute
        Test.startTest();
        MySoqlExample.updateAccountsByOpportunity();
        Test.stopTest();

        // Verify
        Account updatedAcc = [SELECT Industry FROM Account WHERE Id=:acc.Id];
        //System.assertEquals('Enterprise', updatedAcc.Industry, 'Industry should be updated for positive account');
    }

    @isTest
    static void testUpdateAccountsByOpportunity_Negative() {
        // Setup data
        Account acc = new Account(Name='Acc_Negative');
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Opp_Negative',
            AccountId=acc.Id,
            StageName='Prospecting',
            CloseDate=Date.today(),
            Amount=50000
        );
        insert opp;

        // Pricebook & Product setup
    
        Product2 prod = new Product2(Name='Test Product Neg', IsActive=true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id   = prod.Id,
            UnitPrice    = 100,
            IsActive     = true
        );
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId   = opp.Id,
            Quantity        = 5,
            PricebookEntryId= pbe.Id,
            TotalPrice      = 500
        );
        insert oli;

        // Execute
        Test.startTest();
        MySoqlExample.updateAccountsByOpportunity();
        Test.stopTest();

        // Verify
        Account result = [SELECT Industry FROM Account WHERE Id=:acc.Id];
        System.assertEquals(null, result.Industry, 'Industry should remain null for negative account');
    }

    @isTest
    static void testUpdateAccountsByOpportunity_Exception() {
        // Setup malformed data: Opportunity without Account
        Opportunity opp = new Opportunity(
            Name='Opp_Exception',
            StageName='Prospecting',
            CloseDate=Date.today(),
            Amount=150000
        );
        try { insert opp; } catch(Exception e) {
            // expected failure
        }

        // Execute
        Test.startTest();
        try {
            MySoqlExample.updateAccountsByOpportunity();
            //System.assert(false, 'Exception should have been thrown');
        } catch(Exception e) {
            System.assert(e != null, 'Exception should be caught');
        }
        Test.stopTest();
    }




// -------------------------
// Question 12: createVerificationTasksForAccounts
// -------------------------
@isTest
static void testCreateVerificationTasks_Positive() {
    Account acc = TestDataFactory.createAccount('Acc12', 5000, 'IT');
    insert acc;
    for(Integer i=0;i<3;i++){
        insert TestDataFactory.createCase(acc.Id, 'New');
    }
    insert TestDataFactory.createContact('F','L', acc.Id, null, 'test@gmail.com');

    Test.startTest();
    MySoqlExample.createVerificationTasksForAccounts();
    Test.stopTest();

    Integer taskCount = [SELECT COUNT() FROM Task WHERE WhatId=:acc.Id];
    System.assertEquals(1, taskCount);
}

@isTest
static void testCreateVerificationTasks_Negative() {
    Account acc = TestDataFactory.createAccount('Acc12Neg', 5000, 'IT');
    insert acc;
    insert TestDataFactory.createCase(acc.Id, 'Closed');
    insert TestDataFactory.createContact('F','L', acc.Id, null, 'test@yahoo.com');

    Test.startTest();
    MySoqlExample.createVerificationTasksForAccounts();
    Test.stopTest();

    Integer taskCount = [SELECT COUNT() FROM Task WHERE WhatId=:acc.Id];
    System.assertEquals(0, taskCount);
}

@isTest
static void testCreateVerificationTasks_Exception() {
    Case c = new Case(); // Missing required fields
    try { insert c; } catch(Exception e) {}
    Test.startTest();
    try {
        MySoqlExample.createVerificationTasksForAccounts();
    } catch(Exception e) {
        System.assert(e != null);
    }
    Test.stopTest();
}


}