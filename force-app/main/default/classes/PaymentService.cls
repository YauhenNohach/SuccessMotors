@RestResource(urlMapping='/payments/*')
global with sharing class PaymentService {

    @HttpPost
    global static void createPayments() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestBody = req.requestBody.toString();
        System.debug('Received request body: ' + requestBody);

        List<PaymentWrapper> payments = (List<PaymentWrapper>) JSON.deserialize(requestBody, List<PaymentWrapper>.class);
        System.debug('Deserialized payments: ' + JSON.serialize(payments));

        List<Payment__c> paymentRecords = new List<Payment__c>();

        for (PaymentWrapper payment : payments) {
            Payment__c existingPayment = getExistingPayment(payment.Opportunity);
            
            if (existingPayment != null) {
                existingPayment.Amount__c += payment.Amount;
                paymentRecords.add(existingPayment);
            } else {
                Payment__c newPayment = new Payment__c();
                newPayment.Opportunity__c = payment.Opportunity;
                newPayment.Amount__c = payment.Amount;
                newPayment.FirstName__c = payment.FirstName;
                newPayment.LastName__c = payment.LastName;
                paymentRecords.add(newPayment);
            }
        }

        if (!paymentRecords.isEmpty()) {
            upsert paymentRecords;
            res.statusCode = 201;
            res.responseBody = Blob.valueOf('Payments created successfully');
            System.debug('Payments successfully inserted: ' + JSON.serialize(paymentRecords));
        } else {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('No valid payments to create');
        }
    }

    global class PaymentWrapper {
        public String Opportunity;
        public Decimal Amount;
        public String FirstName;
        public String LastName;
    }

    private static Payment__c getExistingPayment(String opportunityId) {
        List<Payment__c> existingPayments = [SELECT Id, Amount__c FROM Payment__c WHERE Opportunity__c = :opportunityId LIMIT 1];
        if (!existingPayments.isEmpty()) {
            return existingPayments[0];
        } else {
            return null;
        }
    }
}
