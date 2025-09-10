@isTest
public with sharing class DetailsInputForExtraHighControllerTest {
    
    @TestSetup
    static void makeData(){
        Integer recNo = 0;
        List<PricingTable__c> pricingDataOil = initPricingTableDataOil(recNo);
        insert pricingDataOil;
        List<PricingTable__c> pricingDataMold = initPricingTableDataMold(recNo);
        insert pricingDataMold;
        List<PricingTable__c> pricingDataGas = initPricingTableDataGas(recNo);
        insert pricingDataGas;
        initStandardData();
    }
    static void initStandardData() {
        //////////////////////////////////////////////////////////////////////////////////////////////
        //                    Account, Quote__c, Device__c, Detail__c                               //
        //////////////////////////////////////////////////////////////////////////////////////////////
        String DEFAULT_MAJOR_CLASSIFICATION = '変圧器';
        String DEFAULT_MINOR_CLASSIFICATION = '特高変圧器';

        Account account = new Account(
            Name='Test Account Name'
        );
        insert account;

        // 施設
        RecordType quoteFacilityRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='施設' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote1 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 1',
            QuoteNumber__c='1234567890',
            GeneralAdministrativeExpenses__c='23',
            PowerFrequency__c='50Hz', // {50Hz, 60Hz}
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteFacilityRecordType.Id
        );
        insert quote1;

        // 水環境
        RecordType quoteWaterRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='水環境' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote2 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 2',
            QuoteNumber__c='1234567891',
            GeneralAdministrativeExpenses__c='25',
            PowerFrequency__c='60Hz', // {50Hz, 60Hz}
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteWaterRecordType.Id
        );
        insert quote2;

        Quote__c quote3 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 3',
            QuoteNumber__c='1234567892',
            GeneralAdministrativeExpenses__c='25',
            PowerFrequency__c='60Hz', // {50Hz, 60Hz}
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteWaterRecordType.Id
        );
        insert quote3;

        // 官需
        RecordType quotePDemandRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='官需' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote4 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 4',
            QuoteNumber__c='1234567893',
            GeneralAdministrativeExpenses__c='25',
            PowerFrequency__c='60Hz', // {50Hz, 60Hz}
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quotePDemandRecordType.Id
        );
        insert quote4;

        // 施設
        RecordType deviceFacilityRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='施設' AND SobjectType='Device__c' LIMIT 1];
        Device__c device1 = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 1',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567890',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='施設', // {施設, 水環境, 官需}
            MajorClassification__c=DEFAULT_MAJOR_CLASSIFICATION,
            MinorClassification__c=DEFAULT_MINOR_CLASSIFICATION,
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        insert device1;

        Device__c device2 = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 2',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567891',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='施設', // {施設, 水環境, 官需}
            MajorClassification__c=DEFAULT_MAJOR_CLASSIFICATION,
            MinorClassification__c=DEFAULT_MINOR_CLASSIFICATION,
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        insert device2;

        // 水環境
        RecordType deviceWaterRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='水環境' AND SobjectType='Device__c' LIMIT 1];
        Device__c device3 = new Device__c(
            Quote__c=quote2.Id,
            Name='Test Device Name 3',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567892',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='水環境', // {施設, 水環境, 官需}
            MajorClassification__c=DEFAULT_MAJOR_CLASSIFICATION,
            MinorClassification__c=DEFAULT_MINOR_CLASSIFICATION,
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceWaterRecordType.Id
        );
        insert device3;

        List<Detail__c> details = new List<Detail__c>();
        // 筐体 :: GIS直結
        details.add(new Detail__c(
            Device__c=device2.Id,
            Name='特高TR油入',
            Name1__c='油 スポットネットワーク',
            Name2__c='屋外',
            Name3__c='三相',
            Name4__c='22,000V',
            PricingTableUniqueKey__c='筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相22,000V6,600V1,000kVA特高TR油入',
            UnitPrice__c=12000000,
            DetailCategory__c='筐体',
            Quantity__c=1,
            WcCalculationRate__c=0.0,
            Name5__c='6,600V',
            Name6__c='1,000kVA',
            Name10__c='特高TR油入',
            detailedStatementText__c='TR',
            SpecialSpecificationNo__c=3,
            MajorClassificationName__c='変圧器',
            MajorClassificationCode__c='23',
            MinorClassificationName__c='特高変圧器',
            MinorClassificationCode__c='01',
            CategoryCode__c='01'
        ));

        //  明細
        details.add(new Detail__c(
            Device__c=device2.Id,
            Name='特高油入',
            Name1__c='油',
            Name2__c='GIS直結',
            Name3__c='1,000kVA',
            PricingTableUniqueKey__c='明細S変圧器特高変圧器油GIS直結1,000kVA',
            UnitPrice__c=2100000,
            DetailCategory__c='明細',
            Quantity__c=1,
            SpecialSpecificationNo__c=0,
            MajorClassificationName__c='変圧器',
            MajorClassificationCode__c='23',
            MinorClassificationName__c='特高変圧器',
            MinorClassificationCode__c='01',
            CategoryCode__c='00'
        ));

        //  明細 : OLTC付
        details.add(new Detail__c(
            Device__c=device2.Id,
            Name='特高油入',
            Name1__c='油',
            Name2__c='OLTC付',
            PricingTableUniqueKey__c='明細S変圧器特高変圧器油OLTC付',
            UnitPrice__c=22000000,
            DetailCategory__c='明細',
            Quantity__c=1,
            SpecialSpecificationNo__c=0,
            MajorClassificationName__c='変圧器',
            MajorClassificationCode__c='23',
            MinorClassificationName__c='特高変圧器',
            MinorClassificationCode__c='01',
            CategoryCode__c='00'
        ));
        insert details;

        
    } 

    static List<PricingTable__c> initPricingTableDataOil(Integer recNo) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        RecordType chassisRecordType = [SELECT Id, DeveloperName  FROM RecordType WHERE DeveloperName='Chassis' LIMIT 1];
        RecordType detailRecordType = [SELECT Id, DeveloperName  FROM RecordType WHERE DeveloperName='Detail' LIMIT 1];

        List<String> name6List = new List<String>{'1,000kVA', '1,200kVA', '1,250kVA', '1,500kVA', '2,000kVA', '2,500kVA'};
        List<Decimal> priceList = new List<Decimal>{9800000, 11100000, 13200000, 16100000, 20100000, 21100000};

        List<String> keyList11 = new List<String>{'筐体S変圧器特高変圧器60Hz油屋内三相22,000V6,600V1,000kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油屋内三相22,000V6,600V1,200kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油屋内三相22,000V6,600V1,250kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油屋内三相22,000V6,600V1,500kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油屋内三相22,000V6,600V2,000kVA特高TR油入'};
        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TR油入';
            pricingTable.CategoryName__c = '60Hz';
            pricingTable.Name1__c = '油';
            pricingTable.Name2__c = '屋内';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '22,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '02';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TR油入';
            pricingTable.CategoryName__c = '50Hz';
            pricingTable.Name1__c = '油';
            pricingTable.Name2__c = '屋内';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '22,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '01';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        List<String> keyList12 = new List<String>{'筐体S変圧器特高変圧器60Hz油屋内三相11,000V6,600V1,000kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油屋内三相11,000V6,600V1,200kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油屋内三相11,000V6,600V1,250kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油屋内三相11,000V6,600V1,500kVA特高TR油入'};
        for (Integer i = 0; i < 4 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TR油入';
            pricingTable.CategoryName__c = '60Hz';
            pricingTable.Name1__c = '油';
            pricingTable.Name2__c = '屋内';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '11,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '02';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        for (Integer i = 0; i < 4 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TR油入';
            pricingTable.CategoryName__c = '50Hz';
            pricingTable.Name1__c = '油';
            pricingTable.Name2__c = '屋内';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '11,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '01';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        for (Integer i = 0; i < 1 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TR油入';
            pricingTable.CategoryName__c = '60Hz';
            pricingTable.Name1__c = '油';
            pricingTable.Name2__c = '屋内';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '33,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '02';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        for (Integer i = 0; i < 1 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TR油入';
            pricingTable.CategoryName__c = '50Hz';
            pricingTable.Name1__c = '油';
            pricingTable.Name2__c = '屋内';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '33,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '01';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        List<String> keyList21 = new List<String>{'筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相22,000V6,600V1,000kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相22,000V6,600V1,200kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相22,000V6,600V1,250kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相22,000V6,600V1,500kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相22,000V6,600V2,000kVA特高TR油入'};
        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TR油入';
            pricingTable.CategoryName__c = '60Hz';
            pricingTable.Name1__c = '油 スポットネットワーク';
            pricingTable.Name2__c = '屋外';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '22,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '02';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        // for (Integer i = 0; i < 5 ; i++) {
        //     PricingTable__c pricingTable = new PricingTable__c();
        //     pricingTable.RecordTypeId = chassisRecordType.Id;
        //     pricingTable.DisplayName__c = '特高TR油入';
        //     pricingTable.CategoryName__c = '50Hz';
        //     pricingTable.Name1__c = '油 スポットネットワーク';
        //     pricingTable.Name2__c = '屋外';
        //     pricingTable.Name3__c = '三相';
        //     pricingTable.Name4__c = '22,000V';
        //     pricingTable.Name5__c = '6,600V';
        //     pricingTable.Name6__c = name6List.get(i);
        //     pricingTable.Name10__c = '特高TR油入';
        //     pricingTable.Price__c = priceList.get(i);
        //     pricingTable.BU__c = 'S';
        //     pricingTable.detailedStatementText__c = 'TR';
        //     pricingTable.SpecialSpecificationNo__c = 0;
        //     pricingTable.MajorClassificationName__c  = '変圧器';
        //     pricingTable.MajorClassificationCode__c  = '23';
        //     pricingTable.MinorClassificationName__c = '特高変圧器';
        //     pricingTable.MinorClassificationCode__c = '01';
        //     pricingTable.CategoryCode__c = '01';
        //     pricingTable.RECNo__c=++recNo;
        //     pricingTableList.add(pricingTable);
        // }

        List<String> keyList22 = new List<String>{'筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相66,000V13,800V1,000kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相66,000V13,800V1,200kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相66,000V13,800V1,250kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相66,000V13,800V1,500kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相66,000V13,800V2,000kVA特高TR油入'};
        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TR油入';
            pricingTable.CategoryName__c = '60Hz';
            pricingTable.Name1__c = '油 スポットネットワーク';
            pricingTable.Name2__c = '屋外';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '66,000V';
            pricingTable.Name5__c = '13,800V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '02';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TR油入';
            pricingTable.CategoryName__c = '50Hz';
            pricingTable.Name1__c = '油 スポットネットワーク';
            pricingTable.Name2__c = '屋外';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '66,000V';
            pricingTable.Name5__c = '13,800V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '01';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        List<String> keyList3 = new List<String>{'明細S変圧器特高変圧器油GIS直結1,000kVA特高TR油入',
                                                '明細S変圧器特高変圧器油GIS直結1,200kVA特高TR油入',
                                                '明細S変圧器特高変圧器油GIS直結1,250kVA特高TR油入',
                                                '明細S変圧器特高変圧器油GIS直結1,500kVA特高TR油入',
                                                '明細S変圧器特高変圧器油GIS直結2,000kVA特高TR油入'};
        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = detailRecordType.Id;
            pricingTable.DisplayName__c = '特高油入';
            pricingTable.CategoryName__c = null;
            pricingTable.Name1__c = '油';
            pricingTable.Name2__c = 'GIS直結';
            pricingTable.Name3__c = name6List.get(i);
            pricingTable.Name4__c = null;
            pricingTable.Name5__c = null;
            pricingTable.Name6__c = null;
            pricingTable.Name10__c = null;
            pricingTable.Price__c = priceList.get(0);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '00';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        List<String> keyList4 = new List<String>{'明細S変圧器特高変圧器油OLTC付',
                                                '明細S変圧器特高変圧器油OLTC付',
                                                '明細S変圧器特高変圧器油OLTC付',
                                                '明細S変圧器特高変圧器油OLTC付',
                                                '明細S変圧器特高変圧器油OLTC付'};
        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = detailRecordType.Id;
            pricingTable.DisplayName__c = '特高油入';
            pricingTable.CategoryName__c = null;
            pricingTable.Name1__c = '油';
            pricingTable.Name2__c = 'OLTC付';
            pricingTable.Name3__c = name6List.get(i);
            pricingTable.Name4__c = null;
            pricingTable.Name5__c = null;
            pricingTable.Name6__c = null;
            pricingTable.Name10__c = null;
            pricingTable.Price__c = priceList.get(0);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = null;
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '00';
            pricingTable.RECNo__c=++recNo;
            pricingTableList.add(pricingTable);
        }

        return pricingTableList;
    }

    static List<PricingTable__c> initPricingTableDataMold(Integer recNo) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        RecordType chassisRecordType = [SELECT Id, DeveloperName  FROM RecordType WHERE DeveloperName='Chassis' LIMIT 1];
        RecordType detailRecordType = [SELECT Id, DeveloperName  FROM RecordType WHERE DeveloperName='Detail' LIMIT 1];

        List<String> name6List = new List<String>{'1,000kVA', '1,200kVA', '1,250kVA', '1,500kVA', '2,000kVA'};
        List<Decimal> priceList = new List<Decimal>{9800000, 11100000, 13200000, 16100000, 20100000};
        List<String> keyList = new List<String>{'筐体S変圧器特高変圧器60Hzモールド三相22,000V6,600V1,000kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hzモールド三相22,000V6,600V1,200kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hzモールド三相22,000V6,600V1,250kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hzモールド三相22,000V6,600V1,500kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hzモールド三相22,000V6,600V2,000kVA特高TR油入'};
        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TRモールド';
            pricingTable.CategoryName__c = '60Hz';
            pricingTable.Name1__c = 'モールド';
            pricingTable.Name2__c = '屋内';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '22,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '02';
            pricingTable.RECNo__c=++recNo;

            pricingTableList.add(pricingTable);
        }

        return pricingTableList;
    }

    static List<PricingTable__c> initPricingTableDataGas(Integer recNo) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        RecordType chassisRecordType = [SELECT Id, DeveloperName  FROM RecordType WHERE DeveloperName='Chassis' LIMIT 1];
        RecordType detailRecordType = [SELECT Id, DeveloperName  FROM RecordType WHERE DeveloperName='Detail' LIMIT 1];

        List<String> name6List = new List<String>{'1,000kVA', '1,200kVA', '1,250kVA', '1,500kVA', '2,000kVA'};
        List<Decimal> priceList = new List<Decimal>{9800000, 11100000, 13200000, 16100000, 20100000};
        List<String> keyList = new List<String>{'筐体S変圧器特高変圧器60Hzガス三相22,000V6,600V1,000kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hzガス三相22,000V6,600V1,200kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hzガス三相22,000V6,600V1,250kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hzガス三相22,000V6,600V1,500kVA特高TR油入',
                                                '筐体S変圧器特高変圧器60Hzガス三相22,000V6,600V2,000kVA特高TR油入'};
        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TRガス';
            pricingTable.CategoryName__c = '60Hz';
            pricingTable.Name1__c = 'ガス';
            pricingTable.Name2__c = '屋内';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '22,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '02';
            pricingTable.RECNo__c=++recNo;

            pricingTableList.add(pricingTable);
        }

        for (Integer i = 0; i < 5 ; i++) {
            PricingTable__c pricingTable = new PricingTable__c();
            pricingTable.RecordTypeId = chassisRecordType.Id;
            pricingTable.DisplayName__c = '特高TRガス';
            pricingTable.CategoryName__c = '50Hz';
            pricingTable.Name1__c = 'ガス';
            pricingTable.Name2__c = '屋内';
            pricingTable.Name3__c = '三相';
            pricingTable.Name4__c = '22,000V';
            pricingTable.Name5__c = '6,600V';
            pricingTable.Name6__c = name6List.get(i);
            pricingTable.Name10__c = '特高TR油入';
            pricingTable.Price__c = priceList.get(i);
            pricingTable.BU__c = 'S';
            pricingTable.detailedStatementText__c = 'TR';
            pricingTable.SpecialSpecificationNo__c = 0;
            pricingTable.MajorClassificationName__c  = '変圧器';
            pricingTable.MajorClassificationCode__c  = '23';
            pricingTable.MinorClassificationName__c = '特高変圧器';
            pricingTable.MinorClassificationCode__c = '01';
            pricingTable.CategoryCode__c = '01';
            pricingTable.RECNo__c=++recNo;

            pricingTableList.add(pricingTable);
        }

        return pricingTableList;
    }


    @IsTest
    private static void getDetailsInputForExtraHighInfoCase1Test() {

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];

        Boolean isInit = true;
        String deviceId = device.Id;
        String screenType = '1';
        String searchCondition1 = '1';
        String searchCondition2 = '0';
        String searchCondition3 = '0';
        String searchCondition4 = '0';
        String searchCondition5 = '0';

        Test.startTest();
        String res_actaul = DetailsInputForExtraHighController.getDetailsInputForExtraHighInfo(
            isInit,
            deviceId,
            screenType,
            searchCondition1,
            searchCondition2,
            searchCondition3,
            searchCondition4,
            searchCondition5
        );
        Test.stopTest();
        Map<String, Object> res_actaulMap = (Map<String, Object>)JSON.deserializeUntyped(res_actaul);

        System.debug('================Case1=================');

        String errorMsg = '';
        Boolean isNoData = false;

        String inputedId = null;
        String displayCondition = null;
        Decimal displayTotal = null;

        String displayLabel = '特高TR 油入 屋内 GIS直結なし 電圧仕様標準 OLTCなし スポットネットワークなし';
        
        Assert.areEqual(errorMsg, res_actaulMap.get('errorMsg'));
        Assert.areEqual(isNoData, res_actaulMap.get('isNoData'));
        Assert.areEqual(inputedId, res_actaulMap.get('inputedId'));
        Assert.areEqual(displayCondition, res_actaulMap.get('displayCondition'));
        Assert.areEqual(displayTotal, res_actaulMap.get('displayTotal'));

        Assert.areEqual(displayLabel, res_actaulMap.get('displayLabel'));

        Assert.areEqual('1', res_actaulMap.get('screenType'));
        Assert.areEqual('1', res_actaulMap.get('searchCondition1'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition2'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition3'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition4'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition5'));

        //Check [headerList]
        List<Object> headerList_expectList = new List<Object>{
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>4, 'value'=>'容量'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'一次電圧'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'11,000V'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'22,000V'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'33,000V'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'二次電圧'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'6,600V'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'6,600V'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'6,600V'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'相数'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'三相'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'三相'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'三相'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'周波数'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'50Hz'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'GIS直結'},
                    
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'50Hz'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'GIS直結'},

                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'50Hz'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'GIS直結'}
                }
            }
        };

        List<Object> headerList_actualList = (List<Object>)res_actaulMap.get('headerList');
        for(Integer i=0; i<headerList_actualList.size(); i++) {
            Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
            List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
            Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
            List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

            for(Integer j=0; j<cellList_actaul.size(); j++) {
                Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
            }
        }

        // Check [bodyList]
        List<Object> bodyList_expectList = new List<Object>{
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1,000kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>9800000, 'title'=>'油 屋内 三相 11,000V 6,600V 1,000kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>9800000, 'title'=>'油 屋内 三相 22,000V 6,600V 1,000kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>9800000, 'title'=>'油 屋内 三相 33,000V 6,600V 1,000kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1,200kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'11,100,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>11100000, 'title'=>'油 屋内 三相 11,000V 6,600V 1,200kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'11,100,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>11100000, 'title'=>'油 屋内 三相 22,000V 6,600V 1,200kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1,250kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'13,200,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>13200000, 'title'=>'油 屋内 三相 11,000V 6,600V 1,250kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'13,200,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>13200000, 'title'=>'油 屋内 三相 22,000V 6,600V 1,250kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1,500kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'16,100,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>16100000, 'title'=>'油 屋内 三相 11,000V 6,600V 1,500kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'16,100,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>16100000, 'title'=>'油 屋内 三相 22,000V 6,600V 1,500kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'2,000kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'20,100,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>20100000, 'title'=>'油 屋内 三相 22,000V 6,600V 2,000kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TR 油入"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'―'}
                }
            }
        };           

        List<Object> bodyList_actualList = (List<Object>)res_actaulMap.get('bodyList');
        for(Integer i=0; i<bodyList_actualList.size(); i++) {
            Map<String, Object> cell_expect = (Map<String, Object>)bodyList_expectList.get(i);
            List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
            Map<String, Object> cell_actaul = (Map<String, Object>)bodyList_actualList.get(i);
            List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

            for(Integer j=0; j<cellList_actaul.size(); j++) {
                Map<String, Object> expect = (Map<String, Object>)cellList_expect.get(j);
                Map<String, Object> actaul = (Map<String, Object>)cellList_actaul.get(j);

                if(actaul.get('value') instanceof Map<string,object>) {
                    Assert.areEqual(expect.get('colSpanCnt'), actaul.get('colSpanCnt'));
                    Assert.areEqual(expect.get('isColSpan'), actaul.get('isColSpan'));
                    Assert.areEqual(expect.get('isRowSpan'), actaul.get('isRowSpan'));
                    Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));
                    Assert.areEqual(expect.get('isEdit'), actaul.get('isEdit'));

                    Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                    Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                    Assert.areEqual(expect_value.get('Price'), actaul_value.get('Price'));
                    Assert.areEqual(expect_value.get('isChecked'), actaul_value.get('isChecked'));
                    Assert.areEqual(expect_value.get('title'), actaul_value.get('title'));
                } else {
                    Assert.areEqual(expect, actaul);
                }
            }
        }
    }

    @IsTest
    private static void getDetailsInputForExtraHighInfoCase2Test() {

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];

        Boolean isInit = true;
        String deviceId = device.Id;
        String screenType = '2';
        String searchCondition1 = '1';
        String searchCondition2 = '0';
        String searchCondition3 = '0';
        String searchCondition4 = '0';
        String searchCondition5 = '0';

        Test.startTest();
        String res_actaul = DetailsInputForExtraHighController.getDetailsInputForExtraHighInfo(
            isInit,
            deviceId,
            screenType,
            searchCondition1,
            searchCondition2,
            searchCondition3,
            searchCondition4,
            searchCondition5
        );
        Test.stopTest();
        Map<String, Object> res_actaulMap = (Map<String, Object>)JSON.deserializeUntyped(res_actaul);

        System.debug('================Case2=================');

        String errorMsg = '';
        Boolean isNoData = true;

        String inputedId = null;
        String displayCondition = null;
        Decimal displayTotal = null;

        String displayLabel = null;
    
        List<Object> headerList = null;
        List<Object> bodyList = null;

        Assert.areEqual(errorMsg, res_actaulMap.get('errorMsg'));
        Assert.areEqual(isNoData, res_actaulMap.get('isNoData'));
        Assert.areEqual(inputedId, res_actaulMap.get('inputedId'));
        Assert.areEqual(displayCondition, res_actaulMap.get('displayCondition'));
        Assert.areEqual(displayTotal, res_actaulMap.get('displayTotal'));

        Assert.areEqual(displayLabel, res_actaulMap.get('displayLabel'));
        Assert.areEqual(headerList, res_actaulMap.get('headerList'));
        Assert.areEqual(bodyList, res_actaulMap.get('bodyList'));

        Assert.areEqual('2', res_actaulMap.get('screenType'));
        Assert.areEqual('1', res_actaulMap.get('searchCondition1'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition2'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition3'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition4'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition5'));

        
    }

    @IsTest
    private static void getDetailsInputForExtraHighInfoCase3Test() {

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];

        Boolean isInit = true;
        String deviceId = device.Id;
        String screenType = '3';
        String searchCondition1 = '1';
        String searchCondition2 = '0';
        String searchCondition3 = '0';
        String searchCondition4 = '0';
        String searchCondition5 = '0';

        Test.startTest();
        String res_actaul = DetailsInputForExtraHighController.getDetailsInputForExtraHighInfo(
            isInit,
            deviceId,
            screenType,
            searchCondition1,
            searchCondition2,
            searchCondition3,
            searchCondition4,
            searchCondition5
        );
        Test.stopTest();
        Map<String, Object> res_actaulMap = (Map<String, Object>)JSON.deserializeUntyped(res_actaul);

        System.debug('================Case3=================');

        String errorMsg = '';
        Boolean isNoData = false;

        String inputedId = null;
        String displayCondition = null;
        Decimal displayTotal = null;

        String displayLabel = '特高TRガス 屋内 GIS直結なし 電圧仕様標準 OLTCなし スポットネットワークなし';
        
        Assert.areEqual(errorMsg, res_actaulMap.get('errorMsg'));
        Assert.areEqual(isNoData, res_actaulMap.get('isNoData'));
        Assert.areEqual(inputedId, res_actaulMap.get('inputedId'));
        Assert.areEqual(displayCondition, res_actaulMap.get('displayCondition'));
        Assert.areEqual(displayTotal, res_actaulMap.get('displayTotal'));

        Assert.areEqual(displayLabel, res_actaulMap.get('displayLabel'));
    
        Assert.areEqual('3', res_actaulMap.get('screenType'));
        Assert.areEqual('1', res_actaulMap.get('searchCondition1'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition2'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition3'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition4'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition5'));

        //Check [headerList]
        List<Object> headerList_expectList = new List<Object>{
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>4, 'value'=>'容量'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'一次電圧'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'22,000V'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'二次電圧'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'6,600V'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'相数'},
                    new Map<String, Object>{'colSpanCnt'=>3, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'三相'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'周波数'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'50Hz'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'GIS直結'}
                }
            }
        };

        List<Object> headerList_actualList = (List<Object>)res_actaulMap.get('headerList');
        for(Integer i=0; i<headerList_actualList.size(); i++) {
            Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
            List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
            Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
            List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

            for(Integer j=0; j<cellList_actaul.size(); j++) {
                Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
            }
        }

        // Check [bodyList]
        List<Object> bodyList_expectList = new List<Object>{
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1,000kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'9,800,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>9800000, 'title'=>'ガス 屋内 三相 22,000V 6,600V 1,000kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TRガス"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'0'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1,200kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'11,100,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>11100000, 'title'=>'ガス 屋内 三相 22,000V 6,600V 1,200kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TRガス"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'0'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1,250kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'13,200,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>13200000, 'title'=>'ガス 屋内 三相 22,000V 6,600V 1,250kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TRガス"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'0'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1,500kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'16,100,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>16100000, 'title'=>'ガス 屋内 三相 22,000V 6,600V 1,500kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TRガス"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'0'}
                }
            },
            new Map<String, List<Object>>{
                'cellList'=>new List<Object>{
                    new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'2,000kVA'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'20,100,000'},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'id'=>'', 'isChecked'=>false, 'price'=>20100000, 'title'=>'ガス 屋内 三相 22,000V 6,600V 2,000kVA@@{"スポットネットワーク":"なし","OLTC":"なし","電圧仕様":"標準","GIS直結":"なし","設置場所":"屋内","screenType":"特高TRガス"}'}},
                    new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'0'}
                }
            }
        };           

        List<Object> bodyList_actualList = (List<Object>)res_actaulMap.get('bodyList');
        for(Integer i=0; i<bodyList_actualList.size(); i++) {
            Map<String, Object> cell_expect = (Map<String, Object>)bodyList_expectList.get(i);
            List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
            Map<String, Object> cell_actaul = (Map<String, Object>)bodyList_actualList.get(i);
            List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

            for(Integer j=0; j<cellList_actaul.size(); j++) {
                Map<String, Object> expect = (Map<String, Object>)cellList_expect.get(j);
                Map<String, Object> actaul = (Map<String, Object>)cellList_actaul.get(j);

                if(actaul.get('value') instanceof Map<string,object>) {
                    Assert.areEqual(expect.get('colSpanCnt'), actaul.get('colSpanCnt'));
                    Assert.areEqual(expect.get('isColSpan'), actaul.get('isColSpan'));
                    Assert.areEqual(expect.get('isRowSpan'), actaul.get('isRowSpan'));
                    Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));
                    Assert.areEqual(expect.get('isEdit'), actaul.get('isEdit'));

                    Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                    Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                    Assert.areEqual(expect_value.get('Price'), actaul_value.get('Price'));
                    Assert.areEqual(expect_value.get('isChecked'), actaul_value.get('isChecked'));
                    Assert.areEqual(expect_value.get('title'), actaul_value.get('title'));
                } else {
                    Assert.areEqual(expect, actaul);
                }
            }
        }
    }

    @IsTest
    private static void getDetailsInputForExtraHighInfoCase4Test() {

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];

        Boolean isInit = true;
        String deviceId = device.Id;
        String screenType = '1';
        String searchCondition1 = '1';
        String searchCondition2 = '2';
        String searchCondition3 = '0';
        String searchCondition4 = '0';
        String searchCondition5 = '0';

        Test.startTest();
        String res_actaul = DetailsInputForExtraHighController.getDetailsInputForExtraHighInfo(
            isInit,
            deviceId,
            screenType,
            searchCondition1,
            searchCondition2,
            searchCondition3,
            searchCondition4,
            searchCondition5
        );
        Test.stopTest();
        Map<String, Object> res_actaulMap = (Map<String, Object>)JSON.deserializeUntyped(res_actaul);

        System.debug('================Case4=================');

        String errorMsg = '';
        Boolean isNoData = true;

        String inputedId = null;
        String displayCondition = null;
        Decimal displayTotal = null;

        String displayLabel = null;
        
        List<Object> headerList = null;
        List<Object> bodyList = null;

    
        Assert.areEqual(errorMsg, res_actaulMap.get('errorMsg'));
        Assert.areEqual(isNoData, res_actaulMap.get('isNoData'));
        Assert.areEqual(inputedId, res_actaulMap.get('inputedId'));
        Assert.areEqual(displayCondition, res_actaulMap.get('displayCondition'));
        Assert.areEqual(displayTotal, res_actaulMap.get('displayTotal'));

        Assert.areEqual(displayLabel, res_actaulMap.get('displayLabel'));
        Assert.areEqual(headerList, res_actaulMap.get('headerList'));
        Assert.areEqual(bodyList, res_actaulMap.get('bodyList'));

        Assert.areEqual('1', res_actaulMap.get('screenType'));
        Assert.areEqual('1', res_actaulMap.get('searchCondition1'));
        Assert.areEqual('2', res_actaulMap.get('searchCondition2'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition3'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition4'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition5'));
    }

    @IsTest
    private static void getDetailsInputForExtraHighInfoCase5Test() {

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 2' LIMIT 1];
        PricingTable__c pricingTable = [SELECT Id, Name, RECNo__c,
                                                    MajorClassificationCode__c, 
                                                    MajorClassificationName__c, 
                                                    MinorClassificationCode__c, 
                                                    MinorClassificationName__c, 
                                                    CategoryCode__c,CategoryName__c,
                                                    Name1__c, Name2__c,Name3__c,Name4__c,Name5__c, Name6__c, Name7__c, Name8__c, Name9__c, Name10__c, 
                                                    BU__c, WC__c, Price__c, UniqueKey__c,ConditionForSearchformula__c,
                                                    Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                                                    Note__c
                                                FROM PricingTable__c
                                                WHERE UniqueKey__c='筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相22,000V6,600V1,000kVA特高TR油入'
                                                LIMIT 1
                                            ];

        Boolean isInit = true;
        String deviceId = device.Id;
        String screenType = '1';
        String searchCondition1 = '2';
        String searchCondition2 = '2';
        String searchCondition3 = '1';
        String searchCondition4 = '1';
        String searchCondition5 = '1';

        Test.startTest();
        String res_actaul = DetailsInputForExtraHighController.getDetailsInputForExtraHighInfo(
            isInit,
            deviceId,
            screenType,
            searchCondition1,
            searchCondition2,
            searchCondition3,
            searchCondition4,
            searchCondition5
        );
        Test.stopTest();
        Map<String, Object> res_actaulMap = (Map<String, Object>)JSON.deserializeUntyped(res_actaul);

        System.debug('================Case5=================');
        
        String errorMsg = '';
        Boolean isNoData = true;

        String inputedId = pricingTable.Id;
        String displayCondition = '油 スポットネットワーク 屋外 三相 22,000V 6,600V 1,000kVA';
        Decimal displayTotal = 36100000;

        String displayLabel = null;
        
        List<Object> headerList = null;
        List<Object> bodyList = null;

    
        Assert.areEqual(errorMsg, res_actaulMap.get('errorMsg'));
        Assert.areEqual(isNoData, res_actaulMap.get('isNoData'));
        Assert.areEqual(inputedId, res_actaulMap.get('inputedId'));
        Assert.areEqual(displayCondition, res_actaulMap.get('displayCondition'));
        Assert.areEqual(displayTotal, res_actaulMap.get('displayTotal'));

        Assert.areEqual(displayLabel, res_actaulMap.get('displayLabel'));
        Assert.areEqual(headerList, res_actaulMap.get('headerList'));
        Assert.areEqual(bodyList, res_actaulMap.get('bodyList'));

        Assert.areEqual('1', res_actaulMap.get('screenType'));
        Assert.areEqual('2', res_actaulMap.get('searchCondition1'));
        Assert.areEqual('0', res_actaulMap.get('searchCondition2'));
        Assert.areEqual('1', res_actaulMap.get('searchCondition3'));
        Assert.areEqual('1', res_actaulMap.get('searchCondition4'));
        Assert.areEqual('1', res_actaulMap.get('searchCondition5'));
    }

    @IsTest
    private static void submitDetailsForExtraHighSuccessTest() {

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 2' LIMIT 1];
        PricingTable__c pricingTable = [SELECT Id, Name, RECNo__c,
                                                    MajorClassificationCode__c, 
                                                    MajorClassificationName__c, 
                                                    MinorClassificationCode__c, 
                                                    MinorClassificationName__c, 
                                                    CategoryCode__c,CategoryName__c,
                                                    Name1__c, Name2__c,Name3__c,Name4__c,Name5__c, Name6__c, Name7__c, Name8__c, Name9__c, Name10__c, 
                                                    BU__c, WC__c, Price__c, UniqueKey__c,ConditionForSearchformula__c,
                                                    Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                                                    Note__c
                                                FROM PricingTable__c
                                                WHERE UniqueKey__c='筐体S変圧器特高変圧器60Hz油屋内三相22,000V6,600V1,200kVA特高TR油入'
                                                LIMIT 1
                                            ];
        String deviceId = device.Id;
        String rId = pricingTable.Id;
        String cnt = '1';
        String title = '{"スポットネットワーク":"あり","OLTC":"あり","電圧仕様":"6,600V","GIS直結":"あり","設置場所":"屋外","screenType":"特高TR 油入"}';

        Test.startTest();
        String res_actaul = DetailsInputForExtraHighController.submitDetailsForExtraHigh(
            deviceId,
            rId,
            cnt,
            title
        );
        Test.stopTest();

        System.debug('================すべての明細　Delete=================');
        List<String> oldDetailList = new List<String>{
            '筐体S変圧器特高変圧器60Hz油 スポットネットワーク屋外三相22,000V6,600V1,000kVA特高TR油入',
            '明細S変圧器特高変圧器油GIS直結1,000kVA',
            '明細S変圧器特高変圧器油OLTC付'
        };
        List<Detail__c> oldDetails = [SELECT Id FROM Detail__c WHERE PricingTableUniqueKey__c IN:oldDetailList];
        Assert.areEqual(0, oldDetails.size());


        List<Detail__c> details = [SELECT Id
                                        ,Device__c
                                        ,Name
                                        ,Name1__c
                                        ,Name2__c
                                        ,Name3__c
                                        ,Name4__c
                                        ,PricingTableUniqueKey__c
                                        ,CreditWC__c
                                        ,UnitPrice__c
                                        ,CreditWeight__c
                                        ,DetailCategory__c
                                        ,Quantity__c
                                        ,WcCalculationRate__c
                                        ,Note__c
                                        ,Name5__c
                                        ,Name6__c
                                        ,Name7__c
                                        ,Name8__c
                                        ,Name9__c
                                        ,Name10__c
                                        ,detailedStatementText__c
                                        ,SpecialSpecificationNo__c
                                        ,MajorClassificationName__c
                                        ,MajorClassificationCode__c
                                        ,MinorClassificationName__c
                                        ,MinorClassificationCode__c
                                        ,CategoryName__c
                                        ,CategoryCode__c
                                    FROM Detail__c
                                    WHERE Device__c =:deviceId];
        
        Map<String, String> searchConditionMap = (Map<String, String>)JSON.deserialize(title, Map<String, String>.class);
        for(Detail__c detail : details) {
            if(detail.DetailCategory__c=='筐体') {
                System.debug('================筐体=================');
                Assert.areEqual(deviceId, detail.Device__c);
                Assert.areEqual(pricingTable.DisplayName__c, detail.Name);
                Assert.areEqual(pricingTable.Name1__c, detail.Name1__c);
                Assert.areEqual(pricingTable.Name2__c, detail.Name2__c);
                Assert.areEqual(pricingTable.Name3__c, detail.Name3__c);
                Assert.areEqual(pricingTable.Name4__c, detail.Name4__c);
                Assert.areEqual(pricingTable.UniqueKey__c, detail.PricingTableUniqueKey__c);
                Assert.areEqual(pricingTable.WC__c, detail.CreditWC__c);
                Assert.areEqual(pricingTable.Price__c, detail.UnitPrice__c);
                Assert.areEqual(pricingTable.Weight__c, detail.CreditWeight__c);
                Assert.areEqual('筐体', detail.DetailCategory__c);
                Assert.areEqual(1, detail.Quantity__c);
                Assert.areEqual(0, detail.WcCalculationRate__c);
                Assert.areEqual(pricingTable.Note__c, detail.Note__c);
                Assert.areEqual(pricingTable.Name5__c, detail.Name5__c);
                Assert.areEqual(pricingTable.Name6__c, detail.Name6__c);
                Assert.areEqual(pricingTable.Name7__c, detail.Name7__c);
                Assert.areEqual(pricingTable.Name8__c, detail.Name8__c);
                Assert.areEqual(pricingTable.Name9__c, detail.Name9__c);
                Assert.areEqual(pricingTable.Name10__c, detail.Name10__c);
                Assert.areEqual(pricingTable.detailedStatementText__c, detail.detailedStatementText__c);
                Assert.areEqual(pricingTable.SpecialSpecificationNo__c, detail.SpecialSpecificationNo__c);
                Assert.areEqual(pricingTable.MajorClassificationName__c, detail.MajorClassificationName__c);
                Assert.areEqual(pricingTable.MajorClassificationCode__c, detail.MajorClassificationCode__c);
                Assert.areEqual(pricingTable.MinorClassificationName__c, detail.MinorClassificationName__c);
                Assert.areEqual(pricingTable.MinorClassificationCode__c, detail.MinorClassificationCode__c);
                Assert.areEqual(pricingTable.CategoryName__c, detail.CategoryName__c);
                Assert.areEqual(pricingTable.CategoryCode__c, detail.CategoryCode__c);
            } else if(detail.Name2__c=='GIS直結') {
                System.debug('================GIS直結=================');
                PricingTable__c pricingTableGIS = [SELECT Id, Name, RECNo__c,
                                                                MajorClassificationCode__c, 
                                                                MajorClassificationName__c, 
                                                                MinorClassificationCode__c, 
                                                                MinorClassificationName__c, 
                                                                CategoryCode__c,CategoryName__c,
                                                                Name1__c, Name2__c,Name3__c,Name4__c,Name5__c, Name6__c, Name7__c, Name8__c, Name9__c, Name10__c, 
                                                                WC__c, WcCalculationRate__c, Price__c, UniqueKey__c,
                                                                Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                                                                Note__c
                                                            FROM PricingTable__c
                                                            WHERE
                                                                RecordType.DeveloperName = :'Detail' AND
                                                                MajorClassificationName__c = :pricingTable.MajorClassificationName__c AND 
                                                                MinorClassificationName__c = :pricingTable.MinorClassificationName__c AND 
                                                                BU__c = :pricingTable.BU__c AND 
                                                                CategoryCode__c = '00' AND 
                                                                Name1__c =:'油' AND
                                                                Name2__c =:'GIS直結' AND
                                                                Name3__c =:pricingTable.Name6__c
                                                            LIMIT 1];

                                                            Assert.areEqual(deviceId, detail.Device__c);
                                                            Assert.areEqual(pricingTableGIS.DisplayName__c, detail.Name);
                                                            Assert.areEqual(pricingTableGIS.Name1__c, detail.Name1__c);
                                                            Assert.areEqual(pricingTableGIS.Name2__c, detail.Name2__c);
                                                            Assert.areEqual(pricingTableGIS.Name3__c, detail.Name3__c);
                                                            Assert.areEqual(pricingTableGIS.Name4__c, detail.Name4__c);
                                                            Assert.areEqual(pricingTableGIS.UniqueKey__c, detail.pricingTableUniqueKey__c);
                                                            Assert.areEqual(pricingTableGIS.WC__c, detail.CreditWC__c);
                                                            Assert.areEqual(pricingTableGIS.Price__c, detail.UnitPrice__c);
                                                            Assert.areEqual(pricingTableGIS.Weight__c, detail.CreditWeight__c);
                                                            Assert.areEqual('明細', detail.DetailCategory__c);
                                                            Assert.areEqual(1, detail.Quantity__c);
                                                            Assert.areEqual(pricingTableGIS.WcCalculationRate__c, detail.WcCalculationRate__c);
                                                            Assert.areEqual(pricingTableGIS.Note__c, detail.Note__c);
                                                            Assert.areEqual(pricingTableGIS.Name5__c, detail.Name5__c);
                                                            Assert.areEqual(pricingTableGIS.Name6__c, detail.Name6__c);
                                                            Assert.areEqual(pricingTableGIS.Name7__c, detail.Name7__c);
                                                            Assert.areEqual(pricingTableGIS.Name8__c, detail.Name8__c);
                                                            Assert.areEqual(pricingTableGIS.Name9__c, detail.Name9__c);
                                                            Assert.areEqual(pricingTableGIS.Name10__c, detail.Name10__c);
                                                            Assert.areEqual(pricingTableGIS.detailedStatementText__c, detail.detailedStatementText__c);
                                                            Assert.areEqual(pricingTableGIS.SpecialSpecificationNo__c, detail.SpecialSpecificationNo__c);
                                                            Assert.areEqual(pricingTableGIS.MajorClassificationName__c, detail.MajorClassificationName__c);
                                                            Assert.areEqual(pricingTableGIS.MajorClassificationCode__c, detail.MajorClassificationCode__c);
                                                            Assert.areEqual(pricingTableGIS.MinorClassificationName__c, detail.MinorClassificationName__c);
                                                            Assert.areEqual(pricingTableGIS.MinorClassificationCode__c, detail.MinorClassificationCode__c);
                                                            Assert.areEqual(pricingTableGIS.CategoryName__c, detail.CategoryName__c);
                                                            Assert.areEqual(pricingTableGIS.CategoryCode__c, detail.CategoryCode__c);
            } else if(detail.Name2__c=='OLTC付') {
                System.debug('================OLTC付=================');
                PricingTable__c pricingTableOLTC = [SELECT Id, Name, RECNo__c,
                                                                MajorClassificationCode__c, 
                                                                MajorClassificationName__c, 
                                                                MinorClassificationCode__c, 
                                                                MinorClassificationName__c, 
                                                                CategoryCode__c,CategoryName__c,
                                                                Name1__c, Name2__c,Name3__c,Name4__c,Name5__c, Name6__c, Name7__c, Name8__c, Name9__c, Name10__c, 
                                                                WC__c, WcCalculationRate__c, Price__c, UniqueKey__c,
                                                                Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                                                                Note__c
                                                            FROM PricingTable__c
                                                            WHERE
                                                                RecordType.DeveloperName = :'Detail' AND
                                                                MajorClassificationName__c = :pricingTable.MajorClassificationName__c AND 
                                                                MinorClassificationName__c = :pricingTable.MinorClassificationName__c AND 
                                                                BU__c = :pricingTable.BU__c AND 
                                                                CategoryCode__c = :'00' AND 
                                                                Name1__c =:'油' AND
                                                                Name2__c =:'OLTC付'
                                                            LIMIT 1];

                                                            Assert.areEqual(deviceId, detail.Device__c);
                                                            Assert.areEqual(pricingTableOLTC.DisplayName__c, detail.Name);
                                                            Assert.areEqual(pricingTableOLTC.Name1__c, detail.Name1__c);
                                                            Assert.areEqual(pricingTableOLTC.Name2__c, detail.Name2__c);
                                                            Assert.areEqual(pricingTableOLTC.Name3__c, detail.Name3__c);
                                                            Assert.areEqual(pricingTableOLTC.Name4__c, detail.Name4__c);
                                                            Assert.areEqual(pricingTableOLTC.UniqueKey__c, detail.pricingTableUniqueKey__c);
                                                            Assert.areEqual(pricingTableOLTC.WC__c, detail.CreditWC__c);
                                                            Assert.areEqual(pricingTableOLTC.Price__c, detail.UnitPrice__c);
                                                            Assert.areEqual(pricingTableOLTC.Weight__c, detail.CreditWeight__c);
                                                            Assert.areEqual('明細', detail.DetailCategory__c);
                                                            Assert.areEqual(1, detail.Quantity__c);
                                                            Assert.areEqual(pricingTableOLTC.WcCalculationRate__c, detail.WcCalculationRate__c);
                                                            Assert.areEqual(pricingTableOLTC.Note__c, detail.Note__c);
                                                            Assert.areEqual(pricingTableOLTC.Name5__c, detail.Name5__c);
                                                            Assert.areEqual(pricingTableOLTC.Name6__c, detail.Name6__c);
                                                            Assert.areEqual(pricingTableOLTC.Name7__c, detail.Name7__c);
                                                            Assert.areEqual(pricingTableOLTC.Name8__c, detail.Name8__c);
                                                            Assert.areEqual(pricingTableOLTC.Name9__c, detail.Name9__c);
                                                            Assert.areEqual(pricingTableOLTC.Name10__c, detail.Name10__c);
                                                            Assert.areEqual(pricingTableOLTC.detailedStatementText__c, detail.detailedStatementText__c);
                                                            Assert.areEqual(pricingTableOLTC.SpecialSpecificationNo__c, detail.SpecialSpecificationNo__c);
                                                            Assert.areEqual(pricingTableOLTC.MajorClassificationName__c, detail.MajorClassificationName__c);
                                                            Assert.areEqual(pricingTableOLTC.MajorClassificationCode__c, detail.MajorClassificationCode__c);
                                                            Assert.areEqual(pricingTableOLTC.MinorClassificationName__c, detail.MinorClassificationName__c);
                                                            Assert.areEqual(pricingTableOLTC.MinorClassificationCode__c, detail.MinorClassificationCode__c);
                                                            Assert.areEqual(pricingTableOLTC.CategoryName__c, detail.CategoryName__c);
                                                            Assert.areEqual(pricingTableOLTC.CategoryCode__c, detail.CategoryCode__c);
            }
        }
        

        System.debug(res_actaul);
        //Assert.areEqual(res_expect, res_actaul);
    }

    @IsTest
    private static void submitDetailsForExtraHighErrorTest() {

        String deviceId = 'XXXXXXXXXXXXXXXXXXXXXXXX';
        String rId = 'XXXXXXXXXXXXXXXXXXXXXXXX';
        String cnt = 'XXXXXXXXXXXXXXXXXXXXXXXX';
        String title = 'XXXXXXXXXXXXXXXXXXXXXXXX';

        Test.startTest();
        String res_actaul = DetailsInputForExtraHighController.submitDetailsForExtraHigh(
            deviceId,
            rId,
            cnt,
            title
        );
        Test.stopTest();

        String res_expect = 'Error';
        Assert.areEqual(res_expect, res_actaul);
    }
}