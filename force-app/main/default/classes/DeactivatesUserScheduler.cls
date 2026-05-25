/*
  @Name=DeactivatesUserScheduler 
  @Author Name=Ankit Kumar
  @Description=schedulable class that checks users who haven’t logged in for 90 days and deactivates
              them.
  @Date=07/09/25
  */

public with sharing class DeactivatesUserScheduler implements Schedulable {
   public void execute(SchedulableContext sc){
    //list of users who haven’t logged in for 90 days and

    List<User> listOfUserToDeactivates=[SELECT Id, LastLoginDate, IsActive
                                        FROM User
                                        WHERE IsActive = true
                                        AND LastLoginDate  <= :System.today().addDays(-90) ];
    //yaha collection bna lo
     List<User> listOfUserToUpdate= new List<User>();

     for(User recordOfUser:listOfUserToDeactivates){
        user recordOfUserAdded=new User();
        recordOfUserAdded.Id=recordOfUser.Id;
        recordOfUserAdded.IsActive=false;
        listOfUserToUpdate.add(recordOfUserAdded);
     }

     if(!listOfUserToUpdate.isEmpty()){
        Database.update(listOfUserToUpdate,false);
     }
   }
}
/*
//run daily at 9 am
String cron=* * 9 * * ?;
System.Schedulable('User Deactivation',cron,new DeactivatesUserScheduler());

*/