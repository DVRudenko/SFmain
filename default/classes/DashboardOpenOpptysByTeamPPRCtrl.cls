/**
 * Created by A.Syromyatnikov on 28.01.2019.
 */

public with sharing class DashboardOpenOpptysByTeamPPRCtrl {
    private String userId;
    public String selectedRole { get; set; } //String role for role display list
    public UserRole currentRole { get; set; } //role of connected user
    public UserRole userRole { get; set; } //role by which gathering data
    public Map<Id, UserRole> mapOfAvailableRoles { get; set; } //Map with UserRoleId and UserRole sObject which is available for current user
    public Map<Id, UserRole> salesTeamsMap { get; set; } //Teams Map to gather and show data
    public List<FinalList> finalList { get; set; }
    public Map<Id, Integer> quantityOpptysNoTaskForTeam { get; set; }
    public Map<Id, Integer> quantityOpptysWithTaskForTeam { get; set; }

    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 06/02/2019
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

            contactedOpptys();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : contactedOpptys()
    *  Type            : method
    *  Summary         : getting all overdue opportunities by teams
    *  CreatedDate     : 06/02/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void contactedOpptys() {
        Date todayDate = Date.today();

        this.finalList = new List<FinalList>();
        this.quantityOpptysNoTaskForTeam = new Map<Id, Integer>();
        this.quantityOpptysWithTaskForTeam = new Map<Id, Integer>();

        Map<Id, Opportunity> allContactedOpptysMap = new Map<Id, Opportunity>([
                SELECT Id, Name, Owner.UserRole.Name, Owner.UserRoleId, StageName, (
                        SELECT Id, ActivityDate, Owner.UserRoleId
                        FROM Tasks
                        WHERE IsClosed = FALSE
                        ORDER BY ActivityDate ASC
                        LIMIT 1
                )
                FROM Opportunity
                WHERE Owner.UserRoleId IN :this.salesTeamsMap.keySet()
                AND Owner.IsActive = TRUE
                AND StageName NOT IN ('Moved to Start', 'Отказ', 'Потерян в конкуренции')
                ORDER BY CreatedDate ASC
                LIMIT 50000
        ]);

        Map<Id, List<Opportunity>> teamsWithOpptysMap = new Map<Id, List<Opportunity>>();
        for (Opportunity opportunity : allContactedOpptysMap.values()) {
            if (this.salesTeamsMap.containsKey(opportunity.Owner.UserRoleId)) {
                if (!teamsWithOpptysMap.containsKey(opportunity.Owner.UserRoleId)) {
                    List<Opportunity> putOpptyList = new List<Opportunity>();
                    putOpptyList.add(opportunity);
                    teamsWithOpptysMap.put(opportunity.Owner.UserRoleId, putOpptyList);
                } else {
                    teamsWithOpptysMap.get(opportunity.Owner.UserRoleId).add(opportunity);
                }
            }
        }

        for (Id userRoleId : teamsWithOpptysMap.keySet()) {
            Integer noTasksNumber = 0;
            Integer overdueTasksNumber = 0;
            for (Opportunity opportunity : teamsWithOpptysMap.get(userRoleId)) {
                Integer noTaskBuf = 0;
                Integer overDueBuf = 0;
                Integer wrongOwnerBuf = 0;
                if (opportunity.Tasks.size() == 0) {
                    noTaskBuf++;
                } else {
                    for (Task task : opportunity.Tasks) {
                        if (task.Owner.UserRoleId.equals(opportunity.Owner.UserRoleId)) {
                            if (task.ActivityDate < todayDate) {
                                overDueBuf++;
                                break;
                            }
                        } else {
                            wrongOwnerBuf++;
                        }
                    }
                }

                if (overDueBuf == 0 && noTaskBuf == 0 && wrongOwnerBuf == opportunity.Tasks.size()) {
                    noTaskBuf++;
                }

                noTasksNumber += noTaskBuf;
                overdueTasksNumber += overDueBuf;
            }
            this.finalList.add(new FinalList(userRoleId, overdueTasksNumber + noTasksNumber));
            this.quantityOpptysNoTaskForTeam.put(userRoleId, noTasksNumber);
            this.quantityOpptysWithTaskForTeam.put(userRoleId, overdueTasksNumber);
        }

        finalList.sort();
    }

    /*******************************************************************************
    *  Name            : getRolesList()
    *  Type            : method
    *  Summary         : Display available roles in selectbox
    *  CreatedDate     : 06/02/2019
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getRolesList() {
        List<SelectOption> selectRoleList = new List<SelectOption>();

        for (String option : DashboardMethods.userRoleTree.toListWithLevels(this.currentRole)) {
            selectRoleList.add(new SelectOption(option.remove('- ').trim(), option.remove(option.remove('- ')) + this.mapOfAvailableRoles.get(option.remove('- ').trim()).Name));
        }
        return selectRoleList;
    }

    /*******************************************************************************
    *  Name            : changeRole()
    *  Type            : method
    *  Summary         : Setting UserRole depending on the selected UserRole
    *  CreatedDate     : 06/02/2019
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
    *  CreatedDate     : 06/02/2019
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