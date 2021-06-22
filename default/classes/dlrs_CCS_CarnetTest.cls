/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_CCS_CarnetTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_CCS_CarnetTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new CCS_Carnet__c());
    }
}