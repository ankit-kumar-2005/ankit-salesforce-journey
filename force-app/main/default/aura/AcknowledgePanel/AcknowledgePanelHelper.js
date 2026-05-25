({
    loadPolicyData: function(component) {
        var action = component.get("c.getPolicyDataAndStatus");
        action.setParams({ policyId: component.get("v.recordId") });
       
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
           
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.success) {
                    component.set("v.policyRecord", result.policyRecord);
                    component.set("v.isAcknowledged", result.isAcknowledged);
                    if (result.acknowledgmentDate) {
                        component.set("v.acknowledgmentDate", result.acknowledgmentDate);
                    }
                } else {
                    this.showMessage(component, result.message, 'error');
                }
            } else {
                this.showMessage(component, 'Error loading policy data', 'error');
            }
        });
       
        $A.enqueueAction(action);
    },
   
    createAcknowledgment: function(component) {
        component.set("v.isLoading", true);
       
        var action = component.get("c.createPolicyAcknowledgment");
        action.setParams({ policyId: component.get("v.recordId") });
       
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
           
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.success) {
                    component.set("v.isAcknowledged", true);
                    component.set("v.acknowledgmentDate", result.acknowledgmentDate);
                    this.showMessage(component, 'Policy acknowledged successfully!', 'success');
                } else {
                    this.showMessage(component, result.message, 'error');
                }
            } else {
                this.showMessage(component, 'Error creating acknowledgment', 'error');
            }
        });
       
        $A.enqueueAction(action);
    },
   
    showMessage: function(component, message, type) {
        component.set("v.message", message);
        component.set("v.messageType", type);
    }
})