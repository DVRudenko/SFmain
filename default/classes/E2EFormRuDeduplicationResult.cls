public class E2EFormRuDeduplicationResult {
    public Account sfAccount { get; set; }              // Дубль Account найденный по ИНН
    public Opportunity sfOpportunity { get; set; }      // Определен как основной по результатам дедубликации (случай перевода в КО)
    public Account e2eAccount { get; set; }             // созданный Account
    public Contact e2eContact { get; set; }             // созданный Contact
    public Opportunity e2eOpportunity { get; set; }     // созданный Opportunity
    public String statusCode { get; set; }              // статус дедубликации
    public Boolean innDuplication { get; set; }         // флаг, что найден дубль по ИНН
    public Id formDataId { get; set; }                  // Id formData
    public Boolean isDomainDuplicated { get; set; }     // флаг, что найден дубль по домену
    public Boolean isEmailDuplicated { get; set; }      // флаг, что найден дубль по email
    public Datetime deduplicationDatetime { get; set; } // дата и время дедубликации
    public List<Contact> excludedContacts {get; set;}    // список контактов для исключения из дедупликации
    public Boolean isDifferentOwnerFoundForOpportunities {get; set;}    // флаг, что найдена возможность с таким же владельцем
    //SF-1313
    public List<Opportunity> excludedOpportunities {get; set;}    // список Opportunity для исключения из дедупликации
	
    public E2EFormRuDeduplicationResult() {
        this.statusCode = GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name();
        this.innDuplication = false;
        this.isDomainDuplicated = false;
        this.isEmailDuplicated = false;
        this.excludedContacts = new List<Contact>();
        //SF-1313
        this.excludedOpportunities = new List<Opportunity>();		
    }

    public String getDedupStatusInformation() {
        if (this.statusCode == GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name()) {
            return 'Е2Е - нет дубля';
        } else if (this.statusCode == GlobalUtils.DeduplicationStatus.E2EProcess.name()) {
            return 'E2E ';
        } else if (this.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
            return 'Клиент Сервис';
        } else if (this.statusCode == GlobalUtils.DeduplicationStatus.KO.name()) {
            return 'Клиент КО';
        } else if (this.statusCode == GlobalUtils.DeduplicationStatus.Inbound.name()) {
            if (this.innDuplication == true) {
                return 'Е2Е проверка (прикрепление e2e объектов)';
            } else {
                return 'Е2Е проверка (новый ИНН, дубль по email)';
            }
        }
        return 'status missing';
    }
}
