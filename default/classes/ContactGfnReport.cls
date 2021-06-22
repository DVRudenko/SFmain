/**
 * Created by Anna Rudas on 29.11.2017.
 */

public class ContactGfnReport {
    public String salutation { get; set; }
    public String firstName { get; set; }
    public String middleName { get; set; }
    public String lastName { get; set; }
    public String role { get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String mobilePhone { get; set; }
    public String fax { get; set; }
    public Boolean isPrimary { get; set; }

    public ContactGfnReport() {
        this.salutation = '';
        this.firstName = '';
        this.middleName = '';
        this.lastName = '';
        this.role = '';
        this.email = '';
        this.phone = '';
        this.mobilePhone = '';
        this.fax = '';
        this.isPrimary = false;
    }
}