@IsTest
public class QuoteBiddingInquiryHandlerTest {

    private static final Profile PROFILE_SYS = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
    private static User testManager;
    private static User testManager2;
    private static User testUser;
    
    // テスト用のQuoteBiddingInquiry__cレコードを作成するヘルパーメソッド
    private static QuoteBiddingInquiry__c createTestQuoteBiddingInquiry() {

        // レコードタイプを取得
        Schema.SObjectType qbiType = QuoteBiddingInquiry__c.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('手数料伺い').getRecordTypeId();
        Id qbiRecordTypeId2 = qbiRecordTypes.get('応札伺い').getRecordTypeId();

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
        insert qbi;

        QuoteBiddingInquiry__c qbi2 = new QuoteBiddingInquiry__c();
        qbi2.Creating__c = true;
        qbi2.NewChanged__c = '新規';
        qbi2.RecordTypeId = qbiRecordTypeId2;
        qbi2.ICPReviewTarget__c = true;
        qbi2.IcpExaminationGrConfirmation__c = true;
        qbi2.DependentFeeInquiry__c = qbi.id;
        return qbi2;
    }

    private static QuoteBiddingInquiry__c createTestQuoteBiddingInquiry2() {

        // レコードタイプを取得
        Schema.SObjectType qbiType = QuoteBiddingInquiry__c.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('手数料伺い').getRecordTypeId();
        Id qbiRecordTypeId2 = qbiRecordTypes.get('応札伺い').getRecordTypeId();

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
        return qbi;
    }

    @IsTest
    static void testUpdateFormulaFields() {
        // テスト用のQuoteBiddingInquiry__cレコードを作成
        QuoteBiddingInquiry__c qbiOld = createTestQuoteBiddingInquiry();
        qbiOld.InquiryApprovalStatus__c = '未申請'; // 初期状態
        qbiOld.IcpExaminationGrConfirmation__c = true;
        insert qbiOld;

        // レコードタイプを取得
        Schema.SObjectType qbiType = Account.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('事業所').getRecordTypeId();

        // 取引先を作成
        Account acc = new Account(
            Name = 'テスト取引先',
            RecordTypeId = qbiRecordTypeId
        );
        insert acc;

        PumpStation__c ps = new PumpStation__c(
            Name = 'ポンプ場'
        );
        insert ps;

        // 商談を作成
        Opportunity opp = new Opportunity(
            Name = '受付未承認',
            AccountId = acc.Id,
            StageName = '基本計画',
            ConstructionDistinction__c = '更新（自社既設）',
            BU__c = '水環境',
            SBU__c = '上水',
            EstablishedCompany__c = '三菱',
            Probability1__c = 100,
            PumpStation__c = ps.Id,
            CloseDate = Date.Today()
        );
        insert opp; 

        // 更新前のレコードマップを取得
        Map<Id, QuoteBiddingInquiry__c> oldMap = new Map<Id, QuoteBiddingInquiry__c>{qbiOld.Id => qbiOld};

        // 新しい状態をシミュレートするためのレコードを作成
        QuoteBiddingInquiry__c qbiNew = [SELECT Id, InquiryApprovalStatus__c, ResultContactStatus__c FROM QuoteBiddingInquiry__c WHERE Id = :qbiOld.Id];
        qbiNew.InquiryApprovalStatus__c = 'TL'; // 状態を変更
        qbiOld.IcpExaminationGrConfirmation__c = false;
        
        Test.startTest();

        update qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.ContractAmountMax__c = 2000000;
        qbiNew.ContractAmountMin__c = 2000000;
        qbiNew.BusinessCategory__c = '既存事業';
        qbiNew.Opportunity__c = opp.Id;
        insert qbiNew;

        opp.ConstructionDistinction__c = '更新（他社既設）';
        update opp;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.ContractAmountMax__c = 6000000;
        qbiNew.ContractAmountMin__c = 6000000;
        qbiNew.BusinessCategory__c = '既存事業';
        qbiNew.Opportunity__c = opp.Id;
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        opp.ConstructionDistinction__c = '更新（自社既設）';
        update opp;
        qbiNew.BusinessCategory__c  = '既存事業';
        qbiNew.ContractAmountMin__c = 6000000;
        qbiNew.ContractAmountMax__c = 6000000;
        qbiNew.Opportunity__c = opp.Id;
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        opp.ConstructionDistinction__c = '更新（他社既設）';
        update opp;
        qbiNew.Opportunity__c = opp.Id;
        qbiNew.BusinessCategory__c  = '既存事業';
        qbiNew.ContractAmountMin__c = 10000000;
        qbiNew.ContractAmountMax__c = 10000000;
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.LastCustomerCategory__c = '新規顧客';
        qbiNew.Opportunity__c = opp.Id;
        qbiNew.BusinessCategory__c = '新規・拡販事業';
        qbiNew.ContractAmountMin__c = 20000000;
        qbiNew.ContractAmountMax__c = 20000000;
        insert qbiNew;
        
        qbiNew = createTestQuoteBiddingInquiry2();
        opp.ConstructionDistinction__c = '更新（他社既設）';
        update opp;
        qbiNew.Opportunity__c = opp.Id;
        qbiNew.LastCustomerCategory__c = '新規顧客';
        qbiNew.Opportunity__c = opp.Id;
        qbiNew.BusinessCategory__c = '既存事業';
        qbiNew.ContractAmountMin__c = 40000000;
        qbiNew.ContractAmountMax__c = 40000000;
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.ContractAmountMax__c = 100000000;
        qbiNew.ContractAmountMin__c = 100000000;
        insert qbiNew;
        
        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.ContractAmountMax__c = 100000001;
        qbiNew.ContractAmountMin__c = 100000001;
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.InquiryApprovalStatus__c = '事管推部長';
        insert qbiNew;

        qbiNew.ICPReviewTarget__c = true;
        qbiNew.IcpExaminationGrConfirmation__c = false;
        qbiNew.InquiryApprovalStatus__c = 'GM';
        update qbiNew;

        Test.stopTest();
    }

