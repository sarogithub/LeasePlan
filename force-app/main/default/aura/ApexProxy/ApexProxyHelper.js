({
    call : function(component, event, helper) {
        console.log('test');
        var args = event.getParam('arguments');
        if(args.showSpinner) component.find("spinner").show();
        var action = args.action;

        action.setParams(args.actionParams);
        if(args.store == true) action.setStorable();
        action.setCallback(this, function(response) {
            switch( response.getState()) {
              default: break;
              case 'NEW': break;
              case 'RUNNING': break;
              case 'SUCCESS':
                  this.handleSuccess(component, args, response.getReturnValue());
                  break;
              case 'ERROR':
              case 'INCOMPLETE':
                  this.handleError(component, args, response);
                  break;
          }
        });
        $A.enqueueAction(action);
    },
    handleSuccess: function(component, args, responseValue){
        var onSuccess = args.onSuccess;
        onSuccess(responseValue, component);
        if(args.showSpinner) component.find("spinner").hide();

    },
    handleError: function(component, args, response){
        if(args.showNotification){
            component.find("notify").showErrorResponse(response);
        }
        var onError = args.onError;
        onError(response, component);
        if(args.showSpinner) component.find("spinner").hide();
    }
})