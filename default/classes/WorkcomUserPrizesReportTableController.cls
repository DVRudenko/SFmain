/**
 * Created by A.Syromyatnikov on 17.01.2019.
 */

public class WorkcomUserPrizesReportTableController {

    public String url { get; set; }
    private Map<Id, String> recordsTypeMap { get; set; }
    private Set<Id> userRoleIds { get; set; }
    private Integer pageSize { get; set; }

    public WorkcomUserPrizesReportTableController() {
        url = System.Url.getSalesforceBaseUrl().toExternalForm();
        pageSize = 1000;

        this.recordsTypeMap = new Map<Id, String>();
        for (RecordTypeInfo info : WorkBadgeDefinition.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (info.isAvailable()) {
                this.recordsTypeMap.put(info.getRecordTypeId(), info.getName());
            }
        }

        //get all roles corresponding to Russian team
        UserRole pPRFleetcorRole = ([
                SELECT Name
                FROM UserRole
                WHERE Name = 'PPR_Fleetcor'
        ]);
        userRoleIds = GlobalUtils.getAllSubRoleIds(new Set<Id>{
                pPRFleetcorRole.Id
        });
        userRoleIds.add(pPRFleetcorRole.Id);
    }

    public ApexPages.StandardSetController con {
        get {
            if (con == null) {
                con = new ApexPages.StandardSetController([
                        SELECT User__r.Name, User__r.Earned_Points__c, Prize__r.Cost__c, Prize__r.Name, CreatedDate
                        FROM UserPrizeAssociation__c
                        WHERE User__r.Earned_Points__c != NULL
                        AND User__c IN (SELECT RecipientId FROM WorkBadge WHERE Definition.RecordTypeId = :this.recordsTypeMap.keySet())
                        AND User__r.UserRoleId IN :userRoleIds
                        ORDER BY User__r.Name ASC
                        LIMIT 5000
                ]);
                con.setPageSize(pageSize);
            }
            return con;
        }
        set;
    }

    public List<UserPrizeAssociation__c> getUserPrizeAssociationList() {
        return (List<UserPrizeAssociation__c>) con.getRecords();
    }

    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    public void first() {
        con.first();
    }

    public void last() {
        con.last();
    }

    public void previous() {
        con.previous();
    }

    public void next() {
        con.next();
    }

    //TODO: Сделать сортировку по колонкам и фильтры как в стандартном отчете salesforce


}