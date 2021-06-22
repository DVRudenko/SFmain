@IsTest
public with sharing class PhoneNumbersHandlerTest {
    @IsTest
    private static void testAddIrrelevantNumber () { // test moving phones from phone fields to irrelevant phones (on the record or the global list)
        Contact con = new Contact(
            Salutation = 'Herr',
            FirstName = 'test name',
            LastName = 'test1',
            Phone = '+7955 622 5334',
            MobilePhone = '+7955 02 55334'
        );
        insert con;

        Map <String, String> irrelevantPhones_StatusReasonsMap = new  Map <String, String> {
            con.Phone => '0',
            con.MobilePhone => '1'
        };
        PhoneNumbersHandler.addIrrelevantNumber (con, irrelevantPhones_StatusReasonsMap);
        update con;
        Contact irrelevantOnRecord = [SELECT Irrelevant_Phones__c FROM Contact WHERE Id = :con.Id][0];
        IrrelevantPhone__c irrelevantGlobal = [SELECT Phone__c, StatusReason__c FROM IrrelevantPhone__c LIMIT 1][0];
        System.assertEquals('+79556225334', irrelevantGlobal.Phone__c);
        System.assertEquals('0', irrelevantGlobal.StatusReason__c);
        System.assertEquals('+79550255334:1', irrelevantOnRecord.Irrelevant_Phones__c);
    }
    @IsTest
    private static void testAddAdditionalNumbersToPhoneFields () { // test moving phones from Additional_Phones__c field to phone fields on the record
        Account acc1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            Name = 'test acc',
            Phone = '+7495 622 0000',
            Phone_Status__c = 'New',
            BillingCountry = 'Russia'
        );
        insert acc1;
        
        List <String> conPhoneFields = GlobalUtils.getFieldSetMembersAPIs(Schema.Contact.sObjectType, 'All_Phone_Fields');
        String phoneField1 = conPhoneFields [0];
        String phoneField2 = conPhoneFields [1];
        String phoneField3 = conPhoneFields [2];
        String phoneField4 = conPhoneFields [3];
        String phoneField5 = conPhoneFields [4];
        String phoneField6 = conPhoneFields [5];

        Contact con1 = new Contact( // one field is filled only: Phone field
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            AccountId = acc1.Id,
            Salutation = 'Herr',
            FirstName = 'name',
            LastName = 'test'
        );
        con1.put(phoneField1, '+7495 622 1111 #001');
        con1.put(PhoneNumbersHandler.getPhoneStatusField(phoneField1), 'New');

        Contact con2 = new Contact( // 2 fields are fiiled: Phone and MobilePhone
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            AccountId = acc1.Id,
            Salutation = 'Herr',
            FirstName = 'name',
            LastName = 'test'
        );
        con2.put(phoneField1, '+7495 622 1111 #001');
        con2.put(PhoneNumbersHandler.getPhoneStatusField(phoneField1), 'New');
        con2.put(phoneField2, '+7495 622 2222 #002');
        con2.put(PhoneNumbersHandler.getPhoneStatusField(phoneField2), 'New');

        Contact con3 = new Contact( // 2 fields are fiiled: Phone and MobilePhone
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            AccountId = acc1.Id,
            Salutation = 'Herr',
            FirstName = 'name',
            LastName = 'test'
        );
        con3.put(phoneField1, '+7495 622 1111 #001');
        con3.put(PhoneNumbersHandler.getPhoneStatusField(phoneField1), 'New');
        con3.put(phoneField2, '+7495 622 2222 #002');
        con3.put(PhoneNumbersHandler.getPhoneStatusField(phoneField2), 'New');
        insert new List <Contact> {con1, con2, con3};

        Test.startTest();
        con1 = [SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c, AssistantPhone, AssistantPhone_Status__c, 
                       HomePhone, HomePhone_Status__c, OtherPhone, OtherPhone_Status__c, 
                       PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c, Additional_Phones__c 
                FROM Contact WHERE Id = :con1.Id];
        con1.Additional_Phones__c = '+78465212147#456.+487872221245';
        PhoneNumbersHandler.addAdditionalNumbersToPhoneFields (con1);
        
        System.assertEquals('+7495 622 1111 #001', con1.get(phoneField1));
        System.assertEquals('New', con1.get(PhoneNumbersHandler.getPhoneStatusField(phoneField1)));
        System.assertEquals('+78465212147#456', con1.get(phoneField2));
        System.assertEquals('New', con1.get(PhoneNumbersHandler.getPhoneStatusField(phoneField2)));
        System.assertEquals('+487872221245', con1.get(phoneField3));
        System.assertEquals('New', con1.get(PhoneNumbersHandler.getPhoneStatusField(phoneField3)));
        System.assertEquals(null, con1.Additional_Phones__c);
        
        con2 = [SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c, AssistantPhone, AssistantPhone_Status__c, 
                       HomePhone, HomePhone_Status__c, OtherPhone, OtherPhone_Status__c, 
                       PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c, Additional_Phones__c 
                FROM Contact WHERE Id = :con2.Id];
        con2.Additional_Phones__c = '+78465212147#456.+487872221245.+4541511555.+54151588152.+78452152158.+45656666#112';
        PhoneNumbersHandler.addAdditionalNumbersToPhoneFields (con2);
        
        System.assertEquals('+7495 622 1111 #001', con2.get(phoneField1));
        System.assertEquals('New', con2.get(PhoneNumbersHandler.getPhoneStatusField(phoneField1)));
        System.assertEquals('+7495 622 2222 #002', con2.get(phoneField2));
        System.assertEquals('New', con2.get(PhoneNumbersHandler.getPhoneStatusField(phoneField2)));
        System.assertEquals('+78465212147#456', con2.get(phoneField3));
        System.assertEquals('New', con2.get(PhoneNumbersHandler.getPhoneStatusField(phoneField3)));
        System.assertEquals('+487872221245', con2.get(phoneField4));
        System.assertEquals('New', con2.get(PhoneNumbersHandler.getPhoneStatusField(phoneField4)));
        System.assertEquals('+4541511555', con2.get(phoneField5));
        System.assertEquals('New', con2.get(PhoneNumbersHandler.getPhoneStatusField(phoneField5)));
        System.assertEquals('+54151588152', con2.get(phoneField6));
        System.assertEquals('New', con2.get(PhoneNumbersHandler.getPhoneStatusField(phoneField6)));
        System.assertEquals('+78452152158.+45656666#112', con2.Additional_Phones__c);
        
        con3 = [SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c, AssistantPhone, AssistantPhone_Status__c, 
                       HomePhone, HomePhone_Status__c, OtherPhone, OtherPhone_Status__c, 
                       PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c, Additional_Phones__c 
                FROM Contact WHERE Id = :con3.Id];
        con3.Phone_Status__c = 'Wrong number:0'; // irrelevant on a global list
        update con3;
        con3.Additional_Phones__c = '+78465212147#456.+487872221245.+4541511555.+54151588152.+78452152158.+45656666#112';
        PhoneNumbersHandler.addAdditionalNumbersToPhoneFields (con3);
        System.assertEquals('+78465212147#456', con3.get(phoneField1));
        System.assertEquals('New', con3.get(PhoneNumbersHandler.getPhoneStatusField(phoneField1)));
        System.assertEquals('+7495 622 2222 #002', con3.get(phoneField2));
        System.assertEquals('New', con3.get(PhoneNumbersHandler.getPhoneStatusField(phoneField2)));
        System.assertEquals('+487872221245', con3.get(phoneField3));
        System.assertEquals('New', con3.get(PhoneNumbersHandler.getPhoneStatusField(phoneField3)));
        System.assertEquals('+4541511555', con3.get(phoneField4));
        System.assertEquals('New', con3.get(PhoneNumbersHandler.getPhoneStatusField(phoneField4)));
        System.assertEquals('+54151588152', con3.get(phoneField5));
        System.assertEquals('New', con3.get(PhoneNumbersHandler.getPhoneStatusField(phoneField5)));
        System.assertEquals('+78452152158', con3.get(phoneField6));
        System.assertEquals('New', con3.get(PhoneNumbersHandler.getPhoneStatusField(phoneField6)));
        System.assertEquals('+45656666#112', con3.Additional_Phones__c);
        
        Test.stopTest();
    }

    @IsTest
    private static void testCheckIrrelevantNumbers () { // don't save a phone number to a phone field if this number is in one of irrelevant lists
        String phone1 = '+7954 622 5334';
        String phone2 = '+7954 02 55334';
        String phone3 = null;

        Contact con = new Contact(
            RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            Salutation = 'Herr',
            FirstName = 'test name',
            LastName = 'test1',
            Phone = phone1,
            MobilePhone = phone2,
            PPR_Contact_Phone__c = phone3,
            Irrelevant_Phones__c = '+76664485254;+75220255822'
        );
        insert con;
        String phoneNum = '+71111255445';
        IrrelevantPhone__c irrelevantPhone = new IrrelevantPhone__c (
            Phone__c = phoneNum,
            Phone_NoExtension__c = PhoneNumbersHandler.trimPhoneNumber (phoneNum, false),
            StatusReason__c = '0'
        );
        insert irrelevantPhone;
        
        String phone1_new = '+766644 85254#455'; // irrelevant on the record
        String phone2_new = '+7111 125 5445'; // irrelevant in global list
        String phone3_new = '+73325533332'; // not irrelevant
        
        con.Phone = phone1_new; // irrelevant
        con.MobilePhone = phone2_new; // irrelevant global
        con.PPR_Contact_Phone__c = phone3_new; // not irrelevant
        update con;
        Contact conResult = [SELECT Id, Phone, MobilePhone, PPR_Contact_Phone__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals(phone1, conResult.Phone); // new phone number is NOT saved
        System.assertEquals(phone2, conResult.MobilePhone); // new phone number is NOT saved
        System.assertEquals(phone3_new, conResult.PPR_Contact_Phone__c); // new phone number is saved
    }
@IsTest
    private static void testProcessAfterUpdate () { // test changing account on contact record
    // if account is changed and the new account has irrelevant phone as on the contact then remove irrelevant phone from the new account 
        Account acc1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            Name = 'test acc',
            Phone = '+74956220000',
            Phone_Status__c = 'New',
            BillingCountry = 'Russia',
            Irrelevant_Phones__c = null,
            Irrelevant_Phones_ModifiedDate__c = null
        );
        Account acc2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            Name = 'test acc2',
            Phone = '+74956220002',
            Phone_Status__c = 'New',
            BillingCountry = 'Russia',
            Irrelevant_Phones__c = '+79250001112:4d', // irrelevant phone is the same as MobilePhone on the contact record
            Irrelevant_Phones_ModifiedDate__c = '+79250001112:1112201521'
        );
        insert new List <Account> {acc1, acc2};

        Contact con1 = new Contact( // one field is filled only: Phone field
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            AccountId = acc1.Id,
            Salutation = 'Herr',
            FirstName = 'name',
            LastName = 'test',
            Phone =  '+74956221111#001',
            MobilePhone = '+79250001112', // the same number as the irrelevant phone number on acc2
            Phone_Status__c = 'New'
        );
        insert con1;

        Test.startTest();
        con1.AccountId = acc2.Id; // change account from acc1 to acc2
        update con1;
        Account updatedAcc = [SELECT Irrelevant_Phones__c, Irrelevant_Phones_ModifiedDate__c
                FROM Account WHERE Id = :acc2.Id];
        System.assertEquals(null, updatedAcc.Irrelevant_Phones__c);
        System.assertEquals(null, updatedAcc.Irrelevant_Phones_ModifiedDate__c);
        Test.stopTest();
    }

    @IsTest
    private static void testSetPhoneStatusModifiedDate () { // test setting date/time of changing phone status on record: Phone_StatusModifiedDate__c field
        Lead lead = new Lead(
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId(),
            FirstName = 'test name',
            LastName = 'test1',
            Phone = '+7 495 111 1111',
            MobilePhone = '+7 495 222 2222',
            Additional_Phones__c = '+74953333333#233.+74954444444.+74955555555',
            Description = 'text 1.',
            Country = 'Russia',
            Company = 'TestCompany'
        );
        insert lead;
        lead = (Lead) Database.query('SELECT Phone_StatusModifiedDate__c FROM Lead WHERE Id = \'' + lead.Id + '\'')[0];
        //SF-1293 start
        System.assertEquals(system.now().dateGMT(), lead.Phone_StatusModifiedDate__c.dateGMT());
        //SF-1293 end
    }
    @IsTest
    private static void testGetPhoneStatusReasons () { // get map of all irrelevant phones statuses reasons: status codes => status labels
        Map<String, String> statusReasonsMap = PhoneNumbersHandler.getPhoneStatusReasons();
    }
    @IsTest
    private static void testGetPhoneStatuses_Disqual () { // disqualification statuses reasons: status codes => status labels
        Map <String, String> disqualStatusesMap = PhoneNumbersHandler.getPhoneStatuses_Disqual ();
    }
    @IsTest
    private static void testPhoneNumbersHandler () {
        Lead lead = new Lead(
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId(),
            FirstName = 'test name',
            LastName = 'test1',
            Phone = '+7 495 111 1111',
            MobilePhone = '+7 495 222 2222',
            PPR_Contact_Phone__c = '+74951221221',
            Additional_Phones__c = '+74953333333!New!!0207202135.+74954444444.+74955555555',
            Description = 'text 1.',
            Country = 'Russia',
            Company = 'TestCompany',
            Irrelevant_Phones__c = '+79250001112#333:4d',
            Irrelevant_Phones_ModifiedDate__c = '+79250001112#333:1112201521'
        );
        insert lead;

        Test.startTest();
        PhoneNumbersHandler.sObjWrapper sObjWrap = new PhoneNumbersHandler.sObjWrapper(lead, null);
        PhoneNumbersHandler.sObjWrapper sObjWrap2 = PhoneNumbersHandler.createSObjWrapper (lead);
        List<String> phoneFieldsAPIs = PhoneNumbersHandler.getAllPhoneFields (Schema.Lead.sObjectType);
        Map <String, String> unifiedPhonesMap = sObjWrap.getUnifiedNumbersMap(new List<String> {'Phone'}, false);
        Map<String, String> phoneStatusesMap = PhoneNumbersHandler.getPhoneStatusesTranslations(Schema.Lead.SObjectType);
        Map<String, String> phoneStatusesTranslations = PhoneNumbersHandler.getPhoneStatusesTranslations(Schema.Lead.SObjectType);

        String transl1 = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation ('New');
        String transl2 = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation ('Needs validation');
        String transl3 = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation ('Successful dialing');
        String transl4 = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation ('Wrong number:0');
        String transl5 = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation ('CTI Wrong number - Doesn\'t exist');
        String transl6 = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation ('CTI System Error');
        String transl1_abbr = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation (transl1);
        String transl2_abbr = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation (transl2);
        String transl3_abbr = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation (transl3);
        String transl4_abbr = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation (transl4);
        String transl5_abbr = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation (transl5);
        String transl6_abbr = PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation (transl6);

        String additionalPhoneItem = PhoneNumbersHandler.getAdditionalPhonelItemByPhone (lead, '+74953333333', false);
        system.assertEquals('+74953333333!New!!0207202135', additionalPhoneItem);

        Map <String, String> irrelevantPhonesToReasonsMap = PhoneNumbersHandler.getIrrelevantPhonesToReasonsMap (lead);
        PhoneNumbersHandler.removeIrrelevantNumber_fromRecord(lead, '+74951221221');
        Test.stopTest();
    }
    @IsTest
    private static void testCheckPhoneDuplicates() {
        // create leads to test phones duplicates on a record
        Lead lead = new Lead(
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId(),
            FirstName = 'test name',
            LastName = 'test1',
            Phone = '+7 495 111 1111',
            MobilePhone = '+7 495 222 2222',
            Additional_Phones__c = '+74953333333#233.+74954444444.+74955555555',
            Description = 'text 1.',
            Country = 'Russia',
            Company = 'TestCompany'
        );
        Lead lead_1_case1 = lead.clone();
        Lead lead_1_case2 = lead.clone();
        Lead lead_1_case3 = lead.clone();
        Lead lead_1_case4 = lead.clone();
        Lead lead_1_case5 = lead.clone();
        
        Lead lead_2_case1 = lead.clone();
        Lead lead_2_case2 = lead.clone();
        Lead lead_2_case3 = lead.clone();
        Lead lead_2_case4 = lead.clone();
        
        Lead lead_3_case1 = lead.clone();
        Lead lead_3_case2 = lead.clone();
        Lead lead_3_case3 = lead.clone();
        Lead lead_3_case4 = lead.clone();
        
        insert new List <Lead> {lead_1_case1, lead_1_case2, lead_1_case3, lead_1_case4, lead_1_case5,
                                lead_2_case1, lead_2_case2, lead_2_case3, lead_2_case4, 
                                lead_3_case1, lead_3_case2, lead_3_case3, lead_3_case4};
        
        Test.startTest();
// 1) a new value is entered in a phone field (PPR_Contact_Phone__c)
    
    // CASE 1: the new value on PPR_Contact_Phone__c duplicates Phone field value

        // a) previous value was null 
        // result : PPR_Contact_Phone__c - new value is saved
        //          Phone  - duplicated value is cleared, phone from additional phones is moved to the Phone field
        lead_1_case1.PPR_Contact_Phone__c = '+7 495 1111111'; // set new phone value
        update lead_1_case1;
        lead_1_case1 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_1_case1.Id][0];
        System.assertEquals('+74953333333#233', lead_1_case1.Phone); // phone from additional phones
        System.assertEquals('New', lead_1_case1.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_1_case1.MobilePhone);
        System.assertEquals('New', lead_1_case1.MobilePhone_Status__c);
        System.assertEquals('+7 495 1111111', lead_1_case1.PPR_Contact_Phone__c); // new value is saved
        System.assertEquals('New', lead_1_case1.PPR_Contact_Phone_Status__c);
        System.assertEquals('+74954444444.+74955555555', lead_1_case1.Additional_Phones__c);

        // b) previous value was not null
            // result : PPR_Contact_Phone__c - new value is saved
            //          Phone  - duplicated value is cleared and previous value of PPR_Contact_Phone__c is moved on its place
        lead_1_case1.PPR_Contact_Phone__c = '+7 495 0000000'; // set the previous value
        update lead_1_case1;
        
        lead_1_case1.PPR_Contact_Phone__c = '+7 495 1111111'; // set the new phone value
        update lead_1_case1;
        lead_1_case1 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_1_case1.Id][0];
        System.assertEquals('+74953333333#233', lead_1_case1.Phone); // phone from additional phones
        System.assertEquals('New', lead_1_case1.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_1_case1.MobilePhone);
        System.assertEquals('New', lead_1_case1.MobilePhone_Status__c);
        System.assertEquals('+7 495 1111111', lead_1_case1.PPR_Contact_Phone__c); // new value is saved
        System.assertEquals('New', lead_1_case1.PPR_Contact_Phone_Status__c);
        System.assertEquals('+74954444444.+74955555555', lead_1_case1.Additional_Phones__c);
        
    // CASE 2: the new values duplicate additional_phones__c values
        // result: save new values on phone fields
        // remove duplicates from additonal phones
        // move previous values from phone fields to additional phones
        lead_1_case2.MobilePhone = '+7 495 4444444';
        lead_1_case2.PPR_Contact_Phone__c = '+7 4955555555';
        update lead_1_case2;
        lead_1_case2 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_1_case2.Id][0];
        System.assertEquals('+7 495 111 1111', lead_1_case2.Phone);
        System.assertEquals('New', lead_1_case2.Phone_Status__c);
        System.assertEquals('+7 495 4444444', lead_1_case2.MobilePhone); // save the new value
        System.assertEquals('New', lead_1_case2.MobilePhone_Status__c);
        System.assertEquals('+7 4955555555', lead_1_case2.PPR_Contact_Phone__c); // save the new value
        System.assertEquals('New', lead_1_case2.PPR_Contact_Phone_Status__c);
        System.assertEquals(true, lead_1_case2.Additional_Phones__c.contains('+74953333333#233')); // leave this value in additional phones field
        System.assertEquals(true, lead_1_case2.Additional_Phones__c.contains('+74952222222')); // move previous value from mobile phone to additional phones
        System.assertEquals(false, lead_1_case2.Additional_Phones__c.contains('+74954444444')); // remove MobilePhone value duplicate from additonal phones 
        System.assertEquals(false, lead_1_case2.Additional_Phones__c.contains('+74955555555'));// remove PPR_Contact_Phone__c value duplicate from additonal phones 

    // CASE 3: as the CASE 1, but the new value contains an extension number
    // result: save the new number as the extension number is different
        lead_1_case3.PPR_Contact_Phone__c = '+7 495 1111111#123';
        update lead_1_case3;
        lead_1_case3 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_1_case3.Id][0];
        System.assertEquals('+7 495 111 1111', lead_1_case3.Phone);
        System.assertEquals('New', lead_1_case3.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_1_case3.MobilePhone);
        System.assertEquals('New', lead_1_case3.MobilePhone_Status__c);
        System.assertEquals('+7 495 1111111#123', lead_1_case3.PPR_Contact_Phone__c); // leave previous value - null
        System.assertEquals('New', lead_1_case3.PPR_Contact_Phone_Status__c);
        System.assertEquals('+74953333333#233.+74954444444.+74955555555', lead_1_case3.Additional_Phones__c);   
    
    // CASE 4: as the CASE 2, but the new value contains an extension number
    // result: leave numbers in additional phones as the number with extension is different
        lead_1_case4.MobilePhone = '+7 495 3333333#456'; // duplicates additional phones number, but the extension number id different
        lead_1_case4.PPR_Contact_Phone__c = '+7 4954444444 #555'; // duplicates additional phones number, but the extension number id different
        update lead_1_case4;
        lead_1_case4 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_1_case4.Id][0];
        System.assertEquals('+7 495 111 1111', lead_1_case4.Phone);
        System.assertEquals('New', lead_1_case4.Phone_Status__c);
        System.assertEquals('+7 495 3333333#456', lead_1_case4.MobilePhone); // save the new value
        System.assertEquals('New', lead_1_case4.MobilePhone_Status__c);
        System.assertEquals('+7 4954444444 #555', lead_1_case4.PPR_Contact_Phone__c); // save the new value
        System.assertEquals('New', lead_1_case4.PPR_Contact_Phone_Status__c);
        System.assertEquals('+74953333333#233.+74954444444.+74955555555', lead_1_case4.Additional_Phones__c); // leave numbers in additional phones as the number with extension is different
    
    // CASE 5: new value duplicates a new value on a phone field
    // result: don't save the new phone number, leave an old one
        lead_1_case5.MobilePhone = '+74958888888'; // duplicates additional phones number, but the extension number id different
        lead_1_case5.Phone = '+74958888888'; // duplicates additional phones number, but the extension number id different
        update lead_1_case5;
        lead_1_case5 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_1_case5.Id][0];
        System.assertEquals('+74958888888', lead_1_case5.Phone);
        System.assertEquals('New', lead_1_case5.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_1_case5.MobilePhone); // leave the previous value
        System.assertEquals('New', lead_1_case5.MobilePhone_Status__c);
        System.assertEquals('+74953333333#233', lead_1_case5.PPR_Contact_Phone__c); // move value from additional phones
        System.assertEquals('New', lead_1_case5.PPR_Contact_Phone_Status__c);
        System.assertEquals('+74954444444.+74955555555', lead_1_case5.Additional_Phones__c); // leave numbers in additional phones as the number with extension is different
    
    
