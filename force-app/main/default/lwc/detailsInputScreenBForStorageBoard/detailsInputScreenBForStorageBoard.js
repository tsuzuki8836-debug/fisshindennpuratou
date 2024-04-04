import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getStorageBoardScreenInfo from '@salesforce/apex/DetailsInputForStorageBoardController.getStorageBoardScreenInfo';

export default class DetailsInputScreenBForStorageBoard extends LightningElement {

    @api recordId;
    @track loaded = false;
    //選択仕様
    @track displayCondition;
    //合計価格
    @track displayTotal;
    @track inputsRecords = [];//画面入力された情報
    @track inputsKyotaiRecords = [];

    @track storageBoardValue = '屋内';
    @track existingOption='屋内';
    @track storageBoardOptions = [
        { label: '屋内', value: '屋内' ,selected:true},
        { label: '屋外', value: '屋外' ,selected:false},
        { label: '屋内FF', value: '屋内FF' ,selected:false},
        { label: '屋外FF', value: '屋外FF' ,selected:false}
    ];

    @track transformerLowVoltageTable;
    @track loadDisconnectorTable;
    @track transformerStoragePanelHighVoltageTable;
    @track transformerStoragePanelLowVoltageTable;
    @track groundTransformerTable;
    @track groundTransformerWithNeutralPointTable;
    @track transformersLightingAndBuildingTable;
    @track thunderResistantTable;
    @track transformerHighVoltagePowerReceivingTable;
    @track isHasDetail;
    @track displayConditionMap;

    async connectedCallback() {
        console.log('detailsInputScreenBStorageBoard is loading');

        this.loaded = true;
        this.storageBoardValue = '屋内'
        getStorageBoardScreenInfo({init:true, deviceId : this.recordId, searchOption : this.storageBoardValue, inputsRecords : null})
            .then(result => {
                this.loaded = false;
                if(result) {
                    var resData = JSON.parse(result);
                    this.transformerLowVoltageTable = resData.transformerLowVoltageTable;
                    this.loadDisconnectorTable = resData.loadDisconnectorTable;
                    this.transformerStoragePanelHighVoltageTable = resData.transformerStoragePanelHighVoltageTable;
                    this.transformerStoragePanelLowVoltageTable = resData.transformerStoragePanelLowVoltageTable;
                    this.groundTransformerTable = resData.groundTransformerTable;
                    this.groundTransformerWithNeutralPointTable = resData.groundTransformerWithNeutralPointTable;
                    this.transformersLightingAndBuildingTable = resData.transformersLightingAndBuildingTable;
                    this.thunderResistantTable = resData.thunderResistantTable;
                    this.transformerHighVoltagePowerReceivingTable = resData.transformerHighVoltagePowerReceivingTable;

                    this.storageBoardValue = resData.searchOption.slice();
                    this.existingOption = resData.searchOption.slice();
                    this.updateOption(resData.searchOption);

                    this.displayConditionMap = new Map([...Object.entries(resData.transformerStoragePanelHighVoltageTable.displayConditionMap), ...Object.entries(resData.transformerStoragePanelLowVoltageTable.displayConditionMap)]);
                    //変圧器収納盤(高圧)
                    let isHighHasDetail = resData.transformerStoragePanelHighVoltageTable.isHasDetail;
                    //変圧器収納盤(低圧)
                    let isLowHasDetail = resData.transformerStoragePanelLowVoltageTable.isHasDetail;
                    let defultValueMap = new Map([...Object.entries(resData.transformerStoragePanelHighVoltageTable.recMap), ...Object.entries(resData.transformerStoragePanelLowVoltageTable.recMap)]);
                    
                    if(isHighHasDetail || isLowHasDetail){
                        this.defultInputsKyotaiRecords(defultValueMap);
                        this.defultDisplayCondition();                
                    }
                }
            })
            .catch(error => {
                this.loaded = false;
                console.log('----ERROR---');
                console.log(error);
            });

    }

