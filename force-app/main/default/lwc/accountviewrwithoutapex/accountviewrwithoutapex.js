import { LightningElement,api,wire } from 'lwc';
import {getRecord,getFieldValue} from 'lightning/uiRecordApi'

//schema import is required for getFieldvalue
import  Name_FIELD from '@salesforce/schema/Account.Name';
import  Industry_FIELD from '@salesforce/schema/Account.Industry';
import  Phone_FIELD from '@salesforce/schema/Account.Phone';

const Fields=[Name_FIELD,Industry_FIELD,Phone_FIELD];

export default class Accountviewrwithoutapex extends LightningElement {
    @api recordId;
     account=[];

     @wire(getRecord,{recordId:'$recordId',fields: Fields})
     wiredAccount({error,data}){
        if(data){
            this.account=data;
        }else if(error){
            this.error=error;
            this.account=[];
        }
     }

     get name(){
         return getFieldValue(this.account,Name_FIELD);
     }
     get industry(){
         return getFieldValue(this.account,Industry_FIELD);
     }

     get phone(){
         return getFieldValue(this.account,Phone_FIELD);
     }
  
}