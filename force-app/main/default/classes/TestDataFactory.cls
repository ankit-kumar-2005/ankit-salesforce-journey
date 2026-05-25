/* 
 @Name: TestDataFactory
 @Author: Ankit Kumar
 @Description: TestDataFactory for SOQL Assignment 
 @Date: 28/08/25
*/
public class TestDataFactory {
    /*
     @Create Account Factory
     */
    
    // Account Factory
    public static Account createAccount(String name, Decimal annualRevenue, String industry) {
        return new Account(
            Name = name,
            AnnualRevenue = annualRevenue,
            Industry = industry
        );
    }
    //Lead Factory
    public static Lead createLead(String firstName,String LastName,String Company,String LeadSource ){
             
        return new Lead(
            FirstName = firstName,
            LastName = LastName,
            Company = Company,
            LeadSource = LeadSource
              );

    }
    
    // Contact Factory
    public static Contact createContact(String fName, String lName, Id accountId, String title, String email) {
        return new Contact(
            FirstName = fName,
            LastName = lName,
            AccountId = accountId,
            Title = title,
            Email = email
        );
    }
    
    // Opportunity Factory
    public static Opportunity createOpportunity(String name, Id accountId, Date closeDate, String stageName) {
        return new Opportunity(
            Name = name,
            AccountId = accountId,
            CloseDate = closeDate,
            StageName = stageName
        );
    }
    
    // Employee Factory
  /*  public static Employee__c createEmployee(String name, Date joiningDate, String status) {
        return new Employee__c(
            Name = name,
            Joining_Date__c = joiningDate,
            Status__c = status
        );
    }
*/
   // Employee Factory
public static Employee__c createEmployee(
    String name,
    Date joiningDate,
    Boolean resigned,
    String employmentStatus,
    Date dob,
    String primaryContactNo,
    String aadharNo,
    String address,
    String currentLocation,
    String panCardNo,
    String workMode,
    Integer totalExperience,
    String department
) {
    return new Employee__c(
        Name = name,
        Joining_Date__c = joiningDate,
        Resigned__c = resigned,
        Employment_Status__c = employmentStatus,
        Date_of_Birth__c = dob,
        Primary_Contact_No__c = primaryContactNo,
        Aadhar_Number__c = aadharNo,
        Address__c = address,
        Current_Location__c = currentLocation,
        Pan_Card_Number__c = panCardNo,
        Work_Mode__c = workMode,
        Total_Experience_in_year__c = totalExperience,
        Department__c = department
    );
}
//Email template Factory
// Inside TestDataFactory.cls
public static EmailTemplate createEmailTemplate(
    String name,
    String developerName,
    String subject,
    String htmlValue
) {
    return new EmailTemplate(
        Name          = name,
        DeveloperName = developerName,
        TemplateType  = 'text',          // simplest type for unit tests
        Subject       = subject,
        HtmlValue     = htmlValue,
        FolderId      = UserInfo.getUserId() // current user’s private folder
    );
}


    //Task Factory
public static Task createTask(Id owner,String status,String subject,String Priority,Date activityDate){
    return new Task(
        ownerId=owner,
        Status=status,
        Subject=subject,
        Priority=Priority,
        ActivityDate=activityDate
        );
}
    // Case Factory
    public static Case createCase(Id accId, String status) {
        return new Case(
            AccountId = accId,
            Status = status
        );
    }
    // Create PolicyGuideline record
    public static PolicyGuideline__c createPolicyGuideline(String name) {
        return new PolicyGuideline__c(
            Name = name
        );
    }

    //create user
    public static User createUser(String usernamePrefix,String profileName){
        profile p=[SELECT ID FROM Profile WHERE Name= :profileName Limit 1];
        return new User(
          Alias = usernamePrefix.substring(0, Math.min(8, usernamePrefix.length())), // Alias must be <= 8 chars
                Email = usernamePrefix + '@testuser.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestUser',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'Asia/Kolkata',
                Username = usernamePrefix + System.currentTimeMillis() + '@communitytest.com'
        );
    }

    // Create a test Group for Software Engineers
    public static Group createSoftwareEngineerGroup() {
        return new Group(
            Name = 'Software Engineer Group',
            DeveloperName = 'Software_Engineer_Group',
            Type = 'Regular'
        );
    }
    // Product Factory
    public static Product2 createProduct(String name, Boolean isActive) {
        return new Product2(
            Name = name,
            IsActive = isActive
        );
    }

    // PricebookEntry Factory
    public static PricebookEntry createPricebookEntry(Id productId, Id pricebookId, Decimal unitPrice, Boolean isActive) {
        return new PricebookEntry(
            Product2Id = productId,
            Pricebook2Id = pricebookId,
            UnitPrice = unitPrice,
            IsActive = isActive
        );
    }

    // OpportunityLineItem Factory
    public static OpportunityLineItem createOpportunityLineItem(Id oppId, Id pricebookEntryId, Decimal unitPrice, Integer quantity) {
        return new OpportunityLineItem(
            OpportunityId = oppId,
            PricebookEntryId = pricebookEntryId,
            UnitPrice = unitPrice,
            Quantity = quantity
        );
    }
}