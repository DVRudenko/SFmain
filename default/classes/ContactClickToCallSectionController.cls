public with sharing class ContactClickToCallSectionController {
    private ApexPages.StandardController controller {get; set;}
    public Contact contact {get; set;}
    public Map<String, String> fieldsValuesMap {get; set;}

    public ContactClickToCallSectionController(ApexPages.StandardController controller) {
    	this.controller = controller;
    	this.fieldsValuesMap = new Map<String, String>();
    	String currentId = ApexPages.currentPage().getParameters().get('id');
    	List<Schema.FieldSetMember> fieldSetMemberList = readFieldSet('ClickToCall', 'Contact');
    	String fields = '';

    	for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
    		fields += fieldSetMemberObj.getFieldPath() + ',';
    		fieldsValuesMap.put(fieldSetMemberObj.getFieldPath(), '');
    	}
    	fields = fields.removeEnd(',');
    	String query = 'SELECT MailingCountry, ' + fields + ' FROM contact WHERE Id = :currentId';
    	contact = Database.query(query);
        User currentUser = [
                    SELECT UserRole.Name
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];  

        if (currentUser.UserRole.Name != null) {
        	for (String val : fieldsValuesMap.keySet()) {
    			String clickToCall = '';
    			List<String> ctcList = new List<String>();
    			if (contact.get(val) != null) {
    				if (String.valueOf(contact.get(val)).contains(':')) {
    					clickToCall = String.valueOf(contact.get(val)).replaceAll('\\s+',''); 
    					ctcList = clickToCall.split(':');
    				} else if (String.valueOf(contact.get(val)).contains(',')) {
    					clickToCall = String.valueOf(contact.get(val)).replaceAll('\\s+',''); 
    					ctcList = clickToCall.split(',');
    				} else {
    					clickToCall = String.valueOf(contact.get(val)).replaceAll('\\s+','');
    					ctcList.add(clickToCall);
    				}

    				String endLink = '';
    				try {
    					if (contact.MailingCountry != null) {
    						for (String ph : ctcList) {
                                String vphone = ph.replace('/','');
                                vphone = vphone.replace('.','');
                                vphone = vphone.replace('-','');
                                vphone = vphone.replace('(','');
                                vphone = vphone.replace(')','');
    							system.debug('=== ' + vphone);
                                vphone = returnNaumenNumber(vphone, contact.MailingCountry, currentUser.UserRole.Name);
                                String czskprefix = '';
                                if (contact.MailingCountry == 'Czech Republic') {
                                    czskprefix = '881';
                                } else if (contact.MailingCountry == 'Slovakia') {
                                    czskprefix = '882';
                                }
                                endLink += '<a onclick="makefirstcall();" href="sip:' + czskprefix + vphone + '">' + vphone + '</a>, ';
    						}

    						endLink = endLink.removeEnd(', ');
    					}

    					fieldsValuesMap.put(val, endLink);
    				} catch (Exception e) {
    					system.debug('===Exception: ' + e.getMessage());
    					Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, 'Invalid phone. Please contact your administrator.'));
    				}
    			}
        	}
        }
    }

    public String returnNaumenNumber(String ph, String country, String roleName) {
        String validPhone = '';
        String mainCode = '';
        String exception1 = '';
        String exception2 = '';
        String exception3 = '';
        String exception4 = '';
        String exception5 = '';
        String exception6 = '';

        if (country == 'Germany' || country == 'Deutschland') {
            if (roleName == 'Salesteam Outbound 5' || roleName == 'Teamleiter Outbound 5') {
                mainCode = '00049';
                exception1 = '+49(0)';
                exception2 = '+49';
                exception3 = '49(0)';
                exception4 = '0049';
                exception5 = '49';
                exception6 = '049';
            } else {
                mainCode = '0049';
                exception1 = '+49(0)';
                exception2 = '+49';
                exception3 = '49(0)';
                exception4 = '00049';
                exception5 = '49';
                exception6 = '049';
            }
        } else if (country == 'Austria') {
            mainCode = '0049';
            exception1 = '+49(0)';
            exception2 = '+49';
            exception3 = '49(0)';
            exception4 = '00049';
            exception5 = '49';
            exception6 = '049';
        } else if (country == 'Poland') {
            mainCode = '00048';
            exception1 = '+48(0)';
            exception2 = '+48';
            exception3 = '48(0)';
            exception4 = '0048';
            exception5 = '48';
            exception6 = '048';
        } else if (country == 'Netherlands') {
            mainCode = '00031';
            exception1 = '+31(0)';
            exception2 = '+31';
            exception3 = '31(0)';
            exception4 = '0031';
            exception5 = '31';
            exception6 = '031';
        } else if (country == 'Belgium-FR') {
            mainCode = '0032';
            exception1 = '+32(0)';
            exception2 = '+32';
            exception3 = '32(0)';
            exception4 = '00032';
            exception5 = '32';
            exception6 = '032';
        } else if (country == 'Belgium-NL') {
            mainCode = '00032';
            exception1 = '+32(0)';
            exception2 = '+32';
            exception3 = '32(0)';
            exception4 = '0032';
            exception5 = '32';
            exception6 = '032';
        } else if (country == 'France') {
            mainCode = '0033';
            exception1 = '+33(0)';
            exception2 = '+33';
            exception3 = '33(0)';
            exception4 = '00033';
            exception5 = '33';
            exception6 = '033';
        } else if (country == 'Hungary') {
            mainCode = '00036';
            exception1 = '+36(0)';
            exception2 = '+36';
            exception3 = '36(0)';
            exception4 = '0036';
            exception5 = '36';
            exception6 = '036';
        } else if (country == 'Switzerland-DE' || country == 'Switzerland-FR' || country == 'Switzerland-IT') {
            mainCode = '0041';
            exception1 = '+41(0)';
            exception2 = '+41';
            exception3 = '41(0)';
            exception4 = '00041';
            exception5 = '41';
            exception6 = '041';
        } else if (country == 'Luxembourg') {
            mainCode = '00352';
            exception1 = '+352(0)';
            exception2 = '+352';
            exception3 = '352(0)';
            exception4 = '000352';
            exception5 = '352';
            exception6 = '0352';
        } else if (country == 'Czech Republic') {
            mainCode = '';
            exception1 = '+420(0)';
            exception2 = '+420';
            exception3 = '420(0)';
            exception4 = '00420';
            exception5 = '420';
            exception6 = '0420';
        } else if (country == 'Slovakia') {
            mainCode = '00421';
            exception1 = '+421(0)';
            exception2 = '+421';
            exception3 = '421(0)';
            exception4 = '000421';
            exception5 = '421';
            exception6 = '0421';
        }

        if (country == 'Luxembourg' || country == 'Slovakia') {
            if (ph.substring(0, 5) != mainCode) {
                if (ph.contains('+')) {
                    if (ph.length() >= 7 && ph.substring(0, 7) == exception1) {
                        validPhone = mainCode + ph.substring(7, ph.length());
                    } else if (ph.length() >= 4 && ph.substring(0, 4) == exception2) {
                        validPhone = mainCode + ph.substring(4, ph.length());
                    }
                } else {
                    if (ph.length() >= 6 && ph.substring(0, 6) == exception3) {
                        validPhone = mainCode + ph.substring(6, ph.length());
                    } else if (ph.length() >= 6 && ph.substring(0, 6) == exception4) {
                        validPhone = mainCode + ph.substring(6, ph.length());
                    } else if (ph.length() >= 3 && ph.substring(0, 3) == exception5) {
                        validPhone = mainCode + ph.substring(3, ph.length());
                    } else if (ph.length() >= 4 && ph.substring(0, 4) == exception6) {
                        validPhone = mainCode + ph.substring(4, ph.length());
                    } else if (ph.substring(0, 1) == '0') {
                        validPhone = mainCode + ph.substring(1, ph.length());
                    } 
                }
            } else {
                    return ph;
            }
        } else if (country == 'Czech Republic') {
            if (ph.contains('+')) {
                if (ph.length() >= 7 && ph.substring(0, 7) == exception1) {
                    validPhone = mainCode + ph.substring(7, ph.length());
                } else if (ph.length() >= 4 && ph.substring(0, 4) == exception2) {
                    validPhone = mainCode + ph.substring(4, ph.length());
                }
            } else {
                if (ph.length() >= 6 && ph.substring(0, 6) == exception3) {
                    validPhone = mainCode + ph.substring(6, ph.length());
                } else if (ph.length() >= 5 && ph.substring(0, 5) == exception4) {
                    validPhone = mainCode + ph.substring(5, ph.length());
                } else if (ph.length() >= 3 && ph.substring(0, 3) == exception5) {
                    validPhone = mainCode + ph.substring(3, ph.length());
                } else if (ph.length() >= 4 && ph.substring(0, 4) == exception6) {
                    validPhone = mainCode + ph.substring(4, ph.length());
                } else if (ph.substring(0, 1) == '0') {
                    validPhone = mainCode + ph.substring(1, ph.length());
                }
            }
        } else if (country == 'Hungary' || country == 'Belgium-NL' || country == 'Netherlands' || country == 'Poland' || (country == 'Germany' 
                && (roleName == 'Salesteam Outbound 5' || roleName == 'Teamleiter Outbound 5'))) {
            if (ph.substring(0, 5) != mainCode) {
                if (ph.contains('+')) {
                    if (ph.length() >= 6 && ph.substring(0, 6) == exception1) {
                        validPhone = mainCode + ph.substring(6, ph.length());
                    } else if (ph.length() >= 3 && ph.substring(0, 3) == exception2) {
                        validPhone = mainCode + ph.substring(3, ph.length());
                    }
                } else {
                    if (ph.length() >= 5 && ph.substring(0, 5) == exception3) {
                        validPhone = mainCode + ph.substring(5, ph.length());
                    } else if (ph.length() >= 4 && ph.substring(0, 4) == exception4) {
                        validPhone = mainCode + ph.substring(4, ph.length());
                    } else if (ph.length() >= 2 && ph.substring(0, 2) == exception5) {
                        validPhone = mainCode + ph.substring(2, ph.length());
                    } else if (ph.length() >= 3 && ph.substring(0, 3) == exception6) {
                        validPhone = mainCode + ph.substring(3, ph.length());
                    } else if (ph.substring(0, 1) == '0') {
                        validPhone = mainCode + ph.substring(1, ph.length());
                    }
                }
            } else {
                    return ph;
            }
        } else {
            if (ph.substring(0, 4) != mainCode) {
                if (ph.contains('+')) {
                    if (ph.length() >= 6 && ph.substring(0, 6) == exception1) {
                        validPhone = mainCode + ph.substring(6, ph.length());
                    } else if (ph.length() >= 3 && ph.substring(0, 3) == exception2) {
                        validPhone = mainCode + ph.substring(3, ph.length());
                    }
                } else {
                    if (ph.length() >= 5 && ph.substring(0, 5) == exception3) {
                        validPhone = mainCode + ph.substring(5, ph.length());
                    } else if (ph.length() >= 5 && ph.substring(0, 5) == exception4) {
                        validPhone = mainCode + ph.substring(5, ph.length());
                    } else if (ph.length() >= 2 && ph.substring(0, 2) == exception5) {
                        validPhone = mainCode + ph.substring(2, ph.length());
                    } else if (ph.length() >= 3 && ph.substring(0, 3) == exception6) {
                        validPhone = mainCode + ph.substring(3, ph.length());
                    } else if (ph.substring(0, 1) == '0') {
                        validPhone = mainCode + ph.substring(1, ph.length());
                    }
                }
            } else {
                return ph;
            }
        }

        return validPhone;
    }

	public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
	    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
	    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName); 
	    
	    return fieldSetObj.getFields(); 
	} 
}