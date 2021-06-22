public with sharing class BRSettingWrapper {
    public Id id;
    public String name;
    public Boolean isActive;
    public String sObjectName;
    public String sObjectStatus;
    public List<BRCase> cases = new List<BRCase>();

    public class BRCase {
        public Id id;
        public Integer caseNumber;
        public String name;
        public String filterLogic;
        public Id settingId;
        public List<BRFilter> filters = new List<BRFilter>();
    }

    public class BRFilter {
        public Id id;
        public Id caseId;
        public String filterNumber;
        public String condition;
        public String field;
        public String fieldType;
        public String fieldValue;
    }
}
