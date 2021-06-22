/**
 * Created by Andrei.Moiseev on 05.04.2018.
 */

public interface NetStartVolumeDataProcessingInterface {
    List<Map<String, Object>> processingData(List<Object> objectList);
    Map<String, Object> initTotalData();
    String getSoqlRequest();
    void updateFilters(String filters);
}