public with sharing class DetailsInputController {

    public class ScreenInfo {
        String errorMsg  {get;set;}
        Boolean isNodata  {get;set;}

        //初期表示(選択内容)
        String inputedId {get;set;}
        Decimal displayTotal {get;set;}
        String displayCondition {get;set;}
        //初期表示(検索条件)
        String screenType {get;set;}
        String priceCondition1 {get;set;}
        String priceCondition2 {get;set;}
        String priceCondition3 {get;set;}
        String priceCondition4 {get;set;}
        String priceCondition5 {get;set;}

        public List<BodyRow> bodyList {get;set;}
        public List<BodyRow> headerList {get;set;}
    }

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
    }

    public class QuantityObject{
        public String Id {get;set;}
        public Decimal Price {get;set;}
        public Decimal Quantity {get;set;}
        // public String Option {get;set;}
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
        CustomTable primerCutoutSwitchTable{get;set;}
        CustomTable lightningArresterTable{get;set;}
        CustomTable instrumentTransformerTable{get;set;}
        CustomTable zeroPhaseTransformerTable{get;set;}
        CustomTable groundedInstrumentTransformerTable{get;set;}
        CustomTable currentTransformerTable{get;set;}
        
    }


    ///内訳入力B_高圧TR 油入
    public class VoltageOilImmersedScreenInfo {
        CustomTable highVoltageTransformerTable {get;set;}       //高圧トランス 
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
     *内訳入力B_高圧受配電盤  保存ボタン　処理
     */
    public static string submitHighVoltageDetails(String details,String deviceId){
        System.debug(details);
        System.debug(deviceId);
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

        //既存情報を削除
        List<Detail__c> deleteDetails = [SELECT Id FROM Detail__c WHERE Device__c =:deviceId ];//AND PricingTable__c IN:delIds
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
                                                                        Name1__c, Name2__c, Name3__c, Name4__c, Name5__c, Name6__c, 
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
                        detail.Device__c = deviceId;//機器ID
                        detail.Name	= pricingTable.DisplayName__c;//価格表.表示用テキスト

                        // 名称1Name"③の表で数量を入力した内訳を保存する場合：価格表.種類名
                        // それ以外の表で数量を入力した内訳を保存する場合：価格表.名称1"
                        // 名称2Name2__c"③の表で数量を入力した内訳を保存する場合：価格表.名称1+""　""+価格表.名称2
                        // それ以外の表で数量を入力した内訳を保存する場合：価格表.名称2"
                        // 名称3Name3__c"③の表で数量を入力した内訳を保存する場合：価格表.名称3+""　""+価格表.名称4+""　""+名称5
                        // それ以外の表で数量を入力した内訳を保存する場合：価格表.名称3"
                        // 名称4Name4__c"③の表で数量を入力した内訳を保存する場合：""""
                        // それ以外の表で数量を入力した内訳を保存する場合：価格表.名称4"
                        // WC算出レートWcCalculationRate__c"③の表で数量を入力した内訳を保存する場合：0
                        // それ以外の表で数量を入力した内訳を保存する場合：価格表.WC算出レート"
                        if (pricingTable.RecordType.DeveloperName=='Chassis') {
                            detail.Name1__c	= pricingTable.CategoryName__c;//価格表.種類名
                            detail.Name2__c	= pricingTable.Name1__c 
                                            +(String.isNotBlank(pricingTable.Name2__c)?'　' + pricingTable.Name2__c:'');//価格表.名称1+""　""+価格表.名称2
                            detail.Name3__c	= pricingTable.Name3__c
                                            + (String.isNotBlank(pricingTable.Name4__c)?'　' + pricingTable.Name4__c:'')
                                            + (String.isNotBlank(pricingTable.Name5__c)?'　' + pricingTable.Name5__c:'');//価格表.名称3+""　""+価格表.名称4+""　""+名称5
                            detail.Name4__c	= '';//名称４
                            detail.DetailCategory__c='筐体';//"筐体" "明細"
                            detail.WcCalculationRate__c=0;
                        }else{
                            detail.Name1__c	= pricingTable.Name1__c;//名称１
                            detail.Name2__c	= pricingTable.Name2__c;//名称２
                            detail.Name3__c	= pricingTable.Name3__c;//名称３
                            detail.Name4__c	= pricingTable.Name4__c;//名称４
                            detail.DetailCategory__c='明細';//"筐体" "明細"
                            detail.WcCalculationRate__c=pricingTable.WcCalculationRate__c;
                        }

                        // detail.RECNO__c = pricingTable.RECNO__c;//RECNO__c
                        //RECNO 「大分類名」「大分類コード」「小分類名」「小分類コード」「種類名」「種類コード」
                        detail.RECNO__c = pricingTable.RECNO__c;//RECNO
                        detail.MajorClassificationName__c = pricingTable.MajorClassificationName__c;//大分類名
                        detail.MajorClassificationCode__c = pricingTable.MajorClassificationCode__c;//大分類コード
                        detail.MinorClassificationName__c = pricingTable.MinorClassificationName__c;//小分類名
                        detail.MinorClassificationCode__c = pricingTable.MinorClassificationCode__c;//小分類コード
                        detail.CategoryCode__c = pricingTable.CategoryCode__c;//種類コード

                        // detail.PricingTable__c = pricingTable.Id;//価格表Id
                        detail.PricingTableUniqueKey__c = pricingTable.UniqueKey__c;//価格表Id
                        detail.CreditWC__c = pricingTable.WC__c;//価格表.WC
                        // detail.WcCoefficient__c=null;// WC係数	WcCoefficient__c	""	
                        detail.Note__c = pricingTable.Note__c;//備考
                        detail.UnitPrice__c	 = pricingTable.Price__c;//単価
                        detail.UnitPriceCoefficient__c	=null;//単価係数 UnitPriceCoefficient__c ""
                        detail.Quantity__c = quantity;//数量
                        detail.CreditWeight__c = pricingTable.Weight__c;//価格表.重量
                        detail.detailedStatementText__c	= pricingTable.detailedStatementText__c;//価格表.内訳書出力用テキスト
                        detail.SpecialSpecificationNo__c= pricingTable.SpecialSpecificationNo__c;//価格表.特殊仕様No
                        detail.MasterCode__c = pricingTable.MasterCode__c;//マスタコード
                        detail.DetailRecordDisplayNumberText__c = pricingTable.DetailRecordDisplayNumberText__c;//明細レコード表示順
                        detailList.add(detail); 
                    }
                }
            }
            if (detailList.size()>0) insert detailList;
        }

        return 'success';
    }

    
    @AuraEnabled
    /*
     *内訳入力B_高圧TR 油入  画面情報を取得
     */
    public static string getVoltageOilImmersedScreenInfo(){
        VoltageOilImmersedScreenInfo screenInfo = new VoltageOilImmersedScreenInfo();

        CustomTable highVoltageTransformerTable = new CustomTable();

        screenInfo.highVoltageTransformerTable = highVoltageTransformerTable;

        return  JSON.serialize(screenInfo);
    }




    @AuraEnabled
    /*
     *内訳入力B_高圧受配電盤  画面情報を取得
     */
    public static string getHighVoltageScreenInfo(String deviceId,
                                                    String searchOption,
                                                    String inputsRecords){
        HighVoltageScreenInfo screenInfo = new HighVoltageScreenInfo();

        List<PricingTable__c> priceList = [SELECT Id,UniqueKey__c, Name, RecordType.DeveloperName,
                                            MajorClassificationName__c,//大分類
                                            MinorClassificationName__c, //小分類
                                            CategoryName__c,//種類名
                                            Name1__c, //名称１
                                            Name2__c, //名称２
                                            Name3__c, //名称３
                                            Name4__c, //名称４
                                            Name5__c, //名称５
                                            WC__c, 
                                            Price__c, //単価
                                            //Weight__c, 
                                            MasterCode__c,//マスタコード
                                            DetailRecordDisplayNumberText__c,//明細レコード表示順
                                            Note__c
                                        FROM PricingTable__c
                                        WHERE BU__c='S'
                                            AND MajorClassificationName__c = '高圧受配電盤'
                                            AND ( 
                                                (RecordType.DeveloperName = 'Chassis' 
                                                AND CategoryName__c='筐体' 
                                                AND Name4__c = :searchOption)
                                              OR (RecordType.DeveloperName = 'Detail' 
                                              AND Name1__C IN ('真空遮断器(VCB) 7.2/3.6kV'
                                              ,'断路器(DS)　 600A以下'
                                              ,'断路器(DS)　1200A'
                                              ,'断路器(DS)　2000A'
                                              ,'屋外用高圧交流ｶﾞｽ負荷開閉器'
                                              ,'ﾋｭｰｽﾞ付負荷開閉器(LBS)'
                                              ,'気中負荷開閉器(PAS)'
                                              ,'零相変流器(ZCT)'
                                              ,'ﾌﾟﾗｲﾏﾘｶｯﾄｱｳﾄｽｲｯﾁ(PCS)'
                                              ,'避雷器(LA) 8.4/4.2kV 3相用'
                                              ,'計器用変圧器(VT、PT)ﾋｭｰｽﾞ付'
                                              ,'零相変成器(ZPC、ZPD)'
                                              ,'接地形計器用変圧器ﾋｭｰｽﾞ付'
                                              ,'計器用変流器(CT)'
                                              ,'計器用変流器(CT) 3相用'
                                              ,''))
                                                )
                                        ORDER BY RECNO__c
                                    ];
                                    // CategoryCode__c,Specification1DisplayOrder__c,Name1__c,
                                    // Specification2DisplayOrder__c,Name2__c,
                                    // Specification3DisplayOrder__c,Name3__c,
                                    // Specification4DisplayOrder__c desc,Name4__c,
                                    // Specification5DisplayOrder__c,Name5__c


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

        //箱体（高圧受配電盤  筐体）
        CustomTable boxTable = setBoxTable(priceList, '箱体（高圧受配電盤  筐体）', detailMap);
        boxTable.noteList = new List<String>{
                                    '注１：屋外盤は屋内盤+30%とする。薄型盤(FF)は屋内盤-20%とする。',
                                    '注２：取引用変成器(VCT,MOF,PCT)は電力会社より支給。',
                                    '注３：1面に MOFとVCBとも収納の場合は、遮断器収納価格を採用下さい。',
                                    '注４：低圧配電盤筐体価格は、本価格表では入力できません。現場自立盤筐体価格を参照の上、内訳入力Aをご利用下さい。'};
        screenInfo.boxTable = boxTable;//箱体（高圧受配電盤  筐体）

        //真空遮断器(VCB)
        CustomTable vcBreakerTable = setVcBreakerTable(priceList, detailMap);
        screenInfo.vcBreakerTable = vcBreakerTable;//真空遮断器(VCB)

        //断路器（ＤＳ）
        CustomTable disconnectorTable = setBoxTable(priceList, '断路器(DS)', detailMap);
        disconnectorTable.noteList = new List<String>();
        disconnectorTable.comment='＊通常は手動リンク';
        screenInfo.disconnectorTable = disconnectorTable;//断路器（ＤＳ）

        //屋外用高圧交流ガス負荷開閉器
        CustomTable gasLoadSwitchTable = setGasLoadSwitchTable(priceList, detailMap);
        screenInfo.gasLoadSwitchTable = gasLoadSwitchTable;//屋外用高圧交流ガス負荷開閉器

        //ﾋｭｰｽﾞ付負荷開閉器（LBS）
        CustomTable fuseLoadSwitchTable = setFuseLoadSwitchTable(priceList, detailMap);
        screenInfo.fuseLoadSwitchTable = fuseLoadSwitchTable;//ﾋｭｰｽﾞ付負荷開閉器（LBS）
        
        //気中負荷開閉器(PAS(戸上電機))
        CustomTable airLoadSwitchTable = setAirLoadSwitchTable(priceList, detailMap);
        screenInfo.airLoadSwitchTable = airLoadSwitchTable;//気中負荷開閉器(PAS(戸上電機))

        //取引用計器箱(日東工業)
        CustomTable instrumentBoxTable = setInstrumentBoxTable(priceList, detailMap);
        screenInfo.instrumentBoxTable = instrumentBoxTable;//取引用計器箱(日東工業)

        //零相変流器（ZCT）：高圧
        CustomTable zeroPhaseCurrentTransformerTable = setZeroPhaseCurrentTransformerTable(priceList, detailMap);
        screenInfo.zeroPhaseCurrentTransformerTable = zeroPhaseCurrentTransformerTable;//零相変流器（ZCT）：高圧

        //ﾌﾟﾗｲﾏﾘｰｶｯﾄｱｳﾄｽｲｯﾁ（PCS）
        CustomTable primerCutoutSwitchTable = setPrimerCutoutSwitchTable(priceList, detailMap);
        screenInfo.primerCutoutSwitchTable = primerCutoutSwitchTable;//ﾌﾟﾗｲﾏﾘｰｶｯﾄｱｳﾄｽｲｯﾁ（PCS）

        //避雷器(LA)
        CustomTable lightningArresterTable = setLightningArresterTable(priceList, detailMap);
        screenInfo.lightningArresterTable = lightningArresterTable;//避雷器(LA)

        //計器用変圧器(VT，PT)ﾋｭｰｽﾞ付
        CustomTable instrumentTransformerTable = setInstrumentTransformerTable(priceList, detailMap);
        screenInfo.instrumentTransformerTable = instrumentTransformerTable;//計器用変圧器(VT，PT)ﾋｭｰｽﾞ付

        //零相変成器（ZPC・ZPD)
        CustomTable zeroPhaseTransformerTable = setZeroPhaseTransformerTable(priceList, detailMap);
        screenInfo.zeroPhaseTransformerTable = zeroPhaseTransformerTable;//零相変成器(ZPC、ZPD)


        //接地形計器用変圧器ﾋｭｰｽﾞ付(ZPT・GPT）
        CustomTable groundedInstrumentTransformerTable = setGroundedInstrumentTransformerTable(priceList, detailMap);
        screenInfo.groundedInstrumentTransformerTable = groundedInstrumentTransformerTable;//接地形計器用変圧器ﾋｭｰｽﾞ付(ZPT・GPT）

        //計器用変流器（ＣＴ）：高圧
        CustomTable currentTransformerTable = setCurrentTransformerTable(priceList, detailMap);
        screenInfo.currentTransformerTable = currentTransformerTable;//計器用変流器（ＣＴ）：高圧
        return  JSON.serialize(screenInfo);

    }

    //計器用変流器（ＣＴ）：高圧一覧表示内容の設定
    private static CustomTable setCurrentTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable currentTransformerTable = new CustomTable();
        Set<String> currentTransformerName3 = new Set<String>();//名称3
        Set<String> currentTransformerName2 = new Set<String>();//名称2
        Set<String> currentTransformerName1 = new Set<String>();//名称1
        Map<String, PricingTable__c> currentTransformerInfoMap = new Map<String, PricingTable__c>();//計器用変流器（ＣＴ）：高圧　情報
        for (PricingTable__c item : priceList) {
            //仕様１が計器用変流器（ＣＴ）：高圧のは　対象とする
            if(item.Name1__c.contains('計器用変流器(CT)')){
                String key = item.Name3__c + '@@' + item.Name2__c+'@@' + item.Name1__c ;//キー
                currentTransformerName3.add(item.Name3__c);
                currentTransformerName2.add(item.Name2__c);
                currentTransformerName1.add(item.Name1__c);
                currentTransformerInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 定格電流 価格 数量 価格 数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('定格電流',2,null,false));
        headerRow1.add(setCell('価格',null,2,false));
        headerRow1.add(setCell('数量',null,2,false));
        headerRow1.add(setCell('価格',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);
        // 一次　二次
        List<BodyCell> headerRow2 = new List<BodyCell>();  
        headerRow2.add(setCell('一次',null,null,false));
        headerRow2.add(setCell('二次',null,null,false));
        headerRow2.add(setCell('3相用（2×CT）',2,null,false));
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row2);

        //Body の設定
        Boolean isFirst = true;
        for(String name2 : currentTransformerName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2.remove('一次：'),null,null,false));//一次
            for(String name3 : currentTransformerName3){
                if (isFirst)bodyRow.add(setCell(name3.remove('二次：'),null,currentTransformerName2.size(),false));//二次：
                for (String name1 : currentTransformerName1) {
                    PricingTable__c priceObj = currentTransformerInfoMap.get(name3 +'@@' + name2 + '@@' + name1);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                    }else {
                        bodyRow.add(setCell('―',null,null,false));//価格セル
                        bodyRow.add(setCell('―',null,null,false));//空白
                    }
                }
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            isFirst = false;
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }

        //注＊　の設定
        List<String> noteList = new List<String>{
            '注：（CTT）試験用端子は含む。',
            '注：3相用（2個）価格。'
        };

        //タイトルの設定
        currentTransformerTable.secTitle = '計器用変流器（ＣＴ）：高圧';//タイトル
        currentTransformerTable.comment = '300A以下：定格電流不明時に採用';//ココメント
        currentTransformerTable.headerList = headerList;//ヘッダ
        currentTransformerTable.bodyList = bodyList;//ボディー
        currentTransformerTable.noteList = noteList;//注＊
        return currentTransformerTable;
    }

    //接地形計器用変圧器ﾋｭｰｽﾞ付(ZPT・GPT）一覧表示内容の設定
    private static CustomTable setGroundedInstrumentTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable groundedInstrumentTransformerTable = new CustomTable();
        Set<String> groundedInstrumentTransformerName4 = new Set<String>();//名称4
        Set<String> groundedInstrumentTransformerName3 = new Set<String>();//名称３
        Set<String> groundedInstrumentTransformerName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> groundedInstrumentTransformerInfoMap = new Map<String, PricingTable__c>();//接地形計器用変圧器ﾋｭｰｽﾞ付情報
        for (PricingTable__c item : priceList) {
            //仕様１が接地形計器用変圧器ﾋｭｰｽﾞ付のは　対象とする
            if(item.Name1__c=='接地形計器用変圧器ﾋｭｰｽﾞ付'){
                String key = item.Name4__c +'@@' + item.Name3__c + '@@' + item.Name2__c;//キー
                groundedInstrumentTransformerName4.add(item.Name4__c);
                groundedInstrumentTransformerName3.add(item.Name3__c);
                groundedInstrumentTransformerName2.add(item.Name2__c);
                groundedInstrumentTransformerInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        // 電圧 本体 数量 引出有 数量
        List<BodyCell> headerRow1 = new List<BodyCell>();  
        headerRow1.add(setCell('電圧',null,null,false));
        headerRow1.add(setCell('本体',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        headerRow1.add(setCell('引出有',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name4 : groundedInstrumentTransformerName4){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name4,null,null,false));//電圧
            for(String name2 : groundedInstrumentTransformerName2){
                for (String name3 : groundedInstrumentTransformerName3) {
                    PricingTable__c priceObj = groundedInstrumentTransformerInfoMap.get(name4 +'@@' + name3 + '@@' + name2);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                    }else {
                        bodyRow.add(setCell('―',null,null,false));//価格セル
                        bodyRow.add(setCell('―',null,null,false));//空白
                    }
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>{
            '注： 3.3KVの場合も同価格。'
        };

        //タイトルの設定
        groundedInstrumentTransformerTable.secTitle = '接地形計器用変圧器ﾋｭｰｽﾞ付(ZPT・GPT）';//タイトル
        groundedInstrumentTransformerTable.headerList = headerList;//ヘッダ
        groundedInstrumentTransformerTable.bodyList = bodyList;//ボディー
        groundedInstrumentTransformerTable.noteList = noteList;//注＊
        return groundedInstrumentTransformerTable;
    }

    //零相変成器（ZPC・ZPD)一覧表示内容の設定
    private static CustomTable setZeroPhaseTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable zeroPhaseTransformerTable = new CustomTable();
        Set<String> zeroPhaseTransformerName4 = new Set<String>();//名称4
        Set<String> zeroPhaseTransformerName3 = new Set<String>();//名称３
        Set<String> zeroPhaseTransformerName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> zeroPhaseTransformerInfoMap = new Map<String, PricingTable__c>();//零相変成器(ZPC、ZPD)情報
        for (PricingTable__c item : priceList) {
            //仕様１が計器用変圧器(VT、PT)ﾋｭｰｽﾞ付のは　対象とする
            if(item.Name1__c=='零相変成器(ZPC、ZPD)'){
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
        headerRow1.add(setCell('電圧',null,null,false));
        headerRow1.add(setCell('本体',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        headerRow1.add(setCell('引出有',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name4 : zeroPhaseTransformerName4){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name4.split(',').get(0),null,null,false));//電圧
            for (String name3 : zeroPhaseTransformerName3) {
                for(String name2 : zeroPhaseTransformerName2){
                    PricingTable__c priceObj = zeroPhaseTransformerInfoMap.get(name4 +'@@' + name3 + '@@' + name2);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                    }else {
                        bodyRow.add(setCell('―',null,null,false));//価格セル
                        bodyRow.add(setCell('―',null,null,false));//空白
                    }
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>{
            '注：3.3KV／3.5Vの場合も同価格。',
            '注：3相1組価格。'
        };

        //タイトルの設定
        zeroPhaseTransformerTable.secTitle = '零相変成器（ZPC・ZPD)';//タイトル
        zeroPhaseTransformerTable.headerList = headerList;//ヘッダ
        zeroPhaseTransformerTable.bodyList = bodyList;//ボディー
        zeroPhaseTransformerTable.noteList = noteList;//注＊
        return zeroPhaseTransformerTable;
    }

    //計器用変圧器(VT、PT)ﾋｭｰｽﾞ付一覧表示内容の設定
    private static CustomTable setInstrumentTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable instrumentTransformerTable = new CustomTable();
        Set<String> instrumentTransformerName4 = new Set<String>();//名称4
        Set<String> instrumentTransformerName3 = new Set<String>();//名称３
        Set<String> instrumentTransformerName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> instrumentTransformerInfoMap = new Map<String, PricingTable__c>();//計器用変圧器(VT、PT)ﾋｭｰｽﾞ付情報
        for (PricingTable__c item : priceList) {
            //仕様１が計器用変圧器(VT、PT)ﾋｭｰｽﾞ付のは　対象とする
            if(item.Name1__c.contains('計器用変圧器(VT、PT)ﾋｭｰｽﾞ付')){
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
        // 電圧 相 負担         価格
        //             本体 数量 引出有 数量
        List<BodyCell> headerRow1 = new List<BodyCell>();//電圧 相 負担 価格       
        headerRow1.add(setCell('電圧',null,2,false));
        headerRow1.add(setCell('相',null,2,false));
        headerRow1.add(setCell('負担',null,2,false));
        headerRow1.add(setCell('価格',4,null,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        List<BodyCell> headerRow2 = new List<BodyCell>();//本体 数量 引出有 数量      
        headerRow2.add(setCell('本体',null,null,false));
        headerRow2.add(setCell('数量',null,null,false));
        headerRow2.add(setCell('引出有',null,null,false));
        headerRow2.add(setCell('数量',null,null,false));
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row2);

        //Body の設定
        for(String name4 : instrumentTransformerName4){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name4,null,2,false));//電圧
            for (String name3 : instrumentTransformerName3) {
                List<String> name3Tmp = name3.split('相');
                bodyRow.add(setCell((name3Tmp.get(0)=='3'?name3Tmp.get(0)+'（2個1組）':name3Tmp.get(0)),null,null,false));//相
                bodyRow.add(setCell(name3Tmp.get(1),null,null,false));//負担
                for(String name2 : instrumentTransformerName2){
                    PricingTable__c priceObj = instrumentTransformerInfoMap.get(name4 +'@@' + name3 + '@@' + name2);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                    }else {
                        bodyRow.add(setCell('―',null,null,false));//価格セル
                        bodyRow.add(setCell('―',null,null,false));//空白
                    }
                }
                
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>{
            '注： 3.3KVの場合も同価格。',
            '注： （PTT）試験用端子は含む。',
            '注：3相→1組（2個）価格。'
        };

        //タイトルの設定
        instrumentTransformerTable.secTitle = '計器用変圧器(VT、PT)ﾋｭｰｽﾞ付';//タイトル
        instrumentTransformerTable.headerList = headerList;//ヘッダ
        instrumentTransformerTable.bodyList = bodyList;//ボディー
        instrumentTransformerTable.noteList = noteList;//注＊
        return instrumentTransformerTable;
    }

    //避雷器(LA) 一覧表示内容の設定
    private static CustomTable setLightningArresterTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable lightningArresterTable = new CustomTable();
        Set<String> lightningArresterName1 = new Set<String>();//名称１
        Map<String,Set<String>> lightningArresterName2 = new Map<String,Set<String>>();//名称2+名称３
        Map<String, PricingTable__c> lightningArresterInfoMap = new Map<String, PricingTable__c>();//避雷器(LA)情報
        for (PricingTable__c item : priceList) {
            //仕様１が避雷器(LA)含むのは　対象とする
            if(item.Name1__c.contains('避雷器(LA)')){
                String key = item.Name1__c +'@@' + item.Name2__c + '@@' + item.Name3__c;//キー
                lightningArresterName1.add(item.Name1__c);
                Set<String> name3List=lightningArresterName2.get(item.Name2__c);
                if (name3List==null) {
                    name3List = new Set<String>();
                    lightningArresterName2.put(item.Name2__c,name3List);
                }
                name3List.add(item.Name3__c);
                lightningArresterInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();//電圧 放電電流 価格        
        headerRow1.add(setCell('電圧',null,2,false));
        headerRow1.add(setCell('放電電流',null,2,false));
        headerRow1.add(setCell('価格',4,null,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        List<BodyCell> headerRow2 = new List<BodyCell>();//本体 数量 引出有 数量      
        headerRow2.add(setCell('本体',null,null,false));
        headerRow2.add(setCell('数量',null,null,false));
        headerRow2.add(setCell('引出有',null,null,false));
        headerRow2.add(setCell('数量',null,null,false));
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row2);

        //Body の設定
        for(String name1 : lightningArresterName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell('8.4KV',null,2,false));//電圧
            for (String name2 : lightningArresterName2.keyset()) {
                String name2Tmp = name2.remove('放電電流：');
                bodyRow.add(setCell(name2Tmp,null,null,false));//放電電流：
                Set<String> name3List=lightningArresterName2.get(name2);
                for(String name3 : name3List){
                    PricingTable__c priceObj = lightningArresterInfoMap.get(name1 +'@@' + name2 + '@@' + name3);
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                    }else {
                        bodyRow.add(setCell('―',null,null,false));//価格セル
                        bodyRow.add(setCell('―',null,null,false));//空白
                    }
                }
                
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>{
            '注：電圧4.2KVの場合も同価格。',
            '注：3相1組価格。'
        };

        //タイトルの設定
        lightningArresterTable.secTitle = '避雷器(LA)';//タイトル
        lightningArresterTable.headerList = headerList;//ヘッダ
        lightningArresterTable.bodyList = bodyList;//ボディー
        lightningArresterTable.noteList = noteList;//注＊
        return lightningArresterTable;
    }

   //ﾌﾟﾗｲﾏﾘｰｶｯﾄｱｳﾄｽｲｯﾁ（PCS） 一覧表示内容の設定
   private static CustomTable setPrimerCutoutSwitchTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable primerCutoutSwitchTable = new CustomTable();
        Set<String> primerCutoutSwitchName1 = new Set<String>();//名称１
        Set<String> primerCutoutSwitchName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> primerCutoutSwitchInfoMap = new Map<String, PricingTable__c>();//ﾌﾟﾗｲﾏﾘｰｶｯﾄｱｳﾄｽｲｯﾁ（PCS） 情報
        for (PricingTable__c item : priceList) {
            //仕様１がﾌﾟﾗｲﾏﾘｰｶｯﾄｱｳﾄｽｲｯﾁ（PCS）のは　対象とする
            if(item.Name1__c == 'ﾌﾟﾗｲﾏﾘｶｯﾄｱｳﾄｽｲｯﾁ(PCS)'){
                String key = item.Name1__c +'@@' + item.Name2__c;//キー
                primerCutoutSwitchName1.add(item.Name1__c);
                primerCutoutSwitchName2.add(item.Name2__c);
                primerCutoutSwitchInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();//仕様 価格 数量
        headerRow1.add(setCell('仕様',null,null,false));
        headerRow1.add(setCell('価格',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        //Body の設定
        Boolean isFirst = true;
        for(String name1 : primerCutoutSwitchName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name2 : primerCutoutSwitchName2) {
                PricingTable__c priceObj = primerCutoutSwitchInfoMap.get(name1 +'@@' + name2);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2,null,null,false));//一次電流
                    bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                }else {
                    bodyRow.add(setCell(name2,null,null,false));//一次電流
                    bodyRow.add(setCell('―',null,null,false));//価格セル
                    bodyRow.add(setCell('―',null,null,false));//空白
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
        primerCutoutSwitchTable.secTitle = 'ﾌﾟﾗｲﾏﾘｶｯﾄｱｳﾄｽｲｯﾁ(PCS)';//タイトル
        primerCutoutSwitchTable.headerList = headerList;//ヘッダ
        primerCutoutSwitchTable.bodyList = bodyList;//ボディー
        primerCutoutSwitchTable.noteList = noteList;//注＊
        return primerCutoutSwitchTable;
    }

    //零相変流器（ZCT）：高圧一覧表示内容の設定
    private static CustomTable setZeroPhaseCurrentTransformerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable zeroPhaseCurrentTransformerTable = new CustomTable();
        Set<String> zeroPhaseCurrentTransformerName1 = new Set<String>();//名称１
        Set<String> zeroPhaseCurrentTransformerName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> zeroPhaseCurrentTransformerInfoMap = new Map<String, PricingTable__c>();//零相変流器（ZCT）：高圧 情報
        for (PricingTable__c item : priceList) {
            //仕様１が零相変流器(ZCT)のは　対象とする
            if(item.Name1__c == '零相変流器(ZCT)'){
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
        headerRow1.add(setCell('過電流倍数',null,null,false));
        headerRow1.add(setCell('2,000 以上',null,null,false));
        headerRow1.add(setCell('数量',null,2,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        List<BodyCell> headerRow2 = new List<BodyCell>();//一次電流 価格
        headerRow2.add(setCell('一次電流',null,null,false));
        headerRow2.add(setCell('価格',null,null,false));
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row2);


        //Body の設定
        for(String name1 : zeroPhaseCurrentTransformerName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name2 : zeroPhaseCurrentTransformerName2) {
                PricingTable__c priceObj = zeroPhaseCurrentTransformerInfoMap.get(name1 +'@@' + name2);
                String name2Tmp = name2.remove('一次電流:');
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2Tmp,null,null,false));//一次電流
                    bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                }else {
                    bodyRow.add(setCell(name2Tmp,null,null,false));//一次電流
                    bodyRow.add(setCell('―',null,null,false));//価格セル
                    bodyRow.add(setCell('―',null,null,false));//空白
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
        zeroPhaseCurrentTransformerTable.secTitle = '零相変流器（ZCT）：高圧';//タイトル
        zeroPhaseCurrentTransformerTable.headerList = headerList;//ヘッダ
        zeroPhaseCurrentTransformerTable.bodyList = bodyList;//ボディー
        zeroPhaseCurrentTransformerTable.noteList = noteList;//注＊
        return zeroPhaseCurrentTransformerTable;
    }

    //取引用計器箱(日東工業)一覧表示内容の設定
//TODO　⇒　仮設定です。
    private static CustomTable setInstrumentBoxTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable instrumentBoxTable = new CustomTable();

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報
        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();//仕様  価格 数量

        headerRow1.add(setCell('仕様',null,null,false));
        headerRow1.add(setCell('価格',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        BodyRow row = new BodyRow();
        List<BodyCell> bodyRow  = new List<BodyCell>();
        bodyRow.add(setCell('WHM×1個収納用 ，300W×800H×200D',null,null,false));//価定格電流
        bodyRow.add(setCell('70',null,null,false));//価格
        bodyRow.add(setCell(new QuantityObject(),null,null,true));//入力セル
        row.cellList = bodyRow;
        bodyList.add(row);


        BodyRow row2 = new BodyRow();
        List<BodyCell> bodyRow2  = new List<BodyCell>();
        bodyRow2.add(setCell('WHM×2個収納用 ，500W×1000H×200D',null,null,false));//価定格電流
        bodyRow2.add(setCell('88',null,null,false));//価格
        bodyRow2.add(setCell(new QuantityObject(),null,null,true));//入力セル
        row2.cellList = bodyRow2;
        bodyList.add(row2);

        //注＊　の設定
        List<String> noteList = new List<String>{'注：上記価格は箱のみ。(WHMは含まず。)'};
        //タイトルの設定
        instrumentBoxTable.secTitle = '取引用計器箱(日東工業)';//タイトル
        instrumentBoxTable.comment = '参考';//コメント
        instrumentBoxTable.headerList = headerList;//ヘッダ
        instrumentBoxTable.bodyList = bodyList;//ボディー
        instrumentBoxTable.noteList = noteList;//注＊
        return instrumentBoxTable;
    }

    //気中負荷開閉器(PAS(戸上電機)) 一覧表示内容の設定
    private static CustomTable setAirLoadSwitchTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable airLoadSwitchTable = new CustomTable();
        Set<String> airLoadSwitchName1 = new Set<String>();//名称１
        Set<String> airLoadSwitchName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> airLoadSwitchInfoMap = new Map<String, PricingTable__c>();//気中負荷開閉器(PAS(戸上電機)) 情報
        for (PricingTable__c item : priceList) {
            //仕様１が気中負荷開閉器(PAS)のは　対象とする
            if(item.Name1__c == '気中負荷開閉器(PAS)'){
                String key = item.Name1__c +'@@' + item.Name2__c;//キー
                airLoadSwitchName1.add(item.Name1__c);
                airLoadSwitchName2.add(item.Name2__c);
                airLoadSwitchInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();//定格電流    価  格    数量
        headerRow1.add(setCell('定格電流',null,null,false));
        headerRow1.add(setCell('価格',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        headerRow1.add(setCell('仕様(戸上電機：型式)',null,null,false));
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
                String name2Tmp = name2.remove('定格電流：');
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2Tmp,null,null,false));//価定格電流
                    bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                    if(isFirst)bodyRow.add(setCell('制御電源・ｱﾚｽﾀ内蔵形 \n(方向性・SUS・重耐塩仕様)\nKLT-P-D2N10LT',null,airLoadSwitchName2.size(),false));//入力セル
                }else {
                    bodyRow.add(setCell(name2Tmp,null,null,false));//価定格電流
                    bodyRow.add(setCell('―',null,null,false));//価格セル
                    bodyRow.add(setCell('―',null,null,false));//空白
                    if(isFirst)bodyRow.add(setCell('制御電源・ｱﾚｽﾀ内蔵形 \n(方向性・SUS・重耐塩仕様)\nKLT-P-D2N10LT',null,airLoadSwitchName2.size(),false));//入力セル
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
        airLoadSwitchTable.secTitle = '気中負荷開閉器(PAS(戸上電機))';//タイトル
        airLoadSwitchTable.comment = '参考';
        airLoadSwitchTable.headerList = headerList;//ヘッダ
        airLoadSwitchTable.bodyList = bodyList;//ボディー
        airLoadSwitchTable.noteList = noteList;//注＊
        return airLoadSwitchTable;
    }

    //ﾋｭｰｽﾞ付負荷開閉器（LBS） 一覧表示内容の設定
    private static CustomTable setFuseLoadSwitchTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable fuseLoadSwitchTable = new CustomTable();
        Set<String> fuseLoadSwitchName1 = new Set<String>();//名称１
        Map<String,Set<String>> fuseLoadSwitchName2 = new Map<String,Set<String>>();//名称2+名称３
        Map<String, PricingTable__c> fuseLoadSwitchInfoMap = new Map<String, PricingTable__c>();//真空遮断器(VCB)情報
        for (PricingTable__c item : priceList) {
            //仕様１がﾋｭｰｽﾞ付負荷開閉器(LBS)のは　対象とする
            if(item.Name1__c == 'ﾋｭｰｽﾞ付負荷開閉器(LBS)'){
                String key = item.Name1__c +'@@' + item.Name2__c + '@@' + item.Name3__c;//キー
                fuseLoadSwitchName1.add(item.Name1__c);
                Set<String> name3List=fuseLoadSwitchName2.get(item.Name2__c);
                if (name3List==null) {
                    name3List = new Set<String>();
                    fuseLoadSwitchName2.put(item.Name2__c,name3List);
                }
                name3List.add(item.Name3__c);
                fuseLoadSwitchInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();//定格電流    価  格    数量
        headerRow1.add(setCell('電  流',null,null,false));


        Boolean isFirst = true;
        //Body の設定
        for(String name1 : fuseLoadSwitchName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name2 : fuseLoadSwitchName2.keyset()) {

                bodyRow.add(setCell(name2,null,null,false));//電  流

                Set<String> name3List=fuseLoadSwitchName2.get(name2);
                for(String name3 : name3List){
                    PricingTable__c priceObj = fuseLoadSwitchInfoMap.get(name1 +'@@' + name2 + '@@' + name3);
                    if (isFirst) {
                        headerRow1.add(setCell(name3,null,null,false));
                        headerRow1.add(setCell('数量',null,null,false));
                    }
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                    }else {
                        bodyRow.add(setCell('―',null,null,false));//価格セル
                        bodyRow.add(setCell('―',null,null,false));//空白
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
        fuseLoadSwitchTable.secTitle = 'ﾋｭｰｽﾞ付負荷開閉器（LBS）';//タイトル
        fuseLoadSwitchTable.headerList = headerList;//ヘッダ
        fuseLoadSwitchTable.bodyList = bodyList;//ボディー
        fuseLoadSwitchTable.noteList = noteList;//注＊
        return fuseLoadSwitchTable;
    }

    //屋外用高圧交流ガス負荷開閉器 一覧表示内容の設定
    private static CustomTable setGasLoadSwitchTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable gasLoadSwitchTable = new CustomTable();
        Set<String> gasLoadSwitchName1 = new Set<String>();//名称１
        Set<String> gasLoadSwitchName3 = new Set<String>();//名称３
        Map<String, PricingTable__c> gasLoadSwitchInfoMap = new Map<String, PricingTable__c>();//真空遮断器(VCB)情報
        for (PricingTable__c item : priceList) {
            //仕様１が屋外用高圧交流ｶﾞｽ負荷開閉器のは　対象とする
            if(item.Name1__c == '屋外用高圧交流ｶﾞｽ負荷開閉器'){
                String key = item.Name1__c +'@@' + item.Name3__c;//キー
                gasLoadSwitchName1.add(item.Name1__c);
                gasLoadSwitchName3.add(item.Name3__c);
                gasLoadSwitchInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();//定格電流    価  格    数量
        headerRow1.add(setCell('定格電流',null,null,false));
        headerRow1.add(setCell('価格',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);


        //Body の設定
        for(String name1 : gasLoadSwitchName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name3 : gasLoadSwitchName3) {
                PricingTable__c priceObj = gasLoadSwitchInfoMap.get(name1 +'@@' + name3);
                String name3Tmp = name3.remove('定格電流:');
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name3Tmp,null,null,false));//価定格電流
                    bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                    bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                }else {
                    bodyRow.add(setCell(name3Tmp,null,null,false));//価定格電流
                    bodyRow.add(setCell('―',null,null,false));//価格セル
                    bodyRow.add(setCell('―',null,null,false));//空白
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
        gasLoadSwitchTable.secTitle = '屋外用高圧交流ｶﾞｽ負荷開閉器';//タイトル
        gasLoadSwitchTable.headerList = headerList;//ヘッダ
        gasLoadSwitchTable.bodyList = bodyList;//ボディー
        gasLoadSwitchTable.noteList = noteList;//注＊
        return gasLoadSwitchTable;
    }

    //真空遮断器(VCB) 一覧表示内容の設定
    private static CustomTable setVcBreakerTable(List<PricingTable__c> priceList, Map<Id, Detail__c> detailMap){
        CustomTable vcBreakerTable = new CustomTable();
        Set<String> vcBreakerName1 = new Set<String>();//名称１
        Map<String,Set<String>> vcBreakerName2 = new Map<String,Set<String>>();//名称2＋名称３
        Map<String, PricingTable__c> vcBreakerInfoMap = new Map<String, PricingTable__c>();//真空遮断器(VCB)情報
        for (PricingTable__c item : priceList) {
            //仕様１が真空遮断器(VCB) 7.2/3.6kVのは　対象とする
            if(item.RecordType.DeveloperName == 'Detail' && item.Name1__c == '真空遮断器(VCB) 7.2/3.6kV'){
                String key = item.Name1__c +'@@' + item.Name2__c + '@@' + item.Name3__c;//キー
                vcBreakerName1.add(item.Name1__c);
                Set<String> name3List=vcBreakerName2.get(item.Name2__c);
                if (name3List==null) {
                    name3List = new Set<String>();
                    vcBreakerName2.put(item.Name2__c,name3List);
                }
                name3List.add(item.Name3__c);
                vcBreakerInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerRow1 = new List<BodyCell>();//電圧        遮断電流        定格電流Ａ    価格    数量
        headerRow1.add(setCell('電圧',null,null,false));
        headerRow1.add(setCell('遮断電流',null,null,false));
        headerRow1.add(setCell('定格電流',null,null,false));
        headerRow1.add(setCell('価格',null,null,false));
        headerRow1.add(setCell('数量',null,null,false));
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        headerList.add(row1);

        Map<String,String> fixedWord = new Map<String,String>{
                            '12.5kA'=>'(VF-13DM-BA)',
                            '20/25kA'=>'(VF-20DDM-BA)',
                            '31.5kA'=>'(VF-32DM-BA)',
                            '40kA'=>'(VF-40DM-BA)'};
        //Body の設定
        for(String name1 : vcBreakerName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            String name1Tmp = name1.remove('真空遮断器(VCB) ');
            bodyRow.add(setCell(name1Tmp,null,12,false));//電 圧
            for (String name2 : vcBreakerName2.keyset()){
                String name2Tmp = name2.remove('遮断電流：');
                Set<String> name3 = vcBreakerName2.get(name2);
                bodyRow.add(setCell(name2Tmp+'\n'+fixedWord.get(name2Tmp),null,name3.size(),false));//遮断電流
                for (String val : name3) {
                    PricingTable__c priceObj = vcBreakerInfoMap.get(name1 +'@@' + name2 + '@@' +val);
                    String name3Tmp = val.remove('定格電流:');
                    if (priceObj!=null) {
                        Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(name3Tmp,null,null,false));//価定格電流
                        bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                    }else {
                        bodyRow.add(setCell(name3Tmp,null,null,false));//価定格電流
                        bodyRow.add(setCell('―',null,null,false));//価格セル
                        bodyRow.add(setCell('―',null,null,false));//空白
                    }
                    row.cellList = bodyRow;
                    bodyList.add(row);
                    row = new BodyRow();
                    bodyRow  = new List<BodyCell>();
                }
            }
        }

        //注＊　の設定
        List<String> noteList = new List<String>{
                                    '注１：引出装置付き'};

        //タイトルの設定
        vcBreakerTable.secTitle = '真空遮断器(VCB)';//真空遮断器(VCB)　タイトル
        vcBreakerTable.headerList = headerList;//真空遮断器(VCB)） ヘッダ
        vcBreakerTable.bodyList = bodyList;//真空遮断器(VCB) ボディー
        vcBreakerTable.noteList = noteList;//真空遮断器(VCB) 注＊
        return vcBreakerTable;
    }

    //箱体（高圧受配電盤  筐体） 一覧表示内容の設定
    private static CustomTable setBoxTable(List<PricingTable__c> priceList, String tableKey, Map<Id, Detail__c> detailMap){
        CustomTable boxTable = new CustomTable();
        Set<String> boxName1 = new Set<String>();//名称１
        Map<String,Set<String>> boxName2 = new Map<String,Set<String>>();//名称2＋名称３
        Map<String, PricingTable__c> boxInfoMap = new Map<String, PricingTable__c>();//箱体（高圧受配電盤  筐体）情報
        for (PricingTable__c item : priceList) {
            if ((tableKey == '箱体（高圧受配電盤  筐体）' && item.RecordType.DeveloperName == 'Chassis' && item.Name2__c != 'MS-S')
             || (tableKey != '箱体（高圧受配電盤  筐体）' && item.Name1__c.contains(tableKey))){
                String name1 = (tableKey=='断路器(DS)'?item.Name1__c.remove('断路器(DS)　'):item.Name1__c);
                String key = name1+'@@' + item.Name2__c + '@@' + item.Name3__c;//キー
                boxName1.add(name1);
                Set<String> name3List=boxName2.get(item.Name2__c);
                if (name3List==null) {
                    name3List = new Set<String>();
                    boxName2.put(item.Name2__c,name3List);
                }
                name3List.add(item.Name3__c);
                boxInfoMap.put(key,item);//データをキーで格納

            }
        }

        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //箱体 の場合　1行目：用途 引込及び補助 遮断器収納    
        List<BodyCell> headerRow1 = new List<BodyCell>();    
        String cell1 = (tableKey == '箱体（高圧受配電盤  筐体）'?'用途':'仕様');            
        headerRow1.add(setCell(cell1,null,null,false));
        //箱体 の場合　２行目：母線電流    MOF収納    数量    MOF無    数量    １台    数量    ２台（２段積）    数量    ３台（３段積）    数量
        List<BodyCell> headerRow2 = new List<BodyCell>();
        String cell2 = (tableKey == '箱体（高圧受配電盤  筐体）'?'母線電流':'定格電流');    
        headerRow2.add(setCell('母線電流',null,null,false));
        //キー単位でヘッダを設定
        for (String name2 : boxName2.keyset()){
            Set<String> name3 = boxName2.get(name2);
            headerRow1.add(setCell(name2, name3.size() * 2,null,false));
            for (String val : name3) {
                String newval = val.replace('<通常>','＊');
                headerRow2.add(setCell(newval,null,null,false));
                headerRow2.add(setCell('数量',null,null,false));
            }
        }
        BodyRow row1 = new BodyRow();
        row1.cellList=headerRow1;
        BodyRow row2 = new BodyRow();
        row2.cellList=headerRow2;
        headerList.add(row1);
        headerList.add(row2);


        //Body の設定
        for(String name1 : boxName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name1,null,null,false));//母線電流
            for (String name2 : boxName2.keyset()){
                Set<String> name3 = boxName2.get(name2);
                for (String val : name3) {
                    PricingTable__c priceObj = boxInfoMap.get(name1 +'@@' + name2 + '@@' +val);
                    if (priceObj!=null) {
                        // priceObj.Price__c = getPriceBySearchOption(searchOption, priceObj.Price__c);
                        Decimal price = (priceObj.Price__c==null?0:priceObj.Price__c);
                        bodyRow.add(setCell(price.format(),null,null,false));//価格セル
                        bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true));//入力セル
                    }else {
                        bodyRow.add(setCell('―',null,null,false));//価格セル
                        bodyRow.add(setCell('―',null,null,false));//空白
                    }
                }
            }
            row.cellList = bodyRow;
            bodyList.add(row);
        }

        //タイトルの設定
        boxTable.secTitle = tableKey;//タイトル
        boxTable.headerList = headerList;// ヘッダ
        boxTable.bodyList = bodyList;// ボディー
        // boxTable.noteList = noteList;// 注＊
        return boxTable;
    }

    @AuraEnabled
    /*
     *内訳入力B_特高ＴＲ  画面情報を取得
     */
    Public static String getInitScreenInfo(Boolean isInit,
                                        String deviceId,
                                        String screenType,
                                        String priceCondition1,
                                        String priceCondition2,
                                        String priceCondition3,
                                        String priceCondition4,
                                        String priceCondition5){

        ScreenInfo info = new ScreenInfo();
        Device__c deveice;
        Detail__c priceTable;
        Detail__c optPrice;
        String powerFrequency = null;
        Boolean isHaveOpt=false;//GIS直結/収納盤
        Boolean isHaveOnload=false;//ｵﾝﾛｰﾄﾞﾀｯﾌﾟﾁｪﾝｼﾞｬｰ
        if (String.isNotBlank(deviceId)) {
            deveice = [SELECT Id, toLabel(MajorClassification__c),
                            MinorClassification__c,
                            Quote__r.PowerFrequency__c
                            ,
                            (SELECT Id,Name,UnitPrice__c,PricingTableUniqueKey__c
                             FROM Details__r
                             WHERE PricingTableUniqueKey__c like '%特高TR%')
                        FROM Device__c WHERE Id =:deviceId LIMIT 1];
            if (String.isNotBlank(deveice.Quote__r.PowerFrequency__c)) powerFrequency = deveice.Quote__r.PowerFrequency__c;
            if (deveice.MajorClassification__c != '変圧器') {
                info.errorMsg = '当画面の利用はできません！';
                return JSON.serialize(info);
            }
            List<Detail__c> pList =deveice.Details__r;
            if (pList!=null && pList.size()>0) {
                //初期表示データを確定
                for (Detail__c tmp : pList) {
                    if (tmp.PricingTableUniqueKey__c.contains('GIS直結')
                        || tmp.PricingTableUniqueKey__c.contains('収納盤')) 
                        {
                            isHaveOpt = true;
                            continue;//オプションデータを対象外
                        }
                        if (tmp.PricingTableUniqueKey__c.contains('ｵﾝﾛｰﾄﾞﾀｯﾌﾟﾁｪﾝｼﾞｬｰ')) 
                        {
                            isHaveOnload = true;
                            continue;//ｵﾝﾛｰﾄﾞﾀｯﾌﾟﾁｪﾝｼﾞｬｰデータを対象外
                        }
                        priceTable = tmp;
                        // break;
                }
                // if (priceTable.name.contains('GIS直結あり')
                //     || priceTable.name.contains('収納盤あり')) {
                if (isHaveOpt){
                    //オプションデータを確定
                    for (Detail__c tmp : pList) {
                        if ((tmp.PricingTableUniqueKey__c.contains('GIS直結')
                            || tmp.PricingTableUniqueKey__c.contains('収納盤'))
                            ) {
                                String priceKey = tmp.PricingTableUniqueKey__c.remove(' GIS直結').remove(' 収納盤');
                                if (priceKey == priceTable.PricingTableUniqueKey__c){
                                    optPrice=tmp;
                                }
                            }
                    }
                }
            } 
            
        }

        //6桁
        //1桁目：特高TR 油入(1) 特高TR ﾓｰﾙﾄﾞ(2) 特高TRｶﾞｽ(3)
        //2桁目：屋内(1)  屋外(2) 選択なし(0)
        //3桁目：ｽﾎﾟｯﾄ(1)  選択なし(0)
        //4桁目：二次低圧(1)  選択なし(0)
        //5桁目：60/13.8kV(1)  20/13.8kV屋外(2) 選択なし(0)
        //6桁目：GIS直結／収納盤(1)  選択なし(0)
        String dataCondition = '';

        //GIS直結／収納盤の条件
        String optCondition = '';
        //初期　かつ　既存ありの場合、
        if (isInit && priceTable!=null && String.isNotBlank(priceTable.PricingTableUniqueKey__c)) {
            String uniqueKey = priceTable.PricingTableUniqueKey__c;
            PricingTable__c pricingTable = [SELECT Id,ConditionForSearchformula__c FROM PricingTable__c WHERE UniqueKey__c=:uniqueKey limit 1];

            dataCondition = pricingTable.ConditionForSearchformula__c;//既存データ表示
            for(Integer i=0;i<dataCondition.length();i++){
                if(i==0)info.screenType=dataCondition.subString(i,i+1);
                if(i==1)info.priceCondition1=dataCondition.subString(i,i+1);
                if(i==2)info.priceCondition4=dataCondition.subString(i,i+1);
                if(i==3){
                    if (dataCondition.subString(i,i+1)=='1') {
                        info.priceCondition2='9';
                        break;
                    }
                }else if (i==4) {
                    if (dataCondition.subString(i,i+1)=='1' || dataCondition.subString(i,i+1)=='2') {
                        info.priceCondition2=dataCondition.subString(i,i+1);
                        break;
                    }
                }
            }
            String optName = 'GIS直結';
            // if (String.isNotBlank(priceTable.Name)&&
            //     (priceTable.Name.contains('GIS直結')
            //     || priceTable.Name.contains('収納盤'))) {
            if (optPrice!=null){
                info.priceCondition5='1';
                priceCondition5 = '1';
            }
            // if (String.isNotBlank(priceTable.Name)&&
            //     priceTable.Name.contains('ｵﾝﾛｰﾄﾞﾀｯﾌﾟﾁｪﾝｼﾞｬｰ')) {
//TODO
            If(isHaveOnload){
                info.priceCondition3='1';
                priceCondition3 = '1';
            }
            if(dataCondition.startsWith('2')){
                info.screenType = '2';
                optCondition = '200001';
                optName='収納盤';
            }else if(dataCondition.startsWith('1')){
                info.screenType = '1';
                optCondition = '100001';
            }else if(dataCondition.startsWith('3')){
                info.screenType = '3';
                optCondition = '300001';
            }

            info.inputedId = pricingTable.Id;
            info.displayTotal = priceTable.UnitPrice__c + (optPrice!=null?optPrice.UnitPrice__c:0);
            info.displayCondition = priceTable.Name+(optPrice!=null?(optName+'あり'):'')+(isHaveOnload?'ｵﾝﾛｰﾄﾞﾀｯﾌﾟﾁｪﾝｼﾞｬｰあり':'');
            
        }else {
            dataCondition = dataCondition + screenType;//1桁目
            dataCondition = dataCondition + (String.isBlank(priceCondition1)?'0':priceCondition1);//設置場所
            dataCondition = dataCondition + (String.isBlank(priceCondition4)?'0':priceCondition4);//3桁目
            dataCondition = dataCondition + (String.isNotBlank(priceCondition2)&&priceCondition2=='9'?'1':'0');//4桁目
            dataCondition = dataCondition + (String.isNotBlank(priceCondition2)&&priceCondition2!='9'?priceCondition2:'0');//5桁目
            dataCondition = dataCondition + '0';//6桁目 データ取得の場合　固定'0'

            optCondition = screenType + '00001';
        }

        system.debug('dataCondition::'+dataCondition);
        system.debug('optCondition::'+optCondition);
        List<PricingTable__c> chassisList = [SELECT Id, Name, 
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
                                            WC__c, 
                                            Price__c, 
                                            //Weight__c, 
                                            ConditionForSearchformula__c,
                                            Note__c
                                        FROM PricingTable__c
                                        WHERE 
                                            (ConditionForSearchformula__c = :dataCondition
                                            OR ConditionForSearchformula__c = :optCondition)
                                            AND RecordType.DeveloperName = 'Chassis'
                                        ORDER BY CategoryCode__c,Specification1DisplayOrder__c,
                                                        Specification2DisplayOrder__c,
                                                        Specification3DisplayOrder__c,
                                                        Specification4DisplayOrder__c desc,
                                                        Specification5DisplayOrder__c
                                    ];

        String specifi1;
        //周波数 50hz,60hz
        Set<String> categoryList = new Set<String>();
        //容量 1000,1200～30000
        Set<String> specifi2List = new Set<String>();
        //相数 3Φ
        String specifi3;
        //一次電圧(V) 22000V,33000V,66000V,77000V
        Set<String> specifi4List = new Set<String>();
        //二次電圧(V) 6600V
        String specifi5;

        Map<String , PricingTable__c> chassisMap = new Map<String , PricingTable__c>();
        Map<String , PricingTable__c> optionsMap = new Map<String , PricingTable__c>();
        for (PricingTable__c item : chassisList) {
            String key=item.CategoryCode__c+item.Name2__c+item.Name4__c;

            //GIS直結、収納盤　のデータ
            if (!item.ConditionForSearchformula__c.endsWith('0')) {
                optionsMap.put(key,item);
                continue;
            }

            if (String.isBlank(specifi1)) specifi1=item.Name1__c;
            if (String.isBlank(specifi3)) specifi3=item.Name3__c;
            if (String.isBlank(specifi5)) specifi5=item.Name5__c;
            categoryList.add(item.CategoryCode__c);
            specifi2List.add(item.Name2__c);
            specifi4List.add(item.Name4__c);
            chassisMap.put(key,item);
        }

        if (chassisMap.size()==0) {
            info.isNodata=true;
        }else {
            info.isNodata=false;
        }

        List<BodyRow> bodyList = new List<BodyRow>();
        List<BodyRow> headerList = new List<BodyRow>();

        //
        Boolean isSetHeader = true;//一回のみ設定
        for (String specifi2 : specifi2List) {
            List<BodyCell> cellList = new List<BodyCell>();
            //ヘッダー情報設定
            if (isSetHeader) {
                List<BodyCell> headerRow1 = new List<BodyCell>();
                List<BodyCell> headerRow2 = new List<BodyCell>();
                List<BodyCell> headerRow3 = new List<BodyCell>();
                List<BodyCell> headerRow4 = new List<BodyCell>();
                headerRow1.add(setCell('容量',null,4,false));
                headerRow1.add(setCell('一次電圧(V) ',null,null,false));
                headerRow2.add(setCell('二次電圧(V) ',null,null,false));
                headerRow3.add(setCell('相数',null,null,false));
                headerRow4.add(setCell('周波数',null,null,false));
                for (String specifi4 : specifi4List) {
                    Integer rowSpanCnt = 5;
                    if (String.isNotBlank(powerFrequency)) rowSpanCnt=3;
                    headerRow1.add(setCell(specifi4,rowSpanCnt,null,false));
                    headerRow2.add(setCell(specifi5,rowSpanCnt,null,false));
                    headerRow3.add(setCell(specifi3,rowSpanCnt,null,false));
                    for (String category : categoryList) {
                        String strCategory= (category=='01'?'50Hz':'60Hz');
                        if (String.isNotBlank(powerFrequency) && strCategory!=powerFrequency) continue;
                        headerRow4.add(setCell(strCategory,null,null,false));//価格セル
                        headerRow4.add(setCell(null,null,null,true));//入力セル
                    }
                    String tmp= 'GIS直結';
                    if (screenType=='2') {//特高TR ﾓｰﾙﾄﾞ標準
                        tmp = '収納盤';
                    }
                    headerRow4.add(setCell(tmp,null,null,false));//GIS直結セル
                }
                BodyRow row1 = new BodyRow();
                row1.cellList=headerRow1;
                BodyRow row2 = new BodyRow();
                row2.cellList=headerRow2;
                BodyRow row3 = new BodyRow();
                row3.cellList=headerRow3;
                BodyRow row4 = new BodyRow();
                row4.cellList=headerRow4;
                headerList.add(row1);
                headerList.add(row2);
                headerList.add(row3);
                headerList.add(row4);
                info.headerList = headerList;
                isSetHeader = false;
            }
            //データ情報設定
            //１列目
            cellList.add(setCell(Decimal.valueOf(specifi2).format() ,2,null,false));
            //１列目の以外　データ列
            for (String specifi4 : specifi4List) {
                Boolean isDone = false;
                String key='';
                Decimal dec;
                for (String category : categoryList) {
                    key = category + specifi2 +specifi4;
                    String strCategory= (category=='01'?'50Hz':'60Hz');
                    if (String.isNotBlank(powerFrequency) && strCategory!=powerFrequency) continue;
                    PricingTable__c item = chassisMap.get(key);

                    PricingTable__c option = optionsMap.get(key);
                    dec = option==null||option.Price__c == null?0:option.Price__c;//GIS直結単価

                    if (item!=null) {
                        isDone = true;
                        Decimal price =  (item.Price__c==null?0:item.Price__c);
                        String Name1 = item.CategoryName__c;
                        cellList.add(setCell(price.format(),null,null,false));//価格セル
                        //GIS直結の場合、本体価格＋GIS直結価格で表示
                        if (String.isNotBlank(priceCondition5) && priceCondition5=='1') {
                            price = price+dec;
                            String tmp= 'GIS直結';
                            if (screenType=='2') {//特高TR ﾓｰﾙﾄﾞ標準
                                tmp = '収納盤';
                            }
                            Name1 = Name1 + ' ' + tmp + 'あり';
                        }
                        //OLTC(オンロードタップチェンジャー)付きの場合、本体価格＋22,000千円加算で表示
                        if (String.isNotBlank(priceCondition3) && priceCondition3=='1') {
                            price = price+22000000;
                            Name1 = Name1 + ' ' + 'ｵﾝﾛｰﾄﾞﾀｯﾌﾟﾁｪﾝｼﾞｬｰあり';
                        }
                        Map<String,Object> cellItem = new Map<String,Object>();
                        cellItem.put('Id',item.Id);//Id
                        cellItem.put('Price__c',price);//単価
                        cellItem.put('Name1__c',Name1);//仕様
                        // cellItem.put('isChecked',(isInit&&info.inputedId==item.Id?9:null));//チェックボックス表示制御
                        cellItem.put('isChecked',isInit&&info.inputedId==item.Id);

                        cellList.add(setCell(cellItem,null,null,true));//入力セル
                    }else {
                        cellList.add(setCell('―',null,null,false));//価格セル
                        cellList.add(setCell('―',null,null,false));//空白
                    }

                }

                cellList.add(setCell(isDone?dec.format():'―',null,null,false));//GIS直結セル
            }

            BodyRow row = new BodyRow();
            row.cellList = cellList;
            // System.debug(cellList);
            bodyList.add(row);
            
        }
        // System.debug(bodyList);
        info.bodyList = bodyList;
        System.debug(bodyList);
        return JSON.serialize(info);
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

    @AuraEnabled(Cacheable=false)
    Public static String submitDetails(String deviceId,
                                            String rId,
                                            Decimal cnt,
                                            String title){
        try{

            List<Detail__c> dtList = [SELECT Id
                                        FROM Detail__c
                                       WHERE Device__c=:deviceId
                                        AND PricingTableUniqueKey__c like '%特高TR%'];
            if (dtList != null && dtList.size()>0) delete dtList;//既存のデータを削除

            //登録対象
            List<Detail__c> insList = new List<Detail__c>();

            PricingTable__c chassis = [SELECT Id, Name, RECNo__c,
                            MajorClassificationCode__c, 
                            MajorClassificationName__c, 
                            MinorClassificationCode__c, 
                            MinorClassificationName__c, 
                            CategoryCode__c,CategoryName__c,
                            Name1__c, Name2__c,Name3__c,Name4__c,Name5__c,
                            WC__c, Price__c, UniqueKey__c,ConditionForSearchformula__c,
                            Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                            Note__c
                        FROM PricingTable__c
                        WHERE Id =:rId
                        LIMIT 1
                    ];
            
            //GIS直結または　収納盤を選択された場合、
            //GIS直結ありで筐体マスタを保存した場合、筐体とGIS直結で明細を分けて保存する
            PricingTable__c option;
            if((title.contains('GIS直結')
                || title.contains('収納盤'))
                && !String.isBlank(chassis.ConditionForSearchformula__c)){
                String optCondition = chassis.ConditionForSearchformula__c.left(1) + '00001';
                
                option = [SELECT Id, Name, RECNo__c,
                            MajorClassificationCode__c, 
                            MajorClassificationName__c, 
                            MinorClassificationCode__c, 
                            MinorClassificationName__c, 
                            CategoryCode__c,CategoryName__c,
                            Name1__c, Name2__c,Name3__c,Name4__c,Name5__c,
                            WC__c, Price__c, UniqueKey__c,
                            Weight__c,DisplayName__c,detailedStatementText__c,SpecialSpecificationNo__c,
                            Note__c
                        FROM PricingTable__c
                        WHERE ConditionForSearchformula__c = :optCondition
                          AND CategoryName__c = :chassis.CategoryName__c
                          AND Name2__c = :chassis.Name2__c
                          AND Name3__c = :chassis.Name3__c
                          AND Name4__c = :chassis.Name4__c
                          AND Name5__c = :chassis.Name5__c
                        LIMIT 1
                    ]; 
                    if (option!=null) {
                        Detail__c opt = new Detail__c();
                        opt.Note__c = option.Note__c;
                        opt.UnitPrice__c = option.Price__c;
                        opt.UnitPriceCoefficient__c = 1;
                        opt.Name = option.DisplayName__c;
                        opt.Name1__c = option.CategoryName__c;
                        opt.Name2__c = option.Name1__c 
                                             +(String.isNotBlank(option.Name2__c)?'　' + option.Name2__c:'');//価格表.名称1+""　""+価格表.名称2
                        opt.Name3__c = option.Name3__c
                                        + (String.isNotBlank(option.Name4__c)?'　' + option.Name4__c:'')
                                        + (String.isNotBlank(option.Name5__c)?'　' + option.Name5__c:'');//価格表.名称3+""　""+価格表.名称4+""　""+名称5
                        opt.Name4__c = '';
                        opt.Quantity__c = 1;
                        opt.Device__c = deviceId;
                        opt.PricingTableUniqueKey__c = option.UniqueKey__c;
                        opt.CreditWC__c = option.WC__c;
                        opt.CreditWeight__c = option.Weight__c;
                        opt.WcCalculationRate__c = 0;
                        opt.DetailCategory__c='筐体';//"筐体" "明細"
                        //RECNO 「大分類名」「大分類コード」「小分類名」「小分類コード」「種類名」「種類コード」
                        opt.RECNO__c = option.RECNO__c;//RECNO
                        opt.MajorClassificationName__c = option.MajorClassificationName__c;//大分類名
                        opt.MajorClassificationCode__c = option.MajorClassificationCode__c;//大分類コード
                        opt.MinorClassificationName__c = option.MinorClassificationName__c;//小分類名
                        opt.MinorClassificationCode__c = option.MinorClassificationCode__c;//小分類コード
                        opt.CategoryName__c = option.CategoryName__c;//種類名
                        opt.CategoryCode__c = option.CategoryCode__c;//種類コード
                        opt.detailedStatementText__c	= option.detailedStatementText__c;//価格表.内訳書出力用テキスト
                        opt.SpecialSpecificationNo__c= option.SpecialSpecificationNo__c;//価格表.特殊仕様No

                        insList.add(opt);
                    } 

            }
            Detail__c detail = new Detail__c();
            detail.Note__c = chassis.Note__c;
            // detail.UnitPrice__c = cnt;
            detail.UnitPrice__c = chassis.Price__c;
            detail.UnitPriceCoefficient__c = 1;
            detail.Name = chassis.DisplayName__c;
            detail.Name1__c = chassis.CategoryName__c;
            detail.Name2__c =  chassis.Name1__c 
                              +(String.isNotBlank(chassis.Name2__c)?'　' + chassis.Name2__c:'');//価格表.名称1+""　""+価格表.名称2
            detail.Name3__c = chassis.Name3__c
                                + (String.isNotBlank(chassis.Name4__c)?'　' + chassis.Name4__c:'')
                                + (String.isNotBlank(chassis.Name5__c)?'　' + chassis.Name5__c:'');//価格表.名称3+""　""+価格表.名称4+""　""+名称5
            detail.Name4__c = '';
            detail.Quantity__c = 1;
            detail.Device__c = deviceId;
            // detail.PricingTable__c = chassis.Id;
            detail.CreditWC__c = chassis.WC__c;
            detail.CreditWeight__c = chassis.Weight__c;
            detail.WcCalculationRate__c = 0;
            detail.PricingTableUniqueKey__c = chassis.UniqueKey__c;
            detail.DetailCategory__c='筐体';//"筐体" "明細"
            // detail.RECNo__c=chassis.RECNo__c;
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

            insList.add(detail);

            if (insList.size()>0) insert insList;

            //機器情報を取得
            List<Device__c> deviceList = DeviceController.getDevice(deviceId);
            return deviceList.get(0).Quote__c;
        }catch(Exception ex) {
            System.debug('An Exception: '+ex);
            return 'error';
        }

    }

}