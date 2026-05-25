import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountForm extends LightningElement {
    @track filldocument=false;
    @track newAccntType;
    @track recordId;

    handleSuccess(event) {
        const accountId = event.detail.id;
        this.recordId = accountId;

        this.newAccntType=event.detail.fields.Type.value;
        this.filldocument=true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: `Account created successfully. Id: ${accountId}`,
                variant: 'success'
            })
        );
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating account',
                message: event.detail.message,
                variant: 'error'
            })
        );
    }
}