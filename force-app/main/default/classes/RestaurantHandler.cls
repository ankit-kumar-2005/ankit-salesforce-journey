public with sharing class RestaurantHandler {
    public static void preventRestaurantCreation(List<Restaurant__c> listOfNewRestaurants) {

        for(Restaurant__c recordOfResturant:listOfNewRestaurants){
            if(recordOfResturant.Rating__c == '1'){
                recordOfResturant.addError('Rating can not be 1');
            }

        }
        
}
}