    defultInputsKyotaiRecords(defultValueMap){
        var newRecord = {   'Id':defultValueMap.get('Id'),
                            'Quantity':1,
                            'Price':this.priceCalculator({
                                            UnitPrice__c: defultValueMap.get('Price'),
                                            Quantity__c: defultValueMap.get('Quantity')
                                        }),
                            'UnitPrice':defultValueMap.get('Price')//単価
                        };
        this.inputsKyotaiRecords.push(newRecord);
        console.log('defultInputsKyotaiRecords sss');
    }

    defultDisplayCondition(){
        let mapValues = new Map(Object.entries(this.displayConditionMap.get(this.inputsKyotaiRecords[0].Id)));                         
        //this.displayCondition=mapValues.get('condition');
        this.displayTotal=mapValues.get('price');
    }

    onSearch(event){
        console.log('onSearch is Start');
        this.loaded = true;
        var inputsRecords = JSON.stringify(this.inputsRecords);
        getStorageBoardScreenInfo({init:this.existingOption==this.storageBoardValue, deviceId : this.recordId, searchOption : this.storageBoardValue, inputsRecords : inputsRecords})
        .then(result => {
            if(result) {
                this.loaded = false;
                //クリアする
                this.inputsRecords = [];
                this.inputsKyotaiRecords = [];
                this.displayCondition = '';
                var mydata =JSON.parse(result);
                if (mydata) {
                    console.log('mydata is true');
                    this.template.querySelector('c-common-table[data-id="transformerLowVoltageTable"]').setTableObj(mydata.transformerLowVoltageTable);
                    this.template.querySelector('c-common-table[data-id="loadDisconnectorTable"]').setTableObj(mydata.loadDisconnectorTable);
                    this.template.querySelector('c-common-checkbox-table[data-id="transformerStoragePanelHighVoltageTable"]').setTableObj(mydata.transformerStoragePanelHighVoltageTable);
                    this.template.querySelector('c-common-checkbox-table[data-id="transformerStoragePanelLowVoltageTable"]').setTableObj(mydata.transformerStoragePanelLowVoltageTable);
                    this.template.querySelector('c-common-table[data-id="groundTransformerTable"]').setTableObj(mydata.groundTransformerTable);
                    this.template.querySelector('c-common-table[data-id="groundTransformerWithNeutralPointTable"]').setTableObj(mydata.groundTransformerWithNeutralPointTable);
                    this.template.querySelector('c-common-table[data-id="transformersLightingAndBuildingTable"]').setTableObj(mydata.transformersLightingAndBuildingTable);
                    this.template.querySelector('c-common-table[data-id="thunderResistantTable"]').setTableObj(mydata.thunderResistantTable);
                    this.template.querySelector('c-common-table[data-id="transformerHighVoltagePowerReceivingTable"]').setTableObj(mydata.transformerHighVoltagePowerReceivingTable);

                    // this.displayConditionMap = new Map([...Object.entries(mydata.transformerStoragePanelHighVoltageTable.displayConditionMap), ...Object.entries(mydata.transformerStoragePanelLowVoltageTable.displayConditionMap), ...this.displayConditionMap]);
                    // 変圧器収納盤(高圧)
                    // let isHighHasDetail = mydata.transformerStoragePanelHighVoltageTable.isHasDetail;
                    // 変圧器収納盤(低圧)
                    // let isLowHasDetail = mydata.transformerStoragePanelLowVoltageTable.isHasDetail;
                    // let defultValueMap = new Map([...Object.entries(mydata.transformerStoragePanelHighVoltageTable.recMap), ...Object.entries(mydata.transformerStoragePanelLowVoltageTable.recMap)]);                    
                    // if(isHighHasDetail || isLowHasDetail){
                    //     this.defultInputsKyotaiRecords(defultValueMap);
                    //     this.defultDisplayCondition();                
                    // }
                }
            }
            this.setTotalPrice();//金額を合計
        })
        .catch(error => {
            this.loaded = false;
            console.log(error);
        });

    }

    handleStorageBoard(event) {
        this.storageBoardValue = event.detail.value;
        this.updateOption(this.storageBoardValue);
    }

    updateOption(storageBoardValue) {
        this.storageBoardOptions.forEach(item => {
            if(item.value==storageBoardValue) {
                item.selected = true;
            } else {
                item.selected = false;
            }
        })
    }

