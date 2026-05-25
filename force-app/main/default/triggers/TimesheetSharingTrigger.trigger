trigger TimesheetSharingTrigger on Timesheet__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        TimesheetSharingHandler.shareWithSupervisorAndManager(Trigger.new);
    }
}