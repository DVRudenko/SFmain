public class E2EExceptionUtils {


	/*******************************************************************************
    *  Name            : saveExceptionData(Account account, Opportunity opportunity, String errorName, Exception excpt, String searchParam)
    *  Summary         : update opportuinty and account if we catch a exception    
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : 17/12/2019
    *  Parameters      : Account account, Opportunity opportunity, String errorName, Exception excpt
    *  Returns         : void
    ******************************************************************************/
    public static void saveExceptionData(Account account, Opportunity opportunity, String errorName, Exception excpt, String searchParam) {
    	try {
	        if (opportunity != null && account != null) {
	        	Boolean isVatIdError = false;
				TimeZone tz = UserInfo.getTimeZone();
				DateTime dt = Datetime.now();
				Datetime errorDt = dt.addSeconds((tz.getOffset(dt)/1000));

        		if (! errorsMap.containsKey(errorName)) {
					if (excpt.getTypeName() == 'CreditFactoryException') {
						opportunity.E2E_Errors__c = 'CF System Error';
						opportunity.Last_E2E_Error__c = 'CF System Error';
					} else {
						opportunity.E2E_Errors__c = 'System Error';
						opportunity.Last_E2E_Error__c = 'System Error';
					}
					if (opportunity.E2E_System_Error_Description__c != null && opportunity.E2E_System_Error_Description__c != '') {
						opportunity.E2E_System_Error_Description__c += ';' + '\n' + errorDt + ': ' + excpt.getMessage() + ' (StackTrace: ' + excpt.getStackTraceString() + ')';
					} else {
						opportunity.E2E_System_Error_Description__c = errorDt + ': ' + excpt.getMessage() + ' (StackTrace: ' + excpt.getStackTraceString() + ')';
					}
	        		if (opportunity.E2E_System_Error_Description__c != null && opportunity.E2E_System_Error_Description__c.contains('Vat number is not valid')) {
	        			isVatIdError = true;
					}
	    		} else {
	    			opportunity.E2E_Errors__c = errorToCategoryMap.get(errorName);
                    opportunity.Last_E2E_Error__c = errorToCategoryMap.get(errorName);

					if (opportunity.E2E_System_Error_Description__c != null && opportunity.E2E_System_Error_Description__c != '') {
						opportunity.E2E_System_Error_Description__c += ';' + '\n' + errorDt + ': ' + errorName;
					} else {
						opportunity.E2E_System_Error_Description__c = errorDt + ': ' + errorName;
					}
				}

	            if (errorName == 'Private entity') {
	                opportunity.StageName = 'Closed Lost';
	                opportunity.E2E_Form_of_Business__c = 'Private';
	                opportunity.Gruende_verloren__c = 'Not a legal entity';
					opportunity.Kredit_Entscheidung__c = 'Abgelehnt';
	            } else if (errorName == 'Too high limit' || errorName == 'Risky but manageable' || errorName == 'Negative profit') {
	            	opportunity.E2E_Active_Step__c = 1;
	            	opportunity.E2E_Active_Substep__c = 'Set total consumption';
	            } else if (errorName == 'Additional Credit Scoring Allowance' || errorName == 'Consent not signed by the right person' || errorName == 'Company has overdue debts' || errorName == 'Too high limit. Additional Credit Scoring Allowance') {
	            	opportunity.E2E_Active_Step__c = 1;
	            	opportunity.E2E_Active_Substep__c = 'Additional Credit Scoring Allowance';
	            } else if (errorName == 'Too risky') {
	            	opportunity.E2E_Active_Step__c = 1;
	            	opportunity.E2E_Active_Substep__c = 'Set total consumption';
	            	opportunity.StageName = 'Closed Lost';
					opportunity.Kredit_Entscheidung__c = 'Abgelehnt';
	            } else if (errorName == 'Too many reports' || 
            		errorName == 'Authorization not granted' ||
            		errorName == 'Black list' ||
            		errorName == 'High e-mail risk' ||
            		errorName == 'Report does not exist' ||
            		errorName == 'Company not found' ||
            		errorName == 'Already a customer' ||
            		errorName == 'Already in process' ||
					errorName == 'High risk industry' ||
					errorName == 'Empty Address') {
	            	opportunity.E2E_Active_Step__c = 1;
	            	opportunity.E2E_Active_Substep__c = 'Search company';
	            } else if (errorName == 'Inactive company') {
					opportunity.StageName = 'Closed Lost';
					opportunity.Gruende_verloren__c = 'Refused Credit';
					opportunity.Kredit_Entscheidung__c = 'Abgelehnt';
				}
	            
	        	if (errorName == 'Already in process') {
	        		opportunity.E2E_Status__c = 'Finished';
	        	} else if ( ! isVatIdError ) {
	        		opportunity.E2E_Status__c = 'Rejected';
				}

				// save search params
				if (errorName == 'Company not found') {
					if (opportunity.CF_Search_Parameters__c != null && opportunity.CF_Search_Parameters__c != '') {
						opportunity.CF_Search_Parameters__c += ';' + '\n' + errorDt + '; ' + searchParam;
					} else {
						opportunity.CF_Search_Parameters__c = errorDt + '; ' + searchParam;
					}
				}

	        	if ( ! isVatIdError ) {
		            opportunity.E2E_Sub_Status__c = 'Switched to manual';
		            opportunity.E2E_Sales_Type__c = 'E2E downgraded to manual';

		            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(account.BillingCountry);
                    if (settings != null && settings.Abandonment_User__c != null) {
                    	account.OwnerId = settings.Abandonment_User__c;
                        opportunity.OwnerId = settings.Abandonment_User__c;
                    }			    	
				}

	            update opportunity;
	            update account;
	        }
        } catch (Exception e) {}
    }


    /*******************************************************************************
    *  Name            : sendExceptionEmail(Account account, Opportunity opportunity, Contact contact, String methodName, Exception excpt)
    *  Summary         : send exception email
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Account account, Opportunity opportunity, Contact contact, String deviceView, String methodName, Exception excpt
    *  Returns         : void
    ******************************************************************************/
    public static void sendExceptionEmail(Account account, Opportunity opportunity, Contact contact, String deviceView, String methodName, Exception excpt) {
        try {
            String notificationMessage = '<br/>E2E method ' + 
				methodName + ': ' + 
				String.valueOf(excpt.getMessage());
            notificationMessage += '<br/>Device: ' + deviceView;
            if (account != null) {
                notificationMessage += '<br/>Account Id: ' + account.Id;
            }
            if (contact != null) {
                notificationMessage += '<br/>Contact Id: ' + contact.Id;
            }
            if (opportunity != null) {
                notificationMessage += '<br/>Opportunity Id: ' + opportunity.Id;
            }

            ExceptionLogger.sendException(notificationMessage, String.valueOf(excpt.getStackTraceString()));
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method sendExceptionEmail(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
	*  Name            : errorsMap - static map
	*  Summary         : 'errorsMap' is static map for saving all e2e errors    
	*  CreatedDate     : 24/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/	
	public static Map<String, String> errorsMap = new Map<String, String>{
		'Company not found' => 'Company not found',
		'Report does not exist' => 'Report does not exist',
		'Too high limit' => 'Too high limit',
		'Additional Credit Scoring Allowance' => 'Additional Credit Scoring Allowance',
		'Too high limit. Additional Credit Scoring Allowance' => 'Too high limit. Additional Credit Scoring Allowance',
		'Private entity' => 'Private entity',
		'Risky but manageable' => 'Risky but manageable',
		'Too risky' => 'Too risky',
		'Authorization not granted' => 'Authorization not granted',
        'Black list' => 'Black list',
		'High e-mail risk' => 'High e-mail risk',
		'Already a customer' => 'Already a customer',
		'Already in process' => 'Already in process',
		'More than two paid reports' => 'More than two paid reports',
		'Inactive company' => 'Inactive company',
        'Negative profit' => 'Negative profit',
		'Consent not signed by the right person' => 'Consent not signed by the right person',
		'Company has overdue debts' => 'Company has overdue debts',
		'Company is not in the list' => 'Company is not in the list',
		'High risk industry' => 'High risk industry',
		'Empty Address' => 'Empty Address'
	};

	public static Map<String, String> errorToCategoryMap = new Map<String, String>{
			'Report does not exist' => 'CF System Error',
			'Company not found' => 'CF System Error',
			'Too high limit' => 'Credit Logic',
			'Additional Credit Scoring Allowance' => 'Credit Logic',
			'Too high limit. Additional Credit Scoring Allowance' => 'Credit Logic',
			'Private entity' => 'Credit Logic',
			'Risky but manageable' => 'Credit Logic',
			'Too risky' => 'Credit Logic',
			'Authorization not granted' => 'Credit Logic',
			'Black list' => 'Credit Logic',
			'High e-mail risk' => 'Credit Logic',
			'Already a customer' => 'Process Error',
			'Already in process' => 'Process Error',
			'More than two paid reports' => 'Credit Logic',
			'Inactive company' => 'Credit Logic',
			'Negative profit' => 'Credit Logic',
			'Consent not signed by the right person' => 'Credit Logic',
			'Company has overdue debts' => 'Credit Logic',
			'Company is not in the list' => 'Credit Logic',
			'High risk industry' => 'Credit Logic',
			'Empty Address' => 'Credit Logic'
	};
}