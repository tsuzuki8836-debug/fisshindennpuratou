/**
 * 場所別トリガーロジック
 * 
 * 2020/03/11　修正：IDのリストでContains関数が正しく機能しないバグのため、Mapに置き換え
 */
public class FactoryTriggerLogic {
    
    //-- 2021.06.25 コスト構造対応 DEL Start    
    // //集計先オブジェクト名(親)
    // private String pObjectName  = 'Opportunity';
    // //集計先項目名
    // private String pItemName1   = 'TotalCP__c';
    // private String pItemName2   = 'TotalWC__c';
    // private String pItemName3   = 'TC__c';
    
    // private String pItemName4   = 'Order_TotalCP__c';
    // private String pItemName5   = 'Order_TotalWC__c';
    // private String pItemName6   = 'Order_TC__c';
    
    // private String pItemName7   = 'Order_Forecast_TotalCP__c';
    // private String pItemName8   = 'Order_Forecast_TotalWC__c';
    // private String pItemName9   = 'Order_Forecast_TC__c';
    
    // private String pItemName10   = 'Latest_TotalCP__c';
    // private String pItemName11   = 'Latest_TotalWC__c';
    // private String pItemName12   = 'Latest_TC__c';
    
    // private String pItemName13   = 'Latest_Forecast_TotalCP__c';
    // private String pItemName14   = 'Latest_Forecast_TotalWC__c';
    // private String pItemName15   = 'Latest_Forecast_TC__c'; 
        
    // private String pItemName16   = 'Result_TotalCP__c';
    // private String pItemName17   = 'Result_TotalWC__c';
    // private String pItemName18   = 'Result_TC__c';    
    // private String pItemName19   = 'Result_Difference__c';
    // private String pItemName20   = 'Result_AdditionalCost__c';
    
    // //集計元オブジェクト名(子)
    // private String cObjectName  = 'Factory__c';
    // //集計元項目名
    // private String cItemName1    = 'SR_CP__c';
    // private String cItemName2    = 'SRWC__c';
    // private String cItemName3    = 'TC__c';
    
    // private String cItemName4    = 'Order_SR_CP__c';
    // private String cItemName5    = 'Order_SRWC__c';
    // private String cItemName6    = 'Order_TC__c';
    
    // private String cItemName7    = 'Order_Forecast_SR_CP__c';
    // private String cItemName8    = 'Order_Forecast_SRWC__c';
    // private String cItemName9    = 'Order_Forecast_TC__c';
    
    // private String cItemName10   = 'Latest_SR_CP__c';
    // private String cItemName11   = 'Latest_SRWC__c';
    // private String cItemName12   = 'Latest_TC__c';
    
    // private String cItemName13   = 'Latest_Forecast_SR_CP__c';
    // private String cItemName14   = 'Latest_Forecast_SRWC__c';
    // private String cItemName15   = 'Latest_Forecast_TC__c';
    
    // private String cItemName16   = 'Result_SR_CP__c';
    // private String cItemName17   = 'Result_SRWC__c';
    // private String cItemName18   = 'Result_TC__c';
    // private String cItemName19   = 'Result_Difference__c';
    // private String cItemName20   = 'Result_AdditionalCost__c';
    // //20201104 削除フラグ追加
    // private String facDeleteFlag   = 'DeleteFlag__c';
    // private String customFilter = null;              //where条件
    //-- 2021.06.25 コスト構造対応 DEL End

    private String RelationName = 'Opp1__c';        //子から親への参照関係項目名
    // private List<Id> CalculateParentIdList;         //集計対象レコードの親IDを格納
    private Map<Id,Boolean> CalculateParentIdMap;   //集計対象レコードの親IDを格納

    private static final String STAGE_ORDER = '受注・オーダー管理';
    private static final String STAGE_ORDER_COMPLETED = 'オーダー完了';
    private static final String UPD_ERROR_MESSAGE = '案件を更新できませんでした。案件の入力規則エラーが起きていないか確認してください。';

    // 再帰呼び出し制御
    private static Map<String, Boolean> isRecursiveMap = new Map<String, Boolean>();
    private static final String MODE_BEFORE_INSERT = 'before_insert';
    private static final String MODE_BEFORE_UPDATE = 'before_update';
    private static final String STAGE_DELETE = '削除';
    private static final String STAGE_FAILED = '失注';

    // 再起呼び出し制御マップ作製
    public static void setIsRecursive(String mode){
        isRecursiveMap.put(mode, true);
    }

