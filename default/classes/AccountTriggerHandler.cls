public class AccountTriggerHandler {
    public static Boolean isE2EForm = false;
    public static Boolean enablesTrigger = true;
    public static Boolean enablesBeforeUpdateTrigger = true;
    public static Boolean enablesBeforeInsertTrigger = true;
    public static Boolean enablesAfterUpdateTrigger = true;
    public static Boolean isParent = true;
    public static Boolean isChild;
    public static Map<Id, Opportunity> oldOpportunityMap;

    private static Map<String, RecordTypeInfo> accountRecordTypes{
        get{
            if(accountRecordTypes == null){
                accountRecordTypes = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return accountRecordTypes;
        }
        private set;
    }

    public static void setRecordType(List<Account> newList) {
        for (Account acc : newList) {
            if (acc.Lead_Record_Type__c == 'AllStar'){
                acc.RecordTypeId = accountRecordTypes.get('AllStar').getRecordTypeId();
            } else if (acc.Lead_Record_Type__c == 'Russian Sales') {
                acc.RecordTypeId = accountRecordTypes.get('Russian').getRecordTypeId();
            } else if (acc.Lead_Record_Type__c == 'Lotos') {
                acc.RecordTypeId = accountRecordTypes.get('Endkunde').getRecordTypeId();
            } else if (acc.CCS_Account_Record_Type__c != null && acc.CCS_Account_Record_Type__c != ''){
                if(acc.CCS_Account_Record_Type__c.contains('CCS')){
                    acc.RecordTypeId = accountRecordTypes.get('CCS').getRecordTypeId();
                }
            }
        }
    }

    public static void maketouppercase(List<Account> newList) {
        for (Account a : newList) {
            if (a.Name != null) {
                a.Name = a.Name.touppercase();
            }

            if (a.Firmenname2_Zusatz__c != null) {
                a.Firmenname2_Zusatz__c = a.Firmenname2_Zusatz__c.touppercase();
            }

            if (a.BillingStreet != null) {
                a.BillingStreet = a.BillingStreet.touppercase();
            }

            if (a.ShippingStreet != null) {
                a.ShippingStreet = a.ShippingStreet.touppercase();
            }

            if (a.BillingCity != null) {
                a.BillingCity = a.BillingCity.touppercase();
            }

            if (a.ShippingCity != null) {
                a.ShippingCity = a.ShippingCity.touppercase();
            }
        }
    }

    public static void parentChildDefinition(List<Account> accountsList) {
        for (Account account : accountsList) {
            if (account.ParentId == null) {
                isChild = true;
                isParent = false;
            } else {
                isChild = false;
            }
        }
    }

    public static void updateChild(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> recordTypeEuroshellSet = new Set<Id>();
        if (GlobalUtils.returnRecordTypeId('Account', 'AllStar') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'AllStar'));
        if (GlobalUtils.returnRecordTypeId('Account', 'CCS') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'CCS'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Endkunde') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Endkunde'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Endkunde PL and HU') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Endkunde PL and HU'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Flexcard') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Flexcard'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Retailer') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Retailer'));
        if (GlobalUtils.returnRecordTypeId('Account', 'WinBack') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'WinBack'));
        Set<Id> parentAccountsId = new Set<Id>();
        for (Account parentAccount : newMap.values()) {
            if (parentAccount.Last_contact_date__c != oldMap.get(parentAccount.Id).Last_contact_date__c &&
                    recordTypeEuroshellSet.contains(parentAccount.RecordTypeId)) {
                parentAccountsId.add(parentAccount.Id);
            }
        }
        if (!parentAccountsId.isEmpty()) {
            List<Account> childAccountsList = [
                    SELECT ParentId
                    FROM Account
                    WHERE ParentId IN :parentAccountsId
            ];
            List<Account> childAccountsToUpdateList = new List<Account>();
            for (Account childAccount : childAccountsList) {
                childAccount.Last_contact_date__c = newMap.get(childAccount.ParentId).Last_contact_date__c;
                childAccountsToUpdateList.add(childAccount);
            }
            update childAccountsToUpdateList;
        }
    }


    public static void updateParent(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> recordTypeEuroshellSet = new Set<Id>();
        if (GlobalUtils.returnRecordTypeId('Account', 'AllStar') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'AllStar'));
        if (GlobalUtils.returnRecordTypeId('Account', 'CCS') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'CCS'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Endkunde') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Endkunde'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Endkunde PL and HU') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Endkunde PL and HU'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Flexcard') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Flexcard'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Retailer') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Retailer'));
        if (GlobalUtils.returnRecordTypeId('Account', 'WinBack') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'WinBack'));
        Map<Id, Id> childToParentMap = new Map<Id, Id>();
        for (Account childAccount : newMap.values()) {
            if (childAccount.Last_contact_date__c != oldMap.get(childAccount.Id).Last_contact_date__c &&
                    recordTypeEuroshellSet.contains(childAccount.RecordTypeId)) {
                childToParentMap.put(childAccount.Id, childAccount.ParentId);
            }
        }

        if (!childToParentMap.isEmpty()) {
            List<Account> parentAccountsToUpdate = new List<Account>();
            for (Id childAccountId : childToParentMap.keySet()) {
                Account parentAccount = new Account(
                        Id = childToParentMap.get(childAccountId),
                        Last_contact_date__c = newMap.get(childAccountId).Last_contact_date__c);
                parentAccountsToUpdate.add(parentAccount);
            }
            update parentAccountsToUpdate;
        }
    }


    /*******************************************************************************
    *  Name            : updateBeforeLastOwnerChangeDateRUS()
    *  Summary         : update account, set Last_Date_Change_Owner_RUS__c to Opportunity
    *  CreatedDate     : 20.11.2017
    *  Parameters      : Map<Id, Account> oldMap, Map<Id, Account> newMap
    *  Returns         : -
    ******************************************************************************/
    public static void updateBeforeLastOwnerChangeDateRUS(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> accSetB = new Set<Id>();
        for (Account acc : newMap.values()) {
            if (accountRecordTypes.get('Russian').getRecordTypeId() == acc.RecordTypeId && acc.OwnerId != oldMap.get(acc.Id).OwnerId) {
                accSetB.add(acc.Id);
            }
        }

        if (!accSetB.isEmpty()) {
            oldOpportunityMap = new Map<Id, Opportunity>();
            for (Opportunity o : [
                    SELECT Id, OwnerId, Last_Owner_Change_Date_RUS__c
                    FROM Opportunity
                    WHERE AccountId IN :oldMap.keySet()
            ]) {
                oldOpportunityMap.put(o.Id, o);
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateLastDateChangeOwnerRUSOpportunityAndOpenTaskCheckBox()
    *  Summary         : update account, set Last_Date_Change_Owner_RUS__c to Opportunity
    *  CreatedDate     : 20.11.2017
    *  UpdateDate      : 11.05.2018
    *  UpdateBy        : Nikita Mikhailov
    *  Parameters      : Map<Id, Account> oldMap, Map<Id, Account> newMap
    *  Returns         : -
    ******************************************************************************/
    public static void updateLastDateChangeOwnerRUSOpportunityAndOpenTaskCheckBox(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> accSet = new Set<Id>();
        for (Account acc : newMap.values()) {
            if (accountRecordTypes.get('Russian').getRecordTypeId() == acc.RecordTypeId && acc.OwnerId != oldMap.get(acc.Id).OwnerId) {
                accSet.add(acc.Id);
            }
        }

        System.debug(accSet);

        if (!accSet.isEmpty()) {
            List<Opportunity> oppUpdateList = new List<Opportunity>();
            List<Opportunity> oppList = [
                    SELECT Id,
                            Last_Owner_Change_Date_RUS__c,
                            AccountId,
                            OwnerId,
                            isClosed,
                            Open_Task__c, (SELECT Id, OwnerId FROM Tasks WHERE IsClosed = false)
                    FROM Opportunity
                    WHERE AccountId IN :accSet
            ];

            System.debug(oppList);

            for (Opportunity opp : oppList) {

                if (oldOpportunityMap.get(opp.Id).OwnerId != opp.OwnerId) {

                    if (opp.Tasks.size() > 0) {
                        opp.Open_Task__c = false;
                        for (Task task : opp.Tasks) {
                            If (task.OwnerId.equals(opp.OwnerId)) {
                                opp.Open_Task__c = true;
                                break;
                            }
                        }
                    }


                    opp.Last_Owner_Change_Date_RUS__c = Datetime.now();
                    oppUpdateList.add(opp);
                }
            }
            System.debug(oppUpdateList);
            update oppUpdateList;
        }
    }

    /*******************************************************************************
    *  Name            : updateCurrencyIsoCode()
    *  Summary         : Update the CurrencyIsoCode in Opportunity
    *  CreatedDate     : 02-03-2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Account> oldMap, Map<Account> newList
    *  Returns         : void
    ******************************************************************************/
    public static void updateCurrencyIsoCode(Map<Id, Account> oldMap, List<Account> newList) {
        // after update
        Set<String> accountIdsSet = new Set<String>();
        for (Account acc : newList) {
            if (acc.BillingCountry != null && CountryToCurrencyIsoCodeMap.containsKey(acc.BillingCountry) && acc.RecordTypeId != accountRecordTypes.get('CCS').getRecordTypeId()) {
                accountIdsSet.add(acc.Id);
            }
        }
        if (!accountIdsSet.isEmpty()) {
            List<Opportunity> opportunitiesList = [
                    SELECT CurrencyIsoCode, Account.BillingCountry, Account.Id
                    FROM Opportunity
                    WHERE AccountId IN :accountIdsSet
                    LIMIT 50000
            ];

            List<Opportunity> opportunityToUpdateList = new List<Opportunity>();
            for (Opportunity opp : opportunitiesList) {
                if (opp.Account.BillingCountry != oldMap.get(opp.Account.Id).BillingCountry) {
                    opp.CurrencyIsoCode = CountryToCurrencyIsoCodeMap.get(opp.Account.BillingCountry);
                    opportunityToUpdateList.add(opp);
                }
            }

            if (!opportunityToUpdateList.isEmpty()) {
                update opportunityToUpdateList;
            }
        }
    }

    /*******************************************************************************
    *  Name            : setFields(Map<Id, Account> oldMap, List<Account> newList)
    *  Summary         : process fields on new records
    *  CreatedDate     : 30/10/2019
   *  Parameters      : oldMap, newMap – maps from the trigger
   *  Returns         : void
   ******************************************************************************/
    public static void setFields(Map<Id, Account> oldMap, List<Account> newList) {
        /* don't use phone field on ru accounts
        PhoneNumbersHandler.sObjWrapperList recordsToProcessRU = new PhoneNumbersHandler.sObjWrapperList ();
        */
        for (Account account : newList) {
            Account oldAccount = oldMap == null ? null : oldMap.get(account.Id);
            if (account.RecordtypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()) {
                // ---- for Russia ----
                // process phones
                /* don't use phone field on ru accounts
                recordsToProcessRU.addSObj(Schema.Account.sObjectType, account, oldAccount);
                */
            } else {
                // ---- for EU ------
                // process phones
                ClickToCallHandler.checkPhonesOnRecordAndProcess (Schema.Account.sObjectType, account.BillingCountryCode, account.BillingCountry, account, oldAccount);
            }
        }
        /* don't use phone field on ru account
        //process RU records
        recordsToProcessRU.processSObjects();
        */
    }


    /*******************************************************************************
    *  Name            : findDuplicateTaxId(Map<Id, Account> oldMap, List<Account> newList)
    *  Summary         : Find duplicate Tax ID and add error message if it's true
    *  CreatedDate     : 18/05/2018
    *  ModifiedDate    : -
    *  Parameters      : oldMap and newList from trigger
    *  Returns         : void
    ******************************************************************************/
    public static void findDuplicateTaxId(Map<Id, Account> oldMap, List<Account> newList) {
        Set<String> taxIdSet = new Set<String>();
        // before insert
        if (oldMap == null) {
            for (Account acc : newList) {
                if (acc.Steuernummer__c != null && acc.BillingCountryCode != null && acc.RecordTypeId != accountRecordTypes.get('Russian').getRecordTypeId() && ! acc.E2E__c) {
                    if (taxIdSet.contains(acc.Steuernummer__c)) {
                        acc.addError('You try to insert accounts with duplicates TAX ID.', false);
                        return;
                    } else {
                        taxIdSet.add(acc.Steuernummer__c);
                    }
                }
            }
        }
        // before update
        if (oldMap != null) {
            for (Account acc : newList) {
                if (acc.Steuernummer__c != null && acc.BillingCountryCode != null && acc.RecordTypeId != accountRecordTypes.get('Russian').getRecordTypeId() && ! acc.E2E__c &&
                        ((oldMap.get(acc.Id).Steuernummer__c != acc.Steuernummer__c) || oldMap.get(acc.Id).BillingCountryCode != acc.BillingCountryCode)) {
                    taxIdSet.add(acc.Steuernummer__c);
                }
            }
        }

        if ( ! taxIdSet.isEmpty()) {
            List<Account> duplicateTaxIDList = [
                    SELECT Id, Steuernummer__c, BillingCountryCode, Name, RecordTypeId
                    FROM Account
                    WHERE Steuernummer__c IN :taxIdSet AND
                    BillingCountryCode != null
                    LIMIT 50000];

            Map<String, List<Account>> taxIdToAccListMap = new Map<String, List<Account>>();
            for (Account acc : duplicateTaxIDList) {
                if ( ! taxIdToAccListMap.containsKey(acc.Steuernummer__c)) {
                    taxIdToAccListMap.put(acc.Steuernummer__c, new List<Account>());
                }
                taxIdToAccListMap.get(acc.Steuernummer__c).add(acc);
            }

            if ( ! taxIdToAccListMap.isEmpty()) {
                for (Account acc : newList) {
                    if (taxIdToAccListMap.containsKey(acc.Steuernummer__c)) {
                        for (Account accInMap : taxIdToAccListMap.get(acc.Steuernummer__c)) {
                            if (accInMap.Steuernummer__c == acc.Steuernummer__c && accInMap.BillingCountryCode.substring(0, 2) == acc.BillingCountryCode.substring(0, 2)
                                    && accInMap.RecordTypeId == acc.RecordTypeId && acc.RecordTypeId != accountRecordTypes.get('Retailer').getRecordTypeId()) {
                                String accountError = 'Duplicate Tax ID number is found. <a href=\'/' + accInMap.Id + '\' target=\'_blank\'>' + accInMap.Name + '</a>';

                                acc.addError(accountError, false);
                            }
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : sendRussianRequestForChangeAccountOwner
    *  Summary         : Send request for Change Account Owner for Russian Team Leader
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : oldMap and newList from trigger
    *  Returns         : void
    ******************************************************************************/
    public static void sendRussianRequestForChangeAccountOwner(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Map<Id, Id> blockChangeOwnerInAccounts = new Map<Id, Id>();
        for (Account account : newMap.values()) {
            if (accountRecordTypes.get('Russian').getRecordTypeId() == account.recordTypeId &&
                    account.OwnerId != oldMap.get(account.Id).ownerId) {
                blockChangeOwnerInAccounts.put(account.id, account.ownerid);
            }
        }

        if (blockChangeOwnerInAccounts.size() != 0) {
            List<User> currentUser = [
                    SELECT id, name, ManagerId, ProfileId
                    FROM User
                    WHERE id = :UserInfo.getUserId()
                    AND Profile.Name = 'Russian Sales Manager'
                    AND ManagerId != null ];
            if (currentUser.size() == 1) {
                // Проверить принадлежность территории
                Map<Id, String> territoriesGroups = new Map<Id, String>();
                for(FieldSalesTerritory__c fieldSalesTerritory : FieldSalesTerritory__c.getAll().values()){
                    territoriesGroups.put(fieldSalesTerritory.GroupId__c, fieldSalesTerritory.Name);
                }
                Map<String, Set<Id>> territoriesUsers = new Map<String, Set<Id>>();
                for(GroupMember groupMember : [
                        SELECT GroupId, Id, SystemModstamp, UserOrGroupId
                        FROM GroupMember
                        WHERE GroupId in :territoriesGroups.keySet() ]){
                    if(territoriesUsers.get(territoriesGroups.get(groupMember.GroupId)) == null){
                        territoriesUsers.put(territoriesGroups.get(groupMember.GroupId), new Set<Id>());
                    }
                    territoriesUsers.get(territoriesGroups.get(groupMember.GroupId)).add(groupMember.UserOrGroupId);
                }

                Map<Id, User> newOwnersMap = new Map<Id, User>([SELECT id, name FROM User where id = :blockChangeOwnerInAccounts.values()]);
                List<Messaging.Email> emails = new List<Messaging.Email>();
                for (Account newAccount : newMap.values()) {
                    if(newAccount.Territory__c != null && territoriesUsers.get(newAccount.Territory__c) != null &&
                            territoriesUsers.get(newAccount.Territory__c).contains(newAccount.OwnerId)){
                        continue; // skip block owner change for territory records.
                    }
                    if(blockChangeOwnerInAccounts.containsKey(newAccount.id)) {
                        if(newAccount.Moved_to_Start__c == 0) {
                            //VS SF-265
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).id,
                                    'Запрос принят',
                                    '<p>Запрос на перевод организации  <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + newAccount.Id + '" > ' + newAccount.id + ' </a>, ' +
                                            '<p>Инн : ' + newAccount.INN__c + '</p>' +
                                            '<p>Наименование Компании : ' + newAccount.Name + '</p>' +
                                            'отправлен вашему Тим Лидеру(Менеджеру)</p> <p>Пожалуйста ожидайте ответа</p>'));
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).ManagerId,
                                    'Запрос на перевод организации',
                                    '<p>Поступил запрос от ' + currentUser.get(0).Name + ' на перевод организации <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + newAccount.Id + '" > ' + newAccount.id + ' </a> на пользователя ' + newOwnersMap.get(newAccount.OwnerId).Name + ' </p>' +
                                            '<p>Инн : ' + newAccount.INN__c + '</p>' +
                                            '<p>Наименование Компании : ' + newAccount.Name + '</p>' +
                                            '<p>Для того чтобы подтвердить перевод организации, нажмите на кнопку "Подтвердить"</p>' +
                                            '<table border="0"> <tr> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=004&Answer=yes&idRecord=' + newAccount.Id + '&idNewOwner=' + newAccount.OwnerId + '"> Подтвердить </a> </th> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=004&Answer=no&idRecord=' + newAccount.Id + '&idNewOwner=' + newAccount.OwnerId + '"> Отклонить </a> </th> ' +
                                            '</tr> </table> '));
                        } else {
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).id,
                                    'Запрос отклонен',
                                    '<p>Запрос на перевод организации "' + newAccount.name + '", отклонен. Т.к. Организация имеет возможность, которая "Принята на старт"</p>' +
                                            '<p>Инн : ' + newAccount.INN__c + '</p>'));
                        }
                        Account oldAccount = oldMap.get(newAccount.id);
                        newAccount.OwnerId = oldAccount.OwnerId;
                    }
                }
                Messaging.sendEmail(emails);
            }
        }
    }

    public static Set<String> salesTeamProfileSet = new Set<String>{
            'Sales',
            'Sales Inbound',
            'Salesteamleiter',
            'Salesteamleiter Inbound',
            'Starts Team',
            'Starts Team Lead',
            'FleetcorEmea Profile'
    };


    public static Map<String, String> CountryToCurrencyIsoCodeMap = new Map<String, String>{
            'Austria' => 'EUR',
            'Belgium-FR' => 'EUR',
            'Belgium-NL' => 'EUR',
            'Czech Republic' => 'CZK',
            'Germany' => 'EUR',
            'Hungary' => 'HUF',
            'Luxembourg' => 'EUR',
            'Netherlands' => 'EUR',
            'Poland' => 'PLN',
            'Slovakia' => 'EUR',
            'Switzerland-DE' => 'CHF',
            'Switzerland-FR' => 'CHF',
            'Switzerland-IT' => 'CHF'
    };

    /*******************************************************************************
   *  Name            : setRecordAddressOKATO
   *  Summary         : set Region__c and Area__c based on Billing_OKATO__c
   *  CreatedDate     : 26.08.2019
   *  ModifiedDate    :
   *  Parameters      : Map<Id, Lead> oldMap, List<Lead> newList
   *  Returns         : void
   ******************************************************************************/
    public static void setRecordAddressFromOKATO(Map<Id, Account> oldMap, List<Account> newList){
        List<Account> listForUpdate = new List<Account>();
        if(oldMap == null){
            for(Account account : newList){
                if(Account.Billing_OKATO__c != null && Account.Billing_OKATO__c != ''){
                    listForUpdate.add(account);
                }
            }
        } else {
            for(Account account : newList){
                if(account.Billing_OKATO__c != null && account.Billing_OKATO__c != '' && account.Billing_OKATO__c != oldMap.get(account.Id).Billing_OKATO__c){
                    listForUpdate.add(account);
                }
            }
        }
        if(listForUpdate.size() != 0){
            Map<String, String> regions = new Map<String,String>();
            for(FS_Tree_Province__mdt region : [SELECT Id, Label, OKATO__c FROM  FS_Tree_Province__mdt]){
                regions.put(region.OKATO__c, region.Label);
            }
            Map<String, String> areas = new Map<String,String>();
            for(FS_Tree_Area__mdt area : [SELECT Id, Label, OKATO__c FROM  FS_Tree_Area__mdt]){
                areas.put(area.OKATO__c, area.Label);
            }

            for(Account account : listForUpdate){
                if(String.valueOf(account.Billing_OKATO__c).length()>=2){
                    if(regions.containsKey(String.valueOf(account.Billing_OKATO__c).substring(0,2))){
                        account.Region__c = regions.get(String.valueOf(account.Billing_OKATO__c).substring(0,2));
                    }
                }
                if(String.valueOf(account.Billing_OKATO__c).length()>=5){
                    if(areas.containsKey(String.valueOf(account.Billing_OKATO__c).substring(0,5))){
                        account.BillingArea__c = areas.get(String.valueOf(account.Billing_OKATO__c).substring(0,5));
                    }
                }
            }
        }
    }

    /*******************************************************************************
   *  Name            : setShippingAddressCCS
   *  Summary         : copy Billing Address to Shipping Address if Shipping is empty on insert
   *  CreatedDate     : 28.01.2020
   *  ModifiedDate    :
   *  Parameters      : List<Account> lstAccount
   *  Returns         : void
   ******************************************************************************/
    public static void setShippingAddressCCS(List<Account> lstAccount){
        for (Account a : lstAccount) {
            if((a.RecordTypeId == accountRecordTypes.get('CCS').getRecordTypeId() || (a.AccountSource == 'Carnet' && a.BillingCountry == 'Poland')) && a.ShippingCountryCode == null && a.ShippingStreet == null && a.ShippingCity == null && a.ShippingStateCode == null && a.ShippingPostalCode == null){
                a.ShippingCountryCode = a.BillingCountryCode;
                a.ShippingStreet = a.BillingStreet;
                a.ShippingCity = a.BillingCity;
                a.ShippingStateCode = a.BillingStateCode;
                a.ShippingPostalCode = a.BillingPostalCode;
            }
        }
    }

    /*******************************************************************************
   *  Name            : getAccountDataFromBizmachine
   *  Summary         : copy Billing Address to Shipping Address if Shipping is empty on insert
   *  CreatedDate     : 28.01.2020
   *  ModifiedDate    :
   *  Parameters      : List<Account> lstAccount
   *  Returns         : void
   ******************************************************************************/
    @TestVisible static Boolean makeCallout = true;
    public static void getAccountDataFromBizmachine(List<Account> newList){
        Set<Id> ids = new Set<Id>();
        for(Account acc : newList){
            if(acc.RecordTypeId == accountRecordTypes.get('CCS').getRecordTypeId() && acc.CCS_Company_ID__c != '00000000' && acc.CCS_Company_ID__c != null && checkCzechVATNumber(acc.CCS_Company_ID__c) && acc.BillingCountry == 'Czech Republic'){
                ids.add(acc.Id);
            }else{
                //Vytvořit log IČ není validní!
            }
        }
        if (ids.size() != 0) {
            if (makeCallout)getAccountDataFromBizmachineFutureCall(ids);
        }
    }

    public static void changedICOBizMachine(Map<Id, Account> oldMap, List<Account> newList){
        //Získání monitoring UID tag
        try{
            List<BizMachine_Data_Settings__c> monitoringIds = [SELECT BizMachine_Tag_UID__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Monitoring_Tag__c = true];
            String monitoringUID;
            if(monitoringIds.size() > 0){
                monitoringUID = monitoringIds[0].BizMachine_Tag_UID__c;
            }else{
                CCSLog.writeError('BizMachine', 'Monitoring Tag UID is not saved', 'There are no monitoring UID in Custom settings!');
                return;
            }

            for(Account acc : newList){
                if(oldMap.get(acc.Id).CCS_Company_ID__c != acc.CCS_Company_ID__c && acc.RecordTypeId == accountRecordTypes.get('CCS').getRecordTypeId() && acc.CCS_Company_ID__c != '00000000' && acc.CCS_Company_ID__c != null && checkCzechVATNumber(acc.CCS_Company_ID__c) && acc.BillingCountry == 'Czech Republic' ){
                    Set<Id> ids = new Set<Id>();
                    ids.add(acc.Id);
                    if (ids.size() != 0) {
                        if (makeCallout)getAccountDataFromBizmachineFutureCall(ids);
                        if (makeCallout)removeBizMachineTagFuture(oldMap.get(acc.Id).CCS_Company_ID__c, monitoringUID);
                    }

                }
            }
        }catch(Exception e){
            CCSLog.writeError('BizMachine', e.getMessage());
        }


    }

    @future(callout=true)
    public static void getAccountDataFromBizmachineFutureCall(Set<Id> ids){
        List<CCS_Log__c> ccsLogs = new List<CCS_Log__c>();
        List<Account> accounts = [SELECT Id, CCS_Company_ID__c FROM Account WHERE Id IN:ids];
        List<Account> accountsToUpdate = new List<Account>();

        //Ukládání Consumption Categories do Mapy
        Map<String, String> ConsumptionMap = new Map<String, String>();
        for(BizMachine_Data_Settings__c biz : [SELECT BizMachine_Tag_UID__c, BizMachine_Tag_Name__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Consumption_Category_Tag__c = true]){
            ConsumptionMap.put(biz.BizMachine_Tag_UID__c, biz.BizMachine_Tag_Name__c);
        }

        //Získání monitoring UID tag
        List<BizMachine_Data_Settings__c> monitoringIds = [SELECT BizMachine_Tag_UID__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Monitoring_Tag__c = true];
        String monitoringUID;
        if(monitoringIds.size() > 0){
            monitoringUID = monitoringIds[0].BizMachine_Tag_UID__c;
        }else{
            CCS_Log__c log = new CCS_Log__c();
            log.Source__c = 'BizMachine';
            log.Message__c = 'Monitoring Tag UID is not saved';
            log.Data__c = 'There are no monitoring UID in Custom settings!    '+(Set<String>)JSON.deserialize(JSON.serialize(ids), Set<String>.class);
            log.Level__c = 'Error';
            ccsLogs.add(log);
            //CCSLog.writeError('BizMachine', 'Monitoring Tag UID is not saved', 'There are no monitoring UID in Custom settings!    '+(Set<String>)JSON.deserialize(JSON.serialize(ids), Set<String>.class));
        }

        Map<Id, Account> accountMap = new Map<Id, Account>();
        for(Account acc : accounts){
            accountMap.put(acc.Id, acc);
        }

        //List namapovaných polí
        List<BizMachine_Data_Settings__c> mappingFields = [SELECT BizMachine_API_Name__c, Salesforce_API_Name__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Mapping_Field__c = true];

        //List namapovaných tagů
        List<BizMachine_Data_Settings__c> mappingTags = [SELECT Salesforce_API_Name__c, BizMachine_Tag_UID__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Mapping_Tag__c = true];

        for(Id accId : ids){
            Account accToUpdate = accountMap.get(accId);
            String jsonText = BizMachineWebServices.getCompanyDetailHttpResponse(accountMap.get(accId).CCS_Company_ID__c).getBody();
            jsonText.replace('Currency', 'Currency_x');
            accToUpdate.Consumption_Category__c = null;
            accToUpdate.Consumption_Category_Percentile__c = null;

            BizMachineCompanyClass biz = BizMachineCompanyClass.parse(jsonText);
            Map<String, Object> bMap = BizMachineCompanyClass.getBMCompanyMap(biz);

            for(BizMachine_Data_Settings__c bd : mappingFields){
                if(bMap.containsKey(bd.BizMachine_API_Name__c)){
                    accToUpdate.put(bd.Salesforce_API_Name__c, bMap.get(bd.BizMachine_API_Name__c));
                }else{
                    CCS_Log__c log = new CCS_Log__c();
                    log.Source__c = 'BizMachine';
                    log.Message__c = 'No field in BizMachine '+accToUpdate.CCS_Company_ID__c;
                    log.Data__c =    'Field not found in BizMachine Callout: '+bd.BizMachine_API_Name__c+'    '+(Set<String>)JSON.deserialize(JSON.serialize(ids), Set<String>.class);
                    log.Level__c = 'Warning';
                    ccsLogs.add(log);

                    //CCSLog.writeWarning('BizMachine', 'No field in BizMachine', 'Field not found in BizMachine Callout: '+bd.BizMachine_API_Name__c+'    '+(Set<String>)JSON.deserialize(JSON.serialize(ids), Set<String>.class));
                }
            }

            BizMachineCompanyTag tags = BizMachineCompanyTag.parse(BizMachineWebServices.getCompanyTags(accountMap.get(accId).CCS_Company_ID__c).getBody());

            Map<String, String> mapMappingTags = new Map<String, String>();
            for(BizMachine_Data_Settings__c tag : mappingTags){
                mapMappingTags.put(tag.BizMachine_Tag_UID__c, tag.Salesforce_API_Name__c);
                accToUpdate.put(tag.Salesforce_API_Name__c, false);
            }

            for(BizMachineCompanyTag.Data tag: tags.data){
                //system.debug(tag.tag.uid);
                //system.debug(tag.description);
                if(ConsumptionMap.containsKey(tag.tag.uid)){
                    accToUpdate.Consumption_Category__c = ConsumptionMap.get(tag.tag.uid);
                    if(tag.description != null){
                        accToUpdate.Consumption_Category_Percentile__c = Decimal.valueOf(tag.description);
                    }
                }

                try{
                    if(mapMappingTags.containsKey(tag.tag.uid)){
                        accToUpdate.put(mapMappingTags.get(tag.tag.uid), true);
                    }
                }catch(Exception e){
                    CCS_Log__c log = new CCS_Log__c();
                    log.Source__c = 'BizMachine';
                    log.Message__c = 'Mapping fields to Account '+accToUpdate.CCS_Company_ID__c;
                    log.Data__c =    e.getMessage();
                    log.Level__c = 'Error';
                    ccsLogs.add(log);

                    //CCSLog.writeError('BizMachine', e.getMessage());
                }
            }

            //Nastavení monitoringu
            HttpResponse setMonitoring = BizMachineWebServices.setTagCompanyRelation(accountMap.get(accId).CCS_Company_ID__c, monitoringUID);

            if(setMonitoring.getStatusCode() == 200){
                accToUpdate.BizMachine_Monitoring__c = true;
            }else{
                //Uložit do LOGU, že se nepodařilo nastavit monitoring pro firmu!!!

                CCS_Log__c log = new CCS_Log__c();
                log.Source__c = 'BizMachine';
                log.Message__c = 'Monitoring Failed';
                log.Data__c = 'Monitoring Failed for company'+accountMap.get(accId).CCS_Company_ID__c+'      '+setMonitoring.getBody();
                log.Level__c = 'Error';
                ccsLogs.add(log);
                //CCSLog.writeError('BizMachine', 'Monitoring Failed', 'Monitoring Failed for company'+accountMap.get(accId).CCS_Company_ID__c+'      '+setMonitoring.getBody());
            }
            accToUpdate.Last_Modified_By_BizMachine__c = DateTime.now();
            accountsToUpdate.add(accToUpdate);
        }

        update accountsToUpdate;
        insert ccsLogs;
    }

    public static Boolean checkCzechVATNumber(String ic){
        ic = ic.replaceAll( '\\s+', '');

        if(!ic.isNumeric()){
            return false;
        }

        if(ic.length() != 8){
            return false;
        }

        String[] icStrings = ic.split('');
        Integer i = 0;
        Integer a = 0;
        while(i < 7){
            Integer o=integer.valueof(icStrings[i]);
            a += o *(8-i);
            i++;
        }

        a = math.mod(a, 11);
        Integer c;
        if(a == 0){
            c = 1;
        }else if(a == 1){
            c = 0;
        }else{
            c = 11-a;
        }

        if(c == integer.valueof(icStrings[7])){
            return true;
        }else{
            return false;
        }
    }

    public static void removeBizMachineTag(List<Account> oldList){
        //Získání monitoring UID tag
        List<BizMachine_Data_Settings__c> monitoringIds = [SELECT BizMachine_Tag_UID__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Monitoring_Tag__c = true];
        List<CCS_Log__c> ccsLogs = new List<CCS_Log__c>();
        String monitoringUID;
        if(monitoringIds.size() > 0){
            monitoringUID = monitoringIds[0].BizMachine_Tag_UID__c;
        }else{
            CCSLog.writeError('BizMachine', 'Monitoring Tag UID is not saved', 'There are no monitoring UID in Custom settings!');
            return;
        }

        Map<String, Account> accountMap = new Map<String, Account>();
        for(Account acc : oldList){
            if(acc.RecordTypeId == accountRecordTypes.get('CCS').getRecordTypeId() && acc.CCS_Company_ID__c != '00000000' && acc.CCS_Company_ID__c != null && checkCzechVATNumber(acc.CCS_Company_ID__c) && acc.BillingCountry == 'Czech Republic'){
                accountMap.put(acc.CCS_Company_ID__c, acc);
            }else if(acc.RecordTypeId == accountRecordTypes.get('CCS').getRecordTypeId() && (acc.CCS_Company_ID__c != '00000000' || acc.CCS_Company_ID__c == null || checkCzechVATNumber(acc.CCS_Company_ID__c))){
                CCS_Log__c log = new CCS_Log__c();
                log.Source__c = 'BizMachine';
                log.Message__c = 'CompanyId is not valid';
                log.Data__c = 'DELETE ACCOUNT, Company ID '+acc.CCS_Company_ID__c+' is not valid!   '+acc.Id;
                log.Level__c = 'Error';
                ccsLogs.add(log);

                //CCSLog.writeError('BizMachine', 'CompanyId is not valid', 'DELETE ACCOUNT, Company ID '+acc.CCS_Company_ID__c+' is not valid!   '+acc.Id);
            }
        }

        //SOQL for Accounts (duplicates) with same IČO
        //List<Account> accounts = [SELECT CCS_Company_ID__c, Id FROM Account WHERE CCS_Company_ID__c IN :accountMap.keySet() AND BizMachine_Monitoring__c = TRUE];
        Map<String, Account> dupAccountMap = new Map<String, Account>();
        for(Account acc : [SELECT CCS_Company_ID__c, Id FROM Account WHERE CCS_Company_ID__c IN :accountMap.keySet() AND BizMachine_Monitoring__c = TRUE AND RecordTypeId = :accountRecordTypes.get('CCS').getRecordTypeId()]){
            dupAccountMap.put(acc.CCS_Company_ID__c, acc);
        }

        for(Account acc : oldList){
            if(!dupAccountMap.containsKey(acc.CCS_Company_ID__c)){
                //REMOVE BizMachine Monitoring Tag
                if(acc.RecordTypeId == accountRecordTypes.get('CCS').getRecordTypeId() && acc.CCS_Company_ID__c != '00000000' && acc.CCS_Company_ID__c != null && checkCzechVATNumber(acc.CCS_Company_ID__c) && acc.BillingCountry == 'Czech Republic'){
                    if (makeCallout)removeBizMachineTagFuture(acc.CCS_Company_ID__c, monitoringUID);
                }else if(acc.RecordTypeId == accountRecordTypes.get('CCS').getRecordTypeId() && (acc.CCS_Company_ID__c != '00000000' || acc.CCS_Company_ID__c == null || checkCzechVATNumber(acc.CCS_Company_ID__c))){
                    CCS_Log__c log = new CCS_Log__c();
                    log.Source__c = 'BizMachine';
                    log.Message__c = 'CompanyId is not valid';
                    log.Data__c = 'DELETE ACCOUNT, Company ID '+acc.CCS_Company_ID__c+' is not valid!   '+acc.Id;
                    log.Level__c = 'Error';
                    ccsLogs.add(log);
                    //CCSLog.writeError('BizMachine', 'CompanyId is not valid', 'DELETE ACCOUNT, Company ID '+acc.CCS_Company_ID__c+' is not valid!   '+acc.Id);
                }
            }
        }
        insert ccsLogs;
    }

    @future(callout=true)
    public static void removeBizMachineTagFuture(String ic, String uid){
        HttpResponse removeTag = BizMachineWebServices.removeTagCompanyRelation(ic, uid);
        if(removeTag.getStatusCode() != 200 && removeTag.getStatusCode() != 204){
            CCSLog.writeError('BizMachine', 'Remove Tag for Company FAILED', 'Tag for Company '+ic+' is not removed.     '+removeTag.getBody());
        }
    }
}