public class AllStarMondoFormController {
	public String objectId;
    public Account formAccount {get; set;}
    public Opportunity formOpportunity;    
    public Boolean error {get; set;}
    public String currentStep {get; set;}
    public Boolean showBlockBusinessAddress {get; set;}
    public Boolean showBlockEntityUBO {get; set;}

    public Boolean agreementDataProtection {get; set;}
    public Boolean agreementAuthorityToApply {get; set;} 
    public Boolean agreementTermsAndConditions {get; set;}
    public Boolean agreementEmailMarketing {get; set;}

    public String password {get; set;}
    
    //account
    public String registeredName {get; set;}
    public String tradingName {get; set;}
    public String taxIdNumber {get; set;}
    public String regon {get; set;}
    public String krsNumber {get; set;}
    public String emailAddress {get; set;}   
    public String primaryBusinessNumber {get; set;}
    public String mobile {get; set;}
    public String streetAndHouseNumber {get; set;}
    public String city {get; set;}
    public String postcode {get; set;}

    public String shipStreet {get; set;}
    public String shipCity {get; set;}
    public String shipPostCode {get; set;}
    public String shipCountry {get; set;}

    public String selectedTypeOfOrganization {get; set;}
    public String webAdress {get; set;}
    public String selectedNumberOfEmployees {get; set;}
    public String selectedYearOfRegistration {get; set;}
    public String selectedIndustry {get; set;}

