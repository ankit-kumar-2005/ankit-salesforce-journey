/*
@Name:UpdateContactLastActivityBatch
@Author:Ankit Kumar
@Description:updates the Last_Activity_Date__c field on Contact records based on their most recent completed Task.
@Date:06-09-25
*/


public with sharing class UpdateContactLastActivityBatch implements Database.Batchable<SObject> {
    //start
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,	Last_Activity_Date__c From Contact]);
    }
    //Execute
    public  void execute(Database.BatchableContext bc,List<Contact> contactBatch){
        Set<Id> setOfConactIds=new Set<Id>();
        for(Contact con:contactBatch){
            setOfConactIds.add(con.Id);
        }
        Map<Id,Date> mapOfContatLastActivityDate= new Map<Id,Date>();


        List<Task> listOfTask=[SELECT WhoId,ActivityDate FROM Task 
                             WHERE Status='Completed' AND WhoId IN:setOfConactIds
                             ORDER BY ActivityDate Desc ];
        Map<Id,Date> latestTaskDate= new Map<Id,Date>();
        for(Task taskRecord:listOfTask){
            if(!latestTaskDate.ContainsKey(taskRecord.WhoId)){
                latestTaskDate.put(taskRecord.WhoId, taskRecord.ActivityDate);
            }
        }

        List<Contact> contactToUpdate=new List<Contact>();
        //iterate over map
        for(Id conId:latestTaskDate.keySet()){
            Contact contactAddedToUpdate=new Contact();
             contactAddedToUpdate.Id=conId;
             contactAddedToUpdate.Last_Activity_Date__c=latestTaskDate.get(conId);
             contactToUpdate.add(contactAddedToUpdate);
        }

        if(!contactToUpdate.isEmpty()){
            Database.Update(contactToUpdate,false);
        }
    }
    //finish
    public  void finish(Database.BatchableContext bc){
        system.debug('Last_Activity_Date__c field on Contact records updated Successfully');
    }
}