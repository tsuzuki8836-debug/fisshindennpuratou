public class QuoteTriggerHandler {
    QuoteTriggerLogic logic = new QuoteTriggerLogic();
    List<Quote__c> qList =new List<Quote__c>();

    public void onBeforeInsert(List<Quote__c> newList,Map<Id,Quote__c> oldMap){
        logic.calculateNETItem(newList,oldMap);
    }

    public void onBeforeUpdate(List<Quote__c> newList,Map<Id,Quote__c> oldMap){
        logic.calculateNETItem(newList,oldMap);
        logic.equipManageCostCalculation(newList);
    }

    public void onAfterInsert(List<Quote__c> newList){
        logic.cloneQuoteAndRelatedRecords(newList);
    }

    /**
     * 全角→半角変換
     *
     * @param value 変換元文字列
     * @return 半角文字列
     */
    public void onBeforeInsertUpdate(List<Quote__c> quoteList){
        for (Quote__c q : quoteList) {
            String value = q.GeneralAdministrativeExpenses__c;
            System.debug('value'+value);
            logic.convertFullToHalf(value);
            q.GeneralAdministrativeExpenses__c = logic.convertFullToHalf(value);
            System.debug('q='+q.GeneralAdministrativeExpenses__c);
            qList.add(new Quote__c ( QuoteNumber__c = q.QuoteNumber__c
                                    ,GeneralAdministrativeExpenses__c = q.GeneralAdministrativeExpenses__c
                                    ,PowerFrequency__c = q.PowerFrequency__c
                                    ,RecordTypeId = q.RecordTypeId
                                    ));
            System.debug('new'+qList);
        }
    }
}