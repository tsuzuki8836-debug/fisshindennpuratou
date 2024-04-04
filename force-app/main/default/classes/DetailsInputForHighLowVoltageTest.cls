/**
 * 明細入力B(高圧TR1、高低圧TR1)画面のコントローラーのテスト
 */
@isTest
public with sharing class DetailsInputForHighLowVoltageTest {
    private static final String RECORDTYPE_NAME_CHSSIS = '筐体';
    private static final String Frequency_50Hz = '50Hz';
    private static final String Frequency_60Hz = '60Hz';
    private static final String SCEEN_TYPE_1 = '高圧TR1';
    private static final String SCEEN_TYPE_2 = '高低圧TR1';
    private static final List<String> BU_LIST = new List<String>{'S','K','M'};

    private static Quote__c quote;//見積
    private static Device__c dv;//見積項目
    private static List<PricingTable__c> tables;

    //価格表データ作成
    private static void createDate(String qRtName,String major, String minor, String powerFrequency, String screenType){
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = :qRtName];

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
            Quote__c =quote.Id
        );
        insert dv;

        // レコードタイプ（価格表）取得
        Map<String, Id> pricingRecordTypeByName = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SobjectType = 'PricingTable__c' and Name=:RECORDTYPE_NAME_CHSSIS]) {
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
                    , Name6__c = index+'kVA'
                    , Name7__c = 'Name7'
                    , Name8__c = 'Name8'
                    , Name9__c = 'Name9'
                    , DisplayName__c = '高圧TR'
                    , Name10__c = (screenType==SCEEN_TYPE_1?'高圧TR油入(一次電圧6600V）':'高・低圧TR油入')
                    , MasterCode__c = 'MasterCode'
                    , RECNo__c = index
                );
                index = index + 1;
                tables.add(table);
            }
        }
        if (tables.size() > 0) insert tables;
    }

    //高圧TR1画面　検索
    //高圧TR1画面　登録
    //既存データなし
    @isTest static void test_1() {
        String qRtName='施設';
        String major='変圧器';
        String minor='高圧変圧器';
        String powerFrequency='50Hz';
        String screenType='高圧TR1';

        createDate(qRtName,major, minor, powerFrequency,screenType);

        Test.startTest();
         //検索
        String strResult = DetailsInputForHighLowVoltageController.getInitScreenInfo(dv.Id,screenType,'高圧TR油入(一次電圧6600V）');

       //登録された場合
        String strSubmitDetails = DetailsInputForHighLowVoltageController.submitDetails(dv.Id,tables.get(0).Id);

        Test.stopTest();
        System.assertNotEquals(strResult, null);
        System.assertEquals(strSubmitDetails, dv.Quote__c);
    }
    //高低圧TR1画面　検索
    //高低圧TR1画面　登録
    //既存データあり
    @isTest static void test_2() {
        String qRtName='施設';
        String major='変圧器';
        String minor='高圧変圧器';
        String powerFrequency='50Hz';
        String screenType='高低圧TR1';

        createDate(qRtName,major, minor, powerFrequency,screenType);

        Test.startTest();
        //登録された場合
        String strSubmitDetails = DetailsInputForHighLowVoltageController.submitDetails(dv.Id,tables.get(0).Id);

         //検索
        String strResult = DetailsInputForHighLowVoltageController.getInitScreenInfo(dv.Id,screenType,'高・低圧TR油入');
        Test.stopTest();
        System.assertNotEquals(strResult, null);
        System.assertEquals(strSubmitDetails, dv.Quote__c);
    }

}