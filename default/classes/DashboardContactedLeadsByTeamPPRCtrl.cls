/**
 * Created by A.Syromyatnikov on 29.01.2019.
 */

public with sharing class DashboardContactedLeadsByTeamPPRCtrl {
    private String userId;
    public String selectedRole { get; set; } //String role for role display list
    public UserRole currentRole { get; set; } //role of connected user
    public UserRole userRole { get; set; } //role by which gathering data
    public Map<Id, UserRole> mapOfAvailableRoles { get; set; } //Map with UserRoleId and UserRole sObject which is available for current user
    public Map<Id, UserRole> salesTeamsMap { get; set; } //Teams Map to gather and show data
    public List<FinalList> finalList { get; set; }
    public Map<Id, Integer> quantityleadsNoTaskForTeam { get; set; }
    public Map<Id, Integer> quantityleadsWithTaskForTeam { get; set; }

    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 30/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {
            if (this.userId == null) {
                this.userId = DashboardMethods.returnUserId();
            }

            if (this.currentRole == null) {
                User currentUser = [
                        SELECT Id, UserRole.Name, Profile.Name, Name, UserRoleId
                        FROM User
                        WHERE Id = :this.userId
                        AND IsActive = TRUE
                ];
                this.currentRole = currentUser.UserRole;
            }

            if (this.userRole == null) {
                this.userRole = DashboardMethods.getUserRole(DashboardMethods.returnUserRoleId());
            }

            if (this.selectedRole == null) {
                this.selectedRole = this.userRole.Id;
            }

            if (this.mapOfAvailableRoles == null) {
                this.mapOfAvailableRoles = new Map<Id, UserRole>();
                for (UserRole userRole : DashboardMethods.userRoleTree.toUserRoleList(this.currentRole)) {
                    this.mapOfAvailableRoles.put(userRole.Id, userRole);
                }
            }

            if (this.salesTeamsMap == null) {
                this.salesTeamsMap = new Map<Id, UserRole>([SELECT Id, Name FROM UserRole WHERE Id IN :DashboardMethods.userRoleTree.toUserRoleList(this.userRole)]);
            }

            contactedLeads();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : contactedLeads()
    *  Type            : method
    *  Summary         : getting all overdue contacted leads by teams
    *  CreatedDate     : 30/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void contactedLeads() {
        Date todayDate = Date.today();

        this.finalList = new List<FinalList>();
        this.quantityleadsNoTaskForTeam = new Map<Id, Integer>();
        this.quantityleadsWithTaskForTeam = new Map<Id, Integer>();

        Map<Id, Lead> allContactedLeadsMap = new Map<Id, Lead>([
                SELECT Id, Owner.UserRoleId, Owner.UserRole.Name, IsConverted, Status, (
                        SELECT Id, ActivityDate, Owner.UserRoleId
                        FROM Tasks
                        WHERE IsClosed = FALSE
                        ORDER BY ActivityDate ASC
                        LIMIT 20
                )
                FROM Lead
                WHERE Owner.UserRoleId IN :this.salesTeamsMap.keySet()
                AND Owner.IsActive = TRUE
                AND Status NOT IN ('Disqualified', 'QUALIFIED - Convert to Opportunity')
                AND IsConverted = FALSE
                ORDER BY CreatedDate ASC
                LIMIT 50000
        ]);

        Map<Id, List<Lead>> teamsWithLeadsMap = new Map<Id, List<Lead>>();
        for (Lead lead : allContactedLeadsMap.values()) {
            if (this.salesTeamsMap.containsKey(lead.Owner.UserRoleId)) {
                if (teamsWithLeadsMap.get(lead.Owner.UserRoleId) == null) {
                    List<Lead> putLeadList = new List<Lead>();
                    putLeadList.add(lead);
                    teamsWithLeadsMap.put(lead.Owner.UserRoleId, putLeadList);
                } else {
                    teamsWithLeadsMap.get(lead.Owner.UserRoleId).add(lead);
                }
            }
        }

        for (Id userRoleId : teamsWithLeadsMap.keySet()) {
            Integer noTasksNumber = 0;
            Integer overdueTasksNumber = 0;
            for (Lead lead : teamsWithLeadsMap.get(userRoleId)) {
                Integer noTaskBuf = 0;
                Integer overDueBuf = 0;
                Integer wrongOwnerBuf = 0;
                if (lead.Tasks.size() == 0) {
                    noTaskBuf++;
                } else {
                    for (Task task : lead.Tasks) {
                        if (task.Owner.UserRoleId.equals(lead.Owner.UserRoleId)) {
                            if (task.ActivityDate < todayDate) {
                                overDueBuf++;
                                break;
                            }
                        } else {
                            wrongOwnerBuf++;
                        }
                    }
                }

                if (overDueBuf == 0 && noTaskBuf == 0 && wrongOwnerBuf == lead.Tasks.size()) {
                    noTaskBuf++;
                }

                noTasksNumber += noTaskBuf;
                overdueTasksNumber += overDueBuf;
            }
            this.finalList.add(new FinalList(userRoleId, overdueTasksNumber + noTasksNumber));
            this.quantityleadsNoTaskForTeam.put(userRoleId, noTasksNumber);
            this.quantityleadsWithTaskForTeam.put(userRoleId, overdueTasksNumber);
        }

        finalList.sort();
    }

    /*******************************************************************************
    *  Name            : getRolesList()
    *  Type            : method
    *  Summary         : Display available roles in selectbox
    *  CreatedDate     : 30/01/2019
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getRolesList() {
        List<SelectOption> selectRoleList = new List<SelectOption>();

        System.debug(currentRole);
        for (String option : DashboardMethods.userRoleTree.toListWithLevels(this.currentRole)) {
            selectRoleList.add(new SelectOption(option.remove('- ').trim(), option.remove(option.remove('- ')) + this.mapOfAvailableRoles.get(option.remove('- ').trim()).Name));
        }
        return selectRoleList;
    }

    /*******************************************************************************
    *  Name            : changeRole()
    *  Type            : method
    *  Summary         : Setting UserRole depending on the selected UserRole
    *  CreatedDate     : 30/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeRole() {
        this.userRole = this.mapOfAvailableRoles.get(selectedRole);
        this.salesTeamsMap = new Map<Id, UserRole>([SELECT Id, Name FROM UserRole WHERE Id IN :DashboardMethods.userRoleTree.toUserRoleList(this.userRole)]);
        init();
    }


    /*******************************************************************************
    *  Name            : finalList()
    *  Summary         : sales are ordering on the number of overdue leads
    *  CreatedDate     : 30/01/2019
    *  Parameters      : String id, Decimal compareValue
    *  Returns         : Integer
    ******************************************************************************/
    public class FinalList implements Comparable {
        public String id { get; set; }
        public Decimal compareValue { get; set; }

        public FinalList(String id, Decimal compareValue) {
            this.id = id;
            this.compareValue = compareValue;
        }

        public Integer compareTo(Object compareTo) {
            FinalList compareToU = (FinalList) compareTo;
            if (compareValue == compareToU.compareValue) return 0;
            if (compareValue < compareToU.compareValue) return 1;
            return -1;
        }
    }
}