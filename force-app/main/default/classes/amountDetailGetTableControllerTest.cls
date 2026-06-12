@IsTest
public class amountDetailGetTableControllerTest {

    // 伺い数値明細画面 テスト
    @IsTest
    static void TestGetAmountDetailGetTable1() {

        amountDetailGetTableController.getAmountDetailGetTable(null);

        QuoteBiddingInquiry__c qbi = createTestQuoteBiddingInquiry('応札伺い');
        insert qbi;

        amountDetailGetTableController.getAmountDetailGetTable(qbi.Id );

        QuoteBiddingInquiry__c qbi2 = createTestQuoteBiddingInquiry('見積伺い');
        insert qbi2;

        amountDetailGetTableController.getAmountDetailGetTable(qbi2.Id );
    }

    // 伺い数値明細画面 テスト
    @IsTest
    static void TestGetAmountDetailGetTable2() {

        QuoteBiddingInquiry__c qbi2 = createTestQuoteBiddingInquiry('見積伺い');
        qbi2.UnitPriceEstimation__c = true;
        // qbi2.Refusal__c = true;
        // qbi2.PriceList__c = true;
        insert qbi2;

        amountDetailGetTableController.getAmountDetailGetTable(qbi2.Id );
    }

    // 伺い数値明細画面 テスト
    @IsTest
    static void TestGetAmountDetailGetTable3() {

        amountDetailGetTableController.getAmountDetailGetTable(null);

        QuoteBiddingInquiry__c qbi = createTestQuoteBiddingInquiry('応札伺い');
        insert qbi;

        amountDetailGetTableController.getAmountDetailGetTable(qbi.Id );

        // レコードタイプを取得
        Schema.SObjectType qbiType = Account.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('事業所').getRecordTypeId();

        // 取引先を作成
        Account acc = new Account(
            Name = 'テスト取引先',
            RecordTypeId = qbiRecordTypeId
        );
        insert acc;

        PumpStation__c ps = new PumpStation__c(
            Name = 'ポンプ場'
        );
        insert ps;

        // 商談を作成
        Opportunity opp = new Opportunity(
            Name = '受付未承認',
            AccountId = acc.Id,
            StageName = '基本計画',
            ConstructionDistinction__c = '更新（自社既設）',
            BU__c = '水環境',
            SBU__c = '上水',
            EstablishedCompany__c = '三菱',
            Probability1__c = 100,
            PumpStation__c = ps.Id,
            CloseDate = Date.Today()
        );
        insert opp;

        QuoteBiddingInquiry__c qbi2 = createTestQuoteBiddingInquiry('見積伺い');
        qbi2.Opportunity__c = opp.Id;
        insert qbi2;

        DetailByInquiryFactory__c dbif = new DetailByInquiryFactory__c(
            QuoteBiddingInquiry__c = qbi2.Id,
            BU__c = '水環境',
            CommonRatio__c = '31% ： 製作所',
            Factory__c = '神電',
            CP__c = 1500,
            WC__c = 500,
            ImprovementTargetCP__c = 1000,
            ImprovementTargetWC__c = 300,
            AdjustCPMax__c = 2000,
            AdjustCPMin__c = 1000,
            AdjustWC__c = 1000,
            NewContractCP__c = 1500,
            NewContractWC__c = 500
        );
        insert dbif;

        qbi2.PriceProposal1MaxCPManualInput__c = 1234;
        qbi2.PriceProposal1MaxWCManualInput__c = 123;
        qbi2.PriceProposal1MaxTCManualInput__c = 123;
        // qbi2.DetailAfterDesignSalesCommission__c = 123;
        qbi2.ExpectProfitAndLossOnOrderCP__c = 12300;
        qbi2.ExpectProfitAndLossOnOrderTC__c = 1230;
        qbi2.ExpectProfitAndLossOnOrderWC__c = 1230;
        qbi2.SingleTotalCP__c = 12300;
        qbi2.SingleTotalWC__c = 1230;
        qbi2.SingleTotalTC__c = 1230;

        update qbi2;

        amountDetailGetTableController.getAmountDetailGetTable(qbi2.Id );
    }

    // 設計変更用伺い数値明細画面 テスト
    @IsTest
    static void TestGetAmountDetailGetTable4() {
        QuoteBiddingInquiry__c qbi = createTestQuoteBiddingInquiry('設計変更応札伺い');

        qbi = createTestQuoteBiddingInquiry('設計変更応札伺い');
        // qbi.DetailAfterDesignSalesCommission__c = 123;
        qbi.ExpectProfitAndLossOnOrderCP__c = 123;
        qbi.ExpectProfitAndLossOnOrderTC__c = 123;
        qbi.ExpectProfitAndLossOnOrderWC__c = 123;
        insert qbi;

        amountDetailGetTableController.getAmountDetailGetTable(qbi.Id );

        qbi = createTestQuoteBiddingInquiry('設計変更応札伺い');
        // qbi.OriginalContractSalesCommission__c = 123;
        insert qbi;

        amountDetailGetTableController.getAmountDetailGetTable(qbi.Id );
    }

