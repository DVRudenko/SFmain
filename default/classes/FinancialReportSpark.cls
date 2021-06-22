public class FinancialReportSpark implements Comparable {

    public Decimal sparkID { get; set; }            // идентификатор системы СПАРК
    public String inn { get; set; }                 // ИНН
    public String ogrn { get; set; }                // ОГРН
    public String okpo { get; set; }                // ОКПО
    public String shortName { get; set; }           // краткое наименование
    public Period period { get; set; }              // период бухгалтерской отчетности
    public String egrulLikvidation { get; set; }    // сведения о ликвидации по данным ФНС
    public String egrpoIncluded { get; set; }       // признак наличия компании в ЕГРПО

    public class Form {
        public List<Value> value { get; set; }      // список всех строк формы
        public Integer id { get; set; }             // id формы
        public Integer power { get; set; }          // единица измерения формы баланса
    }

    public class Value {
        public Decimal value { get; set; }          // значение (отдельно для каждого столбца)
        public String code { get; set; }            // код строки
        public String name { get; set; }            // описание строки
        public Integer column { get; set; }         // номер столбца
    }

    public class Period {
        public List<Form> form { get; set; }        // списко форм бухгалтерской отчетности
        public String periodName { get; set; }      // наименование периода
        public String dateEnd { get; set; }         // дата окончания периода
        public String dateBegin { get; set; }       // дата начала периода
    }


    public Integer compareTo(Object param) {
        FinancialReportSpark compareTo = (FinancialReportSpark) param;
        if (Date.valueOf(this.period.dateEnd) > Date.valueOf(compareTo.period.dateEnd)) {
            return -1;
        } else if (Date.valueOf(this.period.dateEnd) < Date.valueOf(compareTo.period.dateEnd)) {
            return 1;
        } else {
            return 0;
        }
    }

    public static FinancialReportSpark parse(String json) {
        return (FinancialReportSpark) System.JSON.deserialize(json, FinancialReportSpark.class);
    }
}