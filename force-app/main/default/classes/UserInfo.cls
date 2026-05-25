public with sharing class UserInfo {
    //method to get user information
    @AuraEnabled(cacheable=true)
   public static User getUserInfo(Id  userId){
          User userToShow = [SELECT Id, Name, Email, Username, Profile.Name, ProfileId, isActive
           FROM User WHERE Id=:userId LIMIT 1];

           return userToShow;
   }
   //Method to get all the user Name
   @AuraEnabled (cacheable=true)
   public static List<User> getAllUser(){
     return [SELECT Id,Name FROM User];
   }
}