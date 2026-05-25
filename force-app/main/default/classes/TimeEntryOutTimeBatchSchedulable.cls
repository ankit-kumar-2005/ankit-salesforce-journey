/*Name:TimeEntryOutTimeBatchSchedulable 
  Author Name= Ankit
  Description: TimeEntryOutTimeBatchSchedulable
  Date:06/09/25


*/
public with sharing class TimeEntryOutTimeBatchSchedulable  implements Schedulable {
    public void execute(SchedulableContext sc) {
        TimeEntryOutTimeBatch batch = new TimeEntryOutTimeBatch();
        Database.executeBatch(batch);
    }
    
}