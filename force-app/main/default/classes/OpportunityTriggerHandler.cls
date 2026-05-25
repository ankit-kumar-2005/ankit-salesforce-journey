/*
 * Name: OpportunityTriggerHandler
 * Author Name: Ankit Kumar
 * Description: Solve the questions of Trigger Assignment i.e Q10, Q12
 * Date: 01/09/25
 */
public class OpportunityTriggerHandler {
    
    // Q10: Create a Task for Opportunity Owner when Stage changes from Prospecting → Proposal/Price Quote
    public static void createTaskOnStageChange(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        List<Task> tasksToInsert = new List<Task>();
        
        for (Opportunity opp : newOppList) {
            Opportunity oldOpp = oldOppMap.get(opp.Id);
            
            if (opp.StageName == 'Proposal/Price Quote' && oldOpp.StageName == 'Prospecting') {
                Task t = new Task(
                    WhatId = opp.Id,
                    Status = 'In Progress',
                    OwnerId = opp.OwnerId,
                    ActivityDate = Date.today().addDays(4)
                );
                tasksToInsert.add(t);
            }
        }
        
        if (!tasksToInsert.isEmpty()) {
            Database.insert(tasksToInsert, false);
        }
    }
    
    // Q12: Prevent Opportunity Stage update to Closed Won if no related OpportunityLineItems exist
    public static void preventClosedWonWithoutProducts(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        Set<Id> oppIds = new Set<Id>();
        
        for (Opportunity opp : newOppList) {
            Opportunity oldOpp = oldOppMap.get(opp.Id);
            if (opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
                oppIds.add(opp.Id);
            }
        }
        
        if (!oppIds.isEmpty()) {
            Map<Id, Integer> oppToProductCount = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT OpportunityId, COUNT(Id) productCount
                FROM OpportunityLineItem
                WHERE OpportunityId IN :oppIds
                GROUP BY OpportunityId
            ]) {
                oppToProductCount.put((Id)ar.get('OpportunityId'), (Integer)ar.get('productCount'));
            }
            
            for (Opportunity opp : newOppList) {
                if (oppIds.contains(opp.Id) && (!oppToProductCount.containsKey(opp.Id) || oppToProductCount.get(opp.Id) == 0)) {
                    opp.addError('Cannot move Opportunity to Closed Won without related Opportunity Products.');
                }
            }
        }
    }
    //Day02___________________________________________________________________________________________________________________________
 

    // Handles new Opportunities inserted
    public static void processAfterInsert(List<Opportunity> oppList){
        Map<Id, Integer> prospectingMap = new Map<Id, Integer>();
        
        for(Opportunity opp : oppList){
            if(opp.AccountId != null && opp.StageName == 'Prospecting'){
                prospectingMap.put(
                    opp.AccountId, 
                    prospectingMap.containsKey(opp.AccountId) ? prospectingMap.get(opp.AccountId) + 1 : 1
                );
            }
        }
        
        if(!prospectingMap.isEmpty()){
            modifyAccounts(prospectingMap, null, false);
        }
    }

    // Handles Opportunity updates
    public static void processAfterUpdate(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap){
        Map<Id, Integer> decrementProspectingMap = new Map<Id, Integer>();
        Map<Id, Integer> incrementClosedWonMap = new Map<Id, Integer>();
        
        for(Id oppId : newOppMap.keySet()){
            Opportunity oldOpp = oldOppMap.get(oppId);
            Opportunity newOpp = newOppMap.get(oppId);

            if(oldOpp.StageName == 'Prospecting' && newOpp.StageName == 'Closed Won' && newOpp.AccountId != null){
                decrementProspectingMap.put(
                    newOpp.AccountId,
                    decrementProspectingMap.containsKey(newOpp.AccountId) ? decrementProspectingMap.get(newOpp.AccountId) + 1 : 1
                );
                incrementClosedWonMap.put(
                    newOpp.AccountId,
                    incrementClosedWonMap.containsKey(newOpp.AccountId) ? incrementClosedWonMap.get(newOpp.AccountId) + 1 : 1
                );
            }
        }

        if(!decrementProspectingMap.isEmpty() || !incrementClosedWonMap.isEmpty()){
            modifyAccounts(decrementProspectingMap, incrementClosedWonMap, true);
        }
    }

    // Handles Opportunity deletions
    public static void processAfterDelete(List<Opportunity> deletedOpps){
        Map<Id, Integer> prospectingCountMap = new Map<Id, Integer>();

        for(Opportunity opp : deletedOpps){
            if(opp.AccountId == null) continue;

            if(opp.StageName == 'Prospecting'){
                prospectingCountMap.put(
                    opp.AccountId,
                    prospectingCountMap.containsKey(opp.AccountId) ? prospectingCountMap.get(opp.AccountId)+1 : 1
                );
            } else if(opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost'){
                opp.addError('Cannot delete Opportunities in Closed Won or Closed Lost stage.');
            }
        }

        if(!prospectingCountMap.isEmpty()){
            modifyAccounts(prospectingCountMap, null, true);
        }
    }

    // Handles Opportunity undelete
    public static void processAfterUndelete(List<Opportunity> restoredOpps){
        Map<Id, Integer> prospectingCountMap = new Map<Id, Integer>();

        for(Opportunity opp : restoredOpps){
            if(opp.AccountId != null && opp.StageName == 'Prospecting'){
                prospectingCountMap.put(
                    opp.AccountId,
                    prospectingCountMap.containsKey(opp.AccountId) ? prospectingCountMap.get(opp.AccountId) + 1 : 1
                );
            }
        }

        if(!prospectingCountMap.isEmpty()){
            modifyAccounts(prospectingCountMap, null, false);
        }
    }

    // Updates Account fields
    public static void modifyAccounts(
        Map<Id, Integer> prospectingData,
        Map<Id, Integer> closedWonData,
        Boolean decrementProspecting
    ){
        if((prospectingData == null || prospectingData.isEmpty()) &&
           (closedWonData == null || closedWonData.isEmpty())){
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        if(prospectingData != null) accountIds.addAll(prospectingData.keySet());
        if(closedWonData != null) accountIds.addAll(closedWonData.keySet());

        List<Account> accountsToUpdate = new List<Account>();

        for(Account acc : [SELECT Id, No_Of_Opportunity__c, Closed_Won_Opportunity__c FROM Account WHERE Id IN :accountIds]){
            
            if(prospectingData != null && prospectingData.containsKey(acc.Id)){
                Integer current = acc.No_Of_Opportunity__c == null ? 0 : (Integer)acc.No_Of_Opportunity__c;
                acc.No_Of_Opportunity__c = decrementProspecting ? current - prospectingData.get(acc.Id) : current + prospectingData.get(acc.Id);
            }

            if(closedWonData != null && closedWonData.containsKey(acc.Id)){
                Integer currentClosed = acc.Closed_Won_Opportunity__c == null ? 0 : (Integer)acc.Closed_Won_Opportunity__c;
                acc.Closed_Won_Opportunity__c = currentClosed + closedWonData.get(acc.Id);
            }

            accountsToUpdate.add(acc);
        }

        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }


}