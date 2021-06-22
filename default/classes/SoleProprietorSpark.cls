global class SoleProprietorSpark {

    public class Status {
        public Boolean isActing;        // признак действующего ИП
        public String text;             // текст статуса
        public Integer code;            // код статуса
    }

    public class Okved {
        public String code;             // код ОКВЭД
        public String name;             // наименование
        public Boolean isMain;          // признак основного ОКВЭД
    }

    public class Okato {
        public String code;             // код ОКАТО
        public String regionName;       // наименование региона
        public Integer regionCode;      // код региона
    }

    public class OkvedList {
        public List<Okved> okved;       // список ОКВЭД
    }

    public Decimal sparkID;             // идентификатор системы СПАРК
    public Status status;               // статус
    public String dateReg;              // дата регистрации
    public String fullNameRus;          // полное имя (на русском)
    public String inn;                  // ИНН
    public String ogrnip;               // ОГРНИП
    public String okpo;                 // ОКПО
    public Okato okato;                 // ОКАТО
    public String birthDate;            // дата рождения
    public String birthPlace;           // место рождения
    public Okved mainOkved;
    public OkvedList okved2List;         // список ОКВЭД

    public static SoleProprietorSpark parse(String json) {
        return (SoleProprietorSpark) System.JSON.deserialize(json, SoleProprietorSpark.class);
    }

    /*****************************************************************************
    *  Name            : getMainOkved()
    *  Summary         : returns OKVED of organization in SPARK,  which is marked as main
    *  CreatedDate     : 06/12/2019
    *  Parameters      : -
    *  Returns         : Okved - object with data about main OKVED from spark
    ******************************************************************************/
    public Okved getMainOkved() {
        if (okved2List == null) {
            //if no OKVED data in SPARK, return empty object
            return new Okved();
        } else {
            if (okved2List.okved.isEmpty()) {
                //if no OKVED data in SPARK, return empty object
                return new Okved();
            } else {
                for (Okved okved : okved2List.okved) {
                    if (okved.isMain != null && okved.isMain == true) {
                        //return main OKVED
                        return okved;
                    }
                }
                //if no main OKVED found, return first OKVED from JSON
                return okved2List.okved.get(0);
            }
        }
    }
}