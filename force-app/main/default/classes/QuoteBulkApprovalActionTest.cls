@isTest private class  QuoteBulkApprovalActionTest {
    @isTest
    private static void testBulkApproval(){

        // テストデータの用意
        User user = createUser('販事');
        insert user;
        
        Account acc = createOfficeAccount();
        insert acc;

        Region__c region = createRegion();
        insert region;

        PumpStation__c ps = createPumpStation();
        ps.UniqueKey__c = String.valueOf(Datetime.now()) + 'testApprovalRequest001';
        insert ps;

        Opportunity opp = createOpportunity(acc, region, ps);
        insert opp;
        
        Factory__c fc = createFactory(opp);
        insert fc;

        QuoteBiddingInquiry__c qbiOld = createTestQuoteBiddingInquiry();
        qbiOld.InquiryApprovalStatus__c = '未申請'; // 初期状態
        qbiOld.LastCustomerCategory__c = '継続顧客・継続部門';
        qbiOld.Opportunity__c = opp.Id;
        qbiOld.BU__c = '水環境';
        qbiOld.SBU__c = '上水';
        qbiOld.ExistingEquipment1__c = '監視制御';
        qbiOld.PublicOrPrivateDemand__c = '民需';
        qbiOld.SpecialInprofitProject__c = false;
        qbiOld.AdditionalPostInquiryApplication__c = false;
        qbiOld.ApprovalPattern__c = '手動設定';
        qbiOld.Approver1__c = user.Id;
        
        insert qbiOld;

        QuoteBulkApprovalAction.Input param = new QuoteBulkApprovalAction.Input();
        param.recordIds = new List<Id>();
        param.recordIds.add(qbiOld.Id);
        List<QuoteBulkApprovalAction.Result> result = new List<QuoteBulkApprovalAction.Result>();

        // 承認申請を実行
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(qbiOld.Id);
        Approval.ProcessResult processResult = Approval.process(req);

        result = QuoteBulkApprovalAction.bulkApproval(new List<QuoteBulkApprovalAction.Input>{ param });
        Assert.areEqual(result.get(0).success, true);
    }
    
    /**
     * レコードタイプが事業所(Office)の取引先作成
     * @return 取引先
     */
    private static Account createOfficeAccount(){

        // レコードタイプIDを取得
        Schema.DescribeSObjectResult result = Account.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> recTypeInfo = result.getRecordTypeInfos();
        String recTypeOfficeId = '';
        for(Schema.RecordTypeInfo info : recTypeInfo){
            if(info.getDeveloperName() == 'Office'){
                recTypeOfficeId = info.getRecordTypeId();
            }
            if(!String.isBlank(recTypeOfficeId)){
                break;
            }
        }

        Account acc = new Account(
            Name = 'テスト取引先',
            RecordTypeId = recTypeOfficeId
        );
        return acc;
    }

    /**
     * 地域マスタ作成
     * @return 地域マスタ
     */
    private static Region__c createRegion(){

        Region__c region = new Region__c(
            Name = 'テスト地域マスタ'
        );
        return region;
    }

    /**
     * 機場作成
     * @return 機場
     */
    private static PumpStation__c createPumpStation(){

        PumpStation__c ps = new PumpStation__c(
            Name = '機場'
        );
        return ps;
    }

    /**
     * 案件作成
     * @param Account acc
     * @param Region__c region
     * @return 案件
     */
    private static Opportunity createOpportunity(Account acc, Region__c region, PumpStation__c ps){

        Opportunity opp = new Opportunity(
            Name = 'テスト案件',
            AccountId = acc.Id,
            StageName = '基本計画',
            OrderExpectation__c = '1',
            Region__c = region.Id,
            BU__c = '水環境',
            SBU__c = '上水',
            Plant__c = '上水既存',
            CloseDate = Date.today(),
            ScheduledSalesDate__c = Date.today(),
            NeedConstruction__c = '無',
            KOUJI_SYU__c = '電気工事',
            UKE_KBN__c = '元請',
            ConstructionDistinction__c = '新設',
            Handling__c = '直扱',
            DemandOf__c = '民需',
            InformationFrom__c = '施主',
            DemanDepartment__c = '官公庁',
            ExportCategory__c = '0 国内',
            PumpStation__c = ps.Id
        );
        return opp;
    }
    
    /**
     * 場所別作成
     * @return 場所別
     */
    private static Factory__c createFactory(Opportunity opp){

        Factory__c Fac01 = new Factory__c(
            Opp1__c = opp.Id,
            CommonRatio1__c= '31% ： 製作所',
            BU__c='水環境',
            CarryingDay__c=Date.today()+10,
            SR_CP__c                 = 200, 
            SRWC__c                  = 100,
            Factory__c               = '神電'        
        );
        return Fac01;
    }

    /**
     * 見積・応札伺い作成
     */
    private static QuoteBiddingInquiry__c createTestQuoteBiddingInquiry() {
        // レコードタイプを取得
        Schema.SObjectType qbiType = QuoteBiddingInquiry__c.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('応札伺い').getRecordTypeId();

        QuoteBiddingInquiry__c qbi = new QuoteBiddingInquiry__c();
        qbi.Creating__c = true;
        qbi.NewChanged__c = '新規';
        qbi.RecordTypeId = qbiRecordTypeId;
        return qbi;
    }

    /**
     * ユーザの作成
     * @param profileName プロファイル名
     * @return ユーザ
     */
    private static User createUser(String profileName){

        // プロファイル
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        
        // ユーザ
        User mgrUser = new User();
        mgrUser.FirstName = 'test';                                             // 名
        mgrUser.LastName = 'test';                                              // 姓
        mgrUser.Email = String.valueOf(Date.today()) + '@example.co.jp.mgr';      // メール
        mgrUser.UserName = mgrUser.Email;                                       // ユーザ名
        mgrUser.EmailEncodingKey = 'UTF-8';                                     // メールの文字コード
        mgrUser.Alias = 'test'+String.valueOf(Datetime.now().second());                    // 別名
        mgrUser.TimeZoneSidKey = 'Asia/Tokyo';                                  // タイムゾーン
        mgrUser.LocaleSidKey = 'ja_JP';                                         // 地域
        mgrUser.LanguageLocaleKey = 'ja';                                       // 言語
        mgrUser.ProfileId = profile.Id;                                         // プロファイルID
        mgrUser.isActive = true;
        mgrUser.Division = '本社　施設・二';
        insert mgrUser;

        // ユーザ
        User objUser = new User();
        objUser.FirstName = 'test';                                             // 名
        objUser.LastName = 'test';                                              // 姓
        objUser.Email = String.valueOf(Date.today()) + '@example.co.jp';      // メール
        objUser.UserName = objUser.Email;                                       // ユーザ名
        objUser.EmailEncodingKey = 'UTF-8';                                     // メールの文字コード
        objUser.Alias = 'test'+String.valueOf(Datetime.now().second());                    // 別名
        objUser.TimeZoneSidKey = 'Asia/Tokyo';                                  // タイムゾーン
        objUser.LocaleSidKey = 'ja_JP';                                         // 地域
        objUser.LanguageLocaleKey = 'ja';                                       // 言語
        objUser.ProfileId = profile.Id;                                         // プロファイルID
        objUser.isActive = true;
        objUser.Division = '本社　施設・二';
        objUser.ManagerId = mgrUser.Id;
        return objUser;
    }
}