@isTest
public class SendEmailFromRequestTaskTest {
    @testSetup
    static void setupTestData() {
        // プロファイルの取得
        Profile profile = [SELECT Id FROM Profile LIMIT 1];
        // テスト用ユーザーの作成
        User testUser = createUser(profile.Id, 'A');
        User testUser2 = createUser(profile.Id, 'B');
        User testUser3 = createUser(profile.Id, 'C');
        User testUser4 = createUser(profile.Id, 'D');
        insert new List<User>{testUser, testUser2, testUser3, testUser4};
        // テスト用アカウントの作成
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeID = '0122v000001bxUcAAI',
            OwnerId = testUser.Id
        );
        insert testAccount;
        // テスト用地域 (Region) の作成
        Region__c testRegion = new Region__c(
            Name = 'テスト地域マスタ'
        );
        insert testRegion;
        // テスト用機場 (PumpStation) の作成
        PumpStation__c testPs = new PumpStation__c(
            Name = '機場'
        );
        insert testPs;
        // テスト用社内送信先の作成
        CompanyAddress__c testCA = new CompanyAddress__c(
            Mail__c = 'test1@terraskytest.com',
            Name__c = 'テスト 社内送信先'
        );
        // テスト用社内送信先(無効)の作成
        CompanyAddress__c testCA2 = new CompanyAddress__c(
            Mail__c = 'test1@terraskytest.com',
            Name__c = 'テスト 社内送信先',
            IsActive__c = false
        );
        insert testCA;
        // テスト用案件 (Opportunity) の作成
        Opportunity testOpportunity = new Opportunity(
            Name = 'テスト案件',
            AccountId = testAccount.Id,
            StageName = '基本計画',
            OrderExpectation__c = '1',
            Region__c = testRegion.Id,
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
            PumpStation__c = testPs.Id
        );
        insert testOpportunity;
        // テスト用依頼タスク (RequestTask) メアドありverの作成
        RequestTask__c testRequestTask = new RequestTask__c(
            Name = 'テスト依頼タスク件名',
            Status__c = '依頼先対応済/依頼完了',
            DueDate__c = Date.today(),
            TaskCategory__c = '提案書作成依頼',
            RequestDestination__c = '神電',
            RequestTo__c = '神電・社会営',
            ApprovalPattern__c = '承認者自動設定',
            Opportunity__c = testOpportunity.Id,
            CompanyAddress01__c = testCA.Id,
            CompanyAddress02__c = testCA.Id,
            CompanyAddress03__c = testCA.Id,
            CompanyAddress04__c = testCA.Id,
            CompanyAddress05__c = testCA.Id,
            CompanyAddress06__c = testCA.Id,
            CompanyAddress07__c = testCA.Id,
            CompanyAddress08__c = testCA.Id,
            CompanyAddress09__c = testCA.Id,
            CompanyAddress10__c = testCA.Id,
            SharePoint_URL__c = 'https://www.terraskytest.co.jp/',
            OwnerId = testUser.Id,
            UserDeptApproved__c = true,
            DiscloseExceptRequestDestination__c = '開示不可',
            Requester__c = '本社　施設',
            SkipRequestApproval__c = true,
            RequestNotification1__c = testUser.Id,
            RequestNotification2__c = testUser2.Id,
            RequestNotification3__c = testUser3.Id,
            RequestNotification4__c = testUser4.Id
        );
        insert testRequestTask;
        // テスト用依頼タスク (RequestTask) メアドなしverの作成
        RequestTask__c testRequestTaskNoEmail = new RequestTask__c(
            Name = 'テスト依頼タスクメアドなし',
            Status__c = '依頼作成',
            DueDate__c = Date.today(),
            TaskCategory__c = '提案書作成依頼',
            RequestDestination__c = '神電',
            RequestTo__c = '神電・社会営',
            ApprovalPattern__c = '承認者自動設定',
            Opportunity__c = testOpportunity.Id,
            CompanyAddress01__c = testCA2.Id,
            SharePoint_URL__c = 'https://www.terraskytest.co.jp/',
            OwnerId = testUser.Id,
            UserDeptApproved__c = true,
            DiscloseExceptRequestDestination__c = '開示不可',
            Requester__c = '本社　施設'
        );
        insert testRequestTaskNoEmail;
    }

    @isTest
    static void testSendEmail() {
        // テストデータの取得
        RequestTask__c testRequestTask = [SELECT Id, Opportunity__r.Name, SharePoint_URL__c FROM RequestTask__c LIMIT 1];
        // テスト対象メソッドの呼び出し
        List<Id> requestTaskIds = new List<Id>{ testRequestTask.Id };
        Test.startTest();
        Integer emailSendLimitBefore = Limits.getEmailInvocations();
        SendEmailFromRequestTask.sendEmails(requestTaskIds);
        Integer emailSendLimitAfter = Limits.getEmailInvocations();
        Test.stopTest();
        // 検証: メールが1件送信されたことを確認
        System.assertEquals(emailSendLimitBefore + 1, emailSendLimitAfter, 'Expected one email to be sent.');
    }

    @isTest
    static void testSendEmailNoRecipients() {
        // テストデータの取得
        RequestTask__c testRequestTaskNoEmail = [SELECT Id, Opportunity__r.Name, SharePoint_URL__c FROM RequestTask__c WHERE Name = 'テスト依頼タスクメアドなし' LIMIT 1];
        // テスト対象メソッドの呼び出し
        List<Id> requestTaskNoEmailIds = new List<Id>{ testRequestTaskNoEmail.Id };
        Test.startTest();
        Integer emailSendLimitBefore = Limits.getEmailInvocations();
        SendEmailFromRequestTask.sendEmails(requestTaskNoEmailIds);
        Integer emailSendLimitAfter = Limits.getEmailInvocations();
        Test.stopTest();
        // 検証: メールが送信されないことを確認
        System.assertEquals(emailSendLimitBefore, emailSendLimitAfter, 'Expected one email to be sent.');
    }

    static User createUser (Id profileId, String namePrefix) {
        User testUser = new User(
            FirstName = 'test',
            LastName = namePrefix,
            Email = namePrefix + 'test@terraskytest.com',
            UserName = namePrefix + 'testusername@terraskytest.com',
            EmailEncodingKey = 'UTF-8',
            Alias = namePrefix + 'test' + String.valueOf(Datetime.now().second()),
            TimeZoneSidKey = 'Asia/Tokyo',
            LocaleSidKey = 'ja_JP',
            LanguageLocaleKey = 'ja',
            ProfileId = profileId,
            IsActive = true,
            Division = '本社　施設・二'
        );
        return testUser;
    }
}