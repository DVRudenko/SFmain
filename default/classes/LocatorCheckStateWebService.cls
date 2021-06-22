@RestResource(urlMapping='/locator-check-state')
global with sharing class LocatorCheckStateWebService {

    private static final String SECRET_KEY = 'P!v^h9UOC2j&';
    private static final List<String> COMPLETED_STATUSES = new List<String>{
            'Aborted',
            'Completed',
            'Failed'
    };

    @HttpPost
    global static String getUpdatingState(String batchId) {
        RestRequest req = RestContext.request;
        Map<String, String> heders = req.headers;
        String secretKey = heders.get('secretKey');
        Map<String,Object> result = new Map<String, Object>{
                'status' => 'error'
        };
        try{
            if(secretKey != null && secretKey == SECRET_KEY && batchId != null){

                AsyncApexJob batchJob = [
                        SELECT NumberOfErrors, Status, JobItemsProcessed, TotalJobItems
                        FROM AsyncApexJob
                        WHERE Id = :batchId
                        LIMIT 1
                ];

                String status = COMPLETED_STATUSES.contains(batchJob.Status) ? 'complete' :  'process';
                result.put('status', status);
                result.put('batchId', batchId);
                result.put('countErrors', batchJob.NumberOfErrors);
                result.put('countDone', batchJob.JobItemsProcessed);
                result.put('countTotal', batchJob.TotalJobItems);

            }else{
                CalloutException e = new CalloutException();
                e.setMessage('Error! Invalid auth key');
                throw e;
            }
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
            if(e instanceof QueryException) {
                result.put('cleanBatch', true);
            }
        }

        return JSON.serialize(result);
    }
}