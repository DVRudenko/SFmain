public class CFSearchResponse {
	public String status {get; set;}
	public String message;
	public Map<String, CreditCompany> companiesMap {get; set;}
	public String orderReferenceNumber {get; set;}
	public String orderPartyId {get; set;}

    public CFSearchResponse() {      
    }
}