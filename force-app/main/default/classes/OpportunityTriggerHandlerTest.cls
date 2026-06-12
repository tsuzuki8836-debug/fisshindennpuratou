@isTest
private class OpportunityTriggerHandlerTest {

    /**
     * テストケース　recalculationOppByFactoryTest
     *
     * 【準備】
     *  案件を２件作成する
     *  場所別を２件作成する
     *  場所別.案件には案件1のIDを設定すること
     *
     * 【テスト実行】
     *  場所別をinsertする
     *
     * 【期待値】
     *  案件に紐づく場所別の商談CP、商談WC、商談TCが集計された結果が、案件の商談CP、商談WC、商談TCにセットされていること
     */
    @IsTest
    private static void recalculationOppByFactoryTest() {

        List<RecordType> recType = [SELECT Id, name, SobjectType  FROM RecordType WHERE SobjectType = 'Account' and name = '事業所'];

        Account acc = new Account(
            Name = 'Test Account',
            Phone = '09011111111',
            RecordTypeId = recType[0].Id,
            OfficeName__c = 'acc01'
        );
        insert acc;

        Property__c prop = new Property__c(
            Name = 'Test Prop'
        );
        insert prop;

        SupplySite__c supplySite = new SupplySite__c(
            Name='テスト納入サイト',
            SBU__c='建設防災'
        );
        insert supplySite;

        List<Opportunity> oppList = new List<Opportunity>();

        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp1',
            StageName = '基本計画',
            CloseDate = Date.today(),
            SBU__c = 'PVスマエネ',
            Property__c = prop.Id,
            ScheduledCollectionDate__c = Date.today(),
            ConstructionDistinction__c = '新設',
            OrderExpectation__c = '1',
            Website__c = 01,
            Handling__c = '直扱',
            DemanDepartment__c = '金融',
            DemandOf__c = '官需',
            SupplySite__c = supplySite.id,
            InformationFrom__c = '施主',
            AccountId = acc.Id
        );
        oppList.add(opp1);

        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp2',
            StageName = '基本計画',
            CloseDate = Date.today(),
            SBU__c = '受変電',
            Property__c = prop.Id,
            ScheduledCollectionDate__c = Date.today(),
            ConstructionDistinction__c = '新設',
            OrderExpectation__c = '2',
            Website__c = 02,
            Handling__c = '直扱',
            DemanDepartment__c = '通信',
            DemandOf__c = '官需',
            SupplySite__c = supplySite.id,
            InformationFrom__c = '施主',
            AccountId = acc.Id
        );
        oppList.add(opp2);

        insert oppList;

        List<Factory__c> facList = new List<Factory__c>();

        //場所別
        Factory__c Fac01 = new Factory__c(
            Opp1__c = opp1.Id,
            CommonRatio1__c = '21% ： 製作所',
            BU__c = '施設',
            CarryingDay__c = Date.today() + 10,
            SR_CP__c = 200,
            SRWC__c = 100
        );
        facList.add(Fac01);

        Factory__c Fac02 = new Factory__c(
            Opp1__c = opp1.Id,
            CommonRatio1__c = '22% ： プラ統',
            BU__c = '施設',
            CarryingDay__c = Date.today() + 10,
            SR_CP__c = 400,
            SRWC__c = 300
        );
        facList.add(Fac02);

        //テスト実行
        Test.startTest();

        insert facList;

        Test.stopTest();

        //検証
        List<AggregateResult> aggFacResult1 =
            [SELECT Opp1__c,
                SUM(SR_CP__c) SumValue1,
                SUM(SRWC__c) SumValue2,
                SUM(TC__c) SumValue3
            FROM Factory__c WHERE Opp1__c = :opp1.Id AND DeleteFlag__c = false GROUP BY Opp1__c];

        List<Opportunity> oppResult1 =
            [SELECT Id,
                TotalCP__c,
                TotalWC__c,
                TC__c
            FROM Opportunity WHERE Id = :opp1.Id];

        List<Opportunity> oppResult2 =
            [SELECT Id,
                TotalCP__c,
                TotalWC__c,
                TC__c
            FROM Opportunity WHERE Id = :opp2.Id];

        System.assertEquals(aggFacResult1[0].get('SumValue1'), oppResult1[0].TotalCP__c);
        System.assertEquals(aggFacResult1[0].get('SumValue2'), oppResult1[0].TotalWC__c);
        System.assertEquals(aggFacResult1[0].get('SumValue3'), oppResult1[0].TC__c);
        System.assertEquals(null, oppResult2[0].TotalCP__c);
        System.assertEquals(null, oppResult2[0].TotalWC__c);
        System.assertEquals(null, oppResult2[0].TC__c);
    }

    /**
     * テストケース　recalculationOppBySRInfoTest
     *
     * 【準備】
     *  部門管理者ユーザで操作する
     *  案件を２件作成する
     *  オーダー管理台帳を２件作成する
     *  オーダー管理台帳.商談番号には案件1の商談番号を設定すること
     *
     * 【テスト実行】
     *  SR情報を３件作成する
     *  SR情報１～２件目：SR情報.案件には案件1のIDを設定すること
     *  SR情報３件目：SR情報.案件には案件2のIDを設定すること
     *
     * 【期待値】
     *  案件に紐づくSR情報のCP、WCの集計結果が、案件のCP、WCにセットされていること
     *  案件1.フェーズが「オーダー完了」であること
     *  案件2.フェーズが「受注・オーダー管理」であること
     *  案件毎に最小の受注年月日がセットされていること
     *  案件毎に最大のSR情報取得日（最新）と 売上年月日がセットされていること
     *  オーダー管理台帳から取得した販売手数料がセットされていること
     */
    @IsTest
    private static void recalculationOppBySRInfoTest() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {

            List<RecordType> recType = [SELECT Id, name, SobjectType  FROM RecordType WHERE SobjectType = 'Account' and name = '事業所'];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType[0].Id,
                OfficeName__c = 'acc01'
            );
            insert acc;

            Property__c prop = new Property__c(
                Name = 'Test Prop'
            );
            insert prop;

            SupplySite__c supplySite = new SupplySite__c(
                Name='テスト納入サイト',
                SBU__c='建設防災'
            );
            insert supplySite;

            List<Opportunity> oppList = new List<Opportunity>();

            Opportunity opp1 = new Opportunity(
                Name = 'Test Opp1',
                StageName = '基本計画',
                CloseDate = Date.today(),
                SBU__c = 'PVスマエネ',
                Property__c = prop.Id,
                ScheduledCollectionDate__c = Date.today(),
                ConstructionDistinction__c = '新設',
                OrderExpectation__c = '1',
                Website__c = 01,
                Handling__c = '直扱',
                DemanDepartment__c = '金融',
                DemandOf__c = '官需',
                SupplySite__c = supplySite.id,
                InformationFrom__c = '施主',
                AccountId = acc.Id,
                Competitor__c = acc.Id,
                OpportunityNumber__c = 'F9999-U000-0',
                OpportunityNumber_Hyphenless__c = 'F9999U0000'
            );
            oppList.add(opp1);

            Opportunity opp2 = new Opportunity(
                Name = 'Test Opp2',
                StageName = '基本計画',
                CloseDate = Date.today(),
                SBU__c = '受変電',
                Property__c = prop.Id,
                ScheduledCollectionDate__c = Date.today(),
                ConstructionDistinction__c = '新設',
                OrderExpectation__c = '2',
                Website__c = 02,
                Handling__c = '直扱',
                DemanDepartment__c = '通信',
                DemandOf__c = '官需',
                SupplySite__c = supplySite.id,
                InformationFrom__c = '施主',
                AccountId = acc.Id,
                Competitor__c = acc.Id,
                OpportunityNumber__c = 'F9999-U000-1',
                OpportunityNumber_Hyphenless__c = 'F9999U0001'
            );
            oppList.add(opp2);

            insert oppList;

            // オーダー管理台帳
            List<OrderManagementLedger__c> ordList = new List<OrderManagementLedger__c>();

            OrderManagementLedger__c ord1 = new OrderManagementLedger__c(
                SR_Number__c = 'A9999V0000',
                OpportunityNumber__c = 'F9999U0000',
                MarginText__c = '1000'
            );
            ordList.add(ord1);

            // 同一商談番号（OpportunityNumber__c）で２件目の販売手数料が異なる
            OrderManagementLedger__c ord2 = new OrderManagementLedger__c(
                SR_Number__c = 'A9999V0001',
                OpportunityNumber__c = 'F9999U0000',
                MarginText__c = '2000'
            );
            ordList.add(ord2);

            insert ordList;

            // SR情報
            List<SRInfo__c> srList = new List<SRInfo__c>();

            Date orderDate = Date.today().addMonths(-3) -5;

            SRInfo__c sr1 = new SRInfo__c(
                OP_Number__c = 'F9999U0000',
                SR_Number__c = 'A9999V0000',
                J_Number__c = '001',
                Opportunity__c = opp1.Id,
                Order_SRCP__c = 200,
                Order_SRWC__c = 100,
                Order_Forecast_SRCP__c = 210,
                Order_Forecast_SRWC__c = 300,
                Latest_SRCP__c = 1000,
                Latest_SRWC__c = 800,
                Latest_Forecast_SRCP__c = 700,
                Latest_Forecast_SRWC__c = 900,
                Result_SRCP__c = 100,
                Result_SRWC__c = 300,
                Result_Difference__c = 1200,
                Result_AdditionalCost__c = 1100,
                Order_OrderDate__c = orderDate,
                Latest_SRInfoUpdateDate__c= Date.today().addMonths(-3),
                Result_SalesDate__c = Date.today().addMonths(-2)
            );
            srList.add(sr1);

            SRInfo__c sr2 = new SRInfo__c(
                OP_Number__c = 'F9999U0000',
                SR_Number__c = 'A9999V0000',
                J_Number__c = '002',
                Opportunity__c = opp1.Id,
                Order_SRCP__c = 200,
                Order_SRWC__c = 100,
                Order_Forecast_SRCP__c = 210,
                Order_Forecast_SRWC__c = 300,
                Latest_SRCP__c = 1000,
                Latest_SRWC__c = 800,
                Latest_Forecast_SRCP__c = 700,
                Latest_Forecast_SRWC__c = 900,
                Result_SRCP__c = 100,
                Result_SRWC__c = 300,
                Result_Difference__c = 1200,
                Result_AdditionalCost__c = 1100,
                Order_OrderDate__c = Date.today().addMonths(-2) -5,
                Latest_SRInfoUpdateDate__c= Date.today().addMonths(-2),
                Result_SalesDate__c = Date.today().addMonths(-1)
            );
            srList.add(sr2);

            SRInfo__c sr3 = new SRInfo__c(
                OP_Number__c = 'F9999U0001',
                SR_Number__c = 'A9999V0001',
                J_Number__c = '001',
                Opportunity__c = opp2.Id,
                Order_SRCP__c = 200,
                Order_SRWC__c = 100,
                Order_Forecast_SRCP__c = 210,
                Order_Forecast_SRWC__c = 300,
                Latest_SRCP__c = 1000,
                Latest_SRWC__c = 800,
                Latest_Forecast_SRCP__c = 700,
                Latest_Forecast_SRWC__c = 900,
                Order_OrderDate__c = Date.today().addMonths(-2) -5,
                Latest_SRInfoUpdateDate__c= Date.today().addMonths(-2)
            );
            srList.add(sr3);

            //テスト実行
            Test.startTest();

            insert srList;

            Test.stopTest();

            //検証
            // 案件１に紐づくSR情報から受注年月の最小を取得する
            AggregateResult a = [SELECT MIN(OrderMonth__c) month FROM SRInfo__c WHERE Opportunity__c = :opp1.Id];
            String month = String.valueOf(a.get('month'));

            // SR情報から「受注時」情報を取得する
            List<AggregateResult> aggSRInfoResult1 =
                [SELECT Opportunity__c,
                    SUM(Order_SRCP__c) SumValue1,
                    SUM(Order_SRWC__c) SumValue2,
                    SUM(Order_Forecast_SRCP__c) SumValue3,
                    SUM(Order_Forecast_SRWC__c) SumValue4
                FROM SRInfo__c WHERE Opportunity__c = :opp1.Id AND OrderMonth__c = :month GROUP BY Opportunity__c];

            // SR情報から「受注後最新」「売上実績」情報を取得する
            List<AggregateResult> aggSRInfoResult2 =
                [SELECT Opportunity__c,
                    SUM(Latest_SRCP__c) SumValue5,
                    SUM(Latest_SRWC__c) SumValue6,
                    SUM(Latest_Forecast_SRCP__c) SumValue7,
                    SUM(Latest_Forecast_SRWC__c) SumValue8,
                    SUM(Result_SRCP__c) SumValue9,
                    SUM(Result_SRWC__c) SumValue10,
                    SUM(Result_Difference__c) SumValue11,
                    SUM(Result_AdditionalCost__c) SumValue12,
                    MAX(Latest_SRInfoUpdateDate__c) MaxValue1,
                    MAX(Result_SalesDate__c) MaxValue2
                FROM SRInfo__c WHERE Opportunity__c = :opp1.Id GROUP BY Opportunity__c];

            // 案件２に紐づくSR情報から受注年月の最小を取得する
            AggregateResult a2 = [SELECT MIN(OrderMonth__c) month FROM SRInfo__c WHERE Opportunity__c = :opp2.Id];
            String orderMonthMin2 = String.valueOf(a2.get('month'));

            // SR情報から「受注時」情報を取得する
            List<AggregateResult> aggSRInfoResult3 =
                [SELECT Opportunity__c,
                    SUM(Order_SRCP__c) SumValue1,
                    SUM(Order_SRWC__c) SumValue2,
                    SUM(Order_Forecast_SRCP__c) SumValue3,
                    SUM(Order_Forecast_SRWC__c) SumValue4
                FROM SRInfo__c WHERE Opportunity__c = :opp2.Id AND OrderMonth__c = :orderMonthMin2 GROUP BY Opportunity__c];

            List<Opportunity> oppResult1 =
                [SELECT Id,
                    StageName,
                    LastSRAggregateDate__c,
                    Order_TotalCP__c,
                    Order_TotalWC__c,
                    Order_Forecast_TotalCP__c,
                    Order_Forecast_TotalWC__c,
                    Latest_TotalCP__c,
                    Latest_TotalWC__c,
                    Latest_Forecast_TotalCP__c,
                    Latest_Forecast_TotalWC__c,
                    Result_TotalCP__c,
                    Result_TotalWC__c,
                    Result_Difference__c,
                    Result_AdditionalCost__c,
                    Order_OrderDate__c,
                    Latest_SRInfoUpdateDate__c,
                    Result_SalesDate__c,
                    Order_Margin__c,
                    Latest_Margin__c,
                    Result_Margin__c
                FROM Opportunity WHERE Id = :opp1.Id];

            List<Opportunity> oppResult2 =
                [SELECT Id,
                    StageName,
                    Order_TotalCP__c,
                    Order_TotalWC__c,
                    Order_Forecast_TotalCP__c,
                    Order_Forecast_TotalWC__c
                FROM Opportunity WHERE Id = :opp2.Id];

            // 案件１
            System.assertEquals('オーダー完了', oppResult1[0].StageName);
            System.assertEquals(aggSRInfoResult1[0].get('SumValue1'), oppResult1[0].Order_TotalCP__c);
            System.assertEquals(aggSRInfoResult1[0].get('SumValue2'), oppResult1[0].Order_TotalWC__c);
            System.assertEquals(aggSRInfoResult1[0].get('SumValue3'), oppResult1[0].Order_Forecast_TotalCP__c);
            System.assertEquals(aggSRInfoResult1[0].get('SumValue4'), oppResult1[0].Order_Forecast_TotalWC__c);
            System.assertEquals(aggSRInfoResult2[0].get('SumValue5'), oppResult1[0].Latest_TotalCP__c);
            System.assertEquals(aggSRInfoResult2[0].get('SumValue6'), oppResult1[0].Latest_TotalWC__c);
            System.assertEquals(aggSRInfoResult2[0].get('SumValue7'), oppResult1[0].Latest_Forecast_TotalCP__c);
            System.assertEquals(aggSRInfoResult2[0].get('SumValue8'), oppResult1[0].Latest_Forecast_TotalWC__c);
            System.assertEquals(aggSRInfoResult2[0].get('SumValue9'), oppResult1[0].Result_TotalCP__c);
            System.assertEquals(aggSRInfoResult2[0].get('SumValue10'), oppResult1[0].Result_TotalWC__c);
            System.assertEquals(aggSRInfoResult2[0].get('SumValue11'), oppResult1[0].Result_Difference__c);
            System.assertEquals(aggSRInfoResult2[0].get('SumValue12'), oppResult1[0].Result_AdditionalCost__c);
            System.assertEquals(orderDate, oppResult1[0].Order_OrderDate__c);
            System.assertEquals(aggSRInfoResult2[0].get('MaxValue1'), oppResult1[0].Latest_SRInfoUpdateDate__c);
            System.assertEquals(aggSRInfoResult2[0].get('MaxValue2'), oppResult1[0].Result_SalesDate__c);
            // オーダー管理台帳
            // SR手数料（受注時）は１件目の値（受注した段階の金額）であること
            System.assertEquals(1000, oppResult1[0].Order_Margin__c);
            // SR手数料（最新）は１件目の値（受注した段階の金額）であること
            System.assertEquals(1000, oppResult1[0].Latest_Margin__c);
            // 売上実績手数料に２件目の値であること
            System.assertEquals(2000, oppResult1[0].Result_Margin__c);
            // 案件２
            System.assertEquals('受注・オーダー管理', oppResult2[0].StageName);
            System.assertEquals(aggSRInfoResult3[0].get('SumValue1'), oppResult2[0].Order_TotalCP__c);
            System.assertEquals(aggSRInfoResult3[0].get('SumValue2'), oppResult2[0].Order_TotalWC__c);
            System.assertEquals(aggSRInfoResult3[0].get('SumValue3'), oppResult2[0].Order_Forecast_TotalCP__c);
            System.assertEquals(aggSRInfoResult3[0].get('SumValue4'), oppResult2[0].Order_Forecast_TotalWC__c);
        }
    }

    /**
     * テストケース　recalculationOppBySRInfoTest2
     *
     * 【準備】
     *  部門管理者ユーザで操作する
     *  案件を１件作成する
     *  SR情報を１件作成する
     *  SR情報.案件には案件IDを設定すること
     *  オーダー管理台帳を１件作成する
     *  オーダー管理台帳.商談番号には案件の商談番号を設定しないこと
     *
     * 【テスト実行】
     *  SR情報を作成する
     *
     * 【期待値】
     *  案件に紐づくオーダー管理台帳が存在しないため、案件の手数料が更新されないこと
     */
    @IsTest
    private static void recalculationOppBySRInfoTest2() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {

            List<RecordType> recType = [SELECT Id, name, SobjectType  FROM RecordType WHERE SobjectType = 'Account' and name = '事業所'];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType[0].Id,
                OfficeName__c = 'acc01'
            );
            insert acc;

            Property__c prop = new Property__c(
                Name = 'Test Prop'
            );
            insert prop;

            SupplySite__c supplySite = new SupplySite__c(
                Name='テスト納入サイト',
                SBU__c='建設防災'
            );
            insert supplySite;

            List<Opportunity> oppList = new List<Opportunity>();

            Opportunity opp1 = new Opportunity(
                Name = 'Test Opp1',
                StageName = '基本計画',
                CloseDate = Date.today(),
                SBU__c = 'PVスマエネ',
                Property__c = prop.Id,
                ScheduledCollectionDate__c = Date.today(),
                ConstructionDistinction__c = '新設',
                OrderExpectation__c = '1',
                Website__c = 01,
                Handling__c = '直扱',
                DemanDepartment__c = '金融',
                DemandOf__c = '官需',
                SupplySite__c = supplySite.id,
                InformationFrom__c = '施主',
                AccountId = acc.Id,
                Competitor__c = acc.Id,
                OpportunityNumber__c = 'F9999-U000-0',
                OpportunityNumber_Hyphenless__c = 'F9999U0000'
            );
            oppList.add(opp1);

            insert oppList;

            // オーダー管理台帳（案件.商談番号と異なる商談番号をセットする）
            List<OrderManagementLedger__c> ordList = new List<OrderManagementLedger__c>();

            OrderManagementLedger__c ord1 = new OrderManagementLedger__c(
                SR_Number__c = 'A9999V0000',
                OpportunityNumber__c = 'F9999U0001',
                MarginText__c = '1000'
            );
            ordList.add(ord1);

            insert ordList;

            // SR情報
            List<SRInfo__c> srList = new List<SRInfo__c>();

            SRInfo__c sr1 = new SRInfo__c(
                OP_Number__c = 'F9999U0000',
                SR_Number__c = 'A9999V0000',
                J_Number__c = '001',
                Opportunity__c = opp1.Id,
                Order_SRCP__c = 200,
                Order_SRWC__c = 100,
                Order_Forecast_SRCP__c = 210,
                Order_Forecast_SRWC__c = 300,
                Latest_SRCP__c = 1000,
                Latest_SRWC__c = 800,
                Latest_Forecast_SRCP__c = 700,
                Latest_Forecast_SRWC__c = 900,
                Result_SRCP__c = 100,
                Result_SRWC__c = 300,
                Result_Difference__c = 1200,
                Result_AdditionalCost__c = 1100,
                Order_OrderDate__c = Date.today().addMonths(-3) -5,
                Latest_SRInfoUpdateDate__c= Date.today().addMonths(-3),
                Result_SalesDate__c = Date.today().addMonths(-2)
            );
            srList.add(sr1);

            //テスト実行
            Test.startTest();

            insert srList;

            Test.stopTest();

            //検証
            List<Opportunity> oppResult1 =
                [SELECT Id,
                    Order_Margin__c,
                    Latest_Margin__c,
                    Result_Margin__c
                FROM Opportunity WHERE Id = :opp1.Id];

            // 手数料が更新されていないこと
            System.assertEquals(null, oppResult1[0].Order_Margin__c);
            System.assertEquals(null, oppResult1[0].Latest_Margin__c);
            System.assertEquals(null, oppResult1[0].Result_Margin__c);
        }
    }

    /**
     * テストケース　recalculationOppBySRInfoTest3
     *
     * 【準備】
     *  部門管理者ユーザで操作する
     *  案件を１件作成する
     *  SR情報を３件作成する
     *  ３件のうち２件は売報番号を同一にする
     *  SR情報.案件には案件IDを設定すること
     *
     * 【テスト実行】
     *  SR情報を作成する
     *
     * 【期待値】
     *  売報番号の重複が除去されること
     *  案件.売報番号が設定されていること
     *  案件.その他売報番号に代表の売報番号が含まれていないこと
     */
    @IsTest
    private static void recalculationOppBySRInfoTest3() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {

            List<RecordType> recType = [SELECT Id, name, SobjectType  FROM RecordType WHERE SobjectType = 'Account' and name = '事業所'];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType[0].Id,
                OfficeName__c = 'acc01'
            );
            insert acc;

            Property__c prop = new Property__c(
                Name = 'Test Prop'
            );
            insert prop;

            SupplySite__c supplySite = new SupplySite__c(
                Name='テスト納入サイト',
                SBU__c='建設防災'
            );
            insert supplySite;

            List<Opportunity> oppList = new List<Opportunity>();

            Opportunity opp1 = new Opportunity(
                Name = 'Test Opp1',
                StageName = '基本計画',
                CloseDate = Date.today(),
                SBU__c = 'PVスマエネ',
                Property__c = prop.Id,
                ScheduledCollectionDate__c = Date.today(),
                ConstructionDistinction__c = '新設',
                OrderExpectation__c = '1',
                Website__c = 01,
                Handling__c = '直扱',
                DemanDepartment__c = '金融',
                DemandOf__c = '官需',
                SupplySite__c = supplySite.id,
                InformationFrom__c = '施主',
                AccountId = acc.Id,
                Competitor__c = acc.Id,
                OpportunityNumber__c = 'F9999-U000-0',
                OpportunityNumber_Hyphenless__c = 'F9999U0000'
            );
            oppList.add(opp1);

            insert oppList;

            // SR情報
            List<SRInfo__c> srList = new List<SRInfo__c>();

            Date orderDate = Date.today().addMonths(-3) -5;

            // 商談番号(OP_Number__c)が設定されている売報番号(SR_Number__c)が主
            SRInfo__c sr1 = new SRInfo__c(
                OP_Number__c = 'F9999U0000',
                SR_Number__c = 'A9999V0000',
                J_Number__c = '001',
                Opportunity__c = opp1.Id
            );
            srList.add(sr1);

            SRInfo__c sr2 = new SRInfo__c(
                OP_Number__c = '',
                SR_Number__c = 'A9999V0001',
                J_Number__c = '001',
                Opportunity__c = opp1.Id
            );
            srList.add(sr2);

            // sr1と売報番号(SR_Number__c)が重複
            SRInfo__c sr3 = new SRInfo__c(
                OP_Number__c = '',
                SR_Number__c = 'A9999V0000',
                J_Number__c = '002',
                Opportunity__c = opp1.Id
            );
            srList.add(sr3);

            //テスト実行
            Test.startTest();

            insert srList;

            Test.stopTest();

            //検証
            List<Opportunity> oppResult1 =
                [SELECT Id,
                    SR_Number_Main__c,
                    SellingNumber__c
                FROM Opportunity WHERE Id = :opp1.Id];

            // 案件１
            System.assertEquals('A9999V0000', oppResult1[0].SR_Number_Main__c);
            System.assertEquals('A9999V0001', oppResult1[0].SellingNumber__c);
        }
    }

    /**
     * テストケース　recalculationOppBySRInfoTest4
     *
     * 【準備】
     *  部門管理者ユーザで操作する
     *  案件を２件作成する
     *  SR情報を２件ずつ作成する
     *  SR情報.案件には各案件IDを設定すること
     *
     * 【テスト実行】
     *  SR情報を作成する
     *
     * 【期待値】
     *  案件.売報番号が設定されていること
     *  案件.その他売報番号に代表の売報番号が含まれていないこと
     */
    @IsTest
    private static void recalculationOppBySRInfoTest4() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {

            List<RecordType> recType = [SELECT Id, name, SobjectType  FROM RecordType WHERE SobjectType = 'Account' and name = '事業所'];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType[0].Id,
                OfficeName__c = 'acc01'
            );
            insert acc;

            Property__c prop = new Property__c(
                Name = 'Test Prop'
            );
            insert prop;

            SupplySite__c supplySite = new SupplySite__c(
                Name='テスト納入サイト',
                SBU__c='建設防災'
            );
            insert supplySite;

            List<Opportunity> oppList = new List<Opportunity>();

            Opportunity opp1 = new Opportunity(
                Name = 'Test Opp1',
                StageName = '基本計画',
                CloseDate = Date.today(),
                SBU__c = 'PVスマエネ',
                Property__c = prop.Id,
                ScheduledCollectionDate__c = Date.today(),
                ConstructionDistinction__c = '新設',
                OrderExpectation__c = '1',
                Website__c = 01,
                Handling__c = '直扱',
                DemanDepartment__c = '金融',
                DemandOf__c = '官需',
                SupplySite__c = supplySite.id,
                InformationFrom__c = '施主',
                AccountId = acc.Id,
                Competitor__c = acc.Id,
                OpportunityNumber__c = 'F9999-U000-0',
                OpportunityNumber_Hyphenless__c = 'F9999U0000'
            );
            oppList.add(opp1);

            Opportunity opp2 = new Opportunity(
                Name = 'Test Opp2',
                StageName = '基本計画',
                CloseDate = Date.today(),
                SBU__c = '受変電',
                Property__c = prop.Id,
                ScheduledCollectionDate__c = Date.today(),
                ConstructionDistinction__c = '新設',
                OrderExpectation__c = '2',
                Website__c = 02,
                Handling__c = '直扱',
                DemanDepartment__c = '通信',
                DemandOf__c = '官需',
                SupplySite__c = supplySite.id,
                InformationFrom__c = '施主',
                AccountId = acc.Id,
                Competitor__c = acc.Id,
                OpportunityNumber__c = 'F8888-U000-1',
                OpportunityNumber_Hyphenless__c = 'F8888U0001'
            );
            oppList.add(opp2);

            insert oppList;

            // SR情報
            List<SRInfo__c> srList = new List<SRInfo__c>();

            Date orderDate = Date.today().addMonths(-3) -5;

            // 商談番号(OP_Number__c)が設定されている売報番号(SR_Number__c)が主
            SRInfo__c sr1 = new SRInfo__c(
                OP_Number__c = 'F9999U0000',
                SR_Number__c = 'A9999V0000',
                J_Number__c = '001',
                Opportunity__c = opp1.Id
            );
            srList.add(sr1);

            SRInfo__c sr2 = new SRInfo__c(
                OP_Number__c = '',
                SR_Number__c = 'A9999V0001',
                J_Number__c = '001',
                Opportunity__c = opp1.Id
            );
            srList.add(sr2);

            // 商談番号(OP_Number__c)が設定されている売報番号(SR_Number__c)が主
            SRInfo__c sr3 = new SRInfo__c(
                OP_Number__c = 'F8888U0000',
                SR_Number__c = 'A8888V0000',
                J_Number__c = '001',
                Opportunity__c = opp2.Id
            );
            srList.add(sr3);

            SRInfo__c sr4 = new SRInfo__c(
                OP_Number__c = '',
                SR_Number__c = 'A8888V0001',
                J_Number__c = '001',
                Opportunity__c = opp2.Id
            );
            srList.add(sr4);

            //テスト実行
            Test.startTest();

            insert srList;

            Test.stopTest();

            //検証
            List<Opportunity> oppResult1 =
                [SELECT Id,
                    SR_Number_Main__c,
                    SellingNumber__c
                FROM Opportunity WHERE Id = :opp1.Id];

            List<Opportunity> oppResult2 =
                [SELECT Id,
                    SR_Number_Main__c,
                    SellingNumber__c
                FROM Opportunity WHERE Id = :opp2.Id];

            // 案件１
            System.assertEquals('A9999V0000', oppResult1[0].SR_Number_Main__c);
            System.assertEquals('A9999V0001', oppResult1[0].SellingNumber__c);
            // 案件２
            System.assertEquals('A8888V0000', oppResult2[0].SR_Number_Main__c);
            System.assertEquals('A8888V0001', oppResult2[0].SellingNumber__c);
        }
    }

    private static User createUser(Id profileId, Id roleId, String uNamePref, String BUVal, String division, String department, String division01) {
        String str = Datetime.now().format('yyyyMMddHHmmss');
        User u = new User(
            UserName = uNamePref + '-' + str + '@prot2.mc.example.com.3bu'
            , Email = uNamePref + '-' + str + '@prot2.mc.example.com.3bu'
            , LastName = 'test'
            , Alias = 'test'
            , TimeZoneSidKey = 'Asia/Tokyo'
            , LocaleSidKey = 'ja_JP'
            , EmailEncodingKey = 'ISO-2022-JP'
            , LanguageLocaleKey = 'ja'
            , ProfileId = profileId
            , UserRoleId = roleId
            , BU__c = BUVal
            , DepartmentAndDivision__c = division
            , Department__c = department
            , Division01__c = division01
        );
        return u;
    }

    /**
     * テストケース　createNewInternalApprovalTest
     *
     * 【準備】
     *  部門管理者ユーザで操作する
     *  案件を２件作成する
     *
     * 【テスト実行】
     *  案件をinsertする
     *
     * 【期待値】
     *  案件に紐づく社内承認レコードが作成されていること、社内承認名は'伺い関連'となっていること
     */
    @IsTest
    private static void createNewInternalApprovalTest(){
        //テスト準備
        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {
            List<RecordType> recType = [SELECT Id, name, SobjectType  FROM RecordType WHERE SobjectType = 'Account' and name = '事業所'];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType[0].Id,
                OfficeName__c = 'acc01'
            );
            insert acc;

            Region__c region = new Region__c(
                Name = 'Test region'
            );
            insert region;

            SupplySite__c supplySite = new SupplySite__c(
                Name='テスト納入サイト',
                SBU__c='建設防災'
            );
            insert supplySite;

            List<Opportunity> oppList = new List<Opportunity>();

            Opportunity opp1 = new Opportunity(
                Name = 'Test Opp <name test>',
                AccountId = acc.Id,
                StageName = '基本計画',
                OrderExpectation__c = '1',
                Region__c = region.Id,
                BU__c = '官需',
                SBU__c = '建設防災',
                Plant__c = '国交省(河川)',
                CloseDate = Date.today(),
                ScheduledSalesDate__c = Date.today(),
                NeedConstruction__c = '無',
                KOUJI_SYU__c = '電気工事',
                UKE_KBN__c = '元請',
                Handling__c = '直扱',
                DemandOf__c = '官需',
                SupplySite__c = supplySite.id,
                InformationFrom__c = '施主',
                ConstructionDistinction__c = '新設',
                DemanDepartment__c = '官公庁',
                ExportCategory__c = '0'
            );
            oppList.add(opp1);

            Opportunity opp2 = new Opportunity(
                Name = 'Test Opp2*',
                AccountId = acc.Id,
                StageName = '基本設計',
                OrderExpectation__c = '1',
                Region__c = region.Id,
                BU__c = '官需',
                SBU__c = '有料道路',
                Plant__c = 'NEXCO既存',
                CloseDate = Date.today(),
                ScheduledSalesDate__c = Date.today(),
                NeedConstruction__c = '無',
                KOUJI_SYU__c = '電気工事',
                UKE_KBN__c = '元請',
                Handling__c = '直扱',
                DemandOf__c = '官需',
                SupplySite__c = supplySite.id,
                InformationFrom__c = 'サブコン',
                ConstructionDistinction__c = '新設',
                DemanDepartment__c = '官公庁',
                ExportCategory__c = '0'
            );
            oppList.add(opp2);

            //テスト実行
            Test.startTest();
            insert oppList;
            Test.stopTest();

            //テスト検証
            List<InternalApproval__c> internalApprovals = [SELECT Id, Name, Opportunity__c, Opportunity__r.Name
                                                            FROM InternalApproval__c
                                                            WHERE Opportunity__c = :opp1.Id];

            List<InternalApproval__c> internalApprovals2 = [SELECT Id, Name, Opportunity__c, Opportunity__r.Name
                                                            FROM InternalApproval__c
                                                            WHERE Opportunity__c = :opp2.Id];

            // 案件１
            System.assertEquals('伺い関連', internalApprovals[0].Name);
            System.assertEquals('Test Opp ＜name test＞', internalApprovals[0].Opportunity__r.name);

            // 案件２
            System.assertEquals('伺い関連', internalApprovals2[0].Name);
            System.assertEquals('Test Opp2＊', internalApprovals2[0].Opportunity__r.name);
        }
    }
}