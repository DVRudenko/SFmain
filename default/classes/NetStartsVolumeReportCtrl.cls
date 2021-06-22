/**
 * Created by ilja.garin on 25.08.2017.
 */
public class NetStartsVolumeReportCtrl {
    public Id userRoleId;
    public Integer noOfRecords{get; set;}
    public Integer size {get; set;}
    public List<Opportunity> matchingOpportunities {get; set;}
    private List<SelectOption> setCountry {get; set;}
    public List<SelectOption> setSecChannel {get; set;}
    public List<SelectOption> setAccountOwner {get; set;}
    public List<SelectOption> setRoles {get; set;}
    public List<SelectOption> setStartsManager {get; set;}
    public List<SelectOption> setOffer {get; set;}
    public List<SelectOption> setFirstPumpDate {get; set;}

    private Set<Id> finalUserSet {get; set;}

    public Set<Id> changeUserSet {get; set;}

    public String countries {get; set;}
    public String secChannel {get; set;}
    public String accountOwner {get; set;}
    public String role {get; set;}
    public String startsManager {get; set;}
    public String offer {get; set;}
    public String firstPumpDate {get; set;}

    public Map<Id, Map<Integer, Decimal>> startsList1 {get; set;}
    public Map<Id, Map<Integer, Decimal>> startsList2 {get; set;}
    public Map<Id, String> startsList3 {get; set;}
    public Map<Id, Decimal> startsList4 {get; set;}
    public Map<Integer, Decimal> startsList5 {get; set;}
    public Map<Integer, Decimal> startsList6 {get; set;}

    public Map<Id, User> userMap {get; set;}

    public Opportunity dateFromOpp {get;set;}
    public Date dateFrom;
    public Date dateTo;
    public Opportunity dateToOpp {get;set;}

    public Decimal totalNetStarts {get; set;}

    public String tquery {get; set;}

    /*Return current user with subordinate*/
    public void getUser() {
        userRoleId = UserInfo.getUserRoleId();
        Integer childSize = 1;
        Set<Id> parentRoleSet = new Set<Id>();
        Set<Id> parentRoleTemp = new Set<Id>();

        Set<Id> finalRoleSet = new Set<Id>();
        finalRoleSet.add(userRoleId);
        parentRoleTemp.add(userRoleId);

        do {
            for (UserRole childRole : [SELECT Id FROM UserRole WHERE ParentRoleId IN :parentRoleTemp]){
                if (childRole.Id <> null) {
                    finalRoleSet.add(childRole.Id);
                    parentRoleSet.add(childRole.Id);
                }
            }
            parentRoleTemp.clear();
            if (parentRoleSet.size() > 0) {
                parentRoleTemp.addAll(parentRoleSet);
            }
            else {childSize = 0;}
            parentRoleSet.clear();
        } while (childSize != 0);

        finalUserSet = new Set<Id>();
        for (User users : [SELECT Id FROM User WHERE UserRole.Id IN : finalRoleSet]){
            finalUserSet.add(users.Id);
        }

        if (UserInfo.getUserName() == 'Oskar Ehehalt' || UserInfo.getUserName() == 'Jan Polivka' || UserInfo.getUserName() == 'Endres Jorg')
        {
            GetExcludeUsers();
        }
    }

