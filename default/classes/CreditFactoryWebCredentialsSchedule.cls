global class CreditFactoryWebCredentialsSchedule implements Schedulable {


    /*******************************************************************************
	*  Summary         : Change password
	*  CreatedDate     : 20/11/2020 by Ivan Kulinkovich
	*  Parameters      : sc - variable to track schedulable job
	*  Returns         : void
	******************************************************************************/
    global void execute(SchedulableContext sc) {
        try {
            changePasswordBigTest();
            changePasswordBigProd();
        }
        catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
	*  Summary         : Send request to change password in test service
	*  CreatedDate     : 20/11/2020 by Ivan Kulinkovich
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    private void changePasswordBigTest() {
        BIG__c bigSettingsTest = BIG__c.getInstance('Test Password');
        String userName = bigSettingsTest.User_Name__c;
        String password = bigSettingsTest.Password__c;
        String endpoint = bigSettingsTest.Endpoint__c;
        String temporaryPassword = password.substring(0, 9) + 'Z';
        HttpResponse httpResponse = sendTemporaryChangePasswordRequestBig(temporaryPassword, userName, password, endpoint);
        if (httpResponse.getStatusCode() == 200) {
            httpResponse = sendChangePasswordRequestBig(temporaryPassword, userName, password, endpoint);
            if (httpResponse.getStatusCode() != 200) {
                throw new CreditFactoryException('BIG password in test environment has been changed to new one');
            }
        }
        else {
            throw new CreditFactoryException('BIG password change in test environment failed');
        }
    }


    /*******************************************************************************
	*  Summary         : Send request to change password in production service
	*  CreatedDate     : 20/11/2020 by Ivan Kulinkovich
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    private void changePasswordBigProd() {
        BIG__c bigSettingsProd = BIG__c.getInstance('Production Password');
        String userName = bigSettingsProd.User_Name__c;
        String password = bigSettingsProd.Password__c;
        String endpoint = bigSettingsProd.Endpoint__c;
        String temporaryPassword = password.substring(0, 9) + '4';
        HttpResponse httpResponse = sendTemporaryChangePasswordRequestBig(temporaryPassword, userName, password, endpoint);
        if (httpResponse.getStatusCode() == 200) {
            httpResponse = sendChangePasswordRequestBig(temporaryPassword, userName, password, endpoint);
            if (httpResponse.getStatusCode() != 200) {
                throw new CreditFactoryException('BIG password in production environment has been changed to new one');
            }
        }
        else {
            throw new CreditFactoryException('BIG password change in production environment failed');
        }
    }

    /*******************************************************************************
	*  Summary         : Send the first request to change password
	*  CreatedDate     : 20/11/2020 by Ivan Kulinkovich
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    private HttpResponse sendTemporaryChangePasswordRequestBig(String temporaryPassword, String userName, String password, String endpoint) {
        String body = generateChangePasswordXML(password, userName, temporaryPassword);
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', 'http://bik.pl/binari/ws/zmiana-hasla');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response;
    }


    /*******************************************************************************
	*  Summary         : Send the second request to change password
	*  CreatedDate     : 20/11/2020 by Ivan Kulinkovich
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    private HttpResponse sendChangePasswordRequestBig(String temporaryPassword, String userName, String password, String endpoint) {
        String body = generateChangePasswordXML(temporaryPassword, userName, password);
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', 'http://bik.pl/binari/ws/zmiana-hasla');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response;
    }


    /*******************************************************************************
	*  Summary         : Generate request body to change password
	*  CreatedDate     : 20/11/2020 by Ivan Kulinkovich
	*  Parameters      : -
	*  Returns         : String body
	******************************************************************************/
    private String generateChangePasswordXML(String oldPassword, String userName, String newPassword) {
        String xmlBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:big="http://bik.pl/cc/big">' +
                            '<soapenv:Header/>' +
                                '<soapenv:Body>' +
                                    '<big:zmiana-hasla id-operatora="' + userName + '" haslo-stare="' + oldPassword + '" haslo-nowe="' + newPassword + '"/>' +
                                '</soapenv:Body>' +
                         '</soapenv:Envelope>';
        return xmlBody;
    }
}