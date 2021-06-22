
public class CreditFactoryTestUtils {
    
    
    /*******************************************************************************
    *  Summary         : Generate Account object   
    *  Created         : 08/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountPL() {
        Account account = new Account(
            Name = 'Kacze wyroby BIS Mariusz Wernyks', 
            BillingStreet = 'Kacza 1',
            BillingPostalCode = '82-333',
            BillingCity = 'Wodnowo',
            BillingCountry = 'Poland',
            BillingCountryCode = 'PL', 
            ShippingStreet = 'Kacza 1',
            ShippingPostalCode = '82-333',
            ShippingCity = 'Wodnowo',
            ShippingCountry = 'Poland',
            ShippingCountryCode = 'PL',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Single person company confirmed',
            Steuernummer__c = '8338085693',
            Umsatzsteuer_ID__c = 'PL8338085693',
            HR_Abteilung_HRA_HRB_und_HR_Nummer__c = '414052396');
        return account;
    }
    
    /*******************************************************************************
    *  Summary         : Generate Opportunity object   
    *  Created         : 08/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityPL() {
        Opportunity opportunity = new Opportunity(
            Name = 'Kacze wyroby BIS Mariusz Wernyks',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Zahlungsziel_2__c = '15',
            Rechnungsperiode_2__c = '7',
            Total_consumption_l_month__c = 1000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Anzahl_der_Karten__c = 1,
            Zahlungsart__c = 'Lastschrift',
            Language_preference__c = 'Polish',
            IBAN__c = 'PL1234512345',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test',
            e_Invoicing_PDF__c = true,
            Papierrechnung__c = false);
        return opportunity;
    }
    
    /*******************************************************************************
    *  Summary         : Generate Contact object   
    *  Created         : 08/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactPL() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Wernyks',
            FirstName = 'Mariusz',
            Email = 'mariusz.wernyks@test.com');
        return contact;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate Black List object
    *  CreatedDate     : 19/03/2020  by Anton Buzak
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyPL() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'PL',
            Customer_Full_Name__c = 'Kacze wyroby BIS Mariusz Wernyks',
            TAX_ID__c = '8338085693',
            Trade_Register_Number__c = '414052396',
            Reg_Address_Address_Lines__c = 'Kacza 1',
            Reg_Address_City__c = 'Wodnowo',
            Reg_Address_Zip_Code__c = '82-333',
            Primary_Phone__c = '12341234',
            Primary_Email__c = 'mariusz.wernyks@test.com',
            Primary_Contact__c = 'Mariusz Wernyks',
            IBAN__c = 'PL1234512345',
            IP_Address__c = '12341234');
        return blackList;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object
    *  Created         : 26/08/2020 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReport(String country) {
        Credit_Factory_Report__c report;
        if (country == 'Poland') {
            report = generateCreditFactoryReportPL();
        }
        else if (country == 'Germany') {
            report = generateCreditFactoryReportDE();
        }
        else if (country == 'Netherlands') {
            report = generateCreditFactoryReportNL();
        }
        else if (country == 'Belgium-NL' || country == 'Belgium-FR') {
            report = generateCreditFactoryReportBE();
            report.Country__c = country;
        }
        else if (country == 'Slovakia') {
            report = generateCreditFactoryReportSK();
        }
        else if (country == 'Hungary') {
            report = generateCreditFactoryReportHU();
        }
        else if (country == 'Czech Republic') {
            report = generateCreditFactoryReportCZ();
        }
        else if (country == 'France') {
            report = generateCreditFactoryReportFR();
        }
        else if (country == 'Switzerland-DE' || country == 'Switzerland-FR' || country == 'Switzerland-IT') {
            report = generateCreditFactoryReportCH();
        }
        else if (country == 'Austria') {
            report = generateCreditFactoryReportAT();
        }
        else if (country == 'Luxembourg') {
            report = generateCreditFactoryReportLU();
        }

        return report;
    }

    
    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object   
    *  Created         : 09/02/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportPL() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'Kacze wyroby BIS Mariusz Wernyks',
            Name__c = 'Kacze wyroby BIS Mariusz Wernyks',
            Country__c = 'Poland',
            Street__c = 'Kacza',
            Housenumber__c = '1',
            City__c = 'Wodnowo',
            Postcode__c = '82-333',
            Postal_Street__c = 'Kacza',
            Postal_Housenumber__c = '1',
            Postal_City__c = 'Wodnowo',
            Postal_Postcode__c = '82-333',
            Registered_Street__c = 'Kacza',
            Registered_Housenumber__c = '1',
            Registered_City__c = 'Wodnowo',
            Registered_Postcode__c = '82-333',
            Tax_Id__c = '8338085693',
            VAT_Number__c = 'PL8338085693',
            Trade_Register_Number__c = '414052396',
            Request_Status__c = 'OK',
            Date_of_Foundation__c = '20101010',
            Obligation_Overdue__c = false,
            Payment_History_Requested__c = true,
            Class_Rating__c = '1',
            Profit_Loss_Last_Year__c = '10000',
            Profit_Loss_Year_Before_Last__c = '10000',
            BIG_Requested__c = true, 
            Total_Overdue_Amount__c = 0,
            Principal_Activity_Code__c = '10.42.Z',
            Principal_Activity_Description__c = 'Manufacture of margarine and similar edible fats',
            Company_Status__c = 'ACTIVE'
        );
        
        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object
    *  Created         : 26/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployee(String country) {
        Credit_Factory_Report_Employee__c reportEmployee;
        if (country == 'Poland') {
            reportEmployee = generateCreditFactoryReportEmployeePL();
        }
        else if (country == 'Germany') {
            reportEmployee = generateCreditFactoryReportEmployeeDE();
        }
        else if (country == 'Netherlands') {
            reportEmployee = generateCreditFactoryReportEmployeeNL();
        }
        else if (country == 'Belgium-NL' || country == 'Belgium-FR') {
            reportEmployee = generateCreditFactoryReportEmployeeBE();
        }
        else if (country == 'Slovakia') {
            reportEmployee = generateCreditFactoryReportEmployeeSK();
        }
        else if (country == 'Hungary') {
            reportEmployee = generateCreditFactoryReportEmployeeHU();
        }
        else if (country == 'Czech Republic') {
            reportEmployee = generateCreditFactoryReportEmployeeCZ();
        }
        else if (country == 'France') {
            reportEmployee = generateCreditFactoryReportEmployeeFR();
        }
        else if (country == 'Switzerland-DE' || country == 'Switzerland-FR' || country == 'Switzerland-IT') {
            reportEmployee = generateCreditFactoryReportEmployeeCH();
        }
        else if (country == 'Austria') {
            reportEmployee = generateCreditFactoryReportEmployeeAT();
        }
        else if (country == 'Luxembourg') {
            reportEmployee = generateCreditFactoryReportEmployeeLU();
        }

        return reportEmployee;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object   
    *  Created         : 16/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeePL() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Mariusz Wernyks',
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Default')
        );
        
        return reportEmployee;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Crif settings   
    *  Created         : 09/04/2020
    *  Parameters      : -
    *  Returns         : crif settings
    ******************************************************************************/
    public static CreditSystem__c generateCrifSetting() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Crif',
            Endpoint__c = 'https://demo.deltavista.pl/Search_Soap_Service_PL/services/SearchService,' + 
                'https://demo.deltavista.pl/dvs-soap/services/OrderCheckService,https://demo.deltavista.pl/pdfservice/pdfservlet', 
            Username__c = 'demo_fleetcor_soap', 
            Password__c = 'cvujmHe4',
            Supported_Countries__c = 'Poland');
        return creditSystem;
    }


    /*******************************************************************************
    *  Summary         : Generate Account object for DE
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountDE() {
        Account account = new Account(
            Name = 'Buchverlagsgesellschaft Druck mbH',
            BillingStreet = 'Schillerstr. 52-60',
            ShippingStreet = 'Schillerstr. 52-60',
            BillingPostalCode = '60313',
            ShippingPostalCode = '60313',
            BillingCity = 'Frankfurt am Main',
            ShippingCity = 'Frankfurt am Main',
            BillingCountry = 'Germany',
            BillingCountryCode = 'DE',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'AG',
            Umsatzsteuer_ID__c = 'DE123547899');
        return account;
    }

    /*******************************************************************************
    *  Summary         : Generate Opportunity object for DE
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityDE() {
        Opportunity opportunity = new Opportunity(
            Name = 'Buchverlagsgesellschaft Druck mbH',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 2000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '7',
            Rechnungsperiode_2__c = '7',
            Anzahl_der_Karten__c = 1,
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
            Language_preference__c = 'German',
            IBAN__c = 'DE1234512345',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test',
            Sec_Channel__c = 'Inbound',
            Einwilligung_Lastschriftverfahren__c = false);
        return opportunity;
    }

    /*******************************************************************************
    *  Summary         : Generate Contact object for DE
    *  Created         : 13/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactDE() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Ottersbach',
            FirstName = 'Cornelius',
            Phone = '123123412345');
        return contact;
    }


    /*******************************************************************************
    *  Summary         : generate Black List object for DE
    *  CreatedDate     : 13/08/2020  by Anton Buzak
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyDE() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'DE',
            Customer_Full_Name__c = 'Buchverlagsgesellschaft Druck mbH',
            VATReg_Number__c = 'DE123547899',
            Reg_Address_Address_Lines__c = 'Schillerstr. 52-60',
            Reg_Address_City__c = 'Frankfurt am Main',
            Reg_Address_Zip_Code__c = '60313',
            Primary_Phone__c = '123123412345',
            Primary_Email__c = 'cornelius.ottersbach@test.com',
            Primary_Contact__c = 'Cornelius Ottersbach',
            IBAN__c = 'DE1234512345',
            IP_Address__c = '12341234');
        return blackList;
    }

    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for DE
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportDE() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'Buchverlagsgesellschaft Druck mbH',
            Name__c = 'Buchverlagsgesellschaft Druck mbH',
            Country__c = 'Germany',
            Street__c = 'Schillerstr.',
            Housenumber__c = '52-60',
            City__c = 'Frankfurt am Main',
            Postcode__c = '60313',
            Date_of_Foundation__c = '10.10.2010',
            Class_Rating__c = '1',
            Principal_Activity_Code__c = '7112',
            Principal_Activity_Description__c = 'Ingenieurbüros',
            VAT_Number__c = 'DE123547899',
            Credit_Limit__c = '10000'
        );

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object for DE
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeDE() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Cornelius Ottersbach',
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Default')
        );

        return reportEmployee;
    }


    /*******************************************************************************
    *  Summary         : Generate Schufa settings
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : schufa settings
    ******************************************************************************/
    public static CreditSystem__c generateSchufaSetting() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Schufa',
            Endpoint__c = 'https://kycnow.test.fino.cloud/api/v1',
            Username__c = 'fleetcor_eu',
            Password__c = 'f0503e6c-c180-49b2-9f8a-4d9fcdd1b262',
            Supported_Countries__c = 'Germany');
        return creditSystem;
    }


    /*******************************************************************************
    *  Summary         : Generate Account object for NL
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountNL() {
        Account account = new Account(
            Name = 'Testgear B.V.',
            BillingStreet = 'Molensingel 10',
            ShippingStreet = 'Molensingel 10',
            BillingPostalCode = '2614LB',
            ShippingPostalCode = '2614LB',
            BillingCity = 'DELFT',
            ShippingCity = 'DELFT',
            BillingCountry = 'Netherlands',
            BillingCountryCode = 'NL',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'AG',
            Umsatzsteuer_ID__c = '123123123',
            Steuernummer__c = '5026034');
        return account;
    }

    /*******************************************************************************
    *  Summary         : Generate Opportunity object for NL
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityNL() {
        Opportunity opportunity = new Opportunity(
            Name = 'Testgear B.V.',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 1000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '7',
            Rechnungsperiode_2__c = '7',
            Anzahl_der_Karten__c = 1,
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
            Language_preference__c = 'Dutch',
            IBAN__c = 'NL39INGB0006421882',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test',
            Sec_Channel__c = 'Inbound',
            Einwilligung_Lastschriftverfahren__c = false);
        return opportunity;
    }

    /*******************************************************************************
    *  Summary         : Generate Contact object for NL
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactNL() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Petrus',
            FirstName = 'Cornelius',
            Phone = '123123412345');
        return contact;
    }


    /*******************************************************************************
    *  Summary         : generate Black List object for NL
    *  CreatedDate     : 11/09/2020  by Anton Buzak
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyNL() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'NL',
            Customer_Full_Name__c = 'Testgear B.V.',
            VATReg_Number__c = '123123123',
            Reg_Address_Address_Lines__c = 'Molensingel 10',
            Reg_Address_City__c = 'DELFT',
            Reg_Address_Zip_Code__c = '2614LB',
            Primary_Phone__c = '123123412345',
            Primary_Email__c = 'cornelius.ottersbach@test.com',
            Primary_Contact__c = 'Petrus Cornelius',
            IBAN__c = 'NL39INGB0006421882',
            IP_Address__c = '12341234');
        return blackList;
    }

    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for NL
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportNL() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'Testgear B.V.',
            Name__c = 'Testgear B.V.',
            Country__c = 'Netherlands',
            Street__c = 'Molensingel',
            Housenumber__c = '10',
            City__c = 'DELFT',
            Postcode__c = '2614LB',
            Date_of_Foundation__c = '2007-05-26T00:00:00Z',
            Date_Of_Last_Change_Of_Director__c = '2007-05-26T00:00:00Z',
            Date_Of_Last_Change_Of_Address__c = '2007-05-26T00:00:00Z',
            Class_Rating__c = '1',
            Principal_Activity_Code__c = '7112',
            Principal_Activity_Description__c = 'Ingenieurbüros',
            VAT_Number__c = '123123123',
            Tax_Id__c = '5026034',
            Credit_Limit__c = '10000',
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report__c', 'Default')
        );

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for NL
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryAdditionalReportNL() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'Testgear B.V.',
            Name__c = 'Testgear B.V.',
            Country__c = 'Netherlands',
            Street__c = 'Molensingel',
            Housenumber__c = '10',
            City__c = 'DELFT',
            Postcode__c = '2614LB',
            Date_of_Foundation__c = '2007-05-26T00:00:00Z',
            Class_Rating__c = '1',
            Principal_Activity_Code__c = '7112',
            Principal_Activity_Description__c = 'Ingenieurbüros',
            VAT_Number__c = '123123123',
            Tax_Id__c = '5026034',
            Credit_Limit__c = '10000',
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report__c', 'Company Info')
        );

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object for NL
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeNL() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Petrus Cornelius',
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Default')
        );

        return reportEmployee;
    }


    /*******************************************************************************
    *  Summary         : Generate Account object for BE
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountBE() {
        Account account = new Account(
            Name = 'TEST SA',
            BillingStreet = 'RUE LOUIS RENARD 9B',
            ShippingStreet = 'RUE LOUIS RENARD 9B',
            BillingPostalCode = '4367',
            ShippingPostalCode = '4367',
            BillingCity = 'CRISNÉE',
            ShippingCity = 'CRISNÉE',
            BillingCountry = 'Belgium-NL',
            BillingCountryCode = 'BENL',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'AG',
            Umsatzsteuer_ID__c = 'BE.0428.089.605',
            Steuernummer__c = '428089605');
        return account;
    }

    /*******************************************************************************
    *  Summary         : Generate Opportunity object for BE
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityBE() {
        Opportunity opportunity = new Opportunity(
            Name = 'TEST SA',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 1000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '7',
            Rechnungsperiode_2__c = '7',
            Anzahl_der_Karten__c = 1,
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
            Language_preference__c = 'Dutch',
            IBAN__c = 'BE71096123456769',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test',
            Sec_Channel__c = 'Inbound',
            Einwilligung_Lastschriftverfahren__c = false);
        return opportunity;
    }

    /*******************************************************************************
    *  Summary         : Generate Contact object for BE
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactBE() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Aydogdu',
            FirstName = 'Roman',
            Phone = '123123412345');
        return contact;
    }


    /*******************************************************************************
    *  Summary         : generate Black List object for BE
    *  CreatedDate     : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyBE() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'BE',
            Customer_Full_Name__c = 'TEST SA',
            VATReg_Number__c = 'BE.0428.089.605',
            Reg_Address_Address_Lines__c = 'RUE LOUIS RENARD 9B',
            Reg_Address_City__c = 'CRISNÉE',
            Reg_Address_Zip_Code__c = '4367',
            Primary_Phone__c = '123123412345',
            Primary_Email__c = 'aydogdu.roman@test.com',
            Primary_Contact__c = 'Aydogdu Roman',
            IBAN__c = 'BE71096123456769',
            IP_Address__c = '12341234');
        return blackList;
    }

    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for BE
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportBE() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'TEST SA',
            Name__c = 'TEST SA',
            Street__c = 'RUE LOUIS RENARD',
            Housenumber__c = '9B',
            City__c = 'CRISNÉE',
            Postcode__c = '4367',
            Date_of_Foundation__c = '2007-05-26T00:00:00Z',
            Class_Rating__c = '5',
            Principal_Activity_Code__c = '7112',
            Principal_Activity_Description__c = 'Ingenieurbüros',
            VAT_Number__c = 'BE.0428.089.605',
            Tax_Id__c = '428089605',
            Credit_Limit__c = '10000'
        );

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object for BE
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeBE() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Roman Aydogdu',
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Default')
        );

        return reportEmployee;
    }


    /*******************************************************************************
    *  Summary         : Generate Account object for FR
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountFR() {
        Account account = new Account(
            Name = 'TESTS OPTIMUM',
            BillingStreet = 'RUE DE LA CLAIRETTE 10',
            ShippingStreet = 'RUE DE LA CLAIRETTE 10',
            BillingPostalCode = '34800',
            ShippingPostalCode = '34800',
            BillingCity = 'PERET',
            ShippingCity = 'PERET',
            BillingCountry = 'France',
            BillingCountryCode = 'FR',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'AG',
            Umsatzsteuer_ID__c = 'FR05537643967',
            Steuernummer__c = '537643967');
        return account;
    }

    /*******************************************************************************
    *  Summary         : Generate Opportunity object for FR
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityFR() {
        Opportunity opportunity = new Opportunity(
            Name = 'TESTS OPTIMUM',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 800,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '7',
            Rechnungsperiode_2__c = '7',
            Anzahl_der_Karten__c = 1,
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
            Language_preference__c = 'Dutch',
            IBAN__c = 'FR7630006000011234567890189',
            SWIFT_BIC__c = 'AGRIFRPP',
            Requested_SWIFT_BIC__c = 'AGRIFRPP',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test',
            Sec_Channel__c = 'Inbound',
            Einwilligung_Lastschriftverfahren__c = false);
        return opportunity;
    }

    /*******************************************************************************
    *  Summary         : Generate Contact object for FR
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactFR() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'RENÉ',
            FirstName = 'RUBINOCCI RENÉ',
            Phone = '123123412345');
        return contact;
    }


    /*******************************************************************************
    *  Summary         : generate Black List object for FR
    *  CreatedDate     : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyFR() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'FR',
            Customer_Full_Name__c = 'TEST OPTIMUM',
            VATReg_Number__c = 'FR05537643967',
            Reg_Address_Address_Lines__c = 'RUE DE LA CLAIRETTE 10',
            Reg_Address_City__c = 'PERET',
            Reg_Address_Zip_Code__c = '34800',
            Primary_Phone__c = '123123412345',
            Primary_Email__c = 'rubinochi.rene@test.com',
            Primary_Contact__c = 'RUBINOCCI RENÉ RENÉ',
            IBAN__c = 'FR7630006000011234567890189',
            IP_Address__c = '12341234');
        return blackList;
    }

    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for FR
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportFR() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'TESTS OPTIMUM',
            Name__c = 'TESTS OPTIMUM',
            Street__c = 'RUE DE LA CLAIRETTE',
            Housenumber__c = '10',
            City__c = 'PERET',
            Postcode__c = '34800',
            Date_of_Foundation__c = '2007-05-26T00:00:00Z',
            Class_Rating__c = '1',
            Principal_Activity_Code__c = '7112',
            Principal_Activity_Description__c = 'Ingenieurbüros',
            VAT_Number__c = 'FR05537643967',
            Tax_Id__c = '537643967',
            Credit_Limit__c = '300000'
        );

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object for FR
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeFR() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'RUBINOCCI RENÉ RENÉ',
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Default')
        );

        return reportEmployee;
    }


    /*******************************************************************************
    *  Summary         : Generate Creditsafe settings
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : creditsafe settings
    ******************************************************************************/
    public static CreditSystem__c generateCreditsafeSetting() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditsafe',
            Endpoint__c = 'https://connect.sandbox.creditsafe.com/v1',
            Username__c = 'anton.buzak@enway.com',
            Password__c = 'Gy4A]HBDO*Np7DlRLSUNI2',
            Supported_Countries__c = 'Netherlans');
        return creditSystem;
    }


    /*******************************************************************************
    *  Summary         : Generate Company.info settings
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : creditsafe settings
    ******************************************************************************/
    public static CreditSystem__c generateCompanyInfoSetting() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CompanyInfo',
            Endpoint__c = 'https://ws1.webservices.nl:443/soap_doclit.php',
            Username__c = 'test123',
            Password__c = 'test123',
            Supported_Countries__c = 'Netherlans');
        return creditSystem;
    }


    /*******************************************************************************
    *  Summary         : Generate Account object
    *  Created         : 09/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountSK() {
        Account account = new Account(
            Name = 'Štefan Sinčák',
            BillingStreet = 'Povstania českého ľudu 738/7',
            BillingPostalCode = '040 22',
            BillingCity = 'Košice - Dargovských hrdinov',
            BillingCountry = 'Slovakia',
            BillingCountryCode = 'SK',
            ShippingStreet = 'Povstania českého ľudu 738/7',
            ShippingPostalCode = '040 22',
            ShippingCity = 'Košice - Dargovských hrdinov',
            ShippingCountry = 'Slovakia',
            ShippingCountryCode = 'SK',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Single person company confirmed',
            Steuernummer__c = '50521969',
            Umsatzsteuer_ID__c = 'SK1048346145',
            HR_Abteilung_HRA_HRB_und_HR_Nummer__c = '35227/B',
            Ort_der_Registrierung_Handelsregisterort__c = 'Okresní soud Bratislava I');
        return account;
    }

    /*******************************************************************************
    *  Summary         : Generate Opportunity object
    *  Created         : 09/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunitySK() {
        Opportunity opportunity = new Opportunity(
            Name = 'Štefan Sinčák',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Zahlungsziel_2__c = '15',
            Rechnungsperiode_2__c = '10',
            Total_consumption_l_month__c = 1000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Anzahl_der_Karten__c = 1,
            Zahlungsart__c = 'Lastschrift',
            Language_preference__c = 'Slovak',
            IBAN__c = 'SK3112000000198742637541',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test',
            e_Invoicing_PDF__c = true,
            Papierrechnung__c = false);
        return opportunity;
    }

    /*******************************************************************************
    *  Summary         : Generate Contact object
    *  Created         : 09/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactSK() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Štefan',
            FirstName = 'Sinčák',
            Email = 'stefan.sincak@test.com',
            Birthdate = Date.newInstance(1996, 08, 20));
        return contact;
    }


    /*******************************************************************************
    *  Summary         : generate Black List object
    *  CreatedDate     : 09/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanySK() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'SK',
            Customer_Full_Name__c = 'Štefan Sinčák',
            TAX_ID__c = '50521969',
            VATReg_Number__c = 'SK1048346145',
            Trade_Register_Number__c = '1048346145',
            Reg_Address_Address_Lines__c = 'Povstania českého ľudu 738/7',
            Reg_Address_City__c = 'Košice - Dargovských hrdinov',
            Reg_Address_Zip_Code__c = '040 22',
            Primary_Phone__c = '12341234',
            Primary_Email__c = 'stefan.sincak@test.com',
            Primary_Contact__c = 'Štefan Sinčák',
            IBAN__c = 'SK3112000000198742637541',
            IP_Address__c = '12341234');
        return blackList;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for BE
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportSK() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'Štefan Sinčák',
            Name__c = 'Štefan Sinčák',
            Street__c = 'Povstania českého ľudu 738/7',
            City__c = 'Košice - Dargovských hrdinov',
            Postcode__c = '040 22',
            Date_of_Foundation__c = '2007-05-26',
            Class_Rating__c = '4',
            Principal_Activity_Code__c = '82.19',
            Principal_Activity_Description__c = 'Photocopying, document preparation and other specialised office support activities',
            VAT_Number__c = 'SK1048346145',
            Tax_Id__c = '50521969',
            Trade_Register_Number__c = '35227/B',
            County_Court__c = 'Okresní soud Bratislava I',
            Credit_Limit__c = '10000'
        );

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object for BE
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeSK() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Štefan Sinčák'
        );

        return reportEmployee;
    }


    /*******************************************************************************
    *  Summary         : Generate Opportunity object
    *  Created         : 08/06/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunitySKCCS() {
        Opportunity opportunity = new Opportunity(
                Name = 'Štefan Sinčák',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate',
                Zahlungsziel_2__c = '15',
                Rechnungsperiode_2__c = '2',
                Total_consumption_l_month__c = 1000,
                Derzeitige_Zahlungsmethode__c = 'Barzahlung',
                Anzahl_der_Karten__c = 1,
                Zahlungsart__c = 'Lastschrift',
                Language_preference__c = 'Czech',
                IBAN__c = 'CZ6508000000192000145399',
                SWIFT_BIC__c = 'AA12341234',
                Requested_SWIFT_BIC__c = 'AA12341234',
                Product__c = 'Sales no fee promo Feb 2016',
                Home_Station__c = 'test',
                ESI__c = 'test',
                e_Invoicing_PDF__c = true,
                Papierrechnung__c = false);
        return opportunity;
    }


    /*******************************************************************************
    *  Summary         : Generate Account object
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountCZ() {
        Account account = new Account(
            Name = 'Pavel Dziura',
            BillingStreet = 'Bejblíkova 199',
            BillingPostalCode = '391 11',
            BillingCity = 'Planá nad Lužnicí',
            BillingCountry = 'Czech Republic',
            BillingCountryCode = 'CZ',
            ShippingStreet = 'Bejblíkova 199',
            ShippingPostalCode = '391 11',
            ShippingCity = 'Planá nad Lužnicí',
            ShippingCountry = 'Czech Republic',
            ShippingCountryCode = 'CZ',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Single person company confirmed',
            Steuernummer__c = '41909941',
            Umsatzsteuer_ID__c = 'CZ1048346145',
            HR_Abteilung_HRA_HRB_und_HR_Nummer__c = 'A 77353',
            Ort_der_Registrierung_Handelsregisterort__c = 'Městský soud v Praze');
        return account;
    }

    /*******************************************************************************
    *  Summary         : Generate Opportunity object
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityCZ() {
        Opportunity opportunity = new Opportunity(
            Name = 'Pavel Dziura',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Zahlungsziel_2__c = '15',
            Rechnungsperiode_2__c = '10',
            Total_consumption_l_month__c = 1000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Anzahl_der_Karten__c = 1,
            Zahlungsart__c = 'Lastschrift',
            Language_preference__c = 'Czech',
            IBAN__c = 'CZ6508000000192000145399',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test',
            e_Invoicing_PDF__c = true,
            Papierrechnung__c = false);
        return opportunity;
    }

    /*******************************************************************************
    *  Summary         : Generate Contact object
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactCZ() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Pavel',
            FirstName = 'Dziura',
            Email = 'pavel.dziura@test.com',
            Birthdate = Date.newInstance(1996, 08, 20));
        return contact;
    }


    /*******************************************************************************
    *  Summary         : generate Black List object
    *  CreatedDate     : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyCZ() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'CZ',
            Customer_Full_Name__c = 'Pavel Dziura',
            TAX_ID__c = '41909941',
            VATReg_Number__c = 'CZ1048346145',
            Trade_Register_Number__c = '1048346145',
            Reg_Address_Address_Lines__c = 'Bejblíkova 199',
            Reg_Address_City__c = 'Planá nad Lužnicí',
            Reg_Address_Zip_Code__c = '391 11',
            Primary_Phone__c = '12341234',
            Primary_Email__c = 'pavel.dziura@test.com',
            Primary_Contact__c = 'Pavel Dziura',
            IBAN__c = 'CZ6508000000192000145399',
            IP_Address__c = '12341234');
        return blackList;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportCZ() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'Pavel Dziura',
            Name__c = 'Pavel Dziura',
            Street__c = 'Bejblíkova 199',
            City__c = 'Planá nad Lužnicí',
            Postcode__c = '391 11',
            Date_of_Foundation__c = '2007-05-26',
            Class_Rating__c = '4',
            Principal_Activity_Code__c = '82.19',
            Principal_Activity_Description__c = 'Photocopying, document preparation and other specialised office support activities',
            VAT_Number__c = 'CZ1048346145',
            Tax_Id__c = '41909941',
            Trade_Register_Number__c = 'A 77353',
            County_Court__c = 'Městský soud v Praze',
            Credit_Limit__c = '1000000'
        );

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeCZ() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Pavel Dziura'
        );

        return reportEmployee;
    }


    /*******************************************************************************
    *  Summary         : Generate Cribis settings
    *  Created         : 12/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : cribis settings
    ******************************************************************************/
    public static CreditSystem__c generateCribisSetting() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Cribis',
            Endpoint__c = 'https://ws.cribis.sk/v2.1/CribisSKWS.asmx',
            Username__c = 'enfleetcor-T2T',
            Password__c = 'Pi1=f5',
            Supported_Countries__c = 'Slovakia');
        return creditSystem;
    }


    /*******************************************************************************
    *  Summary         : Generate Opportunity object
    *  Created         : 15/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityCZCCS() {
        Opportunity opportunity = new Opportunity(
                Name = 'Pavel Dziura',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate',
                Zahlungsziel_2__c = '15',
                Rechnungsperiode_2__c = '2',
                Total_consumption_l_month__c = 1000,
                Derzeitige_Zahlungsmethode__c = 'Barzahlung',
                Anzahl_der_Karten__c = 1,
                Zahlungsart__c = 'Lastschrift',
                Language_preference__c = 'Czech',
                IBAN__c = 'CZ6508000000192000145399',
                SWIFT_BIC__c = 'AA12341234',
                Requested_SWIFT_BIC__c = 'AA12341234',
                Product__c = 'Sales no fee promo Feb 2016',
                Home_Station__c = 'test',
                ESI__c = 'test',
                e_Invoicing_PDF__c = true,
                Papierrechnung__c = false);
        return opportunity;
    }


    /*******************************************************************************
    *  Summary         : Generate Account object
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountHU() {
        Account account = new Account(
            Name = 'Hild Ingatlanbefektető Kft.',
            BillingStreet = 'Lajos utca 74-76.',
            ShippingStreet = 'Lajos utca 74-76.',
            BillingPostalCode = '1036',
            ShippingPostalCode = '1036',
            BillingCity = 'BUDAPEST',
            ShippingCity = 'BUDAPEST',
            BillingCountry = 'Hungary',
            BillingCountryCode = 'HU',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Limited Liability Company',
            Steuernummer__c = '13373344-2-41',
            Umsatzsteuer_ID__c = 'HU13373344',
            HR_Abteilung_HRA_HRB_und_HR_Nummer__c = '0109731931');
        return account;
    }

    /*******************************************************************************
    *  Summary         : Generate Opportunity object
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityHU() {
        Opportunity opportunity = new Opportunity(
            Name = 'Hild Ingatlanbefektető Kft.',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Zahlungsziel_2__c = '7',
            Rechnungsperiode_2__c = '7',
            Total_consumption_l_month__c = 100,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Anzahl_der_Karten__c = 0,
            Zahlungsart__c = 'Lastschrift',
            Language_preference__c = 'Hungarian',
            IBAN__c = 'HU1234512345',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test',
            DocuSign_Status__c = 'Completed');
        return opportunity;
    }

    /*******************************************************************************
    *  Summary         : Generate Contact object
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactHU() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Tibor',
            FirstName = 'BIRÓ Balázs',
            MailingCountry = 'Hungary',
            MailingCountryCode = 'HU',
            Phone = '123123123',
            Email = 'balazstibor@test.com');
        return contact;
    }


    /*******************************************************************************
    *  Summary         : generate Black List object
    *  CreatedDate     : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyHU() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'HU',
            Customer_Full_Name__c = 'Hild Ingatlanbefektető Kft.',
            TAX_ID__c = '13373344-2-41',
            VATReg_Number__c = 'HU13373344',
            Trade_Register_Number__c = '0109731931',
            Reg_Address_Address_Lines__c = 'Lajos utca 74-76.',
            Reg_Address_City__c = 'BUDAPEST',
            Reg_Address_Zip_Code__c = '1036',
            Primary_Phone__c = '123123123',
            Primary_Email__c = 'balazstibor@test.com',
            Primary_Contact__c = 'BIRÓ Balázs Tibor',
            IBAN__c = 'HU10732001271601917900000000',
            IP_Address__c = '12341234');
        return blackList;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for HU
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportHU() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'Hild Ingatlanbefektető Kft.',
            Name__c = 'Hild Ingatlanbefektető Kft.',
            Trade_Name__c = 'Hild Ingatlanbefektető Kft.',
            Street__c = 'Lajos utca 74-76.  ',
            City__c = 'Budapest',
            Postcode__c = '1036',
            Date_of_Foundation__c = '19.11.2007',
            Class_Rating__c = '1',
            VAT_Number__c = 'HU13373344',
            Tax_Id__c = '13373344-2-41',
            Trade_Register_Number__c = '0109731931',
            Credit_Limit__c = '3000000',
            Profit_Loss_Last_Year__c = '10000000',
            Profit_Loss_Year_Before_Last__c = '10000000',
            Turn_Over_Last_Year__c = '100000000'
        );

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object for HU
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeHU() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Tibor BIRÓ Balázs'
        );

        return reportEmployee;
    }


    /*******************************************************************************
    *  Summary         : Generate Coface settings
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Coface settings
    ******************************************************************************/
    public static CreditSystem__c generateCofaceSetting() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Coface',
            Endpoint__c = 'https://test.cofacecentraleurope.com/iconwebservices',
            Username__c = 'Petr.Cermak@fleetcor.eu',
            Password__c = 'Fleetcor2021',
            Supported_Countries__c = 'Hungary');
        return creditSystem;
    }


    /*******************************************************************************
    *  Summary         : create order notification settings
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : order notification
    ******************************************************************************/
    public static CF_Order_Notifications__c createOrderNotificationHU() {
        CF_Order_Notifications__c notification = new CF_Order_Notifications__c();
        notification.Name = 'Hungary';
        notification.Active__c = true;
        notification.Email__c = 'test@test.com';
        return notification;
    }


    /*******************************************************************************
    *  Summary         : Generate DocuSign status HU
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : DocuSign status
    ******************************************************************************/
    public static dsfs__DocuSign_Status__c generateDocuSignStatusHU() {
        dsfs__DocuSign_Status__c docuSignStatus = new dsfs__DocuSign_Status__c(
            dsfs__Completed_Date_Time__c = Datetime.now(),
            Document_name__c = 'test',
            dsfs__Envelope_Status__c = 'Completed');
        return docuSignStatus;
    }

    /*******************************************************************************
    *  Summary         : Generate DocuSign recipient HU
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : DocuSign recipient
    ******************************************************************************/
    public static dsfs__DocuSign_Recipient_Status__c generateDocuSignRecipientHU() {
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient = new dsfs__DocuSign_Recipient_Status__c(
            Name = 'Tibor BIRÓ Balázs',
            dsfs__DocuSign_Recipient_Id__c = '1324123');
        return docuSignRecipient;
    }


    /*******************************************************************************
    *  Summary         : Generate Account object
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountCH() {
        Account account = new Account(
            Name = 'TESTO INDUSTRIAL SERVICES AG',
            BillingStreet = 'GEWERBESTRASSE 12A',
            ShippingStreet = 'GEWERBESTRASSE 12A',
            BillingPostalCode = '8132',
            ShippingPostalCode = '8132',
            BillingCity = 'EGG B. ZÜRICH',
            ShippingCity = 'EGG B. ZÜRICH',
            BillingCountry = 'Switzerland-DE',
            BillingCountryCode = 'CHDE',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Limited Liability Company',
            Steuernummer__c = 'CH02030307442',
            Umsatzsteuer_ID__c = 'CHE113471243');
        return account;
    }


    /*******************************************************************************
    *  Summary         : Generate Opportunity object
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityCH() {
        Opportunity opportunity = new Opportunity(
            Name = 'TESTO INDUSTRIAL SERVICES AG',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Zahlungsziel_2__c = '30',
            Rechnungsperiode_2__c = '27',
            Total_consumption_l_month__c = 1000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Anzahl_der_Karten__c = 0,
            Zahlungsart__c = 'Lastschrift',
            Language_preference__c = 'German',
            IBAN__c = 'CH0204835181107271000',
            SWIFT_BIC__c = 'testSWIFT123',
            Requested_SWIFT_BIC__c = 'testSWIFT123',
            Product__c = 'Home Station offer (v.1)',
            Home_Station__c = 'test',
            ESI__c = 'test');
        return opportunity;
    }


    /*******************************************************************************
    *  Summary         : Generate Contact object
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactCH() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'WOLFGANG',
            FirstName = 'HÄHNEL',
            MailingCountry = 'Switzerland-DE',
            MailingCountryCode = 'CHDE',
            Phone = '1234567890',
            Email = 'wolfgang@test.com');
        return contact;
    }


    /*******************************************************************************
    *  Summary         : generate Black List object
    *  CreatedDate     : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyCH() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'CH',
            Customer_Full_Name__c = 'TESTO INDUSTRIAL SERVICES AG',
            TAX_ID__c = 'CH02030307442',
            VATReg_Number__c = 'CHE113471243',
            Trade_Register_Number__c = 'CHE113471243',
            Reg_Address_Address_Lines__c = 'GEWERBESTRASSE 12A',
            Reg_Address_City__c = 'EGG B. ZÜRICH',
            Reg_Address_Zip_Code__c = '8132',
            Primary_Phone__c = '1234567890',
            Primary_Email__c = 'wolfgang@test.com',
            Primary_Contact__c = 'HÄHNEL WOLFGANG',
            IBAN__c = 'CH0204835181107271000',
            IP_Address__c = '12341234');
        return blackList;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for CH
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportCH() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'TESTO INDUSTRIAL SERVICES AG',
            Name__c = 'TESTO INDUSTRIAL SERVICES AG',
            Trade_Name__c = 'TESTO INDUSTRIAL SERVICES AG',
            Street__c = 'GEWERBESTRASSE',
            City__c = 'EGG B. ZÜRICH',
            Housenumber__c = '12A',
            Postcode__c = '8132',
            Date_of_Foundation__c = '2007-02-28T00:00:00',
            Class_Rating__c = '1',
            VAT_Number__c = 'CHE113471243',
            Tax_Id__c = 'CH02030307442',
            Credit_Limit__c = '80000',
            Date_Of_Last_Change_Of_Director__c = '02.2009',
            Date_Of_Last_Change_Of_Address__c = '09.2010',
            Date_Of_Last_Change_Of_Name__c = '09.2010'
        );

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object for CH
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeCH() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'HÄHNEL WOLFGANG'
        );

        return reportEmployee;
    }


    /*******************************************************************************
    *  Summary         : Generate Coface settings
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Coface settings
    ******************************************************************************/
    public static CreditSystem__c generateCrediconnectSetting() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CrediconnectCH',
            Endpoint__c = 'https://webservice.crediconnect.ch/V2/03/CrediConnect.svc/basic',
            UserName__c = 'VENT4CC20_CONNECT',
            Password__c = 'CON4CC20VENT99',
            Supported_Countries__c = 'Switzerland-DE, Switzerland-FR, Switzerland-IT');
        return creditSystem;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Account object for AT
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountAT() {
        Account account = new Account(
            Name = 'AT KUNDENTESTSYSTEM GMBH - BITTE NICHT ÄNDERN',
            BillingStreet = 'NEUGASSE 1',
            ShippingStreet = 'NEUGASSE 1',
            BillingPostalCode = '2560',
            ShippingPostalCode = '2560',
            BillingCity = 'BERNDORF',
            ShippingCity = 'BERNDORF',
            BillingCountry = 'Austria',
            BillingCountryCode = 'AT',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Limited Liability Company',
            Steuernummer__c = 'AT1234567',
            Umsatzsteuer_ID__c = 'AT87654321');
        return account;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Opportunity object for AT
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityAT() {
        Opportunity opportunity = new Opportunity(
            Name = 'AT KUNDENTESTSYSTEM GMBH - BITTE NICHT ÄNDERN',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 800,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '15',
            Rechnungsperiode_2__c = '7',
            Anzahl_der_Karten__c = 1,
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
            Language_preference__c = 'Dutch',
            IBAN__c = 'LU280019400644750000',
            SWIFT_BIC__c = 'BCEELULL',
            Requested_SWIFT_BIC__c = 'BCEELULL',
            Product__c = 'Home Station offer (v.1)',
            Home_Station__c = 'test',
            ESI__c = 'test',
            Sec_Channel__c = 'Inbound',
            Einwilligung_Lastschriftverfahren__c = false);
        return opportunity;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Contact object for AT
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactAT() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'LAMBERT',
            FirstName = 'LUDEWIG',
            Phone = '123123412345',
            Email = 'testat@test.at');
        return contact;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate Black List object
    *  CreatedDate     : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyAT() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'AT',
            Customer_Full_Name__c = 'AT KUNDENTESTSYSTEM GMBH - BITTE NICHT ÄNDERN',
            TAX_ID__c = 'AT1234567',
            VATReg_Number__c = 'AT87654321',
            Trade_Register_Number__c = 'AT87654321',
            Reg_Address_Address_Lines__c = 'NEUGASSE 1',
            Reg_Address_City__c = 'BERNDORF',
            Reg_Address_Zip_Code__c = '2560',
            Primary_Phone__c = '123123412345',
            Primary_Email__c = 'testat@test.at',
            Primary_Contact__c = 'LUDEWIG LAMBERT',
            IBAN__c = 'LU280019400644750000',
            IP_Address__c = '12341234');
        return blackList;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for AT
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportAT() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'AT KUNDENTESTSYSTEM GMBH - BITTE NICHT ÄNDERN',
            Name__c = 'AT KUNDENTESTSYSTEM GMBH - BITTE NICHT ÄNDERN',
            Trade_Name__c = 'AT-KTO-GMBH',
            Street__c = 'Neugasse',
            City__c = 'Berndorf',
            Housenumber__c = '1',
            Postcode__c = '2560',
            Date_of_Foundation__c = '2015-09-01',
            Class_Rating__c = '1',
            VAT_Number__c = 'AT87654321',
            Tax_Id__c = 'AT1234567',
            Credit_Limit__c = '3000'
        );

        return report;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object for AT
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeAT() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'LUDEWIG LAMBERT'
        );

        return reportEmployee;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Coface settings
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Creditreform settings
    ******************************************************************************/
    public static CreditSystem__c generateCreditreformSettings() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CreditreformAT',
            Endpoint__c = 'https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl',
            UserName__c = '345013323001',
            Password__c = '1ppf39vE',
            API_Key__c = 'CFflt123',
            Supported_Countries__c = 'Austria');
        return creditSystem;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Account object for LU
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account generateAccountLU() {
        Account account = new Account(
            Name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN',
            BillingStreet = 'BLD. PIERRE ROT 169',
            ShippingStreet = 'BLD. PIERRE ROT 169',
            BillingPostalCode = '1543',
            ShippingPostalCode = '1543',
            BillingCity = 'LUXEMBOURG',
            ShippingCity = 'LUXEMBOURG',
            BillingCountry = 'Luxembourg',
            BillingCountryCode = 'LU',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Limited Liability Company',
            Steuernummer__c = 'LU1234567',
            Umsatzsteuer_ID__c = 'LU87654321');
        return account;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Opportunity object for LU
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity generateOpportunityLU() {
        Opportunity opportunity = new Opportunity(
            Name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 800,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '15',
            Rechnungsperiode_2__c = '7',
            Anzahl_der_Karten__c = 1,
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
            Language_preference__c = 'Dutch',
            IBAN__c = 'LU280019400644750000',
            SWIFT_BIC__c = 'BCEELULL',
            Requested_SWIFT_BIC__c = 'BCEELULL',
            Product__c = 'Home Station offer (v.1)',
            Home_Station__c = 'test',
            ESI__c = 'test',
            Sec_Channel__c = 'Inbound',
            Einwilligung_Lastschriftverfahren__c = false);
        return opportunity;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Contact object for LU
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact generateContactLU() {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'ALAIN',
            FirstName = 'AUTEIL - KTO',
            Phone = '123123412345',
            Email = 'testat@test.at');
        return contact;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate Black List object
    *  CreatedDate     : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public static Credit_Black_List_Company__c generateBlackListCompanyLU() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Id__c = 'LU',
            Customer_Full_Name__c = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN',
            TAX_ID__c = 'LU1234567',
            VATReg_Number__c = 'LU87654321',
            Trade_Register_Number__c = 'LU87654321',
            Reg_Address_Address_Lines__c = 'BLD. PIERRE ROT 169',
            Reg_Address_City__c = 'LUXEMBOURG',
            Reg_Address_Zip_Code__c = '1543',
            Primary_Phone__c = '123123412345',
            Primary_Email__c = 'testat@test.at',
            Primary_Contact__c = 'ALAIN AUTEIL - KTO',
            IBAN__c = 'LU280019400644750000',
            IP_Address__c = '12341234');
        return blackList;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report__c object for LU
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c generateCreditFactoryReportLU() {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
            Name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN',
            Name__c = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN',
            Trade_Name__c = 'KTO TV International',
            Street__c = 'Bld. Pierre Rot',
            City__c = 'Luxembourg',
            Housenumber__c = '169',
            Postcode__c = '1543',
            Date_of_Foundation__c = '1972-12-20',
            Class_Rating__c = '1',
            VAT_Number__c = 'AT87654321',
            Tax_Id__c = 'AT1234567',
            Credit_Limit__c = '3000'
        );

        return report;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_Report_Employee__c object for LU
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : report employee
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c generateCreditFactoryReportEmployeeLU() {
        Credit_Factory_Report_Employee__c reportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'ALAIN AUTEIL - KTO'
        );

        return reportEmployee;
    }


    /*******************************************************************************
    *  Summary         : Generate Opportunity Contact Role
    *  Created         : 13/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole generateOpportunityContactRole() {
        OpportunityContactRole role = new OpportunityContactRole(
            Role = 'Fleet manager',
            IsPrimary = true);
        return role;
    }


    /*******************************************************************************
    *  Summary         : select Opportunity from database
    *  Created         : 09/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : opportunity
    ******************************************************************************/
    public static Opportunity selectOpportunity() {
        Opportunity opportunity = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        return opportunity;
    }


    /*******************************************************************************
    *  Summary         : select Account from database
    *  Created         : 18/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : opportunity
    ******************************************************************************/
    public static Account selectAccount() {
        Account account = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        return account;
    }


    /*******************************************************************************
    *  Summary         : select Credit Factory Report from database
    *  Created         : 16/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : report
    ******************************************************************************/
    public static Credit_Factory_Report__c selectCreditFactoryReport() {
        Credit_Factory_Report__c report = [
            SELECT Id
            FROM Credit_Factory_Report__c
            LIMIT 1
        ];

        return report;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit_Factory_User_Profile__c object
    *  CreatedDate     : 19/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : profile
    ******************************************************************************/
    public static Credit_Factory_User_Profile__c generateCreditFactoryUserProfile() {
        Credit_Factory_User_Profile__c creditFactoryUserProfile = new Credit_Factory_User_Profile__c(
            Name = 'System Administrator'
        );

        return creditFactoryUserProfile;
    }


    /*******************************************************************************
    *  Summary         : Return settings with mapping between solvency and rating for DE
    *  CreatedDate     : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Solvency__c
    ******************************************************************************/
    public static Solvency__c returnSolvencySettingsDE() {
        Solvency__c solvency = new Solvency__c(
            Name = 'Germany',
            Rating_1_Minimum__c = 100,
            Rating_2_Minimum__c = 217,
            Rating_3_Minimum__c = 246,
            Rating_4_Minimum__c = 284,
            Rating_5_Minimum__c = 303,
            Rating_6_Minimum__c = 359,
            Rating_1_Maximum__c = 216,
            Rating_2_Maximum__c = 246,
            Rating_3_Maximum__c = 283,
            Rating_4_Maximum__c = 302,
            Rating_5_Maximum__c = 358,
            Rating_6_Maximum__c = 600);
        return solvency;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return settings with mapping between solvency and rating for CH
    *  CreatedDate     : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Solvency__c
    ******************************************************************************/
    public static Solvency__c returnSolvencySettingsCH() {
        Solvency__c solvency = new Solvency__c(
            Name = 'Switzerland',
            Rating_1_Minimum__c = 91,
            Rating_2_Minimum__c = 81,
            Rating_3_Minimum__c = 71,
            Rating_4_Minimum__c = 60,
            Rating_5_Minimum__c = 39,
            Rating_6_Minimum__c = 0,
            Rating_1_Maximum__c = 100,
            Rating_2_Maximum__c = 90,
            Rating_3_Maximum__c = 80,
            Rating_4_Maximum__c = 70,
            Rating_5_Maximum__c = 59,
            Rating_6_Maximum__c = 38);
        return solvency;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return settings with mapping between solvency and rating for AT
    *  CreatedDate     : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Solvency__c
    ******************************************************************************/
    public static Solvency__c returnSolvencySettingsAT() {
        Solvency__c solvency = new Solvency__c(
            Name = 'Austria',
            Rating_1_Minimum__c = 100,
            Rating_2_Minimum__c = 252,
            Rating_3_Minimum__c = 273,
            Rating_4_Minimum__c = 302,
            Rating_5_Minimum__c = 349,
            Rating_6_Minimum__c = 409,
            Rating_1_Maximum__c = 251,
            Rating_2_Maximum__c = 272,
            Rating_3_Maximum__c = 301,
            Rating_4_Maximum__c = 348,
            Rating_5_Maximum__c = 408,
            Rating_6_Maximum__c = 600);
        return solvency;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return settings with mapping between solvency and rating for LU
    *  CreatedDate     : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Solvency__c
    ******************************************************************************/
    public static Solvency__c returnSolvencySettingsLU() {
        Solvency__c solvency = new Solvency__c(
            Name = 'Luxembourg',
            Rating_1_Minimum__c = 100,
            Rating_2_Minimum__c = 217,
            Rating_3_Minimum__c = 247,
            Rating_4_Minimum__c = 284,
            Rating_5_Minimum__c = 303,
            Rating_6_Minimum__c = 359,
            Rating_1_Maximum__c = 216,
            Rating_2_Maximum__c = 246,
            Rating_3_Maximum__c = 283,
            Rating_4_Maximum__c = 302,
            Rating_5_Maximum__c = 358,
            Rating_6_Maximum__c = 600);
        return solvency;
    }


    /*******************************************************************************
    *  Summary         : Generate KRD settings
    *  Created         : 07/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : KRS settings
    ******************************************************************************/
    public static CreditSystem__c generateKrdSetting() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'KRD',
            Endpoint__c = 'https://demo.krd.pl/Chase/3.1/Search.svc/basic',
            Username__c = 'F5FF0EA58D',
            Password__c = 'krd123');
        return creditSystem;
    }

    
    /*******************************************************************************
    *  Summary         : Generate LexisNexis settings   
    *  Created         : 15/04/2020
    *  Parameters      : -
    *  Returns         : Lexis Nexis settings
    ******************************************************************************/
    public static LexisNexis_Settings__c generateLexisNexisSetting() {
        LexisNexis_Settings__c lexisNexisSettings = new LexisNexis_Settings__c(
            Name = 'Production',
            Active__c = true,
            Endpoint__c = 'https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php',
            User_Name__c = '20017531',
            Password__c = 'Fleetcor2020');
        return lexisNexisSettings;
    }
    
    /*******************************************************************************
    *  Summary         : Generate DocuSign status   
    *  Created         : 15/04/2020
    *  Parameters      : -
    *  Returns         : DocuSign status
    ******************************************************************************/
    public static dsfs__DocuSign_Status__c generateDocuSignStatus() {
        dsfs__DocuSign_Status__c docuSignStatus = new dsfs__DocuSign_Status__c(
            dsfs__Completed_Date_Time__c = Datetime.now(),
            Document_name__c = 'Zgoda na weryfikację (DocuSign).pdf',
            dsfs__Envelope_Status__c = 'Completed');
        return docuSignStatus;
    }
    
    /*******************************************************************************
    *  Summary         : Generate DocuSign recipient   
    *  Created         : 15/04/2020
    *  Parameters      : -
    *  Returns         : DocuSign recipient
    ******************************************************************************/
    public static dsfs__DocuSign_Recipient_Status__c generateDocuSignRecipient() {
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient = new dsfs__DocuSign_Recipient_Status__c(
            Name = 'Mariusz Wernyks',
            dsfs__DocuSign_Recipient_Id__c = '1324123');
        return docuSignRecipient;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate BIG settings
    *  CreatedDate     : 16/04/2020
    *  Parameters      : -
    *  Returns         : big setting
    ******************************************************************************/
    public static BIG__c generateBigSetting() {
        BIG__c bigSettings = new BIG__c(
            Name = 'Test',
            Active__c = true,
            Endpoint__c = 'https://wasstt.infomonitor.pl:443/bigApi/v1/ReportOrderService', 
            User_Name__c = 'USER188247', 
            Password__c = '8NC1p1696Y',
            Client_Id__c = '1777717777',
            Test_Data_Marker__c = true);
        return bigSettings;
    }


    /*******************************************************************************
    *  Summary         : Generate order notification settings for DE
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : order notification settings
    ******************************************************************************/
    public static CF_Order_Notifications__c generateOrderNotificationsSettingsDE() {
        CF_Order_Notifications__c orderNotifications = new CF_Order_Notifications__c(
            Name = 'Germany',
            Active__c = true,
            Email__c = 'test@test.com');
        return orderNotifications;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Tankkarten
    *  CreatedDate     : 17/04/2020
    *  Parameters      : -
    *  Returns         : tankkarten
    ******************************************************************************/
    public static Tankkarten__c generateTankkarten() {
        Tankkarten__c card = new Tankkarten__c(
            Gewuenschter_Kartentyp__c = 'Multi Network Card -- National',
            Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)',
            Fahrzeugtyp__c = 'PKW',
            Firmenname_auf_der_Karte__c = 'Test firm name',
            Driver_Name__c = 'test driver name');
        return card;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Line Item
    *  CreatedDate     : 17/04/2020
    *  Parameters      : -
    *  Returns         : line item
    ******************************************************************************/
    public static Product2 generateProduct2() {
        Product2 product2 = new Product2(
            Family = 'SHELL',
            Name = 'Test',
            Integration_Name__c = 'test');
        return product2;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Price Book Entry   
    *  Created         : 17/04/2020
    *  Parameters      : -
    *  Returns         : price book entry
    ******************************************************************************/
    public static PricebookEntry generatePricebookEntry() {
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 10000, 
            IsActive = true);
        return pricebookEntry;
    } 
    
    
    /*******************************************************************************
    *  Summary         : Generate Line Item
    *  CreatedDate     : 17/04/2020
    *  Parameters      : -
    *  Returns         : line item
    ******************************************************************************/
    public static OpportunityLineItem generateLineItem() {
        OpportunityLineItem lineItem = new OpportunityLineItem(
            Quantity = 1,
            TotalPrice = 0);
        return lineItem;
    }


    /*******************************************************************************
    *  Summary         : Generate offer item type
    *  CreatedDate     : 17/04/2020
    *  Parameters      : -
    *  Returns         : line item
    ******************************************************************************/
    public static Offer_Item_Type__c generateOfferItemType() {
        Offer_Item_Type__c offerItemType = new Offer_Item_Type__c(
            Name = 'Shell Fuel Card');
        return offerItemType;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate Line Item
    *  CreatedDate     : 17/04/2020
    *  Parameters      : -
    *  Returns         : line item
    ******************************************************************************/
    public static Offer_Item__c generateOfferItem() {
        Offer_Item__c offerItem = new Offer_Item__c();
        return offerItem;
    }


    /*******************************************************************************
    *  Summary         : Generate Attachment for order request
    *  CreatedDate     : 12/04/2021
    *  Parameters      : -
    *  Returns         : Attachment
    ******************************************************************************/
    public static Attachment generateGWAAttachment() {
        Attachment attachment = new Attachment(
            Name = 'GWA',
            Body = Blob.valueOf('test')
        );

        return attachment;
    }


    /*******************************************************************************
    *  Summary         : Generate Content Version
    *  CreatedDate     : 12/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : ContentVersion
    ******************************************************************************/
    public static ContentVersion generateContentVersion() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'GWA',
            VersionData = Blob.valueOf('test'),
            PathOnClient = 'test.pdf'
        );

        return contentVersion;
    }


    /*******************************************************************************
    *  Summary         : Generate Content Document Link
    *  CreatedDate     : 12/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : ContentDocumentLink
    ******************************************************************************/
    public static ContentDocumentLink generateContentDocumentLink() {
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        return contentDocumentLink;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit Factory Calculations DE
    *  CreatedDate     : 11/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : List<Credit_Factory_Calculation__c>
    ******************************************************************************/
    public static List<Credit_Factory_Calculation__c> generateCreditFactoryCalculationsDE() {
        List<Credit_Factory_Calculation__c> calculations = new List<Credit_Factory_Calculation__c>();
        calculations.add(new Credit_Factory_Calculation__c(
            Country__c = 'Germany',
            Class_Rating__c = '1',
            Date_of_Foundation_month__c = '<=18',
            Number_of_Cards__c = '<=1',
            Total_Consumption_Min_Value__c = '0',
            Total_Consumption_Max_Value__c = '600',
            Order__c = 1,
            Payment_Detail__c = '7+7'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
            Country__c = 'Germany',
            Class_Rating__c = '2',
            Date_of_Foundation_month__c = '<=18',
            Number_of_Cards__c = '<=1',
            Total_Consumption_Min_Value__c = '0',
            Total_Consumption_Max_Value__c = '600',
            Order__c = 2,
            Payment_Detail__c = '7+7'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
            Country__c = 'Germany',
            Class_Rating__c = '4',
            Date_of_Foundation_month__c = '<=18',
            Number_of_Cards__c = '<=1',
            Total_Consumption_Min_Value__c = '0',
            Total_Consumption_Max_Value__c = '600',
            Order__c = 4,
            Payment_Detail__c = '7+7'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
            Country__c = 'Germany',
            Class_Rating__c = '6',
            Date_of_Foundation_month__c = '*',
            Number_of_Cards__c = '*',
            Total_Consumption_Min_Value__c = '*',
            Total_Consumption_Max_Value__c = '*',
            Order__c = 6,
            Security_Level__c = '110',
            Payment_Detail__c = '*'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
            Country__c = 'Germany',
            Class_Rating__c = '*',
            Date_of_Foundation_month__c = '<=18',
            Number_of_Cards__c = '*',
            Total_Consumption_Min_Value__c = '*',
            Total_Consumption_Max_Value__c = '*',
            Order__c = 7,
            Security_Level__c = '100',
            Payment_Detail__c = '*',
            Deposit_Reason__c = 'New business'
        ));

        return calculations;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit Factory Calculations PL
    *  CreatedDate     : 11/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : List<Credit_Factory_Calculation__c>
    ******************************************************************************/
    public static List<Credit_Factory_Calculation__c> generateCreditFactoryCalculationsPL() {
        List<Credit_Factory_Calculation__c> calculations = new List<Credit_Factory_Calculation__c>();
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Poland',
                Class_Rating__c = '1',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '450',
                Order__c = 1,
                Payment_Detail__c = '7+7'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Poland',
                Class_Rating__c = '2',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '450',
                Order__c = 2,
                Payment_Detail__c = '7+7'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Poland',
                Class_Rating__c = '*',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '*',
                Total_Consumption_Min_Value__c = '*',
                Total_Consumption_Max_Value__c = '*',
                Order__c = 3,
                Payment_Detail__c = '*',
                Security_Level__c = '100',
                Deposit_Reason__c = 'New business'
        ));

        return calculations;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit Factory Calculations BE
    *  CreatedDate     : 21/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : List<Credit_Factory_Calculation__c>
    ******************************************************************************/
    public static List<Credit_Factory_Calculation__c> generateCreditFactoryCalculationsBE() {
        List<Credit_Factory_Calculation__c> calculations = new List<Credit_Factory_Calculation__c>();
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Belgium',
                Class_Rating__c = '1',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 1,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Belgium',
                Class_Rating__c = '2',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 2,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Belgium',
                Class_Rating__c = '3',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 3,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Belgium',
                Class_Rating__c = '4',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 4,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Belgium',
                Class_Rating__c = '5',
                Date_of_Foundation_month__c = '*',
                Number_of_Cards__c = '*',
                Total_Consumption_Min_Value__c = '*',
                Total_Consumption_Max_Value__c = '*',
                Order__c = 5,
                Payment_Detail__c = '*',
                Security_Level__c = '110',
                Deposit_Reason__c = 'Low credit rating (rating 5)'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Belgium',
                Class_Rating__c = '*',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '*',
                Total_Consumption_Min_Value__c = '*',
                Total_Consumption_Max_Value__c = '*',
                Order__c = 6,
                Payment_Detail__c = '*',
                Security_Level__c = '100',
                Deposit_Reason__c = 'New business'
        ));

        return calculations;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit Factory Calculations NL
    *  CreatedDate     : 21/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : List<Credit_Factory_Calculation__c>
    ******************************************************************************/
    public static List<Credit_Factory_Calculation__c> generateCreditFactoryCalculationsNL() {
        List<Credit_Factory_Calculation__c> calculations = new List<Credit_Factory_Calculation__c>();
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Netherlands',
                Class_Rating__c = '1',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 1,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Netherlands',
                Class_Rating__c = '2',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 2,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Netherlands',
                Class_Rating__c = '3',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 3,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Netherlands',
                Class_Rating__c = '4',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 4,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Netherlands',
                Class_Rating__c = '5',
                Date_of_Foundation_month__c = '*',
                Number_of_Cards__c = '*',
                Total_Consumption_Min_Value__c = '*',
                Total_Consumption_Max_Value__c = '*',
                Order__c = 5,
                Payment_Detail__c = '*',
                Security_Level__c = '110',
                Deposit_Reason__c = 'Low credit rating (rating 5)'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Netherlands',
                Class_Rating__c = '*',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '*',
                Total_Consumption_Min_Value__c = '*',
                Total_Consumption_Max_Value__c = '*',
                Order__c = 6,
                Payment_Detail__c = '*',
                Security_Level__c = '100',
                Deposit_Reason__c = 'New business'
        ));

        return calculations;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit Factory Calculations CH
    *  CreatedDate     : 30/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : List<Credit_Factory_Calculation__c>
    ******************************************************************************/
    public static List<Credit_Factory_Calculation__c> generateCreditFactoryCalculationsCH() {
        List<Credit_Factory_Calculation__c> calculations = new List<Credit_Factory_Calculation__c>();
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Switzerland',
                Class_Rating__c = '1',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '350',
                Order__c = 1,
                Payment_Detail__c = '30+14',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Switzerland',
                Class_Rating__c = '2',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '350',
                Order__c = 2,
                Payment_Detail__c = '30+14',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Switzerland',
                Class_Rating__c = '3',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '350',
                Order__c = 3,
                Payment_Detail__c = '30+14',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Switzerland',
                Class_Rating__c = '4',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '350',
                Order__c = 4,
                Payment_Detail__c = '30+14',
                New_Business_Exception__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Switzerland',
                Class_Rating__c = '*',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '*',
                Total_Consumption_Min_Value__c = '*',
                Total_Consumption_Max_Value__c = '*',
                Order__c = 5,
                Payment_Detail__c = '*',
                Security_Level__c = '33',
                Deposit_Reason__c = 'New business'
        ));

        return calculations;
    }


    /*******************************************************************************
    *  Summary         : Generate Credit Factory Calculations CH
    *  CreatedDate     : 17/06/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : List<Credit_Factory_Calculation__c>
    ******************************************************************************/
    public static List<Credit_Factory_Calculation__c> generateCreditFactoryCalculationsHU() {
        List<Credit_Factory_Calculation__c> calculations = new List<Credit_Factory_Calculation__c>();
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Hungary',
                Class_Rating__c = '4',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=2',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 1,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true,
                High_Risk__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Hungary',
                Class_Rating__c = '5',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=2',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 2,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true,
                High_Risk__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Hungary',
                Class_Rating__c = '6',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=2',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 3,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true,
                High_Risk__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Hungary',
                Class_Rating__c = '7',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=2',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 4,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true,
                High_Risk__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Hungary',
                Class_Rating__c = '10',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=2',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 5,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true,
                High_Risk__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Hungary',
                Class_Rating__c = '99',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=2',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 6,
                Payment_Detail__c = '7+7',
                New_Business_Exception__c = true,
                High_Risk__c = true
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Hungary',
                Class_Rating__c = '0',
                Date_of_Foundation_month__c = '*',
                Number_of_Cards__c = '*',
                Total_Consumption_Min_Value__c = '*',
                Total_Consumption_Max_Value__c = '*',
                Order__c = 7,
                Payment_Detail__c = '*',
                Security_Level__c = '110',
                Deposit_Reason__c = 'Low credit rating (rating 0)'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Hungary',
                Class_Rating__c = '3',
                Date_of_Foundation_month__c = '*',
                Number_of_Cards__c = '*',
                Total_Consumption_Min_Value__c = '*',
                Total_Consumption_Max_Value__c = '*',
                Order__c = 8,
                Payment_Detail__c = '*',
                Security_Level__c = '110',
                Deposit_Reason__c = 'Low credit rating (rating 3)'
        ));
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Hungary',
                Class_Rating__c = '*',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '*',
                Total_Consumption_Min_Value__c = '*',
                Total_Consumption_Max_Value__c = '*',
                Order__c = 9,
                Payment_Detail__c = '*',
                Security_Level__c = '100',
                Deposit_Reason__c = 'New business'
        ));

        return calculations;
    }
}