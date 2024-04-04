@isTest
private class FactoryTriggerTest {
      
    @IsTest
    private static void SumTest() {

        List<RecordType> recType = [SELECT Id,name,SobjectType  FROM RecordType WHERE SobjectType = 'Account' and name = '事業所'];

        Account acc = new Account(
            Name = 'Test Account',
            Phone = '09011111111',
            RecordTypeId = recType[0].Id,
            OfficeName__c = 'acc01'
        );
        insert acc;

        Property__c prop = new Property__c(
            Name = 'Test Prop'
        );
        insert prop;

        //20210426 テスト実行時のガバナ制限エラー対応
        List<Opportunity> oppList = new List<Opportunity>();
                
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp1',
            StageName = '基本計画',
            CloseDate = Date.today(),
            SBU__c = 'PVスマエネ',
            Property__c = prop.Id,
            ScheduledCollectionDate__c = Date.today(),
            ConstructionDistinction__c = '新設',
            OrderExpectation__c = '1', 
            Website__c = 01, 
            Handling__c = '直扱', 
            DemanDepartment__c = '金融', 
            DemandOf__c = '官需', 
            InformationFrom__c = '施主',
            AccountId = acc.Id
        );
        oppList.add(opp1);

        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp2',
            StageName = '基本計画',
            CloseDate = Date.today(),
            SBU__c = '受変電',
            Property__c = prop.Id,
            ScheduledCollectionDate__c = Date.today(),
            ConstructionDistinction__c = '新設',
            OrderExpectation__c = '2', 
            Website__c = 02, 
            Handling__c = '直扱', 
            DemanDepartment__c = '通信', 
            DemandOf__c = '官需', 
            InformationFrom__c = '施主',
            AccountId = acc.Id
        );
        oppList.add(opp2);
        
        insert oppList;

        List<Factory__c> facList = new List<Factory__c>();

        //場所別
        // 2021.07.16 コスト構造対応　受注時、受注後最新、売上実績セクションの項目は未使用となった為、ロジックから削除
        Factory__c Fac01 = new Factory__c(
            Opp1__c = opp1.Id,
            CommonRatio1__c= '21% ： 製作所',
            BU__c='施設',
            CarryingDay__c=Date.today()+10,
            SR_CP__c                 = 200, 
            SRWC__c                  = 100         
        );
        facList.add(Fac01);

        Factory__c Fac02 = new Factory__c(
            Opp1__c = opp1.Id,
            CommonRatio1__c= '22% ： プラ統',
            BU__c='施設',
            CarryingDay__c=Date.today()+10,
            SR_CP__c                 = 400, 
            SRWC__c                  = 300          
        );
        facList.add(Fac02);

        //20210426 テスト実行時のガバナ制限エラー対応
        // Factory__c Fac03 = new Factory__c(
        //     Opp1__c = opp1.Id,
        //     CommonRatio1__c='他社品',
        //     CarryingDay__c=Date.today()+10,
        //     SR_CP__c                 = 600, 
        //     SRWC__c                  = 500,
        //     Order_SR_CP__c           = 610,
        //     Order_SRWC__c            = 510,
        //     Order_Forecast_SR_CP__c  = 620,
        //     Order_Forecast_SRWC__c   = 520,
        //     Latest_SR_CP__c          = 630,
        //     Latest_SRWC__c           = 530,
        //     Latest_Forecast_SR_CP__c = 640,
        //     Latest_Forecast_SRWC__c  = 540,
        //     Result_SR_CP__c          = 650,
        //     Result_SRWC__c           = 550,
        //     Result_Difference__c     = 660,   
        //     Result_AdditionalCost__c = 660            
        // );

        //20201104 削除フラグ対応
        Factory__c Fac04 = new Factory__c(
            Opp1__c = opp1.Id,
            CommonRatio1__c= '20% ： 他社品',
            BU__c='施設',
            CarryingDay__c=Date.today()+10,
            SR_CP__c                 = 600, 
            SRWC__c                  = 500,
            DeleteFlag__c = true            
        );
        facList.add(Fac04);

        //テスト実行
        Test.startTest();

        //insert
        insert facList;
        //20210426 テスト実行時のガバナ制限エラー対応
        //insert Fac02;
        //insert Fac03;
        //20201104 削除フラグ対応
        //insert Fac04;
        
        //検証
        // 2021.07.16 コスト構造対応　受注時、受注後最新、売上実績セクションの項目は未使用となった為、ロジックから削除
        List<AggregateResult> aggFacResult1 = [SELECT Opp1__c , 
                                               SUM(SR_CP__c) SumValue1,
                                               SUM(SRWC__c) SumValue2,
                                               SUM(TC__c) SumValue3
                                               FROM Factory__c WHERE Opp1__c = :opp1.Id AND DeleteFlag__c = false GROUP BY Opp1__c];
                                               
        List<Opportunity> oppResult1 = [SELECT Id,
                                        TotalCP__c,
                                        TotalWC__c,
                                        TC__c
                                        FROM Opportunity WHERE Id = :opp1.Id];

        System.debug('★★★test1_CP'+oppResult1[0].TotalCP__c);
        System.debug('★★★test1_WC'+oppResult1[0].TotalWC__c);
        System.debug('★★★test1_TC'+oppResult1[0].TC__c);
        
        System.AssertEquals(aggFacResult1[0].get('SumValue1'),  oppResult1[0].TotalCP__c);
        System.AssertEquals(aggFacResult1[0].get('SumValue2'),  oppResult1[0].TotalWC__c);
        System.AssertEquals(aggFacResult1[0].get('SumValue3'),  oppResult1[0].TC__c);

        //Fac01を削除
        delete Fac01;
        
        //検証
        // 2021.07.16 コスト構造対応　受注時、受注後最新、売上実績セクションの項目は未使用となった為、ロジックから削除
        List<AggregateResult> aggFacResult2 = [SELECT Opp1__c , 
                                               SUM(SR_CP__c) SumValue1,
                                               SUM(SRWC__c) SumValue2,
                                               SUM(TC__c) SumValue3
                                               FROM Factory__c WHERE Opp1__c = :opp1.Id AND DeleteFlag__c = false GROUP BY Opp1__c];
        
        List<Opportunity> oppResult2 = [SELECT Id,
                                        TotalCP__c,
                                        TotalWC__c,
                                        TC__c
                                        FROM Opportunity WHERE Id = :opp1.Id];

        System.debug('★★★test2_CP'+oppResult2[0].TotalCP__c);
        System.debug('★★★test2_WC'+oppResult2[0].TotalWC__c);
        System.debug('★★★test2_TC'+oppResult2[0].TC__c);
