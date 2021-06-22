public without sharing class E2EFormRuServiceImpl implements E2EFormRuService {
    public static Boolean isScoringTrue = false;
    public static final String SOURCE_LEAD = 'Партнерская программа';

    private E2EFormRuDao e2eFormRuDao;
    private FormDataValidator formDataValidator;
    private CFService creditFactoryService;
    private E2EFormRuServiceImplHelper serviceHelper;
    private Converter numberConverter;

    public E2EFormRuServiceImpl() {
        this.e2eFormRuDao = new E2EFormRuDaoImpl();
        this.formDataValidator = new FormDataValidator();
        this.creditFactoryService = new CFServiceRuImpl();
        this.serviceHelper = new E2EFormRuServiceImplHelper();
        this.numberConverter = new ConverterRU();
    }

    //******* Content Service *****//

    /*******************************************************************************
   *  Name            : getPages(String country, String stepName, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType)
   *  Summary         : generate pages map for some Step
   *  CreatedDate     : 10/07/2018
   *  ModifiedDate    : 23/10/2020
   *  Parameters      : String country, String stepName, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType
   *  Returns         : -
   ******************************************************************************/
    public void collectContent(String country, String stepName, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType) {
        System.debug('In collectContent method');
        GlobalUtils.E2ERuSteps activeStep = convertToStep(stepName);
        List<String> elementsOfStep = getStepElements(activeStep);

        List<String> needLoadElements = new List<String>();
        for (String element : elementsOfStep) {
            if (!pagesMap.containsKey(element)) {
                needLoadElements.add(element);
            }
        }

        Map<Id, LongForm_Page__c> longFromPages = e2eFormRuDao.getLongFormPages(country, new Set<String>(needLoadElements), deviceType.name());
        List<LongForm_Element__c> elementsList = e2eFormRuDao.getElementsListByPages(longFromPages.keySet());

        Set<Id> offerIds = new Set<Id>();
        for (LongForm_Element__c element : elementsList) {
            for (LongForm_Offer__c offer : element.LongForm_Offers__r) {
                offerIds.add(offer.Id);
            }
        }

        System.debug('OfferIds ' + offerIds);

        Map<Id, LongForm_Offer__c> offers = new Map<Id, LongForm_Offer__c>();
        offers = e2eFormRuDao.getOffersByIds(offerIds);

        Map<Id, LongForm_Fleetcor_Product__c> products = new Map<Id, LongForm_Fleetcor_Product__c>();
        products = e2eFormRuDao.getProductsByOffer(offerIds);

        Map<Id, LongForm_Tariff__c> tariffs = new Map<Id, LongForm_Tariff__c>();
        tariffs = e2eFormRuDao.getTariffsByProduct(products.keySet());

        Map<Id, LongForm_Property__c> properties = new Map<Id, LongForm_Property__c>();
        properties = e2eFormRuDao.getPropertiesByTariff(tariffs.keySet());

        for (LongForm_Element__c element : elementsList) {
            if (!pagesMap.containsKey(element.Long_Form_Page__r.Name)) {
                pagesMap.put(element.Long_Form_Page__r.Name, new LongFormPage());
                pagesMap.get(element.Long_Form_Page__r.Name).pageTitle = element.Long_Form_Page__r.Title__c;
                pagesMap.get(element.Long_Form_Page__r.Name).systemError = element.Long_Form_Page__r.System_Error__c;
                pagesMap.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongFormElementItem>>();
                pagesMap.get(element.Long_Form_Page__r.Name).fields = new Map<String, LongFormField>();
            }

            if (GlobalUtils.fieldTypes.contains(element.Type__c) && !element.Long_Form_Element_Items__r.isEmpty()) {
                LongFormField field = new LongFormField();
                field.options = new List<SelectOption>();
                field.elementItemsMap = new Map<String, LongFormElementItem>();
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    LongFormElementItem lfElementItem = new LongFormElementItem();
                    lfElementItem.value = elementItem.Value__c;
                    if (elementItem.Type__c == 'Options') {
                        lfElementItem.value = elementItem.Value__c.deleteWhitespace();
                        lfElementItem.value = elementItem.Value__c.replaceAll('_', ' ');
                        List<String> optionsList = elementItem.Value__c.split(';');
                        for (String option : optionsList) {
                            option = option.trim();
                            field.options.add(new SelectOption(option.substringBefore('=>'), option.substringAfter('=>')));
                        }
                    }
                    field.elementItemsMap.put(elementItem.Name, lfElementItem);
                }
                pagesMap.get(element.Long_Form_Page__r.Name).fields.put(element.Name, field);
            } else {
                if (!pagesMap.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name)) {
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongFormElementItem>());
                }
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    LongFormElementItem lfElementItem = new LongFormElementItem();
                    lfElementItem.value = elementItem.Value__c;
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, lfElementItem);
                }
            }

            // Init offers
            for (LongForm_Offer__c offer : element.LongForm_Offers__r) {

                LongFormOffer longFormOffer = new LongFormOffer();
                longFormOffer.offerName = offer.Product__c;
                longFormOffer.products = new Map<String, LongFormProduct>();

                if (pagesMap.get(element.Long_Form_Page__r.Name).fields.get(element.Name).offers == null) {
                    pagesMap.get(element.Long_Form_Page__r.Name).fields.get(element.Name).offers = new Map<String, LongFormOffer>();
                }
                pagesMap.get(element.Long_Form_Page__r.Name).fields.get(element.Name).offers.put(offer.Product__c, longFormOffer);

                LongForm_Offer__c offerWithAllParameters = offers.get(offer.Id); // get offer with all filled fields
                for (LongForm_Fleetcor_Product__c productItem : offerWithAllParameters.Long_Form_Fleetcor_Products__r) {

                    LongFormProduct longFormProduct = new LongFormProduct();
                    longFormProduct.productName = productItem.Name;
                    longFormProduct.productLabel = productItem.Label__c;
                    longFormProduct.tariffs = new Map<String, LongFormTariff>();
                    longFormProduct.productProperties = new Map<String, LongFormTariffProperty>();

                    // put products to offer
                    longFormOffer.products.put(productItem.Name, longFormProduct);

                    LongForm_Fleetcor_Product__c productWithAllParameters = products.get(productItem.Id); // get product with all filled fields
                    for (LongForm_Tariff__c tariffItem : productWithAllParameters.LongForm_Tariffs__r) {

                        LongFormTariff longFormTariff = new LongFormTariff();
                        longFormTariff.tariffName = tariffItem.Name;
                        longFormTariff.tariffLabel = tariffItem.Label__c;
                        longFormTariff.showTariff = tariffItem.Show_Tariff__c;
                        if (longFormTariff.properties == null) {
                            longFormTariff.properties = new Map<String, LongFormTariffProperty>();
                        }

                        // put tariff to product
                        longFormProduct.tariffs.put(tariffItem.Name, longFormTariff);

                        LongForm_Tariff__c tariffWithAllParameters = tariffs.get(tariffItem.Id); // get tariff with all filled fields
                        if (tariffWithAllParameters != null) {
                            for (LongForm_Property__c propItem : tariffWithAllParameters.LongForm_Properties__r) {

                                LongForm_Property__c propertyWithAllParameters = properties.get(propItem.Id);
                                LongFormTariffProperty tariffProperty = new LongFormTariffProperty();
                                tariffProperty.propertyName = propertyWithAllParameters.Name;
                                tariffProperty.propertyValue = propertyWithAllParameters.Value__c;
                                tariffProperty.propertyPopup = propertyWithAllParameters.Popup__c;
                                tariffProperty.propertyItems = propertyWithAllParameters.LongForm_Property_Items__r;
                                tariffProperty.propertyItems.sort();
                                longFormTariff.properties.put(propertyWithAllParameters.Name, tariffProperty);
                                longFormProduct.productProperties.put(tariffProperty.propertyName, tariffProperty);
                            }
                        }
                    }

                    for (String keyItem : longFormProduct.productProperties.keySet()) {
                        LongFormTariffProperty property = longFormProduct.productProperties.get(keyItem);
                        property.propertyTariffs = longFormProduct.tariffs;


                        for (LongFormTariff tariff : longFormProduct.tariffs.values()) {
                            if (!tariff.properties.containsKey(keyItem)) {
                                LongFormTariffProperty tariffProperty = new LongFormTariffProperty();
                                tariffProperty.propertyName = property.propertyName;
                                tariffProperty.propertyValue = property.propertyValue;
                                tariffProperty.propertyPopup = property.propertyPopup;
                                tariffProperty.propertyItems = new List<LongForm_Property_Item__c>();
                                tariffProperty.propertyItems.add(new LongForm_Property_Item__c(Name = '', Value__c = '-'));
                                tariff.properties.put(tariffProperty.propertyName, tariffProperty);
                            }
                        }

                    }
                }
            }
        }

    }

    public void collectSharedResource(String country, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType, String source) {
        String sharedStep = 'SHARED RESOURCES';

        List<String> needLoadElements = new List<String>();
        needLoadElements.add(sharedStep);

        Map<Id, LongForm_Page__c> longFromPages = e2eFormRuDao.getSharedResources(country, new Set<String>(needLoadElements), deviceType.name());
        List<LongForm_Element__c> elementsList = new List<LongForm_Element__c>();

        boolean isInList = false;

        System.debug('Source ' + source);

        for (LongForm_Element__c item : e2eFormRuDao.getElementsListByPages(longFromPages.keySet())) {
            if (item.Name.equals(source.toUpperCase() + ' HEADERS')) {
                System.debug('Item ' + item.Name);
                item.Name = item.Name.split(' ')[1].trim();
                isInList = true;
            }
        }

        if (!isInList) source = 'petrolplus';

        for (LongForm_Element__c item : e2eFormRuDao.getElementsListByPages(longFromPages.keySet())) {
            if (item.Name.contains('HEADERS')) {
                if (item.Name.equals(source.toUpperCase() + ' HEADERS')) {
                    item.Name = item.Name.split(' ')[1].trim();
                    elementsList.add(item);
                }
            } else {
                System.debug(item.Name);
                elementsList.add(item);
            }
        }

        for (LongForm_Element__c element : elementsList) {

            if (!pagesMap.containsKey(element.Long_Form_Page__r.Name)) {
                pagesMap.put(element.Long_Form_Page__r.Name, new LongFormPage());
                pagesMap.get(element.Long_Form_Page__r.Name).pageTitle = element.Long_Form_Page__r.Title__c;
                pagesMap.get(element.Long_Form_Page__r.Name).systemError = element.Long_Form_Page__r.System_Error__c;
                pagesMap.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongFormElementItem>>();
                pagesMap.get(element.Long_Form_Page__r.Name).fields = new Map<String, LongFormField>();
            }

            if (GlobalUtils.fieldTypes.contains(element.Type__c) && !element.Long_Form_Element_Items__r.isEmpty()) {
                LongFormField field = new LongFormField();
                field.options = new List<SelectOption>();
                field.elementItemsMap = new Map<String, LongFormElementItem>();
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    LongFormElementItem lfElementItem = new LongFormElementItem();
                    lfElementItem.value = elementItem.Value__c;
                    if (elementItem.Type__c == 'Options') {
                        lfElementItem.value = elementItem.Value__c.deleteWhitespace();
                        lfElementItem.value = elementItem.Value__c.replaceAll('_', ' ');
                        List<String> optionsList = elementItem.Value__c.split(';');
                        for (String option : optionsList) {
                            option = option.trim();
                            field.options.add(new SelectOption(option.substringBefore('=>'), option.substringAfter('=>')));
                        }
                    }
                    field.elementItemsMap.put(elementItem.Name, lfElementItem);
                }
                pagesMap.get(element.Long_Form_Page__r.Name).fields.put(element.Name, field);
            } else {
                if (!pagesMap.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name)) {
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongFormElementItem>());
                }
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    LongFormElementItem lfElementItem = new LongFormElementItem();
                    lfElementItem.value = elementItem.Value__c;
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, lfElementItem);
                }
            }
        }

    }

    public void collectContentDataByLink(Id formDataId, String stepName, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, Map<String, LongFormTariff> msl_suffix, Map<String, String> objectIds) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(stepName);
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        Account account = this.e2eFormRuDao.getAccountById(formDataRecord.E2E_Account_Id__c);
        Contact contact = this.e2eFormRuDao.getContactById(formDataRecord.E2E_Contact_Id__c);
        Opportunity opportunity = e2eFormRuDao.getOpportunityById(formDataRecord.E2E_Opportunity_Id__c);

        objectIds.put('accountId', account.Id);
        objectIds.put('contactId', contact.Id);
        objectIds.put('opportunityId', opportunity.Id);

        List<String> stepsList = getStepElements(activeStep);
        if (!stepsList.isEmpty()) {
            for (String step : stepsList) {

                if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()).get(0)) {
                    // STEP CONTACT DETAILS

                    String offer = '';
                    String source = '';
                    String product = '';

                    if (formDataRecord.E2E_Product_Id__c != null && formDataRecord.E2E_Source__c != null && formDataRecord.E2E_Offer__c != null) {
                        offer = formDataRecord.E2E_Offer__c;
                        source = formDataRecord.E2E_Source__c;
                        product = formDataRecord.E2E_Product_Id__c;
                    } else {
                        offer = GlobalUtils.E2ESource.PetrolPlus.name();
                        source = GlobalUtils.E2ESource.PetrolPlus.name();
                        product = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
                    }

                    // set offer
                    formParams.offer = offer;

                    // set product
                    formParams.product = product;

                    // set source
                    formParams.source = source;

                    // set promo
                    if (formDataRecord.E2E_Promo_Campaign__c != null) {
                        formParams.promoCode = formDataRecord.E2E_Promo_Campaign__c;
                        System.debug('BACK TO FORM FORMDATA ' + formDataRecord.E2E_Promo_Campaign__c);
                    }

                    pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value = contact.Phone;
                    pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = contact.Email;
                    pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').value = String.valueOf(contact.Agree_to_receive_comm_info_by_email__c);
                    pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value = String.valueOf(contact.Agree_to_process_pers_data_for_marketing__c);

                    formParams.source = formDataRecord.E2E_Source__c;
                    formParams.sourcePP = opportunity.Source_PP__c;

                } else if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()).get(0)) {
                    pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value = account.Name;
                    pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = account.INN__c;
                    pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').value = String.valueOf(formDataRecord.E2E_Manual_Entry__c);

                    formParams.okpoSpark = formDataRecord.E2E_OKPO__c;
                    formParams.kppSpark = formDataRecord.E2E_KPP__c;

                    if (formDataRecord.E2E_Manual_Entry__c == true) {
                        formParams.isManualEntry = true;
                        formParams.sendToInbound = true;
                    }

                    if (formDataRecord.E2E_Spark_Id__c != null) {
                        formParams.sparkId = Decimal.valueOf(formDataRecord.E2E_Spark_Id__c);
                    }
                    formParams.mainCompanyFullNameSpark = formDataRecord.E2E_Main_Company_Full_Name__c;
                    formParams.postCodeSpark = formDataRecord.E2E_Billing_Code__c;
                    formParams.regionSpark = formDataRecord.E2E_Billing_State__c;
                    formParams.citySpark = formDataRecord.E2E_Billing_City__c;
                    formParams.streetSpark = formDataRecord.E2E_Billing_Str__c;
                    formParams.buildingSpark = formDataRecord.E2E_Billing_House__c;
                    formParams.housingSpark = formDataRecord.E2E_Billing_Apartment__c;
                    formParams.blockSpark = '';
                    formParams.roomSpark = '';
                    formParams.legalAddressSpark = formDataRecord.E2E_Legal_Address__c;
                    formParams.legalAddressAdditionally = formDataRecord.E2E_Billing_Apartment__c;
                    formParams.postalAddress = formDataRecord.E2E_Post_Address__c;
                    formParams.postalAddressAdditionally = formDataRecord.E2E_Shipping_Apartment__c;
                    formParams.verifiedDecisionCode = formDataRecord.E2E_Black_List_Code__c;
                    formParams.verifiedDecision = formDataRecord.E2E_Black_List__c;
                    formParams.verifiedLimitation = formDataRecord.E2E_Black_List_Limitations__c;
                    formParams.scoringDecisionCode = formDataRecord.E2E_Scoring_Decision_Code__c;
                    formParams.scoringDecision = formDataRecord.E2E_Scoring_Decision__c;
                    formParams.scoringDate = formDataRecord.E2E_Scoring_Date__c;

                    if (account.Organization_Type__c == 'ИП') {
                        formParams.ogrnipSpark = account.OGRN_ppr__c;
                        formParams.isSoleProprietor = true;
                        List<String> executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
                        formParams.soleProprietorFio = executivePersonData.get(0);
                        formParams.executivePosition = executivePersonData.get(1);
                    } else {
                        formParams.ogrnSpark = account.OGRN_ppr__c;
                        formParams.isSoleProprietor = false;
                        List<String> executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
                        formParams.executiveFio = executivePersonData.get(0);
                        formParams.executivePosition = executivePersonData.get(1);
                        if (executivePersonData.get(0) != '' && executivePersonData.get(1) != '') {
                            formParams.executiveId = createEmployeeContact(account.Id, formParams.executiveFio, formParams.executivePosition, formParams.businessProcess);
                        }
                    }

                    // if position does not exist, send to Inbound
                    if (formParams.executivePosition == null || formParams.executivePosition == '') {
                        formParams.sendToInbound = true;
                    }

                } else if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()).get(0)) {
                    // STEP ORDER
                    pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value = String.valueOf(formDataRecord.E2E_Num_Cards__c);
                    pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Promo_Campaign__c;
                    pagesMap.get('ORDER').fields.get('PAYMENT CONDITIONS').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Payment_Condition__c;
                    pagesMap.get('ORDER').fields.get('PERSONAL MANAGER').elementItemsMap.get('DEFAULT VALUE').value = String.valueOf(formDataRecord.E2E_Personal_Manager_srv__c);
                    pagesMap.get('ORDER').fields.get('DOCS DELIVERY').elementItemsMap.get('DEFAULT VALUE').value = String.valueOf(formDataRecord.E2E_Document_Delivery_srv__c);
                    pagesMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value = String.valueOf(formDataRecord.E2E_Overdraft_srv__c);

                    // check amount cards
                    Integer numberOfCards = Integer.valueOf(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Number_of_Cards__c);
                    if (formDataRecord.E2E_Num_Cards__c > numberOfCards) {
                        formParams.sendToInbound = true;
                    }

                    String offer = '';
                    String source = '';
                    String product = '';
                    if (formDataRecord.E2E_Product_Id__c != null && formDataRecord.E2E_Tariff_Id__c != null && formDataRecord.E2E_Source__c != null && formDataRecord.E2E_Offer__c != null) {
                        offer = formDataRecord.E2E_Offer__c;
                        source = formDataRecord.E2E_Source__c;
                        product = formDataRecord.E2E_Product_Id__c;
                        formParams.product = formDataRecord.E2E_Product_Id__c;
                        pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value = formDataRecord.E2E_Product_Id__c;
                        pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value = formDataRecord.E2E_Tariff_Id__c;
                        System.debug('INIT OK' + formDataRecord.E2E_Tariff_Id__c);
                    } else {
                        offer = GlobalUtils.E2ESource.PetrolPlus.name();
                        source = GlobalUtils.E2ESource.PetrolPlus.name();
                        product = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
                        formParams.product = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
                        pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
                        if (pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value == '') {
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value = '3SUPER_CARDS';
                        }
                    }

                    // set offer
                    formParams.offer = offer;

                    // set product
                    formParams.product = product;

                    // set source
                    formParams.source = source;

                    setAZSLocatorLink(product, pagesMap);
                    if (formDataRecord.E2E_Promo_Campaign__c != null) {
                        formParams.promoCode = formDataRecord.E2E_Promo_Campaign__c;
                        System.debug('BACK TO FORM FORMDATA ' + formDataRecord.E2E_Promo_Campaign__c);

                        String promocode = formParams.promoCode;
                        String productName = pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('DEFAULT VALUE').value;
                        pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').value = '';
                        System.debug('BACK TO FORM FORMDATA 1');
                        if (promocode != null && !promocode.equals('')) {
                            System.debug('BACK TO FORM FORMDATA 2');
                            E2E_Promocodes__c promocodeObject = E2E_Promocodes__c.getValues(promocode);
                            if (promocodeObject != null) {
                                System.debug('BACK TO FORM FORMDATA 3');
                                System.debug(promocodeObject.Product_Name__c + ' == ' + productName);

                                if (promocodeObject.Product_Name__c != productName) {
                                    System.debug('BACK TO FORM FORMDATA 4');
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').value = 'Данная акция действует только при заказе карт ' + promocodeObject.Product_Name__c;
                                    pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').value = 'Данная акция действует только при заказе карт ' + promocodeObject.Product_Name__c;
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').value = '';
                                    /*pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').value = '';
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').value = '';*/
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').value = '';
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = '';
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value = '';
                                } else {
                                    System.debug('BACK TO FORM FORMDATA 5');
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').value = promocodeObject.Name;
                                    /*pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').value = String.format(promocodeObject.Promocode_Label__c, new List<String>{formParams.source});
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').value = promocodeObject.Promocode_Description_Title__c;*/
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').value = promocodeObject.Promocode_Description_Body__c;
                                    if (promocodeObject.Promocode_Additional_Field__c == null || promocodeObject.Supplier_Selection__c == 'False') {
                                        pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = '';
                                        pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value = '';
                                    } else {
                                        String dropdownList = promocodeObject.Promocode_Additional_Field__c;
                                        pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = dropdownList;
                                        pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value = dropdownList.split(';')[0].split('@')[0];

                                        String listPromocodeItems = pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value;
                                        Map<String, String> supplies = new Map<String, String>();
                                        for (String val : listPromocodeItems.split(';')) {
                                            supplies.put(val.split('@')[0], val.split('@')[1]);
                                        }
                                        String idPromocodeItem = supplies.get(pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value);
                                        formParams.promocodeIdInTransit = idPromocodeItem;
                                    }

                                    pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').value = '';
                                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').value = '';
                                    System.debug(pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value);

                                    formParams.promocodeName = promocodeObject.Name;
                                }
                            } else {
                                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').value = 'Промокод недействителен';
                                pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').value = 'Промокод недействителен';
                                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').value = '';
                                /*pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').value = '';
                                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').value = '';*/
                                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').value = '';
                                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = '';
                                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').value = '';
                            }
                            //VS SF-695
                            pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').value = 'Акция: 50 копеек с литра!';
                            pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').value = 'Скидка 50 копеек с литра топлива на АЗС ' +
                                    '<a target="_blank" rel="noopener noreferrer" href="http://www.petrolplus.ru/docs.php?f=GES_gsa">«Газпром»</a> и ' +
                                    '<a target="_blank" rel="noopener noreferrer" href="http://www.petrolplus.ru/docs.php?f=gazprom_neft">«Газпром нефть»</a> в течение 3-х календарных месяцев с даты договора.';
                        }
                    }

                    pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('DEFAULT VALUE').value = pagesMap.get('ORDER').fields.get('PRODUCTS').offers.get(offer).products.get(product).productLabel;
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').value = '';

                    // Init tariffs
                    Map<String, LongFormTariff> msl = pagesMap.get('ORDER').fields.get('PRODUCTS').offers.get(offer).products.get(product).tariffs;
                    System.debug('msl **');
                    System.debug(msl);

                    String suffix = null;
                    if (msl.size() == 2) {
                        formParams.numberOfTariffsDependency = '999';
                        if (formParams.product == 'PetrolPlus_Gaz') {
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value = 'Тариф 2';
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value = '2CONTRACT_CARDS';
                        }
                        if (formParams.product == 'Partner_Rover') {
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value = 'Супер Договор';
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value = '3SUPER_CARDS';
                        }

                        suffix = '_CARDS';
                    } else {
                        formParams.numberOfTariffsDependency = '5';
                        if (Test.isRunningTest()) {
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value = msl.get(new List<String>(msl.keySet())[0]).tariffLabel;
                        } else {
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value = msl.get(pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value).tariffLabel;
                        }
                        //pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value = '2CHOOSEN_CONTRACT';
                        Integer thresholdForCards = Integer.valueOf(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Number_of_Cards_Card__c);
                        if (formDataRecord.E2E_Num_Cards__c < thresholdForCards) {
                            suffix = '_CARDS';
                        } else {
                            suffix = '_CONTRACT';
                        }
                    }

                    msl_suffix.clear();
                    for (String tariffName : msl.keySet()) {
                        if (tariffName.indexOf(suffix) != -1) {
                            LongFormTariff tariff = msl.get(tariffName);
                            if (tariff.showTariff) {
                                msl_suffix.put(tariffName, tariff);
                            }
                        }
                    }
                    System.debug(msl_suffix);
                    pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').value = '';

                } else if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.LegalDetails.name()).get(0)) {
                    // STEP LegalDetails
                    pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value = account.OGRN_ppr__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').value = account.OGRN_ppr__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_KPP__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = account.OKPO_ppr__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value = account.Code_Word__c;

                    // Legal address
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Legal_Address__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').value = account.BillingCountry;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').value = account.Region__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').value = account.BillingCity;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').value = formDataRecord.E2E_Billing_Str__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value = formDataRecord.E2E_Billing_House__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').value = account.BillingPostalCode;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Billing_Apartment__c;

                    // Postal address
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Post_Address__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').value = account.ShippingCountry;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STATE').value = formDataRecord.E2E_Shipping_State__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').value = account.ShippingCity;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').value = formDataRecord.E2E_Shipping_Str__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value = formDataRecord.E2E_Shipping_House__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').value = account.ShippingPostalCode;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Shipping_Apartment__c;

                    // set TRUE if Legal Address matches to Postal Address
                    if (formDataRecord.E2E_Legal_Address__c == formDataRecord.E2E_Post_Address__c && account.BillingCountry == account.ShippingCountry
                            && account.Region__c == formDataRecord.E2E_Shipping_State__c && account.BillingCity == account.ShippingCity
                            && formDataRecord.E2E_Billing_Str__c == formDataRecord.E2E_Shipping_Str__c && formDataRecord.E2E_Billing_House__c == formDataRecord.E2E_Shipping_House__c
                            && account.BillingPostalCode == account.ShippingPostalCode && formDataRecord.E2E_Billing_Apartment__c == formDataRecord.E2E_Shipping_Apartment__c) {
                        pagesMap.get('LEGAL DETAILS').fields.get('MATCHES LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = 'false';
                    }
                    else {pagesMap.get('LEGAL DETAILS').fields.get('MATCHES LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = 'true';}

                    String executiveFioWithPosition = formDataRecord.E2E_Executive_Person__c;
                    List<String> executiveProperties = executiveFioWithPosition.split(',');
                    if (executiveProperties != null && executiveProperties.size() == 2) {
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').value = executiveProperties.get(0);
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').value = executiveProperties.get(1);
                    } else if (executiveProperties != null && executiveProperties.size() == 1) {
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').value = executiveProperties.get(0);
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').value = '';
                    } else {
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').value = '';
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').value = '';
                    }

                    pagesMap.get('LEGAL DETAILS').fields.get('CHIEF ACCOUNTANT').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Chief_Accountant__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Personal_Office_Email__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('CARDS DELIVERY INFORMATION').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Courier_Comments__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT PHONE').elementItemsMap.get('DEFAULT VALUE').value = opportunity.Personal_office_phone__c;

                    // check manual entry
                    if (formDataRecord.E2E_Manual_Entry_Legal_Info__c == true) {
                        formParams.sendToInbound = true;
                    }

                } else if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.PaymentDetails.name()).get(0)) {
                    // STEP PaymentDetails
                    pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value = account.Checking_Account__c;
                    pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value = account.Bank__c;
                    pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value = account.SWIFT_BIC__c;
                    pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value = account.Cor_Bank_Account__c;
                    pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').value = formDataRecord.E2E_Prepay_Amount__c;

                    formParams.bankAddress = formDataRecord.E2E_Bank_Address__c;
                    formParams.bankNameShort = formDataRecord.E2E_Bank_Name_Short__c;
                    formParams.bankOkpo = formDataRecord.E2E_Bank_OKPO__c;
                    formParams.bankTown = formDataRecord.E2E_Bank_Town__c;
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : setAZSLocatorLink()
    *  Summary         : setAZSLocatorLink
    *  CreatedDate     : 28/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setAZSLocatorLink(String locator, Map<String, LongFormPage> pagesMap) {
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
        Matcher m = p.matcher(pagesMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').value);
        while (m.find()) {
            System.debug(m.group(1));
            prevHrefValue = m.group(1);
        }
        pagesMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').value = pagesMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').value.replace(prevHrefValue, linkLocator);
    }

    /*******************************************************************************
    *  Name            : parserExecutivePerson(String executivePerson)
    *  Summary         : parser executive person information
    *  CreatedDate     : 01/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String executivePerson
    *  Returns         : List<String> (1. executiveFio 2. executivePosition)
    ******************************************************************************/
    public List<String> parserExecutivePerson(String executivePerson) {
        String executiveFio = '';
        String executivePosition = '';
        if (executivePerson != null) {
            String executiveFioWithPosition = executivePerson;
            List<String> executiveProperties = executiveFioWithPosition.split(',');
            if (executiveProperties != null && executiveProperties.size() == 2) {
                executiveFio = executiveProperties.get(0);
                executivePosition = executiveProperties.get(1);
            } else if (executiveProperties != null && executiveProperties.size() == 1) {
                executiveFio = executiveProperties.get(0);
                executivePosition = '';
            }
        } else {
            executiveFio = '';
            executivePosition = '';
        }
        return new List<String>{
                executiveFio, executivePosition
        };
    }

    //******* Account Service *****//

    /*******************************************************************************
   *  Name            : createAccount(Map<String, LongFormPage> pagesMap, E2EFormParams formParams)
   *  Summary         : create account
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Map<String, LongFormPage> pagesMap
   *  Returns         : created account id
   ******************************************************************************/
    public Id createAccount(E2EFormParams formParams) {
        // New account
        Account account = new Account(
                RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Russian'),
                Name = 'E2E Account ' + Datetime.now().format('yyyyMMddHHmmss'),
                BillingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
                ShippingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
                Type = 'Customer',
                AccountSource = 'E2E Form RU',
                Utm_campaign__c = formParams.utmCampaign,
                Utm_content__c = formParams.utmContent,
                Utm_medium__c = formParams.utmMedium,
                Utm_source__c = formParams.utmSource,
                Utm_term__c = formParams.utmTerm,
                Utm_url__c = formParams.utmUrl,
                Lead_ID__c = formParams.leadId
        );
        return this.e2eFormRuDao.createAccount(account);
    }

    /*******************************************************************************
    *  Name            : updateAccount
    *  Summary         : Update Account for E2E Bussines
    *  CreatedDate     : 05/03/2019
    *  ModifiedDate    : 06/03/2019
    *  Parameters      : Id accountId, E2EFormParams formParams
    *  Returns         : -
    ******************************************************************************/
    public void updateAccount(Id accountId, E2EFormParams formParams) {
        Account account = new Account(Id = accountId);

        account.Name = GlobalUtils.blankStringIfNull(formParams.companyName);
        account.INN__c = GlobalUtils.blankStringIfNull(formParams.companyInn);

        account.OKPO_ppr__c = formParams.okpo;
        if (formParams.isSoleProprietor == true) {
            if (formParams.ogrn != '' && formParams.ogrn != null) {
                this.formDataValidator.validatePSRNField(formParams.ogrn);
            }
            account.OGRN_ppr__c = formParams.ogrn;
            account.Organization_Type__c = 'ИП';
        } else {
            if (formParams.ogrn != '' && formParams.ogrn != null) {
                this.formDataValidator.validatePSRNField(formParams.ogrn);
            }
            if (formParams.kpp != '' && formParams.kpp != null) {
                this.formDataValidator.validateKPPField(formParams.kpp);
            }
            account.OGRN_ppr__c = formParams.ogrn;
            String KPP = formParams.kpp;
            account.KPP__c = (KPP == '' || KPP == null) ? 0 : Decimal.valueOf(KPP);
            account.Organization_Type__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(1);
        }

        if (account.Organization_Type__c.equals('') || account.Organization_Type__c == null) account.Organization_Type__c = 'ОАО';


        if (formParams.codeWord != '' && formParams.codeWord != null) {
            this.formDataValidator.validateStringField(formParams.codeWord);
        }
        account.Code_Word__c = GlobalUtils.blankStringIfNull(formParams.codeWord);

        this.formDataValidator.isValidAddress(formParams.companyLegalAddressCountry, formParams.companyLegalAddressCity, formParams.companyLegalAddressState, formParams.companyLegalAddressStreet, formParams.companyLegalAddressPostalCode);
        this.formDataValidator.isValidAddress(formParams.postalAddressCountry, formParams.postalAddressCity, formParams.postalAddressStreet, formParams.postalAddressPostalCode);

        // legal address
        account.BillingCountry = GlobalUtils.blankStringIfNull(formParams.companyLegalAddressCountry);
        account.BillingCity = GlobalUtils.blankStringIfNull(formParams.companyLegalAddressCity);
        //VS SF-579
        List<String> listStreet = new List<String>();
        if (GlobalUtils.blankStringIfNull(formParams.companyLegalAddressStreet) != '') listStreet.add(formParams.companyLegalAddressStreet);
        if (GlobalUtils.blankStringIfNull(formParams.companyLegalAddressHouse) != '') listStreet.add('дом ' + formParams.companyLegalAddressHouse);
        if (GlobalUtils.blankStringIfNull(formParams.legalAddressAdditionally) != '') listStreet.add(formParams.legalAddressAdditionally);
        account.BillingStreet = String.join(listStreet, ', ');

        account.BillingPostalCode = GlobalUtils.blankStringIfNull(formParams.companyLegalAddressPostalCode);
        account.Region__c = GlobalUtils.blankStringIfNull(formParams.companyLegalAddressState);

        // postal address
        //VS SF-579
        if (formParams.isLegalAddressCorrespondWithPostAddress) {
            account.ShippingCountry = account.BillingCountry;
            account.ShippingCity = account.BillingCity;
            account.ShippingStreet = account.BillingStreet;
            account.ShippingPostalCode = account.BillingPostalCode;
        } else {
            account.ShippingCountry = GlobalUtils.blankStringIfNull(formParams.postalAddressCountry);
            account.ShippingCity = GlobalUtils.blankStringIfNull(formParams.postalAddressCity);

            listStreet = new List<String>();
            if (GlobalUtils.blankStringIfNull(formParams.postalAddressStreet) != '') listStreet.add(formParams.postalAddressStreet);
            if (GlobalUtils.blankStringIfNull(formParams.postalAddressHouse) != '') listStreet.add('дом ' + formParams.postalAddressHouse);
            if (GlobalUtils.blankStringIfNull(formParams.postalAddressAdditionally) != '') listStreet.add(formParams.postalAddressAdditionally);
            account.ShippingStreet = String.join(listStreet, ', ');

            account.ShippingPostalCode = GlobalUtils.blankStringIfNull(formParams.postalAddressPostalCode);
        }

        if (formParams.checkingAccount != '' && formParams.checkingAccount != null) {
            this.formDataValidator.validateCheckingAccount(formParams.checkingAccount);
        }
        if (formParams.bankNameShort != '') {
            this.formDataValidator.validateIsNotBlank(formParams.bankNameShort, 'bank');
        }
        if (formParams.corBankAccount != '' && formParams.corBankAccount != null) {
            this.formDataValidator.validateCheckingAccount(formParams.corBankAccount);
        }
        if (formParams.bankBic != '' && formParams.bankBic != null) {
            this.formDataValidator.validateBICField(formParams.bankBic);
        }

        // bank info
        account.Checking_Account__c = GlobalUtils.blankStringIfNull(formParams.checkingAccount);
        account.Bank__c = GlobalUtils.blankStringIfNull(formParams.bankNameShort);
        account.SWIFT_BIC__c = GlobalUtils.blankStringIfNull(formParams.bankBic);
        account.Cor_Bank_Account__c = GlobalUtils.blankStringIfNull(formParams.corBankAccount);

        // In E2E Business process set special marker SF-864
        if (GlobalUtils.BusinessProcessType.E2EBusiness.name().equals(formParams.businessProcess)) account.Modified_in_E2E_Business__c = true;

        this.e2eFormRuDao.updateAccount(account);
    }

    /*******************************************************************************
   *  Name            : updateAccount(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step)
   *  Summary         : update account
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step
   *  Returns         : -
   ******************************************************************************/
    public void updateAccount(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);
        Account account = new Account(Id = accountId);
        account.Lead_ID__c = formParams.leadId;

        if (activeStep == GlobalUtils.E2ERuSteps.CompanyInformation) {
            String accountName = pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value;
            String INN = pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value;
            Boolean isEntryManual = Boolean.valueOf(pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').value);

            this.formDataValidator.validateAccountNameField(accountName);
            if (!isEntryManual) {
                this.formDataValidator.validateInnField(INN);
            }

            account.Name = GlobalUtils.blankStringIfNull(accountName);
            if (formParams.verifiedDecisionCode != '4') { // костыль чтобы не сохранять INN
                account.INN__c = GlobalUtils.blankStringIfNull(INN);
            }

            // Save Address
            account.BillingPostalCode = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
            account.BillingCity = GlobalUtils.blankStringIfNull(formParams.citySpark);
            String street = formParams.streetSpark == null ? '' : GlobalUtils.blankStringIfNull(formParams.streetSpark);
            String building = formParams.buildingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.buildingSpark);
            String housing = formParams.housingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.housingSpark);
            String block = formParams.blockSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.blockSpark);
            String room = formParams.roomSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.roomSpark);
            account.BillingStreet = street + building + housing + block + room;
            account.Region__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);

            // Save OKPO
            account.OKPO_ppr__c = formParams.okpoSpark;

            // Save OGRN, KPP, Organization Type
            if (formParams.isSoleProprietor == true) {
                account.OGRN_ppr__c = formParams.ogrnipSpark;
                account.Organization_Type__c = 'ИП';
            } else {
                account.OGRN_ppr__c = formParams.ogrnSpark;
                String KPP = formParams.kppSpark;
                account.KPP__c = (KPP == '' || KPP == null) ? 0 : Decimal.valueOf(KPP);
                account.Organization_Type__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(1);
            }

            // Update
            this.e2eFormRuDao.updateAccount(account);
        } else if (activeStep == GlobalUtils.E2ERuSteps.LegalDetails) {

            if (formParams.isSoleProprietor) {
                String OGRNIP = pagesMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').value;
                this.formDataValidator.validatePSRNField(OGRNIP);
                account.OGRN_ppr__c = GlobalUtils.blankStringIfNull(OGRNIP);
            } else {
                String OGRN = pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value;
                String KPP = pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value;
                this.formDataValidator.validatePSRNField(OGRN);
                this.formDataValidator.validateKPPField(KPP);
                account.OGRN_ppr__c = GlobalUtils.blankStringIfNull(OGRN);
                account.KPP__c = Decimal.valueOf(KPP);
            }

            String OKPO = pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value;
            String codeWord = pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value;

            String legalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').value;
            String legalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').value + ' ' +
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value + ' ' +
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
            String legalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').value;
            String legalAddressState = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').value;
            String legalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').value;

            String postalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').value;
            String postalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').value + ' ' +
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value + ' ' +
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
            String postalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').value;
            String postalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').value;

            this.formDataValidator.validateOKPOField(OKPO);
            this.formDataValidator.validateStringField(codeWord);

            account.OKPO_ppr__c = GlobalUtils.blankStringIfNull(OKPO);
            account.Code_Word__c = GlobalUtils.blankStringIfNull(codeWord);


            if (!this.formDataValidator.isValidAddress(legalAddressCountry, legalAddressCity, legalAddressState, legalAddressStreet, legalAddressPostalCode) ||
                    !this.formDataValidator.isValidAddress(postalAddressCountry, postalAddressCity, postalAddressStreet, postalAddressPostalCode)) {
                formParams.sendToInbound = true;
            }

            // legal address
            account.BillingCountry = GlobalUtils.blankStringIfNull(legalAddressCountry);
            account.BillingCity = GlobalUtils.blankStringIfNull(legalAddressCity);
            account.BillingStreet = GlobalUtils.blankStringIfNull(legalAddressStreet);
            account.BillingPostalCode = GlobalUtils.blankStringIfNull(legalAddressPostalCode);
            account.Region__c = GlobalUtils.blankStringIfNull(legalAddressState);

            // postal address
            account.ShippingCountry = GlobalUtils.blankStringIfNull(postalAddressCountry);
            account.ShippingCity = GlobalUtils.blankStringIfNull(postalAddressCity);
            account.ShippingStreet = GlobalUtils.blankStringIfNull(postalAddressStreet);
            account.ShippingPostalCode = GlobalUtils.blankStringIfNull(postalAddressPostalCode);

            this.e2eFormRuDao.updateAccount(account);
        } else if (activeStep == GlobalUtils.E2ERuSteps.PaymentDetails) {
            String checkingAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value;
            String bank = pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value;
            String BIC = pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value;
            String corBankAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value;

            this.formDataValidator.validateCheckingAccount(checkingAccount);
            this.formDataValidator.validateIsNotBlank(bank, 'bank');
            this.formDataValidator.validateCheckingAccount(corBankAccount);
            this.formDataValidator.validateBICField(BIC);

            account.Checking_Account__c = GlobalUtils.blankStringIfNull(checkingAccount);
            account.Bank__c = GlobalUtils.blankStringIfNull(bank);
            account.SWIFT_BIC__c = GlobalUtils.blankStringIfNull(BIC);
            account.Cor_Bank_Account__c = GlobalUtils.blankStringIfNull(corBankAccount);

            this.e2eFormRuDao.updateAccount(account);
        }
    }

    /*******************************************************************************
   *  Name            : getAccountById(Id accountId)
   *  Summary         : get account by id
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id accounts
   *  Returns         : account id
   ******************************************************************************/
    public Account getAccountById(Id accountId) {
        return this.e2eFormRuDao.getAccountById(accountId);
    }

    /*******************************************************************************
    *  Name            : deleteAccountById(Id accountId)
    *  Summary         : get account by id
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Id accounts
    *  Returns         : account id
    ******************************************************************************/
    public static void deleteAccountById(Id accountId) {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();
        e2eFormRuDao.deleteAccount(e2eFormRuDao.getAccountById(accountId));
    }


    //******* Contact Service *****//

    /*******************************************************************************
   *  Name            : createContact(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams,
   *                  : GlobalUtils.BusinessProcessType businessProcessType)
    *  Summary         : create contact
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : 25/07/2018
   *  Parameters      : Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams,
   *                  : GlobalUtils.BusinessProcessType businessProcessType
    *  Returns         : created contact id
    ******************************************************************************/
    public Id createContact(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, GlobalUtils.BusinessProcessType businessProcessType) {
        if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EClassic)) {
            System.debug('******* E2E CLASSIC PROCESS createContact *******');
            String phone = pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value;
            String convertedPhone = convertPhone(phone);
            String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
            String sendMarketingEmail = pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').value;
            String processPersonalInformation = pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value;

            this.formDataValidator.validateMobilePhone(convertedPhone);
            this.formDataValidator.validateEmail(email);
            this.formDataValidator.validateBooleanField(sendMarketingEmail);
            this.formDataValidator.validateBooleanField(processPersonalInformation);

            // New contact
            Contact contact = new Contact(
                    RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
                    Salutation = 'Mr.',
                    LeadSource = 'E2E Form RU',
                    AccountId = accountId,
                    FirstName = 'Contact ' + Datetime.now().format('yyyyMMddHHmmss'),
                    LastName = 'E2E',
                    Phone = convertedPhone,
                    Agree_to_receive_comm_info_by_email__c = Boolean.valueOf(sendMarketingEmail),
                    Agree_to_process_pers_data_for_marketing__c = Boolean.valueOf(processPersonalInformation),
                    Utm_campaign__c = formParams.utmCampaign,
                    Utm_content__c = formParams.utmContent,
                    Utm_medium__c = formParams.utmMedium,
                    Utm_source__c = formParams.utmSource,
                    Utm_term__c = formParams.utmTerm,
                    Utm_url__c = formParams.utmUrl
            );

            if (Boolean.valueOf(processPersonalInformation)) {
                contact.Email = email;
            }
			return this.e2eFormRuDao.createContact(contact);
			/*
            //SF-975
            Id createdConId = this.e2eFormRuDao.createContact(contact);
            try {  
                PD_Callouts.sendReq_saveData(contact);
            } catch (Exception e) {
                System.debug('******* CREATE CONTACT: PD_Callouts.sendReq_saveData got an exception: ' + String.valueOf(e.getMessage()));
            }
            return createdConId;
			*/
        } else if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EBusiness)) {
            System.debug('*******E2E BUSINESS PROCESS createContact ********');
            String mainContactPhone = convertPhone(formParams.mainContactPhone);
            String mainContactEmail = formParams.mainContactEmail;
            if (mainContactPhone != '') {
                this.formDataValidator.validateMobilePhone(mainContactPhone);
            }
            if (mainContactEmail != '') {
                this.formDataValidator.validateEmail(mainContactEmail);
            }

            // New contact
            Contact contact = new Contact(
                    RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
                    Salutation = 'Mr.',
                    AccountId = accountId,
                    FirstName = 'Contact ' + Datetime.now().format('yyyyMMddHHmmss'),
                    LastName = 'E2E Business',
                    Phone = mainContactPhone,
                    Email = formParams.mainContactEmail,
                    Modified_in_E2E_Business__c = true     // In E2E Business process set special marker SF-864
            );

            if (String.isNotBlank(formParams.emailForPersonalOffice) && !formParams.emailForPersonalOffice.equals(formParams.mainContactEmail)) {
                this.formDataValidator.validateEmail(formParams.emailForPersonalOffice);
                contact.Additional_Emails__c = formParams.emailForPersonalOffice;
            }

            return this.e2eFormRuDao.createContact(contact);
        } else if (businessProcessType.equals(GlobalUtils.BusinessProcessType.PPR_API)) {
            System.debug('*******PPR API PROCESS createContact ********');

            // New contact
            Contact contact = new Contact(
                    RecordTypeId = ContactTriggerHandler.contactRecordTypes.get(
                            GlobalUtils.ContactRecordTypes.Russian.name()
                    ).recordTypeId,
                    Salutation = 'Mr.',
                    AccountId = accountId,
                    FirstName = 'Contact ' + Datetime.now().format('yyyyMMddHHmmss'),
                    LastName = 'PPR API',
                    Phone = formParams.mainContactPhone,
                    Email = formParams.mainContactEmail
            );

            return this.e2eFormRuDao.createContact(contact);
        } else {
            throw new E2EFormRuException('The business process type is neither E2E Classic nor E2E Business');
        }

    }



    /*******************************************************************************
    *  Name            : createEmployeeContact(Id accountId, String employeeFio, String title)
    *  Summary         : create contact if its does not exists, which related to employee
    *  CreatedDate     : 27/08/2018
    *  Parameters      : Id accountId, String employeeFio, String title
    *  Returns         : created contact id
    ******************************************************************************/
    public Id createEmployeeContact(Id accountId, String employeeFio, String title, String businessProcessType) {
        this.formDataValidator.validateIsNotBlank(employeeFio, 'employeeFio');
        this.formDataValidator.validateIsNotBlank(title, 'title');

        // Check existing contact with this fio as LastName
        Contact existingContact = null;
        List<Contact> listContacts = this.e2eFormRuDao.getContactsByLastName(employeeFio, accountId);
        if (listContacts.size() != 0) {
            existingContact = listContacts.get(0);
        }

        if (existingContact == null) {
            Contact employee = new Contact(
                    RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
                    Salutation = 'Mr.',
                    LeadSource = 'E2E Form RU',
                    AccountId = accountId,
                    LastName = employeeFio,
                    Title = title
            );
            // In E2E Business process set special marker SF-864
            if (GlobalUtils.BusinessProcessType.E2EBusiness.name().equals(businessProcessType)) employee.Modified_in_E2E_Business__c = true;
			/*
            //SF-975
            Id createdConId = this.e2eFormRuDao.createContact(employee);
            try {  
                if (GlobalUtils.BusinessProcessType.E2EClassic.name().equals(businessProcessType)) PD_Callouts.sendReq_saveData(employee);
            } catch (Exception e) {
                System.debug('******* CREATE EMPLOYEE CONTACT: PD_Callouts.sendReq_saveData got an exception: ' + String.valueOf(e.getMessage()));
            }
            return createdConId;
			*/
			return this.e2eFormRuDao.createContact(employee);
        } else {
            return existingContact.Id;
        }
    }

    /*******************************************************************************
    *  Name            : updateContact
    *  Summary         : Update Contact for E2E Bussines
    *  CreatedDate     : 05/03/2019
    *  ModifiedDate    : 06/03/2019
    *  Parameters      : Contact contact, E2EFormParams formParams
    *  Returns         : -
    ******************************************************************************/
    public void updateContact(Contact contact, E2EFormParams formParams) {
        String convertedPhone = convertPhone(formParams.mainContactPhone);
        this.formDataValidator.validateMobilePhone(convertedPhone);
        this.formDataValidator.validateEmail(formParams.mainContactEmail);
        if (String.isNotBlank(formParams.emailForPersonalOffice) && !formParams.emailForPersonalOffice.equals(formParams.mainContactEmail)) {
            this.formDataValidator.validateEmail(formParams.emailForPersonalOffice);
            if(String.isBlank(contact.Additional_Emails__c)) {
                contact.Additional_Emails__c = formParams.emailForPersonalOffice;
            } else {
                String separator = ':';
                Set<String> uniqueEmails = new Set<String>(contact.Additional_Emails__c.split(separator));
                uniqueEmails.add(formParams.emailForPersonalOffice);
                contact.Additional_Emails__c = String.join(new List<String>(uniqueEmails), separator);
            }
        }

        contact.Phone = convertedPhone;
        contact.Email = formParams.mainContactEmail;
        // In E2E Business process set special marker SF-864
        if (GlobalUtils.BusinessProcessType.E2EBusiness.name().equals(formParams.businessProcess)) contact.Modified_in_E2E_Business__c = true;
        this.e2eFormRuDao.updateContact(contact);
    }

    /*******************************************************************************
    *  Name            : updateProfileEmailForContact
    *  Summary         : Replace old user account email with new one in Additional_emails__c filed for Contact
    *  CreatedDate     : 18/01/2020
    *  ModifiedDate    : -
    *  Parameters      : Id contactId, Id formDataId, String email
    *  Returns         : -
    ******************************************************************************/
    public void updateProfileEmailForContact(Id contactId, Id formDataId, String email) {
        Contact contact = this.e2eFormRuDao.getContactById(contactId);
        E2EFormData__c formData = this.e2eFormRuDao.getFormDataById(formDataId);
        if (formData != null && contact != null && !email.equals(contact.Email)) {
            this.formDataValidator.validateEmail(email);
            if (String.isBlank(contact.Additional_Emails__c)) {
                contact.Additional_Emails__c = email;
            } else {
                String separator = ':';
                Set<String> uniqueEmails = new Set<String>(contact.Additional_Emails__c.split(separator));
                uniqueEmails.add(email);
                if (!email.equals(formData.E2E_Personal_Office_Email__c)) {
                    uniqueEmails.remove(formData.E2E_Personal_Office_Email__c);
                }
                contact.Additional_Emails__c = String.join(new List<String>(uniqueEmails), separator);
            }
            this.e2eFormRuDao.updateContact(contact);
        }
    }

    /*******************************************************************************
   *  Name            : updateContact(Id contactId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step)
   *  Summary         : update contact
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : 25/07/2018
   *  Parameters      : Id contactId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step
   *  Returns         : -
   ******************************************************************************/
    public void updateContact(Id contactId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);
        Contact contact = new Contact(Id = contactId);
        if (activeStep == GlobalUtils.E2ERuSteps.ContactDetails) {
            String convertedPhone = convertPhone(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value);
            String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
            String sendMarketingEmail = pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').value;
            String processPersonalInformation = pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value;

            this.formDataValidator.validateMobilePhone(convertedPhone);
            this.formDataValidator.validateEmail(email);
            this.formDataValidator.validateBooleanField(sendMarketingEmail);
            this.formDataValidator.validateBooleanField(processPersonalInformation);

            contact.Phone = convertedPhone;
            contact.Agree_to_receive_comm_info_by_email__c = Boolean.valueOf(sendMarketingEmail);
            contact.Agree_to_process_pers_data_for_marketing__c = Boolean.valueOf(processPersonalInformation);

            if (Boolean.valueOf(processPersonalInformation)) {
                contact.Email = email;
            }

            this.e2eFormRuDao.updateContact(contact);
			/*
            //SF-975
            try {  
                PD_Callouts.sendReq_saveData(contact);
            } catch (Exception e) {
                System.debug('******* CREATE CONTACT: PD_Callouts.sendReq_saveData got an exception: ' + String.valueOf(e.getMessage()));
            }        
			*/
        }
    }

    /*******************************************************************************
    *  Name            : updateEmployeeContact(Id contactId, String employeeFio, String title)
    *  Summary         : update contact
    *  CreatedDate     : 27/08/2018
    *  ModifiedDate    : 04/10/2018
    *  Parameters      : Id contactId, String employeeFio, String title
    *  Returns         : -
    ******************************************************************************/
    public void updateEmployeeContact(Id contactId, String employeeFio, String title, String businessProcessType) {
        System.debug('******* Employee Contact: ' + employeeFio + ', title: ' + title);
        this.formDataValidator.validateIsNotBlank(employeeFio, 'employeeFio');
        this.formDataValidator.validateIsNotBlank(title, 'title');

        if (contactId != null) {
            Contact employee = new Contact(
                    Id = contactId,
                    LastName = employeeFio,
                    Title = title,
                    PD_Avaliable_LastName_Update__c = true
            );
            // In E2E Business process set special marker SF-864
            if (GlobalUtils.BusinessProcessType.E2EBusiness.name().equals(businessProcessType)) employee.Modified_in_E2E_Business__c = true;
            this.e2eFormRuDao.updateContact(employee);
			/*
            //SF-975
            try {
                if (GlobalUtils.BusinessProcessType.E2EClassic.name().equals(businessProcessType)) PD_Callouts.sendReq_saveData(employee);
            } catch (Exception e) {
                System.debug('******* UPDATE EMPLOYEE CONTACT: PD_Callouts.sendReq_saveData got an exception: ' + String.valueOf(e.getMessage()));
            }     
			*/
        } else {
            System.debug('******* UPDATE EMPLOYEE CONTACT: contactId is null.');
        }
    }

    /*******************************************************************************
    *  Name            : updateContactPhone(Id contactId, String phone)
    *  Summary         : update contact phone
    *  CreatedDate     : 16/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Id contactId, String email
    *  Returns         : -
    ******************************************************************************/
    public void updateContactPhone(Id contactId, String phone) {
        String currentPhone = convertPhone(phone);
        this.formDataValidator.validateMobilePhone(currentPhone);
        Contact employee = new Contact(
                Id = contactId,
                Phone = currentPhone
        );
        this.e2eFormRuDao.updateContact(employee);
        /*
        //SF-975
        try {  
            PD_Callouts.sendReq_saveData(employee);
        } catch (Exception e) {
            System.debug('******* CREATE CONTACT: PD_Callouts.sendReq_saveData got an exception: ' + String.valueOf(e.getMessage()));
        } 
		*/
    }

    /*******************************************************************************
    *  Name            : update(Id contactId, String phone)
    *  Summary         : update s
    *  CreatedDate     : 16/04/2020
    *  ModifiedDate    : -
    *  Parameters      : Id contactId, String email
    *  Returns         : -
    ******************************************************************************/
    public void updSObjects (String objectName, List<SObject> sObjectList) {
        this.e2eFormRuDao.updSObjects(objectName, sObjectList);
    }

    /*******************************************************************************
   *  Name            : getContactById(Id contactId)
   *  Summary         : get contact by id
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id contact
   *  Returns         : contact id
   ******************************************************************************/
    public Contact getContactById(Id contactId) {
        return this.e2eFormRuDao.getContactById(contactId);
    }

    //******* Opportunity Service *****//

    /*******************************************************************************
    *  Name            : createOpportunity(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams)
    *  Summary         : create opportunity
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<String, LongFormPage> pagesMap
    *  Returns         : created opportunity id
    ******************************************************************************/
    public Id createOpportunity(Id accountId, E2EFormParams formParams) {
        // New opportunity
        // if(formParams.sourceIfSelfSourced == ''){
        //     formParams.sourceIfSelfSourced = 'E2E Form RU';
        // }

        Opportunity opportunity = new Opportunity(
                Business_process__c = formParams.businessProcess,
                Name = 'E2E Opportunity ' + Datetime.now().format('yyyyMMddHHmmss'),
                CategoryContract__c = GlobalUtils.getContractType('MultiOffer'),
                StageName = 'Qualified Lead',
                AccountId = accountId,
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
                Utm_campaign__c = formParams.utmCampaign,
                Utm_content__c = formParams.utmContent,
                Utm_medium__c = formParams.utmMedium,
                Utm_source__c = formParams.utmSource,
                Utm_term__c = formParams.utmTerm,
                Utm_url__c = formParams.utmUrl,
                Utm_ip__c = formParams.utmIp,
                Utm_region__c = formParams.utmRegion,
                Website_Page_Form__c = formParams.websitePageForm,
                Promo_campaign__c = formParams.promoCode,
                Client_Id__c = formParams.clientId
        );
        return e2eFormRuDao.createOpportunity(opportunity);
    }

    /*******************************************************************************
    *  Name            : updateOpportunity
    *  Summary         : Update Opportunity for E2E Bussines
    *  CreatedDate     : 05/03/2019
    *  ModifiedDate    : 06/03/2019
    *  Parameters      : Id opportunityId, E2EFormParams formParams
    *  Returns         : -
    ******************************************************************************/
    public void updateOpportunityStage(Id opportunityId, String stageName) {
        Opportunity opportunity = new Opportunity(Id = opportunityId);

        opportunity.StageName = stageName;
        this.e2eFormRuDao.updateOpportunity(opportunity);
    }

    /*******************************************************************************
    *  Name            : updateOpportunity
    *  Summary         : Update Opportunity for E2E Bussines
    *  CreatedDate     : 05/03/2019
    *  ModifiedDate    : 06/03/2019
    *  Parameters      : Id opportunityId, E2EFormParams formParams
    *  Returns         : -
    ******************************************************************************/
    public void updateOpportunity(Id opportunityId, E2EFormParams formParams) {
        Opportunity opportunity = new Opportunity(Id = opportunityId);

        this.formDataValidator.validateIsNotBlank(formParams.companyName, 'accountName');
        this.formDataValidator.validateNumberOfCards(String.valueOf(formParams.numOfCards));

        opportunity.Name = formParams.companyName;
        opportunity.Product_PPR__c = formParams.product;
        opportunity.Number_of_Cards__c = Integer.valueOf(formParams.numOfCards);
        opportunity.Promo_campaign__c = formParams.promoCode;
        opportunity.Business_process__c = GlobalUtils.changeIfHasNewValue(opportunity.Business_process__c, formParams.businessProcess);
        //VS SF-1429
        opportunity.PPR_Electronic_document_management__c = formParams.electronicDocumentManagement;
        opportunity.Virtual_cards__c = formParams.virtualCards;
        opportunity.Personal_office_phone__c = formParams.personalOfficePhone;
        System.debug('______: ' + opportunity.Virtual_cards__c);
        System.debug('______: ' + formParams.virtualCards);
        this.e2eFormRuDao.updateOpportunity(opportunity);
    }

    /*******************************************************************************
   *  Name            : updateOpportunity(Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step)
   *  Summary         : update opportunity
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : 25/07/2018
   *  Parameters      : Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step
   *  Returns         : -
   ******************************************************************************/
    public void updateOpportunity(Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);
        Opportunity opportunity = new Opportunity(Id = opportunityId);
        opportunity.E2E_Status__c = 'Клиент Активен';
        if (activeStep == GlobalUtils.E2ERuSteps.CompanyInformation) {
            String accountName = pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value;
            String isEntryManual = pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').value;

            this.formDataValidator.validateIsNotBlank(accountName, 'accountName');
            this.formDataValidator.validateBooleanField(isEntryManual);

            opportunity.Name = accountName;
            opportunity.Manual_Entry__c = Boolean.valueOf(isEntryManual);
            if (formParams.scoringDate != null) {
                opportunity.Scoring_Date__c = formParams.scoringDate;
                opportunity.Scoring_Expiration_Date__c = formParams.scoringDate.addMonths(3);
            }

            // Set field E2E_Sub_Status__c 'Чёрный список' or 'Дедубликация'
            if (formParams.verifiedDecisionCode != null) {
                if (formParams.verifiedDecisionCode == '3' || formParams.scoringDecisionCode == '2') {
                    opportunity.E2E_Sub_Status__c = 'Чёрный список';
                    opportunity.E2E_Sales_Type__c = 'Отклонен';
                    opportunity.StageName = 'Отказ';
                    opportunity.PPR_Lost_Reasons__c = formParams.opportunityLostReason;
                    opportunity.E2E_Status__c = 'Клиент завершил';
                }
            }

            if (formParams.deduplicationStatus != null) {
                if (formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.Service.name() || formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.KO.name()) {
                    opportunity.E2E_Sub_Status__c = 'Дедубликация';
                    opportunity.E2E_Sales_Type__c = 'Отклонен';
                }
            }
        } else if (activeStep == GlobalUtils.E2ERuSteps.Order) {
            String product = pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value;
            String tariff = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value;
            String tariffId = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value;
            String numberOfCards = pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value;
            String promoCode = pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value == null ? '' : pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value;

            this.formDataValidator.validateIsNotBlank(product, 'product');
            this.formDataValidator.validateNumberOfCards(numberOfCards);
            this.formDataValidator.validateIsNotBlank(tariff, 'tariff');
            this.formDataValidator.validateIsNotBlank(tariffId, 'tariffId');

            Integer numberOfCardsWithFeeCards = Integer.valueOf(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Number_of_Cards_Card__c);
            String productResult = '';
            if (product == GlobalUtils.E2EProduct.PetrolPlus_Rover.name()) {
                productResult = GlobalUtils.getE2EProduct(product) + ' "' + tariff + '" ';
                if (Integer.valueOf(numberOfCards) < numberOfCardsWithFeeCards) {
                    productResult += 'Карты';
                } else {
                    productResult += 'Договор';
                }
            } else if (product == GlobalUtils.E2EProduct.PetrolPlus_Gaz.name()) {
                productResult = GlobalUtils.getE2EProduct(product) + ' – сеть АЗС ';
                if (tariff.equals('Тариф 1')) {
                    productResult += 'Карты';
                } else if (tariff.equals('Тариф 2')) {
                    productResult += 'Договор';
                }
            } else {
                productResult = GlobalUtils.getE2EProduct(product) + ' ' + tariff;
            }

            opportunity.Product_PPR__c = productResult;
            opportunity.Promo_campaign__c = promoCode;
            opportunity.Number_of_Cards__c = Integer.valueOf(numberOfCards);
            opportunity.StageName = 'Agreement Terms and Conditions';

        } else if (activeStep == GlobalUtils.E2ERuSteps.LegalDetails) {
            opportunity.Personal_office_phone__c = formParams.personalOfficePhone;
                     
        } else if (activeStep == GlobalUtils.E2ERuSteps.PaymentDetails) {
            //SF-637
            if (formParams.sendToInbound == true) {
                opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
            }
        } else if (activeStep == GlobalUtils.E2ERuSteps.Congratulations) {
            opportunity.E2E_Status__c = 'Клиент завершил';
        }

        //SF-637
        //if (formParams.sendToInbound == true) {
        //    opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
        //}
        opportunity.Business_process__c = GlobalUtils.changeIfHasNewValue(opportunity.Business_process__c, formParams.businessProcess);
        opportunity.E2E_Encoded_URL__c = formParams.encodedURL;
        opportunity.E2E_Active_Substep__c = GlobalUtils.getE2ESteps(step);
        opportunity.E2E_Last_Activity__c = Datetime.now();
        opportunity.Client_Id__c = formParams.clientId;

        this.e2eFormRuDao.updateOpportunity(opportunity);
    }

    public void forceUpdateOpportunity(Id opportunityId, String error) {
        try {
            if (opportunityId != null) {
                Opportunity opportunity = new Opportunity(Id = opportunityId);
                opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
                opportunity.Business_process__c = GlobalUtils.BusinessProcessType.Standard.name();
                opportunity.E2E_Errors__c = error;
                opportunity.E2E_Last_Activity__c = Datetime.now();
                this.e2eFormRuDao.updateOpportunity(opportunity);

                //Send email notifications
                E2E_RU_Internal_Notifications.forceUpdateOpportunity(opportunity.Id);
            } else {
                String notificationMessage = '<br/>E2E method forceUpdateOpportunity(): opportunityId == null ';
                ExceptionLogger.sendException(notificationMessage, '');
            }
        } catch (E2EFormRuException e) {
            String notificationMessage = '<br/>E2E method forceUpdateOpportunity(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    public class updateOpportunityQueueable implements Queueable {
        public Opportunity opportunity;
        public String updateCase;

        public updateOpportunityQueueable(Opportunity opp, String uCase) {
            opportunity = opp;
            updateCase = uCase;
        }

        public void execute(QueueableContext param1) {
            try {
                E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();
                if (updateCase == 'firstFormUrl') {
                    Opportunity currentOpportunity = e2eFormRuDao.getOpportunityById(opportunity.Id);
                    if (currentOpportunity.E2E_Encoded_URL__c == null) {
                        e2eFormRuDao.updateOpportunity(opportunity);
                    }
                }
            } catch (Exception e) {
                ExceptionLogger.sendException('<br/>E2E updateOpportunityQueueable: ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
        }
    }

    /*******************************************************************************
   *  Name            : getOpportunityById(Id opportunityId)
   *  Summary         : get opportunity by id
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id opportunityId
   *  Returns         : opportunity id
   ******************************************************************************/
    public Opportunity getOpportunityById(Id opportunityId) {
        return this.e2eFormRuDao.getOpportunityById(opportunityId);
    }

    //****** OpportunityContactRole Service *****//

    /*******************************************************************************
    *  Name            : createOpportunityContactRoles(Id opportunityId, Id accountId, Map<String, LongFormPage> pagesMap, String step)
    *  Summary         : create OpportunityContactRole
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Id opportunityId, Id accountId, Map<String, LongFormPage> pagesMap, String step
    *  Returns         : void
    ******************************************************************************/
//    public void createOpportunityContactRoles(Id opportunityId, Id accountId, Map<String, LongFormPage> pagesMap, String step) {
//        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);
//        if (activeStep == GlobalUtils.E2ERuSteps.LegalDetails) {
//            List<Contact> contactList = new List<Contact>();
//            String executivePerson = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').value;
//            String executivePersonTitle = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').value;
//            String chiefAccountant = pagesMap.get('LEGAL DETAILS').fields.get('CHIEF ACCOUNTANT').elementItemsMap.get('DEFAULT VALUE').value;
//
//            this.formDataValidator.validateStringField(executivePerson);
//            this.formDataValidator.validateStringField(executivePersonTitle);
//            this.formDataValidator.validateStringField(chiefAccountant);
//
//            // Executive Person
//            Contact executivePersonContact = new Contact(
//                    RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
//                    Salutation = 'Mr.',
//                    AccountId = accountId,
//                    LastName = executivePerson,
//                    Title = executivePersonTitle
//            );
//            contactList.add(executivePersonContact);
//
//            // Chief Accountant
//            Contact chiefAccountantContact = new Contact(
//                    RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
//                    Salutation = 'Mr.',
//                    AccountId = accountId,
//                    LastName = chiefAccountant,
//                    Title = 'Главный бухгалтер'
//            );
//            contactList.add(chiefAccountantContact);
//
//            // create OpportunityContactRole
//            this.e2eFormRuDao.createContacts(contactList);
//
//            List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
//            OpportunityContactRole executivePersonRole = this.e2eFormRuDao.getOpportunityContactRole(contactList.get(0).Id, opportunityId);
//            executivePersonRole.Role = 'Decision Maker';
//            opportunityContactRoles.add(executivePersonRole);
//            OpportunityContactRole chiefAccountantRole = this.e2eFormRuDao.getOpportunityContactRole(contactList.get(1).Id, opportunityId);
//            chiefAccountantRole.Role = 'Accounting (for invoices)';
//            opportunityContactRoles.add(chiefAccountantRole);
//
//            // update OpportunityContactRole
//            this.e2eFormRuDao.updateOpportunityContactRole(opportunityContactRoles);
//        }
//    }

    /*******************************************************************************
    *  Name            : createOpportunityContactRoles(Id opportunityId, Id accountId, String role, Boolean isPrimary)
    *  Summary         : creates OpportunityContactRole
    *  CreatedDate     : 06.04.2020
    *  ModifiedDate    : -
    *  Parameters      : Id opportunityId, Id accountId, String role, Boolean isPrimary
    *  Returns         : void
    ******************************************************************************/
    public void createOpportunityContactRole(Id opportunityId, Id contactId, String role, Boolean isPrimary) {
        this.e2eFormRuDao.createOpportunityContactRole(new List<OpportunityContactRole>{
                new OpportunityContactRole(
                        OpportunityId = opportunityId,
                        ContactId = contactId,
                        Role = role,
                        IsPrimary = isPrimary
                )
        });
    }

    /*******************************************************************************
    *  Name            : updateOpportunityContactRole
    *  Summary         : update OpportunityContactRole
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Id opportunityId, Id accountId, String role - OpportunityContactRole
    *  Returns         : void
    ******************************************************************************/
    public static void updateOpportunityContactRole(Id opportunityId, Id contactId, String role, Boolean isPrimary) {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();
        List<OpportunityContactRole> opportunityContactRoles = e2eFormRuDao.getOpportunityContactRoles(contactId, opportunityId);
        if (opportunityContactRoles != null && !opportunityContactRoles.isEmpty()) {
            OpportunityContactRole opportunityContactRole = opportunityContactRoles.get(0);
            opportunityContactRole.Role = role;
            opportunityContactRole.IsPrimary = isPrimary;
            e2eFormRuDao.updateOpportunityContactRole(new List<OpportunityContactRole>{
                    opportunityContactRole
            });
        }
    }

    //******* Document Service *****//

    /*******************************************************************************
    *  Name            : createDocument(String name, Blob content, String contentType, Id folderId)
    *  Summary         : create document
    *  CreatedDate     : 24/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String name, Blob content, String contentType, Id folderId
    *  Returns         : created document id
    ******************************************************************************/
    public Id createDocument(String name, Blob content, String contentType, Id folderId) {
        Document document = new Document(
                Name = name,
                FolderId = folderId,
                Body = content,
                ContentType = contentType,
                IsPublic = false,
                Type = 'pdf'
        );
        return this.e2eFormRuDao.createDocument(document);
    }

    //******** Report Service Integration ******//

    public ReportRequestData prepareReportRequestData(E2EFormParams formParams, Boolean preview, GlobalUtils.BusinessProcessType businessProcessType) {
        E2E_Form_Ru_General_Settings__c generalSettings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        if (generalSettings == null) {
            throw new E2EFormRuException('Error: prepareReportRequestData(); E2E_Form_Ru_General_Settings__c does not found');
        }
        ReportRequestData requestData = new ReportRequestData();
        requestData.reportParams = new ReportRequestData.ReportParams();

        requestData.inn = formParams.companyInn;
        System.debug('mainCompanyFullNameSpark - ' + formParams.mainCompanyFullNameSpark);
        System.debug('formParams.opportunityId - ' + formParams.opportunityId);
        //VS SF-699
        requestData.companyName = formParams.isSoleProprietor ? formParams.mainCompanyFullNameSpark : GlobalUtils.createOrganiozationName(formParams.normName);
        requestData.sFRequestId = formParams.opportunityId;
        requestData.hasPersonalManager = formParams.hasPersonalManager;
        requestData.hasExpressDelivery = formParams.hasDocumentDelivery;
        requestData.preview = preview;
        requestData.amount = Integer.valueOf(formParams.prepayAmount);

        requestData.bikBank = formParams.bankBic;

        if (formParams.source != null && formParams.source != '') {
            requestData.specPartner = true;
        } else {
            requestData.specPartner = false;
        }

        if (generalSettings.Send_Contract_To_Client__c == true && formParams.sendToInbound == false && preview == false) {
            requestData.mailList = new List<String>{
                    formParams.mainContactEmail
            };
            Map<String, String> mailInfo = getSummaryMailInfo(formParams);
            requestData.mailType = mailInfo.get('type');
            requestData.mailSubject = mailInfo.get('subject');
            requestData.mailBody = mailInfo.get('body');
        } else {
            requestData.mailList = new List<String>();
        }
        system.debug('formParams.product2');
        system.debug(formParams.product);
        system.debug('formParams.tariffId2');
        system.debug(formParams.tariffId);

        //****  Init productId and tariffId ******//
        Map<String, Object> product = PPRProductSettingsUtils.getProductSettings(formParams.productId);
        if (product != null) {
            requestData.productId = String.valueOf(product.get('reportId'));
            Map<String, Object> tariff = (Map<String, Object>) product.get(formParams.tariffId);
            if (tariff != null) {
                requestData.tariffId = String.valueOf(tariff.get('reportId'));
            } else {
                throw new E2EFormRuException('Error: prepareReportRequestData(); tariff ' + formParams.tariffId + ' does not found');
            }
        } else {
            throw new E2EFormRuException('Error: prepareReportRequestData(); product ' + formParams.productId + ' does not found');
        }
        System.debug('PRODUCT ID REPORT = ' + requestData.productId + '; TARIFF ID REPORT = ' + requestData.tariffId);

        //******* Init specialOfferId and Promocode  *******//
        requestData.reportParams.PROMOCODE = '';
        requestData.reportParams.SPECIAL_OFFER_NAME = '';
        requestData.reportParams.SUPPLIER = '';

        if (formParams.source != null && formParams.source != '') {
            requestData.reportParams.PARTNER_NAME = formParams.sourcePP;
//            requestData.reportParams.PROMOCODE = formParams.promocodeName;
//            if (formParams.addPromoCodeName != null && formParams.addPromoCodeName != '') {
//                if (!requestData.reportParams.PROMOCODE.endsWith(';')) requestData.reportParams.PROMOCODE += ';';
//                requestData.reportParams.PROMOCODE += formParams.addPromoCodeName;
//            }
//            requestData.reportParams.SPECIAL_OFFER_NAME = formParams.source;
        }
//        else {
        System.debug('PROMOCODE IN SERVICE REPORT - ' + formParams.promocodeName);
        if (formParams.promocodeName != null) {
            E2E_Promocodes__c promocodeObject = E2E_Promocodes__c.getValues(formParams.promocodeName);
            E2E_Promocodes__c addPromocodeObject = E2E_Promocodes__c.getValues(formParams.addPromoCodeName);
            System.debug('PROMOCODE IN SERVICES - ' + promocodeObject);
            if (promocodeObject != null && promocodeObject.Report_Identifiers__c != null) {
                List<String> transitCoupleCode = promocodeObject.Report_Identifiers__c.split(';');
                if (addPromocodeObject != null && addPromocodeObject.Report_Identifiers__c != null) {
                    transitCoupleCode.addAll(addPromocodeObject.Report_Identifiers__c.split(';'));
                }
                Map<String, String> codes = new Map<String, String>();
                for (String coupleCode : transitCoupleCode) {
                    codes.put(coupleCode.split('@').get(0), coupleCode.split('@').get(1));
                }

                Map<String, String> supplies = new Map<String, String>();
                List<String> suppliesCodes = promocodeObject.Promocode_Additional_Field__c.split(';');
                if (addPromocodeObject != null && addPromocodeObject.Promocode_Additional_Field__c != null) {
                    suppliesCodes.addAll(addPromocodeObject.Promocode_Additional_Field__c.split(';'));
                }
                for (String val : suppliesCodes) {
                    supplies.put(val.split('@')[1], val.split('@')[0]);
                }
                System.debug('PROMOCODE IN SERVICE REPORT - ' + promocodeObject);
                requestData.specialOfferId = codes.get(formParams.promocodeIdInTransit) != null ? codes.get(formParams.promocodeIdInTransit) : '';
                requestData.reportParams.SPECIAL_OFFER_NAME = promocodeObject.Promocode_Label__c;
                requestData.reportParams.SUPPLIER = supplies.get(formParams.promocodeIdInTransit) != null ? supplies.get(formParams.promocodeIdInTransit) : '';
                requestData.reportParams.PROMOCODE = formParams.promocodeName;
                //Дополнительный промокод
                if (addPromocodeObject != null) {
                    if (!requestData.specialOfferId.endsWith(',') && requestData.specialOfferId != '') requestData.specialOfferId += ',';
                    requestData.specialOfferId += codes.get(formParams.addPromoCodeIdInTransit) != null ? codes.get(formParams.addPromoCodeIdInTransit) : '';

                    if (!requestData.reportParams.SPECIAL_OFFER_NAME.endsWith(';')) requestData.reportParams.SPECIAL_OFFER_NAME += ';';
                    requestData.reportParams.SPECIAL_OFFER_NAME += addPromocodeObject.Promocode_Label__c;

                    if (!requestData.reportParams.SUPPLIER.endsWith(';') && requestData.reportParams.SUPPLIER != '') requestData.reportParams.SUPPLIER += ';';
                    requestData.reportParams.SUPPLIER = supplies.get(formParams.addPromoCodeIdInTransit) != null ? supplies.get(formParams.addPromoCodeIdInTransit) : '';

                    if (!requestData.reportParams.PROMOCODE.endsWith(';')) requestData.reportParams.PROMOCODE += ';';
                    requestData.reportParams.PROMOCODE += formParams.addPromoCodeName;
                }
            } else {
                requestData.specialOfferId = '';
            }
        } else {
            requestData.specialOfferId = '';
        }
//        }


        // Check permission to credit
        requestData.hasCredit = formParams.freeOverdraft;
        requestData.reportParams.HAS_OVERDRAFT = formParams.freeOverdraft;

        // for PPR API overdraft
        if (businessProcessType.equals(GlobalUtils.BusinessProcessType.PPR_API)) {
            requestData.reportParams.OVERDRAFT_SUM = formParams.overdraftSum;
            String sumText = new ConverterRU().toWords(Integer.valueOf(formParams.overdraftSum));
            System.debug('reportParams.OVERDRAFT_SUM_TEXT = ' + sumText);
            requestData.reportParams.OVERDRAFT_SUM_TEXT = sumText;
        }

        requestData.reportParams.CONTRACT_DATE = createDateStringForReport(System.Today());

        //VS SF-668
        //requestData.reportParams.PAY_UNTIL_DATE = createDateStringForReport(System.Today().addMonths(3));
        Integer numberOfDays = Date.daysInMonth(System.Today().year(), System.Today().month());
        requestData.reportParams.PAY_UNTIL_DATE = createDateStringForReport(Date.newInstance(System.Today().year(), System.Today().month(), numberOfDays));
        System.debug(formParams.promoCode);
        requestData.reportParams.NUMBER_OF_CARDS = String.valueOf(formParams.numOfCards);
        requestData.reportParams.NUMBER_OF_CARDS_TEXT = GlobalUtils.convertNumberToWord(Integer.valueOf(formParams.numOfCards));
        requestData.reportParams.SECURITY_PHRASE = formParams.codeWord;
        requestData.reportParams.USERNAME = formParams.emailForPersonalOffice;
        requestData.reportParams.PRODUCT_NAME = formParams.product;

        requestData.reportParams.BILL_SUM = Integer.valueOf(formParams.prepayAmount);
        requestData.reportParams.EXT_CLIENT_ID = formParams.opportunityId;

        // Requisite for client
        requestData.reportParams.CLIENT_INN = formParams.companyInn;
        requestData.reportParams.CLIENT_KPP = GlobalUtils.blankStringIfNull(formParams.kpp);
        requestData.reportParams.CLIENT_OGRN = formParams.ogrn;
        requestData.reportParams.CLIENT_OKPO = formParams.okpo;
        requestData.reportParams.CLIENT_LEGAL_ADDRESS = formParams.companyLegalAddress;
        requestData.reportParams.CLIENT_ADDRESS = formParams.postalAddress;

        //VS SF-579
        /*if (businessProcessType == GlobalUtils.BusinessProcessType.E2EBusiness) {
            requestData.reportParams.CLIENT_LEGAL_ADDRESS += ' ' + formParams.legalAddressAdditionally;
            requestData.reportParams.CLIENT_ADDRESS += ' ' + formParams.postalAddressAdditionally;
        }*/

        requestData.reportParams.CLIENT_CURRENT_ACCOUNT = GlobalUtils.blankStringIfNull(formParams.checkingAccount);
        requestData.reportParams.CLIENT_COR_ACCOUNT = GlobalUtils.blankStringIfNull(formParams.corBankAccount);
        requestData.reportParams.CLIENT_BANK_NAME = GlobalUtils.blankStringIfNull(formParams.bankNameShort);
        requestData.reportParams.CLIENT_BIK = GlobalUtils.blankStringIfNull(formParams.bankBic);

        requestData.reportParams.CLIENT_PHONE = formParams.mainContactPhone;
        requestData.reportParams.CLIENT_EMAIL = formParams.mainContactEmail;
        requestData.reportParams.CLIENT_MOB_PHONE_FIN = formParams.mainContactPhone;
        requestData.reportParams.CLIENT_MOB_PHONE_INFO = formParams.mainContactPhone;
        //VS SF-699
        requestData.reportParams.CLIENT_NAME = formParams.mainCompanyFullNameSpark;

        if (formParams.isSoleProprietor == true) {
            requestData.reportParams.CLIENT_SIGNER_POST = '';
            requestData.reportParams.CLIENT_SIGNER_FIO = formParams.soleProprietorFio;
        } else {
            requestData.reportParams.CLIENT_SIGNER_POST = formParams.executivePosition;
            requestData.reportParams.CLIENT_SIGNER_FIO = (formParams.matchExecutiveSpark == true) ? formParams.executiveFio : formParams.executiveFioManual;
        }

        requestData.reportParams.EXTRA_INFO = GlobalUtils.blankStringIfNull(formParams.deliveryComments);

        // Additional
        requestData.reportParams.ADDITIONAL_CONTRACT_DATE = createDateStringForReport(System.Today());
        requestData.reportParams.ATTACHMENT_NUM = '1';

        //VS SF-717
        requestData.businessType = (formParams.businessType != null) ? formParams.businessType : 0;
        requestData.idEqv = (formParams.idEqv != null) ? formParams.idEqv : 1;

        //VS SF-1422
        requestData.createPPRPayContract = false; // По умолчанию всегда создается документ для ППР Пей
        if (requestData.businessType == 0) { // Если businessType ппр
            requestData.reportParams.SELLER_NAME = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ «ПЕРЕДОВЫЕ ПЛАТЕЖНЫЕ РЕШЕНИЯ»';
            requestData.reportParams.SELLER_SITE = 'http://www.petrolplus.ru/';
        } else if (requestData.businessType == 4) { // Если businessType gpc
            requestData.reportParams.SELLER_NAME = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ «Джи Пи Си Рус»';
            requestData.reportParams.SELLER_SITE = 'http://gpc-rus.ru/';
        }

        requestData.createPrescoringDocument = false;
        if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EBusiness)) {
            Credit_Factory_Report__c creditFactryReport = this.creditFactoryService.getChosenCFR(formParams.opportunityId);
            if (creditFactryReport == null) {
                if (formParams.freeOverdraft) {
                    requestData.reportParams.CREDIT_CONDITIONS = System.Label.Free_overdraft_conditions_for_docs;
                }
            } else {
                requestData.reportParams.CREDIT_PERIOD = serviceHelper.getCreditPeriodInWords(creditFactryReport.RU_Scoring_Credit_Period__c);
                requestData.reportParams.DUE_DATE = String.valueOf(creditFactryReport.RU_Scoring_Payment_Time_Limit__c);
                Integer paymentTimeLimit = Integer.valueOf(creditFactryReport.RU_Scoring_Payment_Time_Limit__c);
                String numberInWords = numberConverter.toWordsAccordingCase(paymentTimeLimit, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
                requestData.reportParams.DUE_DATE_IN_WORDS = numberInWords.capitalize();
                requestData.reportParams.CREDIT_LIMIT = creditFactryReport.Credit_Limit__c;
                requestData.reportParams.CREDIT_LIMIT_IN_WORDS = numberConverter.toWords(Integer.valueOf(creditFactryReport.Credit_Limit__c)).capitalize();
                requestData.createPrescoringDocument = true;
                requestData.reportParams.CREDIT_CONDITIONS = CFUtils.PRESCORING_RU + '. ' + creditFactryReport.Credit_Limit__c + ' рублей, срок кредита - '
                        + creditFactryReport.RU_Scoring_Credit_Period__c + ' дней, срок оплаты кредита - ' + creditFactryReport.RU_Scoring_Payment_Time_Limit__c + ' дней.';
            }
        }
        if (
            businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EBusiness) ||
                    businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EClassic)
            ) {
        this.serviceHelper.addPersonalOfficeData(requestData, formParams);
    }
        return requestData;
    }

    public ReportRequestData prepareReportRequestData(Id formDataId, E2EFormParams formParams, Map<String, LongFormPage> pagesMap, Boolean preview, GlobalUtils.BusinessProcessType businessProcessType) {
        E2EFormData__c formDataRecord = this.e2EFormRuDao.getFormDataById(formDataId);
        Account account = this.e2eFormRuDao.getAccountById(formDataRecord.E2E_Account_Id__c);
        Opportunity opportunity = this.e2eFormRuDao.getOpportunityById(formDataRecord.E2E_Opportunity_Id__c);

        E2E_Form_Ru_General_Settings__c generalSettings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        if (generalSettings == null) {
            throw new E2EFormRuException('Error: prepareReportRequestData(); E2E_Form_Ru_General_Settings__c does not found');
        }

        ReportRequestData requestData = new ReportRequestData();
        requestData.reportParams = new ReportRequestData.ReportParams();

        requestData.inn = formDataRecord.E2E_INN__c;
        //VS SF-699
        requestData.companyName = formParams.isSoleProprietor ? account.Name : GlobalUtils.createOrganiozationName(formParams.normName);
        requestData.sFRequestId = formDataRecord.E2E_Opportunity_Id__c;
        requestData.hasPersonalManager = formDataRecord.E2E_Personal_Manager_srv__c;
        requestData.hasExpressDelivery = formDataRecord.E2E_Document_Delivery_srv__c;
        requestData.preview = preview;
        if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EClassic)) {
            requestData.amount = Integer.valueOf(pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').value);
            requestData.bikBank = pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value;
        } else if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EBusiness)) {
            requestData.amount = Integer.valueOf(formParams.prepayAmount);
            requestData.bikBank = formParams.bankBic;

            requestData.inn = formDataRecord.E2E_INN__c;
            requestData.sFRequestId = formDataRecord.E2E_Opportunity_Id__c;
            requestData.hasPersonalManager = formDataRecord.E2E_Personal_Manager_srv__c;
            requestData.hasExpressDelivery = formDataRecord.E2E_Document_Delivery_srv__c;
            requestData.preview = preview;
        }


        // set partner
        if (opportunity.Source_PP__c != null && opportunity.Source_PP__c != '') {
            requestData.specPartner = true;
        } else {
            requestData.specPartner = false;
        }

        // set email for send completed contract to client
        if (generalSettings.Send_Contract_To_Client__c == true && formParams.sendToInbound == false && preview == false) {
            requestData.mailList = new List<String>{
                    formDataRecord.E2E_Contact_Email__c
            };
            Map<String, String> mailInfo = getSummaryMailInfo(formDataRecord);
            requestData.mailType = mailInfo.get('type');
            requestData.mailSubject = mailInfo.get('subject');
            requestData.mailBody = mailInfo.get('body');
        } else {
            requestData.mailList = new List<String>();
        }

        system.debug('formParams.product1');
        system.debug(formParams.product);
        system.debug('formParams.tariffId1');
        system.debug(formParams.tariffId);
        system.debug('formDataRecord.E2E_Tariff_Id__c1');
        system.debug(formDataRecord.E2E_Tariff_Id__c);
        //****  Init productId and tariffId ******//
        Map<String, Object> product = PPRProductSettingsUtils.getProductSettings(formParams.product);
        if (product != null) {
            requestData.productId = String.valueOf(product.get('reportId'));
            Map<String, Object> tariff = (Map<String, Object>) product.get(formDataRecord.E2E_Tariff_Id__c);
            if (tariff != null) {
                requestData.tariffId = String.valueOf(tariff.get('reportId'));
            } else {
                throw new E2EFormRuException('Error: tariff ' + formParams.tariffId + ' does not found');
            }
        } else {
            throw new E2EFormRuException('Error: product ' + formParams.productId + ' does not found');
        }
        system.debug('requestData.tariffId ' + requestData.tariffId);
        system.debug('requestData.productId ' + requestData.productId);




        //******* Init specialOfferId and Promocode  *******//
        requestData.reportParams.PROMOCODE = '';
        requestData.reportParams.SPECIAL_OFFER_NAME = '';
        requestData.reportParams.SUPPLIER = '';

        if (opportunity.Source_PP__c != null && opportunity.Source_PP__c != '' && !'e2ecallcenter'.equalsIgnoreCase(opportunity.Source_PP__c)) {
            requestData.reportParams.PARTNER_NAME = opportunity.Source_PP__c;
//            requestData.reportParams.PROMOCODE = formParams.promocodeName;
//            requestData.reportParams.SPECIAL_OFFER_NAME = formParams.source;
        }
