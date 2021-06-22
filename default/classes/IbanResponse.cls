public class IbanResponse {
	public String length_check;
	public String sct;
	public String branch;
	public String bank_address;
	public String bank_postal_code;
	public String account_number;
	public String scc;
	public String bank_code;
	public String bank_code_check;
	public List<All_bic_candidates> all_bic_candidates;
	public String www_seen_until;
	public String url_category;
	public String sdd;
	public String bank_city;
	public String account_validation;
	public String bank;
	public Integer return_code;
	public String account_check;
	public String iban_listed;
	public String bank_and_branch_code;
	public Integer balance;
	public List<Bic_candidates> bic_candidates;
	public String www_seen_from;
	public Integer iban_reported_to_exist;
	public String result;
	public String branch_code;
	public String iban;
	public String iban_www_occurrences;
	public String iban_candidate;
	public String iban_url;
	public String cor1;
	public String www_prominence;
	public String url_rank;
	public String country;
	public String iban_last_reported;
	public String bank_url;
	public String b2b;
	public String in_scl_directory;
	public String formatcomment;
	public String sct_inst_readiness_date;
	public String bank_street;
	public String IBANformat;
	public String data_age;
	public String url_min_depth;
	public String iban_checksum_check;
	public String sct_inst;
	public String account_validation_method;
	public String bank_state;


	public class Bic_candidates {
		public String zip;
		public Integer wwwcount;
		public String sampleurl;
		public String bic;
		public String city;
	}


	public class All_bic_candidates {
		public String zip;
		public Integer wwwcount;
		public String sampleurl;
		public String bic;
		public String city;
	}
}