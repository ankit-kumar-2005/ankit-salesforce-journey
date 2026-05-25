/*
@Name:MySoqlExample
@Author:Ankit Kumar
@Description:Example of SOQL,List,Set and Map
@Date:20/08/25
*/


public class MySoqlExample {
    //question 01---------------------------------------------------------------------------------------------------------------   
    /**
* @Accounts having more than 5 Contacts. update theContact’s Description field to Primary Contact.
* @return void
*/
    public static List<Opportunity> getHighValueOpportunities(Decimal minAmount){
        
        return [SELECT Id,Name,Amount,StageName,CloseDate FROM Opportunity WHERE Amount>:minAmount and StageName !='ClosedLost'
                ORDER BY Amount DESC
                LIMIT 50];
        
    }
    public static void updatePrimaryContactForAccounts() {
        try {
            // Collect accounts having more than 5 contacts
            Set<Id> eligibleAccountIds = new Set<Id>();
            List<AggregateResult>aggResults=[
                SELECT AccountId 
                FROM Contact 
                WHERE AccountId != null 
                GROUP BY AccountId 
                HAVING COUNT(Id) > 5
            ];
            
            for (AggregateResult groupedResult :aggResults ) {
                eligibleAccountIds.add((Id)groupedResult.get('AccountId'));
            }
            
            // Exit if no accounts found
            if (eligibleAccountIds.isEmpty()) {
                return;
            }
            
            // Fetch all contacts for those accounts
            List<Contact> primaryContactsList = [
                SELECT Id 
                FROM Contact 
                WHERE AccountId IN :eligibleAccountIds
            ];
            
            // Update description field for each contact
            for (Contact contactRecord : primaryContactsList) {
                contactRecord.Description = 'Primary Contact';
            }
            
            // Save updated contacts back to database
            if (!primaryContactsList.isEmpty()) {
                update primaryContactsList;
            }
        } 
        catch (DmlException dmlEx) {
            // Handles issues during DML operations
            System.debug('DML Exception: ' + dmlEx.getMessage());
            System.debug('Line Number'+dmlEx.getLineNumber());
        } 
        catch (NullPointerException nullEx) {
            // Handles null reference errors
            System.debug('Null Pointer Exception: ' + nullEx.getMessage());
            System.debug('Line Number'+nullEx.getLineNumber());
        } 
        catch (QueryException queryEx) {
            // Handles SOQL query issues
            System.debug('Query Exception: ' + queryEx.getMessage());
            System.debug('Line Number'+ queryEx.getLineNumber());
        } 
        catch (LimitException limitEx) {
            // Handles governor limits (like SOQL, DML limits)
            System.debug('Governor Limit Exception: ' + limitEx.getMessage());
            System.debug('Line Number'+limitEx.getLineNumber());
        }
        catch (Exception ex) {
            // Catches any other unhandled exceptions
            System.debug('General Exception: ' + ex.getMessage());
            System.debug('Line Number'+ex.getLineNumber());
        }
       
    }
    //question02____________________________________________________________________________________________________
    /**
* @description Updates Accounts with AnnualRevenue greater than 1,000,000 by setting their Rating to 'Hot'
* @return void
*/
    
    public static void updateHotAccountsByRevenue() {
        try {
            // Fetch accounts where annual revenue is greater than 1,000,000
            List<Account> listOfAccount = [
                SELECT Id, Rating, AnnualRevenue 
                FROM Account 
                WHERE AnnualRevenue > 1000000
            ];
            
            // List to store accounts that need to be updated
            List<Account> listOfAccountToUpdate = new List<Account>();
            
            // Loop through each account and set rating to 'Hot'
            for (Account acc : listOfAccount) {
                Account accountToInsert = new Account();
                accountToInsert.Id = acc.Id;
                accountToInsert.Rating = 'Hot';
                listOfAccountToUpdate.add(accountToInsert);
            }
            
            // Update all accounts if the list is not empty
            if (!listOfAccountToUpdate.isEmpty()) {
                update listOfAccountToUpdate;
            }
        } 
       
        catch (Exception ex) {
            // Catches any other unhandled exceptions
            System.debug('General Exception: ' + ex.getMessage());
            
        } 
        finally {
            // Always runs, useful for logging or cleanup
            System.debug('Process Completed');
        }
    }
    
