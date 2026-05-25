public with sharing class RestaurantHomePageController {

    //Get the cuisine type picklist value
      @AuraEnabled(cacheable=true)
      public static List<String> getCuisineTypePicklistValue(){
            List<String> picklistvalues= new List<String>();
            Schema.DescribeFieldResult fieldResult=Restaurant__c.Cuisine_Type__c.getDescribe();
            List<Schema.PicklistEntry> p= fieldResult.getPicklistValues();
            for(Schema.PicklistEntry recordofPicklisstvalue:p){
                   picklistvalues.add(recordOfPicklisstvalue.getValue());
            }

            return picklistvalues;
      }

      //get the restaurant list
      @AuraEnabled(cacheable=true)
      public static List<Restaurant__c> getRestaurantList(String searchLocation,String searchRestaurant,String selectCuisine,Boolean isVegOnly){
         System.debug('isVegOnly>>' + isVegOnly);
              String baseQuery='SELECT Id,Name,	Phone__c,Rating__c,Location__c,Cuisine_Type__c,Restaurant_Image__c,Restaurant_Type__c FROM Restaurant__c WHERE Id!=null';
			
             if(String.isNotBlank(searchLocation)){
                  baseQuery+=' AND Location__c LIKE \'%' + searchLocation + '%\'';
              }
              if(String.isNotBlank(searchRestaurant)){
                  baseQuery+=' AND Name LIKE \'%' + searchRestaurant + '%\'';
              }
              if(String.isNotBlank(selectCuisine)){
                  baseQuery+=' AND Cuisine_Type__c = \'' + selectCuisine + '\'';
              }
              
        

              if(isVegOnly) {
                  System.debug('isVegOnly>>' + isVegOnly);
                  baseQuery += ' AND Restaurant_Type__c = \'only veg\'';
                }

          
              System.debug('baseQuery--->' + Database.query(baseQuery));
                return Database.query(baseQuery);
                
      }

      
    
}