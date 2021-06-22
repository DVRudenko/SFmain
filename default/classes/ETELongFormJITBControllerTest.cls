@IsTest
public class ETELongFormJITBControllerTest {
    
    @IsTest
    static void init (){
        PageReference pageRef = new PageReference('eteJitbLocator');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getHeaders().put('Host', 'http://test.de');
        ETELongFormJITBController ctrl = new ETELongFormJITBController();
        ctrl.init();
    
        Map<String,String> content = ctrl.content;

        System.assert(content.containsKey('title'));
        System.assert(content.get('title') == 'Shell Tankkarten online bestellen');
    }
}
