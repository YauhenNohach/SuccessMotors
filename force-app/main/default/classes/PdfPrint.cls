public with sharing class PdfPrint {
    Id opportunityId;
    public PdfPrint(ApexPages.StandardController ctrl) {
        opportunityId = ctrl.getId();
    }

    public List<Opportunity> getOpps(){
        return [SELECT Id, Name, StageName, CloseDate
        FROM Opportunity
        WHERE id = :opportunityId
        ORDER BY Name];
    }
}