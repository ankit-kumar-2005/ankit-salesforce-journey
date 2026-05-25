public class TimesheetSharingHandler {

    public static void shareWithSupervisorAndManager(List<Timesheet__c> newTimesheets) {
        if (newTimesheets == null || newTimesheets.isEmpty()) return;


        Set<Id> employeeIds = new Set<Id>();
        for (Timesheet__c ts : newTimesheets) {
            if (ts.Employee__c != null) {
                employeeIds.add(ts.Employee__c);
            }
        }
        if (employeeIds.isEmpty()) return;

        
        Map<Id, Employee__c> employeeDetails = new Map<Id, Employee__c>(
            [SELECT Id, Supervisor__c, Employee_Manager__c,
                    Supervisor__r.Related_User__c,
                    Employee_Manager__r.Related_User__c
             FROM Employee__c
             WHERE Id IN :employeeIds]
        );


        List<Timesheet__Share> shareRecords = new List<Timesheet__Share>();

        for (Timesheet__c ts : newTimesheets) {
            Employee__c emp = employeeDetails.get(ts.Employee__c);
            if (emp == null) continue;

            Set<Id> relatedUsers = new Set<Id>();

            if (emp.Supervisor__r != null && emp.Supervisor__r.Related_User__c != null) {
                relatedUsers.add(emp.Supervisor__r.Related_User__c);
            }
            if (emp.Employee_Manager__r != null && emp.Employee_Manager__r.Related_User__c != null) {
                relatedUsers.add(emp.Employee_Manager__r.Related_User__c);
            }

            for (Id usrId : relatedUsers) {
                shareRecords.add(new Timesheet__Share(
                    ParentId      = ts.Id,
                    UserOrGroupId = usrId,
                    AccessLevel   = 'Read',
                    RowCause      = 'share with Supervisor'
                ));
            }
        }

        if (!shareRecords.isEmpty()) {
            Database.insert(shareRecords, false); 
        }
    }
}