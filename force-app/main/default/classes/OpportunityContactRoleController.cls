public with sharing class OpportunityContactRoleController {
    @AuraEnabled(cacheable=true)
    public static OpportunityContactRole getContactRoleByOpportunityId(Id opportunityId) {
        return [SELECT Id, Contact.Name, Contact.Email FROM OpportunityContactRole WHERE OpportunityId = :opportunityId LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static String getInvoiceNumber(Id opportunityId) {
        Opportunity opp = [SELECT Invoice_Number__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        return opp.Invoice_Number__c;
    }
}