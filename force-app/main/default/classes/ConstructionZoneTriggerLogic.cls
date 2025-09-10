public class ConstructionZoneTriggerLogic {
    //べき乗計算
    @testvisible private static final Double EXPONENT = -0.4711;
    //14,000千円
    @testvisible private static final Integer PRICE_A = 14000*1000;
    //200,000千円
    @testvisible private static final Integer PRICE_B = 200000*1000;

    public void equipManageCostCalculation(List<ConstructionZone__c> constructionZoneList){
        Set<Id> conIds = new Set<Id>();
        for(ConstructionZone__c con : constructionZoneList){
            conIds.add(con.Id);
        }
        if(conIds.isEmpty()) return;
        
        Map<Id,ConstructionZone__c> getConMap = getConChildDevices(conIds);
        for(ConstructionZone__c con : constructionZoneList){
            if(getConMap.get(con.Id).Devices__r.isEmpty()){
                //機器単体費
                con.MachineUnitAmount__c = null;
                //機器管理費
                con.MachineControlAmount__c = null;
                //機器管理費率
                con.MachineControlRate__c = null;
                //システムインテグレーション費合計
                con.SystemIntegrationFee__c = null;
            }else{
                setConstructionZoneValues(con,getConMap.get(con.Id).Devices__r);
            }
        }
    }

    private void setConstructionZoneValues(ConstructionZone__c con, List<Device__c> deviceList){
        //支給品・移設品・製作のみ有りフラグ
        Boolean suppliesFlag = false;
        //見積対象外有りフラグ
        Boolean noTargetFlag = false;
        //機器単体費計算
        Double sumPriceTarget = getSumPriceTarget(deviceList);
        //機器管理費率計算
        Decimal equipManageCostRate = getEquipManageCostRate(sumPriceTarget);
        //システムインテグレーション費合計
        Decimal systemIntegrationTotalPrice = 0;
        //機器単体費(見積対象分のみ)
        Decimal machineUnitAmountOnlyTarget = 0;
        //上記以外の金額合計→「機器単体費(見積対象分のみ)」に含まれないかつシステムインテグレーション費や材料費で無いもの
        Decimal machineUnitAmountExceptTarget = 0;
        //機器単体費対象外合計
        Decimal machineUnitAmount_ExceptSum = 0;

        for(Device__c d : deviceList){
            if(d.EquipManageCostTarget__c == true && d.MajorClassification__c != 'システムインテグレーション費' && (d.QuoteTarget__c == '支給品' || d.QuoteTarget__c == '移設品' || d.QuoteTarget__c == '見積対象(製作のみ)' || d.QuoteTarget__c == '見積対象外(製作のみ)')){
                suppliesFlag = true;
            }else if(d.EquipManageCostTarget__c == true && d.MajorClassification__c != 'システムインテグレーション費' && d.QuoteTarget__c == '見積対象外'){
                noTargetFlag = true;
            }
            //システムインテグレーション費合計加算
            if(d.MajorClassification__c == 'システムインテグレーション費'){
                systemIntegrationTotalPrice += d.ClientAnswerAmountTotalTimesDSCQuantity__c;
            }
            //機器単体費(見積対象分のみ)加算
            if((d.QuoteTarget__c == '見積対象' || d.QuoteTarget__c == '見積対象(製作のみ)') 
                && d.EquipManageCostTarget__c == true && d.MajorClassification__c != 'システムインテグレーション費' && d.MajorClassification__c != '材料' && d.MajorClassification__c != '工事'){
                machineUnitAmountOnlyTarget += d.ClientAnswerAmountTotalTimesDSCQuantity__c;
            }
            //上記以外の金額合計→「機器単体費(見積対象分のみ)」に含まれないかつシステムインテグレーション費や材料費で無いもの
            if(d.MajorClassification__c != '材料' && d.MajorClassification__c != '工事' && d.MajorClassification__c != 'システムインテグレーション費' &&
                ((d.QuoteTarget__c != '見積対象' && d.QuoteTarget__c != '見積対象(製作のみ)' && d.EquipManageCostTarget__c == true) 
                || d.EquipManageCostTarget__c == false)){
                machineUnitAmountExceptTarget += d.ClientAnswerAmountTotalTimesDSCQuantity__c;
            }
            //機器単体費対象外合計
            if(d.MajorClassification__c != '材料' && d.MajorClassification__c != '工事' && d.MajorClassification__c != 'システムインテグレーション費' &&
                d.EquipManageCostTarget__c == false && (d.QuoteTarget__c == '見積対象' || d.QuoteTarget__c == '見積対象(製作のみ)')){
                machineUnitAmount_ExceptSum += d.ClientAnswerAmountTotalTimesDSCQuantity__c;
            }
        }

        //機器単体費設定
        con.MachineUnitAmount__c = sumPriceTarget;
        //システムインテグレーション費合計設定
        con.SystemIntegrationFee__c = systemIntegrationTotalPrice;
        //機器単体費(見積対象分のみ)設定
        con.MachineUnitAmount_OnlyTarget__c = machineUnitAmountOnlyTarget;
        //上記以外の金額合計設定
        con.MachineUnitAmountExceptTarget__c = machineUnitAmountExceptTarget;
        //上記以外の金額合計設定
        con.MachineUnitAmount_ExceptSum__c = machineUnitAmount_ExceptSum;
        
        //機器管理費設定
        if(suppliesFlag == true && sumPriceTarget > 0){
            equipManageCostRate = calculateEquipManageCostInSupplies(con,deviceList,sumPriceTarget,equipManageCostRate);
        }else if(noTargetFlag == true && sumPriceTarget > 0){
            con.MachineControlAmount__c = calculateEquipManageCostInNoTarget(con,deviceList,equipManageCostRate);
        }else{
            con.MachineControlAmount__c = sumPriceTarget * (equipManageCostRate / 100);
        }
        
        //機器管理費率設定
        con.MachineControlRate__c = equipManageCostRate;
    }
    

    /**
     * 機器単体費を取得
     */
    private Double getSumPriceTarget(List<Device__c> deviceList){
        Double sumPriceTarget = 0.0;
        for(Device__c dv : deviceList){
            if(dv.MajorClassification__c != 'システムインテグレーション費' && dv.EquipManageCostTarget__c == true){
                sumPriceTarget += dv.ClientAnswerAmountTotalTimesDSCQuantity__c;
            }
        }

        return sumPriceTarget;
    }
    

    /**
     * 機器管理費率を取得
     */
    private Decimal getEquipManageCostRate(Double sumPriceTarget){
        Decimal equipManageCostRate;
        //PRICE_A = 14,000千円  ,  PRICE_B = 200,000千円
        if(sumPriceTarget <= PRICE_A){
            //機器単体費が 14,000千円以下
            equipManageCostRate = 18.22;            
        }else if(sumPriceTarget>PRICE_A && sumPriceTarget<=PRICE_B){
            //EXPONENT = -0.4711
            equipManageCostRate = 42380.2 * (Math.pow(sumPriceTarget, EXPONENT));
            //小数3位以下を四捨五入
            equipManageCostRate = equipManageCostRate.setScale(2,RoundingMode.HALF_UP);
        }else{
            //機器単体費が200,000千円を越える
            equipManageCostRate = 5.21;
        }

        return equipManageCostRate;
    }

    /**
     * 支給品・移設品・製作のみを含む機器管理費計算
     * @param con 工事区分レコード
     * @param deviceList 工事区分に紐づく見積項目のリスト
     * @param sumPriceTarget 支給品や移設品、製作のみの価格も含めた金額（見積対象外も含む）
     * @param equipManageCostRate 補正前機器管理費率
     * 
     */
    private Decimal calculateEquipManageCostInSupplies(ConstructionZone__c con, List<Device__c> deviceList, Decimal sumPriceTarget, Decimal equipManageCostRate){
        //支給品や移設品、製作のみ(見積対象外も含む)の金額
        Decimal suppliesPrice = 0.0;
        //支給品や移設品、製作のみ以外の機器単体費（見積対象外も含む）→見積対象と見積対象外の金額
        Decimal sumPriceTargetExceptSupplies = 0.0;
        //支給品や移設品の価格は含めない金額（見積対象外含まない）→見積対象と見積対象(製作のみ)の金額
        Decimal sumPriceTargetExceptSuppliesInProduction = 0.0;
        //機器管理費率補正係数
        Decimal equipManageCostRateCoefficient;
        //補正後機器管理費率
        Decimal correctionEquipManageCostRate;
        for(Device__c dv : deviceList){
            if(dv.MajorClassification__c != 'システムインテグレーション費' && dv.EquipManageCostTarget__c == true){
                if(dv.QuoteTarget__c == '支給品' || dv.QuoteTarget__c == '移設品' || dv.QuoteTarget__c == '見積対象(製作のみ)' || dv.QuoteTarget__c == '見積対象外(製作のみ)'){
                    suppliesPrice += dv.ClientAnswerAmountTotalTimesDSCQuantity__c;
                    if(dv.QuoteTarget__c == '見積対象(製作のみ)'){
                        sumPriceTargetExceptSuppliesInProduction += dv.ClientAnswerAmountTotalTimesDSCQuantity__c;
                    }
                }else if(dv.QuoteTarget__c == '見積対象' || dv.QuoteTarget__c == '見積対象外'){
                    sumPriceTargetExceptSupplies += dv.ClientAnswerAmountTotalTimesDSCQuantity__c;
                    if(dv.QuoteTarget__c == '見積対象'){
                        sumPriceTargetExceptSuppliesInProduction += dv.ClientAnswerAmountTotalTimesDSCQuantity__c;
                    }
                }
            }
        }
        //機器管理費率補正係数算出
        equipManageCostRateCoefficient = (sumPriceTargetExceptSupplies + (suppliesPrice * 0.5)) / sumPriceTarget;
        //小数3位以下を四捨五入
        equipManageCostRateCoefficient = equipManageCostRateCoefficient.setScale(2,RoundingMode.HALF_UP);

        //補正後機器管理費率算出
        correctionEquipManageCostRate = equipManageCostRate * equipManageCostRateCoefficient;
        //小数3位以下を四捨五入
        correctionEquipManageCostRate = correctionEquipManageCostRate.setScale(2,RoundingMode.HALF_UP);

        //機器管理費算出
        con.MachineControlAmount__c = sumPriceTargetExceptSuppliesInProduction * (correctionEquipManageCostRate / 100);

        //各種工事区分の値を設定
        con.Device_SuppliesMachineUnitAmount__c = suppliesPrice;
        con.removeSuppliesMachineUnitAmount__c = sumPriceTargetExceptSupplies;
        con.Target_Device_MachineUnitAmount__c = sumPriceTargetExceptSuppliesInProduction;
        con.equipManageCostRate__c = equipManageCostRate;
        con.equipManageCostRateCoefficient__c = equipManageCostRateCoefficient;

        return correctionEquipManageCostRate;
    }

    /**
     * 見積対象外を含む機器管理費計算
     * @param con 工事区分レコード
     * @param deviceList 工事区分に紐づく見積項目のリスト
     * @param equipManageCostRate 機器管理費率
     * 
     */
    private Double calculateEquipManageCostInNoTarget(ConstructionZone__c con, List<Device__c> deviceList, Decimal equipManageCostRate){
        //見積対象の機器単体費
        Decimal quoteTargetPrice = 0.0;
        //再計算後の機器管理費
        Decimal correctionEquipManageCost = 0.0;
        
        for(Device__c dv : deviceList){
            if(dv.QuoteTarget__c == '見積対象' && dv.MajorClassification__c != 'システムインテグレーション費' && dv.EquipManageCostTarget__c == true){
                quoteTargetPrice += dv.ClientAnswerAmountTotalTimesDSCQuantity__c;
            }
        }
        
        //機器管理費再計算
        correctionEquipManageCost = quoteTargetPrice * (equipManageCostRate / 100);
        //各種工事区分の値を設定
        con.Target_Device_MachineUnitAmount__c = quoteTargetPrice;

        return correctionEquipManageCost;
    }    

    private Map<Id,ConstructionZone__c> getConChildDevices(Set<id> conIds){
        Map<Id, ConstructionZone__c> getConMap = new Map<Id, ConstructionZone__c>([SELECT Id, (SELECT Id, QuoteTarget__c, ClientAnswerAmountTotalTimesDSCQuantity__c, MajorClassification__c, EquipManageCostTarget__c FROM Devices__r)
                FROM ConstructionZone__c
                WHERE Id IN : conIds]);
        return getConMap;
    }
}