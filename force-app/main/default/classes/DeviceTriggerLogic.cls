public class DeviceTriggerLogic {
    @testvisible private static final Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
    //べき乗計算
    @testvisible private static final Double EXPONENT = -0.4711;
    //14,000千円
    @testvisible private static final Integer PRICE_A = 14000*1000;
    //200,000千円
    @testvisible private static final Integer PRICE_B = 200000*1000;
    // 項目取得Utilクラスをインスタンス化
    GetAllFieldsUtil util = new GetAllFieldsUtil();
//コメントアウト理由:機器管理費について、見積積算プロジェクトでは対応しないのでコメントアウト
    // public void equipManageCostCalculation(Set<id> quoteIds){
    //     if(quoteIds.isEmpty()) return;
    //     List<Quote__c> qtList = getQuotes(quoteIds);
    //     for(Quote__c qt : qtList){
    //         if(qt.Devices__r.isEmpty()){
    //             //機器管理費
    //             qt.EquipManageCost__c = null;
    //             //機器管理費率
    //             qt.EquipManageCostRate__c = null;
    //         }else{
    //             setQuoteValues(qt);
    //         }
    //     }
    //     update qtList;
    // }

    // private void setQuoteValues(Quote__c quote){
    //     // 機器単体費
    //     Double sumPriceTarget = getSumPriceTarget(quote.Devices__r);
    //     //機器管理費率
    //     Double equipManageCostRate = getEquipManageCostRate(sumPriceTarget);
    //     //機器管理費
    //     quote.EquipManageCost__c = sumPriceTarget * equipManageCostRate;
    //     //機器管理費率
    //     quote.EquipManageCostRate__c = equipManageCostRate * 100;

    // }
    

    // /**
    //  * 機器単体費を取得
    //  */
    
    // private Double getSumPriceTarget(List<Device__c> deviceList){
    //     Double sumPriceTarget = 0.0;
    //     for(Device__c dv : deviceList){
    //         sumPriceTarget += dv.PriceSum__c;
    //     }

    //     return sumPriceTarget;
    // }
    

    // /**
    //  * 機器管理費率を取得
    //  */
    
    // private Double getEquipManageCostRate(Double sumPriceTarget){
    //     Double equipManageCostRate;
    //     //PRICE_A = 14,000千円  ,  PRICE_B = 200,000千円
    //     if(sumPriceTarget <= PRICE_A){
    //         //機器単体費が 14,000千円以下
    //         equipManageCostRate = (18.22)/100;            
    //     }else if(sumPriceTarget>PRICE_A && sumPriceTarget<=PRICE_B){
    //         //EXPONENT = -0.4711
    //         equipManageCostRate = ( 42380.2 * (Math.pow(sumPriceTarget, EXPONENT)) )/100;            
    //     }else{
    //         //機器単体費が200,000千円を越える
    //         equipManageCostRate = (5.21)/100;
    //     }

    //     return equipManageCostRate;
    // }
    

    // /**
    //  * レコードタイプ「官需」の見積の機器を取得
    //  */
    
    // public List<Device__c> getDeviceTargetRectype(List<Device__c> quoteList){
    //     List<Device__c> deviceList = new List<Device__c>();
    //     Map<Id, List<Device__c>> quoteIdByDevices = getQuoteIdByDevice(quoteList);
    //     Set<Id> quoteIdSet = getQuoteIdsRecTypeOfficialDemand(quoteIdByDevices.keySet());
    //     if(quoteIdSet.isEmpty()) return deviceList;
    //     for(Id qtId : quoteIdSet){
    //         for(Device__c dv : quoteIdByDevices.get(qtId)){
    //             deviceList.add(dv);
    //         }
    //     }

    //     return deviceList;
    // }
    

    // /**
    //  * 機器管理費集計対象がチェックのリスト
    //  */
    
    // public List<Device__c> getDeviceTragetCheckedList(List<Device__c> newList){
    //     List<Device__c> newDeviceList = new List<Device__c>();
    //     for(Device__c dv : newList){
    //         if(dv.EquipManageCostTarget__c){
    //             newDeviceList.add(dv);
    //         }
    //     }

    //     return newDeviceList;
    // }
    

    // /**
    //  * 
    //  */
    
    // public List<Device__c> getDeviceValueChangedList(List<Device__c> deviceList, Map<Id, Device__c> oldMap, Map<Id, Device__c> newMap){
    //     //変更したデータリスト
    //     List<Device__c> dvDataChangedList = new List<Device__c>();
    //     //機器管理費集計対象
    //     Boolean oldDvEquipManageCostTarget;
    //     Boolean newDvEquipManageCostTarget;
    //     //価格改定後の金額
    //     Double newDvPriceSum;
    //     Double oldDvPriceSum;

    //     for(Device__c dv : deviceList){            
    //         oldDvEquipManageCostTarget = oldMap.get(dv.Id).EquipManageCostTarget__c;
    //         oldDvPriceSum = oldMap.get(dv.Id).PriceSum__c;
    //         newDvEquipManageCostTarget = newMap.get(dv.Id).EquipManageCostTarget__c;
    //         newDvPriceSum = newMap.get(dv.Id).PriceSum__c;
    //         if(dv.EquipManageCostTarget__c){
    //             if(oldDvEquipManageCostTarget != newDvEquipManageCostTarget){
    //                 dvDataChangedList.add(dv);
    //             }else{
    //                 if(oldDvPriceSum != newDvPriceSum){
    //                     dvDataChangedList.add(dv);
    //                 }
    //             }
    //         }else{
    //             if(oldDvEquipManageCostTarget != newDvEquipManageCostTarget){
    //                 dvDataChangedList.add(dv);
    //             }
    //         }
    //     }

    //     return dvDataChangedList;
    // }

    // public Map<Id, List<Device__c>> getQuoteIdByDevice(List<Device__c> newList){
    //     Map<Id, List<Device__c>> quoteIdDeviceMap = new Map<Id, List<Device__c>>();
    //     for(Device__c dv : newList){
    //         if(quoteIdDeviceMap.get(dv.Quote__c) == null){
    //             List<Device__c> dvList = new List<Device__c>();
    //             dvList.add(dv);
    //             quoteIdDeviceMap.put(dv.Quote__c, dvList);
    //         }else{
    //             quoteIdDeviceMap.get(dv.Quote__c).add(dv);
    //         }
    //     }

    //     return quoteIdDeviceMap;
    // }

    // private Set<Id>  getQuoteIdsRecTypeOfficialDemand(Set<Id> quoteIds){
    //     Map<Id, Quote__c> quoteMap = new Map<Id, Quote__c>([SELECT Id FROM Quote__c WHERE Id IN: quoteIds AND RecordTypeId =: recTypeOfficialDemandId]);

    //     return quoteMap.keySet();
    // }    

    // private List<Quote__c> getQuotes(Set<id> quoteIds){
    //     return [SELECT Id, (SELECT Id, PriceSum__c FROM Devices__r WHERE EquipManageCostTarget__c =: true)
    //             FROM Quote__c
    //             WHERE Id IN : quoteIds];
    // }
    

    public void cloneDeviceAndRelatedRecords(List<Device__c> newDevices){
        //マスタ機器レコード <マスタ機器のId, 新規機器のId>
        Map<Id, Id> cloneDeviceIdMap = this.getCloneDeviceIds(newDevices);
        //コピーする内訳のリスト
        List<Detail__c> dtlCloneList = new List<Detail__c>();
        
        if(cloneDeviceIdMap.size() > 0){
            //関連内訳を取得する
            Map<Id, Device__c> dvRelated = this.getDetailRelatedRecords(cloneDeviceIdMap.keySet());
            //System.debug('見積項目数' + dvRelated.size());
            //関連内訳を確認する
            for(Id dvId : dvRelated.keySet()){
                //System.debug('明細数' + dvRelated.get(dvId).Details__r.size());
                for(Detail__c dtl : dvRelated.get(dvId).Details__r){
                    //内訳がある場合はコピーする
                    Detail__c dtlClone = dtl.clone(false,true);
                    //内訳の機器Idを設定する
                    dtlClone.Device__c = cloneDeviceIdMap.get(dvId);
                    //内訳を集める
                    dtlCloneList.add(dtlClone);
                }              
            }
            if(dtlCloneList.isEmpty()) return;
            //内訳を登録する
            insert dtlCloneList;
        }
    }
    
    /**
     * マスタ機器のIDを取得
     */
    private Map<Id, Id> getCloneDeviceIds(List<Device__c> newList){        
        Map<Id, Id> idMap = new Map<Id, Id>();        
        for (Device__c d : newList) {
            if(d.isClone()){
                idMap.put(d.getCloneSourceId(), d.Id);
            }
        }
        return idMap;        
    }
    
    /**
     * 関連内訳を取得
     */
    private Map<Id, Device__c> getDetailRelatedRecords(Set<Id> dvIds){
        return new Map<Id, Device__c>((List<Device__c>)Database.query('SELECT Id, (SELECT FIELDS(STANDARD) ' + util.getAllCustomFields('Detail__c') + ' FROM Details__r)' + 
                                                                   'FROM Device__c WHERE Id IN: dvIds ORDER BY QuoteSpecificationNumber__c'));
    }

    /**
     * 全角→半角変換
     *
     * @param value 変換元文字列
     * @return 半角文字列
     */
    public String convertFullToHalf(String value) {

        ReplaceChar reChar = new ReplaceChar();
        return reChar.convertFullToHalf(value);
        // String result;
        // // 変換内容がない場合
        // if(String.isEmpty(value)) {
        //     result = '';
        // }else{
        //     // 半角文字のみなら以降スキップ
        //     if (Pattern.matches('[ -~]+', value)) {
        //         result = value;
        //     }else{
        //         Map<String, String> fulltoHalfMap2 = new Map<String, String>();
        //         fulltoHalfMap2.put( '０',  '0' );
        //         fulltoHalfMap2.put( '１',  '1' );
        //         fulltoHalfMap2.put( '２',  '2' );
        //         fulltoHalfMap2.put( '３',  '3' );
        //         fulltoHalfMap2.put( '４',  '4' );
        //         fulltoHalfMap2.put( '５',  '5' );
        //         fulltoHalfMap2.put( '６',  '6' );
        //         fulltoHalfMap2.put( '７',  '7' );
        //         fulltoHalfMap2.put( '８',  '8' );
        //         fulltoHalfMap2.put( '９',  '9' );
        //         // エスケープ必要文字
        //         Set<String> escapeChars = new Set<String>();
        //         escapeChars.add('\\');
        //         escapeChars.add('*');
        //         escapeChars.add('+');
        //         escapeChars.add('.');
        //         escapeChars.add('?');
        //         escapeChars.add('{');
        //         escapeChars.add('}');
        //         escapeChars.add('(');
        //         escapeChars.add(')');
        //         escapeChars.add('[');
        //         escapeChars.add(']');
        //         escapeChars.add('^');
        //         escapeChars.add('$');
        //         escapeChars.add('|');
        //         escapeChars.add('/');

        //         for (String key : fulltoHalfMap2.keySet()) {
        //             if (value.contains(key)) {
        //                 String tempKey = key;
        //                 if (escapeChars.contains(tempKey)) {
        //                     tempKey = '\\' + tempKey;
        //                 }
        //                 value = value.replaceAll(tempKey, fulltoHalfMap2.get(key));
        //             }
        //         }
        //         String comma_twobyte = '，';//全角カンマ
        //         if(value.contains(comma_twobyte)){
        //             value = value.replaceAll(comma_twobyte, '');
        //         }
        //         result = value;
        //     }
        // }
        // system.debug(result);
        // return result;
    }

    /**
     * 項目番号チェック
     *
     * @param device 登録する機器
     * @return なし
     */
    public void quoteSpecificationNumberCheck(Map<Id,List<Device__c>> quotemap) {
        List<String> deviceIdList = new List<String>();
        List<String> quoteSpecificationNumberList = new List<String>();
        String duplicateNumber = '';
        for(String quoteId : quotemap.keySet()){
            List<Device__c> deviceList = quotemap.get(quoteId);
            for(Device__c device : deviceList){
                deviceIdList.add(device.Id);
                quoteSpecificationNumberList.add(device.QuoteSpecificationNumber__c);
            }
            List<Device__c> duplicateDeviceList = [SELECT Id,QuoteSpecificationNumber__c FROM Device__c WHERE Quote__c = :quoteId AND QuoteSpecificationNumber__c IN :quoteSpecificationNumberList AND Id NOT IN :deviceIdList];
            if(duplicateDeviceList.size() >= 1){
                for(Device__c duplicateDevice : duplicateDeviceList){
                    duplicateNumber += '[';
                    duplicateNumber += duplicateDevice.QuoteSpecificationNumber__c;
                    duplicateNumber += ']';
                }
                Trigger.new.get(0).addError('この見積の中に項目番号が重複する見積項目が存在しています。項目番号：' + duplicateNumber);
            }
        }
    }
}