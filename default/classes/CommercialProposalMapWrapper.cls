public class CommercialProposalMapWrapper {
	public String mapImage;
	public String eurolocatorUrl;
	public List<PetrolStationList> petrolStationList;

	public class PetrolStationList {
		public String phone {get; set;}
		public Decimal distanceToFuelStation {get; set;}
		public Brand brand {get; set;}
		public List<AdditionalServices> additionalServices {get; set;}
		public Integer indexNumber {get; set;}
		public Decimal distanceFromRoad {get; set;}
		public List<FuelServices> fuelServices {get; set;}
		public String address {get; set;}
	}

	public class Brand {
		public String name {get; set;}
		public Integer id;
	}

	public class AdditionalServices {
		public String serviceName;
		public Integer id;
	}

	public class FuelServices {
		public String serviceName;
		public Integer id;
	}
}