/**
 * 明細入力B(明細入力B_ACB盤)画面のコントローラー
 * 
 * @author xu.ll 2023/07/27
 * @version 1.0
 */
public with sharing class DetailsInputForAcbBoardController {
    private static final String recordTypeChassis = 'Chassis';//筐体
    private static final String recordTypeDetail = 'Detail';//明細
    private static final String majorClassification = '低圧・現場・リレー・ACB盤';//大分類
    private static final String minorClassification = 'ACB盤';//小分類
    private static final String majorDetail = '共通機器';//明細の大分類



    public class ScreenInfo {
        //初期表示(選択内容)
        String inputedId {get;set;}
        Decimal inputedPrice {get;set;} //合計金額
        String displayCondition {get;set;}//選択仕様
        
        //検索条件（設置場所
        String installationLocation {get;set;}
        Boolean isM  {get;set;}
        //メイン表（筐体一覧）
        String headTitle {get; set;}
        String footerInfo {get; set;}
        public List<BodyRow> bodyList {get;set;}//一覧データ
        public List<BodyRow> headerList {get;set;}//一覧ヘッダー

        // ACB加算
        public CustomTable  acbSumTable {get;set;}
        // 零相変流器+地絡過電融継電器(ZCT+51G)
        public CustomTable  zctTable {get;set;}
        // 計器用変圧器VT,PT(低圧）引出型
        public CustomTable  transformerDrawerTable {get;set;}
        // 計器用変流器 ＣＴ(低圧)
        public CustomTable  transformerCtTable {get;set;}
        // ACB　（エアーサーキットブレーカ）
        public CustomTable  acbTable {get;set;}
        // プロテクタヒューズ
        public CustomTable  protectorFuseTable {get;set;}
        // テイクオフヒューズ
        public CustomTable  takeoffFuseTable {get;set;}
        // ネットワークリレー（multicap)
        public CustomTable  networkRelayTable {get;set;}
        // 合成CT（低圧）
        public CustomTable  mixedTable {get;set;}
        // ネットワークVT（低圧）
        public CustomTable  networkVtTable {get;set;}
        // ネットワークCT（低圧）
        public CustomTable  networkCtTable {get;set;}
        // 配線用遮断器価格 （MCCB・ELB）
        public CustomTable  mccbTable {get;set;}
        public CustomTable  mccbTableHas {get;set;}
        // 取付器具類
        public CustomTable  installEquipTypeTable {get;set;}
    }

    //行情報
    public class BodyRow {
        public List<BodyCell> cellList {get;set;}
    }
    //セル情報
    public class BodyCell {
        public Object value {get;set;}
        public Integer colSpanCnt {get;set;}//列結合数
        public Boolean isColSpan {get;set;}//列結合対象
        public Integer rowSpanCnt {get;set;}//行結合数
        public Boolean isRowSpan {get;set;}//行結合対象
        public Boolean isEdit {get;set;}//入力セル
        public Boolean isRight {get;set;}//右寄せ
    }

    //共通部品表示するため　テーブルを定義
    public class CustomTable {
        Public String secTitle{get;set;}//タイトル
        Public String comment{get;set;}//一覧右上のコメント
        public List<BodyRow> bodyList {get;set;}//表示内容
        public List<BodyRow> headerList {get;set;}//一覧ヘッダ情報
        Public List<String> noteList {get;set;}//一覧下の「注※」内容
    }
    public class QuantityObject{
        public String Id {get;set;}
        public Decimal Price {get;set;}
        public Decimal Quantity {get;set;}
    }
    @AuraEnabled
    /**
     * 明細入力B(明細入力B_ACB盤) 表示データを取得
     * 
     * @param isInit 初期フラグ
     * @param deviceId 見積項目Id
     * @param installationLocation 設置場所（屋内／屋外）
     * 
     */
    Public static String getInitScreenInfo(Boolean isInit,
                                            String deviceId,
                                            String installationLocation){
        ScreenInfo info = new ScreenInfo();

        String bu = '';
        Detail__c currentDetail;
        Map<String, Detail__c> detailsMap = new Map<String, Detail__c>();
        //見積項目を取得
        if (String.isNotBlank(deviceId)) {
            //見積項目
            Device__c device = [SELECT Id, 
                        toLabel(MajorClassification__c), //見積項目大分類
                        MinorClassification__c, //見積項目小分類
                        Quote__r.PowerFrequency__c, //見積項目周波数
                        Quote__r.RecordType.DeveloperName, //レコードタイプ
                        (SELECT Id,Name,UnitPrice__c,PricingTableUniqueKey__c,DetailCategory__c,Quantity__c,
                                Name1__c,Name2__c,Name3__c,Name4__c,Name5__c,Name6__c,Name7__c,Name8__c,Name9__c,Name10__c
                            FROM Details__r)
                        FROM Device__c WHERE Id =:deviceId LIMIT 1];

            // 見積のレコードタイプ確認し、BUの条件をセットする。
            bu = device.Quote__r.RecordType.DeveloperName == 'Facility' ? 'S' : 'M';
            if (device.Details__r!=null && device.Details__r.size()>0) {
                for (Detail__c tmp :device.Details__r) {
                    if (tmp.DetailCategory__c == '筐体' 
                        && String.isNotBlank(tmp.PricingTableUniqueKey__c)
                        && tmp.PricingTableUniqueKey__c.contains('低圧・現場・リレー・ACB盤ACB盤')) {
                        currentDetail = tmp;//筐体の登録データ
                    }else {
                        detailsMap.put(tmp.PricingTableUniqueKey__c, tmp);
                    }
                }
            }
        }
        info.isM = (bu=='M'?true:false);

        /*
         検索条件をセットする。
         ・元のデータが有る場合は、もっとの条件をセットする。
         ・元のデータが無い場合は、画面でセットされた条件をセットする。
        */
        if (isInit && currentDetail != null) {
            installationLocation = currentDetail.Name1__c;
            installationLocation = installationLocation.replace('ACB盤　','');
        }
        info.installationLocation = installationLocation;

        //価格表情報を取得
        List<PricingTable__c> chassisList = getPriceInfo(bu, installationLocation);

        //筐体
        Map<String , PricingTable__c> chassisMap = new Map<String , PricingTable__c>();
        //Mの筐体　情報
        Map<String , Set<String>> headerKeys = new  Map<String , Set<String>> ();
        Set<String> bodyKeys = new Set<String>();

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報
        //ヘッダー設定
        if (bu=='S'){
            info.headTitle='筐体';
        }else if (bu=='M'){
            info.headTitle='ACB盤（エアーサーキットブレーカ盤・気中遮断器盤）';
            info.footerInfo= System.Label.Annotation_ACBWaterEnvironment;
        }
        //テーブル設定用情報
        if (chassisList!=null && chassisList.size() > 0) {
            for (PricingTable__c tmp : chassisList) {
                if (bu=='S'){
                    //筐体の情報
                    if (tmp.RecordType.DeveloperName == 'Chassis') {
                    bodyKeys.add(tmp.Name2__c);
                    chassisMap.put(tmp.Name2__c,tmp);//S 筐体
                }
                }else if (bu=='M'){
                    //筐体の情報
                    if (tmp.RecordType.DeveloperName == 'Chassis') {
                        Set<String> name4Set = headerKeys.get(tmp.Name3__c);
                        if (name4Set == null) name4Set = new Set<String>();
                        name4Set.add(tmp.Name4__c);
                        headerKeys.put(tmp.Name3__c, name4Set);
                        bodyKeys.add(tmp.Name5__c);
                        //名称３～５を結合してキーとする
                        chassisMap.put(tmp.Name3__c+tmp.Name4__c+tmp.Name5__c,tmp); //M 筐体
                    }
                }
            }
        }

        //ヘッダー設定
        BodyRow headerRow = new BodyRow();
        List<BodyCell> headerCell = new List<BodyCell>();//ヘッダーセル
        if (bu=='S'){
            //ACB台数    価格    空白
            headerCell.add(setCell('ACB台数', null, null, false, false));
            headerCell.add(setCell('価格', null, null, false, false));
            headerCell.add(setCell('', null, null, false, false));
            headerRow.cellList = headerCell;
            headerList.add(headerRow);
        }else if (bu=='M'){
            BodyRow headerRow2 = new BodyRow();
            List<BodyCell> headerCell2 = new List<BodyCell>();//ヘッダーセル２行目
            // 母線　　　　　400V                200V            
            // 電流　A　　回路A        回路B        回路A        回路B    
            headerCell.add(setCell(new List<String>{'母線','電流　A'}, null, 2, false, false));
            for (String name3 : headerKeys.keySet()) {
                Set<String> name4Set = headerKeys.get(name3);
                //1行目の設定
                headerCell.add(setCell(name3, name4Set.size()*2, null, false, false));
                //２行目の設定
                for (String name4:name4Set) {
                    headerCell2.add(setCell(name4, null, null, false, false));
                    headerCell2.add(setCell('', null, null, false, false));

                }
            } 
            headerRow.cellList = headerCell;
            headerList.add(headerRow);
            headerRow2.cellList = headerCell2;
            headerList.add(headerRow2);
        }
        //画面情報に設定して、返し
        info.headerList = headerList;
        for (String key : bodyKeys) {
            //一行のデータ
            List<BodyCell> bodyRow = new List<BodyCell>();

            //部がMの場合、'A'を除外
            String displayKey = (bu=='M'?key.replace('A', ''):key);
            bodyRow.add(setCell(displayKey, null, null, false, false));
            if (bu=='M'){
                for (String name3 : headerKeys.keySet()) {
                    Set<String> name4Set = headerKeys.get(name3);
                    //データ設定
                    for (String name4:name4Set) {
                        String dataKey = name3 + name4 + key;
                        PricingTable__c cellData = chassisMap.get(dataKey);
                        if (cellData!=null) {
                            //チェックボックス
                            Decimal price =  (cellData.Price__c==null?0:cellData.Price__c);
                            //価格
                            bodyRow.add(setCell(price.format(), null, null, false, true));
                            // 名称1～7を半角スペースで連結して表示
                            String name = cellData.Name1__c
                                        + (String.isNotBlank(cellData.Name2__c)?' ' + cellData.Name2__c:'')
                                        + (String.isNotBlank(cellData.Name3__c)?' ' + cellData.Name3__c:'')
                                        + (String.isNotBlank(cellData.Name4__c)?' ' + cellData.Name4__c:'')
                                        + (String.isNotBlank(cellData.Name5__c)?' ' + cellData.Name5__c:'');
                            Map<String,Object> cellItem = new Map<String,Object>();
                            cellItem.put('Id',cellData.Id);//Id
                            cellItem.put('Price__c',price);//単価
                            cellItem.put('Name1__c',name);//仕様
        
                            //既存データの設定
                            if (currentDetail!=null && currentDetail.PricingTableUniqueKey__c == cellData.UniqueKey__c){
                                info.inputedId = cellData.Id;//チェックされた値
                                info.inputedPrice = price;//単価
                                info.displayCondition = name;//選択仕様
                                cellItem.put('isChecked',true);
                            }else {
                                cellItem.put('isChecked',false);
                            }
                            
                            bodyRow.add(setCell(cellItem,null,null,true,false));//入力セル
                        }else {
                            //価格
                            bodyRow.add(setCell('―',null,null,false,true));//価格セル
                            //チェックボックス
                            bodyRow.add(setCell(null,null,null,false,false));//空白
                        }

                    }
                }
            }else if (bu=='S'){
                PricingTable__c cellData = chassisMap.get(key);
                if (cellData!=null) {
                    //チェックボックス
                    Decimal price =  (cellData.Price__c==null?0:cellData.Price__c);
                    //価格
                    bodyRow.add(setCell(price.format(), null, null, false, false));
                    // 名称1～7を半角スペースで連結して表示
                    String name = cellData.Name1__c
                                + (String.isNotBlank(cellData.Name2__c)?' ' + cellData.Name2__c:'')
                                + (String.isNotBlank(cellData.Name3__c)?' ' + cellData.Name3__c:'')
                                + (String.isNotBlank(cellData.Name4__c)?' ' + cellData.Name4__c:'')
                                + (String.isNotBlank(cellData.Name5__c)?' ' + cellData.Name5__c:'');
                    Map<String,Object> cellItem = new Map<String,Object>();
                    cellItem.put('Id',cellData.Id);//Id
                    cellItem.put('Price__c',price);//単価
                    cellItem.put('Name1__c',name);//仕様

                    //既存データの設定
                    if (currentDetail!=null  && currentDetail.PricingTableUniqueKey__c == cellData.UniqueKey__c){
                        info.inputedId = cellData.Id;//チェックされた値
                        info.inputedPrice = price;//単価
                        info.displayCondition = name;//選択仕様
                        cellItem.put('isChecked',true);
                    }else {
                        cellItem.put('isChecked',false);
                    }
                    
                    bodyRow.add(setCell(cellItem,null,null,true,false));//入力セル
                }else {
                    //価格
                    bodyRow.add(setCell('―',null,null,false,true));//価格セル
                    //チェックボックス
                    bodyRow.add(setCell(null,null,null,false,false));//空白
                }
            }
            BodyRow row = new BodyRow();
            row.cellList = bodyRow;
            bodyList.add(row);
        }
        info.bodyList = bodyList;

        //ACB加算
        // ・見積.レコードタイプ＝”施設"の場合、この表は表示しない
        if (bu=='M') { 
            info.acbSumTable = setAcbSumTable(chassisList, detailsMap);
        }else if (bu=='S') {
            // 零相変流器+地絡過電融継電器(ZCT+51G)	
            info.zctTable  = setZctTable(chassisList, detailsMap);
            // 計器用変圧器VT,PT(低圧）引出型	
            info.transformerDrawerTable  = setTransformerDrawerTable(chassisList, detailsMap);
            // 計器用変流器 ＣＴ(低圧)	
            info.transformerCtTable  = setTransformerCtTable(chassisList, detailsMap);
            // ACB　（エアーサーキットブレーカ）	
            info.acbTable  = setAcbTable(chassisList, detailsMap);
            // プロテクタヒューズ	
            info.protectorFuseTable  = setProtectorFuseTable(chassisList, detailsMap);
            // テイクオフヒューズ	
            info.takeoffFuseTable  = setTakeoffFuseTable(chassisList, detailsMap);
            // ネットワークリレー（multicap)	
            info.networkRelayTable  = setNetworkRelayTable(chassisList, detailsMap);
            // 合成CT（低圧）	
            info.mixedTable  = setMixedTable(chassisList, detailsMap);
            // ネットワークVT（低圧）	
            info.networkVtTable  = setNetworkVtTable(chassisList, detailsMap);
            // ネットワークCT（低圧）	
            info.networkCtTable  = setNetworkCtTable(chassisList, detailsMap);
            // 配線用遮断器価格 （MCCB・ELB）
            List<CustomTable> tbls = setMccbTable(chassisList, detailsMap);	
            if(tbls!=null&&tbls.size()>0)info.mccbTable = tbls.get(0);
            if(tbls!=null&&tbls.size()>1)info.mccbTableHas = tbls.get(1);
            // info.mccbTable  = setMccbTable(chassisList, detailsMap);

            // 取付器具類	
            info.installEquipTypeTable  = setInstallEquipTypeTable(chassisList, detailsMap);
        }
        return JSON.serialize(info);
    }

    @AuraEnabled(Cacheable=false)
    /**
     * 明細入力B(明細入力B_ACB盤) 表示データを取得
     * 
     * @param deviceId 見積項目Id
     * @param recordId 筐体ID
     * @param strOptRecords 明細情報リスト
     * 
     */
    Public static String submitDetailsForAcbBoard(String deviceId,
                                                    String recordId,
                                                    String strOptRecords){
        System.debug(deviceId);
        System.debug(recordId);
        System.debug(strOptRecords);
        try{
            List<Detail__c> dtList = [SELECT Id
                                        FROM Detail__c
                                        WHERE Device__c=:deviceId
                                        AND ((DetailCategory__c='筐体'
                                                AND MajorClassificationName__c IN ('低圧・現場・リレー・ACB盤')
                                                AND MinorClassificationName__c IN ('ACB盤')
                                            )
                                            OR(DetailCategory__c='明細'
                                                AND (MajorClassificationName__c = '共通機器'
                                                    OR (MajorClassificationName__c='低圧・現場・リレー・ACB盤'
                                                        AND MinorClassificationName__c = 'ACB盤')
                                                    )
                                            )
                                        )];
            if (dtList != null && dtList.size()>0) delete dtList;//既存のデータを削除
            //付属品情報
            List<QuantityObject> optRecords;
            if(String.isNotBlank(strOptRecords)){
                optRecords = (List<QuantityObject>)JSON.deserialize(strOptRecords,List<QuantityObject>.class);
            }
            //チェックボックス（筐体）のId
            List<String> condiList = new List<String>{recordId};
            //付属品のId
            if (optRecords!=null && optRecords.size()>0) {
                for(QuantityObject opt : optRecords) {
                    if (opt.Quantity != null && opt.Quantity > 0) condiList.add(opt.Id);
                }
            }

            //登録用　価格表データ
            Map<String,PricingTable__c> priceMap = getPriceTableForInsert(condiList);
            //登録用　筐体を作成
            List<Detail__c> insList = new List<Detail__c>();
            PricingTable__c chassis = priceMap.get(recordId);
            if (chassis!=null){
                Detail__c detail = new Detail__c();
                // 見積項目_Device__c_明細入力画面を開いた見積項目.ID
                detail.Device__c = deviceId;
                // 名称1_Name1__c_価格表.名称1
                // 名称2_Name2__c_価格表.名称2
                // 名称3_Name3__c_価格表.名称3
                // 名称4_Name4__c_価格表.名称4
                detail.Name1__c = chassis.Name1__c;//名称１
                detail.Name2__c = chassis.Name2__c;//名称2
                detail.Name3__c = chassis.Name3__c;//名称3
                detail.Name4__c = chassis.Name4__c;//名称4
                // 価格表ユニークキー_PricingTableUniqueKey__c_価格表.ユニークキー
                detail.PricingTableUniqueKey__c = chassis.UniqueKey__c;
                // WC単価_CreditWC__c_価格表.WC単価
                detail.CreditWC__c = chassis.WC__c;
                // WC係数_WcCoefficient__c_""
                detail.WcCoefficient__c = null;
                // 単価_UnitPrice__c_価格表.単価
                detail.UnitPrice__c = chassis.Price__c;
                // 単価係数_"UnitPriceCoefficient__c_"_""
                detail.UnitPriceCoefficient__c = null;
                // 単位重量_CreditWeight__c_価格表.単位重量
                detail.CreditWeight__c = chassis.Weight__c;
                // 明細種別_DetailCategory__c_"⑥の表でチェックした筐体を保存する場合：""筐体""
                detail.DetailCategory__c='筐体';//"筐体" "明細"
                // 提供単価_ProvisionUnitPrice__c_""
                detail.ProvisionUnitPrice__c = null;
                // 数量_Quantity__c_"画面に入力された値。（✓の場合は「1」）
                detail.Quantity__c = 1;
                // WC算出レート_WcCalculationRate__c_"⑥の表でチェックした筐体を保存する場合：0
                detail.WcCalculationRate__c = 0;
                // 備考_Note__c_価格表.備考
                detail.Note__c = chassis.Note__c;
                // 表示用テキスト_Name_価格表.表示用テキスト
                detail.Name = chassis.DisplayName__c;//表示用テキスト
                // 名称5_Name5__c_価格表.名称5
                // 名称6_Name6__c_価格表.名称6
                // 名称7_Name7__c_価格表.名称7
                // 名称8_Name8__c_価格表.名称8
                // 名称9_Name9__c_価格表.名称9
                // 名称10_Name10__c_価格表.名称10
                detail.Name5__c = chassis.Name5__c;//名称5
                detail.Name6__c = chassis.Name6__c;//名称6
                detail.Name7__c = chassis.Name7__c;//名称7
                detail.Name8__c = chassis.Name8__c;//名称8
                detail.Name9__c = chassis.Name9__c;//名称9
                detail.Name10__c = chassis.Name10__c;//名称10
                // 内訳書出力用テキスト_detailedStatementText__c_価格表.内訳書出力用テキスト
                detail.detailedStatementText__c	= chassis.detailedStatementText__c;//価格表.内訳書出力用テキスト
                // 特殊仕様No_SpecialSpecificationNo__c_価格表.特殊仕様No
                detail.SpecialSpecificationNo__c= chassis.SpecialSpecificationNo__c;//価格表.特殊仕様No
                // 大分類名_MajorClassificationName__c_価格表.大分類名
                // 大分類コード_MajorClassificationCode__c_価格表.大分類コード
                // 小分類名_MinorClassificationName__c_価格表.小分類名
                // 小分類コード_MinorClassificationCode__c_価格表.小分類コード
                detail.MajorClassificationName__c = chassis.MajorClassificationName__c;//大分類名
                detail.MajorClassificationCode__c = chassis.MajorClassificationCode__c;//大分類コード
                detail.MinorClassificationName__c = chassis.MinorClassificationName__c;//小分類名
                detail.MinorClassificationCode__c = chassis.MinorClassificationCode__c;//小分類コード
                // 種類名_"CategoryName__c_"_価格表.種類名
                // 種類コード_"CategoryCode__c_"_価格表.種類コード
                detail.CategoryName__c = chassis.CategoryName__c;//種類名
                detail.CategoryCode__c = chassis.CategoryCode__c;//種類コード
                // RECNO_RECNO__c_価格表.RECNO
                detail.RECNO__c = chassis.RECNO__c;//RECNO
                detail.MasterCode__c = chassis.MasterCode__c;//マスタコード
                detail.DetailRecordDisplayNumberText__c = chassis.DetailRecordDisplayNumberText__c;//明細レコード表示順
                insList.add(detail);
            }
            //登録用　付属品を作成 
            if (optRecords!=null && optRecords.size()>0) {
                for(QuantityObject opt : optRecords) {
                    if (opt.Quantity != null && opt.Quantity > 0) {
                        Detail__c optObj = new Detail__c();
                        PricingTable__c optDetail = priceMap.get(opt.Id);

                        // 見積項目_Device__c_明細入力画面を開いた見積項目.ID
                        optObj.Device__c = deviceId;
                        // 名称1_Name1__c_価格表.名称1
                        // 名称2_Name2__c_価格表.名称2
                        // 名称3_Name3__c_価格表.名称3
                        // 名称4_Name4__c_価格表.名称4
                        optObj.Name1__c = optDetail.Name1__c;//価格表.名称1
                        optObj.Name2__c =  optDetail.Name2__c;//価格表.名称2
                        optObj.Name3__c = optDetail.Name3__c;//価格表.名称3
                        optObj.Name4__c = optDetail.Name4__c;//価格表.名称4
                        // 価格表ユニークキー_PricingTableUniqueKey__c_価格表.ユニークキー
                        optObj.PricingTableUniqueKey__c = optDetail.UniqueKey__c;
                        // WC単価_CreditWC__c_価格表.WC単価
                        optObj.CreditWC__c = optDetail.WC__c;
                        // WC係数_WcCoefficient__c_""
                        optObj.WcCoefficient__c = null;
                        // 単価_UnitPrice__c_価格表.単価
                        optObj.UnitPrice__c = optDetail.Price__c;//価格表.単価
                        // 単価係数_"UnitPriceCoefficient__c_"_""
                        optObj.UnitPriceCoefficient__c = null;
                        // 単位重量_CreditWeight__c_価格表.単位重量
                        optObj.CreditWeight__c = optDetail.Weight__c;
                        // 明細種別_DetailCategory__c_"⑥の表でチェックした筐体を保存する場合：""筐体""
                        // それ以外の表で数量を入力した明細を保存する場合：""明細"""
                        optObj.DetailCategory__c='明細';//"筐体" "明細"
                        // 提供単価_ProvisionUnitPrice__c_""
                        optObj.ProvisionUnitPrice__c = null;
                        // 数量_Quantity__c_"画面に入力された値。（✓の場合は「1」）
                        // 0or空欄で入力された場合その明細のデータは作成されず、既存データがある場合は物理削除する"
                        optObj.Quantity__c = opt.Quantity;//画面　の数量
                        // WC算出レート_WcCalculationRate__c_"⑥の表でチェックした筐体を保存する場合：0
                        // それ以外の表で数量を入力した明細を保存する場合：価格表.WC算出レート"
                        optObj.WcCalculationRate__c = optDetail.WcCalculationRate__c;//価格表.WC算出レート
                        // 備考_Note__c_価格表.備考
                        optObj.Note__c = optDetail.Note__c;
                        // 表示用テキスト_Name_価格表.表示用テキスト
                        optObj.Name = optDetail.DisplayName__c;
                        // 名称5_Name5__c_価格表.名称5
                        // 名称6_Name6__c_価格表.名称6
                        // 名称7_Name7__c_価格表.名称7
                        // 名称8_Name8__c_価格表.名称8
                        // 名称9_Name9__c_価格表.名称9
                        // 名称10_Name10__c_価格表.名称10
                        optObj.Name5__c = optDetail.Name5__c;//価格表.名称5
                        optObj.Name6__c = optDetail.Name6__c;//価格表.名称6
                        optObj.Name7__c = optDetail.Name7__c;//価格表.名称7
                        optObj.Name8__c = optDetail.Name8__c;//価格表.名称8
                        optObj.Name9__c = optDetail.Name9__c;//価格表.名称9
                        optObj.Name10__c = optDetail.Name10__c;//価格表.名称10
                        // 内訳書出力用テキスト_detailedStatementText__c_価格表.内訳書出力用テキスト
                        optObj.detailedStatementText__c	= optDetail.detailedStatementText__c;//価格表.内訳書出力用テキスト
                        // 特殊仕様No_SpecialSpecificationNo__c_価格表.特殊仕様No
                        optObj.SpecialSpecificationNo__c= optDetail.SpecialSpecificationNo__c;//価格表.特殊仕様No
                        // 大分類名_MajorClassificationName__c_価格表.大分類名
                        // 大分類コード_MajorClassificationCode__c_価格表.大分類コード
                        // 小分類名_MinorClassificationName__c_価格表.小分類名
                        // 小分類コード_MinorClassificationCode__c_価格表.小分類コード
                        optObj.MajorClassificationName__c = optDetail.MajorClassificationName__c;//大分類名
                        optObj.MajorClassificationCode__c = optDetail.MajorClassificationCode__c;//大分類コード
                        optObj.MinorClassificationName__c = optDetail.MinorClassificationName__c;//小分類名
                        optObj.MinorClassificationCode__c = optDetail.MinorClassificationCode__c;//小分類コード
                        // 種類名_"CategoryName__c_"_価格表.種類名
                        // 種類コード_"CategoryCode__c_"_価格表.種類コード
                        optObj.CategoryName__c = optDetail.CategoryName__c;//種類名
                        optObj.CategoryCode__c = optDetail.CategoryCode__c;//種類コード
                        // RECNO_RECNO__c_価格表.RECNO
                        optObj.RECNO__c = optDetail.RECNO__c;//RECNO
                        optObj.MasterCode__c = optDetail.MasterCode__c;//マスタコード
                        optObj.DetailRecordDisplayNumberText__c = optDetail.DetailRecordDisplayNumberText__c;//明細レコード表示順
                        insList.add(optObj);
                    }
                }
            }

            //DB登録行う
            if (insList.size() > 0) insert insList;
            //見積項目情報を取得
            List<Device__c> deviceList = DeviceController.getDevice(deviceId);
            return deviceList.get(0).Quote__c;
        }catch(Exception ex) {
            System.debug('An Exception: '+ex);
            return 'error';
        }
    }

    /**
     *登録用　価格表データを取得
     *
     * @param ids 価格表のId情報（筐体、と　付属品）
     */
    private static Map<String,PricingTable__c> getPriceTableForInsert(List<String> ids){
        Map<String,PricingTable__c> rtnMap = new Map<String,PricingTable__c>();
        //検索条件なし
        if (ids==null || ids.size()==0) return rtnMap;
        //登録用　価格表データ
        List<PricingTable__c> chassis = [SELECT Id, Name, RECNo__c,
                            MajorClassificationCode__c, 
                            MajorClassificationName__c, 
                            MinorClassificationCode__c, 
                            MinorClassificationName__c, 
                            CategoryCode__c,CategoryName__c,WcCalculationRate__c,
                            Name1__c, Name2__c,Name3__c,Name4__c,Name5__c,
                            Name6__c, Name7__c,Name8__c,Name9__c,Name10__c,
                            WC__c, Price__c, UniqueKey__c,ConditionForSearchformula__c,
                            Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                            Note__c,MasterCode__c,DetailRecordDisplayNumberText__c
                        FROM PricingTable__c
                        WHERE Id =:ids
                    ];
        for(PricingTable__c tmp : chassis){
            rtnMap.put(tmp.Id,tmp);
        }
        return rtnMap;
    }



    //  取付器具類
    private static CustomTable setInstallEquipTypeTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // 取付器具類
        Map<String, PricingTable__c> installEquipTypeMap = new Map<String, PricingTable__c>();
        // Map<String, Set<String>> keysMap = new Map<String, Set<String>>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、ACB盤B画面用RECNOがnull以外
            if(tmp.RecordType.DeveloperName == 'Detail' 
                && tmp.MajorClassificationName__c=='共通機器'
                && tmp.RECNOforACBBoardB_Attachment__c != null) {
                installEquipTypeMap.put(tmp.DisplayName__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定 取付器具類
        table.secTitle = '取付器具類';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (installEquipTypeMap.size() == 0) return table;

        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('機 器 名');
        //ボディー情報設定
        table.bodyList=setBodyListCommon(installEquipTypeMap, detailsMap);

        return table;
    }
    
    //ヘッダー情報設定
    private static List<BodyRow> setHeaderListCommon(String col){
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報

        //１行目のヘッダー設定   
        List<BodyCell> headerRow = new List<BodyCell>();  
        headerRow.add(setCell(col, null, null,false,false));//1列目
        headerRow.add(setCell('価格', null, null,false,false));//単価
        headerRow.add(setCell('数量', null, null,false,false));//数量
        BodyRow hBodyRow = new BodyRow();
        hBodyRow.cellList = headerRow;
        headerList.add(hBodyRow);
        return headerList;
    }

    //ボディー情報設定
    private static List<BodyRow> setBodyListCommon(Map<String, PricingTable__c> commonMap, Map<String, Detail__c> detailsMap){
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報
        //ボディー情報設定
        for(String key : commonMap.keySet()){
            //一行のデータ
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow = new List<BodyCell>();

            PricingTable__c price = commonMap.get(key);
            bodyRow.add(setCell(key, null, null, false, false));//一列目

            if (price != null) {
                Decimal decPrice = (price.Price__c==null?0:price.Price__c);
                bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                bodyRow.add(setCell(getQuantityObject(price, detailsMap), null, null, true, false));//数量
            } else {
                bodyRow.add(setCell('―',null,null,false,true));//価格セル
                bodyRow.add(setCell('',null,null,false,false));//空白
            }
            row.cellList = bodyRow;
            bodyList.add(row);
        }
        return bodyList;
    }


    //配線用遮断器価格 （MCCB・ELB）
    private static List<CustomTable> setMccbTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){

        //配線用遮断器価格 （MCCB・ELB）Map
        Map<String, PricingTable__c> detailMap = new Map<String, PricingTable__c>();
        //処理対象 キーを設定
        //Map<名称４, Set<名称３>>
        Map<String,Set<Integer>> name4Map = new Map<String,Set<Integer>>{
            'MCCB電動操作なし'=>new Set<Integer>(),
            'MCCB電動操作あり'=>new Set<Integer>()
        };//先頭２列
 
        for(PricingTable__c tmp : chassisList) {

            // レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「配線用遮断器」を含む
            if (!(tmp.RecordType.DeveloperName == 'Detail' 
                && tmp.MajorClassificationName__c == '共通機器' 
                && tmp.Name1__c.contains('配線用遮断器'))) continue;//処理しない

            if (String.isBlank(tmp.Name2__c) || String.isBlank(tmp.Name3__c)) continue;//処理しない
            //データのキー
            String key = '';
            //4P、3P、2P
            if (tmp.Name2__c.contains('4P')) key += '4P';
            if (tmp.Name2__c.contains('3P')) key += '3P';
            if (tmp.Name2__c.contains('2P')) key += '2P';
            //MCCB(A価格)の方に名称2「MCCB」を含むものを表示し、MCCB(B価格)・ELBの方に名称2「ELB」を含むものを表示する
            if (tmp.Name2__c.contains('MCCB')) key += 'A価格';
            if (tmp.Name2__c.contains('ELB')) key += 'B価格';
        
            //AF
            Integer af = Integer.valueOf(tmp.Name3__c.replace('AF','').replace(',',''));
            key += String.valueOf(af);
            // MCCB電動操作なし / MCCB電動操作あり
            if (String.isNotBlank(tmp.Name4__c) && tmp.Name4__c.contains('電動')) {
                name4Map.get('MCCB電動操作あり').add(af);
                key += 'MCCB電動操作あり';
            }else {
                name4Map.get('MCCB電動操作なし').add(af);
                key += 'MCCB電動操作なし';
            }
            //key例：4PA価格30MCCB電動操作なし
            detailMap.put(key,tmp);
        }

        List<CustomTable> tables = new List<CustomTable>();

        CustomTable table = new CustomTable();
        CustomTable tableHas = new CustomTable();//配線用遮断器価格 （MCCB・ELB）_MCCB電動操作あり
        //タイトル設定　配線用遮断器価格 （MCCB・ELB）
        table.secTitle = '配線用遮断器価格 （MCCB・ELB）電動操作なし';
        tableHas.secTitle = '配線用遮断器価格 （MCCB・ELB）電動操作あり';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        // if (detailMap.size() == 0) return table;
        if (detailMap==null || detailMap.size() == 0) {
            tables.add(table);
            tables.add(tableHas);
            return tables;
        }

        //ヘッダ行情報 設定
        table.headerList = setMccbTableHeader();
        tableHas.headerList = setMccbTableHeader();

        //ボディー情報 設定
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報
        //表示順番を確保
        List<String> keys = new List<String>{
            '4P' + 'A価格',
            '4P' + 'B価格',
            '3P' + 'A価格',
            '3P' + 'B価格',
            '2P' + 'A価格',
            '2P' + 'B価格'
        };
        for (String key : name4Map.keyset()) {
            Set<Integer> name3Set = name4Map.get(key);
            //Hデータ
            List<Integer> name3Lst = new List<Integer>(name3Set);
            name3Lst.sort();
            //MCCB電動操作 セルであるかどうか
            Boolean isFirst = true;
            // af 
            for (Integer name3 : name3Lst) {

                BodyRow row = new BodyRow();
                List<BodyCell> bodyRow  = new List<BodyCell>();
                //１回のみ設定
                // if (isFirst) {
                //     bodyRow.add(setCell(key, null, name3Lst.size(), false, false));
                //     isFirst = false;
                // } 
                // else{
                //     bodyRow.add(setCell(null, null, null, false, false));
                // } 
                bodyRow.add(setCell(name3.format(), null, null, false, true));
                //以下のセルを設定
                //4P A価格
                //4P B価格
                //3P A価格
                //3P B価格
                //2P A価格
                //2P B価格
                for (String pkey : keys) {
                    PricingTable__c price = detailMap.get(pkey + String.valueOf(name3) + key);
                    if (price != null) {
                        Decimal decPrice = (price.Price__c==null?0:price.Price__c);
                        bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                        bodyRow.add(setCell(getQuantityObject(price, detailsMap), null, null, true, false));//数量
                    } else {
                        bodyRow.add(setCell('―',null,null,false,true));//価格セル
                        bodyRow.add(setCell('　',null,null,false,false));//空白
                    }
                }
                row.cellList = bodyRow;
                bodyList.add(row);
            }
            if (key=='MCCB電動操作あり') {
                tableHas.bodyList = bodyList;
                bodyList = new List<BodyRow>();//ボディー行情報
            }else if (key=='MCCB電動操作なし') {
                table.bodyList = bodyList;
                bodyList = new List<BodyRow>();//ボディー行情報
            }
        }
        // table.bodyList = bodyList;
        //注＊　の設定
        List<String> noteList = System.Label.Annotation_BreakerForWiring.split('\r\n');
        table.noteList = noteList;
        tableHas.noteList = noteList;

        tables.add(table);
        tables.add(tableHas);
        return tables;
    }

    //ヘッダー設定（配線用遮断器価格 （MCCB・ELB））
    private static List<BodyRow> setMccbTableHeader(){
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        //ヘッダ　設定
        //１行目のヘッダー設定   
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        // headerRow1.add(setCell('　', null, 3,false,false));//電動操作
        headerRow1.add(setCell('AF', null, 3,false,false));//AF
        headerRow1.add(setCell('４P', 4, null,false,false));//４P
        headerRow1.add(setCell(null, null, null,false,false));//４P非表示セル
        headerRow1.add(setCell(null, null, null,false,false));//４P非表示セル
        headerRow1.add(setCell(null, null, null,false,false));//４P非表示セル
        headerRow1.add(setCell('３P ', 4, null,false,false));//３P
        headerRow1.add(setCell(null, null, null,false,false));//３P非表示セル
        headerRow1.add(setCell(null, null, null,false,false));//３P非表示セル
        headerRow1.add(setCell(null, null, null,false,false));//３P非表示セル
        headerRow1.add(setCell('２P ', 4, null,false,false));//２P
        headerRow1.add(setCell(null, null, null,false,false));//２P非表示セル
        headerRow1.add(setCell(null, null, null,false,false));//２P非表示セル
        headerRow1.add(setCell(null, null, null,false,false));//２P非表示セル
        BodyRow hBodyRow1 = new BodyRow();
        hBodyRow1.cellList = headerRow1;
        headerList.add(hBodyRow1);

        //２行目のヘッダー設定   
        List<BodyCell> headerRow2 = new List<BodyCell>();
        // headerRow2.add(setCell(null, null, null,false,false));//電動操作非表示セル
        headerRow2.add(setCell(null, null, null,false,false));//AF非表示セル
        //３回設定を行う
        //４P⇒３P⇒２P
        for (Integer i=1;i<=3;i++) {
            headerRow2.add(setCell('MCCB(A価格)', 2, null,false,false));//MCCB(A価格)
            headerRow2.add(setCell(null, null, null,false,false));//MCCB(A価格)非表示セル
            headerRow2.add(setCell('MCCB(B価格)・ELB', 2, null,false,false));//MCCB(B価格)・ELB
            headerRow2.add(setCell(null, null, null,false,false));//MCCB(B価格)・ELB非表示セル
        }
        BodyRow hBodyRow2 = new BodyRow();
        hBodyRow2.cellList = headerRow2;
        headerList.add(hBodyRow2);

        //3行目のヘッダー設定   
        List<BodyCell> headerRow3 = new List<BodyCell>();
        // headerRow3.add(setCell(null, null, null,false,false));//電動操作非表示セル
        headerRow3.add(setCell(null, null, null,false,false));//AF非表示セル
        //6回設定を行う
        //４P⇒３P⇒２P
        for (Integer i=1;i<=6;i++) {
            headerRow3.add(setCell('価格', null, null,false,false));//価格
            headerRow3.add(setCell('数量', null, null,false,false));//数量
        }
        BodyRow hBodyRow3 = new BodyRow();
        hBodyRow3.cellList = headerRow3;
        headerList.add(hBodyRow3);
        return headerList;
    }

   //  ネットワークCT（低圧）
   private static CustomTable setNetworkCtTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // ネットワークCT（低圧）
        Map<String, PricingTable__c> networkCtMap = new Map<String, PricingTable__c>();
        // Map<String, Set<String>> keysMap = new Map<String, Set<String>>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「ネットワークCT(低圧)」
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='ネットワークCT(低圧)') {
                networkCtMap.put(tmp.Name2__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定 ネットワークCT（低圧）
        table.secTitle = 'ネットワークCT（低圧）';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (networkCtMap.size() == 0) return table;
        
        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('機器構成');
        //ボディー情報設定
        table.bodyList=setBodyListCommon(networkCtMap, detailsMap);

        return table;
    }

   //  ネットワークVT（低圧）
   private static CustomTable setNetworkVtTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // ネットワークVT（低圧）
        Map<String, PricingTable__c> networkVtMap = new Map<String, PricingTable__c>();
        // Map<String, Set<String>> keysMap = new Map<String, Set<String>>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「ネットワークVT(低圧)」
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='ネットワークVT(低圧)') {
                networkVtMap.put(tmp.Name2__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　ネットワークVT（低圧）
        table.secTitle = 'ネットワークVT（低圧）';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (networkVtMap.size() == 0) return table;

        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('機器構成');
        //ボディー情報設定
        table.bodyList=setBodyListCommon(networkVtMap, detailsMap);

        return table;
    }
    //  合成CT（低圧）	
    private static CustomTable setMixedTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // 合成CT（低圧）	
        Map<String, PricingTable__c> mixedMap = new Map<String, PricingTable__c>();
        // Map<String, Set<String>> keysMap = new Map<String, Set<String>>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「合成CT(低圧)」
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='合成CT(低圧)') {
                mixedMap.put(tmp.Name2__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　合成CT（低圧）
        table.secTitle = '合成CT（低圧）';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (mixedMap.size() == 0) return table;

        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('定格電流');
        //ボディー情報設定
        table.bodyList=setBodyListCommon(mixedMap, detailsMap);

        return table;
    }

    // ネットワークリレー（multicap	
    private static CustomTable setNetworkRelayTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // ネットワークリレー（multicap	
        Map<String, PricingTable__c> networkRelayMap = new Map<String, PricingTable__c>();
        // Map<String, Set<String>> keysMap = new Map<String, Set<String>>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「ネットワークリレー」
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='ネットワークリレー') {
                networkRelayMap.put(tmp.Name2__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　ネットワークリレー（multicap)
        table.secTitle = 'ネットワークリレー（multicap)';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (networkRelayMap.size() == 0) return table;

        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('用途');

        //ボディー情報設定
        table.bodyList=setBodyListCommon(networkRelayMap, detailsMap);

        return table;
    }

    // テイクオフヒューズ	
    private static CustomTable setTakeoffFuseTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // テイクオフヒューズ	
        Map<String, PricingTable__c> takeoffFuseMap = new Map<String, PricingTable__c>();
        // Map<String, Set<String>> keysMap = new Map<String, Set<String>>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「テイクオフヒューズ」
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='テイクオフヒューズ') {
                takeoffFuseMap.put(tmp.Name2__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　テイクオフヒューズ
        table.secTitle = 'テイクオフヒューズ';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (takeoffFuseMap.size() == 0) return table;

        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('定格電流');
        //ボディー情報設定
        table.bodyList=setBodyListCommon(takeoffFuseMap, detailsMap);

        return table;
    }

    // プロテクタヒューズ	
    private static CustomTable setProtectorFuseTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // プロテクタヒューズ	
        Map<String, PricingTable__c> protectorFuseMap = new Map<String, PricingTable__c>();
        // Map<String, Set<String>> keysMap = new Map<String, Set<String>>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「プロテクタヒューズ」
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='プロテクタヒューズ') {
                protectorFuseMap.put(tmp.Name2__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　プロテクタヒューズ
        table.secTitle = 'プロテクタヒューズ';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (protectorFuseMap.size() == 0) return table;
        
        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('定格電流');
        //ボディー情報設定
        table.bodyList=setBodyListCommon(protectorFuseMap, detailsMap);

        return table;
    }
    // ACB　（エアーサーキットブレーカ）
    private static CustomTable setAcbTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // ACB　（エアーサーキットブレーカ）
        Map<String, PricingTable__c> acbMap = new Map<String, PricingTable__c>();
        Set<String> keysSet = new Set<String>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「ACB盤」
            if(tmp.RecordType.DeveloperName == 'Detail' 
                && tmp.MajorClassificationName__c=='低圧・現場・リレー・ACB盤'
                && tmp.MinorClassificationName__c=='ACB盤') {
                //データのキー
                String key = tmp.Name2__c;
                keysSet.add(tmp.Name2__c);
                //3P、2P
                if (tmp.Name3__c.contains('4P')) key += '4P';
                if (tmp.Name3__c.contains('3P')) key += '3P';
                acbMap.put(key,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　ACB　（エアーサーキットブレーカ）
        table.secTitle = 'ACB　（エアーサーキットブレーカ）';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (acbMap.size() == 0) return table;
        
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報
        
        //１行目のヘッダー設定   
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell(new List<String>{'ﾌﾚｰﾑ(A)','極数'}, null, null,true,false));//極数
        headerRow1.add(setCell('3P', null, null,false,false));//3P
        headerRow1.add(setCell('数量', null, null,false,false));//数量
        headerRow1.add(setCell('4P', null, null,false,false));//4P
        headerRow1.add(setCell('数量', null, null,false,false));//数量
        BodyRow hBodyRow1 = new BodyRow();
        hBodyRow1.cellList = headerRow1;
        headerList.add(hBodyRow1);
        table.headerList = headerList;

        for(String key : keysSet){
            //一行のデータ
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow = new List<BodyCell>();

            bodyRow.add(setCell(key.replace('フレーム(A)', ''), null, null, false, false));//極数

            //3P
            PricingTable__c price3P = acbMap.get(key+'3P');
            if (price3P != null) {
                Decimal decPrice = (price3P.Price__c==null?0:price3P.Price__c);
                bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                bodyRow.add(setCell(getQuantityObject(price3P, detailsMap), null, null, true, false));//数量
            } else {
                bodyRow.add(setCell('―',null,null,false,true));//価格セル
                bodyRow.add(setCell('',null,null,false,false));//空白
            }
             //4P
             PricingTable__c price4P = acbMap.get(key+'4P');
             if (price4P != null) {
                 Decimal decPrice = (price4P.Price__c==null?0:price4P.Price__c);
                 bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                 bodyRow.add(setCell(getQuantityObject(price4P, detailsMap), null, null, true, false));//数量
             } else {
                 bodyRow.add(setCell('―',null,null,false,true));//価格セル
                 bodyRow.add(setCell('',null,null,false,false));//空白
             }
            row.cellList = bodyRow;
            bodyList.add(row);
        }
        table.bodyList=bodyList;
        //注
        table.noteList = System.Label.Annotation_ACBFacility.split('\r\n');

        return table;
    }

    // 計器用変流器 ＣＴ(低圧)
    private static CustomTable setTransformerCtTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // 計器用変流器 ＣＴ(低圧)
        Map<String, PricingTable__c> transformerCtMap = new Map<String, PricingTable__c>();
        Map<String, Set<String>> keysMap = new Map<String, Set<String>>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「計器用変流器」
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='計器用変流器') {
                transformerCtMap.put(tmp.Name4__c+tmp.Name3__c,tmp);
                Set<String> name3Set=keysMap.get(tmp.Name4__c);
                if (name3Set == null || name3Set.size()==0) name3Set=new Set<String>();
                name3Set.add(tmp.Name3__c);
                keysMap.put(tmp.Name4__c, name3Set);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　計器用変流器 ＣＴ(低圧)
        table.secTitle = '計器用変流器 ＣＴ(低圧)';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (transformerCtMap.size() == 0) return table;
        
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報
        
        //１行目のヘッダー設定   
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('定格電流', 2, null,false,false));//電圧
        headerRow1.add(setCell('価格', null, 2,false,false));//単価
        headerRow1.add(setCell('数量', null, 2,false,false));//数量
        BodyRow hBodyRow1 = new BodyRow();
        hBodyRow1.cellList = headerRow1;
        headerList.add(hBodyRow1);

        //2行目のヘッダー設定   
        List<BodyCell> headerRow2 = new List<BodyCell>();  
        headerRow2.add(setCell('一次', null, null,false,false));//一次
        headerRow2.add(setCell('二次', null, null,false,false));//二次
        BodyRow hBodyRow2 = new BodyRow();
        hBodyRow2.cellList = headerRow2;
        headerList.add(hBodyRow2);
        table.headerList = headerList;

        for(String name4 : keysMap.keySet()){
            
            Set<String> name3Set=keysMap.get(name4);
            Boolean isFirst = true;
            for (String name3 : name3Set) {
                //一行のデータ
                BodyRow row = new BodyRow();
                List<BodyCell> bodyRow = new List<BodyCell>();

                PricingTable__c price = transformerCtMap.get(name4+name3);
                bodyRow.add(setCell(name3.replace('一次電流', ''), null, null, false, false));//一次
                if (isFirst) {
                    bodyRow.add(setCell(name4.replace('二次電流', ''), null, name3Set.size(), false, false));//二次
                    isFirst = false;
                }
                if (price != null) {
                    Decimal decPrice = (price.Price__c==null?0:price.Price__c);
                    bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                    bodyRow.add(setCell(getQuantityObject(price, detailsMap), null, null, true, false));//数量
                } else {
                    bodyRow.add(setCell('―',null,null,false,true));//価格セル
                    bodyRow.add(setCell('',null,null,false,false));//空白
                }
                row.cellList = bodyRow;
                bodyList.add(row);
            }
        }
        table.bodyList=bodyList;

        return table;
    }

    // 計器用変圧器VT,PT(低圧）引出型
    private static CustomTable setTransformerDrawerTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // 計器用変圧器VT,PT(低圧）引出型
        Map<String, PricingTable__c> transformerDrawerMap = new Map<String, PricingTable__c>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「計器用変圧器」、名称2「VT,PT 引出型」
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='計器用変圧器' && tmp.Name2__c=='VT,PT 引出型') {
                transformerDrawerMap.put(tmp.Name3__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　計器用変圧器VT,PT(低圧）引出型
        table.secTitle = '計器用変圧器VT,PT(低圧）引出型';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (transformerDrawerMap.size() == 0) return table;
        
        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('電圧');
        //ボディー情報設定
        table.bodyList=setBodyListCommon(transformerDrawerMap, detailsMap);

        return table;
    }


    // 零相変流器+地絡過電融継電器(ZCT+51G)	
    private static CustomTable setZctTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){
        // 零相変流器+地絡過電融継電器(ZCT+51G)
        Map<String, PricingTable__c> zctMap = new Map<String, PricingTable__c>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「零相変流器+地絡過電流継電器」かつ、名称3「低圧」
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='零相変流器+地絡過電流継電器' && tmp.Name3__c=='低圧') {
                zctMap.put(tmp.Name2__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　零相変流器+地絡過電融継電器(ZCT+51G)
        table.secTitle = '零相変流器+地絡過電融継電器(ZCT+51G)';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (zctMap.size() == 0) return table;
        
        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('品名');
        //ボディー情報設定
        table.bodyList=setBodyListCommon(zctMap, detailsMap);

        return table;
    }

    //ACB加算　表を設定
    private static CustomTable setAcbSumTable(List<PricingTable__c> chassisList, Map<String, Detail__c> detailsMap){

        // // ACB加算
        Map<String, PricingTable__c> acbSumMap = new Map<String, PricingTable__c>();
        //キー設定
        for(PricingTable__c tmp : chassisList){
            if(tmp.RecordType.DeveloperName == 'Detail' && tmp.Name1__c=='ACB加算') {
                acbSumMap.put(tmp.Name2__c,tmp);
            }
        }

        CustomTable table = new CustomTable();
        //タイトル設定　ACB加算
        table.secTitle = 'ACB加算';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (acbSumMap.size() == 0) return table;

        //ヘッダー情報設定
        table.headerList=setHeaderListCommon('AF');
        //ボディー情報設定
        table.bodyList=setBodyListCommon(acbSumMap, detailsMap);

        return table;
    }

   /**
     * 入力セルに登録データの設定
     * 
     * @param priceObj 価格表データ
     * @param detailMap 登録された明細データ
     */
    private static QuantityObject getQuantityObject(PricingTable__c priceObj, Map<String, Detail__c> detailMap){
        QuantityObject quantityObject = new QuantityObject();
        quantityObject.Id = priceObj.Id;//価格表Id
        quantityObject.Price = priceObj.Price__c;//単価
        quantityObject.Quantity = null;
        //数量
        //既存登録された場合、登録された数量
        //上記以外 設定なし
        if (detailMap!=null && detailMap.size()>0) {
            Detail__c detail = detailMap.get(priceObj.UniqueKey__c);
            if (detail !=null ) {
                quantityObject.Quantity = detail.Quantity__c;
            }
        }
        return quantityObject;
    }

    //価格表情報を取得
    private static  List<PricingTable__c> getPriceInfo(String bu , String installationLocation) {
    //名称1「屋内／屋外」（見積.レコードタイプ＝”水環境”or"官需"の場合は「ACB盤　屋内／屋外」）
    String conInstallationLocation = (bu=='M'?'ACB盤　屋内':installationLocation);
    List<String> name1Lst = new List<String>();
    // 名称1「零相変流器+地絡過電流継電器」かつ、名称3「低圧」かつ、BU「S」
    //名称1「計器用変圧器」、名称2「VT,PT 引出型」かつBU「S」
    //名称1「計器用変流器」かつ、BU「S」
    //名称1「プロテクタヒューズ」かつ、BU「S」
    //名称1「テイクオフヒューズ」かつ、BU「S」
    //名称1「ネットワークリレー」かつ、BU「S」
    //名称1「合成CT(低圧)」かつ、BU「S」
    //名称1「ネットワークVT(低圧)」かつ、BU「S」
    //名称1「ネットワークCT(低圧)」かつ、BU「S」
    if (bu=='S') {
        name1Lst.add('零相変流器+地絡過電流継電器');
        name1Lst.add('計器用変圧器');
        name1Lst.add('計器用変流器');
        name1Lst.add('プロテクタヒューズ');
        name1Lst.add('テイクオフヒューズ');
        name1Lst.add('ネットワークリレー');
        name1Lst.add('合成CT(低圧)');
        name1Lst.add('ネットワークVT(低圧)');
        name1Lst.add('ネットワークCT(低圧)');
    }

    //検索用SQL文を作成
    String sql = 'SELECT '
                + '    Id, '
                + '    DisplayName__c, '
                + '    MajorClassificationName__c, '
                + '    MinorClassificationName__c, '
                + '    RECNOforACBBoardB_Attachment__c, '
                + '    Name1__c, '
                + '    Name2__c, '
                + '    Name3__c, '
                + '    Name4__c, '
                + '    Name5__c, '
                + '    Name6__c, '
                + '    Name7__c, '
                + '    Name8__c, '
                + '    Name9__c, '
                + '    Name10__c, '
                + '    RecordType.DeveloperName, '
                + '    Price__c, '
                + '    UniqueKey__c, '
                + '    CategoryName__c '
                + 'FROM PricingTable__c '
                + 'WHERE '
                //”施設”BUが「S」/ ”水環境”or"官需"の場合 BUが「M」
                + '    BU__c = :bu  AND  '
                //  ・レコードタイプ「筐体」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「ACB盤」かつ、名称1「ACB盤　屋内」かつBU「M」
                //  ・見積.レコードタイプ＝”施設"の場合、この表は表示しない

                // 　・レコードタイプ「筐体」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「ACB盤」かつ、BU「S」かつ 名称1「屋内」 = 画面.筐体仕様
                // ・見積.レコードタイプ＝”水環境"or"官需"の場合、この表は表示しない
                + '    ((  RecordType.DeveloperName = :recordTypeChassis AND '
                + '        MajorClassificationName__c = :majorClassification AND  '
                + '        MinorClassificationName__c = :minorClassification AND '
                + '        Name1__c = :conInstallationLocation) '

                //レコードタイプ「明細」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「ACB盤」
                + '    OR ( '
                + '        RecordType.DeveloperName = :recordTypeDetail AND '
                + '        MajorClassificationName__c = :majorClassification AND  '
                + '        MinorClassificationName__c = :minorClassification  '
                + '        ) ';
        if (bu=='S') {
            //レコードタイプ「明細」かつ、大分類名「共通機器」
            sql = sql + '    OR ( '
                + '        RecordType.DeveloperName = :recordTypeDetail AND '
                + '        MajorClassificationName__c = :majorDetail AND '
                + '            (Name1__c = :name1Lst  '
                        //名称1「配線用遮断器」を含むかつ、BU「S」
                + '            OR Name1__c like \'%配線用遮断器%\' '
                        //ACB盤B画面用RECNOがnull以外かつ、BU「S」
                + '            OR RECNOforACBBoardB_Attachment__c <> null '
                + '            ) '
                + '        ) ';
        }
        sql = sql + '      ) ORDER BY  RECNOforACBBoardB_Attachment__c, RECNo__c ';

        system.debug(sql);
        // セットした条件で価格表のデータを検索する。
        return Database.query(sql);
    }
    //セルに値を設定
    private static BodyCell setCell(Object value,Integer colSpanCnt,Integer rowSpanCnt, Boolean isEdit, Boolean isRight){
        BodyCell cell = new BodyCell();
        cell.isEdit=isEdit;
        cell.isRight=isRight;
        cell.value = value;
        if (colSpanCnt != null){
            cell.colSpanCnt=colSpanCnt;
            cell.isColSpan=true;
        }else{
            cell.isColSpan=false;
        }

        if (rowSpanCnt!=null) {
            cell.rowSpanCnt=rowSpanCnt;
            cell.isRowSpan=true;
        }else {
            cell.isRowSpan=false;
        }
        return cell;
    }
}