import { LightningElement, api, track } from 'lwc';
import getAmountDetailGetTable from '@salesforce/apex/amountDetailGetTableController.getAmountDetailGetTable';
import {unregisterRefreshHandler,registerRefreshContainer,REFRESH_ERROR,REFRESH_COMPLETE,REFRESH_COMPLETE_WITH_ERRORS } from "lightning/refresh";

export default class AmountDetail extends LightningElement {
    @api recordId;
    refreshHandlerId;

    @track bodyList; 
    @track recordType; 
    @track recordTypeIsO = false; 
    @track recordTypeIsJV = false;
    @track recordTypeIsM = false; 
    @track recordTypeIsSh = false; 



    O_RECORD_TYPE = 'O'; // 応札伺い
    J_RECORD_TYPE = 'JV'; // JV締結認可伺い
    M_RECORD_TYPE = 'M'; // 見積伺い
    SH_RECORD_TYPE = 'SH'; // 設計変更伺い
    
    /**
     * コンポーネントが DOM にレンダリングされた後に呼び出されます。
     */
    connectedCallback() {
        this.refreshHandlerId = registerRefreshContainer(
            this.template.host,
            this.refreshContainer.bind(this),
          );
        this.initScreen();
	}

    /**
     * 画面リフレッシュハンドラ
     */
    refreshHandler() {
        return new Promise((resolve) => {
            this.initScreen();
            resolve(true);
          });
	}

    /**
     * コンポーネントが DOM から削除される前に呼び出されます。
     */
    disconnectedCallback() {
		unregisterRefreshHandler(this.refreshHandlerId);
	}

    /**
     * 画面リフレッシュ処理
     */
    refreshContainer(refreshPromise) {
        console.log("画面をリフレッシュします");
        return refreshPromise.then((status) => {
          if (status === REFRESH_COMPLETE) {
            this.initScreen();
            console.log("完了");
          } else if (status === REFRESH_COMPLETE_WITH_ERRORS) {
            console.warn("一部エラーが発生しました");
          } else if (status === REFRESH_ERROR) {
            console.error("エラーが発生しました");
          }
        });
    }
    
    /**
     * 画面初期化処理
     */
    initScreen(){
        getAmountDetailGetTable({
            recId: this.recordId,
        })
        .then(result => {
            if (result){
                const data = JSON.parse(result);
                console.log(data);
                // this.bodyList = data.bodyList;
                this.bodyList = data.bodyList.map((row, rowIndex) => {
                    row.cellList = row.cellList.map((cell, cellIndex) => {
                        return {
                            ...cell,
                            uniqueKey: `row-${rowIndex}-cell-${cellIndex}`
                        };
                    });
                    return row;
                });
                this.recordType = data.recordType;
                console.log('----------'+this.recordType);
                if(this.recordType == this.SH_RECORD_TYPE) {
                    this.recordTypeIsSh = true;
                } else if(this.recordType == this.M_RECORD_TYPE) {
                    this.recordTypeIsM = true;
                } else if(this.recordType == this.J_RECORD_TYPE) {
                    this.recordTypeIsJV = true;
                } else if(this.recordType == this.O_RECORD_TYPE) {
                    this.recordTypeIsO = true;
                }
            }
        });
    }
}