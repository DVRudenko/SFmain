/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_CCS_OrderTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_CCS_OrderTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new CCS_Order__c());
    }
}