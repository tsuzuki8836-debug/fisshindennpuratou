public with sharing class DetailsInputControllerForHighVoltage {

    public static final List<String> SEARCH_OPTIONS = new List<String>{'屋内','屋外','屋内FF','屋外FF'};

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
    //内訳入力B_高圧受配電盤
    public class HighVoltageScreenInfo {
        CustomTable boxTable {get;set;}
        CustomTable vcBreakerTable {get;set;}
        CustomTable disconnectorTable {get;set;}
        CustomTable gasLoadSwitchTable {get;set;}
        CustomTable fuseLoadSwitchTable {get;set;}
        CustomTable airLoadSwitchTable {get;set;}
        CustomTable instrumentBoxTable {get;set;}
        CustomTable zeroPhaseCurrentTransformerTable{get;set;}
        CustomTable lightningArresterTable{get;set;}
        CustomTable instrumentTransformerTable{get;set;}
        CustomTable zeroPhaseTransformerTable{get;set;}
        CustomTable groundedInstrumentTransformerTable{get;set;}
        CustomMultiHeaderTable currentTransformerTable{get;set;}
        CustomTable loadSwitchsTable{get;set;}
        CustomTable transformerStorageBoardTable{get;set;}
        CustomTable networkRelayMulticapTable{get;set;}
        CustomTable networkVTTable{get;set;}
        CustomTable networkCTTable{get;set;}
        CustomTable compositeCTHighAndLowTable{get;set;}
        CustomTable protectorFuseTable{get;set;}
        CustomTable takeOffFuseTable{get;set;}
        CustomTable meterTableTable{get;set;}
        CustomTable transducerTable{get;set;}
        CustomTable MELPRODSeriesTable{get;set;}
        CustomTable mp11MultiRelayTable{get;set;}
        String searchOption{get;set;}
    }

    //一覧に表示する情報
    public class CustomTable {
        Public String secTitle{get;set;}//タイトル
        Public String comment{get;set;}//一覧右上のコメント
        public List<BodyRow> bodyList {get;set;}//表示内容
        public List<BodyRow> headerList {get;set;}//一覧ヘッダ情報
        Public List<String> noteList {get;set;}//一覧下の「注※」内容
    }

    //一覧に表示する情報
    public class CustomMultiHeaderTable {
        Public String secTitle{get;set;}//タイトル
        Public String comment{get;set;}//一覧右上のコメント
        public List<Map<String, List<BodyRow>>> multiTable {get;set;}
        Public List<String> noteList {get;set;}//一覧下の「注※」内容
    }

    @AuraEnabled
    /**
     * 機器に対して　既に登録済みの内訳情報を取得
     * 
     *  @param deviceId 機器Id
     */
    Public static String getAllPriceFor1InputOnly() {
        Map<Id, String> combinationTable_Map = new Map<Id, String>();
        Map<Id, PricingTable__c> priceMap = new Map<Id, PricingTable__c>([SELECT Id,
                                                                                UniqueKey__c,
                                                                                Name,
                                                                                Name1__c,
                                                                                Name2__c,
                                                                                Name4__c,
                                                                                RecordType.DeveloperName,
                                                                                MajorClassificationName__c,//大分類
                                                                                MinorClassificationName__c, //小分類
                                                                                Price__c //単価
                                                                            FROM PricingTable__c
                                                                            WHERE (
                                                                                MajorClassificationName__c = '高圧受配電盤'
                                                                                AND RecordType.DeveloperName = 'Detail'
                                                                                AND (
                                                                                    Name1__c = '断路器(DS)'
                                                                                    OR Name1__c = '真空遮断器(VCB)'
                                                                                )
                                                                            )
                                                                            ORDER BY RECNO__c
                                                                        ]);
        for(Id priceKey : priceMap.keySet()){
            PricingTable__c price = priceMap.get(priceKey);
            if(price.MajorClassificationName__c=='高圧受配電盤' && price.RecordType.DeveloperName=='Detail' && (price.Name1__c == '断路器(DS)' || price.Name1__c == '真空遮断器(VCB)')) {
                combinationTable_Map.put(price.Id, price.Name1__c == '断路器(DS)' ? 'DS@@'+price.Name2__c.remove('以下'):'VCB@@'+price.Name4__c.remove('定格電流:'));
            }
        }

        return JSON.serialize(new Map<String, Object>{
            'combinationTable'=>combinationTable_Map
        });
    }

    @AuraEnabled
    /*
     *内訳入力B_高圧受配電盤  保存ボタン　処理
     */
    public static string submitHighVoltageDetails(String details,String deviceId){

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

            Device__c device = [ SELECT Id, Quote__c,(SELECT Id FROM Details__r WHERE PricingTableUniqueKey__c like '%高圧受配電盤%' OR PricingTableUniqueKey__c like '%共通機器%') FROM Device__c WHERE Id =:deviceId LIMIT 1];

            //既存情報を削除
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
                                                                            Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c, Name7__c, Name8__c, Name9__c,  Name10__c, 
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

                            detailList.add(detail); 
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
    /*
     *内訳入力B_高圧受配電盤  画面情報を取得
     */
    public static string getHighVoltageScreenInfo(Boolean init,
                                                    String deviceId,
                                                    String searchOption,
                                                    String inputsRecords){
        HighVoltageScreenInfo screenInfo = new HighVoltageScreenInfo();

        Device__c device = [SELECT Id
                                ,Name
                                ,Quote__r.RecordType.Name
                                ,(SELECT Id
                                    ,Name
                                    ,Name1__c
                                    ,Name2__c
                                    ,DetailCategory__c
                                FROM Details__r
                                WHERE DetailCategory__c='筐体' AND MajorClassificationName__c='高圧受配電盤' LIMIT 1)
                            FROM Device__c
                            WHERE Id =: deviceId LIMIT 1];
        String bu = device.Quote__r.RecordType.Name == '施設' ? 'S' : 'M';

        if(init&&device.Details__r.size()>0) {
            searchOption = SEARCH_OPTIONS.contains(device.Details__r.get(0).Name2__c) ? device.Details__r.get(0).Name2__c: searchOption;
            searchOption = SEARCH_OPTIONS.contains(device.Details__r.get(0).Name1__c) ? device.Details__r.get(0).Name1__c: searchOption;
        }
        
        screenInfo.searchOption = searchOption;

        List<PricingTable__c> priceList = [SELECT Id,UniqueKey__c, Name, RecordType.DeveloperName,
                                            MajorClassificationName__c,//大分類
                                            MinorClassificationName__c, //小分類
                                            CategoryName__c,//種類名
                                            DisplayName__c,//表示用テキスト
                                            Name1__c, //名称1
                                            Name2__c, //名称2
                                            Name3__c, //名称3
                                            Name4__c, //名称4
                                            Name5__c, //名称5
                                            Name6__c, //名称6
                                            Name7__c, //名称7
                                            Name8__c, //名称8
                                            Name9__c, //名称9
                                            Name10__c, //名称10
                                            WC__c, //WC
                                            Price__c, //単価
                                            //Weight__c,
                                            Note__c
                                        FROM PricingTable__c
                                        WHERE BU__c=:bu
                                            AND ((MajorClassificationName__c = '高圧受配電盤'
                                                AND ((RecordType.DeveloperName = 'Chassis' 
                                                        AND (CategoryName__c IN ('筐体',''))
                                                        AND ( Name1__c = :searchOption)
                                                    )
                                                    OR (RecordType.DeveloperName = 'Detail' 
                                                        AND Name1__C IN ('断路器(DS)'
                                                                        ,'真空遮断器(VCB)'
                                                                        ,'屋外用高圧交流ガス負荷開閉器'
                                                                        ,'気中負荷開閉器(PAS)'
                                                                        ,'取引用計器箱(日東工業)'
                                                                        ,'避雷器(LA)'
                                                                        ,'計器用変圧器(VT､PT)ヒューズ付'
                                                                        ,'零相変成器(ZPC､ZPD)'
                                                                        ,'接地形計器用変圧器ヒューズ付'
                                                                        ,'負荷開閉器類'
                                                                        ,'ネットワークリレー'
                                                                        ,'ネットワークVT'
                                                                        ,'ネットワークCT'
                                                                        ,'合成CT(高圧/低圧)'
                                                                        ,''
                                                        )
                                                    )
                                                )
                                            )
                                            OR (MajorClassificationName__c = '共通機器'
                                                AND ((RecordType.DeveloperName = 'Chassis' 
                                                        AND CategoryName__c='筐体' 
                                                        AND Name1__c = :searchOption)
                                                    OR (RecordType.DeveloperName = 'Detail' 
                                                        AND (Name1__C IN ('ヒューズ付負荷開閉器'
                                                                        ,'変換器(トランスデューサ:T/D)'
                                                                        ,'MELPRO-Dシリーズ'
                                                                        ,'MP11A(マルチリレー)'

                                                                        ,'零相変流器(ZCT):高圧'
                                                                        ,'プロテクタヒューズ'
                                                                        ,'テイクオフヒューズ'
                                                        ) OR Name10__C IN ('計器・保護継電器・変換器'
                                                                        ,'計器用変流器(CT):高圧'
                                                        ))
                                                    )
                                                )
                                            )
                                            OR (MajorClassificationName__c = '変圧器'
                                                AND MinorClassificationName__c = '変圧器収納盤'
                                                AND RecordType.DeveloperName = 'Chassis' 
                                                AND Name2__c = :searchOption
                                            )
                                        )
                                        ORDER BY RECNO__c
                                    ];

        //画面入力された情報
        List<Object> inputsRecordsList;
        Map<Id, Detail__c> detailMap = DetailController.getDetailRecordsByDeviceId(deviceId);
        System.debug('取得明細：' + detailMap);
        Map<Id, Detail__c> chassisMap = getChassisRecordsByDeviceId(deviceId);

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

        if (String.isNotBlank(inputsRecords)) {
            inputsRecordsList = (List<Object>)JSON.deserializeUntyped(inputsRecords);
            //全件処理
            for (Object o : inputsRecordsList) {
                Map<String,Object> record = (Map<String,Object>)o;
                String id = (String)record.get('Id');
                String cnt = String.valueof(record.get('Quantity'));
                Detail__c tmp = chassisMap.get((Id)id);
                if (tmp==null) {
                    tmp = new Detail__c() ;
                    chassisMap.put((Id)id, tmp);//数量が入力されたものは　表示対象
                }
                tmp.Quantity__c=(String.isNotBlank(cnt)?Decimal.valueof(cnt):null);
            }
        }

        //筐体(高圧受配電盤)
        CustomTable boxTable = setBoxTable(priceList, chassisMap, searchOption);
        screenInfo.boxTable = boxTable;//筐体(高圧受配電盤)

        //断路器(DS)
        CustomTable disconnectorTable = setDisconnectorTable(priceList, detailMap);
        screenInfo.disconnectorTable = disconnectorTable;//断路器(DS)

        //真空遮断器(VCB)
        CustomTable vcBreakerTable = setVcBreakerTable(priceList, detailMap);
        screenInfo.vcBreakerTable = vcBreakerTable;//真空遮断器(VCB)

        //屋外用高圧交流ガス負荷開閉器
        CustomTable gasLoadSwitchTable = setGasLoadSwitchTable(priceList, detailMap);
        screenInfo.gasLoadSwitchTable = gasLoadSwitchTable;//屋外用高圧交流ガス負荷開閉器

        //ヒューズ付負荷開閉器(LBS)
        CustomTable fuseLoadSwitchTable = setFuseLoadSwitchTable(priceList, detailMap);
        screenInfo.fuseLoadSwitchTable = fuseLoadSwitchTable;//ヒューズ付負荷開閉器(LBS)
        
        //気中負荷開閉器(PAS)
        CustomTable airLoadSwitchTable = setAirLoadSwitchTable(priceList, detailMap);
        screenInfo.airLoadSwitchTable = airLoadSwitchTable;//気中負荷開閉器(PAS)

        //取引用計器箱(日東工業)
        CustomTable instrumentBoxTable = setInstrumentBoxTable(priceList, detailMap);
        screenInfo.instrumentBoxTable = instrumentBoxTable;//取引用計器箱(日東工業)

        //零相変流器(ZCT):高圧
        CustomTable zeroPhaseCurrentTransformerTable = setZeroPhaseCurrentTransformerTable(priceList, detailMap);
        screenInfo.zeroPhaseCurrentTransformerTable = zeroPhaseCurrentTransformerTable;//零相変流器(ZCT):高圧

        //避雷器(LA)
        CustomTable lightningArresterTable = setLightningArresterTable(priceList, detailMap);
        screenInfo.lightningArresterTable = lightningArresterTable;//避雷器(LA)

        //計器用変圧器(VT、PT)ヒューズ付
        CustomTable instrumentTransformerTable = setInstrumentTransformerTable(priceList, detailMap);
        screenInfo.instrumentTransformerTable = instrumentTransformerTable;//計器用変圧器(VT、PT)ヒューズ付

        //零相変成器(ZPC、ZPD)
        CustomTable zeroPhaseTransformerTable = setZeroPhaseTransformerTable(priceList, detailMap);
        screenInfo.zeroPhaseTransformerTable = zeroPhaseTransformerTable;//零相変成器(ZPC、ZPD)


        //接地形計器用変圧器ﾋｭｰｽﾞ付(ZPT・GPT）
        CustomTable groundedInstrumentTransformerTable = setGroundedInstrumentTransformerTable(priceList, detailMap);
        screenInfo.groundedInstrumentTransformerTable = groundedInstrumentTransformerTable;//接地形計器用変圧器ﾋｭｰｽﾞ付(ZPT・GPT）

        //計器用変流器(CT):高圧
        CustomMultiHeaderTable currentTransformerTable = setCurrentTransformerTable(priceList, detailMap);
        screenInfo.currentTransformerTable = currentTransformerTable;//計器用変流器(CT):高圧

        //負荷開閉器類LBS(LDS)
        CustomTable loadSwitchsTable = setLoadSwitchsTable(priceList, detailMap);
        screenInfo.loadSwitchsTable = loadSwitchsTable;//負荷開閉器類LBS(LDS)

        //変圧器収納盤(高圧)
        CustomTable transformerStorageBoardTable = setTransformerStorageBoardTable(priceList, detailMap, searchOption);
        screenInfo.transformerStorageBoardTable = transformerStorageBoardTable;//変圧器収納盤(高圧)

        // ＳＮＷ関連機器

        //ネットワークリレー
        CustomTable networkRelayMulticapTable = setNetworkRelayMulticapTable(priceList, detailMap);
        screenInfo.networkRelayMulticapTable = networkRelayMulticapTable;//ネットワークリレー

        //ネットワークVT
        CustomTable networkVTTable = setNetworkVTTable(priceList, detailMap);
        screenInfo.networkVTTable = networkVTTable;//ネットワークVT

        //ネットワークCT
        CustomTable networkCTTable = setNetworkCTTable(priceList, detailMap);
        screenInfo.networkCTTable = networkCTTable;//ネットワークCT

        //合成CT(高圧/低圧)
        CustomTable compositeCTHighAndLowTable = setCompositeCTHighAndLowTable(priceList, detailMap);
        screenInfo.compositeCTHighAndLowTable = compositeCTHighAndLowTable;//合成CT(高圧/低圧)

        //プロテクタヒューズ
        CustomTable protectorFuseTable = setProtectorFuseTable(priceList, detailMap);
        screenInfo.protectorFuseTable = protectorFuseTable;//プロテクタヒューズ

        //テイクオフヒューズ
        CustomTable takeOffFuseTable = setTakeOffFuseTable(priceList, detailMap);
        screenInfo.takeOffFuseTable = takeOffFuseTable;//テイクオフヒューズ

        //計器・保護継電器・変換器
        CustomTable meterTableTable = setMeterTableTable(priceList, detailMap);
        screenInfo.meterTableTable = meterTableTable;//計器・保護継電器・変換器

        //変換器(ﾄﾗﾝｽﾃﾞｭｰｻｰ:T/D)
        CustomTable transducerTable = setTransducerTable(priceList, detailMap);
        screenInfo.transducerTable = transducerTable;//変換器(ﾄﾗﾝｽﾃﾞｭｰｻｰ:T/D)

        //MELPRO-Dシリーズ
        CustomTable MELPRODSeriesTable = setMELPRODSeriesTable(priceList, detailMap);
        screenInfo.MELPRODSeriesTable = MELPRODSeriesTable;//MELPRO-Dシリーズ

        //MP11A(マルチリレー)
        CustomTable mp11MultiRelayTable = setMp11MultiRelayTable(priceList, detailMap);
        screenInfo.mp11MultiRelayTable = mp11MultiRelayTable;//MP11A(マルチリレー)
        
        return  JSON.serialize(screenInfo);

    }

    //3) 筐体(高圧受配電盤) 一覧表示内容の設定
    private static CustomTable setBoxTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap, String searchOption){
        CustomTable boxTable = new CustomTable();
        Set<String> boxName2 = new Set<String>();//名称１
        Map<String,Set<String>> boxName3 = new Map<String,Set<String>>();//名称3＋名称4
        Map<String, PricingTable__c> boxInfoMap = new Map<String, PricingTable__c>();//筐体(高圧受配電盤) 情報
        Integer i = 0;
        for (PricingTable__c item : priceList) {
            if (item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Chassis' && item.Name1__c == searchOption){
                String key = item.Name2__c + '@@' + item.Name3__c + '@@' + item.Name4__c;//キー
                boxName2.add(item.Name2__c);
                Set<String> name4List = boxName3.get(item.Name3__c);

                if (name4List==null) {
                    name4List = new Set<String>();
                    boxName3.put(item.Name3__c, name4List);
                }
                name4List.add(item.Name4__c);
                boxInfoMap.put(key, item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //箱体 の場合　1行目
        // 用途 引込及び補助 遮断器収納    
        List<BodyCell> headerRow1 = new List<BodyCell>();            
        headerRow1.add(setCell('用途',null,null,false,false));
        //母線電流  MOF収納   数量  MOF無    数量  1台  数量  2台(2段積) 数量  3台(3段積) 数量  1台  数量
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow2.add(setCell('母線電流',null,null,false,false));

        //キー単位でヘッダを設定
        for (String name3 : boxName3.keyset()){
            Set<String> name4 = boxName3.get(name3);
            headerRow1.add(setCell(name3, name4.size() * 2,null,false,false));
            for (String val : name4) {
                headerRow2.add(setCell(val,null,null,false,false));
                headerRow2.add(setCell('数量',null,null,false,false));
            }
        }
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row1);
        headerList.add(row2);

        //Body の設定
        for(String name2 : boxName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2,1,1,false,false));//母線電流
            for (String name3 : boxName3.keyset()){
                Set<String> name4 = boxName3.get(name3);
                for (String val : name4) {
                    PricingTable__c priceObj = boxInfoMap.get(name2 +'@@' + name3 + '@@' +val);
                    if (priceObj!=null) {
                        Decimal price = (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                    }else {
                        bodyRow.add(setCell(null,null,null,false,true));//価格セル
                        bodyRow.add(setCell(null,null,null,false,true));//空白セル
                    }
                }
            }
            row.cellList = bodyRow;
            bodyList.add(row);
        }

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_HighVoltageDistributionBoard_Case.split('\r\n');

        //タイトルの設定
        boxTable.secTitle = '筐体(高圧受配電盤)';//タイトル
        boxTable.comment = '';//コメント
        boxTable.headerList = headerList;//ヘッダ
        boxTable.bodyList = bodyList;//ボディー
        boxTable.noteList = noteList;//注＊
        return boxTable;
    }

    //5) 断路器(DS) 一覧表示内容の設定
    private static CustomTable setDisconnectorTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable disconnectorTable = new CustomTable();
        Set<String> disconnectorName2 = new Set<String>();//名称2
        Map<String,Set<String>> disconnectorName3 = new Map<String,Set<String>>();//名称3＋名称4
        Map<String, PricingTable__c> disconnectorInfoMap = new Map<String, PricingTable__c>();//筐体(高圧受配電盤)情報
        for (PricingTable__c item : priceList) {
            if (item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c.contains('断路器(DS)')){
                String key = item.Name2__c + '@@' + item.Name3__c + '@@' + item.Name4__c;//キー
                disconnectorName2.add(item.Name2__c);
                Set<String> name4List = disconnectorName3.get(item.Name3__c);

                if (name4List==null) {
                    name4List = new Set<String>();
                    disconnectorName3.put(item.Name3__c, name4List);
                }
                name4List.add(item.Name4__c);
                disconnectorInfoMap.put(key, item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //箱体 の場合　1行目：
        // 仕様   三極単投(3P1T)  三極双投(3P2T)  単極単投(1P1T)          
        List<BodyCell> headerRow1 = new List<BodyCell>();            
        headerRow1.add(setCell('仕様',null,null,false,false));

        //箱体 の場合　２行目：
        // 定格電流 電動操作    数量  手動リンク＊  数量  電動操作    数量  手動リンク   数量  磁器碍子    数量  レンジ碍子   数量
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow2.add(setCell('定格電流',null,null,false,false));

        //キー単位でヘッダを設定
        for (String name3 : disconnectorName3.keyset()){
            Set<String> name4 = disconnectorName3.get(name3);
            headerRow1.add(setCell(name3, name4.size() * 2,null,false,false));
            for (String val : name4) {
                headerRow2.add(setCell(val,null,null,false,false));
                headerRow2.add(setCell('数量',null,null,false,false));
            }
        }
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row1);
        headerList.add(row2);

        //Body の設定
        for(String name2 : disconnectorName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2,null,null,false,false));//定格電流
            for (String name3 : disconnectorName3.keyset()){
                Set<String> name4 = disconnectorName3.get(name3);
                for (String val : name4) {
                    PricingTable__c priceObj = disconnectorInfoMap.get(name2 +'@@' + name3 + '@@' +val);
                    if (priceObj!=null) {
                        Decimal price = (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                    }else {
                        bodyRow.add(setCell(null,null,null,false,true));//価格セル
                        bodyRow.add(setCell(null,null,null,false,true));//空白
                    }
                }
            }
            row.cellList = bodyRow;
            bodyList.add(row);
        }
        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        disconnectorTable.secTitle = '断路器(DS)';//タイトル
        disconnectorTable.comment='＊通常は手動リンク';
        disconnectorTable.headerList = headerList;//ヘッダ
        disconnectorTable.bodyList = bodyList;//ボディー
        disconnectorTable.noteList = noteList;//注＊
        return disconnectorTable;
    }

    //6) 真空遮断器(VCB) 一覧表示内容の設定
    private static CustomTable setVcBreakerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable vcBreakerTable = new CustomTable();
        Map<String, Integer> vcBreakerName2 = new Map<String, Integer>();//名称2
        Map<String,Set<String>> vcBreakerName3 = new Map<String,Set<String>>();//名称3＋名称4
        Map<String, PricingTable__c> vcBreakerInfoMap = new Map<String, PricingTable__c>();//真空遮断器(VCB)情報

        Set<String> msName3Temp = new Set<String>();
        for (PricingTable__c item : priceList) {
            //仕様１が真空遮断器(VCB) 7.2/3.6kVのは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '真空遮断器(VCB)'){
                if(item.Name6__c == 'MS-S用') {
                    msName3Temp.add(item.Name3__c);
                    String name2Temp = item.Name2__c+'\n'+item.Name6__c;
                    String name3Temp = item.Name5__c;
                    String name4Temp = item.Name4__c+item.Name3__c;
                    String key = name2Temp +'@@' + name3Temp + '@@' + name4Temp;//キー

                    Integer num = vcBreakerName2.get(name2Temp);
                    if(num == null) {
                        num = 0;
                        vcBreakerName2.put(name2Temp, num);
                    }
                    vcBreakerName2.put(name2Temp, ++num);

                    Set<String> name4List = vcBreakerName3.get(name3Temp);
                    if (name4List==null) {
                        name4List = new Set<String>();
                        vcBreakerName3.put(name3Temp, name4List);
                    }
                    name4List.add(name4Temp);
                    vcBreakerInfoMap.put(key,item);//データをキーで格納
                } else {
                    String name2Temp = item.Name2__c;
                    String name5 = String.isBlank(item.Name5__c) ? '' : item.Name5__c;
                    String name3Temp = item.Name3__c + '\n' + name5;
                    String key = name2Temp +'@@' + name3Temp + '@@' + item.Name4__c;//キー

                    Integer num = vcBreakerName2.get(name2Temp);
                    if(num == null) {
                        num = 0;
                        vcBreakerName2.put(name2Temp, num);
                    }
                    vcBreakerName2.put(name2Temp, ++num);
        
                    Set<String> name4List = vcBreakerName3.get(name3Temp);
                    if (name4List==null) {
                        name4List = new Set<String>();
                        vcBreakerName3.put(name3Temp, name4List);
                    }
                    name4List.add(item.Name4__c);
                    vcBreakerInfoMap.put(key,item);//データをキーで格納
                }
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //電圧   遮断電流   定格電流   価格    数量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('電圧',null,null,false,false));
        headerRow1.add(setCell('遮断電流',null,null,false,false));
        headerRow1.add(setCell('定格電流',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2 : vcBreakerName2.keySet()){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2,null,vcBreakerName2.get(name2),false,false));//電圧セル
            for (String name3 : vcBreakerName3.keyset()){
                Boolean isFirst = true;
                Set<String> name4 = vcBreakerName3.get(name3);
                for (String val : name4) {
                    String key = name2 +'@@' + name3 + '@@' +val;
                    PricingTable__c priceObj = vcBreakerInfoMap.get(key);
                    if (priceObj!=null) {
                        if(isFirst) bodyRow.add(setCell((priceObj.Name6__c=='MS-S用'?String.join(new List<String>(msName3Temp),'\n'):'')+'\n'+name3,null,name4.size(),false,false));//遮断電流セル
                        isFirst = false;

                        Decimal price = (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(val.remove(priceObj.Name3__c),null,null,false,false));//価定格電流セル
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル

                        row.cellList = bodyRow;
                        bodyList.add(row);
                        row = new BodyRow();
                        bodyRow  = new List<BodyCell>();
                    }
                }
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        vcBreakerTable.secTitle = '真空遮断器(VCB)';//真空遮断器(VCB)　タイトル
        vcBreakerTable.comment = '';//コメント
        vcBreakerTable.headerList = headerList;//真空遮断器(VCB) ヘッダ
        vcBreakerTable.bodyList = bodyList;//真空遮断器(VCB) ボディー
        vcBreakerTable.noteList = noteList;//真空遮断器(VCB) 注＊
        return vcBreakerTable;
    }

    //7) 屋外用高圧交流ガス負荷開閉器 一覧表示内容の設定
    private static CustomTable setGasLoadSwitchTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable gasLoadSwitchTable = new CustomTable();
        Set<String> gasLoadSwitchName1 = new Set<String>();//名称１
        Set<String> gasLoadSwitchName2 = new Set<String>();//名称２
        Map<String, PricingTable__c> gasLoadSwitchInfoMap = new Map<String, PricingTable__c>();//真空遮断器(VCB)情報
        for (PricingTable__c item : priceList) {
            //仕様１が屋外用高圧交流ｶﾞｽ負荷開閉器のは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '屋外用高圧交流ガス負荷開閉器'){
                String key = item.Name1__c +'@@' + item.Name2__c;//キー
                gasLoadSwitchName1.add(item.Name1__c);
                gasLoadSwitchName2.add(item.Name2__c);
                gasLoadSwitchInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();//定格電流    価  格    数量
        headerRow1.add(setCell('定格電流',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name1 : gasLoadSwitchName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name2 : gasLoadSwitchName2) {
                PricingTable__c priceObj = gasLoadSwitchInfoMap.get(name1 +'@@' + name2);
                String name2Tmp = name2;
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2Tmp,null,null,false,true));//価定格電流
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        gasLoadSwitchTable.secTitle = '屋外用高圧交流ガス負荷開閉器';//タイトル
        gasLoadSwitchTable.comment = '';//コメント
        gasLoadSwitchTable.headerList = headerList;//ヘッダ
        gasLoadSwitchTable.bodyList = bodyList;//ボディー
        gasLoadSwitchTable.noteList = noteList;//注＊
        return gasLoadSwitchTable;
    }

    //8) ヒューズ付負荷開閉器(LBS) 一覧表示内容の設定
    private static CustomTable setFuseLoadSwitchTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable fuseLoadSwitchTable = new CustomTable();
        Set<String> fuseLoadSwitchName1 = new Set<String>();//名称1
        Set<String> fuseLoadSwitchName3 = new Set<String>();//名称3
        Set<String> fuseLoadSwitchName4 = new Set<String>();//名称4
        Map<String,Set<String>> fuseLoadSwitchName34 = new Map<String,Set<String>>();//名称3+名称4

        Map<String, PricingTable__c> fuseLoadSwitchInfoMap = new Map<String, PricingTable__c>();//真空遮断器(VCB)情報
        for (PricingTable__c item : priceList) {
            //仕様１がヒューズ付負荷開閉器のは　対象とする
            if(item.MajorClassificationName__c == '共通機器' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'ヒューズ付負荷開閉器'){ 
                String key = item.Name1__c +'@@' + item.Name3__c + '@@' + item.Name4__c;//キー
                fuseLoadSwitchName1.add(item.Name1__c);
                fuseLoadSwitchName3.add(item.Name3__c);
                fuseLoadSwitchName4.add(item.Name4__c);
                fuseLoadSwitchInfoMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //定格電流    価格    数量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('電 流',null,null,false,false));

        Boolean isFirst = true;
        //Body の設定
        for(String name1 : fuseLoadSwitchName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name3 : fuseLoadSwitchName3) {
                bodyRow.add(setCell(name3,null,null,false,false));//定格電流セル
                for(String name4 : fuseLoadSwitchName4){
                    PricingTable__c priceObj = fuseLoadSwitchInfoMap.get(name1 +'@@' + name3 + '@@' + name4);
                    if (isFirst) {
                        headerRow1.add(setCell(name4,null,null,false,false));//価格セル
                        headerRow1.add(setCell('数量',null,null,false,false));//入力セル
                    }
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                    }else {
                        bodyRow.add(setCell(null,null,null,false,true));//価格セル
                        bodyRow.add(setCell(null,null,null,false,true));//空白
                    }
                }
                
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
                isFirst = false;
            }
        }
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        fuseLoadSwitchTable.secTitle = 'ヒューズ付負荷開閉器(LBS)';//タイトル
        fuseLoadSwitchTable.comment = '';//コメント
        fuseLoadSwitchTable.headerList = headerList;//ヘッダ
        fuseLoadSwitchTable.bodyList = bodyList;//ボディー
        fuseLoadSwitchTable.noteList = noteList;//注＊
        return fuseLoadSwitchTable;
    }

    //9) 気中負荷開閉器(PAS) 一覧表示内容の設定
    private static CustomTable setAirLoadSwitchTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable airLoadSwitchTable = new CustomTable();
        Set<String> airLoadSwitchName1 = new Set<String>();//名称１
        Set<String> airLoadSwitchName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> airLoadSwitchInfoMap = new Map<String, PricingTable__c>();//気中負荷開閉器(PAS) 情報
        String commment = '';
        for(PricingTable__c item : priceList) {
            //仕様１が気中負荷開閉器(PAS)のは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '気中負荷開閉器(PAS)'){
                String key = item.Name1__c +'@@' + item.Name2__c;//キー
                airLoadSwitchName1.add(item.Name1__c);
                airLoadSwitchName2.add(item.Name2__c);
                commment = item.Name3__c;
                airLoadSwitchInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //定格電流    価  格    数量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('定格電流',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        Boolean isFirst = true;
        for(String name1 : airLoadSwitchName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name2 : airLoadSwitchName2) {
                PricingTable__c priceObj = airLoadSwitchInfoMap.get(name1 +'@@' + name2);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2,null,null,false,false));//定格電流セル
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                }
                isFirst = false;
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        airLoadSwitchTable.secTitle = '気中負荷開閉器(PAS)';//タイトル
        airLoadSwitchTable.comment = commment;
        airLoadSwitchTable.headerList = headerList;//ヘッダ
        airLoadSwitchTable.bodyList = bodyList;//ボディー
        airLoadSwitchTable.noteList = noteList;//注＊
        return airLoadSwitchTable;
    }

    //10) 取引用計器箱(日東工業) 一覧表示内容の設定
    private static CustomTable setInstrumentBoxTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable instrumentBoxTable = new CustomTable();
        Set<String> instrumentBoxName1 = new Set<String>();//名称1
        Map<String,Set<String>> instrumentBoxName2 = new Map<String,Set<String>>();//名称2＋名称3
        Map<String, PricingTable__c> instrumentBoxInfoMap = new Map<String, PricingTable__c>();//筐体(高圧受配電盤)情報
        for (PricingTable__c item : priceList) {
            if (item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '取引用計器箱(日東工業)'){
                String key = item.Name1__c + '@@' + item.Name2__c + '@@' + item.Name3__c;//キー
                instrumentBoxName1.add(item.Name1__c);
                Set<String> name3List = instrumentBoxName2.get(item.Name2__c);
                if (name3List==null) {
                    name3List = new Set<String>();
                    instrumentBoxName2.put(item.Name2__c, name3List);
                }
                name3List.add(item.Name3__c);
                instrumentBoxInfoMap.put(key, item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //箱体 の場合　仕様     価格  数量
        List<BodyCell> headerRow1 = new List<BodyCell>();            
        headerRow1.add(setCell('仕様',2,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));

        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name1 : instrumentBoxName1){
            for (String name2 : instrumentBoxName2.keyset()){
                BodyRow row = new BodyRow();
                List<BodyCell> bodyRow  = new List<BodyCell>();
                Set<String> name3 = instrumentBoxName2.get(name2);
                for (String val : name3) {
                    PricingTable__c priceObj = instrumentBoxInfoMap.get(name1 +'@@' + name2 + '@@' +val);
                    if (priceObj!=null) {
                        Decimal price = (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(name2,null,null,false,false));//箱体セル
                        bodyRow.add(setCell(val,null,null,false,false));//箱体セル
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                        row.cellList = bodyRow;
                        bodyList.add(row);
                    }
                }
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        instrumentBoxTable.secTitle = '取引用計器箱(日東工業)';//タイトル
        instrumentBoxTable.comment = '';//コメント
        instrumentBoxTable.headerList = headerList;//ヘッダ
        instrumentBoxTable.bodyList = bodyList;//ボディー
        instrumentBoxTable.noteList = noteList;//注＊
        return instrumentBoxTable;
    }

    //11)　零相変流器(ZCT):高圧 一覧表示内容の設定
    private static CustomTable setZeroPhaseCurrentTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable zeroPhaseCurrentTransformerTable = new CustomTable();
        Set<String> zeroPhaseCurrentTransformerName1 = new Set<String>();//名称１
        Set<String> zeroPhaseCurrentTransformerName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> zeroPhaseCurrentTransformerInfoMap = new Map<String, PricingTable__c>();//零相変流器(ZCT):高圧 情報
        for (PricingTable__c item : priceList) {
            //仕様１が零相変流器(ZCT):高圧のは　対象とする
            if(item.MajorClassificationName__c == '共通機器' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '零相変流器(ZCT):高圧'){
                String key = item.Name1__c +'@@' + item.Name2__c;//キー
                zeroPhaseCurrentTransformerName1.add(item.Name1__c);
                zeroPhaseCurrentTransformerName2.add(item.Name2__c);
                zeroPhaseCurrentTransformerInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();//過電流倍数 2,000 以上 数量
        headerRow1.add(setCell('過電流倍数',null,null,false,false));
        headerRow1.add(setCell('2,000 以上',null,null,false,false));
        headerRow1.add(setCell('数量',null,2,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        List<BodyCell> headerRow2 = new List<BodyCell>();//一次電流 価格
        headerRow2.add(setCell('一次電流',null,null,false,false));
        headerRow2.add(setCell('価格',null,null,false,false));
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row2);

        //Body の設定
        for(String name1 : zeroPhaseCurrentTransformerName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name2 : zeroPhaseCurrentTransformerName2) {
                PricingTable__c priceObj = zeroPhaseCurrentTransformerInfoMap.get(name1 +'@@' + name2);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2,null,null,false,false));//過電流倍数セル
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        zeroPhaseCurrentTransformerTable.secTitle = '零相変流器(ZCT):高圧';//タイトル
        zeroPhaseCurrentTransformerTable.comment = '';//コメント
        zeroPhaseCurrentTransformerTable.headerList = headerList;//ヘッダ
        zeroPhaseCurrentTransformerTable.bodyList = bodyList;//ボディー
        zeroPhaseCurrentTransformerTable.noteList = noteList;//注＊
        return zeroPhaseCurrentTransformerTable;
    }

    //13) 避雷器(LA) 一覧表示内容の設定
    private static CustomTable setLightningArresterTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable lightningArresterTable = new CustomTable();
        Set<String> lightningArresterName2 = new Set<String>();//名称１
        Map<String,Set<String>> lightningArresterName3 = new Map<String,Set<String>>();//名称2+名称3
        Set<String> lightningArresterName4 = new Set<String>();//名称4
        Map<String, PricingTable__c> lightningArresterInfoMap = new Map<String, PricingTable__c>();//避雷器(LA)情報
        for (PricingTable__c item : priceList) {
            //仕様１が避雷器(LA)含むのは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '避雷器(LA)'
                && item.Name4__c != '引出装置' //設計書にないですが、Masterにあります。
            ){
                lightningArresterName2.add(item.Name2__c);
                String key = item.Name2__c +'@@' + item.Name3__c + '@@' + item.name4__c;//キー
                Set<String> name4List=lightningArresterName3.get(item.Name3__c);
                if (name4List==null) {
                    name4List = new Set<String>();
                    lightningArresterName3.put(item.Name3__c,name4List);
                }
                name4List.add(item.name4__c);

                lightningArresterName4.add(item.Name4__c);

                lightningArresterInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //電圧 放電電流 本体 数量 引出有 数量     
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('電圧',null,null,false,false));
        headerRow1.add(setCell('放電電流',null,null,false,false));
        for (String name4 : lightningArresterName4) {
            headerRow1.add(setCell(name4,null,null,false,false));
            headerRow1.add(setCell('数量',null,null,false,false));
        }
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1); 

        //Body の設定
        for(String name2 : lightningArresterName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2,null,lightningArresterName3.size(),false,false));//電圧セル
            for (String name3 : lightningArresterName3.keyset()) {
                bodyRow.add(setCell(name3,null,null,false,false));//放電電流セル
                Set<String> name4List=lightningArresterName3.get(name3);
                for(String name4 : name4List){
                    PricingTable__c priceObj = lightningArresterInfoMap.get(name2 +'@@' + name3 + '@@' + name4);
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
        }

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_HighVoltageDistributionBoard_LA.split('\r\n');

        //タイトルの設定
        lightningArresterTable.secTitle = '避雷器(LA)';//
        lightningArresterTable.comment = '';//コメント
        lightningArresterTable.headerList = headerList;//ヘッダ
        lightningArresterTable.bodyList = bodyList;//ボディー
        lightningArresterTable.noteList = noteList;//注＊
        return lightningArresterTable;
    }

    //15) 計器用変圧器(VT､PT)ヒューズ付　一覧表示内容の設定
    private static CustomTable setInstrumentTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable instrumentTransformerTable = new CustomTable();
        Set<String> instrumentTransformerName4 = new Set<String>();//名称4
        Set<String> instrumentTransformerName3 = new Set<String>();//名称３
        Set<String> instrumentTransformerName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> instrumentTransformerInfoMap = new Map<String, PricingTable__c>();//計器用変圧器(VT､PT)ヒューズ　情報
        for (PricingTable__c item : priceList) {
            //仕様１が計器用変圧器(VT、PT)ヒューズ付は　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '計器用変圧器(VT､PT)ヒューズ付'
                && item.Name2__c != '引出装置' //設計書にないですが、Masterにあります。
            ){
                String key = item.Name4__c +'@@' + item.Name3__c + '@@' + item.Name2__c;//キー
                instrumentTransformerName4.add(item.Name4__c);
                instrumentTransformerName3.add(item.Name3__c);
                instrumentTransformerName2.add(item.Name2__c);
                instrumentTransformerInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 電圧   相数  放電電流    本体  数量  引出装置有   数量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('電圧',null,null,false,false));
        headerRow1.add(setCell('相数',null,null,false,false));
        headerRow1.add(setCell('放電電流',null,null,false,false));

        for (String name2 : instrumentTransformerName2) {
            headerRow1.add(setCell(name2,null,null,false,false));
            headerRow1.add(setCell('数量',null,null,false,false));
        }

        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name4 : instrumentTransformerName4){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name4,null,2,false,false));//電圧
            for (String name3 : instrumentTransformerName3) {
                if(name3.contains('相')) {
                    List<String> name3Tmp = name3.split('相');
                    bodyRow.add(setCell((name3Tmp.get(0)=='3'?name3Tmp.get(0)+'（2個1組）':name3Tmp.get(0)),null,1,false,false));//相数
                    bodyRow.add(setCell(name3Tmp.get(1).replaceAll('[()]',''),null,1,false,false));//放電電流
                } else {
                    bodyRow.add(setCell(name3,null,1,false,false));//相数
                    bodyRow.add(setCell(null,null,1,false,false));//放電電流
                }
                for(String name2 : instrumentTransformerName2){
                    PricingTable__c priceObj = instrumentTransformerInfoMap.get(name4 +'@@' + name3 + '@@' + name2);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                    }else {
                        bodyRow.add(setCell(null,null,null,false,true));//価格セル
                        bodyRow.add(setCell(null,null,null,false,true));//空白
                    }
                }
                
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        instrumentTransformerTable.secTitle = '計器用変圧器(VT､PT)ヒューズ付';//タイトル
        instrumentTransformerTable.comment = '';//コメント
        instrumentTransformerTable.headerList = headerList;//ヘッダ
        instrumentTransformerTable.bodyList = bodyList;//ボディー
        instrumentTransformerTable.noteList = noteList;//注＊
        return instrumentTransformerTable;
    }

    //16) 零相変成器(ZPC､ZPD) 一覧表示内容の設定
    private static CustomTable setZeroPhaseTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable zeroPhaseTransformerTable = new CustomTable();
        Set<String> zeroPhaseTransformerName4 = new Set<String>();//名称4
        Set<String> zeroPhaseTransformerName3 = new Set<String>();//名称3
        Set<String> zeroPhaseTransformerName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> zeroPhaseTransformerInfoMap = new Map<String, PricingTable__c>();//零相変成器(ZPC､ZPD) 情報
        for (PricingTable__c item : priceList) {
            //仕様１が零相変成器(ZPC､ZPD)のは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '零相変成器(ZPC､ZPD)'){
                String key = item.Name4__c +'@@' + item.Name3__c + '@@' + item.Name2__c;//キー
                zeroPhaseTransformerName4.add(item.Name4__c);
                zeroPhaseTransformerName3.add(item.Name3__c);
                zeroPhaseTransformerName2.add(item.Name2__c);
                zeroPhaseTransformerInfoMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 電圧 本体 数量 引出有 数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('電圧',null,null,false,false));
        headerRow1.add(setCell('本体',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        headerRow1.add(setCell('本体+引出装置',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name4 : zeroPhaseTransformerName4){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name4,null,null,false,false));//電圧セル
            for (String name3 : zeroPhaseTransformerName3) {
                for(String name2 : zeroPhaseTransformerName2){
                    PricingTable__c priceObj = zeroPhaseTransformerInfoMap.get(name4 +'@@' + name3 + '@@' + name2);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                    }else {
                        bodyRow.add(setCell(null,null,null,false,true));//価格セル
                        bodyRow.add(setCell(null,null,null,false,true));//空白
                    }
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_HighVoltageDistributionBoard_ZPC.split('\r\n');

        //タイトルの設定
        zeroPhaseTransformerTable.secTitle = '零相変成器(ZPC、ZPD)';//タイトル
        zeroPhaseTransformerTable.comment = '';//コメント
        zeroPhaseTransformerTable.headerList = headerList;//ヘッダ
        zeroPhaseTransformerTable.bodyList = bodyList;//ボディー
        zeroPhaseTransformerTable.noteList = noteList;//注＊
        return zeroPhaseTransformerTable;
    }

    //18) 接地形計器用変圧器ヒューズ付(ZPT、GPT）一覧表示内容の設定
    private static CustomTable setGroundedInstrumentTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable groundedInstrumentTransformerTable = new CustomTable();
        Set<String> groundedInstrumentTransformerName4 = new Set<String>();//名称4
        Set<String> groundedInstrumentTransformerName2 = new Set<String>();//名称2
        Set<String> groundedInstrumentTransformerName3 = new Set<String>();//名称3
        Map<String, PricingTable__c> groundedInstrumentTransformerInfoMap = new Map<String, PricingTable__c>();//接地形計器用変圧器ヒューズ付 情報
        for (PricingTable__c item : priceList) {
            //仕様１が接地形計器用変圧器ヒューズ付のは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '接地形計器用変圧器ヒューズ付'){
                String key = item.Name4__c +'@@' + item.Name2__c + '@@' + item.Name3__c;//キー
                groundedInstrumentTransformerName4.add(item.Name4__c);
                groundedInstrumentTransformerName2.add(item.Name2__c);
                groundedInstrumentTransformerName3.add(item.Name3__c);
                groundedInstrumentTransformerInfoMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 電圧仕様     本体  数量  本体+引出装置 数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('電圧仕様',null,null,false,false));
        headerRow1.add(setCell('本体',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        headerRow1.add(setCell('本体+引出装置',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name4 : groundedInstrumentTransformerName4){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name4,null,null,false,false));//電圧仕様セル
            for (String name2 : groundedInstrumentTransformerName2) {
                for(String name3 : groundedInstrumentTransformerName3){
                    PricingTable__c priceObj = groundedInstrumentTransformerInfoMap.get(name4 +'@@' + name2 + '@@' + name3);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                    }else {
                        bodyRow.add(setCell(null,null,null,false,true));//価格セル
                        bodyRow.add(setCell(null,null,null,false,true));//空白
                    }
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_HighVoltageDistributionBoard_ZPT.split('\r\n');

        //タイトルの設定
        groundedInstrumentTransformerTable.secTitle = '接地形計器用変圧器ヒューズ付(ZPT、GPT）';//タイトル
        groundedInstrumentTransformerTable.comment = '';//コメント
        groundedInstrumentTransformerTable.headerList = headerList;//ヘッダ
        groundedInstrumentTransformerTable.bodyList = bodyList;//ボディー
        groundedInstrumentTransformerTable.noteList = noteList;//注＊
        return groundedInstrumentTransformerTable;
    }

    //20) 計器用変流器(CT):高圧 一覧表示内容の設定
    private static CustomMultiHeaderTable setCurrentTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomMultiHeaderTable currentTransformerTable = new CustomMultiHeaderTable();
        Set<String> currentTransformerName3 = new Set<String>();//名称3
        Set<String> currentTransformerName2 = new Set<String>();//名称2
        Set<String> currentTransformerName1 = new Set<String>();//名称1

        Set<String> currentTransformerMSName3 = new Set<String>();//名称3
        Set<String> currentTransformerMSName2 = new Set<String>();//名称2
        Set<String> currentTransformerMSName1 = new Set<String>();//名称1

        Map<String, PricingTable__c> currentTransformerInfoMap = new Map<String, PricingTable__c>();//計器用変流器(CT):高圧　情報
        for (PricingTable__c item : priceList) {
            //計器用変流器(CT):高圧のは　対象とする
            if(item.MajorClassificationName__c == '共通機器' && item.RecordType.DeveloperName == 'Detail' && item.Name10__c == '計器用変流器(CT):高圧'){
                if(item.Name1__c == 'MS-S用ワイドレンジCT') {
                    currentTransformerMSName3.add(item.Name3__c);
                    currentTransformerMSName2.add(item.Name2__c);
                    currentTransformerMSName1.add(item.Name1__c);
                } else {
                    String key = item.Name3__c + '@@' + item.Name2__c+'@@' + item.Name1__c ;//キー
                    currentTransformerName3.add(item.Name3__c);
                    currentTransformerName2.add(item.Name2__c);
                    currentTransformerName1.add(item.Name1__c);
                }
                String key = item.Name3__c + '@@' + item.Name2__c+'@@' + item.Name1__c ;//キー
                currentTransformerInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<Map<String, List<BodyRow>>> multiTable = new List<Map<String, List<BodyRow>>>();//ヘッダ行情報

        List<BodyRow> header1List = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> body1List = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 一次電流 二次電流    Name1   数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('一次電流',null,null,false,false));
        headerRow1.add(setCell('二次電流',null,null,false,false));    
        for(String name1: currentTransformerName1) {
            headerRow1.add(setCell(name1,null,null,false,false));
            headerRow1.add(setCell('数量',null,null,false,false));
        }
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        header1List.add(row1);

        //Body の設定
        Boolean isFirst1 = true;
        for(String name2 : currentTransformerName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2,null,null,false,false));//一次電流セル
            for(String name3 : currentTransformerName3){
                if (isFirst1)bodyRow.add(setCell(name3,null,currentTransformerName2.size(),false,false));//二次電流セル：
                for (String name1 : currentTransformerName1) {
                    PricingTable__c priceObj = currentTransformerInfoMap.get(name3 +'@@' + name2 + '@@' + name1);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                    }else {
                        bodyRow.add(setCell(null,null,null,false,true));//価格セル
                        bodyRow.add(setCell(null,null,null,false,true));//空白
                    }
                }
            }
            row.cellList = bodyRow;
            body1List.add(row);
            isFirst1 = false;
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }
        multiTable.add(new Map<String, List<BodyRow>>{'headerList'=>header1List, 'bodyList'=>body1List});

        List<BodyRow> header2List = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> body2List = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 一次電流 二次電流    Name1   数量
        List<BodyCell> headerRow2 = new List<BodyCell>();  
        headerRow2.add(setCell('一次電流',null,null,false,false));
        headerRow2.add(setCell('二次電流',null,null,false,false));    
        for(String name1: currentTransformerMSName1) {
            headerRow2.add(setCell(name1,null,null,false,false));
            headerRow2.add(setCell('数量',null,null,false,false));
        }
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        header2List.add(row2);

        //Body の設定
        Boolean isFirst2 = true;
        for(String name2 : currentTransformerMSName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2,null,null,false,false));//一次電流セル
            for(String name3 : currentTransformerMSName3){
                if (isFirst2)bodyRow.add(setCell(name3,null,currentTransformerMSName2.size(),false,false));//セル
                for (String name1 : currentTransformerMSName1) {
                    PricingTable__c priceObj = currentTransformerInfoMap.get(name3 +'@@' + name2 + '@@' + name1);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                    }else {
                        bodyRow.add(setCell(null,null,null,false,true));//価格セル
                        bodyRow.add(setCell(null,null,null,false,true));//空白
                    }
                }
            }
            row.cellList = bodyRow;
            body2List.add(row);
            isFirst2 = false;
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }
        multiTable.add(new Map<String, List<BodyRow>>{'headerList'=>header2List, 'bodyList'=>body2List});

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_HighVoltageDistributionBoard_CT.split('\r\n');

        //タイトルの設定
        currentTransformerTable.secTitle = '計器用変流器(CT):高圧';//タイトル
        currentTransformerTable.comment = '300A以下：定格電流不明時に採用';//コメント
        currentTransformerTable.multiTable = multiTable;
        currentTransformerTable.noteList = noteList;//注＊
        return currentTransformerTable;
    }

    //22) 負荷開閉器類LBS(LDS)　一覧表示内容の設定
    private static CustomTable setLoadSwitchsTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable loadSwitchsTable = new CustomTable();
        Set<String> loadSwitchsName3 = new Set<String>();//名称3
        Map<String, Set<String>> loadSwitchsName2 = new Map<String, Set<String>>();//名称2+名称5
        Map<String, Set<String>> loadSwitchsName5 = new Map<String, Set<String>>();//名称5+名称4
        Map<String, PricingTable__c> loadSwitchsInfoMap = new Map<String, PricingTable__c>();//負荷開閉器類LBS(LDS) 情報
        for (PricingTable__c item : priceList) {
            //仕様１が負荷開閉器類LBS(LDS)のは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '負荷開閉器類'){
                String key = item.Name3__c + '@@' + item.Name2__c + '@@' + item.Name5__c +'@@' + item.Name4__c;//キー
                loadSwitchsName3.add(item.Name3__c);
        
                Set<String> name5List=loadSwitchsName2.get(item.Name2__c);
                if (name5List==null) {
                    name5List = new Set<String>();
                    loadSwitchsName2.put(item.Name2__c,name5List);
                }
                name5List.add(item.name5__c);

                Set<String> name4List=loadSwitchsName5.get(item.Name5__c);
                if (name4List==null) {
                    name4List = new Set<String>();
                    loadSwitchsName5.put(item.Name5__c,name4List);
                }
                name4List.add(item.name4__c);
                loadSwitchsInfoMap.put(key,item);//データをキーで格納
            }
        }

        for (String name2 : loadSwitchsName2.keySet()) {
            List<String> name5list = new List<String>(loadSwitchsName2.get(name2));
            name5list.sort();
            loadSwitchsName2.put(name2, new Set<String>(name5list));
            for (String name5 : loadSwitchsName2.get(name2)){
                List<String> name4list = new List<String>(loadSwitchsName5.get(name5));
                name4list.sort();
                List<String> finalList = new List<String>();
                for(Integer i = name4list.size()-1; i>=0;i--)
                {
                    finalList.add(name4list.get(i));
                }
                loadSwitchsName5.put(name5, new Set<String>(finalList));
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 種別及び仕様                      LBS(LDS)                                   PCS
        //                             三極単投                   単極単投              単極単投
        // 定格電流      電動操作   数量  遠方手動    数量  フック操作   数量  フック操作   数量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow1.add(setCell('種別及び仕様',null,2,false,false));
        for (String name2 : loadSwitchsName2.keySet()) {
            Integer topRow = 0;
            for (String name5 : loadSwitchsName2.get(name2)){
                topRow += loadSwitchsName5.get(name5).size()*2;
                headerRow2.add(setCell(name5,loadSwitchsName5.get(name5).size()*2,null,false,false));
            }
            headerRow1.add(setCell(name2,topRow,null,false,false));
        }
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row2);
        
        List<BodyCell> headerRow3 = new List<BodyCell>();  
        headerRow3.add(setCell('定格電流',null,1,false,false));
        for (String name2 : loadSwitchsName2.keySet()) {
            for (String name5 : loadSwitchsName2.get(name2)){
                Set<String> name4 = loadSwitchsName5.get(name5);
                for (String val : name4) {
                    headerRow3.add(setCell(val,null,null,false,false));
                    headerRow3.add(setCell('数量',null,null,false,false));
                }
            }
        }
        BodyRow row3 = new BodyRow();
        row3.cellList=headerRow3;
        headerList.add(row3);

        //Body の設定
        for(String name3 : loadSwitchsName3){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name3,null,null,false,false));//種別及び仕様セル

            for (String name2 : loadSwitchsName2.keyset()){
                for (String name5 : loadSwitchsName2.get(name2)){
                    Set<String> name4 = loadSwitchsName5.get(name5);
                    for (String val : name4) {
                        PricingTable__c priceObj = loadSwitchsInfoMap.get(name3 +'@@' + name2 +'@@' + name5 + '@@' +val);
                        if (priceObj!=null) {
                            Decimal price = (priceObj.Price__c==null?0:priceObj.Price__c);
                            bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                            bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                        }else {
                            bodyRow.add(setCell(null,null,null,false,true));//価格セル
                            bodyRow.add(setCell(null,null,null,false,true));//空白
                        }
                    }
                }
            }
            row.cellList = bodyRow;
            bodyList.add(row);
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        loadSwitchsTable.secTitle = '負荷開閉器類LBS(LDS)';//タイトル
        loadSwitchsTable.comment = '';//コメント
        loadSwitchsTable.headerList = headerList;//ヘッダ
        loadSwitchsTable.bodyList = bodyList;//ボディー
        loadSwitchsTable.noteList = noteList;//注＊
        return loadSwitchsTable;
    }

    //23) 変圧器収納盤(高圧) 一覧表示内容の設定
    private static CustomTable setTransformerStorageBoardTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap, String searchOption){
        CustomTable transformerStorageBoardTable = new CustomTable();
        Set<String> transformerStorageBoardName3 = new Set<String>();//名称3
        Set<String> transformerStorageBoardName4 = new Set<String>();//名称4
        Map<String, PricingTable__c> transformerStorageBoardInfoMap = new Map<String, PricingTable__c>();//変圧器収納盤(高圧) 情報

        for(PricingTable__c item : priceList) {
            //仕様１が変圧器収納盤(高圧)のは　対象とする
            if(item.MajorClassificationName__c == '変圧器' && item.MinorClassificationName__c == '変圧器収納盤' && item.RecordType.DeveloperName == 'Chassis' && item.Name1__c == '変圧器収納盤(高圧)' && item.Name2__c == searchOption){
                String key = item.Name3__c +'@@' + item.Name4__c;//キー
                transformerStorageBoardName3.add(item.Name3__c);
                transformerStorageBoardName4.add(item.Name4__c);
                transformerStorageBoardInfoMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 変圧器容量    価格  標準盤外形寸法 数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('変圧器容量',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('標準盤外形寸法',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name3 : transformerStorageBoardName3){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name4 : transformerStorageBoardName4) {
                PricingTable__c priceObj = transformerStorageBoardInfoMap.get(name3 +'@@' + name4);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name3,null,null,false,false));//変圧器容量セル
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(name4,null,null,false,false));//標準盤外形寸法セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_HighVoltageDistributionBoard_TransformerStorageBoard.split('\r\n');

        //タイトルの設定
        transformerStorageBoardTable.secTitle = '変圧器収納盤(高圧)';//タイトル
        transformerStorageBoardTable.comment = '';//コメント
        transformerStorageBoardTable.headerList = headerList;//ヘッダ
        transformerStorageBoardTable.bodyList = bodyList;//ボディー
        transformerStorageBoardTable.noteList = noteList;//注＊
        return transformerStorageBoardTable;
    }

    //25) ネットワークリレー 一覧表示内容の設定
    private static CustomTable setNetworkRelayMulticapTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable networkRelayMulticapTable = new CustomTable();
        Set<String> networkRelayMulticapName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> networkRelayMulticapInfoMap = new Map<String, PricingTable__c>();
        for(PricingTable__c item : priceList) {
            //仕様１がネットワークリレーのは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'ネットワークリレー'){
                networkRelayMulticapName2.add(item.Name2__c);
                networkRelayMulticapInfoMap.put(item.Name2__c,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 型名       価格  数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('型名',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for (String name2 : networkRelayMulticapName2) {
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = networkRelayMulticapInfoMap.get(name2);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(name2,null,null,false,false));//型名セル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        networkRelayMulticapTable.secTitle = 'ネットワークリレー';//タイトル
        networkRelayMulticapTable.comment = '';//コメント
        networkRelayMulticapTable.headerList = headerList;//ヘッダ
        networkRelayMulticapTable.bodyList = bodyList;//ボディー
        networkRelayMulticapTable.noteList = noteList;//注＊
        return networkRelayMulticapTable;
    }

    //26) ネットワークVT 一覧表示内容の設定
    private static CustomTable setNetworkVTTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable networkVTTable = new CustomTable();
        Map<String, Set<String>> networkVTTName3 = new Map<String, Set<String>>();//名称3+名称2
        Map<String, PricingTable__c> networkVTTInfoMap = new Map<String, PricingTable__c>();//ネットワークVＴ 情報
        for(PricingTable__c item : priceList) {
            //仕様１がネットワークVTのは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'ネットワークVT'){
                String key = item.Name3__c +'@@' + item.Name2__c;//キー
                Set<String> name2List=networkVTTName3.get(item.Name3__c);
                if (name2List==null) {
                    name2List = new Set<String>();
                    networkVTTName3.put(item.Name3__c,name2List);
                }
                name2List.add(item.Name2__c);
                networkVTTInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 機器構成         価格  数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('機器構成',2,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name3 : networkVTTName3.keySet()){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name3,null, networkVTTName3.get(name3).size(),false,false));//機器構成セル
            for (String name2 : networkVTTName3.get(name3)) {
                PricingTable__c priceObj = networkVTTInfoMap.get(name3 +'@@' + name2);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2,null,null,false,false));//機器構成セル
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        networkVTTable.secTitle = 'ネットワークVT';//タイトル
        networkVTTable.comment = '';//コメント
        networkVTTable.headerList = headerList;//ヘッダ
        networkVTTable.bodyList = bodyList;//ボディー
        networkVTTable.noteList = noteList;//注＊
        return networkVTTable;
    }

    //27) ネットワークCT 一覧表示内容の設定
    private static CustomTable setNetworkCTTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable networkCTTable = new CustomTable();
        Map<String, Set<String>> networkCTName3 = new Map<String, Set<String>>();//名称3+名称2
        Map<String, PricingTable__c> networkCTInfoMap = new Map<String, PricingTable__c>();//ネットワークCT 情報
        for(PricingTable__c item : priceList) {
            //仕様１がネットワークCTのは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'ネットワークCT'){
                String key = item.Name3__c +'@@' + item.Name2__c;//キー
                Set<String> name2List=networkCTName3.get(item.Name3__c);
                if (name2List==null) {
                    name2List = new Set<String>();
                    networkCTName3.put(item.Name3__c,name2List);
                }
                name2List.add(item.Name2__c);
                networkCTInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 機器構成         価格  数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('機器構成',2,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name3 : networkCTName3.keySet()){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name3,null, networkCTName3.get(name3).size(),false,false));//機器構成セル
            for (String name2 : networkCTName3.get(name3)) {
                PricingTable__c priceObj = networkCTInfoMap.get(name3 +'@@' + name2);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2,null,null,false,false));//機器構成セル
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        networkCTTable.secTitle = 'ネットワークCT';//タイトル
        networkCTTable.comment = '';//コメント
        networkCTTable.headerList = headerList;//ヘッダ
        networkCTTable.bodyList = bodyList;//ボディー
        networkCTTable.noteList = noteList;//注＊
        return networkCTTable;
    }

    //28) 合成CT(高圧/低圧) 一覧表示内容の設定
    private static CustomTable setCompositeCTHighAndLowTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable compositeCTHighAndLowTable = new CustomTable();
        Set<String> compositeCTHighAndLowName2 = new Set<String>();//名称２
        Map<String, PricingTable__c> compositeCTHighAndLowFuseMap = new Map<String, PricingTable__c>();
        for (PricingTable__c item : priceList) {
            //仕様１が合成CT(高圧/低圧)のは　対象とする
            if(item.MajorClassificationName__c == '高圧受配電盤' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '合成CT(高圧/低圧)'){
                String key = item.Name2__c;//キー
                compositeCTHighAndLowName2.add(item.Name2__c);
                compositeCTHighAndLowFuseMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //定格電流  価格  数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('定格電流',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2 : compositeCTHighAndLowName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = compositeCTHighAndLowFuseMap.get(name2);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(name2,null,null,false,false));//定格電流セル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        compositeCTHighAndLowTable.secTitle = '合成CT(高圧/低圧)';//タイトル
        compositeCTHighAndLowTable.comment = '';//コメント
        compositeCTHighAndLowTable.headerList = headerList;//ヘッダ
        compositeCTHighAndLowTable.bodyList = bodyList;//ボディー
        compositeCTHighAndLowTable.noteList = noteList;//注＊
        return compositeCTHighAndLowTable;
    }

    //29) プロテクタヒューズ 一覧表示内容の設定
    private static CustomTable setProtectorFuseTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable protectorFuseTable = new CustomTable();
        Set<String> protectorFuseName2 = new Set<String>();//名称２
        Map<String, PricingTable__c> protectorFuseMap = new Map<String, PricingTable__c>();
        for (PricingTable__c item : priceList) {
            //仕様１がプロテクタヒューズのは　対象とする
            if(item.MajorClassificationName__c == '共通機器' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'プロテクタヒューズ'){
                String key = item.Name2__c;//キー
                protectorFuseName2.add(item.Name2__c);
                protectorFuseMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //定格電流  価格  数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('定格電流',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2 : protectorFuseName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = protectorFuseMap.get(name2);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(name2,null,null,false,false));//定格電流セル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        protectorFuseTable.secTitle = 'プロテクタヒューズ';//タイトル
        protectorFuseTable.comment = '';//コメント
        protectorFuseTable.headerList = headerList;//ヘッダ
        protectorFuseTable.bodyList = bodyList;//ボディー
        protectorFuseTable.noteList = noteList;//注＊
        return protectorFuseTable;
    }

    //30) テイクオフヒューズ一覧表示内容の設定
    private static CustomTable setTakeOffFuseTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable takeOffFuseTable = new CustomTable();
        Set<String> takeOffFuseName2 = new Set<String>();//名称２
        Map<String, PricingTable__c> takeOffFuseMap = new Map<String, PricingTable__c>();
        for (PricingTable__c item : priceList) {
            //仕様１がテイクオフヒューズのは　対象とする
            if(item.MajorClassificationName__c == '共通機器' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'テイクオフヒューズ'){
                String key = item.Name2__c;//キー
                takeOffFuseName2.add(item.Name2__c);
                takeOffFuseMap.put(key,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 定格電流 価格  数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('定格電流',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2 : takeOffFuseName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = takeOffFuseMap.get(name2);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(name2,null,null,false,false));//定格電流セル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_HighVoltageDistributionBoard_TakeOffFuse.split('\r\n');

        //タイトルの設定
        takeOffFuseTable.secTitle = 'テイクオフヒューズ';//タイトル
        takeOffFuseTable.comment = '';//コメント
        takeOffFuseTable.headerList = headerList;//ヘッダ
        takeOffFuseTable.bodyList = bodyList;//ボディー
        takeOffFuseTable.noteList = noteList;//注＊
        return takeOffFuseTable;
    }

    //32) 計器・保護継電器・変換器 一覧表示内容の設定
    private static CustomTable setMeterTableTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable meterTableTable = new CustomTable();
        Set<String> takeOffFuseName1 = new Set<String>();//名称２
        Map<String, PricingTable__c> takeOffFuseMap = new Map<String, PricingTable__c>();
        for (PricingTable__c item : priceList) {
            //仕様10が計器・保護継電器・変換器のは　対象とする
            if(item.MajorClassificationName__c == '共通機器' && item.RecordType.DeveloperName == 'Detail' && item.Name10__c == '計器・保護継電器・変換器'){
                takeOffFuseName1.add(item.Name1__c);
                takeOffFuseMap.put(item.Name1__c,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 品名           記号      価格  数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('品名',null,null,false,false));
        headerRow1.add(setCell('記号',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name1 : takeOffFuseName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = takeOffFuseMap.get(name1);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(name1,null,null,false,false));//品名セル
                bodyRow.add(setCell(priceObj.Name2__c,null,null,false,false));//記号セル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_HighVoltageDistributionBoard_Meter.split('\r\n');

        //タイトルの設定
        meterTableTable.secTitle = '計器・保護継電器・変換器';//タイトル
        meterTableTable.comment = '';//コメント
        meterTableTable.headerList = headerList;//ヘッダ
        meterTableTable.bodyList = bodyList;//ボディー
        meterTableTable.noteList = noteList;//注＊
        return meterTableTable;
    }

    //34) 変換器(トランスデューサ:T/D) 一覧表示内容の設定
    private static CustomTable setTransducerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable transducerTable = new CustomTable();
        Set<String> transducerName2 = new Set<String>();//名称２
        Map<String, PricingTable__c> transducerMap = new Map<String, PricingTable__c>();
        for (PricingTable__c item : priceList) {
            //仕様１が変換器(トランスデューサ:T/D) のは　対象とする
            if(item.MajorClassificationName__c == '共通機器' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '変換器(トランスデューサ:T/D)'){
                transducerName2.add(item.Name2__c);
                transducerMap.put(item.Name2__c,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 用途           記号      価格  数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('用途',null,null,false,false));
        headerRow1.add(setCell('記号',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2 : transducerName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = transducerMap.get(name2);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(name2,null,null,false,false));//用途セル
                bodyRow.add(setCell(priceObj.Name3__c,null,null,false,false));//記号セル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        transducerTable.secTitle = '変換器(トランスデューサ:T/D)';//タイトル
        transducerTable.comment = '';//コメント
        transducerTable.headerList = headerList;//ヘッダ
        transducerTable.bodyList = bodyList;//ボディー
        transducerTable.noteList = noteList;//注＊
        return transducerTable;
    }
    
    //35) MELPRO-Dシリーズ 一覧表示内容の設定
    private static CustomTable setMELPRODSeriesTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable MELPRODSeriesTable = new CustomTable();
        Set<String> MELPRODSeriesName2and3 = new Set<String>();//名称２
        Map<String, PricingTable__c> MELPRODSeriesMap = new Map<String, PricingTable__c>();
        for (PricingTable__c item : priceList) {
            //仕様１がMELPRO-Dシリーズ のは　対象とする
            if(item.MajorClassificationName__c == '共通機器' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'MELPRO-Dシリーズ'){
                MELPRODSeriesName2and3.add(item.Name2__c + item.Name3__c);
                MELPRODSeriesMap.put(item.Name2__c + item.Name3__c,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 形名     内蔵要素   価格    数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('形名',null,null,false,false));
        headerRow1.add(setCell('内蔵要素',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2and3 : MELPRODSeriesName2and3){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = MELPRODSeriesMap.get(name2and3);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(priceObj.Name2__c,null,null,false,false));//形名セル
                bodyRow.add(setCell(priceObj.Name3__c,null,null,false,false));//内蔵要素セル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        MELPRODSeriesTable.secTitle = 'MELPRO-Dシリーズ';//タイトル
        MELPRODSeriesTable.comment = '';//コメント
        MELPRODSeriesTable.headerList = headerList;//ヘッダ
        MELPRODSeriesTable.bodyList = bodyList;//ボディー
        MELPRODSeriesTable.noteList = noteList;//注＊
        return MELPRODSeriesTable;
    }

    //36) MP11A(マルチリレー) 一覧表示内容の設定
    private static CustomTable setMp11MultiRelayTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable mp11MultiRelayTable = new CustomTable();
        Set<String> mp11MultiRelayName2 = new Set<String>();//名称２
        Map<String, PricingTable__c> mp11MultiRelayInfoMap = new Map<String, PricingTable__c>();
        for (PricingTable__c item : priceList) {
            //仕様１がMP11A(マルチリレー)のは　対象とする
            if(item.MajorClassificationName__c == '共通機器' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'MP11A(マルチリレー)'){
                mp11MultiRelayName2.add(item.Name2__c);
                mp11MultiRelayInfoMap.put(item.Name2__c,item);//データをキーで格納
            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //仕様・型番    価格    数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('仕様・型番',null,null,false,false));
        headerRow1.add(setCell('価格',null,null,false,false));
        headerRow1.add(setCell('数量',null,null,false,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2 : mp11MultiRelayName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = mp11MultiRelayInfoMap.get(name2);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(name2,null,null,false,false));//仕様・型番セル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
            
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        mp11MultiRelayTable.secTitle = 'MP11A(マルチリレー)';//タイトル
        mp11MultiRelayTable.comment = '';//コメント
        mp11MultiRelayTable.headerList = headerList;//ヘッダ
        mp11MultiRelayTable.bodyList = bodyList;//ボディー
        mp11MultiRelayTable.noteList = noteList;//注＊
        return mp11MultiRelayTable;
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

    @AuraEnabled
    /**
     * 機器に対して　既に登録済みの内訳情報を取得
     * 
     *  @param deviceId 機器Id
     */
    Public static Map<Id, Detail__c> getChassisRecordsByDeviceId(Id deviceId) {
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
                                                                UnitPriceCoefficient__c,
                                                                ProvisionUnitPrice__c,
                                                                WC__c,
                                                                Price__c,
                                                                ProvisionPrice__c,
                                                                Weight__c
                                                              FROM Detail__c 
                                                              WHERE Device__c =:deviceId AND DetailCategory__c='筐体' AND MajorClassificationName__c='高圧受配電盤' LIMIT 1]);

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
}