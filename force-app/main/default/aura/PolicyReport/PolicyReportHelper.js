({
    /**
     * Load policy report data from server
     */
    loadReportData: function(component) {
        console.log('Helper - loadReportData called');
       
        component.set("v.isLoading", true);
        component.set("v.errorMessage", "");
       
        var action = component.get("c.getPolicyReportData");
       
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
           
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('getPolicyReportData result:', result);
               
                if (result.success) {
                    component.set("v.policyReportData", result.reportData);
                    this.updateSummaryTotals(component, result.reportData);
                    console.log('Report data loaded successfully. Records count:', result.reportData.length);
                } else {
                    this.showError(component, result.message);
                }
            } else {
                var errors = response.getError();
                console.error('Error in getPolicyReportData:', errors);
                this.showError(component, "Error loading report data: " + this.getErrorMessage(errors));
            }
        });
       
        $A.enqueueAction(action);
    },
   
    /**
     * Update summary totals at the bottom
     */
    updateSummaryTotals: function(component, reportData) {
        var totalAcknowledged = 0;
        var totalPending = 0;
       
        reportData.forEach(function(policy) {
            totalAcknowledged += policy.acknowledgedCount;
            totalPending += policy.pendingCount;
        });
       
        // Update the summary display
        var acknowledgedElement = component.find("totalAcknowledged");
        var pendingElement = component.find("totalPending");
       
        if (acknowledgedElement) {
            acknowledgedElement.getElement().textContent = totalAcknowledged;
        }
       
        if (pendingElement) {
            pendingElement.getElement().textContent = totalPending;
        }
       
        console.log('Summary totals - Acknowledged:', totalAcknowledged, 'Pending:', totalPending);
    },
   
    /**
     * Show error message
     */
    showError: function(component, message) {
        component.set("v.errorMessage", message);
        console.error('Error:', message);
    },
   
    /**
     * Extract error message from response
     */
    getErrorMessage: function(errors) {
        var message = "Unknown error";
        if (errors && errors.length > 0) {
            message = errors[0].message;
        }
        return message;
    }
})