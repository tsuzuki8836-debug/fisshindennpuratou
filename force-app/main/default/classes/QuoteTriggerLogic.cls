public class QuoteTriggerLogic {
    @testvisible private static final Id recTypeOfficialDemandId = Schema.SObjectType.Quote__c.getRecordTypeInfosByName().get('官需').getRecordTypeId();
    //べき乗計算
    @testvisible private static final Double EXPONENT = -0.4711;
    //14,000千円
    @testvisible private static final Integer PRICE_A = 14000*1000;
    //200,000千円
    @testvisible private static final Integer PRICE_B = 200000*1000;
    // 項目取得Utilクラスをインスタンス化
    GetAllFieldsUtil util = new GetAllFieldsUtil();
       
    public void cloneQuoteAndRelatedRecords(List<Quote__c> newQuotes){
        //マスタ見積レコード <マスタ見積のId, 新規見積のId>
    	Map<Id, Id> cloneQuoteIdMap = this.getCloneQuoteIds(newQuotes);
        //関連機器
        Map<Id, Device__c> devicesToInsertDetailMap = new Map<Id, Device__c>();
        //工事区分がある見積をコピーしたか否か
        Boolean copyConstructionZone = false;
        //コピーする内訳のリスト
        List<Detail__c> dtlCloneList = new List<Detail__c>();
        //Insertする関連工事区分（見積項目作成時にも利用するため、copyConstructionZoneのif文の外で作成）
        Map<Id, ConstructionZone__c> insertConstructionZoneMap = new Map<Id, ConstructionZone__c>();
        //Insertする関連細別（見積項目作成時にも利用するため、copyConstructionZoneのif文の外で作成）
        Map<Id, Device_SmallCategory__c> insertDeviceSmallCategoryMap = new Map<Id, Device_SmallCategory__c>();
        
        if(cloneQuoteIdMap.size() > 0){
            //関連機器を取得する
            Map<Id, Quote__c> relatedDevicesMap = this.getDeviceRelatedRecords(cloneQuoteIdMap.keySet());
            for(Quote__c newQuote : newQuotes){
                if(newQuote.SectionExistence__c == 'あり' && newQuote.isClone() == true){
                    copyConstructionZone = true;
                    break;
                }
            }

            if(copyConstructionZone == true){
                //既存の関連工事区分
                Map<Id, Quote__c> relatedConstructionZoneMap = this.getConstructionZoneRelatedRecords(cloneQuoteIdMap.keySet());
                //関連工事区分を確認する
                for(Quote__c qRelate : relatedConstructionZoneMap.values()){
                    for(ConstructionZone__c c : qRelate.ConstructionZones__r){        
                        //各関連工事区分をコピー
                        ConstructionZone__c con = c.clone();
                        //各関連工事区分の見積Idを設定する
                        con.Quote__c = cloneQuoteIdMap.get(qRelate.Id);
                        //関連工事区分を集める
                        insertConstructionZoneMap.put(c.id, con);
                    }
                }
                //関連工事区分を登録する
                insert insertConstructionZoneMap.values();

                //Insertする関連工種
                Map<Id, Device_LargeCategory__c> insertDeviceLargeCategoryMap = new Map<Id, Device_LargeCategory__c>();
                //既存の関連工種
                Map<Id, ConstructionZone__c> relatedDeviceLargeCategoryMap = this.getDeviceLargeCategoryRelatedRecords(insertConstructionZoneMap.keySet());
                //関連工種を確認する
                for(ConstructionZone__c conRelate : relatedDeviceLargeCategoryMap.values()){
                    for(Device_LargeCategory__c dlc : conRelate.Device_LargeCategorys__r){        
                        //各関連工種をコピー
                        Device_LargeCategory__c deviceLC = dlc.clone();
                        //各関連工種の工事区分Idを設定する
                        deviceLC.ConstructionZone__c = insertConstructionZoneMap.get(conRelate.Id).Id;
                        //関連工種を集める
                        insertDeviceLargeCategoryMap.put(dlc.id, deviceLC);
                    }
                }
                //関連工種を登録する
                insert insertDeviceLargeCategoryMap.values();

                //Insertする関連種別
                Map<Id, Device_MiddleCategory__c> insertDeviceMiddleCategoryMap = new Map<Id, Device_MiddleCategory__c>();
                //既存の関連種別
                Map<Id, Device_LargeCategory__c> relatedDeviceMiddleCategoryMap = this.getDeviceMiddleCategoryRelatedRecords(insertDeviceLargeCategoryMap.keySet());
                //関連種別を確認する
                for(Device_LargeCategory__c dlcRelate : relatedDeviceMiddleCategoryMap.values()){
                    for(Device_MiddleCategory__c dmc : dlcRelate.Device_MiddleCategorys__r){        
                        //各関連種別をコピー
                        Device_MiddleCategory__c deviceMC = dmc.clone();
                        //各関連種別の工種Idを設定する
                        deviceMC.Device_LargeCategory__c = insertDeviceLargeCategoryMap.get(dlcRelate.Id).Id;
                        //関連種別を集める
                        insertDeviceMiddleCategoryMap.put(dmc.id, deviceMC);
                    }
                }
                //関連種別を登録する
                insert insertDeviceMiddleCategoryMap.values();

                //既存の関連細別
                Map<Id, Device_MiddleCategory__c> relatedDeviceSmallCategoryMap = this.getDeviceSmallCategoryRelatedRecords(insertDeviceMiddleCategoryMap.keySet());
                //関連細別を確認する
                for(Device_MiddleCategory__c dmcRelate : relatedDeviceSmallCategoryMap.values()){
                    for(Device_SmallCategory__c dsc : dmcRelate.Device_SmallCategorys__r){        
                        //各関連細別をコピー
                        Device_SmallCategory__c deviceSC = dsc.clone();
                        //各関連細別の種別Idを設定する
                        deviceSC.Device_MiddleCategory__c = insertDeviceMiddleCategoryMap.get(dmcRelate.Id).Id;
                        //関連細別を集める
                        insertDeviceSmallCategoryMap.put(dsc.id, deviceSC);
                    }
                }
                //関連細別を登録する
                insert insertDeviceSmallCategoryMap.values();
            }

            //関連見積項目を確認する
            for(Quote__c qRelate : relatedDevicesMap.values()){
                if(qRelate.Devices__r.size() > 200){
                    Trigger.new.get(0).addError('見積項目が200件を超えているためコピー機能は使用できません');
                }
                for(Device__c d : qRelate.Devices__r){        
                    //各関連見積項目をコピー
                    Device__c dv = d.clone();
                    //各関連見積項目の見積Idを設定する
                    dv.Quote__c = cloneQuoteIdMap.get(qRelate.Id);
                    //工区有りの場合、各関連見積項目の工区Id・細別Idを設定する
                    if(copyConstructionZone == true){
                        //リレーション先の工区を取得出来た場合のみ、コピー先の工区Idを設定
                        if(insertConstructionZoneMap.get(d.ConstructionZone__c) != null){
                            dv.ConstructionZone__c = insertConstructionZoneMap.get(d.ConstructionZone__c).Id;
                        }
                        //リレーション先の細別を取得出来た場合のみ、コピー先の細別Idを設定
                        if(insertDeviceSmallCategoryMap.get(d.Device_SmallCategory__c) != null){
                            dv.Device_SmallCategory__c = insertDeviceSmallCategoryMap.get(d.Device_SmallCategory__c).Id;
                        }
                    }
                    //関連見積項目を集める
                    devicesToInsertDetailMap.put(d.id, dv);
                }
            }
            if(devicesToInsertDetailMap.values().isEmpty()) return;
            //関連見積項目を登録する
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

    /**
     * 関連工事区分を取得
     */
    private Map<Id, Quote__c> getConstructionZoneRelatedRecords(Set<Id> qIds){
        
        return new Map<Id, Quote__c>((List<Quote__c>)Database.query('SELECT Id, (SELECT FIELDS(STANDARD) ' + util.getAllCustomFields('ConstructionZone__c') + ' FROM ConstructionZones__r)' + 
                                                                    'FROM Quote__c WHERE Id IN: qIds'));
    }

    /**
     * 関連工種を取得
     */
    private Map<Id, ConstructionZone__c> getDeviceLargeCategoryRelatedRecords(Set<Id> conIds){
        
        return new Map<Id, ConstructionZone__c>((List<ConstructionZone__c>)Database.query('SELECT Id, (SELECT FIELDS(STANDARD) ' + util.getAllCustomFields('Device_LargeCategory__c') + ' FROM Device_LargeCategorys__r)' + 
                                                                    'FROM ConstructionZone__c WHERE Id IN: conIds'));
    }

    /**
     * 関連種別を取得
     */
    private Map<Id, Device_LargeCategory__c> getDeviceMiddleCategoryRelatedRecords(Set<Id> dlcIds){
        
        return new Map<Id, Device_LargeCategory__c>((List<Device_LargeCategory__c>)Database.query('SELECT Id, (SELECT FIELDS(STANDARD) ' + util.getAllCustomFields('Device_MiddleCategory__c') + ' FROM Device_MiddleCategorys__r)' + 
                                                                    'FROM Device_LargeCategory__c WHERE Id IN: dlcIds'));
    }

    /**
     * 関連細別を取得
     */
    private Map<Id, Device_MiddleCategory__c> getDeviceSmallCategoryRelatedRecords(Set<Id> dmcIds){
        
        return new Map<Id, Device_MiddleCategory__c>((List<Device_MiddleCategory__c>)Database.query('SELECT Id, (SELECT FIELDS(STANDARD) ' + util.getAllCustomFields('Device_SmallCategory__c') + ' FROM Device_SmallCategorys__r)' + 
                                                                    'FROM Device_MiddleCategory__c WHERE Id IN: dmcIds'));
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

    public void equipManageCostCalculation(List<Quote__c> quoteList){
        Set<Id> quoteIds = new Set<Id>();
        for(Quote__c quote : quoteList){
            if(quote.RecordTypeId == recTypeOfficialDemandId && quote.EquipmentCostExistence__c == 'あり' && quote.SectionExistence__c == 'なし'){
                quoteIds.add(quote.Id);
            }
        }
        if(quoteIds.isEmpty()) return;

        Map<Id,Quote__c> getQuoteMap  = getQuoteChildDevices(quoteIds);
        
        for(Quote__c quote : quoteList){
            if(getQuoteMap.get(quote.Id).Devices__r.isEmpty()){
                //機器単体費
                quote.MachineUnitAmount__c = null;
                //機器管理費
                quote.EquipManageCost__c = null;
                //機器管理費率
                quote.EquipManageCostRate__c = null;
                //システムインテグレーション費合計
                quote.SystemIntegrationFee__c = null;
            }else{
                setQuoteValues(quote,getQuoteMap.get(quote.Id).Devices__r);
            }
        }
    }
    
    private void setQuoteValues(Quote__c quote, List<Device__c> deviceList){
        //支給品・移設品・製作のみ有りフラグ
        Boolean suppliesFlag = false;
        //見積対象外有りフラグ
        Boolean noTargetFlag = false;
        //機器単体費計算
        Double sumPriceTarget = getSumPriceTarget(deviceList);
        System.debug('sumPriceTarget =' + sumPriceTarget);
        //機器管理費率計算
        Decimal equipManageCostRate = getEquipManageCostRate(sumPriceTarget);
        System.debug('補正前equipManageCostRate =' + equipManageCostRate);
        //システムインテグレーション費合計
        Decimal systemIntegrationTotalPrice = 0;

        for(Device__c d : deviceList){
            if(d.EquipManageCostTarget__c == true && d.MajorClassification__c != 'システムインテグレーション費' && (d.QuoteTarget__c == '支給品' || d.QuoteTarget__c == '移設品' || d.QuoteTarget__c == '見積対象(製作のみ)' || d.QuoteTarget__c == '見積対象外(製作のみ)')){
                suppliesFlag = true;
            }else if(d.EquipManageCostTarget__c == true && d.MajorClassification__c != 'システムインテグレーション費' && d.QuoteTarget__c == '見積対象外'){
                noTargetFlag = true;
            }

            if(d.MajorClassification__c == 'システムインテグレーション費'){
                systemIntegrationTotalPrice += d.ClientAnswerAmountTotal__c;
            }
        }

        //機器単体費設定
        quote.MachineUnitAmount__c = sumPriceTarget;
        //システムインテグレーション費合計設定
        quote.SystemIntegrationFee__c = systemIntegrationTotalPrice;
        
        //機器管理費設定
        if(suppliesFlag == true && sumPriceTarget > 0){
            equipManageCostRate = calculateEquipManageCostInSupplies(quote,deviceList,sumPriceTarget,equipManageCostRate);
        }else if(noTargetFlag == true && sumPriceTarget > 0){
            quote.EquipManageCost__c = calculateEquipManageCostInNoTarget(quote,deviceList,equipManageCostRate);
        }else{
            quote.EquipManageCost__c = sumPriceTarget * (equipManageCostRate / 100);
        }
        System.debug('補正後equipManageCostRate =' + equipManageCostRate);
        
        //機器管理費率設定
        quote.EquipManageCostRate__c = equipManageCostRate;
    }

    /**
     * 機器単体費を取得
     */
    private Double getSumPriceTarget(List<Device__c> deviceList){
        Double sumPriceTarget = 0.0;
        for(Device__c dv : deviceList){
            if(dv.MajorClassification__c != 'システムインテグレーション費' && dv.EquipManageCostTarget__c == true){
                sumPriceTarget += dv.ClientAnswerAmountTotal__c;
            }
        }

        return sumPriceTarget;
    }

    /**
     * 機器管理費率を取得
     */
    private Decimal getEquipManageCostRate(Double sumPriceTarget){
        Decimal equipManageCostRate;
        //PRICE_A = 14,000千円  ,  PRICE_B = 200,000千円
        if(sumPriceTarget <= PRICE_A){
            //機器単体費が 14,000千円以下
            equipManageCostRate = 18.22;            
        }else if(sumPriceTarget>PRICE_A && sumPriceTarget<=PRICE_B){
            //EXPONENT = -0.4711
            equipManageCostRate = 42380.2 * (Math.pow(sumPriceTarget, EXPONENT));
            //小数3位以下を四捨五入
            equipManageCostRate = equipManageCostRate.setScale(2,RoundingMode.HALF_UP);
        }else{
            //機器単体費が200,000千円を越える
            equipManageCostRate = 5.21;
        }

        return equipManageCostRate;
    }

    /**
     * 支給品・移設品・製作のみを含む機器管理費計算
     * @param quote 見積レコード
     * @param deviceList 見積に紐づく見積項目のリスト
     * @param sumPriceTarget 支給品や移設品、製作のみの価格も含めた金額（見積対象外も含む）
     * @param equipManageCostRate 補正前機器管理費率
     * 
     */
    private Decimal calculateEquipManageCostInSupplies(Quote__c quote, List<Device__c> deviceList, Decimal sumPriceTarget, Decimal equipManageCostRate){
        //支給品や移設品、製作のみ(見積対象外も含む)の金額
        Decimal suppliesPrice = 0.0;
        //支給品や移設品、製作のみ以外の機器単体費（見積対象外も含む）→見積対象と見積対象外の金額
        Decimal sumPriceTargetExceptSupplies = 0.0;
        //支給品や移設品の価格は含めない金額（見積対象外含まない）→見積対象と見積対象(製作のみ)の金額
        Decimal sumPriceTargetExceptSuppliesInProduction = 0.0;
        //機器管理費率補正係数
        Decimal equipManageCostRateCoefficient;
        //補正後機器管理費率
        Decimal correctionEquipManageCostRate;
        for(Device__c dv : deviceList){
            if(dv.MajorClassification__c != 'システムインテグレーション費' && dv.EquipManageCostTarget__c == true){
                if(dv.QuoteTarget__c == '支給品' || dv.QuoteTarget__c == '移設品' || dv.QuoteTarget__c == '見積対象(製作のみ)' || dv.QuoteTarget__c == '見積対象外(製作のみ)'){
                    suppliesPrice += dv.ClientAnswerAmountTotal__c;
                    if(dv.QuoteTarget__c == '見積対象(製作のみ)'){
                        sumPriceTargetExceptSuppliesInProduction += dv.ClientAnswerAmountTotal__c;
                    }
                }else if(dv.QuoteTarget__c == '見積対象' || dv.QuoteTarget__c == '見積対象外'){
                    sumPriceTargetExceptSupplies += dv.ClientAnswerAmountTotal__c;
                    if(dv.QuoteTarget__c == '見積対象'){
                        sumPriceTargetExceptSuppliesInProduction += dv.ClientAnswerAmountTotal__c;
                    }
                }
            }
        }
        //機器管理費率補正係数算出
        equipManageCostRateCoefficient = (sumPriceTargetExceptSupplies + (suppliesPrice * 0.5)) / sumPriceTarget;
        //小数3位以下を四捨五入
        equipManageCostRateCoefficient = equipManageCostRateCoefficient.setScale(2,RoundingMode.HALF_UP);

        //補正後機器管理費率算出
        correctionEquipManageCostRate = equipManageCostRate * equipManageCostRateCoefficient;
        //小数3位以下を四捨五入
        correctionEquipManageCostRate = correctionEquipManageCostRate.setScale(2,RoundingMode.HALF_UP);

        //機器管理費算出
        quote.EquipManageCost__c = sumPriceTargetExceptSuppliesInProduction * (correctionEquipManageCostRate / 100);

        //各種工事区分の値を設定
        quote.suppliesMachineUnitAmount__c = suppliesPrice;
        quote.removeSuppliesMachineUnitAmount__c = sumPriceTargetExceptSupplies;
        quote.Target_MachineUnitAmount__c = sumPriceTargetExceptSuppliesInProduction;
        quote.temEquipManageCostRate__c = equipManageCostRate;
        quote.equipManageCostRateCoefficient__c = equipManageCostRateCoefficient;

        return correctionEquipManageCostRate;
    }

    /**
     * 見積対象外を含む機器管理費計算
     * @param quote 見積レコード
     * @param deviceList 見積に紐づく見積項目のリスト
     * @param equipManageCostRate 機器管理費率
     * 
     */
    private Double calculateEquipManageCostInNoTarget(Quote__c quote, List<Device__c> deviceList, Decimal equipManageCostRate){
        //見積対象の機器単体費
        Decimal quoteTargetPrice = 0.0;
        //再計算後の機器管理費
        Decimal correctionEquipManageCost = 0.0;
        
        for(Device__c dv : deviceList){
            if(dv.QuoteTarget__c == '見積対象' && dv.MajorClassification__c != 'システムインテグレーション費' && dv.EquipManageCostTarget__c == true){
                quoteTargetPrice += dv.ClientAnswerAmountTotal__c;
            }
        }
        
        //機器管理費再計算
        correctionEquipManageCost = quoteTargetPrice * (equipManageCostRate / 100);
        //各種工事区分の値を設定
        quote.Target_MachineUnitAmount__c = quoteTargetPrice;

        return correctionEquipManageCost;
    }

    private Map<Id,Quote__c> getQuoteChildDevices(Set<id> quoteIds){
        Map<Id, Quote__c> getQuoteMap = new Map<Id, Quote__c>([SELECT Id, (SELECT Id, QuoteTarget__c, ClientAnswerAmountTotal__c, MajorClassification__c, EquipManageCostTarget__c FROM Devices__r)
                FROM Quote__c
                WHERE Id IN : quoteIds AND RecordTypeId =: recTypeOfficialDemandId]);
        return getQuoteMap;
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