//        else {
        if (formParams.promocodeName != null) {
            E2E_Promocodes__c promocodeObject = E2E_Promocodes__c.getValues(formParams.promocodeName);
            if (promocodeObject != null && promocodeObject.Report_Identifiers__c != null) {
                List<String> transitCoupleCode = promocodeObject.Report_Identifiers__c.split(';');
                Map<String, String> codes = new Map<String, String>();
                for (String coupleCode : transitCoupleCode) {
                    codes.put(coupleCode.split('@').get(0), coupleCode.split('@').get(1));
                }

                Map<String, String> supplies = new Map<String, String>();
                for (String val : promocodeObject.Promocode_Additional_Field__c.split(';')) {
                    supplies.put(val.split('@')[1], val.split('@')[0]);
                }

                requestData.specialOfferId = codes.get(formParams.promocodeIdInTransit) != null ? codes.get(formParams.promocodeIdInTransit) : '';
                requestData.reportParams.SPECIAL_OFFER_NAME = promocodeObject.Promocode_Label__c;
                requestData.reportParams.SUPPLIER = supplies.get(formParams.promocodeIdInTransit);
                requestData.reportParams.PROMOCODE = formParams.promocodeName;
            } else {
                requestData.specialOfferId = '';
            }
        } else {
            requestData.specialOfferId = '';
        }
