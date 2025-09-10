public with sharing class DetailsAddController {
    //画面インフォ
    public class PricingTableWrapper {
        //施設:Facility,水環境:WaterEnvironment,官需:OfficialDemand
        public String bu_Value {get;set;} //BU
        public List<PricingTableCusObj> records {get;set;}   //価格表一覧

        //画面入力情報
        public List<PricingTableInputOnly> intensifyRecords;
        //ページング情報
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}

    }
    //価格表一覧情報
    public class PricingTableCusObj{
        public Boolean isCreate {get;set;}
        public String Id {get;set;}
        public String Name {get;set;}
        public String RecordTypeDeveloperName {get;set;}
        public String MajorClassificationName {get;set;}
        public String MinorClassificationName {get;set;}
        public String Name1 {get;set;}//名称１
        public String Name2 {get;set;}//名称２
        public String Name3 {get;set;}//名称３
        public String Name4 {get;set;}//名称４
        public Decimal CreditWC {get;set;}//単位WC ※入力
        public String CreditWCSpan {get;set;}//単位WC ※入力
        public String CreditWCName {get;set;}//単位WC　識別Id

        public Boolean isPriceTableWC {get;set;}//価格表にWCが指定された
        public Boolean isWCRate {get;set;}//WC算出レートが指定された
        public Decimal WcCalculationRate {get;set;}//WC算出レート

        public Decimal WCCoefficient {get;set;}//WC係数※入力
        public String WCCoefficientName {get;set;}//WC係数　識別Id
        public Decimal UnitPrice{get;set;}//単価
        public String UnitPriceSpan{get;set;}//単価
        public Decimal UnitPriceCoefficient {get;set;}//単価係数※入力
        public String UnitPriceCoefficientName {get;set;}//単価係数　識別Id
        public Decimal ProvisionUnitPrice {get;set;}//提供単価※入力
        public String ProvisionUnitPriceSpan {get;set;}//単位WC ※入力
        public String ProvisionUnitPriceName {get;set;}//提供単価　識別Id

        public Decimal UnitWeight{get;set;}//単位重量
        public String UnitWeightName {get;set;}//提供単価　識別Id
        public String UnitWeightSpan{get;set;}//単価

        public Decimal Quantity {get;set;}//数量※入力
        public String QuantitySpan {get;set;}//数量　表示
        public String QuantityName {get;set;}//数量　識別Id
        public Decimal WC {get;set;}//WC
        public Decimal Price {get;set;}//価格
        public Decimal ProvisionPrice {get;set;}//提供価格
        public Decimal Weight {get;set;}//重量
        public String Note {get;set;}//備考
        public String MasterCode {get;set;}//マスタコード
        public String DetailRecordDisplayNumberText {get;set;}//明細レコード表示順

        public Boolean SpecialFlag {get;set;}//数量を小数点2桁まで許容するフラグ
   }
    //画面数量が入力対象
    public class PricingTableInputOnly{
        public String Id {get;set;}    //価格表Id
        public Decimal Quantity {get;set;}//数量
        public Decimal WCCoefficient {get;set;}//単位WC
        public Decimal CreditWC {get;set;}//WC係数
        public Decimal UnitPriceCoefficient {get;set;}//単価係数
        public Decimal ProvisionUnitPrice {get;set;}//提供単価
        public Decimal UnitWeight {get;set;}//単位重量
        public Decimal WC {get;set;}//WC
        public Decimal Price {get;set;}//価格
        public Decimal ProvisionPrice {get;set;}//提供価格
        public Decimal Weight {get;set;}//重量
    }
    //図記号一覧画面
    public class SymbolObject{
        public String Id {get;set;}    //図記号表Id
        public String SymbolID {get;set;}    //図記号
        public String SymbolName {get;set;}    //名称
        public String CharacterSymbol {get;set;}    //文字記号
    }


    @AuraEnabled
    /**
     * 画面入力データを明細に登録
     * 
     *  @param details  明細入力データ
     *  @param deviceId  見積項目データ
     */
    Public static String submitDetails(String details,
                                      String deviceId){
        try{

            //画面入力された情報
            List<PricingTableInputOnly> priceList;
            if (String.isNotBlank(details)) {
                priceList = (List<PricingTableInputOnly>)JSON.deserialize(details,List<PricingTableInputOnly>.class);
            }
            Set<Id> quoteIds = new Set<Id>();//見積項目Id
            Schema.DescribeSObjectResult d = Detail__c.sObjectType.getDescribe();
            String dPrefix = d.getKeyPrefix();
            
            Set<Id> priceIds = new Set<Id>();//価格表Id
            Schema.DescribeSObjectResult p = PricingTable__c.sObjectType.getDescribe();
            String pPrefix = p.getKeyPrefix();
            
            for(PricingTableInputOnly obj : priceList){    
                String headFiled = obj.Id.substring(0, 3);  //先頭から3文字
                if (pPrefix == headFiled) {
                    priceIds.add((Id)obj.Id);
                }else if (dPrefix == headFiled) {
                    quoteIds.add((Id)obj.Id);
                }
            }
            
            Map<Id, PricingTable__c> priceMap;
            //価格表検索
            if (priceIds.size()>0){
                priceMap = new Map<Id,PricingTable__c>([SELECT Id,RecordType.DeveloperName,
                                                                UniqueKey__c, Name, MajorClassificationCode__c, MajorClassificationName__c, 
                                                                MinorClassificationCode__c, MinorClassificationName__c,
                                                                CategoryCode__c, CategoryName__c, RECNO__c, 
                                                                Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c,
                                                                Name7__c, Name8__c, Name9__c, Name10__c,
                                                                WC__c, Price__c, ProvisionPrice__c,
                                                                WcCalculationRate__c,
                                                                Note__c,Weight__c,DisplayName__c, MasterCode__c,DetailRecordDisplayNumberText__c,
                                                                detailedStatementText__c,SpecialSpecificationNo__c
                                                        FROM PricingTable__c
                                                        WHERE Id IN:priceIds
                                                        ]);
            }
            Map<Id, Detail__c> detailsMap;
            //明細検索
            if (quoteIds.size() > 0){
                detailsMap = new  Map<Id, Detail__c>([
                                    SELECT Id,PricingTableUniqueKey__c, Name, DetailCategory__c,
                                        MajorClassificationCode__c, MajorClassificationName__c, 
                                        MinorClassificationCode__c, MinorClassificationName__c, 
                                        CategoryCode__c, CategoryName__c, RECNO__c,  detailedStatementText__c,
                                        SpecialSpecificationNo__c,
                                        Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c, 
                                        Name7__c, Name8__c, Name9__c, Name10__c, 
                                        CreditWC__c, WcCoefficient__c, WcCalculationRate__c, 
                                        UnitPrice__c, UnitPriceCoefficient__c, 
                                        ProvisionUnitPrice__c, CreditWeight__c, 
                                        Quantity__c, WC__c, Price__c, ProvisionPrice__c, Weight__c, Note__c,MasterCode__c,DetailRecordDisplayNumberText__c
                                    FROM Detail__c
                                    WHERE Id IN:quoteIds
                                    ]);
            }
                
            //登録対象
            List<Detail__c> detailList = new List<Detail__c>();
            for(PricingTableInputOnly obj : priceList){
                String pId = obj.Id;
                String headFiled = pId.substring(0, 3);  //先頭から3文字
                
                
                //価格表情報
                PricingTable__c pricingTable;
                //明細情報
                Detail__c originaldetail;
                if (pPrefix == headFiled && priceMap!=null) {
                    pricingTable = priceMap.get(pId);
                }else if (dPrefix == headFiled && detailsMap!=null) {
                    originaldetail = detailsMap.get(pId);
                }
                
                Decimal quantity = obj.Quantity;
                if(quantity!=null && quantity != 0) {
                    Detail__c detail = new Detail__c();
                    detail.WcCoefficient__c = obj.WCCoefficient;//単位WC
                    detail.CreditWC__c = obj.CreditWC;//WC係数
                    detail.UnitPriceCoefficient__c = obj.UnitPriceCoefficient;//単価係数
                    //detail.ProvisionUnitPrice__c = obj.ProvisionUnitPrice;//提供単価
                    detail.Quantity__c = quantity;//数量
                    detail.Device__c = deviceId;//機器ID

                    //参照の明細情報より明細設定
                    if (dPrefix == headFiled && originaldetail != null){
                        detail.Note__c = originaldetail.Note__c;//備考
                        detail.UnitPrice__c  = originaldetail.UnitPrice__c;//単価
                        detail.Name = originaldetail.Name;//価格表.表示用テキスト
                        
                        detail.Name1__c = originaldetail.Name1__c;//名称１
                        detail.Name2__c = originaldetail.Name2__c;//名称２
                        detail.Name3__c = originaldetail.Name3__c;//名称３
                        detail.Name4__c = originaldetail.Name4__c;//名称４

                        detail.Name5__c = originaldetail.Name5__c;//名称5
                        detail.Name6__c = originaldetail.Name6__c;//名称6
                        detail.Name7__c = originaldetail.Name7__c;//名称7
                        detail.Name8__c = originaldetail.Name8__c;//名称8
                        detail.Name9__c = originaldetail.Name9__c;//名称9
                        detail.Name10__c = originaldetail.Name10__c;//名称10

                        detail.DetailCategory__c=originaldetail.DetailCategory__c;//"筐体" "明細"
                        //RECNO 「大分類名」「大分類コード」「小分類名」「小分類コード」「種類名」「種類コード」
                        detail.RECNO__c = originaldetail.RECNO__c;//RECNO
                        detail.MajorClassificationName__c = originaldetail.MajorClassificationName__c;//大分類名
                        detail.MajorClassificationCode__c = originaldetail.MajorClassificationCode__c;//大分類コード
                        detail.MinorClassificationName__c = originaldetail.MinorClassificationName__c;//小分類名
                        detail.MinorClassificationCode__c = originaldetail.MinorClassificationCode__c;//小分類コード
                        detail.CategoryName__c = originaldetail.CategoryName__c;//種類名
                        detail.CategoryCode__c = originaldetail.CategoryCode__c;//種類コード
                        detail.detailedStatementText__c = originaldetail.detailedStatementText__c;//価格表.内訳書出力用テキスト
                        detail.SpecialSpecificationNo__c= originaldetail.SpecialSpecificationNo__c;//価格表.特殊仕様No


                        detail.CreditWeight__c = originaldetail.CreditWeight__c;//単位重量
                        detail.ProvisionUnitPrice__c = originaldetail.ProvisionUnitPrice__c;//提供単価
                        detail.WcCalculationRate__c=originaldetail.WcCalculationRate__c;//WC算出レート
                        detail.PricingTableUniqueKey__c = originaldetail.PricingTableUniqueKey__c;//価格表ユニークキー
                        detail.MasterCode__c = originaldetail.MasterCode__c;//マスタコード
                        detail.DetailRecordDisplayNumberText__c = originaldetail.DetailRecordDisplayNumberText__c;//明細レコード表示順
                        detailList.add(detail);
                    }

                    //価格表情報情報より明細設定
                    if (pPrefix == headFiled && pricingTable != null){
                        if(String.isNotBlank(pricingTable.Note__c)){
                            detail.Note__c = pricingTable.Note__c;//備考
                            if(obj.WCCoefficient != null && obj.CreditWC != null){
                                detail.Note__c += ' WC×' + String.valueOf(obj.WCCoefficient);
                            }else if(obj.UnitPriceCoefficient != null && pricingTable.Price__c != null){
                                detail.Note__c += ' 単価×' + String.valueOf(obj.UnitPriceCoefficient);
                            }
                        }else if(String.isBlank(pricingTable.Note__c)){
                            if(obj.WCCoefficient != null && obj.CreditWC != null){
                                detail.Note__c = 'WC×' + String.valueOf(obj.WCCoefficient);
                            }else if(obj.UnitPriceCoefficient != null && pricingTable.Price__c != null){
                                detail.Note__c = '単価×' + String.valueOf(obj.UnitPriceCoefficient);
                            }
                        }
                        detail.UnitPrice__c  = pricingTable.Price__c;//単価
                        detail.Name = (String.isNotBlank(pricingTable.DisplayName__c)?pricingTable.DisplayName__c.left(80):'');//価格表.表示用テキスト
                        
                        if (pricingTable.RecordType.DeveloperName=='Chassis') {
                            detail.DetailCategory__c='筐体';//"筐体" "明細"
                        }else{
                            detail.DetailCategory__c='明細';//"筐体" "明細"
                        }
                        detail.Name1__c = pricingTable.Name1__c;//名称１
                        detail.Name2__c = pricingTable.Name2__c;//名称２
                        detail.Name3__c = pricingTable.Name3__c;//名称３
                        detail.Name4__c = pricingTable.Name4__c;//名称４
                        detail.Name5__c = pricingTable.Name5__c;//名称5
                        detail.Name6__c = pricingTable.Name6__c;//名称6
                        detail.Name7__c = pricingTable.Name7__c;//名称7
                        detail.Name8__c = pricingTable.Name8__c;//名称8
                        detail.Name9__c = pricingTable.Name9__c;//名称9
                        detail.Name10__c = pricingTable.Name10__c;//名称10
                        //RECNO 「大分類名」「大分類コード」「小分類名」「小分類コード」「種類名」「種類コード」
                        detail.RECNO__c = pricingTable.RECNO__c;//RECNO
                        detail.MajorClassificationName__c = pricingTable.MajorClassificationName__c;//大分類名
                        detail.MajorClassificationCode__c = pricingTable.MajorClassificationCode__c;//大分類コード
                        detail.MinorClassificationName__c = pricingTable.MinorClassificationName__c;//小分類名
                        detail.MinorClassificationCode__c = pricingTable.MinorClassificationCode__c;//小分類コード
                        detail.CategoryName__c = pricingTable.CategoryName__c;//種類名
                        detail.CategoryCode__c = pricingTable.CategoryCode__c;//種類コード
                        detail.detailedStatementText__c = pricingTable.detailedStatementText__c;//価格表.内訳書出力用テキスト
                        detail.SpecialSpecificationNo__c= pricingTable.SpecialSpecificationNo__c;//価格表.特殊仕様No
                        detail.CreditWeight__c = pricingTable.Weight__c;//単位重量
                        detail.ProvisionUnitPrice__c = pricingTable.ProvisionPrice__c;//提供単価
                        detail.WcCalculationRate__c=pricingTable.WcCalculationRate__c;//WC算出レート
                        detail.PricingTableUniqueKey__c = pricingTable.UniqueKey__c;//価格表ユニークキー
                        detail.MasterCode__c = pricingTable.MasterCode__c;//マスタコード
                        detail.DetailRecordDisplayNumberText__c = pricingTable.DetailRecordDisplayNumberText__c;//明細レコード表示順
                        // 2024/02/19 TS田村 追記
                        Boolean containsEvtPtLa = containsEVT_PT_LA(pId,quantity);
                        if(containsEvtPtLa != true){
                            detailList.add(detail);
                        }
                    }
                }
            }
            if (detailList.size() > 0) Insert detailList;
            //機器情報を取得
            List<Device__c> deviceList = DeviceController.getDevice(deviceId);
            return deviceList.get(0).Quote__c;
        } catch(Exception ex) {
            System.debug('An Exception: '+ex);
            return 'error';
        }
    }

    @AuraEnabled
    /**
     * 画面指定情報により、価格表を検索する（図記号検索）
     * 
     *  @param bu    BU検索条件
     *  @param mdtIdList メタデータIdリスト
     */
    Public static String getPricingTableRecordsByImage(
                                            String deviceId,
                                            List<String> mdtIdList,
                                            Integer pageSize, 
                                            Integer pageNumber,
                                            String intensifyRecords
                                            ){
        //画面入力情報
        List<PricingTableInputOnly> priceList;
        if (String.isNotBlank(intensifyRecords)) {
            priceList = (List<PricingTableInputOnly>) JSON.deserialize(intensifyRecords, List<PricingTableInputOnly>.class);
        }
        //画面情報を設定して戻る
        PricingTableWrapper objDT =  new PricingTableWrapper();
        //メタデータから検索条件を取得
        List<SymbolObject__mdt> mdtList = [Select Id,SymbolID__c,
                            SymbolName__c,CharacterSymbol__c,
                            InstrumentSymbol__c
                            From SymbolObject__mdt
                            WHERE Id = :mdtIdList];

        //条件作成
        List<String> searchCondition = new List<String>();
        for(SymbolObject__mdt so : mdtList){
            String character = (so.CharacterSymbol__c==null?'':so.CharacterSymbol__c);
            String instrument = (so.InstrumentSymbol__c==null?'':so.InstrumentSymbol__c);
            searchCondition.add(character +'@'+ instrument);
        }

        //見積のレコードタイプ
        Device__c device = [SELECT Id, 
                    toLabel(MajorClassification__c), //機器大分類
                    MinorClassification__c, //機器小分類
                    Quote__r.PowerFrequency__c, //機器周波数
                    Quote__r.RecordType.DeveloperName //レコードタイプ
                    FROM Device__c WHERE Id =:deviceId LIMIT 1];
        String quoteRecordType = device.Quote__r.RecordType.DeveloperName;//レコードタイプ
        //価格表.BUが見積.レコードタイプに応じた値（施設=S、水環境/官需=M）」
        // 水環境と官需の場合はいずれも「Ｍ」と「Ｋ」両方を検索対象
        List<String> bu = new List<String>();
        if (quoteRecordType=='Facility'){
            bu.add('S');
            objDT.bu_Value='S';
        }else {
            objDT.bu_Value='NOT_S';
            bu.add('M');
            bu.add('K');
        }
        String major = device.MajorClassification__c;
        String minor = device.MinorClassification__c;
        String powerFrequency = device.Quote__r.PowerFrequency__c;//機器周波数
        //周波数　条件の指定
        List<String> detailPFList = new List<String>();
        //筐体の周波数条件
        String categoryCode = '00';
        //明細の周波数条件
        detailPFList.add('00Hz');
        if (String.isNotBlank(powerFrequency)) {
            //見積に指定された場合、周波数条件を追加
            detailPFList.add(powerFrequency);
            //大分類が「変圧器」or「発電機」の場合は筐体の周波数条件設定
            //大分類がそれ以外の場合は筐体の周波数は全て'01'になる
            
            //⑦大分類「変圧器」かつ小分類「変圧器収納盤」or「バスダクト」の場合は種類コードの条件は"00"固定とする
            // 小分類「変圧器収納盤」or「バスダクト」　の以外　"01"or"02"に切り替える
            if((major == '変圧器' && minor!='変圧器収納盤' && minor!='バスダクト')
                || major == '発電機'
                //⑤大分類「高圧コンビ」かつ小分類「高圧コンデンサ・リアクトル」の場合も周波数によって種類コードの条件を"01"or"02"に切り替える
                || (major == '高圧コンビ' && minor=='高圧コンデンサ・リアクトル')
                //⑥大分類「進相コンデンサ/リアクトル」の場合も周波数によって種類コードの条件を"01"or"02"に切り替える
                || major == '進相コンデンサ/リアクトル'
            ){
                categoryCode = (powerFrequency=='50Hz'?'01':'02');
            } else {
                categoryCode = '00';
            }
        }

        //価格表用SQL
        String query = 'SELECT  COUNT() '
                            + ' FROM PricingTable__c '
                            + ' WHERE BU__c  =:bu ' 
                            + '   AND SymbolAndNumber__c =:searchCondition '
                            + '   AND ( '
                            + '        ( RecordType.DeveloperName = \'Detail\''
                            + '        AND Frequency__c =:detailPFList )' 
                            + '     OR ( RecordType.DeveloperName = \'Chassis\''
                            + '        AND CategoryCode__c  =:categoryCode )'
                            + ' ) ';

        String column = ' Id,UniqueKey__c, Name,RecordType.DeveloperName, '
                        + ' MajorClassificationCode__c, MajorClassificationName__c, '
                        + ' MinorClassificationCode__c, MinorClassificationName__c, '
                        + ' CategoryCode__c, CategoryName__c, RECNO__c, DisplayName__c,  MasterCode__c,DetailRecordDisplayNumberText__c,  '
                        + ' Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c, '
                        + ' WC__c, WcCalculationRate__c, Price__c, ProvisionPrice__c, Weight__c, Note__c ';

        //ページング条件よる、検索条件のOffset部分を設定
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        Integer totalRecords = Database.countQuery(query);
        query = query.replace('COUNT()', column);
       
        //第1キー：筐体→明細の順、第2キー：価格表.大分類コードの昇順、第3キー：価格表.特殊仕様Noの昇順、第4キー：価格表.小分類コードの昇順、第5キー：価格表.RECNOの昇順
        query = query + ' ORDER By RecordType.DeveloperName,MajorClassificationCode__c,SpecialSpecificationNo__c,MinorClassificationCode__c,RECNo__c';

        List<PricingTable__c> recordsAll = Database.query(query);

        List<PricingTable__c> records = new List<PricingTable__c>();
        //価格表を検索して、画面インフォに設定する
        if (recordsAll != null && recordsAll.size() > offset) {
            //ページ毎にデータ抽出
            for (Integer i = offset ; i < (offset+pageSize); i++) {
                if (i==recordsAll.size()) break;
                records.add(recordsAll.get(i));
            }
        }
        //価格表を検索して、画面インフォに設定する
        List<PricingTableCusObj> pageRecords = setPricingPageRecord(records, priceList);
        //画面情報を設定して戻る
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.records = pageRecords;
        objDT.intensifyRecords = priceList;

        return JSON.serialize(objDT);
    }

    @AuraEnabled
    /**
     * 画面指定情報により、価格表を検索する（マスタ検索）
     * 
     *  @param deviceId 見積項目
     *  @param bu    BU検索条件
     *  @param major 大分類検索条件
     *  @param minor 小分類検索条件
     */
    Public static String getPricingTableRecords(
                                            String deviceId,
                                            String bu,
                                            String major,
                                            String minor,
                                            Integer pageSize, 
                                            Integer pageNumber,
                                            String intensifyRecords
                                            ){
        //画面入力情報
        List<PricingTableInputOnly> priceList;
        if (String.isNotBlank(intensifyRecords)) {
            priceList = (List<PricingTableInputOnly>) JSON.deserialize(intensifyRecords, List<PricingTableInputOnly>.class);
        }
        //見積のレコードタイプ
        Device__c device = [SELECT Id, 
                    toLabel(MajorClassification__c), //機器大分類
                    MinorClassification__c, //機器小分類
                    Quote__r.PowerFrequency__c, //機器周波数
                    Quote__r.RecordType.DeveloperName //レコードタイプ
                    FROM Device__c WHERE Id =:deviceId LIMIT 1];

        String powerFrequency = device.Quote__r.PowerFrequency__c;//機器周波数
        //周波数　条件の指定
        List<String> detailPFList = new List<String>();
        //筐体の周波数条件
        List<String> categoryList = new List<String>{'00'};
        //明細の周波数条件
        detailPFList.add('00Hz');
        if (String.isNotBlank(powerFrequency)) {
            //見積に指定された場合、周波数条件を追加
            detailPFList.add(powerFrequency);
            categoryList.add((powerFrequency=='50Hz'?'01':'02'));
        }

        // ・マスタ検索時には、下記の通りに価格表の検索条件を変更する
        // 　・画面.大分類「変圧器」かつ画面.小分類「高圧変圧器」or「機器事業部 変圧器」の場合、小分類名=「変圧器収納盤」の筐体マスタも一覧に表示する。
        // 　・画面.大分類「高圧コンビ」かつ画面.小分類「高圧コンビ盤」の場合、小分類名「高圧コンデンサ・リアクトル」の筐体マスタも一覧に表示する。
        // 　・画面.大分類「低圧・現場・リレー・ACB盤」かつ画面.小分類「リレー盤」の場合と、画面.大分類「計装機器」かつ画面.小分類「計装盤」の場合は
        //               大分類名「低圧・現場・リレー・ACB盤」かつ小分類名「低圧盤」の筐体マスタも一覧に表示する。
        // 　・画面.大分類「進相コンデンサ/リアクトル」の場合、大分類名｢高圧コンビ」かつ小分類名「高圧コンビ盤」かつ名称3が「F」の筐体マスタも一覧に表示する。
        List<String> majorChassisList = new List<String>();
        List<String> minorChassisList = new List<String>();
        String customChassisSql = '';
        if (major=='変圧器' && (minor=='高圧変圧器' || minor=='機器事業部 変圧器')) {
            majorChassisList.add(major);
            minorChassisList.add(minor);
            minorChassisList.add('変圧器収納盤');
        }else if (major=='高圧コンビ' && minor=='高圧コンビ盤') {
            majorChassisList.add(major);
            minorChassisList.add(minor);
            minorChassisList.add('高圧コンデンサ・リアクトル');
        }else if ((major=='低圧・現場・リレー・ACB盤' && minor=='リレー盤' )
                || (major=='計装機器' && minor=='計装盤' )) {
            majorChassisList.add(major);
            if(major=='計装機器')majorChassisList.add('低圧・現場・リレー・ACB盤');
            minorChassisList.add(minor);
            minorChassisList.add('低圧盤');
        }else if (major=='進相コンデンサ/リアクトル') {
            customChassisSql = ' MajorClassificationName__c  =\'高圧コンビ\'  '
                              +' AND MinorClassificationName__c  =\'高圧コンビ盤\'  '
                              +' AND Name3__c  =\'F\'  ';
        }

        // 不要　⇒⇒⇒・画面.大分類「UPS」かつ画面.小分類名が"2"で始まる(2000シリーズ)場合、明細のクエリ時に小分類の条件を除外する。
        // 　・画面.大分類「発電機」かつ画面.小分類が「エンジン(DG)」or「エンジン(GTG)」の場合、大分類名「発電機」、かつ小分類名「補器関連・共通」の明細マスタも一覧に表示する。
        // 　・画面.大分類「コントロールセンタ(C/C)」かつ画面.小分類が「200V」or「400V」の場合、小分類名「共通」の明細マスタも一覧に表示する。
        // 　・画面.大分類が「CCTVカメラ設備[国交省本省宛て提出機器単体費等]」の場合、選択した小分類に関わらず小分類名＝「カメラ周辺装置」の明細マスタも一覧に表示する。
        // 　・画面.大分類「計装機器」かつ画面.小分類「計装盤」の場合、小分類名＝「ラック･パネル計器」の明細マスタも一覧に表示する。
        List<String> majorDetailList = new List<String>();
        List<String> minorDetailList = new List<String>();
        // 　・画面.大分類or小分類が、価格表.利用分類（価格表.大分類名「共通機器」）に含まれている明細マスタも全て取得して一覧に表示する。
        String customDetailSql = ' UseClassification__c includes ( '
                                    + '\'' +major +  '\'' 
                                    + (String.isNotBlank(minor)?(',\''+minor+'\''):'')
                                    + ' )';

        // if (major=='UPS' && String.isNotBlank(minor) && minor.startsWith('2')) {
        //     majorDetailList.add(major);
        // }else
         if (major=='発電機' && (minor=='エンジン(DG)' || minor=='エンジン(GTG)')) {
            majorDetailList.add(major);
            minorDetailList.add(minor);
            minorDetailList.add('補器関連・共通');
        }else if (major=='コントロールセンタ(C/C)' && (minor=='200V' || minor=='400V')) {
            majorDetailList.add(major);
            minorDetailList.add(minor);
            minorDetailList.add('共通');
        }else if (major=='CCTVカメラ設備[国交省本省宛て提出機器単体費等]') {
            majorDetailList.add(major);
            if (String.isNotBlank(minor)) minorDetailList.add(minor);
            minorDetailList.add('カメラ周辺装置');
        }else if (major=='計装機器' && minor=='計装盤') {
            majorDetailList.add(major);
            minorDetailList.add(minor);
            minorDetailList.add('ラック･パネル計器');
        }
        
        //検索項目
        String column = ' Id,UniqueKey__c, Name,RecordType.DeveloperName, '
                        + ' MajorClassificationCode__c, MajorClassificationName__c, '
                        + ' MinorClassificationCode__c, MinorClassificationName__c, '
                        + ' CategoryCode__c, CategoryName__c, RECNO__c, DisplayName__c, MasterCode__c,DetailRecordDisplayNumberText__c, '
                        + ' Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c, '
                        + ' WC__c, WcCalculationRate__c, Price__c, ProvisionPrice__c, Weight__c, Note__c ';

        //件数算出用SQL
        String query = 'SELECT COUNT() FROM PricingTable__c'
                                + ' WHERE BU__c  =:bu ' 
                                // + '   AND MajorClassificationName__c  =:major ' 
                                // + (String.isNotBlank(minor)?'AND MinorClassificationName__c  =:minor':'')
                                + '   AND ( '
                                + '        ( RecordType.DeveloperName = \'Detail\''
                                + '        AND Frequency__c =:detailPFList ' 
                                 //カスタマイズ条件
                                + '        AND   (   '
                                + '                  ( ' + customDetailSql + ' ) '
                                + '              OR  ( '  ;
        // 大分類　小分類条件の設定
        //条件リストが設定された場合
        if (majorDetailList.size()>0) {
            query =       query + '           MajorClassificationName__c IN :majorDetailList ';
            if (minorDetailList.size()>0) {
                query = query + '   AND MinorClassificationName__c IN :minorDetailList ';
            }
        //条件リスト設定されない場合
        } else {
            //画面条件の設定
            query = query       + '      MajorClassificationName__c  =:major ' 
                                + (String.isNotBlank(minor)?' AND MinorClassificationName__c  =:minor':'');
        }
        query = query           + '                    )) '
                                + '    )' 
                                + ' OR ( RecordType.DeveloperName = \'Chassis\''
                                + '        AND CategoryCode__c  =:categoryList ';
        //条件リストが設定された場合
        if (majorChassisList.size()>0) {
            query =       query + '          AND MajorClassificationName__c IN :majorChassisList ';
            if (minorChassisList.size()>0) {
                query = query + '   AND MinorClassificationName__c IN :minorChassisList ';
            }
        //条件リスト設定されない場合
        } else {
            //画面条件の設定
            query = query       + '   AND   ( '
                                + '     ( MajorClassificationName__c  =:major ' 
                                + (String.isNotBlank(minor)?' AND MinorClassificationName__c  =:minor':'')
                                + '  )   ';
            //カスタマイズ条件がある場合、設定する
            if (String.isNotBlank(customChassisSql)) {
                query = query   + '   OR   ( ' + customChassisSql + ' ) ';
            }
            query = query       + '          )  ';
        }
        query =  query      + '  )'
                            + ' ) ' ;


        //ページング条件よる、検索条件のOffset部分を設定
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        Integer totalRecords = Database.countQuery(query);

        query = query.replace('COUNT()', column);

        //ソート順を追加
        String commonOrder='';
        //ソース順の特別化
        if (major=='高圧受配電盤'){
            commonOrder = 'RECNOforHighVoltage__c,';
        }else if(major=='変圧器' && minor=='高圧変圧器'){
            commonOrder = 'RECNOforTransformerHighVoltage__c,';
        }else if(major=='変圧器' && minor=='機器事業部 変圧器'){
            commonOrder = 'RECNOforEquipmentTransformer__c,';
        }else if(major=='高圧コンビ'){
            commonOrder = 'RECNOforHighCombi__c,';
        }else if(major=='低圧・現場・リレー・ACB盤' && minor=='低圧盤'){
            commonOrder = 'RECNOforLowVoltage__c,';
        }else if(major=='低圧・現場・リレー・ACB盤' && minor=='現場盤'){
            commonOrder = 'RECNOforFieldBoard__c,';
        }else if(major=='低圧・現場・リレー・ACB盤' && minor=='リレー盤'){
            commonOrder = 'RECNOforRelayBoard__c,';
        }else if(major=='低圧・現場・リレー・ACB盤' && minor=='ACB盤'){
            commonOrder = 'RECNOforACBBoard__c,';
        }else if(major=='コントロールセンタ(C/C)'){
            commonOrder = 'RECNOforControlCenter__c,';
        }else if(major=='中継端子・接地端子盤'){
            commonOrder = 'RECNOforRelayGroundingTerminal__c,';
        }   
        //第1キー：筐体→明細の順、第2キー：価格表.大分類コードの昇順、
        //第3キー：価格表.特殊仕様Noの昇順、第4キー：価格表.小分類コードの昇順;
        query += ' ORDER By RecordType.DeveloperName,MajorClassificationCode__c,SpecialSpecificationNo__c,MinorClassificationCode__c,';
        //第5キー：価格表.共通機器用RECNOの昇順、第6キー：価格表.RECNOの昇順
        query += commonOrder; 
        query += 'RECNo__c'; 

        List<PricingTable__c> recordsAll = Database.query(query);

        List<PricingTable__c> records = new List<PricingTable__c>();
        //価格表を検索して、画面インフォに設定する
        if (recordsAll != null && recordsAll.size() > offset) {
            //ページ毎にデータ抽出
            for (Integer i = offset ; i < (offset+pageSize); i++) {
                if (i==recordsAll.size()) break;
                records.add(recordsAll.get(i));
            }
        }

        List<PricingTableCusObj> pageRecords = setPricingPageRecord(records, priceList);
        //画面情報を設定して戻る
        PricingTableWrapper objDT =  new PricingTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.records = pageRecords;
        objDT.intensifyRecords = priceList;

        return JSON.serialize(objDT);
    }

    /**
     * 画面表示する情報を作成
     * 
     *  @param records 価格表データ
     *  @param detailMap 登録された内訳
     */
    private static List<PricingTableCusObj> setPricingPageRecord(
                                    List<PricingTable__c> records,
                                    List<PricingTableInputOnly> priceList){
        Map<String, PricingTableInputOnly> priceMap = new Map<String, PricingTableInputOnly>();
        if (priceList!=null && priceList.size()>0) {
            for (PricingTableInputOnly item: priceList) {
                priceMap.put(item.Id, item);
            }
        }
        List<PricingTableCusObj> rtnList = null;//戻り値
        //検索結果がある場合、編集を行う。
        if (records!=null && records.size() > 0) {
            rtnList = new List<PricingTableCusObj>();
            for (PricingTable__c record : records) {
                PricingTableCusObj item = new PricingTableCusObj();
                item.isCreate = false;
                item.Id = record.Id;
                item.Name = record.Name ;
                item.RecordTypeDeveloperName = record.RecordType.DeveloperName;
                item.MajorClassificationName = record.MajorClassificationName__c;
                item.MinorClassificationName = record.MinorClassificationName__c;
 
                item.Name1 = record.DisplayName__c;
                item.Name2 = record.DetailRecordDisplayNumberText__c;//マスタコードの代わりに明細レコード表示順表示

                item.UnitPrice = record.Price__c;
                //マスタに単価が入っておらず名称2に「EP=WC×◯」と記載されており、
                //更にWC算出レートが設定されているマスタが100件程度存在しています。
                if (String.isNotBlank(record.Name2__c) && record.Name2__c.contains('EP=WC')) {
                    item.isWCRate = true;
                    List<String> parts = record.Name2__c.split('×');
                    String wcRate = parts[parts.size()-1];
                    item.WcCalculationRate = decimal.valueOf(wcRate);
                    item.WCCoefficient = item.WcCalculationRate;
                }else {
                    item.isWCRate = false;
                }

                item.isPriceTableWC = false;
                //価格表にWC__cが指定された場合
                if (record.WC__c != null) {
                    item.isPriceTableWC = true;
                    //単位WC
                    item.CreditWC = record.WC__c;
                    item.CreditWCSpan = record.WC__c.format();
                }
                //コンポネットId
                item.UnitPriceCoefficientName = record.Id+'@UnitPriceCoefficient';
                item.QuantityName = record.Id+'@Quantity';
                item.CreditWCName = record.Id+'@CreditWC';
                item.WCCoefficientName = record.Id+'@WCCoefficient';
                item.ProvisionUnitPriceName = record.Id+'@ProvisionUnitPrice';
                item.UnitWeightName = record.Id+'@UnitWeight';
                //単位重量、重量
                item.UnitWeight =  record.Weight__c;
                item.UnitWeightSpan =  (item.UnitWeight!=null?item.UnitWeight.format():'');
                //提供単価＝提供単価（内訳）
                item.ProvisionUnitPrice = record.ProvisionPrice__c;
                item.ProvisionUnitPriceSpan = (item.ProvisionUnitPrice!=null?item.ProvisionUnitPrice.format():'');

                //内訳に登録された場合、数量、価格を設定
                //単価係数＝単価係数（内訳）
                item.UnitPriceCoefficient=null;
                item.Price = null;
                //数量＝数量（内訳）
                item.Quantity = null;
                item.QuantitySpan ='';
    
                //WC係数＝WC係数（内訳)
                if(!item.isWCRate)item.WCCoefficient = null;
                //WC＝数量（内訳）＊単位WC（内訳の単位WC）
                item.WC = null;
                //提供単価＝提供単価（内訳）
                //item.ProvisionUnitPrice = null;
                //item.ProvisionUnitPriceSpan = '';
                //提供単価＝数量（内訳）＊提供単価（内訳）
                item.ProvisionPrice = null;
                item.Weight =  null;
                item.Note = record.Note__c;
                item.SpecialFlag = false;
                if(record.MajorClassificationName__c == '大型映像装置' || record.MajorClassificationName__c == '中央監視'){
                    item.SpecialFlag = true;
                }
                //画面入力された場合
                if (priceMap!=null && priceMap.size()>0 && priceMap.get(item.Id) != null) {
                    item.CreditWC = priceMap.get(item.Id).CreditWC;//WC
                    item.CreditWCSpan = (item.CreditWC!=null?item.CreditWC.format():'');
                    item.WCCoefficient = priceMap.get(item.Id).WCCoefficient;//WC係数

                    item.UnitPriceCoefficient=priceMap.get(item.Id).UnitPriceCoefficient;//単価係数
                    item.ProvisionUnitPrice = priceMap.get(item.Id).ProvisionUnitPrice;//提供単価
                    item.ProvisionUnitPriceSpan = (item.ProvisionUnitPrice!=null?item.ProvisionUnitPrice.format():'');

                    item.UnitWeight= priceMap.get(item.Id).UnitWeight;//単位重量
                    item.UnitWeightSpan =  (item.UnitWeight!=null?item.UnitWeight.format():'');

                    item.Quantity = priceMap.get(item.Id).Quantity;//数量
                    item.QuantitySpan =(item.Quantity!=null?item.Quantity.format():'');

                    item.Price = priceMap.get(item.Id).Price;//価格
                    item.WC =priceMap.get(item.Id).WC;//WC
                    item.ProvisionPrice =priceMap.get(item.Id).ProvisionPrice;//提供価格
                    item.Weight =priceMap.get(item.Id).Weight;//重量
                }
                rtnList.add(item);
            }
        }
        return rtnList;
    }

    @AuraEnabled
    /**
     * 画面指定情報により、明細を検索する（見積検索）
     * 
     *  @param nameId 見積項目検索条件
     */
    Public static String getDetailTableRecords(String nameId,
                                            Integer pageSize, 
                                            Integer pageNumber,
                                            String intensifyRecords){
        //明細用SQL
        String query = 'SELECT COUNT() '
                        + ' FROM Detail__c '
                        + ' WHERE Device__c  =:nameId '
                        + '   AND DetailCategory__c  <>  \'仕様\' ';

        String column = ' Id,PricingTableUniqueKey__c, Name, '
                    + ' MajorClassificationCode__c, MajorClassificationName__c, '
                    + ' MinorClassificationCode__c, MinorClassificationName__c, '
                    + ' CategoryCode__c, CategoryName__c, RECNO__c,  '
                    + ' Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c, '
                    + ' CreditWC__c, WcCoefficient__c, WcCalculationRate__c, '
                    + ' UnitPrice__c, UnitPriceCoefficient__c, '
                    + ' ProvisionUnitPrice__c, CreditWeight__c, '
                    + ' Quantity__c, WC__c, Price__c, ProvisionPrice__c, Weight__c, Note__c ';

        //ページング条件よる、検索条件のOffset部分を設定
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        Integer totalRecords = Database.countQuery(query);

        query = query.replace('COUNT()', column);
        //第1キー：筐体→明細の順、第2キー：価格表.大分類コードの昇順、第3キー：価格表.特殊仕様Noの昇順、第4キー：価格表.小分類コードの昇順、第5キー：価格表.RECNOの昇順
        query = query + ' ORDER BY CreatedDate DESC';

        List<Detail__c> recordsAll = Database.query(query);

        List<Detail__c> records = new List<Detail__c>();

        //画面入力情報
        List<PricingTableInputOnly> priceList;
        if (String.isNotBlank(intensifyRecords)) {
            priceList = (List<PricingTableInputOnly>) JSON.deserialize(intensifyRecords, List<PricingTableInputOnly>.class);
        }

        //価格表を検索して、画面インフォに設定する
        if (recordsAll != null && recordsAll.size() > offset) {
            //画面表示データ抽出
            for (Integer i = offset ; i < (offset+pageSize); i++) {
                if (i==recordsAll.size()) break;
                records.add(recordsAll.get(i));
            }
            //保存データの設定
            if (String.isBlank(intensifyRecords)) {
                priceList = new List<PricingTableInputOnly>();
                for (Detail__c detail :recordsAll) {
                    PricingTableInputOnly newItem = new PricingTableInputOnly();
                    newItem.Id = detail.Id;
                    newItem.Quantity = detail.Quantity__c;
                    newItem.WCCoefficient = detail.WcCoefficient__c;
                    newItem.CreditWC = detail.CreditWC__c;
                    newItem.UnitPriceCoefficient = detail.UnitPriceCoefficient__c;
                    newItem.ProvisionUnitPrice = detail.ProvisionUnitPrice__c;
                    newItem.UnitWeight = detail.CreditWeight__c;
                    newItem.WC = detail.WC__c;
                    newItem.Price = detail.Price__c;
                    newItem.ProvisionPrice = detail.ProvisionPrice__c;
                    newItem.Weight = detail.Weight__c;
                    
                    priceList.add(newItem);
                }
            }
        }

        //価格表を検索して、画面インフォに設定する
        List<PricingTableCusObj> pageRecords = setDetailPageRecord(records, priceList);
        system.debug(priceList);
        //画面情報を設定して戻る
        PricingTableWrapper objDT =  new PricingTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.records = pageRecords;
        objDT.intensifyRecords = priceList;

        return JSON.serialize(objDT);
    }
    /**
     * 画面表示する情報を作成
     * 
     *  @param records 価格表データ
     *  @param detailMap 登録された内訳
     */
    private static List<PricingTableCusObj> setDetailPageRecord(
                                    List<Detail__c> records,
                                    List<PricingTableInputOnly> priceList){
        List<PricingTableCusObj> rtnList = null;//戻り値

        //画面入力された情報
        Map<String, PricingTableInputOnly> priceMap = new Map<String, PricingTableInputOnly>();
        if (priceList!=null && priceList.size()>0) {
            for (PricingTableInputOnly item: priceList) {
                priceMap.put(item.Id, item);
            }
        }

        //検索結果がある場合、編集を行う。
        if (records!=null && records.size() > 0) {
            rtnList = new List<PricingTableCusObj>();
            for (Detail__c record : records) {
                PricingTableCusObj item = new PricingTableCusObj();
                item.isCreate = false;
                item.Id = record.Id;
                item.Name = record.Name ;
                item.MajorClassificationName = record.MajorClassificationName__c;
                item.MinorClassificationName = record.MinorClassificationName__c;
                item.Name1 = record.Name;

                item.UnitPrice = record.UnitPrice__c;
                //単価係数＝単価係数（内訳）
                item.UnitPriceCoefficient=record.UnitPriceCoefficient__c;
                //マスタに単価が入っておらず名称2に「EP=WC×◯」と記載されており、
                //更にWC算出レートが設定されているマスタが100件程度存在しています。
                if (String.isNotBlank(record.Name2__c) && record.Name2__c.contains('EP=WC')) {
                    item.isWCRate = true;
                    List<String> parts = record.Name2__c.split('×');
                    String wcRate = parts[parts.size()-1];
                    item.WcCalculationRate = decimal.valueOf(wcRate);
                    item.WCCoefficient = item.WcCalculationRate;
                }else {
                    item.isWCRate = false;
                }

                item.isPriceTableWC = false;
                //単位WC
                item.CreditWC = record.CreditWC__c;
                item.CreditWCSpan = (item.CreditWC!=null?item.CreditWC.format():'');

                //コンポネットId
                item.UnitPriceCoefficientName = record.Id+'@UnitPriceCoefficient';
                item.QuantityName = record.Id+'@Quantity';
                item.CreditWCName = record.Id+'@CreditWC';
                item.WCCoefficientName = record.Id+'@WCCoefficient';
                item.ProvisionUnitPriceName = record.Id+'@ProvisionUnitPrice';
                item.UnitWeightName = record.Id+'@UnitWeight';
                //単位重量、重量
                item.UnitWeight =  record.CreditWeight__c;
                item.UnitWeightSpan = (item.UnitWeight!=null?item.UnitWeight.format():'');
                //提供単価＝提供単価（内訳）
                item.ProvisionUnitPrice = record.ProvisionUnitPrice__c;
                item.ProvisionUnitPriceSpan = (item.ProvisionUnitPrice!=null?item.ProvisionUnitPrice.format():'');

                //内訳に登録された場合、数量、価格を設定
                item.Price = record.Price__c;
                //数量＝数量（内訳）
                item.Quantity = record.Quantity__c;
                item.QuantitySpan =(item.Quantity!=null?item.Quantity.format():'');
    
                //WC係数＝WC係数（内訳)
                if(!item.isWCRate)item.WCCoefficient = record.WcCoefficient__c;
                //WC＝数量（内訳）＊単位WC（内訳の単位WC）
                item.WC = record.WC__c;

                //提供単価＝数量（内訳）＊提供単価（内訳）
                item.ProvisionPrice = record.ProvisionPrice__c;
                item.Weight =  record.Weight__c;
                item.Note = record.Note__c;

                //画面入力された情報が優先に表示
                PricingTableInputOnly price  = priceMap.get(record.Id);
                //画面入力された場合
                if (price!=null) {
                    item.CreditWC = price.CreditWC;//WC
                    item.CreditWCSpan = (item.CreditWC!=null?item.CreditWC.format():'');
                    item.WCCoefficient = price.WCCoefficient;//WC係数

                    item.UnitPriceCoefficient=price.UnitPriceCoefficient;//単価係数
                    item.ProvisionUnitPrice = price.ProvisionUnitPrice;//提供単価
                    item.ProvisionUnitPriceSpan = (item.ProvisionUnitPrice!=null?item.ProvisionUnitPrice.format():'');

                    item.UnitWeight= price.UnitWeight;//単位重量
                    item.UnitWeightSpan =  (item.UnitWeight!=null?item.UnitWeight.format():'');

                    item.Quantity = price.Quantity;//数量
                    item.QuantitySpan =(item.Quantity!=null?item.Quantity.format():'');

                    item.Price = price.Price;//価格
                    item.WC =price.WC;//WC
                    item.ProvisionPrice =price.ProvisionPrice;//提供価格
                    item.Weight =price.Weight;//重量
                    
                }
                rtnList.add(item);
            }
        }
        return rtnList;
    }


    @AuraEnabled
    /**
     * 図記号画面の一覧を検索する（図記号検索起動）
     */
    Public static String getSymbolObjectRecords(){
        List<SymbolObject__mdt> mdtList = [Select Id,SymbolID__c,
                    SymbolName__c,CharacterSymbol__c,
                    InstrumentSymbol__c,DisplayOrder__c
                From SymbolObject__mdt
                Order By DisplayOrder__c];

        List<SymbolObject> rtnList = new List<SymbolObject> ();
        for (SymbolObject__mdt tmp : mdtList) {
            SymbolObject so = new SymbolObject();
            so.Id = tmp.Id;
            so.SymbolID = tmp.SymbolID__c;//図記号ID
            so.SymbolName = tmp.SymbolName__c;//名称
            //文字記号と器具番号を半角スペースで結合し表示。
            so.CharacterSymbol = (String.isNotBlank(tmp.CharacterSymbol__c)?tmp.CharacterSymbol__c:'')
                                +(String.isNotBlank(tmp.InstrumentSymbol__c)?' '+tmp.InstrumentSymbol__c:'');
            rtnList.add(so);
        }
        return JSON.serialize(rtnList);
    }

    @AuraEnabled
    /*
     * 明細追加  画面情報を取得
     * BUが選択の場合、大分類、見積番号のプルダウンリストを取得
     */
    public static Map<String, List<Map<String, String>>> pickedBUAfter(String bu){
        Map<String, List<Map<String, String>>> res = new Map<String, List<Map<String, String>>>();
        //大分類リストの取得
        List<AggregateResult> majorList = [SELECT MajorClassificationName__c, 
                    COUNT(ID) FROM PricingTable__c 
                    WHERE BU__c =:bu   //BUコード
                    AND MajorClassificationName__c != null //空白以外
                    GROUP BY MajorClassificationName__c
                    Order by Max(MajorClassificationCode__c),Max(MinorClassificationCode__c)];
         //大分類リスト設定
        List<Map<String, String>> majorMapList = new List<Map<String, String>>();
        //戻る値に設定
        for(AggregateResult major: majorList) {
            Map<String, String> majorMap = new Map<String, String>();
            majorMap.put('label', (String)major.get('MajorClassificationName__c'));//表示内容の設定
            majorMap.put('value', (String)major.get('MajorClassificationName__c'));//Valueの設定
            majorMapList.add(majorMap);
        }
        res.put('major', majorMapList);
        String searchCondition = (bu=='S'?'Facility':(bu=='M'?'WaterEnvironment':(bu=='K'?'OfficialDemand':'')));
        //見積番号リストの取得
        List<Quote__c> quoteNumberList = [SELECT Id,Name,QuoteNumber__c
                                FROM Quote__c
                                WHERE RecordType.DeveloperName =:searchCondition   //BUコード
                                AND QuoteNumber__c != null //空白以外
                                AND OwnerId = :UserInfo.getUserId()
                                ORDER BY CreatedDate DESC];

        //見積番号リスト設定
        List<Map<String, String>> quoteNumberMapList = new List<Map<String, String>>();
        //戻る値に設定
        for(Quote__c quoteNumber: quoteNumberList) {
            Map<String, String> quoteNumberMap = new Map<String, String>();
            quoteNumberMap.put('label', quoteNumber.QuoteNumber__c);//表示内容の設定
            quoteNumberMap.put('value', quoteNumber.Id);//Valueの設定
            quoteNumberMapList.add(quoteNumberMap);
        }
        res.put('quoteNumber', quoteNumberMapList);
        return res;
    }
    @AuraEnabled
    /*
     * 明細追加  画面情報を取得
     * 大分類が選択の場合、小分類のプルダウンリストを取得
     */
    public static Map<String, List<Map<String, String>>> pickedMajorAfter(String bu,String major){
        Map<String, List<Map<String, String>>> res = new Map<String, List<Map<String, String>>>();
        //小分類リストの取得
        List<AggregateResult> minorList = [SELECT MinorClassificationName__c, 
                    COUNT(ID) FROM PricingTable__c 
                    WHERE BU__c =:bu   //BUコード
                    AND  MajorClassificationName__c =:major   //大分類
                    AND MinorClassificationName__c != null //空白以外
                    GROUP BY MinorClassificationName__c
                    Order by Max(MajorClassificationCode__c),Max(MinorClassificationCode__c)];
         //小分類リスト設定
        List<Map<String, String>> minorMapList = new List<Map<String, String>>();
        //戻る値に設定
        for(AggregateResult minor: minorList) {
            Map<String, String> minorMap = new Map<String, String>();
            minorMap.put('label', (String)minor.get('MinorClassificationName__c'));//表示内容の設定
            minorMap.put('value', (String)minor.get('MinorClassificationName__c'));//Valueの設定
            minorMapList.add(minorMap);
        }
        res.put('minor', minorMapList);

        return res;
    }

    @AuraEnabled
    /*
     * 明細追加  画面情報を取得
     * 見積番号が選択の場合、項目番号のプルダウンリストを取得
     */
    public static Map<String, List<Map<String, String>>> pickedQuoteNumberAfter(
                                        String quoteNumber,
                                        String deviceId){
        Map<String, List<Map<String, String>>> res = new Map<String, List<Map<String, String>>>();
        //項目番号リストの取得
        List<Device__c> nameList = [SELECT Id,Name
                                FROM Device__c
                                WHERE Quote__c =: quoteNumber //見積
                                AND MajorClassification__c NOT IN ('材料','他社、技派・予備品') //「大分類」が「材料」「他社、技派・予備品」の項目番号は除く。
                                AND Name != null //空白以外
                                ORDER BY CreatedDate DESC];

        //項目番号リスト設定
        List<Map<String, String>> nameMapList = new List<Map<String, String>>();
        //戻る値に設定
        for(Device__c name: nameList) {
            if (deviceId==name.Id) continue;
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', name.Name);//表示内容の設定
            nameMap.put('value', name.Id);//Valueの設定
            nameMapList.add(nameMap);
        }
        res.put('name', nameMapList);
        return res;
    } 

    // 2024/02/20 TS田村 追記 EVT・PT・LAでBUが施設の場合にtrueを返す
    @AuraEnabled
    public static Boolean containsEVT_PT_LA(Id pricingTableId, Decimal quantity) {
        pricingTableId= String.valueOf(pricingTableId).left(18);
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

}