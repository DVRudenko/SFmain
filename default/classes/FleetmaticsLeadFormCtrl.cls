public class FleetmaticsLeadFormCtrl {
    public Lead newLead {get; set;}
    public String externalId {get; set;}
    public String ownerName {get; set;}
    public String ownerEmail {get; set;}
    public String ownerPhone {get; set;}
    public String leadSource {get; set;}
    public Boolean isValid {get; set;}
    public String selectedCountry {get; set;}


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : initialize new Lead    
    *  CreatedDate     : 21/04/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        isValid = false;
    	externalId = ApexPages.CurrentPage().getparameters().get('externalId');
        this.leadSource = 'Prospect';
        newLead = new Lead();
        ownerName = '';
        ownerEmail = '';
        ownerPhone = '';
    	if (externalId == 'nsle45HTlsm2snIJ93NjskO9JiwjcnW5') {
            isValid = true;
    	} else {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid external id!'));
    	}
    }


    /*******************************************************************************
    *  Name            : getLeadSources()
    *  Summary         : get LeadSource from page 
    *  CreatedDate     : 12/04/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getLeadSources() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Prospect', 'Prospect'));
        options.add(new SelectOption('Existing Customer', 'Existing Customer'));
        return options;
    }


    /*******************************************************************************
    *  Name            : createLead()
    *  Summary         : create new Lead with fields from form    
    *  CreatedDate     : 24/04/2017
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference createLead() {
        newLead.Sec_Channel__c = 'Partner';
        newLead.Channel__c = 'FLMT_Form';
        if (selectedCountry != 'No selection') {
            newLead.CountryCode = selectedCountry;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please choose country.'));
        }
        if (this.leadSource == 'Prospect') {
            newLead.LeadSource = 'Fleetmatics_new';
        } else if (this.leadSource == 'Existing customer') {
            newLead.LeadSource = 'Fleetmatics';
        }

        if (checkEmail(ownerEmail) == false) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid Sales Email field.'));
            return null;
        }

        try {
            insert newLead;
            Lead selectedLead = [
                    SELECT Country, RecordType.Name
                    FROM Lead 
                    WHERE Id = :newLead.Id];
            sendEmail(selectedLead);
            return new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/FleetmaticsLeadForm?externalId=nsle45HTlsm2snIJ93NjskO9JiwjcnW5');
        } catch (Exception e) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : send Email with form fields    
    *  CreatedDate     : 24/04/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail(Lead selectedLead) {
        Map<String, Fleetmatics_Notifications__c> notificationMap = Fleetmatics_Notifications__c.getAll();
        List<String> emailToSendList = new List<String>();
        if (! notificationMap.isEmpty()) {
            for (String notification : notificationMap.keySet()) {
                if (notificationMap.get(notification).Active__c == true) {
                    emailToSendList.add(notificationMap.get(notification).Email__c);
                }
            }
        }

        emailToSendList.add(ownerEmail);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailToSendList;
        message.subject = 'New Lead was successfully generated.';
        message.setSenderDisplayName('Salesforce Notfication');
        message.htmlBody = 'Sales contact information: <br/><br/>' + 
                'Name: ' + ownerName + '<br/>' + 
                'Email: ' + ownerEmail + '<br/>' +
                'Contact number: ' + ownerPhone + '<br/><br/>' + 
                'Lead information: <br/><br/>' +
                checkNull(this.leadSource) + '<br/>' +
                'Company Name: ' + checkNull(newLead.Company) + '<br/>' +
                'First Name: ' + checkNull(newLead.FirstName) + '<br/>' +
                'Last Name: ' + checkNull(newLead.LastName) + '<br/>' +
                'Country: ' + checkNull(selectedLead.Country) + '<br/>' + 
                'Sec. Channel: ' + checkNull(newLead.Sec_Channel__c) + '<br/>' +
                'Channel: ' + checkNull(newLead.Channel__c) + '<br/>' +
                'Position: ' + checkNull(newLead.Title) + '<br/>' +
                'Postal Code: ' + checkNull(newLead.PostalCode) + '<br/>' +
                'Phone: ' + checkNull(newLead.Phone) + '<br/>' +
                'Email Address: ' + checkNull(newLead.Email) + '<br/>' +
                'Total Fuel Consumption (l/month): ' + checkNull(String.valueOf(newLead.Monatlicher_Kraftstoffverbrauch_in_Liter__c)) + '<br/>' +
                'Number of vehicles: ' + checkNull(String.valueOf(newLead.Anzahl_der_Fahrzeuge__c)) + '<br/>' +
                'RecordType: ' + checkNull(selectedLead.RecordType.Name) + '<br/>' +
                'Notes: ' + checkNull(newLead.Note__c) + '<br/>';
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        messages.add(message);
        Messaging.sendEmail(messages);
    }


    /*******************************************************************************
    *  Name            : checkNull()
    *  Summary         : change "null" on " "    
    *  CreatedDate     : 02/05/2017
    *  Parameters      : String field
    *  Returns         : String
    ******************************************************************************/
    public String checkNull(String field) {
        if (field == null) {
            field = '';
        }
        return field;
    }

    /*******************************************************************************
    *  Name            : getCountry()
    *  Summary         : create pickList with country values    
    *  CreatedDate     : 09.06.2017
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getCountries() {
        List<SelectOption> countries = new List<SelectOption>();
        countries.add(new SelectOption('No selection', 'No selection'));
        countries.add(new SelectOption('AT', 'Austria'));
        countries.add(new SelectOption('BEFR', 'Belgium-FR'));
        countries.add(new SelectOption('BENL', 'Belgium-NL'));
        countries.add(new SelectOption('CZ', 'Czech Republic'));
        countries.add(new SelectOption('FR', 'France'));
        countries.add(new SelectOption('DE', 'Germany'));
        countries.add(new SelectOption('HU', 'Hungary'));
        countries.add(new SelectOption('LU', 'Luxemburg'));
        countries.add(new SelectOption('NL', 'Netherlands'));
        countries.add(new SelectOption('PL', 'Poland'));
        countries.add(new SelectOption('RU', 'Russia'));
        countries.add(new SelectOption('SK', 'Slovakia'));
        countries.add(new SelectOption('CHDE', 'Switzerland-DE'));
        countries.add(new SelectOption('CHFR', 'Switzerland-FR'));
        countries.add(new SelectOption('CHIT', 'Switzerland-IT'));
        return countries;
    }


    /*******************************************************************************
    *  Name            : checkEmail(String sEmail) 
    *  Summary         : check valid Email    
    *  CreatedDate     : 02/05/2017
    *  Parameters      : String sEmail - email to check
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean checkEmail(String sEmail) {
        Boolean returnValue = true;
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(sEmail);
        if (! MyMatcher.matches() ) {
           returnValue = false;
        }
        
        return returnValue;
    }
}