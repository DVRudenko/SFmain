/**
 * Created by Nikita.Mikhailov on 14.01.2019.
 */

public with sharing class GFNI_Card {
    public String CardRefId { get; set; }
    public Integer CardCategoryId { get; set; }
    public Integer CardTypeId { get; set; }
    public String DriverName {
        get {
            return String.isNotBlank(this.DriverName) ? this.DriverName.toUpperCase() : this.DriverName;
        }
        set;
    }
    public Integer EmbossingId { get; set; }
    public Integer OdometerPromptRequired { get; set; }
    public Integer PurchaseCategoryId { get; set; }
    public Integer DailyCardLimit { get; set; }
    public Integer MonthlyCardLimit { get; set; }
    public String VehicleRegistrationNumber {
        get {
            return String.isNotBlank(this.VehicleRegistrationNumber) ? this.VehicleRegistrationNumber.toUpperCase() : this.VehicleRegistrationNumber;
        }
        set;
    }
}