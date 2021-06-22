public with sharing class NumberOfLeadsOnAccountReportCtrl {
    public String thisMonth {get;set;}
	public String lastMonth {get;set;}
	public String penaltMonth {get;set;}
	public List<Lead> listLeadsWithCreatedDateInThisMonth {get;set;}
	public List<Lead> listLeadsWithCreatedDateInLastMonth {get;set;}
	public List<Lead> listLeadsWithCreatedDateInPenaltMonth {get;set;}
	public void init() {
		thisMonth = monthsMap.get(date.today().month());
		lastMonth = monthsMap.get(date.today().addMonths(-1).month());
		penaltMonth = monthsMap.get(date.today().addMonths(-2).month());
		RecordType retailerRecordType = [
    			SELECT Name 
    			FROM RecordType 
    			WHERE Name = 'Retailer' AND SobjectType = 'Account'];
		String currentId = ApexPages.currentPage().getParameters().get('id');
		Account parentAccount = [
				SELECT Name, RecordTypeId
				FROM Account 
				WHERE Id = :currentId
				LIMIT 1];
		if (parentAccount.RecordTypeId == retailerRecordType.Id) {
	    	Set<Id> accountIdSet = new Set<Id>();
	    	accountIdSet.add(currentId);
			List<Account> childAccountList = [
					SELECT Name
					FROM Account
					WHERE ParentId = :currentId AND RecordTypeId = :retailerRecordType.Id];
			for (Account account : childAccountList) {
				accountIdSet.add(account.Id);
			}

			List<Lead> leadList = [
					SELECT Name, CreatedDate, FirstName, LastName, Status, Channel__c, Sec_Channel__c, LeadSource, OwnerId
					FROM Lead
					WHERE Partner__c IN :accountIdSet AND CreatedDate > :date.today().addMonths(-3)];
			listLeadsWithCreatedDateInThisMonth = new List<Lead>();
			listLeadsWithCreatedDateInLastMonth = new List<Lead>();
			listLeadsWithCreatedDateInPenaltMonth = new List<Lead>();

			for (Lead lead : leadList) {
				if (lead.CreatedDate.month() == date.today().month() && lead.CreatedDate.year() == date.today().year()) {
					listLeadsWithCreatedDateInThisMonth.add(lead);
				}

				if (lead.CreatedDate.month() == date.today().addMonths(-1).month() && lead.CreatedDate.year() == date.today().year()) {
					listLeadsWithCreatedDateInLastMonth.add(lead);
				} 

				if (lead.CreatedDate.month() == date.today().addMonths(-2).month() && lead.CreatedDate.year() == date.today().year()) {
					listLeadsWithCreatedDateInPenaltMonth.add(lead);
				}

				if (date.today().month() == 1) {
					if (lead.CreatedDate.month() == date.today().addMonths(-1).month() && lead.CreatedDate.year() == date.today().addYears(-1).year()) {
						listLeadsWithCreatedDateInLastMonth.add(lead);
					} 

					if (lead.CreatedDate.month() == date.today().addMonths(-2).month() && lead.CreatedDate.year() == date.today().addYears(-1).year()) {
						listLeadsWithCreatedDateInPenaltMonth.add(lead);
					}
				} else if (date.today().month() == 2) {
					if (lead.CreatedDate.month() == date.today().addMonths(-2).month() && lead.CreatedDate.year() == date.today().addYears(-1).year()) {
						listLeadsWithCreatedDateInPenaltMonth.add(lead);
					}
				}
			}
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
        12 => 'December'
    };
}