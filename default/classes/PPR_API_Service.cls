public interface PPR_API_Service {

    E2EFormParams checkINN(Map<String, String> params);

    PPR_API_ResponseBody processCheckINN(Map<String, String> params);

    PPR_API_ResponseBody processCheckStatus(Map<String, String> params);
}