// 2) a new value is entered in Additional_Phones__c field
    
    // CASE 1: the new value duplicates another phone field value
    // result : the new value will not be saved on additonal phones field
        lead_2_case1.Additional_Phones__c = lead.Additional_Phones__c;
        lead_2_case1.Additional_Phones__c += '.' + '+74951111111'; // this value duplicates 'Phone' field
        lead_2_case1.Additional_Phones__c += '.' + '+74950000000'; // this value doesn't duplicate any other values
        update lead_2_case1;
        lead_2_case1 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_2_case1.Id][0];
        System.assertEquals('+7 495 111 1111', lead_2_case1.Phone); // leave the duplicated value on Phone field
        System.assertEquals('New', lead_2_case1.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_2_case1.MobilePhone);
        System.assertEquals('New', lead_2_case1.MobilePhone_Status__c);
        System.assertEquals('+74953333333#233', lead_2_case1.PPR_Contact_Phone__c); // value is moved from additional phones
        System.assertEquals('New', lead_2_case1.PPR_Contact_Phone_Status__c); // set 'New' status for the phone number from additional phones
        System.assertEquals('+74954444444.+74955555555.+74950000000', lead_2_case1.Additional_Phones__c); // don't save the duplicated number
    
    // CASE 2: the new value duplicates additional_phones__c phone value
    // result: leave the previous value on additional phones
        lead_2_case2.Additional_Phones__c = lead.Additional_Phones__c;
        lead_2_case2.Additional_Phones__c += '.' + '+74954444444'; // this value duplicates another value in additional phones field
        lead_2_case2.Additional_Phones__c += '.' + '+74950000000'; // this value doesn't duplicate any other values
        update lead_2_case2;
        lead_2_case2 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_2_case2.Id][0];
        System.assertEquals('+7 495 111 1111', lead_2_case2.Phone); // leave value on phone field
        System.assertEquals('New', lead_2_case2.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_2_case2.MobilePhone);
        System.assertEquals('New', lead_2_case2.MobilePhone_Status__c);
        System.assertEquals('+74953333333#233', lead_2_case1.PPR_Contact_Phone__c); // value is moved from additional phones
        System.assertEquals('New', lead_2_case1.PPR_Contact_Phone_Status__c); // set 'New' status for the phone number from additional phones
        System.assertEquals('+74954444444.+74955555555.+74950000000', lead_2_case1.Additional_Phones__c); // don't save the duplicated number

    // CASE 3: as the CASE 1, but the new value with extension number is different
    // result: save the number with new extension
        lead_2_case3.Additional_Phones__c = lead.Additional_Phones__c;
        lead_2_case3.Additional_Phones__c += '.' + '+74951111111#454'; // this value duplicates 'Phone' field, but extension number is different
        lead_2_case3.Additional_Phones__c += '.' + '+74950000000'; // this value doesn't duplicate any other values
        update lead_2_case3;
        lead_2_case3 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_2_case3.Id][0];
        System.assertEquals('+7 495 111 1111', lead_2_case3.Phone); // leave value on phone field
        System.assertEquals('New', lead_2_case3.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_2_case3.MobilePhone);
        System.assertEquals('New', lead_2_case3.MobilePhone_Status__c);
        System.assertEquals('+74953333333#233', lead_2_case3.PPR_Contact_Phone__c); // value is moved from additional phones
        System.assertEquals('New', lead_2_case3.PPR_Contact_Phone_Status__c); // set 'New' status for the phone number from additional phones
        System.assertEquals('+74954444444.+74955555555.+74951111111#454.+74950000000', lead_2_case3.Additional_Phones__c); // don't save the duplicated number
        
    // CASE 4: as the CASE 2, but the new value contains an extension number
    // result: save the number with new extension because value with another extension is not counted s a duplicate
        lead_2_case4.Additional_Phones__c = lead.Additional_Phones__c;
        lead_2_case4.Additional_Phones__c += '.' + '+74953333333#454'; // this value duplicates another phone on additional phones field, but extension number is different
        lead_2_case4.Additional_Phones__c += '.' + '+74950000000'; // this value doesn't duplicate any other values
        update lead_2_case4;
        lead_2_case4 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_2_case4.Id][0];
        System.assertEquals('+7 495 111 1111', lead_2_case4.Phone); // leave value on phone field
        System.assertEquals('New', lead_2_case4.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_2_case4.MobilePhone);
        System.assertEquals('New', lead_2_case4.MobilePhone_Status__c);
        System.assertEquals('+74953333333#233', lead_2_case4.PPR_Contact_Phone__c); // value is moved from additional phones
        System.assertEquals('New', lead_2_case4.PPR_Contact_Phone_Status__c); // set 'New' status for the phone number from additional phones
        System.assertEquals('+74954444444.+74955555555.+74953333333#454.+74950000000', lead_2_case4.Additional_Phones__c);  // save the new value as extension number is different
    