    //opportunity
    public String turnover {get; set;}
    public String numberOfIndividualCards {get; set;}
    public String companyCreditSpend {get; set;}
    //contact   
    public Map<Integer, Representative> repsMap {get; set;}
    public List<Contact> allContactsList;
    //sub accounts
    public Map<Integer, SubAccount> subAccMap {get; set;}
    public List<Account> allSubAccountsList;
 
	
	/*******************************************************************************
	*  Name            : init()
	*  Summary         : initial data for update objects
	*  CreatedDate     : 01/02/2017
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	public void init() {
        try {
            this.currentStep = 'Step 1'; 
            prefillingFormFields();
            if (this.shipStreet != null || this.shipCity != null || this.shipPostCode != null || shipCountry != null) {
                this.showBlockBusinessAddress = false;
            } else {
                this.showBlockBusinessAddress = true;
            }

            if ( ! subAccMap.isEmpty() && subAccMap.get(1).subAccountId != null) {
                this.showBlockEntityUBO = false;
            } else {
                this.showBlockEntityUBO = true;
            } 
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, e.getMessage()));
        }           
    }


    /*******************************************************************************
    *  Name            : initCheckPassword()
    *  Summary         :     
    *  CreatedDate     : 
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    public void initCheckPassword() {
        this.password = '';
        this.objectId = ApexPages.currentPage().getParameters().get('id');
    }

    /*******************************************************************************
    *  Name            : login() 
    *  Summary         : check password
    *  CreatedDate     : 14/04/2017
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference login() {
        List<Account> allAccountsList = [
            SELECT Id, Web_form_password__c
            FROM Account
            WHERE Web_form_password__c = :this.password AND
                  Id = :objectId
            LIMIT 1];

        if (this.password != '') {
            if (! allAccountsList.isEmpty()) {
                PageReference pr = Page.AllStarMondoForm;
                return pr;
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Wprowadzone hasło jest nieprawidłowe'));
                return null;
            }
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Proszę wpisz hasło'));
            return null;
        }   
    }


    /*******************************************************************************
    *  Name            : prefillingFormFields()
    *  Summary         : prefilling form fields when the page loads    
    *  CreatedDate     : 16/02/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void prefillingFormFields() {
        if (objectId != NULL) {
            this.formAccount = [
            SELECT Name, Trading_Name__c, NIP__c, REGON__c, KRS__c, Gesellschaftsform__c, Phone,
                   Mobile_Phone__c, Website, BillingStreet, BillingCity, BillingPostalCode, Country_Text__c, Allstar_Email__c,
                   ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountry, Beschaeftigte__c, Branche_NACE__c, ParentId, Sub_Account_Number__c      
            FROM Account
            WHERE Id = :objectId];
 
            List<Opportunity> formOpportunityList = [
                SELECT Name, AccountId, Umsatz__c,
                 Anzahl_der_Karten__c, Requested_monthly_Company_Credit_Spend__c, CreatedDate,
                       Data_Protection_Act_1998__c, Bevollmaechtigung__c, AGB_Datenschutzhinweise_Richtigkeit__c, Email_Marketing__c
                FROM Opportunity
                WHERE AccountId = :formAccount.Id
                ORDER BY CreatedDate
                LIMIT 1];

            if (! formOpportunityList.isEmpty()) {
                for (Opportunity opp : formOpportunityList) {
                    this.formOpportunity = opp;  
                }
            } 

            // STEP 1
            this.registeredName = formAccount.Name;
            this.tradingName = formAccount.Trading_Name__c;
            this.taxIdNumber = formAccount.NIP__c;
            this.regon = formAccount.REGON__c;
            this.krsNumber = formAccount.KRS__c;
            this.emailAddress = formAccount.Allstar_Email__c;
            this.primaryBusinessNumber = formAccount.Phone;
            this.mobile = formAccount.Mobile_Phone__c;
            this.streetAndHouseNumber = formAccount.BillingStreet;
            this.city = formAccount.BillingCity;
            this.postcode = formAccount.BillingPostalCode;
           
            // Business Trading Address
            this.shipStreet = formAccount.ShippingStreet;
            this.shipCity = formAccount.ShippingCity;
            this.shipPostCode = formAccount.ShippingPostalCode;
            this.shipCountry = formAccount.Country_Text__c;

            // STEP 2
            this.selectedTypeOfOrganization = formAccount.Gesellschaftsform__c;
            this.webAdress = formAccount.Website;     
            this.selectedNumberOfEmployees = formAccount.Beschaeftigte__c;
            this.selectedYearOfRegistration = null;
            this.selectedIndustry = formAccount.Branche_NACE__c;

            if (this.formOpportunity != null) {
                this.turnover = formOpportunity.Umsatz__c;
                this.numberOfIndividualCards = String.valueOf(formOpportunity.Anzahl_der_Karten__c); 
                this.companyCreditSpend = String.valueOf(formOpportunity.Requested_monthly_Company_Credit_Spend__c);
                this.agreementDataProtection = formOpportunity.Data_Protection_Act_1998__c;
                this.agreementAuthorityToApply = formOpportunity.Bevollmaechtigung__c;
                this.agreementTermsAndConditions = formOpportunity.AGB_Datenschutzhinweise_Richtigkeit__c;
                this.agreementEmailMarketing = formOpportunity.Email_Marketing__c;
            } else {
                this.turnover = '';
                this.numberOfIndividualCards = '';
                this.companyCreditSpend = '';
                this.agreementDataProtection = false;
                this.agreementAuthorityToApply = false;
                this.agreementTermsAndConditions = false;
                this.agreementEmailMarketing = false;
            } 
            this.allContactsList = [
                SELECT Id, AccountId, FirstName, MiddleName, LastName, Mother_s_maiden_name__c, Email, AllStar_authorised_signatory__c, AllStar_account_administrator__c,
                       AllStar_UBO__c, Salutation, Position_Funktion__c, Birthdate, PESEL_Nr__c, Phone, MailingCity, MailingStreet, MailingPostalCode, MailingCountry,
                       Country_Text__c
                FROM Contact
                WHERE AccountId = :formAccount.Id 
                LIMIT 10000];  
     
            // STEP 3
            // Representative
            this.repsMap = new Map<Integer, Representative>();
            Integer c = 1;
            if (! allContactsList.isEmpty()) {
                for (Contact contact : allContactsList) { 
                    Representative rep = new Representative();
                    rep.contactId = contact.Id;
                    rep.conAccountId = contact.AccountId;
                    rep.selectedTitle = contact.Salutation;
                    rep.position = contact.Position_Funktion__c;
                    rep.firstName = contact.FirstName;
                    rep.middleName = contact.MiddleName;
                    rep.lastName = contact.LastName;
                    rep.motherMaidenName = contact.Mother_s_maiden_name__c;
                    rep.email = contact.Email;
                    String birthdateString;
                        if (contact.Birthdate != null) {
                            birthdateString = String.valueOf(contact.Birthdate.year()) + '/';
                        if (contact.Birthdate.month() < 10) {
                            birthdateString += '0' + String.valueOf(contact.Birthdate.month()) + '/';
                        } else {
                            birthdateString += String.valueOf(contact.Birthdate.month()) + '/';
                        }
                        if (contact.Birthdate.day() < 10) {
                            birthdateString += '0' + String.valueOf(contact.Birthdate.day());
                        } else {
                            birthdateString += String.valueOf(contact.Birthdate.day());
                        }
                    }
                    rep.birthday = birthdateString;
                    rep.authorisedSignatory = contact.AllStar_authorised_signatory__c;
                    rep.accountAdministrator = contact.AllStar_account_administrator__c;
                    rep.ubo = contact.AllStar_UBO__c;
                    rep.pesel = contact.PESEL_Nr__c;
                    rep.telephoneNumber = contact.Phone;
                    rep.mailingStreet = contact.MailingStreet;
                    rep.mailingCity = contact.MailingCity;
                    rep.mailingPostcode = contact.MailingPostalCode;
                    rep.mailingCountry = contact.Country_Text__c;
                    this.repsMap.put(c, rep);
                    c++;
                }   
            } else {
                    Representative rep = new Representative();
                    this.repsMap.put(c, rep);
                } 

            this.allSubAccountsList = [
                SELECT Id, Name, Trading_Name__c, NIP__c, REGON__c, KRS__c, Gesellschaftsform__c, Phone,
                       Mobile_Phone__c, Website, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, Country_Text__c, Allstar_Email__c, ParentId,
                       ShippingStreet, ShippingCity, ShippingPostalCode, Beschaeftigte__c, Branche_NACE__c, Sub_Account_Number__c
                FROM Account
                WHERE ParentId = :formAccount.Id
                ORDER BY CreatedDate ASC
                LIMIT 50000];

            // SubAccount
            Integer a = 1;
            this.subAccMap = new Map<Integer, SubAccount>();
            if ( ! allSubAccountsList.isEmpty() ) {
                for (Account account : allSubAccountsList) {
                    SubAccount sa = new SubAccount();
                    sa.subAccountId = account.Id;
                    sa.nameSubAcc = account.Name;
                    sa.streetSubAcc = account.BillingStreet;
                    sa.citySubAcc = account.BillingCity;
                    sa.yearOfRegistrationSubAcc = null;
                    sa.postcodeSubAcc = account.BillingPostalCode;
                    sa.countrySubAcc = account.Country_Text__c;
                    sa.accParentId = formAccount.Id;
                    this.subAccMap.put(a, sa);
                    a++;
                }
            } else {
                this.subAccMap.put(1, new SubAccount());
            }
        }        
    }


    /*******************************************************************************
    *  Name            : goToStepOne(), goToStepTwo(), goToStepThree()
    *  Summary         : transition to a necessary step when pressing the button    
    *  CreatedDate     : 15/02/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToStepOne() {
        currentStep = 'Step 1';
    }
    public void goToStepTwo() {
        validationByStepOne();
    }
    public void goToStepThree() {
        validationByStepTwo();
    }


    /*******************************************************************************
    *  Name            : addrep()
    *  Summary         : action for button "Add Representative"    
    *  CreatedDate     : 22/02/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void addRepresentative() {
        Representative rep = new Representative();
        if (repsMap.isEmpty()) {
            this.repsMap.put(1, rep);
        } else {
            this.repsMap.put(this.repsMap.size()+1, rep);
        }    
    }


    /*******************************************************************************
    *  Name            : doDeleteContact() 
    *  Summary         : delete contact    
    *  CreatedDate     : 07/04/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doDeleteContact() {
        String remoteContactNumber = System.currentPageReference().getParameters().get('conToDelete');

        if (! this.repsMap.isEmpty() && remoteContactNumber != null) {
            this.repsMap.remove(Integer.valueOf(remoteContactNumber));
        }       
        Map<Integer, Representative> tempMap = new Map<Integer, Representative>();
        Integer i = 1;
        for (Representative rep : this.repsMap.values()) {
            tempMap.put(i, rep);
            i++;
        }
        this.repsMap = tempMap;
        currentStep = 'Step 3';
    }


    /*******************************************************************************
    *  Name            : addSubAccount()
    *  Summary         : action for button "Add Entity UBO"    
    *  CreatedDate     : 31/03/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void addSubAccount() {
        SubAccount sa = new SubAccount();
        if (subAccMap.isEmpty()) {
            this.subAccMap.put(1, sa);
        } else {
            this.subAccMap.put(this.subAccMap.size()+1, sa);
        }  
    }


    /*******************************************************************************
    *  Name            : doDeleteSubAccount() 
    *  Summary         : delete contact    
    *  CreatedDate     : 07/04/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doDeleteSubAccount() {
        String remoteSubAccNumber = System.currentPageReference().getParameters().get('accToDelete');

        if (! this.subAccMap.isEmpty() && remoteSubAccNumber != null) {
            this.subAccMap.remove(Integer.valueOf(remoteSubAccNumber));
        }       
        Map<Integer, SubAccount> tempMap = new Map<Integer, SubAccount>();
        Integer i = 1;
        for (SubAccount sa : this.subAccMap.values()) {
            tempMap.put(i, sa);
            i++;
        }
        this.subAccMap = tempMap;
        currentStep = 'Step 3';
    }


    /*******************************************************************************
    *  Name            : doUpdateParentAccount()
    *  Summary         : update accounts    
    *  CreatedDate     : 02/03/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateParentAccount() {
        List<Transaction_Field__c> fieldsToUpdateList = new List<Transaction_Field__c>();

        Transaction__c sysTransAccountUpdate = new Transaction__c (Record_Id__c = formAccount.Id, 
                                                                                Object_API__c = 'Account',
                                                                                DML_type__c = 'update', 
                                                                                Processing__c = true);        

        insert sysTransAccountUpdate;
       
        Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Name',
                                                                        Value__c = this.registeredName);
        fieldsToUpdateList.add(stf1);

        Transaction_Field__c stf2 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Trading_Name__c',
                                                                        Value__c = this.tradingName);
        fieldsToUpdateList.add(stf2);

        Transaction_Field__c stf3 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'NIP__c',
                                                                        Value__c = this.taxIdNumber);
        fieldsToUpdateList.add(stf3);

        Transaction_Field__c stf4 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'REGON__c',
                                                                        Value__c = this.regon);
        fieldsToUpdateList.add(stf4);

        Transaction_Field__c stf5 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'KRS__c',
                                                                        Value__c = this.krsNumber);
        fieldsToUpdateList.add(stf5);

        Transaction_Field__c stf6 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Allstar_Email__c',
                                                                        Value__c = this.emailAddress);
        fieldsToUpdateList.add(stf6);

        Transaction_Field__c stf7 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Phone',
                                                                        Value__c = this.primaryBusinessNumber);
        fieldsToUpdateList.add(stf7);

        Transaction_Field__c stf8 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Mobile_Phone__c',
                                                                        Value__c = this.mobile);
        fieldsToUpdateList.add(stf8);

        Transaction_Field__c stf9 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'BillingStreet',
                                                                        Value__c = this.streetAndHouseNumber);
        fieldsToUpdateList.add(stf9);

        Transaction_Field__c stf10 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'BillingCity',
                                                                        Value__c = this.city);
        fieldsToUpdateList.add(stf10);

        Transaction_Field__c stf11 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'BillingPostalCode',
                                                                        Value__c = this.postcode);
        fieldsToUpdateList.add(stf11);


        Transaction_Field__c stf12 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Gesellschaftsform__c',
                                                                        Value__c = this.selectedTypeOfOrganization);
        fieldsToUpdateList.add(stf12);

        Transaction_Field__c stf13 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Website',
                                                                        Value__c = this.webAdress);
        fieldsToUpdateList.add(stf13);

        Transaction_Field__c stf14 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Beschaeftigte__c',
                                                                        Value__c = this.selectedNumberOfEmployees);
        fieldsToUpdateList.add(stf14);

        Transaction_Field__c stf16 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Branche_NACE__c',
                                                                        Value__c = this.selectedIndustry);
        fieldsToUpdateList.add(stf16);

        Transaction_Field__c stf17 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                            API_Field_Name__c = 'AccountSource',
                                                                            Value__c = 'Allstar Mondo Web Long Form');
        fieldsToUpdateList.add(stf17);

        Transaction_Field__c stf18 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                        API_Field_Name__c = 'Sec_Channel_Acc__c',
                                                                        Value__c = 'Inbound');
        fieldsToUpdateList.add(stf18);

        if (this.showBlockBusinessAddress == false) {
            Transaction_Field__c stf19 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                            API_Field_Name__c = 'ShippingStreet',
                                                                            Value__c = this.shipStreet);
            fieldsToUpdateList.add(stf19);

            Transaction_Field__c stf20 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                            API_Field_Name__c = 'ShippingCity',
                                                                            Value__c = this.shipCity);
            fieldsToUpdateList.add(stf20);

            Transaction_Field__c stf21 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                            API_Field_Name__c = 'ShippingPostalCode',
                                                                            Value__c = this.shipPostCode);
            fieldsToUpdateList.add(stf21);

            String countryTemp = returnCorrectCountry(this.shipCountry);
            Transaction_Field__c stf22 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                            API_Field_Name__c = 'ShippingCountry',
                                                                            Value__c = countryTemp);
            fieldsToUpdateList.add(stf22);

            Transaction_Field__c stf23 = new Transaction_Field__c (Transaction__c = sysTransAccountUpdate.Id,
                                                                            API_Field_Name__c = 'Country_Text__c',
                                                                            Value__c = this.shipCountry);
            fieldsToUpdateList.add(stf23);
        }
             
        insert fieldsToUpdateList;
        update sysTransAccountUpdate;
    }


    /*******************************************************************************
    *  Name            : doUpdateSubAccounts()
    *  Summary         : update sub accounts    
    *  CreatedDate     : 03/04/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateSubAccounts() {
        List<Transaction__c> sysTransObjToUpdateList = new List<Transaction__c>();
        List<Transaction_Field__c> fieldsToUpdateList = new List<Transaction_Field__c>();
        List<SubAccount> subAccsToUpdateList = new List<SubAccount>();
        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Account' LIMIT 1].Id;

        for (SubAccount sa : subAccMap.values()) {
            if (sa.subAccountId != null) {
                Transaction__c sysTransSubAccountUpdate = new Transaction__c (Record_Id__c = sa.subAccountId, 
                                                                                Object_API__c = 'Account',
                                                                                DML_type__c = 'update', 
                                                                                Processing__c = true);
                sysTransObjToUpdateList.add(sysTransSubAccountUpdate);
                subAccsToUpdateList.add(sa);
            }
        }

        Integer i = 0; 
        if (! sysTransObjToUpdateList.isEmpty() && this.showBlockEntityUBO == false) {
            insert sysTransObjToUpdateList;
            for (Transaction__c sysTrans : sysTransObjToUpdateList) {
                SubAccount sa = subAccsToUpdateList.get(i);
                
                Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'Name',
                                                                                Value__c = sa.nameSubAcc);
                fieldsToUpdateList.add(stf1);

                Transaction_Field__c stf2 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'BillingStreet',
                                                                                Value__c = sa.streetSubAcc);
                fieldsToUpdateList.add(stf2);

                Transaction_Field__c stf3 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'BillingCity',
                                                                                Value__c = sa.citySubAcc);
                fieldsToUpdateList.add(stf3);

                Transaction_Field__c stf5 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'BillingPostalCode',
                                                                                Value__c = sa.postcodeSubAcc);
                fieldsToUpdateList.add(stf5);

                String countrySubAccTemp = returnCorrectCountry(sa.countrySubAcc);
                Transaction_Field__c stf6 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'BillingCountry',
                                                                                Value__c = countrySubAccTemp);
                fieldsToUpdateList.add(stf6);

                Transaction_Field__c stf7 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'Country_Text__c',
                                                                                Value__c = sa.countrySubAcc);
                fieldsToUpdateList.add(stf7);

                Transaction_Field__c stf8 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'ParentId',
                                                                                Value__c = sa.accParentId);
                fieldsToUpdateList.add(stf8);

                Transaction_Field__c stf9 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'RecordTypeId',
                                                                                Value__c = recordTypeId);
                fieldsToUpdateList.add(stf9);

                Transaction_Field__c stf10 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'AccountSource',
                                                                            Value__c = 'Allstar Mondo Web Long Form');
                fieldsToUpdateList.add(stf10);

                Transaction_Field__c stf11 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'Sec_Channel_Acc__c',
                                                                                Value__c = 'Inbound');
                fieldsToUpdateList.add(stf11);

                i++;
            }
            insert fieldsToUpdateList;
            update sysTransObjToUpdateList;
        }        
    }


    /*******************************************************************************
    *  Name            : doInsertSubAccount()
    *  Summary         : insert sub account    
    *  CreatedDate     : 31/03/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doInsertSubAccount() {
        List<Transaction__c> sysTransObjToInsertList = new List<Transaction__c>();
        List<Transaction_Field__c> fieldsToInsertList = new List<Transaction_Field__c>();
        List<SubAccount> subAccsToInsertList = new List<SubAccount>();
        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Account' LIMIT 1].Id;

        for (SubAccount subAcc : subAccMap.values()) {
            if (subAcc.subAccountId == null) {
                Transaction__c sysTransSubAccInsert = new Transaction__c (Record_Id__c = '', 
                                                                                        Object_API__c = 'Account',
                                                                                        DML_type__c = 'insert', 
                                                                                        Processing__c = true);
                sysTransObjToInsertList.add(sysTransSubAccInsert);
                subAccsToInsertList.add(subAcc);   
            }
        }

        Integer i = 0;
        if (! sysTransObjToInsertList.isEmpty() && this.showBlockEntityUBO == false) {
            insert sysTransObjToInsertList;

            for (Transaction__c sysTrans : sysTransObjToInsertList) {
                SubAccount subAcc = subAccsToInsertList.get(i);

                Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'Name',
                                                                                Value__c = subAcc.nameSubAcc);
                fieldsToInsertList.add(stf1);

                Transaction_Field__c stf2 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'BillingStreet',
                                                                                Value__c = subAcc.streetSubAcc);
                fieldsToInsertList.add(stf2);

                Transaction_Field__c stf3 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'BillingCity',
                                                                                Value__c = subAcc.citySubAcc);
                fieldsToInsertList.add(stf3);

                Transaction_Field__c stf5 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'BillingPostalCode',
                                                                                Value__c = subAcc.postcodeSubAcc);
                fieldsToInsertList.add(stf5);

                String countrySubAccTemp = returnCorrectCountry(subAcc.countrySubAcc);
                Transaction_Field__c stf6 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'BillingCountry',
                                                                                Value__c = countrySubAccTemp);
                fieldsToInsertList.add(stf6);


                Transaction_Field__c stf7 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'Country_Text__c',
                                                                                Value__c = subAcc.countrySubAcc);
                fieldsToInsertList.add(stf7);

                Transaction_Field__c stf8 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'ParentId',
                                                                                Value__c = formAccount.Id);
                fieldsToInsertList.add(stf8);

                Transaction_Field__c stf9 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'RecordTypeId',
                                                                                Value__c = recordTypeId);
                fieldsToInsertList.add(stf9); 

                Transaction_Field__c stf10 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'AccountSource',
                                                                            Value__c = 'Allstar Mondo Web Long Form');
                fieldsToInsertList.add(stf10);

                Transaction_Field__c stf11 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                                API_Field_Name__c = 'Sec_Channel_Acc__c',
                                                                                Value__c = 'Inbound');
                fieldsToInsertList.add(stf11);

                i++;             
            }
            insert fieldsToInsertList; 
            update sysTransObjToInsertList;
        }
    }

    /*******************************************************************************
    *  Name            : doUpdateOpportunity()
    *  Summary         : update opportunity	 
    *  CreatedDate     : 01/02/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateOpportunity() {
        
        Transaction__c sysTransOppUpdate = new Transaction__c (Record_Id__c = formOpportunity.Id, 
                                                                        Object_API__c = 'Opportunity',
                                                                        DML_type__c = 'update', 
                                                                        Processing__c = true);
        insert sysTransOppUpdate;

        // Fields
        List<Transaction_Field__c> fieldsToUpdateList = new List<Transaction_Field__c>();
        Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'Umsatz__c',
                                                                            Value__c = this.turnover);
        fieldsToUpdateList.add(stf1);

        Transaction_Field__c stf2 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'Anzahl_der_Karten__c',
                                                                            Value__c = this.numberOfIndividualCards);
        fieldsToUpdateList.add(stf2);

        Transaction_Field__c stf3 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'Requested_monthly_Company_Credit_Spend__c',
                                                                            Value__c = this.companyCreditSpend);
        fieldsToUpdateList.add(stf3);

        Transaction_Field__c stf4 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'Data_Protection_Act_1998__c',
                                                                            Value__c = String.valueOf(this.agreementDataProtection));
        fieldsToUpdateList.add(stf4);

        Transaction_Field__c stf5 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'Bevollmaechtigung__c',
                                                                            Value__c = String.valueOf(this.agreementAuthorityToApply));
        fieldsToUpdateList.add(stf5);

        Transaction_Field__c stf6 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'AGB_Datenschutzhinweise_Richtigkeit__c',
                                                                            Value__c = String.valueOf(this.agreementTermsAndConditions));
        fieldsToUpdateList.add(stf6);

        Transaction_Field__c stf7 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'Email_Marketing__c',
                                                                            Value__c = String.valueOf(this.agreementEmailMarketing));
        fieldsToUpdateList.add(stf7);

        Transaction_Field__c stf8 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'LeadSource',
                                                                            Value__c = 'Allstar Mondo Web Long Form');
        fieldsToUpdateList.add(stf8);

        Transaction_Field__c stf9 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'Channel__c',
                                                                            Value__c = 'Internet');
        fieldsToUpdateList.add(stf9);

        Transaction_Field__c stf10 = new Transaction_Field__c (Transaction__c = sysTransOppUpdate.Id,
                                                                            API_Field_Name__c = 'Sec_Channel__c',
                                                                            Value__c = 'Inbound');
        fieldsToUpdateList.add(stf10);

        insert fieldsToUpdateList;
        update sysTransOppUpdate;
    }


    /*******************************************************************************
    *  Name            : doInsertOpportunity()
    *  Summary         : insert opportunity  
    *  CreatedDate     : 04/04/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doInsertOpportunity() {
        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Opportunity' LIMIT 1].Id; 

        if (this.companyCreditSpend != '' && this.turnover != '' && 
            this.numberOfIndividualCards != '') {    

            Transaction__c sysTransOppInsert = new Transaction__c (Record_Id__c = '', 
                                                                        Object_API__c = 'Opportunity',
                                                                        DML_type__c = 'insert', 
                                                                        Processing__c = true);
            insert sysTransOppInsert;

            // Fields
            List<Transaction_Field__c> fieldsToInsertList = new List<Transaction_Field__c>();
            Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'Name',
                                                                                Value__c = this.registeredName);
            fieldsToInsertList.add(stf1);

            Transaction_Field__c stf2 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'Umsatz__c',
                                                                                Value__c = this.turnover);
            fieldsToInsertList.add(stf2);

            Transaction_Field__c stf3 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'Anzahl_der_Karten__c',
                                                                                Value__c = this.numberOfIndividualCards);
            fieldsToInsertList.add(stf3);

            Transaction_Field__c stf4 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'Requested_monthly_Company_Credit_Spend__c',
                                                                                Value__c = this.companyCreditSpend);
            fieldsToInsertList.add(stf4);

            Transaction_Field__c stf5 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'AccountId',
                                                                                Value__c = this.formAccount.Id);
            fieldsToInsertList.add(stf5);

            Transaction_Field__c stf6 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                            API_Field_Name__c = 'Data_Protection_Act_1998__c',
                                                                            Value__c = String.valueOf(this.agreementDataProtection));
            fieldsToInsertList.add(stf6);

            Transaction_Field__c stf7 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'Bevollmaechtigung__c',
                                                                                Value__c = String.valueOf(this.agreementAuthorityToApply));
            fieldsToInsertList.add(stf7);

            Transaction_Field__c stf8 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'AGB_Datenschutzhinweise_Richtigkeit__c',
                                                                                Value__c = String.valueOf(this.agreementTermsAndConditions));
            fieldsToInsertList.add(stf8);

            Transaction_Field__c stf9 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'Email_Marketing__c',
                                                                                Value__c = String.valueOf(this.agreementEmailMarketing));
            fieldsToInsertList.add(stf9);

            Transaction_Field__c stf10 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'StageName',
                                                                                Value__c = 'Prospecting');
            fieldsToInsertList.add(stf10);

            String closeDate = String.valueOf(Datetime.now().addDays(14));
            Transaction_Field__c stf11 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'CloseDate',
                                                                                Value__c = closeDate);
            fieldsToInsertList.add(stf11);

            Transaction_Field__c stf12 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'RecordTypeId',
                                                                                Value__c = recordTypeId);
            fieldsToInsertList.add(stf12);

            Transaction_Field__c stf13 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'LeadSource',
                                                                                Value__c = 'Allstar Mondo Web Long Form');
            fieldsToInsertList.add(stf13);

            Transaction_Field__c stf14 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'Channel__c',
                                                                                Value__c = 'Internet');
            fieldsToInsertList.add(stf14);

            Transaction_Field__c stf15 = new Transaction_Field__c (Transaction__c = sysTransOppInsert.Id,
                                                                                API_Field_Name__c = 'Sec_Channel__c',
                                                                                Value__c = 'Inbound');
            fieldsToInsertList.add(stf15);

            insert fieldsToInsertList;
            update sysTransOppInsert;

        }  
    }


    /*******************************************************************************
    *  Name            : doUpdateContacts()
    *  Summary         : update contacts  
    *  CreatedDate     : 28/02/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateContacts() {
        List<Transaction__c> sysTransObjToUpdateList = new List<Transaction__c>();
        List<Transaction_Field__c> fieldsToUpdateList = new List<Transaction_Field__c>();
        List<Representative> contactsToUpdateList = new List<Representative>();
        for (Representative rep : repsMap.values()) {
            if (rep.conAccountId == formAccount.Id) {
                Transaction__c sysTransContactInsert = new Transaction__c (Record_Id__c = rep.contactId, 
                                                                                Object_API__c = 'Contact',
                                                                                DML_type__c = 'update', 
                                                                                Processing__c = true);
                sysTransObjToUpdateList.add(sysTransContactInsert);
                contactsToUpdateList.add(rep);
            }
        }
            
        Integer i = 0;
        if (! sysTransObjToUpdateList.isEmpty()) {
            insert sysTransObjToUpdateList;
            for (Transaction__c sysTrans : sysTransObjToUpdateList) {
                Representative rep = contactsToUpdateList.get(i);

                if (rep.selectedTitle == 'Please select') {
                    Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Salutation',
                                                                            Value__c = '');
                    fieldsToUpdateList.add(stf1);
                } else {
                    Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Salutation',
                                                                            Value__c = rep.selectedTitle);
                    fieldsToUpdateList.add(stf1);
                }

                Transaction_Field__c stf2 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Position_Funktion__c',
                                                                            Value__c = rep.position);
                fieldsToUpdateList.add(stf2);

                Transaction_Field__c stf3 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'FirstName',
                                                                            Value__c = rep.firstName);
                fieldsToUpdateList.add(stf3);

                Transaction_Field__c stf4 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MiddleName',
                                                                            Value__c = rep.middleName);
                fieldsToUpdateList.add(stf4);

                Transaction_Field__c stf5 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'LastName',
                                                                            Value__c = rep.lastName);
                fieldsToUpdateList.add(stf5);

                Transaction_Field__c stf6 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Mother_s_maiden_name__c',
                                                                            Value__c = rep.motherMaidenName);
                fieldsToUpdateList.add(stf6);

                Transaction_Field__c stf7 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Email',
                                                                            Value__c = rep.email);
                fieldsToUpdateList.add(stf7);

                Transaction_Field__c stf8 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Birthdate',
                                                                            Value__c = rep.birthday);
                fieldsToUpdateList.add(stf8);

                Transaction_Field__c stf9 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'AllStar_authorised_signatory__c',
                                                                            Value__c = String.valueOf(rep.authorisedSignatory));
                fieldsToUpdateList.add(stf9);

                Transaction_Field__c stf10 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'AllStar_account_administrator__c',
                                                                            Value__c = String.valueOf(rep.accountAdministrator));                                            
                fieldsToUpdateList.add(stf10);

                Transaction_Field__c stf11 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'AllStar_UBO__c',
                                                                            Value__c = String.valueOf(rep.ubo));
                fieldsToUpdateList.add(stf11);

                Transaction_Field__c stf12 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'PESEL_Nr__c',
                                                                            Value__c = rep.pesel);
                fieldsToUpdateList.add(stf12);

                Transaction_Field__c stf13 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Phone',
                                                                            Value__c = rep.telephoneNumber);
                fieldsToUpdateList.add(stf13);

                Transaction_Field__c stf14 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MailingStreet',
                                                                            Value__c = rep.mailingStreet);
                fieldsToUpdateList.add(stf14);

                Transaction_Field__c stf15 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MailingCity',
                                                                            Value__c = rep.mailingCity);
                fieldsToUpdateList.add(stf15);

                Transaction_Field__c stf16 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MailingPostalCode',
                                                                            Value__c = rep.mailingPostcode);
                fieldsToUpdateList.add(stf16);

                String mailingCountryTemp = returnCorrectCountry(rep.mailingCountry);
                Transaction_Field__c stf17 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MailingCountry',
                                                                            Value__c = mailingCountryTemp);
                fieldsToUpdateList.add(stf17);

                Transaction_Field__c stf18 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Country_Text__c',
                                                                            Value__c = rep.mailingCountry);
                fieldsToUpdateList.add(stf18);

                Transaction_Field__c stf19 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'LeadSource',
                                                                            Value__c = 'Allstar Mondo Web Long Form');
                fieldsToUpdateList.add(stf19);

                i++;
            }   
            insert fieldsToUpdateList;
            update sysTransObjToUpdateList;
        }   
    }


    /*******************************************************************************
    *  Name            : doInsertContacts()
    *  Summary         : insert contacts     
    *  CreatedDate     : 02/03/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doInsertContacts() {
        List<Transaction__c> sysTransObjToInsertList = new List<Transaction__c>();
        List<Transaction_Field__c> fieldsToInsertList = new List<Transaction_Field__c>();
        List<Representative> contactsToInsertList = new List<Representative>();
        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Contact' LIMIT 1].Id;

        for (Representative rep : repsMap.values()) {
            if (rep.contactId == null) {
                Transaction__c sysTransContactInsert = new Transaction__c (Record_Id__c = '', 
                                                                                        Object_API__c = 'Contact',
                                                                                        DML_type__c = 'insert', 
                                                                                        Processing__c = true);
                sysTransObjToInsertList.add(sysTransContactInsert);
                contactsToInsertList.add(rep);
            }
        }
            
        Integer i = 0;
        if (! sysTransObjToInsertList.isEmpty()) {
            insert sysTransObjToInsertList;
            for (Transaction__c sysTrans : sysTransObjToInsertList) {
                Representative rep = contactsToInsertList.get(i);
                if (rep.selectedTitle == 'Please select') {
                    Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Salutation',
                                                                            Value__c = '');
                    fieldsToInsertList.add(stf1);
                } else {
                    Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Salutation',
                                                                            Value__c = rep.selectedTitle);
                    fieldsToInsertList.add(stf1);
                }

                Transaction_Field__c stf2 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Position_Funktion__c',
                                                                            Value__c = rep.position);
                fieldsToInsertList.add(stf2);

                Transaction_Field__c stf3 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'FirstName',
                                                                            Value__c = rep.firstName);
                fieldsToInsertList.add(stf3);

                Transaction_Field__c stf4 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MiddleName',
                                                                            Value__c = rep.middleName);
                fieldsToInsertList.add(stf4);

                Transaction_Field__c stf5 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'LastName',
                                                                            Value__c = rep.lastName);
                fieldsToInsertList.add(stf5);

                Transaction_Field__c stf6 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Mother_s_maiden_name__c',
                                                                            Value__c = rep.motherMaidenName);
                fieldsToInsertList.add(stf6);

                Transaction_Field__c stf7 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Email',
                                                                            Value__c = rep.email);
                fieldsToInsertList.add(stf7);

                Transaction_Field__c stf8 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Birthdate',
                                                                            Value__c = rep.birthday);
                fieldsToInsertList.add(stf8);

                Transaction_Field__c stf9 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'AllStar_authorised_signatory__c',
                                                                            Value__c = String.valueOf(rep.authorisedSignatory));
                fieldsToInsertList.add(stf9);

                Transaction_Field__c stf10 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'AllStar_account_administrator__c',
                                                                            Value__c = String.valueOf(rep.accountAdministrator));                                            
                fieldsToInsertList.add(stf10);

                Transaction_Field__c stf11 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'AllStar_UBO__c',
                                                                            Value__c = String.valueOf(rep.ubo));
                fieldsToInsertList.add(stf11);

                Transaction_Field__c stf12 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'PESEL_Nr__c',
                                                                            Value__c = rep.pesel);
                fieldsToInsertList.add(stf12);

                Transaction_Field__c stf13 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Phone',
                                                                            Value__c = rep.telephoneNumber);
                fieldsToInsertList.add(stf13);

                Transaction_Field__c stf14 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MailingStreet',
                                                                            Value__c = rep.mailingStreet);
                fieldsToInsertList.add(stf14);

                Transaction_Field__c stf15 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MailingCity',
                                                                            Value__c = rep.mailingCity);
                fieldsToInsertList.add(stf15);

                Transaction_Field__c stf16 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MailingPostalCode',
                                                                            Value__c = rep.mailingPostcode);
                fieldsToInsertList.add(stf16);

                String mailingCountryTemp = returnCorrectCountry(rep.mailingCountry);
                Transaction_Field__c stf17 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'MailingCountry',
                                                                            Value__c = mailingCountryTemp);
                fieldsToInsertList.add(stf17);

                Transaction_Field__c stf18 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'Country_Text__c',
                                                                            Value__c = rep.mailingCountry);
                fieldsToInsertList.add(stf18);

                Transaction_Field__c stf19 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'AccountId',
                                                                            Value__c = formAccount.Id);
                fieldsToInsertList.add(stf19);

                Transaction_Field__c stf20 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'RecordTypeId',
                                                                            Value__c = recordTypeId);
                fieldsToInsertList.add(stf20);

                Transaction_Field__c stf21 = new Transaction_Field__c (Transaction__c = sysTrans.Id,
                                                                            API_Field_Name__c = 'LeadSource',
                                                                            Value__c = 'Allstar Mondo Web Long Form');
                fieldsToInsertList.add(stf21);
            
                i++;
            }   
            insert fieldsToInsertList;
            update sysTransObjToInsertList;
        }        
    }


    /*******************************************************************************
    *  Name            : validationByStepOne()
    *  Summary         : Validation of the fields in step 1   
    *  CreatedDate     : 23/02/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validationByStepOne() {
        Boolean taxIdIsNumber = checkForNumber(this.taxIdNumber);
        Boolean regonIsNumber = checkForNumber(this.regon);
        Boolean krsIsNumber = checkForNumber(this.krsNumber);
        Boolean correctEmail = checkEmail(this.emailAddress);
        if (this.registeredName == '' || this.tradingName == '' || this.taxIdNumber == '' || this.regon == '' || 
            this.primaryBusinessNumber == '' || this.streetAndHouseNumber == '' || this.city == '' || this.postcode == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Proszę wypełnić wszystkie pola obowiązkowe!'));
            this.currentStep = 'Step 1';
            this.error = true;  
        } else if (this.showBlockBusinessAddress == false && (this.shipStreet == '' || this.shipCity == '' || this.shipPostCode == '')) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Proszę wypełnić wszystkie pola obowiązkowe!'));
            this.currentStep = 'Step 1';
            this.error = true;    
        } else
        //validation for Tax ID Number field      
        if (taxIdIsNumber == false || this.taxIdNumber.length() < 10) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Numer Identyfikacji Podatkowej składa się z 10 znaków i zawiera wyłącznie cyfry!'));
            this.currentStep = 'Step 1';
            this.error = true;
        } else 
        //validation for REGON field    
        if (regonIsNumber == false || this.regon.length() < 9) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'REGON składa się z 9 do 10 znaków i zawiera wyłącznie cyfry!'));
            this.currentStep = 'Step 1';
            this.error = true;
        } else 
        //validation for KRS Number field      
        if (krsIsNumber == false || this.krsNumber.length() < 10) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Krajowy Rejestr Sądowy (KRS) Numer składa się z 10 znaków i zawiera wyłącznie cyfry!'));
            this.currentStep = 'Step 1';
            this.error = true;
        }else
        //validation email adress format
         if (correctEmail == false) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Nieprawidłowy format email adres!'));
            this.currentStep = 'Step 1';
            this.error = true;
        } else {
            this.currentStep = 'Step 2';
            this.error = false;
        }
    }


    /*******************************************************************************
    *  Name            : validationByStepTwo()
    *  Summary         : Validation of the fields in step 2    
    *  CreatedDate     : 23/02/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validationByStepTwo() {
        if (this.selectedTypeOfOrganization == 'Please select' || this.turnover == '' || this.selectedNumberOfEmployees == 'Please select' ||
            this.selectedYearOfRegistration == 'Please select' || this.selectedIndustry == 'Please select' || this.numberOfIndividualCards == '' ||
            this.companyCreditSpend == '') {

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Proszę wypełnić wszystkie pola obowiązkowe!'));
            this.currentStep = 'Step 2';
            this.error = true;
        } else {
            this.currentStep = 'Step 3';
            this.error = false;
        }
    }


    /*******************************************************************************
    *  Name            : validationByStepThree()
    *  Summary         : Validation of the fields in step 3    
    *  CreatedDate     : 23/02/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference validationByStepThreeAndSave() {
        //check the required fields 
        List<Representative> preFillingContactErrorsList = new List<Representative>();
        List<Representative> invalidFormatEmailErrorsList = new List<Representative>();
        List<SubAccount> preFillingSubAccountErrorsList = new List<SubAccount>();
        List<Exception> dateFormatErrors = new List<Exception>();    
        for (Representative repr : this.repsMap.values()) {
            Boolean correctEmail = checkEmail(repr.email);
            if (! this.repsMap.isEmpty() && (repr.firstName == '' || repr.lastName == '' || repr.motherMaidenName == '' || repr.email == '' || repr.birthday == '' || 
                repr.mailingStreet == '' || repr.mailingCity == '' || (repr.authorisedSignatory == false && repr.accountAdministrator == false && repr.ubo == false) || 
                this.agreementDataProtection == false || this.agreementAuthorityToApply == false || this.agreementTermsAndConditions == false)) {
                preFillingContactErrorsList.add(repr);
            } else if (correctEmail == false) {
                invalidFormatEmailErrorsList.add(repr);
            } else if (! this.repsMap.isEmpty() && repr.birthday != '') {
                try {
                    Date dateValidate = Date.valueOf(repr.birthday.replace('/', '-'));
                } catch (Exception e) {
                    dateFormatErrors.add(e);
                }
            }
        }

        //prefilling sub accounts
        for (SubAccount sa : this.subAccMap.values()) {
            if (this.showBlockEntityUBO == false && (sa.streetSubAcc == '' || sa.yearOfRegistrationSubAcc == 'Please select')) {
                preFillingSubAccountErrorsList.add(sa);
           } 
        }

        // CHECK PREFILLING FIELDS
        if (preFillingContactErrorsList.size() != 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Proszę wypełnić wszystkie pola obowiązkowe!'));
            this.currentStep = 'Step 3';
            this.error = true;
        } else if (preFillingSubAccountErrorsList.size() != 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Proszę wypełnić wszystkie pola obowiązkowe!'));
            this.currentStep = 'Step 3';
            this.error = true;
        }/*CHECK BIRTH DATE FORMAT*/
        else if (dateFormatErrors.size() != 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Nieprawidłowy format daty urodzenia'));
            this.currentStep = 'Step 3';
            this.error = true;   
        }/*CHECK EMAIL FORMAT*/
        else if (invalidFormatEmailErrorsList.size() != 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Nieprawidłowy format email adres!'));
            this.currentStep = 'Step 3';
            this.error = true;
        }
         else {
            this.error = false;
        }
        //SAVE
        try {
            if (this.error == false) {
                doUpdateParentAccount();
                if (! subAccMap.isEmpty()) {
                    doUpdateSubAccounts();
                    doInsertSubAccount();         
                }
                if (this.formOpportunity != null) {
                    doUpdateOpportunity();
                } else {
                    doInsertOpportunity(); 
                } 
                if (! repsMap.isEmpty()) {
                    doUpdateContacts();
                    doInsertContacts();
                }
                if (this.formOpportunity != null) {
                    PageReference page = new PageReference('/GenerateLinkForAllStarPDF?id=' + this.formOpportunity.Id);
                    return page; 
                } else {
                    this.formOpportunity = [
                        SELECT Name, AccountId, Umsatz__c,
                          Anzahl_der_Karten__c, Requested_monthly_Company_Credit_Spend__c, CreatedDate,
                               Data_Protection_Act_1998__c, Bevollmaechtigung__c, AGB_Datenschutzhinweise_Richtigkeit__c, Email_Marketing__c
                        FROM Opportunity
                        WHERE AccountId = :formAccount.Id
                        LIMIT 1];
                    PageReference page = new PageReference('/GenerateLinkForAllStarPDF?id=' + this.formOpportunity.Id);
                    return page;
                }        
            } else {
                return null;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return null;  
    }


    /*******************************************************************************
    *  Name            : generatePdf()
    *  Summary         : generate page when click link 
    *  CreatedDate     : 31/05/2017
    *  Parameters      : -
    *  Returns         : return page with pdf
    ******************************************************************************/
    public PageReference generatePdf() {
        String oppId = ApexPages.currentPage().getParameters().get('id');
        PageReference page = new PageReference('/GenerateAllStarPDF?id=' + oppId);
        return page;
    }


    /*******************************************************************************
    *  Name            : getCorrectCountry (String country)
    *  Summary         : return correct country    
    *  CreatedDate     : 06/04/2017
    *  Parameters      : String country
    *  Returns         : String country (correct country)
    ******************************************************************************/
    public String returnCorrectCountry (String country) {
        if (country == 'Poland' || country == 'Polska') {
            country = 'Poland';
            return country;
        } else if (country == 'Germany') {
            return country;
        } else {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : isNumber(String str)
    *  Summary         : check a string has only numbers  
    *  CreatedDate     : 07/04/2017
    *  Parameters      : String str
    *  Returns         : Boolean value (true or false)
    ******************************************************************************/
    public Boolean checkForNumber(String str) {
        Pattern isnumbers = Pattern.Compile('^[-]?[0-9]+$');
        Matcher numberMatch = isnumbers.matcher(str);
        return numberMatch.Matches();
    }


    /*******************************************************************************
    *  Name            : checkEmail(String sEmail)
    *  Summary         : email validation    
    *  CreatedDate     : 17/04/2017
    *  Parameters      : String sEmail
    *  Returns         : Boolean value (true or false) 
    ******************************************************************************/
    public Boolean checkEmail(String sEmail) {
        Boolean returnValue = true;
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);

        if (sEmail == null) {
            returnValue = false;
        } else {
            Matcher MyMatcher = MyPattern.matcher(sEmail); 
            if (! MyMatcher.matches() ) {
                returnValue = false;
            } 
        }

        return returnValue;
    }

    /*******************************************************************************
    *  Name            : getTypesOfOrganization()
    *  Summary         : creating a list of organization types   
    *  CreatedDate     : 16/02/2017
    *  Parameters      : -
    *  Returns         : options (type values)
    ******************************************************************************/
    public List<SelectOption> getTypesOfOrganization() {
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('Please select','Proszę wpisać'));
        options.add(new SelectOption('Sole proprietorship','Jednoosobowa działalność gospodarcza'));
        options.add(new SelectOption('The Polish Limited Liability Company (sp.z o.o)','Spółka z ograniczoną odpowiedzialnością'));
        options.add(new SelectOption('Limited Liability Partnership (sp. p.)','Spółka Partnerska'));
        options.add(new SelectOption('Limited Joint Stock Partnership (S.K.A.)','Spółka komandytowo-akcyjna'));
        options.add(new SelectOption('Limited Partnership (sp. k.)','Spółka komandytowa'));
        options.add(new SelectOption('General or Registered Partnership (sp. j.)','Spółka jawna'));
        options.add(new SelectOption('Civil Law Partnership','Spółka cywilna'));
        options.add(new SelectOption('The Polish Joint Stock Company (S.A.)','Spółka akcyjna'));
        options.add(new SelectOption('Branch of an Overseas Business','Oddział Przedsiębiorcy Zagranicznego'));
        options.add(new SelectOption('Agency of an Overseas Business','Agencja Przedsiębiorcy Zagranicznego'));
        options.add(new SelectOption('Other','Inne'));
        options.add(new SelectOption('Foundation','Fundacja'));
        options.add(new SelectOption('Association','Stowarzyszenie'));
        options.add(new SelectOption('Cooperative','Spółdzielnia'));

    	return options;
    }


    /*******************************************************************************
    *  Name            : getNumberOfEmployees()
    *  Summary         : creating a list of Number of Employees    
    *  CreatedDate     : 17/02/2017
    *  Parameters      : -
    *  Returns         : options (number employees)
    ******************************************************************************/
    public List<SelectOption> getNumberOfEmployees() {
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('Please select','Please select'));
    	options.add(new SelectOption('1-4','1-4'));
    	options.add(new SelectOption('5-9','5-9'));
    	options.add(new SelectOption('10-19','10-19'));
    	options.add(new SelectOption('20-49','20-49'));
    	options.add(new SelectOption('50-75','50-75'));
    	options.add(new SelectOption('75-99','75-99'));
    	options.add(new SelectOption('100-149','100-149'));
    	options.add(new SelectOption('150-199','150-199'));
    	options.add(new SelectOption('>200','>200'));
    	options.add(new SelectOption('No information','No information'));    	

    	return options;
    }


