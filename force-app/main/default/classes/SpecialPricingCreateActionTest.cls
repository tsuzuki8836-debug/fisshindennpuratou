/*******************************************************************************
 *  クラス: 特殊仕様マスタ作成テストクラス
 *  概要: SpecialPricingCreateActionクラスのテストを定義する。
 *  作成者: テラスカイ深町
 *  作成日: 2022/10/20
 ******************************************************************************/
@isTest public class SpecialPricingCreateActionTest {
    /**
     * テストデータ作成
     */
    @testSetup static void createTestData() {
        MaintenanceJob__c job = new MaintenanceJob__c(
            Name = '特殊仕様マスタ自動作成'
        );
        insert job;
    }

    /**
     * テストケース　バッチサイズ指定あり
     * 
     * 【準備】
     *  パラーメータ（バッチサイズ：指定あり）を作成する
     * 
     * 【テスト実行】
     *  SpecialPricingCreateAction.createを実行する
     * 
     * 【期待値】
     *  正常に終了すること
     */
    @isTest static void createTest1() {
        MaintenanceJob__c job = [SELECT Id, batchSize__c FROM MaintenanceJob__c LIMIT 1];
        SpecialPricingCreateAction.Input param = new SpecialPricingCreateAction.Input();
        param.recordId = job.Id;
        param.batchSize = (Integer)job.batchSize__c;
        
        SpecialPricingCreateAction.create(new List<SpecialPricingCreateAction.Input>{ param });
        System.assert(true);
    }

    /**
     * テストケース　バッチサイズ指定なし
     * 
     * 【準備】
     *  パラーメータ（バッチサイズ：指定なし）を作成する
     * 
     * 【テスト実行】
     *  SpecialPricingCreateAction.createを実行する
     * 
     * 【期待値】
     *  正常に終了すること
     */
    @isTest static void createTest2() {
        MaintenanceJob__c job = [SELECT Id, batchSize__c FROM MaintenanceJob__c LIMIT 1];
        SpecialPricingCreateAction.Input param = new SpecialPricingCreateAction.Input();
        param.recordId = job.Id;
        param.batchSize = null;
        
        SpecialPricingCreateAction.create(new List<SpecialPricingCreateAction.Input>{ param });
        System.assert(true);
    }
}