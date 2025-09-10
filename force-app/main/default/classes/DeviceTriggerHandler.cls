public class DeviceTriggerHandler {
    DeviceTriggerLogic logic = new DeviceTriggerLogic();
    List<Device__c> dList =new List<Device__c>();

    public void onAfterInsert(List<Device__c> newList){
        logic.cloneDeviceAndRelatedRecords(newList);
        logic.updateConstructionZone(newList,new List<Device__c>());
        // List<Device__c> deviceTargetList = logic.getDeviceTargetRectype(newList);
        // if(deviceTargetList.isEmpty()) return;
        // deviceTargetList = logic.getDeviceTragetCheckedList(deviceTargetList);
        // if(deviceTargetList.isEmpty()) return;
        // Map<Id, List<Device__c>> quoteIdMap = logic.getQuoteIdByDevice(deviceTargetList);
        //logic.equipManageCostCalculation(newList,new List<Device__c>());
    }

    public void onAfterUpdate (Map<Id, Device__c> oldMap, Map<Id, Device__c> newMap) {
        logic.updateConstructionZone(newMap.values(),oldMap.values());
        // List<Device__c> deviceTargetList = logic.getDeviceTargetRectype(newMap.values());
        // if(deviceTargetList.isEmpty()) return;
        // deviceTargetList = logic.getDeviceValueChangedList(deviceTargetList, oldMap, newMap);
        // if(deviceTargetList.isEmpty()) return;
        // Map<Id, List<Device__c>> quoteIdMap = logic.getQuoteIdByDevice(deviceTargetList);
        //logic.equipManageCostCalculation(newMap.values(),oldMap.values());
    }

    public void onAfterDelete(List<Device__c> oldList){
        logic.updateConstructionZone(new List<Device__c>(),oldList);
        // List<Device__c> deviceTargetList = logic.getDeviceTargetRectype(oldList);
        // if(deviceTargetList.isEmpty()) return;
        // Map<Id, List<Device__c>> quoteIdMap = logic.getQuoteIdByDevice(deviceTargetList);
        //logic.equipManageCostCalculation(new List<Device__c>(),oldList);
    }

    /**
     * 全角→半角変換
     *
     * @param value 変換元文字列
     * @return 半角文字列
     */
    public void onBeforeInsert(List<Device__c> deviceList){
        Map<Id,List<Device__c>> quotemap = new Map<Id,List<Device__c>>();
        for (Device__c d : deviceList) {
            String value = d.Quantity__c;
            System.debug('value'+value);
            //logic.convertFullToHalf(value);
            d.Quantity__c = logic.convertFullToHalf(value);
            System.debug('d='+d.Quantity__c);
            if(quotemap.containskey(d.Quote__c)){
                quotemap.get(d.Quote__c).add(d);
            }else{
                quotemap.put(d.Quote__c,new List<Device__c>());
                quotemap.get(d.Quote__c).add(d);
            }
        }
        logic.quoteSpecificationNumberCheck(quotemap);
        logic.updateOfficialDemandField(deviceList);
        logic.deviceConstructionZoneSetting(deviceList);
    }

    /**
     * 全角→半角変換
     *
     * @param value 変換元文字列
     * @return 半角文字列
     */
    public void onBeforeUpdate(List<Device__c> deviceList){
        Map<Id,List<Device__c>> quotemap = new Map<Id,List<Device__c>>();
        for (Device__c d : deviceList) {
            String value = d.Quantity__c;
            System.debug('value'+value);
            //logic.convertFullToHalf(value);
            d.Quantity__c = logic.convertFullToHalf(value);
            System.debug('d='+d.Quantity__c);
            if(quotemap.containskey(d.Quote__c)){
                quotemap.get(d.Quote__c).add(d);
            }else{
                quotemap.put(d.Quote__c,new List<Device__c>());
                quotemap.get(d.Quote__c).add(d);
            }
        }
        logic.quoteSpecificationNumberCheck(quotemap);
        logic.deviceConstructionZoneSetting(deviceList);
        logic.updateFieldFromQuoteValues(deviceList);
        logic.updateOfficialDemandField(deviceList);
    }
}