import { LightningElement,track,api} from 'lwc';
import getInitScreenInfo from '@salesforce/apex/DetailsInputForRelayBoardController.getInitScreenInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { isNotEmpty, priceCalculator } from 'c/commonUtil';

export default class DetailsInputScreenBForRelayBoard extends LightningElement {
    @api recordId;
    @api loaded=false;

    //設置場所 検索条件
    @track installationLocation = '屋内';
    @track installationLocationLabel = '筐体仕様';
    @track installationLocationOptions = [
                        { label: '屋内', value: '屋内', selected :true },
                        { label: '屋外', value: '屋外', selected :false },
                    ];

    //筐体仕様 検索条件
    @track housingSpecifications = '自立SS';
    @track housingSpecificationsLabel = '筐体種類';
    @track housingSpecificationsOptions = [
                        { label: 'SS', value: '自立SS', selected :true },
                        { label: 'SUS', value: '自立SUS', selected :false },
                    ];

    //扉仕様 検索条件
    @track doorSpecifications = '1枚扉';
    @track doorSpecificationsLabel = '扉仕様';
    @track doorSpecificationsOptions = [
                        { label: '1枚扉', value: '1枚扉' , selected :true},
                        { label: '観音開き', value: '観音開き' , selected :false},
                    ];

    //一覧用変数 筐体（低圧盤）
    @track classicTables;

    @track isauxiliaryRelaynodata=false;//一覧表示制御
    //補助継電器盤標準筐体
    @track auxiliaryRelayTable;
    //取付器具類
    @track installEquipTypeTable;

    //選択された仕様
    @track displayCondition;//選択使用
    @track displayTotal;// 合計金額
    @track inputedPrice;//チェックボックスの単価
    @track inputedId;//筐体チェックボックスのId
    @track optRecords;//数量入力されたデータ

    @track closeTables = [];

    //初期化処理
    connectedCallback() {
        console.log("Details Input Screen Loaded");
        this.getScreenInfo(true);
	}

    //初期処理詳細
    getScreenInfo(init) {
        console.log("initScreen Start");
        this.clearTableList();
        this.isauxiliaryRelaynodata=false;
        this.loaded = true;
        console.log(this.installationLocation);
        console.log(this.doorSpecifications);
        console.log(this.housingSpecifications);
        getInitScreenInfo({isInit:init,
                        deviceId : this.recordId,
                        installationLocation: this.installationLocation,
                        doorSpecifications: this.doorSpecifications,
                        housingSpecifications: this.housingSpecifications})
            .then(result => {
                console.log("initScreen 2");
                this.loaded = false;
                if(result) {
                    var mydata =JSON.parse(result);
                    this.classicTables = mydata.classicTables;

                    //補助継電器盤標準筐体
                    this.auxiliaryRelayTable = mydata.auxiliaryRelayTable;
                    //取付器具類
                    this.installEquipTypeTable = mydata.installEquipTypeTable;
                    if (mydata.inputedId ) {
                        this.inputedId=mydata.inputedId;
                        this.inputedPrice=mydata.inputedPrice;
                        this.displayTotal = mydata.displayTotal;
                        this.displayCondition = mydata.displayCondition;

                        //親へ送信（保存用）
                        this.dispatchEvent(new CustomEvent('screeninputforrelayboardchange', {
                            detail: {rId:this.inputedId,
                                    optRecords:this.optRecords} 
                        }));
                        
                    }
                    //条件設定
                    if (mydata.installationLocation) {
                        this.installationLocation=mydata.installationLocation;
                        //筐体仕様
                        this.setSelectedOption(this.installationLocationOptions, this.installationLocation);
                    }
                    if (mydata.doorSpecifications) {
                        this.doorSpecifications=mydata.doorSpecifications;
                        //筐体種類
                        this.setSelectedOption(this.doorSpecificationsOptions, this.doorSpecifications);
                    }
                    if (mydata.housingSpecifications) {
                        this.housingSpecifications=mydata.housingSpecifications;
                        //扉仕様
                        this.setSelectedOption(this.housingSpecificationsOptions, this.housingSpecifications);
                    }
                    // }
                }
            })
            .catch(error => {
                this.loaded = false;
                console.log(error);
            });
    }

    //選択リストの設定
    setSelectedOption(opts, val){
        //筐体仕様
        opts.forEach((item) => {
            if (item.value === val) {
                item.selected = true;
            }else {
                item.selected = false;
            }
        });
    }

    //検索処理
    onSearch(evt){
        console.log('onSearch onClick start::'+evt.target);
        this.getScreenInfo(false);
    }

    //検索条件：筐体仕様　onchange
    installationLocation_Handler(evt){
        console.log('installationLocation_Handler onChange start');
        this.installationLocation = evt.target.value;
    }

    //検索条件：筐体種類 onchange
    housingSpecifications_Handler(evt){
        console.log('housingSpecifications_Handler onChange start');
        this.housingSpecifications = evt.target.value;
    }

