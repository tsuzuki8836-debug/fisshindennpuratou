public class RecordCloneHandler {

    // TODO: error handling, try catch.
    public static sObject getOriginalRecord(Id recordId, sObjectSummary sObjSummary) {

        // concatenate clonable field names of child sObjects to build SOQL string
        String childrenSelect = '';
        if(sObjSummary.children != null && sObjSummary.children.size() > 0) {
            for (String childRelName : sObjSummary.children.keySet()){
                sObjectSummary child = sObjSummary.children.get(childRelName);
                List<String> childFields = child.filterClonableFields();
                if(child.isClonable && childFields.size() > 0) {
                    childrenSelect += ', ( SELECT Id, ' + String.join(childFields, ',') + ' FROM ' + childRelName + ' )';
                }
            }
        }
        // Build query string
        String q = 'SELECT Id, ' + String.join(sObjSummary.filterClonableFields(), ',') + childrenSelect + ' FROM ' + sObjSummary.apiName + ' WHERE Id = \'' + recordId + '\'';
        return Database.query(q);
    }

    public static sObject cloneRecord(sObject cloned, sObjectSummary sObjectSummary, String newRecordName) {

        // TODO: try catch error handling

        // remove original record ID, then insert.
        cloned.Id = null;
        if(sObjectSummary.isNamable) {
            cloned.put(sObjectSummary.nameField, newRecordName);
        }
        if(('Opportunity').equals(String.valueOf(cloned.getSObjectType()))){
            cloned.put('StageName', '基本計画');
            cloned.put('EstimatedIssuedDate_01__c', null);
            // cloned.put('CloseDate', Date.today().AddYears(1)); //コピー時に空欄にするよう仕様変更（売上予定日と合わせる）
        }
        insert cloned;

        if(sObjectSummary.children != null && sObjectSummary.children.keySet().size() > 0) {

            // append to child records' name fields
            String todayStr = Datetime.now().format('yyyy/MM/dd');

            // remove child record IDs, assign then cloned parent record Id to ref field
            for(String childRelName : sObjectSummary.children.keySet()) {
                sObjectSummary childSummary = sObjectSummary.children.get(childRelName);

                if(!childSummary.isClonable) continue;
                sObject[] children;
                try {
                    children = cloned.getSObjects(childRelName);
                } catch(System.SObjectException e) {
                    // TODO : handle error with proper exception class.
                    continue;
                }
                if(children == null) continue;

                // On creating an opportunity record, system automatically creates an OpportunityContactRole record.
                // Delete the created record as of now.
                if(sObjectSummary.apiName == 'Opportunity' && childRelName == 'OpportunityContactRoles') {
                    OpportunityContactRole[] ocrs = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = :cloned.Id];
                    delete ocrs;
                }

                for(Integer i = 0; i < children.size(); i++) {
                    children[i].put('Id', null);
                    if(childSummary.isNamable) {
                        String currentNameValue = (String) children[i].get(childSummary.nameField);
                        //20241212 oh 見積・応札・手数料伺いコピーの分岐判断を追加する
                        if(('QuoteBiddingInquiry__c').equals(String.valueOf(cloned.getSObjectType()))){
                            children[i].put(childSummary.nameField, currentNameValue);
                        } else {
                            children[i].put(childSummary.nameField, 'Cloned - ' + todayStr + ' : ' + currentNameValue);
                        }
                    }
                    children[i].put(childSummary.parentRelationshipField, cloned.Id);

                    // 20200117 chiba 処理追加 start
                    if(('ProductSpecification__c').equals(String.valueOf(children.getSObjectType()))){
                        children[i].put('Factorys__c', null);
                    }
                    // 20200117 chiba 処理追加 end
                }
                insert children;
            }
        }

        // TODO: 作成したオブジェクトの名前とレコード件数を返す。
        return cloned;
    }

    // 20200117 chiba 処理追加 start
    public static sObject clearRecord(sObject cloned, sObjectSummary sObjectSummary) {

        // コピーした子オブジェクトが存在するかを確認し、存在する場合、クリア処理を実施する。
        if(sObjectSummary.children != null && sObjectSummary.children.keySet().size() > 0) {

            //カスタムメタデータを取得しておく
            RecordCloneSetting__mdt[] RecordCloneSetting = [SELECT MasterLabel , value__c FROM RecordCloneSetting__mdt];

            for(String childRelName : sObjectSummary.children.keySet()) {
                sObjectSummary childSummary = sObjectSummary.children.get(childRelName);

                if(!childSummary.isClonable) continue;
                sObject[] children;
                try {
                    children = cloned.getSObjects(childRelName);
                } catch(System.SObjectException e) {
                    // TODO : handle error with proper exception class.
                    continue;
                }
                if(children == null) continue;

                //カスタム項目の型を取得する為、SObjectFieldを取得しておく
                DescribeSObjectResult sObjectDescribe = children.getSObjectType().getDescribe();
                Map<String, SObjectField> fields = sObjectDescribe.fields.getMap();

                for(sObject child : children) {
                    if(RecordCloneSetting.isEmpty())continue;
                    //クリア処理
                    for (RecordCloneSetting__mdt rcs : RecordCloneSetting) {

                        if(String.valueOf(children.getSObjectType()).equals(rcs.MasterLabel)){
                            if(String.isBlank(rcs.value__c))continue;
                            String[] items = rcs.value__c.split(',');

                            for(String item:items){
                                if(String.isBlank(item))continue;
                                DescribeFieldResult field = fields.get(item).getDescribe();
                                Schema.DisplayType fldType = field.getType();
                                //チェック型は、nullセットでエラーとなる為、「false」を設定なしとする。
                                if(('BOOLEAN').equals(String.valueOf(fldType))){
                                    child.put(item, false);
                                }else{
                                    child.put(item, null);
                                }
                            }

                            //機器仕様の場合は、場所別の参照関係を指定する。
                            if(('ProductSpecification__c').equals(String.valueOf(children.getSObjectType()))){
                                //移行時にエラーとなるためTry-Catch追加
                                try {
                                    String FactoryRelationNo = String.valueOf(child.get('FactoryRelationNo__c'));
                                    if(String.isBlank(FactoryRelationNo))continue;
                                    ID FactoryId = null;
                                    sObject[] children_search;
                                    for(String childRelName_search : sObjectSummary.children.keySet()) {
                                        try {
                                            children_search = cloned.getSObjects(childRelName_search);
                                        } catch(System.SObjectException e) {
                                            // TODO : handle error with proper exception class.
                                            continue;
                                        }
                                        if(children_search == null)continue;
                                        for(sObject child_search : children_search) {
                                            if(('Factory__c').equals(String.valueOf(children_search.getSObjectType())) && FactoryRelationNo.equals(String.valueOf(child_search.get('CopyBaseNo_txt__c')))){
                                                FactoryId = child_search.Id;
                                            }
                                        }
                                    }
                                    child.put('Factorys__c', FactoryId);
                                //移行時にエラーとなるためTry-Catch追加
                                } catch(System.SObjectException e) {
                                // TODO : handle error with proper exception class.
                                    continue;
                                }
                            }
                        }
                    }
                }
                System.debug('◆◆◆◆upsert対象：'+children);
                upsert children;
            }
        }

        // 処理結果のフラグを返す。
        return cloned;
    }
    // 20200117 chiba 処理追加 end
}