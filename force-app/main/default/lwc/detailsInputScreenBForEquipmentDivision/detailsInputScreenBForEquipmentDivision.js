import { LightningElement,api, track } from 'lwc';
import getPicklistOptions from '@salesforce/apex/DetailsInputForEquipmentDivController.getPicklistOptions';
import getScreenInfo from '@salesforce/apex/DetailsInputForEquipmentDivController.getScreenInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { isNotEmpty, priceCalculator } from 'c/commonUtil';

export default class DetailsInputScreenBForEquipmentDivision extends LightningElement {

    //外部API：見積項目Id
    @api recordId;
    @api loader = false;//spinner表示制御

    //------------------画面制御----------------
    @track isHighVoltage=true;//高圧TR2
    @track isLowVoltage=false;//高低圧TR2
    @track isHDry=false;//H種乾式変圧器
    @track isOil=true;//油　モールド
    @track title='';
    @track headerList=null; //一覧ヘッダー情報
    @track bodyList=null;   //一覧ボディー情報
    @track isNodata=false;

    @track exOpt={rSeries:null,exaSeries:null,exbSeries:null};//シリーズ の検索条件

    //-------------画面入力情報---------------------
    @track inputedId;//チェックボックスの入力情報
    @track inputedPrice;//チェックボックスの単価
    @track optRecords;//付属品入力情報
    @track displayTotal = null;//合計価格
    @track displayCondition = null;//選択仕様


    //-------------------共通部品---------
    // 高圧TR2-
    @track rSeriesSingleTable;
    @track exaSeriesSingleTable;
    @track exbSeriesSingleTable;
    @track rSeriesTriangleTable;
    @track exaSeriesTriangleTable;
    @track exbSeriesTriangleTable;
    // 高低圧TR2-
    @track lowVoltageTable;
    // H種乾式変圧器
    @track hDrySingleTable;//H種乾式 単相
    @track hDryTriangleTable;//H種乾式 三相


    //------------------画面種類　検索条件----------------
    @track screenType_LabelName = '画面種類';
    @track screenType_Options=[
                {label:'高圧TR2（機器事業部）', value:'高圧TR2（機器事業部）', selected :false},
                {label:'高低圧TR2（機器事業部）', value:'高低圧TR2（機器事業部）', selected :false},
                {label:'H種乾式変圧器（機器事業部）', value:'H種乾式変圧器（機器事業部）', selected :false}
        ];//プルダウンリスト
    @track screenType_Value='';//画面種類選択値

    //------------------変圧器種類　検索条件----------------
    @track transformerType_LabelName = '変圧器種類';
    @track transformerType_Options=[];
    //高圧TR2（機器事業部）　プルダウンリスト
    @track transformerType_High_Options=[
        {label:'油入', value:'油入', selected :false},
        {label:'モールド', value:'モールド', selected :false}
    ];
    //高低圧TR2（機器事業部）　プルダウンリスト
    @track transformerType_Low_Options=[
                {label:'油入', value:'油入', selected :false},
                {label:'モールド', value:'モールド', selected :false},
                {label:'モールド　混触防止板あり', value:'モールド　混触防止板あり', selected :false},
                {label:'モールド　異電圧', value:'モールド　異電圧', selected :false},
                {label:'モールド　異電圧　混触防止板あり', value:'モールド　異電圧　混触防止板あり', selected :false}
        ];//プルダウンリスト
    //高低圧TR2（機器事業部）　プルダウンリスト
    @track transformerType_H_Options=[     
                {label:'なし', value:'ケースなし', selected :false},
                {label:'あり', value:'ケース入り', selected :false}
        ];//プルダウンリスト

    @track transformerType_Value='';//変圧器種類選択値

    //------------------Rシリーズ　検索条件----------------
    @track rSeries_LabelName = 'Rシリーズ';
    @track rSeries_isDisabled = true;//利用可否
    @track rSeries_isRequired = false;//必須可否
    @track rSeries_Options=[];//プルダウンリスト メタデータから取得
    @track rSeries_Value='';//Rシリーズ選択値

