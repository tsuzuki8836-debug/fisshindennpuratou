/**
 * 組織上に存在する非公開グループを取得するため、(SeeAllData=true)を付与している
 */
@isTest(SeeAllData=true)
private class RequestTaskTriggerHandlerTest {

    /**
     * 依頼タスクを作成後、承認申請を行う。
     * 承認経路パターンは3に該当するよう作成。
     * 期待値: レコードロックが解除されていること。
     */
    @isTest
    private static void testApprovalRequest001(){

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

        Test.startTest();
        // 承認申請を実行
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(rt.Id);
        Approval.ProcessResult processResult = Approval.process(req);
        Test.stopTest();

        System.assertEquals(Approval.isLocked(rt.id), false, '承認申請時のレコードロックが解除されている');
    }

    /**
     * 依頼タスクを作成後、申請者のメールアドレス項目以外の項目の更新を行う。
     * 期待値: レコードロックがされていないこと。
     */
    @isTest
    private static void testUpdate001(){

        // テストデータの用意
        Account acc = createOfficeAccount();
        insert acc;

        Region__c region = createRegion();
        insert region;

        PumpStation__c ps = createPumpStation();
        ps.UniqueKey__c = String.valueOf(Datetime.now()) + 'testUpdate001';
        insert ps;

        Opportunity opp = createOpportunity(acc, region, ps);
        insert opp;

        RequestTask__c rt = createRequestTask(opp);
        rt.Applicant__c = UserInfo.getUserId();
        insert rt;

        Test.startTest();
        rt.Name = '件名変更';
        rt.Applicant__c = null; // 初期化
        update rt;
        Test.stopTest();

        System.assertEquals(Approval.isLocked(rt.id), false, 'レコードロックがされていない');
    }

    /**
     * 依頼タスクを作成後、承認申請を行う。
     * 承認経路パターンは3に該当するよう作成。
     * レコードロック処理内で例外を発生させる。
     * 期待値: レコードロックが解除されていないこと。
     */
    @isTest
    private static void testApprovalRequestError001(){

        // 販事ユーザを作成
        User u = createUser('販事');
        insert u;

        // 「神電施設エンジ」非公開グループを取得
        CollaborationGroup cg = getCollaborationGroup('テストグループ');
        // ユーザをグループに追加
        CollaborationGroupMember groupMember = new CollaborationGroupMember();
        groupMember.memberid = u.Id;
        groupMember.CollaborationGroupId = cg.Id;
        insert groupMember;

        System.runAs(u){
            // テストデータの用意
            Account acc = createOfficeAccount();
            insert acc;

            Region__c region = createRegion();
            insert region;

            PumpStation__c ps = createPumpStation();
            ps.UniqueKey__c = String.valueOf(Datetime.now()) + 'testApprovalRequestError001';
            insert ps;

            Opportunity opp = createOpportunity(acc, region, ps);
            insert opp;

            RequestTask__c rt = createRequestTask(opp);
            insert rt;

            // 例外発生フラグをtrueにする
            RequestTaskTriggerHandler.errorHappenFlg = true;

            // 承認申請を実行
            try{
                Test.startTest();
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(rt.Id);
                Approval.ProcessResult processResult = Approval.process(req);
                Test.stopTest();
            } catch (Exception e){
                // ここに入ってきている時点で例外が発生している
                System.assert(true);
            }
        }
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

        RequestTask__c rt = new RequestTask__c(
            Name = 'テスト依頼タスク件名',
            Status__c = '依頼作成',
            TaskCategory__c = '提案書作成依頼',
            DueDate__c = Date.today(),
            RequestDestination__c = '神電',
            RequestTo__c = '神電・社会営',
            ApprovalPattern__c = '承認者自動設定',
            Opportunity__c = opp.Id,
            Requester__c = '本社　施設・二',
            UserDeptApproved__c = true,
            RequestDestinationCc__c = '神電'
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

    /**
     * Chatterグループ作成
     * @param groupName Chatterグループ名
     * @return グループ
     */
    private static CollaborationGroup getCollaborationGroup(String groupName){

        CollaborationGroup cGroup = new CollaborationGroup(
            Name = groupName,
            CollaborationType = 'Private'
        );
        insert cGroup;

        List<CollaborationGroup> cg = [SELECT Id FROM CollaborationGroup WHERE Name = :groupName LIMIT 1];
        if(cg.size() > 0){
            return cg[0];
        }
        return null;
    }
}