    @IsTest
    static void testUpdateFormulaFields2() {
        // テスト用のQuoteBiddingInquiry__cレコードを作成
        QuoteBiddingInquiry__c qbiOld = createTestQuoteBiddingInquiry();
        qbiOld.InquiryApprovalStatus__c = '未申請'; // 初期状態
        qbiOld.IcpExaminationGrConfirmation__c = true;
        insert qbiOld;

        // レコードタイプを取得
        Schema.SObjectType qbiType = Account.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('事業所').getRecordTypeId();

        // 取引先を作成
        Account acc = new Account(
            Name = 'テスト取引先',
            RecordTypeId = qbiRecordTypeId
        );
        insert acc;

        PumpStation__c ps = new PumpStation__c(
            Name = 'ポンプ場'
        );
        insert ps;

        // 商談を作成
        Opportunity opp = new Opportunity(
            Name = '受付未承認',
            AccountId = acc.Id,
            StageName = '基本計画',
            ConstructionDistinction__c = '更新（自社既設）',
            BU__c = '水環境',
            SBU__c = '上水',
            EstablishedCompany__c = '三菱',
            Probability1__c = 100,
            PumpStation__c = ps.Id,
            CloseDate = Date.Today()
        );
        insert opp; 

        // 更新前のレコードマップを取得
        Map<Id, QuoteBiddingInquiry__c> oldMap = new Map<Id, QuoteBiddingInquiry__c>{qbiOld.Id => qbiOld};

        // 新しい状態をシミュレートするためのレコードを作成
        QuoteBiddingInquiry__c qbiNew = [SELECT Id, InquiryApprovalStatus__c, ResultContactStatus__c FROM QuoteBiddingInquiry__c WHERE Id = :qbiOld.Id];
        qbiNew.InquiryApprovalStatus__c = 'TL'; // 状態を変更
        qbiOld.IcpExaminationGrConfirmation__c = false;
        
        Test.startTest();

        update qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.ContractAmountMax__c = 2000000;
        qbiNew.ContractAmountMin__c = 2000000;
        qbiNew.BusinessCategory__c = '既存事業';
        qbiNew.Opportunity__c = opp.Id;
        insert qbiNew;

        opp.ConstructionDistinction__c = '更新（他社既設）';
        update opp;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.ContractAmountMax__c = 6000000;
        qbiNew.ContractAmountMin__c = 6000000;
        qbiNew.BusinessCategory__c = '既存事業';
        qbiNew.Opportunity__c = opp.Id;
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        opp.ConstructionDistinction__c = '更新（自社既設）';
        update opp;
        qbiNew.BusinessCategory__c  = '既存事業';
        qbiNew.ContractAmountMin__c = 6000000;
        qbiNew.ContractAmountMax__c = 6000000;
        qbiNew.Opportunity__c = opp.Id;
        qbiNew.BidResult__c = '受注';
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        opp.ConstructionDistinction__c = '更新（他社既設）';
        update opp;
        qbiNew.Opportunity__c = opp.Id;
        qbiNew.BusinessCategory__c  = '既存事業';
        qbiNew.ContractAmountMin__c = 10000000;
        qbiNew.ContractAmountMax__c = 10000000;
        qbiNew.BidResult__c = '失注';
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.LastCustomerCategory__c = '新規顧客';
        qbiNew.Opportunity__c = opp.Id;
        qbiNew.BusinessCategory__c = '新規・拡販事業';
        qbiNew.ContractAmountMin__c = 20000000;
        qbiNew.ContractAmountMax__c = 20000000;
        insert qbiNew;
        
        qbiNew = createTestQuoteBiddingInquiry2();
        opp.ConstructionDistinction__c = '更新（他社既設）';
        update opp;
        qbiNew.Opportunity__c = opp.Id;
        qbiNew.LastCustomerCategory__c = '新規顧客';
        qbiNew.Opportunity__c = opp.Id;
        qbiNew.BusinessCategory__c = '既存事業';
        qbiNew.ContractAmountMin__c = 40000000;
        qbiNew.ContractAmountMax__c = 40000000;
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.ContractAmountMax__c = 100000000;
        qbiNew.ContractAmountMin__c = 100000000;
        insert qbiNew;
        
        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.ContractAmountMax__c = 100000001;
        qbiNew.ContractAmountMin__c = 100000001;
        insert qbiNew;

        qbiNew = createTestQuoteBiddingInquiry2();
        qbiNew.InquiryApprovalStatus__c = '事管推部長';
        insert qbiNew;

        qbiNew.ICPReviewTarget__c = true;
        qbiNew.IcpExaminationGrConfirmation__c = false;
        qbiNew.InquiryApprovalStatus__c = 'GM';
        update qbiNew;

        Test.stopTest();
    }

