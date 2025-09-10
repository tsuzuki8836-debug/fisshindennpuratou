/*******************************************************************************
 *  クラス: 特殊仕様マスタ作成バッチテストクラス
 *  概要: SpecialPricingCreateBatchのテストを定義する。
 *  作成者: テラスカイ深町
 *  作成日: 2022/10/20
 ******************************************************************************/
@isTest public class SpecialPricingCreateBatchTest {
    private static final String RECORDTYPE_NAME_DETAIL = '明細';
    private static final String RECORDTYPE_NAME_CHSSIS = '筐体';
    private static final String Frequency_00Hz = '00Hz';
    private static final String Frequency_50Hz = '50Hz';
    private static final String Frequency_60Hz = '60Hz';
    private static final Decimal BASE_PRICE = 1234567;

    /**
     * テストケース　明細・施設
     * 
     * 【準備】
     *  パラーメータ（所在：明細、BU：S）を作成する
     * 
     * 【テスト実行】
     *  SpecialPricingCreateBatchを実行する
     * 
     * 【期待値】
     *  価格表が1件追加されること
     *  価格表の項目が期待値と同じであること
     *  価格表の単価が* 1.6されていること
     */
    @isTest static void executeBatchTest1() {
        // メンテナンスジョブ
        MaintenanceJob__c job = new MaintenanceJob__c(
            Name = '特殊仕様マスタ自動作成'
            , Whereabouts__c = '明細'
            , BU__c = 'S'
        );
        insert job;

        SpecialPricingCreateBatch batch = new SpecialPricingCreateBatch(job.Id);

        Test.startTest();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<PricingTable__c> results = getPricingTable();
        System.assertEquals(1, results.size());

        PricingTable__c result = results[0];

        // 単価以外をチェック
        checkResult(result);
        
        // 単価をチェック
        System.assertEquals(1980000, result.Price__c);
    }

    /**
     * テストケース　筐体・施設
     * 
     * 【準備】
     *  パラーメータ（BU：S、所在：明細）を作成する
     * 
     * 【テスト実行】
     *  SpecialPricingCreateBatchを実行する
     * 
     * 【期待値】
     *  価格表が1件追加されること
     *  価格表の項目が期待値と同じであること
     *  価格表の単価が* 1.6 + 500000されていること
     */
    @isTest static void executeBatchTest2() {
        // メンテナンスジョブ
        MaintenanceJob__c job = new MaintenanceJob__c(
            Name = '特殊仕様マスタ自動作成'
            , Whereabouts__c = '筐体'
            , BU__c = 'S'
        );
        insert job;

        SpecialPricingCreateBatch batch = new SpecialPricingCreateBatch(job.Id);

        Test.startTest();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<PricingTable__c> results = getPricingTable();
        System.assertEquals(1, results.size());

        PricingTable__c result = results[0];

        // 単価以外をチェック
        checkResult(result);
        
        // 単価をチェック
        System.assertEquals(2480000, result.Price__c);
    }

    /**
     * テストケース　明細・水環境
     * 
     * 【準備】
     *  パラーメータ（所在：明細、BU：M）を作成する
     * 
     * 【テスト実行】
     *  SpecialPricingCreateBatchを実行する
     * 
     * 【期待値】
     *  価格表が1件追加されること
     *  価格表の項目が期待値と同じであること
     *  価格表の単価が* 1.6 * 1.01されていること
     */
    @isTest static void executeBatchTest3() {
        // メンテナンスジョブ
        MaintenanceJob__c job = new MaintenanceJob__c(
            Name = '特殊仕様マスタ自動作成'
            , Whereabouts__c = '明細'
            , BU__c = 'M'
        );
        insert job;

        SpecialPricingCreateBatch batch = new SpecialPricingCreateBatch(job.Id);

        Test.startTest();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<PricingTable__c> results = getPricingTable();
        System.assertEquals(1, results.size());

        PricingTable__c result = results[0];

        // 単価以外をチェック
        checkResult(result);
        
        // 単価をチェック
        System.assertEquals(2000000, result.Price__c);
    }

