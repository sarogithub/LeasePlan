({
    createComp : function(cmp, event, helper){
        let objInfo = cmp.get("v.obj");

        $A.createComponent(
            cmp.get("v.ComponentName"),
            {
                "aura:id": cmp.get("v.AuraId"),
                "fieldValue" : objInfo[cmp.get("v.FieldName")]
            },
            function(newProgressBar, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = cmp.get("v.body");
                    body.push(newProgressBar);
                    cmp.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    }
})
