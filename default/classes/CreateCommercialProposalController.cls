public class CreateCommercialProposalController {
    public String opportunityId {get; set;}
    public Opportunity opportunity {get; set;}
    public User user {get; set;}
    public Commercial_Proposal_Template__c template {get; set;}
    public String pdfBody {get; set;}
    public String attachmentId {get; set;}
    public String selectedRadius {get; set;}
    public String selectedProduct {get; set;}
    public String selectedContact {get; set;}
    public List<String> selectedBrands {get; set;}
    public Map<String, Attachment> attachmentsMap;
    public List<SelectOption> allAttachmentsOptionsList {get; set;}
    public List<String> selectedAttachments {get; set;}
    public List<CommercialProposalMapWrapper.PetrolStationList> petrolStations {get; set;}
    public List<StationsWrapperList> stationsWrapperList {get; set;}
    public Map<Id, Contact> contactsMap {get; set;}
    public Integer pdfHeight {get; set;}
    public Boolean isGenerate {get; set;}
    public Boolean isError {get; set;}
    public String orgDomain {get; set;}
    transient Attachment attachment;


    public CreateCommercialProposalController() {
        this.isGenerate = false;
        this.isError = false;
    }


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : initialization of the initial data for commercial proposal: 
                         1)current account manager( user ), 
                         2)opportunity for commercial proposal, 
                         3)contact for account,
                         4)email text and pdf text (text templates for products),
                         5)launches a method to return map placed on it filling stations.
    *  CreatedDate     : 03/01/2017
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void init() {
    	try {
	        if ( ! this.isGenerate ) {
	            this.selectedRadius = '10';
	            this.selectedProduct = '1';
                this.stationsWrapperList = new List<StationsWrapperList>();
	            this.orgDomain = Url.getSalesforceBaseUrl().toExternalForm().substringBetween('://c.','.');
	            this.opportunityId = Apexpages.currentPage().getParameters().get('id');
	            this.selectedBrands = new List<String>();
                this.selectedAttachments = new List<String>();
	            this.user = CreateCommercialProposalUtils.doSelectUser();
	            this.opportunity = CreateCommercialProposalUtils.doSelectOpportunity(this.opportunityId);
	            this.contactsMap = CreateCommercialProposalUtils.doSelectContactsInMap(this.opportunity.AccountId);
	            this.template = CreateCommercialProposalUtils.doSelectComProTemplates(this.opportunity.Product__c, this.opportunity.Account.BillingCountry);
                this.attachmentsMap = CreateCommercialProposalUtils.doSelectAttachments(this.template);
                this.allAttachmentsOptionsList = returnAttachmentOption();         
	            validate();   
	            returnMap();
	        }
    	} catch (Exception e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            isError = true;
    	}
    }


    /*******************************************************************************
    *  Name            : returnMap()
    *  Summary         : generates a map with a filling stations    
    *  CreatedDate     : 03/01/2017
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void returnMap() {
        this.petrolStations = new List<CommercialProposalMapWrapper.PetrolStationList>();
        HttpRequest request = CreateCommercialProposalUtils.generateRequest(this.opportunity.Account.BillingCountry, this.opportunity.Account.BillingCity,
         																	this.opportunity.Account.BillingStreet, this.selectedBrands, this.selectedRadius, 
                                                                            this.selectedProduct);
        Http http = new Http();
        HttpResponse res = http.send(request);
        if (res.getStatus() == 'Internal Server Error') {
            ExceptionApi excp = (ExceptionApi)JSON.deserialize(res.getBody(), ExceptionApi.class);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, excp.field));
            this.isError = true;
            return;
        }

        CommercialProposalMapWrapper apiMap = (CommercialProposalMapWrapper) JSON.deserialize(res.getBody(), CommercialProposalMapWrapper.class);
        for (CommercialProposalMapWrapper.PetrolStationList station : apiMap.petrolStationList) {
            this.petrolStations.add(station);
            this.stationsWrapperList.add(new StationsWrapperList(
                    station,
                    station.distanceToFuelStation));
        }

        this.stationsWrapperList.sort();
        deleteAttachment();

        //insert temp attachment
        this.attachment = new Attachment();
        this.attachment.Body = EncodingUtil.base64Decode(apiMap.mapImage);
        this.attachment.Name = 'TEMP_MAP.jpg';
        this.attachment.ParentId = this.opportunity.Id; 
        insert this.attachment;
        this.attachmentId = this.attachment.Id;
        this.attachment = new Attachment(); 
        if (Test.isRunningTest()) {
            String addressTest = apiMap.petrolStationList.get(0).address;
            Decimal distanceToFuelStationTest = apiMap.petrolStationList.get(0).distanceToFuelStation;
            String phoneTest = apiMap.petrolStationList.get(0).phone;
            Decimal indexNumberTest = apiMap.petrolStationList.get(0).indexNumber;
            String brandNameTest = apiMap.petrolStationList.get(0).brand.Name;
            Decimal distanceFromRoadTest = apiMap.petrolStationList.get(0).distanceFromRoad;
        }
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : generate emails for sending    
    *  CreatedDate     : 03/01/2017
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void sendEmail() {                                                                                                     
        try {
            this.pdfBody = CreateCommercialProposalUtils.mergeText(
                this.template.PDF_body__c, 
                this.opportunity, 
                this.contactsMap.get(Id.valueOf(this.selectedContact)), 
                this.user);
            String emailBody = CreateCommercialProposalUtils.mergeText(
                this.template.Email_Body__c, 
                this.opportunity, 
                this.contactsMap.get(Id.valueOf(this.selectedContact)), 
                this.user);

            List<Messaging.SingleEmailMessage> emails = CreateCommercialProposalUtils.preporationEmailsForSending(
                this.template, 
                this.opportunity, 
                this.contactsMap, 
                this.selectedContact,
                this.attachmentsMap,
                this.selectedAttachments,
                emailBody );  
            if (! Test.isRunningTest()) {
                Messaging.sendEmail(emails);
            }
            this.opportunity.Commercial_Proposal_Sent__c = true;
            update this.opportunity;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email sent.'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : error checking during initialization data    
    *  CreatedDate     : 05/01/2017
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void validate() {
        CreateCommercialProposalUtils.validateClosedOpp(this.opportunity);
        CreateCommercialProposalUtils.validateCountries(this.opportunity);
		CreateCommercialProposalUtils.validateContactsMap(this.contactsMap);
		CreateCommercialProposalUtils.validateTemplate(this.template);
    }


    public PageReference generatePDF() {
        this.isGenerate = true;
        this.pdfBody = CreateCommercialProposalUtils.mergeText(this.template.PDF_body__c, this.opportunity, this.contactsMap.get(Id.valueOf(this.selectedContact)), this.user);
        PageReference page = new PageReference('/apex/commercialproposalpdfgenerate');
        return page;
    }


    public PageReference previewPDF() {
        this.isGenerate = false;
        this.pdfBody = CreateCommercialProposalUtils.mergeText(this.template.PDF_body__c, this.opportunity, this.contactsMap.get(Id.valueOf(this.selectedContact)), this.user);
        PageReference page = new PageReference('/apex/commercialproposalpdf');
        return page;
    }


    public PageReference returnToCreate() {
        PageReference page = new PageReference('/apex/createcommercialproposal');
        return page;
    }


    public void deleteAttachment() {
        delete [SELECT Id FROM Attachment WHERE Name = 'TEMP_MAP.jpg' AND ParentId = :this.opportunityId];
    }


    public PageReference cancel() {
        return new PageReference('/' + this.opportunityId);
    }


    public class StationsWrapperList implements Comparable {
        public CommercialProposalMapWrapper.PetrolStationList station {get; set;}
        public Decimal compareValue {get; set;}

        public stationsWrapperList(CommercialProposalMapWrapper.PetrolStationList station, Decimal compareValue) {
            this.station = station;
            this.compareValue = compareValue;
        }

        public Integer compareTo(Object compareTo) {
            StationsWrapperList compareToU = (StationsWrapperList)compareTo;
            if (compareValue == compareToU.compareValue) return 1;
            if (compareValue < compareToU.compareValue) return 0;
            return -1;        
        }
    }


    public List<SelectOption> getRadius() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1','1'));
        options.add(new SelectOption('2','2'));
        options.add(new SelectOption('3','3'));
        options.add(new SelectOption('4','4'));
        options.add(new SelectOption('5','5'));
        options.add(new SelectOption('6','6'));
        options.add(new SelectOption('7','7'));
        options.add(new SelectOption('8','8'));
        options.add(new SelectOption('9','9'));
        options.add(new SelectOption('10','10'));
        return options;
    }


    public List<SelectOption> getAdditionalServices() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('101','Ad Blue'));
        options.add(new SelectOption('102','Car wash'));
        options.add(new SelectOption('103','WC'));
        options.add(new SelectOption('104','Shower'));
        options.add(new SelectOption('105','Shop'));
        options.add(new SelectOption('106','24 Hour'));
        options.add(new SelectOption('107','ATM'));
        options.add(new SelectOption('108','Restaurant'));
        options.add(new SelectOption('109','Truck friendly'));

        return options;
    }


    public List<SelectOption> getProducts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1','euroShell Card Multi (International)'));
        options.add(new SelectOption('2','euroShell Card Single (International)'));
        options.add(new SelectOption('3','euroShell Card Multi'));
        options.add(new SelectOption('4','euroShell Card Single'));

        return options;
    }


    public List<SelectOption> getBrands() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', 'AVIA'));
        options.add(new SelectOption('4', 'ESSO'));
        options.add(new SelectOption('7', 'IQ'));
        options.add(new SelectOption('9', 'OMV'));
        options.add(new SelectOption('10', 'PETROL'));
        options.add(new SelectOption('11', 'Q8'));
        options.add(new SelectOption('13', 'SHELL'));
        options.add(new SelectOption('16', 'TOTAL'));
        options.add(new SelectOption('18', 'BENZINA'));
        options.add(new SelectOption('19', 'CERPO'));
        options.add(new SelectOption('23', 'M-RAST'));
        options.add(new SelectOption('25', 'SMART DIESEL'));
        options.add(new SelectOption('35', 'BP'));

        return options;
    }
    

    public Map<String, List<String>> getTranslateFillingStationColumnsMap() {
        Map<String, List<String>> translations = new Map<String, List<String>>();
        translations.put('Germany', new List<String> {'Brand', 'Adresse', 'Entfernung zur Tankstelle, km'});
        translations.put('Netherlands', new List<String> {'Merk', 'Adres', 'Afstand tot tankstation, km'});
        translations.put('France', new List<String> {'Enseigne', 'Adresse', 'Distance de la station service, km'});
        translations.put('Belgium-FR', new List<String> {'Enseigne', 'Adresse', 'Distance de la station service, km'});
        translations.put('Belgium-NL', new List<String> {'Merk', 'Adres', 'Afstand tot tankstation, km'});

        translations.put('Poland', new List<String> {'Sieć', 'Adres', 'Odległość od stacji paliwowej, km'});
        translations.put('Hungary', new List<String> {'Márka', 'Cím', 'Távolság a benzinkútig, km'});
        translations.put('Czech Republic', new List<String> {'Síť', 'Adresa', 'Vzdálenost k čerpací stanici, km'});
        translations.put('Slovakia', new List<String> {'Sieť', 'Adresa', 'Vzdialenosť k čerpacej stanici, km'});
        translations.put('Luxembourg', new List<String> {'Enseigne', 'Adresse', 'Distance de la station service, km'});
        translations.put('Switzerland-DE', new List<String> {'Brand', 'Adresse', 'Entfernung zur Tankstelle, km'});
        translations.put('Switzerland-FR', new List<String> {'Enseigne', 'Adresse', 'Distance de la station service, km'});
        translations.put('Switzerland-IT', new List<String> {'Marca', 'Indirizzo', 'Distanza dalla stazione di servizio, km'});

        return translations;
    }

    public List<SelectOption> returnAttachmentOption() {
        if ( this.attachmentsMap != null && ! this.attachmentsMap.isEmpty() ) {
            List<SelectOption> options = new List<SelectOption>();
            for (Attachment attach : this.attachmentsMap.values()) {
                options.add(new SelectOption(attach.Name, attach.Name));
                this.selectedAttachments.add(attach.Name);
            }
            return options;
        }
        return null;
    }

    public class ExceptionApi {
        public String code {get; set;}
        public String msg {get; set;}
        public String field {get; set;}
    }
}