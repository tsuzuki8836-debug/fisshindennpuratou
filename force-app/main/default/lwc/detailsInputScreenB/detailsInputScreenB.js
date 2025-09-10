import { LightningElement,track,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetailsInputForExtraHighInfo from '@salesforce/apex/DetailsInputForExtraHighController.getDetailsInputForExtraHighInfo';

export default class DetailsInputScreenB extends LightningElement {

    @api recordId;
    @api loaded = false;

    @track optionsScreen = [
                        { label: '特高TR 油入', value: '1' },
                        { label: '特高TR モールド', value: '2' },
                        { label: '特高TRガス', value: '3' },
                        { label: '特高TR植物油入', value: '4' },
                    ];

    //特高TR　条件
    @track options1 = [
                        { label: '屋内', value: '1' },
                        { label: '屋外', value: '2' },
                    ];

    @track options_oil = [
                        { label: '標準', value: '0' },
                        { label: '66,000V/13,800V', value: '1' },
                        { label: '22,000V/13,800V', value: '2' },
                        { label: '二次電圧低圧', value: '9' },
                    ];

    @track options_mold = [
                        { label: '標準', value: '0' },
                        { label: '22,000V/13,800V', value: '2' },
                        { label: '二次電圧低圧', value: '9' },
                    ];

    @track options3 = [
                        { label: 'なし', value: '0' },
                        { label: 'あり', value: '1' },
                    ];

    @track options4 = [
                        { label: 'なし', value: '0' },
                        { label: 'あり', value: '1' },
                    ];

    @track options5 = [
                        { label: 'なし', value: '0' },
                        { label: 'あり', value: '1' },
                    ];

    @track screenType = '1';
    @track priceCondition1 = '1';
    @track priceCondition2 = '0';
    @track priceCondition3 = '0';
    @track priceCondition4 = '0';
    @track priceCondition5 = '0';
    @track priceCondition5Label='GIS直結';
    @track bodyList;
    @track headerList;
    @track displayTableLabel;
    @track isMoldType = false;
    @track searchConMap;
    @track isFacility;

    @track displayCondition;
    @track displayTotal;
    @track inputedId;

    @track isDisplayError = false;
    @track isNoData;
    @track errorMsg;

    @track footer;

    //画面初期
    connectedCallback() {
        this.initScreen();
	}

    initScreen() {
        console.log('======= initScreen ======');
        this.isMoldType = false;
        this.loaded = true;

        getDetailsInputForExtraHighInfo({
            isInit: true,
            deviceId: this.recordId,
            screenType: this.screenType,
            searchCondition1: this.priceCondition1,
            searchCondition2: this.priceCondition2,
            searchCondition3: this.priceCondition3,
            searchCondition4: this.priceCondition4,
            searchCondition5: this.priceCondition5,
        })
        .then(result => {
            if (result) {
                console.log(result);
                this.loaded = false;
                const data = JSON.parse(result);
                if (data.isNoData) {
                    this.isNoData = true;
                }  else {
                    // 表示データをセット
                    this.headerList = data.headerList;
                    this.bodyList = data.bodyList;
                    this.displayTableLabel = data.displayLabel;
                    this.footer = data.footer;
                    this.isNoData = false;

                    this.inputedId = data.inputedId;
                    this.priceCondition1 = data.searchCondition1;
                    this.priceCondition2 = data.searchCondition2;
                    this.priceCondition3 = data.searchCondition3;
                    this.priceCondition4 = data.searchCondition4;
                    this.priceCondition5 = data.searchCondition5;

                    // 検索条件をセット
                    this.displayCondition = data.displayCondition;
                    this.displayTotal = data.displayTotal;
                    this.screenType = data.screenType;

                    this.searchConMap = data.searchConMap;

                    console.log(this.searchConMap);

                    if (this.displayCondition && this.displayTotal) {
                        var acc = this.template.querySelector('lightning-accordion');
                        var activeSections = ['sec2'];
                        acc.activeSectionName = activeSections;
                    }
                }
                // モードタイプのラベルをセット
                if (this.screenType=='2') {
                    this.priceCondition5Label='収納盤';
                    this.isMoldType = true;
                }

                // BUを判定
                if(data.buType == 'S'){
                    this.isFacility = true;
                }

                // Send selected Id to quoteManagementMainPage
                const passEvent = new CustomEvent('screeninputchange', {
                    detail:{value:this.displayTotal,
                        title:this.searchConMap,
                        rId:this.inputedId} 
                });
                this.dispatchEvent(passEvent);
            }    
        })
        .catch(error => {
            this.isNoData = true;
            this.loaded = false;
            console.log(error);
        });
    }

    handleScreenInputChange(event) {
        let cnt = event.target.checked;//入力された数量 ⇒チェックされた場合
        let rId = event.currentTarget.dataset.id;//Id
        let price = event.currentTarget.dataset.name;//単価
        let tempTitle = event.currentTarget.dataset.title.split('@@');

        let displayCondition = tempTitle[0];//仕様
        let condition = tempTitle[1];

        console.log('@@@@@@@@@@@@@@@@@@@@@@@@');
        console.log(displayCondition);
        console.log(condition);

        if (cnt){
            var acc = this.template.querySelector('lightning-accordion');
            var activeSections = ['sec2'];
            acc.activeSectionName = activeSections;

            //他には入力された場合
            if (this.inputedId!=null && this.inputedId!=undefined && 
                this.inputedId!=rId) {
                this.template.querySelector('lightning-input[data-id='+rId+']').checked = false;
                const event = new ShowToastEvent({
                    title: '入力エラー',
                    message: '2つ以上の筐体を追加する事は出来ません。',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            } else {
                this.inputedId = rId;
                this.displayTotal = price;
                this.displayCondition = displayCondition;
                //custom event
                const passEvent = new CustomEvent('screeninputchange', {
                    detail:{value:price,
                        title:condition,
                        rId:rId} 
                });
               this.dispatchEvent(passEvent);
            }
        } else {
            this.inputedId = null;
            this.displayTotal = null;
            this.displayCondition = null;
            
            //custom event
            const passEvent = new CustomEvent('screeninputchange', {
                detail:{value:null,
                        rId:null} 
            });
            this.dispatchEvent(passEvent);
        }
	}
    handleCon1Change(event) {
        this.priceCondition1=event.detail.value;
    }
    handleCon2Change(event) {
        this.priceCondition2=event.detail.value;
    }
    handleCon3Change(event) {
        this.priceCondition3=event.detail.value;
    }
    handleCon4Change(event) {
        this.priceCondition4=event.detail.value;
    }
    handleCon5Change(event) {
        this.priceCondition5=event.detail.value;
    }
    handleScreenTypeChange(event) {
        this.isMoldType = false;
        this.loaded = true;
        this.bodyList=null;
        this.headerList=null;
        this.isDisplayError = false;

        this.priceCondition1=null;
        this.priceCondition2=null;
        this.priceCondition3=null;
        this.priceCondition4=null;
        this.priceCondition5=null;
    
        this.inputedId = null;
        this.displayTotal = null;
        this.displayCondition = null;

        this.priceCondition5Label ='GIS直結';
        //custom event
        const passEvent = new CustomEvent('screeninputchange', {
            detail:{value:null,
                    rId:null} 
        });
        this.dispatchEvent(passEvent);

        this.errorMsg='';
        this.screenType=event.detail.value;

        // 収納盤の設定
        if (this.screenType=='2') {
            this.priceCondition5Label='収納盤';
            this.isMoldType = true;
        }

        // 内訳入力B_特高TR
        getDetailsInputForExtraHighInfo({
            isInit: false,
            deviceId: this.recordId,
            screenType: event.detail.value,
            searchCondition1: this.priceCondition1,
            searchCondition2: this.priceCondition2,
            searchCondition3: this.priceCondition3,
            searchCondition4: this.priceCondition4,
            searchCondition5: this.priceCondition5,
        })
        .then(result => {
            if (result) {
                this.loaded = false;
                const data = JSON.parse(result);
                console.log(data);
                this.priceCondition1 = data.searchCondition1;
                this.priceCondition2 = data.searchCondition2;
                this.priceCondition3 = data.searchCondition3;
                this.priceCondition4 = data.searchCondition4;
                this.priceCondition5 = data.searchCondition5;
                if (data.isNoData) {
                    this.isNoData = true;
                } else {
                    
                    // 表示データをセット
                    this.bodyList = data.bodyList;
                    this.headerList = data.headerList;
                    this.displayTableLabel = data.displayLabel;
                    this.footer = data.footer;
                    this.isNoData = false;

                    // 検索条件をセット
                    this.displayCondition = data.displayCondition;
                    this.displayTotal = data.displayTotal;
                    this.screenType = data.screenType;
                }

                var acc = this.template.querySelector('lightning-accordion');
                acc.activeSectionName = [];
            }
        })
        .catch(error => {
            this.isNoData = true;
            this.loaded = false;
            console.log(error);
        });
	}

    onSearch(event) {
        this.bodyList=null;
        this.headerList=null;
        this.isDisplayError = false;

        this.isMoldType = false;

        //custom event
        const passEvent = new CustomEvent('screeninputchange', {
            detail:{value:null,
                    rId:null} 
        });
        this.dispatchEvent(passEvent);

        this.inputedId = null;
        this.displayTotal = null;
        this.displayCondition = null;
        
        this.isNodata = false;
        this.errorMsg='';
        this.loaded = true;
        getDetailsInputForExtraHighInfo({
            isInit: false,
            deviceId: this.recordId,
            screenType: this.screenType,
            searchCondition1: this.priceCondition1,
            searchCondition2: this.priceCondition2,
            searchCondition3: this.priceCondition3,
            searchCondition4: this.priceCondition4,
            searchCondition5: this.priceCondition5,
        })
        .then(result => {
            if (result) {
                this.loaded = false;
                const data = JSON.parse(result);

                this.priceCondition1 = data.searchCondition1;
                this.priceCondition2 = data.searchCondition2;
                this.priceCondition3 = data.searchCondition3;
                this.priceCondition4 = data.searchCondition4;
                this.priceCondition5 = data.searchCondition5;

                if (data.isNoData) {
                    this.isNoData = true;
                } else {
                    // 表示データをセット
                    this.bodyList = data.bodyList;
                    this.headerList = data.headerList;
                    this.displayTableLabel = data.displayLabel;
                    this.footer = data.footer;
                    this.isNoData = false;

                    // 検索条件をセット
                    this.displayCondition = data.displayCondition;
                    this.displayTotal = data.displayTotal;
                    this.screenType = data.screenType;
                    
                }
                // モードタイプのラベルをセット
                if (this.screenType=='2') {
                    this.priceCondition5Label='収納盤';
                    this.isMoldType = true;
                }

                var acc = this.template.querySelector('lightning-accordion');
                acc.activeSectionName = [];
            }
        })
        .catch(error => {
            this.isNoData = true;
            this.loaded = true;
            console.log(error);
        });
	}

    // 電圧仕様を判断
    get voltageSpecification() {
        if (this.screenType == '2') return this.options_mold;
        return this.options_oil;
    }
}