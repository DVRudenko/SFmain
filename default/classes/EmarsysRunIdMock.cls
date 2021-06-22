/**
 * Created by Yury on 07.10.2020.
 */

global class EmarsysRunIdMock implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest request){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(' {"replyCode":0,"replyText":"OK","data":{"run_id":"20201007064602-MoKTqSal-suite15-web3-10314-s15","status":"waiting"}}');
        return res;
    }
}