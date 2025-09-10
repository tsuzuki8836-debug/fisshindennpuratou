import { LightningElement ,track,api} from 'lwc';
import getInitScreenInfo from '@salesforce/apex/DetailsInputForAcbBoardController.getInitScreenInfo';
import ACB_DESCRIPTION from '@salesforce/resourceUrl/ACBDescription';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { isNotEmpty, priceCalculator } from 'c/commonUtil';

export default class DetailsInputScreenBForAcbBoard extends LightningElement {

    @api recordId;
    @api loaded=false;

    //筐体仕様 検索条件
    @track installationLocation = '屋内';
    @track installationLocationLabel = '筐体仕様';
    @track installationLocationOptions = [
                        { label: '屋内', value: '屋内', selected :true },
                        { label: '屋外', value: '屋外', selected :false },
                    ];
    //一覧用変数
    @track bodyList;
    @track headerList;
    //タイトル：ACB盤（エアーサーキットブレーカ盤・気中遮断器盤）
    @track headTitle='';
    //footer:注
    @track footerInfo;
    @track isNodata=false;//一覧表示制御
    @track isM=false;//水環境である

    // M（”水環境"or"官需"）の場合
    // ACB盤（エアーサーキットブレーカ盤・気中遮断器盤）
    // ACB加算
    @track acbSumTable;

    // S”施設"の場合
    // 筐体
    // 零相変流器+地絡過電融継電器(ZCT+51G)
    @track zctTable;
    // 計器用変圧器VT,PT(低圧）引出型
    @track transformerDrawerTable;
    // 計器用変流器 ＣＴ(低圧)
    @track transformerCtTable;
    // ACB　（エアーサーキットブレーカ）
    @track acbTable;
    // プロテクタヒューズ
    @track protectorFuseTable;
    // テイクオフヒューズ
    @track takeoffFuseTable;
    // ネットワークリレー（multicap)
    @track networkRelayTable;
    // 合成CT（低圧）
    @track mixedTable;
    // ネットワークVT（低圧）
    @track networkVtTable;
    // ネットワークCT（低圧）
    @track networkCtTable;
    // 配線用遮断器価格 （MCCB・ELB）
    @track mccbTable;
    @track mccbTableHas;
    // 取付器具類
    @track installEquipTypeTable;

    //選択された仕様
    @track displayCondition;//選択使用
    @track displayTotal;// 合計金額
    @track inputedPrice;//チェックボックスの単価
    @track inputedId;//チェックボックスのId
    @track optRecords;//明細に数量入力されたデータ

    
    //筐体　説明図
    get acbDescriptionImage(){
        var imageUrl = '';
        imageUrl = ACB_DESCRIPTION ;

        return imageUrl;
    }

