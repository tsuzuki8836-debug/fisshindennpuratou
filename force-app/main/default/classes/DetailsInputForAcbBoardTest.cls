/**
 * 明細入力B(ACB盤)画面のコントローラーのテスト
 */
@isTest
public with sharing class DetailsInputForAcbBoardTest {

    private static final String RECORDTYPE_NAME_CHSSIS = '筐体';
    private static final String Frequency_50Hz = '50Hz';
    private static final String Frequency_60Hz = '60Hz';
    private static final List<String> BU_LIST = new List<String>{'S','K','M'};

    private static Quote__c quote;//見積
    private static Device__c dv;//見積項目
    private static List<PricingTable__c> tables;
    private static Map<String, Id> pricingRecordTypeByName;
    //価格表データ作成
    private static void createDate(String qRtName){
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = :qRtName];
        List<RecordType> dvType = [SELECT Id FROM RecordType WHERE SobjectType = 'Device__c' and name = :qRtName];

        quote = new Quote__c(
            QuoteNumber__c = '1',
            PowerFrequency__c = Frequency_60Hz,
            RecordTypeId = recType[0].Id
        );
        insert quote;

        dv = new Device__c(
            // QuoteSpecificationNumber__c = '001',
            Name = qRtName+'DeviceTest',
            RecordTypeOfQuote__c = qRtName,
            MajorClassification__c = '低圧・現場・リレー・ACB盤',
            MinorClassification__c = 'ACB盤',
            Quote__c =quote.Id,
            RecordTypeId = dvType[0].Id
        );
        insert dv;

        // レコードタイプ（価格表）取得
       pricingRecordTypeByName = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SobjectType = 'PricingTable__c']) {
            pricingRecordTypeByName.put(rt.Name, rt.Id);
        }
        tables = new List<PricingTable__c>();
        List<String> name1Lst = new List<String>();
        name1Lst.add('零相変流器+地絡過電流継電器');
        name1Lst.add('計器用変圧器');
        name1Lst.add('計器用変流器');
        name1Lst.add('プロテクタヒューズ');
        name1Lst.add('テイクオフヒューズ');
        name1Lst.add('ネットワークリレー');
        name1Lst.add('合成CT(低圧)');
        name1Lst.add('ネットワークVT(低圧)');
        name1Lst.add('ネットワークCT(低圧)');
        name1Lst.add('配線用遮断器');
        // name1Lst.add('ACB加算');
        name1Lst.add('RECNOforACBBoardB_Attachment__c');

        // 大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤
        Integer index = 1;
        for (String bu: BU_LIST){
            //筐体
            // 価格表
            for (Integer i = 1;i<3;i++ ){

                PricingTable__c classicTable = new PricingTable__c(
                    RecordTypeId = pricingRecordTypeByName.get('筐体') 
                    , BU__c = bu
                    , MajorClassificationName__c = '低圧・現場・リレー・ACB盤'
                    , MinorClassificationCode__c = '11'
                    , MinorClassificationName__c = 'ACB盤'
                    , Frequency__c = Frequency_60Hz
                    , Name1__c = (bu=='S'?'屋内':'ACB盤　屋内')
                    , Name2__c = '自立SS'+ String.valueOf(i)
                    , Name3__c = '3'+ String.valueOf(i)
                    , Name4__c = '4'+ String.valueOf(i)
                    , Name5__c = '5'+ String.valueOf(i)
                    , Name6__c = '観音開き'
                    , Name7__c = '7'+ String.valueOf(i)
                    , Name8__c = '8'+ String.valueOf(i)
                    , Name9__c = '9'+ String.valueOf(i)
                    , MasterCode__c = 'MasterCode'
                    , RECNo__c = index
                );
                index = index + 1;
                tables.add(classicTable);
            }

            //ACB盤
            for (Integer i = 3;i<5;i++ ){
                // 価格表
                PricingTable__c table = new PricingTable__c(
                    RecordTypeId = pricingRecordTypeByName.get('明細') 
                    , BU__c = bu
                    , MajorClassificationName__c = '低圧・現場・リレー・ACB盤'
                    , MinorClassificationName__c = 'ACB盤'
                    , Frequency__c = Frequency_60Hz
                    , CategoryName__c = Frequency_60Hz
                    , Name1__c = 'ACB加算'
                    , Name2__c = '222222'+ String.valueOf(i)
                    , Name3__c = '3333333' + String.valueOf(i)+'P'
                    , Name4__c = '4444444' + String.valueOf(i)
                    , Name5__c = '5555555' + String.valueOf(i)
                    , Name6__c = '観音開き'
                    , Name7__c = '777777' + String.valueOf(i)
                    , Name8__c = '888888' + String.valueOf(i)
                    , Name9__c = 'name9est' + String.valueOf(i)
                    , Name10__c = 'name10est' + String.valueOf(i)
                    , MasterCode__c = 'MasterCode'
                    , RECNOforACBBoardB_Attachment__c = null
                    , RECNo__c = index
                );
                index = index + 1;
                tables.add(table);
            }
            if (bu=='S'){
                //共通機器
                for(String mapKey:name1Lst){
                    for (Integer i = 2;i<5;i++ ){
                        // 価格表
                        PricingTable__c table = new PricingTable__c(
                            RecordTypeId = pricingRecordTypeByName.get('明細') 
                            , BU__c = bu
                            , MajorClassificationName__c = '共通機器'
                            , MinorClassificationName__c = 'test'
                            , Frequency__c = Frequency_60Hz
                            , CategoryName__c = Frequency_60Hz
                            , Name1__c = mapKey
                            , Name2__c = (mapKey=='計器用変圧器'?'VT,PT 引出型':(mapKey=='配線用遮断器'?String.valueOf(i)+'PMCCB':'2222222'+ String.valueOf(i)))
                            , Name3__c = (mapKey=='零相変流器+地絡過電流継電器'?'低圧':'333333'+ String.valueOf(i))
                            , Name4__c = (mapKey=='配線用遮断器'&&i==3?'電動':'444444'+ String.valueOf(i))
                            , Name5__c = '5555555' + String.valueOf(i)
                            , Name6__c = '観音開き'
                            , Name7__c = '777777' + String.valueOf(i)
                            , Name8__c = '888888' + String.valueOf(i)
                            , Name9__c = 'name9est' + String.valueOf(i)
                            , Name10__c = 'name10est' + String.valueOf(i)
                            , MasterCode__c = 'MasterCode'
                            , RECNOforACBBoardB_Attachment__c = (mapKey=='RECNOforACBBoardB_Attachment__c'?index:null)
                            , RECNo__c = index
                        );
                        index = index + 1;
                        tables.add(table);
                    }
                }
            }
        }
        if (tables.size() > 0) insert tables;
    }

    /**
     *内訳入力B_ACB盤 画面情報を取得 施設テスト
     * 
     */
    @isTest static void getInitScreenInfoSTest() {
        String qRtName='施設';
        createDate(qRtName);

        Test.startTest();
        String rtn = DetailsInputForAcbBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            '屋内');
        Test.stopTest();
        System.assertNotEquals(rtn, null);//

        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        List<Object> bodyList = (List<Object>)jsonDes.get('bodyList');//メイン一覧データ
        List<Object> headerList = (List<Object>)jsonDes.get('headerList');//メイン一覧ヘッダー
        Map<String, Object> acbSumTable = (Map<String, Object>)jsonDes.get('acbSumTable');//ACB加算
        Map<String, Object> zctTable = (Map<String, Object>)jsonDes.get('zctTable');//零相変流器+地絡過電融継電器(ZCT+51G)
        Map<String, Object> transformerDrawerTable = (Map<String, Object>)jsonDes.get('transformerDrawerTable');//計器用変圧器VT,PT(低圧）引出型
        Map<String, Object> transformerCtTable = (Map<String, Object>)jsonDes.get('transformerCtTable');// 計器用変流器 ＣＴ(低圧)
        Map<String, Object> acbTable = (Map<String, Object>)jsonDes.get('acbTable');// ACB　（エアーサーキットブレーカ）
        Map<String, Object> protectorFuseTable = (Map<String, Object>)jsonDes.get('protectorFuseTable');// プロテクタヒューズ
        Map<String, Object> takeoffFuseTable = (Map<String, Object>)jsonDes.get('takeoffFuseTable');// テイクオフヒューズ
        Map<String, Object> networkRelayTable = (Map<String, Object>)jsonDes.get('networkRelayTable');// ネットワークリレー（multicap)
        Map<String, Object> mixedTable = (Map<String, Object>)jsonDes.get('mixedTable');// 合成CT（低圧）
        Map<String, Object> networkVtTable = (Map<String, Object>)jsonDes.get('networkVtTable');// ネットワークVT（低圧）
        Map<String, Object> networkCtTable = (Map<String, Object>)jsonDes.get('networkCtTable');// ネットワークCT（低圧）
        Map<String, Object> mccbTable = (Map<String, Object>)jsonDes.get('mccbTable');// 配線用遮断器価格 （MCCB・ELB）
        Map<String, Object> installEquipTypeTable = (Map<String, Object>)jsonDes.get('installEquipTypeTable');// 取付器具類

        System.assertEquals(jsonDes.size()>0, true);
        System.assertEquals(bodyList.size()>0, true);
        System.assertEquals(headerList.size()>0, true);
        System.assertEquals(acbSumTable, null);//施設の場合　設定しない
        System.assertEquals(zctTable.size()>0, true);
        System.assertEquals(transformerDrawerTable.size()>0, true);
        System.assertEquals(transformerCtTable.size()>0, true);
        System.assertEquals(protectorFuseTable.size()>0, true);
        System.assertEquals(takeoffFuseTable.size()>0, true);
        System.assertEquals(networkRelayTable.size()>0, true);
        System.assertEquals(mixedTable.size()>0, true);
        System.assertEquals(networkVtTable.size()>0, true);
        System.assertEquals(mccbTable.size()>0, true);
        System.assertEquals(installEquipTypeTable.size()>0, true);
    }
  /**
     *内訳入力B_ACB盤 画面情報を取得 データなしテスト
     * 
     */
    @isTest static void getInitScreenInfoNodataTest() {
        String qRtName='施設';
        createDate(qRtName);

        Test.startTest();
        String rtn = DetailsInputForAcbBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            '屋外');
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
        
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        List<Object> bodyList = (List<Object>)jsonDes.get('bodyList');//メイン一覧データ
        List<Object> headerList = (List<Object>)jsonDes.get('headerList');//メイン一覧ヘッダー
        System.assertEquals(bodyList.size(), 0);
        System.assertEquals(headerList.size(), 1);
    }

    /**
     *内訳入力B_ACB盤 画面情報を取得 官需テスト
     * 
     */
    @isTest static void getInitScreenInfoMTest() {
        String qRtName='官需';
        createDate(qRtName);

        Test.startTest();
        String rtn = DetailsInputForAcbBoardController.getInitScreenInfo(false,
                                            dv.Id,
                                            '屋内');
        Test.stopTest();
        System.assertNotEquals(rtn, null);//

        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        List<Object> bodyList = (List<Object>)jsonDes.get('bodyList');//メイン一覧データ
        List<Object> headerList = (List<Object>)jsonDes.get('headerList');//メイン一覧ヘッダー
        Map<String, Object> acbSumTable = (Map<String, Object>)jsonDes.get('acbSumTable');//ACB加算
        Map<String, Object> zctTable = (Map<String, Object>)jsonDes.get('zctTable');//零相変流器+地絡過電融継電器(ZCT+51G)
        Map<String, Object> transformerDrawerTable = (Map<String, Object>)jsonDes.get('transformerDrawerTable');//計器用変圧器VT,PT(低圧）引出型
        Map<String, Object> transformerCtTable = (Map<String, Object>)jsonDes.get('transformerCtTable');// 計器用変流器 ＣＴ(低圧)
        Map<String, Object> acbTable = (Map<String, Object>)jsonDes.get('acbTable');// ACB　（エアーサーキットブレーカ）
        Map<String, Object> protectorFuseTable = (Map<String, Object>)jsonDes.get('protectorFuseTable');// プロテクタヒューズ
        Map<String, Object> takeoffFuseTable = (Map<String, Object>)jsonDes.get('takeoffFuseTable');// テイクオフヒューズ
        Map<String, Object> networkRelayTable = (Map<String, Object>)jsonDes.get('networkRelayTable');// ネットワークリレー（multicap)
        Map<String, Object> mixedTable = (Map<String, Object>)jsonDes.get('mixedTable');// 合成CT（低圧）
        Map<String, Object> networkVtTable = (Map<String, Object>)jsonDes.get('networkVtTable');// ネットワークVT（低圧）
        Map<String, Object> networkCtTable = (Map<String, Object>)jsonDes.get('networkCtTable');// ネットワークCT（低圧）
        Map<String, Object> mccbTable = (Map<String, Object>)jsonDes.get('mccbTable');// 配線用遮断器価格 （MCCB・ELB）
        Map<String, Object> installEquipTypeTable = (Map<String, Object>)jsonDes.get('installEquipTypeTable');// 取付器具類

        System.assertEquals(jsonDes.size()>0, true);
        System.assertEquals(bodyList.size()>0, true);
        System.assertEquals(headerList.size()>0, true);
        System.assertEquals(acbSumTable.size()>0, true);
        //施設以外の場合　設定しない
        System.assertEquals(zctTable, null);
        System.assertEquals(transformerDrawerTable, null);
        System.assertEquals(transformerCtTable, null);
        System.assertEquals(protectorFuseTable, null);
        System.assertEquals(takeoffFuseTable, null);
        System.assertEquals(networkRelayTable, null);
        System.assertEquals(mixedTable, null);
        System.assertEquals(networkVtTable, null);
        System.assertEquals(mccbTable, null);
        System.assertEquals(installEquipTypeTable, null);
    }

    /**
     *内訳入力B_官需 登録のテスト
     * 明細登録ありの検索テスト
     */
    @isTest static void submitMDetailsTest() {
        String qRtName='官需';
        createDate(qRtName);

        Test.startTest();

        //Optデータを準備
        List<DetailsInputForAcbBoardController.QuantityObject> optRecords 
                        = new List<DetailsInputForAcbBoardController.QuantityObject>();
        Boolean isFirst = true;
        Id classicId = null;
        for(PricingTable__c tmp:tables){
            if (tmp.BU__c=='S') {
                if (tmp.RecordTypeId == pricingRecordTypeByName.get('筐体')) {
                    if(!isFirst)continue;
                    DetailsInputForAcbBoardController.QuantityObject opt = new DetailsInputForAcbBoardController.QuantityObject();
                    classicId=tmp.Id;
                    isFirst = false;
                }else {
                    DetailsInputForAcbBoardController.QuantityObject opt = new DetailsInputForAcbBoardController.QuantityObject();
                    opt.Id=tmp.Id;
                    opt.Price=11111;
                    opt.Quantity=1;
                    optRecords.add(opt);
                }
            }
        }
        //登録
        String strSubmitDetails = DetailsInputForAcbBoardController.submitDetailsForAcbBoard(
                                            dv.Id,
                                            classicId,
                                            JSON.serialize(optRecords));

        //登録データあり場合　検索を行う
        String rtn = DetailsInputForAcbBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            'test');
        Test.stopTest();
        System.assertEquals(strSubmitDetails, dv.Quote__c);
        System.assertNotEquals(rtn, null);//
        
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        System.assertEquals(jsonDes.get('installationLocation'), '屋内');
        
    }

    /**
     *内訳入力B_全画面 登録のテスト
     * 明細登録ありの検索テスト
     */
    @isTest static void submitSDetailsTest() {
        String qRtName='施設';
        createDate(qRtName);

        Test.startTest();

        //Optデータを準備
        List<DetailsInputForAcbBoardController.QuantityObject> optRecords 
                        = new List<DetailsInputForAcbBoardController.QuantityObject>();
        Boolean isFirst = true;
        Id classicId = null;
        for(PricingTable__c tmp:tables){
            if (tmp.BU__c=='S') {
                if (tmp.RecordTypeId == pricingRecordTypeByName.get('筐体')) {
                    if(!isFirst)continue;
                    DetailsInputForAcbBoardController.QuantityObject opt = new DetailsInputForAcbBoardController.QuantityObject();
                    classicId=tmp.Id;
                    isFirst = false;
                }else {
                    DetailsInputForAcbBoardController.QuantityObject opt = new DetailsInputForAcbBoardController.QuantityObject();
                    opt.Id=tmp.Id;
                    opt.Price=11111;
                    opt.Quantity=1;
                    optRecords.add(opt);
                }
            }
        }
        //登録
        String strSubmitDetails = DetailsInputForAcbBoardController.submitDetailsForAcbBoard(
                                            dv.Id,
                                            classicId,
                                            JSON.serialize(optRecords));

        //登録データあり場合　検索を行う
        String rtn = DetailsInputForAcbBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            'test');
        Test.stopTest();
        System.assertEquals(strSubmitDetails, dv.Quote__c);
        System.assertNotEquals(rtn, null);//
        
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        System.assertEquals(jsonDes.get('installationLocation'), '屋内');
        
    }
}