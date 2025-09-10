public class BidAgencyDetailGetTableController {

    /**
     * 画面情報
     */
    public class ScreenInfo {
        public List<BodyRow> bodyListMax { get; set; } // 算出手数料（MAX）リスト
        public List<BodyRow> bodyListMin { get; set; } // 算出手数料（MIN）リスト
        public Boolean isShowDependentFeeInquiry {get;set;} // 前回との決定決定手数料表示フラグ
    }
    /**
     * ボディ行
     */
    public class BodyRow {
        public List<BodyCell> cellList {get;set;} // セルリスト
    }
    /**
     * ボディセル
     */
    public class BodyCell {
        public Object value {get;set;} // 値
        public Boolean isPercent {get;set;} // パーセント表示フラグ
        public Boolean isText {get;set;} // テキスト表示フラグ
        public Boolean isDisabled {get;set;} // 無効フラグ
        public Boolean isNoLeftborder {get;set;} // 左ボーダーなしフラグ
        public Boolean isNoRightborder {get;set;} // 右ボーダーなしフラグ
        public Boolean isNoRightAndLeftborder {get;set;} // 左右ボーダーなしフラグ
        public Boolean hasBgColor {get;set;} // 背景色フラグ
        public Boolean isLastRow {get;set;} // 最終行フラグ
        public Boolean isBlank {get;set;} // 空白フラグ
    }

    /**
     * 画面のデータを取得する
     * @param recId レコードID
     */
    @AuraEnabled
    public static String getDetailTable(String recId){
        ScreenInfo info = new ScreenInfo();
        QuoteBiddingInquiry__c detail;
        if (String.isNotBlank(recId)) {
            detail = [SELECT Id,
                            Agency1StoreName__c, // 代理店1_店名
                            Agency1StoreName__r.name, // 代理店1_店名
                            Agency1TradingStyle__c, // 代理店1_取引形態
                            Agency1Qualification__c, // 代理店1_資格
                            Agency2Name__c, // 代理店2_店名
                            Agency2Name__r.name, // 代理店2_店名
                            Agency2TradingStyle__c, // 代理店2_取引形態
                            Agency2Qualification__c, // 代理店2_資格
                            Agency3Name__c, // 代理店3_店名
                            Agency3Name__r.name, // 代理店3_店名
                            Agency3TradingStyle__c, // 代理店3_取引形態
                            Agency3Qualification__c, // 代理店3_資格
                            TheoryFeeMax__c, // 理論手数料(MAX)
                            TheoryFeeMin__c, // 理論手数料(MIN)
                            Agency1MaxFee__c, // 代理店1_決定手数料(MAX)
                            Agency1MinFee__c, // 代理店1_決定手数料(MIN)
                            Agency2MaxFee__c, // 代理店2_決定手数料(MAX)
                            Agency2MinFee__c, // 代理店2_決定手数料(MIN)
                            Agency3MaxFee__c, // 代理店3_決定手数料(MAX)
                            Agency3MinFee__c, // 代理店3_決定手数料(MIN)
                            MaxFeeTotal__c, // 決定手数料(MAX)_合計
                            MinFeeTotal__c, // 決定手数料(MIN)_合計
                            Agency1MaxTheoryFeeRatio__c, // 代理店1_理論手数料比率(MAX)
                            Agency1MinTheoryFeeRatio__c, // 代理店1_理論手数料比率(MIN)
                            Agency2MaxTheoryFeeRatio__c, // 代理店2_理論手数料比率(MAX)
                            Agency2MinTheoryFeeRatio__c, // 代理店2_理論手数料比率(MIN)
                            Agency3MaxTheoryFeeRatio__c, // 代理店3_理論手数料比率(MAX)
                            Agency3MinTheoryFeeRatio__c, // 代理店3_理論手数料比率(MIN)
                            TheoryFeeRatioMaxTotal__c, // 理論手数料比率(MAX)_合計
                            TheoryFeeRatioMinTotal__c, // 理論手数料比率(MIN)_合計
                            GeneralFeeTotal_MAX__c, // 一般手数料合計(MAX)
                            GeneralFeeTotal_MIN__c, // 一般手数料合計(MIN)
                            SpecialFeeTotal_MAX__c, // 特別手数料合計(MAX)
                            SpecialFeeTotal_MIN__c, // 特別手数料合計(MIN)
                            Agency1MaxCalculationFee__c, // 代理店1_算出手数料(MAX)
                            Agency1MinCalculationFee__c, // 代理店1_算出手数料(MIN)
                            Agency2MaxCalculationFee__c, // 代理店2_算出手数料(MAX)
                            Agency2MinCalculationFee__c, // 代理店2_算出手数料(MIN)
                            Agency3MaxCalculationFee__c, // 代理店3_算出手数料(MAX)
                            Agency3MinCalculationFee__c, // 代理店3_算出手数料(MIN)
                            MaxCalculationFeeTotal__c, // 算出手数料(MAX)_合計
                            MinCalculationFeeTotal__c, // 算出手数料(MIN)_合計
                            DependentFeeInquiry__c, // 参照先手数料伺い
                            DependentFeeInquiry__r.Agency1MaxFee__c, // 参照先手数料伺いの代理店1_決定手数料(MAX)
                            DependentFeeInquiry__r.Agency1MinFee__c, // 参照先手数料伺いの代理店1_決定手数料(MIN)
                            DependentFeeInquiry__r.Agency2MaxFee__c, // 参照先手数料伺いの代理店2_決定手数料(MAX)
                            DependentFeeInquiry__r.Agency2MinFee__c, // 参照先手数料伺いの代理店2_決定手数料(MIN)
                            DependentFeeInquiry__r.Agency3MaxFee__c, // 参照先手数料伺いの代理店3_決定手数料(MAX)
                            DependentFeeInquiry__r.Agency3MinFee__c, // 参照先手数料伺いの代理店3_決定手数料(MIN)
                            DependentFeeInquiry__r.MaxFeeTotal__c, // 参照先手数料伺いの決定手数料(MAX)_合計
                            DependentFeeInquiry__r.MinFeeTotal__c, // 参照先手数料伺いの決定手数料(MIN)_合計
                            ContractAmountMin__c // 受注(見込)CP【MIN】
                        FROM QuoteBiddingInquiry__c
                        WHERE Id = :recId
                        LIMIT 1];
        }

        if(detail == null) {
            return JSON.serialize(info);
        }
        
        info.isShowDependentFeeInquiry = false;
        List<BodyRow> bodyListMax = new List<BodyRow>();
        BodyRow row = new BodyRow();
        List<BodyCell> cellList  = new List<BodyCell>();
        // 代理店1_店名
        cellList.add(setCell(detail.Agency1StoreName__r.name,false,true,false)); 
        // 代理店1_取引形態
        cellList.add(setCell(detail.Agency1TradingStyle__c,false,true,false));
        // 代理店1_資格
        cellList.add(setCell(detail.Agency1Qualification__c,false,true,false));
        cellList.add(setCell('0',false,false,true));
        // 代理店1_決定手数料(MAX)
        cellList.add(setCellHasBg(detail.Agency1MaxFee__c,false,false,false,true,false,false));
        // 代理店1_理論手数料比率(MAX)
        cellList.add(setCell(detail.Agency1MaxTheoryFeeRatio__c==null?0:detail.Agency1MaxTheoryFeeRatio__c,true,false,false));
        // 参照先手数料伺いがある場合
        Decimal Agency1MaxFeeCalculateValue = 0;
        if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
            info.isShowDependentFeeInquiry = true;
            cellList.add(setCellHasBg(detail.DependentFeeInquiry__r.Agency1MaxFee__c,false,false,false,false,false,true));
            Agency1MaxFeeCalculateValue = (detail.Agency1MaxFee__c==null?0:detail.Agency1MaxFee__c) - (detail.DependentFeeInquiry__r.Agency1MaxFee__c==null?0:detail.DependentFeeInquiry__r.Agency1MaxFee__c);
            cellList.add(setCellHasBg(Agency1MaxFeeCalculateValue,false,false,false,false,false,true));
        }
        cellList.add(setCell('',false,false,true));
        cellList.add(setCell('',false,false,true));
        // 代理店1_算出手数料(MAX)
        cellList.add(setCell(detail.Agency1MaxCalculationFee__c,false,false,false));
        row.cellList = cellList;
        bodyListMax.add(row);

        row = new BodyRow();
        cellList  = new List<BodyCell>();
        // 代理店2_店名
        cellList.add(setCell(detail.Agency2Name__r.name,false,true,false));
        // 代理店2_取引形態
        cellList.add(setCell(detail.Agency2TradingStyle__c,false,true,false));
        // 代理店2_資格
        cellList.add(setCell(detail.Agency2Qualification__c,false,true,false));
        cellList.add(setCell('0',false,false,true));
        // 代理店2_決定手数料(MAX)
        cellList.add(setCellHasBg(detail.Agency2MaxFee__c,false,false,false,true,false,false));
        // 代理店2_理論手数料比率(MAX)
        cellList.add(setCell(detail.Agency2MaxTheoryFeeRatio__c==null?0:detail.Agency2MaxTheoryFeeRatio__c,true,false,false));
        // 参照先手数料伺いがある場合
        Decimal Agency2MaxFeeCalculateValue = 0;
        if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
            cellList.add(setCellHasBg(detail.DependentFeeInquiry__r.Agency2MaxFee__c,false,false,false,false,false,true));
            Agency2MaxFeeCalculateValue = (detail.Agency2MaxFee__c==null?0:detail.Agency2MaxFee__c) - (detail.DependentFeeInquiry__r.Agency2MaxFee__c == null?0:detail.DependentFeeInquiry__r.Agency2MaxFee__c);
            cellList.add(setCellHasBg(Agency2MaxFeeCalculateValue,false,false,false,false,false,true));
        }
        cellList.add(setCell('',false,false,true));
        cellList.add(setCell('',false,false,true));
        // 代理店2_算出手数料(MAX)
        cellList.add(setCell(detail.Agency2MaxCalculationFee__c,false,false,false));
        row.cellList = cellList;
        bodyListMax.add(row);

        row = new BodyRow();
        cellList  = new List<BodyCell>();
        // 代理店3_店名
        cellList.add(setCell(detail.Agency3Name__r.name,false,true,false));
        // 代理店3_取引形態
        cellList.add(setCell(detail.Agency3TradingStyle__c,false,true,false));
        // 代理店3_資格
        cellList.add(setCell(detail.Agency3Qualification__c,false,true,false));
        cellList.add(setCell('0',false,false,true));
        // 代理店3_決定手数料(MAX)
        cellList.add(setCellHasBg(detail.Agency3MaxFee__c,false,false,false,true,false,false));
        // 代理店3_理論手数料比率(MAX)
        cellList.add(setCell(detail.Agency3MaxTheoryFeeRatio__c==null?0:detail.Agency3MaxTheoryFeeRatio__c,true,false,false));
        // 参照先手数料伺いがある場合
        Decimal Agency3MaxFeeCalculateValue = 0;
        if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
            cellList.add(setCellHasBg(detail.DependentFeeInquiry__r.Agency3MaxFee__c,false,false,false,false,false,true));
            Agency3MaxFeeCalculateValue = (detail.Agency3MaxFee__c==null?0:detail.Agency3MaxFee__c) - (detail.DependentFeeInquiry__r.Agency3MaxFee__c == null?0:detail.DependentFeeInquiry__r.Agency3MaxFee__c);
            cellList.add(setCellHasBg(Agency3MaxFeeCalculateValue,false,false,false,false,false,true));
        }
        cellList.add(setCell('',false,false,true));
        cellList.add(setCell('',false,false,true));
        // 代理店3_算出手数料(MAX)
        cellList.add(setCell(detail.Agency3MaxCalculationFee__c,false,false,false));
        row.cellList = cellList;
        bodyListMax.add(row);

        row = new BodyRow();
        cellList  = new List<BodyCell>();
        cellList.add(setCell('',false,true,false,true));
        cellList.add(setCell('',false,false,true,true));
        cellList.add(setCell('計',true,false,false,true));
        // 理論手数料(MAX)
        cellList.add(setCell(detail.TheoryFeeMax__c,false,false,false));
        // 決定手数料(MAX)_合計
        cellList.add(setCellHasBg(detail.MaxFeeTotal__c,false,false,false,true,true,false));
        // 理論手数料比率(MAX)_合計
        cellList.add(setCell(detail.TheoryFeeRatioMaxTotal__c==null?0:detail.TheoryFeeRatioMaxTotal__c,true,false,false));
        // 参照先手数料伺いがある場合
        if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
            cellList.add(setCellHasBg((detail.DependentFeeInquiry__r.Agency1MaxFee__c == null?0 :detail.DependentFeeInquiry__r.Agency1MaxFee__c)
                + (detail.DependentFeeInquiry__r.Agency2MaxFee__c == null?0 :detail.DependentFeeInquiry__r.Agency2MaxFee__c) 
                + (detail.DependentFeeInquiry__r.Agency3MaxFee__c == null?0 :detail.DependentFeeInquiry__r.Agency3MaxFee__c)
                ,false,false,false,false,true,true));
            cellList.add(setCellHasBg(Agency1MaxFeeCalculateValue + Agency2MaxFeeCalculateValue + Agency3MaxFeeCalculateValue,false,false,false,false,true,true));
        }
        // 一般手数料合計(MAX)
        cellList.add(setCell(detail.GeneralFeeTotal_MAX__c,false,false,false));
        // 特別手数料合計(MAX)
        cellList.add(setCell(detail.SpecialFeeTotal_MAX__c,false,false,false));
        // 算出手数料(MAX)_合計
        cellList.add(setCell(detail.MaxCalculationFeeTotal__c,false,false,false));
        row.cellList = cellList;
        bodyListMax.add(row);

        List<BodyRow> bodyListMin = new List<BodyRow>();
        row = new BodyRow();
        cellList  = new List<BodyCell>();
        Decimal Agency1MinFeeCalculateValue = 0;
        if(detail.ContractAmountMin__c != null) {
            // 代理店1_店名
            cellList.add(setCell(detail.Agency1StoreName__r.name,false,true,false)); 
            // 代理店1_取引形態
            cellList.add(setCell(detail.Agency1TradingStyle__c,false,true,false));
            // 代理店1_資格
            cellList.add(setCell(detail.Agency1Qualification__c,false,true,false));
            cellList.add(setCell('0',false,false,true));
            // 代理店1_決定手数料(Min)
            cellList.add(setCellHasBg(detail.Agency1MinFee__c,false,false,false,true,false,false));
            // 代理店1_理論手数料比率(Min)
            cellList.add(setCell(detail.Agency1MinTheoryFeeRatio__c==null?0:detail.Agency1MinTheoryFeeRatio__c,true,false,false));
            // 参照先手数料伺いがある場合
            if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
                info.isShowDependentFeeInquiry = true;
                cellList.add(setCellHasBg(detail.DependentFeeInquiry__r.Agency1MinFee__c,false,false,false,false,false,true));
                Agency1MinFeeCalculateValue = (detail.Agency1MinFee__c==null?0:detail.Agency1MinFee__c) - (detail.DependentFeeInquiry__r.Agency1MinFee__c == null?0:detail.DependentFeeInquiry__r.Agency1MinFee__c);
                cellList.add(setCellHasBg(Agency1MinFeeCalculateValue,false,false,false,false,false,true));
            }
            cellList.add(setCell('',false,false,true));
            cellList.add(setCell('',false,false,true));
            // 代理店1_算出手数料(Min)
            cellList.add(setCell(detail.Agency1MinCalculationFee__c,false,false,false));
        } else {
            // 代理店1_店名
            cellList.add(setCell('',false,false,false));
            // 代理店1_取引形態
            cellList.add(setCell('',false,false,false));
            // 代理店1_資格
            cellList.add(setCell('',false,false,false));
            cellList.add(setCell('',false,false,true));
            // 代理店1_決定手数料(Min)
            cellList.add(setCellHasBg('',false,false,false,true,false,false));
            // 代理店1_理論手数料比率(Min)
            cellList.add(setCell('',true,false,false));
            // 参照先手数料伺いがある場合
            if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
                info.isShowDependentFeeInquiry = true;
                cellList.add(setCellHasBg('',false,false,false,false,false,true));
                cellList.add(setCellHasBg('',false,false,false,false,false,true));
            }
            cellList.add(setCell('',false,false,true));
            cellList.add(setCell('',false,false,true));
            // 代理店1_算出手数料(Min)
            cellList.add(setCell('',false,false,false));
        }
        row.cellList = cellList;
        bodyListMin.add(row);

        row = new BodyRow();
        cellList  = new List<BodyCell>();
        Decimal Agency2MinFeeCalculateValue = 0;
        if(detail.ContractAmountMin__c != null) {
            // 代理店2_店名
            cellList.add(setCell(detail.Agency2Name__r.name,false,true,false));
            // 代理店2_取引形態
            cellList.add(setCell(detail.Agency2TradingStyle__c,false,true,false));
            // 代理店2_資格
            cellList.add(setCell(detail.Agency2Qualification__c,false,true,false));
            cellList.add(setCell('0',false,false,true));
            // 代理店2_決定手数料(Min)
            cellList.add(setCellHasBg(detail.Agency2MinFee__c,false,false,false,true,false,false));
            // 代理店2_理論手数料比率(Min)
            cellList.add(setCell(detail.Agency2MinTheoryFeeRatio__c==null?0:detail.Agency2MinTheoryFeeRatio__c,true,false,false));
            // 参照先手数料伺いがある場合
            if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
                cellList.add(setCellHasBg(detail.DependentFeeInquiry__r.Agency2MinFee__c,false,false,false,false,false,true));
                Agency2MinFeeCalculateValue = (detail.Agency2MinFee__c==null?0:detail.Agency2MinFee__c) - (detail.DependentFeeInquiry__r.Agency2MinFee__c == null?0:detail.DependentFeeInquiry__r.Agency2MinFee__c);
                cellList.add(setCellHasBg(Agency2MinFeeCalculateValue,false,false,false,false,false,true));
            }
            cellList.add(setCell('',false,false,true));
            cellList.add(setCell('',false,false,true));
            // 代理店2_算出手数料(Min)
            cellList.add(setCell(detail.Agency2MinCalculationFee__c,false,false,false));
        } else {
            // 代理店2_店名
            cellList.add(setCell('',false,false,false));
            // 代理店2_取引形態
            cellList.add(setCell('',false,false,false));
            // 代理店2_資格
            cellList.add(setCell('',false,false,false));
            cellList.add(setCell('',false,false,true));
            // 代理店2_決定手数料(Min)
            cellList.add(setCellHasBg('',false,false,false,true,false,false));
            // 代理店2_理論手数料比率(Min)
            cellList.add(setCell('',true,false,false));
            // 参照先手数料伺いがある場合
            if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
                cellList.add(setCellHasBg('',false,false,false,false,false,true));
                cellList.add(setCellHasBg('',false,false,false,false,false,true));
            }
            cellList.add(setCell('',false,false,true));
            cellList.add(setCell('',false,false,true));
            // 代理店2_算出手数料(Min)
            cellList.add(setCell('',false,false,false));
        }
        row.cellList = cellList;
        bodyListMin.add(row);

        row = new BodyRow();
        cellList  = new List<BodyCell>();
        Decimal Agency3MinFeeCalculateValue = 0;
        if(detail.ContractAmountMin__c != null) {
            // 代理店3_店名
            cellList.add(setCell(detail.Agency3Name__r.name,false,true,false));
            // 代理店3_取引形態
            cellList.add(setCell(detail.Agency3TradingStyle__c,false,true,false));
            // 代理店3_資格
            cellList.add(setCell(detail.Agency3Qualification__c,false,true,false));
            cellList.add(setCell('0',false,false,true));
            // 代理店3_決定手数料(Min)
            cellList.add(setCellHasBg(detail.Agency3MinFee__c,false,false,false,true,false,false));
            // 代理店3_理論手数料比率(Min)
            cellList.add(setCell(detail.Agency3MinTheoryFeeRatio__c==null?0:detail.Agency3MinTheoryFeeRatio__c,true,false,false));
            // 参照先手数料伺いがある場合
            if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
                cellList.add(setCellHasBg(detail.DependentFeeInquiry__r.Agency3MinFee__c,false,false,false,false,false,true));
                Agency3MinFeeCalculateValue = (detail.Agency3MinFee__c==null?0:detail.Agency3MinFee__c) - (detail.DependentFeeInquiry__r.Agency3MinFee__c == null?0:detail.DependentFeeInquiry__r.Agency3MinFee__c);
                cellList.add(setCellHasBg(Agency3MinFeeCalculateValue,false,false,false,false,false,true));
            }
            cellList.add(setCell('',false,false,true));
            cellList.add(setCell('',false,false,true));
            // 代理店3_算出手数料(Min)
            cellList.add(setCell(detail.Agency3MinCalculationFee__c,false,false,false));
        } else {
            // 代理店3_店名
            cellList.add(setCell('',false,false,false));
            // 代理店3_取引形態
            cellList.add(setCell('',false,false,false));
            // 代理店3_資格
            cellList.add(setCell('',false,false,false));
            cellList.add(setCell('',false,false,true));
            // 代理店3_決定手数料(Min)
            cellList.add(setCellHasBg('',false,false,false,true,false,false));
            // 代理店3_理論手数料比率(Min)
            cellList.add(setCell('',true,false,false));
            // 参照先手数料伺いがある場合
            if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
                cellList.add(setCellHasBg('',false,false,false,false,false,true));
                cellList.add(setCellHasBg('',false,false,false,false,false,true));
            }
            cellList.add(setCell('',false,false,true));
            cellList.add(setCell('',false,false,true));
            // 代理店3_算出手数料(Min)
            cellList.add(setCell('',false,false,false));
        }
        row.cellList = cellList;
        bodyListMin.add(row);

        row = new BodyRow();
        cellList  = new List<BodyCell>();
        cellList.add(setCell('',false,true,false,true));
        cellList.add(setCell('',false,false,true,true));
        cellList.add(setCell('計',true,false,false,true));
        
        if(detail.ContractAmountMin__c != null) {
            // 理論手数料(Min)
            cellList.add(setCell(detail.TheoryFeeMin__c,false,false,false));
            // 決定手数料(MIN)_合計
            cellList.add(setCellHasBg(detail.MinFeeTotal__c,false,false,false,true,true,false));
            // 理論手数料比率(Min)_合計
            cellList.add(setCell(detail.TheoryFeeRatioMinTotal__c==null?0:detail.TheoryFeeRatioMinTotal__c,true,false,false));
            // 参照先手数料伺いがある場合
            if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
                cellList.add(setCellHasBg((detail.DependentFeeInquiry__r.Agency1MinFee__c==null?0:detail.DependentFeeInquiry__r.Agency1MinFee__c)
                + (detail.DependentFeeInquiry__r.Agency2MinFee__c== null?0:detail.DependentFeeInquiry__r.Agency2MinFee__c)
                + (detail.DependentFeeInquiry__r.Agency3MinFee__c == null?0:detail.DependentFeeInquiry__r.Agency3MinFee__c)
                ,false,false,false,false,true,true));
                cellList.add(setCellHasBg(Agency1MinFeeCalculateValue + Agency2MinFeeCalculateValue + Agency3MinFeeCalculateValue,false,false,false,false,true,true));
            }
            // 一般手数料合計(Min)
            cellList.add(setCell(detail.GeneralFeeTotal_Min__c,false,false,false));
            // 特別手数料合計(Min)
            cellList.add(setCell(detail.SpecialFeeTotal_Min__c,false,false,false));
            // 算出手数料(Min)_合計
            cellList.add(setCell(detail.MinCalculationFeeTotal__c,false,false,false));
        } else {
            // 理論手数料(Min)
            cellList.add(setCell('',false,false,false));
            // 決定手数料(MIN)_合計
            cellList.add(setCellHasBg('',false,false,false,true,true,false));
            // 理論手数料比率(Min)_合計
            cellList.add(setCell('',true,false,false));
            // 参照先手数料伺いがある場合
            if(String.isNotBlank(detail.DependentFeeInquiry__c)) {
                cellList.add(setCellHasBg('',false,false,false,false,true,true));
                cellList.add(setCellHasBg('',false,false,false,false,true,true));
            }
            // 一般手数料合計(Min)
            cellList.add(setCell('',false,false,false));
            // 特別手数料合計(Min)
            cellList.add(setCell('',false,false,false));
            // 算出手数料(Min)_合計
            cellList.add(setCell('',false,false,false));
        }
        row.cellList = cellList;
        bodyListMin.add(row);

        info.bodyListMax = bodyListMax;
        info.bodyListMin = bodyListMin;
        return JSON.serialize(info);
    }

    /**
     * セルの設定
     * @param value 値
     * @param isPercent パーセント表示フラグ
     * @param isText テキスト表示フラグ
     * @param isDisabled 無効フラグ
     * @return BodyCell
     */
    private static BodyCell setCell(Object value, Boolean isPercent, Boolean isText, Boolean isDisabled){
        BodyCell cell = new BodyCell();
        cell.value = value;
        cell.isPercent = isPercent;
        if(value == '') {
            cell.isBlank = true;
        } else {
            cell.isBlank = false;
        }
        cell.isText = isText;
        cell.isDisabled = isDisabled;
        return cell;
    }

    /**
     * セルの設定
     * @param value 値
     * @param isPercent パーセント表示フラグ
     * @param isText テキスト表示フラグ
     * @param isDisabled 無効フラグ
     * @param hasBgColor 背景色フラグ
     * @param isLastRow 最終行フラグ
     * @param isNoRightAndLeftborder 左右ボーダーなしフラグ
     * @return BodyCell
     */
    private static BodyCell setCellHasBg(Object value, Boolean isPercent, Boolean isText, Boolean isDisabled, Boolean hasBgColor, Boolean isLastRow, Boolean isNoRightAndLeftborder){
        BodyCell cell = new BodyCell();
        cell.value = value;
        if(value == '') {
            cell.isBlank = true;
        } else {
            cell.isBlank = false;
        }
        cell.isPercent = isPercent;
        cell.isText = isText;
        cell.isDisabled = isDisabled;
        cell.hasBgColor = hasBgColor;
        cell.isLastRow = isLastRow;
        cell.isNoRightAndLeftborder = isNoRightAndLeftborder;
        return cell;
    }

    /**
     * セルの設定
     * @param value 値
     * @param isNoLeftborder 左ボーダーなしフラグ
     * @param isNoRightborder 右ボーダーなしフラグ
     * @param isNoRightAndLeftborder 左右ボーダーなしフラグ
     * @param isText テキスト表示フラグ
     * @return BodyCell
     */
    private static BodyCell setCell(Object value,Boolean isNoLeftborder,Boolean isNoRightborder,Boolean isNoRightAndLeftborder, Boolean isText){
        BodyCell cell = new BodyCell();
        cell.value = value;
        cell.isNoLeftborder = isNoLeftborder;
        cell.isNoRightborder = isNoRightborder;
        cell.isNoRightAndLeftborder = isNoRightAndLeftborder;
        cell.isText = isText;
        return cell;
    }
}