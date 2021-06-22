/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Carnet_UnitTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Carnet_UnitTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Carnet_Unit__c());
    }
}