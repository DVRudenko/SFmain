global class DecisionPrescoring {
    public Boolean decision;            // решение по прескорингу, true – ДА, false – НЕТ(boolean);
    public String dateRequest;          // дата запроса/дата решения(String);
    public String expireDate;           // дата действия решения(String);
    public Integer creditPeriod;        // срок кредита(int);
    public Integer paymentTimeLimit;    // срок оплаты(int);
    public Long overdraft;              // овердрафт(long);
    public Boolean blocked;           // заявка на прескоринг заблокирована(boolean);
    public String decisionString;       // кредитное решение для отображения пользователю
}