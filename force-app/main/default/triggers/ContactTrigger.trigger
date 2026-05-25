/*
 * Name:ContactTrigeer
 * Author Name:Ankit Kumar
 * Discription:Solve the question of Trigger Assigment i.e Q6,Q9,Q15
 * Date:31/08/25
 */
trigger ContactTrigger on Contact (before insert, before update, after insert) {
    try {
        if(Trigger.isBefore){
            // Q6: Auto-fill Email if blank
            ContactHandler.q6FillEmailFromAccount(Trigger.new);
            
            // Q9: Prevent duplicate Email + Phone
            ContactHandler.q9PreventDuplicateEmailPhone(Trigger.new);
        }

        if(Trigger.isAfter && Trigger.isInsert){
            // Q15: Auto-create Opportunity if none exist for Account
            ContactHandler.q15CreateOpportunityForAccount(Trigger.new);
        }
        //trigger day 2
         if (Trigger.isAfter) {
        ContactHandler.processContacts(
            Trigger.new,
            Trigger.old,
            Trigger.isInsert,
            Trigger.isUpdate,
            Trigger.isDelete,
            Trigger.isUndelete
        );
    }
    } catch(Exception ex){
        System.debug('Error in ContactTrigger: ' + ex.getMessage());
    }
}