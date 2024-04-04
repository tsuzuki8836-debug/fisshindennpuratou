@isTest
private class QuoteTriggerTest {
    @testSetup
    static void quotedataCreation() {
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = '施設'];

        List<Quote__c> qtList = new List<Quote__c>();
        Quote__c qoute1 = new Quote__c(
            //GeneralAdministrativeExpenses__c = 1,　コメントアウト中
            PowerFrequency__c = '50Hz',
            RecordTypeId = recType[0].Id,
            QuoteNumber__c = '1'
        );
        qtList.add(qoute1);

        Quote__c qoute2 = new Quote__c(
            //GeneralAdministrativeExpenses__c = 1,　コメントアウト中
            PowerFrequency__c = '50Hz',
            RecordTypeId = recType[0].Id,
            QuoteNumber__c = '1'
        );
        qtList.add(qoute2);
        
        insert qtList;

        List<Device__c> deList = new List<Device__c>();
        Device__c dv1 = new Device__c(
            QuoteSpecificationNumber__c = '001',
            Name = '品名',
            MajorClassification__c = 'UPS',
            NETCalculateCategory__c = '受変電',
            Quote__c = qoute1.Id,
            PriceCoefficient__c=1,
            Quantity__c = '１2'

        );
        deList.add(dv1);
        Device__c dv2 = new Device__c(
            QuoteSpecificationNumber__c = '001',
            Name = '品名',
            MajorClassification__c = 'UPS',
            NETCalculateCategory__c = 'UPS',
            Quote__c = qoute2.Id,
            PriceCoefficient__c=1,
            Quantity__c = '２'

        );
        deList.add(dv2);
        insert deList;

        List<Detail__c> dList = new List<Detail__c>();
        Detail__c dtl1 = new Detail__c(
            Device__c = dv1.Id,
            Name = '名称1',
            Quantity__c = 1,
            UnitPrice__c = 1000
        );
        dList.add(dtl1);
        Detail__c dtl2 = new Detail__c(
            Device__c = dv2.Id,
            Name = '名称2',
            Quantity__c = 2,
            UnitPrice__c = 2000
        );
        dList.add(dtl2);
        insert dList;
    }

    @IsTest
    private static void cloneQuoteAndRelatedRecordsTest() {
        //テスト実行
        Test.startTest();
        quotedataCreation();
        List<Quote__c> cloneQtList = new List<Quote__c>();
        for(Quote__c qt : [SELECT Id,  PowerFrequency__c,QuoteNumber__c,QuotePriceSum__c FROM Quote__c //GeneralAdministrativeExpenses__c,をコメントアウト中
        ]){
            Quote__c qClone = qt.clone();
            // qClone.SelfTotal_NET_LastAcc__c=1;
            cloneQtList.add(qClone);
        }

        insert cloneQtList;
        
        Test.stopTest();

    }
    @IsTest
    private static void updateQuoteAndRelatedRecordsTest() {
        //テスト実行
        Test.startTest();
        quotedataCreation();
        List<Quote__c> updateQtList = new List<Quote__c>();
        for(Quote__c qt : [SELECT Id,  PowerFrequency__c,QuoteNumber__c,QuotePriceSum__c FROM Quote__c //GeneralAdministrativeExpenses__c,をコメントアウト中
        ]){
            // Quote__c qClone = qt.clone();
            qt.SelfTotal_NET_LastAcc__c=1;
            qt.SelfTotal_NET_General__c=1;
            qt.SelfTotal_NET_Sub__c=1;
            updateQtList.add(qt);
        }

        update updateQtList;
        
        Test.stopTest();

    }
    @isTest
    private static void convertFullToHalfTest(){
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = '施設'];
        List<Quote__c> qList = new List<Quote__c>();
        //一般管理費が半角の場合
        Quote__c q1 = new Quote__c(
            QuoteNumber__c = '全角入力テスト_半角ver',
            GeneralAdministrativeExpenses__c = '1',//半角数字
            PowerFrequency__c = '50Hz',
            RecordTypeId = recType[0].Id
        );
        qList.add(q1);
        //一般管理費が全角の場合
        Quote__c q2 = new Quote__c(
            QuoteNumber__c = '全角入力テスト_全角ver',
            GeneralAdministrativeExpenses__c = '１',//全角数字
            PowerFrequency__c = '50Hz',
            RecordTypeId = recType[0].Id
        );
        qList.add(q2);
        //一般管理費が半角・全角複合の場合
        Quote__c q3 = new Quote__c(
            QuoteNumber__c = '全角入力テスト_半角全角複合ver',
            GeneralAdministrativeExpenses__c = '1２',//半角数字、全角数字複合
            PowerFrequency__c = '50Hz',
            RecordTypeId = recType[0].Id
        );
        qList.add(q3);

        //テスト実行
        Test.startTest();

        insert qList;

        Test.stopTest();

        List<Quote__c> qResult1 = [SELECT Id
                                        ,QuoteNumber__c
                                        ,GeneralAdministrativeExpenses__c
                                        ,PowerFrequency__c
                                        ,RecordTypeId
                                        FROM Quote__c WHERE Id = :q1.Id];
        List<Quote__c> qResult2 = [SELECT Id
                                        , QuoteNumber__c
                                        , GeneralAdministrativeExpenses__c
                                        , PowerFrequency__c
                                        , RecordTypeId
                                        FROM Quote__c WHERE Id = :q2.Id];
        List<Quote__c> qResult3 = [SELECT Id
                                        , QuoteNumber__c
                                        , GeneralAdministrativeExpenses__c
                                        , PowerFrequency__c
                                        , RecordTypeId
                                        FROM Quote__c WHERE Id = :q3.Id];

        System.assertEquals('1', qResult1[0].GeneralAdministrativeExpenses__c);
        System.assertEquals('1', qResult2[0].GeneralAdministrativeExpenses__c);
        System.assertEquals('12', qResult3[0].GeneralAdministrativeExpenses__c);

    }
}