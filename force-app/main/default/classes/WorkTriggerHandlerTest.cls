@isTest
private class WorkTriggerHandlerTest {
    // 定数
    // workの商談番号
    private static final String WORK_OPPORTUNITY_NUMBER_MAIN = 'F3280U0450';
    // workの商談番号2
    private static final String WORK_OPPORTUNITY_NUMBER_MAIN2 = 'F3280U0451';
    // workの商談番号(setup)
    private static final String WORK_OPPORTUNITY_NUMBER_MAIN_SETUP = 'F3280U0452';
    // 意図のない商談番号
    private static final String COMMON_OPPORTUNITY_NUMBER = 'F3280U0452';
    // 存在しない案件の商談番号
    private static final String NONE_OPPORTUNITY_NUMBER = 'F3999U0450';
    // SR情報の商談番号
    private static final String SRINFO_OPPORTUNITY_NUMBER = 'F3280U0460';
    // SR情報の商談番号2
    private static final String SRINFO_OPPORTUNITY_NUMBER2 = 'F3280U0461';
    // 案件の商談番号
    private static final String OPPORTUNITY_OPPORTUNITY_NUMBER = 'F3280U0490';
    private static final String OPPORTUNITY_OPPORTUNITY_NUMBER_HYPHEN = 'F3280-U049-0';
    // 案件の商談番号2
    private static final String OPPORTUNITY_OPPORTUNITY_NUMBER2 = 'F3280U0491';
    private static final String OPPORTUNITY_OPPORTUNITY_NUMBER2_HYPHEN = 'F3280-U049-1';
    // オーダー管理台帳の商談番号1
    private static final String ORDER_MANAGEMENT_LEDGER_OPPORTUNITY_NUMBER1 = 'F3280U0470';
    // オーダー管理台帳の商談番号2
    private static final String ORDER_MANAGEMENT_LEDGER_OPPORTUNITY_NUMBER2 = 'F3280U0480';
    // オーダー管理台帳の商談番号3
    private static final String ORDER_MANAGEMENT_LEDGER_OPPORTUNITY_NUMBER3 = 'F3280U0490';
    // オーダー管理台帳の商談番号4
    private static final String ORDER_MANAGEMENT_LEDGER_OPPORTUNITY_NUMBER4 = 'F3280U0500';

    // workの売報番号（ボディ番号）1
    private static final String WORK_SR_NUMBER_BODY1 = 'A3280V001';
    // workの売報番号（ボディ番号）2
    private static final String WORK_SR_NUMBER_BODY2 = 'A3280V002';
    // workの売報番号（ボディ番号）3
    private static final String WORK_SR_NUMBER_BODY3 = 'A3280V003';
    // SR情報の売報番号（ボディ番号）
    private static final String SRINFO_SR_NUMBER_BODY = 'A3280V004';
    // 案件の売報番号（ボディ番号）
    private static final String OPPORTUNITY_SR_NUMBER_BODY = 'A3280V005';
    // オーダー管理台帳の売報番号（ボディ番号）1
    private static final String ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY1 = 'A3280-V006-';
    // オーダー管理台帳の売報番号（ボディ番号）2
    private static final String ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY2 = 'A3280-V007-';
    // オーダー管理台帳の売報番号（ボディ番号）3
    private static final String ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY3 = 'A3280-V008-';
    // オーダー管理台帳の売報番号（ボディ番号）1と一致するwork用の売報番号（ボディ番号）
    private static final String ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY1_FOR_WORK = 'A3280V006';
    // オーダー管理台帳の売報番号（ボディ番号）2と一致するwork用の売報番号（ボディ番号）
    private static final String ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY2_FOR_WORK = 'A3280V007';
    // オーダー管理台帳の売報番号（ボディ番号）3と一致するwork用の売報番号（ボディ番号）
    private static final String ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY3_FOR_WORK = 'A3280V008';

    // 意図のないJ項番号
    private static final String COMMON_J_NUMBER = '101';

    /*
    * テストデータ作成
    */
    private static void createTestWork(){
        // work
        List<work__c> testWorkList = new List<work__c>{
            new work__c(
                OpportunityNumber__c = WORK_OPPORTUNITY_NUMBER_MAIN_SETUP   // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY3 + '0'                 // 売報番号
                , J_Number__c = COMMON_J_NUMBER                             // J項番号
                , AffiliationName__c = 'testSetup_work所属名称'      // 所属名称
                , Subject__c = 'createTestWork：testWorkList1件目'
            )
        };
        insert testWorkList;
    }

    private static void createTestSRInfo(){
        // SR情報
        List<SRInfo__c> testSRInfoList = new List<SRInfo__c>{
            new SRInfo__c(
                OP_Number__c = SRINFO_OPPORTUNITY_NUMBER        // 商談番号
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'    // 売報番号
                , J_Number__c = COMMON_J_NUMBER                 // J項番号
                , AffiliationName__c = 'testSetup_SR情報所属名称'      // 所属名称
                , Subject__c = 'createTestSRInfo：testSRInfoList1件目'
            )
        };
        insert testSRInfoList;
    }

    public static SupplySite__c createSupplySite() {
        SupplySite__c supplySite = new SupplySite__c(Name='テスト納入サイト', SBU__c='建設防災');
        insert supplySite;
        return supplySite;
    }

    private static void createTestOpportunity(){
        // 案件
        List<Opportunity> testOpportunityList = new List<Opportunity>{
            new Opportunity(
                // required
                AdoptedSpecification__c = '技術優位性(当社のみ対応可)'    // 当社仕様採用 選択リスト (複数選択)
                , AutoCalculateCheck__c = false                         // 発行・回収予定 自動計算 boolean
                , IsPrivate = false                                     // 非公開 boolean
                , MPEC_opp__c = false                                   // MPEC協業案件 boolean
                , ProposedTechnique__c = false                          // 当社技術提案済 boolean
                , CloseDate = Date.today().addDays(1)                   // 受注予定日 date
                , Probability = 0                                       // 確度(%) percent (3, 0)
                , StageName = '基本設計'                                // フェーズ picklist (255)
                , Name = 'Unit Test Opportunity'                        // 案件名 string (120)

                // テストに必要な項目
                , OpportunityNumber__c = OPPORTUNITY_OPPORTUNITY_NUMBER_HYPHEN // 商談番号
                , SR_Number_Main__c = OPPORTUNITY_SR_NUMBER_BODY + '0'  // 売報番号

                // FIELD_CUSTOM_VALIDATION対策
                , BU__c = '官需'                                        // BU
                , ConstructionDistinction__c = '新設'                   // 工事区分
                , SupplySite__c = createSupplySite().id                 // 納入サイト
            )
        };
        insert testOpportunityList;
    }

