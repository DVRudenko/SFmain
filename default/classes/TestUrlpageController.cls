public class TestUrlpageController {
	public String salesforceBaseUrl {get; set;}
	public String orgDomainUrl {get; set;}

    public TestUrlpageController() {
        this.salesforceBaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        this.orgDomainUrl = System.URL.getOrgDomainUrl().toExternalForm();
    }
}