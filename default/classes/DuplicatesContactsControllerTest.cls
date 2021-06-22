@isTest
private class DuplicatesContactsControllerTest {
	
   //valid case: There are duplicate field (newContact.Email = newContact2.Email)
	@isTest
    public static void dupsConTest1() {
        Contact newContact = new Contact(
        	Salutation = 'Herr',
        	FirstName = 'test name',
    		LastName = 'test lastname',
    		Phone = '+4977777777',
    		Email = 'test@test.com'
    		);
    	insert newContact;

    	Contact newContact2 = new Contact(
    		Salutation = 'Herr',
        	FirstName = 'test',
    		LastName = 'test',
    		Phone = '+4911111111',
    		Email = 'test@test.com'
    		);
    	insert newContact2;

    	ApexPages.CurrentPage().getparameters().put('id', newContact.id);
    	ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		DuplicatesContactsController dupConController = new DuplicatesContactsController(sc);
		dupConController.init();
		System.assertEquals(1, dupConController.finalDupesContactsList.size());
    }


    //valid case: There are duplicate field (newContact.Phone = newContact2.Phone AND newContact.LastName = newContact2.LastName)
	@isTest
    public static void dupsConTest2() {
        Contact newContact = new Contact(
        	Salutation = 'Herr',
        	FirstName = 'test name',
    		LastName = 'test lastname',
    		Phone = '+4977777777',
    		Email = 'test@test.com'
    		);
    	insert newContact;

    	Contact newContact2 = new Contact(
    		Salutation = 'Herr',
        	FirstName = 'test',
    		LastName = 'test lastname',
    		Phone = '+4977777777',
    		Email = 'test123@test.com'
    		);
    	insert newContact2;

    	ApexPages.CurrentPage().getparameters().put('id', newContact.id);
    	ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		DuplicatesContactsController dupConController = new DuplicatesContactsController(sc);
		dupConController.init();
		System.assertEquals(1, dupConController.finalDupesContactsList.size());
    }


    /*invalid case: There are duplicate field (newContact.FirstName = newContact2.FirstName)
					but we do not fit these parameters */
	@isTest
    public static void dupsConTest3() {
        Contact newContact = new Contact(
        	Salutation = 'Herr',
        	FirstName = 'test name',
    		LastName = 'test lastname',
    		Phone = '+4977777777',
    		Email = 'test@test.com'
    		);
    	insert newContact;

    	Contact newContact2 = new Contact(
    		Salutation = 'Herr',
        	FirstName = 'test name',
    		LastName = 'test',
    		Phone = '+4911111111',
    		Email = 'test123@test.com'
    		);
    	insert newContact2;

    	ApexPages.CurrentPage().getparameters().put('id', newContact.id);
    	ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		DuplicatesContactsController dupConController = new DuplicatesContactsController(sc);
		dupConController.init();
		System.assertEquals(0, dupConController.finalDupesContactsList.size());
    }
}