public with sharing class CreditDataGfn {
	public List<Data> Data;
	public Meta Meta;
	public Links Links;
	public class Data {
		public Integer CustomerID { get; private set; }
		public String CustomerERP { get; private set; }
		public String FullName { get; private set; }
		public String CreditSystemCustomerNumber { get; private set; }
		public String ExternalAccountingClerk { get; private set; }
		public String ExternalCreditManager { get; private set; }
		public Boolean CreditManagementOnshore { get; private set; }
		public Boolean DebtManagementOnshore { get; private set; }
		public String LOBOwnerID { get; private set; }
		public String LOBOwner { get; private set; }
		public String DebtCollectionLevelID { get; private set; }
		public String DebtCollectionLevel { get; private set; }
		public String PaymentIndex { get; private set; }
		public Integer CreditScore { get; private set; }
		public String LastInternalReviewDate { get; private set; }
		public String NextInternalReviewDate { get; private set; }
		public String LastExternalReviewDate { get; private set; }
		public String NextExternalReviewDate { get; private set; }
    }
    
	public class Meta {
		public Integer TotalPages { get; private set; }
    }
    
	public class Links {
		public String Self { get; private set; }
		public String First { get; private set; }
		public String Last { get; private set; }
		public String Prev { get; private set; }
		public String Next { get; private set; }
	}
}
