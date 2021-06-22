global class SchufaEntity {
    global String accessToken;
    global String message;
    global List<Order> order;
    global List<Companies> companies;
    global FinancialStanding financialStanding;
    global List<Employees> employees;
    global List<Volume> volume;
    global CoreData coreData;
    global String documentBytes;
    global String companyId;
    global String street;
    global String zipCode;
    global String companyName;
    global String city;
    global String code;
    global String detail;
    global String traderegisterNumber;
    
    global class Order {
        global String name;
        global Boolean completed;
        global Boolean failed;
        global String reason;
        global String orderDate;
    }
    
    global class Companies {
        global String companyId;
        global String street;
        global String zipCode;
        global String companyName;
        global String city;
        global String traderegisterNumber;
    }
    
    global class CurrentScore {
        global String score;
    }
    
    global class FinancialIndex {
        global CurrentScore currentScore;
    }
    
    global class CreditLimit {
        global String currency_x;
        global String amount;
    }
    
    global class FinancialStanding {
        global FinancialIndex financialIndex;
        global CreditLimit creditLimit;
    }
    
    global class PhoneNumber {
        global String number_x;
        global String dialingCode;
    }
    
    global class FaxNumber {
        global String number_x;
        global String dialingCode;
    }
    
    global class CurrentCommunicationData {
        global String email;
        global PhoneNumber phoneNumber;
        global FaxNumber faxNumber;
        global String website;
    }
    
    global class Employees {
        global String description;
    }
    
    global class Volume {
        global String description;
    }
    
    global class RepresentationAuthorized {
        global String schufaid;
        global String lastname;
        global String firstname;
        global String position;
        global String address;
        global String birthdate;
    }
    
    global class CompanyData {
        global String name;
        global String city;
        global String legalFormAbbreviation;
        global CurrentCommunicationData currentCommunicationData;
        global String companyId;
        global String tradeRegisterNumber;
        global String registercourt;
        global String street;
        global String vatID;
        global String zipcode;
        global String foundationDate;
        global String branch;
        global String branchCode;
    }
    
    global class CoreData {
        global List<RepresentationAuthorized> representationAuthorized;
        global CompanyData companyData;
    }
    
    global static SchufaEntity parse(String jsonStr) {
        return (SchufaEntity) JSON.deserialize(jsonStr, SchufaEntity.class);
    }
}