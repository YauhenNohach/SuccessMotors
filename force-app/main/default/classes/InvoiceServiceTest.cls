@isTest
private class InvoiceServiceTest {
@isTest
static void testGetPreview_WithExistingContentVersion() {
    String invoiceNumber = 'TestInvoice';
    ContentVersion cv = new ContentVersion(
        Title = invoiceNumber,
        VersionData = Blob.valueOf('Test Data'),
        PathOnClient = 'TestPath' 
    );
    insert cv;

    Test.startTest();
    ContentVersion result = InvoiceService.getPreview(invoiceNumber);
    Test.stopTest();

    System.assertNotEquals(null, result);
    System.assertEquals(invoiceNumber, result.Title);
}

    @isTest
    static void testGetPreview_WithNonExistingContentVersion() {
        String invoiceNumber = 'NonExistingInvoice';

        Test.startTest();
        ContentVersion result = InvoiceService.getPreview(invoiceNumber);
        Test.stopTest();

        System.assertEquals(null, result);
    }
}