/**
 * 案件のトリガハンドラ
 */
public class OpportunityTriggerHandler {

    // 集計先オブジェクト名（案件）
    private String pObjectName = 'Opportunity';

    // 集計先項目名（案件）
    private String pItemName1  = 'TotalCP__c';                  // １．商談CP
    private String pItemName2  = 'TotalWC__c';                  // １．商談WC
    private String pItemName3  = 'TC__c';                       // １．商談TC    
    private String pItemName4  = 'Order_TotalCP__c';            // ２．SRCP（受注時）
    private String pItemName5  = 'Order_TotalWC__c';            // ２．SRWC（受注時）
    // private String pItemName6  = 'Order_TC__c';                 // ２．SRTC（受注時）
    private String pItemName7  = 'Order_Forecast_TotalCP__c';   // ２．最終予想CP（受注時）
    private String pItemName8  = 'Order_Forecast_TotalWC__c';   // ２．最終予想WC（受注時）
    // private String pItemName9  = 'Order_Forecast_TC__c';        // ２．最終予想TC（受注時）
    private String pItemName10 = 'Latest_TotalCP__c';           // ３．SRCP（最新）
    private String pItemName11 = 'Latest_TotalWC__c';           // ３．SRWC（最新）
    // private String pItemName12 = 'Latest_TC__c';                // ３．SRTC（最新）
    private String pItemName13 = 'Latest_Forecast_TotalCP__c';  // ３．最終予想CP（最新）
    private String pItemName14 = 'Latest_Forecast_TotalWC__c';  // ３．最終予想WC（最新）
    // private String pItemName15 = 'Latest_Forecast_TC__c';       // ３．最終予想TC（最新）
    private String pItemName16 = 'Result_TotalCP__c';           // ４．売上実績CP
    private String pItemName17 = 'Result_TotalWC__c';           // ４．売上実績WC
    // private String pItemName18 = 'Result_TC__c';                // ４．売上実績TC
    private String pItemName19 = 'Result_Difference__c';        // ４．締切差異
    private String pItemName20 = 'Result_AdditionalCost__c';    // ４．追加原価
    private String pItemName21 = 'Order_OrderDate__c';          // ２．受注年月日
    private String pItemName22 = 'Latest_SRInfoUpdateDate__c';  // ３．SR情報最新取得日
    private String pItemName23 = 'Result_SalesDate__c';         // ４．売上年月日

    // 集計元オブジェクト名（場所別）
    private String cObjectName = 'Factory__c';

    // 集計元項目名（場所別）
    private String cItemName1 = 'SR_CP__c';                     // １．商談CP
    private String cItemName2 = 'SRWC__c';                      // １．商談WC
    private String cItemName3 = 'TC__c';                        // １．商談TC
    //-- 2021.06.25 コスト構造対応 DEL Start
    // private String cItemName6 = 'Order_TC__c';
    // private String cItemName9 = 'Order_Forecast_TC__c';
    // private String cItemName12 = 'Latest_TC__c';
    // private String cItemName15 = 'Latest_Forecast_TC__c';
    // private String cItemName18 = 'Result_TC__c';
    // private String cItemName4  = 'Order_SR_CP__c';
    // private String cItemName5  = 'Order_SRWC__c';
    // private String cItemName7  = 'Order_Forecast_SR_CP__c';
    // private String cItemName8  = 'Order_Forecast_SRWC__c';
    // private String cItemName10 = 'Latest_SR_CP__c';
    // private String cItemName11 = 'Latest_SRWC__c';
    // private String cItemName13 = 'Latest_Forecast_SR_CP__c';
    // private String cItemName14 = 'Latest_Forecast_SRWC__c';
    // private String cItemName16 = 'Result_SR_CP__c';
    // private String cItemName17 = 'Result_SRWC__c';
    // private String cItemName19 = 'Result_Difference__c';
    // private String cItemName20 = 'Result_AdditionalCost__c';
    //-- 2021.06.25 コスト構造対応 DEL End

    private String RelationName = 'Opp1__c';
    private String facDeleteFlag = 'DeleteFlag__c';

    // 集計元オブジェクト名（SR情報）
    private String srObjectName = 'SRInfo__c';
    // 集計元項目名（SR情報）
    private String srItemName1 = 'Order_SRCP__c';               // SRCP（受注時）
    private String srItemName2 = 'Order_SRWC__c';               // SRWC（受注時）
    private String srItemName3 = 'Order_Forecast_SRCP__c';      // 最終予想CP（受注時）
    private String srItemName4 = 'Order_Forecast_SRWC__c';      // 最終予想WC（受注時）
    private String srItemName5 = 'Latest_SRCP__c';              // SRCP（最新）
    private String srItemName6 = 'Latest_SRWC__c';              // SRWC（最新）
    private String srItemName7 = 'Latest_Forecast_SRCP__c';     // 最終予想CP（最新）
    private String srItemName8 = 'Latest_Forecast_SRWC__c';     // 最終予想WC（最新）
    private String srItemName9 = 'Result_SRCP__c';              // 売上実績CP
    private String srItemName10 = 'Result_SRWC__c';             // 売上実績WC
    private String srItemName11 = 'Result_Difference__c';       // 締切差異
    private String srItemName12 = 'Result_AdditionalCost__c';   // 追加原価
    private String srItemName13 = 'Order_OrderDate__c';         // 受注年月日
    private String srItemName14 = 'Latest_SRInfoUpdateDate__c'; // SR情報取得日（最新）
    private String srItemName15 = 'Result_SalesDate__c';        // 売上年月日

