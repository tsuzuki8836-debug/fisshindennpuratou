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
    format : function(sObjectSummary) {
        if(sObjectSummary.children) {
            const childrenArray = [];
            for(let child in sObjectSummary.children) {
                childrenArray.push(sObjectSummary.children[child]);
            }
            sObjectSummary.children = childrenArray;
        }
        return sObjectSummary;
    },
    handleErrors : function(errors) {
        console.log(errors);
        if (errors && errors.length && errors.length> 0) {
            let errorMessage = 'ERROR\n';
            for(let i = 0; i < errors.length; i++) {
                const e = errors[i];
                if(e.message) {
                    errorMessage += e.message + '\n';
                } else if(e.fieldErrors) {
                    for(let key in e.fieldErrors) {
                        const fes = e.fieldErrors[key];
                        for(let fe of fes) {
                            errorMessage += key + ' - [' + fe.statusCode + '] ' + fe.message + '\n';
                        }
                    }
                } else {
                    console.log(e);
                }
            }
            console.log(errorMessage);
            if(errorMessage) alert(errorMessage);
        } else {
            alert('Unknown error');
            console.log('Unknown error');
        }
    }
})