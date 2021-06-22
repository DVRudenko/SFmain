public class ETEMultiProductResponse {

    private Integer statusCode;
    private Object data;

    public ETEMultiProductResponse(){}

    public ETEMultiProductResponse(Integer statusCode, Object data) {
        this.statusCode = statusCode;
        this.data = data;
    }

    public ETEMultiProductResponse setStatusCode(Integer statusCode){
         this.statusCode = statusCode;
         return this;
    }

    public ETEMultiProductResponse setData(Object data){
         this.data = data;
         return this;
    }

    public Integer getStatusCode(){
         return this.statusCode;
    }

    public Object getData(){
         return this.data;
    }
}