//      System.AssertEquals(aggFacResult2[0].get('SumValue1'),  oppResult2[0].TotalCP__c);     
//      System.AssertEquals(aggFacResult2[0].get('SumValue2'),  oppResult2[0].TotalWC__c);     
//      System.AssertEquals(aggFacResult2[0].get('SumValue3'),  oppResult2[0].TC__c);
                            
        //Fac02の親ID変更
//      Fac02.Opp1__c = opp2.Id;
//      update Fac02;

        //検証
        //20210426 場所別プロセスビルダー対応
        // List<AggregateResult> aggFacResult3 = [SELECT Opp1__c , 
        //                                        SUM(SR_CP__c) SumValue1,
        //                                        SUM(SRWC__c) SumValue2,
        //                                        SUM(TC__c) SumValue3,
        //                                        SUM(Order_SR_CP__c) SumValue4, 
        //                                        SUM(Order_SRWC__c) SumValue5,
        //                                        SUM(Order_TC__c) SumValue6,
        //                                        SUM(Order_Forecast_SR_CP__c) SumValue7,
        //                                        SUM(Order_Forecast_SRWC__c) SumValue8,
        //                                        SUM(Order_Forecast_TC__c) SumValue9,
        //                                        SUM(Latest_SR_CP__c) SumValue10,
        //                                        SUM(Latest_SRWC__c) SumValue11,
        //                                        SUM(Latest_TC__c) SumValue12,
        //                                        SUM(Latest_Forecast_SR_CP__c) SumValue13,
        //                                        SUM(Latest_Forecast_SRWC__c) SumValue14,
        //                                        SUM(Latest_Forecast_TC__c) SumValue15,
        //                                        SUM(Result_SR_CP__c) SumValue16,
        //                                        SUM(Result_SRWC__c) SumValue17,
        //                                        SUM(Result_TC__c) SumValue18,
        //                                        SUM(Result_Difference__c) SumValue19,    
        //                                        SUM(Result_AdditionalCost__c) SumValue20 
        //                                        FROM Factory__c WHERE Opp1__c = :opp1.Id AND DeleteFlag__c = false GROUP BY Opp1__c];
        
        
        // List<Opportunity> oppResult3 = [SELECT Id,
        //                                 TotalCP__c,
        //                                 TotalWC__c,
        //                                 TC__c,
        //                                 Order_TotalCP__c,
        //                                 Order_TotalWC__c,
        //                                 Order_TC__c,
        //                                 Order_Forecast_TotalCP__c,
        //                                 Order_Forecast_TotalWC__c,
        //                                 Order_Forecast_TC__c,
        //                                 Latest_TotalCP__c,
        //                                 Latest_TotalWC__c,
        //                                 Latest_TC__c,
        //                                 Latest_Forecast_TotalCP__c,
        //                                 Latest_Forecast_TotalWC__c,
        //                                 Latest_Forecast_TC__c,
        //                                 Result_TotalCP__c,
        //                                 Result_TotalWC__c,
        //                                 Result_TC__c,
        //                                 Result_Difference__c,
        //                                 Result_AdditionalCost__c         
        //                                 FROM Opportunity WHERE Id = :opp1.Id];

        // System.debug('★★★test3_CP'+oppResult3[0].TotalCP__c);
        // System.debug('★★★test3_WC'+oppResult3[0].TotalWC__c);
        // System.debug('★★★test3_TC'+oppResult3[0].TC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue1'),  oppResult3[0].TotalCP__c);     
        // System.AssertEquals(aggFacResult3[0].get('SumValue2'),  oppResult3[0].TotalWC__c);     
        // System.AssertEquals(aggFacResult3[0].get('SumValue3'),  oppResult3[0].TC__c);          
        // System.AssertEquals(aggFacResult3[0].get('SumValue4'),  oppResult3[0].Order_TotalCP__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue5'),  oppResult3[0].Order_TotalWC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue6'),  oppResult3[0].Order_TC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue7'),  oppResult3[0].Order_Forecast_TotalCP__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue8'),  oppResult3[0].Order_Forecast_TotalWC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue9'),  oppResult3[0].Order_Forecast_TC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue10'), oppResult3[0].Latest_TotalCP__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue11'), oppResult3[0].Latest_TotalWC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue12'), oppResult3[0].Latest_TC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue13'), oppResult3[0].Latest_Forecast_TotalCP__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue14'), oppResult3[0].Latest_Forecast_TotalWC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue15'), oppResult3[0].Latest_Forecast_TC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue16'), oppResult3[0].Result_TotalCP__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue17'), oppResult3[0].Result_TotalWC__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue18'), oppResult3[0].Result_TC__c);        
        // System.AssertEquals(aggFacResult3[0].get('SumValue19'), oppResult3[0].Result_Difference__c);
        // System.AssertEquals(aggFacResult3[0].get('SumValue20'), oppResult3[0].Result_AdditionalCost__c);

        // //Fac03の親ID変更
        // Fac03.Opp1__c = opp2.Id;
        // update Fac03;
