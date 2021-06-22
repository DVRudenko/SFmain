/**
 * Created by Anna Rudas on 29.11.2017.
 */

public class CardGfnReport {
    public String cardRequestedType { get; set; }
    public String productsCategory { get; set; }
    public String vehicleType { get; set; }
    public String companyShortName { get; set; }
    public String registrationNum { get; set; }
    public String driverName { get; set; }
    public Integer mileageData { get; set; }

    public CardGfnReport() {
        this.cardRequestedType = '';
        this.productsCategory = '';
        this.vehicleType = '';
        this.companyShortName = '';
        this.registrationNum = '';
        this.driverName = '';
        this.mileageData = 0;
    }
}