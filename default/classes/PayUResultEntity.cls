public class PayUResultEntity {
	public Order order;
	public DateTime localReceiptDateTime;
	public List<Properties> properties;
	public String access_token;
	public String redirectUri;

    public class Products {
		public String unitPrice;
		public String quantity;
		public String name;
	}

	public class Buyer {
		public String language;
		public String phone;
		public String firstName;
		public String email;
		public String customerId;
		public String lastName;
	}

	public class PayMethod {
		public String type;
	}

	public class Order {
		public List<Products> products;
		public String merchantPosId;
		public String description;
		public String notifyUrl;
		public Buyer buyer;
		public String status;
		public String totalAmount;
		public DateTime orderCreateDate;
		public String currencyCode;
		public String customerIp;
		public String orderId;
		public PayMethod payMethod;
	}

	public class Properties {
		public String value;
		public String name;
	}

	public static PayUResultEntity parse(String jsonStr) {
		return (PayUResultEntity) JSON.deserialize(jsonStr, PayUResultEntity.class);
	}
}