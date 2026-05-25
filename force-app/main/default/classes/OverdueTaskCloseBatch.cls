public with sharing class OverdueTaskCloseBatch implements Database.Batchable<SObject>{
    //Start
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Status
                                         FROM Task  WHERE Status!='Completed' 
                                         AND ActivityDate < today]);
    }
    //Execute
    public void execute(Database.BatchableContext bc,List<Task>taskBatch){
        //prepare a list to update
        List<Task> listToUpdate=new List<Task>();
        for(Task recorOfTask:taskBatch){
            Task taskRecordAddedInUpdatedList= new Task();
            taskRecordAddedInUpdatedList.Id=recorOfTask.Id;
            taskRecordAddedInUpdatedList.Status='Closed';
            listToUpdate.add(taskRecordAddedInUpdatedList);
        }

        if(!listToUpdate.isEmpty()){
            Database.update(listToUpdate,false);
        }
    }
    //finish
    public void finish(Database.BatchableContext bc){
        system.debug('automatically closes overdue tasks. Successfully');
    }
}