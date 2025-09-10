public with sharing class DetailsInputForControlCenterController {
    private static final String pricingTableRecordType = 'Detail';
    private static final String majorClassification = 'コントロールセンタ(C/C)';
    public static final List<String> SEARCH_OPTIONS = new List<String>{'なし','あり'};

    //一覧に表示する情報
    public class CustomTable {
        Public String secTitle { get; set; }//タイトル
        Public String comment { get; set; }//一覧右上のコメント
        public List<BodyRow> bodyList { get; set; }//表示内容
        public List<BodyRow> headerList { get; set; }//一覧ヘッダ情報
        Public List<String> noteList { get; set; }//一覧下の「注※」内容
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
        public Boolean isRight {get;set;}
    }

    public class QuantityObject{
        public String Id {get;set;}
        public Decimal Price {get;set;}
        public Decimal Quantity {get;set;}
    }

    //明細入力B_コントロールセンタ
    public class ControlCenterScreenInfo{
        CustomTable EMCTable {get;set;} //EMC総量
        CustomTable outerBoxTable {get;set;} //外箱（盤）
        CustomTable controlPowerTransformerTable {get;set;}//制御用電源用変圧器 （単相2線、400V・200V/100V)
        CustomTable pullInTable {get;set;}//引込盤 ・ 引込ユニット
        CustomTable reversibleTable {get;set;}//非可逆・可逆ユニット
        CustomTable stardeltaTable {get;set;}//スター・デルタユニット
        CustomTable MCCBTable {get;set;}//電源送り（MCCB）ユニット
        CustomTable indicatorTable {get;set;}//指示計・保護継電器類
        CustomTable reactorTable {get;set;}//リアクトル起動回路
        CustomTable staticcondenserTable {get;set;}//Ｃ／Ｃ用 進相コンデンサ
        CustomTable inverterTable {get;set;}//インバータ（ＶＶＶＦ装置・可変電圧可変周波数装置）
        CustomTable highinverterTable {get;set;}//高力率コンバータ付インバータ
        //String EMCPrice {get;set;}
    }

    @AuraEnabled
    public static string submitControlCenterDetails(String details,String deviceId, Integer cnt){
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
                String quantity = String.valueof(record.get('Quantity'));
                // String cntFlg = String.valueof(record.get('cntFlg'));
                // System.debug(cntFlg);
                delIds.add((String)record.get('Id'));//削除対象
                if (String.isNotBlank(quantity)) {
                    insList.put(id, Decimal.valueof(quantity));//数量が入力されたものは　登録対象

                    // if (cntFlg=='true')　 EMC総量　の数量をカウント;
                }
            }

            Device__c device = [ SELECT Id, Quote__c,
                                        MinorClassification__c,
                                        Quote__r.RecordType.DeveloperName,
                                     (SELECT Id FROM Details__r 
                                                WHERE PricingTableUniqueKey__c like '%コントロールセンタ(C/C)%' 
                                                    OR PricingTableUniqueKey__c like '%共通機器%') 
                                FROM Device__c WHERE Id =:deviceId LIMIT 1];

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
                                                                            Note__c,BU__c,MasterCode__c,DetailRecordDisplayNumberText__c
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
                            detail.MasterCode__c = pricingTable.MasterCode__c;//マスタコード
                            detail.DetailRecordDisplayNumberText__c = pricingTable.DetailRecordDisplayNumberText__c;//明細レコード表示順

                            detailList.add(detail); 
                        }
                    }
                }
                System.debug(cnt);

                // EMC総量　の登録
                if (cnt!=null  && cnt>0) {
                    // 見積のレコードタイプ確認し、BUの条件をセットする。
                    String buFunction = device.Quote__r.RecordType.DeveloperName == 'Facility' ? 'S' : 'M';
                    // 見積項目の小分類名確認し、小分類名の条件をセットする。
                    List<String> minorClassification = new List<String>();
                    if (buFunction == 'S') {
                        minorClassification.add('共通');
                    }
                    if (device.MinorClassification__c == '200V') {
                        minorClassification.add('200V');
                    }else if(device.MinorClassification__c == '400V'){
                        minorClassification.add('400V');
                    }

                    PricingTable__c emcPrice = [ SELECT Id, UniqueKey__c, Name, 
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
                                                    Note__c,BU__c,MasterCode__c,DetailRecordDisplayNumberText__c
                                                FROM PricingTable__c
                                                WHERE MajorClassificationName__c = 'コントロールセンタ(C/C)'
                                                    AND MinorClassificationName__c = :minorClassification
                                                    AND BU__c = :buFunction
                                                    AND RecordType.DeveloperName = 'Detail'
                                                    AND Name1__c = 'EMCマルチコントローラ'
                                                ORDER BY RecNo__c
                                                LIMIT 1
                                                ];
                    //条件：'EMCマルチコントローラ'⇒価格表１レコード
                    if (emcPrice!=null) {
                        Detail__c detail = new Detail__c();
                        detail.Device__c = deviceId;//機器ID
                        detail.Name1__c = emcPrice.Name1__c;
                        detail.Name2__c = emcPrice.Name2__c;
                        detail.Name3__c = emcPrice.Name3__c;
                        detail.Name4__c = emcPrice.Name4__c;
                        detail.Name5__c = emcPrice.Name5__c;
                        detail.Name6__c = emcPrice.Name6__c;
                        detail.Name7__c = emcPrice.Name7__c;
                        detail.Name8__c = emcPrice.Name8__c;
                        detail.Name9__c = emcPrice.Name9__c;
                        detail.Name10__c = emcPrice.Name10__c;
                        detail.PricingTableUniqueKey__c = emcPrice.UniqueKey__c;
                        detail.CreditWC__c = emcPrice.WC__c;//WC単価
                        detail.WcCoefficient__c = null;//null
                        detail.UnitPrice__c  = emcPrice.Price__c;//単価
                        detail.UnitPriceCoefficient__c = null;//null
                        detail.CreditWeight__c = emcPrice.Weight__c;//価格表.単位重量
                        detail.DetailCategory__c = emcPrice.RecordType.DeveloperName=='Chassis'?'筐体':'明細';//"筐体" "明細"
                        detail.ProvisionUnitPrice__c = null;//null
                        detail.Quantity__c = cnt;//数量
                        detail.WcCalculationRate__c = emcPrice.RecordType.DeveloperName=='Chassis'?0:emcPrice.WcCalculationRate__c;
                        detail.Note__c = emcPrice.Note__c;//備考
                        detail.Name = emcPrice.DisplayName__c.left(80);//表示用テキスト
                        detail.detailedStatementText__c = emcPrice.detailedStatementText__c;//価格表.内訳書出力用テキスト
                        detail.SpecialSpecificationNo__c= emcPrice.SpecialSpecificationNo__c;//価格表.特殊仕様No

                        //RECNO 「大分類名」「大分類コード」「小分類名」「小分類コード」「種類名」「種類コード」
                        detail.RECNO__c = emcPrice.RECNO__c;//RECNO
                        detail.MajorClassificationName__c = emcPrice.MajorClassificationName__c;//大分類名
                        detail.MajorClassificationCode__c = emcPrice.MajorClassificationCode__c;//大分類コード
                        detail.MinorClassificationName__c = emcPrice.MinorClassificationName__c;//小分類名
                        detail.MinorClassificationCode__c = emcPrice.MinorClassificationCode__c;//小分類コード
                        detail.CategoryCode__c = emcPrice.CategoryCode__c;//種類コード
                        detail.CategoryName__c = emcPrice.CategoryName__c;//種類名
                        detail.MasterCode__c = emcPrice.MasterCode__c;//マスタコード
                        detail.DetailRecordDisplayNumberText__c = emcPrice.DetailRecordDisplayNumberText__c;//明細レコード表示順

                        detailList.add(detail); 
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
    public static string getControlCenterScreenInfo(String deviceId, String inputsRecords) {
        String buFunction;
        List<String> MinorClassification = new List<String>();
        String PowerFrequency;
        List<Detail__c> currentDetailList = new List<Detail__c>();
        ControlCenterScreenInfo screenInfo = new ControlCenterScreenInfo();

        if (String.isNotBlank(deviceId)) {
            Device__c device = [SELECT
                                    Id,
                                    Name,
                                    MinorClassification__c,
                                    Quote__r.RecordType.DeveloperName,
                                    Quote__r.PowerFrequency__c,
                                    (SELECT Id, Name, Price__c, Quantity__c
                                    FROM Details__r
                                    WHERE 
                                        PricingTable__r.RecordType.DeveloperName = :pricingTableRecordType AND
                                        PricingTable__r.MajorClassificationName__c = :majorClassification)
                                FROM Device__c
                                WHERE Id = :deviceId];

            currentDetailList.addAll(device.Details__r);

            // 見積のレコードタイプ確認し、BUの条件をセットする。
            buFunction = device.Quote__r.RecordType.DeveloperName == 'Facility' ? 'S' : 'M';
            // 見積項目の小分類名確認し、小分類名の条件をセットする。
                    if (buFunction == 'S') {
                        MinorClassification.add('共通');
                    }
                    if (device.MinorClassification__c == '200V') {
                        MinorClassification.add('200V');
                    }else if(device.MinorClassification__c == '400V'){
                        MinorClassification.add('400V');
                    }
            //見積項目.見積の周波数を確認し、周波数の条件をセットする。
            PowerFrequency = device.Quote__r.PowerFrequency__c == '50Hz' ? '50Hz' : '60Hz';
        }

        List<PricingTable__c> pricingTableList = [SELECT
                                                    Id,UniqueKey__c, Name, RecordType.DeveloperName,BU__c,
                                                    MajorClassificationName__c,//大分類
                                                    MinorClassificationName__c, //小分類
                                                    Frequency__c,//周波数
                                                    CategoryName__c,//種類名
                                                    DisplayName__c,//表示用テキスト
                                                    RECNOforControlCenter_Attachment__c,//コントロールセンタ用RecNo
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
                                                    Note__c,
                                                    MasterCode__c,//マスタコード
                                                    DetailRecordDisplayNumberText__c//明細レコード表示順
                                                FROM PricingTable__c
                                                WHERE
                                                    BU__c = :buFunction
                                                    AND (
                                                        (MajorClassificationName__c ='コントロールセンタ(C/C)'
                                                        AND RecordType.DeveloperName ='Detail'
                                                        AND MinorClassificationName__c = :MinorClassification
                                                        AND (Name1__c = 'EMCマルチコントローラ' OR
                                                            Name1__c = '外箱 (盤)' OR
                                                            name1__c = '外箱(盤)' OR
                                                            Name1__c = '制御用変圧器単体' OR
                                                            Name1__c = '制御電源用ユニット' OR
                                                            Name1__c = '引込盤' OR
                                                            Name1__c = '引込ユニット' OR
                                                            Name1__c = '非可逆ユニット' OR
                                                            Name1__c = '可逆ユニット' OR
                                                            Name1__c = 'スター・デルタユニット' OR
                                                            Name1__c = 'MCCBユニット' OR
                                                            Name1__c = '電源送り(MCCB)ユニット' OR
                                                            Name1__c = 'リアクトル起動回路' OR
                                                            Name1__c = 'インバータユニット' OR
                                                            Name1__c = '高効率コンバータ付インバータユニット' OR
                                                            Name10__c = '指示計・保護継電器類'
                                                        )
                                                        )
                                                    OR(
                                                        MajorClassificationName__c ='コントロールセンタ(C/C)'
                                                        AND RecordType.DeveloperName ='Detail'
                                                        AND MinorClassificationName__c = :MinorClassification
                                                        AND Frequency__c = :PowerFrequency
                                                        AND Name1__c = '進相コンデンサ'
                                                        )
                                                    OR (
                                                        MajorClassificationName__c = '共通機器'
                                                        AND RecordType.DeveloperName ='Detail'
                                                        AND RECNOforControlCenter_Attachment__c != null
                                                    )
                                                    )
                                                    ORDER BY RECNOforControlCenter_Attachment__c,RecNo__c
                                                    ];

        Map<String, List<PricingTable__c>> pricingMap = new Map<String, List<PricingTable__c>>();

        //画面入力された情報
        List<Object> inputsRecordsList;
        Map<Id,Detail__c> detailMap = DetailController.getDetailRecordsByDeviceId(deviceId);
        System.debug('取得明細;' + detailMap);

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

        //EMC総量
        CustomTable EMCTable = setEMCTable(pricingTableList, detailMap);
        screenInfo.EMCTable = EMCTable;
        
        //外箱（盤）
        CustomTable outerBoxTable = setOuterBoxTable(pricingTableList, detailMap);
        screenInfo.outerBoxTable = outerBoxTable;

        //制御用電源用変圧器 （単相２線、400.200V/100V)
        CustomTable controlPowerTransformerTable = setControlPowerTransformerTable(pricingTableList, detailMap);
        screenInfo.controlPowerTransformerTable = controlPowerTransformerTable;

        //引込盤 ・ 引込ユニット
        CustomTable pullInTable = setpullInTable(pricingTableList, detailMap);
        screenInfo.pullInTable = pullInTable;

        //非可逆・可逆ユニット
        CustomTable reversibleTable = setreversibleTable(pricingTableList, detailMap);
        screenInfo.reversibleTable = reversibleTable;

        //スター・デルタユニット
        CustomTable stardeltaTable = setstardeltaTable(pricingTableList, detailMap);
        screenInfo.stardeltaTable = stardeltaTable;

        //電源送り（MCCB）ユニット
        CustomTable MCCBTable = setMCCBTable(pricingTableList, detailMap);
        screenInfo.MCCBTable = MCCBTable;

        //指示計・保護継電器類
        CustomTable indicatorTable = setindicatorTable(pricingTableList, detailMap);
        screenInfo.indicatorTable = indicatorTable;

        //リアクトル起動回路
        CustomTable reactorTable = setreactorTable(pricingTableList, detailMap);
        screenInfo.reactorTable = reactorTable;

        //Ｃ／Ｃ用 進相コンデンサ
        CustomTable staticcondenserTable = setstaticcondenserTable(pricingTableList, detailMap);
        screenInfo.staticcondenserTable = staticcondenserTable;

        //インバータ（ＶＶＶＦ装置・可変電圧可変周波数装置）
        CustomTable inverterTable = setinverterTable(pricingTableList, detailMap);
        screenInfo.inverterTable = inverterTable;

        //高力率コンバータ付インバータ
        CustomTable highinverterTable = sethighinverterTable(pricingTableList, detailMap);
        screenInfo.highinverterTable = highinverterTable;

        return JSON.serialize(screenInfo);
    }

    //EMC総量
    private static CustomTable setEMCTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable EMCTable = new CustomTable();
        Set<String> EMCTableName1 = new Set<String>();
        Map<String, PricingTable__c> EMCInfoMap = new Map<String, PricingTable__c>();//EMC 情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'EMCマルチコントローラ') {
                String key = item.Name1__c;//キー
                EMCTableName1.add(item.Name1__c);
                if(EMCInfoMap.get(key)==null)EMCInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        List<BodyCell> headerCell = new List<BodyCell>();//ヘッダ　設定
        headerCell.add(setCell('価格', null, null, false,false));
        headerCell.add(setCell('数量', null, null, false,false));

        BodyRow headerRow = new BodyRow();
        headerRow.cellList = headerCell;
        headerList.add(headerRow);

        //Body の設定
        for(String name1 : EMCTableName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = EMCInfoMap.get(name1);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    QuantityObject quantityObject = getQuantityObject(priceObj,detailMap);
                    bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                    bodyRow.add(setCell(quantityObject.Quantity,null,null,false,true));//入力セル
                }
                row.cellList = bodyRow;
                bodyList.add(row);
                row = new BodyRow();
                bodyRow  = new List<BodyCell>();
        }

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        EMCTable.secTitle = 'EMC総量';//タイトル
        EMCTable.comment = '';//コメント
        EMCTable.headerList = headerList;//ヘッダ
        EMCTable.bodyList = bodyList;//ボディー
        EMCTable.noteList = noteList;//注＊

        return EMCTable;
    }

    //外箱 (盤)
    private static CustomTable setOuterBoxTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable outerBoxTable = new CustomTable();
        Set<String> outerBoxName1 = new Set<String>();//名称1
        Set<String> outerBoxName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> outerBoxInfoMap = new Map<String, PricingTable__c>();//外箱（盤）情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && (item.Name1__c == '外箱 (盤)' || item.Name1__c == '外箱(盤)') ) {
                String key = item.Name1__c + '@@' + item.Name2__c;//キー
                outerBoxName1.add(item.Name1__c);
                outerBoxName2.add(item.Name2__c);
                outerBoxInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerCell = new List<BodyCell>();
        headerCell.add(setCell('', null, null, false,false));
        headerCell.add(setCell('価格', null, null, false,false));
        headerCell.add(setCell('数量', null, null, false,false));

        BodyRow headerRow = new BodyRow();
        headerRow.cellList = headerCell;
        headerList.add(headerRow);

        //Body の設定
        for(String name1 : outerBoxName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name2 : outerBoxName2) {
                PricingTable__c priceObj = outerBoxInfoMap.get(name1 +'@@' + name2);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2,null,null,false,true));//名称2
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
        List<String> noteList = System.Label.Annotation_ControlCenter_OuterCase.split('\r\n');

        //タイトルの設定
        outerBoxTable.secTitle = '外箱（盤）';//タイトル
        outerBoxTable.comment = '（1面当り価格）';//コメントs
        outerBoxTable.headerList = headerList;//ヘッダ
        outerBoxTable.bodyList = bodyList;//ボディー
        outerBoxTable.noteList = noteList;//注＊
        

        return outerBoxTable;
    }

    //制御用電源用変圧器 （単相２線、400.200V/100V)
    private static CustomTable setControlPowerTransformerTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable controlPowerTransformerTable = new CustomTable();
        Set<String> controlPowerTransformerName1 = new Set<String>();
        Set<String> controlPowerTransformerName2 = new Set<String>();
        Map<String, PricingTable__c> controlPowerTransformerInfoMap = new Map<String, PricingTable__c>();//制御用電源用変圧器 情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && (item.Name1__c == '制御用変圧器単体' || item.Name1__c == '制御電源用ユニット') ) {
                String replaceName2 = item.Name2__c.replace('kVA','').replace(',','');
                String key = item.Name1__c + '@@' + replaceName2;//キー
                System.debug(replaceName2);
                controlPowerTransformerName1.add(item.Name1__c);
                controlPowerTransformerName2.add(replaceName2);
                controlPowerTransformerInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerCell = new List<BodyCell>();
        headerCell.add(setCell('kVA', null, null, false,false));

        Boolean isFirst = true;
        //Body の設定
        for(String name1 : controlPowerTransformerName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyrow.add(setCell(name1,null,null,false,false));//名称1
            for (String name2 : controlPowerTransformerName2) {
                PricingTable__c priceObj = controlPowerTransformerInfoMap.get(name1 +'@@' + name2);
                if (isFirst) {
                    headerCell.add(setCell(name2, null, null, false, false));
                    headerCell.add(setCell('数量', null, null, false, false));
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
        Bodyrow row1 = new Bodyrow();
        row1.cellList = headerCell;
        headerList.add(row1);

        //注＊　の設定
        List<String> noteList = System.Label.Annotation_ControlCenter_ControlPowerSupply.split('\r\n');

        //タイトルの設定
        controlPowerTransformerTable.secTitle = '制御用電源用変圧器 （単相２線、400.200V/100V)';//タイトル
        controlPowerTransformerTable.comment = '';//コメント
        controlPowerTransformerTable.headerList = setControlPowerTransformerTableHeader(pricingTableList);//ヘッダ
        controlPowerTransformerTable.bodyList = bodyList;//ボディー
        controlPowerTransformerTable.noteList = noteList;//注＊

        return controlPowerTransformerTable;
    }

    //引込盤 ・ 引込ユニット
    private static CustomTable setpullInTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable pullInTable = new CustomTable();
        Set<String> pullInName2 = new Set<String>();//名称2
        Set<String> pullInMinor = new Set<String>();//小分類
        Map<String, Set<String>> pullInName3 = new Map<String,Set<String>>();//名称1+名称3
        Map<String, PricingTable__c> pullInInfoMap = new Map<String, PricingTable__c>();//引込盤 ・ 引込ユニット 情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && (item.Name1__c == '引込盤' || item.Name1__c == '引込ユニット') ) {
                String replaceName2 = item.Name2__c.replace('AF','').replace(',','');
                String key = item.Name1__c + '@@' + replaceName2 + '@@' + item.Name3__c;//キー
                pullInName2.add(replaceName2);
                pullInMinor.add(item.MinorClassificationName__c);
                Set<String> name1List = pullInName3.get(item.Name3__c);

                if(name1List==null){
                    name1List = new Set<String>();
                    pullInName3.put(item.Name3__c, name1List);
                }
                name1List.add(item.Name1__c);
                pullInInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //1行目：図　引込回路
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('図', null, null, false,false));

        //2行目：AF　引込盤・引込ユニット
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow2.add(setCell('AF', null, null, false,false));

        //キー単位でヘッダを設定
        for(String name3 : pullInName3.keyset()){
            Set<String> name1 = pullInName3.get(name3);
            headerRow1.add(setCell(name3, name1.size()*2, null, false, false));
            for(String val : name1){
                headerRow2.add(setCell(val,null,null,false,false));
                headerRow2.add(setCell('数量',null,null,false,false));
            }
        }

        BodyRow row1 = new BodyRow();
        row1.cellList = headerRow1;
        BodyRow row2 = new BodyRow();
        row2.cellList = headerRow2;
        headerList.add(row1);
        headerList.add(row2);

        //Body の設定
        for(String name2 : pullInName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2, null, null, false, false));//AF
            for(String name3 : pullInName3.keyset()){
                Set<String> name1 = pullInName3.get(name3);
                for (String val : name1) {
                    PricingTable__c priceObj = pullInInfoMap.get(val + '@@' + name2 +'@@' + name3);
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
        List<String> noteList = System.Label.Annotation_ControlCenter_PullBoard.split('\r\n');

        //タイトルの設定
        pullInTable.secTitle = '引込盤 ・ 引込ユニット';//タイトル
        pullInTable.comment = '';//コメント
        pullInTable.headerList = headerList;//ヘッダ
        pullInTable.bodyList = bodyList;//ボディー
        pullInTable.noteList = noteList;//注＊

        return pullInTable;
    }

    //非可逆 ・ 可逆ユニット
    private static CustomTable setreversibleTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable reversibleTable = new CustomTable();
        Set<String> reversibleName2 = new Set<String>();//名称2
        Map<String, Set<String>> reversibleMinor = new Map<String,Set<String>>();//名称1+小分類名
        Map<String, PricingTable__c> reversibleInfoMap = new Map<String, PricingTable__c>();//非可逆 ・ 可逆ユニット 情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && (item.Name1__c == '非可逆ユニット' || item.Name1__c == '可逆ユニット') ) {
                String replaceName2 = item.Name2__c.replace('kW','').replace(',','');
                String key = item.Name1__c + '@@' + replaceName2 ;//キー
                reversibleName2.add(replaceName2);
                Set<String> name1List = reversibleMinor.get(item.MinorClassificationName__c);

                if(name1List==null){
                    name1List = new Set<String>();
                    reversibleMinor.put(item.MinorClassificationName__c, name1List);
                }
                name1List.add(item.Name1__c);
                reversibleInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //1行目：小分類名
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell(null, null, null, false,false));

        //2行目：kW　非可逆・可逆ユニット
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow2.add(setCell('kW', null, null, false,false));

        //キー単位でヘッダを設定
        for(String minorclassification : reversibleMinor.keyset()){
            Set<String> name1 = reversibleMinor.get(minorclassification);
            headerRow1.add(setCell(minorclassification, name1.size()*2, null, false, false));
            for(String val : name1){
                headerRow2.add(setCell(val,null,null,false,false));
                headerRow2.add(setCell('数量',null,null,false,false));
            }
        }

        BodyRow row1 = new BodyRow();
        row1.cellList = headerRow1;
        BodyRow row2 = new BodyRow();
        row2.cellList = headerRow2;
        headerList.add(row1);
        headerList.add(row2);

        //Body の設定
        for(String name2 : reversibleName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2, null, null, false, false));//kW
            for(String minorclassification : reversibleMinor.keyset()){
                Set<String> name1 = reversibleMinor.get(minorclassification);
                for (String val : name1) {
                    PricingTable__c priceObj = reversibleInfoMap.get(val + '@@' + name2 );
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
        List<String> noteList = System.Label.Annotation_ControlCenter_Reversible.split('\r\n');

        //タイトルの設定
        reversibleTable.secTitle = '非可逆 ・ 可逆ユニット';//タイトル
        reversibleTable.comment = '';//コメント
        reversibleTable.headerList = headerList;//ヘッダ
        reversibleTable.bodyList = bodyList;//ボディー
        reversibleTable.noteList = noteList;//注＊

        return reversibleTable;
    }

    //スター・デルタユニット
    private static CustomTable setstardeltaTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable stardeltaTable = new CustomTable();
        Set<String> stardeltaName2 = new Set<String>();//名称2
        Map<String, Set<String>> stardeltaName3 = new Map<String,Set<String>>();//名称3+小分類
        Map<String, PricingTable__c> stardeltaInfoMap = new Map<String, PricingTable__c>();//スター・デルタユニット 情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c == 'スター・デルタユニット' ) {
                String replaceName2 = item.Name2__c.replace('kW','').replace(',','');
                String key = replaceName2 + '@@' + item.Name3__c + '@@' + item.MinorClassificationName__c;//キー
                stardeltaName2.add(replaceName2);
                Set<String> MinorList = stardeltaName3.get(item.Name3__c);

                if(MinorList==null){
                    MinorList = new Set<String>();
                    stardeltaName3.put(item.Name3__c, MinorList);
                }
                MinorList.add(item.MinorClassificationName__c);
                stardeltaInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //1行目：Y-Δ、Y-Δ(4コンダクタ)
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell(null, null, null, false,false));

        //2行目：kW　小分類
        List<BodyCell> headerRow2 = new List<BodyCell>();
        headerRow2.add(setCell('kW', null, null, false,false));

        //キー単位でヘッダを設定
        for(String name3 : stardeltaName3.keyset()){
            Set<String> minor = stardeltaName3.get(name3);
            headerRow1.add(setCell(name3 == '3コンダクタ' ? 'Y-Δ':'Y-Δ(4コンダクタ)' , minor.size()*2, null, false, false));
            for(String val : minor){
                headerRow2.add(setCell(val,null,null,false,false));
                headerRow2.add(setCell('数量',null,null,false,false));
            }
        }

        BodyRow row1 = new BodyRow();
        row1.cellList = headerRow1;
        BodyRow row2 = new BodyRow();
        row2.cellList = headerRow2;
        headerList.add(row1);
        headerList.add(row2);

        //Body の設定
        for(String name2 : stardeltaName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2, null, null, false, false));//kW
            for(String name3 : stardeltaName3.keyset()){
                Set<String> minor = stardeltaName3.get(name3);
                for (String val : minor) {
                    PricingTable__c priceObj = stardeltaInfoMap.get(name2 + '@@' + name3 + '@@'+ val);
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
        stardeltaTable.secTitle = 'スター・デルタユニット';//タイトル
        stardeltaTable.comment = '';//コメント
        stardeltaTable.headerList = headerList;//ヘッダ
        stardeltaTable.bodyList = bodyList;//ボディー
        stardeltaTable.noteList = noteList;//注＊

        return stardeltaTable;
    }

    //電源送り（MCCB）ユニット
    private static CustomTable setMCCBTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable MCCBTable = new CustomTable();
        Set<String> MCCBName1 = new Set<String>();//名称1
        Set<String> MCCBName2 = new Set<String>();//名称2
        Map<String, PricingTable__c> MCCBInfoMap = new Map<String, PricingTable__c>();//電源送り（MCCB）ユニット 情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && (item.Name1__c == 'MCCBユニット' || item.Name1__c == '電源送り(MCCB)ユニット') ) {
                String replaceName2 = item.Name2__c.replace('AF','').replace(',','');
                String key = item.Name1__c + '@@' + replaceName2;//キー
                MCCBName1.add(item.Name1__c);
                MCCBName2.add(replaceName2);
                MCCBInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerCell = new List<BodyCell>();
        headerCell.add(setCell('AF', null, null, false,false));//AF
        headerCell.add(setCell('価格', null, null, false,false));//単価？
        headerCell.add(setCell('数量', null, null, false,false));

        BodyRow headerRow = new BodyRow();
        headerRow.cellList = headerCell;
        headerList.add(headerRow);

        //Body の設定
        for(String name1 : MCCBName1){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            for (String name2 : MCCBName2) {
                PricingTable__c priceObj = MCCBInfoMap.get(name1 +'@@' + name2);
                if (priceObj!=null) {
                    Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                    bodyRow.add(setCell(name2,null,null,false,true));//名称2
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
        MCCBTable.secTitle = '電源送り（MCCB）ユニット';//タイトル
        MCCBTable.comment = '';//コメントs
        MCCBTable.headerList = headerList;//ヘッダ
        MCCBTable.bodyList = bodyList;//ボディー
        MCCBTable.noteList = noteList;//注＊
        

        return MCCBTable;
    }

    //指示計・保護継電器類
    private static CustomTable setindicatorTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable indicatorTable = new CustomTable();
        Set<String> indicatorName1 = new Set<String>();//名称1
        Set<String> indicatorDisplayName = new Set<String>();//表示用テキスト
        Map<String, PricingTable__c> indicatorInfoMap = new Map<String, PricingTable__c>();//指示計・保護継電器類　情報
        for(PricingTable__c item : pricingTableList){
            if ((item.MajorClassificationName__c == '共通機器' && item.BU__c == 'S' && item.RecordType.DeveloperName == 'Detail' && item.RECNOforControlCenter_Attachment__c != null) || 
                (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.BU__c == 'M' &&item.RecordType.DeveloperName == 'Detail' && item.Name10__c == '指示計・保護継電器類')) {
                String key = item.Name1__c + '@@' + item.DisplayName__c;//キー
                indicatorName1.add(item.Name1__c);
                indicatorDisplayName.add(item.DisplayName__c);
                indicatorInfoMap.put(item.DisplayName__c,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        List<BodyCell> headerCell = new List<BodyCell>();
        headerCell.add(setCell('', null, null, false,false));
        headerCell.add(setCell('価格', null, null, false,false));//単価？
        headerCell.add(setCell('数量', null, null, false,false));

        BodyRow headerRow = new BodyRow();
        headerRow.cellList = headerCell;
        headerList.add(headerRow);

        //Body の設定
        for (String displayname : indicatorDisplayName) {
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            PricingTable__c priceObj = indicatorInfoMap.get(displayname);
            if (priceObj!=null) {
                Decimal price =  (priceObj.Price__c==null?0:priceObj.Price__c);
                bodyRow.add(setCell(displayname,null,null,false,false));//表示用テキストセル
                bodyRow.add(setCell(price.format(),null,null,false,true));//価格セル
                bodyRow.add(setCell(getQuantityObject(priceObj,detailMap),null,null,true,true));//入力セル
            }
            row.cellList = bodyRow;
            bodyList.add(row);
            row = new BodyRow();
            bodyRow  = new List<BodyCell>();
        }


        //注＊　の設定
        List<String> noteList = System.Label.Annotation_ControlCenter_Indicator.split('\r\n');

        //タイトルの設定
        indicatorTable.secTitle = '指示計・保護継電器類';//タイトル
        indicatorTable.comment = '';//コメントs
        indicatorTable.headerList = headerList;//ヘッダ
        indicatorTable.bodyList = bodyList;//ボディー
        indicatorTable.noteList = noteList;//注＊
        

        return indicatorTable;
    }

    //リアクトル起動回路
    private static CustomTable setreactorTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable reactorTable = new CustomTable();
        Set<String> reactorName2 = new Set<String>();
        Map<String, Set<String>> reactorMinor = new Map<String,Set<String>>();//名称1+小分類名
        Map<String, PricingTable__c> reactorInfoMap = new Map<String, PricingTable__c>();//外箱（盤）情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c =='リアクトル起動回路' ) {
                String replaceName2 = item.Name2__c.replace('kW','').replace(',','');
                String key = item.Name1__c + '@@' + replaceName2 ;//キー
                reactorName2.add(replaceName2);
                Set<String> name1List = reactorMinor.get(item.MinorClassificationName__c);

                if(name1List==null){
                    name1List = new Set<String>();
                    reactorMinor.put(item.MinorClassificationName__c, name1List);
                }
                name1List.add(item.Name1__c);
                reactorInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //電動機容量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('電動機容量', null, null, false,false));

        //キー単位でヘッダを設定
        for(String minorclassification : reactorMinor.keyset()){
            headerRow1.add(setCell(minorclassification, null, null, false, false));
            headerRow1.add(setCell('数量',null,null,false,false));
        }

        BodyRow row1 = new BodyRow();
        row1.cellList = headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2 : reactorName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2, null, null, false, false));//kW
            for(String minorclassification : reactorMinor.keyset()){
                Set<String> name1 = reactorMinor.get(minorclassification);
                for (String val : name1) {
                    PricingTable__c priceObj = reactorInfoMap.get(val + '@@' + name2 );
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
        reactorTable.secTitle = 'リアクトル起動回路';//タイトル
        reactorTable.comment = '';//コメント
        reactorTable.headerList = headerList;//ヘッダ
        reactorTable.bodyList = bodyList;//ボディー
        reactorTable.noteList = noteList;//注＊

        return reactorTable;
    }

    //Ｃ／Ｃ用 進相コンデンサ
    private static CustomTable setstaticcondenserTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable staticcondenserTable = new CustomTable();
        Set<String> staticcondenserFrequency = new Set<String>();//周波数
        Map<String, Set<String>> staticcondenserMinor = new Map<String, Set<String>>();//名称1+小分類
        List<PricingTable__c> staticcondenserInfoMap = new List<PricingTable__c>();//進相コンデンサ 情報

        for(PricingTable__c item : pricingTableList){
            System.debug('大分類'+ item.MajorClassificationName__c);
            System.debug('レコードタイプ'+ item.RecordType.DeveloperName);
            System.debug('名称1'+ item.Name1__c);
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c =='進相コンデンサ' ) {
                staticcondenserInfoMap.add(item);//データをキーで格納
                staticcondenserFrequency.add(item.Frequency__c);
                Set<String> name1List = staticcondenserMinor.get(item.MinorClassificationName__c);
                staticcondenserFrequency.add(item.Frequency__c);
                if(name1List==null){
                    name1List = new Set<String>();
                    staticcondenserMinor.put(item.MinorClassificationName__c, name1List);
                }
                name1List.add(item.Name1__c);
            }
        }

        String f;//周波数用
        String m;//小分類用

        for (String frequency : staticcondenserFrequency) {
            f = frequency;
        }
        for (String minor : staticcondenserMinor.keySet()) {
            m = minor;
        }

        //1行目
        BodyRow row1 = new BodyRow();
        List<BodyCell> headerRow1  = new List<BodyCell>();
        //2行目
        BodyRow row2 = new BodyRow();
        List<BodyCell> bodyRow2  = new List<BodyCell>();
        //3行目
        BodyRow row3 = new BodyRow();
        List<BodyCell> bodyRow3  = new List<BodyCell>();
        //4行目
        BodyRow row4 = new BodyRow();
        List<BodyCell> bodyRow4  = new List<BodyCell>();

        // 1行目　定格出力　kW (ヘッダ)
        headerRow1.add(setCell(null, null, null, false,false));
        headerRow1.add(setCell('定格出力', null, null, false,false));
        headerRow1.add(setCell('kW', null, null, false,false));
        // 2行目　周波数　小分類　μF
        bodyRow2.add(setCell(null, null, null, false,false));//1
        bodyRow2.add(setCell(null, null, null, false,false));//2
        bodyRow2.add(setCell('μF', null, null, false,false));//3
        // 3行目　価格
        bodyRow3.add(setCell(f, null, 1, false,false));//1
        bodyRow3.add(setCell(m, null, 1, false,false));//2
        bodyRow3.add(setCell('価格', null, null, false,false));//3
        // 4行目　数量
        bodyRow4.add(setCell(null, null, null, false,false));//1
        bodyRow4.add(setCell(null, null, null, false,false));//2
        bodyRow4.add(setCell('数量', null, null, false,false));//3

        System.debug('2'+bodyRow3);
        System.debug('3'+bodyRow3);
        System.debug('4'+bodyRow4);


        for(PricingTable__c item : staticcondenserInfoMap){
            String replaceName2 = item.Name2__c.replace('kW','').replace(',','');
            String replaceName3 = item.Name3__c.replace('μF','').replace(',','');
            headerRow1.add(setCell(replaceName2, null, null, false,false));
            bodyRow2.add(setCell(replaceName3, null, null, false,false));
            bodyRow3.add(setCell(item.Price__c.format(), null, null, false,false));
            bodyRow4.add(setCell(getQuantityObject(item,detailMap),null,null,true,true));
        }
        System.debug('2'+bodyRow2);
        System.debug('3'+bodyRow3);
        System.debug('4'+bodyRow4);
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        row1.cellList = headerRow1;
        headerList.add(row1);
        row2.cellList = bodyRow2;
        bodyList.add(row2);
        row3.cellList = bodyRow3;
        bodyList.add(row3);
        row4.cellList = bodyRow4;
        bodyList.add(row4);

        //注＊　の設定
        List<String> noteList = new List<String>();

        //タイトルの設定
        staticcondenserTable.secTitle = 'Ｃ／Ｃ用 進相コンデンサ';//タイトル
        staticcondenserTable.comment = '';//コメント
        staticcondenserTable.headerList = headerList;//ヘッダ
        staticcondenserTable.bodyList = bodyList;//ボディー
        staticcondenserTable.noteList = noteList;//注＊

        return staticcondenserTable;
    }

    //インバータ（ＶＶＶＦ装置・可変電圧可変周波数装置）
    private static CustomTable setinverterTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable inverterTable = new CustomTable();
        Set<String> inverterName2 = new Set<String>();
        Map<String, Set<String>> inverterMinor = new Map<String,Set<String>>();//名称1+小分類名
        Map<String, PricingTable__c> inverterInfoMap = new Map<String, PricingTable__c>();//インバータユニット　情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c =='インバータユニット' ) {
                String replaceName2 = item.Name2__c.replace('kW','').replace(',','');
                String key = item.Name1__c + '@@' + replaceName2 ;//キー
                inverterName2.add(replaceName2);
                Set<String> name1List = inverterMinor.get(item.MinorClassificationName__c);

                if(name1List==null){
                    name1List = new Set<String>();
                    inverterMinor.put(item.MinorClassificationName__c, name1List);
                }
                name1List.add(item.Name1__c);
                inverterInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //電動機容量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('容量(kW）', null, null, false,false));

        //キー単位でヘッダを設定
        for(String minorclassification : inverterMinor.keyset()){
            headerRow1.add(setCell(minorclassification, null, null, false, false));
            headerRow1.add(setCell('数量',null,null,false,false));
        }

        BodyRow row1 = new BodyRow();
        row1.cellList = headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2 : inverterName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2, null, null, false, false));//kW
            for(String minorclassification : inverterMinor.keyset()){
                Set<String> name1 = inverterMinor.get(minorclassification);
                for (String val : name1) {
                    PricingTable__c priceObj = inverterInfoMap.get(val + '@@' + name2 );
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
        List<String> noteList = System.Label.Annotation_ControlCenter_Inverter.split('\r\n');

        //タイトルの設定
        inverterTable.secTitle = 'インバータ（ＶＶＶＦ装置・可変電圧可変周波数装置）';//タイトル
        inverterTable.comment = '';//コメント
        inverterTable.headerList = headerList;//ヘッダ
        inverterTable.bodyList = bodyList;//ボディー
        inverterTable.noteList = noteList;//注＊

        return inverterTable;
    }

    //高力率コンバータ付インバータ
    private static CustomTable sethighinverterTable(List<PricingTable__c> pricingTableList, Map<Id, Detail__c> detailMap) {
        CustomTable highinverterTable = new CustomTable();
        Set<String> highinverterName2 = new Set<String>();
        Map<String, Set<String>> highinverterMinor = new Map<String,Set<String>>();//名称1+小分類名
        Map<String, PricingTable__c> highinverterInfoMap = new Map<String, PricingTable__c>();//高力率コンバータ付インバータ　情報
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && item.Name1__c =='高効率コンバータ付インバータユニット' ) {
                String key = item.Name1__c + '@@' + item.Name2__c ;//キー
                highinverterName2.add(item.Name2__c);
                Set<String> name1List = highinverterMinor.get(item.MinorClassificationName__c);

                if(name1List==null){
                    name1List = new Set<String>();
                    highinverterMinor.put(item.MinorClassificationName__c, name1List);
                }
                name1List.add(item.Name1__c);
                highinverterInfoMap.put(key,item);//データをキーで格納
            }
        }
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        List<BodyRow> bodyList = new List<BodyRow>();//ボディー行情報

        //ヘッダ　設定
        //容量
        List<BodyCell> headerRow1 = new List<BodyCell>();
        headerRow1.add(setCell('容量', null, null, false,false));

        //キー単位でヘッダを設定
        for(String minorclassification : highinverterMinor.keyset()){
            headerRow1.add(setCell(minorclassification, null, null, false, false));
            headerRow1.add(setCell('数量',null,null,false,false));
        }

        BodyRow row1 = new BodyRow();
        row1.cellList = headerRow1;
        headerList.add(row1);

        //Body の設定
        for(String name2 : highinverterName2){
            BodyRow row = new BodyRow();
            List<BodyCell> bodyRow  = new List<BodyCell>();
            bodyRow.add(setCell(name2, null, null, false, false));//kW
            for(String minorclassification : highinverterMinor.keyset()){
                Set<String> name1 = highinverterMinor.get(minorclassification);
                for (String val : name1) {
                    PricingTable__c priceObj = highinverterInfoMap.get(val + '@@' + name2 );
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
        List<String> noteList = System.Label.Annotation_ControlCenter_HighInverter.split('\r\n');

        //タイトルの設定
        highinverterTable.secTitle = '高力率コンバータ付インバータ';//タイトル
        highinverterTable.comment = '';//コメント
        highinverterTable.headerList = headerList;//ヘッダ
        highinverterTable.bodyList = bodyList;//ボディー
        highinverterTable.noteList = noteList;//注＊

        return highinverterTable;
    }
    /* 
    ヘッダー固定
    ・制御用電源用変圧器
        setControlPowerTransformerTableHeader
    */

    private static List<BodyRow> setControlPowerTransformerTableHeader(List<PricingTable__c> pricingTableList){
        List<BodyRow> headerList = new List<BodyRow>();//ヘッダ行情報
        Set<String> controlPowerTransformerName2 = new Set<String>();//名称2
        for(PricingTable__c item : pricingTableList){
            if (item.MajorClassificationName__c == 'コントロールセンタ(C/C)' && item.RecordType.DeveloperName == 'Detail' && (item.Name1__c == '制御用変圧器単体' || item.Name1__c == '制御電源用ユニット') ) {
                String replaceName2 = item.Name2__c.replace('kVA','').replace(',','');
                System.debug(replaceName2);
                controlPowerTransformerName2.add(replaceName2);
            }
        }
        List<BodyCell> headerCell = new List<BodyCell>();
        BodyRow hBodyRow = new BodyRow();
        headerCell.add(setCell('kVA', null, null, false,false));
        for (String name2 : controlPowerTransformerName2) {
            headerCell.add(setCell(name2, null, null, false, false));
            headerCell.add(setCell('数量', null, null, false, false));
        }
        hBodyRow.cellList = headerCell;
        headerList.add(hBodyRow);
        return headerList;
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
}