@isTest
private class DeviceTriggerTest {
    @testSetup
    static void deviceDataCreation() {
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = '施設'];
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();

        List<Quote__c> qtList = new List<Quote__c>();
        Quote__c quote1 = new Quote__c(
            PowerFrequency__c = '50Hz',
            RecordTypeId = recType[0].Id,
            QuoteNumber__c = '1'
        );
        qtList.add(quote1);

        Quote__c quote2 = new Quote__c(
            PowerFrequency__c = '50Hz',
            RecordTypeId = recTypeOfficialDemandId,
            QuoteNumber__c = '2',
            EquipmentCostExistence__c='あり',
            SectionExistence__c='あり'
        );
        qtList.add(quote2);
        
        insert qtList;

        List<ConstructionZone__c> conList = new List<ConstructionZone__c>();
        ConstructionZone__c con = new ConstructionZone__c(
            Name = 'テスト工事区分',    
            Quote__c = quote1.Id,
            ConstructionZoneNo__c = 1    
        );
        conList.add(con);

        insert conList;

        Device_LargeCategory__c largeCategory = new Device_LargeCategory__c(
            Quote__c = quote1.Id,    
            ConstructionZone__c = con.Id,
            Name = '◯◯工事_工種',
            Device_LargeCategoryNo__c = '1'
        );
        insert largeCategory;

        Device_MiddleCategory__c middleCategory = new Device_MiddleCategory__c(
            Quote__c = quote1.Id,      
            Device_LargeCategory__c = largeCategory.Id,
            Name = '◯◯工事_種別',
            Device_MiddleCategoryNo__c = '1'
        );
        insert middleCategory;

        Device_SmallCategory__c smallCategory = new Device_SmallCategory__c(
            Quote__c = quote1.Id,      
            Device_MiddleCategory__c = middleCategory.Id,
            Name = '◯◯工事_細別',
            Device_SmallCategoryNo__c = '1'
        );
        insert smallCategory;

        List<Device__c> deList = new List<Device__c>();
        Device__c dv1 = new Device__c(
            QuoteSpecificationNumber__c = '001',
            Name = '品名',
            MajorClassification__c = 'UPS',
            NETCalculateCategory__c = '受変電',
            Quote__c = quote1.Id,
            PriceCoefficient__c=1,
            Quantity__c = '１2'

        );
        deList.add(dv1);
        insert deList;

        List<Detail__c> dList = new List<Detail__c>();
        Detail__c dtl1 = new Detail__c(
            Device__c = dv1.Id,
            Name = '名称1',
            Quantity__c = 1,
            UnitPrice__c = 1000
        );
        dList.add(dtl1);
        insert dList;
    }
    
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

    @IsTest
    private static void cloneDeviceAndRelatedRecordsTest() {
        //テスト実行
        Test.startTest();
        deviceDataCreation();
        Device__c updateDevice = [SELECT Id,QuoteSpecificationNumber__c,Name,MajorClassification__c,NETCalculateCategory__c,Quote__c,PriceCoefficient__c,Quantity__c FROM Device__c WHERE Name = '品名' LIMIT 1 ];
        
        Device__c dClone = updateDevice.clone();
        dClone.QuoteSpecificationNumber__c = '002';

        insert dClone;
        
        Test.stopTest();

    }

    @IsTest
    private static void cloneDeviceAndRelatedRecordsErrorTest() {
        //テスト実行
        Test.startTest();
        deviceDataCreation();
        Device__c updateDevice = [SELECT Id,QuoteSpecificationNumber__c,Name,MajorClassification__c,NETCalculateCategory__c,Quote__c,PriceCoefficient__c,Quantity__c FROM Device__c WHERE Name = '品名' LIMIT 1 ];
        
        Device__c dClone = updateDevice.clone();

        try{
            insert dClone;
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('この見積の中に項目番号が重複する見積項目が存在しています。'));
        }
        
        
        Test.stopTest();

    }

    @IsTest
    private static void constructionZoneUpdateTest() {
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        deviceDataCreation();

        Quote__c updateQt = [SELECT Id FROM Quote__c WHERE QuoteNumber__c = '1' LIMIT 1];
        ConstructionZone__c updateCon = [SELECT Id FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];
        Device_SmallCategory__c updateSmallCate = [SELECT Id FROM Device_SmallCategory__c WHERE Name = '◯◯工事_細別' LIMIT 1];

        Device__c dvEX = new Device__c(
            QuoteSpecificationNumber__c = '007',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            ClientAnswerAmount_free__c=10000000,
            Note__c ='テスト',
            EquipManageCostTarget__c=true,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象'
        );
        insert dvEX;
        update dvEX;
        
        Test.stopTest();

        Device__c AssertDev = [SELECT Id,ConstructionZone__c FROM Device__c WHERE Device_SmallCategory__c != null LIMIT 1];

        System.assertEquals(updateCon.Id, AssertDev.ConstructionZone__c);

    }

    @IsTest
    private static void deviceDeleteTest() {
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        deviceDataCreation();

        Quote__c updateQt = [SELECT Id FROM Quote__c WHERE QuoteNumber__c = '1' LIMIT 1];
        ConstructionZone__c updateCon = [SELECT Id FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];
        Device_SmallCategory__c updateSmallCate = [SELECT Id FROM Device_SmallCategory__c WHERE Name = '◯◯工事_細別' LIMIT 1];

        Device__c dvEX = new Device__c(
            QuoteSpecificationNumber__c = '007',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            ClientAnswerAmount_free__c=10000000,
            Note__c ='テスト',
            EquipManageCostTarget__c=true,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象'
        );
        insert dvEX;

        delete dvEX;
        
        Test.stopTest();

        ConstructionZone__c AssertCon = [SELECT Id,MachineUnitAmount__c,MachineControlAmount__c,MachineControlRate__c,SystemIntegrationFee__c FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];

        System.assertEquals(null, AssertCon.MachineUnitAmount__c);
        System.assertEquals(null, AssertCon.MachineControlAmount__c);
        System.assertEquals(null, AssertCon.MachineControlRate__c);
        System.assertEquals(null, AssertCon.SystemIntegrationFee__c);
    }
}