({
    doInit: function(component, event, helper) {
        helper.loadPolicyData(component);
    },
   
    handleAcknowledge: function(component, event, helper) {
        if (!component.get("v.isAcknowledged")) {
            helper.createAcknowledgment(component);
        }
    }
})