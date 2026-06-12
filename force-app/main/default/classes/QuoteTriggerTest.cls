@isTest
private class QuoteTriggerTest {
    @testSetup
    static void quotedataCreation() {
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = '施設'];
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();

        List<Quote__c> qtList = new List<Quote__c>();
        Quote__c quote1 = new Quote__c(
            PowerFrequency__c = '50Hz',
            RecordTypeId = recType[0].Id,
            QuoteNumber__c = '1'
        );
        qtList.add(quote1);

        Quote__c quote2 = new Quote__c(
            PowerFrequency__c = '50Hz',
            RecordTypeId = recType[0].Id,
            QuoteNumber__c = '1'
        );
        qtList.add(quote2);

        Quote__c quote3 = new Quote__c(
            PowerFrequency__c = '50Hz',
            RecordTypeId = recTypeOfficialDemandId,
            QuoteNumber__c = '3',
            EquipmentCostExistence__c='あり',
            SectionExistence__c='なし'
        );
        qtList.add(quote3);

        Quote__c quote4 = new Quote__c(
            PowerFrequency__c = '50Hz',
            RecordTypeId = recTypeOfficialDemandId,
            QuoteNumber__c = '1',
            EquipmentCostExistence__c='あり',
            SectionExistence__c='あり'
        );
        qtList.add(quote4);

        insert qtList;

        List<ConstructionZone__c> conList = new List<ConstructionZone__c>();
        ConstructionZone__c con = new ConstructionZone__c(
            Name = 'テスト工事区分',
            Quote__c = quote4.Id,
            ConstructionZoneNo__c = 1
        );
        conList.add(con);

        insert conList;

        Device_LargeCategory__c largeCategory = new Device_LargeCategory__c(
            Quote__c = quote4.Id,
            ConstructionZone__c = con.Id,
            Name = '◯◯工事_工種',
            Device_LargeCategoryNo__c = '1'
        );
        insert largeCategory;

        Device_MiddleCategory__c middleCategory = new Device_MiddleCategory__c(
            Quote__c = quote4.Id,
            Device_LargeCategory__c = largeCategory.Id,
            Name = '◯◯工事_種別',
            Device_MiddleCategoryNo__c = '1'
        );
        insert middleCategory;

        Device_SmallCategory__c smallCategory = new Device_SmallCategory__c(
            Quote__c = quote4.Id,
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
        Device__c dv2 = new Device__c(
            QuoteSpecificationNumber__c = '002',
            Name = '品名',
            MajorClassification__c = 'UPS',
            NETCalculateCategory__c = 'UPS',
            Quote__c = quote1.Id,
            PriceCoefficient__c=1,
            Quantity__c = '２'

        );
        deList.add(dv2);
        Device__c dv3 = new Device__c(
            QuoteSpecificationNumber__c = '003',
            Name = '品名',
            MajorClassification__c = '特高',
            NETCalculateCategory__c = '自家発',
            Quote__c = quote1.Id,
            PriceCoefficient__c=1,
            Quantity__c = '２'

        );
        deList.add(dv3);
        Device__c dv4 = new Device__c(
            QuoteSpecificationNumber__c = '004',
            Name = '品名',
            MajorClassification__c = 'UPS',
            NETCalculateCategory__c = 'ビルシ',
            Quote__c = quote2.Id,
            PriceCoefficient__c=1,
            Quantity__c = '１2'

        );
        deList.add(dv4);
        Device__c dv5 = new Device__c(
            QuoteSpecificationNumber__c = '005',
            Name = '品名',
            MajorClassification__c = '変圧器',
            NETCalculateCategory__c = '映像',
            Quote__c = quote2.Id,
            PriceCoefficient__c=1,
            Quantity__c = '２'

        );
        deList.add(dv5);
        //Device__c dv6 = new Device__c(
            //QuoteSpecificationNumber__c = '006',
            //Name = '品名',
            //MajorClassification__c = '材料',
            //NETCalculateCategory__c = '労務',
            //Quote__c = quote3.Id,
            //PriceCoefficient__c=1,
            //Quantity__c = '２',
            //CreditQuoteAmount__c=100000,
            //Note__c='テスト用'
        //);
        //deList.add(dv6);

        Device__c dvEX = new Device__c(
            QuoteSpecificationNumber__c = '007',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = quote4.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            ClientAnswerAmount_free__c=14000000,
            Note__c ='テスト',
            EquipManageCostTarget__c=true,
            ConstructionZone__c = con.Id,
            Device_SmallCategory__c = smallCategory.Id,
            QuoteTarget__c='見積対象'
        );
        deList.add(dvEX);
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
        Detail__c dtl3 = new Detail__c(
            Device__c = dv3.Id,
            Name = '名称3',
            Quantity__c = 3,
            UnitPrice__c = 3000
        );
        dList.add(dtl3);
        Detail__c dtl4 = new Detail__c(
            Device__c = dv4.Id,
            Name = '名称4',
            Quantity__c = 4,
            UnitPrice__c = 4000
        );
        dList.add(dtl4);
        Detail__c dtl5 = new Detail__c(
            Device__c = dv5.Id,
            Name = '名称5',
            Quantity__c = 5,
            UnitPrice__c = 5000
        );
        dList.add(dtl5);
        insert dList;
    }

