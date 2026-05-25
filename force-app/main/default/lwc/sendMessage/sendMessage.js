import { LightningElement ,wire} from 'lwc';
import {publish, MessageContext} from 'lightning/messageService';
import MESSAGE_CHANNEL from '@salesforce/messageChannel/sendmessage__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class SendMessage extends LightningElement {
      inputMessage='';

      @wire(MessageContext)
      messageContext;

      handleMessageChange(event){
        this.inputMessage=event.target.value;
      }
      handleclick(){
        const payload={message:this.inputMessage};
        publish(this.messageContext,MESSAGE_CHANNEL,payload);
        console.log('payload',payload.message);
        this.showToast('Success','Message Sent Successfully','Success');

        
      }

      showToast(title,message,variant){
        const event= new ShowToastEvent({
            title:title,
            message:message,
            variant:variant,
        });
        this.dispatchEvent(event);
      }
}