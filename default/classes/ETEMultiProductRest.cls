@RestResource(UrlMapping='/multiproduct/v1')
global without sharing class ETEMultiProductRest {

    public static final String PARAM_METHOD = 'method';
    public static final String PARAM_IMPL_KEY = 'implKey';
    public static final String PARAM_SOURCE = 'source';

    public static final String MESSAGE_IMPL_NOT_FOUND = 'Error! Impl key not found';
    public static final String MESSAGE_METHOD_NOT_FOUND = 'Error! Method not found';
    public static final Integer STATUS_CODE_SUCCESS = 200;
    public static final Integer STATUS_CODE_PAGE_NOT_FOUND = 404;
    public static final Integer STATUS_CODE_IMPL_NOT_FOUND = 405;
    public static final Integer STATUS_CODE_METHOD_NOT_FOUND = 406;
    
    @HttpGet
    global static void router () {

        Map<String, String> params = RestContext.request.params;
        RestResponse response = RestContext.response;

        if (response == null) {
            response = new RestResponse();
        }

        ETEMultiProductResponse mResponse = new ETEMultiProductResponse(STATUS_CODE_IMPL_NOT_FOUND, MESSAGE_IMPL_NOT_FOUND);
        String implKey = params.get(PARAM_IMPL_KEY);
        ETEMultiProductInterface instance = ETEGlobalUtils.getETEMultiProductImplementation(implKey);

        if(instance != null){
            String method = params.get(PARAM_METHOD);

            switch on method {
                when 'getProducts' { 
                    mResponse = instance.getProducts(params);
                }
                when 'getOrder' { 
                    mResponse = instance.getOrder(params);
                }when else{
                    mResponse.setStatusCode(STATUS_CODE_METHOD_NOT_FOUND).setData(MESSAGE_METHOD_NOT_FOUND);
                }
            }
        }

            
        response.addHeader('Access-Control-Allow-Methods', 'GET');
        response.addHeader('Content-Type', 'application/json; charset=utf-8');
        response.statusCode = mResponse.getStatusCode();
        String resultString = JSON.serialize(mResponse.getData());
        response.responseBody = Blob.valueOf(resultString);
        RestContext.response = response;
    }
}