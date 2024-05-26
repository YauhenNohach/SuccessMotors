public with sharing class MailSenderClass {
    
    @AuraEnabled
    public static void sendEmail(String recipientEmail, String subject, String body, String opportunityId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new List<String>{recipientEmail});
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        
        Blob pdfBlob = getPdfContent(opportunityId);

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Invoice.pdf');
        attachment.setBody(pdfBlob);
    
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});

        mail.setReplyTo('emailprocessor@15yefaogiub73mc8t1c8cln7r5ntfgxgmqg1hbokjagw4y93au.it-2kzjh2a0.ap49.apex.salesforce.com');

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>{mail};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
    }

    @AuraEnabled(cacheable=true)
    public static Blob getPdfContent(String opportunityId) {
        Blob pdfBlob;
        
            List<Id> contentDocumentIds = new List<Id>();
            for(ContentDocumentLink cdl : [SELECT ContentDocumentId 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId = :opportunityId]) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
            
            if (!contentDocumentIds.isEmpty()) {
                List<ContentVersion> contentVersions = [SELECT VersionData 
                                                        FROM ContentVersion 
                                                        WHERE ContentDocumentId IN :contentDocumentIds
                                                        AND FileExtension = 'pdf'
                                                        LIMIT 1];

                    pdfBlob = contentVersions[0].VersionData;
                
            
        }
        
        return pdfBlob;
    }
}