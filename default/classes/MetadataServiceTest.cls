@isTest  
public class MetadataServiceTest {    
	public class WebServiceMockImpl implements WebServiceMock {
		public void doInvoke(Object stub, Object request, Map<String, Object> response,
			                 String endpoint, String soapAction, String requestName,
			                 String responseNS, String responseName, String responseType) {
			if(request instanceof MetadataService.readMetadata_element) {
                MetadataService.readStandardValueSetTranslationResponse_element readMetadataResponse = new MetadataService.readStandardValueSetTranslationResponse_element();
                readMetadataResponse.result = new MetadataService.ReadStandardValueSetTranslationResult();
                readMetadataResponse.result.records = new List <MetadataService.StandardValueSetTranslation> ();
                MetadataService.StandardValueSetTranslation translationData = new MetadataService.StandardValueSetTranslation ();
                translationData.fullName = 'LeadStatus-ru';
                MetadataService.ValueTranslation[] translations = new List <MetadataService.ValueTranslation> ();
                MetadataService.ValueTranslation transl1 = new MetadataService.ValueTranslation ();
                transl1.masterLabel = 'Status1';
                transl1.translation = 'Статус1';
                MetadataService.ValueTranslation transl2 = new MetadataService.ValueTranslation ();
                transl2.masterLabel = 'Status2';
                transl2.translation = 'Статус2';
                translations.add(transl1);
                translations.add(transl2);
                translationData.valueTranslation = translations;
                readMetadataResponse.result.records.add(translationData);
                response.put('response_x', readMetadataResponse);
            }
        /*** not used for now **
			else if(request instanceof MetadataService.retrieve_element)
                response.put('response_x', new MetadataService.retrieveResponse_element());
            else if(request instanceof MetadataService.checkDeployStatus_element)
                response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
            else if(request instanceof MetadataService.listMetadata_element)
                response.put('response_x', new MetadataService.listMetadataResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            else if(request instanceof MetadataService.describeMetadata_element)
                response.put('response_x', new MetadataService.describeMetadataResponse_element());
            else if(request instanceof MetadataService.deploy_element)
                response.put('response_x', new MetadataService.deployResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof MetadataService.renameMetadata_element)
                response.put('response_x', new MetadataService.renameMetadataResponse_element());
            else if(request instanceof  MetadataService.cancelDeploy_element)
                response.put('response_x', new MetadataService.cancelDeployResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof  MetadataService.deployRecentValidation_element)
                response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof MetadataService.describeValueType_element)
                response.put('response_x', new MetadataService.describeValueTypeResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
        */
        }
    }    

    @IsTest
    private static void testReadMetadata() {       
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.startTest();
        Map <String, String> leadStatusesTransl = MetadataServiceConnector.getStandardPicklistTranslations ('LeadStatus-ru');
        system.assert(!leadStatusesTransl.isEmpty());                            
        Test.stopTest();
    }
    @IsTest
    private static void coverGeneratedCodeTypes() {   
        Test.startTest();
        new MetadataService.CallOptions_element();
        new MetadataService.SessionHeader_element();
        new MetadataService.AllOrNoneHeader_element();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.DebuggingInfo_element();
        new MetadataService.LogInfo();
        new MetadataService.readMetadataResponse_element();
        new MetadataService.ReadResult();
        Test.stopTest();
    }
}