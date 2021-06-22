public class E2ETestDataCleanerCtrl {
    public String searchParam { get; set; }
    public String errorMessage { get; set; }
    public Map<String, Account> accountsMap { get; set; }
    public Map<String, List<Opportunity>> accountToOpportunitiesMap {get; set;}
    public Map<String, List<Contact>> accountToContactsMap {get; set;}
    public Map<String, List<OpportunityContactRole>> accountToOppContactRolesMap {get; set;}
    public Map<String, List<Health_Check__c>> accountToHealthChecksMap {get; set;}
    public Map<String, List<Payment_Transaction__c>> accountToPaymentTransactionsMap {get; set;}
    public Map<String, List<Credit_Factory_Report__c>> accountToCFreportsMap {get; set;}
    public Map<String, List<Tankkarten__c>> accountToCardsMap {get; set;}
    public Map<String, List<Attachment>> accountToAttachmentsMap {get; set;}
    public Map<String, List<OpportunityLineItem>> accountToOppLineItem {get; set;}
    public Map<String, List<Offer_Item__c>> accountToOfferItem {get; set;}
    public Map<String, List<E2E_Data_Object__c>> accountToDataObject {get; set;}
    public Map<String, List<E2E_Data_Log__c>> accountToDataLog {get; set;}
    public Map<String, List<E2E_Data_Offer_Item__c>> accountToDataOfferItem {get; set;}
    public Map<String, List<E2E_Data_Additional_Service__c>> accountToDataAdditionalService {get; set;}
    public Map<String, List<dsfs__DocuSign_Status__c>> accountToDocusignStatus {get; set;}
    public Map<String, List<ContentDocumentLink>> accountToContentDoc {get; set;}
    public Map<String, List<Quote>> accountToQuote {get; set;}
    private Map<String, List<SObject>> sobjectsToDeleteMap;
    public Map<String, Map<String, Integer>> numberOfObjectsFoundMap{ get; set; }
    public final Object BASEURL { get {
                                        Organization instance = [SELECT PrimaryContact, IsSandbox FROM Organization LIMIT 1];
                                        User primaryContact = [SELECT Name, Username FROM User WHERE Name = :instance.PrimaryContact];
                                        if (instance.isSandbox == true) {
                                            return 'https://fleetcor-eu--' + primaryContact.Username.substringAfterLast('.') + '.my.salesforce.com';
                                        } else {
                                            return 'https://fleetcor-eu.my.salesforce.com/';
                                        }
                                } set; }

    public void doSearch() {
        try {
            String key = ApexPages.CurrentPage().getparameters().get('key');
            if (key != null) {
                Map<String, E2E_Test_Data_Cleaner_Settings__c> settings = E2E_Test_Data_Cleaner_Settings__c.getAll();
                searchParam = searchParam.toLowerCase();
                if (! settings.containsKey(searchParam) || settings.get(searchParam).Encryption_Key__c != key) {
                    throw new LongFormException('You don\'t have access. Please contact your administrator.');
                }
                this.errorMessage = null;
                Map<String, String> e2eDataObjectIdToAccountId = new Map<String, String>();
                this.sobjectsToDeleteMap = new Map<String, List<SObject>>();
                this.accountToContactsMap = new Map<String, List<Contact>>();
                this.accountToOpportunitiesMap = new Map<String, List<Opportunity>>();
                this.accountToOppContactRolesMap = new Map<String, List<OpportunityContactRole>>();
                this.accountToHealthChecksMap = new Map<String, List<Health_Check__c>>();
                this.accountToPaymentTransactionsMap = new Map<String, List<Payment_Transaction__c>>();
                this.accountToCFreportsMap = new Map<String, List<Credit_Factory_Report__c>>();
                this.accountToCardsMap = new Map<String, List<Tankkarten__c>>();
                this.accountToAttachmentsMap = new Map<String, List<Attachment>>();
                this.accountToOppLineItem = new Map<String, List<OpportunityLineItem>>();
                this.accountToOfferItem = new Map<String, List<Offer_Item__c>>();
                this.accountToDataObject = new Map<String, List<E2E_Data_Object__c>>();
                this.accountToDataLog = new Map<String, List<E2E_Data_Log__c>>();
                this.accountToDataOfferItem = new Map<String, List<E2E_Data_Offer_Item__c>>();
                this.accountToDataAdditionalService = new Map<String, List<E2E_Data_Additional_Service__c>>();
                this.accountToDocusignStatus = new Map<String, List<dsfs__DocuSign_Status__c>>();
                this.accountToContentDoc = new Map<String, List<ContentDocumentLink>>();
                this.numberOfObjectsFoundMap = new Map<String, Map<String, Integer>>();
                this.accountToQuote = new Map<String, List<Quote>>();

                List<Contact> contactsList = [
                        SELECT Id, AccountId, Name, Email, CreatedDate, (SELECT AccountId FROM AccountContactRelations),
                        (SELECT Id, Contact.Name, ContactId, Opportunity.Name, Opportunity.E2E_Data_Object__c, OpportunityId, CreatedDate FROM OpportunityContactRoles)
                        FROM Contact
                        WHERE Email = :searchParam
                ];
                if (contactsList.size() == 0) {
                    throw new LongFormException('No search results');
                } else {
                    for (Contact con : contactsList) {
                        for (AccountContactRelation acr : con.AccountContactRelations) {
                            if (!this.accountToContactsMap.containsKey(acr.AccountId)) {
                                this.accountToContactsMap.put(acr.AccountId, new List<Contact>());
                                this.accountToOpportunitiesMap.put(acr.AccountId, new List<Opportunity>());
                                this.accountToOppContactRolesMap.put(acr.AccountId, new List<OpportunityContactRole>());
                                this.accountToHealthChecksMap.put(acr.AccountId, new List<Health_Check__c>());
                                this.accountToPaymentTransactionsMap.put(acr.AccountId, new List<Payment_Transaction__c>());
                                this.accountToCFreportsMap.put(acr.AccountId, new List<Credit_Factory_Report__c>());
                                this.accountToCardsMap.put(acr.AccountId, new List<Tankkarten__c>());
                                this.accountToAttachmentsMap.put(acr.AccountId, new List<Attachment>());
                                this.accountToOppLineItem.put(acr.AccountId, new List<OpportunityLineItem>());
                                this.accountToOfferItem.put(acr.AccountId, new List<Offer_Item__c>());
                                this.accountToDataObject.put(acr.AccountId, new List<E2E_Data_Object__c>());
                                this.accountToDataLog.put(acr.AccountId, new List<E2E_Data_Log__c>());
                                this.accountToDataOfferItem.put(acr.AccountId, new List<E2E_Data_Offer_Item__c>());
                                this.accountToDataAdditionalService.put(acr.AccountId, new List<E2E_Data_Additional_Service__c>());
                                this.accountToDocusignStatus.put(acr.AccountId, new List<dsfs__DocuSign_Status__c>());
                                this.accountToContentDoc.put(acr.AccountId, new List<ContentDocumentLink>());
                                this.sobjectsToDeleteMap.put(acr.AccountId, new List<SObject>());
                                this.numberOfObjectsFoundMap.put(acr.AccountId, new Map<String, Integer>());
                                this.accountToQuote.put(acr.AccountId, new List<Quote>());
                            }
                            // 1. Contacts
                            this.accountToContactsMap.get(acr.AccountId).add(con);
                        }

                        for (OpportunityContactRole ocr : con.OpportunityContactRoles) {
                            // 2. Opportunity Contact Roles
                            this.accountToOppContactRolesMap.get(con.AccountId).add(ocr);
                            this.sobjectsToDeleteMap.get(con.AccountId).add(ocr);
                        }
                    }
                    this.accountsMap = new Map<String, Account>([
                            SELECT Id, Name, (SELECT Id, AccountId, StageName, Name, Type, Amount, CloseDate, CreatedDate, E2E_Data_Object__c FROM Opportunities)
                            FROM Account
                            WHERE Id IN :accountToContactsMap.keySet()
                    ]);

                    Map<String, String> oppIdToAccountIdMap = new Map<String, String>();
                    for (Account acc : this.accountsMap.values()) {
                        for (Opportunity opp : acc.Opportunities) {
                            this.accountToOpportunitiesMap.get(acc.Id).add(opp);
                            oppIdToAccountIdMap.put(opp.Id, opp.AccountId);
                            if ( ! e2eDataObjectIdToAccountId.containsKey(opp.E2E_Data_Object__c)) {
                                e2eDataObjectIdToAccountId.put(opp.E2E_Data_Object__c, acc.Id);
                            }
                        }
                    }

                    // 3. Health check
                    List<Health_Check__c> healthChecksList = [
                            SELECT Id, Opportunity__r.AccountId, Name, Country__c, Device__c, CreatedDate
                            FROM Health_Check__c
                            WHERE Opportunity__c IN :oppIdToAccountIdMap.keySet()
                    ];
                    for (Health_Check__c healthCheck : healthChecksList) {
                        this.accountToHealthChecksMap.get(healthCheck.Opportunity__r.AccountId).add(healthCheck);
                        this.sobjectsToDeleteMap.get(healthCheck.Opportunity__r.AccountId).add(healthCheck);
                    }

                    // 4. Payment Transactions
                    List<Payment_Transaction__c> payTransactionsList = [
                            SELECT Id, Name, CreatedDate, OpportunityId__r.AccountId
                            FROM Payment_Transaction__c
                            WHERE OpportunityId__c IN :oppIdToAccountIdMap.keySet()
                    ];
                    for (Payment_Transaction__c payTransaction : payTransactionsList) {
                        this.accountToPaymentTransactionsMap.get(payTransaction.OpportunityId__r.AccountId).add(payTransaction);
                        this.sobjectsToDeleteMap.get(payTransaction.OpportunityId__r.AccountId).add(payTransaction);
                    }

                    // 5. Credit Factory Report
                    List<Credit_Factory_Report__c> creditFactoryReportsList = [
                            SELECT Id, Name, CreatedDate, Opportunity__r.AccountId
                            FROM Credit_Factory_Report__c
                            WHERE Opportunity__c IN :oppIdToAccountIdMap.keySet()
                    ];
                    for (Credit_Factory_Report__c creditFactoryReport : creditFactoryReportsList) {
                        this.accountToCFreportsMap.get(creditFactoryReport.Opportunity__r.AccountId).add(creditFactoryReport);
                        this.sobjectsToDeleteMap.get(creditFactoryReport.Opportunity__r.AccountId).add(creditFactoryReport);
                    }

                    // 6. Cards
                    List<Tankkarten__c> cardsList = [
                            SELECT Id, Name, CreatedDate, Opportunity__r.AccountId
                            FROM Tankkarten__c
                            WHERE Opportunity__c IN :oppIdToAccountIdMap.keySet()
                    ];
                    for (Tankkarten__c card : cardsList) {
                        this.accountToCardsMap.get(card.Opportunity__r.AccountId).add(card);
                        this.sobjectsToDeleteMap.get(card.Opportunity__r.AccountId).add(card);
                    }

                    // 7. Attachments
                    List<Attachment> attachmentsList = [
                            SELECT Id, Name, CreatedDate, ParentId
                            FROM Attachment
                            WHERE ParentId IN :oppIdToAccountIdMap.keySet()
                    ];
                    for (Attachment attach : attachmentsList) {
                        this.accountToAttachmentsMap.get(oppIdToAccountIdMap.get(attach.ParentId)).add(attach);
                        this.sobjectsToDeleteMap.get(oppIdToAccountIdMap.get(attach.ParentId)).add(attach);
                    }

                    // 8. OpportunityLineItem
                    Map<String, List<Offer_Item__c>> productToOfferItem = new Map<String, List<Offer_Item__c>>();
                    List<OpportunityLineItem> oppLineItemList = [
                            SELECT Id, Product2.Name, OpportunityId, CreatedDate
                            FROM OpportunityLineItem
                            WHERE OpportunityId IN :oppIdToAccountIdMap.keySet()
                    ];
                    Set<String> oppLineItemId = new Set<String>();
                    for (OpportunityLineItem lineItem : oppLineItemList) {
                        productToOfferItem.put(lineItem.Id, new List<Offer_Item__c>());
                        this.accountToOppLineItem.get(oppIdToAccountIdMap.get(lineItem.OpportunityId)).add(lineItem);
                        this.sobjectsToDeleteMap.get(oppIdToAccountIdMap.get(lineItem.OpportunityId)).add(lineItem);
                        oppLineItemId.add(lineItem.Id);
                    }

                    // 9. Offer_Item__c
                    List<Offer_Item__c> offerItemList = [
                            SELECT Id, Opportunity_Product_Id__c, Name, CreatedDate, Driver_Name__c, Category_of_products__c, Type_of_Card__c
                            FROM Offer_Item__c
                            WHERE Opportunity_Product_Id__c IN :oppLineItemId];
                    for (Offer_Item__c item : offerItemList) {
                        productToOfferItem.get(item.Opportunity_Product_Id__c).add(item);
                    }
                    for (OpportunityLineItem lineItem : oppLineItemList) {
                        for (Offer_Item__c item : productToOfferItem.get(lineItem.Id)) {
                            this.accountToOfferItem.get(oppIdToAccountIdMap.get(lineItem.OpportunityId)).add(item);
                            this.sobjectsToDeleteMap.get(oppIdToAccountIdMap.get(lineItem.OpportunityId)).add(item);
                        }
                    }

                    // 10. E2E_Data_Object__c
                    List<E2E_Data_Object__c> dataObjectList = [
                            SELECT Id, Name, CreatedDate
                            FROM E2E_Data_Object__c
                            WHERE Id IN :e2eDataObjectIdToAccountId.keySet()
                    ];
                    Set<String> dataObjectIdsSet = new Set<String>();
                    for (E2E_Data_Object__c e2eDataObject : dataObjectList) {
                        dataObjectIdsSet.add(e2eDataObject.Id);
                        this.accountToDataObject.get(e2eDataObjectIdToAccountId.get(e2eDataObject.Id)).add(e2eDataObject);
                        this.sobjectsToDeleteMap.get(e2eDataObjectIdToAccountId.get(e2eDataObject.Id)).add(e2eDataObject);
                    }

                    // 11. E2E_Data_Log__c
                    List<E2E_Data_Log__c> dataLogList = [
                            SELECT Name, Job_Status__c, E2E_Data_Object__c, CreatedDate
                            FROM E2E_Data_Log__c
                            WHERE E2E_Data_Object__c IN :dataObjectIdsSet
                    ];
                    for (E2E_Data_Log__c dataLog : dataLogList) {
                        this.accountToDataLog.get(e2eDataObjectIdToAccountId.get(dataLog.E2E_Data_Object__c)).add(dataLog);
                        this.sobjectsToDeleteMap.get(e2eDataObjectIdToAccountId.get(dataLog.E2E_Data_Object__c)).add(dataLog);
                    }

                    // 12. E2E_Data_Offer_Item__c
                    List<E2E_Data_Offer_Item__c> dataOfferItemList = [
                            SELECT Offer_Name__c, E2E_Data_Object__c, CreatedDate
                            FROM E2E_Data_Offer_Item__c
                            WHERE E2E_Data_Object__c IN :dataObjectIdsSet
                    ];
                    for (E2E_Data_Offer_Item__c dataOfferItem : dataOfferItemList) {
                        this.accountToDataOfferItem.get(e2eDataObjectIdToAccountId.get(dataOfferItem.E2E_Data_Object__c)).add(dataOfferItem);
                        this.sobjectsToDeleteMap.get(e2eDataObjectIdToAccountId.get(dataOfferItem.E2E_Data_Object__c)).add(dataOfferItem);
                    }

                    // 13. E2E_Data_Additional_Service__c
                    List<E2E_Data_Additional_Service__c> dataAdditionalServiceList = [
                            SELECT Name, E2E_Data_Object__c, Selected__c, CreatedDate
                            FROM E2E_Data_Additional_Service__c
                            WHERE E2E_Data_Object__c IN :dataObjectIdsSet
                    ];
                    for (E2E_Data_Additional_Service__c dataAdditionalService : dataAdditionalServiceList) {
                        this.accountToDataAdditionalService.get(e2eDataObjectIdToAccountId.get(dataAdditionalService.E2E_Data_Object__c)).add(dataAdditionalService);
                        this.sobjectsToDeleteMap.get(e2eDataObjectIdToAccountId.get(dataAdditionalService.E2E_Data_Object__c)).add(dataAdditionalService);
                    }

                    // 14. Docusign Status
                    List<dsfs__DocuSign_Status__c> docusignList = [
                            SELECT Name, Document_name__c, dsfs__Envelope_Status__c, dsfs__Opportunity__c, CreatedDate
                            FROM dsfs__DocuSign_Status__c
                            WHERE dsfs__Opportunity__c IN :oppIdToAccountIdMap.keySet()
                    ];
                    for (dsfs__DocuSign_Status__c docusignStatus : docusignList) {
                        this.accountToDocusignStatus.get(oppIdToAccountIdMap.get(docusignStatus.dsfs__Opportunity__c)).add(docusignStatus);
                        this.sobjectsToDeleteMap.get(oppIdToAccountIdMap.get(docusignStatus.dsfs__Opportunity__c)).add(docusignStatus);
                    }

                    // 15 Files
                    Set<String> oppIds = oppIdToAccountIdMap.keySet();
                    List<ContentDocumentLink> cdlList = [
                            SELECT ContentDocument.Title, LinkedEntityId, ContentDocument.CreatedDate, ContentDocument.Id
                            FROM ContentDocumentLink
                            WHERE LinkedEntityId IN :oppIds
                    ];
                    Map<String, String> contentDocumentToLinkMap = new Map<String, String>();
                    for (ContentDocumentLink cdl : cdlList) {
                        this.accountToContentDoc.get(oppIdToAccountIdMap.get(cdl.LinkedEntityId)).add(cdl);
                        contentDocumentToLinkMap.put(cdl.ContentDocument.Id, cdl.LinkedEntityId);
                    }
                    List<ContentDocument> contentDocumentList = [
                            SELECT Id
                            FROM ContentDocument
                            WHERE Id IN :contentDocumentToLinkMap.keySet()
                    ];
                    for (ContentDocument contentDoc : contentDocumentList) {
                        this.sobjectsToDeleteMap.get(oppIdToAccountIdMap.get(contentDocumentToLinkMap.get(contentDoc.Id))).add(contentDoc);
                    }

                    // Calculating number of objects
                    for (String accId : this.accountsMap.keySet()) {
                        this.sobjectsToDeleteMap.get(accId).add(this.accountsMap.get(accId));
                        this.numberOfObjectsFoundMap.get(accId).put('Opportunities', this.accountToOpportunitiesMap.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('Contacts', this.accountToContactsMap.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('OpportunityContactRoles', this.accountToOppContactRolesMap.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('HealthChecks', this.accountToHealthChecksMap.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('PaymentTransactions', this.accountToPaymentTransactionsMap.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('CFreports', this.accountToCFreportsMap.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('Cards', this.accountToCardsMap.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('Attachments', this.accountToAttachmentsMap.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('Products', this.accountToOppLineItem.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('ProductItems', this.accountToOfferItem.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('DataObject', this.accountToDataObject.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('DataLog', this.accountToDataLog.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('DataOfferItem', this.accountToDataOfferItem.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('DataAdditionalService', this.accountToDataAdditionalService.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('DocusignStatus', this.accountToDocusignStatus.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('Files', this.accountToContentDoc.get(accId).size());
                        this.numberOfObjectsFoundMap.get(accId).put('Quotes', this.accountToQuote.get(accId).size());
                    }
                }
            } else {
                throw new LongFormException('You don\'t have access. Please contact your administrator.');
            }
        } catch (Exception e) {
            this.errorMessage = e.getMessage();
            if (this.errorMessage == 'No search results' ||
                this.errorMessage == 'You don\'t have access. Please contact your administrator.') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, this.errorMessage));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, this.errorMessage + ' (Cls: ' + e.getStackTraceString() + ')'));
            }
        }
    }

    public void deleteRecords() {
        try {
            String accid = ApexPages.CurrentPage().getparameters().get('accid');
            if (this.sobjectsToDeleteMap.containsKey(accid)) {
                OpportunityTriggerHandler.enablesTrigger = false;
                for (Opportunity opp : this.accountToOpportunitiesMap.get(accid)) {
                    opp.Name = 'TO DELETE';
                    opp.StageName = 'Prospecting';
                }
                update this.accountToOpportunitiesMap.get(accid);

                List<SObject> sobjectToDeleteList = new List<SObject>();
                List<SObject> secondSobjectToDeleteList = new List<SObject>(); //Created second list to resolve the
                Integer count = 0;
                for (SObject obj : this.sobjectsToDeleteMap.get(accid)) {
                    if (count < 10) {
                        sobjectToDeleteList.add(obj);
                    } else {
                        secondSobjectToDeleteList.add(obj);
                    }
                    count = count + 1;
                }
                AccountTriggerHandler.enablesTrigger = false;
                delete sobjectToDeleteList;
                delete secondSobjectToDeleteList;
                this.sobjectsToDeleteMap = null;
                doSearch();
            }
        } catch (Exception e) {
            this.errorMessage = e.getMessage() + ' (Cls: ' + e.getStackTraceString() + ')';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, this.errorMessage));
        }
    }
}