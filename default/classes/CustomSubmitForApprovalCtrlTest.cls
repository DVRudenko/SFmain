@isTest
private class CustomSubmitForApprovalCtrlTest {
    public static User u;
    public static Account newAccount;
    public static Opportunity newOpportunity;
    public static EmailTemplate newEmailTeamplte;


    /*******************************************************************************
    *  Name            : submitForApprovalValidAllStarCase()
    *  Summary         : testing submit for approval (valid case) 
    *  CreatedDate     : 25/05/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalValidCase() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newOpportunity.OwnerId = u.Id;
            update newOpportunity;
            createEmailTemplate();

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
            controller.preporationEmailsForSending('Information_Required_to_Credit');
            controller.saveAndBack();
            controller.backToOpportunity();
            controller.changeRegisteredCountry();
        }
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest1()
    *  Summary         : testing submit for approval for Germany
    *  CreatedDate     : 02/07/2017
    *  ModifiedDate    : 13/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest1() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'Germany';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest2()
    *  Summary         : testing submit for approval for Belgium-NL
    *  CreatedDate     : 02/07/2017
    *  ModifiedDate    : 13/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest2() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'Belgium-NL';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest3()
    *  Summary         : testing submit for approval for Netherlands
    *  CreatedDate     : 02/07/2017
    *  ModifiedDate    : 13/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest3() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'Netherlands';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*****************************************************************************
    *  Name            : submitForApprovalEuroshellTest4()
    *  Summary         : testing submit for approval for Hungary
    *  CreatedDate     : 02/07/2017
    *  ModifiedDate    : 13/06/2019
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest4() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'Hungary';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /******************************************************************************
    *  Name            : submitForApprovalEuroshellTest5()
    *  Summary         : testing submit for approval for Poland
    *  CreatedDate     : 02/07/2017
    *  ModifiedDate    : 13/06/2019
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest5() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'Poland';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest6()
    *  Summary         : testing submit for approval for Switzerland-IT
    *  CreatedDate     : 02/07/2017
    *  ModifiedDate    : 13/06/2019
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest6() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'Switzerland-IT';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest7()
    *  Summary         : testing submit for approval for Luxembourg
    *  CreatedDate     : 02/07/2017
    *  ModifiedDate    : 13/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest7() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'Luxembourg';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }

    
    
    @isTest
    public static void submitForApprovalEuroshellTest8() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Czech Republic';
            account.BillingCountryCode = 'CZ';
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            insert opportunity;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest10()
    *  Summary         : Send valid CHDE opportunity for approval
    *  CreatedDate     : 10/10/2018
    *. ModifiedDate    : 30/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest10() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Switzerland-DE';
            account.BillingCountryCode = 'CHDE';
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            insert opportunity;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest11()
    *  Summary         : Send valid CHIT opportunity for approval
    *  CreatedDate     : 18/10/2018
    *. ModifiedDate    : 30/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest11() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Switzerland-IT';
            account.BillingCountryCode = 'CHIT';
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            insert opportunity;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest12()
    *  Summary         : Send valid CHFR opportunity for approval
    *  CreatedDate     : 18/10/2018
    *. ModifiedDate    : 30/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest12() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Switzerland-FR';
            account.BillingCountryCode = 'CHFR';
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            insert opportunity;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest9()
    *  Summary         : Send valid AT opportunity for approval
    *  CreatedDate     : 10/10/2018
    *. ModifiedDate    : 30/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest9() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Austria';
            account.BillingCountryCode = 'AT';
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            insert opportunity;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest9()
    *  Summary         : Send valid LU opportunity for approval
    *  CreatedDate     : 21/11/2018
    *. ModifiedDate    : 30/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest13() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Luxembourg';
            account.BillingCountryCode = 'LU';
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            insert opportunity;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }
    
    
    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest14()
    *  Summary         : Testing submit for approval with "Rejected" status
    *  CreatedDate     : 25/10/2019
    *  ModifiedDate    : 30/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest14() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Germany';
            account.BillingCountryCode = 'DE';
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            insert opportunity;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(opportunity.Id);
                req.setSubmitterId(opportunity.OwnerId);
            Approval.process(req);
            
            Set<Id> pIds = (new Map<Id, ProcessInstance>([
                    SELECT Id, Status, TargetObjectId
                    FROM ProcessInstance 
                    WHERE Status = 'Pending' AND TargetObjectId = :opportunity.Id])).keySet();
            
            Set<Id> pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([
                    SELECT Id,ProcessInstanceId 
                    FROM ProcessInstanceWorkitem 
                    WHERE ProcessInstanceId in :pIds])).keySet();
            
            for (Id pInstanceWorkitemsId : pInstanceWorkitems) {
                Approval.ProcessWorkitemRequest request2 = new Approval.ProcessWorkitemRequest();
                request2.setAction('Reject');
                request2.setWorkitemId(pInstanceWorkitemsId);
                Approval.ProcessResult result2 = Approval.process(request2);
                break;
            }
            
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }
    
    
    /*******************************************************************************
    *  Summary         : Send valid SK opportunity for approval
    *  CreatedDate     : 10/02/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest15() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'Slovakia';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Send valid CZ opportunity for approval
    *  CreatedDate     : 10/02/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest16() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'Czech Republic';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Send valid FR opportunity for approval
    *  CreatedDate     : 10/02/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest17() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            newAccount.BillingCountry = 'France';
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                req.setSubmitterId(newOpportunity.OwnerId);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            TaskTriggerHandler.enablesTrigger = false;
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
        }
    }


    /*******************************************************************************
    *  Name            : submitForApprovalCarnetTest()
    *  Summary         : Submit carnet opportunity for approval
    *  CreatedDate     : 10/04/2019
    *. ModifiedDate    : 30/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalCarnetTest2() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Carnet' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            opportunity.StageName = 'Pending Sales – Information';
            opportunity.Product__c = 'Carnet Standard 2019';
            insert opportunity;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setSubmitterId(u.Id);
            req.setObjectId(opportunity.Id);
            req.setSubmitterId(opportunity.OwnerId);
            Approval.process(req);

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
        } 
    }
    
    
    /*******************************************************************************
    *  Name            : submitForApprovalLotosTest()
    *  Summary         : Submit opportunity for "Lotos" approval
    *  CreatedDate     : 25/11/2019
    *. ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalLotosTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Lotos' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            opportunity.Product__c = 'Home Station offer (v.1)';
            opportunity.Home_Station__c = 'test';
            opportunity.ESI__c = 'test';
            insert opportunity;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setSubmitterId(u.Id);
            req.setObjectId(opportunity.Id);
            req.setSubmitterId(opportunity.OwnerId);
            Approval.process(req);

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            
            opportunity = [
                    SELECT Credit_Stage__c, StageName 
                    FROM Opportunity 
                    WHERE Id = :opportunity.Id
            ];
            
            System.assertEquals('Credit Check - Pending Credit', opportunity.Credit_Stage__c);
            System.assertEquals('Qualify', opportunity.StageName);
        } 
    }


    /*******************************************************************************
    *  Summary         : Submit opportunity for "CCS" approval CZ
    *  CreatedDate     : 10/06/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalCCSTest1() {
        Test.startTest();
        createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Czech Republic';
            account.BillingCountryCode = 'CZ';
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'CCS Opportunity Layout' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            insert opportunity;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setSubmitterId(u.Id);
            req.setObjectId(opportunity.Id);
            req.setSubmitterId(opportunity.OwnerId);
            Approval.process(req);

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        }
    }


    /*******************************************************************************
    *  Summary         : Submit opportunity for "CCS" approval SK
    *  CreatedDate     : 10/06/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalCCSTest2() {
        Test.startTest();
        createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Slovakia';
            account.BillingCountryCode = 'SK';
            insert account;

            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'CCS Opportunity Layout' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            insert opportunity;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setSubmitterId(u.Id);
            req.setObjectId(opportunity.Id);
            req.setSubmitterId(opportunity.OwnerId);
            Approval.process(req);

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        }
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryGermanyTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 21/12/2017
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryGermanyTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Germany';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryBelgiumNLTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 28/05/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryBelgiumNLTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Belgium-NL';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryBelgiumFRTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 21/12/2017
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryBelgiumFRTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;


            newAccount.BillingCountry = 'Belgium-FR';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /******************************************************************************
    *  Name            : validateCreditFactoryNetherlandsTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 21/12/2017
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void validateCreditFactoryNetherlandsTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Netherlands';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryFranceTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 21/12/2017
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryFranceTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'France';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryPolandTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 19/01/2018
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryPolandTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Poland';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryAustriaTest()
    *  Summary         : Launch CF for valid AT opportunity.
    *  CreatedDate     : 10/10/2018
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryAustriaTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Austria';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactorySwitzerlandDETest()
    *  Summary         : Launch CF for valid CHDE opportunity.
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactorySwitzerlandDETest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Switzerland-DE';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactorySwitzerlandITTest()
    *  Summary         : Launch CF for valid CHIT opportunity.
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactorySwitzerlandITTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Switzerland-IT';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactorySwitzerlandFRTest()
    *  Summary         : Launch CF for valid CHFR opportunity.
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactorySwitzerlandFRTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Switzerland-FR';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryLuxembourgTest()
    *  Summary         : Launch CF for valid LU opportunity.
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryLuxembourgTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Luxembourg';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryHungaryTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 19/01/2018
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryHungaryTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Hungary';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryHungaryTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 19/01/2018
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactorySlovakiaTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Slovakia';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        }
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryHungaryTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 19/01/2018
    *  ModifiedDate    : 28/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryCzechRepublicTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            Contact contact = returnContact(newAccount.Id);
            insert contact;
            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, newOpportunity.Id);
            insert contactRole;
            
            newAccount.BillingCountry = 'Czech Republic';
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        }
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryRelaunch()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 13/06/2019
    *  ModifiedDate    : 25/07/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryRelaunch() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            Account account = returnAccount();
            account.BillingCountry = 'Germany';
            insert account;

            TaskTriggerHandler.enablesTrigger = false; // remove mixed DML operation in test (user, task)
            Opportunity opportunity = returnOpportunity(account.Id);
            RecordType recordType = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            opportunity.RecordTypeId = recordType.Id;
            opportunity.bearbeitet_von__c = 'Autoprocessed by Sales';
            opportunity.StageName = 'Pending Sales – Deposit';
            opportunity.Product__c = 'Home Station offer (v.1)';
            opportunity.Home_Station__c = 'test';
            opportunity.ESI__c = 'test';
            opportunity.IBAN__c = 'DE89370400440532013000';
            insert opportunity;

            Contact contact = returnContact(account.Id);
            insert contact;

            OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, opportunity.Id);
            insert contactRole;
            
            IBAN_BIC__c ibanBicSettings = new IBAN_BIC__c(
                Name = 'Production',
                User_Name__c = 'test',
                Password__c = 'test',
                Active__c = false,
                Endpoint__c = 'test'
            );
            
            insert ibanBicSettings;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', opportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
            controller.redirectToCreditFactory();

            List<Opportunity> opList = [
                    SELECT Relaunch_CF__c
                    FROM Opportunity
                    WHERE Id = :opportunity.Id];

            System.assertEquals(1, opList.get(0).Relaunch_CF__c);
        } 
    }
    
    
    /*******************************************************************************
    *  Name            : testSendingBicRequest()
    *  Summary         : Test sending request to BIC
    *  CreatedDate     : 30/10/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSendingBicRequest() {
        Account account = returnAccount();
        account.BillingCountry = 'Germany';
        account.BillingCountryCode = 'DE';
        insert account;

        Opportunity opportunity = returnOpportunity(account.Id);
        opportunity.RecordTypeId = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1].Id;
        opportunity.Product__c = 'Home Station offer (v.1)';
        opportunity.Home_Station__c = 'test';
        opportunity.ESI__c = 'test';
        opportunity.IBAN__c = 'DE89370400440532013000';
        opportunity.SWIFT_BIC__c = null;
        insert opportunity;

        Contact contact = returnContact(account.Id);
        insert contact;

        OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, opportunity.Id);
        insert contactRole;
        
        IBAN_BIC__c ibanBicSettings = new IBAN_BIC__c(
                Name = 'Production',
                User_Name__c = 'test',
                Password__c = 'test',
                Active__c = true,
                Endpoint__c = 'test'
        );
        
        insert ibanBicSettings;
        
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('type', 'creditfactory');
        
        Test.startTest();
            SingleRequestMock bicMock = new SingleRequestMock(200, 'Complete', '{"iban": "DE89370400440532013000","result": "passed","return_code": 0,"checks": ["length","bank_code","account_number","iban_checksum"],"bic_candidates": [{"bic": "COBADEFFXXX","zip": "50447","city": "Köln","wwwcount": 0,"sampleurl": ""}],"all_bic_candidates": [{"bic": "COBADEFFXXX","zip": "50447","city": "Köln","wwwcount": 0,"sampleurl": ""}],"country": "DE","bank_code": "37040044","bank_and_branch_code": "37040044","bank": "Commerzbank","bank_address": "50447 Köln","bank_street": "","bank_city": "Köln","bank_state": "","bank_postal_code": "50447","bank_url": "","branch": "","branch_code": "","in_scl_directory": "yes","sct": "yes","sdd": "yes","cor1": "no","b2b": "yes","scc": "yes","sct_inst": "yes","sct_inst_readiness_date": "2018-11-05","account_number": "0532013000","account_validation_method": "13","account_validation": "Methode 13, Konto 0532013000, BLZ 37040044, Prüfziffer 0 steht an Position 8, erwartete Prüfziffer: 0. Überblick über die Berechnung: Nimm die Ziffern auf den Positionen 2 bis 7 - hier: 532013 -, multipliziere sie von rechts nach links mit den Gewichten 2,1,2,1,2,1, addiere die Quersummen der Produkte, bilde den Rest der Division durch 10, ziehe das Ergebnis von 10 ab,  und das Ergebnis modulo 10 ist die erwartete Prüfziffer.","length_check": "passed","account_check": "passed","bank_code_check": "passed","iban_checksum_check": "passed","data_age": "20190812","iban_listed": "www","iban_www_occurrences": "65","www_seen_from": "2015-07-15","www_seen_until": "2016-11-01","iban_url": "http://id.wikipedia.org/wiki/Nomor_Rekening_Bank_Internasional","url_rank": "7","url_category": "參考/百科全書","url_min_depth": "2","www_prominence": "","iban_reported_to_exist": 0,"iban_last_reported": "","iban_candidate": "DE89370400440532013000","IBANformat": "DEkk BBBB BBBB CCCC CCCC CC","formatcomment": "B = sort code (BLZ), C = account No.","balance": 100206}', null);
            Test.setMock(HttpCalloutMock.class, bicMock);
            
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            controller.init();
            controller.redirectToCreditFactory();
        Test.stopTest();
        
        Opportunity testOpportunity = [
                SELECT SWIFT_BIC__c, Requested_SWIFT_BIC__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        
        System.assertEquals('COBADEFFXXX', testOpportunity.Requested_SWIFT_BIC__c);
        System.assertEquals('COBADEFFXXX', testOpportunity.SWIFT_BIC__c);
    }
    
    /*******************************************************************************
    *  Name            : testLotosCreditFactory()
    *  Summary         : Test CF launch for Lotos
    *  CreatedDate     : 11/12/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testLotosCreditFactory() {
        Account account = returnAccount();
        account.BillingCountry = 'Poland';
        account.BillingCountryCode = 'PL';
        insert account;

        Opportunity opportunity = returnOpportunity(account.Id);
        opportunity.RecordTypeId = [SELECT Name FROM RecordType WHERE Name = 'Lotos' AND sObjectType = 'Opportunity' LIMIT 1].Id;
        opportunity.Product__c = 'Home Station offer (v.1)';
        opportunity.Home_Station__c = 'test';
        opportunity.ESI__c = 'test';
        insert opportunity;

        Contact contact = returnContact(account.Id);
        insert contact;

        OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, opportunity.Id);
        insert contactRole;
        
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('type', 'creditfactory');
        
        Test.startTest();
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            controller.init();
        Test.stopTest();
    }


    /*******************************************************************************
    *  Summary         : Test CF launch for CCS CZ
    *  CreatedDate     : 10/06/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCCSCreditFactoryCZ() {
        Account account = returnAccount();
        account.BillingCountry = 'Czech Republic';
        account.BillingCountryCode = 'CZ';
        insert account;

        Opportunity opportunity = returnOpportunity(account.Id);
        opportunity.RecordTypeId = [SELECT Name FROM RecordType WHERE Name = 'CCS Opportunity Layout' AND sObjectType = 'Opportunity' LIMIT 1].Id;
        opportunity.Product__c = 'Home Station offer (v.1)';
        opportunity.Home_Station__c = 'test';
        opportunity.ESI__c = 'test';
        insert opportunity;

        Contact contact = returnContact(account.Id);
        insert contact;

        OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, opportunity.Id);
        insert contactRole;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('type', 'creditfactory');

        Test.startTest();
        CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
        controller.init();
        Test.stopTest();
    }


    /*******************************************************************************
    *  Summary         : Test CF launch for CCS SK
    *  CreatedDate     : 10/06/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCCSCreditFactorySK() {
        Account account = returnAccount();
        account.BillingCountry = 'Slovakia';
        account.BillingCountryCode = 'SK';
        insert account;

        Opportunity opportunity = returnOpportunity(account.Id);
        opportunity.RecordTypeId = [SELECT Name FROM RecordType WHERE Name = 'CCS Opportunity Layout' AND sObjectType = 'Opportunity' LIMIT 1].Id;
        opportunity.Product__c = 'Home Station offer (v.1)';
        opportunity.Home_Station__c = 'test';
        opportunity.ESI__c = 'test';
        insert opportunity;

        Contact contact = returnContact(account.Id);
        insert contact;

        OpportunityContactRole contactRole = returnOpportunityontactRole(contact.Id, opportunity.Id);
        insert contactRole;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('type', 'creditfactory');

        Test.startTest();
        CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
        controller.init();
        Test.stopTest();
    }


    @future
    private static void createSalesUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='API Only'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'AllStar Sales'];
        
        u = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_233232321_test@test.com',
            Alias = 'batman',
            Email='bruce.wayne_1233@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(u);    
    }

    private static void createAccount() {
        List<Account> accountsList = new List<Account>();
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Account' LIMIT 1];
        newAccount = new Account(
            RecordTypeId = rt.Id,
            Name = 'test account',
            Trading_Name__c = 'test trading name',
            NIP__c = '1234567899',
            REGON__c = '9987654321',
            KRS__c = '1234554321',
            Gesellschaftsform__c = 'Sole trader',
            Phone = '+48 7777777',
            Mobile_Phone__c = '+48 3333333',
            Website = 'testsite.com',
            BillingCountry = 'Poland',
            BillingStreet = 'street name',
            BillingCity = 'Warsaw',
            BillingPostalCode = '123455',
            Bundesland__c = 'Berlin',
            Allstar_Email__c = 'test@test.com',
            ShippingStreet = 'shipping street',
            ShippingCity = 'Warsaw',
            ShippingPostalCode = '123455',
            ShippingCountry = 'Poland',
            Beschaeftigte__c = '5-9',
            Branche_NACE__c = 'Manufacturing',
            Web_form_password__c = 'password123',
            Steuernummer__c = '1234512345',
            Umsatzsteuer_ID__c = '1234512345'
        );   
        insert newAccount;
    }

    private static void createOpportunity() {
        RecordType rt = [SELECT Name FROM RecordType WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
            OwnerId = u.Id,
            RecordTypeId = rt.Id,
            Name = 'test opportunity',  
            Anzahl_der_Karten__c = 123,
            Name_of_the_payer_Account_holder__c = 'test payer',
            Language_preference__c = 'Polish',
            Total_consumption_l_month__c = 123,
            Derzeitige_Zahlungsmethode__c = 'Bankkarte',
            Zahlungssystem__c = 'Visa',
            Bank__c = 'bank',
            Zahlungsart__c = 'Lastschrift',
            IBAN__c = '1234567789',
            SWIFT_BIC__c = '987654321',
            Requested_monthly_Company_Credit_Spend__c = 12345,
            AGB_Datenschutzhinweise_Richtigkeit__c = true,
            Direct_Debit_Mandate_Type__c = 'Core',
            Data_Protection_Act_1998__c = true,
            Umsatz__c = '123', 
            AccountId = newAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(14),
            Bevollmaechtigung__c = true,
            CF_Stage__c = 'Launched',
            Last_CF_Errors__c = 'error',
            bearbeitet_von__c = 'Autoprocessed by Sales'
        );
        insert newOpportunity;
    }

    private static void createEmailTemplate() {
        newEmailTeamplte = new EmailTemplate(
            Name = 'Email with URL to Form',
            DeveloperName = 'Information_Required_to_Credit',
            Subject = 'Request Information',
            Body = 'test',
            TemplateType = 'Text',
            FolderId = UserInfo.getUserId()
        );
        insert newEmailTeamplte;
    }


    /*******************************************************************************
    *  Name            : returnAccount()
    *  Summary         : return test Account    
    *  CreatedDate     : 11/04/2019
    *  ModifiedDate    : 04/11/2019
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    private static Account returnAccount() {
        Account account = new Account(
            Name = 'test account',
            Trading_Name__c = 'test trading name',
            NIP__c = '1234567899',
            REGON__c = '9987654321',
            KRS__c = '1234554321',
            Gesellschaftsform__c = 'Sole trader',
            Phone = '+48 7777777',
            Mobile_Phone__c = '+48 3333333',
            Website = 'testsite.com',
            BillingCountry = 'Poland',
            BillingStreet = 'street name',
            BillingCity = 'Warsaw',
            BillingPostalCode = '123455',
            Bundesland__c = 'Berlin',
            Allstar_Email__c = 'test@test.com',
            ShippingStreet = 'shipping street',
            ShippingCity = 'Warsaw',
            ShippingPostalCode = '123455',
            ShippingCountry = 'Poland',
            Beschaeftigte__c = '5-9',
            Branche_NACE__c = 'Manufacturing',
            Web_form_password__c = 'password123',
            Steuernummer__c = '1234512345',
            Umsatzsteuer_ID__c = '1234512345'
        );   
        return account;
    }


    /*******************************************************************************
    *  Name            : returnOpportunity()
    *  Summary         : return test Opportunity     
    *  CreatedDate     : 11/04/2019
    *  ModifiedDate    : 30/10/2019
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    private static Opportunity returnOpportunity(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'test opportunity',  
            Anzahl_der_Karten__c = 123,
            Name_of_the_payer_Account_holder__c = 'test payer',
            Language_preference__c = 'Polish',
            Total_consumption_l_month__c = 123,
            Derzeitige_Zahlungsmethode__c = 'Bankkarte',
            Zahlungssystem__c = 'Visa',
            Bank__c = 'bank',
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
            IBAN__c = '1234567789',
            SWIFT_BIC__c = '987654321',
            Requested_monthly_Company_Credit_Spend__c = 12345,
            AGB_Datenschutzhinweise_Richtigkeit__c = true,
            Data_Protection_Act_1998__c = true,
            Umsatz__c = '123', 
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(14),
            Bevollmaechtigung__c = true,
            CF_Stage__c = 'Launched',
            Last_CF_Errors__c = 'error',
            Sec_Channel__c = 'Outbound',
            Pricing_Approval_Status__c = 'Not required'
        );
        
        if (u != null) opportunity.OwnerId = u.Id;
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : returnContact(String accountId)
    *  Summary         : Return test Contact.  
    *  CreatedDate     : 28/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    private static Contact returnContact(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            FirstName = 'testFirstName',
            LastName = 'testLastName',
            Email = 'test@test.email',
            AccountId = accountId);
        return contact;
    }


    /*******************************************************************************
    *  Name            : returnOpportunityontactRole(String contactId, String opportunityId)
    *  Summary         : Return test contact role.   
    *  CreatedDate     : 28/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String contactId - id of related Сontact, 
                         String opportunityId - id of related Opportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole returnOpportunityontactRole(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager',
            IsPrimary = true);
        return opportunityContactRole;
    }
}