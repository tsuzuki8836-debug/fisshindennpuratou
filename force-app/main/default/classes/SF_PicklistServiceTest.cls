@isTest
public class SF_PicklistServiceTest {
    @isTest static void getDependencyPicklistOptionsTest() {
        Schema.PicklistEntry[] controlEntries = Account.Rating.getDescribe().getPicklistValues();
        Map<String, List<PicklistOption>> dependenceMap = SF_PicklistService.getDependencyPicklistOptions(Account.Rating.getDescribe(), controlEntries);
        Boolean isHaveDependecyOptions = false;
        for (String controlValue : dependenceMap.keySet()) {
            List<PicklistOption> dependenceOptions = dependenceMap.get(controlValue);
            if(!dependenceOptions.isEmpty()) {
                isHaveDependecyOptions = true;
            }
        }
        System.assert(isHaveDependecyOptions);
    }
}