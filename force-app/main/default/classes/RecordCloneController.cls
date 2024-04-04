public class RecordCloneController {
    
    @AuraEnabled
    public static sObjectSummary getSObjectSummary(Id recordId, String childRelationshipNames, String excludedFieldNames) {
        return sObjectSummary.getByRecordId(recordId, childRelationshipNames, excludedFieldNames);
    }
    
    @AuraEnabled
    public static String getNameFieldValue(Id recordId, String objectName, String nameField) {
        sObject sobj = Database.query('SELECT ' + nameField + ' FROM ' + objectName + ' WHERE Id = \'' + recordId + '\'');
        return (String) sobj.get(nameField);
    }
    
    @AuraEnabled
    public static sObject execClone(Id recordId, String newParentRecordName, String childRelationshipNames, String excludedFieldNames) {
        
        // クローン対象のsObjectの概要を取得
        sObjectSummary sObjSummary = sObjectSummary.getByRecordId(recordId, childRelationshipNames, excludedFieldNames);
        
        // 新規レコード名がない場合はエラーを返す。
        if(sObjSummary.isNamable && String.isBlank(newParentRecordName)) {
            return null;
        }
        
        // クローン元になるレコードを取得
        sObject originalRecord = RecordCloneHandler.getOriginalRecord(recordId, sObjSummary);
        
        // クローンを実行
        sObject clonedRecord = RecordCloneHandler.cloneRecord(originalRecord, sObjSummary, newParentRecordName);
        
        return clonedRecord;
    }
    
    // 20200117 chiba 処理追加 start
    @AuraEnabled
    public static sObject execCloneAfter(Id recordId, String childRelationshipNames) {
        
        //System.debug('◆◆◆◆recordId'+recordId);        
        // クローンしたのsObjectの概要を取得
        sObjectSummary sObjSummary = sObjectSummary.getByRecordId(recordId, childRelationshipNames);
        
        // クローンしたクリア対象レコードを取得
        sObject getClonedRecord = RecordCloneHandler.getOriginalRecord(recordId, sObjSummary);
        
        // クリアを実行
        sObject clearRecord = RecordCloneHandler.clearRecord(getClonedRecord, sObjSummary);
        
        return clearRecord;
    }
    // 20200117 chiba 処理追加 end
    
}