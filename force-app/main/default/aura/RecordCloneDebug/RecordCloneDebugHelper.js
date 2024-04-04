({
    callAction : function(c, actionName, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            const action = c.get(actionName);
            action.setParams(params);            
            action.setCallback(this, function(response) {
                const state = response.getState();
                if (state === 'SUCCESS') {
                    resolve(response.getReturnValue());
                } else {
                    reject(response.getError());
                }
            });
            $A.enqueueAction(action);
        }));
    },
})