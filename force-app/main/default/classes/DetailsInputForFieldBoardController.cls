/**
 * 明細入力B(明細入力B_現場盤)画面のコントローラー
 * 
 * @author TS鈴木 2023/07/14
 * @version 1.0
 */
public with sharing class DetailsInputForFieldBoardController {
    private static final String recordTypeChassis = 'Chassis';//筐体
    private static final String recordTypeDetail = 'Detail';//明細
    private static final String majorClassification = '低圧・現場・リレー・ACB盤';
    private static final String minorClassification = '低圧盤';
    private static final String majorDetail = '共通機器';
    private static final String fieldClassification = '現場盤';

    public class ScreenInfo {
        Boolean isFieldNodata  {get;set;}
        Boolean isPostAddNodata  {get;set;}
        Boolean isWallSpNodata  {get;set;}

        //初期表示(選択内容)
        String inputedId {get;set;}//筐体チェックボックスのId
        String detailInputedId {get;set;}//明細チェックボックスのId
        Decimal inputedPrice {get;set;}//筐体　単価
        Decimal displayTotal {get;set;} //合計金額
        Decimal detailInputedPrice {get;set;}//明細チェック　単価
        String displayCondition {get;set;}//選択仕様
        
        //検索条件
        String installationLocation {get;set;}
        String doorSpecifications {get;set;}
        String housingSpecifications {get; set;}

        //メイン表（壁掛盤筐体一覧）
        //筐体の表を高さ(H)毎に別の表に分ける対応
        List<ClassicTable> fieldTables {get; set;}

        //メイン表（低圧配電盤筐体一覧）
        //筐体の表を高さ(H)毎に別の表に分ける対応
        List<ClassicTable> classicTables {get; set;}

        //ポスト（スタンド）形の場合の加算価格
        String postAddHeadTitle {get; set;}
        String postAddFooterInfo {get; set;}
        public List<BodyRow> postAddBodyList {get;set;}//一覧データ
        public List<BodyRow> postAddHeaderList {get;set;}//一覧ヘッダー

        //防爆形筐体価格
        String wallSpHeadTitle {get; set;}
        String wallSpFooterInfo {get; set;}
        public List<BodyRow> wallSpBodyList {get;set;}//一覧データ
        public List<BodyRow> wallSpHeaderList {get;set;}//一覧ヘッダー

        public CustomTable mccbTable {get;set;}//配線用遮断器価格 （MCCB・ELB）
        public CustomTable mccbTableHas {get;set;}//配線用遮断器価格 （MCCB・ELB）_MCCB電動操作あり
        public CustomTable installEquipTypeTable{get;set;} //取付器具類
        public CustomTable startupCircuitTable{get;set;} //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
        public CustomTable electroSwitchTable{get;set;} // 電磁開閉器（MC）

        String recordType {get;set;}
    }

    // （低圧配電盤筐体一覧）筐体テーブル
    //筐体の表を高さ(H)毎に別の表に分ける対応
    public class ClassicTable {
        Boolean isLowPressureNodata  {get;set;}
        //メイン表（筐体一覧）
        String headTitle {get; set;}
        String footerInfo {get; set;}
        public List<BodyRow> bodyList {get;set;}//一覧データ
        public List<BodyRow> headerList {get;set;}//一覧ヘッダー
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
     * 明細入力B(明細入力B_現場盤) 表示データを取得
     * 
     * @param isInit 初期フラグ
     * @param deviceId 見積項目Id
     * @param installationLocation 設置場所（屋内／屋外）
     * @param housingSpecifications 筐体仕様（自立SS／自立SUS）
     * @param doorSpecifications 扉仕様（1枚扉／観音開き）
     * 
     */
    Public static String getInitScreenInfo(Boolean isInit,
                                        String deviceId,
                                        String installationLocation,
                                        String housingSpecifications,
                                        String doorSpecifications){

        ScreenInfo info = new ScreenInfo();
        String bu = '';
        Detail__c currentDetail;
        String category;
        Map<String, Detail__c> detailsMap = new Map<String, Detail__c>();

        if (String.isNotBlank(deviceId)) {
            //見積項目
            Device__c device = [SELECT Id, 
                        toLabel(MajorClassification__c), //見積項目大分類
                        MinorClassification__c, //見積項目小分類
                        Quote__r.PowerFrequency__c, //見積項目周波数
                        Quote__r.RecordType.DeveloperName, //レコードタイプ
                        (SELECT Id,Name,UnitPrice__c,PricingTableUniqueKey__c,DetailCategory__c,Quantity__c,CreditWC__c,
                                Name1__c,Name2__c,Name3__c,Name4__c,Name5__c,Name6__c,Name7__c,Name8__c,Name9__c,Name10__c
                            FROM Details__r)
                        FROM Device__c WHERE Id =:deviceId LIMIT 1];

            // 見積のレコードタイプ確認し、BUの条件をセットする。
            info.recordType = device.Quote__r.RecordType.DeveloperName;
            bu = device.Quote__r.RecordType.DeveloperName == 'Facility' ? 'S' : 'M';
            category =  device.Quote__r.PowerFrequency__c;
            if (device.Details__r!=null 
                && device.Details__r.size()>0) {
                for (Detail__c tmp :device.Details__r) {
                    if (tmp.DetailCategory__c == '筐体' 
                        && String.isNotBlank(tmp.PricingTableUniqueKey__c)
                        && (tmp.PricingTableUniqueKey__c.contains('低圧・現場・リレー・ACB盤低圧盤') || tmp.PricingTableUniqueKey__c.contains('低圧・現場・リレー・ACB盤現場盤'))) {
                        currentDetail = tmp;//筐体の登録データ
                    }else {
                        detailsMap.put(tmp.PricingTableUniqueKey__c, tmp);
                    }
                }
            }
        }

        /*
         検索条件をセットする。
         ・元のデータが有る場合は、元の条件をセットする。
         ・元のデータが無い場合は、画面でセットされた条件をセットする。
        */
        if (isInit && currentDetail != null) {
            if(currentDetail.PricingTableUniqueKey__c.contains('低圧・現場・リレー・ACB盤現場盤') && currentDetail.Name1__c.contains('防爆形')){
                installationLocation = '防爆形';
                housingSpecifications = '';
                doorSpecifications = '';
            }else if(currentDetail.PricingTableUniqueKey__c.contains('低圧・現場・リレー・ACB盤現場盤') && !currentDetail.Name1__c.contains('防爆形')){
                installationLocation = '壁掛';
                housingSpecifications = '';
                doorSpecifications = '';
            }else{
                installationLocation = currentDetail.Name1__c.right(2);
                housingSpecifications = currentDetail.Name2__c;
                doorSpecifications = '1枚扉';
                if (currentDetail.Name6__c=='観音開き')doorSpecifications=currentDetail.Name6__c;
            }
        }
        info.installationLocation = installationLocation;
        info.housingSpecifications = housingSpecifications;
        info.doorSpecifications = doorSpecifications;
        System.debug('info.installationLocation=' + info.installationLocation);
        System.debug('installationLocation=' + installationLocation);
        
        //名称1「屋内／屋外／防爆形」（見積.レコードタイプ＝”水環境”or"官需"の場合は「低圧盤　屋内／屋外」）
        String conInstallationLocation = (bu=='M'?'低圧盤　'+installationLocation:installationLocation);
        //名称2「自立SS／自立SUS」
        String conHousingSpecifications = housingSpecifications;
        //「観音開き」の場合 名称6が「観音開き」、「1枚扉」の場合　名称6が空欄
        String conDoorSpecifications = (doorSpecifications=='観音開き'?doorSpecifications:'');

        // セットした条件で現場盤価格表のデータを検索する。
        List<PricingTable__c> fieldChassisList = [SELECT 
                                                Id,
                                                Name,
                                                Name1__c,
                                                Name2__c,
                                                Name3__c,
                                                Name4__c,
                                                Name5__c, 
                                                Name6__c, 
                                                Name7__c, 
                                                Name8__c, 
                                                Name9__c, 
                                                Name10__c, 
                                                Price__c,
                                                UniqueKey__c,
                                                CategoryName__c,
                                                MasterCode__c,
                                                DetailRecordDisplayNumberText__c
                                             FROM PricingTable__c 
                                             WHERE 
                                                // レコードタイプ「筐体」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤」
                                                RecordType.DeveloperName = 'Chassis' AND
                                                MajorClassificationName__c = :majorClassification AND 
                                                MinorClassificationName__c = :fieldClassification AND
                                                //”施設”BUが「S」/ ”水環境”or"官需"の場合 BUが「M」
                                                BU__c = :bu AND
                                                //名称2「壁掛SS／壁掛SUS」
                                                Name2__c IN ('壁掛SS','壁掛SUS')
                                             ORDER BY 
                                             RECNo__c
                                    ];
        
        Map<Integer, Set<Integer>> fieldChassisMap = new Map<Integer, Set<Integer>>();
        Map<String, PricingTable__c> fieldChassisData = new Map<String, PricingTable__c>();
        

        //筐体　高さ(H)毎に別の表に分ける
        List<ClassicTable> fieldTables = new List<ClassicTable>();
        //データありの場合
        if (fieldChassisList != null && fieldChassisList.size()>0) {

            Set<String> fieldHeaderCellData1 = new Set<String>();
            Set<String> fieldHeaderCellData2 = new Set<String>();
            for (PricingTable__c chassis : fieldChassisList) {
                String tmpName3 = chassis.Name3__c;
                tmpName3 = tmpName3.replace('W', '').replace(',', '');//数字以外を除外
                String tmpName4 = chassis.Name4__c;
                tmpName4 = tmpName4.replace('H', '').replace(',', '');//数字以外を除外
                String tmpName5 = chassis.Name5__c;
                tmpName5 = tmpName5.replace('D', '').replace(',', '');//数字以外を除外
    
                //横1行目のヘッダー
                fieldHeaderCellData1.add('D:' + tmpName5);
                //横2行目のヘッダー
                String fieldHeaderCell = chassis.Name1__c;
                if(chassis.Name1__c.contains('屋内') && chassis.Name2__c.contains('SS')){
                    fieldHeaderCell = 'SS屋内型';
                }
                if(chassis.Name1__c.contains('屋外') && chassis.Name2__c.contains('SS')){
                    fieldHeaderCell = 'SS屋外型';
                }
                if(chassis.Name1__c.contains('屋内') && chassis.Name2__c.contains('SUS')){
                    fieldHeaderCell = 'SUS屋内型';
                }
                if(chassis.Name1__c.contains('屋外') && chassis.Name2__c.contains('SUS')){
                    fieldHeaderCell = 'SUS屋外型';
                }
                fieldHeaderCellData2.add(fieldHeaderCell);
                String key = tmpName3 + tmpName4 + fieldHeaderCell;
    
                if (!fieldChassisMap.containsKey(Integer.valueOf(tmpName3))) fieldChassisMap.put(Integer.valueOf(tmpName3), new Set<Integer>());
                if (!fieldChassisData.containsKey(key)) fieldChassisData.put(key, chassis);
                //縦　Wごとに　Hリストを設定
                fieldChassisMap.get(Integer.valueOf(tmpName3)).add(Integer.valueOf(tmpName4));
            }

            List<BodyRow> fieldHeaderList = new List<BodyRow>();//ヘッダー情報
            //1行目のヘッダー設定
            BodyRow fieldHeaderRow1 = new BodyRow();
            List<BodyCell> fieldHeaderCell1 = new List<BodyCell>();//ヘッダーセル
    
            fieldHeaderCell1.add(setCell('寸法', 2, null, false, false));
            fieldHeaderCell1.add(setCell(null,null, null, false, false));//非表示セル
            //D をヘッダーに設定
            for (String item : fieldHeaderCellData1) {
                fieldHeaderCell1.add(setCell(item, 8, null, false, false));
                fieldHeaderCell1.add(setCell(null, null, null, false, false));//非表示セル
                fieldHeaderCell1.add(setCell(null, null, null, false, false));//非表示セル
                fieldHeaderCell1.add(setCell(null, null, null, false, false));//非表示セル
                fieldHeaderCell1.add(setCell(null, null, null, false, false));//非表示セル
                fieldHeaderCell1.add(setCell(null, null, null, false, false));//非表示セル
                fieldHeaderCell1.add(setCell(null, null, null, false, false));//非表示セル
                fieldHeaderCell1.add(setCell(null, null, null, false, false));//非表示セル
            }
            fieldHeaderRow1.cellList = fieldHeaderCell1;
            fieldHeaderList.add(fieldHeaderRow1);
    
            //2行目のヘッダー設定
            BodyRow fieldHeaderRow2 = new BodyRow();
            List<BodyCell> fieldHeaderCell2 = new List<BodyCell>();//ヘッダーセル
    
            fieldHeaderCell2.add(setCell('W', null, null, false, false));
            fieldHeaderCell2.add(setCell('H', null, null, false, false));
            //筐体の形 をヘッダーに設定
            for (String item : fieldHeaderCellData2) {
                fieldHeaderCell2.add(setCell(item, 2, null, false, false));
                fieldHeaderCell2.add(setCell(null, null, null, false, false));//非表示セル
            }
            fieldHeaderRow2.cellList = fieldHeaderCell2;
            fieldHeaderList.add(fieldHeaderRow2);
    
            //表が分けるの限界値を取得する。
            //200,600,800,1000@500,700,900,1200
            List<String> preName3 = System.Label.ScreenB_FieldBoard_Control.split('@').get(0).split(',');
            List<String> lastedName3 = System.Label.ScreenB_FieldBoard_Control.split('@').get(1).split(',');

            ClassicTable tbl = new ClassicTable();
            tbl.isLowPressureNodata = true;
            String title = '';
            List<BodyRow> fieldBodyList = new List<BodyRow>();//ボディー情報
            tbl.footerInfo= null;
            //ヘッダ設定
            tbl.headerList = fieldHeaderList;
            //データ行を設定
            for (Integer name3 : fieldChassisMap.keyset()) {
                Set<Integer> name4Set = fieldChassisMap.get(name3);
                if (name4Set==null || name4Set.size()==0){
                    continue;
                }
                if (tbl.isLowPressureNodata) tbl.isLowPressureNodata = false;
                if (preName3.contains(String.valueOf(name3))) title = 'ポスト（スタンド）（W'+name3.format()+'-';
                if (lastedName3.contains(String.valueOf(name3))) title = title + name3.format()+'）・壁掛盤筐体価格';
                tbl.headTitle=title;
                //Hデータ
                List<Integer> name4Lst = new List<Integer>(name4Set);
                name4Lst.sort();
                
                //Wセルであるかどうか
                Boolean isFirst = true;
    
                for (Integer name4 : name4Lst) {
                    //一行のデータ
                    List<BodyCell> fieldBodyRow = new List<BodyCell>();
                    if (isFirst) {
                        //W　セルの設定
                        fieldBodyRow.add(setCell(name3.format(), null, name4Lst.size(), false, false));
                        isFirst = false;
                    }else {
                        fieldBodyRow.add(setCell(null, null, null, false, false));

                    }
                    //H　セルの設定
                    fieldBodyRow.add(setCell(name4.format(), null, null, false, true));
                    //価格、チェックボックス
                    for(String fieldHeader : fieldHeaderCellData2) {
                        PricingTable__c fieldCellData = fieldChassisData.get(String.valueOf(name3)+String.valueOf(name4)+fieldHeader);
                        if (fieldCellData!=null) {
                            //チェックボックス
                            Decimal price =  (fieldCellData.Price__c==null?0:fieldCellData.Price__c);
                            //価格
                            fieldBodyRow.add(setCell(price.format(), null, null, false, true));
                            // 名称1～7を半角スペースで連結して表示
                            String name = fieldCellData.Name1__c
                                        + (String.isNotBlank(fieldCellData.Name2__c)?' ' + fieldCellData.Name2__c:'')
                                        + (String.isNotBlank(fieldCellData.Name3__c)?' ' + fieldCellData.Name3__c:'')
                                        + (String.isNotBlank(fieldCellData.Name4__c)?' ' + fieldCellData.Name4__c:'')
                                        + (String.isNotBlank(fieldCellData.Name5__c)?' ' + fieldCellData.Name5__c:'')
                                        + (String.isNotBlank(fieldCellData.Name6__c)?' ' + fieldCellData.Name6__c:'')
                                        + (String.isNotBlank(fieldCellData.Name7__c)?' ' + fieldCellData.Name7__c:'');
                            Map<String,Object> cellItem = new Map<String,Object>();
                            cellItem.put('Id',fieldCellData.Id);//Id
                            cellItem.put('Price__c',price);//単価
                            cellItem.put('Name1__c',name);//仕様
    
                            //既存データの設定
                            if (currentDetail!=null 
                                && currentDetail.PricingTableUniqueKey__c == fieldCellData.UniqueKey__c){
                                info.inputedId = fieldCellData.Id;//チェックされた値
                                info.inputedPrice= price;
                                info.displayTotal = price;//単価
                                info.displayCondition = name;//選択仕様
                                cellItem.put('isChecked',true);
                            }else {
                                cellItem.put('isChecked',false);
                            }
                            
                            fieldBodyRow.add(setCell(cellItem,null,null,true,false));//入力セル
                        }else {
                            //価格
                            fieldBodyRow.add(setCell('―',null,null,false,true));//価格セル
                            //チェックボックス
                            fieldBodyRow.add(setCell('　',null,null,false,false));//空白
                        }
                    }
    
                    BodyRow fieldRow = new BodyRow();
                    fieldRow.cellList = fieldBodyRow;
                    fieldBodyList.add(fieldRow);
                }
                //以下の場合には　次から別一覧に表示
                if (lastedName3.contains(String.valueOf(name3))){
                    tbl.bodyList = fieldBodyList;
                    fieldTables.add(tbl);
                    tbl = new ClassicTable();
                    fieldBodyList = new List<BodyRow>();//ボディー情報
                    tbl.isLowPressureNodata = true;
                    title = '';
                    tbl.footerInfo= null;
                    //ヘッダ設定
                    tbl.headerList = fieldHeaderList;
                }
            }
           
        }

        info.fieldTables = fieldTables;

        // セットした条件で低圧盤価格表のデータを検索する。
        List<PricingTable__c> lowVoltageChassisList = [SELECT 
                                                Id,
                                                Name,
                                                Name1__c,
                                                Name2__c,
                                                Name3__c,
                                                Name4__c,
                                                Name5__c, 
                                                Name6__c, 
                                                Name7__c, 
                                                Name8__c, 
                                                Name9__c, 
                                                Name10__c, 
                                                Price__c,
                                                UniqueKey__c,
                                                CategoryName__c 
                                             FROM PricingTable__c 
                                             WHERE 
                                                // レコードタイプ「筐体」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤」
                                                RecordType.DeveloperName = 'Chassis' AND
                                                MajorClassificationName__c = :majorClassification AND 
                                                MinorClassificationName__c = :minorClassification AND
                                                //”施設”BUが「S」/ ”水環境”or"官需"の場合 BUが「M」
                                                BU__c = :bu AND
                                                //名称1「屋内／屋外」（見積.レコードタイプ＝”水環境”or"官需"の場合は「低圧盤　屋内／屋外」） 
                                                Name1__c = :conInstallationLocation AND
                                                //名称2「自立SS／自立SUS」
                                                Name2__c = :conHousingSpecifications AND
                                                //「観音開き」の場合 名称6が「観音開き」、「1枚扉」の場合　名称6が空欄
                                                Name6__c = :conDoorSpecifications 
                                             ORDER BY 
                                             RECNo__c
                                    ];
        
        Map<Integer, Set<Integer>> chassisMap = new Map<Integer, Set<Integer>>();
        Map<String, PricingTable__c> chassisData = new Map<String, PricingTable__c>();
        
        //筐体　高さ(H)毎に別の表に分ける
        List<ClassicTable> classicTables = new List<ClassicTable>();
 
        //データありの場合
        if (lowVoltageChassisList!=null && lowVoltageChassisList.size()>0) {
            //キーを設定
            for (PricingTable__c chassis : lowVoltageChassisList) {
                String tmpName3 = chassis.Name3__c;
                tmpName3 = tmpName3.replace('W', '').replace(',', '');//数字以外を除外
                String tmpName4 = chassis.Name4__c;
                tmpName4 = tmpName4.replace('H', '').replace(',', '');//数字以外を除外
                String tmpName5 = chassis.Name5__c;
                tmpName5 = tmpName5.replace('D', '').replace(',', '');//数字以外を除外
                String key = tmpName3 + tmpName4 +tmpName5;

                if (!chassisMap.containsKey(Integer.valueOf(tmpName4))) chassisMap.put(Integer.valueOf(tmpName4), new Set<Integer>());
                if (!chassisData.containsKey(key)) chassisData.put(key, chassis);
                //縦　Hごとに　Wリストを設定
                chassisMap.get(Integer.valueOf(tmpName4)).add(Integer.valueOf(tmpName3));
            }

            //データ行を設定
            for (Integer name4 : chassisMap.keyset()) {
                Set<Integer> name3Set = chassisMap.get(name4);

                ClassicTable tbl = new ClassicTable();
                tbl.headTitle='低圧盤(H'+name4.format()+')  筐体価格';
                tbl.footerInfo= System.Label.Annotation_LowVoltageBoard_Cabinet;
                if (name3Set==null || name3Set.size()==0){
                    tbl.isLowPressureNodata = true;
                    continue;
                }
                tbl.isLowPressureNodata = false;

                //高さ(H)毎にヘッダ設定
                Set<Integer> headerCellData = new Set<Integer>();//ソート用
                for (PricingTable__c chassis : lowVoltageChassisList) {
                    String tmpName4 = chassis.Name4__c;
                    tmpName4 = tmpName4.replace('H', '').replace(',', '');//数字以外を除外
                    String tmpName5 = chassis.Name5__c;
                    tmpName5 = tmpName5.replace('D', '').replace(',', '');//数字以外を除外
                    if (Integer.valueOf(tmpName4) != name4)continue;
                    // 横　のヘッダー
                    headerCellData.add(Integer.valueOf(tmpName5));
                }

                List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報
                List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報
    
                //ヘッダー設定
                BodyRow headerRow = new BodyRow();
                List<BodyCell> headerCell = new List<BodyCell>();//ヘッダーセル
    
                List<Integer> sortedHeaderCellData = new List<Integer>(headerCellData);
                sortedHeaderCellData.sort();
                headerCell.add(setCell('H', null, null, false, false));
                headerCell.add(setCell(new List<String>{'W','D'}, null, null, true, false));
                //D をヘッダーに設定
                for (Integer item : sortedHeaderCellData) {
                    headerCell.add(setCell(item.format(), null, null, false, false));
                    headerCell.add(setCell(null, null, null, false, false));
                }
                headerRow.cellList = headerCell;
                headerList.add(headerRow);
                //画面情報に設定して、返し
                tbl.headerList = headerList;

                //Hデータ
                List<Integer> name3Lst = new List<Integer>(name3Set);
                name3Lst.sort();
                
                //Hセルであるかどうか
                Boolean isFirst = true;

                for (Integer name3 : name3Lst) {
                    //一行のデータ
                    List<BodyCell> bodyRow = new List<BodyCell>();
                    if (isFirst) {
                        //H　セルの設定
                        bodyRow.add(setCell(name4.format(), null, name3Lst.size(), false, true));
                        isFirst = false;
                    }
                    // 20231121 非表示セルを追加
                    else {
                        bodyRow.add(setCell(null, null, null, false, true));
                    }

                    //W　セルの設定
                    bodyRow.add(setCell(name3.format(), null, null, false, true));
                    //価格、チェックボックス
                    for(Integer name5 : sortedHeaderCellData) {
                        PricingTable__c cellData = chassisData.get(String.valueOf(name3)+String.valueOf(name4)+String.valueOf(name5));
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
                                        + (String.isNotBlank(cellData.Name5__c)?' ' + cellData.Name5__c:'')
                                        + (String.isNotBlank(cellData.Name6__c)?' ' + cellData.Name6__c:'')
                                        + (String.isNotBlank(cellData.Name7__c)?' ' + cellData.Name7__c:'');
                            Map<String,Object> cellItem = new Map<String,Object>();
                            cellItem.put('Id',cellData.Id);//Id
                            cellItem.put('Price__c',price);//単価
                            cellItem.put('Name1__c',name);//仕様

                            //既存データの設定
                            if (currentDetail!=null 
                                && currentDetail.PricingTableUniqueKey__c == cellData.UniqueKey__c){
                                info.inputedId = cellData.Id;//チェックされた値
                                info.inputedPrice= price;
                                info.displayTotal = price;//単価
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
                            bodyRow.add(setCell('　',null,null,false,false));//空白
                        }
                    }

                    BodyRow row = new BodyRow();
                    row.cellList = bodyRow;
                    bodyList.add(row);
                }
                tbl.bodyList = bodyList;
                classicTables.add(tbl);
            }
            info.classicTables = classicTables;
        }

        //壁掛の場合、ポスト（スタンド）形の場合の加算価格を表示
        if(installationLocation == '壁掛'){
            List<String> indicatorLst = new List<String>{'材料','価格',''};
            String customSql,customOrderBy;

            customSql = ' AND MinorClassificationName__c = \'現場盤\'';

            // セットした条件で価格表のデータを検索する。
            List<PricingTable__c> detailPriceList = getDetailPriceTable(recordTypeDetail,majorClassification,bu, customSql, customOrderBy);

            //タイトル設定　例：ポスト（スタンド）形の場合の加算価格
            info.postAddHeadTitle = 'ポスト（スタンド）形の場合の加算価格';
            info.postAddFooterInfo = System.Label.Annotation_PostStandAddPrice;

            // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
            if (detailPriceList.size() == 0) {
                info.isPostAddNodata = true;
            }

            List<BodyRow> postAddHeaderList = new List<BodyRow>();//ヘッダ行情報
            List<BodyRow> postAddBodyList = new List<BodyRow>();//ボディー行情報
            
            //ヘッダ　設定 例：材料、価格
            if(indicatorLst!=null && indicatorLst.size()>0){
                List<BodyCell> headerRow1 = new List<BodyCell>();
                for (String postAddHeaderCell : indicatorLst) {
                    headerRow1.add(setCell(postAddHeaderCell,null,null,false,false));
                }
                BodyRow row1 = new BodyRow();
                row1.cellList=headerRow1;
                postAddHeaderList.add(row1);
            }

            info.postAddHeaderList = postAddHeaderList;

            Boolean isFirst = true;//一回だけ実施
            //ボディー行情報設定
            for(PricingTable__c tmp : detailPriceList){
                BodyRow row = new BodyRow();
                List<BodyCell> bodyRow  = new List<BodyCell>();

                String name = '';
                //機器名 ⇒ 価格表.表示用テキスト
                name = tmp.DisplayName__c;

                bodyRow.add(setCell(name, null, null, false, false));

                Decimal decPrice = (tmp.Price__c==null?0:tmp.Price__c);
                bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                
                Map<String,Object> cellItem = new Map<String,Object>();
                cellItem.put('Id',tmp.Id);//Id
                cellItem.put('Price__c',decPrice);//単価
                cellItem.put('Name1__c',name);//仕様
                cellItem.put('isChecked',false);

                //既存登録されていた場合、チェック
                //上記以外 チェックなし
                if (detailsMap!=null && detailsMap.size()>0){
                    Detail__c detail = detailsMap.get(tmp.UniqueKey__c);
                    if (detail !=null ) {
                        cellItem.put('isChecked',true);
                        info.detailInputedId = tmp.Id;//チェックされた値
                        info.detailInputedPrice = decPrice;
                        info.displayTotal = (info.displayTotal==null?decPrice:info.displayTotal + decPrice);
                    }
                }
                
                bodyRow.add(setCell(cellItem,null,null,true,false));//入力セル
                row.cellList = bodyRow;
                postAddBodyList.add(row);
            }
            info.postAddBodyList = postAddBodyList;    
        }

        //防爆形の場合、防爆形筐体価格を表示
        // レコードタイプ＝”施設"の場合、この表は表示しない
        if (bu!='S' && installationLocation == '防爆形') {
            List<String> indicatorLst = new List<String>{'品名','価格',''};
            String customSql,customOrderBy;
            customSql = ' AND MinorClassificationName__c = \'現場盤\' AND  Name1__c like \'%防爆形%\'';

            // セットした条件で価格表のデータを検索する。
            List<PricingTable__c> detailPriceList = getDetailPriceTable(recordTypeChassis,majorClassification,bu, customSql, customOrderBy);

            //タイトル設定　例：防爆形筐体価格（盤面取付器具数15個まで）
            info.wallSpHeadTitle = '防爆形筐体価格（盤面取付器具数15個まで）';
            info.wallSpFooterInfo = System.Label.Annotation_WallCreditBoard;

            // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
            if (detailPriceList.size() == 0) {
                info.isWallSpNodata = true;
            }

            List<BodyRow> wallSpHeaderList = new List<BodyRow>();//ヘッダ行情報
            List<BodyRow> wallSpBodyList = new List<BodyRow>();//ボディー行情報
            
            //ヘッダ　設定 例：材料、価格
            if(indicatorLst!=null && indicatorLst.size()>0){
                List<BodyCell> headerRow1 = new List<BodyCell>();
                for (String wallSpHeaderCell : indicatorLst) {
                    headerRow1.add(setCell(wallSpHeaderCell,null,null,false,false));
                }
                BodyRow row1 = new BodyRow();
                row1.cellList=headerRow1;
                wallSpHeaderList.add(row1);
            }

            info.wallSpHeaderList = wallSpHeaderList;

            Boolean isFirst = true;//一回だけ実施
            //ボディー行情報設定
            for(PricingTable__c tmp : detailPriceList){
                BodyRow row = new BodyRow();
                List<BodyCell> bodyRow  = new List<BodyCell>();

                String name = '';
                //機器名 ⇒ 価格表.表示用テキスト
                name = tmp.DisplayName__c;

                bodyRow.add(setCell(tmp.Name2__c, null, null, false, false));

                Decimal decPrice = (tmp.Price__c==null?0:tmp.Price__c);
                bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                
                Map<String,Object> cellItem = new Map<String,Object>();
                cellItem.put('Id',tmp.Id);//Id
                cellItem.put('Price__c',decPrice);//単価
                cellItem.put('Name1__c',name);//仕様

                //既存登録されていた場合、チェック
                //上記以外 チェックなし
                if (currentDetail!=null 
                    && currentDetail.PricingTableUniqueKey__c == tmp.UniqueKey__c){
                    info.inputedId = tmp.Id;//チェックされた値
                    info.inputedPrice= decPrice;
                    info.displayTotal = decPrice;//単価
                    info.displayCondition = name;//選択仕様
                    cellItem.put('isChecked',true);
                }else {
                    cellItem.put('isChecked',false);
                }
                
                bodyRow.add(setCell(cellItem,null,null,true,false));//入力セル
                row.cellList = bodyRow;
                wallSpBodyList.add(row);
            }
            info.wallSpBodyList = wallSpBodyList;
        }
        
        //配線用遮断器価格 （MCCB・ELB）
        List<CustomTable> tbls = setMccbTable(bu, detailsMap);
        if(tbls!=null&&tbls.size()>0)info.mccbTable = tbls.get(0);
        if(tbls!=null&&tbls.size()>1)info.mccbTableHas = tbls.get(1);
        
        //取付器具類
        List<String> indicatorLst = new List<String>{'機 器 名','WC','価格','数量'};
        info.installEquipTypeTable = setCommonEquipment('取付器具類',indicatorLst, bu, detailsMap);

        //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】
        // レコードタイプ＝”施設"の場合、この表は表示しない
        if (bu!='S') {
            info.startupCircuitTable = setStartupCircuitTable('起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】', bu, detailsMap);
        }
        //電磁開閉器（MC）
        info.electroSwitchTable = setStartupCircuitTable('電磁開閉器（MC）', bu, detailsMap);

        return JSON.serialize(info);
    }

    //共通機器 明細をを設定
    //低圧CT・PT、保護継電器類
    private static CustomTable setCommonEquipment(String secTitle, List<String> headerLst, String bu, Map<String, Detail__c> detailsMap){

        String customSql,customOrderBy;
        // 低圧CT・PT、保護継電器類
        if (secTitle=='取付器具類') {
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、低圧盤B画面取付器具類用RECNOがnull以外
            customSql = ' AND RECNOforFieldBoardB_Attachment__c <> null ';
            //低圧盤B画面取付器具類用RECNO 昇順
            customOrderBy = '  RECNOforFieldBoardB_Attachment__c  ';
        } 

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> detailPriceList = getDetailPriceTable(recordTypeDetail,null,bu, customSql, customOrderBy);

        CustomTable table = new CustomTable();
        //タイトル設定　例：低圧CT・PT、保護継電器類
        table.secTitle = secTitle;

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (detailPriceList.size() == 0) return table;

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報
        
        //ヘッダ　設定 例：品　名、価格、数量
        if(headerLst!=null && headerLst.size()>0){
            List<BodyCell> headerRow1 = new List<BodyCell>();
            for (String headerCell : headerLst) {
                headerRow1.add(setCell(headerCell,null,null,false,false));
            }
            BodyRow row1 = new BodyRow();
            row1.cellList=headerRow1;
            headerList.add(row1);
        }

        table.headerList = headerList;

        Boolean isFirst = true;//一回だけ実施
        //ボディー行情報設定
        for(PricingTable__c tmp : detailPriceList){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();

            String name = '';
            //機器名 ⇒ 価格表.表示用テキスト
            name = tmp.DisplayName__c;

            bodyRow.add(setCell(name, null, null, false, false));
            Decimal decPrice = (tmp.Price__c==null?0:tmp.Price__c);

            if(tmp.DisplayName__c.contains('配線材料費')){
                QuantityObject quantityWcObj = new QuantityObject();//wcセル
                QuantityObject quantityPriObj = new QuantityObject();//数量セル
                quantityWcObj.Id = tmp.Id;//価格表Id
                quantityPriObj.Id = tmp.Id;//価格表Id
                quantityWcObj.Price = null;
                quantityPriObj.Price = null;
                quantityPriObj.Quantity = null;
                //上記以外 設定なし
                if (detailsMap!=null && detailsMap.size()>0) {
                    Detail__c detail = detailsMap.get(tmp.UniqueKey__c);
                    if (detail !=null ) {
                        quantityWcObj.Price = detail.CreditWC__c;//WC 
                        quantityPriObj.Price = detail.UnitPrice__c;//数量セル
                        quantityPriObj.Quantity = detail.Quantity__c;//数量セル
                    }
                }
                bodyRow.add(setCell(quantityWcObj, null, null, true, true));
                bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                bodyRow.add(setCell(quantityPriObj, null, null, true, false));//数量
            }else{
                bodyRow.add(setCell('',null,null,false,false));//空白
                bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                bodyRow.add(setCell(getQuantityObject(tmp, detailsMap), null, null, true, false));//数量
            }
            row.cellList = bodyRow;
            bodyList.add(row);
        }
        table.bodyList = bodyList;

        return table;
    }

    //配線用遮断器価格 （MCCB・ELB）
    private static List<CustomTable> setMccbTable(String bu, Map<String, Detail__c> detailsMap){

        // ・価格表マスタから以下の条件で取得し、表形式で表示する。
        // 　・レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「配線用遮断器」を含む
        String customSql = ' AND  Name1__c like \'%配線用遮断器%\'';

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> mccbList = getDetailPriceTable(recordTypeDetail,majorDetail,bu, customSql, null);

        CustomTable table = new CustomTable();
        CustomTable tableHas = new CustomTable();//配線用遮断器価格 （MCCB・ELB）_MCCB電動操作あり

        List<CustomTable> tables = new List<CustomTable>();

        //タイトル設定　配線用遮断器価格 （MCCB・ELB）
        table.secTitle = '配線用遮断器価格 （MCCB・ELB）電動操作なし';
        tableHas.secTitle = '配線用遮断器価格 （MCCB・ELB）電動操作あり';
        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (mccbList==null || mccbList.size() == 0) {
            tables.add(table);
            tables.add(tableHas);
            return tables;
        }

        //ヘッダ行情報 設定
        table.headerList = setMccbTableHeader();
        tableHas.headerList = setMccbTableHeader();

        // ・見積.レコードタイプ＝"施設"の場合はMCCB(A価格)の方に名称2「MCCB」を含むものを表示し、MCCB(B価格)・ELBの方に名称2「ELB」を含むものを表示する
        // ・見積.レコードタイプ＝"水環境"or"官需"の場合はMCCB(A価格)の方に名称1「B価格」を含まないものを表示し、MCCB(B価格)・ELBの方に名称1「B価格」を含むものを表示する
        // ・MCCB電動操作なしのラインには名称4「電動」を含まないものを表示し、MCCB電動操作ありのラインには名称4「電動」を含むものを表示する
        // ・縦の列「4P」には名称2に「4P」を含むもの、「3P」には名称2に「3P」を含むもの、「2P」には名称2に「2P」を含むものを表示する
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //処理対象 キーを設定
        //Map<名称４, Set<名称３>>
        Map<String,Set<Integer>> name4Map = new Map<String,Set<Integer>>{
            'MCCB電動操作なし'=>new Set<Integer>(),
            'MCCB電動操作あり'=>new Set<Integer>()
        };//先頭２列
        Map<String, PricingTable__c> detailMap = new Map<String, PricingTable__c>();
        for(PricingTable__c tmp : mccbList) {
            if (String.isBlank(tmp.Name2__c) || String.isBlank(tmp.Name3__c)) continue;//処理しない
            //データのキー
            String key = '';
            //4P、3P、2P
            if (tmp.Name2__c.contains('4P')) key += '4P';
            if (tmp.Name2__c.contains('3P')) key += '3P';
            if (tmp.Name2__c.contains('2P')) key += '2P';
            //A価格、B価格
            if (bu=='S') {//施設
                //MCCB(A価格)の方に名称2「MCCB」を含むものを表示し、MCCB(B価格)・ELBの方に名称2「ELB」を含むものを表示する
                if (tmp.Name2__c.contains('MCCB')) key += 'A価格';
                if (tmp.Name2__c.contains('ELB')) key += 'B価格';
            }else if (bu=='M') {//”水環境”or"官需"
                //MCCB(A価格)の方に名称1「B価格」を含まないものを表示し、MCCB(B価格)・ELBの方に名称1「B価格」を含むものを表示する
                if (tmp.Name1__c.contains('B価格')){
                    key += 'B価格';
                } else {
                    key += 'A価格';
                }
            }
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
                // //１回のみ設定
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
        //注＊　の設定
        List<String> noteList = System.Label.Annotation_BreakerForWiring.split('\r\n');
        table.noteList = noteList;
        tableHas.noteList = noteList;
        //
        tables.add(table);
        tables.add(tableHas);
        return tables;
    }

    //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】
    //電磁開閉器（MC）
    private static customTable setStartupCircuitTable(String secTitle, String bu, Map<String, Detail__c> detailsMap){
        String customSql ;
        if (secTitle == '電磁開閉器（MC）') {
            //名称10「電磁開閉器（MC）」
            customSql = ' AND  Name10__c = \'電磁開閉器(MC)\'';

        } else if (secTitle=='起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】') {
            //名称10「起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】」かつ、BU「M」
            customSql = ' AND  Name10__c = \'起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】\'';
        }

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> startupCircuList = getDetailPriceTable(recordTypeDetail,majorDetail,bu, customSql, null);

        CustomTable table = new CustomTable();
        //タイトル設定
        //　起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】
        //電磁開閉器（MC）
        table.secTitle = secTitle;

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (startupCircuList.size() == 0) return table;

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報
        //ヘッダ　設定
        //１行目のヘッダー設定   
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('方式', null, 2,false,false));//方式
        headerRow1.add(setCell('モータ容量', 2, null,false,false));//モータ容量
        if (secTitle == '電磁開閉器（MC）') {
            headerRow1.add(setCell('電磁開閉器・コンダクタ(MC)', 3, null,false,false));

        } else if (secTitle=='起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】') {
            headerRow1.add(setCell('遮断機（MCCB)・電磁開閉器（MC)・補助リレー・タイマー', null, 2,false,false));
            headerRow1.add(setCell('価格', null, 2,false,false));//
            headerRow1.add(setCell('数量', null, 2,false,false));//価格
        }
        BodyRow hBodyRow1 = new BodyRow();
        hBodyRow1.cellList = headerRow1;
        headerList.add(hBodyRow1);

        //２行目のヘッダー設定   
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow2.add(setCell('200V', null, null,false,false));//200V
        headerRow2.add(setCell('400V', null, null,false,false));//400V
        if (secTitle=='電磁開閉器（MC）') {
            headerRow2.add(setCell('型名', null, null,false,false));
            headerRow2.add(setCell('価格', null, null,false,false));//
            headerRow2.add(setCell('数量', null, null,false,false));//価格
        }
        BodyRow hBodyRow2 = new BodyRow();
        hBodyRow2.cellList = headerRow2;
        headerList.add(hBodyRow2);
        table.headerList = headerList;

        //キーを設定
        Map<String, List<String>> methodMap = new Map<String,List<String>>();
        Map<String, PricingTable__c> dataMap = new Map<String,PricingTable__c>();
        for (PricingTable__c tmp : startupCircuList) {
            //方式
            String method,motor200,motor400;
            if (secTitle == '電磁開閉器（MC）') {
                method = tmp.Name3__c;
                motor200 = tmp.Name4__c;
                motor400 = tmp.Name5__c;
            } else if (secTitle=='起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】') {
                method = tmp.Name1__c;
                motor200 = tmp.Name3__c;
                motor400 = tmp.Name4__c;
                //方式　編集
                method = method.replace('起動回路','');
                Integer len1 = method.length();
                method= method.substring(1, len1-1);//「（）」を除外
            }


            motor200 = motor200.substring(4);//先頭「200v」を除外
            motor400 = motor400.substring(4);//先頭「400v」を除外

            if (methodMap.get(method)==null) methodMap.put(method, new List<String>());
            methodMap.get(method).add(motor200 + '@@' + motor400);
            //キーでデータを設定
            dataMap.put(method+motor200+motor400,tmp);
        }

        //ボディー情報を設定
        for(String name1 : methodMap.keySet()){
            List<String> name34List = methodMap.get(name1);

            Boolean isFirst = true;
            for (String name34:name34List) {
                //一行のデータ
                BodyRow row = new BodyRow();
                List<BodyCell> bodyRow = new List<BodyCell>();

                String name3 = name34.split('@@').get(0);
                String name4 = name34.split('@@').get(1);

                if (isFirst) {
                    //方式 セルの設定
                    bodyRow.add(setCell(name1, null, name34List.size(), false, false));
                    isFirst = false;
                }
                //モータ容量 200V セルの設定
                bodyRow.add(setCell(name3, null,null, false, false));
                //モータ容量 400V セルの設定
                bodyRow.add(setCell(name4, null,null, false, false));

                PricingTable__c price = dataMap.get(name1+name3+name4);

                //遮断機（MCCB)・電磁開閉器（MC)・補助リレー・タイマー
                bodyRow.add(setCell(price.Name2__c, null,null, false, false));
                //価格、数量
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
        table.bodyList = bodyList;
        //注＊　の設定
        List<String> noteList = System.Label.Annotation_ElectromagneticSwitch.split('\r\n');
        table.noteList = noteList;
        return table;
    }

    /**
     * 指定条件により明細価格表を取得
     * 
     * @param recordType レコードタイプ
     * @param major      大分類
     * @param bu    部　条件
     * @param customSql 個別条件指定
     * @param customOrderBy 個別ソート順
     */
    private static List<PricingTable__c> getDetailPriceTable(String recordType, 
                                                             String major, 
                                                             String bu, 
                                                             String customSql, 
                                                             String customOrderBy){
        // セットした条件で価格表のデータを検索する。
        String strSql =  'SELECT '
                            + ' Id, '
                            + ' DisplayName__c, '
                            + ' Name1__c, '
                            + ' Name2__c, '
                            + ' Name3__c, '
                            + ' Name4__c, '
                            + ' Name5__c, '
                            + ' Name6__c, '
                            + ' Name7__c, '
                            + ' Name8__c, '
                            + ' Name9__c, '
                            + ' Name10__c, '
                            + ' Price__c, '
                            + ' UniqueKey__c, '
                            + ' CategoryName__c '
                        + '  FROM PricingTable__c '
                        + '  WHERE '
                            // レコードタイプ「明細」or「筐体」
                            + '      RecordType.DeveloperName = :recordType  '
                            //+ '  AND MajorClassificationName__c = :major '
                            //”施設”BUが「S」/ ”水環境”or"官需"の場合 BUが「M」'
                            + '  AND BU__c = :bu  ';
        
        if (String.isNotBlank(major)) strSql +=  '  AND MajorClassificationName__c = :major ';//大分類条件設定
        if (String.isNotBlank(customSql)) strSql +=  customSql;//個別条件指定
        //ソート
        if (String.isNotBlank(customOrderBy)){
            strSql += '   ORDER BY ' + customOrderBy; //ソート順指定
        } else {
            strSql += '   ORDER BY  RECNo__c ';//デフォルトの設定
        }
        //価格表を検索する
        return Database.query(strSql);
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

    @AuraEnabled(Cacheable=false)
    Public static String submitDetailsForFieldBoard(String deviceId,
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
                                                AND MajorClassificationName__c = '低圧・現場・リレー・ACB盤'
                                                AND MinorClassificationName__c IN ('低圧盤','現場盤')
                                            )
                                            OR(DetailCategory__c='明細'
                                                AND MajorClassificationName__c IN ('共通機器','低圧・現場・リレー・ACB盤','計装機器')
                                                AND MinorClassificationName__c IN ('','現場盤','計装盤')
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

                        if(optDetail.DisplayName__c.contains('配線材料費')){
                            System.debug('配線材料費' + opt.Price);
                            // WC単価_CreditWC__c
                            optObj.CreditWC__c = (opt.Price!=null?opt.Price/2/opt.Quantity:null);//画面入力.wc単価
                            // 単価_UnitPrice__c
                            optObj.UnitPrice__c = opt.Price;//画面入力.単価
                        }else {
                            // WC単価_CreditWC__c_価格表.WC単価
                            optObj.CreditWC__c = optDetail.WC__c;
                            // 単価_UnitPrice__c_価格表.単価
                            optObj.UnitPrice__c = optDetail.Price__c;//価格表.単価
                        }


                        // WC係数_WcCoefficient__c_""
                        optObj.WcCoefficient__c = null;
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
}