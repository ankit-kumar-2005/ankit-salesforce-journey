@IsTest
public class ContactTriggerTest {

    @TestSetup
    static void createTestData(){
        // Accounts for testing
        Account accountWithEmail = new Account(Name='AccountWithEmail', Email__c='email@test.com');
        Account accountWithoutOpp = new Account(Name='AccountWithoutOpp', Email__c='noopp@test.com');
        insert new List<Account>{accountWithEmail, accountWithoutOpp};

        // Existing Contact for Q9 duplicate test
        Contact existingCon = new Contact(
            LastName='ExistingContact',
            Email='duplicate@test.com',
            Phone='1234567890',
            AccountId=accountWithEmail.Id
        );
        insert existingCon;
    }

    // Q6 Positive Test: Auto-fill Email
    @IsTest
    static void testQ6_EmailAutoFill(){
        Account acc = [SELECT Id, Email__c FROM Account WHERE Name='AccountWithEmail' LIMIT 1];
        Contact newCon = new Contact(LastName='Q6TestContact', AccountId=acc.Id);
        insert newCon;

        newCon = [SELECT Email FROM Contact WHERE Id=:newCon.Id];
        System.assertEquals(acc.Email__c, newCon.Email, 'Email should auto-fill from Account');
    }

    // Q9 Negative Test: Duplicate Email + Phone
    @IsTest
    static void testQ9_DuplicatePrevention(){
        Account acc = [SELECT Id FROM Account WHERE Name='AccountWithEmail' LIMIT 1];
        Contact duplicateCon = new Contact(
            LastName='Q9DupTest',
            Email='duplicate@test.com',
            Phone='1234567890',
            AccountId=acc.Id
        );

        try{
            insert duplicateCon;
            System.assert(false, 'Duplicate Contact insertion should fail');
        } catch(DmlException e){
            System.assert(e.getMessage().contains('already exists'), 'Expected duplicate error message');
        }
    }

    // Q15 Positive Test: Auto-create Opportunity
    @IsTest
    static void testQ15_OpportunityCreation(){
        Account acc = [SELECT Id FROM Account WHERE Name='AccountWithoutOpp' LIMIT 1];
        Contact newCon = new Contact(
            LastName='Q15Contact',
            Email='q15@test.com',
            Phone='9876543210',
            AccountId=acc.Id
        );
        insert newCon;

        List<Opportunity> opps = [SELECT Id, AccountId, StageName, CloseDate FROM Opportunity WHERE AccountId=:acc.Id];
        System.assertEquals(1, opps.size(), 'One Opportunity should be created automatically');
        System.assertEquals('Prospecting', opps[0].StageName);
        System.assertEquals(Date.today().addDays(30), opps[0].CloseDate);
    }

    // Bulk Test: Insert multiple Contacts
    @IsTest
    static void testBulkInsertContacts(){
        Account acc = [SELECT Id FROM Account WHERE Name='AccountWithEmail' LIMIT 1];
        List<Contact> bulkContacts = new List<Contact>();
        for(Integer i=0; i<200; i++){
            bulkContacts.add(new Contact(
                LastName='BulkContact'+i,
                AccountId=acc.Id,
                Email='bulk'+i+'@test.com',
                Phone='500'+i
            ));
        }

        Test.startTest();
        insert bulkContacts;
        Test.stopTest();

        Integer insertedCount = [SELECT COUNT() FROM Contact WHERE AccountId=:acc.Id AND LastName LIKE 'BulkContact%'];
        System.assertEquals(200, insertedCount, 'All 200 Contacts should be inserted successfully');
    }
}