/**
 * Created by Anna Rudas on 28.11.2017.
 */

public class AccountGfnReportTemplate implements HtmlReportGenerator {

    private String accountId;
    private String opportunityId;
    private String opportunityRecordTypeId;

    public AccountGfnReportTemplate(String opportunityId, String opportunityRecordTypeId, String accountId) {
        this.accountId = accountId;
        this.opportunityId = opportunityId;
        this.opportunityRecordTypeId = opportunityRecordTypeId;
    }

    /*******************************************************************************
    *  Name            : generateReportHtmlTemplate()
    *  Summary         : generate HTML report template for sending by email
    *  CreatedDate     : 30/11/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String generateReportHtmlTemplate() {
        String htmlDocument = '';
        htmlDocument += getTableHeader();
        htmlDocument += '<div class="report">\n<table>\n';
        htmlDocument += getTableHeaderRow();
        htmlDocument += getTableBody();
        htmlDocument += '</table>\n</div>';
        return htmlDocument;
    }

    /*******************************************************************************
    *  Name            : getTableHeader()
    *  Summary         : generate a table header of HTML template <head>...</head>
    *  CreatedDate     : 30/11/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getTableHeader() {
        String tableHeader = '<head><META http-equiv="Content-Type" content="application/vnd.ms-excel; charset=UTF-8"></head>\n';
        return tableHeader;
    }

    /*******************************************************************************
    *  Name            : getStyle()
    *  Summary         : get CSS style for HTML template <style>...</style>
    *  CreatedDate     : 30/11/2017
    *  Parameters      : -
    *  Returns         : String
   ******************************************************************************/
    public String getStyle(){
        return '';
    }

