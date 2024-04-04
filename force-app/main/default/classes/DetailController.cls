/**
 * 明細入力A画面のコントローラー
 * 
 * @author xu.ll 2022/10/27
 * @version 1.0
 */
public with sharing class DetailController {

    //画面インフォ
    public class PricingTableWrapper {
        public Integer pageSize {get;set;}//ページ毎に表示する件数
        public Integer pageNumber {get;set;}//当前ページ
        public Integer totalRecords {get;set;}//総件数
        public Integer recordStart {get;set;}//Offset開始
        public Integer recordEnd {get;set;}//Offset終了
        public Device__c device {get;set;}//見積項目
        //施設:Facility,水環境:WaterEnvironment,官需:OfficialDemand
        public String quoteRecordType {get;set;} //見積レコードタイプ
        public List<PricingTableCusObj> records {get;set;}   //価格表一覧
        public List<PricingTableNewRowObj> newRecords {get;set;}   //新規追加された情報
        public List<PricingTableInputOnly> intensifyRecords {get;set;} //集約リスト
        HeaderMetaData metaObj {get;set;} 
    }
    //新規追加行の情報
    public class PricingTableNewRowObj{
        public Boolean isCreate {get;set;}//追加行　Flg
        public String Id {get;set;}
        public String Name1 {get;set;}//名称１
        public String Name2 {get;set;}//名称２
        public String Name3 {get;set;}//名称３
        public Decimal CreditWC {get;set;}//単位WC ※入力
        public Decimal WCCoefficient {get;set;}//WC係数※入力
        public Decimal UnitPrice{get;set;}//単価
        public Decimal UnitPriceCoefficient {get;set;}//単価係数※入力
        public Decimal ProvisionUnitPrice {get;set;}//提供単価※入力
        public Decimal UnitWeight {get;set;}//単位重量
        public Decimal Quantity {get;set;}//数量※入力
        public Decimal WC {get;set;}//WC
        public Decimal Price {get;set;}//価格
        public Decimal ProvisionPrice {get;set;}//提供価格
        public Decimal Weight {get;set;}//重量
        public String Note {get;set;}//備考
        public String Name4 {get;set;}//名称４
   }  
    //内訳集約対象
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
        //単価入力可能の場合に利用する
        public Decimal UnitPrice{get;set;}//単価
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
        public Decimal CreditWC {get;set;}//単位WC ※入力
        public String CreditWCSpan {get;set;}//単位WC ※入力
        public String CreditWCName {get;set;}//単位WC　識別Id
        public Boolean isPriceTableWC {get;set;}//価格表にWCが指定された
        public Boolean isWCRate {get;set;}//WC算出レートが指定された
        public Decimal WcCalculationRate {get;set;}//WC算出レート
        public Decimal WCCoefficient {get;set;}//WC係数※入力
        public String WCCoefficientName {get;set;}//WC係数　識別Id

        public Boolean isPriceEdit{get;set;}//価格編集可能（「EP=標準価格×◯◯」の場合）
        public String UnitPriceName{get;set;}//単価　識別Id

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
        public String Name4 {get;set;}//名称４

        public Boolean SpecialFlag {get;set;}//数量を小数点2桁まで許容するフラグ
   }
    //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸ   
    //ヘッダー入力情報
    public class HeaderMetaData{
        public String meta1 {get;set;}//入力欄１
        public String meta2 {get;set;}//入力欄2
        public String meta3 {get;set;}//入力欄3
        public String meta4 {get;set;}//入力欄4
        public String meta5 {get;set;}//入力欄5
        public String meta6 {get;set;}//入力欄6
        public String meta7 {get;set;}//入力欄7
        public String meta8 {get;set;}//入力欄8
        public String meta9 {get;set;}//入力欄9

        //一つでも入力さていないか　判定
        public Boolean isNotBlank(){
            return (String.isNotBlank(meta1)||String.isNotBlank(meta2)||String.isNotBlank(meta3)||String.isNotBlank(meta4)||String.isNotBlank(meta5)||String.isNotBlank(meta6)||String.isNotBlank(meta7)||String.isNotBlank(meta8)||String.isNotBlank(meta9));
        }
    }

   @AuraEnabled
    /**
     * 集約対象を検索する
     * @param intensifyRecords 数量が入力された行情報
     * @param newRecords 新規追加行の入力情報
     */
   Public static String getPricingTableByintensify(
        String intensifyRecords,
        String newRecords){

        //入力情報
        List<PricingTableInputOnly> priceList;
        if (String.isNotBlank(intensifyRecords)) {
            priceList = (List<PricingTableInputOnly>)JSON.deserialize(intensifyRecords,List<PricingTableInputOnly>.class);
        }
        List<PricingTableNewRowObj> newRecordsList;
        Map<String, PricingTableNewRowObj> newRowsMap;
        //追加行情報
        if (String.isNotBlank(newRecords)) {
            newRecordsList = (List<PricingTableNewRowObj>)JSON.deserialize(newRecords,List<PricingTableNewRowObj>.class);
            newRowsMap = new Map<String, PricingTableNewRowObj>();
            for (PricingTableNewRowObj item : newRecordsList) {
                //数量が入力された行だけ　表示対象とする
                newRowsMap.put(item.Id,item);
            }
        }
        System.debug(priceList);
        //画面情報を設定して戻る
        PricingTableWrapper objDT =  new PricingTableWrapper();
        Set<String> ids;
        Map<String, PricingTableInputOnly> detailMap;
        if (priceList!=null && priceList.size()>0) {
            ids = new Set<String>();
            detailMap = new Map<String, PricingTableInputOnly>();
            for (PricingTableInputOnly item : priceList) {
                //数量が入力された行だけ　表示対象とする
                if (item.Quantity != null){
                    if (!item.Id.contains('rowIndex')) ids.add(item.Id);
                    detailMap.put(item.Id,item);
                }
            }
        }else {
            return JSON.serialize(objDT);
        }
        //検索項目
        String column = 'Id, UniqueKey__c, Name,RecordType.DeveloperName, '
                        + 'MajorClassificationCode__c, MajorClassificationName__c, MinorClassificationCode__c, MinorClassificationName__c, '
                        + 'CategoryCode__c, CategoryName__c, RECNO__c,  DisplayName__c, MasterCode__c, '
                        + 'Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c, WC__c,'
                        + 'WcCalculationRate__c, Price__c, Weight__c, Note__c';//,
        //SQL
        String query = 'SELECT ' + column 
                        +' FROM PricingTable__c'
                        +' WHERE Id IN:ids'
                        +' ORDER By RecordType.DeveloperName,MajorClassificationCode__c,SpecialSpecificationNo__c,MinorClassificationCode__c,RECNo__c';

        List<PricingTable__c> records = Database.query(query);
        //一覧表示データ設定
        List<PricingTableCusObj> pageRecords = setPageRecord(records, detailMap, newRowsMap);
        objDT.records = pageRecords;
        objDT.intensifyRecords = priceList;
        objDT.newRecords = newRecordsList;
        return JSON.serialize(objDT);
   }


    @AuraEnabled
    /**
     * 画面指定情報により、価格表を検索する
     * 
     *  @param searchTerm 分類：仕様検索：SpecSearch、コード検索：CodeSearch、名称検索：NameSearch
     *  @param recordId 機器Id
     *  @param pageSize ページ毎に表示する件数
     *  @param pageNumber 当前ページ
     *  @param searchConditions 検索条件
     *  @param intensifyRecords 数量が入力された行情報
     *  @param newRecords 新規追加行の入力情報
     */
    Public static String getPricingTableRecords(
        String searchTerm,
        String recordId,
        Integer pageSize, 
        Integer pageNumber,
        Map<String, List<String>> searchConditions,
        String intensifyRecords,
        String newRecords
    ) {
        System.debug(searchConditions);
        // try {
            //画面情報を設定して戻る
            PricingTableWrapper objDT =  new PricingTableWrapper();
            //機器の検索条件
            String majorClassification,minorClassification,powerFrequency,quoteRecordType;
            //機器情報を取得
            List<Device__c> deviceList = DeviceController.getDevice(recordId);
            if (deviceList != null && deviceList.size() > 0) {
                majorClassification = deviceList.get(0).MajorClassification__c;//機器の大分類
                minorClassification = deviceList.get(0).MinorClassification__c;//機器の小分類
                powerFrequency = deviceList.get(0).Quote__r.PowerFrequency__c;//見積の周波数

                quoteRecordType = deviceList.get(0).Quote__r.RecordType.DeveloperName;//施設:Facility,水環境:WaterEnvironment,官需:OfficialDemand
                objDT.quoteRecordType= quoteRecordType;//見積レコードタイプを画面に戻る
                objDT.device= deviceList.get(0);//機器情報を画面に戻る
            }
            
            Map<String, PricingTableInputOnly> intensifys;
            //画面に入力された値で設定
            if (String.isNotBlank(intensifyRecords)) {
                intensifys = new Map<String, PricingTableInputOnly>();
                List<PricingTableInputOnly> priceList = (List<PricingTableInputOnly>)JSON.deserialize(intensifyRecords,List<PricingTableInputOnly>.class);
                for (PricingTableInputOnly item : priceList) {
                    System.debug(item);
                    //数量が入力された行だけ　表示対象とする
                    intensifys.put(item.Id,item);

                }
            }

            Map<String, PricingTableNewRowObj> newRowsMap;
            List<PricingTableNewRowObj> newRecordsList;

            //画面に入力された値で設定
            if (String.isNotBlank(newRecords)) {
                newRowsMap = new Map<String, PricingTableNewRowObj>();
                newRecordsList = (List<PricingTableNewRowObj>)JSON.deserialize(newRecords,List<PricingTableNewRowObj>.class);
                for (PricingTableNewRowObj item : newRecordsList) {
                    List<String> idsItem = item.Id.split('rowIndex'); 
                    //当前ページの追加行のみ　対象とする
                    if (idsItem.get(0) != String.valueof(pageNumber)) continue;
                    System.debug(item);
                    //表示対象とする
                    newRowsMap.put(item.Id,item);

                }
            }
            //内訳に登録された情報で設定
            if (String.isBlank(intensifyRecords) || String.isBlank(newRecords)) {
                Map<Id, Detail__c> detailMap = getDetailRecordsByDeviceId(recordId);
                //数量設定
                if (String.isBlank(intensifyRecords) ) {
                    intensifys = setIntensifyRecord(detailMap);
                }
                //新規追加行　設定
                if (String.isBlank(newRecords) ) {
                    if (intensifys==null) intensifys = new Map<String, PricingTableInputOnly>();
                    newRowsMap = setNewRecords(recordId, intensifys);
                    newRecordsList = newRowsMap.values();
                }
            }

            //検索項目
            String column = 'Id,UniqueKey__c, Name,RecordType.DeveloperName, '
                            +'MajorClassificationCode__c, MajorClassificationName__c, MinorClassificationCode__c, MinorClassificationName__c, '
                            +'CategoryCode__c, CategoryName__c, RECNO__c, DisplayName__c, MasterCode__c, '
                            +'Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c, '
                            +'WC__c, WcCalculationRate__c, Price__c, Weight__c, Note__c';//,

            //ページング条件よる、検索条件のOffset部分を設定
            Integer offset = (pageNumber - 1) * pageSize;
            Integer recordEnd = pageSize * pageNumber;

            //件数算出用SQL
            String query = 'SELECT COUNT() FROM PricingTable__c';

            //条件
            List<String> conditions = new List<String>();
            List<String> sreenConditions = new List<String>();
            List<String> boardConditions = new List<String>();
            set<String> minorDetailList = new set<String>();
            List<String> minorChassicList = new List<String>();
            
            //2023/01/05 共通機器用RECNO追加対応（TS鈴木）
            String commonOrder = '';

            //仕様検索　または　初期検索　の場合
            if(searchTerm == 'SpecSearch' || searchTerm == '') {

                //大分類「計装機器」、小分類「計装盤」の場合は
                //大分類「低圧・現場・リレー・ACB盤」、小分類「低圧盤」の筐体仕様検索を可能とする
                //大分類「進相コンデンサ/リアクトル」の場合は、大分類「高圧コンビ」の回路F筐体を検索する
                if (!((majorClassification=='計装機器' && minorClassification=='計装盤')
                    || (majorClassification=='進相コンデンサ/リアクトル')) ) {
                    //条件指定の場合、機器の大分類条件を追加            
                    if(String.isNotBlank(majorClassification)) conditions.add('MajorClassificationName__c =:majorClassification');
                    //以下の6つパターンでは、小分類が明細、筐体のそれぞれに追加、共通条件には追加しない。
                    if (!(
                        //機器の大分類が「UPS」かつ小分類が2000台の場合は、明細のクエリ時に小分類の条件のみ無視する
                        (majorClassification=='UPS' && minorClassification.left(1)=='2')
                        //機器.大分類が「発電機」、かつ小分類が「エンジンDG」or「エンジンGTG」の場合、
                        //明細のクエリ時に機器.大分類が「発電機」、かつ小分類「補機関連・共通」の条件を追加する。
                        || (majorClassification=='発電機' && (minorClassification=='エンジン(DG)' || minorClassification=='エンジン(GTG)'))
                        //見積項目.大分類名が「変圧器」かつ見積項目.小分類名が「高低圧変圧器」or「機器事業部 変圧器」の場合、
                        //価格表.小分類名=「変圧器収納盤」を条件追加する。
                        || ((majorClassification=='変圧器'
                            && (minorClassification == '高圧変圧器' || minorClassification == '機器事業部 変圧器')))
                        //見積項目.大分類名が「コントロールセンタ(C/C)」、小分類が「200V」or「400V」の場合、
                        // 小分類「共通」のマスタも表示する。
                        || (majorClassification=='コントロールセンタ(C/C)' &&
                           (minorClassification == '200V' || minorClassification == '400V'))
                        //大分類「高圧コンビ」、小分類「高圧コンビ盤」でA画面を開いた時に、
                        //小分類「高圧コンデンサ・リアクトル」の筐体も一覧に表示する
                        || (majorClassification=='高圧コンビ' && minorClassification=='高圧コンビ盤')
                        //大分類「低圧・現場・リレー・ACB盤」、小分類「リレー盤」の場合と、
                        //大分類「低圧・現場・リレー・ACB盤」、小分類「低圧盤」の筐体仕様検索を可能とする
                        || (majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='リレー盤')
                        || (majorClassification=='CCTVカメラ設備')
                        )
                        ) {
                            //条件指定の場合、機器の小分類条件を追加
                            if(String.isNotBlank(minorClassification)) conditions.add('MinorClassificationName__c =:minorClassification');
                    }
                }

                //画面に指定された仕様１～仕様４の検索条件
                if (searchConditions.get('specificationNames') != null && searchConditions.get('specificationNames').size()>0) {
                    for (Integer i=0; i<searchConditions.get('specificationNames').size(); i++) {
                        if(searchConditions.get('specificationNames')[i] != null && searchConditions.get('specificationNames')[i] != '') {
                            sreenConditions.add('Name' + (i+1) + '__c =' +  '\'' + searchConditions.get('specificationNames')[i] + '\'');
                        }
                    }
                }

                //変圧器の場合　設置場所　標準盤外形寸法　の条件
                if (searchConditions.get('boardNames') != null && searchConditions.get('boardNames').size()>0) {
                    for (Integer i=0; i<searchConditions.get('boardNames').size(); i++) {
                        if(searchConditions.get('boardNames')[i] != null && searchConditions.get('boardNames')[i] != '') {
                            boardConditions.add('Name' + (i+1) + '__c =' +  '\'' + searchConditions.get('boardNames')[i] + '\'');
                        }
                    }
                }
            //コード検索の場合
            } else if(searchTerm == 'CodeSearch') {
                //画面指定のコード条件を追加
                for (Integer i=0; i<searchConditions.get('searchCodes').size(); i++) {
                    if(searchConditions.get('searchCodes')[i] != null && searchConditions.get('searchCodes')[i] != '') {
                        conditions.add('MasterCode__c =' +  '\'' + searchConditions.get('searchCodes')[i] + '\'');
                    }
                }
            //名称検索の場合
            } else if(searchTerm == 'NameSearch') {
                //名称指定された場合、条件を追加
                if(searchConditions.get('searchName')[0] != null && searchConditions.get('searchName')[0] != '') {
                    for (Integer i=0; i<10; i++) {
                        conditions.add('Name' + (i+1) + '__c LIKE ' +  '\'%' + searchConditions.get('searchName')[0] + '%\'');
                    }
                    //2023/01/05 名称検索対象項目追加（TS鈴木）
                    conditions.add('DisplayName__c LIKE ' +  '\'%' + searchConditions.get('searchName')[0] + '%\'');
                    conditions.add('CharacterSymbol__c LIKE ' +  '\'%' + searchConditions.get('searchName')[0] + '%\'');
                    conditions.add('EquipmentNumber__c LIKE ' +  '\'%' + searchConditions.get('searchName')[0] + '%\'');
                }
            }

            //周波数　条件の指定
            List<String> DetailPFList = new List<String>();
            //筐体の周波数条件
            List<String>  categoryCodeList = new List<String>();
            //明細の周波数条件
            DetailPFList.add('00Hz');
            categoryCodeList.add('00');
            if (String.isNotBlank(powerFrequency)) {
                //見積に設定された周波数条件を追加
                DetailPFList.add(powerFrequency);

                if(powerFrequency=='50Hz'){
                    categoryCodeList.add('01');
                }else if(powerFrequency=='60Hz'){
                    categoryCodeList.add('02');
                }
            }
            set<String> intensifyIds;
            //価格表.BUが見積.レコードタイプに応じた値（施設=S、水環境/官需=M）」
            // 水環境と官需の場合はいずれも「Ｍ」と「Ｋ」両方を検索対象
            List<String> buList = new List<String>();
            if (quoteRecordType=='Facility'){
                buList.add('S');
            }else {
                buList.add('M');
                buList.add('K');
            }


            query += ' WHERE ';
            //コード検索の場合              
            if(searchTerm == 'CodeSearch'){
                //周波数条件追加 20230314 追加
                query += '  ( ( RecordType.DeveloperName = \'Detail\' ';
                if (String.isNotBlank(powerFrequency)) query += '     AND Frequency__c =: DetailPFList ';
                query += '       ) OR (RecordType.DeveloperName = \'Chassis\' ';
                if (String.isNotBlank(powerFrequency)) query += '  AND  CategoryCode__c =:categoryCodeList ';
                query += '       ) )';

                query += 'AND ( ';

                //画面指定のコード１～４条件をOR条件として　追加
                query += String.join(conditions, ' OR ');
                //既存データの条件
                if (intensifys != null && intensifys.size()>0) {
                    intensifyIds = intensifys.keyset();
                    query += '  OR Id =:intensifyIds';
                }
                query += ') ';

            //名称検索の場合  
            }else if(searchTerm == 'NameSearch') {
                //施設:Facility,水環境:WaterEnvironment,官需:OfficialDemand
                //見積のレコードタイプにより、BUを条件指定
                //S：施設、M：水環境、K：官需
                if (String.isNotBlank(quoteRecordType)) query += (' BU__c =:buList ');

                //周波数条件追加 20230314 追加
                query += ' AND ( ( RecordType.DeveloperName = \'Detail\' ';
                if (String.isNotBlank(powerFrequency)) query += '     AND Frequency__c =: DetailPFList ';
                query += '       ) OR (RecordType.DeveloperName = \'Chassis\' ';
                if (String.isNotBlank(powerFrequency)) query += '  AND  CategoryCode__c =:categoryCodeList ';
                query += '       ) )';

                //画面指定の名称をOR条件として　名称1～10に追加
                //名称1 Like 「%画面指定条件：名称%」OR
                //名称2 Like 「%画面指定条件：名称%」OR
                query += 'AND ( ';
                query += String.join(conditions, ' OR '); 
                //既存データの条件
                if (intensifys != null && intensifys.size()>0) {
                    intensifyIds = intensifys.keyset();
                    query += '  OR Id =:intensifyIds';
                }
                query += ') ';

            //画面初期表示　または　仕様検索の場合   
            }else{
                
                if (intensifys != null && intensifys.size()>0) {
                    intensifyIds = intensifys.keyset();
                    query += ' Id =:intensifyIds OR (';
                }

                query += ' ( ';
                query += '   RecordType.DeveloperName = \'Detail\'';
                //S：施設、M：水環境、K：官需
                if (String.isNotBlank(quoteRecordType)) query += ' AND BU__c =:buList ';
                if (String.isNotBlank(powerFrequency)) query += ' AND Frequency__c =: DetailPFList ';
                //見積項目.大分類名or小分類名が、価格表.利用分類（価格表.大分類名「共通機器」）に含まれているものを全て取得する。
                query += ' AND UseClassification__c includes (\''+majorClassification+'\''+(String.isNotBlank(minorClassification)?(',\''+minorClassification+'\''):'')+') ';
                query += '  ) OR (';

                // 大分類＝「機器の大分類」 AND
                // 小分類＝「機器の小分類」 AND
                // BU＝「見積のレコードタイプよる指定」 AND
                // (
                // (レコードタイプ＝「明細」AND
                //  周波数＝「00Hz、50Hz、60Hz」)
                // OR
                // (レコードタイプ＝「筐体」AND
                //  種類コード＝  50Hzの場合「01」、60Hzの場合「02」)
                // 名称1＝画面指定条件：仕様１ AND
                // 名称2＝画面指定条件：仕様２  ) 
                // )
                if (conditions!=null && conditions.size()>0) 
                {   query += String.join(conditions, ' AND ');   
                    //施設:Facility,水環境:WaterEnvironment,官需:OfficialDemand
                    //見積のレコードタイプにより、BUを条件指定
                    //S：施設、M：水環境、K：官需
                    if (String.isNotBlank(quoteRecordType)) query += (' AND BU__c =:buList ');
                 }else {
                    //施設:Facility,水環境:WaterEnvironment,官需:OfficialDemand
                    //見積のレコードタイプにより、BUを条件指定
                    //S：施設、M：水環境、K：官需
                    if (String.isNotBlank(quoteRecordType)) query += (' BU__c =:buList ');

                 }
                query += ' AND ( ( RecordType.DeveloperName = \'Detail\' ';
                if (String.isNotBlank(powerFrequency)) query += '     AND Frequency__c =: DetailPFList ';
                //明細に大分類、小分類条件追加
                if ((majorClassification=='計装機器' && minorClassification=='計装盤')
                    || (majorClassification=='進相コンデンサ/リアクトル')) {
                    //大分類10「計装機器」かつ小分類01「計装盤」の場合は、小分類03「ラック･パネル計器」の明細も検索対象とする。
                    List<String> condsMinorList = new List<String>{minorClassification};
                    if ((majorClassification=='計装機器' && minorClassification=='計装盤'))condsMinorList.add('ラック･パネル計器');

                    if(String.isNotBlank(majorClassification))query += '   AND MajorClassificationName__c = :majorClassification';
                    if(String.isNotBlank(minorClassification))query += '   AND MinorClassificationName__c IN :condsMinorList';
                }
                //明細の場合、小分類条件追加
                if ((majorClassification=='変圧器'
                    && (minorClassification == '高圧変圧器' || minorClassification == '機器事業部 変圧器'))
                    || (majorClassification=='高圧コンビ' && minorClassification=='高圧コンビ盤')
                    || (majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='リレー盤')){
                        query += '   AND MinorClassificationName__c = :minorClassification';
                }

                //機器.大分類が「発電機」、かつ小分類が「エンジンDG」or「エンジンGTG」の場合、
                //明細のクエリ時に機器.大分類が「発電機」、かつ小分類「補機関連・共通」の条件を追加する。
                if ((majorClassification=='発電機' && (minorClassification=='エンジン(DG)' || minorClassification=='エンジン(GTG)'))
                    || (majorClassification=='コントロールセンタ(C/C)' && (minorClassification == '200V' || minorClassification == '400V') )
                    || (majorClassification=='CCTVカメラ設備')
                    )
                    {
                    minorDetailList.add(minorClassification);
                    if (majorClassification=='発電機' && (minorClassification=='エンジン(DG)' || minorClassification=='エンジン(GTG)')) minorDetailList.add('補機関連・共通');
                    if (majorClassification=='コントロールセンタ(C/C)' && (minorClassification == '200V' || minorClassification == '400V'))minorDetailList.add('共通');
                    if (majorClassification=='CCTVカメラ設備') minorDetailList.add('カメラ周辺装置');
                    query += '   AND MinorClassificationName__c = :minorDetailList ';
                }

                query += '       ) OR (RecordType.DeveloperName = \'Chassis\' ';
                //見積項目.大分類名が「変圧器」かつ見積項目.小分類名が「高低圧変圧器」or「機器事業部 変圧器」の場合、
                //価格表.小分類名=「変圧器収納盤」を条件追加する。
                if (majorClassification=='変圧器'
                    && (minorClassification == '高圧変圧器' || minorClassification == '機器事業部 変圧器')){
                    query += 'AND ( (';
                    query += ' MinorClassificationName__c = \'変圧器収納盤\'';
                    //画面条件を追加
                    if (boardConditions.size()>0) {
                        query += ' AND ';
                        query += String.join(boardConditions, ' AND ');
                    }
                    query += ' ) OR (';

                //見積項目.大分類名が「高圧コンビ」かつ見積項目.小分類名が「高圧コンビ盤」の場合、
                //価格表.小分類名=「高圧コンデンサ・リアクトル」を条件追加する。
                } else if (majorClassification=='高圧コンビ' && minorClassification=='高圧コンビ盤') {
                    query += 'AND ( (';
                    query += ' MinorClassificationName__c = \'高圧コンデンサ・リアクトル\'';
                    query += ' ) OR (';
                //見積項目.大分類名が「低圧・現場・リレー・ACB盤」かつ見積項目.小分類名が「リレー盤」の場合、
                //価格表.小分類名=「低圧盤」を条件追加する。
                } else if (majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='リレー盤'){
                    query += 'AND ( (';
                    query += ' MinorClassificationName__c = \'低圧盤\'';
                    if (sreenConditions.size()>0) {
                        query += ' AND ';
                        query += String.join(sreenConditions, ' AND ');
                    }
                    query += ' ) OR (';
                //見積項目.大分類名が「計装機器」かつ見積項目.小分類名が「計装盤」の場合、
                //価格表.小分類名=「低圧盤」を条件追加する。
                } else if (majorClassification=='計装機器' && minorClassification=='計装盤'){
                    query += 'AND ( (';
                    query += '     MajorClassificationName__c = \'低圧・現場・リレー・ACB盤\' ';
                    query += ' AND MinorClassificationName__c = \'低圧盤\'';
                    if (sreenConditions.size()>0) {
                        query += ' AND ';
                        query += String.join(sreenConditions, ' AND ');
                    }
                    query += ' ) OR (';
                //見積項目.大分類名が「進相コンデンサ/リアクトル」の場合、
                //価格表.大分類名=高圧コンビ 価格表.小分類名=「高圧コンビ盤」を条件追加する。
                } else if (majorClassification=='進相コンデンサ/リアクトル'){
                    query += 'AND ( (';
                    query += '     MajorClassificationName__c = \'高圧コンビ\' ';
                    query += ' AND MinorClassificationName__c = \'高圧コンビ盤\'';
                    query += ' AND Name3__c = \'F\'';
                    query += ' ) OR (';
                } else {
                    query += ' ';
                }
                //筐体の場合、小分類条件追加
                if ((majorClassification=='UPS')
                    || (majorClassification=='発電機' && (minorClassification=='エンジン(DG)' || minorClassification=='エンジン(GTG)'))
                    || (majorClassification=='コントロールセンタ(C/C)' && (minorClassification == '200V' || minorClassification == '400V') )
                    || (majorClassification=='CCTVカメラ設備')
                    ) {
                    //条件指定の場合、機器の小分類条件を追加
                    if(String.isNotBlank(minorClassification)) query += '  AND  MinorClassificationName__c =:minorClassification';
                    
                }
                //筐体に大分類、小分類条件追加
                if ((majorClassification=='計装機器' && minorClassification=='計装盤')
                    ||(majorClassification=='進相コンデンサ/リアクトル')) {
                    if(String.isNotBlank(majorClassification))query += '   MajorClassificationName__c = :majorClassification';
                    if(String.isNotBlank(minorClassification))query += '   AND MinorClassificationName__c = :minorClassification';
                }
                //筐体の場合、小分類条件追加
                if ( (majorClassification=='変圧器' && (minorClassification == '高圧変圧器' || minorClassification == '機器事業部 変圧器'))
                || (majorClassification=='高圧コンビ' && minorClassification=='高圧コンビ盤')
                || (majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='リレー盤')
                ) {
                    //条件指定の場合、機器の小分類条件を追加
                    if(String.isNotBlank(minorClassification)) query += '     MinorClassificationName__c =:minorClassification';
                }

                if (sreenConditions.size()>0) {
                    query += ' AND ';
                    query += String.join(sreenConditions, ' AND ');
                }
                
                //特別パターンの場合、周波数条件追加
                if ((majorClassification=='変圧器'
                        && (minorClassification == '高圧変圧器' || minorClassification == '機器事業部 変圧器'))
                        || (majorClassification=='高圧コンビ' && minorClassification=='高圧コンビ盤')
                        || (majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='リレー盤')
                        || (majorClassification=='計装機器' && minorClassification=='計装盤')
                        || (majorClassification=='進相コンデンサ/リアクトル'))query += '  ) ) '; 
        
                if (String.isNotBlank(powerFrequency)) query += '  AND  CategoryCode__c =:categoryCodeList ';
                
                query += '  )) )'; 

                if (intensifys != null && intensifys.size()>0) query += ' )';
                
                //2023/01/05 共通機器用RECNO追加対応（TS鈴木） 
                //ソース順の特別化
                if (majorClassification=='高圧受配電盤'){
                    commonOrder = 'RECNOforHighVoltage__c,';
                }else if(majorClassification=='変圧器' && minorClassification=='高圧変圧器'){
                    commonOrder = 'RECNOforTransformerHighVoltage__c,';
                }else if(majorClassification=='変圧器' && minorClassification=='機器事業部 変圧器'){
                    commonOrder = 'RECNOforEquipmentTransformer__c,';
                }else if(majorClassification=='高圧コンビ'){
                    commonOrder = 'RECNOforHighCombi__c,';
                }else if(majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='低圧盤'){
                    commonOrder = 'RECNOforLowVoltage__c,';
                }else if(majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='現場盤'){
                    commonOrder = 'RECNOforFieldBoard__c,';
                }else if(majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='リレー盤'){
                    commonOrder = 'RECNOforRelayBoard__c,';
                }else if(majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='ACB盤'){
                    commonOrder = 'RECNOforACBBoard__c,';
                }else if(majorClassification=='コントロールセンタ(C/C)'){
                    commonOrder = 'RECNOforControlCenter__c,';
                }else if(majorClassification=='中継端子・接地端子盤'){
                    commonOrder = 'RECNOforRelayGroundingTerminal__c,';
                }
            }

            system.debug(query);
            Integer totalRecords = Database.countQuery(query);
            query = query.replace('COUNT()', column);
            //第1キー：筐体→明細の順、第2キー：価格表.大分類コードの昇順、
            //第3キー：価格表.特殊仕様Noの昇順、第4キー：価格表.小分類コードの昇順
            query += ' ORDER By RecordType.DeveloperName,MajorClassificationCode__c,SpecialSpecificationNo__c,MinorClassificationCode__c,';
            //第5キー：価格表.共通機器用RECNOの昇順、第6キー：価格表.RECNOの昇順
            query += commonOrder; 
            query += 'RECNo__c'; 

//2023/01/10 課題3.   Offset 2000件以上制限の対応  Start
            //当前ページのデータを取得するため、LIMIT制御
            // query += ' LIMIT :pageSize OFFSET :offset';
            // System.debug('getPricingTableRecords of query :: ' + query);
            List<PricingTable__c> recordsAll = Database.query(query);

            List<PricingTable__c> records = new List<PricingTable__c>();
            if (recordsAll != null && recordsAll.size() > offset) {
                //ページ毎にデータ抽出
                for (Integer i = offset ; i < (offset+pageSize); i++) {
                    if (i==recordsAll.size()) break;
                    records.add(recordsAll.get(i));
                }
            }
//2023/01/10 課題3.   Offset 2000件以上制限の対応  End
            System.debug(intensifys);
            //一覧表示データ設定
            List<PricingTableCusObj> pageRecords = setPageRecord(records, intensifys, newRowsMap);
            //画面戻る値の設定
            objDT.pageSize = pageSize;
            objDT.pageNumber = pageNumber;
            objDT.recordStart = offset + 1;
            objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            objDT.totalRecords = totalRecords;
            objDT.records = pageRecords;
            objDT.newRecords = newRecordsList;
            objDT.intensifyRecords = (intensifys!=null && intensifys.size() > 0?
                                        intensifys.values()
                                        :null);
            return JSON.serialize(objDT);
    }

    @AuraEnabled
    /**
     * 機器に対して　既に登録済みの内訳情報を取得
     * 
     *  @param deviceId 機器Id
     */
    Public static Map<Id, Detail__c> getDetailRecordsByDeviceId(Id deviceId) {
        try {
            //機器Idより、既に登録済みの内訳情報を取得
            Map<Id, Detail__c> detailsMap = new Map<Id, Detail__c>();
            Map<String, Id> priceIds = new Map<String, Id>();
            List<Detail__c> details = new List<Detail__c>([SELECT Id, 
                                                                DetailCategory__c,
                                                                Quantity__c, 
                                                                //PricingTable__c,
                                                                PricingTableUniqueKey__c,
                                                                CreditWC__c,
                                                                WcCoefficient__c,
                                                                CreditWeight__c,
                                                                UnitPrice__c,
                                                                UnitPriceCoefficient__c,
                                                                ProvisionUnitPrice__c,
                                                                WC__c,
                                                                Price__c,
                                                                ProvisionPrice__c,
                                                                Weight__c
                                                              FROM Detail__c 
                                                              WHERE Device__c =:deviceId]);

            Set<String> uniqueKeys = new Set<String>();
            for (Detail__c item : details) {
                if(item.PricingTableUniqueKey__c!=null) uniqueKeys.add(item.PricingTableUniqueKey__c);
            }
            //ユニークキーより　価格表を検索
            if (uniqueKeys.size() > 0) {
                List<PricingTable__c> priceList = [SELECT Id, UniqueKey__c
                                                    FROM  PricingTable__c
                                                    WHERE UniqueKey__c=:uniqueKeys] ;
                for(PricingTable__c temp : priceList){
                    if(temp.UniqueKey__c!=null) priceIds.put(temp.UniqueKey__c, temp.Id);
                }
            } 

            //一つの価格表情報が内訳には1件しかない。。
            for (Detail__c item : details) {
                if(item.PricingTableUniqueKey__c!=null) {
                    Id priceId = priceIds.get(item.PricingTableUniqueKey__c);
                    if (priceId!=null) detailsMap.put(priceId ,item);
                }
            }
            return detailsMap;
        } catch(Exception ex) {
            System.debug('An Exception: ' + ex);
            return null;
        }
    }

    /**
     * 新規追加行情報を一時保存
     * 
     *  @param deviceId 親画面機器Id
     *  @param intensifys 数量が入力された行情報
     */
    private static Map<String, PricingTableNewRowObj> setNewRecords(
                                    String deviceId,
                                    Map<String, PricingTableInputOnly> intensifys){
        Map<String, PricingTableNewRowObj> rtnMap = new Map<String, PricingTableNewRowObj>();
        List<Detail__c> details = new List<Detail__c>([SELECT Id, Name,Name1__c,Name2__c,Name3__c,Name4__c,Name5__c,
                    Quantity__c, 
                    //PricingTable__c,
                    PricingTableUniqueKey__c,
                    CreditWC__c,
                    CreditWeight__c,
                    WcCoefficient__c,
                    UnitPriceCoefficient__c,
                    UnitPrice__c,
                    ProvisionUnitPrice__c,
                    Note__c,
                    WC__c,
                    Price__c,
                    ProvisionPrice__c,
                    Weight__c
                FROM Detail__c 
                WHERE Device__c =:deviceId
                 AND PricingTableUniqueKey__c = null
                 AND DetailCategory__c <> '仕様']); //新規追加行　情報を検索

        if (details!=null && details.size()>0) {
            Integer rowIndex = 1;
            for (Detail__c detail : details) {
                PricingTableNewRowObj newRow = new PricingTableNewRowObj();
                PricingTableInputOnly inputObj = new PricingTableInputOnly();

                String id = '1rowIndex'+rowIndex;

                newRow.isCreate = true;
                newRow.Id = id;
                //名称1~4の列は削除して、代わりに価格表.表示用テキストと価格表.マスタコードを表示する
                newRow.Name1 = detail.Name;
                newRow.Name2 = '';//マスタコードなし
                newRow.CreditWC = detail.CreditWC__c;
                newRow.WCCoefficient = detail.WcCoefficient__c;
                newRow.UnitPrice = detail.UnitPrice__c;
                newRow.UnitPriceCoefficient = detail.UnitPriceCoefficient__c;
                newRow.ProvisionUnitPrice = detail.ProvisionUnitPrice__c;
                newRow.UnitWeight = detail.CreditWeight__c;
                newRow.Quantity = detail.Quantity__c;
                newRow.WC = detail.WC__c;
                newRow.Price = detail.Price__c;
                newRow.ProvisionPrice = detail.ProvisionPrice__c;
                newRow.Weight = detail.Weight__c;
                newRow.Note = detail.Note__c;
                //追加行情報に保持
                rtnMap.put(id,newRow);

                inputObj.Id = id;
                inputObj.Quantity = newRow.Quantity;
                inputObj.WCCoefficient = newRow.WCCoefficient;
                inputObj.CreditWC = newRow.CreditWC;
                inputObj.UnitPriceCoefficient = newRow.UnitPriceCoefficient;
                inputObj.UnitWeight = newRow.UnitWeight;
                inputObj.WC = detail.WC__c;
                inputObj.Price =  detail.Price__c;
                inputObj.ProvisionPrice =  detail.ProvisionPrice__c;
                inputObj.Weight = detail.Weight__c;
                //入力情報に保持
                intensifys.put(id, inputObj);
                rowIndex = rowIndex + 1;
            }
        }
        return rtnMap;

    }

    /**
     * 数量が入力された価格表データを一時保存
     * 
     *  @param detailMap 登録された内訳
     */
    private static Map<String, PricingTableInputOnly> setIntensifyRecord(Map<Id, Detail__c> detailMap){
        Map<String, PricingTableInputOnly> rtnList = null;//戻り値
        //検索結果がある場合、編集を行う。
        if (detailMap!=null && detailMap.size() > 0) {
            rtnList = new Map<String, PricingTableInputOnly>();
            for(String priceId : detailMap.keyset()){
                Detail__c detail = detailMap.get(priceId);
                if (detail.DetailCategory__c=='仕様') continue;
                PricingTableInputOnly item = new PricingTableInputOnly();
                item.Id = priceId;//価格表Id
                item.Quantity = detail.Quantity__c;//数量
                item.CreditWC = detail.CreditWC__c;//単位WC
                item.WCCoefficient = detail.WcCoefficient__c;//WC係数
                item.UnitPriceCoefficient = detail.UnitPriceCoefficient__c;//単価係数
                item.ProvisionUnitPrice = detail.ProvisionUnitPrice__c;//提供単価
                item.UnitWeight = detail.CreditWeight__c;//重量
                item.WC = detail.WC__c;//WC
                item.Price = detail.Price__c;//価格
                item.ProvisionPrice = detail.ProvisionPrice__c;//提供価格
                item.Weight = detail.Weight__c;//重量
                //単価入力可能の場合、                
                item.UnitPrice = detail.UnitPrice__c;//単価
                rtnList.put(priceId, item);
            }
        }
        return rtnList;
    }

    /**
     * 画面表示する情報を作成
     * 
     *  @param records 価格表データ
     *  @param detailMap 登録された内訳
     *  @param newRowsMap 新規追加行の入力情報
     */
    private static List<PricingTableCusObj> setPageRecord(
                                    List<PricingTable__c> records,
                                    Map<String, PricingTableInputOnly> detailMap,
                                    Map<String, PricingTableNewRowObj> newRowsMap){
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
                //名称1~4の列は削除して、代わりに価格表.表示用テキストと価格表.マスタコードを表示する
                item.Name1 = record.DisplayName__c;
                item.Name2 = record.MasterCode__c;

                item.UnitPrice = record.Price__c;
                item.isPriceEdit = false;//ディフォルトが入力不可。
                item.isWCRate = false;//ディフォルトが「EP=WC×◯」ではない

                //マスタに単価が入っておらず名称2に「EP=WC×◯」と記載されており、
                //更にWC算出レートが設定されているマスタが100件程度存在しています。
                if (String.isNotBlank(record.Name2__c) && record.Name2__c.contains('EP=WC')) {
                    item.isWCRate = true;
                    List<String> parts = record.Name2__c.split('×');
                    String wcRate = parts[parts.size()-1];
                    item.WcCalculationRate = decimal.valueOf(wcRate);
                    item.WCCoefficient = item.WcCalculationRate;
                //名称2が「EP=標準価格×◯◯」と言う形式だった場合、単価の欄を手入力出来るようにする
                }else if (String.isNotBlank(record.Name2__c) && record.Name2__c.contains('EP=標準価格')) {
                    item.isPriceEdit = true;//単価が入力可能にする
                    item.UnitPriceName= record.Id+'@UnitPric';
                    item.UnitPriceSpan = (item.UnitPrice!=null?item.UnitPrice.format():'');
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

                //内訳に登録された場合、数量、価格を設定
                if (detailMap!=null && detailMap.size()>0
                    && detailMap.get(record.Id)!=null) {
                    //単価係数＝単価係数（内訳）
                    item.UnitPriceCoefficient=detailMap.get(record.Id).UnitPriceCoefficient;

                    //価格＝数量（内訳）＊単価（価格表）
                    item.Price = detailMap.get(record.Id).Price;

                    //数量＝数量（内訳）
                    item.Quantity = detailMap.get(record.Id).Quantity;
                    item.QuantitySpan =  (item.Quantity!=null?item.Quantity.format():'');
                    //価格表に設定されない場合のみ　内訳に登録された内容で表示
                    if(!item.isPriceTableWC){
                        //単位WC
                        item.CreditWC = detailMap.get(record.Id).CreditWC;
                        item.CreditWCSpan = (item.CreditWC!=null?item.CreditWC.format():'');

                    }
                    //WC係数＝WC係数（内訳)
                    item.WCCoefficient = (item.isWCRate?item.WcCalculationRate:detailMap.get(record.Id).WCCoefficient);
                    //WC＝数量（内訳）＊単位WC（内訳の単位WC）
                    item.WC = detailMap.get(record.Id).WC;
                    //提供単価＝提供単価（内訳）
                    item.ProvisionUnitPrice = detailMap.get(record.Id).ProvisionUnitPrice;
                    item.ProvisionUnitPriceSpan = (item.ProvisionUnitPrice!=null?item.ProvisionUnitPrice.format():'');
                    //提供単価＝数量（内訳）＊提供単価（内訳）
                    item.ProvisionPrice = detailMap.get(record.Id).ProvisionPrice;

                    //単価入力の場合、明細の単価により設定・表示する。
                    if(item.isPriceEdit) {
                        item.UnitPrice = detailMap.get(record.Id).UnitPrice;
                        item.UnitPriceSpan = (item.UnitPrice!=null?item.UnitPrice.format():'');
                    }

                    item.Weight =  detailMap.get(record.Id).Weight;
                }
                item.Note = record.Note__c;
                item.SpecialFlag = false;
                if(record.MajorClassificationName__c == '大型映像装置' || record.MajorClassificationName__c == '中央監視'){
                    item.SpecialFlag = true;
                }
                rtnList.add(item);
            }
        }

        //新規追加行の情報を設定する
        if (newRowsMap!=null && newRowsMap.size()>0) {
            for(String key : detailMap.keyset()){
                if (!key.contains('rowIndex')) continue;
                if(rtnList==null)rtnList = new List<PricingTableCusObj>();
                PricingTableNewRowObj newRow = newRowsMap.get(key);
                if (newRow==null) continue;//対象がない場合　
                PricingTableCusObj item = new PricingTableCusObj();
                item.isCreate = newRow.isCreate;
                item.Id = key;
                item.Name1 = newRow.Name1;
                item.Name2 = newRow.Name2;

                //単位WC
                item.CreditWC = newRow.CreditWC;
                item.CreditWCSpan = (item.CreditWC!=null?item.CreditWC.format():'');
                //WC係数＝WC係数（内訳)
                item.WCCoefficient = newRow.WCCoefficient;
                //単価
                item.UnitPrice = newRow.UnitPrice;
                item.UnitPriceSpan = (newRow.UnitPrice!=null?newRow.UnitPrice.format():'');
                //単価係数
                item.UnitPriceCoefficient=newRow.UnitPriceCoefficient;
                //提供単価＝提供単価（内訳）
                item.ProvisionUnitPrice = newRow.ProvisionUnitPrice;
                item.ProvisionUnitPriceSpan = (item.ProvisionUnitPrice!=null?item.ProvisionUnitPrice.format():'');
                //単位重量
                item.UnitWeight = newRow.UnitWeight;
                item.UnitWeightSpan = (item.UnitWeight!=null?item.UnitWeight.format():'');
                //コンポネットId
                item.UnitPriceCoefficientName = key+'@UnitPriceCoefficient';
                item.QuantityName = key+'@Quantity';
                item.CreditWCName = key+'@CreditWC';
                item.WCCoefficientName = key+'@WCCoefficient';
                item.ProvisionUnitPriceName = key+'@ProvisionUnitPrice';
                item.UnitWeightName = key+'@UnitWeight';

                //数量＝数量（内訳）
                item.Quantity = newRow.Quantity;
                item.QuantitySpan = (item.Quantity!=null?item.Quantity.format():'');
                //WC＝数量（内訳）＊単位WC（内訳の単位WC）
                item.WC = newRow.WC;
                //価格＝数量（内訳）＊単価（価格表）
                item.Price = newRow.Price;
                //提供単価＝数量（内訳）＊提供単価（内訳）
                item.ProvisionPrice = newRow.ProvisionPrice;
                //重量
                item.Weight = newRow.Weight;

                item.Note = newRow.Note;
                if (rtnList.size()>0) {
                    rtnList.add(0,item);
                }else {
                    rtnList.add(item);
                }
            }
        }

        return rtnList;
    }

    @AuraEnabled
    /**
     * 内訳入力A画面 画面入力内容を内訳に保存
     * 
     * @param details 画面入力された情報
     * @param newRows 行追加情報
     * @param metaObj ヘッダー入力情報
     * @param deviceId 機器Id
     * @param selectedOption 一般管理費
     */
    Public static String setDetail(String details, 
                                String newRows, 
                                String metaObj, 
                                Id deviceId, 
                                Boolean selectedOption) {

        //画面入力された情報
        List<PricingTableInputOnly> priceList;
        if (String.isNotBlank(details)) {
            priceList = (List<PricingTableInputOnly>)JSON.deserialize(details,List<PricingTableInputOnly>.class);
        }
        Map<String, PricingTableNewRowObj> newRowsMap;
        //新規追加行の情報
        if (String.isNotBlank(newRows)) {
            List<PricingTableNewRowObj> newRowsList;
            newRowsMap = new Map<String, PricingTableNewRowObj>();
            newRowsList = (List<PricingTableNewRowObj>)JSON.deserialize(newRows,List<PricingTableNewRowObj>.class);
            for (PricingTableNewRowObj item:newRowsList) {
                newRowsMap.put(item.Id,item);
            }
        }
        
        //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸの場合 ヘッダー入力情報
        HeaderMetaData metaMap;
        Boolean isMACTUS_MELFLEX = false;
        //ヘッダー入力情報
        if (String.isNotBlank(metaObj)){
            metaMap = (HeaderMetaData) JSON.deserialize(metaObj,HeaderMetaData.class);
        } 
        
        Set<Id> pricingTableIds = new Set<Id>();
        try{
            //機器情報を取得
            List<Device__c> deviceList = DeviceController.getDevice(deviceId);

            //内訳を更新
            Map<String,PricingTable__c> insertPrice = new Map<String,PricingTable__c> ();
            for(PricingTableInputOnly obj : priceList){    
                String pId = obj.Id;
                if (!pId.contains('rowIndex')) {
                    pricingTableIds.add((Id)pId);
                }
            }
            //価格表情報情報を取得
            Map<Id,PricingTable__c> pricingTableList = new Map<Id,PricingTable__c>([SELECT Id,RecordType.DeveloperName,
                                            UniqueKey__c, Name, MajorClassificationCode__c, MajorClassificationName__c, 
                                            MinorClassificationCode__c, MinorClassificationName__c,
                                            CategoryCode__c, CategoryName__c, RECNO__c, 
                                            Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c,
                                            Name7__c, Name8__c, Name9__c, Name10__c,
                                            WC__c, Price__c,
                                            WcCalculationRate__c,
                                            Note__c,Weight__c,DisplayName__c,
                                            detailedStatementText__c,SpecialSpecificationNo__c
                                            FROM PricingTable__c
                                            WHERE Id IN:pricingTableIds
                                        ]);

            //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸ または　大型映像装置の場合
            if ((deviceList.get(0).MajorClassification__c == 'MACTUS'
                && (deviceList.get(0).MinorClassification__c == 'CTR'
                    || deviceList.get(0).MinorClassification__c == 'OPS'))
                || (deviceList.get(0).MajorClassification__c == 'MELFLEX')
                    ) {
                    isMACTUS_MELFLEX=true;
                }

            //一般管理費を更新する
            if (deviceId!= null && selectedOption != null) {
                Device__c upObj = new Device__c(Id=deviceId,GeneralAdminExpensesExistence__c=selectedOption);
                update upObj;
            }

            //既存情報を削除
            List<Detail__c> deleteDetails = [SELECT Id FROM Detail__c WHERE Device__c =:deviceId ];
            delete deleteDetails;

            List<Detail__c> detailList = new List<Detail__c>();
            //入力情報件数ごとに処理
            for(PricingTableInputOnly obj : priceList){
                String pId = obj.Id;

                PricingTable__c pricingTable;
                //追加行の場合
                if (!pId.contains('rowIndex')) {
                    pricingTable = pricingTableList.get(pId);
                }
                
                Decimal quantity = obj.Quantity;
                //数量入力された場合だけ　登録を行う
                if(quantity!=null && quantity != 0) {
                    //画面　数量入力された行
                    if (pricingTable != null){
                        Detail__c detail = new Detail__c();
                        detail.WcCoefficient__c = obj.WCCoefficient;//単位WC
                        if(String.isNotBlank(pricingTable.Note__c)){
                            detail.Note__c = pricingTable.Note__c;//備考
                            if(obj.WCCoefficient != null && obj.CreditWC != null){
                                detail.Note__c += ' WC×' + String.valueOf(obj.WCCoefficient);
                            }else if(obj.UnitPriceCoefficient != null && (pricingTable.Price__c != null || obj.unitPrice != null )){
                                detail.Note__c += ' 単価×' + String.valueOf(obj.UnitPriceCoefficient);
                            }
                        }else if(String.isBlank(pricingTable.Note__c)){
                            if(obj.WCCoefficient != null && obj.CreditWC != null){
                                detail.Note__c = 'WC×' + String.valueOf(obj.WCCoefficient);
                            }else if(obj.UnitPriceCoefficient != null && (pricingTable.Price__c != null || obj.unitPrice != null )){
                                detail.Note__c = '単価×' + String.valueOf(obj.UnitPriceCoefficient);
                            }
                        }
                        detail.CreditWC__c = obj.CreditWC;//WC係数
                        detail.UnitPrice__c  = pricingTable.Price__c;//単価
                        //単価入力可能の場合、画面入力値で更新
                        if (String.isNotBlank(pricingTable.Name2__c) && pricingTable.Name2__c.contains('EP=標準価格')){
                            detail.UnitPrice__c=obj.unitPrice;
                        }
                        detail.UnitPriceCoefficient__c = obj.UnitPriceCoefficient;//単価係数
                        detail.Name = (String.isNotBlank(pricingTable.DisplayName__c)?pricingTable.DisplayName__c.left(80):'');//価格表.表示用テキスト
                        detail.Name1__c = pricingTable.Name1__c;//名称１
                        detail.Name2__c = pricingTable.Name2__c;//名称２
                        detail.Name3__c = pricingTable.Name3__c;//名称３
                        detail.Name4__c = pricingTable.Name4__c;//名称４
                        detail.Name5__c = pricingTable.Name5__c;//名称５
                        detail.Name6__c = pricingTable.Name6__c;//名称６
                        detail.Name7__c = pricingTable.Name7__c;//名称７
                        detail.Name8__c = pricingTable.Name8__c;//名称８
                        detail.Name9__c = pricingTable.Name9__c;//名称９
                        detail.Name10__c = pricingTable.Name10__c;//名称１０
                        //筐体
                        if (pricingTable.RecordType.DeveloperName=='Chassis') {

                           if (deviceList.get(0).MajorClassification__c == '大型映像装置'
                                && (deviceList.get(0).MinorClassification__c == '屋内'
                                || deviceList.get(0).MinorClassification__c == '屋外')){
                                    detail.Name4__c=null;
                                    detail.Name5__c=null;
                                    //大分類名「大型映像装置」の筐体を保存する場合は、ヘッダ.ラベル4
                                    if (metaMap != null && String.isNotBlank(metaMap.meta4)) {
                                        detail.Name4__c = metaMap.meta4;//
                                    }
                                    //大分類名「大型映像装置」の筐体を保存する場合は、ヘッダ.ラベル5
                                    if (metaMap != null && String.isNotBlank(metaMap.meta5)) {
                                        detail.Name5__c = metaMap.meta5;//
                                    }
                                }
                            detail.DetailCategory__c='筐体';//"筐体" "明細"
                        }else{
                            detail.DetailCategory__c='明細';//"筐体" "明細"
                        }
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

                        detail.ProvisionUnitPrice__c = obj.ProvisionUnitPrice;//提供単価
                        detail.CreditWeight__c = pricingTable.Weight__c;//単位重量
                        detail.Quantity__c = quantity;//数量
                        detail.WcCalculationRate__c=pricingTable.WcCalculationRate__c;//WC算出レート
                        detail.Device__c = deviceId;//機器ID
                        // detail.PricingTable__c = pricingTable.Id;//価格表Id
                        detail.PricingTableUniqueKey__c = pricingTable.UniqueKey__c;//価格表ユニークキー

                        detailList.add(detail); 
                    //新規追加行の場合
                    }else if (pId.contains('rowIndex')){

                        PricingTableNewRowObj newRowObj = newRowsMap.get(pId);
                        if (newRowObj!=null) {
                            Detail__c detail = new Detail__c();
                            detail.Device__c = deviceId;//機器ID
                            //手入力した表示用テキストを価格表.名称1にも入れる（表示用テキストと名称1が同じになる）
                            detail.Name = newRowObj.Name1;//名称１
                            detail.Name1__c = newRowObj.Name1;//名称１
                            detail.CreditWC__c  = newRowObj.CreditWC;//単位WC
                            detail.WCCoefficient__c = newRowObj.WCCoefficient;//WC係数
                            detail.UnitPrice__c = newRowObj.UnitPrice;//単価
                            detail.UnitPriceCoefficient__c  = newRowObj.UnitPriceCoefficient;//単価係数
                            detail.ProvisionUnitPrice__c    = newRowObj.ProvisionUnitPrice;//提供単価
                            detail.CreditWeight__c = newRowObj.UnitWeight;//単位重量
                            detail.Quantity__c = newRowObj.Quantity;//数量
                            detail.Note__c = newRowObj.Note.substringBefore(' WC×').substringBefore(' 単価×');//備考
                            if(newRowObj.WCCoefficient != null && newRowObj.CreditWC != null){
                                detail.Note__c += ' WC×' + String.valueOf(newRowObj.WCCoefficient);
                            }else if(newRowObj.UnitPriceCoefficient != null && newRowObj.UnitPrice != null){
                                detail.Note__c += ' 単価×' + String.valueOf(newRowObj.UnitPriceCoefficient);
                            }
                            detail.DetailCategory__c='手入力';//"筐体" "明細"
                            detailList.add(detail); 
                        }
                    }
                }
            }

            System.debug(detailList);

            if (detailList.size()>0) {

                if (isMACTUS_MELFLEX) {
                    //「MACTUS」「MELFLEX」の場合は、
                    //ヘッダのプルダウン選択値、およびテキスト入力値で明細データを作成/更新する（明細.明細種別は"仕様"）
                    if (metaMap.isNotBlank()) {
                        Detail__c detail = new Detail__c();
                        detail.Name = metaMap.meta1;//名称１
                        detail.Name1__c = metaMap.meta1;//名称１
                        detail.Name2__c = metaMap.meta2;//名称２
                        detail.Name3__c = metaMap.meta3;//名称３
                        detail.Name4__c = metaMap.meta4;//名称４
                        detail.Name5__c = metaMap.meta5;//名称5
                        detail.Name6__c = metaMap.meta6;//名称6
                        detail.Name7__c = metaMap.meta7;//名称7
                        detail.Name8__c = metaMap.meta8;//名称8
                        detail.Name9__c = metaMap.meta9;//名称9
                        detail.Device__c = deviceId;//機器ID
                        
                       // ⑧大分類「MACTUS」の「仕様」明細を保存する時に、大分類コードに"09"、小分類コードに"01"or"02"、種類コードに"00"を入れて保存する
                        ///（小分類コードは見積項目.小分類名が「CTR」なら"01"、「OPS」なら"02"）
                        //⑨大分類「MELFLEX」の「仕様」明細を保存する時に、大分類コードに"48"、小分類コードに"00"、種類コードに"00"を入れて保存する
                        detail.CategoryCode__c='00';
                        if (deviceList.get(0).MajorClassification__c == 'MACTUS') {
                            detail.MajorClassificationCode__c='09';
                            if (deviceList.get(0).MinorClassification__c == 'CTR') {
                                detail.MinorClassificationCode__c='01';
                            }else if (deviceList.get(0).MinorClassification__c == 'OPS'){
                                detail.MinorClassificationCode__c='02';
                            }
                        }else if (deviceList.get(0).MajorClassification__c == 'MELFLEX') {
                            detail.MajorClassificationCode__c='48';
                            detail.MinorClassificationCode__c='00';
                        }
                        detail.DetailCategory__c='仕様';//"筐体" "明細"
                        detailList.add(detail);
                    } 
                }
                Insert detailList;
            }
            return deviceList.get(0).Quote__c;
        } catch(Exception ex) {
            System.debug('An Exception: '+ex);
            return 'error';
        }
    }

    /**
     * 大分類と小分類により　表示のラベルを設定
     * 
     * @param MajorClassification 大分類
     * @param MinorClassification 小分類
     * @param RecordTypeName 見積のレコードタイプ
     */
    private static List<Map<String, String>> setLabelList(String MajorClassification, String MinorClassification, String RecordTypeName){
        List<Map<String, String>> labelList = new List<Map<String, String>>();
        //小分類がないの場合
        if (MajorClassification=='MELFLEX'
            ||MajorClassification=='高圧受配電盤'
            ||MajorClassification=='中央監視'
            ||MajorClassification=='UPS(GS)'
            ) MinorClassification = '';

        Set<String> rtList = new Set<String>{'共通'};
        if (String.isNotBlank(RecordTypeName))rtList.add(RecordTypeName);
        //メタデータからプルダウンリストを検索
        List<LabelSetting__mdt> labelMaster = [SELECT 
                                    MajorClassification__c,
                                    MinorClassification__c,
                                    DetailName__c, 
                                    LabelName1__c,
                                    LabelName2__c, 
                                    LabelName3__c,
                                    LabelName4__c, 
                                    LabelName5__c,
                                    LabelName6__c, 
                                    LabelName7__c,
                                    LabelName8__c, 
                                    LabelName9__c,
                                    LabelName10__c
                                    FROM LabelSetting__mdt 
                    WHERE MajorClassification__c = :MajorClassification //機器大分類と一致
                    AND MinorClassification__c = :MinorClassification //機器小分類と一致
                    AND UseBU__c =:rtList
                    ];

        if (labelMaster!=null && labelMaster.size()>0) {
            if (String.isNotBlank(labelMaster.get(0).DetailName__c)) {
                //明細名称のラベルを設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).DetailName__c, 'value' => 'detail'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName1__c)) {
                //ラベル1を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName1__c, 'value' => 'name1'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName2__c)) {
                //ラベル2を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName2__c, 'value' => 'name2'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName3__c)) {
                //ラベル3を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName3__c, 'value' => 'name3'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName4__c)) {
                //ラベル4を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName4__c, 'value' => 'name4'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName5__c)) {
                //ラベル5を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName5__c, 'value' => 'name5'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName6__c)) {
                //ラベル6を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName6__c, 'value' => 'name6'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName7__c)) {
                //ラベル7を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName7__c, 'value' => 'name7'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName8__c)) {
                //ラベル8を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName8__c, 'value' => 'name8'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName9__c)) {
                //ラベル9を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName9__c, 'value' => 'name9'};
                labelList.add(namelabelMap);
            }
            if (String.isNotBlank(labelMaster.get(0).LabelName10__c)) {
                //ラベル10を設定
                Map<String, String> namelabelMap = new Map<String, String>{'label' => labelMaster.get(0).LabelName10__c, 'value' => 'name10'};
                labelList.add(namelabelMap);
            }
        }
        return labelList;
    }

    /**
     * ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸの設定
     * 
     * @param res 画面へ渡す情報
     * @param deveice 親画面の機器Id
     * @param bu BU条件
     * @param categoryCode 種類情報
     */
    private static Map<String, List<Map<String, String>>> setMactusAndMelflex(
                                Map<String, List<Map<String, String>>> res,
                                Device__c deveice,
                                List<String> bu,
                                List<String> categoryCode){
        List<Detail__c> details = new List<Detail__c>([
                                    SELECT Id, 
                                           Name,Name1__c,Name2__c,Name3__c,Name4__c,Name5__c,
                                           Name6__c,Name7__c,Name8__c,Name9__c                                    
                                     FROM Detail__c 
                                    WHERE Device__c =:deveice.Id
                                        AND PricingTableUniqueKey__c = null
                                        AND DetailCategory__c = '仕様'
                                    LIMIT 1]); //一件だけはず。

            //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸ
            //初期表示内容
            List<Map<String, String>> metadatas = new List<Map<String, String>>();
            Map<String, String> metadatasMap = new Map<String, String>();
            metadatasMap.put('meta1', (details!=null&&details.size()>0)?details.get(0).Name1__c:null);//meta1表示内容の設定
            metadatasMap.put('meta2', (details!=null&&details.size()>0)?details.get(0).Name2__c:null);//meta2表示内容の設定
            metadatasMap.put('meta3', (details!=null&&details.size()>0)?details.get(0).Name3__c:null);//meta3表示内容の設定
            metadatasMap.put('meta4', (details!=null&&details.size()>0)?details.get(0).Name4__c:null);//meta3表示内容の設定
            metadatasMap.put('meta5', (details!=null&&details.size()>0)?details.get(0).Name5__c:null);//meta3表示内容の設定
            metadatasMap.put('meta6', (details!=null&&details.size()>0)?details.get(0).Name6__c:null);//meta3表示内容の設定
            metadatasMap.put('meta7', (details!=null&&details.size()>0)?details.get(0).Name7__c:null);//meta3表示内容の設定
            metadatasMap.put('meta8', (details!=null&&details.size()>0)?details.get(0).Name8__c:null);//meta3表示内容の設定
            metadatasMap.put('meta9', (details!=null&&details.size()>0)?details.get(0).Name9__c:null);//meta3表示内容の設定
            metadatas.add(metadatasMap);
            res.put('metadatas', metadatas);
            
            List<Map<String, String>> name1List = new List<Map<String, String>>();
            List<Map<String, String>> name2List = new List<Map<String, String>>();
            List<Map<String, String>> name6List = new List<Map<String, String>>();

            //メタデータからプルダウンリストを検索
            List<PullDownList__mdt> optionList = [SELECT 
                                            MajorClassification__c,
                                            MinorClassification__c,
                                            DisplayOrder__c,
                                            ListValue__c, 
                                            DisplayLocation__c 
                                            FROM PullDownList__mdt 
                                            WHERE MajorClassification__c = :deveice.MajorClassification__c //機器大分類と一致
                                            AND MinorClassification__c = :deveice.MinorClassification__c //機器小分類と一致
                                            Order by MajorClassification__c,MinorClassification__c,DisplayLocation__c,DisplayOrder__c];

            //戻る値に設定
            for(PullDownList__mdt option: optionList) {
                Map<String, String> nameMap = new Map<String, String>();
                nameMap.put('label', (String)option.ListValue__c);//表示内容の設定
                nameMap.put('value', (String)option.ListValue__c);//Valueの設定
                if (option.DisplayLocation__c == 1) { //位置１に表示
                    if (details!=null&&details.size()>0 && details.get(0).Name1__c == option.ListValue__c){
                        nameMap.put('selected', 'true');
                    }
                    name1List.add(nameMap);
                }else if (option.DisplayLocation__c == 2) {//位置２に表示
                    if (details!=null&&details.size()>0 && details.get(0).Name2__c == option.ListValue__c){
                        nameMap.put('selected', 'true');
                    }
                    name2List.add(nameMap);
                }else if (option.DisplayLocation__c == 6) {//位置６に表示
                    if (details!=null&&details.size()>0 && details.get(0).Name6__c == option.ListValue__c){
                        nameMap.put('selected', 'true');
                    }
                    name6List.add(nameMap);
                }
            }
            if(name1List.size()>0) res.put('metadata1', name1List);//位置１のプルダウンリスト
            if(name2List.size()>0) res.put('metadata2', name2List);//位置2のプルダウンリスト
            if(name6List.size()>0) res.put('metadata6', name6List);//位置６のプルダウンリスト
            return res;
    }

    @AuraEnabled
    /**
     * 条件仕様１～６のリスト内容を取得
     * 
     * @param deviceId 機器Id
     * @param name1 仕様１の選択値
     */
    public static Map<String, List<Map<String, String>>> getUniqueNamePicklist(
                                                        Id deviceId,
                                                        String name1) {

        Map<String, List<Map<String, String>>> res = new Map<String, List<Map<String, String>>>();

        //機器を取得
        Device__c deveice = [SELECT Id, 
                                    toLabel(MajorClassification__c), //機器大分類
                                    MinorClassification__c, //機器小分類
                                    Quote__r.PowerFrequency__c, //機器周波数
                                    Quote__r.RecordType.DeveloperName, //レコードタイプ
                                    Quote__r.RecordType.Name //レコードタイプ　表示ラベル
                                FROM Device__c WHERE Id =:deviceId LIMIT 1];

        List<String> categoryCode = new List<String>();
        String powerFrequency = deveice.Quote__r.PowerFrequency__c;//機器周波数
        String quoteRecordType = deveice.Quote__r.RecordType.DeveloperName;//レコードタイプ
        //周波数検索条件
        if (String.isNotBlank(powerFrequency)) {
            categoryCode.add('00');
            if(powerFrequency=='50Hz'){
                categoryCode.add('01');
            }else if(powerFrequency=='60Hz'){
                categoryCode.add('02');
            }
        }else{
            categoryCode.add('00');
            categoryCode.add('01');
            categoryCode.add('02');
        }

        //価格表.BUが見積.レコードタイプに応じた値（施設=S、水環境/官需=M）」
        // 水環境と官需の場合はいずれも「Ｍ」と「Ｋ」両方を検索対象
        List<String> bu = new List<String>();
        if (quoteRecordType=='Facility'){
            bu.add('S');
        }else {
            bu.add('M');
            bu.add('K');
        }

        //表示ラベルの設定
        //大分類と小分類により　表示のラベルを決める
        List<Map<String, String>> labelList = setLabelList(deveice.MajorClassification__c,deveice.MinorClassification__c, deveice.Quote__r.RecordType.Name);
        res.put('label', labelList);
        if (labelList.size() == 0) return res;//画面条件なし

        //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸの場合
        if (deveice.MajorClassification__c == 'MACTUS'
            || deveice.MajorClassification__c == 'MELFLEX'
            ) {
            Boolean isTarget = false;

            List<Map<String, String>> temp = new List<Map<String, String>>();
            temp.add(new Map<String, String>());
            //ＣＴＲ
            if(deveice.MajorClassification__c == 'MACTUS'
                 && deveice.MinorClassification__c == 'CTR'){
                res.put('isMACTUS',  temp);
                isTarget = true;
            //ＯＰＳ
            }else  if(deveice.MajorClassification__c == 'MACTUS'
                 && deveice.MinorClassification__c == 'OPS'){
                res.put('isMACTUS',  temp);
                res.put('isOPS',  temp);
                isTarget = true;
            //ＭＥＬＦＬＥＸ
            }else  if(deveice.MajorClassification__c == 'MELFLEX'
                    ){
                res.put('isMELFLEX',  temp);
                isTarget = true;
            //大型映像装置
            }
            if (isTarget) {
                //表示のラベルとプルダウンリストを設定
                res = setMactusAndMelflex(res,deveice,bu,categoryCode);
                return res;
            } 

        }

        //画面表示する条件を判定
        Boolean isExist1=false;
        Boolean isExist2=false;
        Boolean isExist3=false;
        Boolean isExist4=false;
        Boolean isExist5=false;
        Boolean isExist6=false;
        Boolean isExist7=false;
        Boolean isExist8=false;
        Boolean isExist9=false;
        Boolean isExist10=false;
        for(Map<String,String> temp : labelList) {
            if (temp.get('value') == 'name1') isExist1 = true;
            if (temp.get('value') == 'name2') isExist2 = true;
            if (temp.get('value')  == 'name3') isExist3 = true;
            if (temp.get('value') == 'name4') isExist4 = true;
            if (temp.get('value') == 'name5') isExist5 = true;
            if (temp.get('value')  == 'name6') isExist6 = true;
            if (temp.get('value')  == 'name7') isExist7 = true;
            if (temp.get('value')  == 'name8') isExist8 = true;
            if (temp.get('value')  == 'name9') isExist9 = true;
            if (temp.get('value')  == 'name10') isExist10 = true;
        }
        //画面条件なし
        if (!(isExist1||isExist2||isExist3||isExist4||isExist5||isExist6||isExist7||isExist8||isExist9||isExist10)) return res;
        
        //大型映像装置の場合、横、縦の制御を行う
        if(deveice.MajorClassification__c == '大型映像装置'
                && (deveice.MinorClassification__c == '屋内'
                || deveice.MinorClassification__c == '屋外')){
            List<Map<String, String>> temp = new List<Map<String, String>>();
            temp.add(new Map<String, String>());
            res.put('isLargeScreen',  temp);
        }

        //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸの以外　価格表から検索
        //仕様１の設定
        List<Map<String, String>> name1List = setName1(deveice,bu,categoryCode);
        res.put('name1', name1List);
        system.debug('deveice.MajorClassification__c==' + deveice.MajorClassification__c);
        //初期の場合、仕様１だけ　設定する
        if (String.isBlank(name1)
            && deveice.MajorClassification__c != '特高'){

            //変圧器の場合、盤条件のリストを取得する
            if (deveice.MajorClassification__c == '変圧器'
              && (deveice.MinorClassification__c == '高圧変圧器' || deveice.MinorClassification__c == '機器事業部 変圧器')) {
                //「筐体」条件のリストを取得
                //筐体：価格表.レコードタイプ="筐体"かつ、価格表.BU＝見積.レコードタイプかつ、
                //価格表.大分類="変圧器"かつ、価格表.種類名称＝"変圧器収納盤（高圧）"の、価格表.名称5を重複無いように表示
                res=setBoard(res,deveice,bu);
            }
            //連動項目
            res.put('name2', new List<Map<String, String>>());
            res.put('name3', new List<Map<String, String>>());
            res.put('name4', new List<Map<String, String>>());
            res.put('name5', new List<Map<String, String>>());
            res.put('name6', new List<Map<String, String>>());
            return res;
        }
        system.debug(isExist2);
        //仕様２
        if (isExist2) {
            List<Map<String, String>> name2List = setName2(deveice,bu,categoryCode,name1);
            system.debug(name2List);
            res.put('name2', name2List);
        }

        //検索条件：仕様３のリスト内容を取得
        if (isExist3) {
            List<Map<String, String>> name3List = setName3(deveice,bu,categoryCode,name1);
            res.put('name3', name3List);
        }

        //検索条件：仕様４のリスト内容を取得
        if (isExist4) {
            List<Map<String, String>> name4List = setName4(deveice,bu,categoryCode,name1);
            res.put('name4', name4List);
        }

        //検索条件：仕様５のリスト内容を取得
        if (isExist5) {
            List<Map<String, String>> name5List = setName5(deveice,bu,categoryCode,name1);
            res.put('name5', name5List);
        }
        //検索条件：仕様６のリスト内容を取得
        if (isExist6) {
            List<Map<String, String>> name6List = setName6(deveice,bu,categoryCode,name1);
            res.put('name6', name6List);
        }
        //検索条件：仕様7のリスト内容を取得
        if (isExist7) {
            List<Map<String, String>> name7List = setName7(deveice,bu,categoryCode,name1);
            res.put('name7', name7List);
        }
        //検索条件：仕様8のリスト内容を取得
        if (isExist8) {
            List<Map<String, String>> name8List = setName8(deveice,bu,categoryCode,name1);
            res.put('name8', name8List);
        }
        //検索条件：仕様9のリスト内容を取得
        if (isExist9) {
            List<Map<String, String>> name9List = setName9(deveice,bu,categoryCode,name1);
            res.put('name9', name9List);
        }
        //検索条件：仕様9のリスト内容を取得
        if (isExist10) {
            List<Map<String, String>> name10List = setName10(deveice,bu,categoryCode,name1);
            res.put('name10', name10List);
        }
        return res;
    }

    /**
     * 盤条件を設定
     * 
     * @param res 画面へ渡す情報
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     */
    private static Map<String, List<Map<String, String>>> setBoard(
                            Map<String, List<Map<String, String>>> res,
                            Device__c deveice,
                            List<String> bu
                            ){
        //設置場所
        //（見積項目.大分類名が「変圧器」かつ見積項目.小分類名が「高低圧変圧器」or「機器事業部 変圧器」の時のみ表示）
        List<AggregateResult> board1Map = [SELECT Name2__c, COUNT(ID) 
                                            FROM PricingTable__c 
                                            WHERE MajorClassificationName__c = :deveice.MajorClassification__c //機器大分類と一致
                                                AND MinorClassificationName__c = '変圧器収納盤'
                                                AND BU__c =:bu   //BUコード
                                                AND Name1__c ='変圧器収納盤(高圧)' //変圧器収納盤（高圧）の筐体
                                                AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                                AND Name2__c != null //空白以外
                                            GROUP BY Name2__c
                                            Order by Max(Specification2DisplayOrder__c)];

        List<Map<String, String>> board1List = new List<Map<String, String>>();
        //戻る値に設定
        for(AggregateResult name: board1Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name2__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name2__c'));//Valueの設定
            board1List.add(nameMap);
        }
        res.put('board1', board1List);

        //標準盤外形寸法
        //（見積項目.大分類名が「変圧器」かつ見積項目.小分類名が「高低圧変圧器」or「機器事業部 変圧器」の時のみ表示）
        // 20230301  2つ目のプルダウンに表示する内容と検索条件を現在の名称4の値から名称3の値に変更
        List<AggregateResult> board2Map = [SELECT Name3__c, COUNT(ID) 
                                                FROM PricingTable__c 
                                                WHERE MajorClassificationName__c = :deveice.MajorClassification__c //機器大分類と一致
                                                    AND MinorClassificationName__c = '変圧器収納盤'
                                                    AND BU__c =:bu   //BUコード
                                                    AND Name1__c ='変圧器収納盤(高圧)' //変圧器収納盤（高圧）の筐体
                                                    AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                                    AND Name3__c != null //空白以外
                                                GROUP BY Name3__c
                                                Order by Max(Specification3DisplayOrder__c)];

        List<Map<String, String>> board2List = new List<Map<String, String>>();
        //戻る値に設定
        for(AggregateResult name: board2Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name3__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name3__c'));//Valueの設定
            board2List.add(nameMap);
        }
        res.put('board2', board2List);
        return res;
    }

    /**
     * 仕様１の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     */
    private static List<Map<String,String>> setName1(Device__c deveice,
                                    List<String> bu,
                                    List<String> categoryCode){
        List<AggregateResult> name1Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);

        //仕様１リストの取得
        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            name1Map = [SELECT Name1__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND BU__c =:bu   //BUコード
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            AND Name1__c != null //空白以外
                        GROUP BY Name1__c
                        Order by Max(Specification1DisplayOrder__c)];
        //小分類が指定している
        }else { 
            name1Map = [SELECT Name1__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND MinorClassificationName__c = :minor//機器小分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            AND Name1__c != null //空白以外
                        GROUP BY Name1__c
                        Order by Max(Specification1DisplayOrder__c)];
        }
        List<Map<String, String>> name1List = new List<Map<String, String>>();
        //戻る値に設定
        for(AggregateResult name: name1Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name1__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name1__c'));//Valueの設定
            name1List.add(nameMap);
        }
        return name1List;
    }

    /**
     * 仕様２の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     * @param name1 仕様１選択値
     */
    private static List<Map<String,String>> setName2(Device__c deveice,
                                            List<String> bu,
                                            List<String> categoryCode,
                                            String name1){
        //検索条件：仕様２のリスト内容を取得
        List<AggregateResult> name2Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);
        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            if (deveice.MajorClassification__c != '特高') {
                name2Map = [SELECT Name2__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major //機器大分類と一致
                                AND CategoryCode__c =:categoryCode  //機器周波数と一致
                                AND BU__c =:bu   //BUコード
                                AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                AND Name1__c = :name1 //仕様１と連動
                                AND Name2__c != null //空白以外
                            GROUP BY Name2__c
                            Order by Max(Specification2DisplayOrder__c)];
                            // AND MinorClassificationName__c = :deveice.MinorClassification__c
            }else {
                name2Map = [SELECT Name2__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major //機器大分類と一致
                                AND CategoryCode__c =:categoryCode  //機器周波数と一致
                                AND BU__c =:bu   //BUコード
                                AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                // AND Name1__c = :name1 //仕様１と連動
                                AND Name2__c != null //空白以外
                            GROUP BY Name2__c
                            Order by Max(Specification2DisplayOrder__c)];
                            // AND MinorClassificationName__c = :deveice.MinorClassification__c
            }
        //小分類が指定している
        } else {
            if (deveice.MajorClassification__c != '特高') {
                name2Map = [SELECT Name2__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND MinorClassificationName__c = :minor  //機器小分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name2__c != null //空白以外
                        GROUP BY Name2__c
                        Order by Max(Specification2DisplayOrder__c)];
            }else {
                name2Map = [SELECT Name2__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND MinorClassificationName__c = :minor  //機器小分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            // AND Name1__c = :name1 //仕様１と連動
                            AND Name2__c != null //空白以外
                        GROUP BY Name2__c
                        Order by Max(Specification2DisplayOrder__c)];
            }

        }
        List<Map<String, String>> name2List = new List<Map<String, String>>();

        //戻る値を設定
        for(AggregateResult name: name2Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name2__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name2__c'));//Valueの設定
            name2List.add(nameMap);
        }
        return name2List;
    }

    /**
     * 仕様３の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     * @param name1 仕様１選択値
     */
    private static List<Map<String,String>> setName3(Device__c deveice,
                                            List<String> bu,
                                            List<String> categoryCode,
                                            String name1){
        List<AggregateResult> name3Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);

        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            if (deveice.MajorClassification__c != '特高') {
                name3Map = [SELECT Name3__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major  //機器大分類と一致
                                AND BU__c =:bu   //BUコード
                                AND CategoryCode__c =:categoryCode //機器周波数と一致
                                AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                AND Name1__c = :name1 //仕様１と連動
                                AND Name3__c != null //空白以外
                            GROUP BY Name3__c
                            Order by Max(Specification3DisplayOrder__c)];//AND MinorClassificationName__c = :deveice.MinorClassification__c
            } else {
                name3Map = [SELECT Name3__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major  //機器大分類と一致
                                AND BU__c =:bu   //BUコード
                                AND CategoryCode__c =:categoryCode //機器周波数と一致
                                AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                // AND Name1__c = :name1 //仕様１と連動
                                AND Name3__c != null //空白以外
                            GROUP BY Name3__c
                            Order by Max(Specification3DisplayOrder__c)];//AND MinorClassificationName__c = :deveice.MinorClassification__c
            }
        //小分類が指定している
        }else{
            
            if (deveice.MajorClassification__c != '特高') {
                name3Map = [SELECT Name3__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major //機器大分類と一致
                                AND MinorClassificationName__c = :minor  //機器小分類と一致
                                AND BU__c =:bu   //BUコード
                                AND CategoryCode__c =:categoryCode //機器周波数と一致
                                AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                AND Name1__c = :name1 //仕様１と連動
                                AND Name3__c != null //空白以外
                            GROUP BY Name3__c
                            Order by Max(Specification3DisplayOrder__c)];
            }else{
                name3Map = [SELECT Name3__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND MinorClassificationName__c = :minor  //機器小分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            // AND Name1__c = :name1 //仕様１と連動
                            AND Name3__c != null //空白以外
                        GROUP BY Name3__c
                        Order by Max(Specification3DisplayOrder__c)];
            }
        }
        List<Map<String, String>> name3List = new List<Map<String, String>>();
        //戻る値を設定
        for(AggregateResult name: name3Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name3__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name3__c'));//Valueの設定
            name3List.add(nameMap);
        }
        return name3List;
    }

    /**
     * 仕様４の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     * @param name1 仕様１選択値
     */
    private static List<Map<String,String>> setName4(Device__c deveice,
                                            List<String> bu,
                                            List<String> categoryCode,
                                            String name1){
        List<AggregateResult> name4Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);
        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            if (deveice.MajorClassification__c != '特高') {
                name4Map = [SELECT Name4__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major  //機器大分類と一致
                                AND BU__c =:bu   //BUコード
                                AND CategoryCode__c =:categoryCode //機器周波数と一致
                                AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                AND Name1__c = :name1 //仕様１と連動
                                AND Name4__c != null //空白以外
                            GROUP BY Name4__c
                            Order by Max(Specification4DisplayOrder__c)];// AND MinorClassificationName__c = :deveice.MinorClassification__c
            }else {
                name4Map = [SELECT Name4__c, COUNT(ID) 
                FROM PricingTable__c 
                WHERE MajorClassificationName__c = :major  //機器大分類と一致
                    AND BU__c =:bu   //BUコード
                    AND CategoryCode__c =:categoryCode //機器周波数と一致
                    AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                    // AND Name1__c = :name1 //仕様１と連動
                    AND Name4__c != null //空白以外
                GROUP BY Name4__c
                Order by Max(Specification4DisplayOrder__c)];// AND MinorClassificationName__c = :deveice.MinorClassification__c

            }
        //小分類が指定している
        }else{
            if (deveice.MajorClassification__c != '特高') {
                name4Map = [SELECT Name4__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major //機器大分類と一致
                                AND MinorClassificationName__c = :minor  //機器小分類と一致
                                AND BU__c =:bu   //BUコード
                                AND CategoryCode__c =:categoryCode //機器周波数と一致
                                AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                AND Name1__c = :name1 //仕様１と連動
                                AND Name4__c != null //空白以外
                            GROUP BY Name4__c
                            Order by Max(Specification4DisplayOrder__c)];
            } else {
                name4Map = [SELECT Name4__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major //機器大分類と一致
                                AND MinorClassificationName__c = :minor  //機器小分類と一致
                                AND BU__c =:bu   //BUコード
                                AND CategoryCode__c =:categoryCode //機器周波数と一致
                                AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                                // AND Name1__c = :name1 //仕様１と連動
                                AND Name4__c != null //空白以外
                            GROUP BY Name4__c
                            Order by Max(Specification4DisplayOrder__c)];
            }
        }
        List<Map<String, String>> name4List = new List<Map<String, String>>();
        //戻る値を設定
        for(AggregateResult name: name4Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name4__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name4__c'));//Valueの設定
            name4List.add(nameMap);
        }
        return name4List;
    }

    /**
     * 仕様５の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     * @param name1 仕様１選択値
     */
    private static List<Map<String, String>> setName5(Device__c deveice,
                                                List<String> bu,
                                                List<String> categoryCode,
                                                String name1){
        List<AggregateResult> name5Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);
        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            if (deveice.MajorClassification__c != '特高') {
                name5Map = [SELECT Name5__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major  //機器大分類と一致
                                AND BU__c =:bu   //BUコード
                                AND CategoryCode__c =:categoryCode //機器周波数と一致
                                AND RecordType.DeveloperName = 'Chassis'  //筐体のみ
                                AND Name1__c = :name1 //仕様１と連動
                                AND Name5__c != null //空白以外
                            GROUP BY Name5__c
                            Order by Max(Specification5DisplayOrder__c)];//AND MinorClassificationName__c = :deveice.MinorClassification__c
            }else {
                name5Map = [SELECT Name5__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major  //機器大分類と一致
                                AND BU__c =:bu   //BUコード
                                AND CategoryCode__c =:categoryCode //機器周波数と一致
                                AND RecordType.DeveloperName = 'Chassis'  //筐体のみ
                                // AND Name1__c = :name1 //仕様１と連動
                                AND Name5__c != null //空白以外
                            GROUP BY Name5__c
                            Order by Max(Specification5DisplayOrder__c)];//AND MinorClassificationName__c = :deveice.MinorClassification__c
            }
        //小分類が指定している
        }else{
            if (deveice.MajorClassification__c != '特高') {
                name5Map = [SELECT Name5__c, COUNT(ID) 
                            FROM PricingTable__c 
                            WHERE MajorClassificationName__c = :major //機器大分類と一致
                                AND MinorClassificationName__c = :minor  //機器小分類と一致
                                AND BU__c =:bu   //BUコード
                                AND CategoryCode__c =:categoryCode //機器周波数と一致
                                AND RecordType.DeveloperName = 'Chassis'  //筐体のみ
                                AND Name1__c = :name1 //仕様１と連動
                                AND Name5__c != null //空白以外
                            GROUP BY Name5__c
                            Order by Max(Specification5DisplayOrder__c)];
            }else {
                name5Map = [SELECT Name5__c, COUNT(ID) 
                                FROM PricingTable__c 
                                WHERE MajorClassificationName__c = :major //機器大分類と一致
                                    AND MinorClassificationName__c = :minor  //機器小分類と一致
                                    AND BU__c =:bu   //BUコード
                                    AND CategoryCode__c =:categoryCode //機器周波数と一致
                                    AND RecordType.DeveloperName = 'Chassis'  //筐体のみ
                                    // AND Name1__c = :name1 //仕様１と連動
                                    AND Name5__c != null //空白以外
                                GROUP BY Name5__c
                                Order by Max(Specification5DisplayOrder__c)];
            }
        }
        List<Map<String, String>> name5List = new List<Map<String, String>>();
        //戻る値を設定
        for(AggregateResult name: name5Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name5__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name5__c'));//Valueの設定
            name5List.add(nameMap);
        }
        return name5List;
    }

    /**
     * 仕様６の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     * @param name1 仕様１選択値
     */
    private static List<Map<String, String>> setName6(Device__c deveice,
                                                List<String> bu,
                                                List<String> categoryCode,
                                               String name1){
        List<AggregateResult> name6Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);
        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            name6Map = [SELECT Name6__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode  //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis'  //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name6__c != null //空白以外
                        GROUP BY Name6__c
                        Order by Max(Specification6DisplayOrder__c)];//Order by Max(Specification6DisplayOrder__c)
        //小分類が指定している
        }else{ 
            name6Map = [SELECT Name6__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND MinorClassificationName__c = :minor  //機器小分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name6__c != null //空白以外
                        GROUP BY Name6__c
                        Order by Max(Specification6DisplayOrder__c)];//Order by Max(Specification6DisplayOrder__c)
        }
        List<Map<String, String>> name6List = new List<Map<String, String>>();
        //戻る値を設定
        for(AggregateResult name: name6Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name6__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name6__c'));//Valueの設定
            name6List.add(nameMap);
        }
        return name6List;
    }
    /**
     * 仕様7の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     * @param name1 仕様１選択値
     */
    private static List<Map<String, String>> setName7(Device__c deveice,
                                                List<String> bu,
                                                List<String> categoryCode,
                                               String name1){
        List<AggregateResult> name7Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);
        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            name7Map = [SELECT Name7__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode  //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis'  //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name7__c != null //空白以外
                        GROUP BY Name7__c
                        Order by Max(Specification7DisplayOrder__c)];//Order by Max(Specification6DisplayOrder__c)
        //小分類が指定している
        }else{ 
            name7Map = [SELECT Name7__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND MinorClassificationName__c = :minor  //機器小分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name7__c != null //空白以外
                        GROUP BY Name7__c
                        Order by Max(Specification7DisplayOrder__c)];//Order by Max(Specification6DisplayOrder__c)
        }
        List<Map<String, String>> name7List = new List<Map<String, String>>();
        //戻る値を設定
        for(AggregateResult name: name7Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name7__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name7__c'));//Valueの設定
            name7List.add(nameMap);
        }
        return name7List;
    }
    /**
     * 仕様8の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     * @param name1 仕様１選択値
     */
    private static List<Map<String, String>> setName8(Device__c deveice,
                                                List<String> bu,
                                                List<String> categoryCode,
                                               String name1){
        List<AggregateResult> name8Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);
        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            name8Map = [SELECT Name8__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode  //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis'  //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name8__c != null //空白以外
                        GROUP BY Name8__c
                        Order by Max(Specification8DisplayOrder__c)];//Order by Max(Specification8DisplayOrder__c)
        //小分類が指定している
        }else{ 
            name8Map = [SELECT Name8__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND MinorClassificationName__c = :minor  //機器小分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name8__c != null //空白以外
                        GROUP BY Name8__c
                        Order by Max(Specification8DisplayOrder__c)];//Order by Max(Specification8DisplayOrder__c)
        }
        List<Map<String, String>> name8List = new List<Map<String, String>>();
        //戻る値を設定
        for(AggregateResult name: name8Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name8__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name8__c'));//Valueの設定
            name8List.add(nameMap);
        }
        return name8List;
    }
    /**
     * 仕様9の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     * @param name1 仕様１選択値
     */
    private static List<Map<String, String>> setName9(Device__c deveice,
                                                List<String> bu,
                                                List<String> categoryCode,
                                               String name1){
        List<AggregateResult> name9Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);
        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            name9Map = [SELECT Name9__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode  //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis'  //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name9__c != null //空白以外
                        GROUP BY Name9__c
                        Order by Max(Specification9DisplayOrder__c)];//Order by Max(Specification8DisplayOrder__c)
        //小分類が指定している
        }else{ 
            name9Map = [SELECT Name9__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND MinorClassificationName__c = :minor //機器小分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name9__c != null //空白以外
                        GROUP BY Name9__c
                        Order by Max(Specification9DisplayOrder__c)];//Order by Max(Specification9DisplayOrder__c)
        }
        List<Map<String, String>> name9List = new List<Map<String, String>>();
        //戻る値を設定
        for(AggregateResult name: name9Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name9__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name9__c'));//Valueの設定
            name9List.add(nameMap);
        }
        return name9List;
    }

    /**
     * 仕様10の設定
     * 
     * @param deveice 親画面の機器情報
     * @param bu BUリスト
     * @param categoryCode 種類コード
     * @param name1 仕様１選択値
     */
    private static List<Map<String, String>> setName10(Device__c deveice,
                                                List<String> bu,
                                                List<String> categoryCode,
                                               String name1){
        List<AggregateResult> name10Map;
        List<String> major = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,true);
        List<String> minor = getClassification(deveice.MajorClassification__c,deveice.MinorClassification__c,false);
        //小分類が指定していない
        if(String.isBlank(deveice.MinorClassification__c)) {
            name10Map = [SELECT Name10__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode  //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis'  //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name10__c != null //空白以外
                        GROUP BY Name10__c
                        Order by Max(Specification10DisplayOrder__c)];//Order by Max(Specification10DisplayOrder__c)
        //小分類が指定している
        }else{ 
            name10Map = [SELECT Name10__c, COUNT(ID) 
                        FROM PricingTable__c 
                        WHERE MajorClassificationName__c = :major //機器大分類と一致
                            AND MinorClassificationName__c = :minor //機器小分類と一致
                            AND BU__c =:bu   //BUコード
                            AND CategoryCode__c =:categoryCode //機器周波数と一致
                            AND RecordType.DeveloperName = 'Chassis' //筐体のみ
                            AND Name1__c = :name1 //仕様１と連動
                            AND Name10__c != null //空白以外
                        GROUP BY Name10__c
                        Order by Max(Specification10DisplayOrder__c)];//Order by Max(Specification10DisplayOrder__c)
        }
        List<Map<String, String>> name10List = new List<Map<String, String>>();
        //戻る値を設定
        for(AggregateResult name: name10Map) {
            Map<String, String> nameMap = new Map<String, String>();
            nameMap.put('label', (String)name.get('Name10__c'));//表示内容の設定
            nameMap.put('value', (String)name.get('Name10__c'));//Valueの設定
            name10List.add(nameMap);
        }
        return name10List;
    }

    /**
     * 検索条件を個別対応
     * 
     * @param majorClassification 大分類
     * @param minorClassification 小分類
     * @param isMajor 大分類の取得であるかどうか
     */
    private static List<String> getClassification(String majorClassification,String minorClassification,Boolean isMajor){
        List<String> rtnLst = new List<String>();
        //大分類リスト取得する場合
        if (isMajor) {
            if(String.isNotBlank(majorClassification))rtnLst.add(majorClassification);
            if (majorClassification=='計装機器' && minorClassification=='計装盤'){
                rtnLst.add('低圧・現場・リレー・ACB盤');
            }
        //小分類リスト取得する場合
        }else {
            if(String.isNotBlank(minorClassification))rtnLst.add(minorClassification);
            if (majorClassification=='低圧・現場・リレー・ACB盤' && minorClassification=='リレー盤'){
                rtnLst.add('低圧盤');
            } else if (majorClassification=='計装機器' && minorClassification=='計装盤'){
                rtnLst.add('低圧盤');
            }
        }
        return rtnLst;
    }
}