    onCommonTableInputChange(event){
        let idChanged= event.detail.id;
        let cnt= event.detail.cnt;
        let price= event.detail.price;
        this.addtoInputRecords(idChanged,cnt,price);//入力情報に追加

        this.setTotalPrice();//金額を合計
    }

    onCommonCheckboxTableInputChange(event){
        let idChanged= event.detail.id;
        let cnt= event.detail.cnt;
        let price= event.detail.price;
        let isKyotai= event.detail.kyotai;
        var condition='';
        //var total='';
        if(isKyotai) {
            var exist = this.addtoInputKyotaiRecords(idChanged,cnt,price);
            console.log('exist');
            console.log(exist);
            if(exist=='NotExist' || exist=='SameID') {
                this.addtoInputRecords(idChanged,cnt,price);//入力情報に追加
            }else if(exist=='Existing') {
                event.detail.target.checked = false;
                const errEvent = new ShowToastEvent({
                    title: '入力エラー',
                    message: '2つ以上の筐体を追加する事は出来ません。',
                    variant: 'error',
                    mode: 'dismissable' 
                });
                this.dispatchEvent(errEvent);
            }            
            if(this.inputsKyotaiRecords.length > 0){
                let mapValues = new Map(Object.entries(this.displayConditionMap.get(this.inputsKyotaiRecords[0].Id)));            
                condition=mapValues.get('condition');
                //total=mapValues.get('price');
            }
            this.displayCondition=condition;
            this.setTotalPrice();//金額を合計
            //this.displayTotal=total;
        }// else {
        //     this.addtoInputRecords(idChanged,cnt,price);//入力情報に追加
        // }
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

    addtoInputRecords(idChanged,cnt,price){
        console.log('addtoInputRecords start');
        var inputsRecords = this.inputsRecords;
        var isNotIn = true;
        var checkDefultValues = [];
        if (inputsRecords!=null && inputsRecords.length > 0) {
            //一時保存情報を最新化する
            inputsRecords.forEach((item) => {
                var idRecord = item['Id'];
                checkDefultValues.push(idRecord);
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
            checkDefultValues.push(idChanged);
        }
        //親へ送信（保存用）
        var inputsKyotaiRecords = this.inputsKyotaiRecords;
        if(inputsKyotaiRecords.length>0){
            console.log(checkDefultValues.includes(inputsKyotaiRecords[0].Id));
            if(!checkDefultValues.includes(inputsKyotaiRecords[0].Id)){  
                var newRecord = {'Id':inputsKyotaiRecords[0].Id,
                                'Quantity':1,
                                'Price':this.priceCalculator({
                                                UnitPrice__c: price,
                                                Quantity__c: 1
                                            }),
                                'UnitPrice':inputsKyotaiRecords[0].UnitPrice//単価
                                };                            
                inputsRecords.push(newRecord);
            }
        }
        this.inputsRecords = inputsRecords;
        this.dispatchEvent(new CustomEvent('quantitychangeforstorageboard', {
            detail: {inputsRecords:this.inputsRecords} 
        }));
    }

    addtoInputKyotaiRecords(idChanged,cnt,price){
        console.log('addtoInputKyotaiRecords start');
        var inputsKyotaiRecords = this.inputsKyotaiRecords;
        console.log(inputsKyotaiRecords.length);
        if(cnt == 0 && inputsKyotaiRecords[0].Id == idChanged){
            this.inputsKyotaiRecords = [];
            return 'NotExist';
        }else{
            if (inputsKyotaiRecords.length > 0) {
                if (inputsKyotaiRecords[0].Id != idChanged) {
                    return 'Existing';
                } else {
                    return 'SameID';
                }
            } else {
                var newRecord = {'Id':idChanged,
                                'Quantity':1,
                                'Price':this.priceCalculator({
                                                UnitPrice__c: price,
                                                Quantity__c: 1
                                            }),
                                'UnitPrice':price//単価
                            };
                inputsKyotaiRecords.push(newRecord);
                this.inputsKyotaiRecords = inputsKyotaiRecords;
                return 'NotExist';
            }
        }        
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