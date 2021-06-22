public class EcEuropaEu {
    public class checkVatResponse_element {
        public String countryCode;
        public String vatNumber;
        public Date requestDate;
        public Boolean valid;
        public String name;
        public String address;
        private String[] countryCode_type_info = new String[]{'countryCode','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] vatNumber_type_info = new String[]{'vatNumber','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] requestDate_type_info = new String[]{'requestDate','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] valid_type_info = new String[]{'valid','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] name_type_info = new String[]{'name','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','true'};
        private String[] address_type_info = new String[]{'address','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:ec.europa.eu:taxud:vies:services:checkVat:types','true','true'};
        private String[] field_order_type_info = new String[]{'countryCode','vatNumber','requestDate','valid','name','address'};
    }
    public class checkVat_element {
        public String countryCode;
        public String vatNumber;
        private String[] countryCode_type_info = new String[]{'countryCode','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] vatNumber_type_info = new String[]{'vatNumber','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:ec.europa.eu:taxud:vies:services:checkVat:types','true','true'};
        private String[] field_order_type_info = new String[]{'countryCode','vatNumber'};
    }
    public class checkVatApproxResponse_element {
        public String countryCode;
        public String vatNumber;
        public Date requestDate;
        public Boolean valid;
        public String traderName;
        public String traderCompanyType;
        public String traderAddress;
        public String traderStreet;
        public String traderPostcode;
        public String traderCity;
        public String traderNameMatch;
        public String traderCompanyTypeMatch;
        public String traderStreetMatch;
        public String traderPostcodeMatch;
        public String traderCityMatch;
        public String requestIdentifier;
        private String[] countryCode_type_info = new String[]{'countryCode','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] vatNumber_type_info = new String[]{'vatNumber','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] requestDate_type_info = new String[]{'requestDate','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] valid_type_info = new String[]{'valid','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] traderName_type_info = new String[]{'traderName','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','true'};
        private String[] traderCompanyType_type_info = new String[]{'traderCompanyType','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','true'};
        private String[] traderAddress_type_info = new String[]{'traderAddress','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderStreet_type_info = new String[]{'traderStreet','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderPostcode_type_info = new String[]{'traderPostcode','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderCity_type_info = new String[]{'traderCity','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderNameMatch_type_info = new String[]{'traderNameMatch','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderCompanyTypeMatch_type_info = new String[]{'traderCompanyTypeMatch','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderStreetMatch_type_info = new String[]{'traderStreetMatch','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderPostcodeMatch_type_info = new String[]{'traderPostcodeMatch','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderCityMatch_type_info = new String[]{'traderCityMatch','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] requestIdentifier_type_info = new String[]{'requestIdentifier','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:ec.europa.eu:taxud:vies:services:checkVat:types','true','true'};
        private String[] field_order_type_info = new String[]{'countryCode','vatNumber','requestDate','valid','traderName','traderCompanyType','traderAddress','traderStreet','traderPostcode','traderCity','traderNameMatch','traderCompanyTypeMatch','traderStreetMatch','traderPostcodeMatch','traderCityMatch','requestIdentifier'};
    }
    public class checkVatApprox_element {
        public String countryCode;
        public String vatNumber;
        public String traderName;
        public String traderCompanyType;
        public String traderStreet;
        public String traderPostcode;
        public String traderCity;
        public String requesterCountryCode;
        public String requesterVatNumber;
        private String[] countryCode_type_info = new String[]{'countryCode','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] vatNumber_type_info = new String[]{'vatNumber','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] traderName_type_info = new String[]{'traderName','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderCompanyType_type_info = new String[]{'traderCompanyType','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderStreet_type_info = new String[]{'traderStreet','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderPostcode_type_info = new String[]{'traderPostcode','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] traderCity_type_info = new String[]{'traderCity','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] requesterCountryCode_type_info = new String[]{'requesterCountryCode','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] requesterVatNumber_type_info = new String[]{'requesterVatNumber','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:ec.europa.eu:taxud:vies:services:checkVat:types','true','true'};
        private String[] field_order_type_info = new String[]{'countryCode','vatNumber','traderName','traderCompanyType','traderStreet','traderPostcode','traderCity','requesterCountryCode','requesterVatNumber'};
    }
    public class checkVatPort {
        public String endpoint_x = 'http://ec.europa.eu/taxation_customs/vies/services/checkVatService';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:ec.europa.eu:taxud:vies:services:checkVat:types', 'EcEuropaEu', 'urn:ec.europa.eu:taxud:vies:services:checkVat', 'EcEuropaEu'};
        public EcEuropaEu.checkVatApproxResponse_element checkVatApprox(String countryCode,String vatNumber,String traderName,String traderCompanyType,String traderStreet,String traderPostcode,String traderCity,String requesterCountryCode,String requesterVatNumber) {
            EcEuropaEu.checkVatApprox_element request_x = new EcEuropaEu.checkVatApprox_element();
            request_x.countryCode = countryCode;
            request_x.vatNumber = vatNumber;
            request_x.traderName = traderName;
            request_x.traderCompanyType = traderCompanyType;
            request_x.traderStreet = traderStreet;
            request_x.traderPostcode = traderPostcode;
            request_x.traderCity = traderCity;
            request_x.requesterCountryCode = requesterCountryCode;
            request_x.requesterVatNumber = requesterVatNumber;
            EcEuropaEu.checkVatApproxResponse_element response_x;
            Map<String, EcEuropaEu.checkVatApproxResponse_element> response_map_x = new Map<String, EcEuropaEu.checkVatApproxResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'urn:ec.europa.eu:taxud:vies:services:checkVat:types',
              'checkVatApprox',
              'urn:ec.europa.eu:taxud:vies:services:checkVat:types',
              'checkVatApproxResponse',
              'EcEuropaEu.checkVatApproxResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public EcEuropaEu.checkVatResponse_element checkVat(String countryCode,String vatNumber) {
            EcEuropaEu.checkVat_element request_x = new EcEuropaEu.checkVat_element();
            request_x.countryCode = countryCode;
            request_x.vatNumber = vatNumber;
            EcEuropaEu.checkVatResponse_element response_x;
            Map<String, EcEuropaEu.checkVatResponse_element> response_map_x = new Map<String, EcEuropaEu.checkVatResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'urn:ec.europa.eu:taxud:vies:services:checkVat:types',
              'checkVat',
              'urn:ec.europa.eu:taxud:vies:services:checkVat:types',
              'checkVatResponse',
              'EcEuropaEu.checkVatResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}