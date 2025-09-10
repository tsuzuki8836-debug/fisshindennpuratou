@IsTest
private class LedgerSheetOutputBizLogicTest {

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
            MajorClassification__c='低圧・現場・ﾘﾚｰ・ACB盤',
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
            MajorClassification__c='ｺﾝﾄﾛｰﾙｾﾝﾀ（C/C)',
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
            MajorClassification__c='無線装置(テレメータ･テレコントロール用)[国交省本省宛て提出機器単体費]',
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
            MajorClassificationName__c='低圧・現場・ﾘﾚｰ・ACB盤',
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
            MajorClassificationName__c='低圧・現場・ﾘﾚｰ・ACB盤',
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
            MajorClassificationName__c='無線装置（ﾃﾚﾒｰﾀ･ﾃﾚｺﾝﾄﾛｰﾙ用）',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='70ＭＨｚ帯無線装置（ﾃﾚﾒｰﾀ･ﾃﾚｺﾝﾄﾛｰﾙ用）',
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
    private static void svfLedgerSheetPrintSuccessCaseTest() {

        String CLIENT_ID = System.Label.SVF_ClientId;
        String SECRET_KEY = System.Label.SVF_SecretKey;
        String PRIVATE_KEY = System.Label.SVF_PrivateKey1to1000 + System.Label.SVF_PrivateKey1001to2000;
        String URL_GET_TOKEN = System.Label.SVF_UrlGetToken;
        String URL_PRINT_DATA = System.Label.SVF_UrlPrintData;

        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567890' LIMIT 1];

        Test.startTest();
        LedgerSheetOutputBizLogic ledger = new LedgerSheetOutputBizLogic(CLIENT_ID, SECRET_KEY, PRIVATE_KEY, URL_GET_TOKEN, URL_PRINT_DATA);
        Test.setMock(HttpCalloutMock.class, new LedgerSheetOutputBizLogicMock('SuccessCase', URL_GET_TOKEN, URL_PRINT_DATA));

        String ledgerRes = ledger.svfLedgerSheetPrint(quote.Id, 'TestPrintData', 'TestFileName');
        Test.stopTest();
    }

