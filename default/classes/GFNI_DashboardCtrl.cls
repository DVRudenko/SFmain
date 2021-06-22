public with sharing class GFNI_DashboardCtrl {

    private static final String GFN_CUSTOM_SETTINGS_SME = 'GFN Integration Settings';
    private static final String GFN_CUSTOM_SETTINGS_CCS = 'GFN Integration Settings CCS';
    private static final String DEFAULT_LINE_OF_BUSINESS = 'SME';

    public static GFNI_DashboardService gfnDashboardService = new GFNI_DashboardServiceImpl();
    public static GFNI_DashboardDao gfnDashboardDao = new GFNI_DashboardDaoImpl();
    public static GFNI_DashboardHandler gfnDashboardHandler = new GFNI_DashboardHandler();

    public class Params {
        @AuraEnabled public String colCoId { get; set; }
        @AuraEnabled public String customerGfnNumber { get; set; }
        @AuraEnabled public String objId { get; set; }
        @AuraEnabled public String objType { get; set; }
        @AuraEnabled public String recordType { get; set; }
        @AuraEnabled public List<GFN_Dashboard_UI_settings__mdt> uiSettings { get; set; }
    }

    @AuraEnabled(Cacheable=true)
    public static Params init(Id currentObjectId, String objectType) {
        Params paramValues = new Params();
        paramValues.objId = currentObjectId;
        paramValues.objType = objectType;
        paramValues.recordType = DEFAULT_LINE_OF_BUSINESS; //sets line of business as SME if Dashboard is opened from Account

        // Dashboard can be called from Account object page or from Case object page or from Task or ERP object page. We need to get account colCoID and GFN number.
        getGFNParams(paramValues);


        //get Dashboard UI settings
        paramValues.uiSettings = gfnDashboardDao.getDashboardUISettings(paramValues.recordType);

        System.debug('Object type = ' + objectType + ', ColcoID = ' + paramValues.colCoId + ', GFN Number = ' + paramValues.customerGfnNumber + ' ' + paramValues.uiSettings);
        return paramValues;
    }


    @AuraEnabled(Cacheable=true)
    public static Params getUISettings(String lineOfBusiness) {
        Params paramValues = new Params();
        paramValues.recordType = lineOfBusiness;
        paramValues.uiSettings = gfnDashboardDao.getDashboardUISettings(lineOfBusiness);
        System.debug('===' + paramValues);
        return paramValues;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountDetailsGfn(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn customerInformation = new AccountDetailsGfn();
        AccountDetailsGfn relatedCustomers = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);
        try {
            customerInformation = gfnDashboardService.getCustomerInformation(colCoID, integrationSettings, customerNumber);
            relatedCustomers = gfnDashboardService.getRelatedCustomers(colCoID, integrationSettings, customerNumber, null);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountDetailsMap = gfnDashboardHandler.getGfnAccountDetails(customerInformation, relatedCustomers, colCoID, customerNumber, integrationSettings);
        return accountDetailsMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountContactsGfn(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn customerContacts = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);
        try {
            customerContacts = gfnDashboardService.getCustomerContacts(colCoID,integrationSettings, customerNumber, null);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountContactsMap = gfnDashboardHandler.getGfnAccountContacts(customerContacts, colCoID, customerNumber, integrationSettings);
        return accountContactsMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountAddressesGfn(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn customerAddresses = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            customerAddresses = gfnDashboardService.getCustomerAddresses(colCoID, integrationSettings, customerNumber, null);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountAddressesMap = gfnDashboardHandler.getGfnAccountAddresses(customerAddresses, colCoID, customerNumber, integrationSettings);
        return accountAddressesMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountServicesGfn(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn customerServices = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            customerServices = gfnDashboardService.getCustomerServices(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountServicesMap = gfnDashboardHandler.getGfnAccountServices(customerServices, colCoID, customerNumber, integrationSettings);
        return accountServicesMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountSelfServeUsersGfn(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn customerSelfServeUsers = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            customerSelfServeUsers = gfnDashboardService.getSelfServeUsers(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountSelfServeUsersMap = gfnDashboardHandler.getGfnAccountSelfServeUsers(customerSelfServeUsers, colCoID, customerNumber, integrationSettings);
        return accountSelfServeUsersMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountCardsInfoGfn(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn customerCardsInfo = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            customerCardsInfo = gfnDashboardService.getCustomerCardsInfo(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountCardsInfoMap = gfnDashboardHandler.getGfnAccountCardsInfo(customerCardsInfo, colCoID, customerNumber, integrationSettings);
        return accountCardsInfoMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountUnbilledProductsGfn(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn customerUnbilledTransactionProducts = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            customerUnbilledTransactionProducts = gfnDashboardService.getUnbilledTransactionProducts(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountUnbilledTransactionProductsMap = gfnDashboardHandler.getGfnAccountUnbilledProducts(customerUnbilledTransactionProducts, integrationSettings);
        return accountUnbilledTransactionProductsMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountUnbilledTransactionsGfn(String colCoID, String customerNumber,
            String dateFrom, String dateTo, String cardNumber, String product, String lineOfBusiness) {
        AccountDetailsGfn customerUnbilledTransactions = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            customerUnbilledTransactions = gfnDashboardService.getUnbilledTransactions(colCoID, integrationSettings, customerNumber, dateFrom, dateTo, cardNumber, product);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountUnbilledTransactionsMap = gfnDashboardHandler.getGfnAccountUnbilledTransactions(customerUnbilledTransactions, colCoID, customerNumber, integrationSettings);
        return accountUnbilledTransactionsMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountPaymentDetailsGfn(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn customerPaymentDetails = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            customerPaymentDetails = gfnDashboardService.getCustomerPaymentDetails(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountPaymentDetailsMap = gfnDashboardHandler.getGfnAccountPaymentDetails(customerPaymentDetails, colCoID, customerNumber, integrationSettings);
        return accountPaymentDetailsMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getAccountInformationSubscriptionsGfn(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn customerInformationSubscriptions = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            customerInformationSubscriptions = gfnDashboardService.getInformationSubscriptions(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountInformationSubscriptionsMap = gfnDashboardHandler.getGfnAccountInformationSubscriptions(customerInformationSubscriptions, colCoID, customerNumber, integrationSettings);
        return accountInformationSubscriptionsMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> blockAccountCardsGfn(String colCoID, String customerNumber, String cardIdsList, String lineOfBusiness){
        String cardsListJson = gfnDashboardHandler.prepareCardsListJson(cardIdsList);
        BlockCardResponseGfn blockCustomerCardResponseGfn = new BlockCardResponseGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            blockCustomerCardResponseGfn = gfnDashboardService.blockCards(cardsListJson, colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> blockedCustomerCardsMap = gfnDashboardHandler.getGfnAccountBlockedCardsRequests(blockCustomerCardResponseGfn, integrationSettings);
        return blockedCustomerCardsMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getHomeSitesGFN(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn homeSites = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
             homeSites = gfnDashboardService.getHomeSites(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountHomeSitesMap = gfnDashboardHandler.getGfnAccountHomeSites(homeSites, colCoID, customerNumber, integrationSettings);
        return accountHomeSitesMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getPriceRules(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn priceRules = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            priceRules = gfnDashboardService.getPriceRules(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountPriceRules = gfnDashboardHandler.getGfnAccountPriceRules(priceRules, colCoID, customerNumber, integrationSettings);
        return accountPriceRules;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getFeeRules(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn feeRules = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            feeRules = gfnDashboardService.getFeeRules(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountFeeRules = gfnDashboardHandler.getGfnAccountFeeRules(feeRules, colCoID, customerNumber, integrationSettings);
        return accountFeeRules;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getCreditData(String colCoID, String customerNumber, String lineOfBusiness){
        CreditDataGfn creditData = new CreditDataGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            creditData = gfnDashboardService.getCreditData(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            // throw new AuraHandledException(exceptionMessage);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        Map<String, String> accountCreditData = gfnDashboardHandler.getGfnCreditData(creditData, colCoID, customerNumber, integrationSettings);
        return accountCreditData;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getBillingDocuments(String colCoID, String customerNumber, String lineOfBusiness){
        AccountDetailsGfn billingDocuments = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        try {
            billingDocuments = gfnDashboardService.getBillingDocuments(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        Map<String, String> accountBillingDocuments = gfnDashboardHandler.getGFNAccountBillingDocuments(billingDocuments, colCoID, customerNumber, integrationSettings);
        return accountBillingDocuments;
    }

    @AuraEnabled(Cacheable=true)
    public static String resetPassword(String colCoID, String customerNumber, String userName, String lineOfBusiness){
        String resetPasswordResponse = '';
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);
        
        try {
            resetPasswordResponse = gfnDashboardService.resetPassword(colCoID, integrationSettings, customerNumber, userName);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        return resetPasswordResponse;
    }

    @AuraEnabled(Cacheable=true)
    public static Integer getCurrentUserOffset(){
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        return offset;
    }

    @AuraEnabled
    public static String getDocumentLink(String colCoId, String customerNumber, String docNumber, String lineOfBusiness){
        List<ContentVersion> version = gfnDashboardDao.getVersionByDocName(docNumber);
        ContentDistribution distribution = new ContentDistribution();
        GFNI_Settings__c integrationSettings = getCustomSetting(lineOfBusiness);

        if(!version.isEmpty()){
            List<ContentDistribution> existingDestributions = gfnDashboardDao.getDistributionByVersionId(version[0].Id);
            distribution = existingDestributions.isEmpty() ? gfnDashboardDao.createDistributionForVersion(version[0]) : existingDestributions[0];
        } else {
            AccountDetailsGfn document = gfnDashboardService.getDocumentFromGFN(colCoID, integrationSettings, customerNumber, EncodingUtil.urlEncode(docNumber, 'UTF-8'));
            if(document.Data != null){
                ContentVersion newVersion = gfnDashboardDao.createContentVersionPDF(document.Data.PdfData, docNumber);
                distribution = gfnDashboardDao.createDistributionForVersion(newVersion);
            }
        }

        return distribution.DistributionPublicUrl;
    }

    @AuraEnabled
    public static Id getRelatedAccountId(String customerNumber) {
        List<Account> accountList = [
            SELECT  Id
            FROM    Account
            WHERE   GFN_Nr__c =: customerNumber
            LIMIT   1
        ];
        if(accountList.size() > 0) {
            return accountList[0].Id;
        }
        return null;
    }

    @AuraEnabled
    public static Id getRelatedERPId(String customerNumber) {
        List<ERP__c> erpList = [
            SELECT  Id
            FROM    ERP__c
            WHERE   GFN_Nr__c =: customerNumber
            OR     GFN_Number__c =: customerNumber
            LIMIT   1
        ];
        if(erpList.size() > 0) {
            return erpList[0].Id;
        }
        return null;
    }

    @AuraEnabled
    public static String getResetPasswordHistory(String customerNumber) {
        ERP__c erp = [
            SELECT  Reset_Password_History__c
            FROM    ERP__c
            WHERE   GFN_Nr__c =: customerNumber
            OR      GFN_Number__c =: customerNumber
            LIMIT   1
        ];
        if(erp.Reset_Password_History__c != null) {
            List<String> resetHistoryList = erp.Reset_Password_History__c.split('\n');
            List<String> userIdList = new List<String>();
            for(String historyItem : resetHistoryList) {
                userIdList.add(historyItem.split(',')[1]);
            }
            List<User> userList = [
                SELECT  FirstName,
                        LastName
                From    User
                WHERE   Id IN: userIdList
            ];
            
            for(User user : userList) {
                erp.Reset_Password_History__c = erp.Reset_Password_History__c.replace(user.Id, user.FirstName + ' ' + user.LastName);
            }
        }
        return erp.Reset_Password_History__c;

    }


    @AuraEnabled
    public static void saveResetPasswortLog(String customerNumber, String status, String userName) {
        List<ERP__c> erpList = [
            SELECT  Reset_Password_History__c
            FROM    ERP__c
            WHERE   GFN_Nr__c =: customerNumber
            OR      GFN_Number__c =: customerNumber
        ];
        if(erpList.size() == 1) {
            ERP__c erp = erpList[0];
                    //replace last item if number of history items = 10
            if(erp.Reset_Password_History__c != null && erp.Reset_Password_History__c.split('\n').size() == 10) {
                erp.Reset_Password_History__c = erp.Reset_Password_History__c.replace(erp.Reset_Password_History__c.substringAfterLast('\n'), '');
            }
            String newHistoryItem = String.valueOf(DateTime.now().getTime()) + ',' + UserInfo.getuserid() + ',' + status + ',' + userName + '\n';
            if(erp.Reset_Password_History__c != null) {
                erp.Reset_Password_History__c = newHistoryItem  + erp.Reset_Password_History__c;
            }
            else {
                erp.Reset_Password_History__c = newHistoryItem;
            }
            update erp;
        }
    }

    
    private static void getParamsByERPData(ERP__c currentERP, Params paramValues) {
        if (currentERP != null) {
            paramValues.recordType = Schema.SObjectType.ERP__c.getRecordTypeInfosById().get(currentERP.RecordTypeId).getName();
            if (currentERP.GFN_Number__c != null) {
                paramValues.customerGfnNumber = currentERP.GFN_Number__c;
            } else if(currentERP.GFN_Nr__c != null) {
                paramValues.customerGfnNumber = currentERP.GFN_Nr__c;
            }
            if (currentERP.ColCoID__c != null) {
                paramValues.colCoId = getColCoId(paramValues.recordType, currentERP.ColCoID__c);
            } else if(currentERP.ColCo__c != null) {
                paramValues.colCoId = getColCoId(paramValues.recordType, currentERP.ColCo__c);
            }
        }
    }
    
    public static GFNI_Settings__c getCustomSetting(String recordType) {
        if(recordType == 'CCS') {
             return GFNI_Utils.getGfnCustomSettings(GFN_CUSTOM_SETTINGS_CCS);
        } else {
            return GFNI_Utils.getGfnCustomSettings(GFN_CUSTOM_SETTINGS_SME);
        }
    }

    private static void getGFNParams(Params paramValues) {
        ERP__c currentERP;
        
        if (paramValues.objType == 'Account') {
            Account currentAccount = gfnDashboardDao.getAccountById(paramValues.objId);
            paramValues.colCoId = getColCoId(paramValues.recordType, currentAccount.ColCo__c);
            paramValues.customerGfnNumber = currentAccount.GFN_Nr__c;
        } else if (paramValues.objType == 'Case') {
            Case currentCase = gfnDashboardDao.getCaseAccountById(paramValues.objId);
            String supportCCSRecordTypeId = GlobalUtils.getRecordTypeId(Case.class.getName(), GlobalUtils.CaseRecordTypes.Support_CCS.name());
            if(currentCase.ERP__r != null && (currentCase.ERP__r.ColCo__c != null || currentCase.ERP__r.ColCoID__c != null) &&
                (currentCase.RecordTypeId == supportCCSRecordTypeId) && (currentCase.ERP__r.GFN_Nr__c != null || currentCase.ERP__r.GFN_Number__c != null)) {
                currentERP = currentCase.ERP__r;
            } else if(currentCase.Account != null && currentCase.Account.ColCo__c != null && currentCase.Account.GFN_Nr__c != null) {
                paramValues.colCoId = getColCoId(paramValues.recordType, currentCase.Account.ColCo__c);
                paramValues.customerGfnNumber = currentCase.Account.GFN_Nr__c;
            }
        } else if (paramValues.objType == 'Task'){
            Task currentTask = gfnDashboardDao.getTaskById(paramValues.objId);
            if(String.isNotEmpty(currentTask.Account__c)) {
                paramValues.colCoId = getColCoId(paramValues.recordType, currentTask.Account__r.ColCo__c);
                paramValues.customerGfnNumber = currentTask.Account__r.GFN_Nr__c;
            } 
            else if (String.isNotEmpty(currentTask.WhatId) && String.valueOf(currentTask.WhatId).startsWith('001')) {
                Account relatedAccount = gfnDashboardDao.getAccountById(currentTask.WhatId);
                paramValues.colCoId = getColCoId(paramValues.recordType, relatedAccount.ColCo__c);
                paramValues.customerGfnNumber = relatedAccount.GFN_Nr__c;                
            }
        } else if (paramValues.objType == 'LiveChatTranscript') {
            currentERP = gfnDashboardDao.getErpByLiveChatTranscript(paramValues.objId);
        } else if (paramValues.objType == 'ERP__c') {
            currentERP = gfnDashboardDao.getERPById(paramValues.objId);
        }

        //set colco and gfn number from ERP(GFN) object if it is not equal null
        getParamsByERPData(currentERP, paramValues);
    }

    public static String getColCoId(String lineOfBusiness, String colCo) {
        List<Col_Co_Mapping__mdt> colCoItem = [
            SELECT  ColCoId__c 
            FROM    Col_Co_Mapping__mdt
            WHERE   Line_Of_Business__c =: lineOfBusiness
            AND     Label =: colCo
        ];
        System.debug('===' + colCoItem+'*===* ' + lineOfBusiness + '*===* ' + colCo);
        if(colCoItem.size() > 0){
            return String.valueOf(colCoItem[0].ColCoId__c).substringBefore('.');
        }
        return null;
    }
}