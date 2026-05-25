@IsTest
public class AccountTriggerTest {

    // Test Data Setup
    @TestSetup
    static void setupTestData() {
        // Account in Education industry
        Account eduAcc = TestDataFactory.createAccount('Edu Test Acc', 500000, 'Education');
        insert eduAcc;

        // Account in some other industry
        Account nonEduAcc = TestDataFactory.createAccount('Tech Test Acc', 200000, 'Technology');
        insert nonEduAcc;
    }

    //  Positive test: E
    @IsTest
    static void testEducationContactsCreated() {
        List<Account> eduAccs = [SELECT Id, Name, Industry FROM Account WHERE Industry = 'Education'];

        Test.startTest();
        AccountTriggerHandler.q16CreateEducationContacts(eduAccs);
        Test.stopTest();

        List<Contact> eduContacts = [SELECT LastName, Title FROM Contact WHERE AccountId = :eduAccs[0].Id];
       // System.assertEquals(3, eduContacts.size(), 'Education account should have 3 contacts');
        // System.assertEquals(true, eduContacts.stream().anyMatch(c -> c.Title == 'Principal'), 'Principal contact should exist');
        // System.assertEquals(true, eduContacts.stream().anyMatch(c -> c.Title == 'Teacher'), 'Teacher contact should exist');
        // System.assertEquals(true, eduContacts.stream().anyMatch(c -> c.Title == 'Student'), 'Student contact should exist');
    }

    // Negative test
    @IsTest
    static void testNonEducationContactsCreated() {
        List<Account> techAccs = [SELECT Id, Name, Industry FROM Account WHERE Industry = 'Technology'];

        Test.startTest();
        AccountTriggerHandler.q16CreateEducationContacts(techAccs);
        Test.stopTest();

        List<Contact> defaultContacts = [SELECT LastName FROM Contact WHERE AccountId = :techAccs[0].Id];
       // System.assertEquals(1, defaultContacts.size(), 'Non-Education account should create only 1 default contact');
        System.assertEquals(techAccs[0].Name, defaultContacts[0].LastName, 'Default contact should have same name as Account');
    }
}