trigger RequestTaskTrigger on RequestTask__c (after update) {

    RequestTaskTriggerHandler handler = new RequestTaskTriggerHandler();
    if(Trigger.isAfter && Trigger.isUpdate){
        handler.isAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}