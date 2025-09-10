import { LightningElement , track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Annotation_HighLowVoltageTR from '@salesforce/label/c.Annotation_HighLowVoltageTR';
import Annotation_HighVoltageTR from '@salesforce/label/c.Annotation_HighVoltageTR';
import getInitScreenInfo from '@salesforce/apex/DetailsInputForHighLowVoltageController.getInitScreenInfo';
import { isNotEmpty } from 'c/commonUtil';

export default class DetailsInputScreenBForHighLowVoltage extends LightningElement {

    //外部API：機器Id
    @api recordId;
    @api loader = false;//spinner表示制御

    //------------------画面種類　検索条件----------------
    @track screenType_LabelName = '画面種類';
    @track screenType_isDisabled = false;//利用可否
    @track screenType_isRequired = false;//必須可否
    @track screenType_Options=[
                    {label:'高圧TR1', value:'高圧TR1', selected :false},
                    {label:'高低圧TR1', value:'高低圧TR1', selected :false}
                ];//プルダウンリスト
    @track screenType_Value='';//画面種類選択値
    
    //------------------変圧器種類　検索条件----------------
    @track transformerType_LabelName = '変圧器種類';
    @track transformerType_isDisabled = false;//利用可否
    @track transformerType_isRequired = false;//必須可否
    @track transformerType_Options=[];
    @track transformerType_High_Options=[
                    {label:'高圧TR油入(1次電圧6600V)', value:'高圧TR油入(一次電圧6,600V)@@高圧TR油入(一次電圧6,600/3,300V共用)', selected :false},
                    {label:'高圧TR油入(1次電圧3300V)', value:'高圧TR油入(一次電圧3,300V)@@高圧TR油入(一次電圧6,600/3,300V共用)', selected :false},
                    {label:'高圧TR油入(1次電圧6600V)混触防止板あり', value:'高圧TR油入(一次電圧6,600V)混触防止板あり@@高圧TR油入(一次電圧6,600/3,300V共用)混触防止板あり', selected :false},
                    {label:'高圧TR油入(1次電圧3300V)混触防止板あり', value:'高圧TR油入(一次電圧3,300V)混触防止板あり@@高圧TR油入(一次電圧6,600/3,300V共用)混触防止板あり', selected :false},
                    {label:'高圧TRモールド', value:'高圧TRモールド', selected :false},
                    {label:'高圧TRモールド混触防止板あり', value:'高圧TRモールド混触防止板あり', selected :false}
                ];//プルダウンリスト
    @track transformerType_Low_Options=[
                    {label:'高・低圧TR油入', value:'高・低圧TR油入', selected :false},
                    {label:'高・低圧TR油入混触防止板あり', value:'高・低圧TR油入混触防止板あり', selected :false},
                    {label:'高・低圧TRモールド', value:'高・低圧TRモールド', selected :false},
                    {label:'高・低圧TRモールド混触防止板あり', value:'高・低圧TRモールド混触防止板あり', selected :false}
    ];//プルダウンリスト
    @track transformerType_Value='';//変圧器種類選択値

    //------------------一覧の変数-------------------------------------
    @track isHighVoltage = false;
    @track isHighLowVoltage = false;

    //2024/7/25 TS佐藤
    //屋外・油入 自冷   （１／２）
    @track title2_1=' ';
    //屋外・油入 自冷   （２／２）
    @track title2_2=' ';

    @track headerList=[]; //一覧ヘッダー情報
    @track bodyList=[];   //一覧ボディー情報
    @track footerInfo2_1 = Annotation_HighVoltageTR;
    @track footerInfo2_2 = Annotation_HighLowVoltageTR;
    @track isNodata=false;

    //画面入力された情報
    @track inputedId=null;
    @track displayTotal = null;
    @track displayCondition = null;

    //画面初期処理
    connectedCallback() {
        this.clearTableList()
        //検索を行う
        this.onSearch();
    }

    //画面種類
    screenType_Handler(evt){
        this.screenType_Value=evt.target.value;
        //一覧非表示にする
        this.clearTableList();
        //選択値より設定
        if (this.screenType_Value==='高圧TR1') {
            this.transformerType_Value='高圧TR油入(一次電圧6,600V)@@高圧TR油入(一次電圧6,600/3,300V共用)';
            this.transformerType_Options=this.transformerType_High_Options;
        }else if (this.screenType_Value==='高低圧TR1') {
            this.transformerType_Value='高・低圧TR油入';
            this.transformerType_Options=this.transformerType_Low_Options;
        }
    }

    //変圧器種類
    transformerType_Handler(evt){
        this.transformerType_Value=evt.target.value;
        //一覧非表示にする
        this.clearTableList();
    }

    //検索を行う
    onSearch(){
        console.log(this.screenType_Value);
        console.log(this.transformerType_Value);
        //状態クリア
        this.clearTableList();
        //検索を行う
        this.loader = true;
        getInitScreenInfo({
            recordId:this.recordId,
            screenType:this.screenType_Value,
            transformerType:this.transformerType_Value})
            .then(result => {
                this.loader = false;
                if(result) {
                    var mydata =JSON.parse(result);
                    if (mydata.isNodata) {
                        this.isNodata = true;
                    }else {
                        this.isNodata = false;
                        this.bodyList = mydata.bodyList;//データ
                        this.headerList = mydata.headerList;//ヘッダー
                        this.inputedId = mydata.inputedId;//チャックされたの選択値
                        this.displayTotal = mydata.displayTotal;//選択仕様
                        this.displayCondition = mydata.displayCondition;//選択仕様
                        //初期表示の設定
                        if (!isNotEmpty(this.screenType_Value)
                            && !isNotEmpty(this.transformerType_Value)) {
                            this.screenType_Value = mydata.screenType;
                            this.transformerType_Value = mydata.transformerType;
                            //選択値より設定
                            if (this.screenType_Value==='高圧TR1') {
                                this.isHighVoltage=true;
                                this.transformerType_High_Options.forEach((item) => {
                                    if (item.value === this.transformerType_Value) {
                                        item.selected = true;
                                    }
                                });
                                this.transformerType_Options=this.transformerType_High_Options;
                            }else if (this.screenType_Value==='高低圧TR1') {
                                this.isHighLowVoltage=true;
                                this.transformerType_Low_Options.forEach((item) => {
                                    if (item.value === this.transformerType_Value) {
                                        item.selected = true;
                                    }
                                });
                                this.transformerType_Options=this.transformerType_Low_Options;
                            }
                        }
                        //親画面へ　登録データ送信
                        const passEvent = new CustomEvent('checkboxchangeforhlv', {
                            detail:{rId:this.inputedId} 
                        });
                        this.dispatchEvent(passEvent);
                    }
                }
            })
            .catch(error => {
            this.loaded = false;
            console.log(error);
            });
    }


    //一覧非表示にする
    clearTableList(){
        //ヘッダー　フッター非表示
        this.isHighVoltage=false;
        this.isHighLowVoltage=false;
        this.headerList=null; //一覧ヘッダー情報
        this.bodyList=null;   //一覧ボディー情報

        this.inputedId = null;
        this.displayTotal = null;
        this.displayCondition = null;
        //custom event
        const passEvent = new CustomEvent('checkboxchangeforhlv', {
            detail:{rId:null} 
        });
        this.dispatchEvent(passEvent);

        //選択値より設定
        if (this.screenType_Value==='高圧TR1') {
            this.isHighVoltage=true;
        }else if (this.screenType_Value==='高低圧TR1') {
            this.isHighLowVoltage=true;
        }
    }

    //一覧コンポネットから返信　の場合
    handleScreenInputChange(event){
        console.log('handleScreenInputChange start');
        let cnt = event.target.checked;//入力された数量 ⇒チェックされた場合
        let rId = event.currentTarget.dataset.id;//Id
        let price = event.currentTarget.dataset.name;//単価
        let condition = event.currentTarget.dataset.title;//仕様
        
        if (cnt){
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
            }else{
                this.inputedId = rId;
                this.displayTotal = price;
                this.displayCondition = condition;
                //登録データ　が親画面へ送信
                const passEvent = new CustomEvent('checkboxchangeforhlv', {
                    detail:{rId:rId} 
                });
                this.dispatchEvent(passEvent);
            }
        }else{
            //選択解除の場合、保持値のクリア
            this.inputedId = null;
            this.displayTotal = null;
            this.displayCondition = null;
            
            //クリアされた内容が　親画面へ送信
            const passEvent = new CustomEvent('checkboxchangeforhlv', {
                detail:{rId:null} 
            });
            this.dispatchEvent(passEvent);
        }
    }
    //2024/7/25 TS佐藤 
    get GetStyle(){
        console.log(window.innerWidth);
        if(this.title2_1 && this.title2_1.indexOf(' ') != -1){
            return 'overflow: auto;max-height: 540px; max-width:' + (window.innerWidth*0.6) + 'px';
        }
    }
}