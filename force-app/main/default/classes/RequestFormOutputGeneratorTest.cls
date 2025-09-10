@isTest public with sharing class RequestFormOutputGeneratorTest {
    private static final Profile PROFILE_SALES = [SELECT Id FROM Profile WHERE Name = '販事'];
    private static final RecordType RECORDTYPE_OFFICE = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND name = '事業所'];

    private static User testManager;
    private static User testUser;
    private static User testApprover1;
    private static User testApprover2;
    private static User testApprover3;

    private static Account testAccount;
    private static PumpStation__c testpumpStation;
    private static Opportunity testOpportunity;
    private static Factory__c testFactory;
    private static RequestTask__c testRequestTask;
    private static Engineer__c testEngineer;
    private static Engineer__c testEngineer2;
    private static ConstructionInfo__c testConstructionInfo;
    private static ConstructionInfo__c testConstructionInfo2;
    private static BidManagement__c testBidManagement;
    private static BidManagement__c testBidManagement2;

    /**
     * @description ユーザデータ作成
     * runAs用の販事ユーザ、そのマネージャ、承認者1~3用のユーザを作成する。
     */
    private static void createUsers(){
        testManager = new User(
            LastName = 'manager'
            , FirstName = 'boss'

            // insertに必要な項目
            , Username = 'manager@RequestFormOutputGeneratorTest.test'
            , Email = 'mail@RequestFormOutputGeneratorTest.test'
            , Alias = 'MGR'
            , TimeZoneSidKey = 'Asia/Tokyo'
            , LocaleSidKey = 'ja_JP'
            , EmailEncodingKey = 'ISO-2022-JP'
            , ProfileId = PROFILE_SALES.Id
            , LanguageLocaleKey = 'ja'
        );
        insert testManager;

        testUser = new User(
            LastName = 'RunAs'
            , FirstName = 'Executer'
            , ManagerId = testManager.Id

            // insertに必要な項目
            , Username = 'runas@RequestFormOutputGeneratorTest.test'
            , Email = 'mail@RequestFormOutputGeneratorTest.test'
            , Alias = 'RunAs'
            , TimeZoneSidKey = 'Asia/Tokyo'
            , LocaleSidKey = 'ja_JP'
            , EmailEncodingKey = 'ISO-2022-JP'
            , ProfileId = PROFILE_SALES.Id
            , LanguageLocaleKey = 'ja'
            , DepartmentAndDivision__c = '01_社会環境事業部'
        );

        testApprover1 = new User(
            LastName = '1'

            // insertに必要な項目
            , Username = 'melcostest1@RequestFormOutputGeneratorTest.test'
            , Email = 'mail@RequestFormOutputGeneratorTest.test'
            , Alias = 'test1'
            , TimeZoneSidKey = 'Asia/Tokyo'
            , LocaleSidKey = 'ja_JP'
            , EmailEncodingKey = 'ISO-2022-JP'
            , ProfileId = PROFILE_SALES.Id
            , LanguageLocaleKey = 'ja'
            , DepartmentAndDivision__c = '01_社会環境事業部'
        );

        testApprover2 = new User(
            LastName = '2'

            // insertに必要な項目
            , Username = 'melcotest2@RequestFormOutputGeneratorTest.test'
            , Email = 'mail@RequestFormOutputGeneratorTest.test'
            , Alias = 'test2'
            , TimeZoneSidKey = 'Asia/Tokyo'
            , LocaleSidKey = 'ja_JP'
            , EmailEncodingKey = 'ISO-2022-JP'
            , ProfileId = PROFILE_SALES.Id
            , LanguageLocaleKey = 'ja'
            , DepartmentAndDivision__c = '01_社会環境事業部'
        );

        testApprover3 = new User(
            LastName = '3'

            // insertに必要な項目
            , Username = 'melcotest3@RequestFormOutputGeneratorTest.test'
            , Email = 'mail@RequestFormOutputGeneratorTest.test'
            , Alias = 'test3'
            , TimeZoneSidKey = 'Asia/Tokyo'
            , LocaleSidKey = 'ja_JP'
            , EmailEncodingKey = 'ISO-2022-JP'
            , ProfileId = PROFILE_SALES.Id
            , LanguageLocaleKey = 'ja'
            , DepartmentAndDivision__c = '01_社会環境事業部'
        );

        List<User> testUserList = new List<User>{
            testUser
            , testApprover1
            , testApprover2
            , testApprover3
        };
        insert testUserList;
    }

    /** 依頼タスク */
        /**
         * @description テスト用依頼タスク作成
         */
        private static void createTestRequestTask() {
            testAccount = new Account(
                Name = 'Test Account'
                , Type = 'エンドユーザー'

                // insertに必要な項目
                , RecordTypeId = RECORDTYPE_OFFICE.Id
            );
            insert testAccount;

            testpumpStation = new PumpStation__c(
                Name = 'テスト機場'
            );
            insert testpumpStation;

            testOpportunity = new Opportunity(
                AccountId = testAccount.Id
                , DistributionChannelsPattern__c = '施主→当社'
                , CloseDate = Date.newInstance(2000, 1, 2) // OpportunityTriggerHandler.setOppItem で EstimatedIssuedDate_01__c に設定される。
                , KOUJI_SYU__c = 'その他'
                , Name = 'Test Opp'
                , OpportunityNote__c = 'テスト案件メモ'
                , OpportunityNumber__c = 'F1234-X567-8'
                , OrderExpectation__c = '1'
                , Order_OrderDate__c = Date.newInstance(2001, 3, 4)
                , PickDivision__c = '本社　施設'
                // , ProposedTechniqueRemarks__c = 'テスト技術提案 備考'
                , PumpStation__c = testpumpStation.Id
                , Result_SalesDate__c = Date.newInstance(2002, 5, 6)
                , SR_CP__c = 7777
                , SR_Number_Main__c = 'A1234Z5670'
                // insertに必要な項目
                , Client__c = testAccount.Id
                , StageName = '基本計画'
                , ConstructionDistinction__c = '新設'
            );
            insert testOpportunity;

            testFactory = new Factory__c(
                Opp1__c = testOpportunity.Id
                , Factory__c = '神電'
                , SR_CP__c = 6666 // opportunity.TotalCP__c に集計される。
                , SRWC__c = 9999 // opportunity.TotalWC__c に集計される。

                // insertに必要な項目
                , CommonRatio1__c= '21% ： 製作所'
            );
            insert testFactory;

            testRequestTask = new RequestTask__c(
                DueDate__c = Date.newInstance(2099, 12, 31)
                , RequestCc1__c = '神電・施設エンジ'
                , RequestCc2__c = '配電・東配計'
                , RequestCc3__c = '伊電・長施営'
                , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                , Requester__c = '本社　施設'
                , RequestTo__c = '神電・社会営'
                , TaskCategory__c = '提案書作成依頼'
                , UserDeptLastApprover__c = '承認者1'
                , Approver1__c = testApprover1.Id
                , Approver2__c = testApprover2.Id
                , Approver3__c = testApprover3.Id
                , Factory__c = testFactory.Id
                , Opportunity__c = testOpportunity.Id

                // insertに必要な項目
                , RequestDestinationCc__c = '神電'
                , RequestDestinationCc2__c = '配電'
                , RequestDestinationCc3__c = '伊電長崎'
                , OwnerId = testUser.Id
            );
            insert testRequestTask;
        }

        /**
         * @description 依頼タスク取得テスト
         */
        @isTest private static void getRequestTaskTest() {
            // preparation
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();

                // execution
                Test.startTest();
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                Test.stopTest();
            }

            // assertion
            System.assertEquals(testRequestTask.DueDate__c, RequestFormOutputGenerator.requestTask.DueDate__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.RequestCc1__c, RequestFormOutputGenerator.requestTask.RequestCc1__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.RequestCc2__c, RequestFormOutputGenerator.requestTask.RequestCc2__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.RequestCc3__c, RequestFormOutputGenerator.requestTask.RequestCc3__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.RequestDestination__c, RequestFormOutputGenerator.requestTask.RequestDestination__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.Requester__c, RequestFormOutputGenerator.requestTask.Requester__c, '依頼タスク取得が不正です。');
            System.assertEquals('神戸製作所', RequestFormOutputGenerator.requestTask.RequestFactoryName__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.RequestTo__c, RequestFormOutputGenerator.requestTask.RequestTo__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.TaskCategory__c, RequestFormOutputGenerator.requestTask.TaskCategory__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.UserDeptLastApprover__c, RequestFormOutputGenerator.requestTask.UserDeptLastApprover__c, '依頼タスク取得が不正です。');
            System.assertEquals(testApprover1.LastName, RequestFormOutputGenerator.requestTask.Approver1__r.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(testApprover2.LastName, RequestFormOutputGenerator.requestTask.Approver2__r.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(testApprover3.LastName, RequestFormOutputGenerator.requestTask.Approver3__r.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(testUser.LastName, RequestFormOutputGenerator.requestTask.CreatedBy.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(testUser.FirstName, RequestFormOutputGenerator.requestTask.CreatedBy.FirstName, '依頼タスク取得が不正です。');
            System.assertEquals(testManager.LastName, RequestFormOutputGenerator.requestTask.CreatedBy.Manager.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(testManager.FirstName, RequestFormOutputGenerator.requestTask.CreatedBy.Manager.FirstName, '依頼タスク取得が不正です。');
            System.assertEquals(testFactory.Factory__c, RequestFormOutputGenerator.requestTask.Factory__r.Factory__c, '依頼タスク取得が不正です。');
            System.assertEquals(testFactory.SR_CP__c, RequestFormOutputGenerator.requestTask.Factory__r.SR_CP__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.Id, RequestFormOutputGenerator.requestTask.Opportunity__c, '依頼タスク取得が不正です。');
            System.assertEquals(testAccount.Name, RequestFormOutputGenerator.requestTask.Opportunity__r.Account.Name, '依頼タスク取得が不正です。');
            System.assertEquals(testAccount.Type, RequestFormOutputGenerator.requestTask.Opportunity__r.Account.Type, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.DistributionChannelsPattern__c, RequestFormOutputGenerator.requestTask.Opportunity__r.DistributionChannelsPattern__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.CloseDate, RequestFormOutputGenerator.requestTask.Opportunity__r.EstimatedIssuedDate_01__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.KOUJI_SYU__c, RequestFormOutputGenerator.requestTask.Opportunity__r.KOUJI_SYU__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.Name, RequestFormOutputGenerator.requestTask.Opportunity__r.Name, '依頼タスク取得が不正です。');
            System.assertNotEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.OppNumber__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.OpportunityNote__c, RequestFormOutputGenerator.requestTask.Opportunity__r.OpportunityNote__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.OpportunityNumber__c, RequestFormOutputGenerator.requestTask.Opportunity__r.OpportunityNumber__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.OrderExpectation__c, RequestFormOutputGenerator.requestTask.Opportunity__r.OrderExpectation__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.CloseDate, RequestFormOutputGenerator.requestTask.Opportunity__r.CloseDate, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.PickDivision__c, RequestFormOutputGenerator.requestTask.Opportunity__r.PickDivision__c, '依頼タスク取得が不正です。');
            // System.assertEquals(testOpportunity.ProposedTechniqueRemarks__c, RequestFormOutputGenerator.requestTask.Opportunity__r.ProposedTechniqueRemarks__c, '依頼タスク取得が不正です。');
            System.assertEquals(testpumpStation.Name, RequestFormOutputGenerator.requestTask.Opportunity__r.PumpStation__r.Name, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.Result_SalesDate__c, RequestFormOutputGenerator.requestTask.Opportunity__r.Result_SalesDate__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.SR_CP__c, RequestFormOutputGenerator.requestTask.Opportunity__r.SR_CP__c, '依頼タスク取得が不正です。');
            System.assertEquals(testOpportunity.SR_Number_Main__c, RequestFormOutputGenerator.requestTask.Opportunity__r.SR_Number_Main__c, '依頼タスク取得が不正です。');
            System.assertEquals(testFactory.SR_CP__c, RequestFormOutputGenerator.requestTask.Opportunity__r.TotalCP__c, '依頼タスク取得が不正です。');
            System.assertEquals(testFactory.SRWC__c, RequestFormOutputGenerator.requestTask.Opportunity__r.TotalWC__c, '依頼タスク取得が不正です。');
            System.assertEquals(testFactory.SRWC__c.divide(testFactory.SR_CP__c, 3) * 100, RequestFormOutputGenerator.requestTask.Opportunity__r.WCPercent__c, '依頼タスク取得が不正です。');
        }

        /**
         * @description 依頼タスク取得テスト 最小限の値設定
         */
        @isTest private static void getRequestTaskTestMin() {
            // preparation
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;

                // execution
                Test.startTest();
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                Test.stopTest();
            }

            // assertion
            System.assertEquals(testRequestTask.DueDate__c, RequestFormOutputGenerator.requestTask.DueDate__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.RequestCc1__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.RequestCc2__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.RequestCc3__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.RequestDestination__c, RequestFormOutputGenerator.requestTask.RequestDestination__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.Requester__c, RequestFormOutputGenerator.requestTask.Requester__c, '依頼タスク取得が不正です。');
            System.assertEquals('神戸製作所', RequestFormOutputGenerator.requestTask.RequestFactoryName__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.RequestTo__c, '依頼タスク取得が不正です。');
            System.assertEquals(testRequestTask.TaskCategory__c, RequestFormOutputGenerator.requestTask.TaskCategory__c, '依頼タスク取得が不正です。');
            System.assertEquals('承認者1', RequestFormOutputGenerator.requestTask.UserDeptLastApprover__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Approver1__r.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Approver2__r.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Approver3__r.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(testUser.LastName, RequestFormOutputGenerator.requestTask.CreatedBy.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(testUser.FirstName, RequestFormOutputGenerator.requestTask.CreatedBy.FirstName, '依頼タスク取得が不正です。');
            System.assertEquals(testManager.LastName, RequestFormOutputGenerator.requestTask.CreatedBy.Manager.LastName, '依頼タスク取得が不正です。');
            System.assertEquals(testManager.FirstName, RequestFormOutputGenerator.requestTask.CreatedBy.Manager.FirstName, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Factory__r.Factory__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Factory__r.SR_CP__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.Account.Name, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.Account.Type, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.DistributionChannelsPattern__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.EstimatedIssuedDate_01__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.KOUJI_SYU__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.Name, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.OppNumber__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.OpportunityNote__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.OpportunityNumber__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.OrderExpectation__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.Order_OrderDate__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.PickDivision__c, '依頼タスク取得が不正です。');
            // System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.ProposedTechniqueRemarks__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.PumpStation__r.Name, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.Result_SalesDate__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.SR_CP__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.SR_Number_Main__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.TotalCP__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.TotalWC__c, '依頼タスク取得が不正です。');
            System.assertEquals(null, RequestFormOutputGenerator.requestTask.Opportunity__r.WCPercent__c, '依頼タスク取得が不正です。');
        }

    /** 工事情報 */
        /**
         * @description テスト用依頼タスクに紐づく案件に紐づく工事情報作成
         */
        private static void createTestConstructionInfo(Integer constructionInfoCount) {
            testEngineer = new Engineer__c(
                Name = 'テストエンジニア'
            );
            insert testEngineer;

            testConstructionInfo = new ConstructionInfo__c(
                DAIRININ_KENMU__c = '可'
                , FROM_K_YMD_1__c = Date.newInstance(2004, 9, 10)
                , HAICHI_STATUS__c = '配置済'
                , KOUKIF_YMD__c = Date.newInstance(2005, 11, 12)
                , KOUKIT_YMD__c = Date.newInstance(2006, 2, 13)
                , MAN_1__c = testEngineer.Id
                , Opp6__c = testOpportunity.Id
                , ORDER_NO__c = '007'
                , SYUNKO_YMD__c = Date.newInstance(2007, 4, 14)
                , TO_K_YMD_1__c = Date.newInstance(2008, 6, 15)

                // insertに必要な項目
                , HAICHI_JUMBI__c = '不要'
            );
            insert testConstructionInfo;

            if(constructionInfoCount == 2){
                testEngineer2 = new Engineer__c(
                    Name = 'テストエンジニア2'
                );
                insert testEngineer2;

                testConstructionInfo2 = new ConstructionInfo__c(
                    DAIRININ_KENMU__c = '可'
                    , FROM_K_YMD_1__c = Date.newInstance(2009, 8, 16)
                    , HAICHI_STATUS__c = '配置済'
                    , KOUKIF_YMD__c = Date.newInstance(2010, 10, 17)
                    , KOUKIT_YMD__c = Date.newInstance(2011, 12, 18)
                    , MAN_1__c = testEngineer2.Id
                    , Opp6__c = testOpportunity.Id
                    , ORDER_NO__c = '008'
                    , SYUNKO_YMD__c = Date.newInstance(2012, 1, 19)
                    , TO_K_YMD_1__c = Date.newInstance(2013, 2, 20)

                    // insertに必要な項目
                    , HAICHI_JUMBI__c = '不要'
                );
                insert testConstructionInfo2;
            }
        }

        /**
         * @description 依頼タスクに紐づく案件に紐づく工事情報取得テスト 工事情報1
         */
        @isTest private static void getOpportunityConstructionInfoListTest1() {
            // preparation
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(1);

                // execution
                Test.startTest();
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);
                Test.stopTest();
            }

            // assertion
            /** 工事情報 */
            System.assertEquals(1, RequestFormOutputGenerator.opportunityConstructionInfoList.size(), '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
            for(Opportunity opportunity : RequestFormOutputGenerator.opportunityConstructionInfoList){
                System.assertEquals(1, opportunity.ConstructionInfo__r.size(), '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                for(ConstructionInfo__c constructionInfo : opportunity.ConstructionInfo__r){
                    System.assertEquals(testConstructionInfo.DAIRININ_KENMU__c, constructionInfo.DAIRININ_KENMU__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                    System.assertEquals(testConstructionInfo.FROM_K_YMD_1__c, constructionInfo.FROM_K_YMD_1__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                    System.assertEquals(testConstructionInfo.HAICHI_STATUS__c, constructionInfo.HAICHI_STATUS__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                    System.assertEquals(testConstructionInfo.KOUKIF_YMD__c, constructionInfo.KOUKIF_YMD__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                    System.assertEquals(testConstructionInfo.KOUKIT_YMD__c, constructionInfo.KOUKIT_YMD__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                    System.assertEquals(testEngineer.Name, constructionInfo.MAN_1__r.Name, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                    System.assertEquals(testConstructionInfo.ORDER_NO__c, constructionInfo.ORDER_NO__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                    System.assertEquals(testConstructionInfo.SYUNKO_YMD__c, constructionInfo.SYUNKO_YMD__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                    System.assertEquals(testConstructionInfo.TO_K_YMD_1__c, constructionInfo.TO_K_YMD_1__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                }
            }
        }

        /**
         * @description 依頼タスクに紐づく案件に紐づく工事情報取得テスト 工事情報2
         */
        @isTest private static void getOpportunityConstructionInfoListTest2() {
            // preparation
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(2);

                // execution
                Test.startTest();
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);
                Test.stopTest();
            }

            // assertion
            /** 工事情報 */
            System.assertEquals(1, RequestFormOutputGenerator.opportunityConstructionInfoList.size(), '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
            for(Opportunity opportunity : RequestFormOutputGenerator.opportunityConstructionInfoList){
                System.assertEquals(2, opportunity.ConstructionInfo__r.size(), '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo.DAIRININ_KENMU__c, opportunity.ConstructionInfo__r[0].DAIRININ_KENMU__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo.FROM_K_YMD_1__c, opportunity.ConstructionInfo__r[0].FROM_K_YMD_1__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo.HAICHI_STATUS__c, opportunity.ConstructionInfo__r[0].HAICHI_STATUS__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo.KOUKIF_YMD__c, opportunity.ConstructionInfo__r[0].KOUKIF_YMD__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo.KOUKIT_YMD__c, opportunity.ConstructionInfo__r[0].KOUKIT_YMD__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testEngineer.Name, opportunity.ConstructionInfo__r[0].MAN_1__r.Name, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo.ORDER_NO__c, opportunity.ConstructionInfo__r[0].ORDER_NO__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo.SYUNKO_YMD__c, opportunity.ConstructionInfo__r[0].SYUNKO_YMD__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo.TO_K_YMD_1__c, opportunity.ConstructionInfo__r[0].TO_K_YMD_1__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo2.DAIRININ_KENMU__c, opportunity.ConstructionInfo__r[1].DAIRININ_KENMU__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo2.FROM_K_YMD_1__c, opportunity.ConstructionInfo__r[1].FROM_K_YMD_1__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo2.HAICHI_STATUS__c, opportunity.ConstructionInfo__r[1].HAICHI_STATUS__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo2.KOUKIF_YMD__c, opportunity.ConstructionInfo__r[1].KOUKIF_YMD__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo2.KOUKIT_YMD__c, opportunity.ConstructionInfo__r[1].KOUKIT_YMD__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testEngineer2.Name, opportunity.ConstructionInfo__r[1].MAN_1__r.Name, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo2.ORDER_NO__c, opportunity.ConstructionInfo__r[1].ORDER_NO__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo2.SYUNKO_YMD__c, opportunity.ConstructionInfo__r[1].SYUNKO_YMD__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
                System.assertEquals(testConstructionInfo2.TO_K_YMD_1__c, opportunity.ConstructionInfo__r[1].TO_K_YMD_1__c, '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
            }
        }

        /**
         * @description 依頼タスクに紐づく案件に紐づく工事情報取得テスト 工事情報0
         */
        @isTest private static void getOpportunityConstructionInfoListTest0() {
            // preparation
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();

                // execution
                Test.startTest();
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);
                Test.stopTest();
            }

            // assertion
            /** 工事情報 */
            System.assertEquals(1, RequestFormOutputGenerator.opportunityConstructionInfoList.size(), '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
            for(Opportunity opportunity : RequestFormOutputGenerator.opportunityConstructionInfoList){
                System.assertEquals(0, opportunity.ConstructionInfo__r.size(), '依頼タスクに紐づく案件に紐づく工事情報取得が不正です。');
            }
        }

    /** 入札 */
        /**
         * @description テスト用依頼タスクに紐づく案件に紐づく入札作成
         * BidManagement__c
         */
        private static void createTestBidManagement(Integer bidManagementCount) {
            testBidManagement = new BidManagement__c(
                Opportunity__c = testOpportunity.Id
                , SubmitDate__c = Date.newInstance(2014, 3, 21)
            );
            insert testBidManagement;

            if(bidManagementCount == 2){
                testBidManagement2 = new BidManagement__c(
                    Opportunity__c = testOpportunity.Id
                    , SubmitDate__c = Date.newInstance(2015, 4, 22)
                );
                insert testBidManagement2;
            }
        }

        /**
         * @description 依頼タスクに紐づく案件に紐づく入札取得テスト 入札1
         */
        @isTest private static void getOpportunityBidManagementListTest1() {
            // preparation
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestBidManagement(1);

                // execution
                Test.startTest();
                RequestFormOutputGenerator.getOpportunityBidManagementList(testRequestTask.Id);
                Test.stopTest();
            }

            // assertion
            /** 工事情報 */
            System.assertEquals(1, RequestFormOutputGenerator.opportunityBidManagementList.size(), '依頼タスクに紐づく案件に紐づく入札取得が不正です。');
            for(Opportunity opportunity : RequestFormOutputGenerator.opportunityBidManagementList){
                System.assertEquals(1, opportunity.Opp1__r.size(), '依頼タスクに紐づく案件に紐づく入札取得が不正です。');
                for(BidManagement__c bidManagement : opportunity.Opp1__r){
                    System.assertEquals(testBidManagement.SubmitDate__c, bidManagement.SubmitDate__c, '依頼タスクに紐づく案件に紐づく入札取得が不正です。');
                }
            }
        }

        /**
         * @description 依頼タスクに紐づく案件に紐づく入札取得テスト 入札2
         */
        @isTest private static void getOpportunityBidManagementListTest2() {
            // preparation
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestBidManagement(2);

                // execution
                Test.startTest();
                RequestFormOutputGenerator.getOpportunityBidManagementList(testRequestTask.Id);
                Test.stopTest();
            }

            // assertion
            /** 工事情報 */
            System.assertEquals(1, RequestFormOutputGenerator.opportunityBidManagementList.size(), '依頼タスクに紐づく案件に紐づく入札取得が不正です。');
            for(Opportunity opportunity : RequestFormOutputGenerator.opportunityBidManagementList){
                System.assertEquals(2, opportunity.Opp1__r.size(), '依頼タスクに紐づく案件に紐づく入札取得が不正です。');
                System.assertEquals(testBidManagement.SubmitDate__c, opportunity.Opp1__r[0].SubmitDate__c, '依頼タスクに紐づく案件に紐づく入札取得が不正です。');
                System.assertEquals(testBidManagement2.SubmitDate__c, opportunity.Opp1__r[1].SubmitDate__c, '依頼タスクに紐づく案件に紐づく入札取得が不正です。');
            }
        }

        /**
         * @description 依頼タスクに紐づく案件に紐づく入札取得テスト 入札0
         */
        @isTest private static void getOpportunityBidManagementListTest0() {
            // preparation
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();

                // execution
                Test.startTest();
                RequestFormOutputGenerator.getOpportunityBidManagementList(testRequestTask.Id);
                Test.stopTest();
            }

            // assertion
            /** 工事情報 */
            System.assertEquals(1, RequestFormOutputGenerator.opportunityBidManagementList.size(), '依頼タスクに紐づく案件に紐づく入札取得が不正です。');
            for(Opportunity opportunity : RequestFormOutputGenerator.opportunityBidManagementList){
                System.assertEquals(0, opportunity.Opp1__r.size(), '依頼タスクに紐づく案件に紐づく入札取得が不正です。');
            }
        }

    // ①提案業務依頼書
        /**
         * @description ①提案業務依頼書用CSV作成テスト 工事情報1
         */
        @isTest private static void createRequestForm1CsvTest1() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(1);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm1Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(24, headerList.size(), '①提案業務依頼書用CSV作成が不正です。');
            System.assertEquals('ヘッダー_作成日,ヘッダー_宛先,ヘッダー_宛先Cc1,ヘッダー_宛先Cc2,ヘッダー_宛先Cc3,発信部門,課長,担当,客先名,発注予定年月,商談件名,商談番号,案件番号,商談内容,受注見込み,WC率,提案先,回答_依頼元,回答_宛先Cc1,回答_宛先Cc2,回答_宛先Cc3,竣工予定年月,配置技術者の有,配置技術者の無', header, '①提案業務依頼書用CSV作成が不正です。');
            System.assertEquals(24, valueList.size(), '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_作成日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE_JPNYMD, valueList[0], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先
            System.assertEquals(testRequestTask.RequestTo__c, valueList[1], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先Cc1
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[2], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先Cc2
            System.assertEquals(testRequestTask.RequestCc2__c, valueList[3], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先Cc3
            System.assertEquals(testRequestTask.RequestCc3__c, valueList[4], '①提案業務依頼書用CSV作成が不正です。');
            // 発信部門
            System.assertEquals(testOpportunity.PickDivision__c, valueList[5], '①提案業務依頼書用CSV作成が不正です。');
            // 課長
            System.assertEquals(testManager.LastName + testManager.FirstName, valueList[6], '①提案業務依頼書用CSV作成が不正です。');
            // 担当
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[7], '①提案業務依頼書用CSV作成が不正です。');
            // 客先名
            System.assertEquals(testAccount.Name, valueList[8], '①提案業務依頼書用CSV作成が不正です。');
            // 発注予定年月
            System.assertEquals('2000/01/02', valueList[9], '①提案業務依頼書用CSV作成が不正です。');
            // 商談件名
            System.assertEquals(testOpportunity.Name, valueList[10], '①提案業務依頼書用CSV作成が不正です。');
            // 商談番号
            System.assertEquals('Ｆ１２３４－Ｘ５６７－８', valueList[11], '①提案業務依頼書用CSV作成が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[12], '①提案業務依頼書用CSV作成が不正です。');
            // 商談内容
            System.assertEquals('"' + testOpportunity.OpportunityNote__c + '"', valueList[13], '①提案業務依頼書用CSV作成が不正です。');
            // 受注見込み
            System.assertEquals('１', valueList[14], '①提案業務依頼書用CSV作成が不正です。');
            // WC率
            System.assertEquals(String.valueOf(testFactory.SRWC__c.divide(testFactory.SR_CP__c, 1) * 100), valueList[15], '①提案業務依頼書用CSV作成が不正です。');
            // 提案先
            System.assertEquals('■最終顧客・部署 (' + testAccount.Name + ')', valueList[16], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_依頼元
            System.assertEquals(testRequestTask.Requester__c, valueList[17], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_宛先Cc1
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[18], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_宛先Cc2
            System.assertEquals(testRequestTask.RequestCc2__c, valueList[19], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_宛先Cc3
            System.assertEquals(testRequestTask.RequestCc3__c, valueList[20], '①提案業務依頼書用CSV作成が不正です。');
            // 竣工予定年月
            System.assertEquals('2007/04/14', valueList[21], '①提案業務依頼書用CSV作成が不正です。');
            // 配置技術者の有
            System.assertEquals('■有', valueList[22], '①提案業務依頼書用CSV作成が不正です。');
            // 配置技術者の無
            System.assertEquals('□無', valueList[23], '①提案業務依頼書用CSV作成が不正です。');
        }

        /**
         * @description ①提案業務依頼書用CSV作成テスト  工事情報2
         */
        @isTest private static void createRequestForm1CsvTest2() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(2);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm1Csv();
                Test.stopTest();
            }


            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(24, headerList.size(), '①提案業務依頼書用CSV作成が不正です。');
            System.assertEquals('ヘッダー_作成日,ヘッダー_宛先,ヘッダー_宛先Cc1,ヘッダー_宛先Cc2,ヘッダー_宛先Cc3,発信部門,課長,担当,客先名,発注予定年月,商談件名,商談番号,案件番号,商談内容,受注見込み,WC率,提案先,回答_依頼元,回答_宛先Cc1,回答_宛先Cc2,回答_宛先Cc3,竣工予定年月,配置技術者の有,配置技術者の無', header, '①提案業務依頼書用CSV作成が不正です。');
            System.assertEquals(24, valueList.size(), '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_作成日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE_JPNYMD, valueList[0], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先
            System.assertEquals(testRequestTask.RequestTo__c, valueList[1], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先Cc1
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[2], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先Cc2
            System.assertEquals(testRequestTask.RequestCc2__c, valueList[3], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先Cc3
            System.assertEquals(testRequestTask.RequestCc3__c, valueList[4], '①提案業務依頼書用CSV作成が不正です。');
            // 発信部門
            System.assertEquals(testOpportunity.PickDivision__c, valueList[5], '①提案業務依頼書用CSV作成が不正です。');
            // 課長
            System.assertEquals(testManager.LastName + testManager.FirstName, valueList[6], '①提案業務依頼書用CSV作成が不正です。');
            // 担当
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[7], '①提案業務依頼書用CSV作成が不正です。');
            // 客先名
            System.assertEquals(testAccount.Name, valueList[8], '①提案業務依頼書用CSV作成が不正です。');
            // 発注予定年月
            System.assertEquals('2000/01/02', valueList[9], '①提案業務依頼書用CSV作成が不正です。');
            // 商談件名
            System.assertEquals(testOpportunity.Name, valueList[10], '①提案業務依頼書用CSV作成が不正です。');
            // 商談番号
            System.assertEquals('Ｆ１２３４－Ｘ５６７－８', valueList[11], '①提案業務依頼書用CSV作成が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[12], '①提案業務依頼書用CSV作成が不正です。');
            // 商談内容
            System.assertEquals('"' + testOpportunity.OpportunityNote__c + '"', valueList[13], '①提案業務依頼書用CSV作成が不正です。');
            // 受注見込み
            System.assertEquals('１', valueList[14], '①提案業務依頼書用CSV作成が不正です。');
            // WC率
            System.assertEquals(String.valueOf(testFactory.SRWC__c.divide(testFactory.SR_CP__c, 1) * 100), valueList[15], '①提案業務依頼書用CSV作成が不正です。');
            // 提案先
            System.assertEquals('■最終顧客・部署 (' + testAccount.Name + ')', valueList[16], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_依頼元
            System.assertEquals(testRequestTask.Requester__c, valueList[17], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_宛先Cc1
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[18], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_宛先Cc2
            System.assertEquals(testRequestTask.RequestCc2__c, valueList[19], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_宛先Cc3
            System.assertEquals(testRequestTask.RequestCc3__c, valueList[20], '①提案業務依頼書用CSV作成が不正です。');
            // 竣工予定年月
            System.assertEquals('', valueList[21], '①提案業務依頼書用CSV作成が不正です。');
            // 配置技術者の有
            System.assertEquals('□有', valueList[22], '①提案業務依頼書用CSV作成が不正です。');
            // 配置技術者の無
            System.assertEquals('□無', valueList[23], '①提案業務依頼書用CSV作成が不正です。');
        }

        /**
         * @description ①提案業務依頼書用CSV作成テスト 最小限の値設定
         */
        @isTest private static void createRequestForm1CsvTestMin() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;
                
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm1Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(24, headerList.size(), '①提案業務依頼書用CSV作成が不正です。');
            System.assertEquals('ヘッダー_作成日,ヘッダー_宛先,ヘッダー_宛先Cc1,ヘッダー_宛先Cc2,ヘッダー_宛先Cc3,発信部門,課長,担当,客先名,発注予定年月,商談件名,商談番号,案件番号,商談内容,受注見込み,WC率,提案先,回答_依頼元,回答_宛先Cc1,回答_宛先Cc2,回答_宛先Cc3,竣工予定年月,配置技術者の有,配置技術者の無', header, '①提案業務依頼書用CSV作成が不正です。');
            System.assertEquals(24, valueList.size(), '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_作成日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE_JPNYMD, valueList[0], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先
            System.assertEquals('', valueList[1], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先Cc1
            System.assertEquals('', valueList[2], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先Cc2
            System.assertEquals('', valueList[3], '①提案業務依頼書用CSV作成が不正です。');
            // ヘッダー_宛先Cc3
            System.assertEquals('', valueList[4], '①提案業務依頼書用CSV作成が不正です。');
            // 発信部門
            System.assertEquals('', valueList[5], '①提案業務依頼書用CSV作成が不正です。');
            // 課長
            System.assertEquals(testManager.LastName + testManager.FirstName, valueList[6], '①提案業務依頼書用CSV作成が不正です。');
            // 担当
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[7], '①提案業務依頼書用CSV作成が不正です。');
            // 客先名
            System.assertEquals('', valueList[8], '①提案業務依頼書用CSV作成が不正です。');
            // 発注予定年月
            System.assertEquals('', valueList[9], '①提案業務依頼書用CSV作成が不正です。');
            // 商談件名
            System.assertEquals('', valueList[10], '①提案業務依頼書用CSV作成が不正です。');
            // 商談番号
            System.assertEquals('', valueList[11], '①提案業務依頼書用CSV作成が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[12], '①提案業務依頼書用CSV作成が不正です。');
            // 商談内容
            System.assertEquals('', valueList[13], '①提案業務依頼書用CSV作成が不正です。');
            // 受注見込み
            System.assertEquals('', valueList[14], '①提案業務依頼書用CSV作成が不正です。');
            // WC率
            System.assertEquals('', valueList[15], '①提案業務依頼書用CSV作成が不正です。');
            // 提案先
            System.assertEquals('□最終顧客・部署 (    　　　)', valueList[16], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_依頼元
            System.assertEquals(testRequestTask.Requester__c, valueList[17], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_宛先Cc1
            System.assertEquals('', valueList[18], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_宛先Cc2
            System.assertEquals('', valueList[19], '①提案業務依頼書用CSV作成が不正です。');
            // 回答_宛先Cc3
            System.assertEquals('', valueList[20], '①提案業務依頼書用CSV作成が不正です。');
            // 竣工予定年月
            System.assertEquals('', valueList[21], '①提案業務依頼書用CSV作成が不正です。');
            // 配置技術者の有
            System.assertEquals('□有', valueList[22], '①提案業務依頼書用CSV作成が不正です。');
            // 配置技術者の無
            System.assertEquals('□無', valueList[23], '①提案業務依頼書用CSV作成が不正です。');
        }

    // ②見積照会書
        /**
         * @description ②見積照会書用CSV作成テスト1
         */
        @isTest private static void createRequestForm2CsvTest1() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(1);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm2Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(14, headerList.size(), '②見積照会書用CSV作成が不正です。1)');
            System.assertEquals('発行日,案件番号,商談番号,宛先,担当,顧客名,件名,案件概要,確度,受注,売上,工事,商流,着手', header, '②見積照会書用CSV作成が不正です。2');
            System.assertEquals(14, valueList.size(), '②見積照会書用CSV作成が不正です。3');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE, valueList[0], '②見積照会書用CSV作成が不正です。4');
            // 案件番号
            System.assertNotEquals(null, valueList[1], '②見積照会書用CSV作成が不正です。5');
            // 商談番号
            System.assertEquals(testOpportunity.OpportunityNumber__c, valueList[2], '②見積照会書用CSV作成が不正です。6');
            // 宛先
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ殿', valueList[3], '②見積照会書用CSV作成が不正です。7');
            // 担当
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[4], '②見積照会書用CSV作成が不正です。8');
            // 顧客名
            System.assertEquals('"' + testAccount.Name + '"', valueList[5], '②見積照会書用CSV作成が不正です。9');
            // 件名
            System.assertEquals('"' + testOpportunity.Name + '"', valueList[6], '②見積照会書用CSV作成が不正です。10');
            // 案件概要
            System.assertEquals('"' + testOpportunity.OpportunityNote__c + '"', valueList[7], '②見積照会書用CSV作成が不正です。11');
            // システム概要
            // System.assertEquals('"' + testOpportunity.ProposedTechniqueRemarks__c + '"', valueList[8], '②見積照会書用CSV作成が不正です。');
            // 確度

            System.assertEquals('"■1 決定，□2 有望，□3 努力，□4C チャレンジ，□4 希望，□5 需要"', valueList[8], '②見積照会書用CSV作成が不正です。12');
            // 受注
            System.assertEquals('2000/01/02', valueList[9], '②見積照会書用CSV作成が不正です。13');
            // 売上
            System.assertEquals('2002/05/06', valueList[10], '②見積照会書用CSV作成が不正です。14');
            // 工事
            System.assertEquals('□建設業法対象', valueList[11], '②見積照会書用CSV作成が不正です。15');
            // 商流
            System.assertEquals(testOpportunity.DistributionChannelsPattern__c, valueList[12], '②見積照会書用CSV作成が不正です。16');
            // 着手
            System.assertEquals('2005/11/12', valueList[13], '②見積照会書用CSV作成が不正です。17');
        }

        /**
         * @description ②見積照会書用CSV作成テスト2
         */
        @isTest private static void createRequestForm2CsvTest2() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(2);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm2Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(14, headerList.size(), '②見積照会書用CSV作成が不正です。');
            System.assertEquals('発行日,案件番号,商談番号,宛先,担当,顧客名,件名,案件概要,確度,受注,売上,工事,商流,着手', header, '②見積照会書用CSV作成が不正です。');
            System.assertEquals(13, valueList.size(), '②見積照会書用CSV作成が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE, valueList[0], '②見積照会書用CSV作成が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[1], '②見積照会書用CSV作成が不正です。');
            // 商談番号
            System.assertEquals(testOpportunity.OpportunityNumber__c, valueList[2], '②見積照会書用CSV作成が不正です。');
            // 宛先
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ殿', valueList[3], '②見積照会書用CSV作成が不正です。');
            // 担当
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[4], '②見積照会書用CSV作成が不正です。');
            // 顧客名
            System.assertEquals('"' + testAccount.Name + '"', valueList[5], '②見積照会書用CSV作成が不正です。');
            // 件名
            System.assertEquals('"' + testOpportunity.Name + '"', valueList[6], '②見積照会書用CSV作成が不正です。');
            // 案件概要
            System.assertEquals('"' + testOpportunity.OpportunityNote__c + '"', valueList[7], '②見積照会書用CSV作成が不正です。');
            // システム概要
            // System.assertEquals('"' + testOpportunity.ProposedTechniqueRemarks__c + '"', valueList[8], '②見積照会書用CSV作成が不正です。');
            // 確度
            System.assertEquals('"■1 決定，□2 有望，□3 努力，□4C チャレンジ，□4 希望，□5 需要"', valueList[8], '②見積照会書用CSV作成が不正です。');
            // 受注
            System.assertEquals('2000/01/02', valueList[9], '②見積照会書用CSV作成が不正です。');
            // 売上
            System.assertEquals('2002/05/06', valueList[10], '②見積照会書用CSV作成が不正です。');
            // 工事
            System.assertEquals('□建設業法対象', valueList[11], '②見積照会書用CSV作成が不正です。');
            // 商流
            System.assertEquals(testOpportunity.DistributionChannelsPattern__c, valueList[12], '②見積照会書用CSV作成が不正です。');
            // 着手
            // 空文字列想定のため、valueList.size()が14の時点で想定通り。
        }

        /**
         * @description ②見積照会書用CSV作成テスト 最小限の値設定
         */
        @isTest private static void createRequestForm2CsvTestMin() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;
                
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm2Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(14, headerList.size(), '②見積照会書用CSV作成が不正です。');
            System.assertEquals('発行日,案件番号,商談番号,宛先,担当,顧客名,件名,案件概要,確度,受注,売上,工事,商流,着手', header, '②見積照会書用CSV作成が不正です。');
            System.assertEquals(5, valueList.size(), '②見積照会書用CSV作成が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE, valueList[0], '②見積照会書用CSV作成が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[1], '②見積照会書用CSV作成が不正です。');
            // 商談番号
            System.assertEquals('', valueList[2], '②見積照会書用CSV作成が不正です。');
            // 宛先
            System.assertEquals('Ｋ殿', valueList[3], '②見積照会書用CSV作成が不正です。');
            // 担当
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[4], '②見積照会書用CSV作成が不正です。');
            // 顧客名
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
            // 件名
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
            // 案件概要
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
            // システム概要
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
            // 確度
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
            // 受注
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
            // 売上
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
            // 工事
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
            // 商流
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
            // 着手
            // 空文字列想定のため、valueList.size()が5の時点で想定通り。
        }

    // ③写真撮影依頼書
        /**
         * @description  ③写真撮影依頼書用CSV作成テスト
         */
        @isTest private static void createRequestForm3CsvTest() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(1);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm3Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(11, headerList.size(), '③写真撮影依頼書用CSV作成処理が不正です。');
            System.assertEquals('本社・支社,事業所,ヘッダー_御注文元,ヘッダー_件名,SR_NO_案件番号,送付期限_年,送付期限_月,送付期限_日,看板仕様_御注文元,看板仕様_件名,看板仕様_製作所名', header, '③写真撮影依頼書用CSV作成処理が不正です。');
            System.assertEquals(11, valueList.size(), '③写真撮影依頼書用CSV作成処理が不正です。');
            // 本社・支社
            System.assertEquals(testRequestTask.Requester__c + 'Ｋ', valueList[0], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 事業所
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ', valueList[1], '③写真撮影依頼書用CSV作成処理が不正です。');
            // ヘッダー_御注文元
            System.assertEquals(testAccount.Name, valueList[2], '③写真撮影依頼書用CSV作成処理が不正です。');
            // ヘッダー_件名
            System.assertEquals(testOpportunity.Name, valueList[3], '③写真撮影依頼書用CSV作成処理が不正です。');
            // SR_NO_案件番号
            System.assert(valueList[4].contains('A1234-Z567-0（案件番号：'), '③写真撮影依頼書用CSV作成処理が不正です。');
            // 送付期限_年
            System.assertEquals('２０９９', valueList[5], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 送付期限_月
            System.assertEquals('１２', valueList[6], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 送付期限_日
            System.assertEquals('３１', valueList[7], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 看板仕様_御注文元
            System.assertEquals(testAccount.Name, valueList[8], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 看板仕様_件名
            System.assertEquals(testOpportunity.Name, valueList[9], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 看板仕様_製作所名
            System.assertEquals('三菱電機株式会社　神戸製作所', valueList[10], '③写真撮影依頼書用CSV作成処理が不正です。');
        }

        /**
         * @description  ③写真撮影依頼書用CSV作成テスト 最小限の値設定
         */
        @isTest private static void createRequestForm3CsvTestMin() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;
                
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm3Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(11, headerList.size(), '③写真撮影依頼書用CSV作成処理が不正です。');
            System.assertEquals('本社・支社,事業所,ヘッダー_御注文元,ヘッダー_件名,SR_NO_案件番号,送付期限_年,送付期限_月,送付期限_日,看板仕様_御注文元,看板仕様_件名,看板仕様_製作所名', header, '③写真撮影依頼書用CSV作成処理が不正です。');
            System.assertEquals(11, valueList.size(), '③写真撮影依頼書用CSV作成処理が不正です。');
            // 本社・支社
            System.assertEquals(testRequestTask.Requester__c + 'Ｋ', valueList[0], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 事業所
            System.assertEquals('Ｋ', valueList[1], '③写真撮影依頼書用CSV作成処理が不正です。');
            // ヘッダー_御注文元
            System.assertEquals('', valueList[2], '③写真撮影依頼書用CSV作成処理が不正です。');
            // ヘッダー_件名
            System.assertEquals('', valueList[3], '③写真撮影依頼書用CSV作成処理が不正です。');
            // SR_NO_案件番号
            System.assert(valueList[4].startsWith('（案件番号：'), '③写真撮影依頼書用CSV作成処理が不正です。');
            // 送付期限_年
            System.assertEquals('２０２５', valueList[5], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 送付期限_月
            System.assertEquals('０９', valueList[6], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 送付期限_日
            System.assertEquals('０９', valueList[7], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 看板仕様_御注文元
            System.assertEquals('', valueList[8], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 看板仕様_件名
            System.assertEquals('', valueList[9], '③写真撮影依頼書用CSV作成処理が不正です。');
            // 看板仕様_製作所名
            System.assertEquals('三菱電機株式会社　神戸製作所', valueList[10], '③写真撮影依頼書用CSV作成処理が不正です。');
        }

    // ④機器搬入連絡表
        /**
         * @description ④機器搬入連絡表用CSV作成テスト1
         */
        @isTest private static void createRequestForm4CsvTest1() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(1);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm4Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(11, headerList.size(), '④機器搬入連絡表用CSV作成処理が不正です。');
            System.assertEquals('宛先,写1,写2,写3,発行日,発行者,発注元,工事件名,現場名,工事番号,現場代理人', header, '④機器搬入連絡表用CSV作成処理が不正です。');
            System.assertEquals(11, valueList.size(), '④機器搬入連絡表用CSV作成処理が不正です。');
            // 宛先
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ', valueList[0], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 写1
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[1], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 写2
            System.assertEquals(testRequestTask.RequestCc2__c, valueList[2], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 写3
            System.assertEquals(testRequestTask.RequestCc3__c, valueList[3], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(RequestFormOutputGenerator.EXECUTED_DATE_JPNYMD), valueList[4], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 発行者
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[5], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 発注元
            System.assertEquals(testAccount.Name, valueList[6], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 工事件名
            System.assertEquals(testOpportunity.Name, valueList[7], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 現場名
            System.assertEquals(testPumpStation.Name, valueList[8], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 工事番号
            System.assertEquals(testConstructionInfo.ORDER_NO__c, valueList[9], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 現場代理人
            System.assertEquals(testEngineer.Name, valueList[10], '④機器搬入連絡表用CSV作成処理が不正です。');
        }

        /**
         * @description ④機器搬入連絡表用CSV作成テスト2
         */
        @isTest private static void createRequestForm4CsvTest2() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(2);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm4Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(11, headerList.size(), '④機器搬入連絡表用CSV作成処理が不正です。');
            System.assertEquals('宛先,写1,写2,写3,発行日,発行者,発注元,工事件名,現場名,工事番号,現場代理人', header, '④機器搬入連絡表用CSV作成処理が不正です。');
            System.assertEquals(9, valueList.size(), '④機器搬入連絡表用CSV作成処理が不正です。');
            // 宛先
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ', valueList[0], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 写1
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[1], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 写2
            System.assertEquals(testRequestTask.RequestCc2__c, valueList[2], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 写3
            System.assertEquals(testRequestTask.RequestCc3__c, valueList[3], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(RequestFormOutputGenerator.EXECUTED_DATE_JPNYMD), valueList[4], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 発行者
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[5], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 発注元
            System.assertEquals(testAccount.Name, valueList[6], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 工事件名
            System.assertEquals(testOpportunity.Name, valueList[7], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 現場名
            System.assertEquals(testPumpStation.Name, valueList[8], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 工事番号
            // 空文字列想定のため、valueList.size()が9の時点で想定通り。
            // 現場代理人
            // 空文字列想定のため、valueList.size()が9の時点で想定通り。
        }

        /**
         * @description ④機器搬入連絡表用CSV作成テスト 最小限の値設定
         */
        @isTest private static void createRequestForm4CsvTestMin() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;
                
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm4Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(11, headerList.size(), '④機器搬入連絡表用CSV作成処理が不正です。');
            System.assertEquals('宛先,写1,写2,写3,発行日,発行者,発注元,工事件名,現場名,工事番号,現場代理人', header, '④機器搬入連絡表用CSV作成処理が不正です。');
            System.assertEquals(6, valueList.size(), '④機器搬入連絡表用CSV作成処理が不正です。');
            // 宛先
            System.assertEquals('Ｋ', valueList[0], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 写1
            System.assertEquals('', valueList[1], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 写2
            System.assertEquals('', valueList[2], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 写3
            System.assertEquals('', valueList[3], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(RequestFormOutputGenerator.EXECUTED_DATE_JPNYMD), valueList[4], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 発行者
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[5], '④機器搬入連絡表用CSV作成処理が不正です。');
            // 発注元
            // 空文字列想定のため、valueList.size()が6の時点で想定通り。
            // 工事件名
            // 空文字列想定のため、valueList.size()が6の時点で想定通り。
            // 現場名
            // 空文字列想定のため、valueList.size()が6の時点で想定通り。
            // 工事番号
            // 空文字列想定のため、valueList.size()が6の時点で想定通り。
            // 現場代理人
            // 空文字列想定のため、valueList.size()が6の時点で想定通り。
        }

    // ⑤技術員派遣依頼書
        /**
         * @description ⑤技術員派遣依頼書用CSV作成テスト1
         */
        @isTest private static void createRequestForm5CsvTest1() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(1);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm5Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(18, headerList.size(), ' ⑤技術員派遣依頼書用CSV作成処理が不正です。');
            System.assertEquals('回答希望期限,発行日_年,発行日_月,発行日_日,本社・支社・現場,製作所営業,製作所営業_写1,製作所営業_写2,製作所営業_写3,注文元,件名,SR_NO,案件番号,販事担当者,宛先1,宛先2,技術員派遣連絡件名,現場代理人', header, ' ⑤技術員派遣依頼書用CSV作成処理が不正です。');
            System.assertEquals(18, valueList.size(), ' ⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 回答希望期限
            System.assertEquals('２０９９年１２月３１日', valueList[0], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 発行日_年
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(String.valueOf(RequestFormOutputGenerator.NOW.year())), valueList[1], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 発行日_月
            String publishMonth = String.valueOf(RequestFormOutputGenerator.NOW.month()).length() == 1 ? '0' + String.valueOf(RequestFormOutputGenerator.NOW.month()) : String.valueOf(RequestFormOutputGenerator.NOW.month());
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(publishMonth), valueList[2], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 発行日_日
            String publishDay = String.valueOf(RequestFormOutputGenerator.NOW.day()).length() == 1 ? '0' + String.valueOf(RequestFormOutputGenerator.NOW.day()) : String.valueOf(RequestFormOutputGenerator.NOW.day());
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(publishDay), valueList[3], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 本社・支社・現場
            System.assertEquals(testRequestTask.Requester__c, valueList[4], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業
            System.assertEquals(testRequestTask.RequestTo__c, valueList[5], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業_写1
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[6], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業_写2
            System.assertEquals(testRequestTask.RequestCc2__c, valueList[7], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業_写3
            System.assertEquals(testRequestTask.RequestCc3__c, valueList[8], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 注文元
            System.assertEquals(testAccount.Name, valueList[9], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 件名
            System.assertEquals(testOpportunity.Name, valueList[10], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // SR_NO
            System.assertEquals('Ａ１２３４－Ｚ５６７－０', valueList[11], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[12], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 販事担当者
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[13], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 宛先1
            System.assertEquals(testRequestTask.RequestTo__c, valueList[14], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 宛先2
            System.assertEquals(testRequestTask.Requester__c, valueList[15], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 技術員派遣連絡件名
            System.assertEquals(testOpportunity.Name, valueList[16], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 現場代理人
            System.assertEquals(testEngineer.Name, valueList[17], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
        }

        /**
         * @description ⑤技術員派遣依頼書用CSV作成テスト2
         */
        @isTest private static void createRequestForm5CsvTest2() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(2);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm5Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(18, headerList.size(), ' ⑤技術員派遣依頼書用CSV作成処理が不正です。');
            System.assertEquals('回答希望期限,発行日_年,発行日_月,発行日_日,本社・支社・現場,製作所営業,製作所営業_写1,製作所営業_写2,製作所営業_写3,注文元,件名,SR_NO,案件番号,販事担当者,宛先1,宛先2,技術員派遣連絡件名,現場代理人', header, ' ⑤技術員派遣依頼書用CSV作成処理が不正です。');
            System.assertEquals(17, valueList.size(), ' ⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 回答希望期限
            System.assertEquals('２０９９年１２月３１日', valueList[0], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 発行日_年
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(String.valueOf(RequestFormOutputGenerator.NOW.year())), valueList[1], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 発行日_月
            String publishMonth = String.valueOf(RequestFormOutputGenerator.NOW.month()).length() == 1 ? '0' + String.valueOf(RequestFormOutputGenerator.NOW.month()) : String.valueOf(RequestFormOutputGenerator.NOW.month());
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(publishMonth), valueList[2], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 発行日_日
            String publishDay = String.valueOf(RequestFormOutputGenerator.NOW.day()).length() == 1 ? '0' + String.valueOf(RequestFormOutputGenerator.NOW.day()) : String.valueOf(RequestFormOutputGenerator.NOW.day());
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(publishDay), valueList[3], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 本社・支社・現場
            System.assertEquals(testRequestTask.Requester__c, valueList[4], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業
            System.assertEquals(testRequestTask.RequestTo__c, valueList[5], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業_写1
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[6], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業_写2
            System.assertEquals(testRequestTask.RequestCc2__c, valueList[7], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業_写3
            System.assertEquals(testRequestTask.RequestCc3__c, valueList[8], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 注文元
            System.assertEquals(testAccount.Name, valueList[9], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 件名
            System.assertEquals(testOpportunity.Name, valueList[10], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // SR_NO
            System.assertEquals('Ａ１２３４－Ｚ５６７－０', valueList[11], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[12], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 販事担当者
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[13], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 宛先1
            System.assertEquals(testRequestTask.RequestTo__c, valueList[14], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 宛先2
            System.assertEquals(testRequestTask.Requester__c, valueList[15], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 技術員派遣連絡件名
            System.assertEquals(testOpportunity.Name, valueList[16], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 現場代理人
            // 空文字列想定のため、valueList.size()が17の時点で想定通り。
        }

        /**
         * @description ⑤技術員派遣依頼書用CSV作成テスト 最小限の値設定
         */
        @isTest private static void createRequestForm5CsvTestMin() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;
                
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm5Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(18, headerList.size(), ' ⑤技術員派遣依頼書用CSV作成処理が不正です。');
            System.assertEquals('回答希望期限,発行日_年,発行日_月,発行日_日,本社・支社・現場,製作所営業,製作所営業_写1,製作所営業_写2,製作所営業_写3,注文元,件名,SR_NO,案件番号,販事担当者,宛先1,宛先2,技術員派遣連絡件名,現場代理人', header, ' ⑤技術員派遣依頼書用CSV作成処理が不正です。');
            System.assertEquals(16, valueList.size(), ' ⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 回答希望期限
            System.assertEquals('２０２５年０９月０９日', valueList[0], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 発行日_年
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(String.valueOf(RequestFormOutputGenerator.NOW.year())), valueList[1], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 発行日_月
            String publishMonth = String.valueOf(RequestFormOutputGenerator.NOW.month()).length() == 1 ? '0' + String.valueOf(RequestFormOutputGenerator.NOW.month()) : String.valueOf(RequestFormOutputGenerator.NOW.month());
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(publishMonth), valueList[2], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 発行日_日
            String publishDay = String.valueOf(RequestFormOutputGenerator.NOW.day()).length() == 1 ? '0' + String.valueOf(RequestFormOutputGenerator.NOW.day()) : String.valueOf(RequestFormOutputGenerator.NOW.day());
            System.assertEquals(RequestFormOutputGenerator.convertCharacterWidthHalfToFull(publishDay), valueList[3], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 本社・支社・現場
            System.assertEquals(testRequestTask.Requester__c, valueList[4], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業
            System.assertEquals('', valueList[5], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業_写1
            System.assertEquals('', valueList[6], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業_写2
            System.assertEquals('', valueList[7], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 製作所営業_写3
            System.assertEquals('', valueList[8], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 注文元
            System.assertEquals('', valueList[9], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 件名
            System.assertEquals('', valueList[10], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // SR_NO
            System.assertEquals('', valueList[11], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[12], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 販事担当者
            System.assertEquals(testUser.LastName + testUser.FirstName, valueList[13], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 宛先1
            System.assertEquals('', valueList[14], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 宛先2
            System.assertEquals(testRequestTask.Requester__c, valueList[15], '⑤技術員派遣依頼書用CSV作成処理が不正です。');
            // 技術員派遣連絡件名
            // 空文字列想定のため、valueList.size()が16の時点で想定通り。
            // 現場代理人
            // 空文字列想定のため、valueList.size()が16の時点で想定通り。
        }

    // ⑥配置技術者選定依頼
        /**
         * @description ⑥配置技術者選定依頼用CSV作成テスト1
         */
        @isTest private static void createRequestForm6CsvTest1() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(1);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm6Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(31, headerList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals('ヘッダー_発信元,ヘッダー_宛先1,ヘッダー_写,ヘッダー_発信元担当,ヘッダー_発信元検印,依頼先場所,回答期限_月,回答期限_日,客先名,件名,案件番号,回答場所名,回答_宛先1,回答_宛先2,配置報告_発信元,配置報告_発信元担当,配置報告_発信元検印,配置報告_宛先1,配置報告_写,工期_自_年,工期_自_月,工期_自_日,工期_至_年,工期_至_月,工期_至_日,配置期間_自_年,配置期間_自_月,配置期間_自_日,配置期間_至_年,配置期間_至_月,配置期間_至_日', header, '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals(31, valueList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_発信元
            System.assertEquals(testRequestTask.Requester__c, valueList[0], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_宛先1
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ殿', valueList[1], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_写
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[2], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_発信元担当
            System.assertEquals(testUser.LastName, valueList[3], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_発信元検印
            System.assertEquals(testApprover1.LastName, valueList[4], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 依頼先場所
            System.assertEquals('以下の条件で，' + testRequestTask.RequestDestination__c + 'から配置技術者選出の検討をお願いします。詳細は添付参照のこと。', valueList[5], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答期限_月
            System.assertEquals('１２', valueList[6], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答期限_日
            System.assertEquals('３１', valueList[7], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 客先名
            System.assertEquals(testAccount.Name, valueList[8], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 件名
            System.assertEquals(testOpportunity.Name, valueList[9], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[10], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答場所名
            System.assertEquals('【回答（' + testRequestTask.RequestDestination__c + '）】', valueList[11], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答_宛先1
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ殿', valueList[12], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答_宛先2
            System.assertEquals(testRequestTask.Requester__c, valueList[13], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_発信元
            System.assertEquals(testRequestTask.Requester__c + 'Ｋ', valueList[14], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_発信元担当
            System.assertEquals(testUser.LastName, valueList[15], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_発信元検印
            System.assertEquals(testApprover1.LastName, valueList[16], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_宛先1
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ殿', valueList[17], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_写
            System.assertEquals('', valueList[18], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 工期_自_年
            System.assertEquals('2005', valueList[19], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 工期_自_月
            System.assertEquals('11', valueList[20], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 工期_自_日
            System.assertEquals('12', valueList[21], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 工期_至_年
            System.assertEquals('2006', valueList[22], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 工期_至_月
            System.assertEquals('02', valueList[23], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 工期_至_日
            System.assertEquals('13', valueList[24], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置期間_自_年
            System.assertEquals('2004', valueList[25], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置期間_自_月
            System.assertEquals('09', valueList[26], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置期間_自_日
            System.assertEquals('10', valueList[27], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置期間_至_年
            System.assertEquals('2008', valueList[28], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置期間_至_月
            System.assertEquals('06', valueList[29], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置期間_至_日
            System.assertEquals('15', valueList[30], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
        }

        /**
         * @description ⑥配置技術者選定依頼用CSV作成テスト2
         */
        @isTest private static void createRequestForm6CsvTest2() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(2);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm6Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(31, headerList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals('ヘッダー_発信元,ヘッダー_宛先1,ヘッダー_写,ヘッダー_発信元担当,ヘッダー_発信元検印,依頼先場所,回答期限_月,回答期限_日,客先名,件名,案件番号,回答場所名,回答_宛先1,回答_宛先2,配置報告_発信元,配置報告_発信元担当,配置報告_発信元検印,配置報告_宛先1,配置報告_写,工期_自_年,工期_自_月,工期_自_日,工期_至_年,工期_至_月,工期_至_日,配置期間_自_年,配置期間_自_月,配置期間_自_日,配置期間_至_年,配置期間_至_月,配置期間_至_日', header, '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals(18, valueList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_発信元
            System.assertEquals(testRequestTask.Requester__c, valueList[0], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_宛先1
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ殿', valueList[1], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_写
            System.assertEquals(testRequestTask.RequestCc1__c, valueList[2], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_発信元担当
            System.assertEquals(testUser.LastName, valueList[3], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_発信元検印
            System.assertEquals(testApprover1.LastName, valueList[4], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 依頼先場所
            System.assertEquals('以下の条件で，' + testRequestTask.RequestDestination__c + 'から配置技術者選出の検討をお願いします。詳細は添付参照のこと。', valueList[5], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答期限_月
            System.assertEquals('１２', valueList[6], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答期限_日
            System.assertEquals('３１', valueList[7], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 客先名
            System.assertEquals(testAccount.Name, valueList[8], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 件名
            System.assertEquals(testOpportunity.Name, valueList[9], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[10], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答場所名
            System.assertEquals('【回答（' + testRequestTask.RequestDestination__c + '）】', valueList[11], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答_宛先1
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ殿', valueList[12], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答_宛先2
            System.assertEquals(testRequestTask.Requester__c, valueList[13], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_発信元
            System.assertEquals(testRequestTask.Requester__c + 'Ｋ', valueList[14], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_発信元担当
            System.assertEquals(testUser.LastName, valueList[15], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_発信元検印
            System.assertEquals(testApprover1.LastName, valueList[16], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_宛先1
            System.assertEquals(testRequestTask.RequestTo__c + 'Ｋ殿', valueList[17], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_写
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_自_年
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_自_月
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_自_日
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_至_年
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_至_月
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_至_日
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_自_年
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_自_月
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_自_日
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_至_年
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_至_月
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_至_日
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
        }

        /**
         * @description ⑥配置技術者選定依頼用CSV作成テスト 最小限の値設定
         */
        @isTest private static void createRequestForm6CsvTestMin() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;
                
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm6Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(31, headerList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals('ヘッダー_発信元,ヘッダー_宛先1,ヘッダー_写,ヘッダー_発信元担当,ヘッダー_発信元検印,依頼先場所,回答期限_月,回答期限_日,客先名,件名,案件番号,回答場所名,回答_宛先1,回答_宛先2,配置報告_発信元,配置報告_発信元担当,配置報告_発信元検印,配置報告_宛先1,配置報告_写,工期_自_年,工期_自_月,工期_自_日,工期_至_年,工期_至_月,工期_至_日,配置期間_自_年,配置期間_自_月,配置期間_自_日,配置期間_至_年,配置期間_至_月,配置期間_至_日', header, '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals(18, valueList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_発信元
            System.assertEquals(testRequestTask.Requester__c, valueList[0], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_宛先1
            System.assertEquals('Ｋ殿', valueList[1], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_写
            System.assertEquals('', valueList[2], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_発信元担当
            System.assertEquals(testUser.LastName, valueList[3], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // ヘッダー_発信元検印
            System.assertEquals('', valueList[4], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 依頼先場所
            System.assertEquals('以下の条件で，' + testRequestTask.RequestDestination__c + 'から配置技術者選出の検討をお願いします。詳細は添付参照のこと。', valueList[5], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答期限_月
            System.assertEquals('０９', valueList[6], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答期限_日
            System.assertEquals('０９', valueList[7], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 客先名
            System.assertEquals('', valueList[8], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 件名
            System.assertEquals('', valueList[9], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[10], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答場所名
            System.assertEquals('【回答（' + testRequestTask.RequestDestination__c + '）】', valueList[11], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答_宛先1
            System.assertEquals('Ｋ殿', valueList[12], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 回答_宛先2
            System.assertEquals(testRequestTask.Requester__c, valueList[13], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_発信元
            System.assertEquals(testRequestTask.Requester__c + 'Ｋ', valueList[14], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_発信元担当
            System.assertEquals(testUser.LastName, valueList[15], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_発信元検印
            System.assertEquals('', valueList[16], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_宛先1
            System.assertEquals('Ｋ殿', valueList[17], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 配置報告_写
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_自_年
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_自_月
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_自_日
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_至_年
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_至_月
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 工期_至_日
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_自_年
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_自_月
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_自_日
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_至_年
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_至_月
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
            // 配置期間_至_日
            // 空文字列想定のため、valueList.size()が18の時点で想定通り。
        }

        /**
         * @description ⑥配置技術者選定依頼用CSV作成テスト 別紙
         */
        @isTest private static void createRequestForm6AppendixCsvTest() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestConstructionInfo(1);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm6AppendixCsv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(4, headerList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals('受注確度,全社CP,場所CP,備考', header, '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals(4, valueList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 受注確度
            System.assertEquals('受注確度【' + testOpportunity.OrderExpectation__c + '】', valueList[0], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 全社CP
            System.assertEquals('全社ＣＰ7', valueList[1], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 場所CP
            System.assertEquals('場所ＣＰ7', valueList[2], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 備考
            System.assertEquals(testOpportunity.OpportunityNumber__c, valueList[3], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
        }

        /**
         * @description ⑥配置技術者選定依頼用CSV作成テスト 別紙 最小限の値設定
         */
        @isTest private static void createRequestForm6AppendixCsvTestMin() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm6AppendixCsv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(4, headerList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals('受注確度,全社CP,場所CP,備考', header, '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            System.assertEquals(3, valueList.size(), '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 受注確度
            System.assertEquals('受注確度【】', valueList[0], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 全社CP
            System.assertEquals('全社ＣＰ', valueList[1], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 場所CP
            System.assertEquals('場所ＣＰ', valueList[2], '⑥配置技術者選定依頼用CSV作成処理が不正です。');
            // 備考
            // 空文字列想定のため、valueList.size()が3の時点で想定通り。
        }

    // ⑦先行手配依頼書
        /**
         * @description ⑦先行手配依頼書用CSV作成テスト1
         */
        @isTest private static void createRequestForm7CsvTest1() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestBidManagement(1);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityBidManagementList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm7Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(9, headerList.size(), '⑦先行手配依頼書用CSV作成処理が不正です。');
            System.assertEquals('発行日,注文元,件名・工事名,案件番号,希望回答期限,場所,予想CP,予想WC,入札予定', header, '⑦先行手配依頼書用CSV作成処理が不正です。');
            System.assertEquals(9, valueList.size(), '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE, valueList[0], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 注文元
            System.assertEquals(testAccount.Name, valueList[1], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 件名・工事名
            System.assertEquals(testOpportunity.Name, valueList[2], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 案件番号
            System.assert(valueList[3].startsWith('（案件番号：'), '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 希望回答期限
            System.assertEquals('２０９９年１２月３１日', valueList[4], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 場所
            System.assertEquals(testRequestTask.RequestDestination__c, valueList[5], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 予想CP
            System.assertEquals('7', valueList[6], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 予想WC
            System.assertEquals('10', valueList[7], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 入札予定
            System.assertEquals('２０１４年０３月２１日', valueList[8], '⑦先行手配依頼書用CSV作成処理が不正です。');
        }

        /**
         * @description ⑦先行手配依頼書用CSV作成テスト2
         */
        @isTest private static void createRequestForm7CsvTest2() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestBidManagement(2);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityBidManagementList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm7Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(9, headerList.size(), '⑦先行手配依頼書用CSV作成処理が不正です。');
            System.assertEquals('発行日,注文元,件名・工事名,案件番号,希望回答期限,場所,予想CP,予想WC,入札予定', header, '⑦先行手配依頼書用CSV作成処理が不正です。');
            System.assertEquals(9, valueList.size(), '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE, valueList[0], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 注文元
            System.assertEquals(testAccount.Name, valueList[1], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 件名・工事名
            System.assertEquals(testOpportunity.Name, valueList[2], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 案件番号
            System.assert(valueList[3].startsWith('（案件番号：'), '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 希望回答期限
            System.assertEquals('２０９９年１２月３１日', valueList[4], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 場所
            System.assertEquals(testRequestTask.RequestDestination__c, valueList[5], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 予想CP
            System.assertEquals('7', valueList[6], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 予想WC
            System.assertEquals('10', valueList[7], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 入札予定
            System.assertEquals('　　　　年　　月　　日', valueList[8], '⑦先行手配依頼書用CSV作成処理が不正です。');
        }

        /**
         * @description ⑦先行手配依頼書用CSV作成テスト 最小限の値設定
         */
        @isTest private static void createRequestForm7CsvTestMin() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;
                
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityBidManagementList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm7Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(9, headerList.size(), '⑦先行手配依頼書用CSV作成処理が不正です。');
            System.assertEquals('発行日,注文元,件名・工事名,案件番号,希望回答期限,場所,予想CP,予想WC,入札予定', header, '⑦先行手配依頼書用CSV作成処理が不正です。');
            System.assertEquals(6, valueList.size(), '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE, valueList[0], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 注文元
            System.assertEquals('', valueList[1], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 件名・工事名
            System.assertEquals('', valueList[2], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 案件番号
            System.assert(valueList[3].startsWith('（案件番号：'), '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 希望回答期限
            System.assertEquals('２０２５年０９月０９日', valueList[4], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 場所
            System.assertEquals(testRequestTask.RequestDestination__c, valueList[5], '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 予想CP
            // 空文字列想定のため、valueList.size()が6の時点で想定通り。
            // 予想WC
            // 空文字列想定のため、valueList.size()が6の時点で想定通り。
            // 入札予定
            // 空文字列想定のため、valueList.size()が6の時点で想定通り。
        }

    // ⑧原低依頼書
        /**
         * @description⑧原低依頼書用CSV作成テスト1
         */
        @isTest private static void createRequestForm8CsvTest1() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestBidManagement(1);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityBidManagementList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm8Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(12, headerList.size(), '⑧原低依頼書用CSV作成処理が不正です。');
            System.assertEquals('発行日,ヘッダー_宛先,ヘッダー_発信元,注文元,件名・工事名,案件番号,希望回答期限,場所,予想CP,回答_宛先,回答_発信元,入札予定', header, '⑧原低依頼書用CSV作成処理が不正です。');
            System.assertEquals(12, valueList.size(), '⑧原低依頼書用CSV作成処理が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE, valueList[0], '⑧原低依頼書用CSV作成処理が不正です。');
            // ヘッダー_宛先
            System.assertEquals(testRequestTask.RequestTo__c + 'K殿', valueList[1], '⑧原低依頼書用CSV作成処理が不正です。');
            // ヘッダー_発信元
            System.assertEquals('(販事)' + testRequestTask.Requester__c + 'K', valueList[2], '⑧原低依頼書用CSV作成処理が不正です。');
            // 注文元
            System.assertEquals(testAccount.Name, valueList[3], '⑧原低依頼書用CSV作成処理が不正です。');
            // 件名・工事名
            System.assertEquals(testOpportunity.Name, valueList[4], '⑧原低依頼書用CSV作成処理が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[5], '⑧原低依頼書用CSV作成処理が不正です。');
            // 希望回答期限
            System.assertEquals('２０９９年１２月３１日', valueList[6], '⑧原低依頼書用CSV作成処理が不正です。');
            // 場所
            System.assertEquals(testRequestTask.RequestDestination__c, valueList[7], '⑧原低依頼書用CSV作成処理が不正です。');
            // 予想CP
            System.assertEquals('7', valueList[8], '⑧原低依頼書用CSV作成処理が不正です。');
            // 回答_宛先
            System.assertEquals(testRequestTask.Requester__c + 'K殿', valueList[9], '⑧原低依頼書用CSV作成処理が不正です。');
            // 回答_発信元
            System.assertEquals('(場所)'+ testRequestTask.RequestTo__c + 'K', valueList[10], '⑧原低依頼書用CSV作成処理が不正です。');
            // 入札予定
            System.assertEquals('２０１４年０３月２１日', valueList[11], '⑧原低依頼書用CSV作成処理が不正です。');
        }

        /**
         * @description⑧原低依頼書用CSV作成テスト2
         */
        @isTest private static void createRequestForm8CsvTest2() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                createTestRequestTask();
                createTestBidManagement(2);
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityBidManagementList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm8Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(12, headerList.size(), '⑧原低依頼書用CSV作成処理が不正です。');
            System.assertEquals('発行日,ヘッダー_宛先,ヘッダー_発信元,注文元,件名・工事名,案件番号,希望回答期限,場所,予想CP,回答_宛先,回答_発信元,入札予定', header, '⑧原低依頼書用CSV作成処理が不正です。');
            System.assertEquals(12, valueList.size(), '⑧原低依頼書用CSV作成処理が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE, valueList[0], '⑧原低依頼書用CSV作成処理が不正です。');
            // ヘッダー_宛先
            System.assertEquals(testRequestTask.RequestTo__c + 'K殿', valueList[1], '⑧原低依頼書用CSV作成処理が不正です。');
            // ヘッダー_発信元
            System.assertEquals('(販事)' + testRequestTask.Requester__c + 'K', valueList[2], '⑧原低依頼書用CSV作成処理が不正です。');
            // 注文元
            System.assertEquals(testAccount.Name, valueList[3], '⑧原低依頼書用CSV作成処理が不正です。');
            // 件名・工事名
            System.assertEquals(testOpportunity.Name, valueList[4], '⑧原低依頼書用CSV作成処理が不正です。');
            // 案件番号
            System.assertNotEquals(null, valueList[5], '⑧原低依頼書用CSV作成処理が不正です。');
            // 希望回答期限
            System.assertEquals('２０９９年１２月３１日', valueList[6], '⑧原低依頼書用CSV作成処理が不正です。');
            // 場所
            System.assertEquals(testRequestTask.RequestDestination__c, valueList[7], '⑧原低依頼書用CSV作成処理が不正です。');
            // 予想CP
            System.assertEquals('7', valueList[8], '⑧原低依頼書用CSV作成処理が不正です。');
            // 回答_宛先
            System.assertEquals(testRequestTask.Requester__c + 'K殿', valueList[9], '⑧原低依頼書用CSV作成処理が不正です。');
            // 回答_発信元
            System.assertEquals('(場所)'+ testRequestTask.RequestTo__c + 'K', valueList[10], '⑧原低依頼書用CSV作成処理が不正です。');
            // 入札予定
            System.assertEquals('　　　　年　　月　　日', valueList[11], '⑧原低依頼書用CSV作成処理が不正です。');
        }

        /**
         * @description⑧原低依頼書用CSV作成テスト 最小限の値設定
         */
        @isTest private static void createRequestForm8CsvTestMin() {
            // preparation
            String result;
            createUsers();
            System.runAs(testUser){
                testRequestTask = new RequestTask__c(
                    // insertに必要な項目
                    DueDate__c = Date.newInstance(2025, 9, 9)
                    , Requester__c = '本社　施設'
                    , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
                    , TaskCategory__c = '提案書作成依頼'
                    , UserDeptApproved__c = true
                    , RequestDestinationCc__c = '神電'
                );
                insert testRequestTask;
                
                RequestFormOutputGenerator.getRequestTask(testRequestTask.Id);
                RequestFormOutputGenerator.getOpportunityBidManagementList(testRequestTask.Id);

                // execution
                Test.startTest();
                result = RequestFormOutputGenerator.createRequestForm8Csv();
                Test.stopTest();
            }

            String header = result.substringBefore('\n');
            List<String> headerList = header.split(',');
            List<String> valueList = result.substringAfter('\n').split(',');

            // assertion
            System.assertEquals(12, headerList.size(), '⑧原低依頼書用CSV作成処理が不正です。');
            System.assertEquals('発行日,ヘッダー_宛先,ヘッダー_発信元,注文元,件名・工事名,案件番号,希望回答期限,場所,予想CP,回答_宛先,回答_発信元,入札予定', header, '⑧原低依頼書用CSV作成処理が不正です。');
            System.assertEquals(11, valueList.size(), '⑧原低依頼書用CSV作成処理が不正です。');
            // 発行日
            System.assertEquals(RequestFormOutputGenerator.EXECUTED_DATE, valueList[0], '⑧原低依頼書用CSV作成処理が不正です。');
            // ヘッダー_宛先
            System.assertEquals('K殿', valueList[1], '⑧原低依頼書用CSV作成処理が不正です。');
            // ヘッダー_発信元
            System.assertEquals('(販事)' + testRequestTask.Requester__c + 'K', valueList[2], '⑧原低依頼書用CSV作成処理が不正です。');
            // 注文元
            System.assertEquals('', valueList[3], '⑧原低依頼書用CSV作成処理が不正です。');
            // 件名・工事名
            System.assertEquals('', valueList[4], '⑧原低依頼書用CSV作成処理が不正です。');
            // 案件番号
            System.assert(valueList[5].startsWith('（案件番号：'), '⑦先行手配依頼書用CSV作成処理が不正です。');
            // 希望回答期限
            System.assertEquals('２０２５年０９月０９日', valueList[6], '⑧原低依頼書用CSV作成処理が不正です。');
            // 場所
            System.assertEquals(testRequestTask.RequestDestination__c, valueList[7], '⑧原低依頼書用CSV作成処理が不正です。');
            // 予想CP
            System.assertEquals('', valueList[8], '⑧原低依頼書用CSV作成処理が不正です。');
            // 回答_宛先
            System.assertEquals(testRequestTask.Requester__c + 'K殿', valueList[9], '⑧原低依頼書用CSV作成処理が不正です。');
            // 回答_発信元
            System.assertEquals('(場所)K', valueList[10], '⑧原低依頼書用CSV作成処理が不正です。');
            // 入札予定
            // 空文字列想定のため、valueList.size()が11の時点で想定通り。
        }

    /**
     * @description 半角→全角変換処理 テスト
     */
    @isTest private static void convertCharacterWidthHalfToFullTest() {
        // preparation
        String param = '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzあ';
        String result;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.convertCharacterWidthHalfToFull(param);
        Test.stopTest();

        // assertion
        System.assertEquals('－０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚあ', result, '半角→全角変換処理が不正です。');
    }

    /**
     * @description 提案先設定処理 テスト
     */
    private static String setProposalTest(String type) {
        // preparation
        String result;
        String name;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setProposal(type, 'テスト提案先');
        Test.stopTest();

        return result;
    }

    /**
     * @description 提案先設定処理 テスト
     */
    @isTest private static void setProposalTestEndUser() {
        String result = setProposalTest('エンドユーザー');

        // assertion
        System.assertEquals('■最終顧客・部署 (テスト提案先)', result, '確度設定処理が不正です。');
    }

    /**
     * @description 提案先設定処理 テスト
     */
    @isTest private static void setProposalTestTheOther() {
        String result = setProposalTest('その他');

        // assertion
        System.assertEquals('□最終顧客・部署 (    　　　)', result, '確度設定処理が不正です。');
    }

    /**
     * @description 提案先設定処理 テスト
     */
    @isTest private static void setProposalTestNull() {
        String result = setProposalTest(null);

        // assertion
        System.assertEquals('□最終顧客・部署 (    　　　)', result, '確度設定処理が不正です。');
    }

    /**
     * @description 配置技術者の有無設定処理 テスト
     */
    private static List<String> setAvailabilityTest(String status) {
        // preparation
        List<String> result = new List<String>();

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setAvailability(status);
        Test.stopTest();

        return result;
    }

    /**
     * @description 配置技術者の有無設定処理 テスト
     */
    @isTest private static void setAvailabilityTestDone() {
        List<String> result = setAvailabilityTest('配置済');

        // assertion
        System.assertEquals('■有', result[0], '配置技術者の有無設定処理が不正です。');
        System.assertEquals('□無', result[1], '配置技術者の有無設定処理が不正です。');
    }

    /**
     * @description 配置技術者の有無設定処理 テスト
     */
    @isTest private static void setAvailabilityTestAssined() {
        List<String> result = setAvailabilityTest('配置予定');

        // assertion
        System.assertEquals('■有', result[0], '配置技術者の有無設定処理が不正です。');
        System.assertEquals('□無', result[1], '配置技術者の有無設定処理が不正です。');
    }

    /**
     * @description 配置技術者の有無設定処理 テスト
     */
    @isTest private static void setAvailabilityTestOther() {
        List<String> result = setAvailabilityTest(null);

        // assertion
        System.assertEquals('□有', result[0], '配置技術者の有無設定処理が不正です。');
        System.assertEquals('■無', result[1], '配置技術者の有無設定処理が不正です。');
    }

    /**
     * @description 確度設定処理 テスト
     */
    private static String setExpectationTest(String param) {
        // preparation
        String result;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setExpectation(param);
        Test.stopTest();

        return result;
    }

    /**
     * @description 確度設定処理 テスト1
     */
    @isTest private static void setExpectationTest1() {
        String result = setExpectationTest('1');

        // assertion
        System.assertEquals('"■1 決定，□2 有望，□3 努力，□4C チャレンジ，□4 希望，□5 需要"', result, '確度設定処理が不正です。');
    }

    /**
     * @description 確度設定処理 テスト2
     */
    @isTest private static void setExpectationTest2() {
        String result = setExpectationTest('2');

        // assertion
        System.assertEquals('"□1 決定，■2 有望，□3 努力，□4C チャレンジ，□4 希望，□5 需要"', result, '確度設定処理が不正です。');
    }

    /**
     * @description 確度設定処理 テスト3
     */
    @isTest private static void setExpectationTest3() {
        String result = setExpectationTest('3');

        // assertion
        System.assertEquals('"□1 決定，□2 有望，■3 努力，□4C チャレンジ，□4 希望，□5 需要"', result, '確度設定処理が不正です。');
    }

    /**
     * @description 確度設定処理 テスト4C
     */
    @isTest private static void setExpectationTest4C() {
        String result = setExpectationTest('4C');

        // assertion
        System.assertEquals('"□1 決定，□2 有望，□3 努力，■4C チャレンジ，□4 希望，□5 需要"', result, '確度設定処理が不正です。');
    }

    /**
     * @description 確度設定処理 テスト4
     */
    @isTest private static void setExpectationTest4() {
        String result = setExpectationTest('4');

        // assertion
        System.assertEquals('"□1 決定，□2 有望，□3 努力，□4C チャレンジ，■4 希望，□5 需要"', result, '確度設定処理が不正です。');
    }

    /**
     * @description 確度設定処理 テスト5
     */
    @isTest private static void setExpectationTest5() {
        String result = setExpectationTest('5');

        // assertion
        System.assertEquals('"□1 決定，□2 有望，□3 努力，□4C チャレンジ，□4 希望，■5 需要"', result, '確度設定処理が不正です。');
    }

    /**
     * @description 工事設定処理 テスト 電気工事
     */
    @isTest private static void setConstructionTestElectric() {
        // preparation
        String result;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setConstruction('電気工事');
        Test.stopTest();

        System.assertEquals('■建設業法対象', result, '工事設定処理が不正です。');
    }

    /**
     * @description 工事設定処理 テスト その他
     */
    @isTest private static void setConstructionTestOther() {
        // preparation
        String result;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setConstruction('その他');
        Test.stopTest();

        System.assertEquals('□建設業法対象', result, '工事設定処理が不正です。');
    }

    /**
     * @description 売報番号フォーマット処理 Blank
     */
    @isTest private static void formatSrNoTestBlank() {
        // preparation
        String result;
        String srNumberMain;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.formatSrNo(srNumberMain);
        Test.stopTest();

        // assertion
        System.assertEquals('', result, '売報番号フォーマット処理が不正です。');
    }

    /**
     * @description 売報番号フォーマット処理 10桁未満
     */
    @isTest private static void formatSrNoTestShort() {
        // preparation
        String result;
        String srNumberMain = '123456789';

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.formatSrNo(srNumberMain);
        Test.stopTest();

        // assertion
        System.assertEquals(srNumberMain, result, '売報番号フォーマット処理が不正です。');
    }

    /**
     * @description 売報番号フォーマット処理
     */
    @isTest private static void formatSrNoTest1() {
        // preparation
        String result;
        String srNumberMain = 'A1234Z5670';

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.formatSrNo(srNumberMain);
        Test.stopTest();

        // assertion
        System.assertEquals('A1234-Z567-0', result, '売報番号フォーマット処理が不正です。');
    }

    /**
     * @description 継承付与処理(仮)
     */
    @isTest private static void setPostAndTitleTestSet() {
        // preparation
        String result;
        String name = 'テスト';
        String title = 'Ｋ殿';

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setPostAndTitle(name, title);
        Test.stopTest();

        // assertion
        System.assertEquals('テストＫ殿', result, '継承付与処理が不正です。');
    }

    /**
     * @description 継承付与処理(仮)
     */
    @isTest private static void setPostAndTitleTestBlank() {
        // preparation
        String result;
        String name;
        String title = 'Ｋ殿';

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setPostAndTitle(name, title);
        Test.stopTest();

        // assertion
        System.assertEquals('', result, '継承付与処理が不正です。');
    }

    /**
     * @description Date型フォーマット処理
     * Date型→DateTime型→Format
     */
    @isTest private static void formatDateTest() {
        // preparation
        String result;
        Date testDate = Date.newInstance(2022, 2, 22);

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.formatDate(testDate, 'yyyy年MM月dd日');
        Test.stopTest();

        // assertion
        System.assertEquals('2022年02月22日', result, 'Date型フォーマット処理が不正です。');
    }

    /**
     * @description Date型フォーマット処理
     * Date型→DateTime型→Format
     */
    @isTest private static void formatDateTestNull() {
        // preparation
        String result;
        Date testDate;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.formatDate(testDate, 'yyyy年MM月dd日');
        Test.stopTest();

        // assertion
        System.assertEquals('', result, 'Date型フォーマット処理が不正です。');
    }

    /**
     * @description 千円単位変換四捨五入処理テスト 四捨
     */
    @isTest private static void convertTo1000YenAndRoundHalfUpTestDown() {
        // preparation
        String result;
        Decimal amount = 1400;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.convertTo1000YenAndRoundHalfUp(amount);
        Test.stopTest();

        // assertion
        System.assertEquals('1', result, '千円単位変換四捨五入処理が不正です。');
    }

    /**
     * @description 千円単位変換四捨五入処理テスト 五入
     */
    @isTest private static void convertTo1000YenAndRoundHalfUpTestUp() {
        // preparation
        String result;
        Decimal amount = 1500;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.convertTo1000YenAndRoundHalfUp(amount);
        Test.stopTest();

        // assertion
        System.assertEquals('2', result, '千円単位変換四捨五入処理が不正です。');
    }

    /**
     * @description 千円単位変換四捨五入処理テスト null
     */
    @isTest private static void convertTo1000YenAndRoundHalfUpTestNull() {
        // preparation
        String result;
        Decimal amount;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.convertTo1000YenAndRoundHalfUp(amount);
        Test.stopTest();

        // assertion
        System.assertEquals('', result, '千円単位変換四捨五入処理が不正です。');
    }

    /**
     * @description 千円単位変換四捨五入処理テスト 0
     */
    @isTest private static void convertTo1000YenAndRoundHalfUpTest0() {
        // preparation
        String result;
        Decimal amount = 0;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.convertTo1000YenAndRoundHalfUp(amount);
        Test.stopTest();

        // assertion
        System.assertEquals('0', result, '千円単位変換四捨五入処理が不正です。');
    }

    /**
     * @description ヘッダー_発信元検印設定処理テスト
     */
    @isTest private static void setApproverTest1() {
        // preparation
        String result;
        createUsers();

        testRequestTask = new RequestTask__c(
            UserDeptLastApprover__c = '承認者1'
            , Approver1__c = testApprover1.Id
            , Approver2__c = testApprover2.Id
            , Approver3__c = testApprover3.Id
            
            // insertに必要な項目
            , DueDate__c = Date.newInstance(2025, 9, 18)
            , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
            , Requester__c = '本社　施設'
            , TaskCategory__c = '提案書作成依頼'
            , RequestDestinationCc__c = '神電'
            , OwnerId = testUser.Id
        );
        insert testRequestTask;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setApprover(testRequestTask);
        Test.stopTest();

        // assertion
        System.assertEquals(testApprover1.Name, result, 'ヘッダー_発信元検印設定処理テストが不正です。');
    }

    /**
     * @description ヘッダー_発信元検印設定処理テスト
     */
    @isTest private static void setApproverTest2() {
        // preparation
        String result;
        createUsers();

        testRequestTask = new RequestTask__c(
            UserDeptLastApprover__c = '承認者2'
            , Approver1__c = testApprover1.Id
            , Approver2__c = testApprover2.Id
            , Approver3__c = testApprover3.Id
            
            // insertに必要な項目
            , DueDate__c = Date.newInstance(2025, 9, 18)
            , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
            , Requester__c = '本社　施設'
            , TaskCategory__c = '提案書作成依頼'
            , RequestDestinationCc__c = '神電'
            , OwnerId = testUser.Id
        );
        insert testRequestTask;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setApprover(testRequestTask);
        Test.stopTest();

        // assertion
        System.assertEquals(testApprover2.Name, result, 'ヘッダー_発信元検印設定処理テストが不正です。');
    }

    /**
     * @description ヘッダー_発信元検印設定処理テスト
     */
    @isTest private static void setApproverTest3() {
        // preparation
        String result;
        createUsers();

        testRequestTask = new RequestTask__c(
            UserDeptLastApprover__c = '承認者3'
            , Approver1__c = testApprover1.Id
            , Approver2__c = testApprover2.Id
            , Approver3__c = testApprover3.Id
            
            // insertに必要な項目
            , DueDate__c = Date.newInstance(2025, 9, 18)
            , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
            , Requester__c = '本社　施設'
            , TaskCategory__c = '提案書作成依頼'
            , RequestDestinationCc__c = '神電'
            , OwnerId = testUser.Id
        );
        insert testRequestTask;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setApprover(testRequestTask);
        Test.stopTest();

        // assertion
        System.assertEquals(testApprover3.Name, result, 'ヘッダー_発信元検印設定処理テストが不正です。');
    }

    /**
     * @description ヘッダー_発信元検印設定処理テスト
     */
    @isTest private static void setApproverTestOther() {
        // preparation
        String result;
        createUsers();

        testRequestTask = new RequestTask__c(
            UserDeptLastApprover__c = null
            , Approver1__c = testApprover1.Id
            , Approver2__c = testApprover2.Id
            , Approver3__c = testApprover3.Id
            
            // insertに必要な項目
            , DueDate__c = Date.newInstance(2025, 9, 18)
            , RequestDestination__c = '神電' // RequestFactoryName__c '神戸製作所'
            , Requester__c = '本社　施設'
            , TaskCategory__c = '提案書作成依頼'
            , RequestDestinationCc__c = '神電'
            , OwnerId = testUser.Id
        );
        insert testRequestTask;

        // execution
        Test.startTest();
        result = RequestFormOutputGenerator.setApprover(testRequestTask);
        Test.stopTest();

        // assertion
        System.assertEquals('', result, 'ヘッダー_発信元検印設定処理テストが不正です。');
    }
}