    // // 再起呼び出し制御判定
    public static Boolean isRecursive(String mode){
        return isRecursiveMap.containsKey(mode);
    }

    public FactoryTriggerLogic() {
        // CalculateParentIdList = new List<Id>();
        CalculateParentIdMap = new Map<Id,Boolean>();
    }

    public void beforeInsert(List<Factory__c> newlist){
        if(!isRecursive(MODE_BEFORE_INSERT)){
            setCommonRatioCal(newlist, null);
            // 案件更新日時を設定（プロセスビルダーの処理を移行）
            updateLastModifiedDateTimeInOpp(null, newList, false);
        }
        setIsRecursive(MODE_BEFORE_INSERT);
    }

    public void beforeUpdate(List<Factory__c> newList, Map<Id, SObject> oldMap){
        if(!isRecursive(MODE_BEFORE_UPDATE)){
            setCommonRatioCal(newlist, oldMap);
            // 案件更新日時を設定（プロセスビルダーの処理を移行）
            updateLastModifiedDateTimeInOpp(oldMap, newList, true);
        }
        setIsRecursive(MODE_BEFORE_UPDATE);
    }

    /**
     * insertレコードから親レコードのIDを取得
     */
    public void sumInsert(Map<Id, sObject> newMap) {
        createCalcuParentIdMap(newMap);
/*
        for (Id recId : newMap.keySet()) {
            sObject newRec = newMap.get(recId);
            Id parentRecordId = (Id)newRec.getPopulatedFieldsAsMap().get(RelationName);
            addNCR(parentRecordId);
        }
*/
    }

    /**
     * updateレコードから親レコードのIDを取得
     */
    public void sumUpdate(Map<Id, sObject> newMap, Map<Id, SObject> oldMap) {
        createCalcuParentIdMap(newMap);
// 20210512 共通費率対応
/*
        for (Id recId : newMap.keySet()) {
            sObject newRec = newMap.get(recId);
            sObject oldRec = oldMap.get(recId);
            
            Id newParentRecordId = (Id)newRec.getPopulatedFieldsAsMap().get(RelationName);
            Id oldParentRecordId = (Id)oldRec.getPopulatedFieldsAsMap().get(RelationName);
            
            Decimal newcItemName1 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName1);
            Decimal oldcItemName1 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName1);
            
            Decimal newcItemName2 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName2);
            Decimal oldcItemName2 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName2);
            
            Decimal newcItemName3 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName3);
            Decimal oldcItemName3 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName3);
            
            Decimal newcItemName4 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName4);
            Decimal oldcItemName4 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName4);
            
            Decimal newcItemName5 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName5);
            Decimal oldcItemName5 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName5);
            
            Decimal newcItemName6 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName6);
            Decimal oldcItemName6 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName6);
            
            Decimal newcItemName7 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName7);
            Decimal oldcItemName7 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName7);
            
            Decimal newcItemName8 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName8);
            Decimal oldcItemName8 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName8);
            
            Decimal newcItemName9 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName9);
            Decimal oldcItemName9 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName9);
            
            Decimal newcItemName10 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName10);
            Decimal oldcItemName10 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName10);
            
            Decimal newcItemName11 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName11);
            Decimal oldcItemName11 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName11);
            
            Decimal newcItemName12 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName12);
            Decimal oldcItemName12 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName12);
            
            Decimal newcItemName13 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName13);
            Decimal oldcItemName13 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName13);
            
            Decimal newcItemName14 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName14);
            Decimal oldcItemName14 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName14);
            
            Decimal newcItemName15 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName15);
            Decimal oldcItemName15 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName15);
            
            Decimal newcItemName16 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName16);
            Decimal oldcItemName16 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName16);
            
            Decimal newcItemName17 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName17);
            Decimal oldcItemName17 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName17);
            
            Decimal newcItemName18 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName18);
            Decimal oldcItemName18 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName18);

            Decimal newcItemName19 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName19);
            Decimal oldcItemName19 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName19);

            Decimal newcItemName20 = (Decimal)newRec.getPopulatedFieldsAsMap().get(cItemName20);
            Decimal oldcItemName20 = (Decimal)oldRec.getPopulatedFieldsAsMap().get(cItemName20);
            //20201104 削除フラグ追加
            Boolean newcItemName21 = (Boolean)newRec.getPopulatedFieldsAsMap().get(facDeleteFlag);
            Boolean oldcItemName21 = (Boolean)oldRec.getPopulatedFieldsAsMap().get(facDeleteFlag);
            
            if (newParentRecordId != oldParentRecordId) {
                // 親レコードが変わった場合
                addNCR(newParentRecordId);
                addNCR(oldParentRecordId);
            } else if (newcItemName1  != oldcItemName1  || 
                       newcItemName2  != oldcItemName2  || 
                       newcItemName3  != oldcItemName3  ||  
                       newcItemName4  != oldcItemName4  ||  
                       newcItemName5  != oldcItemName5  ||  
                       newcItemName6  != oldcItemName6  ||  
                       newcItemName7  != oldcItemName7  ||  
                       newcItemName8  != oldcItemName8  ||  
                       newcItemName9  != oldcItemName9  ||  
                       newcItemName10 != oldcItemName10 ||  
                       newcItemName11 != oldcItemName11 ||  
                       newcItemName12 != oldcItemName12 ||  
                       newcItemName13 != oldcItemName13 ||  
                       newcItemName14 != oldcItemName14 ||  
                       newcItemName15 != oldcItemName15 ||  
                       newcItemName16 != oldcItemName16 ||  
                       newcItemName17 != oldcItemName17 ||  
                       newcItemName18 != oldcItemName18 ||  
                       newcItemName19 != oldcItemName19 ||  
                       newcItemName20 != oldcItemName20 || //){
                       newcItemName21 != oldcItemName21 )
                       { 
                // 親レコードが同じで金額が変更された場合
                addNCR(newParentRecordId);
            }
        }
*/
    }

