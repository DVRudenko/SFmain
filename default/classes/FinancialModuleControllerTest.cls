@isTest
private class FinancialModuleControllerTest {
	public static Account account;
	public static Financial_Module__c module;


	/*******************************************************************************
	*  Name            : testFinancialDataDisplaying()
	*  Summary         : Test select, add, delete, update and save as csv Financial details    
	*  CreatedDate     : 24/09/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testFinancialDataDisplaying() {
        createAccount();
        createFinancialModule();
        createFinancialDetails();
        ApexPages.currentPage().getParameters().put('Id', module.Id);
        FinancialModuleController controller = new FinancialModuleController(new ApexPages.StandardController(module));
        controller.updateModule();
        controller.addDetail();
        System.currentPageReference().getParameters().put('detailToDelete', '4');
        controller.deleteDetail();
        controller.removeChanges();
        controller.saveAsCSV();
        controller.ratingsMap.get(1);
        controller.ratingsMap.get(2);
        controller.ratingsMap.get(3);
        controller.ratingsMap.get(4);
        controller.ratingsMap.get(5);
        controller.ratingsMap.get(6);

        List<Financial_Module__c> financialModulesList = [
	        SELECT Name, 
	                (SELECT Year__c, Type__c, Total_Assets__c, Total_Fixed_Assets__c, Intangible_Fixed_Assets__c, 
	                    Tangible_Fixed_Assets__c, Financial_LT_Assets__c, Total_Current_Assets__c, Stock_material_work__c, 
	                    Trade_debtors__c, Cash_Cash_equivalent__c,  Others_Current_Assets__c, Total_Liabilities__c, 
	                    Net_worth__c, Reserves__c, Liabilities__c, LongTerm_Liabilities__c, From_that_LT_bank_debt__c, 
	                    From_that_other_LT_liabilities__c, ShortTerm_Liabilities__c, From_that_Trade_Creditors__c, 
	                    From_that_ST_bank_debt__c, From_that_other_ST_liabilities__c, Total_Turnover__c, Turnover__c, 
	                    Activation__c, Other_operational_income__c, Cost_of_goods_sold__c, Gross_profit_loss__c, Depreciation__c, 
	                    EBIT_from_Crefo__c, Income_and_other_taxes__c, Operational_profit_EBIT__c, EBITDA__c, Calculated_CF__c, 
	                    Financial_Income__c, Financial_Charges__c, Net_Interest_expense__c, EAT__c, Extraordinary_Items__c, 
	                    Exceptional_Income__c, Exceptional_Charges__c, Exceptional_Items_Total__c, Profit_Margin__c, 
	                    ROA_calculation_includes_taxes_x_D_B__c, ROE_without_Reserves__c, Profitability__c,
	                    Solvency_ratio__c, Leverage__c, Debt_to_EBITDA__c, EBITDA_coverage__c, Current_ratio__c, 
	                    Quick_acid_ratio__c, Working_capital__c, Cash_flow_ratio__c, DSO_in_days__c, DPO_in_days__c,
	                    Overall_score__c
	                FROM Financial_Details__r
	                ORDER BY Year__c DESC)
	        FROM Financial_Module__c
	        WHERE Id = :module.Id
	        ORDER BY CreatedDate DESC
	        LIMIT 1];

	    // 2 "annual" and 2 "change" details
	    System.assertEquals(4, financialModulesList.get(0).Financial_Details__r.size());

	    // 2018 annual
	    System.assertEquals(1400, financialModulesList.get(0).Financial_Details__r.get(1).Total_Assets__c);
	    System.assertEquals(600, financialModulesList.get(0).Financial_Details__r.get(1).Total_Fixed_Assets__c);
	    System.assertEquals(800, financialModulesList.get(0).Financial_Details__r.get(1).Total_Current_Assets__c);
	    System.assertEquals(1400, financialModulesList.get(0).Financial_Details__r.get(1).Total_Liabilities__c);
	    System.assertEquals(1000, financialModulesList.get(0).Financial_Details__r.get(1).Liabilities__c);
	    System.assertEquals(400, financialModulesList.get(0).Financial_Details__r.get(1).LongTerm_Liabilities__c);
	    System.assertEquals(600, financialModulesList.get(0).Financial_Details__r.get(1).ShortTerm_Liabilities__c);
	    System.assertEquals(600, financialModulesList.get(0).Financial_Details__r.get(1).Total_Turnover__c);
	    System.assertEquals(200, financialModulesList.get(0).Financial_Details__r.get(1).Operational_profit_EBIT__c);
	    System.assertEquals(400, financialModulesList.get(0).Financial_Details__r.get(1).EBITDA__c);
	    System.assertEquals(300, financialModulesList.get(0).Financial_Details__r.get(1).Calculated_CF__c);
	    System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Net_Interest_expense__c);
	    System.assertEquals(600, financialModulesList.get(0).Financial_Details__r.get(1).Exceptional_Items_Total__c);
	    System.assertEquals(0.33, financialModulesList.get(0).Financial_Details__r.get(1).Profit_Margin__c);
	    System.assertEquals(0.14, financialModulesList.get(0).Financial_Details__r.get(1).ROA_calculation_includes_taxes_x_D_B__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(1).ROE_without_Reserves__c);
	    System.assertEquals(-0.29, financialModulesList.get(0).Financial_Details__r.get(1).Profitability__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(1).Solvency_ratio__c);
	    System.assertEquals(0.86, financialModulesList.get(0).Financial_Details__r.get(1).Leverage__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(1).Debt_to_EBITDA__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).EBITDA_coverage__c);
	    System.assertEquals(1.33, financialModulesList.get(0).Financial_Details__r.get(1).Current_ratio__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(1).Quick_acid_ratio__c);
	    System.assertEquals(200, financialModulesList.get(0).Financial_Details__r.get(1).Working_capital__c);
	    System.assertEquals(0.5, financialModulesList.get(0).Financial_Details__r.get(1).Cash_flow_ratio__c);
	    System.assertEquals(120, financialModulesList.get(0).Financial_Details__r.get(1).DSO_in_days__c);
	    System.assertEquals(360, financialModulesList.get(0).Financial_Details__r.get(1).DPO_in_days__c);

	    // 2018 score
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Total_Assets__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Total_Fixed_Assets__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Intangible_Fixed_Assets__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Tangible_Fixed_Assets__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Financial_LT_Assets__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Total_Current_Assets__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Stock_material_work__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Trade_debtors__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Cash_Cash_equivalent__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Others_Current_Assets__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Total_Liabilities__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Net_worth__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Reserves__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Liabilities__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).LongTerm_Liabilities__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).From_that_LT_bank_debt__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).From_that_other_LT_liabilities__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).ShortTerm_Liabilities__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).From_that_Trade_Creditors__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).From_that_ST_bank_debt__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).From_that_other_ST_liabilities__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Total_Turnover__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Turnover__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Activation__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Other_operational_income__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Cost_of_goods_sold__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Gross_profit_loss__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Depreciation__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).EBIT_from_Crefo__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Income_and_other_taxes__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Operational_profit_EBIT__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).EBITDA__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Calculated_CF__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Financial_Income__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Financial_Charges__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Net_Interest_expense__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).EAT__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Extraordinary_Items__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Exceptional_Income__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Exceptional_Charges__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Exceptional_Items_Total__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Profit_Margin__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).ROA_calculation_includes_taxes_x_D_B__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).ROE_without_Reserves__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Profitability__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Solvency_ratio__c);
	    System.assertEquals(5, financialModulesList.get(0).Financial_Details__r.get(0).Leverage__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).Debt_to_EBITDA__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).EBITDA_coverage__c);
	    System.assertEquals(3, financialModulesList.get(0).Financial_Details__r.get(0).Current_ratio__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Quick_acid_ratio__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Working_capital__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(0).Cash_flow_ratio__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).DSO_in_days__c);
	    System.assertEquals(5, financialModulesList.get(0).Financial_Details__r.get(0).DPO_in_days__c);
	    System.assertEquals(3, financialModulesList.get(0).Financial_Details__r.get(0).Overall_score__c);

	    // 2017 annual
	    System.assertEquals(700, financialModulesList.get(0).Financial_Details__r.get(3).Total_Assets__c);
	    System.assertEquals(300, financialModulesList.get(0).Financial_Details__r.get(3).Total_Fixed_Assets__c);
	    System.assertEquals(400, financialModulesList.get(0).Financial_Details__r.get(3).Total_Current_Assets__c);
	    System.assertEquals(700, financialModulesList.get(0).Financial_Details__r.get(3).Total_Liabilities__c);
	    System.assertEquals(500, financialModulesList.get(0).Financial_Details__r.get(3).Liabilities__c);
	    System.assertEquals(200, financialModulesList.get(0).Financial_Details__r.get(3).LongTerm_Liabilities__c);
	    System.assertEquals(300, financialModulesList.get(0).Financial_Details__r.get(3).ShortTerm_Liabilities__c);
	    System.assertEquals(300, financialModulesList.get(0).Financial_Details__r.get(3).Total_Turnover__c);
	    System.assertEquals(100, financialModulesList.get(0).Financial_Details__r.get(3).Operational_profit_EBIT__c);
	    System.assertEquals(200, financialModulesList.get(0).Financial_Details__r.get(3).EBITDA__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Calculated_CF__c);
	    System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(3).Net_Interest_expense__c);
	    System.assertEquals(300, financialModulesList.get(0).Financial_Details__r.get(3).Exceptional_Items_Total__c);
	    System.assertEquals(0.33, financialModulesList.get(0).Financial_Details__r.get(3).Profit_Margin__c);
	    System.assertEquals(0.14, financialModulesList.get(0).Financial_Details__r.get(3).ROA_calculation_includes_taxes_x_D_B__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(3).ROE_without_Reserves__c);
	    System.assertEquals(-0.29, financialModulesList.get(0).Financial_Details__r.get(3).Profitability__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(3).Solvency_ratio__c);
	    System.assertEquals(0.86, financialModulesList.get(0).Financial_Details__r.get(3).Leverage__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(3).Debt_to_EBITDA__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).EBITDA_coverage__c);
	    System.assertEquals(1.33, financialModulesList.get(0).Financial_Details__r.get(3).Current_ratio__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(3).Quick_acid_ratio__c);
	    System.assertEquals(100, financialModulesList.get(0).Financial_Details__r.get(3).Working_capital__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Cash_flow_ratio__c);
	    System.assertEquals(120, financialModulesList.get(0).Financial_Details__r.get(3).DSO_in_days__c);
	    System.assertEquals(360, financialModulesList.get(0).Financial_Details__r.get(3).DPO_in_days__c);

	    // 2017 score
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Assets__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Fixed_Assets__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Intangible_Fixed_Assets__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Tangible_Fixed_Assets__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Financial_LT_Assets__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Current_Assets__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Stock_material_work__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Trade_debtors__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Cash_Cash_equivalent__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Others_Current_Assets__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Liabilities__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Net_worth__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Reserves__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Liabilities__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).LongTerm_Liabilities__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_LT_bank_debt__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_other_LT_liabilities__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).ShortTerm_Liabilities__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_Trade_Creditors__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_ST_bank_debt__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_other_ST_liabilities__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Turnover__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Turnover__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Activation__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Other_operational_income__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Cost_of_goods_sold__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Gross_profit_loss__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Depreciation__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).EBIT_from_Crefo__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Income_and_other_taxes__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Operational_profit_EBIT__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).EBITDA__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Calculated_CF__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Financial_Income__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Financial_Charges__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Net_Interest_expense__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).EAT__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Extraordinary_Items__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Exceptional_Income__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Exceptional_Charges__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Exceptional_Items_Total__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Profit_Margin__c);
	    System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(2).ROA_calculation_includes_taxes_x_D_B__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).ROE_without_Reserves__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Profitability__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Solvency_ratio__c);
	    System.assertEquals(5, financialModulesList.get(0).Financial_Details__r.get(2).Leverage__c);
	    System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(2).Debt_to_EBITDA__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).EBITDA_coverage__c);
	    System.assertEquals(3, financialModulesList.get(0).Financial_Details__r.get(2).Current_ratio__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Quick_acid_ratio__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Working_capital__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Cash_flow_ratio__c);
	    System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).DSO_in_days__c);
	    System.assertEquals(5, financialModulesList.get(0).Financial_Details__r.get(2).DPO_in_days__c);
	    System.assertEquals(3, financialModulesList.get(0).Financial_Details__r.get(2).Overall_score__c);
    }


    /*******************************************************************************
    *  Name            : createAccount()
    *  Summary         : Create test Account.
    *  CreatedDate     : 24/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    static void createAccount() {
    	account = new Account(
    		Name = 'test',
    		BillingCountry = 'Germany');
    	insert account;
    }


    /*******************************************************************************
    *  Name            : createFinancialModule()
    *  Summary         : Create test Financial Module.  
    *  CreatedDate     : 24/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    static void createFinancialModule() {
		module = new Financial_Module__c(
			Account__c = account.Id,
			Name = 'Test');
		insert module;
    }


    /*******************************************************************************
    *  Name            : createFinancialDetails()
    *  Summary         : Create test Financial Details.   
    *  CreatedDate     : 24/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    static void createFinancialDetails() {
    	List<Financial_Detail__c> detailsList = new List<Financial_Detail__c>();

    	Financial_Detail__c detail1 = new Financial_Detail__c(
    		Financial_Module__c = module.Id,
    		Year__c = '2018',
    		Type__c = 'Annual',
    		Intangible_Fixed_Assets__c = 200,
    		Tangible_Fixed_Assets__c = 200,
    		Financial_LT_Assets__c = 200,
    		Stock_material_work__c = 200,
    		Trade_debtors__c = 200,
    		Cash_Cash_equivalent__c = 200,
    		Others_Current_Assets__c = 200,
    		Net_worth__c = 200,
    		Reserves__c = 200,
    		LongTerm_Liabilities__c = 200,
    		From_that_LT_bank_debt__c = 200,
    		From_that_other_LT_liabilities__c = 200,
    		ShortTerm_Liabilities__c = 400,
    		From_that_Trade_Creditors__c = 200,
    		From_that_ST_bank_debt__c = 200,
    		From_that_other_ST_liabilities__c = 200,
    		Turnover__c = 200,
    		Activation__c = 200,
    		Other_operational_income__c = 200,
    		Cost_of_goods_sold__c = 200,
    		Depreciation__c = 200,
    		Income_and_other_taxes__c = 200,
    		EBIT_from_Crefo__c = 200,
    		Gross_profit_loss__c = 200,
    		Financial_Income__c = 200,
    		Financial_Charges__c = 200,
    		EAT__c = 200,
    		Extraordinary_Items__c = 200,
    		Exceptional_Income__c = 200,
    		Exceptional_Charges__c = 200);
    	detailsList.add(detail1);

    	Financial_Detail__c detail2 = new Financial_Detail__c(
    		Financial_Module__c = module.Id,
    		Year__c = '2017',
    		Type__c = 'Annual',
    		Intangible_Fixed_Assets__c = 100,
    		Tangible_Fixed_Assets__c = 100,
    		Financial_LT_Assets__c = 100,
    		Stock_material_work__c = 100,
    		Trade_debtors__c = 100,
    		Cash_Cash_equivalent__c = 100,
    		Others_Current_Assets__c = 100,
    		Net_worth__c = 100,
    		Reserves__c = 100,
    		LongTerm_Liabilities__c = 100,
    		From_that_LT_bank_debt__c = 100,
    		From_that_other_LT_liabilities__c = 100,
    		ShortTerm_Liabilities__c = 200,
    		From_that_Trade_Creditors__c = 100,
    		From_that_ST_bank_debt__c = 100,
    		From_that_other_ST_liabilities__c = 100,
    		Turnover__c = 100,
    		Activation__c = 100,
    		Other_operational_income__c = 100,
    		Cost_of_goods_sold__c = 100,
    		Depreciation__c = 100,
    		Income_and_other_taxes__c = 100,
    		EBIT_from_Crefo__c = 100,
    		Gross_profit_loss__c = 100,
    		Financial_Income__c = 100,
    		Financial_Charges__c = 100,
    		EAT__c = 100,
    		Extraordinary_Items__c = 100,
    		Exceptional_Income__c = 100,
    		Exceptional_Charges__c = 100);
    	detailsList.add(detail2);

    	insert detailsList;
    }
}