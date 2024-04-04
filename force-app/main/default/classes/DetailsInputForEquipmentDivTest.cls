/**
 * 明細入力B(高圧TR２、高低圧TR２　H種乾式変圧器（機器事業部）)画面のコントローラーのテスト
 */
@isTest
public with sharing class DetailsInputForEquipmentDivTest {
    private static final String RECORDTYPE_NAME_CHSSIS = '筐体';
    private static final String RECORDTYPE_NAME_DETAILS = '明細';
    private static final String Frequency_50Hz = '50Hz';
    private static final String Frequency_60Hz = '60Hz';
    private static final String SCEEN_TYPE_1 = '高圧TR2（機器事業部）';
    private static final String SCEEN_TYPE_2 = '高低圧TR2（機器事業部）';
    private static final String SCEEN_TYPE_3 = 'H種乾式変圧器（機器事業部）';
    private static final List<String> BU_LIST = new List<String>{'S','K','M'};

    private static Quote__c quote;//見積
    private static Device__c dv;//見積項目
    private static List<PricingTable__c> tables;

    //価格表データ作成
    private static void createDate(String qRtName,
                                    String powerFrequency, 
                                    String screenType,
                                    String transformerType
                                    ){
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = :qRtName];

        quote = new Quote__c(
            QuoteNumber__c = '1',
            PowerFrequency__c = powerFrequency,
            RecordTypeId = recType[0].Id
        );
        insert quote;

        dv = new Device__c(
            Name = qRtName+ '変圧器',
            RecordTypeOfQuote__c = qRtName,
            MajorClassification__c = '変圧器',
            MinorClassification__c = '機器事業部 変圧器',
            Quote__c =quote.Id
        );
        insert dv;

        tables = new List<PricingTable__c>();
        Map<String,String> seriesList;
        if (screenType == '高圧TR2（機器事業部）') {
            seriesList = new  Map<String,String>{
                'R' => 'トップランナー(標準)@R',
                'EX-α' => 'スーパー高効率(アモルファス)@EX-α',
                'EX-β' => 'スーパー高効率@EX-β'};
        }else if (screenType == '高低圧TR2（機器事業部）') {
            seriesList = new  Map<String,String>{
                '低圧' => 'トップランナー対象外 @ 低圧',
                'タイトランス' => 'トップランナー対象外 @ タイトランス',
                'スコット' => 'トップランナー対象外 @ スコット'};
        }else if (screenType == 'H種乾式変圧器（機器事業部）') {
            seriesList = new  Map<String,String>{
                '低圧' => 'H種乾式 低圧'};
        }

        String name9 = '';
        if (transformerType=='モールド') {
            // ・変圧器機種「モールド」の場合
            // 　かつ 名称9「モ低圧混板なし」or「モ スコット混板なし」
            name9 ='モ低圧混板なし';

        }else if (transformerType=='モールド　混触防止板あり') {
            // 　・変圧器機種「モールド　混触防止板あり」の場合
            // 　　　かつ 名称9「モ低圧混板あり」or「モ スコット混板あり」
            name9 ='モ低圧混板あり';
        }else if (transformerType=='モールド　異電圧') {
            // 　・変圧器機種「モールド　異電圧」の場合
            // 　　　かつ 名称9「モ低圧異電圧・異結線混板なし」
            name9 ='モ低圧異電圧・異結線混板なし';
        }else if (transformerType=='モールド　異電圧　混触防止板あり') {
            // 　・変圧器機種「モールド　異電圧　混触防止板あり」の場合
            // 　　　かつ 名称9「モ低圧異電圧・異結線混板あり」
            name9 ='モ低圧異電圧・異結線混板あり';
        }

        Integer index = 1;
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'PricingTable__c' and Name=:RECORDTYPE_NAME_CHSSIS LIMIT 1];
        RecordType detailRt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'PricingTable__c' and Name=:RECORDTYPE_NAME_DETAILS LIMIT 1];
        for (String bu: BU_LIST){
            for (String series: seriesList.keyset()){
                String ser=seriesList.get(series).replace('@', transformerType); 
                // 価格表　（筐体）
                PricingTable__c table = new PricingTable__c(
                    RecordTypeId = rt.Id 
                    , BU__c = bu
                    , MajorClassificationCode__c = '01'
                    , MajorClassificationName__c = '変圧器'
                    , MinorClassificationCode__c = '11'
                    , MinorClassificationName__c = '機器事業部 変圧器'
                    , CategoryCode__c = (powerFrequency==Frequency_60Hz?'02':'01')
                    , Frequency__c = powerFrequency
                    , Name1__c = ser
                    , Name2__c = '屋外'
                    , Name3__c = '単相'
                    , Name4__c = '6,600V'
                    , Name5__c = '210/105V'
                    , Name6__c = index+'kVA'
                    , Name7__c = (screenType==SCEEN_TYPE_3?'ケースなし':'テスト名称７')
                    , Name8__c = 'ケースなし'
                    , Name9__c = name9
                    , DisplayName__c = '機器事業部 高圧TR'
                    , Name10__c = (screenType==SCEEN_TYPE_1?'一次電圧6600V二次電圧210V':'高・低圧TR油入')
                    , MasterCode__c = 'MasterCode'
                    , RECNo__c = index
                );
                index = index + 1;
                tables.add(table);

                PricingTable__c tableDt = new PricingTable__c(
                    RecordTypeId = detailRt.Id 
                    , BU__c = bu
                    , MajorClassificationCode__c = '01'
                    , MajorClassificationName__c = '変圧器'
                    , MinorClassificationCode__c = '11'
                    , MinorClassificationName__c = '機器事業部 変圧器'
                    , CategoryCode__c = (powerFrequency==Frequency_60Hz?'02':'01')
                    , Frequency__c = powerFrequency
                    , Name1__c = transformerType +' ' + series
                    , Name2__c = '耐塩ブッシング'
                    , Name3__c = '単相'
                    , Name4__c = 'UT4'
                    , Name5__c = 'UT5'
                    , Name6__c = 'UT6'
                    , Name7__c = 'UT7'
                    , Name8__c = 'UT8'
                    , Name9__c = 'UT9'
                    , Name10__c = 'UT10'
                    , DisplayName__c = '機器事業部 高圧TR'
                    , MasterCode__c = 'MasterCode'
                    , RECNo__c = index
                );
                tables.add(tableDt);

            }

        }
        if (tables.size() > 0) insert tables;


    }

    /**
     * リスト内容取得をテストする
     *  Rシリーズ
     *  EXｰαシリーズ
     *  EXｰβシリーズ
     * 
     * */
    @isTest static void getPicklistOptionsTest() {
        Test.startTest();
        //高圧TR2（機器事業部）
        //油入
        Map<String, List<Map<String, String>>> resOil = 
                            DetailsInputForEquipmentDivController.getPicklistOptions(
                                SCEEN_TYPE_1,
                                '油入',
                                10);
        //高圧TR2（機器事業部）
        //モールド
        Map<String, List<Map<String, String>>> resMo = 
                            DetailsInputForEquipmentDivController.getPicklistOptions(
                                SCEEN_TYPE_1,
                                'モールド'
                                ,10
                                );
        Test.stopTest();
        System.assertEquals(resOil.get('rSeriesOptions').size()>0, true);//Rシリーズ
        System.assertEquals(resOil.get('exaSeriesOptions').size()>0, true);//EXｰαシリーズ
        System.assertEquals(resOil.get('exbSeriesOptions').size()>0, true);//EXｰβシリーズ
        System.assertEquals(resMo.get('rSeriesOptions').size()>0, true);//Rシリーズ
        System.assertEquals(resMo.get('exaSeriesOptions').size()>0, true);//EXｰαシリーズ
        System.assertEquals(resMo.get('exbSeriesOptions'), null);//EXｰβシリーズ
    }
   /**
     *内訳入力B_高圧TR2 画面情報を取得 テスト
     * 油
     */
    @isTest static void getScreenInfoForHighVoltageOilTest() {
        String qRtName='施設';
        String powerFrequency='50Hz';
        String screenType='高圧TR2（機器事業部）';
        String transformerType='油入';
        Map<String, String> optMap= new Map<String, String>{
            'rSeries' => '一次電圧6600V二次電圧210V',
            'exaSeries' => '一次電圧6600V二次電圧210V',
            'exbSeries' => '一次電圧6600V二次電圧210V'
        };
        createDate(qRtName, powerFrequency, screenType,'油');

        Test.startTest();
        String rtn = DetailsInputForEquipmentDivController.getScreenInfo(
                                            dv.Id,
                                            screenType,
                                            transformerType,
                                            Json.serialize(optMap));
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
    }
   /**
     *内訳入力B_高圧TR2 画面情報を取得 テスト
     * モールド
     */
    @isTest static void getScreenInfoForHighVoltageMoTest() {
        String qRtName='施設';
        String powerFrequency='50Hz';
        String screenType='高圧TR2（機器事業部）';
        String transformerType='モールド';
        Map<String, String> optMap= new Map<String, String>{
            'rSeries' => '一次電圧6600V二次電圧210V',
            'exaSeries' => '一次電圧6600V二次電圧210V',
            'exbSeries' => '一次電圧6600V二次電圧210V'
        };
        createDate(qRtName, powerFrequency, screenType,'モールド');

        Test.startTest();
        //既存登録なしで検索
        String rtnOri = DetailsInputForEquipmentDivController.getScreenInfo(
                                dv.Id,
                                null,
                                null,
                                null);
        //Optデータを準備
        DetailsInputForEquipmentDivController.QuantityObject opt = new DetailsInputForEquipmentDivController.QuantityObject();
        opt.Id=tables.get(1).Id;
        opt.Price=11111;
        opt.Quantity=1;
        List<DetailsInputForEquipmentDivController.QuantityObject> optRecords 
                    = new List<DetailsInputForEquipmentDivController.QuantityObject>{opt};
        //登録
        String strSubmitDetails = DetailsInputForEquipmentDivController.submitDetails(
                                            dv.Id,
                                            tables.get(0).Id,
                                            JSON.serialize(optRecords));
        String rtn = DetailsInputForEquipmentDivController.getScreenInfo(
                                            dv.Id,
                                            null,
                                            null,
                                            null);
        System.debug(rtn);
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
        System.assertEquals(strSubmitDetails, dv.Quote__c);
    }
    /**
     *内訳入力B_高低圧TR2（機器事業部） 画面情報を取得 テスト
     * 油入
     */
    @isTest static void getScreenInfoForLowVoltageTest() {
        String qRtName='施設';
        String powerFrequency='50Hz';
        String screenType='高低圧TR2（機器事業部）';
        String transformerType='モールド　異電圧　混触防止板あり';

        createDate(qRtName, powerFrequency, screenType,transformerType);

        Test.startTest();

        //Optデータを準備
        DetailsInputForEquipmentDivController.QuantityObject opt = new DetailsInputForEquipmentDivController.QuantityObject();
        opt.Id=tables.get(1).Id;
        opt.Price=11111;
        opt.Quantity=1;
        List<DetailsInputForEquipmentDivController.QuantityObject> optRecords 
                    = new List<DetailsInputForEquipmentDivController.QuantityObject>{opt};
        //登録
        String strSubmitDetails = DetailsInputForEquipmentDivController.submitDetails(
                                            dv.Id,
                                            tables.get(0).Id,
                                            JSON.serialize(optRecords));

        String rtn = DetailsInputForEquipmentDivController.getScreenInfo(
                                            dv.Id,
                                            null,
                                            null,
                                            null);
        System.debug(rtn);
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
        System.assertEquals(strSubmitDetails, dv.Quote__c);
    }

    /**
     *内訳入力B_高低圧TR2（機器事業部） 画面情報を取得 テスト
     * モールド
     */
    @isTest static void getScreenInfoForLowVoltageTest1() {
        String qRtName='施設';
        String powerFrequency='50Hz';
        String screenType='高低圧TR2（機器事業部）';
        String transformerType='モールド';

        createDate(qRtName, powerFrequency, screenType,transformerType);

        Test.startTest();
        String rtn = DetailsInputForEquipmentDivController.getScreenInfo(
                                            dv.Id,
                                            screenType,
                                            transformerType,
                                            null);
        System.debug(rtn);
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
    }

    /**
     *内訳入力B_高低圧TR2（機器事業部） 画面情報を取得 テスト
     * モールド　混触防止板あり
     */
    @isTest static void getScreenInfoForLowVoltageTest2() {
        String qRtName='施設';
        String powerFrequency='50Hz';
        String screenType='高低圧TR2（機器事業部）';
        String transformerType='モールド　混触防止板あり';

        createDate(qRtName, powerFrequency, screenType,transformerType);

        Test.startTest();
        String rtn = DetailsInputForEquipmentDivController.getScreenInfo(
                                            dv.Id,
                                            screenType,
                                            transformerType,
                                            null);
        System.debug(rtn);
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
    }

    /**
     *内訳入力B_高低圧TR2（機器事業部） 画面情報を取得 テスト
     * モールド　異電圧
     */
    @isTest static void getScreenInfoForLowVoltageTest3() {
        String qRtName='施設';
        String powerFrequency='50Hz';
        String screenType='高低圧TR2（機器事業部）';
        String transformerType='モールド　異電圧';

        createDate(qRtName, powerFrequency, screenType,transformerType);

        Test.startTest();
        String rtn = DetailsInputForEquipmentDivController.getScreenInfo(
                                            dv.Id,
                                            screenType,
                                            transformerType,
                                            null);
        System.debug(rtn);
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
    }

    /**
     *内訳入力B_高低圧TR2（機器事業部） 画面情報を取得 テスト
     * モールド　異電圧　混触防止板あり
     */
    @isTest static void getScreenInfoForLowVoltageTest4() {
        String qRtName='施設';
        String powerFrequency='50Hz';
        String screenType='高低圧TR2（機器事業部）';
        String transformerType='モールド　異電圧　混触防止板あり';

        createDate(qRtName, powerFrequency, screenType,transformerType);

        Test.startTest();
        String rtn = DetailsInputForEquipmentDivController.getScreenInfo(
                                            dv.Id,
                                            screenType,
                                            transformerType,
                                            null);
        System.debug(rtn);
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
    }


    /**
     *内訳入力B_H種乾式変圧器（機器事業部） 画面情報を取得 テスト
     * モールド
     */
    @isTest static void getScreenInfoForForHDryTest() {
        String qRtName='施設';
        String powerFrequency='50Hz';
        String screenType='H種乾式変圧器（機器事業部）';
        String transformerType='ケースなし';

        createDate(qRtName, powerFrequency, screenType,'ケースなし');

        Test.startTest();
        String rtn = DetailsInputForEquipmentDivController.getScreenInfo(
                                            dv.Id,
                                            screenType,
                                            transformerType,
                                            null);
        System.debug(rtn);
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
    }

    /**
     *内訳入力B_全画面 登録のテスト
     * 明細登録ありの検索テスト
     */
    @isTest static void submitDetailsTest() {
        String qRtName='施設';
        String powerFrequency='50Hz';
        String screenType='H種乾式変圧器（機器事業部）';
        String transformerType='ケースなし';

        createDate(qRtName, powerFrequency, screenType,'ケースなし');

        Test.startTest();

        //Optデータを準備
        DetailsInputForEquipmentDivController.QuantityObject opt = new DetailsInputForEquipmentDivController.QuantityObject();
        opt.Id=tables.get(1).Id;
        opt.Price=11111;
        opt.Quantity=1;
        List<DetailsInputForEquipmentDivController.QuantityObject> optRecords 
                    = new List<DetailsInputForEquipmentDivController.QuantityObject>{opt};
        //登録
        String strSubmitDetails = DetailsInputForEquipmentDivController.submitDetails(
                                            dv.Id,
                                            tables.get(0).Id,
                                            JSON.serialize(optRecords));

        //登録データあり場合　検索を行う
        String rtn = DetailsInputForEquipmentDivController.getScreenInfo(
                                            dv.Id,
                                            null,
                                            null,
                                            null);
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
        System.assertEquals(strSubmitDetails, dv.Quote__c);
    }   
}