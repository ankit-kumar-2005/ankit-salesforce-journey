public with sharing class CartController {

    public class OrderItemWrapper {
        @AuraEnabled public Id menuItemId;
        @AuraEnabled public Integer quantity;
        @AuraEnabled public Decimal subtotal;
        @AuraEnabled public String spiceLevel;
        @AuraEnabled public String customization;
    }

    public class OrderWrapper {
        @AuraEnabled public String customerName;
        @AuraEnabled public String customerEmail;
        @AuraEnabled public String customerPhone;
        @AuraEnabled public String paymentType;
        @AuraEnabled public Decimal grandTotal;
        @AuraEnabled public List<OrderItemWrapper> items;
    }

    @AuraEnabled
    public static Id createOrderWithDetails(String orderWrapperJson) {
        OrderWrapper wrapper = (OrderWrapper)JSON.deserialize(orderWrapperJson, OrderWrapper.class);

        // 1. Create Contact (new contact for now, could be merged with existing if needed)
        Contact cust = new Contact(
            LastName = wrapper.customerName,
            Email = wrapper.customerEmail,
            Phone = wrapper.customerPhone
        );
        insert cust;

        // 2. Create Order__c
        Order__c ord = new Order__c(
            Customer__c = cust.Id,
            Order_Status__c = 'In Progress',
            Total_Amount__c = wrapper.grandTotal,
            Order_Date__c = System.now()
        );
        insert ord;

        // 3. Create Order_Item__c records
        List<Order_Item__c> orderItems = new List<Order_Item__c>();
        for (OrderItemWrapper item : wrapper.items) {
            orderItems.add(new Order_Item__c(
                Order__c = ord.Id,
                Restaurant_Menu_Item__c = item.menuItemId,
                Quantity__c = item.quantity,
                Spice_Level__c = item.spiceLevel,
                Customization__c = item.customization
            ));
        }
        if (!orderItems.isEmpty()) {
            insert orderItems;
        }

        // 4. Create Payment__c
        Payment__c payment = new Payment__c(
            Order__c = ord.Id,
            Amount__c = wrapper.grandTotal,
            Payment_Method__c = wrapper.paymentType,
            Payment_Status__c = 'Completed'
        );
        insert payment;

        return ord.Id;
    }
}