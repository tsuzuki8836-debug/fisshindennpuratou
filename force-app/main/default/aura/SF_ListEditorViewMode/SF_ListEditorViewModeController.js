({
    reloadData: function(cmp, event, helper){
        var recordList = cmp.get('v.recordList');
        const isHaveNoError = cmp.get("v.isHaveNoError");
        let recordTypes = cmp.get('v.recordTypes');
        if (isHaveNoError) {
            helper.getColumnDefinitions(cmp, recordList);
            helper.getObjectLabel(cmp);
            helper.getRelationshipName(cmp);
            helper.getTabStyle(cmp); 
            if(recordTypes.length){
                cmp.set('v.recordTypeId',recordTypes.some(rt => rt.checked).value);
            }
        }
    },

    refresh: function(cmp, event, helper){
        var compEvent = cmp.getEvent("refreshRecordList");
        compEvent.fire();
    },

    updateColumnSorting: function(cmp, event, helper) {
        var sortColName;
        var temp = event.getParam('fieldName');
        var prefixes = ['refer','per','pick','time','cur'];
        cmp.set("v.sortedBy", temp);
        sortColName = temp;
        prefixes.some(prefix => {
            if(temp.indexOf(prefix) == 0) {
                sortColName = temp.slice(prefix.length);
                return true;
            }
        });
        var sortDESC = cmp.get("v.isOrderDESC"),
		sortField = cmp.get("v.orderField"),
        sortDESC = (sortColName == sortField) ? !sortDESC : sortDESC;
        cmp.set("v.sortedDirection", sortDESC ? 'desc' : 'asc');
		cmp.set("v.orderField", sortColName);
		cmp.set("v.isOrderDESC", sortDESC);
    },

    handleRowAction: function(cmp, event, helper){
    	var action = event.getParam('action');
        var row = event.getParam('row');
        var rows = cmp.get('v.rawData');
        var rowIndex = rows.indexOf(row);
        var recordId = rows[rowIndex]['Id'];
        cmp.set('v.selectedRowId', recordId);
        switch (action.name) {
            case 'edit':
                helper.handleEditRow(cmp,event);
                break;
            case 'delete':
                cmp.set("v.isOpen", true);
                break;
        }
    },

    deleteRecord: function(cmp, event, helper){
        helper.handleDeleteRow(cmp);
        cmp.set("v.isOpen", false);
    },

    closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
    },

    navigateToListView: function(cmp, event, helper){
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": cmp.get('v.relationField'),
            "parentRecordId": cmp.get('v.recordId')
        });
        relatedListEvent.fire();
    },

    switchMode: function(cmp, event, helper){
    	cmp.set('v.isEditMode',true);
    },

    addMode: function(cmp, event, helper){
        let recordTypes = cmp.get('v.recordTypes');
        let createRecord = cmp.get('c.createRecord');
        let chooseRecordType = cmp.get('c.toggleChooseRecordTypePopup');

        if(recordTypes.length == 1 || recordTypes.length == 0){
            $A.enqueueAction(createRecord);
        }else{
            $A.enqueueAction(chooseRecordType);
        }
    },

    onChangeParent: function(cmp, event, helper){
        var compEvent = cmp.getEvent("refreshRecordList");
        compEvent.setParams({parentField: cmp.get('v.parentField')});
        compEvent.fire();
    },

    toggleChooseRecordTypePopup: function(cmp,event,helper){
        let isChooseRecordType = cmp.get('v.isChooseRecordType');
        let recordTypes = cmp.get('v.recordTypes');
        recordTypes = recordTypes.map(rt =>{
            rt.checked = rt.default;
            return rt;
        })
        if(recordTypes.length){
            cmp.set('v.recordTypeId',recordTypes.some(rt => rt.default).value);
        }
        cmp.set('v.isChooseRecordType',!isChooseRecordType);
    },
    createRecord: function(cmp, event, helper){
        var objectName = cmp.get('v.objectName');
        var recordId = cmp.get('v.recordId');
        var objectDefaultValue;
        try{
            objectDefaultValue = JSON.parse(cmp.get("v.defaultValueAddList"));
        }catch(e){
            objectDefaultValue = {};
        } 
        objectDefaultValue[cmp.get('v.parentField')] = recordId;

        var createObjectEvent = $A.get("e.force:createRecord");
        var createRecordConfig = {
            entityApiName: objectName,
            defaultFieldValues: objectDefaultValue
        };
        if(cmp.get('v.recordTypeId')){
            createRecordConfig.recordTypeId = cmp.get('v.recordTypeId');
        }
        createObjectEvent.setParams(createRecordConfig);
        createObjectEvent.fire();
        
        cmp.set('v.isChooseRecordType',false);
    },
    changeRecordeTypeId: function(cmp, event, helper){
        let recordTypeId = event.getSource().get("v.value");
        let recordTypes = cmp.get('v.recordTypes');
        recordTypes = recordTypes.map(rt =>{
            rt.checked = rt.value == recordTypeId;
            return rt;
        })
        cmp.set('v.recordTypes',recordTypes);
        cmp.set('v.recordTypeId',recordTypeId);
    }
})