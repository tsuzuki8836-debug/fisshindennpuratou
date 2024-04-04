import { LightningElement, track ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CommonTable extends LightningElement {

    @api tableObj;
    @api isOneSelector;
    @api errorMessage;
    @track headerList;
    @track bodyList;
    @track secTitle;
    @track noteList;
    @track comment;
    @track isNodata;
    @track selectedId;

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

    //初期化処理
    connectedCallback() {
        console.log("common Table connectedCallback Loaded");
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

    handleScreenInputChange(event){
        console.log('CommonTableInputChange  start');
        let objName = event.currentTarget.dataset.id;
        let price = event.currentTarget.dataset.name;
        console.log('CommonTableInputChange  start2');

        var objInput=this.template.querySelector('input[data-id="'+objName+'"]');
        //数量が全角入力された際に半角に変換する 2023/06/06 TS木佐貫
        objInput.value = objInput.value.replace(/[０-９]/g, function(s) {
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
            console.log('CommonTableInputChange  start3');
            this.dispatchEvent(errEvent);
            console.log('CommonTableInputChange  start4');
            objInput.value='';
            return;
        }

        if(this.isOneSelector && objInput.value!=0 && objInput.value!='' && this.selectedId!=null && this.selectedId!=undefined && this.selectedId!=objName) {
            const errEvent = new ShowToastEvent({
                title: '入力エラー',
                message: this.errorMessage,
                variant: 'error',
                mode: 'dismissable'
            });
            console.log('CommonTableInputChange  start5');
            this.dispatchEvent(errEvent);
            console.log('CommonTableInputChange  start6');
            this.setQuantityObj(objName, '')
        } else {
            if (this.isOneSelector) this.selectedId = objInput.value!=0 && objInput.value!='' ? objName : null;
            const passEvent = new CustomEvent('commontableinputchange', {
                detail:{id:objName,
                        cnt:objInput.value,
                        price:price                    
                        // ,option:event.currentTarget.dataset.option
                        }
            });
            console.log('CommonTableInputChange  start7');
            this.dispatchEvent(passEvent);
        }
    }
    //空白、Null、undefined以外の場合 true
    isNotEmpty(val){
        return (val!=null &&val!='' && val!=undefined);
    }

    @api
    setQuantityObj(tagId, value){
        console.log('setQuantityObj  start');
        this.template.querySelector('input[data-id="'+tagId+'"]').value = value;
        this.selectedId = value!=0&&value!=''?tagId:null
    }
}