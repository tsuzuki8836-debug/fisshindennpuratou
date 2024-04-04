public class GetAllFieldsUtil {
    
    // 引数にはカスタム項目を取得したいオブジェクト名を渡す
    public String getAllCustomFields(String objName) {
        String customQuery = '';
        String delimiter = ', ';

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
        
        // ここで指定したオブジェクトの項目定義を取得
        Map<String, sObjectField> fieldsMap = objType.getDescribe().fields.getMap();

        for (String fieldName : fieldsMap.keySet()) {
            // カスタム項目のみクエリになる文字列に追加
            if (fieldName.endsWith('__c')) {
                customQuery += delimiter + fieldName;
            }
        }
        System.debug('query = ' + customQuery);

        return customQuery;
    }
}