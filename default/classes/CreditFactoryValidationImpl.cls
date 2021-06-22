public virtual class CreditFactoryValidationImpl implements CreditFactoryValidation {
    protected CreditFactoryCompany internalCFCompany;
    protected CreditFactoryCompany externalCFCompany;
    protected CreditFactoryCompany externalAdditionalCFCompany;
    protected String lastValidationName;


    /*******************************************************************************
    *  Summary         : Set Credit Factory Company object.
    *  CreatedDate     : 01/08/2019 by Anton Buzak
    *  Parameters      : opportunity - opportunity - full data structure
    *  Returns         : -
    ******************************************************************************/
    public void setInternalCFCompany(Map<String, Object> creditFactoryDataMap) {
        try {
            this.internalCFCompany = new CreditFactoryCompany();
            String creditFactoryJsonData = JSON.serialize(creditFactoryDataMap);
            this.internalCFCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryJsonData, CreditFactoryCompany.class);
        } catch (Exception e) {
            throw new CreditFactoryException('Set Internal Credit Factory Company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Get Credit Factory Company   
    *  Created         : 19/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public CreditFactoryCompany getInternalCFCompany() {
        return this.internalCFCompany;
    }
    
    
    /*******************************************************************************
    *  Summary         : Set data from Credit System to Credit Factory Company object.
    *  CreatedDate     : 14/11/2019 by Anton Buzak
    *  Parameters      : externalCFCompaniesList - companies from Credit Systems
    *  Returns         : -
    ******************************************************************************/
    public void setExternalCreditFactoryCompanies(List<CreditFactoryCompany> externalCFCompaniesList) {
        try {
            this.externalCFCompany = new CreditFactoryCompany();
            this.externalCFCompany.creditFactoryContacts = new List<CreditFactoryCompany.CreditFactoryContact>();
            for (CreditFactoryCompany company : externalCFCompaniesList) {
                if (company.recordType == 'Default') {
                    this.externalCFCompany = company;
                } else {
                    this.externalAdditionalCFCompany = company;
                }
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Set External Credit Factory Companies failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }
    
    
    protected virtual String returnCreditSystemName() {
        return null;
    }


    /*******************************************************************************
    *  Summary         : Do validates based on accepted list of validations names
    *  CreatedDate     : 23/12/2019 by Anton Buzak
    *  Parameters      : validationsNamesList - list of validations names, 
    *                    validateAll - variable that identify if we need to perform all validations from the list in case of error
    *  Returns         : map of validation results
    ******************************************************************************/
    public Map<String, CreditFactoryValidationItem> validate(List<String> validationsNamesList, Boolean validateAll) {
        try {
            Map<String, CreditFactoryValidationItem> validationItemsMap = new Map<String, CreditFactoryValidationItem>();
            if (! validateAll) {
                validationItemsMap.putAll(doValidationsUntilError(validationsNamesList));
            } else {
                validationItemsMap.putAll(doAllValidations(validationsNamesList));
            }

            return validationItemsMap;
        } catch (Exception e) {
            throw new CreditFactoryException('Validation process failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Failed Validation: ' + this.lastValidationName);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Do validations until the first error
    *  Created         : 05/03/2020
    *  Parameters      : validationsNamesList - list of validations names
    *  Returns         : map of validation results
    ******************************************************************************/
    protected Map<String, CreditFactoryValidationItem> doValidationsUntilError(List<String> validationsNamesList) {
        Map<String, CreditFactoryValidationItem> validationItemsMap = new Map<String, CreditFactoryValidationItem>();
        for (String validationName : validationsNamesList) {
            this.lastValidationName = validationName;
            if (validationName == 'Profile') {
                validationItemsMap.put(validationName, validateProfile());
            } 
            else if (validationName == 'ClosedOpportunity') {
                validationItemsMap.put(validationName, validateClosedOpportunity());
            } 
            else if (validationName == 'BlackList') {
                validationItemsMap.put(validationName, validateBlackList());
            } 
            else if (validationName == 'DesiredPaymentDetails') {
                validationItemsMap.put(validationName, validateDesiredPaymentDetails());
            }
            else if (validationName == 'Invoicing') {
                validationItemsMap.put(validationName, validateInvoicing());
            }
            else if (validationName == 'ProcessedOpportunity') {
                validationItemsMap.put(validationName, validateProcessedOpportunity());
            }
            else if (validationName == 'NumberOfCards') {
                validationItemsMap.put(validationName, validateNumberOfCards());
            }
            else if (validationName == 'SepaAttachment') {
                validationItemsMap.put(validationName, validateSepaAttachment());
            }
            else if (validationName == 'Order') {
                validationItemsMap.put(validationName, validateOrder());
            }
            else if (validationName == 'UnavailableReport') {
                validationItemsMap.put(validationName, validateUnavailableReport());
            }
            else if (validationName == 'Duplicates') {
                validationItemsMap.put(validationName, searchDuplicates());
            }

            if (! validationItemsMap.get(validationName).passed) break;
        }
        
        return validationItemsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Do all validations
    *  Created         : 05/03/2020
    *  Parameters      : validationsNamesList - list of validations names
    *  Returns         : map of validation results
    ******************************************************************************/
    protected Map<String, CreditFactoryValidationItem> doAllValidations(List<String> validationsNamesList) {
        Map<String, CreditFactoryValidationItem> validationItemsMap = new Map<String, CreditFactoryValidationItem>();
        for (String validationName : validationsNamesList) {
            this.lastValidationName = validationName;
            if (validationName == 'CompanyName') {
                validationItemsMap.put(validationName, validateCompanyName());
            }
            else if (validationName == 'Address') {
                validationItemsMap.put(validationName, validateAddress());
            }
            else if (validationName == 'TaxId') {
                validationItemsMap.put(validationName, validateTaxId());
            }
            else if (validationName == 'VatNumber') {
                validationItemsMap.put(validationName, validateVatNumber());
            }
            else if (validationName == 'TradeRegisterNumber') {
                validationItemsMap.put(validationName, validateTradeRegisterNumber());
            }
            else if (validationName == 'Contact') {
                validationItemsMap.putAll(validateContact());
            }
            else if (validationName == 'RequestStatus') {
                validationItemsMap.put(validationName, validateRequestStatus());
            }
            else if (validationName == 'AgeOfCompany') {
                validationItemsMap.put(validationName, validateAgeOfCompany());
            }
            else if (validationName == 'ObligationOverdue') {
                validationItemsMap.put(validationName, validateObligationOverdue());
            }
            else if (validationName == 'LostOpportunities') {
                validationItemsMap.put(validationName, validateLostOpportunities());
            }
            else if (validationName == 'EmailRisk') {
                validationItemsMap.put(validationName, validateEmailRisk());
            }
            else if (validationName == 'BlackList') {
                validationItemsMap.put(validationName, validateBlackList());
            }
            else if (validationName == 'MandateType') {
                validationItemsMap.put(validationName, validateMandateType());
            }
            else if (validationName == 'SwiftBic') {
                validationItemsMap.put(validationName, validateSwiftBic());
            }
            else if (validationName == 'Duplicates') {
                validationItemsMap.put(validationName, searchDuplicates());
            }
            else if (validationName == 'ConsentSigner') {
                validationItemsMap.put(validationName, validateConsentSigner());
            }
            else if (validationName == 'LegalForm') {
                validationItemsMap.put(validationName, validateLegalForm());
            }
            else if (validationName == 'EmptyAddress') {
                validationItemsMap.put(validationName, validateEmptyAddress());
            }
            else if (validationName == 'CompanyStatus') {
                validationItemsMap.put(validationName, validateCompanyStatus());
            }
            else if (validationName == 'PaymentMethod') {
                validationItemsMap.put(validationName, validatePaymentMethod());
            }
            else if (validationName == 'NegativeInformation') {
                validationItemsMap.put(validationName, validateNegativeInformation());
            }
        }
        
        return validationItemsMap;
    }
    
    
    /*******************************************************************************
	*  Summary         : Check Opportunity Stage
	*  CreatedDate     : 23/12/2019 by Anton Buzak
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
    protected CreditFactoryValidationItem validateProfile() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if (Credit_Factory_User_Profile__c.getInstance(profileName) == null)  {
            validationItem.passed = false;
            validationItem.description = 'Your profile doesn\'t have access to Credit Factory.';
        } else {
            validationItem.passed = true;
        }
        
        return validationItem;
    }


    /*******************************************************************************
	*  Summary         : Check Opportunity Stage
	*  CreatedDate     : 09/08/2019 by Anton Buzak
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
    protected CreditFactoryValidationItem validateClosedOpportunity() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
    	if (this.internalCFCompany.stage == 'Closed Won' || this.internalCFCompany.stage == 'Closed Lost' || 
                this.internalCFCompany.stage == 'CreditCheck abgelehnt' || this.internalCFCompany.stage == 'CreditCheck rejected') {
    		validationItem.passed = false;
            validationItem.description = 'Opportunity was already closed.';
    	} else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
	*  Summary         : Find Company in Black List
	*  CreatedDate     : 09/08/2019 by Anton Buzak
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
    protected CreditFactoryValidationItem validateBlackList() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        String street = this.internalCFCompany.registeredStreet;
        String name = this.internalCFCompany.name;
        String city = this.internalCFCompany.registeredCity;
        String postalCode = this.internalCFCompany.registeredPostCode;
        
        String visitorId = this.internalCFCompany.visitorId;
        String country = this.internalCFCompany.country.substringBefore('-');
        String countryCode = this.internalCFCompany.countryCode.substring(0, 2);

        List<String> contactsEmailsSet = new List<String>();
        List<String> contactsNamesSet = new List<String>();
        List<String> contactsPhonesSet = new List<String>();
        for (CreditFactoryCompany.CreditFactoryContact contact : this.internalCFCompany.creditFactoryContacts) {
            if (contact.relation == 'Account') {
                if (contact.email != null) {
                    contactsEmailsSet.add(contact.email.toUpperCase());
                }

                String firstName = '';
                if (contact.firstName != null) {
                    firstName = contact.firstName;
                }

                String lastName = '';
                if (contact.lastName != null) {
                    lastName = contact.lastName;
                }

                String firstAndLastName = (firstName.toUpperCase() + ' ' + lastName.toUpperCase()).removeStart(' ');
                contactsNamesSet.add(firstAndLastName);
                String lastAndFirstName = (lastName.toUpperCase() + ' ' + firstName.toUpperCase()).removeEnd(' ');
                contactsNamesSet.add(lastAndFirstName);

                if (contact.phone != null) {
                    contactsPhonesSet.add(contact.phone);
                }
                if (contact.mobilePhone != null) {
                    contactsPhonesSet.add(contact.mobilePhone);
                }
            }
        }

        String taxId = this.internalCFCompany.taxId;
        String vatNumber = this.internalCFCompany.vatNumber;
        String tradeRegisterNumber = this.internalCFCompany.tradeRegisterNumber;
        String iban = this.internalCFCompany.iban;

        List<Credit_Black_List_Company__c> blackListCompaniesList = [
                SELECT Customer_Full_Name__c, Trade_Register_Number__c, VATReg_Number__c, Reg_Address_Address_Lines__c, 
                	  	Reg_Address_City__c, Reg_Address_Country__c, Reg_Address_Zip_Code__c, Primary_Phone__c, Primary_Email__c, 
                	  	Primary_Contact__c, IBAN__c, Name, Comment__c, TAX_ID__c, IP_Address__c
                FROM Credit_Black_List_Company__c
                WHERE Customer_Id__c != null AND Customer_Id__c = :countryCode AND
                	  	((Customer_Full_Name__c != null AND Customer_Full_Name__c = :name) OR 
                	  	(TAX_ID__c != null AND TAX_ID__c = :taxId) OR
                      	(VATReg_Number__c != null AND VATReg_Number__c = :vatNumber) OR
                      	(Trade_Register_Number__c != null AND Trade_Register_Number__c = :tradeRegisterNumber) OR
                            (((Reg_Address_Address_Lines__c != null AND Reg_Address_Address_Lines__c = :street) OR Reg_Address_Address_Lines__c = null) AND
                            ((Reg_Address_City__c != null AND Reg_Address_City__c = :city) OR (Reg_Address_Zip_Code__c != null AND Reg_Address_Zip_Code__c = :postalCode))) OR
                      	(Primary_Phone__c != null AND Primary_Phone__c IN :contactsPhonesSet) OR 
                      	(Primary_Email__c != null AND Primary_Email__c IN :contactsEmailsSet) OR
                      	(Primary_Contact__c != null AND Primary_Contact__c IN :contactsNamesSet) OR
                      	(IBAN__c != null AND IBAN__c = :iban) OR
                        (IP_Address__c != null AND IP_Address__c = :visitorId))
                LIMIT 1];

        if ( ! blackListCompaniesList.isEmpty()) {
            String description = returnBlackListException(blackListCompaniesList.get(0), name, taxId, vatNumber, tradeRegisterNumber, 
                                                          street, city, postalCode, country, contactsEmailsSet, 
                                                          contactsNamesSet, contactsPhonesSet, iban, visitorId);
            validationItem.passed = false;
            validationItem.description = description;

        } else {
            validationItem.passed = true;
        }

        return validationItem;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return exception if black list validation failed
    *  CreatedDate     : 12/09/2019 by Anton Buzak
    *  Parameters      : blackListCompany - black list company, 
                         name - company name, 
                         taxId - company tax id, 
                         vatNumber - company vat number, 
                         tradeRegisterNumber - company 
                         trade registered number, 
                         street - company street, 
                         city - company city, 
                         postalCode - company postal code, 
                         country - company country,
                         contactsEmailsSet - contacts emails, 
                         contactsNamesSet - contact names, 
                         contactsPhonesSet - contact phones, 
                         iban - company iban, 
                         visitor id - ip address of user
    *  Returns         : Exception
    ******************************************************************************/
    private static String returnBlackListException(Credit_Black_List_Company__c blackListCompany, 
                                                   String name, 
                                                   String taxId, 
                                                   String vatNumber, 
                                                   String tradeRegisterNumber, 
                                                   String street, 
                                                   String city, 
                                                   String postalCode, 
                                                   String country, 
                                                   List<String> contactsEmailsSet, 
                                                   List<String> contactsNamesSet, 
                                                   List<String> contactsPhonesSet, 
                                                   String iban, 
                                                   String visitorId) {
        String description = '<strong>BLACK LIST.</strong> Company found in black list. Please refer to credit. ';
        description = description + 'Click <a target="_blank" href="/' + blackListCompany.Id + '">here</a>.';

        description += '<br/><br/>Matched fields:<br/><ul>';
        if (blackListCompany.Customer_Full_Name__c != null && blackListCompany.Customer_Full_Name__c == name) {
            description += '<li>Account Name: ' + name + '</li>';
        }

        if (blackListCompany.TAX_ID__c != null && blackListCompany.TAX_ID__c == taxId) {
            description += '<li>Tax Id: ' + taxId + '</li>';
        }

        if (blackListCompany.VATReg_Number__c != null && blackListCompany.VATReg_Number__c == vatNumber) {
            description += '<li>VAT Number: ' + vatNumber + '</li>';
        }

        if (blackListCompany.Trade_Register_Number__c != null && blackListCompany.Trade_Register_Number__c == tradeRegisterNumber) {
            description += '<li>Trade Register Number: ' + tradeRegisterNumber + '</li>';
        }
        
        if ((blackListCompany.Reg_Address_Address_Lines__c != null && blackListCompany.Reg_Address_Address_Lines__c == street || blackListCompany.Reg_Address_Address_Lines__c == null) && 
                (blackListCompany.Reg_Address_City__c != null && blackListCompany.Reg_Address_City__c == city ||
                blackListCompany.Reg_Address_Zip_Code__c != null && blackListCompany.Reg_Address_Zip_Code__c == postalCode)) {
            description += '<li>Registered Address:<br/>' + 
                (street != null ? street : '') + '<br/>' + 
                (postalCode != null ? postalCode : '') + ' ' + (city != null ? city : '') + '<br/>' + 
                country + '</li>';
        }
        
        if (blackListCompany.Primary_Phone__c != null && contactsPhonesSet.contains(blackListCompany.Primary_Phone__c)) {
            description += '<li>Contact Phone Number: ' + blackListCompany.Primary_Phone__c + '</li>';
        }
        
        if (blackListCompany.Primary_Email__c != null && contactsEmailsSet.contains(blackListCompany.Primary_Email__c.toUpperCase())) {
            description += '<li>Contact Email: ' + blackListCompany.Primary_Email__c + '</li>';
        }

        if (blackListCompany.Primary_Contact__c != null && contactsNamesSet.contains(blackListCompany.Primary_Contact__c.toUpperCase())) {
            description += '<li>Contact Name: ' + blackListCompany.Primary_Contact__c + '</li>';
        }

        if (blackListCompany.IBAN__c != null && blackListCompany.IBAN__c == iban) {
            description += '<li>IBAN: ' + iban + '</li>';
        }
        
        if (blackListCompany.IP_Address__c != null && blackListCompany.IP_Address__c == visitorId) {
            description += '<li>IP Address: ' + visitorId + '</li>';
        }

        description += '<ul/>';
        description += '<!--^^';
        if (blackListCompany.Comment__c != null) {
            description += blackListCompany.Comment__c + '. ';
        }

        description += 'Black List record Id: ' + blackListCompany.Id;

        description += '^^-->';

        return description;
    }
    

    /*******************************************************************************
    *  Summary         : Check desired Billing period and desire Payment terms  
    *  CreatedDate     : 05/09/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected virtual CreditFactoryValidationItem validateDesiredPaymentDetails() {
        return null;
    }
    
    
    /*******************************************************************************
	*  Summary         : Check for e-invoicing or paper invoice   
	*  Created         : 22/04/2020
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/
	protected virtual CreditFactoryValidationItem validateInvoicing() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
		if (! (this.internalCFCompany.eInvoice == true && this.internalCFCompany.paperInvoice == false)) {
            validationItem.passed = false;
            validationItem.description = 'It is not possible to send invoices by mail with payment terms of 7 days.';
		}
        else {
            validationItem.passed = true;
        }
        
        return validationItem;
	}


    /*******************************************************************************
    *  Summary         : Check Opportunity "Processed by" field    
    *  CreatedDate     : 05/09/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected CreditFactoryValidationItem validateProcessedOpportunity() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
    	if (this.internalCFCompany.processedBy != null && this.internalCFCompany.processedBy != 'Autoprocessed by E2E' && 
    			! (this.internalCFCompany.processedBy == 'Autoprocessed by Sales' && this.internalCFCompany.stage == 'Pending Sales – Deposit')) {
            validationItem.passed = false;
            validationItem.description = 'Your Opportunity has already received a Credit Decision or is in the ongoing Manual Review with the Credit Team.';
    	} else {
            validationItem.passed = true;
        }

        return validationItem;
    }
    
    
    /*******************************************************************************
    *  Summary         : Check Opportunity "Processed by" field    
    *  CreatedDate     : 05/09/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected CreditFactoryValidationItem validateNumberOfCards() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        Integer numberOfRelatedCards = 0;
        if (this.internalCFCompany.cards != null) {
            numberOfRelatedCards = this.internalCFCompany.cards.size();
        }
        else if (this.internalCFCompany.lineItems != null) {
            for (CreditFactoryCompany.LineItem lineItem : this.internalCFCompany.lineItems) {
                if (this.internalCFCompany.offerItems != null &&
                        (lineItem.productFamily == 'SHELL' || lineItem.productFamily == 'Lotos' || lineItem.productFamily == 'CCS')) {
                    for (CreditFactoryCompany.OfferItem offerItem : this.internalCFCompany.offerItems) {
                        if (offerItem.productId == lineItem.id) {
                            numberOfRelatedCards ++;
                        }
                    }
                }
            }
        }
        
        Integer numberOfCards = 0;
        if (this.internalCFCompany.numberOfCards != null) {
            numberOfCards = Integer.valueOf(this.internalCFCompany.numberOfCards);
        }
        
        if (numberOfRelatedCards != numberOfCards && this.internalCFCompany.customPin != true) {
            validationItem.passed = false;
            validationItem.description = '"Number of cards" field in the Opportunity is different from number of cards linked to the Opportunity.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check Attachment with name "SEPA"
    *  CreatedDate     : 10/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected virtual CreditFactoryValidationItem validateSepaAttachment() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        Boolean isSEPAAttachmentExist = false;
        Boolean isSEPAFileExist = false;
    	if (this.internalCFCompany.paymentMethod == 'Lastschrift' && this.internalCFCompany.sepaRequestApproved != true && this.internalCFCompany.directDebitFormAvailable == true) {
            if (this.internalCFCompany.attachments != null) {
                for (CreditFactoryCompany.CreditFactoryAttachment attachment : this.internalCFCompany.attachments) {
                    if (attachment.name.containsIgnoreCase('sepa')) {
                        isSEPAAttachmentExist = true;
                        break;
                    }
                }
            }
            if (this.internalCFCompany.files != null) {
                for (CreditFactoryCompany.CreditFactoryFile file : this.internalCFCompany.files) {
                    if (file.title.containsIgnoreCase('sepa')) {
                        isSEPAFileExist = true;
                        break;
                    }
               }
            }

            if (isSEPAAttachmentExist || isSEPAFileExist) {
                validationItem.passed = true;
            }
            else {
                validationItem.passed = false;
                validationItem.description = 'Please attach SEPA form to the Opportunity to launch Credit Factory.';
            }
    	}
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check Payment Method
    *  CreatedDate     : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected virtual CreditFactoryValidationItem validatePaymentMethod() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
    	if (this.internalCFCompany.paymentMethod == 'Banküberweisung') {
            validationItem.passed = false;
            validationItem.description = 'Opportunity cannot be closed automatically with Payment Method Bank Transfer.';
    	}
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check Opportunity "Processed by" field    
    *  CreatedDate     : 08/05/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected virtual CreditFactoryValidationItem validateOrder() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.cfStage == 'Pending Credit Report - Order was sent') {
            validationItem.passed = false;
            validationItem.description = 'Additional attempts to download a Credit Factory report will be performed automatically till the end of the day. ' + 
                'Once a report is downloaded you will receive an email notification.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check CF stage
    *  CreatedDate     : 15/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected CreditFactoryValidationItem validateUnavailableReport() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.cfStage == 'Credit Report not available') {
            validationItem.passed = false;
            validationItem.description = 'Credit Report is not available. Please refer to Credit.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Search duplicates in Salesforce database 
    *  CreatedDate     : 05/09/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected CreditFactoryValidationItem searchDuplicates() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        String exceptionString = searchOpportunityDuplicates(this.internalCFCompany);
        exceptionString += searchAccountDuplicates(this.internalCFCompany);
        exceptionString += searchContactDuplicates(this.internalCFCompany);

        if (String.isNotEmpty(exceptionString)) {
            validationItem.passed = false;
            validationItem.description = exceptionString;
        } 
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }
    
    
    /*******************************************************************************
    *  Summary         : Search duplicates in Opportunities
    *  CreatedDate     : 05/09/2019 by Anton Buzak
    *  Parameters      : creditFactoryCompany - validated company
    *  Returns         : Exception
    ******************************************************************************/
    private static String searchOpportunityDuplicates(CreditFactoryCompany creditFactoryCompany) {
        String opportunitiesQuery = 'SELECT Name, IBAN__c, RecordType.Name, StageName, Gruende_verloren__c, Credit_System_Number__c, Creditreform_Nummer__c, AccountId' +
                ' FROM Opportunity' + 
                ' WHERE (RecordType.Name = \'Euroshell\' OR RecordType.Name = \'Euroshell Starts\')' + ((creditFactoryCompany.country != null) ? ' AND ' + 
                    (creditFactoryCompany.country.contains('Belgium') ? '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' : 
                    (creditFactoryCompany.country.contains('Switzerland') ? '(Account.BillingCountry = \'Switzerland-DE\' OR Account.BillingCountry = \'Switzerland-FR\'' + 
                    ' OR Account.BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' + clearFieldSOQL(creditFactoryCompany.country) + '\'')) : '') + ' AND (' + 
                    ((creditFactoryCompany.opportunityName != '[nicht vorhanden]' && creditFactoryCompany.opportunityName != 'New Inbound Lead') ? 'Name = \'' + 
                    clearFieldSOQL(creditFactoryCompany.opportunityName) + '\'' : '') + ((creditFactoryCompany.iban != null && creditFactoryCompany.iban != 'n/a' && 
                    creditFactoryCompany.iban != 'X' && creditFactoryCompany.iban != 'x' && creditFactoryCompany.iban != 'XX' && 
                    creditFactoryCompany.iban != 'xx' && ! creditFactoryCompany.iban.containsIgnoreCase('XXX') && creditFactoryCompany.iban != 'DE000') ? 
                    ' OR IBAN__c = \'' + clearFieldSOQL(creditFactoryCompany.iban) + '\'' : '') + ((creditFactoryCompany.creditSystemNumber != null) ? 
                    ' OR Credit_System_Number__c = \'' + clearFieldSOQL(creditFactoryCompany.creditSystemNumber) + '\' OR Creditreform_Nummer__c = \'' + 
                    clearFieldSOQL(creditFactoryCompany.creditSystemNumber) + '\'' : '') +
                ') LIMIT 100';

        List<Opportunity> duplicateOpportunitiesList = Database.query(opportunitiesQuery);
        String exceptionString = '';
        if (! duplicateOpportunitiesList.isEmpty()) {
            Integer counter = 0;
            for (Opportunity opportunity : duplicateOpportunitiesList) {
                if ((opportunity.Name == creditFactoryCompany.opportunityName || opportunity.IBAN__c == creditFactoryCompany.iban ||
                        opportunity.Credit_System_Number__c == creditFactoryCompany.creditSystemNumber || 
                        opportunity.Creditreform_Nummer__c == creditFactoryCompany.creditSystemNumber) &&
                        ! (opportunity.StageName == 'Closed Lost' && opportunity.Gruende_verloren__c != 'Refused Credit') &&
                        opportunity.Id != creditFactoryCompany.opportunityId && opportunity.AccountId != creditFactoryCompany.accountId) {
                    if (! exceptionString.contains('<br/>Duplicate Opportunities found:<br/>')) {
                        exceptionString += '<br/>Duplicate Opportunities found:<br/>';
                    }
                    exceptionString += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + 
                        '">' + opportunity.Name + '</a>' + '<br/>';
                    counter ++;
                    if (counter == 5) {
                        break;
                    }
                }
            }
        }

        return exceptionString;
    }


    /*******************************************************************************
    *  Summary         : Search duplicates in Accounts
    *  CreatedDate     : 05/09/2019
    *  Parameters      : creditFactoryCompany - validated company 
    *  Returns         : Exception
    ******************************************************************************/
    private static String searchAccountDuplicates(CreditFactoryCompany creditFactoryCompany) {
        String accountsQuery = 'SELECT Name, Steuernummer__c, Umsatzsteuer_ID__c, RecordType.Name, BillingCity, BillingStreet' +
                ' FROM Account' + 
                ' WHERE RecordType.Name = \'Endkunde\'' + ((creditFactoryCompany.country != null) ? ' AND ' + 
                    (creditFactoryCompany.country.contains('Belgium') ? '(BillingCountry = \'Belgium-NL\' OR BillingCountry = \'Belgium-FR\')' : 
                    (creditFactoryCompany.country.contains('Switzerland') ? '(BillingCountry = \'Switzerland-DE\' OR BillingCountry = \'Switzerland-FR\'' + 
                    ' OR BillingCountry = \'Switzerland-IT\')' : 'BillingCountry = \'' + clearFieldSOQL(creditFactoryCompany.country) + '\'')) : '') + 
                    ' AND (' + ((creditFactoryCompany.name != '[nicht vorhanden]' && creditFactoryCompany.name != 'New Inbound Lead') ? 'Name = \'' + 
                    clearFieldSOQL(creditFactoryCompany.name) + '\'' : '') + (creditFactoryCompany.vatNumber != null ? ' OR Umsatzsteuer_ID__c = \'' + 
                    clearFieldSOQL(creditFactoryCompany.vatNumber) + '\'' : '') + (creditFactoryCompany.taxId != null &&
                    creditFactoryCompany.taxId != 'nicht bekannt' && creditFactoryCompany.taxId != 'unbekannt' &&
                    creditFactoryCompany.taxId != '0' ? ' OR Steuernummer__c = \'' + clearFieldSOQL(creditFactoryCompany.taxId) + '\'' : '') + 
                    (creditFactoryCompany.registeredCity != null && creditFactoryCompany.registeredStreet != null ? ' OR (BillingCity = \'' + 
                    clearFieldSOQL(creditFactoryCompany.registeredCity) + '\' AND BillingStreet = \'' + clearFieldSOQL(creditFactoryCompany.registeredStreet) + '\')' : '') +
                ') LIMIT 6';

        String exceptionString = '';
        List<Account> duplicateAccountsList = Database.query(accountsQuery);
        if (! duplicateAccountsList.isEmpty()) {
            Integer counter = 0;
            for (Account account : duplicateAccountsList) {
                if ((account.Name == creditFactoryCompany.name || account.Steuernummer__c == creditFactoryCompany.taxId ||
                        account.Umsatzsteuer_ID__c == creditFactoryCompany.vatNumber || account.BillingCity == creditFactoryCompany.registeredCity && 
                        account.BillingStreet == creditFactoryCompany.registeredStreet) && account.Id != creditFactoryCompany.accountId) {
                    if (! exceptionString.contains('<br/>Duplicate Accounts found:<br/>')) {
                        exceptionString += '<br/>Duplicate Accounts found:<br/>';
                    }
                    exceptionString += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + account.Id + '">' + account.Name + '</a>' + '<br/>';
                    if (counter == 5) {
                        break;
                    }
                }
            }
        }

        return exceptionString;
    }


    /*******************************************************************************
    *  Summary         : Search duplicates in Contacts    
    *  CreatedDate     : 05/09/2019
    *  Parameters      : creditFactoryCompany - validated company 
    *  Returns         : Exception
    ******************************************************************************/
    private static String searchContactDuplicates(CreditFactoryCompany creditFactoryCompany) {
        Set<Id> currentContactsIdsSet = new Set<Id>();
        Set<String> contactEmailsSet = new Set<String>();
        Set<String> contactPhonesSet = new Set<String>();
        Set<String> contactFirstNamesSet = new Set<String>();
        Set<String> contactLastNamesSet = new Set<String>();
        Set<String> contactDataSet = new Set<String>();
        for (CreditFactoryCompany.CreditFactoryContact contact : creditFactoryCompany.creditFactoryContacts) {
            if (contact.relation == 'OpportunityContactRole') {
                currentContactsIdsSet.add(contact.id);
                String contactDataString = '';
                if (contact.firstName != null) {
                    contactFirstNamesSet.add(clearFieldSOQL(contact.firstName));
                    contactDataString += clearFieldSOQL(contact.firstName) + ' ';
                }

                contactDataString += clearFieldSOQL(contact.lastName) + ' ';
                contactLastNamesSet.add(clearFieldSOQL(contact.lastName));
                if (contact.email != null) {
                    contactEmailsSet.add(clearFieldSOQL(contact.email));
                    contactDataString += clearFieldSOQL(contact.email.substringAfter('@'));
                }

                contactDataSet.add(contactDataString);

                if (contact.phone != null) {
                    contactPhonesSet.add(clearFieldSOQL(contact.phone));
                }
            }
        }

        String contactsQuery = 'SELECT FirstName, LastName, Phone, Email, Name, Account.RecordType.Name' +
                ' FROM Contact' + 
                ' WHERE Account.RecordType.Name = \'Endkunde\'' + ((creditFactoryCompany.country != null) ? ' AND ' + 
                    (creditFactoryCompany.country.contains('Belgium') ? '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' : 
                    (creditFactoryCompany.country.contains('Switzerland') ? '(Account.BillingCountry = \'Switzerland-DE\' OR ' + 
                    'Account.BillingCountry = \'Switzerland-FR\' OR Account.BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' + 
                    clearFieldSOQL(creditFactoryCompany.country) + '\'')) : '') + ' AND (' + (! contactEmailsSet.isEmpty() ? 
                    'Email IN :contactEmailsSet OR ' : '') + (! contactPhonesSet.isEmpty() ? 'Phone IN :contactPhonesSet OR ' : '') +
                    ((! contactEmailsSet.isEmpty() && ! contactFirstNamesSet.isEmpty()) ? '(FirstName IN :contactFirstNamesSet AND LastName IN :contactLastNamesSet)' : '');
        contactsQuery = contactsQuery.removeEnd('OR ') + ') LIMIT 20';
        String exceptionString = '';
        if (! contactsQuery.endsWith('() LIMIT 20')) {
            List<Contact> duplicateContactsList = Database.query(contactsQuery);
            if (! duplicateContactsList.isEmpty()) {
                Integer counter = 0;
                for (Contact contact : duplicateContactsList) {
                    if ((contactEmailsSet.contains(contact.Email) || contactPhonesSet.contains(contact.Phone) || 
                            (contact.Email != null && contactDataSet.contains(contact.FirstName + ' ' + contact.LastName + ' ' + contact.Email.substringAfter('@')))) &&
                            ! currentContactsIdsSet.contains(contact.Id)
                            ) {
                        if (! exceptionString.contains('<br/>Duplicate Contacts found:<br/>')) {
                            exceptionString += '<br/>Duplicate Contacts found:<br/>';
                        }

                        exceptionString += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + contact.Id + 
                            '">' + contact.Name + '</a>' + '<br/>';
                        counter ++;
                        if (counter == 5) {
                            break;
                        }
                    }
                }
            }
        }

        return exceptionString;
    }
    
    
    /*******************************************************************************
    *  Summary         : remove illegal characters from field for SOQL    
    *  CreatedDate     : 12/09/2019 by Anton Buzak
    *  Parameters      : String field - field for SOQL
    *  Returns         : clear soql
    ******************************************************************************/
    private static String clearFieldSOQL(String field) {
        if (field != null && field.contains('\'')) field = field.replace('\'', '\\\'');
        return field;
    }

    
    /*******************************************************************************
	*  Summary         : Check that company name from Credit System is the same as Salesforce company name
	*  CreatedDate     : 14/11/2019
	*  ModifiedDate    : -
	*  Returns         : validation result
	******************************************************************************/
	protected virtual CreditFactoryValidationItem validateCompanyName() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (areStringsEquals(this.internalCFCompany.name, this.externalCFCompany.name)) {
            validationItem.passed = true;
        } 
        else {
            validationItem.passed = false;
            validationItem.description = 'Account Name and ' + returnCreditSystemName() + ' Name mismatch';
        }

		return validationItem;
	}
    

    /*******************************************************************************
	*  Summary         : Check that company name from Credit System is the same as Salesforce company name
	*  CreatedDate     : 22/09/2020 by Anton Buzak
	*  Parameters      : -
    *  Returns         : validation result
	******************************************************************************/
    protected virtual CreditFactoryValidationItem validateAddress() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        CreditFactoryValidationItem validationEmptyAddress = validateEmptyAddress();
        if (validationEmptyAddress != null && validationEmptyAddress.passed == false) {
            validationItem.passed = true;
            return validationItem;
        }

        String externalStreetAndHouseNumber = joinStreetAndHouseNumber(this.externalCFCompany.street, this.externalCFCompany.houseNumber);
        String externalHouseNumberAndStreet = joinStreetAndHouseNumber(this.externalCFCompany.houseNumber, this.externalCFCompany.street);

        if (! ((isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalStreetAndHouseNumber) ||
                isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalHouseNumberAndStreet)) &&
                (isCityValid(this.internalCFCompany.registeredCity, this.internalCFCompany.shippingCity, this.externalCFCompany.city)) &&
                (isPostalCodeValid(this.internalCFCompany.registeredPostCode, this.internalCFCompany.shippingPostCode, this.externalCFCompany.postCode)))) {
            validationItem.passed = false;
            validationItem.description = 'Account Billing and Shipping Addresses should be the same as ' + returnCreditSystemName() + ' address';
        } else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Joint street and house number into 1 string
    *  CreatedDate     : 21/12/2019
    *  Parameters      : addressItem1 - street or house number, addressItem2 - street or house number
    *  Returns         : string street + house number
    ******************************************************************************/
    protected String joinStreetAndHouseNumber(String addressItem1, String addressItem2) {
        String streetAndHouseNumber = (addressItem1 != null ? addressItem1 : '') + ' ' + (addressItem2 != null ? addressItem2 : '');
        streetAndHouseNumber = streetAndHouseNumber.removeStart(' ').removeEnd(' ');
        return streetAndHouseNumber;
    }


    /*******************************************************************************
	*  Summary         : Check if street and house numbers are the same.
	*  CreatedDate     : 21/11/2019  by Anton Buzak
	*  Parameters      : internalRegisteredStreet - salesforce registered street, internalShippingStreet - salesforce shipping street, externalStreet - street from web service
	*  Returns         : validation result
	******************************************************************************/
	protected Boolean isStreetAndHouseNumberValid(String internalRegisteredStreet, String internalShippingStreet, String externalStreetAndHouseNumber) {
		Boolean isValid = false;
		if (areStringsEquals(internalRegisteredStreet, internalShippingStreet) &&
			    areStringsEquals(internalRegisteredStreet, externalStreetAndHouseNumber)) {
			isValid = true;
		}
	    return isValid;
	}


	/*******************************************************************************
	*  Summary         : Check if cities are the same.
	*  CreatedDate     : 21/11/2019 by Anton Buzak
	*  Parameters      : internalRegisteredCity - salesforce registered city, internalShippingCity - salesforce shipping city, externalCity - city from web service
	*  Returns         : validation result
	******************************************************************************/
	protected Boolean isCityValid(String internalRegisteredCity, String internalShippingCity, String externalCity) {
		Boolean isValid = false;
		if (areStringsEquals(internalRegisteredCity, internalShippingCity) &&
			    areStringsEquals(internalRegisteredCity, externalCity)) {
			isValid = true;
		}
	    return isValid;
	}


	/*******************************************************************************
	*  Summary         : Check if postal codes are the same.
	*  CreatedDate     : 21/11/2019 by Anton Buzak
	*  Parameters      : internalRegisteredPostalCode - salesforce registered postal code,
                         internalShippingPostalCode - salesforce shipping postal code,
                         externalPostalCode - postal code from web service
	*  Returns         : validation result
	******************************************************************************/
	protected Boolean isPostalCodeValid(String internalRegisteredPostalCode, String internalShippingPostalCode, String externalPostalCode) {
		Boolean isValid = false;
		if (areStringsEquals(internalRegisteredPostalCode, internalShippingPostalCode) &&
			    areStringsEquals(internalRegisteredPostalCode, externalPostalCode)) {
			isValid = true;
		}
	    return isValid;
	}


    /*******************************************************************************
	*  Summary         : Compare Credit System and Salesforce tax ids
	*  CreatedDate     : 14/01/2020
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
	protected CreditFactoryValidationItem validateTaxId() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
		if (externalCFCompany.taxId != null && ! areStringsEquals(externalCFCompany.taxId, internalCFCompany.taxId)) {
            validationItem.passed = false;
            validationItem.description = 'Account Tax ID and ' + returnCreditSystemName() + ' Tax ID mismatch.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
	}


    /*******************************************************************************
	*  Summary         : Compare Credit System and Salesforce vat numbers
	*  CreatedDate     : 11/08/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
	protected CreditFactoryValidationItem validateVatNumber() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
		if (externalCFCompany.vatNumber != null && ! areStringsEquals(externalCFCompany.vatNumber, internalCFCompany.vatNumber)) {
            validationItem.passed = false;
            validationItem.description = 'Account VAT number and ' + returnCreditSystemName() + ' VAT number mismatch.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
	}


    /*******************************************************************************
	*  Summary         : Compare Credit System and Salesforce trade register numbers
	*  CreatedDate     : 14/01/2020
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
	protected virtual CreditFactoryValidationItem validateTradeRegisterNumber() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
		if (externalCFCompany.tradeRegisterNumber != null && ! areStringsEquals(externalCFCompany.tradeRegisterNumber, internalCFCompany.tradeRegisterNumber)) {
            validationItem.passed = false;
            validationItem.description = 'Account Trade Register Number and ' + returnCreditSystemName() + ' Trade Register Number mismatch.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
	}


    /*******************************************************************************
	*  Summary         : Check that contact from Crif the same as Salesforce
	*  CreatedDate     : 13/01/2020
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
	protected Map<String, CreditFactoryValidationItem> validateContact() {
        Set<String> contactsLastNamesSet = new Set<String>();
        Set<String> contactsFirstAndLastNamesSet = new Set<String>();
        Set<String> contactsEmailsDomainsSet = new Set<String>();
        Set<String> contactsPhonesSet = new Set<String>();
        for (CreditFactoryCompany.CreditFactoryContact contact : this.internalCFCompany.creditFactoryContacts) {
            if (contact.relation == 'AccountContactRelation') {
                String firstName = '';
                if (contact.firstName != null) {
                    firstName = replaceSpecificCharacters(contact.firstName).toUpperCase().replace('’', '\'');
                }

                String lastName = replaceSpecificCharacters(contact.lastName).toUpperCase().replace('’', '\'');
                contactsLastNamesSet.add(lastName);
                contactsFirstAndLastNamesSet.add((firstName + ' ' + lastName).removeStart(' '));
                contactsFirstAndLastNamesSet.add((lastName + ' ' + firstName).removeEnd(' '));

                if (contact.email != null) {
                    contactsEmailsDomainsSet.add(contact.email.substringAfterLast('@').toUpperCase());
                }

                if (contact.phone != null && contact.phone.length() >= 6) {
                    String phone = contact.phone;
                    contactsPhonesSet.add(phone.substring(phone.length() - 6, phone.length()));
                }
            }
        }

        String primaryContactRole = '';
        for (CreditFactoryCompany.CreditFactoryContact contact : this.internalCFCompany.creditFactoryContacts) {
            if (contact.relation == 'OpportunityContactRole') {
                if (contact.isPrimary == true) {
                    primaryContactRole = contact.role;
                }
            }
        }

        Boolean isContactExists = false;
        List<CreditFactoryCompany.CreditFactoryContact> contactsToCheckList = new List<CreditFactoryCompany.CreditFactoryContact>();
        contactsToCheckList.addAll(this.externalCFCompany.creditFactoryContacts);
        if (this.externalAdditionalCFCompany != null && this.externalAdditionalCFCompany.creditFactoryContacts != null) {
            contactsToCheckList.addAll(this.externalAdditionalCFCompany.creditFactoryContacts);

        }

        for (CreditFactoryCompany.CreditFactoryContact contact : contactsToCheckList) {
        	if (contact.name != null) {
	        	for (String lastName : contactsLastNamesSet) {
					if (replaceSpecificCharacters(contact.name).toUpperCase().replace('\u00a0', ' ').contains(lastName)) {
						isContactExists = true;
					}
				}
	        }
        }

        for (String firstAndLastName : contactsFirstAndLastNamesSet) {
            if (this.externalCFCompany.name != null && firstAndLastName == replaceSpecificCharacters(this.externalCFCompany.name).toUpperCase().replace('’', '\'')) {
                isContactExists = true;
            }
        }

        String companyEmailDomain = '';
		if (this.externalCFCompany.email != null) {
		    companyEmailDomain = this.externalCFCompany.email.substringAfterLast('@').toUpperCase();
		}

		String companyPhone = '';
		if (this.externalCFCompany.phone != null && this.externalCFCompany.phone.length() >= 6) {
		    companyPhone = this.externalCFCompany.phone.substring(this.externalCFCompany.phone.length() - 6, this.externalCFCompany.phone.length());
		}

		String companyMobile = '';
		if (this.externalCFCompany.mobile != null && this.externalCFCompany.mobile.length() >= 6) {
		    companyMobile = this.externalCFCompany.mobile.substring(this.externalCFCompany.mobile.length() - 6, this.externalCFCompany.mobile.length());
		}

        String additionalCompanyPhone = '';
        if (this.externalAdditionalCFCompany != null && this.externalAdditionalCFCompany.phone != null && this.externalAdditionalCFCompany.phone.length() >= 6) {
            additionalCompanyPhone = this.externalAdditionalCFCompany.phone.substring(this.externalAdditionalCFCompany.phone.length() - 6, this.externalAdditionalCFCompany.phone.length());
        }

        String additionalCompanyMobile = '';
        if (this.externalAdditionalCFCompany != null && this.externalAdditionalCFCompany.mobile != null && this.externalAdditionalCFCompany.mobile.length() >= 6) {
            additionalCompanyMobile = this.externalAdditionalCFCompany.mobile.substring(this.externalAdditionalCFCompany.mobile.length() - 6, this.externalAdditionalCFCompany.mobile.length());
        }

        CreditFactoryValidationItem contactValidationItem = new CreditFactoryValidationItem();
        CreditFactoryValidationItem contactRoleValidationItem = new CreditFactoryValidationItem();
    	if (! isContactExists && ! (contactsEmailsDomainsSet.contains(companyEmailDomain) || contactsPhonesSet.contains(companyPhone) || contactsPhonesSet.contains(companyMobile) ||
                contactsPhonesSet.contains(additionalCompanyPhone) || contactsPhonesSet.contains(additionalCompanyMobile) ||
                (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') && this.internalCFCompany.contactRoleConfirmationCall != null)) {
    		if (this.externalCFCompany.creditFactoryContacts.isEmpty() && (this.externalAdditionalCFCompany == null ||
                    this.externalAdditionalCFCompany != null && externalAdditionalCFCompany.creditFactoryContacts != null && externalAdditionalCFCompany.creditFactoryContacts.isEmpty())) {
                contactValidationItem.description = 'No directors information for this company';
        	}
            else {
                contactValidationItem.description = returnCreditSystemName() + ' Contact person doesn\'t exist in Account\'s Contacts';
	        }

            contactValidationItem.passed = false;
            if (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') {
                contactRoleValidationItem.description = 'Please choose call with contact role confirmation.';
                contactRoleValidationItem.passed = false;
            }
        }
        else {
            contactValidationItem.passed = true;
            contactRoleValidationItem.passed = true;
        }

        Map<String, CreditFactoryValidationItem> validationItemsMap = new Map<String, CreditFactoryValidationItem>();
        validationItemsMap.put('Contact', contactValidationItem);
        validationItemsMap.put('ContactRole', contactRoleValidationItem);
        return validationItemsMap;
    }


    protected virtual String replaceSpecificCharacters(String stringToReplace) {
        return stringToReplace;
    }


    /*******************************************************************************
	*  Summary         : check errors in request
	*  CreatedDate     : 14/01/2020
	*  Parameters      : externalCFCompany - Credit System Company
	*  Returns         : validation result
	******************************************************************************/
	protected CreditFactoryValidationItem validateRequestStatus() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (externalCFCompany.requestStatus != 'OK') {
            validationItem.passed = false;
            validationItem.description = 'Error with request status. Please refer to credit.';
		}
        else {
            validationItem.passed = true;
        }

		return validationItem;
	}


    /*******************************************************************************
	*  Summary         : check age of company
	*  CreatedDate     : 14/01/2020
	*  Parameters      : externalCFCompany - Credit System Company
	*  Returns         : validation result
	******************************************************************************/
	protected CreditFactoryValidationItem validateAgeOfCompany() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
		if (externalCFCompany.dateOfFoundation != null) {
			Date dateOfFoundation = Date.newInstance(Integer.valueOf(externalCFCompany.dateOfFoundation.substring(0, 4)),
				Integer.valueOf(externalCFCompany.dateOfFoundation.substring(4, 6)), Integer.valueOf(externalCFCompany.dateOfFoundation.substring(6, 8)));
			if (dateOfFoundation.monthsBetween(Date.today()) < 18) {
				validationItem.passed = false;
                validationItem.description = 'Age of company is too small.';
			}
            else {
                validationItem.passed = true;
            }
		}
        else {
            validationItem.passed = true;
        }

		return validationItem;
	}


    /*******************************************************************************
	*  Summary         : check payment history with obligation overdue
	*  CreatedDate     : 14/01/2020
	*  Parameters      : externalCFCompany - Credit System Company
	*  Returns         : validation result
	******************************************************************************/
	protected CreditFactoryValidationItem validateObligationOverdue() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
		if (externalCFCompany.obligationOverdue == true) {
            validationItem.passed = false;
            validationItem.description = 'Сompany has an overdue obligation.';
		}
        else {
            validationItem.passed = true;
        }

		return validationItem;
	}


    /*******************************************************************************
	*  Summary         : Check for Lost Opportunities relates to current Opportunity's
						 Account or its Contacts
	*  CreatedDate     : 02/04/2018
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
	protected CreditFactoryValidationItem validateLostOpportunities() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
		List<Opportunity> relatedOpportunitiesList = [
		        SELECT StageName, Gruende_verloren__c, RecordType.Name, Credit_Stage__c
		        FROM Opportunity
		        WHERE AccountId = :internalCFCompany.accountId];
		List<Opportunity> opportunitiesToCheckList = new List<Opportunity>();
		for (Opportunity opportunity : relatedOpportunitiesList) {
			opportunitiesToCheckList.add(opportunity);
		}

		Set<Id> relatedContactsIdsSet = new Set<Id>();
		for (CreditFactoryCompany.CreditFactoryContact contact : this.internalCFCompany.creditFactoryContacts) {
            if (contact.relation == 'AccountContactRelation') {
                relatedContactsIdsSet.add(contact.id);
            }
		}

		if (! relatedContactsIdsSet.isEmpty()) {
            List<OpportunityContactRole> contactRolesList = [
                    SELECT Opportunity.StageName, Opportunity.Gruende_verloren__c, Opportunity.RecordType.Name, Opportunity.Credit_Stage__c
                    FROM OpportunityContactRole
                    WHERE ContactId IN :relatedContactsIdsSet];
            for (OpportunityContactRole contactRole : contactRolesList) {
                opportunitiesToCheckList.add(contactRole.Opportunity);
            }
        }

        validationItem.passed = true;
		for (Opportunity opportunity : opportunitiesToCheckList) {
			String stage;
			if (opportunity.RecordType.Name == 'Lotos') {
				stage = opportunity.Credit_Stage__c;
			}
            else {
				stage = opportunity.StageName;
			}

			if (stage == 'CreditCheck abgelehnt' || stage == 'CreditCheck rejected' || (stage == 'Closed Lost' &&
					opportunity.Gruende_verloren__c == 'Refused Credit')) {
                validationItem.passed = false;
                validationItem.description = 'Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.';
                break;
			}
		}

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check fround risk by Email
    *  CreatedDate     : 14/01/2020
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected CreditFactoryValidationItem validateEmailRisk() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        Integer year;
        Integer month;
        Integer day;
        Date dateOfFoundation;
        if (this.externalCFCompany.dateOfFoundation != null && this.externalCFCompany.dateOfFoundation.length() >= 8) {
            if (!this.externalCFCompany.dateOfFoundation.substring(0, 4).contains('.')) {
                year = Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(0, 4));
                if (!(this.externalCFCompany.dateOfFoundation.substring(4, 6).contains('.') || this.externalCFCompany.dateOfFoundation.substring(4, 6).contains('-'))) {
                    month = Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(4, 6));
                    day = Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(6, 8));
                }
                else {
                    month = Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(5, 7));
                    day = Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(8, 10));
                }
            }
            else {
                year = Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(6, 10));
                month = Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(3, 5));
                day = Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(0, 2));
            }

            dateOfFoundation = Date.newInstance(year, month, day);
        }
        else if (this.externalAdditionalCFCompany != null && this.externalAdditionalCFCompany.dateOfFoundation != null) {
            year = Integer.valueOf(this.externalAdditionalCFCompany.dateOfFoundation.substring(0, 4));
            month = Integer.valueOf(this.externalAdditionalCFCompany.dateOfFoundation.substring(5, 7));
            day = Integer.valueOf(this.externalAdditionalCFCompany.dateOfFoundation.substring(8, 10));

            dateOfFoundation = Date.newInstance(year, month, day);
        }

    	if ((this.externalCFCompany.emailRisk == 'Review' || this.externalCFCompany.emailRisk == 'High' || this.externalCFCompany.emailRisk == 'Very High') &&
				(this.externalCFCompany.emailExists == 'No' || this.externalCFCompany.domainExists == 'No' || this.externalCFCompany.uniqueHits != null &&
				Decimal.valueOf(this.externalCFCompany.uniqueHits) > 1 || String.isEmpty(this.externalCFCompany.domainDate) || Date.valueOf(this.externalCFCompany.domainDate).monthsBetween(Date.today()) > 6 ||
				dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) > 6)) {
            validationItem.passed = false;
            validationItem.description = 'Contact Person has a high email risk. Please refer to Credit';
    	}
        else {
            validationItem.passed = true;
        }

    	return validationItem;
    }


    /*******************************************************************************
	*  Summary         : Check Mandate Type
	*  CreatedDate     : 11/08/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
    protected virtual CreditFactoryValidationItem validateMandateType() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.paymentMethod == 'Lastschrift' && this.internalCFCompany.directDebitMandateType == 'Core') {
            String riskCategory;
            if (this.externalCFCompany.classRating == null) {
                riskCategory = 'High';
            }
            else if (this.externalCFCompany.classRating == '1') {
                riskCategory = 'Low';
            }
            else if (this.externalCFCompany.classRating == '2') {
                riskCategory = 'Medium';
            }
            else if (this.externalCFCompany.classRating == '3' || this.externalCFCompany.classRating == '4') {
                riskCategory = 'High';
            }
            else if (this.externalCFCompany.classRating == '5') {
                riskCategory = 'Very';
            }

            String appropriateMandateType = CreditFactoryGlobalUtils.returnAppropriateMandateType(this.internalCFCompany.country,
                                                                                                          riskCategory,
                                                                                          this.internalCFCompany.totalConsumption);

            if (appropriateMandateType == 'B2B') {
                validationItem.passed = false;
                validationItem.description = 'Please change the Direct Debit Type Mandate from Core to B2B because the Customer has high Credit risk.';
            }
            else {
                validationItem.passed = true;
            }
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
	*  Summary         : Check Swift Bic
	*  CreatedDate     : 11/08/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
    protected CreditFactoryValidationItem validateSwiftBic() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
    	if (this.internalCFCompany.swiftBic != this.internalCFCompany.requestedSwiftBic && this.internalCFCompany.paymentMethod == 'Lastschrift') {
    		validationItem.passed = false;
            validationItem.description = 'Entered BIC is invalid. Please note that your Customer will need to re- confirm SEPA form with correct bank details.';
    	} else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check that consent signer is one of the credit factory contacts
    *  CreatedDate     : 14/01/2020
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected CreditFactoryValidationItem validateConsentSigner() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
		Map<String, DateTime> dsRecipientsMap = new Map<String, DateTime>();
        if (this.internalCFCompany.documentsStatusesList != null) {
            for (CreditFactoryCompany.DocumentStatus documentStatus : this.internalCFCompany.documentsStatusesList) {
                if (documentStatus.name == 'Zgoda na weryfikację (DocuSign).pdf' && documentStatus.status == 'Completed' && documentStatus.completedDate >= Date.today().addDays(-60)) {
                    for (CreditFactoryCompany.DocumentRecipient recipient : documentStatus.documentRecipients) {
                        String dsSigner = replaceSpecificCharacters(recipient.name.toUpperCase().replace('’', '\''));
                        if (! dsRecipientsMap.containsKey(dsSigner) || documentStatus.completedDate > dsRecipientsMap.get(dsSigner)) {
                            dsRecipientsMap.put(dsSigner, documentStatus.completedDate);
                        }
                    }
                }
            }
        }

        Datetime consentGrantDateTime;
		for (CreditFactoryCompany.CreditFactoryContact contact : this.externalCFCompany.creditFactoryContacts) {
			String creditFactoryContact = replaceSpecificCharacters(contact.name.toUpperCase().replace('’', '\''));
			if (dsRecipientsMap.containsKey(creditFactoryContact)) {
				if (consentGrantDateTime == null || dsRecipientsMap.get(creditFactoryContact) > consentGrantDateTime) {
					consentGrantDateTime = dsRecipientsMap.get(creditFactoryContact);
				}
			}
		}

		if (consentGrantDateTime != null) {
			validationItem.passed = true;
            validationItem.parametersMap = new Map<String, Object>();
            validationItem.parametersMap.put('ConsentGrantDate', consentGrantDateTime);
		}
        else {
			validationItem.passed = false;
            validationItem.description = 'Consent not signed by the right person in the last 60 days. Please refer to credit.';
		}

		return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check physical person without date of foundation
    *  CreatedDate     : 07/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected CreditFactoryValidationItem validateLegalForm() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
		if (this.externalCFCompany.dateOfFoundation == null && this.externalCFCompany.legalForm == 'Physical person') {
			validationItem.passed = false;
            validationItem.description = 'Opportunity is Closed as lost. Requester is a physical person, not a company.';
            validationItem.parametersMap = new Map<String, Object>();
            validationItem.parametersMap.put('ReasonLost', 'Not a legal entity');
		}
        else {
			validationItem.passed = true;
		}

		return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check empty address
    *  CreatedDate     : 16/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected virtual CreditFactoryValidationItem validateEmptyAddress() {
        return null;
    }


    /*******************************************************************************
    *  Summary         : Check company status
    *  CreatedDate     : 17/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected CreditFactoryValidationItem validateCompanyStatus() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.externalCFCompany.status != null && ! this.externalCFCompany.status.equalsIgnoreCase('Active')) {
            validationItem.passed = false;
            validationItem.description = 'Company is inactive.';
            validationItem.parametersMap = new Map<String, Object>();
            validationItem.parametersMap.put('ReasonLost', 'Refused Credit');
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check negative information
    *  CreatedDate     : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected virtual CreditFactoryValidationItem validateNegativeInformation() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
    	if (this.externalCFCompany.negativeInformation != null) {
            validationItem.passed = false;
            validationItem.description = 'Negative Information: ' + this.externalCFCompany.negativeInformation;
    	}
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }

    
    /*******************************************************************************
    *  Summary         : Check that string variables have the same values
    *  CreatedDate     : 14/11/2019 by Anton Buzak
    *  Parameters      : string1 - the first string to compare, string2 - the second string to compare
    *  Returns         : validation result
    ******************************************************************************/
    protected Boolean areStringsEquals(String string1, String string2) {
        if (String.isEmpty(string1) && String.isBlank(string2)) {
            return true;
        }
        
        if (string1 == null || string2 == null) {
            return false;
        }

        if (string1.toUpperCase() == string2.toUpperCase()) {
            return true;
        } 
        else {
            return false;
        }
    }
}