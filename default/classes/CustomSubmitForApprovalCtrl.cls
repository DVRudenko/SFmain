public class CustomSubmitForApprovalCtrl {
    // public List<Opportunity> oppList;
    public Opportunity opp {get; set;}
    // public List<Account> accList;
    public Account acc {get; set;}
    public Contact primaryContact {get; set;}
    public List<ProcessInstance> pi;
    public List<String> finalOpportunityFieldsList {get; set;}
    public List<String> finalAccountFieldsList {get; set;}
    public String type {get; set;}
    public String oppId;
    public Boolean changeOfTotalConsumption {get; set;}
    private Boolean isCfDecisionCleared; 
    public Boolean relaunchCF {get; set;}
    private Boolean isAutoprocessed;
    public Boolean isInternationalOffers {get; set;}


    public CustomSubmitForApprovalCtrl() {}

    public PageReference init() {
        try {
            this.changeOfTotalConsumption = false;
            this.relaunchCF = false;
            this.isCfDecisionCleared = false;
            this.isInternationalOffers = false;
            if (this.oppId == null) {
                this.oppId = ApexPages.currentPage().getParameters().get('id');
            }
            this.type = ApexPages.currentPage().getParameters().get('type');
            User currentUser = [
                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
                FROM User
                WHERE Id = :UserInfo.getUserId()];

            List<Opportunity> oppList = [
                SELECT Id, OwnerId, Owner.UserRole.Name, Name, StageName, Owner.Name, Zahlungsart__c, AccountId, Requested_monthly_Company_Credit_Spend__c, RecordType.Name,
                       AGB_Datenschutzhinweise_Richtigkeit__c, Data_Protection_Act_1998__c, Anzahl_der_Karten__c, Language_preference__c, bearbeitet_von__c,
                       Name_of_the_payer_Account_holder__c, Derzeitige_Zahlungsmethode__c, Direct_Debit_Mandate_Type__c, IBAN__c, SWIFT_BIC__c, Total_consumption_l_month__c,
                       Zahlungsziel__c, DocuSign_Status__c, Zahlungssystem__c, Bank__c, Tankkarte_Emittent__c, Product__c, Angebotsdauer__c, Home_Station__c, Sec_Channel__c, 
                       Channel__c, Datansatztyp_auto__c, Eco_Fee__c, ESI__c, Registered_Country__c, CF_Stage__c, Last_CF_Errors__c, Total_One_time_Payment__c, Type, Relaunch_CF__c, 
                       Non_fuel_exposure__c, Requested_SWIFT_BIC__c, Total_consumption_per_card__c, Credit_Stage__c, Total_cards_consumption_monthly__c, Number_of_GPS_units__c,
                                (SELECT Id 
                                 FROM Credit_Factory_Reports__r 
                                 WHERE CreatedDate > :Date.today().addMonths(-30)),
                                (SELECT Contact.FirstName, Contact.LastName, Contact.Email, Contact.Birthdate
                                 FROM OpportunityContactRoles
                                 WHERE IsPrimary = true),
                                (SELECT Id 
                                FROM Tankkarten__r 
                                WHERE Gewuenschter_Kartentyp__c = 'Single Network Card -- International' OR Gewuenschter_Kartentyp__c = 'Multi Network Card -- International')
                FROM Opportunity 
                WHERE Id = :oppId
                LIMIT 1];

            if (! oppList.isEmpty()) {
                this.opp = oppList.get(0);
                
                String SHELL = 'SHELL';
                String EV = 'EV';
                String LOTOS = 'Lotos';
                List<OpportunityLineItem> lineItemsList = [
                    SELECT Product2.Name, Product2.Family
                    FROM OpportunityLineItem
                    WHERE OpportunityId = :this.opp.Id AND (Product2.Family = :SHELL OR Product2.Family = :EV OR Product2.Family = :LOTOS)];
                Map<String, OpportunityLineItem> lineItemsMap = new Map<String, OpportunityLineItem>();
                for (OpportunityLineItem lineItem : lineItemsList) {
                    lineItemsMap.put(lineItem.Id, lineItem);
                }
                if (! lineItemsMap.isEmpty()) {
                    List<Offer_Item__c> offerItemsList = [
                            SELECT Type_of_Card__c, Opportunity_Product_Id__c
                            FROM Offer_Item__c
                            WHERE Opportunity_Product_Id__c IN :lineItemsMap.keySet()
                    ];
                    for (Offer_Item__c oferItem : offerItemsList) {
                        if (lineItemsMap.containsKey(oferItem.Opportunity_Product_Id__c) && ((lineItemsMap.get(oferItem.Opportunity_Product_Id__c).Product2.Family == SHELL || 
                                lineItemsMap.get(oferItem.Opportunity_Product_Id__c).Product2.Family == LOTOS) && 
                                (oferItem.Type_of_Card__c == 'Single Network Card -- International' || oferItem.Type_of_Card__c == 'Multi Network Card -- International') || 
                                lineItemsMap.get(oferItem.Opportunity_Product_Id__c).Product2.Family == EV)) {
                            this.isInternationalOffers = true;
                        }
                    }
                }

                List<Account> accList = [
                    SELECT Id, NIP__c, Gesellschaftsform__c, Trading_Name__c, BillingCountry, Beschaeftigte__c, Bundesland__c, OwnerId,
                            Steuernummer__c, Umsatzsteuer_ID__c, No_Vat__c, No_Tax__c
                    FROM Account
                    WHERE Id = :opp.AccountId 
                    LIMIT 1];
                this.acc = accList.get(0);

                this.pi = [
                    SELECT TargetObjectId, Status, ProcessDefinitionId, (SELECT ActorId, Comments, StepStatus FROM StepsAndWorkitems WHERE StepStatus != 'Started')
                    FROM ProcessInstance 
                    WHERE TargetObjectId = :this.opp.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1];

                validateOpportunity();
                this.finalOpportunityFieldsList = generateOppRequiredFieldsList(currentUser.Profile.Name);
                this.finalAccountFieldsList = generateAccRequiredFieldsList(currentUser.Profile.Name);

                PageReference page;
                if (this.opp.bearbeitet_von__c == 'Autoprocessed by Sales' && (this.opp.StageName == 'Pending Sales – Deposit' || this.opp.Credit_Stage__c == 'Pending Sales – Deposit') || 
                        this.opp.bearbeitet_von__c == 'Autoprocessed by E2E') {
                    this.isAutoprocessed = true;
                } else {
                    this.isAutoprocessed = false;
                }
                if (this.isAutoprocessed) this.relaunchCF = true;
                if (this.type == 'submitforapproval') {
                    if (this.pi.isEmpty() || this.pi.get(0).Status == 'Approved') {
                        validateSubmitForApproval();
                        page = initiallySubmitForApproval();
                    } else {
                        String approveProcessName = [SELECT DeveloperName FROM ProcessDefinition WHERE Id = :this.pi.get(0).ProcessDefinitionId].DeveloperName;
                        validateResubmitForApproval(approveProcessName);
                        page = resubmitForApproval();  
                    }
                } else if (this.type == 'creditfactory') {
                    return processCreditFactory();
                } 
                
                return page;     
            }
        } catch (Exception e) {
            if (ApexPages.currentPage() != null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            } else {
                ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
        }       
        return null;    
    }

    /*******************************************************************************
    *  Name            : initiallySubmitForApproval()
    *  Summary         : Submit for approval (opportunity is submit for the first time)   
    *  CreatedDate     : 06/06/2017
    *  ModifiedDate    : 10/12/2019
    *  Parameters      : -
    *  Returns         : home page opportunity OR page with error and required fields
    ******************************************************************************/
    public PageReference initiallySubmitForApproval() {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for CreditCheck.');
        req.setObjectId(this.opp.id);
        req.setSubmitterId(UserInfo.getUserId()); 
        req.setSkipEntryCriteria(false);
        Savepoint sp = Database.setSavepoint();
        try {
            if (this.opp.RecordType.Name == 'Lotos') {
                this.opp.Credit_Stage__c = 'CreditCheck';
            } else {
                this.opp.StageName = 'CreditCheck';
            }
            if (this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check' && this.opp.RecordType.Name != 'Carnet') {
                this.opp.CF_Stage__c = 'Manual scoring';
            }
            update this.opp;
            Approval.process(req);  
        } catch (Exception e) {
            Database.rollback(sp);
            String errorText = e.getMessage();
            if (errorText.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                errorText = errorText.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': [');
            } else {
                errorText = 'This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.';
            }
            if (ApexPages.currentPage() != null) {  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorText));
            } else {
                ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
            return null;     
        }   
        PageReference page = new PageReference('/' + opp.Id);
        return page;
    }


    /*******************************************************************************
    *  Name            : resubmitForApproval()
    *  Summary         : send for approval if Approval History not empty
    *  CreatedDate     : 07/06/2017
    *  ModifiedDate    : 10/12/2019
    *  Parameters      : -
    *  Returns         : opportunity page or validation page
    ******************************************************************************/
    public PageReference resubmitForApproval() {
        if (this.pi.get(0).Status == 'Rejected') {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for CreditCheck.');
            req.setObjectId(this.opp.id);
            req.setSubmitterId(UserInfo.getUserId()); 
            req.setSkipEntryCriteria(false);
            Savepoint sp = Database.setSavepoint();
            try {
                if (this.opp.RecordType.Name == 'Lotos') {
                    this.opp.Credit_Stage__c = 'CreditCheck';
                } else {
                    this.opp.StageName = 'CreditCheck';
                }
                if (this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check') {
                    this.opp.CF_Stage__c = 'Manual Scoring';
                }
                update this.opp;
                Approval.process(req);                 
            } catch (Exception e) {
                Database.rollback(sp);
                String errorText = e.getMessage();          
                if (errorText.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    errorText = errorText.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': [');
                } else {
                    errorText = 'This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.';
                }
                if (ApexPages.currentPage() != null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorText));
                } else {
                    ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
                }
                return null;    
            }   
            PageReference page = new PageReference('/' + this.opp.Id);
            return page;
        } else if (this.pi.get(0).Status == 'Pending') {
            if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
                this.opp.StageName = 'Credit Check - Pending Credit';
                if (this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check') {
                    this.opp.CF_Stage__c = 'Manual Scoring';
                }
                update opp;
                Approval.lock(this.opp.Id);
                PageReference page = new PageReference('/' + this.opp.Id);
                return page;
            } else if (this.opp.RecordType.Name == 'Carnet') {
                this.opp.StageName = 'Credit Check - Pending Credit';
                update opp; 
                Approval.lock(this.opp.Id);
                PageReference page = new PageReference('/' + this.opp.Id);
                return page;
            } else if (this.opp.RecordType.Name == 'Lotos') {
                this.opp.Credit_Stage__c = 'Credit Check - Pending Credit';
                update opp; 
                Approval.lock(this.opp.Id);
                PageReference page = new PageReference('/' + this.opp.Id);
                return page;
            }
        }      
        return null;
    }


    /*******************************************************************************
    *  Name            : submitForApprovalFromValidationPage() 
    *  Summary         : save opportunity and send for approval    
    *  CreatedDate     : 24/05/2017
    *  Parameters      : -
    *  Returns         : opportunity page or validation page
    ******************************************************************************/
    public PageReference submitForApprovalFromValidationPage() {     
        try {
            if (! Test.isRunningTest()) {
                update this.acc;
                update this.opp; 
            }
            if (this.pi.isEmpty() || this.pi.get(0).Status == 'Approved') {
                validateSubmitForApproval();
                PageReference page = initiallySubmitForApproval();
                return page;
            } else {
                String approveProcessName = [SELECT DeveloperName FROM ProcessDefinition WHERE Id = :this.pi.get(0).ProcessDefinitionId].DeveloperName;
                validateResubmitForApproval(approveProcessName);
                PageReference page = resubmitForApproval();
                return page;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }       
        return null;
    }


    /*******************************************************************************
    *  Name            : preporationEmailsForSending()
    *  Summary         : prepares to send email    
    *  CreatedDate     : 25/05/2017
    *  Parameters      : String emailTemplateName
    *  Returns         : all emails
    ******************************************************************************/
    public List<Messaging.SingleEmailMessage> preporationEmailsForSending(String emailTemplateName) {
        // getting email template id
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue, Body
            FROM EmailTemplate 
            WHERE DeveloperName = :emailTemplateName
            LIMIT 1];

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mailToCredit = new Messaging.SingleEmailMessage();
        //email for credit
        mailToCredit.setTemplateID(emailTemplate.Id); 
        if (! Test.isRunningTest()) {
            mailToCredit.setTargetObjectId(pi.get(0).StepsAndWorkitems.get(0).ActorId); 
        } 
        mailToCredit.setSaveAsActivity(false);
        mailToCredit.setWhatId(opp.Id);
        allmsg.add(mailToCredit);

        return allmsg;  
    }


    /*******************************************************************************
    *  Name            : redirectToCreditFactory() 
    *  Summary         : Redirect to Credit Factory Finder     
    *  CreatedDate     : 21/12/2017
    *  ModifiedDate    : 31/10/2019
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference redirectToCreditFactory() {
        try {
            validateCreditFactory();
            
            if (this.opp.Requested_SWIFT_BIC__c == null && this.opp.Zahlungsart__c == 'Lastschrift') {
                String requestedBic = generateBic();
                if (requestedBic != null) {
                    this.opp.Requested_SWIFT_BIC__c = requestedBic;
                    if (this.opp.SWIFT_BIC__c == null) this.opp.SWIFT_BIC__c = requestedBic;
                    update this.opp;
                }
            }
            
            clearCreditFields();
            update this.opp;
            update this.acc;
            update this.primaryContact;
            return new PageReference('/apex/CreditFactory?id=' + this.opp.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : clearCreditFields()
    *  Summary         : Clear fields that were calculated on the previous launch of Credit Factory    
    *  CreatedDate     : 13/06/2019
    *  ModifiedDate    : 10/12/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void clearCreditFields() {
        if (this.relaunchCF == true && this.isCfDecisionCleared == false) {
            this.isCfDecisionCleared = true;
            this.opp.Zahlungsziel_Credit__c = null;
            this.opp.Rechnungsperiode__c = null;
            this.opp.CF_Credit_Limit__c = null;
            this.opp.Credit_check_date__c = null;
            this.opp.bearbeitet_von__c = null;
            this.opp.Kredit_Entscheidung__c = null;
            this.opp.Max_Credit_Limit__c = null;
            this.opp.Security_To_Pay__c = null;
            this.opp.Security_Amount_To_Pay__c = null;
            this.opp.Security_level_H_he_der_Sicherheit__c = null;
            this.opp.Billing_Period_by_Sales__c = false;
            if (this.opp.RecordType.Name == 'Lotos') {
                this.opp.Credit_Stage__c = 'Qualify';
            } else {
                this.opp.StageName = 'Prospecting';
            }
            this.opp.CF_Stage__c = 'Report generated';
            this.opp.Pending_Deposit_by_CF__c = false;
            if (this.opp.Relaunch_CF__c == null) this.opp.Relaunch_CF__c = 0;
            this.opp.Relaunch_CF__c++;
        }
    }


    /*******************************************************************************
    *  Name            : validateOpportunity()
    *  Summary         : validating RecordType and Country    
    *  CreatedDate     : 21/06/2017
    *  ModifiedDate    : 25/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateOpportunity() { //
        //check Record Type
        if (this.opp.RecordType.Name != 'Euroshell' && this.opp.RecordType.Name != 'Euroshell Starts' &&
                this.opp.RecordType.Name != 'Carnet' && this.opp.RecordType.Name != 'Lotos' &&
                this.opp.RecordType.Name != 'CCS Opportunity Layout') {
            throw new MessageException('This button is only for opportunities with "Euroshell", "Euroshell Starts", "Carnet", "Lotos", "CCS Opportunity Layout" record types only');
        }
        //check country for Euroshell
        if ((this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') &&
            this.acc.BillingCountry != 'Germany' &&
            this.acc.BillingCountry != 'Austria' && 
            (! this.acc.BillingCountry.contains('Belgium')) &&
            this.acc.BillingCountry != 'Netherlands' &&
            this.acc.BillingCountry != 'Hungary' && 
            this.acc.BillingCountry != 'Poland' &&
            (! this.acc.BillingCountry.contains('Switzerland')) && 
            this.acc.BillingCountry != 'Luxembourg' && 
            this.acc.BillingCountry != 'Slovakia' &&
            this.acc.BillingCountry != 'Czech Republic' &&
            this.acc.BillingCountry != 'France') {
            throw new MessageException('There\'s no active approval process for this country with this Record type. Please select other country.');
        }
        //check country for AllStar
        if ((this.opp.RecordType.Name == 'Carnet' || this.opp.RecordType.Name == 'Lotos') &&
                this.acc.BillingCountry != 'Poland') {
            throw new MessageException('There\'s no active approval process for this country with this Record type. Please select other country.');
        }

        //check country for CCS
        if (this.opp.RecordType.Name == 'CCS Opportunity Layout' && (this.acc.BillingCountry != 'Czech Republic' && this.acc.BillingCountry != 'Slovakia')) {
            throw new MessageException('There\'s no active approval process for this country with this Record type. Please select other country.');
        }
    }


    /*******************************************************************************
    *  Name            : validateSubmitForApproval()
    *  Summary         : validate submit for approval (note: 00e20000001nSOBAA2 = 'System Administrator')    
    *  CreatedDate     : 29/06/2017
    *  ModifiedDate    : 13/12/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateSubmitForApproval() {
        if (this.opp.OwnerId != this.acc.OwnerId && UserInfo.getProfileId() != '00e20000001nSOBAA2') {
            throw new MessageException('Opportunity owner should be the same as Account owner.');
        }
        if (this.opp.CF_Stage__c != null && this.opp.CF_Stage__c.contains('Pending Credit Report') && this.opp.Registered_Country__c != 'Germany') {
            throw new MessageException('Please waiting for Credit Report.');
        }
        if (this.opp.RecordType.Name == 'Carnet') {
            if (this.opp.Total_One_time_Payment__c == null || this.opp.Total_One_time_Payment__c == 0) {
                throw new MessageException('Total One-time Payment shouldn\'t be 0');
            } else if (this.opp.Type == 'Existing GFN') {
                throw new MessageException('Existing customers do not require additional Credit Approval.');
            }
        }
        if ((this.opp.Registered_Country__c == 'Germany' || this.opp.Registered_Country__c == 'Netherlands' || this.opp.Registered_Country__c == 'Belgium-NL' ||
                this.opp.Registered_Country__c == 'France' || this.opp.Registered_Country__c == 'Belgium-FR' || this.opp.Registered_Country__c == 'Poland' ||
                this.opp.Registered_Country__c == 'Hungary' || this.opp.Registered_Country__c == 'Austria' || this.opp.Registered_Country__c == 'Switzerland-DE' ||
                this.opp.Registered_Country__c == 'Switzerland-FR' || this.opp.Registered_Country__c == 'Switzerland-IT' || this.opp.Registered_Country__c == 'Luxembourg' ||
                this.opp.Registered_Country__c == 'Slovakia' || this.opp.Registered_Country__c == 'Czech Republic') &&
                (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Lotos' || this.opp.RecordType.Name == 'CCS Opportunity Layout') &&
                this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check' &&
                this.opp.Last_CF_Errors__c == null && this.opp.CF_Stage__c != 'Credit Report not available' && this.opp.CF_Stage__c != 'Pending Advance Payment') {
            throw new MessageException('Please process your Opportunity in Credit Factory before submitting it for manual review.');
        }
        if (this.opp.StageName == 'Closed Won') {
            throw new MessageException('You can\'t submit this opportunity for approval because it\'s already Closed Won');
        }
        if ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'HOME 1' || this.opp.Product__c == 'Inbound Typ C') &&
                (this.opp.Datansatztyp_auto__c.containsIgnoreCase('Euroshell') || this.opp.Datansatztyp_auto__c.containsIgnoreCase('Lotos'))) {
            if (String.isBlank(this.opp.Home_Station__c)) {
                throw new MessageException('Please fill homestation.');
            } else if (String.isBlank(opp.ESI__c)) {
                throw new MessageException('Please fill ESI.');
            }
        }
    }
    
    
    /*******************************************************************************
    *  Name            : processCreditFactory()
    *  Summary         : process Credit Factory
    *  CreatedDate     : 22/10/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference processCreditFactory() {
        try {
            if (this.acc.No_Vat__c == true && this.acc.No_Tax__c == true) {
                this.acc.No_Vat__c = false;
                this.acc.No_Tax__c = false;
            }
            
            if (! this.opp.OpportunityContactRoles.isEmpty()) {
                this.primaryContact = this.opp.OpportunityContactRoles.get(0).Contact;
            }
            
            validateCreditFactory();
            
            if (this.opp.Requested_SWIFT_BIC__c == null && this.opp.Zahlungsart__c == 'Lastschrift') {
                String requestedBic = generateBic();
                if (requestedBic != null) {
                    this.opp.Requested_SWIFT_BIC__c = requestedBic;
                    if (this.opp.SWIFT_BIC__c == null) this.opp.SWIFT_BIC__c = requestedBic;
                    update this.opp;
                }
            }
            
            if (this.isAutoprocessed && opp.RecordType.Name != 'Lotos') {
                this.changeOfTotalConsumption = true;
                return null;
            }
            
            return new PageReference('/apex/CreditFactory?id=' + this.opp.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : validateCreditFactory()
    *  Summary         : Validate fields for available countries
    *  CreatedDate     : 21/12/2017
    *  ModifiedDate    : 10/04/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void validateCreditFactory() {
        if (this.opp.OwnerId != this.acc.OwnerId && UserInfo.getProfileId() != '00e20000001nSOBAA2') {
            throw new MessageException('Opportunity owner should be the same as Account owner.');
        }
        String stage;
        Decimal totalConsumption;
        if (opp.RecordType.Name == 'Lotos') {
            stage = opp.Credit_Stage__c;
            if (opp.Total_consumption_per_card__c != null && opp.Total_consumption_per_card__c != 0) {
                totalConsumption = opp.Total_consumption_per_card__c;
            }
            else {
                totalConsumption = opp.Total_cards_consumption_monthly__c;
            }
        } else {
            stage = opp.StageName;
            totalConsumption = opp.Total_consumption_l_month__c;
        }
        if ((stage == 'CreditCheck' ||
             stage == 'Pending Credit Check' || 
             stage == 'Credit Check - Pending Credit' || 
             stage == 'Pending Credit AML') &&
             this.opp.Bearbeitet_von__c != null) {
            throw new MessageException('Your Customer is already on Credit review.');
        }

        Boolean isCarnet = false;
        if (this.acc.BillingCountry == 'Poland' && (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') &&
                this.opp.Number_of_GPS_units__c != null && this.opp.Number_of_GPS_units__c > 0) {
            isCarnet = true;
        }

        if (totalConsumption == null || totalConsumption == 0) {
            if (acc.BillingCountry == 'Germany' || acc.BillingCountry == 'Netherlands') {
                if (this.opp.Non_fuel_exposure__c == null || this.opp.Non_fuel_exposure__c == 0) {
                    throw new MessageException('You cannot launch Credit Factory for a customer with 0 Total consumption (l/month) and 0 Non-fuel exposure.');
                }
            } else if (! isCarnet) {
                throw new MessageException('You cannot launch Credit Factory for a customer with 0 Total consumption (l/month).');
            }
        }

        if ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'HOME 1' || this.opp.Product__c == 'Inbound Typ C') &&
                this.opp.Datansatztyp_auto__c.containsIgnoreCase('Euroshell')) {
            if (String.isBlank(this.opp.Home_Station__c)) {
                throw new MessageException('Please fill homestation.');
            } else if (String.isBlank(opp.ESI__c)) {
                throw new MessageException('Please fill ESI.');
            }
        }

        if (this.opp.OpportunityContactRoles.isEmpty()) {
            throw new MessageException('Please select Primary Contact for your Opportunity in the Opportunity Contact Roles.');
        }
        
        if (this.acc.Steuernummer__c == null && this.acc.No_Tax__c == false) throw new MessageException('Please fill Tax ID');
        
        if (this.acc.Umsatzsteuer_ID__c == null && this.acc.No_Vat__c == false) throw new MessageException('Please fill VAT Number');

        if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
            if ((this.acc.BillingCountry == 'Germany' || this.acc.BillingCountry == 'Austria') &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && this.opp.Direct_Debit_Mandate_Type__c == null) ||
                this.primaryContact.FirstName == null
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry.contains('Belgium') &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && this.opp.Direct_Debit_Mandate_Type__c == null) ||
                this.primaryContact.FirstName == null
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'Netherlands' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && this.opp.Direct_Debit_Mandate_Type__c == null) ||
                this.primaryContact.FirstName == null
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'France' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && this.opp.Direct_Debit_Mandate_Type__c == null) ||
                this.primaryContact.FirstName == null
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'Poland' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                this.primaryContact.FirstName == null
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'Hungary' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                this.primaryContact.FirstName == null
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry.contains('Switzerland') &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && this.opp.IBAN__c == null) ||
                this.primaryContact.FirstName == null
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'Luxembourg' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && this.opp.Direct_Debit_Mandate_Type__c == null) ||
                this.primaryContact.FirstName == null
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            }
            else if ((this.acc.BillingCountry == 'Slovakia' || this.acc.BillingCountry == 'Czech Republic') &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                this.primaryContact.FirstName == null ||
                this.primaryContact.Birthdate == null
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            }
        } else if (this.opp.RecordType.Name == 'Lotos') {
            if (! isLotosRecordValid()) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            }
        }
        else if (this.opp.RecordType.Name == 'CCS Opportunity Layout') {
            if (this.acc.BillingCountry == 'Czech Republic' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.acc.Beschaeftigte__c == null ||
                this.opp.Total_consumption_per_card__c == null &&
                this.opp.Total_cards_consumption_monthly__c == null)) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            }
            else if (this.acc.BillingCountry == 'Slovakia' &&
                    (this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    this.opp.Total_consumption_per_card__c == null &&
                    this.opp.Total_cards_consumption_monthly__c == null ||
                    this.primaryContact.FirstName == null ||
                    this.primaryContact.Birthdate == null)) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            }
        }
    }
    
    
    /*******************************************************************************
    *  Name            : generateBic()
    *  Summary         : Validate IBAN format and request BIC
    *  CreatedDate     : 31/10/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String generateBic() {
        Pattern myPattern;
        String requestedBic;
        if ((this.acc.BillingCountry == 'Germany' || this.acc.BillingCountry == 'Austria' || this.acc.BillingCountry == 'Luxembourg' ||
                this.acc.BillingCountry == 'Netherlands' || this.acc.BillingCountry == 'Belgium-NL' || this.acc.BillingCountry == 'France' || 
                this.acc.BillingCountry == 'Belgium-FR') && ! String.isEmpty(this.opp.IBAN__c)) {
            String ibanFormat = '(^[Dd]{1}[Ee]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{2}?$|' +
                '^[Aa]{1}[Tt]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|' +
                '^[Ll]{1}[Uu]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|' +
                '^[Nn]{1}[Ll]{1}[0-9]{2}[A-Za-z]{4}[0-9]{10}?$|' + 
                '^[Bb]{1}[Ee]{1}[0-9]{14}?$|' +
                '^[Ff]{1}[Rr]{1}[0-9]{12}[A-Za-z0-9]{11}[0-9]{2}?$)';
            myPattern = Pattern.compile(ibanFormat);
            if (! myPattern.matcher(this.opp.IBAN__c).matches()) {
                throw new MessageException('Please enter the IBAN in a valid format.');
            }
            
            if ( ! SEPA_Toolkit.SEPAUtilities.ValidateIBAN(this.opp.IBAN__c)) {
                throw new MessageException('Please enter valid IBAN');
            }
            
            IBAN_BIC__c ibanBicSettings = IBAN_BIC__c.getInstance('Production');
            if (ibanBicSettings.Active__c) {
                IbanResponse ibanResponse = requestBic(ibanBicSettings);
                if (ibanResponse.result != 'passed' || ibanResponse.all_bic_candidates.isEmpty()) {
                    throw new MessageException('Please enter valid IBAN');
                } else {
                    requestedBic = ibanResponse.all_bic_candidates.get(0).bic;
                }
            } else {
                requestedBic = 'GKCCBEBB';
            }
        }
        
        return requestedBic;
    }


    /*******************************************************************************
    *  Name            : requestBic(IBAN_BIC__c ibanBicSettings)
    *  Summary         : Send request to BIC
    *  CreatedDate     : 28/10/2019
    *  ModifiedDate    : -
    *  Parameters      : IBAN_BIC__c ibanBicSettings - iban bic settings
    *  Returns         : void
    ******************************************************************************/
    public IbanResponse requestBic(IBAN_BIC__c ibanBicSettings) {
        Blob headerValue = Blob.valueOf(ibanBicSettings.User_Name__c + ':' + ibanBicSettings.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = ibanBicSettings.Endpoint__c + this.opp.IBAN__c;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', authorizationHeader);
        HttpResponse response = h.send(request);
        IbanResponse ibanResponse = (IbanResponse) JSON.deserialize(response.getBody(), IbanResponse.class);
        return ibanResponse;
    }


    /*******************************************************************************
    *  Name            : validateResubmitForApproval(String approveProcessName)
    *  Summary         : validating Resubmit For Approval (note: 00e20000001nSOBAA2 = 'System Administrator')
    *  CreatedDate     : 21/06/2017
    *  ModifiedDate    : 22/11/2019
    *  Parameters      : String approveProcessName
    *  Returns         : void
    ******************************************************************************/
    public void validateResubmitForApproval(String approveProcessName) {
        if (this.opp.OwnerId != this.acc.OwnerId && UserInfo.getProfileId() != '00e20000001nSOBAA2') {
            throw new MessageException('Opportunity owner should be the same as Account owner.');
        }
        if (this.opp.CF_Stage__c != null && this.opp.CF_Stage__c.contains('Pending Credit Report')) {
            throw new MessageException('Please waiting for Credit Report.');
        }
        if (this.opp.RecordType.Name == 'Carnet') {
            if (this.opp.Total_One_time_Payment__c == null || this.opp.Total_One_time_Payment__c == 0) {
                throw new MessageException('Total One-time Payment shouldn\'t be 0');
            } else if (this.opp.Type == 'Existing GFN') {
                throw new MessageException('Existing customers do not require additional Credit Approval.');
            }
        }
        if ((this.opp.Registered_Country__c == 'Germany' || this.opp.Registered_Country__c == 'Netherlands' || this.opp.Registered_Country__c == 'Belgium-NL' ||
                this.opp.Registered_Country__c == 'France' || this.opp.Registered_Country__c == 'Belgium-FR' || this.opp.Registered_Country__c == 'Poland' ||
                this.opp.Registered_Country__c == 'Hungary' || this.opp.Registered_Country__c == 'Austria' || this.opp.Registered_Country__c == 'Switzerland-DE' ||
                this.opp.Registered_Country__c == 'Switzerland-FR' || this.opp.Registered_Country__c == 'Switzerland-IT' || this.opp.Registered_Country__c == 'Luxembourg' ||
                this.opp.Registered_Country__c == 'Slovakia' || this.opp.Registered_Country__c == 'Czech Republic') &&
                (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Lotos' || this.opp.RecordType.Name == 'CCS Opportunity Layout') &&
                this.opp.Last_CF_Errors__c == null && this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check' &&
                this.opp.CF_Stage__c != 'Pending Advance Payment') {
            throw new MessageException('Please process your Opportunity in Credit Factory before submitting it for manual review.');
        }
        if (this.opp.StageName == 'Closed Won') {
            throw new MessageException('You can\'t submit this opportunity for approval because it\'s already Closed Won');
        }
        String stage;
        if (opp.RecordType.Name == 'Lotos') {
            stage = opp.Credit_Stage__c;
        } else {
            stage = opp.StageName;
        }
        if (stage == 'CreditCheck' ||
            stage == 'Pending Credit Check' || 
            stage == 'Credit Check - Pending Credit' || 
            stage == 'Pending Credit AML') {
            throw new MessageException('This opportunity is already in the stage of CreditCheck.');
        }
        if ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'HOME 1' || this.opp.Product__c == 'Inbound Typ C') &&
                (this.opp.Datansatztyp_auto__c.containsIgnoreCase('Euroshell') || this.opp.Datansatztyp_auto__c.containsIgnoreCase('Lotos'))) {
            if (String.isBlank(this.opp.Home_Station__c)) {
                throw new MessageException('Please fill homestation.');
            } else if (String.isBlank(opp.ESI__c)) {
                throw new MessageException('Please fill ESI.');
            }
        }
        if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
            if (this.pi.get(0).Status == 'Pending') {
                if (this.opp.StageName != 'Pending Sales – Information' && this.opp.StageName != 'Pending Sales – Deposit') {
                    throw new MessageException('This action is available for Pending Sales Opportunity Stage only.');
                }
                if (approveProcessName == 'CreditCheck' &&
                    ((this.acc.BillingCountry != 'Germany' && this.acc.BillingCountry != 'Austria') ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_BE' && 
                    (! this.acc.BillingCountry.contains('Belgium') ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_BeNeFra' &&
                    (this.acc.BillingCountry != 'Netherlands' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_Callcenter' &&
                    ((this.acc.BillingCountry != 'Germany' && this.acc.BillingCountry != 'Austria') ||
                    this.opp.Total_consumption_l_month__c == null ||
                    UserInfo.getProfileId() != '00e20000001AnIR' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Zahlungsziel__c == null ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_HU' &&
                    ( this.acc.BillingCountry != 'Hungary' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_PL' &&
                    (this.acc.BillingCountry != 'Poland' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_CH' &&
                    (! this.acc.BillingCountry.contains('Switzerland') ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_LU' &&
                    (this.acc.BillingCountry != 'Luxembourg' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_SK' &&                   
                    (this.acc.BillingCountry != 'Slovakia' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_CZ' &&   
                    (this.acc.BillingCountry != 'Czech Republic' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_Fra' &&  
                    (this.acc.BillingCountry != 'France' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null))
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                }
            }
        } else if (this.opp.RecordType.Name == 'Carnet') {
            if (this.pi.get(0).Status == 'Pending') {
                    if (this.acc.BillingCountry != 'Poland' || 
                            this.acc.Beschaeftigte__c == null || 
                            this.opp.Sec_Channel__c == null ||
                            this.opp.Product__c == null) {
                        throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.'); 
                }
            }
        } else if (this.opp.RecordType.Name == 'Lotos') {
            if (! isLotosRecordValid()) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            }
        }
        else if (this.opp.RecordType.Name == 'CCS Opportunity Layout') {
            if (this.acc.BillingCountry == 'Czech Republic' &&
                    (this.opp.Anzahl_der_Karten__c == null ||
                            this.opp.Total_consumption_l_month__c == null ||
                            this.acc.Beschaeftigte__c == null ||
                            this.opp.Total_consumption_per_card__c == null &&
                            this.opp.Total_cards_consumption_monthly__c == null)) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            }
            else if (this.acc.BillingCountry == 'Slovakia' &&
                    (this.opp.Anzahl_der_Karten__c == null ||
                            this.opp.Total_consumption_l_month__c == null ||
                            this.acc.Beschaeftigte__c == null ||
                            this.opp.Total_consumption_per_card__c == null &&
                            this.opp.Total_cards_consumption_monthly__c == null ||
                            this.primaryContact.FirstName == null ||
                            this.primaryContact.Birthdate == null)) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            }
        }
    }
    
    
    /*******************************************************************************
    *  Name            : isLotosRecordValid()
    *  Summary         : Validate Lotos Record for submitting for approval    
    *  CreatedDate     : 22/11/2019
    *  ModifiedDate    : 09/12/2019
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isLotosRecordValid() {
        if (this.acc.BillingCountry != 'Poland' || this.acc.BillingCountry == 'Poland' && (this.opp.Anzahl_der_Karten__c == null || this.opp.Language_preference__c == null || 
                this.opp.Total_consumption_per_card__c == null && this.opp.Total_cards_consumption_monthly__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null || this.acc.Beschaeftigte__c == null || ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || 
                this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) || 
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) || this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)))) {
            return false;
        } else {
            return true;
        }
    }


    /*******************************************************************************
    *  Name            : generateOppRequiredFieldsList(String currentUserProfile)
    *  Summary         : generate Opportunity Required Fields List    
    *  CreatedDate     : 21/06/2017
    *  ModifiedDate    : 25/11/2019
    *  Parameters      : currentUserProfile
    *  Returns         : fields list
    ******************************************************************************/
    public List<String> generateOppRequiredFieldsList(String currentUserProfile) {
        List<String> additionalRequiredFieldsList = new List<String>();
        if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
            if ((this.acc.BillingCountry == 'Germany' || this.acc.BillingCountry == 'Austria') && currentUserProfile == 'Callcenter') { return oppFieldsEuroshellList_ATDEcallcenter; } 
            else if ((this.acc.BillingCountry == 'Germany' || this.acc.BillingCountry == 'Austria')) { 
                return oppFieldsEuroshellList_ATDE; 
            } else if (this.acc.BillingCountry.contains('Belgium')) { 
                return oppFieldsEuroshellList_BE; 
            } else if (this.acc.BillingCountry == 'Netherlands') { 
                return oppFieldsEuroshellList_NL; 
            } else if (this.acc.BillingCountry == 'Hungary') { 
                return oppFieldsEuroshellList_HU; 
            } else if (this.acc.BillingCountry == 'Poland') { 
                return oppFieldsEuroshellList_PL; 
            } else if (this.acc.BillingCountry.contains('Switzerland')) { 
                return oppFieldsEuroshellList_CH; 
            } else if (this.acc.BillingCountry == 'Luxembourg') { 
                return oppFieldsEuroshellList_LU; 
            } else if (this.acc.BillingCountry == 'Slovakia') { 
                return oppFieldsEuroshellList_SK; 
            } else if (this.acc.BillingCountry == 'Czech Republic') { 
                return oppFieldsEuroshellList_CZ; 
            } else if (this.acc.BillingCountry == 'France') { 
                return oppFieldsEuroshellList_FR; 
            }     
        } else if (this.opp.RecordType.Name == 'Carnet') {
            return oppFieldsCarnetList_PL; 
        } else if (this.opp.RecordType.Name == 'Lotos' && this.acc.BillingCountry == 'Poland') {
            return oppFieldsLotosList_PL;
        }
        else if (this.opp.RecordType.Name == 'CCS Opportunity Layout') {
            if (this.acc.BillingCountry == 'Czech Republic') {
                return oppFieldsCCSList_CZ;
            }
            else if (this.acc.BillingCountry == 'Slovakia') {
                return oppFieldsCCSList_SK;
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : generateAccRequiredFieldsList()
    *  Summary         : generate Account Required Fields List
    *  CreatedDate     : 21/06/2017
    *  ModifiedDate    : 25/11/2019
    *  Parameters      : -
    *  Returns         : fields list
    ******************************************************************************/
    public List<String> generateAccRequiredFieldsList(String currentUserProfile) {
        if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
            if ((this.acc.BillingCountry == 'Germany' || this.acc.BillingCountry == 'Austria')) {
                return accFieldsEuroshellList_ATDE;
            } 
            else if (this.acc.BillingCountry.contains('Belgium')) { return accFieldsEuroshellList_BE; } 
            else if (this.acc.BillingCountry == 'Netherlands') { return accFieldsEuroshellList_NL; } 
            else if (this.acc.BillingCountry == 'Hungary') { return accFieldsEuroshellList_HU; } 
            else if (this.acc.BillingCountry == 'Poland') { return accFieldsEuroshellList_PL; } 
            else if (this.acc.BillingCountry.contains('Switzerland')) { return accFieldsEuroshellList_CH; } 
            else if (this.acc.BillingCountry == 'Luxembourg') { return accFieldsEuroshellList_LU; } 
            else if (this.acc.BillingCountry == 'Slovakia') { return accFieldsEuroshellList_SK; } 
            else if (this.acc.BillingCountry == 'Czech Republic') { return accFieldsEuroshellList_CZ; } 
            else if (this.acc.BillingCountry == 'France') { return accFieldsEuroshellList_FR; }    
        } else if (this.opp.RecordType.Name == 'Carnet') {
            return accFieldsCarnetList_PL; 
        } else if (this.opp.RecordType.Name == 'Lotos' && this.acc.BillingCountry == 'Poland') {
            return accFieldsLotosList_PL;
        }
        else if (this.opp.RecordType.Name == 'CCS Opportunity Layout') {
            if (this.acc.BillingCountry == 'Czech Republic') {
                return accFieldsCCSList_CZ;
            }
            else if (this.acc.BillingCountry == 'Slovakia') {
                return accFieldsCCSList_SK;
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : saveAndBack()
    *  Summary         : back to opportunity with saving    
    *  CreatedDate     : 24/05/2017
    *  ModifiedDate    : 10/12/2019
    *  Parameters      : -
    *  Returns         : opportunity page
    ******************************************************************************/
    public PageReference saveAndBack() {
        String stage;
        if (opp.RecordType.Name == 'Lotos') {
            stage = opp.Credit_Stage__c;
        } else {
            stage = opp.StageName;
        }
        if (stage == 'CreditCheck' || 
            stage == 'Credit Check - Pending Credit' || 
            stage == 'Pending Credit AML' ||
            stage == 'Closed Won') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can\'t save. This opportunity is locked.'));
                PageReference page = new PageReference('/apex/CustomSubmitForApproval?id=' + opp.Id);
                return page;
        } else {
            if (! Test.isRunningTest()) {
                update acc;
                update opp; 
            }
            PageReference page = new PageReference('/' + opp.Id);
            return page;
        }
    }


    /*******************************************************************************
    *  Name            : backToOpportunity()
    *  Summary         : back to opportunity without saving    
    *  CreatedDate     : 24/05/2017
    *  Parameters      : -
    *  Returns         : opportunity page
    ******************************************************************************/
    public PageReference backToOpportunity() {
        PageReference page = new PageReference('/' + opp.Id);
        return page;
    }


    /*******************************************************************************
    *  Name            : changeRegisteredCountry()
    *  Summary         : return account page    
    *  CreatedDate     : 29/05/2017
    *  Parameters      : -
    *  Returns         : account page
    ******************************************************************************/
    public PageReference changeRegisteredCountry() {
        PageReference page = new PageReference('/' + acc.Id);
        return page;
    }

    public class MessageException extends Exception {}

    //1.1 Opportunity required fields for CreditCheck_Callcenter approval process (Germany, Austria)
    public static List<String> oppFieldsEuroshellList_ATDEcallcenter = new List<String> {
        'Anzahl_der_Karten__c',
        'Zahlungsart__c',
        'Zahlungsziel__c'      
    };

    //2.1 Opportunity required fields for CreditCheck approval process (Germany, Austria)
    public static List<String> oppFieldsEuroshellList_ATDE = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'    
    };
    //2.2 Account required fields for CreditCheck approval process (Germany, Austria)
    public static List<String> accFieldsEuroshellList_ATDE = new List<String> {
        'Beschaeftigte__c'
    };


    //3.1 Opportunity required fields for CreditCheck_BE approval process (Belgium-NL, Belgium-FR)
    public static List<String> oppFieldsEuroshellList_BE = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //3.2 Account required fields for CreditCheck_BE approval process (Belgium-NL, Belgium-FR)
    public static List<String> accFieldsEuroshellList_BE = new List<String> {
        'Beschaeftigte__c'
    };


    //4.1 Opportunity required fields for CreditCheck_NL approval process (Netherlands)
    public static List<String> oppFieldsEuroshellList_NL = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //4.2 Account required fields for CreditCheck_NL approval process (Netherlands)
    public static List<String> accFieldsEuroshellList_NL = new List<String> {
        'Beschaeftigte__c'
    };


    //5.1 Opportunity required fields for CreditCheck_HU approval process (Hungary)
    public static List<String> oppFieldsEuroshellList_HU = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //5.2 Account required fields for CreditCheck_HU approval process (Hungary)
    public static List<String> accFieldsEuroshellList_HU = new List<String> {
        'Beschaeftigte__c'
    };


    //6.1 Opportunity required fields for CreditCheck_PL approval process (Poland)
    public static List<String> oppFieldsEuroshellList_PL = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //6.2 Account required fields for CreditCheck_PL approval process (Poland)
    public static List<String> accFieldsEuroshellList_PL = new List<String> {
        'Beschaeftigte__c'
    };


    //7.1 Opportunity required fields for CreditCheck_CH approval process (Switzerland-NL, Switzerland-FR, Switzerland-IT)
    public static List<String> oppFieldsEuroshellList_CH = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //7.2 Account required fields for CreditCheck_CH approval process (Switzerland-NL, Switzerland-FR, Switzerland-IT)
    public static List<String> accFieldsEuroshellList_CH = new List<String> {
        'Beschaeftigte__c'
    };


    //8.1 Opportunity required fields for CreditCheck_LU approval process (Luxembourg)
    public static List<String> oppFieldsEuroshellList_LU = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //8.2 Account required fields for CreditCheck_LU approval process (Luxembourg)
    public static List<String> accFieldsEuroshellList_LU = new List<String> {
        'Beschaeftigte__c'
    };


    //9.1 Opportunity required fields for CreditCheck_SK approval process (Slovakia)
    public static List<String> oppFieldsEuroshellList_SK = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //9.2 Account required fields for CreditCheck_SK approval process (Slovakia)
    public static List<String> accFieldsEuroshellList_SK = new List<String> {
        'Beschaeftigte__c'
    };


    //10.1 Opportunity required fields for CreditCheck_CZ approval process (Czech Republic)
    public static List<String> oppFieldsEuroshellList_CZ = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //10.2 Account required fields for CreditCheck_CZ approval process (Czech Republic)
    public static List<String> accFieldsEuroshellList_CZ = new List<String> {
        'Beschaeftigte__c'
    };


    //11.1 Opportunity required fields for CreditCheck_Fra approval process (France)
    public static List<String> oppFieldsEuroshellList_FR = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //11.2 Account required fields for CreditCheck_Fra approval process (France)
    public static List<String> accFieldsEuroshellList_FR = new List<String> {
        'Beschaeftigte__c'
    };
    //13.1 Account required fields for CreditCheck_PL_Carnet approval process (Poland)
    public static List<String> accFieldsCarnetList_PL = new List<String> {
        'Beschaeftigte__c'
    };
    //13.2 Account required fields for CreditCheck_PL_Carnet approval process (Poland)
    public static List<String> oppFieldsCarnetList_PL = new List<String> {
        'Language_preference__c',
        'Sec_Channel__c',
        'Product__c',
        'Total_One_time_Payment__c'
    };
    //14.1 Opportunity required fields for CreditCheck_PL approval process (Poland)
    public static List<String> oppFieldsLotosList_PL = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //14.2 Account required fields for CreditCheck_PL approval process (Poland)
    public static List<String> accFieldsLotosList_PL = new List<String> {
            'Beschaeftigte__c'
    };
    //15.1 Opportunity required fields for CreditCheck_CZ_CCS approval process (Czech Republic)
    public static List<String> oppFieldsCCSList_CZ = new List<String> {
            'Anzahl_der_Karten__c'
    };
    //15.2 Account required fields for CreditCheck_CZ_CCS approval process (Czech Republic)
    public static List<String> accFieldsCCSList_CZ = new List<String> {
            'Beschaeftigte__c'
    };
    //16.1 Opportunity required fields for CreditCheck_SK_CCS approval process (Czech Republic)
    public static List<String> oppFieldsCCSList_SK = new List<String> {
            'Anzahl_der_Karten__c'
    };
    //16.2 Account required fields for CreditCheck_SK_CCS approval process (Slovakia)
    public static List<String> accFieldsCCSList_SK = new List<String> {
            'Beschaeftigte__c'
    };
}