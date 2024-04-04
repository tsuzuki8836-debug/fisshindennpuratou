import { LightningElement, track ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CommonCheckboxTable extends LightningElement {

    @api tableObj;
    @track headerList;
    @track bodyList;
    @track secTitle;
    @track noteList;
    @track comment;
    @track isNodata;
    @track selectedId;
    
    @api
    setTableObj(preObj) {
        console.log("common Checkbox Table setTableObj Loaded");
        if (preObj){
            this.isNodata=false;
            this.secTitle=preObj.secTitle;
            this.selectedId=null;
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
                            console.log(quantityObj);
                            this.selectedId = quantityObj.Id;
                            const passEvent = new CustomEvent('commoncheckboxtableinputchange', {
                                detail:{id:quantityObj.Id,
                                        cnt:quantityObj.Quantity,
                                        price:quantityObj.Price,
                                        kyotai:true,
                                        target:{checked:true}
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
        console.log("common Checkbox Table setTableObj Loaded");

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
                                this.selectedId = quantityObj.Id;
                                const passEvent = new CustomEvent('commoncheckboxtableinputchange', {
                                    detail:{id:quantityObj.Id,
                                            cnt:quantityObj.Quantity,
                                            price:quantityObj.Price,
                                            kyotai:true,
                                            target:{checked:true}
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
        let objId = event.currentTarget.dataset.id;
        let price = event.currentTarget.dataset.name;
        let checked = event.currentTarget.checked;

        var objInput = this.template.querySelector('input[data-id="'+objId+'"]');

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
            this.dispatchEvent(errEvent);
            objInput.value='';
            return;
        }

        if (checked && this.selectedId!=null && this.selectedId!=undefined && this.selectedId!=objId) {
            console.log('commoncheckboxtableinputchangeYY');
            event.currentTarget.checked = false;
            const errEvent = new ShowToastEvent({
                title: '入力エラー',
                message: '2つ以上の筐体を追加する事は出来ません。',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errEvent);
        }else{
            console.log('commoncheckboxtableinputchangeXX');
            this.selectedId = checked ? objId : null;
            const passEvent = new CustomEvent('commoncheckboxtableinputchange', {
                detail:{id:objId,
                        cnt:checked ? 1 : 0,
                        price:price,
                        kyotai:true,
                        target:event.currentTarget
                        // ,option:event.currentTarget.dataset.option
                        } 
            });
            this.dispatchEvent(passEvent);
        }

    }
    //空白、Null、undefined以外の場合 true
    isNotEmpty(val){
        return (val!=null &&val!='' && val!=undefined);
    }
}