    @IsTest
    private static void cloneQuoteAndRelatedRecordsTest() {
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        quotedataCreation();
        List<Quote__c> cloneQtList = new List<Quote__c>();
        for(Quote__c qt : [SELECT Id,PowerFrequency__c,QuoteNumber__c,QuotePriceSum__c,SectionExistence__c,EquipmentCostExistence__c,RecordTypeId FROM Quote__c
        ]){
            Quote__c qClone = qt.clone(false,true);
            System.debug('工区有無：' + qClone.SectionExistence__c);
            // qClone.SelfTotal_NET_LastAcc__c=1;
            cloneQtList.add(qClone);
        }

        insert cloneQtList;

        Test.stopTest();

    }
    @IsTest
    private static void equipManageCostCalculationTest() {
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        quotedataCreation();
        List<Quote__c> updateQtList = new List<Quote__c>();
        for(Quote__c qt : [SELECT Id,  PowerFrequency__c,QuoteNumber__c,QuotePriceSum__c FROM Quote__c WHERE RecordTypeId != :recTypeOfficialDemandId
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

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest1() {
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        quotedataCreation();

        Quote__c updateQt = [SELECT Id FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        Device__c dvEX = new Device__c(
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
            EquipManageCostTarget__c=true,
            QuoteTarget__c='見積対象',
            Note__c ='テスト'
        );
        insert dvEX;

        Test.stopTest();

        Quote__c AssertQt = [SELECT Id,MachineUnitAmount__c,EquipManageCost__c,EquipManageCostRate__c,SystemIntegrationFee__c FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        System.assertEquals(10000000, AssertQt.MachineUnitAmount__c);
        System.assertEquals(1822000, AssertQt.EquipManageCost__c);
        System.assertEquals(18.22, AssertQt.EquipManageCostRate__c);
        System.assertEquals(0, AssertQt.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest2() {
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        quotedataCreation();

        Quote__c updateQt = [SELECT Id FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        Device__c dvEX = new Device__c(
            QuoteSpecificationNumber__c = '8',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            Note__c ='テスト',
            ClientAnswerAmount_free__c=20000000,
            EquipManageCostTarget__c=true,
            QuoteTarget__c='見積対象'
        );
        insert dvEX;

        Test.stopTest();

        Quote__c AssertQt = [SELECT Id,MachineUnitAmount__c,EquipManageCost__c,EquipManageCostRate__c,SystemIntegrationFee__c FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        System.assertEquals(20000000, AssertQt.MachineUnitAmount__c);
        System.assertEquals(3080000, AssertQt.EquipManageCost__c);
        System.assertEquals(15.4, AssertQt.EquipManageCostRate__c);
        System.assertEquals(0, AssertQt.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest3() {
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        quotedataCreation();

        Quote__c updateQt = [SELECT Id FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        Device__c dvEX = new Device__c(
            QuoteSpecificationNumber__c = '008',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            Note__c ='テスト',
            ClientAnswerAmount_free__c=200000001,
            EquipManageCostTarget__c=true,
            QuoteTarget__c='見積対象'
        );
        insert dvEX;

        Test.stopTest();

        Quote__c AssertQt = [SELECT Id,MachineUnitAmount__c,EquipManageCost__c,EquipManageCostRate__c,SystemIntegrationFee__c FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        System.assertEquals(200000001, AssertQt.MachineUnitAmount__c);
        System.assertEquals(10420000.0521, AssertQt.EquipManageCost__c);
        System.assertEquals(5.21, AssertQt.EquipManageCostRate__c);
        System.assertEquals(0, AssertQt.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest4() {
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        quotedataCreation();

        Quote__c updateQt = [SELECT Id FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        List<Device__c> deList = new List<Device__c>();
        Device__c dvEX = new Device__c(
            QuoteSpecificationNumber__c = '008',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            Note__c ='テスト',
            ClientAnswerAmount_free__c=10000000,
            EquipManageCostTarget__c=true,
            QuoteTarget__c='見積対象'
        );
        deList.add(dvEX);

        Device__c dvEX2 = new Device__c(
            QuoteSpecificationNumber__c = '009',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            Note__c ='テスト',
            ClientAnswerAmount_free__c=10000000,
            EquipManageCostTarget__c=true,
            QuoteTarget__c='支給品'
        );
        deList.add(dvEX2);

        Device__c dvEX3 = new Device__c(
            QuoteSpecificationNumber__c = '010',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            Note__c ='テスト',
            ClientAnswerAmount_free__c=5000000,
            EquipManageCostTarget__c=true,
            QuoteTarget__c='見積対象(製作のみ)'
        );
        deList.add(dvEX3);

        Device__c dvEX4 = new Device__c(
            QuoteSpecificationNumber__c = '11',
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
            QuoteTarget__c='見積対象'
        );
        deList.add(dvEX4);
        insert deList;

        Test.stopTest();

        Quote__c AssertQt = [SELECT Id,MachineUnitAmount__c,EquipManageCost__c,EquipManageCostRate__c,SystemIntegrationFee__c FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        System.assertEquals(25000000, AssertQt.MachineUnitAmount__c);
        System.assertEquals(1456500, AssertQt.EquipManageCost__c);
        System.assertEquals(9.71, AssertQt.EquipManageCostRate__c);
        System.assertEquals(2000000, AssertQt.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTest5() {
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        quotedataCreation();

        Quote__c updateQt = [SELECT Id FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        List<Device__c> deList = new List<Device__c>();
        Device__c dvEX = new Device__c(
            QuoteSpecificationNumber__c = '008',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            Note__c ='テスト',
            ClientAnswerAmount_free__c=10000000,
            EquipManageCostTarget__c=true,
            QuoteTarget__c='見積対象'
        );
        deList.add(dvEX);

        Device__c dvEX2 = new Device__c(
            QuoteSpecificationNumber__c = '009',
            RecordTypeId=recTypeOfficialDemandIdForDevice,
            RecordTypeOfQuote__c='官需',
            Name = '品名',
            MajorClassification__c ='テレメータ装置[国交省本省宛て提出機器単体費]',
            MinorClassification__c='2量型観測局装置',
            Quote__c = updateQt.Id,
            PriceCoefficient__c=1,
            Quantity__c = '1',
            Note__c ='テスト',
            ClientAnswerAmount_free__c=4100000,
            EquipManageCostTarget__c=true,
            QuoteTarget__c='見積対象外'
        );
        deList.add(dvEX2);

        insert deList;

        Test.stopTest();

        Quote__c AssertQt = [SELECT Id,MachineUnitAmount__c,EquipManageCost__c,EquipManageCostRate__c,SystemIntegrationFee__c FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        System.assertEquals(14100000, AssertQt.MachineUnitAmount__c);
        System.assertEquals(1816000, AssertQt.EquipManageCost__c);
        System.assertEquals(18.16, AssertQt.EquipManageCostRate__c);
        System.assertEquals(0, AssertQt.SystemIntegrationFee__c);

    }

    @IsTest
    private static void updateQuoteAndRelatedRecordsTestForNone() {
        Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        Id recTypeOfficialDemandIdForDevice = Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
        //テスト実行
        Test.startTest();
        quotedataCreation();

        Quote__c updateQt = [SELECT Id FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        update updateQt;

        Test.stopTest();

        Quote__c AssertQt = [SELECT Id,MachineUnitAmount__c,EquipManageCost__c,EquipManageCostRate__c,SystemIntegrationFee__c FROM Quote__c WHERE RecordTypeId = :recTypeOfficialDemandId LIMIT 1];

        System.assertEquals(null, AssertQt.MachineUnitAmount__c);
        System.assertEquals(null, AssertQt.EquipManageCost__c);
        System.assertEquals(null, AssertQt.EquipManageCostRate__c);
        System.assertEquals(null, AssertQt.SystemIntegrationFee__c);

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