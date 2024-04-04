public class QuoteTriggerLogic {

    // 項目取得Utilクラスをインスタンス化
    GetAllFieldsUtil util = new GetAllFieldsUtil();
       
    public void cloneQuoteAndRelatedRecords(List<Quote__c> newQuotes){
        //マスタ見積レコード <マスタ見積のId, 新規見積のId>
    	Map<Id, Id> cloneQuoteIdMap = this.getCloneQuoteIds(newQuotes);
        //関連機器
        Map<Id, Device__c> devicesToInsertDetailMap = new Map<Id, Device__c>();
        //コピーする内訳のリスト
        List<Detail__c> dtlCloneList = new List<Detail__c>();
        
        if(cloneQuoteIdMap.size() > 0){
            //関連機器を取得する
            Map<Id, Quote__c> relatedDevicesMap = this.getDeviceRelatedRecords(cloneQuoteIdMap.keySet());            
            //関連機器を確認する
            for(Quote__c qRelate : relatedDevicesMap.values()){
                if(qRelate.Devices__r.size() > 200){
                    Trigger.new.get(0).addError('見積項目が200件を超えているためコピー機能は使用できません');
                }
                for(Device__c d : qRelate.Devices__r){        
                    //各関連機器をコピー
                    Device__c dv = d.clone();
                    //各関連機器の見積Idを設定する
                    dv.Quote__c = cloneQuoteIdMap.get(qRelate.Id);
                    //関連機器を集める
                    devicesToInsertDetailMap.put(d.id, dv);
                }
            }
            if(devicesToInsertDetailMap.values().isEmpty()) return;
            //関連機器を登録する
            insert devicesToInsertDetailMap.values();
        }
    }
    
    /**
     * マスタ見積のIDを取得
     */
    private Map<Id, Id> getCloneQuoteIds(List<Quote__c> newList){        
    	Map<Id, Id> idMap = new Map<Id, Id>();        
        for (Quote__c q : newList) {
        	if(q.isClone()){
            	idMap.put(q.getCloneSourceId(), q.Id);
        	}
    	}
        return idMap;        
    }
    
    /**
     * 関連機器を取得
     */
    private Map<Id, Quote__c> getDeviceRelatedRecords(Set<Id> qIds){
        
        return new Map<Id, Quote__c>((List<Quote__c>)Database.query('SELECT Id, (SELECT FIELDS(STANDARD) ' + util.getAllCustomFields('Device__c') + ' FROM Devices__r)' + 
                                                                    'FROM Quote__c WHERE Id IN: qIds'));
    }

    // NET関連の値計算
    public void calculateNETItem(List<Quote__c> newQuotes,Map<Id,Quote__c> oldQuotesMap){
        System.debug(newQuotes);
        Decimal d;
        Quote__c sourceQuote;
        final String facilityId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Quote__c' AND DeveloperName = 'Facility'].get(0).Id;

        for(Quote__c q : newQuotes){
            // 施設以外はNET率を使わない
            if(q.RecordTypeId != facilityId) continue;
            system.debug('q.isClone()'+q.isClone());
            // コピーレコードならコピー元のレコードを取得
            if(q.isClone()){
                sourceQuote = this.getCloneQuoteRecord(q);
            }

            system.debug('q.SelfTotal_NET_LastAcc__c'+q.SelfTotal_NET_LastAcc__c);
            // 手入力項目の有無で処理を分岐→入力有り：全体NET価格÷全体EP=全体&各NET率、入力無し：各NET価格÷各EP=各NET率
            // 最終顧客NET率
            if(q.SelfTotal_NET_LastAcc__c != null && 
            (!q.isClone() && q.SelfTotal_NET_LastAcc__c != oldQuotesMap.get(q.Id).SelfTotal_NET_LastAcc__c)
            || (q.isClone() && q.SelfTotal_NET_LastAcc__c != sourceQuote.SelfTotal_NET_LastAcc__c)){
                // 全体NET率=手入力全体NET÷全体EP
                q.Total_NETRate_LastAcc__c = q.SelfTotal_NET_LastAcc__c / q.QuotePriceSum__c * 100;
                
                // 各NET率に算出した全体NET率を入れる（EPが0のSBUはNET率も0%）
                if(q.Transforming_EP__c > 0){
                    q.Transforming_NETRate_LastAcc__c = q.Total_NETRate_LastAcc__c;
                }else{
                    q.Transforming_NETRate_LastAcc__c = 0;
                }
                if(q.UPS_EP__c > 0){
                    q.UPS_NETRate_LastAcc__c = q.Total_NETRate_LastAcc__c;
                }else{
                    q.UPS_NETRate_LastAcc__c = 0;
                }
                if(q.HousePowerGeneration_EP__c > 0){
                    q.HousePowerGeneration_NETRate_LastAcc__c = q.Total_NETRate_LastAcc__c;
                }else{
                    q.HousePowerGeneration_NETRate_LastAcc__c = 0;
                }
                if(q.Building_System_EP__c > 0){
                    q.Building_System_NETRate_LastAcc__c = q.Total_NETRate_LastAcc__c;
                }else{
                    q.Building_System_NETRate_LastAcc__c = 0;
                }
                if(q.Video_EP__c > 0){
                    q.Video_NETRate_LastAcc__c = q.Video_NETRate_LastAcc__c;
                }else{
                    q.Video_NETRate_LastAcc__c = 0;
                }
                if(q.Labor_EP__c > 0){
                    q.Labor_NETRate_LastAcc__c = q.Total_NETRate_LastAcc__c;
                }else{
                    q.Labor_NETRate_LastAcc__c = 0;
                }
                
                // 各NET価格に各EP×各NET率を入れる
                d = q.Transforming_EP__c * q.Transforming_NETRate_LastAcc__c / 100;
                q.Transforming_NET_LastAcc__c = d.round(System.RoundingMode.HALF_UP);

                d = q.UPS_EP__c * q.UPS_NETRate_LastAcc__c / 100;
                q.UPS_NET_LastAcc__c = d.round(System.RoundingMode.HALF_UP);

                d = q.HousePowerGeneration_EP__c * q.HousePowerGeneration_NETRate_LastAcc__c / 100;
                q.HousePowerGeneration_NET_LastAcc__c = d.round(System.RoundingMode.HALF_UP);

                d = q.Building_System_EP__c * q.Building_System_NETRate_LastAcc__c / 100;
                q.Building_System_NET_LastAcc__c = d.round(System.RoundingMode.HALF_UP);

                d = q.Video_EP__c * q.Video_NETRate_LastAcc__c / 100;
                q.Video_NET_LastAcc__c = d.round(System.RoundingMode.HALF_UP);

                d = q.Labor_EP__c * q.Labor_NETRate_LastAcc__c / 100;
                q.Labor_NET_LastAcc__c = d.round(System.RoundingMode.HALF_UP);
            } else {
                this.normalCalculateNETRateLastAcc(q);
            }

            // ゼネコンNET率
            if(q.SelfTotal_NET_General__c != null && 
            (!q.isClone() && q.SelfTotal_NET_General__c != oldQuotesMap.get(q.Id).SelfTotal_NET_General__c)
            || (q.isClone() && q.SelfTotal_NET_General__c != sourceQuote.SelfTotal_NET_General__c)){
                q.Total_NETRate_General__c = q.SelfTotal_NET_General__c / q.QuotePriceSum__c * 100;
                
                // 各NET率に算出した全体NET率を入れる（EPが0のSBUはNET率も0%）
                if(q.Transforming_EP__c > 0){
                    q.Transforming_NETRate_General__c = q.Total_NETRate_General__c;
                }else{
                    q.Transforming_NETRate_General__c = 0;
                }
                if(q.UPS_EP__c > 0){
                    q.UPS_NETRate_General__c = q.Total_NETRate_General__c;
                }else{
                    q.UPS_NETRate_General__c = 0;
                }
                if(q.HousePowerGeneration_EP__c > 0){
                    q.HousePowerGeneration_NETRate_General__c = q.Total_NETRate_General__c;
                }else{
                    q.HousePowerGeneration_NETRate_General__c = 0;
                }
                if(q.Building_System_EP__c > 0){
                    q.Building_System_NETRate_General__c = q.Total_NETRate_General__c;
                }else{
                    q.Building_System_NETRate_General__c = 0;
                }
                if(q.Video_EP__c > 0){
                    q.Video_NETRate_General__c = q.Video_NETRate_General__c;
                }else{
                    q.Video_NETRate_General__c = 0;
                }
                if(q.Labor_EP__c > 0){
                    q.Labor_NETRate_General__c = q.Total_NETRate_General__c;
                }else{
                    q.Labor_NETRate_General__c = 0;
                }

                // 各NET価格に各EP×各NET率を入れる
                d = q.Transforming_EP__c * q.Transforming_NETRate_General__c / 100;
                q.Transforming_NET_General__c = d.round(System.RoundingMode.HALF_UP);

                d = q.UPS_EP__c * q.UPS_NETRate_General__c / 100;
                q.UPS_NET_General__c = d.round(System.RoundingMode.HALF_UP);

                d = q.HousePowerGeneration_EP__c * q.HousePowerGeneration_NETRate_General__c / 100;
                q.HousePowerGeneration_NET_General__c = d.round(System.RoundingMode.HALF_UP);

                d = q.Building_System_EP__c * q.Building_System_NETRate_General__c / 100;
                q.Building_System_NET_General__c = d.round(System.RoundingMode.HALF_UP);

                d = q.Video_EP__c * q.Video_NETRate_General__c / 100;
                q.Video_NET_General__c = d.round(System.RoundingMode.HALF_UP);

                d = q.Labor_EP__c * q.Labor_NETRate_General__c / 100;
                q.Labor_NET_General__c = d.round(System.RoundingMode.HALF_UP);
            } else {
                this.normalCalculateNETRateGeneral(q);
            }

            // サブコンNET率
            if(q.SelfTotal_NET_Sub__c != null && 
            (!q.isClone() && q.SelfTotal_NET_Sub__c != oldQuotesMap.get(q.Id).SelfTotal_NET_Sub__c)
            || (q.isClone() && q.SelfTotal_NET_Sub__c != sourceQuote.SelfTotal_NET_Sub__c)){
                q.Total_NETRate_Sub__c = q.SelfTotal_NET_Sub__c / q.QuotePriceSum__c * 100;
                
                // 各NET率に算出した全体NET率を入れる（EPが0のSBUはNET率も0%）
                if(q.Transforming_EP__c > 0){
                    q.Transforming_NETRate_Sub__c = q.Total_NETRate_Sub__c;
                }else{
                    q.Transforming_NETRate_Sub__c = 0;
                }
                if(q.UPS_EP__c > 0){
                    q.UPS_NETRate_Sub__c = q.Total_NETRate_Sub__c;
                }else{
                    q.UPS_NETRate_Sub__c = 0;
                }
                if(q.HousePowerGeneration_EP__c > 0){
                    q.HousePowerGeneration_NETRate_Sub__c = q.Total_NETRate_Sub__c;
                }else{
                    q.HousePowerGeneration_NETRate_Sub__c = 0;
                }
                if(q.Building_System_EP__c > 0){
                    q.Building_System_NETRate_Sub__c = q.Total_NETRate_Sub__c;
                }else{
                    q.Building_System_NETRate_Sub__c = 0;
                }
                if(q.Video_EP__c > 0){
                    q.Video_NETRate_Sub__c = q.Video_NETRate_Sub__c;
                }else{
                    q.Video_NETRate_Sub__c = 0;
                }
                if(q.Labor_EP__c > 0){
                    q.Labor_NETRate_Sub__c = q.Total_NETRate_Sub__c;
                }else{
                    q.Labor_NETRate_Sub__c = 0;
                }

                // 各NET価格に各EP×各NET率を入れる
                d = q.Transforming_EP__c * q.Transforming_NETRate_Sub__c / 100;
                q.Transforming_NET_Sub__c = d.round(System.RoundingMode.HALF_UP);

                d = q.UPS_EP__c * q.UPS_NETRate_Sub__c / 100;
                q.UPS_NET_Sub__c = d.round(System.RoundingMode.HALF_UP);

                d = q.HousePowerGeneration_EP__c * q.HousePowerGeneration_NETRate_Sub__c / 100;
                q.HousePowerGeneration_NET_Sub__c = d.round(System.RoundingMode.HALF_UP);

                d = q.Building_System_EP__c * q.Building_System_NETRate_Sub__c / 100;
                q.Building_System_NET_Sub__c = d.round(System.RoundingMode.HALF_UP);

                d = q.Video_EP__c * q.Video_NETRate_Sub__c / 100;
                q.Video_NET_Sub__c = d.round(System.RoundingMode.HALF_UP);

                d = q.Labor_EP__c * q.Labor_NETRate_Sub__c / 100;
                q.Labor_NET_Sub__c = d.round(System.RoundingMode.HALF_UP);
            } else {
                this.normalCalculateNETRateSub(q);
            }
        }
    }

    // 最終顧客NET率を通常計算
    private void normalCalculateNETRateLastAcc(Quote__c q){
        Decimal d;
        // 受変電NET率（最終顧客）
        if(q.Transforming_NET_LastAcc__c != null && q.Transforming_EP__c > 0){
            d = q.Transforming_NET_LastAcc__c / q.Transforming_EP__c * 100;
            q.Transforming_NETRate_LastAcc__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Transforming_NETRate_LastAcc__c = 0;
        }
        // UPSNET率（最終顧客）
        if(q.UPS_NET_LastAcc__c != null && q.UPS_EP__c > 0){
            d = q.UPS_NET_LastAcc__c / q.UPS_EP__c * 100;
            q.UPS_NETRate_LastAcc__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.UPS_NETRate_LastAcc__c = 0;
        }
        // 自家発NET率（最終顧客）
        if(q.HousePowerGeneration_NET_LastAcc__c != null && q.HousePowerGeneration_EP__c > 0){
            d = q.HousePowerGeneration_NET_LastAcc__c / q.HousePowerGeneration_EP__c * 100;
            q.HousePowerGeneration_NETRate_LastAcc__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.HousePowerGeneration_NETRate_LastAcc__c = 0;
        }
        // ビルシNET率（最終顧客）
        if(q.Building_System_NET_LastAcc__c != null && q.Building_System_EP__c > 0){
            d = q.Building_System_NET_LastAcc__c / q.Building_System_EP__c * 100;
            q.Building_System_NETRate_LastAcc__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Building_System_NETRate_LastAcc__c = 0;
        }
        // 映像NET率（最終顧客）
        if(q.Video_NET_LastAcc__c != null && q.Video_EP__c > 0){
            d = q.Video_NET_LastAcc__c / q.Video_EP__c * 100;
            q.Video_NETRate_LastAcc__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Video_NETRate_LastAcc__c = 0;
        }
        // 労務NET率（最終顧客）
        if(q.Labor_NET_LastAcc__c != null && q.Labor_EP__c > 0){
            d = q.Labor_NET_LastAcc__c / q.Labor_EP__c * 100;
            q.Labor_NETRate_LastAcc__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Labor_NETRate_LastAcc__c = 0;
        }
        // 全体NET率（最終顧客）
        if(q.Total_NET_LastAcc__c != null && q.QuotePriceSum__c > 0){
            d = q.Total_NET_LastAcc__c / q.QuotePriceSum__c * 100;
            q.Total_NETRate_LastAcc__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Total_NETRate_LastAcc__c = 0;
        }
    }

    // ゼネコンNET率を通常計算
    private void normalCalculateNETRateGeneral(Quote__c q){
        Decimal d;
        // 受変電NET率（ゼネコン）
        if(q.Transforming_NET_General__c != null && q.Transforming_EP__c > 0){
            d = q.Transforming_NET_General__c / q.Transforming_EP__c * 100;
            q.Transforming_NETRate_General__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Transforming_NETRate_General__c = 0;
        }
        // UPSNET率（ゼネコン）
        if(q.UPS_NET_General__c != null && q.UPS_EP__c > 0){
            d = q.UPS_NET_General__c / q.UPS_EP__c * 100;
            q.UPS_NETRate_General__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.UPS_NETRate_General__c = 0;
        }
        // 自家発NET率（ゼネコン）
        if(q.HousePowerGeneration_NET_General__c != null && q.HousePowerGeneration_EP__c > 0){
            d = q.HousePowerGeneration_NET_General__c / q.HousePowerGeneration_EP__c * 100;
            q.HousePowerGeneration_NETRate_General__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.HousePowerGeneration_NETRate_General__c = 0;
        }
        // ビルシNET率（ゼネコン）
        if(q.Building_System_NET_General__c != null && q.Building_System_EP__c > 0){
            d = q.Building_System_NET_General__c / q.Building_System_EP__c * 100;
            q.Building_System_NETRate_General__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Building_System_NETRate_General__c = 0;
        }
        // 映像NET率（ゼネコン）
        if(q.Video_NET_General__c != null && q.Video_EP__c > 0){
            d = q.Video_NET_General__c / q.Video_EP__c * 100;
            q.Video_NETRate_General__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Video_NETRate_General__c = 0;
        }
        // 労務NET率（ゼネコン）
        if(q.Labor_NET_General__c != null && q.Labor_EP__c > 0){
            d = q.Labor_NET_General__c / q.Labor_EP__c * 100;
            q.Labor_NETRate_General__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Labor_NETRate_General__c = 0;
        }
        // 全体NET率（ゼネコン）
        if(q.Total_NET_General__c != null && q.QuotePriceSum__c > 0){
            d = q.Total_NET_General__c / q.QuotePriceSum__c * 100;
            q.Total_NETRate_General__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Total_NETRate_General__c = 0;
        }
    }

    // サブコンNET率を通常計算
    private void normalCalculateNETRateSub(Quote__c q){
        Decimal d;
        // 受変電NET率（サブコン）
        if(q.Transforming_NET_Sub__c != null && q.Transforming_EP__c > 0){
            d = q.Transforming_NET_Sub__c / q.Transforming_EP__c * 100;
            q.Transforming_NETRate_Sub__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Transforming_NETRate_Sub__c = 0;
        }
        // UPSNET率（サブコン）
        if(q.UPS_NET_Sub__c != null && q.UPS_EP__c > 0){
            d = q.UPS_NET_Sub__c / q.UPS_EP__c * 100;
            q.UPS_NETRate_Sub__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.UPS_NETRate_Sub__c = 0;
        }
        // 自家発NET率（サブコン）
        if(q.HousePowerGeneration_NET_Sub__c != null && q.HousePowerGeneration_EP__c > 0){
            d = q.HousePowerGeneration_NET_Sub__c / q.HousePowerGeneration_EP__c * 100;
            q.HousePowerGeneration_NETRate_Sub__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.HousePowerGeneration_NETRate_Sub__c = 0;
        }
        // ビルシNET率（サブコン）
        if(q.Building_System_NET_Sub__c != null && q.Building_System_EP__c > 0){
            d = q.Building_System_NET_Sub__c / q.Building_System_EP__c * 100;
            q.Building_System_NETRate_Sub__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Building_System_NETRate_Sub__c = 0;
        }
        // 映像NET率（サブコン）
        if(q.Video_NET_Sub__c != null && q.Video_EP__c > 0){
            d = q.Video_NET_Sub__c / q.Video_EP__c * 100;
            q.Video_NETRate_Sub__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Video_NETRate_Sub__c = 0;
        }
        // 労務NET率（サブコン）
        if(q.Labor_NET_Sub__c != null && q.Labor_EP__c > 0){
            d = q.Labor_NET_Sub__c / q.Labor_EP__c * 100;
            q.Labor_NETRate_Sub__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Labor_NETRate_Sub__c = 0;
        }
        // 全体NET率（サブコン）
        if(q.Total_NET_Sub__c != null && q.QuotePriceSum__c > 0){
            d = q.Total_NET_Sub__c / q.QuotePriceSum__c * 100;
            q.Total_NETRate_Sub__c = d.round(System.RoundingMode.HALF_UP);
        }else{
            q.Total_NETRate_Sub__c = 0;
        }
    }

 
    // マスタ見積のレコード情報を取得
    private Quote__c getCloneQuoteRecord(Quote__c newQuote){        
    	String sourceId = newQuote.getCloneSourceId();

        Quote__c sourceQuote = [SELECT Id
                                    , SelfTotal_NET_LastAcc__c
                                    , SelfTotal_NET_General__c
                                    , SelfTotal_NET_Sub__c
                                FROM Quote__c
                                WHERE Id = :sourceId
                                LIMIT 1];
        
        System.debug(sourceQuote);
        
        return sourceQuote;        
    }
    /**
     * 全角→半角変換
     *
     * @param value 変換元文字列
     * @return 半角文字列
     */
    public String convertFullToHalf(String value) {
        ReplaceChar reChar = new ReplaceChar();
        return reChar.convertFullToHalf(value);
        // String result;
        // // 変換内容がない場合
        // if(String.isEmpty(value)) {
        //     result = '';
        // }else{
        //     // 半角文字のみなら以降スキップ
        //     if (Pattern.matches('[ -~]+', value)) {
        //         result = value;
        //     }else{
        //         Map<String, String> fulltoHalfMap2 = new Map<String, String>();
        //         fulltoHalfMap2.put( '０',  '0' );
        //         fulltoHalfMap2.put( '１',  '1' );
        //         fulltoHalfMap2.put( '２',  '2' );
        //         fulltoHalfMap2.put( '３',  '3' );
        //         fulltoHalfMap2.put( '４',  '4' );
        //         fulltoHalfMap2.put( '５',  '5' );
        //         fulltoHalfMap2.put( '６',  '6' );
        //         fulltoHalfMap2.put( '７',  '7' );
        //         fulltoHalfMap2.put( '８',  '8' );
        //         fulltoHalfMap2.put( '９',  '9' );
        //         // エスケープ必要文字
        //         Set<String> escapeChars = new Set<String>();
        //         escapeChars.add('\\');
        //         escapeChars.add('*');
        //         escapeChars.add('+');
        //         escapeChars.add('.');
        //         escapeChars.add('?');
        //         escapeChars.add('{');
        //         escapeChars.add('}');
        //         escapeChars.add('(');
        //         escapeChars.add(')');
        //         escapeChars.add('[');
        //         escapeChars.add(']');
        //         escapeChars.add('^');
        //         escapeChars.add('$');
        //         escapeChars.add('|');
        //         escapeChars.add('/');
    
        //         for (String key : fulltoHalfMap2.keySet()) {
        //             if (value.contains(key)) {
        //                 String tempKey = key;
        //                 if (escapeChars.contains(tempKey)) {
        //                     tempKey = '\\' + tempKey;
        //                 }
        //                 value = value.replaceAll(tempKey, fulltoHalfMap2.get(key));
        //             }
        //         }
        //         String comma = '，';
        //         if(value.contains(comma)){
        //             value = value.replaceAll(comma, '');
        //         }
        //         result = value;
        //     }
        // }
        // system.debug(result);
        // return result;
    }
}