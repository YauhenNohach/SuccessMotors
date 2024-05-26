public class PriceBookEntryUtility {

  public static void deletePriceBookEntries() {
       delete [SELECT Id FROM PricebookEntry];
    }
    
    public static void deleteAllProducts() {
        delete [SELECT Id FROM Product2];
    }
}