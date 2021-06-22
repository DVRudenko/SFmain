public with sharing class GFNI_ModalWindowHandler {

    private static Id supportRecordType =  GlobalUtils.getRecordTypeId('Case', 'Support');
    private static Id ccsSupportRecordType =  GlobalUtils.getRecordTypeId('Case', 'Support_CCS');

    public static String getTemplateName(String accountParams){
        Profile creditProfile = [
            SELECT  Id
            FROM    Profile
            WHERE   Name = 'Credit'
        ];
        List<Col_Co_Mapping__mdt> colCoMapping = [
            SELECT  Resend_Invoice_Email_Template__c,
                    Credit_Resend_Invoice_Email_Template__c
            FROM    Col_Co_Mapping__mdt
            WHERE   DeveloperName =: accountParams.replace(',', '_')
        ];
        if(colCoMapping.size() > 0) {
            if(UserInfo.getProfileId() == creditProfile.Id) {
                return colCoMapping[0].Credit_Resend_Invoice_Email_Template__c;
            }
            return colCoMapping[0].Resend_Invoice_Email_Template__c;
        }
        return null;
    }

    public static String getQueueName(String accountParams){
        Map<String, String> templateNameMap = new Map<String, String>{
            'German,1'=>'DE Support',
            'German,2' => 'AT Support',
            'Dutch,3' => 'BE_NL Support',
            'French,3' => 'BE_FR Support',
            'Dutch,4' => 'NL Support',
            'French,5' => 'FR Support',
            'Hungarian,6' => 'HU Support',
            'Polish,7' => 'PL Support',
            'French,79' => 'LU Support',
            'German,80' => 'CH_DE Support',
            'French,80' => 'CH_FR Support',
            'Italian,80' => 'CH_IT Support',
            'Czech,81' => 'CZ Support',
            'Slovak,82' => 'SK Support',
            'Slovak,9' => 'Kredit CCS SK,Zákaznické',
            'Slovakian,9' => 'Kredit CCS SK,Zákaznické',
            'Czech,8' => 'Bonusky,Carnet,CCS Premium,Eurotoll,Kredit CCS CZ,Market,Mýto,Provoz,Reklamace,UTA,Zákaznická podpora'
        };
        return templateNameMap.get(accountParams);
    }

    public static Case createNewCase(Case relatedCase, Map<String, String> emailContent, String lineOfBusiness) {
        relatedCase.Status = 'New';
        if(lineOfBusiness == 'CCS') {
            relatedCase.RecordTypeId = ccsSupportRecordType;
        } else {
            relatedCase.RecordTypeId = supportRecordType;
        }
        if(relatedCase.AccountId == null && relatedCase.ERP__c != null) {
            relatedCase.AccountId = getAccountId(relatedCase.ERP__c);
        }
        insert relatedCase;
        relatedCase = [
            SELECT  CaseNumber 
            FROM    Case 
            WHERE   Id =: relatedCase.Id];
        emailContent.put('subject', emailContent.get('subject').replace('{!Case.CaseNumber}', relatedCase.CaseNumber));
        emailContent.put('subject', emailContent.get('subject').replace('(New Case)', relatedCase.CaseNumber));
        relatedCase.Subject = emailContent.get('subject');
        update relatedCase;
        return relatedCase;
    }

    public static List<Messaging.EmailFileAttachment> createAttachments(Map<String, String> emailContent){
        List<Messaging.EmailFileAttachment> attachList = new List<Messaging.EmailFileAttachment>();
        List<ContentVersion> attachmentList = createDocuments(emailContent);
        for (ContentVersion attach : attachmentList) {
            Messaging.EmailFileAttachment newAttach = new Messaging.EmailFileAttachment();
            newAttach.setFileName(attach.PathOnClient);
            newAttach.setBody(attach.VersionData);
            attachList.add(newAttach);
        }
        return attachList;
    }

    public static void sendInvoiceEmail(Map<String, String> emailContent, List<Messaging.EmailFileAttachment> attachList, Case relatedCase){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{emailContent.get('to')});
        if(String.isNotEmpty(emailContent.get('cc'))){
            mail.setCcAddresses(emailContent.get('cc').split('[,;]{1}[\\s]?'));
        }
        List<OrgWideEmailAddress> owea = [
            SELECT  Id 
            FROM    OrgWideEmailAddress 
            WHERE Address =: emailContent.get('from')
        ];
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        String emailBody = setThreadIdForBody(emailContent.get('body'), relatedCase.Id);
        mail.setSubject(emailContent.get('subject'));
        mail.setHtmlBody(emailBody);
        mail.setReplyTo(emailContent.get('from'));
        mail.setFileAttachments(attachList);
        mail.setWhatId(relatedCase.Id);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }


    public static List<Messaging.EmailFileAttachment> getExistingDocuments(List<String> documentIdList) {
        List<Messaging.EmailFileAttachment> attachList = new List<Messaging.EmailFileAttachment>();
        List<ContentVersion> versionList = [
            SELECT  Id,
                    PathOnClient,
                    VersionData
            FROM    ContentVersion
            WHERE   ContentDocumentId IN: documentIdList
        ];
        for(ContentVersion version : versionList) {
            Messaging.EmailFileAttachment newAttach = new Messaging.EmailFileAttachment();
            newAttach.setFileName(version.PathOnClient);
            newAttach.setBody(version.VersionData);
            attachList.add(newAttach);
        }
        return attachList;
    }


    private static List<ContentVersion> createDocuments(Map<String, String> emailContent){
        List<ContentVersion> attachsToInsert = new List<ContentVersion>();
        if(!String.isEmpty(emailContent.get('invoices'))){
            Map<String, String> attachmentMap = (Map<String, String>)JSON.deserialize(emailContent.get('invoices'), Map<String, String>.class);
            List<String> attachmentTitleList = new List<String>();
            for(String docName : attachmentMap.keySet()){
                attachmentTitleList.add(docName+'.pdf');
            }
            List<ContentVersion> existingDocs = [
                SELECT  Title,
                        VersionData,
                        isLatest,
                        PathOnClient
                FROM    ContentVersion
                WHERE   isLatest = true AND Title IN :attachmentTitleList
            ];

            List<String> existingDocNames = new List<String>();
            for(ContentVersion version : existingDocs){
                existingDocNames.add(version.Title);
            }
            for (String docName : attachmentMap.keySet()) {
                if(!existingDocNames.contains(docName + '.pdf')){
                    String encodedPDF = attachmentMap.get(docName);
                    Blob pdf = EncodingUtil.base64Decode(encodedPDF);
                    ContentVersion newAttach = new ContentVersion();
                    newAttach.VersionData = pdf;
                    newAttach.Title = docName + '.pdf';
                    newAttach.PathOnClient = docName + '.pdf';
                    attachsToInsert.add(newAttach);
                }
            }
            insert attachsToInsert;
            attachsToInsert.addAll(existingDocs);
        }
        return attachsToInsert;
    }

    private static String setThreadIdForBody(String emailBody, String caseId){
        String threadId;
        if(GFNI_Utils.isProductionOrg()){
            threadId = '[ ref:_' + UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + caseId.left(5) + caseId.mid(9,6) + ':ref ]';
        } else {
            threadId = '[ ref:_' + UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + caseId.left(5) + caseId.mid(10,5) + ':ref ]';            
        }
        emailBody = emailBody + '\n' + threadId;
        return emailBody;
    }


    private static String getAccountId(String erpId) {
        List<ERP__c> erpList = [
            SELECT  Account__c
            FROM    ERP__c
            WHERE   Id =: erpid
        ];
        if(erpList.size() >0) {
            return erpList[0].Account__c;
        }
        return null;
    }

}