    //question03__________________________________________________________________________________________________________________________
    /**
* @description Queries all Opportunities with past CloseDate that are not 'Closed Won' or 'Closed Lost',
*              and updates their StageName to 'Closed Lost'.
* @return void
*/
    public static void updateOpportunitiesToClosedLost() {
        try {
            // Query all opportunities where CloseDate is in the past 
            // and StageName is not already 'Closed Won' or 'Closed Lost'
            List<Opportunity> oppList = [
                SELECT Id, StageName, CloseDate 
                FROM Opportunity 
                WHERE CloseDate < :System.today() 
                AND StageName NOT IN ('Closed Won','Closed Lost')
            ];
            
            // List to hold opportunities that need to be updated
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            
            // Loop through opportunities and mark them as 'Closed Lost'
            for (Opportunity opp : oppList) {
                Opportunity updatedOpp = new Opportunity();
                updatedOpp.Id = opp.Id;
                updatedOpp.StageName = 'Closed Lost';
                oppListToUpdate.add(updatedOpp);
            }
            
            // Update records if the list is not empty
            if (!oppListToUpdate.isEmpty()) {
                update oppListToUpdate;
            }
        } 
       
        catch (Exception ex) {
            // Catches any other unhandled exceptions
            System.debug('General Exception: ' + ex.getMessage());
            
        } 
        finally {
            // Always runs, useful for logging or cleanup
            System.debug('Process Completed');
        }
    }
    
    
    //question04______________________________________________________________________________________________________________
    
    
    
    /**
* @description Updates Employee records that joined more than 6 months ago 
*              and are not resigned, by setting their Status__c to 'Probation'.
* @return void
*/
    
    public static void updateEmployeeStatusToProbation() {
        try {
            // Query employees who joined more than 6 months ago and are not resigned
            List<Employee__c> employeesToCheck = [
                SELECT Id, Joining_Date__c, Status__c 
                FROM Employee__c 
                WHERE Joining_Date__c < LAST_N_MONTHS:6 
                AND Status__c != 'Resigned'
            ];
            
            // List to hold employees that need to be updated
            List<Employee__c> employeesToUpdate = new List<Employee__c>();
            
            // Update employee status to 'Probation'
            for (Employee__c currentEmployee : employeesToCheck) {
                currentEmployee.Status__c = 'Probation';
                employeesToUpdate.add(currentEmployee);
            }
            
            // Perform bulk update if list is not empty
            if (!employeesToUpdate.isEmpty()) {
                update employeesToUpdate;
                System.debug('Updated Employees: ' + employeesToUpdate.size());
            } else {
                System.debug('No Employees matched criteria.');
            }
        } 
       
        catch (Exception ex) {
            // Catches any other unhandled exceptions
            System.debug('General Exception: ' + ex.getMessage());
            
        } 
        
    }
    
    //question05____________________________________________________________________________________________________________
    
    
    /**
* @description Queries all Accounts that don’t have any related Contacts. 
*              For each such Account, creates a default Contact with LastName = 'Default Contact'
*              and inserts all new Contacts.
* @return void
*/
    public static void createDefaultContactsForAccountsWithoutContacts() {
        try {
            // Query accounts that do not have any related contacts
            List<Account> accountsWithoutContacts = [
                SELECT Id 
                FROM Account 
                WHERE Id NOT IN (SELECT AccountId FROM Contact)
            ];
            
            // List to hold new contacts to insert
            List<Contact> contactsToInsert = new List<Contact>();
            
            // Create a default contact for each account without a contact
            for (Account acc : accountsWithoutContacts) {
                Contact c = new Contact();
                c.LastName = 'Default Contact';
                c.AccountId = acc.Id;
                contactsToInsert.add(c);
            }
            
            // Insert all default contacts if list is not empty
            if (!contactsToInsert.isEmpty()) {
                insert contactsToInsert;
                System.debug('Inserted Contacts: ' + contactsToInsert.size());
            } else {
                System.debug('No Accounts found without contacts.');
            }
        } 
         
        catch (Exception ex) {
            // Catches any other unhandled exceptions
            System.debug('General Exception: ' + ex.getMessage());
            System.debug('Stack Trace: ' + ex.getStackTraceString());
        } 
       
    }
    
