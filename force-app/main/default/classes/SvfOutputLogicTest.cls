@isTest
public with sharing class SvfOutputLogicTest {
    /**
     * @description アクセスートークン取得テスト 200 OK
     */
    @isTest private static void getSvfTokenTest200OK() {
        // preparation
        String result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfTokenHttpCalloutMock(false, 200));

        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.getSvfToken();
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(SvfTokenHttpCalloutMock.TEST_TOKEN, result, 'アクセストークンが不正です。');
        System.assertEquals(false, hasException, '例外が発生しています。');
        System.assertEquals(null, errorMessage, 'エラーメッセージが設定されています。');
    }

    /**
     * @description アクセスートークン取得テスト OK以外の共通メソッド
     * @param responseCode レスポンスとして返却させるコード
     */
    static void getSvfTokenTestNotOK(Integer responseCode) {
        // preparation
        String result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfTokenHttpCalloutMock(false, responseCode));

        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.getSvfToken();
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(null, result, 'アクセストークンが不正です。');
        System.assertEquals(true, hasException, '例外が発生していません。');
        System.assertEquals('認証時HTTPステータス=' + responseCode, errorMessage, 'エラーメッセージが不正です。');
    }

    /**
     * @description アクセスートークン取得テスト 401 Unauthorized
     */
    @isTest static void getSvfTokenTest401Unauthorized() {
        getSvfTokenTestNotOK(401);
    }

    /**
     * @description アクセスートークン取得テスト 403 Forbidden
     */
    @isTest static void getSvfTokenTest403Forbidden() {
        getSvfTokenTestNotOK(403);
    }

    /**
     * @description アクセスートークン取得テスト 429 Too many Requests
     */
    @isTest static void getSvfTokenTest429TooManyRequests() {
        getSvfTokenTestNotOK(429);
    }

    /**
     * @description アクセスートークン取得テスト 503 Service Unavailable
     */
    @isTest static void getSvfTokenTest503ServiceUnavailable() {
        getSvfTokenTestNotOK(503);
    }

    /**
    * @description アクセスートークン取得テスト 例外
    */
    @isTest static void getSvfTokenTestCalloutException() {
        // preparation
        String result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfTokenHttpCalloutMock(true, null));
        
        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.getSvfToken();
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(null, result, 'アクセストークンが不正です。');
        System.assertEquals(true, hasException, '例外が発生していません。');
        System.assertEquals('通信エラー', errorMessage, 'エラーメッセージが不正です。');
    }

    /**
     * JWTベアラトークン作成テスト
     */
    @isTest
    private static void generateTokenTest(){
        // preparation
        String resultHeader;
        String resultClaims;
        String resultSignature;
        String userName = UserInfo.getUserName();

        // execution
        Test.startTest();
        List<String> resultList = SvfOutputLogic.generateToken().split('\\.');
        resultHeader = EncodingUtil.base64Decode(resultList[0]).toString();
        resultClaims = EncodingUtil.base64Decode(resultList[1]).toString();
        resultSignature = resultList[2];
        Test.stopTest();

        // assertion
        System.assertEquals('{"alg":"RS256"}', resultHeader, 'JWTヘッダーが不正です。');
        System.assert(resultClaims.contains('"iss":"' + SvfOutputLogic.CLIENT_ID), 'JWT要求セットのissフィールドが不正です。');
        System.assert(resultClaims.contains('"sub":"' + userName), 'JWT要求セットのsubフィールドが不正です。');
        System.assert(resultClaims.contains('"exp":"' + SvfOutputLogic.UNIXTIME_1HOUR_AFTER_EXECUTE), 'JWT要求セットのexpフィールドが不正です。');
        System.assert(resultClaims.contains('"userName":"　"'), 'JWT要求セットのuserNameフィールドが不正です。');
        System.assertNotEquals(null, resultSignature, '署名が設定されていません。');
    }

    /**
     * Base64 URL エンコードテスト
     */
    @isTest
    private static void encodeUrlsafeBase64Test(){
        // preparation
        String resultUnsafe;
        String resultSafe;
        Blob testBlob = Blob.valueOf('<base64>? ｖ');

        // execution
        Test.startTest();
        resultUnsafe = EncodingUtil.base64Encode(testBlob);
        resultSafe = SvfOutputLogic.encodeUrlsafeBase64(testBlob);
        Test.stopTest();

        // assertion
        System.assertEquals('PGJhc2U2ND4/IO+9lg==', resultUnsafe, 'Base64エンコード結果が不正です。');
        System.assertEquals('PGJhc2U2ND4_IO-9lg', resultSafe, 'Base64 URL エンコード結果が不正です。');
    }

    /**
     * @description 印刷実行テスト 正常実行共通メソッド
     * @param responseCode レスポンスとして返却させるコード
     */
    private static void execSvfPrintTestSuccess(Integer responseCode) {
        // preparation
        String result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfArtifactsHttpCalloutMock(false, responseCode));

        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.execSvfPrint(SvfArtifactsHttpCalloutMock.TEST_TOKEN, 'testfile', 'testdata', 'EXCEL');
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(SvfArtifactsHttpCalloutMock.TEST_LOCATION, result, '印刷データ取得URLが不正です。');
        System.assertEquals(false, hasException, '例外が発生しています。');
        System.assertEquals(null, errorMessage, 'エラーメッセージが設定されています。');
    }

    /**
     * @description 印刷実行テスト 202 Accepted
     */
    @isTest static void execSvfPrintTest202Accepted() {
        execSvfPrintTestSuccess(202);
    }

    /**
     * @description 印刷実行テスト 303 See Other
     */
    @isTest static void execSvfPrintTest303SeeOther() {
        execSvfPrintTestSuccess(303);
    }

    /**
     * @description 印刷実行テスト 正常実行以外共通メソッド
     * @param responseCode レスポンスとして返却させるコード
     */
    private static void execSvfPrintTestError(Integer responseCode) {
        // preparation
        String result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfArtifactsHttpCalloutMock(false, responseCode));

        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.execSvfPrint(SvfArtifactsHttpCalloutMock.TEST_TOKEN, 'testfile', 'testdata', 'EXCEL');
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(null, result, '印刷データ取得URLが不正です。');
        System.assertEquals(true, hasException, '例外が発生していません。');
        System.assertEquals('印刷実行時HTTPステータス=' + responseCode, errorMessage, 'エラーメッセージが不正です。');
    }

    /**
     * @description 印刷実行テスト 400 Bad Request
     */
    @isTest static void execSvfPrintTest400BadRequest() {
        execSvfPrintTestError(400);
    }

    /**
     * @description 印刷実行テスト 401 Unauthorized
     */
    @isTest static void execSvfPrintTest401Unauthorized() {
        execSvfPrintTestError(401);
    }

    /**
     * @description 印刷実行テスト 403 Forbidden
     */
    @isTest static void execSvfPrintTest403Forbidden() {
        execSvfPrintTestError(403);
    }

    /**
     * @description 印刷実行テスト 429 Too many Requests
     */
    @isTest static void execSvfPrintTestError429TooManyRequests() {
        execSvfPrintTestError(429);
    }

    /**
     * @description 印刷実行テスト 503 Service Unavailable
     */
    @isTest static void execSvfPrintTest503ServiceUnavailable() {
        execSvfPrintTestError(503);
    }


    /*
     * @description 印刷実行テスト 例外
     */
    @isTest private static void execSvfPrintTestException() {
        // preparation
        String result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfArtifactsHttpCalloutMock(true, null));

        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.execSvfPrint(SvfArtifactsHttpCalloutMock.TEST_TOKEN, 'testfile', 'testdata', 'EXCEL');
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(null, result, '印刷データ取得URLが不正です。');
        System.assertEquals(true, hasException, '例外が発生していません。');
        System.assertEquals('通信エラー', errorMessage, 'エラーメッセージが不正です。');
    }

    /**
     * HTTPリクエスト作成時の汎用処理（通常）テスト
     */
    @isTest
    private static void writeFormDataTest(){
        // preparation
        String result;

        // execution
        Test.startTest();
        result = SvfOutputLogic.writeFormData('name', 'value');
        Test.stopTest();

        // assertion
        System.assert(result.contains('-------------------------------102852708831426\r\nContent-Disposition: form-data; name="name";\r\n\r\nvalue'), '\r\n');
    }

    /**
     * HTTPリクエスト作成時の汎用処理（ファイル系）テスト
     */
    @isTest
    private static void writeFileDataTest(){
        // preparation
        String result;

        // execution
        Test.startTest();
        result = SvfOutputLogic.writeFileData('name', 'value');
        Test.stopTest();

        // assertion
        System.assert(result.contains('-------------------------------102852708831426\r\nContent-Disposition: form-data; name="name"; filename="Print.csv";\r\nContent-Type: application/octet-stream\r\n\r\nvalue\r\n'), '\r\n');
    }

    /**
     * @description 成果物ダウンロードテスト 200 OK
     */
    @isTest private static void getSvfPrintdataTest200OK() {
        // preparation
        Blob result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfArtifactsHttpCalloutMock(false, 200));

        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.getSvfPrintdata(SvfArtifactsHttpCalloutMock.TEST_TOKEN, SvfArtifactsHttpCalloutMock.TEST_LOCATION);
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(SvfArtifactsHttpCalloutMock.TEST_OUTPUT, result.toString(), '成果物ダウンロード結果が不正です。');
        System.assertEquals(false, hasException, '例外が発生しています。');
        System.assertEquals(null, errorMessage, 'エラーメッセージが設定されています。');
    }

    /**
     * @description 成果物ダウンロードテスト 303 See Other
     */
    @isTest private static void getSvfPrintdataTest303SeeOther() {
        // preparation
        Blob result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfArtifactsHttpCalloutMock(false, 303));

        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.getSvfPrintdata(SvfArtifactsHttpCalloutMock.TEST_TOKEN, SvfArtifactsHttpCalloutMock.TEST_LOCATION);
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(SvfArtifactsHttpCalloutMock.TEST_OUTPUT_REDIRECT, result.toString(), '成果物ダウンロード結果が不正です。');
        System.assertEquals(false, hasException, '例外が発生しています。');
        System.assertEquals(null, errorMessage, 'エラーメッセージが設定されています。');
    }

    /**
     * @description 成果物ダウンロードテスト OK以外共通メソッド
     * @param responseCode レスポンスとして返却させるコード
     */
    private static void getSvfPrintdataTestNotOk(Integer responseCode) {
        // preparation
        Blob result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfArtifactsHttpCalloutMock(false, responseCode));

        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.getSvfPrintdata(SvfArtifactsHttpCalloutMock.TEST_TOKEN, SvfArtifactsHttpCalloutMock.TEST_LOCATION);
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(null, result, '成果物ダウンロード結果が不正です。');
        System.assertEquals(true, hasException, '例外が発生していません。');
        System.assertEquals('成果物ダウンロード時HTTPステータス=' + responseCode, errorMessage, 'エラーメッセージが不正です。');
    }

    /**
     * @description 成果物ダウンロードテスト 400 Bad Request
     */
    @isTest static void getSvfPrintdataTest400BadRequest() {
        getSvfPrintdataTestNotOk(400);
    }

    /**
     * @description 成果物ダウンロードテスト 401 Unauthorized
     */
    @isTest static void getSvfPrintdataTest401Unauthorized() {
        getSvfPrintdataTestNotOk(401);
    }

    /**
     * @description 成果物ダウンロードテスト 403 Forbidden
     */
    @isTest static void getSvfPrintdataTest403Forbidden() {
        getSvfPrintdataTestNotOk(403);
    }

    /**
     * @description 成果物ダウンロードテスト 404 Not Found
     */
    @isTest static void getSvfPrintdataTest404NotFound() {
        getSvfPrintdataTestNotOk(404);
    }

    /**
     * @description 成果物ダウンロードテスト 408 Request Timeout
     */
    @isTest static void getSvfPrintdataTest408RequestTimeout() {
        getSvfPrintdataTestNotOk(408);
    }

    /**
     * @description 成果物ダウンロードテスト 429 Too many Requests
     */
    @isTest static void getSvfPrintdataTest429TooManyRequests() {
        getSvfPrintdataTestNotOk(429);
    }

    /**
     * @description 成果物ダウンロードテスト 503 Service Unavailable
     */
    @isTest static void getSvfPrintdataTest503ServiceUnavailable() {
        getSvfPrintdataTestNotOk(503);
    }


    /*
    * @description 成果物ダウンロードテスト 例外
    */
    @isTest private static void getSvfPrintdataTestException() {
        // preparation
        Blob result;
        Boolean hasException = false;
        String errorMessage;

        Test.setMock(HttpCalloutMock.class, new SvfArtifactsHttpCalloutMock(true, null));

        // execution
        Test.startTest();
        try {
            result = SvfOutputLogic.getSvfPrintdata(SvfArtifactsHttpCalloutMock.TEST_TOKEN, SvfArtifactsHttpCalloutMock.TEST_LOCATION);
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(null, result, '成果物ダウンロード結果が不正です。');
        System.assertEquals(true, hasException, '例外が発生していません。');
        System.assertEquals('通信エラー', errorMessage, 'エラーメッセージが不正です。');
    }

    /**
     * コンテンツバージョンレコード登録テスト
     */
    @isTest private static void insertContentVersionTest(){
        // preparation
        Id executedResult;
        Id expectResult;

        // execution
        Test.startTest();
        executedResult = SvfOutputLogic.insertContentVersion('filename', Blob.valueOf('filedata'), 'extension');
        expectResult = [SELECT
                ContentDocumentId
            FROM
                ContentVersion
            WHERE
                ContentLocation = 'S'
                AND PathOnClient = :('filename' + 'extension')
                AND Title = 'filename'
                // field 'VersionData' can not be filtered in a query call
                // AND VersionData = :Blob.valueOf('filedata')
        ].ContentDocumentId;
        Test.stopTest();

        // assertion
        System.assertEquals(expectResult, executedResult, 'コンテンツバージョンレコードが登録できていません。');
    }

    /**
     * コンテンツバージョンレコード登録テスト DML例外
     */
    @isTest private static void insertContentVersionTestDMLException(){
        // preparation
        Id executedResult;
        Boolean hasException = false;
        String errorMessage;
        
        // execution
        Test.startTest();
        try {
            executedResult = SvfOutputLogic.insertContentVersion(null, null, null);
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(true, hasException, '例外が発生していません。');
        System.assertNotEquals(null, errorMessage, 'エラーメッセージが設定されています。');
    }

    /**
     * コンテンツドキュメントリンクレコード登録テスト
     */
    @isTest private static void insertContentDocumentLinkTest(){
        // preparation
        ContentDocumentLink cdl;
        RequestTask__c rt = new RequestTask__c(
            TaskCategory__c = '提案書作成依頼'
            , DueDate__c = Date.today()
            , RequestDestination__c = '神電'
            , Requester__c = '本社　施設'
        );
        insert rt;

        ContentVersion cv = new ContentVersion(
            Title = 'test'
            , PathOnClient = 'test'
            , VersionData = Blob.valueOf('test')
        );
        insert cv;
        Id cvid = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // execution
        Test.startTest();
        SvfOutputLogic.insertContentDocumentLink(rt.Id, cvid);
        cdl = [SELECT
                Id
            FROM
                ContentDocumentLink
            WHERE
                ContentDocumentId = :cvid
                AND LinkedEntityId = :rt.Id
                AND ShareType = 'V'
        ];
        Test.stopTest();

        // assertion
        System.assertNotEquals(null, cdl, 'コンテンツドキュメントリンクレコードが登録できていません。');
    }

    /**
     * コンテンツドキュメントリンクレコード登録テスト DML例外
     */
    @isTest private static void insertContentDocumentLinkTestDMLException(){
        // preparation
        Boolean hasException = false;
        String errorMessage;

        // execution
        Test.startTest();
        try {
            SvfOutputLogic.insertContentDocumentLink(null, null);
        } catch(Exception e) {
            hasException = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        // assertion
        System.assertEquals(true, hasException, '例外が発生していません。');
        System.assertNotEquals(null, errorMessage, 'エラーメッセージが設定されています。');
    }
}