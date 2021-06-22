/**
 * Created by A.Syromyatnikov on 28.01.2019.
 */

public with sharing class DashboardSalesByTeamPPRCtrl {
    public String selectedRole { //String role for role display list
        get {
            if (selectedRole == null) {
                selectedRole = connectedUserRole.Id;
                return selectedRole;
            }
            return selectedRole;
        }
        set;
    }
    public UserRole connectedUserRole { //UserRole of connected user
        get {
            if (connectedUserRole == null) {
                User user = [
                        SELECT Id, UserRole.Name, Profile.Name, Name, UserRoleId
                        FROM User
                        WHERE Id = :this.userId
                ];
                connectedUserRole = user.UserRole;
                return connectedUserRole;
            }
            return connectedUserRole;
        }
        private set;
    }

    public UserRole currentRole { //role by which gathering data
        get {
            if (currentRole == null) {
                currentRole = connectedUserRole;
                return currentRole;
            }
            return currentRole;
        }
        private set;
    }

    public Map<Id, UserRole> mapOfAvailableRoles { //Map with UserRoleId and UserRole sObject which is available for current user
        get {
            if (mapOfAvailableRoles == null) {
                mapOfAvailableRoles = new Map<Id, UserRole>();
                for (UserRole userRole : DashboardMethods.userRoleTree.toUserRoleList(currentRole)) {
                    mapOfAvailableRoles.put(userRole.Id, userRole);
                }
                return mapOfAvailableRoles;
            }
            return mapOfAvailableRoles;
        }
        private set;
    }

    public String userId { //connected userId
        get {
            userId = DashboardMethods.returnUserId();
            return userId;
        }
        private set;
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
        this.currentRole = this.mapOfAvailableRoles.get(selectedRole);
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
        try{
            List<SelectOption> selectRoleList = new List<SelectOption>();
            for (String option : DashboardMethods.userRoleTree.toListWithLevels(this.connectedUserRole)) {
                selectRoleList.add(new SelectOption(option.remove('- ').trim(), option.remove(option.remove('- ')) + this.mapOfAvailableRoles.get(option.remove('- ').trim()).Name));
            }
            return selectRoleList;
        }
        catch (Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
            return null;
        }
    }
}