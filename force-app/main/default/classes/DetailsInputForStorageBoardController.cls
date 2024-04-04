public with sharing class DetailsInputForStorageBoardController {
    public static final String FACILITY_RECORD_TYPE = 'Facility';
    public static final String PRICING_TABLE_DETAIL_RECORD_TYPE = 'Detail';
    public static final String BU_TYPE_S = 'S';
    public static final String BU_TYPE_M = 'M';

    public static final String MAJOR_CLASSIFICATION_TYPE = '変圧器';
    public static final String MINOR_CLASSFICATION_TYPE = '変圧器収納盤';
    public static final List<String> SEARCH_OPTIONS = new List<String>{'屋内','屋外','屋内FF','屋外FF'};

    public class StorageBoardInfo {
        public CustomTable transformerLowVoltageTable { get; set; } //変成機器：低圧
        public CustomTable loadDisconnectorTable { get; set; }  //ヒューズ付負荷開閉器（LBS)
        public CustomTable transformerStoragePanelHighVoltageTable { get; set; }    //変圧器収納盤(高圧)　(FFの場合は×0.8とすること)
        public CustomTable transformerStoragePanelLowVoltageTable { get; set; } //変圧器収納盤(低圧)　(FFの場合は×0.8とすること)
        public CustomTable groundTransformerTable { get; set; } //接地トランス(GTR) (3相､6600/190V､50/60Hz,モールド)
        public CustomTable groundTransformerWithNeutralPointTable { get; set; } //中性点付接地トランス(NGR) (3相､6600/190V､50/60Hz,モールド)
        public CustomTable transformersLightingAndBuildingTable { get; set; }   //照明用・建築付帯用トランス(単相3線､400,200/100V)
        public CustomTable thunderResistantTable { get; set; }  //耐雷トランス　耐雷TRを耐雷トランスに変更　mod by Kisanuki 2023/03/07
        public CustomTable transformerHighVoltagePowerReceivingTable { get; set; }  //高圧盤内照明・電源用トランス(単相2線､6600/105V,モールド)　高圧受電用操作トランスを高圧盤内照明・電源用トランスに変更　mod by Kisanuki 2023/03/07
        public String searchOption{get;set;}
    }

    //一覧に表示する情報
    public class CustomTable {
        Public String secTitle{get;set;}//タイトル
        Public String comment{get;set;}//一覧右上のコメント
        public List<BodyRow> bodyList {get;set;}//表示内容
        public List<BodyRow> headerList {get;set;}//一覧ヘッダ情報
        Public List<String> noteList {get;set;}//一覧下の「注※」内容
        Public Boolean isHasDetail {get;set;}//明細のレコードが存在しているチェック
        Map<String, Object> recMap {get;set;}
        Public Map<Id, Map<String,Object>> displayConditionMap {get;set;}
    }

    public class BodyRow {
        public List<BodyCell> cellList { get; set; }
    }

    public class BodyCell {
        public Object value { get; set; }
        public Integer colSpanCnt { get; set; }
        public Boolean isColSpan { get; set; }
        public Integer rowSpanCnt { get; set; }
        public Boolean isRowSpan { get; set; }
        public Boolean isEdit { get; set; }
        public Boolean isRight { get; set; }
    }
    
    public class QuantityObject{
        public String Id {get;set;}
        public Decimal Price {get;set;}
        public Decimal Quantity {get;set;}
        // public String Option {get;set;}
    }

    @AuraEnabled
    /*
     *内訳入力B_変圧器収納盤及びその他  保存ボタン　処理
     */
    public static string submitStorageBoardDetails(String details,String deviceId){
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
        
        Device__c device = [ SELECT Id, Quote__c,(SELECT Id FROM Details__r WHERE PricingTableUniqueKey__c like '%変圧器変圧器収納盤%' OR PricingTableUniqueKey__c like '%共通機器%') FROM Device__c WHERE Id =:deviceId LIMIT 1];

        //既存情報を削除
        //12/15modify ByTS木佐貫
        List<Detail__c> deleteDetails = device.Details__r;//AND PricingTable__c IN:delIds
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
                                                                        Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, 
                                                                        Name6__c, Name7__c, Name8__c, Name9__c, Name10__c,
                                                                        WC__c, WcCalculationRate__c,
                                                                        Price__c,
                                                                        Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                                                                        Note__c
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
                        detail.Device__c = deviceId;//機器ID
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
                        detail.Name = pricingTable.DisplayName__c;//表示用テキスト
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

                        detailList.add(detail); 
                    }
                }
            }
            if (detailList.size()>0) insert detailList;
        }
        //12/15modify ByTS木佐貫
        return device.Quote__c;
    }

    @AuraEnabled
    public static String getStorageBoardScreenInfo(Boolean init, String deviceId, String searchOption, String inputsRecords) {
        String majorClassification;
        String minorClassification;
        String quotationRecordType;
        String bu;

        StorageBoardInfo info = new StorageBoardInfo();

        Device__c devices = [SELECT Id
                                ,Name
                                ,Quote__r.RecordType.Name
                                ,(SELECT Id
                                    ,Name
                                    ,Name2__c
                                    ,DetailCategory__c
                                FROM Details__r
                                WHERE DetailCategory__c='筐体')
                            FROM Device__c
                            WHERE Id =: deviceId LIMIT 1];
        
        if(init&&devices.Details__r.size()>0) {
            searchOption = SEARCH_OPTIONS.contains(devices.Details__r.get(0).Name2__c) ? devices.Details__r.get(0).Name2__c: searchOption;
        }

        info.searchOption = searchOption;

        List<Device__c> deviceList = DeviceController.getDevice(deviceId);
        if (deviceList != null && deviceList.size() > 0) {
            Device__c device = deviceList.get(0);
            majorClassification = device.MajorClassification__c;
            minorClassification = device.MinorClassification__c;
            quotationRecordType = device.Quote__r.RecordType.DeveloperName;
            bu = device.Quote__r.RecordType.DeveloperName == FACILITY_RECORD_TYPE ? BU_TYPE_S : BU_TYPE_M;
        }

        
        // 変成機器：低圧
        List<PricingTable__c> priceList =   [SELECT Id,UniqueKey__c, Name, RecordType.DeveloperName,
                                                    MajorClassificationName__c,//大分類
                                                    MinorClassificationName__c, //小分類
                                                    CategoryName__c,//種類名
                                                    DisplayName__c,//表示用テキスト
                                                    Name1__c, //名称１
                                                    Name2__c, //名称２
                                                    Name3__c, //名称３
                                                    Name4__c, //名称４
                                                    Name5__c, //名称５
                                                    Name6__c, //名称６
                                                    Name7__c, //名称７
                                                    Name8__c, //名称８
                                                    Name9__c, //名称９
                                                    Name10__c, //名称１０
                                                    WC__c, 
                                                    Price__c, //単価
                                                    //Weight__c,
                                                    Note__c 
                                                FROM PricingTable__c
                                                WHERE BU__c =:bu
                                                    AND ((MajorClassificationName__c = '変圧器'
                                                    AND MinorClassificationName__c = '変圧器収納盤'
                                                        AND ((RecordType.DeveloperName = 'Chassis')
                                                            OR (RecordType.DeveloperName = 'Detail' 
                                                                AND (Name1__C IN (''
                                                                ))
                                                            )
                                                        )
                                                    )
                                                    OR (MajorClassificationName__c = '共通機器'
                                                        AND ((RecordType.DeveloperName = 'Chassis' )
                                                            OR (RecordType.DeveloperName = 'Detail' 
                                                                AND (Name1__C IN ('計器用変流器'
                                                                                ,'零相変流器+地絡過電流継電器'
                                                                                ,'ヒューズ付負荷開閉器'
                                                                                ,'接地トランス'
                                                                                ,'中性点付接地トランス'
                                                                                ,'照明用・建築付帯用トランス'
                                                                                ,'耐雷トランス'
                                                                                ,'高圧盤内照明・電源用トランス'
                                                                                ,''
                                                                ) OR Name2__C IN ('CT'
                                                                                ,'ZCT+51G'
                                                                                ,'LBS'
                                                                                ,'GTR'
                                                                                ,'NGR'
                                                                                ,''
                                                                ) OR Name3__C IN ('一次電流1,000A'
                                                                                ,'低圧'
                                                                                ,''
                                                                ))
                                                            )
                                                        )
                                                    )
                                                )
                                                ORDER BY RECNO__c
    
                                                ];
        


        //画面入力された情報
        List<Object> inputsRecordsList;
        Map<Id, Detail__c> detailMap = DetailController.getDetailRecordsByDeviceId(deviceId);
        if (String.isNotBlank(inputsRecords)) {
            inputsRecordsList = (List<Object>)JSON.deserializeUntyped(inputsRecords);
            //全件処理
            for (Object o : inputsRecordsList) {
                Map<String,Object> record = (Map<String,Object>)o;
                String id = (String)record.get('Id');
                String cnt = String.valueof(record.get('Quantity'));
                Detail__c tmp = detailMap.get((Id)id);
                if (tmp==null) {
                    tmp = new Detail__c() ;
                    detailMap.put((Id)id, tmp);//数量が入力されたものは　表示対象
                }
                tmp.Quantity__c=(String.isNotBlank(cnt)?Decimal.valueof(cnt):null);
                
            }
        }
    
        // Waiting for Master Data
        QuantityObject quantityObject = new QuantityObject();

        //変成機器：低圧
        CustomTable transformerLowVoltageTable = setTransformerLowVoltageTable(priceList, detailMap);
        info.transformerLowVoltageTable = transformerLowVoltageTable;//変成機器：低圧
        //ヒューズ付負荷開閉器（LBS)
        CustomTable loadDisconnectorTable = setLoadDisconnectorTable(priceList, detailMap);
        info.loadDisconnectorTable = loadDisconnectorTable;//ヒューズ付負荷開閉器（LBS)
        //変圧器収納盤(高圧)　(FFの場合は×0.8とすること)
        CustomTable transformerStoragePanelHighVoltageTable = setTransformerStoragePanelHighVoltageTable(priceList, detailMap, searchOption);
        info.transformerStoragePanelHighVoltageTable = transformerStoragePanelHighVoltageTable;//変圧器収納盤(高圧)　(FFの場合は×0.8とすること)
        //変圧器収納盤(低圧)　(FFの場合は×0.8とすること)
        CustomTable transformerStoragePanelLowVoltageTable = setTransformerStoragePanelLowVoltage(priceList, detailMap, searchOption);
        info.transformerStoragePanelLowVoltageTable = transformerStoragePanelLowVoltageTable;//変圧器収納盤(低圧)　(FFの場合は×0.8とすること)
        //接地トランス(GTR) (3相､6600/190V､50/60Hz,モールド)
        CustomTable groundTransformerTable = setGroundTransformerTable(priceList, detailMap);
        info.groundTransformerTable = groundTransformerTable;//接地トランス(GTR) (3相､6600/190V､50/60Hz,モールド)
        //中性点付接地トランス(NGR) (3相､6600/190V､50/60Hz,モールド)
        CustomTable groundTransformerWithNeutralPointTable = setGroundTransformerWithNeutralPointTable(priceList, detailMap);
        info.groundTransformerWithNeutralPointTable = groundTransformerWithNeutralPointTable;//中性点付接地トランス(NGR) (3相､6600/190V､50/60Hz,モールド)
        //照明用・建築付帯用トランス(単相3線､400,200/100V)
        CustomTable transformersLightingAndBuildingTable = setTransformersLightingAndBuildingTable(priceList, detailMap);
        info.transformersLightingAndBuildingTable = transformersLightingAndBuildingTable;//照明用・建築付帯用トランス(単相3線､400,200/100V)
        //耐雷トランス
        CustomTable thunderResistantTable = setThunderResistantTable(priceList, detailMap);
        info.thunderResistantTable = thunderResistantTable;//耐雷トランス
        //高圧盤内照明・電源用トランス(単相2線､6600/105V,モールド)
        CustomTable transformerHighVoltagePowerReceivingTable = setTransformerHighVoltagePowerReceivingTable(priceList, detailMap);
        info.transformerHighVoltagePowerReceivingTable = transformerHighVoltagePowerReceivingTable;//高圧盤内照明・電源用トランス(単相2線､6600/105V,モールド)

       return JSON.serialize(info);
    }

    //変成機器：低圧 一覧表示内容の設定
    private static CustomTable setTransformerLowVoltageTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable transformerLowVoltageTable = new CustomTable();
        Set<String> transformerLowVoltageName2 = new Set<String>();//名称２
        Map<String, PricingTable__c> transformerLowVoltageInfoMap = new Map<String, PricingTable__c>();
        for (PricingTable__c item : priceList) {
            //仕様１が変成機器：低圧のは　対象とする

            if(item.MajorClassificationName__c == '共通機器' &&
                item.RecordType.DeveloperName == 'Detail' && (
                    (item.Name1__c == '計器用変流器' &&
                    item.Name2__c == 'CT' &&
                    item.Name3__c == '一次電流1,000A') 
                    || (item.Name1__c == '零相変流器+地絡過電流継電器' &&
                    item.Name2__c == 'ZCT+51G' &&
                    item.Name3__c == '低圧')
                )
            ){
                transformerLowVoltageName2.add(item.Name2__c);
                transformerLowVoltageInfoMap.put(item.Name2__c,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //仕様・型番    価格    数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        List<String> transformerLowVoltageName2list = new List<String>(transformerLowVoltageName2);
        transformerLowVoltageName2list.sort();
        
        for(String name2 : transformerLowVoltageName2list){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = transformerLowVoltageInfoMap.get(name2);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(name2,null,null,false,true));//仕様
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
            
        }


        //タイトルの設定
        transformerLowVoltageTable.secTitle = '変成機器：低圧';//タイトル
        transformerLowVoltageTable.comment = '';//コメント
        transformerLowVoltageTable.headerList = headerList;//ヘッダ
        transformerLowVoltageTable.bodyList = bodyList;//ボディー
        return transformerLowVoltageTable;
    }

    //ヒューズ付負荷開閉器（LBS) 一覧表示内容の設定
    private static CustomTable setLoadDisconnectorTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable loadDisconnectorTable = new CustomTable();
        Set<String> loadDisconnectorName4 = new Set<String>();//名称4
        Map<String,Set<String>> loadDisconnectorName3 = new Map<String,Set<String>>();//名称3+名称4
        Map<String, PricingTable__c> loadDisconnectorInfoMap = new Map<String, PricingTable__c>();//真空遮断器（VCB）情報

        for (PricingTable__c item : priceList) {
            if(item.MajorClassificationName__c == '共通機器' &&
                item.RecordType.DeveloperName == 'Detail' && (
                    (item.Name1__c == 'ヒューズ付負荷開閉器' &&
                        item.Name2__c == 'LBS')
                )
            ) { 
                String key = item.Name3__c + '@@' + item.Name4__c;//キー
                loadDisconnectorName4.add(item.Name4__c);
                Set<String> name4List=loadDisconnectorName3.get(item.Name3__c);
                if (name4List==null) {
                    name4List = new Set<String>();
                    loadDisconnectorName3.put(item.Name3__c,name4List);
                }
                name4List.add(item.Name4__c);
                loadDisconnectorInfoMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow1.add(setCell('電　流',null,2,false,false));
        for (String name4 : loadDisconnectorName4) {
            headerRow1.add(setCell(name4,2,null,false,false));
            headerRow2.add(setCell('価格',null,null,false,true));
            headerRow2.add(setCell('数量',null,null,false,true));
        }
        BodyRow row1 = new BodyRow();
        BodyRow row2 = new BodyRow();
        row1.cellList=headerRow1;
        row2.cellList=headerRow2;
        headerList.add(row1);
        headerList.add(row2);

        BodyRow row = new BodyRow();
        List<BodyCell> bodyRow  = new List<BodyCell>();
        for (String name3 : loadDisconnectorName3.keyset()) {
            bodyRow.add(setCell(name3,null,null,false,false));//電  流

            Set<String> name4List=loadDisconnectorName3.get(name3);
            for(String name4 : name4List){
                PricingTable__c priceObj = loadDisconnectorInfoMap.get(name3 + '@@' + name4);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                }
            }            
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }


        //タイトルの設定
        loadDisconnectorTable.secTitle = 'ヒューズ付負荷開閉器（LBS)';//タイトル
        loadDisconnectorTable.headerList = headerList;//ヘッダ
        loadDisconnectorTable.bodyList = bodyList;//ボディー
        return loadDisconnectorTable;
    }

    //変圧器収納盤(高圧)　(FFの場合は×0.8とすること) 一覧表示内容の設定
    private static CustomTable setTransformerStoragePanelHighVoltageTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap, String searchOption){
        CustomTable transformerStoragePanelHighVoltageTable = new CustomTable();
        List<PricingTable__c> transformerStoragePanelHighVoltageList = new List<PricingTable__c>();
        Map<Id, Map<String,Object>> displayConditionMap = new Map<Id, Map<String,Object>>();
        
        for (PricingTable__c item : priceList) {
            Map<String,Object> conditionMap = new Map<String,Object>();
            if(item.MajorClassificationName__c == '変圧器' &&
                item.MinorClassificationName__c == '変圧器収納盤' &&
                item.RecordType.DeveloperName == 'Chassis' &&
                item.Name1__c == '変圧器収納盤(高圧)'&&
                item.Name2__c == searchOption
            ) {
                transformerStoragePanelHighVoltageList.add(item);
                String conditionName = (item.Name1__c==null?'':item.Name1__c)
                                    +(item.Name2__c==null?'':' '+item.Name2__c)
                                    +(item.Name3__c==null?'':' '+item.Name3__c)
                                    +(item.Name4__c==null?'':' '+item.Name4__c);
                conditionMap.put('condition', conditionName);
                conditionMap.put('price', (item.Price__c==null?0:item.Price__c));
                displayConditionMap.put(item.Id, conditionMap);
            }
            else if(item.MajorClassificationName__c == '変圧器' &&
                    item.MinorClassificationName__c == '変圧器収納盤' &&
                    item.RecordType.DeveloperName == 'Chassis' &&
                    item.Name1__c == '変圧器収納盤(高圧)'&&
                    (item.Name2__c == '屋内' || item.Name2__c == '屋外' || item.Name2__c == '屋内FF' || item.Name2__c == '屋内FF')
            ){                
                String conditionName = (item.Name1__c==null?'':item.Name1__c)
                                    +(item.Name2__c==null?'':' '+item.Name2__c)
                                    +(item.Name3__c==null?'':' '+item.Name3__c)
                                    +(item.Name4__c==null?'':' '+item.Name4__c);
                conditionMap.put('condition', conditionName);
                conditionMap.put('price', (item.Price__c==null?0:item.Price__c));
                displayConditionMap.put(item.Id, conditionMap);

            }
        }

        //登録したレコードを確認する
        // Boolean isHasDetail = false;
        // Map<String, Object> recMap = new Map<String, Object>();
        // for(Id recId : displayConditionMap.keySet()){
        //     if (detailMap.get(recId)!=null) {
        //         isHasDetail = true;
        //         recMap.put('Id', recId);
        //         recMap.put('Price', displayConditionMap.get(recId).get('price'));
        //         recMap.put('Quantity', detailMap.get(recId).Quantity__c);
        //         break;
        //     }            
        // }       

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('変圧器容量',null,null,false,false));
        headerRow1.add(setCell('価  格',null,null,false,false));
        headerRow1.add(setCell('標準盤外形寸法',null,null,false,false));
        headerRow1.add(setCell('',null,null,false,false));        
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);
        
        BodyRow row = new BodyRow();
        List<BodyCell> bodyRow  = new List<BodyCell>();
        for (PricingTable__c priceObj : transformerStoragePanelHighVoltageList) {
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                //QuantityObject quantityObject = getQuantityObject(priceObj,detailMap);
                bodyRow.add(setCell(priceObj.Name3__c,null,null,false,false));//容量
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格
                bodyRow.add(setCell(priceObj.Name4__c,null,null,false,false));//価格表.名称4
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }   
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }
        
        //タイトルの設定
        transformerStoragePanelHighVoltageTable.secTitle = '変圧器収納盤(高圧)　(FFの場合は×0.8とすること)';//タイトル
        transformerStoragePanelHighVoltageTable.headerList = headerList;//ヘッダ
        transformerStoragePanelHighVoltageTable.bodyList = bodyList;//ボディー
        //transformerStoragePanelHighVoltageTable.isHasDetail = isHasDetail;
        //transformerStoragePanelHighVoltageTable.recMap = recMap;
        transformerStoragePanelHighVoltageTable.displayConditionMap = displayConditionMap;
        return transformerStoragePanelHighVoltageTable;
    }

    //変圧器収納盤(低圧)　(FFの場合は×0.8とすること) 一覧表示内容の設定
    private static CustomTable setTransformerStoragePanelLowVoltage(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap, String searchOption){
        CustomTable transformerStoragePanelLowVoltageTable = new CustomTable();
        List<PricingTable__c> transformerStoragePanelLowVoltageList = new List<PricingTable__c>();
        Map<Id, Map<String,Object>> displayConditionMap = new Map<Id, Map<String,Object>>();

        for (PricingTable__c item : priceList) {
            Map<String,Object> conditionMap = new Map<String,Object>();
            if(item.MajorClassificationName__c == '変圧器' &&
                item.MinorClassificationName__c == '変圧器収納盤' &&
                item.RecordType.DeveloperName == 'Chassis' &&
                item.Name1__c == '変圧器収納盤(低圧)' &&
                item.Name2__c == searchOption
            ) { 
                transformerStoragePanelLowVoltageList.add(item);
                String conditionName = (item.Name1__c==null?'':item.Name1__c)
                                    +(item.Name2__c==null?'':' '+item.Name2__c)
                                    +(item.Name3__c==null?'':' '+item.Name3__c)
                                    +(item.Name4__c==null?'':' '+item.Name4__c);
                conditionMap.put('condition', conditionName);
                conditionMap.put('price', (item.Price__c==null?0:item.Price__c));
                displayConditionMap.put(item.Id, conditionMap);
            }else if(item.MajorClassificationName__c == '変圧器' &&
                    item.MinorClassificationName__c == '変圧器収納盤' &&
                    item.RecordType.DeveloperName == 'Chassis' &&
                    item.Name1__c == '変圧器収納盤(低圧)' &&
                    (item.Name2__c == '屋内' || item.Name2__c == '屋外' || item.Name2__c == '屋内FF' || item.Name2__c == '屋内FF')
            ){
                String conditionName = (item.Name1__c==null?'':item.Name1__c)
                                    +(item.Name2__c==null?'':' '+item.Name2__c)
                                    +(item.Name3__c==null?'':' '+item.Name3__c)
                                    +(item.Name4__c==null?'':' '+item.Name4__c);
                conditionMap.put('condition', conditionName);
                conditionMap.put('price', (item.Price__c==null?0:item.Price__c));
                displayConditionMap.put(item.Id, conditionMap);
            }
        }

        //登録したレコードを確認する
        // Boolean isHasDetail = false;
        // Map<String, Object> recMap = new Map<String, Object>();
        // for(Id recId : displayConditionMap.keySet()){
        //     if (detailMap.get(recId)!=null) {
        //         isHasDetail = true;
        //         recMap.put('Id', recId);
        //         recMap.put('Price', displayConditionMap.get(recId).get('price'));
        //         recMap.put('Quantity', detailMap.get(recId).Quantity__c);
        //         break;
        //     }            
        // }    

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('変圧器容量',null,null,false,false));
        headerRow1.add(setCell('価  格',null,null,false,false));
        headerRow1.add(setCell('標準盤外形寸法',null,null,false,false));
        headerRow1.add(setCell('',null,null,false,false));        
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);
        
        BodyRow row = new BodyRow();
        List<BodyCell> bodyRow  = new List<BodyCell>();
        for (PricingTable__c priceObj : transformerStoragePanelLowVoltageList) {
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                //QuantityObject quantityObject = getQuantityObject(priceObj,detailMap);
                bodyRow.add(setCell(priceObj.Name3__c,null,null,false,false));//容量
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格
                bodyRow.add(setCell(priceObj.Name4__c,null,null,false,false));//価格表.名称4
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                
                Map<String,String> conditionMap = new Map<String,String>();
                String conditionName = (priceObj.Name1__c==null?'':priceObj.Name1__c)
                                    +(priceObj.Name2__c==null?'':' '+priceObj.Name2__c)
                                    +(priceObj.Name3__c==null?'':' '+priceObj.Name3__c)
                                    +(priceObj.Name4__c==null?'':' '+priceObj.Name4__c);
                conditionMap.put('condition', conditionName);
                conditionMap.put('price', price.format());
                displayConditionMap.put(priceObj.Id, conditionMap);
            }
            
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }
        //注＊　の設定
        List<String> noteList = new List<String>();
        noteList.add('注1)屋外盤は屋内盤+30%');
        noteList.add('注2)FFの場合は×0.8とすること');
        noteList.add('注3)2次側にブレーカーが入る場合、盤外形寸法を優先');
        
        //タイトルの設定
        transformerStoragePanelLowVoltageTable.secTitle = '変圧器収納盤(低圧)　(FFの場合は×0.8とすること)';//タイトル
        transformerStoragePanelLowVoltageTable.headerList = headerList;//ヘッダ
        transformerStoragePanelLowVoltageTable.bodyList = bodyList;//ボディー
        transformerStoragePanelLowVoltageTable.noteList = noteList;//注＊
        //transformerStoragePanelLowVoltageTable.isHasDetail = isHasDetail;
        //transformerStoragePanelLowVoltageTable.recMap = recMap;
        transformerStoragePanelLowVoltageTable.displayConditionMap = displayConditionMap;
        return transformerStoragePanelLowVoltageTable;
    }

    //接地トランス(GTR) (3相､6600/190V､50/60Hz,モールド) 一覧表示内容の設定
    private static CustomTable setGroundTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable groundTransformerTable = new CustomTable();
        List<PricingTable__c> groundTransformerList = new List<PricingTable__c>();
        Map<String,Set<String>> groundTransformerTableName3 = new Map<String,Set<String>>();//名称3+名称4

        for (PricingTable__c item : priceList) {
            if(item.MajorClassificationName__c == '共通機器' &&
                item.RecordType.DeveloperName == 'Detail' && (
                    (item.Name1__c == '接地トランス' &&
                        item.Name2__c == 'GTR')
                )
            ) { 
                groundTransformerList.add(item);
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('容量（ｋVA）',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        BodyRow row = new BodyRow();
        List<BodyCell> bodyRow  = new List<BodyCell>();
        for (PricingTable__c priceObj : groundTransformerList) {
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(priceObj.Name3__c,null,null,false,false));//容量（ｋVA)
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//数量
            }    
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }


        //タイトルの設定
        groundTransformerTable.secTitle = '接地トランス(GTR) (3相､6600/190V､50/60Hz,モールド)';//タイトル
        groundTransformerTable.headerList = headerList;//ヘッダ
        groundTransformerTable.bodyList = bodyList;//ボディー
        return groundTransformerTable;
    }

    //中性点付接地トランス(NGR) (3相､6600/190V､50/60Hz,モールド) 一覧表示内容の設定
    private static CustomTable setGroundTransformerWithNeutralPointTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable groundTransformerWithNeutralPointTable = new CustomTable();
        List<PricingTable__c> groundTransformerWithNeutralPointList = new List<PricingTable__c>();

        for (PricingTable__c item : priceList) {
            if(item.MajorClassificationName__c == '共通機器' &&
                item.RecordType.DeveloperName == 'Detail' && (
                    (item.Name1__c == '中性点付接地トランス' &&
                        item.Name2__c == 'NGR')
                )
            ) { 
                groundTransformerWithNeutralPointList.add(item);
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('容量（ｋVA）',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        BodyRow row = new BodyRow();
        List<BodyCell> bodyRow  = new List<BodyCell>();
        for (PricingTable__c priceObj : groundTransformerWithNeutralPointList) {
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(priceObj.Name3__c,null,null,false,false));//容量（ｋVA)
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//数量
            }
               
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        //タイトルの設定
        groundTransformerWithNeutralPointTable.secTitle = '中性点付接地トランス(NGR) (3相､6600/190V､50/60Hz,モールド)';//タイトル
        groundTransformerWithNeutralPointTable.headerList = headerList;//ヘッダ
        groundTransformerWithNeutralPointTable.bodyList = bodyList;//ボディー
        return groundTransformerWithNeutralPointTable;
    }

    //照明用・建築付帯用トランス(単相3線､400,200/100V) 一覧表示内容の設定
    private static CustomTable setTransformersLightingAndBuildingTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable transformersLightingAndBuildingTable = new CustomTable();
        Set<String> name4Set = new Set<String>();//名称4
        Map<String,Set<String>> transformersLightingAndBuildingTableName3 = new Map<String,Set<String>>();//名称3+名称4
        Map<String, PricingTable__c> transformersLightingAndBuildingTableMap = new Map<String, PricingTable__c>();//照明用・建築付帯用トランス(単相3線､400,200/100V) 情報

        for (PricingTable__c item : priceList) {
            if(item.MajorClassificationName__c == '共通機器' &&
                item.RecordType.DeveloperName == 'Detail' &&
                item.Name1__c == '照明用・建築付帯用トランス'
            ) { 
                String key = item.Name3__c + '@@' + item.Name4__c;//キー
                name4Set.add(item.Name4__c);
                Set<String> name4Values=transformersLightingAndBuildingTableName3.get(item.Name3__c);
                if (name4Values==null) {
                    name4Values = new Set<String>();
                    transformersLightingAndBuildingTableName3.put(item.Name3__c,name4Values);
                }
                name4Values.add(item.Name4__c);
                transformersLightingAndBuildingTableMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow1.add(setCell('容量',null,2,false,false));
        for (String name4 : name4Set) {
            headerRow1.add(setCell(name4,2,null,false,false));
            headerRow2.add(setCell('価格',null,null,false,true));
            headerRow2.add(setCell('数量',null,null,false,true));
        }
        BodyRow row1 = new BodyRow();
        BodyRow row2 = new BodyRow();
        row1.cellList=headerRow1;
        row2.cellList=headerRow2;
        headerList.add(row1);
        headerList.add(row2);
        
        BodyRow row = new BodyRow();
        List<BodyCell> bodyRow  = new List<BodyCell>();
        for (String name3 : transformersLightingAndBuildingTableName3.keyset()) {
            bodyRow.add(setCell(name3,null,null,false,false));//容量
            Set<String> name4List=transformersLightingAndBuildingTableName3.get(name3);
            for(String name4 : name4Set){
                PricingTable__c priceObj = transformersLightingAndBuildingTableMap.get(name3 + '@@' + name4);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                }
            }            
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }
        //タイトルの設定
        transformersLightingAndBuildingTable.secTitle = '照明用・建築付帯用トランス(単相3線､400,200/100V)';//タイトル
        transformersLightingAndBuildingTable.headerList = headerList;//ヘッダ
        transformersLightingAndBuildingTable.bodyList = bodyList;//ボディー
        return transformersLightingAndBuildingTable;
    }

    //耐雷トランス 一覧表示内容の設定
    private static CustomTable setThunderResistantTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable thunderResistantTable = new CustomTable();
        Set<String> name4Set = new Set<String>();//名称4
        Map<String,Set<String>> thunderResistantTableName3 = new Map<String,Set<String>>();//名称3+名称4
        Map<String, PricingTable__c> thunderResistantTableMap = new Map<String, PricingTable__c>();//耐雷トランス 情報

        for (PricingTable__c item : priceList) {
            if(item.MajorClassificationName__c == '共通機器' &&
                item.RecordType.DeveloperName == 'Detail' &&
                item.Name1__c == '耐雷トランス'
            ) { 
                String key = item.Name3__c + '@@' + item.Name4__c;//キー
                name4Set.add(item.Name4__c);
                Set<String> name4Values=thunderResistantTableName3.get(item.Name3__c);
                if (name4Values==null) {
                    name4Values = new Set<String>();
                    thunderResistantTableName3.put(item.Name3__c,name4Values);
                }
                name4Values.add(item.Name4__c);
                thunderResistantTableMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow1.add(setCell('容量',null,2,false,false));
        for (String name4 : name4Set) {
            headerRow1.add(setCell(name4,2,null,false,false));
            headerRow2.add(setCell('価格',null,null,false,true));
            headerRow2.add(setCell('数量',null,null,false,true));
        }
        BodyRow row1 = new BodyRow();
        BodyRow row2 = new BodyRow();
        row1.cellList=headerRow1;
        row2.cellList=headerRow2;
        headerList.add(row1);
        headerList.add(row2);
        
        BodyRow row = new BodyRow();
        List<BodyCell> bodyRow  = new List<BodyCell>();
        for (String name3 : thunderResistantTableName3.keyset()) {
            bodyRow.add(setCell(name3,null,null,false,false));//容量
            Set<String> name4List=thunderResistantTableName3.get(name3);
            for(String name4 : name4Set){
                PricingTable__c priceObj = thunderResistantTableMap.get(name3 + '@@' + name4);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                }
            }            
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }
        //タイトルの設定
        thunderResistantTable.secTitle = '耐雷TR';//タイトル
        thunderResistantTable.headerList = headerList;//ヘッダ
        thunderResistantTable.bodyList = bodyList;//ボディー
        return thunderResistantTable;
    }

    //高圧盤内照明・電源用トランス(単相2線､6600/105V,モールド) 一覧表示内容の設定
    private static CustomTable setTransformerHighVoltagePowerReceivingTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){        
        CustomTable transformerHighVoltagePowerReceivingTable = new CustomTable();
        List<PricingTable__c> transformerHighVoltagePowerReceivingList = new List<PricingTable__c>();
        Set<String> name4Set = new Set<String>();//名称4

        for (PricingTable__c item : priceList) {
            if(item.MajorClassificationName__c == '共通機器' &&
                item.RecordType.DeveloperName == 'Detail' &&
                item.Name1__c == '高圧盤内照明・電源用トランス'
            ) { 
                transformerHighVoltagePowerReceivingList.add(item);
                name4Set.add(item.Name4__c);
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow1.add(setCell('容量',null,2,false,false));
        for (String name4 : name4Set) {
            headerRow1.add(setCell(name4,2,null,false,false));
            headerRow2.add(setCell('価格',null,null,false,true));
            headerRow2.add(setCell('数量',null,null,false,true));
        }
        BodyRow row1 = new BodyRow();
        BodyRow row2 = new BodyRow();
        row1.cellList=headerRow1;
        row2.cellList=headerRow2;
        headerList.add(row1);
        headerList.add(row2);
        
        BodyRow row = new BodyRow();
        List<BodyCell> bodyRow  = new List<BodyCell>();
        for (PricingTable__c priceObj : transformerHighVoltagePowerReceivingList) {
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(priceObj.Name3__c,null,null,false,false));//容量
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格 
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//数量
            }     
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }
        
        //タイトルの設定
        transformerHighVoltagePowerReceivingTable.secTitle = '高圧受電用操作トランス(単相2線､6600/105V,モールド)';//タイトル
        transformerHighVoltagePowerReceivingTable.headerList = headerList;//ヘッダ
        transformerHighVoltagePowerReceivingTable.bodyList = bodyList;//ボディー
        return transformerHighVoltagePowerReceivingTable;
    }

    //入力セルを設定
    private static QuantityObject getQuantityObject(PricingTable__c priceObj, Map<Id, Detail__c> detailMap){
        QuantityObject quantityObject = new QuantityObject();
        quantityObject.Id = priceObj.Id;
        quantityObject.Price = priceObj.Price__c;
        // quantityObject.Option = null;
        Detail__c detail = detailMap.get(priceObj.Id);
        if (detail!=null) {
            quantityObject.Quantity = detail.Quantity__c;
        } else {
            quantityObject.Quantity = null;
        }

        return quantityObject;
    }

    private static BodyCell setCell(Object value, Integer colSpanCnt, Integer rowSpanCnt, Boolean isEdit, Boolean isRight){
        BodyCell cell = new BodyCell();
        cell.isEdit=isEdit;
        cell.value = value;
        cell.isRight = isRight;
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