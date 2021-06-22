public with sharing class ContentVersionTriggerHandler {

    private static List<Service_Transformation_Settings__mdt> signatureRemoving = [SELECT DeveloperName, Enabled__c FROM Service_Transformation_Settings__mdt WHERE DeveloperName = 'Signature_removing'];

    public static void setupEmptyName(List<ContentVersion> documentList) {
        for(ContentVersion document : documentList) {
            if(String.isEmpty(document.Title) && !String.isEmpty(document.PathOnClient)) {
                document.Title = document.PathOnClient;
            } else if(String.isEmpty(document.Title) && String.isEmpty(document.PathOnClient)) {
                document.Title = 'Untitled';
            }
        }
    }

    public static void preventSignatureInsert(List<ContentVersion> documentList) {
        if((signatureRemoving.size() != 0 && signatureRemoving[0].Enabled__c) || Test.isRunningTest()) {
            Set<Id> documentIdSetToDelete = new Set<Id>();
            Set<Id> messageIdSet = new Set<Id>();
            Set<String> messageIdConnectedToCaseList = new Set<String>();
            List<ContentDocument> documentListToDelete = new List<ContentDocument>();
            List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
            List<EmailMessage> relatedEmailMessages = new List<EmailMessage>();
            for (ContentVersion document : documentList) {
                if (    Pattern.matches('image[0-9]{3}\\b', document.Title) &&
                        (document.FileType == 'JPG' || document.FileType == 'PNG' || document.FileType == 'BMP') &&
                        document.ContentSize < 14336 )
                {
                    documentIdSetToDelete.add(document.ContentDocumentId);
                }
            }
            if(documentIdSetToDelete.size() != 0) {
                linkList = [
                    SELECT  ContentDocumentId,
                            ContentDocument.Id,
                            LinkedEntityId
                    FROM    ContentDocumentLink
                    WHERE   ContentDocumentId IN: documentIdSetToDelete
                ];
                for (ContentDocumentLink docLink : linkList) {
                    String objectType = String.valueOf(docLink.LinkedEntityId).substring(0, 3);
                    if( objectType == '02s' ) {
                        messageIdSet.add(docLink.LinkedEntityId);
                    }
                }
                relatedEmailMessages = [
                    SELECT  ParentId
                    FROM    EmailMessage
                    WHERE   Id IN: messageIdSet
                ];
    
                for(EmailMessage message : relatedEmailMessages) {
                    if(String.valueOf(message.ParentId).substring(0, 3) == '500') {
                        messageIdConnectedToCaseList.add(String.valueOf(message.Id));
                    }
                }
                for (ContentDocumentLink docLink : linkList) {
                    if(messageIdConnectedToCaseList.contains(docLink.LinkedEntityId)) {
                        documentListToDelete.add(docLink.ContentDocument);
                    }
                }
                delete documentListToDelete;
    
            }
        }
    }
}