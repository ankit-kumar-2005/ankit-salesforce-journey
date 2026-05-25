public with sharing class MenuPageController {
    //Get the food category type picklist
    @AuraEnabled(cacheable=true)
    public static List<String> getCategoryTypePickListValue(){
        List<String> picklistvalues= new List<String>();
        Schema.DescribeFieldResult fieldresult=Menu_Item__c.Category__c.getDescribe();
        List<Schema.picklistEntry> p= fieldresult.getPicklistValues();
        for(Schema.picklistEntry recordofpicklistvalue:p){
                  picklistvalues.add(recordofpicklistvalue.getValue());
        }

        return picklistvalues;
    }

    //get food menu list 
    @AuraEnabled(cacheable=true)
    public static List<Menu_Item__c> getFoodMenuList(String searchMenu,String selectCategory,Id restaurantId ){
    
        string baseQuery='Select Id,Menu_Item__r.Name,Menu_Item__r.Image__c,Price__c,A__c,Menu_Item__r.Description__c FROM Restaurant_Menu_Item__c WHERE Restaurant__c=:restaurantId';

        if(String.isNotBlank(searchMenu)){
         baseQuery += ' AND Menu_Item__r.Name LIKE \'%' + searchMenu +'%'+ '\'';
        }
        if(String.isNotBlank(selectCategory)){
            baseQuery += ' AND Menu_Item__r.Category__c = \'' + selectCategory + '\'';
        }

        return database.query(baseQuery);

    }
}