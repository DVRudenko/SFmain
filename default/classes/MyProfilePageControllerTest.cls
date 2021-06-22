/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
 */
@IsTest
public with sharing class MyProfilePageControllerTest {
    @IsTest
    static void testSetContactFields() {
        User u = [
                SELECT Title, FirstName, LastName, Email, Phone, MobilePhone, Fax, Street, City, State, PostalCode, Country
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];

        Contact c = new Contact();

        MyProfilePageController.setContactFields(c, u);
        System.assertEquals(c.FirstName, u.FirstName, 'firstname should have been set as the firstname of the user for the contact');
        System.assertEquals(c.LastName, u.LastName, 'lastname should have been set as the lastname of the user for the contact');
    }

    @IsTest
    static void testSave() {
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT Id, ProfileId, UserRoleId FROM User WHERE UserRoleId <> NULL AND UserType = 'CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
            User currentUser = [
                    SELECT Id, Title, FirstName, LastName, Email, Phone, MobilePhone, Fax, Street, City, State, PostalCode, Country
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
            ];
            MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
            System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
            controller.edit();
            System.assert(controller.getIsEdit() == true);
            controller.cancel();
            System.assert(controller.getIsEdit() == false);

            Contact c = new Contact();
            c.LastName = 'TestContact';
            c.Salutation = 'Herr';
            insert c;

            c.Title = currentUser.Title;
            c.FirstName = currentUser.FirstName;
            c.LastName = currentUser.LastName;
            c.Email = currentUser.Email;
            c.Phone = currentUser.Phone;
            c.MobilePhone = currentUser.MobilePhone;
            c.Fax = currentUser.Fax;
            c.MailingStreet = currentUser.Street;
            c.MailingCity = currentUser.City;
            c.MailingState = currentUser.State;
            c.MailingPostalCode = currentUser.PostalCode;
            c.MailingCountry = currentUser.Country;
            controller.save();
            System.assert(Page.ChangePassword.getUrl().equals(controller.changePassword().getUrl()));
        } else {
            User existingPortalUser = existingPortalUsers[0];
            String randFax = Math.rint(Math.random() * 1000) + '5551234';

            System.runAs(existingPortalUser) {
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(existingPortalUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
                controller.edit();
                System.assert(controller.getIsEdit() == true);

                controller.cancel();
                System.assert(controller.getIsEdit() == false);

                controller.getUser().Fax = randFax;
                controller.save();
                System.assert(controller.getIsEdit() == false);
            }

            // verify that the user and contact were updated
            existingPortalUser = [SELECT Id, Fax, Contact.Fax FROM User WHERE Id = :existingPortalUser.Id];
            System.assert(existingPortalUser.Fax == randFax);
            System.assert(existingPortalUser.Contact.Fax == randFax);
        }
    }
}