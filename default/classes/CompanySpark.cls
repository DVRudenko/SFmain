global class CompanySpark {
        public Decimal sparkID { get; set; }                    // идентификатор системы СПАРК
        public String inn { get; set; }                         // ИНН
        public String ogrn { get; set; }                        // ОГРН
        public String okpo { get; set; }                        // ОКПО
        public String fullName { get; set; }                    // полное наименование
        public String address { get; set; }                     // адресс
        public String industry { get; set; }                    // основная отрасль
        public String regionCode { get; set; }                  // код региона
        public String regionName { get; set; }                  // название региона
        public String manager { get; set; }                     // ФИО руководителя
        public String okopfName { get; set; }                   // организационно - правовая форма
        public ExtendedReportSpark extendedReport { get; set; } // расширенный отчет по юр. лицу
}