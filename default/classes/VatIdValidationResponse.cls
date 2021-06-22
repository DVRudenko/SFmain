public class VatIdValidationResponse {
    public Boolean valid;
	public String database;
	public Boolean format_valid;
	public String query;
	public String country_code;
	public String vat_number;
	public String company_name;
	public String company_address;
	public Error error;
	public class Error {
		public Integer code;
		public String type;
		public String info;
	}
}