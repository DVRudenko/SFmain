public with sharing class LeadClickToCallSectionController {
    private ApexPages.StandardController controller {get; set;}
    private User currentUser {get; set;}
    public Lead lead {get; set;}
    public Map<String, String> fieldsValuesMap {get; set;}
    public String userPhone {get; set;}
    //dialoga
    public static final String DIALOGA_USERNAME = 'd184603c-5b97-487d-affc-01b81902f75c';
    public static final String DIALOGA_PASSWORD = '2a4dd301-2e4c-45ef-b585-4a02d4547322';
    public static final String DIALOGA_ENDPOINT = 'https://api.parthenon.io/api/widget/d184603c-5b97-487d-affc-01b81902f75c/t-call/';
    public Boolean displayDialogaSection {get; set;}

    public LeadClickToCallSectionController(ApexPages.StandardController controller) {
    	this.controller = controller;
    	this.fieldsValuesMap = new Map<String, String>();
    	String currentId = ApexPages.currentPage().getParameters().get('id');
    	List<Schema.FieldSetMember> fieldSetMemberList = readFieldSet('ClickToCall', 'Lead');
    	String fields = '';

    	for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
    		fields += fieldSetMemberObj.getFieldPath() + ',';
    		fieldsValuesMap.put(fieldSetMemberObj.getFieldPath(), '');
    	}

    	fields = fields.removeEnd(',');
    	String query = 'SELECT Country, CountryCode, First_Call__c, Using_Phone__c, OwnerId, ' + fields + ' FROM Lead WHERE Id = :currentId';
    	this.lead = Database.query(query);
        this.currentUser = [
                    SELECT UserRole.Name, Profile.Name, Phone
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];
        this.userPhone = this.currentUser.Phone;

        List<GroupMember> groupMembersList = [
                SELECT UserOrGroupId 
                FROM GroupMember 
                WHERE Group.Name = 'DialogaUsers'
                LIMIT 10000];
        Set<Id> groupMemberIdsSet = new Set<Id>();
        for (GroupMember gm : groupMembersList) {
            groupMemberIdsSet.add(gm.UserOrGroupId);
        }
        if (groupMemberIdsSet.contains(UserInfo.getUserId())) {
            displayDialogaSection = true;
        } else {
            displayDialogaSection = false;
        }
                      
        if (this.currentUser.UserRole.Name != null) {
        	for (String val : fieldsValuesMap.keySet()) {
    			String clickToCall = '';
    			List<String> ctcList = new List<String>();
    			if (lead.get(val) != null) {
    				if (String.valueOf(lead.get(val)).contains(':')) {
    					clickToCall = String.valueOf(lead.get(val)).replaceAll('\\s+',''); 
    					ctcList = clickToCall.split(':');
    				} else if (String.valueOf(lead.get(val)).contains(',')) {
    					clickToCall = String.valueOf(lead.get(val)).replaceAll('\\s+',''); 
    					ctcList = clickToCall.split(',');
    				} else {
    					clickToCall = String.valueOf(lead.get(val)).replaceAll('\\s+','');
    					ctcList.add(clickToCall);
    				}

    				String endLink = '';
    				try {
    					if (lead.Country != null) {
    						for (String ph : ctcList) {
                                String vphone = ph.replace('/','');
                                vphone = vphone.replace('.','');
                                vphone = vphone.replace('-','');
                                vphone = vphone.replace('(','');
                                vphone = vphone.replace(')','');
    							system.debug('=== ' + vphone);
                                vphone = returnNaumenNumber(vphone, lead.Country, this.currentUser.UserRole.Name);
                                String czskprefix = '';
                                if (lead.Country == 'Czech Republic') {
                                    czskprefix = '881';
                                } else if (lead.Country == 'Slovakia') {
                                    czskprefix = '882';
                                }
                                endLink += returnPhoneLink(czskprefix, vphone);
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

    	if (country == 'Germany') {
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


    public void doDialogaCall() {
        try {
            if (this.lead.Phone == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please add phone to Lead.'));
                return;
            }
            if (this.userPhone == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please add phone to User profile.'));
                return;
            }

            Blob headerValue = Blob.valueOf(DIALOGA_USERNAME + ':' + DIALOGA_PASSWORD);
            String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = DIALOGA_ENDPOINT;
            request.setEndpoint(endpoint);                
            request.setMethod('POST');
            String dialogaSenderPhone = (this.userPhone != null || this.userPhone.contains('+')) ? this.userPhone.replace('+','00') : this.userPhone;
            String dialogaRecipientPhone = (this.lead.Phone != null || this.lead.Phone.contains('+')) ? this.lead.Phone.replace('+','00') : this.lead.Phone;
            String requestBody = '' +
                'session=7' + 
                '&Campaign=127' +
                '&Client=FLEETCOR0509' + 
                '&Phone1=' + dialogaSenderPhone +
                '&Phone2=' + dialogaRecipientPhone +
                '&propagate=4991114955728';
            request.setBody(requestBody);
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', authorizationHeader);
            HttpResponse response = h.send(request);
            if (response.getStatusCode() == 200) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Call started. Please pick up the User phone and wait for client.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please try again later.'));
                System.debug('DEBUG: response === ' + response);
                System.debug('DEBUG: response.Body === ' + response.getBody());
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Internal error. Please contact your administrator.'));
            System.debug('DEBUG: Exception === ' + e.getMessage());
        }
    }


    public String returnPhoneLink(String czskprefix, String vphone) {
        String phoneLink = '';
        if (this.currentUser.Profile.Name == 'AllStar Teamleader' || 
            this.currentUser.Profile.Name == 'Salesteamleiter Inbound' || this.currentUser.Profile.Name == 'Salesteamleiter') {
            phoneLink = vphone;
        } else {
            phoneLink = '<a onclick="makefirstcall();" href="sip:' + czskprefix + vphone + '">' + vphone + '</a>, ';
        }
        return phoneLink;
    }

    public void makeacall() {
    	if (lead.First_Call__c == null) {
	    	lead.First_Call__c = Datetime.now();
            lead.Using_Phone__c = true;
	    	update lead;
    	}
    }

	public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
	    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
	    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName); 
	    
	    return fieldSetObj.getFields(); 
	} 
}