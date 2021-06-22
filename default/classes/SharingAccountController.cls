public class SharingAccountController {
    public Account account{get; private set;}
    public List<HistoryUtils.ObjectHistoryLine> accountHistory{get; set;}
    public List<Opportunity> opportunityList{get; private set;}

    public SharingAccountController(ApexPages.StandardController stdController) {
        try {
            Id accountId = stdController.getId();
            // Get describe for Account object
            DescribeSObjectResult describeResult = accountId.getSObjectType().getDescribe();
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            String query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ', (Select Subject, Who.Name, Ownerid, Istask, Priority, ActivityDate, Status from OpenActivities Order by CreatedDate DESC LIMIT 500) ' +
                    ', (Select Subject, Who.Name, Ownerid, Istask, Priority, ActivityDate, Status, Description from ActivityHistories Order by CreatedDate DESC LIMIT 500)' +
                    ', (SELECT Id, Name, Email, Phone, Salutation, MobilePhone, Title from Contacts LIMIT 500)' +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' id = :accountId' +
                    ' LIMIT 1 '
            ;
            List<SObject> records = Database.query( query );
            account = (Account)records.get(0);

            opportunityList = ([
                    SELECT Name, CreatedDate, StageName, Contract_Number__c, CloseDate, ALL_Cards__c, Number_of_Vehicles__c
                    FROM Opportunity
                    WHERE AccountId =: accountId
            ]);

            // Get Account history
            HistoryUtils historyUtils = new HistoryUtils();
            accountHistory = historyUtils.getObjectHistory(accountId);

        }catch (Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.FATAL, e.getMessage()));
        }
    }
}