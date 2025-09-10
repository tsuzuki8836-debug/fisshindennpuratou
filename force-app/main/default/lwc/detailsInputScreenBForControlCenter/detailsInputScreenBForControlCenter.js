import { LightningElement,api, track } from 'lwc';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getControlCenterScreenInfo from '@salesforce/apex/DetailsInputForControlCenterController.getControlCenterScreenInfo';
import CONTROL_CENTER_DESCRIPTION from '@salesforce/resourceUrl/ControlCenterDescription';


export default class DetailsInputScreenBForControlCenter extends LightningElement {

    //外部API：見積項目Id
    @api recordId;
    @api loaded = false;//spinner表示制御

    //------------------EMC----------------
    @track EMCvalue = 'なし';
    //@track existingOption='なし';
    @track EMC_Options=[
        {label:'なし', value:'なし', selected :false},
        {label:'あり', value:'あり', selected :false}
    ];//プルダウンリスト
    @track isEMC_Value='';//EMC選択値

    @track displayTotal;//合計金額
    @track parentCnt=null;
    @track inputsRecords = [];//画面入力された情報
    @track totalQuantity = 0;//EMC数量
    @track EMCTable;
    @track EMCPrice;
    @track outerBoxTable;
    @track controlPowerTransformerTable;
    @track pullInTable;
    @track isPullInDescription = false;
    @track reversibleTable;
    @track stardeltaTable;
    @track isStarDeltaDescription = false;
    @track MCCBTable;
    @track indicatorTable;
    @track reactorTable;
    @track isReactorDescription = false;
    @track staticcondenserTable;
    @track inverterTable;
    @track isInverterDescription = false;
    @track highinverterTable;
    @track isHighInverterDescription = false;

    @api
    setTable(preObj) {
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

    //画面初期　各一覧の情報を取得する
    connectedCallback() {
        console.log('detailsInputScreenBForControlCenter is loading');
        this.loaded = true;
        this.EMCvalue='なし';
        this.isPullInDescription = false;
        this.isStarDeltaDescription = false;
        this.isReactorDescription = false;
        this.isInverterDescription = false;
        this.isHighInverterDescription = false;
        this.inputsRecords = [];
        this.parentCnt=null;
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('quantitychangeforcontrolcenter', {
            detail: {inputsRecords:this.inputsRecords, cnt:this.parentCnt} 
        }));

            getControlCenterScreenInfo({
                deviceId : this.recordId,
                inputsRecords : null})
                .then(result => {
                if(result) {
                this.loaded = false;
                var mydata =JSON.parse(result);
                if (mydata) {
                    //Emc数量
                    console.log(mydata.EMCTable);
                    let emcCnt = mydata.EMCTable.bodyList[0].cellList[1].value;
                    console.log('Emc数量:'+emcCnt);
                    if(emcCnt){
                        mydata.EMCTable.bodyList[0].cellList[1].value = emcCnt+'';//文字に転換
                        this.EMCvalue='あり';
                        this.updateOption(this.EMCvalue);
                    }
                    this.EMCTable = mydata.EMCTable;
                    this.outerBoxTable = mydata.outerBoxTable;
                    this.controlPowerTransformerTable = mydata.controlPowerTransformerTable;
                    this.pullInTable = mydata.pullInTable;
                    if(this.pullInTable && this.pullInTable.bodyList && this.pullInTable.bodyList.length>0){
                        this.isPullInDescription = true;
                    }
                    this.reversibleTable = mydata.reversibleTable;
                    this.stardeltaTable = mydata.stardeltaTable;
                    if(this.stardeltaTable && this.stardeltaTable.bodyList && this.stardeltaTable.bodyList.length>0){
                        this.isStarDeltaDescription = true;
                    }
                    this.MCCBTable = mydata.MCCBTable;
                    this.indicatorTable = mydata.indicatorTable;
                    this.reactorTable = mydata.reactorTable;
                    if(this.reactorTable && this.reactorTable.bodyList && this.reactorTable.bodyList.length>0){
                        this.isReactorDescription = true;
                    }
                    this.staticcondenserTable = mydata.staticcondenserTable;
                    this.inverterTable = mydata.inverterTable;
                    if(this.inverterTable && this.inverterTable.bodyList && this.inverterTable.bodyList.length>0){
                        this.isInverterDescription = true;
                    }
                    this.highinverterTable = mydata.highinverterTable;
                    if(this.highinverterTable && this.highinverterTable.bodyList && this.highinverterTable.bodyList.length>0){
                        this.isHighInverterDescription = true;
                    }

                }
                }
                })
                .catch(error => {
                this.loaded = false;
                console.log(error);
                });
    }

