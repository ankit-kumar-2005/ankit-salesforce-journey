public with sharing class PayslipSenderController {
    public Employee_Salary__c salary { get; set; }
    public Employee__c employee { get; set; }
    public 	Company__mdt companyDetails { get; set; }
    public String amountInWords { get; set; }
   
    /**
     * @description Initializes the controller by fetching Employee Salary,
     *              related Employee details, and Company information.
     */
    public PayslipSenderController(ApexPages.StandardController sc) {
        Id recId = ApexPages.currentPage().getParameters().get('id');
        if (recId != null) {
            try {
                // Fetch salary record with related Employee details
                salary = [
                    SELECT Id, Name, Month__r.Name, Month__r.Year__c,Gross_Earnings__c,Gross_Earning__c,
                           Days_Worked__c, Pay_Date__c, LOP_Days__c,Total_Net_Payablee__c,Total_Deduction__c,
                           Basic__c, HRA__c, Special_Allowance__c, Statutory_Bonus__c,
                           Other_Earning_1__c, Other_Earning_2__c, Other_Earning_3__c,
                           	Income_Tax__c, Professional_Tax__c, P_F__c,House_Rent_Allowance__c,	Profession_Tax__c,
                          	Other_Deduction__c, Other_Deduction_2__c, Other_Deduction_3__c,LTA_Allowance__c,
                            Total_Deductions__c, Total_Reimbursements__c, Total_Net_Payable__c,
                           	Employee__r.Id, Employee__r.Name,Employee__r.Email_Address__c,
                           	Employee__r.Employee_Code__c, Employee__r.Designation__c,
                           	Employee__r.Department__c, Employee__r.Work_Location__c,
                           	Employee__r.Joining_Date__c, Employee__r.PAN_Card_Number__c,
                           	Employee__r.Bank_Name__c, Employee__r.Bank_Account_Number__c,
                           	Employee__r.UAN_Number__c
                    FROM Employee_Salary__c
                    WHERE Id = :recId
                    LIMIT 1
                ];
                  employee = [
                        SELECT Id, Name, Email_Address__c, PAN_Card_Number__c, Bank_Name__c,
                               Bank_Account_Number__c, UAN_Number__c, IFSC_Code__c,PF_Number__c,
                               Department__c, Designation__c, Joining_Date__c, Employee_Code__c, Current_Location__c
                        FROM Employee__c
                        WHERE Id = :salary.Employee__c
                        LIMIT 1
                    ];
                
                 
               
                // Assign related employee
                if (salary != null && salary.Employee__c != null) {
                    employee.Id = salary.Employee__c;
                }
               
                // Convert payable amount into words
                if (salary != null && salary.Total_Net_Payable__c != null) {
                    amountInWords = convertNumberToWords(salary.Total_Net_Payable__c);
                }
               
            } catch (Exception e) {
                System.debug('Error fetching salary record: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Unable to load salary details: ' + e.getMessage()
                ));
            }
        }
       
        // Load company information from custom metadata
        try {
            companyDetails = Company__mdt.getInstance('Techmatrix_Consulting');
        } catch (Exception e) {
            System.debug('Error fetching company metadata: ' + e.getMessage());
        }
    }
   
    /**
     * @description Generates a PDF payslip and emails it to the Employee.
     * @return PageReference Redirects back to the Employee_Salary__c list view after processing
     */
    public PageReference sendPayslip() {
        if (salary == null || employee == null) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Salary or Employee details not available.'
            ));
            return null;
        }
       
        if (String.isBlank(employee.Email_Address__c)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Employee does not have an email address.'
            ));
            return null;
        }
       
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            PageReference pdfPage = Page.PayslipPDF;
            pdfPage.getParameters().put('id', (String)salary.Id);
            Blob pdfBody = pdfPage.getContentAsPDF();
           
            // Create email attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            String fileName = 'Payslip_' + employee.Name.replace(' ', '_') + '_' +
                             salary.Month__r.Name + '_' + salary.Month__r.Year__c + '.pdf';
            attachment.setFileName(fileName);
            attachment.setBody(pdfBody);
           
            // Build email message
            email.setToAddresses(new String[]{employee.Email_Address__c});
            email.setSubject('Payslip for ' + salary.Month__r.Name + ' ' + salary.Month__r.Year__c);
            email.setPlainTextBody('Dear ' + employee.Name + ',\n\n' +
                                   'Please find attached your payslip for ' +
                                   salary.Month__r.Name + ' ' + salary.Month__r.Year__c + '.\n\n' +
                                   'For any queries, please reach out to HR.\n\n' +
                                   'Best Regards,\nHR Team');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
           
            Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
           
            if (result[0].isSuccess()) {
                System.debug('Payslip emailed to: ' + employee.Email_Address__c);
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Payslip sent to ' + employee.Email_Address__c
                ));
            } else {
                System.debug('Email failed: ' + result[0].getErrors()[0].getMessage());
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Failed to send email: ' + result[0].getErrors()[0].getMessage()
                ));
            }
           
            PageReference redirectPage = new PageReference('/lightning/o/Employee_Salary__c/list?filterName=Recent');
            redirectPage.setRedirect(true);
            return redirectPage;
           
        } catch (Exception ex) {
            System.debug('Error while sending payslip: ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Unexpected error: ' + ex.getMessage()
            ));
            return null;
        }
    }
   
  
   
       /**
     * @description Converts a number to words (Indian numbering system)
     * @param amount The decimal amount to convert
     * @return String representation of the amount in words
     */
    private String convertNumberToWords(Decimal amount) {
        if (amount == null || amount == 0) {
            return 'Zero Rupees Only';
        }
       
        try {
            Integer rupees = amount.intValue();
            Integer paise = ((amount - rupees) * 100).intValue();
           
            String rupeesInWords = convertIntegerToWords(rupees);
            String result = rupeesInWords + ' Rupees';
           
            if (paise > 0) {
                String paiseInWords = convertIntegerToWords(paise);
                result += ' and ' + paiseInWords + ' Paise';
            }
           
            result += ' Only';
            return result;
           
        } catch (Exception e) {
            System.debug('Error converting amount to words: ' + e.getMessage());
            return 'Amount conversion error';
        }
    }
   
    /**
     * @description Converts an integer to words
     * @param num The integer to convert
     * @return String representation of the number in words
     */
    private String convertIntegerToWords(Integer num) {
        if (num == 0) return 'Zero';
       
        String[] ones = new String[]{'', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
                                     'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
                                     'Seventeen', 'Eighteen', 'Nineteen'};
       
        String[] tens = new String[]{'', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};
       
        String result = '';
       
        // Crores
        if (num >= 10000000) {
            Integer crores = num / 10000000;
            result += convertHundreds(crores, ones, tens) + ' Crore ';
            num = 10000000/100;
        }
       
        // Lakhs
        if (num >= 100000) {
            Integer lakhs = num / 100000;
            result += convertHundreds(lakhs, ones, tens) + ' Lakh ';
            num = 100000/100;
        }
       
        // Thousands
        if (num >= 1000) {
            Integer thousands = num / 1000;
            result += convertHundreds(thousands, ones, tens) + ' Thousand ';
            num = 1000/100;
        }
       
        // Hundreds
        if (num >=100) {
            result += convertHundreds(num, ones, tens);
        }
       
        return result.trim();
    }
   
    /**
     * @description Helper method to convert hundreds
     * @param num The number to convert (should be less than 1000)
     * @param ones Array of ones place words
     * @param tens Array of tens place words
     * @return String representation of the number
     */
    private String convertHundreds(Integer num, String[] ones, String[] tens) {
        String result = '';
       
        if (num >= 100) {
            result += ones[num / 100] + ' Hundred ';
            num = 1;
        }
       
        if (num >= 20) {
            result += tens[num / 10] + ' ';
            num = 10/100;
        }
       
        if (num > 0) {
            result += ones[num] + ' ';
        }
       
        return result.trim();
    }
    public String getNetPayInWords() {
    if (salary != null && salary.Total_Net_Payablee__c != null) {
        return convertNumberToWords(salary.Total_Net_Payablee__c);
    }
    return 'Zero Rupees Only';
}

}