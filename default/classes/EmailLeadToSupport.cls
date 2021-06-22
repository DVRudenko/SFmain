public with sharing class EmailLeadToSupport {
	public String leadId {get; set;}
    public EmailLeadToSupport() {

    }

    public PageReference sendEmailToSupport() {
    	leadId = Apexpages.currentPage().getParameters().get('leadId');
    	if (leadId == null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Lead Id.'));
    		return null;
    	}

    	User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];

    	if (currentUser.Profile.Name.contains('Inbound') || currentUser.Profile.Name.contains('System Administrator') ||
    		currentUser.Profile.Name.contains('Systemadministrator') || currentUser.Profile.Name.contains('Teamleiter') ||
    		currentUser.Profile.Name.contains('Harte Hanke (Sales)') || currentUser.Profile.Name.contains('API Only')) {
	    	try {
	    		Lead clead = [
	    			SELECT FirstName, LastName, Phone, Email, Country,
	    				   Status, Description, Contact_Email_Body__c,
	    				   Company, CountryCode
	    			FROM Lead
	    			WHERE Id = :leadId
	    			LIMIT 1];

	    		if (clead.Status != 'Open') {
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This action is available for Open Leads only.'));
	    			return null;
	    		}
	    		//send email
	    		List<Messaging.SingleEmailMessage> listtosend = new List<Messaging.SingleEmailMessage>();
		        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		        String sendtoemail = '';
		        if (clead.CountryCode == 'AT') {
		        	sendtoemail = 'kundenservice@fleetcor.at';
		        } else if (clead.CountryCode == 'BENL') {
		        	sendtoemail = 'klantendienst@fleetcorcards.be';
		        } else if (clead.CountryCode == 'BEFR') {
		        	sendtoemail = 'serviceclients@fleetcorcards.be';
		        } else if (clead.CountryCode == 'NL') {
					sendtoemail = 'klantenservice@fleetcor.nl';
		        } else if (clead.CountryCode == 'FR') {
		        	sendtoemail = 'serviceclients@fleetcor.fr';
		        } else if (clead.CountryCode == 'HU') {
		        	sendtoemail = 'kapcsolat@fleetcor.hu';
		        } else if (clead.CountryCode == 'PL') {
		        	sendtoemail = 'obslugaklienta@fleetcor.pl';
		        } else if (clead.CountryCode == 'DE') {
		        	sendtoemail = 'kundenservice@fleetcor.de';
		        } else if (clead.CountryCode == 'SK') {
		        	sendtoemail = 'backoffice@fleetcor.sk';
		        } else if (clead.CountryCode == 'CZ') {
		        	sendtoemail = 'backoffice@fleetcor.cz';
		        } else if (clead.CountryCode == 'LU') {
		        	sendtoemail = 'backoffice@fleetcor.lu';
		        } else if (clead.CountryCode == 'CHDE'){
					sendtoemail = 'kundenservice@fleetcor.ch';
				} else if (clead.CountryCode == 'CHFR'){
					sendtoemail = 'serviceclients@fleetcor.ch';
				} else if (clead.CountryCode == 'CHIT') {
		        	sendtoemail = 'backoffice@fleetcor.ch';
		        } else if (clead.Country == 'Eugene-Test') {
		        	sendtoemail = 'flash.log@gmail.com';
		        }

		        if (String.isBlank(sendtoemail)) {
		        	String availableCountries = 'Available countries for sending: Austria, Belgium Dutch, Belgium French, Netherlands, France, Hungary, Poland, Germany, ' +
		        		'Slovakia, Czech Republic, Luxembourg, Switzerland-IT, Switzerland-FR, Switzerland-DE.';
		        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invaild contact email. Check your country please. ' + availableCountries));
		        	return null;
		        }
		        String finalBody = 'Name: ' + (clead.FirstName != null ? clead.FirstName : '') + ' ' + (clead.LastName != null ? clead.LastName : '') + '<br/>' +
		        	'Company: ' + (clead.Company != null ? clead.Company : '') + '<br/>' +
		        	'Phone: ' + (clead.Phone != null ? clead.Phone : '') + '<br/>' +
		        	'Email: ' + (clead.Email != null ? clead.Email : '') + '<br/>' +
		        	(clead.Contact_Email_Body__c != null ? 'Email text: ' + clead.Contact_Email_Body__c : '');
		        String[] toAddresses = new String[] {sendtoemail};
		        mail.setToAddresses(toAddresses);
		        mail.setSenderDisplayName('SFDC');
		        mail.setSubject('Request from customer');
		        mail.setBccSender(false);
		        mail.setUseSignature(false);
		        mail.setHtmlBody(finalBody);
		        listtosend.add(mail);

		        if (! Test.isRunningTest()) {
		        	Messaging.sendEmail(listtosend);
		        }

		        clead.Status = 'Disqualified';
	       		clead.Quali_Status__c = 'Sent to support';
	       		update clead;

		        return new PageReference('/00Q/o');
	    	} catch (Exception e) {
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	    	}
    	} else {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This action is available for Sales Inbound or Team leaders only.'));
    	}

    	return null;
    }
}