        //条件「EMC」　Onchange
        onChangeHandler(event){
            //変わった値を一時保存
            this.EMCvalue = event.target.value;
            this.updateOption(this.EMCvalue);
        }
    
        updateOption(EMCvalue) {
            this.EMC_Options.forEach(item => {
                if(item.value==EMCvalue) {
                    item.selected = true;
                } else {
                    item.selected = false;
                }
            })
        }

    //検索処理
    onSearch(event){
        console.log('onSearch is Start');
        this.loaded = true;
        var inputsRecords = JSON.stringify(this.inputsRecords);
        console.log('変数表示');
        //console.log(this.existingOption);
        console.log(this.EMCValue);
        console.log(this.recordId);

        this.isPullInDescription  = false;
        this.isStarDeltaDescription = false;
        this.isReactorDescription = false;
        this.isInverterDescription = false;
        this.isHighInverterDescription = false;
        getControlCenterScreenInfo({
                                  deviceId : this.recordId,
                                  inputsRecords : inputsRecords})
            .then(result => {
                if(result) {
                    this.loaded = false;
                    //クリアする
                    this.inputsRecords = [];
                    var mydata =JSON.parse(result);
                    if (mydata) {
                        this.template.querySelector('c-common-table[data-id="EMCTable"]').setTableObj(mydata.EMCTable);
                        this.template.querySelector('c-common-table[data-id="outerBoxTable"]').setTableObj(mydata.outerBoxTable);
                        this.template.querySelector('c-common-table[data-id="controlPowerTransformerTable"]').setTableObj(mydata.controlPowerTransformerTable);
                        this.template.querySelector('c-common-table[data-id="pullInTable"]').setTableObj(mydata.pullInTable);
                        if(this.pullInTable && this.pullInTable.bodyList && this.pullInTable.bodyList.length>0){
                            this.isPullInDescription = true;
                        }
                        this.template.querySelector('c-common-table[data-id="reversibleTable"]').setTableObj(mydata.reversibleTable);
                        this.template.querySelector('c-common-table[data-id="stardeltaTable"]').setTableObj(mydata.stardeltaTable);
                        if(this.stardeltaTable && this.stardeltaTable.bodyList && this.stardeltaTable.bodyList.length>0){
                            this.isStarDeltaDescription = true;
                        }
                        this.template.querySelector('c-common-table[data-id="MCCBTable"]').setTableObj(mydata.MCCBTable);
                        this.template.querySelector('c-common-table[data-id="indicatorTable"]').setTableObj(mydata.indicatorTable);
                        this.template.querySelector('c-common-table[data-id="reactorTable"]').setTableObj(mydata.reactorTable);
                        if(this.reactorTable && this.reactorTable.bodyList && this.reactorTable.bodyList.length>0){
                            this.isReactorDescription = true;
                        }
                        this.template.querySelector('c-common-table[data-id="staticcondenserTable"]').setTableObj(mydata.staticcondenserTable);
                        this.template.querySelector('c-common-table[data-id="inverterTable"]').setTableObj(mydata.inverterTable);
                        if(this.inverterTable && this.inverterTable.bodyList && this.inverterTable.bodyList.length>0){
                            this.isInverterDescription = true;
                        }
                        this.template.querySelector('c-common-table[data-id="highinverterTable"]').setTableObj(mydata.highinverterTable);
                        if(this.highinverterTable && this.highinverterTable.bodyList && this.highinverterTable.bodyList.length>0){
                            this.isHighInverterDescription = true;
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
   onCommonTableInputChangeForCount(event){
    console.log('parent onCommonTableInputChangeForCount start');
    let idChanged= event.detail.id;
    let cnt= event.detail.cnt;
    let price= event.detail.price;

    this.addtoIuputRecords(idChanged,cnt,price,true);//入力情報に追加

    this.setTotalPrice();//金額を合計
}


    //一覧コンポネットから返信　の場合
    onCommonTableInputChange(event){
        console.log('parent onCommonTableInputChange start');
        let idChanged= event.detail.id;
        let cnt= event.detail.cnt;
        let price= event.detail.price;

        this.addtoIuputRecords(idChanged,cnt,price,false);//入力情報に追加

        this.setTotalPrice();//金額を合計
    }

    //合計の計算
    setTotalPrice(){
        var total = 0;
        var count = 0;
        console.log('setTotalPrice start');

        var inputsRecords= this.inputsRecords;
        if (inputsRecords!=null && inputsRecords.length>0) {
            //入力されたデータの全部を対象とする。
            inputsRecords.forEach((item) => {
            //数量が入力のデータをカウントする
                if (this.isNotEmpty(item.Quantity)) {
                    if(item.cntFlg)count = count+ parseInt(item.Quantity);
                    if (this.isNotEmpty(item.Price)) total = total+item.Price;//価格合計       
                }
            });
        }
        // this.EMCTable.bodyList[1][1]
        this.parentCnt=null;
        if (this.EMCvalue=='あり'){
            var cellList=this.EMCTable.bodyList[0].cellList;
            cellList[1].value = count + '';
            if(this.template.querySelector('c-common-table[data-id="EMCTable"]'))this.template.querySelector('c-common-table[data-id="EMCTable"]').setTableObj(this.EMCTable);
            this.parentCnt = count;
            var emcPrice = cellList[0].value;
            emcPrice = emcPrice.replace(',','');
            total = total + (count * parseInt(emcPrice));
        }
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('quantitychangeforcontrolcenter', {
            detail: {inputsRecords:this.inputsRecords, cnt:this.parentCnt} 
        }));

        this.displayTotal=total;
    }

    addtoIuputRecords(idChanged,cnt,price, cntFlg){
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
                    item['cntFlg']=cntFlg;
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
                            'UnitPrice':price,//単価
                            'cntFlg':cntFlg
                        };
                            
            inputsRecords.push(newRecord);
        }
        this.inputsRecords = inputsRecords;
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('quantitychangeforcontrolcenter', {
            detail: {inputsRecords:this.inputsRecords, cnt:this.parentCnt} 
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

    //-------------コントロールセンタの画像を判断------------------------------
    PULLBOARD_TYPE ={type: '引込盤', file: 'PullBoardDescription.png'};
    STARDELTA_TYPE ={type: 'スター・デルタユニット', file:'StarDeltaDescription.png'};
    REACTOR_TYPE ={type: 'リアクトル起動回路', file:'ReactorDescription.png'};
    INVERTER_TYPE ={type: 'インバータユニット', file:'InverterDescription.png'};
    HIGHINVERTER_TYPE ={type: '高効率コンバータ付インバータユニット', file:'HighInverterDescription.png'};

    //引込盤
    get pullboardDescriptionImage(){
        var imageUrl = '';
        imageUrl = CONTROL_CENTER_DESCRIPTION + '/images/';
        imageUrl += this.PULLBOARD_TYPE.file;

        return imageUrl;
    }
    //スター・デルタユニット
    get stardeltaDescriptionImage(){
        var imageUrl = '';
        imageUrl = CONTROL_CENTER_DESCRIPTION + '/images/';
        imageUrl += this.STARDELTA_TYPE.file;

        return imageUrl;
    }
    //リアクトル起動回路
    get reactorDescriptionImage(){
        var imageUrl = '';
        imageUrl = CONTROL_CENTER_DESCRIPTION + '/images/';
        imageUrl += this.REACTOR_TYPE.file;

        return imageUrl;
    }
    //インバータユニット
    get inverterDescriptionImage(){
        var imageUrl = '';
        imageUrl = CONTROL_CENTER_DESCRIPTION + '/images/';
        imageUrl += this.INVERTER_TYPE.file;

        return imageUrl;
    }
    //高効率コンバータ付インバータユニット
    get highinverterDescriptionImage(){
        var imageUrl = '';
        imageUrl = CONTROL_CENTER_DESCRIPTION + '/images/';
        imageUrl += this.HIGHINVERTER_TYPE.file;

        return imageUrl;
    }

}