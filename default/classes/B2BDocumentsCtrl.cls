public without sharing class B2BDocumentsCtrl {
    public static String documentName {get;set;}
    public static String umr {get;set;}

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : initialize the visualforce page
    *  CreatedDate     : 20/10/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void init() {
        Blob keyAES256 = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);

        if (! String.isEmpty(ApexPages.currentPage().getParameters().get('documentName'))) {
            Blob doc = EncodingUtil.base64Decode(ApexPages.currentPage().getParameters().get('documentName').replace(' ','+'));
            Blob decryptedDoc = Crypto.decryptWithManagedIV('AES256', keyAES256, doc);
            documentName = decryptedDoc.toString();
        }

        if (! String.isEmpty(ApexPages.currentPage().getParameters().get('umr'))) {
            Blob umrValue = EncodingUtil.base64Decode(ApexPages.currentPage().getParameters().get('umr').replace(' ', '+'));
            Blob decryptedUmr = Crypto.decryptWithManagedIV('AES256', keyAES256, umrValue);
            umr = decryptedUmr.toString();
        }
    }
}