@IsTest
private class LedgerSheetOutputGeneratorTest {

    @TestSetup
    static void createTestData(){
        
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
            MajorClassification__c='特高',
            MinorClassification__c='特高監視盤',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        insert device1;

        // 水環境
        RecordType deviceWaterRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='水環境' AND SobjectType='Device__c' LIMIT 1];
        Device__c device2 = new Device__c(
            Quote__c=quote2.Id,
            Name='Test Device Name 2',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567891',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='水環境', // {施設, 水環境, 官需}
            MajorClassification__c='低圧・現場・リレー・ACB盤',
            MinorClassification__c='低圧盤',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceWaterRecordType.Id
        );
        insert device2;

        Device__c device3 = new Device__c(
            Quote__c=quote3.Id,
            Name='Test Device Name 3',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567892',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='水環境', // {施設, 水環境, 官需}
            MajorClassification__c='コントロールセンタ(C/C)',
            MinorClassification__c='400V',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceWaterRecordType.Id
        );
        insert device3;
        
        // 官需
        RecordType devicePDemandRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='官需' AND SobjectType='Device__c' LIMIT 1];
        Device__c device4 = new Device__c(
            Quote__c=quote4.Id,
            Name='Test Device Name 4',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567894',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='官需', // {施設, 水環境, 官需}
            MajorClassification__c='無線装置（テレメータ･テレコントロール用）',
            MinorClassification__c='70MHz帯無線装置(テレメータ･テレコントロール用)',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=devicePDemandRecordType.Id
        );
        insert device4;

        List<Detail__c> details = new List<Detail__c>();
        // 筐体
        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Detail Name 1',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='04',
            MinorClassificationName__c='特高監視盤',
            CategoryCode__c='',
            CategoryName__c='',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='Test Detail Name 1',
            Name2__c='Test Detail Name 2',
            Name3__c='Test Detail Name 3',
            Name4__c='Test Detail Name 4',
            Name5__c='Test Detail Name 5',
            Name6__c='Test Detail Name 6',
            Name7__c='Test Detail Name 7',
            Name8__c='Test Detail Name 8',
            Name9__c='Test Detail Name 9',
            PricingTableUniqueKey__c='Test Unique Key',
            Order__c='Test Order',
            DetailCategory__c='筐体', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        //  明細
        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Detail Name 2',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='04',
            MinorClassificationName__c='特高監視盤',
            CategoryCode__c='',
            CategoryName__c='',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='Test Detail Name 1',
            Name2__c='Test Detail Name 2',
            Name3__c='Test Detail Name 3',
            Name4__c='Test Detail Name 4',
            Name5__c='Test Detail Name 5',
            Name6__c='Test Detail Name 6',
            Name7__c='Test Detail Name 7',
            Name8__c='Test Detail Name 8',
            Name9__c='Test Detail Name 9',
            PricingTableUniqueKey__c='Test Unique Key',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        // 筐体
        details.add(new Detail__c(
            Device__c=device2.Id,
            PricingTable__c=null,
            Name='Test Detail Name 3',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='05',
            MajorClassificationName__c='低圧・現場・リレー・ACB盤',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='低圧盤',
            CategoryCode__c='01',
            CategoryName__c='筐体',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='Test Detail Name 1',
            Name2__c='Test Detail Name 2',
            Name3__c='Test Detail Name 3',
            Name4__c='Test Detail Name 4',
            Name5__c='Test Detail Name 5',
            Name6__c='Test Detail Name 6',
            Name7__c='Test Detail Name 7',
            Name8__c='Test Detail Name 8',
            Name9__c='Test Detail Name 9',
            PricingTableUniqueKey__c='Test Unique Key',
            Order__c='Test Order',
            DetailCategory__c='筐体', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        //  明細
        details.add(new Detail__c(
            Device__c=device2.Id,
            PricingTable__c=null,
            Name='Test Detail Name 4',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='05',
            MajorClassificationName__c='低圧・現場・リレー・ACB盤',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='低圧盤',
            CategoryCode__c='01',
            CategoryName__c='筐体',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='Test Detail Name 1',
            Name2__c='Test Detail Name 2',
            Name3__c='Test Detail Name 3',
            Name4__c='Test Detail Name 4',
            Name5__c='Test Detail Name 5',
            Name6__c='Test Detail Name 6',
            Name7__c='Test Detail Name 7',
            Name8__c='Test Detail Name 8',
            Name9__c='Test Detail Name 9',
            PricingTableUniqueKey__c='Test Unique Key',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        //  明細
        details.add(new Detail__c(
            Device__c=device4.Id,
            PricingTable__c=null,
            Name='Test Detail Name 5',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='41',
            MajorClassificationName__c='無線装置（テレメータ･テレコントロール用）',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='70MHz帯無線装置(テレメータ･テレコントロール用)',
            CategoryCode__c='',
            CategoryName__c='',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='Test Detail Name 1',
            Name2__c='Test Detail Name 2',
            Name3__c='Test Detail Name 3',
            Name4__c='Test Detail Name 4',
            Name5__c='Test Detail Name 5',
            Name6__c='Test Detail Name 6',
            Name7__c='Test Detail Name 7',
            Name8__c='Test Detail Name 8',
            Name9__c='Test Detail Name 9',
            PricingTableUniqueKey__c='Test Unique Key',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=null,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        insert details;
    }

    @IsTest
    private static void generatePrintDataFacilityTest() {
        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567890' LIMIT 1];

        LedgerSheetOutputGenerator ledger = new LedgerSheetOutputGenerator();
        String ledgerRes = ledger.generatePrintData(quote.Id);

        List<String> ledgerList = ledgerRes.split('\r\n');
System.debug(ledgerList[4]);
        ledgerList[4] = ledgerList[4].substring(0, 10) + 'X-XXXXXXXX-XXXXXX' + ledgerList[4].substring(20, ledgerList[4].length());
System.debug(ledgerList[4]);
        Assert.areEqual('<start>', ledgerList[0]);
        Assert.areEqual('VrSetForm=form/社環CRM/見積書類/[ExportFormat_施設.xlsm]データシート', ledgerList[1]);
        Assert.areEqual('<end>', ledgerList[2]);
        Assert.areEqual('"見積番号","客先名","件名","一般管理費","周波数","表示順","仕様書番号","明細種類","明細並び順","一般管理費有無","大分類","小分類","機器数量","機器単位","機器単位WC","機器単位見積金額","機器単代理店提供","機器備考","品名１","品名２","品名３","数量","単価","価格係数","備考","WC単価","代理店提供価格","係数"', ledgerList[3]);
        Assert.areEqual('"見積番号  第  X-XXXXXXXX-XXXXXX  号","Test Account Name","Test Quote Subject 1","0.23","周波数　50Hz","","","","","","","","","","","","","","","","","","","","","","",""', ledgerList[4]);
        Assert.areEqual('"","","","","","1","1234567890","01","1","N","特高","特高監視盤","1","piece","","","","Test Device Note","Test Device Name 1","","","","","0.00","","","",""', ledgerList[5]);
        //Assert.areEqual('"","","","","","1","1234567890","01","2","","","","","","","","","","　電圧 特高監視盤","","","","","","","","",""', ledgerList[6]);
        Assert.areEqual('"","","","","","1","1234567890","01","2","","","","","","","","","","Test Detail Name 1","Test Detail Name 2","Test Detail Name 3","1.00","0","","Test Detail Note","0","0","0.00"', ledgerList[6]);
        Assert.areEqual('"","","","","","1","1234567890","02","1","","","","","","","","","","Test Detail Name 1","Test Detail Name 2","Test Detail Name 3","1.00","0","","Test Detail Note","0","0","0.00"', ledgerList[7]);
        Assert.areEqual('"","","","","","1","1234567890","03","1","","","","","","","","","","1.00 ✕ Test Detail Statement","","","","","","","","",""', ledgerList[8]);
        Assert.areEqual('"","","","","","1","1234567890","03","2","","","","","","","","","","1.00 ✕ Test Detail Statement","","","","","","","","",""', ledgerList[9]);
        Assert.areEqual('"","","","","","1","1234567890","04","1","","","","","","","","","","積算金額、WC金額合計","","","","","","","","",""', ledgerList[10]);
        Assert.areEqual('"","","","","","1","1234567890","04","2","","","","","","","","","","積算金額×価格係数","","","","","","","","",""', ledgerList[11]);
        Assert.areEqual('"","","","","","1","1234567890","04","3","","","","","","","","","","諸経費 23%","","","","","","","","",""', ledgerList[12]);
        Assert.areEqual('"","","","","","1","1234567890","04","4","","","","","","","","","","見積金額","","","","","","","","",""', ledgerList[13]);
        Assert.areEqual('"","","","","","1","1234567890","04","5","","","","","","","","","","客先回答金額","","","","","","","","",""', ledgerList[14]);

        String fileName = ledger.getFileName();
        Datetime todayDate = Datetime.now();
        String todayDateStr = todayDate.format('yyyyMMddHHmm');
        String expectFileName = '1234567890_' + 'TestQuoteOutputSheetName' + '_' + todayDateStr;
        String actualFileName = fileName.substring(0, 48);
        Assert.areEqual(expectFileName, actualFileName);
    }

    @IsTest
    private static void generatePrintDataWaterTest() {
        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567891' LIMIT 1];

        LedgerSheetOutputGenerator ledger = new LedgerSheetOutputGenerator();
        String ledgerRes = ledger.generatePrintData(quote.Id);

        List<String> ledgerList = ledgerRes.split('\r\n');
        ledgerList[4] = ledgerList[4].substring(0, 10) + 'X-XXXXXXXX-XXXXXX' + ledgerList[4].substring(20, ledgerList[4].length());

        Assert.areEqual('<start>', ledgerList[0]);
        Assert.areEqual('VrSetForm=form/社環CRM/見積書類/[ExportFormat_水環境.xlsm]データシート', ledgerList[1]);
        Assert.areEqual('<end>', ledgerList[2]);
        Assert.areEqual('"見積番号","客先名","件名","諸経費","周波数","表示順","仕様書番号","明細種類","明細並び順","機器管理対象","一般管理費有無","大分類","小分類","機器数量","機器単位","機器単位WC","機器単位見積金額","機器単位重量","機器備考","品名１","品名２","品名３","数量","単価","価格係数","備考","WC単価","単位重量","係数"', ledgerList[3]);
        Assert.areEqual('"見積番号  第  X-XXXXXXXX-XXXXXX  号","Test Account Name","Test Quote Subject 2","0.25","周波数　60Hz","","","","","","","","","","","","","","","","","","","","","","","",""', ledgerList[4]);
        Assert.areEqual('"","","","","","1","1234567891","01","1","N","N","低圧・現場・リレー・ACB盤","低圧盤","1","piece","","","0.0","Test Device Note","Test Device Name 2","","","","","0.00","","","",""', ledgerList[5]);
        Assert.areEqual('"","","","","","1","1234567891","01","2","","","","","","","","","","","Test Detail Name 1","Test Detail Name 2","Test Detail Name 3","1.00","0","","Test Detail Note","0","0.00","0.00"', ledgerList[6]);
        Assert.areEqual('"","","","","","1","1234567891","02","1","","","","","","","","","","","Test Detail Name 1","Test Detail Name 2","Test Detail Name 3","1.00","0","","Test Detail Note","0","0.00","0.00"', ledgerList[7]);
        Assert.areEqual('"","","","","","1","1234567891","03","1","","","","","","","","","","","積算金額、WC金額合計","","","","","","","","",""', ledgerList[8]);
        Assert.areEqual('"","","","","","1","1234567891","03","2","","","","","","","","","","","積算金額×価格係数","","","","","","","","",""', ledgerList[9]);
        Assert.areEqual('"","","","","","1","1234567891","03","3","","","","","","","","","","","一般管理費 25%","","","","","","","","",""', ledgerList[10]);
        Assert.areEqual('"","","","","","1","1234567891","03","4","","","","","","","","","","","見積金額","","","","","","","","",""', ledgerList[11]);
        Assert.areEqual('"","","","","","1","1234567891","03","5","","","","","","","","","","","客先回答金額","","","","","","","","",""', ledgerList[12]);

        String fileName = ledger.getFileName();
        Datetime todayDate = Datetime.now();
        String todayDateStr = todayDate.format('yyyyMMddHHmm');
        String expectFileName = '1234567891_' + 'TestQuoteOutputSheetName' + '_' + todayDateStr;
        String actualFileName = fileName.substring(0, 48);
        Assert.areEqual(expectFileName, actualFileName);
    }

    @IsTest
    private static void generatePrintDataNoDetailTest() {
        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567892' LIMIT 1];

        LedgerSheetOutputGenerator ledger = new LedgerSheetOutputGenerator();
        String ledgerRes = ledger.generatePrintData(quote.Id);

        List<String> ledgerList = ledgerRes.split('\r\n');
        ledgerList[4] = ledgerList[4].substring(0, 10) + 'X-XXXXXXXX-XXXXXX' + ledgerList[4].substring(20, ledgerList[4].length());

        Assert.areEqual('<start>', ledgerList[0]);
        Assert.areEqual('VrSetForm=form/社環CRM/見積書類/[ExportFormat_水環境.xlsm]データシート', ledgerList[1]);
        Assert.areEqual('<end>', ledgerList[2]);
        Assert.areEqual('"見積番号","客先名","件名","諸経費","周波数","表示順","仕様書番号","明細種類","明細並び順","機器管理対象","一般管理費有無","大分類","小分類","機器数量","機器単位","機器単位WC","機器単位見積金額","機器単位重量","機器備考","品名１","品名２","品名３","数量","単価","価格係数","備考","WC単価","単位重量","係数"', ledgerList[3]);
        Assert.areEqual('"見積番号  第  X-XXXXXXXX-XXXXXX  号","Test Account Name","Test Quote Subject 3","0.25","周波数　60Hz","","","","","","","","","","","","","","","","","","","","","","","",""', ledgerList[4]);
        Assert.areEqual('"","","","","","1","1234567892","01","1","N","N","コントロールセンタ(C/C)","400V","1","piece","","","0.0","Test Device Note","Test Device Name 3","","","","","0.00","","","",""', ledgerList[5]);
        //Assert.areEqual('"","","","","","1","1234567892","01","2","","","","","","","","","","","400V","","","","","","","","",""', ledgerList[6]);
        Assert.areEqual('"","","","","","1","1234567892","02","1","","","","","","","","","","","","","","","","","","","",""', ledgerList[6]);
        Assert.areEqual('"","","","","","1","1234567892","03","1","","","","","","","","","","","積算金額、WC金額合計","","","","","","","","",""', ledgerList[7]);
        Assert.areEqual('"","","","","","1","1234567892","03","2","","","","","","","","","","","積算金額×価格係数","","","","","","","","",""', ledgerList[8]);
        Assert.areEqual('"","","","","","1","1234567892","03","3","","","","","","","","","","","一般管理費 25%","","","","","","","","",""', ledgerList[9]);
        Assert.areEqual('"","","","","","1","1234567892","03","4","","","","","","","","","","","見積金額","","","","","","","","",""', ledgerList[10]);
        Assert.areEqual('"","","","","","1","1234567892","03","5","","","","","","","","","","","客先回答金額","","","","","","","","",""', ledgerList[11]);

        String fileName = ledger.getFileName();
        Datetime todayDate = Datetime.now();
        String todayDateStr = todayDate.format('yyyyMMddHHmm');
        String expectFileName = '1234567892_' + 'TestQuoteOutputSheetName' + '_' + todayDateStr;
        String actualFileName = fileName.substring(0, 48);
        Assert.areEqual(expectFileName, actualFileName);
    }

    @IsTest
    private static void generatePrintDataPDemandTest() {
        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567893' LIMIT 1];

        LedgerSheetOutputGenerator ledger = new LedgerSheetOutputGenerator();
        String ledgerRes = ledger.generatePrintData(quote.Id);

        List<String> ledgerList = ledgerRes.split('\r\n');
        ledgerList[4] = ledgerList[4].substring(0, 10) + 'X-XXXXXXXX-XXXXXX' + ledgerList[4].substring(20, ledgerList[4].length());

        Assert.areEqual('<start>', ledgerList[0]);
        Assert.areEqual('VrSetForm=form/社環CRM/見積書類/[ExportFormat_水環境.xlsm]データシート', ledgerList[1]);
        Assert.areEqual('<end>', ledgerList[2]);
        Assert.areEqual('"見積番号","客先名","件名","諸経費","周波数","表示順","仕様書番号","明細種類","明細並び順","機器管理対象","一般管理費有無","大分類","小分類","機器数量","機器単位","機器単位WC","機器単位見積金額","機器単位重量","機器備考","品名１","品名２","品名３","数量","単価","価格係数","備考","WC単価","単位重量","係数"', ledgerList[3]);
        Assert.areEqual('"見積番号  第  X-XXXXXXXX-XXXXXX  号","Test Account Name","Test Quote Subject 4","0.25","周波数　60Hz","","","","","","","","","","","","","","","","","","","","","","","",""', ledgerList[4]);
        Assert.areEqual('"","","","","","1","1234567894","01","1","N","N","無線装置(テレメータ･テレコントロール用)","70MHz帯無線装置(テレメータ･テレコントロール用)","1","piece","","","0.0","Test Device Note","Test Device Name 4","","","","","0.00","","","",""', ledgerList[5]);
        Assert.areEqual('"","","","","","1","1234567894","02","1","","","","","","","","","","","Test Detail Name 1","Test Detail Name 2","Test Detail Name 3","1.00","0","","Test Detail Note","0","0.00","0.00"', ledgerList[6]);
        Assert.areEqual('"","","","","","1","1234567894","03","1","","","","","","","","","","","積算金額、WC金額合計","","","","","","","","",""', ledgerList[7]);
        Assert.areEqual('"","","","","","1","1234567894","03","2","","","","","","","","","","","積算金額×価格係数","","","","","","","","",""', ledgerList[8]);
        Assert.areEqual('"","","","","","1","1234567894","03","3","","","","","","","","","","","一般管理費 25%","","","","","","","","",""', ledgerList[9]);
        Assert.areEqual('"","","","","","1","1234567894","03","4","","","","","","","","","","","見積金額","","","","","","","","",""', ledgerList[10]);
        Assert.areEqual('"","","","","","1","1234567894","03","5","","","","","","","","","","","客先回答金額","","","","","","","","",""', ledgerList[11]);

        String fileName = ledger.getFileName();
        Datetime todayDate = Datetime.now();
        String todayDateStr = todayDate.format('yyyyMMddHHmm');
        String expectFileName = '1234567893_' + 'TestQuoteOutputSheetName' + '_' + todayDateStr;
        String actualFileName = fileName.substring(0, 48);
        Assert.areEqual(expectFileName, actualFileName);
    }
}