import { LightningElement, track, wire, api } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import CLOSE_MODAL_CHANNEL from '@salesforce/messageChannel/Close_Modal__c';
import submitDetailsForExtraHigh from '@salesforce/apex/DetailsInputForExtraHighController.submitDetailsForExtraHigh';
import submitHighVoltageDetails from '@salesforce/apex/DetailsInputControllerForHighVoltage.submitHighVoltageDetails';
import submitSpHighVoltageDetails from '@salesforce/apex/DetailsInputControllerForSpHighVoltage.submitSpHighVoltageDetails';
import submitDetailsForLowVoltage from '@salesforce/apex/DetailsInputForLowVoltageController.submitDetailsForLowVoltage';
import submitDetailsForAcbBoard from '@salesforce/apex/DetailsInputForAcbBoardController.submitDetailsForAcbBoard';
import submitDetailsForFieldBoard from '@salesforce/apex/DetailsInputForFieldBoardController.submitDetailsForFieldBoard';
import submitDetailsForRelayBoard from '@salesforce/apex/DetailsInputForRelayBoardController.submitDetailsForRelayBoard';
import submitStorageBoardDetails from '@salesforce/apex/DetailsInputForStorageBoardController.submitStorageBoardDetails';
import submitControlCenterDetails from '@salesforce/apex/DetailsInputForControlCenterController.submitControlCenterDetails';
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
import Quantity from '@salesforce/schema/Asset.Quantity';