    /*******************************************************************************
    *  Name            : getTableHeaderRow()
    *  Summary         : generate a header row of template
    *  CreatedDate     : 30/11/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getTableHeaderRow() {
        String headerRow = '<tr class="headerRow">\n';
        headerRow += '<th filter=all id="col-1">Account #</th>\n';
        headerRow += '<th filter=all id="col-2">Type</th>\n';
        headerRow += '<th filter=all id="col-3">Sec. Channel</th>\n';
        headerRow += '<th filter=all id="col-4">Lead Source</th>\n';
        headerRow += '<th filter=all id="col-5">Account Name</th>\n';
        headerRow += '<th filter=all id="col-6">Language Preference *</th>\n';
        headerRow += '<th filter=all id="col-7">Opportunity Owner</th>\n';
        headerRow += '<th filter=all id="col-8">Company form</th>\n';
        headerRow += '<th filter=all id="col-9">Tax ID</th>\n';
        headerRow += '<th filter=all id="col-10">Trade Register Number</th>\n';
        headerRow += '<th filter=all id="col-11">VAT number</th>\n';
        headerRow += '<th filter=all id="col-12">SWIFT BIC *</th>\n';
        headerRow += '<th filter=all id="col-13">IBAN *</th>\n';
        headerRow += '<th filter=all id="col-14">Credit System Number</th>\n';
        headerRow += '<th filter=all id="col-15">Product *</th>\n';
        headerRow += '<th filter=all id="col-16">Offer duration</th>\n';
        headerRow += '<th filter=all id="col-17">ESI</th>\n';
        headerRow += '<th filter=all id="col-18">Total number of vehicles</th>\n';
        headerRow += '<th filter=all id="col-19">Number of Cards*</th>\n';
        headerRow += '<th filter=all id="col-20">Total consumption (l/month) *</th>\n';
        headerRow += '<th filter=all id="col-21">Payment method *</th>\n';
        headerRow += '<th filter=all id="col-22">Direct Debit Mandate Type</th>\n';
        headerRow += '<th filter=all id="col-23">UMR</th>\n';
        headerRow += '<th filter=all id="col-24">Credit Limit</th>\n';
        headerRow += '<th filter=all id="col-25">Credit Limit Currency</th>\n';
        headerRow += '<th filter=all id="col-26">Payment terms Credit</th>\n';
        headerRow += '<th filter=all id="col-27">Risk Category</th>\n';
        headerRow += '<th filter=all id="col-28">Billing Period</th>\n';
        headerRow += '<th filter=all id="col-29">e-Invoicing PDF</th>\n';
        headerRow += '<th filter=all id="col-30">Paper Invoice</th>\n';
        headerRow += '<th filter=all id="col-31">Processed by</th>\n';
        headerRow += '<th filter=all id="col-32">Credit System Rating</th>\n';
        headerRow += '<th filter=all id="col-33">Next Review Date</th>\n';
        headerRow += '<th filter=all id="col-34">Security</th>\n';
        headerRow += '<th filter=all id="col-35">Security amount</th>\n';
        headerRow += '<th filter=all id="col-36">Registered Country</th>\n';
        headerRow += '<th filter=all id="col-37">Registered State/Province</th>\n';
        headerRow += '<th filter=all id="col-38">Registered City</th>\n';
        headerRow += '<th filter=all id="col-39">Registered Zip/Postal Code</th>\n';
        headerRow += '<th filter=all id="col-40">Registered Street</th>\n';
        headerRow += '<th filter=all id="col-41">Shipping Country</th>\n';
        headerRow += '<th filter=all id="col-42">Shipping State/Province</th>\n';
        headerRow += '<th filter=all id="col-43">Shipping City</th>\n';
        headerRow += '<th filter=all id="col-44">Shipping Zip/Postal Code</th>\n';
        headerRow += '<th filter=all id="col-45">Shipping Street</th>\n';

        headerRow += '<th filter=all id="col-46">Primary contact: Salutation</th>\n';
        headerRow += '<th filter=all id="col-47">Primary contact: First name</th>\n';
        headerRow += '<th filter=all id="col-48">Primary Contact: Middle name</th>\n';
        headerRow += '<th filter=all id="col-49">Primary Contact: Last name</th>\n';
        headerRow += '<th filter=all id="col-50">Primary Contact: Role</th>\n';
        headerRow += '<th filter=all id="col-51">Primary Contact: Email</th>\n';
        headerRow += '<th filter=all id="col-52">Primary contact: Phone</th>\n';
        headerRow += '<th filter=all id="col-53">Primary contact: Mobile</th>\n';
        headerRow += '<th filter=all id="col-54">Primary contact: Fax</th>\n';
        headerRow += '<th filter=all id="col-55">Additional contact 1: Salutation</th>\n';
        headerRow += '<th filter=all id="col-56">Additional contact 1: First name</th>\n';
        headerRow += '<th filter=all id="col-57">Additional contact 1: Middle name</th>\n';
        headerRow += '<th filter=all id="col-58">Additional contact 1: Last name</th>\n';
        headerRow += '<th filter=all id="col-59">Additional contact 1: Role</th>\n';
        headerRow += '<th filter=all id="col-60">Additional contact 1: Email </th>\n';
        headerRow += '<th filter=all id="col-61">Additional contact 1: Phone </th>\n';
        headerRow += '<th filter=all id="col-62">Additional contact 1: Mobile</th>\n';
        headerRow += '<th filter=all id="col-63">Additional contact 1: Fax</th>\n';
        headerRow += '<th filter=all id="col-64">Additional contact 2: Salutation</th>\n';
        headerRow += '<th filter=all id="col-65">Additional contact 2: First name</th>\n';
        headerRow += '<th filter=all id="col-66">Additional contact 2: Middle name</th>\n';
        headerRow += '<th filter=all id="col-67">Additional contact 2: Last name</th>\n';
        headerRow += '<th filter=all id="col-68">Additional contact 2: Role</th>\n';
        headerRow += '<th filter=all id="col-69">Additional contact 2: Email </th>\n';
        headerRow += '<th filter=all id="col-70">Additional contact 2: Phone</th>\n';
        headerRow += '<th filter=all id="col-71">Additional contact 2: Mobile</th>\n';
        headerRow += '<th filter=all id="col-72">Additional contact 2: Fax</th>\n';

        headerRow += '<th filter=all id="col-73">Requested Type of the Card</th>\n';
        headerRow += '<th filter=all id="col-74">Category of products</th>\n';
        headerRow += '<th filter=all id="col-75">Type of the vehicle</th>\n';
        headerRow += '<th filter=all id="col-76">Custom PIN</th>\n';
        headerRow += '<th filter=all id="col-77">Name company on the card (25 char)</th>\n';
        headerRow += '<th filter=all id="col-78">License plate number</th>\n';
        headerRow += '<th filter=all id="col-79">Driver Name</th>\n';
        headerRow += '<th filter=all id="col-80">Mileage data</th>\n';
        headerRow += '<th filter=all id="col-81">Link to Account</th>\n';
        headerRow += '<th filter=all id="col-82">Link to Opportunity</th>\n';
        headerRow += '<th filter=all id="col-83">Eco Fee</th>\n';
        headerRow += '<th filter=all id="col-84">VAT Recovery</th>\n';
        headerRow += '</tr>\n';
        return headerRow;
    }

    /*******************************************************************************
    *  Name            : getTableBody()
    *  Summary         : get all data for report and generate a body of the table
    *  CreatedDate     : 30/11/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getTableBody() {
        Account acc = [SELECT Id, Account_Nr__c, Type, Name, Gesellschaftsform__c, Steuernummer__c,
                HR_Abteilung_HRA_HRB_und_HR_Nummer__c, Umsatzsteuer_ID__c, BillingCountry,
                BillingState, BillingCity, BillingPostalCode, BillingStreet, ShippingCountry,
                ShippingState, ShippingCity, ShippingPostalCode, ShippingStreet, UMR__c
        FROM Account WHERE Id = :accountId LIMIT 1];

        Opportunity opp = [
                SELECT  Opportunity.Id, Opportunity.Name, Opportunity.Sec_Channel__c, Opportunity.LeadSource,
                        Opportunity.Language_Preference__c, Owner.FirstName, Owner.LastName, Opportunity.SWIFT_BIC__c,
                        Opportunity.IBAN__c, Opportunity.Custom_PIN__c, Opportunity.Credit_System_Number__c,
                        Opportunity.Product__c, Opportunity.Angebotsdauer__c, Opportunity.ESI__c,
                        Opportunity.Total_number_of_vehicles__c, Opportunity.Anzahl_der_Karten__c,
                        Opportunity.Total_consumption_l_month__c, Opportunity.Zahlungsart__c, Opportunity.Direct_Debit_Mandate_Type__c,
                        Opportunity.Credit_Limit__c, Opportunity.CurrencyIsoCode, Opportunity.Zahlungsziel_Credit__c,
                        Opportunity.Risk_Category__c, Opportunity.Next_Review_date__c, Opportunity.Rechnungsperiode__c,
                        Opportunity.e_Invoicing_PDF__c, Opportunity.Papierrechnung__c, Opportunity.bearbeitet_von__c,
                        Opportunity.Credit_System_Rating__c, Opportunity.Garantie__c, Opportunity.Garantie_other__c,
                        Opportunity.Eco_Fee__c, Opportunity.VAT_Recovery__c,
                (SELECT Contact.Id, Contact.Salutation, Contact.FirstName, Contact.MiddleName, Contact.LastName,
                        Role, Contact.Email, Contact.Phone, Contact.MobilePhone, Contact.Fax, IsPrimary
                FROM OpportunityContactRoles LIMIT 3),
                (SELECT Id, Gewuenschter_Kartentyp__c, Produktbezugskategorie__c, Fahrzeugtyp__c, Firmenname_auf_der_Karte__c,
                        KFZ_Kennzeichen_oder_Fahrername__c, Driver_Name__c, Kilometerstand_Abfrage__c
                FROM Tankkarten__r)
                FROM Opportunity
                WHERE id = :opportunityId
                LIMIT 1];

        AccountGfnReport accountGfnReport = new AccountGfnReport();
        if (opp != null && acc != null) {
            List<OpportunityContactRole> contactRoles = opp.OpportunityContactRoles;
            List<Tankkarten__c> cards = opp.Tankkarten__r;

            // Prepare report fields
            accountGfnReport.accountNum = GlobalUtils.blankStringIfNull(acc.Account_Nr__c);
            accountGfnReport.accountType = GlobalUtils.blankStringIfNull(
                    GlobalUtils.getPicklistValueTranslation(Account.Type.getDescribe(), acc.Type));
            accountGfnReport.opportunitySecChannel = GlobalUtils.blankStringIfNull(opp.Sec_Channel__c);
            accountGfnReport.opportunityLeadSource = GlobalUtils.blankStringIfNull(opp.LeadSource);
            accountGfnReport.accountName = GlobalUtils.blankStringIfNull(acc.Name);
            accountGfnReport.language = GlobalUtils.blankStringIfNull(opp.Language_preference__c);
            accountGfnReport.opportunityOwner = GlobalUtils.blankStringIfNull(opp.Owner.FirstName + ' ' + opp.Owner.LastName);
            accountGfnReport.companyForm = GlobalUtils.blankStringIfNull(
                    GlobalUtils.getPicklistValueTranslation(Account.Gesellschaftsform__c.getDescribe(), acc.Gesellschaftsform__c));
            accountGfnReport.taxId = GlobalUtils.blankStringIfNull(acc.Steuernummer__c);
            accountGfnReport.tradeRegisterNum = GlobalUtils.blankStringIfNull(acc.HR_Abteilung_HRA_HRB_und_HR_Nummer__c);
            accountGfnReport.vatNum = GlobalUtils.blankStringIfNull(acc.Umsatzsteuer_ID__c);
            accountGfnReport.swiftBic = GlobalUtils.blankStringIfNull(opp.SWIFT_BIC__c);
            accountGfnReport.iban = GlobalUtils.blankStringIfNull(opp.IBAN__c);
            accountGfnReport.creditSystemNum = GlobalUtils.blankStringIfNull(opp.Credit_System_Number__c);
            accountGfnReport.opportunityProduct = GlobalUtils.blankStringIfNull(opp.Product__c);
            accountGfnReport.offerDuration = GlobalUtils.blankStringIfNull(
                    GlobalUtils.getPicklistValueTranslation(Opportunity.Angebotsdauer__c.getDescribe(), opp.Angebotsdauer__c));
            accountGfnReport.esi = GlobalUtils.blankStringIfNull(opp.ESI__c);
            accountGfnReport.numOfVehicles = GlobalUtils.blankStringIfNull(String.valueOf(opp.Total_number_of_vehicles__c)); // decimal
            accountGfnReport.numOfCards = GlobalUtils.blankStringIfNull(String.valueOf(opp.Anzahl_der_Karten__c)); // decimal
            accountGfnReport.consumptionInMonth = GlobalUtils.blankStringIfNull(String.valueOf(opp.Total_consumption_l_month__c)); // decimal
            accountGfnReport.paymentMethod = GlobalUtils.blankStringIfNull(
                    GlobalUtils.getPicklistValueTranslation(Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c));
            accountGfnReport.directDebitMandateType = GlobalUtils.blankStringIfNull(
                    GlobalUtils.getPicklistValueTranslation(Opportunity.Direct_Debit_Mandate_Type__c.getDescribe(), opp.Direct_Debit_Mandate_Type__c));
            accountGfnReport.umr = GlobalUtils.blankStringIfNull(acc.UMR__c);
            accountGfnReport.creditLimit = GlobalUtils.blankStringIfNull(String.valueOf(opp.Credit_Limit__c));
            accountGfnReport.creditLimitCurrency = GlobalUtils.blankStringIfNull(opp.CurrencyIsoCode);
            accountGfnReport.paymentTermsCredit = GlobalUtils.blankStringIfNull(
                    GlobalUtils.getPicklistValueTranslation(Opportunity.Zahlungsziel_Credit__c.getDescribe(), opp.Zahlungsziel_Credit__c));
            accountGfnReport.riskCategory = GlobalUtils.blankStringIfNull(opp.Risk_Category__c);
            accountGfnReport.billingPeriod = GlobalUtils.blankStringIfNull(
                    GlobalUtils.getPicklistValueTranslation(Opportunity.Rechnungsperiode__c.getDescribe(), opp.Rechnungsperiode__c));
            accountGfnReport.invoicingPdf = GlobalUtils.blankBooleanIfNull(opp.e_Invoicing_PDF__c) ? 1 : 0;
            accountGfnReport.isPaperInvoicing = GlobalUtils.blankBooleanIfNull(opp.Papierrechnung__c) ? 1 : 0;
            accountGfnReport.processedBy = GlobalUtils.blankStringIfNull(opp.Bearbeitet_von__c);
            accountGfnReport.creditSystemRating = GlobalUtils.blankStringIfNull(opp.Credit_System_Rating__c);
            String nextReviewDate = '';
            if(opp.Next_Review_Date__c != null){
                nextReviewDate = DateTime.newInstance(opp.Next_Review_Date__c.year(), opp.Next_Review_Date__c.month(), opp.Next_Review_Date__c.day()).format('dd.MM.yyyy');
            }
            accountGfnReport.nextReviewDate = GlobalUtils.blankStringIfNull(nextReviewDate);
            accountGfnReport.security = GlobalUtils.blankStringIfNull(
                    GlobalUtils.getPicklistValueTranslation(Opportunity.Garantie__c.getDescribe(), opp.Garantie__c));
            accountGfnReport.securityAmount = GlobalUtils.blankStringIfNull(String.valueOf(opp.Garantie_other__c)); // decimal
            accountGfnReport.registeredCountry = GlobalUtils.blankStringIfNull(acc.BillingCountry);
            accountGfnReport.registeredState = GlobalUtils.blankStringIfNull(acc.BillingState);
            accountGfnReport.registeredCity = GlobalUtils.blankStringIfNull(acc.BillingCity);
            accountGfnReport.registeredZip = GlobalUtils.blankStringIfNull(acc.BillingPostalCode);
            accountGfnReport.registeredStreet = GlobalUtils.blankStringIfNull(acc.BillingStreet);
            accountGfnReport.shippingCountry = GlobalUtils.blankStringIfNull(acc.ShippingCountry);
            accountGfnReport.shippingState = GlobalUtils.blankStringIfNull(acc.ShippingState);
            accountGfnReport.shippingCity = GlobalUtils.blankStringIfNull(acc.ShippingCity);
            accountGfnReport.shippingZip = GlobalUtils.blankStringIfNull(acc.ShippingPostalCode);
            accountGfnReport.shippingStreet = GlobalUtils.blankStringIfNull(acc.ShippingStreet);
            accountGfnReport.customPin = GlobalUtils.blankBooleanIfNull(opp.Custom_PIN__c) ? 1 : 0;
            accountGfnReport.accountLink = URLs__c.getInstance().Organization_URLs__c + '/' + GlobalUtils.blankStringIfNull(acc.Id);
            accountGfnReport.opportunityLink = URLs__c.getInstance().Organization_URLs__c + '/' + GlobalUtils.blankStringIfNull(opp.Id);
            accountGfnReport.ecoFee = GlobalUtils.blankBooleanIfNull(opp.Eco_Fee__c) ? 1 : 0;
            accountGfnReport.vatRecovery = GlobalUtils.blankBooleanIfNull(opp.VAT_Recovery__c) ? 1 : 0;
            List<ContactGfnReport> contacts = new List<ContactGfnReport>();
            for(OpportunityContactRole contactRole : contactRoles){
                ContactGfnReport contact = new ContactGfnReport();
                contact.salutation = GlobalUtils.blankStringIfNull(contactRole.Contact.Salutation);
                contact.firstName = GlobalUtils.blankStringIfNull(contactRole.Contact.FirstName);
                contact.middleName = GlobalUtils.blankStringIfNull(contactRole.Contact.MiddleName);
                contact.lastName = GlobalUtils.blankStringIfNull(contactRole.Contact.LastName);
                contact.role = GlobalUtils.blankStringIfNull(contactRole.Role);
                contact.email = GlobalUtils.blankStringIfNull(contactRole.Contact.Email);
                contact.phone = GlobalUtils.blankStringIfNull(contactRole.Contact.Phone);
                contact.mobilePhone = GlobalUtils.blankStringIfNull(contactRole.Contact.MobilePhone);
                contact.fax = GlobalUtils.blankStringIfNull(contactRole.Contact.Fax);
                contact.isPrimary = contactRole.IsPrimary;
                contacts.add(contact);
            }
            accountGfnReport.contacts = contacts;
            List<CardGfnReport> reportCards = new List<CardGfnReport>();
            for(Tankkarten__c tankkarten : cards){
                CardGfnReport reportCard = new CardGfnReport();
                reportCard.cardRequestedType = GlobalUtils.blankStringIfNull(tankkarten.Gewuenschter_Kartentyp__c);
                reportCard.productsCategory = GlobalUtils.blankStringIfNull(
                        GlobalUtils.getPicklistValueTranslation(Tankkarten__c.Produktbezugskategorie__c.getDescribe(), tankkarten.Produktbezugskategorie__c));
                reportCard.vehicleType = GlobalUtils.blankStringIfNull(tankkarten.Fahrzeugtyp__c);
                reportCard.companyShortName = GlobalUtils.blankStringIfNull(tankkarten.Firmenname_auf_der_Karte__c);
                reportCard.registrationNum = GlobalUtils.blankStringIfNull(tankkarten.KFZ_Kennzeichen_oder_Fahrername__c);
                reportCard.driverName = GlobalUtils.blankStringIfNull(tankkarten.Driver_Name__c);
                reportCard.mileageData = GlobalUtils.blankBooleanIfNull(tankkarten.Kilometerstand_Abfrage__c) ? 1 : 0;
                reportCards.add(reportCard);
            }
            accountGfnReport.cards = reportCards;
        }
        String tableBody = generateBodyHtmlTemplate(accountGfnReport);
        return tableBody;
    }

    /*******************************************************************************
    *  Name            : generateBodyHtmlTemplate()
    *  Summary         : generate a body of HTML template
    *  CreatedDate     : 30/11/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private String generateBodyHtmlTemplate(AccountGfnReport accountGfnReport){

        // Sorting contacts on a main and additions
        Map<String, ContactGfnReport> contactsRoles = new Map<String, ContactGfnReport>();
        Integer index = 1;
        Boolean hasPrimaryContact = false;
        for (Integer i = 0; i < accountGfnReport.contacts.size(); i++) {
            ContactGfnReport contact = accountGfnReport.contacts.get(i);
            if(contact.isPrimary){
                contactsRoles.put('main', contact);
                hasPrimaryContact = true;
            } else {
                contactsRoles.put('addition' + index, contact);
                index++;
            }
        }

        // if primary contact is missing make the first contact as main
        if((accountGfnReport.contacts.size() > 0) && !hasPrimaryContact){
            contactsRoles = fillPrimaryContactRole(accountGfnReport.contacts);
        }

        String bodyTemplate = '';
        if (accountGfnReport.cards.size() > 0) {
            for (CardGfnReport card : accountGfnReport.cards) {
                bodyTemplate += getDataRow(accountGfnReport, contactsRoles, card.cardRequestedType,
                        card.productsCategory, card.vehicleType, card.companyShortName, card.registrationNum,
                        card.driverName, String.valueOf(card.mileageData));
            }
        } else {
            bodyTemplate += getDataRow(accountGfnReport, contactsRoles, '', '', '', '', '', '', '');
        }

        return bodyTemplate.unescapeHtml3();
    }

    private String getDataRow(AccountGfnReport accountGfnReport, Map<String, ContactGfnReport> contactsRoles,
            String cardRequestedType, String productsCategory, String vehicleType, String companyShortName,
            String registrationNum, String driverName, String mileageData) {

        String dataRow = '<tr class="dataRow">\n';
        dataRow += '<td id="data-1" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.accountNum + '</td>\n';
        dataRow += '<td id="data-2" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.accountType + '</td>\n';
        dataRow += '<td id="data-3" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.opportunitySecChannel + '</td>\n';
        dataRow += '<td id="data-4" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.opportunityLeadSource + '</td>\n';
        dataRow += '<td id="data-5" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.accountName + '</td>\n';
        dataRow += '<td id="data-6" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.language + '</td>\n';
        dataRow += '<td id="data-7" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.opportunityOwner + '</td>\n';
        dataRow += '<td id="data-8" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.companyForm + '</td>\n';
        dataRow += '<td id="data-9" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.taxId + '</td>\n';
        dataRow += '<td id="data-10" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.tradeRegisterNum + '</td>\n';
        dataRow += '<td id="data-11" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.vatNum + '</td>\n';
        dataRow += '<td id="data-12" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.swiftBic + '</td>\n';
        dataRow += '<td id="data-13" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.iban + '</td>\n';
        dataRow += '<td id="data-14" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.creditSystemNum + '</td>\n';
        dataRow += '<td id="data-15" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.opportunityProduct + '</td>\n';
        dataRow += '<td id="data-16" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.offerDuration + '</td>\n';
        dataRow += '<td id="data-17" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.esi + '</td>\n';
        dataRow += '<td id="data-18" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.numOfVehicles + '</td>\n';
        dataRow += '<td id="data-19" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.numOfCards + '</td>\n';
        dataRow += '<td id="data-20" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.consumptionInMonth + '</td>\n';
        dataRow += '<td id="data-21" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.paymentMethod + '</td>\n';
        dataRow += '<td id="data-22" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.directDebitMandateType + '</td>\n';
        dataRow += '<td id="data-23" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.umr + '</td>\n';
        dataRow += '<td id="data-24" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.creditLimit + '</td>\n';
        dataRow += '<td id="data-25" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.creditLimitCurrency + '</td>\n';
        dataRow += '<td id="data-26" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.paymentTermsCredit + '</td>\n';
        dataRow += '<td id="data-27" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.riskCategory + '</td>\n';
        dataRow += '<td id="data-28" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.billingPeriod + '</td>\n';
        dataRow += '<td id="data-29" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.invoicingPdf + '</td>\n';
        dataRow += '<td id="data-30" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.isPaperInvoicing + '</td>\n';
        dataRow += '<td id="data-31" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.processedBy + '</td>\n';
        dataRow += '<td id="data-32" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.creditSystemRating + '</td>\n';
        dataRow += '<td id="data-33" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.nextReviewDate + '</td>\n';
        dataRow += '<td id="data-34" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.security + '</td>\n';
        dataRow += '<td id="data-35" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.securityAmount + '</td>\n';
        dataRow += '<td id="data-36" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.registeredCountry + '</td>\n';
        dataRow += '<td id="data-37" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.registeredState + '</td>\n';
        dataRow += '<td id="data-38" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.registeredCity + '</td>\n';
        dataRow += '<td id="data-39" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.registeredZip + '</td>\n';
        dataRow += '<td id="data-40" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.registeredStreet + '</td>\n';
        dataRow += '<td id="data-41" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.shippingCountry + '</td>\n';
        dataRow += '<td id="data-42" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.shippingState + '</td>\n';
        dataRow += '<td id="data-43" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.shippingCity + '</td>\n';
        dataRow += '<td id="data-44" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.shippingZip + '</td>\n';
        dataRow += '<td id="data-45" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.shippingStreet + '</td>\n';

        dataRow += '<td id="data-46" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('main') ? contactsRoles.get('main').salutation : '') + '</td>\n';
        dataRow += '<td id="data-47" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('main') ? contactsRoles.get('main').firstName : '') + '</td>\n';
        dataRow += '<td id="data-48" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('main') ? contactsRoles.get('main').middleName : '') + '</td>\n';
        dataRow += '<td id="data-49" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('main') ? contactsRoles.get('main').lastName : '') + '</td>\n';
        dataRow += '<td id="data-50" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('main') ? contactsRoles.get('main').role : '') + '</td>\n';
        dataRow += '<td id="data-51" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('main') ? String.valueOf(contactsRoles.get('main').email) : '') + '</td>\n';
        dataRow += '<td id="data-52" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('main') ? contactsRoles.get('main').phone : '') + '</td>\n';
        dataRow += '<td id="data-53" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('main') ? contactsRoles.get('main').mobilePhone : '') + '</td>\n';
        dataRow += '<td id="data-54" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('main') ? contactsRoles.get('main').fax : '') + '</td>\n';
        dataRow += '<td id="data-55" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition1') ? contactsRoles.get('addition1').salutation : '') + '</td>\n';
        dataRow += '<td id="data-56" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition1') ? contactsRoles.get('addition1').firstName : '') + '</td>\n';
        dataRow += '<td id="data-57" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition1') ? contactsRoles.get('addition1').middleName : '') + '</td>\n';
        dataRow += '<td id="data-58" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition1') ? contactsRoles.get('addition1').lastName : '') + '</td>\n';
        dataRow += '<td id="data-59" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition1') ? contactsRoles.get('addition1').role : '') + '</td>\n';
        dataRow += '<td id="data-60" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition1') ? String.valueOf(contactsRoles.get('addition1').email) : '') + '</td>\n';
        dataRow += '<td id="data-61" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition1') ? contactsRoles.get('addition1').phone : '') + '</td>\n';
        dataRow += '<td id="data-62" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition1') ? contactsRoles.get('addition1').mobilePhone : '') + '</td>\n';
        dataRow += '<td id="data-63" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition1') ? contactsRoles.get('addition1').fax : '') + '</td>\n';
        dataRow += '<td id="data-64" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition2') ? contactsRoles.get('addition2').salutation : '') + '</td>\n';
        dataRow += '<td id="data-65" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition2') ? contactsRoles.get('addition2').firstName : '') + '</td>\n';
        dataRow += '<td id="data-66" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition2') ? contactsRoles.get('addition2').middleName : '') + '</td>\n';
        dataRow += '<td id="data-67" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition2') ? contactsRoles.get('addition2').lastName : '') + '</td>\n';
        dataRow += '<td id="data-68" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition2') ? contactsRoles.get('addition2').role : '') + '</td>\n';
        dataRow += '<td id="data-69" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition2') ? String.valueOf(contactsRoles.get('addition2').email) : '') + '</td>\n';
        dataRow += '<td id="data-70" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition2') ? contactsRoles.get('addition2').phone : '') + '</td>\n';
        dataRow += '<td id="data-71" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition2') ? contactsRoles.get('addition2').mobilePhone : '') + '</td>\n';
        dataRow += '<td id="data-72" style="vnd.ms-excel.numberformat:@">' + (contactsRoles.containsKey('addition2') ? contactsRoles.get('addition2').fax : '') + '</td>\n';

        dataRow += '<td id="data-73" style="vnd.ms-excel.numberformat:@">' + cardRequestedType + '</td>\n';
        dataRow += '<td id="data-74" style="vnd.ms-excel.numberformat:@">' + productsCategory + '</td>\n';
        dataRow += '<td id="data-75" style="vnd.ms-excel.numberformat:@">' + vehicleType + '</td>\n';
        dataRow += '<td id="data-76" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.customPin + '</td>\n';
        dataRow += '<td id="data-77" style="vnd.ms-excel.numberformat:@">' + companyShortName + '</td>\n';
        dataRow += '<td id="data-78" style="vnd.ms-excel.numberformat:@">' + registrationNum + '</td>\n';
        dataRow += '<td id="data-79" style="vnd.ms-excel.numberformat:@">' + driverName + '</td>\n';
        dataRow += '<td id="data-80" style="vnd.ms-excel.numberformat:@">' + mileageData + '</td>\n';

        dataRow += '<td id="data-81" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.accountLink + '</td>\n';
        dataRow += '<td id="data-82" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.opportunityLink + '</td>\n';
        dataRow += '<td id="data-83" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.ecoFee + '</td>\n';
        dataRow += '<td id="data-84" style="vnd.ms-excel.numberformat:@">' + accountGfnReport.vatRecovery + '</td>\n';
        dataRow += '</tr>\n';
        return dataRow;
    }

    private Map<String, ContactGfnReport> fillPrimaryContactRole(List<ContactGfnReport> contacts){
        Map<String, ContactGfnReport> contactsRoles = new Map<String, ContactGfnReport>();
        Integer index = 1;
        for (Integer i = 0; i < contacts.size(); i++) {
            ContactGfnReport contact = contacts.get(i);
            if(i == 0){
                contactsRoles.put('main', contact);
            } else {
                contactsRoles.put('addition' + index, contact);
                index++;
            }
        }
        return contactsRoles;
    }
}