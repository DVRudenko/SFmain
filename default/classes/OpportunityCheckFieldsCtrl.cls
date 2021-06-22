public with sharing class OpportunityCheckFieldsCtrl {
    public Opportunity currentOpportunity { get; set; }
    public String opportunityId;
    public String opportunityPageTitle { get; private set; }
    public List<Opportunity> listOpportunities { get; set; }
    public String base64Value { get; set; }
    public Boolean isOpportunitySaved { get; set; }

    public OpportunityCheckFieldsCtrl(ApexPages.StandardController controller) {
        this.currentOpportunity = new Opportunity();
        this.listOpportunities = new List<Opportunity>();
        this.isOpportunitySaved = true;
    }

    /***************************************************************************************************
	*  Name            : init()
	*  Summary         : initializes Visualforce page for the controller
	*  CreatedDate     : 16/01/2018
	*  Parameters      : -
	*  Returns         : void
	****************************************************************************************************/
    public void init() {
        this.opportunityPageTitle = 'Проверка заполнености полей перед стартом';
        this.opportunityId = ApexPages.CurrentPage().getParameters().get('Id');
        this.listOpportunities = [
                SELECT Id, Name, StageName, Account.Name, Industry__c, Primary_Fueling_Method__c, Primary_Fueling_Method_specific__c,
                        Additional_Fueling_Methods__c, Fleet_Type__c, Number_of_Vehicles__c, Projected_Liters_weekly__c,
                        Area_Traveled__c, The_region__c, Description, PPR_Electronic_document_management__c,
                        PPR_EDM_No__c, PPR_Operator__c, Traffic_tickets_monitoring_service__c, Paid_personal_manager__c,
                        UPD__c, Extra_terms__c, High_season__c, High_season_months__c, Product_PPR__c,
                        General_Projected_Liters_w__c, Percentage_of_General_projected_liters__c, INN_Opp__c
                FROM Opportunity
                WHERE Id = :this.opportunityId
        ];
        if (this.opportunityId != null && !(this.listOpportunities.isEmpty())) {
            this.currentOpportunity = listOpportunities.get(0);
            if (currentOpportunity.Industry__c != null && 
                currentOpportunity.Fleet_Type__c != null && 
                currentOpportunity.Number_of_Vehicles__c != null && 
                currentOpportunity.Area_Traveled__c != null && 
                currentOpportunity.The_region__c != null && 
                currentOpportunity.Projected_Liters_weekly__c != null && 
                currentOpportunity.General_Projected_Liters_w__c != null && 
                currentOpportunity.Primary_Fueling_Method__c != null && 
                currentOpportunity.Primary_Fueling_Method_specific__c != null && 
                ((currentOpportunity.PPR_Electronic_document_management__c == 'НЕТ' && currentOpportunity.PPR_EDM_No__c != null) ||
                (currentOpportunity.PPR_Electronic_document_management__c == 'ДА' && currentOpportunity.PPR_Operator__c != null)) &&
                currentOpportunity.Traffic_tickets_monitoring_service__c != null && 
                currentOpportunity.UPD__c != null && 
                ((currentOpportunity.High_season__c == 'ДА' && currentOpportunity.High_season_months__c != null) ||
                currentOpportunity.High_season__c == 'НЕТ') &&
                currentOpportunity.Product_PPR__c != null) {
                this.isOpportunitySaved = false;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Некорректный Opportunity ID! Обратитесь к Администратору!'));
        }
    }

    /***************************************************************************************************
	*  Name            : save()
	*  Summary         : checks and saves Opportunity record if all required fields are filled in with data
	*  CreatedDate     : 16/01/2018
	*  Parameters      : -
	*  Returns         : PageReference
	*****************************************************************************************************/
    public PageReference save() {
        try {
            update currentOpportunity;
            this.isOpportunitySaved = false;
            Blob beforeBlob = constructBlob();
            base64value = EncodingUtil.base64Encode(beforeBlob);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Пожалуйста, обратитесь к администратору!\n' + e.getMessage()));
        }
        return null;
    }

    /***************************************************************************************************
	*  Name            : back()
	*  Summary         : redirects to an Opportunity main page
	*  CreatedDate     : 16/01/2018
	*  Parameters      : -
	*  Returns         : PageReference
	*****************************************************************************************************/
    public PageReference back() {
        this.opportunityId = ApexPages.CurrentPage().getParameters().get('Id');
        return new PageReference('/' + this.opportunityId);
    }

    /***************************************************************************************************
	*  Name            : constructBlob()
	*  Summary         : constructs Blob in the form of a HTML table
	*  CreatedDate     : 21/03/2018
	*  Parameters      : -
	*  Returns         : Blob
	*****************************************************************************************************/
    private Blob constructBlob() {
        String header = '<html><head><meta charset=\"utf-8\"></head><body> \n' +
                '<table class="table"> <thead> <tr>' +
                '<th>Имя организации</th> ' +
                '<th>ИНН</th> ' +
                '<th>ID возможности</th> ' +
                '<th>Вид деятельности</th> ' +
                '<th>Тип автопарка</th> ' +
                '<th>Кол-во автотранспорта</th> ' +
                '<th>География поездок</th>' +
                '<th>География поездок (детали)</th> ' +
                '<th>Прогнозные литры в месяц</th> ' +
                '<th>Общая прокачка</th> ' +
                '<th>Процент от общей прокачки</th>' +
                '<th>Способ приобретения топлива</th> ' +
                '<th>Способ приобретения топлива (детали)</th> ' +
                '<th>Дополнительные способы заправки</th>' +
                '<th>ЭДО</th> ' +
                '<th>ЭДО - НЕТ</th> ' +
                '<th>Оператор ЭДО</th> ' +
                '<th>Платный персональный менеджер</th>' +
                '<th>Услуга мониторинга штрафов</th> ' +
                '<th>УПД</th> ' +
                '<th>Высокий сезон</th> ' +
                '<th>Высокий сезон: выбор</th> ' +
                '<th>Дополнительные договоренности с клиентом</th> ' +
                '<th>Продукт</th> ' +
                '</tr> </thead>';
        String finalString = header;
        finalString += '<tbody> <tr> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).Account.Name) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).INN_Opp__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).Id) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Opportunity.Industry__c.getDescribe(), listOpportunities.get(0).Industry__c)) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).Fleet_Type__c) + '</td> ' +
                '<td>' + GlobalUtils.blankDecimalIfNull(listOpportunities.get(0).Number_of_Vehicles__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Opportunity.Area_Traveled__c.getDescribe(), listOpportunities.get(0).Area_Traveled__c)) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).The_region__c) + '</td> ' +
                '<td>' + GlobalUtils.blankDecimalIfNull(listOpportunities.get(0).Projected_Liters_weekly__c) + '</td>' +
                '<td>' + GlobalUtils.blankDecimalIfNull(listOpportunities.get(0).General_Projected_Liters_w__c) + '</td> ' +
                '<td>' + GlobalUtils.blankDecimalIfNull(listOpportunities.get(0).Percentage_of_General_projected_liters__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Opportunity.Primary_Fueling_Method__c.getDescribe(), listOpportunities.get(0).Primary_Fueling_Method__c)) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Opportunity.Primary_Fueling_Method_specific__c.getDescribe(), listOpportunities.get(0).Primary_Fueling_Method_specific__c)) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Opportunity.Additional_Fueling_Methods__c.getDescribe(), listOpportunities.get(0).Additional_Fueling_Methods__c)) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).PPR_Electronic_document_management__c) + '</td>  ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).PPR_EDM_No__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).PPR_Operator__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).Paid_personal_manager__c + '</td> ') +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).Traffic_tickets_monitoring_service__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).UPD__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).High_season__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).High_season_months__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).Extra_terms__c) + '</td> ' +
                '<td>' + GlobalUtils.blankStringIfNull(listOpportunities.get(0).Product_PPR__c) + '</td> ' +
                '</tr> </tbody> </table>';
        finalString += '</body></html>';
        return Blob.valueOf(finalString);
    }
}