    private String srRelationName = 'Opportunity__c';

    // 案件フェーズ
    private static final String STAGE_ORDER = '受注・オーダー管理';
    private static final String STAGE_ORDER_COMPLETED = 'オーダー完了';
    private static final String STAGE_DELETE = '削除';
    private static final String STAGE_FAILED = '失注';

    // 統一企業コード（三菱電機株式会社）
    private static final String  companyCode = System.Label.COMPANY_CODE_MITSUBISHI; // A000002HA

    // SR情報から取得した商談番号、案件Id
    private Map<String, String> opNumberMap = new Map<String, String>();

    // 再帰呼び出し制御
    private static Map<String, Boolean> isRecursiveMap = new Map<String, Boolean>();
    private static final String MODE_BEFORE_INSERT = 'before_insert';
    private static final String MODE_BEFORE_UPDATE = 'before_update';
    private static final String MODE_AFTER_UPDATE = 'after_update';

    // 再起呼び出し制御マップ作製
    public static void setIsRecursive(String mode){
        isRecursiveMap.put(mode, true);
    }

    // // 再起呼び出し制御判定
    public static Boolean isRecursive(String mode){
        return isRecursiveMap.containsKey(mode);
    }

    /**
     * 更新前処理
     */
    public void onBeforeUpdate(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        if(!isRecursive(MODE_BEFORE_UPDATE)){
            // 案件.商談番号（ハイフンなし）外部IDをセット
            this.setOpportunityNumberHyphenless(newMap);
            // 場所別⇒案件
            this.recalculationOppByFactory(newMap);
            // SR情報⇒案件
            this.recalculationOppBySRInfo(newMap, oldMap);
            // 案件更新日時を設定（プロセスビルダーの処理を移行）
            this.updateLastModifiedDateTimeInOpp(oldMap, newList, true);
            // 発行予定日①の設定
            this.setOppItem(newList);
        }
        setIsRecursive(MODE_BEFORE_UPDATE);
    }

    /**
     * 作成前処理
     */
    public void onBeforeInsert(List<Opportunity> newList){
        if(!isRecursive(MODE_BEFORE_INSERT)){
            // 案件更新日時を設定（プロセスビルダーの処理を移行）
            this.updateLastModifiedDateTimeInOpp(null, newList, false);
            // 案件項目自動設定
            this.setOppItem(newList);
        }
        setIsRecursive(MODE_BEFORE_INSERT);
    }

    /**
     * 更新後処理
     */
    public void onAfterUpdate(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap){
        if(!isRecursive(MODE_AFTER_UPDATE)){
            // 場所別更新
            this.updateFactories(newMap, oldMap);
        }
        setIsRecursive(MODE_AFTER_UPDATE);
    }

    /**
     * 作成後処理
     */
    public void onAfterInsert(List<Opportunity> newList){
        // 社内承認レコード作成
        this.createNewInternalApproval(newList);
    }

    /**
     * 案件.商談番号（ハイフンなし）外部IDをセット
     */
    private void setOpportunityNumberHyphenless(Map<Id, Opportunity> newMap) {

        for (Id oppId : newMap.keyset()) {
            // 商談番号のハイフンを除去して商談番号（ハイフンなし）にセットする
            if (String.isBlank(newMap.get(oppId).OpportunityNumber__c)) {
                newMap.get(oppId).put('OpportunityNumber_Hyphenless__c', '');
            } else {
                newMap.get(oppId).put('OpportunityNumber_Hyphenless__c', newMap.get(oppId).OpportunityNumber__c.remove('-'));
            }
        }
    }

