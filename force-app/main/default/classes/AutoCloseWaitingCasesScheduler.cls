/*
  @Name=AutoCloseWaitingCasesScheduler 
  @Author Name=Ankit Kumar
  @Description=schedulable class that runs every week and closes cases that are in status "Waiting
                for Customer" for more than 15 days.
  @Date=07/09/25
  */


public with sharing class AutoCloseWaitingCasesScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        // list of case that is updated to close
        List<Case> listOfCase = [
            SELECT Id
            FROM Case
            WHERE Status = 'Waiting for Customer'
             AND CreatedDate <= :System.now().addDays(-15)
        ];

        // Collection to be updated
        List<Case> listToBeUpdated = new List<Case>();
        for (Case recordOfCase : listOfCase) {
            // build a sparse record so DML payload is light (only Id + fields to change)
            Case recordToBeAdded = new Case();
            recordToBeAdded.Id = recordOfCase.Id;
            recordToBeAdded.Status = 'Closed';
            listToBeUpdated.add(recordToBeAdded);
        }

        // update the list
        if (!listToBeUpdated.isEmpty()) {
            Database.update(listToBeUpdated, false);
        }
    }
}
/*
// every Sunday at 2:00 AM
String cron = '0 0 2 ? * SUN *';
AutoCloseWaitingCasesScheduler job = new AutoCloseWaitingCasesScheduler();
System.schedule('Auto Close Waiting Cases', cron, job);
*/