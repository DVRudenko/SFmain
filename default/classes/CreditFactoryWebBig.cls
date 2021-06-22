public with sharing class CreditFactoryWebBig {


    /*******************************************************************************
    *  Summary         : Generate HTTP Report Request to BIG
    *  CreatedDate     : 09/01/2020
    *  Parameters      : endpoint - BIG endpoint, userName - BIG userName, password - BIG password,
                         clientId - BIG client Id, testDataMarker - identify test data or not,
                         companyName - company name, companyNip - company NIP, consentGrantDate - date of signing documents
    *  Returns         : BIG report request
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password, String clientId, 
                                                    Boolean testDataMarker, String companyName, String companyNip, String consentGrantDate) {
        String body = generateReportXML(userName, password, clientId, testDataMarker, companyName, companyNip, consentGrantDate);
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', 'http://api.big.pl/bigApi/v1/getReport');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');

        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call BIG report
    *  CreatedDate     : 09/01/2020
    *  Parameters      : userName - BIG userName, password - BIG password, clientId - BIG client Id,
                         testDataMarker - identify test data or not, companyName - company name,
                         companyNip - company NIP, consentGrantDate - date of signing documents
    *  Returns         : request body
    ******************************************************************************/
    public static String generateReportXML(String userName, String password, String clientId, Boolean testDataMarker, String companyName, String companyNip, String consentGrantDate) {
        String xmlbody =
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://api.big.pl/bigApi/v1/types">' +
                '<soapenv:Header>' +
                    '<typ:credentials>' +
                        '<user>' + userName + '</user>' +
                        '<password>' + password + '</password>' +
                    '</typ:credentials>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                    '<typ:getReportRequest>' +
                        '<requestId>kk004</requestId>' +
                        // <requestDateTime>2019-10-07T13:00:00</requestDateTime>
                        '<requestDateTime>' +  CreditFactoryUtilities.returnCurrentDate() + '</requestDateTime>' +
                        '<protocol>bimo v1</protocol>' +
                        '<testDataMarker>' + testDataMarker + '</testDataMarker>' +
                        '<data><![CDATA[' +
                            '<?xml version="1.0" encoding="UTF-8"?>' +
                            '<br:getReportRequest xmlns:bc="http://api.big.pl/bimo/v1" xmlns:br="http://api.big.pl/bimoR/v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.big.pl/bimoR/v1 bimoR.v1.xsd ">' +
                                '<client>' +
                                    '<clientId>' + clientId + '</clientId>' +
                                    '<unitId>' + clientId + '</unitId>' +
                                '</client>' +
                                '<repeatedRequestMarker>false</repeatedRequestMarker>' +
                                '<reportComposition xsi:type="br:FinancialReportComposition">' +
                                    '<product>entrepreneurPlus</product>' +
                                    '<components select="custom">' +
                                        '<liabilitiesSummaries>' +
                                            '<summaryRequest>' +
                                                '<liabilitiesSource>bigIm</liabilitiesSource>' +
                                                '<liabilitiesType>fulfilled overdue</liabilitiesType>' +
                                                '<debtorLegalForm>legalPerson</debtorLegalForm>' +
                                            '</summaryRequest>' +
                                        '</liabilitiesSummaries>' +
                                        '<imEntrepreneurInquiries></imEntrepreneurInquiries>' +
                                        '<imEntrepreneurFulfilledLiabilities>' +
                                            '<containRestricted>false</containRestricted>' +
                                            '<searchByPesel>false</searchByPesel>' +
                                        '</imEntrepreneurFulfilledLiabilities>' +
                                        '<imEntrepreneurOverdueLiabilities>' +
                                            '<containRestricted>false</containRestricted>' +
                                            '<searchByPesel>false</searchByPesel>' +
                                        '</imEntrepreneurOverdueLiabilities>' +
                                        '<bikEntrepreneurOverdueLiabilities></bikEntrepreneurOverdueLiabilities>' +
                                        '<zbpUnreliableEntrepreneursByNip></zbpUnreliableEntrepreneursByNip>' +
                                    '</components>' +
                                    '<reportSubject xsi:type="bc:LegalPerson">' +
                                        '<fullName>' + companyName + '</fullName>' +
                                        '<nip>' + companyNip + '</nip>' +
                                    '</reportSubject>' +
                                    '<consentList>' +
                                        '<consent grantDate="' + consentGrantDate + '">entrepreneurZbpAuthorisation</consent>' +
                                        '<consent grantDate="' + consentGrantDate + '">bigImInquiriesAuthorisation</consent>' +
                                        '<consent grantDate="' + consentGrantDate + '">entrepreneurBikAuthorisation</consent>' +
                                    '</consentList>' +
                                '</reportComposition>' +
                            '</br:getReportRequest>' +
                        ']]></data>' +
                    '</typ:getReportRequest>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        return xmlbody;
    }

    /*******************************************************************************
    *  Summary         : Remove CDATA characters
    *  CreatedDate     : 09/01/2020
    *  Parameters      : xml - response body xml
    *  Returns         : report xml
    ******************************************************************************/
    public static String clearReportXml(String xml) {
        Pattern p = Pattern.compile('<!\\[CDATA\\[(.*?)\\]\\]>');
        Matcher m = p.matcher(xml);
        while (m.find()) {
            xml = xml.replace(m.group(), m.group(1));
        }

        return xml;
    }

    /*******************************************************************************
    *  Summary         : Return Credit Company with fields from BIG
    *  CreatedDate     : 09/01/2020
    *  Parameters      : xmlDom - xml Dom from response,
                         xmlDom - report dom xml 
    *  Returns         : overdue xml node
    ******************************************************************************/
    public static Dom.XmlNode returnOverdueNode(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode envelopeField : xmlDom.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'getReportResponse') {
                        for (Dom.XmlNode reportResponseField : bodyField.getChildElements()) {
                            if (reportResponseField.getName() == 'data') {
                                Dom.Document domDoc = new Dom.Document();
                                domDoc.load(reportResponseField.getText());
                                Dom.XmlNode xmldom2 = domDoc.getRootElement();
                                for (Dom.XmlNode dataField : xmldom2.getChildElements()) {
                                    if (dataField.getName() == 'success') {
                                        for (Dom.XmlNode successField : dataField.getChildElements()) {
                                            if (successField.getName() == 'components') {
                                                for (Dom.XmlNode componentsField : successField.getChildElements()) {
                                                    if (componentsField.getName() == 'reportComponent') {
                                                        for (Dom.XmlNode reportComponentField : componentsField.getChildElements()) {
                                                            if (reportComponentField.getName() == 'data') {
                                                                for (Dom.XmlNode data2Field : reportComponentField.getChildElements()) {
                                                                    if (data2Field.getName() == 'overdueLiabilitiesSummary') {
                                                                        return data2Field;
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
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return report company with BIG fields
    *  CreatedDate     : 09/01/2020
    *  Parameters      : xmlDom - xml Dom from response, 
                         CreditCompany - current company
    *  Returns         : credit factory company
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(Dom.XmlNode xmlDom, CreditFactoryCompany company) {
        company.creditorsCount = returnCreditorsCount(xmlDom);
        company.economicInformationsCount = returnEconomicInformationsCount(xmlDom);
        company.liabilitiesCount = returnLiabilitiesCount(xmlDom);
        company.totalAmount = returnTotalAmount(xmlDom);
        company.totalOverdueAmount = returnTotalOverdueAmount(xmlDom);
        company.bigRequested = true;
        return company;
    }


    /*******************************************************************************
    *  Summary         : Return Creditors Count field
    *  CreatedDate     : 09/01/2020
    *  Parameters      : xmlDom - xml dom from response
    *  Returns         : Creditors Count
    ******************************************************************************/
    public static Decimal returnCreditorsCount(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode overdueLiabilitiesSummaryField : xmlDom.getChildElements()) {
            if (overdueLiabilitiesSummaryField.getName() == 'creditorsCount' && overdueLiabilitiesSummaryField.getText() != null) {
                return Decimal.valueOf(overdueLiabilitiesSummaryField.getText());
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Economic Informations Count field
    *  CreatedDate     : 09/01/2020
    *  Parameters      : xmlDom - xml dom from response
    *  Returns         : Economic Informations Count
    ******************************************************************************/
    public static Decimal returnEconomicInformationsCount(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode overdueLiabilitiesSummaryField : xmlDom.getChildElements()) {
            if (overdueLiabilitiesSummaryField.getName() == 'economicInformationsCount' && overdueLiabilitiesSummaryField.getText() != null) {
                return Decimal.valueOf(overdueLiabilitiesSummaryField.getText());
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Liabilities Count field
    *  CreatedDate     : 09/01/2020
    *  Parameters      : xmlDom - xml Dom from response
    *  Returns         : Liabilities Count
    ******************************************************************************/
    public static Decimal returnLiabilitiesCount(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode overdueLiabilitiesSummaryField : xmlDom.getChildElements()) {
            if (overdueLiabilitiesSummaryField.getName() == 'liabilitiesCount' && overdueLiabilitiesSummaryField.getText() != null) {
                return Decimal.valueOf(overdueLiabilitiesSummaryField.getText());
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Total Amount field
    *  CreatedDate     : 09/01/2020
    *  Parameters      : xmlDom - xml Dom from response
    *  Returns         : Total Amount
    ******************************************************************************/
    public static Decimal returnTotalAmount(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode overdueLiabilitiesSummaryField : xmlDom.getChildElements()) {
            if (overdueLiabilitiesSummaryField.getName() == 'totalAmount' && overdueLiabilitiesSummaryField.getText() != null) {
                return Decimal.valueOf(overdueLiabilitiesSummaryField.getText());
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Total Overdue Amount field
    *  CreatedDate     : 09/01/2020
    *  Parameters      : xmlDom - xml Dom from response
    *  Returns         : Total Overdue Amount
    ******************************************************************************/
    public static Decimal returnTotalOverdueAmount(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode overdueLiabilitiesSummaryField : xmlDom.getChildElements()) {
            if (overdueLiabilitiesSummaryField.getName() == 'totalOverdueAmount' && overdueLiabilitiesSummaryField.getText() != null) {
                return Decimal.valueOf(overdueLiabilitiesSummaryField.getText());
            }
        }

        return null;
    }
}