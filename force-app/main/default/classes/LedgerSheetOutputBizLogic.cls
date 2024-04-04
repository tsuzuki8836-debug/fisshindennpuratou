public with sharing class LedgerSheetOutputBizLogic {

	private String clientId = '';
	private String secretKey = '';
	private String privateKey = '';
	private String urlGetToken = '';
	private String urlPrintData = '';

	// boudary
	private static final String BOUNDARY = '-----------------------------102852708831426';
	// SVFCLOUD_TIMEOUT
	private static final Integer SVFCLOUD_TIMEOUT = 120000;
	private static final Integer REPEAT_TIMES = 5;
	private static final String DELIMITER = '","';
	private static final String CRLF = '\r\n';

	public LedgerSheetOutputBizLogic(String clientId, String secretKey, String privateKey, String urlGetToken, String urlPrintData) {
		this.clientId = clientId;
		this.secretKey = secretKey;
		this.privateKey = privateKey;
		this.urlGetToken = urlGetToken;
		this.urlPrintData = urlPrintData;
	}

	public String svfLedgerSheetPrint(Id recordId, String printData, String fileName) {

		// // アクセストークン取得
		String authorization = 'Bearer ' + getSvfToken();

		// // 印刷実行
		String locationArtifact = execSvfPrint(authorization, fileName, printData);

		// // 印刷結果ファイル取得
		Blob pdfData = getSvfPrintdata(authorization, locationArtifact, 0);

		// // 印刷ログ記録＆ファイル添付
		Id vslId = insertVslWithFile(fileName, pdfData, recordId);

		PageReference ref = new PageReference('/' + recordId);
		return ref.getURL();
	}

	/**
	 * アクセスートークン取得
	 * @return String アクセストークン
	 */
	private String getSvfToken() {
		try {
			HttpRequest req = new HttpRequest() ;
			req.setHeader('Content-Type', 'application/x-www-form-urlencoded') ;
			req.setHeader('Authorization'
						  , 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(this.clientId + ':' + this.secretKey))
						 ) ;
			req.setMethod('POST') ;
			req.setEndpoint(this.urlGetToken) ;
			req.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + generateToken(this.clientId, this.privateKey)) ;
			req.setTimeout(12000) ;

			Http http = new Http() ;
			HTTPResponse response = http.send(req) ;

			// 成功
			if (response.getStatusCode() == 200) {
				System.Debug('トークン取得:成功');
				Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()) ;
				return String.ValueOf(responseMap.get('token')) ;
				// 失敗
			} else {
				//呼び出し元でキャッチするため、Exceptionを発行
				throw new CalloutException('認証時HTTPステータス=' + response.getStatusCode());
			}
		} catch (Exception e) {
			throw e;
		}
	}

	/**
	 * 印刷実行
	 * @return String 印刷データ取得URL
	 */
	private String execSvfPrint(String authorization, String fileName, String printData) {
		// String printData ='';
		String location = null;
		try {
			HttpRequest req = new HttpRequest() ;
			req.setEndpoint(this.urlPrintData) ;
			req.setHeader('Authorization', authorization) ;
//            req.setHeader ( 'processData', 'false' ) ;
			req.setHeader('Accept', '*/*') ;
			req.setHeader('Content-Type', 'multipart/form-data; boundary=' + BOUNDARY) ;
			req.setTimeout(SVFCLOUD_TIMEOUT) ;
			req.setMethod('POST') ;

			//ファイル名生成
			String data = '';
			data += writeFormData('name', fileName);
			data += writeFormData('printer', EncodingUtil.urlEncode('EXCEL', 'UTF-8'));
			data += writeFormData('source', EncodingUtil.urlEncode('CSV', 'UTF-8'));
			data += writeFormData('redirect', EncodingUtil.urlEncode('false', 'UTF-8'));
			data += writeFileData('data/', printData) ;
			data = writeEnd(data) ;
			req.setBody(data) ;

			//HTTPリクエストの送信
			Http http = new Http();
			HttpResponse res = http.send(req);

			// 成功
			if (res.getStatusCode() == 202 || res.getStatusCode() == 303) {
				System.Debug('印刷命令実行:成功');
				System.Debug('res.getStatusCode ():' + res.getStatusCode());
				location = res.getHeader('Location');
				System.Debug('location :' + location);
				return location;
				// 失敗
			} else {
				System.Debug('印刷命令実行:失敗');
				System.Debug('res.getStatusCode ():' + res.getStatusCode());
				return null;
			}
		} catch (Exception e) {
			throw e;
		}
	}

	/**
	 * 印刷結果データ取得
	 * @return Blob 印刷結果バイナリデータ
	 */
	private static Blob getSvfPrintdata(String authorization, String location, Integer currentrepeatTimes) {
		try {
			if(++currentrepeatTimes == REPEAT_TIMES) return null;

			HttpRequest req = new HttpRequest() ;
			req.setEndpoint(location) ;
			req.setHeader('Authorization', authorization) ;
			req.setHeader('Accept', 'application/octet-stream') ;
			req.setTimeout(SVFCLOUD_TIMEOUT) ;
			req.setCompressed(false);
			req.setMethod('GET') ;
			//HTTPリクエストの送信
			Http http = new Http() ;
			HttpResponse res = http.send(req) ;

			// 成功（バイナリデータ取得）
			if (res.getStatusCode() == 200) {
				System.Debug('成果物ダウンロード命令実行:成功');
				System.Debug('location:' + res.getHeader('Location'));
				Blob pdfData = res.getBodyAsBlob();
				return pdfData;
				// 成功（リダイレクト先URL取得）
			}

			if (res.getStatusCode() == 303) {
				// リダイレクト命令がレスポンスされた場合
				System.Debug('成果物ダウンロード命令実行:成功/リダイレクト');
				System.Debug('location:' + res.getHeader('Location'));
				return getSvfPrintdata(authorization, res.getHeader('Location'), currentrepeatTimes) ;
			} else {
				System.Debug('成果物ダウンロード命令実行:失敗');
				System.Debug('res.getStatusCode ():' + res.getStatusCode());
				return null;
			}
		} catch (Exception e) {
			throw e;
		}
	}

	/**
	 * 出力ログ作成、ファイル添付
	 * @return String ログオブジェクトId
	 */
	private static Id insertVslWithFile(String filename, Blob filedata, Id recordId) {

		// ドキュメントを作成する
		ContentVersion cv = new ContentVersion();
		// ファイルはSalesforce上に保存
		cv.ContentLocation = 'S';
		// ファイル名
		cv.PathOnClient = filename + '.xlsm';
		// ファイルタイトル
		cv.Title = filename;
		// ファイルの内容
		cv.VersionData = filedata;

		try {
			insert cv;
		} catch (Exception ex) {
			System.Debug('ファイル作成:失敗');
			System.Debug('ex.getMessage ():' + ex.getMessage());
			return null;
		}

		// 登録したファイルのドキュメントIDを取得する
		Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

		// レコードとドキュメントをリンクする
		ContentDocumentLink cde = new ContentDocumentLink();
		// リンクするドキュメントID
		cde.ContentDocumentId = docId;
		// 添付ファイルとしてリンクするオブジェクトのレコードID
		cde.LinkedEntityId = recordId;
		cde.ShareType = 'V';

		try {
			insert cde;
		} catch (Exception ex) {
			System.Debug('ファイル関連付け:失敗');
			System.Debug('ex.getMessage ():' + ex.getMessage());
			return null;
		}

		return docId;
	}

	/**
	 * HTTPリクエスト作成時の汎用処理（通常）
	 * @param String 変換前データ
	 * @return String 変換後データ
	 */
	private static String writeFormData(String name, String value) {
		String data = '';
		data += '--' + boundary + CRLF;
		data += 'Content-Disposition: form-data; name="' + name + '";' + CRLF;
		data += CRLF;
		data += value;
		//heapサイズ対策
		value = null;
		data += CRLF;
		return data;
	}

	/**
	 * HTTPリクエスト作成時の汎用処理（末尾）
	 * @param String 変換前データ
	 * @return String 変換後データ
	 */
	private static String writeEnd(String data) {
		data += '--' + boundary + '--';
		return data;
	}

	/**
	 * HTTPリクエスト作成時の汎用処理（ファイル系）
	 * @param String 変換前データ
	 * @return String 変換後データ
	 */
	private static String writeFileData(String name, String value) {
		String data = '';
		data += '--' + boundary + CRLF;
		data += 'Content-Disposition: form-data; name="' + name +
				'"; filename="Print.csv";\r\nContent-Type: application/octet-stream\r\n';
		data += CRLF;
		data += value;
		data += CRLF;
		return data;
	}


	/**
	 * JWTベアラトークン作成
	 * @param clientId client Id
	 * @param key      private key
	 * @param expiration expiration date time
	 */
	private static String generateToken(String clientId, String key, DateTime expiration) {
		Map<String, String> header = new Map<String, String> {'alg' => 'RS256'};
		Map<String, String> payload = new Map<String, String> {
			'iss' => clientId, 'sub' => UserInfo.getUserName(), 'exp' => unixTime(expiration)
			, 'userName' => '　' // PDFファイルの作成者名不正対策
		};
		String target = encodeUrlsafeBase64(Blob.valueOf(JSON.serialize(header))) + '.' + encodeUrlsafeBase64(Blob.valueOf(JSON.serialize(payload)));
		String signature = encodeUrlsafeBase64(Crypto.sign('RSA-SHA256', Blob.valueOf(target), EncodingUtil.base64Decode(key)));
		return target + '.' + signature;
	}
	/**
	 * generate JWT
	 * @param clientId client Id
	 * @param key      private key
	 */
	private static String generateToken(String clientId, String key) {
		return generateToken(clientId, key, DateTime.now().addHours(1));
	}

	/**
	 * Convert DateTime to unix time expression
	 * @param dt
	 */
	private static String unixTime(DateTime dt) {
		return '' + dt.getTime() / 1000;
	}

	/**
	 * Encode to Base64URL
	 * @target
	 */
	private static String encodeUrlsafeBase64(Blob target) {
		return EncodingUtil.base64Encode(target)
			   .replace('+', '-')
			   .replace('/', '_')
			   .replace('=', '');
	}

	// /**
	//  * 文字列内のダブルクォーテーションをエスケープする処理
	//  * @param target エスケープする文字列
	//  * @return String
	//  */
	// private static String escapeDoubleQuotation(String target) {
	// 	return String.isNotBlank(target) ? target.replace('"', '""') : target;
	// }
}