    @IsTest
    static void onAfterErrorCheck() {

         // テスト用のQuoteBiddingInquiry__cレコードを作成
         QuoteBiddingInquiry__c qbiOld = createTestQuoteBiddingInquiry();
         qbiOld.InquiryApprovalStatus__c = '事管推部長'; // 初期状態
         qbiOld.ICPReviewTarget__c = true;
         qbiOld.IcpExaminationGrConfirmation__c = true;
         insert qbiOld;

         QuoteBiddingInquiry__c qbinew = qbiOld.clone();
         qbinew.Id = qbiOld.Id;
         qbinew.ICPReviewTarget__c = true;
         qbinew.IcpExaminationGrConfirmation__c = false;
         qbinew.InquiryApprovalStatus__c = 'GM';

         List<QuoteBiddingInquiry__c> newList = new List<QuoteBiddingInquiry__c>();
         newList.add(qbinew);
         
         QuoteBiddingInquiryHandler handler = new QuoteBiddingInquiryHandler();
         handler.onAfterErrorCheck(newList, new Map<Id,QuoteBiddingInquiry__c>{qbiOld.Id => qbiOld});
    }

    @IsTest
    static void onAfterErrorCheck2() {

         // テスト用のQuoteBiddingInquiry__cレコードを作成
         QuoteBiddingInquiry__c qbiOld = createTestQuoteBiddingInquiry();
         qbiOld.InquiryApprovalStatus__c = '事管推部長'; // 初期状態
         qbiOld.ICPReviewTarget__c = true;
         qbiOld.IcpExaminationGrConfirmation__c = true;
         insert qbiOld;

         // レコードタイプを取得
        Schema.SObjectType qbiType = Account.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('事業所').getRecordTypeId();

        // 取引先を作成
        Account acc = new Account(
            Name = 'テスト取引先',
            RecordTypeId = qbiRecordTypeId
        );
        insert acc;

         QuoteBiddingInquiry__c qbinew = qbiOld.clone();
         qbinew.Id = qbiOld.Id;
         qbinew.ICPReviewTarget__c = true;
         qbinew.IcpExaminationGrConfirmation__c = false;
         qbinew.SpecialFeeTotal_MIN__c = 10000000;
         qbinew.SpecialFeeTotal_MAX__c = 10000000;
         qbinew.Agency1StoreName__c = acc.Id; 
         qbinew.Agency2Name__c = acc.Id; 
         qbinew.Agency3Name__c = acc.Id;
         qbinew.Creating__c = false;
         qbinew.InquiryApprovalStatus__c = 'GM';

         List<QuoteBiddingInquiry__c> newList = new List<QuoteBiddingInquiry__c>();
         newList.add(qbinew);
         
         QuoteBiddingInquiryHandler handler = new QuoteBiddingInquiryHandler();
         handler.onAfterErrorCheck(newList, new Map<Id,QuoteBiddingInquiry__c>{qbiOld.Id => qbiOld});
    }

