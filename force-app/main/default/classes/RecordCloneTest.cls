@isTest
private class RecordCloneTest {
    
    @IsTest
    private static void controllerTest() {
        List<Case> cList = new List<Case>();

        // insert a record
        Case c = new Case(
            Subject = 'Test Case'
        );
        insert c;
        
        Case c2 = new Case(
            Subject = 'Test Child Case',
            ParentId = c.Id
        );
        cList.add(c2);
        
        Case c3 = new Case(
            Subject = 'Test Child Case',
            ParentId = c.Id
        );
        cList.add(c3);

        insert cList;
        
        Case cc = [SELECT Id, (SELECT Id FROM Cases) FROM Case WHERE Id = :c.Id];
        System.debug(cc.Cases.size());
        
        //chiba edit start
        Account a = new Account(
            Name = 'Test Account',
            Phone = '09011111111'
        );
        insert a;

        Property__c prop = new Property__c(
            Name = 'Test Prop'
        );
        insert prop;

        List<Opportunity> oList = new List<Opportunity>();
                
        Opportunity o = new Opportunity(
            Name = 'Test Opp',
            StageName = 'aaa',
            CloseDate = Date.today(),
            BU__c = '施設',
            SBU__c = '受変電',
            Plant__c = '特高（66/77kV）',
            Property__c = prop.Id,
            ScheduledCollectionDate__c = Date.today().addMonths(1),
            ConstructionDistinction__c = '新設',
            Website__c = 00, 
            Handling__c = ' 直扱', 
            OrderExpectation__c = '1', 
            DemanDepartment__c = '金融', 
            DemandOf__c = '官需', 
            InformationFrom__c = '施主',
            Type__c = '新築'
        );
        oList.add(o);
        
        Opportunity o2 = new Opportunity(
            Name = 'Test Opp2',
            StageName = 'aaa2',
            CloseDate = Date.today(),
            BU__c = '施設',
            SBU__c = '受変電',
            Plant__c = '特高（66/77kV）',
            Property__c = prop.Id,
            ScheduledCollectionDate__c = Date.today().addMonths(1),
            ConstructionDistinction__c = '新設',
            Website__c = 00, 
            Handling__c = ' 直扱', 
            OrderExpectation__c = '1', 
            DemanDepartment__c = '金融', 
            DemandOf__c = '官需', 
            InformationFrom__c = '施主',
            Type__c = '新築'
        );
        oList.add(o2);
        
        Opportunity o3 = new Opportunity(
            Name = 'Test Opp3',
            StageName = 'aaa3',
            CloseDate = Date.today(),
            BU__c = '施設',
            SBU__c = '受変電',
            Plant__c = '特高（66/77kV）',
            Property__c = prop.Id,
            ScheduledCollectionDate__c = Date.today().addMonths(1),
            ConstructionDistinction__c = '新設',
            Website__c = 00, 
            Handling__c = ' 直扱', 
            OrderExpectation__c = '1', 
            DemanDepartment__c = '金融', 
            DemandOf__c = '官需', 
            InformationFrom__c = '施主',
            Type__c = '新築'
        );
        oList.add(o3);

        insert oList;
        
        List<Factory__c> factoryList = new List<Factory__c>();
        //場所別
        Factory__c Factory = new Factory__c(
            Opp1__c = o.Id,
            CommonRatio1__c= '21% ： 製作所',
            BU__c='施設',
            CarryingDay__c=Date.today()+10,
            SR_CP__c=10000, 
            SRWC__c=10000
        );
        factoryList.add(Factory);

        //場所別
        Factory__c Factory2 = new Factory__c(
            Opp1__c = o3.Id,
            CommonRatio1__c= '21% ： 製作所',
            BU__c='施設',
            CarryingDay__c=Date.today()+10,
            SR_CP__c=10000, 
            SRWC__c=10000
        );
        factoryList.add(Factory2);

        insert factoryList;
        
        List<ProductSpecification__c> productList = new List<ProductSpecification__c>();
        //機器仕様
        ProductSpecification__c ProductSpecificatio = new ProductSpecification__c(
            Opp5__c = o.Id,
            Factorys__c = Factory.Id
        );
        productList.add(ProductSpecificatio);
        
        //機器仕様
        ProductSpecification__c ProductSpecificatio2 = new ProductSpecification__c(
            Opp5__c = o.Id,
            Factorys__c = null
        );
        productList.add(ProductSpecificatio2);

        //機器仕様
        ProductSpecification__c ProductSpecificatio3 = new ProductSpecification__c(
            Opp5__c = o3.Id,
            Factorys__c = Factory.Id
        );
        productList.add(ProductSpecificatio3);

        insert productList;
        
        //工事情報
        ConstructionInfo__c ConstructionInfo = new ConstructionInfo__c(
            Opp6__c = o.Id,
            HAICHI_JUMBI__c = '不要'
        );
        insert ConstructionInfo;
        
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact(
            FirstName = 'hello',
            LastName = 'hoho',
            Phone = '09011111111'
        );
        conList.add(con);
        
        Contact con2 = new Contact(
            AccountId = a.Id,
            FirstName = 'tarou',
            LastName = 'sato',
            Phone = '09012345678'
        );
        conList.add(con2);

        insert conList;
        //chiba edit end
        
        OpportunityContactRole ocr = new OpportunityContactRole(
            ContactId = con.Id,
            OpportunityId = o.Id,
            IsPrimary = true, 
            Role = 'TestRole'
        );
        insert ocr;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='RPAロボット'];
        User u = new User();
        u.LastName = 'test';
        u.Alias = 'test';
        u.Email = 'testorg' + '@mitsubishielectric.co.jp.melgit-crm01';
        u.UserName = u.Email;
        u.EmailEncodingKey = 'ISO-2022-JP';
        u.TimeZoneSidKey = 'Asia/Tokyo';
        u.LocaleSidKey = 'ja_JP';
        u.LanguageLocaleKey = 'ja';
        u.profileId = p.Id;
        insert u;
        
