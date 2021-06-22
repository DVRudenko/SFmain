global class CreditSafeAuthEntity {
	global String token;
	global String message;
	
	global static CreditSafeAuthEntity parse(String jsonStr) {
		return (CreditSafeAuthEntity) JSON.deserialize(jsonStr, CreditSafeAuthEntity.class);
	}
}