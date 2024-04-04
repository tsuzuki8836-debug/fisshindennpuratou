/*******************************************************************************
 *  クラス: 特殊仕様マスタ作成クラス
 *  概要: 特殊仕様マスタ自動作成バッチを実行する。
 *  作成者: テラスカイ深町
 *  作成日: 2022/10/05
 ******************************************************************************/
public with sharing class SpecialPricingCreateAction {
    // Inputパラメータ  
    public class Input {
        @InvocableVariable(required=true label='レコードID')
        public String recordId;
        @InvocableVariable(required=true label='バッチサイズ')
        public Integer batchSize;
    }

    /**
     * レコードタイプID取得
     * @param objDevName オブジェクトAPI参照名
     * @param recordTypeDevName レコードタイプAPI参照名
     * @return レコードタイプID
     */
    @invocableMethod(label='特殊仕様マスタ作成')
    public static void create(List<Input> parameters) {
        for(Input param : parameters) {
            SpecialPricingCreateBatch batch = new SpecialPricingCreateBatch(param.recordId);
            Integer size = (param.batchSize == null) ? 200 : param.batchSize;
            Database.executeBatch(batch, size);
        }
    }
}