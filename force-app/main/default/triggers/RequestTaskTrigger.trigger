trigger RequestTaskTrigger on RequestTask__c (before insert, before update, after update) {

    RequestTaskTriggerHandler handler = new RequestTaskTriggerHandler();
    if(Trigger.isBefore && Trigger.isInsert){
        handler.isBeforeInsert(Trigger.new);
    } else if(Trigger.isBefore && Trigger.isUpdate){
        handler.isBeforeUpdate(Trigger.new, Trigger.oldMap);
    } else if(Trigger.isAfter && Trigger.isUpdate){
        handler.isAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}