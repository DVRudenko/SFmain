public with sharing class GFNI_DashboardDaoImpl implements GFNI_DashboardDao {

    /*******************************************************************************
    *  Name            : getAccountById(Id accountId)
    *  Summary         : get account by id
    *  CreatedDate     : 25/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Id accounts
    *  Returns         : account
    ******************************************************************************/
    public Account getAccountById(Id accountId) {
        Account accountObject = [
                SELECT Id, Name, GFN_Nr__c, ColCo__c, OwnerId
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
        ];
        return accountObject;
    }


    /*******************************************************************************
    *  Name            : getCaseAccountById(Id caseId)
    *  Summary         : get case by id
    *  CreatedDate     : 25/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Id case
    *  Returns         : case
    ******************************************************************************/
    public Case getCaseAccountById(Id caseId) {
        Case caseObject = [
                SELECT Id, 
                    CaseNumber, 
                    Account.GFN_Nr__c, 
                    Account.ColCo__c,
                    ERP__r.GFN_Number__c,
                    ERP__r.GFN_Nr__c,
                    ERP__r.ColCoID__c,
                    ERP__r.ColCo__c,
                    ERP__r.RecordTypeId,
                    RecordTypeId
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
        ];
        return caseObject;
    }


    /*******************************************************************************
    *  Summary         : get task by id
    *  Created         : 27/12/2019 Anton Hrytsavets
    *  Parameters      : taskId - task Id
    *  Returns         : task for GFN dashboard
    ******************************************************************************/
    public Task getTaskById(Id taskId) {
        Task taskObject = [
                SELECT  Account__c, 
                        Account__r.GFN_Nr__c, 
                        Account__r.ColCo__c,
                        WhatId
                FROM    Task
                WHERE   Id = :taskId
                LIMIT   1
        ];
        return taskObject;
    }


    /*******************************************************************************
    *  Summary         : get erp(gfn) record by id
    *  Created         : 01/06/2020 Anton Hrytsavets
    *  Parameters      : erpId - erp Id
    *  Returns         : erp(gfn) for GFN dashboard
    ******************************************************************************/
    public ERP__c getERPById(Id erpId) {
        ERP__c erpObject = [
                SELECT  GFN_Number__c,
                        GFN_Nr__c,
                        ColCoID__c,
                        ColCo__c,
                        RecordTypeId
                FROM    ERP__c
                WHERE   Id = :erpId
                LIMIT   1
        ];
        return erpObject;
    }


    /*******************************************************************************
    *  Summary         : get ERP by liveChat record id
    *  Created         : 19/03/2021 Anton Hrytsavets
    *  Parameters      : chatTranscriptId - chat transcript Id
    *  Returns         : erp(gfn) for GFN dashboard
    ******************************************************************************/
    public ERP__c getErpByLiveChatTranscript(Id chatTranscriptId) {
        LiveChatTranscript chatObject = [
                SELECT  GFN__c,
                        GFN__r.GFN_Nr__c,
                        GFN__r.GFN_Number__c,
                        GFN__r.ColCoID__c,
                        GFN__r.ColCo__c,
                        GFN__r.RecordTypeId
                FROM    LiveChatTranscript
                WHERE   Id = :chatTranscriptId
                LIMIT   1
        ];
        return chatObject.GFN__r;
    }


    /*******************************************************************************
    *  Name            : getCaseCurrentInfo(String caseId)
    *  Summary         : get case info by Id
    *  CreatedDate     : 08/10/2019
    *  ModifiedDate    : -
    *  Parameters      : String caseId
    *  Returns         : list of cases
    ******************************************************************************/
    public List<Case> getCaseCurrentInfo(Id caseId) {
        List<Case> caseObject = [
                SELECT  Id, 
                        CaseNumber,
                        Description,
                        Origin,
                        Status,
                        Topic__c,
                        Sub_topic__c,
                        Queue_Email__c,
                        SuppliedEmail,
                        AccountId,
                        Account.Name,
                        Account.GFN_Nr__c, 
                        Account.ColCo__c   
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
        ];
        return caseObject;
    }


    /*******************************************************************************
    *  Name            : getRelatedCases(Id accountId)
    *  Summary         : get case info by account Id
    *  CreatedDate     : 08/10/2019
    *  ModifiedDate    : -
    *  Parameters      : String caseId
    *  Returns         : list of cases
    ******************************************************************************/
    public List<Case> getRelatedCases(Id accountId) {
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
                WHERE   AccountId = :accountId
                AND     Status != 'Resolved'
                AND     Status != 'Closed'
        ];
        return caseList;
    }

    
    /*******************************************************************************
    *  Name            : getVersionByDocName(String docNumber)
    *  Summary         : get ContentVersion by document number
    *  CreatedDate     : 2/11/2019
    *  ModifiedDate    : -
    *  Parameters      : String docNumber
    *  Returns         : list of ContentVersion
    ******************************************************************************/
    public List<ContentVersion> getVersionByDocName(String docNumber) {
        List<ContentVersion> version = [
            SELECT  Id,
                    Title,
                    ContentDocumentId,
                    VersionData
            FROM    ContentVersion
            WHERE   Title =: docNumber+'.pdf'
            LIMIT   1
        ];
        return version;
    }

    
    /*******************************************************************************
    *  Name            : getDashboardUISettings(String recordType)
    *  Summary         : get Dashboard components to display by recordType
    *  CreatedDate     : 5/06/2020
    *  Parameters      : String recordType
    *  Returns         : list of GFN_Dashboard_UI_settings__mdt records
    ******************************************************************************/
    public List<GFN_Dashboard_UI_settings__mdt> getDashboardUISettings(String recordType) {
        List<GFN_Dashboard_UI_settings__mdt> uiSettings = [
            SELECT  Label,
                    DeveloperName,
                    Tab__c,
                    Line_Of_Business__c,
                    Fields__c,
                    Priority__c,
                    Tab_Icon__c
            FROM    GFN_Dashboard_UI_settings__mdt
            WHERE   Line_Of_Business__c=: recordType
            AND     Active__c = true
            ORDER BY Priority__c
        ];
        return uiSettings;
    }

    
    /*******************************************************************************
    *  Name            : getDistributionByVersionId(Id versionId)
    *  Summary         : get ContentDistribution by version Id
    *  CreatedDate     : 2/11/2019
    *  ModifiedDate    : -
    *  Parameters      : Id versionId
    *  Returns         : list of ContentDistribution
    ******************************************************************************/
    public List<ContentDistribution> getDistributionByVersionId(Id versionId) {
        List<ContentDistribution> existingDestributions = [
            SELECT  DistributionPublicUrl
            FROM    ContentDistribution
            WHERE   ContentVersionId =: versionId
            LIMIT   1
        ];
        return existingDestributions;
    }

    
    /*******************************************************************************
    *  Name            : createDistributionForVersion(ContentVersion version)
    *  Summary         : create ContentDistribution for content version and return new ContentDistribution record with autofilled fields
    *  CreatedDate     : 2/11/2019
    *  ModifiedDate    : -
    *  Parameters      : ContentVersion version
    *  Returns         : ContentDistribution
    ******************************************************************************/
    public ContentDistribution createDistributionForVersion(ContentVersion version) {
        ContentDistribution distribution = new ContentDistribution();
        distribution.Name = version.Title + ' ' + String.valueOf(Date.today());
        distribution.ContentVersionId = version.Id;
        distribution.PreferencesNotifyOnVisit = false;
        insert distribution;

        List<ContentDistribution> distributionList = [
            SELECT  DistributionPublicUrl
            FROM    ContentDistribution
            WHERE   Id =: distribution.Id
            LIMIT   1
        ];
        distribution = distributionList[0];
        return distribution;
    }

    
    /*******************************************************************************
    *  Name            : createContentVersionPDF(ContentVersion version)
    *  Summary         : create ContentDistribution for content version and return new ContentDistribution record with autofilled fields
    *  CreatedDate     : 2/11/2019
    *  ModifiedDate    : -
    *  Parameters      : ContentVersion version
    *  Returns         : ContentDistribution
    ******************************************************************************/
    public ContentVersion createContentVersionPDF(String encodedPDF, String docName) {
        ContentVersion newVersion = new ContentVersion();
        Blob pdf = EncodingUtil.base64Decode(encodedPDF);
        newVersion.VersionData = pdf;
        newVersion.Title = docName + '.pdf';
        newVersion.PathOnClient = docName + '.pdf';
        insert newVersion;
        return newVersion;
    }

}