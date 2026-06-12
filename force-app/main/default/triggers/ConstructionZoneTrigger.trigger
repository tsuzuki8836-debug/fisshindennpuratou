/**
 * 工事区分トリガー
 */
trigger ConstructionZoneTrigger on ConstructionZone__c (before insert,before update) {
    ConstructionZoneTriggerHandler handler = new ConstructionZoneTriggerHandler();
      
    if(Trigger.isBefore){
        if (Trigger.isInsert) {
                handler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
                handler.onBeforeUpdate(Trigger.new);
        }
    }
}