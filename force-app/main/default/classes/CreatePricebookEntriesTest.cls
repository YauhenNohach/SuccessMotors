@isTest
private class CreatePricebookEntriesTest {

    @isTest
    static void testCreateEntries() {
        Pricebook2 standardPricebook = new Pricebook2(Name = 'StandardPricebook');
        insert standardPricebook;

        Id standardPricebookId = standardPricebook.Id;

        List<Product2> testProducts = new List<Product2>();
        for(Integer i = 0; i < 5; i++) {
            testProducts.add(new Product2(Name = 'Test Product ' + i));
        }
        insert testProducts;

        Test.startTest();
        CreatePricebookEntries.createEntries(testProducts);
        Test.stopTest();

        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry];
        System.assertEquals(testProducts.size(), pricebookEntries.size());
    }



    @isTest
    static void testGetStandardPricebookId() {
        Pricebook2 standardPricebook = new Pricebook2(Name = 'StandardPricebook');
        insert standardPricebook;

        Test.startTest();
        Id standardPricebookId = TestDataFactory.getStandardPricebookId();
        Test.stopTest();

        System.assertEquals(standardPricebook.Id, standardPricebookId);
    }

    @isTest
    static void testGenerateStandardPriceEntries() {
        List<Product2> testProducts = new List<Product2>();
        for(Integer i = 0; i < 5; i++) {
            testProducts.add(new Product2(Name = 'Test Product ' + i));
        }
        insert testProducts;

        Pricebook2 standardPricebook = new Pricebook2(Name = 'StandardPricebook');
        insert standardPricebook;

        List<PricebookEntry> entries = CreatePricebookEntries.generateStandardPriceEntries(testProducts, standardPricebook.Id);

        System.assertEquals(testProducts.size(), entries.size());
    }

    @isTest
    static void testGenerateStandardPriceEntry() {

        Product2 testProduct = new Product2(Name = 'Test Product');
        insert testProduct;

        Pricebook2 standardPricebook = new Pricebook2(Name = 'StandardPricebook');
        insert standardPricebook;

        PricebookEntry entry = CreatePricebookEntries.generateStandardPriceEntry(testProduct, standardPricebook.Id);

        System.assertEquals(testProduct.Id, entry.Product2Id);
        System.assertEquals(standardPricebook.Id, entry.Pricebook2Id);
        System.assertNotEquals(null, entry.UnitPrice);
        System.assertEquals(true, entry.IsActive);
    }

    @isTest
    static void testInsertStandardPriceEntries() {
        List<PricebookEntry> entries = new List<PricebookEntry>();
        entries.add(new PricebookEntry(UnitPrice = 100, IsActive = true));
        entries.add(new PricebookEntry(UnitPrice = 200, IsActive = true));

        Test.startTest();
        CreatePricebookEntries.insertStandardPriceEntries(entries);
        Test.stopTest();

        List<PricebookEntry> insertedEntries = [SELECT Id FROM PricebookEntry];
        System.assertEquals(entries.size(), insertedEntries.size());
    }
}