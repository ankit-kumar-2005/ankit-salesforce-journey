({
    acknowledgeRecord : function(component) {
        let action = component.get("c.acknowledgePolicy");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isDisabled", true);
                alert("Acknowledged successfully!");
            } else {
                let errors = response.getError();
                console.error(errors);
                alert("Error acknowledging the record.");
            }
        });
        $A.enqueueAction(action);
    }
})