/**
 * 競争先トリガーハンドラー
 */
public class CompetitorTriggerHandler {

    private static final String COMPANY_CODE_MITSUBISHI = System.Label.COMPANY_CODE_MITSUBISHI;
    private static final String COMPANY_NAME_OTHER = System.Label.COMPANY_NAME_OTHER;
    private static final String TOO_MANY_BIDDER = System.Label.TOO_MANY_BIDDER;
    private static final String COMPANY_OTHER_CHECK = System.Label.COMPANY_OTHER_CHECK;

    @TestVisible
    private static final CompetitorTriggerHandler internalInstance = new CompetitorTriggerHandler();

    /**
     * @description トリガ処理の取得
     * @return   return description
     */
    public static CompetitorTriggerHandler instance() {
        return CompetitorTriggerHandler.internalInstance;
    }

    /**
     * @description 保存時トリガーハンドラ。入力チェックを主に行う。
     * @param  newList 新規に保存する競争先リスト
     */
    public void onBeforeInsert(List<Competitors__c> newList) {
        this.checkAccount(newList);
        this.validateToSave(newList);
    }

    /**
     * @description 更新時トリガーハンドラ。入力チェックを主に行う。
     * @param  newList   更新対象の競争先リスト
     * @param  oldMap 更新前の競争先マップ
     */
    public void onBeforeUpdate(List<Competitors__c> newList, Map<Id, Competitors__c> oldMap) {
        this.validateToSave(newList);
        this.checkAccount(newList);
    }

    /**
     * @description 新規保存完了後のトリガーハンドラ。主に関連項目の更新処理を実行する。
     * @param  newList newList description
     */
    public void onAfterInsert(List<Competitors__c> newList) {
        this.updateRelateObjects(newList, null);
    }

    /**
     * @description 更新保存完了後のトリガーハンドラ。主に関連項目の更新処理を実行する。
     * @param  newList   newList description
     * @param  oldMap oldMap description
     */
    public void onAfterUpdate(List<Competitors__c> newList, Map<Id, Competitors__c> oldMap) {
        // NOTE: 落札者フラグ On => On 時に更新をしない場合は、ここでフィルタ。
        this.updateRelateObjects(newList, oldMap);
    }
    
