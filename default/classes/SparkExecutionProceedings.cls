global class SparkExecutionProceedings {
    public String sparkID { get; set; }
    public String shortName { get; set; }
    public String inn { get; set; }
    public String ogrn { get; set; }
    public String okpo { get; set; }
    public String okato { get; set; }
    public StatusClass status { get; set; }
    public ExecutionProceedings executionProceedings { get; set; }

    public class StatusClass {
        public Boolean isActing { get; set; }
        public Long code { get; set; }
        public String text { get; set; }
        public String date_x { get; set; }
    }

    public class ExecutionProceedings {
        public List<ExecutionProceeding> executionProceeding { get; set; }
    }

    public class ExecutionProceeding {
        public Boolean isExecuted { get; set; }
        public String number_x { get; set; }
        public String payoutAmount { get; set; }
        public String department { get; set; }
        public String document { get; set; }
        public String date_x { get; set; }
        public TypeClass type { get; set; }
        public TerminationReasonClass terminationReason { get; set; }
    }

    public class TypeClass {
        public String value { get; set; }
        public Long groupId { get; set; }
        public String groupName { get; set; }
        public Long id { get; set; }
    }

    public class TerminationReasonClass {
        public Long id { get; set; }
        public String name { get; set; }
        public String date_x { get; set; }
    }
}