    //	Question06_______________________________________________________________________________________________________________
    /**
* @description Queries all Opportunities where StageName = 'Closed Won'. 
*              Then queries all related Tasks for those Opportunities and deletes them.
* @return void
*/
    public static void deleteTasksForClosedWonOpportunities() {
        try {
            // Query opportunities that are in 'Closed Won' stage
            List<Opportunity> closedWonOpps = [
                SELECT Id 
                FROM Opportunity 
                WHERE StageName = 'Closed Won'
            ];
            
            // Collect opportunity Ids into a set
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity opp : closedWonOpps) {
                oppIds.add(opp.Id);
            }
            
            // If there are opportunities, fetch related tasks
            if (!oppIds.isEmpty()) {
                List<Task> tasksToDelete = [
                    SELECT Id 
                    FROM Task 
                    WHERE WhatId IN :oppIds
                ];
                
                // Delete tasks if any exist
                if (!tasksToDelete.isEmpty()) {
                    delete tasksToDelete;
                    System.debug('Deleted Tasks: ' + tasksToDelete.size());
                } else {
                    System.debug('No Tasks found for Closed Won Opportunities.');
                }
            } else {
                System.debug('No Closed Won Opportunities found.');
            }
        } 
       
        catch (Exception ex) {
            // Catches any other unhandled exceptions
            System.debug('General Exception: ' + ex.getMessage());
            
        } 
        
    }
    
    
    //Question 07__________________________________________________________________________________________________
    /**
* @description Queries all Contacts that belong to Accounts in the 'Education' industry. 
*              Updates the Department of each Contact to 'Education Services'.
* @return void
*/
    public static void updateContactsDepartmentForEducationAccounts() {
        try {
            // Query contacts whose parent account is in the Education industry
            List<Contact> contactsList = [
                SELECT Id, Department, Account.Industry 
                FROM Contact 
                WHERE Account.Industry = 'Education'
            ];
            
            // List to hold contacts that need updating
            List<Contact> contactsToUpdate = new List<Contact>();
            
            // Update Department field for each contact
            for (Contact c : contactsList) {
                Contact temp = new Contact();
                temp.Id = c.Id;
                temp.Department = 'Education Services';
                contactsToUpdate.add(temp);
            }
            
            // Update contacts if the list is not empty
            if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;
                System.debug('Updated Contacts: ' + contactsToUpdate.size());
            } else {
                System.debug('No Contacts found for Education accounts.');
            }
        } 
       
        catch (Exception ex) {
            // Catches any other unhandled exceptions
            System.debug('General Exception: ' + ex.getMessage());
            
        } 
        
    }
    
    //Question08__________________________________________________________________________________________________
    /**
* @description Queries all Accounts with their related Contacts and Opportunities. 
*              For Accounts with more than 3 Contacts and at least one Opportunity 
*              in 'Closed Won' stage, updates the Account Rating to 'Hot'.
* @return void
*/
    public static void updateHotAccountsBasedOnContactsAndOpportunities() {
        try {
            // Query all accounts with related contacts and opportunities
            List<Account> accList = [
                SELECT Id, Rating,
                (SELECT Id FROM Contacts),
                (SELECT Id, StageName FROM Opportunities)
                FROM Account
            ];
            
            // List to hold accounts that need updating
            List<Account> accountsToUpdate = new List<Account>();
            
            for (Account acc : accList) {
                // Check if Account has more than 3 Contacts
                Boolean hasEnoughContacts = acc.Contacts != null && acc.Contacts.size() > 3;
                
                // Check if Account has at least one Closed Won Opportunity
                Boolean hasClosedWonOpp = false;
                if (acc.Opportunities != null) {
                    for (Opportunity opp : acc.Opportunities) {
                        if (opp.StageName == 'Closed Won') {
                            hasClosedWonOpp = true;
                            break;
                        }
                    }
                }
                
                // If both conditions are satisfied, update Rating
                if (hasEnoughContacts && hasClosedWonOpp) {
                    Account temp = new Account();
                    temp.Id = acc.Id;
                    temp.Rating = 'Hot';
                    accountsToUpdate.add(temp);
                }
            }
            
            // Update accounts if the list is not empty
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
                System.debug('Updated Accounts: ' + accountsToUpdate.size());
            } else {
                System.debug('No Accounts met criteria for update.');
            }
        } 
       
        catch (Exception ex) {
            // Catches any other unhandled exceptions
            System.debug('General Exception: ' + ex.getMessage());
            
        } 
      
    }
    
    
    //question09____________________________________________________________________________________________________________
    /**
* @description Queries all Accounts with their related Contacts and Opportunities. 
*              For Accounts that have at least one Contact with Title = 'Manager' 
*              and at least one Opportunity in StageName = 'Prospecting', 
*              updates the Account Rating to 'Warm'.
* @return void
*/
    public static void updateWarmAccountsBasedOnManagerAndProspectingOpps() {
        try {
            // Query all accounts with related contacts and opportunities
            List<Account> accList = [
                SELECT Id, Rating,
                (SELECT Id, Title FROM Contacts),
                (SELECT Id, StageName FROM Opportunities)
                FROM Account
            ];
            
            // List to hold accounts that need updating
            List<Account> accountsToUpdate = new List<Account>();
            
            for (Account acc : accList) {
                Boolean hasManagerContact = false;
                Boolean hasProspectingOpp = false;
                
                // Check if at least one Contact has Title 'Manager'
                if (acc.Contacts != null) {
                    for (Contact c : acc.Contacts) {
                        if (c.Title == 'Manager') {
                            hasManagerContact = true;
                            break;
                        }
                    }
                }
                
                // Check if at least one Opportunity is in 'Prospecting' stage
                if (acc.Opportunities != null) {
                    for (Opportunity opp : acc.Opportunities) {
                        if (opp.StageName == 'Prospecting') {
                            hasProspectingOpp = true;
                            break;
                        }
                    }
                }
                
                // If both conditions are satisfied, update Rating to 'Warm'
                if (hasManagerContact && hasProspectingOpp) {
                    Account temp = new Account();
                    temp.Id = acc.Id;
                    temp.Rating = 'Warm';
                    accountsToUpdate.add(temp);
                }
            }
            
            // Update accounts if the list is not empty
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
                System.debug('Updated Accounts: ' + accountsToUpdate.size());
            } else {
                System.debug('No Accounts met criteria for update.');
            }
        } 
       
        catch (Exception ex) {
            // Catches any other unhandled exceptions
            System.debug('General Exception: ' + ex.getMessage());
            
        } 
       
    }
    
    //question10__________________________________________________________________________________________________________
    /**
* @description Queries all Contacts along with their related Tasks and parent Account. 
*              If a Contact has more than 3 Tasks with Status = 'Not Started', 
*              updates the parent Account’s SLA__c field to 'Review Needed'.
* @return void
*/
    public static void updateAccountsSLAForContactsWithPendingTasks() {
        try {
            // Query contacts with related tasks and their parent account
            List<Contact> contactList = [
                SELECT Id, AccountId,
                (SELECT Id, Status FROM Tasks WHERE Status ='Not Started')
                FROM Contact
                WHERE AccountId != null
            ];
            Set<Id> idOfAcc= new set<id>();
            List<Account> listOfAccount = new List<Account>();
            
            
            for (Contact c : contactList) {
                
                // Count tasks with Status = 'Not Started'
                if (c.Tasks.Size()>3) {
                    idOfAcc.add(c.AccountId);
                }
            }
            
            // If more than 3 pending tasks, mark parent Account for update
            
            for(Id id:idOfAcc)   {
                Account acc = new Account();
            acc.Id = id;
            acc.SLA__c = 'Review Needed';
            listOfAccount.add(acc);
            
            
        }
            if(!listOfAccount.isEmpty()){
                Update listOfAccount;
            }
        
    } 
    
    catch (Exception ex) {
        // Catches any other unhandled exceptions
        System.debug('General Exception: ' + ex.getMessage());
        
    } 
    finally {
        // Always runs, useful for logging or cleanup
        System.debug('Process Completed');
    }
}

