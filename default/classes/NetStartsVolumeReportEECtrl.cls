/**
 * Created by Andrei.Moiseev on 29.01.2018.
 */

public without sharing class NetStartsVolumeReportEECtrl {

    public NetStartsVolumeProcessor.NetStartsVolumeReportApi reportApi { get; private set; }

    private NetStartsVolumeProcessor processor;

    public NetStartsVolumeReportEECtrl() {
        this.processor = new NetStartsVolumeProcessor();
        this.reportApi = processor.getReportApi(
                NetStartVolumeReportSettings.BusinessType.EastEurope,
                NetStartVolumeReportSettings.ReportType.Onboarding,
                new List<String>{
                        UserInfo.getUserEmail()
                }
        );
    }

    /*******************************************************************************
    *  Name            : passFilterParams()
    *  Summary         : update content with new filter parameters
    *  CreatedDate     : 29/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void passFilterParams() {
        try {
            String filterParams = ApexPages.CurrentPage().getParameters().get('filterParams');

            if (filterParams != null) {
                this.reportApi.refreshContent(filterParams);
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
        }
    }
}