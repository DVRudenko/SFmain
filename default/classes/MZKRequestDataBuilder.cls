public with sharing class MZKRequestDataBuilder {
    public static final String E2E_EXCEPTION = 'MZK Setting does not found';
    public static final String MZK_SETTING_NAME = 'E2EFormRu';
    public static final String PRODUCT_SETTING_NAME = 'mzkId';
    public static final String MZK_PRODUCT = 'product';
    private E2EFormRuDao e2eFormRuDao;

    public MZKRequestDataBuilder() {
        this.e2eFormRuDao = new E2EFormRuDaoImpl();
    }

    public MZKRequest buildForOrgReqv(Id opportunityId) {
        MZKRequest mzkRequest = new MZKRequest();
        if (opportunityId != null) {
            E2E_Form_MZK_Settings__c mzkSettings = E2E_Form_MZK_Settings__c.getValues(MZK_SETTING_NAME);
            Opportunity opportunity = this.e2eFormRuDao.getOpportunityById(opportunityId);
            Account account = this.e2eFormRuDao.getAccountById(opportunity.AccountId);
            Map<String, Object> productMapping = PPRProductSettingsUtils.getTariffMapping(opportunity.Product_PPR__c);
            Map<String, Object> organizationMapping = MZKRequestSettingUtils.getProductSettings();
            String product = '';
            if (productMapping != null) {
                product = String.valueOf(productMapping.get(MZK_PRODUCT));
            }

            if (mzkSettings != null) {
                mzkRequest.Cards = new MZKRequest.MzkCards();
                mzkRequest.Cards.sendType = mzkSettings.Send_Type__c.intValue();
                mzkRequest.Cards.transitId = opportunity.Transit_ID__c;
                mzkRequest.Cards.requestDescription = GlobalUtils.blankStringIfNull(account.Original_document_courier_info__c);
                mzkRequest.Cards.logUser = mzkSettings.Log_User__c;
                mzkRequest.Cards.isTemplate = 0;
                mzkRequest.Cards.eqv = Integer.valueOf(organizationMapping.get(opportunity.Our_organization__c));
                mzkRequest.Cards.serviceId = mzkSettings.Service_Ids__c;
                mzkRequest.Cards.limitVal = mzkSettings.Limit_Values__c;
                mzkRequest.Cards.limitTypeId = mzkSettings.Limit_Type_Ids__c;
                mzkRequest.Cards.isCommon = mzkSettings.Is_Common__c;
                mzkRequest.Cards.isRuble = mzkSettings.Is_Ruble__c;
                mzkRequest.Cards.totalLimitValue = null;
                mzkRequest.Cards.totalLimitType = null;
                mzkRequest.Cards.cardsNumber = Integer.valueOf(opportunity.ALL_Cards__c);
                mzkRequest.Cards.cardDescr = GlobalUtils.blankStringIfNull(account.Cards_delivery_courier_info__c);
                mzkRequest.Cards.serviceGroups = mzkSettings.Service_Groups__c;
                mzkRequest.Cards.productId = (Integer) PPRProductSettingsUtils.getProductSettings(product).get(PRODUCT_SETTING_NAME);
            } else {
                throw new E2EFormRuException(E2E_EXCEPTION);
            }
        }
        return mzkRequest;
    }
}