//question11____________________________________________________________________________________________________________________
/**
* @description Updates Account.Industry to 'Enterprise' if its Opportunity
* has Amount > 100,000 and at least one Line Item with Quantity > 10
* @return void
*/
public static void updateAccountsByOpportunity() {
    try {
        // Query Opportunities with their Line Items and Account
        List<Opportunity> oppList = [
            SELECT Id, Amount, AccountId,
            (SELECT Id, Quantity FROM OpportunityLineItems)
            FROM Opportunity
            WHERE Amount > 100000
            AND AccountId != null
        ];
        
        // Prepare list of Accounts to update
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        
        for (Opportunity opp : oppList) {
            Boolean hasEligibleLineItem = false;
            
            // Check if any Line Item has Quantity > 10
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                if (oli.Quantity > 10) {
                    hasEligibleLineItem = true;
                    break;
                }
            }
            
            // If condition satisfied, add Account for update
            if (hasEligibleLineItem) {
                accountsToUpdate.put(
                    opp.AccountId,
                    new Account(Id = opp.AccountId, Industry = 'Enterprise')
                );
            }
        }
        
        // Perform update if we have Accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate.values();
        }
    }
  
    catch (Exception ex) {
        System.debug('General Exception: ' + ex.getMessage());
    }
  
}



