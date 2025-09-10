/**
 * 明細入力B画面_リレー盤のコントローラーのテスト
 */

@isTest
private class DetailsInputForRelayBoardTest {
    private static final String RECORDTYPE_NAME_DETAIL = '明細';
    private static final String RECORDTYPE_NAME_CHSSIS = '筐体';
    private static final String Frequency_50Hz = '50Hz';
    private static final String Frequency_60Hz = '60Hz';
    private static final List<String> BU_LIST = new List<String>{'S','K','M'};

    private static Quote__c quote;//見積
    private static Device__c dv;//見積項目
    private static List<PricingTable__c> tables;

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
            QuoteSpecificationNumber__c = '001',
            Name = qRtName+'DeviceTest',
            RecordTypeOfQuote__c = qRtName,
            MajorClassification__c = '低圧・現場・リレー・ACB盤',
            MinorClassification__c = 'リレー盤',
            Quote__c =quote.Id,
            RecordTypeId = dvType[0].Id
        );
        insert dv;

        // レコードタイプ（価格表）取得
        Map<String, Id> pricingRecordTypeByName = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SobjectType = 'PricingTable__c']) {
            pricingRecordTypeByName.put(rt.Name, rt.Id);
        }
        tables = new List<PricingTable__c>();
        List<String> lst = new List<String>{'100','200','300'};
        Map<String,List<String>> commonDetails = new Map<String,List<String>>{
            // 大分類名「共通機器」かつ、低圧盤B画面取付器具類用RECNOがnull以外
            'RECNO'=>new List<String>{'1'}
        };
        // 大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤」
        Integer index = 1;
        for (String bu: BU_LIST){
            //筐体
            for (String namex : lst) {
                // 価格表
                PricingTable__c table = new PricingTable__c(
                    RecordTypeId = pricingRecordTypeByName.get('筐体') 
                    , BU__c = bu
                    , MajorClassificationName__c = '低圧・現場・リレー・ACB盤'
                    , MinorClassificationCode__c = '11'
                    , MinorClassificationName__c = '低圧盤'
                    , Frequency__c = Frequency_60Hz
                    , DisplayName__c = 'TEST'
                    , Name1__c = (bu=='S'?'屋内':'低圧盤　屋内')
                    , Name2__c = '自立SS'
                    , Name3__c = namex
                    , Name4__c = namex
                    , Name5__c = namex
                    , Name6__c = '観音開き'
                    , Name7__c = '7'
                    , Name8__c = '8'
                    , Name9__c = '9'
                    , MasterCode__c = 'MasterCode'
                    , RECNo__c = index
                );
                index = index + 1;
                tables.add(table);
            }
            PricingTable__c table_Special = new PricingTable__c(
                RecordTypeId = pricingRecordTypeByName.get('筐体') 
                , BU__c = bu
                , MajorClassificationName__c = '低圧・現場・リレー・ACB盤'
                , MinorClassificationCode__c = '11'
                , MinorClassificationName__c = '低圧盤'
                , Frequency__c = Frequency_60Hz
                , DisplayName__c = 'Test'
                , Name1__c = (bu=='S'?'屋内':'低圧盤　屋内')
                , Name2__c = '自立SS'
                , Name3__c = '800W'
                , Name4__c = '2,300H'
                , Name5__c = '600D'
                , Name6__c = '観音開き'
                , Name7__c = '7'
                , Name8__c = '8'
                , Name9__c = '9'
                , MasterCode__c = 'MasterCode'
                , RECNo__c = index
                , Price__c = 9999
            );
            index = index + 1;
            tables.add(table_Special);
            for(String mapKey:commonDetails.keySet()){
                List<String> keys = commonDetails.get(mapKey);
                for (String key:keys){
                    // 価格表
                    PricingTable__c table = new PricingTable__c(
                        RecordTypeId = pricingRecordTypeByName.get('明細') 
                        , BU__c = bu
                        , MajorClassificationName__c = '共通機器'
                        , MinorClassificationName__c = 'minor'
                        , Frequency__c = Frequency_60Hz
                        , CategoryName__c = Frequency_60Hz
                        , DisplayName__c = '配線材料費'
                        , Name1__c = (mapKey=='name1'?key:'name1Test')
                        , Name2__c = '自立SS'
                        , Name3__c = '3333333'
                        , Name4__c = '4444444'
                        , Name5__c = '5555555'
                        , Name6__c = '観音開き'
                        , Name7__c = '777777'
                        , Name8__c = '888888'
                        , Name9__c = (mapKey=='name9'?key:'name9est')
                        , Name10__c = (mapKey=='name10'?key:'name10est')
                        , RECNOforRelayBoardB_Attachment__c = (mapKey=='RECNO'?Decimal.valueof(key):null)
                        , MasterCode__c = 'MasterCode'
                        , RECNo__c = index
                    );
                    index = index + 1;
                    tables.add(table);
                }
            }
            for(String mapKey:commonDetails.keySet()){
                List<String> keys = commonDetails.get(mapKey);
                for (String key:keys){
                    // 価格表
                    PricingTable__c table_detail = new PricingTable__c(
                        RecordTypeId = pricingRecordTypeByName.get('明細') 
                        , BU__c = bu
                        , MajorClassificationName__c = '共通機器'
                        , MinorClassificationName__c = 'minor'
                        , Frequency__c = Frequency_60Hz
                        , CategoryName__c = Frequency_60Hz
                        , DisplayName__c = 'TEST01'
                        , Name1__c = (mapKey=='name1'?key:'name1Test')
                        , Name2__c = '自立SS'
                        , Name3__c = '3333333'
                        , Name4__c = '4444444'
                        , Name5__c = '5555555'
                        , Name6__c = '観音開き'
                        , Name7__c = '777777'
                        , Name8__c = '888888'
                        , Name9__c = (mapKey=='name9'?key:'name9est')
                        , Name10__c = (mapKey=='name10'?key:'name10est')
                        , RECNOforRelayBoardB_Attachment__c = (mapKey=='RECNO'?Decimal.valueof(key):null)
                        , MasterCode__c = 'MasterCode'
                        , RECNo__c = index
                    );
                    index = index + 1;
                    tables.add(table_detail);
                }
            }
        }
        if (tables.size() > 0) insert tables;
    }

    /**
     *内訳入力B_低圧配電盤 画面情報を取得 施設テスト
     * 
     */
    @isTest static void getInitScreenInfoSTest() {
        String qRtName='施設';
        createDate(qRtName);

        Test.startTest();
        String rtn = DetailsInputForRelayBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            '屋内',
                                            '自立SS',
                                            '観音開き');
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        Map<String, Object> auxiliaryRelayTable= (Map<String, Object>)jsonDes.get('auxiliaryRelayTable'); //補助継電器盤標準筐体
        List<Object> tbls = (List<Object>)jsonDes.get('classicTables');//メイン一覧ヘッダー
        Map<String, Object> installEquipTypeTable= (Map<String, Object>)jsonDes.get('installEquipTypeTable'); //取付器具類

        System.assertEquals(jsonDes.size()>0, true);
        System.assertEquals(auxiliaryRelayTable.size()>0, true);
        System.assertEquals(tbls.size()>0, true);
        System.assertEquals(installEquipTypeTable.size()>0, true);
    }

    /**
     *明細入力B_リレー盤 画面情報を取得 データなしテスト
     *
     */
    @isTest static void getInitScreenInfoNodataTest() {
        String qRtName='施設';
        createDate(qRtName);

        Test.startTest();
        String rtn = DetailsInputForRelayBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            '屋外',
                                            '自立SS',
                                            '1枚扉');
        Test.stopTest();
        System.debug('rtn='+rtn);
        System.assertNotEquals(rtn, null);//
        
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        List<Object> tbls = (List<Object>)jsonDes.get('classicTables');//メイン一覧データ
        System.assertEquals(tbls.size(), 0);
    }

    /**
     *内訳入力B_全画面 登録のテスト
     * 明細登録ありの検索テスト
     */
    @isTest static void submitDetailsTest() {
        String qRtName='施設';
        createDate(qRtName);

        Test.startTest();

        //Optデータを準備
        List<DetailsInputForRelayBoardController.QuantityObject> optRecords 
        = new List<DetailsInputForRelayBoardController.QuantityObject>();

        for(PricingTable__c tmp:tables){
            if (tmp.BU__c=='S') {
                DetailsInputForRelayBoardController.QuantityObject opt = new DetailsInputForRelayBoardController.QuantityObject();
                opt.Id=tmp.Id;
                opt.Price=11111;
                opt.Quantity=1;
                optRecords.add(opt);
            }
        }
        //登録
        String strSubmitDetails = DetailsInputForRelayBoardController.submitDetailsForRelayBoard(
                                            dv.Id,
                                            tables.get(0).Id,
                                            JSON.serialize(optRecords));

        //登録データあり場合　検索を行う
        String rtn = DetailsInputForRelayBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            'test',
                                            'test',
                                            'test');
        Test.stopTest();
        System.debug('strSubmitDetails'+strSubmitDetails);
        System.debug('dv.Quote__c'+dv.Quote__c);
        System.assertEquals(strSubmitDetails, dv.Quote__c);
        System.assertNotEquals(rtn, null);//
        
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        System.assertEquals(jsonDes.get('installationLocation'), '屋内');
        System.assertEquals(jsonDes.get('housingSpecifications'), '自立SS');
        System.assertEquals(jsonDes.get('doorSpecifications'), '観音開き');
        
    } 

}