    private void GetExcludeUsers() {
        String userRoleName = UserInfo.getUserName();
        if (userRoleName == 'Oskar Ehehalt'){
            for (User users : [SELECT Id FROM User WHERE UserRole.Name IN ('Salesteam Outbound 1', 'Salesteam Outbound 2', 'Salesteam Outbound 3', 'Salesteam Outbound 4', 'Salesteam Outbound 5')
            OR (UserRole.Name = 'Salesteam Inbound') OR (UserRole.Name = 'Salesteam Inbound 2' AND LocaleSidKey = 'nl_NL')])
                finalUserSet.Add(users.Id);
        }
        if (userRoleName == 'Jan Polivka'){
            for (User users1 : [SELECT Id FROM User WHERE UserRole.Name = 'Salesteam Inbound 2' AND LocaleSidKey <> 'nl_NL'])
                finalUserSet.Add(users1.Id);
        }
        if (userRoleName == 'Endres Jorg'){
            for (User users2 : [SELECT Id FROM User WHERE UserRole.Name IN ('Salesteam Outbound 5', 'Salesteam Inbound 2')])
                finalUserSet.Add(users2.Id);
        }
    }

/*******************************************************************************
*  Name            : constructor
*  Summary         : initiation
*  CreatedDate     : 01/09/2017
*  Parameters      : -
*  Returns         :
******************************************************************************/
    public NetStartsVolumeReportCtrl() {
        getUser();
        getCountryItems();
        getSecChannelItems();
        getAccountOwnerItems();
        getRolesItems();
        getStartsManagerItems();
        getOfferItems();
        getFirstPumpDateItems();
        dateFromOpp = new Opportunity();
        dateFromOpp.CloseDate = Date.today().addDays(-70);
        dateToOpp = new Opportunity();
        dateToOpp.CloseDate = Date.today();
    }

    public void okButton() {
        refresh();
    }