    //検索条件：扉仕様
    doorSpecifications_Handler(evt){
        console.log('doorSpecifications_Handler onChange start');
        this.doorSpecifications = evt.target.value;
    }

    //チェックボックスが変わった
    handleScreenInputChange(evt){
        console.log('checkBox onChange start');
        let cnt = evt.target.checked;//入力された数量 ⇒チェックされた場合
        let rId = evt.currentTarget.dataset.id;//Id
        let price = evt.currentTarget.dataset.name;//単価
        let condition = evt.currentTarget.dataset.title;//仕様
        //数量あり
        if (cnt){
            console.log(11111);
            //他には入力された場合
            if (isNotEmpty(this.inputedId) && 
                this.inputedId!=rId) {
                console.log(22222);
                this.template.querySelector('lightning-input[data-id='+rId+']').checked = false;
                const event = new ShowToastEvent({
                    title: '入力エラー',
                    message: '2つ以上の筐体を追加する事は出来ません。',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }else{
                console.log(3333);
                this.inputedId = rId;
                this.inputedPrice = price;
                this.displayCondition = condition;
                //custom event
                const passEvent = new CustomEvent('screeninputforrelayboardchange', {
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
            const passEvent = new CustomEvent('screeninputforrelayboardchange', {
                detail:{rId:null,
                    optRecords:this.optRecords} 
            });
            this.dispatchEvent(passEvent);
        }
        this.setTotalPrice();//金額を合計
    }

    //共通テーブルから通信された
    commonTableInputChange(evt){
        console.log('parent onCommonTableInputChange start');
        let idChanged= evt.detail.id;
        let cnt= evt.detail.cnt;
        let price= evt.detail.price;
        this.addtoIuputRecords(idChanged,cnt,price);
        this.setTotalPrice();//金額を合計
    }

     //共通テーブルから通信された
     commonWCTableInputChange(evt){
        console.log('parent onCommonWCTableInputChange start');
        let idChanged= evt.detail.id;
        let cnt= evt.detail.cnt;
        let price= evt.detail.price;
        this.addtoIuputRecords(idChanged,cnt,price);
        this.setTotalPrice();//金額を合計
        // try{
        console.log('parameter cnt  '+ cnt);
        console.log('parameter price  '+ price);
        var bodyList = this.installEquipTypeTable.bodyList;
        //数量が入力のデータ
        for (let i = 0; i < bodyList.length; i++) {
            var row = bodyList[i];
            for (let j = 0; j < row.cellList.length; j++) {
                var cell = row.cellList[j];
                //wcセル
                if (cell.isEdit && cell.isRight && cell.value.Id == idChanged){
                    if (isNotEmpty(price)){
                        cell.value.Price = (parseInt(price)/2).toLocaleString();
                        row.cellList[j+1].value = price.toLocaleString()+'';
                    }else {
                        cell.value.Price = null;
                        row.cellList[j+1].value = '';
                    }
                    console.log('wc  '+ cell.value.Price );
                    console.log('Price  '+ row.cellList[j+1].value);
                }
                //数量セル
                if (cell.isEdit && !cell.isRight && cell.value.Id == idChanged){
                    console.log('CNT Price ' + price);
                    cell.value.Price = price;
                    cell.value.Quantity = cnt;
                }
            }
        }
        console.log(bodyList);
        this.installEquipTypeTable.bodyList = bodyList;
        this.template.querySelector('c-common-wc-table[data-id="installEquipTypeTable"]').setTableObj(this.installEquipTypeTable);

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
        this.displayTotal=null;
        if(total>0)this.displayTotal=total;
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
                    item['Price'] = parseInt(price) * parseInt(cnt);
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
                            'Price': parseInt(price) * parseInt(cnt)
                        };
                            
            optRecords.push(newRecord);
        }
        this.optRecords = optRecords;
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('screeninputforrelayboardchange', {
            detail: {rId:this.inputedId,
                    optRecords:this.optRecords} 
        }));
    }

    //クリア処理
    clearTableList(){
        this.classicTables =  null;//低圧配電盤
        this.inputedId = '';//チェックされた選択値
        this.inputedPrice = null;
        this.optRecords=[];//明細に数量入力されたデータ
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('screeninputforrelayboardchange', {
            detail: {rId:this.inputedId,
                    optRecords:this.optRecords} 
        }));
        this.displayTotal = '';//選択仕様
        this.displayCondition = '';//選択仕様

        //補助継電器盤標準筐体
        this.auxiliaryRelayTable = null;
        //取付器具類
        this.installEquipTypeTable = null;
    }
    //slds-box幅による設定
    get getStyle() {
        const boxWidth = this.template.querySelector('.slds-box').clientWidth * 0.92;
        return 'overflow: auto;max-height: 270px; max-width:' + boxWidth + 'px';
    }
}