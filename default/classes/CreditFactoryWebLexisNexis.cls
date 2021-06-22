public class CreditFactoryWebLexisNexis {
    

    /*******************************************************************************
    *  Summary         : Generate Email Risk request to LexisNexis.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : endpoint - LexisNexis endpoint, 
                         userName - LexisNexis user name, 
                         password - LexisNexis password, 
    					 firstName - contact first name, 
    					 lastName - contact last Name, 
    					 email - contact email,
    					 reference - reference created by user
    *  Returns         : IDU request
    ******************************************************************************/
    public static HttpRequest generateIDURequest(String endpoint, String userName, String password, String firstName, 
                                                 String lastName, String email, String reference) {
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
    *  Summary         : Generate body for IDU request
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : userName - LexisNexis user name, 
                         password - LexisNexis password, 
                         firstName - contact first name, 
    					 lastName - contact last Name, 
    					 email - contact email,
    					 reference - reference created by user
    *  Returns         : idu request xml
    ******************************************************************************/
    private static String generateIDURequestBody(String userName, String password, String firstName, String lastName, 
                                                 String email, String reference) {
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
							'<emailrisk xsi:type="xsd:boolean">true</emailrisk>' +
						'</Services>' +
					'</params>' +
				'</urn:IDUProcess>' +
			'</soapenv:Body>' +
		'</soapenv:Envelope>';
		return body;
    }


    /*******************************************************************************
    *  Summary         : Return Email Risk Body DOM element    
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : envelope - envelope field from response
    *  Returns         : email risk dom 
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
    *  CreatedDate     : 17/05/2020
    *  Parameters      : envelope - node from response
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
    *  Summary         : Return Credit Company with fields from LexisNexis    
    *  CreatedDate     : 15/05/2019
    *  Parameters      : emailRisksField - email risks field from response, 
                         company - credit company with fields from Credit System
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(Dom.XMLNode emailRisksField, CreditFactoryCompany company) {
        for (Dom.XmlNode emailRiskField : emailRisksField.getChildElements()) {
            if (emailRiskField.getName() == 'EmailExists') {
                company.emailExists = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'DomainExists') {
                company.domainExists = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'EmailDate') {
                String emailDate = emailRiskField.getText();
                if (emailDate != null && emailDate.length() >= 10) {
                    company.emailDate = emailDate.substring(0, 10);
                } else {
                    company.emailDate = emailRiskField.getText();
                }
            } else if (emailRiskField.getName() == 'DomainDate') { 
                String domainDate = emailRiskField.getText();
                if (domainDate != null && domainDate.length() >= 10) {
                    company.domainDate = domainDate.substring(0, 10);
                } else {
                    company.domainDate = emailRiskField.getText();
                }
                company.domainDate = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'StatusID') { 
                if (emailStatusesMap.containsKey(emailRiskField.getText())) {
                    company.emailStatus = emailStatusesMap.get(emailRiskField.getText());
                }
                else {
                    company.emailStatus = emailRiskField.getText();
                }
            } else if (emailRiskField.getName() == 'FraudRiskBand') {
                if (emailRisksMap.containsKey(emailRiskField.getText())) {
                    company.emailRisk = emailRisksMap.get(emailRiskField.getText());
                }
                else {
                    company.emailRisk = emailRiskField.getText();
                }
            } else if (emailRiskField.getName() == 'RiskDescriptionID') {
                if (riskDescriptionsMap.containsKey(emailRiskField.getText())) {
                    company.riskDescription = riskDescriptionsMap.get(emailRiskField.getText());
                }
                else {
                    company.riskDescription = emailRiskField.getText();
                }
            } else if (emailRiskField.getName() == 'RiskAdviceID') {
                if (riskAdvicesMap.containsKey(emailRiskField.getText())) {
                    company.riskAdvice = riskAdvicesMap.get(emailRiskField.getText());
                }
                else {
                    company.riskAdvice = emailRiskField.getText();
                }
            } else if (emailRiskField.getName() == 'FraudWithinIndustry') { 
                company.fraudWithinIndustry = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'FraudType') {
                company.fraudType = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'TotalHits') {
                company.totalHits = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'UniqueHits') {
                company.uniqueHits = emailRiskField.getText();
            } else if (emailRiskField.getName() == 'NameMatch') {
                if (nameMatchesMap.containsKey(emailRiskField.getText())) {
                    company.nameMatch = nameMatchesMap.get(emailRiskField.getText());
                }
                else {
                    company.nameMatch = emailRiskField.getText();
                }
            } else if (emailRiskField.getName() == 'EmailAddress') {
                company.checkedEmail = emailRiskField.getText();
            }
        }
        return company;
    }
    
    
    public static Map<String, String> emailStatusesMap = new Map<String, String> {
        '0' => 'GeneralError',
        '1' => 'Certified',
        '2' => 'Verified',
        '3' => 'EmailNonexistent',
        '4' => 'ValidDomain',
        '5' => 'DomainNonexistent'
    };
    
    
    public static Map<String, String> emailRisksMap = new Map<String, String> {
        '1' => 'Very Low',
        '2' => 'Low',
        '3' => 'Moderate',
        '4' => 'Review',
        '5' => 'High',
        '6' => 'Very High'
    };
    
    
    public static Map<String, String> riskDescriptionsMap = new Map<String, String> {
        '1' => 'Fraud Level X',
        '2' => 'Email does not exist',
        '3' => 'Domain does not exist',
        '4' => 'Risky Domain',
        '5' => 'Risky Country',
        '6' => 'Risky Email Syntax',
        '7' => 'Numeric Email',
        '8' => 'Limited History for Email',
        '9' => 'Email Recently Created',
        '10' => 'Email linked to High Risk Account',
        '11' => 'Good Level X',
        '12' => 'Low Risk Domain',
        '13' => 'Email Created X Years Ago',
        '14' => 'Email Created at least X Years Ago',
        '15' => 'Email Linked to Low Risk Account',
        '16' => 'Invalid Email Syntax',
        '17' => 'Mailbox is Full',
        '18' => 'Mailbox is Inactive',
        '19' => 'Corporate Link',
        '20' => 'Mailbox is Expired',
        '21' => 'User Defined Risk Domain',
        '22' => 'User Defined Low Risk Domain',
        '23' => 'Velocity Level X',
        '24' => 'Risk Domain Category',
        '25' => 'Low Risk Domain Category',
        '26' => 'High Risk Email Account',
        '27' => 'Email Created at least X Months Ago',
        '28' => 'Valid Email From X Country Domain',
        '29' => 'Valid Domain From X Country',
        '30' => 'Potentially Breached Email',
        '31' => 'Fraud Emails Linked X',
        '32' => 'Good Email Linked Level X',
        '33' => 'Fraud IP Level X',
        '34' => 'Good IP Level X',
        '35' => 'Risky Proxy IP',
        '36' => 'Risk IP Behavior',
        '37' => 'Risky IP Country',
        '38' => 'IP Not Found',
        '39' => 'IP Invalid Syntax Format',
        '40' => 'High Risk IP',
        '51' => 'Good Popularity',
        '52' => 'Risk Domain Category Review',
        '53' => 'Tumbling Abuse',
        '54' => 'Email Enumeration for Company',
        '55' => 'Email Enumeration for Industry',
        '56' => 'Creation Date Velocity',
        '61' => 'Customer Email not Provided',
        '62' => 'Risk Email Pattern',
        '63' => 'Suspected Fraud',
        '64' => 'Limited Email Information',
        '65' => 'Domain Recently Created',
        '66' => 'Velocity Other',
        '67' => 'Valid Email From Domain',
        '68' => 'Valid Domain',
        '101' => 'Low Risk Email Domain for Company',
        '102' => 'Low Risk IP for Company',
        '103' => 'Low Risk IP Geolocation for Company',
        '104' => 'Low Risk Email Domain for Industry',
        '105' => 'Low Risk IP for Industry',
        '106' => 'Low Risk IP Geolocation for Industry',
        '107' => 'Low Risk Email Domain for Network',
        '108' => 'Low Risk IP for Network',
        '109' => 'Low Risk IP Geolocation for Network',
        '110' => 'Very Low Risk Email Domain for Company',
        '111' => 'Very Low Risk IP for Company',
        '112' => 'Very Low Risk IP Geolocation for Company',
        '113' => 'Very Low Risk Email Domain for Industry',
        '114' => 'Very Low Risk IP for Industry',
        '115' => 'Very Low Risk IP Geolocation for Industry',
        '116' => 'Very Low Risk Email Domain for Network',
        '117' => 'Very Low Risk IP for Network',
        '118' => 'Very Low Risk IP Geolocation for Network',
        '121' => 'High Risk Email Domain for Company',
        '122' => 'High Risk IP for Company',
        '123' => 'High Risk IP Geolocation for Company',
        '124' => 'High Risk Email Domain for Industry',
        '125' => 'High Risk IP for Industry',
        '126' => 'High Risk IP Geolocation for Industry',
        '127' => 'High Risk Email Domain for Network',
        '128' => 'High Risk IP for Network',
        '129' => 'High Risk IP Geolocation for Network',
        '130' => 'Very High Risk Email Domain for Company',
        '131' => 'Very High Risk IP for Company',
        '132' => 'Very High Risk IP Geolocation for Company',
        '133' => 'Very High Risk Email Domain for Industry',
        '134' => 'Very High Risk IP for Industry',
        '135' => 'Very High Risk IP Geolocation for Industry',
        '136' => 'Very High Risk Email Domain for Network',
        '137' => 'Very High Risk IP for Network',
        '138' => 'Very High Risk IP Geolocation for Network',
        '139' => 'High Risk Phone for Company',
        '140' => 'High Risk Ship Address for Company',
        '141' => 'High Risk Phone for Industry',
        '142' => 'High Risk Ship Address for Industry',
        '143' => 'High Risk Phone for Network',
        '144' => 'High Risk Ship Address for Network',
        '145' => 'Very High Risk Phone for Company',
        '146' => 'Very High Risk Ship Address for Company',
        '147' => 'Very High Risk Phone for Industry',
        '148' => 'Very High Risk Ship Address for Industry',
        '149' => 'Very High Risk Phone for Network',
        '150' => 'Very High Risk Ship Address for Network',
        '151' => 'High Risk Bill Address For Company',
        '152' => 'High Risk Customer ID For Company',
        '153' => 'High Risk Service Location For Company',
        '154' => 'High Risk Bill Address For Industry',
        '155' => 'High Risk Bill Address For Industry',
        '156' => 'High Risk Service Location For Industry',
        '157' => 'High Risk Bill Address For Network',
        '158' => 'High Risk Customer ID For Network',
        '159' => 'High Risk Service Location For Network',
        '160' => 'Very High Risk Bill Address For Company',
        '161' => 'Very High Risk Customer ID For Company',
        '162' => 'Very High Risk Service Location For Company',
        '163' => 'Very High Risk Bill Address For Industry',
        '164' => 'Very High Risk Customer ID For Industry',
        '165' => 'Very High Risk Service Location For Industry',
        '166' => 'Very High Risk Bill Address For Network',
        '167' => 'Very High Risk Customer ID For Network',
        '168' => 'Very High Risk Service Location For Network'
    };
    
    
    public static Map<String, String> riskAdvicesMap = new Map<String, String> {
        '1' => 'Fraud Review',
        '2' => 'Unclear Risk',
        '3' => 'Lower Fraud Risk',
        '4' => 'Moderate Fraud Risk',
        '11' => 'Data Entry Review',
        '1001' => 'Custom Fraud Score Define'
    };
    
    
    public static Map<String, String> nameMatchesMap = new Map<String, String> {
        'Y' => 'Full Match',
        'P' => 'Partial Match',
        'N' => 'No Match',
        'U' => 'Owner Unknown'
    };
}