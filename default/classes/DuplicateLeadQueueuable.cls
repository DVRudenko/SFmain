global class DuplicateLeadQueueuable implements Queueable  {

    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String country;
    private String recordTypeName;

    global DuplicateLeadQueueuable(String firstName, String lastName, String email, String phone,
                                   String country, String recordTypeName) {

        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
        this.country = country;
        this.recordTypeName = recordTypeName;
    }

    global void execute(QueueableContext context) {
        LongFormGlobalUtils.findAndProcessDuplicateLeadFuture(
            this.firstName, this.lastName, this.email, this.phone, this.country, this.recordTypeName
        );
    }
}