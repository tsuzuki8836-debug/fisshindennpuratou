import { LightningElement, track ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getHighVoltageScreenInfo from '@salesforce/apex/DetailsInputControllerForHighVoltage.getHighVoltageScreenInfo';
import getAllPriceFor1InputOnly from '@salesforce/apex/DetailsInputControllerForHighVoltage.getAllPriceFor1InputOnly';


export default class DetailsInputScreenBForHighVoltage extends LightningElement {

    @api recordId;

    @track loaded = false;
    @track classic_Options= [
        { label: '屋内', value: '屋内' ,selected:true},
        { label: '屋外', value: '屋外' ,selected:false},
        { label: '屋内FF', value: '屋内FF' ,selected:false},
        { label: '屋外FF', value: '屋外FF' ,selected:false},
    ];
    @track selectedValue='屋内';
    @track existingOption='屋内';

    @track displayTotal = 0;//合計金額
    @track inputsRecords = [];//画面入力された情報

    @track highVoltageBoxTable;//筐体(高圧受配電盤)
    @track disconnectorTable;//断路器(DS)
    @track vcBreakerTable;//真空遮断器(VCB)
    @track gasLoadSwitchTable;//屋外用高圧交流ガス負荷開閉器
    @track fuseLoadSwitchTable;//ヒューズ付負荷開閉器(LBS)
    @track airLoadSwitchTable;//気中負荷開閉器(PAS)
    @track instrumentBoxTable;//取引用計器箱(日東工業)
    @track zeroPhaseCurrentTransformerTable;//零相変流器(ZCT):高圧
    @track lightningArresterTable;//避雷器(LA)
    @track instrumentTransformerTable;//計器用変圧器(VT、PT)ヒューズ付
    @track zeroPhaseTransformerTable;//零相変成器(ZPC、ZPD)
    @track groundedInstrumentTransformerTable;//接地形計器用変圧器ヒューズ付(ZPT、GPT）
    @track currentTransformerTable;//計器用変流器(CT):高圧
    @track loadSwitchsTable;//負荷開閉器類LBS(LDS)
    @track transformerStorageBoardTable;//変圧器収納盤(高圧)
    @track networkRelayMulticapTable;//ネットワークリレー
    @track networkVTTable;//ネットワークVＴ
    @track networkCTTable;//ネットワークＣＴ
    @track compositeCTHighAndLowTable;//合成CT(高圧/低圧)
    @track protectorFuseTable;//プロテクタヒューズ
    @track takeOffFuseTable;//テイクオフヒューズ
    @track meterTableTable;//計器・保護継電器・変換器
    @track transducerTable;//変換器(トランスデューサー:T/D)
    @track MELPRODSeriesTable;//MELPRO－Dシリーズ
    @track mp11MultiRelayTable;//MP11A(マルチリレー)

    @track combinationTable = {};
    @track combinationAmpDS = '';
    @track combinationAmpVCB = '';

    //画面初期　各一覧の情報を取得する
    connectedCallback() {
        console.log('detailsInputScreenBForHighVoltage is loading');
        this.loaded = true;
        this.selectedValue='屋内';
        getAllPriceFor1InputOnly()
            .then(result => {
                if(result) {
                    var allPriceFor1InputOnly =JSON.parse(result);
                    this.combinationTable = {...allPriceFor1InputOnly.combinationTable};
                }
            })
            .catch(error => {
                console.log(error);
            });
        
    
        getHighVoltageScreenInfo({init:true,
                                    deviceId : this.recordId,
                                    searchOption : this.selectedValue,
                                    inputsRecords : null})
            .then(result => {
                if(result) {
                    this.loaded = false;
                    var mydata =JSON.parse(result);
                    if (mydata) {
                        this.highVoltageBoxTable = mydata.boxTable;
                        this.vcBreakerTable = mydata.vcBreakerTable;
                        this.disconnectorTable = mydata.disconnectorTable;
                        this.gasLoadSwitchTable = mydata.gasLoadSwitchTable;
                        this.fuseLoadSwitchTable = mydata.fuseLoadSwitchTable;
                        this.airLoadSwitchTable = mydata.airLoadSwitchTable;
                        this.instrumentBoxTable = mydata.instrumentBoxTable;
                        this.zeroPhaseCurrentTransformerTable = mydata.zeroPhaseCurrentTransformerTable;
                        this.lightningArresterTable = mydata.lightningArresterTable;
                        this.instrumentTransformerTable = mydata.instrumentTransformerTable;
                        this.zeroPhaseTransformerTable = mydata.zeroPhaseTransformerTable;
                        this.groundedInstrumentTransformerTable = mydata.groundedInstrumentTransformerTable;
                        this.currentTransformerTable = mydata.currentTransformerTable;
                        this.loadSwitchsTable = mydata.loadSwitchsTable;
                        this.transformerStorageBoardTable = mydata.transformerStorageBoardTable;
                        this.networkRelayMulticapTable = mydata.networkRelayMulticapTable;
                        this.networkVTTable = mydata.networkVTTable;
                        this.networkCTTable = mydata.networkCTTable;
                        this.compositeCTHighAndLowTable = mydata.compositeCTHighAndLowTable;
                        this.protectorFuseTable = mydata.protectorFuseTable;
                        this.takeOffFuseTable = mydata.takeOffFuseTable;
                        this.meterTableTable = mydata.meterTableTable;
                        this.transducerTable = mydata.transducerTable;
                        this.MELPRODSeriesTable = mydata.MELPRODSeriesTable;
                        this.mp11MultiRelayTable = mydata.mp11MultiRelayTable;

                        this.selectedValue = mydata.searchOption.slice();
                        this.existingOption = mydata.searchOption.slice();
                        this.updateOption(mydata.searchOption);
                    }
                }
            })
            .catch(error => {
                this.loaded = false;
                console.log(error);
            });
    }

    //検索条件「筐体仕様」　Onchange
    onChangeHandler(event){
        //変わった値を一時保存
        this.selectedValue = event.target.value;
        this.updateOption(this.selectedValue);
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

    //検索処理
    onSearch(event){
        console.log('onSearch is Start');
        this.loaded = true;
        var inputsRecords = JSON.stringify(this.inputsRecords);
        console.log('変数表示');
        console.log(this.existingOption);
        console.log(this.selectedValue);
        console.log(this.recordId);

        getHighVoltageScreenInfo({init:false,
                                  deviceId : this.recordId,
                                  searchOption : this.selectedValue,
                                  inputsRecords : inputsRecords})
            .then(result => {
                if(result) {
                    this.loaded = false;
                    //クリアする
                    this.inputsRecords = [];
                    var mydata =JSON.parse(result);
                    if (mydata) {
                        this.template.querySelector('c-common-checkbox-table[data-id="highVoltageBoxTable"]').setTableObj(mydata.boxTable);
                        this.template.querySelector('c-common-table[data-id="disconnectorTable"]').setTableObj(mydata.disconnectorTable);
                        this.template.querySelector('c-common-table[data-id="vcBreakerTable"]').setTableObj(mydata.vcBreakerTable);
                        this.template.querySelector('c-common-table[data-id="gasLoadSwitchTable"]').setTableObj(mydata.gasLoadSwitchTable);
                        this.template.querySelector('c-common-table[data-id="fuseLoadSwitchTable"]').setTableObj(mydata.fuseLoadSwitchTable);
                        this.template.querySelector('c-common-table[data-id="airLoadSwitchTable"]').setTableObj(mydata.airLoadSwitchTable);
                        this.template.querySelector('c-common-table[data-id="instrumentBoxTable"]').setTableObj(mydata.instrumentBoxTable);
                        this.template.querySelector('c-common-table[data-id="zeroPhaseCurrentTransformerTable"]').setTableObj(mydata.zeroPhaseCurrentTransformerTable);
                        this.template.querySelector('c-common-table[data-id="lightningArresterTable"]').setTableObj(mydata.lightningArresterTable);
                        this.template.querySelector('c-common-table[data-id="instrumentTransformerTable"]').setTableObj(mydata.instrumentTransformerTable);
                        this.template.querySelector('c-common-table[data-id="zeroPhaseTransformerTable"]').setTableObj(mydata.zeroPhaseTransformerTable);
                        this.template.querySelector('c-common-table[data-id="groundedInstrumentTransformerTable"]').setTableObj(mydata.groundedInstrumentTransformerTable);
                        this.template.querySelector('c-common-multi-header-table[data-id="currentTransformerTable"]').setTableObj(mydata.currentTransformerTable);
                        this.template.querySelector('c-common-table[data-id="loadSwitchsTable"]').setTableObj(mydata.loadSwitchsTable);
                        this.template.querySelector('c-common-table[data-id="transformerStorageBoardTable"]').setTableObj(mydata.transformerStorageBoardTable);
                        this.template.querySelector('c-common-table[data-id="networkRelayMulticapTable"]').setTableObj(mydata.networkRelayMulticapTable);
                        this.template.querySelector('c-common-table[data-id="networkVTTable"]').setTableObj(mydata.networkVTTable);
                        this.template.querySelector('c-common-table[data-id="networkCTTable"]').setTableObj(mydata.networkCTTable);
                        this.template.querySelector('c-common-table[data-id="compositeCTHighAndLowTable"]').setTableObj(mydata.compositeCTHighAndLowTable);
                        this.template.querySelector('c-common-table[data-id="protectorFuseTable"]').setTableObj(mydata.protectorFuseTable);
                        this.template.querySelector('c-common-table[data-id="takeOffFuseTable"]').setTableObj(mydata.takeOffFuseTable);
                        this.template.querySelector('c-common-table[data-id="meterTableTable"]').setTableObj(mydata.meterTableTable);
                        this.template.querySelector('c-common-table[data-id="transducerTable"]').setTableObj(mydata.transducerTable);
                        this.template.querySelector('c-common-table[data-id="MELPRODSeriesTable"]').setTableObj(mydata.MELPRODSeriesTable);
                        this.template.querySelector('c-common-table[data-id="mp11MultiRelayTable"]').setTableObj(mydata.mp11MultiRelayTable);
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

        this.addtoIuputRecords(idChanged,cnt,price);//入力情報に追加

        this.setTotalPrice();//金額を合計
    } 
    onCommonCheckboxTableInputChange(event){
        console.log('parent onCommonTableInputChange start');

        let idChanged= event.detail.id;
        let cnt= event.detail.cnt;
        let price= event.detail.price;
        this.addtoIuputRecords(idChanged,cnt,price);//入力情報に追加

        this.setTotalPrice();//金額を合計
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

        if(idChanged in this.combinationTable) {
            var com = this.combinationTable[idChanged];
            var comType = '';
            var tempCom = com.split('@@');
            if(tempCom[0] == 'DS') {
                comType = 'DS'
                this.combinationAmpDS = cnt!=0&&cnt!=''?tempCom[1]:''
            } else {
                comType = 'VCB'
                this.combinationAmpVCB = cnt!=0&&cnt!=''?tempCom[1]:'' 
            }

            if((this.combinationAmpDS != '' && this.combinationAmpVCB != '') &&
                (this.combinationAmpDS != this.combinationAmpVCB) &&
                !(this.combinationAmpDS == '600A' && this.combinationAmpVCB == '400A')){
                isNotIn = false;
                const errEvent = new ShowToastEvent({
                    title: '入力エラー',
                    message: '定格電流が真空遮断器(VCB)と異なっています。',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(errEvent);
                if(comType=='DS') {
                    this.combinationAmpDS = '';
                    this.template.querySelector('c-common-table[data-id="disconnectorTable"]').setQuantityObj(idChanged, '');
                } else {
                    this.combinationAmpVCB = '';
                    this.template.querySelector('c-common-table[data-id="vcBreakerTable"]').setQuantityObj(idChanged, '');
                }
                return;
            }
        }

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
        this.dispatchEvent(new CustomEvent('quantitychangeforhighvoltage', {
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
}