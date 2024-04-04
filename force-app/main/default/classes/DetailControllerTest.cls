/**
 * 明細入力A画面コントローラーのテスト
 */
@isTest
public with sharing class DetailControllerTest {
    private static final String RECORDTYPE_NAME_DETAIL = '明細';
    private static final String RECORDTYPE_NAME_CHSSIS = '筐体';
    private static final String Frequency_50Hz = '50Hz';
    private static final String Frequency_60Hz = '60Hz';
    private static final String CATEGORYCODE_50Hz = '01';
    private static final String CATEGORYCODE_60Hz = '02';
    private static final List<String> BU_LIST = new List<String>{'S','K','M'};

    private static Quote__c quote;//見積
    private static Device__c dv;//見積項目
    private static List<PricingTable__c> tables;

    //価格表データ作成
    private static void createDate(String qRtName,String major, String minor, String powerFrequency){
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = :qRtName];
        List<RecordType> dvType = [SELECT Id FROM RecordType WHERE SobjectType = 'Device__c' and name = :qRtName];

        quote = new Quote__c(
            QuoteNumber__c = '1',
            PowerFrequency__c = powerFrequency,
            RecordTypeId = recType[0].Id
        );
        insert quote;

        dv = new Device__c(
            // QuoteSpecificationNumber__c = '001',
            Name = qRtName+ major,
            RecordTypeOfQuote__c = qRtName,
            MajorClassification__c = major,
            MinorClassification__c = minor,
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
        Integer index = 1;
        for (String bu: BU_LIST){
            for (String rtName  : pricingRecordTypeByName.keyset()) {
                Id rtId = pricingRecordTypeByName.get(rtName);
                // 価格表
                PricingTable__c table = new PricingTable__c(
                    RecordTypeId = rtId 
                    , BU__c = bu
                    , MajorClassificationCode__c = '01'
                    , MajorClassificationName__c = major
                    , MinorClassificationCode__c = '11'
                    , MinorClassificationName__c = minor
                    , CategoryCode__c = (powerFrequency==Frequency_60Hz?'02':'01')
                    , Frequency__c = powerFrequency
                    , Name1__c = 'Name1'
                    , Name2__c = 'Name2'
                    , Name3__c = 'Name3'
                    , Name4__c = 'Name4'
                    , Name5__c = 'Name5'
                    , Name6__c = 'Name6'
                    , Name7__c = 'Name7'
                    , Name8__c = 'Name8'
                    , Name9__c = 'Name9'
                    , MasterCode__c = 'MasterCode'
                    , RECNo__c = index
                );
                index = index + 1;
                tables.add(table);
                if (rtName == RECORDTYPE_NAME_CHSSIS) {
                    PricingTable__c table03 = new PricingTable__c(
                        RecordTypeId = rtId
                        , BU__c = bu
                        , MajorClassificationCode__c = '01'
                        , MajorClassificationName__c = major
                        , MinorClassificationCode__c = '11'
                        , MinorClassificationName__c = '変圧器収納盤'
                        , CategoryCode__c = '00'
                        , CategoryName__c ='変圧器収納盤'
                        , Frequency__c = powerFrequency
                        , Name1__c = '変圧器収納盤(高圧)'
                        , Name2__c = 'Name2'
                        , Name3__c = 'Name3'
                        , Name4__c = 'Name4'
                        , Name5__c = 'Name5'
                        , Name6__c = 'Name6'
                        , Name7__c = 'Name7'
                        , Name8__c = 'Name8'
                        , Name9__c = 'Name9'
                        , WC__c = 1
                        , WcCalculationRate__c = 1
                        , MasterCode__c = 'MasterCode'
                        , RECNo__c = 9
                    );
                tables.add(table03);
                }
            }
        }
        if (tables.size() > 0) insert tables;
    }
    //変圧器　パターン
    @isTest static void picklistTest1() {
        String qRtName='施設';
        String major='変圧器';
        String minor='機器事業部 変圧器';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        Test.startTest();
            //ラベル設定
            Map<String, List<Map<String, String>>> initMap =  DetailController.getUniqueNamePicklist(dv.Id,'');

            //ラベル設定
            Map<String, List<Map<String, String>>> nameChangedMap =  DetailController.getUniqueNamePicklist(dv.Id,'Name1');
        Test.stopTest();

        System.assertEquals(9, initMap.get('label').size());
        System.assertNotEquals(null, initMap.get('name1'));
        System.assertNotEquals(null, initMap.get('board1'));
        System.assertNotEquals(null, initMap.get('board2'));
        // System.assertNotEquals(null, initMap.get('board3'));
        // System.assertNotEquals(null, initMap.get('board4'));
        System.assertEquals(0, initMap.get('name2').size());
        System.assertEquals(0, initMap.get('name3').size());
        System.assertEquals(0, initMap.get('name4').size());
        System.assertEquals(0, initMap.get('name5').size());
        System.assertEquals(0, initMap.get('name6').size());

        System.assertEquals(9, nameChangedMap.get('label').size());
        System.assertNotEquals(null, nameChangedMap.get('name1'));
        System.assertNotEquals(null, nameChangedMap.get('name2'));
        System.assertNotEquals(null, nameChangedMap.get('name3'));
        System.assertNotEquals(null, nameChangedMap.get('name4'));
        System.assertNotEquals(null, nameChangedMap.get('name5'));
        System.assertNotEquals(null, nameChangedMap.get('name6'));

    }
    //名称９まで取得
    @isTest static void picklistTest2_1() {
        String qRtName='施設';
        String major='進相コンデンサ/リアクトル';
        String minor='機器事業部 低圧コンデンサ/リアクトル';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);
        Test.startTest();
            //ラベル設定
            Map<String, List<Map<String, String>>> initMap =  DetailController.getUniqueNamePicklist(dv.Id,'');            //ラベル設定
            Map<String, List<Map<String, String>>> nameChangedMap =  DetailController.getUniqueNamePicklist(dv.Id,'Name1');
        Test.stopTest();

        System.assertEquals(10, initMap.get('label').size());
        System.assertEquals(10, nameChangedMap.get('label').size());

    }
    //MELFLEX
    @isTest static void picklistTest2_2() {
        String qRtName='官需';
        String major='MELFLEX';
        String minor='';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);
        Test.startTest();
            //ラベル設定
            Map<String, List<Map<String, String>>> initMap =  DetailController.getUniqueNamePicklist(dv.Id,'');
        Test.stopTest();

        System.assertEquals(7, initMap.get('label').size());

    }
    //MACTUS
    @isTest static void picklistTest2() {
        String qRtName='水環境';
        String major='MACTUS';
        String minor='OPS';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);
        Test.startTest();
            //ラベル設定
            Map<String, List<Map<String, String>>> initMap =  DetailController.getUniqueNamePicklist(dv.Id,'');
        Test.stopTest();

        System.assertEquals(10, initMap.get('label').size());
        System.assertNotEquals(null, initMap.get('metadata1'));

    }

    //明細に既存がなし　基本パターン１
    @isTest static void searchTest1() {
        String qRtName='施設';
        String major='変圧器';
        String minor='特高変圧器';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        DetailController.PricingTableInputOnly intensify = new DetailController.PricingTableInputOnly();
        DetailController.PricingTableInputOnly  newIntensify = new DetailController.PricingTableInputOnly();
        intensify.Id = tables.get(0).Id;
        intensify.Quantity = 1;
        intensify.WCCoefficient = 1;
        intensify.CreditWC = 1;
        intensify.UnitPriceCoefficient = 1;
        intensify.ProvisionUnitPrice = 1;
        intensify.UnitWeight = 1;
        DetailController.PricingTableNewRowObj newRow = new DetailController.PricingTableNewRowObj();
        newRow.isCreate  =true;
        newRow.Id = '1rowIndex1';
        newRow.Name1 = 'Name1'; //名称１
        newRow.Name2  = 'Name2'; ///名称２
        newRow.Name3  = 'Name3'; ///名称３
        newRow.CreditWC = 1; //単位WC ※入力
        newRow.WCCoefficient = 1; //WC係数※入力
        newRow.UnitPrice = 1;//単価
        newRow.UnitPriceCoefficient = 1; //単価係数※入力
        newRow.ProvisionUnitPrice = 1; //提供単価※入力
        newRow.UnitWeight = 1; //単位重量
        newRow.Quantity = 1; //数量※入力
        newRow.WC  = 1;//WC
        newRow.Price = 1; //価格
        newRow.ProvisionPrice = 1; //提供価格
        newRow.Weight = 1; //重量
        newRow.Note = '備考';//備考
        newRow.Name4 = 'Name4';//名称４
    
        newIntensify.Id = newRow.Id;
        newIntensify.Quantity = newRow.Quantity;
        newIntensify.WCCoefficient = newRow.WCCoefficient;
        newIntensify.CreditWC = newRow.CreditWC;
        newIntensify.UnitPriceCoefficient = newRow.UnitPriceCoefficient;
        newIntensify.ProvisionUnitPrice = newRow.ProvisionUnitPrice;
        newIntensify.UnitWeight = newRow.UnitWeight;
        List<DetailController.PricingTableInputOnly> intensifyRecords 
                        = new List<DetailController.PricingTableInputOnly>{intensify,newIntensify};
        List<DetailController.PricingTableNewRowObj> newRowRecords 
                = new List<DetailController.PricingTableNewRowObj>{newRow};

        List<String> specificationNames = new List<String>{'Name1','Name2','Name3','Name4'};
        List<String> boardNames = new List<String>{'Name1','Name2','Name3','Name4'};
        List<String> searchCodes = new List<String>{'MasterCode'};
        List<String> searchName = new List<String>{'Name'};
        
        Map<String, List<String>>  searchConditions = new Map<String, List<String>>();

        Test.startTest();
        //ラベル設定
        Map<String, List<Map<String, String>>> labelMap =  DetailController.getUniqueNamePicklist(dv.Id,'');

        //初期検索
        String rtnStr1 =  DetailController.getPricingTableRecords(
                                '',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                '',
                                ''
                                );
        //画面条件指定
        searchConditions.put('specificationNames',specificationNames);
        searchConditions.put('boardNames',boardNames);
        //仕様検索
        String rtnStr2 =  DetailController.getPricingTableRecords(
                                'SpecSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        searchConditions.put('searchCodes',searchCodes);
        //コード検索
        String rtnStr3 =  DetailController.getPricingTableRecords(
                                'CodeSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        searchConditions.put('searchName',searchName);
        //名称検索
        String rtnStr4 =  DetailController.getPricingTableRecords(
                                'NameSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        //集約対象を検索する
        String rtnStr5 =  DetailController.getPricingTableByintensify(
            JSON.serialize(intensifyRecords),
            JSON.serialize(newRowRecords));

        //登録処理
       String rtnStr6 =  DetailController.setDetail(
                JSON.serialize(intensifyRecords),
                JSON.serialize(newRowRecords),
                '',
                dv.Id,
                true);
        Test.stopTest();

        System.assertNotEquals(null, rtnStr1);
        System.assertNotEquals(null, rtnStr2);
        System.assertNotEquals(null, rtnStr3);
        System.assertNotEquals(null, rtnStr4);
        System.assertNotEquals(null, rtnStr5);
        System.assertEquals(String.valueof(quote.Id), rtnStr6);


    }
    //明細に既存が存在　
    @isTest static void searchTest2() {
        String qRtName='施設';
        String major='変圧器';
        String minor='特高変圧器';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        DetailController.PricingTableInputOnly intensify = new DetailController.PricingTableInputOnly();

        intensify.Id = tables.get(0).Id;
        intensify.Quantity = 1;
        intensify.WCCoefficient = 1;
        intensify.CreditWC = 1;
        intensify.UnitPriceCoefficient = 1;
        intensify.ProvisionUnitPrice = 1;
        intensify.UnitWeight = 1;
        DetailController.PricingTableNewRowObj newRow = new DetailController.PricingTableNewRowObj();
        DetailController.PricingTableInputOnly newIntensify = new DetailController.PricingTableInputOnly();
        newRow.isCreate  =true;
        newRow.Id = '1rowIndex1';
        newRow.Name1 = 'Name1'; //名称１
        newRow.Name2  = 'Name2'; ///名称２
        newRow.Name3  = 'Name3'; ///名称３
        newRow.CreditWC = 1; //単位WC ※入力
        newRow.WCCoefficient = 1; //WC係数※入力
        newRow.UnitPrice = 1;//単価
        newRow.UnitPriceCoefficient = 1; //単価係数※入力
        newRow.ProvisionUnitPrice = 1; //提供単価※入力
        newRow.UnitWeight = 1; //単位重量
        newRow.Quantity = 1; //数量※入力
        newRow.WC  = 1;//WC
        newRow.Price = 1; //価格
        newRow.ProvisionPrice = 1; //提供価格
        newRow.Weight = 1; //重量
        newRow.Note = '備考';//備考
        newRow.Name4 = 'Name4';//名称４

        newIntensify.Id = newRow.Id;
        newIntensify.Quantity = newRow.Quantity;
        newIntensify.WCCoefficient = newRow.WCCoefficient;
        newIntensify.CreditWC = newRow.CreditWC;
        newIntensify.UnitPriceCoefficient = newRow.UnitPriceCoefficient;
        newIntensify.ProvisionUnitPrice = newRow.ProvisionUnitPrice;
        newIntensify.UnitWeight = newRow.UnitWeight;
        List<DetailController.PricingTableInputOnly> intensifyRecords 
                        = new List<DetailController.PricingTableInputOnly>{intensify,newIntensify};
        List<DetailController.PricingTableNewRowObj> newRowRecords 
                = new List<DetailController.PricingTableNewRowObj>{newRow};

        List<String> specificationNames = new List<String>{'Name1','Name2','Name3','Name4'};
        List<String> boardNames = new List<String>{'Name1','Name2','Name3','Name4'};
        List<String> searchCodes = new List<String>{'MasterCode'};
        List<String> searchName = new List<String>{'Name'};
        
        Map<String, List<String>>  searchConditions = new Map<String, List<String>>();

        Test.startTest();
        //登録処理
        String rtnStr6 =  DetailController.setDetail(
                            JSON.serialize(intensifyRecords),
                            JSON.serialize(newRowRecords),
                            '',
                            dv.Id,
                            true);

        //初期検索
        String rtnStr1 =  DetailController.getPricingTableRecords(
                                '',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                '',
                                ''
                                );
        //画面条件指定
        searchConditions.put('specificationNames',specificationNames);
        searchConditions.put('boardNames',boardNames);
        //仕様検索
        String rtnStr2 =  DetailController.getPricingTableRecords(
                                'SpecSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        searchConditions.put('searchCodes',searchCodes);
        //コード検索
        String rtnStr3 =  DetailController.getPricingTableRecords(
                                'CodeSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        searchConditions.put('searchName',searchName);
        //名称検索
        String rtnStr4 =  DetailController.getPricingTableRecords(
                                'NameSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        //集約対象を検索する
        String rtnStr5 =  DetailController.getPricingTableByintensify(
            JSON.serialize(intensifyRecords),
            JSON.serialize(newRowRecords));

        Test.stopTest();
        System.assertNotEquals(null, rtnStr1);
        System.assertNotEquals(null, rtnStr2);
        System.assertNotEquals(null, rtnStr3);
        System.assertNotEquals(null, rtnStr4);
        System.assertNotEquals(null, rtnStr5);
        System.assertEquals(String.valueof(quote.Id), rtnStr6);
    }

    //MACTUS 明細に既存が存在　
    @isTest static void searchTest3() {
        String qRtName='水環境';
        String major='MACTUS';
        String minor='OPS';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        DetailController.PricingTableInputOnly intensify = new DetailController.PricingTableInputOnly();

        intensify.Id = tables.get(0).Id;
        intensify.Quantity = 1;
        intensify.WCCoefficient = 1;
        intensify.CreditWC = 1;
        intensify.UnitPriceCoefficient = 1;
        intensify.ProvisionUnitPrice = 1;
        intensify.UnitWeight = 1;
        DetailController.PricingTableNewRowObj newRow = new DetailController.PricingTableNewRowObj();
        DetailController.PricingTableInputOnly newIntensify = new DetailController.PricingTableInputOnly();
        newRow.isCreate  =true;
        newRow.Id = '1rowIndex1';
        newRow.Name1 = 'Name1'; //名称１
        newRow.Name2  = 'Name2'; ///名称２
        newRow.Name3  = 'Name3'; ///名称３
        newRow.CreditWC = 1; //単位WC ※入力
        newRow.WCCoefficient = 1; //WC係数※入力
        newRow.UnitPrice = 1;//単価
        newRow.UnitPriceCoefficient = 1; //単価係数※入力
        newRow.ProvisionUnitPrice = 1; //提供単価※入力
        newRow.UnitWeight = 1; //単位重量
        newRow.Quantity = 1; //数量※入力
        newRow.WC  = 1;//WC
        newRow.Price = 1; //価格
        newRow.ProvisionPrice = 1; //提供価格
        newRow.Weight = 1; //重量
        newRow.Note = '備考';//備考
        newRow.Name4 = 'Name4';//名称４

        newIntensify.Id = newRow.Id;
        newIntensify.Quantity = newRow.Quantity;
        newIntensify.WCCoefficient = newRow.WCCoefficient;
        newIntensify.CreditWC = newRow.CreditWC;
        newIntensify.UnitPriceCoefficient = newRow.UnitPriceCoefficient;
        newIntensify.ProvisionUnitPrice = newRow.ProvisionUnitPrice;
        newIntensify.UnitWeight = newRow.UnitWeight;
        List<DetailController.PricingTableInputOnly> intensifyRecords 
                        = new List<DetailController.PricingTableInputOnly>{intensify,newIntensify};
        List<DetailController.PricingTableNewRowObj> newRowRecords 
                = new List<DetailController.PricingTableNewRowObj>{newRow};



        DetailController.HeaderMetaData deta = new DetailController.HeaderMetaData();
        deta.meta1 = 'Web';
        deta.meta2 = '1台';
        deta.meta3 = 'meta3';
        deta.meta4 = 'meta4';
        deta.meta5 = 'meta5';
        deta.meta6 = 'meta6';
        deta.meta7 = 'meta7';
        deta.meta8 = 'meta8';
        deta.meta9 = 'meta9';

        List<String> specificationNames = new List<String>{'Name1','Name2','Name3','Name4'};
        List<String> boardNames = new List<String>{'Name1','Name2','Name3','Name4'};
        List<String> searchCodes = new List<String>{'MasterCode'};
        List<String> searchName = new List<String>{'Name'};
        
        Map<String, List<String>>  searchConditions = new Map<String, List<String>>();

        
        Test.startTest();
        //登録処理
        String rtnStr6 =  DetailController.setDetail(
                            JSON.serialize(intensifyRecords),
                            JSON.serialize(newRowRecords),
                            JSON.serialize(deta),
                            dv.Id,
                            true);

        //初期検索
        String rtnStr1 =  DetailController.getPricingTableRecords(
                                '',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                '',
                                ''
                                );
        //画面条件指定
        searchConditions.put('specificationNames',specificationNames);
        searchConditions.put('boardNames',boardNames);
        //仕様検索
        String rtnStr2 =  DetailController.getPricingTableRecords(
                                'SpecSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        searchConditions.put('searchCodes',searchCodes);
        //コード検索
        String rtnStr3 =  DetailController.getPricingTableRecords(
                                'CodeSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        searchConditions.put('searchName',searchName);
        //名称検索
        String rtnStr4 =  DetailController.getPricingTableRecords(
                                'NameSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        //集約対象を検索する
        String rtnStr5 =  DetailController.getPricingTableByintensify(
            JSON.serialize(intensifyRecords),
            JSON.serialize(newRowRecords));

        Test.stopTest();
        System.assertNotEquals(null, rtnStr1);
        System.assertNotEquals(null, rtnStr2);
        System.assertNotEquals(null, rtnStr3);
        System.assertNotEquals(null, rtnStr4);
        System.assertNotEquals(null, rtnStr5);
        System.assertEquals(String.valueof(quote.Id), rtnStr6);
    }

    //明細に既存が存在　
    @isTest static void searchTest2_1() {
        String qRtName='施設';
        String major='変圧器';
        String minor='機器事業部 変圧器';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        DetailController.PricingTableInputOnly intensify = new DetailController.PricingTableInputOnly();

        intensify.Id = tables.get(0).Id;
        intensify.Quantity = 1;
        intensify.WCCoefficient = 1;
        intensify.CreditWC = 1;
        intensify.UnitPriceCoefficient = 1;
        intensify.ProvisionUnitPrice = 1;
        intensify.UnitWeight = 1;
        DetailController.PricingTableNewRowObj newRow = new DetailController.PricingTableNewRowObj();
        DetailController.PricingTableInputOnly newIntensify = new DetailController.PricingTableInputOnly();
        newRow.isCreate  =true;
        newRow.Id = '1rowIndex1';
        newRow.Name1 = 'Name1'; //名称１
        newRow.Name2  = 'Name2'; ///名称２
        newRow.Name3  = 'Name3'; ///名称３
        newRow.CreditWC = 1; //単位WC ※入力
        newRow.WCCoefficient = 1; //WC係数※入力
        newRow.UnitPrice = 1;//単価
        newRow.UnitPriceCoefficient = 1; //単価係数※入力
        newRow.ProvisionUnitPrice = 1; //提供単価※入力
        newRow.UnitWeight = 1; //単位重量
        newRow.Quantity = 1; //数量※入力
        newRow.WC  = 1;//WC
        newRow.Price = 1; //価格
        newRow.ProvisionPrice = 1; //提供価格
        newRow.Weight = 1; //重量
        newRow.Note = '備考';//備考
        newRow.Name4 = 'Name4';//名称４

        newIntensify.Id = newRow.Id;
        newIntensify.Quantity = newRow.Quantity;
        newIntensify.WCCoefficient = newRow.WCCoefficient;
        newIntensify.CreditWC = newRow.CreditWC;
        newIntensify.UnitPriceCoefficient = newRow.UnitPriceCoefficient;
        newIntensify.ProvisionUnitPrice = newRow.ProvisionUnitPrice;
        newIntensify.UnitWeight = newRow.UnitWeight;
        List<DetailController.PricingTableInputOnly> intensifyRecords 
                        = new List<DetailController.PricingTableInputOnly>{intensify,newIntensify};
        List<DetailController.PricingTableNewRowObj> newRowRecords 
                = new List<DetailController.PricingTableNewRowObj>{newRow};

        List<String> specificationNames = new List<String>{'Name1','Name2','Name3','Name4'};
        List<String> boardNames = new List<String>{'Name1','Name2','Name3','Name4'};
        List<String> searchCodes = new List<String>{'MasterCode'};
        List<String> searchName = new List<String>{'Name'};
        
        Map<String, List<String>>  searchConditions = new Map<String, List<String>>();

        Test.startTest();
        //登録処理
        String rtnStr6 =  DetailController.setDetail(
                            JSON.serialize(intensifyRecords),
                            JSON.serialize(newRowRecords),
                            '',
                            dv.Id,
                            true);

        //初期検索
        String rtnStr1 =  DetailController.getPricingTableRecords(
                                '',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                '',
                                ''
                                );
        //画面条件指定
        searchConditions.put('specificationNames',specificationNames);
        searchConditions.put('boardNames',boardNames);
        //仕様検索
        String rtnStr2 =  DetailController.getPricingTableRecords(
                                'SpecSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        searchConditions.put('searchCodes',searchCodes);
        //コード検索
        String rtnStr3 =  DetailController.getPricingTableRecords(
                                'CodeSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        searchConditions.put('searchName',searchName);
        //名称検索
        String rtnStr4 =  DetailController.getPricingTableRecords(
                                'NameSearch',
                                dv.Id,
                                200, 
                                1,
                                searchConditions,
                                JSON.serialize(intensifyRecords),
                                JSON.serialize(newRowRecords)
                                );
        //集約対象を検索する
        String rtnStr5 =  DetailController.getPricingTableByintensify(
            JSON.serialize(intensifyRecords),
            JSON.serialize(newRowRecords));

        Test.stopTest();
        System.assertNotEquals(null, rtnStr1);
        System.assertNotEquals(null, rtnStr2);
        System.assertNotEquals(null, rtnStr3);
        System.assertNotEquals(null, rtnStr4);
        System.assertNotEquals(null, rtnStr5);
        System.assertEquals(String.valueof(quote.Id), rtnStr6);
    }




}