public with sharing class AssessmentPractiseBatch implements Database.Batchable<SObject>,Database.Stateful {
    public Decimal noofAccountMarkedInactive=0;
    public Decimal noofrecordnotmarkedAsInactive=0;
    Public Decimal noOfRecordProceed=0;
    
    
    //start
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,(SELECT Id FROM Tasks WHERE Status !='Completed'),
                                         (SELECT Id,WhatId FROM Events WHERE EndDateTime>today),
                                         (SELECT Id From Cases WHERE Status!='Closed') From Account LIMIT 10]);
    } 
    //execute
    public void execute(Database.BatchableContext bc,List<Account> accountBatch){
        
        
        //collection
        List<Account> listOfAccountToUpdates= new List<Account>();
        
        
        for(Account acc:accountBatch){
            if(acc.Tasks.size()==0 && acc.Events.size()==0 && acc.Cases.size()==0){
                
                Account recordOfAccountAddedInCollection=new Account();
                recordOfAccountAddedInCollection.Id=acc.Id;
                recordOfAccountAddedInCollection.Active__c='No';
                listOfAccountToUpdates.add(recordOfAccountAddedInCollection);
            }
            
            
        }
        
        Set<Id> setOfAccountMarkedInActive= new Set<Id>();
        
        if(!listOfAccountToUpdates.isEmpty()){
            
            //List<Database.SaveResult> srlist= Database.update(listOfAccountToUpdates,false);
            Database.SaveResult[] srlist=Database.Update(listOfAccountToUpdates,false);
            
            for(Database.SaveResult sr:srlist){
                if(sr.isSuccess()){
                    noofAccountMarkedInactive++;
                    system.debug('success Account Id'+ sr.getId());
                    setOfAccountMarkedInActive.add(sr.getId());
                    
                }else{
                    noofrecordnotmarkedAsInactive++;
                    for(Database.Error err:sr.getErrors()){
                        system.debug('Error'+ err.getMessage());
                    }
                }
            }
            
        }
        
        
        
        List<Account> listOfInactiveAccount = [
            SELECT Id, OwnerId, Owner.Email 
            FROM Account 
            WHERE Id IN :setOfAccountMarkedInActive
        ];
        
        //create task
        List<Task> listOfTask= new List<Task>();
        for(Account acc:listOfInactiveAccount){
            //task creation
            Task recordOfTaskAddedInCollection=new Task();
            recordOfTaskAddedInCollection.OwnerId=acc.OwnerId;
            recordOfTaskAddedInCollection.Status='Not Started';
            recordOfTaskAddedInCollection.Priority='Normal';
            recordOfTaskAddedInCollection.Subject='Account are Inactive';
            recordOfTaskAddedInCollection.ActivityDate= Date.today().addDays(2);
            recordOfTaskAddedInCollection.WhatId=acc.Id;
            
            listOfTask.add(recordOfTaskAddedInCollection);
            
        }
        if(!listOfTask.isEmpty()){
            Database.insert(listOfTask,false);
        }
        
        //email bhejma hai bhaiii
        List<Messaging.SingleEmailMessage> listOfEmmailmssg=new List<Messaging.SingleEmailMessage>();
        for(Account acc : listOfInactiveAccount){
            System.debug('acc.Owner.Email'+acc.Owner.Email);
            System.debug('acc.OwnerId'+acc.OwnerId);
            if(String.isNotBlank(acc.Owner.Email) && acc.OwnerId !='005NS00000QxnaYYAR'){
                Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
                em.setToAddresses(new List<String>{ acc.Owner.Email });
                em.setSubject('Account Marked as Inactive');
                em.setPlainTextBody('Hi, the Account ' + acc.Id + ' is now inactive.');
                listOfEmmailmssg.add(em);
            } else {
                System.debug('No email found for Owner of Account ' + acc.Id);
            }
        }
        
        
        if(!listOfEmmailmssg.isEmpty()){
            Messaging.sendEmail(listOfEmmailmssg);
        }
        
        
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
}