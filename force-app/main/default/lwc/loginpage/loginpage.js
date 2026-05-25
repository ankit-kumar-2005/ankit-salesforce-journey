import { LightningElement,track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Loginpage extends LightningElement {
    @track mobileNo;
    @track showValidatepage=false;
    @track otp;
   @track userotp;
    @track isButtonDisabled=false;
    @track showAccountspage=false;
    @track count=0;
    handlePhoneChange(event){
        this.mobileNo = event.target.value;
    }
    handleLogin(){
        console.log('this.mobileNo'+this.mobileNo);
        console.log('nobile length'+this.mobileNo.length);
        console.log('this.mobileNo'+this.mobileNo.startsWith('6'||'7'||'8'||'9'));
        console.log('this.mobileNo'+this.mobileNo[0]);
       
        if(this.mobileNo.length==10 && (this.mobileNo[0]=='6'||this.mobileNo[0]=='7'||this.mobileNo[0]=='8'||this.mobileNo[0]=='9') ){
            this.showToast('Success','Login Successfully','success');
            this.showValidatepage=true;
                const max = 10000;
                const randomInt = Math.floor(Math.random() * max); 
                this.otp=randomInt;
        }
        
        
        else{
            this.showToast('Error','Mobile No must be of 10 digit and start with 6,7,8,9','error');
        }
         this.isButtonDisabled = true;

        // Set a timer to re-enable the button after 30 seconds (30000 milliseconds)
        setTimeout(() => {
            this.isButtonDisabled = false;
        }, 30000)
       
    }
     showToast(title,message,variant){
        const event= new ShowToastEvent({
            title:title,
            message:message,
            variant:variant,
        });
        this.dispatchEvent(event);
      }

    handleOtpChange(event){
        this.userotp = event.target.value;
    }

   handleResetOtp() {

    console.log('this.count'+this.count);

    if(this.count==2){
        this.isButtonDisabled = true;
    } else{
        this.count++;
        // Disable the button
        this.isButtonDisabled = true;

        // Set a timer to re-enable the button after 30 seconds (30000 milliseconds)
        setTimeout(() => {
            this.isButtonDisabled = false;
        }, 30000);
        this.showToast('Success','OTP Reset Successfully','success');
               const max = 10000;
                const randomInt = Math.floor(Math.random() * max); 
                this.otp=randomInt;
    }

    }
    handleValidate(){
        console.log('this.userotp'+this.userotp);
        console.log('this.otp'+this.otp);
        if(this.userotp==this.otp){
            this.showToast('Success','OTP Verified Successfully','success');
            //yaha child call krana hai
            this.showAccountspage=true;
        }
        else{
            this.showToast('Error','OTP Not Matched','error');
        }
    }
}