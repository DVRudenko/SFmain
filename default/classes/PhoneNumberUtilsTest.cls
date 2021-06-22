@IsTest
public with sharing class PhoneNumberUtilsTest {

    @IsTest
    private static void testGetRawPhoneNumber() {
        String rawPhoneNumber = '+7(999) 555-32-32#05';
        String cleanedPhoneNumber = PhoneNumberUtils.getRawPhoneNumber(rawPhoneNumber);
        System.assertEquals('9995553232', cleanedPhoneNumber);
        System.assertEquals('+7(999) 555-32-32#05', rawPhoneNumber);

        //if phone is blank
        String blankPhoneNumber = '';
        System.assertEquals('', PhoneNumberUtils.getRawPhoneNumber(blankPhoneNumber));
        System.assertEquals('', blankPhoneNumber);

        //if phone is short
        String shortRawPhoneNumber = '+7(999) 5-32-32#05';
        cleanedPhoneNumber = PhoneNumberUtils.getRawPhoneNumber(shortRawPhoneNumber);
        System.assertEquals('799953232', cleanedPhoneNumber);
        System.assertEquals('+7(999) 5-32-32#05', shortRawPhoneNumber);
    }

    @IsTest
    private static void testAddUnifiedPhoneNumber() {
        String delimiter = PhoneNumberUtils.PHONE_NUMBER_DELIMITER;
        PhoneNumberUtils.ListBuilder listBuilder = new PhoneNumberUtils.ListBuilder();

        String rawPhoneNumber = '+7(999) 555-32-32#05';
        listBuilder.addUnifiedPhoneNumber(rawPhoneNumber);
        System.assertEquals('9995553232', listBuilder.getPhoneNumbersString());
        System.assertEquals('+7(999) 555-32-32#05', rawPhoneNumber);

        listBuilder.addUnifiedPhoneNumber(rawPhoneNumber);
        System.assertEquals('9995553232' + delimiter + '9995553232', listBuilder.getPhoneNumbersString());

        //if phone is blank
        String blankPhoneNumber = ' ';
        listBuilder.addUnifiedPhoneNumber(blankPhoneNumber);
        System.assertEquals('9995553232' + delimiter + '9995553232', listBuilder.getPhoneNumbersString());

        listBuilder.refresh();
        System.assert(listBuilder.getPhoneNumberListMain().isEmpty());
        System.assert(String.isEmpty(listBuilder.getPhoneNumbersString()));
    }

}