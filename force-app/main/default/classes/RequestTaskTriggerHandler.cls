public without sharing class RequestTaskTriggerHandler {

    // 例外発生テスト時のみ使用するフラグ
    public static Boolean errorHappenFlg = false;

    public void isAfterUpdate(List<RequestTask__c> triggerNew, Map<Id, RequestTask__c> triggerOldMap){

        Savepoint sp = Database.setSavepoint();
        try{
            List<Id> targetIdList = new List<Id>();
            for(RequestTask__c rt : triggerNew){
                // 帳票出力時に依頼タスク.帳票出力済みフラグをtrueに更新する場合はレコードロック解除対象としない。
                if(!triggerOldMap.get(rt.Id).DocumentOutputFlag__c && rt.DocumentOutputFlag__c){
                    system.debug('@@帳票出力時に依頼タスク.帳票出力済みフラグをtrueに更新する場合はレコードロック解除対象としない。');
                    continue;
                }
                // 未承認アラート番号が値ありからnullに更新される、かつ更新後のレコード.状況が「」の場合はレコードロック解除対象としない。
                if(triggerOldMap.get(rt.Id).UnapprovedRemindNumber__c != null && rt.UnapprovedRemindNumber__c == null && rt.Status__c == '依頼先対応済/依頼完了'){
                    system.debug('@@未承認アラート番号が値ありからnullに更新される、かつ更新後のレコード.状況が「」の場合はレコードロック解除対象としない。');
                    continue;
                }
                
                if(rt.ApprovalPattern__c == '承認者手動設定' &&
                    (
                        (String.isBlank(rt.Approver2__c) && triggerOldMap.get(rt.Id).UnapprovedRemindNumber__c == 1 && rt.UnapprovedRemindNumber__c == 2) ||
                        (String.isBlank(rt.Approver3__c) && triggerOldMap.get(rt.Id).UnapprovedRemindNumber__c == 2 && rt.UnapprovedRemindNumber__c == 3) ||
                        (String.isBlank(rt.Approver4__c) && triggerOldMap.get(rt.Id).UnapprovedRemindNumber__c == 3 && rt.UnapprovedRemindNumber__c == 4) ||
                        (String.isBlank(rt.Approver5__c) && triggerOldMap.get(rt.Id).UnapprovedRemindNumber__c == 4 && rt.UnapprovedRemindNumber__c == 5)
                    )){
                        system.debug('@@手動設定のときのスキップ');
                        continue;
                }
                // 製作所・プラ建対応: 承認申請時に項目自動更新で依頼タスク.申請者のメールアドレスが入力され、却下/取下時には空白値となる。
                if((String.isBlank(triggerOldMap.get(rt.Id).ApplicantEmail__c) && !String.isBlank(rt.ApplicantEmail__c)) ||
                    (triggerOldMap.get(rt.Id).UnapprovedRemindNumber__c != rt.UnapprovedRemindNumber__c && rt.UnapprovedRemindNumber__c != null && rt.Status__c != '依頼先対応済/依頼完了')){
                        system.debug('@@targetIdListにIDを追加');
                        targetIdList.add(rt.Id);
                }
                system.debug('@@targetIdList: ' + targetIdList);
            }
            if(!targetIdList.isEmpty()){
                doUnlock(targetIdList);
            }
            // テスト実行時、かつ例外発生フラグがtrueのときに例外発生
            if(Test.isRunningTest() && errorHappenFlg){
                throw new  ApprovalProcessException();
            }
        } catch (Exception e){
            Database.rollback(sp);
            triggerNew[0].addError('エラーが発生しました。承認申請を再度実行してください。エラーが繰り返す場合はシステム管理者に連絡してください。', false);
        }
    }

    /**
     * レコードロック解除処理メソッド
     * @param List<Id> targetIdList レコードロック解除処理対象依頼タスクIDリスト
     */
    @future
    private static void doUnlock(List<Id> targetIdList){

        Approval.UnLockResult[] results = Approval.unlock(targetIdList, true);
        System.debug('非同期処理によるロック解除操作の対象件数 = ' + results.size());
    }
}