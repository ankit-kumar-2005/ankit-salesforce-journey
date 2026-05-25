import { LightningElement,track, wire } from 'lwc';
import getLastFiveDaysEntries from '@salesforce/apex/LastTimeEntryController.getLastFiveDaysEntries';
const COLUMNS = [
    { label: 'Date', fieldName: 'Date__c' },
    { label: 'Total Hours', fieldName: 'Total_Hours__c' }
];

export default class Last5TimeEntryLWC extends LightningElement {
     @track timeEntries = [];
     columns = COLUMNS;


     @wire(getLastFiveDaysEntries)
        allTimeEntry ({ error, data }) {
        if (data) {
            this.timeEntries = data;
            console.log(data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log(error);
            this.timeEntries = [];
        }
    }
}