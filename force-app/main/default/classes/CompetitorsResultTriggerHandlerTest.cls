/**
 * 競合結果トリガハンドラのテスト
 */
@isTest
public without sharing class CompetitorsResultTriggerHandlerTest {

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

    public static SupplySite__c createSupplySite() {
        SupplySite__c supplySite = new SupplySite__c(Name='テスト納入サイト', SBU__c='建設防災');
        insert supplySite;
        return supplySite;
    }

    public static Opportunity createOpportunity(Date closeDate) {
        Opportunity opps = new Opportunity(
            StageName = '価格交渉 伺い準備・伺い',
            ForecastCategoryName = 'Best Case',
            Name = 'テスト案件',
            ConstructionDistinction__c = '更新（自社既設）',
            EstablishedCompany__c = '三菱',
            SupplySite__c = createSupplySite().id,
            CloseDate = closeDate
        );
        insert opps;
        return opps;
    }

    public static QuoteBiddingInquiry__c createQuoteBiddingInquiry(Account lastCustomer, Opportunity opps) {

        // レコードタイプを取得
        Schema.SObjectType qbiType = QuoteBiddingInquiry__c.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('応札伺い').getRecordTypeId();

        QuoteBiddingInquiry__c qbi = new QuoteBiddingInquiry__c();
        qbi.Creating__c = true;
        qbi.NewChanged__c = '新規';
        qbi.ContractAmountMax__c = 6000000;
        qbi.ContractAmountMin__c = 2000000;
        qbi.Agency1_BaseFunction_EvPoint__c = 30;
        qbi.Agency1_PlatformFunction_EvPoint__c = 20;
        qbi.Agency1TradingStyle__c = '委嘱';
        qbi.Agency1Qualification__c = '特約店';
        qbi.Factor_PriceExponential__c = 'TC以上';
        
        qbi.Agency2_BaseFunction_EvPoint__c = 30;
        qbi.Agency2_PlatformFunction_EvPoint__c = 20;
        qbi.Agency2TradingStyle__c = '協力';
        qbi.Agency2Qualification__c = '特約店';
        
        qbi.Agency3_BaseFunction_EvPoint__c = 30;
        qbi.Agency3_PlatformFunction_EvPoint__c = 20;
        qbi.Agency3TradingStyle__c = '協力';
        qbi.Agency3Qualification__c = '代理店';
        qbi.RecordTypeId = qbiRecordTypeId;
        qbi.ICPReviewTarget__c = true;
        qbi.IcpExaminationGrConfirmation__c = true;

        qbi.LastCustomerCategory__c = '継続顧客・継続部門';
        qbi.BusinessCategory__c = '新規・拡販事業';
        qbi.LastCustomer__c = lastCustomer.Id;
        qbi.Opportunity__c = opps.Id;
        insert qbi;
        return qbi;
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
     * - 事前に案件/伺いが存在している
     *
     * 期待結果:
     * - 案件/伺いへの更新処理は実行されない
     */
    @isTest
    public static void onInsert_NothingToDo_onNoWinners() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            // 事前に案件/伺いが存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            QuoteBiddingInquiry__c qbi = createQuoteBiddingInquiry(accounts[0], opps);
        
            // 引数
            List<CompetitorsResult__c> competitors = new List<CompetitorsResult__c> {
                new CompetitorsResult__c(
                    Account__c = accounts[1].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8000000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[2].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社2',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8200000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[3].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社3',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 7600000
                )
            };
        
            // 実行
            Test.startTest();
            insert competitors;
            Test.stopTest();
        }
    }

    /**
     * onInsert: 落札者が複数発生することは許容しない
     *
     * 引数:
     * - 落札者=true が複数存在する
     *
     * 条件:
     * - 事前に案件/伺いが存在している
     *
     * 期待結果:
     * - 例外が発生し、保存に失敗している
     */
    @isTest
    public static void onInsert_Failed_onMultiWinners() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            // 事前に案件/伺いが存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            QuoteBiddingInquiry__c qbi = createQuoteBiddingInquiry(accounts[0], opps);
        
            // 引数
            List<CompetitorsResult__c> competitors = new List<CompetitorsResult__c> {
                new CompetitorsResult__c(
                    Account__c = accounts[1].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8000000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[2].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社2',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8200000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[3].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
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
            List<AggregateResult> aggregate = [SELECT COUNT(Id) cnt FROM CompetitorsResult__c];
            System.assertEquals(0, (Integer) aggregate[0].get('cnt'));
        }
    }

    /**
     * onInsert: 落札者が存在するとき、その値が伺い/案件に書き込まれる。
     *
     * 引数:
     * - 落札者=true が一人だけ存在する
     *
     * 条件:
     * - 事前に案件/伺いが存在している
     *
     * 期待結果:
     * - 落札の情報が案件/伺いにコピーされる
     */
    @isTest
    public static void onInsert_Success_onExistsWinner() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            // 事前に案件/伺いが存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            QuoteBiddingInquiry__c qbi = createQuoteBiddingInquiry(accounts[0], opps);
        
            // 引数
            List<CompetitorsResult__c> competitors = new List<CompetitorsResult__c> {
                new CompetitorsResult__c(
                    Account__c = accounts[1].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8000000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[3].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社3',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 7600000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[2].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社2',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8200000
                )
            };

            // 実行
            Test.startTest();
            insert competitors;
            Test.stopTest();
        }
    }

    /**
     * onInsert: 落札者が三菱電機株式会社の場合、当社応札金額に設定される。
     *
     * 引数:
     * - 落札者=true が一人だけ存在する
     *
     * 条件:
     * - 事前に案件/伺いが存在している
     *
     * 期待結果:
     * - 落札の情報が案件/伺いにコピーされる
     */
    @isTest
    public static void onInsert_Success_withMitsubishiElectronics() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設部', '第一課');
        insert user;

        System.runAs(user) {
            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            // 事前に案件/伺いが存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            QuoteBiddingInquiry__c qbi = createQuoteBiddingInquiry(accounts[0], opps);
        
            // 引数
            List<CompetitorsResult__c> competitors = new List<CompetitorsResult__c> {
                new CompetitorsResult__c(
                    Account__c = accounts[1].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8000000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[3].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社3',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 7600000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[0].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = '三菱電機株式会社',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8200002
                )
            };

            // 実行
            Test.startTest();
            insert competitors;
            Test.stopTest();
        }
    }

    /**
     * onInsert: 落札者が「その他」の場合、競争先（手入力）が必須となる
     *
     * 引数:
     * - 落札者=true が一人だけ存在する
     *
     * 条件:
     * - 事前に案件/伺いが存在している
     *
     * 期待結果:
     * - 競争先（手入力）が必須エラーとなる
     */
    @isTest
    public static void onInsert_Error_CompetitorManual() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設部', '第一課');
        insert user;

        System.runAs(user) {
            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            // 事前に案件/伺いが存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            QuoteBiddingInquiry__c qbi = createQuoteBiddingInquiry(accounts[0], opps);
        
            // 引数
            List<CompetitorsResult__c> competitors = new List<CompetitorsResult__c> {
                new CompetitorsResult__c(
                    Account__c = accounts[4].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = null,
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8000000
                )
            };

            // 引数
            List<CompetitorsResult__c> competitors2 = new List<CompetitorsResult__c> {
                new CompetitorsResult__c(
                    Account__c = accounts[4].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
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
                    insert competitors2;
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
     * - 事前に案件/伺いが存在している
     *
     * 期待結果:
     * - 更新時点で、落札者/落札金額が 伺い/案件 に転記される。
     */
    @isTest
    public static void onUpdate_Success_withWinner() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            // 事前に案件/伺いが存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            QuoteBiddingInquiry__c qbi = createQuoteBiddingInquiry(accounts[0], opps);
        
            // 引数
            List<CompetitorsResult__c> competitors = new List<CompetitorsResult__c> {
                new CompetitorsResult__c(
                    Account__c = accounts[1].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = false,
                    FirstBidAmount__c = 8000000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[2].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社2',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8000000
                ),
                new CompetitorsResult__c(
                    Account__c = accounts[3].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
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
     * - 事前に案件/伺いが存在している
     *
     * 期待結果:
     * - upsert 分は失敗する
     */
    @isTest
    public static void onUpdate_Failure_withMultiWinners() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = '01_ファシリティインフラシステム事業部' LIMIT 1];
        User user = createUser(prof.Id, role.Id, 'terrasky-melco-admin', '官需', '01_本社', '施設部', '第一課');
        insert user;

        System.runAs(user) {

            // 条件
            List<Account> accounts = createAccounts();
            List<Property__c> properties = createProperties(accounts);
            // 事前に案件/伺いが存在している
            Date today = Date.today();
            Opportunity opps = createOpportunity(today.addMonths(2));
            QuoteBiddingInquiry__c qbi = createQuoteBiddingInquiry(accounts[0], opps);
        
            // 引数
            List<CompetitorsResult__c> competitors = new List<CompetitorsResult__c> {
                new CompetitorsResult__c(
                    Account__c = accounts[1].Id,
                    QuoteBiddingInquiry__c = qbi.Id,
                    CompetitorManual__c = 'テスト株式会社1',
                    IsWinBidder__c = true,
                    FirstBidAmount__c = 8000000
                )
            };
            insert competitors;

            competitors.add(new CompetitorsResult__c(
                Account__c = accounts[1].Id,
                QuoteBiddingInquiry__c = qbi.Id,
                CompetitorManual__c = 'テスト株式会社2',
                IsWinBidder__c = true,
                FirstBidAmount__c = 8200000
            ));
            competitors.add(new CompetitorsResult__c(
                Account__c = accounts[1].Id,
                QuoteBiddingInquiry__c = qbi.Id,
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
            List<CompetitorsResult__c> result = [SELECT Id, Account__c FROM CompetitorsResult__c];
            System.assertEquals(1, result.size());
            System.assertEquals(competitors[0].Id, result[0].Id);
            System.assertEquals(accounts[1].Id, result[0].Account__c);
        }
    }
}