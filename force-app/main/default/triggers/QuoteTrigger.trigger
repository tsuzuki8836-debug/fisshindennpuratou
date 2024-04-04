trigger QuoteTrigger on Quote__c (before insert, before update, after insert, after update, after delete) {
    // カスタム表示ラベルで処理有無を制御。データ一括移行時はTrueにする。
    if (Boolean.valueOf(Label.SkipQuoteTrigger)) return;
    QuoteTriggerHandler handler = new QuoteTriggerHandler();

    if(Trigger.isBefore){
        if (Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new,Trigger.oldMap);
            handler.onBeforeInsertUpdate(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
            handler.onBeforeInsertUpdate(Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if (Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new);
        }
    }
}