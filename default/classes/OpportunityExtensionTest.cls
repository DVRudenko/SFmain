@IsTest
private class OpportunityExtensionTest {

	@isTest
	static void method1 () {
		PageReference page = new PageReference('testPage');
		page.getParameters().put('ids', 'array ids');
		page.getParameters().put('id', 'test ids');
		Test.setCurrentPage(page);
		OpportunityExtension extension = new OpportunityExtension();
	}

}