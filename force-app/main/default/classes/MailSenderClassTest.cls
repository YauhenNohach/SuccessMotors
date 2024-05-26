@isTest
private class MailSenderClassTest {

   @isTest
static void testSendEmail() {
    Opportunity testOpp = new Opportunity(
        Name = 'Test Opportunity',
        StageName = 'Closed Won',
        CloseDate = Date.today()
    );
    insert testOpp;
    
    ContentVersion testContentVersion = new ContentVersion(
        VersionData = Blob.valueOf('Test PDF content'),
        Title = 'Test PDF',
        PathOnClient = 'TestPDF.pdf',
        IsMajorVersion = true
    );
    insert testContentVersion;
    
    ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
        ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
        LinkedEntityId = testOpp.Id,
        ShareType = 'V'
    );
    insert testContentDocumentLink;
    
    String recipientEmail = 'test@example.com';
    String subject = 'Test Email';
    String body = 'This is a test email';
    
    Test.startTest();
    MailSenderClass.sendEmail(recipientEmail, subject, body, testOpp.Id);
    Test.stopTest();
    
    System.assertEquals(0, Limits.getEmailInvocations(), 'Email not sent');
}
    @isTest
    static void testGetPdfContent() {
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today()
        );
        insert testOpp;

        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test PDF content'),
            Title = 'Test PDF',
            PathOnClient = 'TestPDF.pdf',
            IsMajorVersion = true
        );
        insert testContentVersion;
        
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testOpp.Id,
            ShareType = 'V'
        );
        insert testContentDocumentLink;
        
        Test.startTest();
        Blob pdfBlob = MailSenderClass.getPdfContent(testOpp.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, pdfBlob, 'PDF content not retrieved');
    }
}