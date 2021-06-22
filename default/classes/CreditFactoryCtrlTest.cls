@isTest
public class CreditFactoryCtrlTest {
    
    
    /*******************************************************************************
    *  Summary         : create test data for all methods   
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        List<Account> accountsList = new List<Account>();
        Account accountPL = CreditFactoryTestUtils.generateAccountPL();
        accountsList.add(accountPL);
        Account accountHU = CreditFactoryTestUtils.generateAccountHU();
        accountsList.add(accountHU);
        insert accountsList;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunityPL = CreditFactoryTestUtils.generateOpportunityPL();
        opportunityPL.AccountId = accountPL.Id;
        opportunitiesList.add(opportunityPL);
        Opportunity opportunityHU = CreditFactoryTestUtils.generateOpportunityHU();
        opportunityHU.AccountId = accountHU.Id;
        opportunitiesList.add(opportunityHU);
        insert opportunitiesList;

        Contact contact = CreditFactoryTestUtils.generateContactPL();
        contact.AccountId = accountPL.Id;
        insert contact;
        
        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunityPL.Id;
        role.ContactId = contact.Id;
        insert role;
        
        dsfs__DocuSign_Status__c docuSignStatus = CreditFactoryTestUtils.generateDocuSignStatus();
        docuSignStatus.dsfs__Opportunity__c = opportunityPL.Id;
        insert docuSignStatus;
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient = CreditFactoryTestUtils.generateDocuSignRecipient();
        docuSignRecipient.dsfs__Parent_Status_Record__c = docuSignStatus.Id;
        insert docuSignRecipient;
        
        Tankkarten__c card = CreditFactoryTestUtils.generateTankkarten();
        card.Opportunity__c = opportunityPL.Id;
        insert card;
        
        Product2 product2 = CreditFactoryTestUtils.generateProduct2();
        insert product2;
        
        PricebookEntry pricebookEntry = CreditFactoryTestUtils.generatePricebookEntry();
        pricebookEntry.Product2Id = product2.Id;
        pricebookEntry.CurrencyIsoCode = 'PLN';
        insert pricebookEntry;
        
        OpportunityLineItem lineItem = CreditFactoryTestUtils.generateLineItem();
        lineItem.OpportunityId = opportunityPL.Id;
        lineItem.PricebookEntryId = pricebookEntry.Id; 
        insert lineItem;
        
        Offer_Item__c offerItem = CreditFactoryTestUtils.generateOfferItem();
        offerItem.Opportunity_Product_Id__c = lineItem.Id;
        insert offerItem;

        List<SObject> customSettingsList = new List<SObject>();
        CreditSystem__c crifSettings = CreditFactoryTestUtils.generateCrifSetting();
        customSettingsList.add(crifSettings);
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        customSettingsList.add(lexisNexisSettings);
        BIG__c bigSettings = CreditFactoryTestUtils.generateBigSetting();
        customSettingsList.add(bigSettings);
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Poland', Index__c = 5.25);
        customSettingsList.add(fuelPrice);
        CF_Order_Notifications__c orderNotification = CreditFactoryTestUtils.createOrderNotificationHU();
        customSettingsList.add(orderNotification);
        insert customSettingsList;

        List<Credit_Factory_Report__c> reportsList = new List<Credit_Factory_Report__c>();
        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Poland');
        report.Opportunity__c = opportunityPL.Id;
        reportsList.add(report);

        Credit_Factory_Report__c additionalReport = CreditFactoryTestUtils.generateCreditFactoryAdditionalReportNL();
        additionalReport.Opportunity__c = opportunityPL.Id;
        reportsList.add(additionalReport);
        insert reportsList;
        
        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Poland');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<Credit_Factory_Calculation__c> calculations = CreditFactoryTestUtils.generateCreditFactoryCalculationsPL();
        insert calculations;
    } 
    
    
    /*******************************************************************************
    *  Summary         : test data generation
    *  Created         : 02/06/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testGenerateDataMap() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        
        System.assertEquals('8338085693', String.valueOf(dataMap.get('taxId')));
    }
    
    
    /*******************************************************************************
    *  Summary         : test validations before search
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testValidateSearch() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String message = CreditFactoryCtrl.validateSearch(dataMap);
        
        System.assertEquals('Your profile doesn\'t have access to Credit Factory.', message);
    }
    
    
    /*******************************************************************************
    *  Summary         : test check existing reports
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testCheckExistingReports() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        
        Boolean areReportsExist = CreditFactoryCtrl.checkExistingReports(dataMap);
        
        System.assertEquals(true, areReportsExist);
    }
    
    
    /*******************************************************************************
    *  Summary         : test valid search for companies
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testSearchCompanies() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> searchResults = new Map<String, Object>();
        Test.startTest();
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ns1:SearchResponse xmlns:ns1="http://www.deltavista.com/dspone/webservices/search"><ns1:Candidates><ns1:Address><ns1:AddressId>1364830</ns1:AddressId><ns1:ParentId>1364830</ns1:ParentId><ns1:FirstName></ns1:FirstName><ns1:MaidenName></ns1:MaidenName><ns1:Name>Kacze wyroby BIS Mariusz Wernyks</ns1:Name><ns1:LegalForm>2</ns1:LegalForm><ns1:Sex>0</ns1:Sex><ns1:Street>Kacza</ns1:Street><ns1:Unit>1</ns1:Unit><ns1:Zip>82-333</ns1:Zip><ns1:City>Wodnowo</ns1:City><ns1:Country>POL</ns1:Country><ns1:DateLastChange>2018-01-10+01:00</ns1:DateLastChange><ns1:CompanyRegistrationDate>2015-10-04+02:00</ns1:CompanyRegistrationDate><ns1:ReferenceNumbers><ns1:ReferenceNumber><ns1:Name>DV_AID</ns1:Name><ns1:Value>1208000003842292</ns1:Value></ns1:ReferenceNumber><ns1:ReferenceNumber><ns1:Name>DV_LID</ns1:Name><ns1:Value>3372000003842288</ns1:Value></ns1:ReferenceNumber><ns1:ReferenceNumber><ns1:Name>DV_UID</ns1:Name><ns1:Value>2849000003842293</ns1:Value></ns1:ReferenceNumber></ns1:ReferenceNumbers><ns1:CompanyRegistrationInfo><ns1:directoryEntry><ns1:type>PL_NIP</ns1:type><ns1:ID>8338085693</ns1:ID></ns1:directoryEntry></ns1:CompanyRegistrationInfo><ns1:CompanyStatus>ACTIVE</ns1:CompanyStatus><ns1:IsRegistered>false</ns1:IsRegistered></ns1:Address><ns1:CompareResult><ns1:HitType>1</ns1:HitType><ns1:Similarity>100.0</ns1:Similarity></ns1:CompareResult></ns1:Candidates></ns1:SearchResponse></soapenv:Body></soapenv:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, searchMock);
            searchResults = CreditFactoryCtrl.searchCompanies(dataMap);
        Test.stopTest();
        
        System.assertEquals(false, ((List<CreditFactoryCompany>) searchResults.get('companies')).isEmpty());
    }
    
    
    /*******************************************************************************
    *  Summary         : test case with no matches for company
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testNoMatchesForCompany() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> searchResults = new Map<String, Object>();
        Test.startTest();
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ns1:SearchResponse xmlns:ns1="http://www.deltavista.com/dspone/webservices/search"></ns1:SearchResponse></soapenv:Body></soapenv:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, searchMock);
            searchResults = CreditFactoryCtrl.searchCompanies(dataMap);
        Test.stopTest();
        
        System.assertEquals(true, ((List<CreditFactoryCompany>) searchResults.get('companies')).isEmpty());
    }
    
    
    /*******************************************************************************
    *  Summary         : test case with not in the list company
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testProcessCompanyNotInTheList() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> notInTheListResults = new Map<String, Object>();
        Test.startTest();
            SingleRequestMock orderMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:messageContext xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:credentials><ns1:user>demo_fleetcor_soap</ns1:user><ns1:password>cvujmHe4</ns1:password></ns1:credentials></ns1:messageContext></soapenv:Header><soapenv:Body><ns1:orderCheckResponse xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:returnCode>1</ns1:returnCode><ns1:product><ns1:name>CreditCheckBusiness</ns1:name><ns1:country>POL</ns1:country><ns1:language>POL</ns1:language></ns1:product><ns1:archiveID>4751000002428489</ns1:archiveID><ns1:reportCreationTime>201801161118</ns1:reportCreationTime><ns1:foundAddress><ns1:legalForm>COMPANY</ns1:legalForm><ns1:address><ns1:name>Kacze wyroby BIS Mariusz Wernyks</ns1:name><ns1:firstName/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location></ns1:address></ns1:foundAddress><ns1:myDecision><ns1:decision>RED</ns1:decision><ns1:rating>U---</ns1:rating></ns1:myDecision><ns1:companyBasicData><ns1:contact><ns1:item>EMAIL</ns1:item><ns1:value>kaczewyrobybis@wodnowo.pl</ns1:value></ns1:contact><ns1:officialName>Kacze wyroby BIS Mariusz Wernyks</ns1:officialName><ns1:location><ns1:type>POSTAL</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>REGISTERED</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>BUSINESS</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:branchesCount>0</ns1:branchesCount><ns1:classification><ns1:companyLegalForm>74</ns1:companyLegalForm><ns1:industryCode><ns1:name>PKD_2007</ns1:name><ns1:code>10.42.Z</ns1:code><ns1:primary>true</ns1:primary></ns1:industryCode></ns1:classification><ns1:registration><ns1:companyRegistry><ns1:type>PL_REGON</ns1:type><ns1:number>414052396</ns1:number></ns1:companyRegistry><ns1:companyRegistry><ns1:type>PL_NIP</ns1:type><ns1:number>8338085693</ns1:number><ns1:dateOfRegistration>20151004</ns1:dateOfRegistration></ns1:companyRegistry></ns1:registration><ns1:dateOfFoundation>20150414</ns1:dateOfFoundation><ns1:knownSince>20150414</ns1:knownSince></ns1:companyBasicData><ns1:companyExtendedData><ns1:organization><ns1:organizationPosition><ns1:holderLegalForm>PERSON</ns1:holderLegalForm><ns1:firstName>Mariusz</ns1:firstName><ns1:name>Wernyks</ns1:name><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip></ns1:location><ns1:sharePercentage>0.0</ns1:sharePercentage><ns1:function><ns1:functionType>OWNER</ns1:functionType><ns1:functionId>101</ns1:functionId><ns1:isActive>true</ns1:isActive></ns1:function><ns1:signatureType>ALONE</ns1:signatureType><ns1:period><ns1:startDate>20150101</ns1:startDate></ns1:period><ns1:hasPaymentInfo>true</ns1:hasPaymentInfo></ns1:organizationPosition></ns1:organization></ns1:companyExtendedData><ns1:decisionMatrix><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>similarCompanies</ns1:comment><ns1:value>65</ns1:value><ns1:name>companyStability</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value><ns1:name>webScore</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>unableCalculate</ns1:comment><ns1:value>-1</ns1:value><ns1:name>creditLimitTransactional</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>thisCompany</ns1:comment><ns1:value>55</ns1:value><ns1:name>generalEvaluationIndex</ns1:name></ns1:item><ns1:identificationDecision><ns1:companyStatus xsi:type="ns1:DecisionMatrixItemCompanyStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment/><ns1:value>ACTIVE</ns1:value></ns1:companyStatus><ns1:identificationType xsi:type="ns1:DecisionMatrixItemIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>IDENTITY_IN_UNIVERSE</ns1:value></ns1:identificationType><ns1:similarHit xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value></ns1:similarHit><ns1:houseType xsi:type="ns1:DecisionMatrixItemString" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>UNKNOWN</ns1:value></ns1:houseType><ns1:nameHint xsi:type="ns1:DecisionMatrixItemNameHint" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>EMPTY</ns1:value></ns1:nameHint><ns1:locationIdentificationType xsi:type="ns1:DecisionMatrixItemLocationIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>NOT_CONFIRMED</ns1:value></ns1:locationIdentificationType></ns1:identificationDecision><ns1:solvencyDecision><ns1:paymentExperience xsi:type="ns1:DecisionMatrixItemPHS" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>RED</ns1:partialDecision><ns1:value>SERIOUS</ns1:value></ns1:paymentExperience><ns1:externalSourcesProcessingStatus xsi:type="ns1:DecisionMatrixItemExternalProcessingStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>ERROR</ns1:value></ns1:externalSourcesProcessingStatus><ns1:daysSinceInBusiness xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>1008</ns1:value></ns1:daysSinceInBusiness><ns1:daysSinceNameChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceNameChange><ns1:daysSinceDomicileChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceDomicileChange></ns1:solvencyDecision></ns1:decisionMatrix><ns1:paymentHistory><ns1:currency>PLN</ns1:currency><ns1:count>1</ns1:count><ns1:dateOfLastEntry>20160315</ns1:dateOfLastEntry><ns1:amountTotal>0.0</ns1:amountTotal><ns1:amountTotalOpen>0.0</ns1:amountTotalOpen><ns1:creditStatusMax>3</ns1:creditStatusMax><ns1:masterRiskStatus>Postępowanie komorniczo-sądowe - Tytuł wykonawczy wystawiony przeciwko osobie fizycznej. (3 - 36) PO.IX NS-REJ.KRS/14418/11/228; SĄD REJONOWY POZNAŃ - NOWE MIASTO I WILDA W POZNANIU, IX WYDZIAŁ GOSPODARCZY KRAJOWEGO REJESTRU SĄDOWEGO</ns1:masterRiskStatus><ns1:detail><ns1:source>PUBLICATION</ns1:source><ns1:debtorName>Kacze wyroby BIS Mariusz Wernyks</ns1:debtorName><ns1:amount>0.0</ns1:amount><ns1:amountOpen>0.0</ns1:amountOpen><ns1:creditStatus>3</ns1:creditStatus><ns1:masterRiskStatus>36</ns1:masterRiskStatus><ns1:paymentStatus>PARTIALLYPAID</ns1:paymentStatus><ns1:comment>Tytuł wykonawczy wystawiony przeciwko osobie fizycznej.</ns1:comment><ns1:courtCaseReferenceNumber>PO.IX NS-REJ.KRS/14418/11/228</ns1:courtCaseReferenceNumber></ns1:detail></ns1:paymentHistory><ns1:normalization><ns1:searchedAddress xsi:type="ns1:SearchedAddressN" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:name/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street/><ns1:city/><ns1:zip/></ns1:location><ns1:liableID>3372000003842288</ns1:liableID></ns1:searchedAddress><ns1:foundAddress><ns1:addressID>1208000003842292</ns1:addressID><ns1:unitID>2849000003842293</ns1:unitID><ns1:liableID>3372000003842288</ns1:liableID><ns1:houseID>308536069</ns1:houseID><ns1:streetID>308536068</ns1:streetID><ns1:cityID>307942197</ns1:cityID></ns1:foundAddress></ns1:normalization><ns1:clientExtensions><ns1:additionalData><ns1:name>mainPKDCode</ns1:name><ns1:value>10.42.Z</ns1:value></ns1:additionalData><ns1:additionalData><ns1:name>detailedCompanyStatus</ns1:name><ns1:value>ACTIVE</ns1:value></ns1:additionalData></ns1:clientExtensions></ns1:orderCheckResponse></soapenv:Body></soapenv:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, orderMock);
            notInTheListResults = CreditFactoryCtrl.processCompanyNotInTheList(dataMap);
        Test.stopTest();
        
        System.assertEquals(true, ((String) notInTheListResults.get('message')).contains('Company is not in the list. '));
    }


    /*******************************************************************************
    *  Summary         : test case with not in the list company
    *  Created         : 22/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testApproveTaxId() {
        Opportunity opportunity = [
                SELECT Id
                FROM Opportunity
                WHERE Account.BillingCountry = 'Hungary'
                LIMIT 1
        ];

        String opportunityId = opportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> notInTheListResults = CreditFactoryCtrl.processCompanyNotInTheList(dataMap);
        Map<String, Object> approveResults = CreditFactoryCtrl.approveTaxId(dataMap);

        System.assertEquals(true, notInTheListResults.get('isTaxIdApprove'));
        System.assertEquals('Order request was sent.', approveResults.get('message'));
    }


    /*******************************************************************************
    *  Summary         : test choosing company with available report
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testChooseAvailableCompany() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 2500;
        update testOpportunity;
        
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> reportResults = new Map<String, Object>();
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock crifReportMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:messageContext xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:credentials><ns1:user>demo_fleetcor_soap</ns1:user><ns1:password>cvujmHe4</ns1:password></ns1:credentials></ns1:messageContext></soapenv:Header><soapenv:Body><ns1:orderCheckResponse xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:returnCode>1</ns1:returnCode><ns1:product><ns1:name>CreditCheckBusiness</ns1:name><ns1:country>POL</ns1:country><ns1:language>POL</ns1:language></ns1:product><ns1:archiveID>4751000002428489</ns1:archiveID><ns1:reportCreationTime>201801161118</ns1:reportCreationTime><ns1:foundAddress><ns1:legalForm>COMPANY</ns1:legalForm><ns1:address><ns1:name>Kacze wyroby BIS Mariusz Wernyks</ns1:name><ns1:firstName/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location></ns1:address></ns1:foundAddress><ns1:myDecision><ns1:decision>GREEN</ns1:decision><ns1:rating>U---</ns1:rating></ns1:myDecision><ns1:companyBasicData><ns1:contact><ns1:item>EMAIL</ns1:item><ns1:value>kaczewyrobybis@wodnowo.pl</ns1:value></ns1:contact><ns1:officialName>Kacze wyroby BIS Mariusz Wernyks</ns1:officialName><ns1:location><ns1:type>POSTAL</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>REGISTERED</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>BUSINESS</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:branchesCount>0</ns1:branchesCount><ns1:classification><ns1:companyLegalForm>74</ns1:companyLegalForm><ns1:industryCode><ns1:name>PKD_2007</ns1:name><ns1:code>10.42.Z</ns1:code><ns1:primary>true</ns1:primary></ns1:industryCode></ns1:classification><ns1:registration><ns1:companyRegistry><ns1:type>PL_REGON</ns1:type><ns1:number>414052396</ns1:number></ns1:companyRegistry><ns1:companyRegistry><ns1:type>PL_NIP</ns1:type><ns1:number>8338085693</ns1:number><ns1:dateOfRegistration>20151004</ns1:dateOfRegistration></ns1:companyRegistry></ns1:registration><ns1:dateOfFoundation>20150414</ns1:dateOfFoundation><ns1:knownSince>20150414</ns1:knownSince></ns1:companyBasicData><ns1:companyExtendedData><ns1:organization><ns1:organizationPosition><ns1:holderLegalForm>PERSON</ns1:holderLegalForm><ns1:firstName>Mariusz</ns1:firstName><ns1:name>Wernyks</ns1:name><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip></ns1:location><ns1:sharePercentage>0.0</ns1:sharePercentage><ns1:function><ns1:functionType>OWNER</ns1:functionType><ns1:functionId>101</ns1:functionId><ns1:isActive>true</ns1:isActive></ns1:function><ns1:signatureType>ALONE</ns1:signatureType><ns1:period><ns1:startDate>20150101</ns1:startDate></ns1:period><ns1:hasPaymentInfo>true</ns1:hasPaymentInfo></ns1:organizationPosition></ns1:organization></ns1:companyExtendedData><ns1:decisionMatrix><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>similarCompanies</ns1:comment><ns1:value>65</ns1:value><ns1:name>companyStability</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value><ns1:name>webScore</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>unableCalculate</ns1:comment><ns1:value>-1</ns1:value><ns1:name>creditLimitTransactional</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>thisCompany</ns1:comment><ns1:value>55</ns1:value><ns1:name>generalEvaluationIndex</ns1:name></ns1:item><ns1:identificationDecision><ns1:companyStatus xsi:type="ns1:DecisionMatrixItemCompanyStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment/><ns1:value>ACTIVE</ns1:value></ns1:companyStatus><ns1:identificationType xsi:type="ns1:DecisionMatrixItemIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>IDENTITY_IN_UNIVERSE</ns1:value></ns1:identificationType><ns1:similarHit xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value></ns1:similarHit><ns1:houseType xsi:type="ns1:DecisionMatrixItemString" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>UNKNOWN</ns1:value></ns1:houseType><ns1:nameHint xsi:type="ns1:DecisionMatrixItemNameHint" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>EMPTY</ns1:value></ns1:nameHint><ns1:locationIdentificationType xsi:type="ns1:DecisionMatrixItemLocationIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>NOT_CONFIRMED</ns1:value></ns1:locationIdentificationType></ns1:identificationDecision><ns1:solvencyDecision><ns1:paymentExperience xsi:type="ns1:DecisionMatrixItemPHS" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>RED</ns1:partialDecision><ns1:value>SERIOUS</ns1:value></ns1:paymentExperience><ns1:externalSourcesProcessingStatus xsi:type="ns1:DecisionMatrixItemExternalProcessingStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>OK</ns1:value></ns1:externalSourcesProcessingStatus><ns1:daysSinceInBusiness xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>1008</ns1:value></ns1:daysSinceInBusiness><ns1:daysSinceNameChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceNameChange><ns1:daysSinceDomicileChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceDomicileChange></ns1:solvencyDecision></ns1:decisionMatrix><ns1:paymentHistory><ns1:currency>PLN</ns1:currency><ns1:count>1</ns1:count><ns1:dateOfLastEntry>20160315</ns1:dateOfLastEntry><ns1:amountTotal>0.0</ns1:amountTotal><ns1:amountTotalOpen>0.0</ns1:amountTotalOpen><ns1:creditStatusMax>3</ns1:creditStatusMax><ns1:masterRiskStatus>Postępowanie komorniczo-sądowe - Tytuł wykonawczy wystawiony przeciwko osobie fizycznej. (3 - 36) PO.IX NS-REJ.KRS/14418/11/228; SĄD REJONOWY POZNAŃ - NOWE MIASTO I WILDA W POZNANIU, IX WYDZIAŁ GOSPODARCZY KRAJOWEGO REJESTRU SĄDOWEGO</ns1:masterRiskStatus><ns1:detail><ns1:source>PUBLICATION</ns1:source><ns1:debtorName>Kacze wyroby BIS Mariusz Wernyks</ns1:debtorName><ns1:amount>0.0</ns1:amount><ns1:amountOpen>0.0</ns1:amountOpen><ns1:creditStatus>3</ns1:creditStatus><ns1:masterRiskStatus>36</ns1:masterRiskStatus><ns1:paymentStatus>PARTIALLYPAID</ns1:paymentStatus><ns1:comment>Tytuł wykonawczy wystawiony przeciwko osobie fizycznej.</ns1:comment><ns1:courtCaseReferenceNumber>PO.IX NS-REJ.KRS/14418/11/228</ns1:courtCaseReferenceNumber></ns1:detail></ns1:paymentHistory><ns1:normalization><ns1:searchedAddress xsi:type="ns1:SearchedAddressN" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:name/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street/><ns1:city/><ns1:zip/></ns1:location><ns1:liableID>3372000003842288</ns1:liableID></ns1:searchedAddress><ns1:foundAddress><ns1:addressID>1208000003842292</ns1:addressID><ns1:unitID>2849000003842293</ns1:unitID><ns1:liableID>3372000003842288</ns1:liableID><ns1:houseID>308536069</ns1:houseID><ns1:streetID>308536068</ns1:streetID><ns1:cityID>307942197</ns1:cityID></ns1:foundAddress></ns1:normalization><ns1:clientExtensions><ns1:additionalData><ns1:name>mainPKDCode</ns1:name><ns1:value>10.42.Z</ns1:value></ns1:additionalData><ns1:additionalData><ns1:name>detailedCompanyStatus</ns1:name><ns1:value>ACTIVE</ns1:value></ns1:additionalData></ns1:clientExtensions></ns1:orderCheckResponse></soapenv:Body></soapenv:Envelope>', null);
            mocksMap.put('https://demo.deltavista.pl/dvs-soap/services/OrderCheckService', crifReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">1</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            SingleRequestMock bigMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><a:getReportResponse xmlns:a="http://api.big.pl/bigApi/v1/types"><responseId>cabb1224d9614a4ab0c24648398075f2</responseId><responseDateTime>2019-10-15T13:07:41.130+02:00</responseDateTime><requestId>kk004</requestId><requestDateTime>2019-10-07T13:00:00</requestDateTime><user>USER188247</user><protocol>bimo v1</protocol><data><![CDATA[&lt;?xml version="1.0" encoding="UTF-8" standalone="yes"?&gt;&lt;ns3:getReportResponse xmlns:ns2="http://api.big.pl/iasWrapper/reports/v1" xmlns:ns3="http://api.big.pl/bimoR/v1"&gt;&lt;success&gt;&lt;currentRequest&gt;&lt;client&gt;&lt;clientId&gt;1777717777&lt;/clientId&gt;&lt;unitId&gt;1777717777&lt;/unitId&gt;&lt;/client&gt;&lt;repeatedRequestMarker&gt;false&lt;/repeatedRequestMarker&gt;&lt;reportComposition xsi:type="ns3:FinancialReportComposition" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;&lt;product&gt;entrepreneur&lt;/product&gt;&lt;components select="custom"&gt;&lt;liabilitiesSummaries&gt;&lt;summaryRequest&gt;&lt;liabilitiesSource&gt;bigIm&lt;/liabilitiesSource&gt;&lt;liabilitiesType&gt;overdue fulfilled&lt;/liabilitiesType&gt;&lt;debtorLegalForm&gt;legalPerson&lt;/debtorLegalForm&gt;&lt;/summaryRequest&gt;&lt;/liabilitiesSummaries&gt;&lt;imEntrepreneurOverdueLiabilities&gt;&lt;containRestricted&gt;false&lt;/containRestricted&gt;&lt;searchByPesel&gt;false&lt;/searchByPesel&gt;&lt;/imEntrepreneurOverdueLiabilities&gt;&lt;imEntrepreneurFulfilledLiabilities&gt;&lt;containRestricted&gt;false&lt;/containRestricted&gt;&lt;searchByPesel&gt;false&lt;/searchByPesel&gt;&lt;/imEntrepreneurFulfilledLiabilities&gt;&lt;imEntrepreneurInquiries/&gt;&lt;bikEntrepreneurOverdueLiabilities/&gt;&lt;zbpUnreliableEntrepreneursByNip/&gt;&lt;/components&gt;&lt;reportSubject xsi:type="ns5:LegalPerson" xmlns:ns5="http://api.big.pl/bimo/v1"&gt;&lt;fullName&gt;PTASZNIK&lt;/fullName&gt;&lt;nip&gt;9523658461&lt;/nip&gt;&lt;/reportSubject&gt;&lt;consentList&gt;&lt;consent grantDate="2019-08-28"&gt;entrepreneurZbpAuthorisation&lt;/consent&gt;&lt;consent grantDate="2019-08-28"&gt;bigImInquiriesAuthorisation&lt;/consent&gt;&lt;consent grantDate="2019-08-28"&gt;entrepreneurBikAuthorisation&lt;/consent&gt;&lt;/consentList&gt;&lt;/reportComposition&gt;&lt;/currentRequest&gt;&lt;exchangeRateTable&gt;&lt;id&gt;200/A/NBP/2019&lt;/id&gt;&lt;date&gt;2019-10-15&lt;/date&gt;&lt;/exchangeRateTable&gt;&lt;components&gt;&lt;reportComponent&gt;&lt;componentId&gt;t9c/WB1ysCfI2L2NKP2MR+lxobM=&lt;/componentId&gt;&lt;componentType&gt;imEntrepreneurOverdueLiabilities&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:35.883&lt;/validityDateTime&gt;&lt;processingResult&gt;noDataFound&lt;/processingResult&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;x2lrRU4UH8Nd0KNIMK/7Nk0nH1A=&lt;/componentId&gt;&lt;componentType&gt;imEntrepreneurFulfilledLiabilities&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:35.887&lt;/validityDateTime&gt;&lt;processingResult&gt;noDataFound&lt;/processingResult&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;z0dItQENKoXkF3oaFvBFjsey2Ys=&lt;/componentId&gt;&lt;componentType&gt;imEntrepreneurInquiries&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:36.243&lt;/validityDateTime&gt;&lt;processingResult&gt;success&lt;/processingResult&gt;&lt;data xsi:type="ns3:ImInquiriesData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;&lt;inquiriesByMarketSegment&gt;&lt;segment&gt;enterprise&lt;/segment&gt;&lt;inquiries0To30&gt;48&lt;/inquiries0To30&gt;&lt;inquiries31To90&gt;0&lt;/inquiries31To90&gt;&lt;inquiries91To365&gt;0&lt;/inquiries91To365&gt;&lt;/inquiriesByMarketSegment&gt;&lt;/data&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;h0H6YK+gGKXk2VcbosfT5CvK3GM=&lt;/componentId&gt;&lt;componentType&gt;zbpUnreliableEntrepreneursByNip&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:35.886&lt;/validityDateTime&gt;&lt;processingResult&gt;success&lt;/processingResult&gt;&lt;data xsi:type="ns3:ZbpUnreliableEntrepreneursByNipData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;&lt;checkResult&gt;noDataFound&lt;/checkResult&gt;&lt;/data&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;ceb85508a50948108ab532f33fc73358&lt;/componentId&gt;&lt;componentType&gt;bikEntrepreneurOverdueLiabilities&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:37.212&lt;/validityDateTime&gt;&lt;processingResult&gt;noDataFound&lt;/processingResult&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;AVrr1m8yNSasPlWBXez5FO09tH0=&lt;/componentId&gt;&lt;componentType&gt;liabilitiesSummary&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:38&lt;/validityDateTime&gt;&lt;processingResult&gt;success&lt;/processingResult&gt;&lt;data xsi:type="ns3:LiabilitiesSummaryData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;&lt;checkResult&gt;negativeInformationNotFounded&lt;/checkResult&gt;&lt;overdueLiabilitiesSummary&gt;&lt;creditorsCount&gt;0&lt;/creditorsCount&gt;&lt;economicInformationsCount&gt;0&lt;/economicInformationsCount&gt;&lt;liabilitiesCount&gt;0&lt;/liabilitiesCount&gt;&lt;totalAmount&gt;0&lt;/totalAmount&gt;&lt;totalOverdueAmount&gt;0&lt;/totalOverdueAmount&gt;&lt;/overdueLiabilitiesSummary&gt;&lt;fulfilledLiabilitiesSummary&gt;&lt;creditorsCount&gt;0&lt;/creditorsCount&gt;&lt;economicInformationsCount&gt;0&lt;/economicInformationsCount&gt;&lt;liabilitiesCount&gt;0&lt;/liabilitiesCount&gt;&lt;totalAmount&gt;0&lt;/totalAmount&gt;&lt;totalRepaidAmount&gt;0&lt;/totalRepaidAmount&gt;&lt;/fulfilledLiabilitiesSummary&gt;&lt;/data&gt;&lt;/reportComponent&gt;&lt;/components&gt;&lt;/success&gt;&lt;/ns3:getReportResponse&gt;]]></data></a:getReportResponse></soapenv:Body></soapenv:Envelope>', null);
            mocksMap.put('https://wasstt.infomonitor.pl:443/bigApi/v1/ReportOrderService', bigMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            reportResults = CreditFactoryCtrl.chooseCompany(dataMap, '1234123412', false);
        Test.stopTest();
        
        System.assertEquals(true, reportResults.get('cfResult') != null);
    }
    
    
    /*******************************************************************************
    *  Summary         : test choosing company with unavailable report
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testChooseUnavailableCompany() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> reportResults = new Map<String, Object>();
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock crifReportMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:messageContext xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:credentials><ns1:user>demo_fleetcor_soap</ns1:user><ns1:password>cvujmHe4</ns1:password></ns1:credentials></ns1:messageContext></soapenv:Header><soapenv:Body><ns1:orderCheckResponse xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:returnCode>1</ns1:returnCode><ns1:product><ns1:name>CreditCheckBusiness</ns1:name><ns1:country>POL</ns1:country><ns1:language>POL</ns1:language></ns1:product><ns1:archiveID>4751000002428489</ns1:archiveID><ns1:reportCreationTime>201801161118</ns1:reportCreationTime><ns1:foundAddress><ns1:legalForm>COMPANY</ns1:legalForm><ns1:address><ns1:name>Kacze wyroby BIS Mariusz Wernyks</ns1:name><ns1:firstName/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location></ns1:address></ns1:foundAddress><ns1:myDecision><ns1:decision>RED</ns1:decision><ns1:rating>U---</ns1:rating></ns1:myDecision><ns1:companyBasicData><ns1:contact><ns1:item>EMAIL</ns1:item><ns1:value>kaczewyrobybis@wodnowo.pl</ns1:value></ns1:contact><ns1:officialName>Kacze wyroby BIS Mariusz Wernyks</ns1:officialName><ns1:location><ns1:type>POSTAL</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>REGISTERED</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>BUSINESS</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:branchesCount>0</ns1:branchesCount><ns1:classification><ns1:companyLegalForm>74</ns1:companyLegalForm><ns1:industryCode><ns1:name>PKD_2007</ns1:name><ns1:code>10.42.Z</ns1:code><ns1:primary>true</ns1:primary></ns1:industryCode></ns1:classification><ns1:registration><ns1:companyRegistry><ns1:type>PL_REGON</ns1:type><ns1:number>414052396</ns1:number></ns1:companyRegistry><ns1:companyRegistry><ns1:type>PL_NIP</ns1:type><ns1:number>8338085693</ns1:number><ns1:dateOfRegistration>20151004</ns1:dateOfRegistration></ns1:companyRegistry></ns1:registration><ns1:dateOfFoundation>20150414</ns1:dateOfFoundation><ns1:knownSince>20150414</ns1:knownSince></ns1:companyBasicData><ns1:companyExtendedData><ns1:organization><ns1:organizationPosition><ns1:holderLegalForm>PERSON</ns1:holderLegalForm><ns1:firstName>Mariusz</ns1:firstName><ns1:name>Wernyks</ns1:name><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip></ns1:location><ns1:sharePercentage>0.0</ns1:sharePercentage><ns1:function><ns1:functionType>OWNER</ns1:functionType><ns1:functionId>101</ns1:functionId><ns1:isActive>true</ns1:isActive></ns1:function><ns1:signatureType>ALONE</ns1:signatureType><ns1:period><ns1:startDate>20150101</ns1:startDate></ns1:period><ns1:hasPaymentInfo>true</ns1:hasPaymentInfo></ns1:organizationPosition></ns1:organization></ns1:companyExtendedData><ns1:decisionMatrix><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>similarCompanies</ns1:comment><ns1:value>65</ns1:value><ns1:name>companyStability</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value><ns1:name>webScore</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>unableCalculate</ns1:comment><ns1:value>-1</ns1:value><ns1:name>creditLimitTransactional</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>thisCompany</ns1:comment><ns1:value>55</ns1:value><ns1:name>generalEvaluationIndex</ns1:name></ns1:item><ns1:identificationDecision><ns1:companyStatus xsi:type="ns1:DecisionMatrixItemCompanyStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment/><ns1:value>ACTIVE</ns1:value></ns1:companyStatus><ns1:identificationType xsi:type="ns1:DecisionMatrixItemIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>IDENTITY_IN_UNIVERSE</ns1:value></ns1:identificationType><ns1:similarHit xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value></ns1:similarHit><ns1:houseType xsi:type="ns1:DecisionMatrixItemString" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>UNKNOWN</ns1:value></ns1:houseType><ns1:nameHint xsi:type="ns1:DecisionMatrixItemNameHint" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>EMPTY</ns1:value></ns1:nameHint><ns1:locationIdentificationType xsi:type="ns1:DecisionMatrixItemLocationIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>NOT_CONFIRMED</ns1:value></ns1:locationIdentificationType></ns1:identificationDecision><ns1:solvencyDecision><ns1:paymentExperience xsi:type="ns1:DecisionMatrixItemPHS" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>RED</ns1:partialDecision><ns1:value>SERIOUS</ns1:value></ns1:paymentExperience><ns1:externalSourcesProcessingStatus xsi:type="ns1:DecisionMatrixItemExternalProcessingStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>ERROR</ns1:value></ns1:externalSourcesProcessingStatus><ns1:daysSinceInBusiness xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>1008</ns1:value></ns1:daysSinceInBusiness><ns1:daysSinceNameChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceNameChange><ns1:daysSinceDomicileChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceDomicileChange></ns1:solvencyDecision></ns1:decisionMatrix><ns1:paymentHistory><ns1:currency>PLN</ns1:currency><ns1:count>1</ns1:count><ns1:dateOfLastEntry>20160315</ns1:dateOfLastEntry><ns1:amountTotal>0.0</ns1:amountTotal><ns1:amountTotalOpen>0.0</ns1:amountTotalOpen><ns1:creditStatusMax>3</ns1:creditStatusMax><ns1:masterRiskStatus>Postępowanie komorniczo-sądowe - Tytuł wykonawczy wystawiony przeciwko osobie fizycznej. (3 - 36) PO.IX NS-REJ.KRS/14418/11/228; SĄD REJONOWY POZNAŃ - NOWE MIASTO I WILDA W POZNANIU, IX WYDZIAŁ GOSPODARCZY KRAJOWEGO REJESTRU SĄDOWEGO</ns1:masterRiskStatus><ns1:detail><ns1:source>PUBLICATION</ns1:source><ns1:debtorName>Kacze wyroby BIS Mariusz Wernyks</ns1:debtorName><ns1:amount>0.0</ns1:amount><ns1:amountOpen>0.0</ns1:amountOpen><ns1:creditStatus>3</ns1:creditStatus><ns1:masterRiskStatus>36</ns1:masterRiskStatus><ns1:paymentStatus>PARTIALLYPAID</ns1:paymentStatus><ns1:comment>Tytuł wykonawczy wystawiony przeciwko osobie fizycznej.</ns1:comment><ns1:courtCaseReferenceNumber>PO.IX NS-REJ.KRS/14418/11/228</ns1:courtCaseReferenceNumber></ns1:detail></ns1:paymentHistory><ns1:normalization><ns1:searchedAddress xsi:type="ns1:SearchedAddressN" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:name/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street/><ns1:city/><ns1:zip/></ns1:location><ns1:liableID>3372000003842288</ns1:liableID></ns1:searchedAddress><ns1:foundAddress><ns1:addressID>1208000003842292</ns1:addressID><ns1:unitID>2849000003842293</ns1:unitID><ns1:liableID>3372000003842288</ns1:liableID><ns1:houseID>308536069</ns1:houseID><ns1:streetID>308536068</ns1:streetID><ns1:cityID>307942197</ns1:cityID></ns1:foundAddress></ns1:normalization><ns1:clientExtensions><ns1:additionalData><ns1:name>mainPKDCode</ns1:name><ns1:value>10.42.Z</ns1:value></ns1:additionalData><ns1:additionalData><ns1:name>detailedCompanyStatus</ns1:name><ns1:value>ACTIVE</ns1:value></ns1:additionalData></ns1:clientExtensions></ns1:orderCheckResponse></soapenv:Body></soapenv:Envelope>', null);
            mocksMap.put('https://demo.deltavista.pl/dvs-soap/services/OrderCheckService', crifReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            reportResults = CreditFactoryCtrl.chooseCompany(dataMap, '1234123412', false);
        Test.stopTest();
        
        System.assertEquals(true, String.valueOf(reportResults.get('message')).contains('Credit Factory report received with a system error.'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test selecting company from database
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testSelectCompany() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> reportResults = CreditFactoryCtrl.selectCompany(dataMap);
        
        System.assertEquals(true, reportResults.get('cfResult') != null);
    }
    
    
    /*******************************************************************************
    *  Summary         : test get sections data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testGetSectionsData() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> reportResults = CreditFactoryCtrl.selectCompany(dataMap);
        Object companyData = reportResults.get('selectedCompany');
        List<Object> sectionsData = CreditFactoryCtrl.getSectionsData(companyData, null, dataMap);
        
        System.assertEquals(false, sectionsData.isEmpty());
    }
    
    
    /*******************************************************************************
    *  Summary         : test get address update data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testGetAddressUpdateData() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> reportResults = CreditFactoryCtrl.selectCompany(dataMap);
        Object companyData = reportResults.get('selectedCompany');
        Map<String, Object> addressUpdateDataMap = CreditFactoryCtrl.getAddressData(companyData, null, dataMap);
        
        System.assertEquals('Update Address', String.valueOf(addressUpdateDataMap.get('header')));
    }
    
    
    /*******************************************************************************
    *  Summary         : test get name update data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testGetNameUpdateData() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> reportResults = CreditFactoryCtrl.selectCompany(dataMap);
        Object companyData = reportResults.get('selectedCompany');
        Map<String, Object> nameUpdateDataMap = CreditFactoryCtrl.getNameUpdateData(companyData, null, dataMap);
        
        System.assertEquals('Update Name', String.valueOf(nameUpdateDataMap.get('header')));
    }
    
    
    /*******************************************************************************
    *  Summary         : test get tax id update data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testGetTaxIdUpdateData() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> reportResults = CreditFactoryCtrl.selectCompany(dataMap);
        Object companyData = reportResults.get('selectedCompany');
        Map<String, Object> taxIdUpdateDataMap = CreditFactoryCtrl.getTaxIdUpdateData(companyData, dataMap);
        
        System.assertEquals('Update Tax Id', String.valueOf(taxIdUpdateDataMap.get('header')));
    }
    
    
    /*******************************************************************************
    *  Summary         : test get trade register number update data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testGetTradeRegisterNumberUpdateData() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        Map<String, Object> reportResults = CreditFactoryCtrl.selectCompany(dataMap);
        Object companyData = reportResults.get('selectedCompany');
        Map<String, Object> tradeRegisterNumberUpdateDataMap = CreditFactoryCtrl.getTradeRegisterNumberUpdateData(companyData, dataMap);
        
        System.assertEquals('Update Trade Register Number', String.valueOf(tradeRegisterNumberUpdateDataMap.get('header')));
    }


    /*******************************************************************************
    *  Summary         : test get vat number update data
    *  Created         : 18/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testGetVatNumberUpdateData() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();

        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(testOpportunity.Id);
        Map<String, Object> reportResults = CreditFactoryCtrl.selectCompany(dataMap);
        Object companyData = reportResults.get('selectedCompany');
        Map<String, Object> tradeRegisterNumberUpdateDataMap = CreditFactoryCtrl.getVatNumberUpdateData(companyData, dataMap);

        System.assertEquals('Update Vat Number', String.valueOf(tradeRegisterNumberUpdateDataMap.get('header')));
    }


    /*******************************************************************************
    *  Summary         : test get swift bic update data
    *  Created         : 18/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testGetSwiftBicUpdateData() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();

        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(testOpportunity.Id);
        Map<String, Object> tradeRegisterNumberUpdateDataMap = CreditFactoryCtrl.getSwiftBicUpdateData(dataMap);

        System.assertEquals('Update SWIFT BIC', String.valueOf(tradeRegisterNumberUpdateDataMap.get('header')));
    }
    
    
    /*******************************************************************************
    *  Summary         : test updating address data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testDoUpdateAddress() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'address');
        
        System.assertEquals('Address has been updated.', successMessage);
    }


    /*******************************************************************************
    *  Summary         : test updating additional address data
    *  Created         : 14/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testDoUpdateAdditionalAddress() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'additionalAddress');

        System.assertEquals('Address has been updated.', successMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test updating postal address data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testDoUpdatePostalAddress() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'postalAddress');
        
        System.assertEquals('Address has been updated.', successMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test updating registered address data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testDoUpdateRegisteredAddress() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'registeredAddress');
        
        System.assertEquals('Address has been updated.', successMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test updating name data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testDoUpdateName() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'name');
        
        System.assertEquals('Account Name has been updated.', successMessage);
    }


    /*******************************************************************************
    *  Summary         : test updating name data
    *  Created         : 30/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testDoUpdateTradeName() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c creditFactoryReport = CreditFactoryTestUtils.selectCreditFactoryReport();
        creditFactoryReport.Trade_Name__c = 'Test Name';
        update creditFactoryReport;

        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'tradeName');

        System.assertEquals('Account Name has been updated.', successMessage);
    }


    /*******************************************************************************
    *  Summary         : test updating additional name data
    *  Created         : 14/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testDoUpdateAdditionalName() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'additionalName');

        System.assertEquals('Account Name has been updated.', successMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test updating tax Id data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testDoUpdateTaxId() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'taxId');
        
        System.assertEquals('Tax Id has been updated.', successMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test updating vat number data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testDoUpdateVatNumber() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'vatNumber');
        
        System.assertEquals('Vat Number has been updated.', successMessage);
    }


    /*******************************************************************************
    *  Summary         : test updating trade register number data
    *  Created         : 14/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testDoUpdateTradeRegisterNumber() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'tradeRegisterNumber');

        System.assertEquals('Trade Register Number has been updated.', successMessage);
    }


    /*******************************************************************************
    *  Summary         : test updating trade register number data
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testDoUpdateSwiftBicNumber() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.doUpdate(dataMap, 'swiftBic');

        System.assertEquals('SWIFT BIC has been updated.', successMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test setting "Update Opportunity" decision
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testSetUpdateOpportunityDecision() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        CreditFactoryCtrl.setUpdateOpportunityDecision(dataMap);
        
        testOpportunity = [
                SELECT Credit_check_date__c 
                FROM Opportunity 
                WHERE Id = :opportunityId
        ];
        
        System.assertEquals(Date.today(), testOpportunity.Credit_check_date__c);
    }
    
    
    /*******************************************************************************
    *  Summary         : test "Contract Check" decision
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testChangeToContractCheck() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        CreditFactoryCtrl.changeToContractCheck(dataMap);
        
        testOpportunity = [
                SELECT CF_Stage__c 
                FROM Opportunity 
                WHERE Id = :opportunityId
        ];
        
        System.assertEquals('Pending Credit - Contract Check', testOpportunity.CF_Stage__c);
    }
    
    
    /*******************************************************************************
    *  Summary         : test "Closed Won" decision
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testChangeToClosedWon() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        CreditFactoryCtrl.changeToClosedWon(dataMap);
        
        testOpportunity = [
                SELECT CF_Stage__c 
                FROM Opportunity 
                WHERE Id = :opportunityId
        ];
        
        System.assertEquals('Auto CW', testOpportunity.CF_Stage__c);
    }


    /*******************************************************************************
    *  Summary         : test "Pending SEPA" decision
    *  Created         : 18/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testChangeToPendingSepa() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        CreditFactoryCtrl.changeToPendingSepa(dataMap);

        testOpportunity = [
                SELECT CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunityId
        ];

        System.assertEquals('SEPA Confirmation', testOpportunity.CF_Stage__c);
    }
    
    
    /*******************************************************************************
    *  Summary         : test "Pending Deposit" decision
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testChangeToPendingDeposit() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Obligation_Overdue__c = true;
        update report;
        
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        CreditFactoryCtrl.changeToPendingDeposit(dataMap);
        
        testOpportunity = [
                SELECT CF_Stage__c, Security_level_H_he_der_Sicherheit__c
                FROM Opportunity 
                WHERE Id = :opportunityId
        ];
        
        System.assertEquals('Pending deposit', testOpportunity.CF_Stage__c);
        System.assertEquals(true, testOpportunity.Security_level_H_he_der_Sicherheit__c != null);
    }


    /*******************************************************************************
    *  Summary         : test "Pending Advance Payment" decision
    *  Created         : 26/02/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testChangeToPendingAdvancePayment() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 0;
        testOpportunity.Number_of_GPS_units__c = 2;
        testOpportunity.Anzahl_der_Karten__c = 0;
        update testOpportunity;

        String opportunityId = testOpportunity.Id;

        List<Offer_Item__c> offerItems = [
                SELECT Id
                FROM Offer_Item__c
        ];
        delete offerItems;

        Test.startTest();
            Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
            CreditFactoryCtrl.changeToPendingAdvancePayment(dataMap);
        Test.stopTest();

        testOpportunity = [
                SELECT CF_Stage__c, StageName
                FROM Opportunity
                WHERE Id = :opportunityId
        ];

        System.assertEquals('Pending Advance Payment', testOpportunity.CF_Stage__c);
        System.assertEquals('Pending Sales - Advance payment', testOpportunity.StageName);
    }
    
    
    /*******************************************************************************
    *  Summary         : test saving errors
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testSaveErrors() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        CreditFactoryCtrl.saveErrors(dataMap, 'Test Error', true);
        
        testOpportunity = [
                SELECT CF_Stage__c, Credit_Factory_Errors__c, Last_CF_Errors__c
                FROM Opportunity 
                WHERE Id = :opportunityId
        ];
        
        System.assertEquals('Error (Report generated)', testOpportunity.CF_Stage__c);
        System.assertEquals('Test Error', testOpportunity.Credit_Factory_Errors__c);
        System.assertEquals('Test Error', testOpportunity.Last_CF_Errors__c);
    }
    
    
    /*******************************************************************************
    *  Summary         : test call confirmation
    *  Created         : 02/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testConfirmCall() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        Task callTask = new Task(
            WhatId = opportunityId,
            CallObject = '12341234'
        );
        
        insert callTask;
        
        CreditFactoryCtrl.getCallTasksList(opportunityId);
        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        CreditFactoryCtrl.confirmCall(dataMap, callTask.Id);
        
        testOpportunity = [
                SELECT Contact_Role_Confirmation_Call__c
                FROM Opportunity 
                WHERE Id = :opportunityId
        ];
        
        System.assertEquals(true, testOpportunity.Contact_Role_Confirmation_Call__c != null);
    }


    /*******************************************************************************
    *  Summary         : test updating contacts
    *  Created         : 14/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testUpdateContacts() {
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Map<String, Object> dataMap = CreditFactoryCtrl.generateDataMap(opportunityId);
        String successMessage = CreditFactoryCtrl.updateContacts(dataMap);

        System.assertEquals('Employees data has been updated.', successMessage);
    }
}