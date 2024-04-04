import { LightningElement, track, wire, api } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import CLOSE_MODAL_CHANNEL from '@salesforce/messageChannel/Close_Modal__c';
import submitDetailsForExtraHigh from '@salesforce/apex/DetailsInputForExtraHighController.submitDetailsForExtraHigh';
import submitHighVoltageDetails from '@salesforce/apex/DetailsInputControllerForHighVoltage.submitHighVoltageDetails';
//import submitDetailsForLowVoltage from '@salesforce/apex/DetailsInputForLowVoltageController.submitDetailsForLowVoltage';
import submitStorageBoardDetails from '@salesforce/apex/DetailsInputForStorageBoardController.submitStorageBoardDetails';
import submitDetailsForHLV from '@salesforce/apex/DetailsInputForHighLowVoltageController.submitDetails';
import submitDetailsForED from '@salesforce/apex/DetailsInputForEquipmentDivController.submitDetails';
import setDetail from '@salesforce/apex/DetailController.setDetail';
import submitAddDetail from '@salesforce/apex/DetailsAddController.submitDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDevice from '@salesforce/apex/DeviceController.getDevice';
import { NavigationMixin } from 'lightning/navigation';
import { isNotEmpty } from 'c/commonUtil';

import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import USER_FIELD from '@salesforce/schema/User.Division';

