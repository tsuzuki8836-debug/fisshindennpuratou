trigger DeviceTrigger on Device__c (before insert, before update, after insert, after update, after delete) {
      // カスタム表示ラベルで処理有無を制御。データ一括移行時はTrueにする。
      if (Boolean.valueOf(Label.SkipQuoteTrigger)) return;
      DeviceTriggerHandler handler = new DeviceTriggerHandler();
      
      if(Trigger.isBefore){
            if (Trigger.isInsert) {
                  handler.onBeforeInsert(Trigger.new);
            } else if (Trigger.isUpdate) {
                  handler.onBeforeUpdate(Trigger.new);
            }
      }

      if(Trigger.isAfter){
            if (Trigger.isInsert){
                  handler.onAfterInsert(Trigger.new);
            }
            if (Trigger.isUpdate) {
                  handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
            }
            if (Trigger.isDelete){
                  handler.onAfterDelete(Trigger.old);
            }
      }      

}