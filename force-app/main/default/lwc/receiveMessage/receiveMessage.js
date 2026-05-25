import { LightningElement,wire } from 'lwc';
import { subscribe,MessageContext } from 'lightning/messageService';
import MESSAGE_CHANNEL from '@salesforce/messageChannel/sendmessage__c';

export default class ReceiveMessage extends LightningElement {
    receivedMessage='';
    @wire(MessageContext)
    messageContext;

   connectedCallback(){
        this.subscribeMessage();
   }
   subscribeMessage(){
     this.subscription= subscribe(this.messageContext,MESSAGE_CHANNEL,(payload)=>this.handleMessage(payload));
   }
   
   handleMessage(payload){
        this.receivedMessage=payload.message;
   }
}