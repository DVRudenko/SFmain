/**
 * Created by Nikita.Mikhailov on 28.01.2019.
 */

public with sharing class GFNI_OpportunityLogReportCtrl {
    private ApexPages.StandardController controller { get; set; }
    private GFNI_LogDAO logDAO;
    public String currentId { get; set; }

    public List<GFNI_Opportunity_log__b> logs { get; set; }

    //created for UnitTests
    public GFNI_OpportunityLogReportCtrl(GFNI_LogDAO logDAO) {
        this.logDAO = logDAO;

        init();
    }

    public GFNI_OpportunityLogReportCtrl(ApexPages.StandardController controller) {
        this.logDAO = new GFNI_LogDAO();
        this.controller = controller;

        init();
    }

    public void init() {
        this.currentId = ApexPages.currentPage().getParameters().get('id');

        if (!String.isNotBlank(this.currentId)) {
            this.logs = new List<GFNI_Opportunity_log__b>();
            return;
        }

        Opportunity opportunity = [
                SELECT Id, CreatedDate, CloseDate
                FROM Opportunity
                WHERE Id = :this.currentId
        ];

        List<GFNI_Opportunity_log__b> allLogs = this.logDAO.queryLog(opportunity.CreatedDate.addDays(-1).date(), opportunity.CloseDate.addDays(30));

        this.logs = new List<GFNI_Opportunity_log__b>();

        for (GFNI_Opportunity_log__b log : allLogs) {
            if (log.Opportunity__c == opportunity.Id) {
                this.logs.add(log);
            }
        }
    }
}