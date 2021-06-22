global class SparkRisksReportXML {
    public String sparkID { get; set; }
    public String shortName { get; set; }
    public String fullName { get; set; }
    public String inn { get; set; }
    public String kpp { get; set; }
    public String ogrn { get; set; }
    public String okpo { get; set; }
    public StatusClass status { get; set; }
    public String dateFirstReg { get; set; }
    public RiskFactors riskFactors { get; set; }
    public FrozenAccounts frozenAccounts { get; set; }

    public class StatusClass {
        public Boolean isActing { get; set; }
        public Long code { get; set; }
        public String text { get; set; }
        public Integer groupId { get; set; }
        public String groupName { get; set; }
        public String date_x { get; set; }
    }

    public class AddInfoClass {
        public List<AddFieldClass> addField { get; set; }
    }

    public class AddFieldClass {
        public String value { get; set; }
        public String name { get; set; }
    }

    public class RiskFactors {
        public List<FactorClass> factor { get; set; }
    }

    public class FactorClass {
        public Long id { get; set; }
        public String name { get; set; }
        public List<AddInfoClass> addInfo { get; set; }
    }

    public class FrozenAccounts {
        public List<DecisionClass> decision { get; set; }
    }

    public class DecisionClass {
        public String number_x { get; set; }
        public String date_x { get; set; }
        public TaxAuthorityClass taxAuthority { get; set; }
        public BankClass bank { get; set; }
    }

    public class TaxAuthorityClass {
        public String code { get; set; }
        public String name { get; set; }
    }

    public class BankClass {
        public String bik { get; set; }
        public String sparkId { get; set; }
        public String name { get; set; }
    }

}