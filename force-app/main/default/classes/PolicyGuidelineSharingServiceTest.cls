/*
 @Name: PolicyGuidelineSharingServiceTest
 @Author: Ankit Kumar
 @Description: Test class for PolicyGuidelineSharingService
 @Date: 28/08/2025
*/
@isTest
public class PolicyGuidelineSharingServiceTest {

    @isTest
    static void testShareWithSoftwareEngineers_Positive() {
        // Step 1: Create test group and insert
        Group grp = TestDataFactory.createSoftwareEngineerGroup();
        insert grp;

        // Step 2: Create test PolicyGuideline records
        List<PolicyGuideline__c> guidelines = new List<PolicyGuideline__c>();
        for(Integer i=0; i<3; i++) {
            guidelines.add(TestDataFactory.createPolicyGuideline('Policy ' + i));
        }
        insert guidelines;

        // Step 3: Call the method
        Test.startTest();
        PolicyGuidelineSharingService.shareWithSoftwareEngineers();
        Test.stopTest();

        // Step 4: Verify share records
        List<PolicyGuideline__Share> shares = [SELECT ParentId, UserOrGroupId, AccessLevel FROM PolicyGuideline__Share];
        System.assertEquals(3, shares.size(), 'All PolicyGuideline records should have a share record');
        for(PolicyGuideline__Share sh : shares) {
            System.assertEquals('Read', sh.AccessLevel);
            System.assertEquals(grp.Id, sh.UserOrGroupId);
        }
    }

    @isTest
    static void testShareWithSoftwareEngineers_NoGroup() {
        // No group inserted
        List<PolicyGuideline__c> guidelines = new List<PolicyGuideline__c>();
        guidelines.add(TestDataFactory.createPolicyGuideline('Policy X'));
        insert guidelines;

        Test.startTest();
        // Should not throw exception, handled in try-catch
        PolicyGuidelineSharingService.shareWithSoftwareEngineers();
        Test.stopTest();

        List<PolicyGuideline__Share> shares = [SELECT Id FROM PolicyGuideline__Share];
        System.assertEquals(0, shares.size(), 'No share record should be created without group');
    }
}