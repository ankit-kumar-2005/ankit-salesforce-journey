/**
     * Assigns initial leave balance to newly created employees
     * based on the joining date.
     */


public class EmployeeTriggerHandler {
    /**
     * Description  Assigns initial leave balance to newly created employees
     * return type is void
     */

    public static void assignInitialLeaveBalance(List<Employee__c> employees) {
        List<Leave_Balance__c> leaveRecords = new List<Leave_Balance__c>();

        for (Employee__c emp : employees) {
            if (emp.Joining_Date__c == null) continue;

            // Assign leave balance based on joining date
            Decimal initialBalance = emp.Joining_Date__c.day() <= 15 ? 1 : 0.5;

            Leave_Balance__c leaveBalance = new Leave_Balance__c(
                Employee__c = emp.Id,
                Leave_Balance__c = initialBalance
            );

            leaveRecords.add(leaveBalance);
        }

        if (!leaveRecords.isEmpty()) {
            insert leaveRecords;
        }
    }
}