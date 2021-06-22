public class CallLogRu  {

    public List<Log> logs;

    public class Log implements Comparable {
        public String recordId;
        public String phoneNumber;
        public String statusValue;
        public String statusDate;
        public String statusDateTimeZone;
        public String caseStatus;
        public String finisheddate;
        public String authortitle;
        public DateTime finisheddateFormatted {get {return finisheddateFormatted == null ? getDateTimeFormatted (finisheddate) : finisheddateFormatted;} set;}

        public Integer compareTo(Object compareTo) {
            CallLogRu.Log compareToSObject = (CallLogRu.Log)compareTo;
            if(compareToSObject.statusDate < statusDate){
                return 1;
            } else {
                return -1;
            }
        }
        private DateTime getDateTimeFormatted (String dateTimeStr) {
            DateTime ret;
            try {
                ret = DateTime.valueof(dateTimeStr.replace('T', ' '));
            } catch (Exception ex) {}
            return ret;
        }
    }

    public static CallLogRu parse(String json) {
        CallLogRu ret = (CallLogRu) System.JSON.deserialize(json, CallLogRu.class);
        return ret;
    }

}