//question 12_____________________________________________________________________________________________________________

/**
* @description Queries Accounts that have at least one Gmail Contact 
*              and more than two Open Cases, then creates a Task 
*              to verify contact information.
* @return void
*/

public static void createVerificationTasksForAccounts() {
    try {
        // Query Accounts with Gmail contacts and open cases
        List<Account> accountsToCheck = [
            SELECT Id,
            (SELECT Id, Email FROM Contacts WHERE Email LIKE '%@gmail.com'),
            (SELECT Id, Status FROM Cases WHERE Status != 'Closed')
            FROM Account
        ];
        
        // List to hold Tasks to insert
        List<Task> tasksToCreate = new List<Task>();
        
        // Apply conditions on each Account
        for (Account currentAccount : accountsToCheck) {
            Boolean hasGmailContact = currentAccount.Contacts != null && currentAccount.Contacts.size() > 0;
            Integer openCaseCount = currentAccount.Cases != null ? currentAccount.Cases.size() : 0;
            
            if (hasGmailContact && openCaseCount > 2) {
                tasksToCreate.add(new Task(
                    WhatId   = currentAccount.Id,
                    Subject  = 'Verify Contact Information',
                    Status   = 'Not Started',
                    Priority = 'Normal'
                ));
            }
        }
        
        // Insert tasks if the list is not empty
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
            System.debug('Inserted Tasks: ' + tasksToCreate.size());
        } else {
            System.debug('No Accounts matched criteria.');
        }
    } 
   
    catch (Exception ex) {
        // Catches any other unhandled exceptions
        System.debug('General Exception: ' + ex.getMessage());
        System.debug('Line Number'+ex.getLineNumber());
        
    } 
  
}
}