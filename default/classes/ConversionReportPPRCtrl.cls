public with sharing class ConversionReportPPRCtrl {
    public Id userRoleId;
    private Set<Id> finalUserSet {get; set;}
    public Set<Id> leadSet {get; set;}
    public Set<Id> opportunitySet {get; set;}
    public Map<Id, OutputMapClass> outputMap {get; set;}
    public List<OutputMapClass> outputList {get; set;}
    public List<OutputMapClassText> outputListText {get; set;}

    public List<SelectOption> setFCPeriod {get; set;}
    public List<SelectOption> setReportMonth {get; set;}
    public List<SelectOption> setSalesGroup {get; set;}
    public List<SelectOption> setReportType {get; set;}

    public String salesGroup {get; set;}

    public String periodFC {get; set;}
    public Date dFCBeg {get; set;}
    public Date dFCEnd {get; set;}
    public Datetime dtFCBeg {get; set;}
    public Datetime dtFCEnd {get; set;}

    public String monthReport {get; set;}
    public Date dBegMonth {get; set;}
    public Date dEndMonth {get; set;}
    public Datetime dtBegMonth {get; set;}
    public Datetime dtEndMonth {get; set;}

    public String reportType {get; set;}

    private List<Date> holidaysList {get; set;}

    public String mode {get; set;} // Mode for send or not source data to admin users, send or nosend
    public Map<Id, ClassForUpload> uploadListAssignment {get; set;}

    public class LeadOpportunityClass {
        public String typeObject {get; set;}
        public String logicTypeObject {get; set;}
        public Id leadId {get; set;}
        public Id opportunityId {get; set;}
        public Id ownerId {get; set;}
        public Id leadOwnerId {get; set;}
        public Date ownDate {get; set;}  // Дата назначения
        public String stageName {get; set;}
        public Date closeDate {get; set;}
    }

    public class ClassForUpload {
        public Id oppId { get; set;}
        public String ownerId { get; set;}
        public Date assignmentDate { get; set;}
        public Date closeDate { get; set;}
    }

    /*******************************************************************************
    *  Name            : getFCPeriodItems()
    *  Summary         : get list of periods for picklist
    *  CreatedDate     : 16/01/2018
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getFCPeriodItems() {
        String period = '';
        setFCPeriod = new List<SelectOption>();
        for (Fleetcor_Calendar_Month__c periodList : [SELECT Start_Date__c, End_Date__c
        FROM Fleetcor_Calendar_Month__c
        WHERE (Start_Date__c > :date.today().addMonths(-4) AND Start_Date__c < :date.today())
        ORDER BY Start_Date__c]){

            period = periodList.Start_Date__c.format() + ' - ' + periodList.End_Date__c.format();
            setFCPeriod.add(new SelectOption(periodList.Start_Date__c.format(), period));
        }
        return setFCPeriod;
    }

    /*******************************************************************************
    *  Name            : getReportMonth()
    *  Summary         : get list of report months for picklist
    *  CreatedDate     : 16/01/2018
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getReportMonth() {
        Date dateFiscal = date.today().addMonths(-3);
        String monthYear = '';
        Date firstDayMonth = null;
        setReportMonth = new List<SelectOption>();
        for (Fleetcor_Calendar_Month__c reportMonth : [SELECT End_Date__c, Month_Number__c FROM Fleetcor_Calendar_Month__c WHERE Start_Date__c >= :dateFiscal]) {
            monthYear = reportMonth.End_Date__c.month() + '/' + reportMonth.End_Date__c.year();
            firstDayMonth = Date.valueOf(reportMonth.End_Date__c.year() + '-' + reportMonth.End_Date__c.month() + '-' + '01');
            setReportMonth.add(new SelectOption(firstDayMonth.format(), monthYear));
        }
        return setReportMonth;
    }

    /*******************************************************************************
    *  Name            : getSalesGroupItems()
    *  Summary         : get list of group of sales for picklist
    *  CreatedDate     : 16/01/2018
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getSalesGroupItems() {
        setSalesGroup = new List<SelectOption>();
        setSalesGroup.add(new SelectOption('None', 'None'));
        for (UserRole userRole : [SELECT Id, Name FROM UserRole
        WHERE (Name LIKE '%Bryansk PSO%' OR Name LIKE '%Bryansk Partner%') AND Id IN (SELECT UserRoleId FROM User WHERE Id IN :finalUserSet)
        ORDER BY Name]) {
            setSalesGroup.add(new SelectOption(userRole.Id, userRole.Name));
        }
        return setSalesGroup;
    }

    /*******************************************************************************
    *  Name            : getReportTypeItems()
    *  Summary         : get list of type of report for picklist
    *  CreatedDate     : 16/01/2018
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getReportTypeItems() {
        setReportType = new List<SelectOption>();
        setReportType.add(new SelectOption('current', 'Текущий'));
        setReportType.add(new SelectOption('final', 'Итоговый'));
        return setReportType;
    }

    /*******************************************************************************
    *  Name            : getUser()
    *  Summary         : Return current user with subordinate
    *  CreatedDate     : 16/01/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getUser() {
        userRoleId = UserInfo.getUserRoleId();
        Integer childSize = 1;
        Set<Id> parentRoleSet = new Set<Id>();
        Set<Id> parentRoleTemp = new Set<Id>();

        Set<Id> finalRoleSet = new Set<Id>();
        finalRoleSet.add(userRoleId);
        parentRoleTemp.add(userRoleId);

        do {
            for (UserRole childRole : [SELECT Id
                FROM UserRole
                WHERE ParentRoleId IN :parentRoleTemp AND (NOT Name LIKE '%Call%')
            ]){
                if (childRole.Id <> null) {
                    finalRoleSet.add(childRole.Id);
                    parentRoleSet.add(childRole.Id);
                }
            }
            parentRoleTemp.clear();
            if (parentRoleSet.size() > 0) {
                parentRoleTemp.addAll(parentRoleSet);
            } else {
                childSize = 0;
            }

            parentRoleSet.clear();
        } while (childSize != 0);

        finalUserSet = new Set<Id>();
        for (User roles : [SELECT Id FROM User WHERE UserRole.Id IN : finalRoleSet]){
            finalUserSet.add(roles.Id);
        }
    }

    /*******************************************************************************
    *  Name            : getFCDates()
    *  Summary         : convert date to datetime
    *  CreatedDate     : 16/01/2018
    *  Parameters      : String datetype
    *  Returns         : -
    ******************************************************************************/
    private void getFCDates(String datetype) {
        Date endDateTemp = Date.parse(periodFC);
        List<Fleetcor_Calendar_Month__c> endDateList = new List<Fleetcor_Calendar_Month__c>([SELECT Start_Date__c, End_Date__c FROM Fleetcor_Calendar_Month__c WHERE Start_Date__c = :endDateTemp LIMIT 1]);
        if (datetype == 'date') {
            dFCBeg = endDateList.get(0).Start_Date__c;
            dFCEnd = endDateList.get(0).End_Date__c;
        }
        if (datetype == 'datetime') {
            dtFCBeg = Datetime.newInstance(endDateList.get(0).Start_Date__c.year(),
                    endDateList.get(0).Start_Date__c.month(),
                    endDateList.get(0).Start_Date__c.day()
            );
            dtFCEnd = Datetime.newInstance(endDateList.get(0).End_Date__c.year(),
                    endDateList.get(0).End_Date__c.month(),
                    endDateList.get(0).End_Date__c.day()
            );
        }
    }

    /*******************************************************************************
    *  Name            : getReportMonthDates()
    *  Summary         : convert string to date and datetime
    *  CreatedDate     : 16/01/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getReportMonthDates() {
        dBegMonth = Date.parse(monthReport);
        dtBegMonth = Datetime.newInstance(dBegMonth.year(), dBegMonth.month(), dBegMonth.day());
        dEndMonth = Date.newInstance(dBegMonth.year(), dBegMonth.month(), Date.daysInMonth(dBegMonth.year(), dBegMonth.month()));
        dtEndMonth = Datetime.newInstance(dBegMonth.year(), dBegMonth.month(), Date.daysInMonth(dBegMonth.year(), dBegMonth.month()));
    }

    /*******************************************************************************
    *  Name            : getHolidays()
    *  Summary         : get holiday days
    *  CreatedDate     : 16/01/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getHolidays() {
        Integer diffDays = 0;
        holidaysList = new List<Date>();
        for (Holiday hol : [SELECT ActivityDate FROM Holiday WHERE ActivityDate >= :dFCBeg AND ActivityDate <= :dFCEnd AND Name LIKE 'RU%']) {
            diffDays = date.newInstance(1900, 1, 7).daysBetween(hol.ActivityDate);
            if (math.mod(diffDays, 7) != 0)
                holidaysList.add(hol.ActivityDate);
        }
    }

    /*******************************************************************************
    *  Name            : getLeadData()
    *  Summary         : get data of leads
    *  CreatedDate     : 16/01/2018
    *  Parameters      : Map<Id, LeadOpportunityClass> pLeadOpportunityMap, String roleName
    *  Returns         : Map<Id, LeadOpportunityClass>
    ******************************************************************************/
    public Map<Id, LeadOpportunityClass> getLeadData(Map<Id, LeadOpportunityClass> pLeadOpportunityMap, String roleName, Set<Id> convertedOpportunitySet) {
        Date ownDate = null;
        Id leadOpportunityId = null;
        leadSet = new Set<Id>();

        if (roleName.contains('PSO 3')) {
            for (Lead lead : [SELECT OwnerId, CreatedDate, Day_transfer__c, LastTransferDate, ConvertedOpportunityId
            FROM Lead
            WHERE (Status != 'Disqualified' AND Source_of_Lead__c IN ('Сайт Petrolplus.ru', 'Petrolcards.ru - АГГРЕГАТОР', 'Сайт Petrolplus.kz'))
            AND OwnerId IN (SELECT Id FROM User WHERE UserRoleId = :salesGroup)
            AND (LastTransferDate >= :dFCBeg AND LastTransferDate <= :dFCEnd)
            ORDER BY OwnerId LIMIT 10000]) {

                LeadOpportunityClass leadOpportunityObject = new LeadOpportunityClass();

                if (lead.ConvertedOpportunityId != null) {
                    convertedOpportunitySet.add(lead.ConvertedOpportunityId);
                }

                if (lead.Day_transfer__c != null) {
                    ownDate = lead.Day_transfer__c;
                } else {
                    ownDate = lead.LastTransferDate;
                }

                if (lead.ConvertedOpportunityId != null) {
                    leadOpportunityId = lead.ConvertedOpportunityId;
                } else {
                    leadOpportunityId = lead.Id;
                }

                leadOpportunityObject.typeObject = 'Lead';
                leadOpportunityObject.leadId = lead.Id;
                leadOpportunityObject.opportunityId = lead.ConvertedOpportunityId;
                leadOpportunityObject.ownerId = lead.OwnerId;
                leadOpportunityObject.leadOwnerId = lead.OwnerId;
                leadOpportunityObject.ownDate = ownDate;
                leadOpportunityObject.stageName = null;
                leadOpportunityObject.closeDate = null;
                pLeadOpportunityMap.put(leadOpportunityId, leadOpportunityObject);

                leadSet.add(lead.Id);
            }
        } else {
            for (Lead lead : [SELECT OwnerId, CreatedDate, Day_transfer__c, LastTransferDate, ConvertedOpportunityId
            FROM Lead
            WHERE ((Status = 'Disqualified' AND Lead_Status_Specific__c NOT IN ('Дубликат', 'Существующий клиент', 'Existing Customer', 'Нет автопарка',
                    'No Company Vehicles', 'Not a Valid Business', 'Out of Business', 'Банкрот', 'Недостижимо', 'Unable to Reach', 
                    'Некорректная контактная информация', 'Возврат в воронку', 'Повторная заявка', 'СТК - терминал', 'Email SPAM', 
                    'Тест', 'Re-request', 'Bad Data/Wrong Phone Number', 'Return to funnel', 'STK - terminal'))
            OR (Status != 'Disqualified')
            OR (Status = 'Disqualified' AND  Source_of_Lead__c IN ('Сайт Petrolplus.ru', 'Petrolcards.ru - АГГРЕГАТОР', 'Сайт Petrolplus.kz')))
            AND OwnerId IN (SELECT Id FROM User WHERE UserRoleId = :salesGroup)
            AND (LastTransferDate >= :dFCBeg AND LastTransferDate <= :dFCEnd)
            ORDER BY OwnerId LIMIT 10000]) {
                LeadOpportunityClass leadOpportunityObject = new LeadOpportunityClass();

                if (lead.ConvertedOpportunityId != null) {
                    convertedOpportunitySet.add(lead.ConvertedOpportunityId);
                }

                if (lead.Day_transfer__c != null) {
                    ownDate = lead.Day_transfer__c;
                } else {
                    ownDate = lead.LastTransferDate;
                }

                if (lead.ConvertedOpportunityId != null) {
                    leadOpportunityId = lead.ConvertedOpportunityId;
                } else {
                    leadOpportunityId = lead.Id;
                }

                leadOpportunityObject.typeObject = 'Lead';
                leadOpportunityObject.leadId = lead.Id;
                leadOpportunityObject.opportunityId = lead.ConvertedOpportunityId;
                leadOpportunityObject.ownerId = lead.OwnerId;
                leadOpportunityObject.leadOwnerId = lead.OwnerId;
                leadOpportunityObject.ownDate = ownDate;
                leadOpportunityObject.stageName = null;
                leadOpportunityObject.closeDate = null;
                pLeadOpportunityMap.put(leadOpportunityId, leadOpportunityObject);

                leadSet.add(lead.Id);
            }
        }
        return pLeadOpportunityMap;
    }

    /*******************************************************************************
    *  Name            : getLeadDataAdd()
    *  Summary         : get data of leads for total report
    *  CreatedDate     : 16/01/2018
    *  Parameters      : Map<Id, LeadOpportunityClass> pLeadOpportunityMap, String roleName
    *  Returns         : Map<Id, LeadOpportunityClass>
    ******************************************************************************/
    public Map<Id, LeadOpportunityClass> getLeadDataAdd(Map<Id, LeadOpportunityClass> pLeadOpportunityMap, String roleName, Set<Id> convertedOpportunitySet) {
        Set<Id> setUser = new Set<Id>();
        for (User listUser : [SELECT Id FROM User WHERE UserRoleId = :salesGroup]) {
            setUser.add(listUser.Id);
        }

        Id leadOpportunityId = null;
        Date prevDate, currDate = null;
        Id prevOwner = null;
        Id prevLead = null;
        Id prevLeadId = null;

        Integer etap = 1;
        Integer i = 0;

        if (roleName.contains('PSO 3')) {
            for (LeadHistory leadHistory : [
                    SELECT Id, CreatedDate, NewValue, OldValue, LeadId, Lead.Name, Lead.OwnerId, Lead.ConvertedOpportunityId
                    FROM LeadHistory
                    WHERE Field = 'Owner' AND CreatedDate >= :dtFCBeg
                    AND CreatedDate <= :dtFCEnd
                    AND LeadId IN (
                            SELECT Id
                            FROM Lead
                            WHERE OwnerId IN :setUser
                            AND Status != 'Disqualified'
                            AND Source_of_Lead__c IN ('Сайт Petrolplus.ru', 'Petrolcards.ru - АГГРЕГАТОР', 'Сайт Petrolplus.kz')
                    )
                    ORDER BY LeadId, CreatedDate
                    LIMIT 10000
            ]) {
                if(leadHistory.NewValue instanceof Id) {
                    if (etap == 1) {
                        prevOwner = (Id)leadHistory.NewValue;
                        prevDate = date.newInstance(leadHistory.CreatedDate.year(), leadHistory.CreatedDate.month(), leadHistory.CreatedDate.day());
                        prevLeadId = leadHistory.LeadId;
                    }

                    if (etap == 2) {
                        currDate = date.newInstance(leadHistory.CreatedDate.year(), leadHistory.CreatedDate.month(), leadHistory.CreatedDate.day());
                        if (leadHistory.OldValue == prevOwner && leadHistory.LeadId == prevLeadId && currDate.daysBetween(prevDate) > 30) {
                            LeadOpportunityClass leadOpportunityObject = new LeadOpportunityClass();

                            if (leadHistory.Lead.ConvertedOpportunityId != null) {
                                convertedOpportunitySet.add(leadHistory.Lead.ConvertedOpportunityId);
                            }

                            if (lead.ConvertedOpportunityId != null) {
                                leadOpportunityId = leadHistory.Lead.ConvertedOpportunityId;
                            } else {
                                leadOpportunityId = leadHistory.Lead.Id;
                            }

                            leadOpportunityObject.typeObject = 'Lead';
                            leadOpportunityObject.leadId = leadHistory.Lead.Id;
                            leadOpportunityObject.opportunityId = leadHistory.Lead.ConvertedOpportunityId;
                            leadOpportunityObject.ownerId = leadHistory.Lead.OwnerId;
                            leadOpportunityObject.leadOwnerId = leadHistory.Lead.OwnerId;
                            leadOpportunityObject.ownDate = prevDate;
                            leadOpportunityObject.stageName = null;
                            leadOpportunityObject.closeDate = null;
                            pLeadOpportunityMap.put(leadOpportunityId, leadOpportunityObject);
                        }
                    }
                    etap =+ 1;
                }
            }
        }
        else {
            for (LeadHistory leadHistory : [
                    SELECT Id, CreatedDate, NewValue, OldValue, LeadId, Lead.Name, Lead.OwnerId, Lead.Day_transfer__c, Lead.LastTransferDate, Lead.ConvertedOpportunityId
                    FROM LeadHistory
                    WHERE Field = 'Owner' AND CreatedDate >= :dtFCBeg
                    AND CreatedDate <= :dtFCEnd
                    AND LeadId IN (
                            SELECT Id
                            FROM Lead
                            WHERE OwnerId IN :setUser
                            AND ((Status = 'Disqualified' AND Lead_Status_Specific__c NOT IN ('Дубликат', 'Существующий клиент', 'Existing Customer', 'Нет автопарка',
                                    'No Company Vehicles', 'Not a Valid Business', 'Out of Business', 'Банкрот', 'Недостижимо', 'Unable to Reach', 
                                    'Некорректная контактная информация', 'Возврат в воронку', 'Повторная заявка', 'СТК - терминал', 'Email SPAM', 
                                    'Тест', 'Re-request', 'Bad Data/Wrong Phone Number', 'Return to funnel', 'STK - terminal'))
                            OR (Status != 'Disqualified'))
                    )
                    ORDER BY LeadId, CreatedDate
                    LIMIT 10000
            ]) {
                if (leadHistory.NewValue instanceof Id) {
                    if (etap == 1) {
                        prevOwner = (Id) leadHistory.NewValue;
                        prevDate = date.newInstance(leadHistory.CreatedDate.year(), leadHistory.CreatedDate.month(), leadHistory.CreatedDate.day());
                        prevLeadId = leadHistory.LeadId;
                    }

                    if (etap == 2) {
                        currDate = date.newInstance(leadHistory.CreatedDate.year(), leadHistory.CreatedDate.month(), leadHistory.CreatedDate.day());
                        if (leadHistory.OldValue == prevOwner && leadHistory.LeadId == prevLeadId && currDate.daysBetween(prevDate) > 30) {
                            LeadOpportunityClass leadOpportunityObject = new LeadOpportunityClass();

                            if (leadHistory.Lead.ConvertedOpportunityId != null) {
                                convertedOpportunitySet.add(leadHistory.Lead.ConvertedOpportunityId);
                            }

                            if (lead.ConvertedOpportunityId != null) {
                                leadOpportunityId = leadHistory.Lead.ConvertedOpportunityId;
                            } else {
                                leadOpportunityId = leadHistory.Lead.Id;
                            }

                            leadOpportunityObject.typeObject = 'Lead';
                            leadOpportunityObject.leadId = leadHistory.Lead.Id;
                            leadOpportunityObject.opportunityId = leadHistory.Lead.ConvertedOpportunityId;
                            leadOpportunityObject.ownerId = leadHistory.Lead.OwnerId;
                            leadOpportunityObject.leadOwnerId = leadHistory.Lead.OwnerId;
                            leadOpportunityObject.ownDate = prevDate;
                            leadOpportunityObject.stageName = null;
                            leadOpportunityObject.closeDate = null;
                            pLeadOpportunityMap.put(leadOpportunityId, leadOpportunityObject);
                        }
                    }
                    etap = +1;
                }
            }
            i += 1;
        }
        return pLeadOpportunityMap;
    }

    /*******************************************************************************
    *  Name            : getOpportunityData()
    *  Summary         : get data of opportunities
    *  CreatedDate     : 16/01/2018
    *  Parameters      : Map<Id, LeadOpportunityClass> pLeadOpportunityMap, String roleName
    *  Returns         : Map<Id, LeadOpportunityClass>
    ******************************************************************************/
    public Map<Id, LeadOpportunityClass> getOpportunityData(Map<Id, LeadOpportunityClass> pLeadOpportunityMap,
                                                            String roleName,
                                                            Set<Id> convertedOpportunitySet,
                                                            Set<Id> noconvertedOpportunitySet) {
        Date dateOwn = null;
        opportunitySet = new Set<Id>();

        if (roleName.contains('PSO 3')) {
            for (Opportunity allopp : [SELECT Id, OwnerId, Last_Owner_Change_Date_RUS__c, StageName, CloseDate, CreatedById, CreatedDate
                FROM Opportunity
                WHERE (Last_Owner_Change_Date_RUS__c >= :this.dtFCBeg
                AND Last_Owner_Change_Date_RUS__c <= :this.dtFCEnd)
                AND OwnerId IN (SELECT Id FROM User WHERE UserRoleId = :salesGroup)
                AND Source_of_Lead_o__c IN ('Сайт Petrolplus.ru', 'Petrolcards.ru - АГГРЕГАТОР', 'Сайт Petrolplus.kz')
                LIMIT 5000]
            ) {
                dateOwn = date.newInstance(allopp.Last_Owner_Change_Date_RUS__c.year(), allopp.Last_Owner_Change_Date_RUS__c.month(), allopp.Last_Owner_Change_Date_RUS__c.day());

                if (convertedOpportunitySet.contains(allopp.Id)) {
                    pLeadOpportunityMap.get(allopp.Id).ownDate = dateOwn;
                    pLeadOpportunityMap.get(allopp.Id).ownerId = allopp.OwnerId;
                    pLeadOpportunityMap.get(allopp.Id).stageName = allopp.StageName;
                    pLeadOpportunityMap.get(allopp.Id).closeDate = allopp.CloseDate;
                    pLeadOpportunityMap.get(allopp.Id).logicTypeObject = 'Opportunity';
                } else {
                    LeadOpportunityClass leadOpportunityObject = new LeadOpportunityClass();
                    leadOpportunityObject.typeObject = 'Lead';
                    leadOpportunityObject.leadId = null;
                    leadOpportunityObject.opportunityId = allopp.Id;
                    leadOpportunityObject.ownerId = allopp.OwnerId;
                    leadOpportunityObject.ownDate = dateOwn;
                    leadOpportunityObject.stageName = allopp.StageName;
                    leadOpportunityObject.closeDate = allopp.CloseDate;

                    pLeadOpportunityMap.put(allopp.Id, leadOpportunityObject);
                    noconvertedOpportunitySet.add(allopp.Id);
                }

                opportunitySet.add(allopp.Id);
            }
        } else {
            for (Opportunity allopp : [SELECT Id, OwnerId, Last_Owner_Change_Date_RUS__c, StageName, CloseDate, CreatedById, CreatedDate
                FROM Opportunity
                WHERE ((Last_Owner_Change_Date_RUS__c >= :this.dtFCBeg
                AND Last_Owner_Change_Date_RUS__c <= :this.dtFCEnd)
                OR (Date_of_last_change_of_stage__c >= :dtFCBeg.date() AND Date_of_last_change_of_stage__c <= :dtFCEnd.date()))
                AND OwnerId IN (SELECT Id FROM User WHERE UserRoleId = :salesGroup)
                LIMIT 5000]
            ) {
                dateOwn = date.newInstance(allopp.Last_Owner_Change_Date_RUS__c.year(), allopp.Last_Owner_Change_Date_RUS__c.month(), allopp.Last_Owner_Change_Date_RUS__c.day());

                if (convertedOpportunitySet.contains(allopp.Id)) {
                    pLeadOpportunityMap.get(allopp.Id).ownDate = dateOwn;
                    pLeadOpportunityMap.get(allopp.Id).ownerId = allopp.OwnerId;
                    pLeadOpportunityMap.get(allopp.Id).stageName = allopp.StageName;
                    pLeadOpportunityMap.get(allopp.Id).closeDate = allopp.CloseDate;
                    pLeadOpportunityMap.get(allopp.Id).logicTypeObject = 'Opportunity';
                } else
                {
                    LeadOpportunityClass leadOpportunityObject = new LeadOpportunityClass();
                    leadOpportunityObject.typeObject = 'Lead';
                    leadOpportunityObject.leadId = null;
                    leadOpportunityObject.opportunityId = allopp.Id;
                    leadOpportunityObject.ownerId = allopp.OwnerId;
                    leadOpportunityObject.ownDate = dateOwn;
                    leadOpportunityObject.stageName = allopp.StageName;
                    leadOpportunityObject.closeDate = allopp.CloseDate;

                    pLeadOpportunityMap.put(allopp.Id, leadOpportunityObject);
                    noconvertedOpportunitySet.add(allopp.Id);
                }
                opportunitySet.add(allopp.Id);
            }
        }
        return pLeadOpportunityMap;
    }

    public Map<Id, LeadOpportunityClass> getOpportunityDataAdd(Map<Id, LeadOpportunityClass> pLeadOpportunityMap,
                                                               String roleName,
                                                               Set<Id> convertedOpportunitySet,
                                                               Set<Id> noconvertedOpportunitySet) {
        Set<Id> setUser = new Set<Id>();
        for (User listUser : [SELECT Id FROM User WHERE UserRoleId = :salesGroup]) {
            setUser.add(listUser.Id);
        }

        Id leadOpportunityId = null;
        Date prevDate, currDate = null;
        Id prevOwner = null;
        Id prevLead = null;

        Integer etap = 1;

        if (roleName.contains('PSO 3')) {
            for (OpportunityFieldHistory opportunityHistory : [SELECT Id, OpportunityId, CreatedById, CreatedDate, NewValue, OldValue, Opportunity.OwnerId, Opportunity.StageName,
                                                                        Opportunity.CloseDate
                                                                FROM OpportunityFieldHistory
                                                                WHERE Field = 'Owner'
                                                                AND CreatedDate >= :dtFCBeg
                                                                AND CreatedDate <= :dtFCEnd
                                                                AND OpportunityId IN (SELECT Id
                                                                                        FROM Opportunity
                                                                                        WHERE OwnerId IN :setUser
                                                                                        AND Source_of_Lead_o__c IN ('Сайт Petrolplus.ru', 'Petrolcards.ru - АГГРЕГАТОР', 'Сайт Petrolplus.kz'))
                                                                AND OpportunityId NOT IN :opportunitySet
                                                                LIMIT 5000]
            ) {

                if (opportunityHistory.NewValue instanceof Id) {

                    if (etap == 1) {
                        prevOwner = (Id)opportunityHistory.NewValue;
                        prevDate = date.newInstance(opportunityHistory.CreatedDate.year(), opportunityHistory.CreatedDate.month(), opportunityHistory.CreatedDate.day());
                    }

                    if (etap == 2) {
                        currDate = date.newInstance(opportunityHistory.CreatedDate.year(), opportunityHistory.CreatedDate.month(), opportunityHistory.CreatedDate.day());
                        if (opportunityHistory.OldValue == prevOwner && currDate.daysBetween(prevDate) > 30) {

                            if (convertedOpportunitySet.contains(opportunityHistory.Id)) {
                                pLeadOpportunityMap.get(opportunityHistory.Id).ownDate = prevDate;
                                pLeadOpportunityMap.get(opportunityHistory.Id).ownerId = opportunityHistory.Opportunity.OwnerId;
                                pLeadOpportunityMap.get(opportunityHistory.Id).stageName = opportunityHistory.Opportunity.StageName;
                                pLeadOpportunityMap.get(opportunityHistory.Id).closeDate = opportunityHistory.Opportunity.CloseDate;
                                pLeadOpportunityMap.get(opportunityHistory.Id).logicTypeObject = 'Opportunity';
                            } else {
                                LeadOpportunityClass leadOpportunityObject = new LeadOpportunityClass();
                                leadOpportunityObject.typeObject = 'Lead';
                                leadOpportunityObject.leadId = null;
                                leadOpportunityObject.opportunityId = opportunityHistory.Id;
                                leadOpportunityObject.ownerId = opportunityHistory.Opportunity.OwnerId;
                                leadOpportunityObject.ownDate = prevDate;
                                leadOpportunityObject.stageName = opportunityHistory.Opportunity.StageName;
                                leadOpportunityObject.closeDate = opportunityHistory.Opportunity.CloseDate;

                                pLeadOpportunityMap.put(opportunityHistory.Id, leadOpportunityObject);
                                noconvertedOpportunitySet.add(opportunityHistory.Id);
                            }
                            opportunitySet.add(opportunityHistory.Id);
                        }
                    }
                }
            }
        } else {
            for (OpportunityFieldHistory opportunityHistory : [SELECT Id, OpportunityId, CreatedById, CreatedDate, NewValue, OldValue, Opportunity.OwnerId, Opportunity.StageName,
                                                                        Opportunity.CloseDate
                                                                FROM OpportunityFieldHistory
                                                                WHERE Field = 'Owner'
                                                                AND CreatedDate >= :dtFCBeg
                                                                AND CreatedDate <= :dtFCEnd
                                                                AND OpportunityId IN (SELECT Id
                                                                                        FROM Opportunity
                                                                                        WHERE OwnerId IN :setUser)
                                                                AND OpportunityId NOT IN :opportunitySet
                                                                LIMIT 5000]
            ) {
                if (opportunityHistory.NewValue instanceof Id) {

                    if (etap == 1) {
                        prevOwner = (Id)opportunityHistory.NewValue;
                        prevDate = date.newInstance(opportunityHistory.CreatedDate.year(), opportunityHistory.CreatedDate.month(), opportunityHistory.CreatedDate.day());
                    }

                    if (etap == 2) {
                        currDate = date.newInstance(opportunityHistory.CreatedDate.year(), opportunityHistory.CreatedDate.month(), opportunityHistory.CreatedDate.day());
                        if (opportunityHistory.OldValue == prevOwner && currDate.daysBetween(prevDate) > 30) {
                            if (convertedOpportunitySet.contains(opportunityHistory.Id)) {
                                pLeadOpportunityMap.get(opportunityHistory.Id).ownDate = prevDate;
                                pLeadOpportunityMap.get(opportunityHistory.Id).ownerId = opportunityHistory.Opportunity.OwnerId;
                                pLeadOpportunityMap.get(opportunityHistory.Id).stageName = opportunityHistory.Opportunity.StageName;
                                pLeadOpportunityMap.get(opportunityHistory.Id).closeDate = opportunityHistory.Opportunity.CloseDate;
                                pLeadOpportunityMap.get(opportunityHistory.Id).logicTypeObject = 'Opportunity';
                            } else {
                                LeadOpportunityClass leadOpportunityObject = new LeadOpportunityClass();
                                leadOpportunityObject.typeObject = 'Lead';
                                leadOpportunityObject.leadId = null;
                                leadOpportunityObject.opportunityId = opportunityHistory.Id;
                                leadOpportunityObject.ownerId = opportunityHistory.Opportunity.OwnerId;
                                leadOpportunityObject.ownDate = prevDate;
                                leadOpportunityObject.stageName = opportunityHistory.Opportunity.StageName;
                                leadOpportunityObject.closeDate = opportunityHistory.Opportunity.CloseDate;

                                pLeadOpportunityMap.put(opportunityHistory.Id, leadOpportunityObject);
                                noconvertedOpportunitySet.add(opportunityHistory.Id);
                            }
                            opportunitySet.add(opportunityHistory.Id);
                        }
                    }
                }
            }
        }
        return pLeadOpportunityMap;
    }

    public Map<Id, LeadOpportunityClass> getCheckOpportunityData(Map<Id, LeadOpportunityClass> pLeadOpportunityMap,
                                                                 String roleName,
                                                                 Set<Id> convertedOpportunitySet,
                                                                 Set<Id> noconvertedOpportunitySet) {
        /******************************************************************************************************/
        Set<Id> allOpportunitySet = new Set<Id>();
        allOpportunitySet.addAll(convertedOpportunitySet);
        allOpportunitySet.addAll(noconvertedOpportunitySet);

        Map<Id, Id> changeStageMap = new Map<Id, Id>();

        OpportunityFieldHistory[] groupedNoConvertOpportunities = ([
            SELECT OpportunityId, CreatedById
            FROM OpportunityFieldHistory
            WHERE OpportunityId IN :noconvertedOpportunitySet
            AND Field = 'StageName'
            AND CreatedDate >= :dtFCBeg AND CreatedDate <= :dtFCEnd
            AND CreatedById IN (SELECT Id FROM User WHERE UserRole.Name LIKE '%PPR%')
            ORDER BY OpportunityId, CreatedDate
        ]);

        for (OpportunityFieldHistory ar : groupedNoConvertOpportunities) {
            changeStageMap.put(ar.OpportunityId, ar.CreatedById);
        }

        PPR_Legacy_Opportunity_History__c[] groupedNoConvertOpportunitiesOld = [
            SELECT Opportunity_Id__c, Edited_By_ID__c
            FROM PPR_Legacy_Opportunity_History__c
            WHERE Opportunity_Id__c IN :noconvertedOpportunitySet
            AND Field_Event__c = 'StageName'
            AND Edit_Date__c >= :dtFCBeg AND Edit_Date__c <= :dtFCEnd
            AND Edited_By_ID__c IN (SELECT Id FROM User WHERE UserRole.Name LIKE '%PPR%')
            ORDER BY Opportunity_Id__c, Edit_Date__c
        ];

        for (PPR_Legacy_Opportunity_History__c ar : groupedNoConvertOpportunitiesOld) {
            changeStageMap.put(ar.Opportunity_Id__c, ar.Edited_By_ID__c);
        }

        for (Id csmSet : changeStageMap.keySet()) {
            if (pLeadOpportunityMap.get(csmSet).ownerId == changeStageMap.get(csmSet)) {
                pLeadOpportunityMap.get(csmSet).logicTypeObject = 'Opportunity';
            }
        }

        for (Id noconvSet : noconvertedOpportunitySet) {
            if ( ! changeStageMap.containsKey(noconvSet) && pLeadOpportunityMap.get(noconvSet).stageName == 'Moved to Start') {
                pLeadOpportunityMap.get(noconvSet).logicTypeObject = 'Opportunity';
            }
        }

        /// Тут по условиям из Agile по задаче W-00017
        Integer i = 0;
        for (Opportunity oppActivity : [SELECT Id, OwnerId, (SELECT Id, OwnerId FROM ActivityHistories WHERE Status = 'Completed')
                                        FROM Opportunity
                                        WHERE Id IN :noconvertedOpportunitySet]) {
            for (ActivityHistory ah : oppActivity.getSObjects('ActivityHistories')) {
                if ( ! changeStageMap.containsKey(oppActivity.Id) &&
                        pLeadOpportunityMap.get(oppActivity.Id).stageName != 'Moved to Start' &&
                        ah.OwnerId == oppActivity.OwnerId) {
                    pLeadOpportunityMap.get(oppActivity.Id).logicTypeObject = 'Opportunity';
                }
            }
        }

        Date prevDate, currDate = null;
        Id prevOwner = null;
        Id prevOpportunity = null;

        // Проверка на Отказ новая версия
        Integer etap = 1;
        etap = 1;
        for (OpportunityFieldHistory oh : [
                SELECT Id, OpportunityId, NewValue, OldValue, CreatedDate, CreatedById
                FROM OpportunityFieldHistory
                WHERE Field = 'StageName'
                AND OpportunityId IN :allOpportunitySet
                AND CreatedDate >= :dtFCBeg - 10
                ORDER BY OpportunityId, CreatedDate
        ]) {

            if (prevOpportunity != null && prevOpportunity != oh.OpportunityId) {
                etap = 1;
            }

            if (etap == 1) {
                if (pLeadOpportunityMap.get(oh.OpportunityId).ownerId == oh.CreatedById && (oh.NewValue == 'Отказ')) {
                    prevDate = date.newInstance(oh.CreatedDate.year(), oh.CreatedDate.month(), oh.CreatedDate.day());
                    prevOwner = oh.CreatedById;
                    prevOpportunity = oh.OpportunityId;

                } else {
                    etap = 0;
                }

                if (pLeadOpportunityMap.get(oh.OpportunityId).ownerId == oh.CreatedById && (oh.OldValue == 'Отказ') ) {
                    Date newDate = date.newInstance(oh.CreatedDate.year(), oh.CreatedDate.month(), oh.CreatedDate.day());
                    pLeadOpportunityMap.get(oh.OpportunityId).ownDate = newDate;
                }
            }

            if (etap == 2) {
                if (pLeadOpportunityMap.get(oh.OpportunityId).ownerId == oh.CreatedById && oh.OldValue == 'Отказ' && etap == 1 && oh.OpportunityId == prevOpportunity) {
                    currDate = date.newInstance(oh.CreatedDate.year(), oh.CreatedDate.month(), oh.CreatedDate.day());
                    if (prevDate.daysBetween(currDate) > 30) {
                        pLeadOpportunityMap.get(oh.OpportunityId).ownDate = currDate;
                        etap = 0;
                    } else {
                        etap = 0;
                    }
                } else {
                    etap = 0;
                }
            }
            etap += 1;
        }

        /*check for doubtful transfer*/
        prevDate = currDate = null;
        prevOwner = null;
        prevOpportunity = null;

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([
            SELECT Id, Transfer_Lead_1__c
            FROM Opportunity
            WHERE Id IN :allOpportunitySet
            LIMIT 10000
        ]);


        // Поиск неправильных переводов
        Integer transferStage = 0; // 0 - init; 1 - correct; 2 - not correct
        for (OpportunityFieldHistory oh : [
                SELECT Id, OpportunityId, NewValue, OldValue, CreatedDate, CreatedById
                FROM OpportunityFieldHistory
                WHERE Field = 'Owner'
                AND CreatedDate >= :dtFCBeg - 10
                AND OpportunityId IN :allOpportunitySet
                ORDER BY OpportunityId, CreatedDate DESC
        ]) {

            if( (oh.NewValue instanceof Id) && (oh.OldValue instanceof Id) ) {

                if (pLeadOpportunityMap.get(oh.OpportunityId).opportunityId != prevOpportunity) {
                    if(transferStage == 2) {
                        pLeadOpportunityMap.get(prevOpportunity).ownDate = opportunityMap.get(prevOpportunity).Transfer_Lead_1__c;
                    }
                    transferStage = 0;
                }

                if (prevOpportunity == null) {
                    if (pLeadOpportunityMap.get(oh.OpportunityId).opportunityId == oh.OpportunityId && (oh.NewValue == pLeadOpportunityMap.get(oh.OpportunityId).ownerId)) {
                        prevOpportunity = oh.OpportunityId;
                    } else {
                        prevOpportunity = null;
                    }
                }

                if (prevOpportunity != null) {
                    if (pLeadOpportunityMap.get(oh.OpportunityId).opportunityId == prevOpportunity && oh.OldValue == pLeadOpportunityMap.get(oh.OpportunityId).ownerId) {
                        if (transferStage == 0) {
                            currDate = date.newInstance(oh.CreatedDate.year(), oh.CreatedDate.month(), oh.CreatedDate.day());
                            if (currDate.daysBetween(date.newInstance(oh.CreatedDate.year(), oh.CreatedDate.month(), oh.CreatedDate.day())) < 30) {
                                pLeadOpportunityMap.get(oh.OpportunityId).ownDate = Date.newInstance(oh.CreatedDate.year(), oh.CreatedDate.month(), oh.CreatedDate.day());
                                transferStage = 2;
                            }else {
                                transferStage = 1;
                            }
                        }else if (transferStage == 2) {
                            if (pLeadOpportunityMap.get(oh.OpportunityId).opportunityId == prevOpportunity && oh.NewValue == pLeadOpportunityMap.get(oh.OpportunityId).ownerId) {
                                pLeadOpportunityMap.get(oh.OpportunityId).ownDate = Date.newInstance(oh.CreatedDate.year(), oh.CreatedDate.month(), oh.CreatedDate.day());
                                transferStage = 1;
                            }
                        }
                    } else {

                    }
                }
                prevOpportunity = oh.OpportunityId;
            }
        }

        return pLeadOpportunityMap;
    }

    public class OutputMapClass {
        public String managerName {get; set;}
        public Id salesId {get; set;}
        public Integer leadsCount {get; set;}
        public Integer opportunitiesCount {get; set;}
        public Integer agreementsCount {get; set;}
        public Decimal leadOpportunityPercent {get; set;}
        public Decimal leadAgreementPrecent { get; set; }
        public Decimal middleDealCicle { get; set; }
    }

    public class OutputMapClassText {
        public String managerName { get; set; }
        public Id salesId { get; set; }
        public String leadsCount { get; set; }
        public String opportunitiesCount { get; set; }
        public String agreementsCount { get; set; }
        public String leadOpportunityPercent {get; set;}
        public String leadAgreementPrecent { get; set; }
        public String middleDealCicle { get; set; }
    }

    public void getOutputData(Map<Id, LeadOpportunityClass> pLeadOpportunityMap) {
        Integer lLeadsCount, lOpportunitycount, lAgreementCount;

        for (Id locId : pLeadOpportunityMap.keySet()) {
            LeadOpportunityClass loc = pLeadOpportunityMap.get(locId);
            if (loc.ownDate >= dFCBeg && loc.ownDate <= dFCEnd) { // тут начало договоров
                lLeadsCount = lOpportunitycount = lAgreementCount = 0;
                if (loc.typeObject == 'Lead') {
                    lLeadsCount = 1;
                }

                if (loc.logicTypeObject == 'Opportunity') {lOpportunitycount = 1;}

                if (loc.stageName == 'Moved to Start' && (loc.closeDate <= dEndMonth)) {
                    ClassForUpload classForUpload = new ClassForUpload();
                    classForUpload.oppId = loc.opportunityId;
                    classForUpload.ownerId = loc.ownerId;
                    classForUpload.assignmentDate = loc.ownDate;
                    classForUpload.closeDate = loc.closeDate;
                    uploadListAssignment.put(loc.opportunityId, classForUpload);
                    lAgreementCount = 1;
                }

                if ( ! outputMap.containsKey(loc.ownerId) ) {
                    OutputMapClass outputMapClassObject = new OutputMapClass();
                    outputMapClassObject.salesId = loc.ownerId;
                    outputMapClassObject.leadsCount = 0;
                    outputMapClassObject.opportunitiesCount = lOpportunitycount;
                    outputMapClassObject.agreementsCount = lAgreementCount;

                    if (loc.stageName == 'Moved to Start' && (loc.closeDate <= dEndMonth)) {
                        outputMapClassObject.middleDealCicle = dealCicle(loc.ownDate, loc.closeDate);
                    } else {outputMapClassObject.middleDealCicle = 0;}

                    outputMap.put(loc.ownerId, outputMapClassObject);
                }

                if ( ! outputMap.containsKey(loc.leadOwnerId) ){
                    OutputMapClass outputMapClassObject = new OutputMapClass();
                    outputMapClassObject.salesId = loc.leadOwnerId;
                    outputMapClassObject.leadsCount = lLeadsCount;
                    outputMapClassObject.opportunitiesCount = 0;
                    outputMapClassObject.agreementsCount = 0;
                    outputMapClassObject.middleDealCicle = 0;

                    outputMap.put(loc.leadOwnerId, outputMapClassObject);
                }

                if (outputMap.containsKey(loc.ownerId)) {
                    outputMap.get(loc.ownerId).leadsCount += lLeadsCount;
                    outputMap.get(loc.ownerId).opportunitiesCount += lOpportunitycount;
                    outputMap.get(loc.ownerId).agreementsCount += lAgreementCount;

                    if (loc.stageName == 'Moved to Start' && (loc.closeDate <= dEndMonth)) {
                        outputMap.get(loc.ownerId).middleDealCicle += dealCicle(loc.ownDate, loc.closeDate);
                    }
                }
            } else {
                pLeadOpportunityMap.remove(locId);
            }

        }

        for (User user : [SELECT Id, Name FROM User WHERE Id IN :outputMap.keySet() AND UserRoleId = :salesGroup ORDER BY Name]) {
            OutputMapClass omc = new OutputMapClass();
            omc.salesId = user.Id;
            omc.managerName = user.Name;
            omc.leadsCount = outputMap.get(user.id).leadsCount;
            omc.opportunitiesCount = outputMap.get(user.Id).opportunitiesCount;
            omc.agreementsCount = outputMap.get(user.Id).agreementsCount;
            if (outputMap.get(user.id).leadsCount > 0) {
                omc.leadOpportunityPercent = (Decimal.valueOf((outputMap.get(user.Id).opportunitiesCount * 100)) / Decimal.valueOf(outputMap.get(user.id).leadsCount)).setScale(1);
            } else {
                omc.leadOpportunityPercent = 0;
            }
            if (outputMap.get(user.id).leadsCount > 0) {
                omc.leadAgreementPrecent = (Decimal.valueOf((outputMap.get(user.Id).agreementsCount * 100)) / Decimal.valueOf(outputMap.get(user.id).leadsCount)).setScale(1);
            } else {
                omc.leadAgreementPrecent = 0;
            }
            if (outputMap.get(user.Id).agreementsCount > 0) {
                if ((outputMap.get(user.Id).middleDealCicle / outputMap.get(user.Id).agreementsCount).setScale(1) > 0) {
                    omc.middleDealCicle = (outputMap.get(user.Id).middleDealCicle / outputMap.get(user.Id).agreementsCount).setScale(1);
                } else {omc.middleDealCicle = 0;}
            }
            outputList.add(omc);
        }

        OutputMapClass omcTotal = new OutputMapClass();

        Integer leadsCount = 0;
        Integer opportunitiesCount = 0;
        Integer agreementsCount = 0;
        Decimal leadOpportunityPercent = 0;
        Decimal leadAgreementPrecent = 0;
        Decimal middleDealCicle = 0;

        for (OutputMapClass omcT : outputList) {
            leadsCount += omcT.leadsCount;
            opportunitiesCount += omcT.opportunitiesCount;
            agreementsCount += omcT.agreementsCount;
            leadOpportunityPercent += omcT.leadOpportunityPercent;
            leadAgreementPrecent += omcT.leadAgreementPrecent;
            if (omcT.middleDealCicle > 0) {
                middleDealCicle += omcT.middleDealCicle;
            }
        }

        omcTotal.managerName = 'Общий Итог';
        omcTotal.leadsCount = leadsCount;
        omcTotal.opportunitiesCount = opportunitiesCount;
        omcTotal.agreementsCount = agreementsCount;
        if (outputList.size() > 0) {
            omcTotal.leadOpportunityPercent = (leadOpportunityPercent/outputList.size()).setScale(1);
        } else {omcTotal.leadOpportunityPercent = 0;}
        if (outputList.size() > 0) {
            omcTotal.leadAgreementPrecent = (leadAgreementPrecent/outputList.size()).setScale(1);
        } else {omcTotal.leadAgreementPrecent = 0;}
        if (outputList.size() > 0) {
            omcTotal.middleDealCicle = (middleDealCicle/outputList.size()).setScale(1);
        } else {omcTotal.middleDealCicle = 0;}
        outputList.add(omcTotal);

        outputListText = new List<OutputMapClassText>();
        for (OutputMapClass omcItem : outputList) {
            OutputMapClassText outputListTextItem = new OutputMapClassText();
            outputListTextItem.managerName = omcItem.managerName;
            outputListTextItem.leadsCount = omcItem.leadsCount.format().replace('.', ',');
            if (omcItem.opportunitiesCount != null) {
                outputListTextItem.opportunitiesCount = omcItem.opportunitiesCount.format().replace('.', ',');
            }
            if (omcItem.agreementsCount != null) {
                outputListTextItem.agreementsCount = omcItem.agreementsCount.format().replace('.', ',');
            }
            if (omcItem.leadOpportunityPercent != null) {
                outputListTextItem.leadOpportunityPercent = (omcItem.leadOpportunityPercent.format() + '%').replace('.', ',');
            }
            if (omcItem.leadAgreementPrecent != null) {
                outputListTextItem.leadAgreementPrecent = (omcItem.leadAgreementPrecent.format() + '%').replace('.', ',');
            }
            if (omcItem.middleDealCicle != null) {
                outputListTextItem.middleDealCicle = omcItem.middleDealCicle.format().replace('.', ',');
            } else {outputListTextItem.middleDealCicle = '0,0';}
            outputListText.add(outputListTextItem);
        }
    }

    public Decimal dealCicle (Date beginDate, Date endDate) {
        Integer countDays1, countDays2 = 0;
        Decimal divCountDays1, divCountDays2, returnCount = 0;
        countDays1 = Date.newInstance(1900, 1, 8).daysBetween(endDate);
        countDays2 = Date.newInstance(1900, 1, 8).daysBetween(beginDate);
        divCountDays1 = countDays1 / 7;
        divCountDays2 = countDays2 / 7;

        returnCount = (6 * math.floor(divCountDays1) + math.min(6, math.mod(countDays1, 7)))
                - (6 * math.floor(divCountDays2) + math.min(6, math.mod(countDays2, 7)));

        for (Date holiday : holidaysList) {
            if (beginDate <= holiday && endDate >= holiday) {
                returnCount =- 1;
            }
        }
        return returnCount;
    }


    public void init() {
        if (periodFC == null) {
            periodFC = ApexPages.currentPage().getParameters().get('periodFC');
        }

        if (salesGroup == null) {
            salesGroup = ApexPages.currentPage().getParameters().get('salesGroup');
        }

        if (monthReport == null) {
            monthReport = ApexPages.currentPage().getParameters().get('monthReport');
        }

        if(this.reportType == null) {
            this.reportType = ApexPages.currentPage().getParameters().get('reportType');
            if (this.reportType == null) {
                this.reportType = 'current';
            }
        }

        if (this.mode == null) {
            this.mode = ApexPages.currentPage().getParameters().get('mode');
            if (this.mode == null) {
                this.mode = 'nosend';
            }
        }

        getUser();
        getSalesGroupItems();

        if (periodFC != null && salesGroup != null && monthReport != null && reportType != null) {
            uploadData();
        }
        getReportTypeItems();
    }

    private String getLeadOpportunitySourceAttachmentData(Map<Id, LeadOpportunityClass> leadOpportunityMap) {
        String header = 'LeadId, OpportunityId, OwnerId, LeadOwnerId, TypeObject, LogicTypeObject, OwnDate, StageName, CloseDate \n';
        String resultStr = header;

        for (Id itemId : leadOpportunityMap.keySet()) {
            LeadOpportunityClass item = leadOpportunityMap.get(itemId);
            String record = item.leadId + '; ' +
                            item.opportunityId + '; ' +
                            item.ownerId + '; ' +
                            item.leadOwnerId + '; ' +
                            item.typeObject + '; ' +
                            item.logicTypeObject + '; ' +
                            item.ownDate + '; ' +
                            item.stageName + '; ' +
                            item.closeDate + '\n';
            resultStr += record;
        }

        return resultStr;
    }

    public String getAgreementSourceAttachmentData() {
        String resultStr = 'OpportunityId, OwnerId , Assignment Date, Closed Date \n';
        for ( Id key :this.uploadListAssignment.keySet()) {
            ConversionReportPPRCtrl.ClassForUpload cl = this.uploadListAssignment.get(key);
            String record = cl.oppId + '; ' + cl.ownerId + '; ' + cl.assignmentDate + '; ' + cl.closeDate + '\n';
            resultStr += record;
        }
        return resultStr;
    }

    public Messaging.EmailFileAttachment prepareEmailFileAttachment(Blob data, String name) {
        Messaging.EmailFileAttachment csvAttch = new Messaging.EmailFileAttachment();
        csvAttch.setFileName(name);
        csvAttch.setBody(data);
        return csvAttch;
    }

    public void sendReportSource(Messaging.EmailFileAttachment[] attachments) {

        Set<String> emails = new Set<String>();
        for (RU_Conversion_Report_Email_For_Source__c  emailItem : [SELECT Name FROM RU_Conversion_Report_Email_For_Source__c]) {
            emails.add(emailItem.name);
        }

        if ( ! emails.isEmpty() ) {
            List<OrgWideEmailAddress> orgEmails = ([
                    SELECT Id
                    FROM OrgWideEmailAddress
                    WHERE Address = 'no-reply@fleetcor.eu'
            ]);

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if ( orgEmails.size() > 0 ) {
                email.setOrgWideEmailAddressId(orgEmails.get(0).Id);
            }
            email.setSubject('Conversion Report Source');
            email.setToAddresses(new List<String>(emails));
            email.setPlainTextBody('See Attachment');
            email.setFileAttachments(attachments);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }

    public void main() {
        String roleName = '';
        Map<Id, LeadOpportunityClass> leadOpportunityMap = new Map<Id, LeadOpportunityClass>();
        Set<Id> convertedOpportunitySet = new Set<Id>();
        Set<Id> noconvertedOpportunitySet = new Set<Id>();
        this.uploadListAssignment = new Map<Id, ClassForUpload>();

        if (salesGroup != null && salesGroup != 'None') {
            roleName = [SELECT Name FROM UserRole WHERE Id = :salesGroup LIMIT 1].get(0).Name;

            // Get Leads
            getLeadData(leadOpportunityMap, roleName, convertedOpportunitySet);

            if (reportType == 'final') {
                getLeadDataAdd(leadOpportunityMap, roleName, convertedOpportunitySet);
            }

            // Get Opportunity
            getOpportunityData(leadOpportunityMap, roleName, convertedOpportunitySet, noconvertedOpportunitySet);

            if (reportType == 'final') {
                getOpportunityDataAdd(leadOpportunityMap, roleName, convertedOpportunitySet, noconvertedOpportunitySet);
            }

            // Check Opportunity
            getCheckOpportunityData(leadOpportunityMap, roleName, convertedOpportunitySet, noconvertedOpportunitySet);

            String json  = Json.serialize(leadOpportunityMap);
            System.debug('Leads + Opp: ' + json);

            this.outputMap = new Map<Id, OutputMapClass>();
            this.outputList = new List<OutputMapClass>();
            getOutputData(leadOpportunityMap);

            if (this.mode == 'send') {
                Messaging.EmailFileAttachment[] attachments = new Messaging.EmailFileAttachment[] {
                        prepareEmailFileAttachment(
                                Blob.valueOf(getLeadOpportunitySourceAttachmentData(leadOpportunityMap)),
                                roleName + ' (' + periodFC + ' ' + monthReport + ') lead opp source.csv'
                        ),
                        prepareEmailFileAttachment(
                                Blob.valueOf(getAgreementSourceAttachmentData()),
                                roleName + ' (' + periodFC + ' ' + monthReport + ') agreements source.csv'
                        )
                };

                sendReportSource(attachments);
            }
        }

    }

    public void uploadData() {
        getFCDates('date');
        getFCDates('datetime');
        getHolidays();
        getReportMonthDates();
        getReportTypeItems();
        main();
    }
}