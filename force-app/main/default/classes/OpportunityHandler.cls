public class OpportunityHandler {

    public static void updateTotalOpportunityAmount(Set<Id> accountIds) {
        if (accountIds.isEmpty()) return;

        // Aggregate sum of open opportunities per account
        Map<Id, Decimal> accountOppSumMap = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT AccountId, SUM(Amount) sumAmount
            FROM Opportunity
            WHERE AccountId IN :accountIds
              AND StageName NOT IN ('Closed Won', 'Closed Lost')
            GROUP BY AccountId
        ]) {
            accountOppSumMap.put((Id)ar.get('AccountId'), (Decimal)ar.get('sumAmount'));
        }

        // Get all accounts to update
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {
            Account acc = new Account(
                Id = accId,
                Total_Opportunity_Amount__c = accountOppSumMap.containsKey(accId) ? accountOppSumMap.get(accId) : 0
            );
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}