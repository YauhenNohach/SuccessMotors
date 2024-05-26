public with sharing class EmailTemplateController {
    
    @AuraEnabled(cacheable=true)
    public static EmailTemplate getEmailTemplate(String templateId) {
        return [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Id = :templateId];
    }
}
