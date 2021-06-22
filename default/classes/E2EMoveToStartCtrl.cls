global with sharing class E2EMoveToStartCtrl {

    public static final String MOVE_TO_START_WARNING_WRONG_STAGE = System.Label.MOVE_TO_START_WARNING_WRONG_STAGE;
    private static final String BUSINESS_PROCESS = GlobalUtils.BusinessProcessType.E2EBusiness.name();
    private static final String COUNTRY = GlobalUtils.FleetcorCountries.Russia.name();
    private static final String MULTI_OFFER = GlobalUtils.getContractType('MultiOffer');
    private static final String FREE_OVERDRAFT = E2EMoveToStartService.FREE_OVERDRAFT;

    private String currentUserId { get; private set; }
    private String currentUserProfileId { get; private set; }
    private E2E_business_settings__c settings = E2E_business_settings__c.getValues(COUNTRY);
    public String currentUserRole { get; set; }
    private String managerTransitId { get; private set; }
    public String pageTitle { get; private set; }
    public Boolean hasPageError { get; set; }
    public Id opportunityId { get; set; }
    private Id contactId { get; set; }
    public Id formDataId { get; set; }
    private Id accountId { get; set; }
    public String formDataInn { get; set; }
    public Integer cardsLimit { get; set; }
    public Boolean showFinalStep { get; set; }
    public Boolean matchExecutiveSpark { get; set; }
    public Boolean isStartButtonEnabled { get; set; }
    public Boolean isSaveButtonEnabled { get; set; }
    public Boolean approvalProcessRMDActive { get; set; }

    public Account account { get; set; }
    public Opportunity oppty { get; set; }
    public Contact contactDecisionMaker { get; set; }
    public E2EFormData__c formData { get; set; }
    public E2EFormParams formParams { get; set; }
    public List<SelectOption> productOptions { get; set; }
    public List<SelectOption> promoCodeList { get; set; }
    public List<SelectOption> addPromoCodeList { get; set; }
    public Boolean additionalPromoCode { get; set; }
    //VS SF-1429
    public List<SelectOption> electronicDocumentManagementList { get; set; }	
    public String daDataToken {get; set;}
    public List<SelectOption> creditDecisionList { get; set; }

    /*execution status*/
    public String executionStatus { get; set; }
    public String activeStep { get; set; }
    private Boolean isActivatedContractPreview { get; set; }
    private Boolean terminateProcess;
    private Boolean recordLockecdByRMD;
    private Boolean executedMoveToStart;
    private Boolean recordApprovedByRMD;

    /*preview contract*/
    public String previewContractContent {
        get {
            return EncodingUtil.Base64Encode(getPreviewContract());
        }
    }

    /* Services */
    public E2EFormRuService formService;
    public SparkWebService sparkWebService;
    public ScoringWebService scoringWebService;
    public CrmWebService crmWebService;
    public ReportWebService reportWebService;
    public TransitWebService transitWebService;
    public MZKWebService mzkWebService;
    public E2EMoveToStartService moveToStartService;
    @TestVisible
    private CFService cfrService;

    // FOR REMOTE ACTION
    global static String companyInfoSpark { get; set; }
    global static String soleInfoSpark { get; set; }
    public String blackListDecision { get; set; }
    public String scoringPassed { get; set; }
    global static Boolean scoringRefused { get; set; }

    /***************************************************************************************************
	*  Name            : init()
	*  Summary         : initializes Visualforce page for the controller
	*  CreatedDate     : 15/02/2019
	*  Parameters      : -
	*  Returns         : void
	****************************************************************************************************/
    public void init() {
        this.currentUserId = UserInfo.getUserId();
        this.currentUserProfileId = UserInfo.getProfileId();
        this.isActivatedContractPreview = false;
        this.hasPageError = false;
        this.showFinalStep = true;
        this.matchExecutiveSpark = false;

        this.pageTitle = 'Проверка данных о клиенте для передачи на старт';
        this.opportunityId = ApexPages.CurrentPage().getParameters().get('id');
        this.cardsLimit = Integer.valueOf(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').E2EBUS_CardNumLimit__c);
        this.formService = returnFormService(COUNTRY);
        this.sparkWebService = returnSparkWebService(COUNTRY);
        this.scoringWebService = returnScoringWebService(COUNTRY);
        this.crmWebService = returnCrmWebService(COUNTRY);
        this.reportWebService = returnReportWebService(COUNTRY);
        this.transitWebService = returnTransitWebService(COUNTRY);
        this.mzkWebService = returnMZKWebService(COUNTRY);
        this.moveToStartService = new E2EMoveToStartService();
        this.cfrService = new CFServiceRuImpl();
        this.formParams = new E2EFormParams();
        this.formParams.businessProcess = BUSINESS_PROCESS;
        this.contactId = null;
        this.terminateProcess = false;
        this.isSaveButtonEnabled = true;
        this.recordLockecdByRMD = false;
        this.executedMoveToStart = false;
        this.approvalProcessRMDActive = settings != null && String.isNotBlank(settings.Approval_Process_Name__c);
        this.recordApprovedByRMD = false;
        if (settings != null && String.isNotBlank(settings.DaData_Token__c)) {
            this.daDataToken  = settings.DaData_Token__c;
        }
		//VS SF-1429
		gatherElectronicDocumentManagementList();
        if (opportunityId != null) {
            this.recordLockecdByRMD = moveToStartService.checkRMDRecordLock(opportunityId);
            this.isStartButtonEnabled = moveToStartService.checkStartAvailability(this.settings, this.recordLockecdByRMD);
            this.isSaveButtonEnabled = !this.recordLockecdByRMD;

            this.formParams.opportunityId = opportunityId;
            this.oppty = formService.getOpportunityById(opportunityId);
            this.managerTransitId = GlobalUtils.getTransitIdByUserId(this.oppty.OwnerId);

            this.promoCodeList = new List<SelectOption>();
            this.addPromoCodeList = new List<SelectOption>();

            this.formParams.promocodeName = this.formParams.promoCode;

            if (this.oppty.INN_Opp__c != null) {
                if (checkAccessibility()) {
                    this.account = formService.getAccountById(oppty.AccountId);
                    this.accountId = account.Id;

                    if (oppty.E2EFormRuData__r.size() == 0) {
                        this.formDataId = this.formService.createFormDataRecord(account.Id, oppty.Id, formParams);
                        this.formData = formService.getFormDataById(formDataId);
                    } else {
                        this.formData = formService.getFormDataById(oppty.E2EFormRuData__r[0].Id);
                        this.formDataId = this.formData.Id;
                    }

                    this.formDataInn = this.formData.E2E_INN__c;
                    this.productOptions = this.formService.getFieldPickListSelectOptions(Opportunity.Product_PPR__c.getDescribe());
                    this.productOptions = this.moveToStartService.filterProducts(this.productOptions);
                    this.formParams = this.formService.getCurrentDataToShowOnForm(account, oppty, formData);

                    if (productOptions.size() > 0 && formParams.product == null) {
                        formParams.product = this.productOptions[0].getValue();
                    }
                    gatherPromos();
                    this.showFinalStep = (this.formParams.transitContId != null || this.formParams.transitContId == '') ? true : false;
                }
                checkOpportunityStage(oppty);
            } else {
                this.hasPageError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Ошибка. У Возможности отсутствует ИНН.'));
            }
            
            List <Credit_Factory_Report__c> actualCfrs = this.cfrService.getActualCFRs(opportunityId);
            this.creditDecisionList = this.moveToStartService.setCreditDecisions(actualCfrs, this.formData, this.oppty.Source_PP__c);
            this.moveToStartService.setPreselectedCreditDecision(actualCfrs, this.formData, this.formParams);
        } else {
            this.hasPageError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Ошибка. Вы пытаетесь открыть страницу без указания Возможности.'));
        }

        UserRole roleInfo = (new E2EFormRuDaoImpl()).getUserRoleById(UserInfo.getUserRoleId());
        if (roleInfo.DeveloperName.startsWithIgnoreCase('PPR')) {
            this.currentUserRole = 'PPR';
            this.formParams.businessType = 0;
            this.formParams.idEqv = 1;
        } else if (roleInfo.DeveloperName.startsWithIgnoreCase('GPC')) {
            this.currentUserRole = 'GPC';
            this.formParams.businessType = 4;
            this.formParams.idEqv = 26;
        }
    }

    /******************************************************************************
    *  Name            : checkAccessibility()
    *  Summary         : check whether manager can access the page or not
    *  CreatedDate     : 21/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean - if manager can access the page
    ******************************************************************************/
    private Boolean checkAccessibility() {
        Profile userProfile = ProfileManager.getProfileByName(Label.System_Administrator);
        Boolean isNotAdmin = userProfile != null && !userProfile.Id.equals(this.currentUserProfileId);
        if (!this.oppty.Owner.Id.equals(currentUserId) && isNotAdmin) {
            this.hasPageError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Доступ запрещён. Вы не являетесь владельцем этой возможности.'));
            return false;
        } else if (this.oppty.CategoryContract__c == null || !this.oppty.CategoryContract__c.equals(MULTI_OFFER)) {
            this.hasPageError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Договор не является мультиофертным.'));
            return false;
        } else if (this.managerTransitId == null || this.managerTransitId.length() != 32) {
            this.hasPageError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ошибка. У Вас некорректный transit GUID. Пожалуйста, обратитесь к администратору.'));
            return false;
        }
        return true;
    }

    /******************************************************************************
    *  Name            : checkOpportunityStage()
    *  Summary         : check what stage opportunity has
    *  CreatedDate     : 28/09/2019
    *  ModifiedDate    : 1/12/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkOpportunityStage(Opportunity oppty) {
        Boolean isQualifiedLead = oppty.StageName.equals(GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead));
        Boolean isClientNegotiations = oppty.StageName.equals(GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Client_Negotiations));
        Boolean isCheckCreditHistory = oppty.StageName.equals(GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Check_Credit_History));
        Boolean isAgreementTermsAndConditions = oppty.StageName.equals(GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AgreementTermsAndConditions));

        if (!isQualifiedLead && !isClientNegotiations && !isCheckCreditHistory && !isAgreementTermsAndConditions) {
            this.isSaveButtonEnabled = false;
        }

        if (!isAgreementTermsAndConditions) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, String.format(MOVE_TO_START_WARNING_WRONG_STAGE, new List<String>{oppty.StageName})));
            this.isStartButtonEnabled = false;
        }
    }

    /******************************************************************************
    *  Name            : doDisabledTriggers()
    *  Summary         : disabling SF triggers
    *  CreatedDate     : 29/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doDisabledTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;

        ContactTriggerHandler.isE2EForm = true;
        OpportunityTriggerHandler.isE2EForm = true;
    }

    public void getSparkData(String inn, Boolean catchException) {
        try {
            String sparkId = '';
            Integer blackListDecision;
            if (formParams.isSoleProprietor) {
                SoleProprietorSpark soleProprietorInfo = sparkWebService.getEntrepreneurShortReportByInn(formParams.companyInn);
                if (soleProprietorInfo.sparkID != null) {
                    sparkId = String.valueOf(soleProprietorInfo.sparkID);
                    formParams.sparkId = soleProprietorInfo.sparkID;
                    formParams.soleProprietorFio = soleProprietorInfo.fullNameRus;
                    formParams.mainCompanyFullNameSpark = 'ИП ' + soleProprietorInfo.fullNameRus;
                    String registrationDate = String.valueOf(((DateTime) Json.deserialize('"' + soleProprietorInfo.dateReg + '"', DateTime.class)).format('dd.MM.yyyy'));
                    formParams.registrationDateSpark = registrationDate;
                    formParams.ogrnipSpark = soleProprietorInfo.ogrnip;
                    formParams.emptySparkOkpo = String.isBlank(soleProprietorInfo.okpo);
                    formParams.okpoSpark = formParams.emptySparkOkpo ? formParams.okpoSpark : soleProprietorInfo.okpo;

                    // verify company by black lists
                    CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(inn, String.valueOf(formParams.sparkId), opportunityId);
                    System.debug('**** SOLE PROPRIETOR VERIFICATION DECISION: ' + verificationDecision.decision + ', listType=' + verificationDecision.blackListType);
                    if (verificationDecision != null) {
                        if (this.executedMoveToStart && this.approvalProcessRMDActive) {
                            this.recordApprovedByRMD = moveToStartService.checkRMDDecision(verificationDecision, opportunityId, settings);
                            if (!recordApprovedByRMD) {
                                this.terminateProcess = moveToStartService.checkForRMDApproval(verificationDecision, opportunityId, settings);
                            } 
                            if (this.terminateProcess) {
                                return;
                            }
                        }
                        Boolean skipProcess = this.executedMoveToStart && this.approvalProcessRMDActive && this.recordApprovedByRMD;

                        formParams.verifiedDecision = scoringWebService.prepareBlackListDecisionForSF(verificationDecision.decision);
                        formParams.verifiedDecisionCode = String.valueOf(verificationDecision.decision);
                        formParams.verifiedLimitation = String.valueOf(verificationDecision.limitation);
                        if (verificationDecision.decision == 3) {
                            // update before throwing exception
                            blackListDecision = verificationDecision.decision;
                            formParams.opportunityLostReason = 'Другое';
                            // if in black list - error
                            if (catchException) {
                                throw new E2EFormRuException('Sole Proprietor in BlackList verification failed: inn=' + inn + ', sparkId=' + sparkId);
                            } else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sole Proprietor in BlackList verification failed: inn=' + inn + ', sparkId=' + sparkId));
                            }
                        } else if (!skipProcess && (verificationDecision.decision == 1 || verificationDecision.decision == 4)) {
                            blackListDecision = verificationDecision.decision;
                            if (catchException) {
                                throw new E2EFormRuException('Sole Proprietor need approve, verification decision is: ' + blackListDecision);
                            } else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sole Proprietor need approve, verification decision is: ' + blackListDecision));
                            }
                        }
                        this.formParams.checkedInBlackList = ' > ' + GlobalUtils.E2ERuProcessStatus.CheckedInBlackList.name(); // log process
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SOLE PROPRIETOR VERIFICATION DECISION: verificationDecision is NULL'));
                    }
                } else {
                    formParams.scoringDecision = 'Предоплата';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SOLE PROPRIETOR INFO sparkID: ' + soleProprietorInfo.sparkID));
                }
                System.debug('**** SPARK ID: ' + formParams.sparkId + ' SPARK SOLE: ' + formParams.mainCompanyFullNameSpark);
            } else {
                // get company information from spark
                List<CompanySpark> mainCompanySpark = sparkWebService.getCompanyListByInn(inn);
                ExtendedReportSpark.Leader actualLeader = new ExtendedReportSpark.Leader();
                if (!mainCompanySpark.isEmpty()) {
                    sparkId = String.valueOf(mainCompanySpark.get(0).sparkID);
                    formParams.sparkId = mainCompanySpark.get(0).sparkID;
                    formParams.mainCompanyFullNameSpark = mainCompanySpark.get(0).fullName;
                    System.debug('**** SPARK ID: ' + formParams.sparkId + ' SPARK COMPANY: ' + formParams.mainCompanyFullNameSpark);

                    // get extended information from spark
                    ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(inn, String.valueOf(formParams.sparkId));
                    System.debug('**** EXTENDED REPORT: ' + extendedReport);
                    if (extendedReport != null) {
                        actualLeader = sparkWebService.getCompanyActualLeader(extendedReport.LeaderList.leader);
                        String registrationDate = String.valueOf(((DateTime) Json.deserialize('"' + extendedReport.dateFirstReg + '"', DateTime.class)).format('dd.MM.yyyy'));
                        formParams.registrationDateSpark = registrationDate;
                        formParams.executiveFio = actualLeader.fio;
                        formParams.executivePosition = actualLeader.position;
                        formParams.emptySparkOkpo = String.isBlank(extendedReport.okpo);
                        formParams.okpoSpark = formParams.emptySparkOkpo ? formParams.okpoSpark : extendedReport.okpo;
                        formParams.ogrnSpark = extendedReport.ogrn;
                        formParams.kppSpark = extendedReport.kpp;
                        formParams.companyCountry = 'Россия';
                        formParams.postCodeSpark = extendedReport.LegalAddresses.address.postCode;
                        formParams.regionSpark = extendedReport.LegalAddresses.address.region;
                        formParams.citySpark = extendedReport.LegalAddresses.address.city;
                        formParams.streetSpark = extendedReport.LegalAddresses.address.streetName;
                        formParams.buildingSpark = extendedReport.LegalAddresses.address.buildingNumber;
                        formParams.housingSpark = extendedReport.LegalAddresses.address.housing;
                        formParams.blockSpark = extendedReport.LegalAddresses.address.block;
                        formParams.roomSpark = extendedReport.LegalAddresses.address.room;
                        formParams.legalAddressSpark = extendedReport.LegalAddresses.address.address;
                        formParams.normName = extendedReport.normName;
                        formParams.companyName = extendedReport.shortNameRus;
                        formParams.legalAddressSpark = mainCompanySpark.get(0).address;

                        if (formParams.executivePosition == null || formParams.executivePosition == '') {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'COMPANY executivePosition: ' + formParams.executivePosition));
                        }
                    }

                    // verify company by black lists
                    CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(formParams.companyInn, String.valueOf(formParams.sparkId), opportunityId);
                    System.debug('**** COMPANY VERIFICATION DECISION: ' + verificationDecision.decision + ', listType=' + verificationDecision.blackListType);
                    if (verificationDecision != null) {
                        if (this.executedMoveToStart && this.approvalProcessRMDActive) {
                            this.recordApprovedByRMD = moveToStartService.checkRMDDecision(verificationDecision, opportunityId, settings);
                            if (!recordApprovedByRMD) {
                                this.terminateProcess = moveToStartService.checkForRMDApproval(verificationDecision, opportunityId, settings);
                            }
                            if (this.terminateProcess) {
                                return;
                            }
                        }
                        Boolean skipProcess = this.executedMoveToStart && this.approvalProcessRMDActive && this.recordApprovedByRMD;

                        formParams.verifiedDecision = scoringWebService.prepareBlackListDecisionForSF(verificationDecision.decision);
                        formParams.verifiedDecisionCode = String.valueOf(verificationDecision.decision);
                        formParams.verifiedLimitation = String.valueOf(verificationDecision.limitation);
                        if (verificationDecision.decision == 3) {
                            // update before throwing exception
                            blackListDecision = verificationDecision.decision;
                            formParams.opportunityLostReason = 'Другое';
                            // if in black list - error
                            if (catchException) {
                                throw new E2EFormRuException('Company in BlackList verification failed: inn=' + formParams.companyInn + ', sparkId=' + sparkId);
                            } else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company in BlackList verification failed: inn=' + formParams.companyInn + ', sparkId=' + sparkId));
                            }
                        } else if (!skipProcess && (verificationDecision.decision == 1 || verificationDecision.decision == 4)) {
                            blackListDecision = verificationDecision.decision;
                            if (catchException) {
                                throw new E2EFormRuException('Company need approve, verification decision is: ' + blackListDecision);
                            } else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company need approve, verification decision is: ' + blackListDecision));
                            }
                        }
                        this.formParams.checkedInBlackList = ' > ' + GlobalUtils.E2ERuProcessStatus.CheckedInBlackList.name(); // log process
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'COMPANY VERIFICATION DECISION: verificationDecision is NULL'));
                    }

                    // do not score the company if it was manual entry or if company is in a black list
                    if (verificationDecision != null && verificationDecision.decision != 3) {
                        DecisionScoring decision = scoringWebService.getScoringDecision(formParams.companyInn, String.valueOf(formParams.sparkId), opportunityId);
                        DateTime d = Date.Today();
                        formParams.scoringDateString = d.format('dd.MM.yyyy');
                        formParams.scoringDate = Date.today();
                        System.debug('**** SCORING DECISION: ' + decision.decision);
                        if (decision != null) {
                            if (decision.decision == 2) {
                                if (catchException) {
                                    throw new E2EFormRuException('Scoring - refused to cooperate: inn=' + inn + ', sparkId=' + sparkId);
                                } else {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Scoring - refused to cooperate: inn=' + inn + ', sparkId=' + sparkId));
                                }
                            }
                            formParams.scoringDecision = scoringWebService.prepareScoringDecisionForSF(decision.decision);
                            formParams.scoringDecisionCode = String.valueOf(decision.decision);
                            formParams.scoringDateString = d.format('dd.MM.yyyy');
                            formParams.scoringDate = Date.today();
                        } else {
                            // if something wrong with scoring and we got empty decision then credit denied
                            formParams.scoringDecision = 'Предоплата';
                        }
                        this.formParams.scoringPassed = ' > ' + GlobalUtils.E2ERuProcessStatus.ScoringPassed.name(); // log process
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'COMPANY VERIFICATION DECISION: verificationDecision=' + verificationDecision + ', verificationDecision.decision=' + verificationDecision.decision));
                    }
                } else {
                    // if spark couldn't find data about company, hide the manual entry checkbox on legal details and make manual entry true
                    formParams.scoringDecision = 'Предоплата';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'COMPANY INFO sparkID: ' + mainCompanySpark.get(0).sparkID));
                }
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2EMoveToStartCtrl method getSparkData(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /***************************************************************************************************
    *  Name            : saveSObjects()
    *  Summary         : save Salesforce objects
    *  CreatedDate     : 05/03/2019
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************************************/
    public void saveSObjects() {
        //keep business process in E2EFormParams
        this.formParams.businessProcess = BUSINESS_PROCESS;        
        doDisabledTriggers();

        if (additionalPromoCode==false) {
            this.formParams.addPromoCode = null;
            this.formParams.addPromoCodeIdInTransit = null;
            this.formParams.addPromoCodeName = null;
        }

        System.debug('PROMOCODE IN SF - ' + this.formParams.promoCode);
        if (this.formParams.promoCode != null && this.formParams.promoCode != '') {
            this.getPromocode(this.formParams.promoCode, this.formParams.addPromoCode);
        }
        System.debug('PROMOCODE IN SERVICES - ' + this.formParams.promocodeName);

        //this.formParams.promocodeName = this.formParams.promoCode;
        //this.formParams.promoCodeIdInTransit = E2E_Promocodes__c.getValues(formParams.promocodeName).Transit_Identifier__c;
        getSparkData(formParams.companyInn, true);
        System.debug('Save SparkData is complete');

        if (this.terminateProcess) {
            this.isSaveButtonEnabled = false;
            return;
        }
        
        //VS SF-579
        if (formParams.isSoleProprietor) {
            if (formParams.ogrnipSpark != null) formParams.ogrn = formParams.ogrnipSpark;
        } else {
            if (formParams.ogrnSpark != null) formParams.ogrn = formParams.ogrnSpark;
        }
        if (formParams.kppSpark != null) formParams.kpp = formParams.kppSpark;

        if (String.isBlank(formParams.okpoSpark)) {
            formParams.okpoSpark = formParams.okpo;
        } else {
            formParams.okpo = formParams.okpoSpark;
        }

        if (formParams.legalAddressSpark != null) formParams.companyLegalAddress = formParams.legalAddressSpark;
        if (formParams.isLegalAddressCorrespondWithPostAddress) {
            if (formParams.postCodeSpark != null) {
                // SF-793
                formParams.postalAddressPostalCode = formParams.postCodeSpark;
                formParams.companyLegalAddressPostalCode = formParams.postCodeSpark;
            }
        } else {
            if (formParams.postCodeSpark != null) {
                formParams.companyLegalAddressPostalCode = formParams.postCodeSpark;
            }
//            if ()
//            formParams.postalAddressPostalCode = formParams.postalAddress;
        }
        if (formParams.citySpark != null) formParams.companyLegalAddressCity = formParams.citySpark;
        if (formParams.streetSpark != null) formParams.companyLegalAddressStreet = formParams.streetSpark;
        if (formParams.buildingSpark != null) formParams.companyLegalAddressHouse = formParams.buildingSpark;
        List<String> listAddressAdditionally = new List<String>();
        if (formParams.housingSpark != null) listAddressAdditionally.add('корпус ' + formParams.housingSpark);
        if (formParams.blockSpark != null) listAddressAdditionally.add('блок ' + formParams.blockSpark);
        if (formParams.roomSpark != null) listAddressAdditionally.add('квартира ' + formParams.roomSpark);
        if (listAddressAdditionally.size() > 0) formParams.legalAddressAdditionally = String.join(listAddressAdditionally, ', ');
          
        this.contactId = E2EMoveToStartService.processContactUpsertion(formParams, this.oppty, this.account.Id);
        this.oppty = formService.getOpportunityById(opportunityId);
             
        sendDataToPDService(this.contactId);

        if (formParams.creditDecision != null && opportunityId != null) {
            formParams.freeOverdraft = formParams.creditDecision == FREE_OVERDRAFT;
            this.cfrService.saveChekedCFR(opportunityId, formParams);
        }

        if (oppty.AccountId != null && opportunityId != null) {

            formService.updateAccount(oppty.AccountId, formParams);
            System.debug('**** Save Account is complete');

            formService.updateOpportunity(opportunityId, formParams);
            System.debug('**** Save Opportunity is complete');

            formService.updateFormData(formDataId, formParams);
            System.debug('Save FormData is complete');
        }

        Boolean contactCreatedOrUpdated = false;

        // Create executive person contact
        if (this.formParams.executiveFioManual != null && this.formParams.executiveFioManual != '' &&
                this.formParams.executivePositionManual != null && this.formParams.executivePositionManual != '') {
            this.formParams.executiveId = this.formService.createEmployeeContact(
                    this.accountId,
                    this.formParams.executiveFioManual,
                    this.formParams.executivePositionManual,
                    BUSINESS_PROCESS
            );
            contactCreatedOrUpdated = true;
        }
        // Update execute person
        if (this.formParams.isSoleProprietor != true &&
                this.formParams.executiveId != null &&
                this.formParams.executiveId != '' &&
                this.formParams.executiveFioManual != '' &&
                this.formParams.executivePositionManual != '') {
            this.formService.updateEmployeeContact(
                    this.formParams.executiveId,
                    this.formParams.executiveFioManual,
                    this.formParams.executivePositionManual,
                    BUSINESS_PROCESS
            );
            // Update OpportunityContactRole for execute person
            this.formService.updateOpportunityContactRole(this.opportunityId, this.formParams.executiveId, 'Decision Maker', false);
            contactCreatedOrUpdated = true;
        }

        if (contactCreatedOrUpdated) {
            sendDataToPDService(this.formParams.executiveId);
        }
    }

    /***************************************************************************************************
    *  Name            : moveToStart()
    *  Summary         : process opportunity to start
    *  CreatedDate     : 07/03/2019
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************************************/
    public void moveToStart() {
        this.executedMoveToStart = true;
        this.executionStatus = '';
        this.formParams.sourceLead = oppty.Source_of_Lead_o__c;
        System.debug('PROMOCODE IN SF - ' + this.formParams.promoCode);
        if (this.formParams.promoCode != null && this.formParams.promoCode != '') {
            this.getPromocode(this.formParams.promoCode, this.formParams.addPromoCode);
        }

        System.debug('PROMOCODE IN SERVICES - ' + this.formParams.promocodeName);
        this.formParams.lastLaunch = Datetime.now();
        System.debug('LAST LAUNCH IN E2E BUSSINESS - ' + this.formParams.lastLaunch);
        try {
            checkOpportunityStage(this.oppty);
            //*******Saving data from form*********//
            System.debug('*************SAVING BEGIN************');
            saveSObjects();
            System.debug('*************SAVING DONE************');

            if (this.terminateProcess) {
                return;
            }
            
            this.formService.updateOpportunityStage(opportunityId, GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractChecking));
            //*******Deduplication Account*********//
            System.debug('*************DEDUPLICATION BEGIN************');
            if (moveToStartService.checkApprovalStatus(this.opportunityId, settings) || !deduplicationAccount()) {
                System.debug('*************DEDUPLICATION DONE************');

                //*******Transit, MZK, report requests********//
                this.formParams.transitManagerId = this.managerTransitId;
                System.enqueueJob(new E2EAsyncSenderRequests(this.formDataId, this.formParams, null, GlobalUtils.BusinessProcessType.E2EBusiness));
                System.debug('**** AsyncSenderRequests QUEUEABLE LAUNCHED');
            }
            if (!this.hasPageError && (this.executionStatus == '')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Запрос постановки клиента на Старт отправлен. ' +
                        'После завершения обработки в карточке Возможности появится Transit Id клиента и Номер заявки МЗК.'));
            }
        } catch (Exception e) {
            this.executionStatus = 'Системная ошибка!';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(e.getMessage())));
            System.debug('**** EXCEPTION: ' + String.valueOf(e.getMessage()) + '\r\n' + 'STACK TRACE: ' + String.valueOf(e.getStackTraceString()));
            String notificationMessage = '<br/>E2E Business method moveToStart(): inn=' + this.formParams.companyInn + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        } finally {
            this.executedMoveToStart = false;
        }
    }

    public void getPromocode(String promocode, String addPromocode) {
        String productName = GlobalUtils.getE2EProduct(this.formParams.productId);
        if (this.formParams.productId == GlobalUtils.E2EProduct.PetrolPlus_Gaz.name())
            productName = GlobalUtils.getE2EProduct(this.formParams.productId) + ' – Сеть АЗС';
        if (promocode != null && !promocode.equals('')) {
            E2E_Promocodes__c promocodeObject = E2E_Promocodes__c.getValues(promocode);
            if (promocodeObject != null) {
                if (promocodeObject.Promocode_Additional_Field__c == null || promocodeObject.Supplier_Selection__c == 'False') {

                } else {
                    String dropdownList = promocodeObject.Promocode_Additional_Field__c;

                    String listPromocodeItems = dropdownList;
                    Map<String, String> supplies = new Map<String, String>();
                    for (String val : listPromocodeItems.split(';')) {
                        supplies.put(val.split('@')[0], val.split('@')[1]);
                    }
                    String idPromocodeItem = supplies.get(dropdownList.split(';')[0].split('@')[0]);
                    this.formParams.promocodeIdInTransit = idPromocodeItem;
                }
                this.formParams.promocodeName = promocodeObject.Name;
            }

            //дополнительный промокод
            promocodeObject = E2E_Promocodes__c.getValues(addPromocode);
            if (promocodeObject != null) {
                if (promocodeObject.Promocode_Additional_Field__c != null && promocodeObject.Supplier_Selection__c != 'False') {
                    String listPromocodeItems = promocodeObject.Promocode_Additional_Field__c;

                    Map<String, String> supplies = new Map<String, String>();
                    for (String val : listPromocodeItems.split(';')) {
                        supplies.put(val.split('@')[0], val.split('@')[1]);
                    }
                    String idPromocodeItem = supplies.get(listPromocodeItems.split(';')[0].split('@')[0]);
                    this.formParams.addPromoCodeIdInTransit = idPromocodeItem;
                }
                this.formParams.addPromoCodeName = promocodeObject.Name;
            }
        }
    }

    /***************************************************************************************************
	*  Name            : back()
	*  Summary         : redirects back to an Opportunity main page
	*  CreatedDate     : 18/03/2019
	*  Parameters      : -
	*  Returns         : PageReference
	*****************************************************************************************************/
    public PageReference back() {
        this.opportunityId = ApexPages.CurrentPage().getParameters().get('Id');
        return new PageReference('/' + this.opportunityId);
    }

    /*******************************************************************************
    *  Name            : deduplicationAccount()
    *  Summary         : checks if account duplicated
    *  CreatedDate     : 04/03/2019
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : none
    *  Returns         : Boolean - if account duplicated
    ******************************************************************************/
    private Boolean deduplicationAccount() {
        E2EFormRuDao e2eFormRuDao = new E2EFormRuDaoImpl();
        // prepare data for deduplication
        E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
        deduplicationResult.formDataId = this.formData.Id;
        deduplicationResult.e2eAccount = e2eFormRuDao.getAccountById(this.account.Id);
        deduplicationResult.e2eContact = e2eFormRuDao.getContactById(this.contactId);
        deduplicationResult.e2eOpportunity = e2eFormRuDao.getOpportunityById(this.opportunityId);
        deduplicationResult.excludedContacts = e2eFormRuDao.getContactsByAccount(deduplicationResult.e2eOpportunity.AccountId);
        //SF-1313 start
        //Excluding "Reanimation" Opps from deduplication
        if (String.isNotEmpty(deduplicationResult.e2eOpportunity.Promo_Code1__c) 
            && deduplicationResult.e2eOpportunity.Promo_Code1__c.startsWithIgnoreCase('реанимация')) {
            deduplicationResult.excludedOpportunities = e2eFormRuDao.getOpportunitiesByAccount(deduplicationResult.e2eOpportunity.AccountId);
        }
        //SF-1313 end
        deduplicationResult = this.formService.deduplicationAccountProcess(this.formParams.companyInn, this.formParams.mainContactEmail, deduplicationResult);

        // Account, который был определен как основной в процессе дедуюликации
        System.debug('**** deduplicationResult.e2eAccount.Id ' + deduplicationResult.e2eAccount.Id);
        System.debug('**** current.e2eAccount.Id ' + this.account.Id);
        System.debug('**** deduplicationResult.statusCode; -> ' + deduplicationResult.statusCode);
        System.debug('**** deduplicationResult -> ' + deduplicationResult);
        this.formParams.deduplicationStatus = deduplicationResult.statusCode;
        this.formParams.deduplicationStatusInfo = deduplicationResult.getDedupStatusInformation();
        if (deduplicationResult.statusCode.equals(GlobalUtils.DeduplicationStatus.Service.name())) {
            //Service marker
            E2EMoveToStartService.sendApprovalToService(this.opportunityId, settings);
            if (!String.isNotBlank(settings.Approval_Process_Service_Name__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                        System.Label.SendToService));
            }
            this.executionStatus = 'Необходимо согласование с сервисом.';
            return true;
        } else {
            if (deduplicationResult.innDuplication == true) {
                //duplication INN
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        'Обнаружен дубль по ИНН!'));
                this.executionStatus = 'Обнаружен дубль по ИНН!';
                return true;
            } else if ((deduplicationResult.isEmailDuplicated || deduplicationResult.isDomainDuplicated)
                    && deduplicationResult.isDifferentOwnerFoundForOpportunities) {
                //duplication email
                E2EMoveToStartService.sendApprovalToAdmin(this.opportunityId, settings);
                if (!String.isNotBlank(settings.Approval_Process_Admin_Name__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                            System.Label.SendingToApprovalAdmin));
                }
                this.executionStatus = 'Необходимо согласование с администратором.';
                return true;
            }  else {
                return false;
            }
        }
    }

    public void activatePreviewContract() {
        this.isActivatedContractPreview = true;
        System.debug('******** PREVIEW ACTIVATED *******');
    }

    /*******************************************************************************
    *  Name            : getPreviewContract()
    *  Summary         : return draft contract blob
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : Blob
    ******************************************************************************/
    private Blob getPreviewContract() {
        this.executionStatus = '';
        Blob body = Blob.valueOf('');
        if (this.isActivatedContractPreview == true) {
            this.isActivatedContractPreview = false;
            try {
                getSparkData(formParams.companyInn, false);
                List<String> reportIds = getReportIdsForContract(true);
                System.debug('**** DRAFT REPORT IDS: ' + reportIds);
                body = getContractContent(reportIds);
            } catch (Exception e) {
                this.executionStatus = 'Системная ошибка!';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(e.getMessage())));
                String notificationMessage = '<br/>E2EMoveToStartCtrl  method getPreviewContract(): ' + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
            }
        }
        return body;
    }

    /*******************************************************************************
    *  Name            : getReportIdsForContract(Boolean isDraft)
    *  Summary         : return report ids list from credit factory
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Boolean isDraft
    *  Returns         : List<String> reportIds
    ******************************************************************************/
    private List<String> getReportIdsForContract(Boolean isDraft) {
        ReportRequestData requestData = this.formService.prepareReportRequestData(this.formParams, isDraft, GlobalUtils.BusinessProcessType.E2EBusiness);
        System.debug('********* REPORT REQUEST DATA: ' + requestData);
        ReportResponseData response = this.reportWebService.getReportIdsFromCreditFactory(requestData);

        if (!isDraft) {
            this.formParams.contractPrefix = response.reportParams.SALESFORCE_CONTRACT_PREFIX;
            this.formParams.contractCounter = response.reportParams.SALESFORCE_CONTRACT_COUNTER;
            this.formParams.invoicePrefix = response.reportParams.SALESFORCE_INVOICE_PREFIX;
            this.formParams.invoiceCounter = response.reportParams.SALESFORCE_INVOICE_COUNTER;
        }
        return this.reportWebService.getOrderReportIds(response, GlobalUtils.reportIdsSequence);
    }

    /*******************************************************************************
    *  Name            : getContractContent(List<String> reportIds)
    *  Summary         : return contract blob by report ids
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : List<String> reportIds
    *  Returns         : Blob
    ******************************************************************************/
    private Blob getContractContent(List<String> reportIds) {
        if (reportIds != null && !reportIds.isEmpty()) {
            Blob body = this.reportWebService.getReportsFromReportService(reportIds);
            return body;
        } else {
            throw new E2EFormRuException('<br/>E2EMoveToStartCtrl method getContractContent (reportIds is empty)');
        }
    }

    /*******************************************************************************
    *  Name            : returnFormService(String countryName)
    *  Summary         : get General Form Service
    *  CreatedDate     : 15/02/2019
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : E2EFormRuService formService
    ******************************************************************************/
    public E2EFormRuService returnFormService(String countryName) {
        E2EFormRuService formService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            formService = new E2EFormRuServiceImpl();
        }
        return formService;
    }

    /*******************************************************************************
    *  Name            : returnSparkWebService(String countryName)
    *  Summary         : get Spark Web Service
    *  CreatedDate     : 09/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : SparkWebService sparkWebService
    ******************************************************************************/
    public SparkWebService returnSparkWebService(String countryName) {
        SparkWebService sparkWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            sparkWebService = new SparkWebServiceImpl();
        }
        return sparkWebService;
    }

    /*******************************************************************************
    *  Name            : returnCrmWebService(String countryName)
    *  Summary         : get Crm Web Service
    *  CreatedDate     : 30/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : CrmWebService crmWebService
    ******************************************************************************/
    public CrmWebService returnCrmWebService(String countryName) {
        CrmWebService crmWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            crmWebService = new CrmWebServiceImpl();
        }
        return crmWebService;
    }

    /*******************************************************************************
    *  Name            : returnReportWebService(String countryName)
    *  Summary         : get Report Web Service
    *  CreatedDate     : 30/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : ReportWebService reportWebService
    ******************************************************************************/
    public ReportWebService returnReportWebService(String countryName) {
        ReportWebService reportWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            reportWebService = new ReportWebServiceImpl();
        }
        return reportWebService;
    }

    /*******************************************************************************
    *  Name            : returnScoringWebService(String countryName)
    *  Summary         : get Scoring Web Service
    *  CreatedDate     : 23/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : ScoringWebService scoringWebService
    ******************************************************************************/
    public ScoringWebService returnScoringWebService(String countryName) {
        ScoringWebService scoringWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            scoringWebService = new ScoringWebServiceImpl();
        }
        return scoringWebService;
    }

    /*******************************************************************************
    *  Name            : returnTransitWebService(String countryName)
    *  Summary         : get Transit Web Service
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : TransitWebService transitWebService
    ******************************************************************************/
    public TransitWebService returnTransitWebService(String countryName) {
        TransitWebService transitWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            transitWebService = new TransitWebServiceImpl();
        }
        return transitWebService;
    }

    /*******************************************************************************
    *  Name            : returnMZKWebService(String countryName)
    *  Summary         : get MZK Web Service
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         :  MZKWebService mzkWebService
    ******************************************************************************/
    public MZKWebService returnMZKWebService(String countryName) {
        MZKWebService mzkWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            mzkWebService = new MZKWebServiceImpl();
        }
        return mzkWebService;
    }

    public void gatherPromos() {

        this.promoCodeList.clear();
        this.addPromoCodeList.clear();

        if (!String.isNotBlank(this.formParams.tariffId)) {
            return;
        }

        Map<String, E2E_Promocodes__c> promocodeObjects = E2E_Promocodes__c.getAll();
        for (String promo : promocodeObjects.keySet()) {
            if (String.isNotBlank(promocodeObjects.get(promo).Apply_to_tariffs__c)) {
                if (promocodeObjects.get(promo).Apply_to_tariffs__c.split(';').contains(this.formParams.tariffId)) {
                    if (promocodeObjects.get(promo).Enable_Main_Promo__c) 
                        this.promoCodeList.add(new SelectOption(promo, promo + ' - ' + promocodeObjects.get(promo).Promocode_Label__c));
                    if (promocodeObjects.get(promo).Enable_Additional_Promo__c) 
                        this.addPromoCodeList.add(new SelectOption(promo, promo + ' - ' + promocodeObjects.get(promo).Promocode_Label__c));
                }
            }
        }
    }
	
    //VS SF-1429
    public void gatherElectronicDocumentManagementList() {

        this.electronicDocumentManagementList = new List<SelectOption>();
        
        Schema.DescribeFieldResult describeResult = Opportunity.PPR_Electronic_document_management__c.getDescribe();
        List<Schema.PicklistEntry> entries = describeResult.getPicklistValues();

        for (Schema.PicklistEntry pEntry : entries) {
            if (pEntry.isActive()) {
                electronicDocumentManagementList.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
        }
    }	

    public PageReference updateCreditList() {
        this.formData = this.formService.getFormDataById(this.formDataId);
        List <Credit_Factory_Report__c> actualCfrs = this.cfrService.getActualCFRs(opportunityId);
        this.creditDecisionList = this.moveToStartService.setCreditDecisions(actualCfrs, this.formData, this.oppty.Source_PP__c);
        return null;
    }

    /*******************************************************************************
    *  Name            : sendDataToPDService(Id contactId)
    *  Summary         : get contact record by id and send data to the PD data base
    *  CreatedDate     : 20/05/2020
    *  ModifiedDate    : –
    *  Parameters      : contactId - contact id
    *  Returns         : void
    ******************************************************************************/
    @TestVisible
    private static void sendDataToPDService(Id contactId) {
        if (contactId != null && PD_Callouts.isPDActive()) {
            List<String> fields = new List<String>();
            List<Schema.FieldSetMember> pdFields = GlobalUtils.getFieldSetMembers (contactId.getSobjectType(), 'PD_Fields');
            List<Schema.FieldSetMember> phoneFields =  GlobalUtils.getFieldSetMembers(contactId.getSObjectType(), 'All_Phone_Fields');

            for (Schema.FieldSetMember pdField : pdFields) {
                fields.add(pdField.getFieldPath());
            }
            for (Schema.FieldSetMember phoneField : phoneFields) {
                fields.add(phoneField.getFieldPath());
            }

            String filedsForQuery = (!fields.isEmpty()) ? ', ' + String.join(fields, ', ') : '';

            String query = 'SELECT Id, PD_ExternalId__c' + filedsForQuery + ' FROM Contact Where Id =: contactId';
            List<Contact> contactsFromDB = Database.query(query);

            if (contactsFromDB != null && !contactsFromDB.isEmpty()) {
                PD_Callouts.sendReq_saveData(contactsFromDB.get(0));
            }
        }
    }

    /*******************************************************************************
    *  Name            : remoteGetCompanyData(String inn)
    *  Summary         : remote action get company data from SPARK
    *  CreatedDate     : 28/02/2019
    *  ModifiedDate    : -
    *  Parameters      : String inn
    *  Returns         : CompanySpark companySpark
    ******************************************************************************/
    @RemoteAction
    global static CompanySpark remoteGetCompanyData(String inn) {
        SparkWebService sparkWebService = new SparkWebServiceImpl();

        // get company information from spark
        List<CompanySpark> mainCompanySpark = new List<CompanySpark>();
        CompanySpark companySpark;
        try {
            mainCompanySpark = sparkWebService.getCompanyListByInn(inn);
            if (!mainCompanySpark.isEmpty()) {
                companySpark = mainCompanySpark.get(0);
                System.debug('**** Remote Action SPARK ID: ' + companySpark.sparkId + ' SPARK COMPANY: ' + companySpark.fullName);

                // get extended information from spark
                ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(inn, String.valueOf(companySpark.sparkId));
                System.debug('**** Remote Action EXTENDED REPORT: ' + extendedReport);
                if (extendedReport != null) {
                    companySpark.extendedReport = extendedReport;
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ошибка при получении данных из СПАРК!'));
            String notificationMessage = '<br/>E2E Remote Action remoteGetCompanyData(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
        return companySpark;
    }

    /*******************************************************************************
    *  Name            : remoteGetEntrepreneurData(String inn)
    *  Summary         : remote action get sole company data from SPARK
    *  CreatedDate     : 28/02/2019
    *  ModifiedDate    : -
    *  Parameters      : String inn
    *  Returns         : SoleProprietorSpark soleProprietorInfo
    ******************************************************************************/
    @RemoteAction
    global static SoleProprietorSpark remoteGetEntrepreneurData(String inn) {
        SparkWebService sparkWebService = new SparkWebServiceImpl();
        E2EFormParams formParams = new E2EFormParams();

        // get sole proprietor information from spark
        SoleProprietorSpark soleProprietorInfo;
        try {
            soleProprietorInfo = sparkWebService.getEntrepreneurShortReportByInn(inn);
            System.debug('**** RemoteAction SOLE INFO SPARK: ' + soleProprietorInfo);
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E Remote Action remoteGetEntrepreneurData(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
        return soleProprietorInfo;
    }

    @RemoteAction
    global static void remoteUpdateEntrepreneurShortReport(String soleProprietorInfoJson, String formDataId) {
        String soleProprietorInfo = soleProprietorInfoJson.replace('&quot;', '\"');
        System.debug('soleProprietorInfo: ' + soleProprietorInfo);
        if (soleProprietorInfo != null && soleProprietorInfo != '') {
            SoleProprietorSpark soleProprietorSpark = (SoleProprietorSpark) System.JSON.deserialize(soleProprietorInfo, SoleProprietorSpark.class);
            if (soleProprietorSpark != null && soleProprietorSpark.sparkID != null) {
                E2EFormParams formParams = new E2EFormParams();
                formParams.sparkId = soleProprietorSpark.sparkID;
                formParams.companyInn = soleProprietorSpark.inn;
                formParams.soleProprietorFio = soleProprietorSpark.fullNameRus;
                formParams.mainCompanyFullNameSpark = 'ИП ' + soleProprietorSpark.fullNameRus;
                formParams.registrationDateSpark = String.valueOf(((DateTime) Json.deserialize('"' + soleProprietorSpark.dateReg + '"', DateTime.class)).format('dd.MM.yyyy'));
                formParams.ogrnipSpark = soleProprietorSpark.ogrnip;
                formParams.okpoSpark = soleProprietorSpark.okpo;
                formParams.emptySparkOkpo = String.isBlank(formParams.okpoSpark);
                formParams.businessProcess = BUSINESS_PROCESS;
                System.debug('**** RemoteAction SPARK ID: ' + formParams.sparkId + ' SPARK SOLE: ' + formParams.mainCompanyFullNameSpark);

                E2EFormRuService formService = new E2EFormRuServiceImpl();
                formService.updateSoleProprietorInfoFromSpark(formParams, formDataId);
            }
        } else {
            throw new E2EFormRuException('Error: remoteUpdateEntrepreneurShortReport');
        }
    }

    @RemoteAction
    global static CompanyVerificationScoring checkCompany(Boolean isSole, String inn, String sparkId, String opportunityId) {
        ScoringWebService scoringWebService = new ScoringWebServiceImpl();

        // verify company by black lists
        CompanyVerificationScoring verificationDecision;
        if (sparkId != '' && inn != '') {
            verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
            System.debug('**** RemoteAction VERIFICATION DECISION: ' + verificationDecision.decision + ', listType=' + verificationDecision.blackListType);
        } else {
            System.debug('**** RemoteAction SPARK DATA IS EMPTY for inn = ' + inn + ' sparkId = ' + sparkId);
            String notificationMessage = '<br/>E2E RU RemoteAction SPARK DATA IS EMPTY for inn = ' + inn + ' sparkId = ' + sparkId;
            ExceptionLogger.sendException(notificationMessage, '');
        }
        return verificationDecision;
    }

    @RemoteAction
    global static DecisionScoring getScore(String inn, String sparkId, String opportunityId, String verificationDecision) {
        CompanyVerificationScoring verificationScoring;
        if (verificationDecision != '') {
            verificationScoring = (CompanyVerificationScoring) System.JSON.deserialize(verificationDecision, CompanyVerificationScoring.class);
        }

        ScoringWebService scoringWebService = new ScoringWebServiceImpl();

        DecisionScoring decision;
        // do not score the company if it was manual entry or if company is in a black list
        if (verificationScoring != null && verificationScoring.decision != 3) {
            decision = scoringWebService.getScoringDecision(inn, sparkId, (Id) opportunityId);
            System.debug('**** RemoteAction SCORING DECISION: ' + decision.decision);
        }
        return decision;
    }

    @RemoteAction
    global static String getVerification(CompanyVerificationScoring verificationDecision) {
        ScoringWebService scoringWebService = new ScoringWebServiceImpl();
        String verificationString = scoringWebService.prepareBlackListDecisionForSF(verificationDecision.decision);
        return verificationString;
    }

    @RemoteAction
    global static String getDecision(DecisionScoring decisionScoring) {
        ScoringWebService scoringWebService = new ScoringWebServiceImpl();
        String decisionString = scoringWebService.prepareScoringDecisionForSF(decisionScoring.decision);
        return decisionString;
    }

    @RemoteAction
    global static void remoteUpdateCompanySparkInfo(String companySparkInfoJson, String formDataId, String opportunityId, String companyInn) {
        String companySparkInfo = companySparkInfoJson.replace('&quot;', '\\"');
        if (companySparkInfo != null && companySparkInfo != '') {
            CompanySpark companySpark = (CompanySpark) System.JSON.deserialize(companySparkInfo, CompanySpark.class);

            if (companySpark.extendedReport != null) {
                SparkWebService sparkWebService = new SparkWebServiceImpl();
                E2EFormParams formParams = new E2EFormParams();
                ExtendedReportSpark.Leader actualLeader = sparkWebService.getCompanyActualLeader(companySpark.extendedReport.LeaderList.leader);
                formParams.sparkId = companySpark.sparkID;
                formParams.mainCompanyFullNameSpark = companySpark.fullName;
                formParams.registrationDateSpark = String.valueOf(((DateTime) Json.deserialize('"' + companySpark.extendedReport.dateFirstReg + '"', DateTime.class)).format('dd.MM.yyyy'));
                formParams.executiveFio = actualLeader.fio;
                formParams.executivePosition = actualLeader.position;
                formParams.okpoSpark = companySpark.extendedReport.okpo;
                formParams.emptySparkOkpo = String.isBlank(formParams.okpoSpark);
                formParams.ogrnSpark = companySpark.extendedReport.ogrn;
                formParams.kppSpark = companySpark.extendedReport.kpp;
                formParams.companyCountry = 'Россия';
                formParams.postCodeSpark = companySpark.extendedReport.LegalAddresses.address.postCode;
                formParams.regionSpark = companySpark.extendedReport.LegalAddresses.address.region;
                formParams.citySpark = companySpark.extendedReport.LegalAddresses.address.city;
                formParams.streetSpark = companySpark.extendedReport.LegalAddresses.address.streetName;
                formParams.buildingSpark = companySpark.extendedReport.LegalAddresses.address.buildingNumber;
                formParams.housingSpark = companySpark.extendedReport.LegalAddresses.address.housing;
                formParams.blockSpark = companySpark.extendedReport.LegalAddresses.address.block;
                formParams.roomSpark = companySpark.extendedReport.LegalAddresses.address.room;
                formParams.legalAddressSpark = companySpark.extendedReport.LegalAddresses.address.address;
                formParams.normName = companySpark.extendedReport.normName;
                formParams.companyInn = companyInn;
                formParams.companyName = companySpark.extendedReport.shortNameRus;
                formParams.businessProcess = BUSINESS_PROCESS;
                E2EFormRuService formRuService = new E2EFormRuServiceImpl();
                formRuService.updateCompanyInformationFromSpark(formParams, formDataId, opportunityId);
                System.debug('DONE remoteUpdateCompanySparkInfo');
            } else {
                throw new E2EFormRuException('Error: remoteUpdateCompanySparkInfo - inn: ' + companyInn + ', opportunity ID ' + opportunityId);
            }
        } else {
            throw new E2EFormRuException('Error: remoteUpdateCompanySparkInfo - inn: ' + companyInn + ', opportunity ID ' + opportunityId);
        }
    }

    @RemoteAction
    global static String remoteCreateExecutiveEmployee(String formDataId, String leaderListJson) {
        String leaderList = leaderListJson.replace('&quot;', '\\"');
        if (leaderList != null && leaderList != '') {
            ExtendedReportSpark.LeaderList leaders = (ExtendedReportSpark.LeaderList) System.JSON.deserialize(leaderList, ExtendedReportSpark.LeaderList.class);

            if (leaders != null) {
                SparkWebService sparkWebService = new SparkWebServiceImpl();
                ExtendedReportSpark.Leader actualLeader = sparkWebService.getCompanyActualLeader(leaders.leader);

                if (actualLeader != null) {
                    E2EFormRuService formService = new E2EFormRuServiceImpl();
                    E2EFormData__c formData = formService.getFormDataById(formDataId);
                    if (formData != null && formData.E2E_Account_Id__c != null) {
                        Id contactId = formService.createEmployeeContact(formData.E2E_Account_Id__c, actualLeader.fio, actualLeader.position, BUSINESS_PROCESS);
                        sendDataToPDService(contactId);
                        return contactId;
                    }
                }
            }
        }
        return null;
    }

    @RemoteAction
    global static void updateVerifiedDecision(String formDataId, String opportunityId, String inn, String verificationDecision) {
        ScoringWebService scoringWebService = new ScoringWebServiceImpl();
        E2EFormParams formParams;
        CompanyVerificationScoring verificationScoring;
        if (verificationDecision != '') {
            verificationScoring = (CompanyVerificationScoring) System.JSON.deserialize(verificationDecision, CompanyVerificationScoring.class);
        }

        if (verificationScoring != null) {
            formParams = new E2EFormParams();
            formParams.verifiedDecision = scoringWebService.prepareBlackListDecisionForSF(verificationScoring.decision);
            formParams.verifiedDecisionCode = String.valueOf(verificationScoring.decision);
            formParams.verifiedLimitation = String.valueOf(verificationScoring.limitation);
            formParams.businessProcess = BUSINESS_PROCESS;
            E2EFormRuService formService = new E2EFormRuServiceImpl();
            formService.updateVerifiedDecision(formParams, formDataId, opportunityId);
        } else {
            throw new E2EFormRuException('**** Error: updateVerifiedDecision verificationScoring is null');
        }
    }

    @RemoteAction
    global static void updateScoreDecision(String formDataId, String opportunityId, String scoreDecision) {
        ScoringWebService scoringWebService = new ScoringWebServiceImpl();

        DecisionScoring decision;
        if (scoreDecision != null && scoreDecision != '') {
            decision = (DecisionScoring) System.JSON.deserialize(scoreDecision, DecisionScoring.class);
        }

        if (decision != null) {
            E2EFormParams formParams = new E2EFormParams();
            formParams.scoringDecision = scoringWebService.prepareScoringDecisionForSF(decision.decision);
            formParams.scoringDecisionCode = String.valueOf(decision.decision);
            formParams.scoringDate = Date.today();
            formParams.businessProcess = BUSINESS_PROCESS;
            E2EFormRuService formService = new E2EFormRuServiceImpl();
            formService.updateScoringDecision(formParams, formDataId, opportunityId);
        }
    }
}