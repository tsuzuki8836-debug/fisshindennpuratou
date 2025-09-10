global without sharing class redirect20240206 {

    global class Parameter{
        @InvocableVariable
        global Id input_ParentRecordId;
    }

    @InvocableMethod(label='redirectToRecordPage')
    global static void RedirectTo(List<Parameter> objInputParameter){
        Id parentId;
        for(Parameter param:objInputParameter){
            parentId = param.input_ParentRecordId;
        }
        String redirectUrl = URL.getOrgDomainURL().toExternalForm() + '/' + parentId;
        redirectoToRecordPage(redirectUrl);
    }

    @AuraEnabled
    global static void redirectoToRecordPage(String url){
        PageReference pageRef = new PageReference(url);
        System.Aura.redirect(pageRef);
    }
}