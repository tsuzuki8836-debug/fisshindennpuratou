@isTest
private class ConstructionZoneTriggerTest {
    @testSetup
    static void constructionDataCreation() {
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();

        List<Quote__c> qtList = new List<Quote__c>();
        Quote__c quote1 = new Quote__c(
            PowerFrequency__c = '50Hz',
            RecordTypeId = recTypeOfficialDemandId,
            QuoteNumber__c = '1',
            EquipmentCostExistence__c='あり',
            SectionExistence__c='あり'
        );
        qtList.add(quote1);
        
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
    }

    @IsTest
    private static void equipManageCostCalculationTest_Below14million() {
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        constructionDataCreation();

        Quote__c updateQt = [SELECT Id FROM Quote__c LIMIT 1];
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
            ClientAnswerAmount_free__c=14000000,
            Note__c ='テスト',
            EquipManageCostTarget__c=true,
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象'
        );
        insert dvEX;
        
        Test.stopTest();

        ConstructionZone__c AssertCon = [SELECT Id,MachineUnitAmount__c,MachineControlAmount__c,MachineControlRate__c,SystemIntegrationFee__c FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];

        System.assertEquals(14000000, AssertCon.MachineUnitAmount__c);
        System.assertEquals(2550800, AssertCon.MachineControlAmount__c);
        System.assertEquals(18.22, AssertCon.MachineControlRate__c);
        System.assertEquals(0, AssertCon.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest_Over14million() {
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        constructionDataCreation();
        
        Quote__c updateQt = [SELECT Id FROM Quote__c LIMIT 1];
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
            ClientAnswerAmount_free__c=14000001,
            Note__c ='テスト',
            EquipManageCostTarget__c=true,
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象'
        );
        insert dvEX;
        
        Test.stopTest();

        ConstructionZone__c AssertCon = [SELECT Id,MachineUnitAmount__c,MachineControlAmount__c,MachineControlRate__c,SystemIntegrationFee__c FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];

        System.assertEquals(14000001, AssertCon.MachineUnitAmount__c);
        System.assertEquals(2550800.1822, AssertCon.MachineControlAmount__c);
        System.assertEquals(18.22, AssertCon.MachineControlRate__c);
        System.assertEquals(0, AssertCon.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest_Below200million() {
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        constructionDataCreation();
        
        Quote__c updateQt = [SELECT Id FROM Quote__c LIMIT 1];
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
            ClientAnswerAmount_free__c=200000000,
            Note__c ='テスト',
            EquipManageCostTarget__c=true,
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象'
        );
        insert dvEX;
        
        Test.stopTest();

        ConstructionZone__c AssertCon = [SELECT Id,MachineUnitAmount__c,MachineControlAmount__c,MachineControlRate__c,SystemIntegrationFee__c FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];

        System.assertEquals(200000000, AssertCon.MachineUnitAmount__c);
        System.assertEquals(10420000, AssertCon.MachineControlAmount__c);
        System.assertEquals(5.21, AssertCon.MachineControlRate__c);
        System.assertEquals(0, AssertCon.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest_Over200million() {
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        constructionDataCreation();
        
        Quote__c updateQt = [SELECT Id FROM Quote__c LIMIT 1];
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
            ClientAnswerAmount_free__c=200000001,
            Note__c ='テスト',
            EquipManageCostTarget__c=true,
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象'
        );
        insert dvEX;
        
        Test.stopTest();

        ConstructionZone__c AssertCon = [SELECT Id,MachineUnitAmount__c,MachineControlAmount__c,MachineControlRate__c,SystemIntegrationFee__c FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];

        System.assertEquals(200000001, AssertCon.MachineUnitAmount__c);
        System.assertEquals(10420000.0521, AssertCon.MachineControlAmount__c);
        System.assertEquals(5.21, AssertCon.MachineControlRate__c);
        System.assertEquals(0, AssertCon.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest_InSupplies() {
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        constructionDataCreation();
        
        Quote__c updateQt = [SELECT Id FROM Quote__c LIMIT 1];
        ConstructionZone__c updateCon = [SELECT Id FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];
        Device_SmallCategory__c updateSmallCate = [SELECT Id FROM Device_SmallCategory__c WHERE Name = '◯◯工事_細別' LIMIT 1];

        List<Device__c> deList = new List<Device__c>();
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
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象'
        );
        deList.add(dvEX);

        Device__c dvEX2 = new Device__c(
            QuoteSpecificationNumber__c = '008',
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
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='支給品'
        );
        deList.add(dvEX2);

        Device__c dvEX3 = new Device__c(
            QuoteSpecificationNumber__c = '009',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            ClientAnswerAmount_free__c=5000000,
            Note__c ='テスト',
            EquipManageCostTarget__c=true,
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象(製作のみ)'
        );
        deList.add(dvEX3);

        Device__c dvEX4 = new Device__c(
            QuoteSpecificationNumber__c = '010',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='システムインテグレーション費',
            Note__c ='テスト',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            ClientAnswerAmount_free__c=2000000,
            EquipManageCostTarget__c=true,
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象'
        );
        deList.add(dvEX4);
        insert deList;
        
        Test.stopTest();

        ConstructionZone__c AssertCon = [SELECT Id,MachineUnitAmount__c,MachineControlAmount__c,MachineControlRate__c,SystemIntegrationFee__c FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];

        System.assertEquals(25000000, AssertCon.MachineUnitAmount__c);
        System.assertEquals(1456500, AssertCon.MachineControlAmount__c);
        System.assertEquals(9.71, AssertCon.MachineControlRate__c);
        System.assertEquals(2000000, AssertCon.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest_InNotApplicable() {
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        constructionDataCreation();
        
        Quote__c updateQt = [SELECT Id FROM Quote__c LIMIT 1];
        ConstructionZone__c updateCon = [SELECT Id FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];
        Device_SmallCategory__c updateSmallCate = [SELECT Id FROM Device_SmallCategory__c WHERE Name = '◯◯工事_細別' LIMIT 1];

        List<Device__c> deList = new List<Device__c>();
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
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象'
        );
        deList.add(dvEX);

        Device__c dvEX2 = new Device__c(
            QuoteSpecificationNumber__c = '008',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            ClientAnswerAmount_free__c=4100000,
            Note__c ='テスト',
            EquipManageCostTarget__c=true,
            ConstructionZone__c = updateCon.Id,
            Device_SmallCategory__c = updateSmallCate.Id,
            QuoteTarget__c='見積対象外'
        );
        deList.add(dvEX2);

        insert deList;
        
        Test.stopTest();

        ConstructionZone__c AssertCon = [SELECT Id,MachineUnitAmount__c,MachineControlAmount__c,MachineControlRate__c,SystemIntegrationFee__c FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];

        System.assertEquals(14100000, AssertCon.MachineUnitAmount__c);
        System.assertEquals(1816000, AssertCon.MachineControlAmount__c);
        System.assertEquals(18.16, AssertCon.MachineControlRate__c);
        System.assertEquals(0, AssertCon.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTestForNone() {
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        constructionDataCreation();
        
        ConstructionZone__c updateCon = [SELECT Id FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];

        update updateCon;
        
        Test.stopTest();

        ConstructionZone__c AssertCon = [SELECT Id,MachineUnitAmount__c,MachineControlAmount__c,MachineControlRate__c,SystemIntegrationFee__c FROM ConstructionZone__c WHERE Name = 'テスト工事区分' LIMIT 1];

        System.assertEquals(null, AssertCon.MachineUnitAmount__c);
        System.assertEquals(null, AssertCon.MachineControlAmount__c);
        System.assertEquals(null, AssertCon.MachineControlRate__c);
        System.assertEquals(null, AssertCon.SystemIntegrationFee__c);

    }
}