    /**
     * 親レコードのIDを取得して更新対象の親レコードIDリストを作成する
     */
    private void createCalcuParentIdMap(Map<Id, sObject> newMap){
        for (Id recId : newMap.keySet()) {
            sObject newRec = newMap.get(recId);
            Id parentRecordId = (Id)newRec.getPopulatedFieldsAsMap().get(RelationName);
            addNCR(parentRecordId);
        }
    }

    /**
     * 共通費率（計算用）CommonRatioCalc__c に共通費率の％数値を転記する
     */
    private void setCommonRatioCal(List<Factory__c> newList, Map<Id, sObject> oldMap){
        
        Map<Id, Opportunity> facIdOppMap = getOpptunityMap(newList);

        // beforeInsert時
        if (oldMap == null) {
            for (Factory__c fac : newList) {
                // 共通費率（計算用）がnull、かつ 案件.フェーズが「受注・オーダー管理」以外、かつ 「オーダー完了」以外のとき                
                if (fac.CommonRatioCalc__c == null 
                    && !facIdOppMap.get(fac.Opp1__c).StageName.equals(STAGE_ORDER) 
                    && !facIdOppMap.get(fac.Opp1__c).StageName.equals(STAGE_ORDER_COMPLETED)) {
                    fac.CommonRatioCalc__c = Decimal.valueOf(fac.CommonRatio1__c.substringBefore('%'));
                }
            }
        // beforeUpdate時
        } else {
            for (Factory__c fac : newList) {
                Factory__c oldFac = (Factory__c)oldMap.get(fac.Id);
                // 共通費率が変更されている、かつ 共通費率（計算用）がnull、かつ 案件.フェーズが「受注・オーダー管理」以外、かつ「オーダー完了」以外のとき
                if (!facIdOppMap.get(fac.Opp1__c).StageName.equals(STAGE_ORDER) 
                    && !facIdOppMap.get(fac.Opp1__c).StageName.equals(STAGE_ORDER_COMPLETED) 
                    && (fac.CommonRatio1__c != oldFac.CommonRatio1__c || fac.CommonRatioCalc__c == null)) {
                    fac.CommonRatioCalc__c = Decimal.valueOf(fac.CommonRatio1__c.substringBefore('%'));
                }
            }
        }
    }

    /**
     * deleteレコードから親レコードのIDを取得
     */
    public void sumDelete(Map<Id, SObject> oldMap) {
        sumInsert(oldMap);
    }

    /**
     * 更新対象の親レコードIDリストの作成
     */
    private void addNCR(Id addId) {
        if (addId != null) {
            // if (!CalculateParentIdList.contains(addId)) {
            //     CalculateParentIdList.add(addId);
            if (!CalculateParentIdMap.containsKey(addId)) {
                CalculateParentIdMap.put(addId,True);
            }
        }
    }

    /**
     * 集計対象レコードの有無を判断
     */
    public boolean isNeedUpdate() {
        // return (!CalculateParentIdList.isEmpty());
        return (!CalculateParentIdMap.isEmpty());
    }

