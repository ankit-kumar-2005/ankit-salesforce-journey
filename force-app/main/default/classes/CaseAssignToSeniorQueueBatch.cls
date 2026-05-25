public with sharing class CaseAssignToSeniorQueueBatch implements Database.Batchable<SObject>,Database.Stateful{
    Integer reassignedCaseCount=0;
    //start1
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,	Priority From Case WHERE
                                         Priority='High' and Status !='Closed'] );
    }
    //Execute
    public void execute(Database.BatchableContext bc,List<Case> caseBatch){
        Group seniorSupportQueue=[Select Id From Group WHERE
                                  Type='Queue' AND DeveloperName='Senior_Support_Queue' LIMIT 1];
        
        List<Case> caseToUpdate=new List<Case>();
        for(Case c:caseBatch){
            case caseAddedInUpdate=new case();
            caseAddedInUpdate.Id=c.Id;
            caseAddedInUpdate.OwnerId=seniorSupportQueue.Id;
            caseToUpdate.add(caseAddedInUpdate);
        }
        
        if(!caseToUpdate.isEmpty()){
            Database.SaveResult[] results=Database.update(caseToUpdate,false);
            for(Database.SaveResult sr: results){
                if(sr.isSuccess()){
                    reassignedCaseCount++;
                }
            }
        }
        
    }
    
    //Finish
    Public Void finish(Database.BatchableContext bc){
        system.debug('number of cases reassigned.'+ reassignedCaseCount);
    }
}