public class LinkRedirectController {

    String country = 'Germany'; // default for sandbox , cause sandbox url is different

    public PageReference redirectURL() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        String country_code;
        if (Test.isRunningTest()) {
            country_code = ApexPages.currentPage().getParameters().get('test_country');
        } else {
            country_code = ApexPages.currentPage().getHeaders().get('Host').substringAfterLast('.');
        }

//        country_code = 'pl';
        switch on country_code {
            when 'de' { country = 'Germany'; }
            when 'pl' { country = 'Poland'; }
            when 'ch' { country = 'Switzerland'; }
            when 'sk' { country = 'Slovakia'; }
            when 'hu' { country = 'Hungary'; }
        }
        String shortid;
        String codeToCheck;
        for (String pName : parameters.keySet()) {
            if (pName.startsWith('s') || pName.startsWith('q') ||
                    pName.startsWith('l') || pName.startsWith('u')) {

                if (pName.startsWith('sk')) {
                    shortid = pName.substring(0, 2);
                } else {
                    shortid = pName.substring(0, 1);
                }
                codeToCheck = pName;
                break;
            }
        }

        return new PageReference(generateUrl(shortid, codeToCheck));
    }

    @TestVisible
    private String generateUrl(String shortid, String codeToCheck) {
        E2E_Short_Url__c e2eShortUrlDetail;
        if (shortid != null) {
            String clientSource;
            if (shortid == 's') {
                clientSource = ETEDataGenerator.sourceSMS;
            } else if (shortid == 'q') {
                clientSource = ETEDataGenerator.sourceQR;
            } else if (shortid == 'u') {
                clientSource = ETEDataGenerator.sourceURL;
            } else if (shortid == 'l') {
                clientSource = ETEDataGenerator.sourceTablet;
            }
            String dataObjectRecordTypeName = country.replace('-', '_');
            String stageName = 'Prospecting';
            String opportunityRecordTypeName = 'Euroshell';
            String countryCode = ETEGlobalUtils.returnTwoLettersCountry(country);
            String finalUrl;

            if (shortid == 's') {  // SMS source
                // twilio service
                String shortLink = codeToCheck.substringAfter('s');
                List<Opportunity> opportunityToCheck = [
                        SELECT E2E_Encoded_Url__c, Account.BillingCountry, Sec_Channel__c, RecordType.Name, (
                                SELECT AccountTo.OBN__c, AccountTo.BillingStreet, AccountTo.BillingCity, AccountTo.BillingCountry
                                FROM Partners
                                WHERE AccountTo.OBN__c != NULL AND AccountTo.BillingStreet != null AND AccountTo.BillingCity != NULL AND AccountTo.BillingCountry != NULL
                                LIMIT 1
                        )
                        FROM Opportunity
                        WHERE E2E_Encoded_Url__c != NULL AND
                        E2E_Short_Link__c = :shortLink
                        LIMIT 1
                ];
                if ( ! opportunityToCheck.isEmpty() ) {
                    e2eShortUrlDetail = E2E_Short_Url__c.getInstance(opportunityToCheck.get(0).Account.BillingCountry);
                    if (opportunityToCheck.get(0).Account.BillingCountry == country) {
                        finalUrl = e2eShortUrlDetail.E2E_Form_Url__c + '?source=' + opportunityToCheck.get(0).E2E_Encoded_Url__c + '&followup=sms';
                        if (country == 'Poland' && opportunityToCheck.get(0).RecordType.Name == 'Lotos') {
                            finalUrl = finalUrl.replace('etepl', 'etelotospl');
                        }

                        return finalUrl;
                    }
                    if (opportunityToCheck.get(0).Partners.isEmpty() && e2eShortUrlDetail.E2E_JITB_Form_Url__c != null) {
                        return e2eShortUrlDetail.E2E_JITB_Form_Url__c + '?source=' + opportunityToCheck.get(0).E2E_Encoded_Url__c;
                    }
                } else {
                    // adoption process from Emarsys service
                    List<Lead> leadToCheck = [
                            SELECT Owner.Name, IsConverted, ConvertedOpportunity.E2E_Encoded_URL__c, Country, Anzahl_der_Fahrzeuge__c, Channel__c, Salutation, RecordType.Name, Status,
                                   LeadSource, CCS_number_of_cards__c, Email, CountryCode, Number_of_Cards_facebook__c, Sec_Channel__c, E2E_Assistant__c, E2E_Manual_Adoption_Date__c, Partner_OBN__c,
                                   Utm_campaign__c, Agree_to_receive_comm_info_by_email__c, FirstName, LastName, Phone, Company, Owner.Type
                            FROM Lead
                            WHERE E2E_Short_Link__c = :shortLink
                            LIMIT 1
                    ];
                    if (! leadToCheck.isEmpty()) {
                        e2eShortUrlDetail = E2E_Short_Url__c.getInstance(leadToCheck.get(0).Country);
                        String implKey = leadToCheck.get(0).Country;
                        if (leadToCheck.get(0).Country == 'Poland' && leadToCheck.get(0).RecordType.Name == 'Lotos') {
                            implKey = implKey + ' ' + leadToCheck.get(0).RecordType.Name;
                        }
                        String urlPath = ETEGlobalUtils.returnUrlPath(implKey).getUrl();

                        E2E_Data_Object__c dataObject;
                        List<E2E_Data_Object__c> dataObjectToCheck = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c = :leadToCheck.get(0).Id];

                        if (dataObjectToCheck.isEmpty()) {
                            ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
                            ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(implKey);
                            Map<String, Object> untypedSettings = e2eDatabase.getSettings(implKey, countryCode);
                            List<String> availableStepsList = e2eStep.getAvailableSteps(untypedSettings, null);
                            ETEBusinessObjectsInterface businessObjectsHandler = ETEGlobalUtils.getETEBusinessObjectsHandler(implKey);
                            String shortCompanyName = leadToCheck.get(0).Company;
                            if (shortCompanyName.length() > 25) {
                                shortCompanyName = shortCompanyName.substring(0, 25);
                            }
                            dataObject = businessObjectsHandler.initDataObject(availableStepsList, countryCode, implKey);
                            dataObject.Salutation__c = 'Mr.';
                            dataObject.Name = leadToCheck.get(0).Company;
                            dataObject.Lead__c = leadToCheck.get(0).Id;
                            dataObject.Company_Short_Name__c = shortCompanyName;

                            insert dataObject;

                            E2E_Data_Contact__c e2EDataContact = ETEDataGenerator.insertE2EDataContact(dataObject, null, leadToCheck.get(0), null);

                            // insert data log to run checkBusinessObjects after redirect
                            List<RecordType> e2eDataLogRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Log__c' AND DeveloperName = 'Job_Status' LIMIT 1];
                            E2E_Data_Log__c dataLog = new E2E_Data_Log__c(
                                    E2E_Data_Object__c = dataObject.Id,
                                    Job_Status__c = 'Completed',
                                    Name = 'checkBusinessObjects'
                            );
                            if (!e2eDataLogRecordTypeList.isEmpty()) {
                                dataLog.RecordTypeId = e2eDataLogRecordTypeList.get(0).Id;
                            }
                            insert dataLog;

                            if (leadToCheck.get(0).Salutation == null || leadToCheck.get(0).Salutation == '' || leadToCheck.get(0).Owner.Type != 'User') {
                                E2E_Form_General_Settings__c e2eGeneralSettings = E2E_Form_General_Settings__c.getInstance(leadToCheck.get(0).Country);
                                leadToCheck.get(0).OwnerId = e2eGeneralSettings.Integration_Admin_Id__c;
                                leadToCheck.get(0).Salutation = 'Mr.';

                                update leadToCheck;
                            }

                            List<String> jobsNeededToRun = new List<String>{
                                    'checkBusinessObjects'
                            };
                            ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(jobsNeededToRun, dataObject.Id, countryCode, implKey);
                            jobChainHandler.runNext();
                        } else {
                            dataObject = dataObjectToCheck.get(0);
                        }
                        String source = ETEGlobalUtils.doEncryptParams(dataObject.Id, countryCode);
                        return finalUrl = urlPath + '?source=' + source;
                    }
                }
            }

            else if (shortid == 'q' || shortid == 'u' || shortid == 'l') {  // QR source // URL source // tablet source
                String obn;
                if (country == 'Poland' && shortid == 'q') {
                    obn = codeToCheck.substringAfter(shortid).substringBefore('lotos');
                } else {
                    obn = codeToCheck.substringAfter(shortid);
                }

                if (country == 'Switzerland') {
                    List<Account> accountToCheck = [
                            SELECT BillingCountry
                            FROM Account
                            WHERE OBN__c = :obn AND (BillingCountry = 'Switzerland-DE' OR BillingCountry = 'Switzerland-FR')
                            LIMIT 1];
                    if ( ! accountToCheck.isEmpty() ) {
                        country = accountToCheck.get(0).BillingCountry;
                    } else {
                        country = 'Switzerland-DE';
                    }
                    dataObjectRecordTypeName = country.replace('-', '_');
                    countryCode = ETEGlobalUtils.returnTwoLettersCountry(country);
                }
                e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
                String source;
                List<Account> retailerAccount;
                String formName = ETEDataGenerator.getETEFormName(null, obn);
                retailerAccount = ETEDataGenerator.getRetailerAccount(country, obn);
                if (country == 'Poland' && retailerAccount.get(0).Partnertyp__c == 'Lotos partner') {
                    dataObjectRecordTypeName = country + '_Lotos';
                    stageName = 'Qualify';
                    opportunityRecordTypeName = 'Lotos';
                }
                String typeOfStation = 'JITB';
                if ( ! retailerAccount.isEmpty() && retailerAccount.get(0).BillingCountry == 'Slovakia' && retailerAccount.get(0).Type == 'Partner') {
                    typeOfStation = retailerAccount.get(0).Type;
                }
                Account account = ETEDataGenerator.insertAccount('Endkunde', country, formName);
                E2E_Data_Object__c e2EDataObject = ETEDataGenerator.insertE2EDataObject('products_and_services', stageName, dataObjectRecordTypeName, 'jitb', shortid, obn, countryCode, countryCode, null, null, null);
                E2E_Data_Log__c dataLog = ETEDataGenerator.insertE2EDataLog('Job_Status', e2EDataObject.Id, 'Completed', 'checkBusinessObjects');
                Opportunity opportunity = ETEDataGenerator.insertOpportunity(formName, retailerAccount, account.Id, opportunityRecordTypeName, stageName, country, null, clientSource, obn, e2EDataObject.Id, typeOfStation);
                Contact contact = ETEDataGenerator.insertContact(formName, 'Contact layout', account.Id, null, country);
                E2E_Data_Contact__c e2EDataContact = ETEDataGenerator.insertE2EDataContact(e2EDataObject, null, null, contact);
                ETEDataGenerator.insertOpportunityContactRole(opportunity.Id, contact.Id);
                ETEDataGenerator.setPartnerRelationship(retailerAccount, opportunity.Id);
                source = opportunity.E2E_Encoded_URL__c;

                if (source == null) {
                    finalUrl = e2eShortUrlDetail.E2E_Form_Url__c + '?utm_source=jitb&utm_medium=' + shortid + '&utm_content=' + obn;
                } else {
                    finalUrl = e2eShortUrlDetail.E2E_Form_Url__c + '?source=' + source;
                }
                if (country == 'Poland' && (codeToCheck.contains('lotos') || retailerAccount.get(0).Partnertyp__c == 'Lotos partner')) {
                    finalUrl = finalUrl.replace('etepl', 'etelotospl');
                }

                return finalUrl;
            }
        }

        e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
        return e2eShortUrlDetail.E2E_Form_Url__c;
    }
}