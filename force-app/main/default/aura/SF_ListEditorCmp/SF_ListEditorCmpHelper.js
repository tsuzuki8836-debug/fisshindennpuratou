({
   getRecordList: function(component, objectName, fields, rowsToLoad, recordId, parentField, offset, filter,isOrderDESC,orderField) { 
      component.set("v.isLoading", true);
      // create a server side action. 
      var action = component.get("c.getRecordList");

      action.setParams({
         "objectName": objectName,
         "fields": fields,
         "limitRecs": rowsToLoad,
         "recordId": recordId,
         "parentField": parentField,
         "offset": offset,
         "filter": filter,
         'isOrderDESC': isOrderDESC,
         'orderField':orderField
      });
      // set a call back   
      action.setCallback(this, (a)=>{
         // store the response return value (wrapper class insatance)  
         var result = a.getReturnValue();     
         // set the component attributes value with wrapper class properties.
         if(result && a.getState() === "SUCCESS"){
            result.fieldsLocation.forEach((field)=>{
               fields = fields.replace(field.fieldApi,field.fieldDetail);
            })
            this.setFieldsEachMode(component,fields);
            //Remove if fields seperated on two mode 
            component.set('v.fields',fields);
            component.set("v.parentFieldList", result.parentFieldList);
            component.set("v.hasMoreRecord", result.hasMoreRecord);
            component.set("v.parentField", result.parentField);
            component.set("v.sObjectName", result.sObjectName);
            component.set("v.objectName", result.objectName);
            component.set('v.isHaveOrderField',result.hasLEOrderField);
            component.set('v.orderFieldAPI',result.orderFieldAPI);
            component.set('v.recordTypes',result.recordTypes);
            if(result.caseField != '') {
               result.records.forEach(e => {
                  if (e["ToCase__r"] && !e["ToCase__r"]["Subject"]) {
                     e["ToCase__r"]["Subject"] = e["ToCase__r"]["CaseNumber"];
                  }
               });
            }
            component.set("v.recordList", result.records);
         } else if (a.getState() === "ERROR") {
            this.handleListEditorException(component, "レコードの取得中に例外が発生しました。アプリケーションビルダー上で表示項目設定またはフィルター設定が正しいかどうかをご確認ください。");
        }
         component.set("v.isLoading", false);
      });
      // enqueue the action 
      $A.enqueueAction(action);
   },

   handleListEditorException: function (component, exceptionMessage) {
      const title = this.getComponentTitle(component);
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
            "title": 'リストエディターコンポーネントの例外: ' + title,
            "message": exceptionMessage,
            "type" : 'error'
      });
      toastEvent.fire();
      component.set("v.isHaveNoError", false);
   },

   getComponentTitle: function (component) {
      const defaultTitle = component.get("v.defaultLabel");
      if (defaultTitle) {
         return defaultTitle;
      }
      return component.get("v.title")
   },
   setFieldsEachMode: function(component,fields){
      let fieldsViewMode = [];
      let fieldsEditMode = [];
      let numFieldsViewMode = component.get('v.numOfFieldsViewMode');
      let numFieldsEditMode = component.get('v.numOfFieldsEditMode');
      fields = fields.split(',');
      if(numFieldsViewMode < numFieldsEditMode){
         this.pushFieldsEachMode(fields,fieldsViewMode,numFieldsViewMode,fieldsEditMode,numFieldsEditMode);
      }else{
         this.pushFieldsEachMode(fields,fieldsEditMode,numFieldsEditMode,fieldsViewMode,numFieldsViewMode);
      }
      component.set('v.fieldsViewMode',fieldsViewMode.join(','));
      component.set('v.fieldsEditMode',fieldsEditMode.join(','));
   },
   pushFieldsEachMode: function(fields,modeFirst,numFirst,modeSecond,numSecond){
      let index = 0;
      while(index < fields.length && index<numFirst){
         modeFirst.push(fields[index]);
         modeSecond.push(fields[index++]);
      }
      while(index < fields.length && index<numSecond){
         modeSecond.push(fields[index++]);
      }
   }
})