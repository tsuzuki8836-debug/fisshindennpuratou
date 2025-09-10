/**
 * 明細入力B画面_現場盤のコントローラーのテスト
 */

 @isTest
 private class DetailsInputForFieldBoardControllerTest {
     private static final String RECORDTYPE_NAME_DETAIL = '明細';
     private static final String RECORDTYPE_NAME_CHSSIS = '筐体';
     private static final String Frequency_50Hz = '50Hz';
     private static final String Frequency_60Hz = '60Hz';
     private static final String Frequency_00Hz = '00Hz';
     private static final List<String> BU_LIST = new List<String>{'S','K','M'};
 
     private static Quote__c quote;//見積
     private static Device__c dv;//見積項目
     private static List<PricingTable__c> tables;
 
     //価格表データ作成
     private static void createData(String qRtName){
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
            MinorClassification__c = '現場盤',
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
        List<String> lst = new List<String>{'200','300','400','500'};
        Map<String,List<String>> commonDetails = new Map<String,List<String>>{
            // 大分類名「共通機器」かつ、名称1「配線用遮断器」
            'name1'=> new List<String>{'配線用遮断器'},
            // 大分類名「共通機器」かつ、名称10「起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】」
            // 大分類名「共通機器」かつ、名称10「電磁開閉器（MC）」
            'name10'=> new List<String>{'起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】','電磁開閉器(MC)'},
            // 大分類名「共通機器」かつ、現場盤B画面指示計類用RECNOがnull以外
            // 大分類名「共通機器」かつ、現場盤B画面取付器具類用RECNOがnull以外
            'RECNO'=>new List<String>{'1'}
        };
        // 大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤」
        Integer index = 1;
        for (String bu: BU_LIST){
            //低圧盤筐体
            for (String namex : lst) {
                // 価格表
                PricingTable__c table = new PricingTable__c(
                    RecordTypeId = pricingRecordTypeByName.get('筐体') 
                    , BU__c = bu
                    , MajorClassificationName__c = '低圧・現場・リレー・ACB盤'
                    , MinorClassificationCode__c = '11'
                    , MinorClassificationName__c = '低圧盤'
                    , Frequency__c = Frequency_00Hz
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
            index = 1;
            //現場盤壁掛筐体
            for (String namex : lst) {
                // 価格表
                PricingTable__c table = new PricingTable__c(
                    RecordTypeId = pricingRecordTypeByName.get('筐体') 
                    , BU__c = bu
                    , MajorClassificationName__c = '低圧・現場・リレー・ACB盤'
                    , MinorClassificationCode__c = '12'
                    , MinorClassificationName__c = '現場盤'
                    , Frequency__c = Frequency_00Hz
                    , DisplayName__c = '現場盤テスト'
                    , Name1__c = (bu=='S'?'屋内':'現場盤　屋内')
                    , Name2__c = '壁掛SS'
                    , Name3__c = namex
                    , Name4__c = namex
                    , Name5__c = namex
                    , Name6__c = '6'
                    , Name7__c = '7'
                    , Name8__c = '8'
                    , Name9__c = '9'
                    , MasterCode__c = 'MasterCode'
                    , RECNo__c = index
                );
                index = index + 1;
                tables.add(table);
            }
            // 防爆形筐体
            PricingTable__c table_Special = new PricingTable__c(
                RecordTypeId = pricingRecordTypeByName.get('筐体') 
                , BU__c = bu
                , MajorClassificationName__c = '低圧・現場・リレー・ACB盤'
                , MinorClassificationCode__c = '12'
                , MinorClassificationName__c = '現場盤'
                , Frequency__c = Frequency_00Hz
                , DisplayName__c = '筐体 現場盤　防爆形 壁掛 W300 H360 D160'
                , Name1__c = '現場盤　防爆形'
                , Name2__c = '壁掛'
                , Name3__c = 'W300'
                , Name4__c = 'H360'
                , Name5__c = 'D160'
                , Name6__c = ''
                , Name7__c = ''
                , Name8__c = ''
                , Name9__c = ''
                , MasterCode__c = 'MasterCode'
                , RECNo__c = index
                , Price__c = 10000
            );
            tables.add(table_Special);
            index = 1;
            // ポスト（スタンド）形の場合の加算価格
            PricingTable__c table_PostAdd = new PricingTable__c(
                RecordTypeId = pricingRecordTypeByName.get('明細') 
                , BU__c = bu
                , MajorClassificationName__c = '低圧・現場・リレー・ACB盤'
                , MinorClassificationCode__c = '12'
                , MinorClassificationName__c = '現場盤'
                , Frequency__c = Frequency_00Hz
                , DisplayName__c = '壁掛→ポスト(スタンド型)加算SS'
                , Name1__c = '壁掛→ポスト(スタンド型)加算SS'
                , Name2__c = '2'
                , Name3__c = '3'
                , Name4__c = '4'
                , Name5__c = '5'
                , Name6__c = '6'
                , Name7__c = '7'
                , Name8__c = '8'
                , Name9__c = '9'
                , MasterCode__c = 'MasterCode'
                , RECNo__c = index
                , Price__c = 9999
            );
            tables.add(table_PostAdd);
            index = index + 1;
            for(String mapKey:commonDetails.keySet()){
                List<String> keys = commonDetails.get(mapKey);
                for (String key:keys){
                    // 価格表
                    PricingTable__c table = new PricingTable__c(
                        RecordTypeId = pricingRecordTypeByName.get('明細') 
                        , BU__c = bu
                        , MajorClassificationName__c = '共通機器'
                        , MinorClassificationName__c = 'minor'
                        , Frequency__c = Frequency_00Hz
                        , CategoryName__c = Frequency_00Hz
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
                        , RECNOforFieldBoard__c = (mapKey=='RECNO'?Decimal.valueof(key):null)
                        , RECNOforFieldBoardB_Attachment__c = (mapKey=='RECNO'?Decimal.valueof(key):null)
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
                    PricingTable__c table = new PricingTable__c(
                        RecordTypeId = pricingRecordTypeByName.get('明細') 
                        , BU__c = bu
                        , MajorClassificationName__c = '共通機器'
                        , MinorClassificationName__c = 'minor'
                        , Frequency__c = Frequency_00Hz
                        , CategoryName__c = Frequency_00Hz
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
                        , RECNOforFieldBoard__c = (mapKey=='RECNO'?Decimal.valueof(key):null)
                        , RECNOforFieldBoardB_Attachment__c = (mapKey=='RECNO'?Decimal.valueof(key):null)
                        , MasterCode__c = 'MasterCode'
                        , RECNo__c = index
                    );
                    index = index + 1;
                    tables.add(table);
                }
            }
         }
         if (tables.size() > 0) insert tables;
     }
 
    /**
     *内訳入力B_現場盤 画面情報を取得 施設テスト
    * 
    */
    @isTest static void getInitScreenInfoSTest() {
        String qRtName='施設';
        createData(qRtName);

        Test.startTest();
        String rtn = DetailsInputForFieldBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            '屋内',
                                            '自立SS',
                                            '観音開き');
        Test.stopTest();
        System.assertNotEquals(rtn, null);
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        Map<String, Object> mccbTable = (Map<String, Object>)jsonDes.get('mccbTable');//配線用遮断器価格 （MCCB・ELB）
        Map<String, Object> installEquipTypeTable= (Map<String, Object>)jsonDes.get('installEquipTypeTable'); //取付器具類
        Map<String, Object> startupCircuitTable= (Map<String, Object>)jsonDes.get('startupCircuitTable'); //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
        Map<String, Object> electroSwitchTable= (Map<String, Object>)jsonDes.get('electroSwitchTable'); // 電磁開閉器（MC）
        List<Object> tbls = (List<Object>)jsonDes.get('classicTables');//メイン表（低圧配電盤筐体一覧）データ
        List<Object> fieldTables = (List<Object>)jsonDes.get('fieldTables');//メイン表（壁掛盤筐体一覧）データ
        // List<Object> fieldHeaderList = (List<Object>)jsonDes.get('fieldHeaderList');//メイン表（壁掛盤筐体一覧）ヘッダー
        List<Object> postAddBodyList = (List<Object>)jsonDes.get('postAddBodyList');//ポスト（スタンド）形の場合の加算価格データ
        List<Object> postAddHeaderList = (List<Object>)jsonDes.get('postAddHeaderList');//ポスト（スタンド）形の場合の加算価格ヘッダー
        List<Object> wallSpBodyList = (List<Object>)jsonDes.get('wallSpBodyList');//防爆形筐体価格データ
        List<Object> wallSpHeaderList = (List<Object>)jsonDes.get('wallSpHeaderList');//防爆形筐体価格ヘッダー

        System.assertEquals(jsonDes.size()>0, true);
        System.assertEquals(mccbTable.size()>0, true);
        System.assertEquals(installEquipTypeTable.size()>0, true);
        System.assertEquals(startupCircuitTable, null);
        System.assertEquals(electroSwitchTable.size()>0, true);
        System.assertEquals(tbls.size()>0, true);
        System.assertEquals(fieldTables.size()>0, true);
        // System.assertEquals(fieldHeaderList.size()>0, true);
        System.assertEquals(postAddBodyList, null);
        System.assertEquals(postAddHeaderList, null);
        System.assertEquals(wallSpBodyList, null);
        System.assertEquals(wallSpHeaderList, null);
    }

    /**
     *内訳入力B_現場盤 画面情報を取得 水環境テスト
    * 
    */
    @isTest static void getInitScreenInfoMTest() {
        String qRtName='水環境';
        createData(qRtName);

        Test.startTest();
        String rtn = DetailsInputForFieldBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            '屋内',
                                            '自立SS',
                                            '観音開き');
        Test.stopTest();
        System.assertNotEquals(rtn, null);
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        Map<String, Object> mccbTable = (Map<String, Object>)jsonDes.get('mccbTable');//配線用遮断器価格 （MCCB・ELB）
        Map<String, Object> installEquipTypeTable= (Map<String, Object>)jsonDes.get('installEquipTypeTable'); //取付器具類
        Map<String, Object> startupCircuitTable= (Map<String, Object>)jsonDes.get('startupCircuitTable'); //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
        Map<String, Object> electroSwitchTable= (Map<String, Object>)jsonDes.get('electroSwitchTable'); // 電磁開閉器（MC）
        List<Object> tbls = (List<Object>)jsonDes.get('classicTables');//メイン表（低圧配電盤筐体一覧）データ
        List<Object> fieldTables = (List<Object>)jsonDes.get('fieldTables');//メイン表（壁掛盤筐体一覧）データ
        // List<Object> fieldHeaderList = (List<Object>)jsonDes.get('fieldHeaderList');//メイン表（壁掛盤筐体一覧）ヘッダー
        List<Object> postAddBodyList = (List<Object>)jsonDes.get('postAddBodyList');//ポスト（スタンド）形の場合の加算価格データ
        List<Object> postAddHeaderList = (List<Object>)jsonDes.get('postAddHeaderList');//ポスト（スタンド）形の場合の加算価格ヘッダー
        List<Object> wallSpBodyList = (List<Object>)jsonDes.get('wallSpBodyList');//防爆形筐体価格データ
        List<Object> wallSpHeaderList = (List<Object>)jsonDes.get('wallSpHeaderList');//防爆形筐体価格ヘッダー

        System.assertEquals(jsonDes.size()>0, true);
        System.assertEquals(mccbTable.size()>0, true);
        System.assertEquals(installEquipTypeTable.size()>0, true);
        System.assertEquals(startupCircuitTable.size()>0, true);
        System.assertEquals(electroSwitchTable.size()>0, true);
        System.assertEquals(tbls.size()>0, true);
        System.assertEquals(fieldTables.size()>0, true);
        // System.assertEquals(fieldHeaderList.size()>0, true);
        System.assertEquals(postAddBodyList, null);
        System.assertEquals(postAddHeaderList, null);
        System.assertEquals(wallSpBodyList, null);
        System.assertEquals(wallSpHeaderList, null);
    }

    /**
     *内訳入力B_現場盤 画面情報を取得 壁掛テスト
    * 
    */
    @isTest static void getInitScreenInfoWallTest() {
        String qRtName='水環境';
        createData(qRtName);

        Test.startTest();
        String rtn = DetailsInputForFieldBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            '壁掛',
                                            '',
                                            '');
        Test.stopTest();
        System.assertNotEquals(rtn, null);
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        Map<String, Object> mccbTable = (Map<String, Object>)jsonDes.get('mccbTable');//配線用遮断器価格 （MCCB・ELB）
        Map<String, Object> installEquipTypeTable= (Map<String, Object>)jsonDes.get('installEquipTypeTable'); //取付器具類
        Map<String, Object> startupCircuitTable= (Map<String, Object>)jsonDes.get('startupCircuitTable'); //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
        Map<String, Object> electroSwitchTable= (Map<String, Object>)jsonDes.get('electroSwitchTable'); // 電磁開閉器（MC）
        List<Object> tbls = (List<Object>)jsonDes.get('classicTables');//メイン表（低圧配電盤筐体一覧）データ
        List<Object> fieldTables = (List<Object>)jsonDes.get('fieldTables');//メイン表（壁掛盤筐体一覧）データ
        // List<Object> fieldHeaderList = (List<Object>)jsonDes.get('fieldHeaderList');//メイン表（壁掛盤筐体一覧）ヘッダー
        List<Object> postAddBodyList = (List<Object>)jsonDes.get('postAddBodyList');//ポスト（スタンド）形の場合の加算価格データ
        List<Object> postAddHeaderList = (List<Object>)jsonDes.get('postAddHeaderList');//ポスト（スタンド）形の場合の加算価格ヘッダー
        List<Object> wallSpBodyList = (List<Object>)jsonDes.get('wallSpBodyList');//防爆形筐体価格データ
        List<Object> wallSpHeaderList = (List<Object>)jsonDes.get('wallSpHeaderList');//防爆形筐体価格ヘッダー

        System.assertEquals(jsonDes.size()>0, true);
        System.assertEquals(mccbTable.size()>0, true);
        System.assertEquals(installEquipTypeTable.size()>0, true);
        System.assertEquals(startupCircuitTable.size()>0, true);
        System.assertEquals(electroSwitchTable.size()>0, true);
        System.assertEquals(tbls, null);
        System.assertEquals(fieldTables.size()>0, true);
        // System.assertEquals(fieldHeaderList.size()>0, true);
        System.assertEquals(postAddBodyList.size()>0, true);
        System.assertEquals(postAddHeaderList.size()>0, true);
        System.assertEquals(wallSpBodyList, null);
        System.assertEquals(wallSpHeaderList, null);
    }

    /**
     *内訳入力B_現場盤 画面情報を取得 防爆形テスト
    * 
    */
    @isTest static void getInitScreenInfoWallSpTest() {
        String qRtName='水環境';
        createData(qRtName);

        Test.startTest();
        String rtn = DetailsInputForFieldBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            '防爆形',
                                            '',
                                            '');
        Test.stopTest();
        System.assertNotEquals(rtn, null);
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        Map<String, Object> mccbTable = (Map<String, Object>)jsonDes.get('mccbTable');//配線用遮断器価格 （MCCB・ELB）
        Map<String, Object> installEquipTypeTable= (Map<String, Object>)jsonDes.get('installEquipTypeTable'); //取付器具類
        Map<String, Object> startupCircuitTable= (Map<String, Object>)jsonDes.get('startupCircuitTable'); //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
        Map<String, Object> electroSwitchTable= (Map<String, Object>)jsonDes.get('electroSwitchTable'); // 電磁開閉器（MC）
        List<Object> tbls = (List<Object>)jsonDes.get('classicTables');//メイン表（低圧配電盤筐体一覧）データ
        List<Object> fieldTables = (List<Object>)jsonDes.get('fieldTables');//メイン表（壁掛盤筐体一覧）データ
        // List<Object> fieldHeaderList = (List<Object>)jsonDes.get('fieldHeaderList');//メイン表（壁掛盤筐体一覧）ヘッダー
        List<Object> postAddBodyList = (List<Object>)jsonDes.get('postAddBodyList');//ポスト（スタンド）形の場合の加算価格データ
        List<Object> postAddHeaderList = (List<Object>)jsonDes.get('postAddHeaderList');//ポスト（スタンド）形の場合の加算価格ヘッダー
        List<Object> wallSpBodyList = (List<Object>)jsonDes.get('wallSpBodyList');//防爆形筐体価格データ
        List<Object> wallSpHeaderList = (List<Object>)jsonDes.get('wallSpHeaderList');//防爆形筐体価格ヘッダー

        System.assertEquals(jsonDes.size()>0, true);
        System.assertEquals(mccbTable.size()>0, true);
        System.assertEquals(installEquipTypeTable.size()>0, true);
        System.assertEquals(startupCircuitTable.size()>0, true);
        System.assertEquals(electroSwitchTable.size()>0, true);
        System.assertEquals(tbls, null);
        System.assertEquals(fieldTables.size()>0, true);
        // System.assertEquals(fieldHeaderList.size()>0, true);
        System.assertEquals(postAddBodyList, null);
        System.assertEquals(postAddHeaderList, null);
        System.assertEquals(wallSpBodyList.size()>0, true);
        System.assertEquals(wallSpHeaderList.size()>0, true);
    }
 
     /**
      *明細入力B_現場盤 画面情報を取得 データなしテスト
      *
      */
     @isTest static void getInitScreenInfoNodataTest() {
        String qRtName='施設';
        createData(qRtName);

        Test.startTest();
        String rtn = DetailsInputForFieldBoardController.getInitScreenInfo(true,
                                            dv.Id,
                                            '屋外',
                                            '自立SS',
                                            '1枚扉');
        Test.stopTest();
        System.debug('rtn='+rtn);
        System.assertNotEquals(rtn, null);
        
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        List<Object> tbls = (List<Object>)jsonDes.get('classicTables');//メイン表（低圧配電盤筐体一覧）データ
        List<Object> fieldTables = (List<Object>)jsonDes.get('fieldTables');//メイン表（壁掛盤筐体一覧）データ
        // List<Object> fieldHeaderList = (List<Object>)jsonDes.get('fieldHeaderList');//メイン表（壁掛盤筐体一覧）ヘッダー
        List<Object> postAddBodyList = (List<Object>)jsonDes.get('postAddBodyList');//ポスト（スタンド）形の場合の加算価格データ
        List<Object> postAddHeaderList = (List<Object>)jsonDes.get('postAddHeaderList');//ポスト（スタンド）形の場合の加算価格ヘッダー
        List<Object> wallSpBodyList = (List<Object>)jsonDes.get('wallSpBodyList');//防爆形筐体価格データ
        List<Object> wallSpHeaderList = (List<Object>)jsonDes.get('wallSpHeaderList');//防爆形筐体価格ヘッダー
        System.debug('jsonDes'+jsonDes.get('isFieldNodata'));
        System.assertEquals(jsonDes.get('isFieldNodata'), null);
        System.debug('jsonDes'+jsonDes.get('isPostAddNodata'));
        System.assertEquals(jsonDes.get('isPostAddNodata'), null);
        System.debug('jsonDes'+jsonDes.get('isWallSpNodata'));
        System.assertEquals(jsonDes.get('isWallSpNodata'), null);
        System.assertEquals(tbls,null);
        System.assertEquals(fieldTables.size()>0, true);
        // System.assertNotEquals(fieldHeaderList.size(), 0);
        System.assertEquals(postAddBodyList, null);
        System.assertEquals(postAddHeaderList, null);
        System.assertEquals(wallSpBodyList, null);
        System.assertEquals(wallSpHeaderList, null);
     }
 
    /**
     *明細入力B_現場盤画面 登録のテスト
    * 低圧盤筐体&明細登録ありの検索テスト
    */
    @isTest static void submitDetailsTest() {
        String qRtName='施設';
        createData(qRtName);

        Test.startTest();

        //Optデータを準備
        List<DetailsInputForFieldBoardController.QuantityObject> optRecords 
        = new List<DetailsInputForFieldBoardController.QuantityObject>();

        for(PricingTable__c tmp:tables){
            if (tmp.BU__c=='S') {
                DetailsInputForFieldBoardController.QuantityObject opt = new DetailsInputForFieldBoardController.QuantityObject();
                opt.Id=tmp.Id;
                opt.Price=11111;
                opt.Quantity=1;
                optRecords.add(opt);
            }
        }
        //登録
        String strSubmitDetails = DetailsInputForFieldBoardController.submitDetailsForFieldBoard(
                                            dv.Id,
                                            tables.get(0).Id,
                                            JSON.serialize(optRecords));

        //登録データあり場合　検索を行う
        String rtn = DetailsInputForFieldBoardController.getInitScreenInfo(true,
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

    /**
     *明細入力B_現場盤画面 登録のテスト
    * 現場盤筐体&明細登録ありの検索テスト
    */
    @isTest static void submitDetailsTest2() {
        String qRtName='水環境';
        createData(qRtName);

        Test.startTest();

        //Optデータを準備
        List<DetailsInputForFieldBoardController.QuantityObject> optRecords 
        = new List<DetailsInputForFieldBoardController.QuantityObject>();

        for(PricingTable__c tmp:tables){
            if (tmp.BU__c=='M') {
                DetailsInputForFieldBoardController.QuantityObject opt = new DetailsInputForFieldBoardController.QuantityObject();
                opt.Id=tmp.Id;
                opt.Price=11111;
                opt.Quantity=1;
                optRecords.add(opt);
            }
        }
        //登録
        List<PricingTable__c> testChassis = [SELECT Id,Name1__c FROM PricingTable__c WHERE BU__c = 'M' AND DisplayName__c = '現場盤テスト' LIMIT 1];
        String strSubmitDetails = DetailsInputForFieldBoardController.submitDetailsForFieldBoard(
                                            dv.Id,
                                            testChassis.get(0).Id,
                                            JSON.serialize(optRecords));

        //登録データあり場合　検索を行う
        String rtn = DetailsInputForFieldBoardController.getInitScreenInfo(true,
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
        System.assertEquals(jsonDes.get('installationLocation'), '壁掛');
        System.assertEquals(jsonDes.get('housingSpecifications'), '');
        System.assertEquals(jsonDes.get('doorSpecifications'), '');
        
    }

    /**
     *明細入力B_現場盤画面 登録のテスト
    * 防爆形筐体&明細登録ありの検索テスト
    */
    @isTest static void submitDetailsTest3() {
        String qRtName='水環境';
        createData(qRtName);

        Test.startTest();

        //Optデータを準備
        List<DetailsInputForFieldBoardController.QuantityObject> optRecords 
        = new List<DetailsInputForFieldBoardController.QuantityObject>();

        for(PricingTable__c tmp:tables){
            if (tmp.BU__c=='M') {
                DetailsInputForFieldBoardController.QuantityObject opt = new DetailsInputForFieldBoardController.QuantityObject();
                opt.Id=tmp.Id;
                opt.Price=11111;
                opt.Quantity=1;
                optRecords.add(opt);
            }
        }
        //登録
        List<PricingTable__c> testChassis = [SELECT Id,Name1__c FROM PricingTable__c WHERE BU__c = 'M' AND DisplayName__c = '筐体 現場盤　防爆形 壁掛 W300 H360 D160' LIMIT 1];
        String strSubmitDetails = DetailsInputForFieldBoardController.submitDetailsForFieldBoard(
                                            dv.Id,
                                            testChassis.get(0).Id,
                                            JSON.serialize(optRecords));

        //登録データあり場合　検索を行う
        String rtn = DetailsInputForFieldBoardController.getInitScreenInfo(true,
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
        System.assertEquals(jsonDes.get('installationLocation'), '防爆形');
        System.assertEquals(jsonDes.get('housingSpecifications'), '');
        System.assertEquals(jsonDes.get('doorSpecifications'), '');
        
    }

 }