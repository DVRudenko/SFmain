/**
 * Created by Nikita.Dayanov on 02.07.2018. 
 */

public with sharing class DashboardPersonalSalesPPRCtrl {
    public String userId { //connected userId
        get {
            userId = DashboardMethods.returnUserId();
            return userId;
        }
        private set;
    }
    public UserRole connectedUserRole { //UserRole of connected user
        public get {
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
}