    //------------------EXｰαシリーズ　検索条件----------------
    @track exaSeries_LabelName = 'EXｰαシリーズ';
    @track exaSeries_isDisabled = true;//利用可否
    @track exaSeries_isRequired = false;//必須可否
    @track exaSeries_Options=[];//プルダウンリスト メタデータから取得
    @track exaSeries_Value='';//EXｰαシリーズ選択値

    //------------------EXｰβシリーズ　検索条件----------------
    @track exbSeries_LabelName = 'EXｰβシリーズ';
    @track exbSeries_isDisabled = true;//利用可否
    @track exbSeries_isRequired = false;//必須可否
    @track exbSeries_Options=[];//プルダウンリスト メタデータから取得
    @track exbSeries_Value='';//EXｰβシリーズ選択値


    //画面初期処理
    connectedCallback() {
        //一覧非表示にする
        this.clearTableList();
        console.log('ED connectedCallback Start');
        // 親の一時データをクリア
        const passEvent = new CustomEvent('checkboxchangefored', {
            detail:{rId:this.inputedId,
                optRecords:this.optRecords
                } 
        });
        this.dispatchEvent(passEvent);

        this.screenType_Value='';
        this.transformerType_Value='';
        this.exOpt={rSeries:null,exaSeries:null,exbSeries:null};
        this.transformerType_LabelName = '変圧器種類';
        this.isHighVoltage = false;
        this.isLowVoltage = false;
        this.isHDry = false;
        this.isOil = false;
        //検索の処理
        this.onSearch();
    }

    //画面種類 Onchange
    screenType_Handler(evt){
        console.log(evt.target.value);
        this.screenType_Value=evt.target.value;
        //一覧非表示にする
        this.clearTableList();
        //Optクリア
        this.rSeries_isDisabled = true;
        this.exaSeries_isDisabled = true;
        this.exbSeries_isDisabled = true;
        this.exOpt={rSeries:null,exaSeries:null,exbSeries:null};

        this.transformerType_LabelName = '変圧器種類';
        this.isHighVoltage = false;
        this.isLowVoltage = false;
        this.isHDry = false;
        
        this.isOil = false;
        //選択値より設定
        if (this.screenType_Value==='高圧TR2（機器事業部）') {
            this.isHighVoltage = true;
            this.isOil = true;
            this.transformerType_Value='油入';
            this.transformerType_Options=this.transformerType_High_Options;
            this.getOptins(null);
        }else if (this.screenType_Value==='高低圧TR2（機器事業部）') {
            this.isLowVoltage = true;
            this.transformerType_Value='油入';
            this.transformerType_Options=this.transformerType_Low_Options;
        }else if (this.screenType_Value==='H種乾式変圧器（機器事業部）') {
            this.isHDry = true;
            this.transformerType_Value='ケースなし';
            this.transformerType_LabelName = 'ケース';
            this.transformerType_Options=this.transformerType_H_Options;
        }
    }
    //変圧器種類 Onchange
    transformerType_Handler(evt){
        console.log(evt.target.value);
        this.transformerType_Value=evt.target.value;

        //一覧非表示にする
        this.clearTableList();
        //Optクリア
        this.rSeries_isDisabled = true;
        this.exaSeries_isDisabled = true;
        this.exbSeries_isDisabled = true;
        this.exOpt={rSeries:null,exaSeries:null,exbSeries:null};

        this.isOil = false;
        if (this.screenType_Value==='高圧TR2（機器事業部）'
          && this.transformerType_Value==='油入') {
            this.isOil = true;
        }

        //高圧TR2（機器事業部） の場合　プルダウンリストを取得
        if (this.screenType_Value==='高圧TR2（機器事業部）') this.getOptins(null);
    }