/*
        //検証
        List<Opportunity> oppResult4 = [SELECT Id,
                                        TotalCP__c,
                                        TotalWC__c,
                                        TC__c,
                                        Order_TotalCP__c,
                                        Order_TotalWC__c,
                                        Order_TC__c,
                                        Order_Forecast_TotalCP__c,
                                        Order_Forecast_TotalWC__c,
                                        Order_Forecast_TC__c,
                                        Latest_TotalCP__c,
                                        Latest_TotalWC__c,
                                        Latest_TC__c,
                                        Latest_Forecast_TotalCP__c,
                                        Latest_Forecast_TotalWC__c,
                                        Latest_Forecast_TC__c,
                                        Result_TotalCP__c,
                                        Result_TotalWC__c,
                                        Result_TC__c,
                                        Result_Difference__c,
                                        Result_AdditionalCost__c  
                                        FROM Opportunity WHERE Id = :opp1.Id];
                                        
        System.AssertEquals(0, oppResult4[0].TotalCP__c);     
        System.AssertEquals(0, oppResult4[0].TotalWC__c);     
        System.AssertEquals(0, oppResult4[0].TC__c);          
        System.AssertEquals(0, oppResult4[0].TotalCP__c);
        System.AssertEquals(0, oppResult4[0].TotalWC__c);
        System.AssertEquals(0, oppResult4[0].TC__c);
        System.AssertEquals(0, oppResult4[0].Order_TotalCP__c);
        System.AssertEquals(0, oppResult4[0].Order_TotalWC__c);
        System.AssertEquals(0, oppResult4[0].Order_TC__c);
        System.AssertEquals(0, oppResult4[0].Order_Forecast_TotalCP__c);
        System.AssertEquals(0, oppResult4[0].Order_Forecast_TotalWC__c);
        System.AssertEquals(0, oppResult4[0].Order_Forecast_TC__c);
        System.AssertEquals(0, oppResult4[0].Latest_TotalCP__c);
        System.AssertEquals(0, oppResult4[0].Latest_TotalWC__c);
        System.AssertEquals(0, oppResult4[0].Latest_TC__c);
        System.AssertEquals(0, oppResult4[0].Latest_Forecast_TotalCP__c);
        System.AssertEquals(0, oppResult4[0].Latest_Forecast_TotalWC__c);
        System.AssertEquals(0, oppResult4[0].Latest_Forecast_TC__c);
        System.AssertEquals(0, oppResult4[0].Result_TotalCP__c);
        System.AssertEquals(0, oppResult4[0].Result_TotalWC__c);
        System.AssertEquals(0, oppResult4[0].Result_TC__c);
        System.AssertEquals(0, oppResult4[0].Result_Difference__c);
        System.AssertEquals(0, oppResult4[0].Result_AdditionalCost__c);
*/

        Test.stopTest();
    }

    //案件と場所別の数式項目テスト
    @IsTest
    private static void FormulaTest() {
        List<RecordType> recType = [SELECT Id,name,SobjectType  FROM RecordType WHERE SobjectType = 'Account' and name = '事業所'];

        Account acc = new Account(
            Name = 'Test Account',
            Phone = '09011111111',
            RecordTypeId = recType[0].Id,
            OfficeName__c = 'acc01'
        );
        insert acc;

        Property__c prop2 = new Property__c(
            Name = 'Test Prop'
        );
        insert prop2;
                
        //案件
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp1',
            StageName = '基本計画',
            CloseDate = Date.today(),
            SBU__c = 'PVスマエネ',
            Property__c = prop2.Id,
            ScheduledCollectionDate__c = Date.today(),
            ConstructionDistinction__c = '新設',
            OrderExpectation__c = '1', 
            Website__c = 01, 
            Handling__c = '委嘱', 
            DemanDepartment__c = '金融', 
            DemandOf__c = '官需', 
            InformationFrom__c = '施主',
            AccountId = acc.Id,
            Agency__c = acc.Id,
            Margin__c = 50,
            Order_Margin__c = 51,
            Latest_Margin__c = 52,
            Result_Margin__c = 53            
        );
        insert opp1;
        
        //場所別
        // 2021.07.16 コスト構造対応　受注時、受注後最新、売上実績セクションの項目は未使用となった為、ロジックから削除
        Factory__c Fac01 = new Factory__c(
            Opp1__c = opp1.Id,
            CommonRatio1__c='21% ： 製作所',          //21%
            BU__c='施設',
            CarryingDay__c=Date.today()+10,
            SR_CP__c                 = 200, 
            SRWC__c                  = 100
        );
        
        //テスト実行
        Test.startTest();

        insert Fac01;

        Test.stopTest();

        // 検証
        // 2021.07.16 コスト構造対応　受注時、受注後最新、売上実績セクションの項目は未使用となった為、ロジックから削除
        List<factory__c> fctResult1 = [SELECT Id,
                                       TC__c,
                                       WCRate__c,
                                       TCPercent__c,
                                       GP__c
                                       FROM factory__c WHERE Id = :Fac01.Id];

        System.AssertEquals(121,   fctResult1[0].TC__c);
        System.AssertEquals( 50,   fctResult1[0].WCRate__c);
        System.AssertEquals( 60.5, fctResult1[0].TCPercent__c);
        System.AssertEquals(100,   fctResult1[0].GP__c);
            
        List<Opportunity> oppResult1 = [SELECT Id,
                                        TotalCP__c,                                        
                                        TotalWC__c,
                                        TC__c,
                                        GP__c,
                                        WCPercent__c,
                                        TCRate__c
                                        FROM Opportunity WHERE Id = :opp1.Id];
        
        System.AssertEquals(200,  oppResult1[0].TotalCP__c);
        System.AssertEquals(100,  oppResult1[0].TotalWC__c);
        System.AssertEquals(121,  oppResult1[0].TC__c);
        System.AssertEquals(50,  oppResult1[0].GP__c);
        System.AssertEquals(50,  oppResult1[0].WCPercent__c);
        System.AssertEquals(60.5,  oppResult1[0].TCRate__c);        
    }
}