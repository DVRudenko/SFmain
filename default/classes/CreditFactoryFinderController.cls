public class CreditFactoryFinderController {
    public List<CreditCompany> companiesList {get; set;}
    public Opportunity currentOpportunity {get; set;}
    public String creditSystemName {get; set;}
    public CreditSystem creditService;
    public Finder finderService;
    public String opportunityId;
    public Set<String> creditFactoryErrorsSet;
    public String currentCompanyId;
    public Boolean displayTaxIdApprove {get; set;}


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : Initial method. Get parameters, credit service, finder service. Validate finder service.
                         Search for company in Credit System based on information from Opportunity.    
    *  CreatedDate     : 1/11/2016
    *  ModifiedDate    : 19/10/2017
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference init() {
        this.displayTaxIdApprove = false;
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        if (opportunityId == null) {
            CreditFactoryUtilities.displayMessage('error','Invalid record id.');
            return null;
        }

        //Credit system
        this.creditFactoryErrorsSet = new Set<String>();
        try {
            creditService = new CreditSystemService();
            creditService.setCreditSystemSource(opportunityId);

            //Finder 
            this.creditSystemName = creditService.getCreditSystemName();
            finderService = returnFinderService(this.creditSystemName);
            //Set and validate mapping
            finderService.setMapping();
            finderService.validateMapping();
            currentOpportunity = (Opportunity)finderService.getSourceObject(opportunityId);

            //Validate record
            finderService.validate();
            finderService.checkDuplicates();
            if (isCreditReportExist(opportunityId)) {
                PageReference ref = new PageReference('/apex/CreditFactoryReport?creditSystemCompanyNumber=' + currentCompanyId + '&opportunityId=' + opportunityId);
                ref.setRedirect(true);
                return ref;
            }

            companiesList = finderService.searchCompany(creditService);
            if (companiesList.isEmpty()) {
                Order orderService = returnOrderService(this.creditSystemName);
                if (orderService != null) {
                    this.displayTaxIdApprove = true;
                    String errorToRequestOrder = 'No matches for this company.';
                    orderService.validateOpportunity(this.currentOpportunity, errorToRequestOrder);
                    CreditCompany company = orderService.doOrder(creditService, this.currentOpportunity, errorToRequestOrder, null);
                    orderService.updateOpportunity(this.currentOpportunity, company, errorToRequestOrder);
                    throw new CreditFactoryException(errorToRequestOrder + ' ' + orderService.getSuccessfulOrderStatus());
                }
                throw new CreditFactoryException('No matches for this company.');
            }

            setLaunchedCFStage();
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : isCreditReportExist(String opportunityId)
    *  Summary         : check existing Credit Factory Reports with Created Date in last 3 months     
    *  CreatedDate     : 19/10/2017
    *  ModifiedDate    : 19/10/2017
    *  Parameters      : String opportunityId - id of current Opportunity
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isCreditReportExist(String opportunityId) {
        List<Credit_Factory_Report__c> creditReportsList = [
                SELECT CreatedDate, Company_Id__c
                FROM Credit_Factory_Report__c
                WHERE Opportunity__c = :opportunityId AND CreatedDate > :Date.today().addMonths(-3)
                ORDER BY CreatedDate DESC
                LIMIT 1];
        if (! creditReportsList.isEmpty() && creditReportsList.get(0).Company_Id__c != null) {
            currentCompanyId = creditReportsList.get(0).Company_Id__c;
            return true;
        } else {
            return false;
        }
    }


    /*******************************************************************************
    *  Name            : returnReportService(String creditSystemName, String opportunityId) 
    *  Summary         : initialize report service based on Credit System Name     
    *  CreatedDate     : 1/11/2016
    *  Parameters      : String creditSystemName – name of credit system from custom setting
                         String opportunityId – Salesforce record id
    *  Returns         : CreditReport – implementation of CreditReport
    ******************************************************************************/
    public Finder returnFinderService(String creditSystemName) {
        Finder internalFinderService;
        if (creditSystemName.equalsIgnoreCase(CreditFactoryWebSchufa.CREDIT_SYSTEM_NAME)) {
            internalFinderService = new FinderSchufaServiceDE();
        } else if (creditSystemName.equalsIgnoreCase(CreditSafeWebservice.CREDIT_SYSTEM_NAME)) {
            internalFinderService = new FinderCreditsafeService();
        } else if (creditSystemName.equalsIgnoreCase(CofaceWebservice.CREDIT_SYSTEM_NAME)) {
            internalFinderService = new FinderCofaceService();
        } else if (creditSystemName.equalsIgnoreCase(CreditReformWebserviceAT.CREDIT_SYSTEM_NAME)) {
            internalFinderService = new FinderCreditreformServiceAT();
        } else if (creditSystemName.equalsIgnoreCase(CrediconnectWebserviceCH.CREDIT_SYSTEM_NAME)) {
            internalFinderService = new FinderCrediconnectServiceCH();
        } else if (creditSystemName.equalsIgnoreCase(CreditReformWebserviceLU.CREDIT_SYSTEM_NAME)) {
            internalFinderService = new FinderCreditreformServiceLU();
        } else {
            throw new CreditFactoryException('Invalid name for Credit setting.');
        }

        return internalFinderService;
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
        } else if (creditSystemName.equalsIgnoreCase(CofaceWebservice.CREDIT_SYSTEM_NAME)) {
            orderService = new OrderCofaceService();
        } else if (creditSystemName.equalsIgnoreCase(CreditReformWebserviceAT.CREDIT_SYSTEM_NAME)) {
            orderService = new OrderCreditreformServiceAT();
        } else if (creditSystemName.equalsIgnoreCase(CreditReformWebserviceLU.CREDIT_SYSTEM_NAME)) {
            orderService = new OrderCreditreformServiceLU();
        }

        return orderService;
    }


    /*******************************************************************************
    *  Name            : selectCompanyForReport()
    *  Summary         : Process selected company for report
    *  CreatedDate     : 1/11/2016
    *  Parameters      : 
    *  Returns         : PageReference – redirect to create report page
    ******************************************************************************/
    public PageReference selectCompanyForReport() {
        String selectedCompanyIndex = Apexpages.currentPage().getParameters().get('companyIndex');
        String companyCreditId = companiesList.get(Integer.valueOf(selectedCompanyIndex)).identificationnumber;
        if (companiesList.get(Integer.valueOf(selectedCompanyIndex)).isReportExists) {
            if (companyCreditId == null) {
                CreditFactoryUtilities.displayMessage('info','Identificationnumber is empty.');
                return null;
            }
        } else {
            CreditFactoryUtilities.displayMessage('error','Report doesn\'t exist for selected company.');
            return null;
        }
        
        PageReference pageReference = finderService.redirectToReport(companiesList.get(Integer.valueOf(selectedCompanyIndex)));
        if (pageReference == null) {
            this.companiesList = new List<CreditCompany>();
            saveAllErrorsInOpportunity();
        }

        return pageReference;
    }


    /*******************************************************************************
    *  Name            : setLaunchedCFStage()
    *  Summary         : set CF Stage = Launched if there are no errors    
    *  CreatedDate     : 27/10/2017
    *  ModifiedDate    : 27/10/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void setLaunchedCFStage() {
        if (this.currentOpportunity.CF_Stage__c != null && this.currentOpportunity.CF_Stage__c != 'Auto CW' && this.currentOpportunity.CF_Stage__c != 'Manual scoring' &&
                this.currentOpportunity.CF_Stage__c != 'Pending deposit' && this.currentOpportunity.CF_Stage__c != 'Pending Credit - Contract Check' &&
                ! this.currentOpportunity.CF_Stage__c.contains('Pending Credit Report')) {
            this.currentOpportunity.CF_Stage__c = 'Launched';
            update this.currentOpportunity;
        }
    }


    /*******************************************************************************
    *  Name            : backToOpporutnity()
    *  Summary         : Redirect to source Opportunity record     
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToOpporutnity() {  
        return new PageReference('/' + this.opportunityId);
    }


    /*******************************************************************************
    *  Name            : setInvalidSearch()
    *  Summary         : Redirect to source Opportunity record if there is no needed company in the list    
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : 18/07/2019
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference setInvalidSearch() {
        try {
            String errorMessage = 'Company is not in the list. ';
            Order orderService = returnOrderService(this.creditSystemName);
            if (orderService != null) {
                this.displayTaxIdApprove = true;
                orderService.validateOpportunity(this.currentOpportunity, errorMessage);
                CreditCompany company = orderService.doOrder(creditService, this.currentOpportunity, errorMessage, null);
                orderService.updateOpportunity(this.currentOpportunity, company, errorMessage);
                throw new CreditFactoryException(errorMessage + orderService.getSuccessfulOrderStatus());
            } else {
                CreditFactoryUtilities.displayMessage('error', errorMessage);
                saveAllErrorsInOpportunity();
                return new PageReference('/' + this.opportunityId);
            }
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }

        return null;
    }
    
    
    /*******************************************************************************
    *  Summary         : approve tax id to send order 
    *  Created         : 26/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void approveTaxId() {
        try {
            Order orderService = returnOrderService(this.creditSystemName);
            String errorMessage = '';
            CreditCompany company = orderService.doOrder(creditService, this.currentOpportunity, errorMessage, null);
            orderService.updateOpportunity(this.currentOpportunity, company, errorMessage);
            this.displayTaxIdApprove = false;
            throw new CreditFactoryException(errorMessage + orderService.getSuccessfulOrderStatus());
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error',e.getMessage());
            saveAllErrorsInOpportunity();
        }
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
                        creditFactoryErrorsSet.add(message.getSummary());
                    }
                }
            }

            if (! creditFactoryErrorsSet.isEmpty()) {
                this.currentOpportunity = [
                        SELECT Credit_Factory_Errors__c, CF_Stage__c, Account.Steuernummer__c, Account.BillingCountryCode,
                                Name, (
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

                        if (this.currentOpportunity.CF_Stage__c != null && ! (this.currentOpportunity.CF_Stage__c.contains('Pending Credit Report') && 
                                this.currentOpportunity.Credit_Factory_Reports__r.size() == 0)) {
                            this.currentOpportunity.CF_Stage__c = 'Error (Report not generated)';
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
            }
        
            update this.currentOpportunity;
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error', e.getMessage());
        }
    }
}