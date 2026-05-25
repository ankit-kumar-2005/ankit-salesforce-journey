/*Name:PreventClaimCreationTriggerHandler
 *Author:Ankit Kumar
 *Description:Handler on claim trigger
 *Date:10/09/25
 */
public with sharing class PreventClaimCreationTriggerHandler {
    public static void PreventClaimCreation(List<Policy_Claim__c>listOfClaim){

      
           
       
        System.debug(listofClaim);
       
        Set<Id> setOfPolicyId=new Set<Id>();
        for(Policy_Claim__c recordClaim:listOfClaim){
             setOfPolicyId.add(recordClaim.Policy__c);
            
        }
        
        System.debug(setOfPolicyId);

        List<Policy__c> listOfPolicy=[SELECT Id,Status__c FROM Policy__c WHERE Id IN:setOfPolicyId];
        
        Map<Id,String> mapofStatus=new Map<Id,String>();
        for(Policy__c recordOfPolicy:listOfPolicy){
            mapofStatus.put(recordOfPolicy.Id,recordOfPolicy.Status__c);
        }
        for(Policy_Claim__c recordOfClaim:listOfClaim){
            if(mapofStatus.get(recordOfClaim.Policy__c)=='expired'|| mapofStatus.get(recordOfClaim.Policy__c)=='cancelled'){
                recordOfClaim.addError('Policy is Expired or Cancelled');
            }else{
                recordOfClaim.Status__c='Submitted';
            }
        }
            
      
        

     /*
     //it's not working because inbefore insert trigger ,you never queried the related object because it does not exist in dtabase
       we only know the lookup Id's.
        for(Policy_Claim__c recordClaim:listOfClaim){
            if(recordClaim.Policy__r.Status__c=='expired'|| recordClaim.Policy__r.Status__c=='cancelled'){
                recordClaim.addError('Policy is Expired or Cancelled');
            }else{
                
            }
        }
            */
            


    

    }

    //When claim is updated to approved , insert a claim audit record
    public static void insertClaimAudit(List<Policy_Claim__c>listOfClaim,Map<Id,Policy_Claim__c>mapOfClaimRecord){

       /* Map<Id,String> mapofClaimStatus=new Map<Id, String>();
        for(Policy_Claim__c recordClaim:listOfClaim){
            mapofClaimStatus.put(recordClaim.Id,recordClaim.Status__c);
        }
            */

            Map<Id,Policy_Claim__c> mapofClaim= new Map<Id,Policy_Claim__c>();
            for(Policy_Claim__c recordOfClaim:listOfClaim){
                mapOfClaim.put(recordOfClaim.Id,recordOfClaim);
            }


        //collection
        List<Claim_Audit__c> listOfClaimAudit=new List<	Claim_Audit__c>();
        for(Id idOfMap:mapOfClaim.keySet()){
            if(mapOfClaim.get(idOfMap).Status__c=='Approved' ){
                	Claim_Audit__c recordOfClaimAudit=new Claim_Audit__c();
                    recordOfClaimAudit.Policy_Claim__c=idOfMap;
                    recordOfClaimAudit.Action__c=mapofClaim.get(idOfMap).Status__c;
                    listOfClaimAudit.add(recordOfClaimAudit);
            }
             if(mapOfClaim.get(idOfMap).Status__c=='paid' && mapofClaim.get(idOfMap).Is_Fraud__c==false){
                	Claim_Audit__c recordOfClaimAudit=new Claim_Audit__c();
                     recordOfClaimAudit.Policy_Claim__c=idOfMap;
                    recordOfClaimAudit.Action__c=mapofClaim.get(idOfMap).Status__c;
                    listOfClaimAudit.add(recordOfClaimAudit);
            }
           
            
        }
        if(!listOfClaimAudit.isEmpty()){
            Database.insert(listOfClaimAudit,false);
        }
        

        
        
    }

    //If claim amount is more than 2x of policy premium amount, mark claim as is fraud = true
        public static void marksClaimAsFraud(List<Policy_Claim__c>listOfClaim){
              
        System.debug(listofClaim);
       
        Set<Id> setOfPolicyId=new Set<Id>();
        for(Policy_Claim__c recordClaim:listOfClaim){
             setOfPolicyId.add(recordClaim.Policy__c);
            
        }
         List<Policy__c> listOfPolicy=[SELECT Id,Premium_amount__c FROM Policy__c WHERE Id IN:setOfPolicyId];
        
         Map<Id,Decimal> MapofPolicy= new Map<Id,Decimal>();
          for(Policy__c recordOfPolicy:listOfPolicy){
            MapofPolicy.put(recordOfPolicy.Id,recordOfPolicy.Premium_amount__c);
        }

        for(Policy_Claim__c recordOfClaim:listOfClaim){
            if(recordOfClaim.Claim_Amount__c>2*MapofPolicy.get(recordOfClaim.Policy__c)){
                recordOfClaim.Is_Fraud__c=true;
            }
        }
    }
}