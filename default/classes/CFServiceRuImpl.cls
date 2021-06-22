public without sharing class CFServiceRuImpl implements CFService {

    public CFUtils.CompanyBlockReason blockReason = null;       //reason of organization blocking
    private SparkWebService sparkWebService;
    private ScoringWebService scoringWebService;
    private Boolean blackListDataUpdated = false;               //flag to update black list data
    private Boolean scoringDataUpdated = false;                 //flag to update scoring data
    private Boolean blockCompany = false;                       //flag to block organization
    private CFDAORuImpl cfRuDao;
    private DefaultValidator validator = new DefaultValidator();

    public CFServiceRuImpl() {
//        if ( !Test.isRunningTest()) {
        this.sparkWebService = new SparkWebServiceImpl();
        this.scoringWebService = new ScoringWebServiceImpl();
//        }
        this.cfRuDao = new CFDAORuImpl();
    }

    public void setTestSparkWebService(SparkWebService sparkWebService) {
        if (Test.isRunningTest()) this.sparkWebService = sparkWebService;
    }

    public void setTestScoringWebService(ScoringWebService scoringWebService) {
        if (Test.isRunningTest()) this.scoringWebService = scoringWebService;
    }

    public Boolean isBlackListDataUpdated() {
        return this.blackListDataUpdated;
    }

    public Boolean isScoringDataUpdated() {
        return this.scoringDataUpdated;
    }

    public Boolean companyIsToBeBlocked() {
        return this.blockCompany;
    }

    /*****************************************************************************
    *  Name            : setCompanyToBeBlocked(E2EFormParams formParams)
    *  Summary         : set attributes in Service instance to block company
    *  CreatedDate     : 05/12/2019
    *  Parameters      : E2EFormParams formParams
    *  Returns         : void
    ******************************************************************************/

    private void setCompanyToBeBlocked(CFUtils.CompanyBlockReason blockReason) {
        if ( !companyIsToBeBlocked()) {
            this.blockReason = blockReason;
            this.blockCompany = true;
        }
    }

    // **** prescoring service **** //

    /*****************************************************************************
    *  Name            : getSparkDataForPrescoring(String sparkId, String inn)
    *  Summary         : retrieves data from spark service for prescoring
    *  CreatedDate     : 11/25/2020
    *  Parameters      : String sparkId, String inn
    *  Returns         : SparkDataForPrescoring - prescoring data if exist, or null if not found
    ******************************************************************************/
    public SparkDataForPrescoring getSparkDataForPrescoring(String sparkId, String inn) {
        this.validator.validateNumber(sparkId);
        SparkDataForPrescoring data = new SparkDataForPrescoring();
        data.companyData = this.sparkWebService.getCompanyExtendedReportBySparkId(
                inn,
                sparkId
        );
        if (data.companyData.sparkID == null) {
            return null;
        }
        System.debug('CFServiceRuImpl.getSparkDataForPrescoring - companyData received');
        data.riskReport = this.sparkWebService.getCompanySparkRisksReportXML(String.valueOf(data.companyData.sparkID));
        if (data.riskReport == null) {
            return null;
        }
        System.debug('CFServiceRuImpl.getSparkDataForPrescoring - riskReport received');
        data.arbitrationSummaryList = this.sparkWebService.getCompanyArbitrationSummary(String.valueOf(data.companyData.sparkID));
        System.debug('CFServiceRuImpl.getSparkDataForPrescoring - arbitrationSummaryList received');
        data.financialReports = this.sparkWebService.getCompanyAccountingReportBySparkId(
                data.companyData.inn,
                String.valueOf(data.companyData.sparkID)
        );
        System.debug('CFServiceRuImpl.getSparkDataForPrescoring - financialReports received');
        data.executionProceedings = this.sparkWebService.getCompanyExecutionProceedings(String.valueOf(data.companyData.sparkID));
        System.debug('CFServiceRuImpl.getSparkDataForPrescoring - executionProceedings received');

        // if SPARK data is enough for prescoring, then return data
        return data;
    }

    /*****************************************************************************
    *  Name            : buildPrescoringRequestBody(SparkDataForPrescoring data, Long turnover)
    *  Summary         : process data from spark to build request body for prescoring
    *  CreatedDate     : 11/25/2020
    *  Parameters      : SparkDataForPrescoring data - spark data, Long turnover - turnover
    *  Returns         : RequestPrescoring - request body for prescoring api
    ******************************************************************************/
    public RequestPrescoring buildPrescoringRequestBody(SparkDataForPrescoring data, Long turnover) {
        this.validator.validate(SparkDataForPrescoring.class, 'data', data);
        this.validator.validate(Long.class, 'turnover', turnover);
        RequestPrescoring requestPrescoring = new RequestPrescoring();
        requestPrescoring.prescoringDataId = null;
        requestPrescoring.creditApplicationId = null;
        requestPrescoring.inn = data.companyData.inn;
        requestPrescoring.turnover = turnover;
        requestPrescoring.companyStatusIsActing = data.riskReport.status.isActing;
        requestPrescoring.frozenAccounts = data.riskReport.frozenAccounts == null ? false : !data.riskReport.frozenAccounts.decision.isEmpty();
        requestPrescoring.dateFirstReg = String.isBlank(data.companyData.dateFirstReg) ? null : String.valueOf(
                Date.valueOf(data.companyData.dateFirstReg)
        );
        requestPrescoring.consolidatedIndicator = data.companyData.consolidatedIndicator == null ?
                '' : data.companyData.consolidatedIndicator.value;
        requestPrescoring.bankruptcyMessage = false;
        if (data.companyData.bankruptcyMessage != null) {
            Set<Integer> validIdTypes = new Set<Integer> {521, 522, 527, 538};
            for (ExtendedReportSpark.Message message : data.companyData.bankruptcyMessage.messages) {
                if (!validIdTypes.contains(message.idType)) {
                    requestPrescoring.bankruptcyMessage = true;
                    break;
                }
            }
        }
        System.debug('CFServiceRuImpl.buildPrescoringRequestBody - bankruptcyMessage processed');

        if ( !this.validator.listIsEmpty(data.financialReports)) {
            data.financialReports.sort();
            Map<String, CFUtils.FinancialReportFormValue> codeValue = new Map<String, CFUtils.FinancialReportFormValue>();
            for (FinancialReportSpark.Form form : data.financialReports.get(0).period.form) {
                Long power = form.power;
                for (FinancialReportSpark.Value value : form.value) {
                    CFUtils.FinancialReportFormValue finValue = codeValue.get(value.code);
                    if (finValue == null) {
                        finValue = new CFUtils.FinancialReportFormValue();
                    }
                    if (value.column == 3) {
                        finValue.startValue = (Long) value.value * power;
                    }
                    if (value.column == 4) {
                        finValue.endValue = (Long) value.value * power;
                    }
                    if (finValue.startValue == null) {
                        finValue.startValue = 0;
                    }
                    if (finValue.endValue == null) {
                        finValue.endValue = 0;
                    }
                    codeValue.put(value.code, finValue);
                }
            }

            CFUtils.FinancialReportFormValue value1150 = codeValue.get(CFUtils.VALUE_CODE.CODE_1150);
            if (value1150 == null) {
                requestPrescoring.fixedAssets1150 = 0;
            } else {
                if (value1150.startValue == 0) {
                    requestPrescoring.fixedAssets1150 = value1150.endValue;
                } else {
                    requestPrescoring.fixedAssets1150 = value1150.startValue;
                }
            }
            CFUtils.FinancialReportFormValue value1200 = codeValue.get(CFUtils.VALUE_CODE.CODE_1200);
            if (value1200 == null) {
                requestPrescoring.currentAssets1200 = CFUtils.zeroIfNull(codeValue.get(CFUtils.VALUE_CODE.CODE_1210))
                        + CFUtils.zeroIfNull(codeValue.get(CFUtils.VALUE_CODE.CODE_1230))
                        + CFUtils.zeroIfNull(codeValue.get(CFUtils.VALUE_CODE.CODE_1250));
            } else {
                requestPrescoring.currentAssets1200 = value1200.startValue;
            }
            CFUtils.FinancialReportFormValue value1500 = codeValue.get(CFUtils.VALUE_CODE.CODE_1500);
            if (value1500 == null) {
                requestPrescoring.shortTermLiabilities1500 = CFUtils.zeroIfNull(codeValue.get(CFUtils.VALUE_CODE.CODE_1510))
                        + CFUtils.zeroIfNull(codeValue.get(CFUtils.VALUE_CODE.CODE_1520))
                        + CFUtils.zeroIfNull(codeValue.get(CFUtils.VALUE_CODE.CODE_1550));
            } else {
                requestPrescoring.shortTermLiabilities1500 = value1500.startValue;
            }
            requestPrescoring.capitalAndReserves1300 = CFUtils.zeroIfNull(codeValue.get(CFUtils.VALUE_CODE.CODE_1300));
            requestPrescoring.revenue2110 = CFUtils.zeroIfNull(codeValue.get(CFUtils.VALUE_CODE.CODE_2110));
        } else {
            requestPrescoring.fixedAssets1150 = null;
            requestPrescoring.currentAssets1200 = null;
            requestPrescoring.shortTermLiabilities1500 = null;
            requestPrescoring.capitalAndReserves1300 = null;
            requestPrescoring.revenue2110 = null;
        }
        System.debug('CFServiceRuImpl.buildPrescoringRequestBody - financialReports processed');

        requestPrescoring.trialsAsDefendantCurrentYear = 0;
        requestPrescoring.trialsAsDefendantLastYear = 0;
        requestPrescoring.trialsAsPlaintiffCurrentYear = 0;
        requestPrescoring.trialsAsPlaintiffLastYear = 0;
        Date today = Date.today();
        for (SparkArbitrationSummary arbitrationSummary : data.arbitrationSummaryList) {
            for (SparkArbitrationSummary.YearClass arbitrationByYear : arbitrationSummary.arbitrationSummary.arbitrationByYear.year) {
                if (Integer.valueOf(arbitrationByYear.year) == today.year() - 1) {
                    requestPrescoring.trialsAsPlaintiffLastYear += Long.valueOf(arbitrationByYear.plaintiff.sum);
                    requestPrescoring.trialsAsDefendantLastYear += Long.valueOf(arbitrationByYear.defendant.sum);
                } else if (Integer.valueOf(arbitrationByYear.year) == today.year()) {
                    requestPrescoring.trialsAsPlaintiffCurrentYear += Long.valueOf(arbitrationByYear.plaintiff.sum);
                    requestPrescoring.trialsAsDefendantCurrentYear += Long.valueOf(arbitrationByYear.defendant.sum);
                }
            }
        }
        System.debug('CFServiceRuImpl.buildPrescoringRequestBody - arbitrationSummaryList processed');

        requestPrescoring.sumExecutionProceedings = 0;
        if ( !this.validator.listIsEmpty(data.executionProceedings)) {
            for (SparkExecutionProceedings.ExecutionProceeding executionProceeding : data.executionProceedings.get(0).executionProceedings.executionProceeding) {
                if (!executionProceeding.isExecuted && executionProceeding.payoutAmount != null && executionProceeding.type.id != 100) {
                    requestPrescoring.sumExecutionProceedings += Double.valueOf(executionProceeding.payoutAmount.replace(',', '.'));
                }
            }
        }
        System.debug('CFServiceRuImpl.buildPrescoringRequestBody - executionProceedings processed');

        requestPrescoring.simultaneousChangeFounderAndCEO = false;
        if (data.riskReport.riskFactors != null) {
            for (SparkRisksReportXML.FactorClass factor : data.riskReport.riskFactors.factor) {
                if (factor.id == 25) {
                    requestPrescoring.simultaneousChangeFounderAndCEO = true;
                    break;
                }
            }
        }
        System.debug('CFServiceRuImpl.buildPrescoringRequestBody - riskFactors processed');

        return requestPrescoring;
    }

    /*****************************************************************************
    *  Name            : processPrescoring(String sparkId, String inn, Long turnover, E2EFormParams params)
    *  Summary         : process prescoring logic and returns prescoring decision (contains Callouts)
    *  CreatedDate     : 11/25/2020
    *  Parameters      : String sparkId, String inn, Long turnover
    *                  : E2EFormParams params - for SPARK data save to Account (deprecate in future)
    *  Returns         : DecisionPrescoring - prescoring result
    ******************************************************************************/
    public DecisionPrescoring processPrescoring(String sparkId, String inn, Long turnover, E2EFormParams params) {
        SparkDataForPrescoring data = getSparkDataForPrescoring(sparkId, inn);
        System.debug('CFServiceRuImpl.processPrescoring - SparkDataForPrescoring received');

        if (data != null && params != null) {
            params.okvedSpark = data.companyData.getMainOkved().name;
            params.kppSpark = data.companyData.kpp;
            params.citySpark = data.companyData.legalAddresses.address.city;
            params.streetSpark = data.companyData.legalAddresses.address.streetName;
            params.postCodeSpark = data.companyData.legalAddresses.address.postCode;
            params.normName = data.companyData.normName;
            if ( !Boolean.valueOf(data.companyData.isActing)) setCompanyToBeBlocked(CFUtils.CompanyBlockReason.SPARK);
        }

        RequestPrescoring requestPrescoring = buildPrescoringRequestBody(data, turnover);
        System.debug('CFServiceRuImpl.processPrescoring - RequestPrescoring built');

        DecisionPrescoring decisionPrescoring = this.scoringWebService.getPrescoringDecision(requestPrescoring);
        System.debug('CFServiceRuImpl.processPrescoring - DecisionPrescoring received');

        if (decisionPrescoring.blocked) this.setCompanyToBeBlocked(CFUtils.CompanyBlockReason.Prescoring);
        return decisionPrescoring;
    }


    // **** E2EFormParams service **** //

    /*****************************************************************************
    *  Name            : getSoleProprietorSparkData(E2EFormParams formParams)
    *  Summary         : updates spark data in E2EFormParams for sole proprietor
    *  CreatedDate     : 09/10/2019
    *  Parameters      : E2EFormParams formParams
    *  Returns         : Boolean - success or not
    ******************************************************************************/
    public Boolean getSoleProprietorSparkData(E2EFormParams formParams) {
        //callout to SPARK service
        SoleProprietorSpark soleProprietorInfo = this.sparkWebService.getEntrepreneurShortReportByInn(formParams.companyInn);
        if (soleProprietorInfo.sparkID != null) {
            //if SPARK data exists, update it
            formParams.sparkId = soleProprietorInfo.sparkID;
            formParams.isSoleProprietor = true;
            formParams.soleProprietorFio = soleProprietorInfo.fullNameRus;
            formParams.mainCompanyFullNameSpark = 'ИП ' + soleProprietorInfo.fullNameRus;
            formParams.registrationDateSpark = String.valueOf(((Datetime) JSON.deserialize('"' + soleProprietorInfo.dateReg + '"', Datetime.class)).format('dd.MM.yyyy'));
            formParams.ogrnipSpark = soleProprietorInfo.ogrnip;
            formParams.okpoSpark = soleProprietorInfo.okpo;
            formParams.okvedSpark = soleProprietorInfo.getMainOkved().name;
            formParams.isActing = soleProprietorInfo.status.isActing;
            if ( !formParams.isActing) {
                //if sole proprietor is not acting, mark it to be blocked
                setCompanyToBeBlocked(CFUtils.CompanyBlockReason.SPARK);
                //SPARK failed
                return false;
            }
            //SPARK passed
            return true;
        } else {
            formParams.scoringDecision = ScoringWebServiceImpl.scoringDecisionMapping.get(1);
            //SPARK failed
            return false;
        }
    }

    /*****************************************************************************
    *  Name            : getCompanySparkShortData(E2EFormParams formParams)
    *  Summary         : updates spark data in E2EFormParams for company
    *  CreatedDate     : 09/10/2019
    *  Parameters      : E2EFormParams formParams
    *  Returns         : Boolean - success or not
    ******************************************************************************/
    public Boolean getCompanySparkShortData(E2EFormParams formParams) {
        //callout to SPARK service
        List<CompanySpark> companySparks = sparkWebService.getCompanyListByInn(formParams.companyInn);
        if ( !companySparks.isEmpty()) {
            //if SPARK data exists, update it
            CompanySpark mainCompanySpark = companySparks.get(0);
            formParams.sparkId = mainCompanySpark.sparkID;
            formParams.isSoleProprietor = false;
            formParams.mainCompanyFullNameSpark = mainCompanySpark.fullName;
            formParams.okpoSpark = mainCompanySpark.okpo;
            formParams.ogrnSpark = mainCompanySpark.ogrn;
            formParams.legalAddressSpark = mainCompanySpark.address;
            //SPARK passed
            return true;
        } else {
            System.debug('mainCompanySpark.isEmpty() == true');
            // if spark couldn't find data about company set credit prepay
            formParams.scoringDecision =  ScoringWebServiceImpl.scoringDecisionMapping.get(1);
            //SPARK failed
            return false;
        }

    }

    /*****************************************************************************
    *  Name            : getCompanySparkExtendedData(E2EFormParams formParams)
    *  Summary         : updates extended spark data in E2EFormParams for company
    *  CreatedDate     : 18/10/2019
    *  Parameters      : E2EFormParams formParams
    *  Returns         : Boolean - success or not
    ******************************************************************************/
    public Boolean getCompanySparkExtendedData(E2EFormParams formParams) {
        //callout to SPARK service
        ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(formParams.companyInn, String.valueOf(formParams.sparkId));
        if (extendedReport.sparkID != null) {
            //if SPARK data exists, update it
            formParams.registrationDateSpark = String.valueOf(((Datetime) JSON.deserialize('"' + extendedReport.dateFirstReg + '"', Datetime.class)).format('dd.MM.yyyy'));
            formParams.okpoSpark = extendedReport.okpo;
            formParams.ogrnSpark = extendedReport.ogrn;
            formParams.kppSpark = extendedReport.kpp;
            formParams.isSoleProprietor = false;
            formParams.okvedSpark = extendedReport.getMainOkved().name;
            formParams.postCodeSpark = extendedReport.legalAddresses.address.postCode;
            formParams.regionSpark = extendedReport.legalAddresses.address.region;
            formParams.citySpark = extendedReport.legalAddresses.address.city;
            formParams.streetSpark = extendedReport.legalAddresses.address.streetName;
            formParams.buildingSpark = extendedReport.legalAddresses.address.buildingNumber;
            formParams.housingSpark = extendedReport.legalAddresses.address.housing;
            formParams.blockSpark = extendedReport.legalAddresses.address.block;
            formParams.roomSpark = extendedReport.legalAddresses.address.room;
            formParams.legalAddressSpark = extendedReport.legalAddresses.address.address;
            formParams.normName = extendedReport.normName;
            ExtendedReportSpark.Leader leader = this.sparkWebService.getCompanyActualLeader(extendedReport.leaderList.leader);
            formParams.executiveFio = leader.fio;
            formParams.executivePosition = leader.position;
            formParams.isActing = Boolean.valueOf(extendedReport.isActing);
            if ( !formParams.isActing) {
                //if company is not acting, mark it to be blocked
                setCompanyToBeBlocked(CFUtils.CompanyBlockReason.SPARK);
                //SPARK failed
                return false;
            }
            //SPARK passed
            return true;
        } else {
            // if spark couldn't find data about company set credit prepay
            formParams.scoringDecision =  ScoringWebServiceImpl.scoringDecisionMapping.get(1);
            //SPARK failed
            return false;
        }
    }


    /*****************************************************************************
    *  Name            : getCompanySparkFullData(E2EFormParams formParams)
    *  Summary         : updates full spark data in E2EFormParams for company
    *  CreatedDate     : 18/10/2019
    *  Parameters      : E2EFormParams formParams
    *  Returns         : Boolean - success or not
    ******************************************************************************/
    public Boolean getCompanySparkFullData(E2EFormParams formParams) {
        return getCompanySparkShortData(formParams) ? getCompanySparkExtendedData(formParams) : false;
    }


    /*****************************************************************************
    *  Name            : getBlackListDecisionData(E2EFormParams formParams)
    *  Summary         : updates black list data in E2EFormParams
    *  CreatedDate     : 09/10/2019
    *  Parameters      : E2EFormParams formParams,
    *                  : Boolean checkScoringExpired - if true, works only if scoring has expired (using formParams data)
    *  Returns         : Boolean - success or not
    ******************************************************************************/
    public Boolean getBlackListDecisionData(E2EFormParams formParams, Boolean checkScoringExpired) {
        this.blackListDataUpdated = false;
        //check if black list check is necessary
        if ( !checkScoringExpired || (checkScoringExpired && (formParams.scoringExpirationDate == null || formParams.scoringExpirationDate <= Date.today()))) {
            //callout to black list service
            CompanyVerificationScoring verificationDecision = this.scoringWebService.verifyCompany(formParams.companyInn, String.valueOf(formParams.sparkId), formParams.opportunityId);
            System.debug('**** SOLE PROPRIETOR VERIFICATION DECISION: ' + verificationDecision.decision + ', listType=' + verificationDecision.blackListType);
            this.blackListDataUpdated = true;
            if (verificationDecision.decision != null) {
                //save black list data
                formParams.verifiedDecision = ScoringWebServiceImpl.blackListDecisionMapping.get(verificationDecision.decision);
                formParams.verifiedDecisionCode = String.valueOf(verificationDecision.decision);
                formParams.verifiedLimitation = String.valueOf(verificationDecision.limitation);
                if (verificationDecision.decision == 3) {
                    //total denial, black list check failed
                    setCompanyToBeBlocked(CFUtils.CompanyBlockReason.BlackList);
                    return false;
                }
                //black list check passed
                return true;
            } else {
                //No data, black list check failed
                formParams.verifiedDecision = ScoringWebServiceImpl.blackListDecisionMapping.get(-1);
                return false;
            }
        } else {
            //black list check passed, because not needed
            return true;
        }
    }

    /*****************************************************************************
    *  Name            : getScoringDecisionData(E2EFormParams formParams)
    *  Summary         : updates scoring data in E2EFormParams
    *  CreatedDate     : 09/10/2019
    *  Parameters      : E2EFormParams formParams
    *  Returns         : Boolean - success or not
    ******************************************************************************/
    public Boolean getScoringDecisionData(E2EFormParams formParams) {
        this.scoringDataUpdated = false;
        //check if scoring is necessary
        if (formParams.scoringExpirationDate == null || formParams.scoringExpirationDate <= Date.today()) {
            //callout to scoring service
            DecisionScoring decision = scoringWebService.getScoringDecision(formParams.companyInn, String.valueOf(formParams.sparkId), formParams.opportunityId);
            System.debug('**** SCORING DECISION: ' + decision.decision);
            this.scoringDataUpdated = true;
            if (decision.decision != null) {
                //save scoring data
                formParams.scoringDecision = ScoringWebServiceImpl.scoringDecisionMapping.get(decision.decision);
                formParams.scoringDecisionCode = String.valueOf(decision.decision);
                formParams.scoringDateString = ((Datetime) Date.today()).format('dd.MM.yyyy');
                formParams.scoringDate = Date.today();
                Integer daysScoringToExpire = Integer.valueOf(CFUtils.getCFSettingsFor(GlobalUtils.FleetcorCountries.Russia.name()).Days_scoring_to_expire__c);
                formParams.scoringExpirationDate = formParams.scoringDate.addDays(daysScoringToExpire);
                if (decision.decision == 2) {
                    //total denial
                    setCompanyToBeBlocked(CFUtils.CompanyBlockReason.Prescoring);
                    //scoring failed
                    return false;
                }
                //scoring passed
                return true;
            } else {
                // if something wrong with scoring and we got empty decision then prepay
                formParams.scoringDecision = ScoringWebServiceImpl.scoringDecisionMapping.get(1);
                //no data, scoring failed
                return false;
            }
        } else {
            //scoring passed, because not needed
            return true;
        }

    }

    /*****************************************************************************
    *  Name            : processOpportunityScoring(E2EFormParams params)
    *  Summary         : process extended scoring
    *  CreatedDate     : 22/07/2020
    *  Parameters      : E2EFormParams formParams
    *  Returns         : OpportunityScoring - scoring result
    ******************************************************************************/
    public OpportunityScoring processOpportunityScoring(E2EFormParams params) {
        Map<String, Object> criteria = (Map<String, Object>) CFUtils.getScoringSettings('criteria');
        Integer total = 0;
        OpportunityScoring scoring = new OpportunityScoring();
        if (criteria == null) return scoring;
        if (CFUtils.SOURCES.contains(params.source)) {
            total += (Integer) criteria.get('sourceOfLead');
            scoring.sourceOfLead = true;
        } else {
            scoring.sourceOfLead = false;
        }
        if (String.isNotBlank(params.prepayAmount) && Integer.valueOf(params.prepayAmount) > 500000) {
            total += (Integer) criteria.get('firstBill500000More');
            scoring.firstBill = true;
        } else {
            scoring.firstBill = false;
        }
        if (params.companyLegalAddress != null && !params.companyLegalAddress.equals(params.postalAddress)) {
            total += (Integer) criteria.get('legalAddressDifferentFromPostal');
            scoring.differentPostAddress = true;
        } else {
            scoring.differentPostAddress = false;
        }
        // dd.mm.yyyy can't be formated !
        /*if (String.isNotBlank(params.registrationDateSpark) && Date.valueOf(params.registrationDateSpark).addYears(1) >= Date.today()) {
            total += (Integer) criteria.get('newLegalEntity');
            scoring.newLegal = true;
        } else {
            scoring.newLegal = false;
        }*/
        scoring.totalPoints = total;
        return scoring;
    }

    /*****************************************************************************
    *  Name            : prepareScoringDataForTransit(OpportunityScoring scoring)
    *  Summary         : prepares FRAUD scoring data for transit
    *  CreatedDate     : 22/07/2020
    *  Parameters      : OpportunityScoring scoring - scoring data
    *  Returns         : TransitRequestData.ContMonitoring - scoring data for transit
    ******************************************************************************/
    public TransitRequestData.ContMonitoring prepareScoringDataForTransit(OpportunityScoring scoring) {
        TransitRequestData.ContMonitoring contMonitoring = new TransitRequestData.ContMonitoring();
        contMonitoring.differentPostAddress = GlobalUtils.parseBoolean(scoring.differentPostAddress);
        contMonitoring.firstBill = GlobalUtils.parseBoolean(scoring.firstBill);
        contMonitoring.newLegal = GlobalUtils.parseBoolean(scoring.newLegal);
        contMonitoring.sourceOfLead = GlobalUtils.parseBoolean(scoring.sourceOfLead);
        contMonitoring.notificationSent = GlobalUtils.parseBoolean(scoring.notificationSent);
        return contMonitoring;
    }

    /*****************************************************************************
    *  Name            : prepareScoringDataForTransit(Credit_Factory_Report__c report)
    *  Summary         : prepares FRAUD scoring data for transit
    *  CreatedDate     : 22/07/2020
    *  Parameters      : Credit_Factory_Report__c report - scoring data from database
    *  Returns         : TransitRequestData.ContMonitoring - scoring data for transit
    ******************************************************************************/
    public TransitRequestData.ContMonitoring prepareScoringDataForTransit(Credit_Factory_Report__c report) {
        TransitRequestData.ContMonitoring contMonitoring = new TransitRequestData.ContMonitoring();
        contMonitoring.differentPostAddress = GlobalUtils.parseBoolean(report.Different_post_address__c);
        contMonitoring.firstBill = GlobalUtils.parseBoolean(report.First_bill__c);
        contMonitoring.newLegal = GlobalUtils.parseBoolean(report.New_legal__c);
        contMonitoring.sourceOfLead = GlobalUtils.parseBoolean(report.Source_of_lead_matched__c);
        contMonitoring.notificationSent = GlobalUtils.parseBoolean(report.Scoring_notification_sent__c);
        return contMonitoring;
    }

    /*****************************************************************************
    *  Name            : sendFRAUDNotification(List<E2EFormParams> paramsList)
    *  Summary         : sends notification about scoring
    *  CreatedDate     : 22/07/2020
    *  Parameters      : List<E2EFormParams> paramsList - parameters for email
    *  Returns         : -
    ******************************************************************************/
    public void sendFRAUDNotification(List<E2EFormParams> paramsList) {
        Map<String, Object> notificationSettings = (Map<String, Object>) CFUtils.getScoringSettings(CFUtils.NOTIFICATION);
        if (notificationSettings != null) {
            List<Object> notificationReceivers = (List<Object>) notificationSettings.get('notificationReceivers');
            if (notificationReceivers != null) {
                String body = '<th>ID компании</th>';
                body += '<th>Наименование</th>';
                body += '<th>ИНН</th>';
                body += '<th>Канал привлечения - inbound, E2E, партнеры</th>';
                body += '<th>Новое ЮЛ (в пределах 12 месяцев с момента создания)</th>';
//                body += '<th>Смена учредителя за последние 6 месяцев</th>';
//                body += '<th>Адрес массовой регистрации</th>';
                body += '<th>Запрос отправки договора и карт на адрес, отличный от юридического</th>';
                body += '<th>Запрос первого счета на сумму более 500 т.р.</th>';
                body = '<tr>' + body + '</tr>';

                for (E2EFormParams params : paramsList) {
                    body += '<tr>';
                    body += '<td>' + CFUtils.replcaeNullValue(params.transitContId) + '</td>';
                    body += '<td>' + CFUtils.replcaeNullValue(params.companyName) + '</td>';
                    body += '<td>' + CFUtils.replcaeNullValue(params.companyInn) + '</td>';
                    body += '<td>' + CFUtils.replcaeNullValue(params.source) + '</td>';
                    body += '<td>' + CFUtils.replcaeNullValue(params.registrationDateSpark) + '</td>';
//                    body += '<td>' + null + '</td>';
//                    body += '<td>' + null + '</td>';
                    body += '<td>' + CFUtils.replcaeNullValue(params.postalAddress) + '</td>';
                    body += '<td>' + CFUtils.replcaeNullValue(params.prepayAmount) + '</td>';
                    body += '</tr>';
                }

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.htmlBody = '<div><table border="1" cellspacing="0">' + body + '</table></div>';
                List<String> toAddresses = new List<String>();
                for (Object receiver : notificationReceivers) {
                    toAddresses.add(String.valueOf(receiver));
                }
                message.toAddresses = toAddresses;
                message.saveAsActivity = false;
                message.senderDisplayName = 'SF NOTIFICATION';
                message.subject = '"Проверка на FRAUD"';
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
            }
        }
    }

    // **** Account service **** //

    /*****************************************************************************
    *  Name            : updateAccountSparkData(Account account, E2EFormParams formParams)
    *  Summary         : updates spark data for Account
    *  CreatedDate     : 21/10/2019
    *  Parameters      : Account account - data target, E2EFormParams formParams - data source
    *  Returns         : Account - updated Account
    ******************************************************************************/
    public Account updateAccountSparkData(Account account, E2EFormParams formParams) {
        //update SPARK data in Account fields if there is SPARK data in E2EFormParams
        account.Spark_ID__c = String.valueOf(formParams.sparkId);
        account.OKPO_ppr__c = GlobalUtils.changeIfHasNewValue(account.OKPO_ppr__c, formParams.okpoSpark);
        account.INN__c = GlobalUtils.changeIfHasNewValue(account.INN__c, formParams.companyInn);
        account.Company_Legal_Name1__c = GlobalUtils.changeIfHasNewValue(account.Company_Legal_Name1__c, formParams.mainCompanyFullNameSpark);
        String kppSpark = GlobalUtils.changeIfHasNewValue(String.valueOf(account.KPP__c), formParams.kppSpark);
        account.KPP__c = String.isBlank(kppSpark) ? null : Decimal.valueOf(kppSpark);
        account.OKVED__c = GlobalUtils.changeIfHasNewValue(account.OKVED__c, formParams.okvedSpark);
        account.BillingCity = GlobalUtils.changeIfHasNewValue(account.BillingCity, formParams.citySpark);
        account.BillingStreet = GlobalUtils.changeIfHasNewValue(account.BillingStreet, formParams.streetSpark);
        account.BillingPostalCode = GlobalUtils.changeIfHasNewValue(account.BillingPostalCode, formParams.postCodeSpark);
        if (formParams.isSoleProprietor) {
            //for sole proprietor
            account.Organization_Type__c = 'ИП';
            account.Name = GlobalUtils.changeIfHasNewValue(account.Name, formParams.soleProprietorFio);
            account.OGRN_ppr__c = GlobalUtils.changeIfHasNewValue(account.OGRN_ppr__c, formParams.ogrnipSpark);
        } else {
            //for company
            List<String> normName = GlobalUtils.parseNormNameForOrganization(formParams.normName);
            account.Name = GlobalUtils.changeIfHasNewValue(account.Name, normName.get(0));
            account.Organization_Type__c = GlobalUtils.changeIfHasNewValue(account.Organization_Type__c, normName.get(1));
            account.OGRN_ppr__c = GlobalUtils.changeIfHasNewValue(account.OGRN_ppr__c, formParams.ogrnSpark);
        }
        cfRuDao.updateAccounts(new List<Account> {account});
        System.debug('********* ACCOUNT SPARK DATA UPDATED *************');
        return account;
    }

    /*****************************************************************************
    *  Name            : updateAccountBlackListData(Account account, E2EFormParams formParams)
    *  Summary         : updates black list data for Account
    *  CreatedDate     : 21/10/2019
    *  Parameters      : Account account - data target, E2EFormParams formParams - data source
    *  Returns         : Account - updated Account
    ******************************************************************************/
    public Account updateAccountBlackListData(Account account, E2EFormParams formParams) {
        //update black list data in Account fields
        account.Black_list_check_code__c = formParams.verifiedDecisionCode;
        account.Black_list_check_decision__c = formParams.verifiedDecision;
        cfRuDao.updateAccounts(new List<Account> {account});
        System.debug('********* BLACK LIST DATA UPDATED IN ACCOUNT *************');
        return account;
    }

    /*****************************************************************************
    *  Name            : blockCompany(Account account, E2EFormParams formParams)
    *  Summary         : blocks Account and its Opportunities
    *  CreatedDate     : 21/10/2019
    *  Parameters      : Account account - Account to block, E2EFormParams formParams - data source
    *  Returns         : Account - blocked Account
    ******************************************************************************/
    public Account blockCompany(Account account) {
        //exclude some Stages of Opportunity
        List<String> excludeStages = new List<String> {
                GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.MovedToStart),
                GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Refused)
        };
        //get List of Opportunities in work
        List<Opportunity> opportunitiesInWork = cfRuDao.getOpportunitiesByAccountIdAndStages(account.Id, excludeStages);
