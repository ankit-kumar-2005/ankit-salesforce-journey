public with sharing class TimeEntryOutTime implements Database.Batchable<SObject> {
    //start
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Date__c,Out_Time__c FROM  
                                           Time_Entry__c WHERE Out_Time__c = null
                                            AND Date__c = today]);
    }

    //Execute
    public void execute (Database.BatchableContext bc,List<Time_Entry__c> timeEntryBatch){
        //collection to update
        List<Time_Entry__c> timeEntryToUpdate=new List<Time_Entry__c>();
        for(Time_Entry__C timeEntryRecord:timeEntryBatch){
            Time_Entry__c timeEntryRecordAddedInUpdate=new Time_Entry__c();
            timeEntryRecordAddedInUpdate.Id=timeEntryRecord.Id;
            timeEntryRecordAddedInUpdate.Out_Time__c= Time.newInstance(18, 0, 0, 0);
            timeEntryToUpdate.add(timeEntryRecordAddedInUpdate);
        }
        if(!timeEntryToUpdate.isEmpty()){
            Database.update(timeEntryToUpdate,false);
        }
    }
    
    //Finish
    public void finish(Database.BatchableContext bc){

    }

   

   
}