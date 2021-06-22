public without sharing class Naumen_SoftphoneController {
    /*******************************************************************************
    *  Name            : getRecord
    *  Summary         : finds sf record of the call (Lead, Opportunity) by Naumen UUID and related Contact for Opportunity by phone number passed in the params, returns record wrapper for Naumen Softphone
    *  Parameters      : String callCustomerId - id ofthe Lead/Contact record, String phoneNumber - current call phone number
    *  Returns         : Map<String,Object>: result attribute name => result attribute value
    ******************************************************************************/
    @RemoteAction
    public static Map<String,Object> getRecord (String recordNaumenUUID, String phoneNumber) {
        return Naumen_RecordsHelper.getRecord (recordNaumenUUID, phoneNumber);
    }
    /*******************************************************************************
    *  Name            : setCallCustomer
    *  Summary         : finds call customer record (Contact) by id passed in the params
    *  Parameters      : String callCustomerId - id of the Contact record, String phoneNumber - phone number of the Contact record (current call phone number in the softphone)
    *  Returns         : Map<String,Object>: result attribute name => result attribute value
    ******************************************************************************/
    @RemoteAction
    public static Map<String,Object> setCallCustomer (String callCustomerId, String phoneNumber) {
        return Naumen_RecordsHelper.setCallCustomer (callCustomerId, phoneNumber);
    }
    /* not used now since we use naumen softphone on ccspeedup page only, where saving of the record is going on the operator console side
    * use this method to update Lead/Opportunity record from softphone if saveCustomerCallInfo param in NaumenSoftphoneJS is set as true
    @RemoteAction
    public static Map<String,Object> saveCallData (String callData) {
        return Naumen_RecordsHelper.saveCallData (callData);
    }
    */
}