    //Rシリーズ Onchange
    rSeries_Handler(evt){
        //一覧非表示にする
        this.clearTableList();

        //クリア
        this.exOpt={rSeries:null,exaSeries:null,exbSeries:null};
        //検索条件に保持
        this.exOpt.rSeries=evt.target.value;
        var order = evt.target.selectedOptions[0].dataset.id;

        //EXｰαシリーズ
        this.exaSeries_Options.forEach((item) => {
            if (item.order === order) {
                item.selected = true;
                this.exOpt.exaSeries=item.value;
            }else {
                item.selected = false;
            }
        });
        //EXｰβシリーズ
        this.exbSeries_Options.forEach((item) => {
            if (item.order === order) {
                item.selected = true;
                this.exOpt.exbSeries=item.value;
            }else {
                item.selected = false;
            }
        });
    }

    //EXｰαシリーズ
    exaSeries_Handler(evt){
        this.exOpt.exaSeries=evt.target.value;
        //一覧非表示にする
        this.clearTableList();
    }

    //EXｰβシリーズ
    exbSeries_Handler(evt){
        this.exOpt.exbSeries=evt.target.value;
        //一覧非表示にする
        this.clearTableList();
    }

    //Rシリーズ
    //EXｰαシリーズ
    //EXｰβシリーズ
    getOptins(index){
        //検索を行う
        this.loader = true;
        //クリア
        this.exOpt={rSeries:null,exaSeries:null,exbSeries:null};
        getPicklistOptions({
            screenType:this.screenType_Value,
            transformerType:this.transformerType_Value,
            index: index})
        .then(result => {
            this.loader = false;
            if(result) {
                var options = result;
                this.rSeries_Options=options.rSeriesOptions;//Rシリーズ
                this.exaSeries_Options=options.exaSeriesOptions;//EXｰαシリーズ
                this.exbSeries_Options=options.exbSeriesOptions;//EXｰβシリーズ

                //Rシリーズ　表示制御
                if (this.rSeries_Options != undefined && this.rSeries_Options.length > 0) {
                    this.rSeries_isDisabled = false;
                    //EXｰβシリーズ
                    this.rSeries_Options.forEach((item) => {
                        if (item.selected) {
                            this.exOpt.rSeries=item.value;
                        }
                    });

                }
                //EXｰαシリーズ　表示制御
                if (this.exaSeries_Options != undefined && this.exaSeries_Options.length > 0) {
                    this.exaSeries_isDisabled = false;
                    //EXｰαシリーズ
                    this.exaSeries_Options.forEach((item) => {
                        if (item.selected) {
                            this.exOpt.exaSeries=item.value;
                        }
                    });
                }
                //EXｰβシリーズ　表示制御
                if (this.exbSeries_Options != undefined && this.exbSeries_Options.length > 0) {
                    this.exbSeries_isDisabled = false;
                    //EXｰβシリーズ
                    this.exbSeries_Options.forEach((item) => {
                        if (item.selected) {
                            this.exOpt.exbSeries=item.value;
                        }
                    });
                }
            }
        })
        .catch(error => {
            this.loaded = false;
            console.log(error);
        });
    }

