/**
 * 競争先トリガー
 */
trigger CompetitorTrigger on Competitors__c (after insert, before insert, after update, before update) {

    System.debug('@@CompetitorTrigger開始');
    CompetitorTriggerHandler triggerHandler = CompetitorTriggerHandler.instance();

    if (Trigger.isBefore){
        if(Trigger.isInsert){
            triggerHandler.onBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            triggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            triggerHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            triggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}