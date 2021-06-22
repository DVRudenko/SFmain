public without sharing class PPR_API_ServiceImplHelper {

    private E2EFormRuDao e2eFormRuDao = new E2EFormRuDaoImpl();

    public String createStreetString(String street, String house, String apartment, String housePrefix) {
        String streetString = '';
        if (String.isNotBlank(street)) {
            streetString += street + ' ';
        }

        if (String.isNotBlank(house)) {
            if (String.isNotBlank(housePrefix)) {
                streetString += housePrefix + ' ';
            }
            streetString += house;
        }
        
        if (String.isNotBlank(apartment)) {
            streetString += ' ' + apartment;
        }

        return streetString;
    }

    public PPR_API_ResponseBody saveReferencesInFormData(E2EFormParams formParams, E2EFormData__c formData, String formdataId, PPR_API_ResponseBody response) {
        try {
            if (formData != null) {
                e2eFormRuDao.updateFormData(formData);
            } else {
                updateFormDataReferences(formParams, formdataId);
            }
        } catch (Exception e) {
            updateFormDataReferences(formParams, formdataId);
        }

        return (response != null) ? response : ResponseBodyBuilder.constructPPR_API_ResponseBodyError('FormData updation error');
    }

    private void updateFormDataReferences(E2EFormParams formParams, String formdataId) {
        if (String.isNotBlank(formdataId) && formParams != null) {
            E2EFormData__c initialFormData = e2eFormRuDao.getFormDataById(formDataId);
            if (formParams.accountId != null) {
                initialFormData.E2E_Account_Id__c = formParams.accountId;
            }

            if (formParams.opportunityId != null) {
                initialFormData.E2E_Opportunity_Id__c = formParams.opportunityId;
            }

            e2eFormRuDao.updateFormData(initialFormData);
        }
    }

    /*******************************************************************************
    *  Name            : processAddresses
    *  Summary         : process objects so that the address is saved from either source to target
    *  Parameters      : PPR_API_CreateClientRequest.AddressObj source, E2EFormParams altSource, E2EFormData__c target
    *  Returns         : -
    ******************************************************************************/
    public void processAddresses(List<PPR_API_CreateClientRequest.AddressObj> source, E2EFormParams altSource, E2EFormData__c target) {
        Boolean requestHasLegalAddress = false;
        Boolean requestHasPostalAddress = false;
        if (source != null) {
            for (PPR_API_CreateClientRequest.AddressObj address : source) {
                if (address.type.contains('Billing')) {
                    String fullStreet = createStreetString(address.street, address.house, address.apartment, null);
                    target.E2E_Legal_Address__c = address.city + ' ' + address.state + ' ' + fullStreet;
                    target.E2E_Billing_Country__c = address.country;
                    target.E2E_Billing_City__c = address.city;
                    target.E2E_Billing_State__c = address.state;
                    target.E2E_Billing_Str__c = address.street;
                    target.E2E_Billing_House__c = address.house;
                    target.E2E_Billing_Code__c = address.zipCode;
                    target.E2E_Billing_Apartment__c = address.apartment;
                    requestHasLegalAddress = true;
                }
                
                if (address.type.contains('Shipping')) {
                    String fullStreet = createStreetString(address.street, address.house, address.apartment, null);
                    target.E2E_Post_Address__c = address.city + ' ' + address.state + ' ' + fullStreet;
                    target.E2E_Shipping_Country__c = address.country;
                    target.E2E_Shipping_City__c = address.city;
                    target.E2E_Shipping_State__c = address.state;
                    target.E2E_Shipping_Str__c = address.street;
                    target.E2E_Shipping_House__c = address.house;
                    target.E2E_Shipping_Code__c = address.zipCode;
                    target.E2E_Shipping_Apartment__c = address.apartment;
                    requestHasPostalAddress = true;
                }
            }
        }

        if ( !requestHasLegalAddress) {
            target.E2E_Legal_Address__c = altSource.legalAddressSpark;
            target.E2E_Billing_Country__c = GlobalUtils.FleetcorCountries.Russia.name();
            target.E2E_Billing_City__c = altSource.citySpark;
            target.E2E_Billing_State__c = altSource.regionSpark;
            target.E2E_Billing_Str__c = altSource.streetSpark;
            target.E2E_Billing_House__c = altSource.buildingSpark;
            target.E2E_Billing_Code__c = altSource.postCodeSpark;
            target.E2E_Billing_Apartment__c = altSource.roomSpark;
        }

        if ( !requestHasPostalAddress) {
            target.E2E_Post_Address__c = target.E2E_Legal_Address__c;
            target.E2E_Shipping_Country__c = target.E2E_Billing_Country__c;
            target.E2E_Shipping_City__c = target.E2E_Billing_City__c;
            target.E2E_Shipping_State__c = target.E2E_Billing_State__c;
            target.E2E_Shipping_Str__c = target.E2E_Billing_Str__c;
            target.E2E_Shipping_House__c = target.E2E_Billing_House__c;
            target.E2E_Shipping_Code__c = target.E2E_Billing_Code__c;
            target.E2E_Shipping_Apartment__c = target.E2E_Billing_Apartment__c;
        }

        altSource.companyLegalAddress = target.E2E_Legal_Address__c;
        altSource.postalAddress = String.isNotBlank(target.E2E_Post_Address__c) ? target.E2E_Post_Address__c : target.E2E_Legal_Address__c;
    }

    /*******************************************************************************
    *  Name            : processAddresses
    *  Summary         : process objects so that the address is saved from either source to target
    *  Parameters      : PPR_API_CreateClientRequest.AddressObj source, E2EFormParams altSource, Account target
    *  Returns         : -
    ******************************************************************************/
    public void processAddresses(List<PPR_API_CreateClientRequest.AddressObj> source, E2EFormParams altSource, Account target) {
        Boolean requestHasLegalAddress = false;
        Boolean requestHasPostalAddress = false;
        if (source != null) {
            for (PPR_API_CreateClientRequest.AddressObj address : source) {
                if (target.BillingCountry == null && address.type.contains('Billing')) {
                    target.BillingCountry = address.country;
                    target.BillingCity = address.city;
                    target.Region__c = address.state;
                    target.BillingStreet = createStreetString(address.street, address.house, address.apartment, 'дом');
                    target.BillingPostalCode = address.zipCode;
                    requestHasLegalAddress = true;
                }
                if (target.ShippingCountry == null && address.type.contains('Shipping')) {
                    target.ShippingCountry = address.country;
                    target.ShippingCity = address.city;
                    target.ShippingStreet = createStreetString(address.street, address.house, address.apartment, 'дом');
                    target.ShippingPostalCode = address.zipCode;
                    requestHasPostalAddress = true;
                }
            }
        }

        if ( !requestHasLegalAddress) {
            target.BillingCountry = GlobalUtils.FleetcorCountries.Russia.name();
            target.BillingCity = altSource.citySpark;
            target.Region__c = altSource.regionSpark;
            target.BillingPostalCode = altSource.postCodeSpark;
            target.BillingStreet = createStreetString(altSource.streetSpark, altSource.buildingSpark, altSource.roomSpark, 'дом');
        }

        if ( !requestHasPostalAddress) {
            target.ShippingCountry = target.BillingCountry;
            target.ShippingCity = target.BillingCity;
            target.ShippingPostalCode = target.BillingPostalCode;
            target.ShippingStreet = target.BillingStreet;
        }
    }
}
