/*
 Name:MyExample
 Author:Ankit Kumar
 Description:I Solve this problem for My practise
 date:30/08/25
*/
public class MyExample {
    //Question02_____________________________________________________________________________________________________________
 /**
   @description:Query all Accounts with AnnualRevenue greater than 1,000,000. Update the Rating field
to Hot for each of these Accounts.
   @return void
  */
   
    /*
    public static void updateAccountRatingOnAnnualRevenue(){
        //Step 01: fetch the data from database
            List<Account> listOfAccount=[SELECT Id,Name,Rating,AnnualRevenue
                          FROM Account
                          WHERE AnnualRevenue>1000000];
       //Step 02: Make a new list that stores id to be updated
      List<Account> listOfAccToUpdate= new List<Account>();
        //Step 03:Loop and set the Rating field to Hot
        for(Account acc:listOfAccount){
              Account accAddedInUpdatedList=new Account();
               accAddedInUpdatedList.Id=acc.Id;
               accAddedInUpdatedList.Rating='Hot';
            listOfAccToUpdate.add(accAddedInUpdatedList);
            
        }
        //Step 04: Update Record in Bulk if list is ot empty
        if(!listOfAccToUpdate.isEmpty()){
          Update listOfAccToUpdate; 
            System.debug('Updated successfully');
        }
        
    }
*/
//_______________________________________________________________________________________________________________________________________________       
         // For simple bulk updates, List is simpler and perfectly fine.
         // Use Map when you need lookup, merge, or duplicate handling.

    public static void updateAccountRatingOnAnnualRevenue(){
        //Step01:fetch data from database
        List<Account> listOfAccount=[SELECT Id,Name,Rating,AnnualRevenue
                          FROM Account
                          WHERE AnnualRevenue>1000000];
        //Step02:Prepare a map to hold record for update
        Map<Id,Account> mapOfAccountToUpdate= new Map<Id,Account>();
        
        //step03:Loop and set the Rating field to Hot
        for(Account acc:listOfAccount){
            Account accToUpdate=new Account();
            accToUpdate.Id=acc.Id;
            accToUpdate.Rating='Hot';
            mapOfAccountToUpdate.put(acc.Id,accToUpdate);
        }
        //Step04:Update map if map is not empty
        if(!mapOfAccountToUpdate.isEmpty()){
            Update mapOfAccountToUpdate.values();
            System.debug('Updated Successfully');
        }
        
    }


}