    /**
     * 集計処理（場所別⇒案件）
     */
    private void recalculationOppByFactory(Map<Id, Opportunity> newMap) {

        Set<String> procRecords = new Set<String>();

        List<Id> oppIdList = new List<Id>();
        for (Id oppId : newMap.keyset()) {
            // 案件.フェーズが「受注・オーダー管理」以外、かつ「オーダー完了」以外のとき
            if (!newMap.get(oppId).StageName.equals(STAGE_ORDER) && !newMap.get(oppId).StageName.equals(STAGE_ORDER_COMPLETED)) {
                oppIdList.add(oppId);
            }
        }

        // 集計元（場所別）のSOQLを生成する
        string sumQuery = 'SELECT ' + RelationName;
        if (pItemName1 != null)  sumQuery += ', SUM(' + cItemName1  + ') SumValue1 ';
        if (pItemName2 != null)  sumQuery += ', SUM(' + cItemName2  + ') SumValue2 ';
        if (pItemName3 != null)  sumQuery += ', SUM(' + cItemName3  + ') SumValue3 ';
        //-- 2021.06.25 コスト構造対応 DEL Start
        // if (pItemName4 != null)  sumQuery += ', SUM(' + cItemName4  + ') SumValue4 ';
        // if (pItemName5 != null)  sumQuery += ', SUM(' + cItemName5  + ') SumValue5 ';
        // if (pItemName6 != null)  sumQuery += ', SUM(' + cItemName6  + ') SumValue6 ';
        // if (pItemName7 != null)  sumQuery += ', SUM(' + cItemName7  + ') SumValue7 ';
        // if (pItemName8 != null)  sumQuery += ', SUM(' + cItemName8  + ') SumValue8 ';
        // if (pItemName9 != null)  sumQuery += ', SUM(' + cItemName9  + ') SumValue9 ';
        // if (pItemName10 != null) sumQuery += ', SUM(' + cItemName10 + ') SumValue10 ';
        // if (pItemName11 != null) sumQuery += ', SUM(' + cItemName11 + ') SumValue11 ';
        // if (pItemName12 != null) sumQuery += ', SUM(' + cItemName12 + ') SumValue12 ';
        // if (pItemName13 != null) sumQuery += ', SUM(' + cItemName13 + ') SumValue13 ';
        // if (pItemName14 != null) sumQuery += ', SUM(' + cItemName14 + ') SumValue14 ';
        // if (pItemName15 != null) sumQuery += ', SUM(' + cItemName15 + ') SumValue15 ';
        // if (pItemName16 != null) sumQuery += ', SUM(' + cItemName16 + ') SumValue16 ';
        // if (pItemName17 != null) sumQuery += ', SUM(' + cItemName17 + ') SumValue17 ';
        // if (pItemName18 != null) sumQuery += ', SUM(' + cItemName18 + ') SumValue18 ';
        // if (pItemName19 != null) sumQuery += ', SUM(' + cItemName19 + ') SumValue19 ';
        // if (pItemName20 != null) sumQuery += ', SUM(' + cItemName20 + ') SumValue20 ';
        //-- 2021.06.25 コスト構造対応 DEL End

        sumQuery += ' FROM ' + cObjectName;
        sumQuery += ' WHERE ' + RelationName + ' IN :oppIdList';
        sumQuery += ' AND ' + facDeleteFlag + ' = false';
        sumQuery += ' GROUP BY ' + RelationName;
        
        // 集計結果を取得して案件に反映する
        AggregateResult[] groupedResults = Database.query(sumQuery);
        for (AggregateResult Res : groupedResults) {
            Id recId = (Id)Res.get(RelationName);
            // sObject updateRec = createObject(pObjectName);   //-- 2021.06.25 コスト構造対応 DEL
            
            if (pItemName1 != null)  newMap.get(recId).put(pItemName1,  Res.get('SumValue1'));
            if (pItemName2 != null)  newMap.get(recId).put(pItemName2,  Res.get('SumValue2'));
            if (pItemName3 != null)  newMap.get(recId).put(pItemName3,  Res.get('SumValue3'));
            //-- 2021.06.25 コスト構造対応 DEL Start
            // if (pItemName4 != null)  newMap.get(recId).put(pItemName4,  Res.get('SumValue4'));
            // if (pItemName5 != null)  newMap.get(recId).put(pItemName5,  Res.get('SumValue5'));
            // if (pItemName6 != null)  newMap.get(recId).put(pItemName6,  Res.get('SumValue6'));
            // if (pItemName7 != null)  newMap.get(recId).put(pItemName7,  Res.get('SumValue7'));
            // if (pItemName8 != null)  newMap.get(recId).put(pItemName8,  Res.get('SumValue8'));
            // if (pItemName9 != null)  newMap.get(recId).put(pItemName9,  Res.get('SumValue9'));
            // if (pItemName10 != null) newMap.get(recId).put(pItemName10, Res.get('SumValue10'));
            // if (pItemName11 != null) newMap.get(recId).put(pItemName11, Res.get('SumValue11'));
            // if (pItemName12 != null) newMap.get(recId).put(pItemName12, Res.get('SumValue12'));
            // if (pItemName13 != null) newMap.get(recId).put(pItemName13, Res.get('SumValue13'));
            // if (pItemName14 != null) newMap.get(recId).put(pItemName14, Res.get('SumValue14'));
            // if (pItemName15 != null) newMap.get(recId).put(pItemName15, Res.get('SumValue15'));
            // if (pItemName16 != null) newMap.get(recId).put(pItemName16, Res.get('SumValue16'));
            // if (pItemName17 != null) newMap.get(recId).put(pItemName17, Res.get('SumValue17'));
            // if (pItemName18 != null) newMap.get(recId).put(pItemName18, Res.get('SumValue18'));
            // if (pItemName19 != null) newMap.get(recId).put(pItemName19, Res.get('SumValue19'));
            // if (pItemName20 != null) newMap.get(recId).put(pItemName20, Res.get('SumValue20'));
            //-- 2021.06.25 コスト構造対応 DEL End

            procRecords.add(recId);
        }

        for (string targetId : oppIdList) {
            // 更新対象の親レコードに紐づく子レコードがない場合
            if (!procRecords.contains(targetId)) {
                // sObject updateRec = createObject(pObjectName);   //-- 2021.06.25 コスト構造対応 DEL
                // updateRec.put('Id', targetId);                   //-- 2021.06.25 コスト構造対応 DEL
                
                if (pItemName1 != null)  newMap.get(targetId).put(pItemName1, 0);
                if (pItemName2 != null)  newMap.get(targetId).put(pItemName2, 0);
                if (pItemName3 != null)  newMap.get(targetId).put(pItemName3, 0);
                //-- 2021.06.25 コスト構造対応 DEL Start
                // if (pItemName4 != null)  newMap.get(targetId).put(pItemName4, 0);
                // if (pItemName5 != null)  newMap.get(targetId).put(pItemName5, 0);
                // if (pItemName6 != null)  newMap.get(targetId).put(pItemName6, 0);
                // if (pItemName7 != null)  newMap.get(targetId).put(pItemName7, 0);
                // if (pItemName8 != null)  newMap.get(targetId).put(pItemName8, 0);
                // if (pItemName9 != null)  newMap.get(targetId).put(pItemName9, 0);
                // if (pItemName10 != null) newMap.get(targetId).put(pItemName10, 0);
                // if (pItemName11 != null) newMap.get(targetId).put(pItemName11, 0);
                // if (pItemName12 != null) newMap.get(targetId).put(pItemName12, 0);
                // if (pItemName13 != null) newMap.get(targetId).put(pItemName13, 0);
                // if (pItemName14 != null) newMap.get(targetId).put(pItemName14, 0);
                // if (pItemName15 != null) newMap.get(targetId).put(pItemName15, 0);
                // if (pItemName16 != null) newMap.get(targetId).put(pItemName16, 0);
                // if (pItemName17 != null) newMap.get(targetId).put(pItemName17, 0);
                // if (pItemName18 != null) newMap.get(targetId).put(pItemName18, 0);
                // if (pItemName19 != null) newMap.get(targetId).put(pItemName19, 0);
                // if (pItemName20 != null) newMap.get(targetId).put(pItemName20, 0);
                //-- 2021.06.25 コスト構造対応 DEL End
            }
        }
    }

