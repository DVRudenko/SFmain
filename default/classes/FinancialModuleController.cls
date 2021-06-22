public class FinancialModuleController {
    public ApexPages.StandardController controller {get; set;}
    public String financialModuleId {get; set;}
    public List<Financial_Detail__c> financialDetailsList {get; set;}
    public String financialModuleName {get; set;}
    public String pageMode {get; set;}
    public List<Financial_Detail__c> detailsToDeleteList {get; set;}
    public FinancialModuleController(ApexPages.StandardController controller) {
        this.controller = controller;
        this.financialModuleId = ApexPages.currentPage().getParameters().get('Id');
        setDataForDisplaying();
        setViewMode();
        this.detailsToDeleteList = new List<Financial_Detail__c>();
    }


    /*******************************************************************************
    *  Name            : setDataForDisplaying()
    *  Summary         : select and sort data to show on VF page    
    *  CreatedDate     : 12/09/2017
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDataForDisplaying() {
        List<Financial_Module__c> financialModulesList = [
                SELECT Name, 
                        (SELECT Year__c, Type__c, Total_Assets__c, Total_Fixed_Assets__c, Intangible_Fixed_Assets__c, 
                            Tangible_Fixed_Assets__c, Financial_LT_Assets__c, Other_Fixed_assets__c, Total_Current_Assets__c, Stock_material_work__c, 
                            Trade_debtors__c, Cash_Cash_equivalent__c,  Others_Current_Assets__c, Total_Liabilities__c, 
                            Net_worth__c, Reserves__c, Liabilities__c, LongTerm_Liabilities__c, From_that_LT_bank_debt__c, Leasing_Engagement__c,
                            ShortTerm_Liabilities__c, From_that_Trade_Creditors__c, From_that_ST_bank_debt__c,
                            Total_Turnover__c, Turnover__c, Activation__c, Other_operational_income__c, Cost_of_goods_sold__c, Gross_profit_loss__c,
                            Depreciation__c, Income_and_other_taxes__c, EBIT_from_Crefo__c, Operational_profit_EBIT__c, EBITDA__c, Calculated_CF__c, 
                            Financial_Income__c, Financial_Charges__c, Net_Interest_expense__c, EAT__c, Extraordinary_Items__c, Exceptional_Income__c,
                            Exceptional_Charges__c, Exceptional_Items_Total__c, Profit_Margin__c, 
                            ROA_calculation_includes_taxes_x_D_B__c, ROE_without_Reserves__c, Profitability__c,
                            Solvency_ratio__c, Leverage__c, Debt_to_EBITDA__c, EBITDA_coverage__c, Current_ratio__c, 
                            Quick_acid_ratio__c, Working_capital__c, Cash_flow_ratio__c, DSO_in_days__c, DPO_in_days__c,
                            Overall_score__c, From_that_other_LT_liabilities__c, From_that_other_ST_liabilities__c
                        FROM Financial_Details__r
                        ORDER BY Year__c DESC)
                FROM Financial_Module__c
                WHERE Id = :this.financialModuleId
                ORDER BY CreatedDate DESC
                LIMIT 1];
        if (! financialModulesList.isEmpty()) {
            financialModuleName = financialModulesList.get(0).Name;
            Set<String> yearsSet = new Set<String>();
            Map<String, Financial_Detail__c> annualDetailsMap = new Map<String, Financial_Detail__c>();
            Map<String, Financial_Detail__c> scoreDetailsMap = new Map<String, Financial_Detail__c>();
            for (Financial_Detail__c detail : financialModulesList.get(0).Financial_Details__r) {
                yearsSet.add(detail.Year__c);
                if (detail.Type__c == 'Annual') {
                    annualDetailsMap.put(detail.Year__c, detail);
                } else if (detail.Type__c == 'Score') {
                    scoreDetailsMap.put(detail.Year__c, detail);
                }
            }

            this.financialDetailsList = new List<Financial_Detail__c>();
            for (String year : yearsSet) {
                if (annualDetailsMap.containsKey(year)) {
                    this.financialDetailsList.add(annualDetailsMap.get(year));
                }

                if (scoreDetailsMap.containsKey(year)) {
                    this.financialDetailsList.add(scoreDetailsMap.get(year));
                }
            }
        }
    }
    

    /*******************************************************************************
    *  Name            : setEditMode()
    *  Summary         : Give ability to user to edit Financial Module.
    *  CreatedDate     : 30/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setEditMode() {
        this.pageMode = 'Edit';
    }


    /*******************************************************************************
    *  Name            : setViewMode()
    *  Summary         : Remove ability to user to edit Financial Module.    
    *  CreatedDate     : 30/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setViewMode() {
        this.pageMode = 'View';
    }


    /*******************************************************************************
    *  Name            : updateModule()
    *  Summary         : Update finance module's details
    *  CreatedDate     : 05/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateModule() {
        if (! validate()) {
            return;
        }
        
        this.financialDetailsList = FinancialModuleCalculator.calculateFinancialDetails(this.financialDetailsList, this.financialModuleId);
        if (! this.detailsToDeleteList.isEmpty()) {
            delete this.detailsToDeleteList;
        }
        setDataForDisplaying();
        setViewMode();
        this.detailsToDeleteList = new List<Financial_Detail__c>();
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : Check for valid input data   
    *  CreatedDate     : 13/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String year - year of financial detail
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean validate() {
        List<String> detailsKeysList = new List<String>();
        Set<String> detailsKeysSet = new Set<String>();
        Set<String> yearsSet = new Set<String>();
        for (Financial_Detail__c detail : this.financialDetailsList) {
            detailsKeysList.add(detail.Year__c + detail.Type__c);
            detailsKeysSet.add(detail.Year__c + detail.Type__c);
            yearsSet.add(detail.Year__c);
        }

        if (detailsKeysList.size() > detailsKeysSet.size()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Duplicate year is found'));
            return false;
        }

        for (String year : yearsSet) {
            if (year.length() != 4) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid year is found'));
                return false;
            } 
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : deleteDetail()
    *  Summary         : Delete detail.    
    *  CreatedDate     : 05/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deleteDetail() {
        Integer detailToDelete = Integer.valueOf(System.currentPageReference().getParameters().get('detailToDelete'));

        // remove current detail
        if (this.financialDetailsList.get(detailToDelete).Id != null) {
            detailsToDeleteList.add(this.financialDetailsList.get(detailToDelete));
        }

        this.financialDetailsList.remove(detailToDelete);

        // remove the next detail (score)
        if (this.financialDetailsList.get(detailToDelete).Id != null) {
            detailsToDeleteList.add(this.financialDetailsList.get(detailToDelete));
        }

        this.financialDetailsList.remove(detailToDelete);
    }


    /*******************************************************************************
    *  Name            : addDetail()
    *  Summary         : Create detail    
    *  CreatedDate     : 12/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void addDetail() {
        String newDetailYear;
        if (this.financialDetailsList.size() > 0) {
            newDetailYear = String.valueOf(Integer.valueOf(this.financialDetailsList.get(this.financialDetailsList.size() - 1).Year__c) - 1);
        } else {
            newDetailYear = String.valueOf(Date.today().year());
        }

        List<Financial_Detail__c> detailsToInsertList = new List<Financial_Detail__c>{
            new Financial_Detail__c(
                Type__c = 'Annual',
                Year__c = newDetailYear,
                Financial_module__c = this.financialModuleId),
            new Financial_Detail__c(
                Type__c = 'Score',
                Year__c = newDetailYear,
                Financial_module__c = this.financialModuleId)};
        this.financialDetailsList.addAll(detailsToInsertList);
    }


    /*******************************************************************************
    *  Name            : removeChanges()
    *  Summary         : Reload page again without update.  
    *  CreatedDate     : 13/09/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void removeChanges() {
        setDataForDisplaying();
        setViewMode();
    }


    public Map<Integer, String> ratingsMap {
        get {
            ratingsMap = new Map<Integer, String>{
                1 => 'Very Low',
                2 => 'Low',
                3 => 'Medium',
                4 => 'High',
                5 => 'Very High',
                6 => 'Extremely high'
            };

            return ratingsMap;
        }

        set;
    }


    /*******************************************************************************
    *  Name            : saveAsCSV()
    *  Summary         : Save data as SCV    
    *  CreatedDate     : 14/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference saveAsCSV() {
        PageReference reference = new PageReference('/apex/FinancialModuleCSV?id=' + this.financialModuleId);
        reference.setRedirect(true); 
        return reference;
    }


    public class DetailsToDisplay {
        public String intangibleFixedAssets {get; set;}
    }
}