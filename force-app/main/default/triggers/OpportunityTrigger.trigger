/**
 * 案件トリガー
 */
trigger OpportunityTrigger on Opportunity (before insert, before update, before delete,after insert, after update) {

    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    if (Trigger.isBefore && Trigger.isUpdate) {
        handler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isInsert){
        handler.onAfterInsert(Trigger.new);
    }
}