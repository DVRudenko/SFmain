public without sharing class UnlockRecordButtonController {

    @AuraEnabled
    public static Boolean isButtonVisible(Id recordId) {
        List<Profile> profileList = [
            SELECT  Name
            FROM    Profile
            WHERE   Id =: Userinfo.getProfileId()
            AND    (Name = 'Credit'
            OR      Name = 'CCS System Administrator'
            OR      Name = 'System Administrator'
            OR      Name = 'CCS Service Agent'
            OR      Name = 'CCS Service Manager'
            OR      Name = 'Service Agent'
            OR      Name = 'Service Manager')
        ];
        return Approval.isLocked(recordId) && (profileList.size() == 1);
    }
    
    @AuraEnabled
    public static void unlockRecord(Id recordId) {
        Approval.UnlockResult unlockResult = Approval.unlock(recordId);
        if( !unlockResult.isSuccess() ) {
            throw new AuraHandledException('Error' + unlockResult.getErrors());
        }
    }
}
