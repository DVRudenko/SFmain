public class DashboardNumberOfLeadsOnAccountCtrl {
    private ApexPages.StandardController controller {get; set;}
    public Map<String, Decimal> leadMapThisMonth {get; set;}
    public Map<String, Decimal> leadMapLastMonth {get; set;}
    public Map<String, Decimal> leadMapPenaltMonth {get; set;}
    public String currentId {get; set;}
    public DashboardNumberOfLeadsOnAccountCtrl(ApexPages.StandardController controller) {
        this.controller = controller;
        currentId = ApexPages.currentPage().getParameters().get('id');
        List<Lead> listLeadsWithCreatedDateInThisMonth = new List<Lead>();
        List<Lead> listLeadsWithCreatedDateInLastMonth = new List<Lead>();
        List<Lead> listLeadsWithCreatedDateInPenaltMonth = new List<Lead>();
        RecordType retailerRecordType = [
                SELECT Name 
                FROM RecordType
                WHERE Name = 'Retailer' AND SobjectType = 'Account'];
        Account parentAccount = [
                SELECT Name, RecordTypeId
                FROM Account 
                WHERE Id = :currentId
                LIMIT 1];
        if (parentAccount.RecordTypeId == retailerRecordType.Id) {
            Set<Id> accountIdSet = new Set<Id>();
            accountIdSet.add(currentId);
            List<Account> childAccountList = [
                    SELECT Name, RecordTypeId, ParentId
                    FROM Account
                    WHERE ParentId = :currentId AND RecordTypeId = :retailerRecordType.Id];
            for (Account account : childAccountList) {
                accountIdSet.add(account.Id);
            }
            
            List<Lead> leadList = [
                    SELECT Name, CreatedDate
                    FROM Lead
                    WHERE Partner__c IN :accountIdSet AND CreatedDate > :date.today().addMonths(-3)];
            for (Lead lead : leadList) {
                if (lead.CreatedDate.month() == date.today().month() && lead.CreatedDate.year() == date.today().year()) {
                    listLeadsWithCreatedDateInThisMonth.add(lead);
                }

                if (lead.CreatedDate.month() == date.today().addMonths(-1).month() && lead.CreatedDate.year() == date.today().year()) {
                    listLeadsWithCreatedDateInLastMonth.add(lead);
                } 

                if (lead.CreatedDate.month() == date.today().addMonths(-2).month() && lead.CreatedDate.year() == date.today().year()) {
                    listLeadsWithCreatedDateInPenaltMonth.add(lead);
                }

                if (date.today().month() == 1) {
                    if (lead.CreatedDate.month() == date.today().addMonths(-1).month() && lead.CreatedDate.year() == date.today().addYears(-1).year()) {
                        listLeadsWithCreatedDateInLastMonth.add(lead);
                    } 

                    if (lead.CreatedDate.month() == date.today().addMonths(-2).month() && lead.CreatedDate.year() == date.today().addYears(-1).year()) {
                        listLeadsWithCreatedDateInPenaltMonth.add(lead);
                    }
                } else if (date.today().month() == 2) {
                    if (lead.CreatedDate.month() == date.today().addMonths(-2).month() && lead.CreatedDate.year() == date.today().addYears(-1).year()) {
                        listLeadsWithCreatedDateInPenaltMonth.add(lead);
                    }
                }
            }
        }

        leadMapThisMonth = new Map<String, Decimal>();
        leadMapThisMonth.put(monthsMap.get(date.today().month()), listLeadsWithCreatedDateInThisMonth.size());
        leadMapLastMonth = new Map<String, Decimal>();
        leadMapLastMonth.put(monthsMap.get(date.today().addMonths(-1).month()), listLeadsWithCreatedDateInLastMonth.size());
        leadMapPenaltMonth = new Map<String, Decimal>();
        leadMapPenaltMonth.put(monthsMap.get(date.today().addMonths(-2).month()), listLeadsWithCreatedDateInPenaltMonth.size());
    }

    private Map<Integer, String> monthsMap = new Map<Integer, String>{
        1 => 'January', 
        2 => 'February', 
        3 => 'March',
        4 => 'April',
        5 => 'May',
        6 => 'June',
        7 => 'July',
        8 => 'August',
        9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'
    };
}