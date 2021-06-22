/**
 * Created by Anna Rudas on 08.12.2017.
 */

public class AccountGfnReportSendingLog {

    public String accountId {get; set;}
    public String opportunityId {get; set;}
    public String address {get; set;}
    public String fileName {get; set;}
    public Id userId {get; set;}

    public AccountGfnReportSendingLog(String accountId, String opportunityId, String address, String fileName, Id userId) {
        this.accountId = accountId;
        this.opportunityId = opportunityId;
        this.address = address;
        this.fileName = fileName;
        this.userId = userId;
    }
}