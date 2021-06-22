global class SparkArbitrationSummary {
    public String sparkID { get; set; }
    public String shortName { get; set; }
    public String inn { get; set; }
    public String ogrn { get; set; }
    public String okpo { get; set; }
    public String okato { get; set; }
    public StatusClass status { get; set; }
    public ArbitrationSummaryClass arbitrationSummary { get; set; }

    public class StatusClass {
        public Boolean isActing { get; set; }
        public Long code { get; set; }
        public String text { get; set; }
    }

    public class ArbitrationSummaryClass {
        public PlaintiffClass plaintiff {get; set;}
        public PlaintiffClass defendant { get; set; }
        public ArbitrationByTypeClass arbitrationByType { get; set; }
        public ArbitrationByYearClass arbitrationByYear { get; set; }
        public Long total { get; set; }
        public Long considered { get; set; }
        public Long appealed { get; set; }
        public Long decisionsAndRulings { get; set; }
        public Long completed { get; set; }
    }

    public class PlaintiffClass {
        public CompletedByResultClass completedByResult { get; set; }
        public Long total { get; set; }
        public String totalSum { get; set; }
        public Long considered { get; set; }
        public String consideredSum { get; set; }
        public Long appealed { get; set; }
        public String appealedSum { get; set; }
        public Long decisionsAndRulings { get; set; }
        public String decisionsAndRulingsSum { get; set; }
        public Long completed { get; set; }
        public String completedSum { get; set; }
    }

    public class CompletedByResultClass {
        public List<ResultTypeClass> resultType { get; set; }
    }

    public class ResultTypeClass {
        public Long id { get; set; }
        public String name { get; set; }
        public Long casesNumber { get; set; }
        public String sum { get; set; }
    }

    public class ArbitrationByTypeClass {
        public List<TypeClass> type { get; set; }
    }

    public class TypeClass {
        public TypePlaintiffClass plaintiff { get; set; }
        public TypePlaintiffClass defendant { get; set; }
        public Long id { get; set; }
        public String name { get; set; }
    }

    public class TypePlaintiffClass {
        public Long total { get; set; }
        public Long considered { get; set; }
        public Long appealed { get; set; }
        public Long completed { get; set; }
    }

    public class ArbitrationByYearClass {
        public List<YearClass> year { get; set; }
    }

    public class YearClass {
        public YearPlaintiffClass plaintiff { get; set; }
        public YearPlaintiffClass defendant { get; set; }
        public ThirdOrOtherPerson thirdOrOtherPerson { get; set; }
        public Long year { get; set; }
    }

    public class YearPlaintiffClass {
        public Long casesNumber { get; set; }
        public String sum { get; set; }
    }

    public class ThirdOrOtherPerson {
        public Long casesNumber { get; set; }
    }
}