/**
 * Created by Nikita.Mikhailov on 14.01.2019.
 */

public with sharing class GFNI_CreateCustomerCardsRequest {
    public GFNI_Metadata Metadata { get; set; }
    public List<Integer> ServiceIds { get; set; }
    public String ApplicationId { get; set; }
    public GFNI_Customer Customer { get; set; }

    public void addServiceId(Integer serviceId) {
        if (this.ServiceIds == null)
            this.ServiceIds = new List<Integer>();

        this.ServiceIds.add(serviceId);
    }
}