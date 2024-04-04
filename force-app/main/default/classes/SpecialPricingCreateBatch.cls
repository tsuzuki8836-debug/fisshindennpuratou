/*******************************************************************************
 *  クラス: 特殊仕様マスタ作成バッチ
 *  概要: 特殊計算用の価格表レコードを自動生成する。
 *  作成者: テラスカイ深町
 *  作成日: 2022/10/05
 ******************************************************************************/
public with sharing class SpecialPricingCreateBatch implements Database.Batchable<sObject>, Database.Stateful {
    // メンテナンスレコードID
    public String maintenanceId;
    // エラーリスト
    public List<Exception> exList = new List<Exception>();
    // 削除件数
    private Integer deleteCount = 0;
    // 登録件数
    private Integer insertCount = 0;

    /**
     * コンストラクタ
     * バッチ実行時の初期化処理を実行
     */
    public SpecialPricingCreateBatch(String recordId) {
        maintenanceId = recordId;
    }

    /**
     * startメソッド
     * 処理対象のレコード取得を実行
     * @param jobId Database.BatchableContext
     * @return 処理対象レコード
     */
    public List<PricingTable__c> start(Database.BatchableContext jobId) {
        System.debug('SpecialPricingCreateBatch.start()');

        // メンテナンスジョブレコード取得
        MaintenanceJob__c job = this.getMaintenance();

        // 価格表の項目定義を取得
        Schema.SObjectType objType = PricingTable__c.getSObjectType();
        Map<String, sObjectField> fieldsMap = objType.getDescribe().fields.getMap();        

        // ベース価格表取得
        String query = 'SELECT ' + String.join(new List<String>(fieldsMap.keySet()), ', ') + ' FROM PricingTable__c';
        query += ' WHERE IsSpecialCalculation__c = true';
        if ( job.BU__c != null ) {
            List<String> bu = job.BU__c.split(';');
            query += ' AND BU__c IN :bu';
        }
        if ( job.Whereabouts__c != null ) {
            List<String> whereabouts = job.Whereabouts__c.split(';');
            query += ' AND RecordTypeName__c IN :whereabouts';
        }

        return Database.query(query);
    }

    /**
     * executeメソッド
     * ロジッククラスの処理を実行
     * @param jobId Database.BatchableContext
     * @param recordList ベース価格表のリスト
     */
    public void execute(Database.BatchableContext jobId, List<PricingTable__c> basePricings) {
        System.debug('SpecialPricingCreateBatch.execute()');
        System.debug('jobId:' + jobId);
        System.debug('basePt:' + basePricings);

        try {
            // 特殊計算パターン取得
            List<SpecialCalculationPattern__c> patterns = this.getPattern(basePricings);

            // 特殊計算価格表作成
            List<PricingTable__c> specialPricing = this.createSpecialPricing(basePricings, patterns);

            // 特殊計算価格表登録
            this.registerSpecialPricing(specialPricing);

        } catch (Exception ex) {
            // キャッチした例外を例外リストに追加
            this.exList.add(ex);
        }
    }

    /**
     * finishメソッド
     * 処理結果の通知を実行
     * @param jobId Database.BatchableContext
     */
    public void finish(Database.BatchableContext jobId) {
        System.debug('SpecialPricingCreateBatch.finish()');
        System.debug('jobId:' + jobId);

        String message;

        System.debug('例外件数:' + exList.size());

        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:jobId.getJobId()];
        System.debug('AsyncApexJob:' + a);

        if (this.exList.size() == 0) {
            message = String.format('特殊仕様マスタの作成が完了しました。（削除数：{0}、登録数：{1}）', 
                                    new List<Object>{ this.deleteCount, this.insertCount } );
        } else {
            List<String> errorMessages = new List<String>();
            for (Exception ex : this.exList) {
                errorMessages.add(ex.getMessage() + ':\n' + ex.getStackTraceString());
            }
            message = String.join(errorMessages, ',\n');
        }

        this.updateMaintenance(false, message);
    }

    /**
     * メンテナンスレコード更新
     * @param running 実行中フラグ
     * @param message 実行結果
     */
    private void updateMaintenance(Boolean running, String message) {
        MaintenanceJob__c rec = new MaintenanceJob__c(
            id = this.maintenanceId
            ,IsRunning__c = running
            ,Result__c = message.left(255)
        );
        update rec;
    }

    /**
     * メンテナンスレコード取得
     * @param running 実行中フラグ
     * @param message 実行結果
     */
    private MaintenanceJob__c getMaintenance() {
        return [
            SELECT
                BU__c
                , Whereabouts__c
            FROM
                MaintenanceJob__c
            WHERE
                Id = :this.maintenanceId
        ];
    }

    /**
     * 特殊計算パターン取得
     * @param basePricings ベース価格表
     * @return 特殊計算パータン
     */
    private List<SpecialCalculationPattern__c> getPattern(List<PricingTable__c> basePricings) {
        System.debug('SpecialPricingCreateBatch.getPattern()');

        // 特殊計算表タイトルのSETを作成
        Set<String> titles = new Set<String>();
        for ( PricingTable__c bp : basePricings ) {
            titles.add(bp.SpecialCalculationTitle__c);
        }

        // 特殊計算パターンからベース価格に関連するレコードを取得する
        return [
            SELECT 
                Name                        // 特殊計算パターン番号
                ,SpecialCalculationTitle__c // 特殊計算表タイトル
                ,BU__c                      // BU
                ,MajorClassificationCode__c // 大分類コード
                ,MinorClassificationCode__c // 小分類コード
                ,Frequency__c               // 周波数
                ,Whereabouts__c             // 所在
                ,CategoryCode__c            // 種類コード
                ,CalculationCategory__c     // 計算区分
                ,Name1__c                   // 名称1
                ,Name2__c                   // 名称2
                ,Name3__c                   // 名称3
                ,Name4__c                   // 名称4
                ,Name5__c                   // 名称5
                ,Name6__c                   // 名称6
                ,Name7__c                   // 名称7
                ,Name8__c                   // 名称8
                ,Name9__c                   // 名称9
                ,Name10__c                  // 名称10
                ,SpecialSpecificationNo__c  // 特殊仕様No
            FROM 
                SpecialCalculationPattern__c
            WHERE
                SpecialCalculationTitle__c = :titles
        ];
    }

    /**
     * 特殊価格表作成
     * @param basePricings ベース価格表
     * @param patterns 特殊計算パータン
     * @return 特殊計算価格表
     */
    private List<PricingTable__c> createSpecialPricing(List<PricingTable__c> basePricings, List<SpecialCalculationPattern__c> patterns) {
        System.debug('SpecialPricingCreateBatch.createSpecialPricing()');

        // ベース価格表と特殊計算パターンから特殊計算価格表を作成
        List<PricingTable__c> specialPricing = new List<PricingTable__c>();
        List<String> nameList = new List<String>();
        Set<String> chassisCodeSet = new Set<String>{'02','05','22','26'};
        for ( SpecialCalculationPattern__c pattern : patterns ) {
            for ( PricingTable__c bp : basePricings ) {        
                if (
                    bp.SpecialCalculationTitle__c == pattern.SpecialCalculationTitle__c
                    && bp.BU__c == pattern.BU__c
                    && bp.MajorClassificationCode__c == pattern.MajorClassificationCode__c
                    && bp.MinorClassificationCode__c == pattern.MinorClassificationCode__c
                    && bp.Frequency__c == pattern.Frequency__c
                    && bp.RecordTypeName__c == pattern.Whereabouts__c
                    && bp.CategoryCode__c == pattern.CategoryCode__c
                    && bp.CalculationCategory__c == pattern.CalculationCategory__c
                ) {
                    
                        // ベース価格のコピーを作成
                        PricingTable__c sp = bp.clone(false, true, false, false);
                        // 特殊計算パターンの値で編集
                        sp.IsSpecialCalculation__c = false;
                        sp.BasePrice__c = bp.Id;
                        sp.SpecialCalculationPattern__c = pattern.Id;
                        if(String.isNotBlank(pattern.Name1__c)) sp.Name1__c = pattern.Name1__c;
                        if(String.isNotBlank(pattern.Name2__c)) sp.Name2__c = pattern.Name2__c;
                        if(String.isNotBlank(pattern.Name3__c)) sp.Name3__c = pattern.Name3__c;
                        if(String.isNotBlank(pattern.Name4__c)) sp.Name4__c = pattern.Name4__c;
                        if(String.isNotBlank(pattern.Name5__c)) sp.Name5__c = pattern.Name5__c;
                        if(String.isNotBlank(pattern.Name6__c)) sp.Name6__c = pattern.Name6__c;
                        if(String.isNotBlank(pattern.Name7__c)) sp.Name7__c = pattern.Name7__c;
                        if(String.isNotBlank(pattern.Name8__c)) sp.Name8__c = pattern.Name8__c;
                        if(String.isNotBlank(pattern.Name9__c)) sp.Name9__c = pattern.Name9__c;
                        if(String.isNotBlank(pattern.Name10__c)) sp.Name10__c = pattern.Name10__c;
                        sp.SpecialSpecificationNo__c = pattern.SpecialSpecificationNo__c;

                        if(chassisCodeSet.contains(sp.MajorClassificationCode__c) && sp.RecordTypeName__c == '筐体'){
                            nameList.add('筐体');
                        }
                        if(sp.MajorClassificationCode__c == '02' && sp.RecordTypeName__c == '筐体'){
                            nameList.add('高圧盤');
                        }
                        if(sp.MajorClassificationCode__c == '03' && sp.MinorClassificationCode__c == '03' && sp.RecordTypeName__c == '筐体'){
                            nameList.add('モールド');
                        }
                        nameList.add(sp.Name1__c);
                        if(sp.MajorClassificationCode__c == '03' && (sp.MinorClassificationCode__c == '01' || sp.MinorClassificationCode__c == '02') && sp.RecordTypeName__c == '筐体'){
                            nameList.add('変圧器');
                        }
                        nameList.add(sp.Name2__c);
                        nameList.add(sp.Name3__c);
                        nameList.add(sp.Name4__c);
                        nameList.add(sp.Name5__c);
                        nameList.add(sp.Name6__c);
                        nameList.add(sp.Name7__c);
                        nameList.add(sp.Name8__c);
                        nameList.add(sp.Name9__c);
                        nameList.add(sp.Name10__c);

                        sp.DisplayName__c = String.join(nameList, ' ');
                        
                        specialPricing.add(sp);

                        nameList = new List<String>();
                }                
            }
        }

        // 特殊計算価格表から特殊計算式レコードを取得
        List<SpecialCalculationFormula__c> formulas = this.getSpecialCalculationFormula(specialPricing);
        System.debug('getSpecialCalculationFormula:' + formulas);

        // 特殊計算パターンと特殊計算式レコードから、特殊計算パターンのMAPを作成（Key：特殊計算パターン.ID、Value：特殊計算式のリスト）
        Map<Id, List<SpecialCalculationFormula__c>> formulaMap = new Map<Id, List<SpecialCalculationFormula__c>>();
        for ( SpecialCalculationFormula__c formula : formulas ) {
            List<SpecialCalculationFormula__c> fList = new List<SpecialCalculationFormula__c>();
            if ( formulaMap.containskey(formula.SpecialCalculationPattern__c ) ) {
                fList = formulaMap.get(formula.SpecialCalculationPattern__c);
            }
            fList.add(formula);
            formulaMap.put(formula.SpecialCalculationPattern__c, fList);
        }

        // 特殊計算価格表の価格を設定
        for ( PricingTable__c sp : specialPricing ) {
            List<SpecialCalculationFormula__c> fList = formulaMap.get(sp.SpecialCalculationPattern__c);
            if ( fList != null ) {
                Decimal price = (sp.Price__c == null ? 0 : sp.Price__c);
                for ( SpecialCalculationFormula__c scf : fList ) {
                    Decimal multipl = (scf.Multiplication__c == null ? 1 : scf.Multiplication__c);
                    Decimal add = (scf.Addition__c == null ? 0 : scf.Addition__c);
                    price = (price * multipl + add);
                }
                if ( price != 0 ) {
                    // 単価×乗算値＋加算値 ※値は上位4桁目で切り上げる。
                    Integer digits = 3 - String.valueOf(price.round()).length();
                    sp.Price__c = price.setScale(digits, System.RoundingMode.UP);
                }
            }
        }

        return specialPricing;
    }

    /**
     * 特殊計算式取得
     * @param specialPricing 特殊計算価格表
     * @return 特殊計算式
     */
    private List<SpecialCalculationFormula__c> getSpecialCalculationFormula(List<PricingTable__c> specialPricing) {
        // 特殊計算価格表の特殊パターンIDからSETを作成
        Set<Id> spIds = new Set<Id>();
        for ( PricingTable__c sp : specialPricing ) {
            spIds.add(sp.SpecialCalculationPattern__c);
        }

        // 特殊パターンに関連する特殊計算式を取得
        return [
            SELECT 
                Id 
                ,Name
                ,Multiplication__c
                ,Addition__c     
                ,SpecialCalculationPattern__c          
            FROM 
                SpecialCalculationFormula__c
            WHERE 
                SpecialCalculationPattern__c = :spIds
        ];
    }

    /**
     * 特殊価格表登録
     * @param specialPricing 特殊計算価格表
     */
    private void registerSpecialPricing(List<PricingTable__c> specialPricing) {
        System.debug('SpecialPricingCreateBatch.registerSpecialPricing()');

        // セーブポイント作成
        Savepoint sp = Database.setSavepoint();
        try {
            // 価格表から削除対象レコードを取得
            List<PricingTable__c> deleteRecords = this.getDeletePricingTable(specialPricing);
            
            // 取得した価格表レコードを削除
            System.debug('価格表 削除レコード：' + deleteRecords.size());
            if (deleteRecords.size() > 0) delete deleteRecords;
            this.deleteCount += deleteRecords.size();

            // 特殊価格表を登録
            System.debug('価格表 登録レコード：' + specialPricing.size());
            if (specialPricing.size() > 0) insert specialPricing;
            this.insertCount += specialPricing.size();

        } catch (Exception ex) {
            System.debug('特殊価格表登録エラー ' + ex.getMessage());
            for(PricingTable__c pt : specialPricing) System.debug(pt);

            // ロールバック
            Database.rollback(sp);
            throw ex;
        }
    }

    /**
     * 価格表から削除対象レコード取得
     * @param specialPricing 特殊計算価格表
     * @return 削除対象レコード
     */
    private List<PricingTable__c> getDeletePricingTable(List<PricingTable__c> specialPricing) {
        Set<Id> basePriceIds = new Set<Id>();
        for ( PricingTable__c sp : specialPricing ) {
            basePriceIds.add(sp.BasePrice__c);
        }
        return [SELECT Id FROM PricingTable__c WHERE BasePrice__c = :basePriceIds];
    }
}