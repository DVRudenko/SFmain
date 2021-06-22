public virtual class DefaultValidator extends AbstractValidator {

    public virtual void validateINN(String inn) {
        if (inn == null) throw new ValidationException(System.Label.Invalid_INN.replace('{inn}', 'null'));
        if (!((inn.length() == 10 || inn.length() == 12) && inn.isNumeric())) throw new ValidationException(System.Label.Invalid_INN.replace('{inn}', inn));
    }

    public virtual void validateTurnover(Long turnover) {
        if (turnover == null || turnover <= 0) throw new ValidationException(System.Label.Invalid_turnonver);
    }

}