@isTest
private class LeadSetToContactedControllerTest {
    static testMethod void changeLeadAndCreateTaskTest() {
        Lead lead = new Lead(Status = 'Normal', Country = 'Germany', LastName = 'Ivanov', Company = 'Company');
        insert lead;
        ApexPages.currentPage().getParameters().put('id', lead.Id);

        Test.startTest();
        	LeadSetToContactedController controller = new LeadSetToContactedController();
        	controller.init();
        	controller.save();
        	controller.cancel();
        Test.stopTest();

        Lead ld = [
        		SELECT Status
        		FROM Lead];

        Task tk = [
        		SELECT Subject, ActivityDate, Priority, ReminderDateTime, IsReminderSet
        		FROM Task
        		WHERE WhoId = :lead.Id];
    }
}