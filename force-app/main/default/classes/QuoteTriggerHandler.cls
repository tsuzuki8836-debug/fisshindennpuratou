public class QuoteTriggerHandler {
    QuoteTriggerLogic logic = new QuoteTriggerLogic();

    public void onBeforeInsert(List<Quote__c> newList){
        logic.calculateNETItem(newList, null);
        logic.convertStrings(newList);

    }

    public void onBeforeUpdate(List<Quote__c> newList,Map<Id,Quote__c> oldMap){
        logic.calculateNETItem(newList, oldMap);
        logic.equipManageCostCalculation(newList);
        logic.convertStrings(newList);
    }

    public void onAfterInsert(List<Quote__c> newList){
        logic.cloneQuoteAndRelatedRecords(newList);
    }

}