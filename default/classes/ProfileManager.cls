public with sharing class ProfileManager {
    public static Profile getProfileByName(String profileName) {
        if (String.isBlank(profileName)) {
            return null;
        }

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :profileName];
        return profiles.isEmpty() ? null : profiles[0];
    }

    public static Profile getUserProfileById(Id profileId) {
        return (profileId == null) ? null : [SELECT Name FROM Profile WHERE Id = :profileId];
    }
}