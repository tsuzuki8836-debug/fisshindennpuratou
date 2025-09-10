public class ConstructionZoneTriggerHandler {
    ConstructionZoneTriggerLogic logic = new ConstructionZoneTriggerLogic();

    public void onBeforeInsert(List<ConstructionZone__c> newList){
        //logic.cloneDeviceAndRelatedRecords(newList);
    }

    public void onBeforeUpdate (List<ConstructionZone__c> newList) {
        logic.equipManageCostCalculation(newList);
    }
}