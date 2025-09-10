@isTest private class  BulkApprovalActionTest {
    @isTest
    private static void testBulkApproval(){

        // テストデータの用意
        Account acc = createOfficeAccount();
        insert acc;

        Region__c region = createRegion();
        insert region;

        PumpStation__c ps = createPumpStation();
        ps.UniqueKey__c = String.valueOf(Datetime.now()) + 'testApprovalRequest001';
        insert ps;

        Opportunity opp = createOpportunity(acc, region, ps);
        insert opp;

        RequestTask__c rt = createRequestTask(opp);
        insert rt;

        BulkApprovalAction.Input param = new BulkApprovalAction.Input();
        param.recordIds = new List<Id>();
        param.recordIds.add(rt.Id);
        List<BulkApprovalAction.Result> result = new List<BulkApprovalAction.Result>();

        // 承認申請を実行
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(rt.Id);
        Approval.ProcessResult processResult = Approval.process(req);

        result = BulkApprovalAction.bulkApproval(new List<BulkApprovalAction.Input>{ param });
        Assert.areEqual(result.get(0).success, true);
    }

    // @isTest
    // private static void testBulkApprovalFail(){

    //     // テストデータの用意
    //     Account acc = createOfficeAccount();
    //     insert acc;

    //     Region__c region = createRegion();
    //     insert region;

    //     PumpStation__c ps = createPumpStation();
    //     ps.UniqueKey__c = String.valueOf(Datetime.now()) + 'testApprovalRequest001';
    //     insert ps;

    //     Opportunity opp = createOpportunity(acc, region, ps);
    //     insert opp;

    //     RequestTask__c rt = createRequestTask(opp);
    //     insert rt;

    //     BulkApprovalAction.Input param = new BulkApprovalAction.Input();
    //     param.recordIds = new List<Id>();
    //     // 例外を発生させるために違うオブジェクトのIDを設定
    //     param.recordIds.add(acc.Id);
    //     List<BulkApprovalAction.Result> result = new List<BulkApprovalAction.Result>();

    //     // 承認申請を実行
    //     Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    //     req.setObjectId(rt.Id);
    //     Approval.ProcessResult processResult = Approval.process(req);

    //     result = BulkApprovalAction.bulkApproval(new List<BulkApprovalAction.Input>{ param });
    //     Assert.areEqual(result.get(0).success, false);
    // }

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
            DemandOf__c = '官需',
            InformationFrom__c = '施主',
            DemanDepartment__c = '官公庁',
            ExportCategory__c = '0 国内',
            PumpStation__c = ps.Id
        );
        return opp;
    }

    /**
     * 依頼タスク作成
     * @param Opportunity opp
     * @return 依頼タスク
     */
    private static RequestTask__c createRequestTask(Opportunity opp){
        // 販事ユーザを作成
        User u = createUser('販事');
        insert u;

        RequestTask__c rt = new RequestTask__c(
            Name = 'テスト依頼タスク件名',
            Status__c = '依頼作成',
            TaskCategory__c = '提案書作成依頼',
            DueDate__c = Date.today(),
            RequestDestination__c = '神電',
            DiscloseExceptRequestDestination__c = '開示不可',
            ApprovalPattern__c = '承認者手動設定',
            Opportunity__c = opp.Id,
            Requester__c = '本社　施設',
            UserDeptApproved__c = true,
            RequestApprover1__c = u.Id
        );
        return rt;
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
        return objUser;
    }
}