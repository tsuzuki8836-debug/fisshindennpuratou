public class amountDetailGetTableController {
    public static final String O_RECORD_TYPE = 'O'; // 応札伺い
    public static final String J_RECORD_TYPE = 'JV'; // JV締結認可伺い
    public static final String M_RECORD_TYPE = 'M'; // 見積伺い
    public static final String SH_RECORD_TYPE = 'SH'; // 設計変更伺い

    /**
     * 画面表示情報
     */
    public class ScreenInfo {
        public List<BodyRow> bodyList { get; set; }
        public String recordType { get; set; }
    }

    /**
     * 行の設定
     */
    public class BodyRow {
        public List<BodyCell> cellList {get;set;}
    }

    /**
     * セルの設定
     */
    public class BodyCell {
        public Object value {get;set;} // 値
        public Boolean isPercent {get;set;} // パーセント表示
        public Boolean isText {get;set;} // テキスト表示
        public Boolean isDisable {get;set;} // 無効
    }

    /**
     * 詳細内容を取得する
     */
    @AuraEnabled
    public static String getAmountDetailGetTable(String recId){
        ScreenInfo info = new ScreenInfo();
        QuoteBiddingInquiry__c detail;
        if (String.isNotBlank(recId)) {
            detail = [SELECT Id,
                            RecordType.DeveloperName,  // レコードタイプ
                            PriceProposal1MaxCPManualInput__c, // 価格案_CP(手入力)
                            PriceProposal1MaxWCManualInput__c, // 価格案_WC(手入力)
                            PriceProposal1MaxTCManualInput__c, // 価格案_TC(手入力)
                            PriceProposal1CP__c,    // 価格案_CP
                            PriceProposal1WC__c,    // 価格案_WC
                            PriceProposal1MaxWCRate__c,// 価格案_WC率
                            PriceProposal1TC__c,    // 価格案_TC
                            PriceProposal1MaxTCRate__c,// 価格案_TC率
                            PriceProposal1MaxSalesFee__c, // 価格案(MAX)_手数料
                            PriceProposalSalesFee__c,  // 価格案_手数料
                            PriceProposal1MaxGRossProfit__c, // 価格案_粗利
                            PriceProposal1MaxProfit__c, // 価格案_利益
                            PriceProposal2CP__c, // 価格案(MIN)_CP
                            PriceProposal2WC__c, // 価格案(MIN)_WC
                            PriceProposal2MinWCRate__c, // 価格案(MIN)_WC率
                            PriceProposal2TC__c, // 価格案(MIN)_TC
                            PriceProposal2MinTCRate__c, // 価格案(MIN)_TC率
                            PriceProposal2MinSalesFee__c, // 価格案(MIN)_手数料
                            PriceProposal2MinGrossProfit__c, // 価格案(MIN)_粗利
                            PriceProposal2MinProfit__c, // 価格案(MIN)_利益

                            OriginalContractCPSummary__c, // 原契約_CP
                            OriginalContractTCSummary__c, // 原契約_TC
                            OriginalContractWCSummary__c, // 原契約_WC
                            OriginalContractTCRate__c, // 原契約_TC率
                            OriginalContractWCRate__c, // 原契約_WC率
                            OriginalContractProfitFormula__c, // 原契約_利益
                            OriginalContractGrossProfitFormula__c, // 原契約_粗利
                            OriginalContractFee__c, // 原契約_手数料（設計変更の場合のみ画面から入力あり）
                            //Opportunity__c, // 案件
                            //Opportunity__r.Order_Margin__c, // 案件の２．SR手数料（受注時）

                            DetailAfterDesignChangeCPSummary__c, // 設計変更後最新_CP
                            DetailAfterDesignTCSummary__c, // 設計変更後最新_TC
                            DetailAfterDesignChangeWCSummary__c, // 設計変更後最新_WC
                            DetailAfterDesignRate__c, // 設計変更後最新_TC率
                            DetailAfterDesignWCRate__c, // 設計変更後最新_WC率
                            DetailAfterDesignProfitFormula__c, // 設計変更後最新_利益
                            DetailAfterDesignGrossProfitFormula__c, // 設計変更後最新_粗利
                            DetailAfterDesignFee__c, // 設計変更後最新_手数料（設計変更の場合のみ画面から入力あり）
                            //Opportunity__r.Latest_Margin__c, // 案件の３．SR手数料（最新）

                            AdjustTotalCPMaxSummary__c, // 今回合計CP(MAX)
                            AdjustTotalTCMaxSummary__c, // 今回合計TC(MAX)
                            AdjustTotalWCSummary__c, // 今回合計WC
                            AdjustTotalWCRateMax__c, // 今回合計WC率(MAX)
                            AdjustTotalTCRateMax__c, // 今回合計TC率(MAX)
                            AdjustMaxFee__c, // 今回増減手数料(MAX)

                            AdjustTotalCPMinSummary__c, // 今回合計CP(MIN)
                            AdjustTotalTCMinSummary__c, // 今回合計TC(MIN)
                            AdjustTotalWCRateMin__c, // 今回合計WC率(MIN)
                            AdjustTotalTCRateMin__c, // 今回合計TC率(MIN)
                            AdjustMinFee__c, // 今回増減手数料(MIN)

                            ExpectProfitAndLossOnOrderCP__c, // 受注時見込_CP
                            ExpectProfitAndLossOnOrderWC__c, // 受注時見込_WC
                            ExpectProfitAndLossOnOrderTC__c, // 受注時見込損益_TC
                            ExpectProfitAndLossOnOrderFee__c, // 受注時見込_手数料
                            PriceProposal1MaxCP__c, // 価格案_CP(伺い数値明細)
                            PriceProposal1MaxWC__c, // 価格案_WC(伺い数値明細)
                            PriceProposal1MaxTC__c, // 価格案_TC(伺い数値明細)
                            SingleTotalCP__c, // 単計(損予)織込_CP
                            SingleTotalWC__c, // 単計(損予)織込_WC
                            SingleTotalTC__c, // 単計(損予)織込_TC
                            SingleTotalFee__c, // 単計(損予)織込_手数料
                            ImproveGoal3CPCount__c,// 改善目標_CP
                            ImproveGoal3WCCount__c,// 改善目標_TC
                            ImproveGoal3TCRate__c,// 改善目標_TC率
                            ImproveGoal3TCCount__c,// 改善目標_WC
                            ImproveGoal3WCRate__c,// 改善目標_WC率
                            ImproveGoal3SalesFee__c,// 改善目標_手数料
                            ImproveGoal3GrossProfit__c,// 改善目標_粗利
                            ImproveGoal3Profit__c,// 改善目標_純利益
                            UnitPriceEstimation__c, // 見積単価
                            Refusal__c,// 辞退
                            PriceList__c, // 価格表
                            EstimationUsage__c, // 見積用途
                            Opportunity__r.Probability1__c,  // 案件の係数
                            DependentFeeInquiry__c, // 参照先手数料伺い
                            DependentFeeInquiry__r.DifferenceWithLastTimeMax__c, // 前回との差額(Max)
                            DependentFeeInquiry__r.DifferenceWithLastTimeMin__c // 前回との差額(Min)
                        FROM QuoteBiddingInquiry__c
                        WHERE Id = :recId
                        LIMIT 1];
        }

        if(detail == null) {
            return JSON.serialize(info);
        }

        // 見積伺いの場合
        List<BodyRow> bodyList = new List<BodyRow>();
        if (detail.RecordType.DeveloperName.equals(M_RECORD_TYPE)) {
            BodyRow row = new BodyRow();
            List<BodyCell> cellList  = new List<BodyCell>();

            // -------------------------------------------------------
            cellList.add(setCell('見積価格案',false,true));

            // 単価見積、辞退、価格表の場合は当該テキスト”、”を連結して表示する
            List<String> nameText= new List<String>();
            if(detail.UnitPriceEstimation__c){
                nameText.add('単価見積');
            }
            if(detail.Refusal__c){
                nameText.add('辞退');
            }
            if(detail.PriceList__c){
                nameText.add('価格表');
            }
            if (nameText.size() > 0) {
                cellList.add(setCell(String.join(nameText, '、'),false,true));
                cellList.add(setCell('',false,true)); // WC
                cellList.add(setCell('',false,true)); // WC率
                cellList.add(setCell('',false,true)); // TC
                cellList.add(setCell('',false,true)); // TC率
                cellList.add(setCell('',false,true)); // 手数料
                cellList.add(setCell('',false,true)); // 粗利
                cellList.add(setCell('',false,true)); // 利益
            } else {
                cellList.add(setCell(detail.PriceProposal1MaxCPManualInput__c,false,false)); // CP
                cellList.add(setCell(detail.PriceProposal1MaxWCManualInput__c,false,false)); // WC
                Decimal wcRate = 0;
                // WC率
                if (detail.PriceProposal1MaxCPManualInput__c != 0 && detail.PriceProposal1MaxCPManualInput__c != null
                    && detail.PriceProposal1MaxWCManualInput__c != 0 && detail.PriceProposal1MaxWCManualInput__c != null) {
                    Decimal result = detail.PriceProposal1MaxWCManualInput__c / detail.PriceProposal1MaxCPManualInput__c * 100;
                    wcRate = result.setScale(1, RoundingMode.HALF_UP);
                }
                cellList.add(setCell(wcRate,true,false));
                cellList.add(setCell(detail.PriceProposal1MaxTCManualInput__c,false,false)); // TC
                // TC率
                Decimal tcRate = 0;
                if (detail.PriceProposal1MaxCPManualInput__c != 0 && detail.PriceProposal1MaxCPManualInput__c != null
                    && detail.PriceProposal1MaxTCManualInput__c != 0 && detail.PriceProposal1MaxTCManualInput__c != null) {
                    Decimal result = detail.PriceProposal1MaxTCManualInput__c / detail.PriceProposal1MaxCPManualInput__c * 100;
                    tcRate = result.setScale(1, RoundingMode.HALF_UP);
                }
                cellList.add(setCell(tcRate,true,false));
                cellList.add(setCell(detail.PriceProposalSalesFee__c,false,false)); // 手数料
                Decimal priceProposal1MaxGRossProfit = (detail.PriceProposal1MaxCPManualInput__c == null?0:detail.PriceProposal1MaxCPManualInput__c) -
                                                     (detail.PriceProposal1MaxWCManualInput__c == null?0:detail.PriceProposal1MaxWCManualInput__c) - 
                                                     (detail.PriceProposalSalesFee__c == null?0:detail.PriceProposalSalesFee__c);
                cellList.add(setCell(priceProposal1MaxGRossProfit,false,false)); // 粗利

                Decimal priceProposal1MaxProfit = (detail.PriceProposal1MaxCPManualInput__c == null?0:detail.PriceProposal1MaxCPManualInput__c) -
                                                (detail.PriceProposal1MaxTCManualInput__c == null?0:detail.PriceProposal1MaxTCManualInput__c) - 
                                                (detail.PriceProposalSalesFee__c == null?0:detail.PriceProposalSalesFee__c);
                cellList.add(setCell(priceProposal1MaxProfit,false,false)); // 利益
            }

            row.cellList = cellList;
            bodyList.add(row);


            // -------------------------------------------------------
            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('場所別合計',false,true));
            cellList.add(setCell(detail.PriceProposal1MaxCP__c,false,false)); // CP
            cellList.add(setCell(detail.PriceProposal1MaxWC__c,false,false)); // WC
            Decimal wcRate = 0;
            // WC率
            if (detail.PriceProposal1MaxCP__c != 0 && detail.PriceProposal1MaxCP__c != null
                && detail.PriceProposal1MaxWC__c != 0 && detail.PriceProposal1MaxWC__c != null) {
                Decimal result = detail.PriceProposal1MaxWC__c / detail.PriceProposal1MaxCP__c * 100;
                wcRate = result.setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(wcRate,true,false));
            cellList.add(setCell(detail.PriceProposal1MaxTC__c,false,false)); // TC
            // TC率
            Decimal tcRate = 0;
            if (detail.PriceProposal1MaxCP__c != 0 && detail.PriceProposal1MaxCP__c != null
                && detail.PriceProposal1MaxTC__c != 0 && detail.PriceProposal1MaxTC__c != null) {
                Decimal result = detail.PriceProposal1MaxTC__c / detail.PriceProposal1MaxCP__c * 100;
                tcRate = result.setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(tcRate,true,false));
            cellList.add(setCell('',false,true,true));// 手数料 対象外
            Decimal priceProposalGRossProfit = (detail.PriceProposal1MaxCP__c == null?0:detail.PriceProposal1MaxCP__c) -
                                                 (detail.PriceProposal1MaxWC__c == null?0:detail.PriceProposal1MaxWC__c);
            cellList.add(setCell(priceProposalGRossProfit,false,false)); // 粗利

            Decimal priceProposalProfit = (detail.PriceProposal1MaxCP__c == null?0:detail.PriceProposal1MaxCP__c) -
                                            (detail.PriceProposal1MaxTC__c == null?0:detail.PriceProposal1MaxTC__c);
            cellList.add(setCell(priceProposalProfit,false,false)); // 利益

            row.cellList = cellList;
            bodyList.add(row);

            // -------------------------------------------------------
            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('受注時見込',false,true));

            Decimal expectProfitAndLossOnOrderCP = 0;
            // 受注時見込_CPある場合、受注時見込_CPを表示、ない場合は価格案_CP(伺い数値明細)を表示
            if(detail.ExpectProfitAndLossOnOrderCP__c == null) {
                expectProfitAndLossOnOrderCP = detail.PriceProposal1MaxCP__c;
            } else {
                expectProfitAndLossOnOrderCP = detail.ExpectProfitAndLossOnOrderCP__c;
            }
            cellList.add(setCell(expectProfitAndLossOnOrderCP,false,false)); // CP

            Decimal expectProfitAndLossOnOrderWC = 0;
            // 受注時見込_WCある場合、受注時見込_WCを表示、ない場合は価格案_WC(伺い数値明細)を表示
            if(detail.ExpectProfitAndLossOnOrderWC__c == null) {
                expectProfitAndLossOnOrderWC = detail.PriceProposal1MaxWC__c;
            } else {
                expectProfitAndLossOnOrderWC = detail.ExpectProfitAndLossOnOrderWC__c;
            }
            cellList.add(setCell(expectProfitAndLossOnOrderWC,false,false)); // WC

            wcRate = 0;
            // WC率
            if (expectProfitAndLossOnOrderCP != 0 && expectProfitAndLossOnOrderCP != null
                && expectProfitAndLossOnOrderWC != 0 && expectProfitAndLossOnOrderWC != null) {
                Decimal result = expectProfitAndLossOnOrderWC / expectProfitAndLossOnOrderCP * 100;
                wcRate = result.setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(wcRate,true,false));

            // 受注時見込損益_TCある場合、受注時見込損益_TCを表示、ない場合は価格案_TC(伺い数値明細)を表示
            Decimal expectProfitAndLossOnOrderTC = 0;
            if(detail.ExpectProfitAndLossOnOrderTC__c == null) {
                expectProfitAndLossOnOrderTC = detail.PriceProposal1MaxTC__c;
            } else {
                expectProfitAndLossOnOrderTC = detail.ExpectProfitAndLossOnOrderTC__c;
            }
            cellList.add(setCell(expectProfitAndLossOnOrderTC,false,false)); // TC

            // TC率
            tcRate = 0;
            if (expectProfitAndLossOnOrderCP != 0 && expectProfitAndLossOnOrderCP != null
                && expectProfitAndLossOnOrderTC != 0 && expectProfitAndLossOnOrderTC != null) {
                Decimal result = expectProfitAndLossOnOrderTC / expectProfitAndLossOnOrderCP * 100;
                tcRate = result.setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(tcRate,true,false));

            // 手数料
            Decimal expectProfitAndLossOnOrderFee = detail.ExpectProfitAndLossOnOrderFee__c==null?0:detail.ExpectProfitAndLossOnOrderFee__c;
            cellList.add(setCell(expectProfitAndLossOnOrderFee,false,false));

            // 粗利
            Decimal expectProfitAndLossOnOrderGRossProfit = (expectProfitAndLossOnOrderCP == null?0:expectProfitAndLossOnOrderCP) -
                                                            (expectProfitAndLossOnOrderWC == null?0:expectProfitAndLossOnOrderWC) - 
                                                            (expectProfitAndLossOnOrderFee == null?0:expectProfitAndLossOnOrderFee);

            cellList.add(setCell(expectProfitAndLossOnOrderGRossProfit,false,false));

            // 利益
            Decimal expectProfitAndLossOnOrderProfit = (expectProfitAndLossOnOrderCP == null?0:expectProfitAndLossOnOrderCP) -
                                                        (expectProfitAndLossOnOrderTC == null?0:expectProfitAndLossOnOrderTC) - 
                                                        (expectProfitAndLossOnOrderFee == null?0:expectProfitAndLossOnOrderFee);
            cellList.add(setCell(expectProfitAndLossOnOrderProfit,false,false));

            row.cellList = cellList;
            bodyList.add(row);

            // -------------------------------------------------------
            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('単計(損予)織込',false,true));

            // 単計(損予)織込_CP
            Decimal singleTotalCP = detail.SingleTotalCP__c;
            cellList.add(setCell(singleTotalCP,false,false)); // CP

            // 単計(損予)織込_WC
            Decimal singleTotalWC = detail.SingleTotalWC__c;
            cellList.add(setCell(singleTotalWC,false,false)); // WC

            wcRate = 0;
            // WC率
            if (singleTotalCP != 0 && singleTotalCP != null
                && singleTotalWC != 0 && singleTotalWC != null) {
                Decimal result = singleTotalWC / singleTotalCP * 100;
                wcRate = result.setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(wcRate,true,false));

            // 単計(損予)織込_TC
            Decimal singleTotalTC = detail.SingleTotalTC__c;
            cellList.add(setCell(singleTotalTC,false,false)); // TC

            // TC率
            tcRate = 0;
            if (singleTotalCP != 0 && singleTotalCP != null
                && singleTotalTC != 0 && singleTotalTC != null) {
                Decimal result = singleTotalTC / singleTotalCP * 100;
                tcRate = result.setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(tcRate,true,false));

            // 単計(損予)織込_手数料ある場合、単計(損予)織込_手数料を表示、ない場合　0を表示
            Decimal singleTotalFee = detail.SingleTotalFee__c==null?0:detail.SingleTotalFee__c;
            cellList.add(setCell(singleTotalFee,false,false));

            // 粗利
            Decimal singleTotalGRossProfit = (singleTotalCP == null?0:singleTotalCP) -
                                             (singleTotalWC == null?0:singleTotalWC) - 
                                             (singleTotalFee == null?0:singleTotalFee);
            cellList.add(setCell(singleTotalGRossProfit,false,false));

            // 利益
            Decimal singleTotalProfit = (singleTotalCP == null?0:singleTotalCP) -
                                        (singleTotalTC == null?0:singleTotalTC) - 
                                        (singleTotalFee == null?0:singleTotalFee);
            cellList.add(setCell(singleTotalProfit,false,false));

            row.cellList = cellList;
            bodyList.add(row);

            // -------------------------------------------------------
            if(detail.EstimationUsage__c == '入札前価格提示用' ||
                detail.EstimationUsage__c == '価格交渉用' ) {
                row = new BodyRow();
                cellList  = new List<BodyCell>();
                cellList.add(setCell('改善目標',false,true));
                if((detail.ImproveGoal3CPCount__c == null || detail.ImproveGoal3CPCount__c == 0)
                    && (detail.ImproveGoal3WCCount__c == null || detail.ImproveGoal3WCCount__c == 0)) {
                    cellList.add(setCell('',false,true)); // CP
                    cellList.add(setCell('',false,true)); // WC
                    cellList.add(setCell('',false,true)); // WC率
                    cellList.add(setCell('',false,true)); // TC
                    cellList.add(setCell('',false,true)); // TC率
                    cellList.add(setCell('',false,true)); // 手数料
                    cellList.add(setCell('',false,true)); // 粗利
                    cellList.add(setCell('',false,true)); // 利益
                } else {
                    cellList.add(setCell(detail.ImproveGoal3CPCount__c,false,false));
                    cellList.add(setCell(detail.ImproveGoal3WCCount__c,false,false));
                    cellList.add(setCell(detail.ImproveGoal3WCRate__c == null?0:detail.ImproveGoal3WCRate__c,true,false));
                    cellList.add(setCell(detail.ImproveGoal3TCCount__c,false,false));
                    cellList.add(setCell(detail.ImproveGoal3TCRate__c == null? 0:detail.ImproveGoal3TCRate__c,true,false));
                    cellList.add(setCell(detail.ImproveGoal3SalesFee__c,false,false));
                    cellList.add(setCell(detail.ImproveGoal3GrossProfit__c,false,false));
                    cellList.add(setCell(detail.ImproveGoal3Profit__c,false,false));
                }
                row.cellList = cellList;
                bodyList.add(row);
            }
        }
        // 応札伺い
        else if (detail.RecordType.DeveloperName.equals(O_RECORD_TYPE)) {
            BodyRow row = new BodyRow();
            List<BodyCell> cellList  = new List<BodyCell>();
            cellList.add(setCell('価格案（MAX）',false,true));
            String nameText = '';
            if(detail.Refusal__c){
                cellList.add(setCell('辞退',false,true));
                cellList.add(setCell('',false,true)); // WC
                cellList.add(setCell('',false,true)); // WC率
                cellList.add(setCell('',false,true)); // TC
                cellList.add(setCell('',false,true)); // TC率
                cellList.add(setCell('',false,true)); // 手数料
                cellList.add(setCell('',false,true)); // 粗利
                cellList.add(setCell('',false,true)); // 利益
            // ADD PUS_CRM-615(No9) START
            } else if(detail.PriceList__c){
                cellList.add(setCell('価格表',false,true));
                cellList.add(setCell('',false,true)); // WC
                cellList.add(setCell('',false,true)); // WC率
                cellList.add(setCell('',false,true)); // TC
                cellList.add(setCell('',false,true)); // TC率
                cellList.add(setCell('',false,true)); // 手数料
                cellList.add(setCell('',false,true)); // 粗利
                cellList.add(setCell('',false,true)); // 利益
            // ADD PUS_CRM-615(No9) END
            } else {
                cellList.add(setCell(detail.PriceProposal1CP__c,false,false));
                cellList.add(setCell(detail.PriceProposal1WC__c,false,false));
                cellList.add(setCell(detail.PriceProposal1MaxWCRate__c == null?0:detail.PriceProposal1MaxWCRate__c,true,false));
                cellList.add(setCell(detail.PriceProposal1TC__c,false,false));
                cellList.add(setCell(detail.PriceProposal1MaxTCRate__c == null?0:detail.PriceProposal1MaxTCRate__c,true,false));
                cellList.add(setCell(detail.PriceProposal1MaxSalesFee__c,false,false));
                cellList.add(setCell(detail.PriceProposal1MaxGRossProfit__c,false,false));
                cellList.add(setCell(detail.PriceProposal1MaxProfit__c,false,false));
            }
            row.cellList = cellList;
            bodyList.add(row);

            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('価格案（MIN）',false,true));
            if(detail.PriceProposal2CP__c==null||detail.PriceProposal2CP__c==0) {
                cellList.add(setCell('',false,true)); // CP
                cellList.add(setCell('',false,true)); // WC
                cellList.add(setCell('',false,true)); // WC率
                cellList.add(setCell('',false,true)); // TC
                cellList.add(setCell('',false,true)); // TC率
                cellList.add(setCell('',false,true)); // 手数料
                cellList.add(setCell('',false,true)); // 粗利
                cellList.add(setCell('',false,true)); // 利益
            } else {
                cellList.add(setCell(detail.PriceProposal2CP__c,false,false));
                cellList.add(setCell(detail.PriceProposal2WC__c,false,false));
                cellList.add(setCell(detail.PriceProposal2MinWCRate__c == null?0:detail.PriceProposal2MinWCRate__c,true,false));
                cellList.add(setCell(detail.PriceProposal2TC__c,false,false));
                cellList.add(setCell(detail.PriceProposal2MinTCRate__c == null? 0:detail.PriceProposal2MinTCRate__c,true,false));
                cellList.add(setCell(detail.PriceProposal2MinSalesFee__c,false,false));
                cellList.add(setCell(detail.PriceProposal2MinGrossProfit__c,false,false));
                cellList.add(setCell(detail.PriceProposal2MinProfit__c,false,false));
            }
            row.cellList = cellList;
            bodyList.add(row);

            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('改善目標',false,true));
            if((detail.ImproveGoal3CPCount__c == null || detail.ImproveGoal3CPCount__c == 0) &&
                (detail.ImproveGoal3WCCount__c == null || detail.ImproveGoal3WCCount__c == 0)) {
                cellList.add(setCell('',false,true)); // CP
                cellList.add(setCell('',false,true)); // WC
                cellList.add(setCell('',false,true)); // WC率
                cellList.add(setCell('',false,true)); // TC
                cellList.add(setCell('',false,true)); // TC率
                cellList.add(setCell('',false,true)); // 手数料
                cellList.add(setCell('',false,true)); // 粗利
                cellList.add(setCell('',false,true)); // 利益
            } else {
                cellList.add(setCell(detail.ImproveGoal3CPCount__c,false,false));
                cellList.add(setCell(detail.ImproveGoal3WCCount__c,false,false));
                cellList.add(setCell(detail.ImproveGoal3WCRate__c == null?0:detail.ImproveGoal3WCRate__c,true,false));
                cellList.add(setCell(detail.ImproveGoal3TCCount__c,false,false));
                cellList.add(setCell(detail.ImproveGoal3TCRate__c == null? 0:detail.ImproveGoal3TCRate__c,true,false));
                cellList.add(setCell(detail.ImproveGoal3SalesFee__c == null? 0:detail.ImproveGoal3SalesFee__c,false,false));
                cellList.add(setCell(detail.ImproveGoal3GrossProfit__c== null? 0:detail.ImproveGoal3GrossProfit__c,false,false));
                cellList.add(setCell(detail.ImproveGoal3Profit__c== null? 0:detail.ImproveGoal3Profit__c,false,false));
            }
            row.cellList = cellList;
            bodyList.add(row);

            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('単計(損予)織込',false,true));

            // 単計(損予)織込_CP
            Decimal singleTotalCP = detail.SingleTotalCP__c;
            cellList.add(setCell(singleTotalCP,false,false)); // CP

            // 単計(損予)織込_WC
            Decimal singleTotalWC = detail.SingleTotalWC__c;
            cellList.add(setCell(singleTotalWC,false,false)); // WC

            Decimal wcRate = 0;
            // WC率
            if (singleTotalCP != 0 && singleTotalCP != null
                && singleTotalWC != 0 && singleTotalWC != null) {
                Decimal result = singleTotalWC / singleTotalCP * 100;
                wcRate = result.setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(wcRate,true,false));

            // 単計(損予)織込_TC
            Decimal singleTotalTC = detail.SingleTotalTC__c;
            cellList.add(setCell(singleTotalTC,false,false)); // TC

            // TC率
            Decimal tcRate = 0;
            if (singleTotalCP != 0 && singleTotalCP != null
                && singleTotalTC != 0 && singleTotalTC != null) {
                Decimal result = singleTotalTC / singleTotalCP * 100;
                tcRate = result.setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(tcRate,true,false));

            // 単計(損予)織込_手数料ある場合、単計(損予)織込_手数料を表示、ない場合　0を表示
            Decimal singleTotalFee = detail.SingleTotalFee__c==null?0:detail.SingleTotalFee__c;
            cellList.add(setCell(singleTotalFee,false,false));

            // 粗利
            Decimal singleTotalGRossProfit = (singleTotalCP == null?0:singleTotalCP) -
                                             (singleTotalWC == null?0:singleTotalWC) - 
                                             (singleTotalFee == null?0:singleTotalFee);
            cellList.add(setCell(singleTotalGRossProfit,false,false));

            // 利益
            Decimal singleTotalProfit = (singleTotalCP == null?0:singleTotalCP) -
                                        (singleTotalTC == null?0:singleTotalTC) - 
                                        (singleTotalFee == null?0:singleTotalFee);
            cellList.add(setCell(singleTotalProfit,false,false));

            row.cellList = cellList;
            bodyList.add(row);

        }
        // 設計変更伺い
        else if (detail.RecordType.DeveloperName.equals(SH_RECORD_TYPE)) {
            BodyRow row = new BodyRow();
            Decimal originalContractCP = 0;
            Decimal originalContractWC = 0;
            Decimal originalContractWCRate = 0;
            Decimal originalContractTC = 0;
            Decimal originalContractTCRate = 0;
            Decimal originalContractSalesCommission = 0;
            Decimal originalContractGrossProfit = 0;
            Decimal originalContractProfit = 0;

            // CP
            if(detail.OriginalContractCPSummary__c != null) {
                originalContractCP = detail.OriginalContractCPSummary__c;
            }
            // WC
            if(detail.OriginalContractWCSummary__c != null) {
                originalContractWC = detail.OriginalContractWCSummary__c;
            }
            // WC率
            if(detail.OriginalContractWCRate__c != null) {
                originalContractWCRate = detail.OriginalContractWCRate__c;
            }
            // TC
            if(detail.OriginalContractTCSummary__c != null) {
                originalContractTC = detail.OriginalContractTCSummary__c;
            }
            // TC率
            if(detail.OriginalContractTCRate__c != null) {
                originalContractTCRate = detail.OriginalContractTCRate__c;
            }
            // 手数料
            if(detail.OriginalContractFee__c != null) {
                //originalContractSalesCommission = detail.Opportunity__r.Order_Margin__c;
                originalContractSalesCommission = detail.OriginalContractFee__c;
            }
            // 粗利
            if(detail.OriginalContractGrossProfitFormula__c != null) {
                originalContractGrossProfit = detail.OriginalContractGrossProfitFormula__c;
            }
            // 利益
            if(detail.OriginalContractProfitFormula__c != null) {
                originalContractProfit = detail.OriginalContractProfitFormula__c;
            }

            List<BodyCell> cellList  = new List<BodyCell>();
            cellList.add(setCell('原契約',false,true));
            cellList.add(setCell(originalContractCP,false,false));
            cellList.add(setCell(originalContractWC,false,false));
            cellList.add(setCell(originalContractWCRate,true,false));
            cellList.add(setCell(originalContractTC,false,false));
            cellList.add(setCell(originalContractTCRate,true,false));
            cellList.add(setCell(originalContractSalesCommission,false,false));
            cellList.add(setCell(originalContractGrossProfit,false,false));
            cellList.add(setCell(originalContractProfit,false,false));
            row.cellList = cellList;
            bodyList.add(row);

            Decimal detailAfterDesignChangeCP = 0;
            Decimal detailAfterDesignChangeWC = 0;
            Decimal detailAfterDesignWCRate = 0;
            Decimal detailAfterDesignTC = 0;
            Decimal detailAfterDesignTCRate = 0;
            Decimal detailAfterDesignSalesCommission = 0;
            Decimal detailAfterDesignGrossProfit = 0;
            Decimal detailAfterDesignProfit = 0;

            // CP
            if(detail.DetailAfterDesignChangeCPSummary__c != null) {
                detailAfterDesignChangeCP = detail.DetailAfterDesignChangeCPSummary__c;
            }

            // WC
            if(detail.DetailAfterDesignChangeWCSummary__c != null) {
                detailAfterDesignChangeWC = detail.DetailAfterDesignChangeWCSummary__c;
            }

            // WC率
            if(detail.DetailAfterDesignWCRate__c != null) {
                detailAfterDesignWCRate = detail.DetailAfterDesignWCRate__c;
            }

            // TC
            if(detail.DetailAfterDesignTCSummary__c != null) {
                detailAfterDesignTC = detail.DetailAfterDesignTCSummary__c;
            }

            // TC率
            if(detail.DetailAfterDesignRate__c != null) {
                detailAfterDesignTCRate = detail.DetailAfterDesignRate__c;
            }

            // 手数料
            if(detail.DetailAfterDesignFee__c != null) {
                //detailAfterDesignSalesCommission = detail.Opportunity__r.Latest_Margin__c;
                detailAfterDesignSalesCommission = detail.DetailAfterDesignFee__c;
            }

            // 粗利
            if(detail.DetailAfterDesignGrossProfitFormula__c != null) {
                detailAfterDesignGrossProfit = detail.DetailAfterDesignGrossProfitFormula__c;
            }

            // 利益
            if(detail.DetailAfterDesignProfitFormula__c != null) {
                detailAfterDesignProfit = detail.DetailAfterDesignProfitFormula__c;
            }

            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('最新',false,true));
            cellList.add(setCell(detailAfterDesignChangeCP,false,false));
            cellList.add(setCell(detailAfterDesignChangeWC,false,false));
            cellList.add(setCell(detailAfterDesignWCRate,true,false));
            cellList.add(setCell(detailAfterDesignTC,false,false));
            cellList.add(setCell(detailAfterDesignTCRate,true,false));
            cellList.add(setCell(detailAfterDesignSalesCommission,false,false));
            cellList.add(setCell(detailAfterDesignGrossProfit,false,false));
            cellList.add(setCell(detailAfterDesignProfit,false,false));
            row.cellList = cellList;
            bodyList.add(row);

            Decimal adjustMaxCP = 0;
            Decimal adjustMaxWC = 0;
            Decimal adjustMaxWCRate = 0;
            Decimal adjustMaxTC = 0;
            Decimal adjustMaxTCRate = 0;
            Decimal adjustMaxSalesCommission = 0;
            Decimal adjustMaxGrossProfit = 0;
            Decimal adjustMaxProfit = 0;

            // CP
            if(detail.AdjustTotalCPMaxSummary__c != null) {
                adjustMaxCP = detail.AdjustTotalCPMaxSummary__c;
            }

            // WC
            if(detail.AdjustTotalWCSummary__c != null) {
                adjustMaxWC = detail.AdjustTotalWCSummary__c;
            }

            // WC率
            if(detail.AdjustTotalWCRateMax__c != null) {
                adjustMaxWCRate = detail.AdjustTotalWCRateMax__c;
            }

            // TC
            if(detail.AdjustTotalTCMaxSummary__c != null) {
                adjustMaxTC = detail.AdjustTotalTCMaxSummary__c;
            }

            // TC率
            if(detail.AdjustTotalTCRateMax__c != null) {
                adjustMaxTCRate = detail.AdjustTotalTCRateMax__c;
            }

            // 手数料
            // 参照手数料伺いがある場合、「前回との差異」を表示する
            if(String.isNotBlank(detail.DependentFeeInquiry__c) && detail.DependentFeeInquiry__r.DifferenceWithLastTimeMax__c != null){
                adjustMaxSalesCommission =detail.DependentFeeInquiry__r.DifferenceWithLastTimeMax__c;
            } else {
                if(detail.AdjustMaxFee__c != null) {
                    adjustMaxSalesCommission = detail.AdjustMaxFee__c;
                }
            }

            // 粗利
            adjustMaxGrossProfit = adjustMaxCP - adjustMaxWC - adjustMaxSalesCommission;

            // 利益
            adjustMaxProfit = adjustMaxCP - adjustMaxTC - adjustMaxSalesCommission;

            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('今回増減額(MAX)',false,true));

            cellList.add(setCell(adjustMaxCP,false,false));
            cellList.add(setCell(adjustMaxWC,false,false));
            cellList.add(setCell(adjustMaxWCRate,true,false));
            cellList.add(setCell(adjustMaxTC,false,false));
            cellList.add(setCell(adjustMaxTCRate,true,false));
            cellList.add(setCell(adjustMaxSalesCommission,false,false));
            cellList.add(setCell(adjustMaxGrossProfit,false,false));
            cellList.add(setCell(adjustMaxProfit,false,false));

            row.cellList = cellList;
            bodyList.add(row);

            Decimal adjustMinCP = 0;
            Decimal adjustMinWC = 0;
            Decimal adjustMinWCRate = 0;
            Decimal adjustMinTC = 0;
            Decimal adjustMinTCRate = 0;
            Decimal adjustMinSalesCommission = 0;
            Decimal adjustMinGrossProfit = 0;
            Decimal adjustMinProfit = 0;

            // CP
            if(detail.AdjustTotalCPMinSummary__c != null) {
                adjustMinCP = detail.AdjustTotalCPMinSummary__c;
            }


            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('今回増減額(MIN)',false,true));

            if(adjustMinCP != null && adjustMinCP != 0){
                // WC
                if(detail.AdjustTotalWCSummary__c != null) {
                    adjustMinWC = detail.AdjustTotalWCSummary__c;
                }

                // WC率
                if(detail.AdjustTotalWCRateMin__c != null) {
                    adjustMinWCRate = detail.AdjustTotalWCRateMin__c;
                }

                // TC
                if(detail.AdjustTotalTCMinSummary__c != null) {
                    adjustMinTC = detail.AdjustTotalTCMinSummary__c;
                }

                // TC率
                if(detail.AdjustTotalTCRateMin__c != null) {
                    adjustMinTCRate = detail.AdjustTotalTCRateMin__c;
                }

                // 手数料
                // 参照手数料伺いがある場合、「前回との差異」を表示する
                if(String.isNotBlank(detail.DependentFeeInquiry__c) && detail.DependentFeeInquiry__r.DifferenceWithLastTimeMin__c != null){
                    adjustMinSalesCommission =detail.DependentFeeInquiry__r.DifferenceWithLastTimeMin__c;
                } else {
                    if(detail.AdjustMinFee__c != null) {
                        adjustMinSalesCommission = detail.AdjustMinFee__c;
                    }
                }

                // 粗利
                adjustMinGrossProfit = adjustMinCP - adjustMinWC - adjustMinSalesCommission;

                // 利益
                adjustMinProfit = adjustMinCP - adjustMinTC - adjustMinSalesCommission;

                cellList.add(setCell(adjustMinCP,false,false));
                cellList.add(setCell(adjustMinWC,false,false));
                cellList.add(setCell(adjustMinWCRate,true,false));
                cellList.add(setCell(adjustMinTC,false,false));
                cellList.add(setCell(adjustMinTCRate,true,false));
                cellList.add(setCell(adjustMinSalesCommission,false,false));
                cellList.add(setCell(adjustMinGrossProfit,false,false));
                cellList.add(setCell(adjustMinProfit,false,false));
            } else {
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
            }
            row.cellList = cellList;
            bodyList.add(row);

            //　計算用引数
            Decimal sum1 = 0;
            Decimal sum2 = 0;

            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('今回合計(MAX)',false,true));
            // 最新_CP＋今回増減額CP（MAX)
            // 最新_CPがブランクの場合、原契約_CP＋今回増減額CP（MAX)
            if(detailAfterDesignChangeCP != null && detailAfterDesignChangeCP != 0){
                sum1 = detailAfterDesignChangeCP;
            }else if(originalContractCP != null && originalContractCP != 0){
                sum1 = originalContractCP;
            }

            if(adjustMaxCP != null && adjustMaxCP != 0){
                sum2 = adjustMaxCP;
            }
            Decimal adjustMaxCPTotal = sum1 + Sum2;
            cellList.add(setCell(sum1 + Sum2,false,false));

            sum1 = 0;
            sum2 = 0;

            // 最新_WC＋今回増減額WC（MAX)
            // 最新_WCがブランクの場合、原契約_WC＋今回増減額WC（MAX)
            if(detailAfterDesignChangeWC != null && detailAfterDesignChangeWC != 0){
                sum1 = detailAfterDesignChangeWC;
            }else if(originalContractWC != null && originalContractWC != 0){
                sum1 = originalContractWC;
            }

            if(adjustMaxWC != null && adjustMaxWC != 0){
                sum2 = adjustMaxWC;
            }
            Decimal adjustMaxWCTotal = sum1 + Sum2;
            cellList.add(setCell(sum1 + Sum2,false,false));

            sum1 = 0;
            sum2 = 0;

            // 今回合計(MAX) WC率＝今回合計(MAX) WC/今回合計(MAX) CP
            Decimal adjustMaxWCTotalRate = 0;
            if (adjustMaxCPTotal != 0 && adjustMaxWCTotal != 0) {
                adjustMaxWCTotalRate = (adjustMaxWCTotal / adjustMaxCPTotal * 100).setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(adjustMaxWCTotalRate,true,false)); 

            // 最新_TC＋今回増減額TC（MAX)
            // 最新_TCがブランクの場合、原契約_TC＋今回増減額TC（MAX)
            if(detailAfterDesignTC!= null && detailAfterDesignTC != 0){
                sum1 = detailAfterDesignTC;
            }else if(originalContractTC != null && originalContractTC != 0){
                sum1 = originalContractTC;
            }

            if(adjustMaxTC != null && adjustMaxTC != 0){
                sum2 = adjustMaxTC;
            }
            Decimal adjustMaxTCTotal = sum1 + sum2;
            cellList.add(setCell(sum1 + sum2,false,false));

            sum1 = 0;
            sum2 = 0;

            // 今回合計(MAX) TC率＝今回合計(MAX) TC/今回合計(MAX) CP
            Decimal adjustMaxTCTotalRate = 0;
            if (adjustMaxCPTotal != 0 && adjustMaxTCTotal != 0) {
                adjustMaxTCTotalRate = (adjustMaxTCTotal / adjustMaxCPTotal * 100).setScale(1, RoundingMode.HALF_UP);
            }
            cellList.add(setCell(adjustMaxTCTotalRate,true,false));

            // 最新_手数料＋今回増減額手数料（MAX)
            // 最新_手数料がブランクの場合、原契約_手数料＋今回増減額手数料（MAX)
            if(detailAfterDesignSalesCommission != null && detailAfterDesignSalesCommission != 0){
                sum1 = detailAfterDesignSalesCommission;
            }else if(originalContractSalesCommission != null && originalContractSalesCommission != 0){
                sum1 = originalContractSalesCommission;
            }
            if (adjustMaxSalesCommission != null && adjustMaxSalesCommission != 0) {
                sum2 = adjustMaxSalesCommission;
            }
            Decimal adjustMaxSalesCommissionTotal = sum1 + sum2;
            cellList.add(setCell(sum1 + sum2,false,false));

            // 今回合計(MAX) 粗利＝今回合計(MAX) CP-今回合計(MAX) WC-今回合計(MAX) 手数料
            Decimal adjustMaxGrossProfitTotal = adjustMaxCPTotal - adjustMaxWCTotal - adjustMaxSalesCommissionTotal;
            cellList.add(setCell(adjustMaxGrossProfitTotal,false,false));

            sum1 = 0;
            sum2 = 0;

            // 今回合計(MAX) 利益＝今回合計(MAX) CP-今回合計(MAX) TC-今回合計(MAX) 手数料
            Decimal adjustMaxProfitTotal = adjustMaxCPTotal - adjustMaxTCTotal - adjustMaxSalesCommissionTotal;
            cellList.add(setCell(adjustMaxProfitTotal,false,false));

            row.cellList = cellList;
            bodyList.add(row);

            row = new BodyRow();
            cellList  = new List<BodyCell>();
            cellList.add(setCell('今回合計(MIN)',false,true));

            if(adjustMinCP != null && adjustMinCP != 0){
                // 最新_CP＋今回増減額CP（MIN)
                // 最新_CPがブランクの場合、原契約_CP＋今回増減額CP（MIN)
                if(detailAfterDesignChangeCP != null && detailAfterDesignChangeCP != 0){
                    sum1 = detailAfterDesignChangeCP;
                }else if(originalContractCP != null && originalContractCP != 0){
                    sum1 = originalContractCP;
                }

                if(adjustMinCP != null && adjustMinCP != 0){
                    sum2 = adjustMinCP;
                }
                Decimal adjustMinCPTotal = sum1 + Sum2;
                cellList.add(setCell(sum1 + Sum2,false,false));

                sum1 = 0;
                sum2 = 0;

                // 最新_WC＋今回増減額WC（MIN)
                // 最新_WCがブランクの場合、原契約_WC＋今回増減額WC（MIN)
                if(detailAfterDesignChangeWC != null && detailAfterDesignChangeWC != 0){
                    sum1 = detailAfterDesignChangeWC;
                }else if(originalContractWC != null && originalContractWC != 0){
                    sum1 = originalContractWC;
                }

                if(adjustMinWC != null && adjustMinWC != 0){
                    sum2 = adjustMinWC;
                }
                Decimal adjustMinWCTotal = sum1 + Sum2;

                cellList.add(setCell(sum1 + Sum2,false,false));

                sum1 = 0;
                sum2 = 0;

                // 今回合計(MIN) WC率＝今回合計(MIN) WC/今回合計(MIN) CP
                Decimal adjustMinWCTotalRate = 0;
                if (adjustMinCPTotal != 0 && adjustMinWCTotal != 0) {
                    adjustMinWCTotalRate = (adjustMinWCTotal / adjustMinCPTotal * 100).setScale(1, RoundingMode.HALF_UP);
                }
                cellList.add(setCell(adjustMinWCTotalRate,true,false));

                // 最新_TC＋今回増減額TC（MIN)
                // 最新_TCがブランクの場合、原契約_TC＋今回増減額TC（MIN)
                if(detailAfterDesignTC!= null && detailAfterDesignTC != 0){
                    sum1 = detailAfterDesignTC;
                }else if(originalContractTC != null && originalContractTC != 0){
                    sum1 = originalContractTC;
                }

                if(adjustMinTC != null && adjustMinTC != 0){
                    sum2 = adjustMinTC;
                }
                Decimal adjustMinTCTotal = sum1 + Sum2;
                cellList.add(setCell(sum1 + Sum2,false,false));

                sum1 = 0;
                sum2 = 0;

                // 今回合計(MIN) TC率＝今回合計(MIN) TC/今回合計(MIN) CP
                Decimal adjustMinTCTotalRate = 0;
                if (adjustMinCPTotal != 0 && adjustMinTCTotal != 0) {
                    adjustMinTCTotalRate = (adjustMinTCTotal / adjustMinCPTotal * 100).setScale(1, RoundingMode.HALF_UP);
                }
                cellList.add(setCell(adjustMinTCTotalRate,true,false));

                // 最新_手数料＋今回増減額手数料（MIN)
                // 最新_手数料がブランクの場合、原契約_手数料＋今回増減額手数料（MIN)
                if(detailAfterDesignSalesCommission != null && detailAfterDesignSalesCommission != 0){
                    sum1 = detailAfterDesignSalesCommission;
                }else if(originalContractSalesCommission != null && originalContractSalesCommission != 0){
                    sum1 = originalContractSalesCommission;
                }
                if (adjustMinSalesCommission != null && adjustMinSalesCommission != 0) {
                    sum2 = adjustMinSalesCommission;
                }

                Decimal adjustMinSalesCommissionTotal = sum1 + Sum2;
                cellList.add(setCell(sum1 + Sum2,false,false));

                // 今回合計(MIN) 粗利＝今回合計(MIN) CP-今回合計(MIN) WC-今回合計(MIN) 手数料
                Decimal adjustMinGrossProfitTotal = adjustMinCPTotal - adjustMinWCTotal - adjustMinSalesCommissionTotal;
                cellList.add(setCell(adjustMinGrossProfitTotal,false,false));

                // 今回合計(MIN) 利益＝今回合計(MIN) CP-今回合計(MIN) TC-今回合計(MIN) 手数料
                Decimal adjustMinProfitTotal = adjustMinCPTotal - adjustMinTCTotal - adjustMinSalesCommissionTotal;
                cellList.add(setCell(adjustMinProfitTotal,false,false));
            } else {
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
                cellList.add(setCell('',false,true));
            }

            row.cellList = cellList;
            bodyList.add(row);
        }
        info.bodyList = bodyList;
        info.recordType = detail.RecordType.DeveloperName;
        System.debug('info:' + info.recordType);
        return JSON.serialize(info);
    }

    /**
     * セルの設定
     * @param value
     * @param isPercent
     * @param isText
     * @return BodyCell
     */
    private static BodyCell setCell(Object value, Boolean isPercent, Boolean isText){
        BodyCell cell = new BodyCell();
        cell.value = value;
        cell.isPercent = isPercent;
        cell.isText = isText;
        return cell;
    }

    /**
     * セルの設定
     * @param value
     * @param isPercent
     * @param isText
     * @param isDisable
     * @return BodyCell
     */
    private static BodyCell setCell(Object value, Boolean isPercent, Boolean isText, Boolean isDisable){
        BodyCell cell = new BodyCell();
        cell.value = value;
        cell.isPercent = isPercent;
        cell.isText = isText;
        cell.isDisable = isDisable;
        return cell;
    }
}