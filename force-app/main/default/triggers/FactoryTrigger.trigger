/**
 * 場所別トリガー
 */
trigger FactoryTrigger on Factory__c (before insert, before update, after insert, after update, after delete) {

    //System.debug('★★★FactoryTrigger開始');
    if (Boolean.valueOf(Label.SkipFactoryTrigger)) return;   // Trueの場合、処理をSkip
    FactoryTriggerHandler handler = new FactoryTriggerHandler();

    if(Trigger.isBefore){
        if (Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onAfterInsert(Trigger.newMap);
        }
        if (Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new);
        }
        if (Trigger.isDelete) {
            handler.onAfterDelete(Trigger.oldMap);
        }
        handler.checkUpdate(Trigger.new);
    }
}