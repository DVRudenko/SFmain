public class TransactionsReportKontomatikService implements TransactionsReport {
	private String defaultImportCommandId;
	private String defaultImportCommandStatus;
	private String defaultImportCommandStatusBody;
	private List<BankAccount> bankAccountsList;
	private List<BankAccountOwner> bankAccountOwnersList;
	private List<BankAccountTransaction> bankAccountTransactionsList;
	private TransactionsCompany transactionsCompany;


	/*******************************************************************************
	*  Name            : setDefaultImportCommandId(CreditSystem creditSystem, String sessionId, String sessionIdSignature)
	*  Summary         : Send Import Command request and set id from response    
	*  CreatedDate     : 11/04/2018
	*  ModifiedDate    : -
	*  Parameters      : CreditSystem creditSystem - credit system credentials, String sessionId - id of bank session, 
						 String sessionIdSignature - id signature of bank session.
	*  Returns         : void
	******************************************************************************/
	public void setDefaultImportCommandId(CreditSystem creditSystem, String sessionId, String sessionIdSignature) {
		try {
		    HttpRequest request = KontomatikWebService.generateDefaultImportRequest(
		    	creditSystem.getApiKey(), sessionId, sessionIdSignature, creditSystem.getEndpointUrl());
			Http http = new Http();
			HttpResponse response = http.send(request);
			Dom.Document domDocument = new Dom.Document();
		    domDocument.load(response.getBody());
		    Dom.XMLNode xmlDom = domDocument.getRootElement();
		    this.defaultImportCommandId = KontomatikWebService.returnDefaultImportCommandId(xmlDom);
		} catch (Exception e) {
		    System.debug('Transactions === ' + e.getMessage());
            throw new TransactionsException('Set command Id error. ' + e.getMessage());
		}
	}


	/*******************************************************************************
	*  Name            : getDefaultImportCommandId()
	*  Summary         : Return Import Command Id    
	*  CreatedDate     : 11/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public String getDefaultImportCommandId() {
		return this.defaultImportCommandId;
	}


	/*******************************************************************************
	*  Name            : setDefaultImportCommandStatus(CreditSystem creditSystem, String sessionId, String sessionIdSignature, String defaultImportCommandId)
	*  Summary         : Send request by Command Id
	*  CreatedDate     : 11/04/2018
	*  ModifiedDate    : -
	*  Parameters      : CreditSystem creditSystem - credit system credentials, String sessionId - id of bank session, 
						 String sessionIdSignature - id signature of bank session, String defaultImportCommandId - id from previos request.
	*  Returns         : String
	******************************************************************************/
	public void setDefaultImportCommandStatus(CreditSystem creditSystem, String sessionId, String sessionIdSignature, String defaultImportCommandId) {
		try {
		    HttpRequest request = KontomatikWebService.generateCommandStatusRequest(
		    	creditSystem.getApiKey(), sessionId, sessionIdSignature, creditSystem.getEndpointUrl(), defaultImportCommandId);
			Http http = new Http();
			HttpResponse response = http.send(request);
			this.defaultImportCommandStatusBody = response.getBody();
			Dom.Document domDocument = new Dom.Document();
		    domDocument.load(defaultImportCommandStatusBody);
		    Dom.XMLNode xmlDom = domDocument.getRootElement();
		    this.defaultImportCommandStatus = KontomatikWebService.returnDefaultImportCommandStatus(xmlDom);
		} catch (Exception e) {
		    System.debug('Transactions === ' + e.getMessage());
            throw new TransactionsException('Return command status error. ' + e.getMessage());
		}
	}


	/*******************************************************************************
	*  Name            : getDefaultImportCommandStatus()
	*  Summary         : Return Import Command Status    
	*  CreatedDate     : 12/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public String getDefaultImportCommandStatus() {
		return this.defaultImportCommandStatus;
	}


	/*******************************************************************************
	*  Name            : setBankAccounts()
	*  Summary         : Set Bank Accounts information from response body.
	*  CreatedDate     : 13/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setBankAccounts() {
		try {
			String xml = this.defaultImportCommandStatusBody;
			Dom.Document domDocument = new Dom.Document();
			domDocument.load(xml);
			Dom.XMLNode xmlDom = domDocument.getRootElement();
			this.bankAccountsList = KontomatikWebService.returnBankAccounts(xmlDom);  
		} catch (Exception e) {
		    System.debug('Transactions === ' + e.getMessage());
            throw new TransactionsException('Set Bank Accounts error. ' + e.getMessage());
		}
	}


	/*******************************************************************************
	*  Name            : setBankAccountTransactions()
	*  Summary         : Set Bank Account Transactions information from response body    
	*  CreatedDate     : 13/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setBankAccountTransactions() {
		try {
		 	String xml = this.defaultImportCommandStatusBody;
			Dom.Document domDocument = new Dom.Document();
			domDocument.load(xml);
			Dom.XMLNode xmlDom = domDocument.getRootElement();
			this.bankAccountTransactionsList = KontomatikWebService.returnBankAccountTransactions(xmlDom);   
		} catch (Exception e) {
		    System.debug('DEBUG: Transactions === ' + e.getMessage());
		    throw new TransactionsException('Set Bank Account Transactions error. ' + e.getMessage());
		}
	}


	/*******************************************************************************
	*  Name            : setBankAccountOwners()
	*  Summary         : Set Bank Account Owners information from response body
	*  CreatedDate     : 13/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setBankAccountOwners() {
		try {
			String xml = this.defaultImportCommandStatusBody;
			Dom.Document domDocument = new Dom.Document();
			domDocument.load(xml);
			Dom.XMLNode xmlDom = domDocument.getRootElement();
			this.bankAccountOwnersList = KontomatikWebService.returnBankAccountOwners(xmlDom);   
		} catch (Exception e) {
		    System.debug('DEBUG: Transactions === ' + e.getMessage());
		    throw new TransactionsException('Set Bank Account Owners error. ' + e.getMessage());
		}
	}


	/*******************************************************************************
	*  Name            : setTransactionsCompany(CreditSystem creditSystem, String ownerExternalId)
	*  Summary         : Set Transactions Company information from response body.    
	*  CreatedDate     : 13/04/2018
	*  ModifiedDate    : -
	*  Parameters      : CreditSystem creditSystem - credit system credentials,
						 String ownerExternalId - opportunity Id
	*  Returns         : void
	******************************************************************************/
	public void setTransactionsCompany(CreditSystem creditSystem, String ownerExternalId) {
		try {
			HttpRequest request = KontomatikWebService.generateFinancialHealthIndicatorRequest(
		    	creditSystem.getApiKey(), creditSystem.getEndpointUrl(), ownerExternalId);
			Http http = new Http();
			HttpResponse response = http.send(request);
			Dom.Document domDocument = new Dom.Document();
		    domDocument.load(response.getBody());
		    Dom.XMLNode xmlDom = domDocument.getRootElement();
		    this.transactionsCompany = KontomatikWebService.returnTransactionsCompany(xmlDom);   
		} catch (Exception e) {
		    System.debug('DEBUG: Transactions === ' + e.getMessage());
		    throw new TransactionsException('Set Transaction Company error. ' + e.getMessage());
		}
	}


	/*******************************************************************************
	*  Name            : saveReport()
	*  Summary         : Save Transaction Report object and its children
	*  CreatedDate     : 13/04/2018
	*  ModifiedDate    : -
	*  Parameters      : String opportunityId - id of opportunity related to report
	*  Returns         : void
	******************************************************************************/
	public void saveReport(String opportunityId) {
		try {
		    Transactions_Report__c newTransactionsReport = saveTransactionsReport(opportunityId);
			List<Bank_Account__c> newBankAccountsList = saveBankAccounts(newTransactionsReport.Id);
			saveBankAccountTransactions(newBankAccountsList);
			saveBankAccountOwners(newTransactionsReport.Id);
		} catch (Exception e) {
		    System.debug('DEBUG: Transactions === ' + e.getMessage());
		    throw new TransactionsException('Save Transaction Report error. ' + e.getMessage());
		}
	}


	/*******************************************************************************
	*  Name            : saveTransactionsReport(String opportunityId)
	*  Summary         : Save Transactions report object    
	*  CreatedDate     : 16/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Transactions_Report__c
	******************************************************************************/
	private Transactions_Report__c saveTransactionsReport(String opportunityId) {
		Transactions_Report__c newTransactionsReport = new Transactions_Report__c(
			Value__c = this.transactionsCompany.value,
			Period_Days__c = this.transactionsCompany.periodDays,
			Period_Start_At__c = this.transactionsCompany.periodStartAt,
			Period_End_At__c = this.transactionsCompany.periodEndAt,
			Average__c = this.transactionsCompany.average,
			Median__c = this.transactionsCompany.median,
			Opportunity__c = opportunityId);
		insert newTransactionsReport;
		return newTransactionsReport;
	}


	/*******************************************************************************
	*  Name            : saveBankAccounts(String transactionsReportId)
	*  Summary         : Save Transactions report Id    
	*  CreatedDate     : 16/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : List<Bank_Account__c>
	******************************************************************************/
	private List<Bank_Account__c> saveBankAccounts(String transactionsReportId) {
		List<Bank_Account__c> newBankAccountsList = new List<Bank_Account__c>();
		for (BankAccount bankAccount : this.bankAccountsList) {
			Bank_Account__c newBankAccount = new Bank_Account__c(
				Name = bankAccount.name,
				Friendly_Name__c = bankAccount.friendlyName,
				Iban__c = bankAccount.iban,
				Currency_Balance__c = bankAccount.currencyBalance,
				Currency_Funds_Available__c = bankAccount.currencyFundsAvailable,
				Currency_Name__c = bankAccount.currencyName,
				Owner__c = bankAccount.owner,
				Active_Since_At_Least__c = bankAccount.activeSinceAtLeast,
				Direct_Debit_Available__c = bankAccount.directDebitAvailable,
				Internal_Number__c = bankAccount.internalNumber,
				Transactions_Report__c = transactionsReportId);
			newBankAccountsList.add(newBankAccount);
		}
		insert newBankAccountsList;
		return newBankAccountsList;
	}


	/*******************************************************************************
	*  Name            : saveBankAccountTransactions(List<Bank_Account__c)
	*  Summary         : Save Bank Account Transactions   
	*  CreatedDate     : 16/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void saveBankAccountTransactions(List<Bank_Account__c> newBankAccountsList) {
		List<Bank_Account_Transaction__c> newBankAccountTransactionsList = new List<Bank_Account_Transaction__c>();
		for (Bank_Account__c newBankAccount : newBankAccountsList) {
			for (BankAccountTransaction bankAccountTransaction : this.bankAccountTransactionsList) {
				if (newBankAccount.Internal_Number__c == bankAccountTransaction.bankAccountInternalNumber) {
					Bank_Account_Transaction__c newBankAccountTransaction = new Bank_Account_Transaction__c(
						Transaction_On__c = bankAccountTransaction.transactionOn,
						Booked_On__c = bankAccountTransaction.bookedOn,
						Currency_Amount__c = bankAccountTransaction.currencyAmount,
						Currency_Balance__c = bankAccountTransaction.currencyBalance,
						Party_Iban__c = bankAccountTransaction.partyIban,
						Party__c = bankAccountTransaction.party,
						Title__c = bankAccountTransaction.title,
						Kind__c = bankAccountTransaction.kind,
						Variable_Symbol__c = bankAccountTransaction.variableSymbol,
						Labels__c = bankAccountTransaction.labels,
						Bank_Account_Internal_Number__c = bankAccountTransaction.bankAccountInternalNumber,
						Bank_Account__c = newBankAccount.Id);
					newBankAccountTransactionsList.add(newBankAccountTransaction);
				}
			}
		}
		insert newBankAccountTransactionsList;
	}


	/*******************************************************************************
	*  Name            : saveBankAccountOwners(String transactionsReportId)
	*  Summary         : Save Bank Account Owners    
	*  CreatedDate     : 16/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void saveBankAccountOwners(String transactionsReportId) {
		List<Bank_Account_Owner__c> newBankAccountOwnersList = new List<Bank_Account_Owner__c>();
		for (BankAccountOwner bankAccountOwner : this.bankAccountOwnersList) {
			Bank_Account_Owner__c newBankAccountOwner = new Bank_Account_Owner__c(
				Kind__c = bankAccountOwner.kind,
				Name = bankAccountOwner.name,
				Address__c = bankAccountOwner.address,
				Polish_Pesel__c = bankAccountOwner.polishPesel,
				Polish_Nip__c = bankAccountOwner.polishNip,
				Phone__c = bankAccountOwner.phone,
				Email__c = bankAccountOwner.email,
				Citizenship__c = bankAccountOwner.citizenship,
				Nationality__c = bankAccountOwner.nationality,
				Personal_Document_Type__c = bankAccountOwner.personalDocumentType,
				Personal_Document_Number__c = bankAccountOwner.personalDocumentNumber,
				Birth_Date__c = bankAccountOwner.birthDate,
				Polish_Regon__c = bankAccountOwner.polishRegon,
				Birth_Place__c = bankAccountOwner.birthPlace,
				Transactions_Report__c = transactionsReportId);
			newBankAccountOwnersList.add(newBankAccountOwner);
		}
		insert newBankAccountOwnersList;
	}
}