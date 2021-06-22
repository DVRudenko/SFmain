public interface CardsRangeWebService {

    Map<String, Object> getEntity(String entityName, String id, List<String> queryOptions);

    List<Map<String, Object>> getEntities(String entityName, List<String> queryOptions);

    void updateEntity(String entityName, String id, Map<String, Object> data);

    void updateEntities(String entitySet, Map<String, Map<String, Object>> idDataMap);

}