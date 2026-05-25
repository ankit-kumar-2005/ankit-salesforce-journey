/*Name:AccountTriggerHandler
 * AuthorName:Ankit Kumar
 * Discription:Solve the question of Trigger Assigment i.e Q1,Q8,Q12,Q13,Q16
 * Date:31/08/25
 */


/*
public with sharing class AccountTriggerHandler {

    // Q1: Create a default Contact for new Accounts
   public static void q1CreateDefaultContact(List<Account> newAccounts){
        
    List<Contact> contactToInsert= new List<Contact>();
    for(Account acc:newAccounts){
        Contact recordOfContactToAdded=new Contact();
        recordOfContactToAdded.AccountId=acc.Id;
        recordOfContactToAdded.LastName=acc.Name;
        contactToInsert.add(contactToInsert);
    }

    if(!contactToInsert.isEmpty()){
        Database.insert(contactToInsert,false);
    }

   }

    // Q16: Create Education-specific Contacts
    public static void q16CreateEducationContacts(List<Account> newAccounts){
        List<Contact> educationContacts = new List<Contact>();
        List<Contact> defaultContacts = new List<Contact>();

        for(Account acc : newAccounts){
            if(acc.Industry != null && acc.Industry == 'Education'){
                educationContacts.add(new Contact(LastName='Principal', AccountId=acc.Id, Title='Principal'));
                educationContacts.add(new Contact(LastName='Teacher', AccountId=acc.Id, Title='Teacher'));
                educationContacts.add(new Contact(LastName='Student', AccountId=acc.Id, Title='Student'));
            } else if(String.isNotBlank(acc.Name)){
                defaultContacts.add(new Contact(LastName=acc.Name, AccountId=acc.Id));
            }
        }

        try{
            if(!educationContacts.isEmpty()) Database.insert(educationContacts, false);
            if(!defaultContacts.isEmpty()) Database.insert(defaultContacts, false);
        } catch(DmlException ex){
            System.debug('Error creating Contacts: ' + ex.getMessage());
        }
    }

    // Q12: Ensure every Account has a parent; assign Global Account if missing
    public static void q12AssignDefaultParent(List<Account> newAccounts){
        Map<String, Account> globalParentMap = new Map<String, Account>();
        List<Account> globalParents = [SELECT Id, Name FROM Account WHERE Name='Global Account' LIMIT 1];
        if(!globalParents.isEmpty()){
            globalParentMap.put('GlobalParent', globalParents[0]);
        }

        for(Account acc : newAccounts){
            if(acc.ParentId == null && globalParentMap.containsKey('GlobalParent')){
                acc.ParentId = globalParentMap.get('GlobalParent').Id;
            }
        }
    }

    // Q13: Close open Opportunities when Account Active__c set to 'No'
    public static void q13CloseOpportunitiesOnInactive(Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap){
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        for(Id accId : newAccountMap.keySet()){
            Account oldAcc = oldAccountMap.get(accId);
            Account newAcc = newAccountMap.get(accId);

            if(oldAcc.Active__c != null && oldAcc.Active__c == 'Yes' && newAcc.Active__c == 'No'){
                List<Opportunity> openOpps = [
                    SELECT Id, StageName 
                    FROM Opportunity 
                    WHERE AccountId=:accId AND StageName NOT IN ('Closed Won','Closed Lost')
                ];
                for(Opportunity opp : openOpps){
                    opp.StageName = 'Closed Lost';
                    opportunitiesToUpdate.add(opp);
                }
            }
        }

        if(!opportunitiesToUpdate.isEmpty()){
            try{
                Database.update(opportunitiesToUpdate, false);
            } catch(DmlException ex){
                System.debug('Error closing Opportunities: ' + ex.getMessage());
            }
        }
    }

    // Q8: Prevent deletion of Accounts with open Opportunities
    public static void q8PreventDeletion(List<Account> oldAccounts){
        Set<Id> accountIds = new Set<Id>();
        for(Account acc : oldAccounts) accountIds.add(acc.Id);

        if(!accountIds.isEmpty()){
            List<Opportunity> relatedOpenOpps = [
                SELECT AccountId 
                FROM Opportunity 
                WHERE AccountId IN :accountIds AND StageName NOT IN ('Closed Won','Closed Lost')
            ];

            Set<Id> accountsWithOpenOpps = new Set<Id>();
            for(Opportunity opp : relatedOpenOpps) accountsWithOpenOpps.add(opp.AccountId);

            for(Account acc : oldAccounts){
                if(accountsWithOpenOpps.contains(acc.Id)){
                    acc.addError('Cannot delete Account with open Opportunities.');
                }
            }
        }
    }
//===============================================


    public static void processOutOfBusinessUpdates(Map<Id, Account> previousMap, Map<Id, Account> currentMap) {
        Set<Id> accountsMarkedClosed = new Set<Id>();

        // Identify accounts whose Out_of_Business__c changed to TRUE
        for (Id accId : currentMap.keySet()) {
            Account oldAcc = previousMap.get(accId);
            Account newAcc = currentMap.get(accId);

            if ((oldAcc.Out_of_Business__c == null || oldAcc.Out_of_Business__c == false) 
                && newAcc.Out_of_Business__c == true) {
                accountsMarkedClosed.add(accId);
            }
        }

        if (accountsMarkedClosed.isEmpty()) return;

        // Update related Opportunities to Closed Lost
        List<Opportunity> relatedOpps = [
            SELECT Id, StageName, AccountId
            FROM Opportunity
            WHERE AccountId IN :accountsMarkedClosed
            AND StageName != 'Closed Lost'
        ];

        for (Opportunity opp : relatedOpps) {
            opp.StageName = 'Closed Lost';
        }

        if (!relatedOpps.isEmpty()) {
            update relatedOpps;
        }

        // Notify account owners via email
        List<Account> affectedAccounts = [
            SELECT Id, Name, Owner.Email
            FROM Account
            WHERE Id IN :accountsMarkedClosed
        ];

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (Account acc : affectedAccounts) {
            if (acc.Owner.Email != null) {
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                msg.setToAddresses(new List<String>{acc.Owner.Email});
                msg.setSubject('Notice: Account Closed as Out of Business - ' + acc.Name);
                msg.setPlainTextBody(
                    'Hi,\n\n' +
                    'The account "' + acc.Name + '" has been marked as Out of Business. ' +
                    'All active opportunities have been automatically updated to Closed Lost.\n\n' +
                    'Thank you,\nSalesforce Automation'
                );
                emailList.add(msg);
            }
        }

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList, false);
        }
    }
}
    */
    public with sharing class AccountTriggerHandler {

        public static void createContact(List<Account> newAccounts){
            //collection to insert a new contacts
            List<Contact> contactsToInsert = new List<Contact>();

            for(Account acc: newAccounts){
                Contact recordOfContactAdded= new Contact();
                recordOfContactAdded.AccountId =acc.Id;
                recordOfContactAdded.LastName=acc.Name;

                contactsToInsert.add(recordOfContactAdded);

            }

            if(!contactsTOInsert.isEmpty()){
                    Database.insert(contactsToInsert,false);
            }

        }

        // if the owner of an account is changed then the owner for the related contacts should also be updated.
        public static void updateContactOwner(Map<Id,Account> oldMap,List<Account> newAccounts){

            //store the value of Account Id whose owner is changed
             Set<Id> setOfAccIds= new Set<Id>();

            for(Account acc: newAccounts) {
                if(acc.OwnerId != oldMap.get(acc.Id).OwnerId){
                    setOfAccIds.add(acc.Id);

                }
            }
            List<Contact> contactsToUpdate = [SELECT Id, OwnerId,Account.OwnerId FROM
                                            Contact WHERE AccountId IN :setOfAccIds];
                                    
            for(Contact con: contactsToUpdate){
                       con.OwnerId = con.Account.OwnerId;
            }

            if(!contactsToUpdate.isEmpty()){
                Database.update(contactsToUpdate,false);
            }

           
        }

        public static void updateOpportunityStage(Map<Id,Account> oldMap,List<Account> listOfNewAccounts){

              Set<Id> setOfAccountIds = new Set<Id>();
              for(Account recordOfAccount: listOfNewAccounts){
                    Account oldAccountRecord = oldMap.get(recordOfAccount.Id);
                    if(oldAccountRecord.Out_of_Business__c == false && recordOfAccount.Out_of_Business__c == true){
                          setOfAccountIds.add(recordOfAccount.Id);
                    }
              }

              List<Opportunity> listOfOpportunities = [SELECT Id,StageName FROM Opportunity WHERE AccountId IN: setOfAccountIds];

              for(Opportunity opp: listOfOpportunities){
                    opp.StageName = 'Closed Lost';
              }

              if(!listOfOpportunities.isEmpty()){
                    Database.update(listOfOpportunities,false);
              }
        }

        public static void updateContactMailing(Map<Id,Account> oldAccounts,List<Account> newAccounts){
                 //step 1: identify the accounts whose billing address is changed
            Set<Id> setOfChangedAccountIds = new Set<Id>();
                  for(Account acc: newAccounts){
                   Account oldAccount=oldAccounts.get(acc.Id);
                    if(oldAccount.BillingCity != acc.BillingCity){
                        setOfChangedAccountIds.add(acc.Id);
                    }

                  }
                  //step 2: get the contacts related to the accounts whose billing address is changed
                  List<Contact> listOfContactsToUpdate =[SELECT AccountId,MailingCity FROM Contact WHERE AccountId IN :setOfChangedAccountIds];
                    Map<Id,String> mapOfAccountIdAndBillingCity = new Map<Id,String>();
             
                     for(Account acc: newAccounts){
                        mapOfAccountIdAndBillingCity.put(acc.Id,acc.BillingCity);
                     }

                  //step 3: update the mailing address of the contacts
                  for(Contact con: listOfContactsToUpdate){
                    con.MailingCity = mapOfAccountIdAndBillingCity.get(con.AccountId);
                  }

                  if(!listOfContactsToUpdate.isEmpty()){
                    Database.update(listOfContactsToUpdate,false);

                  }

        }

    //     public static void preventAccountName(List<Account> newAccounts){

    //         Map<String , Account> mapOfAccountNameAndAccount = new Map<String, Account>();
    //         List<Account> listOfAccount=[SELECT Id,Name FROM Account];
    //         for(Account acc: listOfAccount){
    //             mapOfAccountNameAndAccount.put(acc.Name,acc);
    //         }
    //         for(Account acc: newAccounts){
    //             if(mapOfAccountNameAndAccount.containsKey(acc.Name)){
    //                 acc.addError('Account name already exists');
    //         }

    //     }
        
    // }
}