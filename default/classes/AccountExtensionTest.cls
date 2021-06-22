@IsTest
private class AccountExtensionTest {

	@isTest
	static void method1 () {
		PageReference page = new PageReference('testPage');
		page.getParameters().put('ids', 'array ids');
		page.getParameters().put('id', 'test id');
		Test.setCurrentPage(page);
		AccountExtension extension = new AccountExtension();
	}

}