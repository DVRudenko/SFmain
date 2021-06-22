@IsTest
public class ScheduleBatchCloseOpportunitiesTest {

    /*******************************************************************************
     *  Summary         : test scheduler to close inactive opportunities
     *  Created         : 02/11/2020
     *  Parameters      : -
     *  Returns         : void
    ******************************************************************************/
    @IsTest
    static void testScheduleBatchCloseOpportunities() {
        Test.startTest();
            ScheduleBatchCloseOpportunities scheduler = new ScheduleBatchCloseOpportunities();
            String sch = '0 0 23 * * ?';
	        System.schedule('Test Schedule', sch, scheduler);
        Test.stopTest();
    }
}