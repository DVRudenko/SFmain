public with sharing class AccountKamReportCtrl {
	public Integer quantityAllAccounts {get; set;}
    public Integer quantityAccountsGermany {get; set;}
    public Integer quantityAccountsAustria {get; set;}
    public Integer quantityAccountsSwitzerlandDE {get; set;}
    public List<Account> finalAccountsGermanyList {get; set;}
    public List<Account> finalAccountsAustriaList {get; set;}
    public List<Account> finalAccountsSwitzerlandDEList {get; set;}
	public User currentUser {get; set;}
	public String startDatePeriodString {get; set;}
    public String endDatePeriodString {get; set;}
	private Date startDatePeriod;
    private Date endDatePeriod;


    public void init() {
    	this.quantityAllAccounts = 0;
		this.quantityAccountsGermany = 0;
		this.quantityAccountsAustria = 0;
		this.quantityAccountsSwitzerlandDE = 0;
    	generateDataForReport();
    	selectAccountWithoutMeetingTasksForReport();

        if (quantityAccountsGermany >= 1000) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table for Germany displays 1000 record max.'));
        }
        if (quantityAccountsAustria >= 1000) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table for Austria displays 1000 record max.'));
        }
        if (quantityAccountsSwitzerlandDE >= 1000) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table for Switzerland-DE displays 1000 record max.'));
        }    
    }


    /*******************************************************************************
    *  Name            : selectAccountWithoutMeetingTasksForReport()
    *  Summary         : Getting all accounts without meeting tasks over the past three months for
						 Germany, Austria, Switzerland-DE     
    *  CreatedDate     : 10/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void selectAccountWithoutMeetingTasksForReport() {
		List<Account> allAccountsList = [
			SELECT Id, Name, BillingCountry, OwnerId, Owner.Name, CreatedDate, OBN__c, Last_contact_date__c, Last_contact_results__c
			FROM Account
			WHERE RecordType.Name = 'Retailer' AND
				  (BillingCountry = 'Germany' OR BillingCountry = 'Austria' OR BillingCountry = 'Switzerland-DE')
            ORDER BY CreatedDate DESC
			LIMIT 50000];

	 	Set<Id> allAccountsIdSet = new Set<Id>();
	  	for (Account ac : allAccountsList){
	  		allAccountsIdSet.add(ac.Id);
	  	}

	  	List<Task> allMeetingTaskList =	[
			SELECT Id, WhatId, Subject, ActivityDate
			FROM Task 
			WHERE Subject = 'Meeting' AND 
                Status = 'Completed' AND
                ActivityDate >= :this.startDatePeriod AND 
                ActivityDate <= :this.endDatePeriod AND
				WhatId IN :allAccountsIdSet
			LIMIT 50000];

		Set<Id> accountsWithTasksIdSet = new Set<Id>();
	  	for (Task t : allMeetingTaskList){
	  		accountsWithTasksIdSet.add(t.WhatId);
	  	}

	  	List<Account> accountsWithoutTasks = new List<Account>();
	  	for (Account acc : allAccountsList){
	  		if (! accountsWithTasksIdSet.contains(acc.Id)){
	  			accountsWithoutTasks.add(acc);
	  		}
	  	}
	  	this.quantityAllAccounts = accountsWithoutTasks.size();

	  	List<Account> accountsGermanyList = new List<Account>();
		List<Account> accountsAustriaList = new List<Account>();
		List<Account> accountsSwitzerlandDEList = new List<Account>();

	  	for (Account account : accountsWithoutTasks) {
			if (account.BillingCountry == 'Germany'){
				accountsGermanyList.add(account);
			}
			if (account.BillingCountry == 'Austria'){
				accountsAustriaList.add(account);
			}
			if (account.BillingCountry == 'Switzerland-DE'){
				accountsSwitzerlandDEList.add(account);
			}
		}

        finalAccountsGermanyList = new List<Account>();
        finalAccountsAustriaList = new List<Account>();
        finalAccountsSwitzerlandDEList = new List<Account>();

        Integer countDE = 0;
        for (Account a : accountsGermanyList) {
            if (countDE == 1000) break;
            this.finalAccountsGermanyList.add(a);
            countDE++;
        }
        this.quantityAccountsGermany = this.finalAccountsGermanyList.size();

        Integer countAT = 0;
        for (Account a : accountsAustriaList) {
            if (countAT == 1000) break;
            this.finalAccountsAustriaList.add(a);
            countAT++;
        }
        this.quantityAccountsAustria = this.finalAccountsAustriaList.size();

        Integer countCHDE = 0;
        for (Account a : accountsSwitzerlandDEList) {
            if (countCHDE == 1000) break;
            this.finalAccountsSwitzerlandDEList.add(a);
            countCHDE++;
        }
        this.quantityAccountsSwitzerlandDE = this.finalAccountsSwitzerlandDEList.size();
    }


    /*******************************************************************************
    *  Name            : generateDataForReport()
    *  Summary         : generate Data For Report    
    *  CreatedDate     : 10/01/2016
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForReport() {
    	String selectedUserId = Apexpages.currentPage().getParameters().get('userid');
    	this.currentUser = [
            SELECT UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :selectedUserId
            LIMIT 1];

        this.endDatePeriod = Date.today();
        this.startDatePeriod = endDatePeriod.addMonths(-3);

        if (this.startDatePeriod.year() == this.endDatePeriod.year()) {
        	startDatePeriodString = String.valueOf(this.startDatePeriod.day()) + ' ' + monthsMap.get(this.startDatePeriod.month());
        	endDatePeriodString = String.valueOf(this.endDatePeriod.day()) + ' ' + monthsMap.get(this.endDatePeriod.month()) + ' ' + this.endDatePeriod.year();
        } else {
        	startDatePeriodString = String.valueOf(this.startDatePeriod.day()) + ' ' + monthsMap.get(this.startDatePeriod.month()) + ' ' + this.startDatePeriod.year();
        	endDatePeriodString = String.valueOf(this.endDatePeriod.day()) + ' ' + monthsMap.get(this.endDatePeriod.month()) + ' ' + this.endDatePeriod.year();
        }     
    }


    private Map<Integer, String> monthsMap = new Map<Integer, String>{
        1 => 'January', 
        2 => 'February', 
        3 => 'March',
        4 => 'April',
        5 => 'May',
        6 => 'June',
        7 => 'July',
        8 => 'August',
        9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'};
}