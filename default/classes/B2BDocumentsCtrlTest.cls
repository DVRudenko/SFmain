@IsTest
private class B2BDocumentsCtrlTest {

    /*******************************************************************************
    *  Name            : testInit()
    *  Summary         : test initialization
    *  CreatedDate     : 22/10/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @IsTest
    static void testInit() {
        ApexPages.currentPage().getParameters().put('documentName', '1viqQ6O4SULagOLVvl0uM1SY2rLauwxXycjfqppNSV+9lxvvIwlv/tXJ4sC2Guvw');
        ApexPages.currentPage().getParameters().put('umr', 'Gz2uRSemxKsAzOppG93TOO0hPMbEalGUS/o6mqkrtxA=');
        E2EKeysAPI__c keys = new E2EKeysAPI__c();
        keys.Name = 'E2EForm';
        keys.AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=';
        insert keys;

        Test.startTest();
            B2BDocumentsCtrl.init();
        Test.stopTest();

        System.assertEquals(B2BDocumentsCtrl.documentName, 'B2BInstructionsDE');
        System.assertEquals(B2BDocumentsCtrl.umr, '1234567');
    }
}