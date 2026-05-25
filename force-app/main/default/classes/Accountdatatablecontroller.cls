public with sharing class Accountdatatablecontroller {
   //get account list
   @AuraEnabled
   public static List<Account> getAccountList(String mobileNo){
     system.debug('mobileNo>>' + mobileNo);
      system.debug('list of acount>>'+ [SELECT Id,Name,Phone,Type,Industry,PersonEmail FROM Account WHERE Phone=:mobileNo]);
      return [SELECT Id,Name,Phone,Type,Industry,PersonEmail FROM Account WHERE Phone=:mobileNo];

     
       
   }
}