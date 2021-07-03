({
    getCompanyRecords: function(component, event, helper){
        var action = component.get("c.getCompanyRecords");
        var params = {};

        component.find("apexProxy").call(action, params,
            function(response){
                component.set("v.companies", response.companyRecords);
                component.set("v.fieldsAndCompType", response.fieldsAndCompType);
            },
            function(errorResponse){
                component.find("notify").showError(errorResponse);
            },
            false,
            true,
            true
        );
    }
})