//        }


        // Check permission to credit
        if (formDataRecord.E2E_Scoring_Decision_Code__c == '0') {
            requestData.hasCredit = formDataRecord.E2E_Overdraft_srv__c != null ? formDataRecord.E2E_Overdraft_srv__c : false;
            requestData.reportParams.HAS_OVERDRAFT = formDataRecord.E2E_Overdraft_srv__c != null ? formDataRecord.E2E_Overdraft_srv__c : false;
        } else {
            requestData.hasCredit = false;
            requestData.reportParams.HAS_OVERDRAFT = false;
        }

        requestData.reportParams.CONTRACT_DATE = createDateStringForReport(System.Today());
        //VS SF-668
        //requestData.reportParams.PAY_UNTIL_DATE = createDateStringForReport(System.Today().addMonths(3));
        Integer numberOfDays = Date.daysInMonth(System.Today().year(), System.Today().month());
        requestData.reportParams.PAY_UNTIL_DATE = createDateStringForReport(Date.newInstance(System.Today().year(), System.Today().month(), numberOfDays));

        System.debug(formParams.promoCode);
        requestData.reportParams.NUMBER_OF_CARDS = String.valueOf(formDataRecord.E2E_Num_Cards__c);
        requestData.reportParams.NUMBER_OF_CARDS_TEXT = GlobalUtils.convertNumberToWord(Integer.valueOf(formDataRecord.E2E_Num_Cards__c));
        requestData.reportParams.SECURITY_PHRASE = formDataRecord.E2E_Code_Word__c;
        requestData.reportParams.USERNAME = formDataRecord.E2E_Personal_Office_Email__c;
        requestData.reportParams.PRODUCT_NAME = formDataRecord.E2E_Product__c;
        if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EClassic)) {
            requestData.reportParams.BILL_SUM = Integer.valueOf(pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').value);
        } else if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EBusiness)) {
            requestData.reportParams.BILL_SUM = Integer.valueOf(formParams.prepayAmount);
        }
        requestData.reportParams.EXT_CLIENT_ID = formDataRecord.E2E_Opportunity_Id__c;

        // Requisite for client
        requestData.reportParams.CLIENT_INN = formDataRecord.E2E_INN__c;
        requestData.reportParams.CLIENT_KPP = GlobalUtils.blankStringIfNull(formDataRecord.E2E_KPP__c);
        requestData.reportParams.CLIENT_OGRN = formDataRecord.E2E_OGRN__c;
        requestData.reportParams.CLIENT_OKPO = formDataRecord.E2E_OKPO__c;
        requestData.reportParams.CLIENT_LEGAL_ADDRESS = formDataRecord.E2E_Legal_Address__c;
        requestData.reportParams.CLIENT_ADDRESS = formDataRecord.E2E_Post_Address__c;
        if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EClassic)) {
            requestData.reportParams.CLIENT_CURRENT_ACCOUNT = GlobalUtils.blankStringIfNull(pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value);
            requestData.reportParams.CLIENT_COR_ACCOUNT = GlobalUtils.blankStringIfNull(pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value);
            requestData.reportParams.CLIENT_BANK_NAME = GlobalUtils.blankStringIfNull(pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value);
            requestData.reportParams.CLIENT_BIK = GlobalUtils.blankStringIfNull(pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value);
        } else if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EBusiness)) {
            requestData.reportParams.CLIENT_CURRENT_ACCOUNT = GlobalUtils.blankStringIfNull(formParams.checkingAccount);
            requestData.reportParams.CLIENT_COR_ACCOUNT = GlobalUtils.blankStringIfNull(formParams.corBankAccount);
            requestData.reportParams.CLIENT_BANK_NAME = GlobalUtils.blankStringIfNull(formParams.bankNameShort);
            requestData.reportParams.CLIENT_BIK = GlobalUtils.blankStringIfNull(formParams.bankBic);
        }

        requestData.reportParams.CLIENT_PHONE = formDataRecord.E2E_Contact_Phone__c;
        requestData.reportParams.CLIENT_EMAIL = formDataRecord.E2E_Contact_Email__c;
        requestData.reportParams.CLIENT_MOB_PHONE_FIN = formDataRecord.E2E_Contact_Phone__c;
        requestData.reportParams.CLIENT_MOB_PHONE_INFO = formDataRecord.E2E_Contact_Phone__c;
        //VS SF-699
        requestData.reportParams.CLIENT_NAME = formDataRecord.E2E_Main_Company_Full_Name__c;

        List<String> executivePersonData = new List<String>();
        if (businessProcessType == GlobalUtils.BusinessProcessType.E2EClassic) {
            executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
        } else {
            executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person_Manual__c);
        }
        if (account.Organization_Type__c == 'ИП') {
            requestData.reportParams.CLIENT_SIGNER_POST = '';
            requestData.reportParams.CLIENT_SIGNER_FIO = executivePersonData.get(0);
        } else {
            requestData.reportParams.CLIENT_SIGNER_POST = executivePersonData.get(1);
            requestData.reportParams.CLIENT_SIGNER_FIO = executivePersonData.get(0);
        }

        requestData.reportParams.EXTRA_INFO = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Courier_Comments__c);

        // Additional
        requestData.reportParams.ADDITIONAL_CONTRACT_DATE = createDateStringForReport(System.Today());
        requestData.reportParams.ATTACHMENT_NUM = '1';

        //VS SF-717
        requestData.businessType = (formParams.businessType != null) ? formParams.businessType : 0;
        requestData.idEqv = (formParams.idEqv != null) ? formParams.idEqv : 1;

        if (
                businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EBusiness) ||
                        businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EClassic)
                ) {
            this.serviceHelper.addPersonalOfficeData(requestData, formParams);
        }

        requestData.createPPRPayContract = false;
        return requestData;
    }

    public static String createDateStringForReport(Date currentDate) {
        String dateStr = '«' + currentDate.day() + '»';
        dateStr += ' ' + GlobalUtils.getStringOfMonth(currentDate.month()) + ' ';
        dateStr += currentDate.year();
        dateStr += ' г.';
        return dateStr;
    }

    public Map<String, String> getSummaryMailInfo(E2EFormParams formParams) {
        EmailTemplate summaryEmail;
        if (Test.isRunningTest()) {
            summaryEmail = new EmailTemplate(
                    Id = '00X0O000001reLSUAY',
                    HTMLValue = 'test',
                    Name = 'E2E RU Order Confirmation',
                    Subject = 'testSub'
            );
        } else {
            summaryEmail = [
                    SELECT Id, HTMLValue, Name, Subject
                    FROM EmailTemplate
                    WHERE Name = 'E2E RU Order Confirmation'
            ];
        }

        //Get email body
        String emailBody = summaryEmail.HTMLValue;
        emailBody = emailBody.replace('$OrderNumber$', formParams.formDataName);
        emailBody = emailBody.replace('$NumberOfCards$', String.valueof(formParams.numOfCards));
        String emailProductName = '';
        if (formParams.product.contains('Вездеход Online')) {
            emailProductName = '"Вездеход Online"';
        } else {
            emailProductName = formParams.product;
        }
        emailBody = emailBody.replace('$E2EProductName$', emailProductName);

        //Get email Subject
        String emailSubject = summaryEmail.Subject;
        emailSubject = emailSubject.replace('$E2EProductName$', emailProductName);

        Map<String, String> emailData = new Map<String, String>();
        emailData.put('body', emailBody);
        emailData.put('subject', emailSubject);
        emailData.put('type', 'HTML');
        return emailData;
    }

    public Map<String, String> getSummaryMailInfo(E2EFormData__c formData) {
        EmailTemplate summaryEmail = [
                SELECT Id, HTMLValue, Name, Subject
                FROM EmailTemplate
                WHERE Name = 'E2E RU Order Confirmation'
        ];

        //Get email body
        String emailBody = summaryEmail.HTMLValue;
        emailBody = emailBody.replace('$OrderNumber$', formData.Name);
        emailBody = emailBody.replace('$NumberOfCards$', String.valueof(formData.E2E_Num_Cards__c));
        String emailProductName = '';
        if (formData.E2E_Product__c.contains('Вездеход Online')) {
            emailProductName = '"Вездеход Online"';
        } else {
            emailProductName = formData.E2E_Product__c;
        }
        emailBody = emailBody.replace('$E2EProductName$', emailProductName);

        //Get email Subject
        String emailSubject = summaryEmail.Subject;
        emailSubject = emailSubject.replace('$E2EProductName$', emailProductName);

        Map<String, String> emailData = new Map<String, String>();
        emailData.put('body', emailBody);
        emailData.put('subject', emailSubject);
        emailData.put('type', 'HTML');
        return emailData;
    }

    //******* Form Service *****//
    /*******************************************************************************
    *  Name            : createFormDataRecord(Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams
    *  Summary         : create Form Data log record
    *  CreatedDate     : 30/10/2018
    *  ModifiedDate    : -
    *  Parameters      : Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap
    *  Returns         : created record id
    ******************************************************************************/
    public Id createFormDataRecord(Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams) {
        String phone = pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value;
        String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
        Boolean sendMarketingEmail = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').value);
        Boolean processPersonalData = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value);
        // New Form Data record
        E2EFormData__c formDataLog = new E2EFormData__c(
                E2E_Account_Id__c = GlobalUtils.blankStringIfNull(accountId),
                E2E_Contact_Id__c = GlobalUtils.blankStringIfNull(contactId),
                E2E_Opportunity_Id__c = GlobalUtils.blankStringIfNull(opportunityId),
                E2E_Contact_Phone__c = phone,
                E2E_Send_Marketing_Email__c = sendMarketingEmail,
                E2E_Process_Personal_Data__c = processPersonalData,
                E2E_IP_Address__c = formParams.ipAddress,
                E2E_Last_Step__c = GlobalUtils.E2ERuSteps.ContactDetails.name(),
                E2E_Device_Type__c = formParams.deviceType,
                E2E_Source__c = formParams.source,
                E2E_Offer__c = formParams.offer,
                E2E_Product_Id__c = formParams.product,
                E2E_Promo_Campaign__c = formParams.promoCode + ((formParams.addPromoCode != null) ? ';' + formParams.addPromoCode : ''),
                E2E_Split_Testing__c = formParams.splitTesting,
                E2E_Split_WTL__c = formParams.splitWTL
        );

        if (processPersonalData) {
            formDataLog.E2E_Contact_Email__c = email;
        }
        return this.e2eFormRuDao.createFormDataRecord(formDataLog);
    }

    /*******************************************************************************
   *  Name            : createFormDataRecord(Id accountId, Id opportunityId, E2EFormParams formParams
   *  Summary         : create Form Data log record
   *  CreatedDate     : 27/02/2019
   *  ModifiedDate    : -
   *  Parameters      : Id accountId, Id opportunityId, Map<String, LongFormPage> pagesMap
   *  Returns         : created record id
   ******************************************************************************/
    public Id createFormDataRecord(Id accountId, Id opportunityId, E2EFormParams formParams) {
        String phone = formParams.mainContactPhone;
        String email = formParams.mainContactEmail;
        // New Form Data record
        E2EFormData__c formDataLog = new E2EFormData__c(
                E2E_Account_Id__c = GlobalUtils.blankStringIfNull(accountId),
                E2E_Opportunity_Id__c = GlobalUtils.blankStringIfNull(opportunityId),
                E2E_Contact_Phone__c = phone,
                E2E_IP_Address__c = formParams.ipAddress,
                E2E_Last_Step__c = GlobalUtils.E2ERuSteps.ContactDetails.name(),
                E2E_Source__c = formParams.source,
                E2E_Offer__c = formParams.offer,
                E2E_Product_Id__c = formParams.product
        );

        return this.e2eFormRuDao.createFormDataRecord(formDataLog);
    }

    /*******************************************************************************
    *  Name            : updateFormData
    *  Summary         : Update FormData for E2E Bussines
    *  CreatedDate     : 05/03/2019
    *  ModifiedDate    : 06/03/2019
    *  Parameters      : Id formDataId, E2EFormParams formParams
    *  Returns         : -
    ******************************************************************************/
    public void updateFormData(Id formDataId, E2EFormParams formParams) {
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);

        formDataRecord.E2E_Contact_Id__c = formParams.contactId;
        formDataRecord.E2E_Contact_Phone__c = formParams.mainContactPhone;
        formDataRecord.E2E_Contact_Email__c = formParams.mainContactEmail;
        formDataRecord.E2E_Offer__c = formParams.offer;
        formDataRecord.E2E_Source__c = formParams.source;
        formDataRecord.E2E_Product__c = formParams.product;
        formDataRecord.E2E_Num_Cards__c = formParams.numOfCards;
        formDataRecord.E2E_Product_Id__c = GlobalUtils.blankStringIfNull(formParams.productId);
        formDataRecord.E2E_Tariff_Id__c = GlobalUtils.blankStringIfNull(formParams.tariffId);
        formDataRecord.E2E_Promo_Campaign__c = GlobalUtils.blankStringIfNull(formParams.promoCode) + ((formParams.addPromoCode != null) ? ';' + formParams.addPromoCode : '');

        if (formParams.isSoleProprietor == true) {
            formDataRecord.E2E_Account_Short_Name__c = formParams.mainCompanyFullNameSpark.removeStart('ИП ');
            formDataRecord.E2E_Executive_Person__c = GlobalUtils.blankStringIfNull(formParams.soleProprietorFio) + ', ' + 'Индивидуальный предприниматель';
            formDataRecord.E2E_Executive_Person_Manual__c = formDataRecord.E2E_Executive_Person__c;
        } else {
            formDataRecord.E2E_Account_Short_Name__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(0);
            String executiveFio = '';
            String executiveFioManual = '';
            String executivePosition = '';
            String executivePositionManual = '';
            System.debug('formParams.matchExecutiveSpark ' + formParams.matchExecutiveSpark);
            executiveFio = GlobalUtils.blankStringIfNull(formParams.executiveFio);
            executivePosition = formParams.executivePosition == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.executivePosition);
            if (formParams.matchExecutiveSpark == true) {
                executiveFioManual = GlobalUtils.blankStringIfNull(formParams.executiveFio);
                executivePositionManual = formParams.executivePosition == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.executivePosition);
            } else {
                executiveFioManual = GlobalUtils.blankStringIfNull(formParams.executiveFioManual);
                executivePositionManual = formParams.executivePositionManual == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.executivePositionManual);
            }
            formDataRecord.E2E_Executive_Person__c = executiveFio + executivePosition;
            formDataRecord.E2E_Executive_Person_Manual__c = executiveFioManual + executivePositionManual;
            System.debug('formDataRecord.E2E_Executive_Person__c ' + formDataRecord.E2E_Executive_Person__c);
        }

        System.debug('E2E_Account_Short_Name__c ' + formDataRecord.E2E_Account_Short_Name__c);

        formDataRecord.E2E_Account_Name__c = GlobalUtils.blankStringIfNull(formParams.companyName);
        formDataRecord.E2E_INN__c = formParams.companyInn;
        formDataRecord.E2E_Main_Company_Full_Name__c = formParams.mainCompanyFullNameSpark;
        formDataRecord.E2E_Spark_Id__c = GlobalUtils.blankStringIfNull(String.valueOf(formParams.sparkId));
        formDataRecord.E2E_Black_List_Code__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecisionCode);
        formDataRecord.E2E_Black_List__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecision);
        formDataRecord.E2E_Black_List_Limitations__c = GlobalUtils.blankStringIfNull(formParams.verifiedLimitation);
        formDataRecord.E2E_Scoring_Decision_Code__c = GlobalUtils.blankStringIfNull(formParams.scoringDecisionCode);
        formDataRecord.E2E_Scoring_Decision__c = GlobalUtils.blankStringIfNull(formParams.scoringDecision);
        formDataRecord.E2E_Scoring_Date__c = formParams.scoringDate;
        formDataRecord.E2E_Scoring_Expiration_Date__c = formParams.scoringDate == null ? null : formParams.scoringDate.addMonths(3);
        formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(formParams.ogrnSpark);
        formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
        formDataRecord.E2E_Empty_SPARK_OKPO__c = formParams.emptySparkOkpo;
        formDataRecord.E2E_KPP__c = GlobalUtils.blankStringIfNull(formParams.kppSpark);
        formDataRecord.E2E_Reg_Date__c = GlobalUtils.blankStringIfNull(formParams.registrationDateSpark);

        formDataRecord.E2E_Billing_Country__c = GlobalUtils.FleetcorCountries.Russia.name();
        formDataRecord.E2E_Billing_City__c = formParams.companyLegalAddressCity;
        formDataRecord.E2E_Billing_State__c = formParams.companyLegalAddressState;
        formDataRecord.E2E_Billing_Str__c = formParams.companyLegalAddressStreet;
        formDataRecord.E2E_Billing_House__c = formParams.companyLegalAddressHouse;
        formDataRecord.E2E_Billing_Code__c = formParams.companyLegalAddressPostalCode;
        formDataRecord.E2E_Billing_Apartment__c = formParams.legalAddressAdditionally;
        formDataRecord.E2E_Legal_Address__c = formParams.companyLegalAddress;

        formDataRecord.E2E_Shipping_Country__c = GlobalUtils.FleetcorCountries.Russia.name();
        formDataRecord.E2E_Shipping_City__c = formParams.postalAddressCity;
        formDataRecord.E2E_Shipping_State__c = formParams.postalAddressState;
        formDataRecord.E2E_Shipping_Str__c = formParams.postalAddressStreet;
        formDataRecord.E2E_Shipping_House__c = formParams.postalAddressHouse;
        formDataRecord.E2E_Shipping_Code__c = formParams.postalAddressPostalCode;
        formDataRecord.E2E_Shipping_Apartment__c = formParams.postalAddressAdditionally;

        formDataRecord.E2E_Post_Address__c = formParams.postalAddress;

        //FORM DATA
        formDataRecord.E2E_Personal_Manager_srv__c = formParams.hasPersonalManager;
        formDataRecord.E2E_Document_Delivery_srv__c = formParams.hasDocumentDelivery;
        formDataRecord.Free_overdraft__c = formParams.freeOverdraft;
        formDataRecord.E2E_Code_Word__c = formParams.codeWord;
        formDataRecord.E2E_Personal_Office_Email__c = formParams.emailForPersonalOffice;
        formDataRecord.E2E_Courier_Comments__c = formParams.deliveryComments;
        formDataRecord.E2E_Bank_Name_Short__c = formParams.bankNameShort;

        formDataRecord.E2E_Bank__c = GlobalUtils.blankStringIfNull(formParams.bankName);
        formDataRecord.E2E_BIC__c = GlobalUtils.blankStringIfNull(formParams.bankBic);

        formDataRecord.E2E_Bank_Address__c = formParams.bankAddress;
        formDataRecord.E2E_Bank_Town__c = formParams.bankTown;
        formDataRecord.E2E_Bank_OKPO__c = formParams.bankOkpo;
        formDataRecord.E2E_Cor_Bank_Account__c = GlobalUtils.blankStringIfNull(formParams.corBankAccount);
        formDataRecord.E2E_Checking_Account__c = GlobalUtils.blankStringIfNull(formParams.checkingAccount);
        if (formParams.prepayAmount != '') {
            this.formDataValidator.validateIsNotBlank(formParams.prepayAmount, 'prepayAmount');
        }
        formDataRecord.E2E_Prepay_Amount__c = formParams.prepayAmount;
        if (formParams.lastLaunch != null) {
            formDataRecord.E2E_Last_Launch__c = formParams.lastLaunch;
        }
        this.e2eFormRuDao.updateFormData(formDataRecord);
    }

    /*******************************************************************************
    *  Name            : updateFormData(E2EFormParams formParams)
    *  Summary         : Updates FormData for PPR API
    *  CreatedDate     : 05/02/2020
    *  ModifiedDate    : -
    *  Parameters      : E2EFormParams formParams
    *  Returns         : -
    ******************************************************************************/
    public void updateFormData(E2EFormParams formParams) {
        E2EFormData__c formData = this.e2eFormRuDao.getFormDataById(formParams.formDataId);

        // general info
        formData.E2E_INN__c = GlobalUtils.changeIfHasNewValue(formData.E2E_INN__c, formParams.companyInn);
        formData.E2E_Source__c = GlobalUtils.changeIfHasNewValue(formData.E2E_Source__c, formParams.source);
        formData.E2E_Process_Status__c = GlobalUtils.changeIfHasNewValue(formData.E2E_Process_Status__c, formParams.processStatus);

        // deduplication info
        if (formParams.deduplicationDatetime != null) formData.Last_deduplication_time__c = formParams.deduplicationDatetime;
        formData.E2E_Dedup_Status__c = GlobalUtils.changeIfHasNewValue(formData.E2E_Dedup_Status__c, formParams.deduplicationStatus);
        formData.E2E_Dedup_Status_Info__c = GlobalUtils.changeIfHasNewValue(formData.E2E_Dedup_Status_Info__c, formParams.deduplicationStatusInfo);

        // scoring info
        if (formParams.scoringDate != null) formData.E2E_Scoring_Date__c = formParams.scoringDate;
        formData.E2E_Scoring_Decision_Code__c = GlobalUtils.changeIfHasNewValue(formData.E2E_Scoring_Decision_Code__c, formParams.scoringDecisionCode);
        formData.E2E_Scoring_Decision__c = GlobalUtils.changeIfHasNewValue(formData.E2E_Scoring_Decision__c, formParams.scoringDecision);
        if (formParams.scoringExpirationDate != null) formData.E2E_Scoring_Expiration_Date__c = formParams.scoringExpirationDate;

        // black list info
        formData.E2E_Black_List_Code__c = GlobalUtils.changeIfHasNewValue(formData.E2E_Black_List_Code__c, formParams.verifiedDecisionCode);
        formData.E2E_Black_List__c = GlobalUtils.changeIfHasNewValue(formData.E2E_Black_List__c, formParams.verifiedDecision);
        formData.E2E_Black_List_Limitations__c = GlobalUtils.changeIfHasNewValue(formData.E2E_Black_List_Limitations__c, formParams.verifiedLimitation);

        this.e2eFormRuDao.updateFormData(formData);
    }


    /*******************************************************************************
    *  Name            : updateFormData(Id formDataId, Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step)
    *  Summary         : update Form Data log record
    *  CreatedDate     : 18/07/2018
    *  ModifiedDate    : 25/07/2018
    *  Parameters      : Id formDataId, Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step
    *  Returns         : -
    ******************************************************************************/
    public void updateFormData(Id formDataId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step, String source) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);

        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        formParams.formDataName = formDataRecord.Name;
        if (activeStep == GlobalUtils.E2ERuSteps.ContactDetails) {
            // STEP ContactDetails
            String phone = pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value;
            String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
            Boolean sendMarketingEmail = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').value);
            Boolean processPersonalData = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value);

            formDataRecord.E2E_Offer__c = formParams.offer;
            formDataRecord.E2E_Source__c = formParams.source;
            formDataRecord.E2E_Product__c = formParams.product;
            formDataRecord.E2E_Promo_Campaign__c = formParams.promoCode;

            if (processPersonalData) {
                formDataRecord.E2E_Contact_Email__c = email;
            }
            formDataRecord.E2E_Contact_Phone__c = GlobalUtils.blankStringIfNull(phone);
            formDataRecord.E2E_Send_Marketing_Email__c = sendMarketingEmail;
            formDataRecord.E2E_Process_Personal_Data__c = processPersonalData;
        } else if (activeStep == GlobalUtils.E2ERuSteps.CompanyInformation) {
            // STEP CompanyInformation
            String accountName = pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value;
            String INN = pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value;
            Boolean isEntryManual = Boolean.valueOf(pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').value);

            if (formParams.isSoleProprietor == true) {
                formDataRecord.E2E_Account_Short_Name__c = formParams.mainCompanyFullNameSpark.removeStart('ИП ');
                formDataRecord.E2E_Executive_Person__c = GlobalUtils.blankStringIfNull(formParams.soleProprietorFio) + ', ' + 'Индивидуальный предприниматель';
            } else {
                formDataRecord.E2E_Account_Short_Name__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(0);
                String executiveFio = GlobalUtils.blankStringIfNull(formParams.executiveFio);
                String executivePosition = formParams.executivePosition == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.executivePosition);
                formDataRecord.E2E_Executive_Person__c = executiveFio + executivePosition;
            }

            formDataRecord.E2E_Account_Name__c = GlobalUtils.blankStringIfNull(accountName);
            formDataRecord.E2E_Reg_Date__c = GlobalUtils.blankStringIfNull(formParams.registrationDateSpark);
            formDataRecord.E2E_INN__c = GlobalUtils.blankStringIfNull(INN);
            formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(formParams.ogrnSpark);
            formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
            formDataRecord.E2E_KPP__c = GlobalUtils.blankStringIfNull(formParams.kppSpark);
            formDataRecord.E2E_Manual_Entry__c = isEntryManual;
            formDataRecord.E2E_Spark_Id__c = GlobalUtils.blankStringIfNull(String.valueOf(formParams.sparkId));
            formDataRecord.E2E_Main_Company_Full_Name__c = GlobalUtils.blankStringIfNull(formParams.mainCompanyFullNameSpark);
            formDataRecord.E2E_Billing_Code__c = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
            formDataRecord.E2E_Billing_State__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);
            formDataRecord.E2E_Billing_City__c = GlobalUtils.blankStringIfNull(formParams.citySpark);
            String street = formParams.streetSpark == null ? '' : GlobalUtils.blankStringIfNull(formParams.streetSpark);
            String building = formParams.buildingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.buildingSpark);
            String housing = formParams.housingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.housingSpark);
            String block = formParams.blockSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.blockSpark);
            String room = formParams.roomSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.roomSpark);
            formDataRecord.E2E_Billing_Str__c = street + building;
            formDataRecord.E2E_Billing_Apartment__c = housing + block + room;
            formDataRecord.E2E_Legal_Address__c = GlobalUtils.blankStringIfNull(formParams.legalAddressSpark);
            formDataRecord.E2E_Black_List_Code__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecisionCode);
            formDataRecord.E2E_Black_List__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecision);
            formDataRecord.E2E_Black_List_Limitations__c = GlobalUtils.blankStringIfNull(formParams.verifiedLimitation);
            formDataRecord.E2E_Scoring_Decision_Code__c = GlobalUtils.blankStringIfNull(formParams.scoringDecisionCode);
            formDataRecord.E2E_Scoring_Decision__c = GlobalUtils.blankStringIfNull(formParams.scoringDecision);
            formDataRecord.E2E_Scoring_Date__c = formParams.scoringDate;
            formDataRecord.E2E_Scoring_Expiration_Date__c = formParams.scoringDate == null ? null : formParams.scoringDate.addMonths(3);
            formDataRecord.E2E_Dedup_Status__c = GlobalUtils.blankStringIfNull(formParams.deduplicationStatus);
            formDataRecord.E2E_Dedup_Status_Info__c = GlobalUtils.blankStringIfNull(formParams.deduplicationStatusInfo);
        } else if (activeStep == GlobalUtils.E2ERuSteps.Order) {
            // STEP Order
            String product = pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value + '';
            String tariff = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value;
            String tariffId = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value;
            Integer numberOfCards = Integer.valueOf(pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value);
            String promoCode = pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value;
            String paymentCondition = pagesMap.get('ORDER').fields.get('PAYMENT CONDITIONS').elementItemsMap.get('DEFAULT VALUE').value;
            Boolean needPersonalManager = Boolean.valueOf(pagesMap.get('ORDER').fields.get('PERSONAL MANAGER').elementItemsMap.get('DEFAULT VALUE').value);
            Boolean needDocumentDelivery = Boolean.valueOf(pagesMap.get('ORDER').fields.get('DOCS DELIVERY').elementItemsMap.get('DEFAULT VALUE').value);
            Boolean needPayOverdraft = Boolean.valueOf(pagesMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value);

            formDataRecord.E2E_Product_Id__c = GlobalUtils.blankStringIfNull(product);
            formDataRecord.E2E_Tariff_Id__c = GlobalUtils.blankStringIfNull(tariffId);
            formDataRecord.E2E_Product__c = GlobalUtils.getE2EProduct(product) + ' ' + GlobalUtils.blankStringIfNull(tariff);
            formDataRecord.E2E_Num_Cards__c = numberOfCards;
            formDataRecord.E2E_Promo_Campaign__c = GlobalUtils.blankStringIfNull(promoCode);
            formDataRecord.E2E_Personal_Manager_srv__c = needPersonalManager;
            formDataRecord.E2E_Document_Delivery_srv__c = needDocumentDelivery;
            formDataRecord.E2E_Overdraft_srv__c = needPayOverdraft;
            formDataRecord.E2E_Payment_Condition__c = GlobalUtils.blankStringIfNull(paymentCondition);
        } else if (activeStep == GlobalUtils.E2ERuSteps.LegalDetails) {
            // STEP LegalDetails
            String OGRN = '';
            String KPP = '';
            if (formParams.isSoleProprietor) {
                OGRN = pagesMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').value;
            } else {
                OGRN = pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value;
                KPP = pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value;
            }
            String OKPO = pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value;
            String legalAddress = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
            String legalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').value;
            String legalAddressState = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').value;
            String legalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').value;
            String legalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').value;
            String legalAddressHouse = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value;
            String legalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').value;
            String legalAddressApartment = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
            String postalAddress = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
            String postalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').value;
            String postalAddressState = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STATE').value;
            String postalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').value;
            String postalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').value;
            String postalAddressHouse = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value;
            String postalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').value;
            String postalAddressApartment = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
            String executivePerson = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').value;
            String executivePersonTitle = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').value;
            String chiefAccountant = pagesMap.get('LEGAL DETAILS').fields.get('CHIEF ACCOUNTANT').elementItemsMap.get('DEFAULT VALUE').value;
            String codeWord = pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value;
            String cardsDeliveryInformation = pagesMap.get('LEGAL DETAILS').fields.get('CARDS DELIVERY INFORMATION').elementItemsMap.get('DEFAULT VALUE').value;
            String personalOfficeEmail = pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value;
            Boolean isManualEntryLegalInfo = Boolean.valueOf(pagesMap.get('LEGAL DETAILS').fields.get('REWRITE DEFAULT SPARK VALUES').elementItemsMap.get('DEFAULT VALUE').value);

            this.formDataValidator.validateEmail(personalOfficeEmail);

            formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(OGRN);
            formDataRecord.E2E_KPP__c = GlobalUtils.blankStringIfNull(KPP);
            formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(OKPO);
            formDataRecord.E2E_Billing_Str__c = GlobalUtils.blankStringIfNull(legalAddressStreet);
            formDataRecord.E2E_Billing_House__c = GlobalUtils.blankStringIfNull(legalAddressHouse);
            formDataRecord.E2E_Billing_City__c = GlobalUtils.blankStringIfNull(legalAddressCity);
            formDataRecord.E2E_Billing_State__c = GlobalUtils.blankStringIfNull(legalAddressState);
            formDataRecord.E2E_Billing_Code__c = GlobalUtils.blankStringIfNull(legalAddressPostalCode);
            formDataRecord.E2E_Billing_Country__c = GlobalUtils.blankStringIfNull(legalAddressCountry);
            formDataRecord.E2E_Billing_Apartment__c = GlobalUtils.blankStringIfNull(legalAddressApartment);
            formDataRecord.E2E_Legal_Address__c = GlobalUtils.blankStringIfNull(legalAddress);
            formDataRecord.E2E_Shipping_Str__c = GlobalUtils.blankStringIfNull(postalAddressStreet);
            formDataRecord.E2E_Shipping_House__c = GlobalUtils.blankStringIfNull(postalAddressHouse);
            formDataRecord.E2E_Shipping_City__c = GlobalUtils.blankStringIfNull(postalAddressCity);
            formDataRecord.E2E_Shipping_State__c = GlobalUtils.blankStringIfNull(postalAddressState);
            formDataRecord.E2E_Shipping_Code__c = GlobalUtils.blankStringIfNull(postalAddressPostalCode);
            formDataRecord.E2E_Shipping_Country__c = GlobalUtils.blankStringIfNull(postalAddressCountry);
            formDataRecord.E2E_Shipping_Apartment__c = GlobalUtils.blankStringIfNull(postalAddressApartment);
            formDataRecord.E2E_Post_Address__c = GlobalUtils.blankStringIfNull(postalAddress);
            formDataRecord.E2E_Chief_Accountant__c = GlobalUtils.blankStringIfNull(chiefAccountant);
            formDataRecord.E2E_Code_Word__c = GlobalUtils.blankStringIfNull(codeWord);
            formDataRecord.E2E_Courier_Comments__c = GlobalUtils.blankStringIfNull(cardsDeliveryInformation);
            formDataRecord.E2E_Personal_Office_Email__c = personalOfficeEmail;
            formDataRecord.E2E_Manual_Entry_Legal_Info__c = isManualEntryLegalInfo;

            // Update executive fio only for legal person
            if (formParams.isSoleProprietor == false) {
                formDataRecord.E2E_Executive_Person__c = GlobalUtils.blankStringIfNull(executivePerson) + ', ' + GlobalUtils.blankStringIfNull(executivePersonTitle);
            }
        } else if (activeStep == GlobalUtils.E2ERuSteps.PaymentDetails) {
            // STEP PaymentDetails
            String checkingAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value;
            String bank = pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value;
            String BIC = pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value;
            String corBankAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value;
            String prepayAmount = pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').value;

            this.formDataValidator.validateIsNotBlank(prepayAmount, 'prepayAmount');

            formDataRecord.E2E_Bank__c = GlobalUtils.blankStringIfNull(bank);
            formDataRecord.E2E_BIC__c = GlobalUtils.blankStringIfNull(BIC);
            formDataRecord.E2E_Cor_Bank_Account__c = GlobalUtils.blankStringIfNull(corBankAccount);
            formDataRecord.E2E_Checking_Account__c = GlobalUtils.blankStringIfNull(checkingAccount);
            formDataRecord.E2E_Bank_Address__c = GlobalUtils.blankStringIfNull(formParams.bankAddress);
            formDataRecord.E2E_Bank_Name_Short__c = GlobalUtils.blankStringIfNull(formParams.bankNameShort);
            formDataRecord.E2E_Bank_OKPO__c = GlobalUtils.blankStringIfNull(formParams.bankOkpo);
            formDataRecord.E2E_Bank_Town__c = GlobalUtils.blankStringIfNull(formParams.bankTown);
            formDataRecord.E2E_Bank_Information_Invalid__c = formParams.isBankInformationInvalid;

            E2E_Form_Ru_General_Settings__c generalSettings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
            formDataRecord.E2E_Prepay_Amount__c = String.valueOf(Integer.valueOf(prepayAmount) < generalSettings.Prepay_Amount__c ? generalSettings.Prepay_Amount__c : Integer.valueOf(prepayAmount));
        }
        formDataRecord.E2E_Form_URL__c = formParams.generatedUrlWithHash;
        formDataRecord.E2E_Last_Step__c = step;
        formDataRecord.E2E_Source__c = source;
        formDataRecord.E2E_Process_Status__c = formParams.contactDetails + formParams.sfDeduplication1
                + formParams.sfDeduplication2 + formParams.getSparkData + formParams.checkedInBlackList
                + formParams.scoringPassed + formParams.sfDeduplication3 + formParams.sendCrmRequest
                + formParams.companyDetails + formParams.cardOrderDetails + formParams.legalDetails
                + formParams.paymentDetails + formParams.getReport + formParams.createContInTransit
                + formParams.sendMzkRequest + formParams.saveReport;
        formDataRecord.E2E_Form_URL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/e2eFormRu?country=Russia&link=' + formParams.encodedURL; // Save client link
        this.e2eFormRuDao.updateFormData(formDataRecord);
    }

    public class updateFormDataQueueable implements Queueable {
        public E2EFormData__c formDataRecord;
        public String updateCase;

        public updateFormDataQueueable(E2EFormData__c formData, String uCase) {
            formDataRecord = formData;
            updateCase = uCase;
        }

        public void execute(QueueableContext param1) {
            try {
                E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();
                if (updateCase == 'firstFormUrl') {
                    E2EFormData__c currentFormData = e2eFormRuDao.getFormDataById(formDataRecord.Id);
                    if (currentFormData.E2E_Form_URL__c == null) {
                        e2eFormRuDao.updateFormData(formDataRecord);
                    }
                }
            } catch (Exception e) {
                ExceptionLogger.sendException('<br/>E2E updateFormDataQueueable: ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
        }
    }

    /*******************************************************************************
   *  Name            : getFormData(Id formDataRecordId)
   *  Summary         : get Form Data record by id
   *  CreatedDate     : 18/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id formDataRecordId
   *  Returns         : form data record id
   ******************************************************************************/
    public E2EFormData__c getFormDataById(Id formDataRecordId) {
        return this.e2eFormRuDao.getFormDataById(formDataRecordId);
    }

    /*******************************************************************************
   *  Name            : changeObjectOwner(Id objectId, String newUserName)
   *  Summary         : change the object owner by id
   *  CreatedDate     : 10/10/2018
   *  ModifiedDate    : -
   *  Parameters      : Id objectId, String newUserName
   *  Returns         : -
   ******************************************************************************/
    public void changeObjectOwner(Id objectId, String newUserName) {
        changeObjectOwner(objectId, newUserName, true);
    }

    public sObject changeObjectOwner(Id objectId, String newUserName, Boolean Dml) {
        System.debug('!!!!!! changeObjectOwner');
        User userInfo = this.e2eFormRuDao.getUserByName(newUserName);
        if (userInfo != null) {
            try {
                // change Opportunity owner
                if (String.valueOf(objectId).subString(0, 3) == '006') {
                    Opportunity currentOpportunity = this.e2eFormRuDao.getOpportunityById(objectId);
                    currentOpportunity.OwnerId = userInfo.Id;
                    currentOpportunity.E2E_Status__c = 'Клиент Активен';
                    currentOpportunity.E2E_Last_Activity__c = Datetime.now();
                    if (Dml)this.e2eFormRuDao.updateOpportunity(currentOpportunity);
                    System.debug('***** OPPORTUNITY OBJECT OWNER WAS CHANGED: Id=' + objectId + ', newUser=' + newUserName);
                    return currentOpportunity;
                }

                if (String.valueOf(objectId).subString(0, 3) == '001') {
                    Account currentAccount = this.e2eFormRuDao.getAccountById(objectId);
                    currentAccount.OwnerId = userInfo.Id;
                    if (Dml)this.e2eFormRuDao.updateAccount(currentAccount);
                    System.debug('***** ACCOUNT OBJECT OWNER WAS CHANGED: Id=' + objectId + ', newUser=' + newUserName);
                    return currentAccount;
                }

                if (String.valueOf(objectId).subString(0, 3) == '003') {
                    Contact currentContact = this.e2eFormRuDao.getContactById(objectId);
                    currentContact.OwnerId = userInfo.Id;
                    if (Dml)this.e2eFormRuDao.updateContact(currentContact);
                    System.debug('***** CONTACT OBJECT OWNER WAS CHANGED: Id=' + objectId + ', newUser=' + newUserName);
                    return currentContact;
                }

                if (objectId.getsobjecttype().getDescribe().getName() == 'E2EFormData__c') {
                    E2EFormData__c currentFormData = this.e2eFormRuDao.getFormDataById(objectId);
                    currentFormData.OwnerId = userInfo.Id;
                    if (Dml)this.e2eFormRuDao.updateFormData(currentFormData);
                    System.debug('***** FORMDATA OBJECT OWNER WAS CHANGED: Id=' + objectId + ', newUser=' + newUserName);
                    return currentFormData;
                }
            } catch (Exception e) {
                System.debug('***** OBJECT OWNER CAN NOT BE CHANGED: newUserId=' + newUserName);
                throw new E2EFormRuException('SparkWebServiceImpl changeObjectOwner(): can not be changed');
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : getCurrentDataToShowOnForm(Account account, Opportunity opportunity, E2EFormData__c formData)
    *  Summary         : get data from objects and prepare them to show on a form
    *  CreatedDate     : 25/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Account account, Opportunity opportunity, E2EFormData formData
    *  Returns         : E2EFormParams e2eFormParams
    ******************************************************************************/
    public E2EFormParams getCurrentDataToShowOnForm(Account account, Opportunity oppty, E2EFormData__c formData) {
        OpportunityContactRole mainContact = new OpportunityContactRole();
        OpportunityContactRole executivePerson = new OpportunityContactRole();

        if (!oppty.OpportunityContactRoles.isEmpty()) {
            Map<String, OpportunityContactRole> opportunityContactRoles = markPrimaryAndAdditionalContactRole(oppty.OpportunityContactRoles);
            mainContact = opportunityContactRoles.get('main');
            executivePerson = opportunityContactRoles.get('addition1');
        }

        E2EFormParams e2eFormParams = new E2EFormParams();
        e2eFormParams.opportunityId = oppty.Id;
        e2eFormParams.source = oppty.Source_PP__c;
        e2eFormParams.sourcePP = oppty.Source_PP__c;
        e2eFormParams.contactId = mainContact != null && mainContact.ContactId != null ? mainContact.ContactId : null;
        e2eFormParams.contactFirstName = mainContact != null ? mainContact.Contact.FirstName : '';
        e2eFormParams.contactLastName = mainContact != null ? mainContact.Contact.LastName : '';
        e2eFormParams.contactFullName = RussianUtils.mergeContactFullNameInRussianFormat(e2eFormParams.contactLastName, e2eFormParams.contactFirstName, null);
        e2eFormParams.ipAddress = LongFormGlobalUtils.getUserIPAddress();
        e2eFormParams.mainContactEmail = mainContact != null ? mainContact.Contact.Email : '';
        e2eFormParams.mainContactPhone = mainContact != null ? mainContact.Contact.Phone : '';
        e2eFormParams.companyName = account.Name;
        e2eFormParams.mainCompanyFullNameSpark = formData.E2E_Main_Company_Full_Name__c != null ? formData.E2E_Main_Company_Full_Name__c : 'нет данных';
        e2eFormParams.companyInn = account.INN__c;
        e2eFormParams.isSoleProprietor = account.INN__c.length() == 12 ? true : false;
        e2eFormParams.verifiedDecision = formData.E2E_Black_List__c != null ? formData.E2E_Black_List__c : 'нет данных';
        e2eFormParams.verifiedLimitation = formData.E2E_Black_List_Limitations__c != null ? formData.E2E_Black_List_Limitations__c : 'нет данных';
        e2eFormParams.scoringDecision = formData.E2E_Scoring_Decision__c != null ? formData.E2E_Scoring_Decision__c : 'нет данных';
        e2eFormParams.scoringDate = formData.E2E_Scoring_Date__c;
        e2eFormParams.scoringDateString = formData.E2E_Scoring_Date__c != null ? ((Datetime) formData.E2E_Scoring_Date__c).format('dd.MM.YYYY') : 'нет данных';
        e2eFormParams.scoringExpirationDate = formData.E2E_Scoring_Expiration_Date__c;
        e2eFormParams.scoringExpirationDateString = formData.E2E_Scoring_Expiration_Date__c != null ? ((Datetime) formData.E2E_Scoring_Expiration_Date__c).format('dd.MM.YYYY') : 'нет данных';
        e2eFormParams.product = oppty.Product_PPR__c;
        e2eFormParams.numOfCards = oppty.Number_of_Cards__c;
        e2eFormParams.virtualCards = oppty.Virtual_cards__c;
        if (formData.E2E_Promo_Campaign__c != null) {
            List<String> promoList = formData.E2E_Promo_Campaign__c.split(';');
            if (promoList.size() > 0) e2eFormParams.promoCode = promoList[0];
            if (promoList.size() > 1) e2eFormParams.addPromoCode = promoList[1];
        }

        e2eFormParams.hasPersonalManager = formData.E2E_Personal_Manager_srv__c;
        e2eFormParams.hasDocumentDelivery = formData.E2E_Document_Delivery_srv__c;
        e2eFormParams.freeOverdraft = formData.Free_overdraft__c;
        e2eFormParams.ogrn = account.OGRN_ppr__c;
        e2eFormParams.okpo = account.OKPO_ppr__c;
        e2eFormParams.emptySparkOkpo = formData.E2E_Empty_SPARK_OKPO__c;
        e2eFormParams.kpp = formData.E2E_KPP__c;


        e2eFormParams.companyLegalAddressCity = account.BillingCity;
        e2eFormParams.companyLegalAddressPostalCode = formData.E2E_Billing_Code__c;
        e2eFormParams.companyLegalAddressState = formData.E2E_Billing_State__c;
        e2eFormParams.companyLegalAddressStreet = formData.E2E_Billing_Str__c;
        e2eFormParams.companyLegalAddressHouse = formData.E2E_Billing_House__c;

        String billingApartment = formData.E2E_Billing_Apartment__c == null ? '' : GlobalUtils.blankStringIfNull(formData.E2E_Billing_Apartment__c);
        e2eFormParams.legalAddressAdditionally = billingApartment;
        e2eFormParams.companyLegalAddress = GlobalUtils.blankStringIfNull(formData.E2E_Legal_Address__c);

        e2eFormParams.postalAddressCity = account.ShippingCity;
        e2eFormParams.postalAddressPostalCode = formData.E2E_Shipping_Code__c;
        e2eFormParams.postalAddressState = formData.E2E_Shipping_State__c;
        e2eFormParams.postalAddressStreet = formData.E2E_Shipping_Str__c;
        e2eFormParams.postalAddressHouse = formData.E2E_Shipping_House__c;

        String shippingApartment = formData.E2E_Shipping_Apartment__c == null ? '' : GlobalUtils.blankStringIfNull(formData.E2E_Shipping_Apartment__c);
        e2eFormParams.postalAddress = GlobalUtils.blankStringIfNull(formData.E2E_Post_Address__c);
        e2eFormParams.postalAddressAdditionally = shippingApartment;

        List<String> executiveProperties = GlobalUtils.blankStringIfNull(formData.E2E_Executive_Person__c).split(',');
        List<String> executivePropertiesManual = GlobalUtils.blankStringIfNull(formData.E2E_Executive_Person_Manual__c).split(',');
        e2eFormParams.executiveFioManual = (executivePropertiesManual.size() > 0) ? executivePropertiesManual.get(0) : '';
        e2eFormParams.executivePositionManual = (executivePropertiesManual.size() > 1) ? executivePropertiesManual.get(1).trim() : '';
        e2eFormParams.executiveFio = (executiveProperties.size() > 0) ? executiveProperties.get(0) : '';
        e2eFormParams.executivePosition = (executiveProperties.size() > 1) ? executiveProperties.get(1).trim() : '';
        e2eFormParams.codeWord = formData.E2E_Code_Word__c;
        e2eFormParams.emailForPersonalOffice = formData.E2E_Personal_Office_Email__c;
        e2eFormParams.personalOfficePhone = oppty.Personal_office_phone__c;
        e2eFormParams.deliveryComments = formData.E2E_Courier_Comments__c;
        e2eFormParams.bankName = formData.E2E_Bank__c;
        e2eFormParams.bankNameShort = formData.E2E_Bank_Name_Short__c;
        e2eFormParams.bankBic = formData.E2E_BIC__c;
        e2eFormParams.checkingAccount = account.Checking_Account__c;
        e2eFormParams.corBankAccount = account.Cor_bank_account__c;
        e2eFormParams.bankAddress = formData.E2E_Bank_Address__c;
        e2eFormParams.bankTown = formData.E2E_Bank_Town__c;
        e2eFormParams.bankOkpo = formData.E2E_Bank_OKPO__c;
        e2eFormParams.prepayAmount = formData.E2E_Prepay_Amount__c;
        e2eFormParams.transitContId = formData.E2E_Transit_Cont_Id__c;
        e2eFormParams.requestNumMZK = formData.E2E_Req_Num_MZK__c;
        //VS SF-1429
        e2eFormParams.electronicDocumentManagement = oppty.PPR_Electronic_document_management__c;
        return e2eFormParams;
    }

    public List<SelectOption> getFieldPickListSelectOptions(Schema.DescribeFieldResult fieldResult) {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> picklistEntries = GlobalUtils.getPicklistValuesTranslationsList(fieldResult);
        for (Schema.PicklistEntry entry : picklistEntries) {
            options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        return options;
    }

    public Map<String, OpportunityContactRole> markPrimaryAndAdditionalContactRole(List<OpportunityContactRole> contacts) {
        Map<String, OpportunityContactRole> contactsRoles = new Map<String, OpportunityContactRole>();
        Integer index = 1;
        for (Integer i = 0; i < contacts.size(); i++) {
            OpportunityContactRole contact = contacts.get(i);
            if (contact.IsPrimary == true) {
                contactsRoles.put('main', contact);
            } else {
                contactsRoles.put('addition' + index, contact);
                index++;
            }
        }
        return contactsRoles;
    }

    /*******************************************************************************
    *  Name            : getStepElements(GlobalUtils.E2ERuSteps step)
    *  Summary         : get step elements
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : GlobalUtils.E2ERuSteps step
    *  Returns         : List<String> elements
    ******************************************************************************/
    private List<String> getStepElements(GlobalUtils.E2ERuSteps step) {
        List<String> elements = new List<String>();
        if (step == GlobalUtils.E2ERuSteps.ContactDetails) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
        } else if (step == GlobalUtils.E2ERuSteps.CompanyInformation) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
        } else if (step == GlobalUtils.E2ERuSteps.Order || step == GlobalUtils.E2ERuSteps.SummaryOrder) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()));
        } else if (step == GlobalUtils.E2ERuSteps.LegalDetails) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.LegalDetails.name()));
        } else if (step == GlobalUtils.E2ERuSteps.PaymentDetails) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.LegalDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.PaymentDetails.name()));
        } else if (step == GlobalUtils.E2ERuSteps.Congratulations) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.LegalDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.PaymentDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Congratulations.name()));
        } else {
            throw new E2EFormRuException('E2EFormRuServiceImpl: step not found');
        }
        return elements;
    }

    /*******************************************************************************
   *  Name            : convertToStep(String stepName)
   *  Summary         : convert step name to step enum
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : String stepName
   *  Returns         : GlobalUtils.E2ERuSteps
   ******************************************************************************/
    private GlobalUtils.E2ERuSteps convertToStep(String stepName) {
        for (GlobalUtils.E2ERuSteps item : GlobalUtils.E2ERuSteps.values()) {
            if (item.name() == stepName) {
                return item;
            }
        }
        throw new E2EFormRuException('E2EFormRuServiceImpl: Could not convert ' + stepName + ' to enum GlobalUtils.E2ERuSteps.');
    }

    /*******************************************************************************
    *  Name            : convertPhone(String phoneNumber)
    *  Summary         : convert phone number to standard format eg (+7 (926) 777-77-77 => 9267777777)
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String phoneNumber
    *  Returns         : String
    ******************************************************************************/
    public String convertPhone(String phoneNumber) {
        String phoneRegex = '^(\\+7|7|8)?[\\s\\-]?\\(?([0-9]{3})\\)?[\\s\\-]?([0-9]{3})[\\s\\-]?([0-9]{2})[\\s\\-]?([0-9]{2})$';
        Pattern regexPattern = Pattern.compile(phoneRegex);
        Matcher regexMatcher = regexPattern.matcher(phoneNumber);
        if (regexMatcher.matches() && regexMatcher.groupCount() == 5) {
            return '+7' + ' ' + regexMatcher.group(2) + regexMatcher.group(3) + regexMatcher.group(4) + regexMatcher.group(5);
        } else {
            return '';
        }
    }

    public void collectDataFromSpark(Id formDataId, Id accountId, E2EFormParams formParams) {
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        Account account = this.e2eFormRuDao.getAccountById(accountId);

        formParams.normName = formDataRecord.E2E_Account_Short_Name__c;
        formParams.ogrnSpark = formDataRecord.E2E_OGRN__c;
        formParams.ogrnipSpark = formDataRecord.E2E_OGRN__c;
        formParams.okpoSpark = formDataRecord.E2E_OKPO__c;
        formParams.kppSpark = formDataRecord.E2E_KPP__c;
        formParams.sparkId = formDataRecord.E2E_Spark_Id__c != null ? Decimal.valueOf(formDataRecord.E2E_Spark_Id__c) : 0.0;

        // Address
        formParams.postCodeSpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Code__c);
        formParams.regionSpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_State__c);
        formParams.citySpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_City__c);
        formParams.streetSpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Str__c);
        formParams.billingApartment = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Apartment__c);
        formParams.legalAddressSpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Legal_Address__c);
        formParams.legalAddressAdditionally = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Apartment__c);
        formParams.postalAddress = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Post_Address__c);
        formParams.postalAddressAdditionally = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Shipping_Apartment__c);

        List<String> executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
        formParams.executiveFio = executivePersonData.get(0);
        formParams.executivePosition = executivePersonData.get(1);
    }

    //***** Transit Integration *****//

    public TransitRequestData prepareTransitRequestData(Id formDataId, E2EFormParams formParams, Map<String, LongFormPage> pagesMap, GlobalUtils.BusinessProcessType businessProcessType) {
        //TODO: pagesMap не используется, стоит рассмотреть удаление параметра, тк в будущем может привести к ошибке, если будет использоваться в E2EClassic например
        //TODO: либо выделить в условие E2E Business весь метод копипастом без pagesMap
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        Account account = this.e2eFormRuDao.getAccountById(formDataRecord.E2E_Account_Id__c);
        Opportunity opportunity = this.e2eFormRuDao.getOpportunityById(formDataRecord.E2E_Opportunity_Id__c);

        E2E_Form_Ru_General_Settings__c generalSettings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        if (generalSettings == null) {
            throw new E2EFormRuException('Error: prepareTransitRequestData(); E2E_Form_Ru_General_Settings__c does not found');
        }

        E2E_Form_Transit_Settings__c transitSettings = E2E_Form_Transit_Settings__c.getValues('E2EFormRu');
        if (transitSettings == null) {
            throw new E2EFormRuException('Error: prepareTransitRequestData(); E2E_Form_Transit_Settings__c does not found');
        }

        TransitRequestData transitRequestData = new TransitRequestData();
        transitRequestData.Personal = new List<TransitRequestData.Personal>();
        transitRequestData.Address = new List<TransitRequestData.Address>();

        // Persons
        // Add General Manager
        //VS SF-579
//        List<String> executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person_Manual__c);
        List<String> executivePersonData = new List<String>();
        if (businessProcessType == GlobalUtils.BusinessProcessType.E2EClassic) {
            executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
        } else {
            executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person_Manual__c);
        }
        String executivePersonFio = executivePersonData.get(0); // Fio
        String executivePersonPosition = executivePersonData.get(1); // Position

        TransitRequestData.Personal generalManager = new TransitRequestData.Personal();
        generalManager.fullName = executivePersonFio;
        preparePersonalFio(generalManager, executivePersonFio);
        generalManager.titleType = 1;

        if (account.Organization_Type__c == RussianUtils.SOLE_PROPRIETOR_SHORT) {
            generalManager.title = RussianUtils.SOLE_PROPRIETOR;
            generalManager.onBasis = String.format(transitSettings.On_Basis_Svidetelstva__c, new List<String>{
                    account.OGRN_ppr__c, formDataRecord.E2E_Reg_Date__c
            });
        } else {
            generalManager.title = executivePersonPosition != null ? executivePersonPosition.trim() : '';
            generalManager.onBasis = transitSettings.On_Basis_Ustava__c;
        }
        transitRequestData.Personal.add(generalManager);

        // Address
        TransitRequestData.Address address = new TransitRequestData.Address();
        address.rekType = Integer.valueOf(transitSettings.Cont_Rek_Type__c);
        if (formDataRecord.E2E_Billing_Code__c == null || formDataRecord.E2E_Legal_Address__c.startsWith(formDataRecord.E2E_Billing_Code__c)) {
            //VS SF-579
            /*address.address = String.format('{0} {1}', new List<String>{
                    formDataRecord.E2E_Legal_Address__c, GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Apartment__c)
            });*/
            address.address = formDataRecord.E2E_Legal_Address__c;
        } else {
            //VS SF-579
            address.address = String.format('{0} {1}', new List<String>{
                    formDataRecord.E2E_Billing_Code__c, formDataRecord.E2E_Legal_Address__c//, GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Apartment__c)
            });
        }
        address.postCode = account.ShippingPostalCode;
        address.mailCity = account.ShippingCity;
        address.mailStreet = account.ShippingStreet;
        address.mailReceiver = generalManager.fullName; // Получатель письма это ген. Директор personal.fullName = formParams.executiveFio
        transitRequestData.address.add(address); // Add address

        // Add Cont
        TransitRequestData.Cont cont = new TransitRequestData.Cont();
        //Add manager's transit ID in case the process is E2E Business
        if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EBusiness)) {
            cont.transitManagerId = formParams.transitManagerId;
        }
        cont.opportunityId = formDataRecord.E2E_Opportunity_Id__c;
        cont.contractNumber = String.format('{0}-{1}', new List<String>{
                formParams.contractPrefix, formParams.contractCounter
        });
        cont.inn = formDataRecord.E2E_INN__c;
        cont.okpo = account.OKPO_ppr__c;

        if (account.Organization_Type__c == 'ИП') {
            cont.companyName = formDataRecord.E2E_Account_Short_Name__c;
            //cont.companyName = formDataRecord.E2E_Account_Name__c;
            cont.companyType = 'ИП';
            cont.ogrn = account.OGRN_ppr__c;
            cont.kpp = null;
        } else {
            cont.companyName = '"' + formDataRecord.E2E_Account_Short_Name__c + '"';
//            cont.companyName = formDataRecord.E2E_Account_Name__c;
            cont.companyType = account.Organization_Type__c;
            cont.ogrn = account.OGRN_ppr__c;
            cont.kpp = formDataRecord.E2E_KPP__c;
        }

        cont.checkingAccount = account.Checking_Account__c;
        //VS SF-722
        cont.eqv = (formParams.idEqv != null) ? formParams.idEqv : 1;
        //cont.eqv = Integer.valueOf(transitSettings.Id_Eqv__c);                 // 1
        cont.contractType2 = transitSettings.Contract_Type_Commerce__c;        // 'CNT_SLS_OFFERS'в КФ шаг 3 (категория контагента->МО->обработать карты), в трз переносится автоматически. Только для обычной МО, на кМО проставляем сами
        cont.carParkType = Integer.valueOf(transitSettings.Car_Park_Type__c);  // КФ->ШАГ 1-> коммерческая информация-> тип автопарка->прочее(всегда стандартно- прочее) Это Константа: 1
        cont.carParkForm = Integer.valueOf(transitSettings.Car_Park_Vid__c);   // Это константа: 0. В транзите это прочерк. //
        cont.codeWord = account.Code_Word__c;
        cont.ruleChangeType = transitSettings.Order_Of_Conditions_Change__c;   // Это константа: 'RULCH_NOTIFY'. В транзите: "Уведомление"

        // set partner information and promotion
        if (formParams.sourcePP != null && formParams.sourcePP != '' && !'e2ecallcenter'.equalsIgnoreCase(formParams.sourcePP) || formParams.sourceLead == SOURCE_LEAD) {
            cont.clientFrom = Integer.valueOf(transitSettings.External_Client__c);// КФ-> коммерческая инфо -> тип канала поиска: 12 (партнер)
            cont.p_standart_promos = transitSettings.External_Standard_Promos__c;
        } else {
            cont.clientFrom = Integer.valueOf(transitSettings.Internal_Client__c);// КФ-> коммерческая инфо -> тип канала поиска: 11 (внутренний клиент, pertolplus)
            cont.p_standart_promos = transitSettings.Standard_Promos__c;
        }
        if (formParams.addPromoCodeIdInTransit != null && formParams.addPromoCodeIdInTransit != '') {
            cont.p_standart_promos += formParams.addPromoCodeIdInTransit + ';';
        }

        cont.partnerAlias = opportunity == null ? null : opportunity.Source_PP__c == null ? null : opportunity.Source_PP__c.toLowerCase();

        System.debug('*** TRANSIT --- DATA ***');
        // Init tariff
        System.debug('*** TRANSIT --- formDataRecord.E2E_Product_Id__c *** ' + formDataRecord.E2E_Product_Id__c);
        System.debug('*** TRANSIT --- formDataRecord.E2E_Tariff_Id__c *** ' + formDataRecord.E2E_Tariff_Id__c);
        Map<String, Object> tariff = PPRProductSettingsUtils.getTariffSettings(formDataRecord.E2E_Product_Id__c, formDataRecord.E2E_Tariff_Id__c);
        if (tariff != null) {
            cont.tarif = Integer.valueOf(tariff.get('transitId'));
        } else {
            throw new E2EFormRuException('Error: prepareTransitRequestData(); tariff ' + formDataRecord.E2E_Tariff_Id__c + ' does not found');
        }
        System.debug('TARIFF ID TRANSIT = ' + cont.tarif);

        // Init promocodes
        if (formParams.promocodeIdInTransit != null) {
            cont.promoCode = Integer.valueOf(formParams.promocodeIdInTransit);
        } else {
            cont.promoCode = 0;
        }

        Integer prepayAmount = 0;
        if (Integer.valueof(formDataRecord.E2E_Prepay_Amount__c) < generalSettings.Prepay_Amount__c) {
            prepayAmount = Integer.valueOf(generalSettings.Prepay_Amount__c);
        } else {
            prepayAmount = Integer.valueOf(formDataRecord.E2E_Prepay_Amount__c);
        }

        if (formDataRecord.Free_overdraft__c) {
            cont.lgotniyPeriod = Integer.valueOf(transitSettings.Lgotniy_Period__c);       // 0 если прошёл скоринг и выбрал овердрафт
            cont.prepayAmount = 100;
            cont.tipCredita = 2;                                                           // бесплатный
            cont.contractType = 2;                                                         // 2 - недельное кредитование
            cont.dueDate = 3;
            cont.dopustimayaZadolzenostSumma = Integer.valueOf(transitSettings.Allowed_Debt_Sum__c); // 50000 если прошёл скоринг и выбрал овердрафт
            cont.dopustimayaZadolzenostValuta = Integer.valueOf(transitSettings.Allowed_Debt_Currency__c); // рубли(0) если прошёл скоринг и выбрал овердрафт
            cont.znachenieOvedrafta = Integer.valueOf(transitSettings.Overdraft_Value__c); // -50000 если прошёл скоринг и выбрал овердрафт
            cont.opoveshatPoEmail = null;                                                  // проставляем вручную - в письме значения нет
            cont.overdrSumm = Integer.valueOf(transitSettings.Overdraft_Sum__c);           // -50000 если прошёл скоринг и выбрал овердрафт
            cont.uslugaDoveria = transitSettings.Usluga_Doveria__c;                        // 'N' если прошёл скоринг и выбрал овердрафт
            cont.bezDS = transitSettings.Bez_DS__c;                                        // 'N' если прошёл скоринг и выбрал овердрафт
        } else {
            cont.contractType = Integer.valueOf(transitSettings.Contract_Type_Fin_Multioffer__c); // 16 - Мультиоферта, 17 - Кредитный овердрафт
            cont.prepayAmount = prepayAmount;
        }

