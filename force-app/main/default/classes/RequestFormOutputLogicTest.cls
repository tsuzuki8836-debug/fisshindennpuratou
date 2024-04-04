@isTest public with sharing class RequestFormOutputLogicTest {
    /**
     * @description 依頼区分に応じた処理実行テスト
     */
    private static void executeByTaskCategoryTest(String taskCategory) {
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
            , CloseDate = Date.newInstance(2000, 1, 2) // OpportunityTriggerHandler.setOppItem で EstimatedIssuedDate_01__c に設定される。
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
            , TaskCategory__c = taskCategory
            , Opportunity__c = opportunity.Id
        );
        insert requestTask;
        RequestFormOutputGenerator.getRequestTask(requestTask.Id);

        // execution
        Test.startTest();
        RequestFormOutputLogic.executeByTaskCategory(taskCategory, requestTask.Id);
        Test.stopTest();
    }

    /** 提案書作成依頼 */
    @isTest private static void executeByTaskCategoryTest1() {
        executeByTaskCategoryTest('提案書作成依頼');

        // assertion
        System.assertEquals('①提案業務依頼書', RequestFormOutputLogic.formName, '依頼区分に応じた処理実行が不正です。');
        System.assertNotEquals(null, RequestFormOutputLogic.inputCsv, '依頼区分に応じた処理実行が不正です。');
    }

    /** 見積照会 */
    @isTest private static void executeByTaskCategoryTest2() {
        executeByTaskCategoryTest('見積照会');

        // assertion
        System.assertEquals('②見積照会書', RequestFormOutputLogic.formName, '依頼区分に応じた処理実行が不正です。');
        System.assertNotEquals(null, RequestFormOutputLogic.inputCsv, '依頼区分に応じた処理実行が不正です。');
    }

    /** 写真撮影依頼 */
    @isTest private static void executeByTaskCategoryTest3() {
        executeByTaskCategoryTest('写真撮影依頼');

        // assertion
        System.assertEquals('③写真撮影依頼書', RequestFormOutputLogic.formName, '依頼区分に応じた処理実行が不正です。');
        System.assertNotEquals(null, RequestFormOutputLogic.inputCsv, '依頼区分に応じた処理実行が不正です。');
    }

    /** 搬入依頼 */
    @isTest private static void executeByTaskCategoryTest4() {
        executeByTaskCategoryTest('搬入依頼');

        // assertion
        System.assertEquals('④機器搬入連絡表', RequestFormOutputLogic.formName, '依頼区分に応じた処理実行が不正です。');
        System.assertNotEquals(null, RequestFormOutputLogic.inputCsv, '依頼区分に応じた処理実行が不正です。');
    }

    /** 技派依頼 */
    @isTest private static void executeByTaskCategoryTest5() {
        executeByTaskCategoryTest('技派依頼');

        // assertion
        System.assertEquals('⑤技術員派遣依頼書', RequestFormOutputLogic.formName, '依頼区分に応じた処理実行が不正です。');
        System.assertNotEquals(null, RequestFormOutputLogic.inputCsv, '依頼区分に応じた処理実行が不正です。');
    }

    /** 製作所技術者選定依頼 */
    @isTest private static void executeByTaskCategoryTest6() {
        executeByTaskCategoryTest('製作所技術者選定依頼');

        // assertion
        System.assertEquals('⑥配置技術者選定依頼', RequestFormOutputLogic.formName, '依頼区分に応じた処理実行が不正です。');
        System.assertNotEquals(null, RequestFormOutputLogic.inputCsv, '依頼区分に応じた処理実行が不正です。');
    }

    /** 先行手配依頼 */
    @isTest private static void executeByTaskCategoryTest7() {
        executeByTaskCategoryTest('先行手配依頼');

        // assertion
        System.assertEquals('⑦先行手配依頼書', RequestFormOutputLogic.formName, '依頼区分に応じた処理実行が不正です。');
        System.assertNotEquals(null, RequestFormOutputLogic.inputCsv, '依頼区分に応じた処理実行が不正です。');
    }

    /** 原低依頼 */
    @isTest private static void executeByTaskCategoryTest8() {
        executeByTaskCategoryTest('原低依頼');

        // assertion
        System.assertEquals('⑧原低依頼書', RequestFormOutputLogic.formName, '依頼区分に応じた処理実行が不正です。');
        System.assertNotEquals(null, RequestFormOutputLogic.inputCsv, '依頼区分に応じた処理実行が不正です。');
    }

    /** VRSetForm関数設定テスト */
    @isTest private static void vrSetFormTest() {
        // preparation
        String result;

        // execution
        result = RequestFormOutputLogic.vrSetForm('test.xlsx');

        // assertion
        System.assertEquals('<start>\r\nVrSetForm=form/依頼タスク/test.xlsx\r\n<end>\r\n', result, 'VRSetForm関数設定が不正です。');
    }

    /**
     * @description ファイル名設定処理テスト
     * "SVF雛形_”&"案件名_"&"帳票名_"&"yyyyMMdd"
     */
    @isTest private static void setFileNameTest() {
        // execution
        Test.startTest();
        RequestFormOutputLogic.setFileName('提案書作成依頼', 'テスト案件');
        Test.stopTest();

        // assertion
        System.assertEquals('SVF雛形_テスト案件_null_' + RequestFormOutputLogic.EXECUTED_DATE, RequestFormOutputLogic.fileName, 'ファイル名設定処理が不正です。');
    }

    /**
     * @description ファイルフォーマット設定処理テスト
     */
    private static void setFileFormatTest(String taskCategory) {
        // execution
        Test.startTest();
        RequestFormOutputLogic.setFileFormat(taskCategory);
        Test.stopTest();
    }

    /** 提案書作成依頼 */
    @isTest private static void setFileFormatTest1() {
        setFileFormatTest('提案書作成依頼');

        // assertion
        System.assertEquals('WORD', RequestFormOutputLogic.fileFormat, 'ファイルフォーマット設定処理が不正です。');
        System.assertEquals('.docx', RequestFormOutputLogic.extention, 'ファイルフォーマット設定処理が不正です。');
    }

    /** 見積照会 */
    @isTest private static void setFileFormatTest2() {
        setFileFormatTest('見積照会');

        // assertion
        System.assertEquals('EXCEL', RequestFormOutputLogic.fileFormat, 'ファイルフォーマット設定処理が不正です。');
        System.assertEquals('.xlsx', RequestFormOutputLogic.extention, 'ファイルフォーマット設定処理が不正です。');
    }

    /** 写真撮影依頼書 */
    @isTest private static void setFileFormatTest3() {
        setFileFormatTest('写真撮影依頼');

        // assertion
        System.assertEquals('EXCEL', RequestFormOutputLogic.fileFormat, 'ファイルフォーマット設定処理が不正です。');
        System.assertEquals('.xlsm', RequestFormOutputLogic.extention, 'ファイルフォーマット設定処理が不正です。');
    }

    /** 機器搬入連絡表 */
    @isTest private static void setFileFormatTest4() {
        setFileFormatTest('搬入依頼');

        // assertion
        System.assertEquals('EXCEL', RequestFormOutputLogic.fileFormat, 'ファイルフォーマット設定処理が不正です。');
        System.assertEquals('.xlsx', RequestFormOutputLogic.extention, 'ファイルフォーマット設定処理が不正です。');
    }

    /** 技術員派遣依頼書 */
    @isTest private static void setFileFormatTest5() {
        setFileFormatTest('技派依頼');

        // assertion
        System.assertEquals('WORD', RequestFormOutputLogic.fileFormat, 'ファイルフォーマット設定処理が不正です。');
        System.assertEquals('.docx', RequestFormOutputLogic.extention, 'ファイルフォーマット設定処理が不正です。');
    }

    /** 配置技術者選定依頼 */
    @isTest private static void setFileFormatTest6() {
        setFileFormatTest('製作所技術者選定依頼');

        // assertion
        System.assertEquals('EXCEL', RequestFormOutputLogic.fileFormat, 'ファイルフォーマット設定処理が不正です。');
        System.assertEquals('.xlsx', RequestFormOutputLogic.extention, 'ファイルフォーマット設定処理が不正です。');
    }

    /** 先行手配依頼書 */
    @isTest private static void setFileFormatTest7() {
        setFileFormatTest('先行手配依頼');

        // assertion
        System.assertEquals('EXCEL', RequestFormOutputLogic.fileFormat, 'ファイルフォーマット設定処理が不正です。');
        System.assertEquals('.xlsx', RequestFormOutputLogic.extention, 'ファイルフォーマット設定処理が不正です。');
    }

    /** 原低依頼書 */
    @isTest private static void setFileFormatTest8() {
        setFileFormatTest('原低依頼');

        // assertion
        System.assertEquals('EXCEL', RequestFormOutputLogic.fileFormat, 'ファイルフォーマット設定処理が不正です。');
        System.assertEquals('.xlsx', RequestFormOutputLogic.extention, 'ファイルフォーマット設定処理が不正です。');
    }

    /**
     * @description 帳票出力済みフラグが更新されていることのテスト
     */
    @isTest private static void updateDocumentOutputFlagTest(){
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
            , CloseDate = Date.newInstance(2000, 1, 2) // OpportunityTriggerHandler.setOppItem で EstimatedIssuedDate_01__c に設定される。
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

        // execution
        Test.startTest();
        RequestFormOutputGenerator.updateRequestTaskById(requestTask.Id);
        Test.stopTest();

        // フラグの更新は非同期で実行されるため再度クエリ発行
        RequestTask__c rt = [SELECT DocumentOutputFlag__c FROM RequestTask__c WHERE Id = :requestTask.Id LIMIT 1];
        System.assertEquals(true, rt.DocumentOutputFlag__c, '帳票出力済みフラグが更新されていません。');
    }
}