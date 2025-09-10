public with sharing class DeviceController {
    @AuraEnabled
    public static List<Device__c> getDevice(Id recordId) {
        System.debug(recordId);
        return [
            SELECT Id, Quote__c,Quote__r.PowerFrequency__c,PriceCoefficient__c,
            Quote__r.RecordType.DeveloperName,
            Quote__r.external_file_url__c,
            QuoteSpecificationNumber__c, Name, 
            toLabel(MajorClassification__c), MinorClassification__c, 
            CreditWC__c, CreditQuoteAmount__c, CreditWeight__c, 
            CreditAgencyProvisionUnitPrice__c, Note__c, WcSum__c, PriceSum__c, WeightSum__c, AgencyProvisionPriceSum__c, 
            StandardPriceSum__c, SalesCostSum__c, 
            GeneralAdministrativeExpenses__c, 
            GeneralAdministrativeExpensesCopy__c,
            OwnerBranchOffice__c,
            GeneralAdminExpensesExistence__c, QuantityNumeric__c, Unit__c,
            (select id,Name1__c,WcCoefficient__c,UnitPriceCoefficient__c,ProvisionUnitPrice__c,PricingTableUniqueKey__c from Details__r order by PricingTableUniqueKey__c)
            FROM Device__c
            WHERE Id =: recordId
        ];
    }
}