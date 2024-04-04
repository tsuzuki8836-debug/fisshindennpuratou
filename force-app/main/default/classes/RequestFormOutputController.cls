public with sharing class RequestFormOutputController {
    @AuraEnabled
    public static String requestFormOutput(Id recordId){
        return RequestFormOutputLogic.printSvfForm(recordId);
    }
}