
public class FinancialModuleCalculator {


    /*******************************************************************************
    *  Name            : calculateFinancialDetails(List<Financial_Detail__c> detailsList, String moduleId)
    *  Summary         : Calculate Financial Details Manual on VF page.    
    *  CreatedDate     : 27/09/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Financial_Detail__c> detailsList - Financial Details to calculate,
                         String moduleId - Id of parent Financial Module
    *  Returns         : 
    ******************************************************************************/
    public static List<Financial_Detail__c> calculateFinancialDetails(List<Financial_Detail__c> detailsList, String moduleId) {
        List<Financial_Detail__c> financialDetailsList = new List<Financial_Detail__c>();
        financialDetailsList.addAll(returnCalculatedDetails(detailsList, moduleId));
        upsert financialDetailsList;
        return financialDetailsList;
    }



    /*******************************************************************************
    *  Name            : calculateFinancialDetailsValues(Set<String> financialModulesIdsSet)
    *  Summary         : Calculate Financial Details of definite Financial Module.
    *  CreatedDate     : 14/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Set<Id> financialModulesIdsSet
    *  Returns         : List<Financial_Detail__c>
    ******************************************************************************/
    public static List<Financial_Detail__c> calculateFinancialDetails(Set<Id> financialModulesIdsSet) {
        List<Financial_Module__c> financialModulesList = selectFinancialDataToCalculate(financialModulesIdsSet);
        List<Financial_Detail__c> financialDetailsList = new List<Financial_Detail__c>();
        for (Financial_Module__c financialModule : financialModulesList) {
            financialDetailsList.addAll(returnCalculatedDetails(financialModule.Financial_details__r, financialModule.Id));
        }

        upsert financialDetailsList;
        return financialDetailsList;
    }


    /*******************************************************************************
    *  Name            : returnCalculatedDetails(List<Financial_Detail__c> detailsList)
    *  Summary         : Calculate and Return Financial Data.
    *  CreatedDate     : 27/09/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Financial_Detail__c> detailsList - Financial Details to calculate,
                         String moduleId - Id of parent Financial Module
    *  Returns         : List<Financial_Detail__c>
    ******************************************************************************/
    public static List<Financial_Detail__c> returnCalculatedDetails(List<Financial_Detail__c> detailsList, String moduleId) {
        Map<String, Financial_Detail__c> financialDetailsMap = new Map<String, Financial_Detail__c>();
        for (Financial_Detail__c detail : detailsList) {
            // collent all data after input
            financialDetailsMap.put(detail.Year__c + detail.Type__c, detail);
        }

        List<Financial_Detail__c> scoreDetailsToDelete = new List<Financial_Detail__c>();
        for (Financial_Detail__c detail : detailsList) {
            if (detail.Type__c == 'Annual' && ! financialDetailsMap.containsKey(detail.Year__c + 'Score')) {
                // add score item for every annual
                Financial_Detail__c scoreDetailToInsert = new Financial_Detail__c(
                    Year__c = detail.Year__c,
                    Type__c = 'Score',
                    Financial_module__c = moduleId);
                financialDetailsMap.put(scoreDetailToInsert.Year__c + scoreDetailToInsert.Type__c, scoreDetailToInsert);
            } else if (detail.Type__c == 'Score' && ! financialDetailsMap.containsKey(detail.Year__c + 'Annual')) {
                // delete extra score item without annual
                if (detail.Id != null) {
                    scoreDetailsToDelete.add(detail);
                }  
                financialDetailsMap.remove(detail.Year__c + detail.Type__c);
            } 
        }

        if (! scoreDetailsToDelete.isEmpty()) {
            delete scoreDetailsToDelete;
        }
        
        detailsList = financialDetailsMap.values();
        for (Financial_Detail__c detail : detailsList) {
            // calculate annual detail formulas
            if (detail.Type__c == 'Annual') {
                detail = calculateAnnualValues(detail, financialDetailsMap);
            } 
        }

        for (Financial_Detail__c detail : detailsList) {
            // calculate score details formulas
            if (detail.Type__c == 'Score') {
                detail = calculateScoreValues(detail, financialDetailsMap);
            }
        }

        return detailsList;
    }


    /*******************************************************************************
    *  Name            : selectFinancialDataToCalculate(Set<Id> financialModulesIdsSet)
    *  Summary         : Select Financial Module and its Details to calculate values.    
    *  CreatedDate     : 25/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Set<Id> financialModulesIdsSet - Ids of financial Modules
    *  Returns         : List<Financial_Module__c> financialModulesList
    ******************************************************************************/
    public static List<Financial_Module__c> selectFinancialDataToCalculate(Set<Id> financialModulesIdsSet) {
        List<Financial_Module__c> financialModulesList = [
                SELECT Name, 
                        (SELECT Year__c, Type__c, Total_Assets__c, Total_Fixed_Assets__c, Intangible_Fixed_Assets__c, 
                            Tangible_Fixed_Assets__c, Financial_LT_Assets__c, Other_Fixed_assets__c, Total_Current_Assets__c, Stock_material_work__c, 
                            Trade_debtors__c, Cash_Cash_equivalent__c,  Others_Current_Assets__c, Total_Liabilities__c, 
                            Net_worth__c, Reserves__c, Liabilities__c, LongTerm_Liabilities__c, From_that_LT_bank_debt__c, 
                            From_that_other_LT_liabilities__c, Leasing_Engagement__c, ShortTerm_Liabilities__c, From_that_Trade_Creditors__c, 
                            From_that_ST_bank_debt__c, From_that_other_ST_liabilities__c, Total_Turnover__c, Turnover__c, 
                            Activation__c, Other_operational_income__c, Cost_of_goods_sold__c, Gross_profit_loss__c, Depreciation__c, 
                            Income_and_other_taxes__c, EBIT_from_Crefo__c, Operational_profit_EBIT__c, EBITDA__c, Calculated_CF__c, Financial_Income__c, 
                            Financial_Charges__c, Net_Interest_expense__c, EAT__c, Extraordinary_Items__c, Exceptional_Income__c, 
                            Exceptional_Charges__c, Exceptional_Items_Total__c, Profit_Margin__c, ROA_calculation_includes_taxes_x_D_B__c, 
                            ROE_without_Reserves__c, Profitability__c, Solvency_ratio__c, Leverage__c, Debt_to_EBITDA__c, 
                            EBITDA_coverage__c, Current_ratio__c, Quick_acid_ratio__c, Working_capital__c, Cash_flow_ratio__c, 
                            DSO_in_days__c, DPO_in_days__c, Overall_score__c, Number_of_Ratios__c
                        FROM Financial_Details__r
                        ORDER BY Year__c DESC)
                FROM Financial_Module__c
                WHERE Id IN :financialModulesIdsSet
                ORDER BY CreatedDate DESC
                LIMIT 100];

        return financialModulesList;
    }


