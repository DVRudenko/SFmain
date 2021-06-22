@IsTest
public class OpportunityStartProcessCtrlTest {

    @IsTest
    private static void testCtrlMethods(){
        List<String> editFields = OpportunityStartProcessCtrl.getListOfEditFields();
        List<String> readFields = OpportunityStartProcessCtrl.getListOfReadFields();
    }

}