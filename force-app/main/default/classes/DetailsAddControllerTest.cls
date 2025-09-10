/**
 * 明細追加画面コントローラーのテスト
 */
@isTest
public with sharing class  DetailsAddControllerTest {
    private static final String RECORDTYPE_NAME_DETAIL = '明細';
    private static final String RECORDTYPE_NAME_CHSSIS = '筐体';
    private static final String Frequency_50Hz = '50Hz';
    private static final String Frequency_60Hz = '60Hz';
    private static final String CATEGORYCODE_50Hz = '01';
    private static final String CATEGORYCODE_60Hz = '02';
    private static final List<String> BU_LIST = new List<String>{'S','K','M'};
    private static SymbolObject__mdt mdtObj = [Select Id,SymbolID__c,
                                                SymbolName__c,CharacterSymbol__c,
                                                InstrumentSymbol__c
                                            From SymbolObject__mdt 
                                            LIMIT 1];
    private static Quote__c quote;//見積
    private static Device__c dv;//見積項目
    private static Device__c dv1;//見積項目１
    private static List<PricingTable__c> tables;

    //価格表データ作成
    private static void createDate(String qRtName,String major, String minor, String powerFrequency){
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = :qRtName];
        List<RecordType> dvType = [SELECT Id FROM RecordType WHERE SobjectType = 'Device__c' and name = :qRtName];

        //見積
        quote = new Quote__c(
            QuoteNumber__c = '1',
            PowerFrequency__c = powerFrequency,
            RecordTypeId = recType[0].Id
        );
        insert quote;
        //見積項目
        dv = new Device__c(
            Name = qRtName+ major,
            QuoteSpecificationNumber__c = '111111',
            RecordTypeOfQuote__c = qRtName,
            MajorClassification__c = major,
            MinorClassification__c = minor,
            Quote__c =quote.Id,
            RecordTypeId = dvType[0].Id
        );
        insert dv;

        //見積項目１
        dv1 = new Device__c(
            Name = qRtName+ major+'01',
            QuoteSpecificationNumber__c = '222222',
            RecordTypeOfQuote__c = qRtName,
            MajorClassification__c = major,
            MinorClassification__c = minor,
            Quote__c =quote.Id,
            RecordTypeId = dvType[0].Id
        );
        insert dv1;

        // レコードタイプ（価格表）取得
        Map<String, Id> pricingRecordTypeByName = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SobjectType = 'PricingTable__c']) {
            pricingRecordTypeByName.put(rt.Name, rt.Id);
        }

        //登録用価格表リスト
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
                    , CharacterSymbol__c = mdtObj.CharacterSymbol__c
                    , EquipmentNumber__c = mdtObj.InstrumentSymbol__c
                    , Name1__c = 'Name1'
                    , Name2__c = 'EP=WC×2'
                    , Name3__c = 'Name3'
                    , Name4__c = 'Name4'
                    , Name5__c = 'Name5'
                    , Name6__c = 'Name6'
                    , Name7__c = 'Name7'
                    , Name8__c = 'Name8'
                    , Name9__c = 'Name9'
                    , MasterCode__c = 'MasterCode'
                    , WC__c = 1
                    , Note__c = (major=='高圧コンビ'?'note':'')
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
                        , MinorClassificationName__c = minor
                        , CategoryCode__c = '03'
                        , CategoryName__c ='変圧器収納盤（高圧）'
                        , Frequency__c = powerFrequency
                        , CharacterSymbol__c = mdtObj.CharacterSymbol__c
                        , EquipmentNumber__c = mdtObj.InstrumentSymbol__c
                        , Name1__c = 'Name1'
                        , Name2__c = 'EP=WC×2'
                        , Name3__c = 'Name3'
                        , Name4__c = 'Name4'
                        , Name5__c = 'Name5'
                        , Name6__c = 'Name6'
                        , Name7__c = 'Name7'
                        , Name8__c = 'Name8'
                        , Name9__c = 'Name9'
                        , MasterCode__c = 'MasterCode'
                        , WC__c = 1
                        , RECNo__c = 9
                    );
                    tables.add(table03);
                }
            }
        }
        if (tables.size() > 0) insert tables;
    }

    //図記号画面の一覧
    @isTest static void getSymbolObjectRecordsTest() {
        String qRtName='施設';
        String major='変圧器';
        String minor='高圧変圧器';
        String powerFrequency='60Hz';

        createDate(qRtName,major, minor, powerFrequency);
        Test.startTest();
        //図記号画面の一覧を検索する
        String str =  DetailsAddController.getSymbolObjectRecords();

        //図検索
        String strImage = DetailsAddController.getPricingTableRecordsByImage(
                                dv.Id, 
                                new List<String>{mdtObj.Id},
                                500,
                                1,
                                null);
        Test.stopTest();

        System.assertNotEquals(null, str);
        List<DetailsAddController.SymbolObject> rtnList = (List<DetailsAddController.SymbolObject>)JSON.deserialize(str, List<DetailsAddController.SymbolObject>.class);
        System.assertEquals(rtnList.size()>0, true);

        System.assertNotEquals(null, strImage);

    }
    //Buが変わった
    //見積番号が変わった
    //マスター検索
    @isTest static void priceTableTest() {
        String qRtName='施設';
        String major='変圧器';
        String minor='機器事業部 変圧器';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        Test.startTest();
        //BUが選択の場合、大分類、見積番号のプルダウンリストを取得
        Map<String, List<Map<String, String>>> res =  DetailsAddController.pickedBUAfter('S');

        //大分類が選択の場合、小分類のプルダウンリストを取得
        Map<String, List<Map<String, String>>> resMajor =  DetailsAddController.pickedMajorAfter('S',major);

        //見積番号が選択の場合、項目番号のプルダウンリストを取得
        Map<String, List<Map<String, String>>> resQuoteNumber =  DetailsAddController.pickedQuoteNumberAfter(quote.Id,dv.Id);

        //マスター検索
        String strMaster = DetailsAddController.getPricingTableRecords(
                            dv.Id,'S',
                            major,
                            minor,
                            500,
                            1,
                            null
                            );

        List<DetailsAddController.PricingTableInputOnly> intensifyList = new List<DetailsAddController.PricingTableInputOnly>();
        
        for (Integer i = 0;i<tables.size();i++) {
            if (tables.get(i).BU__c == 'S') {
                DetailsAddController.PricingTableInputOnly intensify = new DetailsAddController.PricingTableInputOnly();
                intensify.Id = tables.get(i).Id;
                intensify.Quantity = 1;
                intensify.WCCoefficient = 1;
                intensify.CreditWC = 1;
                intensify.UnitPriceCoefficient = 1;
                intensify.ProvisionUnitPrice = 1;
                intensify.UnitWeight = 1;
                intensify.WC = 1;
                intensify.Price = 1;
                intensify.ProvisionPrice = 1;
                intensify.Weight = 1;
                intensifyList.add(intensify);
            }
        }
       //価格表を基に登録された場合
        String strSubmitDetails = DetailsAddController.submitDetails(JSON.serialize(intensifyList), dv.Id);
        Test.stopTest();

        System.assertEquals(res.get('quoteNumber').size(), 1);
        System.assertEquals(res.get('major').size(), 1);
        System.assertEquals(resMajor.get('minor').size(), 1);
        System.assertEquals(resQuoteNumber.get('name').size(), 1);
        System.assertNotEquals(null, strMaster);
        System.assertEquals(strSubmitDetails, dv.Quote__c);
    }

    //マスター検索
    @isTest static void priceTableTest_1() {
        String qRtName='施設';
        String major='高圧コンビ';
        String minor='高圧コンビ盤';
        String powerFrequency='60Hz';

        createDate(qRtName,major, minor, powerFrequency);

        Test.startTest();
        //マスター検索
        String strMaster = DetailsAddController.getPricingTableRecords(
                            dv.Id,'S',
                            major,
                            minor,
                            500,
                            1,
                            null
                            );

        List<DetailsAddController.PricingTableInputOnly> intensifyList = new List<DetailsAddController.PricingTableInputOnly>();
        
        for (Integer i = 0;i<tables.size();i++) {
            if (tables.get(i).BU__c == 'S') {
                DetailsAddController.PricingTableInputOnly intensify = new DetailsAddController.PricingTableInputOnly();
                intensify.Id = tables.get(i).Id;
                intensify.Quantity = 1;
                intensify.WCCoefficient = 1;
                intensify.CreditWC = 1;
                intensify.UnitPriceCoefficient = 1;
                intensify.ProvisionUnitPrice = 1;
                intensify.UnitWeight = 1;
                intensify.WC = 1;
                intensify.Price = 1;
                intensify.ProvisionPrice = 1;
                intensify.Weight = 1;
                intensifyList.add(intensify);
            }
        }
       //価格表を基に登録された場合
        String strSubmitDetails = DetailsAddController.submitDetails(JSON.serialize(intensifyList), dv.Id);

        //登録した後にマスター検索
        String strMasterAfter = DetailsAddController.getPricingTableRecords(
                            dv.Id,'S',
                            major,
                            minor,
                            500,
                            1,
                            JSON.serialize(intensifyList)
                            );

        Test.stopTest();
        System.assertNotEquals(null, strMaster);
        System.assertNotEquals(null, strMasterAfter);
        System.assertEquals(strSubmitDetails, dv.Quote__c);
    }

    //マスター検索
    @isTest static void priceTableTest_2() {
        String qRtName='水環境';
        String major='計装機器';
        String minor='計装盤';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        Test.startTest();
        //図検索
        String strImage = DetailsAddController.getPricingTableRecordsByImage(
            dv.Id, 
            new List<String>{mdtObj.Id},
            500,
            1,
            null);
        //マスター検索
        String strMaster = DetailsAddController.getPricingTableRecords(
                            dv.Id,'M',
                            major,
                            minor,
                            500,
                            1,
                            null
                            );
        Test.stopTest();
        System.assertNotEquals(null, strImage);
        System.assertNotEquals(null, strMaster);
    }
   //マスター検索
   @isTest static void priceTableTest_3() {
        String qRtName='施設';
        String major='進相コンデンサ/リアクトル';
        String minor='機器事業部 高圧コンデンサ/リアクトル';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        Test.startTest();
        //図検索
        String strImage = DetailsAddController.getPricingTableRecordsByImage(
            dv.Id, 
            new List<String>{mdtObj.Id},
            500,
            1,
            null);
        //マスター検索
        String strMaster = DetailsAddController.getPricingTableRecords(
                            dv.Id,'S',
                            major,
                            minor,
                            500,
                            1,
                            null
                            );
        Test.stopTest();
        System.assertNotEquals(null, strImage);
        System.assertNotEquals(null, strMaster);
    }
    //マスター検索
   @isTest static void priceTableTest_4() {
        String qRtName='施設';
        String major='発電機';
        String minor='エンジン(DG)';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        Test.startTest();
        //マスター検索
        String strMaster = DetailsAddController.getPricingTableRecords(
                            dv.Id,'S',
                            major,
                            minor,
                            500,
                            1,
                            null
                            );
        Test.stopTest();
        System.assertNotEquals(null, strMaster);
    }
    //マスター検索
    @isTest static void priceTableTest_5() {
        String qRtName='施設';
        String major='コントロールセンタ(C/C)';
        String minor='200V';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        Test.startTest();
        //マスター検索
        String strMaster = DetailsAddController.getPricingTableRecords(
                            dv.Id,'S',
                            major,
                            minor,
                            500,
                            1,
                            null
                            );
        Test.stopTest();
        System.assertNotEquals(null, strMaster);
    }
    //マスター検索
    @isTest static void priceTableTest_6() {
        String qRtName='官需';
        String major='CCTVカメラ設備[国交省本省宛て提出機器単体費等]';
        String minor='HDIPカメラ装置';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);

        Test.startTest();
        //マスター検索
        String strMaster = DetailsAddController.getPricingTableRecords(
                            dv.Id,'S',
                            major,
                            minor,
                            500,
                            1,
                            null
                            );
        Test.stopTest();
        System.assertNotEquals(null, strMaster);
    }
    //見積項目検索
    @isTest static void detailTest() {
        String qRtName='施設';
        String major='変圧器';
        String minor='機器事業部 変圧器';
        String powerFrequency='50Hz';

        createDate(qRtName,major, minor, powerFrequency);
        //参照見積項目の明細
        Detail__c dv1Detail = new Detail__c();
        dv1Detail.Device__c = dv1.Id;//機器ID
        dv1Detail.Name1__c = 'Name1';
        dv1Detail.Name2__c = 'EP=WC×2';
        dv1Detail.Name3__c = 'Name3';
        dv1Detail.Name4__c = 'Name4';
        dv1Detail.Name5__c = 'Name5';
        dv1Detail.Name6__c = 'Name6';
        dv1Detail.Name7__c = 'Name7';
        dv1Detail.Name8__c = 'Name8';
        dv1Detail.Name9__c = 'Name9';
        dv1Detail.PricingTableUniqueKey__c = tables.get(0).UniqueKey__c;//機器ID
        insert dv1Detail;
        Test.startTest();
        //見積検索
        String strDetail = DetailsAddController.getDetailTableRecords(dv1.Id,
                                                                        500,
                                                                        1,
                                                                        null);

        DetailsAddController.PricingTableInputOnly intensify = new DetailsAddController.PricingTableInputOnly();

        intensify.Id = dv1Detail.Id;
        intensify.Quantity = 1;
        intensify.WCCoefficient = 1;
        intensify.CreditWC = 1;
        intensify.UnitPriceCoefficient = 1;
        intensify.ProvisionUnitPrice = 1;
        intensify.UnitWeight = 1;
        intensify.WC = 1;
        intensify.Price = 1;
        intensify.ProvisionPrice = 1;
        intensify.Weight = 1;
        List<DetailsAddController.PricingTableInputOnly> intensifyList = new List<DetailsAddController.PricingTableInputOnly>{intensify};
        //明細を基に登録された場合
        String strSubmitDetails = DetailsAddController.submitDetails(JSON.serialize(intensifyList), dv.Id);
        Test.stopTest();
        DetailsAddController.PricingTableWrapper scnInfo = (DetailsAddController.PricingTableWrapper)JSON.deserialize(strDetail, DetailsAddController.PricingTableWrapper.class);
        System.assertEquals(scnInfo.records.size(), 1);
        System.assertEquals(strSubmitDetails, dv.Quote__c);
    }
}