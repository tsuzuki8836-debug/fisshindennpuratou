import { LightningElement, wire, api} from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

import WcSumFormula_FIELD from '@salesforce/schema/Device__c.WcSumFormula__c';
import StandardPriceSumFormula_FIELD from '@salesforce/schema/Device__c.StandardPriceSumFormula__c';
import AgencyProvisionPriceSumFormula_FIELD from '@salesforce/schema/Device__c.AgencyProvisionPriceSumFormula__c';
import GeneralAdministrativeExpenses_FIELD from '@salesforce/schema/Device__c.GeneralAdministrativeExpenses__c'
import SalesCostSum_FIELD from '@salesforce/schema/Device__c.SalesCostSum__c';
import ClientAnswerAmount_FIELD from '@salesforce/schema/Device__c.ClientAnswerAmount__c';

const FIELDS = [WcSumFormula_FIELD, StandardPriceSumFormula_FIELD, AgencyProvisionPriceSumFormula_FIELD, GeneralAdministrativeExpenses_FIELD, SalesCostSum_FIELD, ClientAnswerAmount_FIELD];

export default class DeviceAmountInfomation extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS } )
    device;
    get WcSumFormula(){
        return getFieldValue(this.device.data, WcSumFormula_FIELD).toLocaleString();
    }
    get StandardPriceSumFormula(){
        return getFieldValue(this.device.data, StandardPriceSumFormula_FIELD).toLocaleString();
    }
    get AgencyProvisionPriceSumFormula(){
        return getFieldValue(this.device.data, AgencyProvisionPriceSumFormula_FIELD).toLocaleString();
    }
    get GeneralAdministrativeExpenses(){
        return getFieldValue(this.device.data, GeneralAdministrativeExpenses_FIELD).toLocaleString();
    }
    get SalesCostSum(){
        return getFieldValue(this.device.data, SalesCostSum_FIELD).toLocaleString();
    }
    get ClientAnswerAmount(){
        return getFieldValue(this.device.data, ClientAnswerAmount_FIELD).toLocaleString();
    }

}