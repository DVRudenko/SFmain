public class DeduplicationService {
    private E2EFormRuDao e2eFormRuDao;
    private static final Map<GlobalUtils.OpportunityStage, String> STAGES_TO_TRANSLATE = GlobalUtils.opportunityStagesMap;
    private static final Map<String, Integer> STAGE_NAMES_TO_DAYS = new Map<String, Integer>{
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.ContractChecking) => 5,
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.ContractUnderSigning) => 14,
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.ContractSigning) => 14,
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.AwaitingPayment) => 6
    };

    private static final List<String> STAGES_IN_PROGRESS = new List<String>{
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.Qualified_Lead),
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.Client_Negotiations),
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.Check_Credit_History),
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.AgreementTermsAndConditions),
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.ContractChecking),
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.ContractUnderSigning),
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.ContractSigning),
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.AwaitingPayment),
        STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.Suspended_Opportunity)
    };
    private static final String STAGE_TO_START = STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.MovedToStart);
    private static final String STAGE_DECLINE = STAGES_TO_TRANSLATE.get(GlobalUtils.OpportunityStage.Refused);
    private static final String SOURCE_EMAIL = 'Email';
    private static final String SOURCE_DOMAIN = 'Domain';

    public DeduplicationService() {
        this.e2eFormRuDao = new E2EFormRuDaoImpl();
    }

    /*******************************************************************************
    *  Name            : deduplicateAccounts((String INN, String email, Id AccountId, Id ContactId, Id OpportunityId)
    *  Summary         : Setup initial data for deduplication
    *  CreatedDate     : 17/03/2021
    *  ModifiedDate    : -
    *  Parameters      :String INN, String email, Id AccountId, Id ContactId, Id OpportunityId
    *  Returns         : E2EFormRuDeduplicationResult
    ******************************************************************************/
    public E2EFormRuDeduplicationResult deduplicateAccounts(String INN, String email, Id AccountId, Id ContactId, Id OpportunityId) {
        DeduplicationData deduplicationData = new DeduplicationData();
        deduplicationData.excludedAccounts.add(this.e2eFormRuDao.getAccountById(AccountId));
        deduplicationData.excludedContacts.add(this.e2eFormRuDao.getContactByContactId(ContactId));
        deduplicationData.opportunity = this.e2eFormRuDao.getOpportunityById(OpportunityId);
        deduplicationData.INN = INN;
        deduplicationData.Email = email;
        return deduplicateAccounts(deduplicationData);
    }

    /*******************************************************************************
    *  Name            : deduplicateAccounts(deduplicationData)
    *  Summary         : Main deduplication procces method
    *  CreatedDate     : 17/03/2021
    *  ModifiedDate    : -
    *  Parameters      : String INN, String email, Id e2eAccountId, Id e2eContactId, Id e2eOpportunityId
    *  Returns         : E2EFormRuDeduplicationResult
    ******************************************************************************/
    public E2EFormRuDeduplicationResult deduplicateAccounts(DeduplicationData deduplicationData) {
        E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
        deduplicationResult.deduplicationDatetime = Datetime.now();

        List<Account> duplicateAllAccounts = this.e2eFormRuDao.getAccountsByINN(deduplicationData.INN);
        List<Account> duplicateAccountsByINN = DeduplicationServiceHelper.exculeObjectsFromList(
            duplicateAllAccounts,
            deduplicationData.excludedAccounts
        );
        List<Account> duplicatedAccountsByAllSources = new List<Account>();

        List<Object> duplicatedContactsAndSource = findDuplicatedContactsAndSource(deduplicationData);
        List<Contact> duplicateContactsList = (List<Contact>) duplicatedContactsAndSource[1];
        String duplicationSource = (String) duplicatedContactsAndSource[0];

        if (duplicateAccountsByINN.isEmpty()) {
            deduplicationResult.innDuplication = false;
        } else if (duplicateAccountsByINN.size() == 1) {
            deduplicationResult.innDuplication = true;
            duplicatedAccountsByAllSources.add(duplicateAccountsByINN[0]);
        }

        if (!duplicateContactsList.isEmpty()) {
            if (!deduplicationResult.innDuplication) {
                deduplicationResult.isEmailDuplicated = (duplicationSource == SOURCE_EMAIL);
                deduplicationResult.isDomainDuplicated = (duplicationSource == SOURCE_DOMAIN);
            }
            List<Account> accountsByEmail = findAccountsWithDuplicatedContacts(duplicateContactsList);
            duplicatedAccountsByAllSources.addAll(accountsByEmail);
            deduplicationResult.sfAccount = duplicatedAccountsByAllSources.get(0);
            for (Account account : duplicatedAccountsByAllSources) {
                Boolean transferToService = checkingTransferToService(account);
                if (transferToService) {
                    if (!deduplicationResult.innDuplication) {
                        deduplicationResult.sfAccount = account;
                    }
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
                    return deduplicationResult;
                }
            }
            checkingOpportunityTransfer(deduplicationResult, deduplicationData);
            return deduplicationResult;
        } else {
            if (deduplicationResult.innDuplication) {
                deduplicationResult.sfAccount = duplicatedAccountsByAllSources[0];
                deduplicationSingleAccount(deduplicationResult, deduplicationData);
                return deduplicationResult;
            }
            return deduplicationResult;
        }
    }

    /*******************************************************************************
    *  Name            : checkingTransferToService(Account account)
    *  Summary         : Check if transfer to Service
    *  CreatedDate     : 17/03/2021
    *  ModifiedDate    : -
    *  Parameters      : Account account
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean checkingTransferToService(Account account) {
        Date nowDate = Date.Today();
        if (account.Last_pump_date__c >= nowDate.addYears(-1)) {
            return true;
        } else if (account.Opportunities != null && !account.Opportunities.isEmpty()) {
            for (Opportunity opportunity : account.Opportunities) {
                if (opportunity.StageName == STAGE_TO_START && opportunity.CloseDate >= nowDate.addMonths(-6)) {
                    return true;
                }
            }
        }
        return false;
    }

    /*******************************************************************************
     *  Name            : findDuplicatedContactsAndSource(DeduplicationData deduplicationData)
     *  Summary         : Find duplicate Contacts by email or domain.
     *  CreatedDate     : 17/03/2021
     *  ModifiedDate    : -
     *  Parameters      : DeduplicationData deduplicationData
     *  Returns         : List<Object>
     ******************************************************************************/
    private List<Object> findDuplicatedContactsAndSource(DeduplicationData deduplicationData) {
        List<Object> wrapperList = new List<Object>();
        String email = deduplicationData.Email;
        String domain = email.substringAfter('@');
        Set<String> setPublicDomains = PublicEmailDomains__c.getAll().keySet();
        List<Contact> duplicateContactList = new List<Contact>();
        String source;
        if (setPublicDomains.contains(domain)) {
            duplicateContactList = this.e2eFormRuDao.getContactsByEmail(email);
            duplicateContactList = DeduplicationServiceHelper.matchAdditionalEmails(duplicateContactList, email);
            source = SOURCE_EMAIL;
        } else {
            duplicateContactList = this.e2eFormRuDao.getContactsByDomain(domain);
            source = SOURCE_DOMAIN;
        }

        duplicateContactList = DeduplicationServiceHelper.exculeObjectsFromList(duplicateContactList, deduplicationData.excludedContacts);
        wrapperList.add(source);
        wrapperList.add(duplicateContactList);
        return wrapperList;
    }

    /*******************************************************************************
    *  Name            : deduplicationSingleAccountche(2EFormRuDeduplicationResult deduplicationResult, DeduplicationData deduplicationData)
    *  Summary         : Check One account deduplication status
    *  CreatedDate     : 17/03/2021
    *  ModifiedDate    : -
    *  Parameters      : 2EFormRuDeduplicationResult deduplicationResult, DeduplicationData deduplicationData
    *  Returns         : void
    ******************************************************************************/
    private void deduplicationSingleAccount(E2EFormRuDeduplicationResult deduplicationResult, DeduplicationData deduplicationData) {
        if (checkingTransferToService(deduplicationResult.sfAccount)) {
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
        } else {
            checkingOpportunityTransfer(deduplicationResult, deduplicationData);
        }
    }

    /*******************************************************************************
    *  Name            : findAccountsWithDuplicatedContacts (List<Contact> duplicateContactList)
    *  Summary         : Find all parent Accounts for duplicated contacts
    *  CreatedDate     : 17/03/2021
    *  ModifiedDate    : -
    *  Parameters      : List<Contact> duplicateContactList
    *  Returns         : List<Account>
    ******************************************************************************/
    private List<Account> findAccountsWithDuplicatedContacts(List<Contact> duplicateContactList) {
        Set<Id> accountsIds = new Set<Id>();
        for (Contact contact : duplicateContactList) {
            accountsIds.add(contact.AccountId);
        }
        List<Account> accountsByEmail = this.e2eFormRuDao.getAccountsByIds(accountsIds).values();
        return accountsByEmail;
    }

    /*******************************************************************************
    *  Name            : checkingOpportunityTransfer (E2EFormRuDeduplicationResult deduplicationResult, DeduplicationData deduplicationData)
    *  Summary         : Find deduplication status by opportunities
    *  CreatedDate     : 17/03/2021
    *  ModifiedDate    : -
    *  Parameters      : E2EFormRuDeduplicationResult deduplicationResult, DeduplicationData deduplicationData
    *  Returns         : Void
    ******************************************************************************/
    private void checkingOpportunityTransfer(E2EFormRuDeduplicationResult deduplicationResult, DeduplicationData deduplicationData) {
        List<Opportunity> opportunities = deduplicationResult.sfAccount.Opportunities;
        opportunities = DeduplicationServiceHelper.exculeObjectsFromList(opportunities, deduplicationData.excludedOpportunities);

        if (!opportunities.isEmpty() && deduplicationData.Opportunity != null) {
            deduplicationResult.isDifferentOwnerFoundForOpportunities = DeduplicationServiceHelper.checkingOwnerForOpportunities(
                opportunities,
                deduplicationData.Opportunity
            );
        }

        if (opportunities.size() == 2) {
            List<Opportunity> notInProggessOpportunities = new List<Opportunity>();
            List<Opportunity> inProgressOpportunities = new List<Opportunity>();
            List<String> declinedStages = new List<String>{ STAGE_TO_START, STAGE_DECLINE };
            for (Opportunity opportunity : opportunities) {
                if (STAGES_IN_PROGRESS.contains(opportunity.StageName)) {
                    inProgressOpportunities.add(opportunity);
                } else {
                    notInProggessOpportunities.add(opportunity);
                }
            }

            if (inProgressOpportunities.size() == 2) {
                deduplicationResult.sfOpportunity = inProgressOpportunities[0];
            } else if (inProgressOpportunities.size() == 1 && !declinedStages.contains(notInProggessOpportunities[0].StageName)) {
                deduplicationResult.sfOpportunity = inProgressOpportunities[0];
                inProgressOpportunities.remove(0);
            }
            opportunities = inProgressOpportunities;
        } else if (opportunities.size() > 2) {
            List<Opportunity> openOpportunities = new List<Opportunity>();
            for (Opportunity opportunity : opportunities) {
                if (!opportunity.IsClosed) {
                    openOpportunities.add(opportunity);
                }
            }
            opportunities = openOpportunities;
        }

        if (opportunities.size() == 1) {
            deduplicationResult.sfOpportunity = opportunities[0];
            if (!checkOpportunityGoToKO(opportunities[0])) {
                opportunities.remove(0);
            }
        }
        deduplicationResult.statusCode = getStatusCode(opportunities);
    }

    /*******************************************************************************
    *  Name            : getStatusCode(List<Opportunity> opportunities)
    *  Summary         : check opportunities length under which set deduplication status
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : 17/03/2021
    *  Parameters      : List<Opportunity> opportunities
    *  Returns         : String
    ******************************************************************************/
    private String getStatusCode(List<Opportunity> opportunities) {
        if (opportunities.isEmpty()) {
            return GlobalUtils.DeduplicationStatus.E2EProcess.name();
        } else if (opportunities.size() == 1) {
            return GlobalUtils.DeduplicationStatus.KO.name();
        } else {
            return GlobalUtils.DeduplicationStatus.Inbound.name();
        }
    }

    /*******************************************************************************
    *  Name            : checkOpportunityGoToKO(Opportunity opportunity)
    *  Summary         : check opportunity stage under which opportunity must transferred to KO
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : 17/03/2021
    *  Parameters      : Opportunity opportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean checkOpportunityGoToKO(Opportunity opportunity) {
        String opportunityStage = opportunity.StageName;
        List<OpportunityHistory> historyList = this.e2eFormRuDao.getLastModifiedStageByOpportunityId(opportunity.Id);
        if (!historyList.isEmpty() || Test.isRunningTest()) {
            Date lastModifiedStageDate = Date.Today();
            if (Test.isRunningTest()) {
                lastModifiedStageDate = opportunity.CloseDate;
            } else {
                lastModifiedStageDate = historyList[0].CloseDate;
            }
            Integer daysBetween = Date.Today().daysBetween(lastModifiedStageDate);
            if (daysBetween < STAGE_NAMES_TO_DAYS.get(opportunityStage)) {
                return true;
            }
        }
        return false;
    }

    public class DeduplicationData {
        public List<Opportunity> excludedOpportunities = new List<Opportunity>();
        public List<Contact> excludedContacts = new List<Contact>();
        public List<Account> excludedAccounts = new List<Account>();
        public Opportunity opportunity { get; set; }
        public String INN { get; set; }
        public String Email { get; set; }
    }
}