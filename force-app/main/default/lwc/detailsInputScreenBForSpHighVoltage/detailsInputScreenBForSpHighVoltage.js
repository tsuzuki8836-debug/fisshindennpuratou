import { LightningElement, track ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSpHighVoltageScreenInfo from '@salesforce/apex/DetailsInputControllerForSpHighVoltage.getSpHighVoltageScreenInfo';
import containsEVT_PT_LA from '@salesforce/apex/DetailsInputControllerForSpHighVoltage.containsEVT_PT_LA';
import getDevice from '@salesforce/apex/DeviceController.getDevice';


export default class DetailsInputScreenBForHighVoltage extends LightningElement {

    @api recordId;

    @api loaded = false;
    //設置場所
    @track classic_Options= [
        { label: '屋内', value: '屋内' ,selected:true},
        { label: '屋外', value: '屋外' ,selected:false}
    ];
    @track selectedValue='屋内';
    @track existingOption='屋内';
    //定格電圧
    @track classic_Options2= [
        { label: '66kV', value: '66kV' ,selected:true},
        { label: '77kV', value: '77kV' ,selected:false},
        { label: '110kV', value: '110kV' ,selected:false}
    ];
    @track selectedValue2='66kV';
    @track existingOption2='66kV';
    //定格遮断電流
    @track classic_Options3= [
        { label: '20/25kA', value: '20/25kA' ,selected:true},
        { label: '31.5kA', value: '31.5kA' ,selected:false}
    ];
    @track selectedValue3='20/25kA';
    @track existingOption3='20/25kA';
    //定格電流
    @track classic_Options4= [
        { label: '800A', value: '800A' ,selected:true},
        { label: '1200A(1250A)', value: '1200A(1250A)' ,selected:false}
    ];
    @track selectedValue4='800A';
    @track existingOption4='800A';
    //絶縁方式
    @track classic_Options5= [
        { label: 'SF6ガス', value: 'SF6ガス' ,selected:true},
        { label: 'ドライエア', value: 'ドライエア' ,selected:false}
    ];
    @track selectedValue5='SF6ガス';
    @track existingOption5='SF6ガス';


    @track displayTotal = 0;//合計金額
    @track inputsRecords = [];//画面入力された情報

    @track unitPriceTable;//計器・保護継電器・変換器
    
    @track combinationAmpDS = '';
    @track combinationAmpVCB = '';

    @track minorClassificationInfo = true;
    @track showButtonclassicOptions3 = false; //定格遮断電流
    @track showButtonclassicOptions5 = false; //絶縁方式

    @api tableObj;
    @track noteList2;
    @track isHavenote2 = false;

    @api
    setTableObj(preObj) {
        console.log("common Table setTableObj Loaded");
        if (preObj){
            this.isNodata=false;
            this.secTitle=preObj.secTitle;
            if (preObj.bodyList && preObj.bodyList.length>0){
                this.comment=preObj.comment;
                this.headerList=preObj.headerList;
                this.bodyList=preObj.bodyList;
                this.noteList=preObj.noteList;
                //数量が入力のデータ
                for (let i = 0; i < this.bodyList.length; i++) {
                    var row = this.bodyList[i];
                    for (let j = 0; j < row.cellList.length; j++) {
                        var cell = row.cellList[j];
                        //編集セル
                        if (cell.isEdit){
                        var quantityObj =  cell.value;
                        //数量が既に入力された
                        if (this.isNotEmpty(quantityObj.Quantity)) {
                            if (this.isOneSelector) this.selectedId = quantityObj.Id;
                            const passEvent = new CustomEvent('commontableinputchange', {
                                detail:{id:quantityObj.Id,
                                        cnt:quantityObj.Quantity,
                                        price:quantityObj.Price,
                                        // option:quantityObj.Option
                                        } 
                            });
                            this.dispatchEvent(passEvent);
                        }
                    }
                    }
                }
            }else {
                this.isNodata=true;
            }
        }
    }

    @track device;
    //画面初期　各一覧の情報を取得する
    connectedCallback() {
        console.log('detailsInputScreenBForHighVoltage is loading');
        this.clearTableList();
        console.log(this.selectedValue);
        console.log(this.selectedValue2);
        console.log(this.selectedValue3);
        console.log(this.selectedValue4);
        console.log(this.selectedValue5);
        this.loaded = true;
        this.selectedValue='屋内';
        getDevice({recordId: this.recordId})
        .then(result => {
            if(result) {
                console.log(JSON.stringify(result));
                this.device = result[0];
                if(this.device.MinorClassification__c == '66kV C-GIS'){
                    this.showButtonclassicOptions3 = true;
                    this.showButtonclassicOptions5 = true;
                }else{
                    this.classic_Options2= [
                        { label: '22kV', value: '22kV' ,selected:true},
                        { label: '33kV', value: '33kV' ,selected:false}
                    ];
                    this.selectedValue2 ='22kV';
                    this.existingOption2='22kV';
                    console.log(this.selectedValue2);
                }
            }
        })
        .catch(error => {
            console.log(error);
        });

        if (this.tableObj){
            this.isNodata=false;
            this.secTitle=this.tableObj.secTitle;

            if (this.tableObj.bodyList && this.tableObj.bodyList.length>0) {
                this.comment=this.tableObj.comment;
                this.headerList=this.tableObj.headerList;
                this.bodyList=this.tableObj.bodyList;
                this.noteList=this.tableObj.noteList;
                //数量が入力のデータ
                for (let i = 0; i < this.bodyList.length; i++) {
                    var row = this.bodyList[i];
                    for (let j = 0; j < row.cellList.length; j++) {
                        var cell = row.cellList[j];
                        //編集セル
                        if (cell.isEdit){
                        var quantityObj =  cell.value;
                        console.log('value=' + quantityObj);
                        //数量が既に入力された
                        if (this.isNotEmpty(quantityObj.Quantity)) {
                            if (this.isOneSelector) this.selectedId = quantityObj.Id;
                            const passEvent = new CustomEvent('commontableinputchange', {
                                detail:{id:quantityObj.Id,
                                        cnt:quantityObj.Quantity,
                                        price:quantityObj.Price,
                                        // option:quantityObj.Option
                                        } 
                            });
                            this.dispatchEvent(passEvent);
                        }
                    }
                    }
                }
            }else {
                this.isNodata=true;
            }
        }


        console.log(this.selectedValue2);
    
        getSpHighVoltageScreenInfo({init:true,
                                    deviceId : this.recordId,
                                    searchOption : this.selectedValue,
                                    searchOption2 : this.selectedValue2,
                                    searchOption3 : this.selectedValue3,
                                    searchOption4 : this.selectedValue4,
                                    searchOption5 : this.selectedValue5,
                                    inputsRecords : null})
            .then(result => {
                console.log(this.selectedValue2);
                console.log(JSON.parse(result));
                if(result) {
                    this.loaded = false;
                    var mydata =JSON.parse(result);
                    if (mydata) { 
                        this.unitPriceTable = mydata.unitPriceTable;
                        console.log('mydata.noteList2111111111');
                        console.log(mydata.noteList2);
                        if (mydata.noteList2 && mydata.noteList2.length>0) {
                            console.log('mydata.noteList2.length>0');
                            this.isHavenote2 = true;
                            this.noteList2 = mydata.noteList2;
                        }
                        console.log(JSON.stringify(this.unitPriceTable));
                        this.selectedValue = mydata.searchOption.slice();
                        this.selectedValue2 = mydata.searchOption2.slice();
                        console.log(this.selectedValue2);
                        this.selectedValue3 = mydata.searchOption3.slice();
                        this.selectedValue4 = mydata.searchOption4.slice();
                        this.selectedValue5 = mydata.searchOption5.slice();
                        this.existingOption = mydata.searchOption.slice();
                        this.existingOption2 = mydata.searchOption2.slice();
                        this.existingOption3 = mydata.searchOption3.slice();
                        this.existingOption4 = mydata.searchOption4.slice();
                        this.existingOption5 = mydata.searchOption5.slice();
                        // this.updateOption(mydata.searchOption);
                        // this.updateOption2(mydata.searchOption2);
                        // this.updateOption3(mydata.searchOption3);
                        // this.updateOption4(mydata.searchOption4);
                        // this.updateOption5(mydata.searchOption5);
                    }
                }
            })
            .catch(error => {
                this.loaded = false;
                console.log(error);
            });
    }

    //検索条件　設置場所
    onChangeHandler(event){
        //変わった値を一時保存
        this.selectedValue = event.target.value;
        //this.updateOption(this.selectedValue);
    }
    updateOption(selectedValue) {
        this.classic_Options.forEach(item => {
            if(item.value==selectedValue) {
                item.selected = true;
            } else {
                item.selected = false;
            }
        })
    }

    //検索条件　定格電圧
    onChangeHandler2(event){
        //変わった値を一時保存
        this.selectedValue2 = event.target.value;
        //this.updateOption2(this.selectedValue2);
    }
    updateOption2(selectedValue2) {
        this.classic_Options2.forEach(item => {
            if(item.value==selectedValue2) {
                item.selected = true;
            } else {
                item.selected = false;
            }
        })
    }
     //検索条件　定格遮断電流
    onChangeHandler3(event){
        //変わった値を一時保存
        this.selectedValue3 = event.target.value;
        //this.updateOption3(this.selectedValue3);
    }
    updateOption3(selectedValue3) {
        this.classic_Options3.forEach(item => {
            if(item.value==selectedValue3) {
                item.selected = true;
            } else {
                item.selected = false;
            }
        })
    }
     //検索条件　定格電流
    onChangeHandler4(event){
        //変わった値を一時保存
        this.selectedValue4 = event.target.value;
        //this.updateOption4(this.selectedValue4);
    }
    updateOption4(selectedValue4) {
        this.classic_Options4.forEach(item => {
            if(item.value==selectedValue4) {
                item.selected = true;
            } else {
                item.selected = false;
            }
        })
    }
     //検索条件　絶縁方式
    onChangeHandler5(event){
        //変わった値を一時保存
        this.selectedValue5 = event.target.value;
        //this.updateOption(this.selectedValue5);
    }
    updateOption5(selectedValue5) {
        this.classic_Options5.forEach(item => {
            if(item.value==selectedValue5) {
                item.selected = true;
            } else {
                item.selected = false;
            }
        })
    }

    //検索処理
    onSearch(event){
        console.log('onSearch is Start');
        this.clearTableList();
        this.loaded = true;
        var inputsRecords = JSON.stringify(this.inputsRecords);
        console.log('変数表示');
        console.log(this.existingOption);
        console.log(this.existingOption2);
        console.log(this.existingOption3);
        console.log(this.existingOption4);
        console.log(this.existingOption5);
        console.log(this.selectedValue);
        console.log(this.selectedValue2);
        console.log(this.selectedValue3);
        console.log(this.selectedValue4);
        console.log(this.selectedValue5);
        console.log(this.recordId);
        console.log('onSearch is End');

        this.isHavenote2 = false;//非表示に設定
        getSpHighVoltageScreenInfo({init:false,
                                    deviceId : this.recordId,
                                    searchOption : this.selectedValue,
                                    searchOption2 : this.selectedValue2,
                                    searchOption3 : this.selectedValue3,
                                    searchOption4 : this.selectedValue4,
                                    searchOption5 : this.selectedValue5,
                                    inputsRecords : inputsRecords})
            .then(result => {
                if(result) {
                    this.loaded = false;
                    //クリアする
                    this.inputsRecords = [];
                    var mydata =JSON.parse(result);
                    if (mydata) {
                        this.template.querySelector('c-common-table[data-id="unitPriceTable"]').setTableObj(mydata.unitPriceTable);
                        console.log(mydata.noteList2);
                        if (mydata.noteList2 && mydata.noteList2.length>0) {
                            console.log('mydata.noteList2.length>0');
                            this.isHavenote2 = true;
                            this.noteList2 = mydata.noteList2;
                        }
                    }
                }
                this.setTotalPrice();//金額を合計
            })
            .catch(error => {
                this.loaded = false;
                console.log(error);
            });
    }
    //一覧コンポネットから返信　の場合
    onCommonTableInputChange(event){
        console.log('parent onCommonTableInputChange start');
        let idChanged= event.detail.id;
        let cnt= event.detail.cnt;
        let price= event.detail.price;
        console.log(this.unitPriceTable.Quantity);
        console.log(this.unitPriceTable);


        console.log('idChanged='+idChanged);
        
        // 2024/02/14 TS田村　追記
        containsEVT_PT_LA({pricingTableId: idChanged, quantity: cnt})
                .then(data => {
                    if (data == true) {
                        console.log('result' + data);
                        this.QuantityCheck();
                        cnt = '';
                    }
                });
        console.log('tk' + cnt);
        this.addtoIuputRecords(idChanged,cnt,price);//入力情報に追加

        this.setTotalPrice();//金額を合計
        
    }

    // 2024/02/14 TS田村　追記
    QuantityCheck(){
        console.log('ShowToast');
        const errorEvent = new ShowToastEvent({
            title: 'エラー',
            message: '「LA」「VT、PT」「ZVT、GPT、EVT」「ネットワークVT」「ネットワークCT」に2以上は入力できません。',
            variant: 'error',//info/success/warning/error
            mode: 'dismissable'
        });
        this.dispatchEvent(errorEvent);
    }

    //合計の計算
    setTotalPrice(){
        var total = 0;
        console.log('setTotalPrice start');

        var inputsRecords= this.inputsRecords;
        if (inputsRecords!=null && inputsRecords.length>0) {
            //入力されたデータの全部を対象とする。
            inputsRecords.forEach((item) => {
            //数量が入力のデータをカウントする
                if (this.isNotEmpty(item.Quantity)) {
                    if (this.isNotEmpty(item.Price)) total = total+item.Price;//価格合計       
                }
            });
        }
        this.displayTotal=total;
    }

    addtoIuputRecords(idChanged,cnt,price){
        var inputsRecords = this.inputsRecords;
        var isNotIn = true;

        if (inputsRecords!=null && inputsRecords.length > 0) {
            //一時保存情報を最新化する
            inputsRecords.forEach((item) => {
                var idRecord = item['Id'];
                //既存あり場合　入力データで更新
                if (idChanged === idRecord) {
                    isNotIn = false;
                    item['Quantity']=cnt;
                    item['Price']=this.priceCalculator({
                                        UnitPrice__c: price,
                                        Quantity__c: cnt
                                    });
                    item['UnitPrice']=price;
                }
            });
        }else{
            inputsRecords=[];
        }
    
        //クリア対象外　かつ　既存には存在しない
        if (isNotIn) {
            //新規作成して inputsRecords
            var newRecord = {'Id':idChanged,
                            'Quantity':cnt,
                            'Price':this.priceCalculator({
                                            UnitPrice__c: price,
                                            Quantity__c: cnt
                                        }),
                            'UnitPrice':price//単価
                        };
                    
            inputsRecords.push(newRecord);
        }
        this.inputsRecords = inputsRecords;
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('quantitychangeforsphigh', {
            detail: {inputsRecords:this.inputsRecords} 
        }));
    }
    //空白、Null、undefined以外の場合 true
    isNotEmpty(val){
        return (val!=null &&val!='' && val!=undefined);
    }
    //単価　＊　数量　＝　価格
    priceCalculator(values) {
        var coefficient = values['Coefficient__c'];
        //単価　＊　数量
        var price = parseInt(values['UnitPrice__c']) * parseInt(values['Quantity__c']);
        if (Number.isNaN(price)){
            price = '';
        }
        //係数がある場合
        //価格　＊　係数
        if (this.isNotEmpty(coefficient)) {
            price=parseInt(price) * parseFloat(coefficient);
            if (Number.isNaN(price)){
                price = '';
            }else{
                price =parseInt(price);
            }
        }
        return price;
    }

    //クリア処理
    clearTableList(){
        this.inputsRecords=[];//明細に数量入力されたデータ
        this.tableObj=null;
        this.noteList2=null;
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('quantitychangeforsphigh', {
            detail: {inputsRecords:this.inputsRecords} 
        }));
        this.displayTotal = '';//選択仕様
    }
}