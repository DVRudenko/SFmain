@isTest
public class LeadExtensionTest {

	@isTest
	static void method1 () {
		PageReference page = new PageReference('testPage');
		page.getParameters().put('id', 'test id');
		Test.setCurrentPage(page);
		LeadExtension extension = new LeadExtension();
	}
}