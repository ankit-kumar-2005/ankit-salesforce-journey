trigger RestaurantTrigger on Restaurant__c(before insert) {

    if(Trigger.isBefore){
          RestaurantHandler.preventRestaurantCreation(Trigger.new);
    }

}