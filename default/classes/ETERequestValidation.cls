public class ETERequestValidation {

    public void validateDataObjectSource(String source, String countryCode) {
        if (! String.isEmpty(source)) {
            String sobjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
            Boolean sourceIsValid = Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(sobjectId).matches();
            if (sourceIsValid == false) {
                throw new LongFormException('data object source is not valid');
            }
        }
    }

    public void validateRequestedCountry(String currentCountry, String requestedCountry) {
        if (currentCountry != requestedCountry) {
            throw new LongFormException('requested country is not valid');
        }
    }
}