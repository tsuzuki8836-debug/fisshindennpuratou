@isTest public with sharing class RequestFormOutputControllerTest {
    /**
     * 依頼タスク帳票出力処理テスト
     * @description Lightning コンポーネントから Apex メソッドへアクセスするためだけのクラス・メソッドにつき、コードカバーのみを目的とする。
     */
    @isTest private static void requestFormOutputTest() {
        // preparation
        String result;
        String errorMessage;

        Account account = new Account(
            Name = 'Test Account'
            , Type = 'エンドユーザー'

            // insertに必要な項目
            , RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND name = '事業所'].Id
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            // insertに必要な項目
            AccountId = account.Id
            , CloseDate = Date.newInstance(2000, 1, 2)
            , Name = 'Test Opp'
            , Client__c = account.Id
            , StageName = '基本計画'
            , ConstructionDistinction__c = '新設'
        );
        insert opportunity;

        RequestTask__c requestTask = new RequestTask__c(
            // insertに必要な項目
            DueDate__c = Date.newInstance(2025, 5, 10)
            , Requester__c = '本社　施設'
            , RequestDestination__c = 'その他'
            , RequestDestination_other__c = 'テスト依頼先場所'
            , TaskCategory__c = '提案書作成依頼'
            , Opportunity__c = opportunity.Id
        );
        insert requestTask;

        Test.setMock(HttpCalloutMock.class, new SvfTokenHttpCalloutMock(false, 401));

        // execution
        Test.startTest();
        try {
            result = RequestFormOutputController.requestFormOutput(requestTask.Id);
        } catch(Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assert(String.isNotEmpty(errorMessage), '例外が発生するようにテストメソッドを修正してください。');
    }
}