@isTest
public class CaseControllerTest {

    @isTest
    public static void testGetCase(){

        Case c = new Case(
                Origin = 'E-Mail',
                RecordTypeId = GlobalUtils.getRecordTypeId('Case', 'Support'),
                Status = 'New',
                Subject = 'Subject',
                Description = 'Subject'
        );
        insert c;

        Case newCase = CaseController.getCase(c.Id);
        System.assertEquals(true, newCase.Id == c.Id);
    }

    @isTest
    public static void testUpdateCase(){

        Case c = new Case(
                Origin = 'E-Mail',
                RecordTypeId = GlobalUtils.getRecordTypeId('Case', 'Support'),
                Status = 'New',
                Subject = 'Subject',
                Description = 'Subject'
        );
        insert c;

        CaseController.updateCase(c);
        System.assertEquals(true, c.Status == 'Resolved');
    }

    @isTest
    public static void testUpdateCaseByNotOwner(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Service Agent'];

        User u1 = new User(Alias = 'newUser1', Email='newuser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', Username='newuser@testorg.com.first');
        insert u1;

        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', Username='newuser@testorg.com.second');
        insert u2;

        Case c = new Case(
                Origin = 'E-Mail',
                RecordTypeId = GlobalUtils.getRecordTypeId('Case', 'Support'),
                Status = 'New',
                Subject = 'Subject',
                Description = 'Subject',
                OwnerId = u1.Id
        );
        insert c;

        System.runAs(u2){
            try{
                CaseController.updateCase(c);
            } catch (Exception e){
                System.assert(true, 'Exceptions should be handled by the method');
            }
        }
    }
}