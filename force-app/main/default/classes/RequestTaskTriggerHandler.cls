public without sharing class RequestTaskTriggerHandler {

    // 例外発生テスト時のみ使用するフラグ
    public static Boolean errorHappenFlg = false;

    public void isBeforeInsert(List<RequestTask__c> triggerNew){
        // 状況の更新
        this.updateStatus(triggerNew);
    }
    public void isBeforeUpdate(List<RequestTask__c> triggerNew, Map<Id, RequestTask__c> triggerOldMap){
        // 承認履歴項目の初期化
        this.clearApprovalHsitories(triggerNew, triggerOldMap);
        // 状況の更新
        this.updateStatus(triggerNew);
    }

    public void isAfterUpdate(List<RequestTask__c> triggerNew,Map<Id, RequestTask__c> triggerOldMap){

        // List<RequestTask__c> updateTasks = new List<RequestTask__c>();
        // Set<Id> approveTaskIds = new Set<Id>();
        // for (Id taskId : triggerNewMap.keySet()) {
        //     RequestTask__c newTask = triggerNewMap.get(taskId);
        //     RequestTask__c oldTask = triggerOldMap.get(taskId);
        //     System.debug('newTask='+newTask);
        //     System.debug('oldTask='+oldTask);
        //     if (newTask.Status__c != oldTask.Status__c) {
        //         approveTaskIds.add(newTask.Id);
        //         System.debug('approveTaskIds='+approveTaskIds);
        //     }
        // }

        // if (!approveTaskIds.isEmpty()) {
        //     System.debug('通ってます');
        //     Map<Id, Id> taskIdToAssigneeMap = new Map<Id, Id>();//承認申請のマップ
        //     for (ProcessInstanceWorkItem  workItem : [SELECT Id,ActorId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :approveTaskIds ORDER BY CreatedDate DESC LIMIT 1]) {
        //         System.debug('workItem='+workItem);
        //         if (workItem.ProcessInstanceId !=null) {
        //             taskIdToAssigneeMap.put(workItem.ProcessInstanceId,workItem.actorId);
        //             System.debug('taskIdToAssigneeMap='+taskIdToAssigneeMap);
        //         }
        //     }
        // }

        Savepoint sp = Database.setSavepoint();
        try{
            List<Id> targetIdList = new List<Id>();
            for(RequestTask__c rt : triggerNew){
                // 帳票出力時に依頼タスク.帳票出力済みフラグをtrueに更新する場合はレコードロック解除対象としない。
                if(!triggerOldMap.get(rt.Id).DocumentOutputFlag__c && rt.DocumentOutputFlag__c){
                    system.debug('@@帳票出力時に依頼タスク.帳票出力済みフラグをtrueに更新する場合はレコードロック解除対象としない。');
                    continue;
                }
                // 未承認アラート番号が値ありからnullに更新される、かつ更新後のレコード.状況が「依頼先対応済/依頼完了」の場合はレコードロック解除対象としない。
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
    
    /**
     * 承認履歴項目の初期化
     */
     public void clearApprovalHsitories(List<RequestTask__c> triggerNew, Map<Id, RequestTask__c> triggerOldMap){
        for (RequestTask__c rt: triggerNew) {
            // 申請者が初期化されたタイミング（最終却下・取り消し）で承認履歴関連項目を初期化する
            // ※本来は承認プロセスから直接項目自動更新を実行して処理するが、項目数の上限10を超過したため対応できず
            // 一部依頼タスク更新フローでも対応しているが、日付項目の初期化がうまく動作しないためトリガで更新している
            if (String.isBlank(rt.Applicant__c) && String.isNotBlank(triggerOldMap.get(rt.Id).Applicant__c)) {
                rt.ApplicantRole__c = null;
                rt.ApplicationDatetime__c = null;
                rt.ApprovalDatetime1__c = null;
                rt.ApprovalDatetime2__c = null;
                rt.ApprovalDatetime3__c = null;
                rt.ApprovalDatetime4__c = null;
                rt.ApproverRole1__c = null;
                rt.ApproverRole2__c = null;
                rt.ApproverRole3__c = null;
                rt.ApproverRole4__c = null;
                rt.RequestApprovalDatetime1__c = null;
                rt.RequestApprovalDatetime2__c = null;
                rt.RequestApprovalDatetime3__c = null;
                rt.RequestApprovalDatetime4__c = null;
                rt.RequestApproverRole1__c = null;
                rt.RequestApproverRole2__c = null;
                rt.RequestApproverRole3__c = null;
                rt.RequestApproverRole4__c = null;
            }
        }
    }
    
    /**
     * 状況の更新
     */
    public void updateStatus(List<RequestTask__c> triggerNew){
        for (RequestTask__c rt : triggerNew) {
            // 自部門承認済み・依頼先承認不要の場合に「依頼先対応済/依頼完了」に更新
            if (rt.Status__c != '依頼先対応済/依頼完了' && rt.UserDeptApproved__c && rt.SkipRequestApproval__c) {
                rt.Status__c = '依頼先対応済/依頼完了';
            }            
        }
    }
}