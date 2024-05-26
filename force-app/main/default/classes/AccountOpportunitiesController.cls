public with sharing class AccountOpportunitiesController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name 
                FROM Account 
                WHERE Id IN (SELECT AccountId 
                             FROM Opportunity 
                             WHERE IsClosed = true AND StageName = 'Closed Won')];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getOppRecords( String id ){
            return [SELECT Id, Name, StageName, CreatedDate, CloseDate, Amount 
            FROM Opportunity 
            WHERE AccountId = :id 
            AND IsClosed = true]; 
    }

    @AuraEnabled(cacheable = true)
    public static List<OpportunityLineItem> getOpportunityProducts(String oppId) {
     return [SELECT Id, Product2.Name, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :oppId];

    }


}