@isTest
private class OpportunityContactRoleControllerTest {
@isTest
    static void testGetContactRoleByOpportunityId_WithExistingRole() {
        Account testAccount = TestDataFactory.createAccount();
        insert testAccount;
        Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id);
        insert testOpp;
        OpportunityContactRole role = TestDataFactory.createContactRole(testOpp.Id);
        insert role;

        Test.startTest();
        OpportunityContactRole result = OpportunityContactRoleController.getContactRoleByOpportunityId(testOpp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('John Doe', result.Contact.Name);
        System.assertEquals('john.doe@example.com', result.Contact.Email);
    }


    @isTest
static void testGetInvoiceNumber() {
    Account testAccount = TestDataFactory.createAccount();
    insert testAccount;
    Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount.Id);
    insert testOpportunity;

    String actualInvoiceNumber = OpportunityContactRoleController.getInvoiceNumber(testOpportunity.Id);
    System.assertEquals('INV-100011', actualInvoiceNumber);
}

}