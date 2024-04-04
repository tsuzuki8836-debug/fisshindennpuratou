@isTest
private class SRInfoTriggerHandlerTest {

    /**
     * テストケース　testOnAfterInsert_01
     * 
     * 【準備】
     *  部門管理者ユーザで操作する
     *  取引先（事業所）、地域、案件を作成する
     * 
     * 【テスト実行】
     *  SR情報.案件に作成した案件を設定する
     *  SR情報を作成する
     * 
     * 【期待値】
     *  案件.最終SR集計日時が更新されていること
     * 
     */
    @isTest
    static void testOnAfterInsert_01() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {

            // 取引先（事業所）
            RecordType recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and name = '事業所' LIMIT 1];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType.Id,
                OfficeName__c = 'acc1'
            );
            insert acc;

            // 地域
            Region__c region = new Region__c(
                Prefecture_kana__c = 'ホッカイドウ',
                Prefecture__c = '北海道',
                RegionCode__c = 'A1210',
                City_kana__c = 'サッポロシ',
                City__c = '札幌市',
                Region_key__c = '北海道札幌市',
                Name = '北海道札幌市'
            );
            insert region;

            // 案件
            Opportunity opp = new Opportunity(
                Name = 'Test Opp1',
                AccountId = acc.Id,
                StageName = '基本計画',
                OrderExpectation__c = '1', 
                Region__c = region.Id,
                BU__c = '',
                CloseDate = Date.today(),
                ScheduledSalesDate__c = Date.today(),
                NeedConstruction__c = '無',
                KOUJI_SYU__c = '電気工事',
                UKE_KBN__c = '元請',
                ConstructionDistinction__c = '新設',
                Handling__c = '直扱',
                InformationFrom__c = '施主',
                DemandOf__c = '官需',
                DemanDepartment__c = '官公庁',
                ExportCategory__c = '0',
                SalesTax__c = '10',
                Website__c = 1,
                Competitor__c = acc.Id,
                LastSRAggregateDate__c = Datetime.now().addMinutes(-1)
            );
            insert opp;

            // テスト開始
            Test.startTest();

            // SR情報を作成する
            SRInfo__c sr = new SRInfo__c();
            sr.SR_Number__c = 'A9999V9990';
            sr.J_Number__c = '001';
            sr.Opportunity__c = opp.Id;
            insert sr;

            // テスト終了
            Test.stopTest();

            List<Opportunity> oppList = [SELECT Id, LastSRAggregateDate__c FROM Opportunity WHERE Id =: opp.Id];

            // 検証
            System.assertEquals(1, oppList.size());
            System.assertNotEquals(null, oppList[0].LastSRAggregateDate__c);
            System.assertNotEquals(opp.LastSRAggregateDate__c, oppList[0].LastSRAggregateDate__c);
        }
    }

    /**
     * テストケース　testOnAfterInsert_02
     * 
     * 【準備】
     *  部門管理者ユーザで操作する
     *  取引先（事業所）、地域を作成する
     *  案件を２件作成する
     * 
     * 【テスト実行】
     *  SR情報.案件に作成した案件を各々設定する
     *  SR情報を２件作成する
     * 
     * 【期待値】
     *  各案件.最終SR集計日時が更新されていること
     * 
     */
    @isTest
    static void testOnAfterInsert_02() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {
            // 取引先（事業所）
            RecordType recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and name = '事業所' LIMIT 1];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType.Id,
                OfficeName__c = 'acc1'
            );
            insert acc;

            // 地域
            Region__c region = new Region__c(
                Prefecture_kana__c = 'ホッカイドウ',
                Prefecture__c = '北海道',
                RegionCode__c = 'A1210',
                City_kana__c = 'サッポロシ',
                City__c = '札幌市',
                Region_key__c = '北海道札幌市',
                Name = '北海道札幌市'
            );
            insert region;

            // 案件
            List<Opportunity> oppList = new List<Opportunity>();

            Opportunity opp1 = new Opportunity(
                Name = 'Test Opp1',
                AccountId = acc.Id,
                StageName = '基本計画',
                OrderExpectation__c = '1', 
                Region__c = region.Id,
                BU__c = '',
                CloseDate = Date.today(),
                ScheduledSalesDate__c = Date.today(),
                NeedConstruction__c = '無',
                KOUJI_SYU__c = '電気工事',
                UKE_KBN__c = '元請',
                ConstructionDistinction__c = '新設',
                Handling__c = '直扱',
                InformationFrom__c = '施主',
                DemandOf__c = '官需',
                DemanDepartment__c = '官公庁',
                ExportCategory__c = '0',
                SalesTax__c = '10',
                Website__c = 1,
                Competitor__c = acc.Id,
                LastSRAggregateDate__c = Datetime.now().addMinutes(-1)
            );
            oppList.add(opp1);

            Opportunity opp2 = new Opportunity(
                Name = 'Test Opp2',
                AccountId = acc.Id,
                StageName = '基本計画',
                OrderExpectation__c = '1', 
                Region__c = region.Id,
                BU__c = '',
                CloseDate = Date.today(),
                ScheduledSalesDate__c = Date.today(),
                NeedConstruction__c = '無',
                KOUJI_SYU__c = '電気工事',
                UKE_KBN__c = '元請',
                ConstructionDistinction__c = '新設',
                Handling__c = '直扱',
                InformationFrom__c = '施主',
                DemandOf__c = '官需',
                DemanDepartment__c = '官公庁',
                ExportCategory__c = '0',
                SalesTax__c = '10',
                Website__c = 1,
                Competitor__c = acc.Id,
                LastSRAggregateDate__c = Datetime.now().addMinutes(-2)
            );
            oppList.add(opp2);

            insert oppList;

            // テスト開始
            Test.startTest();

            // SR情報を作成する
            List<SRInfo__c> srList = new List<SRInfo__c>();

            SRInfo__c sr1 = new SRInfo__c(
                SR_Number__c = 'A9999V9990',
                J_Number__c = '001',
                Opportunity__c = opp1.Id
            );
            srList.add(sr1);

            SRInfo__c sr2 = new SRInfo__c(
                SR_Number__c = 'A9999V9991',
                J_Number__c = '002',
                Opportunity__c = opp2.Id
            );
            srList.add(sr2);

            insert srList;

            // テスト終了
            Test.stopTest();

            List<Opportunity> oppList2 = [SELECT Id, LastSRAggregateDate__c FROM Opportunity WHERE Id IN: oppList ORDER BY Name];

            // 検証
            System.assertEquals(2, oppList2.size());
            System.assertNotEquals(null, oppList2[0].LastSRAggregateDate__c);
            System.assertNotEquals(oppList[0].LastSRAggregateDate__c, oppList2[0].LastSRAggregateDate__c);
            System.assertNotEquals(null, oppList2[1].LastSRAggregateDate__c);
            System.assertNotEquals(oppList[1].LastSRAggregateDate__c, oppList2[1].LastSRAggregateDate__c);
        }
    }

    /**
     * テストケース　testOnAfterUpdate_01
     * 
     * 【準備】
     *  部門管理者ユーザで操作する
     *  取引先（事業所）、地域、案件を作成する
     *  SR情報.案件に作成した案件を設定する
     *  SR情報を作成する
     * 
     * 【テスト実行】
     *  SR情報を更新する
     * 
     * 【期待値】
     *  案件.最終SR集計日時が更新されていること
     */
    @isTest
    static void testOnAfterUpdate_01() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {

            // 取引先（事業所）
            RecordType recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and name = '事業所' LIMIT 1];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType.Id,
                OfficeName__c = 'acc1'
            );
            insert acc;

            // 地域
            Region__c region = new Region__c(
                Prefecture_kana__c = 'ホッカイドウ',
                Prefecture__c = '北海道',
                RegionCode__c = 'A1210',
                City_kana__c = 'サッポロシ',
                City__c = '札幌市',
                Region_key__c = '北海道札幌市',
                Name = '北海道札幌市'
            );
            insert region;

            // 案件
            Opportunity opp = new Opportunity(
                Name = 'Test Opp1',
                AccountId = acc.Id,
                StageName = '基本計画',
                OrderExpectation__c = '1', 
                Region__c = region.Id,
                BU__c = '',
                CloseDate = Date.today(),
                ScheduledSalesDate__c = Date.today(),
                NeedConstruction__c = '無',
                KOUJI_SYU__c = '電気工事',
                UKE_KBN__c = '元請',
                ConstructionDistinction__c = '新設',
                Handling__c = '直扱',
                InformationFrom__c = '施主',
                DemandOf__c = '官需',
                DemanDepartment__c = '官公庁',
                ExportCategory__c = '0',
                SalesTax__c = '10',
                Website__c = 1,
                Competitor__c = acc.Id,
                LastSRAggregateDate__c = Datetime.now().addMinutes(-1)
            );
            insert opp;

            // SR情報
            SRInfo__c sr = new SRInfo__c(
                SR_Number__c = 'A9999V9990',
                J_Number__c = '001',
                Opportunity__c = opp.Id
            );
            insert sr;   

            // テスト開始
            Test.startTest();

            // SR情報を更新する
            sr.AffiliationName__c = 'test';
            update sr;

            // テスト終了
            Test.stopTest();

            List<Opportunity> oppList = [SELECT Id, LastSRAggregateDate__c FROM Opportunity WHERE Id =: opp.Id];

            // 検証
            System.assertEquals(1, oppList.size());
            System.assertNotEquals(null, oppList[0].LastSRAggregateDate__c);
            System.assertNotEquals(opp.LastSRAggregateDate__c, oppList[0].LastSRAggregateDate__c);
        }
    }

    /**
     * テストケース　testOnAfterUpdate_02
     * 
     * 【準備】
     *  部門管理者ユーザで操作する
     *  取引先（事業所）、地域、案件を作成する
     *  SR情報.案件に作成した案件を設定しない
     *  SR情報を作成する
     * 
     * 【テスト実行】
     *  SR情報を更新する
     * 
     * 【期待値】
     *  案件.最終SR集計日時が更新されていないこと
     */
    @isTest
    static void testOnAfterUpdate_02() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {

            // 取引先（事業所）
            RecordType recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and name = '事業所' LIMIT 1];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType.Id,
                OfficeName__c = 'acc1'
            );
            insert acc;

            // 地域
            Region__c region = new Region__c(
                Prefecture_kana__c = 'ホッカイドウ',
                Prefecture__c = '北海道',
                RegionCode__c = 'A1210',
                City_kana__c = 'サッポロシ',
                City__c = '札幌市',
                Region_key__c = '北海道札幌市',
                Name = '北海道札幌市'
            );
            insert region;

            // 案件
            Opportunity opp = new Opportunity(
                Name = 'Test Opp1',
                AccountId = acc.Id,
                StageName = '基本計画',
                OrderExpectation__c = '1', 
                Region__c = region.Id,
                BU__c = '',
                CloseDate = Date.today(),
                ScheduledSalesDate__c = Date.today(),
                NeedConstruction__c = '無',
                KOUJI_SYU__c = '電気工事',
                UKE_KBN__c = '元請',
                ConstructionDistinction__c = '新設',
                Handling__c = '直扱',
                InformationFrom__c = '施主',
                DemandOf__c = '官需',
                DemanDepartment__c = '官公庁',
                ExportCategory__c = '0',
                SalesTax__c = '10',
                Website__c = 1,
                Competitor__c = acc.Id,
                LastSRAggregateDate__c = Datetime.now().addMinutes(-1)
            );
            insert opp;

            // SR情報（案件を設定しない）
            SRInfo__c sr = new SRInfo__c(
                SR_Number__c = 'A9999V9990',
                J_Number__c = '001',
                Opportunity__c = null
            );
            insert sr;

            // テスト開始
            Test.startTest();

            // SR情報を更新する
            sr.AffiliationName__c = 'test';
            update sr;

            // テスト終了
            Test.stopTest();

            List<Opportunity> oppList = [SELECT Id, LastSRAggregateDate__c FROM Opportunity WHERE Id =: opp.Id];

            // 検証
            System.assertEquals(1, oppList.size());
            System.assertEquals(opp.LastSRAggregateDate__c, oppList[0].LastSRAggregateDate__c);
        }
    }

    /**
     * テストケース　testOnAfterUpdate_03
     * 
     * 【準備】
     *  システム管理者ユーザで操作する
     *  取引先（事業所）、地域、案件を作成する
     *  SR情報.案件に作成した案件を設定する
     *  SR情報を作成する
     * 
     * 【テスト実行】
     *  SR情報を更新する
     * 
     * 【期待値】
     *  販事、部門管理者以外のユーザが操作した為、案件.最終SR集計日時が更新されていないこと
     */
    @isTest
    static void testOnAfterUpdate_03() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {

            // 取引先（事業所）
            RecordType recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and name = '事業所' LIMIT 1];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType.Id,
                OfficeName__c = 'acc1'
            );
            insert acc;

            // 地域
            Region__c region = new Region__c(
                Prefecture_kana__c = 'ホッカイドウ',
                Prefecture__c = '北海道',
                RegionCode__c = 'A1210',
                City_kana__c = 'サッポロシ',
                City__c = '札幌市',
                Region_key__c = '北海道札幌市',
                Name = '北海道札幌市'
            );
            insert region;

            // 案件
            Opportunity opp = new Opportunity(
                Name = 'Test Opp1',
                AccountId = acc.Id,
                StageName = '基本計画',
                OrderExpectation__c = '1', 
                Region__c = region.Id,
                BU__c = '',
                CloseDate = Date.today(),
                ScheduledSalesDate__c = Date.today(),
                NeedConstruction__c = '無',
                KOUJI_SYU__c = '電気工事',
                UKE_KBN__c = '元請',
                ConstructionDistinction__c = '新設',
                Handling__c = '直扱',
                InformationFrom__c = '施主',
                DemandOf__c = '官需',
                DemanDepartment__c = '官公庁',
                ExportCategory__c = '0',
                SalesTax__c = '10',
                Website__c = 1,
                Competitor__c = acc.Id,
                LastSRAggregateDate__c = Datetime.now().addMinutes(-1)
            );
            insert opp;

            // SR情報
            SRInfo__c sr = new SRInfo__c(
                SR_Number__c = 'A9999V9990',
                J_Number__c = '001',
                Opportunity__c = opp.Id
            );
            insert sr;   

            // テスト開始
            Test.startTest();

            // SR情報を更新する
            sr.AffiliationName__c = 'test';
            update sr;

            // テスト終了
            Test.stopTest();

            List<Opportunity> oppList = [SELECT Id, LastSRAggregateDate__c FROM Opportunity WHERE Id =: opp.Id];

            // 検証
            System.assertEquals(1, oppList.size());
            System.assertEquals(opp.LastSRAggregateDate__c, oppList[0].LastSRAggregateDate__c);
        }
    }

    /**
     * テストケース　testOnAfterDelete_01
     * 
     * 【準備】
     *  部門管理者ユーザで操作する
     *  取引先（事業所）、地域、案件を作成する
     *  SR情報.案件に作成した案件を設定する
     *  SR情報を作成する
     * 
     * 【テスト実行】
     *  SR情報を削除する
     * 
     * 【期待値】
     *  案件.最終SR集計日時が更新されていること
     * 
     */
    @isTest
    static void testOnAfterDelete_01() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = '部門管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設環境部', '第一課');
        insert user;

        System.runAs(user) {

            // 取引先（事業所）
            RecordType recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and name = '事業所' LIMIT 1];

            Account acc = new Account(
                Name = 'Test Account',
                Phone = '09011111111',
                RecordTypeId = recType.Id,
                OfficeName__c = 'acc1'
            );
            insert acc;

            // 地域
            Region__c region = new Region__c(
                Prefecture_kana__c = 'ホッカイドウ',
                Prefecture__c = '北海道',
                RegionCode__c = 'A1210',
                City_kana__c = 'サッポロシ',
                City__c = '札幌市',
                Region_key__c = '北海道札幌市',
                Name = '北海道札幌市'
            );
            insert region;

            // 案件
            Opportunity opp = new Opportunity(
                Name = 'Test Opp1',
                AccountId = acc.Id,
                StageName = '基本計画',
                OrderExpectation__c = '1', 
                Region__c = region.Id,
                BU__c = '',
                CloseDate = Date.today(),
                ScheduledSalesDate__c = Date.today(),
                NeedConstruction__c = '無',
                KOUJI_SYU__c = '電気工事',
                UKE_KBN__c = '元請',
                ConstructionDistinction__c = '新設',
                Handling__c = '直扱',
                InformationFrom__c = '施主',
                DemandOf__c = '官需',
                DemanDepartment__c = '官公庁',
                ExportCategory__c = '0',
                SalesTax__c = '10',
                Website__c = 1,
                Competitor__c = acc.Id,
                LastSRAggregateDate__c = Datetime.now().addMinutes(-1)
            );
            insert opp;

            // SR情報
            SRInfo__c sr = new SRInfo__c(
                SR_Number__c = 'A9999V9990',
                J_Number__c = '001',
                Opportunity__c = opp.Id
            );
            insert sr;

            // テスト開始
            Test.startTest();

            // SR情報を作成する
            delete sr;

            // テスト終了
            Test.stopTest();

            List<Opportunity> oppList = [SELECT Id, LastSRAggregateDate__c FROM Opportunity WHERE Id =: opp.Id];

            // 検証
            System.assertEquals(1, oppList.size());
            System.assertNotEquals(null, oppList[0].LastSRAggregateDate__c);
            System.assertNotEquals(opp.LastSRAggregateDate__c, oppList[0].LastSRAggregateDate__c);
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
}