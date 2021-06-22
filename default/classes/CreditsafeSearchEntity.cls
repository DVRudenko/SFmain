global class CreditsafeSearchEntity {
	global Integer totalSize;
	global List<Companies> companies;
	global String error;

	global class Address {
		global String street;
		global String simpleValue;
		global String postCode;
		global String houseNo;
		global String city;
	}

	global class Companies {
		global DateTime dateOfLatestAccounts;
		global List<String> vatNo;
		global String id;
		global String country;
		global List<String> tradingNames;
		global String status;
		global DateTime dateOfLatestChange;
		global String activityCode;
		global String name;
		global String officeType;
		global String safeNo;
		global String regNo;
		global Address address;
	}

	global static CreditsafeSearchEntity parse(String jsonStr) {
		return (CreditsafeSearchEntity) JSON.deserialize(jsonStr, CreditsafeSearchEntity.class);
	}
}