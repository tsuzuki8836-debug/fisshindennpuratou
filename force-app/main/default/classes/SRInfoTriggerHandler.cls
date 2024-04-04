/**
 * SR情報トリガーハンドラー
 */
public class SRInfoTriggerHandler {

    // トリガ二重起動回避
    public static boolean firstRun = true;
    // ユーザ
    private static User u;
    // プロファイル名
    private static final String PROFILE_NAME_HANJI = '販事';
    private static final String PROFILE_NAME_DIVISION_ADMIN = '部門管理者';
    private static final String UPD_ERROR_MESSAGE = '案件の「最終SR集計日時」を更新できませんでした。案件の入力規則エラーが起きていないか確認してください。';

    /**
     * 作成前処理
     */
    public void onBeforeInsert(List<SRInfo__c> srList) {
        
        // 商談番号を書き換える
        this.updateSRInfo(srList);
    }

    /**
     * 更新前処理
     */
    public void onBeforeUpdate(List<SRInfo__c> srList) {
        
        // 商談番号を書き換える
        this.updateSRInfo(srList);
    }

    /**
     * 作成後処理
     */
    public void onAfterInsert(List<SRInfo__c> srList) {
        
        // 案件を更新する
        this.updateOpportunity(new List<SRInfo__c>(),srList);
    }

    /**
     * 更新後処理
     */
    public void onAfterUpdate(List<SRInfo__c> srOldList,List<SRInfo__c> srNewList) {

        // 案件を更新する
        this.updateOpportunity(srOldList,srNewList);
    }

    /**
     * 削除後処理
     */
    public void onAfterDelete(List<SRInfo__c> oldList) {

        // 案件を更新する
        this.updateOpportunity(oldList,new List<SRInfo__c>());
    }

    /**
     * 案件を更新する
     */
    private void updateOpportunity(List<SRInfo__c> srOldList,List<SRInfo__c> srNewList) {

        // ユーザ取得
        if (u == null) {
            u = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        }
        // 販事と部門管理者以外は処理を行わない
        if (u.Profile.Name <> PROFILE_NAME_HANJI && u.Profile.Name <> PROFILE_NAME_DIVISION_ADMIN) {
            return;
        }

        Set<String> oppIdSet = new Set<String>();
        
        // SR情報から案件Idを取得してSetに追加する(NewList)
        for (SRInfo__c sr : srNewList) {
            if(String.isNotBlank(sr.Opportunity__c)) {
                oppIdSet.add(sr.Opportunity__c);
            }
        }

        // 2023/08/21 TS鈴木追加 PUS_CRM-491 SR情報と案件の紐付け解除時に案件のSR金額情報をnullに戻したい
        // SR情報から案件Idを取得してSetに追加する(OldList)
        for (SRInfo__c sr : srOldList) {
            if(String.isNotBlank(sr.Opportunity__c)) {
                oppIdSet.add(sr.Opportunity__c);
            }
        }
        
        // 案件Idを元に案件を取得してMapを生成する
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, LastSRAggregateDate__c FROM Opportunity WHERE Id IN: oppIdSet]);

        // 現在日時を取得する
        Datetime dt = Datetime.now();

        for (SRInfo__c sr : srNewList) {
            // SR情報に案件Idが設定されている
            if (String.isNotBlank(sr.Opportunity__c)) {              
                // 対象の案件が存在する場合
                if (oppMap.keyset().contains(sr.Opportunity__c)) {
                    // 案件.最終SR集計日時に現在日時をセットする
                    oppMap.get(sr.Opportunity__c).LastSRAggregateDate__c = dt;
                }
            }
        }

        // 2023/08/21 TS鈴木追加 PUS_CRM-491 SR情報と案件の紐付け解除時に案件のSR金額情報をnullに戻したい
        for (SRInfo__c sr : srOldList) {
            // SR情報に案件Idが設定されている
            if (String.isNotBlank(sr.Opportunity__c)) {              
                // 対象の案件が存在する場合
                if (oppMap.keyset().contains(sr.Opportunity__c)) {
                    // 案件.最終SR集計日時に現在日時をセットする
                    oppMap.get(sr.Opportunity__c).LastSRAggregateDate__c = dt;
                }
            }
        }

        try {
            // 案件を更新する
            if (oppMap.values().size() > 0) {
                update oppMap.values();
            }
        }  catch (Exception e) {
            if(srNewList.size()>0){
                srNewList[0].addError(UPD_ERROR_MESSAGE + '【エラー詳細】' + e.getMessage());
            }else if(srOldList.size()>0){
                srOldList[0].addError(UPD_ERROR_MESSAGE + '【エラー詳細】' + e.getMessage());
            }
        }
    }

    /**
     * SR情報を更新する
     */
    private void updateSRInfo(List<SRInfo__c> srList) {

        // ユーザ取得
        if (u == null) {
            u = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        }
        // 販事と部門管理者以外は処理を行わない
        if (u.Profile.Name <> PROFILE_NAME_HANJI && u.Profile.Name <> PROFILE_NAME_DIVISION_ADMIN) {
            return;
        }

        Set<String> oppIdSet = new Set<String>();
        
        // SR情報から案件Idを取得してSetに追加する
        for (SRInfo__c sr : srList) {
            if(String.isNotBlank(sr.Opportunity__c)) {
                oppIdSet.add(sr.Opportunity__c);
            }
        }

        // 案件Idを元に案件を取得してMapを生成する
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, OpportunityNumber_Hyphenless__c FROM Opportunity WHERE Id IN: oppIdSet]);

        for (SRInfo__c sr :srList) {
            // SR情報に案件Idが設定されている
            if (String.isNotBlank(sr.Opportunity__c)) {              
                // 対象の案件が存在する場合
                if (oppMap.keyset().contains(sr.Opportunity__c)) {
                    // SR情報.商談番号に案件.商談番号をセットする
                    sr.OP_Number__c = oppMap.get(sr.Opportunity__c).OpportunityNumber_Hyphenless__c;
                }
            } else {
                sr.OP_Number__c = '';
            }
        }
    }

}