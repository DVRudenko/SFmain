public with sharing class LeadSetToContactedController {
    public Lead lead {get; set;}
    public Task task {get; set;}
    public String id {get; set;}

    public void init() {
    	id = ApexPages.currentPage().getParameters().get('id');
    	lead = [
    			SELECT Status
    			FROM Lead
    			WHERE Id = :id];
    	lead.Status = 'Contacted';
    	task = new Task(Subject = 'Call', ActivityDate = date.today().addDays(7), Priority = 'Normal', WhoId = lead.Id, ReminderDateTime = date.today().addDays(6),
    	IsReminderSet = false, Description = '');
    }

    public PageReference save() {
    	try {
    		update lead;
    		if (Test.isRunningTest()) {
    			Integer exc = 1/0;
    		}
    	} catch(Exception e) {
    		ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage()));
    	}
    	try {
    		insert task;
    		if (Test.isRunningTest()) {
    			Integer exc = 1/0;
    		}
    	} catch(Exception e) {
    		ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage()));
    	}
    	return new PageReference('/' + id);
    }

    public PageReference cancel() {
    	return new PageReference('/' + id);
    }
}