    /**
     * 集計処理（SR情報⇒案件）
     */
    private void recalculationOppBySRInfo(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {

        List<Id> oppIdList = new List<Id>();
        Set<Id> getOppIdSet = new Set<Id>();

        for (Id oppId : newMap.keyset()) {
            // 最終SR集計日時が変わっていたら
            if (newMap.get(oppId).LastSRAggregateDate__c != oldMap.get(oppId).LastSRAggregateDate__c) {
                oppIdList.add(oppId);
            }
        }
        if (oppIdList.size() == 0) {
            return;
        }

        // 案件.売報番号をセットする
        this.setSRNumberBySRInfo(newMap, oppIdList);
        
        Map<Id, String> minDateMap = new Map<Id, String>();

        // SR情報から案件毎の受注年月の最小を取得する
        AggregateResult[] a = [SELECT Opportunity__c, MIN(OrderMonth__c) month FROM SRInfo__c WHERE Opportunity__c IN :oppIdList GROUP BY Opportunity__c];

        // <案件ID, 最小受注年月>のMapを作成
        for(AggregateResult Res : a){
            minDateMap.put((Id)Res.get(srRelationName),String.valueOf(Res.get('month')));
        }

        // 案件に紐づいているSR情報を全て取得
        List<SRInfo__c> srResults = 
            [SELECT Opportunity__c, Order_SRCP__c, Order_SRWC__c, Order_Forecast_SRCP__c, Order_Forecast_SRWC__c, Order_OrderDate__c, OrderMonth__c
            FROM SRInfo__c
            WHERE Opportunity__c IN :oppIdList
            ORDER BY Opportunity__c, Order_OrderDate__c DESC];

        // 取引先（三菱電機株式会社）を取得（クエリの回数削減の為ループ外で取得する）
        List<Account> accList = new List<Account>(getMitsubishiDenki());
        
        // 念のため受注関連の金額項目を初期化
        for(Opportunity opp : newMap.values()){
            opp.Order_TotalCP__c = 0;
            opp.Order_TotalWC__c = 0;
            opp.Order_Forecast_TotalCP__c = 0;
            opp.Order_Forecast_TotalWC__c = 0;
            opp.Order_OrderDate__c = null;
            opp.Latest_TotalCP__c = 0;
            opp.Latest_TotalWC__c = 0;
            opp.Latest_Forecast_TotalCP__c = 0;
            opp.Latest_Forecast_TotalWC__c = 0;
            opp.Latest_SRInfoUpdateDate__c = null;
            opp.Result_TotalCP__c = 0;
            opp.Result_TotalWC__c = 0;
            opp.Result_Difference__c = 0;
            opp.Result_AdditionalCost__c = 0;
            opp.Result_SalesDate__c = null;
        }

        // 親案件の最小受注年月と一致する受注年月を持つSR情報のみ、受注関連の金額に合算する
        for(SRInfo__c sr : srResults){
            Id recId = sr.Opportunity__c;

            if(sr.OrderMonth__c == minDateMap.get(recId)){
                if (sr.Order_SRCP__c != null) newMap.get(recId).Order_TotalCP__c += sr.Order_SRCP__c;
                if (sr.Order_SRWC__c != null) newMap.get(recId).Order_TotalWC__c += sr.Order_SRWC__c;
                if (sr.Order_Forecast_SRCP__c != null) newMap.get(recId).Order_Forecast_TotalCP__c += sr.Order_Forecast_SRCP__c;
                if (sr.Order_Forecast_SRWC__c != null) newMap.get(recId).Order_Forecast_TotalWC__c += sr.Order_Forecast_SRWC__c;
                if (sr.Order_OrderDate__c != null) newMap.get(recId).Order_OrderDate__c = sr.Order_OrderDate__c;
            }

            // 受注社が未入力のとき、「三菱電機株式会社」を登録する
            if (String.isBlank(newMap.get(recId).Competitor__c)) {
                if (accList.size() > 0) {
                    newMap.get(recId).put('Competitor__c', accList[0].Id);
                }
            }

            // 案件フェーズが「受注・オーダー管理」以外、かつ「オーダー完了」以外のとき、「受注・オーダー管理」にする
            if (!newMap.get(recId).StageName.equals(STAGE_ORDER) && !newMap.get(recId).StageName.equals(STAGE_ORDER_COMPLETED)) {
                newMap.get(recId).put('StageName', STAGE_ORDER);
            }
        }

        // SR情報から「受注後最新」「売上実績」情報を取得する
        string sumQuery = 'SELECT ' + srRelationName;
        sumQuery += ', SUM(' + srItemName5  + ') SumValue5 ';
        sumQuery += ', SUM(' + srItemName6  + ') SumValue6 ';
        sumQuery += ', SUM(' + srItemName7  + ') SumValue7 ';
        sumQuery += ', SUM(' + srItemName8  + ') SumValue8 ';
        sumQuery += ', SUM(' + srItemName9  + ') SumValue9 ';
        sumQuery += ', SUM(' + srItemName10  + ') SumValue10 ';
        sumQuery += ', SUM(' + srItemName11  + ') SumValue11 ';
        sumQuery += ', SUM(' + srItemName12  + ') SumValue12 ';
        sumQuery += ', MAX(' + srItemName14  + ') MaxValue1 ';
        sumQuery += ', MAX(' + srItemName15  + ') MaxValue2 ';

        sumQuery += ' FROM ' + srObjectName;
        sumQuery += ' WHERE ' + srRelationName + ' IN :oppIdList';
        sumQuery += ' GROUP BY ' + srRelationName;

        //「受注後最新」「売上実績」の集計値を案件に反映する
        AggregateResult[] groupedResults2 = Database.query(sumQuery);
        System.debug('groupedResults2:' + groupedResults2);
        for (AggregateResult Res : groupedResults2) {
            Id recId = (Id)Res.get(srRelationName);

            newMap.get(recId).put(pItemName10, Res.get('SumValue5'));
            newMap.get(recId).put(pItemName11, Res.get('SumValue6'));
            newMap.get(recId).put(pItemName13, Res.get('SumValue7'));
            newMap.get(recId).put(pItemName14, Res.get('SumValue8'));
            newMap.get(recId).put(pItemName16, Res.get('SumValue9'));
            newMap.get(recId).put(pItemName17, Res.get('SumValue10'));
            newMap.get(recId).put(pItemName19, Res.get('SumValue11'));
            newMap.get(recId).put(pItemName20, Res.get('SumValue12'));
            newMap.get(recId).put(pItemName22, Res.get('MaxValue1'));
            newMap.get(recId).put(pItemName23, Res.get('MaxValue2'));

            // 受注社が未入力のとき、「三菱電機株式会社」を登録する
            if (String.isBlank(newMap.get(recId).Competitor__c)) {
                if (accList.size() > 0) {
                    newMap.get(recId).put('Competitor__c', accList[0].Id);
                }
            }

            // 案件フェーズが「受注・オーダー管理」以外、かつ「オーダー完了」以外のとき、「受注・オーダー管理」にする
            if (!newMap.get(recId).StageName.equals(STAGE_ORDER) && !newMap.get(recId).StageName.equals(STAGE_ORDER_COMPLETED)) {
                newMap.get(recId).put('StageName', STAGE_ORDER);
            }

            // 売上実績が設定されたら案件フェーズを「オーダー完了」にする
            if (newMap.get(recId).Result_TotalCP__c != oldMap.get(recId).Result_TotalCP__c 
                || newMap.get(recId).Result_TotalWC__c != oldMap.get(recId).Result_TotalWC__c
                || newMap.get(recId).Result_Difference__c != oldMap.get(recId).Result_Difference__c
                || newMap.get(recId).Result_AdditionalCost__c != oldMap.get(recId).Result_AdditionalCost__c
                || newMap.get(recId).Result_SalesDate__c != oldMap.get(recId).Result_SalesDate__c) {
                newMap.get(recId).put('StageName', STAGE_ORDER_COMPLETED);
            }

            getOppIdSet.add(recId);
        }

        // SR情報が1件も紐づかない場合、各項目を0ではなくnullにする
        for(Opportunity opp : newMap.values()){
            if(getOppIdSet.contains(opp.Id) == false){
                opp.Order_TotalCP__c = null;
                opp.Order_TotalWC__c = null;
                opp.Order_Forecast_TotalCP__c = null;
                opp.Order_Forecast_TotalWC__c = null;
                opp.Order_OrderDate__c = null;
                opp.Latest_TotalCP__c = null;
                opp.Latest_TotalWC__c = null;
                opp.Latest_Forecast_TotalCP__c = null;
                opp.Latest_Forecast_TotalWC__c = null;
                opp.Latest_SRInfoUpdateDate__c = null;
                opp.Result_TotalCP__c = null;
                opp.Result_TotalWC__c = null;
                opp.Result_Difference__c = null;
                opp.Result_AdditionalCost__c = null;
                opp.Result_SalesDate__c = null;                
            }
        }

        // 案件.手数料をセットする
        this.setMarginByOrder(newMap,getOppIdSet);
    }

    /**
     * オーダー管理台帳から販売手数料を取得して案件にセットする
     */
    private void setMarginByOrder(Map<Id, Opportunity> newMap,Set<Id> getOppIdSet) {

        // オーダー管理台帳から商談番号、販売手数料を取得する
        List<OrderManagementLedger__c> ordList = 
            [SELECT OpportunityNumber__c, Margin__c 
                FROM OrderManagementLedger__c 
                WHERE OpportunityNumber__c IN :opNumberMap.keySet() 
                ORDER BY OpportunityNumber__c];

        System.debug('★opNumberMap：' + opNumberMap);
        System.debug('★ordList.size()：' + ordList.size());

        // SR情報が1件も紐づかない場合、各手数料項目をnullにする
        for(Opportunity opp : newMap.values()){
            if(getOppIdSet.contains(opp.Id) == false){
                opp.Latest_Margin__c = null;
                opp.Order_Margin__c = null;
                opp.Result_Margin__c = null;
            }
        }

        if (ordList.size() == 0) {
            return;
        }

        // 月初日付を取得する
        Date monthOfStartDay = getMonthOfStartDay(Date.today());
        System.debug('★monthOfStartDay：' + monthOfStartDay);

        // オーダー管理台帳.販売手数料を案件の各手数料に設定する
        for (OrderManagementLedger__c ord :ordList) {
            // 商談番号から案件Idを取得する
            Id oppId = opNumberMap.get(ord.OpportunityNumber__c);

            // SR情報最新取得日が前月以前の場合、SR手数料（最新）をセットする
            if (newMap.get(oppId).Latest_SRInfoUpdateDate__c != null
                && newMap.get(oppId).Latest_SRInfoUpdateDate__c < monthOfStartDay
                && (newMap.get(oppId).StageName == STAGE_ORDER || newMap.get(oppId).Order_Margin__c == null)) {
                newMap.get(oppId).put('Latest_Margin__c', ord.Margin__c);
            }
            // 受注年月日が前月以前の場合、SR手数料（受注時）をセットする
            if (newMap.get(oppId).Order_OrderDate__c != null
                && newMap.get(oppId).Order_OrderDate__c < monthOfStartDay
                && newMap.get(oppId).Order_Margin__c == null) {
                newMap.get(oppId).put('Order_Margin__c', ord.Margin__c);
            }
            // 売上年月日が前月以前の場合、売上実績手数料をセットする
            if (newMap.get(oppId).Result_SalesDate__c != null
                && newMap.get(oppId).Result_SalesDate__c < monthOfStartDay) {
                newMap.get(oppId).put('Result_Margin__c', ord.Margin__c);
            }
        }
    }

    /**
     * 月初日付取得
     */
    public static Date getMonthOfStartDay(Date prmDate) {
        return prmDate != null ? Date.newInstance(prmDate.year(), prmDate.month(), 1) : null;
    }

    /**
     * SR情報の売報番号を連結して案件.売報番号にセットする
     */
    private void setSRNumberBySRInfo(Map<Id, Opportunity> newMap, List<Id> oppIdList) {

        // SR情報から案件ID、商談番号、売報番号を取得する
        // 商談番号が設定されている売報番号が主となる為、案件ID、商談番号、売報番号の順にソート
        List<SRInfo__c> srList = 
            [SELECT Opportunity__c, OP_Number__c, SR_Number__c
                FROM SRInfo__c
                WHERE Opportunity__c IN :oppIdList
                ORDER BY Opportunity__c, OP_Number__c DESC NULLS LAST, SR_Number__c];

        System.debug('★srList.size()：' + srList.size());
        if (srList.size() == 0) {
            return;
        }
        
        Id oppId = null;
        List<String> srNumbers = new List<String>();

        // SR情報.売報番号をセミコロン区切りで連結して案件.売報番号に設定する（案件：売報番号＝１：Ｎ）
        for (SRInfo__c sr : srList) {
            if (oppId != null && oppId != sr.Opportunity__c) {
                // 売報番号の重複を除去する
                Set<String> srNumbersSet = new Set<String>(srNumbers);
                // セミコロン区切りにする
                String resultStr = String.join(new List<String>(srNumbersSet),';');

                // 案件.その他売報番号
                if (resultStr.contains(';')) {
                    // 売報番号が複数ある場合、代表の売報番号を除去
                    newMap.get(oppId).put('SellingNumber__c', resultStr.remove(srNumbers[0] + ';'));
                } else {
                    // 代表の売報番号のみ残った場合はブランクとなる
                    newMap.get(oppId).put('SellingNumber__c', resultStr.remove(srNumbers[0]));
                }

                // 案件.売報番号
                newMap.get(oppId).put('SR_Number_Main__c', srNumbers[0]);
                srNumbers = new List<String>();
            }
            // 商談番号を格納
            if (String.isNotBlank(sr.OP_Number__c)) {
                opNumberMap.put(sr.OP_Number__c, sr.Opportunity__c);      // オーダー管理台帳で使用する
            }
            // 売報番号を格納
            if (String.isNotBlank(sr.SR_Number__c)) {
                srNumbers.add(sr.SR_Number__c);
            }
            oppId = sr.Opportunity__c;
        }

        if (srNumbers.size() > 0) {
            // 売報番号の重複を除去する
            Set<String> srNumbersSet = new Set<String>(srNumbers);
            // セミコロン区切りにする
            String resultStr = String.join(new List<String>(srNumbersSet),';');

            // 案件.その他売報番号
            if (resultStr.contains(';')) {
                // 売報番号が複数ある場合、代表の売報番号を除去
                newMap.get(oppId).put('SellingNumber__c', resultStr.remove(srNumbers[0] + ';'));
            } else {
                // 代表の売報番号のみ残った場合はブランクとなる
                newMap.get(oppId).put('SellingNumber__c', resultStr.remove(srNumbers[0]));
            }

            // 案件.売報番号
            newMap.get(oppId).put('SR_Number_Main__c', srNumbers[0]);
        }
    }

    /**
     * 指定したオブジェクトの項目を取得する
     */
/* 2021.06.25 コスト構造対応 未使用のためコメント化
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
     * 取引先（三菱電機株式会社）を検索する
     */
    private List<Account> getMitsubishiDenki() {
        return [SELECT Id FROM Account WHERE MelcoCode__c = :companyCode LIMIT 1];
    }

    /**
     * 失注or削除ではない案件が作成、更新された時、案件更新日時分秒を設定、更新するための準備
     */
    private List<Opportunity> setUpdateLastModifiedDateTimeInOpp(Map<Id, Opportunity> oldMap, List<Opportunity> newList){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : newList){
            oppIds.add(opp.Id);
        }

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, LastModifiedBy.Profile.Name FROM Opportunity WHERE Id IN : oppIds]);
        List<Profile> profileIds = [SELECT Id FROM Profile WHERE Name = 'RPAロボット' OR Name = 'システム管理者' OR Name = 'データ移行管理者'];
        Set<Id> pIds = new Set<Id>();
        for(Profile p : profileIds){
            pIds.add(p.Id);
        }

        List<Opportunity> oppList = new List<Opportunity>();

        for(Opportunity opp : newList){
            if(oldMap == null){
                if(
                    !(pIds.contains(UserInfo.getProfileId())
                    || opp.StageName == STAGE_FAILED
                    || opp.StageName == STAGE_DELETE
                    )
                ){
                    oppList.add(opp);
                }
            } else {
                if(
                    !(pIds.contains(UserInfo.getProfileId())
                    || (oldMap.get(opp.Id).StageName == STAGE_FAILED && opp.StageName == STAGE_FAILED)
                    || (oldMap.get(opp.Id).StageName == STAGE_DELETE && opp.StageName == STAGE_DELETE)
                    )
                ){
                    oppList.add(opp);
                }
            }
        }
        return oppList;
    }

    /**
     * 失注or削除ではない案件が作成、更新された時、案件更新日時分秒を設定、更新する
     */
    private void updateLastModifiedDateTimeInOpp(Map<Id, Opportunity> oldMap, List<Opportunity> newList, Boolean isUpdate){

        List<Opportunity> oppList = setUpdateLastModifiedDateTimeInOpp(oldMap, newList);
        setLastModifiedDateTimeInOpp(oppList, isUpdate);
    }

    /**
     * 失注or削除ではない案件が作成、更新された時、案件更新日時分秒を設定、更新する
     */
    private void setLastModifiedDateTimeInOpp(List<Opportunity> oppList, Boolean isUpdate){
        
        for(Opportunity opp : oppList){
            opp.LastModifiedDateInOpp__c = Date.valueOf(Datetime.now());
            String str = String.valueOf(Datetime.now()).replace('-','');
            str = str.replace(' ', '');
            str = str.replace(':', '');
            opp.LastModifiedDateAndTime__c = str;
        }
    }

    /**
     * 案件項目自動設定
     */
    private void setOppItem(List<Opportunity> newList){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : newList){
            oppIds.add(opp.Id);
        }

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, LastModifiedBy.Profile.Name FROM Opportunity WHERE Id IN : oppIds]);

        List<Profile> profileIds = [SELECT Id FROM Profile WHERE Name = 'RPAロボット'];
        Set<Id> pIds = new Set<Id>();
        for(Profile p : profileIds){
            pIds.add(p.Id);
        }

        for(Opportunity opp : newList){
            if(oppMap == null ||!pIds.contains(UserInfo.getProfileId())) {
                // 発行予定日①を設定
                opp.EstimatedIssuedDate_01__c = opp.CloseDate;
                // サイト②を自動入力
                if(opp.ScheduledCollectionDate2__c == null) {
                    opp.site2__c = opp.Website__c;
                }
                // サイト③を自動入力
                if(opp.ScheduledCollectionDate3__c == null){
                    opp.site3__c = opp.Website__c;
                }
                // CP・WC・回収予定金額をリセットして自動設定する
                if(opp.AutoCalculateCheck__c){
                    Decimal cp = opp.TotalCP__c == null ? null : (opp.TotalCP__c * (opp.Probability1__c * 0.01)).setScale(0, RoundingMode.HALF_UP);
                    opp.EstimatedIssuedCP_01__c = cp;
                    opp.EstimatedIssuedCP_02__c = null;
                    opp.EstimatedIssuedCP_03__c = null;
                    opp.EstimatedIssuedDate_02__c = null;
                    opp.EstimatedIssuedDate_03__c = null;
                    Decimal wc = opp.TotalWC__c == null ? null : (opp.TotalWC__c * (opp.Probability1__c * 0.01)).setScale(0, RoundingMode.HALF_UP);
                    opp.EstimatedIssuedWC_01__c = wc;
                    opp.EstimatedIssuedWC_02__c = null;
                    opp.EstimatedIssuedWC_03__c = null;
                    opp.ScheduledCollectionAmount01__c = cp == null ? null : cp + (cp * (Integer.valueOf(opp.SalesTax__c) * 0.01));
                    opp.ScheduledCollectionAmount02__c = null;
                    opp.ScheduledCollectionAmount03__c = null;
                    opp.ScheduledCollectionDate2__c = null;
                    opp.ScheduledCollectionDate3__c = null;
                }
                // 失注/削除区分を失注にする
                if(opp.StageName.equals(STAGE_FAILED)){
                    opp.LostType__c = STAGE_FAILED;
                }
                // 失注/削除区分を削除にする
                if(opp.StageName.equals(STAGE_DELETE)){
                    opp.LostType__c = STAGE_DELETE;
                }
                // 失注/削除区分をブランクにする
                if(!(opp.StageName.Equals(STAGE_FAILED)) && !(opp.StageName.Equals(STAGE_DELETE))){
                    opp.LostType__c = null;
                }
            }
        }
    }

    /**
     * 紐づく場所別の更新
     */
    private void updateFactories(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap){
        
        Set<Id> oppIds = new Set<Id>();

        // 係数が更新された案件に紐づく場所別の更新
        for(Opportunity opp : newMap.values()){
            if(oldMap.get(opp.Id).Probability1__c != opp.Probability1__c){
                oppIds.add(opp.Id);
            }
        }
        // PUS_CRM-421 の対応 START ※本番リリース未定のためコメントアウト
        //for(Opportunity opp : newMap.values()){
        //    if(checkUpdateFields(opp, oldMap)){
        //        oppIds.add(opp.Id);
        //    }
        //}
        // PUS_CRM-421 の対応 END
        
        List<Factory__c> fList = [SELECT Id FROM Factory__c WHERE Opp1__c IN: oppIds];
        if(fList.isEmpty()) return;
        Update fList;
    }
    
    // PUS_CRM-421 の対応 START ※本番リリース未定のためコメントアウト
    /**
     * 場所別の更新判定
     */
    //private Boolean checkUpdateFields(Opportunity opp, Map<Id, Opportunity> oldMap){
    //    List<String> targetFields = System.Label.FACTORY_UPDATE_TARGET_OPPFIELDS.split(',', 0);
    //    Boolean ret = false;
    //    for(String str : targetFields){
    //        if(oldMap.get(opp.Id).get(str) != opp.get(str)){
    //            ret = true; break;
    //        }
    //    }
    //    return ret;
    //}
    // PUS_CRM-421 の対応 END

    /**
     * 案件新規作成時、自身に紐づく社内承認レコードを作成する
     */
    private void createNewInternalApproval(List<Opportunity> newList){
        List<InternalApproval__c> insertInternalApproval = new List<InternalApproval__c>();
        for(Opportunity opp : newList){
            insertInternalApproval.add(new InternalApproval__c(Name = '伺い関連', Opportunity__c= opp.Id));
        }
        insert insertInternalApproval;
    }
}