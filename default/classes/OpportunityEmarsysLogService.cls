public class OpportunityEmarsysLogService {
	public Map<Id, List<String>> oppIdToCampaignMap;
	public Map<Id, List<String>> oppIdToCampaignDetailsMap;
	public List<Opportunity> opportunitiesWithoutEmarsysLog;
	/*******************************************************************************
	*  Name            : checkOpportunities(List<Opportunity> oppList)
	*  Summary         : Check emarsys logs in opportunities    
	*  CreatedDate     : 11/04/2019
	*  ModifiedDate    : -
	*  Parameters      : List<Opportunity> oppList - list opportunities from batch
	*  Returns         : List<Opportunity>
	******************************************************************************/
	public List<Opportunity> checkOpportunities(List<Opportunity> oppList) {
		this.opportunitiesWithoutEmarsysLog = new List<Opportunity>();
		this.oppIdToCampaignMap = new Map<Id, List<String>>();
		this.oppIdToCampaignDetailsMap = new Map<Id, List<String>>();
		for (Opportunity opp : oppList) {
			if ( ! this.oppIdToCampaignMap.containsKey(opp.Id) && ! this.oppIdToCampaignDetailsMap.containsKey(opp.Id)) {
				this.oppIdToCampaignMap.put(opp.Id, new List<String>());
				this.oppIdToCampaignDetailsMap.put(opp.Id, new List<String>());
			}

			// Upgraded to E2E 
			if (opp.Account.BillingCountry == 'Germany' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isManualUpgradedToE2E(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Manual Upgrade To E2E DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Manual Upgrade To E2E DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Manual Upgrade To E2E DE 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Manual Upgrade To E2E DE 1');
    				}
				} else if (isManualUpgradedToE2E(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Manual Upgrade To E2E DE 1') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Manual Upgrade To E2E DE')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Manual Upgrade To E2E DE');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Manual Upgrade To E2E DE 1')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Manual Upgrade To E2E DE 1');
		    				}
						}
					}
				}

				if (isDirectDebitNoDeposit(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 1. Direct Debit - No Deposit')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 1. Direct Debit - No Deposit');
    				}
				} else if (isDirectDebitNoDeposit(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 1. Direct Debit - No Deposit') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 1. Direct Debit - No Deposit')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 1. Direct Debit - No Deposit');
		    				}
						}
					}
				}

				if (isDirectDebitAccept(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 2. Direct Debit - ACCEPT')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 2. Direct Debit - ACCEPT');
    				}
				} else if (isDirectDebitAccept(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 2. Direct Debit - ACCEPT') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 2. Direct Debit - ACCEPT')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 2. Direct Debit - ACCEPT');
		    				}
						}
					}
				}

				if (isDirectDebitCancelDecline(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 3. Direct Debit - CANCEL/DECLINE')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 3. Direct Debit - CANCEL/DECLINE');
    				}
				} else if (isDirectDebitCancelDecline(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 3. Direct Debit - CANCEL/DECLINE') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 3. Direct Debit - CANCEL/DECLINE')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 3. Direct Debit - CANCEL/DECLINE');
		    				}
						}
					}
				}

				if (isDirectDebitException(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 4. Direct Debit - EXCEPTION')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 4. Direct Debit - EXCEPTION');
    				}
				} else if (isDirectDebitException(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 4. Direct Debit - EXCEPTION') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 4. Direct Debit - EXCEPTION')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 4. Direct Debit - EXCEPTION');
		    				}
						}
					}
				}

				if (isBankTransferNoDeposit(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 5. BT No Deposit')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 5. BT No Deposit');
    				}
				} else if (isBankTransferNoDeposit(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 5. BT No Deposit') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 5. BT No Deposit')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 5. BT No Deposit');
		    				}
						}
					}
				}

				if (isBankTransferAccept(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 6. BT Accept')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 6. BT Accept');
    				}
				} else if (isBankTransferAccept(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 6. BT Accept') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 6. BT Accept')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 6. BT Accept');
		    				}
						}
					}
				}

				if (isBankTransferCancelDecline(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 7. BT - CANCEL/DECLINE')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 7. BT - CANCEL/DECLINE');
    				}
				} else if (isBankTransferCancelDecline(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 7. BT - CANCEL/DECLINE') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 7. BT - CANCEL/DECLINE')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 7. BT - CANCEL/DECLINE');
		    				}
						}
					}
				}

				if (isBankTransferException(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 8. BT - EXCEPTION')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 8. BT - EXCEPTION');
    				}
				} else if (isBankTransferException(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 8. BT - EXCEPTION') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation DE')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation DE');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation DE - 8. BT - EXCEPTION')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation DE - 8. BT - EXCEPTION');
		    				}
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Abandonment Email DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Abandonment Email DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Abandonment Email DE 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Abandonment Email DE 1');
    				}
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Abandonment Email DE');
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Save And Continue DE')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Save And Continue DE');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Save And Continue DE 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Save And Continue DE 1');
    				}
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Save And Continue DE');
				}
			}

			if (opp.Account.BillingCountry == 'Netherlands' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isManualUpgradedToE2E(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Manual Upgrade To E2E NL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Manual Upgrade To E2E NL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Manual Upgrade To E2E NL 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Manual Upgrade To E2E NL 1');
    				}
				} else if (isManualUpgradedToE2E(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Manual Upgrade To E2E NL 1') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Manual Upgrade To E2E NL')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Manual Upgrade To E2E NL');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Manual Upgrade To E2E NL 1')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Manual Upgrade To E2E NL 1');
		    				}
						}
					}
				}

				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation NL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation NL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation - NL')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation - NL');
    				}
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - NL') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation NL')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation NL');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation - NL')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation - NL');
		    				}
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Abandonment Email NL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Abandonment Email NL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Abandonment Email NL 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Abandonment Email NL 1');
    				}
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Abandonment Email NL');
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Save And Continue NL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Save And Continue NL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Save And Continue NL 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Save And Continue NL 1');
    				}
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Save And Continue NL');
				}
			}

			if (opp.Account.BillingCountry == 'Belgium-NL' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Save And Continue BENL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Save And Continue BENL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Save And Continue BENL')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Save And Continue BENL');
    				}
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - BENL') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Save And Continue BENL')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Save And Continue BENL');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Save And Continue BENL')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Save And Continue BENL');
		    				}
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Abandonment Email BENL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Abandonment Email BENL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Abandonment Email BENL 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Abandonment Email BENL 1');
    				}
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Abandonment Email BENL');
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Save And Continue BENL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Save And Continue BENL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Save And Continue BENL 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Save And Continue BENL 1');
    				}
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Save And Continue BENL');
				}
			}

			if (opp.Account.BillingCountry == 'Belgium-FR' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation BEFR')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation BEFR');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation BEFR')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation BEFR');
    				}
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - BEFR') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation BEFR')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation BEFR');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation BEFR')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation BEFR');
		    				}
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Abandonment Email BEFR')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Abandonment Email BEFR');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Abandonment Email BEFR 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Abandonment Email BEFR 1');
    				}
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Abandonment Email BEFR');
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Save And Continue BEFR')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Save And Continue BEFR');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Save And Continue BEFR 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Save And Continue BEFR 1');
    				}
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Save And Continue BEFR');
				}
			}

			if (opp.Account.BillingCountry == 'Poland' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation PL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation PL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation - PL')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation - PL');
    				}
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - PL') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation PL')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation PL');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation - PL')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation - PL');
		    				}
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Abandonment Email PL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Abandonment Email PL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Abandonment Email PL 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Abandonment Email PL 1');
    				}
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Abandonment Email PL');
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Save And Continue PL')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Save And Continue PL');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Save And Continue PL 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Save And Continue PL 1');
    				}
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Save And Continue PL');
				}
			}

			if (opp.Account.BillingCountry == 'Hungary' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation HU')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation HU');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation - HU')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation - HU');
    				}
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - HU') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation HU')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation HU');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation - HU')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation - HU');
		    				}
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Abandonment Email HU')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Abandonment Email HU');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Abandonment Email HU 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Abandonment Email HU 1');
    				}
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Abandonment Email HU');
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Save And Continue HU')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Save And Continue HU');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Save And Continue HU 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Save And Continue HU 1');
    				}
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Save And Continue HU');
				}
			}

			if (opp.Account.BillingCountry == 'France' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation FR')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation FR');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation - FR')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation - FR');
    				}
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - FR') {
							opportunitiesWithoutEmarsysLog.add(opp);
							if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Order Confirmation FR')) {
		    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Order Confirmation FR');
		    				}
		    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Order Confirmation - FR')) {
		    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Order Confirmation - FR');
		    				}
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Abandonment Email FR')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Abandonment Email FR');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Abandonment Email FR 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Abandonment Email FR 1');
    				}
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Abandonment Email FR');
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
					if ( ! this.oppIdToCampaignMap.get(opp.Id).contains('E2E Save And Continue FR')) {
    					this.oppIdToCampaignMap.get(opp.Id).add('E2E Save And Continue FR');
    				}
    				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains('E2E Abandonment Email FR 1')) {
    					this.oppIdToCampaignDetailsMap.get(opp.Id).add('E2E Abandonment Email FR 1');
    				}
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					checkEmarsysCampaign(opp, 'E2E Save And Continue FR');
				}
			}
		}

		return this.opportunitiesWithoutEmarsysLog;
	}


	/*******************************************************************************
	*  Name            : checkEmarsysCampaign(Opportunity opp, String campaign)
	*  Summary         : Check emarsys campaign    
	*  CreatedDate     : 03/05/2019
	*  ModifiedDate    : -
	*  Parameters      : Opportunity opp, String campaign
	*  Returns         : void
	******************************************************************************/
	private void checkEmarsysCampaign(Opportunity opp, String campaign) {
		Datetime campaignEndDate = calculateCampaignEndDate(opp);
		Decimal daysAfteroppCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
		for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
			if ((daysAfteroppCreation < 2 && emarsysLog.Email_Name__c != (campaign + ' 1')) || 
				(daysAfteroppCreation > 2 && daysAfteroppCreation <= 4 && emarsysLog.Email_Name__c != (campaign + ' 2')) || 
				(daysAfteroppCreation > 4 && emarsysLog.Email_Name__c != (campaign + ' 3')) ) {
				this.opportunitiesWithoutEmarsysLog.add(opp);
				if ( ! this.oppIdToCampaignMap.get(opp.Id).contains(campaign)) {
					this.oppIdToCampaignMap.get(opp.Id).add(campaign);
				}
			}

			if ( daysAfteroppCreation < 2 && emarsysLog.Email_Name__c != (campaign + ' 1') ) {
				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains((campaign + ' 1'))) {
					this.oppIdToCampaignDetailsMap.get(opp.Id).add((campaign + ' 1'));
				}
			} else if ( daysAfteroppCreation > 2 && daysAfteroppCreation <= 4 && emarsysLog.Email_Name__c != (campaign + ' 2') ) {
				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains((campaign + ' 2'))) {
					this.oppIdToCampaignDetailsMap.get(opp.Id).add((campaign + ' 2'));
				}
			} else if ( daysAfteroppCreation > 4 && emarsysLog.Email_Name__c != (campaign + ' 3') ) {
				if ( ! this.oppIdToCampaignDetailsMap.get(opp.Id).contains((campaign + ' 3'))) {
					this.oppIdToCampaignDetailsMap.get(opp.Id).add((campaign + ' 3'));
				}
			}
		}
	}


	/*******************************************************************************
	*  Name            : calculateCampaignEndDate(Opportunity opp)
	*  Summary         : Calculate campaign end date    
	*  CreatedDate     : 12/04/2019
	*  ModifiedDate    : -
	*  Parameters      : Opportunity opp
	*  Returns         : Datetime
	******************************************************************************/
	private Datetime calculateCampaignEndDate(Opportunity opp) {
		Datetime endDate = Datetime.now();
		for (OpportunityFieldHistory ofh : opp.Histories) {
            if (ofh.OldValue == 'Marketing automation' && ofh.NewValue == 'Switched to manual') {
                endDate = ofh.CreatedDate;
                break;
            }
        }
        return endDate;
	}


	/*******************************************************************************
    *  Name            : createExcelDocument(List<Opportunity> opportunitiesWithoutEmarsysLog)
    *  Summary         : Generate excel document and insert in the Emarsys Logs folder    
    *  CreatedDate     : 11/04/2019
    *  ModifiedDate    : -
    *  Parameters      : List<Opportunity> opportunitiesWithoutEmarsysLog - List of opportunities without emarsys logs
    *  Returns         : void
    ******************************************************************************/
    public void createExcelDocument(List<Opportunity> opportunitiesWithoutEmarsysLog) {
    	List<Opportunity> oppListForReport = new List<Opportunity>();
    	oppListForReport = checkOpportunities(opportunitiesWithoutEmarsysLog);
    	List<Folder> folderList = [SELECT Id, Name FROM Folder WHERE Name = 'Emarsys Logs'];
        Document document = new Document();
        document.FolderId = folderList.get(0).Id;
    	String body = '';
        for (Opportunity opp : oppListForReport) {
        	if ( ! body.contains(opp.Id)) {
        		body += 'Opportunity ID = ' + opp.Id + ', Name = ' + opp.Name + ', Country = ' + opp.Account.BillingCountry + ', campaign = ' + this.oppIdToCampaignMap.get(opp.Id) + ', details: no ' + this.oppIdToCampaignDetailsMap.get(opp.Id) + '\r';
        	}
        }
        document.Body = Blob.valueOf(body);
        document.Name = 'Opportunities' + Datetime.now() + '.xls';
        Database.insert(document);
    }


    //  E2E Manual Upgraded To E2E (Germany, Netherlands)
	private static Boolean isManualUpgradedToE2E(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'Manual upgraded to E2E' && ofh.NewValue != 'Manual upgraded to E2E') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
		}
	    if ((opp.E2E_Sales_Type__c == 'Manual upgraded to E2E' || isActOfE2ECampaign == true) && 
	    	(opp.StageName != 'Closed Won' || opp.StageName != 'Closed Won') && 
	    	opp.Sec_Channel__c == 'Inbound') {
	        return true;
	    }
	    return false;
	}

	//  E2E Order Confirmation DE - 1. Direct Debit No Deposit (Germany)
	private static Boolean isDirectDebitNoDeposit(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'NO DEPOSIT' && ofh.NewValue != 'NO DEPOSIT') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
		}
	    if (opp.Zahlungsart__c == 'Lastschrift' && 
	    	(opp.E2E_payment_status__c == 'NO DEPOSIT' || isActOfE2ECampaign == true) && 
	    	(opp.Security_Amount_To_Pay__c == null || opp.Security_Amount_To_Pay__c == 0) && 
	    	(opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 2. Direct Debit ACCEPT (Germany)
	private static Boolean isDirectDebitAccept(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'ACCEPT' && ofh.NewValue != 'ACCEPT') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Lastschrift' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        (opp.E2E_payment_status__c == 'ACCEPT' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 3. Direct Debit CANCEL&DECLINE (Germany)
	private static Boolean isDirectDebitCancelDecline(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if ( (ofh.OldValue == 'CANCEL' && ofh.NewValue != 'CANCEL') || (ofh.OldValue == 'DECLINE' && ofh.NewValue != 'DECLINE') ) {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Lastschrift' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        ((opp.E2E_payment_status__c == 'CANCEL' || opp.E2E_payment_status__c == 'DECLINE') || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 4. Direct Debit EXCEPTION (Germany)
	private static Boolean isDirectDebitException(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'EXCEPTION' && ofh.NewValue != 'EXCEPTION') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Lastschrift' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        (opp.E2E_payment_status__c == 'EXCEPTION' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 5. Bank Transfer No Deposit (Germany)
	private static Boolean isBankTransferNoDeposit(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'EXCEPTION' && ofh.NewValue != 'EXCEPTION') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Banküberweisung' && 
	        (opp.Security_Amount_To_Pay__c == null || opp.Security_Amount_To_Pay__c == 0) &&
	        (opp.E2E_payment_status__c == 'NO DEPOSIT' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 6. Bank Transfer ACCEPT (Germany)
	private static Boolean isBankTransferAccept(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'ACCEPT' && ofh.NewValue != 'ACCEPT') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Banküberweisung' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        (opp.E2E_payment_status__c == 'ACCEPT' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 7. Bank Transfer CANCEL&DECLINE (Germany)
	private static Boolean isBankTransferCancelDecline(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if ( (ofh.OldValue == 'CANCEL' && ofh.NewValue != 'CANCEL') || (ofh.OldValue == 'DECLINE' && ofh.NewValue != 'DECLINE') ) {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Banküberweisung' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        ((opp.E2E_payment_status__c == 'CANCEL' || opp.E2E_payment_status__c == 'DECLINE') || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 8. Bank Transfer EXCEPTION
	private static Boolean isBankTransferException(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'ACCEPT' && ofh.NewValue != 'ACCEPT') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Banküberweisung' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        (opp.E2E_payment_status__c == 'EXCEPTION' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// Order Confirmation (Netherlands, Belgium-NL, Belgium-FR, Poland, Hungary, France)
	private static Boolean isOrderConfirmation(Opportunity opp) {
	    if (opp.Zahlungsart__c != null && opp.E2E_payment_status__c != null && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Abandonment Scenarios (Germany, Netherlands, Belgium-NL, Belgium-FR, Poland, Hungary, France)
	private static Boolean isAbandonmentScenarios(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'Marketing automation' && ofh.NewValue == 'Switched to manual') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
        if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost' &&
            (opp.E2E_Switch_To_Manual__c == null || opp.E2E_Switch_To_Manual__c != true) && 
            ((opp.E2E_Status__c == 'Abandoned (hard)' && opp.E2E_Sub_Status__c == 'Marketing automation') || isActOfE2ECampaign == true)) {
            return true;
        }
        return false;
    }

    // E2E Save And Continue (Germany, Netherlands, Belgium-NL, Belgium-FR, Poland, Hungary, France)
    private static Boolean isSaveAndContinueLater(Opportunity opp) {
    	Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'Marketing automation' && ofh.NewValue == 'Switched to manual') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
        if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost' &&
            (opp.E2E_Switch_To_Manual__c == null || opp.E2E_Switch_To_Manual__c != true) && 
            ((opp.E2E_Status__c == 'Abandoned (soft)' && opp.E2E_Sub_Status__c == 'Marketing automation') || isActOfE2ECampaign == true)) {
            return true;
        }
        return false;
    }	
}