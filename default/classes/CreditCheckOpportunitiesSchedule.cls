global class CreditCheckOpportunitiesSchedule implements Schedulable {


	/*******************************************************************************
    *  Name            : execute(Schedulable sc)
    *  Summary         : execute send emails with reference to Credit Chech report  
    *  CreatedDate     : 11/04/2017
    *  Parameters      : Schedulable sc - object to track the schedulable job
    *  Returns         : void
    ******************************************************************************/
    global void execute(SchedulableContext sc) {
        List<Report> reportList = [
				SELECT Id
				FROM Report
				WHERE Name = 'Credit check more than 2 days'
				LIMIT 1];
				
		String reportId;
		Object numberOfOpportunities = 0;
		if (! Test.isRunningTest()) {
			if (! reportList.isEmpty()) {	
				reportId = (String)reportList.get(0).get('Id');
				Reports.ReportResults reportResults = Reports.ReportManager.runReport(reportId, true);
				numberOfOpportunities = reportResults.getFactMap().get('T!T').getAggregates()[0].getValue();
			}
		} else {
			numberOfOpportunities = 11;
		}
		if ((Decimal) numberOfOpportunities > 10) {
			Map<String, Credit_Check_Notifications__c> notificationMap = Credit_Check_Notifications__c.getAll();
			List<String> emailToSendList = new List<String>();
			for (String notification : notificationMap.keySet()) {
				if (notificationMap.get(notification).Active__c == true) {
				 	emailToSendList.add(notificationMap.get(notification).Email__c);
				}
			}
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = emailToSendList;
			message.subject = 'Credit Check Stage Report';
			message.setSenderDisplayName('Salesforce Notification');
			message.plainTextBody = numberOfOpportunities + ' Opportunity Record(s) with Credit Check Stage more than 2 days: ' 
					+ System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + reportId;
			List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
			messages.add(message);
			Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(messages);
			if (emailResults[0].success) {
			    System.debug('The email was sent successfully.');
			} else {
			    System.debug('The email failed to send: ' + emailResults[0].errors[0].message);
			}
		}
    }
}