@isTest
private class EmailProcessorTest {

    static void testHandleInboundEmail_Success() {

    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    
    Account testAccount = TestDataFactory.createAccount();
    Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id);
    email.subject = 'Test' + testOpp.Invoice_Number__c;
    EmailProcessor emailProcessor = new EmailProcessor();
    Messaging.InboundEmailResult result = emailProcessor.handleInboundEmail(email, envelope);
    System.assertEquals(true, result.success);
    System.assertEquals(null, result.message);

}

    @isTest
    static void testHandleInboundEmail_Exception() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = 'Test';
        
        EmailProcessor emailProcessor = new EmailProcessor();
        Messaging.InboundEmailResult result = emailProcessor.handleInboundEmail(email, envelope);
 
        System.assertEquals(false, result.success);
        System.assertNotEquals(null, result.message);
    }
    
    @isTest
    static void testProcessOpportunityEmail() {
        Account testAccount = TestDataFactory.createAccount();
        Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id);
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = 'Approved';

        EmailProcessor emailProcessor = new EmailProcessor();
        emailProcessor.processOpportunityEmail(email, testOpp);

        System.assertEquals('Closed Lost', testOpp.StageName);
    }
    
    @isTest
    static void testExtractInvoiceNumber() {
        String subject = 'Test1234';

        EmailProcessor emailProcessor = new EmailProcessor();
        String invoiceNumber = emailProcessor.extractInvoiceNumber(subject);

        System.assertEquals('1234', invoiceNumber);
    }

    @isTest
    static void testUpdateOpportunityStatus_Rejected() {
            Account testAccount = TestDataFactory.createAccount();
    Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id);
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = 'Rejected';
        
        EmailProcessor emailProcessor = new EmailProcessor();
        emailProcessor.updateOpportunityStatus(email.plainTextBody, testOpp);
        
        System.assertEquals('Closed Won', testOpp.StageName);
    }
    
      @isTest
static void testAdvanceOpportunityStage_Success() {
    Account acc = TestDataFactory.createAccount();
    insert acc;
    Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
    insert opp;

    String initialStage = 'Closed Lost';

    EmailProcessor processor = new EmailProcessor();
    processor.advanceOpportunityStage(opp);

    System.assertEquals(initialStage, opp.StageName);
}

    @isTest
    static void testAdvanceOpportunityStage_LastStage() {
        Account acc = TestDataFactory.createAccount();
        insert acc;
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        opp.StageName = 'Stage 3'; 
        insert opp;

        EmailProcessor processor = new EmailProcessor();
        processor.advanceOpportunityStage(opp);
        System.assertEquals('Closed Won', opp.StageName);
    }
    
    @isTest
    static void testSetOpportunityStageToClosedLost() {
        Account acc = TestDataFactory.createAccount();
        insert acc;
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        insert opp;

        EmailProcessor processor = new EmailProcessor();
        processor.setOpportunityStageToClosedLost(opp);

        System.assertEquals('Closed Lost', opp.StageName);
    }
       
    @isTest
    static void testUpdateOpportunity() {
        Account acc = TestDataFactory.createAccount();
        insert acc;
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        insert opp;

        opp.Name = 'Updated Opportunity Name';

        EmailProcessor processor = new EmailProcessor();
        processor.updateOpportunity(opp);
        
        Opportunity updatedOpp = [SELECT Name FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Updated Opportunity Name', updatedOpp.Name);
    }
    
}