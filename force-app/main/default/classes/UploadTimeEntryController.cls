/*
*********************************************************
@Class Name      : UploadTimeEntryController
@Author          : Ankit Kumar
@Created Date    : 15-09-2025
@Description     : Controller for uploading and processing Time Entry CSV file
*********************************************************
*/
public class UploadTimeEntryController {

    // CSV upload 
    public Blob csvFileBody { get; set; }
    public String csvAsString { get; set; }
    public String[] csvFileLines { get; set; }
    public List<Time_Entry__c> timeEntryList { get; set; }

    // Cache Employee records by Employee Code
    private Map<String, Employee__c> employeeMap;

    /*
    * Constructor for VF page extension
    */
    public UploadTimeEntryController(ApexPages.StandardController stdCtrl) {
        csvFileLines = new String[]{};
        timeEntryList = new List<Time_Entry__c>();
    }

    /*
    * Import CSV, parse records, check duplicates, and insert Time Entry records
    */
    public void importCSVFile() {
        try {
            if (csvFileBody == null) {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR, 'Please select a CSV file to upload.'
                ));
                return;
            }

            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n');

            // Track keys to avoid duplicates
            Set<String> existingKeys = new Set<String>();
            Set<String> csvKeys = new Set<String>();

            // Fetch existing keys from DB (Employee + Date)
            for (Time_Entry__c te : [
                SELECT Employee_Code__c, Date__c
                FROM Time_Entry__c
                WHERE Employee_Code__c != null AND Date__c != null
            ]) {
                existingKeys.add(te.Employee_Code__c + '_' + String.valueOf(te.Date__c));
            }

            // Skip header (start i=1)
            for (Integer i = 1; i < csvFileLines.size(); i++) {
                String line = csvFileLines[i].trim();
                if (String.isBlank(line)) continue;

                String[] csvRecordData = line.split(',');

                if (csvRecordData.size() < 5) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.WARNING,
                        'Row skipped (missing columns): ' + line
                    ));
                    continue;
                }

                String empCode = csvRecordData[0];
                Employee__c emp = getEmployeeByCode(empCode);

                if (emp == null) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.WARNING,
                        'No Employee found for code: ' + empCode + '. Row skipped.'
                    ));
                    continue;
                }

                // Parse Date
                Date workDate;
                try {
                    workDate = parseDate(csvRecordData[2]);
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.WARNING,
                        'Invalid date format for employee ' + empCode + ': ' + csvRecordData[2]
                    ));
                    continue;
                }

                // Uniqueness key
                String uniqueKey = empCode + '_' + String.valueOf(workDate);

                if (existingKeys.contains(uniqueKey)) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.WARNING,
                        'Duplicate found in Salesforce for Employee ' + empCode + ' on ' + workDate + '. Skipped.'
                    ));
                    continue;
                }

                if (csvKeys.contains(uniqueKey)) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.WARNING,
                        'Duplicate found in CSV for Employee ' + empCode + ' on ' + workDate + '. Skipped.'
                    ));
                    continue;
                }
                csvKeys.add(uniqueKey);

                // Build record
                Time_Entry__c timeEntryObj = new Time_Entry__c();
                timeEntryObj.Employee_Code__c = empCode;
                timeEntryObj.Employee_Name_E__c = emp.Id; 

                if (emp.Related_User__c != null) {
                    timeEntryObj.OwnerId = emp.Related_User__c;
                }

                timeEntryObj.Date__c = workDate;

                // In Time
                String inTimeString = csvRecordData[3];
                if (!String.isBlank(inTimeString)) {
                    List<String> inTimes = inTimeString.split(';');
                    if (!inTimes.isEmpty()) {
                        timeEntryObj.In_Time__c = parseTime(inTimes[0]);
                    }
                }

                // Out Time
                timeEntryObj.Out_Time__c = parseTime(csvRecordData[4]);

                timeEntryList.add(timeEntryObj);
            }

            if (!timeEntryList.isEmpty()) {
                insert timeEntryList;
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    timeEntryList.size() + ' records imported successfully.'
                ));
            }

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Error while importing data: ' + e.getMessage()
            ));
        }
    }

    /*
    * Fetch Employee by code with caching
    */
    private Employee__c getEmployeeByCode(String code) {
        if (employeeMap == null) {
            employeeMap = new Map<String, Employee__c>();
            for (Employee__c emp : [
                SELECT Id, Employee_Code__c, Related_User__c
                FROM Employee__c
                WHERE Employee_Code__c != null
            ]) {
                employeeMap.put(emp.Employee_Code__c, emp);
            }
        }
        return employeeMap.get(code);
    }

    /*
    * Parse a string into Date (supports both dd/MM/yyyy and MM/dd/yyyy)
    */
    public Date parseDate(String dateString) {
        if (String.isBlank(dateString)) return null;

        List<String> parts = dateString.split('/');
        if (parts.size() != 3) {
            throw new AuraException('Invalid date format: ' + dateString);
        }

        Integer part1 = Integer.valueOf(parts[0]);
        Integer part2 = Integer.valueOf(parts[1]);
        Integer year  = Integer.valueOf(parts[2]);

        // If part1 > 12 → assume dd/MM/yyyy
        Integer day   = (part1 > 12) ? part1 : part2;
        Integer month = (part1 > 12) ? part2 : part1;

        return Date.newInstance(year, month, day);
    }

    /*
    * Parse a string into Time (HH:mm[:ss])
    */
    public Time parseTime(String timeString) {
        if (String.isBlank(timeString)) return null;

        List<String> parts = timeString.split(':');
        Integer hour   = Integer.valueOf(parts[0]);
        Integer minute = (parts.size() > 1) ? Integer.valueOf(parts[1]) : 0;
        Integer second = (parts.size() > 2) ? Integer.valueOf(parts[2]) : 0;

        return Time.newInstance(hour, minute, second, 0);
    }
}