    @IsTest
    static void testProcessInstanceApprovalFlowError() {
        QuoteBiddingInquiry__c qbiOld = createTestQuoteBiddingInquiry();
        List<Id> newWorkItemIds = new List<Id>();
        ProcessInstanceStep step = new ProcessInstanceStep();
        ProcessInstance pi = new ProcessInstance();

        // 販事ユーザを作成
        createUsers();

        System.runAs(testUser){

            // レコードタイプを取得
            Schema.SObjectType qbiType = QuoteBiddingInquiry__c.sObjectType;
            Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
            Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
            Id qbiRecordTypeId = qbiRecordTypes.get('見積伺い').getRecordTypeId();

            // テスト用のQuoteBiddingInquiry__cレコードを作成
            qbiOld = createTestQuoteBiddingInquiry();
            qbiOld.InquiryApprovalStatus__c = 'TL'; // 初期状態
            qbiOld.RequestClassification__c = '伺い申請';
            qbiOld.ICPReviewTarget__c = true;
            qbiOld.IcpExaminationGrConfirmation__c = false;
            qbiOld.AdditionalPostInquiryApplication__c = false;
            qbiOld.RecordTypeId = qbiRecordTypeId;
            qbiOld.PublicOrPrivateDemand__c = '官需';
            qbiOld.PrimeSubContractor__c = '元請';
            qbiOld.Refusal__c = false;
            qbiOld.SpecialInprofitProject__c = false;
            qbiOld.FreeContract__c = true;
            qbiOld.ExpectProfitAndLossOnOrderCP__c = 20000001;
            qbiOld.UnitPriceEstimation__c = true;
            qbiOld.ApprovalAssignmentDateTime__c = System.now();
            qbiOld.TargetForUnapprovedRemindLimitSet__c = false;
            qbiOld.AdditionalPostInquiryApplication__c = true;
            insert qbiOld;

            Holiday holiday1 = new Holiday(Name = 'Test Holiday 1', ActivityDate = System.today().addDays(1));
            Holiday holiday2 = new Holiday(Name = 'Test Holiday 2', ActivityDate = System.today().addDays(2));
            
            insert new List<Holiday>{holiday1, holiday2};
            
            // 承認プロセスを開始する
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(qbiOld.Id);
            req.setSubmitterId(testUser.Id); // 現在のユーザをSubmitterに設定
            req.setComments('テストの承認プロセスを開始します');
            req.setProcessDefinitionNameOrId('ApplicationDepartmentBLastApproval_V2_1');
            req.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req);
            newWorkItemIds = result.getNewWorkitemIds();
            
            // 承認プロセスが正常に開始されたことを確認
            System.assert(result.isSuccess(), '承認プロセスの開始に成功しました');

            // ProcessInstanceの取得と確認
            pi = [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId = :qbiOld.Id LIMIT 1];
            System.assertEquals('Pending', pi.Status, '承認プロセスが「Pending」状態であることを確認');
            
            // 承認プロセスの進行状況をシミュレートするために、ステップを取得
            step = [SELECT Id, StepStatus FROM ProcessInstanceStep WHERE ProcessInstanceId = :pi.Id LIMIT 1];
            System.assertEquals('Started', step.StepStatus, '承認ステップが「Pending」状態であることを確認');

            // 承認プロセスの承認を行う
            Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
            approvalReq.setWorkItemId(step.Id);
            approvalReq.setComments('承認ステップを完了します');
            approvalReq.setAction('Approve'); // 承認を実行
            approvalReq.setNextApproverIds(new Id[] {testManager.Id});
            approvalReq.setWorkitemId(newWorkItemIds.get(0));

            Approval.ProcessResult approvalResult = Approval.process(approvalReq);
            
            // 承認プロセスが正常に承認されたことを確認
            System.assert(approvalResult.isSuccess(), '承認プロセスの承認に成功しました');

            // 承認後のProcessInstanceを再取得し、次のステップを確認
            pi = [SELECT Id, Status FROM ProcessInstance WHERE Id = :pi.Id];
            System.assertEquals('Pending', pi.Status, '承認プロセスが「Pending」状態であることを確認');

            // 更新前のレコードマップを取得
            Map<Id, QuoteBiddingInquiry__c> oldMap = new Map<Id, QuoteBiddingInquiry__c>{qbiOld.Id => qbiOld};

            // 新しい状態をシミュレートするためのレコードを作成
            QuoteBiddingInquiry__c qbiNew = qbiOld.clone();
            qbiNew.Id = qbiOld.Id;  
            qbiNew.InquiryApprovalStatus__c = '事管推担当'; // 状態を変更
            qbiNew.ApprovalAssignmentDateTime__c = null;
            qbiNew.TargetForUnapprovedRemindLimitSet__c = true;
            update qbiNew;

            List<QuoteBiddingInquiry__c> newList = new List<QuoteBiddingInquiry__c>();
            newList.add(qbiNew);

            // 非同期処理を実行
            QuoteBiddingInquiryHandler handler = new QuoteBiddingInquiryHandler();

            QuoteBiddingInquiryHandler.QueueableUpdateApprovalInfo job = new QuoteBiddingInquiryHandler.QueueableUpdateApprovalInfo(newList, new Map<Id, QuoteBiddingInquiry__c>{qbiNew.Id => qbiNew}, oldMap);

            // 非同期処理をテストするために、テストのトランザクションを開始
            Test.startTest();

            QuoteBiddingInquiryHandler.errorHappenFlg = true;
            try{
                handler.unlockRecord(newList,oldMap);
            } catch (Exception e){
                System.assertEquals ('エラーが発生したため再度承認申請を実行してください。エラーを繰り返す場合はシステム管理者に連絡してください。', e.getMessage());
            }

            System.enqueueJob(job);
            // 非同期処理を強制的に実行させる
            Test.stopTest();
        }
    }

    @IsTest
    static void testProcessInstanceApprovalFlow() {
        QuoteBiddingInquiry__c qbiOld = createTestQuoteBiddingInquiry();
        List<Id> newWorkItemIds = new List<Id>();
        ProcessInstanceStep step = new ProcessInstanceStep();
        ProcessInstance pi = new ProcessInstance();

        // 販事ユーザを作成
        createUsers();

        System.runAs(testUser){

            // レコードタイプを取得
            Schema.SObjectType qbiType = QuoteBiddingInquiry__c.sObjectType;
            Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
            Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
            Id qbiRecordTypeId = qbiRecordTypes.get('見積伺い').getRecordTypeId();

            // テスト用のQuoteBiddingInquiry__cレコードを作成
            qbiOld = createTestQuoteBiddingInquiry();
            qbiOld.InquiryApprovalStatus__c = 'TL'; // 初期状態
            qbiOld.RequestClassification__c = '伺い申請';
            qbiOld.IcpExaminationGrConfirmation__c = false;
            qbiOld.AdditionalPostInquiryApplication__c = false;
            qbiOld.RecordTypeId = qbiRecordTypeId;
            qbiOld.PublicOrPrivateDemand__c = '官需';
            qbiOld.PrimeSubContractor__c = '元請';
            qbiOld.Refusal__c = false;
            qbiOld.SpecialInprofitProject__c = false;
            qbiOld.FreeContract__c = true;
            qbiOld.ExpectProfitAndLossOnOrderCP__c = 20000001;
            qbiOld.UnitPriceEstimation__c = true;
            qbiOld.ApprovalAssignmentDateTime__c = System.now();
            qbiOld.TargetForUnapprovedRemindLimitSet__c = false;
            insert qbiOld;

            Holiday holiday1 = new Holiday(Name = 'Test Holiday 1', ActivityDate = System.today().addDays(1));
            Holiday holiday2 = new Holiday(Name = 'Test Holiday 2', ActivityDate = System.today().addDays(2));
            
            insert new List<Holiday>{holiday1, holiday2};
            
            // 承認プロセスを開始する
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(qbiOld.Id);
            req.setSubmitterId(testUser.Id); // 現在のユーザをSubmitterに設定
            req.setComments('テストの承認プロセスを開始します');
            req.setProcessDefinitionNameOrId('ApplicationDepartmentBLastApproval_V2_1');
            req.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req);
            newWorkItemIds = result.getNewWorkitemIds();
            
            // 承認プロセスが正常に開始されたことを確認
            System.assert(result.isSuccess(), '承認プロセスの開始に成功しました');

            // ProcessInstanceの取得と確認
            pi = [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId = :qbiOld.Id LIMIT 1];
            System.assertEquals('Pending', pi.Status, '承認プロセスが「Pending」状態であることを確認');
            
            // 承認プロセスの進行状況をシミュレートするために、ステップを取得
            step = [SELECT Id, StepStatus FROM ProcessInstanceStep WHERE ProcessInstanceId = :pi.Id LIMIT 1];
            System.assertEquals('Started', step.StepStatus, '承認ステップが「Pending」状態であることを確認');

            // 承認プロセスの承認を行う
            Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
            approvalReq.setWorkItemId(step.Id);
            approvalReq.setComments('承認ステップを完了します');
            approvalReq.setAction('Approve'); // 承認を実行
            approvalReq.setNextApproverIds(new Id[] {testManager.Id});
            approvalReq.setWorkitemId(newWorkItemIds.get(0));

            Approval.ProcessResult approvalResult = Approval.process(approvalReq);
            
            // 承認プロセスが正常に承認されたことを確認
            System.assert(approvalResult.isSuccess(), '承認プロセスの承認に成功しました');

            // 承認後のProcessInstanceを再取得し、次のステップを確認
            pi = [SELECT Id, Status FROM ProcessInstance WHERE Id = :pi.Id];
            System.assertEquals('Pending', pi.Status, '承認プロセスが「Pending」状態であることを確認');

            // 更新前のレコードマップを取得
            Map<Id, QuoteBiddingInquiry__c> oldMap = new Map<Id, QuoteBiddingInquiry__c>{qbiOld.Id => qbiOld};

            // 新しい状態をシミュレートするためのレコードを作成
            QuoteBiddingInquiry__c qbiNew = qbiOld.clone();
            qbiNew.Id = qbiOld.Id;  
            qbiNew.InquiryApprovalStatus__c = '事管推担当'; // 状態を変更
            qbiNew.ApprovalAssignmentDateTime__c = null;
            qbiNew.TargetForUnapprovedRemindLimitSet__c = true;
            update qbiNew;

            List<QuoteBiddingInquiry__c> newList = new List<QuoteBiddingInquiry__c>();
            newList.add(qbiNew);

            // 非同期処理を実行
            QuoteBiddingInquiryHandler handler = new QuoteBiddingInquiryHandler();

            QuoteBiddingInquiryHandler.QueueableUpdateApprovalInfo job = new QuoteBiddingInquiryHandler.QueueableUpdateApprovalInfo(newList, new Map<Id, QuoteBiddingInquiry__c>{qbiNew.Id => qbiNew}, oldMap);

            // 非同期処理をテストするために、テストのトランザクションを開始
            Test.startTest();
            handler.unlockRecord(newList,oldMap);

            System.enqueueJob(job);
            // 非同期処理を強制的に実行させる
            Test.stopTest();
        }
    }

    @IsTest
    static void testProcessInstanceApprovalFlowRejected() {
        
        QuoteBiddingInquiry__c qbiOld = createTestQuoteBiddingInquiry();
        List<Id> newWorkItemIds = new List<Id>();
        ProcessInstanceStep step = new ProcessInstanceStep();
        ProcessInstance pi = new ProcessInstance();

        // 販事ユーザを作成
        createUsers();

        System.runAs(testUser){
            
            // レコードタイプを取得
            Schema.SObjectType qbiType = QuoteBiddingInquiry__c.sObjectType;
            Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
            Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
            Id qbiRecordTypeId = qbiRecordTypes.get('見積伺い').getRecordTypeId();

            // テスト用のQuoteBiddingInquiry__cレコードを作成
            qbiOld = createTestQuoteBiddingInquiry();
            qbiOld.InquiryApprovalStatus__c = '未申請'; // 初期状態
            qbiOld.RequestClassification__c = '伺い申請';
            qbiOld.IcpExaminationGrConfirmation__c = false;
            qbiOld.AdditionalPostInquiryApplication__c = false;
            qbiOld.RecordTypeId = qbiRecordTypeId;
            qbiOld.PublicOrPrivateDemand__c = '官需';
            qbiOld.PrimeSubContractor__c = '元請';
            qbiOld.Refusal__c = false;
            qbiOld.SpecialInprofitProject__c = false;
            qbiOld.FreeContract__c = true;
            qbiOld.ExpectProfitAndLossOnOrderCP__c = 20000001;
            qbiOld.UnitPriceEstimation__c = true;
            insert qbiOld;

            // 承認プロセスを開始する
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(qbiOld.Id);
            req.setSubmitterId(testUser.Id); // 現在のユーザをSubmitterに設定
            req.setComments('テストの承認プロセスを開始します');
            req.setProcessDefinitionNameOrId('ApplicationDepartmentBLastApproval_V2_1');
            req.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req);
            newWorkItemIds = result.getNewWorkitemIds();
            
            // 承認プロセスが正常に開始されたことを確認
            System.assert(result.isSuccess(), '承認プロセスの開始に失敗しました');

            // ProcessInstanceの取得と確認
            pi = [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId = :qbiOld.Id LIMIT 1];
            System.assertEquals('Pending', pi.Status, '承認プロセスが「Pending」状態であることを確認');
            
            // 承認プロセスの進行状況をシミュレートするために、ステップを取得
            step = [SELECT Id, StepStatus FROM ProcessInstanceStep WHERE ProcessInstanceId = :pi.Id LIMIT 1];
            System.assertEquals('Started', step.StepStatus, '承認ステップが「Pending」状態であることを確認');
            
            // 承認プロセスの承認を行う
            Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
            approvalReq.setWorkItemId(step.Id);
            approvalReq.setComments('承認ステップを完了します');
            approvalReq.setAction('Approve'); // 承認を実行
            approvalReq.setNextApproverIds(new Id[] {testManager.Id});
            approvalReq.setWorkitemId(newWorkItemIds.get(0));

            Approval.ProcessResult approvalResult = Approval.process(approvalReq);
            
            // 承認プロセスが正常に承認されたことを確認
            System.assert(approvalResult.isSuccess(), '承認プロセスの承認に失敗しました');

            // 承認後のProcessInstanceを再取得し、完了ステータスを確認
            pi = [SELECT Id, Status FROM ProcessInstance WHERE Id = :pi.Id];
            System.assertEquals('Pending', pi.Status, '承認プロセスが「Pending」状態であることを確認');

            // 却下
            ProcessInstanceWorkItem piwi = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :qbiOld.Id ORDER BY CreatedDate DESC LIMIT 1];
            Approval.ProcessWorkitemRequest workItemReject = new Approval.ProcessWorkitemRequest();
            workItemReject.setWorkitemId(piwi.Id);
            workItemReject.setAction('Reject');
            workItemReject.setComments('却下');
            Approval.ProcessResult resultRejected = Approval.process(workItemReject);

            // 更新前のレコードマップを取得
            Map<Id, QuoteBiddingInquiry__c> oldMap = new Map<Id, QuoteBiddingInquiry__c>{qbiOld.Id => qbiOld};

            // 新しい状態をシミュレートするためのレコードを作成
            QuoteBiddingInquiry__c qbiNew = qbiOld.clone();
            qbiNew.Id = qbiOld.Id;  
            qbiNew.InquiryApprovalStatus__c = 'TL'; // 状態を変更
            qbiNew.ApprovalAssignmentDateTime__c = null;
            qbiNew.TargetForUnapprovedRemindLimitSet__c = true;

            List<QuoteBiddingInquiry__c> newList = new List<QuoteBiddingInquiry__c>();
            newList.add(qbiNew);
            
             // 非同期処理を実行
             QuoteBiddingInquiryHandler handler = new QuoteBiddingInquiryHandler();

             QuoteBiddingInquiryHandler.QueueableUpdateApprovalInfo job = new QuoteBiddingInquiryHandler.QueueableUpdateApprovalInfo(newList, new Map<Id, QuoteBiddingInquiry__c>{qbiNew.Id => qbiNew}, oldMap);
 
             // 非同期処理をテストするために、テストのトランザクションを開始
             Test.startTest();
             System.enqueueJob(job);
             // 非同期処理を強制的に実行させる
             Test.stopTest();
        }
    }

    @IsTest
    static void testIcpExaminationGrConfirmationTimestamp() {

        // レコードタイプを取得
        Schema.SObjectType qbiType = QuoteBiddingInquiry__c.sObjectType;
        Schema.DescribeSObjectResult qbiDescribe = qbiType.getDescribe();
        Map<String, Schema.RecordTypeInfo> qbiRecordTypes = qbiDescribe.getRecordTypeInfosByName();
        Id qbiRecordTypeId = qbiRecordTypes.get('応札伺い').getRecordTypeId();

        // ICP審査GR確認済をfalseのレコード作成
        QuoteBiddingInquiry__c qbi3 = new QuoteBiddingInquiry__c();
        qbi3.Creating__c = true;
        qbi3.NewChanged__c = '新規';
        qbi3.RecordTypeId = qbiRecordTypeId;
        qbi3.ICPReviewTarget__c = true;
        qbi3.IcpExaminationGrConfirmation__c = false;
        insert qbi3;

        // ICP審査GR確認日時がnullになることを確認
        qbi3 = [SELECT IcpExaminationGrConfirmationTimestamp__c FROM QuoteBiddingInquiry__c WHERE Id = :qbi3.Id];
        System.assertEquals(null, qbi3.IcpExaminationGrConfirmationTimestamp__c);

        // ICP審査GR確認済をtrueにしてレコード更新
        qbi3.IcpExaminationGrConfirmation__c = true;
        update qbi3;

        // ICP審査GR確認日時が現在日時になることを確認
        qbi3 = [SELECT IcpExaminationGrConfirmationTimestamp__c FROM QuoteBiddingInquiry__c WHERE Id = :qbi3.Id];
        System.assertNotEquals(null, qbi3.IcpExaminationGrConfirmationTimestamp__c);
        Datetime dt = qbi3.IcpExaminationGrConfirmationTimestamp__c;

        // ICP審査GR確認済をtrueにしたままレコードを更新
        update qbi3;

        // ICP審査GR確認日時が更新されていなことを確認
        qbi3 = [SELECT IcpExaminationGrConfirmationTimestamp__c FROM QuoteBiddingInquiry__c WHERE Id = :qbi3.Id];
        System.assertEquals(dt, qbi3.IcpExaminationGrConfirmationTimestamp__c);

        // ICP審査GR確認済をfalseにしてレコード更新
        qbi3.IcpExaminationGrConfirmation__c = false;
        update qbi3;

        // ICP審査GR確認日時がnullになることを確認
        qbi3 = [SELECT IcpExaminationGrConfirmationTimestamp__c FROM QuoteBiddingInquiry__c WHERE Id = :qbi3.Id];
        System.assertEquals(null, qbi3.IcpExaminationGrConfirmationTimestamp__c);

        // ICP審査GR確認済をtrueのレコード作成
        QuoteBiddingInquiry__c qbi4 = new QuoteBiddingInquiry__c();
        qbi4.Creating__c = true;
        qbi4.NewChanged__c = '新規';
        qbi4.RecordTypeId = qbiRecordTypeId;
        qbi4.ICPReviewTarget__c = true;
        qbi4.IcpExaminationGrConfirmation__c = true;
        insert qbi4;

        // ICP審査GR確認日時が現在日時になることを確認
        qbi4 = [SELECT IcpExaminationGrConfirmationTimestamp__c FROM QuoteBiddingInquiry__c WHERE Id = :qbi4.Id];
        System.assertNotEquals(null, qbi4.IcpExaminationGrConfirmationTimestamp__c);

        // ICP審査GR確認日時をnullにしてレコード更新(不正値レコードを再現)
        qbi4.IcpExaminationGrConfirmationTimestamp__c = null;
        update qbi4;

        // 再現した不正値レコードのICP審査GR確認済をtrueにしたままレコード更新
        update qbi4;

        // ICP審査GR確認日時がnullになることを確認
        qbi4 = [SELECT IcpExaminationGrConfirmationTimestamp__c FROM QuoteBiddingInquiry__c WHERE Id = :qbi4.Id];
        System.assertEquals(null, qbi4.IcpExaminationGrConfirmationTimestamp__c);
    }

    /**
     * ユーザの作成
     * @param profileName プロファイル名
     * @return ユーザ
     */
    private static void createUsers(){

        testManager2 = new User(
            LastName = 'manager'
            , FirstName = 'boss'

            // insertに必要な項目
            , Username = 'manager2@QuoteBiddingInquiryHandlerTest.test'
            , Email = 'mail2@QuoteBiddingInquiryHandlerTest.test'
            , Alias = 'MGR'
            , TimeZoneSidKey = 'Asia/Tokyo'
            , LocaleSidKey = 'ja_JP'
            , EmailEncodingKey = 'ISO-2022-JP'
            , ProfileId = PROFILE_SYS.Id
            , LanguageLocaleKey = 'ja'
        );
        insert testManager2;

        testManager = new User(
            LastName = 'manager'
            , FirstName = 'boss'

            // insertに必要な項目
            , Username = 'manager@QuoteBiddingInquiryHandlerTest.test'
            , Email = 'mail@QuoteBiddingInquiryHandlerTest.test'
            , Alias = 'MGR'
            , TimeZoneSidKey = 'Asia/Tokyo'
            , LocaleSidKey = 'ja_JP'
            , EmailEncodingKey = 'ISO-2022-JP'
            , ProfileId = PROFILE_SYS.Id
            , ManagerId = testManager2.Id
            , LanguageLocaleKey = 'ja'
        );
        insert testManager;

        // ユーザ
        testUser = new User(
            FirstName = 'test'                                            // 名
            ,LastName = 'test'                                             // 姓
            ,Email = String.valueOf(Date.today()) + '@example.co.jp'     // メール
            ,UserName = 'runas@QuoteBiddingInquiryHandlerTest.test'      // ユーザ名
            ,EmailEncodingKey = 'UTF-8'                                    // メールの文字コード
            ,Alias = 'test'+String.valueOf(Datetime.now().second())                   // 別名
            ,TimeZoneSidKey = 'Asia/Tokyo'                                 // タイムゾーン
            ,LocaleSidKey = 'ja_JP'                                        // 地域
            ,LanguageLocaleKey = 'ja'                                      // 言語
            ,ProfileId = PROFILE_SYS.Id                                        // プロファイルID
            ,ManagerId = testManager.Id
            ,isActive = true
            ,Division = '本社　施設・二'
            ,ConcurrentManager__c = testManager.Id
        );
        insert testUser;
    }


}