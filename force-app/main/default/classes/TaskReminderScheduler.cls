/*Name: TaskReminderScheduler
*AuthorName:Ankit Kumar
*Description:every morning at 9 AM and sends an email reminder to all
users who have pending tasks due today
*Date:06/09/25
*/


public with sharing class TaskReminderScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        try{
            
            List<Task> pendingTasks = [
                SELECT Id, Subject, ActivityDate, OwnerId
                FROM Task
                WHERE Status != 'Completed'
                AND ActivityDate = TODAY
            ];
            
            
            if (pendingTasks.isEmpty()) return;
            
            
            Map<Id, List<Task>> mapOfOwnerIdAndTask = new Map<Id, List<Task>>();
            for (Task recordOfTask : pendingTasks) {
                if (!mapOfOwnerIdAndTask.containsKey(recordOfTask.OwnerId)) {
                    mapOfOwnerIdAndTask.put(recordOfTask.OwnerId, new List<Task>());
                }
                mapOfOwnerIdAndTask.get(recordOfTask.OwnerId).add(recordOfTask);
            }
            
            
            EmailTemplate emailTemplateRec = [ SELECT Id FROM EmailTemplate WHERE
                                              DeveloperName = 'Task_Reminder_Template' LIMIT 1];
            
       
            List<Messaging.SingleEmailMessage> listOfEmailMessage = new List<Messaging.SingleEmailMessage>();
            for (Id ownerId : mapOfOwnerIdAndTask.keySet()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(emailTemplateRec.Id);
                mail.setTargetObjectId(ownerId); 
                mail.setSaveAsActivity(false);
                listOfEmailMessage.add(mail);
            }
            
            
            if (!listOfEmailMessage.isEmpty()) {
                Messaging.sendEmail(listOfEmailMessage);
            }
        }catch(Exception EX){
            System.debug('General Exception:'+ ex.getMessage());
        }
    }
}


/*
String cron = '0 0 9 * * ?'; 
System.schedule('Daily Task Reminder', cron, new TaskReminderScheduler());

     /*
             * EmailTemplate emailTemplateRec = new EmailTemplate(
    Name          = 'Task Reminder Template',
    DeveloperName = 'Task_Reminder_Template',
    TemplateType  = 'html',          // 'text' if you only use TextBody
    Subject       = 'Task Reminder',
    HtmlValue     = '<p>Your task reminder</p>',
    FolderId      = UserInfo.getUserId() // or Id of an Email Folder
);
insert emailTemplateRec;
*/