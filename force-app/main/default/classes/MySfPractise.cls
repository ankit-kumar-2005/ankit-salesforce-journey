/*
@Name:MySfPractise
@Author:Ankit Kumar
@Description:I write here code for my practise purpose
@Date:25/05/26
*/

public class MySfPractise {
    /**
@Accounts having more than 5 Contacts. update theContact’s Description field to Primary Contact.
@return void
*/
    public static void updatePrimaryContactRelatedAccount(){
        try{
            set<Id> eligiableSetOfAccount = new set<Id>();
            //Collect accounts having more than 5 contacts
            List<AggregateResult> aggResultOfAccount=[SELECT AccountId FROM Contact GROUP BY AccountId Having COUNT(Id)>5];
            for(AggregateResult arr:aggResultOfAccount){
                eligiableSetOfAccount.add((Id)arr.get('AccountId'));                                          
            }
            //Exist if no account found
            if(eligiableSetOfAccount.isEmpty()){
                return;
            }
            List<Contact> listOfContactToUpdate =[SELECT Id,Description FROM Contact WHERE Id IN:eligiableSetOfAccount];
            
            //update the description field
            for(contact contactRecord: listOfContactToUpdate){
                contactRecord.Description='Primary contact';
            }
            if(!listOfContactToUpdate.isEmpty()){
                Database.update(listOfContactToUpdate,false);
            }
            
            
        }catch(Exception ex){
            system.debug('General Exception' + ex.getmessage());
            system.debug('Line Number=>' + ex.getLineNumber());
        }                                                                                           
        
    }
    
    
}