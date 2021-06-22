public with sharing class DashboardSalesDirectorCtrl {
	public String userId {get; set;}
	public String userName {get; set;}
	public String teamType {get; set;}

    public DashboardSalesDirectorCtrl() {        
    }

    public void init(){
    	teamType = 'Teamleiter Inbound';
    	selectTeamType();
    }

	public void selectTeamType() {
		List<User> usersList = [
				SELECT Id, LastName, FirstName 
				FROM User 
				WHERE UserRole.Name = :teamType OR (Profile.Name = :teamType AND Name = 'Oskar Ehehalt') LIMIT 1];
					
		if ( ! usersList.isEmpty() ) {
			userId = usersList.get(0).Id;
			userName = usersList.get(0).FirstName +' '+ usersList.get(0).LastName;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No User with selected role'));
		}
	}

	public List<SelectOption> getTeamTypes(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('Teamleiter Inbound','Teamleiter Inbound'));
		options.add(new SelectOption('Teamleiter Inbound 2','Teamleiter Inbound 2'));
		options.add(new SelectOption('CCS Telesales Team Lead', 'CCS Telesales Team Lead'));
		options.add(new SelectOption('CCS SME Team Lead', 'CCS SME Team Lead'));
		options.add(new SelectOption('CCS CZ KAM Team Lead', 'CCS CZ KAM Team Lead'));
		options.add(new SelectOption('CCS CZ LAM Team Lead', 'CCS CZ LAM Team Lead'));
		options.add(new SelectOption('Starts Team Manager', 'Starts Team Manager'));
		return options;
	}
}