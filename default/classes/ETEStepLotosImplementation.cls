public class ETEStepLotosImplementation extends ETEStepBaseImplementation {

    public override void setDealStatusesForNextStep(ETEDatabaseInterface e2eDatabase,
                                                    String nextAvailableStep,
                                                    List<String> availableStepsForCustomerList,
                                                    List<String> availableStepsList,
                                                    Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap) {
        if (finalTransitionStatus != null && finalTransitionStatus.contains('stop process')) {
            this.existingDataObject.put('E2E_Status__c', 'Finished');
            this.existingDataObject.put('StageName__c', finalTransitionStatus.substringAfter(':'));
            this.existingDataObject.put('E2E_Finish_Details__c', 'Order Submitted');
        } else if (finalTransitionStatus == 'order submitted') {
            this.existingDataObject.put('E2E_Status__c', 'Finished');
            this.existingDataObject.put('E2E_Finish_Details__c', 'Order Submitted');
            this.existingDataObject.put('StageName__c', 'Negotiate');
        } else if (finalTransitionStatus == 'order finished') {
            this.existingDataObject.put('E2E_Status__c', 'Finished');
            if (availableStepsForCustomerList.size() == availableStepsList.size()) {
                if (existingDataObject.Security_Amount_To_Pay__c == null ||
                        existingDataObject.Security_Amount_To_Pay__c == 0) {
                    this.existingDataObject.put('StageName__c', 'Closed Won');
                    this.existingDataObject.put('E2E_Finish_Details__c', 'Order Completed');
                    finalTransitionStatus = 'order completed';
                }
            } else {
                this.existingDataObject.put('StageName__c', 'Negotiate');
                this.existingDataObject.put('E2E_Finish_Details__c', 'Order Submitted');
                finalTransitionStatus = 'order submitted';
            }
        } else {
            this.existingDataObject.put('E2E_Status__c', 'In progress');
            if (this.existingDataObject.Credit_Limit__c == null) {
                if (this.existingDataObject.Current_Step__c == 'additional_services') {
                    this.existingDataObject.put('StageName__c', 'Propose');
                } else {
                    this.existingDataObject.put('StageName__c', 'Qualify');
                }
            } else {
                this.existingDataObject.put('StageName__c', 'Negotiate');
            }
            if (this.existingDataObject.Current_Step__c != nextAvailableStep) {
                this.existingDataObject.put('Current_Step__c', nextAvailableStep);
            }
        }
        e2eDatabase.upsertDataObject(this.existingDataObject);
    }


    public override void setPayLaterDealStatus(ETEDatabaseInterface e2eDatabase) {
        this.existingDataObject.E2E_Status__c = 'Finished';
        this.existingDataObject.StageName__c = 'Negotiate';
        this.existingDataObject.E2E_Finish_Details__c = 'Awaiting Payment';
        e2eDatabase.upsertDataObject(this.existingDataObject);
    }
}