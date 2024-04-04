/**
 * SR情報トリガー
 */
trigger SRInfoTrigger on SRInfo__c (before insert, before update, after insert, after update, after delete) {

    SRInfoTriggerHandler handler = new SRInfoTriggerHandler();

    if (Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        handler.onBeforeUpdate(Trigger.new);
    }    
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate(Trigger.old,Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
        handler.onAfterDelete(Trigger.old);
    }

}