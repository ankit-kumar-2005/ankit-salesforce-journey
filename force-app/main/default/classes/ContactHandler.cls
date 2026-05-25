public class ContactHandler {

    // Q6: Auto-fill Email from Account if Contact Email is blank
    public static void q6FillEmailFromAccount(List<Contact> contacts){
        Set<Id> accountIdsNeedingEmail = new Set<Id>();
        for(Contact contactRecord : contacts){
            if(String.isBlank(contactRecord.Email) && contactRecord.AccountId != null){
                accountIdsNeedingEmail.add(contactRecord.AccountId);
            }
        }

        if(!accountIdsNeedingEmail.isEmpty()){
            Map<Id, Account> accountMap = new Map<Id, Account>(
                [SELECT Id, Email__c FROM Account WHERE Id IN :accountIdsNeedingEmail]
            );

            for(Contact contactRecord : contacts){
                if(String.isBlank(contactRecord.Email) && accountMap.containsKey(contactRecord.AccountId)){
                    contactRecord.Email = accountMap.get(contactRecord.AccountId).Email__c;
                }
            }
        }
    }

    // Q9: Prevent duplicate Contact with same Email + Phone
    public static void q9PreventDuplicateEmailPhone(List<Contact> contacts){
        Set<String> batchEmailPhoneSet = new Set<String>();
        for(Contact contactRecord : contacts){
            if(!String.isBlank(contactRecord.Email) && !String.isBlank(contactRecord.Phone)){
                batchEmailPhoneSet.add(contactRecord.Email + '|' + contactRecord.Phone);
            }
        }

        if(!batchEmailPhoneSet.isEmpty()){
            Set<String> emailSet = new Set<String>();
            Set<String> phoneSet = new Set<String>();
            for(Contact contactRecord : contacts){
                if(!String.isBlank(contactRecord.Email)) emailSet.add(contactRecord.Email);
                if(!String.isBlank(contactRecord.Phone)) phoneSet.add(contactRecord.Phone);
            }

            List<Contact> existingContacts = [
                SELECT Email, Phone 
                FROM Contact 
                WHERE Email IN :emailSet AND Phone IN :phoneSet
            ];

            Set<String> existingEmailPhoneSet = new Set<String>();
            for(Contact existingCon : existingContacts){
                existingEmailPhoneSet.add(existingCon.Email + '|' + existingCon.Phone);
            }

            for(Contact contactRecord : contacts){
                if(!String.isBlank(contactRecord.Email) && !String.isBlank(contactRecord.Phone) && existingEmailPhoneSet.contains(contactRecord.Email + '|' + contactRecord.Phone)){
                    contactRecord.addError('A Contact with the same Email and Phone already exists.');
                }
            }
        }
    }

    // Q15: Auto-create Opportunity if Account has none
    public static void q15CreateOpportunityForAccount(List<Contact> contacts){
        Set<Id> accountIds = new Set<Id>();
        for(Contact contactRecord : contacts){
            if(contactRecord.AccountId != null) accountIds.add(contactRecord.AccountId);
        }

        if(!accountIds.isEmpty()){
            Map<Id, Integer> accountOpportunityCountMap = new Map<Id, Integer>();
            for(AggregateResult ar : [
                SELECT AccountId accId, COUNT(Id) cnt
                FROM Opportunity
                WHERE AccountId IN :accountIds
                GROUP BY AccountId
            ]){
                accountOpportunityCountMap.put((Id)ar.get('accId'), (Integer)ar.get('cnt'));
            }

            List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
            for(Contact contactRecord : contacts){
                if(contactRecord.AccountId != null && (!accountOpportunityCountMap.containsKey(contactRecord.AccountId) || accountOpportunityCountMap.get(contactRecord.AccountId) == 0)){
                    Opportunity newOpp = new Opportunity(
                        Name = 'Auto Opportunity for ' + contactRecord.LastName,
                        StageName = 'Prospecting',
                        CloseDate = Date.today().addDays(30),
                        AccountId = contactRecord.AccountId
                    );
                    opportunitiesToInsert.add(newOpp);
                }
            }

            if(!opportunitiesToInsert.isEmpty()){
                try{
                    Database.insert(opportunitiesToInsert, false);
                } catch(DmlException e){
                    System.debug('Error creating Opportunities: ' + e.getMessage());
                }
            }
        }
    }
    //Day 2 Assignment
public static void processContacts(
    List<Contact> newContacts,
    List<Contact> oldContacts,
    Boolean isInsert,
    Boolean isUpdate,
    Boolean isDelete,
    Boolean isUndelete
) {
    Set<Id> relatedAccountIds = new Set<Id>();

    if (isInsert || isUndelete) {
        for (Contact c : newContacts) {
            if (c.AccountId != null) {
                relatedAccountIds.add(c.AccountId);
            }
        }
    }

    if (isUpdate) {
        for (Integer i = 0; i < newContacts.size(); i++) {
            Contact oldC = oldContacts[i];
            Contact newC = newContacts[i];
            if (oldC.AccountId != newC.AccountId) {
                if (oldC.AccountId != null) {
                    relatedAccountIds.add(oldC.AccountId);
                }
                if (newC.AccountId != null) {
                    relatedAccountIds.add(newC.AccountId);
                }
            }
        }
    }

    if (isDelete) {
        for (Contact c : oldContacts) {
            if (c.AccountId != null) {
                relatedAccountIds.add(c.AccountId);
            }
        }
    }

    if (!relatedAccountIds.isEmpty()) {
        Map<Id, Integer> accountToContactCount = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT AccountId accountId, COUNT(Id) contactCount
            FROM Contact
            WHERE AccountId IN :relatedAccountIds
            GROUP BY AccountId
        ]) {
            accountToContactCount.put(
                (Id) ar.get('accountId'), 
                (Integer) ar.get('contactCount')
            );
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : relatedAccountIds) {
            Integer contactCount;
            if (accountToContactCount.containsKey(accId)) {
                contactCount = accountToContactCount.get(accId);
            } else {
                contactCount = 0;
            }

            Account acc = new Account(
                Id = accId,
                No_of_Contacts__c = contactCount
            );
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}

}