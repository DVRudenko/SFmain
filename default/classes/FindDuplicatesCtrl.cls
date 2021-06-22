public class FindDuplicatesCtrl {
    Transient public List<LeadWrapper> leadsResult {get; set;}
    Transient public List<AccountWrapper> accResult {get; set;}
    Transient public map<Id, AccountWrapper> accMap {get; set;}
    Transient public String accMapSize {get; set;}

    public String sEmail {get; set;}
    public Boolean isPublicDomain {get; set;}
    public Boolean isEmailSelected {get; set;}
    public String sPhone {get; set;}
    public String inputPhone {get; set;}
    public Boolean isPhoneSelected {get; set;}
    public String sInn {get; set;}
    public Boolean isINNSelected {get; set;}

    public String searchString {get; set;}

    public String recordId {get; set;}
    public String idForRequest { get; set; }
    public Id idToGetExtendedInfo { get; set; }
    public String commentForRequest { get; set; }
    public Map<Id, Boolean> recordAccessMap { get; set; }
    public String findPageTitle { get; set; }

    public Boolean isInboundUserRole {get {
        if (isInboundUserRole == null) {
            Set<String> restrictRoleNames = new Set<String>();
            for (RU_Inbound_Restrict_Group__c roleName : [SELECT id, name FROM RU_Inbound_Restrict_Group__c]) {
                restrictRoleNames.add(roleName.name);
            }
            Id roleId = UserInfo.getUserRoleId();
            List<UserRole> userRoles = ([SELECT Name FROM UserRole WHERE Id =: roleId AND Name =: restrictRoleNames]);

            if(userRoles.isEmpty()){
                return false;
            }
            return true;
        } else return isInboundUserRole;
    } set;}

    Transient public List<String> publicEmailDomainsList {get {
        if (publicEmailDomainsList == null) {
            List<PublicEmailDomains__c> pubDomainsList = PublicEmailDomains__c.getall().values();
            publicEmailDomainsList = new List<String>();
            for (PublicEmailDomains__c domain : pubDomainsList) {
                publicEmailDomainsList.add(domain.Name);
                publicEmailDomainsList.add('@' + domain.Name);
            }
        }
        return publicEmailDomainsList;
    } set;}

    Transient public String recordTypeLead {get {
        if (recordTypeLead == null) {
            return Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        } else {
            return recordTypeLead;
        }
    } set;}
    Transient public String recordTypeOpportunity {get {
        if (recordTypeOpportunity == null) {
            return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        } else {
            return recordTypeOpportunity;
        }
    } set;}
    Transient public String recordTypeAccount {get {
        if (recordTypeAccount == null) {
            return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId();
        } else {
            return recordTypeAccount;
        }
    } set;}
    Transient public String recordTypeContact {get {
        if (recordTypeContact == null) {
            return Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId();
        } else {
            return recordTypeContact;
        }
    } set;}

    public void init() {
        makePreparements();
        recordId = ApexPages.currentPage().getParameters().get('id');
        if (recordId != null) {
            String typeName = ID.valueOf(recordId).getSObjectType().getDescribe().getName();
            if (typeName == 'Lead') {
                Lead currentLead = [
                        SELECT Phone_clean__c, Company, Name, FirstName, LastName, Email, Additional_Emails__c, PostalCode,
                                INN__c, Phone, MobilePhone, PPR_Contact_Phone__c
                        FROM Lead
                        WHERE ID = :recordId
                ];
                findPageTitle = 'Поиск дубликатов по интересу: "' + currentLead.FirstName + ' ' + currentLead.LastName + '" ';
                if (currentLead.email != null) {
                    sEmail = currentLead.email;
                    isEmailSelected = true;
                } else if (currentLead.Additional_Emails__c != null) {
                    List<String> emailList = currentLead.Additional_Emails__c.split(':');
                    if (emailList.size() > 0){
                        sEmail = emailList[0];
                        isEmailSelected = true;
                    }
                } else {
                    isEmailSelected = false;
                }
                if (currentLead.Phone != null) {
                    inputPhone = parsePhone(currentLead.Phone);
                    isPhoneSelected = true;
                } else if (currentLead.MobilePhone != null) {
                    inputPhone = parsePhone(currentLead.MobilePhone);
                    isPhoneSelected = true;
                } else if (currentLead.PPR_Contact_Phone__c != null) {
                    inputPhone = parsePhone(currentLead.PPR_Contact_Phone__c);
                    isPhoneSelected = true;
                } else {
                    isPhoneSelected = false;
                }
                if (currentLead.inn__c != null) {
                    sInn = currentLead.inn__c;
                    isInnSelected = true;
                } else {
                    isInnSelected = false;
                }
            } else if (typeName == 'Opportunity') {
                Opportunity currentOpportunity = [
                        SELECT name, inn_opp__c, company_legal_name__c, account.name, account.phone_clean__c, Source_of_Lead_o__c
                        FROM Opportunity
                        WHERE ID = :recordId
                ];
                List<OpportunityContactRole> oppConRoles = [
                    SELECT
                        Id, OpportunityId, ContactId, IsPrimary, Contact.Phone, Contact.MobilePhone, Contact.PPR_Contact_Phone__c, Contact.AssistantPhone,
                        Contact.HomePhone, Contact.OtherPhone, Contact.Email, Contact.Additional_Emails__c, Contact.LastModifiedDate
                    FROM OpportunityContactRole
                    WHERE OpportunityId = :recordId];
                findPageTitle = 'Поиск дубликатов по возможности: "' + currentOpportunity.name + '"';
                isEmailSelected = false;
                isPhoneSelected = false;
                Datetime lastModifiedDate = null;
                for (OpportunityContactRole oppConRole : oppConRoles) {
                    if (oppConRole.IsPrimary || lastModifiedDate == null || lastModifiedDate < oppConRole.Contact.LastModifiedDate) {
                        lastModifiedDate = oppConRole.Contact.LastModifiedDate;
                        if (oppConRole.Contact.Phone != null) {
                            inputPhone =  parsePhone(oppConRole.Contact.Phone);
                            isPhoneSelected = true;
                        } else if (oppConRole.Contact.MobilePhone != null) {
                            inputPhone =  parsePhone(oppConRole.Contact.MobilePhone);
                            isPhoneSelected = true;
                        } else if (oppConRole.Contact.PPR_Contact_Phone__c != null) {
                            inputPhone =  parsePhone(oppConRole.Contact.PPR_Contact_Phone__c);
                            isPhoneSelected = true;
                        } else if (oppConRole.Contact.AssistantPhone != null) {
                            inputPhone =  parsePhone(oppConRole.Contact.AssistantPhone);
                            isPhoneSelected = true;
                        } else if (oppConRole.Contact.HomePhone != null) {
                            inputPhone =  parsePhone(oppConRole.Contact.HomePhone);
                            isPhoneSelected = true;
                        } else if (oppConRole.Contact.OtherPhone != null) {
                            inputPhone =  parsePhone(oppConRole.Contact.OtherPhone);
                            isPhoneSelected = true;
                        }
                        if (oppConRole.Contact.Email != null) {
                            sEmail = oppConRole.Contact.Email;
                            isEmailSelected = true;
                        } else if (oppConRole.Contact.Additional_Emails__c != null) {
                            List<String> emailList = oppConRole.Contact.Additional_Emails__c.split(':');
                            if (emailList.size() > 0){
                                sEmail = emailList[0];
                                isEmailSelected = true;
                            }
                        }
                        if (oppConRole.IsPrimary) break;
                    }
                }
                if (currentOpportunity.inn_opp__c != null) {
                    sInn = currentOpportunity.inn_Opp__c;
                    isInnSelected = true;
                } else {
                    isInnSelected = false;
                }
            }
            searchPage();
        } else  if (searchString != null && searchString.trim() != '') {
            this.isEmailSelected = false;
            this.isPhoneSelected = false;
            this.isINNSelected = false;

            this.searchString = this.searchString.trim();

            if (this.searchString != '' && this.searchString.length() > 4) {
                this.inputPhone = parsePhone(this.searchString);
                this.isPhoneSelected = true;
            }
            if (this.searchString != '' && this.searchString.length() > 3) {
                this.isEmailSelected = true;
                this.sEmail = this.searchString;
            }
            if (this.searchString != '' && this.searchString.length() > 9) {
                this.isInnSelected = true;
                this.sInn = this.searchString;
            }
            searchPage();
        }
    }

    private void makePreparements() {
        recordAccessMap = new Map<Id, Boolean>();
        findPageTitle = 'Поиск дубликатов';
        this.isPublicDomain = false;
    }

    /*******************************************************************************
    *  Name            : getExtendedInfo()
    *  Summary         : sets additional info
    *  CreatedDate     : 08/04/2020
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getExtendedInfo() {
        if (idToGetExtendedInfo.getSobjectType() == Schema.Lead.SObjectType) {
            Integer targetIndex;
            for (LeadWrapper currObj: leadsResult) {
                if (idToGetExtendedInfo != null && idToGetExtendedInfo.equals(currObj.record.Id)) {
                    targetIndex = leadsResult.indexOf(currObj);
                    break;
                }
            }
            if (targetIndex != null) {
                User targetOwner = getExtendedUserInfoById(leadsResult.get(targetIndex).record.OwnerId);
                if (targetOwner != null) {
                    leadsResult.get(targetIndex).ownerExtension = targetOwner.Extension;
                    leadsResult.get(targetIndex).managerName = (targetOwner.Manager.FirstName != null ? targetOwner.Manager.FirstName : '') + ' ' +
                        (targetOwner.Manager.LastName != null ? targetOwner.Manager.LastName : '');
                }
            }
        } else if (idToGetExtendedInfo.getSobjectType() == Schema.Account.SObjectType) {
            if (accMap.containsKey(idToGetExtendedInfo) != null) {
                User targetOwner = getExtendedUserInfoById(accMap.get(idToGetExtendedInfo).record.OwnerId);
                if (targetOwner != null) {
                    accMap.get(idToGetExtendedInfo).ownerExtension = targetOwner.Extension;
                    accMap.get(idToGetExtendedInfo).managerName = (targetOwner.Manager.FirstName != null ? targetOwner.Manager.FirstName : '') + ' ' +
                        (targetOwner.Manager.LastName != null ? targetOwner.Manager.LastName : '');
                }
            }
        } else if (idToGetExtendedInfo.getSobjectType() == Schema.Contact.SObjectType) {
            List<ContactWrapper> targetObjects = new List<ContactWrapper>();
            for (AccountWrapper acc : accMap.values()) {
                if (acc.conList != null) {
                    for (ContactWrapper currObj: acc.conList) {
                        if (idToGetExtendedInfo != null && idToGetExtendedInfo.equals(currObj.record.Id)) {
                            targetObjects.add(currObj);
                        }
                    }
                }
            }
            if (targetObjects.size() > 0) {
                User targetOwner = getExtendedUserInfoById(targetObjects[0].record.OwnerId);
                if (targetOwner != null) {
                    for (ContactWrapper currObj : targetObjects) {
                        currObj.ownerExtension = targetOwner.Extension;
                        currObj.managerName = (targetOwner.Manager.FirstName != null ? targetOwner.Manager.FirstName : '') + ' ' +
                            (targetOwner.Manager.LastName != null ? targetOwner.Manager.LastName : '');
                    }
                }
            }
        } else if (idToGetExtendedInfo.getSobjectType() == Schema.Opportunity.SObjectType) {
            List<OpportunityWrapper> targetObjects = new List<OpportunityWrapper>();
            for (AccountWrapper acc : accMap.values()) {
                if (acc.oppList != null) {
                    for (OpportunityWrapper currObj: acc.oppList) {
                        if (idToGetExtendedInfo != null && idToGetExtendedInfo.equals(currObj.record.Id)) {
                            targetObjects.add(currObj);
                        }
                    }
                }
            }
            if (targetObjects.size() > 0) {
                User targetOwner = getExtendedUserInfoById(targetObjects[0].record.OwnerId);
                if (targetOwner != null) {
                    for (OpportunityWrapper currObj : targetObjects) {
                        currObj.ownerExtension = targetOwner.Extension;
                        currObj.managerName = (targetOwner.Manager.FirstName != null ? targetOwner.Manager.FirstName : '') + ' ' +
                            (targetOwner.Manager.LastName != null ? targetOwner.Manager.LastName : '');
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : getExtendedUserInfoById(Id targetId)
    *  Summary         : returns info about extended user
    *  CreatedDate     : 08/04/2020
    *  ModifiedDate    : -
    *  Parameters      : targetId - extended user id
    *  Returns         : User - extended user
    ******************************************************************************/
    public User getExtendedUserInfoById(Id targetId) {
        List<User> extendedUserInfo = ([
                SELECT Id, Name, IsActive, ManagerId, Manager.FirstName, Manager.LastName, Extension
                FROM User
                WHERE Id = :targetId
        ]);
        if (extendedUserInfo.size() == 1) {
            return extendedUserInfo[0];
        } else {
            return null;
        }
    }

    public PageReference searchFromSidebar() {
        PageReference ref = new PageReference('/apex/FindDuplicates');
        return ref;
    }

    public PageReference backToRecord() {
        return new PageReference('/' + recordId);
    }

    public void sendRequestForChangeOwner() {
        try {
            Set<String> approveUsersEmails = new Set<String>();
            for (RU_Admin_Approver__c emailApprover : [SELECT id, name FROM Ru_Admin_Approver__c]) { //Custom Settings
                approveUsersEmails.add(emailApprover.name);
            }

            if ((this.idForRequest <> '') && (approveUsersEmails.size() <> 0)) {
                String typeName = ID.valueOf(this.idForRequest).getSObjectType().getDescribe().getName();
                String innForEmail;
                String companyNameForEmail;
                String recordOwnerName;
                id recordOwnerId;

                String additionalInfo = '';
                if (typeName == 'Lead') {
                    List<Lead> recordLead = [SELECT inn__c, owner.name, Status, Source_of_Lead__c, Company FROM lead WHERE id = :idForRequest];
                    if (recordLead.size() == 1) {
                        innForEmail = recordLead.get(0).INN__c;
                        companyNameForEmail = recordLead.get(0).Company;
                        recordOwnerName = recordLead.get(0).owner.name;
                        recordOwnerId = recordLead.get(0).ownerid;
                        additionalInfo = '<p>Статус: ' + recordLead.get(0).Status + '</p>' + '<p>Источник интереса: ' + recordLead.get(0).Source_of_Lead__c + '</p>';

                    }
                } else if (typeName == 'Opportunity') {
                    List<Opportunity> recordOpportunity =
                    [SELECT INN_Opp__c, owner.name, StageName, account.Type, account.Name, Source_of_Lead_o__c FROM Opportunity WHERE id = :idForRequest];
                    if (recordOpportunity.size() == 1) {
                        innForEmail = recordOpportunity.get(0).INN_Opp__c;
                        companyNameForEmail = recordOpportunity.get(0).account.Name;
                        recordOwnerName = recordOpportunity.get(0).owner.name;
                        recordOwnerId = recordOpportunity.get(0).ownerid;
                        additionalInfo = '<p>Этап: ' + recordOpportunity.get(0).StageName + '</p>' +
                                '<p>Тип организации: ' + recordOpportunity.get(0).account.Type  + '</p>' +
                                '<p>Источник интереса: ' + recordOpportunity.get(0).Source_of_Lead_o__c + '</p>';
                    }
                }
                Id currentUserId = UserInfo.getUserId();
                String currentUserEmail = UserInfo.getUserEmail();
                if ((currentUserId != recordOwnerId) && (recordOwnerId != null)) {

                    String[] approveUsersEmailsArray = new List<String>();
                    for (String item : approveUsersEmails) {
                        approveUsersEmailsArray.add(item);
                    }

                    List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();

                    emailMessageList.add(
                            EmailGenerator.prepareHtmlEmailToTarget(
                                    approveUsersEmailsArray,
                                    'Изменение владельца записи',
                                            '<p>Поступил запрос на изменение владельца записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.idForRequest + '" > ' + this.idForRequest + ' </a> </p>' +
                                            '<p>Тип записи  : ' + typeName + '</p>' +
                                            additionalInfo +
                                            '<p>Инн : ' + innForEmail + '</p>' +
                                            '<p>Наименование Компании : ' + companyNameForEmail + '</p>' +
                                            '<p>Текущий  владелец     : ' + recordOwnerName + '</p>' +
                                            '<p>Изменить владельца на : ' + Userinfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
                                            '<p>Комментарий : ' + this.commentForRequest + '</p>' +
                                            '<p>Для того чтобы изменить владельца записи, нажмите на кнопку "Подтвердить"</p>' +
                                            '<table border="0"> <tr> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=001&Answer=yes&idRecord=' + this.idForRequest + '&idNewOwner=' + currentUserId + '"> Подтвердить </a> </th> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=001&Answer=no&idRecord=' + this.idForRequest + '&idNewOwner=' + currentUserId + '"> Отклонить </a> </th> ' +
                                            '</tr> </table> '
                            )
                    );
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_RequestSended));
                    emailMessageList.add(
                            EmailGenerator.prepareHtmlEmailToTarget(
                                    new String[]{currentUserEmail},
                                    'Запрос принят',
                                            '<p>Ваш запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.idForRequest + '" > ' + this.idForRequest + ' </a> - отправлен Администратору</p>' +
                                            '<p>Инн : ' + innForEmail + '</p>' +
                                            '<p>Наименование Компании : ' + companyNameForEmail + '</p>' +
                                            '<p>Пожалуйста ожидайте ответа</p>'
                            )
                    );
                    Messaging.sendEmail(emailMessageList);

                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0011_SelectTheRecord));
            }
        } catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + e.getMessage() + '(' + e.getStackTraceString() + ')'));
        }
        this.commentForRequest = '';
        this.idForRequest = '';
    }

    public static Boolean isInboundUserRole() {
        Set<String> restrictRoleNames = new Set<String>();
        for (RU_Inbound_Restrict_Group__c roleName : [SELECT id, name FROM RU_Inbound_Restrict_Group__c]) {
            restrictRoleNames.add(roleName.name);
        }
        Id roleId = UserInfo.getUserRoleId();
        List<UserRole> userRoles = ([SELECT Name FROM UserRole WHERE Id =: roleId AND Name =: restrictRoleNames]);

        if(userRoles.isEmpty()){
            return false;
        }
        return true;
    }

    public String parsePhone(String phoneSubstring){
        if(phoneSubstring != null){
            phoneSubstring = phoneSubstring.replaceAll(' ', '');
            if(phoneSubstring.length() > 10 && phoneSubstring.startsWith('8')) {
                phoneSubstring  = phoneSubstring.substring(1) ;
            } if (phoneSubstring.length() > 10 && phoneSubstring.startsWith('+7')) {
                phoneSubstring  = phoneSubstring.substring(2);
            } if (phoneSubstring.contains('#')) {
                phoneSubstring  = phoneSubstring.substringBefore('#');
            }
        }
        return phoneSubstring;
    }

    public void searchPage() {
        if (this.isEmailSelected && this.publicEmailDomainsList.contains(this.sEmail)) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    Label.FindDuplicates_no_public_domains
            ));
            leadsResult = new List<LeadWrapper>();
            accMap = new Map<Id, AccountWrapper>();
            accMapSize = '0';

            return;
        }
        
        sPhone = inputPhone;
        sPhone = parsePhone(sPhone);
        findDublicatesLead();

        Map<String, List<ContactWrapper>> conMap = findDublicatesCon();
        List<AccountWrapper> accList = findDublicatesAcc(conMap);
        Map<String, List<OpportunityWrapper>> oppMap = findDublicatesOpp();

        for (AccountWrapper acc :accList) {
            acc.oppList = oppMap.get(acc.record.Id);
            acc.checkSelectable();
        }
    }

    public void findDublicatesLead() {
        leadsResult = new List<LeadWrapper>();
        List<Lead> leadList = Database.query('SELECT Id FROM Lead LIMIT 10');
        //SF-1060 begin
        //SF-1456 add Source_of_Lead__c
        String leadSoql = 'SELECT id, OwnerId, Owner.Name, Owner.isActive, Name, Company, isConverted, INN__c, Status, ' +
                            'LastActivityDate, Email, CreatedDate, MobilePhone, Phone, Five9_Phone__c, PPR_Contact_Phone__c, ' +
                            'Data_com_phone__c, Additional_Phones__c, Additional_Emails__c, LastTransferDate, ' +
                            'Formatted_phones__c, Formatted_phones_additional__c, Source_of_Lead__c, Last_Owner_Change_Date_RUS__c, ' +
                           '(' +
                                'Select ActivityDate ' +
                                'from OpenActivities ' +
                                'Order by CreatedDate DESC ' +
                                'Limit 1' +
                            ') ' +
                            'FROM Lead ' +
                            'WHERE (';
        //SF-1060 end
        List<String> leadSoqlWhere = new List<String>();
        if(isEmailSelected && String.isNotBlank(this.sEmail)) {
            String domain = this.sEmail.substringAfter('@');
            if (String.isBlank(domain)) {
                System.debug('DOESN\'T HAVE DOMAIN');
                this.isPublicDomain = false;
                leadSoqlWhere.add(
                                '(Email LIKE \'%' + this.sEmail + '%\' OR ' +
                                'Additional_Emails__c LIKE \'%' + this.sEmail + '%\')'
                );
            } else if (this.publicEmailDomainsList.contains(domain)) {
                //public domain, full match
                System.debug('PUBLIC DOMAIN');
                this.isPublicDomain = true;
                leadSoqlWhere.add(
                                '(Email = \'' + sEmail + '\' OR ' +
                                'Additional_Emails__c LIKE \'%' + this.sEmail + '%\')'
                );
            } else {
                // not public domain, domain match
                System.debug('NOT PUBLIC DOMAIN');
                this.isPublicDomain = false;
                leadSoqlWhere.add(
                                '(Email LIKE \'%@' + domain + '\' OR ' +
                                'Additional_Emails__c LIKE \'%@' + domain + '%\')'
                );
            }
        }

        if(isPhoneSelected && sPhone != null && sPhone != '') {
            String formattedPhone = PhoneNumberUtils.getRawPhoneNumber(this.sPhone);
			leadSoqlWhere.add(
                            '(Formatted_phones__c LIKE \'%' + formattedPhone + '%\' OR ' +
                            'Formatted_phones_additional__c LIKE \'%' + formattedPhone + '%\')'
			);
        }
        if(isINNSelected && sInn != null && sInn != '') {
            leadSoqlWhere.add('INN__c LIKE \'%'+sInn+'%\'');
        }
        if(leadSoqlWhere.size() == 1) {
            leadSoql = leadSoql + leadSoqlWhere[0];
        } else if(leadSoqlWhere.size() > 1) {
            leadSoql = leadSoql + String.join(leadSoqlWhere, ' OR ');
        }

        if(leadSoqlWhere.size() > 0) {
            leadSoql = leadSoql + ') AND RecordTypeId = :recordTypeLead AND isConverted = false ORDER BY OwnerId ASC LIMIT 40';
            System.debug('leadSoql=== ' + leadSoql);
            leadList = Database.query(leadSoql);
            System.debug('FIND DUPLICATES LEAD leadList size = ' + leadList.size());
            if (this.isPublicDomain) {
                leadList = E2EFormRuServiceImplHelper.matchAdditionalEmails(
                        leadList,
                        this.sEmail,
                        this.sPhone,
                        this.sInn
                );
            }
            System.debug('leadList=== ' + leadList);

            Set<Id> leadOwnerIds = new Set<Id>();
            Set<Id> leadIdList = new Set<Id>();
            for (Lead curLead : leadList) {
                leadOwnerIds.add(curLead.OwnerId);
                if (leadIdList.size() < 200) {
                    leadIdList.add(curLead.Id);
                } else {
                    recordAccessMap.put(curLead.Id, false);
                }
            }

            for(Lead l : leadList) {
                 if (!leadIdList.contains(l.Id)) {
                    continue;
                }

                LeadWrapper lw = new LeadWrapper(sInn, sPhone, sEmail, l);
                lw.request = false;
                if(l.Status == 'Konvertierte Leads') {
                    lw.isConvert = true;
                } else {
                    lw.isConvert = false;
                }
                lw.ownerName = l.Owner.Name;
                if(!l.Owner.IsActive) {
                    lw.colorOwner = 'grey';

                } else {
                    lw.colorOwner = 'black';
                }
                if (l.OpenActivities != null && l.OpenActivities.size() > 0) {
                    lw.activityDate = l.OpenActivities[0].ActivityDate;
                }

                leadsResult.add(lw);
            }
            System.debug('leadsResult=== ' + leadsResult);

            //---Lead Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT recordId, hasReadAccess
                    FROM UserRecordAccess
                    WHERE recordId IN :leadIdList AND UserId = :UserInfo.getUserId()
            ]) {
                recordAccessMap.put(userRecordAccess.recordId, userRecordAccess.hasReadAccess);
            }
        }
    }

    public List<AccountWrapper> findDublicatesAcc(Map<String, List<ContactWrapper>> conMap) {
        accResult = new List<AccountWrapper>();
        accMap = new Map<Id, AccountWrapper>();

        Set<String> accIds = new Set<String>(conMap.keySet());
        //SF-1060
        String accSoql = 'SELECT Id, Name, Type, INN__c, CreatedDate, OwnerId, Owner.Name, Owner.isActive,' +
                            ' Phone, Mobile_Phone__c, CM_mobile__c, Phone_Crif__c, SM_mobile__c, Telephone__c, TM_mobile__c,' +
                            ' Last_pump_date__c ' +
                            'FROM Account' +
                            ' WHERE (' +
                            'Id IN :accIds ' +
                            'AND RecordTypeId = :recordTypeAccount' +
                '           )';
        //SF-1060 end
        if(isINNSelected && sInn != null && sInn != '') {
            accSoql = accSoql + ' OR (INN__c LIKE \'%'+sInn+'%\' AND RecordTypeId = :recordTypeAccount)';
        }
        if(isPhoneSelected && sPhone != null && sPhone != '') {
            accSoql = accSoql + ' OR (('+
                                'Mobile_Phone__c LIKE \'%'+sPhone+'%\' OR ' +
                                'Phone LIKE \'%'+sPhone+'%\' OR '+
                                'CM_mobile__c LIKE \'%'+sPhone+'%\' OR '+
                                'Phone_Crif__c LIKE \'%'+sPhone+'%\' OR '+
                                'SM_mobile__c LIKE \'%'+sPhone+'%\' OR '+
                                'Telephone__c LIKE \'%'+sPhone+'%\' OR '+
                                'TM_mobile__c LIKE \'%'+sPhone+'%\') '+
                                'AND RecordTypeId = :recordTypeAccount)';
        }
        List<Account> accList = Database.query(accSoql);

        Set<Id> accOwnerIds = new Set<Id>();
        Set<Id> accIdList = new Set<Id>();
        for(Account acc : accList) {
            accOwnerIds.add(acc.OwnerId);
            if (accIdList.size() < 200) {
                accIdList.add(acc.Id);
            } else {
                recordAccessMap.put(acc.Id, false);
            }
        }

        for(Account acc : accList) {
            if (!accIdList.contains(acc.Id)) {
                continue;
            }

            AccountWrapper newAcc = new AccountWrapper(acc);
            newAcc.innMatched = (sInn == acc.INN__c)?true:false;
            if(!acc.Owner.IsActive) {
                newAcc.colorOwner = 'grey';
            } else {
                newAcc.colorOwner = 'black';
            }
            newAcc.setPhoneValue(sPhone);
            newAcc.conList = conMap.get(acc.Id);
            accResult.add(newAcc);
            accMap.put(acc.Id, newAcc);
        }
        accMapSize = String.valueOf(accMap.values().size());
        System.debug('accMap = ' + accMap.keySet().size());

        //---Account Access info
        for (UserRecordAccess userRecordAccess : [
                SELECT recordId, hasReadAccess
                FROM UserRecordAccess
                WHERE recordId IN :accIdList AND UserId = :UserInfo.getUserId()
        ]) {
            recordAccessMap.put(userRecordAccess.recordId, userRecordAccess.hasReadAccess);
        }

        return accResult;
    }

    public Map<String, List<OpportunityWrapper>> findDublicatesOpp() {
        Map<String, List<OpportunityWrapper>> oppMap = new Map<String, List<OpportunityWrapper>>();
        Set<Id> accSet = accMap.keySet();
        //SF-1456 add Source_of_Lead_o__c
        String oppSoql = 'SELECT Id, Name, StageName, CloseDate, CreatedDate, OwnerId, Owner.Name, Owner.isActive, ' +
                            'Last_Owner_Change_Date_RUS__c, AccountId, Account.INN__c, Source_of_Lead_o__c,' +
                            '(' +
                                'Select ActivityDate ' +
                                'from OpenActivities ' +
                                'Order by CreatedDate DESC ' +
                                'Limit 1' +
                            ') ' +
                            'FROM Opportunity ' +
                            'WHERE AccountId IN :accSet ' +
                            'AND RecordTypeId = :recordTypeOpportunity';

        List<Opportunity> oppList = Database.query(oppSoql);

        Set<Id> oppOwnerIds = new Set<Id>();
        Set<Id> oppIdList = new Set<Id>();
        for(Opportunity opp : oppList) {
            oppOwnerIds.add(opp.OwnerId);
            if (oppIdList.size() < 200) {
                oppIdList.add(opp.Id);
            }
        }
        for(Opportunity opp : oppList) {
            if (oppIdList.size() < 200) {
                oppIdList.add(opp.Id);
            } else {
                recordAccessMap.put(opp.Id, false);
            }

            OpportunityWrapper newOpp = new OpportunityWrapper(opp);
            if(!opp.Owner.IsActive) {
                newOpp.colorOwner = 'grey';
            } else {
                newOpp.colorOwner = 'black';
            }
            if (opp.OpenActivities != null && opp.OpenActivities.size() > 0) {
                newOpp.activityDate = opp.OpenActivities[0].ActivityDate;
            }
            List<OpportunityWrapper> oppWrap;
            if (oppMap.get(newOpp.accountId) != null) {
                oppWrap = oppMap.get(newOpp.accountId);
            } else {
                oppWrap = new List<OpportunityWrapper>();
            }
            oppWrap.add(newOpp);
            oppMap.put(newOpp.accountId, oppWrap);
        }
        System.debug('oppMap = ' + oppMap);

        //---Opportunity Access info
        for (UserRecordAccess userRecordAccess : [
                SELECT recordId, hasReadAccess
                FROM UserRecordAccess
                WHERE recordId IN :oppIdList AND UserId = :UserInfo.getUserId()
        ]) {
            recordAccessMap.put(userRecordAccess.recordId, userRecordAccess.hasReadAccess);
        }
        return oppMap;
    }

    public Map<String, List<ContactWrapper>> findDublicatesCon() {
        Map<String, List<ContactWrapper>> conMap = new Map<String, List<ContactWrapper>>();

        String conSoql = 'SELECT Id, Name, CreatedDate, Phone, AssistantPhone, HomePhone, MobilePhone, OtherPhone, ' +
                            'PPR_Contact_Phone__c, Additional_Phones__c, Email, Additional_Emails__c, OwnerId, ' +
                            'Owner.Name, Owner.isActive, AccountId, Formatted_phones_additional__c, Formatted_phones__c ' +
                            'FROM Contact ' +
                            'WHERE RecordTypeId = :recordTypeContact';
        List<String> conSoqlWhere = new List<String>();
        if(isEmailSelected && String.isNotBlank(this.sEmail)) {
            String domain = this.sEmail.substringAfter('@');
            if (String.isBlank(domain)) {
                System.debug('DOESN\'T HAVE DOMAIN');
                this.isPublicDomain = false;
                conSoqlWhere.add(
                                '(Email LIKE \'%' + this.sEmail + '%\' OR ' +
                                'Additional_Emails__c LIKE \'%' + this.sEmail + '%\')'
                );
            } else if (this.publicEmailDomainsList.contains(domain)) {
                //public domain, full match
                System.debug('PUBLIC DOMAIN');
                this.isPublicDomain = true;
                conSoqlWhere.add(
                                '(Email = \'' + sEmail + '\' OR ' +
                                'Additional_Emails__c LIKE \'%' + this.sEmail +'%\')'
                );
            } else {
                // not public domain, domain match
                System.debug('NOT PUBLIC DOMAIN');
                this.isPublicDomain = false;
                conSoqlWhere.add(
                                '(Email LIKE \'%@' + domain + '\' OR ' +
                                'Additional_Emails__c LIKE \'%@' + domain + '%\')'
                );
            }
        }

        if(isPhoneSelected && sPhone != null && sPhone != '') {
            String formattedPhone = PhoneNumberUtils.getRawPhoneNumber(this.sPhone);
			conSoqlWhere.add(
                                '(Formatted_phones__c LIKE \'%' + formattedPhone + '%\' OR ' +
                                'Formatted_phones_additional__c LIKE \'%' + formattedPhone + '%\')'
			);
        }

        if (conSoqlWhere.size() == 1) {
            conSoql = conSoql + ' AND (' + conSoqlWhere[0] + ')';
        } else if (conSoqlWhere.size() > 1) {
            conSoql = conSoql + ' AND (' + String.join(conSoqlWhere, ' OR ') + ')';
        }
        
        if(conSoqlWhere.size() > 0) {
            List<Contact> conList = Database.query(conSoql);
            if (this.isPublicDomain) {
                conList = E2EFormRuServiceImplHelper.matchAdditionalEmails(
                        conList,
                        this.sEmail,
                        this.sPhone
                );
            }

            Set<Id> conOwnerIds = new Set<Id>();
            Set<Id> conIdList = new Set<Id>();
            for(Contact con : conList) {
                conOwnerIds.add(con.OwnerId);
                if (conIdList.size() < 200) {
                    conIdList.add(con.Id);
                } else {
                    recordAccessMap.put(con.Id, false);
                }
            }
            for(Contact con : conList) {
                if (!conIdList.contains(con.Id)) {
                    continue;
                }

                ContactWrapper newCon = new ContactWrapper(sPhone, sEmail, con);
                if(!con.Owner.IsActive) {
                    newCon.colorOwner = 'grey';
                } else {
                    newCon.colorOwner = 'black';
                }
                List<ContactWrapper> conWrap;
                if (conMap.get(con.AccountId) != null) {
                    conWrap = conMap.get(con.accountId);
                } else {
                    conWrap = new List<ContactWrapper>();
                }
                conWrap.add(newCon);
                conMap.put(con.accountId, conWrap);
                System.debug('conMap = ' + conWrap);
            }

            //---Contact Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT recordId, hasReadAccess
                    FROM UserRecordAccess
                    WHERE recordId IN :conIdList AND UserId = :UserInfo.getUserId()
            ]) {
                recordAccessMap.put(userRecordAccess.recordId, userRecordAccess.hasReadAccess);
            }

            return conMap;
        }
        return new Map<String, List<ContactWrapper>>();
    }

    public class LeadWrapper {
        public Boolean request {get; set;}
        public Boolean isConvert {get; set;}
        public String inn {get; set;}
        public Boolean innMatched {get; set;}
        public String phone {get; set;}
        public Boolean phoneMatched {get; set;}
        public String mail {get; set;}
        public Boolean emailMatched {get; set;}
        public Date activityDate {get; set;}
        public String managerName {get; set;}
        public String ownerExtension {get; set;}

        public LeadWrapper(String inn, String phone, String mail, Lead record) {
            this.record = record;
            setInnValue(inn);
            setPhoneValue(phone);
            setEmailValue(mail);
        }
        public Lead record {get; set;}
        public String colorOwner {get; set;}
        public String ownerName {get; set;}

        public void setInnValue(String str){
            innMatched = false;
            if(record.INN__c != null) {
                if(str != null && str != '' && record.INN__c == str) {
                    innMatched = true;
                }
                inn = record.INN__c;
            } else {
                inn = '';
            }

        }

        public void setPhoneValue(String str){
            if(str == null || str == '') {
                phoneMatched = false;
                if(record.Phone != null) {
                    phone = record.Phone;
                } else {
                    phone = '';
                }
            } else {
                phoneMatched = true;
                if(record.Phone != null && record.Phone.contains(str)) {
                    phone = record.Phone;
                } else if(record.MobilePhone != null && record.MobilePhone.contains(str)) {
                    phone = record.MobilePhone;
                } else if(record.PPR_Contact_Phone__c != null && record.PPR_Contact_Phone__c.contains(str)) {
                    phone = record.PPR_Contact_Phone__c;
                } else if(record.Additional_Phones__c != null && record.Additional_Phones__c.contains(str)) {
                    phone = record.Additional_Phones__c;
                } else {
                    phoneMatched = false;
                    if(record.Phone != null) {
                        phone = record.Phone;
                    } else {
                        phone = '';
                    }
                }
            }
        }

        public void setEmailValue(String str){
            emailMatched = false;
            if(record.Email != null) {
                if(str != null && str != '' && record.Email.contains(str)) {
                    emailMatched = true;
                }
                mail = record.Email;
            } else  if (record.Additional_Emails__c != null) {
                if(str != null && str != '' && record.Additional_Emails__c.contains(str)) {
                    emailMatched = true;
                }
                mail = record.Additional_Emails__c;
            } else {
                mail = '';
            }
        }
    }

    public class AccountWrapper {
        public String name {get; set;}
        public String inn {get; set;}
        public Boolean innMatched {get; set;}
        public String phone {get; set;}
        public Boolean phoneMatched {get; set;}
        public String type {get; set;}
        public Datetime createdDate {get; set;}
        public User owner {get; set;}
        public String colorOwner {get; set;}
        public Account record {get; set;}
        public Boolean isSelectable {get; set;}
        public String managerName {get; set;}
        public String ownerExtension {get; set;}

        public List<OpportunityWrapper> oppList {get; set;}
        public List<ContactWrapper> conList {get; set;}

        public AccountWrapper(Account record) {
            this.name = record.Name;
            this.inn = record.INN__c;
            this.type = record.Type;
            this.createdDate = record.CreatedDate;
            this.owner = record.Owner;
            this.record = record;
            oppList = new List<OpportunityWrapper>();
            conList = new List<ContactWrapper>();
        }

        public void setPhoneValue(String str){
            phoneMatched = true;
            if(str == null) {
                phoneMatched = false;
                if(record.Phone != null) {
                    phone = record.Phone;
                } else {
                    phone = '';
                }
            } else if(record.Phone != null && record.Phone.contains(str)) {
                phone = record.Phone;
            } else if(record.Mobile_Phone__c != null && record.Mobile_Phone__c.contains(str)) {
                phone = record.Mobile_Phone__c;
            } else if(record.Telephone__c != null && record.Telephone__c.contains(str)) {
                phone = record.Telephone__c;
            } else if(record.CM_mobile__c != null && record.CM_mobile__c.contains(str)) {
                phone = record.CM_mobile__c;
            } else if(record.SM_mobile__c != null && record.SM_mobile__c.contains(str)) {
                phone = record.SM_mobile__c;
            } else if(record.Phone_Crif__c != null && record.Phone_Crif__c.contains(str)) {
                phone = record.Phone_Crif__c;
            } else if(record.TM_mobile__c != null && record.TM_mobile__c.contains(str)) {
                phone = record.TM_mobile__c;
            } else {
                phoneMatched = false;
                if(record.Phone != null) {
                    phone = record.Phone;
                } else {
                    phone = '';
                }
            }
        }

        public void checkSelectable() {
            isSelectable = true;
            if (oppList != null) {
                for (OpportunityWrapper opp: oppList) {
                    if (opp.stageName != 'Moved to Start') {
                        isSelectable = false;
                    }
                }
            }
        }
    }

    public class OpportunityWrapper {
        public String name {get; set;}
        public String stageName {get; set;}
        public Datetime closeDate {get; set;}
        public Datetime createdDate {get; set;}
        public User owner {get; set;}
        public String colorOwner {get; set;}
        public Datetime lastOwnerChangeDate {get; set;}
        public String accountId {get; set;}
        public Opportunity record {get; set;}
        public Date activityDate {get; set;}
        public String managerName {get; set;}
        public String ownerExtension {get; set;}

        public OpportunityWrapper(Opportunity record) {
            this.name = record.Name;
            this.stageName = record.StageName;
            this.closeDate = record.CloseDate;
            this.createdDate = record.CreatedDate;
            this.owner = record.Owner;
            this.lastOwnerChangeDate = record.Last_Owner_Change_Date_RUS__c;
            this.accountId = record.AccountId;
            this.record = record;
        }
    }

    public class ContactWrapper {
        public String name {get; set;}
        public String phone {get; set;}
        public Boolean phoneMatched {get; set;}
        public String email {get; set;}
        public Boolean emailMatched {get; set;}
        public Datetime createdDate {get; set;}
        public User owner {get; set;}
        public String colorOwner {get; set;}
        public Contact record {get; set;}
        public String managerName {get; set;}
        public String ownerExtension {get; set;}

        public ContactWrapper(String sPhone, String sEmail, Contact record) {
            this.name = record.Name;
            setPhoneValue(sPhone, record);
            setEmailValue(sEmail, record);
            this.createdDate = record.CreatedDate;
            this.owner = record.Owner;
            this.record = record;
        }

        public void setPhoneValue(String str, Contact record){
            if(str == null || str == '') {
                phoneMatched = false;
                if(record.Phone != null) {
                    phone = record.Phone;
                } else {
                    phone = '';
                }
            } else {
                phoneMatched = true;
                if(record.Phone != null && record.Phone.contains(str)) {
                    phone = record.Phone;
                } else if(record.MobilePhone != null && record.MobilePhone.contains(str)) {
                    phone = record.MobilePhone;
                } else if(record.PPR_Contact_Phone__c != null && record.PPR_Contact_Phone__c.contains(str)) {
                    phone = record.PPR_Contact_Phone__c;
                } else if(record.AssistantPhone != null && record.AssistantPhone.contains(str)) {
                    phone = record.AssistantPhone;
                } else if(record.HomePhone != null && record.HomePhone.contains(str)) {
                    phone = record.HomePhone;
                } else if(record.OtherPhone != null && record.OtherPhone.contains(str)) {
                    phone = record.OtherPhone;
                } else if(record.Additional_Phones__c != null && record.Additional_Phones__c.contains(str)) {
                    phone = record.Additional_Phones__c;
                } else {
                    if(record.Phone != null) {
                        phone = record.Phone;
                    } else {
                        phone = '';
                    }
                    phoneMatched = false;
                }
            }
        }

        public void setEmailValue(String str, Contact record){
            if(str == null || str == '') {
                emailMatched = false;
                if(record.Email != null) {
                    email = record.Email;
                } else {
                    email = '';
                }
            } else {
                emailMatched = true;
                if(record.Email != null && record.Email.contains(str)) {
                    email = record.Email;
                } else if(record.Additional_Emails__c != null && record.Additional_Emails__c.contains(str)) {
                    email = record.Additional_Emails__c;
                } else {
                    emailMatched = false;
                    if(record.Email != null) {
                        email = record.Email;
                    } else {
                        email = '';
                    }
                }
            }
        }
    }
}
