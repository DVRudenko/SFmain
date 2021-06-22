/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Additional_HardwareTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Additional_HardwareTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Additional_Hardware__c());
    }
}