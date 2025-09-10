import { LightningElement, track, api, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RECORD_SEARCH_CHANNEL from '@salesforce/messageChannel/Record_Search__c';
import CONDITION_CHANGE_CHANNEL from '@salesforce/messageChannel/Condition_Change__c';
import QUOTATION_DESCRIPTION_RESOURCE from '@salesforce/resourceUrl/QuotationDescription';
import QUOTATION_DESCRIPTION_RESOURCE2 from '@salesforce/resourceUrl/QuotationDescription2';
import MAJOR_CLASSIFICATION_FIELD from '@salesforce/schema/Device__c.MajorClassification__c';
import getPricingTableRecords from '@salesforce/apex/DetailController.getPricingTableRecords';
import getPricingTableByintensify from '@salesforce/apex/DetailController.getPricingTableByintensify';
//import containsEVT_PT_LA from '@salesforce/apex/DetailsAddController.containsEVT_PT_LA';
import containsEVT_PT_LA from '@salesforce/apex/DetailController.containsEVT_PT_LA';
import { isNotEmpty } from 'c/commonUtil';
import Quantity from '@salesforce/schema/Asset.Quantity';
import QuantityUnitOfMeasure from '@salesforce/schema/Product2.QuantityUnitOfMeasure';

export default class SearchDatatable extends LightningElement {

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
    @track detailRecords = [];//一覧表示内容
    @track intensifyRecords = [];//集約対象一覧
    @track newRecords=[];//新規追加行の一覧

    //検索条件
    @track searchTerm = '';//検索分類（仕様検索：SpecSearch、コード検索：CodeSearch、名称検索：NameSearch）
    @track specificationNames = [];//仕様検索条件
    @track boardNames = [];//盤検索条件
    @track specificationNameDisplay  = '';//仕様検索条件の画面表示
    @track searchCodes = [];//コード検索条件
    @track searchName = [];//名称検索条件

    @track oldSearchConditions=[];//検索条件を退避

    @track deviceName = '';//機器名
    @track device;//機器

	@track isInputOnly = false;//内訳集約の利用可否
	@track isAll = true;//内訳解除の利用可否
	@track isCreate = false;//行追加の利用可否
    @track isDisplayNoRecords = false;//[No records found]表示要否

    //水環境、官需BUでの高圧盤などの入力時に内訳入力の「提供価格」欄が、「重量」に替わる
    @track isWeight;//単位重量 列を表示する

    //画面初期処理
    connectedCallback() {
        this.clearParentObj();
        //一覧検索
        this.getPricingTable(true);
        //search 購読(Subscribe)する
        this.subscribeToMessageChannelOnsearch();
        //change 購読(Subscribe)する
        this.subscribeToMessageChannelOnChange();
	}

//------------------機器説明画面------------------
    @track isShowDescription =false;
    async  handleShowAlert(){
        this.isShowDescription = true;
    }
    handlerClose(){
        this.isShowDescription = false;
    }
//------------------機器説明画面------------------
    //一般管理費		
    @track expense_LabelName = '一般管理費';
    @track expense_Options = [
        {label:'あり', value:true, selected :false},
        {label:'なし', value:false, selected :false}
    ];
	@track expense_SelectedOption;//選択値
	@track expense_isRequired = false;//必須の場合 Trueで設定

    //一般管理費が変わると、変わった値を一時保存、親に送信
    expense_Handler(event) {
        //変わった値を一時保存
        this.expense_SelectedOption = event.target.value;
        this.device.GeneralAdminExpensesExistence__c=(event.target.value=='true'?true:false);
        //合計計算
        this.setTotalPrice();
        //親に送信
		this.dispatchEvent(new CustomEvent('expensechange', {
			detail: {selectedOption:this.expense_SelectedOption} 
		}));
	}
    //内訳集約ボタンの処理
    handleDisplayInputOnly(event) {
        var recordsJson = (this.intensifyRecords!=null?JSON.stringify(this.intensifyRecords):null);
        var newRecordsJson = (this.newRecords!=null?JSON.stringify(this.newRecords):null);

        //spinner表示制御
        this.loader = true;
        //検索Apexを呼び出し
        getPricingTableByintensify({
            intensifyRecords: recordsJson,
            newRecords:newRecordsJson
        }).then(result => {
            this.loader = false; //spinner表示制御⇒解除
            if(result){
                var resultData = JSON.parse(result);
                //一覧情報の設定
                this.detailRecords = resultData.records;
                //集約対象リスト
                this.intensifyRecords = resultData.intensifyRecords;
                this.dispatchEvent(new CustomEvent('quantitychange', {
                    detail: {intensifyRecords:this.intensifyRecords} 
                }));
                //新規追加行の情報
                this.newRecords = resultData.newRecords;
                
                this.dispatchEvent(new CustomEvent('newrowchange', {
                    detail: {newRecords:this.newRecords} 
                }));
                //利用可否の制御
                this.isInputOnly= true;//内訳集約の利用可否
                this.isAll= false;//内訳解除の利用可否
                this.isCreate= true;//行追加の利用可否
                this.isDisplayNoRecords= true;//[No records found]表示要否
                //明細データがありの場合利用可にする
                if (this.detailRecords){
                    if(this.detailRecords.length>0){
                        this.isDisplayNoRecords= false;//[No records found]表示要否
                    }
                }
                this.isNext = true;
                this.isPrev = true;
            }
        })
        .catch(error => {
            this.loader = false;
            this.error = error;
        });


    }
    //内訳解除ボタンの処理
    handleDisplayAll(event) {
        //検索Apexを呼び出し
        var oldSearchConditions = this.oldSearchConditions;
        //一覧検索
        this.getPricingTable(false);
        this.oldSearchConditions = oldSearchConditions;
    }
    //行追加処理
    handleRowCreate(){
        var detailRecords = this.detailRecords;
        if(detailRecords==undefined || detailRecords==null)detailRecords=[];
        var rowIndex = detailRecords.length + 1;//最後に一行を追加
        var pageNumber = this.pageNumber;
        var newId = pageNumber+'rowIndex'+rowIndex;
        var isCreate = {Id:newId,//Id:pageNumber+'rowIndex'+rowIndex
                        Name1:null,//名称１
                        Name2:null,//名称２
                        Name3:null,//名称３
                        CreditWC:null,//単位WC ※入力
                        CreditWCName:newId+'@CreditWC',//単位WC　識別Id
                        WCCoefficient:null,//WC係数
                        WCCoefficientName:newId+'@WCCoefficient',//WC係数　識別Id
                        UnitPrice:null,//単価
                        UnitPriceCoefficient:null,//単価係数
                        UnitPriceCoefficientName:newId+'@UnitPriceCoefficient',//単価係数　識別Id
                        ProvisionUnitPrice:null,//提供単価
                        ProvisionUnitPriceName:newId+'@ProvisionUnitPrice',//提供単価　識別Id
                        UnitWeight:null,//単位重量
                        UnitWeightName:newId+'@UnitWeight',//単位重量　識別Id
                        Quantity:null,//数量
                        QuantityName:newId+'@Quantity',//数量　識別Id
                        WC:null,//WC
                        Price:null,//価格
                        ProvisionPrice:null,//提供価格
                        Weight:null,//重量
                        Note:null,//備考
                        Name4:null,//名称４
                        isCreate:true};
        //一覧の最後に追加
        detailRecords.unshift(isCreate);
        this.detailRecords=detailRecords;
        this.isDisplayNoRecords=false;//データなしのメッセージを非表示
    }

    // 数量を全てクリアする
    clearAllQuantity() {
        //一時情報をクリア。
        this.intensifyRecords.forEach((item) => {
            //数量をクリア
            if(isNotEmpty(item.Quantity))item.Quantity=null;
            //数量より計算された合計をクリア
            if(isNotEmpty(item.WC))item.WC=null;
            if(isNotEmpty(item.Price))item.Price=null;
            if(isNotEmpty(item.ProvisionPrice))item.ProvisionPrice=null;
            if(isNotEmpty(item.Weight))item.Weight=null;
        });
        //集約対象リストを送信
        this.dispatchEvent(new CustomEvent('quantitychange', {
            detail: {intensifyRecords:this.intensifyRecords} 
        }));
        //新規レコードの一時情報をクリア
        this.newRecords.forEach((item) => {
            //数量をクリア
            if(isNotEmpty(item.Quantity))item.Quantity=null
            //数量より計算された合計をクリア
            if(isNotEmpty(item.WC))item.WC=null;
            if(isNotEmpty(item.Price))item.Price=null;
            if(isNotEmpty(item.ProvisionPrice))item.ProvisionPrice=null;
            if(isNotEmpty(item.Weight))item.Weight=null;

        });
        //新規追加行情報を送信
        this.dispatchEvent(new CustomEvent('newrowchange', {
            detail: {newRecords:this.newRecords} 
        }));
        //一覧表示データをクリア
        this.detailRecords.forEach((item) => {
            //数量をクリア
            if(isNotEmpty(item.Quantity)){
                item.Quantity=null;
                if(isNotEmpty(item.QuantitySpan))item.QuantitySpan='';
                //各価格を計算する
                item = this.calDetailRow(item.Id, item.Quantity, item.UnitPrice, item.UnitWeight, item.ProvisionPrice, item);
                //内訳集約対象に各計算値を更新
                this.addtoIntensifyRecords(item);//計算後
            }

        });
        //合計金額エリアを再計算
        this.setTotalPrice();

    }

    //新規行の入力内容を一時保存
    handleNewRow(event){
  
        let objName = event.currentTarget.dataset.rowindex;//Id:pageNumber+'rowIndex'+rowIndex

        let validity = event.target.validity;
        //WC単価、WC係数、単価係数、数量が全角入力された際に半角に変換する 2023/11/10
        if(event.target.name=='CreditWC'  //WC単価
         || event.target.name=='WCCoefficient' //WC係数
         || event.target.name=='UnitPriceCoefficient' //単価係数
         || event.target.name =='Quantity') {     //数量
            if (isNotEmpty(event.target.value)) {
                event.target.value=event.target.value.replace(/[０-９．]/g, function(s) {
                    return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
                });
            }
         }

        if (!validity.valid) {
            let validationMessage = event.target.validationMessage;
            const errEvent = new ShowToastEvent({
                title: validationMessage,
                message: event.target.title,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
            event.target.value='';
            // return;
        }
       
        var newRowObjs=this.template.querySelectorAll('input[data-rowindex="'+objName+'"]');
        //行単位で入力内容を取得
        var Name1,Name2,Name3,CreditWC,
            WCCoefficient,UnitPrice,UnitWeight,UnitPriceCoefficient,
            ProvisionUnitPrice,Quantity,Note,Name4,WC,Price,ProvisionPrice,Weight;
        newRowObjs.forEach((item) => {
            var itemVal = (isNotEmpty(item.value)?item.value:null);
            if(item.name==='Name1')Name1=itemVal;
            if(item.name==='Name2')Name2=itemVal;
            if(item.name==='Name3')Name3=itemVal;
            if(item.name==='CreditWC') CreditWC=itemVal;
            if(item.name==='WCCoefficient')WCCoefficient=itemVal;
            if(item.name==='UnitPrice')UnitPrice=itemVal;
            if(item.name==='UnitPriceCoefficient')UnitPriceCoefficient=itemVal;
            if(item.name==='ProvisionUnitPrice')ProvisionUnitPrice=itemVal;
            if(item.name==='UnitWeight')UnitWeight=itemVal;
            //数量が全角入力された際に半角に変換する 2023/04/26 TS鈴木
            if(item.name==='Quantity'){
                if (isNotEmpty(itemVal)) {
                    Quantity=itemVal.replace(/[０-９．]/g, function(s) {
                        return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
                    });
                }else {
                    Quantity=null;
                }
            }
            if(item.name==='Note')Note=itemVal;
            if(item.name==='Name4')Name4=itemVal;
        });

        //表示一覧に設定
        //当行のデータを再計算
        var detailRecords = this.detailRecords;
        for(var j=0; j<detailRecords.length; j++) {
            var idRecord = detailRecords[j]['Id'];
            //Id一致する行に　入力値を設定
            if(objName === idRecord) {
                var detail = detailRecords[j];
                //入力値を設定
                detail.Name1 = Name1;
                detail.Name2 = Name2;
                detail.Name3 = Name3;
                detail.CreditWC = CreditWC;
                detail.WCCoefficient = WCCoefficient;
                detail.UnitPrice = UnitPrice;
                detail.UnitPriceSpan = (isNotEmpty(UnitPrice)?Number(UnitPrice).toLocaleString():'');
                detail.UnitPriceCoefficient = UnitPriceCoefficient;
                detail.ProvisionUnitPrice = ProvisionUnitPrice;
                detail.UnitWeight = UnitWeight;
                detail.Quantity = Quantity;
                detail.Note = Note;
                detail.Name4 = Name4;
                //各価格を計算する
                detail= this.calDetailRow(objName, Quantity, UnitPrice, UnitWeight, ProvisionUnitPrice, detail);
                detailRecords[j]=detail;
                //内訳集約対象に追加
                this.addtoIntensifyRecords(detailRecords[j]);
                break;
            }
        }
        this.detailRecords=detailRecords;
        this.dispatchEvent(new CustomEvent('quantitychange', {
            detail: {intensifyRecords:this.intensifyRecords} 
        }));

        //合計金額エリアを検索
        this.setTotalPrice();
        //新規追加レコード情報に追加
        var newRecords = this.newRecords;
        var isNotIn = true;
        WC = (detail!=null&&isNotEmpty(detail.WC)?detail.WC:null);
        Price = (detail!=null&&isNotEmpty(detail.Price)?detail.Price:null);
        ProvisionPrice = (detail!=null&&isNotEmpty(detail.ProvisionPrice)?detail.ProvisionPrice:null);
        Weight = (detail!=null&&isNotEmpty(detail.Weight)?detail.Weight:null);

        if (newRecords!=null && newRecords.length>0) {
            for(var j=0; j<newRecords.length; j++) {
                var idRecord = newRecords[j]['Id'];
                //Id一致する行に　入力値を設定
                if(objName === idRecord) {
                    isNotIn = false;
                    var newRow = newRecords[j];
                    newRow.Name1 = Name1;
                    newRow.Name2 = Name2;
                    newRow.Name3 = Name3;
                    newRow.CreditWC = CreditWC;
                    newRow.WCCoefficient = WCCoefficient;
                    newRow.UnitPrice = UnitPrice;
                    newRow.UnitPriceCoefficient = UnitPriceCoefficient;
                    newRow.ProvisionUnitPrice = ProvisionUnitPrice;
                    newRow.UnitWeight = UnitWeight;
                    newRow.Quantity = Quantity;
                    newRow.WC = WC;
                    newRow.Price = Price;
                    newRow.ProvisionPrice = ProvisionPrice;
                    newRow.Weight = Weight;
                    newRow.Note = Note;
                    newRow.Name4 = Name4;
                    newRecords[j]=newRow;
                }

            }
        }else {
            newRecords=[];
        }
        if (isNotIn){//存在しない場合、新規追加
            var newRow = {
                'isCreate' : true,
                'Id' : objName,
                'Name1' : Name1,
                'Name2' : Name2,
                'Name3' : Name3,
                'CreditWC' : CreditWC,
                'WCCoefficient' : WCCoefficient,
                'UnitPrice' : UnitPrice,
                'UnitPriceCoefficient' : UnitPriceCoefficient,
                'ProvisionUnitPrice' : ProvisionUnitPrice,
                'UnitWeight' : UnitWeight,
                'Quantity' : Quantity,
                'WC' : WC,
                'Price' : Price,
                'ProvisionPrice' : ProvisionPrice,
                'Weight' : Weight,
                'Note' : Note,
                'Name4' : Name4};
            newRecords.push(newRow);
        }
        this.newRecords = newRecords;
        this.dispatchEvent(new CustomEvent('newrowchange', {
            detail: {newRecords:this.newRecords} 
        }));

    }
    //単価　＊　数量　＝　価格
    priceCalculator(values) {
        var coefficient = values['Coefficient__c'];
        //単価　＊　数量
        var price = parseFloat(values['UnitPrice__c']) * parseFloat(values['Quantity__c']);
        if (Number.isNaN(price)){
            price = '';
        }
        //係数がある場合
        //価格　＊　係数
        if (isNotEmpty(coefficient)) {
            price=parseInt(price) * parseFloat(coefficient);
            if (Number.isNaN(price)){
                price = '';
            }else{
                price =parseInt(price);
            }
        }
        return price;
    }

    //検索の共通
    getPricingTable(isReflash){
        //spinner表示制御
        this.loader = true;

        var searchConditions;
        var recordsJson;
        var newRecordsJson;
        //検索ボタン、画面初期を行う
        if (isReflash){
            searchConditions ={      //画面指定の検索条件
                specificationNames: this.specificationNames,//仕様１～５
                boardNames:this.boardNames,
                searchCodes: this.searchCodes,//コード１～４
                searchName: this.searchName   //名称
            }
            recordsJson =null;
            newRecordsJson=null;
        //前ページ、次ページ、内訳解除
        } else {
            searchConditions =this.oldSearchConditions;
            recordsJson = (this.intensifyRecords!=null?JSON.stringify(this.intensifyRecords):null); 
            newRecordsJson = (this.newRecords!=null?JSON.stringify(this.newRecords):null); 
        }

        //検索Apexを呼び出し
        getPricingTableRecords({
            searchTerm: this.searchTerm,//検索種別
            recordId: this.recordId,//機器Id
            pageSize: this.pageSize,
            pageNumber : this.pageNumber,
            searchConditions: searchConditions,
            intensifyRecords : recordsJson,
            newRecords : newRecordsJson
        }).then(result => {
            this.loader = false; //spinner表示制御⇒解除
            if(result){
                var resultData = JSON.parse(result);
                //一覧情報の設定
                this.detailRecords = resultData.records;
                //集約対象リスト
                this.intensifyRecords = resultData.intensifyRecords;
                this.dispatchEvent(new CustomEvent('quantitychange', {
                    detail: {intensifyRecords:this.intensifyRecords} 
                }));
                //新規追加行の情報
                this.newRecords = resultData.newRecords;
                this.dispatchEvent(new CustomEvent('newrowchange', {
                    detail: {newRecords:this.newRecords} 
                }));
                if (isReflash) {


                    //検索時点の検索条件を保存
                    this.oldSearchConditions={
                        specificationNames: this.specificationNames,//仕様１～５
                        boardNames:this.boardNames,
                        searchCodes: this.searchCodes,//コード１～４
                        searchName: this.searchName   //名称
                    }

                    //機器情報設定
                    this.device = resultData.device;   //機器情報
                    this.isWeight = false;//施設の場合
                    if (resultData.quoteRecordType && resultData.quoteRecordType!=='Facility') {
                        this.isWeight=true;//水環境、官需の場合
                    }

                    this.deviceName = this.device.Name;
                    //一般管理費の設定
                    this.expense_Options.forEach((item) => {
                        if (item.value ==this.device.GeneralAdminExpensesExistence__c){
                            item.selected = true;
                            this.expense_SelectedOption = this.device.GeneralAdminExpensesExistence__c;
                            this.dispatchEvent(new CustomEvent('expensechange', {
                                detail: {selectedOption:this.expense_SelectedOption} 
                            }));
                        }
                    });
                    //合計計算
                    this.setTotalPrice();
                }

                //利用可否の制御
                this.isInputOnly= false;//内訳集約の利用可否
                this.isCreate= false;//行追加の利用可否
                this.isAll = true;//内訳解除の利用可否
                this.isDisplayNoRecords= true;//[No records found]表示要否
                //明細データがありの場合利用可にする
                if (this.detailRecords){
                    if(this.detailRecords.length>0){
                        // this.isInputOnly= false;//内訳集約の利用可否
                        // this.isCreate= false;//行追加の利用可否
                        this.isDisplayNoRecords= false;//[No records found]表示要否
                    }
                }
                
                //ページ情報の設定
                this.pageNumber = resultData.pageNumber;
                this.totalRecords = resultData.totalRecords;
                this.recordStart = resultData.recordStart;
                this.recordEnd = resultData.recordEnd;
                this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
            }
        })
        .catch(error => {
            this.loader = false;
            this.error = error;
        });
    }
    //次ページへ遷移　の動作
    handleNext(){
        this.pageNumber = this.pageNumber+1;
        var oldSearchConditions = this.oldSearchConditions;
        //一覧検索
        this.getPricingTable(false);
        this.oldSearchConditions = oldSearchConditions;

    }
 
    //前ページへ遷移　の動作
    handlePrev(){
        this.pageNumber = this.pageNumber-1;
        var oldSearchConditions = this.oldSearchConditions;
        //一覧検索
        this.getPricingTable(false);
        this.oldSearchConditions = oldSearchConditions;
    }

    //画面の検索ボタンを押下する場合
    //（仕様検索：SpecSearch、コード検索：CodeSearch、名称検索：NameSearch）
    search(event) {
        this.pageSize = 500;
        this.pageNumber = 1;
        //内訳A
        if(event.conditionPattern === 'A') {
            //仕様１～４より検索
            if(event.searchTerm === 'SpecSearch') {
                this.searchTerm = event.searchTerm;
                this.specificationNames = event.names;
                if (event.boardNames) {
                    this.boardNames = event.boardNames;
                }
                this.specificationNameDisplay = '';//最新化
                //画面表示内容を設定
                this.specificationNames.forEach( (item)=> {
                    if(isNotEmpty(item)){
                        this.specificationNameDisplay += (item+'、');
                    }
                });
                if (isNotEmpty(this.specificationNameDisplay) && this.specificationNameDisplay.length>0){
                    this.specificationNameDisplay = this.specificationNameDisplay.slice(0,this.specificationNameDisplay.length-1);
                }
                this.clearParentObj();
                //一覧検索
                this.getPricingTable(true);
            //コードにより検索
            } else if (event.searchTerm === 'CodeSearch') {
                this.searchTerm = event.searchTerm;
                this.searchCodes = event.codes;
                var isNotBlank=false;
                //画面表示内容を設定
                this.searchCodes.forEach( (item)=> {
                    if (isNotEmpty(item)){
                        isNotBlank=true;
                    }
                });
                //検索条件がある場合
                if (isNotBlank) {
                    this.clearParentObj();
                    //一覧検索
                    this.getPricingTable(true);
                //入力なしの場合　エラーとする
                }else{
                    const event = new ShowToastEvent({
                        title: '',
                        message: 'コード条件を入力してください。',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }

            //名称により検索
            } else if (event.searchTerm === 'NameSearch') {
                this.searchTerm = event.searchTerm;
                this.searchName = event.name;
                if (isNotEmpty(this.searchName)) {
                    this.clearParentObj();
                    //一覧検索
                    this.getPricingTable(true);
                }else {
                    const event = new ShowToastEvent({
                        title: '',
                        message: '名称検索条件を入力してください。',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }

            }
        }
    }
    //単位WCが変更された場合
    handleCreditWCChange(event){
        let objName = event.currentTarget.dataset.id;//Id@CreditWC
        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        //WCが全角入力された際に半角に変換する 2023/11/10
        objInput.value = objInput.value.replace(/[０-９．]/g, function(s) {
            return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
        });
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
            // return;
        }

        const ids = objName.split('@');
        let idChanged = ids[0];
        this.calDetailRecords(idChanged);
        this.setTotalPrice();
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
           
    }
    //WC係数が変更された場合
    handleWCCoefficientChange(event){
        let objName = event.currentTarget.dataset.id;//Id@WCCoefficient
        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        //WC係数が全角入力された際に半角に変換する 2023/11/10
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
            // return;
        }


        const ids = objName.split('@');
        let idChanged = ids[0];
        this.calDetailRecords(idChanged);
        this.setTotalPrice();
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
    }

    //単価係数が変更された場合
    handleUnitPriceCoefficientChange(event){
        let objName = event.currentTarget.dataset.id;//Id@UnitPriceCoefficient
        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        //単価係数が全角入力された際に半角に変換する 2023/11/10
        objInput.value = objInput.value.replace(/[０-９．]/g, function(s) {
            return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
        });
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
            // return;
        }

        const ids = objName.split('@');
        let idChanged = ids[0];
        this.calDetailRecords(idChanged);
        this.setTotalPrice();
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
    }
   //単価が変更された場合
    handleUnitPriceChange(event){
        let objName = event.currentTarget.dataset.id;
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
            // return;
        }
        const ids = objName.split('@');
        let idChanged = ids[0];
        // let quantityObjName = idChanged+'@Quantity';
        // var quantityObj=this.template.querySelector('input[data-id="'+quantityObjName+'"]');
        // quantityObj.dataset.name=objInput.value;//単価が数量のdatasetへ設定

        this.calDetailRecords(idChanged);
        this.setTotalPrice();
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
            // return;
        }
        const ids = objName.split('@');
        let idChanged = ids[0];
        this.calDetailRecords(idChanged);
        this.setTotalPrice();
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
    }

    //数量が変更された場合
    handleQuantityChange(event){
        console.log('handleQuantityChange Start');
        let objName = event.currentTarget.dataset.id;//Id@Quantity

        const ids = objName.split('@');
        let idChanged = ids[0];
        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        //数量が全角入力された際に半角に変換する 2023/04/26 TS鈴木
        objInput.value = objInput.value.replace(/[０-９．]/g, function(s) {
            return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
        });
        // 2024/02/20 TS田村 追記
        // if(idChanged.length == 22){
        //     idChanged = idChanged.slice(0, -4);
        // }
        containsEVT_PT_LA({pricingTableId: idChanged, quantity: objInput.value})
        .then(result => {
            console.log(result);
            if(result == true){
                const errEvent = new ShowToastEvent({
                    title: 'エラー',
                    message: '「LA」「VT、PT」「ZVT、GPT、EVT」「ネットワークVT」「ネットワークCT」に2以上は入力できません。',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(errEvent);
                var detailRecords = this.detailRecords;
                for(var i = 0; i < detailRecords.length; i++){
                    var detail = detailRecords[i];
                    if(detail.Id == idChanged){
                        detail['Quantity'] = '';
                        detail['QuantitySpan'] = '';
                        detail['Price'] = '';
                    }
                }
                }
            });

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
            // return;
        }

        this.calDetailRecords(idChanged);
        this.setTotalPrice();
        const passEvent = new CustomEvent('quantitychange', {
            detail:{intensifyRecords:this.intensifyRecords} 
        });
        this.dispatchEvent(passEvent);
    }
    //合計の計算
    setTotalPrice(){
        var wCTotal = 0;
        var total = 0;
        var provisionTotal = 0;
        var weightTotal = 0;

        var intensifyRecords= this.intensifyRecords;
        if (intensifyRecords!=null && intensifyRecords.length>0) {
            //入力されたデータの全部を対象とする。
            intensifyRecords.forEach((item) => {
            //数量が入力のデータをカウントする
            if (isNotEmpty(item.Quantity)){
                if (isNotEmpty(item.WC)) wCTotal = wCTotal+item.WC;//WC合計
                if (isNotEmpty(item.Price)) total = total+item.Price;//価格合計
                if (isNotEmpty(item.ProvisionPrice)) provisionTotal = provisionTotal+item.ProvisionPrice;//提供価格合計    
                if (isNotEmpty(item.Weight)) weightTotal = weightTotal+item.Weight;//重量         
            }
    
            });
        }
        //画面表示に設定
        var priceCoefficient = 1;
        //見積項目の価格係数PriceCoefficient__cを利用して計算
        if (isNotEmpty(this.device) && isNotEmpty(this.device.PriceCoefficient__c)) priceCoefficient = this.device.PriceCoefficient__c;
        this.wcTotal_Value = wCTotal;//WC金額
        this.totalAgencyPrice_Value = provisionTotal;//代理店提供価格合計⇒提供価格の合計を表示する
        this.totalWeight_Value = weightTotal;//重量合計
        this.standardPriceTotal_Value = total;//積算金額
        this.totalSellingBase_Value = this.priceCalculator({
                                            UnitPrice__c: total,
                                            Quantity__c: 1,
                                            Coefficient__c: priceCoefficient
                                        });//見積金額(ベース)⇒「積算金額×見積項目.価格係数」を表示する。
        this.expense_Value = this.orgCeil(this.calExpenseValue(this.totalSellingBase_Value),0.01);//一般管理費「積算金額×見積項目.価格係数×見積項目.一般管理費率/100」
        this.totalSellingCost_Value =this.totalSellingBase_Value+ this.expense_Value; //見積金額⇒「積算金額×見積項目.価格係数+一般管理費」を表示する。
        this.totalPrice_Value = this.orgCeil4(this.totalSellingCost_Value);//客先回答金額⇒見積金額を上位4桁目で切り上げた値を表示する。
    }
    //諸経費の計算
    calExpenseValue(total){
        var rate = this.device.GeneralAdministrativeExpensesCopy__c;
        var flag = this.device.GeneralAdminExpensesExistence__c;
        var expenseVal = 0;
        //一般管理費有無がチェックされた場合
        if (isNotEmpty(flag) && flag==true) {
            //価格　＊　率
            if (isNotEmpty(total)
                 && isNotEmpty(rate)) {
                expenseVal=parseInt(total) * parseFloat(rate/100);
                if (Number.isNaN(expenseVal)){
                    expenseVal = 0;
                }else{
                    expenseVal =parseInt(expenseVal);
                }
            }
        }
       return expenseVal;
    }

    //入力内容により、各価格を計算する
    calDetailRecords(idChanged){
        let quantityObjName = idChanged+'@Quantity';
        var objInput=this.template.querySelector('input[data-id="'+quantityObjName+'"]');
        var quantity = objInput.value;
        let unitPrice = objInput.dataset.name;//単価
        let unitWeight = objInput.dataset.weight;//単位重量
        let provisionUnitPrice = objInput.dataset.provision;//提供単価
        
        //当行のデータを再計算
        var detailRecords = this.detailRecords;
        for(var j=0; j<detailRecords.length; j++) {
            var idRecord = detailRecords[j]['Id'];
            if(idChanged === idRecord) {
                var detail = detailRecords[j];
                //各価格を計算する
                detailRecords[j] = this.calDetailRow(idChanged, quantity, unitPrice, unitWeight, provisionUnitPrice, detail);

                //内訳集約対象に追加
                this.addtoIntensifyRecords(detailRecords[j]);
            }
        }
        this.detailRecords=detailRecords;
    }

    //行単位で各価格を計算する
    calDetailRow(idChanged, quantity, unitPrice, unitWeight, provisionUnitPrice, detail){
        let creditWCObjName = idChanged + '@CreditWC';//単位WCコンポの名称
        let wcObjName = idChanged + '@WCCoefficient';//WC係数コンポの名称
        let priceObjName = idChanged + '@UnitPriceCoefficient';//価格係数コンポの名称
        let provisionPriceObjName = idChanged + '@ProvisionUnitPrice';//提供価格コンポの名称

        //単価入力可能の対応
        let unitPricObjName = idChanged + '@UnitPric';//単価コンポの名称
        var unitPricObj=this.template.querySelector('input[data-id="'+unitPricObjName+'"]');
        if (isNotEmpty(unitPricObj))unitPrice=unitPricObj.value;

        //Input 係数入力のコンポ
        var creditWCObj=this.template.querySelector('input[data-id="'+creditWCObjName+'"]');
        var wcInObj=this.template.querySelector('input[data-id="'+wcObjName+'"]');
        var priceIntObj=this.template.querySelector('input[data-id="'+priceObjName+'"]');
        var provisionPriceInObj=this.template.querySelector('input[data-id="'+provisionPriceObjName+'"]');

        //マスタに単価が入っておらず名称2に「EP=WC×◯」と記載されており、
        //更にWC算出レートが設定されているマスタが100件程度存在しています。
        if (isNotEmpty(creditWCObj.dataset.rate)) {
            if (!isNotEmpty(creditWCObj.value) && isNotEmpty(quantity)) {
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
                var price = this.priceCalculator({
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
                var price = this.priceCalculator({
                    UnitPrice__c: creditWCObj.value,
                    Quantity__c: quantity,
                    Coefficient__c: wcInObj.value
                });
            }else{
                //価格を計算する
                var price = this.priceCalculator({
                    UnitPrice__c: unitPrice,
                    Quantity__c: quantity,
                    Coefficient__c: priceIntObj.value
                });
            }

            //WCを計算する
            var wcPrice = this.priceCalculator({
                UnitPrice__c: creditWCObj.value,
                Quantity__c: quantity,
                Coefficient__c: null
            });
        }

        //水環境、官需の場合
        if (this.isWeight) {
            //重量を計算する
            var weihgt = this.priceCalculator({
                UnitPrice__c: unitWeight,
                Quantity__c: quantity,
                Coefficient__c: null
            });
        }else{
            //提供価格を計算する
            var provisionPrice = this.priceCalculator({
                UnitPrice__c: provisionUnitPrice,
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
        detail['ProvisionUnitPrice']= provisionUnitPrice;
        detail['ProvisionUnitPriceSpan']=(isNotEmpty(provisionUnitPrice)?Number(provisionUnitPrice).toLocaleString():'');
        detail['UnitWeight']=unitWeight;
        detail['UnitWeightSpan']=(isNotEmpty(unitWeight)?Number(unitWeight).toLocaleString():'');
        detail['WC']=wcPrice;
        detail['Price']=price;
        detail['ProvisionPrice']=provisionPrice;
        detail['Weight']=weihgt;

        //単価入力可能にする場合
        detail['UnitPrice']=unitPrice;
        detail['UnitPriceSpan']=(isNotEmpty(unitPrice)?Number(unitPrice).toLocaleString():'');
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
        //単価入力の場合
        var unitPrice = (isNotEmpty(detail['UnitPrice'])?detail['UnitPrice']:null);

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
                    item['UnitPrice']=unitPrice;//単価入力の場合
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
                            'UnitPrice':unitPrice,//単価入力の場合
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

    //選択中の条件を随時に表示する
    conditionChange(event) {
        this.specificationNames = event.names;
        this.specificationNameDisplay = '';//最新化
        //画面表示内容を設定
        this.specificationNames.forEach( (item)=> {
            if(isNotEmpty(item)){
                this.specificationNameDisplay += (item+'、');
            }
        });
        if (isNotEmpty(this.specificationNameDisplay)&&this.specificationNameDisplay.length>0){
            this.specificationNameDisplay = this.specificationNameDisplay.slice(0,this.specificationNameDisplay.length-1);
        }
    }

    @wire(MessageContext)
    messageContextOnsearch;
    //検索：購読subscribeする
    subscribeToMessageChannelOnsearch() {
        this.subscription = subscribe(
            this.messageContextOnsearch,
            RECORD_SEARCH_CHANNEL,
            (event) => this.search(event)
        );
    }

    @wire(MessageContext)
    messageContextOnChange;
    //条件変更：購読subscribeする
    subscribeToMessageChannelOnChange() {
        this.subscription = subscribe(
            this.messageContextOnChange,
            CONDITION_CHANGE_CHANNEL,
            (event) => this.conditionChange(event)
        );
    }

    //一覧：列幅を変更できるようにする
    @track mouseStart;
    @track oldWidth;
    //列幅の計算
    calculateWidth(event) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        var mouseStart=event.clientX;
        this.mouseStart = mouseStart;
        this.oldWidth = parObj.offsetWidth;
    }
    //列幅の設定
    setNewWidth (event) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        var mouseStart = this.mouseStart;
        var oldWidth = this.oldWidth;
        var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
        parObj.style.width = newWidth+'px';
    }

    /**
     * 任意の桁で切り上げする関数
     */
    orgCeil4(value) {
        let base = 1;
        let len = String(value).length - 3;
        let index = 1;
        for (let step = 0; step < len; step++) {
            base = base * 0.1;
            index = index * 10;
        }
        base = Math.round(base * index)/index;
        let newval = Math.floor(value * base * 10)/(base * 10);
        let newvalBase = Math.round(newval * base * index)/index;
        let rtn = Math.ceil(newvalBase) / base;

        return Math.round(rtn * index)/index;
    }
    /**
     * 任意の桁で切り上げする関数
     */
     orgCeil(value, base) {
        return Math.ceil(value * base) / base;
    }

    //合計	
    @track wcTotal_Title = 'WC金額';
    @track wcTotal_Value = 0;

    @track totalPrice_Title = '客先回答金額';
    @track totalPrice_Value = 0;

    @track totalAgencyPrice_Title = '代理店提供価格合計';
    @track totalAgencyPrice_Value = 0;

    @track totalWeight_Title = '重量合計';
    @track totalWeight_Value = 0;

    @track standardPriceTotal_Title = '積算金額';
    @track standardPriceTotal_Value = 0;

    @track expense_Title = '一般管理費';
    @track expense_Value = 0;

    @track totalSellingBase_Title = '積算金額×価格係数';
    @track totalSellingBase_Value = 0;

    @track totalSellingCost_Title = '見積金額';
    @track totalSellingCost_Value = 0;

    //親へ送信
    //親の一時保存情報をクリア
    clearParentObj(){
        this.totalPrice_Value=0;
        //custom event
        const passEvent = new CustomEvent('clearall', {
            detail:{} 
        });
        this.dispatchEvent(passEvent);
    }

    //-------------見積書項目説明の画像を判断------------------------------

    CC_TYPE = { type: 'コントロールセンタ(C/C)', file: 'cc.png' };
    UPS_TYPE = { type: 'UPS', file: 'ups.png' };
    ROTATION_TYPE = { type: '回転数制御装置(VVVF)', file: 'rotation.png' };
    GENERATION_TYPE = { type: '発電機', file: 'generator.png' };
    HIGH_PRESSURE_TYPE = { type: '高圧コンビ', file: 'high-pressure.png' };
    TELEMETRY_TYPE = { type: 'テレメータ装置[国交省本省宛て提出機器単体費]', file: 'telemetry.png' };
    TELEMETRY_AUTONOMOUS_TYPE = { type: 'テレメータ装置(自律型)[国交省本省宛て提出機器単体費]', file: 'telemetry-autonomous-type.png' };
    DISCHARGE_ALARM_DEVICE_TYPE = { type: '放流警報装置[国交省本省宛て提出機器単体費]', file: 'discharge-alarm-device.png' };
    RADIO_EQUIPMENT_TYPE = { type: '無線装置(テレメータ･テレコントロール用)[国交省本省宛て提出機器単体費]', file: 'radio-equipment.png' };
    IP_TRANMISSION_EQUIPMENT_TYPE = { type: 'IP伝送装置[国交省本省宛て提出機器単体費]', file: 'ip-transmission-equipment.png' };
    CCTV_CAMERA_TYPE = { type: 'CCTVカメラ設備[国交省本省宛て提出機器単体費等]', file: 'cctv-camera.png' };
    MELFLEX_TYPE = { type: 'MELFLEX', file: 'MELFLEX.png' };

    // 見積書項目レコードを取得
    @wire(getRecord, { recordId: '$recordId', fields: [MAJOR_CLASSIFICATION_FIELD] })
    deviceData;

    // 取得したレコードの大分類項目の値を取得
    get majorClassificationField() {
        return getFieldValue(this.deviceData.data, MAJOR_CLASSIFICATION_FIELD);
    }

    // 大分類項目の値で見積書項目説明の画像を判断
    get quotationDescriptionImage() {
        var imageUrl = '';
        const majorClassificationField = this.majorClassificationField;
        if (majorClassificationField == this.DISCHARGE_ALARM_DEVICE_TYPE.type){
            imageUrl = QUOTATION_DESCRIPTION_RESOURCE2 + '/images/';
        } else {
            imageUrl = QUOTATION_DESCRIPTION_RESOURCE + '/images/';
        }
        console.log(imageUrl);
        
        if (majorClassificationField == this.CC_TYPE.type) {
            imageUrl += this.CC_TYPE.file;
        } else if (majorClassificationField == this.UPS_TYPE.type) {
            imageUrl += this.UPS_TYPE.file;
        } else if (majorClassificationField == this.ROTATION_TYPE.type) {
            imageUrl += this.ROTATION_TYPE.file;
        } else if (majorClassificationField == this.GENERATION_TYPE.type) {
            imageUrl += this.GENERATION_TYPE.file;
        } else if (majorClassificationField == this.HIGH_PRESSURE_TYPE.type) {
            imageUrl += this.HIGH_PRESSURE_TYPE.file;
        } else if (majorClassificationField == this.TELEMETRY_TYPE.type) {
            imageUrl += this.TELEMETRY_TYPE.file;
        } else if (majorClassificationField == this.TELEMETRY_AUTONOMOUS_TYPE.type) {
            imageUrl += this.TELEMETRY_AUTONOMOUS_TYPE.file;
        } else if (majorClassificationField == this.DISCHARGE_ALARM_DEVICE_TYPE.type) {
            imageUrl += this.DISCHARGE_ALARM_DEVICE_TYPE.file;
        } else if (majorClassificationField == this.RADIO_EQUIPMENT_TYPE.type) {
            imageUrl += this.RADIO_EQUIPMENT_TYPE.file;
        } else if (majorClassificationField == this.IP_TRANMISSION_EQUIPMENT_TYPE.type) {
            imageUrl += this.IP_TRANMISSION_EQUIPMENT_TYPE.file;
        } else if (majorClassificationField == this.CCTV_CAMERA_TYPE.type) {
            imageUrl += this.CCTV_CAMERA_TYPE.file;
        } else if (majorClassificationField == this.MELFLEX_TYPE.type) {
            imageUrl += this.MELFLEX_TYPE.file;
        } else {
            return null;
        }

        return imageUrl;
    }
}