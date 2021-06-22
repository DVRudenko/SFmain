/**
 * Created by pgolyakov on 2019-07-25.
 */

@isTest
private class PD_GetToken_Test {
    @isTest static void testGetToken() {
        PD_Setting__c sett = new PD_Setting__c(
                URL__c = 'https://df-maxy-aflex.enterprise.dreamfactory.com/api/v2',
                Token__c = 'asdsdfsdfeferwertwer',
                Name = 'testsetting',
                AdminEmails__c = 'test@test.ru'
        );
        insert sett;

        PD_GetToken.refreshToken();
        PD_GetToken.sentErrorEmail('test@test.ry', 'body');
        PD_GetToken.updateTocken('{"status": "ok","error": null,"result": {"job_id": 17}}', sett);
    }
}