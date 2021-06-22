/**
 * Created by Nikita.Mikhailov on 21.02.2019.
 */

public with sharing class GFNI_GetCustomerIdRequest {
    public GFNI_Metadata Metadata { get; set; }
    public String Name { get; set; }
    public String EmailAddress { get; set; }
    public String CompanyRegNumber { get; set; }
    public String VATNumber { get; set; }
}