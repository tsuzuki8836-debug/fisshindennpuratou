/**
 * 競合結果トリガーハンドラー
 */
public class CompetitorsResultTriggerHandler {

    private static final String COMPANY_CODE_MITSUBISHI = System.Label.COMPANY_CODE_MITSUBISHI;
    private static final String COMPANY_NAME_OTHER = System.Label.COMPANY_NAME_OTHER;
    private static final String TOO_MANY_BIDDER = System.Label.TOO_MANY_BIDDER2;
    private static final String COMPANY_OTHER_CHECK = System.Label.COMPANY_OTHER_CHECK2;

    @TestVisible
    private static final CompetitorsResultTriggerHandler internalInstance = new CompetitorsResultTriggerHandler();

    /**
     * @description トリガ処理の取得
     * @return   return description
     */
    public static CompetitorsResultTriggerHandler instance() {
        return CompetitorsResultTriggerHandler.internalInstance;
    }

    /**
     * @description 保存時トリガーハンドラ。入力チェックを主に行う。
     * @param  newList 新規に保存する競合先リスト
     */
    public void onBeforeInsert(List<CompetitorsResult__c> newList) {
        this.validateToSave(newList);
    }

    /**
     * @description 更新時トリガーハンドラ。入力チェックを主に行う。
     * @param  newList   更新対象の競合先リスト
     * @param  oldMap 更新前の競合先マップ
     */
    public void onBeforeUpdate(List<CompetitorsResult__c> newList, Map<Id, CompetitorsResult__c> oldMap) {
        this.validateToSave(newList);
    }

    /**
     * @description 新規保存完了後のトリガーハンドラ。主に関連項目の更新処理を実行する。
     * @param  newList newList description
     */
    public void onAfterInsert(List<CompetitorsResult__c> newList) {
        this.updateRelateObjects(newList, null);
    }

    /**
     * @description 更新保存完了後のトリガーハンドラ。主に関連項目の更新処理を実行する。
     * @param  newList   newList description
     * @param  oldMap oldMap description
     */
    public void onAfterUpdate(List<CompetitorsResult__c> newList, Map<Id, CompetitorsResult__c> oldMap) {
        // NOTE: 落札者フラグ On => On 時に更新をしない場合は、ここでフィルタ。
        this.updateRelateObjects(newList, oldMap);
    }

    /**
     * @description 保存して良いかどうかの判定処理を行う。NGの場合は false を返し、NG 対象項目へエラーメッセージを付加する。
     * @param  targets 確認対象オブジェクトリスト
     * @return         保存可能であれば true それ以外の場合は false
     */
    private Boolean validateToSave(List<CompetitorsResult__c> targets) {
        // チェック内容: 一つの伺いにおいて、複数の競合先で落札者となってはならない
        // → 詰まり落札者以外はチェックが不要なので、落札者でフィルタする
        // 2件以上ある場合エラー
        List<CompetitorsResult__c> newWinners = this.filterByWinners(targets);
        // 関連する伺いの勝者を検索
        // 1件以上ある場合エラー
        List<CompetitorsResult__c> alreadyWinners = this.selectRelateWinners(targets);

        // チェック実行
        Boolean result = true;
        // 登録時に落札者が1件以上ある、登録した以外に落札者チェックがすでにある
        if(newWinners.size() > 1 || alreadyWinners.size() > 0){
            for(Integer i=0;i<newWinners.size();i++){
                newWinners[i].QuoteBiddingInquiry__c.addError(TOO_MANY_BIDDER);
            }
            result = false;
        }
        return result;
    }

