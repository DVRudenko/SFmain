public class E2ELocatorStation {
	public String highway;
	public Boolean canManageCards;
	public String currencyUnit;
	public String segmentNumber;
	public Integer indexNumber;
	public Boolean fuelStation;
	public String allServiceIds;
	public Integer typeNetwork;
	public Integer brandId;
	public Integer ourProduct;
	public List<Services> services;
	public String address;
	public Boolean brandBigIconExists;
	public String distance;
	public String countryName;
	public Decimal longitude;
	public String id;
	public String brand;
	public Decimal latitude;
	public String fuelServiceNames;
	public List<Products> products;
	public String townName;
	public String stationId;
	public String productNames;
	public String phone;
	public String distanceFromStart;
	public String regionId;
	public List<FuelServices> fuelServices;
	public String serviceNames;
	public Boolean brandIconExists;
	public String serviceIds;
	public Boolean washing;
	public String name;
	public String stationCode;
	public Boolean gasStation;
	public String distanceToFinish;

	public class Services {
		public Boolean able;
		public Integer id;
		public Integer price;
		public Boolean main;
		public Boolean fuel;
		public Boolean premium;
		public String name;
		public String priceDate;
		public String help;
	}

	public class Products {
		public Integer id;
		public Boolean international;
		public Boolean incOfDefault;
		public Boolean productImgExists;
		public String name;
		public Boolean single;
	}

	public class FuelServices {
		public Boolean able;
		public Integer id;
		public Integer price;
		public Boolean main;
		public Boolean fuel;
		public Boolean premium;
		public String name;
		public String priceDate;
		public String help;
	}
}