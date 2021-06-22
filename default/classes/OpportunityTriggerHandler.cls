public class OpportunityTriggerHandler {

    public static Boolean enablesTrigger = true; // TODO : remove from code (Replace by context & TriggerContext)
    public static Boolean isSendToZoho = false;
    public static Boolean isSendWelcomeEmail = false;
    public static Boolean isSendToBackOffice = false;
    public static Boolean isOpportunityClosed = true;
    public static Boolean isE2EForm = false;
    public static Boolean firstRun = true;
    public static final String STANDARD_BUSINESS_PROCESS = GlobalUtils.BusinessProcessType.Standard.name();
    public static final String RUSSIA = GlobalUtils.FleetcorCountries.Russia.name();
    private static Map<String, RecordTypeInfo> oppRecordTypes{
        get{
            if(oppRecordTypes == null){
                oppRecordTypes = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return oppRecordTypes;
        }
        private set;
    }
    private static Map<String, RecordTypeInfo> taskRecordTypes{
        get{
            if(taskRecordTypes == null){
                taskRecordTypes = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return taskRecordTypes;
        }
        private set;
    }
    public static final String RUSSIAN_RECORD_TYPE_ID = oppRecordTypes.get(GlobalUtils.OpportunityRecordTypes.Russian_Sales.name()).getRecordTypeId();

    public static String context = TriggerContext.STANDARD.name();
    public ENUM TriggerContext{
        STANDARD,           // default logic in trigger
        DISABLED,           // disable almost all logic in trigger
        DISTRIBUTION_ENGINE // trigger logic during changes from Unmanaged package - Distribution Engine
    }

    @TestVisible static Messaging.SingleEmailMessage flmtMail;

    public static void changeRussianCreditFactoryReportsOwner(Map<Id, Opportunity> opportunityMap) {
        List<Credit_Factory_Report__c> reports = ([
                SELECT OwnerId, RecordTypeId, Opportunity__c
                FROM Credit_Factory_Report__c
                WHERE Opportunity__c IN :opportunityMap.keySet()
        ]);
        Set<String> processableRecordTypes = new CFRTriggerHandlerHelper().getRecordTypesSetting(CFRTriggerHandlerHelper.RT_FOR_CHANGE_OWNER);
        if ( !new DefaultValidator().listIsEmpty(new List<String>(processableRecordTypes))) {
            List<Credit_Factory_Report__c> reportsToBeUpdated = new List<Credit_Factory_Report__c>();

            for (Credit_Factory_Report__c report : reports) {
                Boolean isRecordTypeProcessable = processableRecordTypes.contains(
                        CreditFactoryReportTriggerHandler.CFR_RT_MAP.get(report.RecordTypeId).getDeveloperName()
                );
                Id ownerId = opportunityMap.get(report.Opportunity__c).OwnerId;
                if (isRecordTypeProcessable && ownerId != null && !ownerId.equals(report.OwnerId)) {
                    report.OwnerId = ownerId;
                    reportsToBeUpdated.add(report);
                }
            }
            if ( !reportsToBeUpdated.isEmpty()) update reportsToBeUpdated;
        }
    }

    /*****************************************************************************
    *  Name            : processOpportunityScoring(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities, Boolean onUpdate)
    *  Summary         : launches scoring job for opportunity
    *  CreatedDate     : 30.07.2020
    *  Parameters      : List<Opportunity> opportunities
    *  Returns         : void
    ******************************************************************************/
    public static void processOpportunityScoring(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities, Boolean onUpdate) {
        Map<String, Object> settings = CFUtils.getScoringSettings();
        List<Object> stages = (List<Object>) settings.get('opportunityStageTriggers');
        Boolean active = (Boolean) settings.get('active');
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            if (opportunity.RecordTypeId.equals(RUSSIAN_RECORD_TYPE_ID) && active
                    && stages != null && stages.contains(opportunity.StageName)
                    && (!onUpdate || onUpdate && !opportunity.StageName.equals(oldOpportunities.get(opportunity.Id).StageName))) {
                opportunityIds.add(opportunity.Id);
            }
        }
        if (!opportunityIds.isEmpty()) System.enqueueJob(new CFOpportunityScoringQueueableRu(opportunityIds));
    }

    /*****************************************************************************
    *  Name            : setOpportunityBusinessProcess(List<Opportunity> opportunities)
    *  Summary         : sets opportunity business process to Standard if there is no assigned
    *  CreatedDate     : 09/10/2019
    *  Parameters      : List<Opportunity> opportunities
    *  Returns         : void
    ******************************************************************************/
    public static void setOpportunityStandardBusinessProcess(List<Opportunity> opportunities) {
        for (Opportunity opportunity : opportunities) {
            if (opportunity.RecordTypeId.equals(RUSSIAN_RECORD_TYPE_ID)
                    && !isE2EOpportunity(opportunity)
                    && String.isEmpty(opportunity.Business_process__c)) {
                opportunity.Business_process__c = STANDARD_BUSINESS_PROCESS;
            }
        }
    }


    public static void finishE2E2Process(Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> newOppsMap) {
        Set<Id> e2eDataObjects = new Set<Id>();
        for (Opportunity opp : newOppsMap.values()) {
            if (opp.E2E_2__c &&
                    opp.Opp_Owner_Profile__c != 'API Only' &&
                    opp.E2E_Status__c != 'Finished' &&
                    opp.E2E_Data_Object__c != null &&
                    e2eDealChanged(oldOppsMap.get(opp.Id), opp)) {
                opp.E2E_Status__c = 'Finished';
                opp.E2E_Sales_Type__c = 'E2E downgraded to manual';
                opp.E2E_Finish_Details__c = 'Not Completed';
                e2eDataObjects.add(opp.E2E_Data_Object__c);
            }
        }
        if (e2eDataObjects.isEmpty()) return;

        List<E2E_Data_Object__c> dataObjects = [
                SELECT Id
                FROM E2E_Data_Object__c
                WHERE E2E_Status__c != 'Finished' AND Id IN :e2eDataObjects];
        for (E2E_Data_Object__c dataObject : dataObjects) {
            dataObject.E2E_Status__c = 'Finished';
            dataObject.E2E_Finish_Details__c = 'Not Completed';
        }
        update dataObjects;
    }


    private static Boolean e2eDealChanged(Opportunity oldOpp, Opportunity newOpp) {
        if (oldOpp.StageName != newOpp.StageName ||
                oldOpp.Total_consumption_l_month__c != newOpp.Total_consumption_l_month__c ||
                oldOpp.AGB_Datenschutzhinweise_Richtigkeit__c != newOpp.AGB_Datenschutzhinweise_Richtigkeit__c ||
                oldOpp.Number_of_cars__c != newOpp.Number_of_cars__c ||
                oldOpp.Number_of_trucks__c != newOpp.Number_of_trucks__c ||
                oldOpp.Total_number_of_vehicles__c != newOpp.Total_number_of_vehicles__c ||
                oldOpp.Bevollmaechtigung__c != newOpp.Bevollmaechtigung__c ||
                oldOpp.Anzahl_der_Karten__c != newOpp.Anzahl_der_Karten__c ||
                oldOpp.Agree_to_process_pers_data_for_marketing__c != newOpp.Agree_to_process_pers_data_for_marketing__c ||
                oldOpp.Agree_to_telephone_contact__c != newOpp.Agree_to_telephone_contact__c ||
                oldOpp.Agree_to_receive_comm_info_by_email__c != newOpp.Agree_to_receive_comm_info_by_email__c ||
                oldOpp.CF_Credit_Limit__c != newOpp.CF_Credit_Limit__c ||
                oldOpp.Security_To_Pay__c != newOpp.Security_To_Pay__c ||
                oldOpp.Credit_System_Recommended_Limit__c != newOpp.Credit_System_Recommended_Limit__c) {
            return true;
        }

        return false;
    }


    /*****************************************************************************
    *  Name            : isE2EOpportunity(Opportunity opportunity)
    *  Summary         : defines attributes of E2E Opportunity
    *  CreatedDate     : 09/10/2019
    *  Parameters      : Opportunity opportunity
    *  Returns         : Boolean - whether E2E Opportunity or not
    ******************************************************************************/
    private static Boolean isE2EOpportunity(Opportunity opportunity) {
        return 'E2E Form RU'.equals(opportunity.Source_of_Lead_o__c)
                || 'E2E Form RU'.equals(opportunity.LeadSource)
                || 'E2E Form RU'.equals(opportunity.Channel_Source_Lead__c);
    }

    /*****************************************************************************
    *  Name            : verifyCompany(List<Opportunity> opportunities)
    *  Summary         : verifies opportunity after lead convert or Opportunity insert
    *  CreatedDate     : 09/10/2019
    *  Parameters      : List<Opportunity> opportunities
    *  Returns         : void
    ******************************************************************************/
    public static void verifyCompany(List<Opportunity> opportunities) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            if (CFUtils.getCFSettingsFor(RUSSIA) != null && CFUtils.getCFSettingsFor(RUSSIA).Check_on_opportunity_create__c) {
                if (isValidOpportunity(opportunity)) {
                    opportunityIds.add(opportunity.Id);
                }
            }
        }
        if ( !opportunityIds.isEmpty()) System.enqueueJob(new CFCheckCompanyQueueableRu(opportunityIds));
    }

    /*****************************************************************************
    *  Name            : verifyCompany(Map<Id, Opportunity> currentOpportunitiesMap, List<Opportunity> updatedOpportunities)
    *  Summary         : verifies opportunity after stage update
    *  CreatedDate     : 09/10/2019
    *  Parameters      : Map<Id, Opportunity> currentOpportunitiesMap, List<Opportunity> updatedOpportunities
    *  Returns         : void
    ******************************************************************************/
    public static void verifyCompany(Map<Id, Opportunity> currentOpportunitiesMap, List<Opportunity> updatedOpportunities) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity updatedOpportunity : updatedOpportunities) {
            if (CFUtils.getCFSettingsFor(RUSSIA) != null && CFUtils.getCFSettingsFor(RUSSIA).Check_on_opportunity_update__c) {
                if (!currentOpportunitiesMap.get(updatedOpportunity.Id).StageName.equals(updatedOpportunity.StageName) && isValidOpportunity(updatedOpportunity)) {
                    //mark that CF checking process for Opportunity started
                    updatedOpportunity.CF_checking__c = true;
                    opportunityIds.add(updatedOpportunity.Id);
                }
            }
        }
        if ( !opportunityIds.isEmpty()) System.enqueueJob(new CFCheckCompanyQueueableRu(opportunityIds));
    }

    /*****************************************************************************
    *  Name            : isValidOpportunity(Opportunity opportunity)
    *  Summary         : checks specific conditions on opportunity to process russian credit check
    *  CreatedDate     : 09/10/2019
    *  Parameters      : Opportunity opportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private static Boolean isValidOpportunity(Opportunity opportunity) {
        return opportunity.RecordTypeId.equals(RUSSIAN_RECORD_TYPE_ID)
                && (STANDARD_BUSINESS_PROCESS.equals(opportunity.Business_process__c) || String.isEmpty(opportunity.Business_process__c))
                && !opportunity.CF_checking__c && CFUtils.isValidOpportunityStage(opportunity.StageName, RUSSIA);
    }

    public static void setRecordType(List<Opportunity> newList) {
        for (Opportunity opp : newList) {
            if(opp.Lead_Record_Type__c == 'AllStar'){
                opp.RecordTypeId = oppRecordTypes.get('AllStar').getRecordTypeId();
            } else if(opp.Lead_Record_Type__c == 'Russian Sales') {
                opp.RecordTypeId = oppRecordTypes.get('Russian_Sales').getRecordTypeId();
            } else if(opp.Lead_Record_Type__c == 'Lotos') {
                opp.RecordTypeId = oppRecordTypes.get('Lotos').getRecordTypeId();
                opp.Product__c = '';
            }
            if(opp.RecordTypeId == oppRecordTypes.get('Euroshell').getRecordTypeId()) {
                if(opp.Registered_Country__c == 'Germany' || opp.Registered_Country__c == 'Netherlands' || opp.Registered_Country__c == 'Poland' || opp.Registered_Country__c == 'Belgium-NL' || opp.Registered_Country__c == 'Belgium-FR'){
                    opp.Product__c = '';
                }
            }
            if(opp.CCS_Opportunity_Record_Type__c == 'CCS Sales process'){
                opp.RecordTypeId = oppRecordTypes.get('CCS_Opportunity').getRecordTypeId();
                opp.Product__c = '';
                if (opp.Product_Solicited__c != 'OMV' && opp.IsClosed == false){
                    opp.Eco_Fee__c = false;
                }
            }
            if(opp.Lead_Record_Type__c == 'Carnet'){
                opp.RecordTypeId = oppRecordTypes.get('Carnet').getRecordTypeId();
            }
            if(opp.CCS_Opportunity_Record_Type__c == 'Endkunde' && opp.Owner.UserRoleId != null &&
                    (opp.Owner.UserRole.DeveloperName.startsWith('Altevida') || opp.Owner.Profile.Name.startsWith('CCS'))){
                opp.RecordTypeId = oppRecordTypes.get('Euroshell').getRecordTypeId();
            }
        }
    }

    public static void setOpporunityStageName(List<Opportunity> newList) {
        for (Opportunity opp : newList) {
            if (opp.Lead_Record_Type__c == 'Russian Sales' && oppRecordTypes.get('Russian_Sales').getRecordTypeId() == opp.RecordTypeId) {
                opp.StageName = 'Qualified Lead';
            }
        }
    }

    public static void updateLastOwnerDate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        for (Opportunity opp : newMap.values()) {
            updateLastOwnerDate(oldMap.get(opp.Id), opp);
        }
    }

    public static void updateLastOwnerDate(Opportunity oldOpportunity, Opportunity newOpportunity) {
        if (newOpportunity.OwnerId != oldOpportunity.OwnerId) {
            newOpportunity.Last_Owner_Change_Date__c = Datetime.now();
        }
    }

    public static void updateFirstLastOwnerDate(List<Opportunity> newOpps) {
        for (Opportunity o : newOpps) {
            o.Last_Owner_Change_Date__c = Datetime.now();
        }
    }

    public static void maketouppercase(Opportunity opportunity) {
        opportunity.Name = opportunity.Name.touppercase();
    }

    public static void maketouppercase(List<Opportunity> newList) {
        for (Opportunity opp : newList) {
            maketouppercase(opp);
        }
    }


    public static void sendWelcomeEmail(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Map<String, List<String>> accountToOpportunityMap = new Map<String, List<String>>();
        List<Task> welcomeTasksList = new List<Task>();
        Set<Id> oppsForContactRolesSet = new Set<Id>();
        Map<String, Opportunity> opptyWithChangedStatuses = new Map<String, Opportunity>();
        for (Opportunity opp : newMap.values()) {
            E2E_Form_General_Settings__c e2eGeneralSettings = E2E_Form_General_Settings__c.getInstance(opp.Registered_Country__c);
            if ( (oldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Won' && GlobalUtils.europeCountrySet.contains(opp.Registered_Country__c) &&
                    (oppRecordTypes.get('Euroshell').getRecordTypeId() == opp.RecordTypeId || oppRecordTypes.get('Euroshell_Starts').getRecordTypeId() == opp.RecordTypeId) && ! opp.E2E__c && ! opp.E2E_2__c)
                    ||
                    ((opp.E2E__c || opp.E2E_2__c) && e2eGeneralSettings != null && opp.OwnerId != e2eGeneralSettings.Integration_Admin_Id__c &&
                            oldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Won' &&
                            GlobalUtils.europeCountrySet.contains(opp.Registered_Country__c) &&
                            (oppRecordTypes.get('Euroshell').getRecordTypeId() == opp.RecordTypeId || oppRecordTypes.get('Euroshell_Starts').getRecordTypeId() == opp.RecordTypeId)) ) {

                if ( ! accountToOpportunityMap.containsKey(opp.AccountId)) {
                    accountToOpportunityMap.put(opp.AccountId, new List<String>());
                }
                accountToOpportunityMap.get(opp.AccountId).add(opp.Id);
                Task newTask = createWelcomeEmailTask(opp);
                welcomeTasksList.add(newTask);
                oppsForContactRolesSet.add(opp.Id);
                opptyWithChangedStatuses.put(opp.Id, opp);
            }
        }

        if (!isSendWelcomeEmail && !oppsForContactRolesSet.isEmpty()) {
            Email_Notifications__c emailCustomSetting = Email_Notifications__c.getInstance('Opportunity Welcome Letters');
            if (emailCustomSetting != null && emailCustomSetting.Enabled__c) {
                List<OrgWideEmailAddress> owaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu' LIMIT 1];
                if (owaList.isEmpty()) {
                    return;
                }
                String orgEmailAddressId = owaList.get(0).Id;

                List<EmailTemplate> allTemplates = [
                        SELECT Id, Name, Body, HtmlValue, Subject
                        FROM EmailTemplate
                        WHERE Name IN :GlobalUtils.welcomeEmailSet
                        LIMIT 1000
                ];

                Map<String, EmailTemplate> templatesMap = new Map<String, EmailTemplate>();
                Set<Id> templatesIdSet = new Set<Id>();
                for (EmailTemplate template : allTemplates) {
                    templatesMap.put(template.Name, template);
                    templatesIdSet.add(template.Id);
                }

                List<OpportunityContactRole> rolesList = [
                        SELECT Contact.Id, Contact.Email, Contact.AccountId, Contact.Account.BillingCountry, Role, OpportunityId
                        FROM OpportunityContactRole
                        WHERE OpportunityId IN :oppsForContactRolesSet AND
                        isPrimary = true
                        LIMIT 10000
                ];

                Map<String, String> oppIdToTemplateNameMap = getTemplateNameForMultiProducts(oppsForContactRolesSet);
                Map<String, Attachment> oppIdToAttachmentMap = getAttachmentForCarnet(oldMap, opptyWithChangedStatuses);
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                Map<String, Messaging.SingleEmailMessage> oppIdToMailMap = new Map<String, Messaging.SingleEmailMessage>();
                for (OpportunityContactRole role : rolesList) {
                    if (role.Contact.Email != null) {
                        if (accountToOpportunityMap.containsKey(role.Contact.AccountId)) {
                            for (String oppId : accountToOpportunityMap.get(role.Contact.AccountId)) {
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if (role.Contact.Account.BillingCountry == 'Poland') {
                                    mail.setTemplateID(templatesMap.get(oppIdToTemplateNameMap.get(oppId)).Id);
                                    if ( ! oppIdToAttachmentMap.isEmpty() ) {
                                        fileAttachments = setFileAttachmentToEmail(oppIdToAttachmentMap, oppId);
                                    }
                                    mail.setFileAttachments(fileAttachments);
                                } else {
                                    mail.setTemplateID(templatesMap.get(templatesForCountriesMap.get(role.Contact.Account.BillingCountry)).Id);
                                }
                                mail.setTargetObjectId(role.Contact.Id);
                                mail.setWhatId(oppId);
                                mail.setSaveAsActivity(false);
                                mail.setCharset('UTF-8');
                                allmsg.add(mail);
                                oppIdToMailMap.put(oppId, mail);
                            }
                        }
                    }
                }

                Savepoint sp = Database.setSavepoint();
                if (!Test.isRunningTest() && !allmsg.isEmpty()) {
                    isSendWelcomeEmail = true;
                    Messaging.sendEmail(allmsg);
                    Database.rollback(sp);
                }

                List<Attachment> emailsToPdfList = new List<Attachment>();
                for (Messaging.SingleEmailMessage message : oppIdToMailMap.values()) {
                    if (!oppIdToMailMap.isEmpty() && !Test.isRunningTest()) {
                        Attachment newPdf = new Attachment();
                        newPdf.ParentId = message.getWhatId();
                        newPdf.Body = Blob.valueOf('<head><meta charset="utf-8"></head>' + message.getHtmlBody());
                        newPdf.Name = 'Welcome Email.html';
                        emailsToPdfList.add(newPdf);
                    }
                }
                insert emailsToPdfList;

                List<Messaging.SingleEmailMessage> allmsgCC = new List<Messaging.SingleEmailMessage>();
                Map<String, List<Messaging.Emailfileattachment>> fileTemplateToAttachmentsMap = new Map<String, List<Messaging.Emailfileattachment>>();
                for (Attachment a : [SELECT Name, Body, BodyLength, Parent.Name FROM Attachment WHERE ParentId IN :templatesIdSet]) {
                    if (!fileTemplateToAttachmentsMap.containsKey(a.Parent.Name)) {
                        fileTemplateToAttachmentsMap.put(a.Parent.Name, new List<Messaging.Emailfileattachment>());
                    }
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.Body);
                    fileTemplateToAttachmentsMap.get(a.Parent.Name).add(efa);
                }
                List<Attachment> sepaAttachmentsList = [
                        SELECT ParentId, Name, Body
                        FROM Attachment
                        WHERE Name LIKE 'SEPAMandate%' AND ParentId IN :newMap.keySet()
                        LIMIT 1000];
                Map<Id, Attachment> sepaMap = new Map<Id, Attachment>();
                for (Attachment att : sepaAttachmentsList) {
                    sepaMap.put(att.ParentId, att);
                }
                for (String oppId : oppIdToMailMap.keySet()) {
                    String templateName = templatesForCountriesMap.get(newMap.get(oppId).Registered_Country__c);
                    List<Messaging.Emailfileattachment> attachmentsList = fileTemplateToAttachmentsMap.get(templateName);
                    if (attachmentsList == null) {
                        attachmentsList = new List<Messaging.Emailfileattachment>();
                    }
                    if (sepaMap.containsKey(oppId)) {
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(sepaMap.get(oppId).Name);
                        efa.setBody(sepaMap.get(oppId).Body);
                        attachmentsList.add(efa);
                    }
                    if ( ! fileAttachments.isEmpty() ) {
                        attachmentsList.add(fileAttachments.get(0));
                    }
                    Messaging.SingleEmailMessage mailCC = new Messaging.SingleEmailMessage();
                    mailCC.setFileAttachments(attachmentsList);
                    mailCC.setTargetObjectId(newMap.get(oppId).OwnerId);
                    mailCC.setOrgWideEmailAddressId(orgEmailAddressId);
                    mailCC.setSubject(oppIdToMailMap.get(oppId).getSubject());
                    mailCC.setHtmlBody(oppIdToMailMap.get(oppId).getHtmlBody());
                    mailCC.setPlainTextBody(oppIdToMailMap.get(oppId).getPlainTextBody());
                    mailCC.setSaveAsActivity(false);
                    mailCC.setCharset('UTF-8');
                    allmsgCC.add(mailCC);
                }
                for (OpportunityContactRole role : rolesList) {
                    if (role.Contact.Email != null) {
                        if (accountToOpportunityMap.containsKey(role.Contact.AccountId)) {
                            for (String oppId : accountToOpportunityMap.get(role.Contact.AccountId)) {
                                String templateName = templatesForCountriesMap.get(role.Contact.Account.BillingCountry);
                                List<Messaging.Emailfileattachment> attachmentsList = fileTemplateToAttachmentsMap.get(templateName);
                                if (attachmentsList == null) {
                                    attachmentsList = new List<Messaging.Emailfileattachment>();
                                }
                                if (sepaMap.containsKey(oppId)) {
                                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                                    efa.setFileName(sepaMap.get(oppId).Name);
                                    efa.setBody(sepaMap.get(oppId).Body);
                                    attachmentsList.add(efa);
                                }
                                if ( ! fileAttachments.isEmpty() ) {
                                    attachmentsList.add(fileAttachments.get(0));
                                }
                                Messaging.SingleEmailMessage mailCC = new Messaging.SingleEmailMessage();
                                mailCC.setFileAttachments(attachmentsList);
                                mailCC.setTargetObjectId(role.Contact.Id);
                                mailCC.setOrgWideEmailAddressId(orgEmailAddressId);
                                mailCC.setSubject(oppIdToMailMap.get(oppId).getSubject());
                                mailCC.setHtmlBody(oppIdToMailMap.get(oppId).getHtmlBody());
                                mailCC.setPlainTextBody(oppIdToMailMap.get(oppId).getPlainTextBody());
                                mailCC.setSaveAsActivity(false);
                                mailCC.setCharset('UTF-8');
                                allmsgCC.add(mailCC);
                            }
                        }
                    }
                }
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(allmsgCC);
                }
                insert welcomeTasksList;
            }
        }
    }


    private static Map<String, String> getTemplateNameForMultiProducts(Set<Id> oppIdsSet) {
        Map<String, String> oppIdToTemplateNameMap = new Map<String, String>();
        Map<String, Set<String>> oppIdToProductsMap = new Map<String, Set<String>>();

        List<OpportunityLineItem> oppLineItemList = [SELECT Product2.Family, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :oppIdsSet];
        if ( ! oppLineItemList.isEmpty()) {
            for (OpportunityLineItem oppLineItem : oppLineItemList) {
                if ( ! oppIdToProductsMap.containsKey(oppLineItem.OpportunityId) ) {
                    oppIdToProductsMap.put(oppLineItem.OpportunityId, new Set<String>());
                }
                oppIdToProductsMap.get(oppLineItem.OpportunityId).add(oppLineItem.Product2.Family);
            }

            for (String oppId : oppIdsSet) {
                if (oppIdToProductsMap.get(oppId).contains('SHELL') && oppIdToProductsMap.get(oppId).contains('Carnet')) {
                    oppIdToTemplateNameMap.put(oppId, 'Welcome_email_pl_shell_carnet');
                } else if (oppIdToProductsMap.get(oppId).contains('SHELL')) {
                    oppIdToTemplateNameMap.put(oppId, 'Letter_9_visualforce_PL');
                } else if (oppIdToProductsMap.get(oppId).contains('Carnet')) {
                    oppIdToTemplateNameMap.put(oppId, 'Carnet OBD PL welcome email_VF');
                }
            }
        }

        return oppIdToTemplateNameMap;
    }


    /*******************************************************************************
    *  Name            : sendEmailToBackOffice(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : sending email to backoffice for Starts Processes
    *  CreatedDate     : 18/07/2017
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendEmailToBackOffice(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        if (isSendToBackOffice) return;
        Map<String, Opportunity> opptiesWithChangedStartsStatusMap = new Map<String, Opportunity>();
        for (Opportunity oppty : newMap.values()) {
            if ((oppty.StageName != oldMap.get(oppty.Id).StageName &&
                    oppty.StageName == 'Closed Won' &&
                    (oppty.RecordTypeId == oppRecordTypes.get('Euroshell').getRecordTypeId() ||
                            oppty.RecordTypeId == oppRecordTypes.get('Shell_Universal_Card').getRecordTypeId() ||
                            oppty.RecordTypeId == oppRecordTypes.get('Lotos').getRecordTypeId())
            ) ||
                    ((oppty.Starts_Status__c != oldMap.get(oppty.Id).Starts_Status__c ||
                            oppty.Starts_Reason_for_Not_Fueling__c != oldMap.get(oppty.Id).Starts_Reason_for_Not_Fueling__c) &&
                            (oppty.Starts_Status__c == '2.3 First Check: Delay' ||
                                    oppty.Starts_Status__c == '3.3 Volume Check 1: Delay' ||
                                    oppty.Starts_Status__c == '4.3 Volume Check 2: Delay' ||
                                    oppty.Starts_Status__c == '5.3 Final Check: Delay') &&
                            (oppty.Starts_Reason_for_Not_Fueling__c == 'Did not receive PINs' ||
                                    oppty.Starts_Reason_for_Not_Fueling__c == 'Did not receive Cards')
                    ) ||
                    (oppty.Starts_Status__c != oldMap.get(oppty.Id).Starts_Status__c &&
                            oppty.Starts_Status__c == '5.5 Winback Failed' ||
                            oppty.Starts_Status__c == '0.6 Missing information provided'
                    )) {
                opptiesWithChangedStartsStatusMap.put(oppty.Id, oppty);
            }
        }

        if ( ! opptiesWithChangedStartsStatusMap.isEmpty() ) {
            StaticResource testCompanies = GlobalUtils.getStaticResource('GFNI_Test_Clients');
            Map<String, Object> countryCodeToCompaniesMap = GlobalUtils.getCompaniesByCountryMap(testCompanies);
            List<Object> listOfCustomers = new List<Object>();
            for (Opportunity opportunity : opptiesWithChangedStartsStatusMap.values()) {
                if (GlobalUtils.countryToCountryCodeMap.containsKey(opportunity.Registered_Country__c)) {
                    String countryCode = GlobalUtils.countryToCountryCodeMap.get(opportunity.Registered_Country__c);
                    listOfCustomers = GlobalUtils.getListOfCustomers(countryCodeToCompaniesMap, countryCode);
                    for (Object customer : listOfCustomers) {
                        if (opportunity.Name == (String) customer) {
                            //skip if it's test customer
                            opptiesWithChangedStartsStatusMap.remove(opportunity.Id);
                        }
                    }
                }
            }
        }

        if (!opptiesWithChangedStartsStatusMap.isEmpty()) {
            List<EmailTemplate> templatesList = [
                    SELECT Id, Name, Body, HtmlValue, Subject, DeveloperName
                    FROM EmailTemplate
                    WHERE DeveloperName IN :templatesForBackOfficeStartsStatusesMap.values()
                    LIMIT 10
            ];

            Map<String, EmailTemplate> templatesMap = new Map<String, EmailTemplate>();
            for (EmailTemplate template : templatesList) {
                templatesMap.put(template.DeveloperName, template);
            }

            Map<String, Attachment> oppIdToAttachmentMap = getAttachmentForCarnet(oldMap, opptiesWithChangedStartsStatusMap);
            Map<String, BackOffice_Notifications__c> backOfficeNotifyCustomSettingMap = BackOffice_Notifications__c.getAll();
            List<String> emailAddressesList = new List<String>();
            List<Messaging.SingleEmailMessage> allmessages = new List<Messaging.SingleEmailMessage>();
            List<Opportunity> opportunityForTasksList = new List<Opportunity>();
            if ( ! opptiesWithChangedStartsStatusMap.isEmpty()) {
                for (Opportunity oppty : opptiesWithChangedStartsStatusMap.values()) {
                    if (oppty.AccountId == null) continue;
                    if (oppty.Registered_Country__c == null) continue;

                    String customSettingsKey;
                    if (oppty.RecordTypeId != oppRecordTypes.get('Shell_Universal_Card').getRecordTypeId()) {
                        customSettingsKey = oppty.Registered_Country__c;
                    } else {
                        customSettingsKey = 'Poland_Shell Universal Card';
                    }
                    if (backOfficeNotifyCustomSettingMap.get(customSettingsKey) != null &&
                            backOfficeNotifyCustomSettingMap.get(customSettingsKey).Active__c == true) {
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        emailAddressesList.add(backOfficeNotifyCustomSettingMap.get(customSettingsKey).Email__c);
                        if (oppty.StageName != oldMap.get(oppty.Id).StageName && oppty.StageName == 'Closed Won') {
                            message.setTemplateID(templatesMap.get(templatesForBackOfficeStartsStatusesMap.get('new closed won')).Id);
                            if ( ! oppIdToAttachmentMap.isEmpty() ) {
                                List<Messaging.Emailfileattachment> fileAttachments = setFileAttachmentToEmail(oppIdToAttachmentMap, oppty.Id);
                                message.setFileAttachments(fileAttachments);
                            }
                        } else if ((oppty.Starts_Status__c == '2.3 First Check: Delay' ||
                                oppty.Starts_Status__c == '3.3 Volume Check 1: Delay' ||
                                oppty.Starts_Status__c == '4.3 Volume Check 2: Delay' ||
                                oppty.Starts_Status__c == '5.3 Final Check: Delay') && oppty.Starts_Reason_for_Not_Fueling__c == 'Did not receive Cards') {
                            message.setTemplateID(templatesMap.get(templatesForBackOfficeStartsStatusesMap.get('New Cards Requested to BO')).Id);
                        } else if ((oppty.Starts_Status__c == '2.3 First Check: Delay' ||
                                oppty.Starts_Status__c == '3.3 Volume Check 1: Delay' ||
                                oppty.Starts_Status__c == '4.3 Volume Check 2: Delay' ||
                                oppty.Starts_Status__c == '5.3 Final Check: Delay') && oppty.Starts_Reason_for_Not_Fueling__c == 'Did not receive PINs') {
                            message.setTemplateID(templatesMap.get(templatesForBackOfficeStartsStatusesMap.get('New PINs Requested to BO')).Id);
                        } else {
                            message.setTemplateID(templatesMap.get(templatesForBackOfficeStartsStatusesMap.get(oppty.Starts_Status__c)).Id);
                        }
                        message.setTargetObjectId(oppty.OwnerId);
                        message.setWhatId(oppty.Id);
                        message.setToAddresses(emailAddressesList);
                        message.setSaveAsActivity(false);
                        message.setCharset('UTF8');
                        allmessages.add(message);
                        opportunityForTasksList.add(oppty);
                    }
                }
            }
            List<Messaging.SendEmailResult> resultsList = new List<Messaging.SendEmailResult>();
            if (! allmessages.isEmpty()) {
                resultsList = Messaging.sendEmail(allmessages);
                isSendToBackOffice = true;
            }
            logBackOfficeEmails(resultsList, opportunityForTasksList);
        }
    }


    private static List<Messaging.Emailfileattachment> setFileAttachmentToEmail(Map<String, Attachment> oppIdToAttachmentMap, String oppId) {
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();

        if ( ! oppIdToAttachmentMap.isEmpty() && oppIdToAttachmentMap.get(oppId) != null) {
            efa.setFileName(oppIdToAttachmentMap.get(oppId).Name);
            efa.setBody(oppIdToAttachmentMap.get(oppId).Body);
            efa.setContentType(oppIdToAttachmentMap.get(oppId).ContentType);
            fileAttachments.add(efa);
        }

        return fileAttachments;
    }


    private static Map<String, Attachment> getAttachmentForCarnet (Map<Id, Opportunity> oldMap, Map<String, Opportunity> opptiesWithChangedStartsStatusMap) {
        Map<String, Attachment> oppIdToAttachmentMap = new Map<String, Attachment>();
        Set<String> oppIdsSet = new Set<String>();
        for (Opportunity opp : opptiesWithChangedStartsStatusMap.values()) {
            if (opp.StageName != oldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won') {
                oppIdsSet.add(opp.Id);
            }
        }

        if ( ! oppIdsSet.isEmpty()) {
            Map<String, List<OpportunityLineItem>> oppIdToLineItemMap = new Map<String, List<OpportunityLineItem>>();
            Set<String> lotosOppIdSet = new Set<String>();
            List<OpportunityLineItem> oppLineItemList = [SELECT Product2.Family, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :oppIdsSet];
            if ( ! oppLineItemList.isEmpty()) {
                for (OpportunityLineItem oppLineItem : oppLineItemList) {
                    if ( ! oppIdToLineItemMap.containsKey(oppLineItem.OpportunityId)) {
                        oppIdToLineItemMap.put(oppLineItem.OpportunityId, new List<OpportunityLineItem>());
                    }
                    oppIdToLineItemMap.get(oppLineItem.OpportunityId).add(oppLineItem);
                }

                for (String oppId : oppIdToLineItemMap.keySet()) {
                    for (OpportunityLineItem item : oppIdToLineItemMap.get(oppId)) {
                        if (item.Product2.Family == 'Carnet') {
                            lotosOppIdSet.add(item.OpportunityId);
                        }
                    }
                }
            }

            if ( ! lotosOppIdSet.isEmpty()) {
                String carnetAttachmentName = '%Carnet_podsumowanie_zamowienia%';
                List<Attachment> cartnetAttachmentsList = [SELECT Name, Body, ContentType, ParentId FROM Attachment WHERE ParentId IN :lotosOppIdSet AND Name LIKE :carnetAttachmentName ORDER BY CreatedDate ASC];
                if ( ! cartnetAttachmentsList.isEmpty() ) {
                    for (Attachment attach : cartnetAttachmentsList) {
                        if (oppIdToLineItemMap.containsKey(attach.ParentId)) {
                            oppIdToAttachmentMap.put(attach.ParentId, attach);
                        }
                    }
                }
            }
        }

        return oppIdToAttachmentMap;
    }


    /*******************************************************************************
    *  Name            : logBackOfficeEmails(List<Messaging.SendEmailResult> resultsList, List<Opportunity> opportunityForTasksList)
    *  Summary         : create tasks on Opportunity in case of sending emails
    *  CreatedDate     : 01/03/2018
    *  ModifiedDate    : 01/03/2018
    *  Parameters      : List<Messaging.SendEmailResult> resultsList - results of sending emails, List<Opportunity> opportunityForTasksList - opportunities
    *  Returns         : void
    ******************************************************************************/
    public static void logBackOfficeEmails(List<Messaging.SendEmailResult> resultsList, List<Opportunity> opportunityForTasksList) {
        Boolean errors = false;
        List<Task> tasksList = new List<Task>();
        String emailBody = '<br/>';
        for (Integer i = 0; i < resultsList.size(); i++) {
            if (opportunityForTasksList.get(i).StageName == 'Closed Won') {
                Task task = new Task(
                        WhatId = opportunityForTasksList.get(i).Id,
                        ActivityDate = Date.today(),
                        Type = 'E-mail',
                        Status = 'Completed');
                if (resultsList.get(i).isSuccess() == true) {
                    task.Subject = 'SENT: Email about new Customer was sent to Back Office';
                } else {
                    errors = true;
                    emailBody += '<br/>Opportunity Id: ' + opportunityForTasksList.get(i).Id + '.<br/> Errors:';
                    String taskBody = 'Errors: ';
                    for (Messaging.SendEmailError error : resultsList.get(i).getErrors()) {
                        emailBody += '<br/>- ' + error.Message;
                        taskBody += '\n- ' + error.Message;
                    }

                    emailBody += '<br/>';
                    task.Subject = 'NOT SENT: Email about new Customer was not sent to Back Office';
                    task.Description = taskBody;
                }

                tasksList.add(task);
            }
        }

        insert tasksList;

        if (errors) {
            ExceptionLogger.sendException(emailBody, '');
        }
    }


    /*******************************************************************************
    *  Name            : sendEmailToStartsOpptyOwner(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : sending email to opportunity owner for Starts Processes
    *  CreatedDate     : 01/08/2017
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendEmailToStartsOpptyOwner(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<String> accountIdsSet = new Set<String>();
        List<Opportunity> finalOpportinitiesList = new List<Opportunity>();
        for (Opportunity opp : newMap.values()) {
            if (opp.Starts_Status__c != oldMap.get(opp.Id).Starts_Status__c) {
                if (opp.Starts_Status__c == '0.5 Missing information' || opp.Starts_Status__c == '0.4 Registration in GFN: Winback' || opp.Starts_Status__c == '3.4 Volume Check 1: Winback' ||
                        opp.Starts_Status__c == '4.4 Volume Check 2: Winback' || opp.Starts_Status__c == '5.4 Final Check: Winback') {
                    finalOpportinitiesList.add(opp);
                    accountIdsSet.add(opp.AccountId);
                }
            }
        }

        if (!finalOpportinitiesList.isEmpty()) {
            Map<Id, Account> accountsMap = new Map<Id, Account>([
                    SELECT BillingCountry
                    FROM Account
                    WHERE Id IN :accountIdsSet
                    LIMIT 1
            ]);

            List<EmailTemplate> templatesList = [
                    SELECT Id, Name, Body, HtmlValue, Subject, DeveloperName
                    FROM EmailTemplate
                    WHERE DeveloperName IN :templatesForOwnerStartsStatusesMap.values()
                    LIMIT 10
            ];

            Map<String, EmailTemplate> templatesMap = new Map<String, EmailTemplate>();
            for (EmailTemplate template : templatesList) {
                templatesMap.put(template.DeveloperName, template);
            }

            Map<String, BackOffice_Notifications__c> backOfficeNotifyCustomSettingMap = BackOffice_Notifications__c.getAll();
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            for (Opportunity oppty : finalOpportinitiesList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(templatesMap.get(templatesForOwnerStartsStatusesMap.get(oppty.Starts_Status__c)).Id);
                if (oppty.AccountId != null &&
                        accountsMap.get(oppty.AccountId).BillingCountry != null &&
                        backOfficeNotifyCustomSettingMap.get(accountsMap.get(oppty.AccountId).BillingCountry).Email__c != null) {
                    mail.setReplyTo(backOfficeNotifyCustomSettingMap.get(accountsMap.get(oppty.AccountId).BillingCountry).Email__c);
                }
                mail.setTargetObjectId(oppty.OwnerId);
                mail.setWhatId(oppty.Id);
                mail.setSaveAsActivity(false);
                mail.setCharset('UTF-8');
                allmsg.add(mail);
            }
            if (!Test.isRunningTest() && !allmsg.isEmpty()) {
                Messaging.sendEmail(allmsg);
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateVouchersSentField ()
    *  Summary         : after Opportunity StageName changes to "Closed Won" of update Vouchers Sent Field (increased by 1) in partner Account
    *  CreatedDate     : 17/01/2017
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap  - old and new opportunity values
    *  Returns         : void
    ******************************************************************************/
    public static void updateVouchersSentField(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> oppClosedWonIdSet = new Set<Id>();
        for (Opportunity opp : newMap.values()) {
            if (oldMap.get(opp.Id).StageName != opp.StageName &&
                    opp.StageName == 'Closed Won') {
                oppClosedWonIdSet.add(opp.Id);
            }
        }

        if (!oppClosedWonIdSet.isEmpty()) {
            List<Lead> convertedLeadsList = [
                    SELECT Id, ConvertedOpportunityId, Partner__c
                    FROM Lead
                    WHERE ConvertedOpportunityId IN :oppClosedWonIdSet AND
                    Partner__r.RecordType.Name = 'Retailer'
                    LIMIT 50000
            ];

            Set<Id> partnerAccIdSet = new Set<Id>();
            for (Lead l : convertedLeadsList) {
                if (l.Partner__c != null) {
                    partnerAccIdSet.add(l.Partner__c);
                }
            }

            if (!partnerAccIdSet.isEmpty()) {
                Map<Id, Account> allPartnerAccMap = new Map<Id, Account>([
                        SELECT Id, Vouchers_Sent__c
                        FROM Account
                        WHERE Id IN :partnerAccIdSet
                        LIMIT 50000
                ]);

                List<Account> accListToUpdateList = new List<Account>();
                for (Lead le : convertedLeadsList) {
                    if (allPartnerAccMap.get(le.Partner__c).Vouchers_Sent__c == null) {
                        allPartnerAccMap.get(le.Partner__c).Vouchers_Sent__c = 1;
                        accListToUpdateList.add(allPartnerAccMap.get(le.Partner__c));
                    } else {
                        allPartnerAccMap.get(le.Partner__c).Vouchers_Sent__c += 1;
                        accListToUpdateList.add(allPartnerAccMap.get(le.Partner__c));
                    }
                }
                update accListToUpdateList;
            }
        }
    }


    /*******************************************************************************
    *  Name            : createWelcomeEmailTask(Opportunity newOpp)
    *  Summary         : creating Welcome Email Task
    *  CreatedDate     : 27/02/2017
    *  Parameters      : Opportunity newOpp
    *  Returns         : task (newTask)
    ******************************************************************************/
    public static Task createWelcomeEmailTask(Opportunity newOpp) {
        Task newTask = new Task(
                ActivityDate = Date.today(),
                Subject = 'Email: Welcome Email Sent',
                WhatId = newOpp.Id,
                Type = 'E-mail',
                Status = 'Completed');

        return newTask;
    }


    /*******************************************************************************
    *  Name            : sendToFleetmatics(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : send email to addresses from custom setting when fleetmatics lead is closed and won
    *  CreatedDate     : 12/06/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old opportunity values, Map<Id, Opportunity> newOpportunitiesMap - new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void sendToFleetmatics(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.StageName != oldOpportunitiesMap.get(opportunity.Id).StageName && opportunity.StageName == 'Closed Won' &&
                    (opportunity.LeadSource == 'Fleetmatics' || opportunity.LeadSource == 'Fleetmatics_new')) {
                Map<String, Fleetmatics_Notifications__c> recipientsEmailsMap = Fleetmatics_Notifications__c.getAll();
                List<String> toAddresses = new List<String>();
                for (String recipientName : recipientsEmailsMap.keySet()) {
                    if (recipientsEmailsMap.get(recipientName).Active__c == true) {
                        toAddresses.add(recipientsEmailsMap.get(recipientName).Email__c);
                    }
                }

                List<Messaging.Email> mailsList = new List<Messaging.Email>();
                flmtMail = new Messaging.SingleEmailMessage();
                flmtMail.setToAddresses(toAddresses);
                flmtMail.setSenderDisplayName('SFDC');
                flmtMail.setSubject('Fleetmatics Form');
                flmtMail.setBccSender(false);
                flmtMail.setUseSignature(false);
                flmtMail.setSaveAsActivity(false);
                flmtMail.setHtmlBody('Opportunity Stage Name is changed to Closed Won ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id);
                mailsList.add(flmtMail);
                Messaging.sendEmail(mailsList);
            }
        }
    }


    /*******************************************************************************
    *  Name            : changeToClosedWonAfterPendingSepa(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportuinty> newOpportunitiesMap)
    *  Summary         : change opportunity stage name from Pending Sales - SEPA Confirmation(exposed by Credit Factory) to Closed Won
    *  CreatedDate     : 29/09/2017
    *  ModifiedDate    : 29/06/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values, Map<Id, Opportuinty> newOpportunitiesMap - new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void changeToClosedWonAfterPendingSepa(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        Set<Id> opportunitiesToCheckSEPAIdsSet = new Set<Id>();
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.StageName == 'Pending Sales - SEPA Confirmation' && opportunity.SEPA_Request_Approved__c != true && opportunity.Zahlungsart__c == 'Lastschrift' &&
                    oldOpportunitiesMap.get(opportunity.Id).Einwilligung_Lastschriftverfahren__c == false && opportunity.Einwilligung_Lastschriftverfahren__c == true) {
                opportunitiesToCheckSEPAIdsSet.add(opportunity.Id);
            }
        }

        Map<Id, List<Attachment>> opportunityToAttachmentsMap = new Map<Id, List<Attachment>>();
        if (!opportunitiesToCheckSEPAIdsSet.isEmpty()) {
            List<Attachment> attachmentsList = [
                    SELECT ParentId
                    FROM Attachment
                    WHERE ParentId IN :opportunitiesToCheckSEPAIdsSet AND Name LIKE '%sepa%'
            ];
            for (Attachment attachment : attachmentsList) {
                if (!opportunityToAttachmentsMap.containsKey(attachment.ParentId)) {
                    opportunityToAttachmentsMap.put(attachment.ParentId, new List<Attachment>());
                }

                opportunityToAttachmentsMap.get(attachment.ParentId).add(attachment);
            }
        }

        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if ((opportunity.Send_SEPA_approval_link__c == true && oldOpportunitiesMap.get(opportunity.Id).SEPA_Request_Approved__c == false &&
                    opportunity.SEPA_Request_Approved__c == true || oldOpportunitiesMap.get(opportunity.Id).Einwilligung_Lastschriftverfahren__c == false &&
                    opportunity.Einwilligung_Lastschriftverfahren__c == true && (opportunity.SEPA_Request_Approved__c != true && opportunityToAttachmentsMap.get(opportunity.Id) != null ||
                    opportunity.SEPA_Request_Approved__c == true)) && opportunity.StageName == 'Pending Sales - SEPA Confirmation' && opportunity.Zahlungsart__c == 'Lastschrift') {
                opportunity.StageName = 'Closed Won';
                opportunity.CF_Stage__c = 'Auto CW';
                opportunity.Closed_Won_by_CF__c = true;
            } else if (opportunity.Zahlungsart__c == 'Lastschrift' && opportunity.SEPA_Request_Approved__c != true &&
                    oldOpportunitiesMap.get(opportunity.Id).Einwilligung_Lastschriftverfahren__c == false && opportunity.Einwilligung_Lastschriftverfahren__c == true &&
                    opportunity.StageName == 'Pending Sales - SEPA Confirmation' &&
                    opportunityToAttachmentsMap.get(opportunity.Id) == null) {
                opportunity.addError('Please attach SEPA form to the Opportunity.');
            }
        }
    }

    public static void opportunityBeforeUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        for (Opportunity opportunity : newMap.values()) {
            updateLastOwnerDate(oldMap.get(opportunity.Id), opportunity);
            maketouppercase(opportunity);
            updatePaymentMethodSEPAApproved(oldMap.get(opportunity.Id), opportunity);
            updateStartsPaymentMethodSEPAApproved(oldMap.get(opportunity.Id), opportunity);
            updateCFStageClosedWon(oldMap.get(opportunity.Id), opportunity);
            closeSignedOpportunities(oldMap.get(opportunity.Id), opportunity);
        }
    }


    /*******************************************************************************
    *  Name            : updatePaymentMethodSEPAApproved(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : update payment method when SEPA request approved
    *  CreatedDate     : 19/08/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values, Map<Id, Opportuinty> newOpportunitiesMap - new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void updatePaymentMethodSEPAApproved(Opportunity oldOpportunity, Opportunity newOpportunity) {
        if (newOpportunity.StageName != 'Closed Won' && newOpportunity.Send_SEPA_approval_link__c == true && oldOpportunity.SEPA_Request_Approved__c == false &&
                newOpportunity.SEPA_Request_Approved__c == true) {
            newOpportunity.Zahlungsart__c = 'Lastschrift';
        }
    }


    /*******************************************************************************
    *  Name            : updateStartsPaymentMethodSEPAApproved(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : update Starts: Payment method when SEPA request approved
    *  CreatedDate     : 14/08/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values, Map<Id, Opportuinty> newOpportunitiesMap - new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void updateStartsPaymentMethodSEPAApproved(Opportunity oldOpportunity, Opportunity newOpportunity) {
        if (newOpportunity.StageName == 'Closed Won' && newOpportunity.Send_SEPA_approval_link__c == true && oldOpportunity.SEPA_Request_Approved__c == false &&
                newOpportunity.SEPA_Request_Approved__c == true) {
            newOpportunity.Starts_Payment_method__c = 'Direct debit';
        }
    }


    /*******************************************************************************
    *  Name            : updateStartsPaymentMethodSEPAApproved(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList)
    *  Summary         : set CF Stage to Auto CW when Stage is set to Closed Won
    *  CreatedDate     : 30/01/2018
    *  ModifiedDate    : 12/12/2018
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values Map, List<Opportunity> newOpportunitiesList - new Opportunities values List
    *  Returns         : void
    ******************************************************************************/
    public static void updateCFStageClosedWon(Opportunity oldOpportunity, Opportunity newOpportunity) {
        if (newOpportunity.StageName == 'Closed Won') {
            if (oldOpportunity.StageName == 'Pending Credit - Contract Check' ||
                newOpportunity.Credit_Stage__c == 'Pending Credit - Contract Check') {
            newOpportunity.CF_Stage__c = 'Auto CW';
            newOpportunity.Closed_Won_by_CF__c = true;
            } else if (oldOpportunity.StageName == 'Pending Credit - E2E Check') {
                newOpportunity.E2E_Finish_Details__c = 'Order Completed';
                newOpportunity.E2E_Step__c = 'Congratulations';
                newOpportunity.CF_Stage__c = 'Manual scoring';
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateStartsFieldsAfterClosedWon(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : change starts fields when opportunity is closed (Before update)
    *  CreatedDate     : 2/09/2017
    *  ModifiedDate    : 2/09/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values map, Map<Id, Opportunity> newOpportunitiesMap - new Opportunities values map
    *  Returns         : void
    ******************************************************************************/
    public static void updateStartsFieldsAfterClosedWon(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        Map<Id, Opportunity> opportunitiesToUpdateMap = new Map<Id, Opportunity>();
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (oldOpportunitiesMap.get(opportunity.Id).StageName != opportunity.StageName && opportunity.StageName == 'Closed Won' && !opportunity.E2E__c && !opportunity.E2E_2__c &&
                    (oppRecordTypes.get('Euroshell').getRecordTypeId() == opportunity.RecordTypeId ||
                            oppRecordTypes.get('Lotos').getRecordTypeId() == opportunity.RecordTypeId)) {
                opportunitiesToUpdateMap.put(opportunity.Id, opportunity);
            }
        }

        if (!opportunitiesToUpdateMap.isEmpty()) {
            List<OpportunityFieldHistory> fieldHistories = [
                    SELECT Field, OpportunityId, NewValue, CreatedDate
                    FROM OpportunityFieldHistory
                    WHERE Field = 'Starts_Status__c' AND
                    OpportunityId IN :opportunitiesToUpdateMap.keySet()
                    ORDER BY CreatedDate DESC
                    LIMIT 30000
            ];
            Map<Id, List<OpportunityFieldHistory>> opportunitiesToFieldHistoriesMap = new Map<Id, List<OpportunityFieldHistory>>();
            for (OpportunityFieldHistory history : fieldHistories) {
                if (!opportunitiesToFieldHistoriesMap.containsKey(history.OpportunityId)) {
                    opportunitiesToFieldHistoriesMap.put(history.OpportunityId, new List<OpportunityFieldHistory>());
                }

                opportunitiesToFieldHistoriesMap.get(history.OpportunityId).add(history);
            }

            List<BusinessHours> fleetcorBH = [
                    SELECT Name
                    FROM BusinessHours
                    WHERE Name = 'CZ' OR Name = 'SK' OR Name = 'HU' OR Name = 'PL' OR Name = 'Default'
                    LIMIT 10
            ];
            Map<String, BusinessHours> businessHoursMap = new Map<String, BusinessHours>();
            for (BusinessHours businessHours : fleetcorBH) {
                businessHoursMap.put(businessHours.Name, businessHours);
            }

            for (Opportunity opportunity : opportunitiesToUpdateMap.values()) {
                Datetime dateOfstatusChange;
                if (opportunitiesToFieldHistoriesMap.containsKey(opportunity.Id) && !opportunitiesToFieldHistoriesMap.get(opportunity.Id).isEmpty()) {
                    dateOfstatusChange = opportunitiesToFieldHistoriesMap.get(opportunity.Id).get(0).CreatedDate;
                } else {
                    dateOfstatusChange = opportunity.CloseDate;
                }

                String businessHoursId;
                if (opportunity.Land_Opp__c == 'Czech Republic') {
                    businessHoursId = businessHoursMap.get('CZ').Id;
                } else if (opportunity.Land_Opp__c == 'Slovakia') {
                    businessHoursId = businessHoursMap.get('SK').Id;
                } else if (opportunity.Land_Opp__c == 'Hungary') {
                    businessHoursId = businessHoursMap.get('HU').Id;
                } else if (opportunity.Land_Opp__c == 'Poland') {
                    businessHoursId = businessHoursMap.get('PL').Id;
                } else {
                    businessHoursId = businessHoursMap.get('Default').Id;
                }

                Datetime dueDateTime = BusinessHours.addGmt(businessHoursId, dateOfstatusChange, 32400001);
                Date dueDate = Date.newinstance(dueDateTime.year(), dueDateTime.month(), dueDateTime.day());
                opportunity.Starts_Schedule__c = dueDate;
                opportunity.Starts_Status_Delay__c = false;
                opportunity.Starts_Number_of_Cards_Target__c = opportunity.Anzahl_der_Karten__c;
                opportunity.Starts_Status__c = '0. Request received';
            }
        }
    }


    /*******************************************************************************
    *  Name            : startsSLAcalculate()
    *  Summary         : update starts schedule value when starts status is changed (before update)
    *  CreatedDate     : 16/10/2017
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : -
    ******************************************************************************/
    public static void startsSLAcalculate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Map<String, Opportunity> opportunitiesToUpdateMap = new Map<String, Opportunity>();
        for (Opportunity opportunity : newMap.values()) {
            if (oldMap.get(opportunity.Id).Starts_Status__c != opportunity.Starts_Status__c &&
                    startsSLAvaluesMap.containsKey(opportunity.Starts_Status__c) &&
                    opportunity.StageName == 'Closed Won') {
                opportunitiesToUpdateMap.put(opportunity.Id, opportunity);
            }
        }

        if (!opportunitiesToUpdateMap.isEmpty()) {
            List<BusinessHours> bhList = [
                    SELECT Id, Name
                    FROM BusinessHours
                    WHERE IsActive = true
                    LIMIT 5
            ];

            Map<String, BusinessHours> fleetcorBHmap = new Map<String, BusinessHours>();
            for (BusinessHours bh : bhList) {
                if (bh.Name == 'CZ') {
                    fleetcorBHmap.put('Czech republic', bh);
                } else if (bh.Name == 'SK') {
                    fleetcorBHmap.put('Slovakia', bh);
                } else if (bh.Name == 'HU') {
                    fleetcorBHmap.put('Hungary', bh);
                } else if (bh.Name == 'PL') {
                    fleetcorBHmap.put('Poland', bh);
                } else if (bh.Name == 'Default') {
                    fleetcorBHmap.put('Default', bh);
                }
            }

            List<Task> tasksToInsertList = new List<Task>();
            for (Opportunity oppty : opportunitiesToUpdateMap.values()) {
                //calculating SLA
                Datetime dueDate;
                if (fleetcorBHmap.containsKey(oppty.Land_Opp__c)) {
                    dueDate = BusinessHours.addGmt(fleetcorBHmap.get(oppty.Land_Opp__c).Id, Datetime.now(), startsSLAvaluesMap.get(oppty.Starts_Status__c) * 32400000 + 1);
                } else if (fleetcorBHmap.containsKey('Default')) {
                    dueDate = BusinessHours.addGmt(fleetcorBHmap.get('Default').Id, Datetime.now(), startsSLAvaluesMap.get(oppty.Starts_Status__c) * 32400000 + 1);
                } else {
                    dueDate = Datetime.now();
                }

                Date dueDateFinal = Date.newinstance(dueDate.year(), dueDate.month(), dueDate.day());
                oppty.Starts_Schedule__c = dueDateFinal;
                oppty.Starts_Overdue_days__c = 0;
                oppty.Starts_Status_Delay__c = false;
            }
        }
    }


    /*******************************************************************************
    *  Name            : doCreateTaskMissingInformationToStartsProcess (Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : creating task if Starts Status = 0.5 Missing information
    *  CreatedDate     : 19/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void doCreateTaskMissingInformationToStartsProcess(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Opportunity> opportunitiesList = new List<Opportunity>();
        for (Opportunity opportunity : newMap.values()) {
            if (oldMap.get(opportunity.Id).Starts_Status__c != opportunity.Starts_Status__c &&
                    startsSLAvaluesMap.containsKey(opportunity.Starts_Status__c) &&
                    opportunity.StageName == 'Closed Won') {
                opportunitiesList.add(opportunity);
            }
        }
        List<Task> tasksToInsertList = new List<Task>();
        for (Opportunity oppty : opportunitiesList) {
            //creating task if Starts Status = 0.5 Missing information
            if (oppty.Starts_Status__c == '0.5 Missing information') {
                Task newTask = new Task(
                        ActivityDate = Date.today(),
                        IsReminderSet = true,
                        OwnerId = oppty.OwnerId,
                        Priority = 'High',
                        Status = 'Not Started',
                        Subject = 'Back Office Missing Information',
                        Type = 'Other',
                        WhatId = oppty.Id);

                tasksToInsertList.add(newTask);
            }
            if (!tasksToInsertList.isEmpty()) {
                insert tasksToInsertList;
            }
        }
    }


    /*******************************************************************************
    *  Name            : insertLastOwnerChangeDateRUS()
    *  Summary         : insert opportunity, set Last_Date_Change_Owner_RUS__c
    *  CreatedDate     : 20.11.2017
    *  Parameters      : List<Opportunity> newOpps
    *  Returns         : -
    ******************************************************************************/
    public static void insertLastOwnerChangeDateRUS(List<Opportunity> newOpps) {
        Map<Id, User> russianSalesManagerIds = new Map <Id, User> ([SELECT Id FROM User WHERE Profile.Name = 'Russian Sales Manager']);
        List <Opportunity> oppsToFinishNaumenCase = new List <Opportunity> ();

        for (Opportunity opportunity : newOpps) {
            if (oppRecordTypes.get('Russian_Sales').getRecordTypeId() == opportunity.RecordTypeId) {
                opportunity.Last_Owner_Change_Date_RUS__c = Datetime.now();

                if (russianSalesManagerIds.containsKey(opportunity.OwnerId)) { // if owner was changed to Russian Sales Manager then finish naumen case to stop calls to ccspeedup operators
                    if (opportunity.Naumen_Autocall_Case_UUID__c != null && opportunity.StageName == 'Prequal' && opportunity.Naumen_Case_Status__c == 'Created') {
                        opportunity.Naumen_Case_Status__c = 'Finished';
                        opportunity.Naumen_Case_Status_ModifiedTime__c = system.now();
                        oppsToFinishNaumenCase.add(opportunity);
                    }
                }
            }
        }
        if (!oppsToFinishNaumenCase.isEmpty()) {
            Naumen_Callouts.sendrequest_updateCasesList_setFinished_NotDone(oppsToFinishNaumenCase);
        }
    }
    /*******************************************************************************
    *  Name            : finishNaumenCasesForOpportunitiesList()
    *  Summary         : finishes Naumen Case linked to the opportunities
    *  CreatedDate     : 24.07.2020
    *  Parameters      : List <Opportunity> opportunities - for which Naumen cases will be finished
    *  Returns         : -
    ******************************************************************************/
    public static void finishNaumenCasesForOpportunitiesList (List <Opportunity> opps) {
        List <Opportunity> oppsToFinishNaumenCase = new List <Opportunity> ();
        for (Opportunity opportunity : opps) {
            if (opportunity.Naumen_Autocall_Case_UUID__c != null) oppsToFinishNaumenCase.add(opportunity);
        }
        if (!oppsToFinishNaumenCase.isEmpty()) {
            Naumen_Callouts.sendrequest_updateCasesList_setFinished_NotDone(oppsToFinishNaumenCase);
        }
    }

    /*******************************************************************************
    *  Name            : updateLastOwnerChangeDateRUS()
    *  Summary         : update opportunity, set Last_Date_Change_Owner_RUS__c
    *  CreatedDate     : 20.11.2017
    *  Parameters      : Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap
    *  Returns         : -
    ******************************************************************************/
    public static void updateLastOwnerChangeDateRUS(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap) {
        for (Opportunity opportunity : newOppMap.values()) {
            if (oppRecordTypes.get('Russian_Sales').getRecordTypeId() == opportunity.RecordTypeId &&
                    opportunity.OwnerId != oldOppMap.get(opportunity.Id).OwnerId) {
                opportunity.Last_Owner_Change_Date_RUS__c = Datetime.now();
            }
        }
    }

    /*******************************************************************************
     *  Name            : sendRequestForChangeOwnerRu()
     *  Summary         : send request for change owner of Opportunity(Account) to owner.Manager
     *  CreatedDate     : 20.11.2017
     *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap
     *  Returns         : void
     ******************************************************************************/
    public static void sendRequestForChangeOwnerRu(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        Boolean isExecute = false;
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (oppRecordTypes.get('Russian_Sales').getRecordTypeId() == opportunity.RecordTypeId) {
                isExecute = true;
                break;
            }
        }
        if (isExecute) {
            List<Profile> profileRussianSalesManagerList = [SELECT id FROM profile WHERE name IN ('Russian Sales Manager', 'Russian Inbound', 'Russian Telesales', 'Russian Field Sales', 'Russian KAM')];
            Set<Id> profileRussianSalesManagerSet = new Set<Id>();
            for (Profile profile : profileRussianSalesManagerList) {
                profileRussianSalesManagerSet.add(profile.Id);
            }
            if (profileRussianSalesManagerSet.contains(UserInfo.getProfileId())) {
                Map<Id, User> ownersOfOppportunitiesMap = new Map<Id, User>();
                Set<id> ownersOfOpportunitiesSet = new Set<Id>();
                Set<id> accountIds = new Set<Id>();
                for (Opportunity newOpportunity : newOpportunitiesMap.values()) {
                    ownersOfOpportunitiesSet.add(newOpportunity.ownerid);
                    ownersOfOpportunitiesSet.add(oldOpportunitiesMap.get(newOpportunity.Id).ownerid);
                    accountIds.add(newOpportunity.AccountId);
                }
                //VS SF-265
                Map<Id, Account> accountsMap = new Map<Id, Account>([
                        SELECT Id, Name
                        FROM Account
                        WHERE Id IN :AccountIds]);

                List<User> ownersOfOpportunitiesList = [SELECT id, name, ManagerId FROM User WHERE id = :ownersOfOpportunitiesSet];
                for (User userOwner : ownersOfOpportunitiesList) {
                    ownersOfOppportunitiesMap.put(userOwner.id, userOwner);
                }
                List<Messaging.Email> emails = new List<Messaging.Email>();
                for (Opportunity newOpportunity : newOpportunitiesMap.values()) {
                    Opportunity oldOpportunity = oldOpportunitiesMap.get(newOpportunity.Id);
                    if (oldOpportunity.OwnerId == UserInfo.getUserId() && oldOpportunity.OwnerId <> newOpportunity.OwnerId &&
                            oppRecordTypes.get('Russian_Sales').getRecordTypeId() == newOpportunity.RecordTypeId){
                        if ((ownersOfOppportunitiesMap.get(oldOpportunity.ownerid) != null) &&
                                (ownersOfOppportunitiesMap.get(newOpportunity.ownerid) != null)) {
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(ownersOfOppportunitiesMap.get(oldOpportunity.ownerid).ManagerId,
                                    'Запрос на изменение владельца возможности/организации',
                                    '<p>Поступил запрос на изменение владельца записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + newOpportunity.Id + '" > ' + newOpportunity.Id + ' </a> </p>' +
                                            '<p>Инн : ' + oldOpportunity.INN_Opp__c + '</p>' +
                                            '<p>Наименование Компании : ' + accountsMap.get(oldOpportunity.AccountId).Name + '</p>' +
                                            '<p>Текущий  владелец     : ' + ownersOfOppportunitiesMap.get(oldOpportunity.ownerid).Name + '</p>' +
                                            '<p>Изменить владельца на : ' + ownersOfOppportunitiesMap.get(newOpportunity.ownerid).Name + '</p>' +
                                            '<p>Для того чтобы изменить владельца записи, нажмите на кнопку "Подтвердить"</p>' +
                                            '<table border="0"> <tr> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=002&Answer=yes&idRecord=' + newOpportunity.Id + '&idNewOwner=' + ownersOfOppportunitiesMap.get(newOpportunity.ownerid).id + '"> Подтвердить </a> </th> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=002&Answer=no&idRecord=' + newOpportunity.Id + '&idNewOwner=' + ownersOfOppportunitiesMap.get(newOpportunity.ownerid).id + '"> Отклонить </a> </th> ' +
                                            '</tr> </table> '));
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(ownersOfOppportunitiesMap.get(oldOpportunity.ownerid).id,
                                    'Запрос принят',
                                    '<p>Ваш запрос на передачу записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + oldOpportunity.id + '" > ' + oldOpportunity.id + ' </a> - отправлен вашему Тим Лидеру(Менеджеру)</p>' +
                                            '<p>Инн : ' + oldOpportunity.INN_Opp__c + '</p>' +
                                            '<p>Наименование Компании : ' + accountsMap.get(oldOpportunity.AccountId).Name + '</p>' +
                                            '<p>Пожалуйста ожидайте ответа</p>'));
                            newOpportunity.Ownerid = oldOpportunity.OwnerId;
                        }
                    }
                }
                if (emails.size() != 0) {
                    Messaging.sendEmail(emails);
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : sendRequestForCreateSecondOpportunity()
    *  Summary         : send request for create second opportunity to owner.Manager
    *  CreatedDate     : 20.11.2017
    *  Parameters      : List<Opportunity>
    *  Returns         : void
    ******************************************************************************/
    public static void sendRequestForCreateSecondOpportunity(List<Opportunity> newOpportunitiesList) {
        Boolean isExecute = false;
        for (Opportunity opportunity : newOpportunitiesList) {
            if (oppRecordTypes.get('Russian_Sales').getRecordTypeId() == opportunity.RecordTypeId) {
                isExecute = true;
                break;
            }
        }
        if(isExecute){
            List<User> currentUser = [
                    SELECT id, name, ManagerId, ProfileId
                    FROM User
                    WHERE id = :UserInfo.getUserId() AND Profile.Name = 'Russian Sales Manager'
            ];
            if (currentUser.size() == 1) {
                Set<id> AccountIds = new Set<Id>();
                for (Opportunity opportunity : newOpportunitiesList) {
                    AccountIds.add(opportunity.AccountId);
                }
                //VS SF-265
                Map<Id, Account> accountsMap = new Map<Id, Account>([
                        SELECT Id, Name
                        FROM Account
                        WHERE Id IN :AccountIds]);

                Map<String, Integer> countOpportunityInAccountMap = new Map<String, Integer>();
                for (AggregateResult aggregateResult : [
                        SELECT AccountId,count(id) num
                        FROM Opportunity
                        WHERE AccountId = :AccountIds
                        GROUP BY AccountId
                ]) {
                    countOpportunityInAccountMap.put(String.valueOf(aggregateResult.get('AccountId')), Integer.valueOf(aggregateResult.get('num')));
                }
                List<Messaging.Email> emails = new List<Messaging.Email>();
                for (Opportunity opportunity : newOpportunitiesList) {
                    if (oppRecordTypes.get('Russian_Sales').getRecordTypeId() == opportunity.RecordTypeId) {
                        if (opportunity.id == null) {
                            if (countOpportunityInAccountMap.get(String.valueOf(opportunity.AccountId)) > 0) {
                                opportunity.ownerid = currentUser.get(0).ManagerId;
                            }
                        } else {
                            if (countOpportunityInAccountMap.get(String.valueOf(opportunity.AccountId)) > 1) {
                                emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).id,
                                        'Запрос принят',
                                        '<p>Запрос на создание новой(очередной) возможности "' + opportunity.name + '", отправлен вашему Тим Лидеру(Менеджеру)</p>' +
                                                '<p>Инн : ' + opportunity.INN_Opp__c + '</p>' +
                                                '<p>Наименование Компании : ' + accountsMap.get(opportunity.AccountId).Name + '</p>' +
                                                '<p>Пожалуйста ожидайте ответа</p>'));
                                emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).ManagerId,
                                        'Запрос на создание второй возможности',
                                        '<p>Поступил запрос от ' + currentUser.get(0).Name + ' на создание новой(очередной) возможности <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '" > ' + opportunity.id + ' </a> </p>' +
                                                '<p>Инн : ' + opportunity.INN_Opp__c + '</p>' +
                                                '<p>Наименование Компании : ' + accountsMap.get(opportunity.AccountId).Name + '</p>' +
                                                '<p>Для того чтобы подтвердить создание возможности, нажмите на кнопку "Подтвердить"</p>' +
                                                '<table border="0"> <tr> ' +
                                                '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=003&Answer=yes&idRecord=' + opportunity.Id + '&idNewOwner=' + currentUser.get(0).id + '"> Подтвердить </a> </th> ' +
                                                '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=003&Answer=no&idRecord=' + opportunity.Id + '&idNewOwner=' + currentUser.get(0).id + '"> Отклонить </a> </th> ' +
                                                '</tr> </table> '));
                            }
                        }
                    }
                }
                if (emails.size() != 0) {
                    Messaging.sendEmail(emails);
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : sendTotalConsumptionChangeAlert(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : send notification to Teamleaders if Sales Agent updates Total_consumption_l_month__c field 3 and more times in the same Opportunity
    *  CreatedDate     : 20/12/2017
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendTotalConsumptionChangeAlert(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Map<String, String> updatedOpptiesMap = new Map<String, String>();
        List<OpportunityFieldHistory> ofh = new List<OpportunityFieldHistory>();
        for (Opportunity opportunity : newMap.values()) {
            if (oldMap.get(opportunity.Id).Total_consumption_l_month__c != opportunity.Total_consumption_l_month__c) {
                updatedOpptiesMap.put(opportunity.Id, opportunity.OwnerId);
                if (Test.isRunningTest()) {
                    ofh.add(new OpportunityFieldHistory(OpportunityId = opportunity.Id, Field = 'Total_consumption_l_month__c'));
                    ofh.add(new OpportunityFieldHistory(OpportunityId = opportunity.Id, Field = 'Total_consumption_l_month__c'));
                    ofh.add(new OpportunityFieldHistory(OpportunityId = opportunity.Id, Field = 'Total_consumption_l_month__c'));
                }
            }
        }

        if (!updatedOpptiesMap.isEmpty()) {
            if (!Test.isRunningTest()) {
                ofh = [
                        SELECT OpportunityId, Field, OldValue, NewValue, CreatedById
                        FROM OpportunityFieldHistory
                        WHERE (Field = 'Total_consumption_l_month__c' OR Field = 'Owner') AND
                        OpportunityId IN :updatedOpptiesMap.keySet()
                        ORDER BY CreatedDate DESC
                        LIMIT 50000
                ];
            }

            Map<String, List<OpportunityFieldHistory>> numberOpptyFieldHistoryMap = new Map<String, List<OpportunityFieldHistory>>();
            for (OpportunityFieldHistory fieldHistory : ofh) {
                if (fieldHistory.Field == 'Owner') break;
                if (!numberOpptyFieldHistoryMap.containsKey(fieldHistory.OpportunityId)) {
                    numberOpptyFieldHistoryMap.put(fieldHistory.OpportunityId, new List<OpportunityFieldHistory>());
                }
                numberOpptyFieldHistoryMap.get(fieldHistory.OpportunityId).add(fieldHistory);
            }

            Map<String, String> opptiesToSendingEmailMapTemp = new Map<String, String>();
            for (String opptyId : numberOpptyFieldHistoryMap.keySet()) {
                Integer numberHistoryLines = numberOpptyFieldHistoryMap.get(opptyId).size();
                Integer lastHistoryLineIndex = 0;
                if (numberHistoryLines != 0) {
                    lastHistoryLineIndex = numberHistoryLines - 1;
                }
                // >= 2 since when last OpportunityFieldHistory is not visible (it working asynchronous: after update trigger and insert field history)
                if (numberOpptyFieldHistoryMap.get(opptyId).get(lastHistoryLineIndex).OldValue == null) {
                    if (numberOpptyFieldHistoryMap.get(opptyId).size() >= 3) {
                        opptiesToSendingEmailMapTemp.put(opptyId, updatedOpptiesMap.get(opptyId));
                    }
                } else {
                    if (numberOpptyFieldHistoryMap.get(opptyId).size() >= 2) {
                        opptiesToSendingEmailMapTemp.put(opptyId, updatedOpptiesMap.get(opptyId));
                    }
                }
            }

            if (!opptiesToSendingEmailMapTemp.isEmpty()) {
                Map<String, User> opptyOwnersMap = new Map<String, User>([
                        SELECT Name, UserRole.ParentRoleId
                        FROM User
                        WHERE Id = :opptiesToSendingEmailMapTemp.values() AND
                        isActive = TRUE AND
                        (UserRole.Name = 'Salesteam Inbound' OR UserRole.Name = 'Salesteam Outbound 1')
                        LIMIT 10000
                ]);

                if (!opptyOwnersMap.isEmpty()) {
                    // [1]. ----- Data preparation -----
                    Map<String, String> parentRoleIdForSaleMap = new Map<String, String>();
                    for (User usr : opptyOwnersMap.values()) {
                        parentRoleIdForSaleMap.put(usr.Id, usr.UserRole.ParentRoleId);
                    }
                    // [1.1]. Generating additional teamleaders set
                    Set<String> additionalUsersSet = new Set<String>{
                            'Aleksandar Ilic'
                    };

                    Map<String, User> teamleadersMap = new Map<String, User>([
                            SELECT Id, Name, UserRoleId, Email
                            FROM User
                            WHERE (UserRoleId IN :parentRoleIdForSaleMap.values() OR Name IN :additionalUsersSet) AND isActive = TRUE
                            LIMIT 10000
                    ]);

                    Map<String, List<String>> teamleadersWithRoleIdMap = new Map<String, List<String>>();
                    for (User teamLead : teamleadersMap.values()) {
                        if (additionalUsersSet.contains(teamLead.Name)) {
                            if (!teamleadersWithRoleIdMap.containsKey('additionalUsers')) {
                                teamleadersWithRoleIdMap.put('additionalUsers', new List<String>());
                            }
                            teamleadersWithRoleIdMap.get('additionalUsers').add(teamLead.Email);
                        } else {
                            if (!teamleadersWithRoleIdMap.containsKey(teamLead.UserRoleId)) {
                                teamleadersWithRoleIdMap.put(teamLead.UserRoleId, new List<String>());
                            }
                            teamleadersWithRoleIdMap.get(teamLead.UserRoleId).add(teamLead.Email);
                        }
                    }

                    // [1.2]. Generating list of Teamleaders with additional users for Sales Rep
                    Map<String, List<String>> userWithHisTeamleadersMap = new Map<String, List<String>>();
                    for (String saleId : parentRoleIdForSaleMap.keySet()) {
                        if (teamleadersWithRoleIdMap.containsKey(parentRoleIdForSaleMap.get(saleId))) {
                            userWithHisTeamleadersMap.put(saleId, new List<String>());
                            userWithHisTeamleadersMap.get(saleId).addAll(teamleadersWithRoleIdMap.get(parentRoleIdForSaleMap.get(saleId)));
                            if (teamleadersWithRoleIdMap.containsKey('additionalUsers')) {
                                userWithHisTeamleadersMap.get(saleId).addAll(teamleadersWithRoleIdMap.get('additionalUsers'));
                            }
                        }
                    }

                    // [1.3]. Generating list of updated Opportunities for Sales Rep
                    Map<String, List<String>> finalOpptiesToSendingEmailMap = new Map<String, List<String>>();
                    for (String opptyId : opptiesToSendingEmailMapTemp.keySet()) {
                        if (userWithHisTeamleadersMap.containsKey(opptiesToSendingEmailMapTemp.get(opptyId))) {
                            finalOpptiesToSendingEmailMap.put(opptiesToSendingEmailMapTemp.get(opptyId), new List<String>());
                        }
                        finalOpptiesToSendingEmailMap.get(opptiesToSendingEmailMapTemp.get(opptyId)).add(opptyId);
                    }

                    // [2]. ----- Sending email notification to teamleaders -----
                    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                    for (String saleId : finalOpptiesToSendingEmailMap.keySet()) {
                        for (String oppId : finalOpptiesToSendingEmailMap.get(saleId)) {
                            String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppId;
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            message.setToAddresses(userWithHisTeamleadersMap.get(saleId));
                            message.setSubject('Fuel consumption change alert');
                            message.setHtmlBody('<p>' + opptyOwnersMap.get(saleId).Name + ' updated Total consumption (l/month)* field in the following Opportunity more than 3 times: <a href="' + fullRecordURL + '">link</a></p>' +
                                    '<p>This is an automatically generated email, please do not respond.</p>');
                            allmsg.add(message);
                        }
                    }
                    if (!Test.isRunningTest()) {
                        Messaging.sendEmail(allmsg);
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : addSubjectsToCloneOpportunity(List<Opportunity> newList)
    *  Summary         : Add Attachment, Contact role and fuel card to clone Opportunity
    *  CreatedDate     : 21/02/2018
    *  ModifiedDate    : 19/07/2019
    *  Parameters      : List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void addSubjectsToCloneOpportunity(List<Opportunity> newList) {
        Map<String, String> oldToNewOpptiesIdMap = new Map<String, String>();
        for (Opportunity oppty : newList) {
            if (oppty.isClone()) {
                oldToNewOpptiesIdMap.put(oppty.getCloneSourceId(), oppty.Id);
            }
        }

        List<Opportunity> oldOppList = [
                SELECT Credit_check_date__c, RecordType.Name, CreatedDate
                FROM Opportunity
                WHERE Id IN :oldToNewOpptiesIdMap.keySet() AND
                RecordType.Name != 'Russian Sales' AND
                RecordType.Name != 'CCS Opportunity Layout'
                LIMIT 50000];

        if ( ! oldOppList.isEmpty() ) {
            for (Opportunity oppty : oldOppList) {
                Integer daysAfterCreditCheck;
                Integer count = 0;
                if (oppty.Credit_check_date__c != null) {
                    daysAfterCreditCheck = (Date.valueOf(oppty.Credit_check_date__c)).daysBetween(Date.today());
                } else {
                    daysAfterCreditCheck = (Date.valueOf(oppty.CreatedDate)).daysBetween(Date.today());
                }
                if (daysAfterCreditCheck < 31) {
                    Trigger.new[count].addError('You can\'t clone the record before 31 days "Credit check date".');
                }
                count++;
            }
        }

        if (! oldToNewOpptiesIdMap.isEmpty()) {
            // clone attachments
            List<Attachment> attachmentsList = [
                    SELECT Id, Name, Body, ParentId
                    FROM Attachment
                    WHERE ParentId IN :oldToNewOpptiesIdMap.keySet() AND
                    (Name != 'CrefoReport.pdf' AND Name != 'CreditsafeReport.pdf' AND Name != 'CrifReport.pdf' AND Name != 'CofaceReport.pdf' AND Name != 'CrediconnectReport.pdf' AND Name != 'SchufaReport.pdf')
                    LIMIT 10000];

            List<Attachment> cloneAttachmentsList = new List<Attachment>();
            for (Attachment attachment : attachmentsList) {
                Attachment newAttachment = attachment.clone();
                newAttachment.ParentId = oldToNewOpptiesIdMap.get(attachment.ParentId);
                cloneAttachmentsList.add(newAttachment);
            }

            if ( ! cloneAttachmentsList.isEmpty()) {
                insert cloneAttachmentsList;
            }

            // clone fuel cards
            List<Tankkarten__c> tankkartenList = [
                    SELECT Id, Name, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Gross__c, Fahrzeugtyp__c, Produktbezugskategorie__c, Firmenname_auf_der_Karte__c, Opportunity__c
                    FROM Tankkarten__c
                    WHERE Opportunity__c IN :oldToNewOpptiesIdMap.keySet()
                    LIMIT 10000];

            List<Tankkarten__c> cloneTankkartenList = new List<Tankkarten__c>();
            for (Tankkarten__c tankkarten : tankkartenList) {
                Tankkarten__c newTankkarten = tankkarten.clone();
                newTankkarten.Opportunity__c = oldToNewOpptiesIdMap.get(tankkarten.Opportunity__c);
                cloneTankkartenList.add(newTankkarten);
            }

            if ( ! cloneTankkartenList.isEmpty()) {
                insert cloneTankkartenList;
            }

            // clone contact role
            List<OpportunityContactRole> opptyContactRoleList = [
                    SELECT Id, Role, ContactId, OpportunityId, IsPrimary
                    FROM OpportunityContactRole
                    WHERE OpportunityId IN :oldToNewOpptiesIdMap.keySet()
                    LIMIT 10000];

            List<OpportunityContactRole> oppConRoleToInsertList = new List<OpportunityContactRole>();
            for (OpportunityContactRole opptyConRole : opptyContactRoleList) {
                OpportunityContactRole newOpptyContactRole = opptyConRole.clone();
                newOpptyContactRole.OpportunityId = oldToNewOpptiesIdMap.get(opptyConRole.OpportunityId);
                if (opptyConRole.IsPrimary == true) {
                    newOpptyContactRole.IsPrimary = true;
                }
                oppConRoleToInsertList.add(newOpptyContactRole);
            }

            if ( ! oppConRoleToInsertList.isEmpty()) {
                insert oppConRoleToInsertList;
            }
        }
    }


    /*******************************************************************************
    *  Name            : setOpptyFieldsForClone()
    *  Summary         : Set fields if Opportunity is clone
    *  CreatedDate     : 16/02/2018
    *  ModifiedDate    : 04/11/2019
    *  Parameters      : List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void setOpptyFieldsForClone(List<Opportunity> newList) {
        for (Opportunity opp : newList) {
            if (opp.isClone() &&
                    opp.RecordTypeId != oppRecordTypes.get('Russian_Sales').getRecordTypeId() &&
                    opp.RecordTypeId != oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() &&
                    opp.RecordTypeId != oppRecordTypes.get('Carnet').getRecordTypeId()) {
                opp.StageName = 'Prospecting';
                opp.bearbeitet_von__c = '';
                opp.Closed_Won_by_CF__c = false;
                opp.Pending_Deposit_by_CF__c = false;
                opp.CF_Stage__c = 'Not launched';
                opp.Name_of_the_payer_Account_holder__c = '';
                opp.IBAN__c = '';
                opp.SWIFT_BIC__c = '';
            }
            if (opp.isClone() && opp.RecordTypeId == oppRecordTypes.get('Russian_Sales').getRecordTypeId()){
                opp.StageName = 'Qualified Lead';
            }
            if (opp.isClone() && opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId()){
                opp.StageName = 'Qualify';
                opp.Product_Solicited__c = '';
            }
            if (opp.isClone() && opp.RecordTypeId == oppRecordTypes.get('Carnet').getRecordTypeId()){
                opp.StageName = 'Qualify';
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateCurrencyIsoCode()
    *  Summary         : Update the CurrencyIsoCode in Opportunity
    *  CreatedDate     : 02-03-2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void updateCurrencyIsoCode(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        if (oldMap == null) {
            // before insert
            for (Opportunity opp : newList) {
                if (opp.Registered_Country__c != null) {
                    opp.CurrencyIsoCode = CountryToCurrencyIsoCodeMap.get(opp.Registered_Country__c);
                }
            }
        } else {
            // before update
            for (Opportunity opp : newList) {
                if (opp.Registered_Country__c != null && oldMap.get(opp.Id).AccountId != opp.AccountId) {
                    opp.CurrencyIsoCode = CountryToCurrencyIsoCodeMap.get(opp.Registered_Country__c);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : addErrorForCredit()
    *  Summary         : Add error for Credit if primary contact does not have valide email, incorrect details, Credit Decision is not "Endorsed" or "Endorsed, guarantee delivered"
    *  CreatedDate     : 05-03-2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void addErrorForCredit(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        List<Profile> profileList = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];

        String currentProfile = '';
        if ( ! profileList.isEmpty() ){
            currentProfile = profileList.get(0).Name;
        }

        List<Opportunity> opportunityList = [SELECT Id, (SELECT Contact.Email, IsPrimary FROM OpportunityContactRoles) FROM Opportunity WHERE Id IN :newList LIMIT 10000];
        String contactEmail;

        for (Opportunity opp : opportunityList) {
            for (OpportunityContactRole ocr : opp.OpportunityContactRoles) {
                if (ocr.IsPrimary == true) {
                    contactEmail = ocr.Contact.Email;
                }
            }
        }

        for (Opportunity opp : newList) {
            if (currentProfile == 'Credit' && opp.StageName == 'Closed Won' && oldMap.get(opp.Id).StageName != opp.StageName && opp.RecordTypeId != oppRecordTypes.get('Carnet').getRecordTypeId()) {
                if (opp.Kredit_Entscheidung__c != 'Genehmigt' && opp.Kredit_Entscheidung__c != 'Genehmigt, Sicherheit geliefert') {
                    opp.Kredit_Entscheidung__c.addError('The field \"Credit Decision\" should be only \"Endorsed\" or \"Endorsed, guarantee delivered\"');
                }
                if (contactEmail == null) {
                    opp.StageName.addError('Incorrect contact email or there is no primary contact');
                }
            }
        }
    }

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

    public static Map<String, String> templatesForCountriesMap = new Map<String, String>{
            'Germany' => 'Letter_8_visualforce',
            'Czech Republic' => 'Letter 9 visualforce [CZ]',
            'Slovakia' => 'Letter 9 visualforce [SK]',
            'Switzerland-DE' => 'Letter 8 visualforce [CH-DE]',
            'Switzerland-FR' => 'Letter 8 visualforce [CH-FR]',
            'Switzerland-IT' => 'Letter 8 visualforce [CH-IT]',
            'Luxembourg' => 'Letter 8 visualforce [LU]',
            'Austria' => 'Letter_8_visualforce_AT',
            'Belgium-FR' => 'Letter_8_visualforce_[BE-FR]',
            'Belgium-NL' => 'Letter_8_visualforce_[BE-NL]',
            'France' => 'Letter_8_visualforce_[FR]',
            'Hungary' => 'Letter 9 visualforce [HU]',
            'Netherlands' => 'Letter_8_visualforce_[NL]',
            'Poland' => 'Letter_9_visualforce_PL'
    };

    public static Map<String, String> templatesForBackOfficeStartsStatusesMap = new Map<String, String>{
            '0.6 Missing information provided' => 'Notify_Missing_Info_Done_to_Back_Office',
            'New Cards Requested to BO' => 'New_Cards_Requested_to_BO',
            'New PINs Requested to BO' => 'New_PINs_Requested_to_BO',
            '5.5 Winback Failed' => 'Contract_Termination_to_BO',
            'new closed won' => 'New_Closed_Won_Customer_to_BO'
    };

    public static Map<String, String> templatesForOwnerStartsStatusesMap = new Map<String, String>{
            '0.5 Missing information' => 'BO_Requires_Additional_Information',
            '0.4 Registration in GFN: Winback' => 'Winback_Request_Setup_in_GFN',
            '3.4 Volume Check 1: Winback' => 'Winback_Request_Volume_Check_1',
            '4.4 Volume Check 2: Winback' => 'Winback_Request_Volume_Check_2',
            '5.4 Final Check: Winback' => 'Winback_Request_Final_Check'
    };

    public static Map<String, Integer> startsSLAvaluesMap = new Map<String, Integer>{
            '0.5 Missing information' => 1,
            '0.4 Registration in GFN: Winback' => 1,
            '0.6 Missing information provided' => 1,
            '0.9 Ready for GFN' => 1,
            '1. Customer registered in GFN (card issued & delivered)' => 9,
            '2.1 First Check: Cards/PINs Received' => 14,
            '2.2 First Check: Not Reached' => 7,
            '2.3 First Check: Delay' => 7,
            '2.4 First Check: Winback' => 7,
            '3.1 Volume Check 1: Customer Pumping' => 14,
            '3.2 Volume Check 1: Not Reached' => 7,
            '3.3 Volume Check 1: Delay' => 7,
            '3.4 Volume Check 1: Winback' => 7,
            '4.1.1 Volume Check 2: Pumping Enough' => 14,
            '4.1.2 Volume Check 2: Pumping NOT Enough' => 14,
            '4.2 Volume Check 2: Not Reached' => 7,
            '4.3 Volume Check 2: Delay' => 7,
            '4.4 Volume Check 2: Winback' => 7,
            '5.4 Final Check: Winback' => 7
    };

    /*******************************************************************************
    *  Name            : sendOpportunityReportToBackOffice()
    *  Summary         : call future method to send info about customer and cards
    *  CreatedDate     : 24.11.2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendAccountReportToBackOffice(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        System.debug('IN sendAccountReportToBackOffice');
        System.debug('New oppty ' + newOpportunitiesMap);
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.Starts_Status__c == null)
                continue;

            System.debug('Is ready for GFN?: ' + opportunity.Starts_Status__c.equals('0.9 Ready for GFN'));
            System.debug('Is updated?: ' + !opportunity.Starts_Status__c.equals(oldOpportunitiesMap.get(opportunity.Id).Starts_Status__c));
            System.debug('Is GFNI_ApplicationId__c null?: ' + opportunity.GFNI_ApplicationId__c);
            System.debug('Is GFN_number_for_starts__c null?: ' + opportunity.GFN_number_for_starts__c);
            System.debug('Together: ' + (opportunity.Starts_Status__c.equals('0.9 Ready for GFN') && !opportunity.Starts_Status__c.equals(oldOpportunitiesMap.get(opportunity.Id).Starts_Status__c)));
            if (opportunity.Starts_Status__c != oldOpportunitiesMap.get(opportunity.Id).Starts_Status__c &&
                    opportunity.Starts_Status__c.equals('0.9 Ready for GFN') && opportunity.GFN_number_for_starts__c == null)
            {
                System.debug('Call future method for ' + opportunity.Id);
                GFNI_Handler.createFullGFNCustomer(opportunity.Id);
            }
        }
    }

    /*********************************************************************************************************
    *  Name            : closeTasksAfterOpportunityClosed()
    *  Summary         : checks if Opportunity's status changed to 'isClosed' and closes its current Tasks
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : 24/05/2021
    *  Parameters      : List<Opportunity> newList
    *  Returns         : void
    **********************************************************************************************************/
    public static void closeTasksAfterOpportunityClosed(List<Opportunity> newList, Map<ID, Opportunity> newMap) {
        if (! OpportunityTriggerHandler.isOpportunityClosed)  return;
        isOpportunityClosed = false;
        List<User> userList = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];

        Set<Id> oppIdsWithClosedStatus = new Set<Id>();
        for (Opportunity op : newList) {
            if (op.isClosed == true &&
                    (op.RecordTypeId == oppRecordTypes.get('Euroshell').getRecordTypeId() ||
                            op.RecordTypeId == oppRecordTypes.get('AllStar').getRecordTypeId() ||
                            op.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() ||
                            op.RecordTypeId == oppRecordTypes.get('Lotos').getRecordTypeId() ||
                            op.RecordTypeId == oppRecordTypes.get('Shell_Universal_Card').getRecordTypeId() ||
                            op.RecordTypeId == oppRecordTypes.get('Carnet').getRecordTypeId())) {
                oppIdsWithClosedStatus.add(op.Id);
            }
        }

        if (oppIdsWithClosedStatus.isEmpty() || userList.isEmpty()) {
            return;
        }

        List<Task> listTasksToClose = new List<Task>();
        for (List<Task> listTasks : [
                SELECT Id, WhatId, IsClosed, OwnerId, RecordTypeId
                FROM Task
                WHERE WhatId IN :oppIdsWithClosedStatus
                AND IsClosed = False
        ]) {
            for (Task tk : listTasks) {
                if(tk.RecordTypeId == taskRecordTypes.get('CCS_Tasks').getRecordTypeId() || tk.RecordTypeId == taskRecordTypes.get('Layout_Tasks').getRecordTypeId() || tk.OwnerId == userList.get(0).Id){
                    tk.Status = 'Completed';
                    listTasksToClose.add(tk);
                }
            }
        }

        if (!listTasksToClose.isEmpty()) {
            update listTasksToClose;
        }
    }

    /*******************************************************************************************************
    *  Name            : updateOpportunityAZSShellOne()
    *  Summary         : update AZS SHELL fields AZS_with_Discount_1_address__c and AZS_with_Discount_1__c  on OPPORTUNITY
    *  CreatedDate     : 02/03/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Opportunity> newList
    *  Returns         : void
    *****************************************************************************************************/
    public static void updateOpportunityAZSShellOne(List<Opportunity> newList) {
        Set<String> stationAZS = new Set<String>();
        for (Opportunity newOpportunity : newList) {
            if (newOpportunity.PPR_AZS_Retailer__c != null &&
                    oppRecordTypes.get('Russian_Sales').getRecordTypeId() == newOpportunity.RecordTypeId){
                stationAZS.add(newOpportunity.PPR_AZS_Retailer__c);
            }
        }
        if (!stationAZS.isEmpty()) {
            List<ShellTerminalAZS__c> shellAZS = [
                    SELECT name, Terminallist__c
                    FROM ShellTerminalAZS__c
                    WHERE name in :stationAZS
            ];
            for (Opportunity opportunity : newList) {
                if (opportunity.PPR_AZS_Retailer__c != null) {
                    for (ShellTerminalAZS__c shellTerminalAZS : shellAZS) {
                        if (opportunity.PPR_AZS_Retailer__c == shellTerminalAZS.name) {
                            opportunity.AZS_with_Discount_1_address__c = shellTerminalAZS.name;
                            opportunity.AZS_with_Discount_1__c = shellTerminalAZS.Terminallist__c;
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************************************
   *  Name            : updateOpportunityAZSShellOneTwo()
   *  Summary         : update AZS SHELL fields AZS_with_Discount_1_address__c, AZS_with_Discount_1__c  and
   *                     AZS_with_Discount_2_address__c, AZS_with_Discount_2__con OPPORTUNITY
   *  CreatedDate     : 05/06/2018
   *  ModifiedDate    : -
   *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
   *  Returns         : void
   *****************************************************************************************************/
    public static void updateOpportunityAZSShellOneTwo(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Map<Opportunity, String> azsOpportunitiesOne = new Map<Opportunity, String>();
        Map<Opportunity, String> azsOpportunitiesTwo = new Map<Opportunity, String>();
        for (Opportunity newOpportunity : newMap.values()) {
            Opportunity oldOpportunity = oldMap.get(newOpportunity.Id);
            if (newOpportunity.AZS_with_Discount_1_address__c != oldOpportunity.AZS_with_Discount_1_address__c &&
                    oppRecordTypes.get('Russian_Sales').getRecordTypeId() == newOpportunity.RecordTypeId)
                azsOpportunitiesOne.put(newOpportunity, newOpportunity.AZS_with_Discount_1_address__c);

            if (newOpportunity.AZS_with_Discount_2_address__c != oldOpportunity.AZS_with_Discount_2_address__c &&
                    oppRecordTypes.get('Russian_Sales').getRecordTypeId() == newOpportunity.RecordTypeId)
                azsOpportunitiesTwo.put(newOpportunity, newOpportunity.AZS_with_Discount_2_address__c);
        }
        if ( ! azsOpportunitiesOne.isEmpty() || ! azsOpportunitiesTwo.isEmpty() ) {
            Map<String, String> shellAZS = new Map<String, String>();
            for (ShellTerminalAZS__c shellTerminalAZS : [
                    SELECT name, TerminalList__c
                    FROM ShellTerminalAZS__c
                    WHERE (name IN :azsOpportunitiesOne.values()
                    OR name IN :azsOpportunitiesTwo.values())
            ]) {
                shellAZS.put(shellTerminalAZS.name, shellTerminalAZS.TerminalList__c);
            }

            for (Opportunity opportunity : azsOpportunitiesOne.keySet()) {
                if (opportunity.AZS_with_Discount_1_address__c == null) {
                    opportunity.AZS_with_Discount_1__c = '';
                } else {
                    opportunity.AZS_with_Discount_1__c = shellAZS.get(opportunity.AZS_with_Discount_1_address__c);
                }
            }

            for (Opportunity opportunity : azsOpportunitiesTwo.keySet()) {
                if (opportunity.AZS_with_Discount_2_address__c == null) {
                    opportunity.AZS_with_Discount_2__c = '';
                } else {
                    opportunity.AZS_with_Discount_2__c = shellAZS.get(opportunity.AZS_with_Discount_2_address__c);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : setCloseDate(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : Update Closed Date when Stage is changed to "Closed Won" or "Closed Lost" or "Duplicate"
    *  CreatedDate     : 08/05/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - map with old opportunity values, Map<Id,
                         Opportunity> newOpportunitiesMap - map with new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void setCloseDate(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.StageName != oldOpportunitiesMap.get(opportunity.Id).StageName &&
                    (opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Closed Lost' || opportunity.StageName == 'Duplicate') &&
                    (opportunity.RecordTypeId == oppRecordTypes.get('Euroshell').getRecordTypeId() ||
                            opportunity.RecordTypeId == oppRecordTypes.get('Euroshell_Starts').getRecordTypeId() ||
                            opportunity.RecordTypeId == oppRecordTypes.get('Carnet').getRecordTypeId() ||
                            opportunity.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId())) {
                opportunity.CloseDate = Date.today();
            }
        }
    }

    /*******************************************************************************************************
    *  Name            : updateOpenTaskCheckbox(Map<Id, Opportunity> oldMap, List<Opportunity> newList)
    *  Summary         : update Open_Task__c field when opportunity owner is changed
    *  CreatedDate     : 07/05/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, List<Opportunity> newList
    *  Returns         : void
    *****************************************************************************************************/
    public static void updateOpenTaskCheckbox(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> opptysToUpdate = new Set<Id>();
        for (Opportunity opportunity : newMap.values()) {
            if (opportunity.OwnerId != oldMap.get(opportunity.Id).OwnerId) {
                opptysToUpdate.add(opportunity.Id);
            }
        }

        if (opptysToUpdate.size() > 0) {
            String requestUrl = System.URL.getCurrentRequestUrl().getPath();
            List<Opportunity> opptyList = [SELECT Id, (SELECT Id, OwnerId FROM Tasks WHERE IsClosed = false) FROM Opportunity WHERE Id in :opptysToUpdate];
            for (Opportunity opportunity : opptyList) {
                if (opportunity.Tasks.size() > 0) {
                    newMap.get(opportunity.Id).Open_Task__c = false;
                    /**
                     * есть 4 варианта смены владельца возможности. При одном из них так же меняется владелец таски, только без вызова таск триггера.
                     * Таким образом в 3 случаях нам надо сравнивать только нового владельца с владельцем таски, так как владелец тасок не поменяется.
                     * Иначе надо сравнивать и нового и старого владельца. В случае если хотябы один совпал, то ставится true. Тоесть если были таски с таким же вледельцем что и возможность,
                     * то владелец таски поменяется. Если же не было тасок с таким же владельцем, то надо проверить вдруг есть таски с новым пользователем.
                     *
                     * There are 4 options for changing the owner of the opportunity. With one of them, the owner of the task also changes, only without triggering a task trigger.
                     * Thus, in 3 cases, we need only compare the new owner with the owner of tasks, as the owner of tasks not changes.
                     * Otherwise, you need to compare the new and the old owner. In case if at least one coincided, then it is set to true. Ie if there were tasks with the same owner as the opportunity,
                     * then the owner of the user will change. If there were no tasks with the same owner, then you should check is there a task with a new owner.
                     *
                     * requestUrl.contains('/services/Soap/') - смена владельца через DataLoader/Api / owner change via DataLoader/Api
                     * requestUrl.contains('waitingJobPage') - смена владельца через Account / owner change via Account owner change
                     * requestUrl.contains('ApprovePprRequestFromEmail') - смена владельца через ApprovePprRequestFromEmail.page / owner change via ApprovePprRequestFromEmail.page
                     */
                    if (requestUrl.contains('/services/Soap/') || requestUrl.contains('waitingJobPage') || requestUrl.contains('ApprovePprRequestFromEmail')) {
                        //owner changed from acc or via data loader or approval process
                        for (Task task : opportunity.Tasks) {
                            if (task.OwnerId.equals(newMap.get(opportunity.Id).OwnerId)) {
                                newMap.get(opportunity.Id).Open_Task__c = true;
                                break;
                            }
                        }
                    } else {
                        //owner changed from oppty page
                        for (Task task : opportunity.Tasks) {
                            if (task.OwnerId.equals(newMap.get(opportunity.Id).OwnerId) || task.OwnerId.equals(oldMap.get(opportunity.Id).OwnerId)) {
                                newMap.get(opportunity.Id).Open_Task__c = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : closeSignedOpportunities(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList)
    *  Summary         : If Opportunity Stage is "Contract Check" and DocuSign_Status__c
                         is chaged to "Comleted", then change Opportunity Stage to "Closed Won"
    *  CreatedDate     : 01/06/2018
    *  ModifiedDate    : 11/12/2019
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - map of old Opportunities values,
                         List<Opportunity> newOpportunitiesList - list of new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void closeSignedOpportunities(Opportunity oldOpportunity, Opportunity newOpportunity) {
        if ((newOpportunity.StageName == 'Pending Credit - Contract Check' || newOpportunity.Credit_Stage__c == 'Pending Credit - Contract Check') &&
                newOpportunity.DocuSign_Status__c == 'Completed' && oldOpportunity.DocuSign_Status__c != newOpportunity.DocuSign_Status__c) {
            newOpportunity.StageName = 'Closed Won';
            newOpportunity.CF_Stage__c = 'Auto CW';
            newOpportunity.Closed_Won_by_CF__c = true;
        }
    }


    /*******************************************************************************
    *  Name            : approveSignedOpportunities(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList)
    *  Summary         : If Opportunity Stage is changed from "Contract Check" to "Closed Won" and DocuSign_Status__c
                         is chaged to "Comleted", then approve Opportunity
    *  CreatedDate     : 05/06/2018
    *  ModifiedDate    : 11/12/2019
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - map of old Opportunities values,
                         List<Opportunity> newOpportunitiesList - list of new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void approveSignedOpportunities(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList) {
        Set<Id> opportunitiesToApproveIdsSet = new Set<Id>();
        for (Opportunity newOpportunity : newOpportunitiesList) {
            if (newOpportunity.StageName == 'Closed Won' && newOpportunity.StageName != oldOpportunitiesMap.get(newOpportunity.Id).StageName
                    && newOpportunity.Credit_Stage__c == 'Pending Credit - Contract Check'
                    && newOpportunity.DocuSign_Status__c == 'Completed' && oldOpportunitiesMap.get(newOpportunity.Id).DocuSign_Status__c != newOpportunity.DocuSign_Status__c) {
                opportunitiesToApproveIdsSet.add(newOpportunity.Id);
            }
        }

        if (! opportunitiesToApproveIdsSet.isEmpty()) {
            List<ProcessInstance> processInstancesList = [
                    SELECT Id, (SELECT Id FROM Workitems)
                    FROM ProcessInstance
                    WHERE TargetObjectId IN :opportunitiesToApproveIdsSet AND Status = 'Pending'];

            List<Approval.ProcessWorkitemRequest> requestsList = new List<Approval.ProcessWorkitemRequest>();
            for (ProcessInstance processInstance : processInstancesList) {
                for (ProcessInstanceWorkItem workItem : processInstance.Workitems) {
                    Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
                    request.setAction('Approve');
                    request.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                    request.setWorkitemId(workItem.Id);
                    requestsList.add(request);
                }
            }

            Approval.process(requestsList);
        }
    }


    /*******************************************************************************
    *  Name            : updateE2EFields()
    *  Summary         : update E2E_Status__c and E2E_Sales_Type__c before insert
    *  CreatedDate     : 17/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void updateE2EFields(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        if (oldMap == null) {
            // before insert
            for (Opportunity opportunity : newList) {
                if (!opportunity.E2E__c && !opportunity.E2E_2__c && oppRecordTypes.get('Euroshell').getRecordTypeId() == opportunity.RecordTypeId && opportunity.E2E_Status__c != 'Drop off') {
                    opportunity.E2E_Status__c = 'Not started';
                    opportunity.E2E_Sales_Type__c = 'Fully manual';
                }
            }
        } else {
            // before update
            for (Opportunity opportunity : newList) {
                if (oppRecordTypes.get('Euroshell').getRecordTypeId() == opportunity.RecordTypeId && oldMap.get(opportunity.Id).StageName != opportunity.StageName &&
                        (opportunity.StageName == 'Closed Lost' || opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Pending Sales – Deposit')) {
                    opportunity.E2E_Status__c = 'Finished';
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateFieldsForVatRecovery(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : Update required for vat recovery fields or display an error if they are empty
    *  CreatedDate     : 25/12/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap - old Opportunity values, Map<Id, Opportunity> newMap - new Opportunity values
    *  Returns         : void
    ******************************************************************************/
    public static void updateFieldsForVatRecovery(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> opportunitiesIdsSet = new Set<Id>();
        for (Opportunity opportunity : newMap.values()) {
            if (  oppRecordTypes.get('Euroshell').getRecordTypeId() == opportunity.RecordTypeId && opportunity.Registered_Country__c == 'Poland' && opportunity.VAT_Recovery__c == true &&
                    (opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Pending Credit - Contract Check' || opportunity.Credit_Stage__c == 'Pending Credit - Contract Check') &&
                    opportunity.StageName != oldMap.get(opportunity.Id).StageName) {
                opportunitiesIdsSet.add(opportunity.Id);
            }
        }

        if (! opportunitiesIdsSet.isEmpty()) {
            Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([
                    SELECT Account.Gesellschaftsform__c,
                    (SELECT Contact.Birthdate, IsPrimary
                    FROM OpportunityContactRoles),
                    (SELECT Fahrzeugtyp__c
                    FROM Tankkarten__r)
                    FROM Opportunity
                    WHERE Id IN :opportunitiesIdsSet]);
            for (Opportunity opportunity : newMap.values()) {
                if (opportunitiesMap.containsKey(opportunity.Id) && soloTradersLegalFormsList.contains(opportunitiesMap.get(opportunity.Id).Account.Gesellschaftsform__c)) {
                    for (OpportunityContactRole role : opportunitiesMap.get(opportunity.Id).OpportunityContactRoles) {
                        if (role.IsPrimary == true) {
                            if (role.Contact.Birthdate != null) {
                                opportunity.Primary_Contact_Birthdate__c = role.Contact.Birthdate;
                            } else {
                                if (opportunity.Opp_Owner_Profile__c != 'API Only') {
                                    opportunity.addError('Birthdate of primary contact shouldn\'t be empty.');
                                }
                            }
                            break;
                        }
                    }

                    Set<String> typesOfTheVehiclesSet = new Set<String>();
                    for (Tankkarten__c card : opportunitiesMap.get(opportunity.Id).Tankkarten__r) {
                        typesOfTheVehiclesSet.add(card.Fahrzeugtyp__c);
                    }

                    if (typesOfTheVehiclesSet.contains('PKW') && typesOfTheVehiclesSet.contains('LKW')) {
                        opportunity.Fleet_type_VAT_recovery__c = 'Mixed';
                    } else if (typesOfTheVehiclesSet.contains('PKW')) {
                        opportunity.Fleet_type_VAT_recovery__c = 'Fleet';
                    } else if (typesOfTheVehiclesSet.contains('LKW')) {
                        opportunity.Fleet_type_VAT_recovery__c = 'CRT';
                    }
                }
            }
        }
    }


    public static List<String> soloTradersLegalFormsList = new List<String> {
            'e.K', // e.K.
            'ENTREPRISE INDIVIDUELLE', // INDIVIDUAL ENTREPRISE
            'Private limited company',
            'Einzelfirma', // Single company
            'Single person company confirmed',
            'Eenmanszaak' // Sole proprietorship
    };


    /*******************************************************************************
    *  Name            : updateAccountGFNNumber(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : Update account GFN number
    *  CreatedDate     : 14/04/2019
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap - old Opportunity values, Map<Id, Opportunity> newMap - new Opportunity values
    *  Returns         : void
    ******************************************************************************/
    public static void updateAccountGFNNumber(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Account> lstAccount = new List<Account>();
        Map<String, String> accountToOpptyMap = new Map<String, String>();
        for (Opportunity opp : newMap.values()) {
            if (oldMap.get(opp.Id).GFN_number_for_starts__c != opp.GFN_number_for_starts__c && opp.GFN_number_for_starts__c != null && opp.AccountId != null) {
                accountToOpptyMap.put(opp.AccountId, opp.GFN_number_for_starts__c);
            }
        }
        if (! accountToOpptyMap.isEmpty()) {
            List<Account> accToUpdateList = [SELECT Id, GFN_Nr__c, ColCo__c, BillingCountry FROM Account WHERE Id IN :accountToOpptyMap.keySet() LIMIT 50000];

            for (Account acc : accToUpdateList) {
                if (accountToOpptyMap.containsKey(acc.Id)) {
                    Boolean isAccountChanged = false;
                    if(acc.GFN_Nr__c != accountToOpptyMap.get(acc.Id)) {
                        acc.GFN_Nr__c = accountToOpptyMap.get(acc.Id);
                        isAccountChanged = true;
                    }
                    if(String.isEmpty(acc.ColCo__c) && String.isNotEmpty(acc.BillingCountry)) {
                        acc.ColCo__c = GFNI_Utils.getStringValue(acc.BillingCountry.split('-').get(0), Schema.Account.BillingCountry.getDescribe(), 'CountryCode');
                        isAccountChanged = true;
                    }
                    if(isAccountChanged) {
                        lstAccount.add(acc);
                    }
                }
            }
            if (!lstAccount.isEmpty()) {
                update lstAccount;
            }
        }
    }


    /*******************************************************************************
    *  Name            : checkAccountOpportunities(Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : Check that Account doesn't already have Opportunity created in the last 31 days with the same record type
    *  CreatedDate     : 15/04/2019
    *  ModifiedDate    : 08/07/2019
    *  Parameters      : List<Opportunity> newOpportunitiesList - new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void checkAccountOpportunities(List<Opportunity> newOpportunitiesList) {
        Set<Id> accountIdsSet = new Set<Id>();
        for (Opportunity opportunity : newOpportunitiesList) {
            if (opportunity.RecordTypeId == oppRecordTypes.get('Euroshell').getRecordTypeId() && ! opportunity.isClone() && opportunity.AccountId != null) {
                accountIdsSet.add(opportunity.AccountId);
            }
        }

        if (! accountIdsSet.isEmpty()) {
            String currentProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            if (Create_Opportunities_Admin_Profiles__c.getInstance(currentProfileName) != null) return;

            List<Opportunity> opportunitiesList = [
                    SELECT RecordTypeId, CreatedDate, AccountId, Credit_check_date__c
                    FROM Opportunity
                    WHERE AccountId IN :accountIdsSet];

            if (! opportunitiesList.isEmpty()) {
                Map<Id, List<Opportunity>> accountToOpportunitiesMap = new Map<Id, List<Opportunity>>();
                for (Opportunity opportunity : opportunitiesList) {
                    if (! accountToOpportunitiesMap.containsKey(opportunity.AccountId)) {
                        accountToOpportunitiesMap.put(opportunity.AccountId, new List<Opportunity>());
                    }
                    if (opportunity.RecordTypeId == oppRecordTypes.get('Euroshell').getRecordTypeId() && (opportunity.Credit_check_date__c != null &&
                            opportunity.Credit_check_date__c >= Date.today().addDays(-31) ||
                            opportunity.Credit_check_date__c == null && opportunity.CreatedDate >= Date.today().addDays(-31))) {
                        accountToOpportunitiesMap.get(opportunity.AccountId).add(opportunity);
                    }
                }

                if (! accountToOpportunitiesMap.isEmpty()) {
                    for (Opportunity opportunity : newOpportunitiesList) {
                        if (accountToOpportunitiesMap.containsKey(opportunity.AccountId) && ! accountToOpportunitiesMap.get(opportunity.AccountId).isEmpty()) {
                            if (! Test.isRunningTest() || Test.isRunningTest() && UserInfo.getUserName().contains('testactiveopportunity')) {
                                opportunity.addError('You are not allowed to create a new Opportunity for the Account that already has an active Opportunity ' +
                                        '(<31 days from Opportunity creation). If the active Opportunity is Closed Won or Closed Lost, please use "Reopen" button ' +
                                        'to continue working with the existing Opportunity.');
                            }
                        }
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : setPenaltyRating
    *  Summary         : Set penalty rating for refused records
    *  CreatedDate     : 20/05/2019
    *  ModifiedDate    : -
    *  Returns         : -
    ******************************************************************************/
    public static void setPenaltyRating(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Map<Id, Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
        // set list of refusal stages for opportunity
        List<String> refuseStages = new List<String>{'Отказ','Потерян в конкуренции'};
        // search opportunities for which stage was changed to refusal
        for (Opportunity opp : newMap.values()) {
            if(oppRecordTypes.get('Russian_Sales').getRecordTypeId() == opp.RecordTypeId && opp.StageName != oldMap.get(opp.Id).StageName && refuseStages.contains(opp.StageName)){
                opportunitiesToUpdate.put(opp.id, opp);
            }
        }
        // if there are opportunities which were just set as refusal then set refusal penalty for them
        if(opportunitiesToUpdate.size() != 0){
            List<Account> accList = new List<Account>();

            //--- Field Manager and Buddy users Ids
            Set<Id> fieldManagers = new Set<Id>(); // field manager and buddy users ids
            for(PermissionSetAssignment managerAssignment : [
                    SELECT AssigneeId
                    FROM PermissionSetAssignment
                    WHERE PermissionSet.Name = 'FieldSalesTerritory_Field_Manager' OR PermissionSet.Name = 'FieldSalesTerritory_buddy']) {
                fieldManagers.add(managerAssignment.AssigneeId);
            }
            //--- other users (Telesales)
            Set <String> telesalesQueuesNames = new Set <String> {'PPR_Queue_Stock_DISQUALIFIED', 'PPR_Queue_Stock_DISQUALIFIED_Call_Center'};
            Map <String, Set<Id>> telesalesQueueUserIdsAndRoleIds = GlobalUtils.getQueueUserIdsAndRoleIds(telesalesQueuesNames);

            // telesales profiles
            Set <String> profileNames_Telesales = new Set <String> {
                    'Russian Call Center', 'Russian Quality Control', 'Russian Read Only',
                    'Russian Sales Manager', 'Russian Team Leader'
            };
            // get all telesales users (active only)
            Map <Id, User> allTelesalesUsersMap = new Map <Id, User> ([
                    SELECT Id
                    FROM User
                    WHERE IsActive = true
                    AND (UserRoleId IN :telesalesQueueUserIdsAndRoleIds.get('RoleIds') // users by roles from queues inner 'Role' groups
                    OR Id IN :telesalesQueueUserIdsAndRoleIds.get('UserIds') // users from queue groups and inner regular groups in queues
                    OR Profile.Name IN :profileNames_Telesales // users by telesales profiles
                    )
                    AND (Id NOT IN :fieldManagers // exclude users from field sales and buddy permission sets
                    )
            ]);

            //--- if users for setting penalty were found; set penalty for refusal
            if(fieldManagers.size() != 0 || allTelesalesUsersMap.size() != 0){
                Map<String, FieldSalesTerritory_General_Settings__c> fieldSalesSettings = FieldSalesTerritory_General_Settings__c.getAll();

                for(Opportunity opportunity : opportunitiesToUpdate.values()){
                    //--- the refusal was set by Field Manager or Buddy user: set refusal penalty for the opportunity
                    if (opportunity.OwnerId == UserInfo.getUserId() && fieldManagers.contains(UserInfo.getUserId())) {
                        accList.add(new Account(
                                Id = opportunity.AccountId,
                                Rating_FS_Penalty__c = fieldSalesSettings.get('RU').Penalty_for_refusal__c)
                        );
                    }
                    //--- the refusal was set by other users (Telesales): set refusal penalty for the opportunity
                    else if (opportunity.OwnerId == UserInfo.getUserId() && allTelesalesUsersMap.containsKey(UserInfo.getUserId())) {
                        accList.add(new Account(
                                Id = opportunity.AccountId,
                                Rating_FS_Penalty__c = fieldSalesSettings.get('RU').Penalty_for_Refusal_Telesales__c)
                        );
                    }
                }
            }
            //--- update accounts penalty for refusal
            if(accList.size() != 0){
                update accList;
            }
        }
    }


    /*******************************************************************************
   *  Name            : validateCarnetOpportunity()
   *  Summary         : Give user error message if Files are missing.
   *  CreatedDate     : 30/10/2019
   *  ModifiedDate    : ---
   *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
   *  Returns         : void
   ******************************************************************************/
    public static void validateCarnetOpportunity(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> oppSet = newMap.keySet();
        Set<Id> oppIds = new Set<Id>();

        for (Opportunity opp :newMap.values()) {
            if(opp.RecordTypeId == oppRecordTypes.get('Carnet').getRecordTypeId() && opp.StageName == 'Closed Won'){
                oppIds.add(opp.Id);
            }
        }

        if(!oppIds.isEmpty()) {
            List<ContentDocumentLink> rOpp = [SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :oppSet AND ContentDocument.Title LIKE 'Carnet_podsumowanie_zamowienia%' LIMIT 1];

            if(rOpp.size() == 0){
                for (Opportunity opp :newMap.values()){
                    opp.addError(System.Label.FilesOpportunityCarnet, false);
                }
            }
        }

        for (Opportunity opp :newMap.values()){
            if(opp.Form_of_Payment__c != null){
                /*if (opp.Account_Status_from_Account__c == 'Customer' && opp.Form_of_Payment__c <> 'Bank Transfer - after delivery' && opp.RecordTypeId == oppRecordTypes.get('Carnet').getRecordTypeId() && opp.isClosed == false){
                    opp.addError(Label.CarnetAccountStatusProspect, false);
                }*/
                if((opp.Account_Status_from_Account__c == 'Prospect' || opp.Account_Status_from_Account__c == 'Former Customer') && opp.Form_of_Payment__c <> 'Advanced payment' && opp.RecordTypeId == oppRecordTypes.get('Carnet').getRecordTypeId() && opp.isClosed == false){
                    opp.addError(Label.CarnetAccountStatusProspect, false);
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : carnetDepositReceived()
    *  Summary         : Populate Deposit fields on Carnet Opportunity.
    *  CreatedDate     : 30/10/2019
    *  ModifiedDate    : ---
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void carnetDepositReceived(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Set<Id> oppIds1 = new Set<Id>();
        Set<Id> oppIds2 = new Set<Id>();

        for (Opportunity opp : newMap.values()) {
            if(opp.RecordTypeId ==  oppRecordTypes.get('Carnet').getRecordTypeId() && opp.Deposit_Amount__c == true && (!oldMap.get(opp.Id).Deposit_Amount__c == true)){
                oppIds1.add(opp.Id);
            }
            else if(opp.RecordTypeId ==  oppRecordTypes.get('Carnet').getRecordTypeId() && opp.Deposit_Amount__c == false && (!oldMap.get(opp.Id).Deposit_Amount__c == false)){
                oppIds2.add(opp.id);
            }
        }

        if(!oppIds1.isEmpty()){
            List<Opportunity> opportunityList1 = [SELECT Id, StageName, Deposit_received_confirmed_by__c, Deposit_received_confirmed_when__c FROM Opportunity WHERE Id IN:oppIds1];

            if(!opportunityList1.isEmpty()){
                for(Opportunity oppN :opportunityList1){
                    oppN.StageName = 'Closed Won';
                    oppN.Deposit_received_confirmed_by__c = UserInfo.getName();
                    oppN.Deposit_received_confirmed_when__c = datetime.now();
                    lstOpportunity.add(oppN);
                }
            }
        }

        if(!oppIds2.isEmpty()){
            List<Opportunity> opportunityList2 = [SELECT Id, StageName, Deposit_received_confirmed_by__c, Deposit_received_confirmed_when__c FROM Opportunity WHERE Id IN:oppIds2];

            if(!opportunityList2.isEmpty()){
                for(Opportunity oppN :opportunityList2){
                    oppN.Deposit_received_confirmed_by__c = '';
                    oppN.Deposit_received_confirmed_when__c = null;
                    lstOpportunity.add(oppN);
                }
            }
        }

        if (!lstOpportunity.isEmpty()) {
            update lstOpportunity;
        }
    }

    /*******************************************************************************
    *  Name            : carnetStatusClosed()
    *  Summary         : Update Account fields after Carnet Opportunity StageName is won.
    *  CreatedDate     : 1/11/2019
    *  ModifiedDate    : ---
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void carnetStatusClosed(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Account> uptAcconut = new List<Account>();
        Set<Id> oppIds = new Set<Id>();
        List<Id> oppIdToSend = new List<Id>();
        Set<Id> accIds = new Set<Id>();

        for (Opportunity opp :newMap.values()) {
            if(opp.RecordTypeId ==  oppRecordTypes.get('Carnet').getRecordTypeId() && opp.StageName == 'Closed Won' && oldMap.get(opp.Id).StageName != 'Closed Won'){
                oppIds.add(opp.Id);
                oppIdToSend.add(opp.Id);
            }
        }

        if (!oppIds.isEmpty()) {
            List<Opportunity> accOpp = [SELECT AccountId FROM Opportunity WHERE Id IN:oppIds];
            if (!accOpp.isEmpty()) {
                for(Opportunity accA :accOpp){
                    CarnetWelcomeEmailClient.sendEmailWithAttachment(oppIdToSend);
                    CarnetWelcomeEmailBO.sendEmailWithAttachment(oppIdToSend);
                    accIds.add(accA.AccountId);
                }
            }

            List<Account> AccUpt = [SELECT Id, Account_Status__c FROM Account WHERE Id IN:accIds];
            if (!AccUpt.isEmpty()) {
                for(Account accP :AccUpt){
                    if(accP.Account_Status__c != 'Customer') {
                        accP.Account_Status__c = 'Customer';
                        uptAcconut.add(accP);
                    }
                }
            }

            if (!uptAcconut.isEmpty()) {
                update uptAcconut;
            }

        }

    }
    /*******************************************************************************
    *  Name            : carnetOpportunityTypeStatus()
    *  Summary         : Approve changing type of oppo with opportunity.AccountStatus.
    *  CreatedDate     : 2/11/2019
    *  ModifiedDate    : ---
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/

    public static void carnetOpportunityTypeStatus(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        for (Opportunity opp :newMap.values()) {
            if(opp.RecordTypeId ==  oppRecordTypes.get('Carnet').getRecordTypeId() && !(opp.Type == 'New GFN') && !(opp.Type == null) && opp.Account_Status_from_Account__c == 'Prospect' && opp.isClosed == false){
                opp.addError(Label.CarnetAccountStatusGFNProspect, false);
            }
        }
    }

    /*******************************************************************************
    *  Name            : carnetOpportunityDepositAmountCheck()
    *  Summary         : block not allowed checking of Deposit_Amount__c value if type of payment is not correct
    *  CreatedDate     : 2/11/2019
    *  ModifiedDate    : ---
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/

    public static void carnetOpportunityDepositAmountCheck(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        for (Opportunity opp :newMap.values()) {
            if(opp.RecordTypeId ==  oppRecordTypes.get('Carnet').getRecordTypeId() && !(opp.Form_of_Payment__c == 'Advanced payment') && opp.Deposit_Amount__c == true){
                opp.addError(Label.CarnetOpportunityDepositAmountPayment, false);
            }
        }
    }


    /*******************************************************************************
    *  Name            : carnetOpportunitySaveClosedWonPayment()
    *  Summary         : Block unauthorized changing status as Closed won
    *  CreatedDate     : 2/11/2019
    *  ModifiedDate    : ---
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/

    public static void carnetOpportunitySaveClosedWonPayment(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        for (Opportunity opp :newMap.values()) {
            if(opp.RecordTypeId ==  oppRecordTypes.get('Carnet').getRecordTypeId() && opp.Deposit_Amount__c == false && opp.Form_of_Payment__c == 'Advanced payment' && opp.StageName == 'Closed Won' && !(oldMap.get(opp.Id).StageName == 'Closed Won')){
                opp.addError(Label.CarnetOpportunityClosedWonCheck, false);
            }
        }
    }

    /*******************************************************************************
    *  Name            : carnetOpportunityProfileRolesClosing()
    *  Summary         : Block unauthorized changing status as Closed won
    *  CreatedDate     : 2/11/2019
    *  ModifiedDate    : ---
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/

    public static void carnetOpportunityProfileRolesClosing(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Id idProfile =  userinfo.getProfileId();
        Boolean check = false;

        for (Opportunity opp :newMap.values()) {
            if (opp.RecordTypeId ==  oppRecordTypes.get('Carnet').getRecordTypeId() && (opp.isClosed == true || oldMap.get(opp.Id).isClosed == true) && (oldMap.get(opp.Id).StageName == 'Closed Won' || oldMap.get(opp.Id).StageName == 'Closed Lost' )) {
                List<Profile> profileName = [Select Name from Profile where Id = :idProfile];
                if (!profileName.isEmpty()) {
                    for(Carnet_Profiles_Approval__c field : Carnet_Profiles_Approval__c.getAll().values()) {
                        for(Profile profile : profileName){
                            if (field.Field_Name__c == profile.Name) {
                                check = true;
                            }
                        }
                    }
                }

                for (Carnet_Opportunity_Fields_after_Closed__c field :Carnet_Opportunity_Fields_after_Closed__c.getAll().values()) {
                    if (newMap.get(opp.Id).get(field.Name) != oldMap.get(opp.Id).get(field.Name)) {
                        check = true;
                        break;
                    }
                }

                if (!check) {
                    opp.addError(Label.CarnetOpportunityAdminClosing, false);
                }
            }
        }
    }

    public static void setFieldsNVM(List<Opportunity> newList){
        for(Opportunity opportunity: newList){
            if(opportunity.Name != null && UserInfo.getName() != 'E2E RU Site Guest User'){
                opportunity.NVM_CLID__c = opportunity.NVM_CLID1__c + opportunity.NVM_CLID2__c + opportunity.NVM_CLID3__c + opportunity.NVM_CLID4__c + opportunity.NVM_CLID5__c;
            }
        }
    }

    public static void updateFieldsOnConvert(List<Opportunity> newList){
        for(Opportunity opportunity : newList){
            if(opportunity.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId()){
                if(opportunity.CCS_Merlin_Stage__c != null){
                    opportunity.StageName = opportunity.CCS_Merlin_Stage__c;
                    if (opportunity.Product_Solicited__c != 'OMV' && opportunity.IsClosed == false){
                        opportunity.Eco_Fee__c = false;
                    }
                }
                if(opportunity.Opportunity_Type_from_Lead__c != null){
                    opportunity.Type = opportunity.Opportunity_Type_from_Lead__c;
                }
            } else if(opportunity.RecordTypeId == oppRecordTypes.get('Carnet').getRecordTypeId()){
                opportunity.StageName = 'Qualify';
                if(opportunity.Opportunity_Type_from_Lead__c != null){
                    if(opportunity.Account_Status_from_Account__c == 'Prospect'){
                        opportunity.Type = 'New GFN';
                        opportunity.Monthly_Payment_Method__c = 'Bank transfer';
                        opportunity.GFN_number_for_starts__c = '';
                    } else if(opportunity.Account_Status__c == 'Customer'){
                        opportunity.Type = 'Existing GFN';
                        opportunity.Monthly_Payment_Method__c = 'Your existing payment method';
                    }
                }
            } else if(opportunity.RecordTypeId == oppRecordTypes.get('Lotos').getRecordTypeId()){
                opportunity.StageName = 'Qualify';
                if(opportunity.Opportunity_Type_from_Lead__c != null){
                    opportunity.Type = opportunity.Opportunity_Type_from_Lead__c;
                }
            } else if(opportunity.RecordTypeId == oppRecordTypes.get('Euroshell').getRecordTypeId()){
                if(opportunity.Opportunity_Type_from_Lead__c != null){
                    opportunity.Type = opportunity.Opportunity_Type_from_Lead__c;
                }
            }
        }
    }

    /*******************************************************************************
   *  Name            : carnetOpportunityClosedWon()
   *  Summary         : Populate Account Status on Opportunity after Closed Won.
   *  CreatedDate     : 7/11/2019
   *  ModifiedDate    : ---
   *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
   *  Returns         : void
   ******************************************************************************/
    public static void carnetOpportunityClosedWon(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();

        for (Opportunity opp : newMap.values()) {
            if(opp.RecordTypeId == oppRecordTypes.get('Carnet').getRecordTypeId() && opp.StageName == 'Closed Won' && (oldMap.get(opp.Id).StageName != 'Closed Won') && opp.Account_Status__c != 'Customer'){
                oppIds.add(opp.Id);
            }
        }

        if(!oppIds.isEmpty()){
            List<Opportunity> opportunityList = [SELECT Id, StageName, Account_Status__c FROM Opportunity WHERE Id IN:oppIds];
            if(!opportunityList.isEmpty()){
                for(Opportunity oppN :opportunityList){
                    oppN.Account_Status__c = 'Customer';
                    lstOpportunity.add(oppN);
                }
            }
        }

        if (!lstOpportunity.isEmpty()) {
            update lstOpportunity;
        }
    }

    /*******************************************************************************
   *  Name            : calculateOpportunityProcessingTime
   *  Summary         : calculating Opportunity processing time (BEFORE UPDATE TRIGGER)
   *  CreatedDate     : 13/12/2017
   *  ModifiedDate    : -
   *  Parameters      : Map<Id, Opportunity> oldMap, Opportunity<Id, Opportunity> newMap
   *  Returns         : void
   ******************************************************************************/
    public static void calculateOpportunityProcessingTime(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Opportunity> processedOpportunitiesList = new List<Opportunity>();
        Set<Id> opportunityOwnersIdSet = new Set<Id>();
        for (Opportunity opp : newMap.values()) {
            if(opp.RecordTypeId == oppRecordTypes.get('Russian_Sales').getRecordTypeId()){
                if(oldMap.get(opp.Id).StageName == 'Unprocessed' && opp.StageName != 'Unprocessed'){
                    processedOpportunitiesList.add(opp);
                    opportunityOwnersIdSet.add(opp.OwnerId);
                }
            }
        }
        if (!processedOpportunitiesList.isEmpty()) {
            Map<String, BusinessHours> localeBusinessHoursMap = new Map<String, BusinessHours>();
            for (BusinessHours bh : [SELECT Id, Name, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayEndTime, WednesdayStartTime,
                    ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime,
                    SundayStartTime
            FROM BusinessHours
            LIMIT 10000]) {
                if (bh.Name == 'RU') {
                    localeBusinessHoursMap.put('ru_RU', bh);
                } else if (bh.Name == 'Default') {
                    localeBusinessHoursMap.put('Default', bh);
                }
            }

            Map<String, BusinessHours> businessHoursForUsersMap = new Map<String, BusinessHours>();
            for (User usr : [SELECT Id, Name, LocaleSidKey FROM User WHERE Id IN :opportunityOwnersIdSet LIMIT 10000]) {
                if (usr.LocaleSidKey == 'ru_RU') {
                    businessHoursForUsersMap.put(usr.Id, localeBusinessHoursMap.get('ru_RU'));
                } else {
                    businessHoursForUsersMap.put(usr.Id, localeBusinessHoursMap.get('Default'));
                }
            }

            for (Opportunity opp : processedOpportunitiesList) {
                if(opp.RecordTypeId == oppRecordTypes.get('Russian_Sales').getRecordTypeId()){
                    opp.Opportunity_Processing_Time__c = (Decimal.valueOf(BusinessHours.diff(businessHoursForUsersMap.get(opp.OwnerId).Id, opp.Last_Owner_Change_Date_RUS__c, system.now()) / 1000) / 60).setScale(2);
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : sendWelcomeEmailShellCardPlusTravel(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : send email to Client for Shell Card Plus Travel product
    *  CreatedDate     : 25/11/2019
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendWelcomeEmailShellCardPlusTravel(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
        Set<Id> oppIds = new Set<Id>();

        for (Opportunity opp : newMap.values()) {
            if(opp.RecordTypeId == oppRecordTypes.get('Shell_Universal_Card').getRecordTypeId() && opp.StageName == 'Closed Won' && (oldMap.get(opp.Id).StageName != 'Closed Won')){
                oppIds.add(opp.Id);
            }
        }

        if(!oppIds.isEmpty()){
            List<OrgWideEmailAddress> owaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu' LIMIT 1];
            List<Opportunity> opportunityList = [SELECT Id, Owner.Name, Owner.Email FROM Opportunity WHERE Id IN:oppIds];
            String contId = [SELECT ContactID FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityID = :oppIds LIMIT 1][0].ContactId;

            if (contId != null) {
                String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Shell_Card_Plus_Travel_Welcome_Email'][0].Id;
                String orgEmailAddressId = owaList.get(0).Id;
                List<String> BccTo = new List<String>();
                BccTo.add(opportunityList.get(0).Owner.Email);

                for (Opportunity oppId :opportunityList) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId);
                    mail.setTargetObjectId(contId);
                    mail.setOrgWideEmailAddressId(orgEmailAddressId);
                    mail.setReplyTo(oppId.Owner.Email);
                    mail.setBccAddresses(BccTo);
                    mail.setWhatId(oppId.Id);
                    mail.setSaveAsActivity(true);
                    mail.setCharset('UTF-8');
                    allEmails.add(mail);
                }
            }
        }

        if (!allEmails.isEmpty()) {
            Messaging.sendEmail(allEmails);
        }
    }


    /*******************************************************************************
    *  Name            : startFieldsCheck
    *  Summary         : check fields which available for modify in START PROCESS
    *  CreatedDate     : 25/11/2019
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void startFieldsCheck(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Opportunity> listForCheck = new List<Opportunity>();
        for (Opportunity opp : newMap.values()) {
            if (opp.IsClosed && opp.IsWon && oldMap.get(opp.Id).IsClosed && oldMap.get(opp.Id).IsWon) {
                if (opp.RecordTypeId == oppRecordTypes.get('Lotos').getRecordTypeId()) {
                    listForCheck.add(opp);
                }
            }
        }

        if (listForCheck.size() != 0) {
            Map<String, General_Integration_Settings__c> settings = General_Integration_Settings__c.getAll();
            Map<Id, Profile> sysAdminProfilesByIds = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name IN ('API Only', 'System Administrator')]);
            if(!sysAdminProfilesByIds.keySet().contains(UserInfo.getProfileId())){
                Set<String> setFields = Schema.SObjectType.Opportunity.fields.getMap().keySet();
                for(Schema.FieldSetMember field : GlobalUtils.getFieldSetMembers(Schema.Opportunity.sObjectType, 'Start_Fields')){
                    setFields.remove(String.valueOf(field.getSObjectField()).toLowerCase());
                }
                for(Schema.FieldSetMember field : GlobalUtils.getFieldSetMembers(Schema.Opportunity.sObjectType, 'Start_Fields_Other')){
                    setFields.remove(String.valueOf(field.getSObjectField()).toLowerCase());
                }
                for(Schema.FieldSetMember field : GlobalUtils.getFieldSetMembers(Schema.Opportunity.sObjectType, 'Start_Fields_read_only')){
                    setFields.remove(String.valueOf(field.getSObjectField()).toLowerCase());
                }
                for (Opportunity opp : listForCheck) {
                    String changedField = '';
                    for (String fieldName : setFields) {
                        if (opp.get(fieldName) != oldMap.get(opp.Id).get(fieldName)) {
                            changedField = fieldName;
                            break;
                        }
                    }
                    if (changedField != '') {
                        opp.addError(System.Label.Start_Process_fields_editing_is_prohibited + changedField);
                    }
                }
            }
        }
    }

    public static String getPlainEmail(Id oppId, Id userId, Id templateId){
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, userId, oppId);
        return email.plainTextBody;
    }

    public static String getEmailPreview(Id oppId, Id userId, Id templateId){
        Messaging.SingleEmailMessage email =
                Messaging.renderStoredEmailTemplate(templateId, userId, oppId);
        return email.htmlBody;
    }

    public static String getSubject(Id oppId, Id userId, Id templateId){
        String subject =
                Messaging.renderStoredEmailTemplate(templateId, userId, oppId).getSubject();
        return subject;
    }

    /*******************************************************************************
    *  Name            : sendCCSBOClosedWonNotification(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : send email to CZ/SK BO for CCS orders from Merlin
    *  CreatedDate     : 13/1/2020
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendCCSBOClosedWonNotification(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Opportunity> OMVOppties = new Map<Id, Opportunity>();

        for (Opportunity opp : newMap.values()) {
            for (CCS_Back_Office_Custom_Settings__c field :CCS_Back_Office_Custom_Settings__c.getAll().values()) {
                if(opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() && opp.StageName == 'Closed Won' && (oldMap.get(opp.Id).StageName != 'Closed Won')){
                    if(opp.Product_Solicited__c == 'OMV'){
                        OMVOppties.put(opp.Id, opp);
                    }else{
                        oppIds.add(opp.Id);
                    }
                }
            }
        }

        if(OMVOppties.size() > 0){
            List<Opportunity> opptiesToUpdate = [SELECT Id FROM Opportunity WHERE Id IN :OMVOppties.keySet()];
            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Closed_Won_OMV_BO_notification'][0].Id;
            String userId = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC'][0].Id;

            List<OrgWideEmailAddress> owaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu' LIMIT 1];
            String orgEmailAddressId = owaList.get(0).Id;
            List<CCS_Back_Office_Custom_Settings__c> boEmails = [SELECT Email__c FROM CCS_Back_Office_Custom_Settings__c WHERE Product__c = 'OMV'];
            String[] emails = new String[]{};
            for(CCS_Back_Office_Custom_Settings__c bo : boEmails){
                emails.add(bo.Email__c);
            }

            for(Id oppId : OMVOppties.keySet()){
                Opportunity o = OMVOppties.get(oppId);

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emails);
                mail.setSubject(getSubject(o.Id, userId, templateId));
                mail.setPlainTextBody(getPlainEmail(o.Id, userId, templateId));
                mail.htmlBody = getEmailPreview(o.Id, userId, templateId);

                mail.setOrgWideEmailAddressId(orgEmailAddressId);
                mail.setWhatId(o.Id);
                mail.setSaveAsActivity(true);
                mail.setCharset('UTF-8');
                allEmails.add(mail);
            }

            for(Opportunity o : opptiesToUpdate){
                o.Starts_Status__c = '0. Request received';
            }
            update opptiesToUpdate;
        }

        if(!oppIds.isEmpty()){
            List<CCS_Order__c> ccsOrder = [SELECT Id, Product__c, Product_Country__c FROM CCS_Order__c WHERE Opportunity__c IN :oppIds];
            for (CCS_Order__c ccsO :ccsOrder) {
                for (CCS_Back_Office_Custom_Settings__c field :CCS_Back_Office_Custom_Settings__c.getAll().values()) {
                    if(ccsO.Product__c == field.Product__c && ccsO.Product_Country__c == field.Country__c){
                        List<OrgWideEmailAddress> owaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu' LIMIT 1];
                        List<Opportunity> opportunityList = [SELECT Id, Owner.Name, Owner.Email, Starts_Status__c, Registered_Country__c, Product_Solicited__c FROM Opportunity WHERE Id IN:oppIds];
                        String userId = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC'][0].Id;
                        String rc = [SELECT Registered_Country__c FROM Opportunity WHERE Id = :oppIds][0].Registered_Country__c;
                        String userModified = [SELECT Merlin_Last_Modified_By__c FROM Opportunity WHERE Id = :oppIds][0].Merlin_Last_Modified_By__c;

                        if(!opportunityList.isEmpty()){
                            for(Opportunity oppN :opportunityList){
                                oppN.Starts_Status__c = '0. Request received';
                                lstOpportunity.add(oppN);
                            }
                        }

                        if (!lstOpportunity.isEmpty()) {
                            update lstOpportunity;
                        }

                        if(ccsOrder.size() > 0) {
                            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Closed_Won_BO_notification'][0].Id;
                            String orgEmailAddressId = owaList.get(0).Id;
                            for (Opportunity oppId :opportunityList) {
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if (userModified != null) {
                                    mail.setToAddresses(new String[]{
                                            userModified
                                    });

                                    for (CCS_Back_Office_Custom_Settings__c emBO : CCS_Back_Office_Custom_Settings__c.getAll().values()) {
                                        if (ccsO.Product_Country__c == emBO.Country__c && ccsO.Product__c == emBO.Product__c) {
                                            String ccAddress = emBO.Email__c;
                                            mail.setCcAddresses(new String[]{
                                                    ccAddress
                                            });
                                        }
                                    }
                                } else {
                                    for (CCS_Back_Office_Custom_Settings__c emBO : CCS_Back_Office_Custom_Settings__c.getAll().values()) {
                                        if (ccsO.Product_Country__c == emBO.Country__c && ccsO.Product__c == emBO.Product__c) {
                                            String toAddress = emBO.Email__c;
                                            mail.setToAddresses(new String[]{
                                                    toAddress
                                            });
                                        }
                                    }
                                }

                                mail.setSubject(getSubject(oppId.Id, userId, templateId));
                                mail.setPlainTextBody(getPlainEmail(oppId.Id, userId, templateId));
                                mail.htmlBody = getEmailPreview(oppId.Id, userId, templateId);

                                mail.setOrgWideEmailAddressId(orgEmailAddressId);
                                mail.setWhatId(oppId.Id);
                                mail.setSaveAsActivity(true);
                                mail.setCharset('UTF-8');
                                allEmails.add(mail);
                            }
                        }
                    }
                }
            }
        }

        if (!allEmails.isEmpty()) {
            try{
                Messaging.sendEmail(allEmails);
            }catch(Exception ex){

            }

        }
    }

    /*******************************************************************************
    *  Name            : ccsOpportunityTypeGFNCheck(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : enforce user checks Opportunity Type and Starts: GFN
    *  CreatedDate     : 13/1/2020
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    /*public static void ccsOpportunityTypeGFNCheck(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');

        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
        Boolean check = false;

        for (Opportunity opp : newMap.values()) {
               if(opp.RecordTypeId == ccsOppoRecId && opp.StageName == 'Closed Won' && (opp.Starts_Status__c == '0.9b Ready for Robot Setup' && (oldMap.get(opp.Id).Starts_Status__c != '0.9b Ready for Robot Setup') || opp.Starts_Status__c == '0.9a Ready for Manual Setup' && (oldMap.get(opp.Id).Starts_Status__c != '0.9a Ready for Manual Setup'))){
                    if(opp.CCS_GFN_Type_Check__c == false){
                        oppIds.add(opp.Id);
                        opp.addError(Label.CCSPopulateGFN, true);
                    }
                }
        }

        if(!oppIds.isEmpty()){
            List<Opportunity> opportunityList = [SELECT Id, CCS_GFN_Type_Check__c FROM Opportunity WHERE Id IN:oppIds];

            if(!opportunityList.isEmpty()){
                for(Opportunity oppN :opportunityList){
                    oppN.CCS_GFN_Type_Check__c = true;
                    lstOpportunity.add(oppN);
                }
            }
        }

        if (!lstOpportunity.isEmpty()) {
            update lstOpportunity;
        }
   }*/

    /*******************************************************************************
    *  Name            : ccsOrderRobot(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : send email with CCS Order XLS summary to robot
    *  CreatedDate     : 13/1/2020
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void ccsOrderRobot(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : newMap.values()) {
            if(opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() && opp.StageName == 'Closed Won' && opp.Starts_Status__c == '0.9b Ready for Robot Setup' && (oldMap.get(opp.Id).Starts_Status__c != '0.9b Ready for Robot Setup') && opp.Number_of_CCS_Order__c != 0){
                if(opp.Type == 'Existing GFN' && opp.CCS_GFN_number__c == ''){
                    opp.addError(Label.CCSPopulateGFN, false);
                }
                else {
                    oppIds.add(opp.Id);
                }
            }
        }

        if(!oppIds.isEmpty()){
            for(Id oppId : oppIds){
                sendEmailToRobot(oppId);
            }
        }
    }
    @future (callout = true)
    public static void sendEmailToRobot(Id oppId){
        Blob refBlob;
        if(Test.isRunningTest()) {
            refBlob = blob.valueOf('Unit.Test');
        } else {
            refBlob = new PageReference('/APEX/ExcelRobotCCS?Id='+oppId).getContent();
        }

        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Closed_Won_Robot' LIMIT 1];

        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(oppId+'.csv');
        efa.setBody(refBlob);


        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(template.Id);
        String ProductCountry = [SELECT Product_Country__c FROM CCS_Order__c WHERE Opportunity__c = :oppId LIMIT 1].Product_Country__c;
        for (CCS_Robot_Emails__c mc :CCS_Robot_Emails__c.getAll().values()){
            if(ProductCountry == mc.Name){
                String toAddress = mc.Email__c;
                msg.setToAddresses(new String[]{toAddress});
            }
        }
        String userId = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC'][0].Id;
        msg.setSubject(getSubject(oppId, userId, template.Id));
        msg.setPlainTextBody(getPlainEmail(oppId, userId, template.Id));
        msg.htmlBody = getEmailPreview(oppId, userId, template.Id);
        msg.setWhatId(oppId);
        msg.saveAsActivity = false;

        msg.setFileAttachments(new Messaging.EmailFileattachment[]{efa});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }

    /*******************************************************************************
    *  Name            : sendWelcomeEmailLotos(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : send email to Client for Lotos product
    *  CreatedDate     : 20/01/2020
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendWelcomeEmailLotos(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
        Set<Id> oppIds = new Set<Id>();

        for (Opportunity opp : newMap.values()) {
            if(opp.RecordTypeId == oppRecordTypes.get('Lotos').getRecordTypeId() &&
                opp.StageName == 'Closed Won' &&
                (oldMap.get(opp.Id).StageName != 'Closed Won') &&
                    UserInfo.getName() != 'E2E Site Guest User') {
                oppIds.add(opp.Id);
            }
        }

        if(!oppIds.isEmpty()){
            List<OrgWideEmailAddress> owaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu' LIMIT 1];
            List<Opportunity> opportunityList = [SELECT Id, Owner.Name, Owner.Email FROM Opportunity WHERE Id IN:oppIds];
            String contId = [SELECT ContactID FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityID = :oppIds LIMIT 1][0].ContactId;

            if (contId != null) {
                String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Lotos_Welcome_Email'][0].Id;
                String orgEmailAddressId = owaList.get(0).Id;
                List<String> BccTo = new List<String>();
                BccTo.add(opportunityList.get(0).Owner.Email);

                for (Opportunity oppId :opportunityList) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId);
                    mail.setTargetObjectId(contId);
                    mail.setOrgWideEmailAddressId(orgEmailAddressId);
                    mail.setReplyTo(oppId.Owner.Email);
                    mail.setBccAddresses(BccTo);
                    mail.setWhatId(oppId.Id);
                    mail.setSaveAsActivity(true);
                    mail.setCharset('UTF-8');
                    allEmails.add(mail);
                }
            }
        }

        if (!allEmails.isEmpty()) {
            Messaging.sendEmail(allEmails);
        }
    }

    /*******************************************************************************
    *  Name            : ccsOpportunityLockOrder()
    *  Summary         : Lock CCS Opportunities with CCS Order under them.
    *  CreatedDate     : 07/06/2021
    *  ModifiedDate    : ---
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/

    public static void ccsOpportunityLockOrder(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        String RecordTime = string.valueOf(datetime.now().getTime());
        String userId = UserInfo.getUserId();
        List<CCS_Order__c> lstCCSOrder = new List<CCS_Order__c>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Profile> allowedProfiles = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name IN ('API Only', 'System Administrator', 'CCS System Administrator', 'CCS API System Admin', 'CCS Service Agent', 'CCS Service Manager')]);

        Log__e[] logs = new Log__e[0];

        for (Opportunity opp :newMap.values()) {
            if (opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() &&
                    !allowedProfiles.keySet().contains(UserInfo.getProfileId()) &&
                    !(opp.Number_of_CCS_Order__c == 0 || opp.Number_of_CCS_Order__c == null) &&
                    (opp.StageName != 'Closed Lost' || oldMap.get(opp.Id).StageName == 'Closed Lost') &&
                    opp.isClosed == false) {
                if (opp.Number_of_open_tasks__c != oldMap.get(opp.Id).Number_of_open_tasks__c ||
                        opp.Open_Task__c != oldMap.get(opp.Id).Open_Task__c ||
                        opp.Primary_Contact_Phone__c != oldMap.get(opp.Id).Primary_Contact_Phone__c ||
                        opp.CloseDate != oldMap.get(opp.Id).CloseDate) {
                } else {
                    logs.add(new Log__e(LogType__c = 'CCS_Opportunity_Locked', RecordDateTime__c = RecordTime, Subject__c = 'ERROR updating CCS Opportunity with CCS Order', ReferenceId__c = opp.Id, LogLevel__c = 'ERROR', UserReference__c = userId));
                    opp.addError(Label.CCS_Order_driving_Opportunity);
                }
            }
            oppIds.add(opp.Id);
        }

        if(!oppIds.isEmpty()) {
            List<CCS_Order__c> lstCCSOrderOpp = [SELECT Id, Order_Stage__c, Update_From_Opportunity__c FROM CCS_Order__c WHERE Opportunity__c = :oppIds LIMIT 1];
            if (!lstCCSOrderOpp.isEmpty()) {
                for (Opportunity opp :newMap.values()){
                    if (opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() && opp.StageName == 'Closed Lost' && oldMap.get(opp.Id).StageName != 'Closed Lost' && !(opp.Number_of_CCS_Order__c == 0 || opp.Number_of_CCS_Order__c == null)) {
                        for (CCS_Order__c ccsO :lstCCSOrderOpp) {
                            ccsO.Order_Stage__c = 'Stornováno';
                            ccsO.Update_From_Opportunity__c = ccsO.Update_From_Opportunity__c + 1;
                            lstCCSOrder.add(ccsO);
                        }
                    }
                }
            }
        }
        if (!lstCCSOrder.isEmpty()) {
            update lstCCSOrder;
        }

        EventBus.publish(logs);
    }

    /*******************************************************************************
    *  Name            : CheckOzNumberUpdateOwner()
    *  Summary         : Check OZ number with data in custom settings Oz_number_checker__c .
    *  CreatedDate     : 23/03/2020
    *  ModifiedDate    : 04/09/2020
    *  Parameters      : Map<Id, Opportunity> oldMap, List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void CheckOzNumberUpdateOwner(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> ccsOwnerId = new Set<Id>();
        //Map<String,Oz_number_checker__c> checkSettings = Oz_number_checker__c.getAll();

        if (oldMap != null) {
            for (Opportunity opp : newList) {
                if(opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() && opp.OZ_Number__c != null && (oldMap.get(opp.Id).OZ_Number__c != opp.OZ_Number__c)){
                    oppIds.add(opp.Id);
                }
            }
            if(!oppIds.isEmpty()){
                List<Opportunity> lstOpportunitySelected = [SELECT Id, OwnerId, OZ_Number__c FROM Opportunity WHERE Id IN:oppIds];

                if(!lstOpportunitySelected.isEmpty()){

                    for(Opportunity oppN :lstOpportunitySelected){

                        if (oppN.OZ_Number__c != null) {

                            for (Oz_number_checker__c mc : Oz_number_checker__c.getAll().values()){
                                if (oppN.OZ_Number__c == mc.OZ_Number__c) {
                                    ccsOwnerId.add(mc.UserId__c);
                                    List<User> lstUserActive = [SELECT Id, IsActive FROM User WHERE Id IN :ccsOwnerId AND IsActive = true];
                                    if (lstUserActive.size() != 0) {
                                        oppN.OwnerId = mc.UserId__c;
                                        lstOpportunity.add(oppN);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (!lstOpportunity.isEmpty()) {
                update lstOpportunity;
            }
        }
        else {
            for (Opportunity opp : newList) {
                if(opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() && opp.OZ_Number__c != null ){
                    for (Oz_number_checker__c mc : Oz_number_checker__c.getAll().values()){
                        if (opp.OZ_Number__c == mc.OZ_Number__c) {
                            ccsOwnerId.add(mc.UserId__c);
                            List<User> lstUserActive = [SELECT Id, IsActive FROM User WHERE Id IN :ccsOwnerId AND IsActive = true];
                            if (lstUserActive.size() != 0) {
                                opp.OwnerId = mc.UserId__c;
                            }
                        }
                    }
                }
            }
        }

    }


    /*******************************************************************************
    *  Summary         : Check changes of non-fuel exposure in processed opportunity.
    *  Created         : 05/05/2020
    *  Parameters      : oldOpportunitiesMap - old opportunities values,
                         newOpportunitiesList - new opportunity values
    *  Returns         : -
    ******************************************************************************/
    public static void checkNonFuelExposureChanges(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList) {
        Boolean isCheck = false;
        for (Opportunity opportunity : newOpportunitiesList) {
            if ((oppRecordTypes.get('Euroshell').getRecordTypeId() == opportunity.RecordTypeId || oppRecordTypes.get('Euroshell_Starts').getRecordTypeId() == opportunity.RecordTypeId) &&
                    oldOpportunitiesMap.get(opportunity.Id).Non_fuel_exposure__c != opportunity.Non_fuel_exposure__c &&
                    (opportunity.bearbeitet_von__c == 'Autoprocessed by Sales' || opportunity.bearbeitet_von__c == 'Autoprocessed by E2E')) {
                isCheck = true;
                break;
            }
        }

        if (isCheck) {
            String userProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            if (CF_Non_fuel_Exposure_Profile__c.getInstance(userProfileName) != null) {
                for (Opportunity opportunity : newOpportunitiesList) {
                    if (oldOpportunitiesMap.get(opportunity.Id).Non_fuel_exposure__c != opportunity.Non_fuel_exposure__c) {
                        if (opportunity.bearbeitet_von__c == 'Autoprocessed by Sales' && opportunity.StageName != 'Pending Sales – Deposit') {
                            opportunity.addError('Your Opportunity has already received a Credit Decision or is in the ongoing Manual Review with the Credit Team.');
                        }
                        else if (opportunity.bearbeitet_von__c == 'Autoprocessed by E2E' ||
                                opportunity.bearbeitet_von__c == 'Autoprocessed by Sales' && opportunity.StageName == 'Pending Sales – Deposit') {
                            opportunity.Zahlungsziel_Credit__c = null;
                            opportunity.Rechnungsperiode__c = null;
                            opportunity.CF_Credit_Limit__c = null;
                            opportunity.Credit_check_date__c = null;
                            opportunity.bearbeitet_von__c = null;
                            opportunity.Kredit_Entscheidung__c = null;
                            opportunity.Max_Credit_Limit__c = null;
                            opportunity.Security_To_Pay__c = null;
                            opportunity.Security_Amount_To_Pay__c = null;
                            opportunity.Security_level_H_he_der_Sicherheit__c = null;
                            opportunity.Billing_Period_by_Sales__c = false;
                            opportunity.StageName = 'Prospecting';
                            opportunity.CF_Stage__c = 'Report generated';
                            opportunity.Pending_Deposit_by_CF__c = false;
                            if (opportunity.Relaunch_CF__c == null) opportunity.Relaunch_CF__c = 0;
                            opportunity.Relaunch_CF__c ++;
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Summary         : Check if CCS Opportunity isClosed = true and set CloseDate to TODAY on insert.
    *  Created         : 03/07/2020
    *  Parameters      : newMap - list of new Opportunities
    *  Returns         : -
    ******************************************************************************/

    public static void setCloseDateCCS(List<Opportunity> newList) {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Set<String> OpportunityId = new Set<String>();

        for (Opportunity opp :newList) {
            if(opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() && opp.IsClosed == true && opp.CloseDate > Date.today()){
                OpportunityId.add(opp.Id);
            }
        }

        if(!OpportunityId.isEmpty()) {
            List<Opportunity> lstOpportunitySelected = [SELECT Id FROM Opportunity WHERE Id IN:OpportunityId];

            if(!lstOpportunitySelected.isEmpty()) {
                for (Opportunity opp :lstOpportunitySelected) {
                    opp.CloseDate = Date.today();
                    lstOpportunity.add(opp);
                }
            }
            if (!lstOpportunity.isEmpty()) {
                update lstOpportunity;
            }
        }
    }

    /*******************************************************************************
     *  Summary         : set ESI and Registered Address from Account
     *  Created         : 30/06/2020 by Ilya Ivonin
     *  Parameters      : Lead oldLead, Lead newLead
     *  Returns         : -
    ******************************************************************************/
    public static void setAccountHomeStation(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Set<Id> homeStationIds = new Set<Id>();
        for(Opportunity opp : newMap.values()) {
            if (opp.Account_Home_Station__c != oldMap.get(opp.id).Account_Home_Station__c) {
                homeStationIds.add(opp.Account_Home_Station__c);
            }
        }
        if(homeStationIds.size() != 0){
            Map<Id, Account> homeStationAccounts = new Map<Id, Account>([
                    SELECT Id, ESI__c, BillingCity, BillingStreet,BillingPostalCode
                    FROM Account
                    WHERE Id in :homeStationIds
            ]);
            for(Opportunity opp : newMap.values()) {
                if (opp.Account_Home_Station__c != oldMap.get(opp.id).Account_Home_Station__c) {
                    if (opp.Account_Home_Station__c != null) {
                        opp.ESI__c = homeStationAccounts.get(opp.Account_Home_Station__c).ESI__c;
                        opp.Home_Station__c =
                                GlobalUtils.blankStringIfNull(homeStationAccounts.get(opp.Account_Home_Station__c).BillingCity) + ' ' +
                                        GlobalUtils.blankStringIfNull(homeStationAccounts.get(opp.Account_Home_Station__c).BillingStreet) + ' ' +
                                        GlobalUtils.blankStringIfNull(homeStationAccounts.get(opp.Account_Home_Station__c).BillingPostalCode);
                    } else {
                        opp.ESI__c = '';
                        opp.Home_Station__c = '';
                    }
                }
            }
        }
    }


    /*******************************************************************************
     *  Summary         : check if credit can approve opportunity
     *  Created         : 26/10/2020
     *  Parameters      : oldMap - old opportunities map,
                          newMap - new opportunities map
     *  Returns         : -
    ******************************************************************************/
    public static void checkCreditToApproveOpportunity(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> closedOpportunitiesIdsSet = new Set<Id>();
        for (Opportunity opportunity : newMap.values()) {
            if (opportunity.StageName != oldMap.get(opportunity.Id).StageName && (opportunity.StageName == 'Closed Won' ||
                    opportunity.StageName == 'CreditCheck abgelehnt')) {
                closedOpportunitiesIdsSet.add(opportunity.Id);
            }
        }

        if (! closedOpportunitiesIdsSet.isEmpty()) {
            Approval_Process_Users__c approvalProcessUsers = Approval_Process_Users__c.getInstance();
            if (approvalProcessUsers.Id != null) {
                List<ProcessInstance> processInstances = [
                        SELECT Status, TargetObjectId
                        FROM ProcessInstance
                        WHERE TargetObjectId IN :closedOpportunitiesIdsSet
                        ORDER BY CreatedDate DESC
                ];

                Map<Id, ProcessInstance> opportunityToApprovalMap = new Map<Id, ProcessInstance>();
                for (ProcessInstance approval : processInstances) {
                    if (! opportunityToApprovalMap.containsKey(approval.TargetObjectId)) {
                        opportunityToApprovalMap.put(approval.TargetObjectId, approval);
                    }
                }

                Double limitToApprove;
                for (Opportunity opportunity : newMap.values()) {
                    if (approvalProcessUsers.Unlimited__c == false) {
                        if (opportunityToApprovalMap.containsKey(opportunity.Id) && opportunityToApprovalMap.get(opportunity.Id).Status == 'Approved') {
                            if (opportunity.CurrencyIsoCode == 'EUR') {
                                limitToApprove = approvalProcessUsers.EUR__c;
                            }
                            else if (opportunity.CurrencyIsoCode == 'PLN') {
                                limitToApprove = approvalProcessUsers.PLN__c;
                            }
                            else if (opportunity.CurrencyIsoCode == 'HUF') {
                                limitToApprove = approvalProcessUsers.HUF__c;
                            }
                            else if (opportunity.CurrencyIsoCode == 'CZK') {
                                limitToApprove = approvalProcessUsers.CZK__c;
                            }
                            else if (opportunity.CurrencyIsoCode == 'CHF') {
                                limitToApprove = approvalProcessUsers.CHF__c;
                            }

                            Decimal amountToCompare;
                            if ((opportunity.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || opportunity.Derzeitige_Zahlungsmethode__c == 'Barzahlung') &&
                                    ! String.isEmpty(opportunity.Garantie__c)) {
                                if (opportunity.Garantie_other__c != null) {
                                    amountToCompare = opportunity.Exposure__c - opportunity.Garantie_other__c;
                                }
                                else {
                                    opportunity.addError('Fill in the security amount');
                                    break;
                                }
                            }
                            else {
                                amountToCompare = opportunity.Credit_Limit__c;
                            }

                            if (amountToCompare > limitToApprove) {
                                opportunity.addError('Limit is too high, please ask a relevant profile to endorse this item.');
                            }
                        }
                    }

                    if (opportunityToApprovalMap.get(opportunity.Id).Status == 'Approved' || opportunityToApprovalMap.get(opportunity.Id).Status == 'Rejected') {
                        opportunity.bearbeitet_von__c = UserInfo.getName();
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateCCSOpportunity()
    *  Summary         : Set CCS Opportunity fields before insert and before update. Re-usable/expandable method.
    *  CreatedDate     : 14/12/2020
    *  ModifiedDate    : 15/03/2021
    *  Parameters      : Map<Id, Opportunity> oldMap, List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void updateCCSOpportunity(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        if (oldMap == null) {
            // before insert
            for (Opportunity opp : newList) {
                if (opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId()) {
                    if (opp.Product_Solicited__c != 'OMV' && opp.IsClosed == false){
                        opp.Eco_Fee__c = false;
                    }
                }
            }
        } else {
            // before update
            for (Opportunity opp : newList) {
                if (opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() && opp.Product_Solicited__c == 'OMV' && oldMap.get(opp.Id).Product_Solicited__c != 'OMV' && opp.Eco_Fee__c == false && opp.IsClosed == false) {
                    opp.Eco_Fee__c = true;
                }
                else if (opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() && opp.Product_Solicited__c != 'OMV' && oldMap.get(opp.Id).Product_Solicited__c == 'OMV' && opp.Eco_Fee__c == true && opp.IsClosed == false) {
                    opp.Eco_Fee__c = false;
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : checkCCSOpportunityOwner()
    *  Summary         : Check if Opportunity Owner has changed and then modify related CCS Order.
    *  CreatedDate     : 07/01/2020
    *  ModifiedDate    :
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void checkCCSOpportunityOwner(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        List<CCS_Order__c> lstCCSOrder = new List<CCS_Order__c>();
        Set<Id> oppIds = new Set<Id>();

        for (Opportunity opp :newList) {
            if (opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() && (oldMap.get(opp.Id).OwnerId != opp.OwnerId) && opp.Number_of_CCS_Order__c != 0) {
                oppIds.add(opp.Id);
            }
        }
        if (!oppIds.isEmpty()) {
            List<Opportunity> lstOpportunitySelected = [SELECT Id, OwnerId, OZ_Number__c FROM Opportunity WHERE Id IN:oppIds];
            List<CCS_Order__c> lstCCSOrderSelected = [SELECT Id, OwnerId, OZ_Number__c FROM CCS_Order__c WHERE Opportunity__c IN:oppIds];

            if (!lstOpportunitySelected.isEmpty()) {
                for (Opportunity oppN :lstOpportunitySelected) {
                    for (CCS_Order__c ccsOrderN :lstCCSOrderSelected) {
                        ccsOrderN.OwnerId = oppN.OwnerId;
                        lstCCSOrder.add(ccsOrderN);
                    }
                }
            }
        }
        if (!lstCCSOrder.isEmpty()) {
            update lstCCSOrder;
        }
    }


    /*******************************************************************************
     *  Summary         : calculate Total Consumption or Amount fields according to fuel prices
     *  Created         : 01/02/2021
     *  Parameters      : oldOpportunities - old opportunities map,
                          newOpportunities - new opportunities list
     *  Returns         : -
    ******************************************************************************/
    public static void calculateTotalConsumptionBasedOnAmount(Map<Id, Opportunity> oldOpportunities, List<Opportunity> newOpportunities) {
        for (Opportunity opportunity : newOpportunities) {
            if ((oppRecordTypes.get('Euroshell').getRecordTypeId() == opportunity.RecordTypeId ||
                    oppRecordTypes.get('Euroshell_Starts').getRecordTypeId() == opportunity.RecordTypeId ||
                    oppRecordTypes.get('Lotos').getRecordTypeId() == opportunity.RecordTypeId) && opportunity.Registered_Country__c != null) {
                Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance(opportunity.Registered_Country__c);
                Decimal fuelPriceIndex = (fuelPrice == null ? 1.4 : fuelPrice.Index__c);

                if (oldOpportunities != null) {
                    if (opportunity.Total_consumption_l_month__c != oldOpportunities.get(opportunity.Id).Total_consumption_l_month__c) {
                        opportunity.Amount__c = (opportunity.Total_consumption_l_month__c * fuelPriceIndex).setScale(0);
                    }
                    else if (opportunity.Amount__c != oldOpportunities.get(opportunity.Id).Amount__c) {
                        opportunity.Total_consumption_l_month__c = (opportunity.Amount__c / fuelPriceIndex).setScale(0);
                    }
                }
                else {
                    if (opportunity.Total_consumption_l_month__c != null) {
                        opportunity.Amount__c = (opportunity.Total_consumption_l_month__c * fuelPriceIndex).setScale(0);
                    }
                    else if (opportunity.Amount__c != null) {
                        opportunity.Total_consumption_l_month__c = (opportunity.Amount__c / fuelPriceIndex).setScale(0);
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : lockingClosedOpportunities
    *  Summary         : All Opportunities that are IsClosed = true will be locked for all users, except certain few that will be adjusted via Custom Settings.
    *  CreatedDate     : 11/03/2021
    *  ModifiedDate    :
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void lockingClosedOpportunities(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        String userName = UserInfo.getUserName();
        String userId = UserInfo.getUserId();
        String profileId = UserInfo.getProfileId();
        String roleId = UserInfo.getUserRoleId();

        Log__e[] logs = new Log__e[0];

        Set<String> oppFields = new Set<String>();
        List<ClosedOpportunityManagement__c> comList = [SELECT Name, Active__c, Opportunity_Record_Type_Develop_Name__c, Exception_URP_Developer_Name__c, Metadata_Type_URP__c, Exception_Field_API_Name__c, Excluded_Field__c FROM ClosedOpportunityManagement__c];

        Set<String> excludedFields = new Set<String>();
        for(ClosedOpportunityManagement__c com : comList){
            if(com.Excluded_Field__c == true && com.Active__c){
                excludedFields.add(com.Exception_Field_API_Name__c.toLowerCase());
            }
        }

        Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
        for(String fieldName : M.keyset())
        {
            fieldName = fieldName.toLowerCase();
            if(!excludedFields.contains(fieldName)){
                Schema.SObjectField field = M.get(fieldName);
                //exclude formula fields - isCalculated = formula field
                if(!field.getDescribe().isCalculated()){
                    oppFields.add(fieldName);
                }
            }
        }

        for (Id oppId : newMap.keySet()) {
            Boolean somethingChanged = false;
            Opportunity opp = newMap.get(oppId);
            Set<String> rectypes = new Set<String>();
            //only for closed oppties - not on changed on closed
            if((opp.IsClosed && oldMap.get(oppId).IsClosed) || oldMap.get(oppId).IsClosed){
                String recordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getDeveloperName();

                //Set of ExceptionFields
                Set<String> exceptionFields = new Set<String>();

                //Set of full access URP
                Set<String> fullAccessProfileIds = new Set<String>();
                Set<String> fullAccessRoleIds = new Set<String>();
                Set<String> fullAccessUserNames = new Set<String>();

                for(ClosedOpportunityManagement__c com : comList){
                    if(com.Active__c){
                        if(!String.isEmpty(com.Opportunity_Record_Type_Develop_Name__c)){
                            if(com.Opportunity_Record_Type_Develop_Name__c.contains(';')){
                                for(String f : com.Opportunity_Record_Type_Develop_Name__c.replaceAll( '\\s+', '').split(';')){
                                    rectypes.add(f);
                                }
                            }else{
                                rectypes.add(com.Opportunity_Record_Type_Develop_Name__c);
                            }
                        }

                        if(rectypes.contains(recordTypeName)){
                            //Exceptions for Exact opportunity record types
                            if(com.Exception_Field_API_Name__c != null && com.Metadata_Type_URP__c == null){
                                exceptionFields.add(com.Exception_Field_API_Name__c.toLowerCase());

                            }else{
                                if(com.Metadata_Type_URP__c == 'Profile' && String.isEmpty(com.Exception_Field_API_Name__c)){
                                    fullAccessProfileIds.add(com.Exception_URP_Developer_Name__c);
                                }else if(com.Metadata_Type_URP__c == 'Role' && String.isEmpty(com.Exception_Field_API_Name__c)){
                                    fullAccessRoleIds.add(com.Exception_URP_Developer_Name__c);
                                }else if(com.Metadata_Type_URP__c == 'User' && String.isEmpty(com.Exception_Field_API_Name__c)){
                                    fullAccessUserNames.add(com.Exception_URP_Developer_Name__c);
                                }
                            }
                        }

                        if(rectypes.contains(recordTypeName)){
                            for(String f : oppFields){
                                if(newMap.get(oppId).get(f) != oldMap.get(oppId).get(f) && !exceptionFields.contains(f.toLowerCase())){
                                    somethingChanged = true;
                                }
                            }
                        }
                        rectypes = new Set<String>();
                    }

                }

                if(somethingChanged){
                    if(fullAccessProfileIds.contains(profileId) || fullAccessRoleIds.contains(roleId) || fullAccessUserNames.contains(userName)){
                        //full access - without any error
                    }else{
                        //opp.addError('ERROR!!!!');

                        Set<String> changedFields = new Set<String>();
                        for(String f : oppFields){
                            if(newMap.get(oppId).get(f) != oldMap.get(oppId).get(f)){
                                //ther has been a change
                                changedFields.add(f.toLowerCase());
                            }
                        }

                        if(changedFields.size() > 0){
                            for(ClosedOpportunityManagement__c com : comList){
                                if(com.Active__c){
                                    if(!String.isEmpty(com.Opportunity_Record_Type_Develop_Name__c)){
                                        if(com.Opportunity_Record_Type_Develop_Name__c.contains(';')){
                                            for(String f : com.Opportunity_Record_Type_Develop_Name__c.replaceAll( '\\s+', '').split(';')){
                                                rectypes.add(f);
                                            }
                                        }else{
                                            rectypes.add(com.Opportunity_Record_Type_Develop_Name__c);
                                        }
                                    }

                                    if(rectypes.contains(recordTypeName)  && !String.isBlank(com.Exception_Field_API_Name__c) && !com.Excluded_Field__c ){
                                        if((com.Exception_URP_Developer_Name__c == profileId || com.Exception_URP_Developer_Name__c == roleId || com.Exception_URP_Developer_Name__c == userName || String.isEmpty(com.Exception_URP_Developer_Name__c)) && changedFields.contains(com.Exception_Field_API_Name__c.toLowerCase())){
                                            changedFields.remove(com.Exception_Field_API_Name__c.toLowerCase());
                                        }
                                    }
                                    rectypes = new Set<String>();
                                }
                            }
                        }

                        if(changedFields.size() > 0){
                            String RecordTime = string.valueOf(datetime.now().getTime());
                            String errMsg = 'ERROR updating Closed Opportunity: '+oppId+'\n User: '+userName+'\n ProfileId: '+profileId+'\n RoleId: '+roleId+'\n Changed fields: \n';
                            for(String f : changedFields){
                                errMsg += f+' : oldValue: '+oldMap.get(oppId).get(f)+' newValue: '+newMap.get(oppId).get(f)+'\n';
                            }

                            //system.debug(errMsg);
                            logs.add(new Log__e(LogType__c='Closed_Opportunity_Management', RecordDateTime__c = RecordTime, Subject__c='ERROR updating Closed Opportunity', Message__c = errMsg, ReferenceId__c=oppId, LogLevel__c='ERROR', UserReference__c=userId));
                            //CCSLog.writeError('BizMachine', 'Monitoring Tag UID is not saved', 'There are no monitoring UID in Custom settings!');
                            opp.addError(Label.Closed_Opportunity_Error);
                        }
                    }
                }
            }
        }
        EventBus.publish(logs);
    }

    /*******************************************************************************
    *  Name            : updateAccountLookup
    *  Summary         : Update Account__c in OpportunityLineItems and Client_Offer_Additional_Service__c when AccountId in opportunity is changed
    *  CreatedDate     : 06/04/2021
    *  ModifiedDate    :
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void updateAccountLookup (Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<String> opportunitiesWithChangedAccountId = new Set<String>();
        for (Opportunity nextNewOpportunity : newMap.values()) {
            Opportunity nextOldOpportunity = oldMap.get(nextNewOpportunity.Id);
            if (nextNewOpportunity.AccountId != nextOldOpportunity.AccountId) {
                opportunitiesWithChangedAccountId.add(nextNewOpportunity.Id);
            }
        }
        if (opportunitiesWithChangedAccountId.isEmpty()) {
            return;
        }
        List<OpportunityLineItem> opportunityLineItemsForUpdate = [
                SELECT  Account__c, OpportunityId
                FROM    OpportunityLineItem
                WHERE   OpportunityId IN : opportunitiesWithChangedAccountId
        ];
        for (OpportunityLineItem nextOpportunityLineItem : opportunityLineItemsForUpdate) {
            nextOpportunityLineItem.Account__c = newMap.get(nextOpportunityLineItem.OpportunityId).AccountId;
        }
        List<Client_Offer_Additional_Service__c> clientOfferAdditionalServicesForUpdate = [
                SELECT  Account__c, Opportunity__c
                FROM    Client_Offer_Additional_Service__c
                WHERE   Opportunity__c IN : opportunitiesWithChangedAccountId
        ];
        for (Client_Offer_Additional_Service__c nextClientOfferAdditionalService : clientOfferAdditionalServicesForUpdate) {
            nextClientOfferAdditionalService.Account__c = newMap.get(nextClientOfferAdditionalService.Opportunity__c).AccountId;
        }
        update opportunityLineItemsForUpdate;
        update clientOfferAdditionalServicesForUpdate;
    }

    /*******************************************************************************
    *  Name            : sendWelcomeEmailOMV(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : Send email to Client for OMV product.
    *  CreatedDate     : 06/04/2021
    *  ModifiedDate    : 10/04/2021
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendWelcomeEmailOMV(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> oppIds = new Set<Id>();

        List<Opportunity> oppties = new List<Opportunity>();
        List<Opportunity> opptiesToUpdate = new List<Opportunity>();

        for (Opportunity opp : newMap.values()) {
            if(opp.RecordTypeId == oppRecordTypes.get('CCS_Opportunity').getRecordTypeId() &&
                    opp.StageName == 'Closed Won' &&
                    (oldMap.get(opp.Id).StageName != 'Closed Won') &&
                    opp.Product_Solicited__c == 'OMV' &&
                    opp.CCS_priobjednavka__c == false) {
                oppIds.add(opp.Id);
                oppties.add(opp);
            }
        }
        if(oppties.size() > 0){
            List<OrgWideEmailAddress> owaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'zakaznicka.podpora@ccs.cz' LIMIT 1];
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

            EmailTemplate et = [SELECT Id,Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName LIKE 'CCS_Welcome_Email_OMV_CZ_LEX%'];
            List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.FileType FROM ContentDocumentLink WHERE LinkedEntityId = :et.Id];

            List<Messaging.EmailFileAttachment> lstEmailAttachments = new List<Messaging.EmailFileAttachment>();
            for(ContentDocumentLink cdl : cdlList){
                blob WOCFbody = cdl.ContentDocument.LatestPublishedVersion.VersionData;
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cdl.ContentDocument.LatestPublishedVersion.Title+'.'+cdl.ContentDocument.LatestPublishedVersion.FileType);
                efa.setBody(WOCFbody);

                lstEmailAttachments.add(efa);
            }

            List<OpportunityContactRole> contactList = [SELECT OpportunityId, ContactId FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityId = :oppIds];
            Map<Id, Id> contactIds = new Map<Id, Id>();
            for(OpportunityContactRole ocr : contactList){
                contactIds.put(ocr.OpportunityId, ocr.ContactId);
            }

            for(Opportunity opp : oppties){
                if(contactIds.containsKey(opp.Id) && !opp.Welcome_Email_Sent_CCS__c){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(et.Id);
                    //mail.setToAddresses(toAddress);
                    mail.setSubject(et.subject);
                    mail.setHTMLBody(et.HtmlValue);
                    mail.setTargetObjectId(contactIds.get(opp.Id));
                    mail.setWhatId(opp.Id);
                    String orgEmailAddressId = owaList.get(0).Id;
                    mail.setOrgWideEmailAddressId(orgEmailAddressId);
                    mail.setSaveAsActivity(true);
                    mail.setUseSignature(false);
                    mail.setCharset('UTF-8');
                    mail.setFileAttachments(lstemailAttachments);

                    allmsg.add(mail);
                    opptiesToUpdate.add(new Opportunity(Id = opp.Id, Welcome_Email_Sent_CCS__c = true));
                }
            }
            try {
                Messaging.sendEmail(allmsg,false);
                update opptiesToUpdate;
                return;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}