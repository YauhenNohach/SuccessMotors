public with sharing class OpportunityPDFController {
    Id opportunityId;
    public String invoiceNumber { get; set; }
    public Decimal opportunityAmount { get; set; }

    public OpportunityPDFController(ApexPages.StandardController ctrl) {
        opportunityId = ctrl.getId();
        Opportunity opp = [SELECT Invoice_Number__c, Amount FROM Opportunity WHERE Id = :opportunityId];
        invoiceNumber = opp.Invoice_Number__c;
        opportunityAmount = opp.Amount;
    }

    public PageReference save() {
    PageReference pdfPage = Page.Opportunity_PDF;
    pdfPage.getParameters().put('id', opportunityId);
    pdfPage.setRedirect(true);

    try {
        Blob pdfBlob = pdfPage.getContentAsPDF();
        
        ContentVersion[] existingCVs = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = :invoiceNumber ORDER BY VersionNumber DESC LIMIT 1];

        if (existingCVs.size() > 0) {
            updateExistingPDF(pdfBlob, existingCVs);
        } else {
            insertNewPDF(pdfBlob);
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PDF was saved successfully!'));

    } catch (Exception e) {
        ApexPages.addMessages(e);
    }
    return null;
}

public void updateExistingPDF(Blob pdfBlob, ContentVersion[] existingCVs) {
    ContentVersion cv = new ContentVersion(
        Title = invoiceNumber,
        PathOnClient = invoiceNumber + '.pdf',
        VersionData = pdfBlob,
        ContentDocumentId = existingCVs[0].ContentDocumentId
    );
    insert cv;

    ContentVersion promotedCV = new ContentVersion(
        Id = cv.Id,
        IsMajorVersion = true
    );
    update promotedCV;
}

public void insertNewPDF(Blob pdfBlob) {
    ContentVersion cv = new ContentVersion(
        Title = invoiceNumber,
        PathOnClient = invoiceNumber + '.pdf',
        VersionData = pdfBlob,
        FirstPublishLocationId = opportunityId
    );
    insert cv;
}

    public List<OpportunityContactRole> getOpportunityContactRoles() {
        return [SELECT Id, Contact.Name, Contact.Account.Name, Contact.Phone, Contact.Email, IsPrimary 
                FROM OpportunityContactRole 
                WHERE OpportunityId = :opportunityId];
    }

    public List<OpportunityLineItem> getOpportunityLineItems() {
        return [SELECT Id, Product2.Name, Quantity, UnitPrice, TotalPrice 
                FROM OpportunityLineItem 
                WHERE OpportunityId = :opportunityId];
    }
}