    //検索ボタンの処理
    onSearch(){
        console.log(this.screenType_Value);
        console.log(this.transformerType_Value);
        var strOpt = JSON.stringify(this.exOpt);
        console.log(strOpt);

        this.bodyList = null;//データ
        this.headerList = null;//ヘッダー
        this.inputedId = '';//チャックされたの選択値
        this.inputedPrice = null;
        this.displayTotal = '';//選択仕様
        this.displayCondition = '';//選択仕様
        //状態クリア
        this.clearTableList();

        //検索を行う
        this.loader = true;
        getScreenInfo({
            recordId:this.recordId,
            screenType:this.screenType_Value,
            transformerType:this.transformerType_Value,
            exOpt:strOpt})
        .then(result => {
            this.loader = false;
            if(result) {
                var mydata =JSON.parse(result);
                if (mydata.isNodata) {
                    this.isNodata = true;
                }else {
                    this.isNodata = false;
                    this.bodyList = mydata.bodyList;//データ
                    this.headerList = mydata.headerList;//ヘッダー
                }
                this.inputedId = mydata.inputedId;//チャックされたの選択値
                this.inputedPrice= mydata.inputedPrice;
                this.displayTotal = mydata.displayTotal;//選択仕様
                this.displayCondition = mydata.displayCondition;//選択仕様
                // 高圧TR2（機器事業部）
                this.rSeriesSingleTable = mydata.rSeriesSingleTable;//Rシリーズ　単相
                this.exaSeriesSingleTable = mydata.exaSeriesSingleTable;//EX-αシリーズ　単相
                this.exbSeriesSingleTable = mydata.exbSeriesSingleTable;//EX-βシリーズ　単相
                this.rSeriesTriangleTable = mydata.rSeriesTriangleTable;//Rシリーズ　三相
                this.exaSeriesTriangleTable = mydata.exaSeriesTriangleTable;//EX-αシリーズ　三相
                this.exbSeriesTriangleTable = mydata.exbSeriesTriangleTable;//EX-βシリーズ　三相
                // 高低圧TR2（機器事業部）
                this.lowVoltageTable = mydata.lowVoltageTable;//付属品
                //H種乾式変圧器（機器事業部）
                this.hDrySingleTable = mydata.hDrySingleTable;//種乾式 単相
                this.hDryTriangleTable = mydata.hDryTriangleTable;//H種乾式 三相

                console.log(this.rSeriesSingleTable);
                // custom event
                const passEvent = new CustomEvent('checkboxchangefored', {
                    detail:{rId:this.inputedId,
                        optRecords:this.optRecords
                        } 
                });
                this.dispatchEvent(passEvent);

                //初期表示
                //画面種類
                //変圧器種類
                if (!isNotEmpty(this.screenType_Value)
                    && !isNotEmpty(this.transformerType_Value)) {
                    this.screenType_Value = mydata.screenType;
                    this.transformerType_Value = mydata.transformerType;

                    //選択値より設定
                    if (this.screenType_Value==='高圧TR2（機器事業部）') {
                        this.isHighVoltage = true;
                        if(mydata.transformerType==='油入')this.isOil = true;
                        this.transformerType_Value=mydata.transformerType;
                        this.transformerType_Options=this.transformerType_High_Options;
                        this.getOptins(mydata.exOptIndex);
                    }else if (this.screenType_Value==='高低圧TR2（機器事業部）') {
                        this.isLowVoltage = true;
                        this.transformerType_Value= mydata.transformerType;
                        this.transformerType_Options=this.transformerType_Low_Options;
                    }else if (this.screenType_Value==='H種乾式変圧器（機器事業部）') {
                        this.isHDry = true;
                        this.transformerType_Value=mydata.transformerType;
                        this.transformerType_LabelName = 'ケース';
                        this.transformerType_Options=this.transformerType_H_Options;
                    }
                    //画面種類
                    this.screenType_Options.forEach((item) => {
                        if (item.value === this.screenType_Value) {
                            item.selected = true;
                        }
                    });
                    //変圧器種類
                    this.transformerType_Options.forEach((item) => {
                        if (item.value === this.transformerType_Value) {
                            item.selected = true;
                        }
                    });


                }
                //選択値より設定
                if (this.screenType_Value==='高圧TR2（機器事業部）') {
                    this.title='機器事業部高圧TR　1/3';
                }else if (this.screenType_Value==='高低圧TR2（機器事業部）') {
                    this.title='機器事業部高圧TR　2/3';
                }else if (this.screenType_Value==='H種乾式変圧器（機器事業部）') {
                    this.title='機器事業部高圧TR　3/3';
                }
            }
        })
        .catch(error => {
            this.loaded = false;
            console.log(error);
        });
    }

    //共通から入力された場合
    onCommonTableInputChange(evt){
        console.log('parent onCommonTableInputChange start');
        let idChanged= evt.detail.id;
        let cnt= evt.detail.cnt;
        let price= evt.detail.price;
        this.addtoIuputRecords(idChanged,cnt,price);
        this.setTotalPrice();//金額を合計
    } 

