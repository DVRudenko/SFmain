public class CreditFactoryReportController {
    public CreditCompany company {get; set;}
    public CreditCompany additionalCompany {get; set;}
    public List<CreditCompanyEmployee> companyEmployeesList {get; set;}
    public List<CreditCompanyEmployee> additionalCompanyEmployeesList {get; set;}
    public Opportunity currentOpportunity {get; set;}
    public CreditSystem creditService {get; set;}
    public Integer billingPeriod {get; set;}
    public Decimal deposit {get; set;}
    public Boolean isValid {get; set;}
    public Boolean isInvalidAddress {get; set;}
    public Boolean isInvalidBillingAddress {get; set;}
    public Boolean isInvalidShippingAddress {get; set;}
    public Boolean isInvalidCompanyName {get; set;}
    public Boolean isInvalidContact {get; set;}
    public Boolean isInvalidContactRole {get; set;}
    public Boolean isInvalidTaxId {get; set;}
    public Boolean isInvalidVatNumber {get; set;}
    public Boolean isInvalidTradeRegisterNumber {get; set;}
    public Boolean isInvalidLostOpportunity {get; set;}
    public Boolean isPublicEntity {get; set;}
    public Boolean isEntrepreneurialCompany {get; set;}
    public Boolean isInvalidPaymentMethod {get; set;}
    public Boolean isInvalidRequestStatus {get; set;}
    public Boolean isInvalidEmailRisk {get; set;}
    public Boolean isInvalidSwiftBic {get; set;}
    public String creditSystemName {get; set;}
    public Boolean isPendingSEPAPossible {get; set;}
    public Boolean isAutoCWPossible {get; set;}
    public Boolean isError {get; set;}
    public CreditReport reportService;
    private Credit_Factory_Opportunity__c opportunityMapping; 
    public final String ADDRESS_ERROR = 'Address';
    public final String EMPTY_ADDRESS_ERROR = 'EmptyAddress';
    public final String BILLING_ADDRESS_ERROR = 'BillingAddress';
    public final String SHIPPING_ADDRESS_ERROR = 'ShippingAddress';
    public final String COMPANY_NAME_ERROR = 'CompanyName';
    public final String CONTACT_ERROR = 'Contact';
    public final String CONTACT_ROLE_ERROR = 'ContactRole';
    public final String TAX_ID_ERROR = 'TaxId';
    public final String VAT_NUMBER_ERROR = 'VatNumber';
    public final String TRADE_REGISTER_NUMBER_ERROR = 'TradeRegisterNumber';
    public final String LOST_OPPORTUNITY_ERROR = 'LostOpportunity';
    public final String PUBLIC_ENTITY_ERROR = 'PublicEntity';
    public final String ENTREPRENEURIAL_COMPANY_ERROR = 'EntrepreneurialCompany';
    public final String PAYMENT_METHOD_ERROR = 'PaymentMethod';
    public final String REQUEST_STATUS_ERROR = 'RequestStatus';
    public final String EMAIL_RISK_ERROR = 'EmailRisk';
    public final String SWIFT_BIC_ERROR = 'SwiftBic';
    public String opportunityId {get; set;}
    public String parentCompanyId {get; set;}
    public String contactRoleConfirmation {get; set;}
    public String callId {get; set;}
    public String confirmationMessage {get; set;}
    public String companyNameType {get; set;}
    public Boolean isWaitingReport {get; set;}
    public String creditSystemCompanyNumber;


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : Initial method. Set default values. Get parameters, credit service, report service, opportunity. 
                         Create PDF attachment report.
    *  CreatedDate     : 11/11/2016
    *  ModifiedDate    : 06/11/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        this.isWaitingReport = false;
        opportunityId = Apexpages.currentPage().getParameters().get('opportunityId');
        creditSystemCompanyNumber = Apexpages.currentPage().getParameters().get('creditSystemCompanyNumber');
        if (opportunityId == null) {
            CreditFactoryUtilities.displayMessage('error','Invalid opportunityId parameter.' + CreditFactoryUtilities.CONTACT_ADMIN);
            return;
        }
        if (creditSystemCompanyNumber == null) {
            CreditFactoryUtilities.displayMessage('error','Invalid creditSystemCompanyNumber parameter.' + CreditFactoryUtilities.CONTACT_ADMIN);
            return;
        }
        
        try {
            this.isError = false;
            // Set Credit System
            creditService = new CreditSystemService(); 
            creditService.setCreditSystemSource(opportunityId);

            // Set Creditreform Report Service and account/opportunity mapping from custom settings
            this.creditSystemName = creditService.getCreditSystemName();
            reportService = returnReportService(this.creditSystemName, opportunityId);
            reportService.setMapping();

            // Set Opportunity record
            reportService.setSourceObject(opportunityId);
            currentOpportunity = (Opportunity)reportService.getSourceObject();

            // get Credit Report from SF if exists
            reportService.setExistingCreditReports();

            // Send request
            reportService.setCompany(creditService, creditSystemCompanyNumber);
            company = (CreditCompany) reportService.getCompany();
            if (company != null) {
                this.isWaitingReport = company.isWaitingReport;
            }
            
            if (this.isWaitingReport != true) {
                processReadyReport();
            }
        } catch (Exception e) {
            processExceptions(e);
        }
    }


    /*******************************************************************************
    *  Summary         : check report status  
    *  Created         : 23/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void checkReportStatus() {
        try {
            reportService.setCompany(creditService, creditSystemCompanyNumber);
            company = (CreditCompany) reportService.getCompany();
            if (company != null) {
                this.isWaitingReport = company.isWaitingReport;
            }

            if (this.isWaitingReport == false) {
                processReadyReport();
            }
        } catch (Exception e) {
            company = (CreditCompany) reportService.getCompany();
            if (company != null) {
                this.isWaitingReport = company.isWaitingReport;
            }
            
            processExceptions(e);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : process with ready report   
    *  Created         : 23/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void processReadyReport() {
        reportService.setAdditionalCompany(creditSystemCompanyNumber);
        reportService.setEmployees();
        reportService.setAdditionalCompanyEmployees(creditSystemCompanyNumber);
        reportService.setAdditionalScoringData(null);
        
        // Get Company and Employees
        company = (CreditCompany)reportService.getCompany();
        companyEmployeesList = (List<CreditCompanyEmployee>)reportService.getEmployees();
        this.additionalCompany = reportservice.getAdditionalCompany();
        this.additionalCompanyEmployeesList = reportService.getAdditionalCompanyEmployees();

        // check errors to do an order
        String errorToRequestOrder = reportService.getErrorToOrderRequest();
        if (errorToRequestOrder != null) {
            Order orderService = returnOrderService(this.creditSystemName);
            orderService.validateOpportunity(this.currentOpportunity, errorToRequestOrder);
            CreditCompany company = orderService.doOrder(creditService, this.currentOpportunity, errorToRequestOrder, reportService.getInternalId());
            orderService.updateOpportunity(this.currentOpportunity, company, errorToRequestOrder);
            throw new CreditFactoryException(errorToRequestOrder + ' ' + orderService.getSuccessfulOrderStatus());
        }
        
        this.isPendingSEPAPossible = reportService.isPendingSEPAPossible();
        this.isAutoCWPossible = reportService.isAutoCWPossible();

        // Validation
        doValidate();

        // Create PDF Report
        Boolean isPdfCreated = reportService.doCreateReportAttachment(opportunityId);
        if (isPdfCreated) {
            reportService.updateOpportunityWithPDF(currentOpportunity);
        }

        // Create xml report
        reportService.saveReports();
    }
    
    
    /*******************************************************************************
    *  Summary         : process in case of exceptions (save report if possible, save errors)   
    *  Created         : 23/03/2020
    *  Parameters      : e - exception
    *  Returns         : -
    ******************************************************************************/
    public void processExceptions(Exception e) {
        this.isError = true;
        // save pdf and xml reports in case of exceptions
         if (reportService != null) {
             Boolean isPdfCreated = reportService.doCreateReportAttachment(opportunityId);
             if (isPdfCreated) {
                 reportService.updateOpportunityWithPDF(currentOpportunity);
             }

             reportService.saveReports();
         }
        CreditFactoryUtilities.displayMessage('error',e.getMessage());
        saveAllErrorsInOpportunity();
    }


    /*******************************************************************************
    *  Name            : calculateBillingPeriod()
    *  Summary         : Do calculate billing period
    *  CreatedDate     : 20/12/2016
    *  ModifiedDate    : 29/11/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void calculateBillingPeriod() {
        try {
            reportService.setFuelPriceIndex();
            reportService.setBuffer(this.company.classRating);
            reportService.setRiskCategory(this.company.classRating);
            reportService.setSecurityLevel(this.company.classRating);
            reportService.setCreditLimitWeeklyPlus7(reportService.getBuffer());
            reportService.setMaxCreditLimitWeeklyPlus7();
            reportService.setMaxValueWeeklyPlus7();
            reportService.setDepositWeeklyPlus7();
            reportService.setCreditLimitBiWeeklyPlus7(reportService.getBuffer());
            reportService.setMaxCreditLimitBiWeeklyPlus7();
            reportService.setMaxValueBiWeeklyPlus7();
            reportService.setDepositBiWeeklyPlus7();
            reportService.setCreditLimitBiWeeklyPlus14(reportService.getBuffer());
            reportService.setMaxCreditLimitBiWeeklyPlus14();
            reportService.setMaxValueBiWeeklyPlus14();
            reportService.setDepositBiWeeklyPlus14();
            reportService.setCreditLimitMonthlyPlus7(reportService.getBuffer());
            reportService.setMaxCreditLimitMonthlyPlus7();
            reportService.setMaxValueMonthlyPlus7();
            reportService.setDepositMonthlyPlus7();
            reportService.setCreditLimitMonthlyPlus14(reportService.getBuffer());
            reportService.setMaxCreditLimitMonthlyPlus14();
            reportService.setMaxValueMonthlyPlus14();
            reportService.setDepositMonthlyPlus14();
            reportService.setCreditLimitMonthlyPlus21(reportService.getBuffer());
            reportService.setMaxCreditLimitMonthlyPlus21();
            reportService.setDepositMonthlyPlus21();
            reportService.setCreditLimitMonthlyPlus27(reportService.getBuffer());
            reportService.setMaxCreditLimitMonthlyPlus27();
            reportService.setMaxValueMonthlyPlus27();
            reportService.setDepositMonthlyPlus27();
            reportService.setPaymentDetails();
            reportService.setCreditLimit();
            reportService.setMaxCreditLimit();
            reportService.setMaxValue();
            reportService.setDeposit();
            reportService.setDecision();
            reportService.updateDefaultFieldSetForRecord();
            reportService.updateDefaultFieldSetForValidRecord();
            if (!isInvalidMandateType()) {
                this.billingPeriod = reportService.getBillingPeriod();
                this.deposit = reportService.getDeposit();
                reportService.checkWarnings();
            }

            saveAllErrorsInOpportunity();
        } catch (Exception e) {
            throw new CreditFactoryException(e.getMessage());
        }
    }
    
    
    /*******************************************************************************
    *  Name            : isInvalidMandateType()
    *  Summary         : Check error with mandate type.
    *  CreatedDate     : 29/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isInvalidMandateType() {
        for (ApexPages.Message message : ApexPages.getMessages()) {
            if (message.getSeverity() == ApexPages.Severity.ERROR && message.getSummary() == CreditFactoryUtilities.UNAVAILABLE_MANDATE_TYPE) {
                return true;
            }
        }
        
        return false;
    }
    

    /*******************************************************************************
    *  Name            : doValidate()
    *  Summary         : Do validation
    *  CreatedDate     : 11/11/2016
    *  ModifiedDate    : 09/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doValidate() {
        this.isError = false;
        this.isInvalidAddress = false;
        this.isInvalidBillingAddress = false;
        this.isInvalidShippingAddress = false;
        this.isInvalidCompanyName = false;
        this.isInvalidContact = false;
        this.isInvalidContactRole = false;
        this.isInvalidTaxId = false;
        this.isInvalidVatNumber = false;
        this.isInvalidLostOpportunity = false;
        this.isInvalidTradeRegisterNumber = false;
        this.isPublicEntity = false;
        this.isEntrepreneurialCompany = false;
        this.isInvalidPaymentMethod = false;
        this.isInvalidRequestStatus = false;
        this.isInvalidEmailRisk = false;
        this.isInvalidSwiftBic = false;
        this.isValid = reportService.validate();
        Boolean isInvalidFieldsUpdate = true;
        Set<String> errorsSet = reportService.getErrorsSet();
        if ( ! this.isValid ) {
            this.isError = true;
            if ( errorsSet.contains(ADDRESS_ERROR) && ! errorsSet.contains(EMPTY_ADDRESS_ERROR)) {
                this.isInvalidAddress = true;
                isInvalidFieldsUpdate = false;
            }
            if ( errorsSet.contains(BILLING_ADDRESS_ERROR) ) {
                this.isInvalidBillingAddress = true;
                isInvalidFieldsUpdate = false;
            }
            if ( errorsSet.contains(SHIPPING_ADDRESS_ERROR) ) {
                this.isInvalidShippingAddress = true;
                isInvalidFieldsUpdate = false;
            }
            if ( errorsSet.contains(COMPANY_NAME_ERROR) ) {
                this.isInvalidCompanyName = true;
                isInvalidFieldsUpdate = false;
            }
            if ( errorsSet.contains(TAX_ID_ERROR) ) {
                this.isInvalidTaxId = true;
                isInvalidFieldsUpdate = false;
            }
            if ( errorsSet.contains(VAT_NUMBER_ERROR) ) {
                this.isInvalidVatNumber = true;
                isInvalidFieldsUpdate = false;
            }
            if ( errorsSet.contains(TRADE_REGISTER_NUMBER_ERROR) ) {
                this.isInvalidTradeRegisterNumber = true;
                isInvalidFieldsUpdate = false;
            }
            if ( errorsSet.contains(LOST_OPPORTUNITY_ERROR) ) {
                this.isInvalidLostOpportunity = true;
                isInvalidFieldsUpdate = false;
            }
            if ( errorsSet.contains(PAYMENT_METHOD_ERROR) ) {
                this.isInvalidPaymentMethod = true;
                isInvalidFieldsUpdate = false;
            }
            if ( errorsSet.contains(REQUEST_STATUS_ERROR) ) {
                this.isInvalidRequestStatus = true;
            }
            if (errorsSet.contains(EMAIL_RISK_ERROR)) {
                this.isInvalidEmailRisk = true;
            }
            if (errorsSet.contains(SWIFT_BIC_ERROR)) {
                this.isInvalidSwiftBic = true;
                isInvalidFieldsUpdate = false;
            }
            if (isInvalidFieldsUpdate) {
                reportService.updateDefaultFieldSetForRecord();
            }

            for (ApexPages.Message message : ApexPages.getMessages()) {
                if (message.getSummary() == 'Decision about deposit was accepted for your client.') {
                    throw new CreditFactoryException('Decision about deposit was accepted for your client.');
                }
            }

            throw new CreditFactoryException('Fix all validation errors or refer to Credit.');
        }

        if ( errorsSet.contains(PUBLIC_ENTITY_ERROR) ) {
            this.isPublicEntity = true;
        }
        if ( errorsSet.contains(ENTREPRENEURIAL_COMPANY_ERROR) ) {
            this.isEntrepreneurialCompany = true;
        }
        if ( errorsSet.contains(CONTACT_ERROR) ) {
            this.isInvalidContact = true;
            this.reportService.setParentCompanyId();
            this.parentCompanyId = reportService.getParentCompanyId();
            isInvalidFieldsUpdate = false;
        } 
        if ( errorsSet.contains(CONTACT_ROLE_ERROR)) {
            this.isInvalidContactRole = true;
        }
        
        calculateBillingPeriod();
    }


    /*******************************************************************************
    *  Name            : doUpdateAddress()
    *  Summary         : Update address information in Account based on address from CreditReform and validate data
    *  CreatedDate     : 11/11/2016
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateAddress() {
        try {
            reportService.doUpdateAddress();
            this.confirmationMessage = 'Address has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }     
    }


    /*******************************************************************************
    *  Name            : doUpdateWithAdditionalAddress()
    *  Summary         : Update address information in Account based on address from additional report
    *  CreatedDate     : 20/04/2018
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateWithAdditionalAddress() {
        try {
            reportService.doUpdateWithAdditionalAddress();
            this.confirmationMessage = 'Address has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }     
    }


    /*******************************************************************************
    *  Name            : doUpdateWithPostalAddress()
    *  Summary         : Update Address based on Postal address from Credit System.
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateWithPostalAddress() {
        try {
            this.reportService.doUpdateWithPostalAddress();
            this.confirmationMessage = 'Address has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error', e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }


    /*******************************************************************************
    *  Name            : doUpdateWithRegisteredAddress()
    *  Summary         : Update Address based Registered on address from Credit System.    
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateWithRegisteredAddress() {
        try {
            this.reportService.doUpdateWithRegisteredAddress();
            this.confirmationMessage = 'Address has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error', e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }


    /*******************************************************************************
    *  Name            : doUpdateCompanyName()
    *  Summary         : Update Account name with Credit System Company Name
    *  CreatedDate     : 11/11/2016
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateCompanyName() {
        try {
            reportService.doUpdateCompanyName(this.companyNameType);
            this.confirmationMessage = 'Account Name has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }


    /*******************************************************************************
    *  Name            : doUpdateWithAdditionalCompanyName()
    *  Summary         : Update Account name with Credit System Company Name from additional report
    *  CreatedDate     : 23/04/2018
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateWithAdditionalCompanyName() {
        try {
            reportService.doUpdateWithAdditionalCompanyName();
            this.confirmationMessage = 'Account Name has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }


    /*******************************************************************************
    *  Name            : doUpdateTaxId()
    *  Summary         : Update Account Tax Id with Credit System Tax Id
    *  CreatedDate     : 29/01/2017
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateTaxId() {
        try {
            reportService.doUpdateTaxId();
            this.confirmationMessage = 'Account Tax ID has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }


    /*******************************************************************************
    *  Name            : doUpdateVatNumber()
    *  Summary         : Update Account Vat Number with Credit System Vat Number
    *  CreatedDate     : 29/01/2017
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateVatNumber() {
        try {
            reportService.doUpdateVatNumber();
            this.confirmationMessage = 'Account VAT number has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }


    /*******************************************************************************
    *  Name            : doUpdateTradeRegisterNumber()
    *  Summary         : Update Account Trade Register Number with Credit System Trade Register Number
    *  CreatedDate     : 02/03/2017
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateTradeRegisterNumber() {
        try {
            reportService.doUpdateTradeRegisterNumber();
            this.confirmationMessage = 'Account Trade Register Number has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }
    
    
    /*******************************************************************************
    *  Name            : doUpdateSwiftBic()
    *  Summary         : Update Account Trade Register Number with Credit System Trade Register Number
    *  CreatedDate     : 02/03/2017
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateSwiftBic() {
        try {
            reportService.doUpdateSwiftBic();
            this.confirmationMessage = 'SWIFT BIC has been updated.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }


    /*******************************************************************************
    *  Name            : doParentCompanyRequest()
    *  Summary         : do new report request for company owned by another company    
    *  CreatedDate     : 3/12/2017
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doParentCompanyRequest() {
        try {
            this.reportService.updateEmployees(this.creditService, this.parentCompanyId);
            this.companyEmployeesList = (List<CreditCompanyEmployee>)this.reportService.getEmployees();
            this.reportService.setParentCompanyId();
            this.parentCompanyId = reportService.getParentCompanyId();
            this.currentOpportunity.CF_Parent_Report_Generated__c = true;
            update this.currentOpportunity;
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }

    /*******************************************************************************
    *  Name            : confirmContactRole()
    *  Summary         : Update Contact Role Confirmation field with tast relation    
    *  CreatedDate     : 06/06/2018
    *  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void confirmContactRole() {
        try {
            if (callId != null && callId != '') {
                Opportunity opportunity = new Opportunity(
                Id = this.currentOpportunity.Id,
                Contact_Role_Confirmation_Call__c = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + callId);
                update opportunity;
            }

            reportService.setSourceObject(this.currentOpportunity.Id);
            this.confirmationMessage = 'Contact role has been confirmed.';
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error', e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }


    /*******************************************************************************
    *  Name            : continueValidation()
    *  Summary         : Continue validation on complete of update data    
    *  CreatedDate     : 22/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void continueValidation() {
        try {
            if (this.confirmationMessage != null) {
                CreditFactoryUtilities.displayMessage('confirm', confirmationMessage);
            }
            currentOpportunity = (Opportunity)reportService.getSourceObject();
            doValidate();
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }
    }


    /*******************************************************************************
    *  Name            : returnReportService(String creditSystemName, String opportunityId) 
    *  Summary         : initialize report service based on Credit System Name     
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String creditSystemName – name of credit system from custom setting
                         String opportunityId – Salesforce record id
    *  Returns         : CreditReport – implementation of CreditReport
    *************************************** ***************************************/
    public CreditReport returnReportService(String creditSystemName, String opportunityId) {
        CreditReport internalReportService;
        if (creditSystemName.equalsIgnoreCase(CreditFactoryWebSchufa.CREDIT_SYSTEM_NAME)) {
            internalReportService = new ReportSchufaServiceDE();
        } else if (creditSystemName.equalsIgnoreCase(CreditsafeWebservice.CREDIT_SYSTEM_NAME)) {
            internalReportService = new ReportCreditsafeService();
        } else if (creditSystemName.equalsIgnoreCase(CofaceWebservice.CREDIT_SYSTEM_NAME)) {
            internalReportService = new ReportCofaceService();
        } else if (creditSystemName.equalsIgnoreCase(CreditReformWebserviceAT.CREDIT_SYSTEM_NAME)) {
            internalReportService = new ReportCreditreformServiceAT();
        } else if (creditSystemName.equalsIgnoreCase(CrediconnectWebserviceCH.CREDIT_SYSTEM_NAME)) {
            internalReportService = new ReportCrediconnectServiceCH();
        } else if (creditSystemName.equalsIgnoreCase(CreditReformWebserviceLU.CREDIT_SYSTEM_NAME)) {
            internalReportService = new ReportCreditreformServiceLU();
        } else {
            throw new CreditFactoryException('Invalid name for Credit setting.');
        }

        return internalReportService;
    }


    /*******************************************************************************
    *  Name            : returnOrderService(String creditSystemName) 
    *  Summary         : initialize order service based on Credit System Name     
    *  CreatedDate     : 29/06/2018
    *  ModifeidDate    : -
    *  Parameters      : String creditSystemName – name of credit system from custom setting
    *  Returns         : CreditReport – implementation of CreditReport
    ******************************************************************************/
    public Order returnOrderService(String creditSystemName) {
        Order orderService;
        if (creditSystemName.equalsIgnoreCase(CreditFactoryWebSchufa.CREDIT_SYSTEM_NAME)) {
            orderService = new OrderSchufaServiceDE();
        }
        else if (creditSystemName.equalsIgnoreCase(CofaceWebservice.CREDIT_SYSTEM_NAME)) {
            orderService = new OrderCofaceService();
        }
        else if (creditSystemName.equalsIgnoreCase(CreditReformWebserviceAT.CREDIT_SYSTEM_NAME)) {
            orderService = new OrderCreditreformServiceAT();
        } 
        else if (creditSystemName.equalsIgnoreCase(CreditReformWebserviceLU.CREDIT_SYSTEM_NAME)) {
            orderService = new OrderCreditreformServiceLU();
        }

        return orderService;
    }


    /*******************************************************************************
    *  Name            : changeBillingPeriodBySales()
    *  Summary         : Change Billing Period and Update Opportunity
    *  CreatedDate     : 14/11/2016
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference changeBillingPeriodBySales() {
        try {
            return reportService.changeBillingPeriodBySales();
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : changeToPendingSEPAConfirmation()
    *  Summary         : Change Opportunity StageName to Pending Sales - SEPA Confirmation
    *  CreatedDate     : 14/08/2017
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference changeToPendingSEPAConfirmation() {
        try {
            return reportService.changeToPendingSEPAConfirmation();
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : changeToClosedWon()
    *  Summary         : change Opportunity StageName to Closed Won
    *  CreatedDate     : 16/06/2017
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference changeToClosedWon() {
        try {
            return reportService.changeToClosedWon();
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
            return null;
        } 
    }


    /*******************************************************************************
    *  Name            : changeToContractCheck()
    *  Summary         : change Opportunity StageName to Pending Credit - Contract Check
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference changeToContractCheck() {
        try {
            return reportService.changeToContractCheck();
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
            return null;
        } 
    }


    /*******************************************************************************
    *  Name            : changeToPendingDeposit()
    *  Summary         : change Opportuinty StageName to Pending Sales - Deposit     
    *  CreatedDate     : 28/03/2018
    *  ModifiedDate    : 28/03/2018
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference changeToPendingDeposit() {
        try {
            reportService.changeToPendingDeposit();
            saveAllErrorsInOpportunity();
            return new PageReference('/' + this.opportunityId);
        } catch (Exception e) {
            this.isError = true;
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : backToOpporutnity()
    *  Summary         : Redirect to source Opportunity record     
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToOpportunity() {
        return new PageReference('/' + this.currentOpportunity.Id);
    }
    

    /*******************************************************************************
    *  Name            : saveAllErrorsInOpportunity()
    *  Summary         : save all validation errors in Credit_Factory_Errors__c field on Opportunity    
    *  CreatedDate     : 29/06/2017
    *  ModifiedDate    : 23/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveAllErrorsInOpportunity() {
        try {
            Set<String> creditFactoryErrorsSet = new Set<String>();
            if (! ApexPages.getMessages().isEmpty()) {
                for (ApexPages.Message message : ApexPages.getMessages()) {
                    if (message.getSeverity() == ApexPages.Severity.ERROR) {
                        creditFactoryErrorsSet.add(message.getSummary().replace('&quot;', '"'));
                    } else if (message.getSummary() == 'If you want to close your Opportunity with desired billing period and desired payment terms, please refer to Credit.') {
                        creditFactoryErrorsSet.add(message.getSummary());
                    }
                }
            }

            if (! creditFactoryErrorsSet.isEmpty()) {
                this.currentOpportunity = [
                        SELECT Credit_Factory_Errors__c, CF_Stage__c, Account.BillingStreet, Account.ShippingStreet, Account.BillingPostalCode, 
                            Account.ShippingPostalCode, Account.BillingCity, Account.ShippingCity, Account.Name, Account.Gesellschaftsform__c,
                            Account.Steuernummer__c, Account.Umsatzsteuer_ID__c, Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, SWIFT_BIC__c, 
                            Requested_SWIFT_BIC__c, Name, (
                                SELECT Id 
                                FROM Credit_Factory_Reports__r 
                                WHERE CreatedDate > :Date.today().addMonths(-3)
                                ORDER BY CreatedDate DESC
                                LIMIT 1)
                        FROM Opportunity 
                        WHERE Id = :this.opportunityId];

                for (String error : creditFactoryErrorsSet) {
                    error = CreditFactoryUtilities.clearErrorMessage(error);
                    if (this.currentOpportunity.Credit_Factory_Errors__c == null) {
                        this.currentOpportunity.Credit_Factory_Errors__c = error;
                    } else if (! this.currentOpportunity.Credit_Factory_Errors__c.contains(error)) {
                        this.currentOpportunity.Credit_Factory_Errors__c += '\n' + error;
                    }
                }

                if (this.currentOpportunity.CF_Stage__c != 'Auto CW' && this.currentOpportunity.CF_Stage__c != 'Manual scoring' &&
                        this.currentOpportunity.CF_Stage__c != 'Pending deposit' && this.currentOpportunity.CF_Stage__c != 'Pending Credit - Contract Check') {
                    this.currentOpportunity.Last_CF_Errors__c = null;
                    for (String error : creditFactoryErrorsSet) {
                        error = CreditFactoryUtilities.clearErrorMessage(error);
                        if (this.currentOpportunity.Last_CF_Errors__c == null) {
                            this.currentOpportunity.Last_CF_Errors__c = error;
                        } else {
                            this.currentOpportunity.Last_CF_Errors__c += '\n' + error;
                        }

                        if (! (this.currentOpportunity.CF_Stage__c.contains('Pending Credit Report') && 
                                this.currentOpportunity.Credit_Factory_Reports__r.size() == 0)) {
                            this.currentOpportunity.CF_Stage__c = 'Error (Report generated)';
                        }
                    }
                } else if (this.currentOpportunity.CF_Stage__c == 'Manual scoring') {
                    for (String error : creditFactoryErrorsSet) {
                        error = CreditFactoryUtilities.clearErrorMessage(error);
                        if (error == 'Duplicates found.') {
                            this.currentOpportunity.Last_CF_Errors__c = error;
                        }
                    }
                }
                
                if (! Test.isRunningTest()) {
                    update this.currentOpportunity;
                }
            }
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error', e.getMessage());
        }
    }
}