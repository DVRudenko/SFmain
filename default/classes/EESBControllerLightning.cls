public with sharing class EESBControllerLightning {

    private static String LOG_NAME = 'EESBControllerLightning';
    private static String LOG_CREATE_CONTRACT = 'CreateDirectumContract';
    private static String LOG_CREATE_CONTRACT_EXCEPTION = 'CreateDirectumContract method exception = ';

    @AuraEnabled
    public static boolean createDirectumContract(DirectumContractRequestBody requestBody){

        Logger logger = new Logger(LOG_NAME);
        try {
            logger.info(LOG_CREATE_CONTRACT, JSON.serialize(requestBody));
            logger.saveLogs();
            new DirectumWebService().createContract(requestBody);
            return true;
        } catch (Exception e) {
            System.debug(LOG_CREATE_CONTRACT_EXCEPTION + e.getMessage());
            logger.fatal(LOG_CREATE_CONTRACT_EXCEPTION, e.getMessage());
            logger.saveLogs();
            return false;
        }
    }
}