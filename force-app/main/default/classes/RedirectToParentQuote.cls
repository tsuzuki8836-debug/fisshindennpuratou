global without sharing class RedirectToParentQuote {

    global class Parameter{
        @InvocableVariable
        global Id input_ParentRecordId;
    }

    @InvocableMethod(label='redirectToRecordPage')
    global static void RedirectTo(List<Parameter> objInputParameter){
        Id parentId;
        String parentSObject;
        for(Parameter param:objInputParameter){
            parentId = param.input_ParentRecordId;
        }
        if(parentId != null){
            String redirectUrl = URL.getOrgDomainURL().toExternalForm() + '/' + parentId;
            RedirectoToRecordPage(redirectUrl);
            System.debug('実行されました');
        } else {
            System.debug('実行されませんでした');
        }
    }

    @AuraEnabled
    global static void RedirectoToRecordPage(String url){
        PageReference pageRef = new PageReference(url);
        System.Aura.redirect(pageRef);
    }

}