/*
  @Name=UpdateCaseOnBasisOfPriorityScheduler
  @Author Name=Ankit Kumar
  @Description=updates all High priority cases that are open for more than 48
               hours to "Critical".
  @Date=07/09/25
  */


public with sharing class UpdateCaseOnBasisOfPriorityScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        // list of High priority cases that are open for more than 48 hours
        List<Case> listOfHighPriorityCase = [
            SELECT Id,Priority
            FROM Case
            WHERE Priority = 'High'
            AND Status != 'Closed'
            AND CreatedDate <= :System.now().addDays(-2)
        ];

        // collection to be updated
        List<Case> listOfCaseToBeUpdated = new List<Case>();

        for (Case recordOfCase : listOfHighPriorityCase) {
            Case recordOfCaseAdded = new Case();
            recordOfCaseAdded.Id = recordOfCase.Id;
            recordOfCaseAdded.Priority = 'Critical';
            listOfCaseToBeUpdated.add(recordOfCaseAdded);
        }

        if (!listOfCaseToBeUpdated.isEmpty()) {
            Database.update(listOfCaseToBeUpdated, false);
        }
    }
}
/*
// Every day at 2:00 AM
String cron = '0 0 2 * * ?';
HighToCriticalCasesScheduler job = new HighToCriticalCasesScheduler();
System.schedule('High Priority -> Critical Job', cron, job);


*/