    /**
     * テストケース　筐体・水環境
     * 
     * 【準備】
     *  パラーメータ（所在：筐体、BU：M）を作成する
     * 
     * 【テスト実行】
     *  SpecialPricingCreateBatchを実行する
     * 
     * 【期待値】
     *  価格表が1件追加されること
     *  価格表の項目が期待値と同じであること
     *  価格表の単価が* 1.6 + 500000 * 1.01されていること
     */
    @isTest static void executeBatchTest4() {
        // メンテナンスジョブ
        MaintenanceJob__c job = new MaintenanceJob__c(
            Name = '特殊仕様マスタ自動作成'
            , Whereabouts__c = '筐体'
            , BU__c = 'M'
        );
        insert job;

        SpecialPricingCreateBatch batch = new SpecialPricingCreateBatch(job.Id);

        Test.startTest();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<PricingTable__c> results = getPricingTable();
        System.assertEquals(1, results.size());

        PricingTable__c result = results[0];

        // 単価以外をチェック
        checkResult(result);
        
        // 単価をチェック
        System.assertEquals(2500000, result.Price__c);//実際の値が2,500,060.27の為、期待値は2,500,000となる。
    }

    /**
     * テストケース　イレギュラーケース（特殊計算式未登録）
     * 
     * 【準備】
     *  パラーメータ（特殊計算式未登録）を作成する
     * 
     * 【テスト実行】
     *  SpecialPricingCreateBatchを実行する
     * 
     * 【期待値】
     *  価格表が1件追加されること
     *  価格表の項目が期待値と同じであること
     *  価格表の単価がベース価格表と同じであること
     */
    @isTest static void executeBatchTest5() {
        // メンテナンスジョブ
        MaintenanceJob__c job = new MaintenanceJob__c(
            Name = '特殊仕様マスタ自動作成'
            , Whereabouts__c = '明細'
            , BU__c = 'K'
        );
        insert job;

        SpecialPricingCreateBatch batch = new SpecialPricingCreateBatch(job.Id);

        Test.startTest();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<PricingTable__c> results = getPricingTable();
        System.assertEquals(1, results.size());

        PricingTable__c result = results[0];

        // 単価以外をチェック
        checkResult(result);
        
        // 単価をチェック
        System.assertEquals(BASE_PRICE, result.Price__c);
    }

    /**
     * テストケース　例外
     * 
     * 【準備】
     *  パラーメータ（例外）を作成する
     * 
     * 【テスト実行】
     *  SpecialPricingCreateBatchを実行する
     * 
     * 【期待値】
     *  価格表が1件追加されること
     *  価格表の項目が期待値と同じであること
     *  価格表の単価がベース価格表と同じであること
     */
    @isTest static void executeBatchTest6() {
        // メンテナンスジョブ
        MaintenanceJob__c job = new MaintenanceJob__c(
            Name = '特殊仕様マスタ自動作成'
            , Whereabouts__c = '筐体'
            , BU__c = 'K'
        );
        insert job;

        SpecialPricingCreateBatch batch = new SpecialPricingCreateBatch(job.Id);

        Test.startTest();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<PricingTable__c> results = getPricingTable();
        System.assertEquals(0, results.size());
    }

    /**
     * 価格表の検証
     */
    private static void checkResult(PricingTable__c result) {
        PricingTable__c basePt = getPricingTable(true, result.MajorClassificationCode__c, result.MinorClassificationCode__c);
        SpecialCalculationPattern__c pattern = getSpecialCalculationPattern(result.MajorClassificationCode__c, result.MinorClassificationCode__c);

        // 特殊計算あり
        System.assertEquals(false, result.IsSpecialCalculation__c);
        // ベース価格
        System.assertEquals(basePt.Id, result.BasePrice__c);
        // 特殊計算パターン
        System.assertEquals(pattern.Id, result.SpecialCalculationPattern__c);
        // 特殊仕様No
        System.assertEquals(pattern.SpecialSpecificationNo__c, result.SpecialSpecificationNo__c);
        // 名称1
        System.assertEquals(pattern.Name1__c, result.Name1__c);
        // 名称2
        System.assertEquals(pattern.Name2__c, result.Name2__c);
        // 名称3
        System.assertEquals(pattern.Name3__c, result.Name3__c);
        // 名称4
        System.assertEquals(pattern.Name4__c, result.Name4__c);
        // 名称5
        System.assertEquals(pattern.Name5__c, result.Name5__c);
        // 名称6
        System.assertEquals(pattern.Name6__c, result.Name6__c);
        // 名称7
        System.assertEquals(pattern.Name7__c, result.Name7__c);
        // 名称8
        System.assertEquals(pattern.Name8__c, result.Name8__c);
        // 名称9
        System.assertEquals(pattern.Name9__c, result.Name9__c);
        // 名称10
        System.assertEquals(pattern.Name10__c, result.Name10__c);
    }

