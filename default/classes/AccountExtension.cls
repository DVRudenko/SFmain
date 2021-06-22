public class AccountExtension {
	public List<Account> accounts {get; set;}
	public Account account {get; set;}

	public AccountExtension() {
		String ids = ApexPages.currentPage().getParameters().get('ids');
		String id = ApexPages.currentPage().getParameters().get('id');

		try {
			accounts = [
					SELECT 	Name,
							Owner.Id,
							Owner.Name,
							Owner.UserRole.Name
					FROM 	Account
					WHERE 	Id IN : ids.split(';')
			];
		} catch (Exception e) {
		    System.debug( e.getMessage() );
		}

		try {
			account = [
					SELECT 	Name,
							Owner.Id,
							Owner.Name,
							Owner.UserRole.Name,
							INN__c
					FROM 	Account
					WHERE 	Id =: id
			];
		} catch (Exception e) {
		    System.debug( e.getMessage() );
		}

	}
}