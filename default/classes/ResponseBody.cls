global class ResponseBody {
    global String id;
    global List<String> errors;
    global Boolean success;

    global ResponseBody(Boolean success, String recordId, List<String> errors) {
        this.id = recordId;
        this.errors = errors;
        this.success = success;
    }

}