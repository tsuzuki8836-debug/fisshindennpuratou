public class LedgerOutputCmpController {

	// APIクライアントId (TerraSkyClientUser1)
	// private static final String CLIENT_ID = 'SVFIGLK.....XXXX' ;
	private static final String CLIENT_ID = System.Label.SVF_ClientId ;

	// APIシークレットキー
	// private static final String SECRET_KEY = 'MYp8tJsL.....XXXX';
	private static final String SECRET_KEY = System.Label.SVF_SecretKey;
	// RSA KEY:pemファイルの内容(改行除去)
	// private static final String PRIVATE_KEY = 'MIIEpAIBAAKCA.....XXXX';
	private static final String PRIVATE_KEY = System.Label.SVF_PrivateKey1to1000 + System.Label.SVF_PrivateKey1001to2000;

	//SVF API URL' +
	// private static final String URL_GET_TOKEN = 'https://api.svfcloud.com/oauth2/token'; //トークン取得API
	private static final String URL_GET_TOKEN = System.Label.SVF_UrlGetToken; //トークン取得API
	// private static final String URL_PRINT_DATA = 'https://api.svfcloud.com/v1/artifacts'; //印刷指示API
	private static final String URL_PRINT_DATA = System.Label.SVF_UrlPrintData; //印刷指示API

    @AuraEnabled
	public static String LedgerSheetOutput(Id recordId){
		LedgerSheetOutputBizLogic ledgerSheetOutputBizLogic = new LedgerSheetOutputBizLogic(
			CLIENT_ID,
			SECRET_KEY,
			PRIVATE_KEY,
			URL_GET_TOKEN,
			URL_PRINT_DATA
		);

		// 印刷データ作成
		LedgerSheetOutputGenerator generator = new LedgerSheetOutputGenerator();
		String printData = generator.generatePrintData(recordId);
		String fileName = generator.getFileName();
	
		return ledgerSheetOutputBizLogic.svfLedgerSheetPrint(recordId, printData, fileName);
	}
}