({
    handleClick : function(component, event, helper) {
        helper.acknowledgeRecord(component);
    }
})
({
    doInit : function(component, event, helper) {
        let action = component.get("c.checkAcknowledged");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.isDisabled", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})