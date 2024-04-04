/**
 * 競争先トリガハンドラのテスト
 */
@isTest
public with sharing class CompetitorTriggerHandlerTest {

    public static List<Account> createAccounts() {
        // レコードタイプ=事業所
        String rcdTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Office').getRecordTypeId();
        // 統一企業コード（三菱電機株式会社）
        String companyCode = System.Label.COMPANY_CODE_MITSUBISHI;
        // 取引先
        List<Account> accounts = new List<Account> {
            new Account(Name = '三菱電機株式会社', RecordTypeId = rcdTypeId, MelcoCode__c = companyCode),
            new Account(Name = 'テスト株式会社1', RecordTypeId = rcdTypeId),
            new Account(Name = 'テスト株式会社2', RecordTypeId = rcdTypeId),
            new Account(Name = 'テスト株式会社3', RecordTypeId = rcdTypeId),
            new Account(Name = 'その他', RecordTypeId = rcdTypeId)
        };
        insert accounts;
        return accounts;
    }

    public static List<Property__c> createProperties(List<Account> accounts) {
        List<Property__c> properties = new List<Property__c> ();
        for (Account acc : accounts) {
            properties.add(new Property__c(Client__c = acc.Id));
        }
        insert properties;
        return properties;
    }

    public static List<PumpStation__c> createPumpStations() {
        List<PumpStation__c> stations = new List<PumpStation__c> {
            new PumpStation__c(Name='テスト機場', Prefecture__c='北海道') 
        };
        insert stations;
        return stations;
    }

    public static List<Region__c> createRegions() {
        List<Region__c> regions = new List<Region__c> {
            new Region__c(
                Prefecture_kana__c = 'ホッカイドウ',
                Prefecture__c='北海道',
                RegionCode__c='0900013',
                City_kana__c='キタミシ',
                City__c='北見市',
                Region_key__c = '北海道北見市',
                Name='北海道北見市'
            )
        };
        insert regions;
        return regions;
    }

    public static SupplySite__c createSupplySite() {
        SupplySite__c supplySite = new SupplySite__c(Name='テスト納入サイト', SBU__c='建設防災');
        insert supplySite;
        return supplySite;
    }

    public static Opportunity createOpportunity(Date closeDate) {
        Opportunity opps = new Opportunity(
            StageName = '価格交渉 入札準備・入札',
            ForecastCategoryName = 'Best Case',
            Name = 'テスト案件',
            EstablishedCompany__c = '三菱',
            SupplySite__c = createSupplySite().id,
            CloseDate = closeDate
        );
        insert opps;
        return opps;
    }

    public static BidManagement__c createBidManagement(Account lastCustomer, Opportunity opps, Property__c property, Region__c region, PumpStation__c station, Date openDate, Date submitDate) {
        BidManagement__c bidManage = new BidManagement__c(
            LastCustomer__c = lastCustomer.Id,
            Opportunity__c = opps.Id,
            SupplySite__c = opps.SupplySite__c,
            Property__c = property.Id,
            PumpStation__c = station.Id,
            Region__c = region.Id,
            Plant__c = '他オゾン',
            BidMethod__c = 'その他',
            ConstructionDistinction__c = '新設',
            DemanDepartment__c = 'エネルギー事業',
            OpportunityType__c = '官・間（その他）',
            OrderExpectation__c = '1',
            SBU__c = 'オゾン',
            TenderType__c = '単独',
            BidOpenDate__c = openDate,
            SubmitDate__c = submitDate
        );
        insert bidManage;
        return bidManage;
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
     * onInsert: 落札者が設定されていない場合、単純に保存されるのみである。
     *
     * 引数:
     * - 落札者=false での新規作成時
     *
     * 条件:
     * - 事前に案件/入札が存在している
     *
     * 期待結果:
     * - 案件/入札への更新処理は実行されない
     */
    @isTest
    public static void onInsert_NothingToDo_onNoWinners() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            List<Region__c> regions = createRegions();
            List<PumpStation__c> stations = createPumpStations();

            // 事前に案件/入札が存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            BidManagement__c bidManage = createBidManagement(accounts[0], opps, properties[0], regions[0], stations[0], today.addMonths(-1), today);
        
            // 引数
            List<Competitors__c> competitors = new List<Competitors__c> {
                new Competitors__c(
                    Account__c = accounts[1].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8000000
                ),
                new Competitors__c(
                    Account__c = accounts[2].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社2',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8200000
                ),
                new Competitors__c(
                    Account__c = accounts[3].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社3',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 7600000
                )
            };
        
            // 実行
            Test.startTest();
            insert competitors;
            Test.stopTest();
        
            // 期待結果
            // 案件/入札への更新処理は実行されない
            BidManagement__c resultBid = [
                SELECT SuccessfulBidder__c, SuccessfulBidderManual__c, BidAmount__c, CompanyBidAmount__c 
                FROM BidManagement__c WHERE Id = :bidManage.Id
            ];
            System.assertEquals(null, resultBid.SuccessfulBidder__c);
            System.assertEquals(null, resultBid.SuccessfulBidderManual__c);
            System.assertEquals(null, resultBid.BidAmount__c);
            System.assertEquals(null, resultBid.CompanyBidAmount__c);
            Opportunity resultOpps = [
                SELECT Competitor__c, CompetitorOther__c, FinalPrice__c
                FROM Opportunity WHERE Id = :opps.Id
            ];
            System.assertEquals(null, resultOpps.Competitor__c);
            System.assertEquals(null, resultOpps.CompetitorOther__c);
            System.assertEquals(null, resultOpps.FinalPrice__c);
        }
    }

    /**
     * onInsert: 落札者が複数発生することは許容しない
     *
     * 引数:
     * - 落札者=true が複数存在する
     *
     * 条件:
     * - 事前に案件/入札が存在している
     *
     * 期待結果:
     * - 例外が発生し、保存に失敗している
     */
    @isTest
    public static void onInsert_Failed_onMultiWinners() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            List<Region__c> regions = createRegions();
            List<PumpStation__c> stations = createPumpStations();
            // 事前に案件/入札が存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            BidManagement__c bidManage = createBidManagement(accounts[0], opps, properties[0], regions[0], stations[0], today.addMonths(-1), today);
        
            // 引数
            List<Competitors__c> competitors = new List<Competitors__c> {
                new Competitors__c(
                    Account__c = accounts[1].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8000000
                ),
                new Competitors__c(
                    Account__c = accounts[2].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社2',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8200000
                ),
                new Competitors__c(
                    Account__c = accounts[3].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社3',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 7600000
                )
            };
        
            // 実行
            Test.startTest();
            Boolean isSuccess = false;
            try {
                insert competitors;
            } catch (DmlException except) {
                isSuccess = true;
            }
            Test.stopTest();

            // 結果検証
            // 例外が発生し、保存に失敗している
            System.assert(isSuccess, '例外が発生しているべきである');
            // 保存に失敗している
            List<AggregateResult> aggregate = [SELECT COUNT(Id) cnt FROM Competitors__c];
            System.assertEquals(0, (Integer) aggregate[0].get('cnt'));
        }
    }

    /**
     * onInsert: 落札者が存在するとき、その値が入札/案件に書き込まれる。
     *
     * 引数:
     * - 落札者=true が一人だけ存在する
     *
     * 条件:
     * - 事前に案件/入札が存在している
     *
     * 期待結果:
     * - 落札の情報が案件/入札にコピーされる
     */
    @isTest
    public static void onInsert_Success_onExistsWinner() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            List<Region__c> regions = createRegions();
            List<PumpStation__c> stations = createPumpStations();
            // 事前に案件/入札が存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            BidManagement__c bidManage = createBidManagement(accounts[0], opps, properties[0], regions[0], stations[0], today.addMonths(-1), today);
        
            // 引数
            List<Competitors__c> competitors = new List<Competitors__c> {
                new Competitors__c(
                    Account__c = accounts[1].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8000000
                ),
                new Competitors__c(
                    Account__c = accounts[2].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社2',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8200000
                ),
                new Competitors__c(
                    Account__c = accounts[3].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社3',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 7600000
                )
            };

            // 実行
            Test.startTest();
            insert competitors;
            Test.stopTest();
        
            // 期待結果
            // 落札の情報が案件/入札にコピーされる
            BidManagement__c resultBid = [
                SELECT SuccessfulBidder__c, SuccessfulBidderManual__c, BidAmount__c, CompanyBidAmount__c 
                FROM BidManagement__c WHERE Id = :bidManage.Id
            ];
            System.assertEquals(accounts[2].Id, resultBid.SuccessfulBidder__c);
            System.assertEquals('テスト株式会社2', resultBid.SuccessfulBidderManual__c);
            System.assertEquals(8200000, resultBid.BidAmount__c);
            System.assertEquals(null, resultBid.CompanyBidAmount__c, '落札したのが三菱電機株式会社ではないので処理しない');
            Opportunity resultOpps = [
                SELECT Competitor__c, CompetitorOther__c, FinalPrice__c
                FROM Opportunity WHERE Id = :opps.Id
            ];
            System.assertEquals(accounts[2].Id, resultOpps.Competitor__c);
            System.assertEquals('テスト株式会社2', resultOpps.CompetitorOther__c);
            System.assertEquals(8200000, resultOpps.FinalPrice__c);
        }
    }

    /**
     * onInsert: 落札者が三菱電機株式会社の場合、当社応札金額に設定される。
     *
     * 引数:
     * - 落札者=true が一人だけ存在する
     *
     * 条件:
     * - 事前に案件/入札が存在している
     *
     * 期待結果:
     * - 落札の情報が案件/入札にコピーされる
     */
    @isTest
    public static void onInsert_Success_withMitsubishiElectronics() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設部', '第一課');
        insert user;

        System.runAs(user) {
            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            List<Region__c> regions = createRegions();
            List<PumpStation__c> stations = createPumpStations();
            // 事前に案件/入札が存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            BidManagement__c bidManage = createBidManagement(accounts[0], opps, properties[0], regions[0], stations[0], today.addMonths(-1), today);
        
            // 引数
            List<Competitors__c> competitors = new List<Competitors__c> {
                new Competitors__c(
                    Account__c = accounts[1].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8000000
                ),
                new Competitors__c(
                    Account__c = accounts[0].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = '三菱電機株式会社',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8200000
                ),
                new Competitors__c(
                    Account__c = accounts[3].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社3',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 7600000
                )
            };

            // 実行
            Test.startTest();
            insert competitors;
            Test.stopTest();
        
            // 期待結果
            // 落札の情報が案件/入札にコピーされる
            BidManagement__c resultBid = [
                SELECT SuccessfulBidder__c, SuccessfulBidderManual__c, BidAmount__c, CompanyBidAmount__c 
                FROM BidManagement__c WHERE Id = :bidManage.Id
            ];
            System.assertEquals(accounts[0].Id, resultBid.SuccessfulBidder__c);
            System.assertEquals('三菱電機株式会社', resultBid.SuccessfulBidderManual__c);
            System.assertEquals(8200000, resultBid.BidAmount__c);
            System.assertEquals(8200000, resultBid.CompanyBidAmount__c, '落札したのが三菱電機株式会社なので、当社応札金額が設定される');
            Opportunity resultOpps = [
                SELECT Competitor__c, CompetitorOther__c, FinalPrice__c
                FROM Opportunity WHERE Id = :opps.Id
            ];
            System.assertEquals(accounts[0].Id, resultOpps.Competitor__c);
            System.assertEquals('三菱電機株式会社', resultOpps.CompetitorOther__c);
            System.assertEquals(8200000, resultOpps.FinalPrice__c);
        }
    }

    /**
     * onInsert: 落札者が「その他」の場合、競争先（手入力）が必須となる
     *
     * 引数:
     * - 落札者=true が一人だけ存在する
     *
     * 条件:
     * - 事前に案件/入札が存在している
     *
     * 期待結果:
     * - 競争先（手入力）が必須エラーとなる
     */
    @isTest
    public static void onInsert_Error_CompetitorManual() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設部', '第一課');
        insert user;

        System.runAs(user) {
            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            List<Region__c> regions = createRegions();
            List<PumpStation__c> stations = createPumpStations();
            // 事前に案件/入札が存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            BidManagement__c bidManage = createBidManagement(accounts[0], opps, properties[0], regions[0], stations[0], today.addMonths(-1), today);
        
            // 引数
            List<Competitors__c> competitors = new List<Competitors__c> {
                new Competitors__c(
                    Account__c = accounts[4].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = null,
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8000000
                )
            };

            // 実行
            Boolean isError = false;
            Test.startTest();
                try {
                    insert competitors;
                } catch(Exception e) {
                    isError = true;
                }
            Test.stopTest();
        
            // 期待結果
            // エラーになる
            System.assertEquals(true, isError);
        }
    }

    /**
     * Update: 落札者フラグが更新された際に、転記処理が実行される
     *
     * 引数:
     * - 落札者=false での新規作成
     * - 更新更新時に 落札者=true を一つだけ追加
     *
     * 条件:
     * - 事前に案件/入札が存在している
     *
     * 期待結果:
     * - 更新時点で、落札者/落札金額が 入札/案件 に転記される。
     */
    @isTest
    public static void onUpdate_Success_withWinner() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            List<Region__c> regions = createRegions();
            List<PumpStation__c> stations = createPumpStations();
            // 事前に案件/入札が存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            BidManagement__c bidManage = createBidManagement(accounts[0], opps, properties[0], regions[0], stations[0], today.addMonths(-1), today);
        
            // 引数
            List<Competitors__c> competitors = new List<Competitors__c> {
                new Competitors__c(
                    Account__c = accounts[1].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8000000
                ),
                new Competitors__c(
                    Account__c = accounts[2].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社2',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8000000
                ),
                new Competitors__c(
                    Account__c = accounts[3].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社3',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 7600000
                )
            };
            insert competitors;

            // 更新時に落札者現れる
            competitors[0].SecondBidAmount__c = 8200000;
            competitors[1].IsWinBidder__c = true;
            competitors[1].SecondBidAmount__c = 8500000;
            competitors[2].IsDeclineSecondBid__c = true;

            // 実行
            Test.startTest();
            update competitors;
            Test.stopTest();
        
            // 結果検証
            // 落札の情報が案件/入札にコピーされる
            BidManagement__c resultBid = [
                SELECT SuccessfulBidder__c, SuccessfulBidderManual__c, BidAmount__c, CompanyBidAmount__c 
                FROM BidManagement__c WHERE Id = :bidManage.Id
            ];
            System.assertEquals(accounts[2].Id, resultBid.SuccessfulBidder__c);
            System.assertEquals('テスト株式会社2', resultBid.SuccessfulBidderManual__c);
            System.assertEquals(8500000, resultBid.BidAmount__c);
            System.assertEquals(null, resultBid.CompanyBidAmount__c, '落札したのが三菱電機株式会社ではないので処理しない');
            Opportunity resultOpps = [
                SELECT Competitor__c, CompetitorOther__c, FinalPrice__c
                FROM Opportunity WHERE Id = :opps.Id
            ];
            System.assertEquals(accounts[2].Id, resultOpps.Competitor__c);
            System.assertEquals('テスト株式会社2', resultOpps.CompetitorOther__c);
            System.assertEquals(8500000, resultOpps.FinalPrice__c);
        }
    }

    /**
     * Update: 更新時も含め、複数の落札者が要る場合は例外を発生させる
     *
     * 引数:
     * - 落札者=false での新規作成
     * - 更新＋新規で複数の落札者を作成
     *
     * 条件:
     * - 事前に案件/入札が存在している
     *
     * 期待結果:
     * - upsert 分は失敗する
     */
    @isTest
    public static void onUpdate_Failure_withMultiWinners() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_社会環境事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_社会環境事業部', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            List<Region__c> regions = createRegions();
            List<PumpStation__c> stations = createPumpStations();
            // 事前に案件/入札が存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            BidManagement__c bidManage = createBidManagement(accounts[0], opps, properties[0], regions[0], stations[0], today.addMonths(-1), today);
        
            // 引数
            List<Competitors__c> competitors = new List<Competitors__c> {
                new Competitors__c(
                    Account__c = accounts[1].Id,
                    BidManagement__c = bidManage.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8000000
                )
            };
            insert competitors;

            competitors.add(new Competitors__c(
                Account__c = accounts[1].Id,
                BidManagement__c = bidManage.Id,
                CompetitorManual__c = 'テスト株式会社2',
                IsWinBidder__c = true,
                FirstBidAmount__c = 8200000
            ));
            competitors.add(new Competitors__c(
                Account__c = accounts[1].Id,
                BidManagement__c = bidManage.Id,
                CompetitorManual__c = 'テスト株式会社3',
                IsWinBidder__c = false,
                FirstBidAmount__c = 7600000
            ));
        
            // 実行
            Test.startTest();
            Boolean isSuccess = false;
            try {
                insert competitors;
            } catch (DmlException except) {
                isSuccess = true;
            }
            Test.stopTest();
        
            // 結果検証
            // 例外が発生し、保存に失敗している
            System.assert(isSuccess);
            // 保存に失敗している(事前に保存していたレコードしか存在しない)
            List<Competitors__c> result = [SELECT Id, Account__c FROM Competitors__c];
            System.assertEquals(1, result.size());
            System.assertEquals(competitors[0].Id, result[0].Id);
            System.assertEquals(accounts[1].Id, result[0].Account__c);
        }
    }

}