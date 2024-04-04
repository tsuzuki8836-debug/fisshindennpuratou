/**
 * 場所別トリガーハンドラー
 */
public class FactoryTriggerHandler {

    FactoryTriggerLogic logic = new FactoryTriggerLogic();

    public void onBeforeInsert (List<Factory__c> newList) {
        logic.beforeInsert(newList);
    }

    public void onBeforeUpdate (List<Factory__c> newList, Map<Id, Sobject> oldMap) {
        logic.beforeUpdate(newList, oldMap);
    }

    public void onAfterInsert (Map<Id, Sobject> newMap) {
        logic.sumInsert(newMap);
    }

    public void onAfterUpdate (Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap, List<Factory__c> newList) {
        logic.sumUpdate(newMap, oldMap);
        logic.setOppLastModDateTime(newList, oldMap);
    }

    public void onAfterDelete (Map<Id, Sobject> oldMap) {
        logic.sumDelete(oldMap);
    }

    public void checkUpdate(List<Factory__c> newList) {
        if (logic.isNeedUpdate()){
            logic.execCalculation(newList);
        }
    }
}