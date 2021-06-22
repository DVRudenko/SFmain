public class CreateCommercialProposalUtils {
	public static String TOKEN = 'PFJGLdHEgGrswTyjtMxlzCCfdtjbxyEI';
	public static String ENDPOINT = 'http://eurolocator.fleetcor.de/locator/api/v1/commercial-proposal/point';


    /*******************************************************************************
    *  Name            : doSelectUser()
    *  Summary         : select current account manager( user )    
    *  CreatedDate     : 04/01/2017
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public static User doSelectUser() {
        String dynQuery = 
            'SELECT Id, Username, LastName, FirstName, Name, CompanyName, Division, Department, Title, Street, City, State, PostalCode, ' + 
                'Country, Latitude, Longitude, GeocodeAccuracy, Email, EmailPreferencesAutoBcc, EmailPreferencesAutoBccStayInTouch, ' + 
                'EmailPreferencesStayInTouchReminder, SenderEmail, SenderName, Signature, StayInTouchSubject, StayInTouchSignature, ' + 
                'StayInTouchNote, Phone, Fax, MobilePhone, Alias, CommunityNickname, BadgeText, IsActive, TimeZoneSidKey, UserRoleId, ' + 
                'LocaleSidKey, ReceivesInfoEmails, ReceivesAdminInfoEmails, EmailEncodingKey, ProfileId, UserType, LanguageLocaleKey, ' + 
                'EmployeeNumber, DelegatedApproverId, ManagerId, LastLoginDate, LastPasswordChangeDate, CreatedDate, CreatedById, ' + 
                'LastModifiedDate, LastModifiedById, SystemModstamp, OfflineTrialExpirationDate, OfflinePdaTrialExpirationDate, ' + 
                'UserPermissionsMarketingUser, UserPermissionsOfflineUser, UserPermissionsAvantgoUser, UserPermissionsCallCenterAutoLogin, ' + 
                'UserPermissionsMobileUser, UserPermissionsSFContentUser, UserPermissionsKnowledgeUser, UserPermissionsInteractionUser, ' + 
                'UserPermissionsSupportUser, UserPermissionsJigsawProspectingUser, UserPermissionsChatterAnswersUser, ' + 
                'UserPermissionsWorkDotComUserFeature, ForecastEnabled, UserPreferencesActivityRemindersPopup, ' + 
                'UserPreferencesEventRemindersCheckboxDefault, UserPreferencesTaskRemindersCheckboxDefault, UserPreferencesReminderSoundOff, ' + 
                'UserPreferencesDisableAllFeedsEmail, UserPreferencesDisableFollowersEmail, UserPreferencesDisableProfilePostEmail, ' + 
                'UserPreferencesDisableChangeCommentEmail, UserPreferencesDisableLaterCommentEmail, UserPreferencesDisProfPostCommentEmail, ' + 
                'UserPreferencesApexPagesDeveloperMode, UserPreferencesHideCSNGetChatterMobileTask, UserPreferencesDisableMentionsPostEmail, ' + 
                'UserPreferencesDisMentionsCommentEmail, UserPreferencesHideCSNDesktopTask, UserPreferencesHideChatterOnboardingSplash, ' + 
                'UserPreferencesHideSecondChatterOnboardingSplash, UserPreferencesDisCommentAfterLikeEmail, UserPreferencesDisableLikeEmail, ' + 
                'UserPreferencesSortFeedByComment, UserPreferencesDisableMessageEmail, UserPreferencesJigsawListUser, ' + 
                'UserPreferencesDisableBookmarkEmail, UserPreferencesDisableSharePostEmail, UserPreferencesEnableAutoSubForFeeds, ' + 
                'UserPreferencesDisableFileShareNotificationsForApi, UserPreferencesShowTitleToExternalUsers, UserPreferencesShowManagerToExternalUsers, ' + 
                'UserPreferencesShowEmailToExternalUsers, UserPreferencesShowWorkPhoneToExternalUsers, UserPreferencesShowMobilePhoneToExternalUsers, ' + 
                'UserPreferencesShowFaxToExternalUsers, UserPreferencesShowStreetAddressToExternalUsers, UserPreferencesShowCityToExternalUsers, ' + 
                'UserPreferencesShowStateToExternalUsers, UserPreferencesShowPostalCodeToExternalUsers, UserPreferencesShowCountryToExternalUsers, ' + 
                'UserPreferencesShowProfilePicToGuestUsers, UserPreferencesShowTitleToGuestUsers, UserPreferencesShowCityToGuestUsers, UserPreferencesShowStateToGuestUsers, ' + 
                'UserPreferencesShowPostalCodeToGuestUsers, UserPreferencesShowCountryToGuestUsers, UserPreferencesDisableFeedbackEmail, UserPreferencesDisableWorkEmail, ' + 
                'UserPreferencesHideS1BrowserUI, UserPreferencesDisableEndorsementEmail, UserPreferencesPathAssistantCollapsed, UserPreferencesCacheDiagnostics, ' + 
                'UserPreferencesShowEmailToGuestUsers, UserPreferencesShowManagerToGuestUsers, UserPreferencesShowWorkPhoneToGuestUsers, UserPreferencesShowMobilePhoneToGuestUsers, ' + 
                'UserPreferencesShowFaxToGuestUsers, UserPreferencesShowStreetAddressToGuestUsers, UserPreferencesLightningExperiencePreferred, ContactId, AccountId, CallCenterId, ' + 
                'Extension, FederationIdentifier, AboutMe, FullPhotoUrl, SmallPhotoUrl, DigestFrequency, DefaultGroupNotificationFrequency, JigsawImportLimitOverride, ' + 
                'LastViewedDate, LastReferencedDate, role__c, Grade__c, Hire_Date__c, UserRole.Name ' + 
            'FROM User ' + 
            'WHERE Id = \'' + UserInfo.getUserId() + '\'';

        User user = Database.query(dynQuery); 
        return user;
    }


    /*******************************************************************************
    *  Name            : doSelectOpportunity()
    *  Summary         : select opportunity for commercial proposal   
    *  CreatedDate     : 04/01/2017
    *  Parameters      : String opportunityId
    *  Returns         : opportunity
    ******************************************************************************/
    public static  Opportunity doSelectOpportunity (String opportunityId) {
        String dynQuery =
            'SELECT IsDeleted, AccountId, RecordTypeId, Name, Description, StageName, Amount, Probability, CloseDate, Type, NextStep, LeadSource, IsClosed, ' + 
                'IsWon, ForecastCategory, ForecastCategoryName, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, Territory2Id, IsExcludedFromTerritory2Filter, ' + 
                'CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, ' + 
                'LastViewedDate, LastReferencedDate, SyncedQuoteId, HasOpenActivity, HasOverdueTask, Credit_Limit__c, Zahlungsziel__c, Risk_Category__c, ' + 
                'Anzahl_der_Karten__c, Kraftstoffverbrauch_Liter_Monat__c, Bevollmaechtigung__c, AGB_Datenschutzhinweise_Richtigkeit__c, ' + 
                'Kreditklasse__c, max_Kreditlimit__c, Exposure__c, bearbeitet_von__c, Zahlungsart__c, Vertrag_nur_mit_Sicherheiten__c, Creditreform_Nummer__c, ' + 
                'Creditreform_Rating__c, Angaben_korrekt__c, Garantie__c, Garantie_other__c, Credit_check_date__c, Year__c, Internet_Source__c, Zahl_der_Mitarbeiter__c, ' +
                'Financials__c, Kredit_Entscheidung__c, Notes__c, Sicherheit_angefodert__c, Creditreform_Recommended_Rating__c, Rechnungsperiode__c, Umsatz__c, ' + 
                'Auftragsvolumen__c, CREFONR__c, Bonitaetsindex__c, Herkunft_Land__c, Prior_year__c, Zahlungsziel_2__c, Buffer_2__c, Papierrechnung__c, ' +
                'Prepaid_Flag_Y_N__c, Kreditbetrag_Anfrage__c, Sec_Channel__c, Kundensegment__c, Kreditbetrag_Vertrag__c, Pimary_Channel__c, ' + 
                'Risk_Category_Begruendung__c, Credit_Limit_Anpassung__c, Vertr_ge_generiert__c, Vertrag_neu_generieren__c, gewuenschter_Kreditrahmen__c, ' +
                'Rechnungsperiode_2__c, Status_Pending_Sales__c, Kartenabieter__c, Estimated_Start_Volume__c, Endorsed_Degussa_Credit_Limit__c, Datansatztyp_auto__c, ' + 
                'Warum_Flexcard__c, Warum_Flexcard_Sonstiges__c, Zahlungsziel_Credit__c, Total_Assets_Credit__c, Wahrscheinlichkeit_der_Ausfalls__c, Gruendungsjahr__c, ' + 
                'Registernummer__c, WC_2008_Code__c, Score_percent__c, App_Data_Transfer_to_Degussa_Ready__c, App_Data_Transfer_to_Degussa_Complete__c, ' + 
                'Customer_ID_Data_Transfer_to_FC_Received__c, App_Data_Transfer_from_FleetCor_Received__c, App_Data_Transfer_from_FleetCor_In_Proce__c, ' + 
                'Customer_ID_Transfer_to_FleetCor_Ready__c, Customer_ID_Transfer_to_FC_Complete__c, Customer_ID_Updated_in_Opp_Record__c, ' + 
                'Welcome_Letter_has_been_issued__c, Bearbeiter_Degussa__c, Degussa_Notes__c, Opportunity_Nr__c, Shell_ID__c, GFN__c, Bargeldaufhebung_aktiviert__c, ' + 
                'Sicherheit_beantragt_Security_requested__c, Total_Assets_Credit_Prior__c, Greundungsjahr__c, Working_capital_Credit__c, Long_term_assets__c, ' + 
                'Intangible_assets__c, Tangible_assets__c, Short_term_assets__c, Stock__c, Trade_Receivables__c, Cash__c, Turnover__c, Cost_of_goods_sold_COGS__c, ' + 
                'EBITDA__c, Depreciation__c, Equity__c, Long_term_debt__c, Long_term_bank_leasing_debt__c, Short_term_debt__c, Trade_Creditors__c, ' + 
                'Short_term_bank_leasing_debt__c, Interest_paid__c, EBIT__c, Working_capital_Prior__c, Liquidity__c, Working_capital__c, A_P_days__c, ROE__c, ROA__c, ' + 
                'Tangible_Net_Worth__c, Debt_to_EBITDA__c, Derzeitige_Zahlungsmethode__c, Tankkarte_Emittent__c, Zahlungssystem__c, Bank__c, Andere_Details__c, ' + 
                'Max_Credit_Limit__c, Leverage__c, Notes_c2__c, Total_Assets_2__c, Net_profit__c, Total_Liabilities__c, EAT_2__c, Checktotal_assets__c, Gearing__c, ' + 
                'Debt_to_EBITDA_calcul__c, AVG_ratios__c, Credit_Limit_Calcul__c, Liquidity_Calcul__c, Comments1__c, Comments2__c, Land_Opp__c, Channel__c, ' + 
                'Gruende_verloren__c, OpportunityStageName__c, Total_Liabilities_Prior__c, Bi_weekly_10__c, Kartentyp__c, Nr_Account__c, ' + 
                'Rechnungsperiode_3__c, Zahlungsziel_Credit_calculati__c, Security_level_H_he_der_Sicherheit__c, Security_level_Calcul__c, Monthly_7__c, Bi_weekly_7__c, ' + 
                'Weekly_7__c, Angebotsdauer__c, Retained_Earnings__c, Last_Owner_Change_Date__c, Retained_Earnings_Prior__c, ' + 
                'Bi_weekly_14__c, Sales__c, Produkt__c, Product__c, Regions__c, GFN_Nr__c, Wie_viele_Clubsmart_Karten__c, Sales_Prior__c, EBIT_Credit__c, EBIT_Prior__c, ' + 
                'Blank_to_make_it_better_for_orientation__c, Blank_to_make_it_better_for_Prior__c, Networth_Credit__c, Networth_Prior__c, ' + 
                'Z_score_non_manufacturers_current_year__c, Z_score_private_companies_current_year__c, Z_score_for_non_manufacturers_prior_year__c, ' + 
                'Z_score_for_private_companies_prior_year__c, Z_score_non_manufacturers__c, Z_score_private_companies__c, Opportunity__c, Number_of_GPS_units__c, ' + 
                'CCS_Promo_offer__c, CCS_Primary_fueling_method__c, First_Activity_Date__c, Trv_n_obchodn_p_le_itosti__c, Po_et_aktivit__c, Next_Step_Date__c, ' + 
                'Credit_Status__c, Decision_Reasons__c, Decision_Reason_Other__c, Lost_To_Competitor__c, Utm_source__c, Utm_medium__c, Utm_campaign__c, Utm_content__c, ' + 
                'Utm_term__c, CCS_Cooperation__c, CCS_Jm_na__c, CCS_GFN_number__c, Source_if_self_sourced_c__c, Date_of_First_Contact__c, ' + 
                'First_Contact_Inbound_Outbound__c, Popis_Leadu__c, CCS_Fleet_Type__c, CCS_Primary_Fueling_Method_specific__c, ' + 
                'Owner.Name, Account.BillingCountry, Account.BillingCity, Account.BillingStreet ' + 
            'FROM Opportunity ' + 
            'WHERE Id = :opportunityId';

        Opportunity opportunity = Database.query(dynQuery);
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : doSelectContactsInMap
    *  Summary         : select contacts for account     
    *  CreatedDate     : 04/01/2017
    *  Parameters      : String accountId
    *  Returns         : contactsMap
    ******************************************************************************/
    public static Map<Id, Contact> doSelectContactsInMap (String accountId) {
        String dynQuery = 
            'SELECT Id, IsDeleted, MasterRecordId, AccountId, LastName, FirstName, Salutation, Name, RecordTypeId, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, ' + 
                'OtherLatitude, OtherLongitude, OtherGeocodeAccuracy, OtherAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, ' + 
                'MailingLongitude, MailingGeocodeAccuracy, MailingAddress, Phone, Fax, MobilePhone, HomePhone, OtherPhone, AssistantPhone, ReportsToId, Email, Title, Department, ' + 
                'AssistantName, LeadSource, Birthdate, Description, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, ' + 
                'LastCURequestDate, LastCUUpdateDate, LastViewedDate, LastReferencedDate, EmailBouncedReason, EmailBouncedDate, IsEmailBounced, PhotoUrl, JigsawContactId, OPT_IN__c, ' + 
                'Primaerer_ASP__c, Briefanrede__c, Sub_CustomerID__c, ContactMaster_AddressID__c, Geburtsort__c, ' + 
                'Nationalitaet__c, Ausweisart__c, Ausweisnummer__c, Ausweis_Ausstellungsdatum__c, Ausweis_Ausstellende_Beh_rde__c, Kartenlimit__c, Bargeldabhebung_Ja_Nein__c, ' + 
                'Sprachpraeferenz__c, AGB_Best_tigung_Ja_Nein_ist_immer_Ja__c, Auth_Person__c, Karteninhaber__c, Passwort__c, Versicherungspaket__c, Nutzungsart__c, Legitimation__c, ' + 
                'Portal_Admin__c, Position_Funktion__c, Ausweis_gueltig_bis__c, Familienstand__c, Click_to_call__c, Call_via_3CX_HomePhone__c, Interested_customer__c, ' + 
                'Call_via_3CX_OtherPhone__c, Call_via_3CX_AssistantPhone__c, Call_via_3CX_Fax__c, Call_via_3CX_MobilePhone__c, Call_via_3CX_Phone__c, CCS_Assistant_e_mail__c, ' + 
                'CCS_Contact_Hobby_Culture__c, CCS_Contact_Hobby_Sports__c, CCS_GFN_Contact_type__c, CCS_GFN_number__c, CCS_Level__c, CCS_Other_e_mail__c, CCS_Phone_national_prefix__c ' + 
                'FROM Contact ' + 
            'WHERE AccountId = :accountId ' + 
            'LIMIT 1000';

        Map<Id, Contact> contactsMap = new Map<Id, Contact>(
          (List<Contact>)Database.query(dynQuery)
          );             
        return contactsMap;                
    }


    /*******************************************************************************
    *  Name            : doSelectComProTemplates
    *  Summary         : select email text and pdf text (text templates for products)     
    *  CreatedDate     : 05/01/2017
    *  Parameters      : String oppProductName
    *  Returns         : List<Commercial_Proposal_Template__c> templateList
    ******************************************************************************/
    public static Commercial_Proposal_Template__c doSelectComProTemplates (String oppProductName, String countryAcc) {
        String dynQuery = 
            'SELECT Email_Body__c, PDF_body__c, Email_Subject__c ' + 
            'FROM Commercial_Proposal_Template__c ' + 
            'WHERE Name = :oppProductName AND ' + 
                      'Country__c = :countryAcc';
          
        List<Commercial_Proposal_Template__c> templateList = (
            Database.query(dynQuery));

        if ( ! templateList.isEmpty() ) {
            return templateList.get(0);
        }
        return null;     
    }


    /*******************************************************************************
    *  Name            : doSelectAttachments (Commercial_Proposal_Template__c template)
    *  Summary         : select all attachments for this template    
    *  CreatedDate     : 11/08/2017
    *  Parameters      : Commercial_Proposal_Template__c template
    *  Returns         : Map<String, Attachment> - allAttachments for this template
    ******************************************************************************/
    public static Map<String, Attachment> doSelectAttachments (Commercial_Proposal_Template__c template) {
        String templateId = template.Id;
        String dynQuery =
            'SELECT Body, Name, OwnerId, ParentId ' +
            'FROM Attachment ' +
            'WHERE ParentId = :templateId ' +
            'LIMIT 100';

        List<Attachment> attachList = (
            Database.query(dynQuery));

        if ( ! attachList.isEmpty() ) {
            Map<String, Attachment> attachMap = new Map<String, Attachment>();
            for (Attachment att : attachList) {
                attachMap.put(att.Name, att);
            }
            return attachMap;
        }
        return null;
    }

	
	/*******************************************************************************
	*  Name            : generateRequest( String country, String city, String street, 
										 List<String> selectedBrands, String selectedRadius,
										 String selectedProduct )
	*  Summary         : Generates request to map API      
	*  CreatedDate     : 03/01/2017
	*  Parameters      : 
	*  Returns         : HttpRequest
	******************************************************************************/
	public static HttpRequest generateRequest( String country, String city, String street, 
											  List<String> selectedBrands, String selectedRadius,
											  String selectedProduct ) {
        String address = country + ', ' + city + ', ' + street;
        String brandsForRequest = '';
        if ( ! selectedBrands.isEmpty()) {
            brandsForRequest = ',"brand": "';
            for (String brandstring : selectedBrands) {
                brandsForRequest = brandsForRequest + brandstring + ';';
            }
            brandsForRequest = brandsForRequest + '"';
        }
        String body = '{"token": "' + TOKEN + '",'+
            '"size": "1000x1000","radius": ' + selectedRadius + ',' +
            '"product": ' + selectedProduct + ',' +
            '"address": "' + street + ' ' + city + ' ' + country + '"' + 
            brandsForRequest +
            '}';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);
        req.setTimeout(10000);
        req.setEndpoint(ENDPOINT);
        req.setMethod('POST');
        
        return req;
	}


    /*******************************************************************************
    *  Name            : preporationEmailsForSending (String pdfBody, Commercial_Proposal_Template__c template,
                                                    Opportunity opportunity, Map<Id, Contact> contactsMap,
                                                    String selectedContact, User user
    *  Summary         : generate emails for sending    
    *  CreatedDate     : 03/01/2017
    *  Parameters      : -
    *  Returns         : emails
    ******************************************************************************/
	public static List<Messaging.SingleEmailMessage> preporationEmailsForSending (Commercial_Proposal_Template__c template,
                                                                                Opportunity opportunity, Map<Id, Contact> contactsMap,
                                                                                String selectedContact, Map<String, Attachment> attachmentsMap,
                                                                                List<String> selectedAttachments, String emailBody) {

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        List<Messaging.EmailFileAttachment> mailattachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        PageReference pdf = new PageReference('/apex/commercialproposalpdf');
        Blob b;
        if ( ! Test.isRunningTest()) {
          b = pdf.getContent();
        } else {
          b = Blob.valueOf('123');
        }
        efa.setFileName('CommercialProposal.pdf');
        efa.setBody(b);
        mailattachments.add(efa);

        if (! selectedAttachments.isEmpty()) {
            for (String attachmentName : selectedAttachments) {
                Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
                fileAttachment.setFileName(attachmentsMap.get(attachmentName).Name);
                fileAttachment.setBody(attachmentsMap.get(attachmentName).Body);
                mailattachments.add(fileAttachment);
            }
        } 
        //generate email items
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(contactsMap.get(selectedContact).Id);
        mail.setSubject(template.Email_Subject__c);
        mail.setHtmlBody(emailBody);
        mail.setFileAttachments(mailattachments);
        mail.setCharset('UTF-8');
        emails.add(mail);

        return emails;
    }


    /*******************************************************************************
    *  Name            : mergeText(String source, Opportunity opp, Contact contact, User user)
    *  Summary         : Merge fields based on formulas for Opportunity, Contact and User    
    *  CreatedDate     : 04/01/2017
    *  Parameters      : String source, Opportunity opp, Contact contact, User user
    *  Returns         : string finalBody
    ******************************************************************************/
    public static String mergeText(String source, Opportunity opp, Contact contact, User user) {
        String finalBody = '';      
        if (source != null && opp != null && contact != null && user != null) {
            finalBody = doMergeString(source, 'Opportunity', opp);
            finalBody = doMergeString(finalBody, 'Contact', contact);
            finalBody = doMergeString(finalBody, 'User', user);
        }
        return finalBody;
    }


	public static String doMergeString(String source, String objectType, Sobject obj) {
        Pattern mergeField = Pattern.compile('\\{!' + objectType + '\\.[a-zA-Z0-9_\\.]*\\}');
        Matcher m = mergeField.matcher(source);
        Integer curPos = 0;
        String s = '';
        while (m.find()) {
            s += source.substring(curPos, m.start());
            String fieldName = source.substring(m.start()+2 + objectType.length() + 1,m.end()-1);
            String[] relations = fieldName.split('\\.');
            try {
                SObject tmp = obj;
                for(Integer i=0; i<relations.size()-1; i++){
                    tmp = tmp.getSObject(relations[i]);
                }
                s += tmp.get(relations[relations.size()-1]);
            } catch(Exception ex){
                s += '[Invalid merge field: ' + m.group() + ']';
            }
            curPos = m.end();
        }
        s += source.substring(curPos);

        return s;
    }


    /*******************************************************************************
    *  Name            : validateClosedOpp()
    *  Summary         : Check if Opportunity NOT in Closed Won or Closed Lost Status
    *  CreatedDate     : 04/01/2017
    *  Parameters      : Opportunity
    *  Returns         : -
    ******************************************************************************/
    public static void validateClosedOpp(Opportunity opportunity) {
        if (opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Closed Lost') {
            throw new CommercialProposalException('This Opportunity is already closed.');
        }
    }


    /*******************************************************************************
    *  Name            : validateCountries()
    *  Summary         : Check if Opportunity.Account.BillingCountry equals Germany, Netherlands, France, Belgium-FR and Belgium-NL only     
    *  CreatedDate     : 05/01/2017
    *  Parameters      : Opportunity
    *  Returns         : -
    ******************************************************************************/
    public static void validateCountries(Opportunity opportunity) {
        if (! countriesMap.containsKey(opportunity.Account.BillingCountry)) {
            throw new CommercialProposalException('Commercial Proposal Generator is available for the following countries only: Germany, Netherlands, France, Belgium-FR, Belgium-NL, Poland, Hungary, Czech Republic, Slovakia, Luxembourg, Switzerland-DE, Switzerland-FR, Switzerland-IT');
        }
    }


    /*******************************************************************************
    *  Name            : validateContactsMap()
    *  Summary         : Check if Contacts Map was NOT empty    
    *  CreatedDate     : 05/01/2017
    *  Parameters      : Map<Id, Contact> contactsMap
    *  Returns         : -
    ******************************************************************************/
    public static void validateContactsMap(Map<Id, Contact> contactsMap) {
        if (contactsMap.isEmpty()) {
            throw new CommercialProposalException('Please add at least one Contact in Account.');
        }
    }


    /*******************************************************************************
    *  Name            : validateTemplate()
    *  Summary         : Check if Commercial Proposal Template exists
    *  CreatedDate     : 05/01/2017
    *  Parameters      : Commercial_Proposal_Template__c
    *  Returns         : void
    ******************************************************************************/
    public static void validateTemplate(Commercial_Proposal_Template__c template) {
        if (template == null) {
            throw new CommercialProposalException('Please select product in Opportunity.');
        }
    }


    private static Map<String, String> countriesMap = new Map<String, String>{
        'Germany' => 'Germany', 
        'Netherlands' => 'Netherlands', 
        'France' => 'France',
        'Belgium-FR' => 'Belgium-FR',
        'Belgium-NL' => 'Belgium-NL',
        'Poland' => 'Poland',
        'Hungary' => 'Hungary',
        'Czech Republic' => 'Czech Republic',
        'Slovakia' => 'Slovakia',
        'Luxembourg' => 'Luxembourg',
        'Switzerland-DE' => 'Switzerland-DE',
        'Switzerland-FR' => 'Switzerland-FR',
        'Switzerland-IT' => 'Switzerland-IT'};
}