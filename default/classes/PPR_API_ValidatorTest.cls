@IsTest
public class PPR_API_ValidatorTest {

    @IsTest
    public static void validateTypesTest() {
        PPR_API_CreateClientTestDataBuilder builder = new PPR_API_CreateClientTestDataBuilder();
        builder.baseRequest(null, null, SparkTestDataFactory.entrepreneurInn);
        System.assertEquals(
                'Validation error. Required address types are missing for sole proprietor. Required - [Billing].',
                PPR_API_Validator.validateTypes(builder.build()).message
        );

        builder.clean().baseRequest(null, null, SparkTestDataFactory.inn);
        System.assertEquals(
                'Validation error. Required email types are missing in legal info. Required - [LK accesses, Mail].',
                PPR_API_Validator.validateTypes(builder.build()).message
        );

        builder.appendEmail('test@mail.com', new List<String>{'LK accesses', 'Mail'});
        System.assertEquals(
                'Validation error. Required phone types are missing in legal info. Required - [Main].',
                PPR_API_Validator.validateTypes(builder.build()).message
        );

        builder.appendPhone('1234567890', new List<String>{'Main'});
        System.assertEquals(null, PPR_API_Validator.validateTypes(builder.build()));
    }

    @IsTest
    public static void validateAddressLengthTest() {
        PPR_API_CreateClientTestDataBuilder builder = new PPR_API_CreateClientTestDataBuilder();
        builder.baseRequest(null, null, null).appendAddress(new List<String>{'Billing'});

        System.assertEquals(null, PPR_API_Validator.validateAddressLength(builder.build().customerInfo.addresses));

        String s = '';
        for (Integer i = 0; i < 250; i++) {
            s += 'a';
        }
        PPR_API_CreateClientRequest request = builder.build();
        request.customerInfo.addresses.get(0).street = s;
        System.assertEquals(
                'Validation error. Billing address fields is too long. street + house + apartment must be up to 249 chars. ',
                PPR_API_Validator.validateAddressLength(request.customerInfo.addresses).message
        );
    }

}