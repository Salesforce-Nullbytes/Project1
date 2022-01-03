public without sharing class OrderController {

@AuraEnabled
    public static string createOrder(List<String> toppings){

        
        System.debug(toppings.size());

        //convert toppinglist to multiselect piclist
        String toppingString = '';
        for (String topping : toppings) {
            toppingString += topping + ';';
        }

        try {
            Pricebook2 bookId = [SELECT Id FROM Pricebook2 WITH SECURITY_ENFORCED LIMIT 1 ]; 
            Account account = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1];
        
            Order order = new Order(accountId = account.ID, status = 'Draft', EffectiveDate = System.today(), Pricebook2 = bookId, toppings__c = toppingString);
            
            insert order;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return 'failure';
        }
        return 'success';
    
    }
    public static void preventDeleteWithRecentOrder(List<Order> orders){
        System.debug('Trigger Helper');
        for(Order order : orders){
            Date orderDate = order.effectiveDate;
            if(orderDate.addYears(1) > System.Today()){
            System.debug('Preventing Delete');
                order.addError('Orders less than one year old cannot be deleted');
            }
        }
    }
}


