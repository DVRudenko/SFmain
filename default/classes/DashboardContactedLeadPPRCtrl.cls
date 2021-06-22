/**
 * Created by Nikita.Mikhailov on 23.05.2018.
 */

public with sharing class DashboardContactedLeadPPRCtrl {
    private String userId;
    public String selectedRole { get; set; } //String role for role display list
    public UserRole currentRole { get; set; } //role of connected user
    public UserRole userRole { get; set; } //role by which gathering data
    public Map<Id, UserRole> mapOfAvailableRoles { get; set; } //Map with UserRoleId and UserRole sObject which is available for current user
    public Map<Id, User> salesTeamMap { get; set; } //Users Map to gather and show data
    public List<FinalList> finalList { get; set; }
    public Map<Id, Integer> quantityleadsNoTaskForTeamlead { get; set; }
    public Map<Id, Integer> quantityleadsWithTaskForTeamlead { get; set; }

    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 23/05/2018
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
                        AND IsActive = true
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

            if (this.salesTeamMap == null) {
                this.salesTeamMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE IsActive = true AND UserRoleId IN :DashboardMethods.userRoleTree.toUserRoleList(this.userRole)]);
            }

            contactedLeads();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : contactedLeads()
    *  Type            : method
    *  Summary         : getting all overdue contacted leads for current user and teamleader
    *  CreatedDate     : 23/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void contactedLeads() {
        Date todayDate = Date.today();

        this.finalList = new List<FinalList>();
        this.quantityleadsNoTaskForTeamlead = new Map<Id, Integer>();
        this.quantityleadsWithTaskForTeamlead = new Map<Id, Integer>();

        Map<Id, Lead> allContactedLeadsMap = new Map<Id, Lead>([
                SELECT Id, OwnerId, IsConverted, Status, (SELECT Id, ActivityDate, OwnerId FROM Tasks WHERE IsClosed = false)
                FROM Lead
                WHERE OwnerId IN :this.salesTeamMap.keySet()
                AND Status NOT IN ('Disqualified', 'QUALIFIED - Convert to Opportunity')
                AND IsConverted = false
                LIMIT 50000
        ]);

        Map<Id, List<Lead>> usersWithLeadsMap = new Map<Id, List<Lead>>();
        for (Lead lead : allContactedLeadsMap.values()) {
            if (this.salesTeamMap.containsKey(lead.OwnerId)) {
                if (usersWithLeadsMap.get(lead.OwnerId) == null) {
                    List<Lead> putLeadList = new List<Lead>();
                    putLeadList.add(lead);
                    usersWithLeadsMap.put(lead.OwnerId, putLeadList);
                } else {
                    usersWithLeadsMap.get(lead.OwnerId).add(lead);
                }
            }
        }

        for (Id user : usersWithLeadsMap.keySet()) {
            Integer noTasksNumber = 0;
            Integer overdueTasksNumber = 0;
            Integer wrongOwnerTasks = 0;
            for (Lead lead : usersWithLeadsMap.get(user)) {
                Integer noTaskBuf = 0;
                Integer overDueBuf = 0;
                Integer wrongOwnerBuf = 0;
                if (lead.Tasks.size() == 0) {
                    noTaskBuf++;
                } else {
                    for (Task task : lead.Tasks) {
                        if (task.OwnerId.equals(lead.OwnerId)) {
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
            this.finalList.add(new FinalList(user, overdueTasksNumber + noTasksNumber));
            this.quantityleadsNoTaskForTeamlead.put(user, noTasksNumber);
            this.quantityleadsWithTaskForTeamlead.put(user, overdueTasksNumber);
        }

        finalList.sort();
    }

    /*******************************************************************************
    *  Name            : getRolesList()
    *  Type            : method
    *  Summary         : Display available roles in selectbox
    *  CreatedDate     : 23/05/2018
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
    *  CreatedDate     : 23/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeRole() {
        this.userRole = this.mapOfAvailableRoles.get(selectedRole);
        this.salesTeamMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE IsActive = true AND UserRoleId IN :DashboardMethods.userRoleTree.toUserRoleList(this.userRole)]);
        init();
    }


    /*******************************************************************************
    *  Name            : finalList()
    *  Summary         : sales are ordering on the number of overdue leads
    *  CreatedDate     : -
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