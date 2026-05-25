/**
 * @Name        ShowEmployeeInformationController
 * @Author      Ankit Kumar
 * @Date        17/09/2025
 * @Description Controller class responsible for fetching and displaying the
 *              current logged-in employee information including personal details,
 *              manager and practice head info, user photo, and formatted values
 *              like experience, dates, and masked account numbers.
 */
public with sharing class ShowEmployeeInformationController {
   
    public Employee__c currentEmployee { get; set; }
    public User currentUser { get; set; }
    public Boolean hasEmployeeRecord { get; set; }
    public Boolean showError { get; set; }
    public String errorMessage { get; set; }

    public String managerName { get; set; }
    public String practiceHeadName { get; set; }
   
    public String userPhotoUrl { get; set; }

    /**
     * @Description Constructor - Initializes the controller and loads
     *              employee information for the current user.
     */
    public ShowEmployeeInformationController() {
        loadEmployeeInformation();
    }

    /**
     * @Description Loads complete employee-related information by
     *              sequentially calling helper methods.
     */
    private void loadEmployeeInformation(){
        try {
            getCurrentUserInfo();
            getEmployeeRecord();
            getManagerAndPracticeHeadInfo();
            getUserPhoto();
        } catch (Exception e) {
            showError = true;
            errorMessage = 'Error loading employee information: ' + e.getMessage();
            System.debug('EmployeeInformationController Error: ' + e.getStackTraceString());
        }
    }

    /**
     * @Description Retrieves current logged-in user information.
     */
    private void getCurrentUserInfo() {
        try {
            currentUser = [
                SELECT Id, Name, Email, Phone, SmallPhotoUrl, FullPhotoUrl
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
        } catch (QueryException e) {
            // No action needed
        }
    }

    /**
     * @Description Fetches employee record linked with the current user.
     */
    private void getEmployeeRecord() {
        try {
            List<Employee__c> employees = [
                SELECT Id, Name, Email_Address__c, Primary_Contact_No__c,
                       Aadhar_Number__c, Pan_Card_Number__c, Emergency_Contact_Number__c,
                       Father_Name__c, Mother_Name__c, Address__c, Current_Location__c,
                       Blood_Group__c, Official_Email_Address__c, Joining_Date__c,
                       Confirmation_Date__c,Total_Experience_in_year__c,Techmatrix_Experience_In_years__c,
                       Department__c, Designation__c, Supervisor__c, Bank_Name__c,
                       Bank_Account_Number__c, IFSC_Code__c, UAN_Number__c,
                       Employee_Manager__c, Practice_Head__c, Related_User__c
                FROM Employee__c
                WHERE Related_User__c = :UserInfo.getUserId()
                LIMIT 1
            ];
           
            if (!employees.isEmpty()) {
                currentEmployee = employees[0];
                hasEmployeeRecord = true;
            } else {
                hasEmployeeRecord = false;
                showError = true;
                errorMessage = 'No employee record found for the current user. Please contact your administrator.';
            }
           
        } catch (QueryException e) {
            hasEmployeeRecord = false;
            showError = true;
            errorMessage = 'Error retrieving employee information: ' + e.getMessage();
        }
    }

    /**
     * @Description Retrieves Manager and Practice Head information for the employee.
     */
    private void getManagerAndPracticeHeadInfo() {
        if (!hasEmployeeRecord || currentEmployee == null) {
            return;
        }
       
        try {
            if (currentEmployee.Employee_Manager__c != null) {
                List<Employee__c> managers = [
                    SELECT Name
                    FROM Employee__c
                    WHERE Id = :currentEmployee.Employee_Manager__c
                    LIMIT 1
                ];
                managerName = !managers.isEmpty() ? managers[0].Name : 'NA';
            } else {
                managerName = 'Aman Sir';
            }
           
            if (currentEmployee.Practice_Head__c != null) {
                List<Practice_Head__c> practiceHeads = [
                    SELECT Name
                    FROM Practice_Head__c
                    WHERE Id = :currentEmployee.Practice_Head__c
                    LIMIT 1
                ];
                practiceHeadName = !practiceHeads.isEmpty() ? practiceHeads[0].Name : 'Arpit Sir';
            } else {
                practiceHeadName = 'Arpit Sir';
            }
           
        } catch (Exception e) {
            managerName = 'Error loading';
            practiceHeadName = 'Error loading';
            System.debug('Error loading manager/practice head info: ' + e.getMessage());
        }
    }

    /**
     * @Description Retrieves user photo URL, defaults to system placeholder if not available.
     */
    private void getUserPhoto() {
        try {
            if (currentUser != null) {
                if (String.isNotBlank(currentUser.FullPhotoUrl)) {
                    userPhotoUrl = currentUser.FullPhotoUrl;
                } else if (String.isNotBlank(currentUser.SmallPhotoUrl)) {
                    userPhotoUrl = currentUser.SmallPhotoUrl;
                } else {
                    userPhotoUrl = '/img/userprofile/default_profile_45_v2.png';
                }
            }
        } catch (Exception e) {
            userPhotoUrl = '/img/userprofile/default_profile_45_v2.png';
        }
    }

    /**
     * @Description Returns formatted total experience in years.
     */
    public String getTotalExperienceFormatted() {
        if (hasEmployeeRecord && currentEmployee != null && currentEmployee.Total_Experience_in_year__c != null) {
            return String.valueOf(currentEmployee.Total_Experience_in_year__c.intValue()) + ' Years';
        }
        return 'Not Specified';
    }
   
    /**
     * @Description Returns formatted Techmatrix experience, either from field or calculated from joining date.
     */
    public String getTechmatrixExperienceFormatted() {
        if (hasEmployeeRecord && currentEmployee != null && currentEmployee.Techmatrix_Experience_In_years__c != null) {
            return String.valueOf(currentEmployee.Techmatrix_Experience_In_years__c.intValue()) + ' Years';
        } else if (hasEmployeeRecord && currentEmployee != null && currentEmployee.Joining_Date__c != null) {
            Date joiningDate = currentEmployee.Joining_Date__c;
            Date today = Date.today();
            Integer daysDiff = joiningDate.daysBetween(today);
            Decimal years = daysDiff / 365.0;
            return String.valueOf(years.setScale(1)) + ' Years';
        }
        return 'Not Calculated';
    }
   
    /**
     * @Description Returns formatted Joining Date.
     */
    public String getFormattedJoiningDate() {
        if (hasEmployeeRecord && currentEmployee != null && currentEmployee.Joining_Date__c != null) {
            return currentEmployee.Joining_Date__c.format();
        }
        return 'Not Available';
    }
   
    /**
     * @Description Returns formatted Confirmation Date.
     */
    public String getFormattedConfirmationDate() {
        if (hasEmployeeRecord && currentEmployee != null && currentEmployee.Confirmation_Date__c != null) {
            return currentEmployee.Confirmation_Date__c.format();
        }
        return 'Not Available';
    }
   
    /**
     * @Description Returns masked bank account number (last 4 digits visible).
     */
    public String getMaskedAccountNumber() {
        if (hasEmployeeRecord && currentEmployee != null && String.isNotBlank(currentEmployee.Bank_Account_Number__c)) {
            String accountNum = currentEmployee.Bank_Account_Number__c;
            if (accountNum.length() > 4) {
                return '**** **** ' + accountNum.substring(accountNum.length() - 4);
            }
            return accountNum;
        }
        return 'Not Available';
    }
}