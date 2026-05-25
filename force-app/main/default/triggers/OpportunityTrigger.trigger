/*
 * Name: OpportunityTrigger
 * Author Name: Ankit Kumar
 * Description: Solve the questions of Trigger Assignment i.e Q10, Q12
 * Date: 01/09/25
 */
trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, after undelete) {

    
    if (Trigger.isBefore && Trigger.isUpdate) {
        // Q12Ensure that every Account has a parent Account
        OpportunityTriggerHandler.preventClosedWonWithoutProducts(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        // Q10 whenever the StageName changes from Prospecting to Proposalcreatea new Task
        OpportunityTriggerHandler.createTaskOnStageChange(Trigger.new, Trigger.oldMap);
        OpportunityTriggerHandler.processAfterInsert(Trigger.new);

    }
    if (Trigger.isAfter) {
        Set<Id> accountIds = new Set<Id>();

        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            for (Opportunity opp : Trigger.new) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        if (Trigger.isDelete) {
            for (Opportunity opp : Trigger.old) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        if (!accountIds.isEmpty()) {
            OpportunityHandler.updateTotalOpportunityAmount(accountIds);
        }
}
     if(Trigger.isAfter && Trigger.isInsert){
        OpportunityTriggerHandler.processAfterInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        OpportunityTriggerHandler.processAfterDelete(Trigger.old);
    }

    if(Trigger.isAfter && Trigger.isUndelete){
        OpportunityTriggerHandler.processAfterUndelete(Trigger.new);
    }

}