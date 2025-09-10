import { LightningElement, api, track } from 'lwc';
import getDetailTable from '@salesforce/apex/BidAgencyDetailGetTableController.getDetailTable';
import {unregisterRefreshHandler,registerRefreshContainer,REFRESH_ERROR,REFRESH_COMPLETE,REFRESH_COMPLETE_WITH_ERRORS } from "lightning/refresh";

export default class BidAgencyDetail extends LightningElement {
    @api recordId;
    refreshHandlerId;

    @track bodyListMax; 
    @track bodyListMin; 
    @track isShowDependentFeeInquiry; 
    
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
     * @param {*} refreshPromise 
     * @returns 
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
        console.log('★---recordId----' + this.recordId);
        getDetailTable({
            recId: this.recordId,
        })
        .then(result => {
            if (result){
                const data = JSON.parse(result);
                console.log('★-------' + JSON.stringify(data));
                // this.bodyListMax = data.bodyListMax;
                this.bodyListMax = data.bodyListMax.map((row, rowIndex) => {
                  row.cellList = row.cellList.map((cell, cellIndex) => {
                      return {
                          ...cell,
                          uniqueKey: `row-${rowIndex}-cell-${cellIndex}`
                      };
                  });
                  return row;
              });
                // this.bodyListMin = data.bodyListMin;
                this.bodyListMin = data.bodyListMin.map((row, rowIndex) => {
                  row.cellList = row.cellList.map((cell, cellIndex) => {
                      return {
                          ...cell,
                          uniqueKey: `row-${rowIndex}-cell-${cellIndex}`
                      };
                  });
                  return row;
              });
                this.isShowDependentFeeInquiry = data.isShowDependentFeeInquiry;
            }
        });
    }
}