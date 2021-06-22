public class LexisNexisWebservice {
    

    /*******************************************************************************
    *  Name            : generateEmailRiskRequest(String endpoint, String userName, String password, String firstName, String lastName, String email)
    *  Summary         : Generate Email Risk request to LexisNexis.
    *  CreatedDate     : 01/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String endpoint - LexisNexis endpoint, String userName - LexisNexis user name, String password - LexisNexis password, 
    					 String firstName - contact first name, String lastName - contact last Name, String email - contact email,
    					 String reference - reference created by user
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateIDURequest(String endpoint, String userName, String password, String firstName, String lastName, String email,
    												   String reference) {
    	Http http = new Http();
    	HttpRequest request = new HttpRequest();
    	request.setHeader('SOAPAction', 'urn:idu#idu#IDUProcess');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        String body = generateIDURequestBody(userName, password, firstName, lastName, email, reference);
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
    	return request;
    }

    /*******************************************************************************
    *  Name            : generateIDURequestBody(String userName, String password, String firstName, String lastName, String email)
    *  Summary         : Generate body for IDU reuqest
    *  CreatedDate     : 01/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String userName - LexisNexis user name, String password - LexisNexis password, String firstName - contact first name, 
    					 String lastName - contact last Name, String email - contact email
    *  Returns         : String reference - reference created by user
    ******************************************************************************/
    private static String generateIDURequestBody(String userName, String password, String firstName, String lastName, String email, String reference) {
    	String body = 
    	'<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:idu" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">' +
			'<soapenv:Header/>' +
			'<soapenv:Body>' +
				'<urn:IDUProcess soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
					'<params xsi:type="urn:Request">' +
						'<IDU xsi:type="urn:IDUDetails">' +
							'<Reference xsi:type="xsd:string">' + reference + '</Reference>' +
						'</IDU>' +
						'<Login xsi:type="urn:LoginDetails">' +
							'<username xsi:type="xsd:string">' + userName + '</username>' +
							'<password xsi:type="xsd:string">' + password + '</password>' +
						'</Login>' +
						'<Person xsi:type="urn:PersonDetails">' +
							'<forename xsi:type="xsd:string">' + firstName + '</forename>' +
							'<surname xsi:type="xsd:string">' + lastName + '</surname>' +
							'<email xsi:type="xsd:string">' + email + '</email>' +
						'</Person>' +
						'<Services xsi:type="urn:ServiceDetails">' +
							// include the following services
							'<emailrisk xsi:type="xsd:boolean">true</emailrisk>' +
						'</Services>' +
					'</params>' +
				'</urn:IDUProcess>' +
			'</soapenv:Body>' +
		'</soapenv:Envelope>';
		return body;
    }


    /*******************************************************************************
    *  Name            : returnEmailRiskBody(Dom.XMLNode envelope)
    *  Summary         : Return Email Risk Body DOM element    
    *  CreatedDate     : 15/05/2019
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode envelope - envelope field from response
    *  Returns         : Dom.XMLNode 
    ******************************************************************************/
    public static Dom.XMLNode returnEmailRiskBody(Dom.XMLNode envelope) {
        for (Dom.XMLNode envelopeField : envelope.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'IDUProcessResponse') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'Results') {
                                for (Dom.XMLNode resultsField : responseField.getChildElements()) {
                                    if (resultsField.getName() == 'EmailRisks') {
                                        for (Dom.XMLNode emailRisksField : resultsField.getChildElements()) {
                                            if (emailRisksField.getName() == 'EmailRisk') {
                                                return emailRisksField;
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

        return null;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return error message
    *  CreatedDate     : 18/02/2020
    *  Parameters      : envelope - envelope field from response
    *  Returns         : error message
    ******************************************************************************/
    public static String returnErrorMessage(Dom.XmlNode envelope) {
        String errorMessage;
        for (Dom.XmlNode envelopeField : envelope.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'IDUProcessResponse') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'Results') {
                                for (Dom.XmlNode resultsField : responseField.getChildElements()) {
                                    if (resultsField.getName() == 'Summary') {
                                        for (Dom.XmlNode summaryField : resultsField.getChildElements()) {
                                            if (summaryField.getName() == 'Errors') {
                                                for (Dom.XmlNode errorsField : summaryField.getChildElements()) {
                                                    if (errorsField.getName() == 'Error') {
                                                        for (Dom.XmlNode errorField : errorsField.getChildElements()) {
                                                            if (errorField.getName() == 'Details') {
                                                                errorMessage = errorField.getText();
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
            }
        }

        return errorMessage;
    }


    /*******************************************************************************
    *  Name            : returnLexisNexisCompanyFields(Dom.XMLNode emailRiskField, CreditCompany creditCompany)
    *  Summary         : Return Credit Company with fields from LexisNexis    
    *  CreatedDate     : 15/05/2019
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode emailRisksField - email risks field from response, 
                         CreditCompany creditCompany - credit company with fields from Credit System
    *  Returns         : 
    ******************************************************************************/
    public static CreditCompany returnReportCompany(Dom.XMLNode emailRisksField, CreditCompany creditCompany) {
        for (Dom.XMLNode emailRiskField : emailRisksField.getChildElements()) {
            if (emailRiskField.getName() == 'EmailExists') {
                creditCompany.emailExists = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'DomainExists') {
                creditCompany.domainExists = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'EmailDate') {
                String emailDate = emailRiskField.getText();
                if (emailDate != null && emailDate.length() >= 10) {
                    creditCompany.emailDate = emailDate.substring(0, 10);
                } else {
                    creditCompany.emailDate = emailRiskField.getText();
                }
            } else if (emailRiskField.getName() == 'DomainDate') { 
                String domainDate = emailRiskField.getText();
                if (domainDate != null && domainDate.length() >= 10) {
                    creditCompany.domainDate = domainDate.substring(0, 10);
                } else {
                    creditCompany.domainDate = emailRiskField.getText();
                }
                creditCompany.domainDate = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'StatusID') { 
                creditCompany.emailStatus = CreditFactoryUtilities.returnEmailStatus(emailRiskField.getText());
            } else if (emailRiskField.getName() == 'FraudRiskBand') {
                creditCompany.emailRisk = CreditFactoryUtilities.returnEmailRisk(emailRiskField.getText());
            } else if (emailRiskField.getName() == 'RiskDescriptionID') {
                creditCompany.riskDescription = CreditFactoryUtilities.returnRiskDescription(emailRiskField.getText());
            } else if (emailRiskField.getName() == 'RiskAdviceID') {
                creditCompany.riskAdvice = CreditFactoryUtilities.returnRiskAdvice(emailRiskField.getText());
            } else if (emailRiskField.getName() == 'FraudWithinIndustry') { 
                creditCompany.fraudWithinIndustry = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'FraudType') {
                creditCompany.fraudType = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'TotalHits') {
                creditCompany.totalHits = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'UniqueHits') {
                creditCompany.uniqueHits = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'NameMatch') {
                creditCompany.nameMatch = CreditFactoryUtilities.returnNameMatch(emailRiskField.getText());
            } else if (emailRiskField.getName() == 'EmailAddress') {
                creditCompany.checkedEmail = emailRiskField.getText();
            }
        }
        return creditCompany;
    }
}