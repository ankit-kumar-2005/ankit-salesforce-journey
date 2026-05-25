/*

Apex Class Name    : FillTimesheetController
Created Date       : 17-09-2025
@description       : Controller class used to handle Timesheet creation and submission.
@author            : Ankit Kumar
Modification Log:
Ver   Date         Author                               Modification
1.0   17-09-2025   Ankit Kumar                          Initial Version

*/
public with sharing class FillTimesheetController {

    public List<Timesheet__c> timesheetList { get; set; }   
    public Id employeeId { get; set; }                      
    public Integer rowToRemove { get; set; }                


    public FillTimesheetController(ApexPages.StandardController std) {
        init();
    }


    private void init() {
        
        if (timesheetList == null) {
            timesheetList = new List<Timesheet__c>();
        }
        if (timesheetList.isEmpty()) {
            timesheetList.add(new Timesheet__c());
        }

        // Fetch current user details
        User currentUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        // Find employee record linked with user’s email
        List<Employee__c> empList = [
            SELECT Id
            FROM Employee__c
            WHERE Email_Address__c = :currentUser.Email
            LIMIT 1
        ];
        if (!empList.isEmpty()) employeeId = empList[0].Id;
    }

    // Add a new blank row for timesheet entry
    public void addRow() {
        if (timesheetList == null) timesheetList = new List<Timesheet__c>();
        timesheetList.add(new Timesheet__c());
    }

    // Remove a row from the list based on index
    public void removeRow() {
        timesheetList.remove(timesheetList.size() - 1);
        if (rowToRemove != null && rowToRemove >= 0 || rowToRemove <= timesheetList.size()) {
            
        }
    }

    // Utility method to check if a row is completely empty
    private Boolean isEmptyRow(Timesheet__c t) {
        return t == null ||
            (t.Project__c == null &&
             t.Spent_Hours__c == null &&
             t.Date__c == null &&
             (t.Description__c == null || String.isBlank(t.Description__c)));
    }

    // Save timesheet records linked with the employee
    public PageReference save() {
        if (employeeId == null) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                ' No Employee record found for your User Email.'
            ));
            return null;
        }

        List<Timesheet__c> toInsert = new List<Timesheet__c>();
        for (Timesheet__c t : timesheetList) {
            if (isEmptyRow(t)) continue;   
            t.Id = null;                   
            t.Employee__c = employeeId;
            toInsert.add(t);
        }

        if (toInsert.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.INFO,
                'ℹ Please add at least one valid timesheet row before submitting.'
            ));
            return null;
        }

        // Insert timesheet records with error handling
        Database.SaveResult[] results = Database.insert(toInsert, false);

        Boolean anyError = false;
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                anyError = true;
                for (Database.Error err : results[i].getErrors()) {
                    if (err.getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            'Validation Error: ' + err.getMessage()
                        ));
                    } else if (err.getStatusCode() == StatusCode.REQUIRED_FIELD_MISSING) {
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            ' A required field is missing in row ' + (i + 1)
                        ));
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            ' Error in row ' + (i + 1) + ': ' + err.getMessage()
                        ));
                    }
                }
            }
        }

        if (anyError) {
            return null; // Stay on page and show error messages
        }

        // On success, show confirmation and redirect to newly created record
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            ' Timesheets submitted successfully.'
        ));

        if (!toInsert.isEmpty()) {
            PageReference pr = new PageReference('/' + toInsert[0].Id);
            pr.setRedirect(true);
            return pr;
        }

        return null;
    }

    // Cancel action → Redirect back to list view
    public PageReference cancel() {
        PageReference pr = new PageReference('/lightning/o/Timesheet__c/list');
        pr.setRedirect(true);
        return pr;
    }
}