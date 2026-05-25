/*
 * Name: AutoLeadConversionHandler
 * Author: Ankit Kumar
 * Description: Handles follow-up task creation and auto conversion of leads
 * Date: 02/09/25
 */
public class AutoLeadConversionHandler {

    // Create follow-up tasks for each lead
    public static void createFollowUpTasks(List<Lead> leads) {
        if (leads.isEmpty()) return;

        List<Task> taskList = new List<Task>();
        System.debug('Lead Record-->'+leads);

        for (Lead ld : leads) {
            Task followUpTask = new Task(
                WhoId       = ld.Id,
                OwnerId      = ld.OwnerId,
                Subject      = 'Follow up with new Lead',
                ActivityDate = System.today().addDays(2),
                Status       = 'Not Started',
                Priority     = 'Normal'
            );
            taskList.add(followUpTask);
        }

        System.debug('Task List\before--> '+taskList);

        if (!taskList.isEmpty()) {
            insert taskList;
        }
		System.debug('Task List After--->'+taskList);
    }

    // Convert leads into Account, Contact, and Opportunity
    public static void convertLeads(Set<Id> leadIds) {
        if (leadIds.isEmpty()) return;

        // Fetch converted status
        LeadStatus convertedStatus = [
            SELECT Id, MasterLabel
            FROM LeadStatus
            WHERE IsConverted = true
            LIMIT 1
        ];

        List<Database.LeadConvert> leadConversionList = new List<Database.LeadConvert>();

        for (Id leadId : leadIds) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setConvertedStatus(convertedStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(false); // Create Opportunity too
            leadConversionList.add(lc);
        }

        if (!leadConversionList.isEmpty()) {
            List<Database.LeadConvertResult> results = Database.convertLead(leadConversionList, false);

            // Debugging errors
            for (Database.LeadConvertResult res : results) {
                if (!res.isSuccess()) {
                    System.debug('Lead conversion failed: ' + res.getErrors());
                }
            }
        }
    }
}