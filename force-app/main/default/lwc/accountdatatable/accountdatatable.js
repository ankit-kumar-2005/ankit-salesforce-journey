import { LightningElement, api, track } from 'lwc';
import getAccountList from '@salesforce/apex/Accountdatatablecontroller.getAccountList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Account Name', fieldName: 'Name' },
    { label: 'Account Type', fieldName: 'Type' }
];

export default class AccountDatatable extends LightningElement {
    @api mobileNo;
    @track accountList = [];
    @track error;
    @track selectedAccountId;
    @track accountExist = false;
    @track filldocument = false;
    @track newAccntType;
    @track showform = false;
    @track showtable = true;
    @track recordId;
    columns = COLUMNS;

    connectedCallback() {
        this.loadAccountList();
    }

    loadAccountList() {
        getAccountList({ mobileNo: this.mobileNo })
            .then(result => {
                if (result && result.length > 0) {
                    this.accountList = result;
                    this.accountExist = true;
                } else {
                    this.accountList = [];
                    this.accountExist = false;
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error.body ? error.body.message : error;
                this.accountList = [];
                this.accountExist = false;
            });
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.selectedAccountId = selectedRows[0].Id;
            this.showform = true;
            this.newAccntType = selectedRows[0].Type;
            console.log('Selected Type:', this.newAccntType);
        } else {
            this.selectedAccountId = null;
            this.showform = false;
        }
        this.showtable = false;
    }

  handleSaveSuccess(event) {
    this.showToast('Success', 'Account Updated Successfully', 'success');
    this.showform = false;
    this.filldocument = true;

    // Get the updated Account Type
    const updatedFields = event.detail.fields;
    this.newAccntType = updatedFields.Type.value; 
    this.recordId = event.detail.id;

    console.log('Record updated successfully!');
    console.log('Updated Account Type:', this.newAccntType);
}

    handleSaveError(event) {
        console.error('Error updating record: ', event.detail);
        this.showToast('Error', 'Failed to update account', 'error');
    }

    handleCancel() {
        this.selectedAccountId = null;
        this.showform = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}