    //初期化処理
    connectedCallback() {
        console.log("Acb Input Screen Load Start");
        this.getScreenInfo(true);
	}
    //検索処理
    onSearch(evt){
        console.log('onSearch onClick start::'+evt.target);
        this.getScreenInfo(false);
    }
    //初期処理詳細
    getScreenInfo(init) {
        console.log("Acb Input Screen onSearch Start" + init);
        console.log("initScreen Start");
        this.clearTableList();
        this.isNodata = false;
        this.loaded = true;
        getInitScreenInfo({isInit:init,
            deviceId : this.recordId,
            installationLocation: this.installationLocation})
        .then(result => {
            if(result) {
                var mydata =JSON.parse(result);
                if (mydata && mydata.bodyList && mydata.bodyList.length==0) {
                    this.isNodata = true;
                }else {
                    this.headTitle=mydata.headTitle;
                    this.footerInfo=mydata.footerInfo;
                    this.bodyList = mydata.bodyList;
                    console.log(this.bodyList);
                    this.headerList = mydata.headerList;
                    this.isM = mydata.isM;
                    //ACB加算
                    this.acbSumTable = mydata.acbSumTable;
                    //零相変流器+地絡過電融継電器(ZCT+51G)
                    this.zctTable = mydata.zctTable;
                    // 計器用変圧器VT,PT(低圧）引出型
                    this.transformerDrawerTable = mydata.transformerDrawerTable;
                    // 計器用変流器 ＣＴ(低圧)
                    this.transformerCtTable = mydata.transformerCtTable;
                    // ACB　（エアーサーキットブレーカ）
                    this.acbTable = mydata.acbTable;
                    // プロテクタヒューズ
                    this.protectorFuseTable = mydata.protectorFuseTable;
                    // テイクオフヒューズ
                    this.takeoffFuseTable = mydata.takeoffFuseTable;
                    // ネットワークリレー（multicap)
                    this.networkRelayTable = mydata.networkRelayTable;
                    // 合成CT（低圧）
                    this.mixedTable = mydata.mixedTable;
                    // ネットワークVT（低圧）
                    this.networkVtTable = mydata.networkVtTable;
                    // ネットワークCT（低圧）
                    this.networkCtTable = mydata.networkCtTable;
                    // 配線用遮断器価格 （MCCB・ELB）
                    this.mccbTable = mydata.mccbTable;
                    this.mccbTableHas = mydata.mccbTableHas;
                    // 取付器具類
                    this.installEquipTypeTable = mydata.installEquipTypeTable;
                    if (mydata.inputedId) {
                        this.inputedId=mydata.inputedId;
                        this.inputedPrice = mydata.inputedPrice;
                        this.displayCondition = mydata.displayCondition;
                        this.setTotalPrice();//金額を合計

                        // 親へ送信（保存用）
                        this.dispatchEvent(new CustomEvent('screeninputforacbboardchange', {
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
                }
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

   //検索条件：筐体仕様　onchange
   installationLocation_Handler(evt){
        console.log('installationLocation_Handler onChange start');
        this.installationLocation = evt.target.value;
    }

    //チェックボックスが変わった
    handleScreenInputChange(evt){
        console.log('checkBox onChange start');
        let cnt = evt.target.checked;//入力された数量 ⇒チェックされた場合
        let rId = evt.currentTarget.dataset.id;//Id
        let price = evt.currentTarget.dataset.name;//単価
        let condition = evt.currentTarget.dataset.title;//仕様
        console.log(rId);
        //数量あり
        if (cnt){
            console.log(cnt);
            //他には入力された場合
            if (isNotEmpty(this.inputedId) && 
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
                try{
                    this.inputedId = rId;
                    this.inputedPrice = price;
                    this.displayCondition = condition;
                    console.log(cnt);
                    //custom event
                    //親へ送信（保存用）
                    this.dispatchEvent(new CustomEvent('screeninputforacbboardchange', {
                                        detail: {rId:this.inputedId,
                                                optRecords:this.optRecords} 
                                    }));
                }catch(e){
                    console.log(e);
                }
            }
        //数量　クリア
        }else{
            this.inputedId = null;
            this.inputedPrice = null;
            this.displayCondition = null;
            
            //custom event
            const passEvent = new CustomEvent('screeninputforacbboardchange', {
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
        this.dispatchEvent(new CustomEvent('screeninputforacbboardchange', {
            detail: {rId:this.inputedId,
                    optRecords:this.optRecords} 
        }));
    }
    //クリア処理
    clearTableList(){
        this.bodyList = null;//データ
        this.headerList = null;//ヘッダー
        this.inputedId = '';//チャックされたの選択値
        this.inputedPrice = null;
        this.optRecords=[];//明細に数量入力されたデータ
        //親へ送信（保存用）
        this.dispatchEvent(new CustomEvent('screeninputforacbboardchange', {
            detail: {rId:this.inputedId,
                    optRecords:this.optRecords} 
        }));
        this.displayTotal = '';//選択仕様
        this.displayCondition = '';//選択仕様

        //ACB加算
        this.acbSumTable =null;
         // 零相変流器+地絡過電融継電器(ZCT+51G)
         this.zctTable = null;
         // 計器用変圧器VT,PT(低圧）引出型
         this.transformerDrawerTable = null;
         // 計器用変流器 ＣＴ(低圧)
         this.transformerCtTable = null;
         // ACB　（エアーサーキットブレーカ）
         this.acbTable = null;
         // プロテクタヒューズ
         this.protectorFuseTable = null;
         // テイクオフヒューズ
         this.takeoffFuseTable = null;
         // ネットワークリレー（multicap)
         this.networkRelayTable = null;
         // 合成CT（低圧）
         this.mixedTable = null;
         // ネットワークVT（低圧）
         this.networkVtTable = null;
         // ネットワークCT（低圧）
         this.networkCtTable = null;
         // 配線用遮断器価格 （MCCB・ELB）
         this.mccbTable = null;
         this.mccbTableHas = null;
         // 取付器具類
         this.installEquipTypeTable = null;
    }
}