// 3) a new value is entered in a phone field and Additional_Phones__c field
    
    // CASE 1: the new value duplicates another phone field value
    // result : PPR_Contact_Phone__c - new value is saved
    //          Phone  - duplicated value is cleared, phone from additional phones is moved to the Phone field
    //          Additional_Phones_c: the new valueis not saved on additonal phones field
        lead_3_case1.PPR_Contact_Phone__c = '+7 495 1111111'; // duplicates 'Phone' field
        lead_3_case1.Additional_Phones__c = lead.Additional_Phones__c; 
        lead_3_case1.Additional_Phones__c += '.' + '+74951111111'; // this value duplicates 'Phone' field
        lead_3_case1.Additional_Phones__c += '.' + '+74950000000'; // this value doesn't duplicate any other values
        update lead_3_case1;
        lead_3_case1 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_3_case1.Id][0];
        System.assertEquals('+74953333333#233', lead_3_case1.Phone); // leave value on phone field
        System.assertEquals('New', lead_3_case1.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_3_case1.MobilePhone);
        System.assertEquals('New', lead_3_case1.MobilePhone_Status__c);
        System.assertEquals('+7 495 1111111', lead_3_case1.PPR_Contact_Phone__c); // leave previous value - null
        System.assertEquals('New', lead_3_case1.PPR_Contact_Phone_Status__c);
        System.assertEquals('+74954444444.+74955555555.+74950000000', lead_3_case1.Additional_Phones__c); // don't save a duplicate number
    
    // CASE 2: the new value duplicates additional_phones__c phone value
    // result: save a new value and remove duplicates from additonal phones
        system.debug('3:2');
        lead_3_case2.PPR_Contact_Phone__c = '+7 495 4444444'; // duplicates additional_phones__c phone value
        lead_3_case2.Additional_Phones__c = lead.Additional_Phones__c;
        lead_3_case2.Additional_Phones__c += '.' + '+74954444444'; // this value duplicates additional_phones__c phone value
        lead_3_case2.Additional_Phones__c += '.' + '+74950000000'; // this value doesn't duplicate any other values
        update lead_3_case2;
        lead_3_case2 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_3_case2.Id][0];
        System.assertEquals('+7 495 111 1111', lead_3_case2.Phone); // leave value on phone field
        System.assertEquals('New', lead_3_case2.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_3_case2.MobilePhone);
        System.assertEquals('New', lead_3_case2.MobilePhone_Status__c);
        System.assertEquals('+7 495 4444444', lead_3_case2.PPR_Contact_Phone__c); // leave previous value - null
        System.assertEquals('New', lead_3_case2.PPR_Contact_Phone_Status__c); // leave previous status - null
        System.assertEquals(true, lead_3_case2.Additional_Phones__c.contains('+74953333333#233')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case2.Additional_Phones__c.contains('+74955555555')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case2.Additional_Phones__c.contains('+74950000000')); // leave this value in additional phones field
        System.assertEquals(false, lead_3_case2.Additional_Phones__c.contains('+74954444444')); // remove PPR_Contact_Phone__c value duplicate from additonal phones

    // CASE 3: as the CASE 1, but the new value with extension number is different
    // result: save the number with new extension
        lead_3_case3.PPR_Contact_Phone__c = '+7 495 1111111#002'; // duplicates 'Phone' field
        lead_3_case3.Additional_Phones__c = lead.Additional_Phones__c;
        lead_3_case3.Additional_Phones__c += '.' + '+74951111111#003'; // this value duplicates 'Phone' field
        lead_3_case3.Additional_Phones__c += '.' + '+74950000000'; // this value doesn't duplicate any other values
        update lead_3_case3;
        lead_3_case3 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_3_case3.Id][0];
        System.assertEquals('+7 495 111 1111', lead_3_case3.Phone); // leave value on phone field
        System.assertEquals('New', lead_3_case3.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_3_case3.MobilePhone);
        System.assertEquals('New', lead_3_case3.MobilePhone_Status__c);
        System.assertEquals('+7 495 1111111#002', lead_3_case3.PPR_Contact_Phone__c); // save the new value as extension number is different
        System.assertEquals('New', lead_3_case3.PPR_Contact_Phone_Status__c);
        System.assertEquals(true, lead_3_case3.Additional_Phones__c.contains('+74953333333#233')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case3.Additional_Phones__c.contains('+74954444444')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case3.Additional_Phones__c.contains('+74955555555')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case3.Additional_Phones__c.contains('+74950000000')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case3.Additional_Phones__c.contains('+74951111111#003')); // remove PPR_Contact_Phone__c value duplicate from additonal phones

    // CASE 4: as the CASE 2, but the new value contains an extension number
    // result: save the number with new extension
        lead_3_case4.PPR_Contact_Phone__c = '+7 495 4444444 #002'; // the same as on additional_phones__c but with an extension
        lead_3_case2.Additional_Phones__c = lead.Additional_Phones__c;
        lead_3_case4.Additional_Phones__c += '.' + '+74954444444#003'; // the same as on additional_phones__c but with an extension
        lead_3_case4.Additional_Phones__c += '.' + '+74950000000'; // this value doesn't duplicate any other values
        update lead_3_case4;
        lead_3_case4 = [SELECT Phone, Phone_Status__c, 
                               MobilePhone, MobilePhone_Status__c,
                               PPR_Contact_Phone__c, PPR_Contact_Phone_Status__c,
                               Additional_Phones__c
                        FROM Lead WHERE Id = :lead_3_case4.Id][0];
        System.assertEquals('+7 495 111 1111', lead_3_case4.Phone); // leave value on phone field
        System.assertEquals('New', lead_3_case4.Phone_Status__c);
        System.assertEquals('+7 495 222 2222', lead_3_case4.MobilePhone);
        System.assertEquals('New', lead_3_case4.MobilePhone_Status__c);
        System.assertEquals('+7 495 4444444 #002', lead_3_case4.PPR_Contact_Phone__c);  // save the new value as extension number is different
        System.assertEquals('New', lead_3_case4.PPR_Contact_Phone_Status__c);
        System.assertEquals('+74953333333#233.+74954444444.+74955555555.+74954444444#003.+74950000000', lead_3_case4.Additional_Phones__c);  // save the new value as extension number is different
        System.assertEquals(true, lead_3_case4.Additional_Phones__c.contains('+74953333333#233')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case4.Additional_Phones__c.contains('+74954444444')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case4.Additional_Phones__c.contains('+74955555555')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case4.Additional_Phones__c.contains('+74950000000')); // leave this value in additional phones field
        System.assertEquals(true, lead_3_case4.Additional_Phones__c.contains('+74954444444#003')); // save this value in additional phones
 
        Test.stopTest();
    }

    @IsTest
    private static void testParsePhoneNumber() { // test parsing a phone number from an external source
        LeadSourceSettings__c leadSourceSettings = new LeadSourceSettings__c (SetupOwnerId = UserInfo.getUserId(), IsExternalSource__c = true);
        insert leadSourceSettings;

        Lead l0 = new Lead(
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId(),
            FirstName = 'test name',
            LastName = 'test1',
            Description = 'text 1.',
            Country = 'Russia',
            CountryCode = 'RU',
            Company = 'TestCompany', 
            Phone = '+7954 622 5334'
        );
    
        Lead l1 = l0.clone();
        l1.LastName = 'l1';
        l1.Phone = '89038747440 доб.2';

        Lead l2 = l0.clone();
        l2.LastName = 'l2';
        l2.Phone = '03496 / 30252 0';

        Lead l3 = l0.clone();
        l3.LastName = 'l3';
        l3.Phone = '+7-672-82-39-000';

        Lead l4 = l0.clone();
        l4.LastName = 'l4';
        l4.Phone = '+74995556664 тест';

        insert new List <Lead> {l0, l1, l2, l3, l4};

        Lead l0_new = [SELECT Phone, Phone_Status__c FROM Lead WHERE Id = :l0.Id];
        system.assertEquals('+7954 622 5334', l0_new.Phone);
        system.assertEquals('New', l0_new.Phone_Status__c);

        Lead l1_new = [SELECT Phone, Phone_Status__c FROM Lead WHERE Id = :l1.Id];
        system.assertEquals('89038747440 #2', l1_new.Phone);
        system.assertEquals('New', l1_new.Phone_Status__c);

        Lead l2_new = [SELECT Phone, Phone_Status__c FROM Lead WHERE Id = :l2.Id];
        system.assertEquals('03496 / 30252 0', l2_new.Phone);
        system.assertEquals('Needs validation', l2_new.Phone_Status__c);

        Lead l3_new = [SELECT Phone, Phone_Status__c FROM Lead WHERE Id = :l3.Id];
        system.assertEquals('+76728239000', l3_new.Phone);
        system.assertEquals('New', l3_new.Phone_Status__c);

        Lead l4_new = [SELECT Phone, Phone_Status__c, Description FROM Lead WHERE Id = :l4.Id];
        system.assertEquals('+74995556664', l4_new.Phone);
        system.assertEquals('New', l4_new.Phone_Status__c);
        system.assertEquals(l0.Description + ' [Business Phone:тест]', l4_new.Description );
        
    }
}