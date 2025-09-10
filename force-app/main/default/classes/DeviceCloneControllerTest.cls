@isTest
private class DeviceCloneControllerTest {

    @isTest
    static void testExecuteMethodSuccess() {
        // テスト用の見積を作成
        Quote__c testQuote = new Quote__c();
        testQuote.QuoteNumber__c= '1';
        testQuote.GeneralAdministrativeExpenses__c = '10';
        testQuote.PowerFrequency__c = '50Hz';
        insert testQuote;

        // テスト用の見積項目を作成
        List<Device__c> testDevices = new List<Device__c>();
        for (Integer i = 0; i < 2; i++) {
            Device__c device = new Device__c();
            device.Name = '見積項目 ' + i;
            device.QuoteSpecificationNumber__c = 'Test'+i;
            device.MajorClassification__c = '高圧受配電盤';
            device.PriceCoefficient__c = 1.00;
            device.Quote__c = testQuote.Id;
            testDevices.add(device);
        }
        insert testDevices;
        System.debug('testDevices= '+testDevices);
        System.debug('testQuote= '+testQuote);

        // テスト見積項目のための標準セットコントローラを作成
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(testDevices);
        setController.setSelected(testDevices);

        // コントローラーのインスタンス化
        DeviceCloneController controller = new DeviceCloneController(setController);
        // copySetを有効な値に設定
        controller.copySet = '1';

        // executeメソッドを呼び出す
    Test.startTest();
    PageReference result = controller.execute();
    Test.stopTest();

    // 実行後の見積項目IDを取得
    List<Device__c> copiedDevices = [SELECT Id FROM Device__c WHERE QuoteSpecificationNumber__c LIKE '%_コピー%'];
    System.debug('copiedDevices='+copiedDevices);
    
    // アサーション
    System.assertEquals(testDevices.size() * Integer.valueOf(controller.copySet), copiedDevices.size());
    }

    @isTest
    static void testExecuteMethodWithInvalidInput() {
        // テスト用の見積もりを作成
        Quote__c testQuote = new Quote__c();
        testQuote.QuoteNumber__c= '1';
        testQuote.GeneralAdministrativeExpenses__c = '10';
        testQuote.PowerFrequency__c = '50Hz';
        insert testQuote;

        // テスト用の見積項目を作成
        List<Device__c> testDevices = new List<Device__c>();
        for (Integer i = 0; i < 2; i++) {
            Device__c device = new Device__c();
            device.Name = '見積項目 ' + i;
            device.QuoteSpecificationNumber__c = 'Test'+i;
            device.MajorClassification__c = '高圧受配電盤';
            device.PriceCoefficient__c = 1.00;
            device.Quote__c = testQuote.Id;
            testDevices.add(device);
        }
        insert testDevices;

        // テスト見積項目のための標準セットコントローラを作成
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(testDevices);
        setController.setSelected(testDevices);

        // コントローラのインスタンスを作成
        DeviceCloneController controller = new DeviceCloneController(setController);

        // copySetを無効な値に設定
        controller.copySet = '0';

        // executeメソッドを呼び出す
        Test.startTest();
        PageReference result = controller.execute();
        Test.stopTest();

        // エラーメッセージが設定されたことをアサート
        System.assertNotEquals(null, controller.errorMessage);
        // 実行が失敗したことをアサート（resultがnullであること）
        System.assertEquals(null, result);
    }
}