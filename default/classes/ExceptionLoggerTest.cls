@isTest
private class ExceptionLoggerTest {
 
 
    /*******************************************************************************
    *  Name            : testSendException()
    *  Summary         : test sending Emails   
    *  CreatedDate     : 18/03/2017
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSendException() {
        Profile profile = [
                SELECT Id
                FROM Profile
                LIMIT 1];
        User user = new User(
            ProfileId = profile.Id,
            Username = System.now().millisecond() + 'test3@test.com',
            Alias = 'kam',
            Email='test@test.com',
            EmailEncodingKey='UTF-8',
            Lastname='test',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago');
        insert user;
 
        Logger_Recipient__c recipient = new  Logger_Recipient__c(Name = user.Id, Active__c = true);
        insert recipient;
        ExceptionLogger.sendException('test', 'test');
        System.assertEquals(Limits.getEmailInvocations(), 1);
    }
}