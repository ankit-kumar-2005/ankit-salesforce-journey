/*@Name:PreventClaimCreationTrigger
  @Author:Ankit Kumar
  @Description:trigger on claim
  @Date:10/09/25

*/


trigger PreventClaimCreationTrigger on Policy_Claim__c (before insert,after update) {
   
    
   if(Trigger.isBefore){
        PreventClaimCreationTriggerHandler.preventClaimcreation(Trigger.new);
        //If claim amount is more than 2x of policy premium amount, mark claim as is fraud = true
        PreventClaimCreationTriggerHandler.marksClaimAsFraud(Trigger.new);
    }
    else if(Trigger.isAfter){
        //When claim is updated to approved , insert a claim audit record
        if(Trigger.isUpdate){
            PreventClaimCreationTriggerHandler.insertClaimAudit(Trigger.new,Trigger.oldMap);

            
        }
    }
        
        
        
       

}