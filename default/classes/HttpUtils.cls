public without sharing class HttpUtils {

    public static final Integer MAX_TIMEOUT = 120000;
    public static final Method METHOD = new Method();
    public static final PPRMiddleware PPR_MIDDLEWARE = new PPRMiddleware();
    public static final Header HEADER = new Header();

    public static void throwHttpResponseException(Integer statusCode, String body, System.Type type, String method) {
        throw new HttpResponseException('\nMethod ' + type + '.' + method + ' received bad response.\nStatus code - ' + statusCode
                + '.\nMessage - ' + body + '.');
    }

    public class Method {
        public final String GET = 'GET';
        public final String POST = 'POST';
    }

    public class Header {
        public final String AUTHORIZATION = 'Authorization';
        public final String CONTENT_TYPE = 'Content-Type';
        public final String JSON = 'application/json';
        public final IBMGateway IBM_GATEWAY = new IBMGateway();
    }

    public class PPRMiddleware {
        public final String STATUS_CODE_RESPONSE_PROPERTY = 'statusCode';
        public final String CONTENT_RESPONSE_PROPERTY = 'content';
        public final String MESSAGE_RESPONSE_PROPERTY = 'message';
    }

    public class IBMGateway {
        public final String CLIENT_SECRET = 'X-IBM-Client-Secret';
        public final String CLIENT_ID = 'X-IBM-Client-Id';
    }
}