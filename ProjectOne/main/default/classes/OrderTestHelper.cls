@isTest
public with sharing class OrderTestHelper {
    public OrderTestHelper() {

    }

    @isTest
    public static void createOrderTest(){
    //create order object to test
        test.startTest();
        Pricebook2 bookId = [SELECT Id FROM Pricebook2 WITH SECURITY_ENFORCED LIMIT 1 ]; 
        Account account = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1];
    
        Order order = new Order(accountId = account.ID, status = 'Draft', EffectiveDate = System.today(), Pricebook2 = bookId);
        insert order;
        test.stopTest();
        System.assertNotEquals(null,order.id);

    } 
}
