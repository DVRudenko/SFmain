global class MetadataBody {

    global String transactionId = GlobalUtils.generateGUID();   // transaction UUID
    global String user = UserInfo.getUserName();                // the user who made the request
    global Long tsCreated = System.currentTimeMillis();         // timestamp when request was created
    global Long tsSent;                                         // timestamp when request was sent
    global String source = 'salesforce';                        // the source of the request
    global String channel = 'api';                              // request channel, eg "api"

}