public without sharing class PPR_API_ServiceImpl implements PPR_API_Service {

    private E2EFormRuService formRuService = new E2EFormRuServiceImpl();
    private E2EFormRuDao formRuDao = new E2EFormRuDaoImpl();
    private PPR_API_ServiceImplHelper serviceHelper = new PPR_API_ServiceImplHelper();
    private Integer businessDataRelevance;
    public String validationName;
    public Set<String> tariffs {get {
		if (tariffs == null) {
			tariffs = new Set<String>();
			for (LongForm_Tariff__c tariff: [SELECT Id, Name FROM LongForm_Tariff__c]) {
                tariffs.add(tariff.Name.toLowerCase());
            }	
        }
        return tariffs;
    } set;}
    public Set<String> products {get {
		if (products == null) {
			products = new Set<String>();
			for (LongForm_Fleetcor_Product__c product: [SELECT Id, Name FROM LongForm_Fleetcor_Product__c]) {
                products.add(product.Name.toLowerCase());
            }	
        }
        return products;
	} set;}


    /*****************************************************************************
    *  Name            : checkINN(Map<String, String> params)
    *  Summary         : checks company for duplicates in SF and in credit factory
    *  CreatedDate     : 05/02/2020
    *  Parameters      : Map<String, String> params - query params
    *  Returns         : E2EFormParams - collected data
    ******************************************************************************/
    public E2EFormParams checkINN(Map<String, String> params) {
        E2EFormParams formParams = new E2EFormParams();
        try {
            formParams.companyInn = params.get('inn');
            formParams.externalUser = params.get('user');
            formParams.source = params.get('source');
            PPR_API_Settings__c settings = PPR_API_Settings__c.getValues(formParams.source);
            this.businessDataRelevance = Integer.valueOf(settings.Business_data_relevance__c);
            if (GlobalUtils.checkINN(formParams.companyInn) == false) {
                throw new GlobalException('Bad request. INN is not correct.');
            } else {
                formParams.processStatus = 'New';
                // get log object with related form data by INN from LogService
                Custom_log__c log = PPR_API_LogService.getLogByInnAndSource(formParams.companyInn, formParams.source);
                E2EFormData__c formData = null;
                if (log != null && log.E2E_Form_Ru_Data__c != null) {
                    formData = log.E2E_Form_Ru_Data__r;
                    formParams.formDataId = formData.Id;
                }
                // deduplication
                processDuplicatesCheck(formParams, formData);
                // check deduplication results
                if (formParams.deduplicationStatus.equals(GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name())) {
                    //Credit factory here
                    processCreditCheck(formParams, formData);
                    if (isBlackList(formParams)) formParams.processStatus = 'BlackList';
                } else {
                    formParams.processStatus = 'Double';
                }
                // save/update form data here
                if (formParams.formDataId == null) {
                    formData = new E2EFormData__c();
                    insert formData;
                    formParams.formDataId = formData.Id;
                }
                this.formRuService.updateFormData(formParams);
            }
        } catch (Exception e) {
            formParams.processStatus = 'Failed';
            formParams.errors = e.getMessage();
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
            System.debug('************ EXCEPTION *************');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            return formParams;
        } finally {
            // save Log record here
            PPR_API_LogService.createLog(formParams);
        }
        return formParams;
    }

    /*****************************************************************************
    *  Name            : processCheckINN(Map<String, String> params)
    *  Summary         : returns response body after inn check
    *  CreatedDate     : 13/02/2020
    *  Parameters      : Map<String, String> params - query params
    *  Returns         : PPR_API_ResponseBody - response body
    ******************************************************************************/
    public PPR_API_ResponseBody processCheckINN(Map<String, String> params) {
        E2EFormParams formParams = checkINN(params);
        if (formParams == null) {
            return ResponseBodyBuilder.constructPPR_API_responseBodyShort(
                    params.get('inn'),
                    params.get('source')
            );
        } else {
            return ResponseBodyBuilder.constructPPR_API_responseBody(formParams);
        }
    }


    /*****************************************************************************
    *  Name            : processCreditCheck(E2EFormParams formParams, E2EFormData__c formData)
    *  Summary         : checks company in credit factory
    *  CreatedDate     : 05/02/2020
    *  Parameters      : E2EFormParams formParams, E2EFormData__c formData - existing form data, if any
    *  Returns         : -
    ******************************************************************************/
    public void processCreditCheck(E2EFormParams formParams, E2EFormData__c formData) {
        if (formData != null) {
            if (formData.E2E_Scoring_Date__c != null && Date.today() <= formData.E2E_Scoring_Date__c.addDays(this.businessDataRelevance)) {
                if (String.isNotEmpty(formData.E2E_Black_List_Code__c) && String.isNotEmpty(formData.E2E_Scoring_Decision_Code__c)) {
                    formParams.verifiedDecisionCode = formData.E2E_Black_List_Code__c;
                    formParams.scoringDecisionCode = formData.E2E_Scoring_Decision_Code__c;
                    formParams.scoringDate = formData.E2E_Scoring_Date__c;
                    return;
                }
            }
        }
        // do credit check if no data
        CFServiceRuImpl cfService = new CFServiceRuImpl();
        formParams.isSoleProprietor = GlobalUtils.isSoleProprietor(formParams.companyInn);
        if (formParams.isSoleProprietor == null) {
            throw new GlobalException('Bad request. INN is not correct.');
        } else {
            formParams.sparkId = null;
            if (formParams.isSoleProprietor) {
                //if sole proprietor
                // get sole proprietor information from spark, check black list
                if (cfService.getSoleProprietorSparkData(formParams)) {
                    cfService.getBlackListDecisionData(formParams, false);
                    formParams.scoringDate = Date.today();
                }
            } else {
                //if company
                // get company information from spark, check black list and score
                if (cfService.getCompanySparkShortData(formParams)) {
                    if (cfService.getBlackListDecisionData(formParams, false)) {
                        cfService.getScoringDecisionData(formParams);
                    }
                }
            }
            if (formParams.sparkId == null) throw new GlobalException('Organization is not found in spark');
        }
    }

    private Boolean isBlackList(E2EFormParams formParams) {
        return formParams.verifiedDecisionCode.equals('3') || formParams.scoringDecisionCode.equals('2');
    }

    /*****************************************************************************
    *  Name            : processDuplicatesCheck(E2EFormParams formParams, E2EFormData__c formData)
    *  Summary         : checks company for duplicates in SF
    *  CreatedDate     : 05/02/2020
    *  Parameters      : E2EFormParams formParams, E2EFormData__c formData - existing form data, if any
    *  Returns         : -
    ******************************************************************************/
    public void processDuplicatesCheck(E2EFormParams formParams, E2EFormData__c formData) {
        if (formData != null) {
            if (formData.Last_deduplication_time__c != null && Datetime.now() <= formData.Last_deduplication_time__c.addDays(this.businessDataRelevance)) {
                if (String.isNotBlank(formData.E2E_Dedup_Status__c)) {
                    formParams.deduplicationStatus = formData.E2E_Dedup_Status__c;
                    formParams.deduplicationDatetime = formData.Last_deduplication_time__c;
                    return;
                }
            }
        }
        // deduplication here
        E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
        //с нынешней нашей дедубликацией е2е это лучший способ обойти проверку по email ИМХО
        this.formRuService.deduplicationAccountProcess(
                formParams.companyInn,
                'qwertyuiiopasfdhjhl134afd@dlfsnncs.gmg',
                deduplicationResult
        );
        formParams.deduplicationStatus = deduplicationResult.statusCode;
        formParams.deduplicationStatusInfo = deduplicationResult.getDedupStatusInformation();
        formParams.deduplicationDatetime = deduplicationResult.deduplicationDatetime;
    }

    /*****************************************************************************
    *  Name            : processCheckStatus(Map<String, String> params)
    *  Summary         : checks result of client creation in SF
    *  CreatedDate     : 11/02/2020
    *  Parameters      : Map<String, String> params - query params
    *  Returns         : PPR_API_ResponseBody - created response
    ******************************************************************************/
    public PPR_API_ResponseBody processCheckStatus(Map<String, String> params) {
        E2EFormData__c formData = formRuDao.getFormDataById(params.get('id'));
        if (formData == null) return ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Internal server error. Invalid FormData Id parameter');
        return ResponseBodyBuilder.constructPPR_API_responseBody(formData.E2E_INN__c, params.get('source'));
    }

    public PPR_API_ResponseBody validationCheck(String jsonString) {
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            
        PPR_API_Validator validationService = new PPR_API_Validator();
        validationService.validationName = 'NewClientRequest';
        PPR_API_ResponseBody validationResult =  validationService.validateData(params);
        if (validationResult != null) {
            return validationResult;
        }
        PPR_API_CreateClientRequest request = (PPR_API_CreateClientRequest) JSON.deserialize(jsonString, PPR_API_CreateClientRequest.class);

        if (!request.customerInfo.legalInfo.agreements.contains('PersonalData')) return ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Validation error. Need agreement to process personal data');
        Custom_log__c log = PPR_API_LogService.getLogByInnAndSource(request.customerInfo.legalInfo.inn, request.metadata.source);
        if (log == null) {
            return ResponseBodyBuilder.constructPPR_API_ResponseBodyError(
                    'Validation error. No data for current INN and source was found. Please check company via /PPR_API/v1/CheckInn first.'
            );
        }
        if (log.E2E_Form_Ru_Data__c != request.metadata.id) {
            return ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Validation error. Metadata Id doesn\'t match customer INN and source');
        }
        E2EFormData__c formDataRecord = formRuDao.getFormDataById(request.metadata.id);
        if (formDataRecord == null) {
            return ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Validation error. FormData with this Id doesn\'t exist');
        }
        if (formDataRecord.E2E_Process_Status__c != 'New') {
            String errorMessage = 'Creation error. ';
            errorMessage += (formDataRecord.E2E_Process_Status__c  == 'Double') ? 'Client already exist' : 'Client is denied in cooperation';
            return ResponseBodyBuilder.constructPPR_API_ResponseBodyError(errorMessage);
        }

        validationResult = PPR_API_Validator.validateTypes(request);
        if (validationResult != null) {
            return validationResult;
        }

        PPR_API_ResponseBody responce = PPR_API_Validator.validateAddressLength(request.customerInfo.addresses);
        if (responce != null) {
            return responce;
        }

        return createSObjects(request);
    }

    public PPR_API_ResponseBody createSObjects(PPR_API_CreateClientRequest data) {
        PPR_API_Settings__c settings = PPR_API_Settings__c.getValues(data.metadata.source);
        doDisabledTriggers();


        E2EFormParams formParams = new E2EFormParams();
        formParams.externalUser = data.metadata.user;
        formParams.companyInn = data.customerInfo.legalInfo.inn;
        formParams.businessType = 0;
        formParams.idEqv = 1;
        if (data.customerInfo.orderInfo.services != null) {
            formParams.hasPersonalManager = data.customerInfo.orderInfo.services.contains('PersonalManager');
            formParams.hasDocumentDelivery = data.customerInfo.orderInfo.services.contains('ExpressDocDelivery');
        }

        if (data.customerInfo.orderInfo.promos != null) {
            if (data.customerInfo.orderInfo.promos.size() > 0) formParams.promoCode = data.customerInfo.orderInfo.promos[0];
            if (data.customerInfo.orderInfo.promos.size() > 1) formParams.addPromoCode = data.customerInfo.orderInfo.promos[1];
        }
        formParams.prepayAmount = settings.Prepay_sum__c;
        formParams.overdraftSum = data.customerInfo.orderInfo.overdraftSum;
        formParams.bankBic = data.customerInfo.bankInfo.bik;
        formParams.source = data.metadata.source;
        formParams.productId = (String.isNotBlank(data.customerInfo.orderInfo.product)) ? data.customerInfo.orderInfo.product : settings.Default_product__c;
        formParams.tariffId = (String.isNotBlank(data.customerInfo.orderInfo.tariff)) ? data.customerInfo.orderInfo.tariff : settings.Default_tariff__c;
        formParams.product = GlobalUtils.getE2EProduct(formParams.productId) + ' ' + GlobalUtils.getE2ETariffReverse(formParams.tariffId);
        formParams.cards = data.customerInfo.orderInfo.cards;
        formParams.sourcePP = data.metadata.source;

        E2E_Promocodes__c promocodeObject = E2E_Promocodes__c.getValues(formParams.promoCode);
        if (promocodeObject != null) {
            formParams.promocodeName = promocodeObject.Name;
            String dropdownList = promocodeObject.Promocode_Additional_Field__c;
            Map<String, String> supplies = new Map<String, String>();
            for (String val : dropdownList.split(';')) {
                supplies.put(val.split('@')[0], val.split('@')[1]);
            }
            String idPromocodeItem = supplies.get(dropdownList.split(';')[0].split('@')[0]);
            formParams.promocodeIdInTransit = idPromocodeItem;
        }
        promocodeObject = E2E_Promocodes__c.getValues(formParams.addPromoCode);
        if (promocodeObject != null) {
            formParams.addPromoCodeName = promocodeObject.Name;
            String dropdownList = promocodeObject.Promocode_Additional_Field__c;
            Map<String, String> supplies = new Map<String, String>();
            for (String val : dropdownList.split(';')) {
                supplies.put(val.split('@')[0], val.split('@')[1]);
            }
            String idPromocodeItem = supplies.get(dropdownList.split(';')[0].split('@')[0]);
            formParams.addPromoCodeIdInTransit = idPromocodeItem;
        }

        CFServiceRuImpl cfService = new CFServiceRuImpl();
        if (Test.isRunningTest()) CFTestDataFactory.populateDataForCF(formParams);
        formParams.isSoleProprietor = GlobalUtils.isSoleProprietor(formParams.companyInn);
        String orgType;
        if (formParams.isSoleProprietor == null) {
            throw new GlobalException('Bad request. INN is not correct: ' + formParams.companyInn);
        } else {
            formParams.sparkId = null;
            if (formParams.isSoleProprietor) {
                //if sole proprietor
                // get sole proprietor information from spark
                if (!Test.isRunningTest()) cfService.getSoleProprietorSparkData(formParams);
                formParams.ogrn = formParams.ogrnipSpark;
                formParams.okpo = formParams.okpoSpark;
                orgType = 'ИП';
            } else {
                //if company
                // get company information from spark
                if (Test.isRunningTest()) {
                    PPR_API_ServiceImplTest.getTestSparkData(formParams);
                } else {
                    cfService.getCompanySparkFullData(formParams);
                }
                formParams.kpp = formParams.kppSpark;
                formParams.okpo = formParams.okpoSpark;
                formParams.ogrn = formParams.ogrnSpark;
                formParams.matchExecutiveSpark = true;
                orgType = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(1);
            }
            if (formParams.sparkId == null) throw new GlobalException('Organization is not found in spark');
        }

        //get bank information from dadata
        try {
            DadataWebService dadataWebService = new DadataWebServiceImpl();
            DadataBank dadataBank;
            if (Test.isRunningTest()) {
                dadataBank = PPR_API_DataTestFactory.setDadataBankInfo();
            } else {
                dadataBank = dadataWebService.getBankData(formParams.bankBic);
            }

            formParams.bankBic = dadataBank.bic;
            formParams.bankAddress = dadataBank.address;
            formParams.bankName = dadataBank.name;
            formParams.bankNameShort = dadataBank.nameShort;
            formParams.bankOkpo = dadataBank.okpo;
            formParams.bankTown = dadataBank.town;
            formParams.corBankAccount = dadataBank.correspondentAccount;
            formParams.isBankInformationInvalid = false;
        } catch (Exception e) {
            return ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Dadata request error: ' + e.getMessage());
        }


        try {
            //SF-1324 start
            if (data.customerInfo.legalInfo.codeWord != null &&
                    data.customerInfo.legalInfo.codeWord.deleteWhitespace() != '') {
                formParams.codeWord = data.customerInfo.legalInfo.codeWord;
            } else {
                formParams.codeWord = generateCodeWord();
            }
            //SF-1324 end

            formParams.checkingAccount = data.customerInfo.bankInfo.accountNum;

            String name = (formParams.isSoleProprietor) ? formParams.mainCompanyFullNameSpark : GlobalUtils.createOrganiozationName(formParams.normName);

            Account account = new Account(
                    RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Russian'),
                    Name = name,
                    Type = 'Customer',
                    AccountSource = 'E2E Form RU',
                    INN__c = formParams.companyInn,
                    Code_Word__c = formParams.codeWord,
                    Checking_Account__c = formParams.checkingAccount,
                    SWIFT_BIC__c = formParams.bankBic,
                    OKPO_ppr__c = formParams.okpo,
                    OGRN_ppr__c = formParams.ogrn,
                    Organization_Type__c = orgType,
                    KPP__c = (formParams.kppSpark == '' || formParams.kppSpark == null) ? 0 : Decimal.valueOf(formParams.kppSpark)
            );

            if (Test.isRunningTest()) account.BillingCountry = 'Russia';
            this.serviceHelper.processAddresses(data.customerInfo.addresses, formParams, account);
            formParams.accountId = formRuDao.createAccount(account);
            //formParams.accountId = formRuService.createAccount(formParams);
            System.debug('***** created accountId=' + formParams.accountId + ' ' + system.currentTimeMillis());
        } catch(Exception e) {
            return ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Account creation error: ' + e.getMessage() + ' line: ' + e.getLineNumber());
        }

        try {
            formParams.businessProcess = ''+GlobalUtils.BusinessProcessType.Standard;
            formParams.numOfCards = data.customerInfo.orderInfo.cards.size();

            String name = (formParams.isSoleProprietor) ? formParams.mainCompanyFullNameSpark : GlobalUtils.createOrganiozationName(formParams.normName);

            Opportunity opportunity = new Opportunity(
                    Business_process__c = formParams.businessProcess,
                    Name = name,
                    CategoryContract__c = GlobalUtils.getContractType('MultiOffer'),
                    StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AgreementTermsAndConditions),
                    AccountId = formParams.accountId,
                    CloseDate = GlobalUtils.addBusinessDays(Date.today(), 5),
                    LeadSource = 'E2E Form RU',
                    Lead_Source_TypeOpp__c = 'Webform',
                    Source_of_Lead_o__c = 'E2E Form RU',
                    Source_if_self_sourced_c__c = 'E2E Form RU',
                    PPR_First_Contact_Inbound_Outbound__c = 'Inbound Website',
                    Channel__c = 'Internet',
                    RecordTypeId = GlobalUtils.getRecordTypeId('Opportunity', 'Russian_Sales'),
                    E2E_Status__c = 'Клиент Активен',
                    E2E_Sales_Type__c = 'Чистый e2e',
                    Source_PP__c = formParams.sourcePP,
                    E2E_Last_Activity__c = Datetime.now(),
                    E2E_Active_Substep__c = GlobalUtils.getE2ESteps(GlobalUtils.E2ERuSteps.ContactDetails.name()),
                    Product_PPR__c = formParams.product,
                    Number_of_Cards__c = formParams.numOfCards,
                    Promo_campaign__c = GlobalUtils.getPromocodesString(new List<String> {
                            formParams.promoCode,
                            formParams.addPromoCode
                    })
            );
            formParams.opportunityId = formRuDao.createOpportunity(opportunity);

            //formParams.opportunityId = formRuService.createOpportunity(formParams.accountId, formParams);
            System.debug('***** created opportunityId=' + formParams.opportunityId + ' ' + system.currentTimeMillis());
        } catch(Exception e) {
            PPR_API_ResponseBody response = ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Account creation error: ' + e.getMessage());
            return serviceHelper.saveReferencesInFormData(formParams, null, data.metadata.id, response);
        }

        try {
            for (PPR_API_CreateClientRequest.PhoneObj phone: data.customerInfo.legalInfo.phones) {
                if (phone.type.contains('Main')) {
                    formParams.mainContactPhone = GlobalUtils.constructPhoneNumber(
                            phone.value.code,
                            phone.value.numberStr,
                            phone.value.ext
                    );
                    break;
                }
            }
            for (PPR_API_CreateClientRequest.EmailObj email: data.customerInfo.legalInfo.emails) {
                if (email.type.contains('Mail')) {
                    formParams.mainContactEmail = email.value;
                }
                if (email.type.contains('LK accesses')) {
                    formParams.emailForPersonalOffice = email.value;
                }
            }

            Boolean requestHasDecisionMakerData = false;
            if (data.customerInfo.staff != null && data.customerInfo.staff.size() > 0) {
                for (PPR_API_CreateClientRequest.StaffObj staff : data.customerInfo.staff) {
                    if (staff.role.equals('Decision Maker')) {
                        formParams.executiveFio = staff.lastName + ' ' + staff.firstName;
                        if (String.isNotBlank(staff.Surname))  formParams.executiveFio += ' ' + staff.Surname;
                        formParams.executivePosition = staff.position;
                        requestHasDecisionMakerData = true;

                        if (staff.phones != null && staff.phones.size() > 0) {
                            for (PPR_API_CreateClientRequest.PhoneObj phonerecord : staff.phones) {
                                PPR_API_CreateClientRequest.ValueObj phoneValues = phonerecord.value;
                                formParams.executivePhone += GlobalUtils.constructPhoneNumber(phoneValues.code, phoneValues.numberStr, phoneValues.ext) + '.';
                            }
                            formParams.executivePhone = formParams.executivePhone.removeEnd('.');
                        }
                        break;
                    }
                }
            }

            if ( !requestHasDecisionMakerData && formParams.isSoleProprietor) {
                formParams.executiveFio = formParams.soleProprietorFio;
                formParams.executivePosition = RussianUtils.SOLE_PROPRIETOR;
            }

            formParams.contactId = formRuService.createContact(formParams.accountId, null, formParams, GlobalUtils.BusinessProcessType.PPR_API);
            formParams.executiveId = this.formRuService.createEmployeeContact(formParams.accountId, formParams.executiveFio, formParams.executivePosition, GlobalUtils.BusinessProcessType.PPR_API.name());
            if (String.isNotBlank(formParams.executivePhone)) {
                Contact executiveContact = new Contact(Id = formParams.executiveId, Additional_Phones__c = formParams.executivePhone);
                formRuDao.updateContact(executiveContact);
            }

            E2EFormRuServiceImpl.updateOpportunityContactRole(formParams.opportunityId, formParams.contactId, 'Decision Maker', true);
            this.formRuService.createOpportunityContactRole(formParams.opportunityId, formParams.executiveId, 'Decision Maker', false);
            System.debug('***** created contactId=' + formParams.contactId + ' ' + system.currentTimeMillis());
            System.debug('***** created executiveId = ' + formParams.executiveId + ' ' + system.currentTimeMillis());
        } catch(Exception e) {
            PPR_API_ResponseBody response = ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Contact creation error: ' + e.getMessage());
            return serviceHelper.saveReferencesInFormData(formParams, null, data.metadata.id, response);
        }

        E2EFormData__c formDataRecord;
        try {
            //cards, agreements, countryCode, addressId
            formDataRecord = formRuDao.getFormDataById(data.metadata.id);
            if (formDataRecord == null) return ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Validation error. FormData with this Id doesn\'t exist');
            if (formDataRecord.E2E_Manual_Entry__c == true) {
                formParams.sendToInbound = true;
            } else {
                formParams.sendToInbound = false;
            }
            formParams.scoringDecisionCode = formDataRecord.E2E_Scoring_Decision_Code__c;
            if (data.customerInfo.additionalInfo != null) {
                formParams.deliveryComments = data.customerInfo.additionalInfo.courierServiceComments;
            }

            formDataRecord.E2E_Contact_Id__c = formParams.contactId;
            formDataRecord.E2E_Contact_Phone__c = formParams.mainContactPhone;
            formDataRecord.E2E_Contact_Email__c = formParams.mainContactEmail;
            //formDataRecord.E2E_Offer__c = ;
            formDataRecord.E2E_Source__c = formParams.source;
            formDataRecord.E2E_Product__c = formParams.product;
            formDataRecord.E2E_Num_Cards__c = formParams.numOfCards;
            formDataRecord.E2E_Product_Id__c = formParams.productId;
            formDataRecord.E2E_Tariff_Id__c = formParams.tariffId;
            formDataRecord.E2E_Promo_Campaign__c = GlobalUtils.getPromocodesString(new List<String> {
                    formParams.promoCode,
                    formParams.addPromoCode
            });

            formDataRecord.E2E_Executive_Person__c = formParams.executiveFio + ', ' + formParams.executivePosition;
            formDataRecord.E2E_Executive_Person_Manual__c = formDataRecord.E2E_Executive_Person__c;

            formDataRecord.E2E_INN__c = formParams.companyInn;

            this.serviceHelper.processAddresses(data.customerInfo.addresses, formParams, formDataRecord);

            formDataRecord.E2E_Personal_Manager_srv__c = formParams.hasPersonalManager;
            formDataRecord.E2E_Document_Delivery_srv__c = formParams.hasDocumentDelivery;
            formDataRecord.E2E_Code_Word__c = formParams.codeWord;
            formDataRecord.E2E_Personal_Office_Email__c = formParams.emailForPersonalOffice;
            formDataRecord.E2E_Courier_Comments__c = formParams.deliveryComments + '\nКарты - ' + String.join(formParams.cards, ';');
            formDataRecord.E2E_BIC__c = formParams.bankBic;
            formDataRecord.E2E_Checking_Account__c = formParams.checkingAccount;
            formDataRecord.E2E_Prepay_Amount__c = formParams.prepayAmount;
            formDataRecord.E2E_Payment_Condition__c = data.customerInfo.orderInfo.orderType;
            formDataRecord.E2E_Opportunity_Id__c = formParams.opportunityId;
            formDataRecord.E2E_Account_Id__c = formParams.accountId;
            formDataRecord.E2E_Contact_Email__c = formParams.mainContactEmail;
            formDataRecord.E2E_Spark_Id__c = String.valueOf(formParams.sparkId);

            formDataRecord.E2E_KPP__c = formParams.kppSpark;
            formDataRecord.E2E_OGRN__c = formParams.ogrn;
            formDataRecord.E2E_OKPO__c = formParams.okpo;

            formDataRecord.E2E_Bank__c = formParams.bankName;
            formDataRecord.E2E_Bank_Name_Short__c = formParams.bankNameShort;
            formDataRecord.E2E_Cor_Bank_Account__c = formParams.corBankAccount;
            formDataRecord.E2E_Bank_OKPO__c = formParams.bankOkpo;
            formDataRecord.E2E_Bank_Town__c = formParams.bankTown;
            formDataRecord.E2E_Bank_Address__c = formParams.bankAddress;

            formDataRecord.E2E_Main_Company_Full_Name__c = formParams.mainCompanyFullNameSpark;

            if (data.customerInfo.legalInfo.agreements != null) {
                formDataRecord.E2E_Process_Personal_Data__c = data.customerInfo.legalInfo.agreements.contains('PersonalData');
                formDataRecord.E2E_Send_Marketing_Email__c = data.customerInfo.legalInfo.agreements.contains('MarketingProgram');
            }

            if (formParams.isSoleProprietor) {
                formDataRecord.E2E_Account_Name__c = formParams.mainCompanyFullNameSpark;
                formDataRecord.E2E_Account_Short_Name__c = formParams.mainCompanyFullNameSpark.removeStart('ИП ');
            } else {
                formDataRecord.E2E_Account_Name__c = GlobalUtils.createOrganiozationName(formParams.normName);
                formDataRecord.E2E_Account_Short_Name__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(0);
            }
            formDataRecord.E2E_Process_Status__c = 'Processing';
            formRuDao.updateFormData(formDataRecord);

        } catch(Exception e) {
            PPR_API_ResponseBody response = ResponseBodyBuilder.constructPPR_API_ResponseBodyError('FormData updation error: ' + e.getMessage());
            return serviceHelper.saveReferencesInFormData(formParams, formDataRecord, data.metadata.id, response);
        }

        try {
            //if (!Test.isRunningTest()) {
            System.enqueueJob(new PPR_API_AsyncRequests(formParams, formDataRecord));
            //}
            System.debug('**** AsyncSenderRequests QUEUEABLE LAUNCHED');
        } catch(Exception e) {
            PPR_API_ResponseBody response = ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Error with Async Requests: ' + e.getMessage());
            return serviceHelper.saveReferencesInFormData(formParams, formDataRecord, data.metadata.id, response);
        }

        PPR_API_ResponseBody response = new PPR_API_ResponseBody();
        response.metadata = new PPR_API_ResponseBody.Metadata();
        response.metadata.id = data.metadata.id;
        response.metadata.user = data.metadata.user;
        response.customerInfo = new PPR_API_ResponseBody.CustomerInfo();
        response.customerInfo.inn = formParams.companyInn;
        response.customerInfo.customerStatus = formDataRecord.E2E_Process_Status__c;
        response.customerInfo.customerStatusId = (String) PPR_Mapping_Utils.customerStatusMap.get(formDataRecord.E2E_Process_Status__c);
        return response;
    }

    private void doDisabledTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;

        ContactTriggerHandler.isE2EForm = true;
        OpportunityTriggerHandler.isE2EForm = true;
    }
	
    //SF-1324 start
    private String generateCodeWord() {
        StaticResource pprApiResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PPR_API_CodeWords' LIMIT 1];
        List<Object> codeList = (List<Object>) ((Map<String, Object>) JSON.deserializeUntyped(pprApiResource.Body.toString())).get('words');
        return (String) codeList.get(Integer.valueof(Math.random() * (codeList.size() - 1)));
    }
    //SF-1324 end
}