export default class QuoteManagementMainPage extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track isModalOpen = false;
    @track isModalBOpen = false;
    @track isModalBForHighLowVoltageOpen = false;//明細入力B_高圧TR1  明細入力B_高低圧TR1
    //大分類名「変圧器」かつ小分類名「機器事業部 変圧器」
    @track isModalBForEquipmentDivisionOpen = false;//明細入力B_高圧TR2 高低圧TR2 H種乾式変圧器
    @track isModalBForHighVoltageOpen = false;
    @track isModalBForLowVoltageOpen = false;
    @track isModalBForControlCenterOpen = false;
    @track isModalBForStorageBoardOpen = false;
    @track isAddModalOpen = false;

    @track userDepartment;

    @wire(getRecord, { recordId: Id, fields: [USER_FIELD]}) 
    currentUserInfo({error, data}) {
        if (data) {
            if (data.fields.Division.value === null || data.fields.Division.value === undefined || data.fields.Division.value===0){
                this.userDepartment = '';
            }else{
                const division = data.fields.Division.value.split("　");
                this.userDepartment = division[0];
            }
        }else if(error) {
            console.log(error);
        }
    }
    //----------------明細追加画面-------------------------
    //画面開き
    openAddModal() {
        getDevice({recordId: this.recordId})
        .then(result => {
            if(result) {
                this.device = result[0];
                //事業部チェック
                console.log('事業部チェック');
                console.log(this.userDepartment);
                let recordDepartment = '';
                if (this.device.OwnerBranchOffice__c === null || this.device.OwnerBranchOffice__c === undefined || this.device.OwnerBranchOffice__c.length===0){
                    recordDepartment = '';
                }else{
                    const recordDepartmentList = this.device.OwnerBranchOffice__c.split("　");
                    recordDepartment = recordDepartmentList[0];
                    if(this.userDepartment === ''){
                        this.userDepartment = recordDepartment;
                    }
                }
                console.log(recordDepartment);
                if (this.userDepartment != recordDepartment) {
                    const event = new ShowToastEvent({
                        title: '',
                        message: '他支社の見積は編集できません。',
                        variant: 'warning',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                } else {
                    this.isAddModalOpen = true;
                }
            }
        });
    }
    //画面閉じる
    closeAddModal() {
        this.inputObj =[];
        console.log("close Modal!");
        this.isAddModalOpen = false;
        eval("$A.get('e.force:refreshView').fire();");
    }
    //登録処理
    submitDetailsForAddModal(event) {
        console.log("submitDetailsForAddModal And close Modal!");
        var buttonId = event.currentTarget.dataset.id;
        var obj = this.template.querySelector('c-details-add-screen[data-id="detailsAddScreen"]');

        //入力チェック
        var checkObj = this.inputObj;
        if (checkObj === null || checkObj ===undefined
            || checkObj.length===0) {
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '数量入力していません。登録出来ません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);

        }else{
            obj.loader=true;
            var draftDetail = JSON.stringify(this.inputObj);
            console.log(draftDetail);
            //登録を行う。
            submitAddDetail({details: draftDetail,
                deviceId: this.recordId})
            .then(result => {
                if (result ==='error') {
                    const event = new ShowToastEvent({
                        title: 'ERROR',
                        message: 'システムエラーが発生しました、システム管理者まで連絡ください。',
                        variant: 'error',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);

                }else {
                    const event = new ShowToastEvent({
                        title: 'SUCCESS',
                        message: '明細を登録しました',
                        variant: 'success',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.inputObj=[];
                    this.isAddModalOpen = false;
                    eval("$A.get('e.force:refreshView').fire();");
                    //保存＆機器一覧へ の場合　遷移行う。
                    if (buttonId==='SaveAddModalToDevice') {
                        // Navigation to Contact related list of account
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result,
                                objectApiName: 'Quote__c',
                                // relationshipApiName: 'Devices__r',
                                actionName: 'view'
                            },
                        });
                    }
                }
                obj.loader=false;
            })
            .catch(error => {
                console.log(error);
            });
        }

    }
//----------------明細追加画面-------------------------
	connectedCallback() {
        console.log("Parent Loadded!");
        console.log(this.recordId);

        this.subscribeToMessageContextOnSaveButtonClick();
	}

    openModal() {
        getDevice({recordId: this.recordId})
        .then(result => {
            if(result) {
                this.device = result[0];
                //事業部チェック
                console.log('事業部チェック');
                console.log(this.userDepartment);
                let recordDepartment = '';
                if (this.device.OwnerBranchOffice__c === null || this.device.OwnerBranchOffice__c === undefined || this.device.OwnerBranchOffice__c.length===0){
                    recordDepartment = '';
                }else{
                    const recordDepartmentList = this.device.OwnerBranchOffice__c.split("　");
                    recordDepartment = recordDepartmentList[0];
                    if(this.userDepartment === ''){
                        this.userDepartment = recordDepartment;
                    }
                }
                console.log(recordDepartment);
                if (this.userDepartment != recordDepartment) {
                    const event = new ShowToastEvent({
                        title: '',
                        message: '他支社の見積は編集できません。',
                        variant: 'warning',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                } else {
                    this.isModalOpen = true;
                }
            }
        });
    }

    closeModal() {
        console.log("close Modal!");
        this.isModalOpen = false;
        eval("$A.get('e.force:refreshView').fire();");
    }

    //数量の入力が必須
    //行追加内容に備考が必須
    checkRequired(){
        var checkObj = this.inputObj;

        if (checkObj === null || checkObj ===undefined
            || checkObj.length===0) {
                const event = new ShowToastEvent({
                    title: '未入力エラー',
                    message: '数量入力していません。登録出来ません。',
                    variant: 'error',//info/success/warning/error
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                return true;
        }

        var noteFlg = false;
        this.newRecords.forEach((item) => {
            if (item.Id.includes('rowIndex') 
                 && (item.UnitPrice!=null &&item.UnitPrice!='' && item.UnitPrice!=undefined)
                 && (item.Note===null || item.Note==='' || item.Note===undefined)
                ){
                    noteFlg = true;
                // return;
            }
        });
        if (noteFlg) {
            const event = new ShowToastEvent({
                title: '入力エラー',
                message: '備考に価格設定根拠を入力してください。',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return true;
        }

        return false;
    }

    submitDetailsForA(event) {
        console.log("submitDetailsForA And close Modal!");

        console.log(this.inputObj);
        console.log(this.selectedOption);
        var buttonId = event.currentTarget.dataset.id;
        console.log(buttonId);
        
        var obj = this.template.querySelector('c-search-datatable[data-id="searchDatatable"]');
        console.log(obj.loader);
        obj.loader=true;
        //入力数量と新規行　に　数量がなし　場合　エラー
        if (this.checkRequired()){
                obj.loader=false;
        }else {
            var draftDetail = JSON.stringify(this.inputObj);
            var newRows = (this.newRecords!=null&&this.newRecords.length>0
                                ?JSON.stringify(this.newRecords)
                                :null);
            //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸ
            console.log(this.metaObj);
            console.log(JSON.stringify(this.metaObj));
            var metaObj = (this.metaObj!=null&&this.metaObj!=undefined
                ?JSON.stringify(this.metaObj)
                :null);

            console.log(metaObj);
            // draftDetail = JSON.parse( draftDetail );
            // console.log(draftDetail);
            setDetail({details: draftDetail, 
                        newRows:newRows,
                        metaObj:metaObj,
                        deviceId: this.recordId, 
                        selectedOption:this.selectedOption})
                .then(result => {
                    if (result ==='error') {
                        const event = new ShowToastEvent({
                            title: 'ERROR',
                            message: 'システムエラーが発生しました、システム管理者まで連絡ください。',
                            variant: 'error',//info/success/warning/error
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);

                    }else {
                        const event = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '明細を登録しました',
                            variant: 'success',//info/success/warning/error
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        //保存＆機器一覧へ の場合　遷移行う。
                        if (buttonId==='SaveToDevice') {
                            this.inputObj=[];
                            this.isModalOpen = false;
                            eval("$A.get('e.force:refreshView').fire();");
                            // Navigation to Contact related list of account
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: result,
                                    objectApiName: 'Quote__c',
                                    // relationshipApiName: 'Devices__r',
                                    actionName: 'view'
                                },
                            });
                        }
                    }
                    obj.loader=false;
                })
                .catch(error => {
                    console.log(error);
                });
                
        }
    }

    @track newRecords = [];
    //新規追加行の場合
    onNewRowChange(event){
        console.log('onNewRowChange Start');
        //画面入力情報を一時保存
        this.newRecords = event.detail.newRecords;
    }

    //検索　変更された場合
    onClearAll(event){
        console.log('onClearAll Start');
        this.selectedOption = false;
        this.inputObj = [];
        this.newRecords = [];
        // this.metaObj = {};
    }

    @track metaObj;
    //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸの場合
    //ヘッダーに入力された情報を保存
    onMetaChange(event){
        console.log('onMetaChange Start');
        var metaObj = this.metaObj;
        if (metaObj===undefined) metaObj = {};
        console.log(metaObj);
        console.log(event.detail.metaData);
        console.log(event.detail.codeIndex);
        var codeIndex = event.detail.codeIndex;
        if (codeIndex==='meta1') metaObj.meta1=event.detail.metaData;
        if (codeIndex==='meta2') metaObj.meta2=event.detail.metaData;
        if (codeIndex==='meta3') metaObj.meta3=event.detail.metaData;
        if (codeIndex==='meta4') metaObj.meta4=event.detail.metaData;
        if (codeIndex==='meta5') metaObj.meta5=event.detail.metaData;
        if (codeIndex==='meta6') metaObj.meta6=event.detail.metaData;
        if (codeIndex==='meta7') metaObj.meta7=event.detail.metaData;
        if (codeIndex==='meta8') metaObj.meta8=event.detail.metaData;
        if (codeIndex==='meta9') metaObj.meta9=event.detail.metaData;

        //画面入力情報を一時保存
        this.metaObj = metaObj;
    }

    @track selectedOption;
    //一般管理費　変更された場合
    onExpenseChange(event){
        console.log('onExpenseChange Start');
        var selectedOption = event.detail.selectedOption;
        if (selectedOption!==undefined &&  selectedOption!==null && selectedOption!=='') {
            this.selectedOption = selectedOption;
        }
    }

    @track inputObj = [];
    //一覧に数量が入力された場合
    onQuantityChange(event){
        console.log('onQuantityChange Start');

        console.log(this.inputObj);
        //画面入力情報を一時保存
        this.inputObj = event.detail.intensifyRecords;
    }

    @track device;
    openModalB() {
        this.rId=null;
        this.cnt=null;
        this.title=null;
        getDevice({recordId: this.recordId})
        .then(result => {
            if(result) {
                this.device = result[0];

                //事業部チェック
                console.log('事業部チェック');
                console.log(this.userDepartment);
                let recordDepartment = '';
                if (this.device.OwnerBranchOffice__c === null || this.device.OwnerBranchOffice__c === undefined || this.device.OwnerBranchOffice__c.length===0){
                    recordDepartment = '';
                }else{
                    const recordDepartmentList = this.device.OwnerBranchOffice__c.split("　");
                    recordDepartment = recordDepartmentList[0];
                    if(this.userDepartment === ''){
                        this.userDepartment = recordDepartment;
                    }
                }
                console.log(recordDepartment);
                if (this.userDepartment != recordDepartment) {
                    const event = new ShowToastEvent({
                        title: '',
                        message: '他支社の見積は編集できません。',
                        variant: 'warning',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                } else {

                    if (this.device.MajorClassification__c==='高圧受配電盤') {
                        this.isModalBForHighVoltageOpen = true;//内訳入力B_高圧受配電盤
                    } else if (this.device.MajorClassification__c === '低圧・現場・リレー盤' && this.device.MinorClassification__c === '低圧盤') {
                        this.isModalBForLowVoltageOpen = true; //内訳入力B_低圧配電盤
                    } else if (this.device.MajorClassification__c === 'Ｃ/Ｃ') {
                        this.isModalBForControlCenterOpen = true;
                    } else if (this.device.MajorClassification__c === '変圧器' && this.device.MinorClassification__c === '高圧変圧器') {
                        this.isModalBForHighLowVoltageOpen = true;//明細入力B_高圧TR1_高低圧TR1
                    //大分類名「変圧器」かつ小分類名「機器事業部 変圧器」
                    } else if (this.device.MajorClassification__c === '変圧器' && this.device.MinorClassification__c === '機器事業部 変圧器') {
                        this.isModalBForEquipmentDivisionOpen = true;//明細入力B_高圧TR2 高低圧TR2 H種乾式変圧器
                    } else if (this.device.MajorClassification__c === '変圧器' && (this.device.MinorClassification__c === '変圧器収納盤' || this.device.MinorClassification__c === 'バスダクト')) {
                        this.isModalBForStorageBoardOpen = true;
                    } else if (this.device.MajorClassification__c === '変圧器' && this.device.MinorClassification__c === '特高変圧器')  {
                        this.isModalBOpen = true;//内訳入力B_特高TR
                    }else {
                        const event = new ShowToastEvent({
                            title: '',
                            message: '明細入力B画面が利用できません。',
                            variant: 'warning',//info/success/warning/error
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                    }
                }
            }
        })
        .catch(error => {
            console.log(error);
        });


    }

    closeModalB() {
        this.rId=null;
        this.cnt=null;
        this.title=null;
        console.log("close ModalB!");
        this.isModalBOpen = false;
        this.isModalBForHighVoltageOpen = false;
        this.isModalBForLowVoltageOpen = false;
        this.isModalBForControlCenterOpen = false;
        this.isModalBForHighLowVoltageOpen = false;
        this.isModalBForEquipmentDivisionOpen = false;
        this.isModalBForStorageBoardOpen = false;
        eval("$A.get('e.force:refreshView').fire();");
    }

    //----------------明細入力B_高圧TR1 高低圧TR1↓↓↓↓↓↓-----------------
    @track rIdForHLV=null;//価格表Id
    submitDetailsForHLV(event){
        console.log("submit Details For HighLowVoltage!");
        console.log(this.rIdForHLV);
        //ボタンを確定
        var buttonId = event.currentTarget.dataset.id;
        if (isNotEmpty(this.rIdForHLV)) {
            var obj = this.template.querySelector('c-details-input-screen-b-for-high-low-voltage');
            obj.loader=true;
            //登録を行う
            submitDetailsForHLV({
                deviceId: this.recordId,
                recordId: this.rIdForHLV
            })
            .then(result => {
                console.log("submitDetailsForHighLowVoltage success");
                obj.loader=false;
                if(result) {
                    const event = new ShowToastEvent({
                        title: 'SUCCESS',
                        message: '明細を登録しました',
                        variant: 'success',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    //保存＆機器一覧へ の場合　遷移行う。
                    if (buttonId==='SaveBToDevice') {
                        this.rIdForHLV=null;
                        this.isModalBForHighLowVoltageOpen = false;
                        eval("$A.get('e.force:refreshView').fire();");
                        // Navigation to Contact related list of account
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result,
                                objectApiName: 'Quote__c',
                                actionName: 'view'
                            },
                        });
                    }
                }
            })
            .catch(error => {
                obj.loader=false;
                console.log(error);
            });
        }else{
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '✓が入力された筐体がありません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
    }
    //高圧TR1 高低圧TR1画面にチェックされた情報を一時保存
    onCheckBoxChangeForHLV(event){
        console.log(event.detail.rId);
        this.rIdForHLV = event.detail.rId;
    }
    //----------------明細入力B_高圧TR1 高低圧TR1↑↑↑↑↑↑-----------------

    //----------------明細入力B_高圧TR2 高低圧TR2↓↓↓↓↓↓-----------------
    @track rIdForED=null;//価格表Id
    @track optRecords=[];//付属品入力情報
    submitDetailsForED(event){
        console.log("submit Details For EquipmentDivision_TR2!");
        //ボタンを確定
        var buttonId = event.currentTarget.dataset.id;
        console.log(this.rIdForED);
        console.log(this.optRecords);
        if (this.checkRequiredForED()) {
            //チェックされていない場合
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '登録するデータがありません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }else{
            var obj = this.template.querySelector('c-details-input-screen-b-for-equipment-division');
            obj.loader=true;
            //空白文字をnullに転換
            this.optRecords.forEach((item) => {
                var price = item.Price !== "" ? item.Price : null;
                item.Price = price;
                var quantity = item.Quantity !== "" ? item.Quantity : null;
                item.Quantity = quantity;
            });
            var strOptRecords = (this.optRecords!=null&&this.optRecords.length>0
                ?JSON.stringify(this.optRecords)
                :null);
            //登録を行う
            submitDetailsForED({
                deviceId: this.recordId,
                recordId: this.rIdForED,
                strOptRecords:strOptRecords
            })
            .then(result => {
                console.log("submitDetailsForHighLowVoltage success");
                obj.loader=false;
                if(result) {
                    const event = new ShowToastEvent({
                        title: 'SUCCESS',
                        message: '明細を登録しました',
                        variant: 'success',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    // eval("$A.get('e.force:refreshView').fire();");
                    //保存＆機器一覧へ の場合　遷移行う。
                    if (buttonId==='SaveBToDevice') {
                        this.rIdForED=null;
                        this.optRecords=[];
                        this.isModalBForEquipmentDivisionOpen = false;
                        eval("$A.get('e.force:refreshView').fire();");
                        // Navigation to Contact related list of account
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result,
                                objectApiName: 'Quote__c',
                                // relationshipApiName: 'Devices__r',
                                actionName: 'view'
                            },
                        });
                    }
                }
            })
            .catch(error => {
                obj.loader=false;
                console.log(error);
            });
        }
    }
    onCheckBoxChangeForED(event){
        console.log(event.detail.rId);
        this.rIdForED = event.detail.rId;
        this.optRecords = event.detail.optRecords;
    }

    //入力必須チェック
    //筐体がチェックされた場合、OK
    //明細に数量が入力された場合、OK
    //上記以外の場合、「登録するデータがありません。」エラーとする
    checkRequiredForED(){
        //筐体がチェックされた場合、OK
        if (isNotEmpty(this.rIdForED)) {
            return false;
        }
        var isNotNull = true;
        //明細に数量が入力された場合、OK
        this.optRecords.forEach((item) => {
            var price = item.Price !== "" ? item.Price : null;
            item.Price = price;
            var quantity = item.Quantity !== "" ? item.Quantity : null;
            item.Quantity = quantity;
            if (isNotNull && isNotEmpty(item.Quantity) && parseInt(item.Quantity)>0) {
                isNotNull = false;
            }
        });
        return isNotNull;
    }

    //----------------明細入力B_高圧TR2 高低圧TR2↑↑↑↑↑↑-----------------



    @track rId=null;
    @track cnt=null;//単価
    @track title=null;//仕様１
    @track isError=false;//エラー
    submitDetails(event) {
        console.log("submit Details For ScreenB!");
        console.log(this.rId);
        console.log(this.cnt);
        console.log(this.title);
        var buttonId = event.currentTarget.dataset.id;
        console.log(buttonId);

        if (this.isError) {
            this.rId=null;
            this.cnt=null;
            this.title=null;
            this.isModalBOpen = false;
            eval("$A.get('e.force:refreshView').fire();");
            return;
        }
        if (isNotEmpty(this.rId)){
            var obj = this.template.querySelector('c-details-input-screen-b[data-id="detailsInputScreenB"]');
            obj.loaded=true;

            submitDetailsForExtraHigh({
                deviceId: this.recordId,
                rId: this.rId,
                cnt: this.cnt,
                title: this.title,
            })
            .then(result => {
                console.log("submitDetails success");
                obj.loaded=false;
                if(result) {
                    const event = new ShowToastEvent({
                        title: 'SUCCESS',
                        message: '明細を登録しました',
                        variant: 'success',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    // eval("$A.get('e.force:refreshView').fire();");
                    //保存＆機器一覧へ の場合　遷移行う。
                    if (buttonId==='SaveBToDevice') {
                        this.rId=null;
                        this.cnt=null;
                        this.title=null;
                        this.isModalBOpen = false;
                        eval("$A.get('e.force:refreshView').fire();");
                        // Navigation to Contact related list of account
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result,
                                objectApiName: 'Quote__c',
                                // relationshipApiName: 'Devices__r',
                                actionName: 'view'
                            },
                        });
                    }
                }
            })
            .catch(error => {
                obj.loaded=false;
                console.log(error);
            });
        }else {
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '✓が入力された筐体がありません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
       
    }
    onScreenInputChange(event){
        console.log(event.detail.value);
        console.log(event.detail.title);
        console.log(event.detail.rId);
        console.log(event.detail.isError);
        this.cnt = event.detail.value;
        this.title = event.detail.title;
        this.rId = event.detail.rId;
        this.isError = event.detail.isError;
    }

    //--------------------------内訳入力B_高圧受配電盤--------------------------
    @track inputObjForHighVoltage = [];
    //一覧に数量が入力された場合
    onQuantityChangeForHighVoltage(event){
        console.log('onQuantityChangeForHighVoltage Start');

        console.log(this.inputObjForHighVoltage);
        //画面入力情報を一時保存
        this.inputObjForHighVoltage = event.detail.inputsRecords;
    }

    //内訳入力B_高圧受配電盤 保存ボタン処理
    submitDetailsForHighVoltage(event){
        console.log("submitDetailsForHighVoltage And close Modal!");
        console.log(this.inputObjForHighVoltage);

        var buttonId = event.currentTarget.dataset.id;
        if (this.inputObjForHighVoltage === null || this.inputObjForHighVoltage ===undefined
            || this.inputObjForHighVoltage.length===0){
                const event = new ShowToastEvent({
                    title: '未入力エラー',
                    message: '登録するデータがありません。',
                    variant: 'error',//info/success/warning/error
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);

        }else {
            var draftDetail = JSON.stringify(this.inputObjForHighVoltage);
            // draftDetail = JSON.parse( draftDetail );
            // console.log(draftDetail);
            submitHighVoltageDetails({details: draftDetail, deviceId: this.recordId})
                .then(result => {
                    console.log('result');
                    console.log(result);
                    if (result!='Error') {
                        const event = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '明細を登録しました',
                            variant: 'success',//info/success/warning/error
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        //this.inputObjForHighVoltage=[];

                        if (buttonId==='SaveForHighVoltageToDivice') {
                            this.isModalBForHighVoltageOpen = false;
                            eval("$A.get('e.force:refreshView').fire();");
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: result,
                                    objectApiName: 'Quote__c',
                                    // relationshipApiName: 'Devices__r',
                                    actionName: 'view'
                                },
                            });
                        }
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        }
    }

    //--------------------------内訳入力B_高圧受配電盤--------------------------

    //--------------------------内訳入力B_低圧配電盤--------------------------
    /*onScreenInputForLowVoltageChange(event){
        this.rId = event.detail.rId;
        this.cnt = event.detail.value;
        this.title = event.detail.title;
        this.isError = event.detail.isError;
    }

    //内訳入力B_低圧配電盤 保存ボタン処理
    @track rId=null;
    @track cnt=null;//単価
    @track title=null;//仕様１
    @track isError=false;//エラー
    submitDetailsForLowVoltage() {
        if (this.isError) {
            this.rId=null;
            this.cnt=null;
            this.title=null;
            this.isModalBForLowVoltageOpen = false;
            eval("$A.get('e.force:refreshView').fire();");
            return;
        }
        if (this.cnt!=null && this.cnt!='' && this.cnt!=0 && this.cnt!=undefined){
            try {
                var obj = this.template.querySelector('c-details-input-screen-b-for-low-voltage-switch-board[data-id="detailsInputScreenBForLowVoltageSwitchBoard"]');
                obj.loaded=true;
            } catch (error) {
                console.log('CATCH ERROR: ' + error);
            }
            submitDetailsForLowVoltage({
                deviceId: this.recordId,
                rId: this.rId,
                cnt: this.cnt,
                title: this.title,
            })
            .then(result => {
                console.log("submitDetails success");
                obj.loaded=false;
                if(result) {
                    const event = new ShowToastEvent({
                        title: 'SUCCESS',
                        message: '明細を登録しました',
                        variant: 'success',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);

                    this.rId=null;
                    this.cnt=null;
                    this.title=null;
                    this.isModalBForLowVoltageOpen = false;
                    eval("$A.get('e.force:refreshView').fire();");
                }
            })
            .catch(error => {
                obj.loaded=false;
                console.log(error);
            });
        }else {
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: 'チェック済みのチェックボックスがありません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
       
    }

    onScreenInputForControlCenterChange(event) {
        console.log('Control Center Screen Input Change');
    }*/

    @wire(MessageContext)
    messageContextOnSaveButtonClick;
    subscribeToMessageContextOnSaveButtonClick() {
        this.subscription = subscribe(
            this.messageContextOnSaveButtonClick,
            CLOSE_MODAL_CHANNEL,
            (event) => this.closeModal()
        );
    }

    //--------------------------内訳入力B_変圧器収納盤及びその他--------------------------
    @track inputObjForStorageBoard = [];
    //一覧に数量が入力された場合
    onQuantityChangeForStorageBoard(event){
        console.log('onQuantityChangeForStorageBoard Start');

        console.log(this.inputObjForStorageBoard);
        //画面入力情報を一時保存
        this.inputObjForStorageBoard = event.detail.inputsRecords;
    }

    //内訳入力B_変圧器TR_変圧器収納盤及びその他 保存ボタン処理
    submitDetailsForStorageBoard(event){
        console.log("submitDetailsForStorageBoard And close Modal!");
        console.log(this.inputObjForStorageBoard);

    var buttonId = event.currentTarget.dataset.id;
        if (this.inputObjForStorageBoard === null || this.inputObjForStorageBoard ===undefined
            || this.inputObjForStorageBoard.length===0){
                const event = new ShowToastEvent({
                    title: '未入力エラー',
                    message: '登録するデータがありません。',
                    variant: 'error',//info/success/warning/error
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);

        }else {
            var draftDetail = JSON.stringify(this.inputObjForStorageBoard);
            // draftDetail = JSON.parse( draftDetail );
            // console.log(draftDetail);
            submitStorageBoardDetails({details: draftDetail, deviceId: this.recordId})
                .then(result => {
                    console.log('result');
                    console.log(result);
                    if (result!='Error') {
                        const event = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '明細を登録しました',
                            variant: 'success',//info/success/warning/error
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this.inputObjForStorageBoard=[];
                        //12/15add ByTS木佐貫
                        if (buttonId==='SaveForStorageBoardToDivice') {
                            this.isModalBForStorageBoardOpen = false;
                            eval("$A.get('e.force:refreshView').fire();");
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: result,
                                    objectApiName: 'Quote__c',
                                    // relationshipApiName: 'Devices__r',
                                    actionName: 'view'
                                },
                            });
                        }
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        }
    }
    //--------------------------内訳入力B_変圧器TR_変圧器収納盤及びその他--------------------------
}