    private static void createTestOrderManagementLedgerList(){
        // オーダー管理台帳
        List<OrderManagementLedger__c> testOrderManagementLedgerList = new List<OrderManagementLedger__c>{
            new OrderManagementLedger__c(
                OpportunityNumber__c = ORDER_MANAGEMENT_LEDGER_OPPORTUNITY_NUMBER1  // 商談番号
                , SR_Number__c = ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY1 + '0'      // 売報番号
                , ItemNumber__c = COMMON_J_NUMBER                                   // 項目番号
            )
            , new OrderManagementLedger__c(
                OpportunityNumber__c = ORDER_MANAGEMENT_LEDGER_OPPORTUNITY_NUMBER2  // 商談番号
                , SR_Number__c = ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY2 + '1'      // 売報番号
                , ItemNumber__c = COMMON_J_NUMBER                                   // 項目番号
            )
            , new OrderManagementLedger__c(
                OpportunityNumber__c = ORDER_MANAGEMENT_LEDGER_OPPORTUNITY_NUMBER2  // 商談番号
                , SR_Number__c = ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY2 + '2'      // 売報番号
                , ItemNumber__c = COMMON_J_NUMBER                                   // 項目番号
            )
            , new OrderManagementLedger__c(
                OpportunityNumber__c = ORDER_MANAGEMENT_LEDGER_OPPORTUNITY_NUMBER3  // 商談番号
                , SR_Number__c = ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY3 + '1'      // 売報番号
                , ItemNumber__c = COMMON_J_NUMBER                                   // 項目番号
            )
            , new OrderManagementLedger__c(
                OpportunityNumber__c = ORDER_MANAGEMENT_LEDGER_OPPORTUNITY_NUMBER4  // 商談番号
                , SR_Number__c = ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY3 + '2'      // 売報番号
                , ItemNumber__c = COMMON_J_NUMBER                                   // 項目番号
            )
        };
        insert testOrderManagementLedgerList;
    }

