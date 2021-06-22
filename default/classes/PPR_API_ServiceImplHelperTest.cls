@isTest
public with sharing class PPR_API_ServiceImplHelperTest {

    @isTest
    public static void createStreetStringTest() {
        String street = null;
        String house = null;
        String apartment = null;
        String housePrefix = null;

        PPR_API_ServiceImplHelper serviceHelper = new PPR_API_ServiceImplHelper();
        String streetString = serviceHelper.createStreetString(street, house, apartment, housePrefix);

        System.assertEquals('', streetString);

        street = 'street name';
        streetString = serviceHelper.createStreetString(street, house, apartment, housePrefix);

        System.assertEquals('street name ', streetString);

        house = 'house number';
        streetString = serviceHelper.createStreetString(street, house, apartment, housePrefix);

        System.assertEquals('street name house number', streetString);

        housePrefix = 'housePrefix';
        streetString = serviceHelper.createStreetString(street, house, apartment, housePrefix);

        System.assertEquals('street name housePrefix house number', streetString);

        apartment = 'apartment number';
        streetString = serviceHelper.createStreetString(street, house, apartment, housePrefix);

        System.assertEquals('street name housePrefix house number apartment number', streetString);
    }

    @isTest
    public static void saveReferencesInFormDataTest() {
        E2EFormParams formParams = null;
        E2EFormData__c formData = null;
        String formdataId = null;
        PPR_API_ResponseBody response = null;
        PPR_API_ServiceImplHelper serviceHelper = new PPR_API_ServiceImplHelper();

        PPR_API_ResponseBody responseFromMethod = serviceHelper.saveReferencesInFormData(formParams, formData, formdataId, response);

        /** Error check */
        System.assertEquals('FormData updation error', responseFromMethod.message);

        formData = E2EFormRuTestUtils.createDefaultFormData();
        insert formData;
        formData.E2E_Contact_Email__c = 'invalid_email';
        response = ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Error');

        responseFromMethod = serviceHelper.saveReferencesInFormData(formParams, formData, formdataId, response);

        System.assertEquals('Error', responseFromMethod.message);

        /** Logic check  */
        formdataId = formData.Id;
        formData = null;

        responseFromMethod = serviceHelper.saveReferencesInFormData(formParams, formData, formdataId, response);

        System.assertEquals('Error', responseFromMethod.message);

        formParams =  new E2EFormParams();

        responseFromMethod = serviceHelper.saveReferencesInFormData(formParams, formData, formdataId, response);

        System.assertEquals('Error', responseFromMethod.message);

        Account acc = E2EFormRuTestUtils.createDefaultAccount();
        insert acc;
        Opportunity opp = E2EFormRuTestUtils.createOpportunity(acc.Id);
        insert opp;

        formParams.accountId = acc.Id;
        formParams.opportunityId = opp.Id;

        responseFromMethod = serviceHelper.saveReferencesInFormData(formParams, formData, formdataId, response);

        E2EFormData__c updatedRecord = [SELECT E2E_Account_Id__c, E2E_Opportunity_Id__c FROM E2EFormData__c WHERE Id =: formdataId];

        System.assertEquals('Error', responseFromMethod.message);
        System.assertEquals(acc.Id, updatedRecord.E2E_Account_Id__c);
        System.assertEquals(opp.Id, updatedRecord.E2E_Opportunity_Id__c);
    }

    @IsTest
    public static void processAddressTest() {
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        E2EFormParams formParams = E2EFormRuTestUtils.createDefaultFormParams();
        formParams.legalAddressSpark = 'legal';
        PPR_API_CreateClientTestDataBuilder builder = new PPR_API_CreateClientTestDataBuilder();
        builder.baseRequest(null, null, null);

        PPR_API_ServiceImplHelper helper = new PPR_API_ServiceImplHelper();
        helper.processAddresses(builder.build().customerInfo.addresses, formParams, formData);
        System.assertEquals(formParams.legalAddressSpark, formData.E2E_Legal_Address__c);
        System.assertEquals(formParams.legalAddressSpark, formData.E2E_Post_Address__c);
        System.assertEquals(formParams.legalAddressSpark, formParams.companyLegalAddress);
        System.assertEquals(formParams.legalAddressSpark, formParams.postalAddress);

        builder.appendAddress(new List<String>{'Billing'});
        helper.processAddresses(builder.build().customerInfo.addresses, formParams, formData);
        System.assertEquals('Первомайское', formData.E2E_Billing_City__c);
        System.assertEquals('Первомайское', formData.E2E_Shipping_City__c);

        builder.appendAddress(new List<String>{'Shipping'});
        helper.processAddresses(builder.build().customerInfo.addresses, formParams, formData);
        System.assertEquals('Первомайское', formData.E2E_Billing_City__c);
        System.assertEquals('6', formData.E2E_Shipping_House__c);

        builder.clean().baseRequest(null, null, null).appendAddress(new List<String>{'Shipping'});
        helper.processAddresses(builder.build().customerInfo.addresses, formParams, formData);
        System.assertEquals(formParams.legalAddressSpark, formData.E2E_Legal_Address__c);
        System.assertEquals('6', formData.E2E_Shipping_House__c);
    }

    @IsTest
    public static void processAddressTest2() {
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        E2EFormParams formParams = E2EFormRuTestUtils.createDefaultFormParams();
        formParams.legalAddressSpark = 'legal';
        PPR_API_CreateClientTestDataBuilder builder = new PPR_API_CreateClientTestDataBuilder();
        builder.baseRequest(null, null, null);

        PPR_API_ServiceImplHelper helper = new PPR_API_ServiceImplHelper();
        helper.processAddresses(builder.build().customerInfo.addresses, formParams, account);
        System.assertEquals(formParams.citySpark, account.BillingCity);
        System.assertEquals(formParams.citySpark, account.ShippingCity);

        account.BillingCountry = null;
        account.ShippingCountry = null;
        builder.appendAddress(new List<String>{'Billing'});
        helper.processAddresses(builder.build().customerInfo.addresses, formParams, account);
        System.assertEquals('Первомайское', account.BillingCity);
        System.assertEquals('Первомайское', account.ShippingCity);

        account.BillingCountry = null;
        account.ShippingCountry = null;
        builder.appendAddress(new List<String>{'Shipping'});
        helper.processAddresses(builder.build().customerInfo.addresses, formParams, account);
        System.assertEquals('Первомайское', account.BillingCity);
        System.assertEquals('659607', account.ShippingPostalCode);

        account.BillingCountry = null;
        account.ShippingCountry = null;
        builder.clean().baseRequest(null, null, null).appendAddress(new List<String>{'Shipping'});
        helper.processAddresses(builder.build().customerInfo.addresses, formParams, account);
        System.assertEquals(formParams.citySpark, account.BillingCity);
        System.assertEquals('Первомайское', account.ShippingCity);
    }
}
