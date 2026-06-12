@isTest
public class RedirectToParentQuoteTest {

    @isTest
    static void success(){
        Date dt = Date.today();
        Opportunity opp = new Opportunity(
            Name = 'TestOpportunity1'
            ,StageName = '基本計画'
            ,ConstructionDistinction__c = '更新（自社既設）'
            ,EstablishedCompany__c = '三菱'
            ,CloseDate = dt
        );
        insert opp;
        Quote__c qu = new Quote__c(
            QuoteNumber__c = 'Test01'
            ,Opportunity__c = opp.Id
            ,Subject__c = 'Test用'
            ,PowerFrequency__c = '50Hz'
        );
        insert qu;
        List<Device__c> deList = new List<Device__c>();
        for(Integer i = 0; i < 10; i++){
            Device__c de = new Device__c(
                Name = 'Test' + i
                ,QuoteSpecificationNumber__c = '0' + i
                ,Quote__c = qu.Id
                ,MajorClassification__c = '特高'
            );
            deList.add(de);
        }
        insert deList;
        List<RedirectToParentQuote.Parameter> rpList = new List<RedirectToParentQuote.Parameter>();
        RedirectToParentQuote.Parameter rp = new RedirectToParentQuote.Parameter();
        rp.input_ParentRecordId = deList[0].Quote__c;
        rpList.add(rp);

        Test.startTest();
        RedirectToParentQuote.RedirectTo(rpList);
        Test.stopTest();
    }

    @isTest
    static void failed(){
        Date dt = Date.today();
        Opportunity opp = new Opportunity(
            Name = 'TestOpportunity1'
            ,StageName = '基本計画'
            ,ConstructionDistinction__c = '更新（自社既設）'
            ,EstablishedCompany__c = '三菱'
            ,CloseDate = dt
        );
        insert opp;
        Quote__c qu = new Quote__c(
            QuoteNumber__c = 'Test01'
            ,Opportunity__c = opp.Id
            ,Subject__c = 'Test用'
            ,PowerFrequency__c = '50Hz'
        );
        insert qu;
        List<Device__c> deList = new List<Device__c>();
        for(Integer i = 0; i < 10; i++){
            Device__c de = new Device__c(
                Name = 'Test' + i
                ,QuoteSpecificationNumber__c = '0' + i
                ,Quote__c = qu.Id
                ,MajorClassification__c = '特高'
            );
            deList.add(de);
        }
        insert deList;
        List<RedirectToParentQuote.Parameter> rpList = new List<RedirectToParentQuote.Parameter>();
        RedirectToParentQuote.Parameter rp = new RedirectToParentQuote.Parameter();
        rp.input_ParentRecordId = null;
        rpList.add(rp);

        Test.startTest();
        RedirectToParentQuote.RedirectTo(rpList);
        Test.stopTest();
    }
}