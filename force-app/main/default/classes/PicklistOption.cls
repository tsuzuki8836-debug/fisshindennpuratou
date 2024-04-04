public with sharing class PicklistOption {
    @AuraEnabled 
    public String value; 
    @AuraEnabled 
    public String label;
    public PicklistOption(String value, String label){
        this.value=value; this.label=label;
    }
}