    /**
     * テストデータ作成
     */
    @testSetup static void createTestData() {
        // レコードタイプ（価格表）取得
        Map<Id, String> pricingRecordTypeById = new Map<Id, String>();
        Map<String, Id> pricingRecordTypeByName = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SobjectType = 'PricingTable__c']) {
            pricingRecordTypeById.put(rt.Id, rt.Name);
            pricingRecordTypeByName.put(rt.Name, rt.Id);
        }

        // 価格表

        // 明細・施設
        PricingTable__c table01 = new PricingTable__c(
            RecordTypeId = pricingRecordTypeByName.get(RECORDTYPE_NAME_DETAIL) 
            , BU__c = 'S'
            , MajorClassificationCode__c = '19'
            , MajorClassificationName__c = 'MajorClassificationName'
            , MinorClassificationCode__c = '17'
            , MinorClassificationName__c = 'MinorClassificationName'
            , CategoryCode__c = null
            , Frequency__c = Frequency_00Hz
            , SpecialCalculationTitle__c = '66kV C-GIS'
            , RECNo__c = 1
            , IsSpecialCalculation__c = true
            , Price__c = BASE_PRICE
        );
        // 筐体・施設
        PricingTable__c table02 = new PricingTable__c(
            RecordTypeId = pricingRecordTypeByName.get(RECORDTYPE_NAME_CHSSIS) 
            , BU__c = 'S'
            , MajorClassificationCode__c = '02'
            , MajorClassificationName__c = 'MajorClassificationName'
            , MinorClassificationCode__c = '00'
            , MinorClassificationName__c = 'MinorClassificationName'
            , CategoryCode__c = '01'
            , Frequency__c = null
            , SpecialCalculationTitle__c = '特高TR 油入'
            , RECNo__c = 1
            , IsSpecialCalculation__c = true
            , Price__c = BASE_PRICE
        );
        // 明細・水環境
        PricingTable__c table03 = new PricingTable__c(
            RecordTypeId = pricingRecordTypeByName.get(RECORDTYPE_NAME_DETAIL) 
            , BU__c = 'M'
            , MajorClassificationCode__c = '22'
            , MajorClassificationName__c = 'MajorClassificationName'
            , MinorClassificationCode__c = '17'
            , MinorClassificationName__c = 'MinorClassificationName'
            , CategoryCode__c = null
            , Frequency__c = Frequency_00Hz
            , SpecialCalculationTitle__c = '66kV C-GIS'
            , RECNo__c = 1
            , IsSpecialCalculation__c = true
            , Price__c = BASE_PRICE
        );
        // 筐体・水環境
        PricingTable__c table04 = new PricingTable__c(
            RecordTypeId = pricingRecordTypeByName.get(RECORDTYPE_NAME_CHSSIS) 
            , BU__c = 'M'
            , MajorClassificationCode__c = '01'
            , MajorClassificationName__c = 'MajorClassificationName'
            , MinorClassificationCode__c = '00'
            , MinorClassificationName__c = 'MinorClassificationName'
            , CategoryCode__c = '01'
            , Frequency__c = null
            , SpecialCalculationTitle__c = '66kV C-GIS'
            , RECNo__c = 1
            , IsSpecialCalculation__c = true
            , Price__c = BASE_PRICE
        );
        // 特殊計算式未登録
        PricingTable__c table05 = new PricingTable__c(
            RecordTypeId = pricingRecordTypeByName.get(RECORDTYPE_NAME_DETAIL) 
            , BU__c = 'K'
            , MajorClassificationCode__c = '99'
            , MajorClassificationName__c = 'MajorClassificationName'
            , MinorClassificationCode__c = '01'
            , MinorClassificationName__c = 'MinorClassificationName'
            , CategoryCode__c = '01'
            , Frequency__c = null
            , SpecialCalculationTitle__c = '66kV C-GIS'
            , RECNo__c = 1
            , IsSpecialCalculation__c = true
            , Price__c = BASE_PRICE
        );
        PricingTable__c table06 = new PricingTable__c(
            RecordTypeId = pricingRecordTypeByName.get(RECORDTYPE_NAME_CHSSIS) 
            , BU__c = 'K'
            , MajorClassificationCode__c = '99'
            , MajorClassificationName__c = 'MajorClassificationName'
            , MinorClassificationCode__c = '02'
            , MinorClassificationName__c = 'MinorClassificationName'
            , CategoryCode__c = '01'
            , Frequency__c = null
            , SpecialCalculationTitle__c = '66kV C-GIS'
            , RECNo__c = 1
            , IsSpecialCalculation__c = true
            , Price__c = 999999999
        );
        List<PricingTable__c> tables = new List<PricingTable__c>{ table01, table02, table03, table04, table05, table06 };
        insert tables;

        // 特殊計算パターン
        SpecialCalculationPattern__c pattern01 = createSpecialCalculationPattern(table01, pricingRecordTypeById.get(table01.RecordTypeId));
        SpecialCalculationPattern__c pattern02 = createSpecialCalculationPattern(table02, pricingRecordTypeById.get(table02.RecordTypeId));
        SpecialCalculationPattern__c pattern03 = createSpecialCalculationPattern(table03, pricingRecordTypeById.get(table03.RecordTypeId));
        SpecialCalculationPattern__c pattern04 = createSpecialCalculationPattern(table04, pricingRecordTypeById.get(table04.RecordTypeId));
        SpecialCalculationPattern__c pattern05 = createSpecialCalculationPattern(table05, pricingRecordTypeById.get(table05.RecordTypeId));
        SpecialCalculationPattern__c pattern06 = createSpecialCalculationPattern(table06, pricingRecordTypeById.get(table06.RecordTypeId));
        List<SpecialCalculationPattern__c> patterns = new List<SpecialCalculationPattern__c>{ pattern01, pattern02, pattern03, pattern04, pattern05, pattern06 };
        for (SpecialCalculationPattern__c p : patterns) {
            p.Name1__c = 'a';
            p.Name2__c = 'b';
            p.Name3__c = 'c';
            p.Name4__c = 'd';
            p.Name5__c = 'e';
            p.Name6__c = 'f';
            p.Name7__c = 'g';
            p.Name8__c = 'h';
            p.Name9__c = 'i';
            p.Name10__c = 'j';
            p.Specification1DisplayOrder__c = 1;
            p.Specification2DisplayOrder__c = 2;
            p.Specification3DisplayOrder__c = 3;
            p.Specification4DisplayOrder__c = 4;
            p.Specification5DisplayOrder__c = 5;
            p.Specification6DisplayOrder__c = 6;
            p.Specification7DisplayOrder__c = 7;
            p.Specification8DisplayOrder__c = 8;
            p.Specification9DisplayOrder__c = 9;
            p.Specification10DisplayOrder__c = 10;
        }
        insert patterns;

        // 特殊計算マスタ
        SpecialCalculationMaster__c master01 = new SpecialCalculationMaster__c(Name = 'master01', BU__c = table01.BU__c, Multiplication__c = 1.6, Addition__c = 0);
        SpecialCalculationMaster__c master02 = new SpecialCalculationMaster__c(Name = 'master02', BU__c = table01.BU__c, Multiplication__c = 1, Addition__c = 500000);
        SpecialCalculationMaster__c master03 = new SpecialCalculationMaster__c(Name = 'master01', BU__c = table01.BU__c, Multiplication__c = 1.01, Addition__c = 0);
        SpecialCalculationMaster__c master04 = new SpecialCalculationMaster__c(Name = 'master01', BU__c = table01.BU__c, Multiplication__c = 999999999, Addition__c = 0);
        List<SpecialCalculationMaster__c> masters = new List<SpecialCalculationMaster__c>{ master01, master02, master03, master04 };
        insert masters;

        // 特殊計算式
        List<SpecialCalculationFormula__c> formulas = new List<SpecialCalculationFormula__c>{
            // パターン１：×1.6
            new SpecialCalculationFormula__c( SpecialCalculationPattern__c = pattern01.Id, SpecialCalculationMaster__c = master01.Id)
            // パターン２：×1.6＋500000
            ,new SpecialCalculationFormula__c( SpecialCalculationPattern__c = pattern02.Id, SpecialCalculationMaster__c = master01.Id )
            ,new SpecialCalculationFormula__c( SpecialCalculationPattern__c = pattern02.Id, SpecialCalculationMaster__c = master02.Id )
            // パターン３：×1.6×1.01
            ,new SpecialCalculationFormula__c( SpecialCalculationPattern__c = pattern03.Id, SpecialCalculationMaster__c = master01.Id )
            ,new SpecialCalculationFormula__c( SpecialCalculationPattern__c = pattern03.Id, SpecialCalculationMaster__c = master03.Id )
            // パターン４：×1.6+500000×1.01
            ,new SpecialCalculationFormula__c( SpecialCalculationPattern__c = pattern04.Id, SpecialCalculationMaster__c = master01.Id )
            ,new SpecialCalculationFormula__c( SpecialCalculationPattern__c = pattern04.Id, SpecialCalculationMaster__c = master02.Id )
            ,new SpecialCalculationFormula__c( SpecialCalculationPattern__c = pattern04.Id, SpecialCalculationMaster__c = master03.Id )
            // 例外パターン：×999999999
            ,new SpecialCalculationFormula__c( SpecialCalculationPattern__c = pattern06.Id, SpecialCalculationMaster__c = master04.Id )
        };
        insert formulas;
    }

    /**
     * 価格表から特殊計算パターンを作成
     */
    private static SpecialCalculationPattern__c createSpecialCalculationPattern(PricingTable__c pt, String whereabouts) {
        return new SpecialCalculationPattern__c(
            SpecialCalculationTitle__c = pt.SpecialCalculationTitle__c          // 特殊計算表タイトル
            ,BU__c = pt.BU__c                                                   // BU
            ,MajorClassificationCode__c = pt.MajorClassificationCode__c         // 大分類コード
            ,MinorClassificationCode__c = pt.MinorClassificationCode__c         // 小分類コード
            ,Frequency__c = pt.Frequency__c                                     // 周波数
            ,Whereabouts__c = whereabouts                                       // 所在
            ,CategoryCode__c = pt.CategoryCode__c                               // 種類コード
            ,CalculationCategory__c = pt.CalculationCategory__c                 // 計算区分
            ,SpecialSpecificationNo__c = 1                                      // 特殊仕様No
        );
    }

    /**
     * 特殊計算マスタ実行結果を取得
     */
    private static List<PricingTable__c> getPricingTable() {
        return [
            SELECT 
                Id
                ,RecordTypeId
                ,RecordTypeName__c
                ,BU__c
                ,MajorClassificationCode__c
                ,MinorClassificationCode__c
                ,Frequency__c
                ,SpecialCalculationTitle__c
                ,RECNo__c
                ,IsSpecialCalculation__c
                ,BasePrice__c
                ,Price__c
                ,SpecialCalculationPattern__c
                ,SpecialSpecificationNo__c
                ,Name1__c
                ,Name2__c
                ,Name3__c
                ,Name4__c
                ,Name5__c
                ,Name6__c
                ,Name7__c
                ,Name8__c
                ,Name9__c
                ,Name10__c
            FROM 
                PricingTable__c
            WHERE
                IsSpecialCalculation__c = false
        ];
    }

    /**
     * 指定条件の価格表を取得
     */
    private static PricingTable__c getPricingTable(Boolean isSpec, String majorCode, String minorCode) {
        return [
            SELECT 
                Id
                ,RecordTypeId
                ,RecordTypeName__c
                ,BU__c
                ,MajorClassificationCode__c
                ,MinorClassificationCode__c
                ,Frequency__c
                ,SpecialCalculationTitle__c
                ,RECNo__c
                ,IsSpecialCalculation__c
                ,BasePrice__c
                ,Price__c
                ,SpecialCalculationPattern__c
                ,SpecialSpecificationNo__c
                ,Name1__c
                ,Name2__c
                ,Name3__c
                ,Name4__c
                ,Name5__c
                ,Name6__c
                ,Name7__c
                ,Name8__c
                ,Name9__c
                ,Name10__c
            FROM 
                PricingTable__c
            WHERE
                IsSpecialCalculation__c = :isSpec
                AND MajorClassificationCode__c = :majorCode
                AND MinorClassificationCode__c = :minorCode
            LIMIT 1
        ];
    }

    /**
     * 指定条件の特殊パターンを取得
     */
    private static SpecialCalculationPattern__c getSpecialCalculationPattern(String majorCode, String minorCode) {
        return [
            SELECT 
                Id
                ,BU__c
                ,MajorClassificationCode__c
                ,MinorClassificationCode__c
                ,Frequency__c
                ,SpecialCalculationTitle__c
                ,SpecialSpecificationNo__c
                ,Name1__c
                ,Name2__c
                ,Name3__c
                ,Name4__c
                ,Name5__c
                ,Name6__c
                ,Name7__c
                ,Name8__c
                ,Name9__c
                ,Name10__c
            FROM 
                SpecialCalculationPattern__c
            WHERE
                MajorClassificationCode__c = :majorCode
                AND MinorClassificationCode__c = :minorCode
            LIMIT 1
        ];
    }
}