({
	doInit : function(component,event,helper) {
	  var objectName = component.get('v.objectName');
    var fields = component.get('v.fields');
    var rowsToLoad = component.get('v.viewRowsToLoad');
    var recordId = component.get('v.recordId');
    var parentField = component.get('v.parentField');
    var conditionsFilterList = component.get('v.conditionsFilterList');
    var orderField = component.get('v.orderField');
    var isOrderDESC = component.get('v.isOrderDESC');
    var offset = "0";
    helper.getRecordList(component, objectName, fields, rowsToLoad, recordId, parentField, offset, conditionsFilterList,isOrderDESC,orderField);
	},
  refreshRecordList: function(cmp, event, helper){
    var parentField = event.getParam("parentField");

    cmp.set('v.parentField', parentField);
    
    var objectName = cmp.get('v.objectName');
    var fields = cmp.get('v.fields');
    var rowsToLoad = cmp.get('v.viewRowsToLoad');
    var recordId = cmp.get('v.recordId');
    var offset = "0";
    var isOrderDESC = cmp.get('v.isOrderDESC');
    var orderField = cmp.get('v.orderField');
    var conditionsFilterList = cmp.get('v.conditionsFilterList');
    helper.getRecordList(cmp, objectName, fields, rowsToLoad, recordId, parentField,offset,conditionsFilterList,isOrderDESC,orderField);
  }
})