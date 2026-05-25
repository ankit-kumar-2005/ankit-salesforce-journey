/*Name:ContentDocumentLinkTrigger
 *Author:Ankit Kumar
 *Description:When a file is uploaded, the checkbox should be automatically checked.
 *Date:04/09/25 
 */

trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        ContentDocumentLinkHandler.EmployeesWithFiles(Trigger.new);
    }
}