    /*******************************************************************************
    *  Name            : calculateAnnualValues(Financial_Detail__c detail)
    *  Summary         : Calculate formulas for the annual detail.
    *  CreatedDate     : 12/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Financial_Detail__c detail - annual detail of the current year,
                         Map<String, Financial_Detail__c> financialDetailsMap - all financial details map
    *  Returns         : Financial_Detail__c
    ******************************************************************************/
    public static Financial_Detail__c calculateAnnualValues(Financial_Detail__c detail, Map<String, Financial_Detail__c> financialDetailsMap) {
        if (detail.Intangible_Fixed_Assets__c != null) detail.Intangible_Fixed_Assets__c = detail.Intangible_Fixed_Assets__c.setScale(0);
        if (detail.Tangible_Fixed_Assets__c != null) detail.Tangible_Fixed_Assets__c = detail.Tangible_Fixed_Assets__c.setScale(0);
        if (detail.Financial_LT_Assets__c != null) detail.Financial_LT_Assets__c = detail.Financial_LT_Assets__c.setScale(0);
        if (detail.Other_Fixed_assets__c != null) detail.Other_Fixed_assets__c = detail.Other_Fixed_assets__c.setScale(0);
        if (detail.Stock_material_work__c != null) detail.Stock_material_work__c = detail.Stock_material_work__c.setScale(0);
        if (detail.Trade_debtors__c != null) detail.Trade_debtors__c = detail.Trade_debtors__c.setScale(0);
        if (detail.Cash_Cash_equivalent__c != null) detail.Cash_Cash_equivalent__c = detail.Cash_Cash_equivalent__c.setScale(0);
        if (detail.Others_Current_Assets__c != null) detail.Others_Current_Assets__c = detail.Others_Current_Assets__c.setScale(0);
        if (detail.Net_worth__c != null) detail.Net_worth__c = detail.Net_worth__c.setScale(0);
        if (detail.Reserves__c != null) detail.Reserves__c = detail.Reserves__c.setScale(0);
        if (detail.From_that_LT_bank_debt__c != null) detail.From_that_LT_bank_debt__c = detail.From_that_LT_bank_debt__c.setScale(0);
        if (detail.From_that_other_LT_liabilities__c != null) detail.From_that_other_LT_liabilities__c = detail.From_that_other_LT_liabilities__c.setScale(0);
        if (detail.Leasing_Engagement__c != null) detail.Leasing_Engagement__c = detail.Leasing_Engagement__c.setScale(0);
        if (detail.From_that_Trade_Creditors__c != null) detail.From_that_Trade_Creditors__c = detail.From_that_Trade_Creditors__c.setScale(0);
        if (detail.From_that_ST_bank_debt__c != null) detail.From_that_ST_bank_debt__c = detail.From_that_ST_bank_debt__c.setScale(0);
        if (detail.From_that_other_ST_liabilities__c != null) detail.From_that_other_ST_liabilities__c = detail.From_that_other_ST_liabilities__c.setScale(0);
        if (detail.Turnover__c != null) detail.Turnover__c = detail.Turnover__c.setScale(0);
        if (detail.Activation__c != null) detail.Activation__c = detail.Activation__c.setScale(0);
        if (detail.Other_operational_income__c != null) detail.Other_operational_income__c = detail.Other_operational_income__c.setScale(0);
        if (detail.Cost_of_goods_sold__c != null) detail.Cost_of_goods_sold__c = detail.Cost_of_goods_sold__c.setScale(0);
        if (detail.Gross_profit_loss__c != null) detail.Gross_profit_loss__c = detail.Gross_profit_loss__c.setScale(0);
        if (detail.Depreciation__c != null) detail.Depreciation__c = detail.Depreciation__c.setScale(0);
        if (detail.Income_and_other_taxes__c != null) detail.Income_and_other_taxes__c = detail.Income_and_other_taxes__c.setScale(0);
        if (detail.EBIT_from_Crefo__c != null) detail.EBIT_from_Crefo__c = detail.EBIT_from_Crefo__c.setScale(0);
        if (detail.Operational_profit_EBIT__c != null) detail.Operational_profit_EBIT__c = detail.Operational_profit_EBIT__c.setScale(0);
        if (detail.Financial_Income__c != null) detail.Financial_Income__c = detail.Financial_Income__c.setScale(0);
        if (detail.Financial_Charges__c != null) detail.Financial_Charges__c = detail.Financial_Charges__c.setScale(0);
        if (detail.EAT__c != null) detail.EAT__c = detail.EAT__c.setScale(0);
        if (detail.Extraordinary_Items__c != null) detail.Extraordinary_Items__c = detail.Extraordinary_Items__c.setScale(0);
        if (detail.Exceptional_Income__c != null) detail.Exceptional_Income__c = detail.Exceptional_Income__c.setScale(0);
        if (detail.Exceptional_Charges__c != null) detail.Exceptional_Charges__c = detail.Exceptional_Charges__c.setScale(0);

        detail.Total_Fixed_Assets__c = returnTotalFixedAssetsAnnual(detail.Intangible_Fixed_Assets__c, 
                                                                    detail.Tangible_Fixed_Assets__c, 
                                                                    detail.Financial_LT_Assets__c,
                                                                    detail.Other_fixed_assets__c);
        detail.Total_Current_Assets__c = returnTotalCurrentAssetsAnnual(detail.Stock_material_work__c, 
                                                                    detail.Trade_debtors__c, 
                                                                    detail.Cash_Cash_equivalent__c, 
                                                                    detail.Others_Current_Assets__c);
        detail.Total_Assets__c = returnTotalAssetsAnnual(detail.Total_Fixed_Assets__c, 
                                                         detail.Total_Current_Assets__c);
        detail.LongTerm_Liabilities__c = returnLongTermLiabilitiesAnnual(detail.From_that_LT_bank_debt__c,
                                                                         detail.From_that_other_LT_liabilities__c);
        detail.ShortTerm_Liabilities__c = returnShortTermLiabilitiesAnnual(detail.From_that_Trade_Creditors__c,
                                                                           detail.From_that_ST_bank_debt__c,
                                                                           detail.From_that_other_ST_liabilities__c);
        detail.Liabilities__c = returnLiabilitiesAnnual(detail.LongTerm_Liabilities__c, 
                                                        detail.ShortTerm_Liabilities__c);
        detail.Total_Liabilities__c = returnTotalLiabilitiesAnnual(detail.Net_worth__c, detail.Reserves__c, 
                                                                   detail.Liabilities__c);
        detail.Total_Turnover__c = returnTotalTurnOverAnnual(detail.Turnover__c, detail.Activation__c, 
                                                             detail.Other_operational_income__c);
        detail.Net_Interest_expense__c = returnNetInterestExpenseAnnual(detail.Financial_Income__c, 
                                                                        detail.Financial_Charges__c);
        detail.Exceptional_Items_Total__c = returnExceptionalItemsTotalAnnual(detail.Extraordinary_Items__c, 
                                                                              detail.Exceptional_Income__c,
                                                                              detail.Exceptional_Charges__c);
        detail.Operational_profit_EBIT__c = returnOperationalProfitEBITAnnual(detail.EBIT_from_Crefo__c,
                                                                              detail.EAT__c,
                                                                              detail.Net_Interest_expense__c,
                                                                              detail.Exceptional_Items_Total__c);
        detail.EBITDA__c = returnEBITDAAnnual(detail.Operational_profit_EBIT__c, detail.Depreciation__c);
        if (financialDetailsMap.containsKey(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + detail.Type__c)) {
            detail.Calculated_CF__c = returnCalculatedCFAnnual(detail.EBITDA__c,
                financialDetailsMap.get(detail.Year__c + detail.Type__c).Stock_material_work__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + detail.Type__c).Stock_material_work__c,
                financialDetailsMap.get(detail.Year__c + detail.Type__c).Trade_debtors__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + detail.Type__c).Trade_debtors__c,
                financialDetailsMap.get(detail.Year__c + detail.Type__c).From_that_Trade_Creditors__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + detail.Type__c).From_that_Trade_Creditors__c);
        } else {
            detail.Calculated_CF__c = null;
        }
        detail.Profit_Margin__c = returnProfitMarginTotalAnnual(detail.EAT__c, detail.Total_Turnover__c);
        detail.ROA_calculation_includes_taxes_x_D_B__c = returnROAAnnual(detail.EAT__c, detail.Total_Assets__c);
        detail.ROE_without_Reserves__c = returnROEAnnual(detail.EAT__c, detail.Net_worth__c);
        detail.Profitability__c = returnProfitabilityAnnual(detail.EAT__c, detail.Exceptional_Items_Total__c,
                                                            detail.Total_Assets__c);
        detail.Solvency_ratio__c = returnSolvencyRatioAnnual(detail.EAT__c, detail.Depreciation__c,
                                                             detail.From_that_LT_bank_debt__c, 
                                                             detail.From_that_ST_bank_debt__c);
        detail.Leverage__c = returnLeverageAnnual(detail.Liabilities__c, detail.Reserves__c, detail.Total_Assets__c);
        detail.Debt_to_EBITDA__c = returnDebtToEBITDAAnnual(detail.EBITDA__c, detail.From_that_LT_bank_debt__c, 
                                                             detail.From_that_ST_bank_debt__c);
        detail.EBITDA_coverage__c = returnEBITDACoverageAnnual(detail.EBITDA__c, detail.Net_Interest_expense__c);
        detail.Current_ratio__c = returnCurrentRatioAnnual(detail.Total_Current_Assets__c, 
                                                           detail.ShortTerm_Liabilities__c);
        detail.Quick_acid_ratio__c = returnQuickAcidRatioAnnual(detail.Total_Current_Assets__c, 
                                                                detail.Stock_material_work__c, 
                                                                detail.ShortTerm_Liabilities__c);
        detail.Working_capital__c = returnWorkingCapitalAnnual(detail.Total_Current_Assets__c, 
                                                               detail.ShortTerm_Liabilities__c);
        detail.Cash_flow_ratio__c = returnCashFlowRatioAnnual(detail.Calculated_CF__c, 
                                                              detail.ShortTerm_Liabilities__c);
        detail.DSO_in_days__c = returnDSOInDaysAnnual(detail.Trade_debtors__c, detail.Total_Turnover__c);
        detail.DPO_in_days__c = returnDPOInDaysAnnual(detail.From_that_Trade_Creditors__c, 
                                                      detail.Cost_of_goods_sold__c);
        return detail;
    }

    /*******************************************************************************
    *  Name            : calculateScoreValues(Financial_Detail__c detail)
    *  Summary         : Calculate formulas for the score.
    *  CreatedDate     : 12/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Financial_Detail__c detail - score detail of the current year
                         Map<String, Financial_Detail__c> financialDetailsMap - all financial details map
    *  Returns         : Financial_Detail__c
    ******************************************************************************/
    public static Financial_Detail__c calculateScoreValues(Financial_Detail__c detail, Map<String, Financial_Detail__c> financialDetailsMap) {
        if (financialDetailsMap.containsKey(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual')) {
            detail.Total_Assets__c = returnTotalAssetsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Total_Assets__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Total_Assets__c);
            detail.Total_Fixed_Assets__c = returnTotalFixedAssetsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Total_Fixed_Assets__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Total_Fixed_Assets__c);
            detail.Intangible_Fixed_Assets__c = returnIntangibleFixedAssetsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Intangible_Fixed_Assets__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Intangible_Fixed_Assets__c);
            detail.Tangible_Fixed_Assets__c = returnTangibleFixedAssetsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Tangible_Fixed_Assets__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Tangible_Fixed_Assets__c);
            detail.Financial_LT_Assets__c = returnFinancialLTAssetsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Financial_LT_Assets__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Financial_LT_Assets__c);
            detail.Total_Current_Assets__c = returnTotalCurrentAssetsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Total_Current_Assets__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Total_Current_Assets__c);
            detail.Stock_material_work__c = returnStockMaterialWorkInProgressChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Stock_material_work__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Stock_material_work__c);
            detail.Trade_debtors__c = returnTradeDebtorsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Trade_debtors__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Trade_debtors__c);
            detail.Cash_Cash_equivalent__c = returnCashCashEquivalentChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Cash_Cash_equivalent__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Cash_Cash_equivalent__c);
            detail.Others_Current_Assets__c = returnOtherCurrentAssetsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Others_Current_Assets__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Others_Current_Assets__c);
            detail.Total_Liabilities__c = returnTotalLiabilitiesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Total_Liabilities__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Total_Liabilities__c);
            detail.Net_worth__c = returnNetWorthChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Net_worth__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Net_worth__c);
            detail.Reserves__c = returnReservesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Reserves__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Reserves__c);
            detail.Liabilities__c = returnLiabilitiesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Liabilities__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Liabilities__c);
            detail.LongTerm_Liabilities__c = returnLongTermLiabilitiesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').LongTerm_Liabilities__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').LongTerm_Liabilities__c);
            detail.From_that_LT_bank_debt__c = returnFromThatLTBankDebtChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').From_that_LT_bank_debt__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').From_that_LT_bank_debt__c);
            detail.From_that_other_LT_liabilities__c = returnFromThatOtherLTLiabilitiesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').From_that_other_LT_liabilities__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').From_that_other_LT_liabilities__c);
            detail.Leasing_Engagement__c = returnLeasingEngagementChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Leasing_Engagement__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Leasing_Engagement__c);
            detail.ShortTerm_Liabilities__c = returnShortTermLiabilitiesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').ShortTerm_Liabilities__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').ShortTerm_Liabilities__c);
            detail.From_that_Trade_Creditors__c = returnFromThatTradeCreditorsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').From_that_Trade_Creditors__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').From_that_Trade_Creditors__c);
            detail.From_that_ST_bank_debt__c = returnFromThatSTBankDebtChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').From_that_ST_bank_debt__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').From_that_ST_bank_debt__c);
            detail.From_that_Other_ST_Liabilities__c = returnFromThatOtherSTLiabilitiesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').From_that_Other_ST_Liabilities__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').From_that_Other_ST_Liabilities__c);
            detail.Total_Turnover__c = returnTotalTurnoverChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Total_Turnover__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Total_Turnover__c);
            detail.Turnover__c = returnTurnoverChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Turnover__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Turnover__c);
            detail.Activation__c = returnActivationChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Activation__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Activation__c);
            detail.Other_operational_income__c = returnOtherOperationalIncomeChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Other_operational_income__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Other_operational_income__c);
            detail.Cost_of_goods_sold__c = returnCostOfGoodsSoldChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Cost_of_goods_sold__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Cost_of_goods_sold__c);
            detail.Gross_profit_loss__c = returnGrossProfitLossChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Gross_profit_loss__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Gross_profit_loss__c);
            detail.Depreciation__c = returnDepreciationChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Depreciation__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Depreciation__c);
            detail.Income_and_other_taxes__c = returnIncomeAndOtherTaxesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Income_and_other_taxes__c,
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Income_and_other_taxes__c);
            detail.EBIT_from_Crefo__c = returnEBITFromCrefoChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').EBIT_from_Crefo__c,
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').EBIT_from_Crefo__c);
            detail.Operational_profit_EBIT__c = returnOperationalProfitEBITChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Operational_profit_EBIT__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Operational_profit_EBIT__c);
            detail.EBITDA__c = returnEBITDAChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').EBITDA__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').EBITDA__c);
            detail.Calculated_CF__c = returnCalculatedCFChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Calculated_CF__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Calculated_CF__c);
            detail.Financial_Income__c = returnFinancialIncomeChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Financial_Income__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Financial_Income__c);
            detail.Financial_Charges__c = returnFinancialChargesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Financial_Charges__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Financial_Charges__c);
            detail.Net_Interest_expense__c = returnNetInterestExpenseChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Net_Interest_expense__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Net_Interest_expense__c);
            detail.EAT__c = returnEATChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').EAT__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').EAT__c);
            detail.Extraordinary_Items__c = returnExtraordinaryItemsChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Extraordinary_Items__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Extraordinary_Items__c);
            detail.Exceptional_Income__c = returnExceptionalIncomeChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Exceptional_Income__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Exceptional_Income__c);
            detail.Exceptional_Charges__c = returnExceptionalChargesChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Exceptional_Charges__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Exceptional_Charges__c);
            detail.Exceptional_Items_Total__c = returnExceptionalItemsTotalChange(
                financialDetailsMap.get(detail.Year__c + 'Annual').Exceptional_Items_Total__c, 
                financialDetailsMap.get(String.valueOf(Integer.valueOf(detail.Year__c) - 1) + 'Annual').Exceptional_Items_Total__c);
        } else {
            detail.Total_Assets__c = null;
            detail.Total_Fixed_Assets__c = null;
            detail.Intangible_Fixed_Assets__c = null;
            detail.Tangible_Fixed_Assets__c = null;
            detail.Financial_LT_Assets__c = null;
            detail.Other_Fixed_assets__c = null;
            detail.Total_Current_Assets__c = null;
            detail.Stock_material_work__c = null;
            detail.Trade_debtors__c = null;
            detail.Cash_Cash_equivalent__c = null;
            detail.Others_Current_Assets__c = null;
            detail.Total_Liabilities__c = null;
            detail.Net_worth__c = null;
            detail.Reserves__c = null;
            detail.Liabilities__c = null;
            detail.LongTerm_Liabilities__c = null;
            detail.From_that_LT_bank_debt__c = null;
            detail.From_that_other_LT_liabilities__c = null;
            detail.Leasing_Engagement__c = null;
            detail.ShortTerm_Liabilities__c = null;
            detail.From_that_Trade_Creditors__c = null;
            detail.From_that_ST_bank_debt__c = null;
            detail.From_that_other_ST_liabilities__c = null;
            detail.Total_Turnover__c = null;
            detail.Turnover__c = null;
            detail.Activation__c = null;
            detail.Other_operational_income__c = null;
            detail.Cost_of_goods_sold__c = null;
            detail.Depreciation__c = null;
            detail.Income_and_other_taxes__c = null;
            detail.EBIT_from_Crefo__c = null;
            detail.Operational_profit_EBIT__c = null;
            detail.EBITDA__c = null;
            detail.Calculated_CF__c = null;
            detail.Financial_Income__c = null;
            detail.Financial_Charges__c = null;
            detail.Net_Interest_expense__c = null;
            detail.EAT__c = null;
            detail.Extraordinary_Items__c = null;
            detail.Exceptional_Income__c = null;
            detail.Exceptional_Charges__c = null;
            detail.Exceptional_Items_Total__c = null;
        }
        detail.ROA_calculation_includes_taxes_x_D_B__c = returnROARS(
            financialDetailsMap.get(detail.Year__c + 'Annual').ROA_calculation_includes_taxes_x_D_B__c);
        detail.Leverage__c = returnLeverageRS(
            financialDetailsMap.get(detail.Year__c + 'Annual').Leverage__c);
        detail.Debt_to_EBITDA__c = returnDebtToEBITDARS(
            financialDetailsMap.get(detail.Year__c + 'Annual').Debt_to_EBITDA__c);
        detail.EBITDA_coverage__c = returnEBITDACoverageRS(
            financialDetailsMap.get(detail.Year__c + 'Annual').EBITDA_coverage__c);
        detail.Current_ratio__c = returnCurrentRatioRS(
            financialDetailsMap.get(detail.Year__c + 'Annual').Current_ratio__c);
        detail.Cash_flow_ratio__c = returnCashFlowRatioRS(
            financialDetailsMap.get(detail.Year__c + 'Annual').Cash_flow_ratio__c);
        detail.DPO_in_days__c = returnDPOInDaysRS(
            financialDetailsMap.get(detail.Year__c + 'Annual').DPO_in_days__c);
        detail.Overall_score__c = returnOverallScoreRS(detail.ROA_calculation_includes_taxes_x_D_B__c, 
                                                                              detail.Leverage__c, detail.Debt_to_EBITDA__c, 
                                                                              detail.EBITDA_coverage__c, detail.Current_ratio__c, 
                                                                              detail.Cash_flow_ratio__c, detail.DPO_in_days__c);
        detail.Number_of_Ratios__c = 0;
        if (detail.ROA_calculation_includes_taxes_x_D_B__c != null) detail.Number_of_Ratios__c ++;
        if (detail.Leverage__c != null) detail.Number_of_Ratios__c ++;
        if (detail.Debt_to_EBITDA__c != null) detail.Number_of_Ratios__c ++;
        if (detail.EBITDA_coverage__c != null) detail.Number_of_Ratios__c ++;
        if (detail.Current_ratio__c != null) detail.Number_of_Ratios__c ++;
        if (detail.Cash_flow_ratio__c != null) detail.Number_of_Ratios__c ++;
        if (detail.DPO_in_days__c != null) detail.Number_of_Ratios__c ++;
        return detail;
    }


    /*******************************************************************************
    *  Name            : returnTotalFixedAssetsAnnual(Decimal intangibleFixedAssets, 
                                                      Decimal tangibleFixedAssets, 
                                                      Decimal financialLTAssets)
    *  Summary         : Return Total Fixed Assets of the current year.
    *  CreatedDate     : 05/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal intangibleFixedAssets - Intangible Fixed Assets, 
                         Decimal tangibleFixedAssets - Tangible Fixed Assets, 
                         Decimal financialLTAssets - Financial LT Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalFixedAssetsAnnual(Decimal intangibleFixedAssets, 
                                                        Decimal tangibleFixedAssets, 
                                                        Decimal financialLTAssets,
                                                        Decimal otherFixedAssets) {
        try {
            Decimal totalFixedAssets = 0;

            if (intangibleFixedAssets != null) totalFixedAssets += intangibleFixedAssets;
            if (tangibleFixedAssets != null) totalFixedAssets += tangibleFixedAssets;
            if (financialLTAssets != null) totalFixedAssets += financialLTAssets;
            if (otherFixedAssets != null) totalFixedAssets += otherFixedAssets;

            return totalFixedAssets;
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTotalCurrentAssetsAnnual(Decimal stockMaterialWorkInProgress, 
                                                        Decimal tradeDebtors, 
                                                        Decimal cashCashEquivalent)
    *  Summary         : Return Total Current Assets of the current year.
    *  CreatedDate     : 05/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal stockMaterialWorkInProgress - Stock Material & Work In Progress, 
                         Decimal tradeDebtors - Trade Debtors, 
                         Decimal cashCashEquivalent - Cash / Cash Equivalent,
                         Decimal othersCurrentAssets - Other Current Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalCurrentAssetsAnnual(Decimal stockMaterialWorkInProgress, 
                                                          Decimal tradeDebtors, 
                                                          Decimal cashCashEquivalent,
                                                          Decimal othersCurrentAssets) {
        try {
            Decimal totalCurrentAssets = 0;

            if (stockMaterialWorkInProgress != null) totalCurrentAssets += stockMaterialWorkInProgress;
            if (tradeDebtors != null) totalCurrentAssets += tradeDebtors;
            if (cashCashEquivalent != null) totalCurrentAssets += cashCashEquivalent;
            if (othersCurrentAssets != null) totalCurrentAssets += othersCurrentAssets;

            return totalCurrentAssets.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTotalAssetsAnnual(Decimal totalFixedAssets, 
                                                 Decimal totalCurrentAssets)
    *  Summary         : Return Total Assets of the current year.
    *  CreatedDate     : 06/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal totalFixedAssets - Total Fixed Assets, 
                         Decimal totalCurrentAssets - Tangible Fixed Assets, 
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalAssetsAnnual(Decimal totalFixedAssets, 
                                                   Decimal totalCurrentAssets) {
        try {
            Decimal totalAssets = 0;

            if (totalFixedAssets != null) totalAssets += totalFixedAssets;
            if (totalCurrentAssets != null) totalAssets += totalCurrentAssets;

            return totalAssets.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnLongTermLiabilitiesAnnual(Decimal fromThatLTBankDebt, 
                                                         Decimal fromThatOtherLTLiabilities,)
    *  Summary         : Return Long Term Liabilities of the current year.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal fromThatLTBankDebt - Long Term Liabilities,
                         Decimal fromThatOtherLTLiabilities - Short Term Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnLongTermLiabilitiesAnnual(Decimal fromThatLTBankDebt, 
                                                           Decimal fromThatOtherLTLiabilities) {
        try {
            Decimal longTermLiabilities = 0;

            if (fromThatLTBankDebt != null) longTermLiabilities += fromThatLTBankDebt;
            if (fromThatOtherLTLiabilities != null) longTermLiabilities += fromThatOtherLTLiabilities;

            return longTermLiabilities.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnShortTermLiabilitiesAnnual(Decimal fromThatTradeCreditorsPrepayments, 
                                                          Decimal fromThatSTbankDebt,
                                                          Decimal fromThatOtherSTLiabilities)
    *  Summary         : Return Short Term Liabilities of the current year.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal fromThatTradeCreditorsPrepayments - Trade Creditors Prepayments Liabilities,
                         Decimal fromThatSTbankDebt - ST Bank Debt Liabilities,
                         Decimal fromThatOtherSTLiabilities - Other ST Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnShortTermLiabilitiesAnnual(Decimal fromThatTradeCreditorsPrepayments, 
                                                            Decimal fromThatSTbankDebt, 
                                                            Decimal fromThatOtherSTLiabilities) {
        try {
            Decimal shortTermLiabilities = 0;

            if (fromThatTradeCreditorsPrepayments != null) shortTermLiabilities += fromThatTradeCreditorsPrepayments;
            if (fromThatSTbankDebt != null) shortTermLiabilities += fromThatSTbankDebt;
            if (fromThatOtherSTLiabilities != null) shortTermLiabilities += fromThatOtherSTLiabilities;

            return shortTermLiabilities.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnLiabilitiesAnnual(Decimal longTermLiabilities, 
                                                 Decimal shortTermLiabilities)
    *  Summary         : Return Liabilities of the current year.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal longTermLiabilities - Long Term Liabilities,
                         Decimal shortTermLiabilities - Short Term Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnLiabilitiesAnnual(Decimal longTermLiabilities, 
                                                   Decimal shortTermLiabilities) {
        try {
            Decimal liabilities = 0;

            if (longTermLiabilities != null) liabilities += longTermLiabilities;
            if (shortTermLiabilities != null) liabilities += shortTermLiabilities;

            return liabilities.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTotalLiabilitiesAnnual(Decimal netWorth, Decimal reserves, 
                                                      Decimal liabilities)
    *  Summary         : Return Total Liabilities of the current year.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal netWorth - Net worth, Decimal reserves - Reserves,
                         Decimal liabilities - Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalLiabilitiesAnnual(Decimal netWorth, Decimal reserves, 
                                                        Decimal liabilities) {
        try {
            Decimal totalLiabilities = 0;

            if (netWorth != null) totalLiabilities += netWorth;
            if (reserves != null) totalLiabilities += reserves;
            if (liabilities != null) totalLiabilities += liabilities;

            return totalLiabilities.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTotalTurnOverAnnual(Decimal turnOver, Decimal activation, 
                                                    Decimal otherOperationalIncome)
    *  Summary         : Return Total TurnOver of the current year.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal turnOver - Turn Over, Decimal activation - Activation,
                         Decimal otherOperationalIncome - Other Operational Income
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalTurnOverAnnual(Decimal turnOver, Decimal activation, 
                                                     Decimal otherOperationalIncome) {
        try {
            Decimal totalTurnOver = 0;

            if (turnOver != null) totalTurnOver += turnOver;
            if (activation != null) totalTurnOver += activation;
            if (otherOperationalIncome != null) totalTurnOver += otherOperationalIncome;

            return totalTurnOver.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnEBITDAAnnual(Decimal operationalProfitEBIT, Decimal depreciation)
    *  Summary         : Return EBITDA of the current year.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal operationalProfitEBIT - Turn Over, Decimal depreciation - Depreciation
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnEBITDAAnnual(Decimal operationalProfitEBIT, Decimal depreciation) {
        try {
            Decimal ebitda = 0;
            if (operationalProfitEBIT != null) ebitda += operationalProfitEBIT;
            if (depreciation != null) ebitda += depreciation;

            return ebitda.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnCalculatedCFAnnual(Decimal ebitdda, Decimal currentStockMaterialWorkInProgress,
                                                  Decimal previousStockMaterialWorkInProgress,
                                                  Decimal currentTradeDebtors, Decimal previousTradeDebtors,
                                                  Decimal currentFromThatTradeCreditors,
                                                  Decimal previousFromThatTradeCreditors
    *  Summary         : Return Calculated CF of the current year.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal ebitdda - EBITDA,
                         Decimal currentStockMaterialWorkInProgress - current year Stock Material Work In Progress,
                         Decimal previousStockMaterialWorkInProgress - previous year Stock Material Work In Progress,
                         Decimal currentTradeDebtors - current year Trade Debtors, 
                         Decimal previousTradeDebtors - previous year Trade Debtors,
                         Decimal currentFromThatTradeCreditors - current year From That Trade Creditors,
                         Decimal previousFromThatTradeCreditors - previous year From That Trade Creditors
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnCalculatedCFAnnual(Decimal ebitdda, Decimal currentStockMaterialWorkInProgress,
                                                    Decimal previousStockMaterialWorkInProgress,
                                                    Decimal currentTradeDebtors, Decimal previousTradeDebtors,
                                                    Decimal currentFromThatTradeCreditors,
                                                    Decimal previousFromThatTradeCreditors) {
        try {
            return (ebitdda - (currentStockMaterialWorkInProgress - 
                previousStockMaterialWorkInProgress) - (currentTradeDebtors - previousTradeDebtors) +
                (currentFromThatTradeCreditors - previousFromThatTradeCreditors)).setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnNetInterestExpenseAnnual(Decimal financialIncome, Decimal financialCharges)
    *  Summary         : Return Net interest Expense of the current year.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal financialIncome - Financial Income, Decimal financialCharges - Financial Charges,
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnNetInterestExpenseAnnual(Decimal financialIncome, Decimal financialCharges) {
        try {
            Decimal netInterestExpense = 0;

            if (financialIncome != null) netInterestExpense += financialIncome;
            if (financialCharges != null) netInterestExpense -= financialCharges;

            return netInterestExpense.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnExceptionalItemsTotalAnnual(Decimal extraordinaryItems, Decimal exceptionalIncome, 
                                                           Decimal exceptionalCharges)
    *  Summary         : Return Exceptional Items Total of the current year.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal extraordinaryItems - Extraordinary Items, 
                         Decimal exceptionalIncome - Exceptional Income,
                         Decimal exceptionalCharges - Exceptional Charges
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnExceptionalItemsTotalAnnual(Decimal extraordinaryItems, Decimal exceptionalIncome,
                                                             Decimal exceptionalCharges) {
        try {
            Decimal exceptionalItemsTotal = 0;

            if (extraordinaryItems != null) exceptionalItemsTotal += extraordinaryItems;
            if (exceptionalIncome != null) exceptionalItemsTotal += exceptionalIncome;
            if (exceptionalCharges != null) exceptionalItemsTotal += exceptionalCharges;

            return exceptionalItemsTotal.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnOperationalProfitEBITAnnual(Decimal ebitFromCrefo, Decimal eat, 
                                                           Decimal netInterestExpense, Decimal exceptionalItemsTotal)
    *  Summary         : Return Operational profit EBIT of the current year.
    *  CreatedDate     : 25/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Decimal ebitFromCrefo - EBIT from Crefo, 
                         Decimal eat - EAT,
                         Decimal netInterestExpense - Net Interest Expense,
                         Decimal exceptionalItemsTotal - Exceptional Items Total
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnOperationalProfitEBITAnnual(Decimal ebitFromCrefo, Decimal eat, Decimal netInterestExpense,
                                                             Decimal exceptionalItemsTotal) {
        try {
            Decimal operationalProfitEBIT = 0;

            if (ebitFromCrefo != null) {
                operationalProfitEBIT = ebitFromCrefo;
            } else {
                if (eat != null) operationalProfitEBIT += eat;
                if (netInterestExpense != null) operationalProfitEBIT += netInterestExpense;
                if (exceptionalItemsTotal != null) operationalProfitEBIT += exceptionalItemsTotal;
            }

            return operationalProfitEBIT.setScale(0);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnProfitMarginTotalAnnual(Decimal eat, Decimal totalTurnOver)
    *  Summary         : Return Profit Margin of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal eat - EAT, 
                         Decimal totalTurnOver - Total Turn Over
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnProfitMarginTotalAnnual(Decimal eat, Decimal totalTurnOver) {
        try {
            if (eat == null) eat = 0;
            return (eat / totalTurnOver).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnROAAnnual(Decimal eat, Decimal totalAssets)
    *  Summary         : Return ROA (calculation includes taxes x D&B) of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal eat - EAT, Decimal totalAssets - Total Assests
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnROAAnnual(Decimal eat, Decimal totalAssets) {
        try {
            return (eat / totalAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnROEAnnual(Decimal eat, Decimal netWorth)
    *  Summary         : Return ROE Without Reserves of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal eat - EAT = Earning after tax, net profit, 
                         Decimal netWorth - Net Worth
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnROEAnnual(Decimal eat, Decimal netWorth) {
        try {
            return (eat / netWorth).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnProfitabilityAnnual(Decimal eat, Decimal exceptionalItemsTotal, 
                                                   Decimal totalAssets)
    *  Summary         : Return Profitability Items Total of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal eat - EAT = Earning after tax, net profit, 
                         Decimal exceptionalItemsTotal - Exceptional Items Total,
                         Decimal totalAssets - Total Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnProfitabilityAnnual(Decimal eat, Decimal exceptionalItemsTotal,
                                                     Decimal totalAssets) {
        try {
            return ((eat - exceptionalItemsTotal) / totalAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnSolvencyRatioAnnual(Decimal eat, Decimal depreciation, 
                                                   Decimal fromThatLTbankdebt, 
                                                   Decimal fromThatSTBankDebt)
    *  Summary         : Return Solvency Ratio of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal eat - EAT = Earning after tax, net profit, 
                         Decimal depreciation - Exceptional Items Total,
                         Decimal fromThatLTbankdebt - Liabilities From That LT bank debt, 
                         Decimal fromThatSTBankDebt - Liabilities From That ST bank debt
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnSolvencyRatioAnnual(Decimal eat, Decimal depreciation, 
                                                     Decimal fromThatLTbankdebt, 
                                                     Decimal fromThatSTBankDebt) {
        try {
            if (eat == null) eat = 0;
            if (depreciation == null) depreciation = 0;
            if (fromThatLTbankdebt == null) fromThatLTbankdebt = 0;
            if (fromThatSTBankDebt == null) fromThatSTBankDebt = 0;
            return ((eat + depreciation) / (fromThatLTbankdebt + fromThatSTBankDebt)).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnDebtToEBITDAAnnual(Decimal ebitda, Decimal fromThatLTbankdebt, 
                                                  Decimal fromThatSTBankDebt)
    *  Summary         : Return Debt To EBITDA of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal ebitda - EBITDA,
                         Decimal fromThatLTbankdebt - Liabilities From That LT bank debt, 
                         Decimal fromThatSTBankDebt - Liabilities From That ST bank debt
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnDebtToEBITDAAnnual(Decimal ebitda, Decimal fromThatLTbankdebt, 
                                                    Decimal fromThatSTBankDebt) {
        try {
            if (fromThatLTbankdebt == null) fromThatLTbankdebt = 0;
            if (fromThatSTBankDebt == null) fromThatSTBankDebt = 0;
            return ((fromThatLTbankdebt + fromThatSTBankDebt) / ebitda).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnLeverageAnnual(Decimal liabilities, Decimal reserves, 
                                              Decimal others, Decimal totalAssets)
    *  Summary         : Return Leverage of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal liabilities = Liabilities, 
                         Decimal reserves - Reserves,
                         Decimal others - Other Liabilities,
                         Decimal totalAssets - Total Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnLeverageAnnual(Decimal liabilities, Decimal reserves, 
                                                Decimal totalAssets) {
        try {
            if (liabilities == null) liabilities = 0;
            if (reserves == null) reserves = 0;
            return ((liabilities + reserves) / totalAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnEBITDACoverageAnnual(Decimal ebitda, Decimal netInterestExpense)
    *  Summary         : Return EBITDACoverage of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal ebitda = EBITDA, 
                         Decimal netInterestExpense - Net Interest netInterestExpense
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnEBITDACoverageAnnual(Decimal ebitda, Decimal netInterestExpense) {
        try {
            if (ebitda == null) ebitda = 0;
            return (ebitda / ((-1) * netInterestExpense)).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnCurrentRatioAnnual(Decimal totalCurrentAssets, Decimal shortTermLiabilities)
    *  Summary         : Return current ratio of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal totalCurrentAssets - Total Current Assets, 
                         Decimal shortTermLiabilities - Short Term Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnCurrentRatioAnnual(Decimal totalCurrentAssets, Decimal shortTermLiabilities) {
        try {
            if (totalCurrentAssets == null) totalCurrentAssets = 0;
            return (totalCurrentAssets / shortTermLiabilities).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnQuickAcidRatioAnnual(Decimal totalCurrentAssets, Decimal stockMaterialWorkInProgress,
                                                     Decimal shortTermLiabilities)
    *  Summary         : Return quick "acid" ratio of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal totalCurrentAssets - Total Current Assets, 
                         Decimal stockMaterialWorkInProgress - Stock, material & work in progress,
                         Decimal shortTermLiabilities - Short Term Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnQuickAcidRatioAnnual(Decimal totalCurrentAssets, Decimal stockMaterialWorkInProgress,
                                                      Decimal shortTermLiabilities) {
        try {
            if (totalCurrentAssets == null) totalCurrentAssets = 0;
            if (stockMaterialWorkInProgress == null) stockMaterialWorkInProgress = 0;
            return ((totalCurrentAssets - stockMaterialWorkInProgress) / shortTermLiabilities).setScale(2);
        } catch (Exception e) {
            return null;
        }
    } 


    /*******************************************************************************
    *  Name            : returnWorkingCapitalAnnual(Decimal totalCurrentAssets, Decimal shortTermLiabilities)
    *  Summary         : Return Working Capital ratio of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : 25/01/2019
    *  Parameters      : Decimal totalCurrentAssets - Total Current Assets, 
                         Decimal shortTermLiabilities - Short Term Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnWorkingCapitalAnnual(Decimal totalCurrentAssets, Decimal shortTermLiabilities) {
        try {
            Decimal workingCapital = 0;
            if (totalCurrentAssets != null) {
                workingCapital += totalCurrentAssets;
            }
            if (shortTermLiabilities != null) {
                workingCapital -= shortTermLiabilities;
            }
            
            return workingCapital.setScale(0);
        } catch (Exception e) {
            return null;
        }
    } 


    /*******************************************************************************
    *  Name            : returnCashFlowRatioAnnual(Decimal calculatedCF, Decimal shortTermLiabilities)
    *  Summary         : Return Cash Flow Ratio ratio of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal calculatedCF - Calculated Cash Flow, 
                         Decimal shortTermLiabilities - Short Term Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnCashFlowRatioAnnual(Decimal calculatedCF, Decimal shortTermLiabilities) {
        try {
            return (calculatedCF / shortTermLiabilities).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnDSOInDaysAnnual(Decimal tradeDebtors, Decimal totalTurnOver)
    *  Summary         : Return DSO In Days ratio of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal tradeDebtors - Trade Debtors, 
                         Decimal totalTurnOver - Total Turn Over
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnDSOInDaysAnnual(Decimal tradeDebtors, Decimal totalTurnOver) {
        try {
            if (tradeDebtors == null) tradeDebtors = 0;
            return ((tradeDebtors * 360) / totalTurnOver).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnDPOInDaysAnnual(Decimal fromThatTradeCreditors, Decimal costOfGoodsSold)
    *  Summary         : Return DPO In Days ratio of the current year.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal fromThatTradeCreditors - From That Trade Creditors debt,  
                         Decimal costOfGoodsSold - Cost Of Goods Sold
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnDPOInDaysAnnual(Decimal fromThatTradeCreditors, Decimal costOfGoodsSold) {
        try {
            if (fromThatTradeCreditors == null) fromThatTradeCreditors = 0;
            return ((fromThatTradeCreditors * 360) / costOfGoodsSold).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTotalAssetsChange(Decimal currentTotalAssets, 
                                                 Decimal previousTotalAssets)
    *  Summary         : Return the difference between current and previous year of Total Assets.
    *  CreatedDate     : 06/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentTotalAssets - current year Total Fixed Assets, 
                         Decimal previousTotalAssets - previous year Total Fixed Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalAssetsChange(Decimal currentTotalAssets, 
                                                   Decimal previousTotalAssets) {
        try {
            return (currentTotalAssets / previousTotalAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTotalFixedAssetsChange(Decimal currentTotalFixedAssets, 
                                                      Decimal previousTotalFixedAssets)
    *  Summary         : Return the difference between current and previous year of Total Fixed Assets.
    *  CreatedDate     : 06/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentTotalFixedAssets - current year Total Fixed Assets, 
                         Decimal previousTotalFixedAssets - previous year Total Fixed Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalFixedAssetsChange(Decimal currentTotalFixedAssets, 
                                                        Decimal previousTotalFixedAssets) {
        try {
            return (currentTotalFixedAssets / previousTotalFixedAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnIntangibleFixedAssetsChange(Decimal currentIntangibleFixedAssets, 
                                                           Decimal previousIntangibleFixedAssets)
    *  Summary         : Return the difference between current and previous year of Intangible Fixed Assets.
    *  CreatedDate     : 06/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentIntangibleFixedAssets - current year Intangible Fixed Assets, 
                         Decimal previousIntangibleFixedAssets - previous year Intangible Fixed Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnIntangibleFixedAssetsChange(Decimal currentIntangibleFixedAssets, 
                                                             Decimal previousIntangibleFixedAssets) {
        try {
            return (currentIntangibleFixedAssets / previousIntangibleFixedAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTangibleFixedAssetsChange(Decimal currentTangibleFixedAssets, 
                                                         Decimal previousTangibleFixedAssets)
    *  Summary         : Return the difference between current and previous year of Tangible Fixed Assets. 
    *  CreatedDate     : 06/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentTangibleFixedAssets - current year Tangible Fixed Assets, 
                         Decimal previousTangibleFixedAssets - previous year Tangible Fixed Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTangibleFixedAssetsChange(Decimal currentTangibleFixedAssets, 
                                                           Decimal previousTangibleFixedAssets) {
        try {
            return (currentTangibleFixedAssets / previousTangibleFixedAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnFinancialLTAssetsChange(Decimal currentFinancialLTAssets, 
                                                         Decimal previousFinancialLTAssets)
    *  Summary         : Return the difference between current and previous year of Financial LT Assets.
    *  CreatedDate     : 06/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentFinancialLTAssets - current year Financial LT Assets, 
                         Decimal previousFinancialLTAssets - previous year Financial LT Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnFinancialLTAssetsChange(Decimal currentFinancialLTAssets, 
                                                         Decimal previousFinancialLTAssets) {
        try {
            return (currentFinancialLTAssets / previousFinancialLTAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTotalCurrentAssetsChange(Decimal currentTotalFixedAssets, 
                                                        Decimal previousTotalFixedAssets)
    *  Summary         : Return the difference between current and previous year of Total Current Assets.
    *  CreatedDate     : 05/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentTotalFixedAssets - current year Total Fixed Assets, 
                         Decimal previousTotalFixedAssets - previous year Total Fixed Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalCurrentAssetsChange(Decimal currentTotalFixedAssets, 
                                                          Decimal previousTotalFixedAssets) {
        try {
            return (currentTotalFixedAssets / previousTotalFixedAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnStockMaterialWorkInProgressChange(Decimal currentStockMaterialWorkInProgress, 
                                                                 Decimal previousStockMaterialWorkInProgress)
    *  Summary         : Return the difference between current and previous year of Stock Material Work In Progress.
    *  CreatedDate     : 05/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentStockMaterialWorkInProgress - current year Stock Material Work In Progress, 
                         Decimal previousStockMaterialWorkInProgress - previous year Stock Material Work In Progress
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnStockMaterialWorkInProgressChange(Decimal currentStockMaterialWorkInProgress, 
                                                                   Decimal previousStockMaterialWorkInProgress) {
        try {
            return (currentStockMaterialWorkInProgress / previousStockMaterialWorkInProgress).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTradeDebtorsChange(Decimal currentTradeDebtors, 
                                                  Decimal previousTradeDebtors)
    *  Summary         : Return the difference between current and previous year of Trade Debtors.
    *  CreatedDate     : 06/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentTradeDebtors - current year Trade Debtors, 
                         Decimal previousTradeDebtors - previous year Trade Debtors
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTradeDebtorsChange(Decimal currentTradeDebtors, 
                                                    Decimal previousTradeDebtors) {
        try {
            return (currentTradeDebtors / previousTradeDebtors).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnCashCashEquivalentChange(Decimal currentCashCashEquivalentChange, 
                                                        Decimal previousCashCashEquivalentChange)
    *  Summary         : Return the difference between current and previous year of Cash Cash Equivalent.
    *  CreatedDate     : 06/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentCashCashEquivalentChange - current year CashCashEquivalentChange,
                         Decimal previousCashCashEquivalentChange - previous year CashCashEquivalentChange
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnCashCashEquivalentChange(Decimal currentCashCashEquivalentChange, 
                                                          Decimal previousCashCashEquivalentChange) {
        try {
            return (currentCashCashEquivalentChange / previousCashCashEquivalentChange).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnOtherCurrentAssetsChange(Decimal currentOtherCurrentAssets, 
                                                        Decimal previousOtherCurrentAssets)
    *  Summary         : Return the difference between current and previous year of Other Current Assets.
    *  CreatedDate     : 06/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentOtherCurrentAssets - current year Other Current Assets,
                         Decimal previousOtherCurrentAssets - previous year Other Current Assets
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnOtherCurrentAssetsChange(Decimal currentOtherCurrentAssets, 
                                                          Decimal previousOtherCurrentAssets) {
        try {
            return (currentOtherCurrentAssets / previousOtherCurrentAssets).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTotalLiabilitiesChange(Decimal currentTotalLiabilities, 
                                                      Decimal previousTotalLiabilities)
    *  Summary         : Return the difference between current and previous year of Total Liabilities.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentTotalLiabilities - current year Total Liabilities,
                         Decimal previousTotalLiabilities - previous year Total Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalLiabilitiesChange(Decimal currentTotalLiabilities, 
                                                        Decimal previousTotalLiabilities) {
        try {
            return (currentTotalLiabilities / previousTotalLiabilities).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnNetWorthChange(Decimal currentNetWorth, 
                                              Decimal previousNetWorth)
    *  Summary         : Return the difference between current and previous year of Net Worth.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentNetWorth - current year Net Worth,
                         Decimal previousNetWorth - previous year Net Worth
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnNetWorthChange(Decimal currentNetWorth, 
                                                Decimal previousNetWorth) {
        try {
            return (currentNetWorth / previousNetWorth).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnReservesChange(Decimal currentReserve, 
                                              Decimal previousReserve)
    *  Summary         : Return the difference between current and previous year of Reserves
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentReserve - current year Reserve,
                         Decimal previousReserve - previous year Reserve
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnReservesChange(Decimal currentReserve, 
                                                Decimal previousReserve) {
        try {
            return (currentReserve / previousReserve).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnLiabilitiesChange(Decimal currentLiabilities, 
                                                 Decimal previousLiabilities)
    *  Summary         : Return the difference between current and previous year of Liabilities.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentLiabilities - current year Long Term Liabilities,
                         Decimal previousLiabilities - previous year Long Term Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnLiabilitiesChange(Decimal currentLiabilities, 
                                                   Decimal previousLiabilities) {
        try {
            return (currentLiabilities / previousLiabilities).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnLongTermLiabilitiesChange(Decimal currentLongTermLiabilities, 
                                                         Decimal previousLongTermLiabilities)
    *  Summary         : Return the difference between current and previous year of Long Term Liabilities.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentLongTermLiabilities - current year Long Term Liabilities,
                         Decimal previousLongTermLiabilities - previous year Long Term Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnLongTermLiabilitiesChange(Decimal currentLongTermLiabilities, 
                                                           Decimal previousLongTermLiabilities) {
        try {
            return (currentLongTermLiabilities / previousLongTermLiabilities).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnFromThatLTBankDebtChange(Decimal currentFromThatLTBankDebt, 
                                                        Decimal previousFromThatLTBankDebt)
    *  Summary         : Return the difference between current and previous year of Liabilities From That LT Bank Debt.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentFromThatLTBankDebt - current Liabilities From That LT Bank Debt,
                         Decimal previousFromThatLTBankDebt - previous Liabilities From That LT Bank Debt
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnFromThatLTBankDebtChange(Decimal currentFromThatLTBankDebt, 
                                                          Decimal previousFromThatLTBankDebt) {
        try {
            return (currentFromThatLTBankDebt / previousFromThatLTBankDebt).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnFromThatOtherLTLiabilitiesChange(Decimal currentFromThatOtherLTLiabilities, 
                                                                Decimal previousFromThatOtherLTLiabilities)
    *  Summary         : Return the difference between current and previous year of other LT Liabilities.
    *  CreatedDate     : 07/12/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentFromThatOtherLTLiabilities - current other LT Liabilities,
                         Decimal previousFromThatOtherLTLiabilities - previous other LT Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnFromThatOtherLTLiabilitiesChange(Decimal currentFromThatOtherLTLiabilities, 
                                                                  Decimal previousFromThatOtherLTLiabilities) {
        try {
            return (currentFromThatOtherLTLiabilities / previousFromThatOtherLTLiabilities).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnLeasingEngagementChange(Decimal currentLeasingEngagement, 
                                                       Decimal previousLeasingEngagement)
    *  Summary         : Return the difference between current and previous year of Leasing Engagement.
    *  CreatedDate     : 14/12/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentLeasingEngagement - current Leasing Engagement,
                         Decimal previousLeasingEngagement - previous Leasing Engagement
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnLeasingEngagementChange(Decimal currentLeasingEngagement, 
                                                         Decimal previousLeasingEngagement) {
        try {
            return (currentLeasingEngagement / previousLeasingEngagement).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnShortTermLiabilitiesChange(Decimal currentShortTermLiabilities, 
                                                          Decimal previousShortTermLiabilities)
    *  Summary         : Return the difference between current and previous year of Short Term Liabilities.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentShortTermLiabilities - current year Short Term Liabilities,
                         Decimal previousShortTermLiabilities - previous year Short Term Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnShortTermLiabilitiesChange(Decimal currentShortTermLiabilities, 
                                                            Decimal previousShortTermLiabilities) {
        try {
            return (currentShortTermLiabilities / previousShortTermLiabilities).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnFromThatTradeCreditorsChange(Decimal currentFromThatTradeCreditors, 
                                                            Decimal previousFromThatTradeCreditors)
    *  Summary         : Return the difference between current and previous year of Liabilities From 
                            That Trade Creditors Debt.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentFromThatTradeCreditors - current year Liabilities From That 
                            Trade Creditors Debt,
                         Decimal previousFromThatTradeCreditors - previous year Liabilities From That 
                            Trade Creditors Debt
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnFromThatTradeCreditorsChange(Decimal currentFromThatTradeCreditors, 
                                                              Decimal previousFromThatTradeCreditors) {
        try {
            return (currentFromThatTradeCreditors / previousFromThatTradeCreditors).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnFromThatSTBankDebtChange(Decimal currentFromThatSTBankDebt, 
                                                        Decimal previousFromThatSTBankDebt)
    *  Summary         : Return the difference between current and previous year of Liabilities 
                            From That ST Bank Debt.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentFromThatSTBankDebt - current year Liabilities From That ST Bank Debt,
                         Decimal previousFromThatSTBankDebt - previous year Liabilities From That ST Bank Debt
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnFromThatSTBankDebtChange(Decimal currentFromThatSTBankDebt, 
                                                          Decimal previousFromThatSTBankDebt) {
        try {
            return (currentFromThatSTBankDebt / previousFromThatSTBankDebt).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnFromThatOtherSTLiabilitiesChange(Decimal currentOthersSTLiabilities, Decimal previousOtherSTLiabilities)
    *  Summary         : Return the difference between current and previous year of Other ST Liabilities.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentOthersSTLiabilities - current year Other ST Liabilities,
                         Decimal previousOtherSTLiabilities - previous year Other ST Liabilities
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnFromThatOtherSTLiabilitiesChange(Decimal currentOthersSTLiabilities, Decimal previousOtherSTLiabilities) {
        try {
            return (currentOthersSTLiabilities / previousOtherSTLiabilities).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTotalTurnoverChange(Decimal currentTotalTurnover, Decimal previousTotalTurnover)
    *  Summary         : Return the difference between current and previous year of TotalTurnover.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentTotalTurnover - current year Total Turnover,
                         Decimal previousTotalTurnover - previous year Total Turnover
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTotalTurnoverChange(Decimal currentTotalTurnover, Decimal previousTotalTurnover) {
        try {
            return (currentTotalTurnover / previousTotalTurnover).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnTurnoverChange(Decimal currentTurnover, Decimal previousTurnover)
    *  Summary         : Return the difference between current and previous year of Turnover.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentTurnover - current year Turnover,
                         Decimal previousTurnover - previous year Turnover
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnTurnoverChange(Decimal currentTurnover, Decimal previousTurnover) {
        try {
            return (currentTurnover / previousTurnover).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnActivationChange(Decimal currentActivation, Decimal previousActivation)
    *  Summary         : Return the difference between current and previous year of Activation.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentActivation - current year Activation,
                         Decimal previousActivation - previous year Activation
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnActivationChange(Decimal currentActivation, Decimal previousActivation) {
        try {
            return (currentActivation / previousActivation).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnOtherOperationalIncomeChange(Decimal currentOtherOperationalIncome, 
                                                            Decimal previousOtherOperationalIncome)
    *  Summary         : Return the difference between current and previous year of Operational Income.
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentOtherOperationalIncome - current year Other Operational Income,
                         Decimal previousOtherOperationalIncome - previous year Other Operational Income
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnOtherOperationalIncomeChange(Decimal currentOtherOperationalIncome, 
                                                              Decimal previousOtherOperationalIncome) {
        try {
            return (currentOtherOperationalIncome / previousOtherOperationalIncome).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnCostOfGoodsSoldChange(Decimal currentCostOfGoodsSold, 
                                                     Decimal previousCostOfGoodsSold)
    *  Summary         : Return the difference between current and previous year of Cost Of Goods Sold.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentCostOfGoodsSold - current year Other Operational Income,
                         Decimal previousCostOfGoodsSold - previous year Other Operational Income
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnCostOfGoodsSoldChange(Decimal currentCostOfGoodsSold, 
                                                       Decimal previousCostOfGoodsSold) {
        try {
            return (currentCostOfGoodsSold / previousCostOfGoodsSold).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnGrossProfitLossChange(Decimal currentGrossProfitLoss, 
                                                     Decimal previousGrossProfitLostt)
    *  Summary         : Return the difference between current and previous year of Gross profit/loss.
    *  CreatedDate     : 25/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentGrossProfitLoss - current year Gross profit/loss,
                         Decimal previousGrossProfitLostt - previous year Gross profit/loss
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnGrossProfitLossChange(Decimal currentGrossProfitLoss, 
                                                       Decimal previousGrossProfitLostt) {
        try {
            return (currentGrossProfitLoss / previousGrossProfitLostt).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnDepreciationChange(Decimal currentDepreciation, Decimal previousDepreciation)
    *  Summary         : Return the difference between current and previous year of Operational Income.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentDepreciation - current year Other Operational Income,
                         Decimal previousDepreciation - previous year Other Operational Income
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnDepreciationChange(Decimal currentDepreciation, Decimal previousDepreciation) {
        try {
            return (currentDepreciation / previousDepreciation).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnIncomeAndOtherTaxesChange(Decimal currentIncomeAndOtherTaxes, Decimal previousIncomeAndOtherTaxes)
    *  Summary         : Return the difference between current and previous year of Income and other taxes.
    *  CreatedDate     : 25/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentIncomeAndOtherTaxes - current year Income and other taxes,
                         Decimal previousIncomeAndOTherTaxes - previous year Income and other taxes
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnIncomeAndOtherTaxesChange(Decimal currentIncomeAndOtherTaxes, Decimal previousIncomeAndOtherTaxes) {
        try {
            return (currentIncomeAndOtherTaxes / previousIncomeAndOtherTaxes).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnEBITFromCrefoChange(Decimal currentEBITFromCrefo, Decimal previousEBITFromCrefo)
    *  Summary         : Return the difference between current and previous year of EBIT from Crefo    
    *  CreatedDate     : 25/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentEBITFromCrefo - current year EBIT from Crefo, Decimal previousEBITFromCrefo - current year EBIT from Crefo
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnEBITFromCrefoChange(Decimal currentEBITFromCrefo, Decimal previousEBITFromCrefo) {
        try {
            return (currentEBITFromCrefo / previousEBITFromCrefo).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnOperationalProfitEBITChange(Decimal currentOperationalProfitEBIT, 
                                                           Decimal previousOperationalProfitEBIT)
    *  Summary         : Return the difference between current and previous year of Operational profit EBIT.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentOperationalProfitEBIT - current year Other Operational Income,
                         Decimal previousOperationalProfitEBIT - previous year Other Operational Income
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnOperationalProfitEBITChange(Decimal currentOperationalProfitEBIT, 
                                                             Decimal previousOperationalProfitEBIT) {
        try {
            return (currentOperationalProfitEBIT / previousOperationalProfitEBIT).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnEBITDAChange(Decimal currentEBITDA, Decimal previousEBITDA)
    *  Summary         : Return the difference between current and previous year of EBITDA.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentEBITDA - current year EBITDA,
                         Decimal previousEBITDA - previous year EBITDA
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnEBITDAChange(Decimal currentEBITDA, Decimal previousEBITDA) {
        try {
            return (currentEBITDA / previousEBITDA).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnCalculatedCFChange(Decimal currentCalculatedCF, Decimal previousCalculatedCF)
    *  Summary         : Return the difference between current and previous year of Calculated CF.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentCalculatedCF - current year EBITDA,
                         Decimal previousCalculatedCF - previous year EBITDA
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnCalculatedCFChange(Decimal currentCalculatedCF, Decimal previousCalculatedCF) {
        try {
            return (currentCalculatedCF / previousCalculatedCF).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnFinancialIncomeChange(Decimal currentFinancialIncome, Decimal previousFinancialIncome)
    *  Summary         : Return the difference between current and previous year of FinancialIncome.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentFinancialIncome - current year Financial Income,
                         Decimal previousFinancialIncome - previous year Financial Income
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnFinancialIncomeChange(Decimal currentFinancialIncome, Decimal previousFinancialIncome) {
        try {
            return (currentFinancialIncome / previousFinancialIncome).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnFinancialChargesChange(Decimal currentFinancialCharges, Decimal previousFinancialCharges)
    *  Summary         : Return the difference between current and previous year of Financial Charges.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentFinancialCharges - current year Financial Charges,
                         Decimal previousFinancialCharges - previous year Financial Charge
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnFinancialChargesChange(Decimal currentFinancialCharges, Decimal previousFinancialCharges) {
        try {
            return (currentFinancialCharges / previousFinancialCharges).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnNetInterestExpenseChange(Decimal currentFinancialCharges, 
                                                        Decimal previousFinancialCharges)
    *  Summary         : Return the difference between current and previous year of Financial Charges.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentFinancialCharges - current year Financial Charges,
                         Decimal previousFinancialCharges - previous year Financial Charges
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnNetInterestExpenseChange(Decimal currentFinancialCharges, 
                                                          Decimal previousFinancialCharges) {
        try {
            return (currentFinancialCharges / previousFinancialCharges).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnEATChange(Decimal currentEAT, Decimal previousEAT)
    *  Summary         : Return the difference between current and previous year of EAT.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentEAT - current year EAT,
                         Decimal previousEAT - previous year EAT
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnEATChange(Decimal currentEAT, Decimal previousEAT) {
        try {
            return (currentEAT / previousEAT).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnExtraordinaryItemsChange(Decimal currentExtraordinaryItems, 
                                                        Decimal previousExtraordinaryItems)
    *  Summary         : Return the difference between current and previous year of Extraordinary Items.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentExtraordinaryItems - current year Extraordinary Items,
                         Decimal previousExtraordinaryItems - previous year Extraordinary Items
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnExtraordinaryItemsChange(Decimal currentExtraordinaryItems, 
                                                          Decimal previousExtraordinaryItems) {
        try {
            return (currentExtraordinaryItems / previousExtraordinaryItems).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnExceptionalIncomeChange(Decimal currentExceptionalIncome, 
                                                       Decimal previousExceptionalIncome)
    *  Summary         : Return the difference between current and previous year of Exceptional Income.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentExceptionalIncome - current year Exceptional Income,
                         Decimal previousExceptionalIncome - previous year Exceptional Income
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnExceptionalIncomeChange(Decimal currentExceptionalIncome, 
                                                         Decimal previousExceptionalIncome) {
        try {
            return (currentExceptionalIncome / previousExceptionalIncome).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnExceptionalChargesChange(Decimal currentExceptionalCharges, 
                                                        Decimal previousExceptionalCharges)
    *  Summary         : Return the difference between current and previous year of Exceptional Charges.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentExceptionalCharges - current year Exceptional Charges,
                         Decimal previousExceptionalCharges - previous year Exceptional Charges
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnExceptionalChargesChange(Decimal currentExceptionalCharges, 
                                                          Decimal previousExceptionalCharges) {
        try {
            return (currentExceptionalCharges / previousExceptionalCharges).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnExceptionalItemsTotalChange(Decimal currentExceptionalItemsTotal, 
                                                           Decimal previousExceptionalItemsTotal)
    *  Summary         : Return the difference between current and previous year of Exceptional Items Total.
    *  CreatedDate     : 10/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentExceptionalItemsTotal - current year Exceptional Items Total,
                         Decimal previousExceptionalItemsTotal - previous year Exceptional Items Total
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnExceptionalItemsTotalChange(Decimal currentExceptionalItemsTotal, 
                                                             Decimal previousExceptionalItemsTotal) {
        try {
            return (currentExceptionalItemsTotal / previousExceptionalItemsTotal).setScale(2);
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnROARS(Decimal roa)
    *  Summary         : Return RS of ROA (calculation includes taxes x D&B).
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal roa - ROA (calculation includes taxes x D&B) of the current year
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnROARS(Decimal roa) {
        try {
            if (roa >= 0.2) {
                return 1;
            } else if (roa >= 0.1) {
                return 2;
            } else if (roa >= 0.05) {
                return 3;
            } else if (roa >= 0.01) {
                return 4;
            } else if (roa >= -0.01) {
                return 5;
            } else if (roa >= -99999999) {
                return 6;
            } else {
                return null;
            } 
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnLeverageRS(Decimal leverage)
    *  Summary         : Return RS of Leverage.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal leverage - ROA (calculation includes taxes x D&B) of the current year
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnLeverageRS(Decimal leverage) {
        try {
            if (leverage >= 0.95) {
                return 6;
            } else if (leverage >= 0.8) {
                return 5;
            } else if (leverage >= 0.75) {
                return 4;
            } else if (leverage >= 0.5) {
                return 3;
            } else if (leverage >= 0.2) {
                return 2;
            } else if (leverage >= -99999999) {
                return 1;
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnDebtToEBITDARS(Decimal debtToEBITDA)
    *  Summary         : Return RS of Debt To EBITDA.
    *  CreatedDate     : 12/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal debtToEBITDA - Debt To EBITDA of the current year
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnDebtToEBITDARS(Decimal debtToEBITDA) {
        try {
            if (debtToEBITDA >= 7.9) {
                return 6;
            } else if (debtToEBITDA >= 5.1) {
                return 5;
            } else if (debtToEBITDA >= 3) {
                return 4;
            } else if (debtToEBITDA >= 2.3) {
                return 3;
            } else if (debtToEBITDA >= 1.5) {
                return 2;
            } else if (debtToEBITDA >= 0) {
                return 1;
            } else if (debtToEBITDA >= -99999999) {
                return 6;
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnEBITDACoverageRS(Decimal ebitdaCoverage)
    *  Summary         : Return RS of EBITDA Coverage.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal ebitdaCoverage - EBITDA Coverage
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnEBITDACoverageRS(Decimal ebitdaCoverage) {
        try {
            if (ebitdaCoverage >= 13.3) {
                return 1;
            } else if (ebitdaCoverage >= 7.8) {
                return 2;
            } else if (ebitdaCoverage >= 5.2) {
                return 3;
            } else if (ebitdaCoverage >= 2.2) {
                return 4;
            } else if (ebitdaCoverage >= 0.9) {
                return 5;
            } else if (ebitdaCoverage >= 0) {
                return 6;
            } else if (ebitdaCoverage >= -99999999) {
                return 1;
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnCurrentRatioRS(Decimal currentRatio)
    *  Summary         : Return RS of Current Ratio.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal currentRatio - Current Ratio
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnCurrentRatioRS(Decimal currentRatio) {
        try {
            if (currentRatio >= 2.9) {
                return 1;
            } else if (currentRatio >= 2) {
                return 2;
            } else if (currentRatio >= 1.1) {
                return 3;
            } else if (currentRatio >= 0.8) {
                return 4;
            } else if (currentRatio >= 0.5) {
                return 5;
            } else if (currentRatio >= -99999999) {
                return 6;
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnCashFlowRatioRS(Decimal cashFlowRatio)
    *  Summary         : Return RS of Cash Flow Ratio.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal cashFlowRatio - Cash Flow Ratio
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnCashFlowRatioRS(Decimal cashFlowRatio) {
        try {
            if (cashFlowRatio >= 0.6) {
                return 1;
            } else if (cashFlowRatio >= 0.4) {
                return 2;
            } else if (cashFlowRatio >= 0.2) {
                return 3;
            } else if (cashFlowRatio >= 0.05) {
                return 4;
            } else if (cashFlowRatio >= -0.05) {
                return 5;
            } else if (cashFlowRatio >= -99999999) {
                return 6;
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnDPOInDaysRS(Decimal dpoInDays)
    *  Summary         : Return RS of DSO In Days.
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal dpoInDays - Cash Flow Ratio
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnDPOInDaysRS(Decimal dpoInDays) {
        try {
            if (dpoInDays >= 999999) {
                return 6;
            } else if (dpoInDays >= 90) {
                return 5;
            } else if (dpoInDays >= 70) {
                return 4;
            } else if (dpoInDays >= 40) {
                return 3;
            } else if (dpoInDays >= 20) {
                return 2;
            } else if (dpoInDays >= 0) {
                return 1;
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnOverallScoreRS(Decimal roa, Decimal leverage, Decimal debtToEBITDA, 
                                                  Decimal ebitdaCoverage, Decimal currentRatio, 
                                                  Decimal cashFlowRatio, Decimal dpoInDays)
    *  Summary         : Return RS of DSO In Days.
    *  CreatedDate     : 13/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal roa - ROA (calculation includes taxes x D&B), Decimal leverage - Leverage,
                         Decimal debtToEBITDA - Debt To EBITDA, Decimal ebitdaCoverage - EBITDA Coverage, 
                         Decimal currentRatio - Current Ratio, Decimal cashFlowRatio - Cash Flow Ratio, 
                         Decimal dpoInDays - DPO In Days
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal returnOverallScoreRS(Decimal roa, Decimal leverage, Decimal debtToEBITDA, 
                                                Decimal ebitdaCoverage, Decimal currentRatio, 
                                                Decimal cashFlowRatio, Decimal dpoInDays) {
        try {
            Decimal summary = 0;
            Integer numberOfParameters = 0;
            if (roa != null) {
                summary += roa;
                numberOfParameters ++;
            }
            if (leverage != null) {
                summary += leverage;
                numberOfParameters ++;
            }
            if (debtToEBITDA != null) {
                summary += debtToEBITDA;
                numberOfParameters ++;
            }
            if (ebitdaCoverage != null) {
                summary += ebitdaCoverage;
                numberOfParameters ++;
            }
            if (currentRatio != null) {
                summary += currentRatio;
                numberOfParameters ++;
            }
            if (cashFlowRatio != null) {
                summary += cashFlowRatio;
                numberOfParameters ++;
            }
            if (dpoInDays != null) {
                summary += dpoInDays;
                numberOfParameters ++;
            }

            return (summary / numberOfParameters).round(System.RoundingMode.HALF_UP);
        } catch (Exception e) {
            return null;
        }
    }
}