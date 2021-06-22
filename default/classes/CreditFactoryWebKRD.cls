public class CreditFactoryWebKRD {


    /*******************************************************************************
    *  Summary         : Generate HTTP Report Request to KRD
    *  CreatedDate     : 05/08/2020 by Anton Buzak
    *  Parameters      : endpoint - KRD endpoint, userName - KRD userName, password - KRD password,
                         taxId - company tax id
    *  Returns         : KRD report request
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password, String taxId) {
        String body = generateReportXML(userName, password, taxId);
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', 'http://krd.pl/Chase3.1/ISearch/SearchNonConsumer');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');

        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call BIG report
    *  CreatedDate     : 05/08/2020 by Anton Buzak
    *  Parameters      : userName - KRD userName, password - KRD password,
                         taxId - company tax id
    *  Returns         : KRD report request
    ******************************************************************************/
    public static String generateReportXML(String userName, String password, String taxId) {
        String xmlbody =
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:aut="http://krd.pl/Authorization" xmlns:dto="http://krd.pl/Chase3.1/Dto">' +
                '<soapenv:Header>' +
                    '<aut:Authorization>' +
                        '<aut:AuthorizationType>LoginAndPassword</aut:AuthorizationType>' +
                        '<aut:Login>' + userName + '</aut:Login>' +
                        '<aut:Password>' + password + '</aut:Password>' +
                    '</aut:Authorization>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                    '<dto:SearchNonConsumerRequest>' +
                        '<dto:Number>' + taxId + '</dto:Number>' +
                        '<dto:NumberType>TaxId</dto:NumberType>' +
                    '</dto:SearchNonConsumerRequest>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Summary         : Return xml node Disclosure Report Node
    *  CreatedDate     : 05/08/2020 by Anton Buzak
    *  Parameters      : xmlDom - xml Dom from response,
    *  Returns         : Disclosure Report Node
    ******************************************************************************/
    public static Dom.XmlNode returnDisclosureReportNode(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode envelopeNode : xmlDom.getChildElements()) {
            if (envelopeNode.getName() == 'Body') {
                for (Dom.XmlNode bodyNode : envelopeNode.getChildElements()) {
                    if (bodyNode.getName() == 'InformationDisclosureResponse') {
                        for (Dom.XmlNode informationDisclosureResponseNode : bodyNode.getChildElements()) {
                            if (informationDisclosureResponseNode.getName() == 'DisclosureReport') {
                                for (Dom.XmlNode disclosureReportNode : informationDisclosureResponseNode.getChildElements()) {
                                    if (disclosureReportNode.getName() == 'Report') {
                                        return disclosureReportNode;
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
    *  Summary         : Return report company with KRD fields
    *  CreatedDate     : 05/08/2020 by Anton Buzak
    *  Parameters      : reportNode - report node response,
                         CreditCompany - current company
    *  Returns         : credit factory company
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(Dom.XmlNode reportNode, CreditFactoryCompany company) {
        if (company.obligationOverdue == false) {
            company.obligationOverdue = returnObligationOverdueResult(reportNode);
        }

        company.paymentHistoryRequested = true;

        return company;
    }


    /*******************************************************************************
    *  Summary         : Return obligation overdue result (true/false)
    *  CreatedDate     : 05/08/2020 by Anton Buzak
    *  Parameters      : reportNode - report node response
    *  Returns         : obligation overdue result
    ******************************************************************************/
    private static Boolean returnObligationOverdueResult(Dom.XmlNode disclosureReportNodeToReturn) {
        for (Dom.XmlNode reportNode : disclosureReportNodeToReturn.getChildElements()) {
            if (reportNode.getName() == 'ObligationInformations') {
                for (Dom.XmlNode obligationInformationsNode : reportNode.getChildElements()) {
                    if (obligationInformationsNode.getName() == 'ObligationInformation') {
                        for (Dom.XmlNode obligationInformationNode : obligationInformationsNode.getChildElements()) {
                            if (obligationInformationNode.getName() == 'Arrears') {
                                for (Dom.XmlNode arrearsNode : obligationInformationNode.getChildElements()) {
                                    if (arrearsNode.getName() == 'Amount') {
                                        Decimal arrearsAmount;
                                        if (arrearsNode.getText() != null) {
                                            arrearsAmount = Decimal.valueOf(arrearsNode.getText());
                                        }

                                        if (arrearsAmount > 100) {
                                            return true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else if (reportNode.getName() == 'PaidObligationInformations') {
                for (Dom.XmlNode paidObligationInformationsNode : reportNode.getChildElements()) {
                    if (paidObligationInformationsNode.getName() == 'PaidObligationInformation') {
                        for (Dom.XmlNode paidObligationInformationNode : paidObligationInformationsNode.getChildElements()) {
                            if (paidObligationInformationNode.getName() == 'PaidObligationsForSubjects') {
                                for (Dom.XmlNode paidObligationsForSubjectsNode : paidObligationInformationNode.getChildElements()) {
                                    if (paidObligationsForSubjectsNode.getName() == 'PaidObligationsForSubject') {
                                        for (Dom.XmlNode paidObligationsForSubjectNode : paidObligationsForSubjectsNode.getChildElements()) {
                                            if (paidObligationsForSubjectNode.getName() == 'PaidObligations') {
                                                for (Dom.XmlNode paidObligationsNode : paidObligationsForSubjectNode.getChildElements()) {
                                                    if (paidObligationsNode.getName() == 'PaidObligation') {
                                                        Decimal paidDebt;
                                                        Date dueDate;
                                                        Date paidDate;
                                                        for (Dom.XmlNode paidObligationNode : paidObligationsNode.getChildElements()) {
                                                            if (paidObligationNode.getName() == 'PaidDebt') {
                                                                if (paidObligationNode.getText() != null) {
                                                                    paidDebt = Decimal.valueOf(paidObligationNode.getText());
                                                                }
                                                            }
                                                            else if (paidObligationNode.getName() == 'DueDate') {
                                                                if (paidObligationNode.getText() != null) {
                                                                    dueDate = Date.newInstance(Integer.valueOf(paidObligationNode.getText().substring(0, 4)), Integer.valueOf(paidObligationNode.getText().substring(5, 7)), Integer.valueOf(paidObligationNode.getText().substring(8, 10)));
                                                                }
                                                            }
                                                            else if (paidObligationNode.getName() == 'PaidDate') {
                                                                if (paidObligationNode.getText() != null) {
                                                                    paidDate = Date.newInstance(Integer.valueOf(paidObligationNode.getText().substring(0, 4)), Integer.valueOf(paidObligationNode.getText().substring(5, 7)), Integer.valueOf(paidObligationNode.getText().substring(8, 10)));
                                                                }
                                                            }
                                                        }

                                                        if (paidDebt > 100 && paidDate > dueDate.addDays(7)) {
                                                            return true;
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

        return false;
    }
}