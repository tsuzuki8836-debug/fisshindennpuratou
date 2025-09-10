/**
 * 明細入力B(高圧TR1、高低圧TR1)画面のコントローラー
 * 
 * @author xu.ll 2022/11/02
 * @version 1.0
 */
public with sharing class DetailsInputForHighLowVoltageController {

    public class ScreenInfo {
        public String errorMsg  {get;set;}
        public Boolean isNodata  {get;set;}//表示データなしの場合 True

        //初期表示(選択内容)
        public String inputedId {get;set;}//選択されたデータId
        public Decimal displayTotal {get;set;}//合計の金額
        public String displayCondition {get;set;}//合計の選択条件
        //初期表示(検索条件)
        public String screenType {get;set;}//検索条件⇒画面種類
        public String transformerType {get;set;}//検索条件⇒変圧器種類

        public List<BodyRow> bodyList {get;set;}//一覧データ
        public List<BodyRow> headerList {get;set;}//ヘッダーデータ
    }

    public class BodyRow {
        public List<BodyCell> cellList {get;set;}
    }

    public class BodyCell {
        public Object value {get;set;}
        public Integer colSpanCnt {get;set;}//列結合数
        public Boolean isColSpan {get;set;}//列結合対象
        public Integer rowSpanCnt {get;set;}//行結合数
        public Boolean isRowSpan {get;set;}//行結合対象
        public Boolean isEdit {get;set;}//入力セル
        public Boolean isRight {get;set;}//右寄せ
    }
 
    @AuraEnabled
    /**
     *内訳入力B_高圧TR1 高低圧TR1 画面情報を取得
     *
     * @param recordId 見積項目Id
     * @param screenType 画面タイプ
     * @param transformerType 変圧器種類
     */
    Public static String getInitScreenInfo(
                            String recordId,
                            String screenType,
                            String transformerType){

        List<String> name10Cond=new List<String>();

        ScreenInfo info = new ScreenInfo();
        //見積のレコードタイプ
        Device__c device = [SELECT Id, 
                    toLabel(MajorClassification__c), //機器大分類
                    MinorClassification__c, //機器小分類
                    Quote__r.PowerFrequency__c, //機器周波数
                    Quote__r.RecordType.DeveloperName, //レコードタイプ
                    (SELECT Id,Name,UnitPrice__c,PricingTableUniqueKey__c,Name10__c
                        FROM Details__r
                        WHERE 
                        // AND Name = '高圧TR'
                        // Name10__c =:name10Cond AND
                        PricingTableUniqueKey__c like '%筐体%変圧器高圧変圧器%')
                    FROM Device__c WHERE Id =:recordId LIMIT 1];
        String quoteRecordType = device.Quote__r.RecordType.DeveloperName;//レコードタイプ
        String powerFrequency = device.Quote__r.PowerFrequency__c;//機器周波数
        String majorClassification = device.MajorClassification__c;//大分類

        //画面検索条件
        if (String.isNotBlank(transformerType)) {
            name10Cond= transformerType.split('@@');
        //初期表示の場合
        } else {
            //既存データ入力がある場合
            if (device.Details__r!=null 
                && device.Details__r.size()>0
                && String.isNotBlank(device.Details__r.get(0).Name10__c)){
                String  name10 = device.Details__r.get(0).Name10__c;
                String transLabel1 = '高圧TR油入(一次電圧6,600V)@@高圧TR油入(一次電圧6,600/3,300V共用)';
                String transLabel2 = '高圧TR油入(一次電圧3,300V)@@高圧TR油入(一次電圧6,600/3,300V共用)';
                String transLabel3 = '高圧TR油入(一次電圧6,600V)混触防止板あり@@高圧TR油入(一次電圧6,600/3,300V共用)混触防止板あり';
                String transLabel4 = '高圧TR油入(一次電圧3,300V)混触防止板あり@@高圧TR油入(一次電圧6,600/3,300V共用)混触防止板あり';

                //画面種類
                if (name10.contains('高・低圧')) {
                    info.screenType = '高低圧TR1';
                }else {
                    info.screenType = '高圧TR1';
                }
                //変圧器種類
                //登録済みの場合、初期表示の検索条件　設定
                if (transLabel1.contains(name10)) {
                    name10Cond = transLabel1.split('@@');
                    info.transformerType = transLabel1;
                }else if (transLabel2.contains(name10)) {
                    name10Cond = transLabel2.split('@@');
                    info.transformerType = transLabel2;
                }else if (transLabel3.contains(name10)) {
                    name10Cond = transLabel3.split('@@');
                    info.transformerType = transLabel3;
                }else if (transLabel4.contains(name10)) {
                    name10Cond = transLabel4.split('@@');
                    info.transformerType = transLabel4;
                }else {
                    name10Cond.add(name10);
                    info.transformerType = name10;
                }

            //既存データがない場合
            }else {
                //ディフォルトの検索条件（画面初期表示）
                info.screenType = '高圧TR1';
                info.transformerType = '高圧TR油入(一次電圧6,600V)@@高圧TR油入(一次電圧6,600/3,300V共用)';
                name10Cond.add('高圧TR油入(一次電圧6,600V)');
                name10Cond.add('高圧TR油入(一次電圧6,600/3,300V共用)');
            }   
        }
        List<String> bu = new List<String>();
        // 見積.レコードタイプ="施設"の場合
        // レコードタイプ「筐体」かつ、BU「S」
        if (quoteRecordType=='Facility'){
            bu.add('S');
        }else {
        // 見積.レコードタイプ="水環境"or"官需"の場合
        // レコードタイプ「筐体」かつ、BU「M」
            bu.add('M');
            // bu.add('K');
        }
        //筐体の周波数条件
        String categoryCode = '';
        if (String.isNotBlank(powerFrequency)) {
            //大分類が「変圧器」or「発電機」の場合は筐体の周波数条件設定
            categoryCode = (powerFrequency=='50Hz'?'01':'02');
        }
        System.debug('tk' + categoryCode);
        System.debug('tk' + bu);
        System.debug('tk' + name10Cond);
        //価格表を検索する
        List<PricingTable__c> chassisList = [SELECT Id, Name, UniqueKey__c,
                                            MajorClassificationCode__c,
                                            MinorClassificationCode__c, 
                                            CategoryCode__c,
                                            CategoryName__c,
                                            RECNO__c,
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
                                            WC__c, 
                                            Price__c, 
                                            //Weight__c, 
                                            ConditionForSearchformula__c,
                                            CapacityNumber__c,
                                            Note__c,
                                            MasterCode__c,
                                            DetailRecordDisplayNumberText__c
                                        FROM PricingTable__c
                                        WHERE RecordType.DeveloperName = 'Chassis'
                                          AND BU__c =:bu
                                          AND CategoryCode__c =:categoryCode
                                        //   AND DisplayName__c = '高圧TR'
                                          AND Name10__c =:name10Cond
                                        ORDER BY RECNo__c
                                    ];
        List<BodyRow> bodyList = new List<BodyRow>();
        List<BodyRow> headerList = new List<BodyRow>();
        info.isNodata=true;//
        //検索結果があるの場合
        if (chassisList.size() > 0) {
            //仕   様:(名称9)
            Set<String> name9List = new Set<String>();
            //相   数:(名称3)
            //Map<仕   様, Set<相   数>>
            Map<String, Set<String>> name3Map = new Map<String, Set<String>>();
            //一次電圧:(名称4)
            // //Map<仕   様, 一次電圧>
            // Map<String, String> name4Map = new Map<String, String>();
            //二次電圧:(名称5)
            //Map<相   数, Set<二次電圧>>
            Map<String, Set<String>> name4_5Map = new Map<String, Set<String>>();
            //周波数 50hz,60hz:(種類名)
            Set<String> categoryList = new Set<String>();

            //kva １列目の内容
            Set<Integer> name6Set = new Set<Integer>();

            //キーで価格表情報を格納する
            Map<String, PricingTable__c> priceMap = new Map<String, PricingTable__c>();

            //キーの設定
            for (PricingTable__c chassisTmp: chassisList) {
                //キーがないの場合、処理しない
                if (String.isBlank(chassisTmp.Name9__c))continue;

                String key = chassisTmp.Name9__c
                            + chassisTmp.Name3__c
                            + chassisTmp.Name4__c
                            + chassisTmp.Name5__c
                            + chassisTmp.CategoryName__c
                            + chassisTmp.Name6__c;
                priceMap.put(key, chassisTmp);
                //仕   様
                name9List.add(chassisTmp.Name9__c);
                //相   数:(名称3)
                Set<String> name3Set=name3Map.get(chassisTmp.Name9__c);
                if (name3Set == null || name3Set.size()==0) name3Set=new Set<String>();
                name3Set.add(chassisTmp.Name3__c);
                name3Map.put(chassisTmp.Name9__c,name3Set);
                // if (name4Map.get(chassisTmp.Name9__c)==null) name4Map.put(chassisTmp.Name9__c,chassisTmp.Name4__c);
                
                //一次電圧
                //二次電圧:(名称5)
                Set<String> name4_5Set = name4_5Map.get(chassisTmp.Name9__c + chassisTmp.Name3__c);
                if (name4_5Set==null || name4_5Set.size()==0) name4_5Set=new Set<String>();
                name4_5Set.add(chassisTmp.Name4__c + '@@@' + chassisTmp.Name5__c);
                name4_5Map.put(chassisTmp.Name9__c + chassisTmp.Name3__c, name4_5Set);
                //周波数
                categoryList.add(chassisTmp.CategoryName__c);
                //１列目の内容
                if(chassisTmp.CapacityNumber__c!=null)name6Set.add(chassisTmp.CapacityNumber__c.intValue());
            }
            List<Integer> name6ListSort;
            //一覧の表示可否を制御
            if (name6Set.size()>0) {
                info.isNodata=false;
                name6ListSort = new List<Integer>(name6Set);
                name6ListSort.sort();

                Boolean isSetHeader = true;//一回のみ設定
                //一覧表示内容を設定
                for (Integer intName6 : name6ListSort) {
                    String name6 = intName6.format()+'kVA';
                    if(isSetHeader){
                        List<BodyCell> headerRow1 = new List<BodyCell>();//ヘッダー1行目
                        List<BodyCell> headerRow2 = new List<BodyCell>();//ヘッダー2行目
                        List<BodyCell> headerRow3 = new List<BodyCell>();//ヘッダー3行目
                        List<BodyCell> headerRow4 = new List<BodyCell>();//ヘッダー4行目
                        List<BodyCell> headerRow5 = new List<BodyCell>();//ヘッダー5行目
    
                        //固定部分を設定
                        headerRow1.add(setCell('仕   様',null,null,false,false));// 仕   様
                        headerRow2.add(setCell('相   数',null,null,false,false));// 相   数
                        headerRow3.add(setCell('一次電圧',null,null,false,false)); // 一次電圧
                        headerRow4.add(setCell('二次電圧',null,null,false,false));// 二次電圧
                        headerRow5.add(setCell('周波数',null,null,false,false));// 周波数(Hz)
                        //ヘッダー設定、キーの組み合わせ
                        for(String name9 : name9List){
                            Integer namr9ColSpan = 0;
                            //相数 行の内容
                            Set<String> name3Set=name3Map.get(name9);
                            for(String name3 : name3Set){
                                Integer name3ColSpan = 0;
    
                                //二次電圧
                                //一次電圧
                                Set<String> name4_5Set = name4_5Map.get(name9 + name3);
                                for(String name4_5 : name4_5Set){
                                    List<String> tmpList = name4_5.split('@@@');
                                    String name4 = (tmpList.size() > 0?tmpList.get(0):'');//一次電圧　名称４
                                    String name5 = (tmpList.size() > 1?tmpList.get(1):'');//二次電圧　名称５
                                    Integer name5ColSpan = categoryList.size();
                                    //周波数　行の内容
                                    for(String category :categoryList){
                                        headerRow5.add(setCell(category,2,null,false,false));//周波数
                                    }
                                    name3ColSpan = name3ColSpan + name5ColSpan;//ConSpan数を計上
                                    //二次電圧　行の内容
                                    headerRow4.add(setCell(name5,(name5ColSpan>0?name5ColSpan*2:null),null,false,false));// 二次電圧
                                    //一次電圧　行の内容
                                    headerRow3.add(setCell(name4,(name5ColSpan>0?name5ColSpan*2:null),null,false,false));// 一次電圧
                                }
                                namr9ColSpan = namr9ColSpan + name3ColSpan;//ConSpan数を計上
                                //相   数　行の内容
                                headerRow2.add(setCell(name3,(name3ColSpan>0?name3ColSpan*2:null),null,false,false));// 相   数
                            }
                            //仕様　行の内容
                            headerRow1.add(setCell(name9,(namr9ColSpan>0?namr9ColSpan*2:null),null,false,false));//仕様
                        }
    
                        //ヘッダー設定済み
                        isSetHeader = false;
                        //１行目ヘッダー設定
                        BodyRow row1 = new BodyRow();
                        row1.cellList=headerRow1;
                        headerList.add(row1);
                        //２行目ヘッダー設定
                        BodyRow row2 = new BodyRow();
                        row2.cellList=headerRow2;
                        headerList.add(row2);
                        //３行目ヘッダー設定
                        BodyRow row3 = new BodyRow();
                        row3.cellList=headerRow3;
                        headerList.add(row3);
                        //４行目ヘッダー設定
                        BodyRow row4 = new BodyRow();
                        row4.cellList=headerRow4;
                        headerList.add(row4);
                        //５行目ヘッダー設定
                        BodyRow row5 = new BodyRow();
                        row5.cellList=headerRow5;
                        headerList.add(row5);
                        info.headerList = headerList;
                    }
    
                    //bodyデータ情報設定
                    List<BodyCell> cellList = new List<BodyCell>();
                    //１列目(名称6)
                    cellList.add(setCell(name6 ,null,null,false,false));
                    //ヘッダー設定、キーの組み合わせ
                    for(String name9 : name9List){
                        //一次電圧　行の内容
                        // String name4 = name4Map.get(name9);
                        //相数 行の内容
                        Set<String> name3Set=name3Map.get(name9);
                        for(String name3 : name3Set){
                            //二次電圧
                            Set<String> name4_5Set = name4_5Map.get(name9 + name3);
                            for(String name4_5 : name4_5Set){
                                List<String> tmpList = name4_5.split('@@@');
                                String name4 = (tmpList.size() > 0?tmpList.get(0):'');//一次電圧　名称４
                                String name5 = (tmpList.size() > 1?tmpList.get(1):'');//二次電圧　名称５
                                //周波数　行の内容
                                for(String category :categoryList){
                                    String key = name9
                                                + name3
                                                + name4
                                                + name5
                                                + category
                                                + name6;
    
                                    PricingTable__c item = priceMap.get(key);
                                    if (item!=null) {
                                        Decimal price =  (item.Price__c==null?0:item.Price__c);
                                        cellList.add(setCell(price.format(),null,null,false,true));//価格セル
                                        // 名称1～7を半角スペースで連結して表示
                                        String name = item.Name1__c
                                                    + (String.isNotBlank(item.Name2__c)?' ' + item.Name2__c:'')
                                                    + (String.isNotBlank(item.Name3__c)?' ' + item.Name3__c:'')
                                                    + (String.isNotBlank(item.Name4__c)?' ' + item.Name4__c:'')
                                                    + (String.isNotBlank(item.Name5__c)?' ' + item.Name5__c:'')
                                                    + (String.isNotBlank(item.Name6__c)?' ' + item.Name6__c:'')
                                                    + (String.isNotBlank(item.Name7__c)?' ' + item.Name7__c:'');
                                        Map<String,Object> cellItem = new Map<String,Object>();
                                        cellItem.put('Id',item.Id);//Id
                                        cellItem.put('Price__c',price);//単価
                                        cellItem.put('Name1__c',name);//仕様
    
                                        //既存データの設定
                                        if (device.Details__r!=null 
                                            && device.Details__r.size()>0
                                            && device.Details__r.get(0).PricingTableUniqueKey__c == item.UniqueKey__c){
                                            info.inputedId = item.Id;//チェックされた値
                                            info.displayTotal = price;//単価
                                            info.displayCondition = name;//選択仕様
                                            cellItem.put('isChecked',true);
                                        }else {
                                            cellItem.put('isChecked',false);
                                        }
                                        
                                        cellList.add(setCell(cellItem,null,null,true,false));//入力セル
                                    }else {
                                        cellList.add(setCell('―',null,null,false,true));//価格セル
                                        cellList.add(setCell('―',null,null,false,false));//空白
                                    }
                                }
                            }
                        }
                    }
                    //行データをBodyリストに追加
                    BodyRow dataRow = new BodyRow();
                    dataRow.cellList = cellList;
                    // System.debug(cellList);
                    bodyList.add(dataRow);
                }
            }
            info.bodyList = bodyList;
        }
        return JSON.serialize(info);
    }


    /**
     * 画面一覧の各セルの内容を設定
     * 
     *  @param value  表示の内容
     *  @param colSpanCnt  列結合数
     *  @param rowSpanCnt  行結合数
     *  @param isEdit  編集可能の制御
     *  @param isRight  右寄せの制御
     */
    private static BodyCell setCell(Object value,Integer colSpanCnt,
                                    Integer rowSpanCnt, Boolean isEdit ,
                                    Boolean isRight){
        BodyCell cell = new BodyCell();
        cell.isEdit=isEdit;
        cell.isRight = isRight;
        cell.value = value;
        //列結合の場合
        if (colSpanCnt != null){
            cell.colSpanCnt=colSpanCnt;
            cell.isColSpan=true;
        }else{
            cell.isColSpan=false;
        }

        //行結合の場合
        if (rowSpanCnt!=null) {
            cell.rowSpanCnt=rowSpanCnt;
            cell.isRowSpan=true;
        }else {
            cell.isRowSpan=false;
        }
        return cell;
    }
    @AuraEnabled(Cacheable=false)
    /**
     *内訳入力B_高圧TR1 高低圧TR1 登録処理
     *
     * @param deviceId 見積項目Id
     * @param recordId 価格表Id
     */
    Public static String submitDetails(
                        String deviceId,
                        String recordId){
        try{
            List<Detail__c> dtList = [SELECT Id
                FROM Detail__c
                WHERE Device__c=:deviceId
                AND PricingTableUniqueKey__c like '%筐体%変圧器高圧変圧器%'];
            if (dtList != null && dtList.size()>0) delete dtList;//既存のデータを削除
    
            //登録用　価格表データ
            PricingTable__c chassis = [SELECT Id, Name, RECNo__c,
                                        MajorClassificationCode__c, 
                                        MajorClassificationName__c, 
                                        MinorClassificationCode__c, 
                                        MinorClassificationName__c, 
                                        CategoryCode__c,CategoryName__c,
                                        Name1__c, Name2__c,Name3__c,Name4__c,Name5__c,
                                        Name6__c, Name7__c,Name8__c,Name9__c,Name10__c,
                                        WC__c, Price__c, UniqueKey__c,ConditionForSearchformula__c,
                                        Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                                        Note__c,MasterCode__c,DetailRecordDisplayNumberText__c
                                    FROM PricingTable__c
                                    WHERE Id =:recordId
                                    LIMIT 1
                                ];
            Detail__c detail = new Detail__c();
            detail.Note__c = chassis.Note__c;
            detail.UnitPrice__c = chassis.Price__c;
            detail.WcCalculationRate__c = 0;
            //価格表.表示用テキストが80文字より多い場合、最初の80文字だけを明細に転記する処理を追加
            if (chassis.DisplayName__c.length()>80) {
                String over80 = chassis.DisplayName__c.subString(0,80);
                detail.Name = over80;
                System.debug('over80='+over80);
            }else if (chassis.DisplayName__c.length() <= 80) {
                detail.Name = chassis.DisplayName__c;
            }
            detail.Name1__c = chassis.Name1__c; //名称１             
            detail.Name2__c = chassis.Name2__c; //名称2
            detail.Name3__c = chassis.Name3__c; //名称3                 
            detail.Name4__c = chassis.Name4__c; //名称4
            detail.Name5__c = chassis.Name5__c; //名称5
            detail.Name6__c = chassis.Name6__c; //名称6
            detail.Name7__c = chassis.Name7__c; //名称7
            detail.Name8__c = chassis.Name8__c; //名称8
            detail.Name9__c = chassis.Name9__c; //名称9
            detail.Name10__c = chassis.Name10__c; //名称１0
    
            detail.Quantity__c = 1;//数量　固定「１」
            detail.Device__c = deviceId;
            detail.CreditWC__c = chassis.WC__c;//単位Wc
            detail.CreditWeight__c = chassis.Weight__c;//単位重量
            detail.PricingTableUniqueKey__c = chassis.UniqueKey__c;
            detail.DetailCategory__c='筐体';//"筐体" "明細"
            //RECNO 「大分類名」「大分類コード」「小分類名」「小分類コード」「種類名」「種類コード」
            detail.RECNO__c = chassis.RECNO__c;//RECNO
            detail.MajorClassificationName__c = chassis.MajorClassificationName__c;//大分類名
            detail.MajorClassificationCode__c = chassis.MajorClassificationCode__c;//大分類コード
            detail.MinorClassificationName__c = chassis.MinorClassificationName__c;//小分類名
            detail.MinorClassificationCode__c = chassis.MinorClassificationCode__c;//小分類コード
            detail.CategoryName__c = chassis.CategoryName__c;//種類名
            detail.CategoryCode__c = chassis.CategoryCode__c;//種類コード
            detail.detailedStatementText__c = chassis.detailedStatementText__c;//価格表.内訳書出力用テキスト
            detail.SpecialSpecificationNo__c= chassis.SpecialSpecificationNo__c;//価格表.特殊仕様No
            detail.MasterCode__c = chassis.MasterCode__c;//マスタコード
            detail.DetailRecordDisplayNumberText__c = chassis.DetailRecordDisplayNumberText__c;//明細レコード表示順
    
            insert detail;
    
            //機器情報を取得
            List<Device__c> deviceList = DeviceController.getDevice(deviceId);
            return deviceList.get(0).Quote__c;
        }catch(Exception ex) {
            System.debug('An Exception: '+ex);
            return 'error';
        }
    }
}