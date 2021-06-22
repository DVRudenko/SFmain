/**
 * Created by Nikita.Mikhailov on 14.01.2019.
 */

public with sharing class GFNI_PaymentInfo {
    public Integer PaymentTermsId { get; set; }
    public Integer PaymentMethodId { get; set; }
    public Integer PaymentFrequencyId { get; set; }
    public List<GFNI_BankAccount> BankAccounts { get; set; }

    public void addBankAccount(GFNI_BankAccount bankAccount) {
        if (this.BankAccounts == null)
            this.BankAccounts = new List<GFNI_BankAccount>();

        this.BankAccounts.add(bankAccount);
    }
}