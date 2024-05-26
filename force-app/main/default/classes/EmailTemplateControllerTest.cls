@isTest
private class EmailTemplateControllerTest {

    @isTest
    static void testGetEmailTemplate() {

        EmailTemplate testTemplate = new EmailTemplate(
            DeveloperName = 'Test_Template',
            Subject = 'Test Subject',
            HtmlValue = '<html><body>Test Body</body></html>'
        );
        insert testTemplate;

        Test.startTest();
        EmailTemplate returnedTemplate = EmailTemplateController.getEmailTemplate(testTemplate.Id);
        Test.stopTest();

        System.assertEquals(testTemplate.Id, returnedTemplate.Id);
        System.assertEquals(testTemplate.Subject, returnedTemplate.Subject);
        System.assertEquals(testTemplate.HtmlValue, returnedTemplate.HtmlValue);
    }
}