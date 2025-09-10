import { LightningElement,track,api} from 'lwc';
import getInitScreenInfo from '@salesforce/apex/DetailsInputForLowVoltageController.getInitScreenInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { isNotEmpty, priceCalculator } from 'c/commonUtil';

export default class DetailsInputScreenBForLowVoltageSwitchBoard extends LightningElement {

    @api recordId;
    @api loaded=false;

    //筐体仕様 検索条件
    @track installationLocation = '屋内';
    @track installationLocationLabel = '筐体仕様';
    @track installationLocationOptions = [
                        { label: '屋内', value: '屋内', selected :true },
                        { label: '屋外', value: '屋外', selected :false },
                    ];

    //筐体種類 検索条件
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

    //一覧用変数
    //Table毎に　中身が以下の通りです。
    // bodyList;データ行
    // headerList;ヘッダ行
    // headTitle;タイトル
    // footerInfo;フッター情報
    // isNodata;データ存在チェック
    @track classicTables = [];

    //共通部品用
    //配線用遮断器価格 （MCCB・ELB）
    @track mccbTable;
    @track mccbTableHas;
    //低圧CT・PT、保護継電器類
    @track lowVoltageCTPTTable;
    //指示計類
    @track indicatorTypeTable;
    //計装・機器取付費
    @track equipInstallFeeTable;
    //取付器具類
    @track installEquipTypeTable;
    //計器用変流器 ＣＴ(低圧)
    @track transformerCTTable;
    //双投式電磁接触器 
    @track twoElectroContactorTable;
    //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
    @track startupCircuitTable;
    // 電磁開閉器（MC）
    @track electroSwitchTable;
    // 低圧コンデンサ・リアクトル　油入
    @track lowVoltageCROilTable;
    // 変圧器　油入り自冷
    @track transformerOilTable;
    // 変圧器　モールド
    @track transformerMoldTable;
    // 変圧器（照明・建築付帯用）
    @track transformerLightingTable;

    //選択された仕様
    @track displayCondition;//選択使用
    @track displayTotal;// 合計金額
    @track inputedPrice;//チェックボックスの単価
    @track inputedId;//チェックボックスのId
    @track optRecords;//明細に数量入力されたデータ

    //初期化処理
    connectedCallback() {
        console.log("Details Input Screen Loaded");
        this.getScreenInfo(true);
	}

    //ロード表示用メッセージ
    @track loadMsg;
    //初期処理詳細
    getScreenInfo(init) {
        console.log("initScreen Start");
        this.clearTableList();
        this.isNodata = false;
        this.loaded = true;
        // this.startTimer();
        this.loadMsg='情報量が多いため、画面描画に時間がかかります。';
        getInitScreenInfo({isInit:init,
                        deviceId : this.recordId,
                        installationLocation: this.installationLocation,
                        doorSpecifications: this.doorSpecifications,
                        housingSpecifications: this.housingSpecifications})
            .then(result => {
                if(result) {
                    var mydata =JSON.parse(result);
                    this.classicTables = mydata.classicTables;
                    //配線用遮断器価格 （MCCB・ELB）
                    this.mccbTable = mydata.mccbTable;
                    this.mccbTableHas = mydata.mccbTableHas;
                    //低圧CT・PT、保護継電器類
                    this.lowVoltageCTPTTable = mydata.lowVoltageCTPTTable;
                    //指示計類
                    this.indicatorTypeTable = mydata.indicatorTypeTable;
                    //計装・機器取付費
                    this.equipInstallFeeTable = mydata.equipInstallFeeTable;
                    //取付器具類
                    this.installEquipTypeTable = mydata.installEquipTypeTable;
                    //計器用変流器 ＣＴ(低圧)
                    this.transformerCTTable = mydata.transformerCTTable;
                    //双投式電磁接触器 
                    this.twoElectroContactorTable = mydata.twoElectroContactorTable;
                    //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
                    this.startupCircuitTable = mydata.startupCircuitTable;
                    // 電磁開閉器（MC）
                    this.electroSwitchTable = mydata.electroSwitchTable;
                    // 低圧コンデンサ・リアクトル　油入
                    this.lowVoltageCROilTable = mydata.lowVoltageCROilTable;
                    // 変圧器　油入り自冷
                    this.transformerOilTable = mydata.transformerOilTable;
                    // 変圧器　モールド
                    this.transformerMoldTable = mydata.transformerMoldTable;
                    // 変圧器（照明・建築付帯用）
                    this.transformerLightingTable = mydata.transformerLightingTable;
                    if (mydata.inputedId) {
                        this.inputedId=mydata.inputedId;
                        this.inputedPrice = mydata.inputedPrice;
                        this.displayCondition = mydata.displayCondition;
                        this.setTotalPrice();//金額を合計

                        //親へ送信（保存用）
                        this.dispatchEvent(new CustomEvent('screeninputforlowvoltagechange', {
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
                        //
                        this.setSelectedOption(this.doorSpecificationsOptions, this.doorSpecifications);
                    }
                    if (mydata.housingSpecifications) {
                        this.housingSpecifications=mydata.housingSpecifications;
                        this.setSelectedOption(this.housingSpecificationsOptions, this.housingSpecifications);
                    }
                    // }
                }
                this.loaded = false;
                this.loadMsg='';
            })
            .catch(error => {
                this.loaded = false;
                this.loadMsg='';
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
                const passEvent = new CustomEvent('screeninputforlowvoltagechange', {
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
            const passEvent = new CustomEvent('screeninputforlowvoltagechange', {
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
        this.dispatchEvent(new CustomEvent('screeninputforlowvoltagechange', {
            detail: {rId:this.inputedId,
                    optRecords:this.optRecords} 
        }));
    }
    //クリア処理
    clearTableList(){
        this.classicTables= null;//筐体のテーブル情報
        this.inputedId = '';//チャックされたの選択値
        this.inputedPrice = null;
        this.optRecords=[];//明細に数量入力されたデータ
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('screeninputforlowvoltagechange', {
            detail: {rId:this.inputedId,
                    optRecords:this.optRecords} 
        }));
        this.displayTotal = '';//選択仕様
        this.displayCondition = '';//選択仕様

        //配線用遮断器価格 （MCCB・ELB）
        this.mccbTable = null;
        this.mccbTableHas = null;
        //低圧CT・PT、保護継電器類
        this.lowVoltageCTPTTable = null;
        //指示計類
        this.indicatorTypeTable = null;
        //計装・機器取付費
        this.equipInstallFeeTable = null;
        //取付器具類
        this.installEquipTypeTable = null;
        //計器用変流器 ＣＴ(低圧)
        this.transformerCTTable = null;
        //双投式電磁接触器 
        this.twoElectroContactorTable = null;
        //起動回路 【遮断器(MCCB)＋電磁開閉器(MC)＋補助リレー＋タイマー】 
        this.startupCircuitTable = null;
        // 電磁開閉器（MC）
        this.electroSwitchTable = null;
        // 低圧コンデンサ・リアクトル　油入
        this.lowVoltageCROilTable = null;
        // 変圧器　油入り自冷
        this.transformerOilTable = null;
        // 変圧器　モールド
        this.transformerMoldTable = null;
        // 変圧器（照明・建築付帯用）
        this.transformerLightingTable = null;
    }
    //slds-box幅による設定
    get getStyle() {
        const boxWidth = this.template.querySelector('.slds-box').clientWidth * 0.92;
        return 'overflow: auto;max-height: 270px; max-width:' + boxWidth + 'px';
    }
}