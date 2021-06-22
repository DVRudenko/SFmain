/**
 * Created by Andrei.Moiseev on 05.04.2018.
 */

global class NetStartVolumeReportEESchedulable implements Schedulable {

    public final static String CRON_EXP = '0 30 23 ? * WED';

    global void execute(SchedulableContext sc) {

        Date dateFrom = Date.Today();
        Date dateTo = Date.Today();
        List<Fleetcor_Calendar_Month__c> periodsFleetCor = ([
                SELECT Start_Date__c, End_Date__c
                FROM Fleetcor_Calendar_Month__c
                WHERE End_Date__c <= :dateTo
                ORDER BY Start_Date__c
                LIMIT 4
        ]);

        if ( ! periodsFleetCor.isEmpty() ) {

            Set<String> setOfEmails = new Set<String>();
            for (RU_Onboarding_Report_EE_Emails__c item : [SELECT Name FROM RU_Onboarding_Report_EE_Emails__c]) {
                setOfEmails.add(item.Name);
            }

            if ( ! setOfEmails.isEmpty() ) {
                dateFrom = periodsFleetCor.get(periodsFleetCor.size() - 1).Start_Date__c;
                NetStartsVolumeProcessor processor = new NetStartsVolumeProcessor();
                NetStartsVolumeProcessor.NetStartsVolumeReportApi reportApi = processor.getReportApi(
                        NetStartVolumeReportSettings.BusinessType.EastEurope,
                        NetStartVolumeReportSettings.ReportType.Onboarding,
                        new List<String>(setOfEmails)
                );

                reportApi.setDefaultParametersToReportSettings('dateFrom', new List<Object>{ dateFrom });
                reportApi.setDefaultParametersToReportSettings('dateTo', new List<Object>{ dateTo });
                reportApi.sendExcelReportToEmail();
            } else {
                throw new NetStartVolumeReportEESchedulableException('Does not have emails for notification.');
            }
        }
    }

    public class NetStartVolumeReportEESchedulableException extends Exception {}
}