    /**
     * @description 競争先のNameチェック。競争先が「その他」の場合入力チェックを行う
     * @param targets 確認対象の競争先リスト
     */
    private void checkAccount(List<Competitors__c> targets){
        
        Set<Id> accIds = new Set<Id>();
        for(Competitors__c comp : targets){
            accIds.add(comp .Account__c);
        }
            
        // 必要な項目を取得
        Map<id, Account> accMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN: accIds]);
        for(Competitors__c target : targets){
            if(accMap .get(target.Account__c).Name.equals(COMPANY_NAME_OTHER )){
                // 競争先(手入力)の必須チェック
                if(String.isBlank(target.CompetitorManual__c)){
                    target.CompetitorManual__c.addError(COMPANY_OTHER_CHECK );
                }
            }else{
                // その他以外の場合、取引先名を手入力競争先に反映
                target.CompetitorManual__c = accMap .get(target.Account__c).Name;
            }
        }
    }

    /**
     * @description 保存して良いかどうかの判定処理を行う。NGの場合は false を返し、NG 対象項目へエラーメッセージを付加する。
     * @param  targets 確認対象オブジェクトリスト
     * @return         保存可能であれば true それ以外の場合は false
     */
    private Boolean validateToSave(List<Competitors__c> targets) {
        // チェック内容: 一つの入札において、複数の競争先で落札者となってはならない
        // → 詰まり落札者以外はチェックが不要なので、落札者でフィルタする
        // 2件以上ある場合エラー
        List<Competitors__c> newWinners = this.filterByWinners(targets);
        // 関連する入札の勝者を検索
        // 1件以上ある場合エラー
        List<Competitors__c> alreadyWinners = this.selectRelateWinners(targets);

        // チェック実行
        Boolean result = true;
        // 登録時に落札者が1件以上ある、登録した以外に落札者チェックがすでにある
        if(newWinners.size() > 1 || alreadyWinners.size() > 0){
            for(Integer i=0;i<newWinners.size();i++){
                newWinners[i].BidManagement__c.addError(TOO_MANY_BIDDER);
            }
            result = false;
        }
        return result;
    }

    /**
     * @description 関連するオブジェクトを更新していく。
     * @param  targets 処理対象の競争先オブジェクトリスト
     */
    private void updateRelateObjects(List<Competitors__c> targets, Map<Id, Competitors__c> oldMap) {

        // 落札者以外はオブジェクト更新を行わないためフィルタ
        List<Competitors__c> newWinners = this.filterByWinners(targets);

        // 関連する入札
        List<Competitors__c> alreadyWinners = this.selectRelateWinners(targets);

        // 更新対象の入札レコードリストを取得
        Map<Id, BidManagement__c> bidManagements = new Map<Id, BidManagement__c> (
            this.selectRelateBidManagements(targets));

        // 関連する商談(更新対象)
        List<Opportunity> updateOpportunities = new List<Opportunity> ();

        // 関連する取引先(三菱電機)マップ取得
        Map<Id, Account> relateMitsubishi = new Map<Id, Account> (
            this.selectRelateMitsubishiDenki(newWinners));
        Decimal amount = 0;
        if(newWinners.size() > 0){
            // 入札レコードの内容更新
            for (Competitors__c comp : newWinners) {
                // 更新対象入札
                if(bidManagements.containsKey(comp.BidManagement__c) && comp.IsWinBidder__c){
                    // 更新対象入札
                    BidManagement__c updTarget = bidManagements.get(comp.BidManagement__c);

                    // 落札者/落札者(手動)
                    updTarget.SuccessfulBidder__c = comp.Account__c;
                    updTarget.SuccessfulBidderManual__c = comp.CompetitorManual__c;

                    // 落札金額(優先順は 3 > 2 > 1 回目応札金額)
                    amount = 0;
                    if(comp.ThirdBidAmount__c != null && comp.ThirdBidAmount__c != 0){
                        amount = comp.ThirdBidAmount__c;
                    } else if(comp.SecondBidAmount__c != null && comp.SecondBidAmount__c != 0 ){
                        amount = comp.SecondBidAmount__c;
                    } else if(comp.FirstBidAmount__c != null && comp.FirstBidAmount__c != 0){
                        amount = comp.FirstBidAmount__c;
                    }
                    updTarget.BidAmount__c = amount;
                    // 当社応礼金額は「三菱電機株式会社」が関連していた場合のみ
                    if (relateMitsubishi.containsKey(comp.Account__c)) {
                        updTarget.CompanyBidAmount__c = amount;
                    }
                    if(updTarget.Opportunity__c != null){
                        // 更新対象案件
                        Opportunity updOpps = new Opportunity(
                            Id = updTarget.Opportunity__c,
                            Competitor__c = updTarget.SuccessfulBidder__c,
                            CompetitorOther__c = updTarget.SuccessfulBidderManual__c,
                            FinalPrice__c = amount
                        );
                        updateOpportunities.add(updOpps);
                    }
                }
            }
        } else if (newWinners.size() == 0 && alreadyWinners.size() == 0){
            for(Competitors__c comp : targets){
                // 更新対象入札
                if(bidManagements.containsKey(comp.BidManagement__c) && !comp.IsWinBidder__c){
                    BidManagement__c updTarget = bidManagements.get(comp.BidManagement__c);

                    // 落札者/落札者(手動)
                    updTarget.SuccessfulBidder__c = null;
                    updTarget.SuccessfulBidderManual__c = '';
                    updTarget.BidAmount__c = null;
                    updTarget.CompanyBidAmount__c = null;
                    if(updTarget.Opportunity__c != null){
                        // 更新対象案件
                        Opportunity updOpps = new Opportunity(
                            Id = updTarget.Opportunity__c,
                            Competitor__c = null,
                            CompetitorOther__c = '',
                            FinalPrice__c = null
                        );
                        if(!updateOpportunities.contains(updOpps)){
                            updateOpportunities.add(updOpps);
                        }
                    }
                }
            }
        }
        // 更新を実行
        update bidManagements.values();
        if(updateOpportunities.size() > 0) update updateOpportunities;
    }

    /**
     * @description 関連する取引先のうち、三菱電機株式会社 に一致するものを検索します。
     * @param  targets targets description
     * @return         return description
     */
    private List<Account> selectRelateMitsubishiDenki(List<Competitors__c> targets) {

        // NOTE: 実装段階では Account 中に 三菱電機株式会社 が１件である保証が無いため、関連 Account を全て検索しています。
        // 関連する取引先を取得
        Set<Id> accountIds = new Set<Id> ();
        for (Competitors__c comp : targets) {
            accountIds.add(comp.Account__c);
        }

        // 統一企業コード（三菱電機株式会社）
        String companyCode = COMPANY_CODE_MITSUBISHI;
        return [SELECT Id FROM Account WHERE MelcoCode__c = :companyCode AND Id IN :accountIds];
    }

    /**
     * @description 関連する入札を一括取得する。
     * @param  targets 検索に用いる競争先
     * @return         入札リスト
     */
    @TestVisible
    private List<BidManagement__c> selectRelateBidManagements(List<Competitors__c> targets) {
        Set<Id> bidManageIds = new Set<Id> ();
        for (Competitors__c c : targets) {
            bidManageIds.add(c.BidManagement__c);
        }
        return [
            SELECT
                Id,
                Opportunity__c,             // 案件
                SuccessfulBidder__c,        // 落札者
                SuccessfulBidderManual__c,  // 落札者(手動)
                BidAmount__c,               // 落札金額
                CompanyBidAmount__c         // 当社応札金額
            FROM   BidManagement__c
            WHERE  Id IN :bidManageIds
        ];
    }

    /**
     * @description 関連入札の勝者を検索取得する。
     * @param  targets targets description
     * @param  updateflag 
     * @return         return description
     */
    private List<Competitors__c> selectRelateWinners(List<Competitors__c> targets) {
        // 対象の入札 ID を取得
        Set<Id> bidManageIds = new Set<Id> ();
        Set<Id> compIds = new Set<Id>();
        for (Competitors__c comp : targets) {
            bidManageIds.add(comp.BidManagement__c);
            compIds.add(comp.Id);
        }

        // 落札者の存在チェック
        return [
            SELECT Id, BidManagement__c FROM Competitors__c
            WHERE BidManagement__c IN :bidManageIds AND IsWinBidder__c = true AND Id NOT IN : compIds
        ];
    }

    /**
     * @description 落札に成功した競争先のみ取得
     * @param  targets フィルタ対象の競争先リスト
     * @return         落札者リスト
     */
    @TestVisible
    private List<Competitors__c> filterByWinners(List<Competitors__c> targets) {
        List<Competitors__c> winners = new List<Competitors__c>();
        for (Competitors__c comp : targets) {
            if (comp.IsWinBidder__c) { winners.add(comp); }
        }
        return winners;
    }
}