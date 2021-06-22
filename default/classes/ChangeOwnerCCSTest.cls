@isTest
global without sharing class ChangeOwnerCCSTest {
    webservice static testMethod void changeOwner(){
        User u = new User();
        u.Lastname = 'Last';
        u.Username = 'infointercodec@intercodec.cz';
        u.Email = 'info@intercodec.cz';
        u.Alias = 'test';
        u.CommunityNickname = 'testINTERCODEC';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = '00e0O000001VEUW';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        User u2 = new User();
        u2.Lastname = 'Last';
        u2.Username = 'infointerco@intercodec.cz';
        u2.Email = 'info@intercodec.cz';
        u2.Alias = 'test2';
        u2.CommunityNickname = 'testINTR';
        u2.TimeZoneSidKey = 'GMT';
        u2.LocaleSidKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        u2.ProfileId = '00e0O000001VEUW';
        u2.LanguageLocaleKey = 'en_US';
        insert u2;
        
        Contact c = new Contact();
        c.LastName = 'Last';
        c.Salutation = 'Herr';
        c.OwnerId = u.id;
        insert c;
        
        String cid = c.ID;
        String us = u2.ID;
        Boolean result2 = cid.equals(us);
        
        Contact cont = [SELECT Owner.Id FROM Contact where Id = :cid];
        User use = [SELECT Id FROM User where Id = :us];
        Test.startTest();
        cont.OwnerId = use.Id;
        update cont;
        Test.stopTest();
        
        Contact result = [SELECT Owner.Id FROM Contact WHERE Owner.Id = :use.Id];
        System.assertEquals(result2, false);
        System.assertEquals(cont.OwnerId, u2.id);
        System.assertEquals(result.OwnerId, use.Id);
    }
}