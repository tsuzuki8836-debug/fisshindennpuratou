public with sharing class DeviceCloneRedirect {
    public String quoteId {set; get;}
    public DeviceCloneRedirect(){
        this.quoteId = ApexPages.currentPage().getParameters().get('quoteId');
    }

    public PageReference redirect(){
        String prevURL = URL.getOrgDomainURL().toExternalForm() + '/' + quoteId;
        PageReference pageref = new PageReference(prevURL);
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();

        while ((finishTime - startTime) < 5000) {
            finishTime = Datetime.now().getTime();
        }
        pageref.setRedirect(true);
        return pageref;
    }
}