//        if (formDataRecord.E2E_Overdraft_srv__c == true) {
//            cont.factProsrochki = Integer.valueOf(transitSettings.Payment_For_Overdue__c); // 890 если прошёл скоринг и выбрал овердрафт
//            cont.lgotniyPeriod = Integer.valueOf(transitSettings.Lgotniy_Period__c);       // 0 если прошёл скоринг и выбрал овердрафт
//            cont.procentPoCreditu = transitSettings.Credit_Percent__c;                     // 0.09 если прошёл скоринг и выбрал овердрафт
//            cont.prepayAmount = 100;
//            cont.tipCredita = Integer.valueOf(transitSettings.Credit_Type__c);             // платный если прошёл скоринг и выбрал овердрафт
//            cont.contractType = Integer.valueOf(transitSettings.Contract_Type_Fin_Overdraft__c); // 16 - Мультиоферта, 17 - Кредитный овердрафт
//            cont.tipPeni = transitSettings.Type_Peni__c;                                   // 'Процентная ставка(%в день)' если прошёл скоринг и выбрал овердрафт
//            cont.znacheniePeni = transitSettings.Value_Peni__c;                            // 0.1 если прошёл скоринг и выбрал овердрафт
//            cont.dopustimayaZadolzenostSumma = Integer.valueOf(transitSettings.Allowed_Debt_Sum__c); // 50000 если прошёл скоринг и выбрал овердрафт
//            cont.dopustimayaZadolzenostValuta = Integer.valueOf(transitSettings.Allowed_Debt_Currency__c); // рубли(0) если прошёл скоринг и выбрал овердрафт
//            cont.znachenieOvedrafta = Integer.valueOf(transitSettings.Overdraft_Value__c); // -50000 если прошёл скоринг и выбрал овердрафт
//            cont.opoveshatPoEmail = null;                                                  // проставляем вручную - в письме значения нет
//            cont.overdrSumm = Integer.valueOf(transitSettings.Overdraft_Sum__c);           // -50000 если прошёл скоринг и выбрал овердрафт
//            cont.uslugaDoveria = transitSettings.Usluga_Doveria__c;                        // 'N' если прошёл скоринг и выбрал овердрафт
//            cont.bezDS = transitSettings.Bez_DS__c;                                        // 'N' если прошёл скоринг и выбрал овердрафт
//        } else {
//            cont.contractType = Integer.valueOf(transitSettings.Contract_Type_Fin_Multioffer__c); // 16 - Мультиоферта, 17 - Кредитный овердрафт
//            cont.prepayAmount = prepayAmount;
//        }

        cont.contractForm = transitSettings.Contract_Form__c; // это константа.
        cont.contractType1 = transitSettings.Contract_Type_Service__c; // Это константа!в КФ шаг 3 (категория контагента->МО->обработать карты), в трз переносится автоматически.
        cont.personalManager = formDataRecord.E2E_Personal_Manager_srv__c == true ? 1 : 0;
        cont.curierDelivery = formDataRecord.E2E_Document_Delivery_srv__c == true ? 1 : 0;
        cont.bic = formDataRecord.E2E_BIC__c;

        // Bank parameters
        cont.bankNameFull = formDataRecord.E2E_Bank__c;
        cont.bankNameShort = formDataRecord.E2E_Bank_Name_Short__c != null ? formDataRecord.E2E_Bank_Name_Short__c : formDataRecord.E2E_Bank__c;
        cont.bankBic = formDataRecord.E2E_BIC__c; // БИК РКЦ банка из Дадаты не приходит, поэтому заполняем обычным БИК банка (обязательное поле)
        cont.corBankAccount = formDataRecord.E2E_Cor_Bank_Account__c;
        cont.bankInn = null; // Уточняется: БРАТЬ ли ИНН! Нужно для сравнений
        cont.bankKpp = null; // Уточняется: БРАТЬ ли КПП! Нужно для сравнений
        cont.bankOkpo = formDataRecord.E2E_Bank_OKPO__c;
        cont.bankTown = formDataRecord.E2E_Bank_Town__c;
        cont.bankAddress = formDataRecord.E2E_Bank_Address__c;

        cont.companyPhone = String.format('{0}', new List<String>{
                convertPhone(formDataRecord.E2E_Contact_Phone__c)
        }).replaceAll(' ', '');

        //cont.companyPhone = formDataRecord.E2E_Contact_Phone__c.replaceAll(' ', '');
        cont.p_is_for_fin_sms = 1; // Это константа (можно не передавать) указ в кф, шаг 1 (Моб. для получения уведомлений финансового характера) в трз переносится автоматически
        cont.p_is_mobile = 1; // Это константа (можно не передавать) указ в кф, шаг 1 (Моб. для получения справочной информации) в трз переносится автоматически
        cont.companyEmail = formDataRecord.E2E_Contact_Email__c;
        cont.p_invoice_doc_num = String.format('{0}-{1}', new List<String>{
                formParams.invoicePrefix, formParams.invoiceCounter
        }); // Это генерируется репорт сервером
        cont.p_invoice_sum = prepayAmount;
        cont.p_invoice_sum_nds = ((prepayAmount / (1 + transitSettings.VAT__c)) * transitSettings.VAT__c).setScale(2);
        //cont.p_invoice_article = String.format('Оплата по договору от {0} № {1}-{2}', new List<String>{DateTime.now().format('dd.MM.YYYY'), formParams.contractPrefix, formParams.contractCounter}); // 'Оплата по договору от (дата, сегодняшняя) № (договора)'
        cont.p_invoice_article = String.format(transitSettings.Article_Oplata_Po_Dogovoru__c, new List<String>{
                DateTime.now().format('dd.MM.YYYY'), formParams.contractPrefix, formParams.contractCounter
        });
        cont.emailForLK = formDataRecord.E2E_Personal_Office_Email__c;
        cont.persOfficePhone = String.format('{0}', new List<String>{
                convertPhone(opportunity.Personal_office_phone__c)
        }).replaceAll(' ', '');
        cont.postcode = account.BillingPostalCode;
        cont.contractDate = DateTime.now().format('dd.MM.yyyy');

        // overdraft PPR_API
        if (businessProcessType.equals(GlobalUtils.BusinessProcessType.PPR_API)) {
            PPR_API_Settings__c setting = PPR_API_Settings__c.getValues(formDataRecord.E2E_Source__c);
            cont.tipCredita = Integer.valueOf(setting.Contract_Type__c);
            cont.contractType = Integer.valueOf(setting.Contract_Type__c);
            cont.dueDate = Integer.valueOf(setting.Due_date__c);
            cont.dopustimayaZadolzenostSumma = Integer.valueOf(formParams.overdraftSum);
            cont.dopustimayaZadolzenostValuta = Integer.valueOf(transitSettings.Allowed_Debt_Currency__c);
            cont.overdrSumm = -1 * cont.dopustimayaZadolzenostSumma;    //???
            cont.partnerGuarantor = cont.partnerAlias;
            cont.guaranteesDatein = cont.contractDate;
            cont.prepayAmount = Integer.valueOf(formDataRecord.E2E_Prepay_Amount__c);
        }

        transitRequestData.cont = cont;
        transitRequestData.EDMInfo = E2EFormRuServiceImplHelper.generateEDMInfo(transitRequestData, formParams);

        //SF-1288
        if (Boolean.valueOf(CFUtils.getScoringSettings('active'))) {
            TransitRequestData.ContMonitoring contMonitoring;
            Credit_Factory_Report__c cFReport = this.creditFactoryService.getCFR(
                opportunity.Id,
                CFUtils.FRAUD_SCORING_TYPE,
                CFUtils.RUSSIAN_FRAUD_RECORD_TYPE
            );

            if (cFReport == null) {
                isScoringTrue = true;
                OpportunityScoring scoring = this.creditFactoryService.processOpportunityScoring(formParams);
                contMonitoring = this.creditFactoryService.prepareScoringDataForTransit(scoring);
            } else {
                contMonitoring = this.creditFactoryService.prepareScoringDataForTransit(cFReport);
            }
            transitRequestData.contMonitoring = contMonitoring;
        }

        if (businessProcessType.equals(GlobalUtils.BusinessProcessType.E2EBusiness)) {
            Credit_Factory_Report__c creditFactryReport = this.creditFactoryService.getChosenCFR(opportunity.Id);
            if (creditFactryReport != null) {
                transitRequestData.cont.contractType = serviceHelper.getContractTypeByPeriod(creditFactryReport.RU_Scoring_Credit_Period__c);
                transitRequestData.cont.dueDate = Integer.valueOf(creditFactryReport.RU_Scoring_Payment_Time_Limit__c);
                transitRequestData.cont.dopustimayaZadolzenostSumma = Integer.valueOf(creditFactryReport.Credit_Limit__c);
                transitRequestData.cont.overdrSumm = -1 * transitRequestData.cont.dopustimayaZadolzenostSumma;

                if (creditFactryReport.RU_Scoring_Credit_Period__c == 30) {
                    transitRequestData.cont.invoiceDueDate = Integer.valueOf(creditFactryReport.RU_Scoring_Payment_Time_Limit__c);
                }
            }
        }

        return transitRequestData;
    }

    public TransitDocLinkRequestData prepareTransitDocLinkRequestData(ReportResponseData responseData, E2EFormParams formParams) {
        TransitDocLinkRequestData requestData = new TransitDocLinkRequestData();

        // set cont id
        requestData.idCont = formParams.transitContId;

        // init document list
        requestData.documentList = new List<TransitDocLinkRequestData.DocumentToLink>();

        for (ReportResponseData.ReportDocument document : responseData.reportDocumentList) {
            if (document.path != null && document.path.pdf != null && document.path.pdf != '') {
                TransitDocLinkRequestData.DocumentToLink docLink = new TransitDocLinkRequestData.DocumentToLink();
                docLink.docTypeId = document.reportTypeId;
                docLink.format = 'pdf';
                docLink.idLink = document.path.pdf;
                requestData.documentList.add(docLink);
            }
        }
        return requestData;
    }

    @TestVisible
    private void preparePersonalFio(TransitRequestData.Personal personal, String fio) {
        if (fio != null) {
            List<String> fioList = fio.split(' ');
            if (fioList.size() == 3) {
                personal.name = fioList.get(1);
                personal.surname = fioList.get(0);
                personal.parentName = fioList.get(2);
            } else if (fioList.size() == 2) {
                personal.name = fioList.get(1);
                personal.surname = fioList.get(0);
                personal.parentName = ' ';
            } else {
                personal.name = ' ';
                personal.surname = ' ';
                personal.parentName = ' ';
            }
        } else {
            personal.name = ' ';
            personal.surname = ' ';
            personal.parentName = ' ';
        }
    }

    //******** MZK Integration ********//

    public MZKRequest prepareMzkRequest(Id formDataId, E2EFormParams formParams) {
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        E2E_Form_MZK_Settings__c mzkSettings = E2E_Form_MZK_Settings__c.getValues('E2EFormRu');

        MZKRequest mzkRequest = new MZKRequest();
        if (mzkSettings != null) {
            mzkRequest.Cards = new MZKRequest.MzkCards();
            mzkRequest.Cards.sendType = mzkSettings.Send_Type__c.intValue();
            mzkRequest.Cards.transitId = formParams.transitContId;
            mzkRequest.Cards.requestDescription = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Courier_Comments__c);
            mzkRequest.Cards.logUser = mzkSettings.Log_User__c; //?
            mzkRequest.Cards.isTemplate = 0;
            mzkRequest.Cards.eqv = 1;
            mzkRequest.Cards.serviceId = mzkSettings.Service_Ids__c;
            mzkRequest.Cards.limitVal = mzkSettings.Limit_Values__c;
            mzkRequest.Cards.limitTypeId = mzkSettings.Limit_Type_Ids__c;
            mzkRequest.Cards.isCommon = mzkSettings.Is_Common__c;
            mzkRequest.Cards.isRuble = mzkSettings.Is_Ruble__c;
            mzkRequest.Cards.totalLimitValue = null;
            mzkRequest.Cards.totalLimitType = null;
            mzkRequest.Cards.cardsNumber = Integer.valueOf(formDataRecord.E2E_Num_Cards__c);
            mzkRequest.Cards.cardDescr = 'e2e';
            mzkRequest.Cards.serviceGroups = mzkSettings.Service_Groups__c;
//            mzkRequest.Cards.virtualCards = formParams.virtualCards ? 1 : 0;

            // Add product Id
            mzkRequest.Cards.productId = (Integer) PPRProductSettingsUtils.getProductSettings(formDataRecord.E2E_Product_Id__c).get('mzkId');
            System.debug('PRODUCT ID MZK = ' + mzkRequest.Cards.productId);

        } else {
            throw new E2EFormRuException('MZK Setting does not found');
        }
        return mzkRequest;
    }

    //*********** Crm Integration ********//

    public CrmTask prepareCrmRequest(String phone, String email, String inn, List<Opportunity> opportunities) {
        E2E_Form_CRM_Settings__c crmSettings = E2E_Form_CRM_Settings__c.getValues('E2EFormRu');
        CrmTask task = new CrmTask();
        if (crmSettings != null) {
            task.OwnerId = crmSettings.Task_OwnerId__c;
            task.SubjectId = crmSettings.Task_SubjectId__c;
            task.Title = crmSettings.Task_Title__c;
            task.CaseOriginCode = Integer.valueOf(crmSettings.Task_Case_Origin_Code__c);
            task.Description = String.format('Тел: {0}; e-mail: {1}; ИНН: {2}; ', new List<String>{
                    phone, email, inn
            });

            // Add CONT_ID in to Description
            List<String> transitIds = new List<String>();
            for (Opportunity opportunity : opportunities) {
                if (opportunity.Transit_ID__c != null) {
                    transitIds.add(opportunity.Transit_ID__c);
                }
            }

            if (!transitIds.isEmpty()) {
                task.Description += 'CONT_IDS: ' + String.join(transitIds, ',');
            }
        } else {
            throw new E2EFormRuException('Crm Setting does not found');
        }
        return task;
    }


    //******* Duplicate Process *****//

    /*******************************************************************************
    *  Name            : duplicateLeadProcess(Map<String, LongFormPage> pagesMap)
    *  Summary         : duplicate lead
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<String, LongFormPage> pagesMap
    *  Returns         : void
    ******************************************************************************/
    public void duplicateLeadProcess(Map<String, LongFormPage> pagesMap) {
        System.debug('***** DEDUPLICATION LEAD');
        String phone = convertPhone(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value);
        String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;

        this.formDataValidator.validateMobilePhone(phone);
        this.formDataValidator.validateEmail(email);

        duplicateLeadProcess(email, phone);
    }

    @Future
    private static void duplicateLeadProcess(String email, String phone) {
        System.debug('***** DEDUPLICATION LEAD FUTURE');
        try {
            E2EFormRuDaoImpl e2EFormRuDao = new E2EFormRuDaoImpl();
            String formattedPhone = PhoneNumberUtils.getRawPhoneNumber(phone);
            List<Lead> duplicateLeadsList = e2EFormRuDao.getDuplicatedLeads(email, formattedPhone);
            duplicateLeadsList = E2EFormRuServiceImplHelper.matchAdditionalEmails(duplicateLeadsList, email, formattedPhone);
            System.debug('****** DEDUPLICATION LEAD FUTURE: find leads by email:' + email + ' or phone:' + phone + ' => ' + duplicateLeadsList);

            if (!duplicateLeadsList.isEmpty()) {

                for (Lead lead : duplicateLeadsList) {
                    lead.Status = 'Disqualified';
                    lead.Lead_Status_Specific__c = 'Switched to E2E';
                }

                //Send email notifications
                E2E_RU_Internal_Notifications.duplicateLeadProcess(duplicateLeadsList);

                e2EFormRuDao.updateLeads(duplicateLeadsList);
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method @future duplicateLeadProcess(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    // Проверка, что клиент только сейчас заходил, вышел и снова зашел
    /*******************************************************************************
    *  Name            : deduplicateE2EClient()
    *  Summary         : Verifying that a customer has recently logged in
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String name, Map<String, LongFormPage> pagesMap
    *  Returns         : Map<String, String> - map contains five key: 1. accountId  2. opportunityId 3. contactId 4. formDataId 5. statusCode
    ******************************************************************************/
    public Map<String, String> deduplicateE2EClient(String name, Map<String, LongFormPage> pagesMap) {
        System.debug('********* E2E method deduplicateE2EClient ****************');
        String phone = PhoneNumberUtils.getRawPhoneNumber(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value);
        String email = GlobalUtils.blankStringIfNull(pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value);

        if (phone != '' && email != '') {
            List<Contact> contacts = this.e2eFormRuDao.getContactsByNamePhoneEmail(name, phone, email, 'e2edefault@default.ru');
            contacts = E2EFormRuServiceImplHelper.matchAdditionalEmails(contacts, email);
            System.debug('deduplicateE2EClient: ' + contacts);
            if (!contacts.isEmpty()) {
                List<E2EFormData__c> formDataList = this.e2eFormRuDao.getFormDataByAccountIdAndContactId(contacts.get(0).AccountId, contacts.get(0).Id);
                if (!formDataList.isEmpty()) {
                    if (formDataList.get(0).E2E_Opportunity_Id__c != null) {
                        Opportunity e2eOpportunity = this.e2eFormRuDao.getOpportunityById(formDataList.get(0).E2E_Opportunity_Id__c);
                        if (e2eOpportunity != null && e2eOpportunity.StageName != 'Awaiting payment' && e2eOpportunity.IsClosed == false) {
                            return new Map<String, String>{
                                    'accountId' => formDataList.get(0).E2E_Account_Id__c,
                                    'opportunityId' => formDataList.get(0).E2E_Opportunity_Id__c,
                                    'contactId' => formDataList.get(0).E2E_Contact_Id__c,
                                    'formDataId' => formDataList.get(0).Id,
                                    'statusCode' => GlobalUtils.DeduplicationStatus.E2EProcess.name()
                            };
                        }
                    }
                }
            }
        }
        return new Map<String, String>();
    }

    /*******************************************************************************
    *  Name            : deduplicationAccountProcess()
    *  Summary         : duplicate account
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String INN, Id e2eAccountId, Id e2eContactId, Id e2eOpportunityId, String statusCode
    *  Returns         : Map<String, String> - map contains two key: 1. accountId  2. statusCode
    ******************************************************************************/
    public E2EFormRuDeduplicationResult deduplicationAccountProcess(String INN, String email, Id e2eAccountId, Id e2eContactId, Id e2eOpportunityId, Id formDataId) {
        // init deduplication result class
        E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
        deduplicationResult.formDataId = formDataId;
        deduplicationResult.e2eAccount = this.e2eFormRuDao.getAccountById(e2eAccountId);
        deduplicationResult.e2eContact = this.e2eFormRuDao.getContactById(e2eContactId);
        deduplicationResult.e2eOpportunity = this.e2eFormRuDao.getOpportunityById(e2eOpportunityId);

        return deduplicationAccountProcess(INN, email, deduplicationResult);
    }

    /*******************************************************************************
    *  Name            : deduplicationAccountProcess(String INN, String email, E2EFormRuDeduplicationResult deduplicationResult)
    *  Summary         : duplicate account by INN and email
    *  CreatedDate     : 25/09/2018
    *  ModifiedDate    : 04/03/2019
    *  Parameters      : String INN, String email, E2EFormRuDeduplicationResult deduplicationResult
    *  Returns         : E2EFormRuDeduplicationResult
    ******************************************************************************/
    public E2EFormRuDeduplicationResult deduplicationAccountProcess(String INN, String email, E2EFormRuDeduplicationResult deduplicationResult) {
        deduplicationResult.deduplicationDatetime = Datetime.now();
        List<Account> duplicateAllAccounts = this.e2eFormRuDao.getAccountsByINN(INN);
        System.debug('******* DEDUPLICATION PROCESS: duplicateAllAccounts size ' + duplicateAllAccounts.size());
        System.debug('******* DEDUPLICATION PROCESS: (Search account by INN): Find by INN=' + INN + ' ' + duplicateAllAccounts);

        List<Account> duplicateAccountsList = excludeAccounts(duplicateAllAccounts, deduplicationResult.e2eAccount);
        System.debug('******* DEDUPLICATION PROCESS: duplicateAccountsList size ' + duplicateAccountsList.size());

        System.debug('******* DEDUPLICATION PROCESS: after exclude account ' + deduplicationResult.e2eAccount + '; resultList: ' + duplicateAccountsList);

        if (duplicateAccountsList.isEmpty()) {
            System.debug('******* DEDUPLICATION PROCESS: (Search account by INN): Does not found any account by INN=' + INN);

            deduplicationResult.innDuplication = false;
            Id e2eContactIdForExclude = deduplicationResult.e2eContact != null ? deduplicationResult.e2eContact.Id : null;
            String domain = email.substringAfter('@');
            System.debug('******* DEDUPLICATION PROCESS: Search contact by domain=' + domain);
            Set<String> setPublicDomains = PublicEmailDomains__c.getAll().keySet();
            if (setPublicDomains.contains(domain)) {
                System.debug('******* DEDUPLICATION PROCESS: Search contact by email');
                List<Contact> contactListFindByEmail = searchDuplicatedContactsByEmail(email, e2eContactIdForExclude);

                //SF-1313
                contactListFindByEmail = E2EFormRuServiceImplHelper.exculeObjectsFromList(
                    contactListFindByEmail,
                    deduplicationResult.excludedContacts);

                if (!contactListFindByEmail.isEmpty()) {
                    deduplicationResult.isEmailDuplicated = true;
                    Set<Id> accountsIds = new Set<Id>();
                    for (Contact contact : contactListFindByEmail) {
                        accountsIds.add(contact.AccountId);
                    }
                    List<Account> accountsByEmail = this.e2eFormRuDao.getAccountsByIds(accountsIds).values();
                    deduplicationResult.sfAccount = accountsByEmail.get(0);
                    for (Account account : accountsByEmail) {
                        Boolean transferToService = checkingTransferToService(account);
                        if (transferToService) {
                            deduplicationResult.sfAccount = account;
                            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
                            return deduplicationResult;
                        }
                    }
                    checkingOpportunityTransfer(deduplicationResult);
                    return deduplicationResult;
                } else {
                    return deduplicationResult;
                }
            } else {
                System.debug('******* DEDUPLICATION PROCESS: Search contact by domain=' + domain);
                List<Contact> contactListByDomain = searchDuplicatedContactsByDomain(domain, e2eContactIdForExclude);

                //SF-1313
                contactListByDomain = E2EFormRuServiceImplHelper.exculeObjectsFromList(
                    contactListByDomain,
                    deduplicationResult.excludedContacts);

                if (!contactListByDomain.isEmpty()) {
                    deduplicationResult.isDomainDuplicated = true;
                    Set<Id> accountsIds = new Set<Id>();
                    for (Contact contact : contactListByDomain) {
                        accountsIds.add(contact.AccountId);
                    }
                    List<Account> accountsByDomain = this.e2eFormRuDao.getAccountsByIds(accountsIds).values();
                    deduplicationResult.sfAccount = accountsByDomain.get(0);
                    for (Account account : accountsByDomain) {
                        Boolean transferToService = checkingTransferToService(account);
                        if (transferToService) {
                            deduplicationResult.sfAccount = account;
                            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
                            return deduplicationResult;
                        }
                    }
                    checkingOpportunityTransfer(deduplicationResult);
                    return deduplicationResult;
                } else {
                    return deduplicationResult;
                }
            }
        } else if (duplicateAccountsList.size() == 1) {
            System.debug('******* DEDUPLICATION PROCESS (Search account by INN): Find account by INN=' + INN + '; accountId=' + duplicateAccountsList.get(0).Id);
            deduplicationResult.innDuplication = true;
            deduplicationResult.sfAccount = duplicateAccountsList.get(0);

            Id e2eContactIdForExclude = deduplicationResult.e2eContact != null ? deduplicationResult.e2eContact.Id : null;
            String domain = email.substringAfter('@');
            Set<String> setPublicDomains = PublicEmailDomains__c.getAll().keySet();
            if (setPublicDomains.contains(domain)) {
                System.debug('******* DEDUPLICATION PROCESS: Search contact by email');
                List<Contact> contactListFindByEmail = searchDuplicatedContactsByEmail(email, e2eContactIdForExclude);

                //SF-1313
                contactListFindByEmail = E2EFormRuServiceImplHelper.exculeObjectsFromList(
                    contactListFindByEmail,
                    deduplicationResult.excludedContacts);

                if (!contactListFindByEmail.isEmpty()) {
                    Set<Id> accountsIds = new Set<Id>();
                    for (Contact contact : contactListFindByEmail) {
                        accountsIds.add(contact.AccountId);
                    }
                    List<Account> accountsByEmail = this.e2eFormRuDao.getAccountsByIds(accountsIds).values();
                    for (Account account : accountsByEmail) {
                        Boolean transferToService = checkingTransferToService(account);
                        if (transferToService) {
                            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
                            return deduplicationResult;
                        }
                    }
                }
            } else {
                System.debug('******* DEDUPLICATION PROCESS: Search contact by domain=' + domain);
                List<Contact> contactListByDomain = searchDuplicatedContactsByDomain(domain, e2eContactIdForExclude);

                //SF-1313
                contactListByDomain = E2EFormRuServiceImplHelper.exculeObjectsFromList(
                    contactListByDomain,
                    deduplicationResult.excludedContacts);

                if (!contactListByDomain.isEmpty()) {
                    Set<Id> accountsIds = new Set<Id>();
                    for (Contact contact : contactListByDomain) {
                        accountsIds.add(contact.AccountId);
                    }
                    List<Account> accountsByDomain = this.e2eFormRuDao.getAccountsByIds(accountsIds).values();
                    for (Account account : accountsByDomain) {
                        Boolean transferToService = checkingTransferToService(account);
                        if (transferToService) {
                            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
                            return deduplicationResult;
                        }
                    }
                }
            }

            deduplicationSingleAccount(deduplicationResult);
            return deduplicationResult;
        } else {
            // Если Account больше одного, то все, ошибка
            System.debug('******* DEDUPLICATION PROCESS (Search account by INN): Find more one account accountList= ' + duplicateAccountsList);
            throw new E2EFormRuException('******* DEDUPLICATION PROCESS (Search account by INN): Find more one account accountList= ' + duplicateAccountsList);
        }
    }

    private List<Account> excludeAccounts(List<Account> accountList, Account excludeAccount) {
        if (excludeAccount != null && excludeAccount.Id != null) {
            List<Account> freshAccountList = new List<Account>();
            for (Account account : accountList) {
                if (account.Id != excludeAccount.Id) {
                    freshAccountList.add(account);
                }
            }
            return freshAccountList;
        }
        return accountList;
    }

    private void deduplicationSingleAccount(E2EFormRuDeduplicationResult deduplicationResult) {
        if (checkingTransferToService(deduplicationResult.sfAccount)) {
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
            System.debug('******* DEDUPLICATION PROCESS: transfer account to Service; accountId=' + deduplicationResult.sfAccount.Id);
        } else {
            System.debug('******* DEDUPLICATION PROCESS: check opportunity status;');
            checkingOpportunityTransfer(deduplicationResult);
        }
    }

    private List<Contact> searchDuplicatedContactsByEmail(String email, Id contactId) {
        List<Contact> withoutExtraContactList = new List<Contact>();
        List<Contact> contacts = this.e2eFormRuDao.getContactsByEmail(email);
        for (Contact contact : E2EFormRuServiceImplHelper.matchAdditionalEmails(contacts, email)) {
            if (contact.Id != contactId) {
                withoutExtraContactList.add(contact);
            }
        }
        return withoutExtraContactList;
    }

    private List<Contact> searchDuplicatedContactsByDomain(String domain, Id contactId) {
        List<Contact> withoutExtraContactList = new List<Contact>();
        for (Contact contact : this.e2eFormRuDao.getContactsByDomain(domain)) {
            if (contact.Id != contactId) {
                withoutExtraContactList.add(contact);
            }
        }
        return withoutExtraContactList;
    }

    public E2EFormRuDeduplicationResult transferCustomer(E2EFormRuDeduplicationResult deduplicationResult) {
        if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
            transferToService(deduplicationResult);
        } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Inbound.name()) {
            transferToInbound(deduplicationResult);
        } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.KO.name()) {
            transferToKO(deduplicationResult);
        } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.E2EProcess.name()) {
            transferToE2E(deduplicationResult);
        }
        return deduplicationResult;
    }

    /*******************************************************************************
    *  Name            : checkingTransferToService(Account account)
    *  Summary         : check that account must transferred to Service
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account account
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean checkingTransferToService(Account account) {
        System.debug('******* DEDUPLICATION PROCESS: start check transfer to Service');
        Date nowDate = Date.Today();
        if (account.Last_pump_date__c >= nowDate.addYears(-1)) {
            System.debug('******* DEDUPLICATION PROCESS: check transfer to Service = TRUE');
            return true;
        } else if (account.Opportunities != null && !account.Opportunities.isEmpty()) {
            for (Opportunity opportunity : account.Opportunities) {
                if (opportunity.StageName == 'Moved to Start' && opportunity.CloseDate >= nowDate.addMonths(-6)) {
                    System.debug('******* DEDUPLICATION PROCESS: check transfer to Service = TRUE');
                    return true;
                }
            }
        }
        System.debug('******* DEDUPLICATION PROCESS: start check transfer to Service = FALSE');
        return false;
    }

    /*******************************************************************************
    *  Name            : checkingOpportunityTransfer()
    *  Summary         : check the conditions under which  opportunity must transferred to Service or KO
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity, String statusCode
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void checkingOpportunityTransfer(E2EFormRuDeduplicationResult deduplicationResult) {
        List<Opportunity> opportunities = deduplicationResult.sfAccount.Opportunities;
        System.debug('******* DEDUPLICATION PROCESS: all opportunities = ' + opportunities);

        //SF-1313 start
        //Opportunity "Reanimation" exclusion
        if (deduplicationResult.excludedOpportunities != null && !deduplicationResult.excludedOpportunities.isEmpty()) {
            opportunities = E2EFormRuServiceImplHelper.exculeObjectsFromList(opportunities, deduplicationResult.excludedOpportunities);
        }
        //SF-1313 end		

        if (!opportunities.isEmpty() && deduplicationResult.e2eOpportunity != null) {
            E2EFormRuServiceImplHelper.checkingOwnerForOpportunities(opportunities, deduplicationResult);
        }

        if (opportunities.size() == 0) {
            System.debug('******* DEDUPLICATION PROCESS: account not have opportunity; Go to E2E');
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name(); // go to E2E process
        } else if (opportunities.size() == 1) {
            System.debug('******* DEDUPLICATION PROCESS: account have one opportunity; opportunityId=' + opportunities.get(0).Id);
            if (checkOpportunityGoToKO(opportunities.get(0))) {
                System.debug('******* DEDUPLICATION PROCESS: go to KO');
                // go to KO
                deduplicationResult.sfOpportunity = opportunities.get(0);
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
            } else {
                System.debug('******* DEDUPLICATION PROCESS: go to E2E');
                // go to E2E
                deduplicationResult.sfOpportunity = opportunities.get(0);
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
            }
        } else if (opportunities.size() == 2) {
            System.debug('******* DEDUPLICATION PROCESS: account have two opportunity; opportunities' + opportunities);
            Opportunity firstOpportunity = opportunities.get(0);
            Opportunity secondOpportunity = opportunities.get(1);
            if (shouldOpportunityBeTransferredToInbound(firstOpportunity, secondOpportunity)) {
                // go to Inbound
                System.debug('******* DEDUPLICATION PROCESS: Go to Inbound;');
                deduplicationResult.sfOpportunity = opportunities.get(0);
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Inbound.name();
            } else if (shouldOpportunityBeTransferredToKO(firstOpportunity, secondOpportunity)) {
                // go to KO
                System.debug('******* DEDUPLICATION PROCESS: Go to KO;');
                if (opportunityInProgress(firstOpportunity)) {  // check opportunity stage
                    deduplicationResult.sfOpportunity = firstOpportunity;
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
                } else {
                    deduplicationResult.sfOpportunity = secondOpportunity;
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
                }
            } else {
                // go to E2E
                System.debug('******* DEDUPLICATION PROCESS: Go to E2E;');
                if (opportunityInProgress(firstOpportunity)) {
                    deduplicationResult.sfOpportunity = firstOpportunity;
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
                } else if (opportunityInProgress(secondOpportunity)) {
                    deduplicationResult.sfOpportunity = secondOpportunity;
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
                } else {
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
                }
            }
        } else {
            // TODO: Берем то только те у которых isClosed == false и смотрим их количество.
            // Если isClosed.count == 0 то E2E
            // Если isClosed.count == 1 то таблица
            // Если isClosed.count >= 2 то Inbound
            System.debug('******* DEDUPLICATION PROCESS: count of opportunities more that 3');
            List<Opportunity> isClosedOpportunityList = new List<Opportunity>();
            for (Opportunity opportunity : opportunities) {
                if (opportunity.IsClosed == false) {
                    isClosedOpportunityList.add(opportunity);
                }
            }

            System.debug('******* DEDUPLICATION PROCESS: isClosed opportunities: ' + isClosedOpportunityList);
            if (isClosedOpportunityList.isEmpty()) {
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
            } else if (isClosedOpportunityList.size() == 1) {
                if (checkOpportunityGoToKO(isClosedOpportunityList.get(0))) {
                    System.debug('******* DEDUPLICATION PROCESS: go to KO');
                    // go to KO
                    deduplicationResult.sfOpportunity = isClosedOpportunityList.get(0);
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: go to E2E');
                    // go to E2E
                    deduplicationResult.sfOpportunity = isClosedOpportunityList.get(0);
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
                }
            } else {
                System.debug('******* DEDUPLICATION PROCESS: Go to Inbound;');
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Inbound.name();
            }
        }
    }

    /*******************************************************************************
    *  Name            : shouldOpportunityBeTransferredToInbound()
    *  Summary         : check stage under which  opportunity must transferred to Inbound
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity firstOpportunity, Opportunity secondOpportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean shouldOpportunityBeTransferredToInbound(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        System.debug('******* DEDUPLICATION PROCESS: Check opportunity transfer to Inbound;');
        System.debug('******* DEDUPLICATION PROCESS: firstOpportunity=' + firstOpportunity + '; secondOpportunity=' + secondOpportunity);
        if (firstOpportunity.StageName == 'Moved to Start' && secondOpportunity.StageName == 'Moved to Start') {
            return false; // go to E2E
        } else if (firstOpportunity.StageName == 'Отказ' && secondOpportunity.StageName == 'Отказ') {
            return false; // go to E2E
        } else if (opportunityInProgress(firstOpportunity) && opportunityInProgress(secondOpportunity)) {
            return true; // go to Inbound
        } else if (firstOpportunity.StageName == 'Отказ' && secondOpportunity.StageName == 'Moved to Start') {
            return false; // go to E2E
        } else if (firstOpportunity.StageName == 'Moved to Start' && secondOpportunity.StageName == 'Отказ') {
            return false; // go to E2E
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : shouldOpportunityBeTransferredToKO()
    *  Summary         : if we have two opportunity on account,
    *                    we must check stage under which opportunity need transferred to KO (Sales department)
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity firstOpportunity, Opportunity secondOpportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean shouldOpportunityBeTransferredToKO(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        System.debug('******* DEDUPLICATION PROCESS: Check opportunity transfer to KO;');
        System.debug('******* DEDUPLICATION PROCESS: firstOpportunity=' + firstOpportunity + '; secondOpportunity=' + secondOpportunity);
        if (firstOpportunity.StageName == 'Moved to Start' && opportunityInProgress(secondOpportunity)) {
            return checkOpportunityGoToKO(secondOpportunity);
        } else if (opportunityInProgress(firstOpportunity) && secondOpportunity.StageName == 'Moved to Start') {
            return checkOpportunityGoToKO(firstOpportunity);
        } else if (firstOpportunity.StageName == 'Отказ' && opportunityInProgress(secondOpportunity)) {
            return checkOpportunityGoToKO(secondOpportunity);
        } else if (opportunityInProgress(firstOpportunity) && secondOpportunity.StageName == 'Отказ') {
            return checkOpportunityGoToKO(firstOpportunity);
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : opportunityInProgress(Opportunity opportunity)
    *  Summary         : check that opportunity in progress status
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean opportunityInProgress(Opportunity opportunity) {
        if (opportunity.StageName == 'Qualified Lead' ||
                opportunity.StageName == 'Client Negotiations' ||
                opportunity.StageName == 'Check Credit History' ||
                opportunity.StageName == 'Agreement Terms and Conditions' ||
                opportunity.StageName == 'Договор на проверке' ||
                opportunity.StageName == 'Contract Under Signing' ||
                opportunity.StageName == 'Signing of a Contract' ||
                opportunity.StageName == 'Awaiting payment' ||
                opportunity.StageName == 'Suspended Opportunity') {
            return true;
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : checkOpportunityGoToKO(Opportunity opportunity)
    *  Summary         : check opportunity stage under which opportunity must transferred to KO
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean checkOpportunityGoToKO(Opportunity opportunity) {
        System.debug('******* DEDUPLICATION PROCESS: check transfer to KO');
        System.debug('******* DEDUPLICATION PROCESS: opportunity.StageName -> ' + opportunity.StageName);
        if (opportunity.StageName == 'Qualified Lead' ||
                opportunity.StageName == 'Client Negotiations' ||
                opportunity.StageName == 'Check Credit History' ||
                opportunity.StageName == 'Agreement Terms and Conditions' ||
                opportunity.StageName == 'Suspended Opportunity' ||
                opportunity.StageName == 'Отказ' ||
                opportunity.StageName == 'Потерян в конкуренции' ||
                opportunity.StageName == 'Moved to Start') {
            System.debug('******* DEDUPLICATION PROCESS: FALSE');
            return false;
        }

        List<OpportunityHistory> historyList = this.e2eFormRuDao.getLastModifiedStageByOpportunityId(opportunity.Id);
        System.debug('historyList: ' + historyList);

        // if history is empty that opportunity was migrated from other source
        if (!historyList.isEmpty() || Test.isRunningTest()) {

            Date lastModifiedStageDate = Date.Today();
            if (Test.isRunningTest()) {
                lastModifiedStageDate = opportunity.CloseDate;
            } else {
                lastModifiedStageDate = historyList.get(0).CloseDate;
            }

            Date nowDate = Date.Today();

            if (opportunity.StageName == 'Договор на проверке') {
                System.debug('Договор на проверке ************');
                if (nowDate.daysBetween(lastModifiedStageDate) > 5) {
                    System.debug('******* DEDUPLICATION PROCESS: FALSE');
                    return false; // go to E2E
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: TRUE');
                    return true; // go to KO
                }
            }

            if (opportunity.StageName == 'Contract Under Signing') {
                if (nowDate.daysBetween(lastModifiedStageDate) > 14) {
                    System.debug('******* DEDUPLICATION PROCESS: FALSE');
                    return false; // go to E2E
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: TRUE');
                    return true; // go to KO
                }
            }

            if (opportunity.StageName == 'Signing of a Contract') {
                if (nowDate.daysBetween(lastModifiedStageDate) > 14) {
                    System.debug('******* DEDUPLICATION PROCESS: FALSE');
                    return false; // go to E2E
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: TRUE');
                    return true; // go to KO
                }
            }

            if (opportunity.StageName == 'Awaiting payment') {
                if (nowDate.monthsBetween(lastModifiedStageDate) > 6) {
                    System.debug('******* DEDUPLICATION PROCESS: FALSE');
                    return false; // go to E2E
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: TRUE');
                    return true; // go to KO
                }
            }
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : transferToService()
    *  Summary         : convert E2E process to Service
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void transferToService(E2EFormRuDeduplicationResult deduplicationResult) {
        System.debug('******* DEDUPLICATION PROCESS: execute transferToService');

        transferToService(deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId
        );

        if (deduplicationResult.innDuplication == true) {
            deduplicationResult.e2eAccount = deduplicationResult.sfAccount;
        }
    }

    @Future
    public static void transferToService(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId, Id e2eContactId, Id formDataId) {
        try {
            E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
            Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);

            if (sfAccount != null) {
                if (innDuplication == true) {
                    // update  E2E opportunity
                    Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                    e2eOpportunity.AccountId = sfAccountId;
                    e2eOpportunity.StageName = 'Отказ';
                    e2eOpportunity.PPR_Lost_Reasons__c = 'Существующий клиент';
                    e2eOpportunity.E2E_Status__c = 'Клиент завершил';
                    e2eFormRuDao.updateOpportunity(e2eOpportunity);

                    // update E2E contact
                    Contact e2eContact = new Contact(Id = e2eContactId);
                    e2eContact.AccountId = sfAccountId;
                    e2eFormRuDao.updateContact(e2eContact);

                    // update E2E FormData
                    E2EFormData__c formData = new E2EFormData__c(Id = formDataId);
                    formData.E2E_Account_Id__c = sfAccountId;
                    e2eFormRuDao.updateFormData(formData);

                    // delete E2E Account
                    if (e2eAccountId != sfAccountId) {
                        deleteAccountById(e2eAccountId);
                    }
                } else {
                    // update  E2E opportunity
                    Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                    e2eOpportunity.StageName = 'Отказ';
                    e2eOpportunity.PPR_Lost_Reasons__c = 'Существующий клиент';
                    e2eOpportunity.E2E_Status__c = 'Клиент завершил';
                    e2eFormRuDao.updateOpportunity(e2eOpportunity);
                }

                // Send email notifications
                E2E_RU_Internal_Notifications.transferToService(sfAccount, e2eOpportunityId);

                List<Opportunity> opportunitiesForUpdate = new List<Opportunity>();
                for (Opportunity opportunity : sfAccount.Opportunities) {
                    if (opportunity.Probability > 0 && opportunity.Probability < 100 && opportunity.Id != e2eOpportunityId) {
                        opportunity.StageName = 'Отказ';
                        opportunity.PPR_Lost_Reasons__c = 'Существующий клиент';
                        opportunity.E2E_Status__c = 'Клиент завершил';
                        opportunitiesForUpdate.add(opportunity);
                    }
                }
                e2eFormRuDao.updateOpportunities(opportunitiesForUpdate);
            } else {
                throw new E2EFormRuException('Error: Account with Id ' + sfAccountId + ' does not found');
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E future method transferToService: ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : transferToInbound()
    *  Summary         : convert E2E process to Inbound
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void transferToInbound(E2EFormRuDeduplicationResult deduplicationResult) {
        System.debug('******* DEDUPLICATION PROCESS: execute transferToInbound');

        transferToInbound(deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId
        );

        if (deduplicationResult.innDuplication == true) {
            deduplicationResult.e2eAccount = deduplicationResult.sfAccount;
        }
    }

    @Future
    public static void transferToInbound(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId, Id e2eContactId, Id formDataId) {
        try {
            E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
            Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);

            if (sfAccount != null) {
                if (innDuplication == true) {
                    //update E2E FormData
                    E2EFormData__c formData = new E2EFormData__c(Id = formDataId);
                    formData.E2E_Account_Id__c = sfAccountId;
                    e2eFormRuDao.updateFormData(formData);

                    // update E2E opportunity
                    Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                    e2eOpportunity.AccountId = sfAccountId;
                    e2eOpportunity.StageName = 'Qualified Lead';
                    e2eOpportunity.Business_process__c = GlobalUtils.BusinessProcessType.Standard.name();
                    e2eFormRuDao.updateOpportunity(e2eOpportunity);

                    // update E2E contact
                    Contact e2eContact = new Contact(Id = e2eContactId);
                    e2eContact.AccountId = sfAccountId;
                    e2eFormRuDao.updateContact(e2eContact);

                    // delete E2E Account
                    if (e2eAccountId != sfAccountId) {
                        deleteAccountById(e2eAccountId);
                    }
                } else {
                    // update E2E opportunity
                    Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                    e2eOpportunity.StageName = 'Qualified Lead';
                    e2eOpportunity.Business_process__c = GlobalUtils.BusinessProcessType.Standard.name();
                    e2eFormRuDao.updateOpportunity(e2eOpportunity);
                }

                // Send email notifications
                E2E_RU_Internal_Notifications.transferToInbound(sfAccount, e2eOpportunityId);

            } else {
                throw new E2EFormRuException('Error: Account with Id ' + sfAccountId + ' does not found');
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E future method transferToInbound: ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : transferToKO()
    *  Summary         : convert E2E process to Inbound
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void transferToKO(E2EFormRuDeduplicationResult deduplicationResult) {
        System.debug('******* DEDUPLICATION PROCESS: execute transferToKO');

        transferToKO(deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.sfOpportunity.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId
        );

        if (deduplicationResult.innDuplication == true) {
            deduplicationResult.e2eAccount = deduplicationResult.sfAccount;
        }
    }

    @Future
    public static void transferToKO(Boolean innDuplication, Id sfAccountId, Id sfOpportunityId, Id e2eAccountId, Id e2eOpportunityId, Id e2eContactId, Id formDataId) {
        try {
            E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
            Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);
            Opportunity sfOpportunity = e2eFormRuDao.getOpportunityById(sfOpportunityId);
            Contact e2eContact = e2EFormRuDao.getContactById(e2eContactId);
            Account e2eAccount = e2EFormRuDao.getAccountById(e2eAccountId);
            System.debug('TRANSFER TO KO @FUTURE METHOD: innDuplication = ' + innDuplication);

            if (innDuplication == true) {
                // update  E2E opportunity
                Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                e2eOpportunity.AccountId = sfAccountId;
                e2eOpportunity.StageName = 'Отказ';
                e2eOpportunity.PPR_Lost_Reasons__c = 'Возврат в Воронку';
                e2eOpportunity.E2E_Status__c = 'Клиент завершил';
                e2eFormRuDao.updateOpportunity(e2eOpportunity);

                // update E2E contact
                e2eContact.AccountId = sfAccountId;
                e2eFormRuDao.updateContact(e2eContact);

                //update E2E FormData
                E2EFormData__c formData = new E2EFormData__c(Id = formDataId);
                formData.E2E_Account_Id__c = sfAccountId;
                e2eFormRuDao.updateFormData(formData);

                // delete E2E Account
                if (e2eAccountId != sfAccountId) {
                    deleteAccountById(e2eAccountId);
                }
            } else {
                // update  E2E opportunity
                Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                e2eOpportunity.StageName = 'Отказ';
                e2eOpportunity.OwnerId = sfOpportunity.OwnerId;
                e2eOpportunity.PPR_Lost_Reasons__c = 'Возврат в Воронку';
                e2eOpportunity.E2E_Status__c = 'Клиент завершил';
                e2eFormRuDao.updateOpportunity(e2eOpportunity);

                // update E2E contact
                e2eContact.OwnerId = sfOpportunity.OwnerId;
                e2eFormRuDao.updateContact(e2eContact);

                // update E2E account
                e2eAccount.OwnerId = sfOpportunity.OwnerId;
                e2eFormRuDao.updateAccount(e2eAccount);
            }

            // Send email notifications
            E2E_RU_Internal_Notifications.transferToKO(sfAccount, e2eOpportunityId, innDuplication, e2eContact, e2eAccount);

        } catch (Exception e) {
            String notificationMessage = '<br/>E2E future method transferToKO: ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : transferToE2E()
    *  Summary         : continue E2E process, when account does not have opportunity
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void transferToE2E(E2EFormRuDeduplicationResult deduplicationResult) {
        System.debug('******* DEDUPLICATION PROCESS: execute transferToE2E');

        List<Id> refusingOpportunityIds = new List<Id>();
        prepareTransferToE2E(
                deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId,
                refusingOpportunityIds
        );


        transferToE2E(deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId,
                refusingOpportunityIds
        );

        if (deduplicationResult.innDuplication == true) {
            deduplicationResult.e2eAccount = deduplicationResult.sfAccount;
        }
    }

    /*******************************************************************************
    *  Name            : prepareTransferToE2E(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
                       : Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds)
    *  Summary         : prepare transfer to e2e process
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : 05/03/2019
    *  Parameters      : Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
                       : Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds
    *  Returns         : void
    ******************************************************************************/
    public void prepareTransferToE2E(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
            Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds) {
        E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
        Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);
        List<Opportunity> refusingOpportunityList = new List<Opportunity>();

        if (sfAccount != null) {
            if (innDuplication == true) {
                //update E2E FormData
                System.debug('@Future -> transferToE2E -> formDataId ' + formDataId);
                System.debug('@Future -> transferToE2E -> sfAccountId ' + sfAccountId);
                E2EFormData__c formData = new E2EFormData__c(Id = formDataId);
                formData.E2E_Account_Id__c = sfAccountId;
                e2eFormRuDao.updateFormData(formData);

                // update E2E contact
                Contact e2eContact = new Contact(Id = e2eContactId);
                e2eContact.AccountId = sfAccountId;
                e2eFormRuDao.updateContact(e2eContact);

                // update  E2E opportunity
                Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                e2eOpportunity.AccountId = sfAccountId;
                e2eFormRuDao.updateOpportunity(e2eOpportunity);
                // update SF opportunity
                for (Opportunity opportunity : sfAccount.Opportunities) {
                    if (opportunity.StageName != 'Moved to Start' && opportunity.StageName != 'Отказ' && opportunity.Id != e2eOpportunityId) {
                        opportunity.StageName = 'Отказ';
                        opportunity.PPR_Lost_Reasons__c = 'Switched to E2E';
                        refusingOpportunityList.add(opportunity);
                    }
                }
                e2eFormRuDao.updateOpportunities(refusingOpportunityList);

                // delete E2E Account
                if (e2eAccountId != sfAccountId) {
                    deleteAccountById(e2eAccountId);
                }
            } else {
                // update SF opportunity
                for (Opportunity opportunity : sfAccount.Opportunities) {
                    if (opportunity.StageName != 'Moved to Start' && opportunity.StageName != 'Отказ' && opportunity.Id != e2eOpportunityId) {
                        opportunity.StageName = 'Отказ';
                        opportunity.PPR_Lost_Reasons__c = 'Switched to E2E';
                        refusingOpportunityList.add(opportunity);
                    }
                }
                e2eFormRuDao.updateOpportunities(refusingOpportunityList);
            }

            //prepare and return refusingOpportunityIds list as parameter for future method
            System.debug('PREPARE TRANSFER TO E2E METHOD: refusingOpportunityList = ' + refusingOpportunityList);
            for (Opportunity opportunity : refusingOpportunityList) {
                refusingOpportunityIds.add(opportunity.Id);
            }
        } else {
            throw new E2EFormRuException('Error: Account with Id ' + sfAccountId + ' does not found');
        }
    }

    /*******************************************************************************
    *  Name            : transferToE2E(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
                       : Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds)
    *  Summary         : send notifications asynchronously
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : 05/03/2019
    *  Parameters      : Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
                       : Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds
    *  Returns         : void
    ******************************************************************************/
    @Future
    public static void transferToE2E(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
            Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds) {
        try {
            E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
            Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);
            List<Opportunity> refusingOpportunityList = e2eFormRuDao.getOpportunitiesByIds(new Set<Id>(refusingOpportunityIds));

            System.debug('TRANSFER TO E2E @FUTURE METHOD: refusingOpportunityList = ' + refusingOpportunityList);
            if (sfAccount != null) {
                // Send email notifications
                E2E_RU_Internal_Notifications.transferToE2E(refusingOpportunityList);
            } else {
                throw new E2EFormRuException('Error: Account with Id ' + sfAccountId + ' does not found');
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E future method transferToE2E: ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    //TODO: оставить
    private static String getEmailBodyDisqualificationLeadForSalesPushEmail(Lead lead) {
        String body = 'Уважаемый менеджер. <br/><br/>' +
                'Интерес <a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + lead.Id + '" target="_blank">' + lead.Name + '</a> ' +
                'дисквалифицирован, клиент передан в E2E. <br/>' +
                'ИНН: ' + (lead.INN__c == null ? 'none' : lead.INN__c) + '; <br/>' +
                'Телефон: ' + (lead.Phone == null ? 'none' : lead.Phone) + '; <br/>';

        return body;
    }

    //******* Notification Part *******//

    public void updateEncodedUrl(Id opportunityId, Id formDataId, E2EFormParams formParams) {
        Opportunity opportunity = new Opportunity(Id = opportunityId);
        opportunity.E2E_Encoded_URL__c = formParams.encodedURL;
        system.enqueueJob(new E2EFormRuServiceImpl.updateOpportunityQueueable(opportunity, 'firstFormUrl'));

        E2EFormData__c formDataRecord = new E2EFormData__c(Id = formDataId);
        formDataRecord.E2E_Form_URL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/e2eFormRu?country=Russia&link=' + formParams.encodedURL;
        system.enqueueJob(new E2EFormRuServiceImpl.updateFormDataQueueable(formDataRecord, 'firstFormUrl'));
    }

    //***** Remote Action *****//

    public void updateSoleProprietorInfoFromSpark(E2EFormParams formParams, String formDataId) {
        // update FormData
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        formDataRecord.E2E_Account_Short_Name__c = formParams.mainCompanyFullNameSpark.removeStart('ИП ');
        formDataRecord.E2E_Executive_Person__c = GlobalUtils.blankStringIfNull(formParams.soleProprietorFio) + ', ' + 'Индивидуальный предприниматель';
        formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(formParams.ogrnipSpark);
        formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
        formDataRecord.E2E_Empty_SPARK_OKPO__c = formParams.emptySparkOkpo;
        formDataRecord.E2E_Spark_Id__c = String.valueOf(formParams.sparkID);
        formDataRecord.E2E_Main_Company_Full_Name__c = GlobalUtils.blankStringIfNull(formParams.mainCompanyFullNameSpark);
        formDataRecord.E2E_Reg_Date__c = GlobalUtils.blankStringIfNull(formParams.registrationDateSpark);
        this.e2eFormRuDao.updateFormData(formDataRecord);

        // update Account
        Account account = new Account(Id = formDataRecord.E2E_Account_Id__c);
        account.OGRN_ppr__c = GlobalUtils.blankStringIfNull(formParams.ogrnipSpark);
        account.Organization_Type__c = 'ИП';
        account.OKPO_ppr__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
        // In E2E Business process set special marker SF-864
        if (GlobalUtils.BusinessProcessType.E2EBusiness.name().equals(formParams.businessProcess)) account.Modified_in_E2E_Business__c = true;
        this.e2eFormRuDao.updateAccount(account);
    }

    public void updateCompanyInformationFromSpark(E2EFormParams formParams, String formDataId, String opportunityId) {
        // init address
        String street = formParams.streetSpark == null ? '' : GlobalUtils.blankStringIfNull(formParams.streetSpark);
        String building = formParams.buildingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.buildingSpark);
        String housing = formParams.housingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.housingSpark);
        String block = formParams.blockSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.blockSpark);
        String room = formParams.roomSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.roomSpark);

        // update FormData
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        System.debug('*** updateCompanyInformationFromSpark -> currentAccount ' + formDataRecord.E2E_Account_Id__c);
        formDataRecord.E2E_Account_Short_Name__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(0);
        String executiveFio = GlobalUtils.blankStringIfNull(formParams.executiveFio);
        String executivePosition = formParams.executivePosition == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.executivePosition);
        formDataRecord.E2E_Executive_Person__c = executiveFio + executivePosition;
        formDataRecord.E2E_Reg_Date__c = GlobalUtils.blankStringIfNull(formParams.registrationDateSpark);
        formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(formParams.ogrnSpark);
        formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
        formDataRecord.E2E_Empty_SPARK_OKPO__c = formParams.emptySparkOkpo;
        formDataRecord.E2E_KPP__c = GlobalUtils.blankStringIfNull(formParams.kppSpark);
        formDataRecord.E2E_Spark_Id__c = GlobalUtils.blankStringIfNull(String.valueOf(formParams.sparkId));
        formDataRecord.E2E_Main_Company_Full_Name__c = GlobalUtils.blankStringIfNull(formParams.mainCompanyFullNameSpark);
        formDataRecord.E2E_INN__c = GlobalUtils.blankStringIfNull(formParams.companyInn);
        formDataRecord.E2E_Billing_Code__c = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
        formDataRecord.E2E_Billing_State__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);
        formDataRecord.E2E_Billing_City__c = GlobalUtils.blankStringIfNull(formParams.citySpark);
        formDataRecord.E2E_Billing_Str__c = street + building;
        formDataRecord.E2E_Billing_Apartment__c = housing + block + room;
        formDataRecord.E2E_Legal_Address__c = GlobalUtils.blankStringIfNull(formParams.legalAddressSpark);
        this.e2eFormRuDao.updateFormData(formDataRecord);

        // update Account
        Account account = new Account(Id = formDataRecord.E2E_Account_Id__c);
        account.BillingPostalCode = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
        account.BillingCity = GlobalUtils.blankStringIfNull(formParams.citySpark);
        account.BillingStreet = street + building + housing + block + room;
        account.Region__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);
        account.OKPO_ppr__c = formParams.okpoSpark;
        account.OGRN_ppr__c = formParams.ogrnSpark;
        String KPP = formParams.kppSpark;
        account.KPP__c = (KPP == '' || KPP == null) ? 0 : Decimal.valueOf(KPP);
        account.Organization_Type__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(1);
        // In E2E Business process set special marker SF-864
        if (GlobalUtils.BusinessProcessType.E2EBusiness.name().equals(formParams.businessProcess)) account.Modified_in_E2E_Business__c = true;
        this.e2eFormRuDao.updateAccount(account);
    }

    public void updateVerifiedDecision(E2EFormParams formParams, String formDataId, String opportunityId) {

        // update FormData
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        formDataRecord.E2E_Black_List_Code__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecisionCode);
        formDataRecord.E2E_Black_List__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecision);
        formDataRecord.E2E_Black_List_Limitations__c = GlobalUtils.blankStringIfNull(formParams.verifiedLimitation);
        this.e2eFormRuDao.updateFormData(formDataRecord);

        if (String.isNotEmpty(formParams.verifiedDecisionCode)) {
            if (formParams.verifiedDecisionCode.equals('3') || formParams.scoringDecisionCode.equals('2')) {
                // update Opportunity
                Opportunity opportunity = new Opportunity(Id = opportunityId);
                opportunity.E2E_Sub_Status__c = 'Чёрный список';
                opportunity.E2E_Sales_Type__c = 'Отклонен';
                opportunity.StageName = 'Отказ';
                opportunity.PPR_Lost_Reasons__c = formParams.opportunityLostReason;
                opportunity.E2E_Status__c = 'Клиент завершил';
                this.e2eFormRuDao.updateOpportunity(opportunity);
            }
        }
    }

    public void updateScoringDecision(E2EFormParams formParams, String formDataId, String opportunityId) {
        // update FormData
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        formDataRecord.E2E_Scoring_Decision_Code__c = GlobalUtils.blankStringIfNull(formParams.scoringDecisionCode);
        formDataRecord.E2E_Scoring_Decision__c = GlobalUtils.blankStringIfNull(formParams.scoringDecision);
        formDataRecord.E2E_Scoring_Date__c = formParams.scoringDate;
        formDataRecord.E2E_Scoring_Expiration_Date__c = formParams.scoringDate == null ? null : formParams.scoringDate.addMonths(3);
        this.e2eFormRuDao.updateFormData(formDataRecord);
    }

    public Boolean isRoleInbound(Id id) {
        System.debug('*** isRoleInbound' + id);
        if (id == null) {
            return false;
        }
        User user = this.e2eFormRuDao.isRoleAnInbound(id);
        return GlobalUtils.getInboundRoles(user.UserRole.Name);
    }

    public String getCurrentStep(Id id) {
        System.debug('*** getCurrentStep' + id);
        Opportunity opp = this.e2eFormRuDao.getOpportunityStep(id);
        return opp.E2E_Active_Substep__c;
    }
}
