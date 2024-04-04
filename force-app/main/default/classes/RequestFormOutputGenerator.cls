public with sharing class RequestFormOutputGenerator {
    @TestVisible private static final Datetime NOW = Datetime.now();
    @TestVisible private static final String EXECUTED_DATE = NOW.format('yyyy/MM/dd');
    @TestVisible private static final String EXECUTED_DATE_JPNYMD = NOW.format('yyyy年MM月dd日');

    private static String csvColumnHeader;
    private static List<String> csvRowValues = new List<String>();
    private static List<String> valueList = new List<String>();

    @TestVisible public static RequestTask__c requestTask;
    @TestVisible public static List<Opportunity> opportunityConstructionInfoList;
    @TestVisible public static List<Opportunity> opportunityBidManagementList;

    /**
     * 依頼タスク取得
     * @param Id 依頼タスクレコードID
     */
    public static void getRequestTask(Id requestTaskId){
        requestTask = [
            SELECT
                DueDate__c                  // 希望回答期限
                , RequestCc1__c             // メンション先グループCc1
                , RequestCc2__c             // メンション先グループCc2
                , RequestCc3__c             // メンション先グループCc3
                , RequestDestination__c     // 依頼先
                , Requester__c              // 依頼元
                , RequestFactoryName__c     // 依頼先製作所名(正式名称)
                , RequestTo__c              // メンション先グループ
                , TaskCategory__c           // 依頼区分
                , UserDeptLastApprover__c   // 自部門最終承認者
                , DocumentOutputFlag__c     // 帳票出力済みフラグ

                , Approver1__r.LastName     // 承認者1.姓
                , Approver2__r.LastName     // 承認者2.姓
                , Approver3__r.LastName     // 承認者3.姓

                , CreatedBy.Name
                , CreatedBy.LastName        // 作成者.姓
                , CreatedBy.FirstName        // 作成者.名
                , CreatedBy.Manager.LastName    // 作成者.マネージャ.姓
                , CreatedBy.Manager.FirstName    // 作成者.マネージャ.名
                , CreatedBy.Manager.Name

                , Factory__r.Factory__c     // 場所別.製作所
                , Factory__r.SR_CP__c       // 場所別.１．商談CP

                , Opportunity__c                                // 案件
                , Opportunity__r.Account.Name                   // 案件.取引先.取引先名
                , Opportunity__r.Account.Type                   // 案件.取引先.取引先 種別
                , Opportunity__r.DistributionChannelsPattern__c // 案件.商流パターン
                , Opportunity__r.EstimatedIssuedDate_01__c      // 案件.発行予定日①
                , Opportunity__r.KOUJI_SYU__c                   // 案件.工事種別
                , Opportunity__r.Name                           // 案件.案件名
                , Opportunity__r.OppNumber__c                   // 案件.案件番号
                , Opportunity__r.OpportunityNote__c             // 案件.案件メモ
                , Opportunity__r.OpportunityNumber__c           // 案件.商談番号
                , Opportunity__r.OrderExpectation__c            // 案件.受注見込
                , Opportunity__r.CloseDate                      // 案件.受注予定日
                , Opportunity__r.PickDivision__c                // 案件.部門
                , Opportunity__r.ProposedTechniqueRemarks__c    // 案件.技術提案 備考
                , Opportunity__r.PumpStation__r.Name            // 案件.機場.機場名
                , Opportunity__r.Result_SalesDate__c            // 案件.４．売上年月日
                , Opportunity__r.SR_CP__c                       // 案件.SR CP
                , Opportunity__r.SR_Number_Main__c              // 案件.売報番号
                , Opportunity__r.TotalCP__c                     // 案件.１．商談CP
                , Opportunity__r.TotalWC__c                     // 案件.１．商談WC
                , Opportunity__r.WCPercent__c                   // 案件.１．商談WC率
            FROM
                RequestTask__c
            WHERE
                Id = :requestTaskId
        ];
    }

    /**
     * 依頼タスクに紐づく案件に紐づく工事情報取得
     * @param Id 依頼タスクレコードID
     */
    public static void getOpportunityConstructionInfoList(Id requestTaskId){
        opportunityConstructionInfoList = [
            SELECT
                (
                    SELECT
                        DAIRININ_KENMU__c   // 現場代理人との兼務可否
                        , FROM_K_YMD_1__c   // 工事期間登録開始日1
                        , HAICHI_STATUS__c  // 技術者の配置状況
                        , KOUKIF_YMD__c     // 工期FROM
                        , KOUKIT_YMD__c     // 工期TO
                        , MAN_1__r.Name     // 技術者1.技術者名
                        , ORDER_NO__c       // 工事番号
                        , SYUNKO_YMD__c     // 竣工日
                        , TO_K_YMD_1__c     // 工事期間登録解除日1
                    FROM
                        ConstructionInfo__r
                )
            FROM
                Opportunity
            WHERE
                Id IN (
                    SELECT
                        Opportunity__c
                    FROM
                        RequestTask__c
                    WHERE
                        Id = :requestTaskId
                )
        ];
    }

    /**
     * 依頼タスクに紐づく案件に紐づく入札取得
     * @param Id 依頼タスクレコードID
     */
    public static void getOpportunityBidManagementList(Id requestTaskId){
        // 依頼タスクに紐づく案件に紐づく入札
        opportunityBidManagementList = [
            SELECT
                (
                    SELECT
                        SubmitDate__c // 提出日時（年月日）
                    FROM
                        Opp1__r
                )
            FROM
                Opportunity
            WHERE
                Id IN (
                    SELECT
                        Opportunity__c
                    FROM
                        RequestTask__c
                    WHERE
                        Id = :requestTaskId
                )
        ];
    }

    /**
     * ①提案業務依頼書用CSV作成
     */
    @TestVisible public static String createRequestForm1Csv(){
        csvColumnHeader = 'ヘッダー_作成日,ヘッダー_宛先,ヘッダー_宛先Cc1,ヘッダー_宛先Cc2,ヘッダー_宛先Cc3,発信部門,課長,担当,客先名,発注予定年月,商談件名,商談番号,案件番号,商談内容,受注見込み,WC率,提案先,回答_依頼元,回答_宛先Cc1,回答_宛先Cc2,回答_宛先Cc3,竣工予定年月,配置技術者の有,配置技術者の無\n';

        // 提案先
        String proposal = setProposal(requestTask.Opportunity__r.Account.Type, requestTask.Opportunity__r.Account.Name);

        // ヘッダー_作成日
        valueList.add(EXECUTED_DATE_JPNYMD);
        // ヘッダー_宛先
        valueList.add(requestTask.RequestTo__c);
        // ヘッダー_宛先Cc1
        valueList.add(requestTask.RequestCc1__c);
        // ヘッダー_宛先Cc2
        valueList.add(requestTask.RequestCc2__c);
        // ヘッダー_宛先Cc3
        valueList.add(requestTask.RequestCc3__c);
        // 発信部門
        valueList.add(requestTask.Opportunity__r.PickDivision__c);
        // 課長
        // valueList.add(requestTask.CreatedBy.Manager.Name);
        system.debug('@@requestTask.CreatedBy.Manager: '+requestTask.CreatedBy.Manager);
        Boolean isHaveManager = requestTask.CreatedBy.Manager != null;
        String managerLastName = '';
        String managerFirstName = '';
        if(isHaveManager){
            managerLastName = requestTask.CreatedBy.Manager.LastName;
            managerFirstName = requestTask.CreatedBy.Manager.FirstName;
        }
        valueList.add(managerLastName + managerFirstName);
        // 担当
        // valueList.add(requestTask.CreatedBy.Name);
        system.debug('@@requestTask.CreatedBy.Name: '+requestTask.CreatedBy.Name);
        String createdByLastName = requestTask.CreatedBy.LastName;
        String createdByFirstName = requestTask.CreatedBy.FirstName == null ? '' : requestTask.CreatedBy.FirstName;
        valueList.add(createdByLastName + createdByFirstName);
        // 客先名
        valueList.add(requestTask.Opportunity__r.Account.Name);
        // 発注予定年月
        valueList.add(requestTask.Opportunity__r.EstimatedIssuedDate_01__c == null ? '' : String.valueOf(requestTask.Opportunity__r.EstimatedIssuedDate_01__c.format()));
        // 商談件名
        valueList.add(requestTask.Opportunity__r.Name);
        // 商談番号
        valueList.add(requestTask.Opportunity__r.OpportunityNumber__c == null ? '' : convertCharacterWidthHalfToFull(requestTask.Opportunity__r.OpportunityNumber__c));
        // 案件番号
        valueList.add(requestTask.Opportunity__r.OppNumber__c == null ? '' : convertCharacterWidthHalfToFull(requestTask.Opportunity__r.OppNumber__c));
        // 商談内容
        valueList.add(requestTask.Opportunity__r.OpportunityNote__c == null ? '' : '"' + requestTask.Opportunity__r.OpportunityNote__c + '"');
        // 受注見込み
        valueList.add(requestTask.Opportunity__r.OrderExpectation__c == null ? '' : convertCharacterWidthHalfToFull(requestTask.Opportunity__r.OrderExpectation__c));
        // WC率
        valueList.add(requestTask.Opportunity__r.WCPercent__c == null ? '' : String.valueOf(requestTask.Opportunity__r.WCPercent__c));
        // 提案先
        valueList.add(proposal);
        // 回答_依頼元
        valueList.add(requestTask.Requester__c);
        // 回答_宛先Cc1
        valueList.add(requestTask.RequestCc1__c);
        // 回答_宛先Cc2
        valueList.add(requestTask.RequestCc2__c);
        // 回答_宛先Cc3
        valueList.add(requestTask.RequestCc3__c);

        List<String> availability = new List<String>();
        String syunkoYmd;
        if(opportunityConstructionInfoList.isEmpty()){
            availability.add('□有');
            availability.add('□無');
        } else {
            for(Opportunity opportunity : opportunityConstructionInfoList){
                if(opportunity.ConstructionInfo__r.size() == 1){
                    for(ConstructionInfo__c constructioninfo : opportunity.ConstructionInfo__r){
                        availability = setAvailability(constructioninfo.HAICHI_STATUS__c);
                        syunkoYmd = constructioninfo.SYUNKO_YMD__c == null ? '' : String.valueOf(constructioninfo.SYUNKO_YMD__c.format());
                    }
                } else if(opportunity.ConstructionInfo__r.size() == 0) {
                    availability.add('□有');
                    availability.add('■無');
                }
                else {
                    availability.add('□有');
                    availability.add('□無');
                }
            }
        }

        // 竣工予定年月
        valueList.add(syunkoYmd);
        // 配置技術者の有
        valueList.add(availability[0]);
        // 配置技術者の無
        valueList.add(availability[1]);

        return createCsv();
    }

    /**
     * ②見積照会書用CSV作成
     */
    @TestVisible public static String createRequestForm2Csv(){
        csvColumnHeader = '発行日,案件番号,商談番号,宛先,担当,顧客名,件名,案件概要,システム概要,確度,受注,売上,工事,商流,着手\n';

        // 確度
        String expectation = setExpectation(requestTask.Opportunity__r.OrderExpectation__c);

        // 工事
        String construction = setConstruction(requestTask.Opportunity__r.KOUJI_SYU__c);

        // 発行日
        valueList.add(EXECUTED_DATE);
        // 案件番号
        valueList.add(requestTask.Opportunity__r.OppNumber__c);
        // 商談番号
        valueList.add(requestTask.Opportunity__r.OpportunityNumber__c);
        // 宛先
        String requestTo = String.format('{0}Ｋ殿', new List<String>{requestTask.RequestTo__c == null ? '' : requestTask.RequestTo__c});
        valueList.add(requestTo);
        // 担当
        valueList.add(requestTask.CreatedBy.LastName + requestTask.CreatedBy.FirstName);
        // 顧客名
        valueList.add(requestTask.Opportunity__r.Account.Name == null ? '' : '"' + requestTask.Opportunity__r.Account.Name + '"');
        // 件名
        valueList.add(requestTask.Opportunity__r.Name == null ? '' : '"' + requestTask.Opportunity__r.Name + '"');
        // 案件概要
        valueList.add(requestTask.Opportunity__r.OpportunityNote__c == null ? '' : '"' + requestTask.Opportunity__r.OpportunityNote__c + '"');
        // システム概要
        valueList.add(requestTask.Opportunity__r.ProposedTechniqueRemarks__c == null ? '' : '"' + requestTask.Opportunity__r.ProposedTechniqueRemarks__c + '"');
        // 確度
        valueList.add(expectation);
        // 受注　SHAKANCRM_CONCEPT-622にて受注年月日→受注予定日に変更
        valueList.add(requestTask.Opportunity__r.CloseDate == null ? '' : String.valueOf(requestTask.Opportunity__r.CloseDate.format()));
        // 売上
        valueList.add(requestTask.Opportunity__r.Result_SalesDate__c == null ? '' : String.valueOf(requestTask.Opportunity__r.Result_SalesDate__c.format()));
        // 工事
        valueList.add(construction);
        // 商流
        valueList.add(requestTask.Opportunity__r.DistributionChannelsPattern__c);

        String koukifYmd;
        for(Opportunity opportunity : opportunityConstructionInfoList){
            if(opportunity.ConstructionInfo__r.size() == 1){
                for(ConstructionInfo__c constructioninfo : opportunity.ConstructionInfo__r){
                    koukifYmd = constructioninfo.KOUKIF_YMD__c == null ? '' : String.valueOf(constructioninfo.KOUKIF_YMD__c.format());
                }
            }
        }

        // 着手
        valueList.add(koukifYmd);

        return createCsv();
    }

    /**
     * ③写真撮影依頼書用CSV作成
     */
    public static String createRequestForm3Csv(){
        csvColumnHeader = '本社・支社,事業所,ヘッダー_御注文元,ヘッダー_件名,SR_NO_案件番号,送付期限_年,送付期限_月,送付期限_日,看板仕様_御注文元,看板仕様_件名,看板仕様_製作所名\n';

        // SR_NO_案件番号
        String sr = formatSrNo(requestTask.Opportunity__r.SR_Number_Main__c);
        String srOpp = String.format('{0}（案件番号：{1}）', new List<Object> {sr, requestTask.Opportunity__r.OppNumber__c});

        // 本社・支社
        valueList.add(setPostAndTitle(requestTask.Requester__c, 'Ｋ'));
        // 事業所
        String requestTo = String.format('{0}Ｋ', new List<String>{requestTask.RequestTo__c == null ? '' : requestTask.RequestTo__c});
        valueList.add(requestTo);
        // ヘッダー_御注文元
        valueList.add(requestTask.Opportunity__r.Account.Name);
        // ヘッダー_件名
        valueList.add(requestTask.Opportunity__r.Name);
        // SR_NO_案件番号
        valueList.add(srOpp);
        // 送付期限_年
        valueList.add(requestTask.DueDate__c == null ? '' : convertCharacterWidthHalfToFull(String.valueOf(requestTask.DueDate__c.year())));
        // 送付期限_月
        String dueDateMonth = String.valueOf(requestTask.DueDate__c.month()).length() == 1 ? '0' + String.valueOf(requestTask.DueDate__c.month()) : String.valueOf(requestTask.DueDate__c.month());
        valueList.add(convertCharacterWidthHalfToFull(dueDateMonth));
        // 送付期限_日
        String dueDateDay = String.valueOf(requestTask.DueDate__c.day()).length() == 1 ? '0' + String.valueOf(requestTask.DueDate__c.day()) : String.valueOf(requestTask.DueDate__c.day());
        valueList.add(convertCharacterWidthHalfToFull(dueDateDay));
        // 看板仕様_御注文元
        valueList.add(requestTask.Opportunity__r.Account.Name);
        // 看板仕様_件名
        valueList.add(requestTask.Opportunity__r.Name);
        // 看板仕様_製作所名
        valueList.add('三菱電機株式会社　' + requestTask.RequestFactoryName__c);

        return createCsv();
    }

    /**
     * ④機器搬入連絡表用CSV作成
     */
    @TestVisible public static String createRequestForm4Csv(){
        csvColumnHeader = '宛先,写1,写2,写3,発行日,発行者,発注元,工事件名,現場名,工事番号,現場代理人\n';

        // 宛先
        String requestTo = String.format('{0}Ｋ', new List<String>{requestTask.RequestTo__c == null ? '' : requestTask.RequestTo__c});
        valueList.add(requestTo);
        // 写1
        valueList.add(requestTask.RequestCc1__c);
        // 写2
        valueList.add(requestTask.RequestCc2__c);
        // 写3
        valueList.add(requestTask.RequestCc3__c);
        // 発行日
        valueList.add(convertCharacterWidthHalfToFull(EXECUTED_DATE_JPNYMD));
        // 発行者
        valueList.add(requestTask.CreatedBy.LastName + requestTask.CreatedBy.FirstName);
        // 発注元
        valueList.add(requestTask.Opportunity__r.Account.Name);
        // 工事件名
        valueList.add(requestTask.Opportunity__r.Name);
        // 現場名
        valueList.add(requestTask.Opportunity__r.PumpStation__r.Name);

        String orderNo;
        String agent;
        for(Opportunity opportunity : opportunityConstructionInfoList){
            if(opportunity.ConstructionInfo__r.size() == 1){
                for(ConstructionInfo__c constructioninfo : opportunity.ConstructionInfo__r){
                    orderNo = constructioninfo.ORDER_NO__c == null ? '' : constructioninfo.ORDER_NO__c;
                    if(constructioninfo.DAIRININ_KENMU__c == '可') agent = constructioninfo.MAN_1__r.Name;
                }
            }
        }

        // 工事番号
        valueList.add(orderNo);
        // 現場代理人
        valueList.add(agent);

        return createCsv();
    }

    /**
     * ⑤技術員派遣依頼書用CSV作成
     */
    @TestVisible public static String createRequestForm5Csv(){
        csvColumnHeader = '回答希望期限,発行日_年,発行日_月,発行日_日,本社・支社・現場,製作所営業,製作所営業_写1,製作所営業_写2,製作所営業_写3,注文元,件名,SR_NO,案件番号,販事担当者,宛先1,宛先2,技術員派遣連絡件名,現場代理人\n';

        // 回答希望期限
        String dueDate = convertCharacterWidthHalfToFull(formatDate(requestTask.DueDate__c, 'yyyy年MM月dd日'));
        // SR_NO
        String sr = convertCharacterWidthHalfToFull(formatSrNo(requestTask.Opportunity__r.SR_Number_Main__c));

        // 回答希望期限
        valueList.add(dueDate);
        // 発行日_年
        valueList.add(convertCharacterWidthHalfToFull(String.valueOf(NOW.year())));
        // 発行日_月
        String publishMonth = String.valueOf(NOW.month()).length() == 1 ? '0' + String.valueOf(NOW.month()) : String.valueOf(NOW.month());
        valueList.add(convertCharacterWidthHalfToFull(publishMonth));
        // 発行日_日
        String publishDay = String.valueOf(NOW.day()).length() == 1 ? '0' + String.valueOf(NOW.day()) : String.valueOf(NOW.day());
        valueList.add(convertCharacterWidthHalfToFull(publishDay));
        // 本社・支社・現場
        valueList.add(requestTask.Requester__c);
        // 製作所営業
        valueList.add(requestTask.RequestTo__c);
        // 製作所営業_写1
        valueList.add(requestTask.RequestCc1__c);
        // 製作所営業_写2
        valueList.add(requestTask.RequestCc2__c);
        // 製作所営業_写3
        valueList.add(requestTask.RequestCc3__c);
        // 注文元
        valueList.add(requestTask.Opportunity__r.Account.Name);
        // 件名
        valueList.add(requestTask.Opportunity__r.Name);
        // SR_NO
        valueList.add(sr);
        // 案件番号
        valueList.add(requestTask.Opportunity__r.OppNumber__c == null ? '' : convertCharacterWidthHalfToFull(requestTask.Opportunity__r.OppNumber__c));
        // 販事担当者
        valueList.add(requestTask.CreatedBy.LastName + requestTask.CreatedBy.FirstName);
        // 宛先1
        valueList.add(requestTask.RequestTo__c);
        // 宛先2
        valueList.add(requestTask.Requester__c);
        // 技術員派遣連絡件名
        valueList.add(requestTask.Opportunity__r.Name);

        String agent;
        for(Opportunity opportunity : opportunityConstructionInfoList){
            if(opportunity.ConstructionInfo__r.size() == 1){
                for(ConstructionInfo__c constructioninfo : opportunity.ConstructionInfo__r){
                    if(constructioninfo.DAIRININ_KENMU__c == '可') agent = constructioninfo.MAN_1__r.Name;
                }
            }
        }

        // 現場代理人
        valueList.add(agent);

        return createCsv();
    }

    /**
     * ⑥配置技術者選定依頼用CSV作成
     */
    @TestVisible public static String createRequestForm6Csv(){
        csvColumnHeader = 'ヘッダー_発信元,ヘッダー_宛先1,ヘッダー_写,ヘッダー_発信元担当,ヘッダー_発信元検印,依頼先場所,回答期限_月,回答期限_日,客先名,件名,案件番号,回答場所名,回答_宛先1,回答_宛先2,配置報告_発信元,配置報告_発信元担当,配置報告_発信元検印,配置報告_宛先1,配置報告_写,工期_自_年,工期_自_月,工期_自_日,工期_至_年,工期_至_月,工期_至_日,配置期間_自_年,配置期間_自_月,配置期間_自_日,配置期間_至_年,配置期間_至_月,配置期間_至_日\n';

        // ヘッダー_発信元検印
        String approver = setApprover(requestTask);

        // 依頼先場所
        String requestDestination = String.format('以下の条件で，{0}から配置技術者選出の検討をお願いします。詳細は添付参照のこと。', new List<String>{requestTask.RequestDestination__c});

        // 案件番号
        String oppNumber = String.format('（案件番号：{0}）', new List<String>{requestTask.Opportunity__r.OppNumber__c});

        // 回答場所名
        String requestDestination2 = String.format('【回答（{0}）】', new List<String>{requestTask.RequestDestination__c});

        // 配置報告_写
        String requestCc1 = String.format('(写){0}Ｋ', new List<String>{requestTask.RequestCc1__c == null ? '' : requestTask.RequestCc1__c});

        // ヘッダー_発信元
        valueList.add(requestTask.Requester__c);
        // ヘッダー_宛先1
        String requestTo = String.format('{0}Ｋ殿', new List<String>{requestTask.RequestTo__c == null ? '' : requestTask.RequestTo__c});
        valueList.add(requestTo);
        // ヘッダー_写
        valueList.add(requestTask.RequestCc1__c);
        // ヘッダー_発信元担当
        valueList.add(requestTask.CreatedBy.LastName);
        // ヘッダー_発信元検印
        valueList.add(approver);
        // 依頼先場所
        valueList.add(requestDestination);
        // 回答期限_月
        String dueDateMonth = String.valueOf(requestTask.DueDate__c.month()).length() == 1 ? '0' + String.valueOf(requestTask.DueDate__c.month()) : String.valueOf(requestTask.DueDate__c.month());
        valueList.add(convertCharacterWidthHalfToFull(dueDateMonth));
        // 回答期限_日
        String dueDateDay = String.valueOf(requestTask.DueDate__c.day()).length() == 1 ? '0' + String.valueOf(requestTask.DueDate__c.day()) : String.valueOf(requestTask.DueDate__c.day());
        valueList.add(convertCharacterWidthHalfToFull(dueDateDay));
        // 客先名
        valueList.add(requestTask.Opportunity__r.Account.Name);
        // 件名
        valueList.add(requestTask.Opportunity__r.Name);
        // 案件番号
        valueList.add(oppNumber);
        // 回答場所名
        valueList.add(requestDestination2);
        // 回答_宛先1
        valueList.add(requestTo);
        // 回答_宛先2
        valueList.add(requestTask.Requester__c);
        // 配置報告_発信元
        valueList.add(setPostAndTitle(requestTask.Requester__c, 'Ｋ'));
        // 配置報告_発信元担当
        valueList.add(requestTask.CreatedBy.LastName);
        // 配置報告_発信元検印
        valueList.add(approver);
        // 配置報告_宛先1
        valueList.add(requestTo);
        // 配置報告_写
        valueList.add('');

        String agent;
        Date koukifYmd;
        Date koukitYmd;
        Date fromKYmd1;
        Date toKYmd1;
        for(Opportunity opportunity : opportunityConstructionInfoList){
            if(opportunity.ConstructionInfo__r.size() == 1){
                for(ConstructionInfo__c constructioninfo : opportunity.ConstructionInfo__r){
                    koukifYmd = constructioninfo.KOUKIF_YMD__c;
                    koukitYmd = constructioninfo.KOUKIT_YMD__c;
                    fromKYmd1 = constructioninfo.FROM_K_YMD_1__c;
                    toKYmd1 = constructioninfo.TO_K_YMD_1__c;
                }
            }
        }

        // 工期_自_年
        valueList.add(koukifYmd == null ? '' : String.valueOf(koukifYmd.year()));
        // 工期_自_月
        valueList.add(koukifYmd == null ? '' : String.valueOf(koukifYmd.month()).length() == 1 ? '0' + String.valueOf(koukifYmd.month()) : String.valueOf(koukifYmd.month()));
        // 工期_自_日
        valueList.add(koukifYmd == null ? '' : String.valueOf(koukifYmd.day()).length() == 1 ? '0' + String.valueOf(koukifYmd.day()) : String.valueOf(koukifYmd.day()));
        // 工期_至_年
        valueList.add(koukitYmd == null ? '' : String.valueOf(koukitYmd.year()));
        // 工期_至_月
        valueList.add(koukitYmd == null ? '' : String.valueOf(koukitYmd.month()).length() == 1 ? '0' + String.valueOf(koukitYmd.month()) : String.valueOf(koukitYmd.month()));
        // 工期_至_日
        valueList.add(koukitYmd == null ? '' : String.valueOf(koukitYmd.day()).length() == 1 ? '0' + String.valueOf(koukitYmd.day()) : String.valueOf(koukitYmd.day()));
        // 配置期間_自_年
        valueList.add(fromKYmd1 == null ? '' : String.valueOf(fromKYmd1.year()));
        // 配置期間_自_月
        valueList.add(fromKYmd1 == null ? '' : String.valueOf(fromKYmd1.month()).length() == 1 ? '0' + String.valueOf(fromKYmd1.month()) : String.valueOf(fromKYmd1.month()));
        // 配置期間_自_日
        valueList.add(fromKYmd1 == null ? '' : String.valueOf(fromKYmd1.day()).length() == 1 ? '0' + String.valueOf(fromKYmd1.day()) : String.valueOf(fromKYmd1.day()));
        // 配置期間_至_年
        valueList.add(toKYmd1 == null ? '' : String.valueOf(toKYmd1.year()));
        // 配置期間_至_月
        valueList.add(toKYmd1 == null ? '' : String.valueOf(toKYmd1.month()).length() == 1 ? '0' + String.valueOf(toKYmd1.month()) : String.valueOf(toKYmd1.month()));
        // 配置期間_至_日
        valueList.add(toKYmd1 == null ? '' : String.valueOf(toKYmd1.day()).length() == 1 ? '0' + String.valueOf(toKYmd1.day()) : String.valueOf(toKYmd1.day()));

        return createCsv();
    }

    /**
     * ⑥配置技術者選定依頼用CSV作成 別紙
     */
    @TestVisible public static String createRequestForm6AppendixCsv(){
        csvRowValues = new List<String>();
        valueList = new List<String>();

        csvColumnHeader = '受注確度,全社CP,場所CP,備考\n';

        // 受注確度
        String expectation = String.format('受注確度【{0}】', new List<String>{requestTask.Opportunity__c == null ? '' : requestTask.Opportunity__r.OrderExpectation__c});

        // 全社CP
        String totalCp = '全社ＣＰ' + convertTo1000YenAndRoundHalfUp(requestTask.Opportunity__r.TotalCP__c);

        // 場所CP
        String srCp = '場所ＣＰ';
        if(requestTask.RequestDestination__c == requestTask.Factory__r.Factory__c){
            srCp += convertTo1000YenAndRoundHalfUp(requestTask.Factory__r.SR_CP__c);
        }

        // 受注確度
        valueList.add(expectation);
        // 全社CP
        valueList.add(totalCp);
        // 場所CP
        valueList.add(srCp);
        // 備考
        valueList.add(requestTask.Opportunity__r.OpportunityNumber__c);

        return createCsv();
    }

    /**
     * ⑦先行手配依頼書用CSV作成
     */
    public static String createRequestForm7Csv(){
        csvColumnHeader = '発行日,注文元,件名・工事名,案件番号,希望回答期限,場所,予想CP,予想WC,入札予定\n';

        // 案件番号
        String oppNumber = String.format('（案件番号：{0}）', new List<String>{requestTask.Opportunity__c == null ? '' : convertCharacterWidthHalfToFull(requestTask.Opportunity__r.OppNumber__c)});

        // 発行日
        valueList.add(EXECUTED_DATE);
        // 注文元
        valueList.add(requestTask.Opportunity__r.Account.Name);
        // 件名・工事名
        valueList.add(requestTask.Opportunity__r.Name);
        // 案件番号
        valueList.add(oppNumber);
        // 希望回答期限
        valueList.add(convertCharacterWidthHalfToFull(formatDate(requestTask.DueDate__c, 'yyyy年MM月dd日')));
        // 場所
        valueList.add(requestTask.RequestDestination__c);
        // 予想CP
        valueList.add(convertTo1000YenAndRoundHalfUp(requestTask.Opportunity__r.TotalCP__c));
        // 予想WC
        valueList.add(convertTo1000YenAndRoundHalfUp(requestTask.Opportunity__r.TotalWC__c));

        // 入札予定
        String submitDate;
        for(Opportunity opportunity : opportunityBidManagementList){
            if(opportunity.Opp1__r.size() == 1){
                for(BidManagement__c bidManagement : opportunity.Opp1__r){
                    submitDate = convertCharacterWidthHalfToFull(formatDate(bidManagement.SubmitDate__c, 'yyyy年MM月dd日'));
                }
            } else {
                submitDate = '　　　　年　　月　　日';
            }
        }

        // 入札予定
        valueList.add(submitDate);

        return createCsv();
    }

    /**
     * ⑧原低依頼書用CSV作成
     */
    public static String createRequestForm8Csv(){
        csvColumnHeader = '発行日,ヘッダー_宛先,ヘッダー_発信元,注文元,件名・工事名,案件番号,希望回答期限,場所,予想CP,回答_宛先,回答_発信元,入札予定\n';
        // ヘッダー_発信元
        String requester = String.format('(販事){0}K', new List<String>{requestTask.Requester__c});

        // 案件番号
        String oppNumber = String.format('（案件番号：{0}）', new List<String>{requestTask.Opportunity__c == null ? '' : convertCharacterWidthHalfToFull(requestTask.Opportunity__r.OppNumber__c)});

        // 予想CP
        String srCp;
        if(requestTask.RequestDestination__c == requestTask.Factory__r.Factory__c){
            srCp = convertTo1000YenAndRoundHalfUp(requestTask.Factory__r.SR_CP__c);
        }

        // 回答_発信元
        String requestTo = String.format('(場所){0}K', new List<String>{requestTask.RequestTo__c == null ? '' : requestTask.RequestTo__c});

        // 発行日
        valueList.add(EXECUTED_DATE);
        // ヘッダー_宛先
        String headerRequestTo = String.format('{0}K殿', new List<String>{requestTask.RequestTo__c == null ? '' : requestTask.RequestTo__c});
        valueList.add(headerRequestTo);
        // ヘッダー_発信元
        valueList.add(requester);
        // 注文元
        valueList.add(requestTask.Opportunity__r.Account.Name);
        // 件名・工事名
        valueList.add(requestTask.Opportunity__r.Name);
        // 案件番号
        valueList.add(oppNumber);
        // 希望回答期限
        valueList.add(convertCharacterWidthHalfToFull(formatDate(requestTask.DueDate__c, 'yyyy年MM月dd日')));
        // 場所
        valueList.add(requestTask.RequestDestination__c);
        // 予想CP
        valueList.add(srCp);
        // 回答_宛先
        valueList.add(setPostAndTitle(requestTask.Requester__c, 'K殿'));
        // 回答_発信元
        valueList.add(requestTo);

        // 入札予定
        String submitDate;
        for(Opportunity opportunity : opportunityBidManagementList){
            if(opportunity.Opp1__r.size() == 1){
                for(BidManagement__c bidManagement : opportunity.Opp1__r){
                    submitDate = convertCharacterWidthHalfToFull(formatDate(bidManagement.SubmitDate__c, 'yyyy年MM月dd日'));
                }
            } else {
                submitDate = '　　　　年　　月　　日';
            }
        }

        // 入札予定
        valueList.add(submitDate);

        return createCsv();
    }

    /**
     * CSV作成
     * ヘッダと明細を文字列結合してCSV形式に整形する。
     */
    public static string createCsv(){
        String rowStr = String.join(valueList, ',');
        csvRowValues.add(rowStr);
        // requestTask.DocumentOutputFlag__c = true;
        // update requestTask;
        return csvColumnHeader + String.join(csvRowValues,'\n');
    }

    /**
     * 半角→全角変換処理
     * Unicodeのコードポイントを利用して指定の文字を半角から全角に変換する。
     * @param String 任意の文字列
     */
    @TestVisible private static String convertCharacterWidthHalfToFull(String str){
        List<Integer> codePointList = new List<Integer>();
        for (integer i = 0; i < str.length(); i++) {
            // 文字のコードポイント取得
            Integer codePoint = str.codePointAt(i);

            if (codePoint == 45) {
                // -
                codePoint += 65248;
            } else if (48 <= codePoint && codePoint <= 57) {
                // 0123456789
                codePoint += 65248;
            } else if (65 <= codePoint && codePoint <= 90) {
                // ABCDEFGHIJKLMNOPQRSTUVWXYZ
                codePoint += 65248;
            } else if (97 <= codePoint && codePoint <= 122) {
                // abcdefghijklmnopqrstuvwxyz
                codePoint += 65248;
            } else {
                // それ以外はそのままリストに追加
            }
            codePointList.add(codePoint);
        }
        return String.fromCharArray(codePointList);
    }

    /** 
     * 配置技術者の有無設定処理
    */
    @TestVisible private static List<String> setAvailability(String status){
        List<String> availability = new List<String>();
        switch on status {
            when '配置済', '配置予定' {
                availability.add('■有');
                availability.add('□無');
            }
            when else {
                availability.add('□有');
                availability.add('■無');
            }
        }
        return availability;
    }

    /** 
     * 提案先設定処理
    */
    @TestVisible private static String setProposal(String type, String name){
        String proposal;
        switch on type {
            when 'エンドユーザー' {
                proposal = String.format('■最終顧客・部署 ({0})', new List<String>{name});
            }
            when 'ゼネコン', 'サブコン', '代理店', '設計事務所', 'プラ建協力会社', 'その他', null {
                proposal = '□最終顧客・部署 (    　　　)';
            }
            when else {
                proposal = '';
            }
        }
        return proposal;
    }

    /** 
     * 確度設定処理
    */
    @TestVisible private static String setExpectation(string orderExpectation){
        String expectation;
        switch on orderExpectation {
            when '1' {
                expectation = '"■1 決定，□2 有望，□3 努力，□4C チャレンジ，□4 希望，□5 需要"';
            }
            when '2' {
                expectation = '"□1 決定，■2 有望，□3 努力，□4C チャレンジ，□4 希望，□5 需要"';
            }
            when '3' {
                expectation = '"□1 決定，□2 有望，■3 努力，□4C チャレンジ，□4 希望，□5 需要"';
            }
            when '4C' {
                expectation = '"□1 決定，□2 有望，□3 努力，■4C チャレンジ，□4 希望，□5 需要"';
            }
            when '4' {
                expectation = '"□1 決定，□2 有望，□3 努力，□4C チャレンジ，■4 希望，□5 需要"';
            }
            when '5' {
                expectation = '"□1 決定，□2 有望，□3 努力，□4C チャレンジ，□4 希望，■5 需要"';
            }
        }
        return expectation;
    }

    /** 
     * 工事設定処理
    */
    @TestVisible private static String setConstruction(String koujiSyu){
        String construction;
        switch on koujiSyu {
            when '電気工事', '電気通信工事' {
                construction = '■建設業法対象';
            }
            when 'その他' {
                construction = '□建設業法対象';
            }
        }
        return construction;
    }

    /** 
     * 売報番号フォーマット処理
     * A1234Z5670
     * A1234-Z567-0
    */
    @TestVisible private static String formatSrNo(String srNumberMain){
        String sr;
        if(String.isBlank(srNumberMain)){
            sr = '';
        } else if(srNumberMain.length() < 10){
            sr = srNumberMain;
        } else {
            sr = srNumberMain.left(5) + '-' + srNumberMain.mid(5, 4) + '-' + srNumberMain.substring(9);
        }
        return sr;
    }

    /** 
     * 敬称付与処理
    */
    @TestVisible private static String setPostAndTitle(String name, String titleAndPost){
        String result;
        if(String.isBlank(name)){
            result = '';
        } else {
            result = name + titleAndPost;
        }
        return result;
    }

    /** 
     * Date型フォーマット処理
    */
    @TestVisible private static String formatDate(Date targetDate, String template){
        String result;
        if(targetDate == null){
            result = '';
        } else {
            result = String.valueOf(Datetime.newInstance(targetDate.year(), targetDate.month(), targetDate.day()).format(template));
        }
        return result;
    }

    /** 
     * 千円単位変換四捨五入処理
    */
    @TestVisible private static String convertTo1000YenAndRoundHalfUp(Decimal amount){
        if(amount == null){
            return '';
        }
        return String.valueOf((amount / 1000).round(System.RoundingMode.HALF_UP));
    }

    /** 
     * ヘッダー_発信元検印設定処理
    */
    @TestVisible private static String setApprover(RequestTask__c requestTask){
        String approver;
        switch on requestTask.UserDeptLastApprover__c {
            when '承認者1'{
                approver = requestTask.Approver1__r.LastName;
            }
            when '承認者2'{
                approver = requestTask.Approver2__r.LastName;
            }
            when '承認者3'{
                approver = requestTask.Approver3__r.LastName;
            }
            when else {
                approver = '';
            }
        }
        return approver;
    }

    /**
     * 依頼タスク取得し、帳票出力済みフラグtrueに更新する
     * @param requestTaskId　依頼タスクID
     */
    @future
    public static void updateRequestTaskById(Id requestTaskId){
        RequestTask__c rt = [
            SELECT
                DocumentOutputFlag__c
            FROM
                RequestTask__c
            WHERE
                Id = :requestTaskId
        ];
        rt.DocumentOutputFlag__c = true;
        update rt;
    }
}