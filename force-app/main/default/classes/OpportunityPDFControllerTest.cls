@isTest
private class OpportunityPDFControllerTest {
    

    @isTest
    static void testSavePDF_UpdateExisting() {
        Account testAccount = TestDataFactory.createAccount();
        insert testAccount;
        
        Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount.Id);
        insert testOpportunity;

        ContentVersion existingCV = new ContentVersion(
            Title = testOpportunity.Invoice_Number__c,
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test Content')
        );
        insert existingCV;

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
        OpportunityPDFController controller = new OpportunityPDFController(stdController);
        PageReference pdfPage = controller.save();
        Test.stopTest();

        List<ContentVersion> updatedCVs = [SELECT Id FROM ContentVersion WHERE Id = :existingCV.Id];
        System.assertEquals(1, updatedCVs.size());
    }
   

    @isTest
static void testGetOpportunityContactRoles() {
    Account testAccount = TestDataFactory.createAccount();
    insert testAccount;

    Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount.Id);
    insert testOpportunity;

    OpportunityContactRole testContactRole = TestDataFactory.createContactRole(testOpportunity.Id);
    insert testContactRole;

    ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
    OpportunityPDFController controller = new OpportunityPDFController(stdController);

    List<OpportunityContactRole> contactRoles = controller.getOpportunityContactRoles();
    
    System.assertEquals(1, contactRoles.size());

    OpportunityContactRole retrievedRole = contactRoles[0];
    System.assertEquals(testContactRole.Id, retrievedRole.Id);
    System.assertEquals('John Doe', retrievedRole.Contact.Name);
    System.assertEquals('Test Account', retrievedRole.Contact.Account.Name);
    System.assertEquals(testContactRole.Contact.Phone, retrievedRole.Contact.Phone);
    System.assertEquals('john.doe@example.com', retrievedRole.Contact.Email);
    System.assertEquals(testContactRole.IsPrimary, retrievedRole.IsPrimary);
}
    
    @IsTest
    static void testInsertNewPDF() {

        Account acc = TestDataFactory.createAccount();
        insert acc;

        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        insert opp;

        Blob testPdfBlob = Blob.valueOf('Test PDF Content'); 

        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        OpportunityPDFController controller = new OpportunityPDFController(stdController);

        Test.startTest();

        controller.insertNewPDF(testPdfBlob);

        Test.stopTest();

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId = :opp.Id];
        System.assertEquals(1, contentVersions.size(), 'Expected one ContentVersion record to be inserted');
    }
    
      @isTest
    static void testUpdateExistingPDF() {
        Account acc = TestDataFactory.createAccount();
        insert acc;

        Opportunity opp = TestDataFactory.createOpportunity();
        opp.AccountId = acc.Id;
        insert opp;

        Blob fakePdfBlob = Blob.valueOf('Fake PDF Content');

        ContentVersion existingCV = new ContentVersion(
    Title = 'Test Invoice',
    PathOnClient = 'Test Invoice.pdf',
    VersionData = Blob.valueOf('Old PDF Content'),
    FirstPublishLocationId = opp.Id
);
        insert existingCV;

        OpportunityPDFController controller = new OpportunityPDFController(new ApexPages.StandardController(opp));
        controller.updateExistingPDF(fakePdfBlob, new ContentVersion[]{existingCV});

        List<ContentVersion> updatedCVs = [SELECT Id, Title FROM ContentVersion WHERE Id = :existingCV.Id];

        System.assertEquals('Test Invoice', updatedCVs[0].Title);
    }
    
    @isTest
    static void testGetOpportunityLineItems_NoLineItems() {
        Account acc = TestDataFactory.createAccount();
        insert acc;

        Opportunity opp = TestDataFactory.createOpportunity();
        opp.AccountId = acc.Id;
        insert opp;

        OpportunityPDFController controller = new OpportunityPDFController(new ApexPages.StandardController(opp));
        List<OpportunityLineItem> lineItems = controller.getOpportunityLineItems();

        System.assertEquals(0, lineItems.size());
    }

}