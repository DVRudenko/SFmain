/**
 * Created by Nikita.Mikhailov on 14.01.2019.
 */

public with sharing class GFNI_Address {
    public Integer TypeId { get; set; }
    public String Line1 {
        get {
            return String.isNotBlank(this.Line1) ? this.Line1.toUpperCase() : this.Line1;
        }
        set;
    }
    //public String Line2 { get; set; }
    //public String Line3 { get; set; }
    public String City {
        get {
            return String.isNotBlank(this.City) ? this.City.toUpperCase() : this.City;
        }
        set;
    }
    public String CountryCode {
        get {
            return String.isNotBlank(this.CountryCode) ? this.CountryCode.toUpperCase() : this.CountryCode;
        }
        set;
    }
    public String ZipCode {
        get {
            return String.isNotBlank(this.ZipCode) ? this.ZipCode.toUpperCase() : this.ZipCode;
        }
        set;
    }
    public String Phone {
        get {
            return String.isNotBlank(this.Phone) ? this.Phone.toUpperCase() : this.Phone;
        }
        set;
    }
}