@IsTest
private class E2EChatPageCtrlTest {

    static testMethod void testBehaviorDE() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'Germany');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }

    static testMethod void testBehavioNL() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'Netherlands');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }

    static testMethod void testBehaviorBENL() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'BELGIUM-NL');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }

    static testMethod void testBehaviorBEFR() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'BELGIUM-FR');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }

    static testMethod void testBehaviorRU() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'Russia');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }

    static testMethod void testBehaviorFR() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'France');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }

    static testMethod void testBehaviorPL() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'Poland');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }

    static testMethod void testBehaviorHU() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'Hungary');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }

    static testMethod void testBehaviorCHDE() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'Switzerland-DE');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }

    static testMethod void testBehaviorCHFR() {
        Test.setCurrentPageReference(new PageReference('E2EChatPage.page'));
        System.currentPageReference().getParameters().put('language', 'Switzerland-FR');
        E2EChatPageCtrl controller = new E2EChatPageCtrl();
    }
}