//        Id ownerId = CFUtils.getCFSettingsFor(GlobalUtils.FleetcorCountries.Russia.name()).Blocked_companies_owner_ID__c;
        //block Opportunities and Account
        switch on blockReason {
            when SPARK {
                //if organization is not acting in SPARK
                account.Organization_Type__c = CFUtils.COMPANY_NON_ACTIVE;
            }
            when BlackList, Scoring, Prescoring {
                //if organization is denied by credit or black list check
                account.Type = CFUtils.COMPANY_DENIAL;
            }
        }
//        account.OwnerId = ownerId;
        for (Opportunity opportunity : opportunitiesInWork) {
            opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Refused);
            opportunity.PPR_Lost_Reasons__c = CFUtils.OPPORTUNITY_LOST_REASON;
//            opportunity.OwnerId = ownerId;
        }
        //update all Account records
        List<SObject> toUpdate = new List<SObject>();
        toUpdate.addAll(opportunitiesInWork);
        toUpdate.add(account);
        cfRuDao.updateSObjects(toUpdate);
        System.debug('********* COMPANY BLOCKED *************');
        return account;
    }

    /*****************************************************************************
    *  Name            : getAccountById(Id accountId)
    *  Summary         : gets Account by ID
    *  CreatedDate     : 05/12/2019
    *  Parameters      : Id accountId
    *  Returns         : Account
    ******************************************************************************/
    public Account getAccountById(Id accountId) {
        return cfRuDao.getAccountById(accountId);
    }

    // **** Credit factory report service **** //

    /*****************************************************************************
    *  Name            : createCFRuPrescoringData(E2EFormParams formParams, Boolean updatePrescoring)
    *  Summary         : creates prescoring CF report
    *  CreatedDate     : 21/10/2019
    *  Parameters      : E2EFormParams formParams - data source,
    *                  : Boolean updatePrescoring - update prescoring data or not
    *  Returns         : Credit_Factory_Report__c - created CF report
    ******************************************************************************/
    public Credit_Factory_Report__c createCFRuPrescoringData(E2EFormParams formParams, Boolean updatePrescoring) {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c();
        //save general data
        report.Opportunity__c = formParams.opportunityId;
        report.Account__c = formParams.accountId;
        report.RU_scoring_type__c = CFUtils.PRESCORING;
        report.RecordTypeId = CFUtils.RUSSIAN_CREDIT_RECORD_TYPE;
        report.Name = CFUtils.PRESCORING_RU;
        if (updatePrescoring) {
            //save prescoring data if necessary
            report.RU_Scoring_date__c = formParams.scoringDate;
            report.RU_Scoring_expiration_date__c = formParams.scoringExpirationDate;
            report.RU_scoring_decision__c = formParams.scoringDecision;
            report.RU_scoring_decision_code__c = formParams.scoringDecisionCode;
        }
        cfRuDao.insertCreditFactoryReports(new List<Credit_Factory_Report__c> {report});
        System.debug('********* CFReport SAVED *************');
        return report;
    }

    /*****************************************************************************
    *  Name            : createPrescoringData(DecisionPrescoring decisionPrescoring, Opportunity opportunity)
    *  Summary         : creates prescoring report
    *  CreatedDate     : 01/12/2020
    *  Parameters      : DecisionPrescoring decisionPrescoring - response from prescoring callout,
    *                  : Opportunity opportunity - record related to prescoring
    *  Returns         : Credit_Factory_Report__c - created CF report
    ******************************************************************************/
    public Credit_Factory_Report__c createPrescoringData(DecisionPrescoring decisionPrescoring, Opportunity opportunity) {
        this.validator.validate(DecisionPrescoring.class, 'decisionPrescoring', decisionPrescoring);
        this.validator.validate(Opportunity.class, 'opportunity', opportunity);
        this.validator.validate(Id.class, 'opportunity.Id', opportunity.Id);
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
                Opportunity__c = opportunity.Id,
                Account__c = opportunity.AccountId,
                RU_scoring_type__c = CFUtils.PRESCORING,
                RecordTypeId = CFUtils.RUSSIAN_CREDIT_RECORD_TYPE,
                Name = CFUtils.PRESCORING_RU
        );
        writePrescoringResponseData(report, decisionPrescoring);
        cfRuDao.insertCreditFactoryReports(new List<Credit_Factory_Report__c> {report});
        System.debug('********* PRESCORING DATA SAVED *************');
        return report;
    }

    /*****************************************************************************
    *  Name            : updatePrescoringData(DecisionPrescoring decisionPrescoring, Credit_Factory_Report__c report)
    *  Summary         : updates prescoring report
    *  CreatedDate     : 01/12/2020
    *  Parameters      : DecisionPrescoring decisionPrescoring - response from prescoring callout,
    *                  : Credit_Factory_Report__c report - report to be updated
    *  Returns         : Credit_Factory_Report__c - updated CF report
    ******************************************************************************/
    public Credit_Factory_Report__c updatePrescoringData(DecisionPrescoring decisionPrescoring, Id reportId) {
        this.validator.validate(DecisionPrescoring.class, 'decisionPrescoring', decisionPrescoring);
        this.validator.validate(Id.class, 'reportId', reportId);
        Credit_Factory_Report__c report = writePrescoringResponseData(new Credit_Factory_Report__c(Id = reportId), decisionPrescoring);
        cfRuDao.updateCreditFactoryReports(new List<Credit_Factory_Report__c> {report});
        System.debug('********* PRESCORING DATA UPDATED *************');
        return report;
    }

    /*****************************************************************************
    *  Name            : createFRAUDScoringData(OpportunityScoring scoring)
    *  Summary         : creates FRAUD scoring report
    *  CreatedDate     : 30.07.2020
    *  Parameters      : OpportunityScoring scoring - data source
    *  Returns         : Credit_Factory_Report__c - created report
    ******************************************************************************/
    public Credit_Factory_Report__c createFRAUDScoringData(OpportunityScoring scoring) {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c();
        report.Opportunity__c = scoring.opportunityId;
        report.Account__c = scoring.accountId;
        report.RU_scoring_type__c = CFUtils.FRAUD_SCORING_TYPE;
        report.RecordTypeId = CFUtils.RUSSIAN_FRAUD_RECORD_TYPE;
        report.Name = CFUtils.FRAUD_SCORING_TYPE;
        report.First_bill__c = scoring.firstBill;
        report.Different_post_address__c = scoring.differentPostAddress;
        report.New_legal__c = scoring.newLegal;
        report.Source_of_lead_matched__c = scoring.sourceOfLead;
        return this.cfRuDao.insertCreditFactoryReports(new List<Credit_Factory_Report__c> {report}).get(0);
    }


    /*****************************************************************************
    *  Name            : updateCFRuPrescoringData(Credit_Factory_Report__c report, E2EFormParams formParams)
    *  Summary         : updates prescoring CF report
    *  CreatedDate     : 21/10/2019
    *  Parameters      : E2EFormParams formParams - data source,
    *                  : Credit_Factory_Report__c report - report to update
    *  Returns         : Credit_Factory_Report__c - updated CF report
    ******************************************************************************/
    public Credit_Factory_Report__c updateCFRuPrescoringData(Credit_Factory_Report__c report, E2EFormParams formParams) {
        //link report to Opportunity and Account if not linked
        report.Opportunity__c = GlobalUtils.changeIfHasNewValue(report.Opportunity__c, formParams.opportunityId);
        report.Account__c = GlobalUtils.changeIfHasNewValue(report.Account__c, formParams.accountId);
        //update prescoring data
        report.RU_Scoring_date__c = formParams.scoringDate;
        report.RU_Scoring_expiration_date__c = formParams.scoringExpirationDate;
        report.RU_scoring_decision__c = formParams.scoringDecision;
        report.RU_scoring_decision_code__c = formParams.scoringDecisionCode;
        cfRuDao.updateCreditFactoryReports(new List<Credit_Factory_Report__c> {report});
        System.debug('********* CFReport UPDATED *************');
        return report;
    }

    /*****************************************************************************
    *  Name            : updateFRAUDScoringData(Credit_Factory_Report__c report, OpportunityScoring scoring)
    *  Summary         : updates FRAUD scoring report
    *  CreatedDate     : 30.07.2020
    *  Parameters      : Credit_Factory_Report__c report - report to update
    *                  : OpportunityScoring scoring - data source
    *  Returns         : Credit_Factory_Report__c - updated report
    ******************************************************************************/
    public Credit_Factory_Report__c updateFRAUDScoringData(Credit_Factory_Report__c report, OpportunityScoring scoring) {
        report.Opportunity__c = GlobalUtils.changeIfHasNewValue(report.Opportunity__c, scoring.opportunityId);
        report.Account__c = GlobalUtils.changeIfHasNewValue(report.Account__c, scoring.accountId);
        report.First_bill__c = scoring.firstBill;
        report.Different_post_address__c = scoring.differentPostAddress;
        report.New_legal__c = scoring.newLegal;
        report.Source_of_lead_matched__c = scoring.sourceOfLead;
        report.Scoring_notification_sent__c = scoring.notificationSent;
        return this.cfRuDao.updateCreditFactoryReports(new List<Credit_Factory_Report__c> {report}).get(0);
    }


    public Credit_Factory_Report__c getCFRById(Id id) {
        List<Credit_Factory_Report__c> data = this.cfRuDao.getCFR(new Set<Id> {id});
        return data.isEmpty() ? null : data.get(0);
    }

    public Credit_Factory_Report__c getCFR(Id opportunityId, String scoringType, Id recordTypeId) {
        List<Credit_Factory_Report__c> data = this.cfRuDao.getCFR(new Set<Id> {opportunityId}, scoringType, recordTypeId);
        return data.isEmpty() ? null : data.get(0);
    }

    /*****************************************************************************
    *  Name            : getCreditFactoryReportRU(Id opportunityId, Id recordTypeId, CFUtils.ScoringType scoringType)
    *  Summary         : returns actual Credit_Factory_Report__c for selected Opportunity, Scoring type and record type
    *  CreatedDate     : 11/12/2020
    *  Parameters      : Id opportunityId, Id recordTypeId, CFUtils.ScoringType scoringType - See CFUtils class
    *  Returns         : Credit_Factory_Report__c or null
    ******************************************************************************/
    public Credit_Factory_Report__c getCreditFactoryReportRU(Id opportunityId, CFUtils.ScoringType scoringType) {
        List<Credit_Factory_Report__c> data = this.cfRuDao.getCreditFactoryReports(
                new List<Id> {opportunityId},
                CFUtils.RUSSIAN_CREDIT_RECORD_TYPE,
                new List<String> {scoringType.name()}
        );
        return data.isEmpty() ? null : data.get(0);
    }


    // **** Opportunity service **** //

    /*****************************************************************************
    *  Name            : getRussianOpportunity(Id id)
    *  Summary         : gets Russian Sales Opportunity
    *  CreatedDate     : 05/12/2019
    *  Parameters      : Id id - Opportunity ID
    *  Returns         : Opportunity
    ******************************************************************************/
    public Opportunity getRussianOpportunity(Id id) {
        List<Opportunity> data = this.cfRuDao.getOpportunities(new List<Id> {id}, new List<Id> {OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID});
        return data.isEmpty() ? null : data.get(0);
    }

    public Opportunity getOpportunity(Id id) {
        List<Opportunity> data = this.cfRuDao.getOpportunities(new Set<Id> {id});
        return data.isEmpty() ? null : data.get(0);
    }


    /*****************************************************************************
    *  Name            : updateOpportunity(Opportunity opportunity)
    *  Summary         : updates Opportunity
    *  CreatedDate     : 05/12/2019
    *  Parameters      : Opportunity opportunity
    *  Returns         : Opportunity - updated Opportunity
    ******************************************************************************/
    public Opportunity updateOpportunity(Opportunity opportunity) {
        return cfRuDao.updateOpportunities(new List<Opportunity>{opportunity}).get(0);
    }

    public E2EFormData__c getByOpportunityId(Id opportunityId) {
        List<E2EFormData__c> data = this.cfRuDao.getByOpportunityId(new Set<Id> {opportunityId});
        return data.isEmpty() ? null : data.get(0);
    }

    /*****************************************************************************
    *  Name            : checkBBLApprovalProcess(E2EFormParams formParams)
    *  Summary         : checks if approval process passed from RMD
    *  CreatedDate     : 09/09/2020
    *  Parameters      : E2EFormParams formParams
    *  Returns         : Boolean. "true" value when process was active and passed.
                         "false" in other cases.
    ******************************************************************************/
    public Boolean checkBBLApprovalProcess(E2EFormParams formParams) {
        CF_Settings__c cfRuSetting = CFUtils.getCFSettingsFor(GlobalUtils.FleetcorCountries.Russia.name());

        if (cfRuSetting != null && String.isNotBlank(cfRuSetting.Approval_Process_Name__c)) {
            Boolean approvalApproved = GlobalUtils.checkApprovalApproved(formParams.opportunityId, cfRuSetting.Approval_Process_Name__c);
            if (approvalApproved) {
                this.blockCompany = false;
            }

            return approvalApproved;
        } else  {
            return false;
        }
    }

    public List<Credit_Factory_Report__c> getActualCFRs(Id opportunityId) {
        CFRTriggerHandlerHelper cfrTriggerHelper = new CFRTriggerHandlerHelper();
        List<String> recordtypeNames = new List<String>();
        List<String> recordTypeIds = new List<String>();
        recordtypeNames.addAll(cfrTriggerHelper.getRecordTypeNamessForCFR());
        Map<String, Schema.RecordTypeInfo> cfrRecordTypeMap = Credit_Factory_Report__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

        if (!recordtypeNames.isEmpty() && cfrRecordTypeMap != null && !cfrRecordTypeMap.isEmpty()) {
            for (String recTypeDevName : recordtypeNames) {
                Schema.RecordTypeInfo recordTypeInfo = cfrRecordTypeMap.get(recTypeDevName);
                if (recordTypeInfo != null) {
                    recordTypeIds.add(recordTypeInfo.getRecordTypeId());
                }
            }
        }

        return cfRuDao.getActualCFRs(opportunityId, recordTypeIds);
    }

    public Credit_Factory_Report__c getChosenCFR(Id opportunityId) {
        List<Credit_Factory_Report__c> actualCfrs = getActualCFRs(opportunityId);

        if (!actualCfrs.isEmpty()) {
            for (Credit_Factory_Report__c cfrRecord : actualCfrs) {
                if (cfrRecord.RU_Client_Choice__c) {
                    return cfrRecord;
                }
            }
        }

        return null;
    }

    public void saveChekedCFR(Id opportunityId, E2EFormParams formParams) {
        List<Credit_Factory_Report__c> cfrsUpdate = new List <Credit_Factory_Report__c>();
        List<Credit_Factory_Report__c> cfrsForUpdate = cfRuDao.getCfrForUpdate(opportunityId);

        if (!cfrsForUpdate.isEmpty()) {
            for (Credit_Factory_Report__c check : cfrsForUpdate) {
                if (String.valueOf(check.id) == formparams.creditDecision) {
                    check.RU_Client_choice__c = true;
                } else {
                    check.RU_Client_choice__c = false;
                }
                cfrsUpdate.add(check);
            }
            update cfrsUpdate;
        }
    }

    private Credit_Factory_Report__c writePrescoringResponseData(Credit_Factory_Report__c report, DecisionPrescoring data) {
        report.RU_Scoring_Credit_Period__c = data.creditPeriod;
        report.RU_Scoring_Payment_Time_Limit__c = data.paymentTimeLimit;
        report.Credit_Limit__c = String.valueOf(data.overdraft);
        report.RU_Scoring_date__c = CFUtils.parsePrescoringDate(data.dateRequest);
        report.RU_Scoring_expiration_date__c = CFUtils.parsePrescoringDate(data.expireDate);
        if (data.decision == null || data.blocked == null) {
            report.RU_Application_Blocked__c = true;
            report.RU_scoring_decision__c = CFUtils.ScoringDecision.No_data.name();
        } else {
            report.RU_Application_Blocked__c = data.blocked;
            report.RU_scoring_decision__c = CFUtils.parsePreScoringDecision(data);
        }
        return report;
    }
}