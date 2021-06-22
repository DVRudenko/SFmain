@IsTest
public class CreditFactoryWebCredentialsScheduleTest {


    /*******************************************************************************
	*  Summary         : test change of password
	*  CreatedDate     : 20/11/2020 by Ivan Kulinkovich
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    @IsTest
    static void testChangePassword() {
        BIG__c bigSettingsTest = new BIG__c();
        bigSettingsTest.Name = 'Test Password';
        bigSettingsTest.User_Name__c = 'USER111111';
        bigSettingsTest.Password__c = '1234567890';
        bigSettingsTest.Endpoint__c = 'https://wasstt.infomonitor.pl:443/39D97477-0709-455f-A7C8-6498B600AC5A/ws/BIG';
        insert bigSettingsTest;

        BIG__c bigSettingsProd = new BIG__c();
        bigSettingsProd.Name = 'Production Password';
        bigSettingsProd.User_Name__c = 'USER222222';
        bigSettingsProd.Password__c = '0987654321';
        bigSettingsProd.Endpoint__c = 'https://was.infomonitor.pl:443/c2aab3d2-d67a-4a28-8c7a-770cf1d1fb43/ws/BIG';
        insert bigSettingsProd;

        Test.startTest();
            SingleRequestMock bigMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><potw-zmiany-hasla haslo-nowe="*********" id-operatora="USER188247" xmlns="http://bik.pl/cc/big" xmlns:ns2="http://bik.pl/cc/big/internal"/></soapenv:Body></soapenv:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, bigMock);
            CreditFactoryWebCredentialsSchedule bigSchedule = new CreditFactoryWebCredentialsSchedule();
            SchedulableContext sc;
            bigSchedule.execute(sc);
        Test.stopTest();

        System.assertEquals(bigSettingsTest.Password__c, '1234567890');
        System.assertEquals(bigSettingsProd.Password__c, '0987654321');
    }
}