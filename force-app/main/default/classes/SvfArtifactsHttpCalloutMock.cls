/**
 * @description SVF Cloud 印刷APIのモック
 */
@isTest
public class SvfArtifactsHttpCalloutMock implements HttpCalloutMock {
    // テスト用アクセストークン
    @TestVisible private static final String TEST_TOKEN = 'fa074d728eef1bfb1da897de1f64b53dae7857e87dd0b8b96d9f65e06da43e9f';
    @TestVisible private static final String TEST_LOCATION = 'https://api.svfcloud.test/v1/artifacts/testArtifactId';
    @TestVisible private static final String TEST_REDIRECT_LOCATION = 'https://api.svfcloud.test/v1/artifacts/testArtifactIdRedirect';
    @TestVisible private static final String TEST_OUTPUT = 'test output';
    @TestVisible private static final String TEST_OUTPUT_REDIRECT = 'test output redirect';

    // エラー発生フラグ
    public Boolean isError { get; set; }
    public Integer responseCode { get; set; }

    /**
     * @description コンストラクタ
     * @param isError エラー発生フラグ
     * @param responseCode レスポンスコード
     */
    public SvfArtifactsHttpCalloutMock(Boolean isError, Integer responseCode) {
        this.isError = isError;
        this.responseCode = responseCode;
    }

    /**
     * @description モックレスポンス
     * @param request HTTPリクエスト
     * @return HTTPResponse アクセストークンの取得結果
     */
    public HTTPResponse respond(HTTPRequest request) {
        // エラーフラグがtrueだった場合は通信エラーをスローする。
        if (this.isError) {
            throw new System.CalloutException('通信エラー');
        }

        System.assert(request.getMethod() != null, 'HTTPリクエストメソッドが不正です。');
        System.assert(request.getEndpoint() != null, 'エンドポイントが不正です。');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(this.responseCode);

        if (request.getMethod() == 'POST') {
            // assertion
            System.assertEquals(SvfOutputLogic.URL_PRINT_DATA, request.getEndpoint(), 'エンドポイントが不正です。');
            System.assertEquals('multipart/form-data; boundary=' + SvfOutputLogic.BOUNDARY, request.getHeader('Content-Type'), 'Content-Typeヘッダーが不正です。');
            System.assertEquals(TEST_TOKEN, request.getHeader('Authorization'), 'リクエストヘッダーのAuthorizationフィールドが不正です。');
            System.assertEquals('*/*', request.getHeader('Accept'), 'リクエストヘッダーのAcceptフィールドが不正です。');
            System.assertNotEquals(null, request.getBody(), 'リクエストボディが不正です。');

            // レスポンスデータ
            if(response.getStatusCode() == 202 || response.getStatusCode() == 303){
                // Accepted または See Other
                response.setHeader('Location', TEST_LOCATION);
            }
            return response;
        } else if (request.getMethod() == 'GET'){
            // assertion
            System.assertEquals('application/octet-stream', request.getHeader('Accept'), 'リクエストヘッダーのAcceptフィールドが不正です。');
            System.assertEquals(TEST_TOKEN, request.getHeader('Authorization'), 'リクエストヘッダーのAuthorizationフィールドが不正です。');

            // レスポンスデータ
            if(request.getEndpoint() == TEST_LOCATION){
                if(response.getStatusCode() == 200){
                    // OK
                    response.setBody(TEST_OUTPUT);
                } else if (response.getStatusCode() == 303){
                    // See Other
                    response.setHeader('Location', TEST_REDIRECT_LOCATION);
                }
            } else if(request.getEndpoint() == TEST_REDIRECT_LOCATION){
                // 303 See Other 経由でリクエストされた場合
                response.setStatusCode(200);
                response.setBody(TEST_OUTPUT_REDIRECT);
            } else {
                // TEST_LOCATION または TEST_REDIRECT_LOCATION 以外のエンドポイントは想定していない。
                throw new System.CalloutException('エンドポイントが不正です。');
            }
            return response;
        } else {
            // GET または POST 以外のHTTPリクエストメソッドは想定していない。
            throw new System.CalloutException('HTTPリクエストメソッドが不正です。');
        }
    }
}