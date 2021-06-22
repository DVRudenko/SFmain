global class RequestPrescoring {
    public String prescoringDataId;                 // id для хранения прескоринговой инфорации в бд, передавать null
    public String creditApplicationId;              // id кредитнойзаявки из КФ, передавать null
    public String inn;                              // ИНН компании (String), вводится вручную
    public Boolean companyStatusIsActing;           // признак действующей компании, true - действующая, false - не действующая (boolean), берется из СПАРК;
    public Boolean frozenAccounts;                  // есть ли решения о приостановлении операций по счету (boolean) , берется из СПАРК;
    public Boolean bankruptcyMessage;               // есть ли сообщения о банкротствах (boolean) , берется из СПАРК;
    public String dateFirstReg;                       // дата регистрации компании (Date) , берется из СПАРК; ФОРМАТ (yyyy-MM-dd)!
    private Long sumPlaintiff2018;                   // сумма исков предыдущего года(истец) (Long), считается с помощью данных из СПАРК;
    private Long sumPlaintiff2019;                   // сумма исков текущего года(истец) (Long), считается с помощью данных из СПАРК;
    private Long sumDefendant2018;                   // сумма исков предыдущего года(ответчик) (Long), считается с помощью данных из СПАРК;
    private Long sumDefendant2019;                   // сумма исков текущего года(ответчик) (Long), считается с помощью данных из СПАРК;
    public String consolidatedIndicator;            // сводный индикатор риска (String) , берется из СПАРК;
    public Long fixedAssets1150;                    // финансовая отчетность, основные средства(код 1150) (Long) , берется из СПАРК;
    public Long currentAssets1200;                  // финансовая отчетность, оборотные активы(код 1200) (Long) , берется из СПАРК;
    public Long shortTermLiabilities1500;           // финансовая отчетность, краткосрочные обязательства (код 1500) (Long) , берется из СПАРК;
    public Long capitalAndReserves1300;             // финансовая отчетность, капитал и резервы (код 1300) (Long) , берется из СПАРК;
    public Long revenue2110;                        // финансовая отчетность, выручка (код 2110) (Long) , берется из СПАРК;
    public Long turnover;                           // планируемый оборот, литры(Long), вводится вручную;
    public Double sumExecutionProceedings;          // (double) , считается с помощью данных из СПАРК;
    public Boolean simultaneousChangeFounderAndCEO; // Однов-ая смена учредителя и ген. директора (boolean), берется из СПАРК;

    public Long trialsAsPlaintiffLastYear {         // враппер sumPlaintiff2018
        public get;
        public set {
            this.trialsAsPlaintiffLastYear = value;
            this.sumPlaintiff2018 = value;
        }
    }
    public Long trialsAsPlaintiffCurrentYear {      // враппер sumPlaintiff2019
        public get;
        public set {
            this.trialsAsPlaintiffCurrentYear = value;
            this.sumPlaintiff2019 = value;
        }
    }
    public Long trialsAsDefendantLastYear {         // враппер sumDefendant2018
        public get;
        public set {
            this.trialsAsDefendantLastYear = value;
            this.sumDefendant2018 = value;
        }
    }
    public Long trialsAsDefendantCurrentYear {      // враппер sumDefendant2019
        public get;
        public set {
            this.trialsAsDefendantCurrentYear = value;
            this.sumDefendant2019 = value;
        }
    }
}