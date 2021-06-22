/**
 * Created by Nikita.Mikhailov on 14.01.2019.
 */

public with sharing class GFNI_Contact {
    public Integer Primary { get; set; }
    public Integer SalutationId { get; set; }
    public String FirstName {
        get {
            return String.isNotBlank(this.FirstName) ? this.FirstName.toUpperCase() : this.FirstName;
        }
        set;
    }
    public String MiddleName {
        get {
            return String.isNotBlank(this.MiddleName) ? this.MiddleName.toUpperCase() : this.MiddleName;
        }
        set;
    }
    public String LastName {
        get {
            return String.isNotBlank(this.LastName) ? this.LastName.toUpperCase() : this.LastName;
        }
        set;
    }
    public String Phone {
        get {
            return String.isNotBlank(this.Phone) ? this.Phone.toUpperCase() : this.Phone;
        }
        set;
    }
    public String Fax {
        get {
            return String.isNotBlank(this.Fax) ? this.Fax.toUpperCase() : this.Fax;
        }
        set;
    }
    public String Mobile {
        get {
            return String.isNotBlank(this.Mobile) ? this.Mobile.toUpperCase() : this.Mobile;
        }
        set;
    }
    public String Email { get; set; }
    public String Language { get; set; }
}