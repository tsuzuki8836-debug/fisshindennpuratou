public with sharing class DeviceCloneController {
    // 選択されたレコード
    @TestVisible private List<Device__c> selectedDevices;
    // コピーするセット数
    public String copySet{get;set;}
    // 未入力or0入力時のエラーメッセージ
    public String errorMessage{get;set;}
    // エラー時のスタイル適用
    public String errorClass{get;set;}
    // 項目取得Utilクラスをインスタンス化
    GetAllFieldsUtil util = new GetAllFieldsUtil();
    // 戻り先ページID
    public Id quoteId;

    public DeviceCloneController(ApexPages.StandardSetController controller) {
        this.quoteId = ApexPages.currentPage().getParameters().get('id');
        this.copySet = '1';
        this.selectedDevices = controller.getSelected();
        // コピー処理の注意事項を表示
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'システムの制約上、コピー可能な件数には上限があります。'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '上限に達するかはコピー対象の見積項目数と見積項目に登録済みの明細数、及びコピーするセット数によって左右されます。'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'コピー実行時にエラーページが表示された場合、画面更新を行うことでこのページに戻る事が出来ます。'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'エラーが発生した場合、コピー対象数を減らすorコピーするセット数を減らして再度実行を試してください。'));
    }

    public PageReference execute() {
        List<Device__c> copyDevices = new List<Device__c>();
        Set<Id> deviceIds = (new Map<Id, Device__c>(selectedDevices)).keySet();
        // 0入力時or空欄時はエラー
        if(copySet == '0' || copySet == '０' || String.isBlank(copySet) || !pattern.matches('^[0-9０-９]*', copySet)){
            errorMessage = 'コピーするセット数は数字で1以上を入力してください';
            errorClass = 'error';
            // コピー処理の注意事項を表示
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'システムの制約上、コピー可能な件数には上限があります。'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '上限に達するかはコピー対象の見積項目数と見積項目に登録済みの明細数、及びコピーするセット数によって左右されます。'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'コピー実行時にエラーページが表示された場合、画面更新を行うことでこのページに戻る事が出来ます。'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'エラーが発生した場合、コピー対象数を減らすorコピーするセット数を減らして再度実行を試してください。'));
            return null;
        }
        
        for(Device__c d : Database.query('SELECT FIELDS(STANDARD) ' + util.getAllCustomFields('Device__c') + ' FROM Device__c WHERE Id IN: deviceIds')){
            for(Integer i = 1; i <= Integer.valueOf(copySet); i++){
                Device__c deviceClone = d.clone(false,true);
                // 項目番号には「コピー」+コピーセット数を付与（項目番号重複防止のため）
                deviceClone.QuoteSpecificationNumber__c = deviceClone.QuoteSpecificationNumber__c + '_コピー' + i;
                copyDevices.add(deviceClone);
            }
        }
        System.debug(copySet);
        System.debug('copyDevices='+copyDevices);
        try{
            insert copyDevices;
        }catch(Exception e){
            // insert失敗した場合はエラーを返す
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'コピー時にエラーが発生しました。コピー対象の見積項目の入力値が正しいか確認して下さい。'));
            return null;
        }

        
        String prevURL = '/' + quoteId;
        PageReference pageRef = new PageReference(prevURL); // 元のリストビューページを取得
        pageRef.setRedirect(true);

        return pageref;
    }


}