public class CFCheckCompanyQueueableRu implements Queueable, Database.AllowsCallouts {

    private Set<Id> opportunityIds;
    private DefaultValidator validator = new DefaultValidator();

    public CFCheckCompanyQueueableRu(Set<Id> opportunityIds) {
        this.validator.validate(Set<Id>.class, 'opportunityIds', opportunityIds);
        this.opportunityIds = opportunityIds;
    }

    public void execute(QueueableContext param1) {
        processCreditCheck();
    }

    @InvocableMethod
    public static void startProcessCreditCheck(List<Id> opportunityIds) {
        System.enqueueJob(new CFCheckCompanyQueueableRu(new Set<Id>(opportunityIds)));
    }

    /*****************************************************************************
    *  Name            : processCreditCheck()
    *  Summary         : launches process of organization checking for Opportunities
    *  CreatedDate     : 05/12/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @TestVisible
    private void processCreditCheck() {
        Opportunity opportunity;
        Id id;
        try {
            for (Id opportunityId : this.opportunityIds) {
                id = opportunityId;
                CFServiceRuImpl cfRuService = new CFServiceRuImpl();

                //select opportunity with scoring report and account
                opportunity = cfRuService.getRussianOpportunity(opportunityId);
                Account account = cfRuService.getAccountById(opportunity.AccountId);
                Credit_Factory_Report__c report = cfRuService.getCreditFactoryReportRU(opportunity.Id, CFUtils.ScoringType.Prescoring);

                E2EFormParams formParams = new E2EFormParams();
                formParams.businessProcess = opportunity.Business_process__c;
                System.debug('********* BUSINESS PROCESS = ' + formParams.businessProcess);
                formParams.opportunityId = opportunity.Id;
                formParams.accountId = opportunity.AccountId;
                formParams.companyInn = opportunity.INN_Opp__c;
                formParams.scoringExpirationDate = report == null ? null : report.RU_Scoring_expiration_date__c;

                Boolean checkScoringExpired = CFUtils.getCFSettingsFor(GlobalUtils.FleetcorCountries.Russia.name()).Black_list_check_when_scoring_expired__c;
                Boolean approvedByApprovalProcess = cfRuService.checkBBLApprovalProcess(formParams);

                this.validator.validateINN(opportunity.INN_Opp__c);
                Boolean isSole = GlobalUtils.isSoleProprietor(opportunity.INN_Opp__c);
                String turnover = String.valueOf(opportunity.Expected_Volume_Ru__c);
                this.validator.validateNumber(turnover);

                DecisionPrescoring decisionPrescoring = null;
                if (isSole) {
                    //if sole proprietor
                    // get sole proprietor information from spark, check black list
                    if (cfRuService.getSoleProprietorSparkData(formParams) && !approvedByApprovalProcess) {
                        cfRuService.getBlackListDecisionData(formParams, false);
                    }
                } else if (!isSole) {
                    // get company information from spark, check black list and score
                    if (cfRuService.getCompanySparkShortData(formParams)) {
                        if (cfRuService.getBlackListDecisionData(formParams, checkScoringExpired) || approvedByApprovalProcess) {
                            decisionPrescoring = cfRuService.processPrescoring(
                                    String.valueOf(formParams.sparkId),
                                    opportunity.INN_Opp__c,
                                    Long.valueOf(turnover),
                                    formParams
                            );
                        }
                    }
                }
                // update SPARK for Account
                cfRuService.updateAccountSparkData(account, formParams);
                // update black list information
                if (cfRuService.isBlackListDataUpdated()) {
                    cfRuService.updateAccountBlackListData(account, formParams);
                }
                // update credit information in SF
                if (decisionPrescoring != null) {
                    if (report == null) {
                        //create new report
                        cfRuService.createPrescoringData(decisionPrescoring, opportunity);
                    } else {
                        cfRuService.updatePrescoringData(decisionPrescoring, report.Id);
                    }
                }
                if (cfRuService.companyIsToBeBlocked()) cfRuService.blockCompany(account);
            }
        } catch (Exception e) {
            String message = e.getTypeName() + '\n' + e.getMessage() + '\n Opportunity id = ' + id + ' \n';
            System.debug('*********** EXCEPTION **************\n' + message + e.getStackTraceString() + '\n*********** EXCEPTION **************');
            PPR_API_LogService.createLog(opportunity == null ? null : opportunity.INN_Opp__c, CFUtils.PRESCORING, e);
            ExceptionLogger.sendException(message, e.getStackTraceString());
        } finally {
            // mark that CF checking process for Opportunity ends
            if (opportunity != null) {
                opportunity.CF_checking__c = false;
                update opportunity;
            }
        }
    }
}