@IsTest
public with sharing class ResponseBodyBuilderTest {

    private static final String SOURCE = 'EP';
    private static final String INN = '1234567890';

    @IsTest
    private static void testConstructPPR_API_responseBody1() {
        Opportunity opportunity = E2EFormRuTestUtils.createDefaultOpportunity();
        opportunity.Agreement_Date__c = Date.today();
        opportunity.Source_PP__c = SOURCE;
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.MovedToStart);
        opportunity.CloseDate = Date.today();
        insert opportunity;
        E2EFormData__c formData = new E2EFormData__c(
                E2E_Opportunity_Id__c = opportunity.Id,
                E2E_OGRN__c = '55553535',
                E2E_Source__c = SOURCE,
                E2E_INN__c = INN,
                E2E_Process_Status__c = 'Processing',
                E2E_Contract_Number__c = '4-1234',
                Last_deduplication_time__c = Datetime.now()
        );
        insert formData;
        Custom_log__c log = new Custom_log__c(
                E2E_Form_Ru_Data__c = formData.Id,
                External_user__c = 'user',
                Errors__c = 'message',
                INN__c = INN,
                Source__c = SOURCE
        );
        insert log;

        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_responseBody(INN, SOURCE);

        System.assertEquals(formData.Id, responseBody.metadata.id);
        System.assertEquals(log.External_user__c, responseBody.metadata.user);
        System.assertEquals(log.INN__c, responseBody.customerInfo.inn);
        String contractDate = Datetime.newInstance(
                opportunity.Agreement_Date__c.year(),
                opportunity.Agreement_Date__c.month(),
                opportunity.Agreement_Date__c.day()
        ).format('dd.MM.yyyy');
        System.assertEquals(contractDate, responseBody.customerInfo.contractDate);
        System.assertEquals(formData.E2E_Contract_Number__c, responseBody.customerInfo.contractNum);
        System.assertEquals(formData.E2E_OGRN__c, responseBody.customerInfo.ogrn);
        System.assertEquals(formData.E2E_Process_Status__c, responseBody.customerInfo.customerStatus);
        System.assertEquals(PPR_Mapping_Utils.customerStatusMap.get(formData.E2E_Process_Status__c), responseBody.customerInfo.customerStatusId);
        System.assertEquals(formData.Last_deduplication_time__c.format('dd.MM.yyyy'), responseBody.customerInfo.checkDate);
        System.assertEquals(log.Errors__c, responseBody.message);
        String closeDate = Datetime.newInstance(
                opportunity.CloseDate.year(),
                opportunity.CloseDate.month(),
                opportunity.CloseDate.day()
        ).format('dd.MM.yyyy');
        System.assertEquals(closeDate, responseBody.customerInfo.invoicePaymentDate);
    }

    @IsTest
    private static void testConstructPPR_API_responseBody1NoOpportunity() {
        E2EFormData__c formData = new E2EFormData__c(
                E2E_OGRN__c = '55553535',
                E2E_Source__c = SOURCE,
                E2E_INN__c = INN,
                E2E_Process_Status__c = 'Processing',
                E2E_Contract_Number__c = '4-1234',
                Last_deduplication_time__c = Datetime.now()
        );
        insert formData;
        Custom_log__c log = new Custom_log__c(
                E2E_Form_Ru_Data__c = formData.Id,
                External_user__c = 'user',
                Errors__c = 'message',
                INN__c = INN,
                Source__c = SOURCE
        );
        insert log;

        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_responseBody(INN, SOURCE);

        System.assertEquals(formData.Id, responseBody.metadata.id);
        System.assertEquals(log.External_user__c, responseBody.metadata.user);
        System.assertEquals(log.INN__c, responseBody.customerInfo.inn);
        System.assertEquals(null, responseBody.customerInfo.contractDate);
        System.assertEquals(null, responseBody.customerInfo.invoicePaymentDate);
        System.assertEquals(formData.E2E_Contract_Number__c, responseBody.customerInfo.contractNum);
        System.assertEquals(formData.E2E_OGRN__c, responseBody.customerInfo.ogrn);
        System.assertEquals(formData.E2E_Process_Status__c, responseBody.customerInfo.customerStatus);
        System.assertEquals(PPR_Mapping_Utils.customerStatusMap.get(formData.E2E_Process_Status__c), responseBody.customerInfo.customerStatusId);
        System.assertEquals(formData.Last_deduplication_time__c.format('dd.MM.yyyy'), responseBody.customerInfo.checkDate);
        System.assertEquals(log.Errors__c, responseBody.message);
    }

    @IsTest
    private static void testConstructPPR_API_responseBody1OpportunityNotMovedToStart() {
        Opportunity opportunity = E2EFormRuTestUtils.createDefaultOpportunity();
        opportunity.Agreement_Date__c = Date.today();
        opportunity.Source_PP__c = SOURCE;
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AwaitingPayment);
        opportunity.CloseDate = Date.today();
        insert opportunity;
        E2EFormData__c formData = new E2EFormData__c(
                E2E_Opportunity_Id__c = opportunity.Id,
                E2E_OGRN__c = '55553535',
                E2E_Source__c = SOURCE,
                E2E_INN__c = INN,
                E2E_Process_Status__c = 'Processing',
                E2E_Contract_Number__c = '4-1234',
                Last_deduplication_time__c = Datetime.now()
        );
        insert formData;
        Custom_log__c log = new Custom_log__c(
                E2E_Form_Ru_Data__c = formData.Id,
                External_user__c = 'user',
                Errors__c = 'message',
                INN__c = INN,
                Source__c = SOURCE
        );
        insert log;

        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_responseBody(INN, SOURCE);

        System.assertEquals(formData.Id, responseBody.metadata.id);
        System.assertEquals(log.External_user__c, responseBody.metadata.user);
        System.assertEquals(log.INN__c, responseBody.customerInfo.inn);
        String contractDate = Datetime.newInstance(
                opportunity.Agreement_Date__c.year(),
                opportunity.Agreement_Date__c.month(),
                opportunity.Agreement_Date__c.day()
        ).format('dd.MM.yyyy');
        System.assertEquals(contractDate, responseBody.customerInfo.contractDate);
        System.assertEquals(formData.E2E_Contract_Number__c, responseBody.customerInfo.contractNum);
        System.assertEquals(formData.E2E_OGRN__c, responseBody.customerInfo.ogrn);
        System.assertEquals(formData.E2E_Process_Status__c, responseBody.customerInfo.customerStatus);
        System.assertEquals(PPR_Mapping_Utils.customerStatusMap.get(formData.E2E_Process_Status__c), responseBody.customerInfo.customerStatusId);
        System.assertEquals(formData.Last_deduplication_time__c.format('dd.MM.yyyy'), responseBody.customerInfo.checkDate);
        System.assertEquals(log.Errors__c, responseBody.message);
        System.assertEquals(null, responseBody.customerInfo.invoicePaymentDate);
    }

    @IsTest
    private static void testConstructPPR_API_responseBody1EmptySource() {

        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_responseBody(INN, SOURCE);

        System.assertEquals('Internal server error. Response source is empty', responseBody.message);
    }

    @IsTest
    private static void testConstructPPR_API_responseBody2() {
        E2EFormParams formParams = new E2EFormParams();
        formParams.companyInn = INN;
        formParams.externalUser = 'user';
        formParams.source = SOURCE;
        formParams.processStatus = 'New';
        formParams.errors = 'message';
        formParams.deduplicationDatetime = Datetime.now();

        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_responseBody(formParams);

        System.assertEquals(formParams.companyInn, responseBody.customerInfo.inn);
        System.assertEquals(formParams.externalUser, responseBody.metadata.user);
        System.assertEquals(formParams.processStatus, responseBody.customerInfo.customerStatus);
        System.assertEquals(PPR_Mapping_Utils.customerStatusMap.get(formParams.processStatus), responseBody.customerInfo.customerStatusId);
        System.assertEquals(formParams.errors, responseBody.message);
        System.assertEquals(formParams.deduplicationDatetime.format('dd.MM.yyyy'), responseBody.customerInfo.checkDate);
        System.assertEquals(null, responseBody.customerInfo.ogrn);
        System.assertEquals(null, responseBody.customerInfo.contractNum);
    }

    @IsTest
    private static void testConstructPPR_API_responseBody2EmptySource() {
        E2EFormParams formParams = null;

        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_responseBody(formParams);

        System.assertEquals('Internal server error. Response source is empty', responseBody.message);
    }

    @IsTest
    private static void testConstructPPR_API_ResponseBodyException() {
        GlobalException globalException = new GlobalException('exception');
        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_ResponseBodyException(globalException);

        System.assertEquals('exception', responseBody.message);
    }

    @IsTest
    private static void testConstructPPR_API_ResponseBodyError() {
        String message = 'PPR API is disabled';
        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_ResponseBodyError(message);

        System.assertEquals(message, responseBody.message);
    }

    @IsTest
    private static void testConstructPPR_API_responseBodyShort() {
        E2EFormData__c formData = new E2EFormData__c(
                E2E_OGRN__c = '55553535',
                E2E_Source__c = SOURCE,
                E2E_INN__c = INN,
                E2E_Process_Status__c = 'Processing',
                E2E_Contract_Number__c = '4-1234',
                Last_deduplication_time__c = Datetime.now()
        );
        insert formData;
        Custom_log__c log = new Custom_log__c(
                E2E_Form_Ru_Data__c = formData.Id,
                External_user__c = 'user',
                Errors__c = 'message',
                INN__c = INN,
                Source__c = SOURCE
        );
        insert log;

        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_responseBodyShort(INN, SOURCE);

        System.assertEquals(formData.Id, responseBody.metadata.id);
        System.assertEquals(log.External_user__c, responseBody.metadata.user);
        System.assertEquals(log.INN__c, responseBody.customerInfo.inn);
        System.assertEquals(null, responseBody.customerInfo.contractDate);
        System.assertEquals(null, responseBody.customerInfo.invoicePaymentDate);
        System.assertEquals(null, responseBody.customerInfo.contractNum);
        System.assertEquals(null, responseBody.customerInfo.ogrn);
        System.assertEquals(formData.E2E_Process_Status__c, responseBody.customerInfo.customerStatus);
        System.assertEquals(PPR_Mapping_Utils.customerStatusMap.get(formData.E2E_Process_Status__c), responseBody.customerInfo.customerStatusId);
        System.assertEquals(formData.Last_deduplication_time__c.format('dd.MM.yyyy'), responseBody.customerInfo.checkDate);
        System.assertEquals(log.Errors__c, responseBody.message);
    }

    @IsTest
    private static void testConstructPPR_API_responseBodyShortEmptySource() {

        PPR_API_ResponseBody responseBody = ResponseBodyBuilder.constructPPR_API_responseBodyShort(INN, SOURCE);

        System.assertEquals('Internal server error. Response source is empty', responseBody.message);
    }

}