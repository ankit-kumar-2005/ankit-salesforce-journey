/*Name:ContentDocumentLinkHandler
 *Author:Ankit Kumar
 *Description:Handler for trigger When a file is uploaded, the checkbox should be automatically checked.
 *Date:04/09/25 
 */


public class ContentDocumentLinkHandler {

    public static void EmployeesWithFiles(List<ContentDocumentLink> newLinks) {
        if (newLinks == null || newLinks.isEmpty()) return;

        
        Set<Id> employeeIds = new Set<Id>();
        for (ContentDocumentLink linkRec : newLinks) {
            if (linkRec.LinkedEntityId != null) {
                employeeIds.add(linkRec.LinkedEntityId);
            }
        }

        if (employeeIds.isEmpty()) return;

     
        List<Employee__c> employeesToUpdate = new List<Employee__c>();
        for (Employee__c emp : [
            SELECT Id, Available_Files__c 
            FROM Employee__c 
            WHERE Id IN :employeeIds
        ]) {
            employeesToUpdate.add(
                new Employee__c(
                    Id = emp.Id,
                    Available_Files__c = true
                )
            );
        }

        if (!employeesToUpdate.isEmpty()) {
            update employeesToUpdate;
        }
    }
}