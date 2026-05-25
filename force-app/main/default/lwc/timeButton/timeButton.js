import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initializeTimeTracking from '@salesforce/apex/TimeTrackingController.initializeTimeTracking';
import recordInTime from '@salesforce/apex/TimeTrackingController.recordInTime';
import recordOutTime from '@salesforce/apex/TimeTrackingController.recordOutTime';

export default class TimeTracking extends LightningElement {
    @track inTimeDisabled = false;
    @track outTimeDisabled = true;
    @track isLoading = false;
    @track currentInTime = '';
    @track currentOutTime = '';
    @track hasInTime = false;
    @track hasOutTime = false;

    connectedCallback() {
        this.initializeComponent();
    }

    async initializeComponent() {
        this.isLoading = true;
        try {
            const result = await initializeTimeTracking();
            if (result.success) {
                this.inTimeDisabled = result.inTimeDisabled;
                this.outTimeDisabled = result.outTimeDisabled;
                this.hasInTime = result.hasInTime;
                this.hasOutTime = result.hasOutTime;
                
                if (result.inTimeValue) {
                    this.currentInTime = this.formatTime(result.inTimeValue);
                }
                if (result.outTimeValue) {
                    this.currentOutTime = this.formatTime(result.outTimeValue);
                }
            } else {
                this.showToast('Error', result.message, 'error');
            }
        } catch (error) {
            this.showToast('Error', 'Failed to initialize time tracking: ' + (error.body?.message || error.message), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async handleInTimeClick() {
        // Prevent multiple clicks while loading
        if (this.isLoading) {
            return;
        }
        
        this.isLoading = true;
        try {
            const result = await recordInTime();
            if (result.success) {
                this.inTimeDisabled = true;
                this.outTimeDisabled = false;
                this.hasInTime = true;
                this.currentInTime = this.formatTime(result.inTimeValue);
                
                this.showToast('Success', result.message, 'success');
            } else {
                this.showToast('Error', result.message, 'error');
            }
        } catch (error) {
            this.showToast('Error', 'Failed to record in-time: ' + (error.body?.message || error.message), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async handleOutTimeClick() {
        // Prevent multiple clicks while loading
        if (this.isLoading) {
            return;
        }
        
        this.isLoading = true;
        try {
            const result = await recordOutTime();
            if (result.success) {
                this.inTimeDisabled = true;
                this.outTimeDisabled = true;
                this.hasOutTime = true;
                this.currentOutTime = this.formatTime(result.outTimeValue);
                
                this.showToast('Success', result.message, 'success');
            } else {
                this.showToast('Error', result.message, 'error');
            }
        } catch (error) {
            this.showToast('Error', 'Failed to record out-time: ' + (error.body?.message || error.message), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    formatTime(timeValue) {
        if (!timeValue) return '';
        
        let totalMilliseconds;
        
        // Check if it's a raw millisecond value (number)
        if (typeof timeValue === 'number') {
            totalMilliseconds = timeValue;
        } else if (typeof timeValue === 'string' && !isNaN(timeValue)) {
            totalMilliseconds = parseInt(timeValue);
        } else {
            // Try to parse as HH:MM:SS format
            const timeStr = timeValue.toString();
            const parts = timeStr.split(':');
            if (parts.length >= 2) {
                const hour = parseInt(parts[0]);
                const minute = parseInt(parts[1]);
                totalMilliseconds = (hour * 60 * 60 * 1000) + (minute * 60 * 1000);
            } else {
                return timeStr;
            }
        }
        
        // Convert milliseconds to hours and minutes
        const hours = Math.floor(totalMilliseconds / (1000 * 60 * 60));
        const minutes = Math.floor((totalMilliseconds % (1000 * 60 * 60)) / (1000 * 60));
        
        // Format to 12-hour format
        const period = hours >= 12 ? 'PM' : 'AM';
        const displayHour = hours > 12 ? hours - 12 : (hours === 0 ? 12 : hours);
        const displayMinute = minutes.toString().padStart(2, '0');
        
        return `${displayHour}:${displayMinute} ${period}`;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    get inTimeButtonClass() {
        return `time-button in-time-btn ${this.inTimeDisabled || this.isLoading ? 'disabled' : ''}`;
    }

    get outTimeButtonClass() {
        return `time-button out-time-btn ${this.outTimeDisabled || this.isLoading ? 'disabled' : ''}`;
    }

    get todayDate() {
        return new Date().toLocaleDateString('en-US', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    }
}