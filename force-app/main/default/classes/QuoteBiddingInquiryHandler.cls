public without sharing class QuoteBiddingInquiryHandler {
    // 例外発生テスト時のみ使用するフラグ
    public static Boolean errorHappenFlg = false;

    // 実行フラグ
    public static Boolean isRunning = false;

    // 三菱電機の会社コード
    private static final String COMPANY_CODE_MITSUBISHI = System.Label.COMPANY_CODE_MITSUBISHI;

    /**
     * 更新後処理
     */
    public void onAfterUpdate(List<QuoteBiddingInquiry__c> newList,
                                Map<Id,QuoteBiddingInquiry__c> newMap,
                                Map<Id,QuoteBiddingInquiry__c> oldMap){
        if (!isRunning) {
            isRunning = true;
            // エラーチェック処理（after）
            if(onAfterErrorCheck(newList, oldMap)){
                isRunning = false;
                return;
            }
            // ロック解除処理
            unlockRecord(newList, oldMap);
            // フォーミュラ項目を計算する
            updateFormulaFieldsAfter(newList,newMap);
            // 項目を案件に転記する
            updateOpportunities(newList);
            // 非同期処理を実行する
            System.enqueueJob(new QueueableUpdateApprovalInfo(newList,newMap, oldMap));
        }
    }

    /**
     * 案件に決定価格、受注社を転記する
     */
    public void updateOpportunities(List<QuoteBiddingInquiry__c> newList){
        List<Opportunity> updateOpportunities = new List<Opportunity>();
        List<Account> mitsubishiAccount = [SELECT Id FROM Account WHERE MelcoCode__c = :COMPANY_CODE_MITSUBISHI];

        for(QuoteBiddingInquiry__c quoteBiddingInquiry : newList){
            if(QuoteBiddingInquiry.Opportunity__c != null){
                if(quoteBiddingInquiry.BidResult__c == '受注') {
                    // ①応札結果が「受注」の場合
                    // →「当社契約金額」を案件の「決定価格」に転記する
                    // 　”三菱電機　株式会社”を案件の「受注社」に設定する
                    Opportunity opp = new Opportunity(Id = quoteBiddingInquiry.Opportunity__c);
                    opp.FinalPrice__c = quoteBiddingInquiry.OurBidAmount__c;
                    opp.Competitor__c = mitsubishiAccount.size() > 0 ? mitsubishiAccount.get(0).Id : null;
                    opp.CompetitorOther__c = null;
                    updateOpportunities.add(opp);
                } else if(quoteBiddingInquiry.BidResult__c == '失注') {
                    // ②応札結果が「失注」の場合
                    // →「落札金額」を案件の「決定価格」に転記する
                    // 　「落札者」を案件の「受注社」に転記する
                    // 　「落札者(手入力)」を案件の「受注社(手入力)」に転記する
                    Opportunity opp = new Opportunity(Id = quoteBiddingInquiry.Opportunity__c);
                    opp.FinalPrice__c = quoteBiddingInquiry.WinningBidAmount__c;
                    opp.Competitor__c = quoteBiddingInquiry.WinningBidder__c;
                    opp.CompetitorOther__c = quoteBiddingInquiry.ManualWinningBidder__c;
                    updateOpportunities.add(opp);
                }

                // else {
                //     Opportunity opp = new Opportunity(Id = quoteBiddingInquiry.Opportunity__c);
                //     opp.FinalPrice__c = null;
                //     opp.Competitor__c = null;
                //     opp.CompetitorOther__c = null;
                //     updateOpportunities.add(opp);
                // }
            }
        }
        if(updateOpportunities.size() > 0){
            update updateOpportunities;
        }
    }

    /**
     * エラーチェック処理（after）
     */
    public Boolean onAfterErrorCheck(List<QuoteBiddingInquiry__c> newList,
                                Map<Id,QuoteBiddingInquiry__c> oldMap){
        Boolean isError = false;
        // ICP審査対象（ICPReviewTarget__c）= True かつ
        // ICP審査GR確認済（IcpExaminationGrConfirmation__c）= False かつ
        // 変更前の伺い認許ステータス（InquiryApprovalStatus__c） = 事管推部長 かつ
        // 変更後の伺い認許ステータス（InquiryApprovalStatus__c） = GM or 承認済
        // エラーメッセージ 本伺いにおいて、事管推部長の承認にはICP審査GRの確認が済んでいる必要があります。ICP審査GRの確認が未済のため、本伺いは承認できません。
        for(QuoteBiddingInquiry__c QuoteBiddingInquiry : newList){
            if(QuoteBiddingInquiry.ICPReviewTarget__c && !QuoteBiddingInquiry.IcpExaminationGrConfirmation__c
                && oldMap.get(QuoteBiddingInquiry.Id).InquiryApprovalStatus__c == '事管推部長'
                && (QuoteBiddingInquiry.InquiryApprovalStatus__c == 'GM' || QuoteBiddingInquiry.InquiryApprovalStatus__c == '承認済')){
                QuoteBiddingInquiry.addError('本伺いにおいて、事管推部長の承認にはICP審査GRの確認が済んでいる必要があります。ICP審査GRの確認が未済のため、本伺いは承認できません。');
                isError = true;
            }
        }

        return isError;
    }

    /**
     * ロック解除処理
     */
    public void unlockRecord(List<QuoteBiddingInquiry__c> newList,
                            Map<Id,QuoteBiddingInquiry__c> oldMap){
        Savepoint sp = Database.setSavepoint();
        try {
            List<Id> targetIdList = new List<Id>();
            for(QuoteBiddingInquiry__c QuoteBiddingInquiry : newList){
                // ①「伺い認許ステータス」が変更された、かつ 「伺い認許ステータス」が「TL」or「所属課長」の場合、レコードロック解除対象とする
                // ②「結果報告ステータス」が変更された、かつ 「結果報告ステータス」が「所属課長」、レコードロック解除対象とする
                if(QuoteBiddingInquiry.InquiryApprovalStatus__c != oldMap.get(QuoteBiddingInquiry.Id).InquiryApprovalStatus__c
                    || QuoteBiddingInquiry.ResultContactStatus__c != oldMap.get(QuoteBiddingInquiry.Id).ResultContactStatus__c){
                    targetIdList.add(QuoteBiddingInquiry.Id);
                }
            }
            if(targetIdList.size() > 0){
                doUnlock(targetIdList);
            }
            // テスト実行時、かつ例外発生フラグがtrueのときに例外発生
            if(Test.isRunningTest() && errorHappenFlg){
                throw new  ApprovalProcessException();
            }
        } catch (Exception e){
            Database.rollback(sp);
            newList[0].addError('エラーが発生したため再度承認申請を実行してください。エラーを繰り返す場合はシステム管理者に連絡してください。', false);
            System.debug('-----error-------' + e.getStackTraceString());
        }
    }

    /**
     * 登録後処理
     */
    public void onAfterInsert(List<QuoteBiddingInquiry__c> newList,Map<Id,QuoteBiddingInquiry__c> newMap){
        updateFormulaFieldsAfter(newList,newMap);
        Set<Id> idList = new Set<Id>();
        for (QuoteBiddingInquiry__c inquiry : newList) {
            idList.add(inquiry.Id);
        }
        // 見積書提出伺いの場合、受注時見込_CP、受注時見込_TC、受注時見込_WCのデフォルト値を設定する
        updateFieldsAsync(idList);
        //  参照先の見積見積・応札・手数料伺いを設定する
        updateOriginalQuoteBiddingInquiry(idList);
        // 項目を案件に転記する
        updateOpportunities(newList);
        // JV締結認許伺いと手数料伺いを作成する時は関連レコードを全て削除する（JV締結認許伺い→JV締結認許伺いを作成する場合はJV構成員は残す）
        deleteRelatedRecord(idList);
    }

    /**
     * 登録前処理
     */
    public void onBeforeInsert(List<QuoteBiddingInquiry__c> newList){
        updateFormulaFields(newList, null);
    }

    /**
     * 更新前処理
     */
    public void onBeforeUpdate(List<QuoteBiddingInquiry__c> newList, Map<Id, QuoteBiddingInquiry__c> oldMap){
        updateFormulaFields(newList, oldMap);
    }

    /**
     * フォーミュラ項目を計算する
     */
    public void updateFormulaFieldsAfter(List<QuoteBiddingInquiry__c> newList,Map<Id,QuoteBiddingInquiry__c> newMap){
        List<QuoteBiddingInquiry__c> updateList = new List<QuoteBiddingInquiry__c>();
        Set<Id> idList = new Set<Id>();
        Boolean isSpecialFee = false;
        for(QuoteBiddingInquiry__c target : newList){
            idList.add(target.Id);
        }

        // 更新対象を取得する
        List<QuoteBiddingInquiry__c> updateTargetList = [SELECT Id,
                                                            Agency1MaxCalculationFee__c, // 代理店1_算出手数料(MAX)
                                                            Agency2MaxCalculationFee__c, // 代理店2_算出手数料(MAX)
                                                            Agency3MaxCalculationFee__c, // 代理店3_算出手数料(MAX)
                                                            Agency1MinCalculationFee__c, // 代理店1_算出手数料(MIN)
                                                            Agency2MinCalculationFee__c, // 代理店2_算出手数料(MIN)
                                                            Agency3MinCalculationFee__c, // 代理店3_算出手数料(MIN)
                                                            MaxCalculationFeeTotal__c, // 算出手数料(MAX)_合計
                                                            MinCalculationFeeTotal__c, // 算出手数料(MIN)_合計
                                                            TheoryFeeMax__c, // 理論手数料(MAX)
                                                            TheoryFeeMin__c, // 理論手数料(MIN)
                                                            GeneralFeeTotal_MAX__c, // 一般手数料合計(MAX)
                                                            GeneralFeeTotal_MIN__c, // 一般手数料合計(MIN)
                                                            SpecialFeeLimit_MAX__c, // 特別手数料上限(MAX)
                                                            SpecialFeeLimit_MIN__c, // 特別手数料上限(MIN)
                                                            SpecialFeeTotal_MAX__c, // 特別手数料合計(MAX)
                                                            SpecialFeeTotal_MIN__c, // 特別手数料合計(MIN)
                                                            FeePaymentLimitAmount_MAX__c, // 手数料支払上限額(MAX)
                                                            FeePaymentLimitAmount_MIN__c, // 手数料支払上限額(MIN)
                                                            DeterminingFeeTotal_MAX__c, // 決定手数料合計(MAX)
                                                            DeterminingFeeTotal_MIN__c, // 決定手数料合計(MIN)
                                                            Agency1MaxFee__c, // 代理店1_決定手数料(MAX)
                                                            Agency2MaxFee__c, // 代理店
                                                            Agency3MaxFee__c, // 代理店3_決定手数料(MAX)
                                                            Agency1StoreName__c,//代理店1_店名(手数料伺い)
                                                            EvaluationComment1__c,//代理店1_申請理由・評価コメント
                                                            Agency2Name__c,//代理店2_店名(手数料伺い)
                                                            EvaluationComment2__c,//代理店2_申請理由・評価コメント
                                                            Agency3Name__c,//代理店3_店名(手数料伺い)
                                                            EvaluationComment3__c,//代理店3_申請理由・評価コメント
                                                            Creating__c, //伺い作成中
                                                            RecordType.DeveloperName, // レコードタイプ名
                                                            ExpectProfitAndLossOnOrderCP__c, // 受注時見込_CP
                                                            ExpectProfitAndLossOnOrderTC__c, // 受注時見込_TC
                                                            ExpectProfitAndLossOnOrderWC__c, // 受注時見込_WC
                                                            PriceProposal1MaxCP__c, // 価格案_CP(伺い数値明細)
                                                            PriceProposal1MaxWC__c, // 価格案_WC(伺い数値明細)
                                                            PriceProposal1MaxTC__c  // 価格案_TC(伺い数値明細)
                                                        FROM QuoteBiddingInquiry__c
                                                        WHERE Id IN :idList];


        for(QuoteBiddingInquiry__c QuoteBiddingInquiry : updateTargetList){
            // 算出手数料(MAX)_合計 MaxCalculationFeeTotal__c
            // 「代理店1_算出手数料(MAX)」Agency1MaxCalculationFee__c + 「代理店2_算出手数料(MAX)」 + 「代理店3_算出手数料(MAX)」
            QuoteBiddingInquiry.MaxCalculationFeeTotal__c = (QuoteBiddingInquiry.Agency1MaxCalculationFee__c==null? 0 : QuoteBiddingInquiry.Agency1MaxCalculationFee__c) 
                                                            + (QuoteBiddingInquiry.Agency2MaxCalculationFee__c==null? 0 : QuoteBiddingInquiry.Agency2MaxCalculationFee__c) 
                                                            + (QuoteBiddingInquiry.Agency3MaxCalculationFee__c==null? 0 : QuoteBiddingInquiry.Agency3MaxCalculationFee__c);

            // 算出手数料(MIN)_合計 MinCalculationFeeTotal__c
            // 「代理店1_算出手数料(MIN)」Agency1MinCalculationFee__c + 「代理店2_算出手数料(MIN)」 + 「代理店3_算出手数料(MIN)」
            QuoteBiddingInquiry.MinCalculationFeeTotal__c = (QuoteBiddingInquiry.Agency1MinCalculationFee__c==null? 0 : QuoteBiddingInquiry.Agency1MinCalculationFee__c) 
                                                            + (QuoteBiddingInquiry.Agency2MinCalculationFee__c==null? 0 : QuoteBiddingInquiry.Agency2MinCalculationFee__c) 
                                                            + (QuoteBiddingInquiry.Agency3MinCalculationFee__c==null? 0 : QuoteBiddingInquiry.Agency3MinCalculationFee__c);


            // 一般手数料合計(MAX) GeneralFeeTotal_MAX
            // IF(
            //  「算出手数料(MAX)_合計」MaxCalculationFeeTotal__c- 「理論手数料(MAX)」TheoryFeeMax__c  > 0,
            //  「理論手数料(MAX)」,
            //  「算出手数料(MAX)_合計」
            // )
            QuoteBiddingInquiry.GeneralFeeTotal_MAX__c = QuoteBiddingInquiry.MaxCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMax__c
                                                            > 0 ?  QuoteBiddingInquiry.TheoryFeeMax__c : QuoteBiddingInquiry.MaxCalculationFeeTotal__c;

            // 一般手数料合計(MIN) GeneralFeeTotal_MIN
            // IF(
            //  「算出手数料(MIN)_合計」MinCalculationFeeTotal__c - 「理論手数料(MIN)」 > 0,
            //  「理論手数料(MIN)」,
            //  「算出手数料(MIN)_合計」
            // )
            QuoteBiddingInquiry.GeneralFeeTotal_MIN__c = QuoteBiddingInquiry.MinCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMin__c
                                                            > 0 ? QuoteBiddingInquiry.TheoryFeeMin__c : QuoteBiddingInquiry.MinCalculationFeeTotal__c;

            // 特別手数料合計(MAX) SpecialFeeTotal_MAX
            // IF(
            //  IF(
            //      「算出手数料(MAX)_合計」 - 「理論手数料(MAX)」>= 0,
            //      「算出手数料(MAX)_合計」 - 「理論手数料(MAX)」,
            //      0
            //  ) >= 「特別手数料上限(MAX)」SpecialFeeLimit_MAX__c ,
            //  「特別手数料上限(MAX)」SpecialFeeLimit_MAX__c,
            //  IF(
            //      「算出手数料(MAX)_合計」 - 「理論手数料(MAX)」>= 0,
            //      「算出手数料(MAX)_合計」 - 「理論手数料(MAX)」,
            //      0
            //  )
            // )
            QuoteBiddingInquiry.SpecialFeeTotal_MAX__c =
                (QuoteBiddingInquiry.MaxCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMax__c >= 0 ?
                    QuoteBiddingInquiry.MaxCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMax__c : 0) >= QuoteBiddingInquiry.SpecialFeeLimit_MAX__c ?
                    QuoteBiddingInquiry.SpecialFeeLimit_MAX__c :
                    (QuoteBiddingInquiry.MaxCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMax__c >= 0 ?
                        QuoteBiddingInquiry.MaxCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMax__c : 0);


            // 特別手数料合計(MIN) SpecialFeeTotal_MIN
            // IF(
            //  IF(
            //      「算出手数料(MIN)_合計」 - 「理論手数料(MIN)」>= 0,
            //      「算出手数料(MIN)_合計」 - 「理論手数料(MIN)」,
            //      0
            //  ) >= 「特別手数料上限計(MIN)」SpecialFeeLimit_MIN__c,
            //  「特別手数料上限(MIN)」SpecialFeeLimit_MIN__c,
            //  IF(
            //      「算出手数料(MIN)_合計」 - 「理論手数料(MIN)」>= 0,
            //      「算出手数料(MIN)_合計」 - 「理論手数料(MIN)」,
            //      0
            //  )
            // )
            QuoteBiddingInquiry.SpecialFeeTotal_MIN__c =
                (QuoteBiddingInquiry.MinCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMin__c >= 0 ?
                    QuoteBiddingInquiry.MinCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMin__c : 0) >= QuoteBiddingInquiry.SpecialFeeLimit_MIN__c ?
                    QuoteBiddingInquiry.SpecialFeeLimit_MIN__c :
                    (QuoteBiddingInquiry.MinCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMin__c >= 0 ?
                        QuoteBiddingInquiry.MinCalculationFeeTotal__c - QuoteBiddingInquiry.TheoryFeeMin__c : 0);

            // 決定手数料合計(MAX) DeterminingFeeTotal_MAX
            // IF(
            // 　　「算出手数料(MAX)_合計」 > 「手数料支払上限額(MAX)」FeePaymentLimitAmount_MAX__c,
            // 　　「手数料支払上限額(MAX)」,
            // 　　「一般手数料合計(MAX)」 + 「特別手数料合計(MAX)」
            // )
            QuoteBiddingInquiry.DeterminingFeeTotal_MAX__c = QuoteBiddingInquiry.MaxCalculationFeeTotal__c > QuoteBiddingInquiry.FeePaymentLimitAmount_MAX__c ? 
                                                            QuoteBiddingInquiry.FeePaymentLimitAmount_MAX__c :
                                                            QuoteBiddingInquiry.GeneralFeeTotal_MAX__c + QuoteBiddingInquiry.SpecialFeeTotal_MAX__c;

            System.debug('-------決定手数料合計(MAX)-----' + QuoteBiddingInquiry.DeterminingFeeTotal_MAX__c);
            // 決定手数料合計(MIN) DeterminingFeeTotal_MIN__c
            // IF(
            // 　　「算出手数料(MIN)_合計」 > 「手数料支払上限額(MIN)」,
            // 　　「手数料支払上限額(MIN)」,
            // 　　「一般手数料合計(MIN)」 + 「特別手数料合計(MIN)」
            // )
            QuoteBiddingInquiry.DeterminingFeeTotal_MIN__c = QuoteBiddingInquiry.MinCalculationFeeTotal__c > QuoteBiddingInquiry.FeePaymentLimitAmount_MIN__c ? 
                                                            QuoteBiddingInquiry.FeePaymentLimitAmount_MIN__c :
                                                            QuoteBiddingInquiry.GeneralFeeTotal_MIN__c + QuoteBiddingInquiry.SpecialFeeTotal_MIN__c;
            System.debug('-------決定手数料合計(MIN)-----' + QuoteBiddingInquiry.DeterminingFeeTotal_MIN__c);

            // 代理店1_決定手数料(MAX) Agency1MaxFee__c
            if (QuoteBiddingInquiry.MaxCalculationFeeTotal__c > QuoteBiddingInquiry.FeePaymentLimitAmount_MAX__c){
                QuoteBiddingInquiry.Agency1MaxFee__c = (QuoteBiddingInquiry.FeePaymentLimitAmount_MAX__c * (QuoteBiddingInquiry.Agency1MaxCalculationFee__c==null ? 0: QuoteBiddingInquiry.Agency1MaxCalculationFee__c) / QuoteBiddingInquiry.MaxCalculationFeeTotal__c / 100).round(System.RoundingMode.UP) * 100;
            }else{
                QuoteBiddingInquiry.Agency1MaxFee__c = (QuoteBiddingInquiry.Agency1MaxCalculationFee__c==null ? 0: QuoteBiddingInquiry.Agency1MaxCalculationFee__c);
            }

            // 代理店2_決定手数料(MAX) Agency2MaxFee__c
            if (QuoteBiddingInquiry.MaxCalculationFeeTotal__c > QuoteBiddingInquiry.FeePaymentLimitAmount_MAX__c){
                QuoteBiddingInquiry.Agency2MaxFee__c = (QuoteBiddingInquiry.FeePaymentLimitAmount_MAX__c * (QuoteBiddingInquiry.Agency2MaxCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency2MaxCalculationFee__c) / QuoteBiddingInquiry.MaxCalculationFeeTotal__c / 100).round(System.RoundingMode.UP) * 100;
            }else{
                QuoteBiddingInquiry.Agency2MaxFee__c = (QuoteBiddingInquiry.Agency2MaxCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency2MaxCalculationFee__c) ;
            }

            // 代理店3_決定手数料(MAX) Agency3MaxFee__c
            if (QuoteBiddingInquiry.MaxCalculationFeeTotal__c > QuoteBiddingInquiry.FeePaymentLimitAmount_MAX__c){
                QuoteBiddingInquiry.Agency3MaxFee__c = (QuoteBiddingInquiry.FeePaymentLimitAmount_MAX__c * (QuoteBiddingInquiry.Agency3MaxCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency3MaxCalculationFee__c) / QuoteBiddingInquiry.MaxCalculationFeeTotal__c / 100).round(System.RoundingMode.UP) * 100;
            }else{
                QuoteBiddingInquiry.Agency3MaxFee__c = (QuoteBiddingInquiry.Agency3MaxCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency3MaxCalculationFee__c);
            }

            // 代理店1_決定手数料(MIN) Agency1MinFee__c
            if (QuoteBiddingInquiry.MinCalculationFeeTotal__c > QuoteBiddingInquiry.FeePaymentLimitAmount_MIN__c){
                QuoteBiddingInquiry.Agency1MinFee__c = (QuoteBiddingInquiry.FeePaymentLimitAmount_MIN__c * (QuoteBiddingInquiry.Agency1MinCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency1MinCalculationFee__c) / QuoteBiddingInquiry.MinCalculationFeeTotal__c / 100).round(System.RoundingMode.UP) * 100;
            }else{
                QuoteBiddingInquiry.Agency1MinFee__c = (QuoteBiddingInquiry.Agency1MinCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency1MinCalculationFee__c);
            }

            // 代理店2_決定手数料(MIN) Agency2MinFee__c
            if (QuoteBiddingInquiry.MinCalculationFeeTotal__c > QuoteBiddingInquiry.FeePaymentLimitAmount_MIN__c){
                QuoteBiddingInquiry.Agency2MinFee__c = (QuoteBiddingInquiry.FeePaymentLimitAmount_MIN__c * (QuoteBiddingInquiry.Agency2MinCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency2MinCalculationFee__c) / QuoteBiddingInquiry.MinCalculationFeeTotal__c / 100).round(System.RoundingMode.UP) * 100;
            }else{
                QuoteBiddingInquiry.Agency2MinFee__c = (QuoteBiddingInquiry.Agency2MinCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency2MinCalculationFee__c);
            }

            // 代理店3_決定手数料(MIN) Agency3MinFee__c
            if (QuoteBiddingInquiry.MinCalculationFeeTotal__c > QuoteBiddingInquiry.FeePaymentLimitAmount_MIN__c){
                QuoteBiddingInquiry.Agency3MinFee__c = (QuoteBiddingInquiry.FeePaymentLimitAmount_MIN__c * (QuoteBiddingInquiry.Agency3MinCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency3MinCalculationFee__c) / QuoteBiddingInquiry.MinCalculationFeeTotal__c / 100).round(System.RoundingMode.UP) * 100;
            }else{
                QuoteBiddingInquiry.Agency3MinFee__c = (QuoteBiddingInquiry.Agency3MinCalculationFee__c==null ? 0 : QuoteBiddingInquiry.Agency3MinCalculationFee__c);
            }

            updateList.add(QuoteBiddingInquiry);

            // 見積伺いの場合
            // if(QuoteBiddingInquiry.RecordType.DeveloperName == 'M' && !isUpdate){
            //     // 受注時見込_CP
            //     QuoteBiddingInquiry.ExpectProfitAndLossOnOrderCP__c = QuoteBiddingInquiry.PriceProposal1MaxCP__c;
            //     // 受注時見込_TC
            //     QuoteBiddingInquiry.ExpectProfitAndLossOnOrderTC__c = QuoteBiddingInquiry.PriceProposal1MaxTC__c;
            //     // 受注時見込_WC
            //     QuoteBiddingInquiry.ExpectProfitAndLossOnOrderWC__c = QuoteBiddingInquiry.PriceProposal1MaxWC__c;
            // }

        }

        if (!updateList.isEmpty()) {
            update updateList;
        }
    }

    /**
     * 見積書提出伺いの場合、受注時見込_CP、受注時見込_TC、受注時見込_WCのデフォルト値を設定する
     * ※案件の場所別合計
     * @param recordIds 見積・応札・手数料伺いID
     */
    public void updateFieldsAsync(Set<Id> recordIds) {
        List<QuoteBiddingInquiry__c> updateLists = new List<QuoteBiddingInquiry__c>();
        List<QuoteBiddingInquiry__c> inquiries = [SELECT Id,
                                                        Opportunity__c, // 案件
                                                        RecordType.DeveloperName, // レコードタイプ名
                                                        ExpectProfitAndLossOnOrderCP__c, // 受注時見込_CP
                                                        ExpectProfitAndLossOnOrderTC__c, // 受注時見込_TC
                                                        ExpectProfitAndLossOnOrderWC__c   // 受注時見込_WC
                                                FROM QuoteBiddingInquiry__c WHERE Id IN :recordIds];

        Set<Id> oppIds = new Set<Id>();
        for (QuoteBiddingInquiry__c inquiry : inquiries) {
            if(inquiry.RecordType.DeveloperName == 'M'){
                oppIds.add(inquiry.Opportunity__c);
            }
        }

        // 案件の場所別からCP, TC, WCの合計を取得
        List<AggregateResult> opps = [SELECT Opp1__c, SUM(SR_CP__c) sumCP, SUM(TC__c) sumTC, SUM(SRWC__c) sumWC
                                        FROM Factory__c
                                        WHERE Opp1__c =: oppIds
                                        GROUP BY Opp1__c];
        for (QuoteBiddingInquiry__c inquiry : inquiries) {
            if(inquiry.RecordType.DeveloperName == 'M' && inquiry.Opportunity__c != null){
                for (AggregateResult opp : opps) {
                    if (inquiry.Opportunity__c == (Id)opp.get('Opp1__c')) {
                        // 受注時見込_CP
                        inquiry.ExpectProfitAndLossOnOrderCP__c = (Decimal)opp.get('sumCP');
                        // 受注時見込_TC
                        inquiry.ExpectProfitAndLossOnOrderTC__c = (Decimal)opp.get('sumTC');
                        // 受注時見込_WC
                        inquiry.ExpectProfitAndLossOnOrderWC__c = (Decimal)opp.get('sumWC');
                        updateLists.add(inquiry);
                    }
                }
            }
        }

        if (updateLists.size() > 0) {
            update updateLists;
        }
    }

    /**
     * 流用データの更新処理
     * 　参照先の見積見積・応札・手数料伺いを設定する
     * 　※案件の場所別合計
     * 　流用元と流用先の伺い種別が異なる場合は伺い内容説明をブランクとする
     * @param recordIds 見積・応札・手数料伺いID
     */
    public void updateOriginalQuoteBiddingInquiry(Set<Id> recordIds) {

        List<QuoteBiddingInquiry__c> updateLists = new List<QuoteBiddingInquiry__c>();
        List<QuoteBiddingInquiry__c> inquiries = [SELECT Id,
                                                        InquiryApplicationComment__c,
                                                        RecordType.DeveloperName, // レコードタイプ名　
                                                        OriginalSFID__c // SFID（コピー参照元用）
                                                FROM QuoteBiddingInquiry__c WHERE Id IN :recordIds];

        Set<Id> ids = new Set<Id>();
        for (QuoteBiddingInquiry__c inquiry : inquiries) {
            if(String.isNotBlank(inquiry.OriginalSFID__c)){
                ids.add(inquiry.OriginalSFID__c);
            }
        }

        Map<id,QuoteBiddingInquiry__c> originalQuoteBiddingInquiry = new Map<id,QuoteBiddingInquiry__c>([SELECT Id,
                                                                                                                RecordType.DeveloperName // レコードタイプ名　
                                                                                                        FROM QuoteBiddingInquiry__c WHERE Id IN :ids]);

        for (QuoteBiddingInquiry__c inquiry : inquiries) {
            if(String.isBlank(inquiry.OriginalSFID__c)){
                inquiry.OriginalSFID__c = inquiry.Id;
                updateLists.add(inquiry);
            } else {
                if(originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName == 'M'){
                    if(inquiry.RecordType.DeveloperName !=originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName) {
                        inquiry.InquiryApplicationComment__c = '';
                    }
                    inquiry.DependentEstimateInquiry__c = inquiry.OriginalSFID__c;
                    updateLists.add(inquiry);
                } else if(originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName == 'O'){
                    if(inquiry.RecordType.DeveloperName !=originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName) {
                        inquiry.InquiryApplicationComment__c = '';
                    }
                    inquiry.DependentBiddingInquiry__c = inquiry.OriginalSFID__c;
                    updateLists.add(inquiry);
                } else if(originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName == 'JV'){
                    if(inquiry.RecordType.DeveloperName !=originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName) {
                        inquiry.InquiryApplicationComment__c = '';
                    }
                    inquiry.DependentJvInquiry__c = inquiry.OriginalSFID__c;
                    updateLists.add(inquiry);
                } else if(originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName == 'FeeInquiry'){
                    if(inquiry.RecordType.DeveloperName !=originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName) {
                        inquiry.InquiryApplicationComment__c = '';
                    }
                    inquiry.DependentFeeInquiry__c = inquiry.OriginalSFID__c;
                    updateLists.add(inquiry);
                } else {
                    if(inquiry.RecordType.DeveloperName !=originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName) {
                        inquiry.InquiryApplicationComment__c = '';
                        updateLists.add(inquiry);
                    }
                }
            }
        }

        if (updateLists.size() > 0) {
            update updateLists;
        }
    }

    /**
     * JV締結認許伺いと手数料伺いを作成する時は関連レコードを全て削除する
     * （JV締結認許伺い→JV締結認許伺いを作成する場合はJV構成員は残す）
     * @param recordIds 見積・応札・手数料伺いID
     */
    // 非同期処理
    @future
    public static void deleteRelatedRecord(Set<Id> recordIds) {
        Set<Id> deletedRelatedIds = new Set<Id>();
        Set<Id> deletedRelatedIdsForSH = new Set<Id>();
        Set<Id> deletedRelatedJVMemberIds = new Set<Id>();
        List<QuoteBiddingInquiry__c> inquiries = [SELECT Id,
                                                        OriginalSFID__c,  // SFID（コピー参照元用）
                                                        RecordType.DeveloperName, // レコードタイプ名
                                                        IsCreatDetailFromSR__c//SR情報から転記フラグ（設計変更流用時用）
                                                FROM QuoteBiddingInquiry__c WHERE Id IN :recordIds];

        Set<Id> updateIds = new Set<Id>();
        Set<Id> ids = new Set<Id>();
        for (QuoteBiddingInquiry__c inquiry : inquiries) {
            if(String.isNotBlank(inquiry.OriginalSFID__c)){
                ids.add(inquiry.OriginalSFID__c);
            }
            updateIds.add(inquiry.Id);
        }

        Map<id,QuoteBiddingInquiry__c> originalQuoteBiddingInquiry = new Map<id,QuoteBiddingInquiry__c>([SELECT Id,
                                                                                                                RecordType.DeveloperName // レコードタイプ名　
                                                                                                        FROM QuoteBiddingInquiry__c WHERE Id IN :ids]);

        for (QuoteBiddingInquiry__c inquiry : inquiries) {
            // JV締結認許伺い
            if(inquiry.RecordType.DeveloperName == 'JV'){
                if(originalQuoteBiddingInquiry.get(inquiry.OriginalSFID__c).RecordType.DeveloperName == 'JV'){
                    deletedRelatedIds.add(inquiry.id);
                } else {
                    deletedRelatedIds.add(inquiry.id);
                    deletedRelatedJVMemberIds.add(inquiry.id);
                }
            } else if(inquiry.RecordType.DeveloperName == 'FeeInquiry'){
                deletedRelatedIds.add(inquiry.id);
                deletedRelatedJVMemberIds.add(inquiry.id);
            } else if(inquiry.RecordType.DeveloperName == 'SH' && inquiry.IsCreatDetailFromSR__c){
                deletedRelatedIdsForSH.add(inquiry.id);
            } else {
                deletedRelatedJVMemberIds.add(inquiry.id);
            }
        }

        if (deletedRelatedIds.size() > 0) {
            // 伺い場所別数値明細
            List<DetailByInquiryFactory__c> aa = [SELECT Id FROM DetailByInquiryFactory__c WHERE QuoteBiddingInquiry__c IN :deletedRelatedIds];
            delete [SELECT Id FROM DetailByInquiryFactory__c WHERE QuoteBiddingInquiry__c IN :deletedRelatedIds];


            // 伺い商流明細
            List<InquiryCommercialDistributionDetail__c> bbb = [SELECT Id FROM InquiryCommercialDistributionDetail__c WHERE QuoteBiddingInquiry__c IN :deletedRelatedIds];
            delete [SELECT Id FROM InquiryCommercialDistributionDetail__c WHERE QuoteBiddingInquiry__c IN :deletedRelatedIds];
        }

        if (deletedRelatedJVMemberIds.size() > 0) {
            List<JVMember__c> aa = [SELECT Id FROM JVMember__c WHERE QuoteBiddingInquiry__c IN :deletedRelatedJVMemberIds];
            // JV構成員
            delete [SELECT Id FROM JVMember__c WHERE QuoteBiddingInquiry__c IN :deletedRelatedJVMemberIds];
        }

        //設計変更応札伺い流用先からの明細レコードを削除する
        if (deletedRelatedIdsForSH.size() > 0) {
            // 伺い場所別数値明細
            List<DetailByInquiryFactory__c> deleteDetailListForSH = [SELECT Id FROM DetailByInquiryFactory__c WHERE QuoteBiddingInquiry__c IN :deletedRelatedIdsForSH and isFromOpportunity__c = false];
            delete deleteDetailListForSH;
            List<DetailByInquiryFactory__c> updateDetailListForSH = [SELECT Id FROM DetailByInquiryFactory__c WHERE QuoteBiddingInquiry__c IN :deletedRelatedIdsForSH and isFromOpportunity__c = true];
            //フラグ復元
            if(updateDetailListForSH.size() > 0){
                for (DetailByInquiryFactory__c d : updateDetailListForSH) {
                    d.isFromOpportunity__c = false;
                }
                update updateDetailListForSH;
            }

        }

        List<QuoteBiddingInquiry__c> updateList = new List<QuoteBiddingInquiry__c>();
        for (QuoteBiddingInquiry__c inquiry : inquiries) {
            inquiry.OriginalSFID__c = inquiry.Id;
            inquiry.IsCreatDetailFromSR__c = false;
            updateList.add(inquiry);
        }

        if (updateList.size() > 0) {
            update updateList;
        }
    }

    /**
     * フォーミュラ項目を計算する
     */
    public void updateFormulaFields(List<QuoteBiddingInquiry__c> newList, Map<Id, QuoteBiddingInquiry__c> oldMap){

        for(QuoteBiddingInquiry__c QuoteBiddingInquiry : newList){
            // 理論手数料(MIN)_切り上げ前（TheoryFeeMin_BeforeRoundup__c）
            if(QuoteBiddingInquiry.ContractAmountMin__c == null){
                QuoteBiddingInquiry.TheoryFeeMin_BeforeRoundup__c = 0;
            }else if(QuoteBiddingInquiry.ContractAmountMin__c <= 2000000){
                QuoteBiddingInquiry.TheoryFeeMin_BeforeRoundup__c = QuoteBiddingInquiry.ContractAmountMin__c * 0.08;
            }else if(QuoteBiddingInquiry.ContractAmountMin__c <= 6000000){
                QuoteBiddingInquiry.TheoryFeeMin_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMin__c - 2000000) * 0.05 + 160000;
            }else if(QuoteBiddingInquiry.ContractAmountMin__c <= 10000000){
                QuoteBiddingInquiry.TheoryFeeMin_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMin__c - 6000000) * 0.04 + 360000;
            }else if(QuoteBiddingInquiry.ContractAmountMin__c <= 20000000){
                QuoteBiddingInquiry.TheoryFeeMin_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMin__c - 10000000) * 0.03 + 520000;
            }else if(QuoteBiddingInquiry.ContractAmountMin__c <= 40000000){
                QuoteBiddingInquiry.TheoryFeeMin_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMin__c - 20000000) * 0.02 + 820000;
            }else if(QuoteBiddingInquiry.ContractAmountMin__c <= 100000000){
                QuoteBiddingInquiry.TheoryFeeMin_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMin__c - 40000000) * 0.015 + 1220000;
            }else if(QuoteBiddingInquiry.ContractAmountMin__c > 100000000){
                QuoteBiddingInquiry.TheoryFeeMin_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMin__c - 100000000) * 0.01 + 2120000;
            }

            // 理論手数料(MAX)_切り上げ前（TheoryFeeMax_BeforeRoundup__c）
            if(QuoteBiddingInquiry.ContractAmountMax__c == null) {
                QuoteBiddingInquiry.TheoryFeeMax_BeforeRoundup__c = 0;
            }else if(QuoteBiddingInquiry.ContractAmountMax__c <= 2000000){
                QuoteBiddingInquiry.TheoryFeeMax_BeforeRoundup__c = QuoteBiddingInquiry.ContractAmountMax__c * 0.08;
            }else if(QuoteBiddingInquiry.ContractAmountMax__c <= 6000000){
                QuoteBiddingInquiry.TheoryFeeMax_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMax__c - 2000000) * 0.05 + 160000;
            }else if(QuoteBiddingInquiry.ContractAmountMax__c <= 10000000){
                QuoteBiddingInquiry.TheoryFeeMax_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMax__c - 6000000) * 0.04 + 360000;
            }else if(QuoteBiddingInquiry.ContractAmountMax__c <= 20000000){
                QuoteBiddingInquiry.TheoryFeeMax_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMax__c - 10000000) * 0.03 + 520000;
            }else if(QuoteBiddingInquiry.ContractAmountMax__c <= 40000000){
                QuoteBiddingInquiry.TheoryFeeMax_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMax__c - 20000000) * 0.02 + 820000;
            }else if(QuoteBiddingInquiry.ContractAmountMax__c <= 100000000){
                QuoteBiddingInquiry.TheoryFeeMax_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMax__c - 40000000) * 0.015 + 1220000;
            }else if(QuoteBiddingInquiry.ContractAmountMax__c > 100000000){
                QuoteBiddingInquiry.TheoryFeeMax_BeforeRoundup__c = (QuoteBiddingInquiry.ContractAmountMax__c - 100000000) * 0.01 + 2120000;
            }

            //①～③に基づく判定結果（CategoryCoefficient__c）
            if(QuoteBiddingInquiry.LastCustomerCategory__c == '継続顧客・継続部門' && QuoteBiddingInquiry.ConstructionDistinction__c == '保守・点検・修繕等'){
                QuoteBiddingInquiry.CategoryCoefficient__c = 0.8;
            }else if(QuoteBiddingInquiry.LastCustomerCategory__c == '継続顧客・継続部門' && QuoteBiddingInquiry.ConstructionDistinction__c == '当社既設' && QuoteBiddingInquiry.BusinessCategory__c == '既存事業'){
                QuoteBiddingInquiry.CategoryCoefficient__c = 1.0;
            }else if(QuoteBiddingInquiry.LastCustomerCategory__c == '継続顧客・継続部門' && (QuoteBiddingInquiry.ConstructionDistinction__c == '他社既設' || QuoteBiddingInquiry.ConstructionDistinction__c == '新設') && QuoteBiddingInquiry.BusinessCategory__c == '既存事業'){
                QuoteBiddingInquiry.CategoryCoefficient__c = 1.2;
            }else if((QuoteBiddingInquiry.LastCustomerCategory__c == '継続顧客・新規部門' || QuoteBiddingInquiry.LastCustomerCategory__c == '新規顧客') && (QuoteBiddingInquiry.ConstructionDistinction__c == '他社既設' || QuoteBiddingInquiry.ConstructionDistinction__c == '新設') && QuoteBiddingInquiry.BusinessCategory__c == '既存事業'){
                QuoteBiddingInquiry.CategoryCoefficient__c = 1.3;
            }else if(QuoteBiddingInquiry.ConstructionDistinction__c != '保守・点検・修繕等' && QuoteBiddingInquiry.BusinessCategory__c == '新規・拡販事業'){
                QuoteBiddingInquiry.CategoryCoefficient__c = 1.5;
            }else{
                QuoteBiddingInquiry.CategoryCoefficient__c = null;
            }

            // ICP審査GR確認済がTrueの場合、ICP審査GR確認日時を更新する
            if(QuoteBiddingInquiry.IcpExaminationGrConfirmation__c && (oldMap == null || !oldMap.get(QuoteBiddingInquiry.Id).IcpExaminationGrConfirmation__c)) {
                QuoteBiddingInquiry.IcpExaminationGrConfirmationTimestamp__c = System.now();
            }else if(!QuoteBiddingInquiry.IcpExaminationGrConfirmation__c){
                QuoteBiddingInquiry.IcpExaminationGrConfirmationTimestamp__c = null;
            }

            if(QuoteBiddingInquiry.BidResult__c == '受注'){
                List<Account> mitsubishiAccount = [SELECT Id FROM Account WHERE MelcoCode__c = :COMPANY_CODE_MITSUBISHI];
                QuoteBiddingInquiry.OrderCompany__c = mitsubishiAccount.size() > 0 ? mitsubishiAccount.get(0).Id : null;
            }
        }
    }

    /**
     * 非同期処理を実行する
     */
    public class QueueableUpdateApprovalInfo implements Queueable {
        List<QuoteBiddingInquiry__c> newList;
        Map<Id,QuoteBiddingInquiry__c> newMap;
        Map<Id,QuoteBiddingInquiry__c> oldMap;

        public QueueableUpdateApprovalInfo(List<QuoteBiddingInquiry__c> newList,
                                Map<Id,QuoteBiddingInquiry__c> newMap,
                                Map<Id,QuoteBiddingInquiry__c> oldMap){
            this.newList = newList;
            this.newMap = newMap;
            this.oldMap = oldMap;
        }
        public void execute(System.QueueableContext context) {
            System.debug('-----WaitOneMinuteJob start-------');
            Long startTime = Datetime.now().getTime();
            Long endTime = startTime + 30000;
            if (!Test.isRunningTest()) {
                while(Datetime.now().getTime() < endTime){
                    // 30秒待つ
                }
            }
            // 見積・伺いの現在の承認者、承認ステップ名、承認割り当て日時を更新する
            this.UpdateApprovalInfo(newList, newMap, oldMap);
            System.debug('-----WaitOneMinuteJob end-------');
        }

        /**
         * 承認プロセスインスタンス新規作成・更新時、
         * 見積・伺いの現在の承認者、承認ステップ名、承認割り当て日時を更新する
         */
        public void UpdateApprovalInfo(List<QuoteBiddingInquiry__c> newList,
                                        Map <Id, QuoteBiddingInquiry__c> newMap,
                                        Map <Id, QuoteBiddingInquiry__c> oldMap){
            Savepoint sp = Database.setSavepoint();
            try{
                Set<Id> QuoteBiddingInquiryIds = new Set<Id>();
                for(QuoteBiddingInquiry__c QuoteBiddingInquiry : newList){
                    // 伺い認許ステータス、あるいは　結果報告ステータスを変更時、or、承認者手動設定かつ未承認アラート発信日時設定対象がfalse→trueになった時
                    if(QuoteBiddingInquiry.InquiryApprovalStatus__c != oldMap.get(QuoteBiddingInquiry.Id).InquiryApprovalStatus__c
                        || QuoteBiddingInquiry.ResultContactStatus__c != oldMap.get(QuoteBiddingInquiry.Id).ResultContactStatus__c
                        || (QuoteBiddingInquiry.ApprovalPattern__c == '手動設定'
                        && ((QuoteBiddingInquiry.TargetForUnapprovedRemindLimitSet__c && !oldMap.get(QuoteBiddingInquiry.Id).TargetForUnapprovedRemindLimitSet__c)
                        || (QuoteBiddingInquiry.ApprovalAssignmentDateTime__c == null && oldMap.get(QuoteBiddingInquiry.Id).ApprovalAssignmentDateTime__c != null)))){
                        QuoteBiddingInquiryIds.add(QuoteBiddingInquiry.Id);
                    }
                }

                // 対象がない場合、処理を終了する
                if(QuoteBiddingInquiryIds.isEmpty()){
                    return;
                }

                DateTime sysdate = System.now(); // 現在の日時を取得

                DateTime resultDateAfter18Hours = sysdate.addHours(18); // 現在の日時に18時間を加える
                DateTime resultDateAfter24Hours = sysdate.addHours(24); // 現在の日時に24時間を加える

                // DateTimeをJSTに変換し、Dateに変換する(休日マスタ検索用)
                Date resultDateAfter18HoursJST = Date.valueOf(resultDateAfter18Hours.addHours(9));
                Date resultDateAfter24HoursJST = Date.valueOf(resultDateAfter24Hours.addHours(9));

                // 18時間後の休日マスタを取得する
                List<Holiday> holidayAfter18Hours = [SELECT Id,
                                                      ActivityDate // 休日
                                                FROM Holiday
                                                WHERE ActivityDate >=:resultDateAfter18HoursJST];
                Map<Date,Holiday> holidayAfter18HoursMap = new Map<Date,Holiday>();
                for(Holiday holiday : holidayAfter18Hours){
                    holidayAfter18HoursMap.put(holiday.ActivityDate, holiday);
                }
                // 24時間後の休日マスタを取得する
                List<Holiday> holidayAfter24Hours = [SELECT Id,
                                                      ActivityDate // 休日
                                                FROM Holiday
                                                WHERE ActivityDate >=:resultDateAfter24HoursJST];
                Map<Date,Holiday> holidayAfter24HoursMap = new Map<Date,Holiday>();
                for(Holiday holiday : holidayAfter24Hours){
                    holidayAfter24HoursMap.put(holiday.ActivityDate, holiday);
                }

                // 更新対象を取得する
                List<QuoteBiddingInquiry__c> UpdateQuoteBiddingInquiryList = [SELECT Id,
                                                                                    AdditionalPostInquiryApplication__c,// 兼務側の伺い申請
                                                                                    CurrentApproverText__c, // 現在の承認者
                                                                                    ApprovallStepsName__c, // 承認ステップ名
                                                                                    ApprovalAssigningTime__c, // 承認割り当て時間
                                                                                    ApprovalAssignmentDateTime__c, // 承認割り当て日時
                                                                                    UnapprovedRemindCategory__c, // 未承認アラートカテゴリ
                                                                                    TargetForUnapprovedRemindLimitSet__c, // 未承認アラート対象
                                                                                    UnapprovedRemindLimit__c, // 未承認アラート発信日時
                                                                                    ICPReviewTarget__c, // ICP審査対象
                                                                                    FinalApprover__c, // 最終承認者
                                                                                    UnapprovedRemindTargetProcessInstanceId__c, // 未承認アラート対象プロセスインスタンスID
                                                                                    InquiryApprovalStatus__c, //伺い認許ステータス
                                                                                    ResultContactStatus__c, // 結果報告ステータス
                                                                                    RequestClassification__c, // 申請区分
                                                                                    ManagementNumber__c, // 伺い管理番号
                                                                                    // PUS_CRM-615 No24 >>
                                                                                    RecordType.DeveloperName, // レコードタイプ名
                                                                                    PublicOrPrivateDemand__c, // 官需・民需
                                                                                    PrimeSubContractor__c, // 元請/下請
                                                                                    OrderTransactionDetailCount__c, // 受注済の商流明細数
                                                                                    FreeContract__c, // 随契
                                                                                    PriceList__c // 価格表
                                                                                    // PUS_CRM-615 No24 <<
                                                                                FROM QuoteBiddingInquiry__c
                                                                            WHERE Id IN :QuoteBiddingInquiryIds];

                // プロセスインスタンスを取得
                List<ProcessInstance> processInstanceList = [SELECT Id,
                                                                TargetObjectId, // 対象オブジェクトId
                                                                Status, // ステータス
                                                                LastmodifiedDate // 最終更新日時
                                                            FROM ProcessInstance
                                                            WHERE TargetObjectId IN :QuoteBiddingInquiryIds
                                                            ORDER BY LastmodifiedDate DESC];
                Map<Id, ProcessInstance> processInstanceTargetObjectIdMap = new Map<Id, ProcessInstance>();
                Map<Id, ProcessInstance> processInstanceMap = new Map<Id, ProcessInstance>();
                for(ProcessInstance processInstance : processInstanceList){
                    if(processInstanceTargetObjectIdMap.containsKey(processInstance.TargetObjectId)){
                        continue;
                    }
                    processInstanceTargetObjectIdMap.put(processInstance.TargetObjectId, processInstance);
                    processInstanceMap.put(processInstance.Id, processInstance);
                }

                // 承認プロセスインスタンスステップを取得
                List<ProcessInstanceStep> processInstanceStepList = [SELECT Id,
                                                                        ActorId, // 承認者Id
                                                                        CreatedBy.ConcurrentManager__r.Id, // 申請者の兼務マネージャー
                                                                        CreatedBy.ManagerId, // 申請者のマネージャー
                                                                        CreatedById, // 申請者Id
                                                                        ProcessInstanceId, // プロセスインスタンスId
                                                                        StepStatus // ステータス
                                                                    FROM ProcessInstanceStep
                                                                    WHERE ProcessInstanceId IN :processInstanceMap.keySet()
                                                                    ORDER BY CreatedDate ASC];
                Map<Id, ProcessInstanceStep> processInstanceStepMap = new Map<Id, ProcessInstanceStep>();
                for(ProcessInstanceStep processInstanceStep : processInstanceStepList){
                    processInstanceStepMap.put(processInstanceStep.ProcessInstanceId, processInstanceStep);
                }

                // 承認申請を取得
                List<ProcessInstanceWorkitem> processInstanceWorkitemList = [SELECT Id,
                                                                                    ProcessInstanceId, // プロセスインスタンスId
                                                                                    ActorId,// 承認者Id
                                                                                    Actor.name // 承認者名
                                                                                FROM ProcessInstanceWorkitem
                                                                                WHERE ProcessInstanceId IN :processInstanceMap.keySet()];
                Map<Id, ProcessInstanceWorkitem> processInstanceWorkitemMap = new Map<Id, ProcessInstanceWorkitem>();
                for(ProcessInstanceWorkitem processInstanceWorkitem : processInstanceWorkitemList){
                    processInstanceWorkitemMap.put(processInstanceWorkitem.ProcessInstanceId, processInstanceWorkitem);
                }

                 // 承認プロセスインスタンスステップを取得
                 List<ProcessInstanceStep> processInstanceStepListOld = [SELECT Id,
                                                                            ActorId, // 承認者Id
                                                                            CreatedBy.ConcurrentManager__r.Id, // 申請者の兼務マネージャー
                                                                            CreatedBy.ManagerId, // 申請者のマネージャー
                                                                            CreatedById, // 申請者Id
                                                                            ProcessInstanceId, // プロセスインスタンスId
                                                                            StepStatus // ステータス
                                                                        FROM ProcessInstanceStep
                                                                        WHERE ProcessInstanceId IN :processInstanceMap.keySet()
                                                                        ORDER BY CreatedDate DESC];
                Map<Id, ProcessInstanceStep> processInstanceStepMapOld = new Map<Id, ProcessInstanceStep>();
                for(ProcessInstanceStep processInstanceStep : processInstanceStepListOld){
                    processInstanceStepMapOld.put(processInstanceStep.ProcessInstanceId, processInstanceStep);
                }

                // 承認プロセスインスタンスノードを取得
                List<ProcessInstanceNode> processInstanceNodeList = [SELECT Id,
                                                                        ProcessNodeName, // 承認ステップ名
                                                                        ProcessInstanceId // プロセスインスタンスId
                                                                    FROM ProcessInstanceNode
                                                                    WHERE ProcessInstanceId IN :processInstanceMap.keySet()
                                                                    ORDER BY CreatedDate ASC];
                Map<Id, ProcessInstanceNode> processInstanceNodeMap = new Map<Id, ProcessInstanceNode>();
                for(ProcessInstanceNode processInstanceNode : processInstanceNodeList){
                    processInstanceNodeMap.put(processInstanceNode.ProcessInstanceId, processInstanceNode);
                }

                List<QuoteBiddingInquiry__c> updateTargetList = new List<QuoteBiddingInquiry__c>();
                // 更新対象を更新する
                for(QuoteBiddingInquiry__c UpdateQuoteBiddingInquiry : UpdateQuoteBiddingInquiryList){
                    ProcessInstance processInstance = processInstanceTargetObjectIdMap.get(UpdateQuoteBiddingInquiry.Id);
                    ProcessInstanceStep processInstanceStep = processInstanceStepMap.get(processInstance.Id);
                    ProcessInstanceStep processInstanceStepOld = processInstanceStepMapOld.get(processInstance.Id);
                    ProcessInstanceNode processInstanceNode = processInstanceNodeMap.get(processInstance.Id);
                    ProcessInstanceWorkitem processInstanceWorkitem = processInstanceWorkitemMap.get(processInstance.Id);

                    // 却下、取り消し、最終承認の場合
                    if(processInstanceStep.StepStatus == 'Rejected' || processInstanceStep.StepStatus == 'Removed' 
                        || processInstance.Status == 'Approved') {
                        // 現在の承認者
                        UpdateQuoteBiddingInquiry.CurrentApproverText__c = null;
                        // 承認ステップ名
                        UpdateQuoteBiddingInquiry.ApprovallStepsName__c = null;
                        // 承認割り当て時間
                        UpdateQuoteBiddingInquiry.ApprovalAssigningTime__c = null;
                        // 承認割り当て日時
                        UpdateQuoteBiddingInquiry.ApprovalAssignmentDateTime__c = null;
                        // 申請者のマネージャー
                        UpdateQuoteBiddingInquiry.ApplicantManager__c = null;
                        // 申請者
                        UpdateQuoteBiddingInquiry.Applicant__c = null;
                        // ICP審査対象
                        // UpdateQuoteBiddingInquiry.ICPReviewTarget__c = false;
                        // 最終承認者
                        if(processInstance.Status != 'Approved' && UpdateQuoteBiddingInquiry.RequestClassification__c == '伺い申請'){
                            UpdateQuoteBiddingInquiry.FinalApprover__c = null;
                            UpdateQuoteBiddingInquiry.ManagementNumber__c = null;
                        }
                    } else {
                        // 現在の承認者
                        UpdateQuoteBiddingInquiry.CurrentApproverText__c = processInstanceWorkitem?.Actor.name;
                        // 承認ステップ名
                        UpdateQuoteBiddingInquiry.ApprovallStepsName__c = processInstanceNode?.ProcessNodeName;
                        // 承認割り当て時間
                        UpdateQuoteBiddingInquiry.ApprovalAssigningTime__c = processInstance?.LastmodifiedDate;
                        // 承認割り当て日時
                        UpdateQuoteBiddingInquiry.ApprovalAssignmentDateTime__c = processInstance?.LastmodifiedDate;
                        // 本務側申請か兼務側申請か
                        if(UpdateQuoteBiddingInquiry.AdditionalPostInquiryApplication__c) {
                            // 申請者のマネージャー
                            UpdateQuoteBiddingInquiry.ApplicantManager__c = processInstanceStepOld?.CreatedBy.ConcurrentManager__r.Id;
                        } else {
                            // 申請者のマネージャー
                            UpdateQuoteBiddingInquiry.ApplicantManager__c = processInstanceStepOld?.CreatedBy.ManagerId;
                        }
                        // 申請者
                        UpdateQuoteBiddingInquiry.Applicant__c = processInstanceStepOld?.CreatedById;

                        if((UpdateQuoteBiddingInquiry.ApprovallStepsName__c == 'BU推進部長' || UpdateQuoteBiddingInquiry.ApprovallStepsName__c == '事管推部長')
                            && UpdateQuoteBiddingInquiry.InquiryApprovalStatus__c == '事管推課長'
                        ){
                            // PUS_CRM-615 No71 >>
                            // UpdateQuoteBiddingInquiry.InquiryApprovalStatus__c = '事管推部長';
                            UpdateQuoteBiddingInquiry.InquiryApprovalStatus__c = UpdateQuoteBiddingInquiry.ApprovallStepsName__c;
                            // PUS_CRM-615 No71 <<
                            UpdateQuoteBiddingInquiry.StatusForPath__c = '事管推部長';
                        }

                        if((UpdateQuoteBiddingInquiry.ApprovallStepsName__c == 'BU推進部長' || UpdateQuoteBiddingInquiry.ApprovallStepsName__c == '事管推部長')
                            && UpdateQuoteBiddingInquiry.ResultContactStatus__c == '事管推課長'
                        ){
                            // PUS_CRM-615 No71 >>
                            // UpdateQuoteBiddingInquiry.ResultContactStatus__c = '事管推部長';
                            UpdateQuoteBiddingInquiry.ResultContactStatus__c = UpdateQuoteBiddingInquiry.ApprovallStepsName__c;
                            // PUS_CRM-615 No71 <<
                        }
                        // PUS_CRM-615 No24 >>
                        if((UpdateQuoteBiddingInquiry.RecordType.DeveloperName == 'M' || UpdateQuoteBiddingInquiry.RecordType.DeveloperName == 'O')
                            && ((UpdateQuoteBiddingInquiry.PublicOrPrivateDemand__c == '官需' && UpdateQuoteBiddingInquiry.PrimeSubContractor__c == '元請') 
                                || (UpdateQuoteBiddingInquiry.PublicOrPrivateDemand__c == '官需' && UpdateQuoteBiddingInquiry.PrimeSubContractor__c == '下請' && UpdateQuoteBiddingInquiry.OrderTransactionDetailCount__c < 1))
                            && (UpdateQuoteBiddingInquiry.FreeContract__c == true || UpdateQuoteBiddingInquiry.PriceList__c == true)
                        ){
                            UpdateQuoteBiddingInquiry.ICPReviewTarget__c = true;
                        }
                        // PUS_CRM-615 No24 <<
                    }


                    // 未承認アラート発信日時設定対象がFalseからTrueに変更時、未承認アラート発信日時を設定する
                    if(newMap.get(UpdateQuoteBiddingInquiry.Id).TargetForUnapprovedRemindLimitSet__c == true
                        && oldMap.get(UpdateQuoteBiddingInquiry.Id).TargetForUnapprovedRemindLimitSet__c == false){

                        // 未承認アラート対象プロセスインスタンスID
                        UpdateQuoteBiddingInquiry.UnapprovedRemindTargetProcessInstanceId__c = processInstance.Id;
                        // 未承認アラート発信日時設定対象
                        UpdateQuoteBiddingInquiry.TargetForUnapprovedRemindLimitSet__c = false;
                        // 未承認アラート発信日時
                        if(newMap.get(UpdateQuoteBiddingInquiry.Id).UnapprovedRemindCategory__c == 18 ) {
                            DateTime disicionDatetime = resultDateAfter18Hours;
                            if(holidayAfter18Hours.size() > 0) {
                                while (disicionDatetime.format('E') == 'Sat' // 土曜日の場合
                                    || disicionDatetime.format('E') == 'Sun' // 日曜日の場合
                                    || holidayAfter18HoursMap.containsKey(Date.valueOf(disicionDatetime.addHours(9)))) { // 休日の場合
                                    disicionDatetime = disicionDatetime.addDays(1);
                                }
                            }
                            UpdateQuoteBiddingInquiry.UnapprovedRemindLimit__c = disicionDatetime;

                        } else if(newMap.get(UpdateQuoteBiddingInquiry.Id).UnapprovedRemindCategory__c == 24 ) {
                            DateTime disicionDatetime = resultDateAfter24Hours;
                            if(holidayAfter24Hours.size() > 0) {
                                while (disicionDatetime.format('E') == 'Sat' // 土曜日の場合
                                    || disicionDatetime.format('E') == 'Sun' // 日曜日の場合
                                    || holidayAfter24HoursMap.containsKey(Date.valueOf(disicionDatetime.addHours(9)))) { // 休日の場合
                                    disicionDatetime = disicionDatetime.addDays(1);
                                }
                            }
                            UpdateQuoteBiddingInquiry.UnapprovedRemindLimit__c = disicionDatetime;
                        }

                    }

                    updateTargetList.add(UpdateQuoteBiddingInquiry);
                }

                if(!updateTargetList.isEmpty()){
                    update updateTargetList;
                }
                // テスト実行時、かつ例外発生フラグがtrueのときに例外発生
                if(Test.isRunningTest() && errorHappenFlg){
                    throw new  ApprovalProcessException();
                }
            } catch (Exception e){
                Database.rollback(sp);
                newList[0].addError('エラーが発生しました。承認申請を再度実行してください。エラーが繰り返す場合はシステム管理者に連絡してください。', false);
                System.debug('-----error-------' + e.getStackTraceString());
            }
        }
    }

    /**
     * レコードロック解除処理メソッド
     * @param List<Id> targetIdList レコードロック解除処理対象のIDリスト
     */
    @future
    private static void doUnlock(List<Id> targetIdList){
        List<Id> unlockIdList = new List<Id>();
        for (Id recordId : targetIdList) {
            if (String.isNotEmpty(recordId)) {
                if (System.Approval.isLocked(recordId)) {
                    unlockIdList.add(recordId);
                }
            }
        }
        if(unlockIdList.size() > 0) {
            Approval.UnLockResult[] results = Approval.unlock(unlockIdList, true);
            System.debug('非同期処理によるロック解除操作の対象件数 = ' + results.size());
        }

        System.debug('非同期処理によるロック解除操作の対象件数なし');
    }
}