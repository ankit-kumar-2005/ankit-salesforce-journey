import { LightningElement,track,wire } from 'lwc';
import getAllUser from '@salesforce/apex/UserInfo.getAllUser';
import getUserInfo from '@salesforce/apex/UserInfo.getUserInfo';

export default class Userinfo extends LightningElement {
    @track selectedUser;
    @track userList=[];
    @track userInfoToShow;


    @wire(getAllUser)
   wireusers({error,data}){
       if(data){
        console.log('data'+data);
        this.userList= data.map(user =>({
            label:user.Name,
            value:user.Id
        }));
       }else if(error){
            this.error=error;
            this.userList=[];
       }
   }

   handleUserChange(event){
    //we get id that is selected and stored above
     this.selectedUser= event.detail.value;
     //Imperative Apex Call in
      getUserInfo({ userId: this.selectedUser })
            .then(result => {
                this.userInfoToShow = result;
            })
            .catch(error => {
                this.error = error;
                this.userInfoToShow = undefined;
            });
   }


//    @wire(getUserInfo,{userId:'$selectedUser'})
//    wiredUserInfo({error,data}){
//        if(data){
//               console.log('data'+data);
//         this.userInfoToShow= data;
//        }else if(error){
//                 this.error=error;
//             this.userInfoToShow=undefined;  
//        }


//     }
    
}