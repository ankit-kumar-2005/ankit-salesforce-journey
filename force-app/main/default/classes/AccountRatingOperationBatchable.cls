/* 
* @Name: AccountRatingOperationBatchable
* @Author: Ankit Kumar
* @Description: Batch Apex class to update Account Rating field based on total Opportunity Amount
* @Date: 05-09-25
*/

public class AccountRatingOperationBatchable implements Database.Batchable<SObject> {
    
    /**
    * This method is the first step of the batch.
    * return Accounts which have Opportunities in 'Closewon' stage.
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Rating 
            FROM Account 
            WHERE Id IN (
                SELECT AccountId FROM Opportunity WHERE StageName = 'Closewon'
            )
        ]);
    }

    /**
    * This method runs for each batch of records.
    * Here we calculate total Opportunity Amount for every Account,
    * then set the Account Rating to Hot, Warm, or Cold.
    */
    public void execute(Database.BatchableContext bc, List<Account> accountBatch) {
        // collect all account Ids from the batch
        Set<Id> setOfAccountIds = new Set<Id>();
        for (Account acc : accountBatch) {
            setOfAccountIds.add(acc.Id);
        }
        
        // get total Opportunity amount for each account
        Map<Id, Decimal> mapAccountTotalAmount = new Map<Id, Decimal>();
        List<AggregateResult> listOfAmount = [
            SELECT AccountId, SUM(Amount) totalAmount 
            FROM Opportunity
            WHERE AccountId IN :setOfAccountIds
            GROUP BY AccountId
        ]; 
        for (AggregateResult ar : listOfAmount) {
            mapAccountTotalAmount.put((Id)ar.get('AccountId'), (Decimal)ar.get('totalAmount'));
        }

        // now update the rating based on total amount
        List<Account> accountToUpdate = new List<Account>();
        for (Account acc : accountBatch) {
            Decimal totalAmount = mapAccountTotalAmount.get(acc.Id);

            Account updatedAccount = new Account();
            updatedAccount.Id = acc.Id;         

            if (totalAmount > 1000000) {
                updatedAccount.Rating = 'Hot';   // big customer
            } else if (totalAmount > 50000 && totalAmount < 1000000) {
                updatedAccount.Rating = 'Warm';  // medium customer
            } else {
                updatedAccount.Rating = 'Cold';  // small customer
            }
            accountToUpdate.add(updatedAccount);
        }

        // save changes only if list is not empty
        if (!accountToUpdate.isEmpty()) {
            Database.update(accountToUpdate, false);
        }
    }

    /**
    * This method runs at the end of the batch job.
    * Just prints a message in the debug log.
    */
    public void finish(Database.BatchableContext bc) {
        System.debug('Account Rating Batch Class processed successfully');
    }
}