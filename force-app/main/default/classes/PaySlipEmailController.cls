public with sharing class PaySlipEmailController {
    public Employee__c emp { get; private set; }
    public Employee_Salary__c empSalary { get; private set; }
    public Company__mdt companyDetails { get; private set; }
   
    public PaySlipEmailController(ApexPages.StandardController stdCtrl) {
        Id empSalaryId = stdCtrl.getId();
        if (empSalaryId == null) return;
       
        try {
            // Fetch Employee Salary record with all required fields
            empSalary = [
                SELECT Id, Employee__c, Basic__c, HRA__c, Special_Allowance__c, LTA_Allowance__c,
                       Statutory_Bonus__c, Travel_Allowance__c, Medical_Allowance__c, Total_Reimbursements__c,
                       Internet_Allowance__c,Gross_Earning__c, Other_Earning_1__c, Other_Earning_2__c, Other_Earning_3__c,
                      Other_Deduction__c, Other_Deduction_2__c, Other_Deduction_3__c, Total_Deduction__c,
                       Employee_EPF__c, Professional_Tax__c, LOP_Days__c, 	Total_Net_Payablee__c
                FROM Employee_Salary__c
                WHERE Id = :empSalaryId
                LIMIT 1
            ];
           
            // Fetch Employee record
            emp = [
                SELECT Id, Name, Email_Address__c, Pan_Card_Number__c, Bank_Name__c,
                       Bank_Account_Number__c, UAN_Number__c, IFSC_Code__c, PF_Number__c,
                       Department__c, Designation__c, Joining_Date__c, Employee_Code__c, Current_Location__c
                FROM Employee__c
                WHERE Id = :empSalary.Employee__c
                LIMIT 1
            ];
           
            // Fetch Company Details from Custom Metadata
            companyDetails = Company__mdt.getInstance('TMC');
           
        } catch (Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Error loading payslip data: ' + e.getMessage())
            );
        }
    }
   
    public void sendPayslip() {
        try {
            // Validate email address
            if (String.isBlank(emp.Email_Address__c)) {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, 'Employee email address is required to send payslip.')
                );
                return;
            }
           
            // Generate PDF using the download VF page
            PageReference pdfPage = Page.PaySlipSenderPage;
            pdfPage.getParameters().put('id', empSalary.Id);
           
            Blob pdfBlob;
            if (Test.isRunningTest()) {
                // Use mock data for test class
                pdfBlob = Blob.valueOf('Test PDF Content');
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }
           
            // Create PDF attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setContentType('application/pdf');
            attachment.setFileName('Payslip_' + emp.Name.replaceAll(' ', '_') + '_' +
                                 String.valueOf(Date.today().month()) + '_' +
                                 String.valueOf(Date.today().year()) + '.pdf');
            attachment.setBody(pdfBlob);
           
            // Prepare email body
            String subject = 'Payslip for ' + Date.today();
            String htmlBody = buildEmailBody();
           
            // Create and send email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { emp.Email_Address__c });
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            mail.setSaveAsActivity(false);
           
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           
        } catch (Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Error sending payslip: ' + e.getMessage())
            );
        }
    }
   
    private String buildEmailBody() {
        String currentMonth = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('MMMM');
        String currentYear = String.valueOf(Date.today().year());
       
        return '<html><body>' +
               '<h2>' + currentMonth + ' ' + currentYear + ' Payslip</h2>' +
               '<p>Hi ' + emp.Name + ',</p>' +
               '<p>Attached with the email is your payslip for the month mentioned in the subject line.</p>' +
               '<p>Thanks,</p>' +
               '<p>Accounts Team</p>' +
               '</body></html>';
    }
   
    public PageReference backToRecord() {
        PageReference pageRef = new PageReference('/' + empSalary.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}