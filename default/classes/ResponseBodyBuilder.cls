public class ResponseBodyBuilder {

    /*******************************************************************************
    *  Name            : constructPPR_API_responseBody(String inn, String source)
    *  Summary         : builds response body for PPR API by INN and source (method with DB operations)
    *  CreatedDate     : 11/02/2020
    *  ModifiedDate    : -
    *  Parameters      : String inn, String source
    *  Returns         : PPR_API_ResponseBody
    ******************************************************************************/
    public static PPR_API_ResponseBody constructPPR_API_responseBody(String inn, String source) {
        String dateFormat = 'dd.MM.yyyy';
        E2EFormRuDao formRuDao = new E2EFormRuDaoImpl();
        Custom_log__c log = PPR_API_LogService.getLogByInnAndSource(inn, source);
        PPR_API_ResponseBody responseBody = new PPR_API_ResponseBody();
        if (log != null) {
            responseBody.metadata = new PPR_API_ResponseBody.Metadata();
            responseBody.customerInfo = new PPR_API_ResponseBody.CustomerInfo();
            responseBody.metadata.user = log.External_user__c;
            responseBody.message = log.Errors__c;
            responseBody.customerInfo.inn = log.INN__c;

            E2EFormData__c formData = formRuDao.getFormDataById(log.E2E_Form_Ru_Data__c);
            if (formData != null) {
                responseBody.metadata.id = formData.Id;
                responseBody.customerInfo.customerStatus = formData.E2E_Process_Status__c;
                responseBody.customerInfo.customerStatusId = (String) PPR_Mapping_Utils.customerStatusMap.get(formData.E2E_Process_Status__c);
                responseBody.customerInfo.checkDate = formData.Last_deduplication_time__c == null ? null : formData.Last_deduplication_time__c.format(dateFormat);
                responseBody.customerInfo.ogrn = formData.E2E_OGRN__c;
                responseBody.customerInfo.contractNum = formData.E2E_Contract_Number__c;

                Opportunity opportunity = getOpportunity(formData.E2E_Opportunity_Id__c);
                if (opportunity != null) {
                    responseBody.customerInfo.contractDate = opportunity.Agreement_Date__c == null ? null :
                            Datetime.newInstance(
                                    opportunity.Agreement_Date__c.year(),
                                    opportunity.Agreement_Date__c.month(),
                                    opportunity.Agreement_Date__c.day()
                            ).format(dateFormat);
                    if (opportunity.StageName.equals(GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.MovedToStart))
                            && opportunity.CloseDate != null) {
                        responseBody.customerInfo.invoicePaymentDate =
                                Datetime.newInstance(
                                        opportunity.CloseDate.year(),
                                        opportunity.CloseDate.month(),
                                        opportunity.CloseDate.day()
                                ).format(dateFormat);
                    }
                }
            }
        } else {
            responseBody.message = 'Internal server error. Response source is empty';
        }
        return responseBody;
    }

    /*******************************************************************************
    *  Name            : constructPPR_API_responseBody(String inn, String source)
    *  Summary         : builds response body for PPR API by INN and source with short body (method with DB operations)
    *  CreatedDate     : 11/02/2020
    *  ModifiedDate    : -
    *  Parameters      : String inn, String source
    *  Returns         : PPR_API_ResponseBody
    ******************************************************************************/
    public static PPR_API_ResponseBody constructPPR_API_responseBodyShort(String inn, String source) {
        String dateFormat = 'dd.MM.yyyy';
        E2EFormRuDao formRuDao = new E2EFormRuDaoImpl();
        Custom_log__c log = PPR_API_LogService.getLogByInnAndSource(inn, source);
        PPR_API_ResponseBody responseBody = new PPR_API_ResponseBody();
        if (log != null) {
            responseBody.metadata = new PPR_API_ResponseBody.Metadata();
            responseBody.customerInfo = new PPR_API_ResponseBody.CustomerInfo();
            responseBody.metadata.user = log.External_user__c;
            responseBody.message = log.Errors__c;
            responseBody.customerInfo.inn = log.INN__c;

            E2EFormData__c formData = formRuDao.getFormDataById(log.E2E_Form_Ru_Data__c);
            if (formData != null) {
                responseBody.metadata.id = formData.Id;
                responseBody.customerInfo.customerStatus = formData.E2E_Process_Status__c;
                responseBody.customerInfo.customerStatusId = (String) PPR_Mapping_Utils.customerStatusMap.get(formData.E2E_Process_Status__c);
                responseBody.customerInfo.checkDate = formData.Last_deduplication_time__c == null ? null : formData.Last_deduplication_time__c.format(dateFormat);
            }
        } else {
            responseBody.message = 'Internal server error. Response source is empty';
        }
        return responseBody;
    }

    /*******************************************************************************
    *  Name            : constructPPR_API_responseBody(E2EFormParams formParams)
    *  Summary         : builds response body for PPR API with short body (method without DB operations)
    *  CreatedDate     : 11/02/2020
    *  ModifiedDate    : -
    *  Parameters      : E2EFormParams formParams
    *  Returns         : PPR_API_ResponseBody
    ******************************************************************************/
    public static PPR_API_ResponseBody constructPPR_API_responseBody(E2EFormParams formParams) {
        String dateFormat = 'dd.MM.yyyy';
        PPR_API_ResponseBody responseBody = new PPR_API_ResponseBody();
        if (formParams != null) {
            responseBody.metadata = new PPR_API_ResponseBody.Metadata();
            responseBody.customerInfo = new PPR_API_ResponseBody.CustomerInfo();
            responseBody.metadata.id = formParams.formDataId;
            responseBody.metadata.user = formParams.externalUser;
            responseBody.customerInfo.customerStatus = formParams.processStatus;
            responseBody.customerInfo.customerStatusId = (String) PPR_Mapping_Utils.customerStatusMap.get(formParams.processStatus);
            responseBody.customerInfo.inn = formParams.companyInn;
            responseBody.message = formParams.errors;
            responseBody.customerInfo.checkDate = formParams.deduplicationDatetime == null ? null : formParams.deduplicationDatetime.format(dateFormat);
        } else {
            responseBody.message = 'Internal server error. Response source is empty';
        }
        return responseBody;
    }

    private static Opportunity getOpportunity(Id opportunityId) {
        List<Opportunity> opportunities = ([
                SELECT Id, Agreement_Date__c, CloseDate, StageName
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
        ]);
        return opportunities.size() == 1 ? opportunities.get(0) : null;
    }

    /*******************************************************************************
    *  Name            : constructPPR_API_responseBody(Exception e)
    *  Summary         : builds response body for PPR API with exception
    *  CreatedDate     : 11/02/2020
    *  ModifiedDate    : -
    *  Parameters      : Exception e
    *  Returns         : PPR_API_ResponseBody
    ******************************************************************************/
    public static PPR_API_ResponseBody constructPPR_API_ResponseBodyException(Exception e) {
        PPR_API_ResponseBody responseBody = new PPR_API_ResponseBody();
        responseBody.message = e == null ? 'Internal server error. Response source is empty' : e.getMessage();
        return responseBody;
    }


    /*******************************************************************************
    *  Name            : constructPPR_API_responseBody()
    *  Summary         : builds response body for PPR API with error message
    *  CreatedDate     : 11/02/2020
    *  ModifiedDate    : -
    *  Parameters      : String error
    *  Returns         : PPR_API_ResponseBody
    ******************************************************************************/
    public static PPR_API_ResponseBody constructPPR_API_ResponseBodyError(String error) {
        PPR_API_ResponseBody responseBody = new PPR_API_ResponseBody();
        responseBody.message = error == null ? 'Internal server error. Response source is empty' : error;
        return responseBody;
    }

}