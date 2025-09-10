global virtual class RedirectToParentQuote2 {

    @RemoteAction
    global static void RedirectTo(String recordId){
        Device__c d = [SELECT Id, Quote__c from Device__c WHERE Id =:recordId];
        String parentId = d.Quote__c;
        String redirectUrl = URL.getOrgDomainURL().toExternalForm() + '/' + parentId;
        RedirectoToRecordPage(redirectUrl);
    }

    @AuraEnabled
    global static void RedirectoToRecordPage(String url){
        PageReference pageRef = new PageReference(url);
        System.Aura.redirect(pageRef);
    }

}