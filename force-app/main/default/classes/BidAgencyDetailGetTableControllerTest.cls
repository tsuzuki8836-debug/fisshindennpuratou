@IsTest
public class BidAgencyDetailGetTableControllerTest {

    // 伺い数値明細画面 テスト
    @IsTest
    static void TestgetDetailTable1() {
        
        BidAgencyDetailGetTableController.getDetailTable(null);

        QuoteBiddingInquiry__c qbi = createTestQuoteBiddingInquiry('手数料伺い');
        // qbi.DetailAfterDesignSalesCommission__c = 123;
        insert qbi;

        BidAgencyDetailGetTableController.getDetailTable(qbi.Id );
    }

    @IsTest
    static void TestgetDetailTable2() {
        
        BidAgencyDetailGetTableController.getDetailTable(null);

        QuoteBiddingInquiry__c qbi2= createTestQuoteBiddingInquiry('手数料伺い');
        // qbi2.DetailAfterDesignSalesCommission__c = 123;
        insert qbi2;

        QuoteBiddingInquiry__c qbi = createTestQuoteBiddingInquiry('手数料伺い');
        // qbi.DetailAfterDesignSalesCommission__c = 123;
        qbi.DependentFeeInquiry__c = qbi2.Id;
        insert qbi;

        BidAgencyDetailGetTableController.getDetailTable(qbi.Id );
    }

    @IsTest
    static void TestgetDetailTable3() {
        
        BidAgencyDetailGetTableController.getDetailTable(null);

        QuoteBiddingInquiry__c qbi2= createTestQuoteBiddingInquiry('手数料伺い');
        // qbi2.DetailAfterDesignSalesCommission__c = 123;
        insert qbi2;

        QuoteBiddingInquiry__c qbi = createTestQuoteBiddingInquiry('手数料伺い');
        // qbi.DetailAfterDesignSalesCommission__c = 123;
        qbi.ContractAmountMax__c = 50000;
        qbi.ContractAmountMin__c = 10000;
        qbi.DependentFeeInquiry__c = qbi2.Id;
        insert qbi;

        BidAgencyDetailGetTableController.getDetailTable(qbi.Id );
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