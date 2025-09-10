/**
 * 明細入力B(明細入力B_低圧配電盤)画面のコントローラー
 * 
 * @author xu.ll 2023/07/04
 * @version 1.0
 */
public with sharing class DetailsInputForLowVoltageController {
    private static final String recordTypeChassis = 'Chassis';//筐体
    private static final String recordTypeDetail = 'Detail';//明細
    private static final String majorClassification = '低圧・現場・リレー・ACB盤';
    private static final String minorClassification = '低圧盤';
    private static final String majorDetail = '共通機器';

    public class ScreenInfo {

        //初期表示(選択内容)
        String inputedId {get;set;}
        Decimal inputedPrice {get;set;} //合計金額
        String displayCondition {get;set;}//選択仕様
        
        //検索条件
        String installationLocation {get;set;}
        String doorSpecifications {get;set;}
        String housingSpecifications {get; set;}

        //筐体
        //筐体の表を高さ(H)毎に別の表に分ける対応
        List<ClassicTable> classicTables {get; set;}

        public CustomTable mccbTable {get;set;}//配線用遮断器価格 （MCCB・ELB）
        public CustomTable  mccbTableHas {get;set;}//配線用遮断器価格 （MCCB・ELB）操作あり
        public CustomTable lowVoltageCTPTTable {get;set;}//低圧CT・PT、保護継電器類
        public CustomTable indicatorTypeTable{get;set;} //指示計類
        public CustomTable equipInstallFeeTable{get;set;} //計装・機器取付費
        public CustomTable installEquipTypeTable{get;set;} //取付器具類
        public CustomTable transformerCTTable{get;set;} //計器用変流器 ＣＴ(低圧)
        public CustomTable twoElectroContactorTable{get;set;} //双投式電磁接触器 
        public CustomTable startupCircuitTable{get;set;} //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
        public CustomTable electroSwitchTable{get;set;} // 電磁開閉器（MC）
        public CustomTable lowVoltageCROilTable{get;set;} // 低圧コンデンサ・リアクトル　油入
        public CustomTable transformerOilTable{get;set;} // 変圧器　油入り自冷
        public CustomTable transformerMoldTable{get;set;} // 変圧器　モールド
        public CustomTable transformerLightingTable{get;set;} // 変圧器（照明・建築付帯用）
    }
    //筐体テーブル
    //筐体の表を高さ(H)毎に別の表に分ける対応
    public class ClassicTable {
        Boolean isNodata  {get;set;}
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
                        (SELECT Id,Name,UnitPrice__c,PricingTableUniqueKey__c,DetailCategory__c,Quantity__c,
                                Name1__c,Name2__c,Name3__c,Name4__c,Name5__c,Name6__c,Name7__c,Name8__c,Name9__c,Name10__c
                            FROM Details__r)
                        FROM Device__c WHERE Id =:deviceId LIMIT 1];

            // 見積のレコードタイプ確認し、BUの条件をセットする。
            bu = device.Quote__r.RecordType.DeveloperName == 'Facility' ? 'S' : 'M';
            category =  device.Quote__r.PowerFrequency__c;
            if (device.Details__r!=null && device.Details__r.size()>0) {
                for (Detail__c tmp :device.Details__r) {
                    if (tmp.DetailCategory__c == '筐体' 
                        && String.isNotBlank(tmp.PricingTableUniqueKey__c)
                        && tmp.PricingTableUniqueKey__c.contains('低圧・現場・リレー・ACB盤低圧盤')) {
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
            installationLocation = currentDetail.Name1__c;
            installationLocation = installationLocation.replace('低圧盤　','');
            housingSpecifications = currentDetail.Name2__c;
            doorSpecifications = '1枚扉';
            if (currentDetail.Name6__c=='観音開き')doorSpecifications=currentDetail.Name6__c;
        }
        info.installationLocation = installationLocation;
        info.housingSpecifications = housingSpecifications;
        info.doorSpecifications = doorSpecifications;
        
        //名称1「屋内／屋外」（見積.レコードタイプ＝”水環境”or"官需"の場合は「低圧盤　屋内／屋外」）
        String conInstallationLocation = ((bu=='M')?'低圧盤　'+installationLocation:installationLocation);
        //名称2「自立SS／自立SUS」
        String conHousingSpecifications = housingSpecifications;
        //「観音開き」の場合 名称6が「観音開き」、「1枚扉」の場合　名称6が空欄
        String conDoorSpecifications = (doorSpecifications=='観音開き'?doorSpecifications:'');

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> chassisList = [SELECT 
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
                                                MasterCode__c,//マスタコード
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
        if (chassisList!=null && chassisList.size()>0) {
            //     info.isNodata = true;
            // }
            // else {
            // Set<Integer> headerCellData = new Set<Integer>();//ソート用
            for (PricingTable__c chassis : chassisList) {
                String tmpName3 = chassis.Name3__c;
                tmpName3 = tmpName3.replace('W', '').replace(',', '');//数字以外を除外
                String tmpName4 = chassis.Name4__c;
                tmpName4 = tmpName4.replace('H', '').replace(',', '');//数字以外を除外
                String tmpName5 = chassis.Name5__c;
                tmpName5 = tmpName5.replace('D', '').replace(',', '');//数字以外を除外
                String key = tmpName3 + tmpName4 +tmpName5;
                //横　のヘッダー
                // headerCellData.add(Integer.valueOf(tmpName5));
    
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
                    tbl.isNodata = true;
                    continue;
                }
                tbl.isNodata = false;

                //高さ(H)毎にヘッダ設定
                Set<Integer> headerCellData = new Set<Integer>();//ソート用
                for (PricingTable__c chassis : chassisList) {
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
                List<Integer> name3List = new List<Integer>(name3Set);
                name3List.sort();
                
                //Hセルであるかどうか
                Boolean isFirst = true;
    
                for (Integer name3 : name3List) {
                    //一行のデータ
                    List<BodyCell> bodyRow = new List<BodyCell>();
                    if (isFirst) {
                        //H　セルの設定
                        bodyRow.add(setCell(name4.format(), null, name3List.size(), false, true));
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

        //配線用遮断器価格 （MCCB・ELB）
        // info.mccbTable = setMccbTable(bu, detailsMap);
        List<CustomTable> tbls = setMccbTable(bu, detailsMap);
        if(tbls!=null&&tbls.size()>0)info.mccbTable = tbls.get(0);
        if(tbls!=null&&tbls.size()>1)info.mccbTableHas = tbls.get(1);

        //低圧CT・PT、保護継電器類
        List<String> ctptList = new List<String>{'品　名','価格','数量'};
        info.lowVoltageCTPTTable = setCommonEquipment('低圧CT・PT、保護継電器類',ctptList, bu, detailsMap);
        //指示計類
        List<String> indicatorList = new List<String>{'機 器 名','価格','数量'};
        info.indicatorTypeTable = setCommonEquipment('指示計類',indicatorList, bu, detailsMap);
        //計装・機器取付費
        info.equipInstallFeeTable = setCommonEquipment('計装・機器取付費',null, bu, detailsMap);
        //取付器具類
        info.installEquipTypeTable = setCommonEquipment('取付器具類',indicatorList, bu, detailsMap);
        //計器用変流器 ＣＴ(低圧)
        //・見積.レコードタイプ＝”水環境”or"官需"の場合、この表は表示しない
        if (bu=='S') {
            info.transformerCTTable = setCommonEquipment('計器用変流器 ＣＴ(低圧)',null, bu, detailsMap);
        }

        //双投式電磁接触器 
        info.twoElectroContactorTable = setTwoElectroContactorTable(bu, detailsMap);

        //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】
        // レコードタイプ＝”施設"の場合、この表は表示しない
        if (bu!='S') {
            info.startupCircuitTable = setStartupCircuitTable('起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】', bu, detailsMap);

        }
        //電磁開閉器（MC）
        info.electroSwitchTable = setStartupCircuitTable('電磁開閉器（MC）', bu, detailsMap);

        //低圧コンデンサ・リアクトル　油入
        //レコードタイプ＝”施設"の場合、この表は表示しない
        if (bu!='S') {
            info.lowVoltageCROilTable = setLowVoltageCROilTable(category, bu, detailsMap);
        }

        //変圧器　油入り自冷
        //・見積.レコードタイプ＝”水環境”or"官需"の場合、この表は表示しない
        if (bu=='S') {
            info.transformerOilTable = setCommonTransformer('変圧器　油入り自冷','油','油入', category, bu, detailsMap);
        }
        //変圧器　モールド
        info.transformerMoldTable = setCommonTransformer('変圧器　モールド', 'モールド','モールド', category, bu, detailsMap);

        //変圧器（照明・建築付帯用）
        info.transformerLightingTable = setTransformerLightingTable(bu, detailsMap);
        return JSON.serialize(info);
    }

    //変圧器（照明・建築付帯用）
    private static customTable setTransformerLightingTable(String bu, Map<String, Detail__c> detailsMap){
        // レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「照明・建築付帯用トランス」
        String customSql = ' AND  Name1__c = \'照明・建築付帯用トランス\'';

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> transformerLightingList = getDetailPriceTable(recordTypeDetail,majorDetail,bu, customSql, null);

        CustomTable table = new CustomTable();
        //タイトル設定　変圧器（照明・建築付帯用）
        table.secTitle = '変圧器（照明・建築付帯用）';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (transformerLightingList.size() == 0) return table;

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報

        //キーを設定
        Map<String, PricingTable__c> dataMap = new Map<String, PricingTable__c>();
        Set<String> name3Set = new Set<String>();
        Set<String> name4Set = new Set<String>();
        for (PricingTable__c tmp : transformerLightingList) {
            String name3 = tmp.Name3__c;
            String name4 = tmp.Name4__c;
            name3Set.add(name3);
            name4Set.add(name4);
            String key = name3+'@@'+name4;
            if (dataMap.get(key)==null) dataMap.put(key, tmp);   
        }
        //ヘッダ　設定
        // 容量   単相		    三相	
    	//      価格	数量	価格	数量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        List<BodyCell> headerRow2 = new List<BodyCell>();    
        headerRow1.add(setCell('容量', null, 2,false,false));//容量
        for(String name4 : name4Set){ 
            headerRow1.add(setCell(name4, 2, null,false,false));//単相,三相
            headerRow2.add(setCell('価格', null, null,false,false));//２行目の価格
            headerRow2.add(setCell('数量', null, null,false,false));//２行目の数量
        }
        BodyRow hBodyRow1 = new BodyRow();
        hBodyRow1.cellList = headerRow1;
        headerList.add(hBodyRow1);//１行目
        BodyRow hBodyRow2 = new BodyRow();
        hBodyRow2.cellList = headerRow2;
        headerList.add(hBodyRow2);//２行目
        table.headerList = headerList;

        // ボディー設定
        for(String name3 : name3Set){
            //一行のデータ
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow = new List<BodyCell>();
            bodyRow.add(setCell(name3, null, null,false,false));//容量
            for(String name4 : name4Set){
                String key = name3+'@@'+name4;
                PricingTable__c price = dataMap.get(key);
                //価格、数量
                if (price != null) {
                    Decimal decPrice = (price.Price__c==null?0:price.Price__c);
                    bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                    bodyRow.add(setCell(getQuantityObject(price, detailsMap), null, null, true, false));//数量
                } else {
                    bodyRow.add(setCell('―',null,null,false,true));//価格セル
                    bodyRow.add(setCell('',null,null,false,false));//空白
                }
            }
             row.cellList = bodyRow;
             bodyList.add(row);
        }
        table.bodyList = bodyList;
        table.comment=' （単相３線、1次電圧400V・200V、 2次電圧100V)';
        return table;
    }

    //配線用遮断器価格 （MCCB・ELB）
    private static List<CustomTable> setMccbTable(String bu, Map<String, Detail__c> detailsMap){

        // ・価格表マスタから以下の条件で取得し、表形式で表示する。
        // 　・レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「配線用遮断器」を含む
        String customSql = ' AND  Name1__c like \'%配線用遮断器%\'';

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> mccbList = getDetailPriceTable(recordTypeDetail,majorDetail,bu, customSql, null);


        List<CustomTable> tables = new List<CustomTable>();
        CustomTable table = new CustomTable();
        CustomTable tableHas = new CustomTable();//配線用遮断器価格 （MCCB・ELB）_MCCB電動操作あり
        //タイトル設定　配線用遮断器価格 （MCCB・ELB）
        table.secTitle = '配線用遮断器価格 （MCCB・ELB）電動操作なし';
        tableHas.secTitle = '配線用遮断器価格 （MCCB・ELB）電動操作あり';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        // if (mccbList.size() == 0) return table;
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
            List<Integer> name3List = new List<Integer>(name3Set);
            name3List.sort();
            //MCCB電動操作 セルであるかどうか
            Boolean isFirst = true;
            // af 
            for (Integer name3 : name3List) {

                BodyRow row = new BodyRow();
                List<BodyCell> bodyRow  = new List<BodyCell>();
                // //１回のみ設定
                // if (isFirst) {
                //     bodyRow.add(setCell(key, null, name3List.size(), false, false));
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

    //変圧器　油入り自冷
    //変圧器　モールド
    private static CustomTable setCommonTransformer(String secTitle,String conName1, String conName5, 
                                                    String categoryName, String bu, Map<String, Detail__c> detailsMap){
        String recordType,major,minor,name1,customSql;
        // レコードタイプ＝”施設”の場合
        // レコードタイプ「筐体」かつ、大分類名「変圧器」かつ、小分類名「高圧変圧器」かつ、
        // 種類名＝見積.電源周波数かつ、名称1「油」かつ、（名称4「210V」or名称4「420V」or「440V」）
        if (bu=='S') {
            recordType = recordTypeChassis;
            major = '変圧器';
            minor = '高圧変圧器';
            name1 = conName1;
            customSql = ' AND Name4__c IN (\'210V\',\'420V\',\'440V\') ';

        // レコードタイプ＝”水環境”or"官需"の場合
        // レコードタイプ「明細」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤」かつ、
        // 種類名＝見積.電源周波数かつ、名称1「低圧変圧器」かつ、名称5「油入」
        }else if (bu=='M'){
            recordType = recordTypeDetail;
            major = majorClassification;
            minor = minorClassification;
            name1 = '低圧変圧器';
            customSql = ' AND Name5__c =:conName5 ';
        }

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
                            // レコードタイプ
                            + '      RecordType.DeveloperName = :recordType  '
                            + '  AND MajorClassificationName__c = :major '
                            + '  AND MinorClassificationName__c = :minor '
                            //”施設”BUが「S」/ ”水環境”or"官需"の場合 BUが「M」'
                            + '  AND BU__c = :bu  '
                            + '  AND CategoryName__c = :categoryName '
                            + '  AND Name1__c = :name1 ';
        if (String.isNotBlank(customSql)) strSql +=  customSql;//個別条件指定
        //ソートの設定
        strSql += '   ORDER BY  RECNo__c ';
        //価格表を検索する
        List<PricingTable__c> priceList = Database.query(strSql);

        CustomTable table = new CustomTable();
        //タイトル設定　例：変圧器　油入り自冷　　//変圧器　モールド
        table.secTitle = secTitle;

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (priceList.size() == 0) return table;

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //キーを設定
        // 仕様  specification
        Map<String, Set<String>> specMap = new Map<String, Set<String>>{
                                                'スコット'=> new Set<String>(),
                                                '低圧／低圧'=>new Set<String>()
                                                };

        //容量
        Set<String> capacitySet = new Set<String>();
        //キーでデータを保持
        Map<String, PricingTable__c> dataMap = new Map<String, PricingTable__c>();
        for(PricingTable__c tmp : priceList) {
            // 仕   様 specification
            // 相   数 phasesNumb
            // 一次電圧 firstVoltage
            // 二次電圧 secVoltage
            // 容量 capacity
            String specification,capacity,phasesNumb,firstVoltage,secVoltage;
            if (bu=='S') {
                specification =  tmp.Name9__c;
                capacity = tmp.Name6__c;
                phasesNumb=tmp.Name3__c;
                firstVoltage=tmp.Name4__c;
                secVoltage=tmp.Name5__c;
            }else if (bu=='M'){
                specification =  tmp.Name6__c;
                capacity = tmp.Name4__c;
                phasesNumb=tmp.Name6__c;
                firstVoltage=tmp.Name2__c;
                secVoltage=tmp.Name3__c;
            }
            capacitySet.add(capacity);//容量
            //キーを連結
            String key = phasesNumb+'@@'+firstVoltage+'@@'+secVoltage;
            if (specification.contains('三相7線')){
                //レコードタイプ＝”水環境"or"官需"の場合、三相7線の部分（図の赤枠内）は表示しない
                if (bu!='M' && specMap.get('三相7線')==null) specMap.put('三相7線', new Set<String>());
                specMap.get('三相7線').add(key);
            }else if (specification.contains('スコット')) {
                specMap.get('スコット').add(key);
            }else {
                specMap.get('低圧／低圧').add(key);
            }
            dataMap.put(capacity + key,tmp);
        }

        //ヘッダー設定
        table.headerList = setTransformerHeader(specMap, categoryName);

        //データ行設定
        for(String capacity : capacitySet){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            //容量
            bodyRow.add(setCell(capacity, null, null, false, false));

            for(String key : specMap.keySet()){
                Set<String> nameSet = specMap.get(key);
                for (String names : nameSet) {
                    PricingTable__c price = dataMap.get(capacity+names);
                    if (price != null) {
                        Decimal decPrice = (price.Price__c==null?0:price.Price__c);
                        bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                        bodyRow.add(setCell(getQuantityObject(price, detailsMap), null, null, true, false));//数量
                    } else {
                        bodyRow.add(setCell('―',null,null,false,true));//価格セル
                        bodyRow.add(setCell('',null,null,false,false));//空白
                    }
                }
            }
            row.cellList = bodyRow;
            bodyList.add(row);
        }

        //設定済みの情報
        table.bodyList = bodyList;
        return table;
    }

    //変圧器　ヘッダー設定
    private static List<BodyRow> setTransformerHeader(Map<String, Set<String>> specMap, String categoryName) {
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        //ヘッダー設定
        List<BodyCell> headerRow1 = new List<BodyCell>();
        List<BodyCell> headerRow2 = new List<BodyCell>();
        List<BodyCell> headerRow3 = new List<BodyCell>();
        List<BodyCell> headerRow4 = new List<BodyCell>();
        List<BodyCell> headerRow5 = new List<BodyCell>();
        List<BodyCell> headerRow6 = new List<BodyCell>();
        headerRow1.add(setCell('仕様',null,null,false,false));
        headerRow2.add(setCell('相   数',null,null,false,false));
        headerRow3.add(setCell('一次電圧',null,null,false,false));
        headerRow4.add(setCell('二次電圧',null,null,false,false));
        headerRow5.add(setCell('周波数',null,null,false,false));
        headerRow6.add(setCell('容量',null,null,false,false));
        
        for(String key : specMap.keySet()){
            Set<String> nameSet = specMap.get(key);
            //スコット	低圧／低圧	三相7線	
            headerRow1.add(setCell(key,nameSet.size()*2,null,false,false));
            for (String names : nameSet) {
                List<String> nameList = names.split('@@');
                //三相 スコット		単相		三相		三相	
                headerRow2.add(setCell(nameList.get(0),2,null,false,false));
                //420V		420V		420V		420V	
                headerRow3.add(setCell(nameList.get(1),2,null,false,false));
                //210-105V		210-105V		210V		210Y/121×182Y/105V	
                headerRow4.add(setCell(nameList.get(2),2,null,false,false));
                //50Hz		50Hz		50Hz		50Hz	
                headerRow5.add(setCell(categoryName,2,null,false,false));
                //価格	数量	価格	数量	価格	数量	価格	数量
                headerRow6.add(setCell('価格',null,null,false,false));
                headerRow6.add(setCell('数量',null,null,false,false));
            }
        }
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);//１行目
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row2);//２行目
        BodyRow row3 = new BodyRow();
        row3.cellList=headerRow3;
        headerList.add(row3);//３行目
        BodyRow row4 = new BodyRow();
        row4.cellList=headerRow4;
        headerList.add(row4);//４行目
        BodyRow row5 = new BodyRow();
        row5.cellList=headerRow5;
        headerList.add(row5);//５行目
        BodyRow row6 = new BodyRow();
        row6.cellList=headerRow6;
        headerList.add(row6);//６行目

        return headerList;
    }


    //共通機器 明細をを設定
    //低圧CT・PT、保護継電器類
    private static CustomTable setCommonEquipment(String secTitle, List<String> hCellList, String bu, Map<String, Detail__c> detailsMap){

        String customSql,customOrderBy;
        // 低圧CT・PT、保護継電器類
        if (secTitle=='低圧CT・PT、保護継電器類') {
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称9「低圧CT・PT、保護継電器類」
            customSql = ' AND Name9__c = \'低圧CT・PT、保護継電器類\' ';
            //低圧盤B画面保護継電器類用RECNO
            customOrderBy = '  RECNOforLowVoltageB_Protection__c  ';
        // 指示計類
        }else if (secTitle=='指示計類') {
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、低圧盤B画面指示計類用RECNOがnull以外
            customSql = ' AND RECNOforLowVoltageB_Order__c <> null ';
            customOrderBy = '  RECNOforLowVoltageB_Order__c  ';
        }else if (secTitle=='計装・機器取付費') {
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「計装・機器取付費」
            customSql = ' AND Name1__c = \'計装・機器取付費\' ';
        }else if (secTitle=='取付器具類') {
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、低圧盤B画面取付器具類用RECNOがnull以外
            customSql = ' AND RECNOforLowVoltageB_Attachment__c <> null ';
            //低圧盤B画面取付器具類用RECNO 昇順
            customOrderBy = '  RECNOforLowVoltageB_Attachment__c  ';
        }else if (secTitle=='計器用変流器 ＣＴ(低圧)') {
            //レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「計器用変流器」
            customSql = ' AND Name1__c = \'計器用変流器\' ';
        }
        

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> detailPriceList = getDetailPriceTable(recordTypeDetail,majorDetail,bu, customSql, customOrderBy);

        CustomTable table = new CustomTable();
        //タイトル設定　例：低圧CT・PT、保護継電器類
        table.secTitle = secTitle;

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (detailPriceList.size() == 0) return table;

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報
        if (secTitle=='計器用変流器 ＣＴ(低圧)') {
            headerList = setTransformerCTHeader();
        } else {
            //ヘッダ　設定 例：品　名、価格、数量
            if(hCellList!=null && hCellList.size()>0){
                List<BodyCell> headerRow1 = new List<BodyCell>();
                for (String headerCell : hCellList) {
                    headerRow1.add(setCell(headerCell,null,null,false,false));
                }
                BodyRow row1 = new BodyRow();
                row1.cellList=headerRow1;
                headerList.add(row1);
            }
        }

        table.headerList = headerList;

        Boolean isFirst = true;//一回だけ実施
        //ボディー行情報設定
        for(PricingTable__c tmp : detailPriceList){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();

            String name = '';
            // 低圧CT・PT、保護継電器類
            if (secTitle=='低圧CT・PT、保護継電器類') {
                //品　名 ⇒ 価格表.名称1+価格表.名称2
                name = tmp.Name1__c + tmp.Name2__c;
            }else if (secTitle=='計器用変流器 ＣＴ(低圧)') {
                //価格表.名称3
                name = tmp.Name3__c.replace('一次電流','');
            // 指示計類
            }else {
                //機器名 ⇒ 価格表.表示用テキスト
                name = tmp.DisplayName__c;
            }
            bodyRow.add(setCell(name, null, null, false, false));

            if (secTitle=='計器用変流器 ＣＴ(低圧)' && isFirst) {
                bodyRow.add(setCell(tmp.Name4__c.replace('二次電流',''), null, detailPriceList.size(), false, false));
                isFirst = false;
            }

            Decimal decPrice = (tmp.Price__c==null?0:tmp.Price__c);
            bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
            bodyRow.add(setCell(getQuantityObject(tmp, detailsMap), null, null, true, false));//数量
            row.cellList = bodyRow;
            bodyList.add(row);
        }
        table.bodyList = bodyList;

        return table;
    }

    //双投式電磁接触器 
    private static CustomTable setTwoElectroContactorTable(String bu, Map<String, Detail__c> detailsMap){

        // レコードタイプ「明細」かつ、大分類名「共通機器」かつ、名称1「双投式電磁接触器」
        String customSql = ' AND  Name1__c = \'双投式電磁接触器\'';

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> twoElectroList = getDetailPriceTable(recordTypeDetail,majorDetail,bu, customSql, null);

        CustomTable table = new CustomTable();
        //タイトル設定　双投式電磁接触器 
        table.secTitle = '双投式電磁接触器';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (twoElectroList.size() == 0) return table;

        //ヘッダ行情報 設定
        //レコードタイプ＝"水環境"or"官需"の場合は電動有のマスタのみのため、電動操作有の列だけ表示される
        table.headerList = setTwoElectroContactorHeader(bu);

        // 縦の列「2P」には名称2に「2P」を含むかつ名称4に「電動」を含まないもの、
        //「3P」には名称2に「3P」を含むかつ名称4に「電動」を含まないもの、
        //「電動操作有2P」には名称2に「2P」を含むかつ名称4に「電動」を含むもの、
        //「電動操作有3P」には名称2に「3P」を含むかつ名称4に「電動」を含むものを表示する
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //処理対象 キーを設定
        Set<Integer> afSet = new Set<Integer>();
        Map<String, PricingTable__c> detailMap = new Map<String, PricingTable__c>();
        for(PricingTable__c tmp : twoElectroList) {
            if (String.isBlank(tmp.Name2__c) || String.isBlank(tmp.Name3__c)) continue;//処理しない
            //データのキー
            String key = '';
            //定格電流
            Integer af = Integer.valueOf(tmp.Name3__c.replace('A','').replace(',',''));
            key += String.valueOf(af);
            afSet.add(af);
            //3P、2P
            if (tmp.Name2__c.contains('3P')) key += '3P';
            if (tmp.Name2__c.contains('2P')) key += '2P';
            // 電動操作なし / 電動操作あり
            if (String.isNotBlank(tmp.Name4__c) && tmp.Name4__c.contains('電動')) {
                key += '電動操作あり';
            }else {
                key += '電動操作なし';
            }
            //key例：302P電動操作なし
            detailMap.put(key,tmp);
        }

        //1列目のデータ
        List<Integer> afList = new List<Integer>(afSet);
        afList.sort();
        //内容のキー
        List<String> keys = new List<String>();
        if (bu!='M') {
            keys.add('2P電動操作なし');
            keys.add('3P電動操作なし');
        }
        keys.add('2P電動操作あり');
        keys.add('3P電動操作あり');

        //データ行設定
        for (Integer key : afList) {
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            //定格電流
            bodyRow.add(setCell(key.format() + 'A', null, null, false, false));
            for (String pkey : keys) {
                PricingTable__c price = detailMap.get(key + pkey);
                if (price != null) {
                    Decimal decPrice = (price.Price__c==null?0:price.Price__c);
                    bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                    bodyRow.add(setCell(getQuantityObject(price, detailsMap), null, null, true, false));//数量
                } else {
                    bodyRow.add(setCell('―',null,null,false,true));//価格セル
                    bodyRow.add(setCell('',null,null,false,false));//空白
                }

            }
            row.cellList = bodyRow;
            bodyList.add(row);

        }
        table.bodyList = bodyList;
        //注＊　の設定
        List<String> noteList = System.Label.Annotation_TwintypeElectromagneticContactor.split('\r\n');
        table.noteList = noteList;
        return table;
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
        return table;
    }

    //低圧コンデンサ・リアクトル　油入
    private static customTable setLowVoltageCROilTable(String categoryName, String bu, Map<String, Detail__c> detailsMap){

        // レコードタイプ「明細」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤」かつ、
        // 種類名＝見積.電源周波数かつ、（名称1「低圧コンデンサ」or名称1「低圧リアクトル」）かつ、BU「M」
        String customSql = ' AND  MinorClassificationName__c = :minorClassification'
                         + ' AND  Name1__c IN (\'低圧コンデンサ\',\'低圧リアクトル\')'
                         + ' AND  CategoryName__c = \''+ (categoryName=='50Hz'?'50Hz':'60Hz') +'\'';

        // セットした条件で価格表のデータを検索する。
        List<PricingTable__c> lowVoltageCROilList = getDetailPriceTable(recordTypeDetail,majorClassification,bu, customSql, null);

        CustomTable table = new CustomTable();
        //タイトル設定　低圧コンデンサ・リアクトル　油入
        table.secTitle = '低圧コンデンサ・リアクトル　油入';

        // ・検索時の条件に当てはまるマスタデータが1件も無い場合、タイトル含めて表自体が表示されない（セクションは表示する）
        if (lowVoltageCROilList.size() == 0) return table;

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダー情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー情報
        //ヘッダ　設定
        //１行目のヘッダー設定   
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('コンデンサ容量', null, null,false,false));//コンデンサ容量
        headerRow1.add(setCell(categoryName, 5, null,false,false));//種類名
        headerRow1.add(setCell('参考リアクトル', null, null,false,false));//参考リアクトル
        BodyRow hBodyRow1 = new BodyRow();
        hBodyRow1.cellList = headerRow1;
        headerList.add(hBodyRow1);

        //２行目のヘッダー設定  
        //kvar	μF	コンデンサ	数量	リアクトル	数量	容量（kvar) 
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow2.add(setCell('kvar', null, null,false,false));//
        headerRow2.add(setCell('μF', null, null,false,false));//  
        headerRow2.add(setCell('コンデンサ', null, null,false,false));
        headerRow2.add(setCell('数量', null, null,false,false));//
        headerRow2.add(setCell('リアクトル', null, null,false,false));//
        headerRow2.add(setCell('数量', null, null,false,false));//
        headerRow2.add(setCell('容量（kvar)', null, null,false,false));//
        BodyRow hBodyRow2 = new BodyRow();
        hBodyRow2.cellList = headerRow2;
        headerList.add(hBodyRow2);
        table.headerList = headerList;

        //キーを設定
        Map<String, Map<String, PricingTable__c>> dataMap = new Map<String, Map<String, PricingTable__c>>();
        for (PricingTable__c tmp : lowVoltageCROilList) {
            String name2 = tmp.Name2__c.replace('kvar','');
            String name4 = tmp.Name4__c.replace('μF','');
            String name1 = tmp.Name1__c.replace('低圧','');
            String key = name2+'@@'+name4;
            if (dataMap.get(key)==null) dataMap.put(key, new Map<String, PricingTable__c>());
            dataMap.get(key).put(name1, tmp);
        }

        //参考リアクトル 係数（固定値）
        Map<String, String> referMap = new Map<String, String>{
            '10'=>'0.6',
            '15'=>'1.0',
            '20'=>'1.3',
            '25'=>'1.6',
            '30'=>'1.9',
            '50'=>'3.2',
            '75'=>'4.8',
            '100'=>'6.4'
        };

        for(String key : dataMap.keySet()){
            
            //一行のデータ
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow = new List<BodyCell>();
            bodyRow.add(setCell(key.split('@@').get(0), null, null,false,true));//kvar
            bodyRow.add(setCell(key.split('@@').get(1), null, null,false,true));//μF
            //コンデンサ
            PricingTable__c conTable = dataMap.get(key).get('コンデンサ');
            //価格、数量
            if (conTable != null) {
                Decimal decPrice = (conTable.Price__c==null?0:conTable.Price__c);
                bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                bodyRow.add(setCell(getQuantityObject(conTable, detailsMap), null, null, true, false));//数量
            } else {
                bodyRow.add(setCell('―',null,null,false,true));//価格セル
                bodyRow.add(setCell('',null,null,false,false));//空白
            }
            //リアクトル
            PricingTable__c reaTable = dataMap.get(key).get('リアクトル');
            //価格、数量
            if (reaTable != null) {
                Decimal decPrice = (reaTable.Price__c==null?0:reaTable.Price__c);
                bodyRow.add(setCell(decPrice.format(), null, null, false, true));//価格
                bodyRow.add(setCell(getQuantityObject(reaTable, detailsMap), null, null, true, false));//数量
            } else {
                bodyRow.add(setCell('―',null,null,false,true));//価格セル
                bodyRow.add(setCell('',null,null,false,false));//空白
            }
            //TODO 参考まで
            bodyRow.add(setCell(referMap.get(key.split('@@').get(0)),null,null,false,true));//空白
            row.cellList = bodyRow;
            bodyList.add(row);
        }
        table.bodyList = bodyList;

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_LowPressureCapacitor_WaterEnvironment.split('\r\n');
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
                            // レコードタイプ「明細」かつ、大分類名「共通機器」
                            + '      RecordType.DeveloperName = :recordType  '
                            + '  AND MajorClassificationName__c = :major '
                            //”施設”BUが「S」/ ”水環境”or"官需"の場合 BUが「M」'
                            + '  AND BU__c = :bu  ';
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

    //ヘッダー設定（双投式電磁接触器）
    private static List<BodyRow>  setTwoElectroContactorHeader(String bu){
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        //ヘッダ　設定
        //１行目のヘッダー設定   
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        Integer spanCnt = 4;
        //"水環境"or"官需"の場合は電動有のマスタのみのため、電動操作有の列だけ表示される
        if (bu!='M')spanCnt = 8;
        headerRow1.add(setCell('定格電流', null, 2,false,false));//定格電流
        headerRow1.add(setCell('DT-MC', spanCnt, null,false,false));//価格
        BodyRow hBodyRow1 = new BodyRow();
        hBodyRow1.cellList = headerRow1;
        headerList.add(hBodyRow1);

        //２行目のヘッダー設定   
        List<BodyCell> headerRow2 = new List<BodyCell>();
        if (bu!='M') {
            headerRow2.add(setCell('2P', null, null,false,false));//2P
            headerRow2.add(setCell('数量', null, null,false,false));//数量
            headerRow2.add(setCell('3P', null, null,false,false));//3P
            headerRow2.add(setCell('数量', null, null,false,false));//数量

        }
        headerRow2.add(setCell('電動操作有2P', null, null,false,false));//電動操作有2P
        headerRow2.add(setCell('数量', null, null,false,false));//数量
        headerRow2.add(setCell('電動操作有3P', null, null,false,false));//電動操作有3P
        headerRow2.add(setCell('数量', null, null,false,false));//数量
        BodyRow hBodyRow2 = new BodyRow();
        hBodyRow2.cellList = headerRow2;
        headerList.add(hBodyRow2);

        return headerList;
    }

    //ヘッダー設定（計器用変流器 ＣＴ(低圧)）
    private static List<BodyRow> setTransformerCTHeader(){
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        //ヘッダ　設定
        //１行目のヘッダー設定   
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('定格電流', 2, null,false,false));//定格電流
        headerRow1.add(setCell('価格', null, 2,false,false));//価格
        headerRow1.add(setCell('数量', null, 2,false,false));//数量
        BodyRow hBodyRow1 = new BodyRow();
        hBodyRow1.cellList = headerRow1;
        headerList.add(hBodyRow1);

        //２行目のヘッダー設定   
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow2.add(setCell('一次', null, null,false,false));//一次
        headerRow2.add(setCell('二次', null, null,false,false));//二次
        BodyRow hBodyRow2 = new BodyRow();
        hBodyRow2.cellList = headerRow2;
        headerList.add(hBodyRow2);

        return headerList;
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
    Public static String submitDetailsForLowVoltage(String deviceId,
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
                                                AND MajorClassificationName__c IN ('低圧・現場・リレー・ACB盤','変圧器')
                                                AND MinorClassificationName__c IN ('低圧盤','高圧変圧器')
                                            )
                                            OR(DetailCategory__c='明細'
                                                AND (MajorClassificationName__c = '共通機器'
                                                    OR (MajorClassificationName__c='低圧・現場・リレー・ACB盤'
                                                        AND MinorClassificationName__c = '低圧盤')
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
}