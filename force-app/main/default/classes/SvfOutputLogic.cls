public with sharing class SvfOutputLogic {
    // APIクライアントId
    @TestVisible private static final String CLIENT_ID = System.Label.SVF_ClientId;

    // APIシークレットキー
    @TestVisible private static final String SECRET_KEY = System.Label.SVF_SecretKey;

    // SVF プライベートキー
    @TestVisible private static final String PRIVATE_KEY = System.Label.SVF_PrivateKey1to1000 + System.Label.SVF_PrivateKey1001to2000;

    // アクセストークン取得API
    @TestVisible private static final String URL_GET_TOKEN = System.Label.SVF_UrlGetToken; 

    // 印刷実行API
    @TestVisible private static final String URL_PRINT_DATA = System.Label.SVF_UrlPrintData;

    // 現在時刻から1時間後のUnixTime。ミリ秒→秒変換。
    @TestVisible private static final String UNIXTIME_1HOUR_AFTER_EXECUTE = String.valueOf(System.now().addHours(1).getTime() / 1000);

    // バウンダリ文字列
    @TestVisible private static final String BOUNDARY = '-----------------------------102852708831426';

    // タイムアウト設定値
    private static final Integer SVFCLOUD_TIMEOUT = 120000;

    // 改行
    private static final String CRLF = '\r\n';

    /**
     * SVF帳票出力
     * @param recordId 成果物のアップロード先レコードID
     * @param printData 帳票入力CSV
     * @param fileName ファイル名
     * @param fileFormat ファイル形式
     * @param extension ファイルの拡張子
     * @return String レコード詳細ページURL
     */
    @TestVisible public static String svfOutput(Id recordId, String printData, String fileName, String fileFormat, String extension) {
        // アクセストークン取得
        String authorization = 'Bearer ' + getSvfToken();

        // 印刷実行(成果物問合せURI取得)
        String locationArtifact = execSvfPrint(authorization, fileName, printData, fileFormat);

        // 成果物ダウンロード
        Blob pdfData = getSvfPrintdata(authorization, locationArtifact);

        // コンテンツバージョンレコード登録
        Id contentDocumentId = insertContentVersion(fileName, pdfData, extension);

        // コンテンツドキュメントリンクレコード登録
        insertContentDocumentLink(recordId, contentDocumentId);

        PageReference ref = new PageReference('/' + recordId);
        return ref.getURL();
    }

    /**
     * アクセスートークン取得
     * @return String アクセストークン
     */
    @TestVisible private static String getSvfToken() {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(URL_GET_TOKEN);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + generateToken());
            request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(CLIENT_ID + ':' + SECRET_KEY)));
            request.setTimeout(SVFCLOUD_TIMEOUT);

            Http http = new Http();
            HTTPResponse response = http.send(request);
            System.Debug('アクセスートークン取得レスポンスコード： ' + response.getStatusCode());

            if (response.getStatusCode() == 200) {
                // OK
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return String.ValueOf(responseMap.get('token'));
            } else {
                // それ以外
                throw new CalloutException('認証時HTTPステータス=' + response.getStatusCode());
            }
        } catch (Exception e) {
            throw e;
        }
    }

    /**
     * JWTベアラトークン作成
     * @return String JWTベアラトークン
     */
    @TestVisible private static String generateToken() {
        Map<String, String> header = new Map<String, String> {'alg' => 'RS256'};
        Map<String, String> claimsMap = new Map<String, String> {
            'iss' => CLIENT_ID
            , 'sub' => UserInfo.getUserName()
            , 'exp' => UNIXTIME_1HOUR_AFTER_EXECUTE
            // ユーザー名：PDFファイルの作成者名不正対策。
            , 'userName' => '　'
        };
        String payload = encodeUrlsafeBase64(Blob.valueOf(JSON.serialize(header))) + '.' + encodeUrlsafeBase64(Blob.valueOf(JSON.serialize(claimsMap)));
        String signature = encodeUrlsafeBase64(Crypto.sign('RSA-SHA256', Blob.valueOf(payload), EncodingUtil.base64Decode(PRIVATE_KEY)));
        return payload + '.' + signature;
    }

    /**
     * Base64 URL エンコード (Base64 URL Encode)
     * @param target エンコード対象Blob
     * @return String エンコード結果
     */
    @TestVisible private static String encodeUrlsafeBase64(Blob target) {
        return EncodingUtil.base64Encode(target)
                .replace('+', '-')
                .replace('/', '_')
                .replace('=', '');
    }

    /**
     * 印刷実行
     * @param authorization アクセストークン
     * @param fileName ファイル名
     * @param printData 帳票入力CSV
     * @param fileFormat ファイル形式
     * @return String 印刷データ取得URL
     */
    @TestVisible private static String execSvfPrint(String authorization, String fileName, String printData, String fileFormat) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(URL_PRINT_DATA);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'multipart/form-data; boundary=' + BOUNDARY);
            request.setHeader('Authorization', authorization);
            request.setHeader('Accept', '*/*');
            request.setTimeout(SVFCLOUD_TIMEOUT);

            String data = '';
            data += writeFormData('name', fileName);
            data += writeFormData('printer', EncodingUtil.urlEncode(fileFormat, 'UTF-8'));
            data += writeFormData('source', EncodingUtil.urlEncode('CSV', 'UTF-8'));
            data += writeFormData('redirect', EncodingUtil.urlEncode('false', 'UTF-8'));
            data += writeFileData('data/', printData);
            data += '--' + BOUNDARY + '--';
            request.setBody(data);

            Http http = new Http();
            HttpResponse response = http.send(request);
            Integer statusCode = response.getStatusCode();
            System.Debug('request: ' + request);
            System.Debug('response: ' + response);
            System.Debug('印刷実行レスポンスコード=' + statusCode);

            if (statusCode == 202 || statusCode == 303) {
                // Accepted または See Other
                return response.getHeader('Location');
            } else {
                // それら以外
                throw new CalloutException('印刷実行時HTTPステータス=' + statusCode);
            }
        } catch (Exception e) {
            throw e;
        }
    }

    /**
     * HTTPリクエスト作成時の汎用処理（通常）
     * @param String 変換前データ
     * @return String 変換後データ
     */
    @TestVisible private static String writeFormData(String name, String value) {
        String data = '';
        data += '--' + BOUNDARY + CRLF;
        data += 'Content-Disposition: form-data; name="' + name + '";' + CRLF;
        data += CRLF;
        data += value;
        //heapサイズ対策
        value = null;
        data += CRLF;
        return data;
    }

    /**
     * HTTPリクエスト作成時の汎用処理（ファイル系）
     * @param String 変換前データ
     * @return String 変換後データ
     */
    @TestVisible private static String writeFileData(String name, String value) {
        String data = '';
        data += '--' + BOUNDARY + CRLF;
        data += 'Content-Disposition: form-data; name="' + name +
                '"; filename="Print.csv";\r\nContent-Type: application/octet-stream\r\n';
        data += CRLF;
        data += value;
        data += CRLF;
        return data;
    }

    /**
     * 成果物ダウンロード
     * @param authorization アクセストークン
     * @param location ダウンロードを問い合わせるURI
     * @return Blob 成果物
     */
    @TestVisible private static Blob getSvfPrintdata(String authorization, String location) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(location);
            request.setMethod('GET');
            request.setHeader('Accept', 'application/octet-stream');
            request.setHeader('Authorization', authorization);
            request.setTimeout(SVFCLOUD_TIMEOUT);
            request.setCompressed(false);

            Http http = new Http();
            HttpResponse response = http.send(request);
            Integer statusCode = response.getStatusCode();
            System.Debug('成果物ダウンロードレスポンスコード： ' + statusCode);

            if (statusCode == 200) {
                // OK
                return response.getBodyAsBlob();
            } else if (statusCode == 303) {
                // See Other
                return getSvfPrintdata(authorization, response.getHeader('Location'));
            } else {
                // それら以外
                throw new CalloutException('成果物ダウンロード時HTTPステータス=' + statusCode);
            }
        } catch (Exception e) {
            throw e;
        }
    }

    /**
     * コンテンツバージョンレコード登録
     * @param filename ファイル名
     * @param filedata 成果物データ
     * @param extension ファイル拡張子
     * @return Id ContentDocumentId
     */
    @TestVisible private static Id insertContentVersion(String filename, Blob filedata, String extension) {
        ContentVersion cv = new ContentVersion(
            // ドキュメントをSalesforce上に保存する。
            ContentLocation = 'S'
            , PathOnClient = filename + extension
            , Title = filename
            , VersionData = filedata
        );

        try {
            insert cv;
        } catch (DMLException ex) {
            System.Debug('ファイル関連付け:失敗');
            System.Debug('ex.getMessage ():' + ex.getMessage());
            throw ex;
        } catch (Exception ex) {
            System.Debug('ファイル作成:失敗');
            System.Debug('ex.getMessage ():' + ex.getMessage());
            throw ex;
        }

        // コンテンツバージョンレコードのコンテンツドキュメントIDを取得し、返却する。
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
    }

    /**
     * コンテンツドキュメントリンクレコード登録
     * @param recordId
     * @param contentDocumentId
     */
    @TestVisible private static void insertContentDocumentLink(String recordId, Id contentDocumentId) {
        // レコードとドキュメントをリンクする
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId
            , LinkedEntityId = recordId
            // 閲覧者権限を付与する。
            , ShareType = 'V'
        );

        try {
            insert cdl;
        } catch (DMLException ex) {
            System.Debug('ファイル関連付け:失敗');
            System.Debug('ex.getMessage ():' + ex.getMessage());
            throw ex;
        } catch (Exception ex) {
            System.Debug('ファイル関連付け:失敗');
            System.Debug('ex.getMessage ():' + ex.getMessage());
            throw ex;
        }
    }
}