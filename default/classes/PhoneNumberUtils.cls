public with sharing class PhoneNumberUtils {

    public static final String PHONE_NUMBER_DELIMITER = ' ';

    /*******************************************************************************
    *  Name            : getRawPhoneNumber(String phoneNumber)
    *  Summary         : remove redundant symbols from phone number
    *  CreatedDate     : 02.12.2019
    *  Parameters      : String phoneNumber
    *  Returns         : String - trimmed phone number
    ******************************************************************************/
    public static String getRawPhoneNumber(String phoneNumber) {
        return String.isBlank(phoneNumber) ? '' : phoneNumber.substringBeforeLast('#').replaceAll('[-() #+]', '').right(10);
    }

    public class ListBuilder {

        private String buffer = '';
        private List<String> phoneNumberList = new List<String>();

        public void refresh() {
            this.phoneNumberList = new List<String>();
            this.buffer = '';
        }

        /*******************************************************************************
        *  Name            : addUnifiedPhoneNumber(String phoneNumber)
        *  Summary         : format input string and appends it to the list of the main phone numbers
        *  CreatedDate     : 18.06.2020
        *  Parameters      : String phoneNumber - phone with any formatting
        *  Returns         : ListBuilder
        ******************************************************************************/
        public ListBuilder addUnifiedPhoneNumber(String phoneNumber) {
            this.buffer = getRawPhoneNumber(phoneNumber);
            if (String.isNotEmpty(this.buffer)) this.phoneNumberList.add(this.buffer);
            return this;
        }

        public List<String> getPhoneNumberListMain() {
            return this.phoneNumberList;
        }

        public String getPhoneNumbersString() {
            return String.join(getPhoneNumberListMain(), PHONE_NUMBER_DELIMITER);
        }

    }

}