    @IsTest
    private static void svfLedgerSheetPrintErrorCase1Test() {

        String CLIENT_ID = System.Label.SVF_ClientId;
        String SECRET_KEY = System.Label.SVF_SecretKey;
        String PRIVATE_KEY = System.Label.SVF_PrivateKey1to1000 + System.Label.SVF_PrivateKey1001to2000;
        String URL_GET_TOKEN = System.Label.SVF_UrlGetToken;
        String URL_PRINT_DATA = System.Label.SVF_UrlPrintData;

        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567890' LIMIT 1];

        Test.startTest();
        LedgerSheetOutputBizLogic ledger = new LedgerSheetOutputBizLogic(CLIENT_ID, SECRET_KEY, PRIVATE_KEY, URL_GET_TOKEN, URL_PRINT_DATA);
        Test.setMock(HttpCalloutMock.class, new LedgerSheetOutputBizLogicMock('ErrorCase1', URL_GET_TOKEN, URL_PRINT_DATA));

        Boolean exceptionOccurred = false;
        try{
            String ledgerRes = ledger.svfLedgerSheetPrint(quote.Id, 'TestPrintData', 'TestFileName');
        }catch (Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    @IsTest
    private static void svfLedgerSheetPrintErrorCase2Test() {

        String CLIENT_ID = System.Label.SVF_ClientId;
        String SECRET_KEY = System.Label.SVF_SecretKey;
        String PRIVATE_KEY = System.Label.SVF_PrivateKey1to1000 + System.Label.SVF_PrivateKey1001to2000;
        String URL_GET_TOKEN = System.Label.SVF_UrlGetToken;
        String URL_PRINT_DATA = System.Label.SVF_UrlPrintData;

        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567890' LIMIT 1];

        Test.startTest();
        LedgerSheetOutputBizLogic ledger = new LedgerSheetOutputBizLogic(CLIENT_ID, SECRET_KEY, PRIVATE_KEY, URL_GET_TOKEN, URL_PRINT_DATA);
        Test.setMock(HttpCalloutMock.class, new LedgerSheetOutputBizLogicMock('ErrorCase2', URL_GET_TOKEN, URL_PRINT_DATA));

        Boolean exceptionOccurred = false;
        try{
            String ledgerRes = ledger.svfLedgerSheetPrint(quote.Id, 'TestPrintData', 'TestFileName');
        }catch (Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    @IsTest
    private static void svfLedgerSheetPrintErrorCase3Test() {

        String CLIENT_ID = System.Label.SVF_ClientId;
        String SECRET_KEY = System.Label.SVF_SecretKey;
        String PRIVATE_KEY = System.Label.SVF_PrivateKey1to1000 + System.Label.SVF_PrivateKey1001to2000;
        String URL_GET_TOKEN = System.Label.SVF_UrlGetToken;
        String URL_PRINT_DATA = System.Label.SVF_UrlPrintData;

        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567890' LIMIT 1];

        Test.startTest();
        LedgerSheetOutputBizLogic ledger = new LedgerSheetOutputBizLogic(CLIENT_ID, SECRET_KEY, PRIVATE_KEY, URL_GET_TOKEN, null);
        Test.setMock(HttpCalloutMock.class, new LedgerSheetOutputBizLogicMock('ErrorCase3', URL_GET_TOKEN, URL_PRINT_DATA));

        Boolean exceptionOccurred = false;
        try{
            String ledgerRes = ledger.svfLedgerSheetPrint(quote.Id, 'TestPrintData', 'TestFileName');
        }catch (Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    @IsTest
    private static void svfLedgerSheetPrintErrorCase4Test() {

        String CLIENT_ID = System.Label.SVF_ClientId;
        String SECRET_KEY = System.Label.SVF_SecretKey;
        String PRIVATE_KEY = System.Label.SVF_PrivateKey1to1000 + System.Label.SVF_PrivateKey1001to2000;
        String URL_GET_TOKEN = System.Label.SVF_UrlGetToken;
        String URL_PRINT_DATA = System.Label.SVF_UrlPrintData;

        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567890' LIMIT 1];

        Test.startTest();
        LedgerSheetOutputBizLogic ledger = new LedgerSheetOutputBizLogic(CLIENT_ID, SECRET_KEY, PRIVATE_KEY, URL_GET_TOKEN, URL_PRINT_DATA);
        Test.setMock(HttpCalloutMock.class, new LedgerSheetOutputBizLogicMock('ErrorCase4', URL_GET_TOKEN, URL_PRINT_DATA));
        
        Boolean exceptionOccurred = false;
        try{
            String ledgerRes = ledger.svfLedgerSheetPrint(quote.Id, 'TestPrintData', 'TestFileName');
        }catch (Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        System.assert(!exceptionOccurred, 'An Exception was thrown');
    }

    @IsTest
    private static void svfLedgerSheetPrintErrorCase5Test() {

        String CLIENT_ID = System.Label.SVF_ClientId;
        String SECRET_KEY = System.Label.SVF_SecretKey;
        String PRIVATE_KEY = System.Label.SVF_PrivateKey1to1000 + System.Label.SVF_PrivateKey1001to2000;
        String URL_GET_TOKEN = System.Label.SVF_UrlGetToken;
        String URL_PRINT_DATA = System.Label.SVF_UrlPrintData;

        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567890' LIMIT 1];

        Test.startTest();
        LedgerSheetOutputBizLogic ledger = new LedgerSheetOutputBizLogic(CLIENT_ID, SECRET_KEY, PRIVATE_KEY, URL_GET_TOKEN, URL_PRINT_DATA);
        Test.setMock(HttpCalloutMock.class, new LedgerSheetOutputBizLogicMock('ErrorCase5', URL_GET_TOKEN, URL_PRINT_DATA));
        
        Boolean exceptionOccurred = false;
        try{
            String ledgerRes = ledger.svfLedgerSheetPrint(quote.Id, 'TestPrintData', 'TestFileName');
        }catch (Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        System.assert(!exceptionOccurred, 'An Exception was thrown');
    }

    @IsTest
    private static void svfLedgerSheetPrintErrorCase6Test() {

        String CLIENT_ID = System.Label.SVF_ClientId;
        String SECRET_KEY = System.Label.SVF_SecretKey;
        String PRIVATE_KEY = System.Label.SVF_PrivateKey1to1000 + System.Label.SVF_PrivateKey1001to2000;
        String URL_GET_TOKEN = System.Label.SVF_UrlGetToken;
        String URL_PRINT_DATA = System.Label.SVF_UrlPrintData;

        Quote__c quote = [SELECT Id FROM quote__c WHERE QuoteNumber__c='1234567890' LIMIT 1];

        Test.startTest();
        LedgerSheetOutputBizLogic ledger = new LedgerSheetOutputBizLogic(CLIENT_ID, SECRET_KEY, PRIVATE_KEY, URL_GET_TOKEN, URL_PRINT_DATA);
        Test.setMock(HttpCalloutMock.class, new LedgerSheetOutputBizLogicMock('SuccessCase', URL_GET_TOKEN, URL_PRINT_DATA));
        
        Boolean exceptionOccurred = false;
        try{
            String ledgerRes = ledger.svfLedgerSheetPrint(null, 'TestPrintData', 'TestFileName');
        }catch (Exception e){
            exceptionOccurred = true;
        }
        Test.stopTest();
        System.assert(!exceptionOccurred, 'An Exception was thrown');
    }
}