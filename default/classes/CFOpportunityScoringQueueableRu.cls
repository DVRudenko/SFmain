public with sharing class CFOpportunityScoringQueueableRu implements Queueable, Database.AllowsCallouts {

    private Set<Id> opportunityIds;
    private Id opportunityId;

    public CFOpportunityScoringQueueableRu(Set<Id> opportunityIds) {
        this.opportunityIds = opportunityIds;
    }

    /*****************************************************************************
    *  Name            : CFOpportunityScoringQueueableRu(Set<Id> opportunityIds)
    *  Summary         :
    *  CreatedDate     :
    *  Parameters      : Set<Id> opportunityIds
    *  Returns         : void
    ******************************************************************************/
    public void execute(QueueableContext param1) {
        Opportunity opportunity;
        try {
            Map<String, Object> settings = (Map<String, Object>) CFUtils.getScoringSettings(CFUtils.NOTIFICATION);
            Integer pointsToSendEmail = (Integer) settings.get('sumPointsToSend');
            for (Id opportunityId : this.opportunityIds) {
                this.opportunityId = opportunityId;
                CFServiceRuImpl cfRuService = new CFServiceRuImpl();
                //get data from DB
                opportunity = cfRuService.getOpportunity(this.opportunityId);
                E2EFormData__c formData = cfRuService.getByOpportunityId(this.opportunityId);
                Credit_Factory_Report__c report = cfRuService.getCFR(
                        this.opportunityId,
                        CFUtils.FRAUD_SCORING_TYPE,
                        CFUtils.RUSSIAN_FRAUD_RECORD_TYPE
                );
                //compose data
                E2EFormParams params = new E2EFormParams();
                params.source = opportunity.Source_of_Lead_o__c;
                if (formData != null) {
                    params.prepayAmount = formData.E2E_Prepay_Amount__c;
                    params.companyLegalAddress = formData.E2E_Legal_Address__c;
                    params.postalAddress = formData.E2E_Post_Address__c;
                }
                // get spark data
                if (Test.isRunningTest()) {
                    params.registrationDateSpark = Date.today().format();
                } else {
                    SparkWebService service = new SparkWebServiceImpl();
                    if (GlobalUtils.isSoleProprietor(opportunity.INN_Opp__c)) {
                        params.registrationDateSpark = service.getEntrepreneurShortReportByInn(opportunity.INN_Opp__c).dateReg;
                    } else {
                        List<CompanySpark> companies = service.getCompanyListByInn(opportunity.INN_Opp__c);
                        if (!companies.isEmpty()) {
                            params.registrationDateSpark = service.getCompanyExtendedReportBySparkId(
                                    opportunity.INN_Opp__c,
                                    String.valueOf(companies.get(0).sparkID)
                            ).dateFirstReg;
                        }
                    }
                }
                //process scoring
                OpportunityScoring scoring = cfRuService.processOpportunityScoring(params);
                //send notification
                if (scoring.totalPoints >= pointsToSendEmail) {
                    //prepare data
                    params.companyInn = opportunity.INN_Opp__c;
                    params.transitContId = formData.E2E_Transit_Cont_Id__c;
                    params.companyName = formData.E2E_Account_Short_Name__c;
                    cfRuService.sendFRAUDNotification(new List<E2EFormParams> {params});
                    scoring.notificationSent = true;
                } else {
                    scoring.notificationSent = false;
                }
                scoring.opportunityId = opportunity.Id;
                scoring.accountId = opportunity.AccountId;
                //update SObjects
                if (report == null) {
                    cfRuService.createFRAUDScoringData(scoring);
                } else {
                    cfRuService.updateFRAUDScoringData(report, scoring);
                }
            }
        } catch (Exception e) {
            String message = e.getMessage() + '\n<br>Opportunity id = ' + this.opportunityId + '<br>\n';
            System.debug(
                    '*********** EXCEPTION **************\n' + message
                            + e.getStackTraceString() + '\n*********** EXCEPTION **************'
            );
            ExceptionLogger.sendException(message, e.getStackTraceString());
            PPR_API_LogService.createLog(opportunity == null ? '' : opportunity.INN_Opp__c, 'FRAUD check', e);
        }
    }

}