    /**
     * 集計処理
     */
    public void execCalculation(List<Factory__c> newList) {
        if (isNeedUpdate()) {
            List<Opportunity> targetOppList = [SELECT Id FROM Opportunity WHERE Id IN : CalculateParentIdMap.keySet()];

            try {
                if (!targetOppList.isEmpty()) {
                    update targetOppList;
                }
            }  catch (Exception e) {
                newList[0].addError(UPD_ERROR_MESSAGE + '【エラー詳細】' + e.getMessage());
            }
        }
    }
// 20210512 共通費率対応
/*
            List<Id> PIdList = new List<Id>();
            for (Id tmpid : CalculateParentIdMap.keySet())
            {
                PIdList.add(tmpid);
            }
            
            //List<sObject> dmlBuffer = new List<sObject>();
            //List<Id> procRecords = new List<Id>();
            Map<String, sObject> dmlBuffer = new Map<String, sObject>();
            Set<String> procRecords = new Set<String>();
          
            string sumQuery =
              'SELECT ' + RelationName + ' ';
            if (pItemName1 != null)  sumQuery += ', SUM(' + cItemName1  + ') SumValue1 ';
            if (pItemName2 != null)  sumQuery += ', SUM(' + cItemName2  + ') SumValue2 ';
            if (pItemName3 != null)  sumQuery += ', SUM(' + cItemName3  + ') SumValue3 ';
            if (pItemName4 != null)  sumQuery += ', SUM(' + cItemName4  + ') SumValue4 ';
            if (pItemName5 != null)  sumQuery += ', SUM(' + cItemName5  + ') SumValue5 ';
            if (pItemName6 != null)  sumQuery += ', SUM(' + cItemName6  + ') SumValue6 ';
            if (pItemName7 != null)  sumQuery += ', SUM(' + cItemName7  + ') SumValue7 ';
            if (pItemName8 != null)  sumQuery += ', SUM(' + cItemName8  + ') SumValue8 ';
            if (pItemName9 != null)  sumQuery += ', SUM(' + cItemName9  + ') SumValue9 ';
            if (pItemName10 != null) sumQuery += ', SUM(' + cItemName10 + ') SumValue10 ';
            if (pItemName11 != null) sumQuery += ', SUM(' + cItemName11 + ') SumValue11 ';
            if (pItemName12 != null) sumQuery += ', SUM(' + cItemName12 + ') SumValue12 ';
            if (pItemName13 != null) sumQuery += ', SUM(' + cItemName13 + ') SumValue13 ';
            if (pItemName14 != null) sumQuery += ', SUM(' + cItemName14 + ') SumValue14 ';
            if (pItemName15 != null) sumQuery += ', SUM(' + cItemName15 + ') SumValue15 ';
            if (pItemName16 != null) sumQuery += ', SUM(' + cItemName16 + ') SumValue16 ';
            if (pItemName17 != null) sumQuery += ', SUM(' + cItemName17 + ') SumValue17 ';
            if (pItemName18 != null) sumQuery += ', SUM(' + cItemName18 + ') SumValue18 ';
            if (pItemName19 != null) sumQuery += ', SUM(' + cItemName19 + ') SumValue19 ';
            if (pItemName20 != null) sumQuery += ', SUM(' + cItemName20 + ') SumValue20 ';

            sumQuery +=
                'FROM ' + cObjectName + ' ' +
                // 'WHERE ' + RelationName + ' IN :CalculateParentIdList ';
                //20201104 削除フラグがないものだけを取得する                
                // 'WHERE ' + RelationName + ' IN :PIdList ';
                'WHERE ' + RelationName + ' IN :PIdList ' +
                'AND ' + facDeleteFlag + ' = false ';

            if (customFilter != null) {
                sumQuery += 'AND ' + customFilter + ' ';
            }
            sumQuery += 'GROUP BY ' + RelationName;
            
            System.debug('★★★sumQuery:' + sumQuery);
*/            
            //集計結果取得
/*          AggregateResult[] groupedResults = Database.query(sumQuery);
            for (AggregateResult Res : groupedResults) {
                Id recId = (Id)Res.get(RelationName);
                sObject updateRec = createObject(pObjectName);
                updateRec.put('Id', recId);
                
                 System.debug('★★★:' + Res );
                
                if (pItemName1 != null)  updateRec.put(pItemName1,  Res.get('SumValue1'));
                if (pItemName2 != null)  updateRec.put(pItemName2,  Res.get('SumValue2'));
                if (pItemName3 != null)  updateRec.put(pItemName3,  Res.get('SumValue3'));
                if (pItemName4 != null)  updateRec.put(pItemName4,  Res.get('SumValue4'));
                if (pItemName5 != null)  updateRec.put(pItemName5,  Res.get('SumValue5'));
                if (pItemName6 != null)  updateRec.put(pItemName6,  Res.get('SumValue6'));
                if (pItemName7 != null)  updateRec.put(pItemName7,  Res.get('SumValue7'));
                if (pItemName8 != null)  updateRec.put(pItemName8,  Res.get('SumValue8'));
                if (pItemName9 != null)  updateRec.put(pItemName9,  Res.get('SumValue9'));
                if (pItemName10 != null) updateRec.put(pItemName10, Res.get('SumValue10'));
                if (pItemName11 != null) updateRec.put(pItemName11, Res.get('SumValue11'));
                if (pItemName12 != null) updateRec.put(pItemName12, Res.get('SumValue12'));
                if (pItemName13 != null) updateRec.put(pItemName13, Res.get('SumValue13'));
                if (pItemName14 != null) updateRec.put(pItemName14, Res.get('SumValue14'));
                if (pItemName15 != null) updateRec.put(pItemName15, Res.get('SumValue15'));
                if (pItemName16 != null) updateRec.put(pItemName16, Res.get('SumValue16'));
                if (pItemName17 != null) updateRec.put(pItemName17, Res.get('SumValue17'));
                if (pItemName18 != null) updateRec.put(pItemName18, Res.get('SumValue18'));
                if (pItemName19 != null) updateRec.put(pItemName19, Res.get('SumValue19'));
                if (pItemName20 != null) updateRec.put(pItemName20, Res.get('SumValue20'));               
                
            System.debug('★★★★★:' + updateRec);

                //dmlBuffer.add(updateRec);
                dmlBuffer.put(recId,updateRec);
                procRecords.add(recId);
            }
            //for (id targetId : CalculateParentIdList) {
            for (string targetId : PIdList) {
                //更新対象の親レコードに紐づく子レコードがない場合
                if (!procRecords.contains(targetId)) {
                    sObject updateRec = createObject(pObjectName);
                    updateRec.put('Id', targetId);
                    
                    if (pItemName1 != null)  updateRec.put(pItemName1, 0);
                    if (pItemName2 != null)  updateRec.put(pItemName2, 0);
                    if (pItemName3 != null)  updateRec.put(pItemName3, 0);
                    if (pItemName4 != null)  updateRec.put(pItemName4, 0);
                    if (pItemName5 != null)  updateRec.put(pItemName5, 0);
                    if (pItemName6 != null)  updateRec.put(pItemName6, 0);
                    if (pItemName7 != null)  updateRec.put(pItemName7, 0);
                    if (pItemName8 != null)  updateRec.put(pItemName8, 0);
                    if (pItemName9 != null)  updateRec.put(pItemName9, 0);
                    if (pItemName10 != null) updateRec.put(pItemName10, 0);
                    if (pItemName11 != null) updateRec.put(pItemName11, 0);
                    if (pItemName12 != null) updateRec.put(pItemName12, 0);
                    if (pItemName13 != null) updateRec.put(pItemName13, 0);
                    if (pItemName14 != null) updateRec.put(pItemName14, 0);
                    if (pItemName15 != null) updateRec.put(pItemName15, 0);
                    if (pItemName16 != null) updateRec.put(pItemName16, 0);
                    if (pItemName17 != null) updateRec.put(pItemName17, 0);
                    if (pItemName18 != null) updateRec.put(pItemName18, 0);
                    if (pItemName19 != null) updateRec.put(pItemName19, 0);
                    if (pItemName20 != null) updateRec.put(pItemName20, 0);
                                        
                    //dmlBuffer.add(updateRec);
                    dmlBuffer.put(targetId,updateRec);
                }
            }
            //System.debug('★★★dmlBuffer:' + dmlBuffer);
            if (!dmlBuffer.isEmpty()) {
                //update dmlBuffer
                update dmlBuffer.values();
            }
        }
    }
*/
    private Map<Id, Opportunity> getOpptunityMap(List<Factory__c> newlist){

        Set<String> oppIdList = new Set<String>();
        for (Factory__c fac : newList) {
            oppIdList.add(fac.Opp1__c);
        }

        return new Map<Id, Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Id IN: oppIdList]);
    }
