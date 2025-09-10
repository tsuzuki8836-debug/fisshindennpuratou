public with sharing class DetailsInputForRelayBoardController {
    private static final String recordTypeChassis = 'Chassis';//筐体
    private static final String recordTypeDetail = 'Detail';//明細
    private static final String majorClassification = '低圧・現場・リレー・ACB盤';
    private static final String minorClassification = '低圧盤';
    private static final String majorDetail = '共通機器';

    public class screenInfo{
        //初期表示(選択内容)
        String inputedId {get;set;}
        Decimal inputedPrice {get;set;}//筐体　単価
        Decimal displayTotal {get;set;} //合計金額
        String displayCondition {get;set;}//選択仕様

        //検索条件
        String installationLocation {get;set;}//筐体仕様
        String doorSpecifications {get;set;}//筐体種類
        String housingSpecifications {get; set;}//扉仕様

        //メイン表（低圧配電盤筐体一覧）
        //筐体の表を高さ(H)毎に別の表に分ける対応
        List<ClassicTable> classicTables {get; set;}

        CustomTable auxiliaryRelayTable{get;set;}//補助継電器盤標準筐体
        CustomTable installEquipTypeTable{get;set;}//取付器具類
    }

    //筐体テーブル
    //筐体の表を高さ(H)毎に別の表に分ける対応
    public class ClassicTable {
        Boolean isLowVoltagenodata  {get;set;}
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
     * 明細入力B(明細入力B_低圧配電盤) 表示データを取得
     *
     * @param isInit 初期フラグ
     * @param deviceId 見積項目Id
     * @param installationLocation 設置場所（屋内／屋外）
     * @param housingSpecifications 筐体仕様（自立SS／自立SUS）
     * @param doorSpecifications 扉仕様（1枚扉／観音開き）
     *
     */
    public static string getInitScreenInfo(Boolean isInit,
                                            String deviceId,
                                            String installationLocation,
                                            String housingSpecifications,
                                            String doorSpecifications){

        ScreenInfo info = new ScreenInfo();
        String bu ='';//BU
        Detail__c currentDetail;
        Map<String,Detail__c> currentDetails = new Map<String,Detail__c>();
        String frequency;//周波数
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
            bu = device.Quote__r.RecordType.DeveloperName == 'Facility' ? 'S' : 'M';
            frequency =  device.Quote__r.PowerFrequency__c;
            if (device.Details__r!=null
                && device.Details__r.size()>0) {
                for (Detail__c tmp :device.Details__r) {
                    if (tmp.DetailCategory__c == '筐体'
                        && String.isNotBlank(tmp.PricingTableUniqueKey__c)
                        && tmp.PricingTableUniqueKey__c.contains('低圧・現場・リレー・ACB盤低圧盤')) {
                        if ((String.valueOf(tmp.Name3__c).contains('700') && String.valueOf(tmp.Name4__c).contains('2,300') && String.valueOf(tmp.Name5__c).contains('600')) 
                            ||(String.valueOf(tmp.Name3__c).contains('800') && String.valueOf(tmp.Name4__c).contains('2,300') && String.valueOf(tmp.Name5__c).contains('600'))){
                                currentDetails.put(tmp.PricingTableUniqueKey__c,tmp);
                            }else {
                                currentDetail = tmp;//筐体の登録データ
                            }
                    }else {
                        detailsMap.put(tmp.PricingTableUniqueKey__c, tmp);
                    }
                }
            }
        }

        /*
         検索条件をセットする。
         ・元のデータが有る場合は、もっとの条件をセットする。
         ・元のデータが無い場合は、画面でセットされた条件をセットする。
        */
        if (isInit && currentDetail != null) {
            installationLocation = currentDetail.Name1__c;
            housingSpecifications = currentDetail.Name2__c;
            doorSpecifications = '1枚扉';
            if (currentDetail.Name6__c=='観音開き')doorSpecifications=currentDetail.Name6__c;
        }
        info.installationLocation = installationLocation;
        info.housingSpecifications = housingSpecifications;
        info.doorSpecifications = doorSpecifications;

        //名称1「屋内／屋外」（見積.レコードタイプ＝”水環境”or"官需"の場合は「低圧盤　屋内／屋外」）
        String conInstallationLocation = ((bu=='M' && !(isInit && currentDetail != null))?'低圧盤　'+installationLocation:installationLocation);
        System.debug('conInstallationLocation=='+conInstallationLocation);
        //名称2「自立SS／自立SUS」
        String conHousingSpecifications = housingSpecifications;
        //「観音開き」の場合 名称6が「観音開き」、「1枚扉」の場合　名称6が空欄
        String conDoorSpecifications = (doorSpecifications=='観音開き'?doorSpecifications:'');

        // セットした条件で補助継電器盤標準筐体のデータを検索する。
        List<PricingTable__c> auxiliaryRelaychassisList = [SELECT
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
                                                            MinorClassificationName__c = :minorClassification AND
                                                            //”施設”BUが「S」/ ”水環境”or"官需"の場合 BUが「M」
                                                            BU__c = :bu AND
                                                            //名称1「屋内／屋外」（見積.レコードタイプ＝”水環境”or"官需"の場合は「低圧盤　屋内／屋外」）
                                                            Name1__c = :conInstallationLocation AND
                                                            //名称2「自立SS／自立SUS」
                                                            Name2__c = :conHousingSpecifications AND
                                                            //名称3「800W」
                                                            (Name3__c =: '800W' OR
                                                            Name3__c =: 'W800' OR
                                                            Name3__c =: '700W' OR
                                                            Name3__c =: 'W700') AND
                                                            //名称4「2300H」
                                                            (Name4__c =: '2,300H' OR
                                                            Name4__c =: 'H2,300') AND
                                                            //名称5「600D」
                                                            (Name5__c =: '600D' OR
                                                            Name5__c =: 'D600') AND
                                                            //「観音開き」の場合 名称6が「観音開き」、「1枚扉」の場合　名称6が空欄
                                                            Name6__c = :conDoorSpecifications
                                                        ORDER BY
                                                        RECNo__c DESC
                                                    ];
        System.debug('auxiliaryRelaychassisList=='+auxiliaryRelaychassisList);

        // セットした条件で取付器具類のデータを検索する。
        List<PricingTable__c> installEquipTypeList = [SELECT
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
                                                            DisplayName__c,
                                                            RECNOforRelayBoardB_Attachment__c,
                                                            RECNOforRelayBoard__c,
                                                            MasterCode__c,
                                                            DetailRecordDisplayNumberText__c
                                                        FROM PricingTable__c
                                                        WHERE
                                                            // レコードタイプ「明細」かつ、大分類名「共通機器」
                                                            RecordType.DeveloperName = 'Detail' AND
                                                            MajorClassificationName__c = :majorDetail AND
                                                            //”施設”BUが「S」/ ”水環境”or"官需"の場合 BUが「M」
                                                            BU__c = :bu AND
                                                            //リレー盤B画面用RECNOがnull以外
                                                            RECNOforRelayBoardB_Attachment__c != null
                                                        ORDER BY
                                                        RECNOforRelayBoardB_Attachment__c
                                                    ];

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> lowVoltagechassisList = [SELECT
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
        if (lowVoltageChassisList!=null && lowVoltageChassisList.size()>=0) {

            //キーを設定
            for (PricingTable__c chassis : lowVoltagechassisList) {
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
                    tbl.isLowVoltagenodata = true;
                    continue;
                }
                tbl.isLowVoltagenodata = false;
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
                    else {
                        //非表示セル
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
                                if ((String.valueOf(name3).equals('700') && String.valueOf(name4).equals('2300') && String.valueOf(name5).equals('600')) 
                                ||(String.valueOf(name3).equals('800') && String.valueOf(name4).equals('2300') && String.valueOf(name5).equals('600'))) {
                                    bodyRow.add(setCell('―',null,null,false,false));//入力セル
                                }else {
                                    //既存データの設定
                                    if (currentDetail!=null
                                    && currentDetail.PricingTableUniqueKey__c == cellData.UniqueKey__c){
                                    info.inputedId = cellData.Id;//チェックされた値
                                    info.inputedprice = price;//筐体
                                    info.displayTotal = price;//単価
                                    info.displayCondition = name;//選択仕様
                                    cellItem.put('isChecked',true);
                                    }else {
                                    cellItem.put('isChecked',false);
                                    }
                                    bodyRow.add(setCell(cellItem,null,null,true,false));//入力セル
                                }
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
        CustomTable auxiliaryRelayTable = setauxiliaryRelayTable(auxiliaryRelaychassisList, currentDetails);
        info.auxiliaryRelayTable = auxiliaryRelayTable;

        CustomTable installEquipTypeTable = setinstallEquipTypeTable(installEquipTypeList, detailsMap);
        info.installEquipTypeTable = installEquipTypeTable;

        return JSON.serialize(info);
    }

    /**
     * 明細入力B(明細入力B_リレー盤) 表示データを取得
     *
     * @param isInit 初期フラグ
     * @param deviceId 見積項目Id
     * @param installationLocation 設置場所（屋内／屋外）
     * @param housingSpecifications 筐体仕様（自立SS／自立SUS）
     * @param doorSpecifications 扉仕様（1枚扉／観音開き）
     * @param auxiliaryRelaychassisList 補助継電器盤標準筐体
     *
     */

    private static CustomTable setauxiliaryRelayTable(List<PricingTable__c> auxiliaryRelaychassisList,
                                                        Map<String,Detail__c> currentDetails){

        CustomTable auxiliaryRelayTable =new CustomTable();
        String titleName = '低圧盤 筐体価格';//名称

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報

        List<BodyCell> headerCell = new List<BodyCell>();//ヘッダ　設定
        headerCell.add(setCell('名称', null, null, false,false));
        headerCell.add(setCell('寸法', null, null, false,false));
        headerCell.add(setCell('価格', null, null, false,false));
        headerCell.add(setCell('数量', null, null, false,false));

        BodyRow headerRow = new BodyRow();
        headerRow.cellList = headerCell;
        headerList.add(headerRow);

        for (PricingTable__c item : auxiliaryRelaychassisList) {
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            String name345 = item.Name3__c + '×' + item.Name4__c + '×' + item.Name5__c;
            bodyRow.add(setCell(titleName, null, null, false,false));
            bodyRow.add(setCell(name345, null, null, false,false));
            bodyRow.add(setCell(item.Price__c.format(), null, null, false,false));
            bodyRow.add(setCell(getQuantityObject(item,currentDetails), null, null, true,false));

            row.cellList = bodyRow;
            bodyList.add(row);
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        auxiliaryRelayTable.secTitle ='補助継電器盤標準筐体';
        auxiliaryRelayTable.comment = '';//コメント
        auxiliaryRelayTable.headerList = headerList;//ヘッダ
        auxiliaryRelayTable.bodyList = bodyList;//ボディー
        auxiliaryRelayTable.noteList = noteList;//注＊

        return auxiliaryRelayTable;
    }

    /**
     * 明細入力B(明細入力B_リレー盤) 表示データを取得
     *
     * @param installEquipTypeList 補助継電器盤標準筐体
     *
     */
    //取付器具類
    private static CustomTable setinstallEquipTypeTable(List<PricingTable__c> installEquipTypeList,
                                                        Map<String, Detail__c> detailsMap){
        CustomTable installEquipTypeTable =new CustomTable();
        system.debug('installEquipTypeList='+installEquipTypeList);

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報

        List<BodyCell> headerCell = new List<BodyCell>();//ヘッダ　設定
        headerCell.add(setCell('機器名', null, null, false,false));
        headerCell.add(setCell('WC', null, null, false,false));
        headerCell.add(setCell('価格', null, null, false,false));
        headerCell.add(setCell('数量', null, null, false,false));

        BodyRow headerRow = new BodyRow();
        headerRow.cellList = headerCell;
        headerList.add(headerRow);

        for (PricingTable__c item : installEquipTypeList) {
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            String displayName;
            displayName = item.DisplayName__c;
            Decimal decPrice = (item.Price__c==null?0:item.Price__c);
            bodyRow.add(setCell(displayName, null, null, false,false));
            if(item.DisplayName__c.contains('配線材料費')){
                QuantityObject quantityWcObj = new QuantityObject();//wcセル
                QuantityObject quantityPriObj = new QuantityObject();//数量セル
                quantityWcObj.Id = item.Id;//価格表Id
                quantityPriObj.Id = item.Id;//価格表Id
                quantityWcObj.Price = null;
                quantityPriObj.Price = null;
                quantityPriObj.Quantity = null;
                //上記以外 設定なし
                if (detailsMap!=null && detailsMap.size()>0) {
                    Detail__c detail = detailsMap.get(item.UniqueKey__c);
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
                bodyRow.add(setCell(getQuantityObject(item, detailsMap), null, null, true, false));//数量
            }

            row.cellList = bodyRow;
            bodyList.add(row);
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        installEquipTypeTable.secTitle ='取付器具類';
        installEquipTypeTable.comment = '';//コメント
        installEquipTypeTable.headerList = headerList;//ヘッダ
        installEquipTypeTable.bodyList = bodyList;//ボディー
        installEquipTypeTable.noteList = noteList;//注＊
        System.debug('installEquipTypeTable='+installEquipTypeTable);

        return installEquipTypeTable;
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

    @AuraEnabled(Cacheable=false)
    Public static String submitDetailsForRelayBoard(String deviceId,
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
                                                AND MinorClassificationName__c = '低圧盤'
                                            )
                                            OR(DetailCategory__c='明細'
                                                AND MajorClassificationName__c ='共通機器'
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
            //登録用　数量入力を作成 
            if (optRecords!=null && optRecords.size()>0) {
                for(QuantityObject opt : optRecords) {
                    if (opt.Quantity != null && opt.Quantity > 0) {
                        Detail__c optObj = new Detail__c();
                        PricingTable__c optDetail = priceMap.get(opt.Id);
                        PricingTable__c recordWithRecordType = [SELECT Id, RecordType.Name FROM PricingTable__c WHERE Id =: optDetail.Id];
                        String recordTypeName = recordWithRecordType.RecordType.Name;
                        System.debug('recordTypeName= '+ recordTypeName);
                        if (recordTypeName == '筐体') {
                            // 見積項目_Device__c_明細入力画面を開いた見積項目.ID
                            optObj.Device__c = deviceId;
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
                            optObj.UnitPrice__c = optDetail.Price__c;
                            // 単価係数_"UnitPriceCoefficient__c_"_""
                            optObj.UnitPriceCoefficient__c = null;
                            // 単位重量_CreditWeight__c_価格表.単位重量
                            optObj.CreditWeight__c = optDetail.Weight__c;
                            // 明細種別_DetailCategory__c_"⑥の表でチェックした筐体を保存する場合：""筐体""
                            optObj.DetailCategory__c='筐体';//"筐体" "明細"
                            // 提供単価_ProvisionUnitPrice__c_""
                            optObj.ProvisionUnitPrice__c = null;
                            // 数量_Quantity__c_"画面に入力された値。（✓の場合は「1」）
                            optObj.Quantity__c = opt.Quantity;
                            // WC算出レート_WcCalculationRate__c_"⑥の表でチェックした筐体を保存する場合：0
                            optObj.WcCalculationRate__c = 0;
                            // 備考_Note__c_価格表.備考
                            optObj.Note__c = optDetail.Note__c;
                            // 表示用テキスト_Name_価格表.表示用テキスト
                            optObj.Name = optDetail.DisplayName__c;//表示用テキスト
                            // 名称5_Name5__c_価格表.名称5
                            // 名称6_Name6__c_価格表.名称6
                            // 名称7_Name7__c_価格表.名称7
                            // 名称8_Name8__c_価格表.名称8
                            // 名称9_Name9__c_価格表.名称9
                            // 名称10_Name10__c_価格表.名称10
                            optObj.Name5__c = optDetail.Name5__c;//名称5
                            optObj.Name6__c = optDetail.Name6__c;//名称6
                            optObj.Name7__c = optDetail.Name7__c;//名称7
                            optObj.Name8__c = optDetail.Name8__c;//名称8
                            optObj.Name9__c = optDetail.Name9__c;//名称9
                            optObj.Name10__c = optDetail.Name10__c;//名称10
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
                            optObj.MasterCode__c = optDetail.MasterCode__c;//RECNO
                            optObj.DetailRecordDisplayNumberText__c = optDetail.DetailRecordDisplayNumberText__c;//明細レコード表示順
                            System.debug(optObj);
                            insList.add(optObj);
                        }else {
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
                            Note__c,RECNOforRelayBoardB_Attachment__c,MasterCode__c,DetailRecordDisplayNumberText__c
                        FROM PricingTable__c
                        WHERE Id =:ids
                    ];
        for(PricingTable__c tmp : chassis){
            rtnMap.put(tmp.Id,tmp);
        }
        return rtnMap;
    }
}