public with sharing class DetailsInputForExtraHighController {
    public static final String BU_TYPE_S = 'S';
    public static final String BU_TYPE_M = 'M';
    public static final String DEFAULT_VOLTAGE_OIL_TYPE = '6,600V';
    public static final String DEFAULT_VOLTAGE_MOLD_TYPE = '3,300V or 6,600V';
    public static final String DEFAULT_CATEGORY_CODE = '02';
    public static final String DETAIL_CATEGORY_CODE = '00';
    public static final String FACILITY_RECORD_TYPE = 'Facility';
    public static final String PRICING_TABLE_RECORD_TYPE = 'Chassis';
    public static final String DETAIL_RECORD_TYPE = 'Detail';
    public static final String DEFAULT_MAJOR_CLASSIFICATION = '変圧器';
    public static final String DEFAULT_MINOR_CLASSIFICATION = '特高変圧器';
    public static final String DISPLAY_TABLE_LABEL = '{0} {1} GIS直結{2} 電圧仕様{3} OLTC{4} スポットネットワーク{5}';
    public static final InitSearchCondition INIT_SEARCH_CONDITION = new InitSearchCondition();
    public static final String ANNOTATION_GAS = System.Label.Annotation_ExtraHighVoltageTR_Gas;
    public static final String ANNOTATION_OIL = System.Label.Annotation_ExtraHighVoltageTR_Oilin;
    public static final String ANNOTATION_MOLD = System.Label.Annotation_ExtraHighVoltageTR_Mold;

    public class ScreenInfo {
        public String errorMsg { get; set; }
        public Boolean isNoData { get; set; }

        String inputedId {get;set;}
        String displayCondition { get; set; }
        Decimal displayTotal {get;set;}

        public String displayLabel { get; set; }
        public List<BodyRow> headerList { get; set; }
        public List<BodyRow> bodyList { get; set; }
        public String footer { get; set; }

        public String screenType { get; set; }
        public string searchCondition1 { get; set; }
        public string searchCondition2 { get; set; }
        public string searchCondition3 { get; set; }
        public string searchCondition4 { get; set; }
        public string searchCondition5 { get; set; }
        public String searchConMap { get; set; }
    }

    public class BodyRow {
        public BodyRow() {
            this.cellList = new List<BodyCell>();
        }

        public List<BodyCell> cellList {get;set;}
    }

    public class BodyCell {
        public Object value {get;set;}
        public Integer colSpanCnt {get;set;}
        public Boolean isColSpan {get;set;}
        public Integer rowSpanCnt {get;set;}
        public Boolean isRowSpan {get;set;}
        public Boolean isEdit {get;set;}
    }

    @AuraEnabled
    public static String getDetailsInputForExtraHighInfo(Boolean isInit,
                                                        String deviceId,
                                                        String screenType,
                                                        String searchCondition1,
                                                        String searchCondition2,
                                                        String searchCondition3,
                                                        String searchCondition4,
                                                        String searchCondition5) {

        //Set default data
        searchCondition1 = String.isEmpty(searchCondition1) ? '1' : searchCondition1;
        searchCondition2 = String.isEmpty(searchCondition2) ? '0' : searchCondition2;
        searchCondition3 = String.isEmpty(searchCondition3) ? '0' : searchCondition3;
        searchCondition4 = String.isEmpty(searchCondition4) ? '0' : searchCondition4;
        searchCondition5 = String.isEmpty(searchCondition5) ? '0' : searchCondition5;                                      


        ScreenInfo info = new ScreenInfo();
        Device__c device;
        Detail__c detail = null;
        Detail__c optionDetailGIS = null;
        Detail__c optionDetailOLTC = null;

        String bu;
        String category = DEFAULT_CATEGORY_CODE;
        String powerFrequency;//機器周波数

        String currentPricingKey;
        Set<String> searchConditionSet = new Set<String>();

        List<String> screenTypeList = INIT_SEARCH_CONDITION.screenTypeMap.get(screenType); // 特高種類
        List<String> voltageTypeList = INIT_SEARCH_CONDITION.voltageTypeMap.get(searchCondition2);                               
        
        String screenTypeLabel = String.isEmpty(searchCondition4) || searchCondition4 == '0' ? screenTypeList.get(1) : screenTypeList.get(2); // 特高種
        String shortKey = screenTypeLabel.contains('油')?'油':screenTypeLabel.contains('モールド')?'モールド':'ガス';

        // 見積、見積項目のデータを検索
        if (String.isNotBlank(deviceId)) {
            device = [SELECT Id
                            ,MajorClassification__c
                            ,MinorClassification__c
                            ,Quote__r.PowerFrequency__c //機器周波数
                            ,Quote__r.RecordType.DeveloperName
                            ,(SELECT Id,
                                Name,
                                Name1__c,
                                Name2__c,
                                Name3__c,
                                Name4__c,
                                Name5__c,
                                Name6__c,
                                DetailCategory__c,
                                Price__c,
                                UnitPrice__c,
                                CategoryCode__c,
                                PricingTableUniqueKey__c
                            FROM Details__r
                           WHERE PricingTableUniqueKey__c like '%変圧器特高変圧器%'
                            )
                        FROM 
                            Device__c
                        WHERE 
                            Id = :deviceId
                        LIMIT 1];

            bu = device.Quote__r.RecordType.DeveloperName == FACILITY_RECORD_TYPE ? BU_TYPE_S : BU_TYPE_M; // BUの検索条件をセット
            powerFrequency = device.Quote__r.PowerFrequency__c;//機器周波数
            category = (powerFrequency=='50Hz'?'01':'02');

            // GIS直結、収納盤があり場合の確認
            for (Detail__c existingDetail : device.Details__r) {
                if(existingDetail.DetailCategory__c == '筐体') {
                    detail = existingDetail;
                } else if(existingDetail.DetailCategory__c == '明細') {
                    if (existingDetail.Name2__c.contains('GIS直結') || existingDetail.Name2__c.contains('収納盤')) {
                        optionDetailGIS = existingDetail;
                    } else if (existingDetail.Name2__c.contains('OLCT付')) {
                        optionDetailOLTC = existingDetail;
                    }
                }
            }
        }
        

        // 存在ある場合
        if (isInit && detail != null) {
            shortKey = detail.Name1__c.contains('油')?'油':detail.Name1__c.contains('モールド')?'モールド':'ガス';

            // 存在あるデータによって画面の条件項目を設定
            currentPricingKey = detail.PricingTableUniqueKey__c;

            screenType = INIT_SEARCH_CONDITION.findScreenType(detail.Name1__c);
            searchCondition1 = detail.Name2__c == '屋内' ? '1' : '2';
            searchCondition2 = INIT_SEARCH_CONDITION.findVoltageType(detail.Name5__c, detail.Name4__c);
            searchCondition3 = optionDetailOLTC!=null ? '1' : '0';
            searchCondition4 = detail.Name1__c.contains('スポットネットワーク') ? '1' : '0';
            searchCondition5 = optionDetailGIS!=null ? '1' : '0';

            // 存在あるデータによってQueryの条件を設定
            screenTypeList = INIT_SEARCH_CONDITION.screenTypeMap.get(screenType);
            voltageTypeList = INIT_SEARCH_CONDITION.voltageTypeMap.get(searchCondition2);

            List<PricingTable__c> inputedPricing = [SELECT Id FROM PricingTable__c WHERE UniqueKey__c = :detail.PricingTableUniqueKey__c];

            // 画面のセットした見積の選択仕様と本体価格をセット
            info.inputedId = inputedPricing.size()==0?null:inputedPricing.get(0).Id;
            String name = detail.Name1__c
                        + (String.isNotBlank(detail.Name2__c)?' ' + detail.Name2__c:'')
                        + (String.isNotBlank(detail.Name3__c)?' ' + detail.Name3__c:'')
                        + (String.isNotBlank(detail.Name4__c)?' ' + detail.Name4__c:'')
                        + (String.isNotBlank(detail.Name5__c)?' ' + detail.Name5__c:'')
                        + (String.isNotBlank(detail.Name6__c)?' ' + detail.Name6__c:'');
            info.displayCondition = name;
            info.displayTotal = detail.UnitPrice__c +
                                (optionDetailGIS !=null ? optionDetailGIS.UnitPrice__c : 0) +
                                (optionDetailOLTC !=null ? optionDetailOLTC.UnitPrice__c : 0);
        }

        // isNoData
        info.isNoData = false;
        // screenType
        info.screenType = screenType;
        // searchCondition
        info.searchCondition1 = searchCondition1;
        info.searchCondition2 = searchCondition2;
        info.searchCondition3 = searchCondition3;
        info.searchCondition4 = searchCondition4;
        info.searchCondition5 = searchCondition5;
        //Error Message
        info.errorMsg = '';
        // テーブルの説明をセット
        if (shortKey == '油') {
            info.footer = ANNOTATION_OIL;
        } else if (shortKey == 'ガス') {
            info.footer = ANNOTATION_GAS;
        } else {
            info.footer = ANNOTATION_MOLD;
        }
        
        //電圧仕様 ラベル
        String voltageSpec = String.isEmpty(searchCondition2) || searchCondition2 == '0' ?
                                (shortKey == 'モールド' ? DEFAULT_VOLTAGE_MOLD_TYPE : DEFAULT_VOLTAGE_OIL_TYPE) :
                                voltageTypeList.get(1);

        // 画面テーブルの上にあるの表示するをセット
        String displayTLabel1 = screenTypeList.get(0);
        String displayTLabel2 = info.searchCondition1 == '1' ? '屋内' : '屋外';
        String displayTLabel3 = info.searchCondition5 == '0' ? 'なし' : 'あり';
        String displayTLabel4 = info.searchCondition2 == '0' ? '標準' : voltageTypeList.get(2) + '/' + voltageTypeList.get(1);
        String displayTLabel5 = info.searchCondition3 == '0' ? 'なし' : 'あり';
        String displayTLabel6 = info.searchCondition4 == '0' ? 'なし' : 'あり';
        String displayTableLabel = String.format(
            DISPLAY_TABLE_LABEL,//'{0} {1} GIS直結{2} 電圧仕様{3} OLTC{4} スポットネットワーク{5}';
            new List<String>{
                displayTLabel1,
                displayTLabel2,
                displayTLabel3,
                displayTLabel4,
                displayTLabel5,
                displayTLabel6
            }
        );
        Map<String, String> searchConditionMap = new Map<String, String>{
            'screenType'=>displayTLabel1,
            '設置場所'=>displayTLabel2,
            'GIS直結'=>displayTLabel3,
            '電圧仕様'=>displayTLabel4,
            'OLTC'=>displayTLabel5,
            'スポットネットワーク'=>displayTLabel6
        };

        // Query PricingTable Data
        List<PricingTable__c> pricingTableList = queryPricingTable(new Map<String, String>{
            'shortKey'=>shortKey,
            'category'=>category,
            'bu'=>bu,
            'name1Search'=>searchCondition4 == '0' ? screenTypeList.get(1) : screenTypeList.get(2),//名称1
            'name2Search'=>searchCondition1 == '1' ? '屋内' : '屋外',//名称2
            'name4Search'=> voltageTypeList.get(2),//名称4
            'name5Search'=> voltageSpec//名称5
        });
        if (pricingTableList.size() == 0) {
            info.isNoData = true;
            return JSON.serialize(info); // If there are on record for PricingTable the process will be ended
        }


        String optLabel = shortKey == 'モールド' ? '収納盤' : 'GIS直結'; //テーブルのヘッダに表示する項目を判断

        // query for OLCT
        List<PricingTable__c> optionalPricingOLCTList = queryPricingTableOpt(bu, shortKey, 'OLCT付');
        PricingTable__c optionalPricingOLCT = optionalPricingOLCTList.size()==0?null:optionalPricingOLCTList.get(0);

        // query for GIS
        List<PricingTable__c> optionalPricingList = queryPricingTableOpt(bu, shortKey, optLabel);
        Map<String, PricingTable__c> optionPricingTableMap = new Map<String, PricingTable__c>();
        for (PricingTable__c option : optionalPricingList) {
            String key = option.Name1__c == 'モールド' ? option.Name3__c + option.Name5__c : option.Name3__c;
            if (!optionPricingTableMap.containsKey(key)) optionPricingTableMap.put(key, option);
        }
    

        // header SetUp
        List<BodyRow> headerList = new List<BodyRow>();
        List<BodyCell> headerRow1 = new List<BodyCell>();
        List<BodyCell> headerRow2 = new List<BodyCell>();
        List<BodyCell> headerRow3 = new List<BodyCell>();
        List<BodyCell> headerRow4 = new List<BodyCell>();

        // 価格表のデータとテーブルのヘッダをセット
        headerRow1.add(setCell('容量', null, 4, false));
        headerRow1.add(setCell('一次電圧', null, null, false));
        headerRow2.add(setCell('二次電圧', null, null, false));
        headerRow3.add(setCell('相数', null, null, false));
        headerRow4.add(setCell('周波数', null, null, false));

        Map<String, PricingTable__c> pricingTableMap = new Map<String, PricingTable__c>();
        Set<String> pricingTableName4 = new Set<String>();
        Set<String> pricingTableName6 = new Set<String>();

        for(PricingTable__c pricingTable : pricingTableList) {
            if (!pricingTableName4.contains(pricingTable.Name4__c)) {
                headerRow1.add(setCell(pricingTable.Name4__c, 3, null, false));
                headerRow2.add(setCell(pricingTable.Name5__c, 3, null, false));
                headerRow3.add(setCell(pricingTable.Name3__c, 3, null, false));
                headerRow4.add(setCell(powerFrequency, null, null, false));
                headerRow4.add(setCell(null, null, null, false));
                headerRow4.add(setCell(optLabel, null, null, false));
            }
            String key = pricingTable.Name4__c + '@@' + pricingTable.Name6__c;
            pricingTableMap.put(key, pricingTable);
            pricingTableName4.add(pricingTable.Name4__c);
            pricingTableName6.add(pricingTable.Name6__c);
        }

        headerList.add(setRow(headerRow1));
        headerList.add(setRow(headerRow2));
        headerList.add(setRow(headerRow3));
        headerList.add(setRow(headerRow4));
 
        List<BodyRow> bodyList = new List<BodyRow>();
        for (String name6 : pricingTableName6) {
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();

            bodyRow.add(setCell(name6,2,null,false));//定格電流セル
            for(String name4 : pricingTableName4){
                PricingTable__c priceObj = pricingTableMap.get(name4 + '@@' + name6);
                if(priceObj!=null) {
                    String key = priceObj.Name1__c.contains('モールド') ? priceObj.Name4__c + priceObj.Name6__c : priceObj.Name6__c;
                    PricingTable__c optionalPricingGIS = optionPricingTableMap.get(key);

                    Decimal optionPriceGIS = optionalPricingGIS == null || optionalPricingGIS.Price__c == null ? 0 : optionalPricingGIS.Price__c;
                    Boolean isChecked = String.isNotEmpty(currentPricingKey) && priceObj.UniqueKey__c == currentPricingKey;
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);

                    bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                    bodyRow.add(setCell(getCheckboxCellItem(searchConditionMap, isChecked, priceObj, optionalPricingGIS, optionalPricingOLCT),null,null,true));//入力セル
                    bodyRow.add(setCell(optionPriceGIS.format(), null, null, false));//GISセル
                } else {
                    bodyRow.add(setCell('―',null,null,false));//Empty
                    bodyRow.add(setCell('―',null,null,false));//Empty
                    bodyRow.add(setCell('―',null,null,false));//Empty
                }
            }
            
            row.cellList = bodyRow;
            bodyList.add(row);
    
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        info.headerList = headerList;
        info.bodyList = bodyList;
        info.displayLabel = displayTableLabel;
        info.searchConMap = JSON.serialize(searchConditionMap);
        return JSON.serialize(info);
    }

    // Query PricingTable
    private static List<PricingTable__c> queryPricingTable(Map<String, String> searchCondMap) {
        
        List<String> targetFields = new List<String>{
            'Id',
            'Name1__c',
            'Name2__c',
            'Name3__c',
            'Name4__c',
            'Name5__c',
            'Name6__c',
            'DisplayName__c',
            'Price__c',
            'CategoryCode__c',
            'UniqueKey__c'
        };
        String targetObject = 'PricingTable__c';
        
        String shortKey = searchCondMap.get('shortKey');
        String category = searchCondMap.get('category');
        String bu = searchCondMap.get('bu');
        String name1Search = searchCondMap.get('name1Search');
        String name2Search = searchCondMap.get('name2Search');
        String name4Search = searchCondMap.get('name4Search');
        String name5Search = searchCondMap.get('name5Search');
        String gasSecVoltage = '210V';

        String queryStr = 'SELECT ';
        queryStr += String.join(targetFields, ', ');
        queryStr += ' FROM ' + targetObject;

        queryStr += ' WHERE RecordType.DeveloperName = :PRICING_TABLE_RECORD_TYPE';
        queryStr += ' AND MajorClassificationName__c = :DEFAULT_MAJOR_CLASSIFICATION';
        queryStr += ' AND MinorClassificationName__c = :DEFAULT_MINOR_CLASSIFICATION';

        queryStr += ' AND CategoryCode__c = :category';
        queryStr += ' AND BU__c = :bu';
        queryStr += ' AND Name1__c = :name1Search';
        if (shortKey != 'ガス')
            queryStr += ' AND Name5__c = :name5Search';
        else {
            queryStr += ' AND (Name5__c = :name5Search OR Name5__c = :gasSecVoltage)'; // 特高種類がガスの場合、2次電圧210Vも条件に追加
        }

        if (shortKey != 'モールド')
            queryStr += ' AND Name2__c = :name2Search';
        if (name4Search != '')
            queryStr += ' AND Name4__c = :name4Search'; // 電圧仕様が66,000V/13,800V、22,000V/13,800Vをセットした時に名称4の検索条件を追加
        queryStr += ' ORDER BY Name6__c, Name4__c';
        System.debug('name1Search=' + name1Search);
        System.debug('name5Search=' + name5Search);
        System.debug('name2Search=' + name2Search);
        System.debug('name4Search=' + name4Search);
        System.debug('PRICING_TABLE_RECORD_TYPE=' + PRICING_TABLE_RECORD_TYPE);
        System.debug('DEFAULT_MAJOR_CLASSIFICATION=' + DEFAULT_MAJOR_CLASSIFICATION);
        System.debug('DEFAULT_MINOR_CLASSIFICATION=' + DEFAULT_MINOR_CLASSIFICATION);
        System.debug('category=' + category);
        System.debug('bu=' + bu);
        System.debug('検索SOQL=' + queryStr);

        List<PricingTable__c> pricingTableList = (List<PricingTable__c>) Database.query(queryStr);
        System.debug('pricingTableList=' + pricingTableList);
        SortablePricingTable.sort(pricingTableList);
        return pricingTableList;
    }

    // Query Option PricingTable
    private static List<PricingTable__c> queryPricingTableOpt(String bu, String name1OptSearch, String name2OptSearch) {
        List<PricingTable__c> optionalPricingList = [SELECT Id, 
                                                            Name1__c,
                                                            Name2__c,
                                                            Name3__c,
                                                            Name4__c,
                                                            Name5__c,
                                                            Name6__c,
                                                            DisplayName__c,
                                                            Price__c,
                                                            CategoryCode__c,
                                                            UniqueKey__c
                                                        FROM 
                                                            PricingTable__c
                                                        WHERE
                                                            RecordType.DeveloperName = :DETAIL_RECORD_TYPE AND
                                                            MajorClassificationName__c = :DEFAULT_MAJOR_CLASSIFICATION AND 
                                                            MinorClassificationName__c = :DEFAULT_MINOR_CLASSIFICATION AND 
                                                            BU__c = :bu AND 
                                                            CategoryCode__c = :DETAIL_CATEGORY_CODE AND 
                                                            Name1__c =:name1OptSearch AND
                                                            Name2__c =:name2OptSearch];
        return optionalPricingList;
    }

    //入力セルを設定
    private static Map<String, Object> getCheckboxCellItem(Map<String, String> searchConditionMap, Boolean isChecked, PricingTable__c priceObj, PricingTable__c optionPricingGIS, PricingTable__c optionPricingOLCT){
        Map<String, Object> cellItem = new Map<String,Object>();

        Decimal price = priceObj.Price__c;
        price += searchConditionMap.get('GIS直結')=='なし' ? 0 : (optionPricingGIS==null||optionPricingGIS.Price__c==null?0:optionPricingGIS.Price__c);
        price += searchConditionMap.get('OLTC')=='なし' ? 0 : (optionPricingOLCT==null||optionPricingOLCT.Price__c==null?0:optionPricingOLCT.Price__c);

        String name = priceObj.Name1__c
                    + (String.isNotBlank(priceObj.Name2__c)?' ' + priceObj.Name2__c:'')
                    + (String.isNotBlank(priceObj.Name3__c)?' ' + priceObj.Name3__c:'')
                    + (String.isNotBlank(priceObj.Name4__c)?' ' + priceObj.Name4__c:'')
                    + (String.isNotBlank(priceObj.Name5__c)?' ' + priceObj.Name5__c:'')
                    + (String.isNotBlank(priceObj.Name6__c)?' ' + priceObj.Name6__c:'');
        
        cellItem.put('id', priceObj.Id);
        cellItem.put('price', price);
        cellItem.put('title', name + '@@' + JSON.serialize(searchConditionMap));
        cellItem.put('isChecked', isChecked);

        return cellItem;
    }

    //セルに値を設定
    private static BodyCell setCell(Object value,Integer colSpanCnt,Integer rowSpanCnt, Boolean isEdit){
        BodyCell cell = new BodyCell();
        cell.isEdit=isEdit;
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

    private static BodyRow setRow(List<BodyCell> cellList) {
        BodyRow row = new BodyRow();
        row.cellList.addAll(cellList);
        return row;
    }

    // 検索条件のデータ準備
    private class InitSearchCondition {
        public Map<String, List<String>> screenTypeMap;
        public Map<String, List<String>> voltageTypeMap;

        InitSearchCondition() {
            Map<String, List<String>> screenTypeMap = new Map<String, List<String>>();
            screenTypeMap.put('1', new List<String>{'特高TR 油入', '油', '油 スポットネットワーク'});
            screenTypeMap.put('2', new List<String>{'特高TR モールド', 'モールド', 'モールド スポットネットワーク'});
            screenTypeMap.put('3', new List<String>{'特高TRガス', 'ガス', 'ガス スポットネットワーク'});

            Map<String, List<String>> voltageTypeMap = new Map<String, List<String>>();
            voltageTypeMap.put('0', new List<String>{'標準', '', ''});
            voltageTypeMap.put('1', new List<String>{'66,000V/13,800V', '13,800V', '66,000V'});
            voltageTypeMap.put('2', new List<String>{'22,000V/13,800V', '13,800V', '22,000V'});
            voltageTypeMap.put('9', new List<String>{'二次電圧低圧', '400V級', ''});

            this.voltageTypeMap = voltageTypeMap;
            this.screenTypeMap = screenTypeMap;
        }

        public String findScreenType(String pricingTableName1) {
            String screenType;
            for (String key : screenTypeMap.keySet()) {
                List<String> targetList = screenTypeMap.get(key);
                if (targetList.get(0).contains(pricingTableName1) || targetList.get(2).contains(pricingTableName1)) screenType = key;
            }

            return screenType;
        }

        public String findVoltageType(String pricingTableName5, String pricingTableName4) {
            if (pricingTableName5.contains('13,800V')) return pricingTableName4 == '66,000V' ? '1' : '2';
            if (pricingTableName5.contains('400V級')) return '9';
            return '0';
        }
    }

    

    @AuraEnabled
    public static String submitDetailsForExtraHigh(String deviceId, String rId, String cnt, String title) {
        try {
            Device__c device = [SELECT Id, Quote__c,(SELECT Id FROM Details__r WHERE PricingTableUniqueKey__c like '%変圧器特高変圧器%') FROM Device__c WHERE Id =:deviceId LIMIT 1];
            //既存明細を削除
            List<Detail__c> deleteDetails = device.Details__r;//AND PricingTable__c IN:delIds

            List<Detail__c> insertList = new List<Detail__c>();

            // 価格表のデータを検索
            PricingTable__c pricingTable = [SELECT Id, Name, RECNo__c,
                                                MajorClassificationCode__c, 
                                                MajorClassificationName__c, 
                                                MinorClassificationCode__c, 
                                                MinorClassificationName__c, 
                                                CategoryCode__c,CategoryName__c,
                                                Name1__c, Name2__c,Name3__c,Name4__c,Name5__c, Name6__c, Name7__c, Name8__c, Name9__c, Name10__c, 
                                                BU__c, WC__c, Price__c, UniqueKey__c,ConditionForSearchformula__c,
                                                Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                                                Note__c
                                            FROM PricingTable__c
                                            WHERE Id =:rId
                                            LIMIT 1];

            Map<String, String> searchConditionMap = (Map<String, String>)JSON.deserialize(title, Map<String, String>.class);

            // GIS直結、収納盤がありの場合
            if (searchConditionMap.get('GIS直結')=='あり') {
                String screenType = searchConditionMap.get('screenType');
                String name1Search = screenType.contains('油')?'油':screenType.contains('モールド')?'モールド':'ガス';
                String name2Search = screenType.contains('モールド')?'収納盤':'GIS直結';
                List<String> targetFields = new List<String>{
                    'Id', 
                    'Name',
                    'RECNo__c',
                    'MajorClassificationCode__c', 
                    'MajorClassificationName__c', 
                    'MinorClassificationCode__c', 
                    'MinorClassificationName__c', 
                    'CategoryCode__c',
                    'CategoryName__c',
                    'Name1__c', 
                    'Name2__c',
                    'Name3__c',
                    'Name4__c',
                    'Name5__c', 
                    'Name6__c', 
                    'Name7__c', 
                    'Name8__c', 
                    'Name9__c', 
                    'Name10__c', 
                    'WC__c', 
                    'WcCalculationRate__c', 
                    'Price__c', 
                    'UniqueKey__c',
                    'Weight__c',
                    'DisplayName__c',
                    'detailedStatementText__c',
                    'SpecialSpecificationNo__c',
                    'Note__c'
                };

                String targetObject = 'PricingTable__c';

                String queryOptionStr = 'SELECT ';
                queryOptionStr += String.join(targetFields, ', ');
                queryOptionStr += ' FROM ' + targetObject;
        
                String bu = pricingTable.BU__c;
                String primaryVoltageSearch = pricingTable.Name4__c;
                String frequency = pricingTable.Name6__c;

                queryOptionStr += ' WHERE RecordType.DeveloperName = :DETAIL_RECORD_TYPE';
                queryOptionStr += ' AND MajorClassificationName__c = :DEFAULT_MAJOR_CLASSIFICATION';
                queryOptionStr += ' AND MinorClassificationName__c = :DEFAULT_MINOR_CLASSIFICATION';

                queryOptionStr += ' AND BU__c = :bu';
                queryOptionStr += ' AND CategoryCode__c = :DETAIL_CATEGORY_CODE';

                queryOptionStr += ' AND Name1__c = :name1Search';
                queryOptionStr += ' AND Name2__c = :name2Search';

                if (name1Search == 'モールド'){
                    queryOptionStr += ' AND Name3__c = :primaryVoltageSearch';
                    queryOptionStr += ' AND Name5__c = :frequency';
                } else {
                    queryOptionStr += ' AND Name3__c = :frequency';
                }                

                queryOptionStr += ' LIMIT 1';
                
                List<PricingTable__c> optionalPricingTableGIS = (List<PricingTable__c>) Database.query(queryOptionStr);
                
                if (optionalPricingTableGIS.size() != 0) {
                    Detail__c optionalDetail = new Detail__c();
                    optionalDetail.Device__c = deviceId;
                    optionalDetail.Name = optionalPricingTableGIS.get(0).DisplayName__c;
                    optionalDetail.Name1__c = optionalPricingTableGIS.get(0).Name1__c;
                    optionalDetail.Name2__c = optionalPricingTableGIS.get(0).Name2__c;
                    optionalDetail.Name3__c = optionalPricingTableGIS.get(0).Name3__c;
                    optionalDetail.Name4__c = optionalPricingTableGIS.get(0).Name4__c;
                    optionalDetail.PricingTableUniqueKey__c = optionalPricingTableGIS.get(0).UniqueKey__c;
                    optionalDetail.CreditWC__c = optionalPricingTableGIS.get(0).WC__c;
                    optionalDetail.UnitPrice__c = optionalPricingTableGIS.get(0).Price__c;
                    optionalDetail.CreditWeight__c = optionalPricingTableGIS.get(0).Weight__c;
                    optionalDetail.DetailCategory__c = '明細';
                    optionalDetail.Quantity__c = 1;
                    optionalDetail.WcCalculationRate__c = optionalPricingTableGIS.get(0).WcCalculationRate__c;
                    optionalDetail.Note__c = optionalPricingTableGIS.get(0).Note__c;
                    optionalDetail.Name5__c = optionalPricingTableGIS.get(0).Name5__c;
                    optionalDetail.Name6__c = optionalPricingTableGIS.get(0).Name6__c;
                    optionalDetail.Name7__c = optionalPricingTableGIS.get(0).Name7__c;
                    optionalDetail.Name8__c = optionalPricingTableGIS.get(0).Name8__c;
                    optionalDetail.Name9__c = optionalPricingTableGIS.get(0).Name9__c;
                    optionalDetail.Name10__c = optionalPricingTableGIS.get(0).Name10__c;
                    optionalDetail.detailedStatementText__c = optionalPricingTableGIS.get(0).detailedStatementText__c;
                    optionalDetail.SpecialSpecificationNo__c = optionalPricingTableGIS.get(0).SpecialSpecificationNo__c;
                    optionalDetail.MajorClassificationName__c = optionalPricingTableGIS.get(0).MajorClassificationName__c;
                    optionalDetail.MajorClassificationCode__c = optionalPricingTableGIS.get(0).MajorClassificationCode__c;
                    optionalDetail.MinorClassificationName__c = optionalPricingTableGIS.get(0).MinorClassificationName__c;
                    optionalDetail.MinorClassificationCode__c = optionalPricingTableGIS.get(0).MinorClassificationCode__c;
                    optionalDetail.CategoryName__c = optionalPricingTableGIS.get(0).CategoryName__c;
                    optionalDetail.CategoryCode__c = optionalPricingTableGIS.get(0).CategoryCode__c;

                    insertList.add(optionalDetail);
                }
            }

            // OLTCがありの場合
            if (searchConditionMap.get('OLTC')=='あり') {
                String screenType = searchConditionMap.get('screenType');
                String name1Search = screenType.contains('油')?'油':screenType.contains('モールド')?'モールド':'ガス';
                String name2Search = 'OLCT付';
                PricingTable__c optionalPricingTableOLTC = [SELECT Id, Name, RECNo__c,
                                                            MajorClassificationCode__c, 
                                                            MajorClassificationName__c, 
                                                            MinorClassificationCode__c, 
                                                            MinorClassificationName__c, 
                                                            CategoryCode__c,CategoryName__c,
                                                            Name1__c, Name2__c,Name3__c,Name4__c,Name5__c, Name6__c, Name7__c, Name8__c, Name9__c, Name10__c, 
                                                            WC__c, WcCalculationRate__c, Price__c, UniqueKey__c,
                                                            Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                                                            Note__c
                                                        FROM PricingTable__c
                                                        WHERE
                                                            RecordType.DeveloperName = :DETAIL_RECORD_TYPE AND
                                                            MajorClassificationName__c = :DEFAULT_MAJOR_CLASSIFICATION AND 
                                                            MinorClassificationName__c = :DEFAULT_MINOR_CLASSIFICATION AND 
                                                            BU__c = :pricingTable.BU__c AND 
                                                            CategoryCode__c = :DETAIL_CATEGORY_CODE AND 
                                                            Name1__c =:name1Search AND
                                                            Name2__c =:name2Search
                                                        LIMIT 1];
                
                if (optionalPricingTableOLTC != null) {
                    Detail__c optionalDetail = new Detail__c();
                    optionalDetail.Device__c = deviceId;
                    optionalDetail.Name = optionalPricingTableOLTC.DisplayName__c;
                    optionalDetail.Name1__c = optionalPricingTableOLTC.Name1__c;
                    optionalDetail.Name2__c = optionalPricingTableOLTC.Name2__c;
                    optionalDetail.Name3__c = optionalPricingTableOLTC.Name3__c;
                    optionalDetail.Name4__c = optionalPricingTableOLTC.Name4__c;
                    optionalDetail.PricingTableUniqueKey__c = optionalPricingTableOLTC.UniqueKey__c;
                    optionalDetail.CreditWC__c = optionalPricingTableOLTC.WC__c;
                    optionalDetail.UnitPrice__c = optionalPricingTableOLTC.Price__c;
                    optionalDetail.CreditWeight__c = optionalPricingTableOLTC.Weight__c;
                    optionalDetail.DetailCategory__c = '明細';
                    optionalDetail.Quantity__c = 1;
                    optionalDetail.WcCalculationRate__c = optionalPricingTableOLTC.WcCalculationRate__c;
                    optionalDetail.Note__c = optionalPricingTableOLTC.Note__c;
                    optionalDetail.Name5__c = optionalPricingTableOLTC.Name5__c;
                    optionalDetail.Name6__c = optionalPricingTableOLTC.Name6__c;
                    optionalDetail.Name7__c = optionalPricingTableOLTC.Name7__c;
                    optionalDetail.Name8__c = optionalPricingTableOLTC.Name8__c;
                    optionalDetail.Name9__c = optionalPricingTableOLTC.Name9__c;
                    optionalDetail.Name10__c = optionalPricingTableOLTC.Name10__c;
                    optionalDetail.detailedStatementText__c = optionalPricingTableOLTC.detailedStatementText__c;
                    optionalDetail.SpecialSpecificationNo__c = optionalPricingTableOLTC.SpecialSpecificationNo__c;
                    optionalDetail.MajorClassificationName__c = optionalPricingTableOLTC.MajorClassificationName__c;
                    optionalDetail.MajorClassificationCode__c = optionalPricingTableOLTC.MajorClassificationCode__c;
                    optionalDetail.MinorClassificationName__c = optionalPricingTableOLTC.MinorClassificationName__c;
                    optionalDetail.MinorClassificationCode__c = optionalPricingTableOLTC.MinorClassificationCode__c;
                    optionalDetail.CategoryName__c = optionalPricingTableOLTC.CategoryName__c;
                    optionalDetail.CategoryCode__c = optionalPricingTableOLTC.CategoryCode__c;

                    insertList.add(optionalDetail);
                }
            }

            Detail__c detail = new Detail__c();
            detail.Device__c = deviceId;
            detail.Name = pricingTable.DisplayName__c;
            detail.Name1__c = pricingTable.Name1__c;
            detail.Name2__c = pricingTable.Name2__c;
            detail.Name3__c = pricingTable.Name3__c;
            detail.Name4__c = pricingTable.Name4__c;
            detail.PricingTableUniqueKey__c = pricingTable.UniqueKey__c;
            detail.CreditWC__c = pricingTable.WC__c;
            detail.UnitPrice__c = pricingTable.Price__c;
            detail.CreditWeight__c = pricingTable.Weight__c;
            detail.DetailCategory__c = '筐体';
            detail.Quantity__c = 1;
            detail.WcCalculationRate__c = 0;
            detail.Note__c = pricingTable.Note__c;
            detail.Name5__c = pricingTable.Name5__c;
            detail.Name6__c = pricingTable.Name6__c;
            detail.Name7__c = pricingTable.Name7__c;
            detail.Name8__c = pricingTable.Name8__c;
            detail.Name9__c = pricingTable.Name9__c;
            detail.Name10__c = pricingTable.Name10__c;
            detail.detailedStatementText__c = pricingTable.detailedStatementText__c;
            detail.SpecialSpecificationNo__c = pricingTable.SpecialSpecificationNo__c;
            detail.MajorClassificationName__c = pricingTable.MajorClassificationName__c;
            detail.MajorClassificationCode__c = pricingTable.MajorClassificationCode__c;
            detail.MinorClassificationName__c = pricingTable.MinorClassificationName__c;
            detail.MinorClassificationCode__c = pricingTable.MinorClassificationCode__c;
            detail.CategoryName__c = pricingTable.CategoryName__c;
            detail.CategoryCode__c = pricingTable.CategoryCode__c;
            insertList.add(detail);

            insert insertList;
            delete deleteDetails;
            return device.Quote__c;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            return 'Error';
        }
    }
}