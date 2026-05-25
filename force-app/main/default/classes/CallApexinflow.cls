public with sharing class CallApexinflow {
    
        @InvocableMethod(label='Flow To Apex Subject')
        Public Static void GetSubjectFromFlow(List<SubjectAndBody> Email){
            For(SubjectAndBody EmailPreint: Email){
                System.debug('Email Subject -->' + EmailPreint.EmailSubject);
                System.debug('Email Body -->' + EmailPreint.EmailBody);
            }
        
    }
        
        public class SubjectAndBody{
            @InvocableVariable(label='Email Subject')
            Public String EmailSubject;
            @InvocableVariable(label='Email Body')
            Public String EmailBody;
        }
    
}