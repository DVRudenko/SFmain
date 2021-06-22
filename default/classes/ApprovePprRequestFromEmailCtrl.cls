public class ApprovePprRequestFromEmailCtrl {

    public Boolean isGoToRecord { get; set; }
    public Boolean isCommentForRejectComboBox { get; set; }
    public Boolean isCommentForRejectTextArea { get; set; }
    public String reasonReject { get; set; }
    public String commentReject { get; set; }
    public Boolean isCommentForConfirmComboBox { get; set; }
    public Boolean isCommentForConfirmTextArea { get; set; }
    public String reasonConfirm { get; set; }
    public String commentConfirm { get; set; }
    private Set<String> approverEmails = Ru_Admin_Approver__c.getAll().keySet();

    /*******************************************************************************
*  Name            : init()
*  Summary         : Start Method loaded from VF page
*  CreatedDate     : 01/11/2017
*  Parameters      : -
*  Returns         : void
******************************************************************************/
    public void init() {
        isGoToRecord = false;
        isCommentForRejectComboBox = false;
        isCommentForRejectTextArea = false;
        isCommentForConfirmComboBox = false;
        isCommentForConfirmTextArea = false;
        String typeRequest = ApexPages.currentPage().getParameters().get('type');
        String answer = ApexPages.currentPage().getParameters().get('Answer');
        String idRecord = ApexPages.currentPage().getParameters().get('idRecord');
        String idNewOwner = ApexPages.currentPage().getParameters().get('idNewOwner');
        if (typeRequest == '001') {
            changeOwnerFromFindDuplicates(idRecord, idNewOwner, answer);
        } else if (typeRequest == '002') {
            changeOwnerRecordByTeamLead(idRecord, idNewOwner, answer);
        } else if (typeRequest == '003') {
            processingRequestForSecondOpportunity(idRecord, idNewOwner, answer);
        } else if (typeRequest == '004') {
            changeOwnerAccountByTeamLead(idRecord, idNewOwner, answer);
        }
    }

    /*******************************************************************************
*  Name            : goToRecord()
*  Summary         : return PageReference to record, that uses in page
*  CreatedDate     : 01/11/2017
*  Parameters      : -
*  Returns         : PageReference
******************************************************************************/
    public PageReference goToRecord() {
        String idRecord = ApexPages.currentPage().getParameters().get('idRecord');
        return new PageReference('/' + idRecord);
    }

    /*******************************************************************************
*  Name            : getReasonsForReject()
*  Summary         : create list for combobox to chouse reject reason
*  CreatedDate     : 01/11/2017
*  Parameters      : -
*  Returns         : List<SelectOption>
******************************************************************************/
    public List<SelectOption> getReasonsForReject() {
        List<SelectOption> listReasons = new List<SelectOption>();
        String typeRequest = ApexPages.currentPage().getParameters().get('type');
        if (typeRequest == '001') {
            List<RU_RejectReasonText__c> rejectReasonTexts = [
                    SELECT id,name,text__c,shorttext__c
                    FROM Ru_RejectReasonText__c
                    WHERE name LIKE 'RejectByAdmin%'
                    ORDER BY NAME
            ];
            for (Ru_RejectReasonText__c reasonText : rejectReasonTexts) {
                listReasons.add(new SelectOption(reasonText.text__c, reasonText.shorttext__c));
            }
        }
        return listReasons;
    }

    public List<SelectOption> getReasonsForConfirm() {
        List<SelectOption> listReasons = new List<SelectOption>();
        List<Ru_ConfirmReasonText__c> confirmReasonTexts = [
                SELECT Id, Name, text__c, shorttext__c
                FROM Ru_ConfirmReasonText__c
                ORDER BY Name
        ];
        for (Ru_ConfirmReasonText__c reasonText : confirmReasonTexts) {
            listReasons.add(new SelectOption(reasonText.text__c, reasonText.shorttext__c));
        }
        return listReasons;
    }

    /*******************************************************************************
*  Name            : rejectRequest()
*  Summary         : action when user confirms reject
*  CreatedDate     : 01/11/2017
*  Parameters      : -
*  Returns         : void
******************************************************************************/
    public void rejectRequest() {
        try {
            String idRecord = ApexPages.currentPage().getParameters().get('idRecord');
            String idNewOwner = ApexPages.currentPage().getParameters().get('idNewOwner');
            String typeRequest = ApexPages.currentPage().getParameters().get('type');

            String innRecord;
            //VS SF-265
            String companyRecord;
            String typeName = ID.valueOf(idRecord).getSObjectType().getDescribe().getName();
            if (typeName == 'Lead') {
                List<Lead> recordList = [SELECT Id, INN__c, Company FROM Lead WHERE Id = :idRecord];
                innRecord = recordList[0].INN__c;
                companyRecord = recordList[0].Company;
            } else if (typeName == 'Opportunity') {
                List<Opportunity> recordList = [SELECT Id, INN_Opp__c, account.Name FROM Opportunity WHERE Id = :idRecord];
                innRecord = recordList[0].INN_Opp__c;
                companyRecord = recordList[0].account.Name;
            }

            String rejectMessage = getReasonRejectMessage();

            if (typeRequest == '001') {
                List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                        'Результат запроса на запись',
                        '<p>Ваш запрос на получение записи "' + idRecord + '" <p/>' + 
                        '<p>Инн : ' + innRecord + '</p>' +
                        '<p>Наименование Компании : ' + companyRecord + '</p>' +
                        '<p>был отклонен ' + UserInfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
                                rejectMessage));
                emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(Userinfo.getUserId(),
                        'Отклоненный запрос на запись',
                        '<p>Запрос на получение записи "' + idRecord + '" <p/>' + 
                        '<p>Инн : ' + innRecord + '</p>' +
                        '<p>Наименование Компании : ' + companyRecord + '</p>' +
                        '<p>был Вами отклонен </p>' +
                                rejectMessage));
                Messaging.sendEmail(emailMessageList);

            } else if (typeRequest == '002') {
                List<Opportunity> listOwner = [SELECT ownerid from Opportunity WHERE id = :idRecord];
                EmailGenerator.sendHtmlEmail(listOwner.get(0).ownerid,
                        'Результат запроса на запись',
                        '<p>Ваш запрос на получение записи "' + idRecord + '" <p/>' + 
                        '<p>Инн : ' + innRecord + '</p>' +
                        '<p>Наименование Компании : ' + companyRecord + '</p>' +
                        '<p>был отклонен ' + UserInfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
                                rejectMessage
                );
            } else if (typeRequest == '003') {
                List<Opportunity> listOpportunities = [SELECT name, ownerid FROM Opportunity WHERE id = :idRecord AND ownerid = :UserInfo.getUserId()];
                if (listOpportunities.size() <> 0) {
                    EmailGenerator.sendHtmlEmail(idNewOwner,
                            'Результат запроса на запись',
                            '<p>Ваш запрос на создание второй в возможности ' + listOpportunities.get(0).name + ' <p/>' + 
                            '<p>Инн : ' + innRecord + '</p>' +
                            '<p>Наименование Компании : ' + companyRecord + '</p>' +
                            '<p>был отклонен ' + UserInfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
                                    rejectMessage
                    );
                    delete listOpportunities;
                }
            } else if (typeRequest == '004') {
                List<Account> listOwner = [SELECT ownerid from Account WHERE id = :idRecord];
                EmailGenerator.sendHtmlEmail(listOwner.get(0).ownerid,
                        'Результат запроса на запись',
                        '<p>Ваш запрос на перевод записи "' + idRecord + '" <p/>' + 
                        '<p>Инн : ' + innRecord + '</p>' +
                        '<p>Наименование Компании : ' + companyRecord + '</p>' +
                        '<p>был отклонен ' + UserInfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
                                    rejectMessage);
            }
            isCommentForRejectComboBox = false;
            isCommentForRejectTextArea = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0012_RequestRejected));
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка' + ' ' + e.getMessage()));
        }
    }

    public void confirmRequest() {
        try {
            String typeRequest = ApexPages.currentPage().getParameters().get('type');
            String answer = ApexPages.currentPage().getParameters().get('Answer');
            String idRecord = ApexPages.currentPage().getParameters().get('idRecord');
            String idNewOwner = ApexPages.currentPage().getParameters().get('idNewOwner');
            if (typeRequest == '001') {
                confirmFromFindDuplicates(idRecord, idNewOwner, answer);
            } else if (typeRequest == '002') {
                confirmRecordByTeamLead(idRecord, idNewOwner, answer);
            } else if (typeRequest == '003') {
                confirmForSecondOpportunity(idRecord, idNewOwner, answer);
            } else if (typeRequest == '004') {
                confirmAccountByTeamLead(idRecord, idNewOwner, answer);
            }

            isCommentForConfirmComboBox = false;
            isCommentForConfirmTextArea = false;
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка' + ' ' + e.getMessage()));
        }   
    }


    /*******************************************************************************
*  Name            : changeOwnerRecordByAdmin()
*  Summary         : type approve = 001. Change owner of Lead/Opportunity(Account) by Request from FindDuplicatesRu
*  CreatedDate     : 01/11/2017
*  Parameters      : (Id idRecord, Id idNewOwner, String answer)
*  Returns         : void
******************************************************************************/
    public void changeOwnerFromFindDuplicates(Id idRecord, Id idNewOwner, String answer) {
        try {
            List<Profile> profilesSysAdmin = [
                    SELECT id
                    FROM Profile
                    WHERE name = :Label.System_Administrator
            ];
            if (this.approverEmails.contains(UserInfo.getUserEmail()) || (profilesSysAdmin.isEmpty() == false) && (Userinfo.getProfileId() == profilesSysAdmin.get(0).id)) {
                if (answer == 'yes') {
                    isCommentForConfirmComboBox = true;
                    isCommentForConfirmTextArea = true;
                    isGoToRecord = true;
                } else if (answer == 'no') {
                    isCommentForRejectComboBox = true;
                    isCommentForRejectTextArea = true;
                    isGoToRecord = true;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0013_NoAccess));
            }
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged + ' ' + e.getMessage()));
        }
    }

    public void confirmFromFindDuplicates(Id idRecord, Id idNewOwner, String answer) {
        try {
            String typeName = idRecord.getSObjectType().getDescribe().getName();
            if (typeName == 'Lead') {
                //VS SF-1449 start
                List<Lead> leadForUpdate = [
                        SELECT Id, ownerId, INN__c, Company, Status
                        FROM lead
                        WHERE id = :idRecord
                        AND ownerid <> :idNewOwner
                ];
                if (leadForUpdate.size() <> 0) {
                    String idOldOwner = leadForUpdate[0].ownerid;
                    List<User> oldOwners = [
                        SELECT Id, Name, ManagerId 
                        FROM User 
                        WHERE Id = :idOldOwner
                    ];
                    User oldOwner = oldOwners.isEmpty() ? null : oldOwners.get(0);
                    //VS SF-1449 end
                    for (Lead lead : leadForUpdate) {
                        lead.ownerid = idNewOwner;
                    }
                    update leadForUpdate;
                    isGoToRecord = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0010_OwnerChanged));

                    String confirmMessage = getReasonConfirmMessage();

                    List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                    emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                            'Результат запроса на запись',
                            '<p>Ваш запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утвержден</p>' + 
                            '<p>Инн : ' + leadForUpdate[0].INN__c + '</p>' +
                            '<p>Наименование Компании : ' + leadForUpdate[0].Company + '</p>'));
                    emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(UserInfo.getUserId(),
                            'Утвержденнный запрос на запись',
                            '<p>Запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> был Вами Утвержден!</p>' + 
                            '<p>Инн : ' + leadForUpdate[0].INN__c + '</p>' +
                            '<p>Наименование Компании : ' + leadForUpdate[0].Company + '</p>'));
                    if (confirmMessage != null) {
                        //VS SF-1449 start
                        emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idOldOwner,
                            'Результат запроса на запись',
                            '<p>С вас переведена запись <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> </p>' + 
                            '<p>Инн : ' + leadForUpdate[0].INN__c + '</p>' +
                            '<p>Наименование Компании : ' + leadForUpdate[0].Company + '</p>' + 
                            '<p>Статус : ' + leadForUpdate[0].Status + '</p>' + confirmMessage));
                        if (oldOwner != null && oldOwner.ManagerId != null) {
                            //VS SF-1510
                            emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(oldOwner.ManagerId,
                                'Результат запроса на запись',
                                '<p>С ' + oldOwner.Name + ' переведена запись <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> </p>' + 
                                '<p>Инн : ' + leadForUpdate[0].INN__c + '</p>' +
                                '<p>Наименование Компании : ' + leadForUpdate[0].Company + '</p>' + 
                                '<p>Статус : ' + leadForUpdate[0].Status + '</p>' + confirmMessage));
                        }
                        //VS SF-1449 end
                    }
                    Messaging.sendEmail(emailMessageList);
                }
            } else if (typeName == 'Opportunity') {
                //VS SF-265
                List<Opportunity> targetOpportunity = [
                        SELECT id, owner.id, account.id, owner.email, INN_Opp__c, account.Name, StageName
                        FROM Opportunity
                        WHERE id = :idRecord
                        AND ownerid <> :idNewOwner
                ];
                if (targetOpportunity.size() == 1) {
                    List<Account> accountsForUpdate = [
                            SELECT id, owner.id
                            FROM Account
                            WHERE id = :targetOpportunity.get(0).account.id
                    ];
                    if (accountsForUpdate.size() == 1) {
                        Account accountForUpdate = accountsForUpdate.get(0);
                        accountForUpdate.ownerid = idNewOwner;
                        update accountForUpdate;

                        List<Opportunity> opportunitiesForUpdate = [
                                SELECT id, owner.id, account.id
                                FROM Opportunity
                                WHERE account.id = :accountForUpdate.id AND
                                StageName <> 'Moved to Start'
                        ];

                        String idOldOwner = opportunitiesForUpdate[0].ownerid;
						
                        //VS SF-1449
                        List<User> oldOwners = [
                            SELECT Id, Name, ManagerId 
                            FROM User 
                            WHERE Id = :idOldOwner
                        ];
                        User oldOwner = oldOwners.isEmpty() ? null : oldOwners.get(0);
						
                        for (Opportunity opportunityForUpdate : opportunitiesForUpdate) {
                            opportunityForUpdate.ownerid = idNewOwner;
                        }
                        update opportunitiesForUpdate;

                        isGoToRecord = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0010_OwnerChanged));

                        String confirmMessage = getReasonConfirmMessage();

                        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                        emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                                'Результат запроса на запись',
                                '<p>Ваш запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утвержден</p>' + 
                                '<p>Инн : ' + targetOpportunity[0].INN_Opp__c + '</p>' +
                                '<p>Наименование Компании : ' + targetOpportunity[0].account.Name + '</p>'));
                        emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(UserInfo.getUserId(),
                                'Утвержденнный запрос на запись',
                                '<p>Запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> был Вами Утвержден!</p>' + 
                                '<p>Инн : ' + targetOpportunity[0].INN_Opp__c + '</p>' +
                                '<p>Наименование Компании : ' + targetOpportunity[0].account.Name + '</p>'));
                        if (confirmMessage != null) {
                            //VS SF-1449 start
                            emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idOldOwner,
                                'Результат запроса на запись',
                                '<p>С вас переведена запись <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> </p>' + 
                                '<p>Инн : ' + targetOpportunity[0].INN_Opp__c + '</p>' +
                                '<p>Наименование Компании : ' + targetOpportunity[0].account.Name + '</p>' + 
                                '<p>Этап : ' + targetOpportunity[0].StageName + '</p>' + confirmMessage));
                            if (oldOwner != null && oldOwner.ManagerId != null) {
                                //VS SF-1510
                                emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(oldOwner.ManagerId,
                                    'Результат запроса на запись',
                                    '<p>С ' + oldOwner.Name + ' переведена запись <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> </p>' + 
                                    '<p>Инн : ' + targetOpportunity[0].INN_Opp__c + '</p>' +
                                    '<p>Наименование Компании : ' + targetOpportunity[0].account.Name + '</p>' + 
                                    '<p>Этап : ' + targetOpportunity[0].StageName + '</p>' + confirmMessage));
                            }
                            //VS SF-1449 end
                        }
                        Messaging.sendEmail(emailMessageList);
                    }
                }
            }
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged + ' ' + e.getMessage()));
        }
    }

    /*******************************************************************************
*  Name            : changeOwnerRecordByAdmin()
*  Summary         : type approve = 002. Change owner of Opportunity(Account) by Request from RussianSalesManager to his Manager(=TeamLeader)
*  CreatedDate     : 01/11/2017
*  Parameters      : (Id idRecord, Id idNewOwner, String answer)
*  Returns         : void
******************************************************************************/
    public void changeOwnerRecordByTeamLead(Id idRecord, Id idNewOwner, String answer) {
        try {
            //VS SF-265
            List<Opportunity> currentOpportunities = [
                    SELECT id, ownerid, owner.managerid, account.id, account.Name, INN_Opp__c
                    FROM Opportunity
                    WHERE id = :idRecord
                    AND Owner.ManagerId = :UserInfo.getUserId()
                    AND StageName <> 'Moved to Start'
            ];
            if (currentOpportunities.size() == 1) {
                if (answer == 'yes') {
                    isCommentForConfirmTextArea = true;
                } else if (answer == 'no') {
                    isCommentForRejectTextArea = true;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0007_OwnerCanNotBeChanged));
            }

        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged + ' ' + e.getMessage()));
        }
    }

    public void confirmRecordByTeamLead(Id idRecord, Id idNewOwner, String answer) {
        try {
            List<Opportunity> currentOpportunities = [
                    SELECT id, ownerid, owner.managerid, account.id, account.Name, INN_Opp__c
                    FROM Opportunity
                    WHERE id = :idRecord
                    AND Owner.ManagerId = :UserInfo.getUserId()
                    AND StageName <> 'Moved to Start'
            ];
            
            String idOldOwner = currentOpportunities.get(0).ownerid;
            List<Account> accountsForUpdate = [
                    SELECT id, owner.id, Opportunity_Sum__c
                    FROM Account
                    WHERE id = :currentOpportunities.get(0).account.id
                    AND Moved_to_Start__c = 0
            ];
            if (accountsForUpdate.size() == 1) {
                if (accountsForUpdate.get(0).Opportunity_Sum__c == 1) {
                    for (Account accountForUpdate : accountsForUpdate) {
                        accountForUpdate.ownerid = idNewOwner;
                    }
                    update accountsForUpdate;
                }
                for (Opportunity opportunity : currentOpportunities) {
                    opportunity.ownerid = idNewOwner;
                }
                update currentOpportunities;

                isGoToRecord = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0010_OwnerChanged));

                List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idOldOwner,
                        'Результат запроса на перевод',
                        '<p>Ваш запрос на перевод записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утвержден</p>' +
                        '<p>Инн : ' + currentOpportunities[0].INN_Opp__c + '</p>' +
                        '<p>Наименование Компании : ' + currentOpportunities[0].account.Name + '</p>'));
                emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                        'Результат перевода записи',
                        '<p>На вас переведена возможность <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a></p>' +
                        '<p>Инн : ' + currentOpportunities[0].INN_Opp__c + '</p>' +
                        '<p>Наименование Компании : ' + currentOpportunities[0].account.Name + '</p>'));
                Messaging.sendEmail(emailMessageList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0007_OwnerCanNotBeChanged));
            }
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged + ' ' + e.getMessage()));
        }
    }

    /*******************************************************************************
*  Name            : processingRequestForSecondOpportunity()
*  Summary         : type approve = 003. change owner from Team Lead to Manager (processing request for create second opportunity)
*  CreatedDate     : 13/11/2017
*  Parameters      : (Id idRecord, Id idNewOwner, String answer)
*  Returns         : void
******************************************************************************/
    public void processingRequestForSecondOpportunity(Id idRecord, Id idNewOwner, String answer) {
        try {
            //VS SF-265
            List<Opportunity> currentOpportunities = [
                    SELECT id, ownerid, owner.managerid, account.Name, INN_Opp__c
                    FROM Opportunity
                    WHERE id = :idRecord
                    AND ownerid = :UserInfo.getUserId()
            ];
            if (currentOpportunities.size() == 1) {
                List<User> newOwnerOfRecord = [
                        SELECT name, ManagerId
                        FROM User
                        WHERE id = :idNewOwner
                        AND ManagerId = :UserInfo.getUserId()
                ];
                if (newOwnerOfRecord.size() == 1) {
                    if (answer == 'yes') {
                        isCommentForConfirmTextArea = true;
                    } else if (answer == 'no') {
                        isCommentForRejectTextArea = true;
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0013_NoAccess));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! Запрос по записи ' + idRecord + ' уже был обработан либо у вас недостаточно прав!'));
            }
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
        }
    }

    public void confirmForSecondOpportunity(Id idRecord, Id idNewOwner, String answer) {
        try {
            List<Opportunity> currentOpportunities = [
                    SELECT id, ownerid, owner.managerid, account.Name, INN_Opp__c
                    FROM Opportunity
                    WHERE id = :idRecord
                    AND ownerid = :UserInfo.getUserId()
            ];

            for (Opportunity opportunity : currentOpportunities) {
                opportunity.ownerid = idNewOwner;
            }
            update currentOpportunities;

            isGoToRecord = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Запись утверждена'));
            EmailGenerator.sendHtmlEmail(idNewOwner,
                    'Результат запроса на создание возможности',
                    '<p>Создание возможности <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утверждено </p>' +
                    '<p>Инн : ' + currentOpportunities[0].INN_Opp__c + '</p>' +
                    '<p>Наименование Компании : ' + currentOpportunities[0].account.Name + '</p>'
            );
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
        }
    }


    /*******************************************************************************
    *  Name            : getReasonRejectMessage()
    *  Summary         : return reject message
    *  CreatedDate     : 31/1/2018
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private String getReasonRejectMessage() {
        String messageReason = 'не указано';
        String messageComment = 'не указано';
        if(!String.isEmpty(reasonReject)) {
            messageReason = reasonReject;
        }

        if(!String.isEmpty(commentReject)) {
            messageComment = commentReject;
        }

        return '<p>Причина : ' + messageReason + '</p>' + '<p>Комментарий : ' + messageComment + '</p>';
    }

    private String getReasonConfirmMessage() {
        if (String.isEmpty(reasonConfirm) && String.isEmpty(commentConfirm)) return null;

        String messageReason = 'не указано';
        String messageComment = 'не указано';
        if(!String.isEmpty(reasonConfirm)) {
            messageReason = reasonConfirm;
        }

        if(!String.isEmpty(commentConfirm)) {
            messageComment = commentConfirm;
        }

        return '<p>Причина : ' + messageReason + '</p>' + '<p>Комментарий : ' + messageComment + '</p>';
    }

    /*******************************************************************************
    *  Name            : changeOwnerOfAccount()
    *  Summary         : type approve = 004. change owner of Account and Account.Opportunities
    *  CreatedDate     : 21/12/2017
    *  Parameters      : (Id idRecord, Id idNewOwner, String answer)
    *  Returns         : void
    ******************************************************************************/
    public void changeOwnerAccountByTeamLead(Id idRecord, Id idNewOwner, String answer) {
        try {
            //VS SF-265
            List<Account> currentAccount = [
                    SELECT id, ownerid, Owner.ManagerId, Name, INN__c
                    FROM Account
                    WHERE id = :idRecord
                    AND Owner.ManagerId = :UserInfo.getUserId()
                    AND Moved_to_Start__c = 0
            ];
            if (currentAccount.size() == 1) {
                if (answer == 'yes') {
                    isCommentForConfirmTextArea = true;
                } else if (answer == 'no') {
                    isCommentForRejectTextArea = true;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0007_OwnerCanNotBeChanged));
            }
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged + ' ' + e.getMessage()));
        }
    }

    public void confirmAccountByTeamLead(Id idRecord, Id idNewOwner, String answer) {
        try {
            List<Account> currentAccount = [
                    SELECT id, ownerid, Owner.ManagerId, Name, INN__c
                    FROM Account
                    WHERE id = :idRecord
                    AND Owner.ManagerId = :UserInfo.getUserId()
                    AND Moved_to_Start__c = 0
            ];

            String idOldOwner = currentAccount.get(0).ownerid;
            List<Opportunity> opportunitiesForUpdate = [
                    SELECT id, owner.id
                    FROM Opportunity
                    WHERE AccountId = :idRecord AND
                    OwnerId = :currentAccount.get(0).OwnerId
            ];
            for (Opportunity opportunityForUpdate : opportunitiesForUpdate) {
                opportunityForUpdate.OwnerId = idNewOwner;
            }
            update opportunitiesForUpdate;

            for (Account account : currentAccount) {
                account.OwnerId = idNewOwner;
            }
            update currentAccount;

            isGoToRecord = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0010_OwnerChanged));

            List<Messaging.Email> emails = new List<Messaging.Email>();
            emails.add(EmailGenerator.prepareHtmlEmailToTarget(idOldOwner,
                    'Результат запроса на перевод организации',
                    '<p>Ваш запрос на перевод записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утвержден</p>' + 
                    '<p>Инн : ' + currentAccount[0].INN__c + '</p>' +
                    '<p>Наименование Компании : ' + currentAccount[0].Name + '</p>'));
            emails.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                    'Результат запроса на перевод организации',
                    '<p>На вас переведена организация <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a></p>' +
                    '<p>Инн : ' + currentAccount[0].INN__c + '</p>' +
                    '<p>Наименование Компании : ' + currentAccount[0].Name + '</p>'));
            Messaging.sendEmail(emails);
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged + ' ' + e.getMessage()));
        }
    }
}