export default class QuoteManagementMainPage extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track isModalOpen = false;
    @track isModalBOpen = false;
    @track isModalBForHighLowVoltageOpen = false;//明細入力B_高圧TR1  明細入力B_高低圧TR1
    //大分類名「変圧器」かつ小分類名「機器事業部 変圧器」
    @track isModalBForEquipmentDivisionOpen = false;//明細入力B_高圧TR2 高低圧TR2 H種乾式変圧器
    @track isModalBForHighVoltageOpen = false;
    @track isModalBForSpcialHighVoltageOpen = false;
    @track isModalBForLowVoltageOpen = false;
    @track isModalBForFieldBoardOpen = false;
    @track isModalBForRelayBoardOpen = false;
    @track isModalBForControlCenterOpen = false;
    @track isModalBForStorageBoardOpen = false;
    @track isModalBForAcbBoardOpen = false;//内訳入力B_ACB盤
    @track isAddModalOpen = false;

    @track userDepartment;

    @track minorClassificationTitle ='明細入力B_特高 66kV C-GIS';//特高の明細B画面タイトルに使用

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

    @track quoteSelectList=[];
    //選択されたデータが変わる
    onCheckBoxChange(event){
        console.log("onChickBoxChange parent Start!!!!");
        console.log(this.quoteSelectList);
        //選択された情報を一時保存
        this.quoteSelectList = event.detail.quoteSelectList;
    }
    checkRequiredForAddModal(){
        var isError = true;
        //入力チェック
        var checkObj = this.inputObj;
        var idsList = this.quoteSelectList;
        if (checkObj === null || checkObj ===undefined|| checkObj.length===0) {
            isError = true;
        }else {
            // ・チェックボックスがチェックされたデータが1件もない場合
            //   →数量>0のデータが1件もない場合
            // 　→エラーメッセージ「数量入力していません。登録出来ません。」を表示する。
            // 　→数量>0のデータが1件以上ある場合
            // 　→数量>0のデータを明細オブジェクトへ保存する。
            if (idsList === null || idsList ===undefined|| idsList.length===0) {
                //明細に数量が入力された場合、OK
                checkObj.forEach((item) => {
                    var quantity = item.Quantity !== "" ? item.Quantity : null;
                    item.Quantity = quantity;
                    if (isError && isNotEmpty(item.Quantity) && parseInt(item.Quantity)>0) {
                        isError = false;
                    }
                });
                
            // ・チェックボックスがチェックされたデータが1件以上ある場合
            // 　→チェックボックスがチェックされたデータの中で数量>0が1件もない場合
            // 　→エラーメッセージ「数量入力していません。登録出来ません。」を表示する。
            // 　→チェックボックスがチェックされたデータの中で数量>0が1件以上ある場合
            // 　→チェックボックスがチェックされているかつ数量>0のデータを明細オブジェクトへ保存する。
            }else {
                //明細に数量が入力された場合、OK
                checkObj.forEach((item) => {
                    var quantity = item.Quantity !== "" ? item.Quantity : null;
                    item.Quantity = quantity;
                    if (isError && idsList.includes(item.Id) && isNotEmpty(item.Quantity) && parseInt(item.Quantity)>0) {
                        isError = false;
                    }
                });
            }
        }
        return isError;
    }

    //登録処理
    submitDetailsForAddModal(event) {
        console.log("submitDetailsForAddModal And close Modal!");
        var buttonId = event.currentTarget.dataset.id;
        var obj = this.template.querySelector('c-details-add-screen[data-id="detailsAddScreen"]');

        //入力チェック
        // var checkObj = this.inputObj;
        // if (checkObj === null || checkObj ===undefined
        //     || checkObj.length===0) {
        if(this.checkRequiredForAddModal()){
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '数量入力していません。登録出来ません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);

        } else{
            obj.loader=true;
            //
            var submitList=[];
            //チェックボックスがチェックされたデータが1件もない場合
            if (this.quoteSelectList === null || this.quoteSelectList ===undefined|| this.quoteSelectList.length===0) {
                submitList = this.inputObj;
            //チェックボックスがチェックされたデータが1件以上ある場合
            }else {
                this.inputObj.forEach((item) => {
                    if (this.quoteSelectList.includes(item.Id)) {
                        submitList.push(item);
                    }
                });
            }

            var draftDetail = JSON.stringify(submitList);
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

        var noteFlg = false; // 備考未入力エラーフラグ
        var priceEmptyFlg = false; // WC&単価未入力エラーフラグ
        
        this.newRecords.forEach((item) => {
            // WC&単価の未入力チェック
            if (item.Id.includes('rowIndex') 
                 && (item.UnitPrice===null || item.UnitPrice==='' || item.UnitPrice===undefined)
                 && (item.CreditWC===null || item.CreditWC==='' || item.CreditWC===undefined)
                ){
                    priceEmptyFlg = true;
                // return;
            }
            // 備考未入力のチェック
            if (item.Id.includes('rowIndex') 
                 && (item.UnitPrice!=null &&item.UnitPrice!='' && item.UnitPrice!=undefined)
                 && (item.Note===null || item.Note==='' || item.Note===undefined)
                ){
                    noteFlg = true;
                // return;
            }
        });
        if (priceEmptyFlg) {
            const event = new ShowToastEvent({
                title: '入力エラー',
                message: 'WC単価と単価のどちらにも値が入っていない明細があります。いずれかの値を入力してください。',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return true;
        }
        if (noteFlg) {
            const event = new ShowToastEvent({
                title: '入力エラー',
                message: '備考に単価(円)設定根拠を入力してください。',
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

                const dedails = this.device.Details__r;
                //明細の中に「価格表ユニークキー」が重複した明細が2つ以上ある場合
                let duplCheck = false;
                //利用中の場合　品名1 !=「配線材料費」AND ( WC係数 != null OR 単価係数 != null OR 提供単価 != null)
                let usedCheck = false;
                let msg = '';
                if (dedails != null && dedails.length > 0){
                    let pricingTableUniqueKey = '';
                    //明細の状況を出力
                    dedails.forEach((item) => {
                        //明細の中に「価格表ユニークキー」が重複した明細が2つ以上ある場合
                        if (isNotEmpty(item.PricingTableUniqueKey__c) && pricingTableUniqueKey == item.PricingTableUniqueKey__c){
                            duplCheck = true;
                            msg = '同一マスタを使用した明細が重複しているため明細入力B画面は使用出来ません。';
                            return true;//エラーの場合、中断
                        }
                        //明細の中に下記条件を満たす明細がある場合
                        //品名1 !=「配線材料費」AND
                        //( WC係数 != null OR 単価係数 != null OR 提供単価 != null)
                        if (isNotEmpty(item.PricingTableUniqueKey__c)
                            && item.Name1__c != '配線材料費' 
                            &&(isNotEmpty(item.WcCoefficient__c)
                                || isNotEmpty(item.UnitPriceCoefficient__c)
                                || isNotEmpty(item.ProvisionUnitPrice__c))){
                            usedCheck = true;
                            msg = 'WC、単価係数、提供単価のいずれかを使用している明細があるため明細入力B画面は使用出来ません。';
                            return true;//エラーの場合、中断
                        }
                        pricingTableUniqueKey = item.PricingTableUniqueKey__c;
                    });
                }
                if (this.userDepartment != recordDepartment) {
                    const event = new ShowToastEvent({
                        title: '',
                        message: '他支社の見積は編集できません。',
                        variant: 'warning',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                } else if (duplCheck || usedCheck) {
                    const event = new ShowToastEvent({
                        title: '',
                        message: msg,
                        variant: 'warning',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                } else {

                    if (this.device.MajorClassification__c==='高圧受配電盤') {
                        this.isModalBForHighVoltageOpen = true;//内訳入力B_高圧受配電盤
                    } else if (this.device.MajorClassification__c === '低圧・現場・リレー・ACB盤' && this.device.MinorClassification__c === '低圧盤') {
                        this.isModalBForLowVoltageOpen = true; //内訳入力B_低圧配電盤
                    } else if (this.device.MajorClassification__c === '低圧・現場・リレー・ACB盤' && this.device.MinorClassification__c === 'ACB盤') {
                        this.isModalBForAcbBoardOpen = true; //内訳入力B_ACB盤
                    } else if (this.device.MajorClassification__c === '低圧・現場・リレー・ACB盤' && this.device.MinorClassification__c === '現場盤') {
                        this.isModalBForFieldBoardOpen = true; //内訳入力B_低圧配電盤
                    } else if (this.device.MajorClassification__c === '低圧・現場・リレー・ACB盤' && this.device.MinorClassification__c === 'リレー盤') {
                        this.isModalBForRelayBoardOpen = true; //明細入力B_リレー盤
                    } else if (this.device.MajorClassification__c === 'コントロールセンタ(C/C)') {
                        this.isModalBForControlCenterOpen = true;//明細入力B_コントロールセンタ
                    } else if (this.device.MajorClassification__c === '変圧器' && this.device.MinorClassification__c === '高圧変圧器') {
                        this.isModalBForHighLowVoltageOpen = true;//明細入力B_高圧TR1_高低圧TR1
                    //大分類名「変圧器」かつ小分類名「機器事業部 変圧器」
                    } else if (this.device.MajorClassification__c === '変圧器' && this.device.MinorClassification__c === '機器事業部 変圧器') {
                        this.isModalBForEquipmentDivisionOpen = true;//明細入力B_高圧TR2 高低圧TR2 H種乾式変圧器
                    } else if (this.device.MajorClassification__c === '変圧器' && this.device.MinorClassification__c === '変圧器収納盤') {
                        this.isModalBForStorageBoardOpen = true;
                    } else if (this.device.MajorClassification__c === '変圧器' && this.device.MinorClassification__c === '特高変圧器')  {
                        this.isModalBOpen = true;//内訳入力B_特高TR
                    } else if (this.device.MajorClassification__c === '特高')  {
                        if(this.device.MinorClassification__c == '66kV C-GIS'){
                            this.isModalBForSpcialHighVoltageOpen = true;//内訳入力B_特高
                            this.minorClassificationTitle  = '明細入力B_特高 66kV C-GIS';
                        }else if(this.device.MinorClassification__c == '22kV C-GIS'){
                            this.isModalBForSpcialHighVoltageOpen = true;//内訳入力B_特高
                            this.minorClassificationTitle  = '明細入力B_特高 22kV C-GIS';
                        }else if(this.device.MinorClassification__c == 'ブロック(気中)キュービクル'){
                            this.isModalBForSpcialHighVoltageOpen = true;//内訳入力B_特高
                            this.minorClassificationTitle  = '明細入力B_特高 ブロック(気中)キュービクル';
                        }else{
                            const event = new ShowToastEvent({
                                title: '',
                                message: '明細入力B画面が利用できません。',
                                variant: 'warning',//info/success/warning/error
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                        }
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
        this.isModalBForSpcialHighVoltageOpen = false;
        this.isModalBForLowVoltageOpen = false;
        this.isModalBForAcbBoardOpen = false;
        this.isModalBForFieldBoardOpen = false;
        this.isModalBForRelayBoardOpen = false;
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
        console.log('リストサイズ' + this.inputObjForHighVoltage.length);
        console.log(this.inputObjForHighVoltage);
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
    //--------------------------内訳入力B_特高--------------------------
    //@track rIdForSH = null;
    @track inputObjForSpHigh = [];
    //@track loaded = false;
    //一覧に数量が入力された場合
    onQuantityChangeForSpHigh(event){
        console.log('onQuantityChangeForSpHighVoltage Start');
        console.log('target'+event.Target);
        console.log('current'+event.currentTarget);
        console.log('type'+event.type);

        //画面入力情報を一時保存
        this.inputObjForSpHigh = event.detail.inputsRecords;

        console.log('リストサイズ' + this.inputObjForSpHigh.length);
        console.log(this.inputObjForSpHigh);
    }

    checkRequiredForSpHigh(){
        console.log('checkRequiredForSpHigh');
        var isNotNull = true;
        //明細に数量が入力された場合、OK
        this.inputObjForSpHigh.forEach((item) => {
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

    //内訳入力B_特高 保存ボタン処理
    submitDetailsForSpecialHighVoltage(event){
        
        console.log("submitDetailsForSpecialHighVoltage And close Modal!");
        console.log(this.inputObjForSpHigh);
        var buttonId = event.currentTarget.dataset.id;

        if (this.checkRequiredForSpHigh()){
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '登録するデータがありません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        } else {
            var obj = this.template.querySelector('c-details-input-screen-b-for-sp-high-voltage');
            obj.loaded=true;
            //空白文字をnullに転換
            this.inputObjForSpHigh.forEach((item) => {
                var price = item.Price !== "" ? item.Price : null;
                item.Price = price;
                var quantity = item.Quantity !== "" ? item.Quantity : null;
                item.Quantity = quantity;
            });
            var draftDetail = (this.inputObjForSpHigh!=null&&this.inputObjForSpHigh.length>0
                ?JSON.stringify(this.inputObjForSpHigh):null);
            submitSpHighVoltageDetails({details: draftDetail, deviceId: this.recordId})
                .then(result => {
                    console.log('result');
                    console.log(result);
                    obj.loaded=false;
                    if (result!='Error') {
                        const event = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '明細を登録しました',
                            variant: 'success',//info/success/warning/error
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        if (buttonId==='SaveForSpHighVoltageToDivice') {
                            this.isModalBForSpcialHighVoltageOpen = false;
                            this.inputObjForSpHighVoltage=[];
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
                    obj.loaded=false;
                    console.log(error);
                });
        }
    }
    //--------------------------内訳入力B_特高--------------------------
    //--------------------------内訳入力B_低圧配電盤-↓↓↓↓↓↓↓↓↓↓↓↓↓------------
    
    //内訳入力B_低圧配電盤 保存ボタン処理
    @track rIdForLV=null;//価格表Id
    @track optRecordsForLV=[];//明細入力情報

    //子画面から通信
    onScreenInputForLowVoltageChange(event){
        console.log(event.detail);
        this.rIdForLV = event.detail.rId;
        this.optRecordsForLV = event.detail.optRecords;
    }

    //入力必須チェック
    //筐体がチェックされた場合、OK
    //明細に数量が入力された場合、OK
    //上記以外の場合、「登録するデータがありません。」エラーとする
    checkRequiredForLV(){
        //筐体がチェックされた場合、OK
        if (isNotEmpty(this.rIdForLV)) {
            return false;
        }
        var isNotNull = true;
        //明細に数量が入力された場合、OK
        this.optRecordsForLV.forEach((item) => {
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
    //登録処理を行う
    submitDetailsForLowVoltage(event) {
        //ボタンを確定
        var buttonId = event.currentTarget.dataset.id;
        console.log(this.rIdForLV);
        console.log(this.optRecordsForLV);
        if (this.checkRequiredForLV()) {
            //チェックされていない場合
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '登録するデータがありません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }else{
            var obj = this.template.querySelector('c-details-input-screen-b-for-low-voltage-switch-board');
            obj.loaded=true;
            //空白文字をnullに転換
            this.optRecordsForLV.forEach((item) => {
                var price = item.Price !== "" ? item.Price : null;
                item.Price = price;
                var quantity = item.Quantity !== "" ? item.Quantity : null;
                item.Quantity = quantity;
            });
            var strOptRecords = (this.optRecordsForLV!=null&&this.optRecordsForLV.length>0
                ?JSON.stringify(this.optRecordsForLV)
                :null);
            //登録を行う
            submitDetailsForLowVoltage({
                deviceId: this.recordId,
                recordId: this.rIdForLV,
                strOptRecords:strOptRecords
            })
            .then(result => {
                console.log("submitDetailsForHighLowVoltage success");
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
                    if (buttonId==='SaveForLowVoltageToDivice') {
                        this.rIdForLV=null;
                        this.optRecordsForLV=[];
                        this.isModalBForLowVoltageOpen = false;
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
        }
    }
    //--------------------------内訳入力B_低圧配電盤-↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑------------

    //--------------------------内訳入力B_ACB盤-↓↓↓↓↓↓↓↓↓↓↓↓↓------------
    
    //内訳入力B_Acb盤 保存ボタン処理
    @track rIdForAcb=null;//価格表Id
    @track optRecordsForAcb=[];//明細入力情報

    //子画面から通信
    onScreenInputForAcbBoardChange(event){
        console.log(event.detail);
        this.rIdForAcb = event.detail.rId;
        this.optRecordsForAcb = event.detail.optRecords;
    }

    //入力必須チェック
    //筐体がチェックされた場合、OK
    //明細に数量が入力された場合、OK
    //上記以外の場合、「登録するデータがありません。」エラーとする
    checkRequiredForAcb(){
        //筐体がチェックされた場合、OK
        if (isNotEmpty(this.rIdForAcb)) {
            return false;
        }
        var isNotNull = true;
        //明細に数量が入力された場合、OK
        this.optRecordsForAcb.forEach((item) => {
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
    //登録処理を行う
    submitDetailsForAcbBoard(event) {
        //ボタンを確定
        var buttonId = event.currentTarget.dataset.id;
        console.log(buttonId);
        if (this.checkRequiredForAcb()) {
            //チェックされていない場合
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '登録するデータがありません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }else{
            var obj = this.template.querySelector('c-details-input-screen-b-for-acb-board');
            obj.loaded=true;
            //空白文字をnullに転換
            this.optRecordsForAcb.forEach((item) => {
                var price = item.Price !== "" ? item.Price : null;
                item.Price = price;
                var quantity = item.Quantity !== "" ? item.Quantity : null;
                item.Quantity = quantity;
            });
            var strOptRecords = (this.optRecordsForAcb!=null&&this.optRecordsForAcb.length>0
                ?JSON.stringify(this.optRecordsForAcb)
                :null);
            //登録を行う
            submitDetailsForAcbBoard({
                deviceId: this.recordId,
                recordId: this.rIdForAcb,
                strOptRecords:strOptRecords
            })
            .then(result => {
                console.log("submitDetailsForAcbBoard success");
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
                    if (buttonId==='SaveForAcbBoardToDivice') {
                        this.rIdForAcb=null;
                        this.optRecordsForLV=[];
                        this.isModalBForAcbBoardOpen = false;
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
        }
    }
    //--------------------------内訳入力B_ACB盤-↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑------------

    //--------------------------明細入力B_現場盤-↓↓↓↓↓↓↓↓↓↓↓↓↓------------
    
    //明細入力B_現場盤 保存ボタン処理
    @track rIdForFB=null;//価格表Id
    @track optRecordsForFB=[];//明細入力情報

    //子画面から通信
    onScreenInputForFieldBoardChange(event){
        console.log(event.detail);
        this.rIdForFB = event.detail.rId;
        this.optRecordsForFB = event.detail.optRecords;
    }

    //入力必須チェック
    //筐体がチェックされた場合、OK
    //明細に数量が入力された場合、OK
    //上記以外の場合、「登録するデータがありません。」エラーとする
    checkRequiredForFB(){
        //筐体がチェックされた場合、OK
        if (isNotEmpty(this.rIdForFB)) {
            return false;
        }
        var isNotNull = true;
        //明細に数量が入力された場合、OK
        this.optRecordsForFB.forEach((item) => {
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
    //登録処理を行う
    submitDetailsForFieldBoard(event) {
        //ボタンを確定
        var buttonId = event.currentTarget.dataset.id;
        console.log(this.rIdForFB);
        console.log(this.optRecordsForFB);
        if (this.checkRequiredForFB()) {
            //チェックされていない場合
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '登録するデータがありません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }else{
            var obj = this.template.querySelector('c-details-input-screen-b-for-field-board');
            obj.loaded=true;
            //空白文字をnullに転換
            this.optRecordsForFB.forEach((item) => {
                var price = item.Price !== "" ? item.Price : null;
                item.Price = price;
                var quantity = item.Quantity !== "" ? item.Quantity : null;
                item.Quantity = quantity;
            });
            var strOptRecords = (this.optRecordsForFB!=null&&this.optRecordsForFB.length>0
                ?JSON.stringify(this.optRecordsForFB)
                :null);
            //登録を行う
            submitDetailsForFieldBoard({
                deviceId: this.recordId,
                recordId: this.rIdForFB,
                strOptRecords:strOptRecords
            })
            .then(result => {
                console.log("submitDetailsForFieldBoard success");
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
                    if (buttonId==='SaveForFieldBoardToDevice') {
                        this.rIdForFB=null;
                        this.optRecordsForFB=[];
                        this.isModalBForFieldBoardOpen = false;
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
        }
    }
    //--------------------------明細入力B_現場盤-↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑------------


    //--------------------------明細入力B_リレー盤-↓↓↓↓↓↓↓↓↓↓↓↓↓------------
    
    //明細入力B_現場盤 保存ボタン処理
    @track rIdForRB=null;//価格表Id
    @track optRecordsForRB=[];//明細入力情報

    //子画面から通信
    onScreenInputForRelayBoardChange(event){
        console.log(event.detail);
        this.rIdForRB = event.detail.rId;
        this.optRecordsForRB = event.detail.optRecords;
    }

    //入力必須チェック
    //筐体がチェックされた場合、OK
    //明細に数量が入力された場合、OK
    //上記以外の場合、「登録するデータがありません。」エラーとする
    checkRequiredForRB(){
        //筐体がチェックされた場合、OK
        if (isNotEmpty(this.rIdForRB)) {
            return false;
        }
        var isNotNull = true;
        //明細に数量が入力された場合、OK
        this.optRecordsForRB.forEach((item) => {
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
    //登録処理を行う
    submitDetailsForRelayBoard(event) {
        //ボタンを確定
        var buttonId = event.currentTarget.dataset.id;
        console.log(this.rIdForRB);
        console.log(this.optRecordsForRB);
        if (this.checkRequiredForRB()) {
            //チェックされていない場合
            const event = new ShowToastEvent({
                title: '未入力エラー',
                message: '登録するデータがありません。',
                variant: 'error',//info/success/warning/error
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }else{
            var obj = this.template.querySelector('c-details-input-screen-b-for-relay-board');
            obj.loaded=true;
            //空白文字をnullに転換
            this.optRecordsForRB.forEach((item) => {
                var price = item.Price !== "" ? item.Price : null;
                item.Price = price;
                var quantity = item.Quantity !== "" ? item.Quantity : null;
                item.Quantity = quantity;
            });
            var strOptRecords = (this.optRecordsForRB!=null&&this.optRecordsForRB.length>0
                ?JSON.stringify(this.optRecordsForRB)
                :null);
            //登録を行う
            submitDetailsForRelayBoard({
                deviceId: this.recordId,
                recordId: this.rIdForRB,
                strOptRecords:strOptRecords
            })
            .then(result => {
                console.log("submitDetailsForRelayBoard success");
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
                    if (buttonId==='SaveForRelayBoardToDivice') {
                        this.rIdForRB=null;
                        this.optRecordsForRB=[];
                        this.isModalBForRelayBoardOpen = false;
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
        }
    }
    //--------------------------明細入力B_現場盤-↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑------------
    /*
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

        //--------------------------内訳入力B_コントロールセンタ--------------------------
        @track inputObjForControlCenter = [];
        @track cntForControlCenter;
        //一覧に数量が入力された場合
        onQuantityChangeForControlCenter(event){
            console.log('onQuantityChangeForControlCenter Start');
    
            console.log(this.inputObjForControlCenter);
            console.log('cntForControlCenter'+ this.cntForControlCenter);
            //画面入力情報を一時保存
            this.inputObjForControlCenter = event.detail.inputsRecords;
            this.cntForControlCenter = event.detail.cnt;
        }

        checkRequiredForCC(){
            var isNotNull = true;
            //明細に数量が入力された場合、OK
            this.inputObjForControlCenter.forEach((item) => {
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
    
        //明細入力B_コントロールセンタ 保存ボタン処理
        submitControlCenterDetails(event){
            console.log("submitDetailsForControlCenter And close Modal!");
            console.log(this.inputObjForControlCenter);
    
            var buttonId = event.currentTarget.dataset.id;
            if (this.checkRequiredForCC()){
                    const event = new ShowToastEvent({
                        title: '未入力エラー',
                        message: '登録するデータがありません。',
                        variant: 'error',//info/success/warning/error
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
    
            }else {
                var obj = this.template.querySelector('c-details-input-screen-b-for-control-center');
                obj.loaded=true;
                this.inputObjForControlCenter.forEach((item) => {
                    var price = item.Price !== "" ? item.Price : null;
                    item.Price = price;
                    var quantity = item.Quantity !== "" ? item.Quantity : null;
                    item.Quantity = quantity;
                });
                var draftDetail = (this.inputObjForControlCenter!=null&&this.inputObjForControlCenter.length>0
                    ?JSON.stringify(this.inputObjForControlCenter):null);
                submitControlCenterDetails({
                    details: draftDetail,
                    deviceId: this.recordId,
                    cnt:this.cntForControlCenter
                })
                .then(result => {
                    console.log('result');
                    console.log(result);
                    obj.loaded=false;
                    if (result!='Error') {
                        const event = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '明細を登録しました',
                            variant: 'success',//info/success/warning/error
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        //this.inputObjForHighVoltage=[];

                        if (buttonId==='SaveForControlCenterToDivice') {
                            this.isModalBForControlCenterOpen = false;
                            this.inputObjForControlCenter=[];
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
                    obj.loaded=false;
                    console.log(error);
                });
            }
        }
    
        //--------------------------内訳入力B_コントロールセンタ--------------------------

    //--------------------------内訳入力_国交省機器管理費対象--------------------------start
    //modalを開く
    // @track isModalOpenNew = false;
    // //modalを開く
    // openModal() {
    //     getDevice({recordId: this.recordId})
    //     .then(result => {
    //         if(result) {
    //             this.device = result[0];

    //             //事業部チェック
    //             console.log('事業部チェック');
    //             console.log(this.userDepartment);
    //             let recordDepartment = '';
    //             if (this.device.OwnerBranchOffice__c === null || this.device.OwnerBranchOffice__c === undefined || this.device.OwnerBranchOffice__c.length===0){
    //                 recordDepartment = '';
    //             }else{
    //                 const recordDepartmentList = this.device.OwnerBranchOffice__c.split("　");
    //                 recordDepartment = recordDepartmentList[0];
    //                 if(this.userDepartment === ''){
    //                     this.userDepartment = recordDepartment;
    //                 }
    //             }
    //             console.log(recordDepartment);
    //             if (this.userDepartment != recordDepartment) {
    //                 const event = new ShowToastEvent({
    //                     title: '',
    //                     message: '他支社の見積は編集できません。',
    //                     variant: 'warning',//info/success/warning/error
    //                     mode: 'dismissable'
    //                 });
    //                 this.dispatchEvent(event);
    //             } else {
    //                 if (this.device.MajorClassification__c==='国交省機器管理費') {
    //                     this.isModalOpenNew = true;//国交省機器管理費 内訳入力
    //                 }else {
    //                     const event = new ShowToastEvent({
    //                         title: '',
    //                         message: '国交省機器管理費 内訳入力画面が利用できません。',
    //                         variant: 'warning',//info/success/warning/error
    //                         mode: 'dismissable'
    //                     });
    //                     this.dispatchEvent(event);
    //                 }
    //             }
    //         }
    //     })
    //     .catch(error => {
    //         console.log(error);
    //     });



    // }
    
    // //クローズ
    // closeModal() {
    //     console.log("close Modal!");
    //     this.isModalOpenNew = false;
    //     eval("$A.get('e.force:refreshView').fire();");
    // }

    // @track parentInfo = {}; //国交省機器管理費対象情報
    // @track childInfo = [];//紐づけ見積項目
    // //一覧に数量が入力された場合
    // OnParentChanged(event){
    //     console.log('OnParentChanged Parent Start');
    //     //画面入力情報を一時保存
    //     this.parentInfo = event.detail.parentInfo;
    //     console.log(this.parentInfo);
    // }

    // //一覧に数量が入力された場合
    // OnChildChanged(event){
    //     console.log('OnChildChanged Parent Start');
    //     //画面入力情報を一時保存
    //     this.childInfo = event.detail.childInfo;
    //     console.log(this.childInfo);
    // }

    // //内訳入力_国交省機器管理費対象 保存ボタン処理
    // submitMlitInfo(event){
    //     console.log('submitMlitInfo Parent Start');
    //     var parentInfo = (this.parentInfo!=null?JSON.stringify(this.parentInfo):null);
    //     var childInfo = (this.childInfo!=null?JSON.stringify(this.childInfo):null);
    //     var obj = this.template.querySelector('c-details-input-screen-for-mlit[data-id="screenmlit"]');
    //     console.log(obj.loader);
    //     obj.loader=true;//spinner表示制御

    //     console.log(parentInfo);
    //     //検索Apexを呼び出し
    //     submitMlitInfo({
    //         recordId:this.recordId, //見積項目ID
    //         parentInfo: parentInfo,//国交省機器管理費対象情報
    //         childInfo: childInfo//紐づけ見積項目
    //     }).then(result => {
    //         console.log('submitMlitInfo:::::'+ result);

    //         obj.loader=false;//spinner表示制御⇒解除
    //         const event = new ShowToastEvent({
    //             title: 'SUCCESS',
    //             message: '国交省機器管理費集計情報を保存しました',
    //             variant: 'success',//info/success/warning/error
    //             mode: 'dismissable'
    //         });
    //         this.dispatchEvent(event);
    //         this.isModalOpenNew = false;
    //         eval("$A.get('e.force:refreshView').fire();");
    //     })
    //     .catch(error => {
    //         this.loader = false;
    //         console.log(error);
    //     });
    // }
    //--------------------------内訳入力_国交省機器管理費対象--------------------------end

}