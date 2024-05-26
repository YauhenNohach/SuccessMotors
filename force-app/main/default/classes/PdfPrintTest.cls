@isTest
private class PdfPrintTest {

    @isTest
    static void testGetOpps() {
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 10000
        );
        insert testOpp;

        PageReference pageRef = Page.Opportunity_PDF; 
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        PdfPrint pdfPrint = new PdfPrint(stdController);

        List<Opportunity> opps = pdfPrint.getOpps();

        System.assertNotEquals(0, opps.size());
        System.assertEquals(testOpp.Id, opps[0].Id);
    }
}