        System.runAs(u){

            // Id recordId, String childRelationshipNames, String excludedFieldNames
            // without relationship, without excludedFields
            RecordCloneController.getSObjectSummary(c.Id, '', '');
            RecordCloneController.getSObjectSummary(c.Id, null, null);
            // with relationship, without excludedFields
            RecordCloneController.getSObjectSummary(c.Id, 'CaseArticles', '');
            RecordCloneController.getSObjectSummary(c.Id, 'CaseArticles, CaseContactRoles, Cases', null);
            // without relationship, with excludedFields
            RecordCloneController.getSObjectSummary(c.Id, '', 'AccountId');
            RecordCloneController.getSObjectSummary(c.Id, null, 'AccountId, SourceId, SuppliedCompany ');
            // with relationship, with excludedFields
            RecordCloneController.getSObjectSummary(c.Id, 'CaseArticles', 'AccountId');
            RecordCloneController.getSObjectSummary(c.Id, 'CaseArticles, CaseContactRoles, Cases ', 'AccountId, SourceId, SuppliedCompany ');
                    
            // Id recordId, String objectName, String nameField
            RecordCloneController.getNameFieldValue(a.Id, 'Account', 'Name');
            
            // Id recordId, String newParentRecordName, String childRelationshipNames, String excludedFieldNames
            // without relationship, without excludedFields
            RecordCloneController.execClone(c.Id, '', '', '');
            RecordCloneController.execClone(c.Id, 'hehe', null, null);
            // with relationship, without excludedFields
            RecordCloneController.execClone(c.Id, '', 'CaseArticles', '');
            RecordCloneController.execClone(c.Id, 'hehe', 'CaseArticles, CaseContactRoles', null);
            // without relationship, with excludedFields
            RecordCloneController.execClone(a.Id, '', '', 'AccountId');
            RecordCloneController.execClone(c.Id, 'hehe', null, 'AccountId, SourceId, SuppliedCompany ');
            // with relationship, with excludedFields
            RecordCloneController.execClone(c.Id, '', 'CaseArticles, Cases', 'AccountId');
            RecordCloneController.execClone(a.Id, 'hehe', 'CaseArticles, CaseContactRoles,  ', 'AccountId, SourceId, SuppliedCompany ');
            //RecordCloneController.execClone(o.Id, 'aaaa', 'OpportunityContactRoles', '');
            
            //chiba edit start
            RecordCloneController.execClone(o.Id, '案件テスト', 'Opps1__r,ProductSpecifications__r,ConstructionInfo__r', 'OpportunityNumber__c,SellingNumber__c,CloseDate,ScheduledSalesDate__c,Handling__c,DemandOf__c,DemanDepartment__c,InformationFrom__c,InformationFromOther__c,OrderExpectation__c,Probability1__c,Margin__c,GrossProfit__c,ScheduledCollectionDate__c,Website__c,LostType__c,Competitor__c,LostReason__c,DeleteReason__c,LostReason_Other__c,DeleteReason_Other__c,SharePointURL__c');
            RecordCloneController.execCloneAfter(o.Id, 'Opps1__r,ProductSpecifications__r,ConstructionInfo__r');
            RecordCloneController.execClone(a.Id, 'Account', 'Contacts', '');
            
            //紐づくオブジェクトなし案件
            RecordCloneController.execClone(o2.Id, '案件テスト２', 'Opps1__r,ProductSpecifications__r,ConstructionInfo__r', 'OpportunityNumber__c,SellingNumber__c,CloseDate,ScheduledSalesDate__c,Handling__c,DemandOf__c,DemanDepartment__c,InformationFrom__c,InformationFromOther__c,OrderExpectation__c,Probability1__c,Margin__c,GrossProfit__c,ScheduledCollectionDate__c,Website__c,LostType__c,Competitor__c,LostReason__c,DeleteReason__c,LostReason_Other__c,DeleteReason_Other__c,SharePointURL__c');
            RecordCloneController.execCloneAfter(o2.Id, 'Opps1__r,ProductSpecifications__r,ConstructionInfo__r');
    
            //紐づく工事情報なし案件
            //RecordCloneController.execClone(o3.Id, '案件テスト３', 'Opps1__r,ProductSpecifications__r,ConstructionInfo__r', 'OpportunityNumber__c,SellingNumber__c,CloseDate,ScheduledSalesDate__c,Handling__c,DemandOf__c,DemanDepartment__c,InformationFrom__c,InformationFromOther__c,OrderExpectation__c,Probability1__c,Margin__c,GrossProfit__c,ScheduledCollectionDate__c,Website__c,LostType__c,Competitor__c,LostReason__c,DeleteReason__c,LostReason_Other__c,DeleteReason_Other__c,SharePointURL__c');
            //RecordCloneController.execCloneAfter(o2.Id, 'Opps1__r,ProductSpecifications__r,ConstructionInfo__r');
    
            // Debug
            RecordCloneDebugController.showAllChildRelationships(o.Id, '');
            //chiba edit end
            
            // Debug
            RecordCloneDebugController.showAllChildRelationships(null, 'Account');
        }
    }
}