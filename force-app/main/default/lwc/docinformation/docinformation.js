import { LightningElement, api, track } from 'lwc';
import saveUploadedDocument from '@salesforce/apex/DocumentUploadController.saveUploadedDocument';
import getUploadedDocuments from '@salesforce/apex/DocumentUploadController.getUploadedDocuments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Docinformation extends LightningElement {
    @api recordId; // Account Id from parent
    @api type; // 'salary' or 'Non-Salary'
    @track salaryType = true;

    @track adharUploaded = false;
    @track panUploaded = false;
    @track salaryUploaded = false;

    

    connectedCallback() {
       if (this.type === 'Salary') {
            this.salaryType = true;
        } else if (this.type === 'Non-Salary') {
            this.salaryType = false;
        }
       
        this.loadUploadedDocs();
    }

    loadUploadedDocs() {
        if (!this.recordId) return;
        getUploadedDocuments({ accountId: this.recordId })
            .then(result => {
                result.forEach(doc => {
                    if (doc.Document_Type__c === 'AdharCard') this.adharUploaded = doc.Is_Uploaded__c;
                    else if (doc.Document_Type__c === 'PanCard') this.panUploaded = doc.Is_Uploaded__c;
                    else if (doc.Document_Type__c === 'Salary Slip') this.salaryUploaded = doc.Is_Uploaded__c;
                });
            })
            .catch(error => console.error(error));
    }

    handleUploadFinished(event) {
        const docType = event.target.dataset.docType;
        const uploadedFiles = event.detail.files;
        const contentDocumentId = uploadedFiles[0].documentId;

        saveUploadedDocument({
            accountId: this.recordId,
            documentType: docType,
            contentDocumentId: contentDocumentId
        })
            .then(() => {
                this.showToast('Success', `${docType} uploaded successfully!`, 'success');
                if (docType === 'AdharCard') this.adharUploaded = true;
                else if (docType === 'PanCard') this.panUploaded = true;
                else if (docType === 'Salary Slip') this.salaryUploaded = true;
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}