public class CreditFactoryImplDE extends CreditFactoryImpl {


    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 10/08/2020 by Anton Buzak
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : list of searched companies
    ******************************************************************************/
    public override List<CreditFactoryCompany> requestSearchCompanies(Set<String> searchParametersSet) {
    	try {
            Http http = new Http();
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('Schufa');
			HttpRequest authRequest = CreditFactoryWebSchufa2.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
			HttpResponse authResponse = http.send(authRequest);
			this.apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(authResponse, 'auth');
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}

			SchufaEntity authEntity = SchufaEntity.parse(authResponse.getBody());
            Map<String, String> searchParametersMap = CreditFactoryGlobalUtils.generateSearchParametersMap(searchParametersSet, this.internalCFCompany);
            List<CreditFactoryCompany> externalCompaniesList = searchByAllParameters(authEntity, creditSystem, searchParametersMap);

			if (externalCompaniesList.isEmpty()) {
				externalCompaniesList = searchByName(authEntity, creditSystem);
			}

			return externalCompaniesList;
    	} catch (Exception e) {
			ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				throw new CreditFactoryException(CreditFactoryGlobalUtils.SCHUFA_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
			}
    	}
    }


    /*******************************************************************************
	*  Summary         : Search by all parameters that we have
	*  CreatedDate     : 09/06/2020 by Anton Buzak
	*  Parameters      : authEntity - auth data, creditSystem - credit system credentials,
                         searchParametersMap - parameters for search
	*  Returns         : list of companies
	******************************************************************************/
	private List<CreditFactoryCompany> searchByAllParameters(SchufaEntity authEntity, CreditSystem__c creditSystem, Map<String, String> searchParametersMap) {
		HttpRequest searchRequest = CreditFactoryWebSchufa2.generateSearchRequest(authEntity.accessToken, creditSystem.Endpoint__c, searchParametersMap);
		Http http = new Http();
		HttpResponse searchResponse = http.send(searchRequest);
		this.apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(searchResponse, 'search');
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}

		SchufaEntity searchEntity = SchufaEntity.parse(searchResponse.getBody());
		List<CreditFactoryCompany> creditCompaniesList = CreditFactoryWebSchufa2.returnSearchCompany(searchEntity);
		return creditCompaniesList;
	}


	/*******************************************************************************
	*  Summary         : Search by name
	*  CreatedDate     : 09/06/2020 by Anton Buzak
	*  Parameters      : authEntity - auth data, creditSystem - credit system credentials
	*  Returns         : list of companies
	******************************************************************************/
	private List<CreditFactoryCompany> searchByName(SchufaEntity authEntity, CreditSystem__c creditSystem) {
		Map<String, String> searchParametersMap = new Map<String, String>();
		searchParametersMap.put('name', this.internalCFCompany.name);
		HttpRequest searchRequest = CreditFactoryWebSchufa2.generateSearchRequest(authEntity.accessToken, creditSystem.Endpoint__c, searchParametersMap);
		Http http = new Http();
		HttpResponse searchResponse = http.send(searchRequest);
		this.apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(searchResponse, 'search');
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}

		SchufaEntity searchEntity = SchufaEntity.parse(searchResponse.getBody());
		List<CreditFactoryCompany> creditCompaniesList = CreditFactoryWebSchufa2.returnSearchCompany(searchEntity);
		return creditCompaniesList;
	}


	/*******************************************************************************
	*  Summary         : Do order request for report.
	*  CreatedDate     : 15/01/2020
	*  Parameters      : internalId - credit company id
	*  Returns         : -
	******************************************************************************/
    public override CreditFactoryOrderItem requestOrder(String internalId) {
		try {
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			CF_Order_Notifications__c notification = CF_Order_Notifications__c.getInstance('Germany');
			if (notification.Active__c) {
				message.setToAddresses(new List<String>{
						notification.Email__c
				});
				List<OrgWideEmailAddress> addressesList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Fleetcor Deutschland GmbH' LIMIT 1];
				if (!addressesList.isEmpty()) {
					message.setOrgWideEmailAddressId(addressesList.get(0).Id);
					String contactName;
					String contactPhone;
					String contactEmail;
					String contactDateOfBirth;
					for (CreditFactoryCompany.CreditFactoryContact contact : internalCFCompany.creditFactoryContacts) {
						if (contact.relation == 'OpportunityContactRole' && contact.isPrimary == true) {
							contactName = contact.lastName + ' ' + contact.firstName;
							contactPhone = contact.phone;
							contactEmail = contact.email;
							contactDateOfBirth = contact.dateOfBirth;
							break;
						}
					}
					
					String body = 'Sehr geehrte Damen und Herren,</br></br>' +
						'können Sie für uns bitte so schnell wie möglich eine Auskunft für folgenden Kunden erstellen?</br></br>' +
						'Firmenname: ' + this.internalCFCompany.name + '</br>' +
						(! String.isEmpty(this.internalCFCompany.taxId) ? 'Steuernummer: ' + this.internalCFCompany.taxId + '</br>' : '') +
						(! String.isEmpty(this.internalCFCompany.tradeRegisterNumber) ? 'Handelsregisternummer: ' + this.internalCFCompany.tradeRegisterNumber + '</br>' : '') +
						(! String.isEmpty(this.internalCFCompany.vatId) ? 'Umsatzsteuer ID: ' + this.internalCFCompany.vatId + '</br>' : '') +
						'Ort: ' + this.internalCFCompany.registeredCity + '</br>' +
						(! String.isEmpty(this.internalCFCompany.registeredStreet) ? 'Straße und Hausnummer: ' + this.internalCFCompany.registeredStreet + '</br>' : '') +
						(! String.isEmpty(this.internalCFCompany.registeredPostCode) ? 'PLZ: ' + this.internalCFCompany.registeredPostCode + '</br>' : '') +
						'Kontaktperson: ' + contactName + '</br>' +
						(! String.isEmpty(contactDateOfBirth) ? 'Geburtsdatum: ' + contactDateOfBirth + '</br>' : '') +
						(! String.isEmpty(contactPhone) ? 'Telefonnummer: ' + contactPhone + '</br>' : '') +
						(! String.isEmpty(contactEmail) ? 'E-Mail: ' + contactEmail + '</br></br>' : '') +
						'Bitte verwenden Sie den folgenden Link, um die Schufa ID des Unternehmens einzugeben, sobald die Auskunft fertig ist: </br>' +
						'<a href="https://fleetcoremea.secure.force.com/SubmitSchufaId?id=' + this.internalCFCompany.opportunityId + '">Schufa ID eingeben</a></br></br>' +
						'Vielen Dank für Ihre Bemühung.</br>' +
						'Mit freundlichen grüßen</br>' +
						'FLEETCOR Team</br></br>';
					
					message.setHtmlBody(body);
					message.setSubject('"' + this.internalCFCompany.name + '". Bitte diese Firma recherchieren. ' + this.internalCFCompany.ownerName);
					message.setSaveAsActivity(false);

					Messaging.EmailFileAttachment fileAttachment = setEmailAttachment();
					if (fileAttachment.getBody() != null) {
						message.setFileAttachments(new Messaging.EmailFileAttachment[] {fileAttachment});
					}

					List<Messaging.SingleEmailMessage> messagesList = new List<Messaging.SingleEmailMessage>();
					messagesList.add(message);
					Messaging.sendEmail(messagesList);
				}
			}

			CreditFactoryOrderItem orderItem = new CreditFactoryOrderItem();
			orderItem.message = 'Order request was sent.';

			return orderItem;
		} catch (Exception e) {
			ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
			throw new CreditFactoryException('Order request failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Summary         : return file to attach to the email
	*  Created         : 08/04/2021 by Ivan Kulinkovich
	*  Parameters      : -
	*  Returns         : Messaging.EmailFileAttachment fileAttachment
	******************************************************************************/
	private Messaging.EmailFileAttachment setEmailAttachment() {
		CreditFactoryCompany.CreditFactoryAttachment attachmentToSend;
		CreditFactoryCompany.CreditFactoryFile fileToSend;
		if (this.internalCFCompany.attachments != null) {
			for (CreditFactoryCompany.CreditFactoryAttachment attachment : this.internalCFCompany.attachments) {
				if (attachment.name.containsIgnoreCase('GWA') || attachment.description == 'Company registration form') {
					attachmentToSend = attachment;
					break;
				}
			}
		}

		if (attachmentToSend == null && this.internalCFCompany.files != null) {
			for (CreditFactoryCompany.CreditFactoryFile file : this.internalCFCompany.files) {
				if (file.title.containsIgnoreCase('GWA')) {
					fileToSend = file;
					break;
				}
			}
		}

		Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
		if (attachmentToSend != null) {
			fileAttachment.setFileName(attachmentToSend.name);
			fileAttachment.setBody(EncodingUtil.base64Decode(attachmentToSend.body));
		}
		else if (fileToSend != null) {
			fileAttachment.setFileName(fileToSend.title);
			fileAttachment.setBody(EncodingUtil.base64Decode(fileToSend.versionData));
		}

		return fileAttachment;
	}


	/*******************************************************************************
	*  Summary         : return set of fields to update after order request
	*  Created         : 10/08/2020 by Anton Buzak
	*  Parameters      : orderId - id of order
	*  Returns         : -
	******************************************************************************/
	public override Map<String, Object> returnOrderFieldsToUpdate(String orderId) {
		Map<String, Object> fieldsMap = new Map<String, Object>();
		Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
		opportunityFieldsMap.put('CF_Orders__c', String.valueOf(Datetime.now()));
		opportunityFieldsMap.put('CF_Order_Date__c', Datetime.now());
		opportunityFieldsMap.put('StageName', 'Pending Credit Report');
		opportunityFieldsMap.put('CF_Stage__c', 'Pending Credit Report - Order was sent');
		fieldsMap.put('Opportunity', opportunityFieldsMap);

		return fieldsMap;
	}


	/*******************************************************************************
    *  Summary         : Send API request to start report check
    *  CreatedDate     : 13/08/2020 by Anton Buzak
    *  Parameters      : companyId - id of selected company
    *  Returns         : -
    ******************************************************************************/
    public override void requestStartReportsCheck(String companyId) {
        try {
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('Schufa');
			HttpRequest authRequest = CreditFactoryWebSchufa2.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
			Http http = new Http();
			HttpResponse authResponse = http.send(authRequest);
			this.apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(authResponse, 'auth');
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}

			SchufaEntity authEntity = SchufaEntity.parse(authResponse.getBody());
			HttpRequest orderEconomyInfoRequest = CreditFactoryWebSchufa2.generateOrderEconomyInfoRequest(authEntity.accessToken, creditSystem.Endpoint__c, companyId);
			HttpResponse orderEconomyInfoResponse = http.send(orderEconomyInfoRequest);
			this.apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(orderEconomyInfoResponse, 'orderEconomyInfo');
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
        } catch (Exception e) {
			ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
			String companyIdText = 'Company Id: ' + companyId;
            if (! String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage + '. ' + companyIdText);
            }
            else if (e.getMessage().contains('Read timed out')) {
                throw new CreditFactoryException(CreditFactoryGlobalUtils.SCHUFA_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.' + '. ' + companyIdText);
            }
            else {
                throw new CreditFactoryException('Start report check failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + '. ' + companyIdText);
            }
        }
    }


	/*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 24/10/2019 by Anton Buzak
    *  Parameters      : companyId - id of selected company
    *  Returns         : credit reports
    ******************************************************************************/
    public override CreditFactoryReportsItem requestCompanyReports(String companyId) {
        String serviceName = 'Schufa';
        try {
            CreditFactoryReportsItem reportsItem = new CreditFactoryReportsItem();
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('Schufa');
			HttpRequest authRequest = CreditFactoryWebSchufa2.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
			Http http = new Http();
			HttpResponse authResponse = http.send(authRequest);
			this.apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(authResponse, 'auth');
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}

			SchufaEntity authEntity = SchufaEntity.parse(authResponse.getBody());

			HttpRequest orderStatusRequest = CreditFactoryWebSchufa2.generateOrderStatusRequest(authEntity.accessToken, creditSystem.Endpoint__c, companyId);
            HttpResponse orderStatusResponse = http.send(orderStatusRequest);
            this.apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(orderStatusResponse, 'orderStatus');
            if (! String.isEmpty(this.apiErrorMessage)) {
                throw new CreditFactoryException(this.apiErrorMessage);
            }

			Boolean completed = false;
			if (orderStatusResponse.getStatusCode() != 404) {
				SchufaEntity orderStatusEntity = SchufaEntity.parse(orderStatusResponse.getBody());
				for (SchufaEntity.Order order : orderStatusEntity.order) {
					if (order.name == 'FullEconomyInfo') {
						if (!order.reason.contains('Es werden derzeit keine Auskünfte zu diesem Unternehmen erteilt.')) {
							completed = order.completed;
						} else {
							reportsItem.isReportAvailable = false;
							reportsItem.isOrderAvailable = false;
							reportsItem.errorMessage = 'Credit report is not available. Please refer to Credit.';
							return reportsItem;
						}

						break;
					}
				}
			}

			HttpResponse reportResponse;
			if (completed == true) {
				HttpRequest reportRequest = CreditFactoryWebSchufa2.generateReportRequest(authEntity.accessToken, creditSystem.Endpoint__c, companyId);
				reportResponse = http.send(reportRequest);
				this.apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(reportResponse, 'report');
				if (!String.isEmpty(this.apiErrorMessage)) {
					throw new CreditFactoryException(this.apiErrorMessage);
				}

				this.externalCFCompany = CreditFactoryWebSchufa2.returnReportCompany(reportResponse.getBody());
				LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
				if (lexisNexisSettings.Active__c == true) {
					serviceName = 'LexisNexis';
					HttpResponse lexisNexisResponse = requestLexisNexisReport(lexisNexisSettings);
					this.apiErrorMessage = CreditFactoryGlobalUtils.checkLexisNexisAPIErrors(lexisNexisResponse);
					if (!String.isEmpty(this.apiErrorMessage)) {
						throw new CreditFactoryException(this.apiErrorMessage);
					}

					Dom.XmlNode XmlNodeLexisNexis = getXmlNode(lexisNexisResponse.getBody());
					Dom.XmlNode emailRiskBody = CreditFactoryWebLexisNexis.returnEmailRiskBody(XmlNodeLexisNexis);
					this.externalCFCompany = CreditFactoryWebLexisNexis.returnReportCompany(emailRiskBody, this.externalCFCompany);
				}

				reportsItem.companiesList = new List<CreditFactoryCompany>();
				reportsItem.companiesList.add(this.externalCFCompany);
				reportsItem.isReportAvailable = true;
			} else {
				reportsItem.isWaiting = true;
				reportsItem.errorMessage = 'The order is still being processed. Please contact your administrator.';
			}

			return reportsItem;
        } catch (Exception e) {
			ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
			String companyIdText = 'Company Id: ' + companyId;
            if (! String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage + '. ' + companyIdText);
            }
            else if (e.getMessage().contains('Read timed out')) {
                throw new CreditFactoryException(CreditFactoryGlobalUtils.returnServiceError(serviceName) + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.' + '. ' + companyIdText);
            }
            else {
                throw new CreditFactoryException('Set company error. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + '. ' + companyIdText);
            }
        }
    }


	/*******************************************************************************
    *  Summary         : replace country specific characters
    *  Created         : 10/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : string without country specific characters
    ******************************************************************************/
    protected override String replaceSpecificCharacters(String stringToReplace) {
        if (stringToReplace != null) {
            if (stringToReplace.contains('Ä')) stringToReplace = stringToReplace.replace('Ä', 'AE');
            if (stringToReplace.contains('ä')) stringToReplace = stringToReplace.replace('ä', 'ae');
            if (stringToReplace.contains('Ö')) stringToReplace = stringToReplace.replace('Ö', 'OE');
            if (stringToReplace.contains('ö')) stringToReplace = stringToReplace.replace('ö', 'oe');
            if (stringToReplace.contains('Ü')) stringToReplace = stringToReplace.replace('Ü', 'UE');
            if (stringToReplace.contains('ü')) stringToReplace = stringToReplace.replace('ü', 'ue');
            // "ß" cannot be capital
            if (stringToReplace.contains('ß')) stringToReplace = stringToReplace.replace('ß', 'ss');
        }

        return stringToReplace;
    }


	 /*******************************************************************************
    *  Summary         : returns birth date
    *  CreatedDate     : 21/09/2020 by Anton Buzak
    *  Parameters      : sfContact - primary contact in Salesforce
    *  Returns         : date of birth
    ******************************************************************************/
    protected override Date returnCfContactBirthdate() {
        CreditFactoryCompany.CreditFactoryContact primaryContact;
        for (CreditFactoryCompany.CreditFactoryContact contact : this.internalCFCompany.creditFactoryContacts) {
            if (contact.relation == 'OpportunityContactRole') {
                if (contact.isPrimary == true) {
                    primaryContact = contact;
                    break;
                }
            }
        }

        Date cfContactDateOfBirth;
        if (primaryContact != null) {
            Set<String> contactsFirstAndLastNamesSet = new Set<String>();
            String firstName = '';
            if (primaryContact.firstName != null) {
                firstName = replaceSpecificCharacters(primaryContact.firstName).toUpperCase().replace('’', '\'');
            }

            String lastName = replaceSpecificCharacters(primaryContact.lastName).toUpperCase().replace('’', '\'');
            contactsFirstAndLastNamesSet.add((firstName + ' ' + lastName).removeStart(' '));
            contactsFirstAndLastNamesSet.add((lastName + ' ' + firstName).removeEnd(' '));
            for (CreditFactoryCompany.CreditFactoryContact contact : this.externalCFCompany.creditFactoryContacts) {
                if (contact.name != null && contactsFirstAndLastNamesSet.contains(replaceSpecificCharacters(contact.name.toUpperCase().replace('’', '\''))) &&
                        contact.dateOfBirth != null && contact.dateOfBirth.length() == 10) {
                    cfContactDateOfBirth = Date.newInstance(Integer.valueOf(contact.dateOfBirth.substring(6, 10)), Integer.valueOf(contact.dateOfBirth.substring(3, 5)),
                        Integer.valueOf(contact.dateOfBirth.substring(0, 2)));
                    break;
                }
            }
        }

        return cfContactDateOfBirth;
    }


	/*******************************************************************************
    *  Summary         : Calculate credit limits, deposit etc.
    *  CreatedDate     : 26/12/2019 by Anton Buzak
    *  Parameters      : paymentDetailsSet - possible payment details,
                         validationItemsMap - validations results map
    *  Returns         : Credit Factory result structure
    ******************************************************************************/
    public override CreditFactoryResult doCreditScoring(Set<String> paymentDetailsSet, Map<String, CreditFactoryValidationItem> validationItemsMap) {
        try {
            CreditFactoryResult cfResult = new CreditFactoryResult();
            if (validationItemsMap.containsKey('EmailRisk') && validationItemsMap.get('EmailRisk').passed == false) {
                cfResult.verdict = 'No';
                cfResult.statusCode = '009';
                return cfResult;
            }
            else if (validationItemsMap.containsKey('BlackList') && validationItemsMap.get('BlackList').passed == false) {
                cfResult.verdict = 'No';
                cfResult.statusCode = '008';
                return cfResult;
            }
            else if (validationItemsMap.containsKey('Industry') && validationItemsMap.get('Industry').passed == false) {
                cfResult.verdict = 'No';
                cfResult.statusCode = '010';
                return cfResult;
            }

			this.validationItemsMap = validationItemsMap;

            setFuelPriceIndex();
            setBuffer();
			setRecommendedCreditLimit();
			setDateOfFoundation();
			setCalculationsForNewBusinessException(paymentDetailsSet);

            for (String paymentDetail : paymentDetailsSet) {
                if (paymentDetail == '7+7') {
                    this.creditLimit7Plus7 = calculateCreditLimit(7, 7);
                    this.securityLevel7Plus7 = calculateSecurityLevel(this.creditLimit7Plus7, 7, 7);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel7Plus7, this.creditLimit7Plus7, 7, 7, this.recommendedCreditLimit);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit7Plus7);
                    this.maxCreditLimit7Plus7 = calculateMaxCreditLimit(7, 7, this.creditLimit7Plus7, this.deposit7Plus7);
					if (this.creditLimit7Plus7 < 700 && this.recommendedCreditLimit > 1000 && this.creditLimit7Plus7 * 1.5 <= this.maxCreditLimit7Plus7 && this.deposit7Plus7 == 0) {
						this.creditLimit7Plus7 = this.creditLimit7Plus7 * 1.5;
						this.creditLimit7Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.creditLimit7Plus7);
					}

					if (this.securityLevel7Plus7 != null) {
						this.depositReason7plus7 = setDepositReason(this.securityLevel7Plus7, paymentDetail);
					}
                }
				else if (paymentDetail == '15+7') {
                    this.creditLimit15Plus7 = calculateCreditLimit(15, 7);
                    this.securityLevel15Plus7 = calculateSecurityLevel(this.creditLimit15Plus7, 15, 7);
                    this.deposit15Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel15Plus7, this.creditLimit15Plus7, 15, 7, this.recommendedCreditLimit);
                    this.deposit15Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit15Plus7);
                    this.maxCreditLimit15Plus7 = calculateMaxCreditLimit(15, 7, this.creditLimit15Plus7, this.deposit15Plus7);
                    this.maxCreditLimit15Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit15Plus7);
					if (this.creditLimit15Plus7 < 700 && this.recommendedCreditLimit > 1000 && this.creditLimit15Plus7 * 1.5 <= this.maxCreditLimit15Plus7 && this.deposit15Plus7 == 0) {
						this.creditLimit15Plus7 = this.creditLimit15Plus7 * 1.5;
						this.creditLimit15Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.creditLimit15Plus7);
					}

					if (this.securityLevel15Plus7 != null) {
						this.depositReason15plus7 = setDepositReason(this.securityLevel15Plus7, paymentDetail);
					}
                }
				else if (paymentDetail == '30+7') {
                    this.creditLimit30Plus7 = calculateCreditLimit(30, 7);
                    this.securityLevel30Plus7 = calculateSecurityLevel(this.creditLimit30Plus7, 30, 7);
                    this.deposit30Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel30Plus7, this.creditLimit30Plus7, 30, 7, this.recommendedCreditLimit);
                    this.deposit30Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit30Plus7);
                    this.maxCreditLimit30Plus7 = calculateMaxCreditLimit(30, 7, this.creditLimit30Plus7, this.deposit30Plus7);
					if (this.creditLimit30Plus7 < 700 && this.recommendedCreditLimit > 1000 && this.creditLimit30Plus7 * 1.5 <= this.maxCreditLimit30Plus7 && this.deposit30Plus7 == 0) {
						this.creditLimit30Plus7 = this.creditLimit30Plus7 * 1.5;
						this.creditLimit30Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.creditLimit30Plus7);
					}

					if (this.securityLevel30Plus7 != null) {
						this.depositReason30plus7 = setDepositReason(this.securityLevel30Plus7, paymentDetail);
					}
                }
				else if (paymentDetail == '30+10') {
					this.creditLimit30Plus10 = calculateCreditLimit(30, 10);
					this.securityLevel30Plus10 = calculateSecurityLevel(this.creditLimit30Plus10, 30, 10);
					this.deposit30Plus10 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel30Plus10, this.creditLimit30Plus10, 30, 10, this.recommendedCreditLimit);
					this.deposit30Plus10 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit30Plus10);
					this.maxCreditLimit30Plus10 = calculateMaxCreditLimit(30, 10, this.creditLimit30Plus10, this.deposit30Plus10);
					if (this.creditLimit30Plus10 < 700 && this.recommendedCreditLimit > 1000 && this.creditLimit30Plus10 * 1.5 <= this.maxCreditLimit30Plus10 && this.deposit30Plus10 == 0) {
						this.creditLimit30Plus10 = this.creditLimit30Plus10 * 1.5;
						this.creditLimit30Plus10 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.creditLimit30Plus10);
					}

					if (this.securityLevel30Plus10 != null) {
						this.depositReason30plus10 = setDepositReason(this.securityLevel30Plus10, paymentDetail);
					}
				}
            }

			this.riskCategory = CreditFactoryGlobalUtils.returnRiskCategory(this.buffer);

            setDefaultPaymentDetails(paymentDetailsSet);
            setDecision();
            setMessages();
            setAvailableButtons();
			setResultsList(paymentDetailsSet);

            cfResult.verdict = this.verdict;
            cfResult.statusCode = this.statusCode;
            cfResult.messagesList = this.messagesList;
            cfResult.billingPeriod = this.billingPeriod;
            cfResult.paymentTerms = this.paymentTerms;
            cfResult.creditLimit = this.creditLimit;
            cfResult.securityLevel = this.securityLevel;
            cfResult.deposit = this.deposit;
            cfResult.maxCreditLimit = this.maxCreditLimit;
            cfResult.availableButtonsList = this.availableButtonsList;
			cfResult.riskCategory = this.riskCategory;
            cfResult.paymentMethodsSet = new List<String>{
				'Direct Debit'
            };
            cfResult.invoicesSet = new List<String>{
				'e-Invoicing', 'Paper Invoice'
            };

			cfResult.depositReason = this.depositReason;
			cfResult.resultsList = this.resultsList;


            return cfResult;
        } catch (Exception e) {
            throw new CreditFactoryException('Credit Scoring failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
		}
    }


    /*******************************************************************************
    *  Summary         : Set fuel price index
    *  CreatedDate     : 26/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
		Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance('Germany');
		this.fuelPriceIndex = fuelPrice.Index__c;
	}


    /*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 26/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setBuffer() {
        if (this.externalCFCompany.classRating == '1' || this.externalCFCompany.classRating == '2') {
	        this.buffer = 0.3;
	    }
        else if (this.externalCFCompany.classRating == '3') {
	    	this.buffer = 0.2;
	    }
        else if (this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == '5' || this.externalCFCompany.classRating == null) {
	    	this.buffer = 0.1;
	    }
		else if (this.externalCFCompany.classRating == '6') {
	    	this.buffer = 0;
	    }
    }


	/*******************************************************************************
    *  Summary         : set recommended CL
    *  Created         : 12/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setRecommendedCreditLimit() {
		this.recommendedCreditLimit = 0;
		if (this.externalCFCompany.creditLimit != null && this.externalCFCompany.creditLimit.isNumeric()) {
			this.recommendedCreditLimit = Decimal.valueOf(this.externalCFCompany.creditLimit);
		}
    }


	/*******************************************************************************
    *  Summary         : set date of foundation
    *  Created         : 12/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDateOfFoundation() {
		if (this.externalCFCompany.dateOfFoundation != null) {
			this.dateOfFoundation = Date.newInstance(Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(6, 10)), Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(3, 5)),
				Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(0, 2)));
		}
    }


    /*******************************************************************************
    *  Summary         : Calculate credit limit
    *  Created         : 26/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : credit limit
    ******************************************************************************/
    private Decimal calculateCreditLimit(Decimal billingPeriod, Decimal paymentTerms) {
		String paymentDetail = billingPeriod + '+' + paymentTerms;
		Decimal buffer = (this.calculationsMap.get(paymentDetail).highRisk ? 0.1 : this.buffer);
        Decimal creditLimit = (this.internalCFCompany.totalConsumption * this.fuelPriceIndex + this.internalCFCompany.nonFuelExposure) * ((billingPeriod + paymentTerms) / 30) * (1 + buffer);
        creditLimit = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(creditLimit);
        return creditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate security level
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
						 billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : Security Level
    ******************************************************************************/
    private Decimal calculateSecurityLevel(Decimal creditLimit, Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
		String paymentDetail = billingPeriod + '+' + paymentTerms;
		String securityLevelForNewBusiness = this.calculationsMap.get(paymentDetail).securityLevel;
		if (securityLevelForNewBusiness == '*') {
			if (this.externalCFCompany.classRating == '1') {
				securityLevel = calculateSecurityLevelRating1(creditLimit);
			}
			else if (this.externalCFCompany.classRating == '2') {
				securityLevel = calculateSecurityLevelRating2(creditLimit);
			}
			else if (this.externalCFCompany.classRating == '3') {
				securityLevel = calculateSecurityLevelRating3(creditLimit);
			}
			else if (this.externalCFCompany.classRating == '4') {
				securityLevel = calculateSecurityLevelRating4(creditLimit, billingPeriod, paymentTerms);
			}
			else if (this.externalCFCompany.classRating == '5') {
				securityLevel = calculateSecurityLevelRating5();
			}
			else if (this.externalCFCompany.classRating == '6') {
				securityLevel = calculateSecurityLevelRating6();
			}
		}
		else if (securityLevelForNewBusiness != null) {
			securityLevel = Decimal.valueOf(securityLevelForNewBusiness);
		}

		if (securityLevel == null && this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
			securityLevel = 100;
		}

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 1
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating1(Decimal creditLimit) {
		Decimal securityLevel;
		if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 4;
		} else {
			securityLevel = null;
		}


        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 2
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 2
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating2(Decimal creditLimit) {
		Decimal securityLevel;
		if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 4;
		} else {
			securityLevel = null;
		}

        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 3
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 3
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating3(Decimal creditLimit) {
		Decimal securityLevel;
		if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 4;
		} else {
			securityLevel = null;
		}

        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 4
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 4
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating4(Decimal creditLimit, Decimal billingPeriod, Decimal paymentTerms) {
		Decimal securityLevel;
		if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 4;
		}
		else {
			securityLevel = null;
		}

		if (billingPeriod == 30 && paymentTerms == 7 && securityLevel == null) {
			securityLevel = 50;
		}

        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 5
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : security Level for Rating 5
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating5() {
		Decimal securityLevel = 100;
        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 6
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : security Level for Rating 6
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating6() {
		Decimal securityLevel = 110;
        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level if it's a new business exception
    *  Created         : 11/03/2021 by Ivan Kulinkovich
    *  Parameters      : Set<String> paymentDetailsSet
    *  Returns         : security level
    ******************************************************************************/
	private void setCalculationsForNewBusinessException(Set<String> paymentDetailsSet) {
		this.calculationsMap = new Map<String, CreditFactoryCompany.CreditFactoryCalculation>();
		List<CreditFactoryCompany.CreditFactoryCalculation> calculations = this.internalCFCompany.calculations;
		for (String paymentDetail : paymentDetailsSet) {
			for (CreditFactoryCompany.CreditFactoryCalculation calculation : calculations) {
				if (arePaymentDetailsValid(paymentDetail, calculation.paymentDetail) && isClassRatingValid(calculation.classRating) &&
						isDateOfFoundationMonthValid(calculation.dateOfFoundationMonths, calculation.dateOfFoundationMonthsOperator) &&
						isNumberOfCardsValid(calculation.numberOfCards, calculation.numberOfCardsOperator) &&
						isTotalConsumptionValid(calculation.totalConsumptionMinValue, calculation.totalConsumptionMaxValue)) {
					if (calculation.securityLevel == null && this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
						calculation.newBusinessException = false;
					}

					this.calculationsMap.put(paymentDetail, calculation);
					break;
				}
			}

			if (! this.calculationsMap.containsKey(paymentDetail)) {
				CreditFactoryCompany.CreditFactoryCalculation calculation = CreditFactoryGlobalUtils.generateDefaultCalculation();
				this.calculationsMap.put(paymentDetail, calculation);
			}
		}
	}


	/*******************************************************************************
    *  Summary         : check for payment detail
    *  Created         : 15/03/2021 by Ivan Kulinkovich
    *  Parameters      : String classRating
    *  Returns         : Boolean
    ******************************************************************************/
	private Boolean arePaymentDetailsValid(String paymentDetail, String calculationPaymentDetail) {
		if (paymentDetail == calculationPaymentDetail || calculationPaymentDetail == '*') {
			return true;
		}

		return false;
	}


	/*******************************************************************************
    *  Summary         : check for class rating
    *  Created         : 11/03/2021 by Ivan Kulinkovich
    *  Parameters      : String classRating
    *  Returns         : Boolean
    ******************************************************************************/
	private Boolean isClassRatingValid(String classRating) {
		if (classRating == this.externalCFCompany.classRating || classRating == '*') {
			return true;
		}

		return false;
	}


	/*******************************************************************************
    *  Summary         : check for date of foundation
    *  Created         : 11/03/2021 by Ivan Kulinkovich
    *  Parameters      : String months, String operator
    *  Returns         : Boolean
    ******************************************************************************/
	private Boolean isDateOfFoundationMonthValid(String months, String operator) {
		if (operatorsSet.contains(operator) && ! String.isEmpty(months) && this.dateOfFoundation != null) {
			Decimal value1 = this.dateOfFoundation.monthsBetween(Date.today());
			Decimal value2 = Integer.valueOf(months);
			return CreditFactoryGlobalUtils.compareValues(value1, value2, operator);
		}

		return true;
	}


	/*******************************************************************************
    *  Summary         : check for number of cards
    *  Created         : 11/03/2021 by Ivan Kulinkovich
    *  Parameters      : String numberOfCards, String operator
    *  Returns         : Boolean
    ******************************************************************************/
	private Boolean isNumberOfCardsValid(String numberOfCards, String operator) {
		if (operatorsSet.contains(operator) && ! String.isEmpty(numberOfCards) && this.internalCFCompany.numberOfCards != null) {
			Decimal value1 = Integer.valueOf(this.internalCFCompany.numberOfCards);
			Decimal value2 = Integer.valueOf(numberOfCards);
			return CreditFactoryGlobalUtils.compareValues(value1, value2, operator);
		}

		return true;
	}


	/*******************************************************************************
    *  Summary         : check for total consumption
    *  Created         : 11/03/2021 by Ivan Kulinkovich
    *  Parameters      : String minValue, String maxValue
    *  Returns         : Boolean
    ******************************************************************************/
	private Boolean isTotalConsumptionValid(String minValue, String maxValue) {
		if (! String.isEmpty(minValue) && ! String.isEmpty(maxValue)) {
			if (minValue == '*' && maxValue == '*' ||
					minValue == '*' && maxValue != '*' && this.internalCFCompany.totalConsumption <= Integer.valueOf(maxValue) ||
					minValue != '*' && maxValue == '*' && this.internalCFCompany.totalConsumption >= Integer.valueOf(minValue) ||
					this.internalCFCompany.totalConsumption >= Integer.valueOf(minValue) && this.internalCFCompany.totalConsumption <= Integer.valueOf(maxValue)) {
				return true;
			}
			else {
				return false;
			}
		}

		return true;
	}


    /*******************************************************************************
    *  Summary         : calculate max CL
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : Decimal billingPeriod, Decimal paymentTerms,
     					 Decimal creditLimit, Decimal deposit
    *  Returns         : max credit limit
    ******************************************************************************/
    private Decimal calculateMaxCreditLimit(Decimal billingPeriod, Decimal paymentTerms, Decimal creditLimit, Decimal deposit) {
        Decimal maxCreditLimit;
        if (deposit > 0) {
            maxCreditLimit = creditLimit;
        }
		else {
			String paymentDetail = billingPeriod + '+' + paymentTerms;
			CreditFactoryCompany.CreditFactoryCalculation calculation = this.calculationsMap.get(paymentDetail);
			if (calculation.totalConsumptionMaxValue != '*') {
				Decimal totalConsumption = Integer.valueOf(calculation.totalConsumptionMaxValue);
				Decimal buffer = (calculation.highRisk ? 0.1 : this.buffer);
				Decimal creditLimitMax = ((totalConsumption * this.fuelPriceIndex + this.internalCFCompany.nonFuelExposure) * ((billingPeriod + paymentTerms) / 30.0) * (1.0 + buffer)).setScale(2);
				if (creditLimit * 2 < creditLimitMax) {
					maxCreditLimit = creditLimit * 2;
				}
				else {
					maxCreditLimit = creditLimitMax;
				}
			}
			else {
				if (this.recommendedCreditLimit + 500 > creditLimit * 2) {
					if (creditLimit * 2 < 8000) {
						maxCreditLimit = creditLimit * 2;
					}
					else {
						maxCreditLimit = 8000;
					}
				}
				else {
					if (this.recommendedCreditLimit + 500 < 8000) {
						maxCreditLimit = this.recommendedCreditLimit + 500;
					}
					else {
						maxCreditLimit = 8000;
					}
				}
			}
		}

        maxCreditLimit = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(maxCreditLimit);

        return maxCreditLimit;
    }


	/*******************************************************************************
    *  Summary         : set deposit reason
    *  Created         : 16/11/2020 by Ivan Kulinkovich
    *  Parameters      : securityLevel - security level
    *                    paymentDetail - payment detail
    *  Returns         : deposit reason
    ******************************************************************************/
	private String setDepositReason(Decimal securityLevel, String paymentDetail) {
		String depositReason = this.calculationsMap.get(paymentDetail).depositReason;
		if (String.isEmpty(depositReason)) {
			depositReason = 'Low credit rating (rating ' + this.externalCFCompany.classRating + ')';
			if (securityLevel == 4) {
				depositReason = 'Low Recommended CL';
			}
			else if (securityLevel == 50) {
				depositReason = 'Low credit rating (rating 4 & 30+7)';
			}
			else if (this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
				depositReason = 'Invalid contact';
			}
		}

		return depositReason;
	}

    /*******************************************************************************
    *  Summary         : set default billing period and payment terms
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails(Set<String> paymentDetailsSet) {
		if (paymentDetailsSet.contains('30+10') && this.creditLimit30Plus10 < 8000 && this.internalCFCompany.secChannel == 'Outbound' &&
				this.deposit30Plus10 == 0 && (this.externalCFCompany.classRating == '1' || this.externalCFCompany.classRating == '2')) {
			if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues7Plus7();
			}
			else if (this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues15Plus7();
			}
			else if (this.internalCFCompany.desiredBillingPeriod == '30' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues30Plus7();
			}
			else {
				setDefaultValues30Plus10();
			}
		}
		else if (paymentDetailsSet.contains('30+7') && this.creditLimit30Plus7 < 8000 && this.deposit30Plus7 == 0) {
			if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues7Plus7();
			}
			else if (this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues15Plus7();
			}
			else {
				setDefaultValues30Plus7();
			}
		}
        else if (paymentDetailsSet.contains('15+7') && this.creditLimit15Plus7 < 8000 && this.deposit15Plus7 == 0) {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus7();
            }
        }
        else if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 8000 && this.deposit7Plus7 == 0) {
            setDefaultValues7Plus7();
        }
		else if (paymentDetailsSet.contains('30+7') && this.creditLimit30Plus7 < 8000) {
			if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues7Plus7();
			}
			else if (this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues15Plus7();
			}
			else {
				setDefaultValues30Plus7();
			}
		}
        else if (paymentDetailsSet.contains('15+7') && this.creditLimit15Plus7 < 8000) {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus7();
            }
        }
        else if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 8000) {
            setDefaultValues7Plus7();
        }
    }


    /*******************************************************************************
    *  Summary         : set default values for 7+7
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : String paymentDetail
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues7Plus7() {
        this.billingPeriod = '7';
        this.paymentTerms = '7';
        this.creditLimit = this.creditLimit7Plus7;
        this.securityLevel = this.securityLevel7Plus7;
        this.deposit = this.deposit7Plus7;
		this.depositReason = this.depositReason7plus7;
        this.maxCreditLimit = this.maxCreditLimit7Plus7;
		this.isNewBusinessException = this.calculationsMap.get('7+7').newBusinessException;
		this.riskCategory = (this.calculationsMap.get('7+7').highRisk ? 'High' : this.riskCategory);
    }


    /*******************************************************************************
    *  Summary         : set default values for 15+7
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues15Plus7() {
        this.billingPeriod = '15';
        this.paymentTerms = '7';
        this.creditLimit = this.creditLimit15Plus7;
        this.securityLevel = this.securityLevel15Plus7;
        this.deposit = this.deposit15Plus7;
		this.depositReason = this.depositReason15plus7;
        this.maxCreditLimit = this.maxCreditLimit15Plus7;
		this.isNewBusinessException = this.calculationsMap.get('15+7').newBusinessException;
		this.riskCategory = (this.calculationsMap.get('15+7').highRisk ? 'High' : this.riskCategory);
    }


	/*******************************************************************************
    *  Summary         : set default values for 30+7
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues30Plus7() {
        this.billingPeriod = '30';
        this.paymentTerms = '7';
        this.creditLimit = this.creditLimit30Plus7;
        this.securityLevel = this.securityLevel30Plus7;
        this.deposit = this.deposit30Plus7;
		this.depositReason = this.depositReason30plus7;
        this.maxCreditLimit = this.maxCreditLimit30Plus7;
		this.isNewBusinessException = this.calculationsMap.get('30+7').newBusinessException;
		this.riskCategory = (this.calculationsMap.get('30+7').highRisk ? 'High' : this.riskCategory);
    }


	/*******************************************************************************
    *  Summary         : set default values for 30+10
    *  Created         : 15/06/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
	private void setDefaultValues30Plus10() {
		this.billingPeriod = '30';
		this.paymentTerms = '10';
		this.creditLimit = this.creditLimit30Plus10;
		this.securityLevel = this.securityLevel30Plus10;
		this.deposit = this.deposit30Plus10;
		this.depositReason = this.depositReason30plus10;
		this.maxCreditLimit = this.maxCreditLimit30Plus10;
	}


    /*******************************************************************************
    *  Summary         : set decision
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDecision() {
		if (this.billingPeriod != null && this.paymentTerms != null) {
			this.verdict = 'Yes';
			this.statusCode = '001';
		}
		else {
			this.verdict = 'No';
			this.statusCode = '004';
		}
    }


    /*******************************************************************************
    *  Summary         : set decision description
    *  Created         : 12/02/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMessages() {
        this.messagesList = new List<CreditFactoryResult.Message>();
        if (this.statusCode == '001') {
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Billing Period can be set to ' + this.billingPeriod));
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Payment Terms can be set to ' + this.paymentTerms));
            if (this.deposit > 0) {
                this.messagesList.add(new CreditFactoryResult.Message('info', '</br>Deposit to pay: ' + this.deposit + ' EUR.</br>' +
					'Deposit reason: ' + this.depositReason + '</br></br>' +
                    'You can update Desired Payment Terms and Desired Billing Period in the Opportunity and restart Credit Factory to recalculate the deposit amount.'));
            }

            if (this.internalCFCompany.desiredPaymentTerms != null && this.internalCFCompany.desiredPaymentTerms != this.paymentTerms ||
                    this.internalCFCompany.desiredBillingPeriod != null && this.internalCFCompany.desiredBillingPeriod != this.billingPeriod) {
                this.messagesList.add(new CreditFactoryResult.Message('warning', 'If you want to close your Opportunity with ' +
                    'desired billing period and desired payment terms, please refer to Credit.'));
                if (this.internalCFCompany.desiredPaymentTerms != null && this.internalCFCompany.desiredPaymentTerms != this.paymentTerms) {
                    this.messagesList.add(new CreditFactoryResult.Message('warning', 'Desired payment terms (' +
                        this.internalCFCompany.desiredPaymentTerms + ') cannot be provided.'));
                }

                if (this.internalCFCompany.desiredBillingPeriod != null && this.internalCFCompany.desiredBillingPeriod != this.billingPeriod) {
                    this.messagesList.add(new CreditFactoryResult.Message('warning', 'Desired billing period (' +
                        this.internalCFCompany.desiredBillingPeriod + ') cannot be provided.'));
                }
            }
        }
        else if (this.statusCode == '004') {
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Requested limit too high. Please refer to credit.'));
        }
    }


    /*******************************************************************************
    *  Summary         : set available button (pending deposit, closed won etc)
    *  Created         : 25/05/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setAvailableButtons() {
        this.availableButtonsList = new List<String>();
        if (this.verdict == 'Yes') {
            this.availableButtonsList.add('Update Opportunity');
            if (this.deposit != null && this.deposit != 0) {
                this.availableButtonsList.add('Pending Deposit');
            }
            else {
                if (this.internalCFCompany.paymentMethod == 'Lastschrift' && (this.internalCFCompany.directDebitFormAvailable == false || String.isEmpty(this.internalCFCompany.iban))) {
                    this.availableButtonsList.add('Pending SEPA');
                }
                else {
                    this.availableButtonsList.add('Closed Won');
                }
            }
        }
    }


	/*******************************************************************************
    *  Summary         : set results list
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setResultsList(Set<String> paymentDetailsSet) {
		this.resultsList = new List<CreditFactoryResult>();
		String riskCategory = CreditFactoryGlobalUtils.returnRiskCategory(this.buffer);
		if (paymentDetailsSet.contains('30+7') && this.creditLimit30Plus7 < 8000) {
			CreditFactoryResult result30Plus7 = new CreditFactoryResult();
			result30Plus7.verdict = 'Yes';
			result30Plus7.statusCode = '001';
			result30Plus7.billingPeriod = '30';
			result30Plus7.paymentTerms = '7';
			result30Plus7.creditLimit = this.creditLimit30Plus7;
			result30Plus7.securityLevel = this.securityLevel30Plus7;
			result30Plus7.deposit = this.deposit30Plus7;
			result30Plus7.depositReason = this.depositReason30plus7;
			result30Plus7.maxCreditLimit = this.maxCreditLimit30Plus7;
			result30Plus7.riskCategory = (this.calculationsMap.get('30+7').highRisk ? 'High' : riskCategory);
			result30Plus7.classRating = (this.calculationsMap.get('30+7').newBusinessException ? '0-EX' : this.externalCFCompany.classRating);
			result30Plus7.paymentMethodsSet = new List<String> {'Direct Debit'};
			result30Plus7.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};
			if (this.billingPeriod == result30Plus7.billingPeriod && this.paymentTerms == result30Plus7.paymentTerms) {
				result30Plus7.isDefault = true;
			}

			resultsList.add(result30Plus7);
		}

		if (paymentDetailsSet.contains('15+7') && this.creditLimit15Plus7 < 8000) {
			CreditFactoryResult result15Plus7 = new CreditFactoryResult();
			result15Plus7.verdict = 'Yes';
			result15Plus7.statusCode = '001';
			result15Plus7.billingPeriod = '15';
			result15Plus7.paymentTerms = '7';
			result15Plus7.creditLimit = this.creditLimit15Plus7;
			result15Plus7.securityLevel = this.securityLevel15Plus7;
			result15Plus7.deposit = this.deposit15Plus7;
			result15Plus7.depositReason = this.depositReason15plus7;
			result15Plus7.maxCreditLimit = this.maxCreditLimit15Plus7;
			result15Plus7.riskCategory = (this.calculationsMap.get('15+7').highRisk ? 'High' : riskCategory);
			result15Plus7.classRating = (this.calculationsMap.get('15+7').newBusinessException ? '0-EX' : this.externalCFCompany.classRating);
			result15Plus7.paymentMethodsSet = new List<String> {'Direct Debit'};
			result15Plus7.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};
			if (this.billingPeriod == result15Plus7.billingPeriod && this.paymentTerms == result15Plus7.paymentTerms) {
				result15Plus7.isDefault = true;
			}

			resultsList.add(result15Plus7);
		}

		if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 8000) {
			CreditFactoryResult result7Plus7 = new CreditFactoryResult();
			result7Plus7.verdict = 'Yes';
			result7Plus7.statusCode = '001';
			result7Plus7.billingPeriod = '7';
			result7Plus7.paymentTerms = '7';
			result7Plus7.creditLimit = this.creditLimit7Plus7;
			result7Plus7.securityLevel = this.securityLevel7Plus7;
			result7Plus7.deposit = this.deposit7Plus7;
			result7Plus7.depositReason = this.depositReason7plus7;
			result7Plus7.maxCreditLimit = this.maxCreditLimit7Plus7;
			result7Plus7.riskCategory = (this.calculationsMap.get('7+7').highRisk ? 'High' : riskCategory);
			result7Plus7.classRating = (this.calculationsMap.get('7+7').newBusinessException ? '0-EX' : this.externalCFCompany.classRating);
			result7Plus7.paymentMethodsSet = new List<String> {'Direct Debit'};
			result7Plus7.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};
			if (this.billingPeriod == result7Plus7.billingPeriod && this.paymentTerms == result7Plus7.paymentTerms) {
				result7Plus7.isDefault = true;
			}

			resultsList.add(result7Plus7);
		}
	}


	/*******************************************************************************
    *  Summary         : create pdf reports asynchronously
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : opportunityId - id of opportunity
    *  Returns         : --
    ******************************************************************************/
    public override void createPdfReports(String opportunityId) {
        // create schedule job for Schufa pdf report
        String schedule = Datetime.now().addSeconds(5).second() + ' ' + Datetime.now().addSeconds(5).minute() + ' ' + Datetime.now().addSeconds(5).hour() + ' ' +
                Datetime.now().addSeconds(5).day() + ' ' + Datetime.now().addSeconds(5).month() + ' ? ' + Datetime.now().addSeconds(5).year();
        String scheduleName = 'Credit Factory Pdf Report ' + Datetime.now().addSeconds(5).minute() + Datetime.now().addSeconds(5).second() +
                Datetime.now().addSeconds(5).millisecond();
        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(this.externalCFCompany.creditSystemCompanyNumber, null, opportunityId, null, this.externalCFCompany.country);
        System.schedule(scheduleName, schedule, pdfSchedule);
    }


	private static Set<String> operatorsSet = new Set<String> {
			'>',
			'>=',
			'=',
			'<',
			'<=',
			'*'
	};

}