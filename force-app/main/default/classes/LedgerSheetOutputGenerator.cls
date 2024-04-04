public with sharing class LedgerSheetOutputGenerator {
	// 帳票定義パス　※本開発時には正しいパスに修正する
	// private static final String URL_DEFAULT_FORM = 'form/帳票フォーム/';
	private static final String URL_DEFAULT_FORM = System.Label.SVF_UrlDefaultForm;
	// private static final String URL_DEFAULT_FORM = 'form/帳票フォーム/帳票開発（テラスカイ）/';

	//Form Name for Facility Type
	private static final String FORM_NAME_FT = System.Label.SVF_FormNameFT;
	//Form Name for WaterEnv Type
	private static final String FORM_NAME_WT = System.Label.SVF_FormNameWT;
	//Form Name for PubliDem Type
	private static final String FORM_NAME_PD = System.Label.SVF_FormNamePD;

	private static final String CRLF = '\r\n';
	private static final String LF = '\n';

	// Sheet Label List For Facility Type
	private static final String SHEETLABEL_LIST = System.Label.SVF_SheetLabelList;
    private static List<String> SheetLabels = SHEETLABEL_LIST.replace(CRLF, LF).split(LF);

    private static String printData = '';
	private static String fileName = '';
	private static String formName = '';

	private static Integer counterLevel1 = 0;

	private static Quote__c quote = new Quote__c();
	private static Map<Id, Device__c> deviceMap = new Map<Id, Device__c>();

	private static Map<String, SVF_Format_Setting__mdt> formatMap = new Map<String, SVF_Format_Setting__mdt>();

    public String generatePrintData(Id parentId) {

        quote = [SELECT
					Id,
					Subject__c,
					Name,
					QuoteNumber__c,
					GeneralAdministrativeExpenses__c,
					GeneralAdministrativeExpensesPercent__c,
					PowerFrequency__c,
					Account__r.Name,
					OutputSheetName__c,
					RecordTypeId
				FROM Quote__c
				WHERE id =:parentId
				LIMIT 1];

		deviceMap = getDataRecords();
	
		// Generate File Name
		Datetime todayDate = Datetime.now();
		String todayDateStr = todayDate.format('yyyyMMddHHmmss');
		fileName = quote.QuoteNumber__c + '_' + quote.OutputSheetName__c + '_' + todayDateStr;
		// Classify Form Type by Record Type
        String recordTypeName = Schema.SObjectType.Quote__c.getRecordTypeInfosById().get(quote.RecordTypeId).getname();
        if (quote != null) {
            // 施設
            if(recordTypeName == '施設') {
				formName = FORM_NAME_FT;
            }
            // 水環境
            else if(recordTypeName == '水環境'){
				formName = FORM_NAME_WT;
            }
			// 官需
			else {
				formName = FORM_NAME_PD;
            }
			formatMap = getFormatRecords(recordTypeName);
			printData = generatePrintDataStep(recordTypeName);
        }
        return printData;
    }

	private String generatePrintDataStep(String recordType) {
		String csvFormData = '';

		csvFormData += generateAPIHeader(SheetLabels.get(3));
		// Column
		csvFormData += generateColumns(recordType);
		// Parent data
		csvFormData += generateParentData(recordType);
		for (String key : deviceMap.keySet()) {
			Device__c device = deviceMap.get(key);
			// 見出し=01 :: Level 1
			csvFormData += generateHeaderData(recordType, device);
			// 見出し=01 :: Level 2
			//csvFormData += generateHeaderDataAddMinor(recordType, device);

			if(device.Details__r.size() > 0) {
				// reorder detail records
				Map<String, Detail__c> detailsMap = reorderDetailRecords(device.Details__r);
				List<String> keys = new List<String>(detailsMap.keySet());
				keys.sort();

				// 明細=02 :: 明細(筐体) 
				csvFormData += generateDetailKyotaiData(recordType, device, detailsMap, keys);

				// 明細=02 :: 明細(明細)
				csvFormData += generateDetailMeisaiData(recordType, device, detailsMap, keys);

				// 集計=03 :: 集計(明細)
				csvFormData += generateDetailSummaryData(recordType, device, detailsMap, keys);


				counterLevel1 = 0;
			} else {
				// In case that have NO details record
				csvFormData += setOptionalLine(recordType, device.DisplayOrder__c, device.QuoteSpecificationNumber__c, '02', 1, null, null, null, null);
			}

			// 合計=04 :: 合計
			csvFormData += generateTotalData(recordType, device);
		}
		return csvFormData;
	}

	private static String generateAPIHeader(String sheetName) {
		String header = '';
		header  += '<start>' + CRLF;
		header += 'VrSetForm=' + URL_DEFAULT_FORM + '[' + formName + '.xlsm]' + sheetName + CRLF;
		header += '<end>' + CRLF;

		return header;
	}

	private static String generateColumns(String recordType) {
		List<String> columns = new List<String>{};
		// 見積
		columns.add('見積番号');
		columns.add('客先名');
		columns.add('件名');
		columns.add(recordType=='施設'?'一般管理費':'諸経費');
		columns.add('周波数');
			// 見積項目
			columns.add('表示順');
			columns.add('仕様書番号');
			columns.add('明細種類');
			columns.add('明細並び順');
			if(recordType!='施設') columns.add('機器管理対象');
			columns.add('一般管理費有無');
			columns.add('大分類');
			columns.add('小分類');
			columns.add('機器数量');
			columns.add('機器単位');
			columns.add('機器単位WC');
			columns.add('機器単位見積金額');
			columns.add(recordType=='施設'?'機器単代理店提供':'機器単位重量');
			columns.add('機器備考');
				// 明細
				columns.add('品名１');
				columns.add('品名２');
				columns.add('品名３');
				columns.add('数量');
				columns.add('単価');
				columns.add('価格係数');
				columns.add('備考');
				columns.add('WC単価');
				columns.add(recordType=='施設'?'代理店提供価格':'単位重量');
				columns.add('係数');
		return listToCSVString(columns);
	}

	private static String generateParentData(String recordType) {
		List<String> outputDatas = new List<String>();
		if(recordType == '施設') {
			outputDatas.addAll(new List<String>{
				'見積番号  第  ' + quote.QuoteNumber__c + '  号',										 // 1) 見積番号 :: 見積.見積番号（任意）
				quote.Account__r.Name,																	// 2) 客先名 :: 見積に紐づく取引先名を編
				quote.Subject__c,																		// 3) 件名 :: 見積に紐づく案件名を編集
				String.valueOf((quote.GeneralAdministrativeExpensesPercent__c/100).setScale(2)),		// 4) 一般管理費 :: 帳票項目名：諸経費、1.0以下の数値渡し
				'周波数　' + quote.PowerFrequency__c,													 // 5) 周波数 :: 見積.電源周波数
				null,																					// 6) 表示順
				null,																					// 7) 仕様書番号
				null,																					// 8) 明細種類
				null,																					// 9) 明細並び順
				null,																					// 10) 一般管理費有無
				null,																					// 11) 大分類
				null,																					// 12) 小分類
				null,																					// 13) 機器数量
				null,																					// 14) 機器単位
				null,																					// 15) 機器単位WC
				null,																					// 16) 機器単位見積金額
				null,																					// 17) 機器単代理店提供
				null,																					// 18) 機器備考
				null,																					// 19) 品名１
				null,																					// 20) 品名２
				null,																					// 21) 品名３
				null,																					// 22) 数量
				null,																					// 23) 単価
				null,																					// 24) 価格係数
				null,																					// 25) 備考
				null,																					// 26) WC単価
				null,																					// 27) 代理店提供価格
				null																					// 28) 係数
			});
		} else {
			outputDatas.addAll(new List<String>{
				'見積番号  第  ' + quote.QuoteNumber__c  + '  号',													 // 1) 見積番号 :: 見積.見積番号（任意）
				quote.Account__r.Name,																	// 2) 客先名 :: 見積に紐づく取引先名を編
				quote.Subject__c,																		// 3) 件名 :: 見積に紐づく案件名を編集
				String.valueOf((quote.GeneralAdministrativeExpensesPercent__c/100).setScale(2)),		// 4) 諸経費 :: 帳票項目名：諸経費、1.0以下の数値渡し
				'周波数　' + quote.PowerFrequency__c,													 // 5) 周波数 :: 見積.電源周波数
				null,																					// 6) 表示順
				null,																					// 7) 仕様書番号
				null,																					// 8) 明細種類
				null,																					// 9) 明細並び順
				null,																					// 10) 機器管理費集計対象
				null,																					// 11) 一般管理費有無
				null,																					// 12) 大分類
				null,																					// 13) 小分類
				null,																					// 14) 機器数量
				null,																					// 15) 機器単位
				null,																					// 16) 機器単位WC
				null,																					// 17) 機器単位見積金額
				null,																					// 18) 機器単位重量
				null,																					// 19) 機器備考
				null,																					// 20) 品名１
				null,																					// 21) 品名２
				null,																					// 22) 品名３
				null,																					// 23) 数量
				null,																					// 24) 単価
				null,																					// 25) 価格係数
				null,																					// 26) 備考
				null,																					// 27) WC単価
				null,																					// 28) 単位重量
				null																					// 29) 係数
			});
		}
		return listToCSVString(outputDatas);
	}

	// 見出し=01 :: 機器(Level 1)
	private static String generateHeaderData(String recordType, Device__c device) {
		List<String> outputDatas = new List<String>();
		if(recordType == '施設') {
			outputDatas.addAll(new List<String>{
				null,																									// 1) 見積番号'
				null,																									// 2) 客先名
				null,																									// 3) 件名
				null,																									// 4) 一般管理費
				null,																									// 5) 周波数
				String.valueOf(device.DisplayOrder__c),																	// 6) 表示順 :: 機器.表示順
				String.valueOf(device.QuoteSpecificationNumber__c),														// 7) 仕様書番号 :: 機器.見積番号
				'01',																									// 8) 明細種類 :: 見出し=01、明細=02、集計=03、合計=04
				String.valueOf(++counterLevel1),																		// 9) 明細並び順
				device.GeneralAdminExpensesExistence__c == true ? 'Y' : 'N',											// 10) 一般管理費有無
				device.MajorClassification__c,																			// 11) 大分類
				device.MinorClassification__c,																			// 12) 小分類
				String.valueOf(device.QuantityNumeric__c),																// 13) 機器数量
				device.Unit__c,																							// 14) 機器単位
				String.valueOf(device.CreditWC__c),																		// 15) 機器単位WC
				String.valueOf(device.CreditQuoteAmount__c),															// 16) 機器単位見積金額
				String.valueOf(device.CreditAgencyProvisionUnitPrice__c),												// 17) 機器単代理店提供
				device.Note__c,																							// 18) 機器備考
				device.Name,																							// 19) 品名１
				null,																									// 20) 品名２
				null,																									// 21) 品名３
				null,																									// 22) 数量
				null,																									// 23) 単価
				device.PriceCoefficient__c == null ? '0.00' : String.valueOf(device.PriceCoefficient__c.setScale(2)),	// 24) 価格係数
				null,																									// 25) 備考
				null,																									// 26) WC単価
				null,																									// 27) 代理店提供価格
				null																									// 28) 係数
			});
		} else {
			outputDatas.addAll(new List<String>{
				null,																									// 1) 見積番号
				null,																									// 2) 客先名
				null,																									// 3) 件名
				null,																									// 4) 諸経費
				null,																									// 5) 周波数
				String.valueOf(device.DisplayOrder__c),																	// 6) 表示順 :: 見積項目.表示順
				String.valueOf(device.QuoteSpecificationNumber__c),														// 7) 仕様書番号 :: 見積項目.見積番号
				'01',																									// 8) 明細種類 :: 見出し=01、明細=02、集計=03、合計=04
				String.valueOf(++counterLevel1),																		// 9) 明細並び順
				device.EquipManageCostTarget__c == true ? 'Y' : 'N',													// 10) 機器管理費集計対象
				device.GeneralAdminExpensesExistence__c == true ? 'Y' : 'N',											// 11) 一般管理費有無
				device.MajorClassification__c,																			// 12) 大分類
				device.MinorClassification__c,																			// 13) 小分類
				String.valueOf(device.QuantityNumeric__c),																// 14) 機器数量
				device.Unit__c,																							// 15) 機器単位
				String.valueOf(device.CreditWC__c),																		// 16) 機器単位WC
				String.valueOf(device.CreditQuoteAmount__c),															// 17) 機器単位見積金額
				String.valueOf(device.CreditWeight__c),																	// 18) 機器単位重量
				device.Note__c,																							// 19) 機器備考
				device.Name,																							// 20) 品名１
				null,																									// 21) 品名２
				null,																									// 22) 品名３
				null,																									// 23) 数量
				null,																									// 24) 単価
				device.PriceCoefficient__c == null ? '0.00' : String.valueOf(device.PriceCoefficient__c.setScale(2)),	// 25) 価格係数
				null,																									// 26) 備考
				null,																									// 27) WC単価
				null,																									// 28) 単位重量
				null																									// 29) 係数
			});
		}
		return listToCSVString(outputDatas);
	}

	// 見出し=01 :: 小分類(Level 2)
	// private static String generateHeaderDataAddMinor(String recordType, Device__c device) {

	// 	List<String> addMinor = new List<String>{'ｺﾝﾄﾛｰﾙｾﾝﾀ（C/C)'};
	// 	if(addMinor.contains(device.MajorClassification__c)) {
	// 		String minorClassification = device.MajorClassification__c=='特高'?
	// 			'　電圧 ' + device.MinorClassification__c:
	// 			device.MinorClassification__c;

	// 		List<String> outputDatas = new List<String>();
	// 		if(recordType == '施設') {
	// 			outputDatas.addAll(new List<String>{
	// 				null,																							// 1) 見積番号'
	// 				null,																							// 2) 客先名
	// 				null,																							// 3) 件名
	// 				null,																							// 4) 一般管理費
	// 				null,																							// 5) 周波数
	// 				String.valueOf(device.DisplayOrder__c),															// 6) 表示順 :: 機器.表示順
	// 				String.valueOf(device.QuoteSpecificationNumber__c),												// 7) 仕様書番号 :: 機器.見積番号
	// 				'01',																							// 8) 明細種類 :: 見出し=01、明細=02、集計=03、合計=04		
	// 				String.valueOf(++counterLevel1),																// 9) 明細並び順	
	// 				null,																							// 10) 一般管理費有無
	// 				null,																							// 11) 大分類
	// 				null,																							// 12) 小分類
	// 				null,																							// 13) 機器数量
	// 				null,																							// 14) 機器単位
	// 				null,																							// 15) 機器単位WC
	// 				null,																							// 16) 機器単位見積金額
	// 				null,																							// 17) 機器単代理店提供
	// 				null,																							// 18) 機器備考
	// 				minorClassification,	 																		// 19) 品名１ ==> 小分類
	// 				null,																							// 20) 品名２
	// 				null,																							// 21) 品名３
	// 				null,																							// 22) 数量
	// 				null,																							// 23) 単価
	// 				null,																							// 24) 価格係数
	// 				null,																							// 25) 備考
	// 				null,																							// 26) WC単価
	// 				null,																							// 27) 代理店提供価格
	// 				null																							// 28) 係数
	// 			});
	// 		} else {
	// 			outputDatas.addAll(new List<String>{
	// 				null,																							// 1) 見積番号
	// 				null,																							// 2) 客先名
	// 				null,																							// 3) 件名
	// 				null,																							// 4) 諸経費
	// 				null,																							// 5) 周波数
	// 				String.valueOf(device.DisplayOrder__c),															// 6) 表示順 :: 見積項目.表示順
	// 				String.valueOf(device.QuoteSpecificationNumber__c),												// 7) 仕様書番号 :: 見積項目.見積番号
	// 				'01',																							// 8) 明細種類 :: 見出し=01、明細=02、集計=03、合計=04		
	// 				String.valueOf(++counterLevel1),																// 9) 明細並び順
	// 				null,																							// 10) 機器管理費集計対象	
	// 				null,																							// 11) 一般管理費有無
	// 				null,																							// 12) 大分類
	// 				null,																							// 13) 小分類
	// 				null,																							// 14) 機器数量
	// 				null,																							// 15) 機器単位
	// 				null,																							// 16) 機器単位WC
	// 				null,																							// 17) 機器単位見積金額
	// 				null,																							// 18) 機器単位重量
	// 				null,																							// 19) 機器備考
	// 				minorClassification,	 																		// 20) 品名１ ==> 小分類
	// 				null,																							// 21) 品名２
	// 				null,																							// 22) 品名３
	// 				null,																							// 23) 数量
	// 				null,																							// 24) 単価
	// 				null,																							// 25) 価格係数
	// 				null,																							// 26) 備考
	// 				null,																							// 27) WC単価
	// 				null,																							// 28) 単位重量
	// 				null																							// 29) 係数
	// 			});
	// 		}
	// 		return listToCSVString(outputDatas);
	// 	} else {
	// 		return '';
	// 	}
	// }

	// 明細=02 :: 明細(筐体)
	private static String generateDetailKyotaiData(String recordType, Device__c device, Map<String, Detail__c> detailsMap, List<String> keys) {
		String outputDatasRes = '';
		for (String key : keys) {
			Detail__c detail = detailsMap.get(key);
			if(detail.DetailCategory__c == '筐体' || detail.DetailCategory__c == '仕様') {
				String customKey = '';
				customKey += String.isBlank(detail.MajorClassificationCode__c) ? 'XX' : detail.MajorClassificationCode__c;
				customKey += String.isBlank(detail.MinorClassificationCode__c) ? 'XX' : detail.MinorClassificationCode__c;
				customKey += String.isBlank(detail.CategoryCode__c) ? 'XX' : detail.CategoryCode__c;

				String unitPrice = '';
				if(detail.WcCoefficient__c != null && detail.CreditWC__c != null){
					unitPrice = String.valueOf(detail.CreditWC__c / 1000);
				}else if(detail.WcCoefficient__c != null && detail.CreditWC__c == null){
					unitPrice = '0';
				}else{
					unitPrice = detail.UnitPrice__c == null ? '' : String.valueOf(detail.UnitPrice__c / 1000);
				}

				SVF_Format_Setting__mdt formatRec = formatMap.get(customKey) == null ? formatMap.get('XXXXXX') : formatMap.get(customKey);

				if(formatRec.KyoTai_Used__c) {
					formatRec.PrintOutFormat_KyoTai__c = prepareFormatSlot(formatRec.PrintOutFormat_KyoTai__c);

					List<String> formatByLine = formatRec.PrintOutFormat_KyoTai__c.replace(CRLF, LF).split(LF);
					List<List<String>> formatList = new List<List<String>>();

					Boolean isFirstLine = true;
					for(String formatLine : formatByLine) {
						List<String> formatStr = formatLine.substring(1, formatLine.length() - 1).split('\\],\\[', 3);

						List<String> outputDatas = new List<String>();
						if(recordType == '施設') {
							outputDatas.addAll(new List<String>{
								null,																				// 1) 見積番号'
								null,																				// 2) 客先名
								null,																				// 3) 件名
								null,																				// 4) 一般管理費
								null,																				// 5) 周波数
								String.valueOf(device.DisplayOrder__c),												// 6) 表示順 :: 機器.表示順
								String.valueOf(device.QuoteSpecificationNumber__c),									// 7) 仕様書番号 :: 機器.見積番号
								'01',																				// 8) 明細種類 :: 見出し=01、明細=02、集計=03、合計=04
								String.valueOf(++counterLevel1),													// 9) 明細並び順	
								null,																				// 10) 一般管理費有無
								null,																				// 11) 大分類
								null,																				// 12) 小分類
								null,																				// 13) 機器数量
								null,																				// 14) 機器単位
								null,																				// 15) 機器単位WC
								null,																				// 16) 機器単位見積金額
								null,																				// 17) 機器単代理店提供
								null,																				// 18) 機器備考
								String.isBlank(formatStr[0]) ? null : replaceFormatString(formatStr[0], detail),	// 19) 品名１
								String.isBlank(formatStr[1]) ? null : replaceFormatString(formatStr[1], detail),	// 20) 品名２
								String.isBlank(formatStr[2]) ? null : replaceFormatString(formatStr[2], detail),	// 21) 品名３
								!isFirstLine ? null : String.valueOf(detail.Quantity__c),							// 22) 数量
								!isFirstLine ? null : unitPrice,													// 23) 単価
								null,																				// 24) 価格係数
								!isFirstLine ? null : detail.Note__c,												// 25) 備考
								!isFirstLine ? null : 
								detail.CreditWC__c == null ? null : String.valueOf(detail.CreditWC__c / 1000),		// 26) WC単価
								!isFirstLine ? null : 
								detail.ProvisionUnitPrice__c == null ? null : String.valueOf(detail.ProvisionUnitPrice__c / 1000),	// 27) 代理店提供価格
								!isFirstLine ? null : generateCoefficient(detail)									// 28) 係数	
							});
						} else {
							outputDatas.addAll(new List<String>{
								null,																				// 1) 見積番号
								null,																				// 2) 客先名
								null,																				// 3) 件名
								null,																				// 4) 諸経費
								null,																				// 5) 周波数
								String.valueOf(device.DisplayOrder__c),												// 6) 表示順 :: 見積項目.表示順
								String.valueOf(device.QuoteSpecificationNumber__c),									// 7) 仕様書番号 :: 見積項目.見積番号
								'01',																				// 8) 明細種類 :: 見出し=01、明細=02、集計=03、合計=04
								String.valueOf(++counterLevel1),													// 9) 明細並び順
								null,																				// 10) 機器管理費集計対象	
								null,																				// 11) 一般管理費有無
								null,																				// 12) 大分類
								null,																				// 13) 小分類
								null,																				// 14) 機器数量
								null,																				// 15) 機器単位
								null,																				// 16) 機器単位WC
								null,																				// 17) 機器単位見積金額
								null,																				// 18) 機器単位重量
								null,																				// 19) 機器備考
								String.isBlank(formatStr[0]) ? null : replaceFormatString(formatStr[0], detail),	// 20) 品名１
								String.isBlank(formatStr[1]) ? null : replaceFormatString(formatStr[1], detail),	// 21) 品名２
								String.isBlank(formatStr[2]) ? null : replaceFormatString(formatStr[2], detail),	// 22) 品名３
								!isFirstLine ? null : String.valueOf(detail.Quantity__c),							// 23) 数量
								!isFirstLine ? null : unitPrice,													// 24) 単価
								null,																				// 25) 価格係数
								!isFirstLine ? null : detail.Note__c,												// 26) 備考
								!isFirstLine ? null : 
								detail.CreditWC__c == null ? null : String.valueOf(detail.CreditWC__c / 1000),		// 27) WC単価
								!isFirstLine ? null : String.valueOf(detail.CreditWeight__c),						// 28) 単位重量
								!isFirstLine ? null : generateCoefficient(detail)									// 29) 係数	
							});
						}
						// 大分類「発電機」かつ小分類「発電機関連」かつ名称1が「補機盤」以外の場合、2行目の出力を行わない
						if(!(!isFirstLine && detail.MajorClassificationCode__c == '12' && detail.MinorClassificationCode__c == '04' && detail.Name1__c != '補機盤')){
							outputDatasRes += listToCSVString(outputDatas);
						}
						// End line
						isFirstLine = false;
					}
				}
			}
		}
		return outputDatasRes;
	}

	// 明細=02 :: 明細(明細)
	private static String generateDetailMeisaiData(String recordType, Device__c device, Map<String, Detail__c> detailsMap, List<String> keys) {
		Integer counterLevel2 = 0;
		String outputDatasRes = '';
		String ccMinorClassificationName = '';
		String lastCCOutput = '';
		for (String key : keys) {
			Detail__c detail = detailsMap.get(key);
			if(detail.DetailCategory__c == '明細' || detail.DetailCategory__c == '手入力') {

				String customKey = '';
				String note = detail.DetailCategory__c == '手入力' ? '＊' + detail.Note__c : detail.Note__c;
				customKey += String.isBlank(detail.MajorClassificationCode__c) ? 'XX' : detail.MajorClassificationCode__c;
				customKey += String.isBlank(detail.MinorClassificationCode__c) ? 'XX' : detail.MinorClassificationCode__c;
				customKey += String.isBlank(detail.CategoryCode__c) ? 'XX' : detail.CategoryCode__c;
				
				String unitPrice = '';
				if(detail.WcCoefficient__c != null && detail.CreditWC__c != null){
					unitPrice = String.valueOf(detail.CreditWC__c / 1000);
				}else if(detail.WcCoefficient__c != null && detail.CreditWC__c == null){
					unitPrice = '0';
				}else{
					unitPrice = String.valueOf(detail.UnitPrice__c / 1000);
				}

				if(detail.MajorClassificationName__c == 'コントロールセンタ(C/C)' && lastCCOutput != detail.MinorClassificationName__c){
					ccMinorClassificationName = '　電圧 ' + detail.MinorClassificationName__c;
					outputDatasRes += setOptionalLine(recordType, device.DisplayOrder__c, device.QuoteSpecificationNumber__c, '02', ++counterLevel2, ccMinorClassificationName, null, null, null);
					lastCCOutput = detail.MinorClassificationName__c;
				}
				
				SVF_Format_Setting__mdt formatRec = formatMap.get(customKey) == null ? formatMap.get('XXXXXX') : formatMap.get(customKey);

				if(formatRec.MeiSai_Used__c) {
					formatRec.PrintOutFormat_MeiSai__c = prepareFormatSlot(formatRec.PrintOutFormat_MeiSai__c);

					List<String> formatByLine = formatRec.PrintOutFormat_MeiSai__c.replace(CRLF, LF).split(LF);
					List<List<String>> formatList = new List<List<String>>();

					Boolean isFirstLine = true;
					for(String formatLine : formatByLine) { 
						List<String> formatStr = formatLine.substring(1, formatLine.length() - 1).split('\\],\\[', 3);
						List<String> outputDatas = new List<String>();
						if(recordType == '施設') {
							outputDatas.addAll(new List<String>{
								null,																				// 1) 見積番号'
								null,																				// 2) 客先名
								null,																				// 3) 件名
								null,																				// 4) 一般管理費
								null,																				// 5) 周波数
								String.valueOf(device.DisplayOrder__c),												// 6) 表示順 :: 機器.表示順
								String.valueOf(device.QuoteSpecificationNumber__c),									// 7) 仕様書番号 :: 機器.見積番号
								'02',																				// 8) 明細種類 :: 見出し=01、明細=02、集計=03、合計=04		
								String.valueOf(++counterLevel2),													// 9) 明細並び順	
								null,																				// 10) 一般管理費有無
								null,																				// 11) 大分類
								null,																				// 12) 小分類
								null,																				// 13) 機器数量
								null,																				// 14) 機器単位
								null,																				// 15) 機器単位WC
								null,																				// 16) 機器単位見積金額
								null,																				// 17) 機器単代理店提供
								null,																				// 18) 機器備考
								String.isBlank(formatStr[0]) ? null : replaceFormatString(formatStr[0], detail),	// 19) 品名１
								String.isBlank(formatStr[1]) ? null : replaceFormatString(formatStr[1], detail),	// 20) 品名２
								String.isBlank(formatStr[2]) ? null : replaceFormatString(formatStr[2], detail),	// 21) 品名３
								!isFirstLine ? null : String.valueOf(detail.Quantity__c),							// 22) 数量
								!isFirstLine ? null : unitPrice,													// 23) 単価
								null,																				// 24) 価格係数
								!isFirstLine ? null : note,												// 25) 備考
								!isFirstLine ? null : 
								detail.CreditWC__c == null ? null : String.valueOf(detail.CreditWC__c / 1000),		// 26) WC単価
								!isFirstLine ? null : 
								detail.ProvisionUnitPrice__c == null ? null : String.valueOf(detail.ProvisionUnitPrice__c / 1000),	// 27) 代理店提供価格
								!isFirstLine ? null : generateCoefficient(detail)									// 28) 係数	
							});
						} else {
							outputDatas.addAll(new List<String>{
								null,																				// 1) 見積番号
								null,																				// 2) 客先名
								null,																				// 3) 件名
								null,																				// 4) 諸経費
								null,																				// 5) 周波数
								String.valueOf(device.DisplayOrder__c),												// 6) 表示順 :: 見積項目.表示順
								String.valueOf(device.QuoteSpecificationNumber__c),									// 7) 仕様書番号 :: 見積項目.見積番号
								'02',																				// 8) 明細種類 :: 見出し=01、明細=02、集計=03、合計=04		
								String.valueOf(++counterLevel2),													// 9) 明細並び順
								null,																				// 10) 機器管理費集計対象
								null,																				// 11) 一般管理費有無
								null,																				// 12) 大分類
								null,																				// 13) 小分類
								null,																				// 14) 機器数量
								null,																				// 15) 機器単位
								null,																				// 16) 機器単位WC
								null,																				// 17) 機器単位見積金額
								null,																				// 18) 機器単位重量
								null,																				// 19) 機器備考
								String.isBlank(formatStr[0]) ? null : replaceFormatString(formatStr[0], detail),	// 20) 品名１
								String.isBlank(formatStr[1]) ? null : replaceFormatString(formatStr[1], detail),	// 21) 品名２
								String.isBlank(formatStr[2]) ? null : replaceFormatString(formatStr[2], detail),	// 22) 品名３
								!isFirstLine ? null : String.valueOf(detail.Quantity__c),							// 23) 数量
								!isFirstLine ? null : unitPrice,													// 24) 単価
								null,																				// 25) 価格係数
								!isFirstLine ? null : note,															// 26) 備考
								!isFirstLine ? null : 
								detail.CreditWC__c == null ? null : String.valueOf(detail.CreditWC__c / 1000),		// 27) WC単価
								!isFirstLine ? null : String.valueOf(detail.CreditWeight__c),						// 28) 単位重量
								!isFirstLine ? null : generateCoefficient(detail)									// 29) 係数	
							});
						}
						isFirstLine = false;
						// End line
						outputDatasRes += listToCSVString(outputDatas);
					}
				}
			}
		}
		return outputDatasRes;
	}

	// 集計=03 :: 集計(明細)
	private static String generateDetailSummaryData(String recordType, Device__c device, Map<String, Detail__c> detailsMap, List<String> keys) {
		Integer counter = 0;
		String outputDatasRes = '';
		if(recordType == '施設') {
			for (String key : keys) {
				Detail__c detail = detailsMap.get(key);
				if(!String.isBlank(detail.detailedStatementText__c)) {
					String displayStr = detail.Quantity__c + ' ✕ ' + detail.detailedStatementText__c;
					List<String> outputDatas = new List<String>{
						null,																				// 1) 見積番号
						null,																				// 2) 客先名
						null,																				// 3) 件名
						null,																				// 4) 諸経費
						null,																				// 5) 周波数
						String.valueOf(device.DisplayOrder__c),												// 6) 表示順 :: 見積項目.表示順
						String.valueOf(device.QuoteSpecificationNumber__c),									// 7) 仕様書番号 :: 見積項目.見積番号
						'03',																				// 8) 明細種類 :: 見出し=01、明細=02、集計=03、合計=04		
						String.valueOf(++counter),															// 9) 明細並び順
						null,																				// 10) 一般管理費有無
						null,																				// 11) 大分類
						null,																				// 12) 小分類
						null,																				// 13) 機器数量
						null,																				// 14) 機器単位
						null,																				// 15) 機器単位WC
						null,																				// 16) 機器単位見積金額
						null,																				// 17) 機器単位重量
						null,																				// 18) 機器備考
						displayStr,																			// 19) 品名１
						null,																				// 20) 品名２
						null,																				// 21) 品名３
						null,																				// 22) 数量
						null,																				// 23) 単価
						null,																				// 24) 価格係数
						null,																				// 25) 備考
						null,																				// 26) WC単価
						null,																				// 27) 単位重量
						null																				// 28) 係数	
					};
					// End line
					outputDatasRes += listToCSVString(outputDatas);					
				}
			}
		}
		return outputDatasRes;
	}

	// 合計=04 :: 合計
	private static String generateTotalData(String recordType, Device__c device) {
		String outputDatas = '';
		
		String levelCode = '';
		String expenses = '';
		// 客先回答金額（手入力対応）2022/11/30 TS鈴木
		String clientAnswerAmountFree = String.isBlank(String.valueOf(device.ClientAnswerAmount_free__c)) ? null : '＊提示価格 ' + device.ClientAnswerAmount_free__c.format();
		// 施設の場合は
		if(recordType == '施設') {
			levelCode = '04';
			expenses = '諸経費 ' + quote.GeneralAdministrativeExpensesPercent__c + '%';
		}
		// 水環境・官需の場合は
		else {
			levelCode = '03';
			expenses = '一般管理費 ' + quote.GeneralAdministrativeExpensesPercent__c + '%';
		}

		// 積算金額、WC金額合計
		outputDatas += setOptionalLine(recordType, device.DisplayOrder__c, device.QuoteSpecificationNumber__c, levelCode, 1, '積算金額、WC金額合計', null, null, null);
		// 積算金額×価格係数
		outputDatas += setOptionalLine(recordType, device.DisplayOrder__c, device.QuoteSpecificationNumber__c, levelCode, 2, '積算金額×価格係数', null, null, null);
		// 施設の場合は「諸経費 n%」、水環境・官需の場合は「一般管理費 n%」
		outputDatas += setOptionalLine(recordType, device.DisplayOrder__c, device.QuoteSpecificationNumber__c, levelCode, 3, expenses, null, null, null);
		// 見積金額
		outputDatas += setOptionalLine(recordType, device.DisplayOrder__c, device.QuoteSpecificationNumber__c, levelCode, 4, '見積金額', null, null, null);
		// 客先回答金額
		outputDatas += setOptionalLine(recordType, device.DisplayOrder__c, device.QuoteSpecificationNumber__c, levelCode, 5, '客先回答金額', null, null, clientAnswerAmountFree);
	
		return outputDatas;
	}

	private static Map<Id, Device__c> getDataRecords() {
		// Query Device and Detail Records
		Map<Id, Device__c> deviceMapRes = new Map<Id, Device__c>([SELECT
																	Quote__c,
																	Id,
																	Name,
																	toLabel(MajorClassification__c),
																	toLabel(MinorClassification__c),
																	EquipManageCostTarget__c,
																	PriceCoefficient__c,
																	DisplayOrder__c,
																	QuoteSpecificationNumber__c,
																	GeneralAdminExpensesExistence__c,
																	Quantity__c,
																	QuantityNumeric__c,
																	Unit__c,
																	CreditWC__c,
																	CreditWeight__c,
																	CreditAgencyProvisionUnitPrice__c,
																	CreditQuoteAmount__c,
																	Note__c,
																	ClientAnswerAmount_free__c,
																	(SELECT
																			Id,
																			Device__c,
																			Name,
																			Name1__c,
																			Name2__c,
																			Name3__c,
																			Name4__c,
																			Name5__c,
																			Name6__c,
																			Name7__c,
																			Name8__c,
																			Name9__c,
																			Name10__c,
																			MajorClassificationCode__c,
																			MajorClassificationName__c,
																			MinorClassificationCode__c,
																			MinorClassificationName__c,
																			CategoryCode__c,
																			CategoryName__c,
																			SpecialSpecificationNo__c,
																			RECNO__c,
																			detailedStatementText__c,
																			Quantity__c,
																			UnitPrice__c,
																			Note__c,
																			CreditWC__c,
																			CreditWeight__c,
																			ProvisionUnitPrice__c,
																			PriceCoefficient__c,
																			WcCoefficient__c,
																			UnitPriceCoefficient__c,
																			DetailCategory__c,
																			DetailCategoryCode__c
																		FROM Details__r
																		//WHERE Quantity__c > 0
																		ORDER BY DetailCategory__c ASC
																	)
																FROM Device__c
																WHERE Quote__c =:quote.Id
																ORDER BY QuoteSpecificationNumber__c ASC
		]);
		return deviceMapRes;
	}

	private static Map<String, Detail__c> reorderDetailRecords(List<Detail__c> details) {

		Map<String, Detail__c> detailsMap = new Map<String, Detail__c>();
		for (Detail__c detail : details) {
			String customKey = '';

			// 第1キー：明細.明細種別=「仕様」>「筐体」>「明細」＞「手入力」の順で上に並ぶ
			customKey += String.isBlank(detail.DetailCategoryCode__c) ? '9' : detail.DetailCategoryCode__c;
			// 第2キー：明細.大分類コードの昇順
			customKey += '_' + (String.isBlank(detail.MajorClassificationCode__c) ? '99' : detail.MajorClassificationCode__c);
			// 第3キー：明細.小分類コードの昇順
			customKey += '_' + (String.isBlank(detail.MinorClassificationCode__c) ? '99' : detail.MinorClassificationCode__c);
			// 第4キー：明細.特殊仕様Noの昇順
			customKey += '_' + String.valueOf(detail.SpecialSpecificationNo__c == null ? 0 : detail.SpecialSpecificationNo__c).leftPad(10, '0');
			// 第5キー：明細.RECNOの昇順
			customKey += '_' + String.valueOf(detail.RECNO__c == null ? 0 : detail.RECNO__c).leftPad(8, '0');
			// 第6キー：明細.カスタムオブジェクトIDの昇順
			customKey += '_' + detail.Id;
	
			detailsMap.put(customKey, detail);
		}
		return detailsMap;
	}

	private static Map<String, SVF_Format_Setting__mdt> getFormatRecords(String recordTypeName) {
		// Query format Records
		List<String> orderBy = new List<String>{'MajorClassificationCode__c', 'MinorClassificationCode__c', 'CategoryCode__c'};
		List<String> fields = new List<String>{
			'Id',
			'Label',
			'MajorClassificationCode__c',
			'MajorClassificationName__c',
			'MinorClassificationCode__c',
			'MinorClassificationName__c',
			'CategoryCode__c',
			'CategoryName__c',
			'KyoTai_Used__c',
			'PrintOutFormat_KyoTai__c',
			'MeiSai_Used__c',
			'PrintOutFormat_MeiSai__c'
		};

		String query = 'SELECT ' + String.join(new List<String>(fields), ',');
		query += ' FROM SVF_Format_Setting__mdt';
		/*switch on recordTypeName {
			when '水環境' {
				query += ' WHERE ForWaterEnvironment__c = true';
			} when '施設' {
				query += ' WHERE ForFacility__c = true';
			} when else {
				query += ' WHERE ForPublicDemand__c = true';
			}
		}*/
		query += ' ORDER BY ' + String.join(new List<String>(orderBy), ',') + ' ASC';

		List<SVF_Format_Setting__mdt> formatRes = Database.query(query);

		Map<String, SVF_Format_Setting__mdt> formats = new Map<String, SVF_Format_Setting__mdt>();
		for (SVF_Format_Setting__mdt format : formatRes) {
			String customKey = '';
			customKey += String.isBlank(format.MajorClassificationCode__c) ? 'XX' : format.MajorClassificationCode__c;
			customKey += String.isBlank(format.MinorClassificationCode__c) ? 'XX' : format.MinorClassificationCode__c;
			customKey += String.isBlank(format.CategoryCode__c) ? 'XX' : format.CategoryCode__c;

			formats.put(customKey, format);
		}
		return formats;
	}

	private static String prepareFormatSlot(String sourceFormat) {
		String targetFormat = sourceFormat;
		targetFormat = targetFormat.replace('{名称1}', '{0}');
		targetFormat = targetFormat.replace('{名称2}', '{1}');
		targetFormat = targetFormat.replace('{名称3}', '{2}');
		targetFormat = targetFormat.replace('{名称4}', '{3}');
		targetFormat = targetFormat.replace('{名称5}', '{4}');
		targetFormat = targetFormat.replace('{名称6}', '{5}');
		targetFormat = targetFormat.replace('{名称7}', '{6}');
		targetFormat = targetFormat.replace('{名称8}', '{7}');
		targetFormat = targetFormat.replace('{名称9}', '{8}');
		targetFormat = targetFormat.replace('{名称10}', '{9}');
		targetFormat = targetFormat.replace('{小分類名}', '{10}');
		return targetFormat;
	}

	private static String replaceFormatString(String formatStr, Detail__c detail) {
		return String.format(formatStr, new List<Object>{
			detail.Name1__c,
			detail.Name2__c,
			detail.Name3__c,
			detail.Name4__c,
			detail.Name5__c,
			detail.Name6__c,
			detail.Name7__c,
			detail.Name8__c,
			detail.Name9__c,
			detail.Name10__c,
			detail.MinorClassificationName__c
		});
	}

	// 集計 計算
	private static String generateCoefficient(Detail__c detail) {
		String coefficient = '';
		if(detail.WcCoefficient__c != null) {
			coefficient = String.valueOf(detail.WcCoefficient__c.setScale(2));
		} else {
			coefficient = String.valueOf((detail.UnitPriceCoefficient__c!=null?detail.UnitPriceCoefficient__c:1.00).setScale(2));
		}
		return coefficient;
	}

	private static String setOptionalLine(String recordType,
										  Decimal displayOrder,
										  String specificationNumber,
										  String itemType,
										  Integer itemOrder,
										  String Str1,
										  String Str2,
										  String Str3,
										  String note // 客先回答金額（手入力対応）2022/11/30 TS鈴木
	) {
		List<String> optionalLine = new List<String>();
		// 1), 2), 3), 4), 5)
		optionalLine.addAll(new List<String>{null,null,null,null,null});
		// 6), 表示順
		optionalLine.add(String.valueOf(displayOrder));
		// 7), 仕様書番号
		optionalLine.add(specificationNumber);
		// 8), 明細種類
		optionalLine.add(itemType);
		// 9), 明細並び順
		optionalLine.add(String.valueOf(itemOrder));
		// 10), 機器管理対象
		if(recordType != '施設') optionalLine.add(null);
		// 施設				10), 11), 12), 13), 14), 15), 16), 17), 18)
		// 水環境, 官需		 11), 12), 13), 14), 15), 16), 17), 18), 19)
		optionalLine.addAll(new List<String>{null,null,null,null,null,null,null,null,null});
		// 施設				19), 品名1
		// 水環境, 官需		20), 品名1
		optionalLine.add(Str1);
		// 施設				20), 品名2
		// 水環境, 官需		21), 品名2
		optionalLine.add(Str2);
		// 施設				21), 品名3
		// 水環境, 官需		22), 品名3
		optionalLine.add(Str3);
		// 施設				22), 23), 24)
		// 水環境, 官需		23), 24), 25)
		optionalLine.addAll(new List<String>{null,null,null});
		// 施設				25), 備考
		// 水環境, 官需		26), 備考
		optionalLine.add(note); // 客先回答金額（手入力対応）2022/11/30 TS鈴木
		// 施設				26), 27), 28)
		// 水環境, 官需		27), 28), 29)
		optionalLine.addAll(new List<String>{null,null,null});

		return listToCSVString(optionalLine);
	}
	
	private static String listToCSVString(List<String> dataList) {
		return ('"' + String.join(dataList, '","') + '"' + CRLF).replace('null', '');
	}

	public String getFileName() {
		return fileName;
	}
}