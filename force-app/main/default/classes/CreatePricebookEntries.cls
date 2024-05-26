public class CreatePricebookEntries {
    
    public static void createEntries(List<Product2> products) {
        Id standardPricebookId = getStandardPricebookId();
        List<PricebookEntry> standardPriceEntriesToInsert = generateStandardPriceEntries(products, standardPricebookId);
        insertStandardPriceEntries(standardPriceEntriesToInsert);
    }

    public static Id getStandardPricebookId() {
        return [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
    }

    public static List<PricebookEntry> generateStandardPriceEntries(List<Product2> products, Id standardPricebookId) {
        List<PricebookEntry> standardPriceEntriesToInsert = new List<PricebookEntry>();
        for (Product2 product : products) {
            PricebookEntry newEntry = generateStandardPriceEntry(product, standardPricebookId);
            standardPriceEntriesToInsert.add(newEntry);
        }
        return standardPriceEntriesToInsert;
    }

    public static PricebookEntry generateStandardPriceEntry(Product2 product, Id standardPricebookId) {
        return new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = standardPricebookId,
            UnitPrice = Math.round(Math.random() * 100), 
            IsActive = true
        );
    }

    public static void insertStandardPriceEntries(List<PricebookEntry> standardPriceEntriesToInsert) {
        if (!standardPriceEntriesToInsert.isEmpty()) {
            insert standardPriceEntriesToInsert;
            System.debug('Standard prices have been successfully created.');
        } else {
            System.debug('There are no products to create standard prices.');
        }
    }
}