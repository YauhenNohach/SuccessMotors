public class TestDataFactory {
    
   public static Account createAccount() {
        return new Account(Name = 'Test Account');
    }

    public static Opportunity createOpportunity(Id accountId) {
        return new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = accountId
        );
    }


   public static Contact createContact() {
    Account acc = createAccount();
    insert acc;

    return new Contact(
        FirstName = 'John',
        LastName = 'Doe',
        Email = 'john.doe@example.com',
        AccountId = acc.Id
    );
}

public static OpportunityContactRole createContactRole(Id opportunityId) {
    Contact contact = createContact();
    insert contact;

    OpportunityContactRole role = new OpportunityContactRole(
        OpportunityId = opportunityId,
        ContactId = contact.Id,
        Role = 'Decision Maker'
    );

    return role;
}
    
    public static Opportunity createOpportunity() {
    return new Opportunity(
        Name = 'Test Opportunity',
        StageName = 'Closed Won',
        CloseDate = Date.today()
    );
  }
    
 public static Id getStandardPricebookId() {
        return [SELECT Id FROM Pricebook2 WHERE Name = 'StandardPricebook' LIMIT 1].Id;
    }
}