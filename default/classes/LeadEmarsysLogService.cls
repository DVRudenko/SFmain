public class LeadEmarsysLogService {
	public Map<Id, List<String>> leadIdToCampaignMap;
	public Map<Id, List<String>> leadIdToCampaignDetailsMap;
	public List<Lead> leadsWithoutEmarsysLog;

    /*******************************************************************************
	*  Name            : checkLeads(List<Lead> leadsList)
	*  Summary         : Check emarsys logs in leads    
	*  CreatedDate     : 08/04/2019
	*  ModifiedDate    : -
	*  Parameters      : List<Lead> leadsList
	*  Returns         : List<Lead>
	******************************************************************************/
    public List<Lead> checkLeads(List<Lead> leadList) {
    	this.leadsWithoutEmarsysLog = new List<Lead>();
    	this.leadIdToCampaignMap = new Map<Id, List<String>>();
		this.leadIdToCampaignDetailsMap = new Map<Id, List<String>>();

    	for (Lead lead : leadList) {
    		if ( ! this.leadIdToCampaignMap.containsKey(lead.Id) && ! this.leadIdToCampaignDetailsMap.containsKey(lead.Id)) {
				this.leadIdToCampaignMap.put(lead.Id, new List<String>());
				this.leadIdToCampaignDetailsMap.put(lead.Id, new List<String>());
			}

    		// cases when emarsys log is empty
    		if (lead.Country == 'Germany' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Short Lead Form - DE')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Short Lead Form - DE');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Short Lead Form - DE 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Short Lead Form - DE 1');
    				}
    			} else if (isInboundCall(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - DE')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - DE');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - DE 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - DE 1');
    				}
    			} else if (isInboundEmail(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Non-Shell - DE')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Non-Shell - DE');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Non-Shell - DE 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Non-Shell - DE 1');
    				}
    			} else if (isOtherChannelJITB(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario Other Channel DE - JITB')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario Other Channel DE - JITB');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario Other Channel DE - JITB 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario Other Channel DE - JITB 1');
    				}
    			}
    		} else if (lead.Country == 'Netherlands' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Short Lead Form - NL')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Short Lead Form - NL');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Short Lead Form - NL 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Short Lead Form - NL 1');
    				}
    			} else if (isInboundCall(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - NL')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - NL');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - NL 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - NL 1');
    				}
    			} else if (isInboundEmail(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Non-Shell - NL')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Non-Shell - NL');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Non-Shell - NL 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Non-Shell - NL 1');
    				}
    			} else if (isShellEmail(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Shell - NL')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Shell - NL');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Shell - NL 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Shell - NL 1');
    				}
    			}
    		} else if (lead.Country == 'Belgium-NL' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Short Lead Form - BENL')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Short Lead Form - BENL');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Short Lead Form - BENL 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Short Lead Form - BENL 1');
    				}
    			} else if (isInboundCall(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BENL')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BENL');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BENL 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BENL 1');
    				}
    			} else if (isInboundEmail(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Non-Shell - BENL')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Non-Shell - BENL');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Non-Shell - BENL 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Non-Shell - BENL 1');
    				}
    			} else if (isShellEmail(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Shell - BENL')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Shell - BENL');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Shell - BENL 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Shell - BENL 1');
    				}
    			}
    		} else if (lead.Country == 'Belgium-FR' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty() && 
    				  (isFacebook(lead) || isInboundCall(lead) || isInboundEmail(lead) || isShellEmail(lead)) ) {
    			if (isFacebook(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Short Lead Form - BEFR')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Short Lead Form - BEFR');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Short Lead Form - BEFR 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Short Lead Form - BEFR 1');
    				}
    			} else if (isInboundCall(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BEFR')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BEFR');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BEFR 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BEFR 1');
    				}
    			} else if (isInboundEmail(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Non-Shell - BEFR')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Non-Shell - BEFR');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Non-Shell - BEFR 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Non-Shell - BEFR 1');
    				}
    			} else if (isShellEmail(lead)) {
    				this.leadsWithoutEmarsysLog.add(lead);
    				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Shell - BEFR')) {
    					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Shell - BEFR');
    				}
    				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario: Email Leads: Shell - BEFR 1')) {
    					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario: Email Leads: Shell - BEFR 1');
    				}
    			}
    		} else if (lead.Country == 'Poland' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty() && isOtherChannelJITB(lead)) {
    			this.leadsWithoutEmarsysLog.add(lead);
    			if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario Other Channel PL - JITB')) {
					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario Other Channel PL - JITB');
				}
				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario Other Channel PL - JITB 1')) {
					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario Other Channel PL - JITB 1');
				}
    		} else if (lead.Country == 'Hungary' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty() && isOtherChannelJITB(lead)) {
    			this.leadsWithoutEmarsysLog.add(lead);
    			if ( ! this.leadIdToCampaignMap.get(lead.Id).contains('E2E Sales Scenario Other Channel HU - JITB')) {
					this.leadIdToCampaignMap.get(lead.Id).add('E2E Sales Scenario Other Channel HU - JITB');
				}
				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains('E2E Sales Scenario Other Channel HU - JITB 1')) {
					this.leadIdToCampaignDetailsMap.get(lead.Id).add('E2E Sales Scenario Other Channel HU - JITB 1');
				}
    		}
    		// cases when emarsys log does not empty but email name is wrong
    		if (lead.Country == 'Germany' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Short Lead Form - DE');
    			} else if (isInboundCall(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - DE');
    			} else if (isInboundEmail(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Email Leads: Non-Shell - DE');
    			} else if (isOtherChannelJITB(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario Other Channel DE - JITB');
    			}
    		} else if (lead.Country == 'Netherlands' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Short Lead Form - NL');
    			} else if (isInboundCall(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - NL');
    			} else if (isInboundEmail(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Email Leads: Non-Shell - NL');
    			} else if (isShellEmail(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Email Leads: Shell - NL');
    			}
    		} else if (lead.Country == 'Belgium-NL' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Short Lead Form - BENL');
    			} else if (isInboundCall(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BENL');
    			} else if (isInboundEmail(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Email Leads: Non-Shell - BENL');
    			} else if (isShellEmail(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Email Leads: Shell - BENL');
    			}
    		} else if (lead.Country == 'Belgium-FR' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Short Lead Form - BEFR');
    			} else if (isInboundCall(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BEFR');
    			} else if (isInboundEmail(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Email Leads: Non-Shell - BEFR');
    			} else if (isShellEmail(lead)) {
	    			checkEmarsysCampaign(lead, 'E2E Sales Scenario: Email Leads: Shell - BEFR');
    			}
    		} else if (lead.Country == 'Poland' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty() && isOtherChannelJITB(lead)) {
    			checkEmarsysCampaign(lead, 'E2E Sales Scenario Other Channel PL - JITB');
    		} else if (lead.Country == 'Hungary' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty() && isOtherChannelJITB(lead)) {
    			checkEmarsysCampaign(lead, 'E2E Sales Scenario Other Channel HU - JITB');
    		}
    	}

		return this.leadsWithoutEmarsysLog;
    }


    /*******************************************************************************
    *  Name            : checkEmarsysCampaign(Lead lead, String campaign)
    *  Summary         : Check emarsys campaign, add email name to Map    
    *  CreatedDate     : 02/05/2019
    *  ModifiedDate    : -
    *  Parameters      : Lead lead, String campaign
    *  Returns         : void
    ******************************************************************************/
    private void checkEmarsysCampaign(Lead lead, String campaign) {
    	Datetime campaignEndDate = calculateCampaignEndDate(lead);
		Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
		for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
			if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != (campaign + ' 1')) || 
				(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != (campaign + ' 2')) || 
				(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != (campaign + ' 3')) ) {
				this.leadsWithoutEmarsysLog.add(lead);
				if ( ! this.leadIdToCampaignMap.get(lead.Id).contains(campaign)) {
					this.leadIdToCampaignMap.get(lead.Id).add(campaign);
				}
			}

			if ( daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != (campaign + ' 1') ) {
				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains((campaign + ' 1'))) {
					this.leadIdToCampaignDetailsMap.get(lead.Id).add((campaign + ' 1'));
				}
			} else if ( daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != (campaign + ' 2') ) {
				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains((campaign + ' 2'))) {
					this.leadIdToCampaignDetailsMap.get(lead.Id).add((campaign + ' 2'));
				}
			} else if ( daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != (campaign + ' 3') ) {
				if ( ! this.leadIdToCampaignDetailsMap.get(lead.Id).contains((campaign + ' 3'))) {
					this.leadIdToCampaignDetailsMap.get(lead.Id).add((campaign + ' 3'));
				}
			}
		}
    }


    /*******************************************************************************
	*  Name            : calculateCampaignEndDate(Lead lead)
	*  Summary         : Calculate campaign end date    
	*  CreatedDate     : 12/04/2019
	*  ModifiedDate    : -
	*  Parameters      : Lead lead
	*  Returns         : Datetime
	******************************************************************************/
	private Datetime calculateCampaignEndDate(Lead lead) {
		Datetime endDate = Datetime.now();
		if ( ! lead.Histories.isEmpty()) {
			for (LeadHistory lh : lead.Histories) {
	            if (lh.OldValue == 'Switched to E2E' && lh.NewValue == null) {
	                endDate = lh.CreatedDate;
	                break;
	            }
	        }
    	}
        return endDate;
	}


    /*******************************************************************************
    *  Name            : createExcelDocument(List<Lead> leadsWithoutEmarsysLog)
    *  Summary         : Generate excel document and insert in the Emarsys Logs folder    
    *  CreatedDate     : 10/04/2019
    *  ModifiedDate    : -
    *  Parameters      : List<Lead> leadsWithoutEmarsysLog - List of leads without emarsys logs
    *  Returns         : void
    ******************************************************************************/
    public void createExcelDocument(List<Lead> leadsWithoutEmarsysLog) {
    	List<Lead> leadsForReport = new List<Lead>();
    	leadsForReport = checkLeads(leadsWithoutEmarsysLog);
    	List<Folder> folderList = [SELECT Id, Name FROM Folder WHERE Name = 'Emarsys Logs'];
        Document document = new Document();
        document.FolderId = folderList.get(0).Id;
    	String body = '';
        for (Lead lead : leadsForReport) {
        	if ( ! body.contains(lead.Id) ) {
            	body += 'Lead ID = ' + lead.Id + ', Name = ' + lead.Name + ', Country = ' + lead.Country + ', campaign = ' + this.leadIdToCampaignMap.get(lead.Id) + ', details: no ' + this.leadIdToCampaignDetailsMap.get(lead.Id) + '\r';
            }
        }
        document.Body = Blob.valueOf(body);
        document.Name = 'Leads' + Datetime.now() + '.xls';
        Database.insert(document);
    }


    /*******************************************************************************
    *  Name            : checkLeadActOfCampaign(lead)
    *  Summary         : Check if lead is act of campaign    
    *  CreatedDate     : 12/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Lead lead
    *  Returns         : Boolean
    ******************************************************************************/
    private static Boolean checkLeadActOfCampaign(Lead lead) {
    	Boolean isActOfCampaign;
    	if (! lead.Histories.isEmpty()) {
			for (LeadHistory oh : lead.Histories) {
	            if (oh.OldValue == 'Switched to E2E' && oh.NewValue == null) {
	                isActOfCampaign = true;
	                break;
	            }
	        }
		}
		return isActOfCampaign;
    }

    // Short Lead Forms DE, NL, BENL, BEFR (Germany, Netherlands, Belgium-NL, Belgium-FR)
	private static Boolean isFacebook(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        (lead.LeadSource == 'Facebook' || lead.LeadSource == 'popup_window' || lead.LeadSource == 'Web_LP') && 
	        (lead.Sec_Channel__c != 'JITB' || lead.Sec_Channel__c == null)) {
	        return true;
	    }
	    return false;
	}

	// Manual Upgrade to e2e DE, NL, BENL, BEFR
	private static Boolean isInboundCall(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        lead.LeadSource == 'Inbound Call' && 
	        (lead.Sec_Channel__c != 'JITB' || lead.Sec_Channel__c == null)) {
	        return true;
	    }
	    return false;
	}

	// Email Leads: Non-Shell DE, NL, BENL, BEFR
	private static Boolean isInboundEmail(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        lead.LeadSource == 'Inbound Email' && 
	        (lead.Sec_Channel__c != 'JITB' || lead.Sec_Channel__c == null)) {
	        return true;
	    }
	    return false;
	}

	// Email Leads: Shell NL, BENL, BEFR
	private static Boolean isShellEmail(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        lead.LeadSource == 'Shell Email' && 
	        (lead.Sec_Channel__c != 'JITB' || lead.Sec_Channel__c == null)) {
	        return true;
	    }
	    return false;
	}

	// Other Channel JITB DE, HU, PL
	private static Boolean isOtherChannelJITB(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        lead.Sec_Channel__c == 'JITB' && 
	        lead.Email != null) {
	        return true;
	    }
	    return false;
	}
}