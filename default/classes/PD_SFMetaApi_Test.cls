/**
 * Created by pgolyakov on 2019-07-25.
 */
@isTest
private class PD_SFMetaApi_Test {

    @isTest static void testReadMeta() {
        Test.setMock(HttpCalloutMock.class, new PD_MetaDataCacheController_MOCK());
        PD_SFMetaApi asmetaapi = new PD_SFMetaApi();
        asmetaapi.readMeta('type', new String[]{
                'member1', 'member2'
        });
    }

    @isTest static void testListMeta() {
        Test.setMock(HttpCalloutMock.class, new PD_MetaDataCacheController_MOCK());
        PD_SFMetaApi asmetaapi = new PD_SFMetaApi();
        asmetaapi.listMeta('type');
    }

    @isTest static void testSoapFaultException() {
        try { throw new PD_SoapFaultException('<faultstring>'); } catch (Exception ex) {}
        try { throw new PD_Exception('<faultstring>'); } catch (Exception ex) {}

    }
}