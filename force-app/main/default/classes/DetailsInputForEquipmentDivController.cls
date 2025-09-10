/**
 * 明細入力B(高圧TR２、高低圧TR２　H種乾式変圧器（機器事業部）)画面のコントローラー
 * 
 * @author xu.ll 2022/11/28
 * @version 1.0
 */
public with sharing class DetailsInputForEquipmentDivController {

    //画面情報
    public class ScreenInfo {
        public String errorMsg  {get;set;}
        public Boolean isNodata  {get;set;}//データなしの場合

        //初期表示(選択内容)
        public String inputedId {get;set;}//入力された筐体
        public Decimal inputedPrice {get;set;}//筐体　単価
        public Decimal displayTotal {get;set;}//合計　金額
        public String displayCondition {get;set;}//合計　表示条件
        //初期表示(検索条件)
        public String screenType {get;set;}//画面種類
        public String transformerType {get;set;}//変圧器種類
        public Decimal exOptIndex {get;set;}//オプション条件

        public List<BodyRow> bodyList {get;set;}//一覧データ
        public List<BodyRow> headerList {get;set;}//一覧ヘッダー

        public CustomTable rSeriesSingleTable {get;set;}//Rシリーズ　単相
        public CustomTable rSeriesTriangleTable {get;set;}//Rシリーズ　三相
        public CustomTable exaSeriesSingleTable {get;set;}//EX-αシリーズ　単相
        public CustomTable exaSeriesTriangleTable {get;set;}//EX-αシリーズ　三相
        public CustomTable exbSeriesSingleTable {get;set;}//EX-βシリーズ　単相
        public CustomTable exbSeriesTriangleTable {get;set;}//EX-βシリーズ　三相
        public CustomTable lowVoltageTable {get;set;}//付属品
        public CustomTable hDrySingleTable {get;set;}//H種乾式 単相
        public CustomTable hDryTriangleTable {get;set;}//H種乾式 三相
    }

    //共通部品表示するため　テーブルを定義
    public class CustomTable {
        Public String secTitle{get;set;}//タイトル
        Public String comment{get;set;}//一覧右上のコメント
        public List<BodyRow> bodyList {get;set;}//表示内容
        public List<BodyRow> headerList {get;set;}//一覧ヘッダ情報
        Public List<String> noteList {get;set;}//一覧下の「注※」内容
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
    public class QuantityObject{
        public String Id {get;set;}
        public Decimal Price {get;set;}
        public Decimal Quantity {get;set;}
    }
    @AuraEnabled
    /**
     *内訳入力B_高圧TR2 高低圧TR2 H種乾式変圧器 登録処理
     *
     * @param deviceId 見積項目Id
     * @param recordId 価格表Id
     * @param strOptRecords 付属品情報
     */
    Public static String submitDetails(
                        String deviceId,
                        String recordId,
                        String strOptRecords){
        try{
            List<Detail__c> dtList = [SELECT Id
                FROM Detail__c
                WHERE Device__c=:deviceId
                AND PricingTableUniqueKey__c like '%変圧器機器事業部 変圧器%'
                ];
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
                detail.Note__c = chassis.Note__c;
                detail.UnitPrice__c = chassis.Price__c;
                // detail.UnitPriceCoefficient__c = 1;
                detail.WcCalculationRate__c = 0;
                detail.Name = chassis.DisplayName__c;//表示用テキスト
                detail.Name1__c = chassis.Name1__c;//名称１
                detail.Name2__c = chassis.Name2__c;//名称2
                detail.Name3__c = chassis.Name3__c;//名称3
                detail.Name4__c = chassis.Name4__c;//名称4
                detail.Name5__c = chassis.Name5__c;//名称5

                detail.Name6__c = chassis.Name6__c;//名称6
                detail.Name7__c = chassis.Name7__c;//名称7
                detail.Name8__c = chassis.Name8__c;//名称8
                detail.Name9__c = chassis.Name9__c;//名称9
                detail.Name10__c = chassis.Name10__c;//名称10
        
                detail.Quantity__c = 1;
                detail.Device__c = deviceId;
                detail.CreditWC__c = chassis.WC__c;
                detail.CreditWeight__c = chassis.Weight__c;
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
                detail.detailedStatementText__c	= chassis.detailedStatementText__c;//価格表.内訳書出力用テキスト
                detail.SpecialSpecificationNo__c= chassis.SpecialSpecificationNo__c;//価格表.特殊仕様No
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
                        optObj.Note__c = optDetail.Note__c;
                        optObj.UnitPrice__c = optDetail.Price__c;//価格表.単価
                        optObj.WcCalculationRate__c = optDetail.WcCalculationRate__c;//価格表.WC算出レート
                        optObj.Name = optDetail.DisplayName__c;
                        optObj.Name1__c = optDetail.Name1__c;//価格表.名称1
                        optObj.Name2__c =  optDetail.Name2__c;//価格表.名称2
                        optObj.Name3__c = optDetail.Name3__c;//価格表.名称3
                        optObj.Name4__c = optDetail.Name4__c;//価格表.名称4
                        optObj.Name5__c = optDetail.Name5__c;//価格表.名称5
                        optObj.Name6__c = optDetail.Name6__c;//価格表.名称6
                        optObj.Name7__c = optDetail.Name7__c;//価格表.名称7
                        optObj.Name8__c = optDetail.Name8__c;//価格表.名称8
                        optObj.Name9__c = optDetail.Name9__c;//価格表.名称9
                        optObj.Name10__c = optDetail.Name10__c;//価格表.名称10
                        optObj.Quantity__c = opt.Quantity;//画面　の数量
                        optObj.Device__c = deviceId;
                        optObj.CreditWC__c = optDetail.WC__c;
                        optObj.CreditWeight__c = optDetail.Weight__c;
                        optObj.PricingTableUniqueKey__c = optDetail.UniqueKey__c;
                        optObj.DetailCategory__c='明細';//"筐体" "明細"
                        //RECNO 「大分類名」「大分類コード」「小分類名」「小分類コード」「種類名」「種類コード」
                        optObj.RECNO__c = optDetail.RECNO__c;//RECNO
                        optObj.MajorClassificationName__c = optDetail.MajorClassificationName__c;//大分類名
                        optObj.MajorClassificationCode__c = optDetail.MajorClassificationCode__c;//大分類コード
                        optObj.MinorClassificationName__c = optDetail.MinorClassificationName__c;//小分類名
                        optObj.MinorClassificationCode__c = optDetail.MinorClassificationCode__c;//小分類コード
                        optObj.CategoryName__c = optDetail.CategoryName__c;//種類名
                        optObj.CategoryCode__c = optDetail.CategoryCode__c;//種類コード
                        optObj.detailedStatementText__c	= optDetail.detailedStatementText__c;//価格表.内訳書出力用テキスト
                        optObj.SpecialSpecificationNo__c= optDetail.SpecialSpecificationNo__c;//価格表.特殊仕様No
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

    @AuraEnabled
    /**
     *内訳入力B_高圧TR2 高低圧TR2 H種乾式変圧器（機器事業部） 画面情報を取得
     *
     * @param recordId 見積項目Id
     * @param screenType 画面タイプ
     * @param transformerType 変圧器種類
     * @param exOpt R EXｰα  EXｰβシリーズ条件
     */
    Public static String getScreenInfo(
                            String recordId,
                            String screenType,
                            String transformerType,
                            String exOpt){

        System.debug(screenType);
        System.debug(transformerType);
        System.debug(exOpt);

        ScreenInfo info = new ScreenInfo();
        //見積のレコードタイプ
        Device__c device = [SELECT Id, 
                    toLabel(MajorClassification__c), //見積項目大分類
                    MinorClassification__c, //見積項目小分類
                    Quote__r.PowerFrequency__c, //見積項目周波数
                    Quote__r.RecordType.DeveloperName, //レコードタイプ
                    (SELECT Id,Name,UnitPrice__c,PricingTableUniqueKey__c,DetailCategory__c,Quantity__c,
                            Name1__c,Name7__c,Name8__c,Name9__c,Name10__c
                        FROM Details__r
                        WHERE PricingTableUniqueKey__c like '%変圧器機器事業部 変圧器%')
                    FROM Device__c WHERE Id =:recordId LIMIT 1];
        String quoteRecordType = device.Quote__r.RecordType.DeveloperName;//レコードタイプ
        String powerFrequency = device.Quote__r.PowerFrequency__c;//見積項目周波数
        String majorClassification = device.MajorClassification__c;

        //画面検索条件(初期表示の場合)
        if (String.isBlank(transformerType)) {
            Detail__c chassisDetail;
            if (device.Details__r!=null 
                && device.Details__r.size()>0) {
                for (Detail__c tmp :device.Details__r) {
                    if (tmp.DetailCategory__c == '筐体') {
                        chassisDetail = tmp;//筐体の登録データ
                    }
                }
            }

            Map<String, String> optMap = new Map<String, String>();
            //既存データ入力がある場合
            if (chassisDetail!=null){
                //H種乾式変圧器（機器事業部） 条件
                List<String> hDry = new List<String>{'ケースなし','ケース入り'};

                //シリーズ条件
                Set<String> highLow = new Set<String>();
                List<TransformerPullDownList__mdt> metaList = [select 
                                                                    TransformerType__c,
                                                                    PulldownName__c,
                                                                    DisplayOrder__c,
                                                                    ListValue__c 
                                                                From TransformerPullDownList__mdt];
                for (TransformerPullDownList__mdt item: metaList) {
                    System.debug(item.ListValue__c);
                    highLow.add(item.ListValue__c);
                }
                //高低圧画面
                List<String> low = new List<String>{
                    'モ低圧混板なし',
                    'モ スコット混板なし',
                    'モ低圧混板あり',
                    'モ スコット混板あり',
                    'モ低圧異電圧・異結線混板なし',
                    'モ低圧異電圧・異結線混板あり'
                };

                //H種乾式変圧器（機器事業部）
                if (String.isNotBlank(chassisDetail.Name7__c) 
                    && hDry.contains(chassisDetail.Name7__c)) {
                        
                    System.debug('H種乾式変圧器（機器事業部）');
                    screenType = 'H種乾式変圧器（機器事業部）';
                    transformerType = chassisDetail.Name7__c;
                    info.screenType = 'H種乾式変圧器（機器事業部）';
                    info.transformerType = chassisDetail.Name7__c;

                //高圧TR2
                } else if (String.isNotBlank(chassisDetail.Name10__c) 
                        && highLow.contains(chassisDetail.Name10__c)  //Name10__cがシリーズ条件に存在
                        && String.isNotBlank(chassisDetail.Name1__c) 
                        && (chassisDetail.Name1__c.contains('油')
                            || chassisDetail.Name1__c.contains('モールド'))
                        && (chassisDetail.Name1__c.contains('R') 
                            || chassisDetail.Name1__c.contains('EX-α')
                            || chassisDetail.Name1__c.contains('EX-β')
                            || chassisDetail.Name1__c.contains('EX- α')
                            || chassisDetail.Name1__c.contains('EX- β'))) {

                    System.debug('高圧TR2');
                    //画面種類の設定
                    screenType = '高圧TR2（機器事業部）';
                    info.screenType = '高圧TR2（機器事業部）';

                    //変圧器種類の設定
                    if (chassisDetail.Name1__c.contains('油')) {
                        transformerType = '油入';
                        info.transformerType = '油入';
                    }else if (chassisDetail.Name1__c.contains('モールド')) {
                        transformerType = 'モールド';
                        info.transformerType = 'モールド';
                    }
                    //シリーズ名
                    String pullName = '';

                    //シリーズ条件　設定
                    if (chassisDetail.Name1__c.contains('R')) {
                        pullName = 'Rシリーズ';
                    } else if (chassisDetail.Name1__c.contains('EX-α')
                            || chassisDetail.Name1__c.contains('EX- α')) {
                        pullName = 'EXｰαシリーズ';
                    }else if (chassisDetail.Name1__c.contains('EX-β')
                            || chassisDetail.Name1__c.contains('EX- β')) {
                        pullName = 'EXｰβシリーズ';
                    }

                    //シリーズ順番を確定
                    Decimal pullOrder = null;
                    for (TransformerPullDownList__mdt item: metaList) {
                        if (item.TransformerType__c == transformerType
                            && item.PulldownName__c == pullName
                            && chassisDetail.Name10__c == item.ListValue__c) {
                            pullOrder = item.DisplayOrder__c;
                            break;
                            }
                    }
                    //シリーズ条件の設定
                    for (TransformerPullDownList__mdt item: metaList) {
                        if (item.TransformerType__c == transformerType
                            && item.DisplayOrder__c == pullOrder) {
                            if (item.PulldownName__c == 'Rシリーズ') {
                                optMap.put('rSeries',item.ListValue__c);
                            }else if(item.PulldownName__c == 'EXｰαシリーズ') {
                                optMap.put('exaSeries',item.ListValue__c);
                            }else if(item.PulldownName__c == 'EXｰβシリーズ') {
                                optMap.put('exbSeries',item.ListValue__c);

                            }
                        }
                    }
                    exOpt = JSON.serialize(optMap);
                    info.exOptIndex = pullOrder;
                // 高低圧TR2（機器事業部）
                } else if ((String.isNotBlank(chassisDetail.Name9__c) 
                            && low.contains(chassisDetail.Name9__c))
                            || (String.isNotBlank(chassisDetail.Name9__c) 
                                && chassisDetail.Name1__c.contains('トップランナー対象外 油'))) {
                    System.debug('高低圧TR2（機器事業部）');
                    //画面種類
                    screenType = '高低圧TR2（機器事業部）';
                    info.screenType='高低圧TR2（機器事業部）';
                    if (chassisDetail.Name1__c.contains('トップランナー対象外 油')) {
                        transformerType = '油入';
                    }else if (chassisDetail.Name9__c == 'モ低圧混板なし'
                            || chassisDetail.Name9__c == 'モ スコット混板なし') {
                        transformerType = 'モールド';
                        info.transformerType = 'モールド';
                    }else if (chassisDetail.Name9__c == 'モ低圧混板あり'
                            || chassisDetail.Name9__c == 'モ スコット混板あり') {
                        transformerType = 'モールド　混触防止板あり';
                        info.transformerType = 'モールド　混触防止板あり';
                    }else if (chassisDetail.Name9__c == 'モ低圧異電圧・異結線混板なし') {
                        transformerType = 'モールド　異電圧';
                        info.transformerType = 'モールド　異電圧';
                    }else if (chassisDetail.Name9__c == 'モ低圧異電圧・異結線混板あり') {
                        transformerType = 'モールド　異電圧　混触防止板あり';
                        info.transformerType = 'モールド　異電圧　混触防止板あり';
                    }         
                }

            //既存登録データがない場合
            //ディフォルト設定
            } else {
                screenType = '高圧TR2（機器事業部）';
                transformerType = '油入';
                info.screenType='高圧TR2（機器事業部）';
                info.transformerType = '油入';
                optMap.put('rSeries','一次電圧6600V二次電圧210V');
                optMap.put('exaSeries','一次電圧6600V二次電圧210V');
                optMap.put('exbSeries','一次電圧6600V二次電圧210V');
                exOpt = JSON.serialize(optMap);
                info.exOptIndex = 10;
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
        }
        //筐体の周波数条件
        String categoryCode = '';
        if (String.isNotBlank(powerFrequency)) {
            //筐体の周波数条件設定
            categoryCode = (powerFrequency=='50Hz'?'01':'02');
        }
        if (screenType == '高圧TR2（機器事業部）') {
            //高圧TR2（機器事業部） 情報取得
            //筐体データ（チェックボックス一覧）
            info = getScreenInfoForHighVoltage(device, info, categoryCode, bu, screenType, transformerType, exOpt);
        } else if (screenType == '高低圧TR2（機器事業部）') {
            //高低圧TR2（機器事業部）情報取得
            info = getScreenInfoForLowVoltage(device, info, categoryCode, bu, screenType, transformerType);
        } else if (screenType == 'H種乾式変圧器（機器事業部）') {
            //H種乾式変圧器（機器事業部）情報取得
            info = getScreenInfoForHDry(device, info, categoryCode, bu, screenType, transformerType);
        }

        return JSON.serialize(info);
    }
   /**
     *H種乾式変圧器（機器事業部）
     *
     * @param device 機器情報
     * @param info   画面情報
     * @param categoryCode 周波数
     * @param bu BU情報
     * @param screenType 画面種類
     * @param transformerType 変圧器種類
     */
    private static ScreenInfo getScreenInfoForHDry(Device__c device,
                                                    ScreenInfo info,
                                                    String categoryCode,
                                                    List<String> bu,
                                                    String screenType,
                                                    String transformerType
                                                    ){
        //検索条件編集
        List<String> condiList = new List<String>{'Name7__c = \''+transformerType+'\''};
        //価格表を検索する
        List<PricingTable__c> chassisList = getPriceTableInfo(bu, screenType, categoryCode, condiList);

        List<BodyRow> bodyList = new List<BodyRow>();
        List<BodyRow> headerList = new List<BodyRow>();
        info.isNodata=true;//

        //筐体の既存明細データ
        Detail__c chassisDetail;
        Map<String, Detail__c> optDetails = new Map<String, Detail__c>();
        if (device.Details__r!=null 
                && device.Details__r.size()>0) {
            for (Detail__c tmp :device.Details__r) {
                if (tmp.DetailCategory__c == '筐体') {
                    chassisDetail = tmp;//筐体の登録データ
                }else {
                    optDetails.put(tmp.PricingTableUniqueKey__c, tmp);//明細の登録データ
                }
            }
        }

        //検索結果があるの場合
        if (chassisList.size() > 0) {
            //相   数:(名称3)
            //Map<仕   様, Set<相   数>>
            Map<String, Set<String>> name3Map = new Map<String, Set<String>>();
            //一次電圧:(名称4)
            //二次電圧:(名称5)
            //Map<仕   様, 一次電圧>
            Map<String, Set<String>> name4Map = new Map<String, Set<String>>();
            //周波数 50hz,60hz:(種類名)
            Set<String> categoryList = new Set<String>();

            //kva １列目の内容
            Set<Integer> name6Set = new Set<Integer>();

            //キーで価格表情報を格納する
            Map<String, PricingTable__c> priceMap = new Map<String, PricingTable__c>();

            //キーの設定
            for (PricingTable__c chassisTmp: chassisList) {
                //キーがないの場合、処理しない
                if (String.isBlank(chassisTmp.Name1__c))continue;

                String key = chassisTmp.Name1__c
                            + chassisTmp.Name3__c
                            + chassisTmp.Name4__c
                            + chassisTmp.Name5__c
                            + chassisTmp.CategoryName__c
                            + chassisTmp.Name6__c;
                priceMap.put(key, chassisTmp);

                //相   数:(名称3)
                Set<String> name3Set=name3Map.get(chassisTmp.Name1__c);
                if (name3Set == null || name3Set.size()==0) name3Set=new Set<String>();
                name3Set.add(chassisTmp.Name3__c);
                name3Map.put(chassisTmp.Name1__c, name3Set);

                //二次電圧
                //一次電圧
                Set<String> name4_5Set=name4Map.get(chassisTmp.Name1__c + chassisTmp.Name3__c);
                if (name4_5Set == null || name4_5Set.size()==0) name4_5Set=new Set<String>();
                name4_5Set.add(chassisTmp.Name4__c+'@@@'+chassisTmp.Name5__c);
                name4Map.put(chassisTmp.Name1__c + chassisTmp.Name3__c, name4_5Set);

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
                // 一覧表示内容を設定
                for (Integer intName6 : name6ListSort) {
                    String name6 = intName6.format()+'kVA';
                    if(isSetHeader){
                        List<BodyCell> headerRow1 = new List<BodyCell>();//ヘッダー1行目の1段
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
                        for(String name1 : name3Map.keyset()){
                            Integer namr1ColSpan = 0;
                            //相数 行の内容
                            Set<String> name3Set=name3Map.get(name1);
                            for(String name3 : name3Set){
                                Integer name3ColSpan = 0;

                                Set<String> name4_5Set = name4Map.get(name1 + name3);
                                //二次電圧　行の内容
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
                                //相   数　行の内容
                                headerRow2.add(setCell(name3,(name3ColSpan>0?name3ColSpan*2:null),null,false,false));// 相   数
                                namr1ColSpan = namr1ColSpan + name3ColSpan;
                            }
                             //仕様　１段　行の内容
                            headerRow1.add(setCell(name1,(namr1ColSpan>0?namr1ColSpan*2:null),null,false,false));//仕様
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
                    for(String name1 : name3Map.keyset()){
                        //相数 行の内容
                        Set<String> name3Set=name3Map.get(name1);
                        for(String name3 : name3Set){
                            Set<String> name4_5Set = name4Map.get(name1 + name3);
                            //二次電圧　行の内容
                            for(String name4_5 : name4_5Set){
                                List<String> tmpList = name4_5.split('@@@');
                                String name4 = (tmpList.size() > 0?tmpList.get(0):'');//一次電圧　名称４
                                String name5 = (tmpList.size() > 1?tmpList.get(1):'');//二次電圧　名称５
                                //周波数　行の内容
                                for(String category :categoryList){
                                    String key = name1
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
                                        if (chassisDetail!=null 
                                            && chassisDetail.PricingTableUniqueKey__c == item.UniqueKey__c){
                                            info.inputedId = item.Id;//チェックされた値
                                            info.inputedPrice= price;
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
                    bodyList.add(dataRow);
                }
            }
            info.bodyList = bodyList;
        }
        //H種乾式 付属品テーブル
        List<PricingTable__c> priceList = getDetailRecordsForSeriesTable(bu, screenType, transformerType);
        info.hDrySingleTable = setSeriesTable(screenType, 'H種乾式', '', '単相', priceList, optDetails);//H種乾式 単相
        info.hDryTriangleTable = setSeriesTable(screenType, 'H種乾式', '', '三相', priceList, optDetails);//H種乾式 三相
        return info;
    }

   /**
     *高低圧TR2（機器事業部）画面情報を取得
     *
     * @param device 機器情報
     * @param info   画面情報
     * @param categoryCode 周波数
     * @param bu BU情報
     * @param screenType 画面種類
     * @param transformerType 変圧器種類
     */
    private static ScreenInfo getScreenInfoForLowVoltage(Device__c device,
                                                    ScreenInfo info,
                                                    String categoryCode,
                                                    List<String> bu,
                                                    String screenType,
                                                    String transformerType
                                                    ){
        //検索条件編集
        List<String> condiList = new List<String>();
        if (transformerType=='油入') {
            // ・変圧器機種「油入」の場合
            // かつ 名称1「トップランナー対象外 油」を含む
            condiList.add('Name1__c like \'トップランナー対象外 油%\'');
        }else if (transformerType=='モールド') {
            // ・変圧器機種「モールド」の場合
            // 　かつ 名称9「モ低圧混板なし」or「モ スコット混板なし」
            condiList.add('Name9__c = \'モ低圧混板なし\'');
            condiList.add('Name9__c = \'モ スコット混板なし\'');

        }else if (transformerType=='モールド　混触防止板あり') {
            // 　・変圧器機種「モールド　混触防止板あり」の場合
            // 　　　かつ 名称9「モ低圧混板あり」or「モ スコット混板あり」
            condiList.add('Name9__c = \'モ低圧混板あり\'');
            condiList.add('Name9__c = \'モ スコット混板あり\'');
        }else if (transformerType=='モールド　異電圧') {
            // 　・変圧器機種「モールド　異電圧」の場合
            // 　　　かつ 名称9「モ低圧異電圧・異結線混板なし」
            condiList.add('Name9__c = \'モ低圧異電圧・異結線混板なし\'');
        }else if (transformerType=='モールド　異電圧　混触防止板あり') {
            // 　・変圧器機種「モールド　異電圧　混触防止板あり」の場合
            // 　　　かつ 名称9「モ低圧異電圧・異結線混板あり」
            condiList.add('Name9__c = \'モ低圧異電圧・異結線混板あり\'');
        }
        //価格表を検索する
        List<PricingTable__c> chassisList = getPriceTableInfo(bu, screenType, categoryCode, condiList);

        List<BodyRow> bodyList = new List<BodyRow>();
        List<BodyRow> headerList = new List<BodyRow>();
        info.isNodata=true;//
        //筐体の既存明細データ
        Detail__c chassisDetail;
        Map<String, Detail__c> optDetails = new Map<String, Detail__c>();
        if (device.Details__r!=null 
                && device.Details__r.size()>0) {
            for (Detail__c tmp :device.Details__r) {
                if (tmp.DetailCategory__c == '筐体') {
                    chassisDetail = tmp;//筐体の登録データ
                }else {
                    optDetails.put(tmp.PricingTableUniqueKey__c, tmp);//明細の登録データ
                }
            }
        }

        //検索結果があるの場合
        if (chassisList.size() > 0) {
            //Map<名称1>
            Map<String, String> name1Map = new Map<String, String>{'一次側低圧/二次側低圧' => '','タイトランス' => '','スコット' => ''};
            //相   数:(名称3)
            //Map<仕   様, Set<相   数>>
            Map<String, Set<String>> name3Map = new Map<String, Set<String>>();
            //一次電圧:(名称4)
            //二次電圧:(名称5)
            //Map<仕   様, 一次電圧>
            Map<String, Set<String>> name4Map = new Map<String, Set<String>>();
            //周波数 50hz,60hz:(種類名)
            Set<String> categoryList = new Set<String>();

            //kva １列目の内容
            Set<Integer> name6Set = new Set<Integer>();

            //キーで価格表情報を格納する
            Map<String, PricingTable__c> priceMap = new Map<String, PricingTable__c>();

            //キーの設定
            for (PricingTable__c chassisTmp: chassisList) {
                //キーがないの場合、処理しない
                if (String.isBlank(chassisTmp.Name1__c))continue;

                String key = chassisTmp.Name1__c
                            + chassisTmp.Name3__c
                            + chassisTmp.Name4__c
                            + chassisTmp.Name5__c
                            + chassisTmp.CategoryName__c
                            + chassisTmp.Name6__c;
                priceMap.put(key, chassisTmp);

                //一次側低圧/二次側低圧
                //タイトランス
                //低圧スコット結線
                //高圧スコット結線
                if (chassisTmp.Name1__c.contains('低圧')) {
                    name1Map.put('一次側低圧/二次側低圧',chassisTmp.Name1__c);
                }else if (chassisTmp.Name1__c.contains('タイトランス')) {
                    name1Map.put('タイトランス',chassisTmp.Name1__c);
                }else if (chassisTmp.Name1__c.contains('スコット')) {
                    name1Map.put('スコット',chassisTmp.Name1__c);
                }

                //相   数:(名称3)
                Set<String> name3Set=name3Map.get(chassisTmp.Name1__c);
                if (name3Set == null || name3Set.size()==0) name3Set=new Set<String>();
                name3Set.add(chassisTmp.Name3__c);
                name3Map.put(chassisTmp.Name1__c, name3Set);

                //二次電圧
                //一次電圧
                Set<String> name4_5Set=name4Map.get(chassisTmp.Name1__c + chassisTmp.Name3__c);
                if (name4_5Set == null || name4_5Set.size()==0) name4_5Set=new Set<String>();
                name4_5Set.add(chassisTmp.Name4__c+'@@@'+chassisTmp.Name5__c);
                name4Map.put(chassisTmp.Name1__c + chassisTmp.Name3__c, name4_5Set);

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
                // 一覧表示内容を設定
                for (Integer intName6 : name6ListSort) {
                    String name6 = intName6.format()+'kVA';
                    if(isSetHeader){
                        List<BodyCell> headerRow1 = new List<BodyCell>();//ヘッダー1行目の1段
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
                        for(String name1Key : name1Map.keyset()){
                            Integer namr1ColSpan = 0;
                            String name1 = name1Map.get(name1Key);
                            if (String.isBlank(name1)) continue;//マスタデータがなしの場合　飛ばし 
                            //相数 行の内容
                            Set<String> name3Set=name3Map.get(name1);
                            for(String name3 : name3Set){
                                Integer name3ColSpan = 0;

                                Set<String> name4_5Set = name4Map.get(name1 + name3);
                                //二次電圧　行の内容
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
                                //相   数　行の内容
                                headerRow2.add(setCell(name3,(name3ColSpan>0?name3ColSpan*2:null),null,false,false));// 相   数
                                namr1ColSpan = namr1ColSpan + name3ColSpan;
                            }
                             //仕様　１段　行の内容
                            headerRow1.add(setCell(name1Key,(namr1ColSpan>0?namr1ColSpan*2:null),null,false,false));//仕様
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
                    for(String name1Key : name1Map.keyset()){
                        String name1 = name1Map.get(name1Key);
                        if (String.isBlank(name1)) continue;//マスタデータがなしの場合　飛ばし 
                        //相数 行の内容
                        Set<String> name3Set=name3Map.get(name1);
                        for(String name3 : name3Set){
                            Set<String> name4_5Set = name4Map.get(name1 + name3);
                            //二次電圧　行の内容
                            for(String name4_5 : name4_5Set){
                                List<String> tmpList = name4_5.split('@@@');
                                String name4 = (tmpList.size() > 0?tmpList.get(0):'');//一次電圧　名称４
                                String name5 = (tmpList.size() > 1?tmpList.get(1):'');//二次電圧　名称５
                                //周波数　行の内容
                                for(String category :categoryList){
                                    String key = name1
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
                                        if (chassisDetail!=null 
                                            && chassisDetail.PricingTableUniqueKey__c == item.UniqueKey__c){
                                            info.inputedId = item.Id;//チェックされた値
                                            info.inputedPrice= price;
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
        //付属品テーブル
        List<PricingTable__c> priceList = getDetailRecordsForSeriesTable(bu, screenType, transformerType);
        info.lowVoltageTable = setSeriesTable(screenType, '', '', '', priceList, optDetails);//付属品テーブル
        return info;
    }

   /**
     *内訳入力B_高圧TR2 画面情報を取得
     *
     * @param device 機器情報
     * @param info   画面情報
     * @param categoryCode 周波数
     * @param bu BU情報
     * @param screenType 画面種類
     * @param transformerType 変圧器種類
     * @param exOpt R EXｰα  EXｰβシリーズ条件
     */
    private static ScreenInfo getScreenInfoForHighVoltage(Device__c device,
                                                    ScreenInfo info,
                                                    String categoryCode,
                                                    List<String> bu,
                                                    String screenType,
                                                    String transformerType,
                                                    String exOpt){
        //検索条件編集
        String condiName1 = '';
        if (transformerType=='油入') {
            condiName1='油';
        }else if (transformerType=='モールド') {
            condiName1='モールド';

        }

        //Map<名称1>
        Map<String, String> name1Map = new Map<String, String>();

        //画面シリーズ条件
        Map<String, String> optMap = new Map<String, String>();
        if (String.isNotBlank(exOpt))optMap=(Map<String, String>) JSON.deserialize(exOpt,Map<String, String>.class);
        List<String> condiName10 = new List<String>();
        //ﾄｯﾌﾟﾗﾝﾅｰ条件
        //(Name1__c like 'ﾄｯﾌﾟﾗﾝﾅｰ%油   ﾓｰﾙﾄﾞ %R' AND Name10__c ='一次電圧6600V二次電圧210V'
        if (String.isNotBlank(optMap.get('rSeries'))) {
            name1Map.put('トップランナー変圧器', '');
            condiName10.add(' (Name1__c like \'トップランナー%' + condiName1 + '%R\' '
                         + ' AND Name10__c = \'' + optMap.get('rSeries') + '\') ');
        }
        //αシリーズ条件
        //(Name1__c like 'ｽｰﾊﾟｰ高効率(ｱﾓﾙﾌｧｽ)%油   ﾓｰﾙﾄﾞ %EX-α' AND Name10__c IN ('一次電圧6600V二次電圧210V','一次電圧6600V二次電圧210V混触防止板あり'))
        if (String.isNotBlank(optMap.get('exaSeries'))) {
            name1Map.put('スーパー高効率変圧器EX-α', '');
            condiName10.add(' (Name1__c like \'スーパー高効率%' + condiName1 + '%EX-%α(アモルファス)\' '
                         + ' AND Name10__c = \''+ optMap.get('exaSeries') + '\') ');
        }

        //βシリーズ条件
        //(Name1__c like 'ｽｰﾊﾟｰ高効率(ｱﾓﾙﾌｧｽ)%油   ﾓｰﾙﾄﾞ %EX-β' AND Name10__c IN ('一次電圧6600V二次電圧210V','一次電圧6600V二次電圧210V混触防止板あり'))
        if (String.isNotBlank(optMap.get('exbSeries'))) {
            name1Map.put('スーパー高効率変圧器EX-β', '');
            condiName10.add(' (Name1__c like \'スーパー高効率%' + condiName1 + '%EX-%β\' '
                         + ' AND Name10__c = \''+ optMap.get('exbSeries') + '\') ');
        }
  
        //価格表を検索する
        List<PricingTable__c> chassisList = getPriceTableInfo(bu, screenType, categoryCode, condiName10);

        //筐体の既存明細データ
        Detail__c chassisDetail;
        Map<String, Detail__c> optDetails = new Map<String, Detail__c>();
        if (device.Details__r!=null 
                && device.Details__r.size()>0) {
            for (Detail__c tmp :device.Details__r) {
                if (tmp.DetailCategory__c == '筐体') {
                    chassisDetail = tmp;//筐体の登録データ
                }else {
                    optDetails.put(tmp.PricingTableUniqueKey__c, tmp);//明細の登録データ
                }
            }
        }

        List<BodyRow> bodyList = new List<BodyRow>();
        List<BodyRow> headerList = new List<BodyRow>();
        info.isNodata=true;//
        //検索結果があるの場合
        if (condiName10.size()>0 && chassisList.size() > 0) {

            //仕   様:(名称1,7)
            Map<String, Set<String>> name7Map = new Map<String, Set<String>>();
            //相   数:(名称3)
            //Map<仕   様, Set<相   数>>
            Map<String, Set<String>> name3Map = new Map<String, Set<String>>();
            //一次電圧:(名称4)
            //Map<仕   様, 一次電圧>
            Map<String, String> name4Map = new Map<String, String>();
            //二次電圧:(名称5)
            //Map<相   数, 二次電圧>
            Map<String, String> name5Map = new Map<String, String>();

            //周波数 50hz,60hz:(種類名)
            Set<String> categoryList = new Set<String>();

            //kva １列目の内容
            Set<Integer> name6Set = new Set<Integer>();

            //キーで価格表情報を格納する
            Map<String, PricingTable__c> priceMap = new Map<String, PricingTable__c>();

            //キーの設定
            for (PricingTable__c chassisTmp: chassisList) {
                //キーがないの場合、処理しない
                if (String.isBlank(chassisTmp.Name10__c))continue;

                String key = chassisTmp.Name1__c
                            + chassisTmp.Name7__c
                            + chassisTmp.Name3__c
                            + chassisTmp.Name4__c
                            + chassisTmp.Name5__c
                            + chassisTmp.CategoryName__c
                            + chassisTmp.Name6__c;
                priceMap.put(key, chassisTmp);

                //トップランナー変圧器
                //スーパー高効率変圧器
                //スーパー高効率変圧器
                if (chassisTmp.Name1__c.contains('R')) {
                    name1Map.put('トップランナー変圧器',chassisTmp.Name1__c);
                }else if (chassisTmp.Name1__c.contains('EX-α')
                        || chassisTmp.Name1__c.contains('EX- α')) {
                    name1Map.put('スーパー高効率変圧器EX-α',chassisTmp.Name1__c);
                }else if (chassisTmp.Name1__c.contains('EX-β')
                        ||chassisTmp.Name1__c.contains('EX- β')) {
                    name1Map.put('スーパー高効率変圧器EX-β',chassisTmp.Name1__c);
                }

                //仕様 混板あり 混板なし
                Set<String> name7Set= name7Map.get(chassisTmp.Name1__c);
                if (name7Set == null || name7Set.size()==0) name7Set=new Set<String>();
                name7Set.add(chassisTmp.Name7__c);
                name7Map.put(chassisTmp.Name1__c,name7Set);


                //相   数:(名称3)
                Set<String> name3Set=name3Map.get(chassisTmp.Name1__c + chassisTmp.Name7__c);
                if (name3Set == null || name3Set.size()==0) name3Set=new Set<String>();
                name3Set.add(chassisTmp.Name3__c);
                name3Map.put(chassisTmp.Name1__c + chassisTmp.Name7__c,name3Set);

                //一次電圧(名称4)
                if (name4Map.get(chassisTmp.Name1__c + chassisTmp.Name7__c+ chassisTmp.Name3__c)==null) name4Map.put(chassisTmp.Name1__c + chassisTmp.Name7__c+ chassisTmp.Name3__c,chassisTmp.Name4__c);

                //二次電圧:(名称5)
                if (name5Map.get(chassisTmp.Name1__c + chassisTmp.Name7__c+ chassisTmp.Name3__c)==null) name5Map.put(chassisTmp.Name1__c + chassisTmp.Name7__c+ chassisTmp.Name3__c,chassisTmp.Name5__c);
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
                        List<BodyCell> headerRow1 = new List<BodyCell>();//ヘッダー1行目の1段
                        List<BodyCell> headerRow1_1 = new List<BodyCell>();//ヘッダー1行目の2段
                        List<BodyCell> headerRow2 = new List<BodyCell>();//ヘッダー2行目
                        List<BodyCell> headerRow3 = new List<BodyCell>();//ヘッダー3行目
                        List<BodyCell> headerRow4 = new List<BodyCell>();//ヘッダー4行目
                        List<BodyCell> headerRow5 = new List<BodyCell>();//ヘッダー5行目
    
                        //固定部分を設定
                        headerRow1.add(setCell('仕   様',null,2,false,false));// 仕   様
                        headerRow2.add(setCell('相   数',null,null,false,false));// 相   数
                        headerRow3.add(setCell('一次電圧',null,null,false,false)); // 一次電圧
                        headerRow4.add(setCell('二次電圧',null,null,false,false));// 二次電圧
                        headerRow5.add(setCell('周波数',null,null,false,false));// 周波数(Hz)
                        //ヘッダー設定、キーの組み合わせ
                        for(String name1Key : name1Map.keyset()){
                            Integer namr1ColSpan = 0;
                            String name1 = name1Map.get(name1Key);
                            if (String.isBlank(name1)) continue;//マスタデータがなしの場合　飛ばし 
                            //仕様 混板あり 混板なし
                            Set<String> name7Set = name7Map.get(name1);
                            for(String name7 : name7Set){
                                Integer name7ColSpan = 0;

                                //相数 行の内容
                                Set<String> name3Set=name3Map.get(name1 + name7);
                                for(String name3 : name3Set){
                                    Integer name3ColSpan = categoryList.size();
                                    //周波数　行の内容
                                    for(String category :categoryList){
                                        headerRow5.add(setCell(category,2,null,false,false));//周波数
                                    }
                                    //一次電圧　行の内容
                                    String name4 = name4Map.get(name1 + name7 + name3);
                                    headerRow3.add(setCell(name4,(name3ColSpan>0?name3ColSpan*2:null),null,false,false));// 一次電圧
                                    //二次電圧　行の内容
                                    String name5 = name5Map.get(name1 + name7 + name3);
                                    headerRow4.add(setCell(name5,(name3ColSpan>0?name3ColSpan*2:null),null,false,false));// 二次電圧
                                    //相   数　行の内容
                                    headerRow2.add(setCell(name3,(name3ColSpan>0?name3ColSpan*2:null),null,false,false));// 相   数

                                    name7ColSpan = name7ColSpan + name3ColSpan;//ConSpan数を計上
                                }

                                namr1ColSpan = namr1ColSpan + name7ColSpan;
                                headerRow1_1.add(setCell(name7,(name7ColSpan>0?name7ColSpan*2:null),null,false,false));//仕様
                            }
                            //仕様　１段　行の内容
                            headerRow1.add(setCell(name1Key,(namr1ColSpan>0?namr1ColSpan*2:null),null,false,false));//仕様
                        }
    
                        //ヘッダー設定済み
                        isSetHeader = false;
                        //１行目ヘッダー設定
                        BodyRow row1 = new BodyRow();
                        row1.cellList=headerRow1;
                        headerList.add(row1);
                        BodyRow row1_1 = new BodyRow();
                        row1_1.cellList=headerRow1_1;
                        headerList.add(row1_1);

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
                    for(String name1Key : name1Map.keyset()){
                        String name1 = name1Map.get(name1Key);
                        if (String.isBlank(name1)) continue;//マスタデータがなしの場合　飛ばし 
                        //仕様 混板あり 混板なし
                        Set<String> name7Set = name7Map.get(name1);
                        for(String name7 : name7Set){

                            //相数 行の内容
                            Set<String> name3Set=name3Map.get(name1 + name7);
                            for(String name3 : name3Set){
                                //一次電圧　行の内容
                                String name4 = name4Map.get(name1 + name7 + name3);
                                //二次電圧　行の内容
                                String name5 = name5Map.get(name1 + name7 + name3);

                                //周波数　行の内容
                                for(String category :categoryList){
                                    String key = name1
                                                + name7
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
                                        if (chassisDetail!=null 
                                            && chassisDetail.PricingTableUniqueKey__c == item.UniqueKey__c){
                                            info.inputedId = item.Id;//チェックされた値
                                            info.inputedPrice= price;
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
        //価格表から明細データ（シリーズテーブル）を取得
        List<PricingTable__c> priceList = getDetailRecordsForSeriesTable(bu,screenType, transformerType);
        if (String.isNotBlank(optMap.get('rSeries'))) {
            info.rSeriesSingleTable = setSeriesTable(screenType, condiName1, 'R', '単相', priceList, optDetails);//Rシリーズ　単相
            info.rSeriesTriangleTable = setSeriesTable(screenType, condiName1, 'R', '三相', priceList, optDetails);//Rシリーズ　三相
        }
        if (String.isNotBlank(optMap.get('exaSeries'))) {
            info.exaSeriesSingleTable =  setSeriesTable(screenType, condiName1, 'EX-α', '単相', priceList, optDetails);//EX-αシリーズ　単相
            info.exaSeriesTriangleTable =  setSeriesTable(screenType, condiName1, 'EX-α', '三相', priceList, optDetails);//EX-αシリーズ　三相
        }
        if (String.isNotBlank(optMap.get('exbSeries'))) {
            info.exbSeriesSingleTable =  setSeriesTable(screenType, condiName1, 'EX-β', '単相', priceList, optDetails);//EX-βシリーズ　単相
            info.exbSeriesTriangleTable =  setSeriesTable(screenType, condiName1, 'EX-β', '三相', priceList, optDetails);//EX-βシリーズ　三相
        }
        return info;
    }

    /**
     * 価格表データ取得
     * 
     * @param bu BU条件
     * @param screenType 画面種類
     * @param categoryCode 変圧器
     * @param condiList カスタム条件
     */
    private static List<PricingTable__c> getPriceTableInfo(List<String> bu, 
                                                        String screenType,
                                                        String categoryCode,
                                                        List<String> condiList){
        //画面条件でSQLを作成
        String strSql = ' SELECT  Id, Name, UniqueKey__c, '
                + ' MajorClassificationCode__c, '
                + ' MinorClassificationCode__c,  '
                + ' CategoryCode__c, '
                + ' CategoryName__c, '
                + ' RECNO__c, '
                + ' Name1__c, '
                + ' Name2__c,  '
                + ' Name3__c,  '
                + ' Name4__c,  '
                + ' Name5__c,  '
                + ' Name6__c,  '
                + ' Name7__c,  '
                + ' Name8__c,  '
                + ' Name9__c,  '
                + ' Name10__c,  '
                + ' WC__c,  '
                + ' Price__c,  '
                + ' ConditionForSearchformula__c, '
                + ' CapacityNumber__c, '
                + ' Note__c '
                + ' FROM PricingTable__c '
                + ' WHERE RecordType.DeveloperName = \'Chassis\' '
                + '   AND  MajorClassificationName__c = \'変圧器\' '
                + '   AND  MinorClassificationName__c = \'機器事業部 変圧器\' '
                + '   AND BU__c =:bu '
                + '   AND CategoryCode__c =:categoryCode ';
                if (screenType=='H種乾式変圧器（機器事業部）')  strSql = strSql + ' AND  Name1__c = \'H種乾式 低圧\' ';
                if (condiList.size() > 0){
                    strSql = strSql + '   AND ( '
                                    + String.join(condiList, ' OR ')
                                    + '    ) '
                + ' ORDER BY RECNo__c,Specification1DisplayOrder__c';
                }

        //価格表を検索する
        return Database.query(strSql);
    }


    /**
     * シリーズテーブルの設定
     * 
     * @param screenType 画面種類
     * @param transformerType 変圧器種類(油入、モールド)
     * @param seriesType シリーズ種類（R、EX-α、EX-β）
     * @param phasesType 相数種類（単相、三相）
     * @param priceList 明細データ
     */
    private static CustomTable setSeriesTable(String screenType,
                                                String transformerType, 
                                                String seriesType,
                                                String phasesType,
                                                List<PricingTable__c> priceList,
                                                Map<String, Detail__c> detailMap){
        CustomTable table = new CustomTable();
        Map<String, PricingTable__c> targetList = new Map<String, PricingTable__c>();
        //Map<名称2, Set<名称6>>
        Map<String,Set<String>> name6Map = new Map<String,Set<String>>();//名称2＋名称6
        //処理対象を抽出
        for(PricingTable__c price : priceList) {
            if (screenType == '高低圧TR2（機器事業部）'
                ||
                ( screenType == '高圧TR2（機器事業部）'
                    &&price.Name1__c == (transformerType +' '+seriesType)
                    && price.Name3__c == phasesType)
                ||
                ( screenType == 'H種乾式変圧器（機器事業部）'
                    && price.Name3__c == phasesType)
               
            ){
                //キー
                String key = price.Name2__c + price.Name6__c;
                //付属品名、容量
                Set<String> set6 = name6Map.get(price.Name2__c);
                if (set6==null || set6.size()==0) set6= new Set<String>();
                set6.add(price.Name6__c);
                name6Map.put(price.Name2__c, set6);//キー情報格納
                targetList.put(key,price);//処理対象
            }
        }
        //タイトル設定　例：Rシリーズ(油)　単相
        if (screenType == '高低圧TR2（機器事業部）') {
            table.secTitle = '付属品';
        } else if (screenType == 'H種乾式変圧器（機器事業部）') {
            table.secTitle = transformerType + ' ' + phasesType;
        } else {
            table.secTitle = (seriesType + 'シリーズ('+transformerType+') ' + phasesType);
        }
        //データなしの場合、飛ばし
        if (targetList.size() == 0) return table;

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //付属品名 	容量	単価	数量    
        List<BodyCell> row1 = new List<BodyCell>();  
        row1.add(setCell('付属品名', null, null,false,false));
        row1.add(setCell('容量', null, null,false,false));
        row1.add(setCell('単価', null, null,false,false));
        row1.add(setCell('数量 ', null, null,false,false));
        BodyRow headerRow = new BodyRow();
        headerRow.cellList = row1;
        headerList.add(headerRow);
        table.headerList = headerList;

        //Body の設定
        for(String name2 : name6Map.keyset()){
            Set<String> set6 = name6Map.get(name2);
            Boolean isFirst = true;
            for (String name6 : set6){
                BodyRow row = new BodyRow();
                List<BodyCell> bodyRow  = new List<BodyCell>();
                if(isFirst){
                    bodyRow.add(setCell(name2,null,set6.size(),false,false));//付属品名
                    isFirst = false;//一回のみ設定
                }

                bodyRow.add(setCell(name6, null, null, false,false));//容量
                PricingTable__c priceObj = targetList.get(name2 + name6);
                if (priceObj!=null) {
                    Decimal price = (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(price.format(),null,null,false,true));//単価
                    bodyRow.add(setCell(getQuantityObject(priceObj, detailMap),null,null,true,false));//数量
                }else {
                    bodyRow.add(setCell('―',null,null,false,true));//価格セル
                    bodyRow.add(setCell('―',null,null,false,false));//空白
                }
                row.cellList = bodyRow;
                bodyList.add(row);
            }
        }
        table.bodyList = bodyList;

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
   /**
     * 価格表から明細データ（シリーズテーブル）を取得
     * 
     * @param bu BU情報
     * @param screenType 画面
     * @param transformerType 変圧器種類
     */
    private static List<PricingTable__c> getDetailRecordsForSeriesTable(
                                                    List<String> bu,
                                                    String screenType,
                                                    String transformerType){

        //検索条件編集
        List<String> name1List;
        if (screenType == '高低圧TR2（機器事業部）') {
            name1List = new List<String>{'モールド'};
        }else if (screenType == 'H種乾式変圧器（機器事業部）') {
            name1List = new List<String>{'H乾式'};
        }else if (transformerType == '油入') {
            name1List = new List<String>{'油 R','油 EX-α','油 EX-β'};
        }else if (transformerType == 'モールド') {
            name1List = new List<String>{'モールド R','モールド EX-α'};
        }
        //価格表データが取得
        List<PricingTable__c> priceList = [SELECT Id,UniqueKey__c, Name, RecordType.DeveloperName,
                                                MajorClassificationName__c,//大分類
                                                MinorClassificationName__c, //小分類
                                                CategoryName__c,//種類名
                                                Name1__c, //名称１
                                                Name2__c, //名称２
                                                Name3__c, //名称３
                                                Name4__c, //名称４
                                                Name5__c, //名称５
                                                Name6__c,
                                                WC__c, 
                                                Price__c, //単価
                                                Note__c
                                            FROM PricingTable__c
                                            WHERE RecordType.DeveloperName = 'Detail' 
                                                AND  BU__c=:bu
                                                AND MajorClassificationName__c = '変圧器'
                                                AND MinorClassificationName__c = '機器事業部 変圧器'
                                                AND Name1__c IN :name1List
                                            ORDER BY RECNO__c
                                        ];
        return priceList;
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
    private static BodyCell setCell(Object value,Integer colSpanCnt,Integer rowSpanCnt, Boolean isEdit, Boolean isRight){
        BodyCell cell = new BodyCell();
        cell.isEdit=isEdit;
        cell.isRight=isRight;
        cell.value = value;
        //列結合の設定
        if (colSpanCnt != null){
            cell.colSpanCnt=colSpanCnt;
            cell.isColSpan=true;
        }else{
            cell.isColSpan=false;
        }
        //行結合の設定
        if (rowSpanCnt!=null) {
            cell.rowSpanCnt=rowSpanCnt;
            cell.isRowSpan=true;
        }else {
            cell.isRowSpan=false;
        }
        return cell;
    }

    @AuraEnabled
    /**
     * リスト内容を取得
     *  Rシリーズ
     *  EXｰαシリーズ
     *  EXｰβシリーズ
     * 
     * @param screenType 画面種類
     * @param transformerType 変圧器種類
     */
    public static Map<String, List<Map<String, String>>> getPicklistOptions(
                                                        String screenType,
                                                        String transformerType,
                                                        Integer index) {

        Map<String, List<Map<String, String>>> res = new Map<String, List<Map<String, String>>>();
        List<Map<String, String>> rSeriesOptions = new List<Map<String, String>>();//Rシリーズ
        List<Map<String, String>> exaSeriesOptions = new List<Map<String, String>>();//EXｰαシリーズ
        List<Map<String, String>> exbSeriesOptions = new List<Map<String, String>>();//EXｰβシリーズ

        //メタデータからプルダウンリストを検索
        List<TransformerPullDownList__mdt> optionList = [SELECT 
                                                MajorClassification__c,
                                                MinorClassification__c,
                                                ScreenType__c,
                                                TransformerType__c,
                                                PulldownName__c,
                                                DisplayOrder__c,
                                                ListValue__c, 
                                                DisplayLocation__c 
                                             FROM TransformerPullDownList__mdt 
                                            WHERE MajorClassification__c = '変圧器' //見積項目大分類と一致
                                              AND MinorClassification__c = '機器事業部 変圧器' //見積項目小分類と一致
                                              AND ScreenType__c = :screenType
                                              AND TransformerType__c = :transformerType
                                            Order by PulldownName__c,DisplayOrder__c];
        //ディフォルト表示する
        Integer selectedIndex = 10;
        if (index!=null) selectedIndex=index;
        //戻る値に設定
        for(TransformerPullDownList__mdt option: optionList) {
            Map<String, String> item = new  Map<String, String> ();
            item.put('label', option.ListValue__c);//表示内容の設定
            item.put('value', option.ListValue__c);//Valueの設定
            item.put('order', String.valueof(option.DisplayOrder__c));//key
            if (option.DisplayOrder__c == selectedIndex) item.put('selected', 'true');//selected
            System.debug(option.PulldownName__c);
            if (option.PulldownName__c=='Rシリーズ') {
                rSeriesOptions.add(item);
            }else if (option.PulldownName__c=='EXｰαシリーズ') {
                exaSeriesOptions.add(item);
            }else if (option.PulldownName__c=='EXｰβシリーズ') {
                exbSeriesOptions.add(item);
            }
        }

        // Rシリーズ
        if (rSeriesOptions.size() > 0) {
            res.put('rSeriesOptions',rSeriesOptions);
        }
        // EXｰαシリーズ
        if (exaSeriesOptions.size() > 0) {
            res.put('exaSeriesOptions',exaSeriesOptions);
        }
        // EXｰβシリーズ
        if (exbSeriesOptions.size() > 0) {
            res.put('exbSeriesOptions',exbSeriesOptions);
        }
        return res;
    }
}