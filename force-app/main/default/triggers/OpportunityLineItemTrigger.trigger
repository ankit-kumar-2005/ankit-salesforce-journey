/*
 * Name: OpportunityLineItemTrigger
 * Author Name: Ankit Kumar
 * Description: Maintain Total_Products_Amount__c and Total_Product_Quantity__c fields 
 *              on Opportunity whenever related Opportunity Products are added, updated, or deleted.
 * Date: 01/09/25
 */
trigger  OpportunityLineItemTrigger on OpportunityLineItem(after insert){
 if(trigger.isAfter){
    if(trigger.isInsert || trigger.isUpdate){
        OpportunityLineItemTriggerHandler.updateOpportunityTotals(trigger.new);
    }
    if(trigger.isDelete){
        OpportunityLineItemTriggerHandler.updateOpportunityTotals(Trigger.old);
    }
 }
}