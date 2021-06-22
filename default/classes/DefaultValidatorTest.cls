@IsTest
public with sharing class DefaultValidatorTest {

    private static DefaultValidator validator = new DefaultValidator();

    @IsTest
    private static void listNotEmptyTest() {
        List<String> l = new List<String>{'dsd'};
        System.assertEquals(false, validator.listIsEmpty(l));

        l = new List<String>();
        System.assertEquals(true, validator.listIsEmpty(l));

        l = null;
        System.assertEquals(true, validator.listIsEmpty(l));
    }

    @IsTest
    private static void validateTest() {
        Account account = null;
        Exception ex = null;
        try {
            validator.validate(Account.class, 'account', account);
        } catch (Exception e) {
            ex = e;
            System.assertEquals('Account account = null', e.getMessage());
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        Object value = null;
        ex = null;
        try {
            validator.validate(Object.class, 'value', account);
        } catch (Exception e) {
            ex = e;
            System.assertEquals('Object value = null', e.getMessage());
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        account = new Account();
        ex = null;
        try {
            validator.validate(Object.class, 'value', account);
        } catch (Exception e) {
            ex = e;
        }
        System.assert(ex == null);
    }

    @IsTest
    private static void validateINNTest() {
        // INN is empty
        String INN = null;
        Exception ex = null;
        try {
            validator.validateINN(INN);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        // INN length is not correct
        INN = '12345';
        ex = null;
        try {
            validator.validateINN(INN);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        // INN contains not digits
        INN = '1234567890aa';
        ex = null;
        try {
            validator.validateINN(INN);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        // INN length is 10
        INN = '1234567890';
        ex = null;
        try {
            validator.validateINN(INN);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex == null);

        // INN length is 12
        INN = '123456789012';
        ex = null;
        try {
            validator.validateINN(INN);
        } catch (Exception e) {
            ex = e;
        }
        System.assert(ex == null);
    }

    @IsTest
    private static void validateNumberTest() {
        // number is null
        String value = null;
        Exception ex = null;
        try {
            validator.validateNumber(value);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        // number is empty
        value = '  ';
        ex = null;
        try {
            validator.validateNumber(value);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        // number with space
        value = '123  45';
        ex = null;
        try {
            validator.validateNumber(value);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        // number contains not digits
        value = '1234567890aa';
        ex = null;
        try {
            validator.validateNumber(value);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        // number is correct
        value = '1234567890';
        ex = null;
        try {
            validator.validateNumber(value);
        } catch (Exception e) {
            ex = e;
        }
        System.assert(ex == null);

    }

    @IsTest
    private static void isNumberTest() {
        // number is null
        String value = null;
        System.assertEquals(false, validator.isNumber(value));

        // number is empty
        value = '  ';
        System.assertEquals(false, validator.isNumber(value));

        // number with space
        value = '123  45';
        System.assertEquals(false, validator.isNumber(value));

        // number contains not digits
        value = '1234567890aa';
        System.assertEquals(false, validator.isNumber(value));

        // number is correct
        value = '1234567890';
        System.assertEquals(true, validator.isNumber(value));
    }

    @IsTest
    public static void validateTurnoverTest() {
        // number is null
        Long value = null;
        Exception ex = null;
        try {
            validator.validateTurnover(value);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        // number is empty
        value = 0;
        ex = null;
        try {
            validator.validateTurnover(value);
        } catch (Exception e) {
            ex = e;
            System.assert(e.getMessage() != null);
            System.assertEquals(ValidationException.class.getName(), e.getTypeName());
        }
        System.assert(ex != null);

        // number is correct
        value = 2000;
        ex = null;
        try {
            validator.validateTurnover(value);
        } catch (Exception e) {
            ex = e;
        }
        System.assert(ex == null);
    }

}