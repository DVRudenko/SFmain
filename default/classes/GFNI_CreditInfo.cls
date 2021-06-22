/**
 * Created by Nikita.Mikhailov on 14.01.2019.
 */

public with sharing class GFNI_CreditInfo {
    public String CreditSystemNumber {
        get {
            return String.isNotBlank(this.CreditSystemNumber) ? this.CreditSystemNumber.toUpperCase() : this.CreditSystemNumber;
        }
        set;
    }
    public Decimal CreditLimit { get; set; }
    public String CreditSystemRating { get; set; }
    public Integer CreditRatingId { get; set; }
}