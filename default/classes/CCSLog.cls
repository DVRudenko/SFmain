/**
 * Created by marekhaken on 26/08/2020.
 */

public class CCSLog {

    Boolean debug = true;
    Boolean saveData = true;
    Boolean postpone = true;
    Boolean err = true;
    CCS_Log__c[] buffer = new List<CCS_Log__c>();

    public CCSLog() {
    }

    public CCSLog(Boolean setDebug, Boolean setPostpone) {
        debug = setDebug;
        postpone = setPostpone;
    }

    public void setDebug(Boolean value) {
        debug = value;
    }

    public void setData(Boolean value) {
        saveData = value;
    }

    public void setPostpone(Boolean value) {
        if (!value) {
            flush();
        }
        postpone = value;
    }

    public void flush() {
        insert buffer;
        buffer.clear();
        err = true;
    }

    private void addRecord(Datetime timestamp, String source, String level, String message, String data) {
        if (debug || level != 'Debug') {
            if (saveData || level != 'Data') {
                CCS_Log__c log = new CCS_Log__c(Timestamp__c = timestamp, Level__c = level);
                if (source != null) {
                    log.Source__c = source.left(80);
                }
                if (message != null) {
                    log.Message__c = message.left(1024);
                }
                if (data != null) {
                    log.Data__c = data.left(8192);
                }
                if (postpone) {
                    if (buffer.size() < 500) {
                        buffer.add(log);
                    } else {
                        if (err) {
                            log = new CCS_Log__c(Timestamp__c = timestamp, Source__c = 'Log', Level__c = 'Error', Message__c = 'Limit reached', Data__c = '');
                            buffer.add(log);
                            err = false;
                        }
                    }
                } else {
                    insert log;
                }
            }
        }
    }

    private void addRecord(String source, String level, String message, String data) {
        addRecord(Datetime.now(), source, level, message, data);
    }

//    Log

    public void add(Datetime timestamp, String source, String level, String message, String data) {
        addRecord(timestamp, source, level, message, data);
    }

    public void add(String source, String level, String message, String data) {
        addRecord(source, level, message, data);
    }

//    Debug

    public void addDebug(String source, String message, String data) {
        addRecord(source, 'Debug', message, data);
    }

    public void addDebug(String source, String message) {
        addRecord(source, 'Debug', message, null);
    }

    public void addDebug(String source, Date value) {
        addRecord(source, 'Debug', String.valueOf(value), null);
    }

    public void addDebug(String source, Datetime value) {
        addRecord(source, 'Debug', String.valueOf(value), null);
    }

    public void addDebug(String source, Decimal value) {
        addRecord(source, 'Debug', String.valueOf(value), null);
    }

    public void addDebug(String source, Double value) {
        addRecord(source, 'Debug', String.valueOf(value), null);
    }

    public void addDebug(String source, Integer value) {
        addRecord(source, 'Debug', String.valueOf(value), null);
    }

    public void addDebug(String source, Long value) {
        addRecord(source, 'Debug', String.valueOf(value), null);
    }

//    Info

    public void addInfo(String source, String message, String data) {
        addRecord(source, 'Info', message, data);
    }

    public void addInfo(String source, String message) {
        addRecord(source, 'Info', message, null);
    }

//    Warning

    public void addWarning(String source, String message, String data) {
        addRecord(source, 'Warning', message, data);
    }

    public void addWarning(String source, String message) {
        addRecord(source, 'Warning', message, null);
    }

//    Error

    public void addError(String source, String message, String data) {
        addRecord(source, 'Error', message, data);
    }

    public void addError(String source, String message) {
        addRecord(source, 'Error', message, null);
    }

//    Critical

    public void addCritical(String source, String message, String data) {
        addRecord(source, 'Critical', message, data);
    }

    public void addCritical(String source, String message) {
        addRecord(source, 'Critical', message, null);
    }

//    Data

    public void addData(String source, String message, String data) {
        addRecord(source, 'Data', message, data);
    }

//    Static Methods

    private static String trim(String str, Integer len) {
        if (str == null) {
            return null;
        }
        return str.left(len);
    }

    private static void writeRecord(Datetime timestamp, String source, String level, String message, String data) {
        CCS_Log__c log = new CCS_Log__c();
        log.Timestamp__c = timestamp;
        log.Source__c = trim(source, 80);
        log.Level__c = level;
        log.Message__c = trim(message, 1024);
        log.Data__c = trim(data, 8192);
        insert log;
    }

    private static void writeRecord(String source, String level, String message, String data) {
        writeRecord(Datetime.now(), source, level, message, data);
    }

//    Log

    public static void write(Datetime timestamp, String source, String level, String message, String data) {
        CCSLog.writeRecord(timestamp, source, level, message, data);
    }

    public static void write(String source, String level, String message, String data) {
        CCSLog.writeRecord(source, level, message, data);
    }

//    Debug

    public static void writeDebug(String source, String message, String data) {
        CCSLog.writeRecord(source, 'Debug', message, data);
    }

    public static void writeDebug(String source, String message) {
        CCSLog.writeRecord(source, 'Debug', message, null);
    }

    public static void writeDebug(String source, Date value) {
        CCSLog.writeRecord(source, 'Debug', String.valueOf(value), null);
    }

    public static void writeDebug(String source, Datetime value) {
        CCSLog.writeRecord(source, 'Debug', String.valueOf(value), null);
    }

    public static void writeDebug(String source, Decimal value) {
        CCSLog.writeRecord(source, 'Debug', String.valueOf(value), null);
    }

    public static void writeDebug(String source, Double value) {
        CCSLog.writeRecord(source, 'Debug', String.valueOf(value), null);
    }

    public static void writeDebug(String source, Integer value) {
        CCSLog.writeRecord(source, 'Debug', String.valueOf(value), null);
    }

    public static void writeDebug(String source, Long value) {
        CCSLog.writeRecord(source, 'Debug', String.valueOf(value), null);
    }

//    Info

    public static void writeInfo(String source, String message, String data) {
        CCSLog.writeRecord(source, 'Info', message, data);
    }

    public static void writeInfo(String source, String message) {
        CCSLog.writeRecord(source, 'Info', message, null);
    }

//    Warning

    public static void writeWarning(String source, String message, String data) {
        CCSLog.writeRecord(source, 'Warning', message, data);
    }

    public static void writeWarning(String source, String message) {
        CCSLog.writeRecord(source, 'Warning', message, null);
    }

//    Error

    public static void writeError(String source, String message, String data) {
        CCSLog.writeRecord(source, 'Error', message, data);
    }

    public static void writeError(String source, String message) {
        CCSLog.writeRecord(source, 'Error', message, null);
    }

//    Critical

    public static void writeCritical(String source, String message, String data) {
        CCSLog.writeRecord(source, 'Critical', message, data);
    }

    public static void writeCritical(String source, String message) {
        CCSLog.writeRecord(source, 'Critical', message, null);
    }

//    Data

    public static void writeData(String source, String message, String data) {
        CCSLog.writeRecord(source, 'Data', message, data);
    }
}