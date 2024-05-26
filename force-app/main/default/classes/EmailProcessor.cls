global class EmailProcessor implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try {
            String invoiceNumber = extractInvoiceNumber(email.subject);
            Opportunity opp = findOpportunityByInvoiceNumber(invoiceNumber);    

                processOpportunityEmail(email, opp);
            
            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.message = ' Error processing email: ' + e.getMessage();
        }
        return result;
    }

    public void processOpportunityEmail(Messaging.InboundEmail email, Opportunity opp) {
        String emailBody = email.plainTextBody.toLowerCase();
        updateOpportunityStatus(emailBody, opp);
        updateOpportunity(opp);
    }

    public String extractInvoiceNumber(String subject) {
        return subject.substring(4);
    }

    public Opportunity findOpportunityByInvoiceNumber(String invoiceNumber) {
        return [SELECT Id, StageName FROM Opportunity WHERE Invoice_Number__c = :invoiceNumber LIMIT 1];
    }

    public void updateOpportunityStatus(String emailBody, Opportunity opp) {
        if (emailBody.contains('approved')) {
            advanceOpportunityStage(opp);
        } else if (emailBody.contains('rejected')) {
            setOpportunityStageToClosedLost(opp);
        }
    }

    public void advanceOpportunityStage(Opportunity opp) {
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        Integer currentStageIndex = getCurrentStageIndex(opp, picklistValues);
        if (currentStageIndex != -1 && currentStageIndex < picklistValues.size() - 1) {
            opp.StageName = picklistValues[currentStageIndex + 1].getValue();
        } else {
            opp.StageName = 'Closed Won';
        }
    }

    public Integer getCurrentStageIndex(Opportunity opp, List<Schema.PicklistEntry> picklistValues) {
        Integer currentStageIndex = -1;
        for (Integer i = 0; i < picklistValues.size(); i++) {
            if (picklistValues[i].getValue() == opp.StageName) {
                currentStageIndex = i;
                break;
            }
        }
        return currentStageIndex;
    }

    public void setOpportunityStageToClosedLost(Opportunity opp) {
        opp.StageName = 'Closed Lost';
    }

public void updateOpportunity(Opportunity opp) {

        if(opp.Id != null) {
            update opp;
        }
    }
}