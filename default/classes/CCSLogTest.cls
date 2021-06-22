/**
 * Created by marekhaken on 26/08/2020.
 */

@isTest
private class CCSLogTest {

    @isTest static void testAll() {
        CCSLog log0 = new CCSLog();
        CCSLog log1 = new CCSLog(true, true);

        Integer cnt = [SELECT count() FROM CCS_Log__c];

        CCSLog.write(Datetime.now(), 'Test', 'Info', 'Test Message', 'Test Data');
        CCSLog.write('Test', 'Info', 'Test Message', 'Test Data');
        CCSLog.writeDebug('Test', 'Test Message', 'Test Data');
        CCSLog.writeDebug('Test', 'Test Message');
        CCSLog.writeDebug('Test', Date.today());
        CCSLog.writeDebug('Test', Datetime.now());
        CCSLog.writeDebug('Test', (Decimal)123.45);
        CCSLog.writeDebug('Test', (Double)123.456);
        CCSLog.writeDebug('Test', 12);
        CCSLog.writeDebug('Test', (Long)123456789);
        CCSLog.writeInfo('Test', 'Test Message', 'Test Data');
        CCSLog.writeInfo('Test', 'Test Message');
        CCSLog.writeWarning('Test', 'Test Message', 'Test Data');
        CCSLog.writeWarning('Test', 'Test Message');
        CCSLog.writeError('Test', 'Test Message', 'Test Data');
        CCSLog.writeError('Test', 'Test Message');
        CCSLog.writeCritical('Test', 'Test Message', 'Test Data');
        CCSLog.writeCritical('Test', 'Test Message');
        CCSLog.writeData('Test', 'Test Message', 'Test Data');

        cnt = [SELECT count() FROM CCS_Log__c];
        System.assertEquals(19, cnt, 'Test failed');

        log1.add(Datetime.now(), 'Test', 'Info', 'Test Message', 'Test Data');
        log1.add('Test', 'Info', 'Test Message', 'Test Data');
        log1.addDebug('Test', 'Test Message', 'Test Data');
        log1.addDebug('Test', 'Test Message');
        log1.addDebug('Test', Date.today());
        log1.addDebug('Test', Datetime.now());
        log1.addDebug('Test', (Decimal)123.45);
        log1.addDebug('Test', (Double)123.456);
        log1.addDebug('Test', 12);
        log1.addDebug('Test', (Long)123456789);
        log1.setPostpone(false);

        cnt = [SELECT count() FROM CCS_Log__c];
        System.assertEquals(29, cnt, 'Test failed');

        log1.addInfo('Test', 'Test Message', 'Test Data');
        log1.addInfo('Test', 'Test Message');
        log1.addWarning('Test', 'Test Message', 'Test Data');
        log1.addWarning('Test', 'Test Message');
        log1.addError('Test', 'Test Message', 'Test Data');
        log1.addError('Test', 'Test Message');
        log1.addCritical('Test', 'Test Message', 'Test Data');
        log1.addCritical('Test', 'Test Message');
        log1.addData('Test', 'Test Message', 'Test Data');
        log1.flush();

        cnt = [SELECT count() FROM CCS_Log__c];
        System.assertEquals(38, cnt, 'Test failed');

        log1.setDebug(false);
        log1.addDebug('Test', 'Test Message', 'Test Data');

        cnt = [SELECT count() FROM CCS_Log__c];
        System.assertEquals(38, cnt, 'Test failed');

        log1.setData(true);
    }
}