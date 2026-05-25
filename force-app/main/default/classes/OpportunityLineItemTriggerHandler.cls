/*
 * Name: OpportunityLineItemTriggerHandler
 * Author Name: Ankit Kumar
 * Description: Helper class to maintain Opportunity totals (Q3)
 * Date: 01/09/25
 */
 public with sharing class  OpportunityLineItemTriggerHandler  {

    public static void updateOpportunityTotals(List<OpportunityLineItem> listofOpportunityLineItem){
        Set<Id> setOfOpportunityId=new Set<Id>();
        for(OpportunityLineItem oppproduct:listofOpportunityLineItem){
            setOfOpportunityId.add(oppproduct.OpportunityId);
        }

        if(setOfOpportunityId.isEmpty()){
            return;
        }
        List<AggregateResult> listOfAgg= [SELECT OpportunityId,SUM(TotalPrice) totalAmount,
                                          SUM(Quantity) totalQuantity FROM OpportunityLineItem 
                                          WHERE OpportunityId IN:setOfOpportunityId
                                          GROUP BY OpportunityId];

        Map<Id,AggregateResult> mapOfIdAndAgg=new map<Id,AggregateResult>();
        for(AggregateResult ar:listOfAgg){
              mapOfIdAndAgg.put((Id)ar.get('OpportunityId'), ar);
        }
        //listofOpp to update
        List<Opportunity> listOfOpportunityToUpdate= new List<Opportunity>();

        for(Id OppId:mapOfIdAndAgg.keySet()){
            AggregateResult agg = mapOfIdAndAgg.get(oppId);
            Opportunity oppToAddedInUpdatedList= new Opportunity();

            oppToAddedInUpdatedList.Id=oppId;
            oppToAddedInUpdatedList.Total_Product_Quantity__c=(Decimal)agg.get('totalQuantity');
            oppToAddedInUpdatedList.Total_Products_Amount__c=(Decimal)agg.get('totalAmount');
            listOfOpportunityToUpdate.add(oppToAddedInUpdatedList);
        }

        if(!listOfOpportunityToUpdate.isEmpty()){
            Database.update(listOfOpportunityToUpdate,false);
        }
    }
    
}