    @IsTest
    static void TestGetAmountDetailGetTable5() {

        // レコードタイプを取得
        Schema.SObjectType qbiType = Account.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('事業所').getRecordTypeId();

        // 取引先を作成
        Account acc = new Account(
            Name = 'テスト取引先',
            RecordTypeId = qbiRecordTypeId
        );
        insert acc;

        PumpStation__c ps = new PumpStation__c(
            Name = 'ポンプ場'
        );
        insert ps;

        // 商談を作成
        Opportunity opp = new Opportunity(
            Name = '受付未承認',
            AccountId = acc.Id,
            StageName = '基本計画',
            ConstructionDistinction__c = '更新（自社既設）',
            BU__c = '水環境',
            SBU__c = '上水',
            EstablishedCompany__c = '三菱',
            Probability1__c = 100,
            PumpStation__c = ps.Id,
            CloseDate = Date.Today()
        );
        insert opp;

        QuoteBiddingInquiry__c qbi2 = createTestQuoteBiddingInquiry('設計変更応札伺い');
        qbi2.Opportunity__c = opp.Id;
        insert qbi2;

        DetailByInquiryFactory__c dbif = new DetailByInquiryFactory__c(
            QuoteBiddingInquiry__c = qbi2.Id,
            BU__c = '水環境',
            CommonRatio__c = '31% ： 製作所',
            Factory__c = '神電',
            CP__c = 1500,
            WC__c = 500,
            ImprovementTargetCP__c = 1000,
            ImprovementTargetWC__c = 300,
            AdjustCPMax__c = 2000,
            AdjustCPMin__c = 1000,
            AdjustWC__c = 1000,
            NewContractCP__c = 1500,
            NewContractWC__c = 500
        );
        insert dbif;

        qbi2.PriceProposal1MaxCPManualInput__c = 1234;
        qbi2.PriceProposal1MaxWCManualInput__c = 123;
        qbi2.PriceProposal1MaxTCManualInput__c = 123;
        // qbi2.DetailAfterDesignSalesCommission__c = 123;
        qbi2.ExpectProfitAndLossOnOrderCP__c = 12300;
        qbi2.ExpectProfitAndLossOnOrderTC__c = 1230;
        qbi2.ExpectProfitAndLossOnOrderWC__c = 1230;
        qbi2.SingleTotalCP__c = 12300;
        qbi2.SingleTotalWC__c = 1230;
        qbi2.SingleTotalTC__c = 1230;
        qbi2.AdjustMaxFee__c = 100;
        qbi2.AdjustMinFee__c = 50;

        update qbi2;

        amountDetailGetTableController.getAmountDetailGetTable(qbi2.Id );
    }

    @IsTest
    static void TestGetAmountDetailGetTable6() {

        // レコードタイプを取得
        Schema.SObjectType qbiType = Account.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('事業所').getRecordTypeId();

        // 取引先を作成
        Account acc = new Account(
            Name = 'テスト取引先',
            RecordTypeId = qbiRecordTypeId
        );
        insert acc;

        PumpStation__c ps = new PumpStation__c(
            Name = 'ポンプ場'
        );
        insert ps;

        // 商談を作成
        Opportunity opp = new Opportunity(
            Name = '受付未承認',
            AccountId = acc.Id,
            StageName = '基本計画',
            ConstructionDistinction__c = '更新（自社既設）',
            BU__c = '水環境',
            SBU__c = '上水',
            EstablishedCompany__c = '三菱',
            Probability1__c = 100,
            PumpStation__c = ps.Id,
            CloseDate = Date.Today()
        );
        insert opp;

        QuoteBiddingInquiry__c qbi2 = createTestQuoteBiddingInquiry('設計変更応札伺い');
        qbi2.Opportunity__c = opp.Id;
        insert qbi2;

        DetailByInquiryFactory__c dbif = new DetailByInquiryFactory__c(
            QuoteBiddingInquiry__c = qbi2.Id,
            BU__c = '水環境',
            CommonRatio__c = '31% ： 製作所',
            Factory__c = '神電',
            CP__c = 1500,
            WC__c = 500,
            ImprovementTargetCP__c = 1000,
            ImprovementTargetWC__c = 300,
            AdjustCPMax__c = 2000,
            AdjustCPMin__c = 1000,
            AdjustWC__c = 1000
        );
        insert dbif;

        qbi2.PriceProposal1MaxCPManualInput__c = 1234;
        qbi2.PriceProposal1MaxWCManualInput__c = 123;
        qbi2.PriceProposal1MaxTCManualInput__c = 123;
        // qbi2.OriginalContractSalesCommission__c = 123;
        qbi2.ExpectProfitAndLossOnOrderCP__c = 12300;
        qbi2.ExpectProfitAndLossOnOrderTC__c = 1230;
        qbi2.ExpectProfitAndLossOnOrderWC__c = 1230;
        qbi2.SingleTotalCP__c = 12300;
        qbi2.SingleTotalWC__c = 1230;
        qbi2.SingleTotalTC__c = 1230;
        qbi2.AdjustMaxFee__c = 100;
        qbi2.AdjustMinFee__c = 50;

        update qbi2;

        amountDetailGetTableController.getAmountDetailGetTable(qbi2.Id );
    }

     // テスト用のQuoteBiddingInquiry__cレコードを作成するヘルパーメソッド
     private static QuoteBiddingInquiry__c createTestQuoteBiddingInquiry(String recordType) {

        // レコードタイプを取得
        Schema.SObjectType qbiType = QuoteBiddingInquiry__c.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get(recordType).getRecordTypeId();

        QuoteBiddingInquiry__c qbi = new QuoteBiddingInquiry__c();
        qbi.Creating__c = true;
        qbi.NewChanged__c = '新規';
        qbi.RecordTypeId = qbiRecordTypeId;
        return qbi;
    }
}