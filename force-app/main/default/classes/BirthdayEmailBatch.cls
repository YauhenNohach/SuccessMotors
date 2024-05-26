global class BirthdayEmailBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, Email FROM Contact WHERE Birthdate = TODAY';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Contact c : scope) {
            if (c.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {c.Email});
                email.setSubject('Happy Birthday!');
                email.setPlainTextBody('Dear ' + c.Name + ',\n\nCongratulations with your Birthday. We have a gift for your order. Enjoy!\n\nRegards');
                emails.add(email);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    global void finish(Database.BatchableContext bc) {
        
    }
}