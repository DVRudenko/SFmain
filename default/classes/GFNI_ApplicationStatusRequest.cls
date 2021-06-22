/**
 * Created by Nikita.Mikhailov on 23.01.2019.
 */

public with sharing class GFNI_ApplicationStatusRequest {
    public GFNI_Metadata Metadata { get; set; }
    public List<GFNI_Application> Applications { get; set; }

    public void addApplication(GFNI_Application application) {
        if (Applications == null)
            Applications = new List<GFNI_Application>();

        Applications.add(application);
    }
}