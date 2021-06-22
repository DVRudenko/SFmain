global class E2EFormRuCtrl {

    public static final String BUSINESS_PROCESS = GlobalUtils.BusinessProcessType.E2EClassic.name();
    public static final String INTEGRATION_ADMIN_RU = 'Integration Administrator RU';
    public E2EFormRuCtrl currentPage {
        get {
            return this;
        }
        set;
    }

    /* URL params */
    public E2EFormParams formParams { get; set; }
    public String country { get; set; }
    public String product { get; set; }
    public Boolean productNotChange { get; set; }
    public String offer { get; set; }

    public Map<String, LongFormTariff> msl_suffix { get; set; }
    public List<LongFormTariff> tariffs { get; set; }
    public String selectedTariff { get; set; }
    public Map<String, String> sparkLegalDetailsData { get; set; }
    public String productID { get; set; }
    public String lastTimeSelectedTariff { get; set; }

    public Id accountId { get; set; }
    public Id opportunityId { get; set; }
    public Id contactId { get; set; }
    public Id formDataId { get; set; }

    public String ipAddress;
    public GlobalUtils.DeviceType deviceType;

    public String activeStep { get; set; }
    public String activeModalWindow { get; set; }
    public String errorStep { get; set; }
    public Boolean sparkCompanyNoDataFound { get; set; }
    public Boolean showBanner { get; set; }

    public E2EFormRuService formService;
    public SparkWebService sparkWebService;
    public ScoringWebService scoringWebService;
    public CrmWebService crmWebService;
    public ReportWebService reportWebService;
    public TransitWebService transitWebService;
    public MZKWebService mzkWebService;
    public Map<String, LongFormPage> pagesContentMap { get; set; }

    // Contract
    public List<String> reportIdList = new List<String>();
    public Boolean isActivateContractPreview = false;
    public Boolean isActivateContract = false;

    public String previewContractContent {
        get {
            return EncodingUtil.Base64Encode(getPreviewContract());
        }
    }

    // FOR REMOTE ACTION
    global static String companyInfoSpark { get; set; }
    global static String soleInfoSpark { get; set; }
    public String blackListDecision { get; set; }
    public String scoringPassed { get; set; }
    global static Boolean scoringRefused { get; set; }
    global Boolean enableManualEntry { get; set; }

    global Boolean enableCaching { get; set; }

    private String getCookie(String cookieName) {
        Cookie ck = ApexPages.currentPage().getCookies().get(cookieName);
        return ck != null ? ck.getValue() : '';
    }

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : page initialization
    *  CreatedDate     : 18/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {
            Long startTime = System.currentTimeMillis();
            System.debug('TIME: init() start:' + startTime);
            System.debug('**** INIT FORM');
            productID = 'PPR_1';
            this.formParams = new E2EFormParams();
            //set business process type as classic E2E
            this.formParams.businessProcess = BUSINESS_PROCESS;
            this.formParams.encodedURL = getCookie('url');
            setClientId();
            setLeadId();
            readUrlParams();
            this.msl_suffix = new Map<String, LongFormTariff>();
            this.tariffs = new List<LongFormTariff>();
            this.sparkLegalDetailsData = new Map<String, String>();

            // init E2EFormParams.sendToInbound param
            // init enableCaching param (SF-776)
            E2E_Form_Ru_General_Settings__c settings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
            if (settings != null) {
                this.formParams.sendToInbound = settings.Send_To_Inbound__c;
                this.enableCaching = settings.Enable_caching__c;
                this.enableManualEntry = settings.Manual_Input__c;
                this.showBanner = settings.Show_Banner__c;
            } else {
                this.formParams.sendToInbound = true;
                this.enableCaching = false;
                this.showBanner = true;
            }

            this.formParams.deviceType = GlobalUtils.DeviceType.Desktop.name();
            this.formParams.ipAddress = LongFormGlobalUtils.getUserIPAddress();
            this.deviceType = GlobalUtils.DeviceType.Desktop;
            this.sparkCompanyNoDataFound = false;
            System.debug('UTM: ' + this.formParams.utmCampaign + ' ' + this.formParams.utmContent + ' ' +
                    this.formParams.utmMedium + ' ' + this.formParams.utmTerm + ' ' + this.formParams.utmSource
                    + ' ' + this.formParams.utmUrl);

            this.formService = returnFormService(this.country);
            this.sparkWebService = returnSparkWebService(this.country);
            this.scoringWebService = returnScoringWebService(this.country);
            this.crmWebService = returnCrmWebService(this.country);
            this.reportWebService = returnReportWebService(this.country);
            this.transitWebService = returnTransitWebService(this.country);
            this.mzkWebService = returnMZKWebService(this.country);
            if (this.activeStep == null) {
                this.activeStep = GlobalUtils.E2ERuSteps.ContactDetails.name();

            }
            pagesContentMap = new Map<String, LongFormPage>();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);

            if (this.formDataId != null && this.activeStep != null) {
                // If the client come by special link
                System.debug('**** come by special link');
                Map<String, String> objectIds = new Map<String, String>();
                formService.collectContentDataByLink(this.formDataId, this.activeStep, this.pagesContentMap, this.formParams, this.msl_suffix, objectIds);
                this.tariffs = this.msl_suffix.values();

                if (this.pagesContentMap.get('ORDER') != null && this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF') != null && this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID') != null) {
                    this.lastTimeSelectedTariff = this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value;
                    this.selectedTariff = this.lastTimeSelectedTariff;
                }

                this.accountId = objectIds.get('accountId');
                this.contactId = objectIds.get('contactId');
                this.opportunityId = objectIds.get('opportunityId');

                // set product and offer
                this.offer = this.formParams.offer;
                this.product = this.formParams.product;

                System.debug('Params by special link: offer ' + this.offer + ' product ' + this.product + ' ' + formParams.source);

                // If the client return by a special link he will become the owner of opportunity again (if a manager has changed it before)
                Opportunity existOpportunity = formService.getOpportunityById(this.opportunityId);
                // If the client return by a special link we check that opportunity has valid stage
                if (existOpportunity.stageName == 'Moved to start' || existOpportunity.stageName == 'Awaiting payment' ||
                        (existOpportunity.stageName == 'Отказ' && existOpportunity.PPR_Lost_Reasons__c == 'Не прошли скоринг') ||
                        ((existOpportunity.stageName == 'Договор на проверке' || existOpportunity.stageName == 'Contract Under Signing' ||
                                existOpportunity.stageName == 'Signing of a Contract') && existOpportunity.E2E_Sales_Type__c == 'Е2Е с участием Inbound')) {
                    throw new E2EFormRuException('Error: Link is deactivated, OpportunityId: ' + this.opportunityId + ' StageName: ' + existOpportunity.stageName);
                }

                // If the client return by a special link he will become the owner of opportunity again (if a manager has changed it before)
                if (existOpportunity != null) {
                    if (this.formService.isRoleInbound(this.opportunityId)) {
                        System.debug('*** inbound role');
                        this.formService.changeObjectOwner(this.opportunityId, INTEGRATION_ADMIN_RU);
                        this.formService.changeObjectOwner(this.accountId, INTEGRATION_ADMIN_RU);
                        this.formService.changeObjectOwner(this.formDataId, INTEGRATION_ADMIN_RU);
                    } else {
                        System.debug('*** not inbound role');
                    }
                }
            }

            formService.collectSharedResource(this.country, pagesContentMap, GlobalUtils.DeviceType.Desktop, this.formParams.source);

            System.debug('formDataId=' + this.formDataId + '; accountId=' + this.accountId + '; contactId=' + this.contactId + '; opportunityId=' + this.opportunityId);
            System.debug('url: ' + URL.getSalesforceBaseUrl().toExternalForm());
            System.debug('TIME: init() end:' + System.currentTimeMillis());

            //SF-555 Lead redirect to 2nd step
            switch on this.formParams.splitWTL {
                when 'A' {
                    Map<String, String> urlParams = ApexPages.CurrentPage().getParameters();
                    if (String.isNotBlank(urlParams.get('cphone')) && String.isNotBlank(urlParams.get('cemail'))) {
                        //kostil for 2nd step redirect. Needed to create it due to double different validation. Sorry...
                        String inputPhone = urlParams.get('cphone');
                        String inputEmail = urlParams.get('cemail');

                        //validate phone
                        String phoneRegEx = '^(8|\\ 7|7|\\+7)(\\d{3})(\\d{7})$';
                        Pattern phonePattern = Pattern.compile(phoneRegEx);
                        Matcher phoneMatcher = phonePattern.matcher(inputPhone);
                        if (phoneMatcher.matches() && LongFormGlobalUtils.validateEmailFormatRu(inputEmail)) {

                            System.debug('HERE!!!' + inputPhone);
                            if (inputPhone.startsWith('+')) {
                                //+7
                                inputPhone = '+7 ' + inputPhone.trim().substring(2);
                            } else {
                                //8
                                inputPhone = '8 ' + inputPhone.trim().substring(1);
                            }
                            this.pagesContentMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value = inputPhone;
                            this.pagesContentMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = inputEmail;
                            goToCompanyDetails();
                            updateContactPhone();
                        } else {
                            //phone number or email is not valid
                            System.debug('HERE!: Phone or email is not valid');
                            System.debug(urlParams.get('cphone'));
                            System.debug(urlParams.get('cemail'));
                            this.formParams.splitWTL = 'B';
                        }
                    } else {
                        //phone number or email is not provided
                        System.debug('HERE!: Phone or email is not provided');
                        this.formParams.splitWTL = 'B';
                    }
                }
            }

        } catch (Exception e) {
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method init(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : readUrlParams()
    *  Summary         : work with url params and set up base parameters
    *  CreatedDate     : 25/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void readUrlParams() {
        Map<String, String> urlParams = ApexPages.CurrentPage().getParameters();
        System.debug('Parameters: ' + urlParams);
        String countryParam = ApexPages.CurrentPage().getParameters().get('country');
        if (countryParam != null && countryParam != '' && countryParam == GlobalUtils.FleetcorCountries.Russia.name()) {
            this.country = countryParam;
        } else {
            this.country = 'Russia';
        }

        String productParam = ApexPages.CurrentPage().getParameters().get('product');
        if (productParam != null && productParam != '') { // заменить значение продукта
            this.formParams.product = productParam;
        }
        this.productNotChange = true;

        // параметр промокода (при его наличии предзаполняем поля и закрываем для редактирования)
        String promoParam = ApexPages.CurrentPage().getParameters().get('promo');
        if (promoParam != null && promoParam != '') {
            this.formParams.promoCode = promoParam;
        } else {
            this.formParams.promoCode = '';
        }

        if (urlParams.get('cphone') != null && urlParams.get('cemail') != null) {
            if (urlParams.get('cphone') != '' && urlParams.get('cemail') != '') {
                this.formParams.sourceIfSelfSourced = 'Web-To-Lead';
            }
        }

        if (urlParams.get('splitWTL') != null) {
            formParams.splitWTL = urlParams.get('splitWTL');
        }

        String sourcePPParam = ApexPages.CurrentPage().getParameters().get('sourcePP');
        if (sourcePPParam != null) {
            this.formParams.sourcePP = sourcePPParam;
        } else {
            this.formParams.sourcePP = '';
        }
        this.formParams.source = 'PetrolPlus';
        //this.formParams.promoCode = '';
        String sourceParam = ApexPages.CurrentPage().getParameters().get('source');

        if (sourceParam != null && sourceParam != '') {

            E2E_Sources__c sourceObject = E2E_Sources__c.getValues(sourceParam);

            if (sourceObject != null) {
                this.offer = sourceObject.Offer__c;
                this.formParams.product = sourceObject.Product__c;
                if (sourceObject.Promo__c != null) {
                    this.formParams.promoCode = sourceObject.Promo__c;
                }
            }

            this.formParams.source = sourceParam;
            this.formParams.sourcePP = sourceParam;
            this.productNotChange = true;
            System.debug('*** PromoCode in formParam DEBUG ' + this.formParams.promoCode);
        }

        if (!String.isNotBlank(this.offer))
            this.offer = 'PetrolPlus';

        this.formParams.offer = this.offer;

        if (this.formParams.product == null || this.formParams.product == '') {
            this.formParams.product = 'PetrolPlus_Rover';
        }

        if (this.formParams.product.equals('PetrolPlus_Gaz')) {
            this.formParams.promoCode = '8Е01';
        }

        if ('e2ecallcenter'.equalsIgnoreCase(this.formParams.sourcePP)) {
            this.formParams.promoCode = '9Е14';
        }

        String splitTesting = ApexPages.CurrentPage().getParameters().get('split');
        if (splitTesting != null && splitTesting != '') {
            E2E_Split_Testing__c splitObject = E2E_Split_Testing__c.getValues(splitTesting);
            if (splitObject != null) {
                this.formParams.splitTesting = splitObject.Name;
                this.formParams.productSplitTesting = splitObject.Target__c;
            } else {
                this.formParams.splitTesting = '';
                this.formParams.productSplitTesting = this.formParams.product;
            }
        } else {
            this.formParams.splitTesting = '';
            this.formParams.productSplitTesting = this.formParams.product;
        }

        System.debug('**** URL PARAMS: country=' + this.country + ', product=' + this.formParams.product + ', source=' + this.offer + ', promo=' + this.formParams.promoCode + ', product=' + this.formParams.product + ', productSplitTesting=' + this.formParams.productSplitTesting);

        String encryptedParams = ApexPages.CurrentPage().getParameters().get('link');
        if (encryptedParams == null || encryptedParams == '') {
            if (this.formParams.encodedURL != null && this.formParams.encodedURL != '') {
                encryptedParams = this.formParams.encodedURL;
                System.debug('*** cookie is ' + encryptedParams);
            } else {
                System.debug('*** cookie is empty');
            }
        } else {
            System.debug('*** link is ' + encryptedParams);
        }
        if (encryptedParams != null && encryptedParams != '') {
            encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
            if (E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu') == null) {
                throw new E2EFormRuException('The link is corrupted. Please contact your administrator');
            }
            Blob key = EncodingUtil.base64Decode(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').AES256_Key__c);
            Blob dest = EncodingUtil.base64Decode(encryptedParams);
            Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
            String decryptedParams = decrypted.toString();
            if (decryptedParams != null) {
                String formDataIdParam = decryptedParams.substringBefore('-');
                String activeStepParam = decryptedParams.substringAfter('-');

                if (formDataIdParam != '' && activeStepParam != '') {
                    this.formDataId = Id.valueOf(formDataIdParam);
                    this.activeStep = activeStepParam;
                } else {
                    throw new E2EFormRuException('The link is corrupted. Please contact your administrator');
                }
                System.debug('**** DECODED URL PARAMS: formDataId=' + this.formDataId + ', activeStep=' + this.activeStep);
            }
        }

        //SF-651
        this.formParams.utmSource = ApexPages.CurrentPage().getParameters().get('utm_source');
        this.formParams.utmCampaign = ApexPages.CurrentPage().getParameters().get('utm_campaign');
        this.formParams.utmTerm = ApexPages.CurrentPage().getParameters().get('utm_term');
        this.formParams.utmContent = ApexPages.CurrentPage().getParameters().get('utm_content');
        this.formParams.utmMedium = ApexPages.currentPage().getParameters().get('utm_medium');
        //SF-973
        this.formParams.utmIp = ApexPages.currentPage().getParameters().get('utm_ip');
        this.formParams.utmRegion = ApexPages.currentPage().getParameters().get('utm_region');
        if (String.isNotBlank(getCookie('website_page_form'))) {
            this.formParams.websitePageForm = getCookie('website_page_form');
        } else {
            this.formParams.websitePageForm = 'https://' + ApexPages.CurrentPage().getHeaders().get('Host') + ApexPages.CurrentPage().getUrl().remove('/apex');
        }
    }

    /*******************************************************************************
    *  Name            : setDeviceType()
    *  Summary         : set Device Type
    *  CreatedDate     : 28/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDeviceType() {
        if (ApexPages.currentPage().getParameters().get('deviceType') == 'Desktop') {
            this.deviceType = GlobalUtils.DeviceType.Desktop;
            this.formParams.deviceType = GlobalUtils.DeviceType.Desktop.name();
        } else {
            this.deviceType = GlobalUtils.DeviceType.Mobile;
            this.formParams.deviceType = GlobalUtils.DeviceType.Mobile.name();

        }
        System.debug('deviceType: ' + this.deviceType);
    }

    /*******************************************************************************
    *  Name            : returnFormService(String countryName)
    *  Summary         : get General Form Service
    *  CreatedDate     : 12/07/2018
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

    /*******************************************************************************
   *  Name            : createSobjects
   *  Summary         : create new sobject records
   *  CreatedDate     : 25/07/2018
   *  ModifiedDate    : -
   *  Parameters      : -
   *  Returns         : -
   ******************************************************************************/
    private void createSObjectsRecords() {
//        if (!Test.isRunningTest()) {
        try {
            system.debug('INIT=' + system.currentTimeMillis());
            doDisabledTriggers();
            if (accountId == null || opportunityId == null || contactId == null || formDataId == null) {
                accountId = this.formService.createAccount(formParams);
                System.debug('***** created accountId=' + accountId + ' ' + system.currentTimeMillis());

                opportunityId = this.formService.createOpportunity(accountId, formParams);
                System.debug('***** created opportunityId=' + opportunityId + ' ' + system.currentTimeMillis());

                contactId = this.formService.createContact(accountId, pagesContentMap, formParams, GlobalUtils.BusinessProcessType.E2EClassic);
                this.formService.updateOpportunityContactRole(opportunityId, contactId, 'Decision Maker', true);
                System.debug('***** created contactId=' + contactId + ' ' + system.currentTimeMillis());

                formDataId = this.formService.createFormDataRecord(accountId, contactId, opportunityId, pagesContentMap, formParams);
                System.debug('***** created formDataId=' + formDataId + ' ' + system.currentTimeMillis());
            } else {
                formService.updateContact(contactId, pagesContentMap, formParams, activeStep);
                System.debug('SOURCE **  ' + this.formParams.source);
                formService.updateFormData(formDataId, pagesContentMap, formParams, activeStep, this.formParams.source);
            }
            system.debug('FINISH=' + system.currentTimeMillis());
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method createSObjectsRecords(): ' + 'formDataId=' + formDataId
                    + 'accountId=' + accountId + 'opportunityId=' + opportunityId + 'contactId=' + contactId
                    + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));

            throw new E2EFormRuException(notificationMessage);
        }
//        }
    }

    /*******************************************************************************
    *  Name            : updateSobjects
    *  Summary         : update sobject records
    *  CreatedDate     : 25/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void updateSObjectsRecords() {
        try {
            System.debug('TIME: updateSObjectsRecords() begin:' + System.currentTimeMillis());
            if (formDataId != null && accountId != null && contactId != null && opportunityId != null) {
                doDisabledTriggers();

                formService.updateFormData(formDataId, pagesContentMap, formParams, activeStep, this.formParams.source);

                formService.updateAccount(accountId, pagesContentMap, formParams, activeStep);

                formService.updateOpportunity(opportunityId, pagesContentMap, formParams, activeStep);

                formService.updateContact(contactId, pagesContentMap, formParams, activeStep);
            }
            System.debug('TIME: updateSObjectsRecords() end:' + System.currentTimeMillis());
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method updateSObjectsRecords(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));

            throw new E2EFormRuException(notificationMessage);
        }
    }

    /*******************************************************************************
    *  Name            : updateContactPhone
    *  Summary         : update contact phone
    *  CreatedDate     : 17/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void updateContactPhone() {
        try {
            deduplicationCurrentClient();
            createSObjectsRecords();
            // this.formService.updateContactPhone(this.contactId, this.pagesContentMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value);
        } catch (Exception e) {
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method updateContactPhone(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
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

        AccountTriggerHandler.isE2EForm = true;
        ContactTriggerHandler.isE2EForm = true;
        OpportunityTriggerHandler.isE2EForm = true;
    }

    /*******************************************************************************
    *  Name            : backToContactDetails
    *  Summary         : back to contact details step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToContactDetails() {
        try {
            this.activeStep = GlobalUtils.E2ERuSteps.ContactDetails.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
        } catch (Exception e) {
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method backToContactDetails(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToCompanyDetails(String countryName)
    *  Summary         : go to company details step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public List<sObject> goToCompanyDetails() {
        System.debug('opportunity ' + opportunityId);
        if (this.formService.isRoleInbound(this.opportunityId)) {
            System.debug('*** inbound role');
            List<sObject> listOwner = new List<sObject>();
            listOwner.add(this.formService.changeObjectOwner(this.opportunityId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.accountId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.formDataId, INTEGRATION_ADMIN_RU, false));
            this.formService.updSObjects('', listOwner);
            return  listOwner;

        }else {
            System.debug('*** not inbound role');
        }
        if (opportunityId != null) {
            System.debug('*** opportunityId ' + opportunityId);
            System.debug('*** current step ' + this.formService.getCurrentStep(opportunityId));
        } else {
            System.debug('*** opportunityId is null');
        }

        if (opportunityId != null && this.formService.getCurrentStep(opportunityId).equals(GlobalUtils.getE2ESteps(GlobalUtils.E2ERuSteps.Congratulations.name()))) {
            System.debug('*** ALREADY FINISH');
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.IsAClient.name();
        } else {
            System.debug('*** GO FURTHER');
            try {
                System.debug('TIME: goToCompanyDetails() begin:' + System.currentTimeMillis());
                this.formParams.contactDetails = GlobalUtils.E2ERuProcessStatus.ContactDetails.name(); // log process
                // Deduplication Lead
                this.formService.duplicateLeadProcess(this.pagesContentMap);
                this.formParams.sfDeduplication1 = ' > ' + GlobalUtils.E2ERuProcessStatus.SFDeduplication1.name(); // log process
                // Deduplication current client
                deduplicationCurrentClient();
                this.formParams.sfDeduplication2 = ' > ' + GlobalUtils.E2ERuProcessStatus.SFDeduplication2.name(); // log process
                setClientId();

                createSObjectsRecords();

                this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
                this.formService.updateEncodedUrl(this.opportunityId, this.formDataId, this.formParams);

                this.activeStep = GlobalUtils.E2ERuSteps.CompanyInformation.name();
                formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
                System.debug('TIME: goToCompanyDetails() end:' + System.currentTimeMillis());
            } catch (Exception e) {
                // force update
                this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
                //VS SF-674
                E2EErrorService.createNewErrorMessage(e, this.opportunityId);

                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
                String notificationMessage = '<br/>E2E method goToCompanyDetails(): ' + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : backToCompanyDetails()
    *  Summary         : back to Company Details step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToCompanyInformation() {
        try {
            // reset overdraft
            this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value = 'FALSE';

            System.debug('TIME: backToCompanyInformation() begin:' + System.currentTimeMillis());
            this.activeStep = GlobalUtils.E2ERuSteps.CompanyInformation.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            System.debug('TIME: backToCompanyInformation() end:' + System.currentTimeMillis());
        } catch (Exception e) {
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method backToCompanyInformation(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToOrderInformation()
    *  Summary         : go to Order Information step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public List<sObject> goToOrderInformation() {
        Long startTime = System.currentTimeMillis();
        System.debug('TIME: goToOrderInformation() start:' + startTime);
        String inn = this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value;
        String phone = this.pagesContentMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value;
        String email = this.pagesContentMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
        String sparkId = '';
        if (this.formService.isRoleInbound(this.opportunityId)) {
            System.debug('*** inbound role');
            List<sObject> listOwner = new List<sObject>();
            listOwner.add(this.formService.changeObjectOwner(this.opportunityId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.accountId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.formDataId, INTEGRATION_ADMIN_RU, false));
            this.formService.updSObjects('', listOwner);
            return  listOwner;
        } else {
            System.debug('*** not inbound role');
        }
        if (opportunityId != null && this.formService.getCurrentStep(opportunityId).equals(GlobalUtils.getE2ESteps(GlobalUtils.E2ERuSteps.Congratulations.name()))) {
            System.debug('*** ALREADY FINISH');
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.IsAClient.name();
        } else {
            try {
                if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value.length() == 10) {
                    formParams.isSoleProprietor = false;
                } else if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value.length() == 12) {
                    formParams.isSoleProprietor = true;
                }

                Boolean isEntryManual = Boolean.valueOf(this.pagesContentMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').value);
                if (isEntryManual) {
                    // if manual entry send to Inbound
                    this.formParams.sendToInbound = true;
                    this.formParams.isManualEntry = true;
                    System.debug('**** goToOrderInformation(): isManualEntry = ' + this.formParams.isManualEntry);
                    System.debug('**** COMPANY WILL BE SEND TO INBOUND: true');
                }

                this.formParams.getSparkData = ' > ' + GlobalUtils.E2ERuProcessStatus.GetSparkData.name(); // log process

                // Deduplication Account
                System.debug('TIME: DUB deduplicationAccountProcess start: ' + System.currentTimeMillis());
                E2EFormRuDeduplicationResult deduplicationResult = this.formService.deduplicationAccountProcess(inn, email, this.accountId, this.contactId, this.opportunityId, this.formDataId);
                System.debug('TIME: DUB deduplicationAccountProcess end: ' + System.currentTimeMillis());
                System.debug('*** deduplicationResult.statusCode; -> ' + deduplicationResult.statusCode);
                System.debug('*** deduplicationResult -> ' + deduplicationResult);
                this.formParams.deduplicationStatus = deduplicationResult.statusCode;
                this.formParams.deduplicationStatusInfo = deduplicationResult.getDedupStatusInformation();
                this.formParams.sfDeduplication3 = ' > ' + GlobalUtils.E2ERuProcessStatus.SFDeduplication3.name(); // log process

                if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
                    // Create new task in CRM System
                    CrmTask crmTask = this.formService.prepareCrmRequest(phone, email, inn, deduplicationResult.sfAccount.Opportunities);
                    this.crmWebService.createTask(inn, crmTask);
                    this.formParams.sendCrmRequest = ' > ' + GlobalUtils.E2ERuProcessStatus.SendCrmRequest.name(); // log process
                }

                System.debug('TIME: DUB transferCustomer start: ' + System.currentTimeMillis());
                this.formService.transferCustomer(deduplicationResult);
                System.debug('TIME: DUB transferCustomer end: ' + System.currentTimeMillis());

                // Account, который был определен как основной в процессе дедуюликации
                System.debug('*** deduplicationResult.e2eAccount.Id =' + deduplicationResult.e2eAccount.Id + ' *** current.e2eAccount.Id =' + this.accountId);
                this.accountId = deduplicationResult.e2eAccount.Id;

                this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
                updateSObjectsRecords();

                // Check deduplication status
                if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
                    System.debug('Go to Service');
                    throw new E2EFormRuException('Deduplication result: Go to Service => ' + this.formParams.deduplicationStatus);
                } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Inbound.name()) {
                    System.debug('Go to Inbound');
                    this.formParams.sendToInbound = true;
                    throw new E2EFormRuException('Deduplication result: Go to Inbound => ' + this.formParams.deduplicationStatus); // Change by Ilya I 15.03 (по просьбе Тани К)
                } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.KO.name()) {
                    System.debug('Go to KO');
                    throw new E2EFormRuException('Deduplication result: Go to KO => ' + this.formParams.deduplicationStatus);
                }

                // Create executive person contact
                if (this.formParams.executiveFio != null && this.formParams.executiveFio != '' &&
                        this.formParams.executivePosition != null && this.formParams.executivePosition != '') {
                    this.formParams.executiveId = this.formService.createEmployeeContact(this.accountId, this.formParams.executiveFio, this.formParams.executivePosition, BUSINESS_PROCESS);
                }

                this.activeStep = GlobalUtils.E2ERuSteps.Order.name();
                formService.collectContent(this.country, this.activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);

                this.formParams.numberOfTariffsDependency = this.getTariffsDependency();
                this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value = this.formParams.product;
                this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('DEFAULT VALUE').value = this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').offers.get(this.offer).products.get(this.formParams.product).productLabel;
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = '';
                this.lastTimeSelectedTariff = this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value;

                System.debug('***** DEBUG .lastTimeSelectedTariff --------->>> ' + this.lastTimeSelectedTariff);
                System.debug('***** DEBUG formParams.promoCode: ' + this.formParams.promoCode);
                getPromocode(this.formParams.promoCode);

                setAZSLocatorLink(this.formParams.product);

                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.promoCode;

                System.debug('*** PromoCode in Content DEBUG ' + this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value);
                this.formParams.companyDetails = ' > ' + GlobalUtils.E2ERuProcessStatus.CompanyDetails.name(); // log process
                System.debug('TIME: goToOrderInformation end: ' + System.currentTimeMillis());
                System.debug('TIME: goToOrderInformation TOTAL:' + (Long) (System.currentTimeMillis() - startTime));

            } catch (Exception e) {
                if (this.formParams.deduplicationStatus != null &&
                        (this.formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.Service.name() || this.formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.KO.name())) {
                    updateSObjectsRecords();
                    this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                    this.errorStep = GlobalUtils.E2ERuErrorSteps.IsAClient.name();
                } else if (this.formParams.deduplicationStatus != null &&
                        this.formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.Inbound.name()) {
                    updateSObjectsRecords();
                    this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                    this.errorStep = GlobalUtils.E2ERuErrorSteps.Inbound.name();
                } else {
                    // force update
                    this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
                    //VS SF-674
                    E2EErrorService.createNewErrorMessage(e, this.opportunityId);

                    this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                    this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
                }

                System.debug('**** EXCEPTION: ' + String.valueOf(e.getMessage()) + '\r\n' + 'STACK TRACE: ' + String.valueOf(e.getStackTraceString()));
                String notificationMessage = '<br/>E2E RU method goToOrderInformation(): inn=' + inn + ', sparkId=' + sparkId + ' ' + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : getTariffsOnCards()
    *  Summary         : get TariffsOnCards
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getTariffsOnCards() {
        String suffix = ApexPages.currentPage().getParameters().get('suffix');
        getTariffs(suffix);
    }

    /*******************************************************************************
    *  Name            : getTariffsDependency()
    *  Summary         : get TariffsDependency
    *  CreatedDate     : 06/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public String getTariffsDependency() {
        if (this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').offers.get(this.offer).products.get(this.formParams.productSplitTesting).tariffs.size() == 1) {
            return '999';
        } else {
            return '5';
        }
    }

    /*******************************************************************************
    *  Name            : getTariffs()
    *  Summary         : get tariff
    *  CreatedDate     : 27/08/2018
    *  ModifiedDate    : 23/10/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getTariffs(String suffix) {
        String production = this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value;
        Map<String, LongFormTariff> msl = this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').offers.get(this.offer).products.get(this.formParams.productSplitTesting).tariffs;
        System.debug('*********  String suffix : ' + suffix);

        this.msl_suffix.clear();

        for (String tariffName : msl.keySet()) {
            if (tariffName.contains(suffix)) {
                LongFormTariff tariff = msl.get(tariffName);
                if (tariff.showTariff != null && tariff.showTariff) {
                    this.msl_suffix.put(tariffName, tariff);
                }
            }
        }

        this.tariffs = this.msl_suffix.values();
        if (!this.tariffs.isEmpty()) {
            this.selectedTariff = this.tariffs[0].tariffName;
        }

        System.debug('*********  Tariffs : ' + this.tariffs);
    }

    /*******************************************************************************
    *  Name            : setTariff()
    *  Summary         : set tariff
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setTariff() {
        this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value = ApexPages.currentPage().getParameters().get('tariffName');
        this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value = ApexPages.currentPage().getParameters().get('tariffID');
        System.debug('tariff: ' + this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value);
    }

    /*******************************************************************************
    *  Name            : setProduct()
    *  Summary         : set product
    *  CreatedDate     : 02/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setProduct() {
        this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value = ApexPages.currentPage().getParameters().get('productID');
        this.formParams.product = ApexPages.currentPage().getParameters().get('productID');
        this.formParams.numberOfTariffsDependency = this.getTariffsDependency();
        setAZSLocatorLink(this.formParams.product);
        System.debug('numberOfTariffsDependency : ' + this.formParams.numberOfTariffsDependency);
        System.debug('product : ' + this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value);
        //System.debug('product : ' + this.productID);
    }

    /*******************************************************************************
    *  Name            : checkPromocode()
    *  Summary         : checkPromocode
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void checkPromocode() {
        String promocode = ApexPages.currentPage().getParameters().get('promocodeName');
        getPromocode(promocode);
    }

    public void getPromocode(String promocode) {
        String productName = this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('DEFAULT VALUE').value;
        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').value = '';
        if (promocode != null && !promocode.equals('')) {
            E2E_Promocodes__c promocodeObject = E2E_Promocodes__c.getValues(promocode);
            if (promocodeObject != null) {
                if (promocodeObject.Product_Name__c != productName) {

                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').value = 'Данная акция действует только при заказе карт ' + promocodeObject.Product_Name__c;
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').value = 'Данная акция действует только при заказе карт ' + promocodeObject.Product_Name__c;
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').value = '';

                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').value = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').value = '';
                   this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').value = '';
                } else {
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').value = promocodeObject.Name;
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').value = promocodeObject.Promocode_Description_Body__c;
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').value = String.format(promocodeObject.Promocode_Classic_Label__c, new List<String>{this.formParams.source });
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').value = promocodeObject.Promocode_Description_Title__c;

                    if (promocodeObject.Promocode_Additional_Field__c == null || promocodeObject.Supplier_Selection__c == 'False') {
                        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = '';
                        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value = '';
                    } else {
                        String dropdownList = promocodeObject.Promocode_Additional_Field__c;
                        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = dropdownList;
                        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value = dropdownList.split(';')[0].split('@')[0];

                        String listPromocodeItems = this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value;
                        Map<String, String> supplies = new Map<String, String>();
                        for (String val : listPromocodeItems.split(';')) {
                            supplies.put(val.split('@')[0], val.split('@')[1]);
                        }
                        String idPromocodeItem = supplies.get(this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value);
                        this.formParams.promocodeIdInTransit = idPromocodeItem;
                    }
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').value = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').value = '';
                    System.debug(this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value);

                    this.formParams.promocodeName = promocodeObject.Name;
                }
            } else {
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').value = 'Промокод недействителен';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').value = 'Промокод недействителен';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').value = '';

                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').value = '';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = '';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value = '';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').value = '';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').value = '';
            }

        }
    }

    /*******************************************************************************
    *  Name            : setPromocodeItem()
    *  Summary         : setPromocodeItem
    *  CreatedDate     : 16/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setPromocodeItem() {
        String namePromocodeItem = ApexPages.currentPage().getParameters().get('promocodeItem');
        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value = namePromocodeItem;
        String listPromocodeItems = this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value;
        Map<String, String> supplies = new Map<String, String>();
        for (String val : listPromocodeItems.split(';')) {
            supplies.put(val.split('@')[0], val.split('@')[1]);
        }
        String idPromocodeItem = supplies.get(namePromocodeItem);
        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD ID').value = idPromocodeItem;
        this.formParams.promocodeIdInTransit = idPromocodeItem;
        System.debug('DEBUG ******' + idPromocodeItem);

    }

    /*******************************************************************************
    *  Name            : setAZSLocatorLink()
    *  Summary         : setAZSLocatorLink
    *  CreatedDate     : 28/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setAZSLocatorLink(String locator) {
        E2E_Form_Ru_General_Settings__c generalSettingsObject = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        String linkLocator = '';
        if (locator.split('_')[1].equals('Rover')) {
            linkLocator = generalSettingsObject.Locator_Rover_url__c;
        }
        if (locator.split('_')[1].equals('Gaz')) {
            linkLocator = generalSettingsObject.Locator_Gaz_url__c;
        }
        if (locator.split('_')[1].equals('Shell')) {
            linkLocator = generalSettingsObject.Locator_Shell_url__c;
        }
        String prevHrefValue;
        Pattern p = Pattern.compile('\"([^\"]*)\"');
        Matcher m = p.matcher(this.pagesContentMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').value);
        while (m.find()) {
            System.debug(m.group(1));
            prevHrefValue = m.group(1);
        }
        this.pagesContentMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').value = this.pagesContentMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').value.replace(prevHrefValue, linkLocator);
    }

    /*******************************************************************************
    *  Name            : backToOrderInformation()
    *  Summary         : back to Order Information step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToOrderInformation() {
        try {
            this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value = 'FALSE';
            System.debug('TIME: backToOrderInformation() begin:' + System.currentTimeMillis());
            this.activeStep = GlobalUtils.E2ERuSteps.Order.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            System.debug('TIME: backToOrderInformation() end:' + System.currentTimeMillis());
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            //VS SF-674
            E2EErrorService.createNewErrorMessage(e, this.opportunityId);

            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method backToOrderInformation(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToOrderSummary()
    *  Summary         : go to Order Summary step
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public List<sObject> goToSummaryOrder() {
        if (this.formService.isRoleInbound(this.opportunityId)) {
            System.debug('*** inbound role');
            List<sObject> listOwner = new List<sObject>();
            listOwner.add(this.formService.changeObjectOwner(this.opportunityId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.accountId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.formDataId, INTEGRATION_ADMIN_RU, false));
            this.formService.updSObjects('', listOwner);
            return  listOwner;
        } else {
            System.debug('*** not inbound role');
        }
        if (opportunityId != null && this.formService.getCurrentStep(opportunityId).equals(GlobalUtils.getE2ESteps(GlobalUtils.E2ERuSteps.Congratulations.name()))) {
            System.debug('*** ALREADY FINISH');
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.IsAClient.name();
        } else {
            try {
                System.debug('*******************goToSummaryOrder');
                setAZSLocatorLink(this.formParams.product);
                this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
                updateSObjectsRecords();
                this.activeStep = GlobalUtils.E2ERuSteps.SummaryOrder.name();
                formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);

                // check pay overdraft conditions
                if (this.formParams.verifiedDecisionCode == '0' && this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value == 'TRUE') {
                    this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value = 'TRUE';
                } else {
                    this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value = 'FALSE';
                }

                if (this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value == 'TRUE') {
                    this.pagesContentMap.get('ORDER').fields.get('PAYMENT CONDITIONS').elementItemsMap.get('DEFAULT VALUE').value = 'Предоплата с возможностью платного овердрафта';
                } else {
                    this.pagesContentMap.get('ORDER').fields.get('PAYMENT CONDITIONS').elementItemsMap.get('DEFAULT VALUE').value = 'Предоплата 100%';
                }

                Integer numberOfCards = Integer.valueOf(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Number_of_Cards__c);
                this.formParams.numberOfCardsEntered = Integer.valueOf(this.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value);
                if (this.formParams.numberOfCardsEntered > numberOfCards) {
                    this.formParams.sendToInbound = true;
                    this.formParams.isNumberOfCardsLimit = true;
                }

                System.debug('Summary order: numberOfCardsEntered = ' + this.formParams.numberOfCardsEntered);
                System.debug('Summary order: isNumberOfCardsLimit = ' + this.formParams.isNumberOfCardsLimit);
                System.debug('************ this.formParams.sendToInbound: ' + this.formParams.sendToInbound);
            } catch (Exception e) {
                // force update
                this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
                //VS SF-674
                E2EErrorService.createNewErrorMessage(e, this.opportunityId);

                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
                String notificationMessage = '<br/>E2E method goToOrderSummary(): ' + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : goBackToSummaryOrder()
    *  Summary         : back to Order Information step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToSummaryOrder() {
        try {
            System.debug('TIME: backToSummaryOrder() begin:' + System.currentTimeMillis());
            this.activeStep = GlobalUtils.E2ERuSteps.SummaryOrder.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            System.debug('TIME: backToSummaryOrder() end:' + System.currentTimeMillis());
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            //VS SF-674
            E2EErrorService.createNewErrorMessage(e, this.opportunityId);

            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            String notificationMessage = '<br/>E2E method goBackToSummaryOrder(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToLegalDetails()
    *  Summary         : go to Legal Details step 4.1
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public List<sObject> goToLegalDetails() {
        if (this.formService.isRoleInbound(this.opportunityId)) {
            System.debug('*** inbound role');
            List<sObject> listOwner = new List<sObject>();
            listOwner.add(this.formService.changeObjectOwner(this.opportunityId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.accountId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.formDataId, INTEGRATION_ADMIN_RU, false));
            this.formService.updSObjects('', listOwner);
            return  listOwner;
        } else {
            System.debug('*** not inbound role');
        }
        if (opportunityId != null && this.formService.getCurrentStep(opportunityId).equals(GlobalUtils.getE2ESteps(GlobalUtils.E2ERuSteps.Congratulations.name()))) {
            System.debug('*** ALREADY FINISH');
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.IsAClient.name();
        } else {
            try {
                System.debug('************ this.formParams.sendToInbound: ' + this.formParams.sendToInbound);
                System.debug('scoringDecisionCode: ' + this.formParams.scoringDecisionCode);
                System.debug('verifiedDecisionCode: ' + this.formParams.verifiedDecisionCode);

                System.debug('TIME: goToLegalDetails() begin: ' + System.currentTimeMillis());
                this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
                updateSObjectsRecords();

                if (this.formParams.verifiedDecisionCode == '3' || this.formParams.scoringDecisionCode == '2') {
                    System.debug('scoringDecisionCode: ' + this.formParams.scoringDecisionCode);
                    System.debug('verifiedDecisionCode: ' + this.formParams.verifiedDecisionCode);
                    this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                    this.errorStep = GlobalUtils.E2ERuErrorSteps.RefuseToCooperate.name();
                    updateSObjectsRecords();
                } else if (this.formParams.verifiedDecisionCode == '1' || this.formParams.verifiedDecisionCode == '4') {
                    System.debug('verifiedDecisionCode: ' + this.formParams.verifiedDecisionCode);
                    this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                    this.errorStep = GlobalUtils.E2ERuErrorSteps.Inbound.name();
                    updateSObjectsRecords();

                    //Send email notifications
                    E2E_RU_Internal_Notifications.goToLegalDetails(this.formParams, this.opportunityId);

                } else {
                    this.activeStep = GlobalUtils.E2ERuSteps.LegalDetails.name();
                    formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
                    this.formService.collectDataFromSpark(this.formDataId, this.accountId, this.formParams);

                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').value = this.formParams.citySpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').value = this.formParams.postCodeSpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').value = this.formParams.regionSpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').value = this.formParams.streetSpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value = formParams.billingApartment;

                    if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value.length() == 10) {
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.ogrnSpark;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.okpoSpark;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.kppSpark;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.executiveFio;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.legalAddressSpark;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.legalAddressAdditionally;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.postalAddress;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.postalAddressAdditionally;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.executivePosition;
                    } else if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value.length() == 12) {
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.ogrnipSpark;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.okpoSpark;
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = '';
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value = '';
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = '';
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value = '';
                    }

                    if (this.sparkCompanyNoDataFound == true) {
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('REWRITE DEFAULT SPARK VALUES').elementItemsMap.get('DEFAULT VALUE').value = 'TRUE';
                    } else {
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('REWRITE DEFAULT SPARK VALUES').elementItemsMap.get('DEFAULT VALUE').value = 'FALSE';
                    }

                    this.formParams.cardOrderDetails = ' > ' + GlobalUtils.E2ERuProcessStatus.CardOrderDetails.name(); // log process
                    System.debug('TIME: goToLegalDetails() end: ' + System.currentTimeMillis());
                }

            } catch (Exception e) {
                // force update
                this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
                //VS SF-674
                E2EErrorService.createNewErrorMessage(e, this.opportunityId);

                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
                String notificationMessage = '<br/>E2E method goToLegalDetails(): ' + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : returnDataSpark()
    *  Summary         : return Data Spark
    *  CreatedDate     : 21/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void returnDataSpark() {
        if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value.length() == 10) {
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.ogrnSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.kppSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.okpoSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.legalAddressSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value = '';

            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').value = this.formParams.citySpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').value = this.formParams.postCodeSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').value = this.formParams.regionSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').value = this.formParams.streetSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value = formParams.billingApartment;

        } else {
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.ogrnipSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = this.formParams.okpoSpark;
        }
    }

    /*******************************************************************************
    *  Name            : backToLegalDetails()
    *  Summary         : back to Legal Details step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToLegalDetails() {
        try {
            System.debug('TIME: backToLegalDetails() begin: ' + System.currentTimeMillis());
            this.activeStep = GlobalUtils.E2ERuSteps.LegalDetails.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            System.debug('TIME: backToLegalDetails() end: ' + System.currentTimeMillis());
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            //VS SF-674
            E2EErrorService.createNewErrorMessage(e, this.opportunityId);

            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            String notificationMessage = '<br/>E2E method backToLegalDetails(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToPaymentDetails()
    *  Summary         : go to Payment Details step 4.2
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public List<sObject> goToPaymentDetails() {
        if (this.formService.isRoleInbound(this.opportunityId)) {
            System.debug('*** inbound role');
            List<sObject> listOwner = new List<sObject>();
            listOwner.add(this.formService.changeObjectOwner(this.opportunityId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.accountId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.formDataId, INTEGRATION_ADMIN_RU, false));
            this.formService.updSObjects('', listOwner);
            return listOwner;
        } else {
            System.debug('*** not inbound role');
        }
        if (opportunityId != null && this.formService.getCurrentStep(opportunityId).equals(GlobalUtils.getE2ESteps(GlobalUtils.E2ERuSteps.Congratulations.name()))) {
            System.debug('*** ALREADY FINISH');
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.IsAClient.name();
        } else {
            try {
                System.debug('TIME: goToPaymentDetails() begin: ' + System.currentTimeMillis());
                this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
                this.formService.updateProfileEmailForContact(
                        this.contactId,
                        this.formDataId,
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value
                );
                this.formParams.personalOfficePhone = this.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT PHONE').elementItemsMap.get('DEFAULT VALUE').value;
                this.formParams.emailForPersonalOffice = this.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value;
                updateSObjectsRecords();

                if (Boolean.valueOf(this.pagesContentMap.get('LEGAL DETAILS').fields.get('REWRITE DEFAULT SPARK VALUES').elementItemsMap.get('DEFAULT VALUE').value) == true) {
                    this.formParams.sendToInbound = true;
                    this.formParams.isManualEntry = true;
                    System.debug('Legal Details: ' + this.formParams.sendToInbound);
                    System.debug('Legal Details: isManualEntry = ' + this.formParams.isManualEntry);
                }

                if (this.formParams.isSoleProprietor != true && this.formParams.executiveId != null && this.formParams.executiveId != '') {
                    // Update execute person
                    this.formService.updateEmployeeContact(
                            this.formParams.executiveId,
                            this.pagesContentMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').value,
                            this.pagesContentMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').value,
                            BUSINESS_PROCESS
                    );
                    // Update OpportunityContactRole for execute person
                    this.formService.updateOpportunityContactRole(this.opportunityId, this.formParams.executiveId, 'Decision Maker', false);
                }

                this.activeStep = GlobalUtils.E2ERuSteps.PaymentDetails.name();
                formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
                this.pagesContentMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').value = String.valueOf(Integer.valueOf(this.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value) * 2000);
                this.formParams.legalDetails = ' > ' + GlobalUtils.E2ERuProcessStatus.LegalDetails.name(); // log process
                System.debug('TIME: goToPaymentDetails() end: ' + System.currentTimeMillis());
            } catch (Exception e) {
                // force update
                this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
                //VS SF-674
                E2EErrorService.createNewErrorMessage(e, this.opportunityId);

                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
                String notificationMessage = '<br/>E2E method goToPaymentDetails(): ' + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : goToCongratulations()
    *  Summary         : go to Congratulations step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public List<sObject> goToCongratulations() {
        if (this.formService.isRoleInbound(this.opportunityId)) {
            System.debug('*** inbound role');
            List<sObject> listOwner = new List<sObject>();
            listOwner.add(this.formService.changeObjectOwner(this.opportunityId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.accountId, INTEGRATION_ADMIN_RU, false));
            listOwner.add(this.formService.changeObjectOwner(this.formDataId, INTEGRATION_ADMIN_RU, false));
            this.formService.updSObjects('', listOwner);
            return listOwner;
        } else {
            System.debug('*** not inbound role');
        }
        if (opportunityId != null && this.formService.getCurrentStep(opportunityId).equals(GlobalUtils.getE2ESteps(GlobalUtils.E2ERuSteps.Congratulations.name()))) {
            System.debug('*** ALREADY FINISH');
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.IsAClient.name();
        } else {
            try {
                // Update with step PaymentDetails
                if (formParams.isBankInformationInvalid) {
                    formParams.sendToInbound = true;
                    formParams.isManualEntry = true;
                }

                this.formParams.paymentDetails = ' > ' + GlobalUtils.E2ERuProcessStatus.PaymentDetails.name();
                updateSObjectsRecords();

                // ASYNC : Generate Contract , Create Transit Cont, Create MZK proposal (Depending of formParams.sendToInbound)
                system.enqueueJob(new E2EAsyncSenderRequests(this.formDataId, this.formParams, this.pagesContentMap, GlobalUtils.BusinessProcessType.E2EClassic));

                if (this.formParams.sendToInbound == false) {
                    System.debug('******* GO TO CONGRATULATIONS *******');
                    this.activeModalWindow = null;
                    this.activeStep = GlobalUtils.E2ERuSteps.Congratulations.name();
                    updateSObjectsRecords();

                    formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
                    this.pagesContentMap.get('CONGRATULATIONS').fields.get('ORDER NUMBER BLOCK').elementItemsMap.get('VALUE').value = this.formParams.formDataName;
                } else {
                    System.debug('******* GO TO INBOUND *******');
                    this.activeModalWindow = null;
                    this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                    this.errorStep = GlobalUtils.E2ERuErrorSteps.Inbound.name();

                    // Send emails notifications
                    E2E_RU_Internal_Notifications.goToCongratulations(this.formParams, this.opportunityId);
                }
            } catch (Exception e) {
                // force update
                this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
                //VS SF-674
                E2EErrorService.createNewErrorMessage(e, this.opportunityId);

                this.activeModalWindow = null;
                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
                String notificationMessage = '<br/>E2E method goToCongratulations(): ' + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : sendExceptionEmail(String methodName, Exception excpt)
    *  Summary         : send exception email
    *  CreatedDate     : 28/05/2018
    *  ModifiedDate    : -
    *  Parameters      : String methodName, Exception excpt
    *  Returns         : void
    ******************************************************************************/
    public void sendExceptionEmail(String methodName, Exception excpt) {
        try {
            String notificationMessage = '<br/>E2E method ' + methodName + ': ' + String.valueOf(excpt.getMessage());
            if (this.accountId != null) {
                notificationMessage += '<br/>Account Id: ' + this.accountId;
            }
            if (this.contactId != null) {
                notificationMessage += '<br/>Contact Id: ' + this.contactId;
            }
            if (this.opportunityId != null) {
                notificationMessage += '<br/>Opportunity Id: ' + this.opportunityId;

                Opportunity opportunity = formService.getOpportunityById(opportunityId);
                opportunity.E2E_Errors__c = (opportunity.E2E_Errors__c != null ? opportunity.E2E_Errors__c + '\n' + String.valueOf(excpt.getMessage()) : String.valueOf(excpt.getMessage()));
                update opportunity;
                //VS SF-674
                E2EErrorService.createNewErrorMessage(excpt, opportunity.Id);
            }
            ExceptionLogger.sendException(notificationMessage, String.valueOf(excpt.getStackTraceString()));
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method sendExceptionEmail(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : printAgreement()
    *  Summary         : opens modal window to print Agreement
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void printAgreement() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.PrintAgreement.name();
    }

    /*******************************************************************************
    *  Name            : closeModal()
    *  Summary         : closes modal window
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void closeModal() {
        this.activeModalWindow = null;
    }

    /*******************************************************************************
    *  Name            : showPreAgreement()
    *  Summary         : opens modal window to show PreAgreement
    *  CreatedDate     : 30/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void showPreAgreement() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.ShowPreAgreement.name();
    }

    /*******************************************************************************
    *  Name            : showPersonalInfoPolicy()
    *  Summary         : opens modal window to show Personal Information Processing Policies
    *  CreatedDate     : 30/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void showPersonalInfoPolicy() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.PersonalInfoPolicy.name();
    }

    /*******************************************************************************
    *  Name            : showSalesPromotion()
    *  Summary         : opens modal window to show Sales Promotion Policies
    *  CreatedDate     : 30/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void showSalesPromotion() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.SalesPromotion.name();
    }

    /*******************************************************************************
    *  Name            : showWarningBeforeGoToCongratulations()
    *  Summary         : opens modal window to warn that user goes to final step
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void showWarningBeforeGoToCongratulations() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.WarningStepBankDetails.name();
    }

    /*******************************************************************************
    *  Name            : activateContract()
    *  Summary         : set true to isActivateContract
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void activateViewContract() {
        this.isActivateContract = true;
    }

    /*******************************************************************************
    *  Name            : activateDraftContract()
    *  Summary         : set true to isActivateContractDraft
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void activatePreviewContract() {
        this.isActivateContractPreview = true;
    }

    /*******************************************************************************
    *  Name            : deduplicationCurrentClient()
    *  Summary         : check client by E2E name and phone
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void deduplicationCurrentClient() {
        Map<String, String> deduplicationResult = this.formService.deduplicateE2EClient('E2E', this.pagesContentMap);
        if (deduplicationResult.containsKey('statusCode') && deduplicationResult.get('statusCode') == GlobalUtils.DeduplicationStatus.E2EProcess.name()) {
            this.accountId = deduplicationResult.get('accountId');
            this.opportunityId = deduplicationResult.get('opportunityId');
            this.contactId = deduplicationResult.get('contactId');
            this.formDataId = deduplicationResult.get('formDataId');
        }
    }

    /*******************************************************************************
    *  Name            : getEncodedUrl()
    *  Summary         : return encoded url
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : String
    ******************************************************************************/
    private String getEncodedUrl(Id formDataId, String nextStep) {
        Blob key256AES = EncodingUtil.base64Decode(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').AES256_Key__c);
        if (key256AES == null) {
            throw new E2EFormRuException('E2EFormRuCtrl.getEncodedUrl: does not found key for encrypt');
        }

        String stringToEncode = formDataId + '-' + nextStep;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        return encodedStringUrl;
    }

    /*******************************************************************************
    *  Name            : getDraftContract()
    *  Summary         : return draft contract blob
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : Blob
    ******************************************************************************/
    private Blob getPreviewContract() {
        System.debug('TIME: getPreviewContract() start: ' + System.currentTimeMillis());
        Blob body = Blob.valueOf('');
        if (this.isActivateContractPreview == true) {
            this.isActivateContractPreview = false;
            try {
                List<String> reportIds = getReportIdsForContract(true);
                System.debug('******* DRAFT REPORT IDS: ' + reportIds);
                body = getContractContent(reportIds);
                this.formParams.getReport = ' > ' + GlobalUtils.E2ERuProcessStatus.GetReport.name(); // log process
            } catch (Exception e) {
                String notificationMessage = '<br/>E2E  method getDraftAgreement: ' + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
            }
        }
        System.debug('TIME: getPreviewContract() end: ' + System.currentTimeMillis());
        return body;
    }

    private void requestToGenerateContract() {
        List<String> reportIds = getReportIdsForContract(false);
        this.formParams.saveReport = ' > ' + GlobalUtils.E2ERuProcessStatus.SaveReport.name(); // log process
        System.debug('******* REPORT IDS: ' + reportIds);
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
        System.debug('TIME: getReportIdsForContract start: ' + System.currentTimeMillis());
        ReportRequestData requestData = this.formService.prepareReportRequestData(this.formDataId, this.formParams, this.pagesContentMap, isDraft, GlobalUtils.BusinessProcessType.E2EClassic);
        System.debug('********* REPORT REQUEST DATA: ' + requestData);
        ReportResponseData response = this.reportWebService.getReportIdsFromCreditFactory(requestData);

        if (!isDraft) {
            this.formParams.contractPrefix = response.reportParams.SALESFORCE_CONTRACT_PREFIX;
            this.formParams.contractCounter = response.reportParams.SALESFORCE_CONTRACT_COUNTER;
            this.formParams.invoicePrefix = response.reportParams.SALESFORCE_INVOICE_PREFIX;
            this.formParams.invoiceCounter = response.reportParams.SALESFORCE_INVOICE_COUNTER;
        }
        System.debug('TIME: getReportIdsForContract start: ' + System.currentTimeMillis());
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
        System.debug('TIME: getReportsFromReportService start: ' + System.currentTimeMillis());
        if (reportIds != null && !reportIds.isEmpty()) {
            Blob body = this.reportWebService.getReportsFromReportService(reportIds);
            System.debug('TIME: getReportsFromReportService end: ' + System.currentTimeMillis());
            return body;
        } else {
            throw new E2EFormRuException('<br/>E2E  method getAgreementContent (reportIds is empty)');
        }
    }

    public void createTransitCont() {
        System.debug('TIME: prepareTransitRequestData end: ' + System.currentTimeMillis());
        TransitRequestData transitRequestData = this.formService.prepareTransitRequestData(this.formDataId, this.formParams, this.pagesContentMap, GlobalUtils.BusinessProcessType.E2EClassic);
        System.debug('TIME: prepareTransitRequestData end: ' + System.currentTimeMillis());
        System.debug('TIME: transitWebService.storeContData end: ' + System.currentTimeMillis());
        TransitResponseData response;
        if (!Test.isRunningTest()) {
            response = this.transitWebService.storeContData(transitRequestData);
        } else {
            response = new TransitResponseData();
            response.createdId = '1234567890QWERTYUIOPASDFGHJKLZXC';
        }
        System.debug('TIME: transitWebService.storeContData end: ' + System.currentTimeMillis());
        this.formParams.transitContId = response.createdId;
        this.formParams.createContInTransit = ' > ' + GlobalUtils.E2ERuProcessStatus.CreateContInTransit.name(); // log process
        System.debug('this.formParams.transitContId: ' + this.formParams.transitContId);
    }

    public void createMzkProposal() {
        System.debug('TIME: prepareMzkRequest start: ' + System.currentTimeMillis());
        MZKRequest request = this.formService.prepareMzkRequest(this.formDataId, this.formParams);
        System.debug('TIME: prepareMzkRequest end: ' + System.currentTimeMillis());
        System.debug('TIME: mzkWebService.getRequestNumber start: ' + System.currentTimeMillis());
        if (!Test.isRunningTest()) this.formParams.requestNumMZK = this.mzkWebService.getRequestNumber(request);
        System.debug('MZK number: ' + this.formParams.requestNumMZK);
    }

    /*******************************************************************************
     *  Name            : setClientId()
     *  Summary         : set ClientId by Google analytics from URL or Cookie
     *  CreatedDate     : 18/02/2021
     *  ModifiedDate    : 12/03/2021
     *  Parameters      : -
     *  Returns         : void
     ******************************************************************************/
    public void setClientId() {
        String ga = getCookie('clientId');
        String clientId = Apexpages.currentPage().getParameters().get('clientId');
        if (String.isNotBlank(clientId)) {
            this.formParams.clientId = clientId;
        } else if (String.isNotBlank(ga)) {
            this.formParams.clientId = ga;
        }
    }

    private void setLeadId() {
        String leadId = Apexpages.currentPage().getParameters().get('leadId');
        if (String.isNotBlank(leadId)) {
            this.formParams.leadId = leadId;
        }
    }

    @RemoteAction
    global static CompanySpark remoteGetCompanySparkInfoByInn(String inn) {
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
            String notificationMessage = '<br/>E2E Remote Action getCompanyListByInn(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
        return companySpark;
    }

    @RemoteAction
    global static void remoteUpdateCompanySparkInfo(String companySparkInfoJson, String formDataId, String opportunityId, String companyInn) {
        String companySparkInfo = companySparkInfoJson.replace('&quot;', '\\"');
        System.debug('companySparkInfo: ' + companySparkInfo);
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
                formParams.businessProcess = BUSINESS_PROCESS;

                E2EFormRuService formRuService = new E2EFormRuServiceImpl();
                formRuService.updateCompanyInformationFromSpark(formParams, formDataId, opportunityId);
            } else {
                throw new E2EFormRuException('Error: remoteUpdateCompanySparkInfo');
            }
        } else {
            throw new E2EFormRuException('Error: remoteUpdateCompanySparkInfo');
        }
    }

    @RemoteAction
    global static SoleProprietorSpark remoteGetEntrepreneurShortReportByInn(String inn) {
        SparkWebService sparkWebService = new SparkWebServiceImpl();
        E2EFormParams formParams = new E2EFormParams();

        // get sole proprietor information from spark
        SoleProprietorSpark soleProprietorInfo;
        try {
            soleProprietorInfo = sparkWebService.getEntrepreneurShortReportByInn(inn);
            System.debug('**** RemoteAction SOLE INFO SPARK: ' + soleProprietorInfo);
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E Remote Action getEntrepreneurShortReportByInn(): ' + String.valueOf(e.getMessage());
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
                formParams.soleProprietorFio = soleProprietorSpark.fullNameRus;
                formParams.mainCompanyFullNameSpark = 'ИП ' + soleProprietorSpark.fullNameRus;
                formParams.registrationDateSpark = String.valueOf(((DateTime) Json.deserialize('"' + soleProprietorSpark.dateReg + '"', DateTime.class)).format('dd.MM.yyyy'));
                formParams.ogrnipSpark = soleProprietorSpark.ogrnip;
                formParams.okpoSpark = soleProprietorSpark.okpo;
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
        System.debug('inn' + inn);
        System.debug('sparkId' + sparkId);

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
    global static DecisionScoring getScore(Boolean isManualEntry, String inn, String sparkId, String opportunityId, String verificationDecision) {
        CompanyVerificationScoring verificationScoring;
        if (verificationDecision != '') {
            verificationScoring = (CompanyVerificationScoring) System.JSON.deserialize(verificationDecision, CompanyVerificationScoring.class);
        }

        ScoringWebService scoringWebService = new ScoringWebServiceImpl();

        DecisionScoring decision;
        // do not score the company if it was manual entry or if company is in a black list
        if (!isManualEntry && verificationScoring != null && verificationScoring.decision != 3) {
            if (!Test.isRunningTest()) {
                decision = scoringWebService.getScoringDecision(inn, sparkId, (Id) opportunityId);
            } else {
                decision = new DecisionScoring();
                decision.decision = 0;
            }
            System.debug('**** RemoteAction SCORING DECISION: ' + decision.decision);
        }
        return decision;
    }

    @RemoteAction
    global static void updateScoreDecision(String formDataId, String opportunityId, String scoreDecision) {
        System.debug('Ты здесь, я тебя вижу ' + scoreDecision);
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
                        return formService.createEmployeeContact(formData.E2E_Account_Id__c, actualLeader.fio, actualLeader.position, BUSINESS_PROCESS);
                    }
                }
            }
        }
        return null;
    }
}
