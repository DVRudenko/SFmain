@isTest
private class e2eShortFormCtrlTest {
	@isTest
    static void createLeadTest() {
        e2eShortFormCtrl ctrl = new e2eShortFormCtrl();
        ctrl.init();
        ctrl.lastName = 'testname';
        ctrl.companyName = 'cyberdyne systems';
        ctrl.phoneNumber = '+3111111111';
        ctrl.email = 'test@test.com';

        ctrl.createLead();

        List<Lead> leadList = [SELECT LastName, Company, Phone, Email, Visitor_ID__c FROM Lead];
        System.assertEquals('testname', leadList.get(0).LastName);
        System.assertEquals('cyberdyne systems', leadList.get(0).Company);
        System.assertEquals('+3111111111', leadList.get(0).Phone);
        System.assertEquals('test@test.com', leadList.get(0).Email);
    }
}