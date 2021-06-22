global class EmailGenerator {

    /*******************************************************************************
    *  Name            : sendHtmlEmail()
    *  Summary         : forming List<String> of email user. Call "sendHtmlEmail" method with List<String> parameter
    *  CreatedDate     : 01/11/2017
    *  Parameters      : (Id userId, String textOfSubject, String textHtmlOfEmail)
    *  Returns         : -
    ******************************************************************************/
    global static void sendHtmlEmail(Id userForEmail, String textOfSubject, String textHtmlOfEmail) {
        List<User> userForSendEmail = [SELECT email FROM User WHERE id = :userForEmail];
        if (userForSendEmail.isEmpty() == false) {
            List<Messaging.SingleEmailMessage> listToSend = new List<Messaging.SingleEmailMessage>();
            listToSend.add(prepareHtmlEmailToTarget(userForEmail, textOfSubject, textHtmlOfEmail));
            Messaging.sendEmail(listToSend);
        }
    }


    /*******************************************************************************
    *  Name            : sendHtmlEmail()
    *  Summary         : send mails to List<String> emails, using parameters
    *  CreatedDate     : 01/11/2017
    *  Parameters      : (List<String> emailUsers, String textOfSubject, String textHtmlOfEmail)
    *  Returns         : -
    ******************************************************************************/
    global static void sendHtmlEmail(List<ID> usersForEmail, String textOfSubject, String textHtmlOfEmail) {
        if (usersForEmail.size() <> 0) {
            List<Messaging.SingleEmailMessage> listToSend = new List<Messaging.SingleEmailMessage>();
            for (ID userForEmail : usersForEmail) {
                listToSend.add(prepareHtmlEmailToTarget(userForEmail, textOfSubject, textHtmlOfEmail));
            }
            Messaging.sendEmail(listToSend);
        }
    }

    /*******************************************************************************
    *  Name            : sendHtmlEmail()
    *  Summary         : send mails to List<String> emails, using parameters
    *  CreatedDate     : 01/11/2017
    *  Parameters      : (List<String> emailUsers, String textOfSubject, String textHtmlOfEmail)
    *  Returns         : -
    ******************************************************************************/
    global static Messaging.SingleEmailMessage prepareHtmlEmailToTarget(Id idUser, String textOfSubject, String textHtmlOfEmail) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(idUser);
        mail.setSenderDisplayName('Fleetcor Salesforce');
        mail.setSubject(textOfSubject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody('<messaging:emailTemplate> ' +
                '<html> <style type="text/css"> body {font-family: Courier; size: 12pt;} td { border-width: 1px;  padding: 4px;' +
                'border-style: solid; border-color: #000000; background-color: #FFEECC;}th { color: #000000; border-width: 1px ; padding: 4px ;' +
                'border-style: solid ;  border-color: #000000; background-color: #FFFFF0;}</style>' +
                '<body>' +
                textHtmlOfEmail +
                '</body> ' +
                '</html> </messaging:emailTemplate>');
        return mail;
    }


    /*******************************************************************************
   *  Name            : prepareHtmlEmailToTarget()
   *  Summary         : prepare email message
   *  CreatedDate     : 15/12/2017
   *  Parameters      : (String, String textOfSubject, String textHtmlOfEmail)
   *  Returns         : -
   ******************************************************************************/
    global static Messaging.SingleEmailMessage prepareHtmlEmailToTarget(String[] addresses, String textOfSubject, String textHtmlOfEmail) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setToAddresses(addresses);
        mail.setSenderDisplayName('Fleetcor Salesforce');
        mail.setSubject(textOfSubject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody('<messaging:emailTemplate> ' +
                '<html> <style type="text/css"> body {font-family: Courier; size: 12pt;} td { border-width: 1px;  padding: 4px;' +
                'border-style: solid; border-color: #000000; background-color: #FFEECC;}th { color: #000000; border-width: 1px ; padding: 4px ;' +
                'border-style: solid ;  border-color: #000000; background-color: #FFFFF0;}</style>' +
                '<body>' +
                textHtmlOfEmail +
                '</body> ' +
                '</html> </messaging:emailTemplate>');
        return mail;
    }


    /*******************************************************************************
    *  Name            : sendHtmlEmailWithAttachment()
    *  Summary         : send email with attachment
    *  CreatedDate     : 30/11/2017
    *  Parameters      : Id userId - user's id for mailing, String subject - an email subject,
    *                    String emailBody - an email text in body, Messaging.EmailFileAttachment attachment - attachment
    *  Returns         : Messaging.SendEmailResult[]
    ******************************************************************************/
    global static Messaging.SingleEmailMessage sendHtmlEmailWithAttachment(String[] addresses, OrgWideEmailAddress[] orgEmails,
            String subject, String emailBody, Messaging.EmailFileAttachment attach) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (orgEmails.size() > 0) {
            email.setOrgWideEmailAddressId(orgEmails.get(0).Id);
        }
        email.setSubject(subject);
        email.setToAddresses(addresses);
        email.setPlainTextBody(emailBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{
                attach
        });
        return email;
    }

    /*******************************************************************************
    *  Name            : sendHtmlEmailWithoutAttachment()
    *  Summary         : send email without attachment
    *  CreatedDate     : 30/11/2017
    *  Parameters      : Id userId - user's id for mailing, String subject - an email subject,
    *                    String emailBody - an email text in body, Messaging.EmailFileAttachment attachment - attachment
    *  Returns         : Messaging.SendEmailResult[]
    ******************************************************************************/
    global static Messaging.SingleEmailMessage sendHtmlEmailWithoutAttachment(String[] addresses, OrgWideEmailAddress[] orgEmails,
            String subject, String emailBody) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (orgEmails.size() > 0) {
            email.setOrgWideEmailAddressId(orgEmails.get(0).Id);
        }
        email.setSubject(subject);
        email.setToAddresses(addresses);
        email.setPlainTextBody(emailBody);
        return email;
    }

    /*******************************************************************************
    *  Name            : getHtmlEmailObject()
    *  Summary         : send email without attachment
    *  Created         : 30/05/2020 by Anton Hrytsavets
    *  Parameters      : Id userId - user's id for mailing, String subject - an email subject,
    *                    String emailBody - an email text in body, Messaging.EmailFileAttachment attachment - attachment
    *  Returns         : Messaging.SendEmailResult[]
    ******************************************************************************/
    global static Messaging.SingleEmailMessage getHtmlEmailObject(String[] addresses, OrgWideEmailAddress[] orgEmails,
            String subject, String emailBody) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (orgEmails.size() > 0) {
            email.setOrgWideEmailAddressId(orgEmails.get(0).Id);
        }
        email.setSubject(subject);
        email.setToAddresses(addresses);
        email.setHtmlBody(emailBody);
        return email;
    }

    /*******************************************************************************
    *  Name            : getEmailTemplatesMap()
    *  Summary         : retrieve raw EmailTemplate SObject via SOQL and merge it with input params for each id's Set
    *  CreatedDate     : 23/01/2019
    *  Parameters      : GlobalUtils.EmailTemplateDevName emailTemplateDevName - API name of EmailTemplate SObject as enum field,
    *                    Map<Set<Id>, Map<String, Object>> emailParamsIds - Map with Set of email receiver's ids and params to merge with raw template as map entry
    *  Returns         : Map<Set<Id>, EmailTemplate>
    ******************************************************************************/
    global static Map<Set<Id>, EmailTemplate> getEmailTemplatesMap(GlobalUtils.EmailTemplateDevName emailTemplateDevName, Map<Set<Id>, Map<String, Object>> emailParamsIds) {
        E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();

        EmailTemplate template = e2EFormRuDao.getEmailTemplateByDevName(emailTemplateDevName.name());
        if (template != null && template.HtmlValue != null && template.Subject != null) {
            Map<Set<Id>, EmailTemplate> templatesByIds = new Map<Set<Id>, EmailTemplate>();
            for (Set<Id> ids : emailParamsIds.keySet()) {
                templatesByIds.put(
                        ids,
                        prepareEmailTemplate(template.clone(), emailParamsIds.get(ids))
                );
            }
            return templatesByIds;
        } else {
            throw new E2EFormRuException('EmailTemplate doesn\'t exist or subject or htmlValue is empty!');
        }
    }

    /*******************************************************************************
    *  Name            : getEmailTemplate()
    *  Summary         : retrieve raw EmailTemplate SObject via SOQL and merge it with input params
    *  CreatedDate     : 23/01/2019
    *  Parameters      : GlobalUtils.EmailTemplateDevName emailTemplateDevName - API name of EmailTemplate SObject as enum field,
    *                    Map<String, Object> params - Map of parameters to merge with raw template
    *  Returns         : EmailTemplate
    ******************************************************************************/
    global static EmailTemplate getEmailTemplate(GlobalUtils.EmailTemplateDevName emailTemplateDevName, Map<String, Object> params) {
        E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();

        EmailTemplate template = e2EFormRuDao.getEmailTemplateByDevName(emailTemplateDevName.name());
        if (template != null && template.HtmlValue != null && template.Subject != null) {
            return prepareEmailTemplate(template, params);
        } else {
            throw new E2EFormRuException('EmailTemplate doesn\'t exist or subject or htmlValue is empty!');
        }
    }

    private static EmailTemplate prepareEmailTemplate(EmailTemplate template, Map<String, Object> params) {
        // prepare email body and subject
        String body = template.HtmlValue;
        String subject = template.Subject;
        System.debug('START TIME: ' + System.currentTimeMillis());
        Object paramValue = null;
        for (String paramName : params.keySet()) {
            paramValue = params.get(paramName);
            if (paramValue != null) {
                if (paramName == '/$opportunities$/') {
                    body = body.replace(paramName, getOpportunitiesEmailTemplateFirst((List<Opportunity>) paramValue));
                } else {
                    body = body.replace(paramName, String.valueOf(paramValue));
                    subject = subject.replace(paramName, String.valueOf(paramValue));
                }
            } else {
                throw new E2EFormRuException(paramName + ' = null');
            }
        }
        if (body.contains('/$') || body.contains('$/') || subject.contains('/$') || subject.contains('$/')) {
            throw new E2EFormRuException('Too few parameters in Map! Preparation of Email template have not been completed.');
        }
        System.debug('END TIME: ' + System.currentTimeMillis());
        template.HtmlValue = body;
        template.Subject = subject;
        return template;
    }

    private static String getOpportunitiesEmailTemplateFirst(List<Opportunity> opportunities) {
        String template = '<table><tr><th>Инн</th>' +
                '<th>Имя Opp-ty</th>' +
                '<th>Имя Ответст.</th>' +
                '<th>Роль Ответст.</th>' +
                '<th>Этап</th>' +
                '<th>Дата перевода</th>' +
                '<th>Дата закрытия</th></tr>';

        E2E_Form_Ru_General_Settings__c settings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        for (Opportunity opportunity : opportunities) {
            template += '<tr><td>' + opportunity.INN_Opp__c + '</td>';

            if (settings != null) {
                template += '<td><a href="' + settings.Domain_Url__c + '/' + opportunity.Id + '" target="_blank">' + opportunity.Name + '</a></td>';
            } else {
                template += '<td>' + +opportunity.Name + '</td>';
            }

            template += '<td>' + opportunity.Owner.Name + '</td>';

            if (opportunity.Owner.UserRole != null) {
                template += '<td>' + opportunity.Owner.UserRole.Name + '</td>';
            } else {
                template += '<td>None</td>';
            }

            template += '<td>' + GlobalUtils.getPicklistValueTranslation(Schema.SObjectType.Opportunity.fields.StageName, opportunity.StageName) + '</td>' +
                    '<td>' + opportunity.Day_transfer__c + '</td>' +
                    '<td>' + opportunity.CloseDate + '</td></tr>';
        }
        template += '</table>';
        return template;
    }

}