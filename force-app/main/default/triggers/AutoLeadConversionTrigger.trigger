/*
 * Name: AutoLeadConversionTrigger
 * Author: Ankit Kumar
 * Description: Creates follow-up Task for new Leads and auto-converts Web leads
 * Date: 02/09/25
 */
trigger AutoLeadConversionTrigger on Lead (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        Set<Id> webLeadIds = new Set<Id>();
        
        // Create follow-up Task for every lead
        AutoLeadConversionHandler.createFollowUpTasks(Trigger.new);

        // Collect Web leads for conversion
        for (Lead ld : Trigger.new) {
            if (ld.LeadSource == 'Web') {
                webLeadIds.add(ld.Id);
            }
        }

        // Convert only if we have some Web leads
        if (!webLeadIds.isEmpty()) {
            AutoLeadConversionHandler.convertLeads(webLeadIds);
        }
    }
}