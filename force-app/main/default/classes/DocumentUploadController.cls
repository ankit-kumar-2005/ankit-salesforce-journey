public with sharing class DocumentUploadController {

    // Save uploaded file info to Account__c (custom object)
    @AuraEnabled
    public static void saveUploadedDocument(Id accountId, String documentType, Id contentDocumentId) {
        try {
            // Check if record already exists for same Account & Document Type
            List<Account__c> existingDocs = [
                SELECT Id FROM Account__c
                WHERE Account__c = :accountId AND Document_Type__c = :documentType
                LIMIT 1
            ];

            if (existingDocs.isEmpty()) {
                Account__c newDoc = new Account__c();
                newDoc.Account__c = accountId;
                newDoc.Document_Type__c = documentType;
                newDoc.Is_Uploaded__c = true;
                newDoc.ContentDocumentId__c = contentDocumentId;
                insert newDoc;
            } else {
                Account__c doc = existingDocs[0];
                doc.Is_Uploaded__c = true;
                doc.ContentDocumentId__c = contentDocumentId;
                update doc;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error saving uploaded document: ' + e.getMessage());
        }
    }

    // Get uploaded document info for displaying tick marks
    @AuraEnabled(cacheable=true)
    public static List<Account__c> getUploadedDocuments(Id accountId) {
        return [
            SELECT Id, Document_Type__c, Is_Uploaded__c, ContentDocumentId__c
            FROM Account__c
            WHERE Account__c = :accountId
        ];
    }
}