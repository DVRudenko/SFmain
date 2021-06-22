public class PPR_API_CreateClientTestDataBuilder {

    private PPR_API_CreateClientRequest request = new PPR_API_CreateClientRequest();

    public PPR_API_CreateClientTestDataBuilder clean() {
        this.request = new PPR_API_CreateClientRequest();
        return this;
    }

    public PPR_API_CreateClientRequest build() {
        return this.request;
    }

    public PPR_API_CreateClientTestDataBuilder baseRequest(String entityId, String source, String inn) {
        PPR_API_CreateClientRequest.MetadataObj metadata = new PPR_API_CreateClientRequest.MetadataObj();
        metadata.user = 'test user';
        metadata.id = entityId;
        metadata.source = source;
        this.request.metadata = metadata;

        PPR_API_CreateClientRequest.CustomerInfoObj customerInfo = new PPR_API_CreateClientRequest.CustomerInfoObj();

        PPR_API_CreateClientRequest.LegalInfoObj legalInfo = new PPR_API_CreateClientRequest.LegalInfoObj();
        legalInfo.inn = inn;
        legalInfo.agreements = new List<String>();
        legalInfo.codeWord = 'тестируем';
        legalInfo.agreements = new List<String>();
        legalInfo.agreements.add('MarketingProgram');
        customerInfo.legalInfo = legalInfo;

        PPR_API_CreateClientRequest.AdditionalInfoObj additionalInfo = new PPR_API_CreateClientRequest.AdditionalInfoObj();
        additionalInfo.courierServiceComments = 'comments here';
        customerInfo.additionalInfo = additionalInfo;

        PPR_API_CreateClientRequest.BankInfoObj bankInfo = new PPR_API_CreateClientRequest.BankInfoObj();
        bankInfo.bik = '044525225';
        bankInfo.accountNum = '12345678901234567890';
        customerInfo.bankInfo = bankInfo;

        PPR_API_CreateClientRequest.OrderInfoObj orderInfo = new PPR_API_CreateClientRequest.OrderInfoObj();
        orderInfo.product = 'PetrolPlus_Rover';
        orderInfo.tariff = '1OPTIMAL_CONTRACT';
        orderInfo.orderType = 'Overdraft';
        orderInfo.overdraftSum = '100000';
        orderInfo.services = new List<String>();
        orderInfo.services.add('PersonalManager');
        orderInfo.services.add('ExpressDocDelivery');
        orderInfo.promos = new List<String>();
        orderInfo.promos.add('9Е07');
        orderInfo.promos.add('9Е08');
        orderInfo.cards = new List<String>();
        orderInfo.cards.add('1111000023');
        customerInfo.orderInfo = orderInfo;

        this.request.customerInfo = customerInfo;
        return this;
    }

    public PPR_API_CreateClientTestDataBuilder appendAgreement(String value) {
        if (this.request.customerInfo.legalInfo.agreements == null) this.request.customerInfo.legalInfo.agreements = new List<String>();
        this.request.customerInfo.legalInfo.agreements.add(value);
        return this;
    }

    public PPR_API_CreateClientTestDataBuilder appendPhone(String value, List<String> types) {
        PPR_API_CreateClientRequest.PhoneObj phone = createPhone(value, types);
        if (this.request.customerInfo.legalInfo.phones == null) this.request.customerInfo.legalInfo.phones = new List<PPR_API_CreateClientRequest.PhoneObj>();
        this.request.customerInfo.legalInfo.phones.add(phone);
        return this;
    }

    public PPR_API_CreateClientTestDataBuilder appendEmail(String value, List<String> types) {
        PPR_API_CreateClientRequest.EmailObj email = new PPR_API_CreateClientRequest.EmailObj();
        email.type = types;
        email.value = value;
        if (this.request.customerInfo.legalInfo.emails == null) this.request.customerInfo.legalInfo.emails = new List<PPR_API_CreateClientRequest.EmailObj>();
        this.request.customerInfo.legalInfo.emails.add(email);
        return this;
    }

    public PPR_API_CreateClientTestDataBuilder appendAddress(List<String> types) {
        PPR_API_CreateClientRequest.AddressObj address = new PPR_API_CreateClientRequest.AddressObj();
        address.type = types;
        address.city = 'Первомайское';
        address.state = 'Алтайский край';
        address.country = 'Russia';
        address.zipCode = '659607';
        address.street = '5';
        address.house = '6';
        address.apartment = '7';
        if (this.request.customerInfo.addresses == null) this.request.customerInfo.addresses = new List<PPR_API_CreateClientRequest.AddressObj>();
        this.request.customerInfo.addresses.add(address);
        return this;
    }

    public PPR_API_CreateClientTestDataBuilder appendStaff(String role, String email) {
        PPR_API_CreateClientRequest.StaffObj staff = new PPR_API_CreateClientRequest.StaffObj();
        staff.firstName = 'Василий';
        staff.lastName = 'Пупкин';
        staff.Surname = 'Васильевич';
        staff.email = email;
        staff.role = role;
        staff.position = 'position';
        staff.phones = new List<PPR_API_CreateClientRequest.PhoneObj>();
        staff.phones.add(createPhone('9995552233', new List<String>{'Mobile'}));
        if (this.request.customerInfo.staff == null) this.request.customerInfo.staff = new List<PPR_API_CreateClientRequest.StaffObj>();
        this.request.customerInfo.staff.add(staff);
        return this;
    }

    private PPR_API_CreateClientRequest.PhoneObj createPhone(String value, List<String> types) {
        PPR_API_CreateClientRequest.PhoneObj phone = new PPR_API_CreateClientRequest.PhoneObj();
        phone.type = types;
        phone.value = new PPR_API_CreateClientRequest.ValueObj();
        phone.value.code = '7';
        phone.value.numberStr = value;
        phone.value.ext = '123';
        return phone;
    }

}