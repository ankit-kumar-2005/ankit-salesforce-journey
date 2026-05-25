({
    /**
     * Initialize component on load
     */
    doInit: function(component, event, helper) {
        console.log('PolicyReportComponent - doInit called');
        helper.loadReportData(component);
    },
   
    /**
     * Refresh report data
     */
    refreshData: function(component, event, helper) {
        console.log('PolicyReportComponent - refreshData called');
        component.set("v.errorMessage", "");
        helper.loadReportData(component);
    }
})