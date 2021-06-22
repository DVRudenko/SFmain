/**
 * Created by A.Syromyatnikov on 17.01.2019.
 */

@IsTest
public class WorkcomUserPrizesReportTableCtrlTest {

    @testSetup static void init() {
        Profile p = ([
                SELECT Id
                FROM Profile
                WHERE Name = 'API Only'
        ]);
        UserRole r = ([
                SELECT Name
                FROM UserRole
                WHERE Name = 'GPC Rus'
        ]);
        User user = new User(
                Username = 'newusertest@fleetcor.ru',
                ProfileId = p.Id,
                UserRoleId = r.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8',
                LastName = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Europe/Moscow',
                UserPermissionsWorkDotComUserFeature = true,
                Points__c = 100,
                Earned_Points__c = 100);
        insert user;
    }


    @IsTest
    public static void test() {
        User user = ([
                SELECT Id, UserRoleId
                FROM User
                WHERE Username = 'newusertest@fleetcor.ru'
        ]);

        Prize__c prize = new Prize__c(Cost__c = 10, Name = 'test');
        insert prize;

        UserPrizeAssociation__c userPrizeAssociation = new UserPrizeAssociation__c(Prize__c = prize.Id, User__c = user.Id);
        insert userPrizeAssociation;

        WorkcomUserPrizesReportTableController workcomReportTableController = new WorkcomUserPrizesReportTableController();
        workcomReportTableController.getUserPrizeAssociationList();
        workcomReportTableController.first();
        workcomReportTableController.last();
        workcomReportTableController.next();
        workcomReportTableController.previous();

    }

}