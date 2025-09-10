/**
 * 明細入力B(低圧配電盤)画面のコントローラーのテスト
 */
@isTest
public with sharing class DetailsInputForLowVoltageTest {
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
            // QuoteSpecificationNumber__c = '001',
            Name = qRtName+'DeviceTest',
            RecordTypeOfQuote__c = qRtName,
            MajorClassification__c = '低圧・現場・リレー・ACB盤',
            MinorClassification__c = '低圧盤',
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
            //大分類名「共通機器」かつ、名称1「配線用遮断器」
            // 大分類名「共通機器」かつ、名称1「計装・機器取付費」
            // 大分類名「共通機器」かつ、名称1「計器用変流器」
            // 大分類名「共通機器」かつ、名称1「双投式電磁接触器」
            // 大分類名「共通機器」かつ、名称1「照明・建築付帯用トランス」
            'name1'=> new List<String>{'配線用遮断器','計装・機器取付費','計器用変流器','双投式電磁接触器','照明・建築付帯用トランス'},
            // 大分類名「共通機器」かつ、名称9「低圧CT・PT、保護継電器類」
            'name9'=> new List<String>{'低圧CT・PT、保護継電器類'},
            // 大分類名「共通機器」かつ、名称10「起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】」
            // 大分類名「共通機器」かつ、名称10「電磁開閉器（MC）」
            'name10'=> new List<String>{'起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】','電磁開閉器（MC）'},
            // 大分類名「共通機器」かつ、低圧盤B画面指示計類用RECNOがnull以外
            // 大分類名「共通機器」かつ、低圧盤B画面取付器具類用RECNOがnull以外
            'RECNO'=>new List<String>{'1'}
        };
        // 大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤
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
                        , RECNOforLowVoltageB_Order__c = (mapKey=='RECNO'?Decimal.valueof(key):null)
                        , RECNOforLowVoltageB_Attachment__c = (mapKey=='RECNO'?Decimal.valueof(key):null)
                        , MasterCode__c = 'MasterCode'
                        , RECNo__c = index
                    );
                    index = index + 1;
                    tables.add(table);
                }
            }
            // 施設     「筐体」かつ、大分類名「変圧器」かつ、小分類名「高圧変圧器」かつ、種類名＝見積.電源周波数かつ、名称1「油」かつ、（名称4「210V」or名称4「420V」）
            // ”水環境”or"官需" 「明細」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤」かつ、種類名＝見積.電源周波数かつ、名称1「低圧変圧器」かつ、名称5「油入」
            
            // ”施設” レコードタイプ「筐体」かつ、大分類名「変圧器」かつ、小分類名「高圧変圧器」かつ、 種類名＝見積.電源周波数かつ、名称1「モールド」かつ、（名称4「210V」or名称4「420V」）
            // ”水環境”or"官需" レコードタイプ「明細」かつ、大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤」かつ、 種類名＝見積.電源周波数かつ、名称1「低圧変圧器」かつ、名称5「モールド」
            List<String> divType = new List<String>{'油','モールド'};
            for (String div : divType) {
                // 価格表
                PricingTable__c table = new PricingTable__c(
                    RecordTypeId = pricingRecordTypeByName.get((qRtName!='施設'?'明細':'筐体')) 
                    , BU__c = bu
                    , MajorClassificationName__c =(qRtName!='施設'?'低圧・現場・リレー・ACB盤':'変圧器')
                    , MinorClassificationName__c = (qRtName!='施設'?'低圧盤':'高圧変圧器')
                    , Frequency__c = Frequency_60Hz
                    , CategoryName__c = Frequency_60Hz
                    , Name1__c =  (qRtName!='施設'?'低圧変圧器':div)
                    , Name2__c = '自立SS'
                    , Name3__c = '3333333'
                    , Name4__c = (qRtName!='施設'?'444444':'210V')
                    , Name5__c = (qRtName=='施設'?'555555':(div=='油'?'油入':div))
                    , Name6__c = '観音開き'
                    , Name7__c = '777777'
                    , Name8__c = '888888'
                    , Name9__c = '99999999'
                    , Name10__c = '11111111'
                    , MasterCode__c = 'MasterCode'
                    , RECNo__c = index
                    );
                    index = index + 1;
                    tables.add(table);
            }
            // 大分類名「低圧・現場・リレー・ACB盤」かつ、小分類名「低圧盤」種類名＝見積.電源周波数かつ、（名称1「低圧コンデンサ」or名称1「低圧リアクトル」）
              // 価格表
            PricingTable__c table = new PricingTable__c(
                RecordTypeId = pricingRecordTypeByName.get('明細')
                , BU__c = bu
                , MajorClassificationName__c ='低圧・現場・リレー・ACB盤'
                , MinorClassificationName__c ='低圧盤'
                , Frequency__c = Frequency_60Hz
                , CategoryName__c = Frequency_60Hz
                , Name1__c =  '低圧コンデンサ'
                , Name2__c = '自立SS'
                , Name3__c = '3333333'
                , Name4__c = '444444'
                , Name5__c = '555555'
                , Name6__c = '観音開き'
                , Name7__c = '777777'
                , Name8__c = '888888'
                , Name9__c = '99999999'
                , Name10__c = '11111111'
                , MasterCode__c = 'MasterCode'
                , RECNo__c = index
                );
            index = index + 1;
            tables.add(table);
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
        String rtn = DetailsInputForLowVoltageController.getInitScreenInfo(true,
                                            dv.Id,
                                            '屋内',
                                            '自立SS',
                                            '観音開き');
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        List<Object> tbls=  (List<Object>)jsonDes.get('classicTables');
        Map<String, Object> mccbTable = (Map<String, Object>)jsonDes.get('mccbTable');//配線用遮断器価格 （MCCB・ELB）
        Map<String, Object> lowVoltageCTPTTable = (Map<String, Object>)jsonDes.get('lowVoltageCTPTTable');//低圧CT・PT、保護継電器類
        Map<String, Object> indicatorTypeTable= (Map<String, Object>)jsonDes.get('indicatorTypeTable'); //指示計類
        Map<String, Object> equipInstallFeeTable= (Map<String, Object>)jsonDes.get('equipInstallFeeTable'); //計装・機器取付費
        Map<String, Object> installEquipTypeTable= (Map<String, Object>)jsonDes.get('installEquipTypeTable'); //取付器具類
        Map<String, Object> transformerCTTable= (Map<String, Object>)jsonDes.get('transformerCTTable'); //計器用変流器 ＣＴ(低圧)
        Map<String, Object> twoElectroContactorTable= (Map<String, Object>)jsonDes.get('twoElectroContactorTable'); //双投式電磁接触器 
        Map<String, Object> startupCircuitTable= (Map<String, Object>)jsonDes.get('startupCircuitTable'); //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
        Map<String, Object> electroSwitchTable= (Map<String, Object>)jsonDes.get('electroSwitchTable'); // 電磁開閉器（MC）
        Map<String, Object> lowVoltageCROilTable= (Map<String, Object>)jsonDes.get('lowVoltageCROilTable'); // 低圧コンデンサ・リアクトル　油入
        Map<String, Object> transformerOilTable= (Map<String, Object>)jsonDes.get('transformerOilTable'); // 変圧器　油入り自冷
        Map<String, Object> transformerMoldTable= (Map<String, Object>)jsonDes.get('transformerMoldTable'); // 変圧器　モールド
        Map<String, Object> transformerLightingTable= (Map<String, Object>)jsonDes.get('transformerLightingTable'); // 変圧器（照明・建築付帯用）

        System.assertEquals(jsonDes.size()>0, true);
        System.assertEquals(tbls.size()>0, true);
        System.assertEquals(mccbTable.size()>0, true);
        System.assertEquals(lowVoltageCTPTTable.size()>0, true);
        System.assertEquals(indicatorTypeTable.size()>0, true);
        System.assertEquals(equipInstallFeeTable.size()>0, true);
        System.assertEquals(installEquipTypeTable.size()>0, true);
        System.assertEquals(transformerCTTable.size()>0, true);
        System.assertEquals(twoElectroContactorTable.size()>0, true);
        System.assertEquals(startupCircuitTable, null);
        System.assertEquals(electroSwitchTable.size()>0, true);
        System.assertEquals(lowVoltageCROilTable, null);
        System.assertEquals(transformerOilTable.size()>0, true);
        System.assertEquals(transformerMoldTable.size()>0, true);
        System.assertEquals(transformerLightingTable.size()>0, true);
    }

   /**
     *内訳入力B_低圧配電盤 画面情報を取得 データなしテスト
     * 
     */
    @isTest static void getInitScreenInfoNodataTest() {
        String qRtName='施設';
        createDate(qRtName);

        Test.startTest();
        String rtn = DetailsInputForLowVoltageController.getInitScreenInfo(true,
                                            dv.Id,
                                            '屋外',
                                            '自立SS',
                                            '1枚扉');
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
        
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        List<Object> tbls=  (List<Object>)jsonDes.get('classicTables');
        System.assertEquals(tbls, null);
    }

    /**
     *内訳入力B_低圧配電盤 画面情報を取得 官需テスト
     * 
     */
    @isTest static void getInitScreenInfoMTest() {
        String qRtName='官需';
        createDate(qRtName);

        Test.startTest();
        String rtn = DetailsInputForLowVoltageController.getInitScreenInfo(false,
                                            dv.Id,
                                            '屋内',
                                            '自立SS',
                                            '観音開き');
        Test.stopTest();
        System.assertNotEquals(rtn, null);//
        
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        List<Object> tbls=  (List<Object>)jsonDes.get('classicTables');
        Map<String, Object> mccbTable = (Map<String, Object>)jsonDes.get('mccbTable');//配線用遮断器価格 （MCCB・ELB）
        Map<String, Object> lowVoltageCTPTTable = (Map<String, Object>)jsonDes.get('lowVoltageCTPTTable');//低圧CT・PT、保護継電器類
        Map<String, Object> indicatorTypeTable= (Map<String, Object>)jsonDes.get('indicatorTypeTable'); //指示計類
        Map<String, Object> equipInstallFeeTable= (Map<String, Object>)jsonDes.get('equipInstallFeeTable'); //計装・機器取付費
        Map<String, Object> installEquipTypeTable= (Map<String, Object>)jsonDes.get('installEquipTypeTable'); //取付器具類
        Map<String, Object> transformerCTTable= (Map<String, Object>)jsonDes.get('transformerCTTable'); //計器用変流器 ＣＴ(低圧)
        Map<String, Object> twoElectroContactorTable= (Map<String, Object>)jsonDes.get('twoElectroContactorTable'); //双投式電磁接触器 
        Map<String, Object> startupCircuitTable= (Map<String, Object>)jsonDes.get('startupCircuitTable'); //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
        Map<String, Object> electroSwitchTable= (Map<String, Object>)jsonDes.get('electroSwitchTable'); // 電磁開閉器（MC）
        Map<String, Object> lowVoltageCROilTable= (Map<String, Object>)jsonDes.get('lowVoltageCROilTable'); // 低圧コンデンサ・リアクトル　油入
        Map<String, Object> transformerOilTable= (Map<String, Object>)jsonDes.get('transformerOilTable'); // 変圧器　油入り自冷
        Map<String, Object> transformerMoldTable= (Map<String, Object>)jsonDes.get('transformerMoldTable'); // 変圧器　モールド
        Map<String, Object> transformerLightingTable= (Map<String, Object>)jsonDes.get('transformerLightingTable'); // 変圧器（照明・建築付帯用）

        System.assertEquals(jsonDes.size()>0, true);
        System.assertEquals(tbls.size()>0, true);
        System.assertEquals(mccbTable.size()>0, true);
        System.assertEquals(lowVoltageCTPTTable.size()>0, true);
        System.assertEquals(indicatorTypeTable.size()>0, true);
        System.assertEquals(equipInstallFeeTable.size()>0, true);
        System.assertEquals(installEquipTypeTable.size()>0, true);
        System.assertEquals(transformerCTTable, null);
        System.assertEquals(twoElectroContactorTable.size()>0, true);
        System.assertEquals(startupCircuitTable.size()>0, true);
        System.assertEquals(electroSwitchTable.size()>0, true);
        System.assertEquals(lowVoltageCROilTable.size()>0, true);
        System.assertEquals(transformerOilTable, null);//表示しない対応
        System.assertEquals(transformerMoldTable.size()>0, true);
        System.assertEquals(transformerLightingTable.size()>0, true);
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
        List<DetailsInputForLowVoltageController.QuantityObject> optRecords 
        = new List<DetailsInputForLowVoltageController.QuantityObject>();

        for(PricingTable__c tmp:tables){
            if (tmp.BU__c=='S') {
                DetailsInputForLowVoltageController.QuantityObject opt = new DetailsInputForLowVoltageController.QuantityObject();
                opt.Id=tmp.Id;
                opt.Price=11111;
                opt.Quantity=1;
                optRecords.add(opt);
            }
        }
        //登録
        String strSubmitDetails = DetailsInputForLowVoltageController.submitDetailsForLowVoltage(
                                            dv.Id,
                                            tables.get(0).Id,
                                            JSON.serialize(optRecords));

        //登録データあり場合　検索を行う
        String rtn = DetailsInputForLowVoltageController.getInitScreenInfo(true,
                                            dv.Id,
                                            'test',
                                            'test',
                                            'test');
        Test.stopTest();
        System.assertEquals(strSubmitDetails, dv.Quote__c);
        System.assertNotEquals(rtn, null);//
        
        Map<String, Object> jsonDes = (Map<String, Object>)JSON.deserializeUntyped(rtn);
        System.assertEquals(jsonDes.get('installationLocation'), '屋内');
        System.assertEquals(jsonDes.get('housingSpecifications'), '自立SS');
        System.assertEquals(jsonDes.get('doorSpecifications'), '観音開き');
        
    } 

}