    /*******************************************************************************
    *  Name            : getYearOfRegistration()
    *  Summary         : creating a list of registration year    
    *  CreatedDate     : 17/02/2017
    *  Parameters      : -
    *  Returns         : options (Year Of Registration)
    ******************************************************************************/
    public List<SelectOption> getYearOfRegistration() {
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('Please select','Proszę wybrać'));
    	options.add(new SelectOption('2017','2017'));
    	options.add(new SelectOption('2016','2016'));
    	options.add(new SelectOption('2015','2015'));
    	options.add(new SelectOption('2014','2014'));
    	options.add(new SelectOption('2013','2013'));
    	options.add(new SelectOption('2012','2012'));
    	options.add(new SelectOption('2011','2011'));
    	options.add(new SelectOption('2010','2010'));
    	options.add(new SelectOption('2009','2009'));
    	options.add(new SelectOption('2008','2008'));
    	options.add(new SelectOption('2007','2007'));
    	options.add(new SelectOption('2006','2006'));
    	options.add(new SelectOption('2005','2005'));
    	options.add(new SelectOption('2004','2004'));
    	options.add(new SelectOption('2003','2003'));
    	options.add(new SelectOption('2002','2002'));
    	options.add(new SelectOption('2001','2001'));
    	options.add(new SelectOption('2000','2000'));
    	options.add(new SelectOption('1999','1999'));
    	options.add(new SelectOption('1998','1998'));
    	options.add(new SelectOption('1997','1997'));
    	options.add(new SelectOption('1996','1996'));
    	options.add(new SelectOption('1995','1995'));
    	options.add(new SelectOption('1994','1994'));
    	options.add(new SelectOption('1993','1993'));
    	options.add(new SelectOption('1992','1992'));
    	options.add(new SelectOption('1991','1991'));
    	options.add(new SelectOption('1990','1990'));
    	options.add(new SelectOption('1989','1989'));
    	options.add(new SelectOption('1988','1988'));
    	options.add(new SelectOption('1987','1987'));
    	options.add(new SelectOption('1986','1986'));
    	options.add(new SelectOption('1985','1985'));
    	options.add(new SelectOption('1984','1984'));
    	options.add(new SelectOption('1983','1983'));
    	options.add(new SelectOption('1982','1982'));
    	options.add(new SelectOption('1981','1981'));
    	options.add(new SelectOption('1980','1980'));
    	options.add(new SelectOption('1979','1979'));
    	options.add(new SelectOption('1978','1978'));
    	options.add(new SelectOption('1977','1977'));
    	options.add(new SelectOption('1976','1976'));
    	options.add(new SelectOption('1975','1975'));
    	options.add(new SelectOption('1974','1974'));
    	options.add(new SelectOption('1973','1973'));
    	options.add(new SelectOption('1972','1972'));
    	options.add(new SelectOption('1971','1971'));
    	options.add(new SelectOption('1970','1970'));
    	options.add(new SelectOption('1969','1969'));
    	options.add(new SelectOption('1968','1968'));
    	options.add(new SelectOption('1967','1967'));
    	options.add(new SelectOption('1966','1966'));
    	options.add(new SelectOption('1965','1965'));
    	options.add(new SelectOption('1964','1964'));
    	options.add(new SelectOption('1963','1963'));
    	options.add(new SelectOption('1962','1962'));
    	options.add(new SelectOption('1961','1961'));
    	options.add(new SelectOption('1960','1960'));
    	options.add(new SelectOption('1959','1959'));
    	options.add(new SelectOption('1958','1958'));
    	options.add(new SelectOption('1957','1957'));
    	options.add(new SelectOption('1956','1956'));
    	options.add(new SelectOption('1955','1955'));
    	options.add(new SelectOption('1954','1954'));
    	options.add(new SelectOption('1953','1953'));
    	options.add(new SelectOption('1952','1952'));
    	options.add(new SelectOption('1951','1951'));
    	options.add(new SelectOption('1950','1950'));
    	options.add(new SelectOption('1949','1949'));
    	options.add(new SelectOption('1948','1948'));
    	options.add(new SelectOption('1947','1947'));
    	options.add(new SelectOption('1946','1946'));
    	options.add(new SelectOption('1945','1945'));
    	options.add(new SelectOption('1944','1944'));
    	options.add(new SelectOption('1943','1943'));
    	options.add(new SelectOption('1942','1942'));
    	options.add(new SelectOption('1941','1941'));
    	options.add(new SelectOption('1940','1940'));