/* 2021.06.25 コスト構造対応  未使用のためコメント化
    private static sObject createObject(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType != null) {
            return targetType.newSObject();
        } else {
            return null;
        }
    }
*/
    /**
     * 失注or削除ではない案件が作成、更新された時、明細、案件更新日時分秒を設定、更新するための準備
     */
    private void updateLastModifiedDateTimeInOpp(Map<Id, sObject> oldMap, List<Factory__c> newList, Boolean isUpdate){
        Set<Id> facIds = new Set<Id>();
        for(Factory__c fac : newList){
            facIds.add(fac.Id);
        }

        Map<Id, Factory__c> facMap = new Map<Id, Factory__c>([SELECT Id, LastModifiedBy.Profile.Name, Opp1__c, OppPhase__c FROM Factory__c WHERE Id IN : facIds]);

        List<Profile> profileIds = [SELECT Id FROM Profile WHERE Name = 'RPAロボット' OR Name = 'システム管理者' OR Name = 'データ移行管理者'];
        Set<Id> pIds = new Set<Id>();
        for(Profile p : profileIds){
            pIds.add(p.Id);
        }

        Set<Id> facOpp1Ids = new Set<Id>();
        for(Factory__c fac : newList){
            if(oldMap == null){
                if(
                    !(pIds.contains(UserInfo.getProfileId())
                    || fac.OppPhase__c == STAGE_FAILED
                    || fac.OppPhase__c == STAGE_DELETE
                    )
                ){
                    facOpp1Ids.add(fac.Opp1__c);
                    fac.LastModifiedDateAndTime__c = createLastModDateTime(fac, isUpdate);
                    fac.LastModifiedDateInFac__c = Date.valueOf(Datetime.now());
                }
            } else {
                if(
                    !(pIds.contains(UserInfo.getProfileId())
                    || (facMap.get(fac.Id).OppPhase__c == STAGE_FAILED && fac.OppPhase__c == STAGE_FAILED)
                    || (facMap.get(fac.Id).OppPhase__c == STAGE_DELETE && fac.OppPhase__c == STAGE_DELETE)
                    )
                ){
                    facOpp1Ids.add(fac.Opp1__c);
                    fac.LastModifiedDateAndTime__c = createLastModDateTime(fac, isUpdate);
                    fac.LastModifiedDateInFac__c = Date.valueOf(Datetime.now());
                }
            }
        }
    }

    /**
     * 更新日時分秒作成
     */
    private String createLastModDateTime(Factory__c fac, Boolean isUpdate){
        String str = String.valueOf(Datetime.now()).replace('-','');
        str = str.replace(' ', '');
        str = str.replace(':', '');
        return str;
    }

    /**
     * 案件の更新日時を設定
     */
    public void setOppLastModDateTime(List<Factory__c> newList, Map<Id, Sobject> oldMap){

        List<Profile> profileIds = [SELECT Id FROM Profile WHERE Name = 'RPAロボット' OR Name = 'システム管理者' OR Name = 'データ移行管理者'];
        Set<Id> pIds = new Set<Id>();
        for(Profile p : profileIds){
            pIds.add(p.Id);
        }
        Set<Id> facIds = new Set<Id>();
        for(Factory__c fac : newList){
            facIds.add(fac.Id);
        }

        Map<Id, Factory__c> facMap = new Map<Id, Factory__c>([SELECT Id, LastModifiedBy.Profile.Name, Opp1__c, OppPhase__c FROM Factory__c WHERE Id IN : facIds]);
        Map<Id, Factory__c> setUpdateMap = new Map<Id, Factory__c>();
        Set<Id> facOpp1Ids = new Set<Id>();
        for(Factory__c fac : newList){
            if(
                !(pIds.contains(UserInfo.getProfileId())
                || (facMap.get(fac.Id).OppPhase__c == STAGE_FAILED && fac.OppPhase__c == STAGE_FAILED)
                || (facMap.get(fac.Id).OppPhase__c == STAGE_DELETE && fac.OppPhase__c == STAGE_DELETE)
                )
            ){
                facOpp1Ids.add(fac.Opp1__c);
                setUpdateMap.put(fac.Opp1__c, fac);
            }
        }

        List<Opportunity> oppList = [SELECT Id, LastModifiedDateAndTime__c, LastModifiedDateInOpp__c FROM Opportunity WHERE Id IN: facOpp1Ids];
        for(Opportunity opp : oppList){
            opp.LastModifiedDateAndTime__c = createLastModDateTime(setUpdateMap.get(opp.Id), true);
            opp.LastModifiedDateInOpp__c = Date.valueOf(Datetime.now());
        }

        update oppList;
    }
}