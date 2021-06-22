public with sharing class UserRoleManager {
    
    public static UserRole getUserRoleById(Id roleId) {
        return (roleId == null) ? null : [SELECT Name FROM UserRole WHERE Id = :roleId];
    }

    public static UserRole getUserRoleByName(String name) {

        if (String.isBlank(name)) {
            return null;
        }

        List<UserRole> roles = ([
                SELECT Id
                FROM UserRole
                WHERE DeveloperName = :name
        ]);
        return roles.isEmpty() ? null : roles[0];
    }
}