    /*
    * work内で売報番号が一致するレコードの商談番号をworkに付与 の正常系テスト
    */
    @isTest static void assignByExactMatchedWorkTest_Success() {
        /* preparation */
        List<work__c> testWorkList = new List<work__c>{
            new work__c(
                OpportunityNumber__c = COMMON_OPPORTUNITY_NUMBER    // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '0'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList1件目'
            )
            , new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '0'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList2件目'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorkList;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];

        /* assertion */
        // testWorkList2件目の商談番号がtestWorkList1件目に付与されていることを検証
        System.assertEquals(2, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(insertedWorks[1].OpportunityNumber__c, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * work内で売報番号（ボディ番号）が一致するレコードの商談番号をworkに付与 の正常系テスト：新規work内で単一一致
    */
    @isTest static void assignByWorkTest_SingleMatchWithNew_Success() {
        /* preparation */
        List<work__c> testWorkList = new List<work__c>{
            new work__c(
                OpportunityNumber__c = COMMON_OPPORTUNITY_NUMBER    // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '0'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList1件目'
            )
            , new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '1'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList2件目'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorkList;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];

        /* assertion */
        // testWorkList2件目の商談番号がtestWorkList1件目に付与されていることを検証
        System.assertEquals(2, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(insertedWorks[1].OpportunityNumber__c, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * work内で売報番号（ボディ番号）が一致するレコードの商談番号をworkに付与 の正常系テスト：既存workと単一一致
    */
    @isTest static void assignByWorkTest_SingleMatchedWithExisting_Success() {
        /* preparation */
        createTestWork();
        List<work__c> testWorkList = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY3 + '1'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList1件目'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorkList;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];

        /* assertion */
        // createTestWork()で作成したworkの商談番号がtestWorkList1件目に付与されていることを検証
        System.assertEquals(2, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(insertedWorks[0].OpportunityNumber__c, insertedWorks[1].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * work内で売報番号（ボディ番号）が一致するレコードの商談番号をworkに付与 の準正常系テスト：既存workで複数一致
    */
    @isTest static void assignByWorkTest_MultiMatched_Unassigned() {
        /* preparation */
        List<work__c> testWorkList = new List<work__c>{
            new work__c(
                OpportunityNumber__c = WORK_OPPORTUNITY_NUMBER_MAIN // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY3 + '1'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList1件目'
            )
            , new work__c(
                OpportunityNumber__c = WORK_OPPORTUNITY_NUMBER_MAIN2 // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY3 + '2'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList2件目'
            )
            , new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY3 + '3'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList2件目'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorkList;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];

        /* assertion */
        System.assertEquals(3, insertedWorks.size(), '商談番号付与処理が不正です。');
        System.assertEquals(null, insertedWorks[2].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * 売報番号が一致するSR情報レコードの商談番号をworkに付与 の正常系テスト
    */
    @isTest static void assignByExactMatchedSRInfoTest_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorkList = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList1件目'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorkList;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c, Subject__c FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> insertedSRInfo = [SELECT OP_Number__c, Subject__c FROM SRInfo__c];

        /* assertion */
        // SR情報の商談番号がtestWorkList1件目に付与されていることを検証
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(1, insertedSRInfo.size(), 'SR情報の件数が不正です。');
        System.assertEquals(insertedSRInfo[0].OP_Number__c, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * 売報番号（ボディ番号）が一致するSR情報レコードの商談番号をworkに付与 の正常系テスト
    */
    @isTest static void assignByPartialMatchedSRInfoTest_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorkList = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '1'        // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList1件目'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorkList;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> insertedSRInfo = [SELECT OP_Number__c FROM SRInfo__c];

        /* assertion */
        // SR情報の商談番号がtestWorkList1件目に付与されていることを検証
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(2, insertedSRInfo.size(), 'SR情報の件数が不正です。');
        System.assertEquals(insertedSRInfo[0].OP_Number__c, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * 売報番号（ボディ番号）が一致するSR情報レコードの商談番号をworkに付与 の準正常系テスト
    */
    @isTest static void assignByPartialMatchedSRInfoTest_Unassigned() {
        /* preparation */
        // SR情報
        createTestSRInfo();
        List<SRInfo__c> testSRInfoList = new List<SRInfo__c>{
            new SRInfo__c(
                OP_Number__c = SRINFO_OPPORTUNITY_NUMBER2        // 商談番号
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '1'    // 売報番号
                , J_Number__c = COMMON_J_NUMBER                 // J項番号
                , AffiliationName__c = 'testSetup_SR情報所属名称'      // 所属名称
                , Subject__c = 'testSRInfoList1件目'
            )
        };
        insert testSRInfoList;

        List<work__c> testWorkList = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '2'        // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , Subject__c = 'testWorkList1件目'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorkList;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];

        /* assertion */
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(null, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * 売報番号が一致する案件レコードの商談番号をworkに付与 の正常系テスト
    */
    @isTest static void assignByExactMatchedOpportunityTest_Success() {
        /* preparation */
        createTestOpportunity();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = OPPORTUNITY_SR_NUMBER_BODY + '0'   // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];
        List<Opportunity> insertedOpportunity = [SELECT OpportunityNumber_Hyphenless__c FROM Opportunity];

        /* assertion */
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(1, insertedOpportunity.size(), '案件の件数が不正です。');
        System.assertEquals(insertedOpportunity[0].OpportunityNumber_Hyphenless__c, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * 売報番号（ボディ番号）が一致する案件レコードの商談番号をworkに付与 の正常系テスト
    */
    @isTest static void assignByPartialMatchedOpportunityTest_Success() {
        /* preparation */
        createTestOpportunity();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = OPPORTUNITY_SR_NUMBER_BODY + '1'   // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];
        List<Opportunity> insertedOpportunity = [SELECT OpportunityNumber_Hyphenless__c FROM Opportunity];

        /* assertion */
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(1, insertedOpportunity.size(), '案件の件数が不正です。');
        System.assertEquals(insertedOpportunity[0].OpportunityNumber_Hyphenless__c, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * 売報番号（ボディ番号）が一致する案件レコードの商談番号をworkに付与 の準正常系テスト
    */
    @isTest static void assignByPartialMatchedOpportunityTest_Unassiged() {
        /* preparation */
        createTestOpportunity();
        // 案件
        List<Opportunity> testOpportunityList = new List<Opportunity>{
            new Opportunity(
                // required
                AdoptedSpecification__c = '技術優位性(当社のみ対応可)'    // 当社仕様採用 選択リスト (複数選択)
                , AutoCalculateCheck__c = false                         // 発行・回収予定 自動計算 boolean
                , IsPrivate = false                                     // 非公開 boolean
                , MPEC_opp__c = false                                   // MPEC協業案件 boolean
                , ProposedTechnique__c = false                          // 当社技術提案済 boolean
                , CloseDate = Date.today().addDays(1)                   // 受注予定日 date
                , Probability = 0                                       // 確度(%) percent (3, 0)
                , StageName = '基本設計'                                // フェーズ picklist (255)
                , Name = 'Unit Test Opportunity'                        // 案件名 string (120)

                // テストに必要な項目
                , OpportunityNumber__c = OPPORTUNITY_OPPORTUNITY_NUMBER2_HYPHEN // 商談番号
                , SR_Number_Main__c = OPPORTUNITY_SR_NUMBER_BODY + '1'   // 売報番号

                // FIELD_CUSTOM_VALIDATION対策
                , BU__c = '官需'                                        // BU
                , ConstructionDistinction__c = '新設'                   // 工事区分
                , SupplySite__c = createSupplySite().id                 // 納入サイト
            )
        };
        insert testOpportunityList;

        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = OPPORTUNITY_SR_NUMBER_BODY + '2'   // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];
        List<Opportunity> insertedOpportunity = [SELECT OpportunityNumber_Hyphenless__c FROM Opportunity ORDER BY CreatedDate];

        /* assertion */
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(2, insertedOpportunity.size(), '案件の件数が不正です。');
        System.assertEquals(insertedOpportunity[0].OpportunityNumber_Hyphenless__c, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * 売報番号が一致するオーダー管理台帳の商談番号をworkに付与 の正常系テスト
    */
    @isTest static void assignByExactMatchedOrderManagementLedgerTest_Success() {
        /* preparation */
        createTestOrderManagementLedgerList();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                                             // 商談番号
                , SR_Number__c = ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY1_FOR_WORK + '0' // 売報番号
                , J_Number__c = COMMON_J_NUMBER                                         // J項番号
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];
        List<OrderManagementLedger__c> insertedOrderManagementLedgers = [SELECT OpportunityNumber__c FROM OrderManagementLedger__c];

        /* assertion */
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(5, insertedOrderManagementLedgers.size(), 'オーダー管理台帳の件数が不正です。');
        System.assertEquals(insertedOrderManagementLedgers[0].OpportunityNumber__c, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * 売報番号が一致するオーダー管理台帳の商談番号をworkに付与 の準正常系テスト
    */
    @isTest static void assignByExactMatchedOrderManagementLedgerTest_Unassigned() {
        /* preparation */
        createTestOrderManagementLedgerList();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY2 + '0'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c FROM work__c ORDER BY CreatedDate];

        /* assertion */
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(null, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
    }

    /*
    * 売報番号（ボディ番号）が一致するオーダー管理台帳の商談番号をworkに付与 の正常系テスト
    */
    @isTest static void assignByPartialMatchedOrderManagementLedgerTest_Success() {
        /* preparation */
        createTestOrderManagementLedgerList();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                                             // 商談番号
                , SR_Number__c = ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY2_FOR_WORK + '0' // 売報番号
                , J_Number__c = COMMON_J_NUMBER                                         // J項番号
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c, Warning__c FROM work__c ORDER BY CreatedDate];
        List<OrderManagementLedger__c> insertedOrderManagementLedgers = [SELECT OpportunityNumber__c FROM OrderManagementLedger__c];

        /* assertion */
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(5, insertedOrderManagementLedgers.size(), 'オーダー管理台帳の件数が不正です。');
        System.assertEquals(insertedOrderManagementLedgers[1].OpportunityNumber__c, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
        System.assertEquals(null, insertedWorks[0].Warning__c, 'ワーニングが不正です。');
    }

    /*
    * 売報番号（ボディ番号）が一致するオーダー管理台帳の商談番号をworkに付与 の準正常系テスト
    */
    @isTest static void assignByPartialMatchedOrderManagementLedgerTest_Warning() {
        /* preparation */
        createTestOrderManagementLedgerList();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                                             // 商談番号
                , SR_Number__c = ORDER_MANAGEMENT_LEDGER_SR_NUMBER_BODY3_FOR_WORK + '0' // 売報番号
                , J_Number__c = COMMON_J_NUMBER                                         // J項番号
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT OpportunityNumber__c, Warning__c FROM work__c ORDER BY CreatedDate];

        /* assertion */
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(null, insertedWorks[0].OpportunityNumber__c, '商談番号付与処理が不正です。');
        System.assertEquals('商談番号を付与できませんでした。', insertedWorks[0].Warning__c, 'ワーニングが不正です。');
    }

    /*
    * workのListから『商談番号無しのworkのList』と『商談番号無しのworkの売報番号（ボディ番号）のSet』を作成し『商談番号無しのworkの有無』を返却 の正常系テスト
    */
    @isTest static void hasNumberlessWorksTest_Success() {
        /* preparation */
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = WORK_OPPORTUNITY_NUMBER_MAIN // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '0'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
            , new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '1'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
            , new work__c(
                OpportunityNumber__c = COMMON_OPPORTUNITY_NUMBER    // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '2'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
        };
        Boolean result;

        /* execution */
        Test.startTest();
        result = WorkTriggerHandler.hasNumberlessWorks(testWorks);
        Test.stopTest();

        /* assertion */
        System.assertEquals(1, WorkTriggerHandler.numberlessWorkList.size(), '商談番号無しのwork件数が不正です。');
        System.assert(WorkTriggerHandler.numberlessWorkList.contains(testWorks[1]), '商談番号無しのwork内容が不正です。');
        System.assertEquals(1, WorkTriggerHandler.numberlessWorkSRNumberBodySet.size(), '商談番号無しのworkの売報番号（ボディ番号）件数が不正です。');
        System.assert(WorkTriggerHandler.numberlessWorkSRNumberBodySet.contains(testWorks[1].SR_Number_Body__c), '商談番号無しのworkの売報番号（ボディ番号）内容が不正です。');
        System.assertEquals(true, result, '商談番号無しのworkの有無が不正です。');
    }

    /*
    * workのListから『商談番号無しのworkのList』と『商談番号無しのworkの売報番号（ボディ番号）のSet』を作成し『商談番号無しのworkの有無』を返却 の準正常系テスト
    */
    @isTest static void hasNumberlessWorksTest_Empty() {
        /* preparation */
        List<work__c> testWorks = new List<work__c>{
        };
        Boolean result;

        /* execution */
        Test.startTest();
        result = WorkTriggerHandler.hasNumberlessWorks(testWorks);
        Test.stopTest();

        /* assertion */
        System.assertEquals(0, WorkTriggerHandler.numberlessWorkList.size(), '商談番号無しのwork件数が不正です。');
        System.assertEquals(0, WorkTriggerHandler.numberlessWorkSRNumberBodySet.size(), '商談番号無しのworkの売報番号（ボディ番号）件数が不正です。');
        System.assertEquals(false, result, '商談番号無しのworkの有無が不正です。');
    }

    /*
    * ワーニング設定 の正常系テスト
    */
    @isTest static void setWarningTest_Success() {
        /* preparation */
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = WORK_OPPORTUNITY_NUMBER_MAIN // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '0'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
            , new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '1'         // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
        };

        /* execution */
        Test.startTest();
        WorkTriggerHandler.setWarning(testWorks);
        Test.stopTest();

        /* assertion */
        System.assertEquals(null, testWorks[0].Warning__c, 'ワーニング設定が不正です。');
        System.assertEquals('商談番号を付与できませんでした。', testWorks[1].Warning__c, 'ワーニング設定が不正です。');
    }

    /*
    * ワーニング設定(案件が無い場合) の正常系テスト
    */
    @isTest static void setWarningTest_Success_Noneopp() {
        /* preparation */
        createTestOpportunity();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = OPPORTUNITY_OPPORTUNITY_NUMBER   // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '0'             // 売報番号
                , J_Number__c = COMMON_J_NUMBER                         // J項番号
            )
            , new work__c(
                OpportunityNumber__c = NONE_OPPORTUNITY_NUMBER          // 商談番号
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '1'             // 売報番号
                , J_Number__c = COMMON_J_NUMBER                         // J項番号
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Warning__c FROM work__c ORDER BY CreatedDate];

        /* assertion */
        System.assertEquals(null, insertedWorks[0].Warning__c, 'ワーニング設定が不正です。');
        //System.assertEquals('この商談番号を持つ案件が見つかりませんでした。', insertedWorks[1].Warning__c, 'ワーニング設定が不正です。');
    }

    /*
    * 案件紐付け の正常系テスト
    */
    @isTest static void linkOpportunity_Success() {
        /* preparation */
        createTestOpportunity();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                OpportunityNumber__c = null                         // 商談番号
                , SR_Number__c = OPPORTUNITY_SR_NUMBER_BODY + '1'   // 売報番号
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Opportunity__c, OpportunityNumber__c FROM work__c ORDER BY CreatedDate];
        List<Opportunity> insertedOpportunity = [SELECT OpportunityNumber_Hyphenless__c FROM Opportunity];

        /* assertion */
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        System.assertEquals(1, insertedOpportunity.size(), '案件の件数が不正です。');
        System.assertEquals(insertedOpportunity[0].OpportunityNumber_Hyphenless__c, insertedWorks[0].OpportunityNumber__c, '案件紐付けが不正です。');
        //System.assertEquals(insertedOpportunity[0].Id, insertedWorks[0].Opportunity__c, '案件紐付けが不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：基本情報
    */
    @isTest static void upsertSRInfo_BasicInfo_Success() {
        /* preparation */
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：基本情報のみ'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , SRCP__c = 1
                , FinalForecastCP_ResultCP__c = 1
                , SRWC__c = 1
                , PriorityWC_ResultWC__c = 1
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 基本情報
                , AffiliationName__c            // 所属名称
                , ContactPersonName__c          // 担当者名称
                , SR_Number__c                  // 売報番号
                , Subject__c                    // 件名
                , OrderingSource__c             // 注文元
                , J_Number__c                   // J項番号
                , LocationName__c               // 場所名称
                , Opportunity__c                // 案件
                , OP_Number__c                  // 商談番号
                , Warning__c                    // ワーニング
                , UpsertByWorkTargetIdNumber__c // work反映先特定番号（売報番号＋J項番号）
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks1
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: testWorksから作られる1
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 基本情報
        System.assertEquals(testWorks[0].AffiliationName__c, upsertedSRInfoList[0].AffiliationName__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].ContactPersonName__c, upsertedSRInfoList[0].ContactPersonName__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SR_Number__c, upsertedSRInfoList[0].SR_Number__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].Subject__c, upsertedSRInfoList[0].Subject__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].Orderer__c, upsertedSRInfoList[0].OrderingSource__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].J_Number__c, upsertedSRInfoList[0].J_Number__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].LocationName__c, upsertedSRInfoList[0].LocationName__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].Opportunity__c, upsertedSRInfoList[0].Opportunity__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].OpportunityNumber__c, upsertedSRInfoList[0].OP_Number__c, 'SR情報の値が不正です。');
        System.assertEquals('商談番号を付与できませんでした。', upsertedSRInfoList[0].Warning__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SR_Number__c + testWorks[0].J_Number__c, upsertedSRInfoList[0].UpsertByWorkTargetIdNumber__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：受注時+受注後最新初回
    */
    @isTest static void upsertSRInfo_Order_Success() {
        /* preparation */
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：受注時+受注後最新初回'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , SRCP__c = 1
                , FinalForecastCP_ResultCP__c = 1
                , SRWC__c = 1
                , PriorityWC_ResultWC__c = 1
                , PlannedOrderDate__c = Date.today().addMonths(-1)
                , LatestRegistrationDate__c = Date.today().addMonths(-1).addDays(1)
                , OpportunityType__c = '手持'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 基本情報
                , AffiliationName__c            // 所属名称
                , ContactPersonName__c          // 担当者名称
                , SR_Number__c                  // 売報番号
                , Subject__c                    // 件名
                , OrderingSource__c             // 注文元
                , J_Number__c                   // J項番号
                , LocationName__c               // 場所名称
                , Opportunity__c                // 案件
                , OP_Number__c                  // 商談番号
                , Warning__c                    // ワーニング
                , UpsertByWorkTargetIdNumber__c // work反映先特定番号（売報番号＋J項番号）
                // 受注時
                , Order_SRCP__c             // SRCP（受注時）
                , Order_Forecast_SRCP__c    // 最終予想CP（受注時）
                , Order_SRWC__c             // SRWC（受注時）
                , Order_Forecast_SRWC__c    // 最終予想WC（受注時）
                , Order_OrderDate__c        // 受注年月日
                // 受注後最新
                , Latest_Forecast_SRCP__c       // 最終予想CP（最新）
                , Latest_Forecast_SRWC__c       // 最終予想WC（最新）
                , Latest_SRCP__c                // SRCP（最新）
                , Latest_SRWC__c                // SRWC（最新）
                , Latest_SRInfoUpdateDate__c    // SR情報取得日（最新）
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks1
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: testWorksから作られる1
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 基本情報
        System.assertEquals(testWorks[0].AffiliationName__c, upsertedSRInfoList[0].AffiliationName__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].ContactPersonName__c, upsertedSRInfoList[0].ContactPersonName__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SR_Number__c, upsertedSRInfoList[0].SR_Number__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].Subject__c, upsertedSRInfoList[0].Subject__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].Orderer__c, upsertedSRInfoList[0].OrderingSource__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].J_Number__c, upsertedSRInfoList[0].J_Number__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].LocationName__c, upsertedSRInfoList[0].LocationName__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].Opportunity__c, upsertedSRInfoList[0].Opportunity__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].OpportunityNumber__c, upsertedSRInfoList[0].OP_Number__c, 'SR情報の値が不正です。');
        System.assertEquals('商談番号を付与できませんでした。', upsertedSRInfoList[0].Warning__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SR_Number__c + testWorks[0].J_Number__c, upsertedSRInfoList[0].UpsertByWorkTargetIdNumber__c, 'SR情報の値が不正です。');
        // 受注時
        System.assertEquals(testWorks[0].SRCP__c, upsertedSRInfoList[0].Order_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].FinalForecastCP_ResultCP__c, upsertedSRInfoList[0].Order_Forecast_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SRWC__c, upsertedSRInfoList[0].Order_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PriorityWC_ResultWC__c, upsertedSRInfoList[0].Order_Forecast_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PlannedOrderDate__c, upsertedSRInfoList[0].Order_OrderDate__c, 'SR情報の値が不正です。');
        // 受注後最新
        System.assertEquals(testWorks[0].SRCP__c, upsertedSRInfoList[0].Latest_Forecast_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].FinalForecastCP_ResultCP__c, upsertedSRInfoList[0].Latest_Forecast_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SRWC__c, upsertedSRInfoList[0].Latest_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PriorityWC_ResultWC__c, upsertedSRInfoList[0].Latest_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].LatestRegistrationDate__c, upsertedSRInfoList[0].Latest_SRInfoUpdateDate__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：実績初回
    */
    @isTest static void upsertSRInfo_Rusult_Success() {
        /* preparation */
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：実績初回'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = WORK_SR_NUMBER_BODY1 + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , SRCP__c = 1
                , FinalForecastCP_ResultCP__c = 1
                , SRWC__c = 1
                , PriorityWC_ResultWC__c = 1
                , PlannedOrderDate__c = Date.today().addMonths(-3)
                , PlannedSalesDate__c = Date.today().addMonths(-1)
                , LatestRegistrationDate__c = Date.today().addMonths(-1).addDays(1)
                , NewRegistrationDate__c = Date.today().addMonths(-1).addDays(1)
                , OpportunityType__c = '実績'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 基本情報
                , AffiliationName__c            // 所属名称
                , ContactPersonName__c          // 担当者名称
                , SR_Number__c                  // 売報番号
                , Subject__c                    // 件名
                , OrderingSource__c             // 注文元
                , J_Number__c                   // J項番号
                , LocationName__c               // 場所名称
                , Opportunity__c                // 案件
                , OP_Number__c                  // 商談番号
                , Warning__c                    // ワーニング
                , UpsertByWorkTargetIdNumber__c // work反映先特定番号（売報番号＋J項番号）
                // 受注時
                , Order_SRCP__c                 // SRCP（受注時）
                , Order_Forecast_SRCP__c        // 最終予想CP（受注時）
                , Order_SRWC__c                 // SRWC（受注時）
                , Order_Forecast_SRWC__c        // 最終予想WC（受注時）
                , Order_OrderDate__c            // 受注年月日
                // 受注後最新
                , Latest_Forecast_SRCP__c       // 最終予想CP（最新）
                , Latest_Forecast_SRWC__c       // 最終予想WC（最新）
                , Latest_SRCP__c                // SRCP（最新）
                , Latest_SRWC__c                // SRWC（最新）
                , Latest_SRInfoUpdateDate__c    // SR情報取得日（最新）
                // 売上実績
                , Result_SRCP__c
                , Result_SRWC__c
                , Result_SalesDate__c
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks1
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: testWorksから作られる1
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 基本情報
        System.assertEquals(testWorks[0].AffiliationName__c, upsertedSRInfoList[0].AffiliationName__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].ContactPersonName__c, upsertedSRInfoList[0].ContactPersonName__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SR_Number__c, upsertedSRInfoList[0].SR_Number__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].Subject__c, upsertedSRInfoList[0].Subject__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].Orderer__c, upsertedSRInfoList[0].OrderingSource__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].J_Number__c, upsertedSRInfoList[0].J_Number__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].LocationName__c, upsertedSRInfoList[0].LocationName__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].Opportunity__c, upsertedSRInfoList[0].Opportunity__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].OpportunityNumber__c, upsertedSRInfoList[0].OP_Number__c, 'SR情報の値が不正です。');
        System.assertEquals('商談番号を付与できませんでした。', upsertedSRInfoList[0].Warning__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SR_Number__c + testWorks[0].J_Number__c, upsertedSRInfoList[0].UpsertByWorkTargetIdNumber__c, 'SR情報の値が不正です。');
        // 受注時
        System.assertEquals(testWorks[0].SRCP__c, upsertedSRInfoList[0].Order_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].FinalForecastCP_ResultCP__c, upsertedSRInfoList[0].Order_Forecast_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SRWC__c, upsertedSRInfoList[0].Order_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PriorityWC_ResultWC__c, upsertedSRInfoList[0].Order_Forecast_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].NewRegistrationDate__c, upsertedSRInfoList[0].Order_OrderDate__c, 'SR情報の値が不正です。');
        // 受注後最新
        System.assertEquals(testWorks[0].SRCP__c, upsertedSRInfoList[0].Latest_Forecast_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].FinalForecastCP_ResultCP__c, upsertedSRInfoList[0].Latest_Forecast_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SRWC__c, upsertedSRInfoList[0].Latest_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PriorityWC_ResultWC__c, upsertedSRInfoList[0].Latest_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].LatestRegistrationDate__c, upsertedSRInfoList[0].Latest_SRInfoUpdateDate__c, 'SR情報の値が不正です。');
        // 売上実績
        System.assertEquals(testWorks[0].FinalForecastCP_ResultCP__c, upsertedSRInfoList[0].Result_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PriorityWC_ResultWC__c, upsertedSRInfoList[0].Result_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PlannedSalesDate__c, upsertedSRInfoList[0].Result_SalesDate__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：受注後最新
    */
    @isTest static void upsertSRInfo_Latest_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：受注後最新'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , SRCP__c = 1
                , FinalForecastCP_ResultCP__c = 1
                , SRWC__c = 1
                , PriorityWC_ResultWC__c = 1
                , OpportunityType__c = '手持'
                , LatestRegistrationDate__c = Date.today().addMonths(-1)
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 受注後最新
                , Latest_Forecast_SRCP__c       // 最終予想CP（最新）
                , Latest_Forecast_SRWC__c       // 最終予想WC（最新）
                , Latest_SRCP__c                // SRCP（最新）
                , Latest_SRWC__c                // SRWC（最新）
                , Latest_SRInfoUpdateDate__c    // SR情報取得日（最新）
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: setup1 + testWorks1
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: setupのSR情報1(testWorksでupdate)
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 受注後最新
        System.assertEquals(testWorks[0].FinalForecastCP_ResultCP__c, upsertedSRInfoList[0].Latest_Forecast_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PriorityWC_ResultWC__c, upsertedSRInfoList[0].Latest_Forecast_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SRCP__c, upsertedSRInfoList[0].Latest_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].SRWC__c, upsertedSRInfoList[0].Latest_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].LatestRegistrationDate__c, upsertedSRInfoList[0].Latest_SRInfoUpdateDate__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：売上実績(上書き) 「事由」が”締追”ではない
    */
    @isTest static void upsertSRInfo_ResultRewrite1_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：売上実績(上書き)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 1
                , PriorityWC_ResultWC__c = 1
                , DeadlineDifference__c = 1
                , AdditionalCost__c = 1
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1)
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 売上実績
                , Result_SRCP__c            // 売上実績CP
                , Result_SRWC__c            // 売上実績WC
                , Result_SalesDate__c       // 売上年月日
                , Result_Difference__c      // 締切差異
                , Result_AdditionalCost__c  // 追加原価
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks1
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: setupのSR情報1(testWorksでupdate)
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 売上実績
        System.assertEquals(testWorks[0].FinalForecastCP_ResultCP__c, upsertedSRInfoList[0].Result_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PriorityWC_ResultWC__c, upsertedSRInfoList[0].Result_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PlannedSalesDate__c, upsertedSRInfoList[0].Result_SalesDate__c, 'SR情報の値が不正です。');
        System.assertEquals(null, upsertedSRInfoList[0].Result_Difference__c, 'SR情報の値が不正です。');
        System.assertEquals(null, upsertedSRInfoList[0].Result_AdditionalCost__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：売上実績(上書き) 「事由」が”締追”
    */
    @isTest static void upsertSRInfo_ResultRewrite2_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：売上実績(上書き)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 1
                , PriorityWC_ResultWC__c = 1
                , DeadlineDifference__c = 1
                , AdditionalCost__c = 1
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1)
                , ReasonName__c = '締追'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 売上実績
                , Result_SRCP__c            // 売上実績CP
                , Result_SRWC__c            // 売上実績WC
                , Result_SalesDate__c       // 売上年月日
                , Result_Difference__c      // 締切差異
                , Result_AdditionalCost__c  // 追加原価
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks1
        System.assertEquals(1, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: setupのSR情報1(testWorksでupdate)
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 売上実績
        System.assertEquals(null, upsertedSRInfoList[0].Result_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(null, upsertedSRInfoList[0].Result_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(null, upsertedSRInfoList[0].Result_SalesDate__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].DeadlineDifference__c, upsertedSRInfoList[0].Result_Difference__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].AdditionalCost__c, upsertedSRInfoList[0].Result_AdditionalCost__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：売上実績(加算) 「売上（予定）年月日」がCRMの売上年月日より後の日の場合は加算する 場合
    */
    @isTest static void upsertSRInfo_ResultAdding_JudgeByDate_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：売上実績(上書き)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 1
                , PriorityWC_ResultWC__c = 1
                , DeadlineDifference__c = 1
                , AdditionalCost__c = 1
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1)
            )
        };
        insert testWorks;
        List<work__c> testWorks1 = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks2件目：売上実績(加算)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 1
                , PriorityWC_ResultWC__c = 1
                , DeadlineDifference__c = 1
                , AdditionalCost__c = 1
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1).addDays(1)
            )
        };
        insert testWorks1;
        List<work__c> testWorks2 = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks3件目：売上実績(加算)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 2
                , PriorityWC_ResultWC__c = 2
                , DeadlineDifference__c = 2
                , AdditionalCost__c = 2
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1).addDays(2)
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks2;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 売上実績
                , Result_SRCP__c            // 売上実績CP
                , Result_SRWC__c            // 売上実績WC
                , Result_SalesDate__c       // 売上年月日
                , Result_Difference__c      // 締切差異
                , Result_AdditionalCost__c  // 追加原価
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks + testWorks1 + testWorks2
        System.assertEquals(3, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: setupのSR情報1(testWorks1とtestWorks2でupdate)
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 売上実績
        System.assertEquals(testWorks[0].FinalForecastCP_ResultCP__c + testWorks1[0].FinalForecastCP_ResultCP__c + testWorks2[0].FinalForecastCP_ResultCP__c, upsertedSRInfoList[0].Result_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PriorityWC_ResultWC__c + testWorks1[0].PriorityWC_ResultWC__c + testWorks2[0].PriorityWC_ResultWC__c, upsertedSRInfoList[0].Result_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PlannedSalesDate__c, upsertedSRInfoList[0].Result_SalesDate__c, 'SR情報の値が不正です。');
        System.assertEquals(null, upsertedSRInfoList[0].Result_Difference__c, 'SR情報の値が不正です。');
        System.assertEquals(null, upsertedSRInfoList[0].Result_AdditionalCost__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：売上実績(加算) 「売上（予定）年月日」がCRMの売上年月日より後の日の場合は加算する 場合（「事由」が”締追”）
    */
    @isTest static void upsertSRInfo_ResultAdding2_JudgeByDate_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：売上実績(上書き)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 1
                , PriorityWC_ResultWC__c = 1
                , DeadlineDifference__c = 1
                , AdditionalCost__c = 1
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1)
            )
        };
        insert testWorks;
        List<work__c> testWorks1 = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks2件目：売上実績(上書き)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 0
                , PriorityWC_ResultWC__c = 0
                , DeadlineDifference__c = 1
                , AdditionalCost__c = 1
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1)
                , ReasonName__c = '締追'
            )
        };
        insert testWorks1;
        List<work__c> testWorks2 = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks3件目：売上実績(加算)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 0
                , PriorityWC_ResultWC__c = 0
                , DeadlineDifference__c = 2
                , AdditionalCost__c = 2
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1).addDays(1)
                , ReasonName__c = '締追'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks2;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 売上実績
                , Result_SRCP__c            // 売上実績CP
                , Result_SRWC__c            // 売上実績WC
                , Result_SalesDate__c       // 売上年月日
                , Result_Difference__c      // 締切差異
                , Result_AdditionalCost__c  // 追加原価
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks + testWorks1 + testWorks2
        System.assertEquals(3, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: setupのSR情報1(testWorks1とtestWorks2でupdate)
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 売上実績
        System.assertEquals(testWorks[0].FinalForecastCP_ResultCP__c, upsertedSRInfoList[0].Result_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PriorityWC_ResultWC__c, upsertedSRInfoList[0].Result_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PlannedSalesDate__c, upsertedSRInfoList[0].Result_SalesDate__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks1[0].DeadlineDifference__c, upsertedSRInfoList[0].Result_Difference__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks1[0].AdditionalCost__c + testWorks2[0].AdditionalCost__c, upsertedSRInfoList[0].Result_AdditionalCost__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：売上実績(加算) 「売上（予定）年月日」がCRMの売上年月日より後の日の場合は加算する
    * CRMの売上年月日の翌日以降に初めて締切差異と追加原価が発生した 場合
    */
    @isTest static void upsertSRInfo_InitialTransferLaterThanResultSalesDate_JudgeByDate_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：売上実績(上書き)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 1
                , PriorityWC_ResultWC__c = 1
                , DeadlineDifference__c = 1
                , AdditionalCost__c = 1
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1)
            )
        };
        insert testWorks;
        List<work__c> testWorks1 = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks2件目：売上実績(加算)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 2
                , PriorityWC_ResultWC__c = 2
                , DeadlineDifference__c = 2
                , AdditionalCost__c = 2
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1).addDays(1)
                , ReasonName__c = '締追'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks1;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 売上実績
                , Result_SalesDate__c       // 売上年月日
                , Result_Difference__c      // 締切差異
                , Result_AdditionalCost__c  // 追加原価
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks + testWorks1
        System.assertEquals(2, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: setupのSR情報1(testWorks1でupdate)
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 売上実績
        System.assertEquals(testWorks[0].PlannedSalesDate__c, upsertedSRInfoList[0].Result_SalesDate__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks1[0].DeadlineDifference__c, upsertedSRInfoList[0].Result_Difference__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks1[0].AdditionalCost__c, upsertedSRInfoList[0].Result_AdditionalCost__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：売上実績(解約) 売上実績登録前の場合
    */
    @isTest static void upsertSRInfo_Cancel_Latest_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：受注後最新'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , SRCP__c = 1
                , FinalForecastCP_ResultCP__c = 1
                , SRWC__c = 1
                , PriorityWC_ResultWC__c = 1
                , OpportunityType__c = '手持'
                , LatestRegistrationDate__c = Date.today().addMonths(-1)
            )
        };
        insert testWorks;
        List<work__c> testWorks1 = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks2件目：売上実績(解約)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 2
                , PriorityWC_ResultWC__c = 2
                , DeadlineDifference__c = 2
                , AdditionalCost__c = 2
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1)
                , ReasonName__c = '解約'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks1;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 売上実績
                , Result_SRCP__c            // 売上実績CP
                , Result_SRWC__c            // 売上実績WC
                , Result_SalesDate__c       // 売上年月日
                , Result_Difference__c      // 締切差異
                , Result_AdditionalCost__c  // 追加原価
                // 受注後最新
                , Latest_Forecast_SRCP__c       // 最終予想CP（最新）
                , Latest_Forecast_SRWC__c       // 最終予想WC（最新）
                , Latest_SRCP__c                // SRCP（最新）
                , Latest_SRWC__c                // SRWC（最新）
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks + testWorks1
        System.assertEquals(2, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: setupのSR情報1(testWorks1でupdate)
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 受注後最新
        System.assertEquals(0, upsertedSRInfoList[0].Latest_Forecast_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Latest_Forecast_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Latest_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Latest_SRWC__c, 'SR情報の値が不正です。');

        // 売上実績
        System.assertEquals(0, upsertedSRInfoList[0].Result_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Result_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks1[0].PlannedSalesDate__c, upsertedSRInfoList[0].Result_SalesDate__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Result_Difference__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Result_AdditionalCost__c, 'SR情報の値が不正です。');
    }

    /*
    * 登録したworkをSR情報に反映(upsert) の正常系テスト：売上実績(解約) 「売上（予定）年月日」がCRMの売上年月日より後の日の場合
    */
    @isTest static void upsertSRInfo_Cancel_JudgeByDate_Success() {
        /* preparation */
        createTestSRInfo();
        List<work__c> testWorks = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks1件目：売上実績(上書き)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 1
                , PriorityWC_ResultWC__c = 1
                , DeadlineDifference__c = 1
                , AdditionalCost__c = 1
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1)
            )
        };
        insert testWorks;
        List<work__c> testWorks1 = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks2件目：売上実績(加算)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 2
                , PriorityWC_ResultWC__c = 2
                , DeadlineDifference__c = 2
                , AdditionalCost__c = 2
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1)
                , ReasonName__c = '締追'
            )
        };
        insert testWorks1;
        List<work__c> testWorks2 = new List<work__c>{
            new work__c(
                AffiliationName__c = 'testWorks3件目：売上実績(解約)'
                , ContactPersonName__c = 'test_cp'
                , SR_Number__c = SRINFO_SR_NUMBER_BODY + '0'        // 売報番号
                , Subject__c = 'test_sbj'
                , Orderer__c = 'test_ordr'
                , J_Number__c = COMMON_J_NUMBER                     // J項番号
                , LocationName__c = 'test_ln'
                , Opportunity__c = null
                , OpportunityNumber__c = null                         // 商談番号
                , FinalForecastCP_ResultCP__c = 2
                , PriorityWC_ResultWC__c = 2
                , DeadlineDifference__c = 2
                , AdditionalCost__c = 2
                , OpportunityType__c = '実績'
                , PlannedSalesDate__c = Date.today().addMonths(-1).addDays(1)
                , ReasonName__c = '解約'
            )
        };

        /* execution */
        Test.startTest();
        insert testWorks2;
        Test.stopTest();

        List<work__c> insertedWorks = [SELECT Id FROM work__c ORDER BY CreatedDate];
        List<SRInfo__c> upsertedSRInfoList = [
            SELECT
                Id
                // 売上実績
                , Result_SRCP__c            // 売上実績CP
                , Result_SRWC__c            // 売上実績WC
                , Result_SalesDate__c       // 売上年月日
                , Result_Difference__c      // 締切差異
                , Result_AdditionalCost__c  // 追加原価
                // 受注後最新
                , Latest_Forecast_SRCP__c       // 最終予想CP（最新）
                , Latest_Forecast_SRWC__c       // 最終予想WC（最新）
                , Latest_SRCP__c                // SRCP（最新）
                , Latest_SRWC__c                // SRWC（最新）
            FROM
                SRInfo__c
            ORDER BY
                CreatedDate
        ];

        /* assertion */
        // work: testWorks + testWorks1
        System.assertEquals(3, insertedWorks.size(), 'workの件数が不正です。');
        // SRInfo: setupのSR情報1(testWorks1でupdate)
        System.assertEquals(1, upsertedSRInfoList.size(), 'SR情報の件数が不正です。');

        // 受注後最新
        System.assertEquals(0, upsertedSRInfoList[0].Latest_Forecast_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Latest_Forecast_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Latest_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Latest_SRWC__c, 'SR情報の値が不正です。');

        // 売上実績
        System.assertEquals(0, upsertedSRInfoList[0].Result_SRCP__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Result_SRWC__c, 'SR情報の値が不正です。');
        System.assertEquals(testWorks[0].PlannedSalesDate__c, upsertedSRInfoList[0].Result_SalesDate__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Result_Difference__c, 'SR情報の値が不正です。');
        System.assertEquals(0, upsertedSRInfoList[0].Result_AdditionalCost__c, 'SR情報の値が不正です。');
    }

}