@RestResource(urlMapping = '/twiliohook/*')
global class TwilioSMSHookController {
    @HttpPost
    global static String getPost() {
        RestRequest req = RestContext.request;
        System.debug(req);
        String sms_from = req.params.get('from').replace('%2B', '+');
        String sms_body = req.params.get('body');
        String country = req.params.get('country');
        System.debug(Datetime.now().format() + ': got sms from ' + sms_from + ':   ' + sms_body);
        try {
            sms_body = sms_body.toUpperCase();
            String obn_number = sms_body.replaceAll('[^a-zA-Z0-9\\s+]', '').deleteWhitespace();
            String shortLink = prepareCustomerToETEProcess(obn_number, country, sms_from);
            GeneratedLink generatedLink = new GeneratedLink(shortLink, country);
            return JSON.serialize(generatedLink);
        } catch (Exception e) {
            System.debug('error creating entities in response to sms!\n' + e.getMessage() + ': ' + e.getStackTraceString());
            return JSON.serialize(new GeneratedLink(null, country));
        }
    }

    private static Set<String> stationNamesSet = new Set<String> {
            'SHELL',
            'SHEL',
            'SHALL',
            'LOTOS',
            'LOTUS'
    };


    private static String prepareCustomerToETEProcess(String obn_number, String country, String clientNumber) {
        String source;
        String obn = obn_number;
        for (String stationName : stationNamesSet) {
            if (obn.contains(stationName)) {
                obn = obn.substringAfter(stationName);
            }
        }
        List<Account> retailerAccount = ETEDataGenerator.getRetailerAccount(country, obn);
        String typeOfStation = 'JITB';
        if ( ! retailerAccount.isEmpty() && retailerAccount.get(0).Type == 'Partner') {
            typeOfStation = retailerAccount.get(0).Type;
        }
        String businessName;
        if (obn_number.startsWith('SHELL')) {
            businessName = 'SHELL';
        } else if (obn_number.startsWith('LOTOS')) {
            businessName = 'LOTOS';
        }
        if (businessName == null && ! retailerAccount.isEmpty()) {
            String partnerType = retailerAccount.get(0).Partnertyp__c;
            if (partnerType == 'Lotos partner') {
                businessName = 'LOTOS';
            } else {
                businessName = 'SHELL';
            }
        }
        String dataObjectRecordTypeName = country.replace('-', '_');
        String stageName = 'Prospecting';
        String opportunityRecordTypeName = 'Euroshell';
        if (businessName == 'LOTOS') {
            dataObjectRecordTypeName = country + '_Lotos';
            stageName = 'Qualify';
            opportunityRecordTypeName = 'Lotos';
        }

        String countryCode = ETEGlobalUtils.returnTwoLettersCountry(country);

        if (businessName != null) {
            String formName = ETEDataGenerator.getETEFormName(clientNumber, obn);
            Account account = ETEDataGenerator.insertAccount('Endkunde', country, formName);
            E2E_Data_Object__c e2EDataObject = ETEDataGenerator.insertE2EDataObject('products_and_services', stageName, dataObjectRecordTypeName, 'jitb', 'sms', obn, countryCode, countryCode, null, null, clientNumber);
            E2E_Data_Log__c dataLog = ETEDataGenerator.insertE2EDataLog('Job_Status', e2EDataObject.Id, 'Completed', 'checkBusinessObjects');
            Opportunity opportunity = ETEDataGenerator.insertOpportunity(formName, retailerAccount, account.Id, opportunityRecordTypeName, stageName, country, clientNumber, ETEDataGenerator.sourceSMS, obn, e2EDataObject.Id, typeOfStation);
            Contact contact = ETEDataGenerator.insertContact(formName, 'Contact layout', account.Id, clientNumber, country);
            E2E_Data_Contact__c e2EDataContact = ETEDataGenerator.insertE2EDataContact(e2EDataObject, clientNumber, null, contact);
            ETEDataGenerator.insertOpportunityContactRole(opportunity.Id, contact.Id);
            ETEDataGenerator.setPartnerRelationship(retailerAccount, opportunity.Id);
            source = opportunity.E2E_Short_Link__c;
        }
        return source;
    }


    public class GeneratedLink {
        public String link;

        public GeneratedLink(String link, String country) {
            E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
            if (link != null) {
                this.link = e2eShortUrlDetail.Short_Url__c + '?s' + link;
            } else {
                this.link = e2eShortUrlDetail.E2E_Form_Url__c;
            }
        }
    }
}