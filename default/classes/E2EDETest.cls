@isTest
private class E2EDETest {

    @isTest
    static void testRedirectToETEforms() {
        Test.startTest();

        LongFormController controller = new LongFormController();
        controller.init();

        Test.stopTest();
    }

}