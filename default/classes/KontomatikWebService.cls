public class KontomatikWebService {
	public static final String CREDIT_SYSTEM_NAME = 'Kontomatik';
    

    /*******************************************************************************
    *  Name            : generateDefaultImportRequest()
    *  Summary         : Generate Default Import HTTP request
    *  CreatedDate     : 10/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String apiKey - api key from Credit System Custom Setting,
    					 String sessionId - session id based on client credentials,
    					 String sessionIdSignature - sesion id signature based on client credentials,
    					 String endpoint - endpoint from Credit System Custom Setting
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateDefaultImportRequest(String apiKey, String sessionId, String sessionIdSignature, 
    													   String endpoint) {
    	String body = 'apiKey=' + apiKey + '&sessionId=' + sessionId + '&sessionIdSignature=' + sessionIdSignature + 
    		'&since=' + String.valueOf(Datetime.now().addDays(-90)).substringBefore(' ');
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');
		request.setEndpoint(endpoint + 'v1/command/default-import.xml');
		request.setHeader('Content-Type','application/x-www-form-urlencoded');
		request.setBody(body);
		return request;
    }


    /*******************************************************************************
    *  Name            : returnDefaultImportCommandId()
    *  Summary         : Return response id to send the next requests
    *  CreatedDate     : 10/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - xml node from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnDefaultImportCommandId(Dom.XMLNode node) {
    	for (Dom.XMLNode replyField : node.getChildElements()) {
            if (replyField.getName() == 'command') {
            	return replyField.getAttribute('id', null);
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : generateCommandStatusRequest(String apiKey, String sessionId, String sessionIdSignature, 
    												  String endpoint, String defaultImportCommandId)
    *  Summary         : Generate Command Status HTTP request    
    *  CreatedDate     : 11/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String apiKey - api key from Credit System Custom Setting,
    					 String sessionId - session id based on client credentials,
    					 String sessionIdSignature - sesion id signature based on client credentials,
    					 String endpoint - endpoint from Credit System Custom Setting,
    					 String defaultImportCommandId - id from previos request
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateCommandStatusRequest(String apiKey, String sessionId, String sessionIdSignature, 
    													   String endpoint, String defaultImportCommandId) {
    	endpoint = endpoint + 'v1/command/' + defaultImportCommandId + '.xml?' + 'apiKey=' + apiKey + '&sessionId=' + 
    		sessionId + '&sessionIdSignature=' + sessionIdSignature;
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		request.setEndpoint(endpoint);
		request.setHeader('Content-Type','application/x-www-form-urlencoded');
		return request;
    }


    /*******************************************************************************
    *  Name            : returnDefaultImportCommandStatus()
    *  Summary         : Return response id to send the next requests.
    *  CreatedDate     : 12/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - xml node from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnDefaultImportCommandStatus(Dom.XMLNode node) {
    	for (Dom.XMLNode replyField : node.getChildElements()) {
            if (replyField.getName() == 'command') {
            	return replyField.getAttribute('state', null);
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnBankAccounts()
    *  Summary         : Return Bank Accounts data.    
    *  CreatedDate     : 13/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - xml node from response
    *  Returns         : List<BankAccount>
    ******************************************************************************/
    public static List<BankAccount> returnBankAccounts(Dom.XMLNode node) {
    	List<BankAccount> bankAccountsList = new List<BankAccount>();
    	Integer internalNumber = 0;
    	for (Dom.XMLNode replyField : node.getChildElements()) {
    		if (replyField.getName() == 'command') {
    			for (Dom.XMLNode commandField : replyField.getChildElements()) {
    				if (commandField.getName() == 'result') {
    					for (Dom.XMLNode resultField : commandField.getChildElements()) {
    						if (resultField.getName() == 'accounts') {
    							for (Dom.XMLNode accountsField : resultField.getChildElements()) {
    								if (accountsField.getName() == 'account') {
    									internalNumber ++;
    									bankAccountsList.add(returnBankAccount(accountsField, internalNumber));
    								}
    							}
    						}
    					}
    				}
    			}
    		}
    	}

    	return bankAccountsList;
    }


    /*******************************************************************************
    *  Name            : returnBankAccount()
    *  Summary         : Return Bank Account data.
    *  CreatedDate     : 13/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - xml node from response, Integer internalNumber - 
    					 number to connect child objects
    *  Returns         : BankAccount
    ******************************************************************************/
    public static BankAccount returnBankAccount(Dom.XMLNode node, Integer internalNumber) {
    	BankAccount bankAccount = new BankAccount();
    	for (Dom.XMLNode accountField : node.getChildElements()) {
    		if (accountField.getName() == 'name') {
    			bankAccount.name = accountField.getText();
    		} else if (accountField.getName() == 'friendlyName') {
    			bankAccount.friendlyName = accountField.getText();
    		} else if (accountField.getName() == 'iban') {
    			bankAccount.iban = accountField.getText();
    		} else if (accountField.getName() == 'currencyBalance') {
    			bankAccount.currencyBalance = accountField.getText();
    		} else if (accountField.getName() == 'currencyFundsAvailable') {
    			bankAccount.currencyBalance = accountField.getText();
    		} else if (accountField.getName() == 'currencyName') {
    			bankAccount.currencyName = accountField.getText();
    		} else if (accountField.getName() == 'owner') {
    			bankAccount.owner = accountField.getText();
    		} else if (accountField.getName() == 'activeSinceAtLeast') {
    			bankAccount.activeSinceAtLeast = accountField.getText();
    		} else if (accountField.getName() == 'directDebit') {
    			bankAccount.directDebitAvailable = accountField.getAttribute('available', null);
    		}
    	}

    	bankAccount.internalNumber = String.valueOf(internalNumber);
    	return bankAccount;
    }


    /*******************************************************************************
    *  Name            : returnBankAccountTransactions()
    *  Summary         : Return Bank Account Transactions data.    
    *  CreatedDate     : 13/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - xml node from response
    *  Returns         : List<BankAccountTransaction>
    ******************************************************************************/
    public static List<BankAccountTransaction> returnBankAccountTransactions(Dom.XMLNode node) {
    	List<BankAccountTransaction> bankAccountTransactionsList = new List<BankAccountTransaction>();
    	Integer bankAccountInternalNumber = 0;
    	for (Dom.XMLNode replyField : node.getChildElements()) {
    		if (replyField.getName() == 'command') {
    			for (Dom.XMLNode commandField : replyField.getChildElements()) {
    				if (commandField.getName() == 'result') {
    					for (Dom.XMLNode resultField : commandField.getChildElements()) {
    						if (resultField.getName() == 'accounts') {
    							for (Dom.XMLNode accountsField : resultField.getChildElements()) {
    								if (accountsField.getName() == 'account') {
    									bankAccountInternalNumber ++;
    									for (Dom.XMLNode accountField : accountsField.getChildElements()) {
    										if (accountField.getName() == 'moneyTransactions') {
    											for (Dom.XMLNode moneyTransactionsField : accountField.getChildElements()) {
    												if (moneyTransactionsField.getName() == 'moneyTransaction') {
    													bankAccountTransactionsList.add(returnBankAccountTransaction(moneyTransactionsField, bankAccountInternalNumber));
    												}
    											}	
    										}
    									}
    								}
    							}
    						}
    					}
    				}
    			}
    		}
    	}

    	return bankAccountTransactionsList;
    }


    /*******************************************************************************
    *  Name            : returnBankAccountTransaction()
    *  Summary         : Return Bank Account Transaction data. 
    *  CreatedDate     : 13/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - xml node from response, Integer bankAccountInternalNumber - 
    					 number to connect parent object
    *  Returns         : BankAccountTransaction
    ******************************************************************************/
    public static BankAccountTransaction returnBankAccountTransaction(Dom.XMLNode node, Integer bankAccountInternalNumber) {
    	BankAccountTransaction bankAccountTransaction = new BankAccountTransaction();
    	for (Dom.XMLNode moneyTransactionField : node.getChildElements()) {
    		if (moneyTransactionField.getName() == 'transactionOn') {
    			bankAccountTransaction.transactionOn = moneyTransactionField.getText();
    		} else if (moneyTransactionField.getName() == 'bookedOn') {
    			bankAccountTransaction.bookedOn = moneyTransactionField.getText(); 
    		} else if (moneyTransactionField.getName() == 'currencyAmount') {
    			bankAccountTransaction.currencyAmount = moneyTransactionField.getText();
    		} else if (moneyTransactionField.getName() == 'currencyBalance') {
    			bankAccountTransaction.currencyBalance = moneyTransactionField.getText();
    		} else if (moneyTransactionField.getName() == 'partyIban') {
    			bankAccountTransaction.partyIban = moneyTransactionField.getText();
    		} else if (moneyTransactionField.getName() == 'party') {
    			bankAccountTransaction.party = moneyTransactionField.getText();
    		} else if (moneyTransactionField.getName() == 'title') {
    			bankAccountTransaction.title = moneyTransactionField.getText();
    		} else if (moneyTransactionField.getName() == 'kind') {
    			bankAccountTransaction.kind = moneyTransactionField.getText();
    		} else if (moneyTransactionField.getName() == 'variableSymbol') {
    			bankAccountTransaction.variableSymbol = moneyTransactionField.getText();
    		} else if (moneyTransactionField.getName() == 'labels') {
    			String labels = '';
    			for (Dom.XMLNode labelsField : moneyTransactionField.getChildElements()) {
    				if (labelsField.getName() == 'label') {
    					labels += labelsField.getText() + ', ';
    				}
    			}

                labels = labels.removeEnd(', ');
    			bankAccountTransaction.labels = labels;
    		}
    	}

    	bankAccountTransaction.bankAccountInternalNumber = String.valueOf(bankAccountInternalNumber);
    	return bankAccountTransaction;
    }


    /*******************************************************************************
    *  Name            : returnBankAccountOwners()
    *  Summary         : Return Bank Account Owners data.    
    *  CreatedDate     : 13/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - xml node from response
    *  Returns         : void
    ******************************************************************************/
    public static List<BankAccountOwner> returnBankAccountOwners(Dom.XMLNode node) {
    	List<BankAccountOwner> bankAccountOwnersList = new List<BankAccountOwner>();
    	for (Dom.XMLNode replyField : node.getChildElements()) {
    		if (replyField.getName() == 'command') {
    			for (Dom.XMLNode commandField : replyField.getChildElements()) {
    				if (commandField.getName() == 'result') {
    					for (Dom.XMLNode resultField : commandField.getChildElements()) {
    						if (resultField.getName() == 'owners') {
    							for (Dom.XMLNode ownersField : resultField.getChildElements()) {
    								if (ownersField.getName() == 'owner') {
    									bankAccountOwnersList.add(returnBankAccountOwner(ownersField));
    								}
    							}
    						}
    					}
    				}
    			}
    		}
    	}

    	return bankAccountOwnersList;
    }


    /*******************************************************************************
    *  Name            : returnBankAccountOwner()
    *  Summary         : Return Bank Account Owner data.    
    *  CreatedDate     : 13/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - xml node from response
    *  Returns         : BankAccountOwner
    ******************************************************************************/
    public static BankAccountOwner returnBankAccountOwner(Dom.XMLNode node) {
    	BankAccountOwner bankAccountOwner = new BankAccountOwner();
    	for (Dom.XMLNode ownerField : node.getChildElements()) {
    		if (ownerField.getName() == 'kind') {
    			bankAccountOwner.kind = ownerField.getText();
    		} else if (ownerField.getName() == 'name') {
    			bankAccountOwner.name = ownerField.getText();
    		} else if (ownerField.getName() == 'address') {
    			bankAccountOwner.address = ownerField.getText();
    		} else if (ownerField.getName() == 'polishPesel') {
    			bankAccountOwner.polishPesel = ownerField.getText();
    		} else if (ownerField.getName() == 'polishNip') {
    			bankAccountOwner.polishNip = ownerField.getText();
    		} else if (ownerField.getName() == 'phone') {
    			bankAccountOwner.phone = ownerField.getText();
    		} else if (ownerField.getName() == 'email') {
    			bankAccountOwner.email = ownerField.getText();
    		} else if (ownerField.getName() == 'citizenship') {
    			bankAccountOwner.citizenship = ownerField.getText();
    		} else if (ownerField.getName() == 'nationality') {
    			bankAccountOwner.nationality = ownerField.getText();
    		} else if (ownerField.getName() == 'personalDocumentType') {
    			bankAccountOwner.personalDocumentType = ownerField.getText();
    		} else if (ownerField.getName() == 'personalDocumentNumber') {
    			bankAccountOwner.personalDocumentNumber = ownerField.getText();
    		} else if (ownerField.getName() == 'birthDate') {
    			bankAccountOwner.birthDate = ownerField.getText();
    		} else if (ownerField.getName() == 'birthDate') {
    			bankAccountOwner.birthDate = ownerField.getText();
    		} else if (ownerField.getName() == 'polishRegon') {
    			bankAccountOwner.polishRegon = ownerField.getText();
    		} else if (ownerField.getName() == 'birthPlace') {
    			bankAccountOwner.birthPlace = ownerField.getText();
    		}
    	}

    	return bankAccountOwner;
    }


    /*******************************************************************************
    *  Name            : generateFinancialHealthIndicatorRequest(String apiKey, String endpoint, String ownerExternalId)
    *  Summary         : Generate Financial Health Indicator HTTP request.   
    *  CreatedDate     : 13/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String apiKey - api key from Credit System Custom Setting,
                         String endpoint - endpoint from Credit System Custom Setting,
                         String ownerExternalId - opportunity Id
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateFinancialHealthIndicatorRequest(String apiKey, String endpoint, String ownerExternalId) {
        endpoint = endpoint + 'v1/indicator.xml?' + 'apiKey=' + apiKey + '&ownerExternalId=' + 
            ownerExternalId;
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        return request;
    }  

    
    /*******************************************************************************
    *  Name            : returnTransactionsCompany()
    *  Summary         : Retrun Transactions Company data.    
    *  CreatedDate     : 13/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - xml node from response
    *  Returns         : TransactionsCompany
    ******************************************************************************/       
    public static TransactionsCompany returnTransactionsCompany(Dom.XMLNode node) {
        TransactionsCompany transactionsCompany = new TransactionsCompany();
        for (Dom.XMLNode replyField : node.getChildElements()) {
            transactionsCompany.value = replyField.getName();
            if (replyField.getName() == 'indicator') {
                transactionsCompany.value = 'test';
                for (Dom.XMLNode indicatorField : replyField.getChildElements()) {
                    if (indicatorField.getName() == 'value') {
                        transactionsCompany.value = indicatorField.getText();
                    } else if (indicatorField.getName() == 'distribution') {
                        for (Dom.XMLNode distributionField : indicatorfield.getChildElements()) {
                            if (distributionField.getName() == 'period') {
                                for (Dom.XMLNode periodField : distributionField.getChildElements()) {
                                    if (periodField.getName() == 'days') {
                                        transactionsCompany.periodDays = periodField.getText();
                                    } else if (periodField.getName() == 'startAt') {
                                        transactionsCompany.periodStartAt = periodField.getText();
                                    } else if (periodField.getName() == 'endAt') {
                                        transactionsCompany.periodEndAt = periodField.getText();
                                    }
                                }
                            } else if (distributionField.getName() == 'average') {
                                transactionsCompany.average = distributionField.getText();
                            } else if (distributionField.getName() == 'median') {
                                transactionsCompany.median = distributionField.getText();
                            }
                        }
                    }
                }
            }
        }

        return transactionsCompany;
    }      
}