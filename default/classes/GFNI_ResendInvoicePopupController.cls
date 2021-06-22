public with sharing class GFNI_ResendInvoicePopupController {



    public static GFNI_DashboardService gfnDashboardService = new GFNI_DashboardServiceImpl();
    public static GFNI_DashboardDao dashboardDao = new GFNI_DashboardDaoImpl();

    @AuraEnabled
    public static List<Case> getRelatedCases(Id recordId, String objectName){
        List<Case> resultCaseList = new List<Case>();
        if(objectName == 'Case'){
            resultCaseList = dashboardDao.getCaseCurrentInfo(recordId);
        } else if (objectName == 'Account'){
            resultCaseList = dashboardDao.getRelatedCases(recordId);
        }
        return resultCaseList;
    }

    @AuraEnabled
    public static List<Case> getCasesByERP(String customerERP){
        Set<Id> relatedAccountIds = new Map<Id, Account>([
            SELECT Id
            FROM Account
            WHERE  GFN_Nr__c =: customerERP
        ]).keySet();
        Set<Id> relatedERPIds = new Map<Id, ERP__c>([
            SELECT  Id
            FROM    ERP__c
            WHERE  GFN_Nr__c =: customerERP
            OR     GFN_Number__c =: customerERP
        ]).keySet();

        List<Case> caseList = [
                SELECT  Id, 
                        CaseNumber,
                        Description,
                        Origin,
                        Status,
                        Topic__c,
                        Sub_topic__c,
                        Queue_Email__c,
                        SuppliedEmail,
                        Account.Name,
                        Account.GFN_Nr__c, 
                        Account.ColCo__c   
                FROM    Case
                WHERE   (AccountId IN :relatedAccountIds
                OR      ERP__c IN : relatedERPIds)
                AND     Status != 'Resolved'
                AND     Status != 'Closed'
        ];
        return caseList;
    }


    @AuraEnabled
    public static List<Contact> getContactList(String accountId) {
        List<Contact> contactList = [
            SELECT  FirstName,
                    LastName,
                    Email
            FROM    Contact
            WHERE   AccountId =: accountId
        ];
        return contactList;
    }


    @AuraEnabled
    public static List<Contact> getContactsByERP(String erpId) {
        ERP__c erp = [
            SELECT  Account__c,
                    Contact__c
            FROM    ERP__c
            WHERE   Id =: erpId
        ];
        List<Contact> contactList = [
            SELECT  FirstName,
                    LastName,
                    Email
            FROM    Contact
            WHERE   ERP__c =: erpId
            OR      (AccountId =: erp.Account__c
            AND     AccountId != null)
            OR      Id =: erp.Contact__c
        ];
        return contactList;
    }


    @AuraEnabled
    public static List<String> getQueueEmailList(String accParams){
        Id currentUserId = UserInfo.getUserId();
        List<String> emailList = new List<String>();
        List<GroupMember> queueMembers = [
            SELECT  Group.Email 
            FROM    GroupMember
            WHERE   Group.Type = 'Queue'
            AND     Group.Name IN: GFNI_ModalWindowHandler.getQueueName(accParams).split(',')
        ];
        for(GroupMember member : queueMembers){
            emailList.add(member.Group.Email);
        }
        return emailList;
    }

    @AuraEnabled
    public static void createCaseAndSendEmail(Boolean isNewCase, Case relatedCase, Map<String, String> emailContent, String lineOfBusiness, List<String> documentsToAttach){
        if(isNewCase){
            relatedCase = GFNI_ModalWindowHandler.createNewCase(relatedCase, emailContent, lineOfBusiness);
        }
        List<Messaging.EmailFileAttachment> attachList = GFNI_ModalWindowHandler.createAttachments(emailContent);
        List<Messaging.EmailFileAttachment> existingDocumentList = GFNI_ModalWindowHandler.getExistingDocuments(documentsToAttach);
        System.debug('existingDocumentList === ' + existingDocumentList);
        attachList.addAll(existingDocumentList);
        GFNI_ModalWindowHandler.sendInvoiceEmail(emailContent, attachList, relatedCase);

    }

    @AuraEnabled
    public static EmailTemplate getEmailTemplate(String accParams){

        List<EmailTemplate> templates = [
            SELECT  Id,
                    Subject,
                    HtmlValue
            FROM    EmailTemplate
            WHERE   Name =: GFNI_ModalWindowHandler.getTemplateName(accParams)
        ];
        if(templates.size()>0){
            List<User> userList = [
                SELECT  FirstName,
                        LastName,
                        Title,
                        Phone
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
            ];
            if(userList.size() > 0) {
                User currentUser = userList[0];
                String userFirstName = currentUser.FirstName == null ? '': currentUser.FirstName;
                String userLastNameName = currentUser.LastName == null ? '': currentUser.LastName;
                String userPhone = currentUser.Phone == null ? '': currentUser.Phone;
                String userTitle = currentUser.Title == null ? '': currentUser.Title;
                templates[0].HtmlValue = templates[0].HtmlValue.Replace('{!User.FirstName}', userFirstName);
                templates[0].HtmlValue = templates[0].HtmlValue.Replace('{!User.LastName}', userLastNameName);
                templates[0].HtmlValue = templates[0].HtmlValue.Replace('{!User.Title}', userTitle);
                templates[0].HtmlValue = templates[0].HtmlValue.Replace('{!User.Phone}', userPhone);
            }
            return templates[0];

        }
        return null;
    }

    @AuraEnabled
    public static String getPDFInvoice(String docNumber, String colCoID, String customerERP, String recordTypeName) {
        List<ContentVersion> existingVersion = dashboardDao.getVersionByDocName(docNumber);
        GFNI_Settings__c integrationSettings = GFNI_DashboardCtrl.getCustomSetting(recordTypeName);
        String pdf = '';
        if(existingVersion.isEmpty()){        
            String encodedDocNumber = EncodingUtil.urlEncode(docNumber, 'UTF-8');
            AccountDetailsGfn document = gfnDashboardService.getDocumentFromGFN(colCoID, integrationSettings, customerERP, encodedDocNumber);
            if(document.Data != null){
                pdf = document.Data.PdfData;
            }
        } else {
            pdf = EncodingUtil.base64Encode(existingVersion[0].VersionData);
        }
        return pdf;
    }

    @AuraEnabled
    public static String getAccParams(String colCoId, String customerNumber, String recordTypeName){
        AccountDetailsGfn customerInformation = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = GFNI_DashboardCtrl.getCustomSetting(recordTypeName);

        try {
            customerInformation = gfnDashboardService.getCustomerInformation(colCoID, integrationSettings, customerNumber);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        String accountDetailsJSON =JSON.serialize(customerInformation.Data);
        return accountDetailsJSON;
    }

    @AuraEnabled
    public static String getAddressFromGFN(String colCoId, String customerNumber, String recordTypeName){
        AccountDetailsGfn customerAddresses = new AccountDetailsGfn();
        GFNI_Settings__c integrationSettings = GFNI_DashboardCtrl.getCustomSetting(recordTypeName);
        
        try {
            customerAddresses = gfnDashboardService.getCustomerAddresses(colCoID, integrationSettings, customerNumber, null);
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            throw new AuraHandledException(exceptionMessage);
        }
        String addressJSON = JSON.serialize(customerAddresses.Data.AccountAddresses);
        return addressJSON;        
    }


    @AuraEnabled
    public static List<ContentWorkspaceDoc> getDocuments() {
        List<ContentWorkspaceDoc> workspaceDocList = [
            SELECT  ContentWorkspaceId,
                    ContentWorkspace.Name,
                    ContentDocumentId,
                    ContentDocument.Title

            FROM    ContentWorkspaceDoc
        ];
        return workspaceDocList;     
    }

    @AuraEnabled
    public static List<ContentDocument> getUsersDocuments() {
        List<ContentDocument> usersDocumentList = [
            SELECT  Title
            FROM    ContentDocument
            WHERE OwnerId =: UserInfo.getUserId()
        ];
        return usersDocumentList;
    }

    @AuraEnabled
    public static void deleteNewDocument(String docId) {
        List<ContentDocument> documentToDelete = [
            SELECT  Id
            FROM    ContentDocument
            WHERE   Id =: docId
        ];
        delete documentToDelete;
    }
}