    //合計の計算
    setTotalPrice(){
        console.log('setTotalPrice start');
        var total = 0;
        var optRecords= this.optRecords;
        //チェックボックス（筐体）
        if(isNotEmpty(this.inputedPrice)) total = total + parseFloat(this.inputedPrice);
        //付属品
        if (optRecords!=null && optRecords.length>0) {
            //入力されたデータの全部を対象とする。
            optRecords.forEach((item) => {
                //数量が入力のデータをカウントする
                if (isNotEmpty(item.Quantity)){
                    if (isNotEmpty(item.Price)) total = total + item.Price;//価格合計       
                }
            });
        }
        this.displayTotal=total;
    }

    //チェックボックスが入力された場合
    handleScreenInputChange(evt){
        console.log('parent handleScreenInputChange start');
        let cnt = evt.target.checked;//入力された数量 ⇒チェックされた場合
        let rId = evt.currentTarget.dataset.id;//Id
        let price = evt.currentTarget.dataset.name;//単価
        let condition = evt.currentTarget.dataset.title;//仕様
        //数量あり
        if (cnt){
            //他には入力された場合
            if (isNotEmpty(this.inputedId) && 
                this.inputedId!=rId) {
                this.template.querySelector('lightning-input[data-id='+rId+']').checked = false;
                const event = new ShowToastEvent({
                    title: '入力エラー',
                    message: '2つ以上の筐体を追加する事は出来ません。',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }else{
                this.inputedId = rId;
                this.inputedPrice = price;
                this.displayCondition = condition;
                //custom event
                const passEvent = new CustomEvent('checkboxchangefored', {
                    detail:{rId:rId,
                        optRecords:this.optRecords} 
                });
               this.dispatchEvent(passEvent);
            }
        //数量　クリア
        }else{
            this.inputedId = null;
            this.inputedPrice = null;
            this.displayCondition = null;
            
            //custom event
            const passEvent = new CustomEvent('checkboxchangefored', {
                detail:{rId:null,
                    optRecords:this.optRecords} 
            });
            this.dispatchEvent(passEvent);
        }
        this.setTotalPrice();//金額を合計
    }

    //付属品の入力情報
    addtoIuputRecords(idChanged,cnt,price){
        var optRecords = this.optRecords;
        var isNotIn = true;
        if (optRecords!=null && optRecords.length > 0) {
            //一時保存情報を最新化する
            optRecords.forEach((item) => {
                var idRecord = item['Id'];
                //既存あり場合　入力データで更新
                if (idChanged === idRecord) {
                    isNotIn = false;
                    item['Quantity']=cnt;
                    item['Price'] = priceCalculator({
                                        UnitPrice__c: price,
                                        Quantity__c: cnt
                                    });
                    item['UnitPrice']=price;
                }
            });
        }else{
            optRecords=[];
        }

        //クリア対象外　かつ　既存には存在しない
        if (isNotIn) {
            //新規作成して inputsRecords
            var newRecord = {'Id':idChanged,
                            'Quantity':cnt,
                            'Price':priceCalculator({
                                            UnitPrice__c: price,
                                            Quantity__c: cnt
                                        }),
                            'UnitPrice':price//単価
                        };
                            
            optRecords.push(newRecord);
        }
        this.optRecords = optRecords;
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('checkboxchangefored', {
            detail: {rId:this.inputedId,
                    optRecords:this.optRecords} 
        }));
    }
    //一覧非表示にする
    clearTableList(){
        this.title='';
        this.bodyList = null;//データ
        this.headerList = null;//ヘッダー
        this.rSeriesTriangleTable = null;//付属品シリーズ
        this.exaSeriesTriangleTable = null;//付属品シリーズ
        this.exbSeriesTriangleTable = null;//付属品シリーズ
        this.rSeriesSingleTable = null;//付属品シリーズ
        this.exaSeriesSingleTable = null;//付属品シリーズ
        this.exbSeriesSingleTable = null;//付属品シリーズ
        this.lowVoltageTable = null;//付属品条件
        this.hDrySingleTable = null;//付属品H乾式
        this.hDryTriangleTable = null;//付属品H乾式

        this.inputedId = '';//チャックされたの選択値
        this.inputedPrice = null;
        this.optRecords=[];//付属品の検索条件
        this.displayTotal = '';//選択仕様
        this.displayCondition = '';//選択仕様
    }
}