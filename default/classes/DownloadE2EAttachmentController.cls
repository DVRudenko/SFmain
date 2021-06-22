public class DownloadE2EAttachmentController {
    public String doc {get; set;}
    public String attachmentId {get; set;}
    public String docId {get; set;}
    public String fileUrl {get; set;}

    public DownloadE2EAttachmentController() {}

    public void init() {        
        String encryptedParams = ApexPages.currentPage().getParameters().get('source');
        this.doc = ApexPages.currentPage().getParameters().get('doc');
        if (doc == null) return;

        String opportunityId;
        if (doc != 'hudd' && encryptedParams != null) {
            encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
            Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
            Blob dest = EncodingUtil.base64Decode(encryptedParams);
            Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
            String decryptedParams = decrypted.toString();            
            if (decryptedParams != null) {
                String objectId = decryptedParams.substringBefore('-'); // E2E_Data_Object__c ID (ETE 2.0) OR Opportunity ID (E2E 1.0)
                if (objectId.startsWith('006')) {
                    opportunityId = objectId;
                } else {
                    List<E2E_Data_Object__c> e2eDataObjectList = [SELECT Id, (SELECT Id FROM Opportunities__r LIMIT 1) FROM E2E_Data_Object__c WHERE Id =:objectId];
                    for (E2E_Data_Object__c e2EDataObject : e2eDataObjectList) {
                        for (Opportunity opp : e2EDataObject.Opportunities__r) {
                            opportunityId = opp.Id;
                        }
                    }
                }
            }
        }

        String attachmentName;
        if (doc == 'umowa1') {
        	attachmentName = 'Umowa Karty euroShell (DocuSign).pdf';
        } else 
        if (doc == 'umowa2') {
        	attachmentName = 'Umowa_o_kaucji (DocuSign).pdf';
        } else 
        if (doc == 'vatrecovery') {
            attachmentName = 'vatRecoveryTC.pdf';
        } else 
        if (doc == 'hudd') {
            attachmentName = 'HU_dd.pdf';
        } else 
        if (doc == 'contracthu') {
            attachmentName = 'ContractHU.pdf';
        } else 
        if (doc == 'agreementhu') {
            attachmentName = 'DepositAgreementHU.pdf';
        } else
        if (doc == 'lotosContract') {
            attachmentName = 'Umowa Karty Lotos (DocuSign).pdf';
        } else
        if (doc == 'lotosDeposit') {
            attachmentName = 'Umowa o kaucji Lotos (DocuSign).pdf';
        }
        else if (doc == 'contractcz') {
            attachmentName = 'E2E CZ Contract.pdf';
        }
        else if (doc == 'agreementcz') {
            attachmentName = 'E2E CZ Deposit Agreement.pdf';
        }
        else if (doc == 'contractsk') {
            attachmentName = 'E2E SK Contract.pdf';
        }
        else if (doc == 'agreementsk') {
            attachmentName = 'E2E SK Deposit Agreement.pdf';
        }
        else if (doc == 'carnetContract') {
            attachmentName = 'POTWIERDZENIE ZAWARCIA UMOWY CARNET PL.pdf';
        }
        else if (doc == 'carnetGDPR') {
            attachmentName = 'CARNET OBD GDPR.pdf';
        }
        attachmentName = '%' + attachmentName + '%';
        List<Attachment> attsList = [SELECT Id FROM Attachment WHERE Name LIKE :attachmentName AND ParentId = :opportunityId ORDER BY CreatedDate DESC LIMIT 1];
        List<Document> docsList = [SELECT Id FROM Document WHERE Name LIKE :attachmentName ORDER BY CreatedDate DESC LIMIT 1];
        if ( ! attsList.isEmpty() ) {
        	attachmentId = attsList.get(0).Id;
            return;
        } 
        if ( ! docsList.isEmpty() ) {
            docId = docsList.get(0).Id;
            return;
        }

        List<ContentDocumentLink> cdlList = [SELECT ContentDocument.Id FROM ContentDocumentLink WHERE LinkedEntityId = :opportunityId AND ContentDocument.Title LIKE :attachmentName];
        if ( ! cdlList.isEmpty() ) {
            List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :cdlList.get(0).ContentDocument.Id AND Title LIKE :attachmentName];
            Set<Id> idsSet = new Set<Id>();
            for (ContentVersion cv : cvList) {
                idsSet.add(cv.Id);
            }
            List<ContentDistribution> cdList = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId IN :idsSet];
            if ( ! cdList.isEmpty() ) {
                fileUrl = cdList.get(0).DistributionPublicUrl;
                return;
            }
        }
    }   
}