    public List<SelectOption> getCountryItems() {
            Schema.DescribeFieldResult dfr = Account.BillingCountryCode.getDescribe();
            List<Schema.PicklistEntry> pe = dfr.getPicklistValues();
            setCountry = new List<SelectOption>();
            setCountry.add(new SelectOption('--None--', 'All'));
            for (Schema.PicklistEntry ple : pe){
                setCountry.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
        return setCountry;
    }

    public List<SelectOption> getSecChannelItems() {
            Schema.DescribeFieldResult dfr = Opportunity.Sec_Channel__c.getDescribe();
            List<Schema.PicklistEntry> pe = dfr.getPicklistValues();
            setSecChannel = new List<SelectOption>();
            setSecChannel.add(new SelectOption('--None--', 'All'));
            for (Schema.PicklistEntry ple : pe){
                setSecChannel.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
        return setSecChannel;
    }

    public List<SelectOption> getAccountOwnerItems() {
        Id currAccountOwner = null;
            setAccountOwner = new List<SelectOption>();
            setAccountOwner.add(new SelectOption('--None--', 'All'));
            for (User own : [SELECT Id, Name FROM User WHERE Id IN :finalUserSet ORDER BY Name, Id] ){
                if (currAccountOwner <> own.Id) {
                    if (own.Id <> null) {
                        setAccountOwner.add(new SelectOption(own.Id, own.Name));
                    }
                    else {
                        setAccountOwner.add(new SelectOption(null, 'null'));
                    }
                    currAccountOwner = own.Id;
                }
            }
        return setAccountOwner;
    }

    public List<SelectOption> getRolesItems() {
        Id currUserRole = null;
            setRoles = new List<SelectOption>();
            setRoles.add(new SelectOption('--None--', 'All'));
            for (User rl : [SELECT UserRoleId, UserRole.Name FROM User WHERE Id IN :finalUserSet Order by UserRole.Name]){
                if (currUserRole <> rl.UserRoleId){
                    setRoles.add(new SelectOption(rl.UserRoleId, rl.UserRole.Name));
                }
                currUserRole = rl.UserRoleId;
            }
        return setRoles;
    }

    public List<SelectOption> getStartsManagerItems() {
            setStartsManager = new List<SelectOption>();
            setStartsManager.add(new SelectOption('--None--', 'All'));
            for (User sm : [SELECT Id, Name FROM User ORDER BY Name, Id]){
                setStartsManager.add(new SelectOption(sm.Id, sm.Name));
            }
        return setStartsManager;
    }

    public List<SelectOption> getOfferItems(){
            setOffer = new List<SelectOption>();
            setOffer.add(new SelectOption('--None--', 'All'));
            Schema.DescribeFieldResult fr = Opportunity.Product__c.getDescribe();
            List<Schema.PicklistEntry> plv = fr.getPicklistValues();

            for (Schema.PicklistEntry f : plv){
                setOffer.add(new SelectOption(f.getValue(), f.getLabel()));
            }
        return setOffer;
    }

    public List<SelectOption> getFirstPumpDateItems(){
            setFirstPumpDate = new List<SelectOption>();
        setFirstPumpDate.add(new SelectOption('--None--', 'All'));
        setFirstPumpDate.add(new SelectOption('null', 'No'));
        setFirstPumpDate.add(new SelectOption('not null', 'Yes'));
        return setFirstPumpDate;
    }

    /*Controller with data from Opportunity*/
    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null){
                size = 200;

                string stringQuery =
                        'SELECT AccountId, Account.Name, Account.BillingCountry, Account.GFN_Nr__c, Sec_Channel__c, ' +
                        'Account.OwnerId, Starts_Rep__c, Starts_Status__c, ' +
                        'Starts_SLA_Expired__c, CloseDate, Starts_Close_Date__c, ' +
                        'Anzahl_der_Karten__c, Starts_Number_of_Cards_Target__c, ' +
                        'Total_consumption_l_month__c, Starts_Fuel_Liters_Per_Mo_Target__c, Product__c, Angebotsdauer__c, Clubsmart__c ';

                stringQuery +=
                        'FROM Opportunity ' +
                        'WHERE (Account.Id <> null AND Account.Name <> null AND CloseDate <> null AND StageName = ' + '\'Closed Won\'' + ') ';

                if (firstPumpDate <> '--None--' && firstPumpDate <> null) {

                    if (firstPumpDate == 'null') {
                        stringQuery +=
                                 'AND AccountId NOT IN (SELECT Account__c FROM Starts__c WHERE client_week_number__c <= 10) ';
                        tquery = 'AND AccountId NOT IN (SELECT Account__c FROM Starts__c WHERE client_week_number__c <= 10) ';
                        System.Debug(tquery);
                    }
                    if (firstPumpDate == 'not null') {
                        stringQuery +=
                                 'AND AccountId IN (SELECT Account__c FROM Starts__c WHERE client_week_number__c <= 10) ';
                        tquery = 'AND AccountId IN (SELECT Account__c FROM Starts__c WHERE client_week_number__c <= 10) ';
                        System.Debug(tquery);
                    }
                }

                if (countries <> '--None--' && countries <> null) {
                    stringQuery += 'AND Account.BillingCountryCode = \'' + countries + '\' ';
                }

                if (secChannel <> '--None--' && secChannel <> null) {
                    stringQuery += 'AND Sec_Channel__c = \'' + secChannel + '\' ';
                }

                if (accountOwner <> '--None--' && accountOwner <> null) {
                    stringQuery += 'AND Account.OwnerId = \'' + accountOwner + '\' ';
                }

                if (role <> '--None--' && role <> null) {
                    changeUserSet = new Set<Id>();
                    changeUserSet.clear();
                    for (User user : [SELECT Id FROM User WHERE UserRoleId = :role]){
                        changeUserSet.add(user.Id);

                    }
                    stringQuery += 'AND Account.OwnerId IN :changeUserSet ';
                } else {
                    stringQuery += 'AND Account.OwnerId IN :finalUserSet ';
                }

                if (startsManager <> '--None--' && startsManager <> null) {
                    stringQuery += 'AND Starts_Rep__c = \'' + startsManager + '\' ';
                }

                if (offer <> '--None--' && offer <> null) {
                    stringQuery += 'AND Product__c = \'' + offer + '\' ';
                }

                if (dateFromOpp <> null) {
                    dateFrom = dateFromOpp.CloseDate;
                    stringQuery += 'AND CloseDate >= :dateFrom ';
                }

                if (dateToOpp <> null) {
                    dateTo = dateToOpp.CloseDate;
                    stringQuery += 'AND CloseDate <= :dateTo ';
                }

                if (UserInfo.getName().contains('Salesteam')) {
                    stringQuery += 'ORDER BY Account.Owner.Name LIMIT 10000';
                }
                else {stringQuery += 'ORDER BY Account.BillingCountry LIMIT 10000';}

                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(stringQuery));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        } set;
    }

    /*List with data from StandardSetController*/
    public List<Opportunity> getOpportunities() {
        this.matchingOpportunities = new List<Opportunity>();
        for (Opportunity op : (List<Opportunity>)setCon.getRecords())
            this.matchingOpportunities.add(op);
        getStartsValues1();
        getTotal();
        getUserRoles();
        return this.matchingOpportunities;
    }

    /*refresh data for filters*/
    public pageReference refresh() {
        setCon = null;
        getOpportunities();
        setCon.setPageNumber(1);
        return null;
    }

    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }

    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }

    public void first() {
        setCon.first();
    }

    public void last() {
        setCon.last();
    }

    public void previous() {
        setCon.previous();
    }

    public void next() {
        setCon.next();
    }

    /*return total row*/
    public void getTotal(){
        this.startsList5 = new Map<Integer, Decimal>();
        this.startsList6 = new Map<Integer, Decimal>();
        Id accountId = null;
        Decimal ns = 0;
        Integer j = 1;
        Integer i = 0;
        Decimal volume1 = 0;
        Decimal volume2 = 0;
        Decimal volume3 = 0;
        Decimal volume4 = 0;
        Decimal volume5 = 0;
        Decimal volume6 = 0;
        Decimal volume7 = 0;
        Decimal volume8 = 0;
        Decimal volume9 = 0;
        Decimal volume10 = 0;
        Decimal netstart1 = 0;
        Decimal netstart2 = 0;
        Decimal netstart3 = 0;
        Decimal netstart4 = 0;
        Decimal netstart5 = 0;
        Decimal netstart6 = 0;
        Decimal netstart7 = 0;
        Decimal netstart8 = 0;
        Decimal netstart9 = 0;
        Decimal netstart10 = 0;
        Decimal startsthis = 0;

        string stringQuery = 'SELECT Account__c, volume__c, starts__c, client_week_number__c FROM Starts__c '+
        'WHERE client_week_number__c <= 10 ' +
        'AND Account__c IN ' +
                '(SELECT AccountId FROM Opportunity ' +
        'WHERE (Account.Id <> null AND Account.Name <> null AND CloseDate <> null AND StageName = ' + '\'Closed Won\'' + ') ';

        if (countries <> '--None--' && countries <> null) {
                stringQuery += 'AND Account.BillingCountryCode = \'' + countries + '\' ';
        }

        if (secChannel <> '--None--' && secChannel <> null) {
                stringQuery += 'AND Sec_Channel__c = \'' + secChannel + '\' ';
        }

        if (accountOwner <> '--None--' && accountOwner <> null) {
            stringQuery += 'AND Account.OwnerId = \'' + accountOwner + '\' ';
        }

        if (role <> '--None--' && role <> null) {
            changeUserSet = new Set<Id>();
            changeUserSet.clear();
            for (User user : [SELECT Id FROM User WHERE UserRoleId = :role]){
                changeUserSet.add(user.Id);

            }
            stringQuery += 'AND Account.OwnerId IN :changeUserSet ';
        } else {
            stringQuery += 'AND Account.OwnerId IN :finalUserSet ';
        }

        if (startsManager <> '--None--' && startsManager <> null) {
            stringQuery += 'AND Starts_Rep__c = \'' + startsManager + '\' ';
        }

        if (offer <> '--None--' && offer <> null) {
            stringQuery += 'AND Product__c = \'' + offer + '\' ';
        }

        if (dateFromOpp <> null) {
            dateFrom = dateFromOpp.CloseDate;
            stringQuery += 'AND CloseDate >= :dateFrom ';
        }

        if (dateToOpp <> null) {
            dateTo = dateToOpp.CloseDate;
            stringQuery += 'AND CloseDate <= :dateTo ';
        }

        if (firstPumpDate <> '--None--' && firstPumpDate <> null) {
            if (firstPumpDate == 'null') {
                stringQuery +=
                         'AND Id = null ';
                tquery = 'AND Id = null ';
                System.Debug(tquery);
            }
            if (firstPumpDate == 'not null') {
                stringQuery +=
                         'AND Id <> null ';
                tquery = 'AND Id <> null ';
                System.Debug(tquery);
            }
        }

        stringQuery += ') ORDER BY Account__c, client_week_number__c';

        System.Debug(stringQuery);

        if ((countries <> '--None--' && countries <> null) || (secChannel <> '--None--' && secChannel <> null) ||
        (accountOwner <> '--None--' && accountOwner <> null) || (role <> '--None--' && role <> null) ||
        (startsManager <> '--None--' && startsManager <> null) || (offer <> '--None--' && offer <> null) ||
        (dateFromOpp <> null) || (dateToOpp <> null)) {
            List<Starts__c> listStarts = Database.query(stringQuery);
            Starts__c starts = new Starts__c();

            do {
                if (listStarts.size() > 0) {
                    starts = listStarts.get(i);
                    
                    if (starts.starts__c == null) {
                        startsthis = 0;
                    }
                    else {
                        startsthis = starts.starts__c;
                    }
                    
                    if (accountId <> starts.Account__c) {
                        accountId = starts.Account__c;
                        ns = 0;
                    }
                    if (starts.client_week_number__c.intValue() == 1) {
                        volume1 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart1 += startsthis - ns.setScale(2);
                        } else {
                            netstart1 += 0;
                        }
                    }
                    if (starts.client_week_number__c.intValue() == 2) {
                        volume2 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart2 += startsthis - ns.setScale(2);
                        } else {
                            netstart2 += 0;
                        }
                    }
                    if (starts.client_week_number__c.intValue() == 3) {
                        volume3 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart3 += startsthis - ns.setScale(2);
                        } else {
                            netstart3 += 0;
                        }
                    }
                    if (starts.client_week_number__c.intValue() == 4) {
                        volume4 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart4 += startsthis - ns.setScale(2);
                        } else {
                            netstart4 += 0;
                        }
                    }
                    if (starts.client_week_number__c.intValue() == 5) {
                        volume5 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart5 += startsthis - ns.setScale(2);
                        } else {
                            netstart5 += 0;
                        }
                    }
                    if (starts.client_week_number__c.intValue() == 6) {
                        volume6 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart6 += startsthis - ns.setScale(2);
                        } else {
                            netstart6 += 0;
                        }
                    }
                    if (starts.client_week_number__c.intValue() == 7) {
                        volume7 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart7 += startsthis - ns.setScale(2);
                        } else {
                            netstart7 += 0;
                        }
                    }
                    if (starts.client_week_number__c.intValue() == 8) {
                        volume8 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart8 += startsthis - ns.setScale(2);
                        } else {
                            netstart8 += 0;
                        }
                    }
                    if (starts.client_week_number__c.intValue() == 9) {
                        volume9 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart9 += startsthis - ns.setScale(2);
                        } else {
                            netstart9 += 0;
                        }
                    }
                    if (starts.client_week_number__c.intValue() == 10) {
                        volume10 += starts.volume__c;
                        if (starts.starts__c != null) {
                            netstart10 += startsthis - ns.setScale(2);
                        } else {
                            netstart10 += 0;
                        }
                    }

                    ns = startsthis;
                    i += 1;
                }
            } while (i <= listStarts.size() - 1);
        }

        startsList5.put(1, volume1);
        startsList5.put(2, volume2);
        startsList5.put(3, volume3);
        startsList5.put(4, volume4);
        startsList5.put(5, volume5);
        startsList5.put(6, volume6);
        startsList5.put(7, volume7);
        startsList5.put(8, volume8);
        startsList5.put(9, volume9);
        startsList5.put(10, volume10);

        startsList6.put(1, netstart1.setScale(2));
        startsList6.put(2, netstart2.setScale(2));
        startsList6.put(3, netstart3.setScale(2));
        startsList6.put(4, netstart4.setScale(2));
        startsList6.put(5, netstart5.setScale(2));
        startsList6.put(6, netstart6.setScale(2));
        startsList6.put(7, netstart7.setScale(2));
        startsList6.put(8, netstart8.setScale(2));
        startsList6.put(9, netstart9.setScale(2));
        startsList6.put(10, netstart10.setScale(2));

        totalNetStarts = netstart1.setScale(2) + netstart2.setScale(2) + netstart3.setScale(2) + netstart4.setScale(2) + netstart5.setScale(2) +
                netstart6.setScale(2) + netstart7.setScale(2) + netstart8.setScale(2) + netstart9.setScale(2) + netstart10.setScale(2);
    }

    /*return data : volume and netstarts*/
    public void getStartsValues1(){
        this.startsList1 = new Map<Id, Map<Integer, Decimal>>();
        this.startsList2 = new Map<Id, Map<Integer, Decimal>>();
        this.startsList3 = new Map<Id, String>();
        this.startsList4 = new Map<Id, Decimal>();
        Map<Integer, Decimal> tMapVolume = new Map<Integer, Decimal>();
        Map<Integer, Decimal> tMapStarts = new Map<Integer, Decimal>();
        Starts__c cur_row = new Starts__c();
        Starts__c prev_row = new Starts__c();
        Set<Id> accId = new Set<Id>();
        Id accountId = null;
        Integer j = 1;
        Integer i = 0;
        Decimal ns = 0;
        Decimal sumns = 0;
        String dt = null;
        Integer cwn = 0;
        Decimal startsthis = 0;

        for (Opportunity opp : this.matchingOpportunities) {
            if (opp.AccountId <> null) {
                accId.add(opp.AccountId);
            }
        }

        List<Starts__c> startsListT = [SELECT Account__c, client_week_number__c, volume__c, starts__c, First_Pump_Date__c FROM Starts__c
                WHERE Account__c IN :accId AND client_week_number__c <= 10 ORDER BY Account__c, client_week_number__c];
        for (Starts__c s : startsListT) {
            if (s.starts__c == null) {
                startsthis = 0;
            }
            else {
                startsthis = s.starts__c;
            }
            
            if (s.First_Pump_Date__c <> null) {
                dt = s.First_Pump_Date__c.format();
            }
            else dt = '--------';
            i++;

            if (i == 1) {
                accountId = s.Account__c;
            }

            if (accountId == s.Account__c) {

                tMapVolume.put(s.client_week_number__c.intValue(), s.volume__c);
                if (s.client_week_number__c.intValue() - 1 == cwn) {
                    if (s.starts__c != null) {
                        tMapStarts.put(s.client_week_number__c.intValue(), (startsthis - ns).setScale(2));
                        sumns = sumns + (startsthis - ns);
                    } else {
                        tMapStarts.put(s.client_week_number__c.intValue(), (0.0).setScale(2));
                        //sumns = sumns + (startsthis - ns);
                    }
                } else {tMapStarts.put(s.client_week_number__c.intValue(), startsthis.setScale(2));
                    sumns = sumns + (startsthis);
                }

                if (i == startsListT.size()) {
                    for (Integer k = 1; k <= 10; k++) {
                        if (!tMapVolume.containsKey(k)) {
                            tMapVolume.put(k, 0);
                        }
                        if (!tMapStarts.containsKey(k)) {
                            tMapStarts.put(k, 0);
                        }
                    }
                    startsList1.put(accountId, new Map<Integer, Decimal>(tMapVolume));
                    startsList2.put(accountId, new Map<Integer, Decimal>(tMapStarts));
                    startsList4.put(accountId, sumns.setScale(2));
                }
            }

            if (accountId <> s.Account__c) {
                for (Integer k = 1; k <= 10; k++) {
                    if (!tMapVolume.containsKey(k)) {
                        tMapVolume.put(k, 0);
                    }
                    if (!tMapStarts.containsKey(k)) {
                        tMapStarts.put(k, 0);
                    }
                }
                startsList1.put(accountId, new Map<Integer, Decimal>(tMapVolume));
                startsList2.put(accountId, new Map<Integer, Decimal>(tMapStarts));
                startsList4.put(accountId, sumns.setScale(2));
                tMapVolume.clear();
                tMapStarts.clear();
                sumns = 0;
                ns = 0;

                tMapVolume.put(s.client_week_number__c.intValue(), s.volume__c);
                if (s.client_week_number__c.intValue() - 1 == cwn) {
                    tMapStarts.put(s.client_week_number__c.intValue(), (startsthis - ns).setScale(2));
                    sumns = sumns + (startsthis - ns);
                } else {tMapStarts.put(s.client_week_number__c.intValue(), startsthis.setScale(2));
                    sumns = sumns + (startsthis);
                }

                if (i == startsListT.size()) {
                    for (Integer k = 1; k <= 10; k++) {
                        if (!tMapVolume.containsKey(k)) {
                            tMapVolume.put(k, 0);
                        }
                        if (!tMapStarts.containsKey(k)) {
                            tMapStarts.put(k, 0);
                        }
                    }
                    startsList1.put(s.Account__c, new Map<Integer, Decimal>(tMapVolume));
                    startsList2.put(s.Account__c, new Map<Integer, Decimal>(tMapStarts));
                    startsList4.put(s.Account__c, sumns.setScale(2));
                }
            }

            ns = startsthis;
            cwn = s.client_week_number__c.intValue();
            accountId = s.Account__c;
            startsList3.put(s.Account__c, dt);
        }

        for (Id id : accId) {
            if (!startsList1.containsKey(id)){
                tMapVolume.clear();
                tMapStarts.clear();
                tMapVolume.put(1, 0);
                tMapStarts.put(1, 0);
                tMapVolume.put(2, 0);
                tMapStarts.put(2, 0);
                tMapVolume.put(3, 0);
                tMapStarts.put(3, 0);
                tMapVolume.put(4, 0);
                tMapStarts.put(4, 0);
                tMapVolume.put(5, 0);
                tMapStarts.put(5, 0);
                tMapVolume.put(6, 0);
                tMapStarts.put(6, 0);
                tMapVolume.put(7, 0);
                tMapStarts.put(7, 0);
                tMapVolume.put(8, 0);
                tMapStarts.put(8, 0);
                tMapVolume.put(9, 0);
                tMapStarts.put(9, 0);
                tMapVolume.put(10, 0);
                tMapStarts.put(10, 0);
                startsList1.put(id, tMapVolume);
                startsList2.put(id, tMapStarts);
                startsList3.put(id, '---------');
                startsList4.put(id, 0);
            }
        }
    }

    /*return data : userrole*/
    private void getUserRoles(){
        Set<Id> roles = new Set<Id>();
        for (Opportunity opp : this.matchingOpportunities) {
            roles.add(opp.Account.OwnerId);
        }

        List<User> userList = [SELECT Id, Name, UserRole.Name FROM User WHERE Id IN :roles];
        this.userMap = new Map<Id, User>();
        for (User ul : userList){
            this.userMap.put(ul.Id, ul);
        }
    }
}