    	return options;
    }


    /*******************************************************************************
    *  Name            : getIndustries()
    *  Summary         : creating a list of Industries    
    *  CreatedDate     : 06/04/2017
    *  Parameters      : -
    *  Returns         : options (Industries)
    ******************************************************************************/
    public List<SelectOption> getIndustries() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Please select','Proszę wybrać'));
        options.add(new SelectOption('Agriculture, forestry and fishing','Rolnictwo, leśnictwo, łowiectwo i rybactwo'));
        options.add(new SelectOption('Mining and quarrying','Górnictwo i wydobywanie'));
        options.add(new SelectOption('Manufacturing','Przetwórstwo przemysłowe'));
        options.add(new SelectOption('Electricity, gas, steam and air conditioning supply','Wytwarzanie i zaopatrywanie w energię elektryczną, gaz, parę wodną, gorącą wodę i powietrze do układów klimatyzacyjnych'));
        options.add(new SelectOption('Water supply; sewerage; waste management and remediation activities','Dostawa wody; gospodarowanie ściekami i odpadami oraz działalność związana z rekultywacją'));
        options.add(new SelectOption('Construction','Budownictwo'));
        options.add(new SelectOption('Wholesale and retail trade; repair of motor vehicles and motorcycles','Handel hurtowy i detaliczny; naprawa pojazdów samochodowych, włączając motocykle'));
        options.add(new SelectOption('Transporting and storage','Transport i gospodarka magazynowa'));
        options.add(new SelectOption('Accommodation and food service activities','Działalność związana z zakwaterowaniem i usługami gastronomicznymi'));
        options.add(new SelectOption('Information and communication','Informacja i komunikacja'));
        options.add(new SelectOption('Financial and insurance activities','Działalność finansowa i ubezpieczeniowa'));
        options.add(new SelectOption('Real estate activities','Działalność związana z obsługą rynku nieruchomości'));
        options.add(new SelectOption('Professional, scientific and technical activities','Działalność profesjonalna, naukowa i techniczna'));
        options.add(new SelectOption('Administrative and support service activities','Działalność w zakresie usług administrowania i działalność wspierająca')); 
        options.add(new SelectOption('Public administration and defense; compulsory social security','Administracja publiczna i obrona narodowa; obowiązkowe zabezpieczenia społeczne'));
        options.add(new SelectOption('Education','Edukacja'));
        options.add(new SelectOption('Human health and social work activities','Opieka zdrowotna i pomoc społeczna'));
        options.add(new SelectOption('Arts, entertainment and recreation','Działalność związana z kulturą, rozrywką i rekreacją'));
        options.add(new SelectOption('Activities of households as employers','Gospodarstwa domowe zatrudniające pracowników; gospodarstwa domowe produkujące wyroby i świadczące usługi na własne potrzeby'));
        options.add(new SelectOption('Activities of extraterritorial organizations and bodies','Organizacje i zespoły eksterytorialne'));
        options.add(new SelectOption('Other services activities','Pozostała działalność usługowa')); 

        return options;
    }


    /*******************************************************************************
    *  Name            : getTitle()
    *  Summary         : creating titles list    
    *  CreatedDate     : 20/02/2017
    *  Parameters      : -
    *  Returns         : options (Solutions)
    ******************************************************************************/
    public List<SelectOption> getTitle() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Please select','Proszę wybrać'));
        options.add(new SelectOption('Herr','Pan'));
        options.add(new SelectOption('Frau','Pani'));     

        return options;
    }

    public class Representative {
        public String contactId {get; set;}
        public String conAccountId {get; set;}
        public String selectedTitle {get; set;}
        public String position {get; set;}
        public String firstName {get; set;}
        public String middleName {get; set;}
        public String lastName {get; set;}
        public String motherMaidenName {get; set;}
        public String email {get; set;}
        public String birthday {get; set;}     
        public Boolean authorisedSignatory {get; set;}
        public Boolean accountAdministrator {get; set;}
        public Boolean ubo {get; set;}
        public String pesel {get; set;}
        public String telephoneNumber {get; set;}
        public String mailingStreet {get; set;}
        public String mailingCity {get; set;}
        public String mailingPostcode {get; set;}
        public String mailingCountry {get; set;} 
    }

    public class SubAccount {
        public String subAccountId {get; set;}
        public String nameSubAcc {get; set;}
        public String streetSubAcc {get; set;}
        public String citySubAcc {get; set;}
        public String yearOfRegistrationSubAcc {get; set;}
        public String postcodeSubAcc {get; set;}
        public String countrySubAcc {get; set;}
        public String accParentId {get; set;}
    }
}