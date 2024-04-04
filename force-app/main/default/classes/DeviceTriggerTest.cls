@isTest
private class DeviceTriggerTest {
    @isTest
    private static void convertFullToHalfTest(){
        //事前準備
        List<RecordType> recType_Quote = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = '施設'];
        List<Quote__c> qList = new List<Quote__c>();
        Quote__c quote = new Quote__c(
            QuoteNumber__c = '見積_事前準備',
            GeneralAdministrativeExpenses__c = '1',
            PowerFrequency__c = '50Hz',
            RecordTypeId = recType_Quote[0].Id
        );
        qList.add(quote);
        insert qList;

        List<Device__c> dList = new List<Device__c>();
        List<RecordType> recType_Device = [SELECT Id FROM RecordType WHERE SobjectType = 'Device__c' and name = '施設'];
        //数量が半角の場合
        Device__c d1 = new Device__c(
            Name = '全角入力テスト_半角ver',
            QuoteSpecificationNumber__c = '001',
            Quantity__c = '1',//半角数字
            Quote__c = quote.Id,
            RecordTypeOfQuote__c = '施設',
            MajorClassification__c = '変圧器',
            MinorClassification__c = '',
            RecordTypeId = recType_Device[0].Id
        );
        dList.add(d1);
        //数量が全角の場合
        Device__c d2 = new Device__c(
            Name = '全角入力テスト_全角ver',
            QuoteSpecificationNumber__c = '002',
            Quantity__c = '１',//全角数字
            Quote__c = quote.Id,
            RecordTypeOfQuote__c = '施設',
            MajorClassification__c = '変圧器',
            MinorClassification__c = '',
            RecordTypeId = recType_Device[0].Id
        );
        dList.add(d2);
        //数量が半角・全角複合の場合
        Device__c d3 = new Device__c(
            Name = '全角入力テスト_半角全角複合ver',
            QuoteSpecificationNumber__c = '003',
            Quantity__c = '1２',//半角数字、全角数字複合
            Quote__c = quote.Id,
            RecordTypeOfQuote__c = '施設',
            MajorClassification__c = '変圧器',
            MinorClassification__c = '',
            RecordTypeId = recType_Device[0].Id
        );
        dList.add(d3);
        //数量が空白の場合
        Device__c d4 = new Device__c(
            Name = '全角入力テスト_空白ver',
            QuoteSpecificationNumber__c = '004',
            Quantity__c = '',//空白
            Quote__c = quote.Id,
            RecordTypeOfQuote__c = '施設',
            MajorClassification__c = '変圧器',
            MinorClassification__c = '',
            RecordTypeId = recType_Device[0].Id
        );
        dList.add(d4);
        //テスト実行
        Test.startTest();

        insert dList;

        Test.stopTest();

        List<Device__c> dResult1 = [SELECT Id
                                        , Name
                                        , QuoteSpecificationNumber__c
                                        , Quantity__c
                                        FROM Device__c WHERE Id = :d1.Id];
        List<Device__c> dResult2 = [SELECT Id
                                        , Name
                                        , QuoteSpecificationNumber__c
                                        , Quantity__c
                                        FROM Device__c WHERE Id = :d2.Id];
        List<Device__c> dResult3 = [SELECT Id
                                        , Name
                                        , QuoteSpecificationNumber__c
                                        , Quantity__c
                                        FROM Device__c WHERE Id = :d3.Id];

        List<Device__c> dResult4 = [SELECT Id
                                        , Name
                                        , QuoteSpecificationNumber__c
                                        , Quantity__c
                                        FROM Device__c WHERE Id = :d4.Id];

        System.assertEquals('1', dResult1[0].Quantity__c);
        System.assertEquals('1', dResult2[0].Quantity__c);
        System.assertEquals('12', dResult3[0].Quantity__c);
        System.assertEquals(null, dResult4[0].Quantity__c);

    }
}