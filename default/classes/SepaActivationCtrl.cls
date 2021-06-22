public class SepaActivationCtrl {
    public Map<String, Object> statusContentsMap {get; set;}
    public Map<String, Object> generalContentsMap {get; set;}
    public Map<String, Object> contactContentsMap {get; set;}
    public String status {get; set;}


    /*******************************************************************************
    *  Summary         : Update Opportunities
    *  CreatedDate     : 10/11/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void init() {
        try {
            String mandateId = ApexPages.currentPage().getParameters().get('mandateNumber');
            this.status = ApexPages.currentPage().getParameters().get('status');
            List<Opportunity> opportunitiesList = [
                    SELECT StageName, Account.BillingCountryCode, OwnerId, Owner.Name, Name
                    FROM Opportunity
                    WHERE Send_SEPA_approval_link__c = true AND Account.UMR__c = :mandateId
            ];

            String countryCode;
            if (! opportunitiesList.isEmpty()) {
                countryCode = opportunitiesList.get(0).Account.BillingCountryCode;
                if (countryCode != 'BEFR' && countryCode != 'BENL') {
                    countryCode = 'BENL';
                }

                this.statusContentsMap = (Map<String, Object>) getStatusContent().get(countryCode);
                this.generalContentsMap = (Map<String, Object>) getGeneralContents().get(countryCode);
                this.contactContentsMap = (Map<String, Object>) getContactContent().get(countryCode);

                List<Messaging.SingleEmailMessage> messages =  new List<Messaging.SingleEmailMessage>();
                List<Opportunity> opportunitiesListToUpdate = new List<Opportunity>();
                for (Opportunity opportunity : opportunitiesList) {
                    if (this.status == 'ok') {
                        opportunity.Send_SEPA_approval_link__c = true;
                        opportunity.SEPA_Request_Approved__c = true;
                        opportunity.Einwilligung_Lastschriftverfahren__c = true;
                        opportunity.SEPA_Request_Approval_Date__c = Datetime.now();
                        opportunity.AGB_Datenschutzhinweise_Richtigkeit__c = true;
                        if (opportunity.StageName == 'Closed Won') {
                            opportunity.Starts_Payment_method__c = 'Direct debit';
                        } else {
                            opportunity.Zahlungsart__c = 'Lastschrift';
                        }

                        opportunitiesListToUpdate.add(opportunity);
                    }

                    messages.add(prepareSepaResultEmail(opportunity));
                }

                Messaging.sendEmail(messages);
                if (! opportunitiesListToUpdate.isEmpty()) {
                    update opportunitiesListToUpdate;
                }
            }
        }
        catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
    *  Summary         : Get content based on status
    *  CreatedDate     : 10/11/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private Map<String, Object> getStatusContent() {
        Map<String, Object> statusContentsMap = new Map<String, Object>();
        statusContentsMap.put('BENL', new Map<String, Object> {
            'ok' => 'Bedankt voor het ondertekenen van het B2B-mandaat! U wordt binnenkort geïnformeerd met details over het B2B mandaatproces.',
            'cancel' => 'Het spijt ons dat u heeft besloten het B2B proces te annuleren. Wij zullen spoedig contact met u opnemen.',
            'fail' => 'Het lijkt erop dat het authenticatie B2B proces is mislukt. Wij zullen spoedig contact met u op nemen.',
            'pending' => 'Wij verzoeken u vriendelijk de stappen af te ronden om de B2B mandaat te activeren.'
        });
        statusContentsMap.put('BEFR', new Map<String, Object> {
            'ok' => 'Nous vous remercions d\'avoir signé votre mandant B2B! Nous allons vous contacter sous peu avec les informations plus détaillées concernant le processus d\'approbation.',
            'cancel' => 'Nous regrettons votre décision d\'interrompre le processus de signature. Nous allons essayer de vous recontacter pour discuter la finalisation du processus d\'approbation.',
            'fail' => 'Il paraît que le processus d\'approbation a échoué. Nous allons essayer de vous recontacter pour discuter la finalisation du processus d\'approbation.',
            'pending' => 'Maintenant le processus d\'activation est à vous. Merci de finir toutes les démarches et activer votre mandat B2B.'
        });

        return statusContentsMap;
    }


    /*******************************************************************************
    *  Summary         : Get general content
    *  CreatedDate     : 10/11/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private Map<String, Object> getGeneralContents() {
        Map<String, Object> generalContentsMap = new Map<String, Object>();
        generalContentsMap.put('BENL', new Map<String, Object> {
            'salutation' => 'Geachte klant,',
            'regards' => 'Met vriendelijke groet,',
            'signature' => 'Uw Fleetcor-team',
            'site' => 'https://fleetcorcards.be/nl/',
            'button' => 'Startpagina'
        });
        generalContentsMap.put('BEFR', new Map<String, Object> {
            'salutation' => 'Cher client,',
            'regards' => 'Cordialement,',
            'signature' => 'Votre équipe Fleetcor',
            'site' => 'https://fleetcorcards.be/fr/',
            'button' => 'Retour au site'
        });

        return generalContentsMap;
    }


    /*******************************************************************************
    *  Summary         : Get content based on contact info
    *  CreatedDate     : 12/11/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private Map<String, Object> getContactContent() {
        Map<String, Object> statusContentsMap = new Map<String, Object>();
        statusContentsMap.put('BENL', new Map<String, Object> {
            'phone' => '+32 (0)2 3648965',
            'email' => 'contact@fleetcorcards.be',
            'time' => '8:00 – 17:00 (van maandag tot vrijdag)'
        });

        return statusContentsMap;
    }


    /*******************************************************************************
    *  Summary         : Send email to the owner of the record
    *  CreatedDate     : 17/11/2020 by Ivan Kulinkovich
    *  Parameters      : Opportunity opportunity - current opportunity
    *  Returns         : Messaging.SingleEmailMessage message
    ******************************************************************************/
    private Messaging.SingleEmailMessage prepareSepaResultEmail(Opportunity opportunity) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.OwnerId);
        message.subject = 'SEPA activation result';
        message.setSenderDisplayName('Salesforce Notification');
        message.setHtmlBody('Dear ' + opportunity.Owner.Name + ',<br/><br/>' +
            'A customer has just finished the B2B onboarding process with Twikey with the following result: "' + this.status + '"' +
            '<br/>Opportunity: <a href="' + Url.getOrgDomainUrl().toExternalForm() + '/' + opportunity.Id + '">' + opportunity.Name + '</a><br/><br/>With regards<br/>SalesForce infoMail');
        message.saveAsActivity = false;

        return message;
    }
}