/**
 * @description SVF Cloud アクセストークン取得APIのモック
 */
@isTest
public class SvfTokenHttpCalloutMock implements HttpCalloutMock {
    // テスト用アクセストークン
    @TestVisible private static final String TEST_TOKEN = 'fa074d728eef1bfb1da897de1f64b53dae7857e87dd0b8b96d9f65e06da43e9f';

    // エラー発生フラグ
    public Boolean isError { get; set; }
    public Integer responseCode { get; set; }

    /**
     * @description コンストラクタ
     * @param isError エラー発生フラグ
     * @param responseCode レスポンスコード
     */
    public SvfTokenHttpCalloutMock(Boolean isError, Integer responseCode) {
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

        // assertion
        System.assertEquals(SvfOutputLogic.URL_GET_TOKEN, request.getEndpoint(), 'エンドポイントが不正です。');
        System.assertEquals('POST', request.getMethod(), 'HTTPリクエストメソッドが不正です。');
        System.assertEquals('application/x-www-form-urlencoded', request.getHeader('Content-Type'), 'Content-Typeヘッダーが不正です。');
        System.assertEquals('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + SvfOutputLogic.generateToken(), request.getBody(), 'リクエストボディが不正です。');
        System.assertEquals('Basic ' + EncodingUtil.base64Encode(Blob.valueOf(SvfOutputLogic.CLIENT_ID + ':' + SvfOutputLogic.SECRET_KEY)), request.getHeader('Authorization'), 'リクエストヘッダーのAuthorizationフィールドが不正です。');

        // レスポンスデータ
        Map<String, Object> responseMap = new Map<String, Object>{
            // アクセストークン
            'token' => TEST_TOKEN
            // 有効期限
            , 'expiration' => SvfOutputLogic.UNIXTIME_1HOUR_AFTER_EXECUTE
        };

        HttpResponse response = new HttpResponse();
        response.setStatusCode(this.responseCode);

        if(this.responseCode == 200){
            // OK
            response.setBody(JSON.serialize(responseMap));
        }
        return response;
    }
}