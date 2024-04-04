import { LightningElement, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pickedBUAfter from '@salesforce/apex/DetailsAddController.pickedBUAfter';
import pickedMajorAfter from '@salesforce/apex/DetailsAddController.pickedMajorAfter';
import pickedQuoteNumberAfter from '@salesforce/apex/DetailsAddController.pickedQuoteNumberAfter';
import getPricingTableRecords from '@salesforce/apex/DetailsAddController.getPricingTableRecords';
import getPricingTableRecordsByImage from '@salesforce/apex/DetailsAddController.getPricingTableRecordsByImage';
import getDetailTableRecords from '@salesforce/apex/DetailsAddController.getDetailTableRecords';
import getSymbolObjectRecords from '@salesforce/apex/DetailsAddController.getSymbolObjectRecords';
import buList from '@salesforce/label/c.BuList';
import symbolObject from '@salesforce/resourceUrl/SymbolObject';
import { isNotEmpty, priceCalculator } from 'c/commonUtil';

export default class DetailsAddScreen extends LightningElement {

    //外部API：機器Id
    @api recordId;
    @api loader = false;//spinner表示制御

    //ページング変数
    @track pageSize = 500;//ページ毎に表示件数
    @track pageNumber = 1;//当前ページ
    @track totalRecords = 0;//データ数
    @track totalPages = 0;//ページ数
    @track recordEnd = 0;//ページ終了数
    @track recordStart = 0;//ページ開始数
    @track isPrev = true;//前ページあるかどうか
    @track isNext = true;//次ページあるかどうか
    @track searchFlg = '';//'1'⇒マスタ検索、'2'⇒画像検索、'3'⇒見積検索

    //------------------BU検索条件----------------
	@track isBuShow = true;//表示する制御
    @track bu_LabelName = 'BU';
    @track bu_isDisabled = false;//利用可否
    @track bu_isRequired = false;//必須可否
    @track bu_Options=[];//プルダウンリスト
    @track bu_Value='';//Bu選択値

    //------------------大分類検索条件----------------
	@track isMajorShow = true;//検索条件を表示する制御
    @track major_LabelName = '大分類';
    @track major_isDisabled = true;//利用可否
    @track major_isRequired = false;//必須可否
    @track major_Options=[];//プルダウンリスト
    @track major_Value='';//大分類選択値

    //------------------小分類検索条件----------------
	@track isMinorShow = true;//検索条件を表示する制御
    @track minor_LabelName = '小分類';
    @track minor_isDisabled = true;//利用可否
    @track minor_isRequired = false;//必須可否
    @track minor_Options=[];//プルダウンリスト
    @track minor_Value='';//小分類選択値
    //小分類が選択必須の大分類
    @track minorIsRequired=['特高','変圧器','高圧コンビ',
                            '低圧・現場・リレー・ACB盤','コントロールセンタ(C/C)',
                            '回転数制御装置(VVVF)','MACTUS',
                            '計装機器','発電機','UPS',
                            // 'MELFLEX',
                            '進相コンデンサ/リアクトル','大型映像装置','テレメータ装置',
                            '無線装置(テレメータ･テレコントロール用)','放流警報装置','テレメータ装置(自律型)',
                            'IP伝送装置','CCTVカメラ設備','本支社専用'];

    //------------------見積番号検索条件----------------
	@track isQuoteNumberShow = true;//見積番号検索条件を表示する制御
    @track quoteNumber_LabelName = '見積番号';
    @track quoteNumber_isDisabled = true;//利用可否
    @track quoteNumber_isRequired = false;//必須可否
    @track quoteNumber_Options=[];//プルダウンリスト
    @track quoteNumber_Value='';//見積番号選択値

    //------------------見積項目名検索条件----------------
	@track isNameShow = true;//見積項目名検索条件を表示する制御
    @track name_LabelName = '見積項目名';
    @track name_isDisabled = true;//利用可否
    @track name_isRequired = false;//必須可否
    @track name_Options=[];//プルダウンリスト
    @track name_Value='';//見積項目名選択値

    //------------------一覧に使う変数-----------
    @track isWeight = false;//施設:false  官需・水環境:true
    @track isDisplayNoRecords= false;//データなし場合、メッセージ表示
    @track detailRecords = [];//一覧表示内容
    @track intensifyRecords = [];//数量が入力された一覧

    //------------------記号検索画面-------------
    @track isShowImageMark = false;//図記号検索を表示する制御
    @track symbolObjectList = []; //図記号検索の一覧
    @track soSelectList = []; //図記号検索の選択されたデータ

    //画面初期処理
    connectedCallback() {
        //Buプルダウンを設定する
        var bu =  buList.split(',');
        bu.forEach((item) => {
            var valList = item.split(':');
            var valSet = {label:valList[0], value:valList[1]};
            this.bu_Options.push(valSet);
        })
    }
    //BU条件が変更された場合
    bu_Handler(evt){
        console.log(evt.target.value);
        this.bu_Value=evt.target.value;

        //状態クリア
        //大分類
        this.major_isDisabled = true; //利用制御
        this.major_Options=[];//リストクリア
        this.major_Value='';
        //小分類
        this.minor_isDisabled = true; //利用制御
        this.minor_Options=[];//リストクリア
        this.minor_Value='';
        //見積番号
        this.quoteNumber_isDisabled = true; //利用制御
        this.quoteNumber_Options=[];//リストクリア
        this.quoteNumber_Value='';//見積番号選択値
        //小分類
        this.name_isDisabled = true; //利用制御
        this.name_Options=[];//リストクリア
        this.name_Value='';//見積項目名選択値
        this.name_isRequired = false;//必須可否
        //一覧状態をクリア
        this.clearTableList();

        if (isNotEmpty(this.bu_Value)) {
            this.loader = true; //spinner表示制御⇒制御
            //連動リストを取得するApexの呼び出し
            pickedBUAfter({
                bu:this.bu_Value
            }).then(result => {
                if(result){
                    this.defaultNames = result;
                    //Apexから戻る結果を変数に設定
                    this.major_Options =  this.defaultNames.major;//大分類
                    this.quoteNumber_Options =  this.defaultNames.quoteNumber;//見積番号
                    //大分類
                    if (this.major_Options!==undefined && this.major_Options.length>0) {
                        this.major_isDisabled = false; //利用制御
                    }
                    //見積番号
                    if (this.quoteNumber_Options!==undefined && this.quoteNumber_Options.length>0) {
                        this.quoteNumber_isDisabled = false; //利用制御
                    }

                }
                this.loader = false; //spinner表示制御⇒解除
            });
        }
    }
    //大分類条件が変更された場合
    major_Handler(evt){
        console.log(evt.target.value);
        this.major_Value=evt.target.value;

        //小分類
        this.minor_isDisabled = true; //利用制御
        this.minor_Options=[];//リストクリア
        this.minor_Value='';
        this.name_isRequired = false;//必須可否
        //一覧状態をクリア
        this.clearTableList();

        if (isNotEmpty(this.major_Value)) {

            //小分類が選択必須
            if (this.minorIsRequired.includes(this.major_Value)) {
                this.name_isRequired = true;//必須可否
            }

            this.loader = true; //spinner表示制御⇒制御
            //連動リストを取得するApexの呼び出し
            pickedMajorAfter({
                bu:this.bu_Value,
                major:this.major_Value
            }).then(result => {
                console.log(result);
                if(result){
                    this.defaultNames = result;
                    //Apexから戻る結果を変数に設定
                    this.minor_Options =  this.defaultNames.minor;//小分類
                    //小分類
                    if (this.minor_Options!==undefined && this.minor_Options.length>0) {
                        this.minor_isDisabled = false; //利用制御
                    }
                }
                this.loader = false; //spinner表示制御⇒解除
            });
        }
    }
    //検索条件：小分類が変更された場合
    minor_Handler(evt){
        console.log(evt.target.value);
        this.minor_Value=evt.target.value;

        //一覧状態をクリア
        this.clearTableList();

    }

    //見積番号条件が変更された場合
    quoteNumber_Handler(evt){
        console.log(evt.target.value);
        this.quoteNumber_Value=evt.target.value;

        //見積項目名
        this.name_isDisabled = true; //利用制御
        this.name_Options=[];//リストクリア
        this.name_Value='';//見積項目名選択値

        //一覧状態をクリア
        this.clearTableList();

        if (isNotEmpty(this.quoteNumber_Value)) {
            this.loader = true; //spinner表示制御⇒制御
            //連動リストを取得するApexの呼び出し
            pickedQuoteNumberAfter({
                quoteNumber:this.quoteNumber_Value,
                deviceId:this.recordId
            }).then(result => {
                if(result){
                    this.defaultNames = result;
                    //Apexから戻る結果を変数に設定
                    this.name_Options =  this.defaultNames.name;//見積項目名
                    //見積項目名
                    if (this.name_Options!==undefined && this.name_Options.length>0) {
                        this.name_isDisabled = false; //利用制御
                    }
                }
                this.loader = false; //spinner表示制御⇒解除
            });
        }
    }
    //検索条件：見積項目名が変更された場合
    name_Handler(evt){
        console.log(evt.target.value);
        this.name_Value=evt.target.value;

        //一覧状態をクリア
        this.clearTableList();
    }

    //マスタ検索
    onMasterSearch(){
        console.log('onMasterSearch Start');
        var msg = '';
        console.log(this.bu_Value);
        if (!isNotEmpty(this.bu_Value)){
            msg = 'BU';
        }else if(!isNotEmpty(this.major_Value)){
            msg = '大分類';
        }else if(!isNotEmpty(this.minor_Value) && this.name_isRequired){
            msg = '小分類';
        }

        console.log(msg);
        //未選択された場合、エラーとする。
        if (isNotEmpty(msg)) {
            const errEvent = new ShowToastEvent({
                title: '',
                message: msg + 'を選択してください。',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
        //上記以外　検索を行う。
        }else {
            //一覧状態をクリア
            this.clearTableList();
            this.searchFlg = '1';
            //一覧検索
            this.masterSearch();
        }
    }

    //次ページへ遷移　の動作
    handleNext(){
        this.pageNumber = this.pageNumber+1;
        console.log('this.searchFlg'+this.searchFlg);
        if (this.searchFlg === '1') {
            //マスタ検索
            this.masterSearch();
        }else if (this.searchFlg === '2') {
            //画像検索
            this.imageSearch();
        }else if (this.searchFlg === '3') {
            //見積検索
            this.quoteSearch();
        }

    }

    //前ページへ遷移　の動作
    handlePrev(){
        this.pageNumber = this.pageNumber-1;
        console.log('this.searchFlg'+this.searchFlg);
        if (this.searchFlg === '1') {
            //マスタ検索
            this.masterSearch();
        }else if (this.searchFlg === '2') {
            //画像検索
            this.imageSearch();
        }else if (this.searchFlg === '3') {
            //見積検索
            this.quoteSearch();
        }
    }

    masterSearch(){
        this.loader = true; //spinner表示制御⇒制御
        console.log('マスタ検索');
        console.log(this.intensifyRecords);
        var recordsJson = (this.intensifyRecords!=null&&this.intensifyRecords.length>0?JSON.stringify(this.intensifyRecords):null);
        //一覧データを検索する
        getPricingTableRecords({
            deviceId:this.recordId,
            bu:this.bu_Value,
            major:this.major_Value,
            minor:this.minor_Value,
            pageSize:this.pageSize,
            pageNumber:this.pageNumber,
            intensifyRecords:recordsJson
        }).then(result => {
            var resultData = JSON.parse(result);
            //一覧情報の設定
            this.detailRecords = resultData.records;
            this.isDisplayNoRecords= true;//[No records found]表示要否
            //明細データがありの場合利用可にする
            if (this.detailRecords){
                if(this.detailRecords.length>0){
                    this.isDisplayNoRecords= false;//[No records found]表示要否
                }
            }
            this.intensifyRecords = resultData.intensifyRecords;
            //ページ情報の設定
            this.pageNumber = resultData.pageNumber;
            this.totalRecords = resultData.totalRecords;
            this.recordStart = resultData.recordStart;
            this.recordEnd = resultData.recordEnd;
            this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
            this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
            this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
            this.loader = false; //spinner表示制御
        });
    }


    //見積検索
    onQuoteSearch(){
        console.log('onQuoteSearch Start');
        var msg = '';
        if (!isNotEmpty(this.bu_Value)){
            msg = 'BU';
        }if (!isNotEmpty(this.quoteNumber_Value)){
            msg = '見積番号';
        }else if(!isNotEmpty(this.name_Value)){
            msg = '見積項目名';
        }

        //未選択された場合、エラーとする。
        if (isNotEmpty(msg)) {
            const errEvent = new ShowToastEvent({
                title: '',
                message: msg + 'を選択してください。',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
        }else {
            //一覧状態をクリア
            this.clearTableList();
            this.searchFlg = '3';
            //見積検索
            this.quoteSearch();
        }
    }

    //見積検索
    quoteSearch(){
        this.loader = true; //spinner表示制御⇒制御
        var recordsJson = (this.intensifyRecords!=null && this.intensifyRecords.length>0?JSON.stringify(this.intensifyRecords):null);
        console.log(recordsJson);
        getDetailTableRecords({
            nameId:this.name_Value,
            pageSize:this.pageSize,
            pageNumber:this.pageNumber,
            intensifyRecords:recordsJson
        }).then(result => {
            var resultData = JSON.parse(result);
            //一覧情報の設定
            this.detailRecords = resultData.records;
            this.isDisplayNoRecords= true;//[No records found]表示要否
            //明細データがありの場合利用可にする
            if (this.detailRecords){
                if(this.detailRecords.length>0){
                    this.isDisplayNoRecords= false;//[No records found]表示要否

                    this.intensifyRecords = resultData.intensifyRecords;
                    //ページ情報の設定
                    this.pageNumber = resultData.pageNumber;
                    this.totalRecords = resultData.totalRecords;
                    this.recordStart = resultData.recordStart;
                    this.recordEnd = resultData.recordEnd;
                    this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                    this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                    this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
                    console.log(this.intensifyRecords);
                    //親へ送信
                    const passEvent = new CustomEvent('quantitychange', {
                        detail:{intensifyRecords:this.intensifyRecords} 
                    });
                    this.dispatchEvent(passEvent);
                }
            }
            this.loader = false; //spinner表示制御
        });
    }

//--------------------図記号検索画面--------------------------
    //図記号検索画面　開く
    onImageMarkSearch(){
        console.log('onImageMarkSearch Start');
        
        this.soSelectList = [];

        getSymbolObjectRecords()
        .then(result => {
            var resultData = JSON.parse(result);
            console.log(resultData);
            //明細データがありの場合利用可にする
            resultData.forEach((item) => {
                var imgUrl = item.SymbolID;
                imgUrl = symbolObject +'/' + imgUrl;
                item.SymbolID = imgUrl;
            });

            this.symbolObjectList = resultData;
            this.isShowImageMark = true;
        });

    //    }
    }
    //図記号検索画面　閉じる
    handlerShowImageClose(){
        this.soSelectList = [];
        this.isShowImageMark = false;
    }
    //選択　チェックボックス　OnClick()
    handlerCheckBoxChange(evt){
        console.log('onImageMarkSearch Start');
        var val = evt.target.checked;
        var id = evt.currentTarget.dataset.id;
        //外すの場合、保持リストから要素削除
        if (this.soSelectList.includes(id) && !val) {
            var index = this.soSelectList.indexOf(id);
            this.soSelectList.splice(index, 1); 
        //チェックオンの場合、保持リストに追加
        }else if (!this.soSelectList.includes(id) && val) {
            this.soSelectList.push(id);
        }
        console.log(this.soSelectList);
    }

    //画像検索
    handlerImageSearch(){
        console.log('handlerImageSearch Start');

        //「選択」チェックボックスが1件も選択されていない場合
        if(this.soSelectList===null 
            || this.soSelectList === undefined 
            || this.soSelectList.length===0){
            const errEvent = new ShowToastEvent({
                title: '',
                message: 'データを選択してください。',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
        }else {
            //一覧状態をクリア
            this.clearTableList();
            this.searchFlg = '2';
            //画像検索
            this.imageSearch();
        }
    }

    //画像
    imageSearch(){
        console.log('handlerImageSearch Start');

        console.log(this.soSelectList);
        var recordsJson = (this.intensifyRecords!=null&& this.intensifyRecords.length>0?JSON.stringify(this.intensifyRecords):null);
        console.log(recordsJson);
        this.loader = true; //spinner表示制御⇒制御
        getPricingTableRecordsByImage({
            deviceId:this.recordId,
            mdtIdList:this.soSelectList,
            pageSize:this.pageSize,
            pageNumber:this.pageNumber,
            intensifyRecords:recordsJson

        }).then(result => {
            var resultData = JSON.parse(result);
            //一覧情報の設定
            this.detailRecords = resultData.records;
            this.isDisplayNoRecords= true;//[No records found]表示要否
            //明細データがありの場合利用可にする
            if (this.detailRecords){
                if(this.detailRecords.length>0){
                    this.isDisplayNoRecords= false;//[No records found]表示要否
                    this.isWeight = (!isNotEmpty(resultData.bu_Value) || resultData.bu_Value==='S'?false:true);;//施設、水環境、官需
                }
            };

            this.intensifyRecords = resultData.intensifyRecords;
            //ページ情報の設定
            this.pageNumber = resultData.pageNumber;
            this.totalRecords = resultData.totalRecords;
            this.recordStart = resultData.recordStart;
            this.recordEnd = resultData.recordEnd;
            this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
            this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
            this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
            
            //図記号検索画面を閉じる
            this.isShowImageMark = false;
            this.loader = false; //spinner表示制御
        });
    }


//--------------------図記号検索画面--------------------------

    //単位WCが変更された場合
    handleCreditWCChange(event){
        let objName = event.currentTarget.dataset.id;//Id@CreditWC
        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        // 項目チェック
        let validity = event.target.validity;
        if (!validity.valid) {
            let validationMessage = event.target.validationMessage;
            const errEvent = new ShowToastEvent({
                title: validationMessage,
                message: event.target.title,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
            objInput.value='';
            return;
        }

        const ids = objName.split('@');
        let idChanged = ids[0];
        this.calDetailRecords(idChanged);
        //親へ送信
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
           
    }
    //WC係数が変更された場合
    handleWCCoefficientChange(event){
        let objName = event.currentTarget.dataset.id;//Id@WCCoefficient
        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');

        //仮　項目チェック
        let validity = event.target.validity;
        if (!validity.valid) {
            let validationMessage = event.target.validationMessage;
            const errEvent = new ShowToastEvent({
                title: validationMessage,
                message: event.target.title,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
            objInput.value='';
            return;
        }


        const ids = objName.split('@');
        let idChanged = ids[0];
        this.calDetailRecords(idChanged);
        //親へ送信
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
    }

    //単価係数が変更された場合
    handleUnitPriceCoefficientChange(event){
        let objName = event.currentTarget.dataset.id;//Id@UnitPriceCoefficient
        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        //項目チェック
        let validity = event.target.validity;
        if (!validity.valid) {
            let validationMessage = event.target.validationMessage;
            const errEvent = new ShowToastEvent({
                title: validationMessage,
                message: event.target.title,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
            objInput.value='';
            return;
        }

        const ids = objName.split('@');
        let idChanged = ids[0];
        this.calDetailRecords(idChanged);
        //親へ送信
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
    }

    //提供単価が変更された場合
    handleProvisionUnitPriceChange(event){
        let objName = event.currentTarget.dataset.id;//Id@ProvisionUnitPrice

        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        //項目チェック
        let validity = event.target.validity;
        if (!validity.valid) {
            let validationMessage = event.target.validationMessage;
            const errEvent = new ShowToastEvent({
                title: validationMessage,
                message: event.target.title,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
            objInput.value='';
            return;
        }

        const ids = objName.split('@');
        let idChanged = ids[0];
        this.calDetailRecords(idChanged);
        //親へ送信
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
    }

    //数量が変更された場合
    handleQuantityChange(event){
        let objName = event.currentTarget.dataset.id;//Id@Quantity

        const ids = objName.split('@');
        let idChanged = ids[0];
        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        //数量が全角入力された際に半角に変換する 2023/06/01 TS木佐貫
        objInput.value = objInput.value.replace(/[０-９．]/g, function(s) {
            return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
        });

        //仮　項目チェック
        let validity = event.target.validity;
        if (!validity.valid) {
            let validationMessage = event.target.validationMessage;
            const errEvent = new ShowToastEvent({
                title: validationMessage,
                message: event.target.title,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
            objInput.value='';
            return;
        }

        this.calDetailRecords(idChanged);
        //親へ送信
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
    }


    //入力内容により、各価格を計算する
    calDetailRecords(idChanged){
        let quantityObjName = idChanged+'@Quantity';
        var objInput=this.template.querySelector('input[data-id="'+quantityObjName+'"]');
        var quantity = objInput.value;
        let unitPrice = objInput.dataset.name;//単価
        let unitWeight = objInput.dataset.weight;//単位重量
        //当行のデータを再計算
        var detailRecords = this.detailRecords;
        for(var j=0; j<detailRecords.length; j++) {
            var idRecord = detailRecords[j]['Id'];
            if(idChanged === idRecord) {
                var detail = detailRecords[j];
                //各価格を計算する
                detailRecords[j] = this.calDetailRow(idChanged, quantity, unitPrice, unitWeight, detail);

                //内訳集約対象に追加
                this.addtoIntensifyRecords(detailRecords[j]);
            }
        }
        this.detailRecords=detailRecords;
    }

    //行単位で各価格を計算する
    calDetailRow(idChanged, quantity, unitPrice, unitWeight, detail){
        
        let creditWCObjName = idChanged + '@CreditWC';//単位WCコンポの名称
        let wcObjName = idChanged + '@WCCoefficient';//WC係数コンポの名称
        let priceObjName = idChanged + '@UnitPriceCoefficient';//価格係数コンポの名称
        let provisionPriceObjName = idChanged + '@ProvisionUnitPrice';//提供価格コンポの名称
        //Input 係数入力のコンポ
        var creditWCObj=this.template.querySelector('input[data-id="'+creditWCObjName+'"]');
        var wcInObj=this.template.querySelector('input[data-id="'+wcObjName+'"]');
        var priceIntObj=this.template.querySelector('input[data-id="'+priceObjName+'"]');
        var provisionPriceInObj=this.template.querySelector('input[data-id="'+provisionPriceObjName+'"]');

        //マスタに単価が入っておらず名称2に「EP=WC×◯」と記載されており、
        //更にWC算出レートが設定されているマスタが100件程度存在しています。
        if (!isNotEmpty(unitPrice) && isNotEmpty(creditWCObj.dataset.rate)) {
            if (!isNotEmpty(creditWCObj.value)) {
                const event = new ShowToastEvent({
                    title: '入力エラー',
                    message: 'WC単価が必須です、WC単価を入力してください。',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                // return;
                var price = '';
            }else {
                //価格を計算する
                var price = priceCalculator({
                    UnitPrice__c: creditWCObj.value,
                    Quantity__c: quantity,
                    Coefficient__c: creditWCObj.dataset.rate
                });
            }
            //WCを計算する
            var wcPrice = '';

        }else {
            //WC係数が入力された場合、WC価格が優先です。
            if (isNotEmpty(wcInObj) && isNotEmpty(wcInObj.value)) {
                //価格を計算する
                var price = priceCalculator({
                    UnitPrice__c: creditWCObj.value,
                    Quantity__c: quantity,
                    Coefficient__c: wcInObj.value
                });
            }else{
                //価格を計算する
                var price = priceCalculator({
                    UnitPrice__c: unitPrice,
                    Quantity__c: quantity,
                    Coefficient__c: priceIntObj.value
                });
            }
            //WCを計算する
            var wcPrice = priceCalculator({
                UnitPrice__c: creditWCObj.value,
                Quantity__c: quantity,
                Coefficient__c: null
            });
        }

        //水環境、官需の場合
        if (this.isWeight) {
            //重量を計算する
            var weihgt = priceCalculator({
                UnitPrice__c: unitWeight,
                Quantity__c: quantity,
                Coefficient__c: null
            });
        }else{
            //提供価格を計算する
            var provisionPrice = priceCalculator({
                UnitPrice__c: provisionPriceInObj.value,
                Quantity__c: quantity,
                Coefficient__c: null
            });
        }

        //計算結果を設定
        detail['Quantity']=quantity;
        detail['QuantitySpan']=(isNotEmpty(quantity)?Number(quantity).toLocaleString():'');
        detail['CreditWC']=creditWCObj.value;
        detail['CreditWCSpan']=(isNotEmpty(creditWCObj.value)?Number(creditWCObj.value).toLocaleString():'');
        detail['WCCoefficient']=wcInObj.value;
        detail['UnitPriceCoefficient']=priceIntObj.value;
        detail['ProvisionUnitPrice']= isNotEmpty(provisionPriceInObj)?provisionPriceInObj.value:'';
        detail['ProvisionUnitPriceSpan']=(isNotEmpty(provisionPriceInObj)&&isNotEmpty(provisionPriceInObj.value)?Number(provisionPriceInObj.value).toLocaleString():'');
        detail['UnitWeight']=unitWeight;
        detail['UnitWeightSpan']=(isNotEmpty(unitWeight)?Number(unitWeight).toLocaleString():'');
        detail['WC']=wcPrice;
        detail['Price']=price;
        detail['ProvisionPrice']=provisionPrice;
        detail['Weight']=weihgt;
        return detail;
    }


    //一覧の入力値を一時保存
    addtoIntensifyRecords(detail){

        var intensifyRecords = this.intensifyRecords;
        var idChanged = detail['Id'];//Id
        var isNotIn = true;//既存には存在しない

        var quantity = (isNotEmpty(detail['Quantity'])?detail['Quantity']:null);
        var wCCoefficient = (isNotEmpty(detail['WCCoefficient'])?detail['WCCoefficient']:null);
        var creditWC = (isNotEmpty(detail['CreditWC'])?detail['CreditWC']:null);
        var unitPriceCoefficient = (isNotEmpty(detail['UnitPriceCoefficient'])?detail['UnitPriceCoefficient']:null);
        var provisionUnitPrice = (isNotEmpty(detail['ProvisionUnitPrice'])?detail['ProvisionUnitPrice']:null);
        var UnitWeight = (isNotEmpty(detail['UnitWeight'])?detail['UnitWeight']:null);

        var wC = (isNotEmpty(detail['WC'])?detail['WC']:null);
        var price = (isNotEmpty(detail['Price'])?detail['Price']:null);
        var provisionPrice = (isNotEmpty(detail['ProvisionPrice'])?detail['ProvisionPrice']:null);
        var Weight = (isNotEmpty(detail['Weight'])?detail['Weight']:null);

        if (intensifyRecords!=null && intensifyRecords.length > 0) {
            //一時保存情報を最新化する
            intensifyRecords.forEach((item, index) => {
                var idRecord = item['Id'];
                //既存あり場合　入力データで更新
                if (idChanged === idRecord) {
                    isNotIn = false;
                    item['Quantity']=quantity;
                    item['WCCoefficient']=wCCoefficient;
                    item['CreditWC']=creditWC;
                    item['UnitPriceCoefficient']=unitPriceCoefficient;
                    item['ProvisionUnitPrice']=provisionUnitPrice;
                    item['UnitWeight']=UnitWeight;
                    item['WC']=wC;
                    item['Price']=price;
                    item['ProvisionPrice']=provisionPrice;
                    item['Weight']=Weight;
                }
            });
        }else{
            intensifyRecords=[];
        }

        //クリア対象外　かつ　既存には存在しない
        if (isNotIn) {
            //新規作成して intensifyRecordsに追加
            var newIntensify = {'Id':idChanged,
                            'Quantity':quantity,
                            'WCCoefficient':wCCoefficient,
                            'CreditWC':creditWC,
                            'UnitPriceCoefficient':unitPriceCoefficient,
                            'UnitWeight':UnitWeight,
                            'WC':wC,
                            'Price':price,
                            'ProvisionPrice':provisionPrice,
                            'Weight':Weight,
                        };
                            
            intensifyRecords.push(newIntensify);
        }
        this.intensifyRecords = intensifyRecords;
    }

    //-----------------------共通メソッド-----------------
    //一覧の制御をクリア
    clearTableList(){
        //一覧の制御をクリア
        this.isWeight = (!isNotEmpty(this.bu_Value) || this.bu_Value==='S'?false:true);;//施設、水環境、官需
        this.isDisplayNoRecords= false;//データなし エラー表示の制御
        this.detailRecords=[];//一覧表示するデータ
        this.intensifyRecords =[];
        this.pageSize = 500;//ページ毎に表示件数
        this.pageNumber = 1;//当前ページ
        this.totalRecords = 0;//データ数
        this.totalPages = 0;//ページ数
        this.recordEnd = 0;//ページ終了数
        this.recordStart = 0;//ページ開始数
        this.searchFlg = '';
        //親へ送信
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
    }
}