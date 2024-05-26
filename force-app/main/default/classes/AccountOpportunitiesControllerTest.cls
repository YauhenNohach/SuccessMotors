@isTest
private class AccountOpportunitiesControllerTest {
    
    @isTest
    static void testGetAccounts() {
        Account testAccount = TestDataFactory.createAccount();
        insert testAccount;

        Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount.Id);
        insert testOpportunity;

        Test.startTest();
        List<Account> accounts = AccountOpportunitiesController.getAccounts();
        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals(testAccount.Id, accounts[0].Id);
    }

    @isTest
    static void testGetOppRecords() {
        Account testAccount = TestDataFactory.createAccount();
        insert testAccount;

        Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount.Id);
        insert testOpportunity;

        Test.startTest();
        List<Opportunity> opps = AccountOpportunitiesController.getOppRecords(testAccount.Id);
        Test.stopTest();
        
        System.assertEquals(1, opps.size());
        System.assertEquals(testOpportunity.Id, opps[0].Id);
    }

@isTest
static void testGetOpportunityProducts() {
    Account testAccount = TestDataFactory.createAccount();
    insert testAccount;

    Id standardPricebookId = Test.getStandardPricebookId();

    Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount.Id);
    testOpportunity.Pricebook2Id = standardPricebookId; 
    insert testOpportunity;

    Product2 testProduct = new Product2(
        Name = 'Test Product'
    );
    insert testProduct;

    PricebookEntry entry = new PricebookEntry(
        Pricebook2Id = standardPricebookId,
        Product2Id = testProduct.Id,
        UnitPrice = 100, 
        IsActive = true
    );
    insert entry;

    OpportunityLineItem oli = new OpportunityLineItem(
        OpportunityId = testOpportunity.Id,
        PricebookEntryId = entry.Id, 
        Quantity = 1,
        TotalPrice = 100 
    );
    insert oli;

    Test.startTest();
    List<OpportunityLineItem> oppProducts = AccountOpportunitiesController.getOpportunityProducts(testOpportunity.Id);
    Test.stopTest();

    System.assertEquals(1, oppProducts.size());
    System.assertEquals(oli.Id, oppProducts[0].Id);
}

  @isTest
static void testGetOppRecords_ExceptionHandling() {
    Test.startTest();
    try {
        List<Opportunity> opps = AccountOpportunitiesController.getOppRecords('invalidAccountId');
    } catch (AuraHandledException e) {
        System.assertNotEquals(null, e.getMessage());
    }
    Test.stopTest();
}
    

@isTest
static void testGetOpportunityProducts_ExceptionHandling() {
    Test.startTest();
    try {
        List<OpportunityLineItem> oppProducts = AccountOpportunitiesController.getOpportunityProducts(null);
    } catch (AuraHandledException e) {
        System.assertNotEquals(null, e.getMessage());
    }
    Test.stopTest();
}
    
}