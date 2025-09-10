import { LightningElement, track ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class commonMultiHeaderTable extends LightningElement {

    @api tableObj;
    @track multiTable;
    @track secTitle;
    @track noteList;
    @track comment;
    @track isNodata;

    @api
    setTableObj(preObj) {
        console.log("common Multi Header Table setTableObj Loaded");
        if (preObj){
            this.isNodata=false;
            this.secTitle=preObj.secTitle;
            if (preObj.multiTable && preObj.multiTable.length>0){

                this.comment=preObj.comment;
                this.multiTable=preObj.multiTable;
                this.noteList=preObj.noteList;
                //数量が入力のデータ
                //数量が入力のデータ
                for (let s = 0; s < this.multiTable.length; s++) {
                    for (let i = 0; i < this.multiTable[s]['bodyList'].length; i++) {
                        var row = this.multiTable[s]['bodyList'][i];
                        for (let j = 0; j < row.cellList.length; j++) {
                            var cell = row.cellList[j];
                            //編集セル
                            if (cell.isEdit){
                            var quantityObj =  cell.value;
                                //数量が既に入力された
                                if (this.isNotEmpty(quantityObj.Quantity)) {
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
                }
            }else {
                this.isNodata=true;
            }
        }
    }

    //初期化処理
    connectedCallback() {
        console.log("common Multi Header Table connectedCallback Loaded");
        if (this.tableObj){
            this.isNodata=false;
            this.secTitle=this.tableObj.secTitle;
            if (this.tableObj.multiTable && this.tableObj.multiTable.length>0) {


                this.comment=this.tableObj.comment;
                this.headerList=this.tableObj.headerList;
                this.multiTable=this.tableObj.multiTable;
                this.noteList=this.tableObj.noteList;
                //数量が入力のデータ
                for (let s = 0; s < this.multiTable.length; s++) {
                    for (let i = 0; i < this.multiTable[s]['bodyList'].length; i++) {
                        var row = this.multiTable[s]['bodyList'][i];
                        for (let j = 0; j < row.cellList.length; j++) {
                            var cell = row.cellList[j];
                            //編集セル
                            if (cell.isEdit){
                                var quantityObj =  cell.value;
                                //数量が既に入力された
                                if (this.isNotEmpty(quantityObj.Quantity)) {
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
                }
            }else {
                this.isNodata=true;
            }
        }
	}

    handleScreenInputChange(event){
        console.log('CommonTableInputChange  start');
        let objName = event.currentTarget.dataset.id;
        let price = event.currentTarget.dataset.name;

        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        //数量が全角入力された際に半角に変換する 2023/06/06 TS木佐貫
        objInput.value = objInput.value.replace(/[０-９]/g, function(s) {
            return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
        });

        //仮　項目チェック
        let validity = event.target.validity;
        console.log(validity);
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
        const passEvent = new CustomEvent('commontableinputchange', {
            detail:{id:objName,
                    cnt:objInput.value,
                    price:price                    
                    // ,option:event.currentTarget.dataset.option
                    } 
        });
        this.dispatchEvent(passEvent);
    }
    //空白、Null、undefined以外の場合 true
    isNotEmpty(val){
        return (val!=null &&val!='' && val!=undefined);
    }
}