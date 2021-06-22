@isTest
public with sharing class E2EFormRuServiceImplHelperTest {
    
    @IsTest
    public static void exculeContactsFromListTest() {
        List<Contact> sourceList = null; 
        List<Contact> exclusionList = null;

        // null behavior

        //SF-1313
        List<Contact> resultList = E2EFormRuServiceImplHelper.exculeObjectsFromList(sourceList, exclusionList);

        System.assertEquals(null, resultList);

        sourceList = new List<Contact>();
        exclusionList = new List<Contact>();
        //SF-1313
        resultList = E2EFormRuServiceImplHelper.exculeObjectsFromList(sourceList, exclusionList);

        System.assertEquals(new List<Contact>(), resultList);

        String RecordTypeCon = [select id from recordtype where name = 'Russian' and SobjectType = 'Contact'].id;
        List<Contact> contacts = new List<Contact>();
        Contact cont = new Contact(
                LastName = 'testcontact12345',
                Phone = '+71234567891',
                Email = 'Email12345678910@gggmail.ru',
                RecordTypeId = RecordTypeCon);
        contacts.add(cont);
        Contact cont2 = cont.clone();
        contacts.add(cont2);
        insert contacts;

        // exclusion check

        exclusionList.add(cont);
        //SF-1313
        resultList = E2EFormRuServiceImplHelper.exculeObjectsFromList(sourceList, exclusionList);

        System.assertEquals(new List<Contact>(), resultList);

        sourceList.add(cont);
        //SF-1313
        resultList = E2EFormRuServiceImplHelper.exculeObjectsFromList(sourceList, exclusionList);

        System.assertEquals(new List<Contact>(), resultList);

        sourceList.addAll(contacts);
        //SF-1313
        resultList = E2EFormRuServiceImplHelper.exculeObjectsFromList(sourceList, exclusionList);

        System.assertEquals(1, resultList.size());
        System.assertEquals(cont2.Id, resultList.get(0).Id);
    }

    @IsTest
    private static void matchAdditionalEmailsTest() {
        //for Contact
        String email = 'test@test.ru';
        String phone =  '1112223344';
        List<Contact> contacts = new List<Contact> {
                new Contact(
                        Email = 'test@test.ru',
                        Additional_Emails__c = 'test423@tsd.ds:fsdf@sdfgg.gf'
                ),
                new Contact(
                        Email = 'dfg@fd.fd',
                        Additional_Emails__c = 'test423@tsd.ds:test@test.ru'
                ),
                new Contact(
                        Email = 'fsdf@fdf.fd',
                        Additional_Emails__c = 'testtest@test.ru:fsdf@sdfgg.gf'
                ),
                new Contact(
                        Email = 'test@test.ru',
                        Additional_Emails__c = 'test@test.ru:fsdf@sdfgg.gf'
                ),
                new Contact(
                        Email = 'fsdf@fdf.fd',
                        Additional_Emails__c = 'testtest@test.ru:fsdf@sdfgg.gf',
                        Formatted_phones__c = '1112223344',
                        Formatted_phones_additional__c = ''
                ),
                new Contact(
                        Email = 'fsdf@fdf.fd',
                        Additional_Emails__c = 'testtest@test.ru:fsdf@sdfgg.gf',
                        Formatted_phones__c = '1112223344',
                        Formatted_phones_additional__c = '1112223344'
                ),
                new Contact(
                        Email = 'fsdf@fdf.fd',
                        Additional_Emails__c = 'test@tedsdst.ru:fsdf@sdfgg.gf',
                        Formatted_phones__c = '',
                        Formatted_phones_additional__c = '1112223344'
                )
        };
        System.assertEquals(3, E2EFormRuServiceImplHelper.matchAdditionalEmails(contacts, email).size());
        System.assertEquals(6, E2EFormRuServiceImplHelper.matchAdditionalEmails(contacts, email, phone).size());
        System.assertEquals(0, E2EFormRuServiceImplHelper.matchAdditionalEmails(new List<Contact>{new Contact()}, '').size());

        //for Lead
        String inn = '1234567890';
        List<Lead> leads = new List<Lead> {
                new Lead(
                        Email = 'test@test.ru',
                        Additional_Emails__c = 'test423@tsd.ds:fsdf@sdfgg.gf'
                ),
                new Lead(
                        Email = 'dfg@fd.fd',
                        Additional_Emails__c = 'test423@tsd.ds:test@test.ru'
                ),
                new Lead(
                        Email = 'fsdf@fdf.fd',
                        Additional_Emails__c = 'testtest@test.ru:fsdf@sdfgg.gf'
                ),
                new Lead(
                        Email = 'test@test.ru',
                        Additional_Emails__c = 'test@test.ru:fsdf@sdfgg.gf'
                ),
                new Lead(
                        Email = 'fsdf@fdf.fd',
                        Additional_Emails__c = 'testtest@test.ru:fsdf@sdfgg.gf',
                        Formatted_phones__c = '1112223344',
                        Formatted_phones_additional__c = ''
                ),
                new Lead(
                        Email = 'fsdf@fdf.fd',
                        Additional_Emails__c = 'testtest@test.ru:fsdf@sdfgg.gf',
                        Formatted_phones__c = '1112223344',
                        Formatted_phones_additional__c = '1112223344'
                ),
                new Lead(
                        Email = 'fsdf@fdf.fd',
                        Additional_Emails__c = 'test@tdsdest.ru:fsdf@sdfgg.gf',
                        Formatted_phones__c = '',
                        Formatted_phones_additional__c = '1112223344'
                ),
                new Lead(
                        INN__c = inn
                )
        };
        System.assertEquals(7, E2EFormRuServiceImplHelper.matchAdditionalEmails(leads, email, phone, inn).size());
        System.assertEquals(3, E2EFormRuServiceImplHelper.matchAdditionalEmails(leads, email).size());
        System.assertEquals(6, E2EFormRuServiceImplHelper.matchAdditionalEmails(leads, email, phone).size());
        System.assertEquals(0, E2EFormRuServiceImplHelper.matchAdditionalEmails(new List<Lead>{new Lead()}, '', '').size());
    }

    @isTest
    static void tesGenerateEDMInfo_ExceptionCases() {
		TransitRequestData transitRequestData = new TransitRequestData();
		E2EFormParams fromParams = new E2EFormParams();

		TransitRequestData.EDMInfo edmInfo = E2EFormRuServiceImplHelper.generateEDMInfo(null, null);
		System.assertEquals(null, edmInfo);

		edmInfo = E2EFormRuServiceImplHelper.generateEDMInfo(transitRequestData, null);
		System.assertEquals(null, edmInfo);

		edmInfo = E2EFormRuServiceImplHelper.generateEDMInfo(null, fromParams);
		System.assertEquals(null, edmInfo);

		edmInfo = E2EFormRuServiceImplHelper.generateEDMInfo(transitRequestData, fromParams);
		System.assertEquals(null, edmInfo);

		fromParams.electronicDocumentManagement = '';
		edmInfo = E2EFormRuServiceImplHelper.generateEDMInfo(transitRequestData, fromParams);
		System.assertEquals(null, edmInfo);
	}
	
	@isTest
    static void tesGenerateEDMInfo_SuccessScenarios() {
		TransitRequestData transitRequestData = new TransitRequestData();
		E2EFormParams fromParams = new E2EFormParams();

		List<StaticResource> edmSRList = [
			SELECT Body
			FROM StaticResource
			WHERE Name =: E2EFormRuServiceImplHelper.EDM_RESOURCE_NAME
			LIMIT 1
		];

		if (edmSRList != null && !edmSRList.isEmpty()) {
			Map<String, Object> resourceNames = (Map<String, Object>) ((Map<String, Object>) JSON.deserializeUntyped((edmSRList.get(0)).Body.toString()));
			List<String> keys = new List<String>(resourceNames.keySet());
			String value = (String) resourceNames.get(keys.get(0));
			fromParams.electronicDocumentManagement = keys.get(0);
		
			TransitRequestData.EDMInfo edmInfo = E2EFormRuServiceImplHelper.generateEDMInfo(transitRequestData, fromParams);
			System.assertEquals(value, edmInfo.electronicDocumentManagement);
			System.assertEquals(1, edmInfo.docSigned);
			System.assertEquals(1, edmInfo.docType);
			System.assertEquals(Datetime.now().format(E2EFormRuServiceImplHelper.DATE_FORMAT_PATTERN), edmInfo.signDate);

			transitRequestData.cont = new TransitRequestData.Cont();
			transitRequestData.cont.contractDate = '22.09.2010';
			edmInfo = E2EFormRuServiceImplHelper.generateEDMInfo(transitRequestData, fromParams);
			System.assertEquals('22-Sep-2010', edmInfo.signDate);
		}
    }

    @isTest
    static void tesGetContractTypeMapping() {
        E2EFormRuServiceImplHelper helper = new E2EFormRuServiceImplHelper();
        Map<Integer, Integer> contractTypeMapping = helper.getContractTypeMapping();

        System.assertEquals(0, contractTypeMapping.size());

        Transit_Contract_Type_Mapping__c transitContractTypeMapping = new Transit_Contract_Type_Mapping__c();
        transitContractTypeMapping.Name = 'test';
        insert transitContractTypeMapping;

        contractTypeMapping = helper.getContractTypeMapping();
        System.assertEquals(1, contractTypeMapping.size());
        System.assertEquals(null, contractTypeMapping.values()[0]);

        transitContractTypeMapping.Contract_Type__c = 1;
        transitContractTypeMapping.Credit_Period__c = 10;
        update transitContractTypeMapping;

        contractTypeMapping = helper.getContractTypeMapping();
        System.assertEquals(1, contractTypeMapping.size());
        System.assertEquals(1, contractTypeMapping.values()[0]);
    }

    @isTest
    static void testGetContractTypeByPeriod() {
        E2EFormRuServiceImplHelper helper = new E2EFormRuServiceImplHelper();
        Integer contractType = helper.getContractTypeByPeriod(null);

        System.assertEquals(null, contractType);

        contractType = helper.getContractTypeByPeriod(10);
        System.assertEquals(null, contractType);

        Transit_Contract_Type_Mapping__c transitContractTypeMapping = E2EFormRuDataTestFactory.createTransitContractTypeMapping(10, 1);
        insert transitContractTypeMapping;
        
        contractType = helper.getContractTypeByPeriod(10);
        System.assertEquals(1, contractType);
    }

    @isTest
    static void testGetCreditPeriodInWords() {
        E2EFormRuServiceImplHelper helper = new E2EFormRuServiceImplHelper();

        String creditPeriodInWords = helper.getCreditPeriodInWords(null);
        System.assertEquals('', creditPeriodInWords);

        creditPeriodInWords = helper.getCreditPeriodInWords(10);
        System.assertEquals('', creditPeriodInWords);

        Transit_Contract_Type_Mapping__c transitContractTypeMapping = E2EFormRuDataTestFactory.createTransitContractTypeMapping(10, 1);
        transitContractTypeMapping.Credit_Period_In_Words__c = 'ten';
        insert transitContractTypeMapping;

        creditPeriodInWords = helper.getCreditPeriodInWords(10);
        System.assertEquals('ten', creditPeriodInWords);
    }

    @isTest
    public static void testChekingOwnerForOpportunities() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());
        User currUser = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createAdminUser());

        System.runAs(owner) {
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            insert opportunity;

            Opportunity opportunityOtherOwner = E2EFormRuTestUtils.createOpportunity(account.Id);
            opportunityOtherOwner.OwnerId = currUser.id;
            insert opportunityOtherOwner;

            List<Opportunity> foundOpportunities = new List<Opportunity>();
            foundOpportunities.add(opportunity);

            E2EFormRuDeduplicationResult e2eDeduplicationResult = new E2EFormRuDeduplicationResult();
            e2eDeduplicationResult.e2eOpportunity = opportunity;

            E2EFormRuServiceImplHelper.checkingOwnerForOpportunities(foundOpportunities, e2eDeduplicationResult);
            System.assertEquals(false, e2eDeduplicationResult.isDifferentOwnerFoundForOpportunities);

            e2eDeduplicationResult.e2eOpportunity = opportunityOtherOwner;
            E2EFormRuServiceImplHelper.checkingOwnerForOpportunities(foundOpportunities, e2eDeduplicationResult);
            System.assertEquals(true, e2eDeduplicationResult.isDifferentOwnerFoundForOpportunities);
        }
    }

    @isTest
    public static void testAddPersonalOfficeData() {
        ReportRequestData requestData = null;
        E2EFormParams formParams = null;
        E2EFormRuServiceImplHelper helper = new E2EFormRuServiceImplHelper();

        helper.addPersonalOfficeData(requestData, formParams);
        System.assertEquals(null, requestData);

        requestData = new ReportRequestData();
        helper.addPersonalOfficeData(requestData, formParams);
        System.assertEquals(null, requestData.reportParams);

        requestData.reportParams = new ReportRequestData.ReportParams();
        formParams = new E2EFormParams();
        formParams.personalOfficePhone = '';
        formParams.emailForPersonalOffice = '';
        try {
            helper.addPersonalOfficeData(requestData, formParams);
        } catch (Exception e) {
            System.assertEquals(E2EFormRuServiceImplHelper.PERSONAL_OFFICE_DATA_EMPTY_ERROR, e.getMessage());
        }

        formParams.personalOfficePhone = '777';
        formParams.emailForPersonalOffice = 'test@test.com';
        helper.addPersonalOfficeData(requestData, formParams);
        System.assertEquals(formParams.personalOfficePhone, requestData.reportParams.PERSONAL_OFFICE_PHONE);
        System.assertEquals(formParams.emailForPersonalOffice, requestData.reportParams.PERSONAL_OFFICE_EMAIL);
    }
}
