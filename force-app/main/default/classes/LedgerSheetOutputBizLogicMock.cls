@isTest
global class LedgerSheetOutputBizLogicMock implements HttpCalloutMock{

    private String testCase = '';
    private String urlGetToken = '';
	private String urlPrintData = '';

    public LedgerSheetOutputBizLogicMock(String testCase, String urlGetToken, String urlPrintData) {
        this.testCase = testCase;
        this.urlGetToken = urlGetToken;
		this.urlPrintData = urlPrintData;
    }

    global HttpResponse respond(HttpRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);

        // LedgerSheetOutputBizLogic.getSvfToken()
        if(this.testCase == 'SuccessCase') {
            if(req.getEndpoint() == this.urlGetToken) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"success","token":"test"}');
                res.setStatusCode(200);
            } else if(req.getEndpoint() == this.urlPrintData) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"success"}');
                res.setHeader('Location', 'testLocation');
                res.setStatusCode(202);
            }
        } else if(this.testCase == 'ErrorCase1'){
            if(req.getEndpoint() == this.urlGetToken) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"error","token":"test"}');
                res.setStatusCode(500);
            } else if(req.getEndpoint() == this.urlPrintData) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"error"}');
                res.setHeader('Location', 'testLocation');
                res.setStatusCode(500);
            }
        } else if(this.testCase == 'ErrorCase2'){
            if(req.getEndpoint() == this.urlGetToken) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"success","token":"test"}');
                res.setStatusCode(200);
            } else if(req.getEndpoint() == this.urlPrintData) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"error"}');
                res.setHeader('Location', 'testLocation');
                res.setStatusCode(500);
            }
        } else if(this.testCase == 'ErrorCase3'){
            if(req.getEndpoint() == this.urlGetToken) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"success","token":"test"}');
                res.setStatusCode(200);
            } else if(req.getEndpoint() == this.urlPrintData) {
                res = new HttpResponse();
            }
        } else if(this.testCase == 'ErrorCase4'){
            if(req.getEndpoint() == this.urlGetToken) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"success","token":"test"}');
                res.setStatusCode(200);
            } else if(req.getEndpoint() == this.urlPrintData) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"error"}');
                res.setHeader('Location', 'testLocation.com');
                res.setStatusCode(202);
            } else if(req.getEndpoint() == 'testLocation.com') {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"error"}');
                res.setHeader('Location', 'testLocation.com');
                res.setStatusCode(303);
            }
        } else if(this.testCase == 'ErrorCase5'){
            if(req.getEndpoint() == this.urlGetToken) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"success","token":"test"}');
                res.setStatusCode(200);
            } else if(req.getEndpoint() == this.urlPrintData) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"error"}');
                res.setHeader('Location', 'testLocation.com');
                res.setStatusCode(202);
            } else if(req.getEndpoint() == 'testLocation.com') {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"error"}');
                res.setHeader('Location', 'testLocation.com');
                res.setStatusCode(500);
            }
        }
        return res; 
    }
}