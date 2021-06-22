public without sharing class ETEPDFViewCtrl {

    /********************************************************
     * 
     * Class: StepDocumentsContractPL
     * Step: Documents 
     * Target: ete_step_documents_tabel_price
     * Description: Contract and deposit agreement view 
     *
     ********************************************************/
    private class StepDocumentsTabelPricePL extends BaseDocument{

        private override Boolean useMargin(){
            return false;
        } 

        private override String changeContentWithObjects(
            Map<String, Object> params,
            E2E_Data_Object__c dataObject,
            Opportunity opp,
            Account acc,
            String content
        ){
            Map<String, List<String>> productAvailableByType = new Map<String, List<String>>{
                'fuel' => new List<String>{'Lotos Fuel Card', 'Shell Fuel Card'},
                'carnet' => new List<String>{'Carnet OBD'},
                'ev' => new List<String>{'EV Fob'}
            };
            String productType = String.valueOf(params.get('productType'));
            List<String> productFamilies;
            if(!String.isEmpty(productType)){
                productFamilies = productAvailableByType.get(productType);
            }
            List<E2E_Data_Offer_Item__c> items;
            if(productFamilies == null){
                items = [
                    SELECT Offer_Item_Type_Name__c, Offer_Name__c 
                    FROM E2E_Data_Offer_Item__c 
                    WHERE E2E_Data_Object__c = :dataObject.Id
                ];
            }else{
                items = [
                    SELECT Offer_Item_Type_Name__c, Offer_Name__c 
                    FROM E2E_Data_Offer_Item__c 
                    WHERE E2E_Data_Object__c = :dataObject.Id
                    AND  Offer_Item_Type_Name__c IN : productFamilies
                ];
            }

            Boolean isShellCardExists = false;
            Boolean isCarnetWithContractExists = false;
            Boolean isCarnetWithoutContractExists = false;
            for(E2E_Data_Offer_Item__c item : items){
                if(item.Offer_Item_Type_Name__c == 'Shell Fuel Card'){
                    isShellCardExists = true;
                }
                if(item.Offer_Name__c == 'Carnet OBD 12 PL (with contract)'){
                    isCarnetWithContractExists = true;
                }

                if(item.Offer_Name__c == 'Carnet OBD 12 PL (no contract)'){
                    isCarnetWithoutContractExists = true;
                }
            }
            String result = '';
            if(isShellCardExists){
                result += this.getTemplateByName('shell_price', content);
            }
            if(isCarnetWithContractExists){
                result += this.getTemplateByName('carnet_price_with_contract', content);
            }
            if(isCarnetWithoutContractExists){
                result += this.getTemplateByName('carnet_price_without_contract', content);
            }
            return result;
        } 

    }

    /********************************************************
     * 
     * Class: StepDocumentsContractPL
     * Step: Documents 
     * Target: ete_step_documents_contract
     * Description: Contract and deposit agreement view 
     *
     ********************************************************/
    private class StepDocumentsContractPL extends BaseDocument{

        private override Map<String, Object> changeParamsWithObjects(
            Map<String, Object> params,
            E2E_Data_Object__c dataObject,
            Opportunity opp,
            Account acc
        ){
            String amount = this.getFormattedCurrency(dataObject.Security_Amount_To_Pay__c);
            params.put('amount', amount);
            return params;
        }

        private override String changeContentWithObjects(
            Map<String, Object> params,
            E2E_Data_Object__c dataObject,
            Opportunity opp,
            Account acc,
            String content
        ){
            List<E2E_Data_Offer_Item__c> items = [
                SELECT Offer_Item_Type_Name__c 
                FROM E2E_Data_Offer_Item__c 
                WHERE E2E_Data_Object__c = :dataObject.Id
            ];
            Boolean isShellCardExists = false;
            Boolean isCarnetExists = false;
            Boolean isDeposit = dataObject.Security_Amount_To_Pay__c > 0;
            for(E2E_Data_Offer_Item__c item : items){
                if(item.Offer_Item_Type_Name__c == 'Shell Fuel Card'){
                    isShellCardExists = true;
                }
                if(item.Offer_Item_Type_Name__c == 'Carnet OBD'){
                    isCarnetExists = true;
                }
            }
            String result = '';
            if(isShellCardExists){
                result += this.getTemplateByName('header_image', content);
                result += this.getTemplateByName('shell_contract', content);
            }
            if(isDeposit){
                if(result != ''){
                    result += this.getTemplateByName('page_break', content);
                }
                result += this.getTemplateByName('header_image', content);
                result += this.getTemplateByName('shell_deposit', content);
            }
            if(isCarnetExists){
                if(result != ''){
                    result += this.getTemplateByName('page_break', content);
                }
                result += this.getTemplateByName('header_image_carnet', content);
                result += this.getTemplateByName('carnet_contract', content);
            }
            return result;
        } 
    }

    /********************************************************
     * 
     * Class: BaseDocument
     * Description: Use for override 'changeParams', 'changeContent', 'changeParamsWithObjects' or 'changeContentWithObjects' methods
     *
     ********************************************************/
    private virtual class BaseDocument{

        private String content {get;set;}
        private Map<String, Object> params {get;set;}
        private Opportunity opportunityObject {get;set;}
        private Account accountObject {get;set;}
        private E2E_Data_Object__c e2EDataObject {get;set;}

        private virtual Map<String, Object> changeParamsWithObjects(
            Map<String, Object> params,
            E2E_Data_Object__c dataObject,
            Opportunity opp,
            Account acc
        ){
            return params;
        } 

        private virtual String changeContentWithObjects(
            Map<String, Object> params,
            E2E_Data_Object__c dataObject,
            Opportunity opp,
            Account acc,
            String content
        ){
            return content;
        } 

        private virtual Map<String, Object> changeParams(Map<String, Object> params){
            return params;
        } 

        private virtual Boolean useMargin(){
            return true;
        } 

        private virtual String changeContent(Map<String, Object> params, String content){
            return content;
        } 

        private Map<String, Object> addCommonParams(Map<String, Object> params){
            params.put(
                'today', 
                (String)Datetime.now().format('yyyy-MM-dd')
            );
            return params;
        }

        private Account getAccount(String accountId){
            return [ 
                SELECT  Name, BillingCountryCode, BillingCountry, 
                        BillingStreet, BillingCity, BillingPostalCode, 
                        IBAN__c, SWIFT_BIC__c, Steuernummer__c,
                        Ort_der_Registrierung_Handelsregisterort__c, 
                        HR_Abteilung_HRA_HRB_und_HR_Nummer__c, 
                        UMR__c, Umsatzsteuer_ID__c
                FROM   Account
                WHERE  Id =: accountId
                LIMIT  1
            ];
        }

        private Opportunity getOpportunity(String dataObjectId){
            return [ 
                SELECT  Name, AccountId, Name_of_the_payer_Account_holder__c,
                        IBAN__c, SWIFT_BIC__c, Security_To_Pay__c,
                        Security_Amount_To_Pay__c, SEPA_Request_Approval_Date__c, Date_For_Agree_To_Deposit_Agreement__c, 
                        Credit_check_date__c, Number_of_electric_vehicles__c, Device_Type__c, 
                        Direct_Debit_Mandate_Type__c, Registered_Country__c
                FROM   Opportunity
                WHERE  E2E_Data_Object__c =: dataObjectId
                LIMIT  1
            ];
        }

        private E2E_Data_Object__c getE2EDataObject(String dataObjectId){
            return [
                SELECT  First_Name__c, Last_Name__c, Security_Amount_To_Pay__c
                FROM E2E_Data_Object__c 
                WHERE Id = :dataObjectId 
                LIMIT 1
            ];
        }

        public String getContent( Map<String, Object> params, String content){
            String source = (String)params.get('source');
            this.params = params;
            if(!String.isBlank(source) && source != 'null'){
                String countryCode = (String)params.get(KEY_COUNTRY_CODE);
                String dataId = ETEGlobalUtils.doDecryptParams(source, countryCode);
                this.e2EDataObject = this.getE2EDataObject(dataId);
                this.opportunityObject = this.getOpportunity(this.e2EDataObject.Id);
                this.accountObject = this.getAccount(this.opportunityObject.AccountId);
                this.params = this.changeParamsWithObjects(this.params, this.e2EDataObject, this.opportunityObject, this.accountObject);
                content = this.changeContentWithObjects(this.params, this.e2EDataObject, this.opportunityObject, this.accountObject, content);
            }

            this.params = this.addCommonParams(this.params);
            this.params = this.changeParams(this.params);
            this.content = this.changeContent(this.params, content);

            if(
                this.e2EDataObject != null && 
                this.opportunityObject != null && 
                this.accountObject != null
            ){
                Map<String, Object> e2EDataObjectMap = this.e2EDataObject.getPopulatedFieldsAsMap();
                Map<String, Object> opportunityObjectMap = this.opportunityObject.getPopulatedFieldsAsMap();
                Map<String, Object> accountObjectMap = this.accountObject.getPopulatedFieldsAsMap();
                this.content = this.mergeContent('e2edataobject',e2EDataObjectMap);
                this.content = this.mergeContent('opportunity',opportunityObjectMap);
                this.content = this.mergeContent('account',accountObjectMap);
            }
            return this.mergeContent('params', this.params);
        }

        public String getTemplateByName(String templateName , String content){
            return content.substringBetween(
                '<template id="' + templateName + '">',
                '</template>'
            );
        }

        public String getFormattedCurrency (Decimal dec) {
            String result = '';
            String separator = ' ';

            if (dec != null) {
                List<String> arr = String.valueOf(dec).split('');
                for (Integer i = arr.size() - 1; i >= 0; i--) {
                    result = arr[i] + result;
                    if (Math.mod(arr.size() - i, 3) == 0) {
                        result = separator + result;
                    }
                }

                if (result.indexOf(separator) == 0) {
                    result = result.substring(1);
                }
            }

            return result;
        }

        private String mergeContent (String prefix, Map<String, Object> objectMap) {
            for (String key : objectMap.keySet()) {
                try{
                    String value = String.valueOf(objectMap.get(key));
                    this.content = this.content.replaceAll('(?i)(\\{!' + prefix +'.' + key + '\\})',value);
                }catch(Exception e){}
            }

            this.content = this.content.replaceAll('(?i)(\\{!' + prefix + '.[A-Za-z0-9_]+\\})', '');
            this.content = this.content.replaceAll('(?i)(\\s+)', ' ');
            this.content = this.content.trim();

            return this.content;
        }
    }


    /********************************************************
     * 
     * Description: Initially page
     *
     ********************************************************/
    public static final String KEY_DOCUMENT_TARGET = 'target';
    public static final String KEY_COUNTRY_CODE = 'country_code';
    public static final String KEY_IMPL = 'impl';
    public static final String PAGE_NOT_FOUND = '<h1>Error</h1><p>Page not found</p>';

    public String content {get; set;}
    public String margin {get; set;}

    public void main(){
        this.content = PAGE_NOT_FOUND;
        Map<String, Object> paramsOnlyRead = ApexPages.currentPage().getParameters();
        Map<String, Object> params = new Map<String, Object>();
        params.putAll(paramsOnlyRead);

        String documentTarget = (String)params.get(KEY_DOCUMENT_TARGET);
        String countryCode = (String)params.get(KEY_COUNTRY_CODE);
        String impl = (String)params.get(KEY_IMPL);
        countryCode = this.getCountryCode(countryCode, impl);
        params.put(KEY_COUNTRY_CODE, countryCode);

        if(
            !String.isBlank(documentTarget) && 
            !String.isBlank(impl) &&
            !String.isBlank(countryCode)
        ){
            BaseDocument instance = new BaseDocument();

            if(documentTarget == 'ete_step_documents_contract' && impl == 'Poland'){
                instance = new StepDocumentsContractPL();
            }else if(documentTarget == 'ete_step_documents_tabel_price' && impl == 'Poland'){
                instance = new StepDocumentsTabelPricePL();
            }

            if(Test.isRunningTest()){
                this.content = '<template id="page_break">a</template><template id="header_image">b</template>'
                    + '<template id="header_image_carnet">c</template><template id="shell_contract">d</template>'
                    + '<template id="shell_deposit">e</template><template id="carnet_contract">f</template>'
                    + '<template id="shell_price">g</template><template id="carnet_price_with_contract">h</template>'
                    + '<template id="carnet_price_without_contract">i</template>';
            }else{
                this.content = PageReference.forResource(documentTarget, impl.replaceAll(' ', '_') + '_' + countryCode + '.html').getContent().toString();
            }
            
            this.content = instance.getContent(params, this.content);
            this.margin = !instance.useMargin() ? 'margin:0;' : '';
        }
    }

    private String getCountryCode(String countryCode, String impl){
        String result = countryCode;
        
        Map<String, List<String>> availableMap = new Map<String, List<String>>{
            'Poland' => new List<String>{'pl'},
            'Czech Republic CCS' => new List<String>{'cz'},
            'Slovakia CCS' => new List<String>{'sk'}
        };

        if(!availableMap.get(impl).contains(countryCode)){
            result = availableMap.get(impl).get(0);
        }

        return result;
    }
}
