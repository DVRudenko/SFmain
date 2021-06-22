public without sharing class PPR_API_Validator {

    public static List<String> requiredEmailTypes = new List<String>{'LK accesses', 'Mail'};
    public static List<String> requiredPhoneTypes = new List<String>{'Main'};
    public static List<String> requiredAddresses = new List<String>{'Billing'};

    public String validationName;
    public Set<String> tariffs {get {
        if (tariffs == null) {
            tariffs = new Set<String>();
            for (LongForm_Tariff__c tariff: [SELECT Id, Name FROM LongForm_Tariff__c]) {
                tariffs.add(tariff.Name.toLowerCase());
            }	
        }
        return tariffs;
    } set;}
    public Set<String> products {get {
        if (products == null) {
            products = new Set<String>();
            for (LongForm_Fleetcor_Product__c product: [SELECT Id, Name FROM LongForm_Fleetcor_Product__c]) {
                products.add(product.Name.toLowerCase());
            }	
        }
        return products;
    } set;}
  
    public PPR_API_ResponseBody validateData(Map<String, Object> data) {
        if (validationName == null || validationName == '') return ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Validation error. ValidationName not found');
        Map<String, Object> requestValidationMap = PPR_Mapping_Utils.getValidationMap(validationName);
        for (String fieldName: requestValidationMap.keyset()) {
            String resultStr = validateData(fieldName, fieldName, (Map<String, Object>)requestValidationMap.get(fieldName), data.get(fieldName));
            if (resultStr != null) return ResponseBodyBuilder.constructPPR_API_ResponseBodyError(resultStr);
        }
        return null;
    }

    public String validateData(String fieldName, String fullPath, Map<String, Object> branch, Object requestPart) {
        if (branch.get('required') == 'true' || (branch.get('required') == 'false' && requestPart != null)) {
            if (requestPart == null) return 'Validation error. Parameter not found: ' + fullPath;
            switch on ((String)branch.get('type')).toLowerCase() {
                when 'string' {
                    return isFieldEmpty('string', fieldName, fullPath, requestPart);
                }
                when 'number' {
                    return isFieldEmpty('number', fieldName, fullPath, requestPart);
                }
                when 'container' {
                    Map<String, Object> chield = (Map<String, Object>)branch.get('contains');
                    for (String chieldName: chield.keyset()) {
                        String validationResult = validateData(chieldName, fullPath + ' > ' + chieldName, (Map<String, Object>)chield.get(chieldName), ((Map<String, Object>)requestPart).get(chieldName));
                        if (validationResult != null) return validationResult;
                    }
                    return null;
                }
                when 'list' {
                    Map<String, Object> chield = (Map<String, Object>)branch.get('contains');
                    if (branch.get('required') == 'true' && ((List<Object>) requestPart).size() == 0) return 'Validation error. List is empty: ' + fullPath;
                    for (Object obj: (List<Object>) requestPart) {
                        for (String chieldName: chield.keyset()) {
                            String validationResult = validateData(chieldName, fullPath + ' > ' + chieldName, (Map<String, Object>)chield.get(chieldName), ((Map<String, Object>)obj).get(chieldName));
                            if (validationResult != null) return validationResult;
                        }
                    }
                    return null;
                }
                when 'stringlist' {
                    if (branch.get('required') == 'true' && ((List<Object>) requestPart).size() == 0) return 'Validation error. List is empty: ' + fullPath;
                    for (Object obj: (List<Object>) requestPart) {
                        String validationResult = isFieldEmpty('string', fieldName, fullPath, obj);
                        if (validationResult != null) return validationResult;
                    }
                    return null;
                }
            }
        }
        return null;
    }

    public String validateField(String fieldName, String fullPath, Object value) {
        if (validationName == 'NewClientRequest') {
            /*
            *	Source – проверяется что такой источник данных есть в salesforce
            *	Id – проверка что это действительно id объекта E2EFormData
            *	Inn – в поле должны быть только цифры и длинна должна соответствовать длинне инн
            *	Codeword – поле должно содержать только кирилицу без других символов и пробелов 
            *	Email – содержимое должно будет соответствовать стандартному шаблону email
            *	Phone – должно будет соответствовать шаблону телефона
            *	Product – проверяется есть ли такой продукт в salesforce
            *	Tariff – проверяется указан ли такой тариф в salesforce
            *	bik – должно быть 9 цифр
            *	accountNum – должно быть 20 цифр
            *	zipCode – должно быть 6 цифр
            */
            Map<String, String> regs = new Map<String, String>{
                'phone' => '((8|\\+7|7)[\\- ]?)?(\\(?\\d\\)?[\\- ]?\\d\\)?[\\- ]?\\d\\)?[\\- ]?\\d\\)?[\\- ]?\\d\\)?[\\- ]?\\d\\)?[\\- ]?\\d\\)?[\\- ]?\\d\\)?[\\- ]?\\d\\)?[\\- ]?\\d)',
                'email' => '[\\w\\-\\.\\_]+@([\\w-]+\\.)+[a-zA-Z]{2,4}',
                'inn' => '\\d{10}|\\d{12}',
                'codeword' => '[а-яА-ЯёЁ]{1,15}',
                'bik' => '\\d{9}',
                'numberStr' => '\\d{10}',
                'accountnum' => '\\d{20}',
                'card' => '\\d{9,10}',
                'zipcode' => '\\d{6}'
            };
            switch on fieldName.toLowerCase() {
                when 'source' {
                    String source = (String)value;
                    PPR_API_Settings__c settings = PPR_API_Settings__c.getValues(source);
                    if (settings == null) {
                        return 'Invalid source parameter: ' + source;
                    } else if (Boolean.valueOf(settings.Block_API_Actions__c)) {
                        return 'API Service disabled';
                    }
                }
                when 'id' {
                    Id testedId = (String)value;
                    if (testedId.getSObjectType().getDescribe().getName() != 'E2EFormData__c') {
                        return 'Validation error. This isn\'t E2EFormData id: ' + testedId;
                    }
                }
                when 'inn' {
                    String inn = (String)value;
                    Pattern regexPatternInn = Pattern.compile(regs.get('inn'));
                    if (!regexPatternInn.matcher(inn).matches()) {
                        return 'Validation error. Invalid inn: ' + inn;
                    }
                }
                when 'codeword' {
                    String codeword = (String)value;
                    Pattern regexPatternInn = Pattern.compile(regs.get('codeword'));
                    if (!regexPatternInn.matcher(codeword).matches()) {
                        return 'Validation error. Invalid codeword: ' + codeword;
                    }
                }
                when 'email' {
                    String email = (String)value;
                    Pattern regexPatternInn = Pattern.compile(regs.get('email'));
                    if (!regexPatternInn.matcher(email).matches()) {
                        return 'Validation error. Invalid email: ' + email;
                    }
                }
                when 'value' {
                    if (fullPath.contains('emails')) {
                        String email = (String)value;
                        Pattern regexPatternInn = Pattern.compile(regs.get('email'));
                        if (!regexPatternInn.matcher(email).matches()) {
                            return 'Validation error. Invalid email: ' + email;
                        }
                    }
                }
                when 'phone' {
                    String phone = (String)value;
                    Pattern regexPatternInn = Pattern.compile(regs.get('phone'));
                    if (!regexPatternInn.matcher(phone).matches()) {
                        return 'Validation error. Invalid phone: ' + phone;
                    }
                }
                when 'product' {
                    String product = (String)value;
                    if(!products.contains(product.toLowerCase())) {
                        return 'Validation error. Invalid product: ' + product;
                    }
                }
                when 'tariff' {
                    String tariff = (String)value;
                    if(!tariffs.contains(tariff.toLowerCase())) {
                        return 'Validation error. Invalid tariff: ' + tariff;
                    }
                }
                when 'bik' {
                    String bik = (String)value;
                    Pattern regexPatternInn = Pattern.compile(regs.get('bik'));
                    if (!regexPatternInn.matcher(bik).matches()) {
                        return 'Validation error. Invalid bik: ' + bik;
                    }
                }
                when 'accountnum' {
                    String accountnum = (String)value;
                    Pattern regexPatternInn = Pattern.compile(regs.get('accountnum'));
                    if (!regexPatternInn.matcher(accountnum).matches()) {
                        return 'Validation error. Invalid account number: ' + accountnum;
                    }
                }
                when 'zipcode' {
                    String zipcode = (String)value;
                    Pattern regexPatternInn = Pattern.compile(regs.get('zipcode'));
                    if (!regexPatternInn.matcher(zipcode).matches()) {
                        return 'Validation error. Invalid zip code: ' + zipcode;
                    }
                }
                when 'numberstr' {
                    String numberStr = (String)value;
                    Pattern regexPatternInn = Pattern.compile(regs.get('numberStr'));
                    if (!regexPatternInn.matcher(numberStr).matches()) {
                        return 'Validation error. Invalid number: ' + numberStr;
                    }
                }
                when 'street' {
                    if (((String)value).length() > 255) {
                        return 'Validation error. Invalid street: ' + value;
                    }
                }
                when 'city' {
                    if (((String)value).length() > 40) {
                        return 'Validation error. Invalid city: ' + value;
                    }
                }
                when 'state' {
                    if (((String)value).length() > 80) {
                        return 'Validation error. Invalid state: ' + value;
                    }
                }
                when 'country' {
                    if (((String)value).length() > 40) {
                        return 'Validation error. Invalid country: ' + value;
                    }
                }
                when 'house' {
                    if (((String)value).length() > 255) {
                        return 'Validation error. Invalid house: ' + value;
                    }
                }
                when 'apartment' {
                    if (((String)value).length() > 255) {
                        return 'Validation error. Invalid apartment: ' + value;
                    }
                }
                when 'user' {
                    if (((String)value).length() > 100) {
                        return 'Validation error. Invalid user: ' + value;
                    }
                }
                when 'cards' {
                    String card = (String)value;
                    Pattern regexPatternInn = Pattern.compile(regs.get('card'));
                    if (!regexPatternInn.matcher(card).matches()) {
                        return 'Validation error. Invalid card: ' + card;
                    }
                }
            }
        }
        return null;
    }

    public String isFieldEmpty(String type, String fieldName, String fullPath, Object requestPart) {
        if ((type == 'string' && String.isBlank(''+requestPart)) || 
                   (type == 'number' && !((''+requestPart).replace('.', '')).isNumeric())) {
            return 'Validation error. Invalid parameter: ' + fullPath;
        }
        return validateField(fieldName, fullPath, requestPart);
    }

    public static Set<String> validateTypes(List<PPR_API_CreateClientRequest.Obj> objects, List<String> requiredTypes) {
        Set<String> required = new Set<String>(requiredTypes);
        if (objects != null) {
            for (PPR_API_CreateClientRequest.Obj obj : objects) {
                for (String type : obj.type) {
                    if (required.contains(type)) required.remove(type);
                }
            }
        }
        return required;
    }

    public static PPR_API_ResponseBody validateTypes(PPR_API_CreateClientRequest request) {
        Set<String> requiredTypes;
        // check for legal address if sole proprietor
        if (GlobalUtils.isSoleProprietor(request.customerInfo.legalInfo.inn)) {
            requiredTypes = PPR_API_Validator.validateTypes(request.customerInfo.addresses, PPR_API_Validator.requiredAddresses);
            if ( !requiredTypes.isEmpty()) {
                return ResponseBodyBuilder.constructPPR_API_ResponseBodyError(
                        'Validation error. Required address types are missing for sole proprietor. Required - ['
                                + String.join(new List<String>(requiredTypes), ', ') + '].'
                );
            }
        }
        // validate required emails
        requiredTypes = PPR_API_Validator.validateTypes(request.customerInfo.legalInfo.emails, PPR_API_Validator.requiredEmailTypes);
        if ( !requiredTypes.isEmpty()) {
            return ResponseBodyBuilder.constructPPR_API_ResponseBodyError(
                    'Validation error. Required email types are missing in legal info. Required - ['
                            + String.join(new List<String>(requiredTypes), ', ') + '].'
            );
        }
        // validate required phones
        requiredTypes = PPR_API_Validator.validateTypes(request.customerInfo.legalInfo.phones, PPR_API_Validator.requiredPhoneTypes);
        if ( !requiredTypes.isEmpty()) {
            return ResponseBodyBuilder.constructPPR_API_ResponseBodyError(
                    'Validation error. Required phone types are missing in legal info. Required - ['
                            + String.join(new List<String>(requiredTypes), ', ') + '].'
            );
        }
        return null;
    }

    public static PPR_API_ResponseBody validateAddressLength(List<PPR_API_CreateClientRequest.AddressObj> addresses) {
        if (addresses != null) {
            List<String> invalidAddressTypes = new List<String>();
            for (PPR_API_CreateClientRequest.AddressObj address : addresses) {
                if (String.isNotBlank(address.street) && String.isNotBlank(address.apartment) && String.isNotBlank(address.house)) {
                    if ((address.street.length() + address.house.length() + address.apartment.length() + 6) > 255) {
                        invalidAddressTypes.addAll(address.type);
                    }
                }
            }
            if ( !invalidAddressTypes.isEmpty()) {
                return ResponseBodyBuilder.constructPPR_API_ResponseBodyError(
                        'Validation error. ' + String.join(invalidAddressTypes, ', ')
                                + ' address fields is too long. street + house + apartment must be up to 249 chars. '
                );
            }
        }
        return null;
    }
}