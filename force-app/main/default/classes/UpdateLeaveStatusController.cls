public with sharing class UpdateLeaveStatusController {
    private final ApexPages.StandardSetController stdController;
    public String newStatus { get; set; }

    public UpdateLeaveStatusController(ApexPages.StandardSetController controller) {
        this.stdController = controller;
    }

    public List<Leave__c> getSelected() {
        return (List<Leave__c>) stdController.getSelected();
    }

    public PageReference updateStatus() {
        List<Leave__c> selectedLeaves = getSelected();

        // Validate selection
        if (selectedLeaves == null || selectedLeaves.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Please select at least one record to update.'
            ));
            return null;
        }

        // Validate new status
        if (String.isBlank(newStatus)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Please select a new status before updating.'
            ));
            return null;
        }

        Boolean hasError = false;

        // Check Approved → Rejected
        for (Leave__c lv : selectedLeaves) {
            if (lv.Leave_Status__c == 'Approved' && newStatus == 'Rejected') {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'You cannot change the status from Approved to Rejected for leave: ' + lv.Name
                ));
                hasError = true;
            }
        }

        if (hasError) return null;

        // Update leaves
        try {
            for (Leave__c lv : selectedLeaves) {
                lv.Leave_Status__c = newStatus;
            }
            update selectedLeaves;

            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.CONFIRM, 'Leave status updated successfully!'
            ));

            return null; // stay on the same page, rerender will refresh table/messages

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Error updating records: ' + e.getMessage()
            ));
            return null;
        }
    }

    public PageReference cancel() {
        return null;
    }
}