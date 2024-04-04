import { LightningElement, track, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RECORD_SEARCH_CHANNEL from '@salesforce/messageChannel/Record_Search__c';
import CONDITION_CHANGE_CHANNEL from '@salesforce/messageChannel/Condition_Change__c';
import getUniqueNamePicklist from '@salesforce/apex/DetailController.getUniqueNamePicklist';
import { isNotEmpty } from 'c/commonUtil';

export default class FilterConditionPatternA extends LightningElement {

    @api recordId;

    //仕様条件の表示を制御
    @track isDetailNameShow;
    @track detailName;//明細名称
    @track isNameShow;
    @track isName1Show;//仕様1
    @track isName2Show;//仕様2
    @track isName3Show;//仕様3
    @track isName4Show;//仕様4
    @track isName5Show;//仕様5

    //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸの制御
    @track isMACTUS_OR_MELFLEX;
    @track isMACTUS;
    @track isOPS;
    @track isMELFLEX;
    @track isLargeScreen;
    @track meta1_Options = [];
    @track meta2_Options = [];
    @track meta6_Options = [];
    @track metadataValues = [];

    //仕様1
    @track name1_LabelName;//ラベル名
    @track name1_Options = [];//ドロップダウンリスト内容
	@track name1_SelectedOption;//選択された内容
	@track name1_isRequired = false;//必須フラグ
    //仕様１が変更あった場合、親に送信
    name1_Handler(event) {
        this.name1_SelectedOption = event.target.value;
        this.name2_SelectedOption =null;//再ロードので　クリアする
        this.name3_SelectedOption =null;//再ロードので　クリアする
        this.name4_SelectedOption =null;//再ロードので　クリアする
        this.name5_SelectedOption =null;//再ロードので　クリアする
        //仕様２～５連動
        this.wireUniqueNamePicklist(false);

        this.onChange();
	}

    //大型映像装置
    //横、縦　の入力値
    handleKeyUpmetaForLargeScreen(event){
        let codeIndex = event.currentTarget.dataset.code;
        //親に送信
		this.dispatchEvent(new CustomEvent('metachange', {
			detail: {metaData:event.target.value,
                    codeIndex:codeIndex} 
		}));
    }

    //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸ
    //プルダウン入力値を保存し、親に送信
    metaSelct_Handler(event) {
        let codeIndex = event.currentTarget.dataset.code;
        //親に送信
		this.dispatchEvent(new CustomEvent('metachange', {
			detail: {metaData:event.target.value,
                    codeIndex:codeIndex} 
		}));

    }
    //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸ
    //テキスト入力値を保存し、親に送信
    handleKeyUpmeta(event) {
        let codeIndex = event.currentTarget.dataset.code;
        //親に送信
		this.dispatchEvent(new CustomEvent('metachange', {
			detail: {metaData:event.target.value,
                    codeIndex:codeIndex} 
		}));
    }


    //仕様2
    @track name2_LabelName;//ラベル名
    @track name2_Options = [];//ドロップダウンリスト内容
	@track name2_SelectedOption;//選択された内容
	@track name2_isRequired = false;//必須フラグ
    //仕様２が変更あった場合、親に送信
    name2_Handler(event) {
        this.name2_SelectedOption = event.target.value;
        this.onChange();
	}

    //仕様3
    @track name3_LabelName;//ラベル名
    @track name3_Options = [];//ドロップダウンリスト内容
	@track name3_SelectedOption;//選択された内容
	@track name3_isRequired = false;//必須フラグ
    //仕様３が変更あった場合、親に送信
    name3_Handler(event) {
        this.name3_SelectedOption = event.target.value;
        this.onChange();
	}

    //仕様4		
    @track name4_LabelName;//ラベル名
    @track name4_Options = [];//ドロップダウンリスト内容
	@track name4_SelectedOption;//選択された内容
	@track name4_isRequired = false;//必須フラグ
    //仕様４が変更あった場合、親に送信
    name4_Handler(event) {
        this.name4_SelectedOption = event.target.value;
        this.onChange();
	}
    //仕様5		
    @track name5_LabelName;//ラベル名
    @track name5_Options = [];//ドロップダウンリスト内容
	@track name5_SelectedOption;//選択された内容
	@track name5_isRequired = false;//必須フラグ
    //仕様5が変更あった場合、親に送信
    name5_Handler(event) {
        this.name5_SelectedOption = event.target.value;
        this.onChange();
	}

    @track name6_LabelName;//ラベル名6
    @track name7_LabelName;//ラベル名7
    @track name8_LabelName;//ラベル名8
    @track name9_LabelName;//ラベル名9
    @track name10_LabelName;//ラベル名10
    @track name6_Options = [];//ドロップダウンリスト内容
    @track name7_Options = [];//ドロップダウンリスト内容
    @track name8_Options = [];//ドロップダウンリスト内容
    @track name9_Options = [];//ドロップダウンリスト内容
    @track name10_Options = [];//ドロップダウンリスト内容
    @track name6_SelectedOption;//選択された内容
    @track name7_SelectedOption;//選択された内容
    @track name8_SelectedOption;//選択された内容
    @track name9_SelectedOption;//選択された内容
    @track name10_SelectedOption;//選択された内容
    @track isName6Show;//仕様6
    @track isName7Show;//仕様7
    @track isName8Show;//仕様8
    @track isName9Show;//仕様9
    @track isName10Show;//仕様10
    //仕様6が変更あった場合、親に送信
    name6_Handler(event) {
        this.name6_SelectedOption = event.target.value;
        this.onChange();
	}
    //仕様7が変更あった場合、親に送信
    name7_Handler(event) {
        this.name7_SelectedOption = event.target.value;
        this.onChange();
	}
    //仕様8が変更あった場合、親に送信
    name8_Handler(event) {
        this.name8_SelectedOption = event.target.value;
        this.onChange();
	}
    //仕様9が変更あった場合、親に送信
    name9_Handler(event) {
        this.name9_SelectedOption = event.target.value;
        this.onChange();
	}
    //仕様10が変更あった場合、親に送信
    name10_Handler(event) {
        this.name10_SelectedOption = event.target.value;
        this.onChange();
	}
    //変圧器の場合だけ　盤条件を表示
    @track isBoardShow;
    //変圧器の場合　盤条件
    //設置場所 (名称2)
    @track board1_LabelName = '設置場所';//ラベル名
    @track board1_Options = [];//ドロップダウンリスト内容
	@track board1_SelectedOption;//選択された内容
    board1_Handler(event){
        this.board1_SelectedOption = event.target.value;
    }

    //標準盤外形寸法(名称4)
    @track board2_LabelName = '容量';//ラベル名
    @track board2_Options = [];//ドロップダウンリスト内容
	@track board2_SelectedOption;//選択された内容
    board2_Handler(event){
        this.board2_SelectedOption = event.target.value;
    }
    // //D (名称３)
    // @track board3_LabelName = 'D';//ラベル名
    // @track board3_Options = [];//ドロップダウンリスト内容
	// @track board3_SelectedOption;//選択された内容
    // board3_Handler(event){
    //     this.board3_SelectedOption = event.target.value;
    // }

    // //H (名称４)
    // @track board4_LabelName = 'H';//ラベル名
    // @track board4_Options = [];//ドロップダウンリスト内容
	// @track board4_SelectedOption;//選択された内容
    // board4_Handler(event){
    //     this.board4_SelectedOption = event.target.value;
    // }


    //コード検索1	
    @track code1_LabelName = 'コード1';
	@track code1_Value = '';

    //コード検索2
    @track code2_LabelName = 'コード2';
	@track code2_Value = '';

    //コード検索3	
    @track code3_LabelName = 'コード3';
	@track code3_Value = '';

    //コード検索1	
    @track code4_LabelName = 'コード4';
	@track code4_Value = '';

    //名称検索
    @track nameSearch_LabelName = '名称検索';
	@track nameSearch_Value = '';

    @track name1_isDisabled;
    @track name2_isDisabled;
    @track name3_isDisabled;
    @track name4_isDisabled;
    @track name5_isDisabled;
    @track name6_isDisabled;
    @track name7_isDisabled;
    @track name8_isDisabled;
    @track name9_isDisabled;
    @track name10_isDisabled;
    //仕様1～仕様4のリストを取得
    wireUniqueNamePicklist(isInit) {
        //ディフォルトが利用可能
        this.name1_isDisabled=true;
        this.name2_isDisabled=true;
        this.name3_isDisabled=true;
        this.name4_isDisabled=true;
        this.name5_isDisabled=true;
        this.name6_isDisabled=true;
        this.name7_isDisabled=true;
        this.name8_isDisabled=true;
        this.name9_isDisabled=true;
        this.name10_isDisabled=true;

        //パラメータ設定
        var name1 = null;
        if(!isInit){
            name1 = this.name1_SelectedOption
        }
        //Apex呼び出す
        getUniqueNamePicklist({deviceId: this.recordId, name1: name1})
            .then(result => {
                if(result) {
                    this.defaultNames = result;
                    //Apexから戻る結果を変数に設定
                    console.log(this.defaultNames);
                    var nameLabelList =  this.defaultNames.label;//条件の表示ラベル
                    if (isNotEmpty(nameLabelList) && nameLabelList.length > 0) {

                        if(isNotEmpty(this.defaultNames.isMACTUS)) this.isMACTUS=true;
                        if(isNotEmpty(this.defaultNames.isOPS)) this.isOPS=true;
                        if(isNotEmpty(this.defaultNames.isMELFLEX)) this.isMELFLEX=true;
                        if(isNotEmpty(this.defaultNames.isLargeScreen)) this.isLargeScreen=true;

                        this.isMACTUS_OR_MELFLEX = false;
                        //ＭＡＣＴＵＳ または　ＭＥＬＦＬＥＸの場合 仕様条件を非表示
                        if (this.isMACTUS || this.isMELFLEX
                            //  || this.isLargeScreen
                             ) {
                            this.isMACTUS_OR_MELFLEX = true;
                            this.isNameShow=false;//仕様条件非表示にする

                            this.meta1_Options=this.defaultNames.metadata1;
                            this.meta2_Options=this.defaultNames.metadata2;
                            this.meta6_Options=this.defaultNames.metadata6;
                            if (isNotEmpty(this.defaultNames.metadatas)&&this.defaultNames.metadatas.length>0){
                                this.metadataValues = this.defaultNames.metadatas[0];
                                //親に送信
                                if (isNotEmpty(this.metadataValues.meta1))this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:this.metadataValues.meta1,codeIndex:'meta1'}}));
                                if (isNotEmpty(this.metadataValues.meta2))this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:this.metadataValues.meta2,codeIndex:'meta2'}}));
                                if (isNotEmpty(this.metadataValues.meta3))this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:this.metadataValues.meta3,codeIndex:'meta3'}}));
                                if (isNotEmpty(this.metadataValues.meta4))this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:this.metadataValues.meta4,codeIndex:'meta4'}}));
                                if (isNotEmpty(this.metadataValues.meta5))this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:this.metadataValues.meta5,codeIndex:'meta5'}}));
                                if (isNotEmpty(this.metadataValues.meta6))this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:this.metadataValues.meta6,codeIndex:'meta6'}}));
                                if (isNotEmpty(this.metadataValues.meta7))this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:this.metadataValues.meta7,codeIndex:'meta7'}}));
                                if (isNotEmpty(this.metadataValues.meta8))this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:this.metadataValues.meta8,codeIndex:'meta8'}}));
                                if (isNotEmpty(this.metadataValues.meta9))this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:this.metadataValues.meta9,codeIndex:'meta9'}}));
                            }
                        }else {
                            this.isNameShow=true;//仕様条件表示にする
                        }
                        //表示ラベル設定
                        nameLabelList.forEach((item) => {
                            if(item.value==='detail'){
                                this.detailName=item.label;
                                if (isNotEmpty(this.detailName)) this.isDetailNameShow = true;//明細名称を表示
                            }
                            if(item.value==='name1'){
                                this.name1_LabelName=item.label;
                                if (this.isNameShow) this.isName1Show = true;//仕様１を表示
                            }
                            if(item.value==='name2'){
                                this.name2_LabelName=item.label;
                                if (this.isNameShow) this.isName2Show = true;//仕様2を表示
                            }
                            if(item.value==='name3'){
                                this.name3_LabelName=item.label;
                                if (this.isNameShow) this.isName3Show = true;//仕様3を表示
                            }
                            if(item.value==='name4'){
                                this.name4_LabelName=item.label;
                                if (this.isNameShow) this.isName4Show = true;//仕様4を表示
                            }
                            if(item.value==='name5'){
                                this.name5_LabelName=item.label;
                                if (this.isNameShow) this.isName5Show = true;//仕様5を表示
                            }
                            if(item.value==='name6'){
                                this.name6_LabelName=item.label;
                                if (this.isNameShow) this.isName6Show = true;//仕様6を表示
                            }
                            if(item.value==='name7'){
                                this.name7_LabelName=item.label;
                                if (this.isNameShow) this.isName7Show = true;//仕様7を表示
                            }
                            if(item.value==='name8'){
                                this.name8_LabelName=item.label;
                                if (this.isNameShow) this.isName8Show = true;//仕様8を表示
                            }
                            if(item.value==='name9'){
                                this.name9_LabelName=item.label;
                                if (this.isNameShow) this.isName9Show = true;//仕様9を表示
                            }
                            if(item.value==='name10'){
                                this.name10_LabelName=item.label;
                                if (this.isNameShow) this.isName10Show = true;//仕様10を表示
                            }
                        });
                    }
                    this.name1_Options = this.defaultNames.name1;//仕様１
                    this.name2_Options = this.defaultNames.name2;//仕様２
                    this.name3_Options = this.defaultNames.name3;//仕様３
                    this.name4_Options = this.defaultNames.name4;//仕様４
                    this.name5_Options = this.defaultNames.name5;//仕様５
                    this.name6_Options = this.defaultNames.name6;//仕様6
                    this.name7_Options = this.defaultNames.name7;//仕様7
                    this.name8_Options = this.defaultNames.name8;//仕様8
                    this.name9_Options = this.defaultNames.name9;//仕様9
                    this.name10_Options = this.defaultNames.name10;//仕様9
                    //初期表示の設定
                    if (isInit) {
                        //変圧器の場合
                        if (isNotEmpty(this.defaultNames.board1)&&this.defaultNames.board1.length>0) {
                            this.isBoardShow=true;
                            this.board1_Options = this.defaultNames.board1;//筐体
                            if (this.board1_Options!==undefined && this.board1_Options.length>0) {
                                this.board1_isDisabled=false;//表示制御
                            }
                            this.board2_Options = this.defaultNames.board2;//W
                            if (this.board2_Options!==undefined && this.board2_Options.length>0) {
                                this.board2_isDisabled=false;//表示制御
                            }
                            this.board3_Options = this.defaultNames.board3;//D
                            if (this.board3_Options!==undefined && this.board3_Options.length>0) {
                                this.board3_isDisabled=false;//表示制御
                            }
                            this.board4_Options = this.defaultNames.board4;//H
                            if (this.board4_Options!==undefined && this.board4_Options.length>0) {
                                this.board4_isDisabled=false;//表示制御
                            }
                        }
                    }
                    //仕様１のリストがない場合　利用不可に制御
                    if (this.name1_Options!==undefined && this.name1_Options.length>0) {
                        this.name1_Options.forEach((item) => {
                            if (isNotEmpty(name1) && item.value === name1) {
                                item.selected = true;
                            }else {
                                item.selected = false;
                            }
                        });

                        this.name1_isDisabled=false;
                    }
                    //仕様２のリストがない場合　利用不可に制御
                    if (this.name2_Options!==undefined && this.name2_Options.length>0) {
                        this.name2_isDisabled=false;
                    }
                    //仕様３のリストがない場合　利用不可に制御
                    if (this.name3_Options!==undefined && this.name3_Options.length>0) {
                        this.name3_isDisabled=false;
                    }
                    //仕様４のリストがない場合　利用不可に制御
                    if (this.name4_Options!==undefined && this.name4_Options.length>0) {
                        this.name4_isDisabled=false;
                    }
                    //仕様５のリストがない場合　利用不可に制御
                    if (this.name5_Options!==undefined && this.name5_Options.length>0) {
                        this.name5_isDisabled=false;
                    }
                    //仕様6のリストがない場合　利用不可に制御
                    if (this.name6_Options!==undefined && this.name6_Options.length>0) {
                        this.name6_isDisabled=false;
                    }
                    //仕様５のリストがない場合　利用不可に制御
                    if (this.name7_Options!==undefined && this.name7_Options.length>0) {
                        this.name7_isDisabled=false;
                    }
                    //仕様8のリストがない場合　利用不可に制御
                    if (this.name8_Options!==undefined && this.name8_Options.length>0) {
                        this.name8_isDisabled=false;
                    }
                    //仕様9のリストがない場合　利用不可に制御
                    if (this.name9_Options!==undefined && this.name9_Options.length>0) {
                        this.name9_isDisabled=false;
                    }
                    //仕様10のリストがない場合　利用不可に制御
                    if (this.name10_Options!==undefined && this.name10_Options.length>0) {
                        this.name10_isDisabled=false;
                    }
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    //画面初期処理
	connectedCallback() {
        this.isBoardShow=false;//盤条件非表示に初期化
        this.isNameShow=false;//仕様条件非表示に初期化
        this.isName1Show=false;
        this.isName2Show=false;
        this.isName3Show=false;
        this.isName4Show=false;
        this.isName5Show=false;
        this.isName6Show=false;
        this.isName7Show=false;
        this.isName8Show=false;
        this.isName9Show=false;
        this.isName10Show=false;
        //初期表示に　ヘッダのメタををクリアする
        this.metadataValues = [];
        this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:'',codeIndex:'meta1'}}));
        this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:'',codeIndex:'meta2'}}));
        this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:'',codeIndex:'meta3'}}));
        this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:'',codeIndex:'meta4'}}));
        this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:'',codeIndex:'meta5'}}));
        this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:'',codeIndex:'meta6'}}));
        this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:'',codeIndex:'meta7'}}));
        this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:'',codeIndex:'meta8'}}));
        this.dispatchEvent(new CustomEvent('metachange', {detail: {metaData:'',codeIndex:'meta9'}}));

        //仕様1～仕様4のリスト内容を取得する
        this.wireUniqueNamePicklist(true);
	}

    //検索の共通メソッド
    //searchDatatableへ送信
    @wire(MessageContext)
    messageContextOnSearch;
    onSearch(searchTerm) {

        // //メタをクリア
        // this.metadataValues = [];
        // var metaObj = this.template.querySelectorAll('[data-type="meta"]');
        // metaObj.forEach((item) => {
        //     item.value='';//if (item.type='text')
        //     // if (item.type='select')item.value='';
        // });

        //仕様１～４より検索
        if (searchTerm === 'SpecSearch') {
            let payload;
            if (this.isBoardShow){
                payload = {
                    conditionPattern: 'A',
                    searchTerm: searchTerm,
                    names: [
                        this.name1_SelectedOption,
                        this.name2_SelectedOption,
                        this.name3_SelectedOption,
                        this.name4_SelectedOption,
                        this.name5_SelectedOption,
                        this.name6_SelectedOption,
                        this.name7_SelectedOption,
                        this.name8_SelectedOption,
                        this.name9_SelectedOption,
                        this.name10_SelectedOption
                    ],
                    boardNames: [
                        null,
                        this.board1_SelectedOption,//名称２条件
                        this.board2_SelectedOption,//名称３条件
                        null,//名称４条件
                        null //名称５条件
                    ]
                };
            }else {
                payload = {
                    conditionPattern: 'A',
                    searchTerm: searchTerm,
                    names: [
                        this.name1_SelectedOption,
                        this.name2_SelectedOption,
                        this.name3_SelectedOption,
                        this.name4_SelectedOption,
                        this.name5_SelectedOption,
                        this.name6_SelectedOption,
                        this.name7_SelectedOption,
                        this.name8_SelectedOption,
                        this.name9_SelectedOption,
                        this.name10_SelectedOption
                    ]
                };
            }
            

            publish(this.messageContextOnSearch, RECORD_SEARCH_CHANNEL, payload);
        //コード１～４より検索
        } else if (searchTerm === 'CodeSearch') {
            const payload = {
                conditionPattern: 'A',
                searchTerm: searchTerm,
                codes: [
                    this.code1_Value,
                    this.code2_Value,
                    this.code3_Value,
                    this.code4_Value,
                ]
            };
            publish(this.messageContextOnSearch, RECORD_SEARCH_CHANNEL, payload);
        //名称より検索
        } else if (searchTerm === 'NameSearch') {
            const payload = {
                conditionPattern: 'A',
                searchTerm: searchTerm,
                name: [this.nameSearch_Value]
            };
            publish(this.messageContextOnSearch, RECORD_SEARCH_CHANNEL, payload);
        }
        
    }

    //仕様検索を押下する　検索を行う
    onSpecSearch() {
        console.log('onSpecSearching!');
        this.onSearch('SpecSearch');
    }

    // 各lightning-inputのvalidationチェック
    isInputValid() {
        let isValid = true;
        let input = this.template.querySelectorAll('lightning-input[data-code="code"]');
        input.forEach(inputField => {
        if(!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false;
        }
        });

        return isValid;
    }

    //コード検索を押下する　検索を行う
    onCodeSearch() {
        console.log('onCodeSearching!');
        if(this.isInputValid()){
            this.onSearch('CodeSearch');
        }


    }
    //名称検索を押下する　検索を行う
    onNameSearch() {
        console.log('onNameSearching!');
        this.onSearch('NameSearch');
    }

    //コード検索条件の入力内容をチェックする
    checkCodeValue(val){
        var str = /^[0-9a-zA-Z]*$/g;
        var result = str.test(val);
        //半角英数字以外の場合エラーとする
        if (!result) {
            const event = new ShowToastEvent({
                title: '入力エラー',
                message: '半角英数字のみで入力してください。',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
        return result;
    }
    //コード１が変更された場合、変数に設定
    handleKeyUpCodeSearch1(evt) {
        //チェック
        if (this.checkCodeValue(evt.target.value)){
            this.code1_Value = evt.target.value;
        }else{
            let input = this.template.querySelector('lightning-input[data-code="code1"]');
            input.value=null;
        }
     }
    //コード２が変更された場合、変数に設定
    handleKeyUpCodeSearch2(evt) {
        //チェック
        if (this.checkCodeValue(evt.target.value)){
            this.code2_Value = evt.target.value;
        }else{
            let input = this.template.querySelector('lightning-input[data-code="code2"]');
            input.value=null;
        }
    }
    //コード３が変更された場合、変数に設定
    handleKeyUpCodeSearch3(evt) {
        //チェック
        if (this.checkCodeValue(evt.target.value)){
            this.code3_Value = evt.target.value;
        }else{
            let input = this.template.querySelector('lightning-input[data-code="code3"]');
            input.value=null;
        }
    }
    //コード４が変更された場合、変数に設定
    handleKeyUpCodeSearch4(evt) {
        //チェック
        if (this.checkCodeValue(evt.target.value)){
            this.code4_Value = evt.target.value;
        }else{
            let input = this.template.querySelector('lightning-input[data-code="code4"]');
            input.value=null;
        }
    }
    //検索条件：名称が変更された場合、変数に設定
    handleKeyUpNameSearch(evt) {
        this.nameSearch_Value = evt.target.value;
    }

    @wire(MessageContext)
    messageContextOnChange;
    //仕様１～４が変わった時に親に送信
    onChange() {
        console.log('onChanging!');
        const payload = { 
            names: [
                this.name1_SelectedOption,
                this.name2_SelectedOption,
                this.name3_SelectedOption,
                this.name4_SelectedOption,
                this.name5_SelectedOption,
                this.name6_SelectedOption,
                this.name7_SelectedOption,
                this.name8_SelectedOption,
                this.name9_SelectedOption,
                this.name10_SelectedOption
            ]
        };
        publish(this.messageContextOnChange, CONDITION_CHANGE_CHANNEL, payload);
    }
}