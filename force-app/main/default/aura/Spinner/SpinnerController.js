({
    show: function(component, event, helper) {
        component.set("v.showSpinner", true);
    },
    hide: function(component, event, helper) {
        component.set("v.showSpinner", false);
    }
})