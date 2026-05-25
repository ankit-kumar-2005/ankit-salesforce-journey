import { LightningElement, wire } from 'lwc';
import getLeaveBalanceForCurrentUser from '@salesforce/apex/LeaveBalanceLWCControler.getLeaveBalanceForCurrentUser';

export default class LeaveBalanceCircle extends LightningElement {
    leaveBalance = null;

    @wire(getLeaveBalanceForCurrentUser)
    wiredLeaveBalance({ error, data }) {
        if (data && typeof data.Leave_Balance__c !== "undefined" && data.Leave_Balance__c !== null) {
            this.leaveBalance = data.Leave_Balance__c;
        } else if (error) {
            this.leaveBalance = null;
        }
    }
}