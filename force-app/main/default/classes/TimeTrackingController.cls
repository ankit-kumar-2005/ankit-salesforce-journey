public with sharing class TimeTrackingController {
    
    @AuraEnabled
    public static TimeTrackingResponse initializeTimeTracking() {
        try {
            TimeTrackingResponse response = new TimeTrackingResponse();
            
            // Get current user's employee record
            Employee__c currentEmployee = getCurrentEmployee();
            if (currentEmployee == null) {
                response.success = false;
                response.message = 'No employee record found for current user';
                return response;
            }
            
            // Check if there's already a time entry for today
            Date today = Date.today();
            List<Time_Entry__c> todayEntries = [
                SELECT Id, In_Time__c, Out_Time__c,Employee_Name_E__c
                FROM Time_Entry__c 
                WHERE Employee_Name_E__c= :currentEmployee.Id 
                AND Date__c = :today
                LIMIT 1
            ];
            
            response.success = true;
            response.employeeId = currentEmployee.Id;
            response.employeeCode = currentEmployee.Employee_Code__c;
            
            if (todayEntries.isEmpty()) {
                // No entry for today - enable In-Time button
                response.hasInTime = false;
                response.hasOutTime = false;
                response.inTimeDisabled = false;
                response.outTimeDisabled = true;
            } else {
                Time_Entry__c todayEntry = todayEntries[0];
                response.timeEntryId = todayEntry.Id;
                
                if (todayEntry.In_Time__c != null && todayEntry.Out_Time__c == null) {
                    // Has in-time but no out-time - enable Out-Time button
                    response.hasInTime = true;
                    response.hasOutTime = false;
                    response.inTimeDisabled = true;
                    response.outTimeDisabled = false;
                    response.inTimeValue = todayEntry.In_Time__c;
                } else if (todayEntry.In_Time__c != null && todayEntry.Out_Time__c != null) {
                    // Both times recorded - disable both buttons
                    response.hasInTime = true;
                    response.hasOutTime = true;
                    response.inTimeDisabled = true;
                    response.outTimeDisabled = true;
                    response.inTimeValue = todayEntry.In_Time__c;
                    response.outTimeValue = todayEntry.Out_Time__c;
                }
            }
            
            return response;
        } catch (Exception e) {
            TimeTrackingResponse response = new TimeTrackingResponse();
            response.success = false;
            response.message = 'Error initializing: ' + e.getMessage();
            return response;
        }
    }
    
    @AuraEnabled
    public static TimeTrackingResponse recordInTime() {
        try {
            TimeTrackingResponse response = new TimeTrackingResponse();
            
            // Get current user's employee record
            Employee__c currentEmployee = getCurrentEmployee();
            if (currentEmployee == null) {
                response.success = false;
                response.message = 'No employee record found for current user';
                return response;
            }
            
            // Check if already has entry for today
            Date today = Date.today();
            List<Time_Entry__c> existingEntries = [
                SELECT Id FROM Time_Entry__c 
                WHERE Employee_Name_E__c = :currentEmployee.Id 
                AND Date__c = :today
                LIMIT 1
            ];
            
            if (!existingEntries.isEmpty()) {
                response.success = false;
                response.message = 'Time entry already exists for today';
                return response;
            }
            
            // Create new time entry
            DateTime currentDateTime = System.now();
            Time_Entry__c newEntry = new Time_Entry__c();
            newEntry.Employee_Name_E__c = currentEmployee.Id;
            newEntry.Date__c = today;
            newEntry.In_Time__c = Time.newInstance(currentDateTime.hour(), currentDateTime.minute(), currentDateTime.second(), 0);
            newEntry.Employee_Code__c = currentEmployee.Employee_Code__c;
            
            insert newEntry;
            
            response.success = true;
            response.message = 'In-time recorded successfully';
            response.timeEntryId = newEntry.Id;
            response.inTimeValue = newEntry.In_Time__c;
            response.hasInTime = true;
            response.inTimeDisabled = true;
            response.outTimeDisabled = false;
            
            return response;
        } catch (Exception e) {
            TimeTrackingResponse response = new TimeTrackingResponse();
            response.success = false;
            response.message = 'Error recording in-time: ' + e.getMessage();
            return response;
        }
    }
    
    @AuraEnabled
    public static TimeTrackingResponse recordOutTime() {
        try {
            TimeTrackingResponse response = new TimeTrackingResponse();
            
            // Get current user's employee record
            Employee__c currentEmployee = getCurrentEmployee();
            if (currentEmployee == null) {
                response.success = false;
                response.message = 'No employee record found for current user';
                return response;
            }
            
            // Find today's time entry
            Date today = Date.today();
            List<Time_Entry__c> todayEntries = [
                SELECT Id, In_Time__c, Out_Time__c 
                FROM Time_Entry__c 
                WHERE Employee_Name_E__c = :currentEmployee.Id 
                AND Date__c = :today
                AND In_Time__c != null
                AND Out_Time__c = null
                LIMIT 1
            ];
            
            if (todayEntries.isEmpty()) {
                response.success = false;
                response.message = 'No valid in-time entry found for today';
                return response;
            }
            
            // Update with out-time
            DateTime currentDateTime = System.now();
            Time_Entry__c entry = todayEntries[0];
            entry.Out_Time__c = Time.newInstance(currentDateTime.hour(), currentDateTime.minute(), currentDateTime.second(), 0);
            update entry;
            
            response.success = true;
            response.message = 'Out-time recorded successfully';
            response.timeEntryId = entry.Id;
            response.inTimeValue = entry.In_Time__c;
            response.outTimeValue = entry.Out_Time__c;
            response.hasInTime = true;
            response.hasOutTime = true;
            response.inTimeDisabled = true;
            response.outTimeDisabled = true;
            
            return response;
        } catch (Exception e) {
            TimeTrackingResponse response = new TimeTrackingResponse();
            response.success = false;
            response.message = 'Error recording out-time: ' + e.getMessage();
            return response;
        }
    }
    
    private static Employee__c getCurrentEmployee() {
        Id currentUserId = UserInfo.getUserId();
        List<Employee__c> employees = [
            SELECT Id, Employee_Code__c 
            FROM  Employee__c	
            WHERE Related_User__c = :currentUserId
            LIMIT 1
        ];
        
        return employees.isEmpty() ? null : employees[0];
    }
    
    // Wrapper class for response
    public class TimeTrackingResponse {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Id timeEntryId { get; set; }
        @AuraEnabled public Id employeeId { get; set; }
        @AuraEnabled public String employeeCode { get; set; }
        @AuraEnabled public Time inTimeValue { get; set; }
        @AuraEnabled public Time outTimeValue { get; set; }
        @AuraEnabled public Boolean hasInTime { get; set; }
        @AuraEnabled public Boolean hasOutTime { get; set; }
        @AuraEnabled public Boolean inTimeDisabled { get; set; }
        @AuraEnabled public Boolean outTimeDisabled { get; set; }
        
        public TimeTrackingResponse() {
            this.success = false;
            this.hasInTime = false;
            this.hasOutTime = false;
            this.inTimeDisabled = false;
            this.outTimeDisabled = true;
        }
    }
}