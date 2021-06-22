public abstract class AbstractValidator {

    public virtual void validate(System.Type type, String name, Object value) {
        if (value == null) throw new ValidationException(type + ' ' + name + ' = null');
    }

    public virtual Boolean listIsEmpty(List<Object> l) {
        return l == null || l.isEmpty();
    }

    public virtual void validateNumber(String value) {
        if (value == null) throw new ValidationException(System.Label.Invalid_number.replace('{number}', 'null'));
        if (!value.isNumeric()) throw new ValidationException(System.Label.Invalid_number.replace('{number}', value));
    }

    public virtual Boolean isNumber(String value) {
        return value != null && value.isNumeric();
    }

}