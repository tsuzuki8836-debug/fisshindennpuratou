public with sharing class DetailsInputControllerForSpHighVoltage {

    public static final List<String> SEARCH_OPTIONS = new List<String>{'屋内','屋外'};
    public static final List<String> SEARCH_OPTIONS2 = new List<String>{'66kV','77kV','110kV', '22kV', '33kV'};
    public static final List<String> SEARCH_OPTIONS3 = new List<String>{'20/25kA','31.5kA'};
    public static final List<String> SEARCH_OPTIONS4 = new List<String>{'800A','1200A(1250A)'};
    public static final List<String> SEARCH_OPTIONS5 = new List<String>{'SF6ガス','ドライエア'};
    public static final List<String> MINOR_CLASSIFICATION_INFO = new List<String>{'66kV C-GIS','22kV C-GIS', 'ブロック(気中)キュービクル'};
    public static final List<String> DEVELOPER_NAME= new List<String>{'Chassis','Detail'};

    public class BodyRow {
        public List<BodyCell> cellList {get;set;}
    }

    public class BodyCell {
        public Object value {get;set;}
        public Integer colSpanCnt {get;set;}
        public Boolean isColSpan {get;set;}
        public Integer rowSpanCnt {get;set;}
        public Boolean isRowSpan {get;set;}
        public Boolean isEdit {get;set;}
        public Boolean isRight {get;set;}
    }

    public class QuantityObject{
        public String Id {get;set;}
        public Decimal Price {get;set;}
        public Decimal Quantity {get;set;}
    }
    //内訳入力B_特高
    public class SpHighVoltageScreenInfo {
        CustomTable unitPriceTable{get;set;}
        String searchOption{get;set;}
        String searchOption2{get;set;}
        String searchOption3{get;set;}
        String searchOption4{get;set;}
        String searchOption5{get;set;}
        // String minorClassificationInfo{get;set;}
        // String developerName{get;set;}
        List<String> noteList2 {get;set;}
    }

    //一覧に表示する情報
    public class CustomTable {
        Public String secTitle{get;set;}//タイトル
        Public String comment{get;set;}//一覧右上のコメント
        public List<BodyRow> bodyList {get;set;}//表示内容
        public List<BodyRow> headerList {get;set;}//一覧ヘッダ情報
        Public List<String> noteList {get;set;}//一覧下の「注※」内容
    }


    @AuraEnabled
    /*
     *内訳入力B_特高  保存ボタン　処理
     */
    public static string submitSpHighVoltageDetails(String details,String deviceId){

        try {
            //画面入力された情報
            List<Object> priceList;
            if (String.isNotBlank(details)) {
                priceList = (List<Object>)JSON.deserializeUntyped(details);
            }

            Set<String> delIds = new Set<String>();
            Map<String, Decimal> insList = new Map<String,Decimal>();
            //全件処理
            for (Object o : priceList) {
                Map<String,Object> record = (Map<String,Object>)o;
                String id = (String)record.get('Id');
                String cnt = String.valueof(record.get('Quantity'));
                delIds.add((String)record.get('Id'));//削除対象
                if (String.isNotBlank(cnt)) {
                    insList.put(id, Decimal.valueof(cnt));//数量が入力されたものは　登録対象
                }
            }

            Device__c device = [ SELECT Id, Quote__c,(SELECT Id FROM Details__r WHERE PricingTableUniqueKey__c like '%特高%') FROM Device__c WHERE Id =:deviceId LIMIT 1];

            //既存情報を削除
            List<Detail__c> deleteDetails = device.Details__r;
            delete deleteDetails;

            //入力された場合
            if (insList.size() > 0) {
                Map<Id,PricingTable__c> pricingTableList = new Map<Id,PricingTable__c>([
                                                                        SELECT Id, UniqueKey__c, Name, 
                                                                            MajorClassificationCode__c, 
                                                                            MajorClassificationName__c, 
                                                                            MinorClassificationCode__c, 
                                                                            MinorClassificationName__c, 
                                                                            CategoryCode__c, CategoryName__c, 
                                                                            RECNO__c, 
                                                                            RecordType.DeveloperName,
                                                                            Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c, Name7__c, Name8__c, Name9__c,  Name10__c, 
                                                                            WC__c, WcCalculationRate__c,
                                                                            Price__c,
                                                                            Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                                                                            Note__c,MasterCode__c,DetailRecordDisplayNumberText__c
                                                                        FROM PricingTable__c
                                                                        WHERE Id IN:insList.keyset()
                                                                        ]);
                List<Detail__c> detailList = new List<Detail__c>();
                for(String  pricingTableId: insList.keyset()){
                    PricingTable__c pricingTable = pricingTableList.get(pricingTableId);
                    Decimal quantity = insList.get(pricingTableId);
                    if(quantity!=null && quantity != 0) {
                        //画面　数量入力された行
                        if (pricingTable != null){
                            Detail__c detail = new Detail__c();
                            detail.Device__c = deviceId;//機器IDf
                            detail.Name1__c = pricingTable.Name1__c;
                            detail.Name2__c = pricingTable.Name2__c;
                            detail.Name3__c = pricingTable.Name3__c;
                            detail.Name4__c = pricingTable.Name4__c;
                            detail.Name5__c = pricingTable.Name5__c;
                            detail.Name6__c = pricingTable.Name6__c;
                            detail.Name7__c = pricingTable.Name7__c;
                            detail.Name8__c = pricingTable.Name8__c;
                            detail.Name9__c = pricingTable.Name9__c;
                            detail.Name10__c = pricingTable.Name10__c;
                            detail.PricingTableUniqueKey__c = pricingTable.UniqueKey__c;
                            detail.CreditWC__c = pricingTable.WC__c;//WC単価
                            detail.WcCoefficient__c = null;//null
                            detail.UnitPrice__c  = pricingTable.Price__c;//単価
                            detail.UnitPriceCoefficient__c = null;//null
                            detail.CreditWeight__c = pricingTable.Weight__c;//価格表.単位重量
                            detail.DetailCategory__c = pricingTable.RecordType.DeveloperName=='Chassis'?'筐体':'明細';//"筐体" "明細"
                            detail.ProvisionUnitPrice__c = null;//null
                            detail.Quantity__c = quantity;//数量
                            detail.WcCalculationRate__c = pricingTable.RecordType.DeveloperName=='Chassis'?0:pricingTable.WcCalculationRate__c;
                            detail.Note__c = pricingTable.Note__c;//備考
                            detail.Name = pricingTable.DisplayName__c.left(80);//表示用テキスト
                            detail.detailedStatementText__c = pricingTable.detailedStatementText__c;//価格表.内訳書出力用テキスト
                            detail.SpecialSpecificationNo__c= pricingTable.SpecialSpecificationNo__c;//価格表.特殊仕様No

                            //RECNO 「大分類名」「大分類コード」「小分類名」「小分類コード」「種類名」「種類コード」
                            detail.RECNO__c = pricingTable.RECNO__c;//RECNO
                            detail.MajorClassificationName__c = pricingTable.MajorClassificationName__c;//大分類名
                            detail.MajorClassificationCode__c = pricingTable.MajorClassificationCode__c;//大分類コード
                            detail.MinorClassificationName__c = pricingTable.MinorClassificationName__c;//小分類名
                            detail.MinorClassificationCode__c = pricingTable.MinorClassificationCode__c;//小分類コード
                            detail.CategoryCode__c = pricingTable.CategoryCode__c;//種類コード
                            detail.CategoryName__c = pricingTable.CategoryName__c;//種類名
                            detail.MasterCode__c = pricingTable.MasterCode__c;//マスタコード
                            detail.DetailRecordDisplayNumberText__c = pricingTable.DetailRecordDisplayNumberText__c;//明細レコード表示順
                            Boolean containsEvtPtLa = containsEVT_PT_LA(pricingTableId, quantity);
                            if(containsEvtPtLa != true){
                                detailList.add(detail); 
                            }
                        }
                    }
                }
                if (detailList.size()>0) insert detailList;
            }
            return device.Quote__c;
        } catch (Exception e) {
            return 'Error';
        }
    }

    @AuraEnabled
    /** 
     *内訳入力B_特高  画面情報を取得
     *
     * @param init 初期フラグ
     * @param deviceId 見積項目Id
     * @param searchOption 設置場所
     * @param searchOption2 定格電圧
     * @param searchOption3 定格遮断電流
     * @param searchOption4 定格電流
     * @param searchOption5 絶縁方式
     * @param inputsRecords 入力済みレコード
     */
    public static string getSpHighVoltageScreenInfo(Boolean init,
                                                    String deviceId,
                                                    String searchOption,
                                                    String searchOption2,
                                                    String searchOption3,
                                                    String searchOption4,
                                                    String searchOption5,
                                                    String inputsRecords){
        SpHighVoltageScreenInfo screenInfo = new SpHighVoltageScreenInfo();

        Device__c device = [SELECT Id
                                ,Name
                                ,Quote__r.RecordType.DeveloperName
                                ,MinorClassification__c
                                ,(SELECT Id
                                    ,Name
                                    ,Name1__c
                                    ,Name2__c
                                    ,Name3__c
                                    ,Name4__c
                                    ,Name5__c
                                    ,WC__c
                                    ,Price__c
                                    ,DetailCategory__c
                                FROM Details__r
                                WHERE DetailCategory__c='明細' AND MajorClassificationName__c='特高' LIMIT 1)
                            FROM Device__c
                            WHERE Id =: deviceId LIMIT 1];
        if((device.MinorClassification__c == '22kV C-GIS' || device.MinorClassification__c == 'ブロック(気中)キュービクル') && searchOption2 == '66kV'){
            searchOption2 = '22kV';
        }

        Device__c device2= [SELECT Id
                                ,Name
                                ,Quote__r.RecordType.DeveloperName
                                ,MinorClassification__c
                                ,(SELECT Id
                                    ,Name
                                    ,Name1__c
                                    ,Name2__c
                                    ,Name3__c
                                    ,Name4__c
                                    ,Name5__c
                                    ,WC__c
                                    ,Price__c
                                    ,DetailCategory__c
                                FROM Details__r
                                WHERE DetailCategory__c='筐体' AND MajorClassificationName__c='特高' LIMIT 1)
                            FROM Device__c
                            WHERE Id =: deviceId LIMIT 1];
        String bu = device2.Quote__r.RecordType.DeveloperName == 'Facility' ? 'S' : 'M';

        if((init&&device.Details__r.size()>0)) {
            // 余計な文字は除外して比較
            searchOption = SEARCH_OPTIONS.contains(device.Details__r.get(0).Name1__c.replace('特高','').replace(' ','')) ? device.Details__r.get(0).Name1__c.replace('特高','').replace(' ',''): searchOption; // Name1 設置場所, searchOption 設置場所
        }

        if((init&&device2.Details__r.size()>0)) {
            searchOption2 = SEARCH_OPTIONS2.contains(device2.Details__r.get(0).Name3__c.replace('定格電圧','')) ? device2.Details__r.get(0).Name3__c.replace('定格電圧',''): searchOption2; //Name3 定格電圧, searchOption2 定格電圧
            searchOption4 = SEARCH_OPTIONS4.contains(device2.Details__r.get(0).Name4__c.replace('定格電流','')) ? device2.Details__r.get(0).Name4__c.replace('定格電流',''): searchOption4; //Name4 定格電流, searchOption4 定格電流
            // 定格遮断電流と絶縁方式は66kVの場合しか使用しない
            if(device.MinorClassification__c == '66kV C-GIS'){
                searchOption3 = SEARCH_OPTIONS3.contains(device2.Details__r.get(0).Name5__c.replace('定格遮断電流','')) ? device2.Details__r.get(0).Name5__c.replace('定格遮断電流',''): searchOption3; //Name5 定格遮断電流, searchOption3 定格遮断電流
                searchOption5 = SEARCH_OPTIONS5.contains(device2.Details__r.get(0).Name2__c) ? device2.Details__r.get(0).Name2__c: searchOption5; // Name2 絶縁方式, searchOption5 絶縁方式
            }
        }
        
        screenInfo.searchOption = searchOption;
        screenInfo.searchOption2 = searchOption2;
        screenInfo.searchOption3 = searchOption3;
        screenInfo.searchOption4 = searchOption4;
        screenInfo.searchOption5 = searchOption5;

        List<PricingTable__c> priceList = [SELECT Id,UniqueKey__c, Name, RecordType.DeveloperName,
                                                    MajorClassificationName__c,//大分類
                                                    MinorClassificationName__c, //小分類
                                                    CategoryName__c,//種類名
                                                    DisplayName__c,//表示用テキスト
                                                    Name1__c, //名称1 品名
                                                    Name2__c, //名称2 絶縁方式
                                                    Name3__c, //名称3 定格電圧
                                                    Name4__c, //名称4 定格電流
                                                    Name5__c, //名称5 定格遮断電流
                                                    Name6__c, //名称6
                                                    Name7__c, //名称7
                                                    Name8__c, //名称8
                                                    Name9__c, //名称9
                                                    Name10__c, //名称10
                                                    WC__c, //WC
                                                    Price__c, //単価
                                                    Note__c,
                                                    MasterCode__c,//マスタコード
                                                    DetailRecordDisplayNumberText__c//明細レコード表示順
                                            FROM PricingTable__c
                                            WHERE BU__c=:bu
                                            AND MajorClassificationName__c = '特高'
                                            ORDER BY RecordType.DeveloperName, RECNO__c
                                    ];
        System.debug(priceList);
        

        //画面入力された情報
        List<Object> inputsRecordsList;
        Map<Id, Detail__c> detailMap = DetailController.getDetailRecordsByDeviceId(deviceId);
        
        System.debug('取得明細：' + detailMap);

        List<String> noteList2;
        if(device2.MinorClassification__c == '22kV C-GIS'){
            noteList2 = System.Label.Notice_ExtraHighVoltage22Kv.split('\r\n');
        }else if(device2.MinorClassification__c == 'ブロック(気中)キュービクル'){
            noteList2 = System.Label.Notice_ExtraHighVoltageCubicle.split('\r\n');
        }
        screenInfo.noteList2 = noteList2;
        CustomTable unitPriceTable = setUnitPriceTable(priceList, detailMap, screenInfo, device2);
        screenInfo.unitPriceTable = unitPriceTable;

        return  JSON.serialize(screenInfo);
    }
    
    //一覧表示内容の設定
    private static CustomTable setUnitPriceTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap, SpHighVoltageScreenInfo screenInfo, Device__c device2){
        CustomTable unitPriceTable = new CustomTable(); 
        Set<String> PricingTableName1 = new Set<String>(); //名称1
        Set<String> PricingTableName2 = new Set<String>();//名称２
        Map<String, PricingTable__c> PricingTableMap = new Map<String, PricingTable__c>(); //価格

        String minorClassification = '';
        if(device2.MinorClassification__c == '66kV C-GIS'){
            minorClassification = '66kV C-GIS';
        }else if(device2.MinorClassification__c == '22kV C-GIS'){
            minorClassification = '22kV C-GIS';
        }else{
            minorClassification = 'ブロック(気中)キュービクル';
        }

        System.debug(minorClassification);

        String changeRequirement1 = '';
        String changeRequirement2 = '';
        String changeRequirement3 = '';
        String changeRequirement4 = '';
        String changeRequirement5 = '';
        String detailName3 = null;
        //検索条件を作成
        if(minorClassification == '66kV C-GIS'){
            changeRequirement1 = screenInfo.searchOption == '屋内' ? '屋内' : '屋外';//名称1　設置場所
            //名称2 定格電圧
            if(screenInfo.searchOption2 =='66kV') {
                changeRequirement2 ='定格電圧66kV';
            }else if(screenInfo.searchOption2 =='77kV') {
                changeRequirement2 ='定格電圧77kV';
            }else{
                changeRequirement2 ='定格電圧110kV';
                detailName3 = '定格電圧110kV';
            }
            changeRequirement3 = screenInfo.searchOption3 == '20/25kA' ? '定格遮断電流20/25kA' : '定格遮断電流31.5kA'; //名称3　定格遮断電流
            changeRequirement4 = screenInfo.searchOption4 == '800A' ? '定格電流800A' : '定格電流1200A(1250A)'; //名称4 定格電流
            changeRequirement5 = screenInfo.searchOption5 == 'SF6ガス' ? 'SF6ガス' : 'ドライエア'; //名称5　絶縁方式
        }else{
            changeRequirement1 = screenInfo.searchOption == '屋内' ? '屋内' : '屋外';//名称1　設置場所
            changeRequirement2 = screenInfo.searchOption2 == '22kV' ? '定格電圧22kV' : '定格電圧33kV';//名称2 定格電圧
            changeRequirement4 = screenInfo.searchOption4 == '800A' ? '定格電流800A' : '定格電流1200A(1250A)'; //名称4 定格電流
        }


        for (PricingTable__c item : priceList) {
            String key = item.Name1__c ;
            if(item.RecordType.DeveloperName == 'Detail' )key = item.Name2__c;
            if(minorClassification == '66kV C-GIS'){
                if((item.MajorClassificationName__c == '特高' && item.RecordType.DeveloperName == 'Chassis' && item.MinorClassificationName__c == '66kV C-GIS' && item.Name2__c == changeRequirement5 &&  item.Name3__c == changeRequirement2 && item.Name4__c == changeRequirement4  && item.Name5__c == changeRequirement3)
                || (item.MajorClassificationName__c == '特高' && item.RecordType.DeveloperName == 'Detail' && item.MinorClassificationName__c == '66kV C-GIS'&& item.Name1__c.contains(changeRequirement1) && item.Name2__c == '筐体' && item.Name3__c == detailName3)){
                PricingTableName1.add(key);
                PricingTableMap.put(key,item);//データをキーで格納
                }
            }else if(minorClassification == '22kV C-GIS'){
                if((item.MajorClassificationName__c == '特高' && item.RecordType.DeveloperName == 'Chassis'  && item.MinorClassificationName__c == '22kV C-GIS' && item.Name3__c == changeRequirement2 &&  item.Name4__c == changeRequirement4)
                || (item.MajorClassificationName__c == '特高' && item.RecordType.DeveloperName == 'Detail'  && item.MinorClassificationName__c == '22kV C-GIS' && item.Name1__c.contains(changeRequirement1) && item.Name2__c == '筐体')){
                PricingTableName1.add(key);
                PricingTableMap.put(key,item);//データをキーで格納
                }
            }else{
                if((item.MajorClassificationName__c == '特高' && item.RecordType.DeveloperName == 'Chassis' &&  item.MinorClassificationName__c == 'ブロック(気中)キュービクル'  &&  item.Name3__c == changeRequirement2 && item.Name4__c == changeRequirement4)
                || (item.MajorClassificationName__c == '特高' && item.RecordType.DeveloperName == 'Detail' &&  item.MinorClassificationName__c == 'ブロック(気中)キュービクル' && item.Name1__c.contains(changeRequirement1))){
                PricingTableName1.add(key);
                PricingTableMap.put(key,item);//データをキーで格納
                }
            }
        }
        
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // No       品名      　単価　　　 数量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('No',null,null,false,false));
        headerRow1.add(setCell('品名',null,null,false,false));
        headerRow1.add(setCell('単価',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);
        
        // Body の設定
        Integer numberOfTable = 1;
        for(String name1 : PricingTableName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = PricingTableMap.get(name1);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(String.valueof(numberOfTable),null,null,false,false));//Noセル
                bodyRow.add(setCell(name1,null,null,false,false));//品名セル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }

            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
            numberOfTable+=1;
        }

        //注＊　の設定
        List<String> noteList; 
        if(device2.MinorClassification__c == '66kV C-GIS'){
            noteList = System.Label.Annotation_ExtraHighVoltage66Kv.split('\r\n');
            unitPriceTable.secTitle = '66kV C-GISユニット単価';//タイトル
        }else if(device2.MinorClassification__c == '22kV C-GIS'){
            noteList = System.Label.Annotation_ExtraHighVoltage22Kv.split('\r\n');
            unitPriceTable.secTitle = '22kV C-GISユニット単価';//タイトル
        }else{
            noteList = System.Label.Annotation_ExtraHighVoltageCubicle.split('\r\n');
            unitPriceTable.secTitle = 'ブロック(気中)キュービクルユニット単価';//タイトル
        }
    
        //タイトルの設定
        unitPriceTable.comment = '';//コメント
        unitPriceTable.headerList = headerList;//ヘッダ
        unitPriceTable.bodyList = bodyList;//ボディー
        unitPriceTable.noteList = noteList;//注＊
        return unitPriceTable;
    }

    //入力セルを設定
    private static QuantityObject getQuantityObject(PricingTable__c priceObj, Map<Id, Detail__c> detailMap){
        QuantityObject quantityObject = new QuantityObject();
        quantityObject.Id = priceObj.Id;
        System.debug('quantityobjId='+quantityObject.Id);
        //System.debug('name1=='+priceObj.Name1__c);
        System.debug(priceObj.Id);
        quantityObject.Price = priceObj.Price__c;
        // quantityObject.Option = null;
        System.debug(detailMap.get(priceObj.Id));
        Detail__c detail = detailMap.get(priceObj.Id);
        if (detail!=null) {
            quantityObject.Quantity = detail.Quantity__c;
        } else {
            quantityObject.Quantity = null;
        }

        return quantityObject;
    }

    // 2024/02/20 TS田村 追記 EVT・PT・LAでBUが施設の場合にtrueを返す
    @AuraEnabled
    public static Boolean containsEVT_PT_LA(Id pricingTableId, Decimal quantity) {
        PricingTable__c pt = [SELECT Id, Name1__c, BU__c,CharacterSymbol__c FROM PricingTable__c WHERE Id =:pricingTableId];
        String Name1 = pt.Name1__c;
        String CharacterSymbol = pt.CharacterSymbol__c;
        String BU = pt.BU__c;
        if (CharacterSymbol != null &&
        (CharacterSymbol.contains('EVT') || CharacterSymbol.contains('ZPT')  || CharacterSymbol.contains('VT') || CharacterSymbol.contains('LA') || CharacterSymbol.contains('NWVT') || CharacterSymbol.contains('NWCT')) &&
        BU == 'S' &&
        quantity > 1) {
            return true;
        }
        return false;
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