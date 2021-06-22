public with sharing class CreateSalesPlanController {
	public String userId {get; set;}
	public String selectedYear {get; set;}

    public CreateSalesPlanController() {
        userId = Apexpages.currentPage().getParameters().get('uid');
        selectedYear = '2016';
    }

    public PageReference createPlan() {
    	if (userId == null) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Id'));
    		return null;
    	}

    	List<Sales_Plan__c> checkExistingItems = [
    			SELECT Id
    			FROM Sales_Plan__c
    			WHERE User__c = :userId AND Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :selectedYear
    			LIMIT 1];
    	if ( ! checkExistingItems.isEmpty() ) {
    		String errorMessage = 'You have existing records for current year. Please delete it and re-create plan';
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
    		return null;
    	}

		List<User> users = [SELECT Grade__c, Hire_Date__c FROM User WHERE Id = :userId];
		List<Sales_Plan__c> plans = new List<Sales_Plan__c>();
		List<Fleetcor_Calendar_Month__c> monthes = [
		    SELECT Id 
		    FROM Fleetcor_Calendar_Month__c 
		    WHERE Fleetcor_Calendar_Year__r.Name = :selectedYear
		];

		for (User u : users) {
            if (u.Hire_Date__c != null && u.Grade__c != null) {
                for (Fleetcor_Calendar_Month__c m : monthes) {
                    plans.add(new Sales_Plan__c(Fleetcor_Calendar_Month__c = m.Id, User__c = u.Id));
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Fill Grade and Hire Date for this user'));
                return null;
            }
		}

		insert plans;

		return new PageReference('/' + userId + '?noredirect=1&isUserEntityOverride=1');
    }

    public PageReference cancel() {
    	return new PageReference('/' + userId + '?noredirect=1&isUserEntityOverride=1');
    }

    public List<SelectOption> getYears() {
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('2016', '2016'));
    	options.add(new SelectOption('2017', '2017'));
    	options.add(new SelectOption('2018', '2018'));
    	options.add(new SelectOption('2019', '2019'));
    	options.add(new SelectOption('2020', '2020'));

    	return options;
    }
}