    /**
     * @description 関連するオブジェクトを更新していく。
     * @param  targets 処理対象の競合先オブジェクトリスト
     */
    private void updateRelateObjects(List<CompetitorsResult__c> targets, Map<Id, CompetitorsResult__c> oldMap) {

        // 落札者以外はオブジェクト更新を行わないためフィルタ
        List<CompetitorsResult__c> newWinners = this.filterByWinners(targets);

        // 関連する伺い
        List<CompetitorsResult__c> alreadyWinners = this.selectRelateWinners(targets);

        // 更新対象の伺いレコードリストを取得
        Map<Id, QuoteBiddingInquiry__c> qbis = new Map<Id, QuoteBiddingInquiry__c> (
            this.selectRelateQbis(targets));

        // 関連する商談(更新対象)
        List<Opportunity> updateOpportunities = new List<Opportunity> ();

        // 関連する取引先(三菱電機)マップ取得
        Map<Id, Account> relateMitsubishi = new Map<Id, Account> (
            this.selectRelateMitsubishiDenki(targets));

        Decimal amount = 0;
        if(newWinners.size() > 0){
            // 伺いレコードの内容更新
            for (CompetitorsResult__c comp : newWinners) {
                // 更新対象伺い
                if(qbis.containsKey(comp.QuoteBiddingInquiry__c) && comp.IsWinBidder__c){
                    // 更新対象伺い
                    QuoteBiddingInquiry__c updTarget = qbis.get(comp.QuoteBiddingInquiry__c);

                    // // 競合結果に応じて更新される前の落札者を取得
                    // Id oldWinningBidder = updTarget.WinningBidder__c; // 落札者
                    // String oldManualWinningBidder = updTarget.ManualWinningBidder__c; // 落札者(手入力)
                    // Decimal oldWinningBidAmount = updTarget.WinningBidAmount__c; // 落札金額

                    // 落札者/落札者(手動)
                    updTarget.WinningBidder__c = comp.Account__c;
                    updTarget.ManualWinningBidder__c = comp.CompetitorManual__c;

                    // 落札金額(優先順は 6 > 5 > 4 > 3 > 2 > 1 回目応札金額)
                    amount = 0;
                    
                    if(comp.SixthBidAmount__c != null && comp.SixthBidAmount__c != 0){
                        amount = comp.SixthBidAmount__c;
                    } else if(comp.FifthBidAmount__c != null && comp.FifthBidAmount__c != 0){
                        amount = comp.FifthBidAmount__c;
                    } else if(comp.FourthBidAmount__c != null && comp.FourthBidAmount__c != 0){
                        amount = comp.FourthBidAmount__c;
                    } else if(comp.ThirdBidAmount__c != null && comp.ThirdBidAmount__c != 0){
                        amount = comp.ThirdBidAmount__c;
                    } else if(comp.SecondBidAmount__c != null && comp.SecondBidAmount__c != 0 ){
                        amount = comp.SecondBidAmount__c;
                    } else if(comp.FirstBidAmount__c != null && comp.FirstBidAmount__c != 0){
                        amount = comp.FirstBidAmount__c;
                    }
                    updTarget.WinningBidAmount__c = amount;

                    // if(oldWinningBidder != updTarget.WinningBidder__c || oldManualWinningBidder != updTarget.ManualWinningBidder__c || oldWinningBidAmount != updTarget.WinningBidAmount__c){
                    //     // 結果報告ステータスを未申請に設定
                    //     updTarget.ResultContactStatus__c = '未申請';   
                    // }
                }
            }
        } else if (newWinners.size() == 0 && alreadyWinners.size() == 0){
            for(CompetitorsResult__c comp : targets){
                // 更新対象伺い
                if(qbis.containsKey(comp.QuoteBiddingInquiry__c) && !comp.IsWinBidder__c){
                    QuoteBiddingInquiry__c updTarget = qbis.get(comp.QuoteBiddingInquiry__c);

                    // 落札者/落札者(手動)
                    updTarget.WinningBidder__c = null;
                    updTarget.ManualWinningBidder__c = '';
                    updTarget.WinningBidAmount__c = null;
                }
            }
        }
        
        // 更新を実行
        update qbis.values();
    }

    /**
     * @description 関連する取引先のうち、三菱電機株式会社 に一致するものを検索します。
     * @param  targets targets description
     * @return         return description
     */
    private List<Account> selectRelateMitsubishiDenki(List<CompetitorsResult__c> targets) {

        // NOTE: 実装段階では Account 中に 三菱電機株式会社 が１件である保証が無いため、関連 Account を全て検索しています。
        // 関連する取引先を取得
        Set<Id> accountIds = new Set<Id> ();
        for (CompetitorsResult__c comp : targets) {
            accountIds.add(comp.Account__c);
        }

        // 統一企業コード（三菱電機株式会社）
        String companyCode = COMPANY_CODE_MITSUBISHI;
        return [SELECT Id FROM Account WHERE MelcoCode__c = :companyCode AND Id IN :accountIds];
    }

    /**
     * @description 関連する伺いを一括取得する。
     * @param  targets 検索に用いる競合先
     * @return         伺いリスト
     */
    @TestVisible
    private List<QuoteBiddingInquiry__c> selectRelateQbis(List<CompetitorsResult__c> targets) {
        Set<Id> qbiIds = new Set<Id> ();
        for (CompetitorsResult__c c : targets) {
            qbiIds.add(c.QuoteBiddingInquiry__c);
        }
        return [
            SELECT
                Id,
                Opportunity__c,             // 案件
                WinningBidder__c,        // 落札者
                ManualWinningBidder__c,  // 落札者(手動)
                WinningBidAmount__c,            // 落札金額
                OurBidAmount__c,         // 当社契約金額
                ResultContactStatus__c    // 結果報告ステータス
            FROM  QuoteBiddingInquiry__c
            WHERE  Id IN :qbiIds
        ];
    }

    /**
     * @description 関連伺いの勝者を検索取得する。
     * @param  targets targets description
     * @param  updateflag 
     * @return         return description
     */
    private List<CompetitorsResult__c> selectRelateWinners(List<CompetitorsResult__c> targets) {
        // 対象の伺い ID を取得
        Set<Id> qbiIds = new Set<Id> ();
        Set<Id> compIds = new Set<Id>();
        for (CompetitorsResult__c comp : targets) {
            qbiIds.add(comp.QuoteBiddingInquiry__c);
            compIds.add(comp.Id);
        }

        // 落札者の存在チェック
        return [
            SELECT Id, QuoteBiddingInquiry__c FROM CompetitorsResult__c
            WHERE QuoteBiddingInquiry__c IN :qbiIds AND IsWinBidder__c = true AND Id NOT IN : compIds
        ];
    }

    /**
     * @description 落札に成功した競合先のみ取得
     * @param  targets フィルタ対象の競合先リスト
     * @return         落札者リスト
     */
    @TestVisible
    private List<CompetitorsResult__c> filterByWinners(List<CompetitorsResult__c> targets) {
        List<CompetitorsResult__c> winners = new List<CompetitorsResult__c>();
        for (CompetitorsResult__c comp : targets) {
            if (comp.IsWinBidder__c) { winners.add(comp); }
        }
        return winners;
    }
}