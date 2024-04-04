public with sharing class RequestFormOutputLogic {
    @TestVisible private static final Datetime NOW = Datetime.now();
    @TestVisible private static final String EXECUTED_DATE = NOW.format('yyyyMMdd');

    // 帳票入力CSV
    @TestVisible private static String inputCsv = '';
    // ファイル名
    @TestVisible private static String fileName;
    // ファイル形式
    @TestVisible private static String fileFormat;
    // ファイルの拡張子
    @TestVisible private static String extention;
    // 帳票名
    @TestVisible private static String formName;

    /**
     * SVF帳票出力
     */
    public static String printSvfForm(Id requestTaskId){
        RequestFormOutputGenerator.getRequestTask(requestTaskId);
        String taskCategory = RequestFormOutputGenerator.requestTask.TaskCategory__c;
        String opportunityName = RequestFormOutputGenerator.requestTask.Opportunity__r.Name;

        executeByTaskCategory(taskCategory, requestTaskId);
        setFileName(taskCategory, opportunityName);
        setFileFormat(taskCategory);

        String result = SvfOutputLogic.svfOutput(requestTaskId, inputCsv, fileName, fileFormat, extention);
        RequestFormOutputGenerator.updateRequestTaskById(requestTaskId);
        return result;
    }

    /**
     * 依頼区分に応じた処理実行
     */
    @TestVisible private static void executeByTaskCategory(String taskCategory, Id requestTaskId){
        switch on taskCategory {
            when '提案書作成依頼' {
                formName = '①提案業務依頼書';
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(requestTaskId);
                inputCsv += vrSetForm('①提案業務依頼書.docx');
                inputCsv += RequestFormOutputGenerator.createRequestForm1Csv();
            }
            when '見積照会' {
                formName = '②見積照会書';
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(requestTaskId);
                inputCsv += vrSetForm('[②見積照会書.xlsx]見積照会書');
                inputCsv += RequestFormOutputGenerator.createRequestForm2Csv();
            }
            when '写真撮影依頼' {
                formName = '③写真撮影依頼書';
                inputCsv += vrSetForm('[③写真撮影依頼書.xlsm]写真撮影依頼書');
                inputCsv += RequestFormOutputGenerator.createRequestForm3Csv();
            }
            when '搬入依頼' {
                formName = '④機器搬入連絡表';
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(requestTaskId);
                inputCsv += vrSetForm('[④機器搬入連絡表.xlsx]3050機器搬入連絡表（本紙）');
                inputCsv += RequestFormOutputGenerator.createRequestForm4Csv();
            }
            when '技派依頼' {
                formName = '⑤技術員派遣依頼書';
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(requestTaskId);
                inputCsv += vrSetForm('⑤技術員派遣依頼書.docx');
                inputCsv += RequestFormOutputGenerator.createRequestForm5Csv();
            }
            when '製作所技術者選定依頼' {
                formName = '⑥配置技術者選定依頼';
                RequestFormOutputGenerator.getOpportunityConstructionInfoList(requestTaskId);
                inputCsv += vrSetForm('[⑥配置技術者選定依頼.xlsx]表紙（神電社シ一部対応）');
                inputCsv += RequestFormOutputGenerator.createRequestForm6Csv();
                inputCsv += '\r\n';
                inputCsv += vrSetForm('[⑥配置技術者選定依頼.xlsx]別紙');
                inputCsv += RequestFormOutputGenerator.createRequestForm6AppendixCsv();
            }
            when '先行手配依頼' {
                formName = '⑦先行手配依頼書';
                RequestFormOutputGenerator.getOpportunityBidManagementList(requestTaskId);
                inputCsv += vrSetForm('[⑦先行手配依頼書.xlsx]先行手配依頼書');
                inputCsv += RequestFormOutputGenerator.createRequestForm7Csv();
            }
            when '原低依頼' {
                formName = '⑧原低依頼書';
                RequestFormOutputGenerator.getOpportunityBidManagementList(requestTaskId);
                inputCsv += vrSetForm('[⑧原低依頼書.xlsx]原低依頼書');
                inputCsv += RequestFormOutputGenerator.createRequestForm8Csv();
            }
        }
    }

    /**
     *  @description VRSetForm関数設定
     */
    @TestVisible private static String vrSetForm(String xmlName){
        String function = '';
        function += '<start>\r\n';
        function += 'VrSetForm=' + Label.URL_DEFAULT_FORM_RequestTask + xmlName + '\r\n';
        function += '<end>\r\n';
        return function;
    }

    /**
     *  @description ファイル名設定処理
     * "SVF雛形_”&"案件名_"&"帳票名_"&"yyyyMMdd"
     */
    @TestVisible public static void setFileName(String taskCategory, String opportunityName){
        fileName = 'SVF雛形_' + opportunityName + '_' + formName + '_' + EXECUTED_DATE;
    }

    /**
     * @description ファイルフォーマット設定処理テスト
     * 依頼区分に応じた帳票のファイルフォーマットと拡張子を設定する。
     * @param 依頼区分
     */
    @TestVisible private static void setFileFormat(String taskCategory){
        switch on taskCategory {
            when '提案書作成依頼', '技派依頼' {
                fileFormat = 'WORD';
                extention = '.docx';
            }
            when '見積照会', '搬入依頼', '製作所技術者選定依頼', '先行手配依頼', '原低依頼' {
                fileFormat = 'EXCEL';
                extention = '.xlsx';
            }
            // 修正ポイント: 拡張子を.xlsxではなく.xlsmに変更する。(ケースNo.106)
            when '写真撮影依頼' {
                fileFormat = 'EXCEL';
                extention = '.xlsm';
            }
        }
    }
}