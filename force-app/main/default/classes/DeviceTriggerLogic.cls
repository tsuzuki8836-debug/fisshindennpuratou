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

    // public void equipManageCostCalculation(List<Device__c> newList, List<Device__c> oldList){
    //     Set<Id> quoteIds = new Set<Id>();
    //     for(Device__c newDev : newList){
    //         quoteIds.add(newDev.Quote__c);
    //     }
    //     for(Device__c oldDev : oldList){
    //         quoteIds.add(oldDev.Quote__c);
    //     }
    //     if(quoteIds.isEmpty()) return;
    //     List<Quote__c> quoteList = getQuotes(quoteIds);
    //     for(Quote__c quote : quoteList){
    //         if(quote.Devices__r.isEmpty()){
    //             //機器管理費
    //             quote.EquipManageCost__c = null;
    //             //機器管理費率
    //             quote.EquipManageCostRate__c = null;
    //         }else{
    //             setQuoteValues(quote,quote.Devices__r);
    //         }
    //     }
    //     update quoteList;
    // }

    // private void setQuoteValues(Quote__c quote, List<Device__c> deviceList){
    //     //支給品・移設品・製作のみ有りフラグ
    //     Boolean suppliesFlag = false;
    //     //見積対象外有りフラグ
    //     Boolean noTargetFlag = false;
    //     //機器単体費
    //     Double sumPriceTarget = Double.valueOf(quote.MachineUnitAmount__c);
    //     System.debug('sumPriceTarget =' + sumPriceTarget);
    //     //機器管理費率計算
    //     Decimal equipManageCostRate = getEquipManageCostRate(sumPriceTarget);
    //     System.debug('補正前equipManageCostRate =' + equipManageCostRate);

    //     for(Device__c d : deviceList){
    //         if(d.EquipManageCostTarget__c == true && (d.QuoteTarget__c == '支給品' || d.QuoteTarget__c == '移設品' || d.QuoteTarget__c == '見積対象(製作のみ)' || d.QuoteTarget__c == '見積対象外(製作のみ)')){
    //             suppliesFlag = true;
    //         }else if(d.EquipManageCostTarget__c == true && d.QuoteTarget__c == '見積対象外'){
    //             noTargetFlag = true;
    //         }
    //     }

    //     //機器管理費設定
    //     if(suppliesFlag == true){
    //         equipManageCostRate = calculateEquipManageCostInSupplies(quote,deviceList,sumPriceTarget,equipManageCostRate);
    //     }else if(noTargetFlag == true){
    //         quote.EquipManageCost__c = calculateEquipManageCostInNoTarget(quote,deviceList,equipManageCostRate);
    //     }else{
    //         quote.EquipManageCost__c = sumPriceTarget * (equipManageCostRate / 100);
    //     }
    //     System.debug('補正後equipManageCostRate =' + equipManageCostRate);

    //     //機器管理費率設定
    //     quote.EquipManageCostRate__c = equipManageCostRate;
    // }

    // /**
    //  * 機器管理費率を取得
    //  */
    // private Decimal getEquipManageCostRate(Double sumPriceTarget){
    //     Decimal equipManageCostRate;
    //     //PRICE_A = 14,000千円  ,  PRICE_B = 200,000千円
    //     if(sumPriceTarget <= PRICE_A){
    //         //機器単体費が 14,000千円以下
    //         equipManageCostRate = 18.22;
    //     }else if(sumPriceTarget>PRICE_A && sumPriceTarget<=PRICE_B){
    //         //EXPONENT = -0.4711
    //         equipManageCostRate = 42380.2 * (Math.pow(sumPriceTarget, EXPONENT));
    //         //小数3位以下を四捨五入
    //         equipManageCostRate = equipManageCostRate.setScale(2,RoundingMode.HALF_UP);
    //     }else{
    //         //機器単体費が200,000千円を越える
    //         equipManageCostRate = 5.21;
    //     }

    //     return equipManageCostRate;
    // }

    // /**
    //  * 支給品・移設品・製作のみを含む機器管理費計算
    //  * @param quote 見積レコード
    //  * @param deviceList 見積に紐づく見積項目のリスト
    //  * @param sumPriceTarget 支給品や移設品、製作のみの価格も含めた金額（見積対象外も含む）
    //  * @param equipManageCostRate 補正前機器管理費率
    //  *
    //  */
    // private Decimal calculateEquipManageCostInSupplies(Quote__c quote, List<Device__c> deviceList, Decimal sumPriceTarget, Decimal equipManageCostRate){
    //     //支給品や移設品、製作のみ(見積対象外も含む)の金額
    //     Decimal suppliesPrice = 0.0;
    //     //支給品や移設品、製作のみ以外の機器単体費（見積対象外も含む）→見積対象と見積対象外の金額
    //     Decimal sumPriceTargetExceptSupplies = 0.0;
    //     //支給品や移設品の価格は含めない金額（見積対象外含まない）→見積対象と見積対象(製作のみ)の金額
    //     Decimal sumPriceTargetExceptSuppliesInProduction = 0.0;
    //     //機器管理費率補正係数
    //     Decimal equipManageCostRateCoefficient;
    //     //補正後機器管理費率
    //     Decimal correctionEquipManageCostRate;
    //     for(Device__c dv : deviceList){
    //         if(dv.MajorClassification__c != 'システムインテグレーション費' && dv.EquipManageCostTarget__c == true){
    //             if(dv.QuoteTarget__c == '支給品' || dv.QuoteTarget__c == '移設品' || dv.QuoteTarget__c == '見積対象(製作のみ)' || dv.QuoteTarget__c == '見積対象外(製作のみ)'){
    //                 suppliesPrice += dv.ClientAnswerAmountTotal__c;
    //                 if(dv.QuoteTarget__c == '見積対象(製作のみ)'){
    //                     sumPriceTargetExceptSuppliesInProduction += dv.ClientAnswerAmountTotal__c;
    //                 }
    //             }else if(dv.QuoteTarget__c == '見積対象' || dv.QuoteTarget__c == '見積対象外'){
    //                 sumPriceTargetExceptSupplies += dv.ClientAnswerAmountTotal__c;
    //                 if(dv.QuoteTarget__c == '見積対象'){
    //                     sumPriceTargetExceptSuppliesInProduction += dv.ClientAnswerAmountTotal__c;
    //                 }
    //             }
    //         }
    //     }
    //     //機器管理費率補正係数算出
    //     equipManageCostRateCoefficient = (sumPriceTargetExceptSupplies + (suppliesPrice * 0.5)) / sumPriceTarget;
    //     //小数3位以下を四捨五入
    //     equipManageCostRateCoefficient = equipManageCostRateCoefficient.setScale(2,RoundingMode.HALF_UP);

    //     //補正後機器管理費率算出
    //     correctionEquipManageCostRate = equipManageCostRate * equipManageCostRateCoefficient;
    //     //小数3位以下を四捨五入
    //     correctionEquipManageCostRate = correctionEquipManageCostRate.setScale(2,RoundingMode.HALF_UP);

    //     //機器管理費算出
    //     quote.EquipManageCost__c = sumPriceTargetExceptSuppliesInProduction * (correctionEquipManageCostRate / 100);

    //     //各種工事区分の値を設定
    //     quote.suppliesMachineUnitAmount__c = suppliesPrice;
    //     quote.removeSuppliesMachineUnitAmount__c = sumPriceTargetExceptSupplies;
    //     quote.Target_MachineUnitAmount__c = sumPriceTargetExceptSuppliesInProduction;
    //     quote.temEquipManageCostRate__c = equipManageCostRate;
    //     quote.equipManageCostRateCoefficient__c = equipManageCostRateCoefficient;

    //     return correctionEquipManageCostRate;
    // }

    // /**
    //  * 見積対象外を含む機器管理費計算
    //  * @param quote 見積レコード
    //  * @param deviceList 見積に紐づく見積項目のリスト
    //  * @param equipManageCostRate 機器管理費率
    //  *
    //  */
    // private Double calculateEquipManageCostInNoTarget(Quote__c quote, List<Device__c> deviceList, Decimal equipManageCostRate){
    //     //見積対象の機器単体費
    //     Decimal quoteTargetPrice = 0.0;
    //     //再計算後の機器管理費
    //     Decimal correctionEquipManageCost = 0.0;

    //     for(Device__c dv : deviceList){
    //         if(dv.QuoteTarget__c == '見積対象' && dv.MajorClassification__c != 'システムインテグレーション費' && dv.EquipManageCostTarget__c == true){
    //             quoteTargetPrice += dv.ClientAnswerAmountTotal__c;
    //         }
    //     }

    //     //機器管理費再計算
    //     correctionEquipManageCost = quoteTargetPrice * (equipManageCostRate / 100);
    //     //各種工事区分の値を設定
    //     quote.Target_MachineUnitAmount__c = quoteTargetPrice;

    //     return correctionEquipManageCost;
    // }

    // private List<Quote__c> getQuotes(Set<id> quoteIds){
    //     return [SELECT Id, MachineUnitAmount__c,(SELECT Id, QuoteTarget__c, ClientAnswerAmountTotal__c, MajorClassification__c, EquipManageCostTarget__c FROM Devices__r WHERE EquipManageCostTarget__c =: true AND MajorClassification__c != 'システムインテグレーション費')
    //             FROM Quote__c
    //             WHERE Id IN : quoteIds AND RecordTypeId =: recTypeOfficialDemandId AND EquipmentCostExistence__c = 'あり' AND SectionExistence__c = 'なし'];
    // }


    public void cloneDeviceAndRelatedRecords(List<Device__c> newDevices){
        //マスタ機器レコード <マスタ機器のId, 新規機器のId>
        Map<Id, Set<Id>> cloneDeviceIdMap = this.getCloneDeviceIds(newDevices);
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
                    for(Id dId : cloneDeviceIdMap.get(dvId)){
                        //内訳がある場合はコピーする
                        Detail__c dtlClone = dtl.clone(false,true);
                        //内訳の機器Idを設定する
                        dtlClone.Device__c = dId;
                        //内訳を集める
                        dtlCloneList.add(dtlClone);
                    }
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
    private Map<Id, Set<Id>> getCloneDeviceIds(List<Device__c> newList){
        Map<Id, Set<Id>> idMap = new Map<Id, Set<Id>>();
        for (Device__c d : newList) {
            if(d.isClone()){
                // 同じ見積項目の複数回コピーに対応（2023/12/20 TS鈴木）Start
                if(idMap.get(d.getCloneSourceId()) != null && !idMap.get(d.getCloneSourceId()).isEmpty()){
                    Set<Id> idSet = idMap.get(d.getCloneSourceId());
                    idSet.add(d.Id);
                    idMap.put(d.getCloneSourceId(), idSet);
                }else{
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(d.Id);
                    idMap.put(d.getCloneSourceId(), idSet);
                }
                // 同じ見積項目の複数回コピーに対応（2023/12/20 TS鈴木）End
                //idMap.put(d.getCloneSourceId(), idMap.get(d.getCloneSourceId()).add(d.Id));
            }
        }
        return idMap;
    }

    public void updateConstructionZone(List<Device__c> newDevices,List<Device__c> oldDevices){
        Set<Id> constructionZoneIds = new Set<id>();
        Set<Id> deviceIds = new Set<Id>();
        for(Device__c d : newDevices){
            deviceIds.add(d.Id);
        }
        for(Device__c d : oldDevices){
            deviceIds.add(d.Id);
            // 変更前の工事区分のIDを入れておく
            constructionZoneIds.add(d.ConstructionZone__c);
        }
        List<Device__c> deviceList = new List<Device__c>([
            SELECT Id, ConstructionZone__c, Device_SmallCategory__c
                , Device_SmallCategory__r.Device_MiddleCategory__r.Device_LargeCategory__r.ConstructionZone__r.Id
            FROM Device__c
            WHERE Id IN: deviceIds]);
        for(Device__c getDevice : deviceList){
            //細別から辿った工事区分のIDを追加
            constructionZoneIds.add(getDevice.Device_SmallCategory__r.Device_MiddleCategory__r.Device_LargeCategory__r.ConstructionZone__r.Id);
            //システムインテグレーション用に見積項目の工事区分のIDを追加
            constructionZoneIds.add(getDevice.ConstructionZone__c);
        }
        List<ConstructionZone__c> conZoneList = [SELECT Id FROM ConstructionZone__c WHERE Id IN : constructionZoneIds];
        if(conZoneList.size() != 0 && conZoneList != null){
            update conZoneList;
        }
    }

    /**
     * 関連内訳を取得
     */
    private Map<Id, Device__c> getDetailRelatedRecords(Set<Id> dvIds){
        return new Map<Id, Device__c>((List<Device__c>)Database.query(
            'SELECT Id, (SELECT FIELDS(STANDARD) ' + util.getAllCustomFields('Detail__c') + ' FROM Details__r)' +
            'FROM Device__c WHERE Id IN: dvIds ORDER BY QuoteSpecificationNumber__c'));
    }

    /**
     * 全角→半角変換
     *
     * @param value 変換元文字列
     * @return 半角文字列
     */
    public String convertFullToHalf(String value) {

        return ReplaceChar.convertFullToHalf(value);
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

    /**
     * 工区自動入力
     *
     * @param device 登録する機器
     * @return なし
     */
    public void deviceConstructionZoneSetting(List<Device__c> devices) {
        // Set<Id> deviceIds = new Set<Id>();
        // for(Device__c d : devices){
        //     deviceIds.add(d.Id);
        // }
        //Map<Id, Device__c> deviceMap = new Map<Id, Device__c>([SELECT Id,ConstructionZoneId__c,Device_SmallCategory__c,Device_SmallCategory__r.Device_MiddleCategory__r.Device_LargeCategory__r.ConstructionZone__r.Id FROM Device__c WHERE Id IN: deviceIds]);

        for(Device__c d : devices){
            if(d.Device_SmallCategory__c != null){
                d.ConstructionZone__c = d.ConstructionZoneId__c;
            }else if(d.Device_SmallCategory__c == null && d.MajorClassification__c != 'システムインテグレーション費'){
                d.ConstructionZone__c = null;
            }
        }
    }

    /**
     * 一般管理費率、工区有無、機器管理費有無更新
     *
     * @param device 登録する機器
     * @return なし
     */
    public void updateFieldFromQuoteValues(List<Device__c> devices) {
        Set<Id> deviceIds = new Set<Id>();
        for(Device__c d : devices){
            deviceIds.add(d.Id);
        }
        Map<Id, Device__c> reGetDeviceMap = new Map<Id, Device__c>([SELECT Id,Quote__r.GeneralAdministrativeExpensesPercent__c,Quote__r.EquipmentCostExistence__c,Quote__r.SectionExistence__c FROM Device__c WHERE Id IN :deviceIds]);
        for(Device__c d : devices){
            d.GeneralAdministrativeExpensesCopy__c = reGetDeviceMap.get(d.Id).Quote__r.GeneralAdministrativeExpensesPercent__c;
            d.EquipmentCostExistence__c = reGetDeviceMap.get(d.Id).Quote__r.EquipmentCostExistence__c;
            d.SectionExistence__c = reGetDeviceMap.get(d.Id).Quote__r.SectionExistence__c;
        }
    }

    /**
     * 工区有無、機器管理費有無、規格名更新
     *
     * @param device 登録する機器
     * @return なし
     */
    public void updateOfficialDemandField(List<Device__c> devices) {
        for(Device__c d : devices){
            // 見積項目名と規格名を同名とするチェックボックスがtrueかつ見積レコードタイプが「官需」の場合、見積項目名を規格名に転記
            if(d.DeviceNameEqualSpecificationName__c == true && d.RecordTypeOfQuote__c == '官需'){
                d.SpecificationName__c = d.Name;
            }
        }
    }
}