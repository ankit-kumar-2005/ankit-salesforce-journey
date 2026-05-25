/*
 * Name:AccountTrigeer
 * Author Name:Ankit Kumar
 * Discription:Solve the question of Trigger Assigment i.e Q1,Q8,Q12,Q13,Q16
 * Date:31/08/25
 */


/*
trigger AccountTrigger on Account (
    before insert, before update, before delete,
    after insert, after update
) {
    try {
        if(Trigger.isBefore){
            // Q12: Ensure parent account is assigned
            AccountTriggerHandler.q12AssignDefaultParent(Trigger.new);

            // Q8: Prevent deletion if open Opportunities exist
            if(Trigger.isDelete){
                AccountTriggerHandler.q8PreventDeletion(Trigger.old);
            }
        }

        if(Trigger.isAfter){
            if(Trigger.isInsert){
                // Q1: Create default Contact for new Accounts
                AccountTriggerHandler.q1CreateDefaultContact(Trigger.new);

                // Q16: Create Education-specific Contacts
                AccountTriggerHandler.q16CreateEducationContacts(Trigger.new);
            }

            if(Trigger.isUpdate){
                // Q13: Close open Opportunities if Account set to inactive
                AccountTriggerHandler.q13CloseOpportunitiesOnInactive(Trigger.oldMap, Trigger.newMap);
            }
if (Trigger.isUpdate) {
            AccountTriggerHandler.processOutOfBusinessUpdates(Trigger.oldMap, Trigger.newMap);
        }
        }
    } catch(Exception ex){
        System.debug('Error in AccountTrigger: ' + ex.getMessage());
    }
}
*/

trigger AccountTrigger on Account(after insert,after update,before insert,before update){
    if(Trigger.isAfter){
        if(Trigger.isInsert){
                 AccountTriggerHandler.createContact(Trigger.new);
                
        }
        // if the owner of an account is changed then the owner for the related contacts should also be updated.
        if(Trigger.isUpdate){
             AccountTriggerHandler.updateContactOwner(Trigger.oldMap,Trigger.new);  
             AccountTriggerHandler.updateOpportunityStage(Trigger.oldMap,Trigger.new); 
             AccountTriggerHandler.updateContactMailing(Trigger.oldMap,Trigger.new);
                 }

    } else if(Trigger.isBefore){
            // if(Trigger.isInsert || Trigger.isUpdate){
            //     AccountTriggerHandler.preventAccountName(Trigger.new);
            // }
    }
    
}