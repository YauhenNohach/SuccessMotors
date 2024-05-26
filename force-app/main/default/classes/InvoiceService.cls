public with sharing class InvoiceService {

    @AuraEnabled(cacheable=true)
    public static ContentVersion getPreview(String invoiceNumber) {
            
            List<ContentVersion> contentVersions = [SELECT Id, Title, ContentDocumentId 
                                                    FROM ContentVersion 
                                                    WHERE Title = :invoiceNumber LIMIT 1];
            
            if (!contentVersions.isEmpty()) {
                return contentVersions[0];
            }

        return null;
    }
}