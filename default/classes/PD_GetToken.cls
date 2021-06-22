/**
 * Created by pgolyakov on 2019-05-07.
 */
global class PD_GetToken implements Schedulable, Database.AllowsCallouts {

    public class Message {
        String status;
        PD_GetToken.MessageError error;
        PD_GetToken.MessageResult result;
    }

    public class MessageResult {
        String token;
        Datetime valid_from;
        Datetime valid_to;
    }
    public class MessageError {
        String code;
        String message;
    }

    public void execute(SchedulableContext SC) {
        PD_GetToken.refreshToken();
    }

    @Future(callout=true)
    public static void refreshToken() {
        PD_Setting__c mc = PD_Setting__c.getOrgDefaults();
        try {

            HttpRequest req = new HttpRequest();
            req.setEndpoint(mc.URL__c + '/auth');
            req.setMethod('POST');
            req.setTimeout(60000);
            req.setBody('{"login": "' + mc.Login__c + '", "password": "' + mc.Password__c + '"}');

            Httpresponse httpreq = new Http().send(req);
            String jsonInput = httpreq.getBody();

            updateTocken(jsonInput, mc);

        } catch(Exception e){
            mc.Token__c = '';
            update mc;
            sentErrorEmail(mc.AdminEmails__c, 'Неверные настройки в PD_Setting ' + e.getMessage());
            System.debug('Неверные настройки в PD_Setting ' + e.getMessage());
        }
    }

    public static void updateTocken(String jsonInput, PD_Setting__c mc) {
        PD_GetToken.Message m = (PD_GetToken.Message)JSON.deserialize(jsonInput, PD_GetToken.Message.class);
        if (m.status == 'ok') {
            mc.Token__c = m.result.token;
        } else {
            sentErrorEmail(mc.AdminEmails__c, String.valueOf(m));
            system.debug(m.error);
            mc.Token__c = '';
        }

        update mc;

    }

    public static void sentErrorEmail(String addresses, String body) {
        if (addresses == null) return;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = addresses.split(',');
        mail.setToAddresses(toAddresses);
        mail.setSubject('PD refresh token error');
        mail.setPlainTextBody(body);
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}