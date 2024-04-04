({
    isValueInPicklistOptions: function(component) {
        	var selectOptions = component.get("v.selectOptions");
        	var value = component.get("v.value");
    		if (typeof selectOptions !== 'undefined') {
            for (var i = 0; i < selectOptions.length; i++) {
                if (selectOptions[i].value == value) return true;
            }
          }
        return false;
    },    
    
    checkAndFormatTimeInput: function(component) {
        if(component.get('v.type') === 'time') {
            var value = component.get('v.value');
            if (value !== null && value !== undefined) {
                var splValue = value.split(":");
                if (splValue[0].length === 1) {
                    value = "0" + value;
                }
                component.set('v.value', value);
            }
        }
    }, 
    
    enableOrDisableFields: function(component) {
        var allInputTypes = [];
        allInputTypes.push(component.find("myCheckbox"));
        allInputTypes.push(component.find("myPicklist"));
        allInputTypes.push(component.find("myStandardInput"));
        for (var i = 0; i < allInputTypes.length; i++) {
            if (typeof allInputTypes[i] !== 'undefined' && typeof allInputTypes[i].getElement === 'function') {
                allInputTypes[i].getElement().disabled = component.get("v.disabled");
            }
        }
    },

    fireEventChange: function(component, value) {
        var fieldChangedEvent = $A.get("e.c:SF_EditInputChangeEvent");
		fieldChangedEvent.setParams({
			"fieldName" : component.get("v.name"), 
			"fieldType" : component.get("v.type"),
			"rowIndex" :  component.get("v.rowIndex"),
			"newValue" : value
		});
		fieldChangedEvent.fire();
    },

	formatNumber: function(component, valueNumber){
        valueNumber = ( valueNumber == null || valueNumber == 'NaN' ) ? 0 : Number(valueNumber);
        var currentScale = component.get("v.scale");
		return valueNumber.toFixed(Math.log10(1/currentScale));
	}
})