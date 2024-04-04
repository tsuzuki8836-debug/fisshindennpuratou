public class WorkTriggerHandler {
    // 商談番号有りのworkのList
    @testvisible private static List<work__c> numberedWorkList;
    // 商談番号無しのworkのList
    @testvisible private static List<work__c> numberlessWorkList;
    // 商談番号無しのworkの売報番号のSet
    @testvisible private static Set<String> numberlessWorkSRNumberSet;
    // 商談番号無しのworkの売報番号（ボディ番号）のSet
    @testvisible private static Set<String> numberlessWorkSRNumberBodySet;

    /**
     * @description 登録前のトリガーハンドラ。
     * @param newList 登録するworkデータ
     */
    public void onBeforeInsert(List<work__c> newList) {
        // 商談番号無しのworkが存在する場合、商談番号付与
        if (hasNumberlessWorks(newList)) this.assignOpportunityNumber(newList);

        // 案件紐付け
        linkOpportunity(newList);
    }

    // 商談番号付与処理
    private void assignOpportunityNumber(List<work__c> newList) {
        // 売上明細表CSV(work)（売報番号完全一致）で付与試行
        assignByExactMatchedWork(newList);
        // 商談番号無しのworkが存在する場合、売上明細表CSV(work)で付与試行。存在しない場合処理終了。
        if (hasNumberlessWorks(newList)) assignByPartialMatchedWork(newList); else return;
        // 商談番号無しのworkが存在する場合、オーダー管理台帳（売報番号完全一致）で付与試行。存在しない場合処理終了。
        if (hasNumberlessWorks(newList)) assignByExactMatchedOrderManagementLedger(newList); else return;
        // 商談番号無しのworkが存在する場合、オーダー管理台帳で付与試行。存在しない場合処理終了。
        if (hasNumberlessWorks(newList)) assignByPartialMatchedOrderManagementLedger(newList); else return;
        // 商談番号無しのworkが存在する場合、SR情報（売報番号完全一致）で付与試行。存在しない場合処理終了。
        if (hasNumberlessWorks(newList)) assignByExactMatchedSRInfo(newList); else return;
        // 商談番号無しのworkが存在する場合、SR情報で付与試行。存在しない場合処理終了。
        if (hasNumberlessWorks(newList)) assignByPartialMatchedSRInfo(newList); else return;
        // 商談番号無しのworkが存在する場合、案件（売報番号完全一致）で付与試行。存在しない場合処理終了。
        if (hasNumberlessWorks(newList)) assignByExactMatchedOpportunity(newList); else return;
        // 商談番号無しのworkが存在する場合、案件で付与試行。存在しない場合処理終了。
        if (hasNumberlessWorks(newList)) assignByPartialMatchedOpportunity(newList); else return;
        // 商談番号無しのworkが存在する場合、ワーニング設定
        if (hasNumberlessWorks(newList)) setWarning(newList);
    }

    // work内で売報番号（ボディ番号）が一致するレコードの商談番号をworkに付与
    private void assignByExactMatchedWork(List<work__c> newList) {
        // work抽出
        numberedWorkList.addAll([
            SELECT
                OpportunityNumber__c
                , SR_Number__c
            FROM
                work__c
            WHERE
                OpportunityNumber__c != null
                AND SR_Number__c IN :numberlessWorkSRNumberSet
        ]);

        // 商談番号有りのworkのMap作成
        Map<String, work__c> numberedWorkMap = new Map<String, work__c>();
        for (work__c numberedWork : numberedWorkList) {
            numberedWorkMap.put(numberedWork.SR_Number__c, numberedWork);
        }

        // 商談番号が存在しないworkに、売報番号（ボディ番号）が一致したworkの商談番号を設定
        if (!numberlessWorkList.isEmpty() && !numberedWorkMap.isEmpty()){
            for (work__c numberlessWork : numberlessWorkList){
                numberlessWork.OpportunityNumber__c = numberedWorkMap.get(numberlessWork.SR_Number__c)?.OpportunityNumber__c;
            }
        }
    }

    // work内で売報番号（ボディ番号）が一致するレコードの商談番号をworkに付与
    private void assignByPartialMatchedWork(List<work__c> newList) {
        // work抽出
        numberedWorkList.addAll([
            SELECT
                OpportunityNumber__c
                , SR_Number_Body__c
            FROM
                work__c
            WHERE
                OpportunityNumber__c != null
                AND SR_Number_Body__c IN :numberlessWorkSRNumberBodySet
        ]);

        // 商談番号有りのworkのMap作成
        Map<String, work__c> numberedWorkMap = new Map<String, work__c>();
        Set<String> multiMatchedSRNumberBodySet = new Set<String>();
        for (work__c numberedWork : numberedWorkList) {
            if (!numberedWorkMap.containsKey(numberedWork.SR_Number_Body__c)){
                // Map内に存在しない売報番号（ボディ番号）の場合、Mapに格納する
                numberedWorkMap.put(numberedWork.SR_Number_Body__c, numberedWork);
            }
            else if (numberedWorkMap.get(numberedWork.SR_Number_Body__c)?.OpportunityNumber__c != numberedWork.OpportunityNumber__c){
                // Map内に既に存在する売報番号（ボディ番号）且つ紐づく商談番号が異なる場合（= 1つの売報番号（ボディ番号）に異なる複数の商談番号が紐づく場合）除外用にSetへ格納する
                    multiMatchedSRNumberBodySet.add(numberedWork.SR_Number_Body__c);
            }
        }

        // 売報番号（ボディ番号）が一致する商談番号が複数存在する場合、Mapから削除
        for (String multiMatchedSRNumberBody : multiMatchedSRNumberBodySet){
            numberedWorkMap.remove(multiMatchedSRNumberBody);
        }

        // 商談番号が存在しないworkに、売報番号（ボディ番号）が一致したworkの商談番号を設定
        if (!numberlessWorkList.isEmpty() && !numberedWorkMap.isEmpty()){
            for (work__c numberlessWork : numberlessWorkList){
                numberlessWork.OpportunityNumber__c = numberedWorkMap.get(numberlessWork.SR_Number_Body__c)?.OpportunityNumber__c;
            }
        }
    }

    // 売報番号が一致するSR情報の商談番号をworkに付与
    private void assignByExactMatchedSRInfo(List<work__c> newList) {
        // SR情報抽出
        List<SRInfo__c> exactmatchedSRInfoList = new List<SRInfo__c>([
            SELECT
                OP_Number__c
                , SR_Number__c
            FROM
                SRInfo__c
            WHERE
                OP_Number__c != null
                AND SR_Number__c IN :numberlessWorkSRNumberSet
        ]);

        // 商談番号有りのSR情報のMap作成
        Map<String, SRInfo__c> numberedSRInfoMap = new Map<String, SRInfo__c>();
        for (SRInfo__c exactmatchedSRInfo : exactmatchedSRInfoList) {
            numberedSRInfoMap.put(exactmatchedSRInfo.SR_Number__c, exactmatchedSRInfo);
        }

        // 商談番号が存在しないworkに、売報番号（ボディ番号）が一致したSR情報の商談番号を設定
        if (!numberlessWorkList.isEmpty() && !numberedSRInfoMap.isEmpty()){
            for (work__c numberlessWork : numberlessWorkList){
                numberlessWork.OpportunityNumber__c = numberedSRInfoMap.get(numberlessWork.SR_Number__c)?.OP_Number__c;
            }
        }
    }

    // 売報番号（ボディ番号）が一致するSR情報の商談番号をworkに付与
    private void assignByPartialMatchedSRInfo(List<work__c> newList) {
        // SR情報抽出
        List<SRInfo__c> partialMatchedSRInfoList = new List<SRInfo__c>([
            SELECT
                OP_Number__c
                , SR_Number_Body__c
            FROM
                SRInfo__c
            WHERE
                OP_Number__c != null
                AND SR_Number_Body__c IN :numberlessWorkSRNumberBodySet
        ]);

        // 商談番号有りのSR情報のMap作成
        Map<String, SRInfo__c> numberedSRInfoMap = new Map<String, SRInfo__c>();
        Set<String> multiMatchedSRNumberBodySet = new Set<String>();
        for (SRInfo__c partialMatchedSRInfo : partialMatchedSRInfoList) {
            if (!numberedSRInfoMap.containsKey(partialMatchedSRInfo.SR_Number_Body__c)){
                // Map内に存在しない売報番号（ボディ番号）の場合、Mapに格納する
                numberedSRInfoMap.put(partialMatchedSRInfo.SR_Number_Body__c, partialMatchedSRInfo);
            }
            else if (numberedSRInfoMap.get(partialMatchedSRInfo.SR_Number_Body__c)?.OP_Number__c != partialMatchedSRInfo.OP_Number__c){
                // Map内に既に存在する売報番号（ボディ番号）且つ紐づく商談番号が異なる場合（= 1つの売報番号（ボディ番号）に異なる複数の商談番号が紐づく場合）除外用にSetへ格納する
                    multiMatchedSRNumberBodySet.add(partialMatchedSRInfo.SR_Number_Body__c);
            }
        }

        // 売報番号（ボディ番号）が一致する商談番号が複数存在する場合、Mapから削除
        for (String multiMatchedSRNumberBody : multiMatchedSRNumberBodySet){
            numberedSRInfoMap.remove(multiMatchedSRNumberBody);
        }

        // 商談番号が存在しないworkに、売報番号（ボディ番号）が一致したSR情報の商談番号を設定
        if (!numberlessWorkList.isEmpty() && !numberedSRInfoMap.isEmpty()){
            for (work__c numberlessWork : numberlessWorkList){
                numberlessWork.OpportunityNumber__c = numberedSRInfoMap.get(numberlessWork.SR_Number_Body__c)?.OP_Number__c;
            }
        }
    }

    // 売報番号が一致する案件の商談番号をworkに付与
    private void assignByExactMatchedOpportunity(List<work__c> newList) {
        // 案件抽出
        List<Opportunity> exactMatchedOpportunityList = new List<Opportunity>([
            SELECT
                OpportunityNumber_Hyphenless__c
                , SR_Number_Main__c
            FROM
                Opportunity
            WHERE
                OpportunityNumber_Hyphenless__c != null
                AND SR_Number_Main__c IN :numberlessWorkSRNumberSet
        ]);

        // 商談番号有りの案件のMap作成
        Map<String, Opportunity> numberedOpportunityMap = new Map<String, Opportunity>();
        for (Opportunity exactMatchedOpportunity : exactMatchedOpportunityList) {
            numberedOpportunityMap.put(exactMatchedOpportunity.SR_Number_Main__c, exactMatchedOpportunity);
        }

        // 商談番号が存在しないworkに、売報番号が一致した案件の商談番号を設定
        if (!numberlessWorkList.isEmpty() && !numberedOpportunityMap.isEmpty()){
            for (work__c numberlessWork : numberlessWorkList){
                numberlessWork.OpportunityNumber__c = numberedOpportunityMap.get(numberlessWork.SR_Number__c)?.OpportunityNumber_Hyphenless__c;
            }
        }
    }

    // 売報番号（ボディ番号）が一致する案件の商談番号をworkに付与
    private void assignByPartialMatchedOpportunity(List<work__c> newList) {
        // 案件抽出
        List<Opportunity> partialMatchedOpportunityList = new List<Opportunity>([
            SELECT
                OpportunityNumber_Hyphenless__c
                , SR_Number_Body__c
            FROM
                Opportunity
            WHERE
                OpportunityNumber_Hyphenless__c != null
                AND SR_Number_Body__c IN :numberlessWorkSRNumberBodySet
        ]);

        // 商談番号有りの案件のMap作成
        Map<String, Opportunity> numberedOpportunityMap = new Map<String, Opportunity>();
        Set<String> multiMatchedSRNumberBodySet = new Set<String>();
        for (Opportunity partialMatchedOpportunity : partialMatchedOpportunityList) {
            if (!numberedOpportunityMap.containsKey(partialMatchedOpportunity.SR_Number_Body__c)){
                // Map内に存在しない売報番号（ボディ番号）の場合、Mapに格納する
                numberedOpportunityMap.put(partialMatchedOpportunity.SR_Number_Body__c, partialMatchedOpportunity);
            }
            else if (numberedOpportunityMap.get(partialMatchedOpportunity.SR_Number_Body__c)?.OpportunityNumber_Hyphenless__c != partialMatchedOpportunity.OpportunityNumber_Hyphenless__c){
                    // Map内に既に存在する売報番号（ボディ番号）且つ紐づく商談番号が異なる場合（= 1つの売報番号（ボディ番号）に異なる複数の商談番号が紐づく場合）除外用にSetへ格納する
                    multiMatchedSRNumberBodySet.add(partialMatchedOpportunity.SR_Number_Body__c);
            }
        }

        // 売報番号（ボディ番号）が一致する商談番号が複数存在する場合、Mapから削除
        for (String multiMatchedSRNumberBody : multiMatchedSRNumberBodySet){
            numberedOpportunityMap.remove(multiMatchedSRNumberBody);
        }

        // 商談番号が存在しないworkに、売報番号（ボディ番号）が一致した案件の商談番号を設定
        if (!numberlessWorkList.isEmpty() && !numberedOpportunityMap.isEmpty()){
            for (work__c numberlessWork : numberlessWorkList){
                numberlessWork.OpportunityNumber__c = numberedOpportunityMap.get(numberlessWork.SR_Number_Body__c)?.OpportunityNumber_Hyphenless__c;
            }
        }
    }

    // 売報番号が一致するオーダー管理台帳の商談番号をworkに付与
    private void assignByExactMatchedOrderManagementLedger(List<work__c> newList) {
        // オーダー管理台帳抽出
        List<OrderManagementLedger__c> exactMatchedOrderManagementLedgerList = new List<OrderManagementLedger__c>([
            SELECT
                OpportunityNumber__c
                , SR_Number_Hyphenless__c
            FROM
                OrderManagementLedger__c
            WHERE
                OpportunityNumber__c != null
                AND SR_Number_Hyphenless__c IN :numberlessWorkSRNumberSet
        ]);

        // 商談番号有りのオーダー管理台帳のMap作成
        Map<String, OrderManagementLedger__c> numberedOrderManagementLedgerMap = new Map<String, OrderManagementLedger__c>();
        for (OrderManagementLedger__c exactMatchedOrderManagementLedger : exactMatchedOrderManagementLedgerList) {
            numberedOrderManagementLedgerMap.put(exactMatchedOrderManagementLedger.SR_Number_Hyphenless__c, exactMatchedOrderManagementLedger);
        }

        // 商談番号が存在しないworkに、売報番号が一致したオーダー管理台帳の商談番号を設定
        if (!numberlessWorkList.isEmpty() && !numberedOrderManagementLedgerMap.isEmpty()){
            for (work__c numberlessWork : numberlessWorkList){
                numberlessWork.OpportunityNumber__c = numberedOrderManagementLedgerMap.get(numberlessWork.SR_Number__c)?.OpportunityNumber__c.remove('-');
            }
        }
    }

    // 売報番号（ボディ番号）が一致するオーダー管理台帳の商談番号をworkに付与
    private void assignByPartialMatchedOrderManagementLedger(List<work__c> newList) {
        // オーダー管理台帳抽出
        List<OrderManagementLedger__c> partialMatchedOrderManagementLedgerList = new List<OrderManagementLedger__c>([
            SELECT
                OpportunityNumber__c
                , SR_Number_Body__c
            FROM
                OrderManagementLedger__c
            WHERE
                OpportunityNumber__c != null
                AND SR_Number_Body__c IN :numberlessWorkSRNumberBodySet
        ]);

        // 商談番号有りのオーダー管理台帳のMap作成
        Map<String, OrderManagementLedger__c> numberedOrderManagementLedgerMap = new Map<String, OrderManagementLedger__c>();
        Set<String> multiMatchedSRNumberBodySet = new Set<String>();
        for (OrderManagementLedger__c partialMatchedOrderManagementLedger : partialMatchedOrderManagementLedgerList) {
            if (!numberedOrderManagementLedgerMap.containsKey(partialMatchedOrderManagementLedger.SR_Number_Body__c)){
                // Map内に存在しない売報番号（ボディ番号）の場合、Mapに格納する
                numberedOrderManagementLedgerMap.put(partialMatchedOrderManagementLedger.SR_Number_Body__c, partialMatchedOrderManagementLedger);
            }
            else if (numberedOrderManagementLedgerMap.get(partialMatchedOrderManagementLedger.SR_Number_Body__c).OpportunityNumber__c != partialMatchedOrderManagementLedger.OpportunityNumber__c){
                // Map内に既に存在する売報番号（ボディ番号）且つ紐づく商談番号が異なる場合（= 1つの売報番号（ボディ番号）に異なる複数の商談番号が紐づく場合）除外用にSetへ格納する
                    multiMatchedSRNumberBodySet.add(partialMatchedOrderManagementLedger.SR_Number_Body__c);
            }
        }
        // 売報番号（ボディ番号）が一致する商談番号が複数存在する場合、Mapから削除
        for (String multiMatchedSRNumberBody : multiMatchedSRNumberBodySet){
            numberedOrderManagementLedgerMap.remove(multiMatchedSRNumberBody);
        }

        // 商談番号が存在しないworkに、売報番号（ボディ番号）が一意で一致したオーダー管理台帳の商談番号を設定
        if (!numberlessWorkList.isEmpty() && !numberedOrderManagementLedgerMap.isEmpty()){
            for (work__c numberlessWork : numberlessWorkList){
                numberlessWork.OpportunityNumber__c = numberedOrderManagementLedgerMap.get(numberlessWork.SR_Number_Body__c)?.OpportunityNumber__c.remove('-');
            }
        }
    }

    // workのListから『商談番号有りのworkのList』、『商談番号無しのworkのList』、『商談番号無しのworkの売報番号のSet』、『商談番号無しのworkの売報番号（ボディ番号）のSet』を作成し『商談番号無しのworkの有無』を返却
    @testvisible private static Boolean hasNumberlessWorks(List<work__c> workList) {
        numberedWorkList = new List<work__c>();
        numberlessWorkList = new List<work__c>();
        numberlessWorkSRNumberSet = new Set<String>();
        numberlessWorkSRNumberBodySet = new Set<String>();
        for (work__c work : workList) {
            if (String.isBlank(work.OpportunityNumber__c)) {
                numberlessWorkList.add(work);
                numberlessWorkSRNumberSet.add(work.SR_Number__c);
                numberlessWorkSRNumberBodySet.add(work.SR_Number_Body__c);
            }
            else {
                numberedWorkList.add(work);
            }
        }
        return !numberlessWorkList.isEmpty();
    }

    // ワーニング設定
    @testvisible private static void setWarning(List<work__c> workList) {
        // 商談番号が付与できていないworkにワーニング設定
        for (work__c work : workList){
            if (work.OpportunityNumber__c == null){
                work.Warning__c = '商談番号を付与できませんでした。';
            }
        }
    }

    // 案件紐付け処理
    private void linkOpportunity(List<work__c> newList) {
        // 商談番号が登録されているworkのListと商談番号のSetを作成
        List<work__c> numberedWorkList = new List<work__c>();
        Set<String> opportunityNumberSet = new Set<String>();
        for (work__c work : newList) {
            if (!String.isBlank(work.OpportunityNumber__c)) {
                numberedWorkList.add(work);
                opportunityNumberSet.add(work.OpportunityNumber__c);
            }
        }

        // 案件抽出
        List<Opportunity> matchedOpportunityList = new List<Opportunity>([
            SELECT
                Id
                , OpportunityNumber_Hyphenless__c
            FROM
                Opportunity
            WHERE
                OpportunityNumber_Hyphenless__c IN :opportunityNumberSet
        ]);

        // workに紐付ける案件のMapを作成
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
        for (Opportunity matchedOpportunity : matchedOpportunityList) {
            opportunityMap.put(matchedOpportunity.OpportunityNumber_Hyphenless__c, matchedOpportunity);
        }

        // workに商談番号が一致する案件を紐付け
        if (!numberedWorkList.isEmpty() && !opportunityMap.isEmpty()){
            for (work__c numberedWork : numberedWorkList){
                numberedWork.Opportunity__c = opportunityMap.get(numberedWork.OpportunityNumber__c)?.Id;
                if (numberedWork.Opportunity__c == null){
                    numberedWork.Warning__c = 'この商談番号を持つ案件が見つかりませんでした。';
                }
            }
        }
    }

    /**
     * @description 登録後のトリガーハンドラ。
     * @param workList 登録したworkデータ
     */
    public void onAfterInsert(List<work__c> newList) {
        upsertSRInfoByWork(newList);
    }

    private void upsertSRInfoByWork(List<work__c> workList) {
        // work反映先特定番号（売報番号＋J項番号）のSet作成 UpsertByWorkTargetIdNumber__c
        Set<String> upsertByWorkTargetIdNumberSet = new Set<String>();
        for (work__c work : workList) {
            upsertByWorkTargetIdNumberSet.add(work.SR_Number__c + work.J_Number__c);
        }

        // SR情報のMap作成
        List<SRInfo__c> matchedSRInfoList = new List<SRInfo__c>([
            SELECT
                Id
                , UpsertByWorkTargetIdNumber__c
                , Result_SalesDate__c
                , Result_SRCP__c
                , Result_SRWC__c
                , Result_Difference__c
                , Result_AdditionalCost__c
            FROM
                SRInfo__c
            WHERE
                UpsertByWorkTargetIdNumber__c IN :upsertByWorkTargetIdNumberSet
        ]);

        Map<String, SRInfo__c> sRInfoMap = new Map<String, SRInfo__c>();
        for (SRInfo__c matchedSRInfo : matchedSRInfoList) {
            sRInfoMap.put(matchedSRInfo.UpsertByWorkTargetIdNumber__c, matchedSRInfo);
        }

        Date lastMonthEnd = Date.newInstance(Date.today().year(), Date.today().month(), 0);

        // for List でInsertとUpdate分離
        for (work__c work : workList) {
            // update
            if (sRInfoMap.get(work.SR_Number__c + work.J_Number__c) != null) {
                SRInfo__c u_SRInfo = sRInfoMap.get(work.SR_Number__c + work.J_Number__c);
                //  受注後最新
                if (work.OpportunityType__c == '手持') {
                    // 「案件種別名称」が”手持”
                    u_SRInfo.Latest_Forecast_SRCP__c = work.FinalForecastCP_ResultCP__c;      // 最終予想CP（最新）   ← 最終予想ＣＰ売上実績ＣＰ
                    u_SRInfo.Latest_Forecast_SRWC__c = work.PriorityWC_ResultWC__c;           // 最終予想WC（最新）   ← 優先ＷＣ売上実績ＷＣ
                    if (work.LatestRegistrationDate__c <= lastMonthEnd) {
                        // 「最新登録年月日」が前月以前
                        u_SRInfo.Latest_SRCP__c = work.SRCP__c;                               // SRCP（最新）        ← SRCP
                        u_SRInfo.Latest_SRWC__c = work.SRWC__c;                               // SRWC（最新）        ← SRWC
                        u_SRInfo.Latest_SRInfoUpdateDate__c = work.LatestRegistrationDate__c; // SR情報取得日（最新） ← 最新登録年月日
                    }
                }
                // 売上実績
                if (work.OpportunityType__c == '実績') {
                     // 「案件種別名称」が”実績”
                    if ((u_SRInfo.Result_SalesDate__c == null || u_SRInfo.Result_SalesDate__c == work.PlannedSalesDate__c)
                    && work.PlannedSalesDate__c <= lastMonthEnd) {
                        // CRMの売上年月日がnullまたは「売上（予定）年月日」と一致し、且つ「売上（予定）年月日」が前月以前
                        if (work.ReasonName__c != '締追') {
                            // 「事由名称」が”締追”ではない
                            u_SRInfo.Result_SRCP__c = work.FinalForecastCP_ResultCP__c;   // 売上実績CP ← 最終予想ＣＰ売上実績ＣＰ
                            u_SRInfo.Result_SRWC__c = work.PriorityWC_ResultWC__c;        // 売上実績WC ← 優先ＷＣ売上実績ＷＣ
                            if (u_SRInfo.Result_SalesDate__c == null){
                                // 売上年月日がnull
                                u_SRInfo.Result_SalesDate__c = work.PlannedSalesDate__c; // 売上年月日 ← 売上(予定)年月日
                            }
                        }    

                        if (work.ReasonName__c == '締追') {
                            // 「事由名称」が”締追”
                            u_SRInfo.Result_Difference__c = work.DeadlineDifference__c; // 締切差異 ← 締切差異
                            u_SRInfo.Result_AdditionalCost__c = work.AdditionalCost__c; // 追加原価 ← 追加原価
                        }
                        else if (work.ReasonName__c == '解約') {
                            // 「事由名称」が”解約”の場合、受注後最新と売上実績の金額情報をすべて0にする
                            u_SRInfo.Latest_SRCP__c = 0;             // SRCP（最新） ← 0
                            u_SRInfo.Latest_Forecast_SRCP__c = 0;    // 最終予想CP（最新） ← 0
                            u_SRInfo.Latest_SRWC__c = 0;             // SRWC（最新） ← 0
                            u_SRInfo.Latest_Forecast_SRWC__c = 0;    // 最終予想WC（最新） ← 0

                            u_SRInfo.Result_SRCP__c = 0;             // 売上実績CP ← 0
                            u_SRInfo.Result_SRWC__c = 0;             // 売上実績WC ← 0
                            u_SRInfo.Result_Difference__c = 0;       // 締切差異 ← 0
                            u_SRInfo.Result_AdditionalCost__c = 0;   // 追加原価 ← 0
                        }
                    }
                    else if (work.PlannedSalesDate__c > u_SRInfo.Result_SalesDate__c) {
                        // 「売上（予定）年月日」がCRMの売上年月日より後の月の場合は加算する
                        u_SRInfo.Result_SRCP__c += work.FinalForecastCP_ResultCP__c;   // 売上実績CP ← 最終予想ＣＰ売上実績ＣＰ
                        u_SRInfo.Result_SRWC__c += work.PriorityWC_ResultWC__c;        // 売上実績WC ← 優先ＷＣ売上実績ＷＣ
                        if (work.ReasonName__c == '締追') {
                            // 「事由名称」が”締追”
                            if(u_SRInfo.Result_Difference__c == null || u_SRInfo.Result_Difference__c == 0){
                                // CRMの売上年月日の翌日以降に初めて締切差異が発生した場合、移送する
                                u_SRInfo.Result_Difference__c = work.DeadlineDifference__c; // 締切差異 ← 締切差異
                            }
                            
                            if(u_SRInfo.Result_AdditionalCost__c == null || u_SRInfo.Result_AdditionalCost__c == 0){
                                // CRMの売上年月日の翌日以降に初めて追加原価が発生した場合、移送する
                                u_SRInfo.Result_AdditionalCost__c = work.AdditionalCost__c; // 追加原価 ← 追加原価
                            }
                            else {
                                // 既に追加原価が移送されている場合、加算する
                                u_SRInfo.Result_AdditionalCost__c += work.AdditionalCost__c; // 追加原価 ← 追加原価
                            }
                        }
                        else if (work.ReasonName__c == '解約') {
                            // 「事由名称」が”解約”の場合、受注後最新と売上実績の金額情報をすべて0にする
                            u_SRInfo.Latest_SRCP__c = 0;             // SRCP（最新） ← 0
                            u_SRInfo.Latest_Forecast_SRCP__c = 0;    // 最終予想CP（最新） ← 0
                            u_SRInfo.Latest_SRWC__c = 0;             // SRWC（最新） ← 0
                            u_SRInfo.Latest_Forecast_SRWC__c = 0;    // 最終予想WC（最新） ← 0

                            u_SRInfo.Result_SRCP__c = 0;             // 売上実績CP ← 0
                            u_SRInfo.Result_SRWC__c = 0;             // 売上実績WC ← 0
                            u_SRInfo.Result_Difference__c = 0;       // 締切差異 ← 0
                            u_SRInfo.Result_AdditionalCost__c = 0;   // 追加原価 ← 0
                        }
                    }
                    sRInfoMap.put(u_SRInfo.UpsertByWorkTargetIdNumber__c, u_SRInfo); 
                }
            }
            else {
                // insert
                SRInfo__c i_sRInfo = new SRInfo__c(
                    // 基本情報
                    AffiliationName__c = work.AffiliationName__c                            // 所属名称   ← 所属名称
                    , ContactPersonName__c = work.ContactPersonName__c                      // 担当者名称 ← 担当者名称
                    , SR_Number__c = work.SR_Number__c                                      // 売報番号   ← 売報番号
                    , Subject__c = work.Subject__c                                          // 件名       ← 向先件名
                    , OrderingSource__c = work.Orderer__c                                   // 注文元     ← 注文元名称
                    , J_Number__c = work.J_Number__c                                        // J項番号    ← Ｊ項番号
                    , LocationName__c = work.LocationName__c                                // 場所名称   ← 場所名称
                    , Opportunity__c = work.Opportunity__c                                  // 案件       ← 案件
                    , OP_Number__c = work.OpportunityNumber__c                              // 商談番号   ← 商談番号
                    , EntryDate__c =Date.today()                                            // 取込日     ← (処理実行日)
                    , Warning__c = work.Warning__c                                          // ワーニング ← ワーニング
                    , UpsertByWorkTargetIdNumber__c = work.SR_Number__c + work.J_Number__c  // work反映先特定番号（売報番号＋J項番号） ← 売報番号 + Ｊ項番号
                );
                // 受注時（手持）
                if (work.OpportunityType__c == '手持' && work.PlannedOrderDate__c <= lastMonthEnd) {
                    // 「受注（予定）年月日」が前月以前の場合に移送する
                    i_sRInfo.Order_SRCP__c = work.SRCP__c;                                // SRCP（受注時）       ← SRCP
                    i_sRInfo.Order_Forecast_SRCP__c = work.FinalForecastCP_ResultCP__c;   // 最終予想CP（受注時） ← 最終予想ＣＰ売上実績ＣＰ
                    i_sRInfo.Order_SRWC__c = work.SRWC__c;                                // SRWC（受注時）       ← SRWC
                    i_sRInfo.Order_Forecast_SRWC__c = work.PriorityWC_ResultWC__c;        // 最終予想WC（受注時） ← 優先ＷＣ売上実績ＷＣ
                    i_sRInfo.Order_OrderDate__c = work.PlannedOrderDate__c;               // 受注年月日           ← 受注(予定)年月日

                    // 初回は「受注時」の値を「受注後最新」にも移送する
                    i_sRInfo.Latest_SRCP__c = work.SRCP__c;                                 // SRCP（最新）        ← SRCP
                    i_sRInfo.Latest_Forecast_SRCP__c = work.FinalForecastCP_ResultCP__c;    // 最終予想CP（最新）   ← 最終予想ＣＰ売上実績ＣＰ
                    i_sRInfo.Latest_SRWC__c = work.SRWC__c;                                 // SRWC（最新）        ← SRWC
                    i_sRInfo.Latest_Forecast_SRWC__c = work.PriorityWC_ResultWC__c;         // 最終予想WC（最新）   ← 優先ＷＣ売上実績ＷＣ
                    i_sRInfo.Latest_SRInfoUpdateDate__c = work.LatestRegistrationDate__c;   // SR情報取得日（最新） ← 最新登録年月日
                }
                // 受注時（実績）
                if (work.OpportunityType__c == '実績' && work.PlannedSalesDate__c <= lastMonthEnd) {
                    // 「売上（予定）年月日」が前月以前の場合に移送する
                    i_sRInfo.Order_SRCP__c = work.SRCP__c;                                  // SRCP（受注時）       ← SRCP
                    i_sRInfo.Order_Forecast_SRCP__c = work.FinalForecastCP_ResultCP__c;     // 最終予想CP（受注時） ← 最終予想ＣＰ売上実績ＣＰ
                    i_sRInfo.Order_SRWC__c = work.SRWC__c;                                  // SRWC（受注時）       ← SRWC
                    i_sRInfo.Order_Forecast_SRWC__c = work.PriorityWC_ResultWC__c;          // 最終予想WC（受注時） ← 優先ＷＣ売上実績ＷＣ
                    i_sRInfo.Order_OrderDate__c = work.NewRegistrationDate__c;              // 受注年月日           ← 新規登録年月日

                    // 初回は「受注時」の値を「受注後最新」にも移送する
                    i_sRInfo.Latest_SRCP__c = work.SRCP__c;                                 // SRCP（最新）        ← SRCP
                    i_sRInfo.Latest_Forecast_SRCP__c = work.FinalForecastCP_ResultCP__c;    // 最終予想CP（最新）   ← 最終予想ＣＰ売上実績ＣＰ
                    i_sRInfo.Latest_SRWC__c = work.SRWC__c;                                 // SRWC（最新）        ← SRWC
                    i_sRInfo.Latest_Forecast_SRWC__c = work.PriorityWC_ResultWC__c;         // 最終予想WC（最新）   ← 優先ＷＣ売上実績ＷＣ
                    i_sRInfo.Latest_SRInfoUpdateDate__c = work.LatestRegistrationDate__c;   // SR情報取得日（最新） ← 最新登録年月日

                    i_sRInfo.Result_SRCP__c = work.FinalForecastCP_ResultCP__c;             // 売上実績CP ← 最終予想ＣＰ売上実績ＣＰ
                    i_sRInfo.Result_SRWC__c = work.PriorityWC_ResultWC__c;                  // 売上実績WC ← 優先ＷＣ売上実績ＷＣ
                    i_sRInfo.Result_SalesDate__c = work.PlannedSalesDate__c;                // 売上年月日 ← 売上(予定)年月日
                }
                sRInfoMap.put(i_sRInfo.UpsertByWorkTargetIdNumber__c, i_sRInfo);
            }
        }
        upsert sRInfoMap.values() UpsertByWorkTargetIdNumber__c;
    }
}